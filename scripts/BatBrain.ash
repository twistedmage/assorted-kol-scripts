//sIMON unmodified
/******************************************************************************
                                BatBrain
                  supporting functions for combat scripts
*******************************************************************************

   Comments? Critiques? Coconuts?  Say stuff here:
   http://kolmafia.us/showthread.php?6445

   Want to say thanks?  Send me (Zarqon) a bat! (Or bat-related item)

******************************************************************************/
import <zlib.ash>

// globals
monster m;
boolean should_putty, should_olfact, should_pp;
boolean isseal;
boolean havemanuel;
int round, howmanyfoes;
int maxround = 30;
int[item] stolen;                // all the items you grab during this combat
string page;                     // most recent page load
effect dangerpoison;             // threatening poison effect of this monster
float beatenup;                  // cost of getting beaten up
int turncount = my_turncount();  // cache this for happenings
boolean finished() {             // returns true if the combat is over
   return (round > maxround);
}
float[string] fvars;             // variables for formulas

//=======================  SPREADS AND ADVEVENTS! =========================

typedef float[element] spread;
typedef float[stat] substats;
record combat_rec {        // data file format for advevents
   string ufname;          // user-friendly name
   string dmg;             // damage to monster
   string pdmg;            // damage to player / healing
   string special;         // comma-delimited list of other action results
};
record advevent {          // record of changes due to an event
   string id;              // macro-ready attack/jiggle/skill s/use i
   spread dmg;             // raw dmg dealt, before resists/vulns
   spread pdmg;            // raw dmg taken, before resists/vulns
   float att;              // monster attack adjustment
   float def;              // monster defense adjustment
   float stun;             // stun chance (expressed as average rounds stunned)
   float mp;               // mp gained/lost
   float meat;             // meat gained/lost
   float profit;           // profit cache to avoid recalculating
   int rounds;             // rounds consumed
   substats stats;         // substats gained/lost
   boolean endscombat;     // this action ends combat
   string note;            // user-friendly name or special note
};
advevent base;             // happens every round for the rest of combat
advevent retal;            // happens when monster hits you
advevent onhit;            // happens when you hit monster
advevent oncrit;           // happens when you get a critical hit
advevent onwin;            // happens when you win the combat
advevent adj;              // current adjustments for monster/player (includes unknownML)
advevent[int] custom;      // custom (must-be-done-sometime) actions
advevent[int] opts;        // all normal combat options
advevent plink;            // cache of stasis_action()
advevent smack;            // cache of attack_action()
advevent buytime;          // cache of stun_action()
base.id = "base";
// adjusted monster stat (unknown_ml and current or projected +/-ML)
float monster_stat(string which) {
   switch (which) {
      case "att": return adj.att + (m == last_monster() ? monster_attack() : monster_attack(m));
      case "def": return adj.def + (m == last_monster() ? monster_defense() : monster_defense(m));
      case "hp": return adj.dmg[$element[none]] + max(1.0, (m == last_monster() ? monster_hp() : monster_hp(m)));
   } return 0;
}
// adjusted player stat
float my_stat(string which) {
   switch (which) {
      case "hp": return minmax(my_hp()-adj.pdmg[$element[none]],0,numeric_modifier("_spec","Buffed HP Maximum"));
      case "mp": return minmax(my_mp()+adj.mp,0,numeric_modifier("_spec","Buffed MP Maximum"));
      case "Muscle":
      case "Mysticality":
      case "Moxie": return numeric_modifier("_spec","Buffed "+which);
     // TODO: track stat/level changes -- would improve accuracy in situations where you gain stats mid-combat
   } return 0;
}
// familiar, accounting for doppelshifter/costume wardrobe (possibly later: comma chameleon)
familiar my_fam() {
   return my_effective_familiar();
}

// math with spreads and events; first +
spread merge(spread fir, spread sec) {
   spread res;
   foreach el,v in fir res[el] += v;
   foreach el,f in sec res[el] += f;
   return res;
}
substats merge(substats fir, substats sec) {
   substats res;
   foreach s in $stats[] res[s] = fir[s] + sec[s];
   return res;
}
advevent merge(advevent fir, advevent sec) {
   advevent res;
   string autofunk = (have_skill($skill[funkslinging]) && is_integer(excise(fir.id,"use ","")) &&
                      is_integer(excise(sec.id,"use ",""))) ? fir.id+","+excise(sec.id,"use ","") : "";
   res.id = (autofunk != "" ? autofunk : fir.id+(sec.id != "" && fir.id != "" ? "; " : "")+sec.id);
   res.dmg = merge(fir.dmg,sec.dmg);
   res.pdmg = merge(fir.pdmg,sec.pdmg);
   res.att = fir.att + sec.att;
   res.def = fir.def + sec.def;
   res.stun = (fir.stun >= 1.0 || sec.stun >= 1.0) ? max(fir.stun,sec.stun) : fir.stun + sec.stun - fir.stun*sec.stun;
   res.mp = fir.mp + sec.mp;
   res.meat = fir.meat + sec.meat;
   res.rounds = fir.rounds + (autofunk != "" ? 0 : sec.rounds);
   res.stats = merge(fir.stats,sec.stats);
   res.endscombat = fir.endscombat || sec.endscombat;
   res.note = fir.note+(sec.note != "" && fir.note != "" ? "; " : "")+sec.note;
   return res;
}
advevent merge(advevent fir, advevent sec, advevent thr) { return merge(merge(fir,sec),thr); }
// now *
spread factor(spread f, float fact) {
   spread res;
   foreach el,v in f res[el] = v*fact;
   return res;
}
substats factor(substats f, float fact) {
   substats res;
   foreach s,v in f res[s] = v*fact;
   return res;
}
advevent factor(advevent a, float fact) {
   advevent res = merge(a,new advevent);
   if (fact == 1) return res;
   res.dmg = factor(res.dmg,fact);
   res.pdmg = factor(res.pdmg,fact);
   res.att *= fact;
   res.def *= fact;
   res.stun *= fact;
   res.mp *= fact;
   res.meat *= fact;            // note: does not factor rounds
   res.stats = factor(res.stats,fact);
   return res;
}

string elem_to_color(element src) {
   switch (src) {
      case $element[hot]: return "red";
      case $element[cold]: return "blue";
      case $element[spooky]: return "gray";
      case $element[sleaze]: return "purple";
      case $element[stench]: return "green";
   }
   return "black";
}
string to_html(spread src) {
   buffer b;
   if (src contains $element[none]) {
      b.append(rnum(src[$element[none]]));
      if (count(src) == 1) return b.to_string();
   }
   b.append("<b>");
   foreach el in $elements[]
      if (src contains el && src[el] != 0)
         b.append(" <span style='color: "+elem_to_color(el)+"'>("+rnum(src[el])+")</span>");
   return b.to_string()+"</b>";
}
spread to_spread(string dmg, float factor) {
   spread res;
   string[int] pld = split_string(dmg,"\\|");
   foreach i,bit in pld {
      matcher bittles = create_matcher("(\\S+?) ((?:(?:none|hot|cold|stench|sleaze|spooky|slime),?)+)",bit);
      if (!bittles.find()) { if (bit != "") res[$element[none]] += eval(bit,fvars); continue; }
      float thisd = eval(bittles.group(1),fvars);
      string[int] dmgtypes = split_string(bittles.group(2),",");
      foreach n,tid in dmgtypes res[to_element(tid)] += thisd / max(count(dmgtypes),1);
   }
   return factor(res,factor);
}
spread to_spread(string dmg) { return to_spread(dmg,1.0); }
float item_val(item i);
float dmg_dealt(spread action); // pre-declare for elemental starfish
element eform;
for i from 189 to 193 if (have_effect(to_effect(i)) > 0) {
   eform = to_element(to_lower_case(excise(to_effect(i),"","form"))); break;
}
advevent to_event(string id, spread dmg, spread pdmg, string special, int howmanyrounds) {
   advevent res;
   res.id = id;
   res.rounds = howmanyrounds;
   matcher bittles = create_matcher("aoe (\\d+?)(?:$|, )",special);   // aoe has to be separate/first to set dmg fvar
   int aoe = bittles.find() ? min(howmanyfoes,to_int(bittles.group(1))) : 1;
   if (count(dmg) > 0) {
      res.dmg = factor(dmg,aoe);
      if (eform != $element[none]) {       // if you have an elemental form, all damage to the monster is of that element
         spread formdmg;
         foreach el,dm in res.dmg formdmg[eform] += dm;
	     res.dmg = formdmg;
      }
      fvars["dmg"] = dmg_dealt(res.dmg);   // this is used for starfish/mosquitos and as a dmg_dealt cache
   } else fvars["dmg"] = 0;
   bittles = create_matcher("([a-z!]+?) (.+?)(?:$|, )",special);
   while (bittles.find()) switch (bittles.group(1)) {
      case "att": res.att = aoe*eval(bittles.group(2),fvars); break;
      case "def": res.def = aoe*eval(bittles.group(2),fvars); break;
      case "stun": if ($monsters[clancy] contains m) break;       // immune to all stuns
	     res.stun = eval(bittles.group(2),fvars);
     // detect multi-round stun immune monsters here
         if (res.stun > 1 && $monsters[your shadow, cyrus the virus, queen bee, beebee king, bee thoven, buzzerker, oil tycoon, oil baron, oil cartel, clancy,
             trophyfish, chester, frosty, ol' scratch, oscus, zombo, hodgman the hoboverlord, stella the demonic turtle poacher] contains m) res.stun = 0;
         break;
      case "mp": if (my_class() == $class[zombie master]) continue;
         res.mp = eval(bittles.group(2),fvars); break;
      case "meat": res.meat = eval(bittles.group(2),fvars); break;
      case "item": string[int] its = split_string(bittles.group(2),"; "); float v;
         foreach n,it in its {
            if (contains_text(id,"enthroned") && $ints[3450,4469,1445,1446,1447,1448] contains to_int(to_item(it)) && stolen contains to_item(it)) { v=0; break; }
            v += item_val(to_item(it));
         } res.meat += v/count(its); break;
      case "monster": boolean[monster] mlist; foreach n,mst in split_string(bittles.group(2),"\\|") 
	     mlist[to_monster(mst)] = true; if (!(mlist contains m)) return new advevent; break;
      case "notmonster": boolean[monster] mlist2; foreach n,mst in split_string(bittles.group(2),"\\|")
         mlist2[to_monster(mst)] = true; if (mlist2 contains m) return new advevent; break;
      case "phylum": if (m.phylum != to_phylum(bittles.group(2))) return new advevent; break;
      case "stats": string[int] sts = split_string(bittles.group(2),"\\|");
         foreach n,st in sts res.stats[to_class((n+1)*2).primestat] = eval(st,fvars); break;
      case "!!": res.note = bittles.group(2); break;
   }
   res.endscombat = special.contains_text("endscombat") || fvars["dmg"] >= monster_stat("hp");
   res.pdmg = factor(pdmg,1.0);
   return res;
}
advevent to_event(string id, spread dmg, spread hp, string special) { return to_event(id,dmg,hp,special,0); }
advevent to_event(string id, string special, int howmanyrounds) { return to_event(id,to_spread(0),to_spread(0),special,howmanyrounds); }
advevent to_event(string id, string special) { return to_event(id,to_spread(0),to_spread(0),special,0); }
advevent to_event(string id, combat_rec src, int howmanyrounds) {
   return to_event(id,to_spread(src.dmg),to_spread(src.pdmg),src.special,howmanyrounds);
}
advevent to_event(string id, combat_rec src) { return to_event(id,src,0); }


//=============== BLACKLIST ===================

int[string] blacklist;
void temp_blacklist_inc(string id, int amt) {
   if (((blacklist contains id) && blacklist[id] == 0) || amt < 1) return;
   blacklist[id] += amt;
}
void build_blacklist() {
   if (!file_to_map("BatMan_blacklist_"+replace_string(my_name()," ","_")+".txt",blacklist)) vprint("Error loading blacklist.",-2);
   if (my_location() != $location[none]) foreach it in tower_items(true) {     // add possible tower items to blacklist for known locations
      if (item_amount(it) == 0) continue;
      temp_blacklist_inc("use "+to_string(to_int(it)),1);
   }
   if (my_class() == $class[avatar of jarlsberg]) blacklist["attack"] = 0;     // Jarlsberg doesn't dirty his hands (even from range, which is kind of stupid)
   if (my_location().zone == "Hobopolis") {                                    // block Richard skills temporarily due to KoL bug
      blacklist["skill 7021"] = 0;
      blacklist["skill 7022"] = 0;
      blacklist["skill 7023"] = 0;
   }
   if (get_property("questM10Azazel") != "finished") {
      if (item_amount($item[imp air]) > 0) temp_blacklist_inc("use 4698",5);   // don't accidentally use your quest items
      if (item_amount($item[bus pass]) > 0) temp_blacklist_inc("use 4699",5);
   }
   if (get_property("sideDefeated") == "neither" && item_amount($item[flaregun]) > 0) temp_blacklist_inc("use 1705",1);   // save a flaregun in case of Wossname
   if (my_path() == "Bugbear Invasion") temp_blacklist_inc("use 1705",1);      // save a different flaregun for Bugbear invasion
   temp_blacklist_inc("skill 7074",to_int(get_property("burrowgrubSummonsRemaining")));  // cap burrowgrub at remaining uses
   if (have_equipped($item[stress ball])) temp_blacklist_inc("skill 7113",5-to_int(get_property("_stressBallSqueezes")));  // cap stress ball at remaining uses
   // TODO: expand this, more situational blockages
}
build_blacklist();

//=============== RESISTANCE / VULNERABILITY ===================

spread mres, pres;  // monster/player resistance

// build resistance(s)
spread get_resistance(element which) {
   spread res;
   foreach el in $elements[] res[el] = 0; res[$element[none]] = 0;
   if (which == $element[none]) return res;
   res[which] = 1;
   switch (which) {
      case $element[hot]: res[$element[sleaze]] = -1; res[$element[stench]] = -1; break;
      case $element[spooky]: res[$element[hot]] = -1; res[$element[stench]] = -1; break;
      case $element[cold]:   res[$element[hot]] = -1; res[$element[spooky]] = -1; break;
      case $element[sleaze]: res[$element[cold]] = -1; res[$element[spooky]] = -1; break;
      case $element[stench]: res[$element[cold]] = -1; res[$element[sleaze]] = -1; break;
   }
   return res;
}

// TODO: Frosty takes up to 3 damage from hot/spooky
// total damage to the monster from a spread, accounting for resistance and soft damage caps
float dmg_dealt(spread action) {
   float res;
   spread newdeal;
   foreach el,amt in action newdeal[el] = amt < 0 ? amt : max(to_int(amt > 0),amt - mres[el]*amt);  // first, apply monster resistances
   float softcapped(float orig, float cap, float exponent) {
      if (orig <= cap) return orig;
	  return cap + floor((orig - cap)**exponent);
   }
   void softcapit(float cap, float exponent) {
      foreach el,amt in newdeal res += softcapped(amt,cap,exponent);
   }
  // apply soft damage caps
   switch (m) {
      case $monster[gorgolok, the demonic hellseal]:
      case $monster[lumpy, the demonic sauceblob]:
      case $monster[demon of new wave]:
      case $monster[somerset lopez, demon mariachi]:
      case $monster[spaghetti demon]: softcapit(75,0.65); break;
      case $monster[stella, the demonic turtle poacher]: softcapit(50,0.65); break;

      case $monster[gorgolok, the infernal seal (volcanic cave)]:
      case $monster[lumpy, the sinister sauceblob (volcanic cave)]:
      case $monster[somerset lopez, dread mariachi (volcanic cave)]:
      case $monster[spaghetti elemental (volcanic cave)]:
      case $monster[spirit of new wave (volcanic cave)]:
      case $monster[stella, the turtle poacher (volcanic cave)]: softcapit(100,0.85); break;

      case $monster[chester]:
      case $monster[zombo]: softcapit(500,0.65); break;
      case $monster[gang of hobo muggers]:
      case $monster[ol' scratch]: softcapit(500,0.7); break;
      case $monster[oscus]: softcapit(500,0.75); break;
      case $monster[hodgman, the hoboverlord]: newdeal = factor(newdeal,0.75); softcapit(500,0.85); break;   // if frosty is undefeated: 300+floor((ceiling(0.05*x)-300)^0.75)

      case $monster[BRICKO cathedral]: 
      case $monster[gargantuchicken]: softcapit(1000,0.2); break;
      case $monster[groar]: softcapit(50,0.7); break;
      case $monster[mer-kin raider]: softcapit(400,0.75); break;
      case $monster[mother slime]: softcapit(200,0.7); break;
      case $monster[trophyfish]: softcapit(500,0.8); break;
	  default: foreach el,amt in newdeal res += amt;       // monster has no soft cap
   }
   return min(res,monster_stat("hp"));
}

float dmg_taken(spread pain) {     // note: negative values for healing
   float res;
   if (pain[$element[none]] < 0) res = pain[$element[none]];
   foreach el,amt in pain
      if (amt > 0) res += amt - min(pres[el]*max(amt,30),amt - 1.0);
   return res;
}

// =============== ACTION TRACKING ==================

// track which combat events have happened -- use external map to enwisen BatBrain-powered relay overrides
// values usable: canonical action id's, famspent, smusted, stolen, mother_<element>, hipster_stats, lackstool
record {
   int turn;
   int queued;
   int done;
}[string] happenings;  // the happening => the turn it happened
boolean happened(string occurrence) {
   if (count(happenings) == 0) file_to_map("BatMan_happenings_"+replace_string(my_name()," ","_")+".txt",happenings);
   if (happenings contains occurrence) return (happenings[occurrence].turn == turncount &&
       happenings[occurrence].queued + happenings[occurrence].done > 0);
   return false;
}
boolean happened(skill occurrence) { return happened("skill "+to_int(occurrence)); }
boolean happened(item occurrence) { return happened("use "+to_int(occurrence)); }
boolean happened(advevent occurrence) { return happened(occurrence.id); }
void set_happened(string occurrence, boolean q) {    // if q, adds the action to queued, otherwise done
   switch (occurrence) {
      case "steal": occurrence = "pickpocket"; break;
      case "summon": occurrence = "summonspirit"; break;
      case "chefstaff": occurrence = "jiggle"; break;
      case "use 5048": mres = get_resistance($element[cold]); break;  // shard of double-ice
      case "use 2404":
      case "use 2405": if (!q) vprint("Flyering completed: "+get_property("flyeredML"),5); break;
   }
   matcher splitfunk = create_matcher("use (\\d+), ?(\\d+)",occurrence);   // record funkslinging individually
   if (splitfunk.find()) { for i from 1 to 2 set_happened("use "+splitfunk.group(i),q); return; }
   if (count(happenings) == 0) file_to_map("BatMan_happenings_"+replace_string(my_name()," ","_")+".txt",happenings);
   if (happenings[occurrence].turn != turncount) {
      happenings[occurrence].turn = turncount;
      happenings[occurrence].done = 0;
   }
   if (q) happenings[occurrence].queued += 1;
     else happenings[occurrence].done += 1;
   if (map_to_file(happenings,"BatMan_happenings_"+replace_string(my_name()," ","_")+".txt"))
      vprint((q ? "Queued: " : "Happened: ")+occurrence,8);
   if (m == $monster[cyrus the virus]) {        // this tracking should be done here
      for i from 4011 to 4016 {
         if (occurrence != "use "+to_string(i)) continue;
         string prop = get_property("usedAgainstCyrus");
         if (prop == "" || index_of(prop,"memory") == last_index_of(prop,"memory"))
            set_property("usedAgainstCyrus",prop+to_item(i));
          else set_property("usedAgainstCyrus","");
      }
   }
}
void set_happened(string occurrence) { set_happened(occurrence, false); }
void set_happened(skill occurrence) { set_happened("skill "+to_int(occurrence)); }
void set_happened(item occurrence) { set_happened("use "+to_int(occurrence)); }


// =================== VALUES ======================

float stat_value(substats s) {    // value of stat gain
   float res, i;
   foreach st,v in s {
      if (v == 0) continue;
      i = v*to_float(vars["BatMan_baseSubstatValue"]);
      if (st == my_primestat()) i *= 2.0;
      if (st == current_hit_stat()) i *= 1.5;
      if (my_buffedstat(st) == my_defstat()) i *= 1.5;
      res += i;
   }
   if (res == 0) return 0;
   vprint_html("Value of stat gain: "+rnum(res)+entity_decode("&mu;"),9);
   return res;
}
substats m_stats() {              // stat gain from this monster
   stat d_stat() { return (string_modifier("Stat Tuning") == "") ? my_primestat() : string_modifier("Stat Tuning").to_stat(); }
   substats res;
   foreach st in $stats[] res[st] = numeric_modifier(st+" Experience") + ((monster_attack(m) + adj.att - monster_level_adjustment())/16.0)*(1+to_int(st == d_stat()));
   return res;
}

float item_val(item i) {
   if (is_tradeable(i) && historical_price(i) == 0 && vprint("Unknown value for tradeable item: "+i,8)) return 1000;
   return sell_val(i,true) == 0 ? 50 : sell_val(i,true);
}
float item_val(item i, float rate) {
   float modv = item_val(i) * minmax(rate*(item_drop_modifier()+100)/100.0,0,100)/100.0;
   vprint(i+" ("+rate+" @ +"+item_drop_modifier()+"): "+rnum(item_val(i),3)+entity_decode("&mu;")+" * "+rnum(minmax(rate*(item_drop_modifier()+100)/100.0,0,100))+"% = "+rnum(modv),8);
   return modv;
}
float monstervalue() {
   float res = to_float(my_path() == "Way of the Surprising Fist" ? max(meat_drop(m),12) : meat_drop(m)) * (max(0,meat_drop_modifier()+100))/100.0;
   int skipped; should_pp = (monster_attack(m) == 0);
   foreach num,rec in item_drops_array(m) {
      switch (rec.type) {
        // pp only
         case "p": if (my_primestat() != $stat[moxie] || skipped > 0) break;
            foreach dealy in stolen if (item_drops() contains dealy) break;
            res += item_val(rec.drop)*minmax(rec.rate*(numeric_modifier("Pickpocket Chance")+100)/100.0,0,100)/100.0;
            should_pp = true; break;
        // normal, pickpocketable
         case "": if (stolen contains rec.drop && skipped < stolen[rec.drop]) { skipped += 1; break; }
            if (!should_pp && count(stolen) == 0 && (rec.rate*(item_drop_modifier()+100)/100.0 < 100 || my_fam() == $familiar[Black Cat])) should_pp = true;
        // filter conditional drops
         case "c": if (item_type(rec.drop) == "shirt" && !have_skill($skill[torso awaregness])) break; // skip shirts if applic
            if (!is_displayable(rec.drop)) break;                          // skip quest items
            if (item_type(rec.drop) == "pasta guardian" && my_class() != $class[pastamancer]) break;  // skip pasta guardians for non-PMs
            if (rec.drop == $item[bunch of square grapes] && my_level() < 11) break;  // grapes drop at 11
                                                                           // include the rest????
        // normal, no pp
         case "n": res += item_val(rec.drop,max(rec.rate,0.01));
      }
   }
   return res + stat_value(m_stats());
}
float meatperhp, meatpermp;
if (get_property("_meatperhp") != "") meatperhp = to_float(get_property("_meatperhp"));
 else meatperhp = min(item_val($item[scroll of drastic healing])/max(1,(my_maxhp()-my_stat("hp"))),
                          10 - to_int(galaktik_cures_discounted())*4);   // best of galaktik, scroll of drastic (hey, they rhyme)
vprint("1 HP costs "+rnum(meatperhp,3)+entity_decode("&mu;")+". ( "+rnum(my_stat("hp"))+" / "+my_maxhp()+" )","#880000",7);
if (get_property("_meatpermp") != "") meatpermp = to_float(get_property("_meatpermp"));
 else {
   if (my_primestat() == $stat[mysticality] || (my_class() == $class[accordion thief] && my_level() > 8))
      meatpermp = 100.0 / (1.5 * to_float(my_level()) + 5);              // best of mmj, seltzer, galaktik
    else meatpermp = dispensary_available() ? 8 : 17 - to_int(galaktik_cures_discounted())*5;
 }
vprint("1 MP costs "+rnum(meatpermp,3)+entity_decode("&mu;")+". ( "+rnum(my_stat("mp"))+" / "+my_maxmp()+" )","#000088",7);
float runaway_cost() {       // returns the cost of running away
   return monstervalue() + to_int(get_property("valueOfAdventure"));
  // TODO: include navel ring / bander runaways?  Or maybe not.
}
float beatenup_cost() {     // returns the cost of getting (removing) beaten up
   if (my_fam() == $familiar[wild hare] || have_effect($effect[heal thy nanoself]) > 0) return 0;
   if (item_amount($item[personal massager]) > 0) return 100;
   float cheapest = to_int(get_property("valueOfAdventure"))*3;    // beaten up costs 3 adventures
   if (have_skill($skill[tongue of the otter])) cheapest = min(cheapest,meatpermp*mp_cost($skill[tongue of the otter]));
   if (have_skill($skill[tongue of the walrus])) cheapest = min(cheapest,meatpermp*mp_cost($skill[tongue of the walrus]));
   if (item_amount($item[tiny house]) > 0) cheapest = min(cheapest,item_val($item[tiny house]));
   if (item_amount($item[forest tears]) > 0) cheapest = min(cheapest,item_val($item[forest tears]));
   if (item_amount($item[sgeea]) > 0) cheapest = min(cheapest,item_val($item[sgeea]));
   return cheapest;
}

// ========= DATA FILE =========

combat_rec [string, int] factors;
load_current_map("batfactors",factors);        // master data file of battle factors
if (have_effect($effect[form of...bird]) > 0) {
   remove factors["item"];                     // remove items if impossible
   vprint("You can't use items in this combat.",-6);
}
if (have_effect($effect[temporary amnesia]) > 0) {
   remove factors["skill"];                    // remove skills if impossible
   vprint("You can't cast any skills with amnesia!",-5);
}
if (my_fam() != $familiar[bandersnatch]) remove factors["bander"];    // remove irrelevant batfactors to
if (my_fam() != $familiar[hatrack]) remove factors["hatrack"];        // save time during the following
if (my_fam() != $familiar[scarecrow]) remove factors["scare"];
if (!have_equipped($item[crown of thrones])) remove factors["crown"];

float spell_elem_bonus(string types) {
   float result;
   int milieu = 0;
   foreach el in $elements[] {
      if (types.contains_text(to_string(el))) {
         milieu += 1;
         result += numeric_modifier(to_string(el)+" Spell Damage");
      }
   }
   if (milieu == 0) return 0;
   return (result / (milieu + to_int(types.contains_text("none"))));
}
string normalize_dmgtype(string dmgt) {
   switch (dmgt) {
      case "prismatic": return "hot,cold,spooky,sleaze,stench";
      case "pasta": if (have_equipped($item[chester aquarius medallion]) || have_equipped($item[sinful desires])) return "sleaze";
         if (have_equipped($item[necrotelicomnicon])) return "spooky";
         if (have_equipped($item[cookbook of the damned])) return "stench";
      case "sauce": if (have_equipped($item[ol' scratch's manacles]) || have_equipped($item[capsaicin conjuration]) ||
            have_equipped($item[ol' scratch's ash can]) || have_equipped($item[snapdragon pistil])) return "hot";
         if (have_equipped($item[glacial grimoire]) || have_equipped($item[double-ice box]) ||
             have_equipped($item[enchanted fire extinguisher])) return "cold";
         if (dmgt == "sauce") {
            if (have_skill($skill[immaculate seasoning]) && dmg_dealt(to_spread((1+spell_elem_bonus("hot"))+" hot")) != dmg_dealt(to_spread((1+spell_elem_bonus("cold"))+" cold")))
               return (dmg_dealt(to_spread((1+spell_elem_bonus("hot"))+" hot")) > dmg_dealt(to_spread((1+spell_elem_bonus("cold"))+" cold"))) ? "hot" : "cold";
            return "hot,cold";
         }
         if (have_effect($effect[spirit of cayenne]) > 0) return "hot";
         if (have_effect($effect[spirit of peppermint]) > 0) return "cold";
         if (have_effect($effect[spirit of garlic]) > 0) return "stench";
         if (have_effect($effect[spirit of wormwood]) > 0) return "spooky";
         if (have_effect($effect[spirit of bacon grease]) > 0) return "sleaze";
         string res = "hot,cold,spooky,sleaze,stench,none";
         if (res.contains_text(m.defense_element)) res.replace_string(m.defense_element+",","");
         return res;
      case "perfect": element[int] ranks;
         foreach el in $elements[] ranks[count(ranks)] = el;
         sort ranks by mres[value];
         return to_string(ranks[0]);
   }
   return dmgt;
}

matcher rng = create_matcher("\\{.+?,(.+?),.+?}","");
//reduce ranges to averages
string deranged(string sane) {
   rng.reset(sane);
   while (rng.find()) sane = sane.replace_string(rng.group(0),rng.group(1));
   return sane;
}
foreach te,it,rd in factors {                 // remove placeholders, reduce ranges to averages, tune damage
   if (contains_text(rd.special,"custom")) { remove factors[te,it]; continue; }
   factors[te,it].dmg = deranged(rd.dmg);
   factors[te,it].pdmg = deranged(rd.pdmg);
   factors[te,it].special = deranged(rd.special);
   foreach kw in $strings[prismatic,pasta,sauce,perfect] if (factors[te,it].dmg.contains_text(kw))
      factors[te,it].dmg = factors[te,it].dmg.replace_string(kw,normalize_dmgtype(kw));
   if (te == "skill" && it == 3008) {         // weapon of the pastalord
      if (!contains_text(factors[te,it].dmg,"none"))
         factors[te,it].dmg += ",none";		 
        else factors[te,it].dmg = factors[te,it].dmg.replace_string("hot,cold,spooky,sleaze,stench,","");
   }
}

//===================== BUILD COMBAT ENVIRONMENT =========================

advevent famevent() {
   advevent fam;
   if ($classes[avatar of boris, avatar of jarlsberg] contains my_class()) return fam;
   if (!(factors["fam"] contains to_int(my_fam())) || (my_fam() == $familiar[dandy lion] && item_type(equipped_item($slot[weapon])) != "whip")) return fam;
   fam.id = to_string(my_fam());
   if (happened("famspent")) return fam;
   fvars["fweight"] = familiar_weight(my_familiar()) + weight_adjustment() + min(20,2*my_level())*to_int(to_int(my_class())+82 == to_int(my_fam()));
   if (my_familiar() == $familiar[disembodied hand]) fvars["famgearpwr"] = get_power(familiar_equipped_equipment($familiar[disembodied hand]));
   if ($familiars[mad hatrack, fancypants scarecrow] contains my_familiar()) {
      string famkey = my_familiar() == $familiar[mad hatrack] ? "hatrack" : "scare";
      if (!(factors[famkey] contains to_int(equipped_item($slot[familiar])))) return fam;
      if (get_power(equipped_item($slot[familiar])) > 0 && get_power(equipped_item($slot[familiar])) < 200)
         fvars["fweight"] = min(fvars["fweight"],floor(get_power(equipped_item($slot[familiar]))/4.0));
      fam = to_event(to_string(my_familiar()),factors[famkey,to_int(equipped_item($slot[familiar]))]);
   } else fam = to_event(to_string(my_fam()),factors["fam",to_int(my_fam())]);
   if (have_effect($effect[raging animal]) > 0 && dmg_dealt(fam.dmg) > 0) fam.dmg[$element[none]] += 30;
   if (round > 9) fam.meat = max(0,fam.meat);
   matcher rate = create_matcher("rate (.+?)(, |$)",factors["fam",to_int(my_fam())].special);
   float r = (rate.find()) ? eval(rate.group(1),fvars) : 0;
   fam = (r == 0 || r == 1) ? factor(fam,r) : factor(fam,minmax(r + min(0.1,have_effect($effect[jingle jangle jingle])) +
      min(0.25,have_effect($effect[stickler for promptness])) + min(0.25,to_int(have_equipped($item[loathing legion helicopter]))),0,1.0));
   return fam;
}

advevent crown() {
   advevent c;
   if (!(factors["crown"] contains to_int(my_enthroned_familiar())) || my_class() == $class[avatar of boris]) return c;
   c.id = "enthroned "+my_enthroned_familiar();
   boolean cutoff = factors["crown",to_int(my_enthroned_familiar())].special.contains_text("r3");
   if (cutoff && round > 3) return c;                             // can't act anymore
   c = to_event("enthroned "+my_enthroned_familiar(),factors["crown",to_int(my_enthroned_familiar())]);
   float crownrate = (cutoff) ? 1 : 0.315;                        // reasonable for all 30%/33% familiars
   switch (my_enthroned_familiar()) {
      case $familiar[chihuahua]: case $familiar[sandworm]: case $familiar[snow angel]: crownrate = 0.5; break;
      case $familiar[Green Pixie]: crownrate = 0.2; break; case $familiar[Maple Leaf]: crownrate = 0.25; break;
      case $familiar[Black Cat]: crownrate = 1; break;
   }
   c = factor(c,crownrate);
   return c;
}
advevent basecache;                          // base round event cached for speed
advevent baseround() {                       // base round event
   if (round > 0 && basecache.note.to_int() == round) return basecache;
   basecache = (have_equipped($item[crown of thrones])) ? merge(base,famevent(),crown()) : merge(base,famevent());
   if (happened("skill 12000")) basecache.dmg[$element[none]] += my_level();
   basecache.note = round;
   return basecache;
}

void fxngear() { 
  // ======== EFFECTS =========
   advevent aedoh;
   foreach ef,fect in factors["effect"] {
      if (have_effect(to_effect(ef)) == 0) continue;
      vprint_html("Factoring in "+to_effect(ef)+": "+to_html(to_spread(fect.dmg))+" damage, "+fect.special,4);
      aedoh = to_event(to_string(to_effect(ef)),fect);
      if (contains_text(fect.special,"retal"))
         retal = merge(retal,aedoh);
       else if (contains_text(fect.special,"onhit"))
         onhit = merge(onhit,aedoh);
        else base = merge(base,aedoh);
   }
  // ======== GEAR ==========
   foreach eq,uip in factors["gear"] {
      if (!have_equipped(to_item(eq))) continue;
      vprint_html("You have "+to_item(eq)+" equipped: "+to_html(to_spread(uip.dmg))+" damage, "+uip.special,4);
      aedoh = to_event(to_string(to_item(eq)),uip);
      if (contains_text(uip.special,"retal"))
         retal = merge(retal,aedoh);
       else if (contains_text(uip.special,"onhit"))
          onhit = merge(onhit,aedoh);
        else if (contains_text(uip.special,"oncrit"))
           oncrit = merge(oncrit,aedoh);
         else base = merge(base,aedoh);
   }
   retal.id = "";
   onhit.id = "";
   oncrit.id = "";
   onwin.id = "";
}

// ====== MONSTER ======
float m_hit_chance() {            // monster hit chance
   float stunmod = minmax(merge(baseround(),adj).stun,0,1.0);
   if ($monsters[a.m.c. gremlin, batwinged gremlin, erudite gremlin, spider gremlin, vegetable gremlin, oil tycoon, oil baron, 
                 oil cartel, reanimated baboon skeleton, reanimated bat skeleton, reanimated demon skeleton, reanimated giant spider skeleton,
                 reanimated serpent skeleton, reanimated wyrm skeleton, your shadow] contains m) return 1.0 - stunmod;
   return (1.0 - stunmod)*minmax(0.55 + (max(monster_stat("att"),0.0) - my_stat("Moxie"))*0.055,my_location() == $location[slime tube] ? 0.8 : 0.06,0.94);
}
spread m_regular() {               // damage dealt by monster attack
   switch (m) {
      case $monster[naughty sorority nurse]:
      case $monster[antique database server]: return to_spread(0);        // these monsters have no attack
      case $monster[your shadow]: return to_spread(95 + (my_maxhp()/6));  // Your Shadow has a unique damage formula
   }
   spread res;
   res[m.attack_element] = max(1.0,max(0.0,max(monster_stat("att"),0.0) - my_defstat(true)) + 0.225*max(monster_stat("att"),0.0) - numeric_modifier("Damage Reduction")) *
      (1 - minmax((square_root(numeric_modifier("Damage Absorption")/10) - 1)/10,0,0.9));
   return res;
}
advevent m_event(float att_mod, float stun_mod) {      // monster event -- attack + retal, factored by hitchance
   advevent res;                                       // allows prediction with attack and stun modifiers
   adj.att += att_mod;
   adj.stun += stun_mod;
   res.pdmg = m_regular();
   if (my_stat("hp") - dmg_taken(res.pdmg) > 0) {      // you didn't die; add retaliation event
      res = merge(retal,res);
      if (have_equipped($item[double-ice cap]) && !happened("icecapstun"))  // double-ice cap only happens once
	     res = merge(to_event("double-ice cap",to_spread("15 cold"),to_spread(0),"stun 1"),res);
   }
   res = factor(res,m_hit_chance());
  // TODO: add high-ML slime special attacks: they totally have them!
   switch (m) {                   // monster special moves, not factored by hitchance
      case $monster[naughty sorority nurse]: res.dmg = to_spread(-min(90,monster_hp(m)+monster_level_adjustment()-monster_stat("hp"))); break;  // 100% rate, capped at maxHP
      case $monster[normal hobo]:
      case $monster[sleaze hobo]:
      case $monster[spooky hobo]:
      case $monster[stench hobo]: 
      case $monster[hot hobo]:
	  case $monster[cold hobo]: res.pdmg[m.attack_element] += 0.1*my_maxhp(); break; // totally guessing with these
      case $monster[frustrating knight]: res.pdmg[$element[none]] += 95; break;
      case $monster[gaunt ghuol]:
      case $monster[gluttonous ghuol]: res.dmg = to_spread("-1.65"); break;          // 30% chance to heal 1-10 HP
      case $monster[huge ghuol]: res.dmg = to_spread("-1.65"); break;                // 30% chance to heal 1-10 HP
      case $monster[dr awkward]: res.dmg = to_spread("-25"); break;                  // assuming 50%
      case $monster[quiet healer]: res.pdmg[$element[none]] -= 0.25*17.5; break;     // ... 25% ... ...??
      case $monster[knob goblin mad scientist]: res.mp += 0.25*9; break;             // assuming 25% activation rate??
   }
   if (my_stat("hp") - dmg_taken(res.pdmg) <= 0) res.meat -= beatenup;    // the monster took you out -- and I don't mean to dinner. ouch!
   adj.att -= att_mod;
   adj.stun -= stun_mod;
   return res;
}
advevent m_cache;
advevent m_event() {
   if (round > 0 && m_cache.note.to_int() == round) return m_cache;
   m_cache = m_event(0,0);
   m_cache.note = round;
   return m_cache;
}
float m_dpr(float att_mod, float stun_mod) {
   return dmg_taken(m_event(att_mod,stun_mod).pdmg);
}
int kill_rounds(spread s) {       // how many rounds for a given damage spread to kill the monster
   return ceil(to_float(monster_stat("hp")) /
               max(dmg_dealt(s) + dmg_dealt(m_event().dmg) + dmg_dealt(baseround().dmg),0.0001));
}
int kill_rounds(advevent a) { return kill_rounds(a.dmg); }  // how many rounds for a given action to kill the monster
int die_rounds() {                // how many rounds at the current ML and stun until you die
   return ceil(my_stat("hp") / max(m_dpr(0,-adj.stun),0.0001)) + adj.stun;
}
boolean intheclear() {            // returns true if you will outlive the combat
   if (m == $monster[none] || have_effect($effect[strangulated]) > 0) return false;
   return (die_rounds() > maxround);
}
boolean unarmed() {
   return (equipped_item($slot[weapon]) == $item[none] && equipped_item($slot[offhand]) == $item[none]);
}

// ======= WHAT ARE THE CHANCES =======

float fumble_chance() {
   if (have_equipped($item[operation patriot shield]) && happened($skill[throw shield]) && !happened("shieldcrit")) return 0;
   if (have_effect($effect[clumsy]) > 0 || have_effect($effect[QWOPped Up]) > 0) return 1.0;
   if ((boolean_modifier("Never Fumble") || have_effect($effect[song of battle]) > 0) && m != $monster[dr awkward]) return 0;
   return (1.0 / max(22.0,to_int(have_effect($effect[sticky hands]) > 0)*30.0)) * max(1.0,numeric_modifier("Fumble")) / (1.0+to_int(have_skill($skill[eye of the stoat])));
}
advevent fumble() {
   if (string_modifier("Outfit") == "Clockwork Apparatus")
      return to_event("",to_spread(15*0.25),to_spread(-12.5*0.25),"stun 0.25, mp 12.5*0.25, att -1, def -1");
   int wpnpwr = get_power(equipped_item($slot[weapon]));
   if (have_skill($skill[double-fisted skull smashing]) && item_type(equipped_item($slot[offhand])) != "shield")
      wpnpwr += get_power(equipped_item($slot[offhand]));
   return to_event("",to_spread(0),to_spread(max(1.0,to_float(wpnpwr)*0.05)),"");
}

float critchance() {         // CRITCH-nce
   if (have_equipped($item[operation patriot shield]) && happened($skill[throw shield]) && !happened("shieldcrit")) return 1;
   if (have_effect($effect[song of fortune]) > 0 && !happened("crit")) return 1;
   return minmax((9.0 + numeric_modifier("Critical Hit Percent"))*(numeric_modifier("Critical") + 1)/100.0,0,1.0);
}

float hitchance(string id) {        // HITCH-nce
   if (id == "jiggle") return 1.0;
   if (have_equipped($item[operation patriot shield]) && happened($skill[throw shield]) && !happened("shieldcrit")) return 1.0;
  // cunctatitis blocks 50% of everything, black cat blocks 50% of items
   float through = 1.0 - 0.5*to_int(have_effect($effect[cunctatitis]) > 0);
   if (id == "attack") through *= 1.0 - fumble_chance();
   if (have_effect($effect[song of battle]) > 0) return through;
   float attack = my_stat(to_string(current_hit_stat())) + (have_skill($skill[sick pythons]) ||
      (have_skill($skill[master of the surprising fist]) && unarmed()) ? 20 : 0);
   if (have_equipped($item[operation patriot shield]) && my_class() == $class[Disco Bandit] &&
       current_hit_stat() == $stat[moxie]) attack += 100;
   matcher aid = create_matcher("(attack|use|skill) ?(\\d+)?",id);
   if (aid.find()) switch (aid.group(1)) {
      case "use": if (my_fam() == $familiar[black cat]) through *= 0.5;
         return (contains_text(to_string(m),"Naughty Sorceress") || m == $monster[bonerdagon]) ? through*0.75 : through;
      case "skill": if (contains_text(to_string(m),"Naughty Sorceress") || m == $monster[bonerdagon]) through *= 0.5;
         switch (to_int(aid.group(2))) {
            case 0001: case 2003: case 7097: break;  // beak, head, turtle*7 tails all have regular hitchance
            case 7010: case 7011: case 7012: case 7013: case 7014: attack = 10 + my_stat("Moxie"); break; // bottle rockets are mox+10
            case 7008: attack = my_stat("Moxie"); break;                                   // moxman
            case 1003: if (have_skill($skill[eye of the stoat])) attack += 20;             // ts
            case 1004: case 1005: case 7096: if (my_class() == $class[seal clubber] && item_type(equipped_item($slot[weapon])) == "club" &&
                        (weapon_hands(equipped_item($slot[weapon])) == 2 || equipped_item($slot[weapon]) == $item[sledgehammer of the v]))
                           return through;   // lts, bashing slam smash
                    if ($ints[1003,1004,7096] contains aid.group(2).to_int()) break;
                    if (have_skill($skill[eye of the stoat])) attack *= 1.25 + 0.05*to_int(my_class() == $class[seal clubber]); break;
            case 2015: case 2103: attack += min(my_level()*2,20.0); break;    // kneebutt & head+knee
            case 11000: break;                                                // regular hit chance, but no fumble
            case 11001: attack *= 1.2; attack += 20; break;                   // estimated: cleave is not perfectly spaded
            default: attack = 0;
         }
   }
   return attack == 0 ? through : min(critchance() + (1.0 - critchance())*max(6.0 + attack - max(monster_stat("def"),0),0)/11.0,1.0)*through;
}


//===================== BUILD COMBAT OPTIONS =========================

advevent oneround(advevent r) {           // plugs an advevent into the current combat and returns the event
   advevent a = merge(r,new advevent);
   for i from 1 upto a.rounds a = merge(a,baseround());
   a.pdmg[$element[none]] = max(a.pdmg[$element[none]], my_stat("hp")-my_maxhp());  // cap healing/mp gain BEFORE merging monster event
   a.mp = min(a.mp,my_maxmp()-my_stat("mp"));
   if (!a.endscombat) for i from 1 upto a.rounds
      a = merge(a,m_event(a.att,max(0,a.stun+1-i)));   // monster event(s)
//   if (monster_stat("hp")-dmg_dealt(a.dmg) < 1) a.meat += monstervalue();   // monster death should only be included for chain profits
   return a;
}

float to_profit(advevent haps, boolean nodelevel) {    // determines the profit of an action in the current combat
   advevent a = oneround(haps);
   haps.profit = minmax(-dmg_taken(a.pdmg),                             // hp
                        min(0,max(-dmg_taken(a.pdmg),-my_stat("hp"))+max(0,my_stat("hp")-max(0,my_maxhp()-numeric_modifier("_spec","HP Regen Min")))),
                        max(0,my_maxhp()-my_stat("hp")-numeric_modifier("_spec","HP Regen Min")))*meatperhp +
          minmax(a.mp,                                                  // mp
                 min(0,max(a.mp,-my_stat("mp"))+max(0,my_stat("mp")-max(0,my_maxmp()-numeric_modifier("_spec","MP Regen Min")))),
                 max(0,my_maxmp()-my_stat("mp")-numeric_modifier("_spec","MP Regen Min")))*meatpermp +
          (nodelevel ? 0 : (a.att == 0 ? 0 : (m_dpr(0,0) - m_dpr(a.att,0))*meatperhp)) +  // delevel
          stat_value(a.stats)+                                          // substats
          a.meat;                                                       // meat
   return haps.profit;
}
float to_profit(advevent haps) { return to_profit(haps,false); }

string to_html(advevent a, boolean table) {
   buffer res;
   if (table) res.append("<table width=100%><tr><th>Action</th><th>Profit</th><th>Damage</th><th>Other</th></tr>");
   res.append("<tr><td align=left>");
   switch {
      case (contains_text(a.id,"use ")): res.append("Throw "+excise(a.id,"use ","")); break;
      case (contains_text(a.id,"skill ")): res.append("Cast "+excise(a.id,"skill ","")); break;
      case (a.id == "attack"): res.append("Attack with weapon"); break;
      case (a.id == "jiggle"): res.append("Jiggle Your Chefstaff"); break;
      default: res.append(a.id);
   }
   res.append(" <span color='green'><small>("+rnum(a.meat)+entity_decode("&mu;")+")</small></span></td><td align=right><span color='green'><b>");
   res.append(rnum(to_profit(a))+entity_decode("&mu;")+"</b></span></td><td align=center>");
   if (dmg_dealt(a.dmg) > 0) {
      res.append(to_html(a.dmg)+" <small>");
      if (a.dmg[$element[none]] != dmg_dealt(a.dmg)) res.append("Actual: "+rnum(dmg_dealt(a.dmg)));
      res.append(" <span color='green'>("+rnum(-a.meat/dmg_dealt(a.dmg))+" "+entity_decode("&mu;")+"/dmg)</span></small>");
   } else res.append("--");
   res.append("</td><td align=center>");
   if (a.att != 0) res.append(" <span color='gray'>Att: "+rnum(a.att)+" <small>("+rnum(m_dpr(a.att,0)-m_dpr(0,0))+" DPR)</small> Def: "+rnum(a.def)+"</span> ");
   if (a.stun != 0) res.append(" "+rnum(a.stun*100.0)+"% stun chance");
   if (dmg_taken(a.pdmg) != 0) res.append(" <span color='red'>HP: "+to_html(a.pdmg)+"</span> ");
   if (a.mp != 0) res.append(" <span color='blue'>MP: "+rnum(a.mp)+"</span> ");
   res.append("</td></tr>");
   if (table) res.append("</table>");
   return res.to_string();
}
string to_html(advevent a) { return to_html(a,true); }

void addopt(advevent a, float meatcost, int mpcost) {
   if (a.id == "") return;
   if (m == $monster[your shadow] && a.pdmg[$element[none]] >= 0) return;   // don't add non-healing items vs. shadow
   if (m == $monster[mine crab] && dmg_dealt(a.dmg) > 39) a.pdmg[$element[none]] = 100000;   // sensitive beasties
   if (happened("skill 5023")) foreach n in $ints[5003,5005,5008,5012,5019]
      if (a.id == "skill "+n) { a.att *= 2.0; a.def *= 2.0; }   // mistletoe doubles DB skill deleveling
  // TODO: add overkilling hobos
   int c = count(opts);
   opts[c] = factor(a,hitchance(a.id));
   opts[c].meat -= meatcost;
   opts[c].mp -= mpcost;
   if (my_class() == $class[zombie master] && contains_text(opts[c].note, "zombify")) opts[c].mp += 1;
}

advevent get_action(string whichid) {
   foreach i,opt in opts if (opt.id == whichid) return opt;
   return new advevent;
}
advevent get_action(item it) { return get_action("use "+to_int(it)); }
advevent get_action(skill sk) { return get_action("skill "+to_int(sk)); }

// bang potions -- returns specified potion, or the average of remaining unidentified potions (which is "")
combat_rec get_bang(string which) {            // TODO: totally rework this
   combat_rec res;
   res.dmg = "0";
   switch (which) {
      case "healing": res.dmg = "-14"; return res;
      case "confusion": res.special = "att -2.5, def -2.5"; return res;
      case "ettin strength": res.special = "att 10"; return res;  // this amount is unknown
      case "mental acuity": res.special = "att 5, def 5"; return res;
      case "teleportitis": res.special = "def 17.5"; return res;
      case "blessing": res.special = "def 25"; return res;
      case "detection":
      case "sleepiness":
      case "inebriety": return res;
   }
   string known;     // i don't like this method but we can't work with combat_recs here
   for i from 819 upto 827 known += get_property("lastBangPotion"+i);
   advevent bang; float bcount;
   foreach bp in $strings[healing,confusion,ettin strength,mental acuity,teleportitis,blessing,detection,sleepiness,inebriety] {
      if (contains_text(known,bp)) continue;
      bcount += 1;
      bang = merge(bang,to_event("",get_bang(bp)));
   }
   if (bcount > 1) bang = factor(bang,1.0/bcount);
   res.dmg = bang.dmg[$element[none]];
   if (bang.att != 0) res.special = "att "+bang.att;
   if (bang.def != 0) res.special = "def "+bang.att;
   return res;
}
combat_rec get_sphere(string which) {
   combat_rec res;
   res.dmg = "0";
   switch (which) {
      case "fire": res.dmg = "9 hot"; return res;
      case "nature": res.special = "att -2, def -2"; return res;
      case "lightning": res.dmg = "9"; return res;
      case "water": res.pdmg = "-4.5"; return res;
   }
   return res;
}

//======== ATTACK ==========

// regular attack (also other attack skills with related damage formulae)
spread regular(int ts) {  // 1) norm, 2) thrust-smack / axing, 3) lts, 5) bashing slam smash / cleave
   spread res;
   if (m == $monster[x-dimensional horror]) return res;
   float ltsadj = (ts == 3) ? 1.25 + 0.05*to_int(my_class() == $class[seal clubber]) : (ts == 5) ? 1.4 : 1.0;
   boolean ranged = (weapon_type(equipped_item($slot[weapon])) == $stat[moxie]);
   float radj = (ranged) ? 0.75 : 1.0;
   if (equipped_item($slot[weapon]) == $item[none]) radj = 0.25 + 0.75*to_int(ts == 0);
   res[$element[none]] = max(0,max(0,floor((ranged ? my_stat("Moxie") : my_stat("Muscle"))*ltsadj*radj) - monster_stat("def")) +
      max(1,numeric_modifier("Weapon Damage") + 0.5) * (critchance()+1.0) * ts +
      to_int(ranged)*numeric_modifier("Ranged Damage")) * (100 + numeric_modifier("Weapon Damage Percent") +
      to_int(ranged)*numeric_modifier("Ranged Damage Percent"))/100;
   if (have_skill($skill[double-fisted]) && to_slot(equipped_item($slot[offhand])) == $slot[weapon])
      res[$element[none]] += 0.15*get_power(equipped_item($slot[offhand])) + 0.5;
   if (unarmed() && have_skill($skill[master of the surprising fist])) res[$element[none]] += 10;
   foreach el in $elements[] if (numeric_modifier(el+" Damage") > 0) res[el] = numeric_modifier(el+" Damage");
   return (have_equipped($item[skeletal scabbard]) && item_type(equipped_item($slot[weapon])) == "sword") ? factor(res,2) : res;
}

spread d;
float rate;

// ======== ITEMS ==========         cost: item_value, unless reusable
void build_items() {                                                // TODO: spheres, bang potions
   boolean dropspants() { foreach i,n in item_drops(m) if (item_type(i) == "pants") return true; return false; }
   boolean[item] added;
   added.clear();
   foreach it,fields in factors["item"] {
      if (is_goal(to_item(it)) || item_amount(to_item(it)) <= blacklist["use "+it] || !be_good(to_item(it))) continue;
	  if (blacklist contains ("use "+it) && blacklist["use "+it] == 0) continue;
      if (happened("use "+it) && (contains_text(fields.special,"once") || (!to_item(it).reusable &&
          happenings["use "+it].queued >= max(0,item_amount(to_item(it)) - blacklist["use "+it])))) continue;
      rate = item_val(to_item(it))*to_int(!to_item(it).reusable || $monsters[bonerdagon, naughty sorceress] contains m);
      switch (it) {
         case 1397: if (item_amount($item[bottle of tequila]) == 0) continue;                 // toy soldier
            rate += item_val($item[bottle of tequila]); break;
         case 2065: if (my_location() != $location[battlefield (frat uniform)] || get_counters("PADL Phone",0,10) != "" ||  // PADL phone
            string_modifier("Outfit") != "Frat Warrior Fatigues" || appearance_rates(my_location())[last_monster()] > 0) continue;
         case 2354: if (to_float(my_stat("hp"))/my_maxhp() < 0.25) fields.pdmg = "-275";      // windchimes
             else if (to_float(my_stat("mp"))/max(1,my_maxmp()) < 0.25) fields.special = "mp 175";
              else fields.dmg = "175";
            if (to_item(it) == $item[PADL phone]) break;
            if (my_location() != $location[battlefield (hippy uniform)] || get_counters("Communications Windchimes",0,10) != "" ||
                string_modifier("Outfit") != "War Hippy Fatigues" || appearance_rates(my_location())[last_monster()] > 0) continue; break;
         case 2453: if (my_fam() != $familiar[penguin goodfella] || my_meat() < fvars["fweight"]*3) continue; break;  // goodfella contract
         case 3101: rate *= 0.5; break;                                                       // rogue swarmer
         case 3195: if (dropspants()) {                                                       // naughty paper shuriken
               fields.special = happened("use 3195") ? "" : "stun 3, once"; fields.dmg = "0";
            } break;
         case 3388: if (get_counters("Zombo's Empty Eye",0,50) != "") continue; break;        // zombo's eye
         case 5048: if (have_effect($effect[coldform]) > 0) continue; break;                  // double-ice: don't align monster to cold
         case 5233: if (monster_phylum(m) == $phylum[construct]) fields.dmg = monster_stat("hp")*6; break; // box of hammers
         case 5445: if (m == $monster[bat in the spats]) fields.dmg = "1000"; break;          // clumsiness bark
         case 5557: if (my_meat() < 50) continue; break;                                      // orange agent
         case 819: case 820: case 821: case 822: case 823: case 824: case 825: case 826: case 827: // ! potions
            fields = get_bang(get_property("lastBangPotion"+it)); break;
         case 2174: case 2175: case 2176: case 2177:                                          // spheres
            fields = get_sphere(get_property("lastStoneSphere"+it)); break;
      }
      fvars["itemamount"] = item_amount(to_item(it));
      d = to_spread(fields.dmg);
      if (isseal) {
         foreach el,amt in d if (d[el] > 0) d[el] = min(1.0,amt);
      } else if (have_equipped($item[v for vivala mask])) d = factor(d,1.5);
      if (m == $monster[mother hellseal] && count(d) > 0) continue;
      advevent temp = to_event("use "+it,d,to_spread(fields.pdmg),fields.special,1);
      switch (my_fam()) {       // arbitrarily assume 30% blocking for these
         case $familiar[o.a.f.]: temp = merge(factor(temp,0.70),factor(
            merge(to_event("",regular(1),to_spread(0),"",0),onhit,factor(oncrit,critchance())),0.30));
            addopt(temp,0.7*rate,0);
            continue;
      }
      addopt(temp,rate,0);
      added[to_item(it)] = false;
   }
  /*
   advevent left;
   if (have_skill($skill[funkslinging])) foreach first in added {       // add funkslinging combinations
      left = get_action(first);
      if (left.stun == 0 && dmg_dealt(left.dmg) == 0) continue;         // speed: only funksling damage or stuns
      foreach second in added {
         if (added[second]) continue;
         if (first == second && (item_amount(first) < 2 || contains_text(factors["item",to_int(first)].special,"once"))) continue;
         opts[count(opts)] = merge(left,get_action(second));
      }
      added[first] = true;
   }
  */
}

// ======== SKILLS ==========        cost: MP of skill * meatpermp

boolean is_spell(skill s) {
   if ($classes[pastamancer,sauceror] contains s.class) return true;
   if (s.to_int() > 27 && s.to_int() < 44) return true;   // hobopolis spells
   return ($skills[noodles of fire,saucemageddon,volcanometeor showeruption] contains s);
}

void build_skillz() {
   if (count(factors["skill"]) == 0 || have_effect($effect[temporary amnesia]) > 0) return;
   spread d;
   string thisid;
   fvars["bonusdb"] = numeric_modifier("DB Combat Damage") + to_int(my_fam() == $familiar[frumious bandersnatch])*
      0.75*(fvars["fweight"]+numeric_modifier("Familiar Weight"));
   fvars["spelldmg"] = numeric_modifier("Spell Damage");
   int burrowgrub_amt() { return (1+to_int(have_effect($effect[yuletide mutations]) > 0)) * min(my_level(),15); }
   string skillsbit = excise(page,"select a skill","Use Skill");
   foreach sk,fields in factors["skill"] {
      thisid = "skill "+sk;
      if (blacklist contains thisid) {      // infinite and threshold blacklisting
	     if (blacklist[thisid] == 0) continue;
		 if (happened(thisid) && happenings[thisid].done + happenings[thisid].queued >= blacklist[thisid]) continue;
      }
      if (mp_cost(to_skill(sk)) > my_stat("mp")) continue;
      if (contains_text(fields.special,"once") && happened(thisid)) continue;
      if (skillsbit == "" ? !have_skill(to_skill(sk)) : !contains_text(skillsbit,"value=\""+sk+"\"")) continue;    // TODO: needs more permissivity to include possible with +MP
      if (m == $monster[x bottles of beer on a golem] && is_spell(to_skill(sk))) continue;  // this dude blocks spells
      fvars["elembonus"] = spell_elem_bonus(excise(fields.dmg," ",""));
      fvars["mpcost"] = mp_cost(to_skill(sk));
      if (have_skill($skill[intrinsic spiciness])) {
	     fvars["spelldmg"] = numeric_modifier("Spell Damage");  // reset since it may have previously been decremented
		 if (to_skill(sk).class != $class[sauceror]) fvars["spelldmg"] -= min(my_level(),10.0);
      }
      rate = 0;
      d = to_spread(0);
      switch (sk) {
        case 55: if (item_amount($item[volcanic ash]) == 0) continue; rate = item_val($item[volcanic ash]); break;  // volcaneometeoric showercanoruptionwhatever
        case 50: case 51: case 52: if (modifier_eval("zone(volcano)") == 0 && have_item($item[unstoppable banjo]) == 0) continue; break;
        case 66: if (fvars["fistskills"] > 1) fields.special = "meat -"+(meatpermp*mp_cost($skill[salamander kata])*have_effect($effect[salamanderenity])/(3*fvars["fistskills"]));
           break;  // flying fire fist costs salamanderenity
        case 70: fields.special = happened($skill[chilled monkey brain]) ? "" : "stun 1"; break;  // monkey only stuns once
        case 7061: fvars["wpnpower"] = get_power(equipped_item($slot[weapon])); break;      // spring raindrop attack
        case 7074: if (my_maxhp() - my_stat("hp") <= 2*burrowgrub_amt() || my_maxmp() - my_stat("mp") <= burrowgrub_amt()) continue; break;  // skip burrowgrub unless none is wasted
        case 7081: fvars["botcharges"] = get_property("bagOTricksCharges").to_int(); break;
        case 7082: if (contains_text(page,"red eye")) {        // point at your opponent (he-boulder rays)
              d = to_spread(((4.5-minmax(have_effect($effect[everything looks red]),0,2))*fvars["fweight"])+" hot");
              if (have_effect($effect[everything looks red]) > 0) fields.special = "once, stats "+(4.5*fvars["fweight"])+"|"+(4.5*fvars["fweight"])+"|"+(4.5*fvars["fweight"]);
           } else if (contains_text(page,"blue eye")) {
              if (have_effect($effect[everything looks blue]) > 0) { d = to_spread((1.5*fvars["fweight"])+" cold"); fields.special = "once"; }
               else fields.special = "stun 3, once";
           } else if (contains_text(page,"yellow eye")) {
              if (have_effect($effect[everything looks yellow]) > 0) d = to_spread(0.75*fvars["fweight"]);
               else d = to_spread((6*monster_stat("hp"))+" hot,cold,spooky,sleaze,stench,none");
			  fields.special = "once";
           } break;
        case 7112: rate = ((have_effect($effect[taste the inferno])-1)/50.0)*item_val($item[nuclear blastball]); break;  // nuclear breath costs a blastball, but should be used
        case 7116: if (m.phylum == $phylum[dude]) fields.special += ", stun 1"; break;
        case 11006: if (!have_equipped($item[trusty])) continue; break;    // throw trusty needs a trusty
        case 11010: if (have_effect($effect[foe-splattered]) > 0) continue; break;   // bifurcating blow
        case 12012: if (!happened("skill 12000")) break;         // plague claws could grant MP after bite
        case 12000: if ($phyla[bug,constellation,elemental,construct,plant,slime] contains m.phylum) break;
           fields.special = "!! zombify"; break;                 // set flag for +MP since all regular MP is ignored
        default: if (contains_text(fields.special,"regular")) {
              if (current_hit_stat() == $stat[moxie] && !($ints[7008,1022,1023,12010] contains sk)) continue;
              switch (sk) {    // dmg formulas too complicated for data file
                case 2005: case 2105: case 2106: case 2107:      // skip shield skills if no shield
                   if (fvars["shieldpower"] == 0) continue; d = merge(to_spread(fields.dmg),regular(1)); break;
                case 11000: if (!have_equipped($item[trusty])) continue;  // axing
                case 1003: d = regular(2); break;                // ts
                case 1005: d = regular(3); break;                // lts
                case 11001: if (!have_equipped($item[trusty])) continue;  // cleave
                case 7096: d = regular(5); break;                // bashing slam smash
                case 7097: d = factor(regular(1),7); break;      // turtle of seven tails = 7 regular attacks
                case 7132: d = (have_equipped($item[right bear arm]) && have_equipped($item[left bear arm]) ?
                   to_spread(monster_hp()*0.5) : regular(1)); break;  // grizzly scene
                case 7135: d = to_spread((get_property("_bearHugs").to_int() < 10 && !m.boss) ? monster_hp()*6 : 25);  // bear hug
                   if (my_class() != $class[zombie master] || ($phyla[bug,constellation,elemental,construct,plant,slime] contains m.phylum)) break;
                   fields.special = "!! zombify"; break;         // set flag for +MP since all regular MP is ignored
                case 1022: d[$element[none]] = max(0.5,0.15*get_power(equipped_item($slot[weapon])))+0.5+ceil(square_root(max(0,numeric_modifier("Weapon Damage"))));
                   foreach el in $elements[] d[el] = ceil(square_root(numeric_modifier(el+" Damage"))); break;   // clobber
                case 1023: if (equipped_item($slot[weapon]) == $item[none]) continue;                            // harpoon!
				   d[$element[none]] = min(800.0,floor(fvars["buffedmus"]/4.0)) + 0.15*get_power(equipped_item($slot[weapon]))+0.5+1.5*max(0,numeric_modifier("Weapon Damage"));
                   foreach el in $elements[] d[el] = 1.5*numeric_modifier(el+" Damage"); break;
                case 12010: d = merge(factor(to_spread(fullness_limit() - my_fullness()),7),regular(1)); break;  // ravenous pounce
                case 12020: d = to_spread((m.boss ? monster_hp()*0.5 : 0));	break;                               // howl of the alpha
                default: d = merge(to_spread(fields.dmg),regular(1));
              }
           }
      }
      if (dmg_dealt(d) == 0) d = to_spread(fields.dmg);
      advevent bander(int which) {
         if (!happened("smusted") && factors["bander",which].special.contains_text("smust"))
            return to_event("",to_spread(0),to_spread(0),"stun 2");
         return to_event("",factors["bander",which]);
      }
      if (m == $monster[mother hellseal] && count(d) > 0 && (sk == 1022 || !contains_text(fields.special,"regular"))) continue;
      advevent temp = to_event(thisid,d,to_spread(fields.pdmg),fields.special,to_int(sk != 5023));  // 5023 is mistletoe (quick action)
      if (contains_text(fields.special,"regular")) temp = merge(temp,onhit);
       else if (isseal) foreach el,amt in temp.dmg if (temp.dmg[el] > 0) temp.dmg[el] = min(1.0,amt);
      switch (my_fam()) {
        // bander skill augmentation
         case $familiar[bandersnatch]: if (factors["bander"] contains sk) temp = merge(temp,bander(sk)); break;
        // OAF and Black cat skill blocks -- convert to regular attack! arbitrarily assume 30%
         case $familiar[o.a.f.]:
         case $familiar[black cat]: temp = merge(factor(temp,0.70),factor(opts[0],0.30));   // either opts[0] contains regular attack at this point,
            addopt(temp,0,0.7*mp_cost(to_skill(sk)));                                       // or you are in Jarlsberg and can't use familiars
            continue;
      }
      addopt(temp,rate,mp_cost(to_skill(sk)));
   }
}

void build_options() {
   vprint("Building options...",9);
   clear(opts);
   fvars["monsterhp"] = monster_stat("hp");
   fvars["monsterattack"] = monster_stat("att");
   fvars["buffedmys"] = my_stat("Mysticality");
   fvars["buffedmus"] = my_stat("Muscle");
   fvars["buffedmox"] = my_stat("Moxie");
   fvars["maxhp"] = my_maxhp();
   fvars["myhp"] = my_stat("hp");
   fvars["mymp"] = my_stat("mp");
  // 1. add regular
   if (!(blacklist contains "attack")) {
      addopt(merge(to_event("attack",regular(1),to_spread(0),"",1),onhit),0,0);
      opts[0] = merge(opts[0],factor(fumble(),fumble_chance()),factor(oncrit,critchance()));         // fumble and crit not factored by hitchance
      opts[0] = merge(opts[0],to_event("",to_spread(0.075*get_power(equipped_item($slot[weapon])),   // glancing blows
         1.0-hitchance("attack")-fumble_chance()),to_spread(0),""));
   }	  
  // TODO: something for 5/day chefstaffs?
  // 2. get jiggy with it
   if (item_type(equipped_item($slot[weapon])) == "chefstaff" && contains_text(page,"chefstaffform") &&
       !happened("jiggle") && factors["chef"] contains to_int(equipped_item($slot[weapon])) && !(blacklist contains "jiggle")) {
      if (isseal) factors["chef",to_int(equipped_item($slot[weapon]))].dmg = "1";
      addopt(to_event("jiggle",factors["chef",to_int(equipped_item($slot[weapon]))],1),0,0);
   }
  // 3. add items
   build_items();
  // 4. add skillz, yo
   build_skillz();
   sort opts by -to_profit(value);
   sort opts by kill_rounds(value.dmg)*-max(1,value.meat);
   vprint("Options built! ("+count(opts)+" actions)",9);
}

// retrieve specific or best-suited actions from opts

advevent stasis_action() {  // returns most profitable lowest-damage action
   boolean ignoredelevel = (smack.id != '' && kill_rounds(smack.dmg) == 1);
   sort opts by -to_profit(value,ignoredelevel);
   sort opts by -min(kill_rounds(value),max(0,maxround - round - 5));
   foreach i,opt in opts {  // skip multistuns and non-multi-usable items
      if (opt.stun > 1 || (contains_text(opt.id,"use ") && !to_item(excise(opt.id,"use ","")).reusable)) continue;
      vprint("Stasis action chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(opt.profit)+")",8);
      plink = opt;
      return opt;
   }
   plink = new advevent;
   return new advevent;
}
advevent attack_action() {  // returns most profitable killing action
   if (!happened($item[gnomitronic hyperspatial demodulizer]) && monster_stat("hp") <= dmg_dealt(get_action("use 2848").dmg))
      return get_action("use 2848");
   float drnd = max(1.0,die_rounds()-1.0);   // a little extra pessimistic
   sort opts by -dmg_dealt(value.dmg);
   sort opts by -to_profit(value);
   sort opts by kill_rounds(value.dmg)*-(min(value.profit,-1));
   foreach i,opt in opts {
      if (kill_rounds(opt.dmg) > min(maxround - round - 1,drnd)) continue;   // reduce RNG risk for stasisy actions
      if (opt.stun < 1 && opt.profit < -runaway_cost()) continue;  // don't choose actions worse than fleeing
      vprint("Attack action chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(opt.profit)+")",8);
      smack = opt;
      return opt;
   }
   vprint("No valid attacks (Best attack '"+opts[0].id+"' not good enough).",8);
   smack = new advevent;
   return new advevent;
}
advevent stun_action(boolean foritem) {    // returns cheapest stunned rounds, at least one (accounting for funking items)
   if (smack.id == "") attack_action();
   sort opts by -(to_profit(value)-(value.stun == 0 ? 1000 : 0)+              // cheatily discount non-stunners
      meatperhp*m_dpr(-adj.att,0)*min(kill_rounds(smack.dmg)+count(custom),
        value.stun - 1 + to_int(foritem && have_skill($skill[funkslinging]) && contains_text(value.id,"use "))));
   foreach i,opt in opts {
      if (opt.stun < 1-to_int(foritem && have_skill($skill[funkslinging]) && contains_text(opt.id,"use "))) continue;
      vprint("Stun action chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(opt.profit)+")",8);
      buytime = opt;
      return opt;
   }
   buytime = new advevent;
   return new advevent;
}


// ========= QUEUEING ========== <-- sexiest word ever?  http://xkcd.com/853/

advevent[int] queue;

// wipe queue and reset adjustments back to pre-queue state
// TODO: account for current multistuns in effect
void reset_queue() {
   foreach n,a in queue round -= min(a.rounds,round);
   queue.clear();
   foreach s,rec in happenings rec.queued = 0;
   map_to_file(happenings,"happenings_"+replace_string(my_name()," ","_")+".txt");
   adj = new advevent;
   basecache.note = "0";
   m_cache.note = "0";
   if (!havemanuel) {                           // stat adjustments
      if (m.raw_attack == -1) adj.att = to_int(vars["unknown_ml"]);
      if (m.raw_defense == -1) adj.def = to_int(vars["unknown_ml"])*0.9;
      if (m.raw_hp == -1) adj.dmg[$element[none]] = to_int(vars["unknown_ml"]);
      if (!m.boss) adj.dmg[$element[none]] += min(5,monster_hp(m)*0.05);     // be pessimistic about monster HP variance
   }
}

stat which_gays(string aid) {        // determines which gays a given action will attract
   if (index_of(aid,"use ") == 0  || contains_text(aid,"pickpocket")) return $stat[moxie]; // moxious gays
   if (index_of(aid,"skill ") == 0)
      return to_skill(to_int(excise(aid,"skill ",""))).class.primestat;  // classy gays
   return $stat[none];     // straight?
}

// TODO: reject excess haiku katana skills
// adds action to queue, adjusts script state; returns false if unable to enqueue the action
boolean enqueue(advevent a) {     // handle inserts/auto-funk
   if (a.id == "") return vprint("Unable to enqueue empty action.",-8);  // allows if(enqueue())
   if (round + a.rounds > maxround + 3) return vprint("Can't enqueue '"+a.id+"': combat too long.",-8);  // allow to enqueue 3 rounds beyond combat limit
   if (my_stat("mp")+a.mp < 0) return vprint("Unable to enqueue '"+a.id+"': insufficient MP.",-7);  // everybody to the limit
  // attract gays
   boolean have_gays() { foreach i,ev in queue if (which_gays(ev.id) != $stat[none]) return true; return false; }
   if (have_equipped($item[juju mojo mask]) && have_effect($effect[gaze of the volcano god]) + have_effect($effect[gaze of the lightning god]) +
       have_effect($effect[gaze of the trickster god]) == 0 && !have_gays() && which_gays(a.id) != my_primestat())
      enqueue(get_action(to_skill(1000*(my_class().to_int()+1))));
  // precede DB deleveling skills with Mistletoe if available
   boolean contains_dbskill(string id) {
      matcher fred = create_matcher("skill (\\d+)",id);
      while (fred.find()) if (to_skill(to_int(fred.group(1))).class == $class[disco bandit]) return true; return false;
   }
   if (get_action($skill[stealth mistletoe]).id != "" && a.att < 0 && contains_text(a.id,"skill ") &&
       contains_dbskill(a.id) && stasis_action().id != a.id && my_stat("mp") + a.mp >= mp_cost($skill[stealth mistletoe]))
      enqueue(get_action($skill[stealth mistletoe]));  // doesn't take a round, w00th!
  // Auto-funk!
   boolean funk;
   matcher bob = create_matcher("use (\\d+)\\Z",a.id);
   if (have_skill($skill[funkslinging]) && bob.find() && count(queue) > 0) {
      bob.reset(queue[count(queue)-1].id);
      if (bob.find() && (queue[count(queue)-1].id != a.id || (item_amount(to_item(to_int(bob.group(1)))) > 1 &&
	      m_dpr(0,-adj.stun)*meatperhp > to_float(vars["BatMan_profitforstasis"]))))
         funk = vprint("Auto-funk: merging '"+queue[count(queue)-1].id+"' and '"+a.id+"'.",4);
   }
   advevent newa = funk ? merge(queue[count(queue)-1],a) : merge(a,new advevent);
   if (funk) remove queue[count(queue)-1];
  // adjust combat environment
   advevent temp = funk ? merge(a,new advevent) : oneround(a);
   temp.dmg = to_spread(dmg_dealt(temp.dmg),-1);         // monster hp is stored in dmg[none]
   temp.pdmg = to_spread(dmg_taken(temp.pdmg));          // player -hp is stored in pdmg[none]
   if (a.endscombat) round = maxround + 1;               // if endscombat, consider us as at the end of combat
    else if (!funk) {
       round += temp.rounds;                             // a round or several go by
       adj.stun -= minmax(temp.rounds,0,adj.stun);
    }
   adj = merge(adj,temp);
  // queue it!
   set_happened(newa.id,true);                           // TODO: queue associated happenings
   build_options();
   queue[count(queue)] = newa;
   return true;
}
boolean enqueue(skill s) { return enqueue(get_action(s)); }
boolean enqueue(item i) { return enqueue(get_action(i)); }

// =========== INITIALISE ============

void set_monster(monster elmo) {  // should be called once per BB instance; initializes BB for a specific monster
   m = elmo;
  // monster plurality
   int[monster] pluralm;
   load_current_map("pluralMonsters",pluralm);
   howmanyfoes = (pluralm contains m) ? pluralm[m] : 1;
   pluralm.clear();
   if (m == $monster[none] && to_int(vars["unknown_ml"]) == 0)
      vprint("You would like to handle this unknown monster yourself. (unknown_ml is 0)",0);
   maxround = 30;
  // values for formulas
   fvars["myhp"] = my_hp();
   fvars["monsterhp"] = monster_hp();
   fvars["famgear"] = to_int(equipped_item($slot[familiar]) == familiar_equipment(my_familiar()));
   fvars["spelldmgpercent"] = 1.0 + (numeric_modifier("Spell Damage Percent")/100.0);
   fvars["yuletide"] = to_int(have_effect($effect[yuletide mutations]) > 0);
   fvars["fweight"] = familiar_weight(my_familiar()) + numeric_modifier("Familiar Weight");
   if (to_int(get_property("fistSkillsKnown")) > 0) fvars["fistskills"] = to_int(get_property("fistSkillsKnown"));
   if (have_skill($skill[intimidating bellow])) fvars["bellows"] = have_skill($skill[louder bellows]) ? 2 : 1;
   if (have_skill($skill[kneebutt])) fvars["pantspower"] = (have_skill($skill[tao of the terrapin])) ?
      get_power(equipped_item($slot[pants]))*2 : get_power(equipped_item($slot[pants]));
   if (have_skill($skill[headbutt])) fvars["helmetpower"] = (have_skill($skill[tao of the terrapin])) ?
      get_power(equipped_item($slot[hat]))*2 : get_power(equipped_item($slot[hat]));
   if (have_skill($skill[shieldbutt])) fvars["shieldpower"] = (item_type(equipped_item($slot[offhand])) == "shield") ? get_power(equipped_item($slot[offhand])) : 0;
   if (have_equipped($item[staff of queso escusado])) fvars["stinkycheese"] = to_int(get_property("_stinkyCheeseCount"));
   if (have_equipped($item[mer-kin hookspear])) fvars["monstermeat"] = to_float(my_path() == "Way of the Surprising Fist" ? max(meat_drop(m),12) : meat_drop(m));
  // initialize effects/gear
   fxngear();
  // monster resistance
   if (happened("use 5048")) mres = get_resistance($element[cold]);
    else mres = get_resistance(m.defense_element);
   switch (m) {
      case $monster[BRICKO vacuum cleaner]: foreach el in $elements[] mres[el] = 0.1; mres[$element[none]] = 0.1; break;
	  case $monster[peanut]: foreach el in $elements[] mres[el] = 0.25; break;
      case $monster[gorgolok, the infernal seal (volcanic cave)]:
      case $monster[lumpy, the sinister sauceblob (volcanic cave)]:
      case $monster[somerset lopez, dread mariachi (volcanic cave)]:        // <-- confirm this?? wasn't in the wiki
      case $monster[spirit of new wave (volcanic cave)]:
      case $monster[stella, the turtle poacher (volcanic cave)]:
	  case $monster[trophyfish]: foreach el in $elements[] mres[el] = 0.25;
      case $monster[booty crab]:
      case $monster[war frat kegrider]:
      case $monster[war frat mobile grill unit]:
      case $monster[war hippy dread squad]: mres[$element[none]] = 0.25; break;
	  case $monster[oil tycoon]: foreach el in $elements[hot, stench] mres[el] = 0.25; mres[$element[cold]] = -0.5; break;
      case $monster[gorgolok, the demonic hellseal]:
      case $monster[stella, the demonic turtle poacher]:
      case $monster[spaghetti demon]:
      case $monster[lumpy, the demonic sauceblob]:
      case $monster[somerset lopez, demon mariachi]:
      case $monster[demon of new wave]: foreach el in $elements[] mres[el] = 0.4; mres[$element[none]] = 0.4; break;
      case $monster[oil baron]: foreach el in $elements[] mres[el] = 0.5;  mres[$element[cold]] = 0; break;
      case $monster[Crys-Rock]:
      case $monster[sexy sorority werewolf]:
      case $monster[queen bee]:
      case $monster[beebee king]:
      case $monster[bee thoven]: foreach el in $elements[] mres[el] = 0.5;
      case $monster[vanya's creature]:
      case $monster[gargantuchicken]:
      case $monster[heavy kegtank]:
      case $monster[mobile armored sweat lodge]: mres[$element[none]] = 0.5; break;
      case $monster[oil cartel]: foreach el in $elements[] mres[el] = 0.75;  mres[$element[cold]] = 0.5; break;
      case $monster[the whole kingdom]: maxround = 11; remove factors["item"];
	  case $monster[don crimbo]:
      case $monster[cyrus the virus]:
      case $monster[hulking construct]:
      case $monster[the landscaper]:
      case $monster[frosty]: foreach el in $elements[] mres[el] = 1;
      case $monster[ancient ghost]:
      case $monster[contemplative ghost]:
      case $monster[lovesick ghost]:
      case $monster[battlie knight ghost]:
      case $monster[claybender sorcerer ghost]:
      case $monster[dusken raider ghost]:
      case $monster[space tourist explorer ghost]:
      case $monster[whatsian commando ghost]:
      case $monster[snow queen]:
      case $monster[chalkdust wraith]:
      case $monster[ancient protector spirit]:
      case $monster[Protector Spectre]:
      case $monster[sexy sorority ghost]:
      case $monster[ghost miner]: mres[$element[none]] = 1; break;
      case $monster[chester]:
      case $monster[mother slime]: remove factors["item"];                     // remove items if impossible
         vprint("You can't use items in this combat.",-6); break;              // note: mother's resistance handled in act()
      case $monster[your shadow]: foreach te,it,rd in factors                  // delete all damage, then add healing as damage
	     factors[te,it].dmg = (rd.pdmg.length() > 1 && substring(rd.pdmg,0,1) == "-") ? substring(rd.pdmg,1) : "0"; break;
     // TODO: reanimated skeletons resist everything except pottery
     // detect seals, add catchall resistance in case you don't have a club equipped
      case $monster[broodling seal]:
      case $monster[centurion of sparky]:
      case $monster[hermetic seal]:
      case $monster[spawn of wally]:
      case $monster[heat seal]:
      case $monster[navy seal]:
      case $monster[servant of grodstank]:
      case $monster[shadow of black bubbles]:
      case $monster[watertight seal]:
      case $monster[wet seal]: isseal = true; if (item_type(equipped_item($slot[weapon])) == "club") break;
      case $monster[zombo]:
      case $monster[sexy sorority skeleton]:
      case $monster[spooky hobo]: foreach el in $elements[] mres[el] = 1; break;
     // long combats
      case $monster[ghost of fernswarthy grandfather]: mres[$element[none]] = 1; maxround = 50; break;
      case $monster[x stone golem]: mres[$element[none]] = 0.5;
      case $monster[beast with x ears]:
      case $monster[beast with x eyes]:
      case $monster[x-headed hydra]:
      case $monster[x bottles of beer on a golem]:
      case $monster[x-dimensional horror]:

      case $monster[naughty sorceress]:
      case $monster[naughty sorceress (2)]:
      case $monster[the man]:
      case $monster[big wisniewski]: maxround = 50; break;
     // unchanging special moves/conditions
      case $monster[blackberry bush]:
      case $monster[cactuary]: if (weapon_type(equipped_item($slot[weapon])) != $stat[moxie]) onhit.pdmg[$element[none]] = 5.3; break;
   }
  // player resistance
   pres = get_resistance($element[none]);
   foreach el in $elements[] {
      if (eform != $element[none]) { pres = get_resistance(eform); break; }
      pres[el] = elemental_resistance(el)/100.0;
   }
   beatenup = beatenup_cost() + runaway_cost();
  // determine whether or not the poison of this monster is dangerous and should be removed
  // a poison is dangerous if a) the monster will be able to hit you, or 2) attack_action won't be able to win
   dangerpoison = m.poison;
   if (!($effects[none,toad in the hole] contains dangerpoison)) {
      cli_execute("whatif up "+dangerpoison+"; quiet");
      if (m_hit_chance() < 0.07 && kill_rounds(attack_action()) < maxround - round) dangerpoison = $effect[none];
   }
   cli_execute("whatif quiet");                     // reset spec in case it was used elsewhere
   reset_queue();
   vprint_html("ATT: <b>"+rnum(monster_stat("att"))+"</b> ("+rnum(m_hit_chance()*100.0)+"% &times; "+to_html(m_regular())+
      ", death in "+die_rounds()+")<br>DEF: <b>"+rnum(monster_stat("def"))+"</b> ("+rnum(hitchance("attack")*100.0)+
      "% &times; "+to_html(regular(1))+", win in "+kill_rounds(to_event("attack",factor(regular(1),hitchance("attack")),
      to_spread(0),""))+")<br>HP: <b>"+rnum(monster_stat("hp"))+"</b>, Value: <b><span style='color:green'>"+
      rnum(monstervalue())+" "+entity_decode("&mu;")+"</span></b>, RES: "+to_html(mres),5);
}


// ========= ACTION FILTER ==========

string act(string action) {
   page = action;
   havemanuel = contains_text(page,"var monsterstats");
  // initialize monster to last_monster() if not initialized manually
   if (m == $monster[none]) set_monster(last_monster());
    else reset_queue();
  // set combat round and record happenings
   round = (contains_text(action,"<!--WINWINWIN-->") ||
            (get_property("serverAddsCustomCombat") == "true" && !contains_text(action,"(show old combat form)")) ||
            !create_matcher("action=\"?fight\\.php",page).find()) ? 0 : to_int(excise(action,"var onturn = ",";"));
   matcher roundmatch = create_matcher("\\<!-- macroaction: (.+?)(?:, (\\d+))? -->",action);
   boolean skipped;
   while (roundmatch.find()) {
      if (skipped && round > 0) round += 1; else skipped = true;
      set_happened(roundmatch.group(1));
      if (roundmatch.group_count() > 1 && roundmatch.group(2).to_int() > 0) set_happened("use "+roundmatch.group(2));
   }
   vprint("Parsed round number: "+round,8);
   if (round == 0) round = maxround + 1;
  // detections
   string lastaction = (contains_text(action,"bgcolor")) ? substring(action,last_index_of(action,"bgcolor")) : action;
   switch (my_fam()) {
      case $familiar[hobo monkey]: if (!happened("famspent") && contains_text(action,"your shoulder, and hands you some Meat")) set_happened("famspent"); break;
      case $familiar[gluttonous green ghost]:
      case $familiar[slimeling]: if (happened("famspent")) break; if (contains_text(lastaction,"/"+my_fam().image) || contains_text(lastaction,"You get the jump") ||
         contains_text(lastaction,"You quickly conjure a saucy salve") || contains_text(lastaction,"twiddle your thumbs")) break;
            print("Your "+my_fam()+" is running on E.","olive"); set_happened("famspent"); break;
      case $familiar[spirit hobo]: if (!happened("famspent") && (contains_text(action,"Oh, Helvetica,") || contains_text(action,"millennium hands and shrimp."))) {
         print("Your hobo is now sober.  Sober hobo sober hobo.","olive");
         set_happened("famspent"); } break;
      case $familiar[bandersnatch]: if (contains_text(action,"cloud of smust")) set_happened("smusted"); break;
      case $familiar[mini-hipster]: if (contains_text(action,"regular ol' creepy moustache") || contains_text(action,"ironic piggy-back ride") ||
         contains_text(action,"indie comic book")) set_happened("hipster_stats"); break;
   }
   foreach doodad,n in extract_items(contains_text(action,"Found in this fight:") ? excise(action,"","Found in this fight:") : action) {
      stolen[doodad] += n;
      if (contains_text(action,"grab something") || contains_text(action,"You manage to wrest") ||
         (my_class() == $class[disco bandit] && contains_text(action,"knocked loose some treasure."))) {
         vprint("You snatched a "+doodad+" ("+rnum(item_val(doodad))+entity_decode("&mu;")+")!","green",5);
         should_pp = vprint("Revised monster value: "+rnum(monstervalue()),"green",-4);
         set_happened("stolen");
      } else vprint("Look! You found "+n+" "+doodad+" ("+rnum(n*item_val(doodad))+entity_decode("&mu;")+")!","green",5);
   }
   if (contains_text(action,"CRITICAL")) set_happened("crit");
   if (have_equipped($item[operation patriot shield]) && happened($skill[throw shield]) && happened("crit")) set_happened("shieldcrit");
   if (have_equipped($item[bag o tricks])) switch {
      case (happened($skill[open the bag])): set_property("bagOTricksCharges","0"); break;
      case (contains_text(action,"Bag o' Tricks suddenly feels")): set_property("bagOTricksCharges","1"); break;
      case (contains_text(action,"Bag o' Tricks begins")): set_property("bagOTricksCharges","2"); break;
      case (contains_text(action,"Bag o' Tricks begins squirming")):
      case (contains_text(action,"Bag o' Tricks continues")): set_property("bagOTricksCharges","3"); break;
   }
   if (have_equipped($item[double-ice cap]) && contains_text(page,"solid, suffering")) set_happened("icecapstun");
   switch (m) {
      case $monster[batwinged gremlin]:
      case $monster[erudite gremlin]:
      case $monster[spider gremlin]:
      case $monster[vegetable gremlin]: if (contains_text(page,"does a bombing run") ||        // gremlin lacks tool
          contains_text(page,"picks a beet") || contains_text(page,"picks a radish") ||
          contains_text(page,"bites you in the fibula") || contains_text(page,"make an automatic eyeball"))
         set_happened("lackstool"); break;
      case $monster[hellseal pup]: if (contains_text(action,"high-pitched screeching wail")) set_happened("sealwail"); break;
      case $monster[mother slime]: if (mres[$element[none]] == 0 && contains_text(action,"ground trembles as Mother Slime shudders")) set_happened("mother_physical");
         if (happened("mother_physical")) mres[$element[none]] = 1.0;                          // mother's resistance is rebuilt every time
        if (mres[$element[sleaze]] == 0 && contains_text(action,"Veins of purple shoot")) set_happened("mother_sleaze");
         if (happened("mother_sleaze")) mres[$element[sleaze]] = 1.0;                          // based on happenings
        if (mres[$element[cold]] == 0 && contains_text(action," a bluish tinge")) set_happened("mother_cold");
         if (happened("mother_cold")) mres[$element[cold]] = 1.0;
        if (mres[$element[spooky]] == 0 && contains_text(action,"skin becomes ashy and gray")) set_happened("mother_spooky");
         if (happened("mother_spooky")) mres[$element[spooky]] = 1.0;
        if (mres[$element[hot]] == 0 && contains_text(action,"becomes decidedly more reddish")) set_happened("mother_hot");
         if (happened("mother_hot")) mres[$element[hot]] = 1.0;
        if (mres[$element[stench]] == 0 && contains_text(action,"looks greener than she did a minute ago")) set_happened("mother_stench");
         if (happened("mother_stench")) mres[$element[stench]] = 1.0;
   }
   if (contains_text(page,"BatBrain abort: ")) vprint("BatBrain abort detected: "+excise(page,"BatBrain abort: ","."),8);
   if (finished()) return action;  // everything that follows is pointless if combat is over
   build_options();
  // reactions
   if (my_location() == $location[slime tube] && contains_text(action,"a massive loogie that sticks") &&
       equipped_item($slot[weapon]) == $item[none]) vprint("Your rusty weapon has been slimed!  Finish combat by yourself.",0);
   if (dangerpoison != $effect[none] && have_effect(dangerpoison) > 0) {
      vprint("You're dangerously poisoned!  Will try to remove if possible.","olive",2);
      if (have_effect($effect[Duct Out of Water]) > 0) return act(use_skill($skill[spew poison]));
      if (item_amount($item[anti-anti-antidote]) > 0) return act(throw_item($item[anti-anti-antidote]));
   }
   switch (m) {
      case $monster[batwinged gremlin]:                                    // tool-revealing gremlins
      case $monster[erudite gremlin]:
      case $monster[spider gremlin]:
      case $monster[vegetable gremlin]: if (item_amount($item[molybdenum magnet]) > 0 &&
             !happened("lackstool") && contains_text(lastaction,"whips") &&
             (contains_text(lastaction,"a hammer") || contains_text(lastaction,"a crescent wrench") ||
              contains_text(lastaction,"pliers") || contains_text(lastaction,"a screwdriver")))
         return act(throw_item($item[molybdenum magnet])); break;
      case $monster[7-Foot Dwarf Replicant]:                               // megalopolis discs
      case $monster[Bangyomaman Warrior]:
      case $monster["Handyman" Jay Android]:
      case $monster[Liquid Metal Robot]:
      case $monster[Space Marine]: if (have_equipped($item[ruby rod]) &&
             (contains_text(action,"A mechanical hand emerges") || contains_text(action,"liquid nitrogen") || contains_text(action,"freaky alien thing") ||
             contains_text(action,"vile-smelling, milky-white") || contains_text(action,"spinning, whirring, vibrating, tubular")))
         return act(attack()); break;
      case $monster[french guard turtle]: if (have_equipped($item[fouet de tortue-dressage]) &&   // un-brainwash turtles
             my_stat("mp") >= 5*mp_cost($skill[apprivoisez la tortue]))
         return act(visit_url("fight.php?action=macro&macrotext=skill 7083; repeat")); break;
      case $monster[breakdancing raver]: if (!have_skill($skill[break it on down]) && have_skill($skill[gothy handwave]) &&  // learn dance moves
             !happened($skill[gothy handwave]) && contains_text(action,"he raver drops ") && my_stat("mp") > 0)
         return act(use_skill($skill[gothy handwave])); break;
      case $monster[pop-and-lock raver]: if (!have_skill($skill[pop and lock it]) && have_skill($skill[gothy handwave]) &&
             !happened($skill[gothy handwave]) && contains_text(action,"spastic and jerky.") && my_stat("mp") > 0)
         return act(use_skill($skill[gothy handwave])); break;
      case $monster[running man]: if (!have_skill($skill[run like the wind]) && have_skill($skill[gothy handwave]) &&
             !happened($skill[gothy handwave]) && contains_text(action,"The raver turns ") && my_stat("mp") > 0)
         return act(use_skill($skill[gothy handwave])); break;
      case $monster[somerset lopez, demon mariachi]: if (have_effect($effect[earworm]) > 0)  // sing away earworms
         return act(use_skill($skill[sing])); break;
      case $monster[the thorax]: if (contains_text(lastaction,"draws back his big fist") && item_amount($item[clumsiness bark]) > 0)
         return act(throw_item($item[clumsiness bark])); break;
   }
   if (my_fam() == $familiar[he-boulder] && have_effect($effect[everything looks yellow]) == 0 && !intheclear() &&
       contains_text(action," yellow eye") && contains_text(to_lower_case(vars["ftf_yellow"]),to_lower_case(m.to_string())))
      return act(use_skill($skill[point at your opponent]));
   return action;
}

// =============== MACROFICATION =================

string batround_insert;   // calling scripts may insert additional responses to batround, formatted "commands; "

// macro version of the above responses section in act()
string batround() {
   buffer res;
   res.append("scrollwhendone; sub batround; ");
   if (dangerpoison != $effect[none]) res.append("if haseffect "+to_int(dangerpoison)+" && hasskill 7107; skill 7107; endif; "+
      "if haseffect "+to_int(dangerpoison)+" && hascombatitem 829; use 829; endif; "+
      "if haseffect "+to_int(dangerpoison)+"; abort \"BatBrain abort: poisoned.\"; endif; ");
   if (my_location() == $location[slime tube]) res.append("if match \"a massive loogie\"; abort \"BatBrain abort: loogie.\"; endif; ");
   switch (m) {
      case $monster[batwinged gremlin]:                                    // tool-revealing gremlins
      case $monster[erudite gremlin]:
      case $monster[spider gremlin]:
      case $monster[vegetable gremlin]: if (item_amount($item[molybdenum magnet]) > 0)
         res.append("if match whips && (match \"a hammer\" || match \"a crescent wrench\" || "+
                    "match pliers || match \"a screwdriver\"); use 2497; endif; "); break;
        case $monster[7-Foot Dwarf Replicant]:                             // megalopolis discs
      case $monster[Bangyomaman Warrior]:
      case $monster["Handyman" Jay Android]:
      case $monster[Liquid Metal Robot]:
      case $monster[Space Marine]: if (have_equipped($item[ruby rod]))
         res.append("if match \"A mechanical hand emerges\" || match \"liquid nitrogen\" || match \"freaky alien thing\" || "+
                "match \"vile-smelling, milky-white\" || match \"spinning, whirring, vibrating, tubular\"; attack; endif; "); break;
      case $monster[breakdancing raver]: if (!have_skill($skill[break it on down]) && have_skill($skill[gothy handwave]) &&  // learn dance moves
             !happened($skill[gothy handwave]))
         res.append("if match \"he raver drops \"; skill 49; endif; "); break;
      case $monster[pop-and-lock raver]: if (!have_skill($skill[pop and lock it]) && have_skill($skill[gothy handwave]) &&
             !happened($skill[gothy handwave]))
         res.append("if match \"spastic and jerky.\"; skill 49; endif; "); break;
      case $monster[running man]: if (!have_skill($skill[run like the wind]) && have_skill($skill[gothy handwave]) &&
             !happened($skill[gothy handwave]))
         res.append("if match \"The raver turns \"; skill 49; endif; "); break;
      case $monster[somerset lopez, demon mariachi]: res.append("if haseffect 721; skill 6025; endif; "); break;   // sing away earworms
      case $monster[the thorax]: if (item_amount($item[clumsiness bark]) > 0)                                      // react to fist-drawing
         res.append("if match \"draws back his big fist\"; use 5445; endif; "); break;
   }
   switch (my_fam()) {
      case $familiar[he-boulder]: if (have_effect($effect[everything looks yellow]) > 0 || !contains_text(to_lower_case(vars["ftf_yellow"]),to_lower_case(m.to_string()))) break;
         if (count(custom) > 0 && intheclear()) break;
         res.append("if !haseffect 790 && match \" yellow eye\"; skill 7082; endif; "); break;
   }
   res.append(batround_insert);
   return res+"endsub; ";
}
string get_macro(string rep) {    // returns the queue in macro form; allows repeat conditions to be added only to the last item
   if (count(queue) == 0 && !vprint("Macro called on empty queue!",-2)) return "";
   buffer r;
   string br = batround();
   r.append(br.length() > 38 ? br : "scrollwhendone; ");
   string temp;
   foreach i,o in queue {
      temp = o.id;
      if (br.length() > 38) {
         temp.replace_string("; ","; call batround; ");
         temp += "; call batround; ";
      } else temp += "; ";
      if (m == $monster[protagonist] && contains_text(o.id,"skill "))
         r.append("if haseffect 297; abort \"Amnesiacs can't do... whatever you were about to do next.\"; endif; ");
      if (i == count(queue)-1 && o.id == "runaway") rep = "";
      if (o.id == "pickpocket" && my_class() == $class[disco bandit] && have_equipped($item[bling of the new wave])) {
         r.append(o.id+"; repeat !match \"You acquire an item\" && !times 2; ");
      } else if (rep != "z" && i == count(queue)-1) {   // repeat conditions
         r.append("sub finito; "+temp+"endsub; call finito; repeat ");
         matcher bob = create_matcher("(skill|use) (\\d+)",o.id);
         boolean popped;
         while (bob.find()) {
            if (popped) r.append(" && "); else popped = true;
            r.append(bob.group(1) == "use" ? "hascombatitem " : "hasskill ");
            r.append(bob.group(2));
         }
         if (rep.length() > 0) r.append(popped ? " && ("+rep+")" : rep);
      } else r.append(temp);
   }
//   if (m_hit_chance() > 0) temp += "if hpbelow "+ceil(max(m_regular()+1,to_float(get_property("autoAbortThreshold"))*my_maxhp()))+
//      "; abort \"BatBrain abort: Danger, Will Robinson\"; endif; ";
   vprint("Constructed macro: "+r,8);
   return to_string(r);
}
string get_macro() { return get_macro("z"); }   // magic letter means no repeat

string macro(string mac) {                // basic wrapper, adds action filter to final page
   return mac == "" ? page : act(visit_url("fight.php?action=macro&macrotext="+url_encode(mac),true,true));
}
string macro() { if (count(queue) > 0) return macro(get_macro()); return page; }
string macro(advevent a, string rep) { enqueue(a); if (count(queue) > 0) return macro(get_macro(rep)); return ""; }
string macro(advevent a) { return macro(a,"z"); }
string macro(skill s, string rep) { return macro(get_action(s),rep); }
string macro(skill s) { return macro(get_action(s),"z"); }
string macro(item i, string rep) { return macro(get_action(i),rep); }
string macro(item i) { return macro(get_action(i),"z"); }

setvar("BatMan_profitforstasis",15.0);       // profit required to enter stasis
setvar("BatMan_baseSubstatValue",5.0);       // value of a single substat point (mainstat 2*n, attack stat 1.5*n, defstat 1.5*n -- these stack)
// setvar("BatMan_pessimism",0.5);              // pessimism range -1.0 - 1.0 (1.0 totally pessimistic, 0 exact averages, -1.0 totally optimistic)
string BBver = check_version("BatBrain","batbrain","1.36",6445);
