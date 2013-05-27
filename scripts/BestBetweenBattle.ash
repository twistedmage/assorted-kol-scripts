/******************************************************************************

                      Best Between Battle by Zarqon
*******************************************************************************



     - sets your MCD for maximum stat gains -- enabled/disabled by [automcd]
     - intelligently adjusts choiceAdvs -- enabled/disabled by [bbb_adjust_choiceadvs]
     - uses items containing goals -- move containers to closet to avoid use
     - fights putty monsters/4-d camera monsters for bounties and specified goals
     - whistles for dolphins to get goals or items worth at least 2x the cost of whistling
     - auto-tames up to n turtles in each zone as a TT -- specify n in [bbb_turtles]
     - eats fortune cookies automatically -- set [auto_semirare] to "always", "timely", or "never"


   Have a suggestion to improve this script?  Visit
   http://kolmafia.us/showthread.php?t=1240


   Want to say thanks?  Send me a bat! (Or bat-related item)

******************************************************************************/
script "BestBetweenBattle.ash";
import <zlib.ash>

boolean cookiecheck() {
   if (my_fullness() >= fullness_limit() || !can_eat()) return true;
   matcher cooks = create_matcher("(timely|always|true|never|false) ?([1-3]?)",vars["auto_semirare"]);
   if (!cooks.find()) return vprint("Warning: your auto_semirare setting is not an accepted value: timely|always|never (maximumcounters)",-5);
   switch (cooks.group(1)) {
      case "timely": if (get_counters("Fortune Cookie",-1,200) != "" || get_counters("Semirare window begin",1,200) != "")
         return vprint("BBB: No need to eat a cookie given the present counters.","#F87217",8);
         if (my_location() != to_location(get_property("semirareLocation")) && $locations[Purple Light District, Haunted Billiards Room,
             Menagerie 2, Outskirts of The Knob, Limerick Dungeon, Sleazy Back Alley, Haunted Pantry, Harem] contains my_location())
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

// CHOICEADVS!!
void set_choiceadvs() {       // this is where the arduous magic happens.
   if (!to_boolean(vars["bbb_adjust_choiceadvs"])) return;
   void friendlyset(int choiceadv, string value, string explan) { if (get_property("choiceAdventure"+choiceadv) == value) return;
      vprint("BBB: "+explan,"#F87217",2); set_property("choiceAdventure"+choiceadv,value); }
   boolean need_temple() {
      if (hidden_temple_unlocked()) return false;
      if (item_amount($item[mosquito larva]) > 0) return true;
      foreach key in $items[tree-holed coin, spooky sapling, spooky temple map, spooky-gro fertilizer]
         if (is_goal(key)) return true;
        return false;
   }
   switch (my_location()) {
      case $location[an octopus's garden]:
         if (item_amount($item[glob of green slime]) > 0 && item_amount($item[soggy seed packet]) > 0)
            for i from 3555 to 3560 if (is_goal(to_item(i)) && (have_equipped($item[straw hat]) || equip($item[straw hat]))) {
               friendlyset(298,"1","Plant seeds to get a sea fruit/vegetable goal."); return;
            }
         friendlyset(298,"2","Skip planting seeds. ("+item_amount($item[soggy seed packet])+" seed packets, "+item_amount($item[glob of green slime])+" green slime)");
         return;
      case $location[batrat and ratbat burrow]:
      case $location[guano junction]:
      case $location[beanbat chamber]: if (last_monster() == $monster[Screambat] && is_goal($item[sonar-in-a-biscuit]))
         remove_item_condition(1,$item[sonar-in-a-biscuit]); return;
      case $location[black forest]:
         if (is_goal($item[blackberry galoshes]) || (!have_skill($skill[unaccompanied miner]) && available_amount($item[blackberry galoshes]) == 0 &&
             item_amount($item[map to ellsbury's claim]) > 0)) { friendlyset(177,"4","Get goal/skill galoshes."); return; }
         if (is_goal($item[blackberry slippers])) { friendlyset(177,"1","Get goal of blackberry slippers."); return; }
         if (is_goal($item[blackberry moccasins])) { friendlyset(177,"2","Get goal of blackberry moccasins."); return; }
         if (is_goal($item[blackberry combat boots])) { friendlyset(177,"3","Get goal of blackberry combat boots."); return; }
         switch (my_primestat()) {
            case $stat[moxie]: if (available_amount($item[blackberry moccasins]) == 0)
                { friendlyset(177,"2","Get moxie-class blackberry shoes."); return; } else break;
            case $stat[muscle]: if (available_amount($item[blackberry combat boots]) == 0)
                { friendlyset(177,"3","Get muscle-class blackberry shoes."); return; } else break;
            default: if (available_amount($item[blackberry slippers]) == 0)
                { friendlyset(177,"1","Get myst-class blackberry shoes."); return; }
         }
         friendlyset(177,"5","Skip getting blackberry shoes.");
         return;
      case $location[defiled alcove]:
         if (my_path() != "Bees Hate You" && item_amount($item[half-rotten brain]) < to_int(vars["bbb_miniboss_items"]))
            friendlyset(153,"3","Get "+vars["bbb_miniboss_items"]+" half-rotten brains.");
          else if (my_primestat() == $stat[muscle]) friendlyset(153,"1","Get muscle stats.");
          else friendlyset(153,"4","Skip brains/non-primestat choiceadv.");
         return;
      case $location[defiled nook]:
         if (my_path() != "Bees Hate You" && item_amount($item[rusty bonesaw]) < to_int(vars["bbb_miniboss_items"]))
            friendlyset(155,"3","Get "+vars["bbb_miniboss_items"]+" rusty bonesaws.");
			//SIMON CHANGED
          else if (my_primestat() == $stat[moxie]) friendlyset(155,"1","Get moxie stats.");
          else friendlyset(155,"4","Skip non-primestat choiceadv.");
         return;
      case $location[defiled niche]:
         if (item_amount($item[plus-sized phylactery]) == 0 && to_int(vars["bbb_miniboss_items"]) > 0)
            friendlyset(157,"2","Get a plus-sized phylactery.");
          else if (my_primestat() == $stat[mysticality]) friendlyset(157,"1","Get mysticality stats.");
          else friendlyset(157,"4","Skip phylactery/non-primestat choiceadv.");
         return;
      case $location[defiled cranny]:
         if (my_path() != "Bees Hate You" && item_amount(to_item("Ghuol-B-Gone")) < to_int(vars["bbb_miniboss_items"]))
            friendlyset(523,"3","Get "+vars["bbb_miniboss_items"]+" cans of Ghuol-B-Gone.");
          else friendlyset(523,"4","Fight evil whelp swarms.");
         return;
      case $location[dungeons of doom]:
         if (is_goal($item[magic lamp]) && my_meat() > 49)
            friendlyset(25,"1","Get goal magic lamp.");
          else if (my_meat() > 4999 && has_goal($item[dead mimic]) > 0) friendlyset(25,"2","Fight a mimic.");
           else friendlyset(25,"3","Skip mimic/lamp.");
         return;
      case $location[fantasy airship]:
         if (is_goal($item[bronze breastplate]))
            friendlyset(178,"1","Get a bronze breastplate.");       // get a breastplate
          else if (available_amount($item[bronze breastplate]) > 0) friendlyset(178,"2","Skip breastplate.");    // skip
         switch {
            case (get_property("currentBountyItem").to_item() == $item[burned-out arcanodiode] ||
                   available_amount($item[metallic A]) < 1) && numeric_modifier("Monster Level") >= 20:
               friendlyset(182,"1","Fight a MechaMech for metallic A/bounty."); break;
            case is_goal($item[Penultimate Fantasy chest]) || get_property("choiceAdventure182") == "2":
               friendlyset(182,"2","Get goal of fantasy chests."); break;
			case (item_amount($item[model airship])<1):
               friendlyset(182,"4","Get a model airship."); break;
            case min(numeric_modifier("Combat Rate"), 0) /(-2.0) + 20 > (24 + numeric_modifier("Experience"))/2.0:
               friendlyset(182,"3","Get stats rather than weaker combat."); break;
            default: friendlyset(182,"1","Fight a MechaMech just because.");
         }
         return;
      case $location[fun house]:
         if (numeric_modifier("clownosity") < 4)
            friendlyset(151,"2","Skip Beelzebozo due to insufficient clownosity.");
          else friendlyset(151,"1","Fight Beelzebozo.");
         return;
      case $location[haunted bedroom]:
         if (have_item("lord spookyraven's spectacles") == 0)
             friendlyset(84,"3","Get Spooky's specs from the ornate nightstand.");
          else if (my_primestat() == $stat[mysticality])
            friendlyset(84,"2","Get myst stats from the ornate nightstand.");
           else friendlyset(84,"1","Get meat from the ornate nightstand.");
         return;
      case $location[haunted billiards room]:             // allows you to set 1 library key as a condition!
         if (item_amount($item[spookyraven library key]) == 0 && have_item("pool cue") > 0 &&
             have_effect($effect[chalky hand]) == 0 && item_amount($item[handful of hand chalk]) > 0)
            use(1,$item[handful of hand chalk]);
         return;
      case $location[haunted library]:
         if (get_property("lastSecondFloorUnlock").to_int() != my_ascensions())  // Rise
            friendlyset(80,"99","Unlock second floor.");
          else if (get_property("choiceAdventure80") != "3") friendlyset(80,"4","Skip Rise of Spookyraven.");
		  //SIMON : modified for bugbears
         if (get_property("lastGalleryUnlock").to_int() != my_ascensions() &&    // Fall
             (my_primestat() == $stat[muscle] || my_level() > 13 ||
			 to_item(get_property("currentBountyItem")) == $item[non-euclidean hoof]) || my_path() == "Bugbear Invasion") {
            friendlyset(81,"1","Read stuff about pet alligators or something.");
            set_property("choiceAdventure87", "2");
         } else {
            if (get_property("lastSecondFloorUnlock").to_int() != my_ascensions())
               friendlyset(81,"99","Unlock second floor.");
             else if (get_property("choiceAdventure81") != "3") friendlyset(81,"4","Skip Fall of Spookyraven.");
         }
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
      case $location[kegger in the woods]:
         if (is_goal($item[orquette's phone number]) || item_amount($item[orquette's phone number]) < 20)
            friendlyset(457,"2","Keep getting phone numbers.");
          else friendlyset(457,"1","Turn in your "+item_amount($item[orquette's phone number])+" phone numbers for some neat prizes.");
         return;
      case $location[knob barracks]:
         if (have_outfit("knob goblin elite guard uniform")) friendlyset(522,"2","Ignore the Footlocker.");
          else friendlyset(522,"1","Complete the KGE Outfit.");
         return;
      case $location[outskirts of the knob]:
         if (item_amount($item[unlit birthday cake]) > 0)
            friendlyset(113,"1","Complete cake quest.");
          else if (is_goal($item[kiss the knob apron]))
            friendlyset(113,"3","Try for a Kiss the Knob apron.");
          else friendlyset(113,"2","Fight BBQ goblins.");
         return;
      case $location[palindome]:
        if (is_goal($item[Ye Olde Navy Fleece]) && available_amount($item[Ye Olde Navy Fleece]) == 0)
           friendlyset(180,"1","Get Fleeced.");
         else if(available_amount($item[Ye Olde Navy Fleece]) > 0)
            friendlyset(180,"2","You've got a fleece. You cannot get another.");
        return;
      case $location[primordial soup]:
        // to add: swim up or swim down?
         int upairs = 0;
         for i from 4011 to 4016 {                        // try to have three unique base pairs if possible
            if (item_amount(to_item(i)) > 0 || (creatable_amount(to_item(i)) > 0 && create(1,to_item(i))))
                upairs = upairs + 1;
            if (upairs > 2) return;
         }
         return;
      case $location[south of the border]:
         if ((!have_familiar($familiar[hovering sombrero]) && available_amount($item[poultrygeist]) == 0 &&
              available_amount($item[hovering sombrero]) == 0) || is_goal($item[poultrygeist]))
            friendlyset(4,"2","Try for a poultrygeist.");
          else friendlyset(4,"3","Skip poultrygeist.");
         return;
      case $location[spooky forest]:
        if (is_goal($item[mosquito larva])) {
            friendlyset(507,"1","Get mosquito larva");
            friendlyset(505,"1","Get mosquito larva");
            friendlyset(502,"2","Get mosquito larva");
            return;
        }
        if (need_temple() && item_amount($item[tree-holed coin]) < 1 && item_amount($item[spooky temple map]) < 1) {
            friendlyset(505,"2","Get tree-holed coin.");
            friendlyset(502,"2","Get tree-holed coin.");
        } else if (item_amount($item[tree-holed coin]) > 0) {
            friendlyset(507,"1","Get spooky temple map.");
            friendlyset(506,"3","Get spooky temple map.");
            set_property("choiceAdventure502","3");
        } else if (item_amount($item[spooky temple map]) > 0) {
            if (item_amount($item[Spooky-Gro fertilizer]) < 1) {
                friendlyset(506,"2","Get Spooky-Gro fertilizer.");
                set_property("choiceAdventure502","3");
            } else if (item_amount($item[spooky sapling]) < 1) {
                friendlyset(502,"1","Get spooky sapling.");
                set_property("choiceAdventure503","3");
                set_property("choiceAdventure504","3");
            }
        }
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
/*
        // set subtrees (vampires, corpses)
         if (to_int(vars["bbb_vampire_hearts"]) > 0) {
            friendlyset(46,"3","Fight more vampires.");
            if (!have_equipped($item[wooden stakes]) && item_amount($item[wooden stakes]) > 0)
               equip($item[wooden stakes]);
            if (item_amount($item[vampire heart]) < to_int(vars["bbb_vampire_hearts"]))
               friendlyset(47,"2","Skip bottles of blood until you have "+vars["bbb_vampire_hearts"]+" vampire hearts.");
             else friendlyset(47,"1","Collect bottles of blood.");
         }
        // determine if we need class-specific items
         boolean yestt;
         if (my_class() == $class[turtle tamer]) yestt = true;
          else for i from 2007 to 2012 if (to_skill(i) != $skill[none] && have_skill(to_skill(i))) yestt = true;
         boolean yesat;
         if (my_class() == $class[accordion thief]) yesat = true;
          else for i from 6003 to 6026 if (to_skill(i) != $skill[none] && have_skill(to_skill(i))) yesat = true;
        // loot corpses
         if (is_goal($item[stolen accordion]) || is_goal($item[mariachi pants])) {
            friendlyset(26,"3","Loot AT corpse for goals.");
            set_property("choiceAdventure29","2");
         } else if (is_goal($item[helmet turtle]) || is_goal($item[turtle totem])) {
            friendlyset(26,"1","Loot TT corpse for goals.");
            set_property("choiceAdventure27","2");
         } else if (is_goal($item[saucepan]) || is_goal($item[spices])) {
            friendlyset(26,"2","Loot S corpse for goals.");
            set_property("choiceAdventure28","2");
         } else if (is_goal($item[disco mask]) || is_goal($item[disco ball])) {
            friendlyset(26,"3","Loot DB corpse for goals.");
            set_property("choiceAdventure29","1");
         } else if (is_goal($item[seal-clubbing club]) || is_goal($item[seal-skull helmet])) {
            friendlyset(26,"1","Loot SC corpse for goals.");
            set_property("choiceAdventure27","1");
         } else if (is_goal($item[pasta spoon]) || is_goal($item[ravioli hat])) {
            friendlyset(26,"2","Loot PM corpse for goals.");
            set_property("choiceAdventure28","1");
         } else if (yesat && available_amount($item[stolen accordion]) + available_amount($item[calavera concertina]) +
             available_amount($item[Rock and Roll Legend]) + available_amount($item[Squeezebox of the Ages]) +
             available_amount($item[Trickster Trikitixa]) == 0) {
            friendlyset(26,"3","Loot AT corpse for accordion so you can cast your skills.");
            set_property("choiceAdventure29","2");
         } else if (yestt && available_amount($item[turtle totem]) == 0 && available_amount($item[Mace of the Tortoise]) == 0 &&
             available_amount($item[Chelonian Morningstar]) + available_amount($item[flail of the seven aspects]) == 0) {
            friendlyset(26,"1","Loot TT corpse for totem so you can cast your skills.");
            set_property("choiceAdventure27","2");
         } else {
            friendlyset(26,"2","Loot S corpse for spices (default).");
            set_property("choiceAdventure28","2");
         }
        // main choice: 502
         return;
*/
      case $location[spooky gravy barrow]:
         if (have_equipped($item[spooky glove]) && item_amount($item[inexplicably glowing rock]) > 0 && my_adventures() > 2)
            friendlyset(5,"1","Fight Felonia.");
          else friendlyset(5,"2","Skip Felonia.");
         return;
      case $location[wartime sonofa beach]:
         if (!have_skill($skill[pulverize])) return;
         foreach its in $items[goatskin umbrella, wool hat] if (item_amount(its) == 1 && !is_goal(its)) cli_execute("pulverize 1 "+its);
         return;
      case $location[whitey grove]:
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

void use_goalcontaining_items() {
   if (my_path() != "Way of the Surprising Fist" && !can_interact()) cli_execute("sell * meat stack; sell * dense meat stack");
   cli_execute("use * evil eye");
   while (item_amount($item[gnollish toolbox]) > 0 && be_good($item[gnollish toolbox]) && (is_goal($item[bitchin' meatcar]) || is_goal($item[meat engine])))
      use(1,$item[gnollish toolbox]);
   if (count(useforitems) == 0 && !load_current_map("use_for_items", useforitems)) return;
   foreach cont,res,chance in useforitems
      while (item_amount(cont) > 0 && be_good(cont) && is_goal(res) && chance > 0) use(1,cont);
}

boolean fight_items() {
   if (my_adventures() == 0) return true;
   if (get_counters("",0,0) != "") return vprint("Expiring counter, not fighting items.",6);
   switch (have_effect($effect[absinthe-minded])) {
     case 0: case 10: case 6: case 3: case 2: break; default: return vprint("Avoiding possible Wormwood conflict, not fighting items.",6);
   }
  // 1. dolphins
   if (get_counters("Dolphin",1,11) == "" && to_item(get_property("dolphinItem")) != $item[none]) {
      boolean no_goals_here() {
         foreach num,mob in get_monsters(my_location()) if (has_goal(mob) > 0) return false;
         return true;
      }
      if ((has_goal(to_item(get_property("dolphinItem"))) > 0 && get_property("dolphinItem") != "sand dollar") || (no_goals_here() &&
           mall_price(to_item(get_property("dolphinItem"))) > 2*(min(mall_price($item[sand dollar]),mall_price($item[dolphin whistle])) + get_property("valueOfAdventure").to_int()))) {
         if (item_amount($item[dolphin whistle]) == 0 && mall_price($item[dolphin whistle]) > mall_price($item[sand dollar]) && retrieve_item(1,$item[sand dollar]))
            visit_url("monkeycastle.php?pwd&action=buyitem&whichitem=3997&quantity=1");
         vprint("Whistling for a "+get_property("dolphinItem")+"...","blue",2);
         if (retrieve_item(1,$item[dolphin whistle])) use(1,$item[dolphin whistle]);
      }
   }
  // 2. 4-d camera monsters
   if (item_amount($item[shaking 4-d camera]) > 0 && get_property("_cameraUsed") != "true" &&
       has_goal(to_monster(get_property("cameraMonster"))) > 0)
      use(1,$item[shaking 4-d camera]);
  // 3. putty monsters
   if (item_amount($item[spooky putty monster]) == 0) return vprint("You don't have any spooky putty monsters.",9);
   if (get_property("spookyPuttyMonster") == "")
      return vprint("You have a putty monster, but mafia doesn't know what it is.",-2);
   if (item_amount($item[spooky putty monster]) > 0 && has_goal(to_monster(get_property("spookyPuttyMonster"))) > 0) {
      use(1,$item[spooky putty monster]);
      return fight_items();
   }
   return true;
}

record turtle_rec {
   item turtle;      // which turtle can be found
   item thing;       // what can be made from the turtle
   int tier;         // 1: pheromones only, 2: also needs rod, 3: also needs familiar
};
turtle_rec[location] tdata;
turtle_rec tort;
boolean use_fam(familiar f) {
   use_familiar(f);
   cli_execute("checkpoint clear");
   return (my_familiar() == f);
}

boolean ensure_turtlefam(boolean really) {
   if ($familiars[grinning turtle, syncopated turtle] contains my_familiar()) return true;
   if (!($familiars[none,grinning turtle,syncopated turtle] contains to_familiar(vars["is_100_run"]))) return false;
   familiar[int] tfams;
   tfams[to_int(can_interact())] = $familiar[grinning turtle];
   tfams[to_int(!can_interact())] = $familiar[syncopated turtle];
   foreach key,pet in tfams
      if (have_familiar(pet)) { if (really) return use_fam(pet); return true; }
       else if (item_amount(to_item(to_string(pet))) > 0) {
          use(1,to_item(to_string(pet)));
          if (really) return use_fam(pet); return have_familiar(pet);
       }
   return false;
}

boolean should_tame() {
   if (tort.tier == 3 && !ensure_turtlefam(false)) return false;
   if (tort.tier > 1 && (my_path() == "Way of the Surprising Fist" || weapon_hands(equipped_item($slot[weapon])) == 2)) return false;
   if (to_boolean(vars["bbb_turtlegear"])) {         // handle turtle wax item creation order
      if (item_amount($item[turtle wax shield]) > 0 && have_item($item[turtle wax helmet]) == 0) use(1,$item[turtle wax shield]);
      if (item_amount($item[turtle wax helmet]) > 0 && have_item($item[turtle wax greaves]) == 0) use(1,$item[turtle wax helmet]);
      if (tort.thing != $item[none] && have_item(tort.thing) == 0 && creatable_amount(tort.thing) > 0 && create(1,tort.thing)) {}
   }
   int templimit;
   switch (tort.turtle) {
      case $item[knobby helmet turtle]:              // if bbb_turtlegear, ensure enough turtles to create gear requiring multiple
      case $item[soup turtle]:
      case $item[furry green turtle]: if (to_boolean(vars["bbb_turtlegear"]) && have_item(tort.thing) == 0) templimit = 2;
      case $item[turtle wax]: foreach itm in $items[turtle wax shield,turtle wax helmet,turtle wax greaves]
         if (have_item(itm) == 0) return true; break;
      case $item[turtlemail bits]: foreach itm in $items[turtlemail coif,turtlemail breeches,turtlemail hauberk]
         if (have_item(itm) == 0 && (!to_boolean(vars["bbb_turtlegear"]) || creatable_amount(itm) == 0 || !create(1,itm))) return true; break;
      case $item[hedgeturtle]: foreach itm in $items[spiky turtle helmet,spiky turtle shield,spiky turtle shoulderpads]
         if (have_item(itm) == 0 && (!to_boolean(vars["bbb_turtlegear"]) || creatable_amount(itm) == 0 || !create(1,itm))) return true; break;
   }
   if (item_type(tort.turtle) == "familiar larva") {
      familiar famgoal;
      if (tort.turtle == $item[sleeping wereturtle]) famgoal = $familiar[wereturtle];
       else famgoal = to_familiar(to_string(tort.turtle));
      if (!have_familiar(famgoal) && item_amount(tort.turtle) > 0) use(1,tort.turtle);
      templimit = 2;
   }
   return (have_item(tort.turtle) < max(to_int(vars["bbb_turtles"]),templimit));
}

void taming_reset() {
   if (tort.tier > 1) cli_execute("outfit checkpoint");
   if (tort.tier == 3 && contains_text(get_property("temp"),"|")) use_fam(to_familiar(excise(get_property("temp"),"|","")));
   set_property("taming","");
}

boolean now_taming() {
   if (get_property("taming") == "") return false;          // turtle already found
   switch (have_effect($effect[eau de tortue])) {
      case 1: case 2: return (have_item($item[Garter of the Turtle Poacher]) > 0);
      case 3: return true;
      case 4: case 5: case 6: case 7:
      case 8: case 9: case 10: if (have_item($item[Garter of the Turtle Poacher]) > 0) {
         taming_reset(); return false;
      } return true;
   }
   return false;
}

boolean taming_check() {
   if (my_class() != $class[turtle tamer] || !guild_store_available()) return true;
   if (have_equipped($item[fouet de tortue-dressage]) && my_location() == $location[outer compound] &&
       have_effect($effect[eau de tortue]) == 0 && get_property("lastNemesisReset").to_int() < my_ascensions() && retrieve_item(1,$item[turtle pheromones]))
      use(1,$item[turtle pheromones]);
   if (to_int(vars["bbb_turtles"]) == 0) return true;
   if (!load_current_map("turtles",tdata)) return vprint("Absolutely massive error loading turtle data.  Recommend buying a new computer.",-1);
   if (!(tdata contains my_location())) return vprint("This location has no turtle to tame.",5);
   tort = tdata[my_location()];
   if (have_effect($effect[eau de tortue]) == 0 && should_tame()) {
      if (retrieve_item(1,$item[turtle pheromones])) use(1,$item[turtle pheromones]);
      if (have_effect($effect[eau de tortue]) == 0) return vprint("Unable to acquire the effect 'Eau de Tortue'.",-3);
      if (tort.tier == 3) set_property("taming",tort.turtle+"|"+my_familiar());
       else set_property("taming",tort.turtle);
   }
   if ($strings["A Rolling Turtle Gathers No Moss","Blue Monday","Boxed In","C'mere, Little Fella",
        "Capital!","Jewel in the Rough","Kick the Can","Nantucket Snapper","No Man, No Hole",
        "O Turtle Were Art Thou","Puttin' it on Wax","Turtle in peril","Turtles of the Universe",
       // Tier II
        "Allow 6-8 Weeks For Delivery","Duel Nature","Like That Time in Tortuga","More eXtreme Than Usual",
        "Never Break the Chain","The Horror...","Turtles All The Way Around",
       // Tier III
        "Cleansing your Palette","Don't Be Alarmed, Now","Silent Strolling",
        "Training Day"] contains get_property("lastEncounter")) taming_reset();
   if (!now_taming()) return true;
  // prepare for taming
   vprint("Preparing to tame a "+tort.turtle+"...",2);
   switch (tort.tier) {
      case 3: if (!ensure_turtlefam(true)) return vprint("You need a turtle familiar to hunt a "+tort.turtle+" here.",-4);
      case 2: cli_execute("checkpoint");
         if (!have_equipped($item[turtling rod]) && !have_equipped($item[flail of the seven aspects]) &&
        !equip($item[flail of the seven aspects]) && !equip($item[turtling rod]))
        return vprint("You need to be able to equip a turtling rod to hunt a "+tort.turtle+" here.",-4);
   }
   return true;
}

boolean fam_check() {
  // first, enforce 100% runs
   if (to_familiar(vars["is_100_run"]) != $familiar[none]) {
      if (my_familiar() != to_familiar(vars["is_100_run"])) return use_fam(to_familiar(vars["is_100_run"]));
      return vprint("Not swapping familiar; is_100_run setting is set to "+my_familiar(),9);
   }
  // farm familiar items if set (and not auto-taming)
   if (!to_boolean(vars["bbb_famitems"]) || to_familiar(excise(get_property("taming"),"|","")) != $familiar[none]) return true;
   int[familiar] dfams;
   if (have_effect($effect[absinthe-minded]) == 0) dfams[$familiar[green pixie]] = to_int(get_property("_absintheDrops"));
   dfams[$familiar[li'l xenomorph]] = to_int(get_property("_transponderDrops"));
   dfams[$familiar[baby sandworm]] = to_int(get_property("_aguaDrops"));
   dfams[$familiar[astral badger]] = to_int(get_property("_astralDrops"));
   dfams[$familiar[llama lama]] = to_int(get_property("_gongDrops"));
   dfams[$familiar[rogue program]] = to_int(get_property("_tokenDrops"));
   dfams[$familiar[li'l xenomorph]] = to_int(get_property("_transponderDrops")) - 5;
   dfams[$familiar[mini-hipster]] = to_int(get_property("_hipsterAdv")) - 7;
   if (dfams contains my_familiar() && dfams[my_familiar()] < 5) return true;
   foreach f,d in dfams if (have_familiar(f) && d < 5) return use_fam(f);
   return true;
}

// NOTE: after running this script, changing these variables here in the script will have no
// effect.  You should instead edit the values by typing "zlib vars" in the CLI.
setvar("auto_semirare","timely"); // auto-eat fortune cookies: always, timely, never (maxcounters)
// setvar("bbb_vampire_hearts",4);   // min hearts desired before collecting blood (0 to avoid auto-equipping stakes)
setvar("bbb_miniboss_items",2);   // vs.-miniboss items to get in the defiled cyrpt areas before getting stats
setvar("bbb_adjust_choiceadvs",true); // enable/disable choiceadv adjustment
setvar("bbb_turtles",1);          // number of each turtle to auto-tame; 0 disables taming
setvar("bbb_turtlegear",false);   // toggle automatically creating gear from tamed turtles (makes 1 of each)
setvar("bbb_famitems",false);     // toggle automatically farming familiar-dropped items
check_version("Best Between Battle Script Ever","automcd","2.6",1240);


void bbb() {
  // reactions to previous encounters; expect this to get fleshed out with more ascensions
   switch (get_property("lastEncounter")) {
      case "A Grave Situation": for i from 1 to 2 visit_url("guild.php?place=ocg"); break;           // turn in, then re-collect key
      case "Screwdriver, wider than a mile": visit_url("forestvillage.php?place=untinker"); break;   // complete untinker quest
   }
   if (run_combat().contains_text("a single fat bumblebee") || run_combat().contains_text("You open the bag and "))
      set_property("bagOTricksCharges","0");
  // exchange tokens for tickets if they'll probably be needed
   if (!can_interact()) for i from 1 upto min((spleen_limit() - my_spleen_use())/ 4- (item_amount($item[Game Grid ticket])/10 +
     item_amount($item[not-a-pipe]) + item_amount($item[glimmering roc feather]) + item_amount($item[agua de vida]) +
     item_amount($item[coffee pixie stick])), item_amount($item[Game Grid token]))
      visit_url("arcade.php?action=skeeball&pwd");
   cookiecheck();
   use_goalcontaining_items();
   fight_items();
   taming_check();
   fam_check();
   set_choiceadvs();
   auto_mcd(my_location());
}
void main() { bbb(); }
