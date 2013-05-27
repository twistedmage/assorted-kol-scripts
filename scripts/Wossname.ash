#/******************************************************************************
#                     One-Click Wossname 1.5 by Zarqon
#*******************************************************************************
#
#   One-Click Wossname automatically detects your progress in obtaining the
#   Wossname, and gets the Wossname for you if possible.  It's also customisable
#   using map files to define the order you do things.  Thus, it can also be
#   used as a general IsleWar script.  It works in both SC and HC.
#
#   For more information, to make suggestions, or to report bugs, visit
#   http://kolmafia.us/showthread.php?t=960
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#   CREDIT: thanks to Hippymon, Crowther, iniquitous, Miser, degrassi,
#   Mighty Xerxes, the_tom77, dj_d, and Rinn for contributing in various ways.
#
#******************************************************************************/
script "Wossname.ash";
import <zlib.ash>
string this_version = "1.5.8";

// wears the appropriate war attire
void dress_apropos(boolean hippy_frat) {
   if (hippy_frat) outfit("War Hippy Fatigues"); else outfit("Frat Warrior Fatigues");
}

// turns in your items for dimes/quarters; converts coins to meat if change_to_meat
boolean turn_stuff_in(boolean getmeat) {
   int camp = 1;
   string whichcoin = "Dimes";
   dress_apropos(true);
  // turns amount of which into camp for change
   void item_turnin(int amount, item which) {
      int totrade = 0;
      if (amount < 0) totrade = item_amount(which) + amount;
        else if (amount > 0) totrade = item_amount(which);
      if (totrade > 0) {
         print("Turning in "+totrade+" "+to_string(which)+"...");
         visit_url("bigisland.php?action=turnin&pwd=&whichcamp="+camp+"&whichitem="+to_int(which)+"&quantity="+to_string(totrade));
      }
   }
  // buys as many of which as you can from camp
   void maxbuy_item(item which, int cost) {
      int change = to_int(get_property("available"+whichcoin));
      int howmany = floor(change / cost);
      if (howmany > 0) {
         print("Buying "+howmany+" "+to_string(which)+"...");
         visit_url("bigisland.php?action=getgear&whichcamp="+camp+"&whichitem="+to_int(which)+"&pwd&quantity="+howmany);
      } else print("Unable to buy any "+to_string(which),"olive");
   }

  // Adjust the numbers as you like. -n means all but n, 0 means none, >0 means all

//-------------- hippy items ---------------------
   item_turnin( 1, $item[red class ring]);
   item_turnin( 1, $item[blue class ring]);
   item_turnin( 1, $item[white class ring]);
   item_turnin(-1, $item[beer helmet]);
   item_turnin(-1, $item[distressed denim pants]);
   item_turnin(-1, $item[bejeweled pledge pin]);
   item_turnin(-1, $item[PADL Phone]);
   item_turnin(-1, $item[kick-ass kicks]);
   item_turnin(-1, $item[perforated battle paddle]);
   item_turnin(-1, $item[bottle opener belt buckle]);
   item_turnin(-1, $item[keg shield]);
   item_turnin(-2, $item[giant foam finger]);
   item_turnin(-2, $item[war tongs]);
   item_turnin(-1, $item[energy drink IV]);
   item_turnin(-1, $item[Elmley shades]);
   item_turnin(-1, $item[beer bong]);
  // exchange your dimes for meat if you've set the option
   if (getmeat) {
      maxbuy_item($item[fancy seashell necklace], 5);
      maxbuy_item($item[water pipe bomb], 1);
   }
   camp = 2; whichcoin = "Quarters"; dress_apropos(false);
//-------------- frat items ----------------------
   item_turnin( 1, $item[pink clay bead]);
   item_turnin( 1, $item[purple clay bead]);
   item_turnin( 1, $item[green clay bead]);
   item_turnin(-1, $item[bullet-proof corduroys]);
   item_turnin(-2, $item[round purple sunglasses]);
   item_turnin(-1, $item[reinforced beaded headband]);
   item_turnin(-1, $item[hippy protest button]);
   item_turnin(-1, to_item("Lockenstock"));
   item_turnin(-2, $item[didgeridooka]);
   item_turnin(-1, $item[wicker shield]);
   item_turnin(-2, $item[lead pipe]);
   item_turnin(-2, $item[fire poi]);
   item_turnin(-1, $item[communications windchimes]);
   item_turnin(-1, $item[Gaia beads]);
   item_turnin(-1, $item[hippy medical kit]);
   item_turnin(-1, $item[flowing hippy skirt]);
   item_turnin(-2, $item[round green sunglasses]);
  // exchange your quarters for meat if you've set the option
   if (getmeat) {
      maxbuy_item($item[commemorative war stein], 5);
      maxbuy_item($item[beer bomb], 1);
   }
   if (getmeat) {
      int prior_meat = my_meat();
      cli_execute("autosell * commemorative war stein; autosell * fancy seashell necklace");
      if (my_meat() > prior_meat) print("You gained "+(my_meat()-prior_meat)+" meat!");
   }
   return (to_int(get_property("availableDimes")) + to_int(get_property("availableQuarters")) == 0);
}

// set global variables
record onestep {
   boolean hippy_frat;
   string checkprop;
   string checktext;
};
int step;
string previous_battleaction = get_property("battleAction");
familiar previous_familiar = my_familiar();
onestep [int] plan;
boolean is_wossname_plan;
boolean includes_hippy = false;
boolean includes_frat = false;
boolean arena_is_frat = false;
setvar("ocw_warplan","simoptimal");
setvar("ocw_change_to_meat",true);      // IF TRUE: will use your quarters/dimes to maxbuy and sell 1000-meat-autosell items
                                        // IF FALSE: will break for you to go spend your change yourself.
setvar("ocw_nunspeed",false);
setvar("ocw_f_default",$familiar[ninja pirate zombie robot]);
setvar("ocw_m_default","");
setvar("ocw_f_arena","");
setvar("ocw_o_arena","");
setvar("ocw_m_arena","");
setvar("ocw_f_lighthouse","jumpsuited hound");
setvar("ocw_o_lighthouse","anti-gremlin");
setvar("ocw_m_lighthouse","");
setvar("ocw_f_junkyard","");
setvar("ocw_o_junkyard","anti-gremlin");
setvar("ocw_m_junkyard","");
setvar("ocw_f_farm","");
setvar("ocw_o_farm","");
setvar("ocw_m_farm","");
setvar("ocw_o_orchard","");
setvar("ocw_m_orchard","");
setvar("ocw_o_nuns","");
setvar("ocw_m_nuns","");

// modified abort(), resets settings before aborting
void die(string die_message) {
   print(die_message,"red");
   print("Restoring initial settings...");
   set_property("battleAction",previous_battleaction);
   use_familiar(previous_familiar);
   cli_execute("outfit checkpoint");
   print("OCW stopped.");
   exit;
}

// chooses the appropriate familiar/outfit/mood for the current step
boolean gearup_apropos() {
   familiar chosen_f = to_familiar(vars["ocw_f_default"]);
   if (to_familiar(vars["is_100_run"]) == $familiar[none] && !have_familiar(chosen_f))
      die("You have specified a default familiar that you don't have! ('"+vars["ocw_f_default"]+"')");
   string chosen_o; string chosen_m;
   string qname = to_lower_case(excise(plan[step].checkprop,"quest","Comp"));
   if (qname != "") {
      chosen_o = vars["ocw_o_"+qname];
      chosen_m = vars["ocw_m_"+qname];
      if (qname != "nuns" && qname != "orchard") {
         chosen_f = to_familiar(vars["ocw_f_"+qname]);
         if (chosen_f == $familiar[none]) chosen_f = best_fam(vars["ocw_f_"+qname]);
      }
   }
   switch (plan[step].checkprop) {
      case "sidequestNunsCompleted": if (to_boolean(vars["ocw_nunspeed"])) chosen_f = best_fam("meat"); else chosen_f = best_fam("produce"); break;
      case "sidequestOrchardCompleted": chosen_f = best_fam("items"); break;
      case "sidequestFarmCompleted": if (vars["ocw_f_farm"] == "") chosen_f = best_fam("items");
   }
   if (chosen_f == $familiar[none] || !have_familiar(chosen_f)) chosen_f = to_familiar(vars["ocw_f_default"]);
   if (to_familiar(vars["is_100_run"]) != $familiar[none] && chosen_f != to_familiar(vars["is_100_run"]))
      chosen_f = to_familiar(vars["is_100_run"]);
   if (chosen_o == "") chosen_o = vars["defaultoutfit"];
   if (chosen_m == "") chosen_m = vars["ocw_m_default"];
   cli_execute("mood "+chosen_m+"; mood execute");
   use_familiar(chosen_f);
   print("equipping outfit "+chosen_o,"green");
   return (outfit(chosen_o));
}

// checks step which and returns true if complete
boolean check_step(int which) {
   if (which >= count(plan)) return false;
   if (contains_text(plan[which].checkprop,"Defeated"))
      return (to_int(get_property(plan[which].checkprop)) >= to_int(plan[which].checktext));
   return (get_property(plan[which].checkprop) != "none");
}

// determines and sets the current step of the warplan
void set_step(boolean show) {
   if (show) print("Verifying Wossname progress...");
   for i from 0 to count(plan)
      if (!check_step(i)) {
         step = i;
         break;
      }
   if (show) print("Current step: "+step);
}

// sets some important variables about the plan, to avoid repeatedly parsing the plan
void load_plan(string whichplan) {
	print("loading warplan: "+whichplan,"blue");
   if (!file_to_map(whichplan+".txt",plan)) die("Error loading warplan.");
   if (count(plan) == 0) die("Warplan is corrupt. I mean, the file is.");
   print("\""+whichplan+".txt\" loaded ("+count(plan)+" steps).");
   int h = 0; int f = 0;
   for i from 0 upto (count(plan)-1) {
      if (plan[i].checkprop == "fratboysDefeated") f = to_int(plan[i].checktext);
      if (plan[i].checkprop == "hippiesDefeated") h = to_int(plan[i].checktext);
      if (plan[i].checkprop == "sidequestArenaCompleted")
         arena_is_frat = !plan[i].hippy_frat;
      if (plan[i].hippy_frat) includes_hippy = true;
      if (!plan[i].hippy_frat) includes_frat = true;
   }
   is_wossname_plan = (f == 999 && h == 999);
   set_step(false);
}

// completes the Organic Orchard sidequest
boolean orchard_sq() {
   print("Step "+step+": Organic Orchard sidequest","blue");
   visit_url("bigisland.php?place=orchard&action=stand&pwd=");
   if (have_effect($effect[heart of lavender]) == 0) use_upto(2,$item[lavender candy heart],true);
   if (have_effect($effect[cupcake of choice]) == 0) use_upto(1,$item[blue-frosted astral cupcake],false);
   if (have_effect($effect[blue tongue]) == 0) use_upto(1,$item[blue snowcone],false);
   if (have_effect($effect[peeled eyeballs]) == 0) use_upto(2,$item[knob goblin eyedrops],true);
   gearup_apropos();
   while (have_effect($effect[Filthworm Guard Stench]) == 0 && my_adventures()>0) {
      while (have_effect($effect[Filthworm Drone Stench]) == 0 && my_adventures()>0) {
         while (have_effect($effect[Filthworm Larva Stench]) == 0 && my_adventures()>0) {
            obtain(1, "filthworm hatchling scent gland", $location[hatching chamber]);
            if (!use(1, $item[filthworm hatchling scent gland])) print("You smell like a hatchling.","olive");
         }
         obtain(1, "filthworm drone scent gland", $location[feeding chamber]);
         if (!use(1, $item[filthworm drone scent gland])) print("You smell like a drone.","olive");
      }
      obtain(1, "filthworm royal guard scent gland", $location[guards' chamber]);
      if (!use(1, $item[filthworm royal guard scent gland])) print("You smell like a guard.","olive");
   }
   use_upto(1,$item[pink candy heart],false);
   obtain(1, "heart of the filthworm queen", $location[queen's chamber]);
   print("You still smell pretty bad.","olive");
   dress_apropos(plan[step].hippy_frat);
   visit_url("bigisland.php?place=orchard&action=stand&pwd=");
   visit_url("bigisland.php?place=orchard&action=stand&pwd=");
   return check_step(step);
}

// completes the Lighthouse sidequest
boolean lighthouse_sq() {
   print("Step "+step+": Lighthouse sidequest","blue");
  // visit the crazy bomb guy
   visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
  // improve combat likelihood
   cli_execute("uneffect fresh scent");
   if (have_skill(to_skill("Confrontation"))) cli_execute("cast 2 confrontation");
   if (have_skill(to_skill("Moose"))) cli_execute("cast 2 musk of the moose");
   if (have_effect($effect[hippy stench]) == 0) use_upto(2,$item[reodorant],true);
  // get those barrels (handles if your CCS puttifies manbearpigs- er, lobsterfrogmen)
   gearup_apropos();
   obtain(5, "barrel of gunpowder", $location[wartime sonofa beach]);
  // wrap things up and collect your reward
   dress_apropos(plan[step].hippy_frat);
   visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
   visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
   return check_step(step);
}

// completes the Our Lady of Perpetual Indecision sidequest
boolean ourlady_sq() {
   print("Step "+step+": Our Lady of Perpetual Indecision sidequest","blue");
   visit_url("bigisland.php?place=nunnery&action=nuns&pwd=");
  // gear/buff up
   int estimated_advs() {
      float result = (100000 - to_float(get_property("currentNunneryMeat"))) / (1000 + (10*meat_drop_modifier()));
      return ceil(result);
   }
   if (to_boolean(vars["ocw_nunspeed"])) {
      if (have_effect($effect[sinuses for miles]) == 0) use_upto(1,$item[mick's icyvapohotness inhaler],false);
      if (have_effect($effect[red tongue]) == 0) use_upto(1,$item[red snowcone],false);
      if (get_property("sidequestArenaCompleted") == "fratboy" && cli_execute("concert 2")) {}
      if (get_property("demonName2") != "" && cli_execute("summon 2")) {}
      use_upto(ceil((estimated_advs()-have_effect($effect[wasabi sinuses]))/10),$item[Knob Goblin nasal spray],true);
      use_upto(ceil((estimated_advs()-have_effect($effect[sticky fingers]))/10),$item[bag of cheat-os],false);
      use_upto(ceil((estimated_advs()-have_effect($effect[your cupcake senses are tingling]))/20),$item[pink-frosted astral cupcake],false);
      use_upto(ceil((estimated_advs()-have_effect($effect[heart of pink]))/10),$item[pink candy heart],true);
   }
   gearup_apropos();
   dress_apropos(plan[step].hippy_frat);
  // get that meat
   string url = "";
   while (my_adventures() > 0 && adventure(1,$location[themthar hills])) {
      print("Nunmeat retrieved: "+get_property("currentNunneryMeat"),"green");
      print("Estimated adventures remaining: "+estimated_advs(),"maroon");
      if (item_amount($item[meat vortex]) == 0 && can_interact() && !retrieve_item(estimated_advs(),$item[meat vortex]))
         print("Unable to get meat vortices.  No meat for you.");
   }
   visit_url("bigisland.php?place=nunnery");
   return check_step(step);
}

// completes the McMillicancuddy's Farm sidequest
boolean mcmillicancuddy_sq() {
   print("Step "+step+": McMillicancuddy's Farm sidequest","blue");
  // set choiceadvs to duck shortcut
   set_property("choiceAdventure147","3");
   set_property("choiceAdventure148","1");
   set_property("choiceAdventure149","2");
  // visit farmer mcmillicancuddy
   visit_url("bigisland.php?place=farm&action=farmer&pwd=");
   gearup_apropos();
  // use a chaos butterfly against a generic duck
   obtain(1, "chaos butterfly", $location[giant's castle]);
   string url;
   boolean altered = false;
   repeat {
      url = visit_url("adventure.php?snarfblat=137");
      if (contains_text(url,"Combat")) {
         throw_item($item[chaos butterfly]);
         altered = true;
         run_combat();
      } else adventure(1,$location[barn]);
   } until (altered || contains_text(url,"no more ducks here."));
  // clear the remaining areas
   if (altered) {
      if (have_effect($effect[fresh scent]) == 0) use_upto(1,$item[deodorant],true);
      adventure(my_adventures(),$location[barn]);
   }
   adventure(my_adventures(),$location[pond]);
   adventure(my_adventures(),$location[back 40]);
   adventure(my_adventures(),$location[other back 40]);
  // wrap things up and collect your reward
	dress_apropos(plan[step].hippy_frat);
   visit_url("bigisland.php?place=farm&action=farmer&pwd=");
   visit_url("bigisland.php?place=farm&action=farmer&pwd=");
   return check_step(step);
}

   boolean do_cy() {
      if (item_amount($item[memory of some delicious amino acids]) == 0) {
         set_property("choiceAdventure349","3");           // swim down
         obtain(1,"memory of some delicious amino acids",$location[primordial soup]);
      }
      if (use(1,$item[memory of some delicious amino acids])) {}
      set_property("choiceAdventure349","1");              // swim up
      if (get_property("cloverProtectActive" == "false") && retrieve_item(1,$item[ten-leaf clover])) {}
      obtain(3,"memory of some delicious amino acids",$location[primordial soup]);  // get acids/unlock the zone
      if (use(3,$item[memory of some delicious amino acids])) {}
      if (!obtain(1,"choiceadv",$location[primordial soup])) return false;  // fight Cy
      return (get_property("flyeredML").to_int() > 9999);
   }

// completes the Mysterious Island Arena sidequest
boolean arena_sq() {
   print("Step "+step+": Mysterious Island Arena sidequest","blue");
  // get flyers
   if (get_property("flyeredML").to_int() > 9999 || item_amount($item[jam band flyers]) + item_amount($item[rock band flyers]) == 0)
      visit_url("bigisland.php?place=concert&pwd=");
   if (check_step(step)) return true;
   if (item_amount($item[jam band flyers]) + item_amount($item[rock band flyers]) == 0)
      die("There was a problem acquiring the flyers for the Arena quest.");
   int estadvs(boolean gmobhits) {
      if (gmobhits) return ceil((5 - get_property("guyMadeOfBeesCount").to_int()) * (3 / (0.25 - combat_rate_modifier())));
      return ceil((10000 - get_property("flyeredML").to_int()) / (159.3 + monster_level_adjustment()));
   }
   boolean do_gmob() {
      print("Finding the Bee Man...");
      set_property("choiceAdventure105","3");     // say "guy made of bees"
      cli_execute("uneffect hippy stench");
      if (retrieve_item(1,$item[antique hand mirror])) {}
      if (have_effect($effect[fresh scent]) < estadvs(true) - 3) use_upto(round(estadvs(true)/10),$item[deodorant],true);
      gearup_apropos();
      while (to_int(get_property("guyMadeOfBeesCount")) < 5 && get_property("flyeredML").to_int() < 10000) {
         print("You need to say 'Guy made of bees' "+(5-to_int(get_property("guyMadeOfBeesCount")))+" more times.","blue");
         if (!obtain(1,"choiceadv",$location[haunted bathroom])) return false;
      }
      return (get_property("flyeredML").to_int() > 9999);
   }
   boolean do_hits() {
      if (!retrieve_item(1,$item[intragalactic rowboat])) die("You have not yet unlocked the Hole in the Sky!  Recommend doing that.");
      print("Hi ho, hi ho, it's off to the Hole we go...");
      set_location($location[hole in the sky]);
      while (get_property("flyeredML").to_int() < 10000 && adventure(1,$location[hole in the sky])) {
         print("Flyering complete: "+get_property("flyeredML")+" / 10000","blue");
         print("Estimated adventures remaining: "+estadvs(false),"maroon");
         if (item_amount($item[star hat]) == 0 && creatable_amount($item[star hat]) > 0 && create(1,$item[star hat])) {}
         if (item_amount($item[richard's star key]) == 0 && creatable_amount($item[richard's star key]) > 0 && create(1,$item[richard's star key])) {}
         if (my_adventures() == 0) die("Come back tomorrow for more of the same exciting flyering action!");
      }
      return (get_property("flyeredML").to_int() > 9999);
   }
   int choose_strategy() {
      print("Choosing strategy...");
      if (item_amount($item[empty agua de vida bottle]) > 0 && !contains_text(visit_url("questlog.php?which=2"),"Primordial Fear")) return 2;
       else print("You cannot use the Cyrus strategy.  Selecting another...");
      if (get_property("guyMadeOfBeesDefeated") == "true")
         return to_int(vprint("You've already defeated the guy made of bees, so... off to the flyering hole!",-2));
      int esthits = estadvs(false);
      print("GMoB estimated adventures: "+estadvs(true));
      print("HitS estimated adventures: "+esthits);
      if (in_hardcore() && available_amount($item[richard's star key]) + available_amount($item[star hat]) +
           available_amount($item[star crossbow]) + available_amount($item[star sword]) < 2) {
         print("Additional factor: star items needed");
         esthits = esthits - 20;
      }
      return to_int(estadvs(true) < esthits);
   }
   switch (choose_strategy()) {
      case 2: if (do_cy()) break; return vprint("Flyering Cy unsuccessful.",-2);
      case 1: if (do_gmob()) break; return vprint("Flyering GMoB unsuccessful.",-2);
      case 0: if (do_hits()) break; return vprint("Unable to complete flyering in the skyhole.",-2);
   }
   dress_apropos(plan[step].hippy_frat);
   visit_url("bigisland.php?place=concert&pwd=");
   return check_step(step);
}

// completes the junkyard sidequest
boolean junkyard_sq() {
   print("Step "+step+": Junkyard sidequest","blue");
  // returns the html from visiting yossarian
   string visit_yossarian(boolean dressup) {
      print("Visiting Yossarian...");
      if (dressup) dress_apropos(plan[step].hippy_frat);
      return visit_url("bigisland.php?action=junkman&pwd=");
   }
  // kick things off
   if (item_amount($item[molybdenum magnet]) == 0) visit_yossarian(true);
   if (have_effect($effect[purple tongue]) == 0) use_upto(1,$item[purple snowcone],true);
   if (have_effect($effect[purple tongue]) == 0) use_upto(1,$item[purple-frosted astral cupcake],true);
   gearup_apropos();
  // main loop
   string url;
   while (item_amount($item[molybdenum hammer]) + item_amount($item[molybdenum crescent wrench]) +
          item_amount($item[molybdenum pliers]) + item_amount($item[molybdenum screwdriver]) < 4) {
      if (my_adventures() == 0) die("You're fresh out of adventures.");
      if (get_property("currentJunkyardTool") == "") {
         url = visit_yossarian(false);
         if (contains_text(url,"the next shipment of cars")) return (check_step(step));
      }
      if (have_effect($effect[purple tongue]) == 0 && have_effect($effect[tiny bubbles in the cupcake]) == 0 &&
          have_effect($effect[heart of orange]) == 0)
         use_upto(1,$item[orange candy heart],true);
      print("getting "+get_property("currentJunkyardTool")+"...","blue");
      obtain(1,get_property("currentJunkyardTool"),to_location(get_property("currentJunkyardLocation")));
   }
   visit_yossarian(true);
   return (check_step(step));
}

// performs one kill on the battlefield
void slay_one() {
   if (have_effect($effect[beaten up]) > 0) abort("You need to un-beat yourself up before continuing.");
  // set location
   location where_to = $location[battlefield(frat uniform)];
   if (plan[step].hippy_frat) where_to = $location[battlefield(hippy uniform)];
  // slay one, using the xxxDefeated property to check for a kill
   int progressflag = to_int(get_property(plan[step].checkprop));
   int current = progressflag;
   while (current == progressflag) {
      if (my_adventures() == 0) return;
      adventure(1,where_to);
      current = to_int(get_property(plan[step].checkprop));
   }
  // print results and progress
   print("+"+(current - progressflag)+" "+plan[step].checkprop+" ( "+current+" / "+plan[step].checktext+" )","blue");
   print("Step "+step+" adventures remaining: "+((to_int(plan[step].checktext)-current)/(current-progressflag)),"maroon");
   string field = visit_url("bigisland.php");
   int i = index_of(field, "bfleft" );
   print("You are on Frat-slaying pic "+substring(field, i+6, i+8), "green");
   i = index_of(field, "bfright");
   print("You are on Hippy-slaying pic "+substring(field, i+7, i+9), "purple");
}

// completes step which
boolean do_step(int which) {
   print("Completing step "+which+" of "+count(plan)+"...");
   gearup_apropos();
   dress_apropos(plan[which].hippy_frat);
   wait(5);
   cli_execute("conditions clear");
   if (plan[which].checkprop == "sidequestOrchardCompleted") return orchard_sq();
   if (plan[which].checkprop == "sidequestLighthouseCompleted") return lighthouse_sq();
   if (plan[which].checkprop == "sidequestNunsCompleted") return ourlady_sq();
   if (plan[which].checkprop == "sidequestFarmCompleted") return mcmillicancuddy_sq();
   if (plan[which].checkprop == "sidequestJunkyardCompleted") return junkyard_sq();
   if (plan[which].checkprop == "sidequestArenaCompleted") return arena_sq();
   if (plan[which].hippy_frat) { print("Step "+step+" goal: "+plan[which].checktext+" fratboys slain.","blue"); }
      else print("Step "+step+" goal: "+plan[which].checktext+" hippies slain.","blue");
   while ((!check_step(which)) && (my_adventures() > 0)) slay_one();
   return (check_step(which));
}

// start the war, get the outfits
boolean start_war() {
   print("Checking for outfits...");
  // assure possession of fratboy fatigues if required
   if (includes_frat && !have_outfit("Frat Warrior Fatigues")) {
      if (!can_interact() || get_property("autoSatisfyWithMall") == "false") {
         if (!have_outfit("Filthy Hippy Disguise")) {
            obtain(1, "filthy knitted dread sack", $location[hippy camp]);
            obtain(1, "filthy corduroys", $location[hippy camp]);
         }
         if (!have_outfit("Filthy Hippy Disguise")) die("There was a problem acquiring the Filthy Hippy Disguise.");
         outfit("Filthy Hippy Disguise");
      }
      obtain(1, "beer helmet", $location[frat house]);
      obtain(1, "distressed denim pants", $location[frat house]);
      obtain(1, "bejeweled pledge pin", $location[frat house]);
   }
  // assure possession of hippy fatigues if required
   if (includes_hippy && !have_outfit("War Hippy Fatigues")) {
      if (!can_interact() || get_property("autoSatisfyWithMall") == "false") {
         if (!have_outfit("Frat Boy Ensemble")) {
            outfit(vars["defaultoutfit"]);
            obtain(1, "orcish baseball cap", $location[frat house]);
            obtain(1, "homoerotic frat-paddle", $location[frat house]);
            obtain(1, "orcish cargo shorts", $location[frat house]);
         }
         if (!have_outfit("Frat Boy Ensemble")) die("There was a problem acquiring the Frat Boy Ensemble.");
         outfit("Frat Boy Ensemble");
      }
      obtain(1, "reinforced beaded headband", $location[hippy camp]);
      obtain(1, "bullet-proof corduroys", $location[hippy camp]);
      obtain(1, "round purple sunglasses", $location[hippy camp]);
   }
  // ensure possession of flaregun if required
   if (is_wossname_plan) obtain(1, "flaregun", $location[pirate cove]);
  // start the war
   print("Starting the war...","blue");
   location startplace;
   if (includes_frat) {
      set_property("choiceAdventure142","3");
      outfit("Frat Warrior Fatigues");
      startplace = $location[hippy camp];
   } else {
      set_property("choiceAdventure146","3");
      outfit("War Hippy Fatigues");
      startplace = $location[frat house];
   }
   repeat {
      if (have_effect($effect[hippy stench]) == 0) use_upto(1,$item[deodorant],true);
      obtain(1, "choiceadv", startplace);
      if (my_adventures() == 0) die("Out of adventures.  Run the script again when you have more of those babies.");
   } until (contains_text(visit_url("council.php"),"get those idiots to fight"));
  // guarantee outfits
   if (includes_frat && !have_outfit("Frat Warrior Fatigues")) die("Somehow, you don't have the frat outfit.  Please get it before continuing.");
   if (includes_hippy && !have_outfit("War Hippy Fatigues")) die("Somehow, you don't have the hippy outfit.  Please get it before continuing.");
  // get flyers if arena sidequest will be fratboy
   if (arena_is_frat && item_amount($item[rock band flyers]) == 0 && get_property("sidequestArenaCompleted") != "fratboy") {
      print("Getting rock band flyers...");
      dress_apropos(false);
      visit_url("bigisland.php?place=concert&pwd=");
   }
   return true;
}

boolean finish_war() {
  // the plan is complete!  or, we ran out of advs
   if (step != count(plan)) return vprint("Out of adventures.  Run the script again when you have more of those lil' guys.",-2);
   print("Step "+step+": win!","blue");
  // everything's cool... right?
   if (is_wossname_plan) {
     // double-check conditions for getting wossname
      if ((to_int(get_property("hippiesDefeated")) != 999) || (to_int(get_property("fratboysDefeated")) != 999))
        die("Wossname: All steps completed, but the final count is inaccurate.  Check your war plan or session logs for errors.");
      if (!retrieve_item(1, $item[flaregun])) die("Crap! No flaregun! Did you use it early or what?");
   } else if (!((to_int(get_property("hippiesDefeated")) == 1000) || (to_int(get_property("fratboysDefeated")) == 1000)))
        die("Non-Wossname: All steps completed, but not all enemies were slain.  Check your war plan for errors.");
  // take care of dimes/quarters
   if (!turn_stuff_in(to_boolean(vars["ocw_change_to_meat"]))) die("You have dimes and/or quarters to spend!  Spend them and run this again.");
   if (is_wossname_plan) {
     // call in the pirates on wisniewski to get your wossname!
      if (!contains_text(visit_url("adventure.php?snarfblat=132"), "The Last Stand, Bra")) abort("Wossname final battle expected but not found.");
      if (!contains_text(visit_url("choice.php?whichchoice=174&option=1&pwd"), "The Big Wisniewski")) abort("Combat with The Big Wisniewski expected but not found.");
      if (!contains_text(throw_item($item[flaregun]), "You win the fight!")) abort("Something went wrong with using the flaregun.  You're on your own, pal.");
      print("Getting the Wossname in..."); wait(3);
      print("...wait for it..."); wait(3);
   } else {
     // defeat the dude at the camp
      print("Fighting the Last Battle..."); wait(5);
      int whichcamp = 1;
      if (to_int(get_property("fratboysDefeated")) == 1000) whichcamp = 2;
      dress_apropos((whichcamp == 2));
      if (!contains_text(visit_url("bigisland.php?place=camp&whichcamp="+whichcamp), "You walk through the carnage")) abort("Final battle expected but not found.");
      if (!contains_text(visit_url("bigisland.php?action=bossfight&pwd"), "This guy")) abort("Confrontation expected but not found.");
      if (!contains_text(run_combat(), "You stare")) abort("You failed to succeed.  Or, you successfully failed.");
      print("Getting your Reward in..."); wait(3);
   }
   visit_url("council.php");
   print("Victory! Veni, vidi, vici and all that stuff.","blue");
   set_property("warProgress","finished");
   return true;
}

void main() {
  // no need to continue in these cases
   if (my_level() < 12) abort("You can't go for the Wossname just yet.  Try again when you're, oh, "+(12-my_level())+" levels stronger.");
   if (my_adventures() == 0)
   {
	   print("An adventurer without adventures is you!","red");
	   return;
   }
   if (my_inebriety() > inebriety_limit()) abort("In your condition, you're liable to lose count.  Try again tomorrow.");
   if (my_level() != to_int(get_property("lastCouncilVisit"))) visit_url("council.php");
	string tmp = visit_url("island.php");
   if (get_property("warProgress") == "finished")
   {
		print("You have already completed the Level 12 quest.  You victor you.");
		return;
   }
   check_version("One-Click Wossname","wossname",this_version,960);
   if (!contains_text(visit_url("questlog.php?which=1"),"between the hippies"))
	{
		if(contains_text(visit_url("island.php"),"A Peaceful Meadow"))
		{
			set_property("warProgress","finished");
			return;
		}
		else
		{
			abort("You have not yet recieved this quest.  Maybe after you defeat Dr. Awkward...");
		}
   }
  // set initial stuff
   set_property("battleAction","custom combat script");
   cli_execute("checkpoint");
   load_plan(vars["ocw_warplan"]);
  // start war
   if (get_property("warProgress") == "unstarted" && start_war())
      print("War successfully incited.  You provocateur you.","blue");
	
	while(available_amount($item[hobo code binder])!=0 && !contains_text(visit_url("questlog.php?which=5"),"The Hippy/Frat Battlefield")&& my_adventures()>0)
	{
		set_property("battleAction","try to run away");
		cli_execute("maximize initiative, +1 handed, +outfit frat warrior fatigues");
		cli_execute("equip hobo code binder");
		boolean catch = adventure(1,$location[Battlefield (Frat Uniform)]);
	}  
   set_property("battleAction","custom combat script");
  // follow the plan!
   set_step(true);
   while ((my_adventures() > 0) && (step < count(plan))) {
      if (do_step(step)) {
          print("Step "+step+" completed!","blue");
          step = step + 1;
      } else die("Unable to complete step "+step);
   }
  // finish war
   finish_war();
  // reset changed settings
   set_property("battleAction",previous_battleaction);
   use_familiar(previous_familiar);
   cli_execute("outfit checkpoint");
}