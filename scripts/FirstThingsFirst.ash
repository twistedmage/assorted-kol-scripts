#/******************************************************************************
#                     First Things First 4.0 by Zarqon
#                 a nifty consult script to start your ccs
#*******************************************************************************
#
#   Handles things you might want to do before killing stuff:
#     - stealing (more than once if available)
#     - entangling stronger opponents
#     - olfaction
#     - puttying
#     - summoning pastamancer ghosts
#     - salving yourself if you need it
#     - using the insult book in the Barrr
#     - using putty on lobsterfrogmen
#     - using quest items against the Cyrpt mini-bosses
#     - casting creepy grin on selected monsters
#     - gets rid of poison if they happen to get you early on
#     - throwing flyers at everything and their moms
#     - definitely flyering Cyrus and the GMOB (otherwise handling those combats)
#     - driving away clingy pirates if you're not looking for clingfilm
#     - throwing decoys to get goal familiars in the Sea
#     - identifying bang potions and hidden city spheres
#
#   Have a suggestion to improve this script?  Visit
#   http://kolmafia.us/showthread.php?t=1255
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#******************************************************************************/
import <zlib.ash>
boolean famspent; boolean should_putty; boolean should_olfact; boolean should_pp;
int round; item stolen; item flyers;
if (item_amount($item[jam band flyers]) > 0) flyers = $item[jam band flyers];
else if (item_amount($item[rock band flyers]) > 0) flyers = $item[rock band flyers];
int hpgoal = round(to_float(get_property("hpAutoRecoveryTarget"))*to_float(my_maxhp()));
int hpmin = round(to_float(get_property("hpAutoRecovery"))*to_float(my_maxhp()));
typedef float[element] spread; spread mres;
float meatpermp, meatperhp;
if (get_property("_meatpermp") != "") meatpermp = to_float(get_property("_meatpermp"));
 else {
   if (my_primestat() == $stat[mysticality] || (my_class() == $class[accordion thief] && my_level() > 8))
      meatpermp = 100.0 / (1.5 * to_float(my_level()) + 5);            // first, mmj
    else if (have_outfit("Elite Guard")) meatpermp = 8;                // next, seltzer
     else meatpermp = 17 - to_int(galaktik_cures_discounted())*5;      // finally, galaktik
 }
if (get_property("_meatperhp") != "") meatperhp = to_float(get_property("_meatperhp"));
 else meatperhp = 10 - to_int(galaktik_cures_discounted())*4;          // galaktik base calc
float item_val(item i) {
   if (is_tradeable(i) && historical_price(i) > max(100,2*autosell_price(i))) return historical_price(i);
   return autosell_price(i);
}
float item_val(item i, float rate) {
   float modv = item_val(i) * minmax(rate*(item_drop_modifier()+100)/100.0,0,100)/100.0;
   vprint(i+" ("+rate+" @ +"+item_drop_modifier()+"): "+item_val(i)+" meat * "+minmax(rate*(item_drop_modifier()+100)/100.0,0,100)+"% = "+modv,8);
   return modv;
}
float monstervalue() {
   float res = to_float(meat_drop()) * (max(0,meat_drop_modifier()+100))/100.0;
   boolean skipped; should_pp = false;
   foreach num,rec in item_drops_array() {
      switch (rec.type) {
        // pp only
         case "p": if (my_primestat() != $stat[moxie] || stolen != $item[none]) break;
            res = res + item_val(rec.drop)*minmax(rec.rate*(numeric_modifier("Pickpocket Chance")+100)/100.0,0,100)/100.0;
            should_pp = true; break;
        // normal, pickpocketable
         case "": if (rec.drop == stolen && !skipped) { skipped = true; break; }
            if (stolen == $item[none] && rec.rate*(item_drop_modifier()+100)/100.0 < 100) should_pp = true;
        // filter conditional drops
         case "c": if (item_type(rec.drop) == "shirt" && !have_skill($skill[torso awaregness])) break; // skip shirts if applic
            if (!is_displayable(rec.drop)) break;                          // skip quest items
                                                                           // include the rest????
        // normal, no pp
         case "n": res = res + item_val(rec.drop,rec.rate);
      }
   }
   return res;
}
vprint("Monster value: "+rnum(monstervalue()),"green",4);

float mladj, stunadj;
if (monster_attack() == monster_level_adjustment()) mladj = to_int(vars["unknown_ml"]);
// adjusted monster stat (unknown_ml and current or projected +/-ML)
float monster_stat(string which) {
   switch (which) {
      case "att": return mladj + monster_attack();
      case "def": return mladj + monster_defense();
      case "hp": return mladj + monster_hp();
   } return 0;
}

boolean intheclear() {              // function rather than variable because it can change
   if (stunadj > 0.94) return true;
   if (last_monster() == $monster[none] || expected_damage() > my_hp() ||
       have_effect($effect[strangulated]) > 0) return false;
   return (monster_stat("att") < my_defstat() - 6 + to_int(vars["threshold"]));
}
//string turtleprop = "wereturtle_"+to_int(familiar_weight(my_familiar())+numeric_modifier("Familiar Weight"))+"lbs_"+moon_light()+"ML_";
//if (have_equipped($item[moontan lotion])) turtleprop = turtleprop + "moontan_";

string act(string action) {                                     // action filter
/*
  // spading wereturtle
   if (my_familiar() == $familiar[wereturtle] && contains_text(action,"turtle.gif\" ")) {
      if (contains_text(action,"moons, yawns"))
         print("Won't attack with only "+moon_light()+" moonlight!");
      else if (contains_text(action,"bite your opponent, but misses")) {
         set_avg(0.0,turtleprop+"hitrate");
      } else if (contains_text(action,"bites your opponent for ")) {
         set_avg(1.0,turtleprop+"hitrate");
         int tdmg = to_int(excise(action,"bites your opponent for <font color=gray><b>","</b></font> damage"));
         set_avg(tdmg,turtleprop+"dmg");
         if (to_int(get_property(turtleprop+"min")) == 0)
            set_property(turtleprop+"min",tdmg);
          else set_property(turtleprop+"min",min(tdmg,to_int(get_property(turtleprop+"min"))));
         set_property(turtleprop+"max",max(tdmg,to_int(get_property(turtleprop+"max"))));
      }
   }
*/
  // stop cases
   if (my_location() == $location[slime tube] && contains_text(action,"a massive loogie that sticks") &&
       equipped_item($slot[weapon]) == $item[none]) vprint("Your rusty weapon has been slimed!  Finish combat by yourself.",0);
   round = round + 1;
  // detections
   if (!famspent) switch (my_familiar()) {
      case $familiar[hobo monkey]: if (contains_text(action,"your shoulder, and hands you some Meat")) famspent = true; break;
      case $familiar[gluttonous green ghost]: if (!contains_text(action,"/ggg.gif") && !contains_text(action,"You quickly conjure a saucy salve")) {
            print("Your ghost is hongry.","olive"); famspent = true; } break;
      case $familiar[slimeling]: if (!contains_text(action,"/slimeling.gif") && !contains_text(action,"You quickly conjure a saucy salve")) {
            print("Your slimeling needs sating.","olive"); famspent = true; } break;
      case $familiar[spirit hobo]: if (contains_text(action,"Oh, Helvetica,") || contains_text(action,"millennium hands and shrimp.")) {
         print("Your hobo is now sober.  Sober hobo sober hobo.","olive");
         famspent = true; } break;
   }
   if (contains_text(action,"grab something") || contains_text(action,"You manage to wrest") ||
       (my_class() == $class[disco bandit] && contains_text(action,"knocked loose some treasure."))) {
      foreach doodad in extract_items(action) stolen = doodad;
      vprint_html("<span color='green'>You snatched 1 "+stolen+" ("+rnum(item_val(stolen))+" &mu;)!</span>",5);
      should_pp = vprint("Revised monster value: "+rnum(monstervalue()),"green",-4);
   }
   if (last_monster() == $monster[mother slime]) {
      if (contains_text(action,"ground trembles as Mother Slime shudders")) mres[$element[none]] = 1.0;
      if (contains_text(action,"Veins of purple shoot")) mres[$element[sleaze]] = 1.0;
      if (contains_text(action," a bluish tinge")) mres[$element[cold]] = 1.0;
      if (contains_text(action,"skin becomes ashy and gray")) mres[$element[spooky]] = 1.0;
      if (contains_text(action,"Mother Slime becomes decidedly more reddish")) mres[$element[hot]] = 1.0;
      if (contains_text(action,"looks greener than she did a minute ago")) mres[$element[stench]] = 1.0;
   }
  // reactions
   if (item_amount($item[molybdenum magnet]) > 0 && contains_text(to_string(last_monster()),"Gremlin") && contains_text(action,"whips") &&
       (contains_text(action,"a hammer") || contains_text(action,"a crescent wrench") ||      // gremlin has tool
        contains_text(action,"pliers") || contains_text(action,"a screwdriver")))
      return act(throw_item($item[molybdenum magnet]));
   if (have_equipped($item[ruby rod]) && my_location() == $location[seaside megalopolis] &&   // monster has disc
       (contains_text(action,"lit match") || contains_text(action,"liquid nitrogen") || contains_text(action,"freaky alien thing") ||
        contains_text(action,"vile-smelling, milky-white") || contains_text(action,"tubular appendage")))
      return act(attack());
   if (my_class() == $class[disco bandit] && have_skill($skill[gothy handwave]) && my_mp() > 0) {
      switch (last_monster()) {                               // learn dance skills from DB nemesis enemies
         case $monster[breakdancing raver]: if (!have_skill($skill[break it on down]) && contains_text(action,"he raver drops "))
            return act(use_skill($skill[gothy handwave])); break;
         case $monster[pop-and-lock raver]: if (!have_skill($skill[pop and lock it]) && contains_text(action,"movements suddenly became spastic and jerky."))
            return act(use_skill($skill[gothy handwave])); break;
         case $monster[running man]: if (!have_skill($skill[run like the wind]) && contains_text(action,"The raver turns "))
            return act(use_skill($skill[gothy handwave]));
      }
   }
   if (my_familiar() == $familiar[he-boulder] && get_counters("Major Yellow Recharge",1,150) == "" &&
       contains_text(action," yellow eye") && contains_text(to_lower_case(vars["ftf_yellow"]),to_lower_case(last_monster().to_string())))
      return act(use_skill($skill[point at your opponent]));
   return action;
}

boolean should_summon_ghost() {
   if (my_adventures() < 2*((10 + (5*to_int(have_item($item[bandolier of the spaghetti elemental]) > 0))) - to_int(get_property("pastamancerGhostSummons"))))
      return vprint("Running out of adventures to use your summons.  Summoning...",4);  // don't waste daily summonses
   int glevel = minmax(floor(square_root(to_float(get_property("pastamancerGhostExperience")))),1,10);
   switch (get_property("pastamancerGhostType")) {
      case "Angel Hair Wisp": return expected_damage() < glevel + 10;
      case "Boba Fettucini": if (glevel == 10)
          return (!should_olfact && !should_putty &&
            monster_attack($monster[giant sandworm]) < my_defstat() - 6 + to_int(vars["threshold"]));
          return (!intheclear());
      case "Bow Tie Bat": if (glevel == 10)
          return (count(item_drops()) > 0);
          return (!intheclear());
      case "Lasagmbie": return (meat_drop() > 10 && monster_element() != $element[spooky]);
      case "Penne Dreadful": if (glevel == 10)
          return (count(item_drops()) > 0);
          if (glevel > 4)
             foreach thingy,num in item_drops() if (item_type(thingy) == "food" && num < 90) return vprint("This monster drops food! Summoning...",4);
          foreach thingy,num in item_drops() if (item_type(thingy) == "booze" && num < 90) return vprint("This monster drops booze! Summoning...",4);
          return false;
      case "Spaghetti Elemental": return (!intheclear());
      case "Spice Ghost": return (!intheclear() || get_property("pastamancerGhostSummons") == "0");
      case "Undead Elbow Macaroni": return (!intheclear() && monster_element() != $element[spooky]);
      case "Vampieroghi": if (my_hp() <= round(to_float(get_property("hpAutoRecovery"))*to_float(my_maxhp()))) return true;
          int suckyamount = 4*(glevel + 1);
          if (glevel == 10) suckyamount = 50;
          if (glevel > 4)
             return (my_maxhp() - my_hp() > suckyamount || my_maxmp() - my_mp() > suckyamount);
          return (my_maxhp() - my_hp() > suckyamount);
      case "Vermincelli": if (glevel > 4 && (have_effect($effect[beaten up]) > 0 || have_effect($effect[cunctatitis]) > 0))
            return vprint("You can remove a negative effect! Summoning...",4);
          return (!intheclear());
      default: return false;
   }
}

string jump_action(string page) {
   if (intheclear() && (should_pp || monster_attack() == monster_level_adjustment()))
      while (contains_text(page,"form name=steal")) page = act(steal());
   if (my_class() == $class[pastamancer] && contains_text(page,"form name=summon") && should_summon_ghost())
      return act(visit_url("fight.php?action=summon"));
   return page;
}

string try_skill(string page, skill tocast) {
   if ((have_skill(tocast) || contains_text(page,to_string(tocast))) && my_mp() >= mp_cost(tocast)) {
      if (tocast == $skill[lasagna bandages]) return act(visit_url("fight.php?action=skill&whichskill=3009"));
      else return act(use_skill(tocast));
   }
   return page;
}

int bountysize = 0;
void set_autoputtifaction() {
   if (last_monster() == $monster[none]) return;
  // first, transparency with mafia settings
  print("should_putty1="+should_putty,"blue");
   if (to_monster(excise(get_property("autoOlfact"),"monster ","")) == last_monster()) should_olfact = true;
   if (to_monster(excise(get_property("autoPutty"),"monster ","")) == last_monster()) should_putty = true;
  print("should_putty2="+should_putty,"blue");
   if (item_drops() contains to_item(excise(get_property("autoOlfact"),"item ",""))) should_olfact = true;
   if (item_drops() contains to_item(excise(get_property("autoPutty"),"item ",""))) should_putty = true;
  print("should_putty3="+should_putty,"blue");
   if (should_putty && should_olfact) return;
  // second, set puttifaction for bounty monsters
   item ihunt = to_item(to_int(get_property("currentBountyItem")));
   if (ihunt != $item[none]) {
      record _bounty {
         int amount;
         location where;
         int safemox;
      };
      _bounty[item] bounty;
      if (!load_current_map("bounty",bounty)) { vprint("Unable to load bounty.txt.  Skipping auto-puttying/olfaction.","olive",-2); return; }
      bountysize = bounty[ihunt].amount;
      if (item_drops() contains ihunt && (
          (my_location() != $location[fun house] && my_location() != $location[goatlet] &&
           my_location() != $location[ninja snowmen] && my_location() != $location[laboratory]) ||
          (contains_text(to_lower_case(vars["ftf_olfact"]),to_lower_case(last_monster().to_string()))))) {
         if (bountysize <= to_int(vars["puttybountiesupto"]) && item_amount(ihunt) < bountysize-1) should_putty = true;
  print("should_putty4="+should_putty,"blue");
         should_olfact = true;
      } else if (contains_text(to_lower_case(vars["ftf_olfact"]),to_lower_case(last_monster().to_string())) && bounty[ihunt].where != my_location())
         should_olfact = true;
      bounty.clear();
   } else if (contains_text(to_lower_case(vars["ftf_olfact"]),to_lower_case(last_monster().to_string()))) should_olfact = true;
  // next, handle effective goal-getting (this only olfacts if you set "goals" for autoOlfact)
   monster bestm;
   float bestr, temp;
   int sources;
   foreach i,m in get_monsters(my_location()) {
      temp = has_goal(m);
      if (temp > 0) sources = sources + 1;
      if (temp > bestr) { bestm = m; bestr = temp; }
   }
   if (bestr == 0) return;
   print(sources+"/"+count(get_monsters(my_location()))+" monsters drop goals here.");
   if (bestm == last_monster()) {
      vprint("This monster is the best source of goals ("+rnum(bestr)+")!","green",3);
      if (get_property("autoOlfact").contains_text("goals")) should_olfact = true;
      if (get_property("autoPutty").contains_text("goals")) should_putty = true;
   }
}

string handle_olfaction(string page) {
   if (have_effect($effect[on the trail]) > 0) return page;
   if (should_olfact) return try_skill(page,$skill[transcendent olfaction]);
   return page;
}

string handle_putty(string page) {
	  print("about to handle putty","blue");
   if (item_amount($item[spooky putty sheet]) == 0 || to_int(get_property("spookyPuttyCopiesMade")) == 5) return page;
	  print("checking should_putty","blue");
   if (should_putty ||
//       (my_location() == $location[guards' chamber] && have_effect($effect[fithworm drone stench]) == 1) ||
       (last_monster() == $monster[lobsterfrogman] && get_property("sidequestLighthouseCompleted") == "none" &&
       item_amount($item[barrel of gunpowder]) < 4)) {
      if (bountysize > 0) should_olfact = (bountysize >= 5 - to_int(get_property("spookyPuttyCopiesMade")));
	  print("about to throw putty","blue");
      return act(throw_item($item[spooky putty sheet]));
   }
   return page;
}

string handle_grin(string page) {
   if (contains_text(to_lower_case(vars["ftf_grin"]),to_lower_case(last_monster().to_string()))) {
      if (contains_text(page,"Creepy Grin (")) return try_skill(page,$skill[creepy grin]);
      if (contains_text(page,"Give Your Opponent the Stinkeye (")) return try_skill(page,$skill[give your opponent the stinkeye]);
   }
   return page;
}

string use_special_item(string page) {    // mostly doesn't support funkslinging
   if (flyers != $item[none] && to_boolean(vars["flyereverything"]) && get_property("flyeredML").to_int() < 10000 &&
       my_location() != $location[battlefield (hippy uniform)] && my_location() != $location[battlefield (frat uniform)] &&
       my_location() != $location[haunted bathroom] && my_location() != $location[primordial soup])
     act(throw_item(flyers));
   string flyerboss(item special) {       // handles flyering / mirror/basepair-ing Cy and GMoB (supports funkslinging)
      if (flyers != $item[none]) {
         if (item_amount(special) > 0) {
            if (have_skill($skill[ambidextrous funkslinging]))
               return act(throw_items(flyers,special));
            act(throw_item(flyers));
            return act(throw_item(special));
         }
         act(throw_item(flyers));
         return act(runaway());
      }
      if (special == $item[none]) vprint("You don't have any base pairs that you haven't already used against Cy.  Whatcha gonna do?",0);
      if (item_amount(special) > 0) return act(throw_item(special));
      vprint("You have neither flyers nor mirror/base pair.  Whatcha gonna do?",0); return "";
   }
   item basepair() {
      string prop = get_property("usedAgainstCyrus");
      for i from 4011 to 4016
         if (item_amount(to_item(i)) > 0 && !contains_text(prop,to_item(i))) {
            if (prop == "" || index_of(prop,"memory") == last_index_of(prop,"memory"))
               set_property("usedAgainstCyrus",prop+to_item(i));
              else set_property("usedAgainstCyrus","");
            return to_item(i);
         }
      return $item[none];
   }
   switch (last_monster()) {
      case $monster[clingy pirate]: if (item_amount($item[cocktail napkin]) > 0) {
         boolean clinggoal;
         for i from 2988 to 2992 if (is_goal(to_item(i))) { clinggoal = true; break; } // only throw cocktail napkin if clingfilm items are not goals
         if (!clinggoal) return act(throw_item($item[cocktail napkin]));
      }
      case $monster[conjoined zmombie]: while (item_amount($item[half-rotten brain]) > 0)
         page = act(throw_item($item[half-rotten brain])); break;
      case $monster[cyrus the virus]: return flyerboss(basepair());
      case $monster[dirty thieving brigand]: if (item_amount($item[meat vortex]) > 1)
         return act(throw_item($item[meat vortex]));
      case $monster[gargantulihc]: if (item_amount($item[plus-size phylactery]) > 0)
         return act(throw_item($item[plus-size phylactery]));
      case $monster[giant skeelton]: while (item_amount($item[rusty bonesaw]) > 0)
         page = act(throw_item($item[rusty bonesaw])); break;
      case $monster[grouper groupie]: if (is_goal($item[grouper fangirl]) && item_amount($item[ice skate decoy]) > 0)
         page = act(throw_item($item[ice skate decoy])); break;
      case $monster[guy made of bees]: return flyerboss($item[antique hand mirror]);
      case $monster[huge ghuol]: while (item_amount($item[can of ghuol-b-gone]) > 0)
         page = act(throw_item($item[can of ghuol-b-gone])); break;
      case $monster[urchin urchin]: if (is_goal($item[urchin roe]) && item_amount($item[roller skate decoy]) > 0)
         page = act(throw_item($item[roller skate decoy])); break;
   }
	print("checking bang id","green");
  // ID bang potions: always ID multiples, ID singles only if mafia's autoPotionID
   if (my_level() > 5 && intheclear() && vprint("Checking for unidentified potions...",9))
      for i from 819 to 827
         if (get_property("lastBangPotion"+i) == "" && item_amount(to_item(i)) > to_int(get_property("autoPotionID") == "false"))
            page = act(throw_item(to_item(i)));
	print("checking sphere id","green");
  // ID spheres transparent with mafia's autoSphereID
   if (my_level() > 10 && get_property("autoSphereID") == "true" && intheclear())
   {
		print("Checking for unidentified spheres...","blue");
      for i from 2174 to 2177
         if (item_amount(to_item(i)) > 0 && get_property("lastStoneSphere"+i) == "")
            page = act(throw_item(to_item(i)));
	}		
   if (item_amount($item[the big book of pirate insults]) > 0 && contains_text(last_monster().to_string()," Pirate") &&
       monster_attack() - monster_level_adjustment() < 100) {
      int insultsknown = 0;
      for i from 1 to 8
         if (get_property("lastPirateInsult"+i) == "true") insultsknown = insultsknown + 1;
      if (insultsknown < 8) return act(throw_item($item[the big book of pirate insults]));
   }
   return page;
}

string clear_poison(string page) {
   if (get_property("autoAntidote") == "0") return page;
   int poison_level() {
      if (have_effect($effect[Toad In The Hole]) > 0) return 1;
      if (have_effect($effect[Majorly Poisoned]) > 0) return 2;
      if (have_effect($effect[Really Quite Poisoned]) > 0) return 3;
      if (have_effect($effect[Somewhat Poisoned]) > 0) return 4;
      if (have_effect($effect[A Little Bit Poisoned]) > 0) return 5;
      if (have_effect($effect[Hardly Poisoned at All]) > 0) return 6;
      return 100;
   }
   if (poison_level() != 100) vprint("Poison level: "+poison_level()+" (set to remove if "+get_property("autoAntidote")+" or lower)","olive",2);
   if (item_amount($item[anti-anti-antidote]) > 0 && poison_level() <= to_int(get_property("autoAntidote")))
      return act(throw_item($item[anti-anti-antidote]));
   return page;
}

string ftf(string page) {
	print("ftf called","green");
   if (last_monster() == $monster[none] && to_int(vars["unknown_ml"]) == 0)
      vprint("You would like to handle this unknown monster yourself. (unknown_ml is 0)",0);
   handle_grin(page);
   set_autoputtifaction();
   if (contains_text(page,"You get the jump ")) page = jump_action(page);
   if (!intheclear() || (to_boolean(vars["flyereverything"]) && flyers != $item[none] && get_property("flyeredML").to_int() < 10000) ||
   (contains_text(last_monster().to_string()," Pirate") && item_amount($item[the big book of pirate insults]) > 0))
      page = try_skill(page,$skill[entangling noodles]);
   page = handle_putty(page);
   page = handle_olfaction(page);
	print("use special items pre","green");
   page = use_special_item(page);
  // safe helper skills
   if (my_hp() < expected_damage() || min(hpgoal - my_hp(),12)*meatperhp > mp_cost($skill[saucy salve])*meatpermp)
      page = try_skill(page,$skill[saucy salve]);
   clear_poison(page);
   if(have_equipped($item[mayfly bait necklace]) && count(item_drops()) > 0) //if mob drops stuff and i have necklace on, sumon flies
	{
		page= use_skill($skill[Summon Mayfly Swarm]);
	}
//   while (my_familiar() == $familiar[wereturtle] && round < 27)
//     page = act(throw_item($item[facsimile dictionary]));
   return page;
}

setvar("flyereverything",true);
setvar("puttybountiesupto",19);
setvar("ftf_olfact","blooper, dairy goat, shaky clown, some zombie waltzers, goth giant, knott yeti, hellion, violent fungus");
setvar("ftf_grin","procrastination giant");
setvar("ftf_yellow","killer clownfish");

check_version("First Things First","FTF","4.0",1255);
void main(int initround, monster foe, string url) {
   round = initround;                               // make round global
   ftf(url);
   print("ftf finished","green");
}