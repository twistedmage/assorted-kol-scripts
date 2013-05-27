#/******************************************************************************
#                        MacGuffin 2.0.9 by Zarqon
#*******************************************************************************
#
#   Automates the level 11 quest.
#
#   Have a suggestion to improve this script?  Visit
#   http://kolmafia.us/showthread.php?t=1965
#
#   Props to izchak -- in writing this I consulted his earlier script quite a
#   bit.  Since he's not around anymore, I view this as a continuation of his
#   project, which is why I started the version number at 2.0 for this rewrite.
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#******************************************************************************/
script "macguffin.ash";
import <zlib.ash>
string this_version = "2.0.9";

boolean buyratchets = false;              // whether or not to allow purchasing tomb ratchets

boolean fightbosses = false;              // whether the script should fight Dr. Awkward / Lord Spookyraven

string questlog;
void updatelog() { questlog = visit_url("questlog.php?which=1"); }

void mg_start() {
   if (!black_market_available()) {
      vprint("Finding the black market...",2);
      obtain(1,"black market map",$location[black forest]);
      if (!have_familiar($familiar[reassembled blackbird])) {
         obtain(1,"sunken eyes",$location[black forest]);
         obtain(1,"broken wings",$location[black forest]);
      }
      use(1,$item[black market map]);
      retrieve_item(1,$item[can of black paint]);
   }
   vprint("Black market found.",2);
   if (item_amount($item[your father's macguffin diary]) == 0) {
      vprint("Obtaining diary...",2);
      retrieve_item(1,$item[forged identification documents]);
      adventure(1,to_location(to_string(my_primestat()) + " vacation"));
      if (my_ascensions() > 0) use(1,$item[your father's macguffin diary]);
   }
   vprint("Diary obtained.",2);
   if (!contains_text(visit_url("beach.php"),"oasis.gif")) {
      vprint("Revealing the oasis...",2);
      set_property("choiceAdventure132","2");     // reveal the oasis
      obtain(1,"choiceadv",$location[desert (unhydrated)]);
   }
   vprint("Oasis revealed.",2);
   if (!contains_text(visit_url("woods.php"),"temple.gif")) {
      vprint("Revealing the hidden temple...",2);
	  abort("Not updated for new spooky forest");
      obtain(1,"spooky temple map",$location[spooky forest]);
      obtain(1,"spooky sapling",$location[spooky forest]);
      obtain(1,"spooky-gro fertilizer",$location[spooky forest]);
      use(1, $item[spooky temple map]);
   }
   vprint("Hidden temple revealed.",2);
   while (!contains_text(visit_url("woods.php"),"hiddencity.gif"))
      obtain(1,"choiceadv",$location[hidden temple]);
   vprint("Hidden city revealed.",2);
   if (item_amount($item[ballroom key]) == 0)     // does this work? no idea
      obtain(1,"ballroom key",$location[haunted bedroom]);
   if (!contains_text(visit_url("manor.php"),"sm8b.gif")) {
      vprint("Opening cellar...",2);
      adventure(my_adventures(),$location[haunted ballroom]);
   }
   vprint("Cellar opened.",2);
   if (have_item("o'nam") == 0) {
      vprint("Revealing Palindome...",2);
      if (equipped_amount($item[pirate fledges]) == 0) {
         obtain(1,"pirate fledges",$location[f'c'le]);
         equip($slot[acc3],$item[pirate fledges]);
      }
      if (!contains_text(visit_url("cove.php"),"cove3_5x2b.gif"))
         adventure(my_adventures(),$location[poop deck]);
      obtain(1,"o'nam",$location[belowdecks]);
      if (!outfit(vars["defaultoutfit"])) vprint("Unable to wear the custom outfit named '"+vars["defaultoutfit"]+"'.",-2);
   }
   vprint("Palindome revealed.",2);
   vprint("Macguffin quest started.","blue",2);
}

boolean do_hiddencity() {
/*
  Hidden City Layout
  N - nature        0 - unexplored         T - temple
  L - lightning     E - explored           A - archaeologist
  F - fire          P - protector spectre
  W - water         D - defeated spectre
*/
   if (item_amount($item[ancient amulet]) + item_amount($item[headpiece of the staff of ed]) +
      item_amount($item[staff of ed, almost]) + item_amount($item[staff of ed]) > 0) return vprint("You have already completed the Hidden City.",2);
   if (to_int(get_property("lastHiddenCityAscension")) != my_ascensions()) visit_url("hiddencity.php");
   cli_execute("conditions clear");
   string prop = to_lower_case(get_property("hiddenCityLayout"));
   if (get_property("autoSphereID") == "false") vprint("WARNING: Mafia is not set to automatically ID stone spheres!","olive",-2);

   int get_first(string hunt) {
      for i from 1 to length(prop)
         if (substring(prop,i-1,i) == hunt) return i;
      return 0;
   }
   boolean hc_adventure(string hunt) {
      if (get_first(hunt) == 0) return false;
      set_property("hiddenCitySquare",get_first(hunt));
      if (!adv1($location[hidden city],-1,"")) return vprint("Debug: adv1 returned false.",-7);
      prop = to_lower_case(get_property("hiddenCityLayout"));
      return true;
   }
   boolean reveal_square(string hunt) {
      while (!contains_text(prop,hunt))
         if (!hc_adventure("0")) return false;
      return true;
   }
   item this_stone(string desc) {
      for i from 2174 to 2177
         if (get_property("lastStoneSphere"+i) == desc) return to_item(i);
      vprint("Unable to determine '"+desc+"' stone.  You may have to identify the stones yourself.",0);
      return $item[none];
   }
   boolean do_altar(string god) {
      vprint("Finding the altar of "+god+"...",2);
      if (!reveal_square(substring(god,0,1))) return vprint("Unable to reveal the "+god+" altar.",-2);
      if (item_amount(this_stone(god)) > 0) cli_execute("hiddencity "+get_first(substring(god,0,1))+" altar "+this_stone(god));
      return (item_amount(this_stone(god)) == 0);
   }

   while (item_amount($item[mossy stone sphere]) + item_amount($item[rough stone sphere]) + item_amount($item[triangular stone]) +
          item_amount($item[smooth stone sphere]) + item_amount($item[cracked stone sphere]) < 4) {
      if (get_first("p") > 0) {
         if (!hc_adventure("p")) return false;
      } else if (!hc_adventure("0")) return false;
   }
   if (do_altar("nature") && do_altar("lightning") && do_altar("fire") && do_altar("water") && reveal_square("t"))
     cli_execute("hiddencity "+get_first("t")+" temple");
   return (item_amount($item[ancient amulet]) > 0 && vprint("Hidden city complete.",2));
}

boolean reveal_pyramid() {
   if (!contains_text(questlog,"A Pyramid Scheme") || contains_text(questlog,"found the little pyramid") ||
        contains_text(questlog,"found the hidden buried pyramid")) return vprint("You've already revealed the pyramid.",2);
   if (contains_text(questlog,"your desert explorations")) {
      vprint("Meeting Gnasir...",2);
      if (adventure(my_adventures(),$location[desert (ultrahydrated)])) vprint("Out of adventures.",0);
      updatelog();
   }
   if (contains_text(questlog,"stone rose")) obtain(1,"stone rose",$location[oasis]);
   obtain(1,"drum machine",$location[oasis]);
   if (item_amount($item[stone rose]) > 0) {
      vprint("Turning in stone rose...",2);
      retrieve_item(1,$item[can of black paint]);
      while (item_amount($item[stone rose]) > 0 && adventure(1, $location[desert (ultrahydrated)])) {}
      updatelog();
   }
   while ((contains_text(questlog,"prove your honor and dedication") && retrieve_item(1,$item[can of black paint])) ||
        contains_text(questlog,"Gnasir seemed satisfied")) {
      vprint("Reporting back to Gnasir...",2);
      cli_execute("conditions clear");
      adventure(2,$location[desert (ultrahydrated)]);
      updatelog();
   }
   if (contains_text(questlog,"worm-riding manual") || contains_text(questlog,"missing manual pages")) {
      obtain(1,"pages 3-15",$location[oasis]);
      obtain(1,"worm-riding hooks",$location[desert (ultrahydrated)]);
   }
   if (item_amount($item[worm-riding hooks]) == 0) abort("Unable to get worm-riding hooks.");
   cli_execute("checkpoint; equip worm-riding hooks; use drum machine; outfit checkpoint");
   return vprint("Pyramid revealed.",2);
}

boolean never_odd_or_even() {
   if (!contains_text(questlog,"Never Odd")) return vprint("You have already defeated Dr. Awkward.",2);
   equip($slot[acc3],$item[talisman o'nam]);
   if (contains_text(questlog,"Palindome") && item_amount(to_item("i love me")) == 0) {
      vprint("Meeting Dr. Awkward...",2);
      cli_execute("conditions clear; conditions add i love me");
      if (adventure(my_adventures(), $location[palindome])) abort("Out of adventures.");
      cli_execute("uneffect beaten up; use i love me");
      updatelog();
   }
   vprint("Dr. Awkward discovered.",2);
   if (item_amount($item[lab key]) == 0)
      obtain(1,$item[lab key],$location[goblin kitchen]);
   while (my_adventures() > 0 && contains_text(questlog,"Fats, but then you lost it")) {
      vprint("Meeting Mr. Alarm...",2);
      cli_execute("conditions clear");
      adventure(my_adventures(), $location[goblin lab]);
      updatelog();
   }
   vprint("Mr. Alarm discovered.",2);
   if (contains_text(questlog,"lion oil, a bird rib, and some stunt nuts")) {
      if (item_amount($item[wet stunt nut stew]) < 1) {
         if (item_amount($item[wet stew]) + creatable_amount($item[wet stew]) == 0) {
            visit_url("guild.php?place=paco");
            obtain(1,"wet stew",$location[whitey's grove]);
         }
         obtain(1,"stunt nuts",$location[palindome]);
         create(1,$item[wet stunt nut stew]);
      }
      if (item_amount($item[wet stunt nut stew]) == 0) abort("Unable to cook up some tasty wet stunt nut stew.");
      while (have_item("mega gem") == 0 && my_adventures() > 0)
         adventure(1, $location[laboratory]);
   }
   if (have_item("mega gem") == 0) return vprint("Unable to get Mega Gem.",-2);
   if (!fightbosses) vprint("Time to go stop evil \"agnieb\" Dr. Awkward being alive. (pots! O got emit!)",0);
   equip($slot[acc2],$item[mega gem]);
   cli_execute("restore hp; conditions clear");
   vprint("Fighting Dr. Awkward in...",2); wait(5);
   adventure(1, $location[palindome]);
   if (!outfit(vars["defaultoutfit"])) vprint("Unable to wear the custom outfit named '"+vars["defaultoutfit"]+"'.",-2);
   if (item_amount($item[Staff of Fats]) == 0) vprint("Looks like Dr. Awkward opened a can of whoop-oohw on you.",0);
   return vprint("Dr. Awkward defeated.",2);
}

boolean manor_of_spooking() {
   if (!contains_text(questlog,"Spooking")) return vprint("You have already defeated Lord Spookyraven.",2);
   if (!contains_text(questlog,"secret black magic laboratory")) {
      set_property("choiceAdventure84",3);
      obtain(1, "Lord Spookyraven's spectacles", $location[Haunted bedroom]);
      if (equipped_amount($item[Lord Spookyraven's spectacles]) == 0 && equip($slot[acc3],$item[Lord Spookyraven's spectacles])) {}
      if (!have_equipped($item[Lord Spookyraven's spectacles])) return false;
      if (get_property("lastDustyBottleReset").to_int() != my_ascensions()) cli_execute("dusty");
      string[int] blar = split_string(visit_url("manor3.php?place=goblet"),"/otherimages/manor/glyph");
      if (count(blar) != 4) vprint("Error parsing wine puzzle.",0);
      item get_this_wine(int wine_no) {
         for i from 2271 to 2276
            if (get_property("lastDustyBottle"+i) == wine_no)
               return to_item(i);
        vprint("Wine (" + wine_no + ") not found!",0);
        return $item[none];
      }
      item[int] wines;
      if (!outfit(vars["defaultoutfit"])) vprint("Unable to wear the custom outfit named '"+vars["defaultoutfit"]+"'.",-2);
      for i from 1 to 3 {
         wines[i] = get_this_wine(to_int(substring(blar[i],0,1)));
         vprint("wine #"+i+" : " + wines[i],3);
         obtain(1,wines[i],$location[haunted wine cellar (automatic)]);
      }
      if (equipped_amount($item[Lord Spookyraven's spectacles]) > 0 || equip($slot[acc3],$item[Lord Spookyraven's spectacles])) {}
      for i from 1 to 3 {
         blar[1] = visit_url("manor3.php?action=pourwine&whichwine="+to_int(wines[i]));
         if (!contains_text(blar[1],"glow more brightly") && !contains_text(blar[1],"reveal a hidden passage")) return false;
      }
   }
   if (contains_text(visit_url("manor3.php"), "chambera.gif")) {
      if (!fightbosses) vprint("Time to lay down the smack on ol' Spookyface.",0);
      if (!outfit(vars["defaultoutfit"])) vprint("Unable to wear the custom outfit named '"+vars["defaultoutfit"]+"'.",-2);
      restore_mp(40);
      restore_hp(my_hp());
      vprint("Fighting Lord Spookyraven in...",2); wait(5);
      visit_url("manor3.php?place=chamber");
      run_combat();
      if (item_amount($item[eye of ed]) == 0) vprint("The Spooky man pwned you with his evil.",0);
   }
   return vprint("Lord Spookyraven defeated.",2);
}

boolean pyramid() {
   if (!contains_text(questlog,"A Pyramid Scheme")) return vprint("You have already exposed Ed the Undying's chamber.",2);
   if (!retrieve_item(1,$item[Staff of Ed])) return false;
   if (!contains_text(visit_url("beach.php"),"pyramid.php"))   // reveal pyramid
      visit_url("beach.php?action=woodencity");
   set_property("choiceAdventure134","1");                     // turn the wheel in the pyramid
   set_property("choiceAdventure135","1");
   if (!outfit(vars["defaultoutfit"])) vprint("Unable to wear the custom outfit named '"+vars["defaultoutfit"]+"'.",-2);
   if (!contains_text(visit_url("pyramid.php"),"pyramid3b.gif")) {   // this should also ensure mafia properties are set
      obtain(1,"carved wooden wheel",$location[upper chamber]);
      obtain(1,"choiceadv",$location[middle chamber]);
   }
   if (get_property("pyramidBombUsed") == "true") return true;
   boolean turn_once() {
      string initpos = get_property("pyramidPosition");
      vprint("Current pyramid position: "+initpos+".  Turning...","olive",2);
      use_upto(1,$item[tomb ratchet],buyratchets);
      if (initpos != get_property("pyramidPosition")) return vprint("Pyramid successfully rotated.",5);
      return obtain(1,"choiceadv",$location[middle chamber]);
   }
   boolean pyrstep(string stepname,string posnum) {
      vprint(stepname+" (image "+posnum+")","blue",2);
      while (get_property("pyramidPosition") != posnum)
         if (my_adventures() == 0 || !turn_once()) return false;
      return adventure(1,$location[lower chambers]);
   }
   if (item_amount($item[ancient bronze token]) == 0 && item_amount($item[ancient bomb]) == 0 &&
       !pyrstep("Step 1 / 3: get a token.","4")) return vprint("Unable to get a token.",-5);
   if (item_amount($item[ancient bronze token]) > 0 && item_amount($item[ancient bomb]) == 0 &&
       !pyrstep("Step 2 / 3: exchange token for a bomb.","3")) return vprint("Unable to exchange token for bomb.",-5);
   if (item_amount($item[ancient bomb]) > 0) {
      if (!pyrstep("Step 3 / 3: reveal Ed's chamber.","1")) return vprint("Unable to use bomb.",-5);
      vprint("Ed's chamber revealed.",2);
   }
   if (my_adventures() < 7) vprint("You need at least 7 adventures to fight Ed.",0);
   return vprint("Go fight Ed to complete the quest!  Or die, depending.","blue",2);
}

void main() {
   if (my_level() < 11) vprint("You're too weak.  Your level needs to be so high that it's ridiculous (and not even funny).",0);
   if (my_adventures() == 0) vprint("Those adventureless should not this script run.",0);
   if (my_inebriety() > inebriety_limit()) vprint("You can't run this script because you're stupid. I mean, stupored.",0);
   check_version("MacGuffin","macguffin",this_version,1965);
   if (my_level() != to_int(get_property("lastCouncilVisit"))) visit_url("council.php");
   updatelog();
   if (!contains_text(questlog,"MacGuffin") && to_int(get_property("lastPyramidReset")) == my_ascensions() && get_property("pyramidBombUsed") == "true")
      vprint("Sorry, but you cannot complete this quest twice.",0);
   mg_start();

//--------- you can change the order of these four pieces if you like ----------
   if (!do_hiddencity()) vprint("Unable to complete the hidden city.",0);
   if (!reveal_pyramid()) vprint("Unable to reveal the pyramid.",0);
   if (!never_odd_or_even()) vprint("Unable to complete the Palindome section of the MacGuffin quest.",0);
   if (!manor_of_spooking()) vprint("Unable to complete the Spookyraven section of the MacGuffin quest.",0);
//------------------------------------------------------------------------------

   if (!pyramid()) vprint("Unable to reveal Ed's chamber.",0);
}
