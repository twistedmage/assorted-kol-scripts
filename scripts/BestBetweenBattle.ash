/******************************************************************************
                      Best Between Battle by Zarqon
*******************************************************************************

     - sets your MCD for maximum stat gains -- enabled/disabled by [automcd]
     - intelligently adjusts choiceAdvs -- enabled/disabled by [bbb_adjust_choiceadvs]
     - uses items containing goals -- move containers to closet to avoid use
     - fights putty monsters/4-d camera monsters for bounties and specified goals
     - whistles for dolphins to get goals or items worth at least 2x the cost of whistling
     - eats fortune cookies automatically -- set [auto_semirare] to "always", "timely", or "never"

   Have a suggestion to improve this script?  Visit
   http://kolmafia.us/showthread.php?t=1240

   Want to say thanks?  Send me a bat! (Or bat-related item)

******************************************************************************/
script "BestBetweenBattle.ash";
notify Zarqon;
import <zlib.ash>

boolean cookiecheck() {
   if (my_fullness() >= fullness_limit() || !can_eat() || my_meat() < 40 || my_fullness() == 0 || ($strings[Zombie Slayer,Avatar of Jarlsberg] contains my_path())) return true;
   matcher cooks = create_matcher("(timely|always|true|never|false) ?([1-3]?)",vars["auto_semirare"]);
   if (!cooks.find()) return vprint("Warning: your auto_semirare setting is not an accepted value: timely|always|never (maximumcounters)",-5);
   switch (cooks.group(1)) {
      case "timely": if (get_counters("Fortune Cookie",-1,200) != "" || get_counters("Semirare window begin",1,200) != "")
         return vprint("BBB: No need to eat a cookie given the present counters.","#F87217",8);
         if (my_location() != to_location(get_property("semirareLocation")) && $locations[The Purple Light District, The Haunted Billiards Room, The Haunted Pantry,
             Cobb's Knob Menagerie\, Level 2, The Outskirts of Cobb's Knob, The Limerick Dungeon, The Sleazy Back Alley, Cobb's Knob Harem] contains my_location())
           return vprint("BBB: "+my_location()+" contains a nice semi-rare; not auto-eating cookie.  Eat one manually if you want your counterScript to handle it.","#F87217",5);
      case "always": case "true":
         while ((my_location() != to_location(get_property("BaleCC_next")) ||
                 to_location(get_property("BaleCC_next")) == to_location(get_property("semirareLocation"))) && (get_counters("Fortune Cookie",-1,200) == "" ||
                (to_int(cooks.group(2)) > 0 && count(split_string(get_counters("Fortune Cookie",0,200),"\t")) > to_int(cooks.group(2))))) {
            if (my_fullness() == fullness_limit()) return true;
            if (!eatsilent(1,$item[fortune cookie])) return false;
         }
         
   }
   return true;
}

void use_goalcontaining_items() {
   if (my_path() == "Way of the Surprising Fist") cli_execute("use * teachings of the fist");
    else if (!can_interact()) cli_execute("sell * meat stack; sell * dense meat stack");
   cli_execute("use * evil eye");
   while (item_amount($item[gnollish toolbox]) > 0 && be_good($item[gnollish toolbox]) && (is_goal($item[bitchin' meatcar]) || is_goal($item[meat engine])))
      use(1,$item[gnollish toolbox]);
   if (count(useforitems) == 0 && !load_current_map("use_for_items", useforitems)) return;
   foreach cont,res,chance in useforitems
      while (item_amount(cont) > 0 && be_good(cont) && is_goal(res) && chance > 0) use(1,cont);
}

// CHOICEADVS!!
void set_choiceadvs() {       // this is where the arduous magic happens.
   if (!to_boolean(vars["bbb_adjust_choiceadvs"])) return;
   void friendlyset(int choiceadv, string value, string explan) { if (get_property("choiceAdventure"+choiceadv) == value) return;
      if (explan != "") vprint("BBB: "+explan,"#F87217",2); set_property("choiceAdventure"+choiceadv,value); }
   boolean includes_goal(boolean[item] prospects) { foreach i in prospects if (has_goal(i) > 0) return true; return false; }
   item next_w() {   // order: balldodger (dragnet), netdragger (switchblade), bladeswitcher (dodgeball)
      if ($location[mer-kin colosseum].combat_queue == "") return $item[mer-kin dragnet];
      if (($monsters[mer-kin balldodger, mer-kin bladeswitcher, mer-kin netdragger, Georgepaul\, the Balldodger, Ringogeorge\, the Bladeswitcher] 
         contains to_monster(get_property("lastEncounter"))) && !contains_text(run_combat(),"WINWINWIN")) return equipped_item($slot[weapon]);
      string[int] ms = split_string($location[mer-kin colosseum].combat_queue,"; ");
      switch (to_monster(ms[ms.count()-1])) {
         case $monster[mer-kin balldodger]: case $monster[Georgepaul, the Balldodger]: return $item[mer-kin switchblade];
         case $monster[mer-kin bladeswitcher]: case $monster[Ringogeorge, the Bladeswitcher]: return $item[mer-kin dragnet];
         case $monster[mer-kin netdragger]: case $monster[Johnringo, the Netdragger]: return $item[mer-kin dodgeball];
      } return $item[none];
   }
   float foodDrop() {
      float famBonus() {
         switch (my_path()) {
            case "Avatar of Boris": return minstrel_instrument() == $item[Clancy's lute] ?
               numeric_modifier($familiar[baby gravy fairy], "Item Drop", minstrel_level()*5, $item[none]) : 0;
            case "Avatar of Jarlsberg":	return my_companion() == "Eggman" ? (have_skill($skill[Working Lunch]) ? 75 : 50) : 0;
         }
         int famw = round(familiar_weight(my_familiar()) + weight_adjustment() - numeric_modifier(familiar_equipped_equipment(my_familiar()),"Familiar Weight"));
         return numeric_modifier(my_familiar(), "Item Drop", famw, familiar_equipped_equipment(my_familiar()));
      }
      return round(numeric_modifier("Item Drop") - famBonus() + numeric_modifier("Food Drop"));
   }
   boolean hacienda_target(string targ, string reason) {
      int ti = last_index_of(substring(get_property("haciendaLayout"),0,18),targ);
      if (ti < 0 || ti > 17) return false;
      friendlyset(410,(ti < 9 ? "1" : "2"),reason);
      if (ti < 9) friendlyset(411,(ti/3 + 1),reason);
       else friendlyset(412,(ti/3 - 2),reason);
      friendlyset((ti / 3) + 413, (ti % 3)+1, reason);
      return true;
   }
   switch (my_location()) {
      case $location[an octopus's garden]:
         if (item_amount($item[glob of green slime]) > 0 && item_amount($item[soggy seed packet]) > 0)
            for i from 3555 to 3560 if (is_goal(to_item(i)) && (have_equipped($item[straw hat]) || equip($item[straw hat]))) {
               friendlyset(298,"1","Plant seeds to get a sea fruit/vegetable goal."); return;
            }
         friendlyset(298,"2","Skip planting seeds. ("+item_amount($item[soggy seed packet])+" seed packets, "+item_amount($item[glob of green slime])+" green slime)");
         return;
      case $location[barrrney's barrr]: int nappunmal; for i from 1 to 8 if (get_property("lastPirateInsult"+i) == "true") nappunmal += 1;
         if (nappunmal > 5) friendlyset(187,"1","Step up to the beer pong!");
          else friendlyset(187,"2","You're not ready for beer pong; skip it.");
         return;
      case $location[The Batrat and Ratbat Burrow]:
      case $location[guano junction]:
      case $location[the beanbat chamber]: if (last_monster() == $monster[Screambat] && is_goal($item[sonar-in-a-biscuit]))
         remove_item_condition(1,$item[sonar-in-a-biscuit]); return;
      case $location[the black forest]:
        // blackberries
         if (is_goal($item[blackberry slippers])) friendlyset(928,"1","Get goal of blackberry slippers.");
          else if (is_goal($item[blackberry moccasins])) friendlyset(928,"2","Get goal of blackberry moccasins.");
          else if (is_goal($item[blackberry combat boots])) friendlyset(928,"3","Get goal of blackberry combat boots.");
          else if (is_goal($item[blackberry galoshes]) || available_amount($item[blackberry galoshes]) == 0) friendlyset(928,"4","Get galoshes.");
          else friendlyset(928,"6","No blackberry footwear needed.");
         if (!get_property("kingLiberated").to_boolean() && item_amount($item[beehive]) < 1 && my_path() != "Bugbear Invasion")
            friendlyset(924,"3","Get a beehive for the wall of skin.");
         else if (get_property("choiceAdventure928") != "6" && item_amount($item[blackberry]) > 2) friendlyset(924,"2","Visit cobbler for footwear.");
          else friendlyset(924,"1","Fight a bush.");
        // blacksmith
         boolean blackgoal; foreach i in $items[black sword, black shield, black helmet, black greaves] if (is_goal(i)) blackgoal = true;
         int blackchoice = 1; foreach i in $items[black sword, black shield, black helmet, black greaves] { 
            if (is_goal(i) || (!blackgoal && available_amount(i) == 0 && be_good(i))) { friendlyset(925,blackchoice,"Get goal/lacking "+i+"."); break; }
            blackchoice += 1;
         }
         if (blackchoice == 5) friendlyset(925,"6","No black weaponry needed.");
        // black gold mine
         if (is_goal($item[texas tea])) friendlyset(926,"2","Get goal texas tea.");
          else if (has_goal($item[black gold]) > 0) friendlyset(926,"1","Mine for black gold.");
          else if (have_effect($effect[black lung]) > 0 || get_property("choiceAdventure926") != "3") friendlyset(926,"6","Nothing to do in the black mine.");
        // black church
         if (is_goal($item[black kettle drum])) friendlyset(927,"2","Get goal black kettle drum.");
          else if (have_equipped($item[black cloak]) && string_modifier("Outfit") == "Black Armaments" && have_effect($effect[salsa satanica]) == 0 && 
                   (have_equipped($item[dark baconstone ring]) || have_equipped($item[dark hamethyst ring]) || have_equipped($item[dark porquoise ring])))
             friendlyset(927,"1","Get +50% items buff.");
          else friendlyset(927,"6","Skip the black church.");
        // All Over the Map
         if (!get_property("kingLiberated").to_boolean() && item_amount($item[beehive]) < 1) friendlyset(923,"1","Get beehive for the tower.");
          else switch (to_int(get_property("blackForestProgress"))) {
             case 5: case 4: if (get_property("choiceAdventure927") != "6") { friendlyset(923,"4","We have business in the black church."); break; }
             case 3: if (get_property("choiceAdventure926") != "6") { friendlyset(923,"3","Take care of business in the black mine."); break; }
             case 2: if (blackgoal || (to_int(get_property("blackForestProgress")) > 4 && blackchoice < 5)) { friendlyset(923,"2","Get black equipment from the black smith."); break; }
             default: friendlyset(923,"1","Fight a bush or get blackberry footwear.");
          }
         return;
      case $location[the castle in the clouds in the sky (basement)]:
        // Fitness
         if (get_property("questL10Garbage") != "finished" && have_item($item[amulet of extreme plot significance]) > 0 && be_good($item[amulet of extreme plot significance]) && 
             can_equip($item[amulet of extreme plot significance]) && have_equipped($item[amulet of extreme plot significance]))
//            (have_equipped($item[amulet of extreme plot significance]) ? friendlyset(670,"4","Unlock the ground floor with your amulet.") : friendlyset(670,"5","Repeat the Fitness room with an amulet."));
             friendlyset(670,"4","Unlock the ground floor with your amulet.");
          else if (includes_goal($items[pec oil, giant jar of protein powder, Squat-Thrust Magazine]))
             friendlyset(670,"3","Get goal items from the gym bag.");
          else friendlyset(670,"1","Get a dumbbell, then skip the Fitness Giant's room.");   // when open detection is known, can add stats
        // Neckbeard
         if (item_amount($item[massive dumbbell]) > 0) friendlyset(671,"1","Unlock ground floor with dumbbell.");
          else if (get_property("questL10Garbage") != "finished" && (to_int(get_property("choiceAdventure670")) > 3 || 
             item_amount($item[massive dumbbell]) == 0)) friendlyset(671,"4","Proceed to Fitness Giant's room for amulet unlock.");
          else if (includes_goal($items[O'RLY manual, open sauce])) friendlyset(671,"3","Get goal manual and/or sauce.");
          else if (is_goal($stat[mysticality])) friendlyset(671,"2","Get myst stats.");
          else friendlyset(671,"1","Skip Neckbeard.");
        // Furry
         if (get_property("questL10Garbage") != "finished" && have_item($item[titanium assault umbrella]) > 0 && be_good($item[titanium assault umbrella]) && 
            can_equip($item[titanium assault umbrella]) && have_equipped($item[titanium assault umbrella])) friendlyset(669,"1","Unlock the ground floor with your umbrella.");
//            (have_equipped($item[titanium assault umbrella]) ? friendlyset(669,"1","Unlock the ground floor with your umbrella.") : friendlyset(669,"3","Repeat the Furry room with an umbrella."));
          else if (get_property("choiceAdventure671") == "1" && is_goal($stat[moxie])) friendlyset(669,"2","Get moxie stats.");
          else friendlyset(669,"1","Proceed to the Neckbeard room for more options.");
         return;
      case $location[the castle in the clouds in the sky (ground floor)]:
         if (item_amount($item[electric boning knife]) == 0 && !have_skill($skill[garbage nova]))
            friendlyset(1026,"2","Get an electric boning knife.");
          else friendlyset(1026,"3","Skip the foodie giant's room.");
         return;
      case $location[the castle in the clouds in the sky (top floor)]:
        // Raver
         if (item_amount($item[drum 'n' bass 'n' drum 'n' bass record]) == 0 && !have_equipped($item[mohawk wig]) && 
            get_property("questL10Garbage") != "finished") friendlyset(676,"3","Get a quest (drum+bass)*2 record.");
          else if (has_goal($monster[raver giant]) > 0) friendlyset(676,"1","Fight Raver Giants for goals.");
          else if (get_property("choiceAdventure676") == "2") vprint("Respecting user's decision to set Raver choice to restore HP/MP.",5);
          else friendlyset(676,"4","Nothing in Raver; proceed to Punk Rock.");
        // Punk
         if (have_equipped($item[mohawk wig]) && get_property("questL10Garbage") != "finished")           // complete quest
            friendlyset(678,"1","Complete Trash quest with mohawk wig.");
          else if (has_goal($monster[punk rock giant]) > 0) friendlyset(678,"1","Fight Punk Rock Giants for goals.");
          else if (get_property("choiceAdventure676") != "4") friendlyset(678,"4","");                    // something important in Raver room
          else if (get_property("choiceAdventure678") == "2") vprint("Respecting user's decision to set Punk choice to meat.",5);
          else if (get_property("questL10Garbage") == "finished" && item_amount($item[intragalactic rowboat]) == 0)
            friendlyset(678,"3","Nothing in either Raver or Punk; take the shortcut to Steampunk.");
          else friendlyset(678,"1","Avoiding endless Raver <=> Punk loop, defaulting to fighting giants.");
        // Steampunk
         if (item_amount($item[model airship]) > 0 && get_property("questL10Garbage") != "finished")      // complete quest
            friendlyset(677,"1","Complete Trash quest with model airship.");
          else if (item_amount($item[steam-powered model rocketship]) == 0 && my_path() != "Bugbear Invasion")
             friendlyset(677,"2","Get a rocketship from the Steampunk Giant.");                           // unlock hits
          else if (is_goal($item[brass gear]) && to_int(excise(get_goals()[0],"+"," brass")) > 1) friendlyset(677,"3","Get goal multiple brass gears.");
          else if (has_goal($monster[steampunk giant]) > 0) friendlyset(677,"1","Fight Steampunk Giants for goals.");
          else friendlyset(677,"4","Nothing in Steampunk; proceed to Goth.");
        // Goth
         if (item_amount($item[drum 'n' bass 'n' drum 'n' bass record]) > 0 && get_property("questL10Garbage") != "finished")
            friendlyset(675,"2","Complete Trash quest with drum 'n' bass 'n' drum 'n' bass record.");     // complete quest
          else if (is_goal($item[thin black candle]) && to_int(excise(get_goals()[0],"+"," thin")) > 1) friendlyset(675,"3","Get goal multiple black candles.");
          else if (get_property("choiceAdventure677") != "4") friendlyset(675,"4","");                    // something important in Steampunk room
          else friendlyset(675,"1","Fight Goth Giants by default.");                                      // default to fighting profitable Goths
         return;
      case $location[Chinatown Tenement]: 
         if (item_amount($item[gold piece]) > 29) {
            friendlyset(657,1,"Turn in your 30GP quota.");
            friendlyset(658,1,"Enter Debasement");
         } else friendlyset(657,2,"Skip Debasement (insufficient GP)");
         return;
      case $location[convention hall lobby]:
         for i from 3891 to 3896 {
            if (get_property("lastSlimeVial"+i) != "") continue;
            if (item_amount(to_item(i)) == 0 && creatable_amount(to_item(i)) > 0) create(1,to_item(i));
            if (item_amount(to_item(i)) > 0) use(1,to_item(i));
         } return;
      case $location[the daily dungeon]:
        // chest 5
         if (includes_goal($items[extra-strength strongness elixir, jug-o-magicalness, rubber axe, skeleton key, suntan lotion of moxiousness, walrus-tusk earring])) 
           friendlyset(690,"1","Get a goal item from the room 5 chest.");
          else if (have_equipped($item[ring of detect boring doors])) friendlyset(690,"2","Skip ahead to room 8.");
          else friendlyset(690,"3","Skip the room 5 chest.");
        // chest 10
         if (includes_goal($items[can of maces, concentrated magicalness pill, enchanted barbell, giant moxie weed, Pick-O-Matic lockpicks, ring of half-assed regeneration, skeleton key ring]))
           friendlyset(691,"1","Get a goal item from the room 10 chest.");
          else if (have_equipped($item[ring of detect boring doors])) friendlyset(691,"2","Skip ahead to room 13.");
          else friendlyset(691,"3","Skip the room 10 chest.");
        // door
         if (item_amount($item[platinum yendorian express card]) > 0) friendlyset(692,"7","Use your PYEC for free dooropenings like a boss.");
          else if (item_amount($item[pick-o-matic lockpicks]) > 0) friendlyset(692,"3","Use your lockpicks for free dooropenings like a pro.");
          else if (retrieve_item(1 + to_int($strings[unstarted, started, step1, step2, step3, step4, step5] contains get_property("questL13Final")),$item[skeleton key])) 
             friendlyset(692,"2","Use a skeleton key because hey, free dooropening.");
          else switch (my_primestat()) {
             case $stat[muscle]: friendlyset(692,"4","Bash down the doors!"); break;
             case $stat[mysticality]: friendlyset(692,"5","Twiddle open the doors."); break;
             case $stat[moxie]: friendlyset(692,"6","Slink past the doors.");
          }
        // trap room
         if (item_amount($item[eleven-foot pole]) > 0) friendlyset(693,"2","Touch it with an 11-ft. pole.");
          else friendlyset(693,"1","Walk into the trap-- I mean, room.");   // TODO: if you can resist a lot you might want stats?
         return;
      case $location[the defiled alcove]:
         if (be_good($item[half-rotten brain]) && item_amount($item[half-rotten brain]) < to_int(vars["bbb_miniboss_items"]))
            friendlyset(153,"3","Get "+vars["bbb_miniboss_items"]+" half-rotten brains.");
          else if (is_goal($stat[muscle])) friendlyset(153,"1","Get muscle stats.");
          else friendlyset(153,"4","Skip brains/non-primestat choiceadv.");
         return;
      case $location[the defiled cranny]:
         if (be_good($item[can of Ghuol-B-Gone&trade;]) && item_amount($item[can of Ghuol-B-Gone&trade;]) < to_int(vars["bbb_miniboss_items"]))
            friendlyset(523,"3","Get "+vars["bbb_miniboss_items"]+" cans of Ghuol-B-Gone&trade;.");
          else friendlyset(523,"4","Fight evil whelp swarms.");
         return;
      case $location[the defiled nook]:
         if (be_good($item[rusty bonesaw]) && item_amount($item[rusty bonesaw]) < to_int(vars["bbb_miniboss_items"]))
            friendlyset(155,"3","Get "+vars["bbb_miniboss_items"]+" rusty bonesaws.");
          else if (get_property("choiceAdventure155") != "3") return;
          else if (is_goal($stat[moxie])) friendlyset(155,"1","Get moxie stats.");
          else friendlyset(155,"4","Skip rusty bonesaw/non-primestat choiceadv.");
         return;
      case $location[the defiled niche]:
         if (be_good($item[plus-sized phylactery]) && item_amount($item[plus-sized phylactery]) == 0 && to_int(vars["bbb_miniboss_items"]) > 0)
            friendlyset(157,"2","Get a plus-sized phylactery.");
          else if (is_goal($stat[mysticality])) friendlyset(157,"1","Get mysticality stats.");
          else friendlyset(157,"4","Skip phylactery/non-primestat choiceadv.");
         return;
      case $location[the dungeons of doom]:
         if (is_goal($item[magic lamp]) && my_meat() > 49)
            friendlyset(25,"1","Get goal magic lamp.");
          else if (my_meat() > 4999 && has_goal($item[dead mimic]) > 0) friendlyset(25,"2","Fight a mimic.");
         return;
      case $location[the enormous greater-than sign]: 
         if (is_goal($item[left parenthesis])) friendlyset(451,"1","Get goal parenthesis.");
          else if (get_property("lastPlusSignUnlock").to_int() < my_ascensions() && item_amount($item[plus sign]) == 0)
            friendlyset(451,"3","Get a plus sign.");
          else if (get_property("lastPlusSignUnlock").to_int() < my_ascensions()) friendlyset(451,"5","Get Teleportitis.");
          else if (is_goal($stat[muscle])) friendlyset(451,"3","Get useful Muscle.");
          else if (is_goal($stat[mysticality])) friendlyset(451,"4","Get useful Mysticality (and MP).");
          else friendlyset(451,"2","Get useful Moxie and meat.");
         return;
      case $location[the "fun" house]:
         if (numeric_modifier("clownosity") < 4)
            friendlyset(151,"2","Skip Beelzebozo due to insufficient clownosity.");
          else friendlyset(151,"1","Fight Beelzebozo.");
         return;
      case $location[the haunted bedroom]:
         if (have_item("lord spookyraven's spectacles") == 0)
             friendlyset(84,"3","Get Spooky's specs from the ornate nightstand.");
          else if (is_goal($stat[mysticality]))
            friendlyset(84,"2","Get myst stats from the ornate nightstand.");
          else friendlyset(84,"1","Get meat from the ornate nightstand.");
         return;
      case $location[the haunted billiards room]:
         if (item_amount($item[spookyraven library key]) == 0 &&   // probably need some kind of pool skill check here
             have_effect($effect[chalky hand]) == 0 && item_amount($item[handful of hand chalk]) > 0)
            use(1,$item[handful of hand chalk]);
         if (is_goal($item[cube of billiard chalk]) || get_property("poolSharkCount").to_int() >= 25) 
            friendlyset(330,"2","Fight a hustled spectre for a cube of billiard chalk.");
          else friendlyset(330,"1","Improve your pool skill (visit "+(25 - to_int(get_property("poolSharkCount")))+" more times to max bonus).");
//            friendlyset(875,"1","Challenge the poolghost.");
//            friendlyset(875,"2","Hone your pool skills some more.");
         return;
      case $location[the haunted library]:
         if (get_property("lastSecondFloorUnlock").to_int() != my_ascensions())  // Rise
            friendlyset(80,"99","Unlock second floor.");
          else if (get_property("choiceAdventure80") != "3") friendlyset(80,"4","Skip Rise of Spookyraven.");
         if (get_property("lastGalleryUnlock").to_int() != my_ascensions() &&    // Fall
             (my_primestat() == $stat[muscle] || get_property("currentHardBountyItem") == "non-Euclidean hoof" ||
              (my_level() > 13 && my_path() != "BIG!") || to_int(get_property("fistSkillsKnown")) > 0) || my_path() == "Bugbear Invasion") {
            friendlyset(81,"1","Read stuff about pet alligators or something.");
            set_property("choiceAdventure87","2");
         } else {
            if (get_property("lastSecondFloorUnlock").to_int() != my_ascensions())
               friendlyset(81,"99","Unlock second floor.");
             else if (get_property("choiceAdventure81") != "3") friendlyset(81,"4","Skip Fall of Spookyraven.");
         }
         return;
      case $location[the haunted pantry]:
         if (is_goal($item[unlit birthday cake]) && get_property("questM08Baker") == "unstarted")
            friendlyset(114,"1","Start the Baker mini-quest.");
          else friendlyset(114,"2","Skip the Baker mini-quest.");
         return;
      case $location[the hidden apartment building]:
         if (have_effect($effect[thrice-cursed]) > 0 && get_property("hiddenApartmentProgress").to_int() < 7)
            friendlyset(780,"1","Thrice-Cursed Penthouse. Thrice-Cursed Penthouse. Thrice-Cursed Penthouse.");
          else if (get_property("relocatePygmyLawyer").to_int() < my_ascensions()) friendlyset(780,"3","Out with the lawyers!  Let them go to the park!");
          else if (have_effect($effect[thrice-cursed]) == 0 && get_property("hiddenApartmentProgress").to_int() < 7) friendlyset(780,"2","Get yourself more cursed.");
          else friendlyset(780,"6","Skip the Action Elevator.");
         return;
      case $location[the hidden bowling alley]:
         if (item_amount($item[bowling ball]) > 0 && get_property("hiddenBowlingAlleyProgress").to_int() < 7) friendlyset(788,"1","Bowl!");
         if (item_amount($item[bowl of scorpions]) == 0 && item_amount($item[bowling ball]) + get_property("hiddenBowlingAlleyProgress").to_int() < 5 && my_meat() > 1000 &&
            get_property("hiddenTavernUnlock").to_int() == my_ascensions() && my_path() != "Way of the Surprising Fist") retrieve_item(1,$item[bowl of scorpions]);
         return;
      case $location[the hidden office building]:
         if (item_amount($item[boring binder clip]) > 0 && get_property("hiddenOfficeProgress") == "5") use(1,$item[boring binder clip]);
         if (item_amount($item[mcclusky file (complete)]) > 0) friendlyset(786,"1","Fight protector spirit.");
          else if (item_amount($item[boring binder clip]) == 0 && get_property("hiddenOfficeProgress").to_int() < 6) friendlyset(786,"2","Get boring binder clip.");
          else if (get_property("hiddenOfficeProgress").to_int() < 5 || has_goal($monster[pygmy witch accountant]) > 0) friendlyset(786,"3","Fight pygmy witch accountants.");
          else friendlyset(786,"6","Skip Working Holiday.");
         return;
      case $location[the hidden park]:
         if (get_property("relocatePygmyJanitor").to_int() < my_ascensions()) friendlyset(789,"2","Knock over the dumpster (move pygmy janitors here).");
          else if (have_item($item[antique machete]) == 0 || item_amount($item[bowling ball]) + get_property("hiddenBowlingAlleyProgress").to_int() < 5 ||
             min(1,have_item($item[half-size scalpel])) + min(1,have_item($item[head mirror])) + min(1,have_item($item[surgical mask])) + 
             min(1,have_item($item[surgical apron])) + min(1,have_item($item[bloodied surgical dungarees])) < 5 ||
             includes_goal($items[bowling ball,half-size scalpel,head mirror,surgical mask,surgical apron,bloodied surgical dungarees]))
            friendlyset(789,"1","Dumpster dive!");
          else friendlyset(789,"6","Skip the dumpster.");
         return;
      case $location[the hidden temple]: 
         if ((goal_exists("choiceadv") || is_goal($item[the nostril of the serpent])) && 
          item_amount($item[stone wool]) > 0 && have_effect($effect[stone-faced]) == 0) use(1,$item[stone wool]);
        // such great heights
         if (item_amount($item[the nostril of the serpent]) == 0 && get_property("lastTempleButtonsUnlock").to_int() < my_ascensions())
            friendlyset(579,"2","Get the Nostril of the Serpent.");
          else if (get_property("lastTempleAdventures").to_int() < my_ascensions()) friendlyset(579,"3","Gain a trio of adventures!");
          else if (is_goal($stat[mysticality])) friendlyset(579,"1","Already got Nostril and adventures, get goal myst stats.");
        // unconfusing buttons
         if (!($strings[step3, finished] contains get_property("questL11Worship"))) {
//            friendlyset(580,"1","Unlock the Hidden City.");
            friendlyset(584,"4","Unlock the Hidden City.");
         } else {
//            friendlyset(580,"2","Hidden City unlocked, leave Pikachutlotl and go back to the Heart.");
            if (is_goal($item[ancient calendar fragment])) friendlyset(584,"2","Hidden City unlocked, get goal ancient calendar fragment.");
             else if (is_goal($stat[muscle])) friendlyset(584,"1","Hidden City unlocked, get muscle stats.");
         }
        // fitting in (stone wool choice)
         if (get_property("choiceAdventure579") == "2") friendlyset(582,"1","Go to the heights for the Nostril.");
          else if (item_amount($item[your father's MacGuffin diary]) > 0 && get_property("lastHiddenCityAscension").to_int() < my_ascensions())
           friendlyset(582,"2","Go to the Heart to unlock the Hidden City.");
          else friendlyset(582,"0","Non-quest-related support for the Hidden Temple is incomplete; show in browser.");
         return;
      case $location[hobopolis town square]:
         if (available_amount($item[hobo code binder]) == 0 && item_amount($item[hobo nickel]) >= 30)
            friendlyset(230,"1","Buy a hobo binder.");
          else friendlyset(230,"2","Skip binder purchasing (not enough nickels).");
         if (!have_equipped($item[hobo code binder]) || is_goal($item[hobo nickel]))
            friendlyset(272,"2","Skip marketplace (no binder equipped, or you have set nickels as a goal).");
          else friendlyset(272,"0","Show marketplace in browser.");
        // to add: tent?
         return;
      case $location[the island barracks]: friendlyset(409,"1","Continue (only one choice here anyway)");
         if (get_property("questG04Nemesis") != "finished" && hacienda_target("k","Get key deduced or indicated by clue.")) return;
         if (hacienda_target("0","Explore unknown choice.")) return;
         if (hacienda_target("r","Collect unvisited reward.")) return;
         if (hacienda_target("f",get_property("questG04Nemesis") == "finished" ? "Get remaining once-only loot from previous fight locations." : "All locations known; fight!")) return;
         if (get_property("questG04Nemesis") == "finished" && hacienda_target("F","Get remaining once-only loot from previous fight locations.")) return;
         hacienda_target("W","Hacienda cleared; head to Puttin' on the Wax.");
         return;
      case $location[kegger in the woods]:
         if (is_goal($item[orquette's phone number]) || item_amount($item[orquette's phone number]) < 20 || goal_exists("factoid"))
            friendlyset(457,"2","Keep getting phone numbers.");
          else friendlyset(457,"1","Turn in your "+item_amount($item[orquette's phone number])+" phone numbers for some neat prizes.");
         return;
      case $location[cobb's knob barracks]:
         if (have_outfit("knob goblin elite guard uniform")) friendlyset(522,"2","Ignore the Footlocker.");
          else friendlyset(522,"1","Complete the KGE Outfit.");
         return;
      case $location[a massive ziggurat]:
         if (item_amount($item[stone triangle]) == 4) friendlyset(my_path() == "Actually Ed the Undying"? 1002: 791,"1","Fight the final Protector Spectre.");
          else friendlyset(my_path() == "Actually Ed the Undying"? 1002: 791,"6","Not enough triangles; skip the Protector Spectre.");
         return;
      case $location[mer-kin colosseum]: if (!have_equipped(next_w())) equip(next_w()); return;
      case $location[mer-kin library]: if (get_property("merkinVocabularyMastery") != "100") return; int choice;
         foreach prop in $strings[dreadScroll1, dreadScroll6, dreadScroll8] if (get_property(prop) != "0") choice += 1;
         friendlyset(704,((choice + 1) % 4),choice == 3 ? "All card catalog clues found." : "Card Catalog clues found: "+rnum(choice));
         if (get_property("dreadScroll4") == "0" && item_amount($item[mer-kin knucklebone]) > 0) use(1,$item[mer-kin knucklebone]);
         return;
/*
	1: catalog
	2: healscroll
	3: Deep Dark Visions clue (cast when HP > 500 and spooky res >= 9)
	4: knucklebone
	5: killscroll
	6: catalog
	7: sushi with worktea
	8: catalog
*/
      case $location[the outskirts of cobb's knob]:
         if (item_amount($item[unlit birthday cake]) > 0)
            friendlyset(113,"1","Complete cake quest.");
          else if (is_goal($item[kiss the knob apron]))
            friendlyset(113,"3","Try for a Kiss the Knob apron.");
          else friendlyset(113,"2","Fight BBQ goblins.");
         return;
      case $location[inside the palindome]:
         if (is_goal($item[Ye Olde Navy Fleece]) && available_amount($item[Ye Olde Navy Fleece]) == 0)
            friendlyset(180,"1","Get Fleeced.");
          else if (available_amount($item[Ye Olde Navy Fleece]) > 0)
             friendlyset(180,"2","You've got a fleece. You cannot get another.");
         return;
      case $location[the penultimate fantasy airship]:
         if (is_goal($item[bronze breastplate]) && have_item($item[bronze breastplate]) == 0) friendlyset(178,"1","Get a bronze breastplate.");
          else friendlyset(178,"2","Skip breastplate.");
         switch {
            case available_amount($item[model airship]) < 1 && get_property("questL10Garbage") != "finished": friendlyset(182,"4","Get a model airship."); break;
            case has_goal($monster[MagiMechTech MechaMech]) > 0 && numeric_modifier("Monster Level") >= 20:
               friendlyset(182,"1","Fight a MechaMech for metallic A/bounty."); break;
            case has_goal($item[Penultimate Fantasy chest]) > 0 || get_property("choiceAdventure182") == "2":
               friendlyset(182,"2","Get goal of fantasy chests."); break;
            case my_level() < 13 && min(numeric_modifier("Combat Rate"), 0) /(-2.0) + 20 > (24 + numeric_modifier("Experience"))/2.0:
               friendlyset(182,"3","Get stats rather than weaker combat."); break;
            default: friendlyset(182,"1","Fight because you're gonna keep on fighting, yeah, you'll never give up.");
         }
         return;
      case $location[the primordial soup]:
        // to add: swim up or swim down?
         int upairs = 0;
         for i from 4011 to 4016 {                        // try to have three unique base pairs if possible
            if (item_amount(to_item(i)) > 0 || (creatable_amount(to_item(i)) > 0 && create(1,to_item(i))))
                upairs = upairs + 1;
            if (upairs > 2) return;
         }
         return;
      case $location[the road to the white citadel]: if ($strings[started, step1, step2, step3, step4] contains get_property("questG02Whitecastle") && 
            item_amount($item[opium grenade]) == 0 && creatable_amount($item[opium grenade]) > 0) create(1,$item[opium grenade]);
         return;
      case $location[the rowdy saloon]: if (item_amount($item[pocket ace]) > 0) friendlyset(998,"5","Cheat with your pocket ace.");
          else switch (item_amount($item[sleeve deuce])) {
             case 0: friendlyset(998,"1","Play without cheating since you have nothing to put up your sleeve."); break;
             case 1: friendlyset(998,"2","Cheat with your sleeve deuce."); break;
             case 2: friendlyset(998,"3","Cheat with two sleeve deuces! (20% chance of being caught and losing your deuces)"); break;
             default: friendlyset(998,"4","Cheat with three sleeve deuces! (40% chance of being caught and losing your deuces)"); break;
          }
         return;
      case $location[The Secret Council Warehouse]: if (item_amount($item[warehouse map page]) > 0 && item_amount($item[warehouse inventory page]) > 0) 
            use(1, $item[warehouse map page]); 
         return;
      case $location[The Shore, Inc. Travel Agency]:
         foreach i in $items[] if (sells_item($coinmaster[The Shore\, Inc. Gift Shop],i) && has_goal(i) > 0 &&
             item_amount($item[Shore Inc. Ship Trip Scrip]) >= sell_price($coinmaster[The Shore\, Inc. Gift Shop],i))
            buy($coinmaster[The Shore\, Inc. Gift Shop],1,i);
         use_goalcontaining_items();
         if (is_goal($stat[muscle])) friendlyset(793,"1","Take muscly vacations.");
          else if (is_goal($stat[mysticality])) friendlyset(793,"2","Take mystical vacations.");
          else friendlyset(793,"3","Take moxious vacations.");
         return;
      case $location[south of the border]:
         if ((!have_familiar($familiar[hovering sombrero]) && available_amount($item[poultrygeist]) +
              available_amount($item[hovering sombrero]) == 0 && my_path() != "Avatar of Boris") || is_goal($item[poultrygeist]))
            friendlyset(4,"2","Try for a poultrygeist.");
          else friendlyset(4,"3","Skip poultrygeist.");
         return;
      case $location[the spooky forest]:
        if (get_property("questL02Larva") == "started" && item_amount($item[mosquito larva]) == 0) {
            friendlyset(502,"2","Get mosquito larva");
            friendlyset(505,"1","Get mosquito larva");
        } else if (!hidden_temple_unlocked()) if (item_amount($item[tree-holed coin]) < 1 && item_amount($item[spooky temple map]) < 1) {
            friendlyset(505,"2","Get tree-holed coin.");
            friendlyset(502,"2","Get tree-holed coin.");
        } else if (item_amount($item[Spooky-Gro fertilizer]) < 1) {
            friendlyset(502,"3","Get Spooky-Gro fertilizer.");
            friendlyset(506,"2","Get Spooky-Gro fertilizer.");
        } else if (item_amount($item[tree-holed coin]) > 0) {
            friendlyset(502,"3","Get spooky temple map.");
            friendlyset(506,"3","Get spooky temple map.");
            friendlyset(507,"1","Get spooky temple map.");
        } else if (item_amount($item[spooky sapling]) < 1) {
            friendlyset(502,"1","Get spooky sapling.");
            set_property("choiceAdventure503","3");
            set_property("choiceAdventure504","3");
        } else use(1,$item[spooky temple map]);
        if (get_property("choiceAdventure503") == "3" && get_property("choiceAdventure504") == "3") {
           int closetbar = min(item_amount($item[bar skin]),
             to_int(have_skill($skill[armorcraftiness]) && available_amount($item[barskin buckler]) > 0) +
               ((have_skill($skill[Super-advanced meatsmithing])) ? min(0,
                ((have_skill($skill[Double-fisted skull smashing])) ? 2 : 1) -
               available_amount($item[bar whip])) : 0) -
           closet_amount($item[bar skin]));
           if (closetbar > 0) {
              vprint("Closeting "+closetbar+" bar skin"+(closetbar > 1 ? "s" : ""),"olive",3);
              put_closet(closetbar,$item[bar skin]);
           }
        }
        return;
      case $location[the spooky gravy burrow]:
         if (have_equipped($item[spooky glove]) && item_amount($item[inexplicably glowing rock]) > 0 && my_adventures() > 2)
            friendlyset(5,"1","Fight Felonia.");
          else friendlyset(5,"2","Skip Felonia.");
         return;
      case $location[sonofa beach]:
         if (!have_skill($skill[pulverize]) || item_amount($item[tenderizing hammer]) == 0) return;
         foreach its in $items[goatskin umbrella, wool hat] if (item_amount(its) == 1 && !is_goal(its)) cli_execute("pulverize 1 "+its);
         return;
      case $location[the typical tavern cellar]:
         if (numeric_modifier("Stench Damage") < 20) friendlyset(514, 1, "Less than +20 Stench Damage");
          else friendlyset(514,"2","Stink out the rats.");
         if (numeric_modifier("Spooky Damage") < 20) friendlyset(515, 1, "Less than +20 Spooky Damage");
          else friendlyset(515,"2","Scare off the rats.");
         if (numeric_modifier("Hot Damage") < 20) friendlyset(496, 1, "Less than +20 Hot Damage");
          else friendlyset(496,"2","Burn out the rats.");
         if (numeric_modifier("Cold Damage") < 20) friendlyset(513, 1, "Less than +20 Cold Damage");
          else friendlyset(513,"2","Freeze out the rats.");
        return;
      case $location[twin peak]:
         int twinPeakProgress = to_int(get_property("twinPeakProgress"));
         if (my_path() == "Bees Hate You") {
            friendlyset(606,"6","Shortcuts not available in BHY.");
            friendlyset(618,"2","Burn the hotel to the ground.");
         } else if ((twinPeakProgress & 1) == 0 && numeric_modifier("Stench Resistance") >= 4) {
            friendlyset(606,"1","Investigate the stinky room.");
            friendlyset(607,"1","");
         } else if ((twinPeakProgress & 2) == 0 && foodDrop() >= 50) {
            friendlyset(606,"2","Search for food.");
            friendlyset(608,"1","");
         } else if ((twinPeakProgress & 4) == 0 && item_amount($item[jar of oil]) > 0) {
            friendlyset(606,"3","Follow the music with a jar of oil.");
            friendlyset(609,"1","");
            friendlyset(616,"1","");
        } else if (twinPeakProgress == 7 && numeric_modifier("Initiative") >= 40) {
            friendlyset(606,"4","Chase your doppleganger.");
            friendlyset(610,"1","");
            friendlyset(617,"1","");
        } else friendlyset(606,"0","What to do here?");
        return;
      case $location[waste processing]: while (get_property("statusWasteProcessing") != "cleared" && item_amount($item[handful of juicy garbage]) > 0 &&
            have_item($item[bugbear communicator badge]) == 0) use(1,$item[handful of juicy garbage]);
         if (!have_equipped($item[bugbear communicator badge]) && item_amount($item[bugbear communicator badge]) > 0) equip($slot[acc3],$item[bugbear communicator badge]);
         return;
      case $location[whitey's grove]:
         if (is_goal($item[piece of wedding cake]) || is_goal($item[white rice]))
            friendlyset(73,"3","Get goal cake/rice.");
          else if (is_goal($item[white picket fence]))
            friendlyset(73,"2","Get a white picket fence.");
          else friendlyset(73,"1","Get muscle stats.");
         return;
        // two more choiceadvs?
/*
      case $location[]:
         if ()
            friendlyset( ,"2","");
          else friendlyset( ,"0","");
         return;
*/
   }
}

boolean fight_items() {
   if (my_adventures() == 0) return true;
   if (get_counters("",0,0) != "") return vprint("Expiring counter, not fighting items.",6);
   switch (have_effect($effect[absinthe-minded])) {
     case 0: case 10: case 6: case 3: case 2: break; default: return vprint("Avoiding possible Wormwood conflict, not fighting items.",6);
   }
  // 1. dolphins
   if (to_item(get_property("dolphinItem")) != $item[none]) {
      if ((has_goal(to_item(get_property("dolphinItem"))) > 0 && get_property("dolphinItem") != "sand dollar") || (count(get_goals()) == 0 && to_boolean(vars["bbb_dolphin_goodies"]) &&
           mall_price(to_item(get_property("dolphinItem"))) > 2*(min(mall_price($item[sand dollar]),mall_price($item[dolphin whistle])) + get_property("valueOfAdventure").to_int()))) {
         vprint("Whistling for a "+get_property("dolphinItem")+"...","blue",2);
         restore_hp(0);     // recover here since recovery is not triggered normally
         if (item_amount($item[dolphin whistle]) > 0) cli_execute("refresh inv");  // sometimes they don't disappear from inventory and you have ghosts
         if (retrieve_item(1,$item[dolphin whistle])) use(1,$item[dolphin whistle]);
      }
   }
  // 2-4. putty monsters, rain-doh boxes, 4-d cameras
   boolean fight_this(item i, string mprop) {
      if (item_amount(i) == 0 || (i == $item[shaking 4-d camera] && get_property("_cameraUsed") == "true")) return true;
      if (get_property(mprop+"Monster") == "") vprint("You have a "+i+", but mafia doesn't know what it is.",-2);
      if (has_goal(to_monster(get_property(mprop+"Monster"))) == 0 && (to_item(to_int(get_property("currentBountyItem"))) == $item[none] || 
       !(item_drops(to_monster(get_property(mprop+"Monster"))) contains to_item(to_int(get_property("currentBountyItem")))))) return true;
      restore_hp(0);     // recover here since recovery is not triggered normally
      restore_mp(0);
      use(1,i);
      return fight_items();
   }
   // if (!to_boolean(get_property("_cameraUsed")))
   fight_this($item[shaking 4-d camera], "camera");
   fight_this($item[spooky putty monster], "spookyPutty");
   fight_this($item[Rain-Doh box full of monster], "rainDoh");
   return true;
}

boolean use_fam(familiar f) {
   use_familiar(f);
   if (to_boolean(vars["bbb_famitems"])) switch (my_familiar()) {
      case $familiar[artistic goth kid]:
      case $familiar[astral badger]:     // these equipments speed rewards from fams
      case $familiar[knob goblin organ grinder]: if (!have_equipped(familiar_equipment(my_familiar())) && available_amount(familiar_equipment(my_familiar())) > 0 &&
         retrieve_item(1,familiar_equipment(my_familiar()))) equip(familiar_equipment(my_familiar())); break;
     // TODO: snow suit drops?
   }
   cli_execute("checkpoint clear");
   return (my_familiar() == f);
}

familiar dropfam() {
   if (my_location().environment == "underwater" || $locations[none, the slime tube] contains my_location()) return my_familiar();
   boolean has_more_drop(familiar f, int soft) {
      boolean clim(string prop, int hard) { return to_int(get_property(prop)) < min(soft,hard); }
      switch(f) {
         case $familiar[gelatinous cubeling]: return (available_amount($item[eleven-foot pole]) == 0 || 
            available_amount($item[ring of detect boring doors]) == 0 || available_amount($item[pick-o-matic lockpicks]) == 0);
         case $familiar[happy medium]: return clim("_mediumSiphons",20);
         case $familiar[knob goblin organ grinder]: return clim("_pieDrops",5);
         case $familiar[artistic goth kid]: if (!hippy_stone_broken() && have_familiar($familiar[mini-hipster])) return false;
         case $familiar[mini-hipster]: if (!contains_text(to_url(my_location()),"adventure.php")) return false; return clim("_hipsterAdv",7);
         case $familiar[pair of stomping boots]: foreach i,m in get_monsters(my_location()) if (!($phyla[dude,none] contains m.phylum)) return clim("_pasteDrops",7); return false;
         case $familiar[green pixie]: if (have_effect($effect[absinthe-minded]) > 0) return false; break;
      }
      return f.drops_today < min(soft,f.drops_limit);
   }
  for i from 1 upto 10
    foreach f in $familiars[] if (have_familiar(f) && !(
          $familiars[cotton candy carnie]          // list familiars here you want to SKIP
       contains f) && has_more_drop(f,i)) return f;
   return my_familiar();
}

boolean fam_check() {
   if ($classes[avatar of boris, avatar of jarlsberg] contains my_class() || my_location() == $location[The Spooky Gravy Burrow]) return true;
  // first, enforce 100% runs
   if (to_familiar(vars["is_100_run"]) != $familiar[none]) {
      if (my_familiar() != to_familiar(vars["is_100_run"])) return use_fam(to_familiar(vars["is_100_run"]));
      return vprint("Not swapping familiar; is_100_run setting is set to "+my_familiar(),9);
   }
  // farm familiar items if set
   if (!to_boolean(vars["bbb_famitems"])) return true;
   return use_fam(dropfam());
}

// NOTE: after running this script, changing these variables here in the script will have no
// effect.  You should instead edit the values by typing "zlib vars" in the CLI.
setvar("auto_semirare","timely");     // auto-eat fortune cookies: always, timely, never (maxcounters)
setvar("bbb_miniboss_items",1);       // vs.-miniboss items to get in the defiled cyrpt areas before getting stats
setvar("bbb_adjust_choiceadvs",true); // enable/disable choiceadv adjustment
setvar("bbb_dolphin_goodies",true);   // toggle automatically fighting dolphins for valuable non-goal items
setvar("bbb_famitems",false);         // toggle automatically farming familiar-dropped items
check_version("Best Between Battle","bestbetweenbattle",1240);

/*
void hacienda_tracking() {
   if (get_property("lastHaciendaReset").to_int() < my_ascensions() || get_property("haciendaLayout").length() < 19) {
      set_property("haciendaLayout","0000000000000000000");
      set_property("lastHaciendaReset",my_ascensions());
   }
   buffer hl;
   hl.append(get_property("haciendaLayout"));
   if (get_property("questG04Nemesis") == "finished" && !contains_text(hl,"W")) {  // W for Puttin' on the Wax
      hl.replace(17,18,"W");
      set_property("haciendaLayout",hl);
   }
   boolean save_room(int r, string value) {
      if (r < 0 || r > 18 || value.length() != 1 || value == char_at(hl,r)) return true;
      if ($strings[R,K,C,W] contains char_at(hl,r))
         return vprint("Room "+r+" already contains content: "+char_at(hl,r),-2);
      hl.replace(r,r+1,value);
      set_property("haciendaLayout",hl);
      if (get_property("questG04Nemesis") != "finished") {  // deduce room when 2/3 are known
         int[string] cont;  
         for i from (value - (value % 3)) to (value - (value % 3) + 2) cont[to_lower_case(hl.char_at(i))] += 1;
         if (cont["0"] == 1) if (!(cont contains "f")) save_room(index_of(hl,"0",value - (value % 3)),"f");
          else if (!(cont contains "r")) save_room(index_of(hl,"0",value - (value % 3)),"r");
          else save_room(index_of(hl,"0",value - (value % 3)),"k");
      }
      return vprint("BBB: Hacienda room "+r+" set to '"+value+"'.","#F87217",4);
   }
   string log = session_logs(1)[0] + session_logs(2)[1];
   matcher cres; int room;
   vprint(hl,9);
   for i from 413 to 418
      for j from 1 to 3 {
         room = (i - 413)*3 + j - 1;
         cres = create_matcher("choice.php\\?(?:pwd&)?whichchoice="+i+"&option="+j+"(?:&pwd)?\\r(.*?)[$\\r]",log);
         while ($strings[F,0,f,r,k] contains hl.char_at(room) && cres.find()) {
            vprint(i+"/"+j+": "+cres.group(1),9);
            switch {
               case (index_of(cres.group(1),"Round 0:") == 1): save_room(room,"F"); break;
               case (index_of(cres.group(1),"hacienda key") > 15): save_room(room,"K"); break;
               case (create_matcher("You gain \\d+ Meat",cres.group(1)).find()):
               case (index_of(cres.group(1),"You acquire ") == 1): save_room(room,"R"); break;
               default: save_room(room,"C");
            }
         }
      }
}
*/

void bbb() {
  // reactions to previous encounters; expect this to get fleshed out with more ascensions
   switch (get_property("lastEncounter")) {
      case "A Grave Situation": for i from 1 to 2 visit_url("guild.php?place=ocg"); break;           // turn in, then re-collect key
      case "Screwdriver, wider than a mile": visit_url("forestvillage.php?place=untinker"); break;   // complete untinker quest
      case "The Fast and the Furry-ous": switch (get_property("choiceAdventure669")) {               // equip zone-unlocking items if script has set the choice to repeat for it
         case "3": cli_execute("checkpoint"); equip($item[titanium assault umbrella]); break;
         case "1": if (have_equipped($item[titanium assault umbrella])) cli_execute("outfit checkpoint");
      } break;
      case "You Don't Mess Around with Gym": switch (get_property("choiceAdventure670")) {
         case "5": cli_execute("checkpoint"); equip($slot[acc3],$item[amulet of extreme plot significance]); break;
         case "4": if (have_equipped($item[amulet of extreme plot significance])) cli_execute("outfit checkpoint");
      } break;
      case "Keep On Turnin' the Wheel in the Sky": visit_url("council.php"); break;
   }
   if (have_equipped($item[bag o' tricks]) && (run_combat().contains_text("a single fat bumblebee") || run_combat().contains_text("You open the bag and ")))
      set_property("bagOTricksCharges","0");
  // exchange tokens for tickets if they'll probably be needed
   if (!can_interact()) for i from 1 upto min((spleen_limit() - my_spleen_use())/ 4- (item_amount($item[Game Grid ticket])/10 +
     item_amount($item[not-a-pipe]) + item_amount($item[glimmering roc feather]) + item_amount($item[agua de vida]) +
     item_amount($item[coffee pixie stick])), item_amount($item[Game Grid token]))
      visit_url("arcade.php?action=skeeball&pwd");
  // if you have BatBrain, make sure pricing information is relatively current for your combat items
   if (svn_exists("batbrain")) foreach i in get_inventory() if (i.combat && sell_val(i,3) == 0) {}
   cookiecheck();
   use_goalcontaining_items();
   fight_items();
   fam_check();
   set_choiceadvs();
   auto_mcd(my_location());
}
void main() { bbb(); }
