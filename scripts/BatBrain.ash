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
boolean isseal, nomultistun, nomiss, nohit, nospells;  // monster attributes not included in proxy records
int round, howmanyfoes, damagecap, maxround;
float noitems, noskills, nostagger, capexp, mvalcache;
effect dangerpoison;             // threatening poison effect of this monster
boolean should_putty, should_olfact, should_pp;
boolean havemanuel, functops;
int[item] stolen;                // all the items you grab during this combat
string page;                     // most recent page load
float beatenup;                  // cost of getting beaten up
int turncount = my_turncount();  // cache this for happenings
boolean finished() {             // returns true if the combat is over
   return (round > maxround);
}
float[string] fvars;             // variables for formulas
string eventscreated;            // list cache for prettier debug output
void cleareventscreated() {
   if (to_int(vars["verbosity"]) > 8 && eventscreated != "") print("Events created: "+eventscreated);
   eventscreated = "";
}

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
   string custom;          // this action should not be used in normal automation -- value is type of custom action (banish, attract, yellow, copy, runaway, etc)
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
spread mres, pres;         // monster/player resistance

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
      case "Moxie": return max(1,numeric_modifier("_spec","Buffed "+which));
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
   string autofunk = (have_skill($skill[ambidextrous funkslinging]) && is_integer(excise(fir.id,"use ","")) &&
                      is_integer(excise(sec.id,"use ",""))) ? fir.id+","+excise(sec.id,"use ","") : "";
   if (fir.rounds == 0 ^ sec.rounds == 0) res.id = (fir.rounds == 0 ? sec.id : fir.id);
     else res.id = (autofunk != "" ? autofunk : fir.id+(sec.id != "" && fir.id != "" ? "; " : "")+sec.id);
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
   res.custom = fir.custom+(sec.custom != "" && fir.custom != "" ? "; " : "")+sec.custom;
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
   if (to_int(vars["verbosity"]) > 8) eventscreated = list_add(eventscreated,id == "" ? "(blank)" : id);
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
   bittles = create_matcher("([a-z!]+?)(?: (.+?))?(?:$|, )",special);
   while (bittles.find()) switch (bittles.group(1)) {
      case "att": res.att = aoe*eval(bittles.group(2),fvars); break;
      case "def": res.def = aoe*eval(bittles.group(2),fvars); break;
      case "stun": if (nostagger == 1) break; res.stun = (bittles.group(2) == "" ? 1 : eval(bittles.group(2),fvars));
         if (nomultistun && res.stun > 1) res.stun = 0; else res.stun *= (1.0 - nostagger); break;
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
      case "custom": res.custom = (bittles.group(2) == "" ? "x" : bittles.group(2)); break;
      case "endscombat": res.endscombat = true; break;
      case "quick": res.rounds = 0; break;
      case "!!": res.note = bittles.group(2); break;
      case "noitems": noitems = 1.0; break;
      case "noskills": noskills = 1.0; break;
   }
   if (!res.endscombat && fvars["dmg"] >= monster_stat("hp")) res.endscombat = true;
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
   if (((blacklist contains id) && blacklist[id] < 1) || amt < 1) return;
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
   if (my_location() == $location[mer-kin colosseum])          // don't use Mer-kin weapon skills when you need to reserve them for autoresponses
      for i from 7085 upto 7093 blacklist["skill "+i] = 0;  
   temp_blacklist_inc("skill 7074",to_int(get_property("burrowgrubSummonsRemaining")));  // cap burrowgrub at remaining uses
   if (have_equipped($item[stress ball])) temp_blacklist_inc("skill 7113",5-to_int(get_property("_stressBallSqueezes")));  // cap stress ball at remaining uses
   // TODO: expand this, more situational blockages
}
build_blacklist();

//=============== RESISTANCE / VULNERABILITY ===================

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
   float softcapped(float orig) {
      if (damagecap < 1 || orig <= damagecap) return orig;
      return damagecap + floor((orig - damagecap)**capexp);
   }
   foreach el,amt in newdeal res += softcapped(amt);
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
record {
   int turns;
   string img;
}[string] banishers; // actions which banish the monster => how many turns and which image to use
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
      case "use 4603": nomiss = vprint("You are now handcuffed to this monster: its attacks will always hit.",8); break;
   }
   matcher splitfunk = create_matcher("use (\\d+), ?(\\d+)",occurrence);   // record funkslinging individually
   if (splitfunk.find()) { for i from 1 to 2 set_happened("use "+splitfunk.group(i),q); return; }
   if (!q && (banishers contains occurrence)) cli_execute("counters add "+banishers[occurrence].turns+" "+m+" banished loc=* "+banishers[occurrence].img);
   if (count(happenings) == 0) file_to_map("BatMan_happenings_"+replace_string(my_name()," ","_")+".txt",happenings);
   if (happenings[occurrence].turn != turncount) {
      happenings[occurrence].turn = turncount;
      happenings[occurrence].done = 0;
   }
   if (q) happenings[occurrence].queued += 1;
     else happenings[occurrence].done += 1;
   if (map_to_file(happenings,"BatMan_happenings_"+replace_string(my_name()," ","_")+".txt"))
      vprint((q ? "Queued: " : "Happened: ")+occurrence,"#537F91",8);
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
   vprint(i+" ("+rate+" @ +"+rnum(item_drop_modifier())+"): "+rnum(item_val(i),3)+entity_decode("&mu;")+" * "+rnum(minmax(rate*(item_drop_modifier()+100)/100.0,0,100))+"% = "+rnum(modv),8);
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
   switch (braindrop(m)) {    // include brain drops for Zombie Slayer
      case $item[none]: case $item[hunter brain]: break;      // mafia accounts for hunter brain drops already
      case $item[boss brain]: res += item_val(braindrop(m),1.0); break;
      default: res += item_val(braindrop(m),have_skill($skill[skullcracker]) ? 0.6 : 0.3);
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
   return mvalcache + to_int(get_property("valueOfAdventure"));
  // TODO: include navel ring / bander runaways?  Or maybe not.
}
float beatenup_cost() {     // returns the cost of getting (removing) beaten up
   if (my_fam() == $familiar[wild hare] || have_effect($effect[heal thy nanoself]) > 0) return 0;
   if (item_amount($item[personal massager]) > 0) return 100;
   float cheapest = to_int(get_property("valueOfAdventure"))*3;    // beaten up costs 3 adventures
   if (have_skill($skill[tongue of the walrus])) cheapest = min(cheapest,meatpermp*mp_cost($skill[tongue of the walrus]));
   if (item_amount($item[tiny house]) > 0) cheapest = min(cheapest,item_val($item[tiny house]));
   if (item_amount($item[forest tears]) > 0) cheapest = min(cheapest,item_val($item[forest tears]));
   if (item_amount($item[soft green echo eyedrop antidote]) > 0) cheapest = min(cheapest,item_val($item[soft green echo eyedrop antidote]));
   return cheapest;
}

// ========= DATA FILE =========

combat_rec [string, int] factors;

float spell_elem_bonus(string types) {
   float result;
   int milieu;
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
      case "pasta": foreach i in $items[chester's aquarius medallion, sinful desires, slime-covered staff] if (have_equipped(i)) return "sleaze";
         foreach i in $items[necrotelicomnicon, the necbromancer's stein] if (have_equipped(i)) return "spooky";
         foreach i in $items[cookbook of the damned, wand of oscus] if (have_equipped(i)) return "stench";
         foreach i in $items[codex of capsaicin conjuration, ol' scratch's ash can, ol' scratch's manacles, snapdragon pistil] if (have_equipped(i)) return "hot";
         foreach i in $items[double-ice box, enchanted fire extinguisher, gazpacho's glacial grimoire] if (have_equipped(i)) return "cold";
         if (have_effect($effect[spirit of cayenne]) > 0) return "hot";
         if (have_effect($effect[spirit of peppermint]) > 0) return "cold";
         if (have_effect($effect[spirit of garlic]) > 0) return "stench";
         if (have_effect($effect[spirit of wormwood]) > 0) return "spooky";
         if (have_effect($effect[spirit of bacon grease]) > 0) return "sleaze";
         string res = "hot,cold,spooky,sleaze,stench,none";
         if (res.contains_text(m.defense_element)) res.replace_string(m.defense_element+",","");
         return res;
      case "sauce":   // this now only applies to saucegeyser, and is non-tuneable
         if (mres[$element[hot]] < mres[$element[cold]]) return "hot";
         if (mres[$element[cold]] < mres[$element[hot]]) return "cold";
         if (dmg_dealt(to_spread((1+spell_elem_bonus("hot"))+" hot")) != dmg_dealt(to_spread((1+spell_elem_bonus("cold"))+" cold")))
            return (dmg_dealt(to_spread((1+spell_elem_bonus("hot"))+" hot")) > dmg_dealt(to_spread((1+spell_elem_bonus("cold"))+" cold"))) ? "hot" : "cold";
         return "hot,cold";
      case "perfect": element[int] ranks;
         foreach el in $elements[] ranks[count(ranks)] = el;
         sort ranks by mres[value];
         return to_string(ranks[0]);
   }
   return dmgt;
}

void load_factors() {
   vprint("Loading batfactors...",9);
   load_current_map("batfactors",factors);        // master data file of battle factors
   if (have_effect($effect[form of...bird!]) > 0) {
      remove factors["item"];                     // remove items if impossible
      vprint("You can't use items in this combat.",-6);
   }
   if (my_fam() != $familiar[frumious bandersnatch]) remove factors["bander"];    // remove irrelevant batfactors to
   if (my_fam() != $familiar[mad hatrack]) remove factors["hatrack"];        // save time during the following
   if (my_fam() != $familiar[fancypants scarecrow]) remove factors["scare"];
   if (!have_equipped($item[crown of thrones]) && !have_equipped($item[buddy bjorn])) remove factors["crown"];
   matcher rng = create_matcher("\\{.+?,(.+?),.+?}","");
   string deranged(string sane) {
      rng.reset(sane);
      while (rng.find()) sane = sane.replace_string(rng.group(0),rng.group(1));
      return sane;
   }
   foreach te,it,rd in factors {                 // remove uunderwater-only, reduce ranges to averages
      if (contains_text(rd.special,"underwater") && my_location().zone != "The Sea") { remove factors[te,it]; continue; }
      factors[te,it].dmg = deranged(rd.dmg);
      factors[te,it].pdmg = deranged(rd.pdmg);
      factors[te,it].special = deranged(rd.special);
   }
}
void parse_factors() {
   vprint("Processing batfactors...",9);
   matcher ban = create_matcher("custom banish (\\d+)","");
   foreach te,it,rd in factors {                 // build banishers list,  tune damage
      ban.reset(rd.special);
      if (ban.find() && ban.group(1).to_int() > 0) {
         string ind = (te == "item" ? "use "+it : "skill "+it);
         banishers[ind].turns = ban.group(1).to_int();
         if (te == "item") banishers[ind].img = to_item(it).image;
          else switch (to_skill(it)) {
             case $skill[creepy grin]: banishers[ind].img = "waxlips.gif"; break;
             case $skill[give your opponent the stinkeye]: banishers[ind].img = "sc_eye.gif"; break;
          }
         factors[te,it].special = replace_string(rd.special, ban.group(0), "custom banish");
      }
      foreach kw in $strings[pasta,sauce,perfect] if (rd.dmg.contains_text(kw))
         factors[te,it].dmg = rd.dmg.replace_string(kw,normalize_dmgtype(kw));
      if (te == "skill" && it == 3008) {         // weapon of the pastalord
         if (!contains_text(rd.dmg,"none"))
            factors[te,it].dmg += ",none";		 
           else factors[te,it].dmg = rd.dmg.replace_string("hot,cold,spooky,sleaze,stench,","");
      }
   }
}

//===================== BUILD COMBAT ENVIRONMENT =========================

advevent famevent() {
   advevent fam;
   if ($classes[avatar of boris, avatar of jarlsberg] contains my_class()) return fam;
   if (!(factors["fam"] contains to_int(my_fam())) || (my_fam() == $familiar[dandy lion] && item_type(equipped_item($slot[weapon])) != "whip")) return fam;
   fam.id = to_string(my_fam());
   if (happened("famspent")) return fam;
   if (my_familiar() == $familiar[warbear drone]) fvars["currentround"] = round;
   fvars["fweight"] = familiar_weight(my_familiar()) + weight_adjustment() + min(20,2*my_level())*to_int(to_int(my_class())+82 == to_int(my_fam()));
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

advevent companions() {
   advevent comp;
   if ($classes[avatar of boris, avatar of jarlsberg] contains my_class() || happened("buddymisfire")) return comp;
   advevent eq_fam(familiar along) {   // a familiar is along for the ride (crown, bjorn)
      advevent c;
      if (!(factors["crown"] contains to_int(along))) return c;
      c.id = "companion "+along;
      boolean cutoff = factors["crown",to_int(along)].special.contains_text("r3");
      if (cutoff && round > 3) return c;                             // can't act anymore
      c = to_event("companion "+along,factors["crown",to_int(along)]);
      float crownrate = (cutoff) ? 1 : 0.315;                        // reasonable for all 30%/33% familiars
      switch (along) {
         case $familiar[mariachi chihuahua]: case $familiar[baby sandworm]: case $familiar[snow angel]: crownrate = 0.5; break;
         case $familiar[Green Pixie]: crownrate = 0.2; break; case $familiar[whirling maple leaf]: crownrate = 0.25; break;
         case $familiar[Black Cat]: crownrate = 1; break;
         case $familiar[Grimstone Golem]: crownrate = (get_property("_grimstoneMaskDropsCrown") < 1) ? crownrate : 0; break;
         case $familiar[Grim Brother]: crownrate = (get_property("_grimFairyTaleDropsCrown") < 2) ? crownrate : 0; break;
      }
      return factor(c,crownrate);
   }
   if (have_equipped($item[crown of thrones])) comp = eq_fam(my_enthroned_familiar());
   if (have_equipped($item[buddy bjorn])) comp = merge(comp,eq_fam(my_bjorned_familiar()));
   return comp;
}
advevent basecache;                          // base round event cached for speed
advevent baseround() {                       // base round event
   if (basecache.note != "" && basecache.note.to_int() == round) return basecache;
   basecache = (have_equipped($item[crown of thrones]) || have_equipped($item[buddy bjorn])) ? merge(base,famevent(),companions()) : merge(base,famevent());
   if (happened("skill 12000")) basecache.dmg[$element[none]] += my_level();
   basecache.note = round;
   cleareventscreated();
   if (round == 0 || vars["verbosity"].to_int() > 8) vprint_html("<b>Base round:</b> "+to_html(basecache.dmg)+" damage, "+to_html(basecache.pdmg)+" player damage, "+
     (basecache.att == 0 ? "" : rnum(basecache.att)+" attack, ")+(basecache.def == 0 ? "" : rnum(basecache.def)+" defense, ")+
     (basecache.stun == 0 ? "" : rnum(basecache.stun)+" stun, ")+(basecache.mp == 0 ? "" : rnum(basecache.mp)+" MP, ")+rnum(basecache.meat)+" meat",4);
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
   cleareventscreated();
}

// ====== MONSTER ======
float m_hit_chance() {            // monster hit chance
   float stunmod = minmax(merge(baseround(),adj).stun,0,1.0);
   return nomiss ? 1.0 - stunmod : (1.0 - stunmod)*minmax(0.55 + (max(monster_stat("att"),0.0) - my_stat("Moxie"))*0.055,my_location() == $location[the slime tube] ? 0.8 : 0.06,0.94);
}
spread m_regular() {               // damage dealt by monster attack
   if (nohit) return to_spread(0);
   switch (m) {                    // unique damage formulas
      case $monster[your shadow]: return to_spread(95 + (my_maxhp()/6));
      case $monster[mammon the elephant]: return to_spread(2**(round - 1));
      case $monster[the landscaper]: return to_spread(my_maxhp()*0.49);
      case $monster[vanya's creature]: return to_spread(my_maxhp()*0.125);
      case $monster[pufferfish]: return to_spread(2 + 2**round);
      case $monster[the unkillable skeleton (hard mode)]: return to_spread(my_maxhp()*0.09);
      case $monster[great wolf of the air (hard mode)]: if (round % 2 == 1) return to_spread(my_maxhp() + 50 - max(0,numeric_modifier("Damage Reduction"))); break;
      case $monster[ninja snowman assassin]: spread res;
         res[m.attack_element] = (max(0,monster_stat("att") - my_defstat()) + 110)*
          (1 - minmax((square_root(max(0,numeric_modifier("Damage Absorption"))/10) - 1)/10,0,0.9));
         return res;
   }
   spread res;
   res[m.attack_element] = max(1.0,max(0,max(0,monster_stat("att")) - my_defstat(true)) + 0.225*max(0,monster_stat("att")) - max(0,numeric_modifier("Damage Reduction"))) *
      (1 - minmax((square_root(max(0,numeric_modifier("Damage Absorption"))/10) - 1)/10,0,0.9));
   return res;
}
advevent m_event(float att_mod, float stun_mod) {      // monster event -- attack + retal, factored by hitchance
   advevent res;                                       // allows prediction with attack and stun modifiers
   adj.att += att_mod;
   adj.stun += stun_mod;
   res.pdmg = have_effect($effect[chilled to the bone]) > 0 ? factor(m_regular(),max(2,my_location().kisses)) : m_regular();
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
      case $monster[spooky vampire (Dreadsylvanian)]:                                // vampires always drain 10 HP
      case $monster[sleaze vampire]:
      case $monster[stench vampire]: 
      case $monster[hot vampire]:
      case $monster[cold vampire]: res.pdmg[$element[none]] += 10; res.dmg = to_spread("-10"); break;
      case $monster[frustrating knight]: res.pdmg[$element[none]] += 95; break;
      case $monster[gaunt ghuol]:
      case $monster[gluttonous ghuol]: res.dmg = to_spread("-1.65"); break;          // 30% chance to heal 1-10 HP
      case $monster[huge ghuol]: res.dmg = to_spread("-1.65"); break;                // 30% chance to heal 1-10 HP
      case $monster[dr. awkward]: res.dmg = to_spread("-25"); break;                 // assuming 50%
      case $monster[quiet healer]: res.pdmg[$element[none]] -= 0.25*17.5; break;     // ... 25% ... ...??
      case $monster[knob goblin mad scientist]: res.mp += 0.25*9; break;             // assuming 25% activation rate??
      case $monster[mer-kin raider]:                                                 // assuming 50% rate healing 250HP
      case $monster[mer-kin burglar]:
      case $monster[mer-kin healer]: res.dmg = to_spread(-min(125,monster_hp(m)+monster_level_adjustment()-monster_stat("hp")),max(0,1.0 - adj.stun)); break;
      case $monster[warbear officer]:
      case $monster[high-ranking warbear officer]:
         if (fvars contains "drone") switch (to_int(fvars["drone"])) {
            case 1: case 7: res.pdmg[$element[none]] += 0.25*my_maxhp(); break;  // 7 is supercold
            case 2: res.pdmg[$element[hot]] += 0.25*my_maxhp(); break;
            case 3: res.pdmg[$element[cold]] += 0.25*my_maxhp(); break;
            case 4: res.pdmg[$element[spooky]] += 0.25*my_maxhp(); break;
            case 5: res.pdmg[$element[stench]] += 50; break;
            case 6: res.pdmg[$element[sleaze]] += 0.25*my_maxhp(); break;
            case 8: res.dmg = to_spread("-18"); break;
            case 9: res.mp -= 50; break;
            default: vprint("Unknown drone shown!",-3);
         } break;
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
   float biff = dmg_dealt(s);
   if (biff >= monster_stat("hp")) return 1;
   return ceil(to_float(monster_stat("hp")) /
               minmax(biff + dmg_dealt(m_event().dmg) + dmg_dealt(baseround().dmg), 0.0001, monster_stat("hp")));
}
int kill_rounds(advevent a) { return kill_rounds(a.dmg); }  // how many rounds for a given action to kill the monster
int die_rounds() {                // how many rounds at the current ML and stun until you die
   switch (m) {
      case $monster[mammon the elephant]:
      case $monster[pufferfish]: int tdmg; for i from round to 100 { tdmg += 2**i; if (tdmg >= my_stat("hp")) return i - round + adj.stun; } return 3;
   }
   return ceil(my_stat("hp") / max(m_dpr(0,-adj.stun),0.0001)) + adj.stun;
}
boolean intheclear() {            // returns true if you will outlive the combat
   if (m == $monster[none] || have_effect($effect[strangulated]) > 0) return false;
   return (die_rounds() > maxround);
}
boolean unarmed() {
   return (equipped_item($slot[weapon]) == $item[none] && equipped_item($slot[off-hand]) == $item[none]);
}

// ======= WHAT ARE THE CHANCES =======

float fumble_chance() {
   if (have_equipped($item[operation patriot shield]) && happened($skill[throw shield]) && !happened("shieldcrit")) return 0;
   if (have_effect($effect[clumsy]) > 0 || have_effect($effect[QWOPped Up]) > 0) return 1.0;
   if ((boolean_modifier("Never Fumble") || have_effect($effect[song of battle]) > 0) && m != $monster[dr. awkward]) return 0;
   return (1.0 / max(22.0,to_int(have_effect($effect[sticky hands]) > 0)*30.0)) * max(1.0,numeric_modifier("Fumble"));
}
advevent fumble() {
   if (string_modifier("Outfit") == "Clockwork Apparatus")
      return to_event("",to_spread(15*0.25),to_spread(-12.5*0.25),"stun 0.25, mp 12.5*0.25, att -1, def -1");
   int wpnpwr = get_power(equipped_item($slot[weapon]));
   if (have_skill($skill[double-fisted skull smashing]) && item_type(equipped_item($slot[off-hand])) != "shield")
      wpnpwr += get_power(equipped_item($slot[off-hand]));
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
   if (id == "attack") {
      if (m == $monster[the bat in the spats]) return critchance();
      through *= 1.0 - fumble_chance();
      if (my_location() == $location[The Tower of Procedurally-Generated Skeletons] && contains_text(m,"shifty")) through *= 0.4;  // value based on tiny sample
   }
   if (have_effect($effect[song of battle]) > 0 || happened("use 4603")) return through;
   float attack = my_stat(to_string(current_hit_stat())) + (have_skill($skill[sick pythons]) ||
      (have_skill($skill[master of the surprising fist]) && unarmed()) ? 20 : 0);
   if (have_equipped($item[operation patriot shield]) && my_class() == $class[Disco Bandit] &&
       current_hit_stat() == $stat[moxie]) attack += 100;
   matcher aid = create_matcher("(attack|use|skill) ?(\\d+)?",id);
   if (aid.find()) switch (aid.group(1)) {
      case "use": if (my_fam() == $familiar[black cat]) through *= 0.5;
         return noitems > 0 ? through*(1.0 - noitems) : through;
      case "skill": if (noskills > 0) through *= max(0, 1.0 - noskills);
         switch (to_int(aid.group(2))) {
            case 0001: case 2003: case 7097: break;  // beak, head, turtle*7 tails all have regular hitchance
            case 7010: case 7011: case 7012: case 7013: case 7014: attack = 10 + my_stat("Moxie"); break; // bottle rockets are mox+10
            case 1003: attack += 20;             // ts -- TODO: verify attack bonus innate to skill now?
            case 1004: case 1005: case 1038: case 7096: if (my_class() == $class[seal clubber] && item_type(equipped_item($slot[weapon])) == "club")
                           return through;   // lts, bashing slam smash
                    if ($ints[1003,1004,7096] contains aid.group(2).to_int()) break;
                    attack *= 1.25 + 0.05*to_int(my_class() == $class[seal clubber]); break;   // TODO: verify this is innate (formerly from eye of stoat)
            case 1032: return my_class() == $class[seal clubber] ? through : 0;
            case 2015: case 2103: attack += min(my_level()*2,20.0); break;    // kneebutt & head+knee
            case 11000: break;                                                // regular hit chance, but no fumble
            case 11001: attack *= 1.2; attack += 20; break;                   // estimated: cleave is not perfectly spaded
            default: attack = 0;
         }
   }
   return attack == 0 ? through : min(critchance() + (1.0 - critchance())*max(6.0 + attack - max(monster_stat("def"),0),0)/11.0,1.0)*through;
}


//===================== BUILD COMBAT OPTIONS =========================

advevent oneround(advevent r) {           // plugs an advevent into the current combat and returns the summed round event
   advevent a = merge(r,new advevent);
   for i from 1 upto a.rounds a = merge(a,baseround());
   a.pdmg[$element[none]] = max(a.pdmg[$element[none]], my_stat("hp")-my_maxhp());  // cap healing/mp gain BEFORE merging monster event
   a.mp = min(a.mp,my_maxmp()-my_stat("mp"));
   if (!a.endscombat) for i from 1 upto a.rounds
      a = merge(a,m_event(a.att,max(0,a.stun+1-i)));   // monster event(s)
//   if (monster_stat("hp")-dmg_dealt(a.dmg) < 1) a.meat += mvalcache;   // monster death should only be included for chain profits
   return a;
}

float to_profit(advevent haps, boolean nodelevel) {    // determines the profit of an action in the current combat
   advevent a = oneround(haps);
   boolean ignorerestore = contains_text(haps.note,"restore");
   haps.profit = minmax(-dmg_taken(a.pdmg),                             // hp
                        min(0,max(-dmg_taken(a.pdmg),-my_stat("hp"))+max(0,my_stat("hp")-max(0,my_maxhp()-numeric_modifier("_spec","HP Regen Min")))),
                        ignorerestore ? 0 : max(0,my_maxhp()-my_stat("hp")-numeric_modifier("_spec","HP Regen Min")))*meatperhp +
          minmax(a.mp,                                                  // mp
                 min(0,max(a.mp,-my_stat("mp"))+max(0,my_stat("mp")-max(0,my_maxmp()-numeric_modifier("_spec","MP Regen Min")))),
                 ignorerestore ? 0 : max(0,my_maxmp()-my_stat("mp")-numeric_modifier("_spec","MP Regen Min")))*meatpermp +
          (nodelevel ? 0 : (a.att == 0 ? 0 : (m_dpr(0,0) - m_dpr(a.att,0))*meatperhp)) +  // delevel
          stat_value(a.stats)+                                          // substats
          a.meat;                                                       // meat
   return haps.profit;
}
float to_profit(advevent haps) { return to_profit(haps,true); }

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
   switch (m) {
      case $monster[your shadow]: if (a.pdmg[$element[none]] >= 0) return; break;   // don't add non-healing items vs. shadow
      case $monster[Yog-Urt, Elder Goddess of Hatred]: if (dmg_dealt(a.dmg) > 0 && round + equipped_amount($item[mer-kin prayerbeads]) <= 8) return; break;  // don't kill yourself
      case $monster[Shub-Jigguwatt, Elder God of Violence]: if (dmg_dealt(a.dmg) > 0 && a.id != "attack") return; break;  // don't kill yourself
      case $monster[mine crab]: if (dmg_dealt(a.dmg) > 39) a.pdmg[$element[none]] = 100000; break;   // sensitive beasties
      case $monster[Mayor Ghost (Hard Mode)]: if (a.pdmg[$element[none]] < 0) return; break;   // healing items are prohibited by law!
   }
   if (a.id == "skill 3022") a.meat *= 0.13;                    // candyblast drops candy at 33% rate, plus additional compensation for overvalued candy
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
   float radj = (equipped_item($slot[weapon]) == $item[none]) ? 0.25 : (ranged ? 0.75 : 1.0);
   res[$element[none]] = max(0,max(0,floor(my_stat(to_string(current_hit_stat()))*ltsadj*radj) - monster_stat("def")) +
      (unarmed() ? 1 : max(1,get_power(equipped_item($slot[weapon]))*0.15 + 0.5) * (critchance()+1.0) * ts) + 
      numeric_modifier("Weapon Damage") - get_power(equipped_item($slot[weapon]))*0.15 + 
      to_int(ranged)*numeric_modifier("Ranged Damage")) * (100 + numeric_modifier("Weapon Damage Percent") +
      to_int(ranged)*numeric_modifier("Ranged Damage Percent"))/100;
   if (have_skill($skill[double-fisted skull smashing]) && to_slot(equipped_item($slot[off-hand])) == $slot[weapon])
      res[$element[none]] += 0.15*get_power(equipped_item($slot[off-hand])) + 0.5;
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
      if (blacklist contains ("use "+it) && blacklist["use "+it] < 1) continue;
      if (happened("use "+it) && (contains_text(fields.special,"once") || 
          (!to_item(it).combat_reusable && happenings["use "+it].queued >= max(0,item_amount(to_item(it)) - blacklist["use "+it])) ||
           m == $monster[Yog-Urt, Elder Goddess of Hatred])) continue;
      switch (m) {
         case $monster[zombie homeowners' association (hard mode)]:
         case $monster[zombie homeowners' association]: if (!contains_text(fields.special,"aoe ")) return; break; // only aoe items work
      }
      rate = item_val(to_item(it))*to_int(!to_item(it).combat_reusable);
      switch (it) {
         case 1397: if (item_amount($item[bottle of tequila]) == 0) continue;                 // toy soldier
            rate += item_val($item[bottle of tequila]); break;
         case 2065: if (my_location() != $location[the battlefield (frat uniform)] || get_counters("PADL Phone",0,10) != "" ||  // PADL phone
            string_modifier("Outfit") != "Frat Warrior Fatigues" || appearance_rates(my_location())[last_monster()] > 0) continue;
         case 2354: if (to_float(my_stat("hp"))/my_maxhp() < 0.25) fields.pdmg = "-275";      // windchimes
             else if (to_float(my_stat("mp"))/max(1,my_maxmp()) < 0.25) fields.special = "mp 175";
              else fields.dmg = "175";
            if (to_item(it) == $item[PADL phone]) break;
            if (my_location() != $location[the battlefield (hippy uniform)] || get_counters("Communications Windchimes",0,10) != "" ||
                string_modifier("Outfit") != "War Hippy Fatigues" || appearance_rates(my_location())[last_monster()] > 0) continue; break;
         case 2453: if (my_fam() != $familiar[penguin goodfella] || my_meat() < fvars["fweight"]*3) continue; break;  // goodfella contract
         case 2462: if (have_effect($effect[on the trail]) > 0) continue; break;              // odor extractor
         case 3101: rate *= 0.5; break;                                                       // rogue swarmer
         case 3195: if (dropspants()) {                                                       // naughty paper shuriken
               fields.special = happened("use 3195") ? "" : "stun 3, once"; fields.dmg = "0";
            } break;
         case 3388: if (get_counters("Zombo's Empty Eye",0,50) != "") continue; break;        // zombo's eye
         case 3665: if (to_int(get_property("spookyPuttyCopiesMade")) + max(1,to_int(get_property("_raindohCopiesMade"))) >= 6 || 
                        item_amount($item[spooky putty monster]) > 0) continue; break;        // spooky putty sheet
         case 4169: if (item_amount($item[shaking 4-d camera]) > 0) continue; break;          // 4-d camera
         case 4494: if (contains_text(m,"BRICKO")) fields.dmg = "50000"; break;               // bricko reactor
         case 5048: if (have_effect($effect[coldform]) > 0) continue; break;                  // double-ice: don't align monster to cold
         case 5233: if (monster_phylum(m) == $phylum[construct]) fields.dmg = monster_stat("hp")*6; break; // box of hammers
         case 5445: if (m == $monster[the bat in the spats]) fields.dmg = "1000"; break;      // clumsiness bark
         case 5557: if (my_meat() < 50) continue; break;                                      // orange agent
         case 5563: if (to_int(get_property("_raindohCopiesMade")) + max(1,to_int(get_property("spookyPuttyCopiesMade"))) >= 6 || 
                        item_amount($item[rain-doh box full of monster]) > 0) continue; break;  // rain-doh black box
         case 6026: if ($monsters[oil baron, oil slick, oil cartel, oil tycoon] contains m) fields.special = "item bubblin' crude"; break;  // Duskwalker syringe
         case 6708: if (monster_stat("att") < my_stat("att")) continue; break;                // crude voodoo doll
         case 6714: if (my_location().zone == "Dreadsylvania") continue; break;               // short calculator
         case 7079: if (item_amount($item[ice sculpture]) > 0) continue; break;               // unfinished ice sculpture
         case 819: case 820: case 821: case 822: case 823: case 824: case 825: case 826: case 827: // ! potions
            fields = get_bang(get_property("lastBangPotion"+it)); break;
         case 2174: case 2175: case 2176: case 2177:                                          // spheres
            fields = get_sphere(get_property("lastStoneSphere"+it)); break;
      }
      fvars["itemamount"] = item_amount(to_item(it));
      d = to_spread(fields.dmg);
      if (isseal) {
         foreach el,amt in d if (d[el] > 0) d[el] = min(1.0,amt);
      } else {
         float dammult = 1.0;
         if (have_equipped($item[v for vivala mask])) dammult += 0.5;
         if (have_skill($skill[deft hands])) dammult += 0.25;
         if (dammult > 1) d = factor(d,dammult);
      }
      if (m == $monster[mother hellseal] && count(d) > 0) continue;
      advevent temp = to_event("use "+it,d,to_spread(fields.pdmg),fields.special,1);
      switch (my_fam()) {       // arbitrarily assume 30% blocking for these
         case $familiar[o.a.f.]: temp = merge(factor(temp,0.70),factor(
            merge(to_event("",regular(1),to_spread(0),"",0),onhit,factor(oncrit,critchance())),0.30));
            addopt(temp,0.7*rate,0);
            continue;
      }
      if (contains_text(item_type(to_item(it)),"restore")) temp.note += (temp.note == "" ? "restore" : " (restore)");
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
   return ($skills[noodles of fire,saucemageddon,volcanometeor showeruption,wassail,toynado,turtleini] contains s);
}

void build_skillz() {
   if (count(factors["skill"]) == 0) return;
   spread d;
   string thisid;
   fvars["bonusdb"] = numeric_modifier("DB Combat Damage") + to_int(my_fam() == $familiar[frumious bandersnatch])*
      0.75*(fvars["fweight"]+numeric_modifier("Familiar Weight"));
   fvars["spelldmg"] = numeric_modifier("Spell Damage");
   int burrowgrub_amt() { return (1+to_int(have_effect($effect[yuletide mutations]) > 0)) * min(my_level(),15); }
   void add_skill(int sk, combat_rec fields) {
      if (mp_cost(to_skill(sk)) > my_stat("mp")) return;
      if (nospells && is_spell(to_skill(sk))) return;
      thisid = "skill "+sk;
      if (blacklist contains thisid) {      // infinite and threshold blacklisting
         if (blacklist[thisid] < 1) return;
         if (happened(thisid) && happenings[thisid].done + happenings[thisid].queued >= blacklist[thisid]) return;
      }
      switch (m) {
         case $monster[zombie homeowners' association (hard mode)]:
         case $monster[zombie homeowners' association]: if (!contains_text(fields.special,"aoe ")) return; break; // only aoe skills work
      }
      fvars["elembonus"] = spell_elem_bonus(excise(fields.dmg," ",""));
      fvars["mpcost"] = mp_cost(to_skill(sk));
      if (have_skill($skill[intrinsic spiciness])) {
         fvars["spelldmg"] = numeric_modifier("Spell Damage");  // reset since it may have previously been decremented
         if (to_skill(sk).class == $class[sauceror]) fvars["spelldmg"] += min(my_level(),10.0);
      }
      rate = 0;
      d = to_spread(0);
      switch (sk) {
        case 19: if (have_effect($effect[on the trail]) > 0) return; break;    // olfaction
        case 55: if (item_amount($item[volcanic ash]) == 0) return; rate = item_val($item[volcanic ash]); break;  // volcaneometeoric showercanoruptionwhatever
        case 50: case 51: case 52: if (modifier_eval("zone(volcano)") == 0 && have_item($item[seeger's unstoppable banjo]) == 0) return; break;
        case 66: if (fvars["fistskills"] > 1) fields.special = "meat -"+(meatpermp*mp_cost($skill[salamander kata])*have_effect($effect[salamanderenity])/(3*fvars["fistskills"]));
           break;  // flying fire fist costs salamanderenity
        case 70: fields.special = happened($skill[chilled monkey brain technique]) ? "" : "stun 1"; break;  // monkey only stuns once
        case 77: fields.special = (!happened($skill[torment plant]) && (item_drops(m) contains $item[clumsiness bark])) ? "item clumsiness bark" : "phylum plant";
        case 78: fields.special = (!happened($skill[pinch ghost]) && (item_drops(m) contains $item[jar full of wind])) ? "item jar full of wind" : "!! only affects ghosts";
        case 79: fields.special = (!happened($skill[tattle]) && (item_drops(m) contains $item[dangerous jerkcicle])) ? "item dangerous jerkcicle" : "att -7, def -12";
        case 84: fvars["wpnpower"] = max(10, get_power(equipped_item($slot[weapon])));            // silent slam
           if (item_type(equipped_item($slot[weapon])) == "club") fvars["wpnpower"] *= 2; break;
        case 86: fvars["wpnpower"] = max(10, get_power(equipped_item($slot[weapon])));            // silent slice
           if (item_type(equipped_item($slot[weapon])) == "knife") fvars["wpnpower"] *= 2; break;
        case 93: if (item_amount($item[dry noodles]) == 0 || m.boss) return; rate = item_val($item[dry noodles]); break;  // carbo cudgel
        case 102: if (happened("skill 3004")) return;  // cannot use both entangling and shadow noodles in a single fight
        case 2028: for i from 1416 to 1418 if (have_effect(to_effect(i)) > 0) { d[$element[none]] = m_hit_chance()*(0.1 + (i - 1415)*0.05)*my_stat("Muscle"); break; }
           for i from 1419 to 1421 if (have_effect(to_effect(i)) > 0) { fields.special = "stun 1, hp "+m_hit_chance()*(3.5*(i - 1418)**2 - 6.5*(i - 1418) + 7); break; }
           for i from 1422 to 1424 if (have_effect(to_effect(i)) > 0) { fields.special = "stun "+max(1,m_hit_chance()*(i - 1419)); break; }
           d[$element[none]] = m_hit_chance()*0.1*my_stat("Muscle"); break;
        case 3004: if (my_class() != $class[pastamancer]) fields.special = "stun, att -9, def -9";    // entangling noodles
           else if (m == $monster[spaghetti demon]) fields.special = list_remove(fields.special,"once"); break;
        case 3025: if (!have_equipped($item[hand that rocks the ladle])) break; d = to_spread(fields.dmg); foreach el in $elements[] d[el] += 11; break;  // utensil twist
        case 4014: if (!happened("skill 4014")) fields.special = "quick"; break;
        case 6030: if (!(factors["cadenza"] contains to_int(equipped_item($slot[weapon])))) return; combat_rec acc = factors["cadenza",to_int(equipped_item($slot[weapon]))];  // cadenza
           d = to_spread(acc.dmg); fields.pdmg = acc.pdmg; fields.special = list_add(acc.special,"once"); break;
        case 7061: fvars["wpnpower"] = get_power(equipped_item($slot[weapon])); break;      // spring raindrop attack
        case 7074: if (my_maxhp() - my_stat("hp") <= 2*burrowgrub_amt() || my_maxmp() - my_stat("mp") <= burrowgrub_amt()) return; break;  // skip burrowgrub unless none is wasted
        case 7081: fvars["botcharges"] = get_property("bagOTricksCharges").to_int(); break;
        case 7082: if (contains_text(page,"red eye")) {        // point at your opponent (he-boulder rays)
              d = to_spread(((4.5-minmax(have_effect($effect[everything looks red]),0,2))*fvars["fweight"])+" hot");
              if (have_effect($effect[everything looks red]) > 0) fields.special = "once, stats "+(4.5*fvars["fweight"])+"|"+(4.5*fvars["fweight"])+"|"+(4.5*fvars["fweight"]);
           } else if (contains_text(page,"blue eye")) {
              if (have_effect($effect[everything looks blue]) > 0) { d = to_spread((1.5*fvars["fweight"])+" cold"); fields.special = "once"; }
               else fields.special = "stun 3, once";
           } else if (contains_text(page,"yellow eye")) {
              if (have_effect($effect[everything looks yellow]) > 0) { d = to_spread(0.75*fvars["fweight"]); fields.special = "once"; }
               else { d = to_spread((6*monster_stat("hp"))+" hot,cold,spooky,sleaze,stench,none"); fields.special = "custom, once, endscombat"; }
           } break;
        case 7112: rate = ((have_effect($effect[taste the inferno])-1)/50.0)*item_val($item[nuclear blastball]); break;  // nuclear breath costs a blastball, but should be used
        case 7116: if (m.phylum == $phylum[dude]) fields.special += ", stun"; break;
        case 7137: effect nano; int turns; foreach e in $effects[nanobrawny, nanobrainy, nanoballsy] if (have_effect(e) > turns) { nano = e; turns = have_effect(e); }
           switch (nano) {    // unleash nanites
              case $effect[nanobrawny]: if (m.boss || turns < 40) {
                 d = to_spread(turns*10); fields.pdmg = to_string(-turns*5); fields.special = "custom, once";
              } else fields.special = "custom banish, endscombat"; break;
              case $effect[nanobrainy]: if (m.boss || turns < 40) {
                 d = to_spread(turns*10); fields.special = "custom, once, mp "+to_string(-turns*5);
              } else fields.special = "custom, once, !! replaces monster with gray goo!"; break;
              case $effect[nanoballsy]: if (m.boss || turns < 40 || have_effect($effect[everything looks yellow]) > 0) {
                 fields.pdmg = to_string(-turns); fields.special = "custom, once, att -"+(turns/2)+", def -"+(turns/2)+", mp "+turns+", !! amounts unknown";
              } else fields.special = "custom yellow, once, endscombat"; break;
              default: return;
           }
        case 7142: case 7143: case 7144: case 7145: if (item_amount($item[pixel power cell]) == 0) return; 
           rate = item_val($item[pixel power cell]); break;  // anger/fear/regret/doubt weapons cost pixel cells
        case 7165: d = to_spread(fields.dmg, to_int(have_equipped($item[great wolf's right paw])) + to_int(have_equipped($item[great wolf's left paw])));
           if (my_location().zone == "Dreadsylvania") d = factor(d,2); break;  // great slash attacks once/paw, and does 2x damage in Dreadsylvania
        case 7200: if (item_amount($item[drum of tommy ammo]) == 0) return;  // unload tommy gun costs ammo
           rate = item_val($item[drum of tommy ammo]); break;
        case 7202: if (monster_element(m) == $element[spooky]) return; break;  // pull voice box string fails to spook the spooky
        case 7203: if (item_amount($item[hot coal]) == 0) return;        // shovel hot coal costs coal
           rate = item_val($item[hot coal]); break;
        case 11006: if (!have_equipped($item[trusty])) return; break;    // throw trusty needs a trusty
        case 11010: if (have_effect($effect[foe-splattered]) > 0) return; break;   // bifurcating blow
        case 12012: if (!happened("skill 12000")) break;         // plague claws could grant MP after bite
           d = to_spread(happened("skill 12012") ? my_level()*3 : my_level()*2);
        case 12000: if ($phyla[bug,constellation,elemental,construct,plant,slime] contains m.phylum) break;
           if (!happened("skill "+sk)) fields.special = list_add(fields.special,"!! zombify"); break;   // set flag for +MP since all regular MP is ignored
        case 15020: switch (get_property("peteMotorbikeHeadlight")) {   // flash headlight
              case "": d = to_spread(10); break;
              case "Ultrabright Yellow Bulb": fields.special = "custom yellow, once, endscombat"; break;
              case "Party Bulb": d = to_spread(my_stat("Moxie")+" hot,cold,spooky,sleaze,stench"); break;
              case "Blacklight Bulb": d = to_spread((0.4*my_stat("Moxie"))+" sleaze"); break;
              default: return;
           }
        default: if (contains_text(fields.special,"regular")) {
              if (have_effect($effect[QWOPped up]) > 0 || (current_hit_stat() == $stat[moxie] && !($ints[1022,1023,1032,12010] contains sk))) return;
              switch (sk) {    // dmg formulas too complicated for data file
                case 94: d = to_spread(regular(1)[$element[none]]+" hot"); break;
                case 2005: case 2105: case 2106: case 2107:      // skip shield skills if no shield
                   if (fvars["shieldpower"] == 0) return; d = merge(to_spread(fields.dmg),regular(1)); break;
                case 11000: if (!have_equipped($item[trusty])) return;  // axing
                case 1003: d = regular(2); break;                // ts
                case 1005: d = regular(3); break;                // lts
                case 1038: d = to_spread(regular(3)[$element[none]]+" cold"); break;  // northern explosion
                case 11001: if (!have_equipped($item[trusty])) return;  // cleave
                case 7096: d = regular(5); break;                // bashing slam smash
                case 7097: d = factor(regular(1),7); break;      // turtle of seven tails = 7 regular attacks
                case 7132: d = (have_equipped($item[right bear arm]) && have_equipped($item[left bear arm]) ?
                   to_spread(monster_hp()*0.5) : regular(1)); break;  // grizzly scene
                case 7135: d = to_spread((get_property("_bearHugs").to_int() < 10 && !m.boss) ? monster_hp()*6 : 25);  // bear hug
                   if (my_class() != $class[zombie master] || ($phyla[bug,constellation,elemental,construct,plant,slime] contains m.phylum)) break;
                   fields.special = list_add(fields.special,"!! zombify"); break;         // set flag for +MP since all regular MP is ignored
                case 1022: d[$element[none]] = max(0.5,0.15*get_power(equipped_item($slot[weapon])))+0.5+ceil(square_root(max(0,numeric_modifier("Weapon Damage"))));
                   foreach el in $elements[] d[el] = ceil(square_root(numeric_modifier(el+" Damage"))); break;   // clobber
                case 1023: if (equipped_item($slot[weapon]) == $item[none]) return;                            // harpoon!
                   d[$element[none]] = min(800.0,floor(fvars["buffedmus"]/4.0)) + 0.15*get_power(equipped_item($slot[weapon]))+0.5+1.5*max(0,numeric_modifier("Weapon Damage"));
                   foreach el in $elements[] d[el] = 1.5*numeric_modifier(el+" Damage"); break;
                case 12010: d = merge(factor(to_spread(fullness_limit() - my_fullness()),7),regular(1)); break;  // ravenous pounce
                case 12020: d = to_spread((m.boss ? monster_hp()*0.5 : 0));	break;                               // howl of the alpha
                default: d = merge(to_spread(fields.dmg),regular(1));
              }
           }
      }
      if (contains_text(fields.special,"once") && happened(thisid)) return;
      if (dmg_dealt(d) == 0) d = to_spread(fields.dmg);
      if (m == $monster[mother hellseal] && count(d) > 0 && (sk == 1022 || !contains_text(fields.special,"regular"))) return;
      advevent temp = to_event(thisid,d,to_spread(fields.pdmg),fields.special,1);
      if (contains_text(fields.special,"regular")) temp = merge(temp,onhit);
       else if (isseal) foreach el,amt in temp.dmg if (temp.dmg[el] > 0) temp.dmg[el] = min(1.0,amt);
      advevent bander(int which) {
         if (!happened("smusted") && factors["bander",which].special.contains_text("smust"))
            return to_event("",to_spread(0),to_spread(0),"stun 2");
         return to_event("",factors["bander",which]);
      }
      switch (my_fam()) {
        // bander skill augmentation
         case $familiar[frumious bandersnatch]: if (factors["bander"] contains sk) temp = merge(temp,bander(sk)); break;
        // OAF and Black cat skill blocks -- convert to regular attack! arbitrarily assume 30%
         case $familiar[o.a.f.]:
         case $familiar[black cat]: temp = merge(factor(temp,0.70),factor(opts[0],0.30));   // either opts[0] contains regular attack at this point,
            temp.id = thisid;                                                               // we don't actually want "attack" in the ID
            temp.rounds = 1;
            addopt(temp,0,0.7*mp_cost(to_skill(sk)));                                       // or you are in Jarlsberg and can't use familiars
            return;
      }
      addopt(temp,rate,mp_cost(to_skill(sk)));
   }
   string skillsbit = excise(page,"select a skill","Use Skill");
   if (skillsbit.length() > 0) {                                                        // if the page contains a skill dropdown, only consider those skills
      matcher oneskill = create_matcher("value=\"?(\\d+)",skillsbit); int sdex;
      while (oneskill.find()) {
         sdex = to_int(oneskill.group(1));
         if (factors["skill"] contains sdex) add_skill(sdex,factors["skill",sdex]);
      }
   } else foreach i,f in factors["skill"] if (have_skill(to_skill(i))) add_skill(i,f);  // otherwise add all batfactors skills that you have_skill
}

void build_options() {
   vprint("Building options...",9);
   clear(opts);
   fvars["monsterhp"] = monster_stat("hp");
   fvars["monsterattack"] = monster_stat("att");
   fvars["monsterdefense"] = monster_stat("att");
   fvars["buffedmys"] = my_stat("Mysticality");
   fvars["buffedmus"] = my_stat("Muscle");
   fvars["buffedmox"] = my_stat("Moxie");
   fvars["maxhp"] = my_maxhp();
   fvars["myhp"] = my_stat("hp");
   fvars["mymp"] = my_stat("mp");
   fvars["myfury"] = my_fury();
   fvars["weasel"] = to_int(have_skill($skill[thirst of the weasel]));
   fvars["shoulder"] = have_skill($skill[cold shoulder]) ? 5 : 0;
   fvars["momentum"] = my_discomomentum();
   if (my_class() == $class[avatar of sneaky pete]) fvars["audience"] = my_audience();
   fvars["accordion"] = item_type(equipped_item($slot[weapon])) == "accordion" ? 1 : 0;
  // 1. add regular
   if (!(blacklist contains "attack") && (have_effect($effect[more like a suckrament]) == 0 || round + equipped_amount($item[mer-kin prayerbeads]) > 8)) {
      addopt(merge(to_event("attack",regular(1),to_spread(0),"",1),onhit),0,0);
      opts[0] = merge(opts[0],factor(fumble(),fumble_chance()),factor(oncrit,critchance()));         // fumble and crit not factored by hitchance
      opts[0] = merge(opts[0],to_event("",to_spread(max(1,0.075*get_power(equipped_item($slot[weapon]))),   // glancing blows
         1.0-hitchance("attack")-fumble_chance()),to_spread(0),""));
   }
  // 2. get jiggy with it
   if (item_type(equipped_item($slot[weapon])) == "chefstaff" && contains_text(page,"chefstaffform") &&
       !happened("jiggle") && factors["chef"] contains to_int(equipped_item($slot[weapon])) && !(blacklist contains "jiggle")) {
      int stf = to_int(equipped_item($slot[weapon]));
      void chkstf(string prop) { if (to_int(get_property(prop)) > 4) stf -= 6000; }
      switch (stf) {
         case 6259: chkstf("_jiggleLife"); break;
         case 6261: chkstf("_jiggleCheese"); break;
         case 6263: chkstf("_jiggleSteak"); break;
         case 6265: chkstf("_jiggleCream"); break;
      }
      if (isseal) factors["chef",stf].dmg = "1";
      addopt(to_event("jiggle",factors["chef",stf],1),0,0);
   }
   cleareventscreated();
  // 3. add items
   if (noitems < 1.0) build_items();
   cleareventscreated();
  // 4. add skillz, yo
   if (noskills < 1.0 && have_effect($effect[temporary amnesia]) == 0 && 
       (have_effect($effect[more like a suckrament]) == 0 || round + equipped_amount($item[mer-kin prayerbeads]) > 8)) build_skillz();
  // 5. runaway
   addopt(to_event("runaway; repeat","custom runaway",1),runaway_cost(),0);
   cleareventscreated();
   sort opts by -to_profit(value);
   sort opts by kill_rounds(value.dmg)*-max(1,value.profit);
   vprint("Options built! ("+count(opts)+" actions)",9);
}

// retrieve specific or best-suited actions from opts

advevent stasis_action() {  // returns most profitable lowest-damage action
   boolean ignoredelevel = (smack.id != '' && kill_rounds(smack.dmg) == 1);
   sort opts by -to_profit(value,ignoredelevel);
   sort opts by -min(kill_rounds(value),max(0,maxround - round - 5));
   foreach i,opt in opts {  // skip multistuns, custom, and non-multi-usable items
      if (opt.custom != "" || opt.stun > 1 || (contains_text(opt.id,"use ") && !to_item(excise(opt.id,"use ","")).combat_reusable)) continue;
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
   sort opts by -value.profit;
   sort opts by -kill_rounds(value.dmg)*min(value.profit - 5,-5);   // insert arbitrary 5mu round cost
   foreach i,opt in opts {
      if (opt.custom != "" || kill_rounds(opt.dmg) > min(maxround - round - 1,drnd)) continue;   // reduce RNG risk for stasisy actions
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
   sort opts by -(value.profit-(value.stun == 0 ? 1000 : 0)+              // cheatily discount non-stunners
      meatperhp*m_dpr(-adj.att,0)*min(kill_rounds(smack.dmg)+count(custom),
        value.stun - 1 + to_int(foritem && have_skill($skill[ambidextrous funkslinging]) && contains_text(value.id,"use "))));
   foreach i,opt in opts {
      if (opt.custom != "" || opt.stun < 1-to_int(foritem && have_skill($skill[ambidextrous funkslinging]) && contains_text(opt.id,"use "))) continue;
      vprint("Stun action chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(opt.profit)+")",8);
      buytime = opt;
      return opt;
   }
   buytime = new advevent;
   return new advevent;
}
advevent custom_action(string type) {     // returns the cheapest custom action of the specified type
   sort opts by -value.profit;
   sort opts by -to_int(value.custom == type);
   if (opts[0].custom == type) return opts[0];
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
string act(string action);

// TODO: reject excess haiku katana skills
// adds action to queue, adjusts script state; returns false if unable to enqueue the action
boolean enqueue(advevent a) {     // handle inserts/auto-funk
   if (my_fam() == $familiar[he-boulder] && have_effect($effect[everything looks yellow]) == 0 && contains_text(page," yellow eye") && 
       contains_text(to_lower_case(vars["BatMan_yellow"]),to_lower_case(m.to_string())) && (count(custom) == 0 || die_rounds() <= 3)) {
      act(use_skill($skill[point at your opponent])); return true;
   }
   if (a.id == "") return vprint("Unable to enqueue empty action.",-8);  // allows if(enqueue())
   if (round + a.rounds > maxround + 3) return vprint("Can't enqueue '"+a.id+"': combat too long.",-8);  // allow to enqueue 3 rounds beyond combat limit
   if (my_stat("mp")+a.mp < 0) return vprint("Unable to enqueue '"+a.id+"': insufficient MP.",-7);  // everybody to the limit
  // attract gays
   boolean have_gays() { foreach i,ev in queue if (which_gays(ev.id) != $stat[none]) return true; if (which_gays(a.id) != $stat[none]) return true; return false; }
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
   if (have_skill($skill[ambidextrous funkslinging]) && count(queue) > 0 && m != $monster[the thorax] && bob.find()) {
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
   vprint("Setting monster to "+elmo+"...",9);
   m = elmo;
   if (m == $monster[none] && to_int(vars["unknown_ml"]) == 0)
      vprint("You would like to handle this unknown monster yourself. (unknown_ml is 0)",0);
  // values for formulas
   fvars["myhp"] = my_hp();
   fvars["monsterhp"] = monster_hp();
   fvars["famgear"] = to_int(equipped_item($slot[familiar]) == familiar_equipment(my_familiar()));
   fvars["spelldmgpercent"] = 1.0 + (numeric_modifier("Spell Damage Percent")/100.0);
   fvars["yuletide"] = to_int(have_effect($effect[yuletide mutations]) > 0);
   fvars["fweight"] = familiar_weight(my_familiar()) + numeric_modifier("Familiar Weight");
   switch (my_familiar()) {
      case $familiar[disembodied hand]: fvars["famgearpwr"] = get_power(familiar_equipped_equipment($familiar[disembodied hand])); break;
      case $familiar[nosy nose]: fvars["indread"] = to_int(my_location().zone == "Dreadsylvania"); break;
   }
   if (to_int(get_property("fistSkillsKnown")) > 0) fvars["fistskills"] = to_int(get_property("fistSkillsKnown"));
   if (have_skill($skill[intimidating bellow])) fvars["bellows"] = have_skill($skill[louder bellows]) ? 2 : 1;
   if (have_skill($skill[kneebutt])) fvars["pantspower"] = (have_skill($skill[tao of the terrapin])) ?
      get_power(equipped_item($slot[pants]))*2 : get_power(equipped_item($slot[pants]));
   if (have_skill($skill[headbutt])) fvars["helmetpower"] = (have_skill($skill[tao of the terrapin])) ?
      get_power(equipped_item($slot[hat]))*2 : get_power(equipped_item($slot[hat]));
   if (have_skill($skill[shieldbutt])) fvars["shieldpower"] = (item_type(equipped_item($slot[off-hand])) == "shield") ? get_power(equipped_item($slot[off-hand])) : 0;
   if (have_equipped($item[staff of queso escusado])) fvars["stinkycheese"] = to_int(get_property("_stinkyCheeseCount"));
   if (have_equipped($item[mer-kin hookspear])) fvars["monstermeat"] = to_float(my_path() == "Way of the Surprising Fist" ? max(meat_drop(m),12) : meat_drop(m));
   if (my_location().zone == "Dreadsylvania") { fvars["woodskisses"] = $location[dreadsylvanian woods].kisses; 
      fvars["villagekisses"] = $location[dreadsylvanian village].kisses; fvars["castlekisses"] = $location[dreadsylvanian castle].kisses; }
   if (have_skill($skill[disco face stab]) || have_skill($skill[knife in the dark]) || have_skill($skill[disco shank])) {
      fvars["bestknife"] = 0;
      foreach i in get_inventory() if (item_type(i) == "knife" && can_equip(i) && get_power(i) > fvars["bestknife"]) fvars["bestknife"] = get_power(i);
   }
  // set default monster attributes
   nomultistun = false; nomiss = false; nohit = false; nospells = false; isseal = false;
   howmanyfoes = 1; maxround = 30; damagecap = 0; capexp = 1; noitems = 0; noskills = 0; nostagger = 0;
   mvalcache = monstervalue();
   if (happened("use 5048")) mres = get_resistance($element[cold]);
    else mres = get_resistance(m.defense_element);
   if (happened("use 4603")) nomiss = true;
   load_factors();
  // special monster attributes
   void setmatt(string attr, string val) {
      switch (attr) {
         case "maxround": if (is_integer(val)) maxround = to_int(val); vprint("This combat may last up to "+rnum(maxround)+" rounds.",8); break;
         case "group": if (is_integer(val)) howmanyfoes = to_int(val); vprint("This monster is a group of "+rnum(howmanyfoes)+".",8); break;
         case "damagecap": if (is_integer(val)) damagecap = to_int(val); vprint("This monster has a damage cap of "+rnum(damagecap)+".",8); break;
         case "capexp": capexp = to_float(val); vprint_html("Damage in excess of the damage cap will be reduced to X<sup>"+rnum(capexp)+"</sup>.",8); break;
         case "nohit": nohit = vprint("This monster has no attack.",8); break;
         case "nomiss": nomiss = vprint("This monster never misses.",8); break;
         case "nostun": nostagger = to_int(vprint("This monster is immune to all stuns.",8)); break;  // deprecated
         case "nostagger": if (val != "") nostagger = minmax(to_float(val),0,1); if (nostagger == 0) nostagger = 1.0;
                           vprint("Staggers have a "+rnum(nostagger*100.0)+"% chance of being blocked.",8); break;
         case "nomultistun": nomultistun = vprint("This monster is immune to multiple-round stunners.",8); break;
         case "seal": isseal = vprint("This monster is a seal, and can only be damaged by clubs.",8); break;
         case "noitems": if (val != "") noitems = minmax(to_float(val),0,1); if (noitems == 0) noitems = 1.0;
                         vprint("Items have a "+rnum(noitems*100.0)+"% chance of being blocked.",8); break;
         case "noskills": if (val != "") noskills = minmax(to_float(val),0,1); if (noskills == 0) noskills = 1.0;
                          vprint("Skills have a "+rnum(noskills*100.0)+"% chance of being blocked.",8); break;
         case "nospells": nospells = vprint("This monster is immune to spells.",8); break;
         case "retal": if (weapon_type(equipped_item($slot[weapon])) == $stat[moxie]) break; onhit.pdmg = merge(onhit.pdmg,to_spread(val));
                       vprint_html("Hitting this monster will deal "+to_html(to_spread(val))+" damage to yourself.",8); break;
         default: vprint("Unknown keyword found: "+attr,-4);
      }
   }
   foreach i,mrec in (factors["monster"]) if (normalized(mrec.ufname,"monster") != mrec.ufname) vprint("Bad monster name supplied for monster "+i+" ("+mrec.ufname+")",-2);
    else if (mrec.ufname.to_monster() == m) {
      matcher monmat = create_matcher("([a-z!]+?)(?: (.+?))?(?:$|, )", mrec.special);
      while (monmat.find()) setmatt(monmat.group(1), group_count(monmat) == 2 ? monmat.group(2) : "");
      if (mrec.dmg.length() > 1 || mrec.dmg.to_int() > 0) foreach el,amt in to_spread(mrec.dmg) if (amt != 0) mres[el] = amt;
      break;
   }
   switch (m) {
     // TODO: reanimated skeletons resist everything except pottery
      case $monster[your shadow]: foreach te,it,rd in factors                // delete regular damage, add healing as damage
         factors[te,it].dmg = (rd.pdmg.length() > 1 && substring(rd.pdmg,0,1) == "-") ? substring(rd.pdmg,1) : "0"; break;
      case $monster[warbear officer]:
      case $monster[high-ranking warbear officer]:
         switch (excise(page," the "," Warbear")) {
            case "Hardened": foreach el in $elements[] mres[el] = 0.85; break;
            case "Heavily-Armored": setmatt("damagecap","5"); break;
            case "Poly-Phasic":  mres[$element[none]] = 0.85; break;
//          default: vprint("Unsupported warbear attribute: "+excise(page," the "," Warbear"),3);
         }
         matcher drone = create_matcher("wbdrone(\\d+)\\.gif",page);        // store drone number in fvars, checked by m_event
         if (drone.find()) { vprint("DRONE DETECTED: "+drone.group(1),4); fvars["wardrone"] = to_int(drone.group(1)); } break;
   }
   switch (my_location()) {
     case $location[The Tower of Procedurally-Generated Skeletons]:
       matcher skelatt = create_matcher("\\b([a-z]+?)\\b",excise(m,", the "," skeleton"));
       while (skelatt.find()) switch (skelatt.group(1)) {
          case "accurate": setmatt("nomiss",""); break;
          case "blazing": base.pdmg[$element[hot]] += my_maxhp()*0.2; break;
          case "charred": mres = get_resistance($element[hot]); break;
          case "dancing": setmatt("noitems",""); break;
          case "disorienting": setmatt("noskills","0.7"); break;
          case "foul": mres = get_resistance($element[stench]); break;
          case "frigid": base.pdmg[$element[cold]] += my_maxhp()*0.2; break;
          case "frozen": mres = get_resistance($element[cold]); break;
          case "ghostly": mres[$element[none]] = 1; break;
          case "greasy": mres = get_resistance($element[sleaze]); break;
          case "lascivious": base.pdmg[$element[sleaze]] += my_maxhp()*0.2; break;
          case "scary": mres = get_resistance($element[spooky]); break;
          case "shimmering": foreach el in $elements[] mres[el] = 1; break;
          case "terrifying": base.pdmg[$element[spooky]] += my_maxhp()*0.2; break;
          case "thorny": setmatt("retal","50"); break;   // arbitrarily chosen value; unspaded!
          case "unstoppable": setmatt("nostagger",""); break;
          case "shiny": setmatt("nospells",""); break;
          case "deadly": case "giant": case "nimble": case "thick": case "smelling":
          case "shifty": break;  // 'shifty' handled in hitchance
          default: vprint("Unsupported skeletal attribute: "+skelatt.group(1),"gray",3);                 // TODO: vicious deals bonus damage
       } break;
     case $location[Video Game Level 3]: 
       switch (get_property("gameProBossSpecialPower")) {
          case "Cold immunity": mres[$element[cold]] = 1; break;
          case "Cold aura": base.pdmg[$element[cold]] += 7; break;
          case "Hot immunity": mres[$element[hot]] = 1; break;
          case "Hot aura": base.pdmg[$element[hot]] += 7; break;
          case "Blocks combat items": setmatt("noitems",""); break;
          case "Reduced physical damage": mres[$element[none]] = 0.5; break;
          case "Stun resistance": setmatt("nostagger",""); break;
          case "Elemental Resistance": foreach el in $elements[] mres[el] = 0.3; break;
          case "Passive damage": onhit.pdmg[$element[none]] += 10;   // how much damage do the spikes do?
          default: vprint("Unsupported boss attribute: " + get_property("gameProBossSpecialPower"),"gray",3); // Ignores armor, Reduced damage from spells
      } break;
   }
  // account for +ML
   if (monster_level_adjustment() > 25) {
      float ml = min(monster_level_adjustment() * 0.004, 0.5);
      foreach res,amt in mres mres[res] = ml + amt - (ml * amt);
      if (monster_level_adjustment() > 50) {
         if (nostagger < 1) setmatt("nostagger", rnum(max(nostagger, (monster_level_adjustment() - 50) * 0.01)));
         if (monster_level_adjustment() > 100) setmatt("nomultistun","");
      }
   }   
   parse_factors();
  // initialize effects/gear
   fxngear();
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
   reset_queue();
   vprint_html("ATT: <b>"+rnum(monster_stat("att"))+"</b> ("+rnum(m_hit_chance()*100.0)+"% &times; "+to_html(m_regular())+
      ", death in "+die_rounds()+")<br>DEF: <b>"+rnum(monster_stat("def"))+"</b> ("+rnum(hitchance("attack")*100.0)+
      "% &times; "+to_html(regular(1))+", win in "+kill_rounds(to_event("attack",factor(regular(1),hitchance("attack")),
      to_spread(0),""))+")<br>HP: <b>"+rnum(monster_stat("hp"))+"</b>, Value: <b><span style='color:green'>"+
      rnum(mvalcache)+" "+entity_decode("&mu;")+"</span></b>, RES: "+to_html(mres),5);
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
            (get_property("serverAddsCustomCombat") == "true" && contains_text(action, "window.fightover = true")) ||
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
      case $familiar[frumious bandersnatch]: if (contains_text(action,"cloud of smust")) set_happened("smusted"); break;
      case $familiar[mini-hipster]: if (contains_text(action,"regular ol' creepy moustache") || contains_text(action,"ironic piggy-back ride") ||
         contains_text(action,"indie comic book")) set_happened("hipster_stats"); break;
   }
   foreach doodad,n in extract_items(contains_text(action,"Found in this fight:") ? excise(action,"","Found in this fight:") : action) {
      stolen[doodad] += n;
      if (contains_text(action,"grab something") || contains_text(action,"You manage to wrest") ||
         (my_class() == $class[disco bandit] && contains_text(action,"knocked loose some treasure."))) {
         vprint("You snatched a "+doodad+" ("+rnum(item_val(doodad))+entity_decode("&mu;")+")!","green",5);
         mvalcache = monstervalue();
         should_pp = vprint("Revised monster value: "+rnum(mvalcache),"green",-4);
         set_happened("stolen");
      } else vprint("Look! You found "+n+" "+doodad+" ("+rnum(n*item_val(doodad))+entity_decode("&mu;")+")!","green",5);
   }
   if (contains_text(action,"CRITICAL")) set_happened("crit");
   if (contains_text(action,"FUMBLE")) set_happened("fumble");
   if (contains_text(action,"monstermanuel.gif") && vprint("You got a factoid!","#8585FF",5)) set_happened("factoid");
   if (!nomultistun && contains_text(action,"Unfazed, your opponent attacks you anyway!") && 
      vprint("This monster is stun immune!  That information should be added to batfactors.","red",2)) nomultistun = true;
   if (have_equipped($item[operation patriot shield]) && happened($skill[throw shield]) && happened("crit")) set_happened("shieldcrit");
   if (have_equipped($item[bag o' tricks])) switch {
      case (happened($skill[open the bag o' tricks])): set_property("bagOTricksCharges","0"); break;
      case (contains_text(action,"Bag o' Tricks suddenly feels")): set_property("bagOTricksCharges","1"); break;
      case (contains_text(action,"Bag o' Tricks begins")): set_property("bagOTricksCharges","2"); break;
      case (contains_text(action,"Bag o' Tricks begins squirming")):
      case (contains_text(action,"Bag o' Tricks continues")): set_property("bagOTricksCharges","3"); break;
   }
   if (have_equipped($item[double-ice cap]) && contains_text(page,"solid, suffering")) set_happened("icecapstun");
   if (have_equipped($item[crown of thrones]) && have_equipped($item[buddy bjorn]) && create_matcher(my_enthroned_familiar().name+" and "+my_bjorned_familiar().name+
        " (are|ignore|argue|both roll for initiative and|do rock-paper|glance|glare|look|say |work)",page).find()) set_happened("buddymisfire");
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
   if (!($effects[none,toad in the hole] contains dangerpoison)) {
      cli_execute("whatif up "+dangerpoison+"; quiet");
      if (m_hit_chance() < 0.07 && kill_rounds(attack_action()) < maxround - round) dangerpoison = $effect[none];
   }
   cli_execute("whatif quiet");                     // reset spec in case it was used elsewhere
  // reactions
   if (my_location() == $location[the slime tube] && contains_text(action,"a massive loogie that sticks") &&
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
      case $monster[the server]: if (item_amount($item[strange goggles]) > 0 && contains_text(lastaction,"chrome input ports"))
         return act(throw_item($item[strange goggles])); break;
      case $monster[mer-kin balldodger]: case $monster[Georgepaul, the Balldodger]: if (!have_equipped($item[mer-kin dragnet])) break;
         switch (to_int(get_property("gladiatorNetMovesKnown"))) {
            case 3: if (contains_text(action,"take on an ominous")) return act(use_skill($skill[net neutrality])); 
            case 2: if (contains_text(action,"experience a serious")) return act(use_skill($skill[net loss]));
            case 1: if (contains_text(action,"exposed underbelly")) return act(use_skill($skill[net gain]));
         } break;
      case $monster[mer-kin netdragger]: case $monster[Johnringo, the Netdragger]: if (!have_equipped($item[mer-kin switchblade])) break;
         switch (to_int(get_property("gladiatorBladeMovesKnown"))) {
            case 3: if (contains_text(action,"attaches some sharp metal barbs")) return act(use_skill($skill[blade runner]));
            case 2: if (contains_text(action,"draws it back like a baseball bat")) return act(use_skill($skill[blade roller]));
            case 1: if (contains_text(action,"starts to fold his net up")) return act(use_skill($skill[blade sling]));
         } break;
      case $monster[mer-kin bladeswitcher]: case $monster[Ringogeorge, the Bladeswitcher]: if (!have_equipped($item[mer-kin dodgeball])) break;
         switch (to_int(get_property("gladiatorBallMovesKnown"))) {
            case 3: if (contains_text(action,"applies it to his switchblade")) return act(use_skill($skill[ball sack]));
            case 2: if (contains_text(action,"He pauses to wipe")) return act(use_skill($skill[ball sweat]));
            case 1: if (contains_text(action,"an especially dope move")) return act(use_skill($skill[ball bust]));
         } break;
      case $monster[Falls-From-Sky]: if (contains_text(lastaction,"begins to spin in a circle")) return act(use_skill($skill[hide under a rock]));
         if (contains_text(lastaction,"begins to paw at the ground")) return act(use_skill($skill[dive into a puddle]));
         if (contains_text(lastaction,"shuffles toward you")) return act(use_skill($skill[hide behind a tree])); break;
   }
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
   if (my_location() == $location[the slime tube]) res.append("if match \"a massive loogie\"; abort \"BatBrain abort: loogie.\"; endif; ");
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
      case $monster[the server]: if (item_amount($item[strange goggles]) == 0) break;
         res.append("if match \"chrome input ports\"; use 6118; endif; "); break;
      case $monster[mer-kin bladeswitcher]: case $monster[Ringogeorge, the Bladeswitcher]: if (have_equipped($item[mer-kin dodgeball]))
         res.append("while (match \"an especially dope move\" && hasskill 7085) || (match \"He pauses to wipe\" && hasskill 7086) || "+
         "(match \"applies it to his switchblade\" && hasskill 7087); if match \"an especially dope move\" && hasskill 7085; skill 7085; "+
         "endif; if match \"He pauses to wipe\" && hasskill 7086; skill 7086; endif; if match \"applies it to his switchblade\" && "+
         "hasskill 7087; skill 7087; endif; endwhile; "); break;  // bust, sweat, sack
      case $monster[mer-kin balldodger]: case $monster[Georgepaul, the Balldodger]: if (have_equipped($item[mer-kin dragnet])) 
         res.append("while (match \"exposed underbelly\" && hasskill 7088) || (match \"He gets a crazy look\" && hasskill 7089) || "+
         "(match \"take on an ominous\" && hasskill 7090); if match \"exposed underbelly\" && hasskill 7088; skill 7088; endif; if "+
         "match \"He gets a crazy look\" && hasskill 7089; skill 7089; endif; if match \"take on an ominous\" && hasskill 7090; "+
         "skill 7090; endif; endwhile; "); break;  // gain, loss, neutrality
      case $monster[mer-kin netdragger]: case $monster[Johnringo, the Netdragger]: if (have_equipped($item[mer-kin switchblade]))
         res.append("while (match \"starts to fold his net up\" && hasskill 7091) || (match \"draws it back like a baseball bat\" && "+
         "hasskill 7092) || (match \"attaches some sharp metal barbs\" && hasskill 7093); if match \"starts to fold his net up\" && hasskill "+
         "7091; skill 7091; endif; if match \"draws it back like a baseball bat\" && hasskill 7092; skill 7092; endif; if match \"attaches "+
         "some sharp metal barbs\" && hasskill 7093; skill 7093; endif; endwhile; "); break;  // sling, roller, runner
      case $monster[Falls-From-Sky (Hard Mode)]:
      case $monster[Falls-From-Sky]: res.append("if match \"begins to spin in a circle\"; skill 7161; endif; "+
         "if match \"begins to paw at the ground\"; skill 7160; endif; if match \"shuffles toward you\"; skill 7159; endif; "); break;
   }
   switch (my_fam()) {
      case $familiar[he-boulder]: if (have_effect($effect[everything looks yellow]) > 0 || !contains_text(to_lower_case(vars["BatMan_yellow"]),to_lower_case(m.to_string()))) break;
         if (count(custom) > 0 && die_rounds() > 3) break;
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
         r.append("if haseffect 297; abort \"Amnesiacs are unable to perform... whatever you were about to perform.\"; endif; ");
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
string BBver = check_version("BatBrain","batbrain",6445);
