#/******************************************************************************
#                            CanAdv by Zarqon
#     A tool for handily determining if an area is available for adventuring
#*******************************************************************************
#
#   I did the work so you don't have to.  Import this into your scripts!
#
#   Have a suggestion to improve this script?  Visit
#   http://kolmafia.us/showthread.php?t=2027
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#******************************************************************************/
import <zlib.ash>

// This will not unlock the guild automatically by default to avoid spending adventures.
// This is a change to legacy behaviour and risks semirares and other limited availability turns.
setvar("canadv_unlockGuild", false);

boolean checkguild() {                            // guild quest-unlocking
   if (!($classes[seal clubber, turtle tamer, pastamancer, sauceror, disco bandit, accordion thief] contains my_class())) return false;
   if (!guild_store_available()) {
      if (to_boolean(vars["canadv_unlockGuild"])) cli_execute("guild");
      else return false;
   }
   if (!white_citadel_available() || get_property("questG06Delivery") != "finished") visit_url("guild.php?place=paco");
   if (get_property("questG03Ego") != "finished") visit_url("guild.php?place=ocg");
   if (get_property("questG04Nemesis") != "finished") visit_url("guild.php?place=scg");
   return true;
}

boolean can_adv(location where, boolean prep, int verb) {
  // prepare yourself!
   if (where == $location[none]) return vprint("Not a known location!",-6);
   if (limit_mode() != "") {
     if (limit_mode() == "Spelunky" && where.zone != "Spelunky Area") return false;
   }
   verb = max(verb,2);  // disallow negative verbs since return value depends on it
   if (prep) {
      if (my_adventures() == 0) return vprint("An adventurer without adventures is you!",-verb);
      if (my_hp() == 0) { restore_hp(0); if (my_hp() == 0) return vprint("You need at least _a_ HP.",-verb); }
      if (my_inebriety() > inebriety_limit() && !($locations[Drunken Stupor, St. Sneaky Pete's Day Stupor] contains where))
         return vprint("You sheriushly shouldn't be advenshuring like thish.",-verb);
      if (my_path() == "KOLHS" && where.zone != "KOL High School" && get_property("_kolhsAdventures").to_int() < 40) return vprint("You gotta stay in school, kid.",-verb);
   }
   if (where == $location[St. Sneaky Pete's Day Stupor]) return (my_inebriety() > 25 && contains_text(visit_url("main.php"),"St. Sneaky Pete's Day"));
   if (where == $location[Drunken Stupor]) return (my_inebriety() > inebriety_limit());
   if (my_level() != to_int(get_property("lastCouncilVisit"))) visit_url("council.php");
  // load permanently unlocked zones
   string theprop = get_property("unlockedLocations");
   if (theprop == "" || index_of(theprop,"--") < 1 || substring(theprop,0,index_of(theprop,"--")) != to_string(my_ascensions()))
      theprop = my_ascensions()+"--";
   if (list_contains(theprop, where) && !prep) return true;

   boolean primecheck(int req, boolean softhard) {
      if (my_buffedstat(my_primestat()) < req)
         return vprint((softhard ? "KoL suggests you have " : "You need ")+"at least "+req+" "+to_string(my_primestat())+" to adventure at "+where+"."+
            (softhard ? " (You can disable this warning in your KoL account menu)" : ""),-verb);
      return true;
   }
   boolean primecheck(int req) { return primecheck(req,false); }
   boolean levelcheck(int req) {
      if (my_level() < req) return vprint("You need to be level "+req+" or higher to adventure at "+where+".",-verb);
      return true;
   }
   boolean itemcheck(item req) {
      if (available_amount(req) == 0 && (!prep || !retrieve_item(1,req)))
         return vprint("You need a '"+req+"' to adventure here.",-verb);
      return true;
   }
   boolean effectcheck(effect req) {
      if (have_effect(req) == 0) return vprint("You need '"+req+"' to be active to adventure at "+where+".",-verb);
      return true;
   }
   boolean equipcheck(item req, slot bodzone) {
      if (!can_equip(req)) return vprint("You need to equip a "+req+", which you currently can't.",-verb);
      if (have_equipped(req)) return true;
      if (prep && retrieve_item(1,req) && equip(bodzone,req)) ;
      return (item_amount(req) > 0 || have_equipped(req));
   }
   boolean equipcheck(item req) {
      return equipcheck(req,to_slot(req));
   }
   boolean famcheck(familiar req) {
      if (to_familiar(vars["is_100_run"]) != $familiar[none] && req != to_familiar(vars["is_100_run"])) 
         return vprint("You need to equip a "+req+", which you currently can't due to being on a 100% run with a "+to_familiar(vars["is_100_run"])+".",-verb);
      if (my_familiar() == req) return true;
      if (have_familiar(req) && prep) return use_familiar(req);
      return have_familiar(req);
   }
   boolean outfitcheck(string req) {
      if (!have_outfit(req)) return vprint("You don't have the '"+req+"' outfit.",-verb);
      if (prep) outfit(req);
      return true;
   }
   boolean add_unlocked() {
      if (list_contains(theprop,where)) return true;
      set_property("unlockedLocations",list_add(theprop,where));
      return true;
   }
   boolean perm_urlcheck(string url, string needle) {
      string page = visit_url(url);
      vprint("Visited "+url+" (length: "+length(page)+")",9);
      if (contains_text(page,needle)) return add_unlocked();
      return false;
   }
   boolean perm_propcheck(string newprop, string needle) {
      if (contains_text(get_property(newprop),needle)) return add_unlocked();
      return false;
   }
   boolean qprop(string prop, string target) {
      string currp = get_property(prop);
      if (currp == "unstarted") return false;
      if (target == currp || currp == "finished") return true;
      foreach s in $strings[started,step1,step2,step3,step4,step5,step6,step7,step8,step9,step10,step11,step12] {
         if (s == currp) break;
         if (s == target) return true;
      }
      return false;
   }
   boolean pirate_check(string url) {
      boolean orig = prep;
      prep = true;
      if (!orig) cli_execute("checkpoint");
      if (!(equipcheck($item[pirate fledges],$slot[acc3]) || outfitcheck("swashbuckling getup"))) return false;
      prep = perm_urlcheck("place.php?whichplace=cove",url);
      if (!orig) cli_execute("outfit checkpoint");
      return prep;
   }
   boolean seafloor_check(string url) {
      string page = visit_url("seafloor.php");
      vprint("Visited seafloor.php (length: "+length(page)+")",9);
      if (contains_text(page,url+"a.gif") || contains_text(page,url+"b.gif")) return add_unlocked();
      return false;
   }
   boolean jarcheck(string who) {
      item jar = to_item("jar of psychoses ("+who+")");
      return (get_campground() contains jar) || itemcheck(jar);
   }
   boolean zone_check(string zone) {
      switch (zone) {
     // alphabetical
      case "Astral": return effectcheck($effect[half-astral]) || itemcheck($item[astral mushroom]);
      case "BatHole": return levelcheck(4) && qprop("questL04Bat","started");
      case "Beach": return get_property("lastDesertUnlock") == my_ascensions();
      case "Beanstalk": return levelcheck(10);
      case "Cyrpt": return levelcheck(7) && itemcheck($item[evilometer]);
      case "Dreadsylvania": return levelcheck(15) && visit_url("clan_dreadsylvania.php").contains_text(">Dreadsylvania<");
      case "Farm": return levelcheck(12) && qprop("questL12War","step1") && get_property("questL12War") != "finished" && get_property("sidequestFarmCompleted") == "none";
      case "Friars": return levelcheck(6) && qprop("questL06Friar","started") && get_property("questL06Friar") != "finished";
      case "HiddenCity": return levelcheck(11) && qprop("questL11Worship","step3");
      case "Highlands": return levelcheck(9) && qprop("questL09Topping","started") && get_property("chasmBridgeProgress").to_int() >= 30;
      case "Hobopolis": return contains_text(visit_url("town_clan.php"), "clanbasement.gif") && !contains_text(visit_url("clan_basement.php?fromabove=1"), "not allowed");
      case "Island": return (get_property("lastIslandUnlock") == my_ascensions()) && !qprop("questL12War","step1"); 
      case "IsleWar": return levelcheck(12) && qprop("questL12War","step1") && get_property("questL12War") != "finished";  
      case "Jacking": return itemcheck($item[map to Professor Jacking's laboratory]);
      case "Junkyard": return levelcheck(12) && get_property("sidequestJunkyardCompleted") == "none";
      case "Knob": if (where == $location[the outskirts of cobb's knob]) return true; return levelcheck(5) && qprop("questL05Goblin","started");
      case "KOL High School": return my_path() == "KOLHS";
      case "Lab": return levelcheck(5) && itemcheck($item[Cobb's Knob lab key]);
      case "Le Marais D&egrave;gueulasse":
      case "Little Canadia": return canadia_available();
      case "Manor0": return levelcheck(11) && itemcheck($item[your father's macguffin diary]) && qprop("questL11Manor","step1");
      case "Manor1": if (where == $location[the haunted pantry]) return true; return qprop("questM20Necklace","started");
      case "Manor2": return qprop("questM21Dance","step1");
      case "Manor3": return qprop("questM17Babies","started");
      case "McLarge": return levelcheck(8) && qprop("questL08Trapper","step1");
      case "Memories": return itemcheck($item[empty agua de vida bottle]);
      case "Menagerie": return itemcheck($item[Cobb's Knob menagerie key]);
      case "Mothership": return my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0;
      case "MoxSign": return gnomads_available() && zone_check("Beach");
      case "MusSign": return knoll_available();
      case "Orchard": return zone_check("IsleWar") && get_property("sidequestOrchardCompleted") == "none";
      case "Pandamonium": return qprop("questL06Friar","finished");
      case "Pyramid": return itemcheck($item[staff of ed]);
      case "Rift": return levelcheck(4) && my_level() < 6 && my_ascensions() > 0 && itemcheck($item[fernswarthy's letter]);
      case "Rumpelstiltskin's Home For Children": return get_property("grimstoneMaskPath") == "gnome" || itemcheck($item[grimstone mask]);
      case "Skid Row": return get_property("grimstoneMaskPath") == "wolf" || itemcheck($item[grimstone mask]);
      case "Spaaace": return effectcheck($effect[transpondent]) || (!prep && itemcheck($item[transporter transponder])) || (prep && use(1,$item[transporter transponder]));
	  case "Spelunky Area": return limit_mode() == "Spelunky";
      case "Spring Break Beach": return get_property("sleazeAirportAlways") == "true" || get_property("_sleazeAirportToday") == "true";
      case "Suburbs": return effectcheck($effect[dis abled]) || (!prep && itemcheck($item[devilish folio])) || (prep && use(1,$item[devilish folio]));
      case "The Candy Witch and the Relentless Child Thieves": return get_property("grimstoneMaskPath") == "witch" || itemcheck($item[grimstone mask]);
      case "The Prince's Ball": return get_property("grimstoneMaskPath") == "stepmother" || itemcheck($item[grimstone mask]);
      case "The Red Zeppelin's Mooring": return qprop("questL11Ron","started");
      case "The Sea": if (!levelcheck(11) || !itemcheck($item[makeshift SCUBA gear])) return false;
         if (!boolean_modifier("Underwater Familiar")) {
            item fgear = $item[none];
            if (available_amount($item[das boot]) > 0) fgear = $item[das boot];
            else {
               if (available_amount($item[little bitty bathysphere]) == 0) visit_url("oldman.php?action=talk");
               if (available_amount($item[little bitty bathysphere]) > 0) fgear = $item[little bitty bathysphere];
            }
            if (fgear == $item[none]) return vprint("Unable to equip your familiar for underwater adventuring.",-verb);
            if (prep) equip(fgear);
         }
         if (boolean_modifier("Adventure Underwater")) return true;
         return (equipcheck($item[aerated diving helmet]) || equipcheck($item[makeshift SCUBA gear],$slot[acc3]));
      case "Tower": return primecheck(11) && qprop("questG03Ego","step1");
      case "Twitch": return get_property("timeTowerAvailable") == "true";
      case "Vanya's Castle": return itemcheck($item[map to vanya's castle]) && equipcheck($item[continuum transfunctioner]);
      case "Volcano": return primecheck(90) && qprop("questG04Nemesis","step3");  // actual step is probably higher!
      case "Woods": return levelcheck(2) && qprop("questL02Larva","started");
      case "Wormwood": return effectcheck($effect[absinthe-minded]) || (!prep && itemcheck($item[tiny bottle of absinthe])) || (prep && use(1,$item[tiny bottle of absinthe]));
     // never open; their individual locations do not need to be present below
      case "The Candy Diorama":
      case "Crimbo06":
      case "Crimbo07":
      case "Crimbo08":
      case "Crimbo09":
      case "Crimbo10":
      case "Crimbo12":
      case "Crimbo14":
      case "Events":
      case "WhiteWed": return false;
      }
      return true;
   }
  // begin location checking
   if (!zone_check(where.zone)) return false;
   if (!get_ignore_zone_warnings() && !primecheck(where.recommended_stat,true)) return false;
   switch (where) {
  // always open if their zone is
   case $location[The Bat Hole Entrance]:               // bathole
   case $location[South of the Border]:
   case $location[Dreadsylvanian Castle]:               // dread
   case $location[Dreadsylvanian Village]:
   case $location[Dreadsylvanian Woods]:
   case $location[The Daily Dungeon]:                   // dungeon
   case $location[The Haiku Dungeon]:
   case $location[The Limerick Dungeon]:
   case $location[Mcmillicancuddy's Barn]:              // farm
   case $location[Mcmillicancuddy's Pond]:
   case $location[Mcmillicancuddy's Back 40]:
   case $location[Mcmillicancuddy's Other Back 40]:
   case $location[Mcmillicancuddy's Granary]:
   case $location[Mcmillicancuddy's Bog]:
   case $location[Mcmillicancuddy's Family Plot]:
   case $location[Mcmillicancuddy's Shady Thicket]:
   case $location[The Dark Neck of the Woods]:          // friars
   case $location[The Dark Heart of the Woods]:
   case $location[The Dark Elbow of the Woods]:
   case $location[Ye Olde Medievale Villagee]:          // grimstone
   case $location[Portal to Terrible Parents]:
   case $location[Rumpelstiltskin's Workshop]:
   case $location[The Prince's Restroom]:
   case $location[The Prince's Dance Floor]:
   case $location[The Prince's Kitchen]:
   case $location[The Prince's Balcony]:
   case $location[The Prince's Lounge]:
   case $location[The Prince's Canapes Table]:
   case $location[Sweet-Ade Lake]:
   case $location[Eager Rice Burrows]:
   case $location[Gumdrop Forest]:
   case $location[The Inner Wolf Gym]:
   case $location[Unleash Your Inner Wolf]:
   case $location[A Massive Ziggurat]:                  // hiddencity
   case $location[The Hidden Park]:
   case $location[An Overgrown Shrine (Northwest)]:
   case $location[An Overgrown Shrine (Southwest)]:
   case $location[An Overgrown Shrine (Northeast)]:
   case $location[An Overgrown Shrine (Southeast)]:
   case $location[A-Boo Peak]:                          // highlands
   case $location[Oil Peak]:
   case $location[Twin Peak]:
   case $location[Wartime Hippy Camp]:                  // islewar
   case $location[Wartime Frat House]:
   case $location[Sonofa Beach]:
   case $location[Professor Jacking's Small-O-Fier]:    // jacking
   case $location[Professor Jacking's Huge-A-Ma-tron]:
   case $location[Near an Abandoned Refrigerator]:      // junkyard
   case $location[Next to that Barrel with Something Burning in it]:
   case $location[Over Where the Old Tires Are]:
   case $location[Out by that Rusted-Out Car]:
   case $location[The Outskirts of Cobb's Knob]:        // knob
   case $location[Art Class]:                           // kol high school
   case $location[Chemistry Class]:
   case $location[Shop Class]:
   case $location[The Hallowed Halls]:
   case $location[The Knob Shaft]:                      // lab
   case $location[The Knob Shaft (Mining)]:
   case $location[Cobb's Knob Laboratory]:
   case $location[Swamp Beaver Territory]:              // le marais degueulasse
   case $location[The Corpse Bog]:
   case $location[The Dark and Spooky Swamp]:
   case $location[The Edge of the Swamp]:
   case $location[The Ruined Wizard Tower]:
   case $location[The Weird Swamp Village]:
   case $location[The Wildlife Sanctuarrrrrgh]:
   case $location[Outskirts of Camp Logging Camp]:      // little canadia
   case $location[Camp Logging Camp]:
   case $location[Pump Up Mysticality]:
   case $location[The Haunted Boiler Room]:             // manor0
   case $location[The Haunted Laundry Room]:
   case $location[The Haunted Wine Cellar]:
   case $location[The Haunted Conservatory]:            // manor1
   case $location[The Haunted Kitchen]:
   case $location[The Haunted Pantry]:
   case $location[The Haunted Bathroom]:                // manor2
   case $location[The Haunted Bedroom]:
   case $location[The Haunted Gallery]:
   case $location[The Haunted Laboratory]:              // manor3
   case $location[The Haunted Nursery]:
   case $location[The Haunted Storage Room]:
   case $location[Itznotyerzitz Mine]:                  // mclarge
   case $location[The Goatlet]:
   case $location[The Primordial Soup]:                 // memories
   case $location[The Jungles of Ancient Loathing]:
   case $location[Seaside Megalopolis]:
   case $location[Cobb's Knob Menagerie\, Level 1]:     // menagerie
   case $location[Cobb's Knob Menagerie\, Level 2]:
   case $location[Cobb's Knob Menagerie\, Level 3]:
   case $location[The Dire Warren]:                     // mountain
   case $location[Noob Cave]:
   case $location[Pump Up Moxie]:                       // moxsign
   case $location[Thugnderdome]:
   case $location[The Hatching Chamber]:                // orchard
   case $location[Infernal Rackets Backstage]:          // pandamonium
   case $location[The Laugh Floor]:
   case $location[Pandamonium Slums]:
   case $location[The Upper Chamber]:                   // pyramid
   case $location[A Mob of Zeppelin Protesters]:        // red zeppelin
   case $location[Battlefield (No Uniform)]:            // rift
   case $location[The Briny Deeps]:                     // sea
   case $location[The Brinier Deepers]:
   case $location[The Briniest Deepests]:
   case $location[An Octopus's Garden]:
   case $location[Hamburglaris Shield Generator]:       // spaaaace
   case $location[Domed City of Grimacia]:
   case $location[Domed City of Ronaldus]:
   case $location[The Fun-Guy Mansion]:                 // spring break
   case $location[Sloppy Seconds Diner]:
   case $location[The Sunken Party Yacht]:
   case $location[The Clumsiness Grove]:                // suburbs
   case $location[The Glacier of Jerks]:
   case $location[The Maelstrom of Lovers]:
   case $location[The Sleazy Back Alley]:               // town
   case $location[An Illicit Bohemian Party]:           // twitch
   case $location[Moonshiners' Woods]:
   case $location[The Cave Before Time]:
   case $location[The Roman Forum]:
   case $location[Vanya's Castle Foyer]:                // vanya's castle
   case $location[Vanya's Castle Chapel]:
   case $location[The Spooky Forest]:                   // woods
   case $location[The Stately Pleasure Dome]:           // wormwood
   case $location[The Mouldering Mansion]:
   case $location[The Rogue Windmill]: return true;
  // astral
   case $location[An Incredibly Strange Place (Bad Trip)]: if (prep) set_property("choiceAdventure71","1"); return primecheck(19);
   case $location[An Incredibly Strange Place (Mediocre Trip)]: if (prep) set_property("choiceAdventure71","2"); return primecheck(51);
   case $location[An Incredibly Strange Place (Great Trip)]: if (prep) set_property("choiceAdventure71","3"); return primecheck(143);
  // bathole
   case $location[Guano Junction]: return resist($element[stench],prep);
   case $location[The Batrat and Ratbat Burrow]: if (prep && !qprop("questL04Bat","step1")) use_upto(1, $item[sonar-in-a-biscuit],true);
      return qprop("questL04Bat","step1") || item_amount($item[sonar-in-a-biscuit]) > 0;
   case $location[The Beanbat Chamber]: if (prep && !qprop("questL04Bat","step2")) use_upto(2 - to_int(qprop("questL04Bat","step1")), $item[sonar-in-a-biscuit],true);
      return qprop("questL04Bat","step2") || item_amount($item[sonar-in-a-biscuit]) > 1 - to_int(qprop("questL04Bat","step1"));
   case $location[The Boss Bat's Lair]: if (prep && !qprop("questL04Bat","step3")) use_upto(3 - (to_int(qprop("questL04Bat","step1")) + to_int(qprop("questL04Bat","step2"))), $item[sonar-in-a-biscuit],true);
      if (get_property("questL04Bat") == "finished") return false;
      return get_property("questL04Bat") == "step3" || item_amount($item[sonar-in-a-biscuit]) > 2 - (to_int(qprop("questL04Bat","step1")) + to_int(qprop("questL04Bat","step2")));
  // beach
   case $location[The Arid, Extra-Dry Desert]: return itemcheck($item[your father's macguffin diary]);
   case $location[The Oasis]: return itemcheck($item[your father's macguffin diary]) && qprop("questL11Desert","started") && perm_urlcheck("place.php?whichplace=desertbeach","oasis.gif");
   case $location[The Shore, Inc. Travel Agency]: if (my_adventures() < 3) return vprint("Not enough adventures to take a vacation.",-verb);
      if (my_meat() < 500) return vprint("Not enough meat to take a vacation.",-verb); return (perm_urlcheck("main.php","map7beach.gif"));
  // beanstalk
   case $location[The Castle in the Clouds in the Sky \(Top Floor\)]: if (get_property("questL10Garbage") != "finished" && get_property("lastCastleTopUnlock").to_int() < my_ascensions()) return false;
   case $location[The Castle in the Clouds in the Sky \(Ground Floor\)]: if (get_property("questL10Garbage") != "finished" && get_property("lastCastleGroundUnlock").to_int() < my_ascensions()) return false;
   case $location[The Castle in the Clouds in the Sky \(Basement\)]: return itemcheck($item[S.O.C.K.]);
   case $location[The Hole in the Sky]: return itemcheck($item[steam-powered model rocketship]);
   case $location[The Penultimate Fantasy Airship]: return perm_urlcheck("place.php?whichplace=plains&action=garbage_grounds","climb_beanstalk.gif");
  // casino
   case $location[The Poker Room]: if (my_meat() < 30) return vprint("You need 30 meat to play the "+where+".",-verb);
   case $location[Pirate Party]:
   case $location[Lemon Party]:
   case $location[The Roulette Tables]: if (my_meat() < 10) return vprint("You need 10 meat to play the "+where+".",-verb);
   case $location[Goat Party]: if (my_meat() < 5) return vprint("You need 5 meat to play the Goat Party.",-verb); return itemcheck($item[casino pass]);
  // clan basement
   case $location[Richard's Hobo Moxie]:
   case $location[Richard's Hobo Muscle]:
   case $location[Richard's Hobo Mysticality]: return zone_check("Hobopolis");  // these are in zone "Gyms"
   case $location[A Maze of Sewer Tunnels]: return my_adventures() > 9;
   case $location[Hobopolis Town Square]:
   case $location[Burnbarrel Blvd.]:
   case $location[Exposure Esplanade]:
   case $location[The Heap]:
   case $location[The Ancient Hobo Burial Ground]:
   case $location[The Purple Light District]: return true;
   case $location[The Slime Tube]: return (visit_url("clan_slimetube.php").contains_text("thebucket.gif"));
  // cyrpt
   case $location[The Defiled Nook]: return get_property("cyrptNookEvilness").to_int() > 0;
   case $location[The Defiled Cranny]: return get_property("cyrptCrannyEvilness").to_int() > 0;
   case $location[The Defiled Alcove]: return get_property("cyrptAlcoveEvilness").to_int() > 0;
   case $location[The Defiled Niche]: return get_property("cyrptNicheEvilness").to_int() > 0;
   case $location[Haert of the Cyrpt]: return qprop("questL07Cyrptic","started") && !qprop("questL07Cyrptic","finished") && visit_url("questlog.php?which=1").contains_text("999<");
  // dungeon
   case $location[The Enormous Greater-Than Sign]: return my_basestat(my_primestat()) > 44 && (get_property("lastPlusSignUnlock").to_int() < my_ascensions() || contains_text(visit_url("da.php"),"Greater"));
   case $location[The Dungeons of Doom]: return get_property("lastPlusSignUnlock").to_int() == my_ascensions() && perm_urlcheck("da.php","ddoom.gif");
   case $location[Video Game Level 1]:
   case $location[Video Game Level 2]:
   case $location[Video Game Level 3]: return (itemcheck($item[GameInformPowerDailyPro Walkthru]) || itemcheck($item[GameInformPowerDailyPro magazine]));
  // grimstone
   case $location[A Deserted Stretch of I-911]: return get_property("grimstoneMaskPath") == "hare";
  // gyms
   case $location[Pump Up Muscle]: return (knoll_available() && (checkguild() || get_property("questM01Untinker") != "unstarted") && perm_urlcheck("place.php?whichplace=plains","Degrassi Gnoll"));
  // hiddencity
   case $location[The Hidden Apartment Building]: return get_property("hiddenApartmentProgress").to_int() > 0;
   case $location[The Hidden Hospital]: return get_property("hiddenHospitalProgress").to_int() > 0;
   case $location[The Hidden Office Building]: return get_property("hiddenOfficeProgress").to_int() > 0;
   case $location[The Hidden Bowling Alley]: return get_property("hiddenBowlingAlleyProgress").to_int() > 0;
  // holiday
   case $location[Spectral Pickle Factory]: if (!primecheck(50) || today_to_string().substring(4, 8) != "0401") return false;
   case $location[The Arrrboretum]: return gameday_to_string() == "Petember 4";
   case $location[Generic Summer Holiday Swimming!]: return gameday_to_string() == "Bill 3";
   case $location[Trick-or-Treating]: return (gameday_to_string() == "Porktember 8" || today_to_string().substring(4, 8) == "1031");
   case $location[The Yuletide Bonfire]: return gameday_to_string() == "Dougtember 4";
  // island
   case $location[Barrrney's Barrr]: return pirate_check("cove3_2x1.gif");
   case $location[The F'c'le]: return pirate_check("cove3_3x1b.gif");
   case $location[The Poop Deck]: return pirate_check("cove3_3x3b.gif");
   case $location[Belowdecks]: return pirate_check("cove3_5x2b.gif");
   case $location[Hippy Camp In Disguise]: if (!outfitcheck("filthy hippy disguise")) return false;
   case $location[Hippy Camp]: return get_property("sideDefeated") != "hippies" && get_property("sideDefeated") != "both";
   case $location[Frat House In Disguise]: if (!outfitcheck("frat boy ensemble")) return false;
   case $location[Frat House]: return get_property("sideDefeated") != "fratboys" && get_property("sideDefeated") != "both";
   case $location[The Obligatory Pirate's Cove]: return !have_equipped($item[pirate fledges]) && !is_wearing_outfit("swashbuckling getup");
   case $location[McMillicancuddy's Farm]:
   case $location[Post-War Junkyard]: return qprop("questL12War","finished");
   case $location[The Hippy Camp (Bombed Back to the Stone Age)]: return qprop("questL12War","finished") && get_property("sideDefeated") != "fratboys";
   case $location[The Orcish Frat House (Bombed Back to the Stone Age)]: return qprop("questL12War","finished") && get_property("sideDefeated") != "hippies";
  // islewar
   case $location[Wartime Hippy Camp (Frat Disguise)]: return outfitcheck("frat warrior fatigues");
   case $location[Wartime Frat House (Hippy Disguise)]: return outfitcheck("war hippy fatigues");
   case $location[The Battlefield (Frat Uniform)]: return outfitcheck("frat warrior fatigues") && get_property("hippiesDefeated") != "1000";
   case $location[The Battlefield (Hippy Uniform)]: return outfitcheck("war hippy fatigues") && get_property("fratboysDefeated") != "1000";
   case $location[The Themthar Hills]: return get_property("sidequestNunsCompleted") == "none";
  // knob
   case $location[Cobb's Knob Kitchens]:
   case $location[Cobb's Knob Barracks]:
   case $location[Cobb's Knob Treasury]:
   case $location[Cobb's Knob Harem]: return perm_urlcheck("cobbsknob.php",to_url(where));
   case $location[Throne Room]: return (!contains_text(visit_url("questlog.php?which=2"),"slain the Goblin King") &&
      (outfitcheck("harem girl disguise") && (effectcheck($effect[knob goblin perfume]) || (!prep && itemcheck($item[knob goblin perfume])) ||
       (prep && use(1,$item[knob goblin perfume])))) || (outfitcheck("Knob Goblin Elite Guard Uniform") && itemcheck($item[knob cake])));
  // manor
   case $location[The Haunted Billiards Room]: return itemcheck($item[Spookyraven billiards room key]);
   case $location[The Haunted Library]: return itemcheck($item[Spookyraven library key]);
   case $location[The Haunted Ballroom]: return qprop("questM21Dance","step3");
   case $location[Summoning Chamber]: if ($strings[unstarted, started, step1] contains get_property("questL11Manor") || qprop("questL11Manor","step4")) return false;
      return visit_url("place.php?whichplace=manor4").contains_text("chamberboss");  // url check here because step2 doesn't upgrade to step3 when you break down the wall
  // mclarge
   case $location[Dwarven Factory Warehouse]:
   case $location[The Mine Foremens' Office]: return (primecheck(100) && outfitcheck("mining gear") && white_citadel_available() && checkguild() && qprop("questG06Delivery","started"));
   case $location[The Icy Peak]: return qprop("questL08Trapper","finished");
   case $location[Itznotyerzitz Mine (In Disguise)]: return outfitcheck("mining gear");
   case $location[the eXtreme Slope]:
   case $location[Lair of the Ninja Snowmen]: return qprop("questL08Trapper","step2");
   case $location[Mist-Shrouded Peak]: return get_property("questL08Trapper") == "step3";
  // mothership
   case $location[Engineering]: return get_property("biodataEngineering").to_int() > 8;
   case $location[Galley]: return get_property("biodataGalley").to_int() > 8;
   case $location[Medbay]: return get_property("biodataMedbay").to_int() > 2;
   case $location[Morgue]: return get_property("biodataMorgue").to_int() > 5;
   case $location[Navigation]: return get_property("biodataNavigation").to_int() > 8;
   case $location[Science Lab]: return get_property("biodataScienceLab").to_int() > 5;
   case $location[Sonar]: return get_property("biodataSonar").to_int() > 2;
   case $location[Special Ops]: return get_property("biodataSpecialOps").to_int() > 5;
   case $location[Waste Processing]: return get_property("biodataWasteProcessing").to_int() > 2;
  // mountain
   case $location[The Barrel full of Barrels]: return checkguild();
   case $location[Mt. Molehill]: return effectcheck($effect[shape of...mole!]) || (!prep && itemcheck($item[llama lama gong]));
   case $location[Nemesis Cave]: return primecheck(25) && perm_urlcheck("cave.php","action=cavern");
   case $location[The Smut Orc Logging Camp]: return levelcheck(9) && qprop("questL09Topping","started");
   case $location[The Thinknerd Warehouse]: return get_property("questM22Shirt") != "unstarted";
   case $location[The Valley of Rof L'm Fao]: return levelcheck(9) && qprop("questM15Lol","started");
  // orchard
   case $location[The Feeding Chamber]: return effectcheck($effect[filthworm larva stench]);
   case $location[The Royal Guard Chamber]: return effectcheck($effect[filthworm drone stench]);
   case $location[The Filthworm Queen's Chamber]: return effectcheck($effect[filthworm guard stench]);
  // plains
   case $location[Pre-Cyrpt Cemetary]: return (checkguild() || get_property("questL07Cyrptic") != "unstarted") && !(get_property("questL07Cyrptic") == "finished");
   case $location[Post-Cyrpt Cemetary]: return primecheck(40) && qprop("questL07Cyrptic","finished");
   case $location[the Degrassi Knoll Bakery]:
   case $location[the Degrassi Knoll Garage]:
   case $location[the Degrassi Knoll Gym]:
   case $location[the Degrassi Knoll Restroom]: return (!knoll_available() && (checkguild() || qprop("questM01Untinker","started")) && perm_urlcheck("place.php?whichplace=plains","knollinside.gif"));
   case $location[The "Fun" House]: return primecheck(12) && checkguild() && qprop("questG04Nemesis","started") && perm_urlcheck("place.php?whichplace=plains","funhouse.gif");
   case $location[Inside The Palindome]: return levelcheck(11) && equipcheck($item[talisman o' nam],$slot[acc3]);
  // psychoses
   case $location[Anger Man's Level]:
   case $location[Fear Man's Level]:
   case $location[Doubt Man's Level]:
   case $location[Regret Man's Level]: return jarcheck("The Crackpot Mystic");
   case $location[The Nightmare Meatrealm]: return jarcheck("The Meatsmith");
   case $location[A Kitchen Drawer]:
   case $location[A Grocery Bag]: return jarcheck("The Pretentious Artist");
   case $location[Triad Factory]: return jarcheck("The Suspicious-Looking Guy") && itemcheck($item[zaibatsu lobby card]) && item_amount($item[strange goggles]) == 0;
   case $location[Chinatown Shops]: return jarcheck("The Suspicious-Looking Guy") && item_amount($item[strange goggles]) == 0;
   case $location[1st Floor, Shiawase-Mitsuhama Building]: return jarcheck("The Suspicious-Looking Guy") && contains_text(visit_url("place.php?whichplace=junggate_1"),to_url(where));
   case $location[2nd Floor, Shiawase-Mitsuhama Building]: cli_execute("use * zaibatsu level 2 card"); return jarcheck("The Suspicious-Looking Guy") && contains_text(visit_url("place.php?whichplace=junggate_1"),to_url(where));
   case $location[3rd Floor, Shiawase-Mitsuhama Building]: cli_execute("use * zaibatsu level 3 card"); return jarcheck("The Suspicious-Looking Guy") && contains_text(visit_url("place.php?whichplace=junggate_1"),to_url(where));
   case $location[Chinatown Tenement]: return jarcheck("The Suspicious-Looking Guy") && itemcheck($item[test site key]);
   case $location[The Gourd!]: return jarcheck("The Captain of the Gourd");
   case $location[The Tower of Procedurally-Generated Skeletons]: return jarcheck("Jick");
   case $location[The Old Man's Bathtime Adventures]: return jarcheck("The Old Man");
  // pyramid
   case $location[The Lower Chambers]: return get_property("lowerChamberUnlock") == "true" && get_property("questL11Pyramid") != "finished";
   case $location[The Middle Chamber]: return get_property("middleChamberUnlock") == "true";
  // red zeppelin's mooring
   case $location[The Red Zeppelin]: return get_property("zeppelinProtestors").to_int() >= 80;
  // rift
   case $location[Battlefield (Cloaca Uniform)]: return outfitcheck("cloaca-cola uniform");
   case $location[Battlefield (Dyspepsi Uniform)]: return outfitcheck("dyspepsi-cola uniform");
  // sea
   case $location[The Wreck of the Edgar Fitzsimmons]: return seafloor_check("shipwreck");
   case $location[Madness Reef]: return seafloor_check("reef");
   case $location[The Marinara Trench]: return seafloor_check("trench");
   case $location[Anemone Mine]:
   case $location[Anemone Mine (Mining)]: return seafloor_check("mine");
   case $location[The Dive Bar]: return seafloor_check("divebar");
   case $location[The Skate Park]: return seafloor_check("skatepark");
   case $location[The Mer-Kin Outpost]: return seafloor_check("outpost");
   case $location[The Coral Corral]: return seafloor_check("corral");
   case $location[The Caliginous Abyss]: return seafloor_check("abyss");
   case $location[Mer-kin Elementary School]:
   case $location[Mer-kin Gymnasium]: return get_property("seahorseName") != "" && outfitcheck("Crappy Mer-kin Disguise");
   case $location[Mer-kin Library]: return get_property("seahorseName") != "" && outfitcheck("Mer-kin Scholar's Vestments");
   case $location[Mer-kin Colosseum]: return get_property("seahorseName") != "" && outfitcheck("Mer-kin Gladiatorial Gear");
  // signs
   case $location[The Bugbear Pen]: return primecheck(13) && get_property("questM03Bugbear") != "finished";
   case $location[Post-Quest Bugbear Pens]: return primecheck(13) && get_property("questM03Bugbear") == "finished" && perm_urlcheck("woods.php","pen.gif");
   case $location[The Spooky Gravy Burrow]: return (famcheck($familiar[spooky gravy fairy]) || famcheck($familiar[sleazy gravy fairy]) ||
           famcheck($familiar[frozen gravy fairy]) || famcheck($familiar[flaming gravy fairy]) || famcheck($familiar[stinky gravy fairy]));
  // sorceress
   case $location[Fastest Adventurer Contest]: return levelcheck(13) && get_property( "questL13Final" ) == "step1" && get_property( "nsContestants1" ) > 0;
   case $location[Strongest Adventurer Contest]:
   case $location[Smartest Adventurer Contest]:
   case $location[Smoothest Adventurer Contest]:
   case $location[A Crowd of (Stat) Adventurers]: return levelcheck(13) && get_property( "questL13Final" ) == "step1" && get_property( "nsContestants2" ) > 0;
   case $location[Hottest Adventurer Contest]:
   case $location[Coldest Adventurer Contest]:
   case $location[Spookiest Adventurer Contest]:
   case $location[Stinkiest Adventurer Contest]:
   case $location[Sleaziest Adventurer Contest]:
   case $location[A Crowd of (Element) Adventurers]: return levelcheck(13) && get_property( "questL13Final" ) == "step1" && get_property( "nsContestants3" ) > 0;
   case $location[The Hedge Maze]: return levelcheck(13) && get_property( "questL13Final" ) == "step2";
  // tower
   case $location[Fernswarthy's Basement]: return qprop("questG03Ego","step4") && perm_urlcheck("fernruin.php","basement.php");
   case $location[Tower Ruins]: return (itemcheck($item[fernswarthy's letter]));
  // town
   case $location[The Copperhead Club]: return levelcheck(11) && qprop("questL11Shen", "started");
  // volcano
   case $location[The Broodling Grounds]: return my_class() == $class[seal clubber];
   case $location[The Outer Compound]: return my_class() == $class[turtle tamer];
   case $location[The Temple Portico]: return my_class() == $class[pastamancer];
   case $location[Convention Hall Lobby]: return my_class() == $class[sauceror];
   case $location[Outside the Club]: return my_class() == $class[disco bandit];
   case $location[The Island Barracks]: return my_class() == $class[accordion thief];
   case $location[The Nemesis' Lair]: return false;
  // woods
   case $location[8-Bit Realm]: return primecheck(20);
   case $location[A Barroom Brawl]:
   case $location[The Typical Tavern Cellar]: return levelcheck(3) && qprop("questL03Rat","started");
   case $location[The Black Forest]: return levelcheck(11) && qprop("questL11MacGuffin","started");
   case $location[The Hidden Temple]: return get_property("lastTempleUnlock").to_int() == my_ascensions();
   case $location[The Old Landfill]: return perm_urlcheck("woods.php","oldlandfill.gif");
   case $location[The Road to the White Citadel]: return (!white_citadel_available() && qprop("questG02Whitecastle","step1"));
   case $location[Whitey's Grove]: return (levelcheck(7) && primecheck(34) && (qprop("questL11Palindome","step3") || (checkguild() && qprop("questG02Whitecastle","started"))) && perm_urlcheck("woods.php","grove.gif"));
  // unique locations
   case $location[Friar Ceremony Location]: return (itemcheck($item[dodecagram]) && itemcheck($item[box of birthday candles]) && itemcheck($item[eldritch butterknife]));
   case $location[El Vibrato Island]: return (itemcheck($item[el vibrato trapezoid]) || contains_text(visit_url("campground.php"),"Portal1.gif"));
   case $location[The Red Queen's Garden]: return (effectcheck($effect[down the rabbit hole]) || (!prep && itemcheck($item[&quot;DRINK ME&quot; potion])) || (prep && use(1,$item[&quot;DRINK ME&quot; potion])));
   case $location[The Landscaper's Lair]: return itemcheck($item[antique painting of a landscape]);
   case $location[Kegger in the Woods]: return (itemcheck($item[map to the kegger in the woods]));
   case $location[The Electric Lemonade Acid Parade]: return (itemcheck($item[map to the magic commune]));
   case $location[Neckback Crick]: return (itemcheck($item[map to ellsbury's claim]));
  // never open
   case $location[A Pile of Old Servers]:
   case $location[A Skeleton Invasion!]:
   case $location[Fudge Mountain]:
   case $location[Grim Grimacite Site]:
   case $location[Heartbreaker's Hotel]:
   case $location[Lollipop Forest]:
   case $location[The Cannon Museum]:
   case $location[Spectral Salad Factory]:
   case $location[WarBear Fortress (First Level)]:
   case $location[WarBear Fortress (Second Level)]:
   case $location[WarBear Fortress (Third Level)]: return vprint(where+" is no longer adventurable.",-9);
   default: vprint("Unknown location: "+where+" (zone: "+where.zone+")","olive",-2);
            return vprint("Please report this missing location here: http://kolmafia.us/showthread.php?t=2027","black",-2);
   }
}

boolean can_adv(location where, boolean p) { return can_adv(where, p, 6); }
boolean can_adv(location where, int verb)  { return can_adv(where, false, verb); }
boolean can_adv(location where) {            return can_adv(where, false, 6); }

string[string] post;  // provide hook for relay scripts to Ajax zone availability
post = form_fields();
if (post contains "where") {
   location w = to_location(post["where"]);
   int postverb = (post contains "verb" && is_integer(post["verb"])) ? post["verb"].to_int() : 9;
   if (w == $location[none] || !can_adv(w, postverb)) write("unavailable");
   else write("available");
   exit;
}

void main(location theplace) {
   if (theplace == $location[none]) {
      foreach l in $locations[]
         if (can_adv(l)) vprint(l+" is available to your character.","green",7);
          else vprint(l+" is not available to your character.",-6);
      exit;
   }
   if (can_adv(theplace)) vprint(theplace+" is available to your character.","green",7);
   else vprint(theplace+" is not available to your character.",-6);
}