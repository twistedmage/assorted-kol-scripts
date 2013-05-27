#/******************************************************************************
#                            CanAdv 0.73 by Zarqon
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

boolean checkguild() {                            // guild quest-unlocking
   if (!guild_store_available()) cli_execute("guild");
   item my_lew() {
      switch (my_class()) {
         case $class[seal clubber]: return $item[hammer of smiting];
         case $class[turtle tamer]: return $item[chelonian morningstar];
         case $class[pastamancer]: return $item[greek pasta of peril];
         case $class[sauceror]: return $item[17-alarm saucepan];
         case $class[disco bandit]: return $item[shagadelic disco banjo];
         case $class[accordion thief]: return $item[squeezebox of the ages];
      }
      return $item[none];
   }
   if (!white_citadel_available()) visit_url("guild.php?place=paco");
   if (item_amount($item[fernswarthy's key]) == 0) visit_url("guild.php?place=ocg");
   if (item_amount(my_lew()) + equipped_amount(my_lew()) == 0) visit_url("guild.php?place=scg");
   return true;
}

boolean can_adv(location where, boolean prep) {
  // prepare yourself!
   if (where == $location[none]) return vprint("Not a known location!",-6);
   if (my_adventures() == 0) return vprint("An adventurer without adventures is you!",-6);
   if (my_hp() == 0) { if (prep) restore_hp(0); if (my_hp() == 0) return vprint("You need at least _a_ HP.",-6); }
  // check drunk-only locations before doing drunkenness check
   if (where == $location[St. Sneaky Pete's Day Stupor]) return (my_inebriety() > inebriety_limit() && contains_text(visit_url("main.php"),"St. Sneaky Pete's Day"));
   if (where == $location[Drunken Stupor]) return (my_inebriety() > inebriety_limit());
   if (my_inebriety() > inebriety_limit()) return vprint("You sheriushly shouldn't be advenshuring like thish.",-6);
   if (my_level() != to_int(get_property("lastCouncilVisit"))) visit_url("council.php");
  // load permanently unlocked zones
   string theprop = get_property("unlockedLocations");
   if (theprop == "" || substring(theprop,0,index_of(theprop,"--")) != to_string(my_ascensions()))
      theprop = my_ascensions()+"--";
   if (contains_text(theprop,where)) return true;

   boolean primecheck(int req) {
      if (my_buffedstat(my_primestat()) < req)
         return vprint("You need at least "+req+" "+to_string(my_primestat())+" to adventure at "+where+".",-6);
      return true;
   }
   boolean levelcheck(int req) {
      if (my_level() < req) return vprint("You need to be level "+req+" or higher to adventure at "+where+".",-6);
      return true;
   }
   boolean itemcheck(item req) {
      if (available_amount(req) == 0 && (!prep || !retrieve_item(1,req)))
         return vprint("You need a '"+req+"' to adventure here.",-6);
      return true;
   }
   boolean effectcheck(effect req) {
      if (have_effect(req) == 0) return vprint("You need '"+req+"' to be active to adventure at "+where+".",-6);
      return true;
   }
   boolean equipcheck(item req, slot bodzone) {
      if (!can_equip(req)) return vprint("You need to equip a "+req+", which you currently can't.",-6);
      if (prep && retrieve_item(1,req) && equip(bodzone,req)) {}
      return (item_amount(req) > 0 || have_equipped(req));
   }
   boolean equipcheck(item req) { return equipcheck(req,to_slot(req)); }
   boolean outfitcheck(string req) {
      if (!have_outfit(req)) return vprint("You don't have the '"+req+"' outfit.",-6);
      if (prep) outfit(req);
      return true;
   }
   boolean perm_urlcheck(string url, string needle) {
      if (contains_text(visit_url(url),needle)) {
         set_property("unlockedLocations",theprop+" "+where);
         return true;
      }
      return false;
   }
   boolean pirate_check(string url) {
      boolean orig = prep;
      prep = true;
      if (!orig) cli_execute("checkpoint");
      if (!(equipcheck($item[pirate fledges],$slot[acc3]) || outfitcheck("swashbuckling getup"))) return false;
      prep = perm_urlcheck("cove.php",url);
      if (!orig) cli_execute("outfit checkpoint");
      return prep;
   }
   boolean candive() {
      if (!levelcheck(13) || !itemcheck($item[makeshift SCUBA gear])) return false;
      if (!boolean_modifier("Underwater Familiar")) {
         item fgear = $item[none];
         if (available_amount($item[das boot]) > 0) fgear = $item[das boot];
         else {
            if (available_amount($item[little bitty bathysphere]) == 0) visit_url("oldman.php?action=talk");
            if (available_amount($item[little bitty bathysphere]) > 0) fgear = $item[little bitty bathysphere];
         }
         if (fgear == $item[none]) return vprint("Unable to equip your familiar for underwater adventuring.",-6);
         if (prep) equip(fgear);
      }
      if (boolean_modifier("Adventure Underwater")) return true;
      return (equipcheck($item[aerated diving helmet]) || equipcheck($item[makeshift SCUBA gear],$slot[acc3]));
   }

  // begin location checking
   if (contains_text(to_string(where),"Haunted Wine Cellar"))
      return (levelcheck(11) && itemcheck($item[your father's macguffin diary]) && perm_urlcheck("manor.php","sm8b.gif"));
   switch (where) {
  // always open
   case $location[Sleazy Back Alley]:
   case $location[Haunted Pantry]:
   case $location[Outskirts of The Knob]:
   case $location[Dire Warren]:
   case $location[Noob Cave]: return true;
  // casino
   case $location[Goat Party]: if (my_meat() < 5) return vprint("You need 5 meat to play the Goat Party.",-6);
   case $location[Pirate Party]:
   case $location[Lemon Party]: if (my_meat() < 10) return vprint("You need 10 meat to play the "+where+".",-6);
   case $location[Roulette Tables]:
   case $location[Poker Room]: return (itemcheck($item[casino pass]));
  // level-opened
   case $location[Haiku Dungeon]: return (primecheck(5));
   case $location[Daily Dungeon]: return (primecheck(15));
   case $location[Limerick Dungeon]: return (primecheck(21));
   case $location[Spooky Forest]: return (levelcheck(2));
   case $location[A Barroom Brawl]:
   case $location[Tavern Cellar]: return (levelcheck(3));
   case $location[8-Bit Realm]: return (primecheck(20));
   case $location[Bat Hole Entryway]: return (levelcheck(4));
   case $location[Guano Junction]: return (levelcheck(4) && resist($element[stench],prep));
   case $location[Batrat and Ratbat Burrow]:
   case $location[Beanbat Chamber]:
   case $location[Boss Bat Lair]: if (!levelcheck(4)) return false; string bathole = visit_url("bathole.php");
                                    int sonarsneeded = to_int(!contains_text(bathole,"batratroom.gif")) +
                                       to_int(!contains_text(bathole,"batbeanroom.gif")) + to_int(!contains_text(bathole,"batbossroom"));
                                    if (sonarsneeded > 0) {
                                       if (prep) use_upto(sonarsneeded,$item[sonar-in-a-biscuit],true);
                                       else return (item_amount($item[sonar-in-a-biscuit]) >= sonarsneeded);
                                    }
                                  return (perm_urlcheck("bathole.php",to_url(where)));
   case $location[Knob Barracks]:
   case $location[Knob Kitchens]:
   case $location[Knob Treasury]:
   case $location[Knob Harem]: if (!levelcheck(5) || contains_text(visit_url("plains.php"), "knob1.gif")) return false; return (perm_urlcheck("cobbsknob.php",to_url(where)));
   case $location[Greater-Than Sign]: return (primecheck(45) && contains_text(visit_url("da.php"),"Greater"));
   case $location[Dungeons of Doom]: return (primecheck(45) && perm_urlcheck("da.php","ddoom.gif"));
   case $location[Itznotyerzitz Mine]: return (levelcheck(8));
   case $location[Black Forest]: return (levelcheck(11));
  // key opened
   case $location[Knob Shaft]:
   case $location[Knob Laboratory]:
   case $location[Menagerie 1]:
   case $location[Menagerie 2]:
   case $location[Menagerie 3]: return (itemcheck($item[lab key]));
   case $location[Hippy Camp In Disguise]: if (!outfitcheck("filthy hippy disguise")) return false;
   case $location[Frat House In Disguise]: if (!outfitcheck("frat boy ensemble")) return false;
   case $location[Hippy Camp]: return (itemcheck($item[dingy dinghy]) && get_property("warProgress") != "started" && get_property("sideDefeated") != "hippies" && get_property("sideDefeated") != "both");
   case $location[Frat House]: return (itemcheck($item[dingy dinghy]) && get_property("warProgress") != "started" && get_property("sideDefeated") != "fratboys" && get_property("sideDefeated") != "both");
   case $location[Pirate Cove]: return (itemcheck($item[dingy dinghy]) && !have_equipped($item[pirate fledges]) && get_property("warProgress") != "started");
   case $location[Giant's Castle (basement)]:
   case $location[Giant's Castle (ground floor)]:
   case $location[Giant's Castle (top floor)]:
   return (item_amount($item[S.O.C.K]) > 0);
   case $location[Hole in the Sky]: return (itemcheck($item[steam-powered model rocketship]));
   case $location[Haunted Library]: return (itemcheck($item[library key]));
   case $location[Haunted Gallery]: return (itemcheck($item[gallery key]));
   case $location[Haunted Ballroom]: return (itemcheck($item[ballroom key]));
   case $location[Palindome]: return (equipcheck($item[talisman o'nam],$slot[acc3]));
   case $location[Fernswarthy Basement]: return (itemcheck($item[fernswarthy letter]) && perm_urlcheck("fernruin.php","basement.php"));
   case $location[Fernswarthy Ruins]: return (itemcheck($item[fernswarthy letter]));
   case $location[Battlefield (Cloaca Uniform)]: return (levelcheck(4) && my_level() < 6 && my_ascensions() > 0 && itemcheck($item[fernswarthy letter]) && outfitcheck("cloaca-cola uniform"));
   case $location[Battlefield (Dyspepsi Uniform)]: if (!outfitcheck("dyspepsi-cola uniform")) return false;
   case $location[Battlefield (No Uniform)]: return (levelcheck(4) && my_level() < 6 && my_ascensions() > 0 && itemcheck($item[fernswarthy letter]));
   case $location[Desert (Ultrahydrated)]: if (!effectcheck($effect[ultrahydrated])) return false;
   case $location[Desert (Unhydrated)]: return (itemcheck($item[your father's macguffin diary]));
   case $location[Oasis in the Desert]: return (itemcheck($item[your father's macguffin diary]) && perm_urlcheck("beach.php","oasis.gif"));
   case $location[The Upper Chamber]:
   case $location[The Middle Chamber]: return (itemcheck($item[staff of ed]));
   case $location[Friar Ceremony Location]: return (itemcheck($item[dodecagram]) && itemcheck($item[box of birthday candles]) && itemcheck($item[eldritch butterknife]));
   case $location[Sorceress Hedge Maze]: return (levelcheck(13) && (itemcheck($item[hedge maze key]) || contains_text(visit_url("questlog.php?which=1"),"a hedge maze")));
  // signs
   case $location[Thugnderdome]: if (!primecheck(25)) return false;
   case $location[Pump Up Moxie]: return (in_moxie_sign() && can_adv($location[south of the border],prep));
   case $location[Pump Up Mysticality]:
   case $location[Outskirts of Camp]: return (in_mysticality_sign());
   case $location[Camp Logging Camp]: return (in_mysticality_sign() && primecheck(30));
   case $location[Pump Up Muscle]: return (in_muscle_sign() && checkguild() && perm_urlcheck("plains.php","Degrassi Gnoll"));
   case $location[Post-Quest Bugbear Pens]:
   case $location[Bugbear Pens]: return (in_muscle_sign() && primecheck(13) && perm_urlcheck("woods.php","pen.gif"));
   case $location[Spooky Gravy Barrow]: return (in_muscle_sign() && primecheck(40) && (have_familiar($familiar[frozen gravy fairy]) ||
                                                have_familiar($familiar[flaming gravy fairy]) || have_familiar($familiar[stinky gravy fairy])));
  // misc
   case $location[Barrel full of Barrels]: return checkguild();
   case $location[Hidden Temple]: return (levelcheck(2) && perm_urlcheck("woods.php","temple.gif"));
   case $location[Degrassi Knoll]: return (!in_muscle_sign() && checkguild() && perm_urlcheck("plains.php","knoll1.gif"));
   case $location[Fun House]: return (checkguild() && perm_urlcheck("plains.php","funhouse.gif"));
   case $location[Throne Room]: return (levelcheck(5) && !contains_text(visit_url("questlog.php?which=2"),"slain the Goblin King") && outfitcheck("harem girl disguise") &&
                                  (effectcheck($effect[knob goblin perfume]) || (!prep && itemcheck($item[knob goblin perfume])) || (prep && use(1,$item[knob goblin perfume]))));
   case $location[Muscle Vacation]:
   case $location[Mysticality Vacation]:
   case $location[Moxie Vacation]: if (my_adventures() < 3) return vprint("Not enough adventures to take a "+where+".",-6);
   case $location[South of the Border]: return (perm_urlcheck("main.php","map7beach.gif"));
   case $location[Defiled Nook]: return (levelcheck(7) && visit_url("cyrpt.php").contains_text("cyrpt7d.gif"));
   case $location[Defiled Cranny]: return (levelcheck(7) && visit_url("cyrpt.php").contains_text("cyrpt9d.gif"));
   case $location[Defiled Alcove]: return (levelcheck(7) && visit_url("cyrpt.php").contains_text("cyrpt4d.gif"));
   case $location[Defiled Niche]: return (levelcheck(7) && visit_url("cyrpt.php").contains_text("cyrpt6d.gif"));
   case $location[Haert of the Cyrpt]: return (levelcheck(7) && visit_url("questlog.php?which=1").contains_text("extreme Spookiness emanating"));
   case $location[Pre-Cyrpt Cemetary]: return (primecheck(11) && checkguild() && !visit_url("questlog.php?which=2").contains_text("defeated the Bonerdagon"));
   case $location[Post-Cyrpt Cemetary]: return (primecheck(40) && perm_urlcheck("questlog.php?which=2","defeated the Bonerdagon"));
   case $location[Goatlet]: return (levelcheck(8) && perm_urlcheck("mclargehuge.php","bottommiddle.gif"));
   case $location[Ninja Snowmen]: return (levelcheck(8) && perm_urlcheck("mclargehuge.php","leftmiddle.gif"));
   case $location[eXtreme Slope]: return (levelcheck(8) && perm_urlcheck("mclargehuge.php","rightmiddle.gif"));
   case $location[Whitey Grove]: return (levelcheck(7) && checkguild() && perm_urlcheck("woods.php","grove.gif"));
   case $location[Dark Neck of the Woods]:
   case $location[Dark Heart of the Woods]:
   case $location[Dark Elbow of the Woods]: return (levelcheck(6) && !have_skill($skill[liver of steel]) && !have_skill($skill[stomach of steel]) &&
                                                   !have_skill($skill[spleen of steel]) && !contains_text(visit_url("questlog.php?which=2"),"cleansed the taint"));
   case $location[Belilafs Comedy Club]:
   case $location[Hey Deze Arena]:
   case $location[Pandamonium Slums]: return (primecheck(29) && (have_skill($skill[liver of steel]) || have_skill($skill[spleen of steel]) ||
                                         have_skill($skill[stomach of steel]) || perm_urlcheck("questlog.php?which=2","cleansed the taint")));
   case $location[Orc Chasm]: return (levelcheck(9) && perm_urlcheck("mountains.php","valley2.gif"));
   case $location[Fantasy Airship]: return (levelcheck(10) && (perm_urlcheck("plains.php","beanstalk.gif") || use(1,$item[enchanted bean])));
   case $location[White Citadel]: return (!white_citadel_available() && checkguild() && visit_url("woods.php").contains_text("wcroad.gif"));
   case $location[Haunted Kitchen]: return (primecheck(5) && (itemcheck($item[library key]) || perm_urlcheck("town_right.php","manor.gif")));
   case $location[Haunted Conservatory]: return (primecheck(6) && perm_urlcheck("town_right.php","manor.gif"));
   case $location[Haunted Billiards Room]: return (primecheck(10) && perm_urlcheck("town_right.php","manor.gif"));
   case $location[Haunted Bathroom]: return (primecheck(68) && to_int(get_property("lastSecondFloorUnlock")) == my_ascensions());
   case $location[Haunted Bedroom]: return (primecheck(85) && to_int(get_property("lastSecondFloorUnlock")) == my_ascensions());
   case $location[Icy Peak]: return (levelcheck(8) && perm_urlcheck("questlog.php?which=2","L337 Tr4pz0r"));
   case $location[Barrrney's Barrr]: return (itemcheck($item[dingy dinghy]) && (equipcheck($item[pirate fledges],$slot[acc3]) || outfitcheck("swashbuckling getup")));
   case $location[F'c'le]: return (pirate_check("cove3_3x1b.gif"));
   case $location[Poop Deck]: return (pirate_check("cove3_3x3b.gif"));
   case $location[Belowdecks]: return (pirate_check("cove3_5x2b.gif"));
   case $location[Hidden City (encounter)]:
   case $location[Hidden City (automatic)]: return (levelcheck(11) && itemcheck($item[your father's macguffin diary]) && perm_urlcheck("woods.php","hiddencity.php"));
   case $location[The Lower Chambers]: return (levelcheck(11) && perm_urlcheck("beach.php","pyramid.php"));
  // nemesis zones
   case $location[Nemesis Cave]: return (primecheck(25) && contains_text(visit_url("mountains.php"),"cave.gif"));
   case $location[The Broodling Grounds]: return (my_class() == $class[seal clubber] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Outer Compound]: return (my_class() == $class[turtle tamer] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Temple Portico]: return (my_class() == $class[pastamancer] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[Convention Hall Lobby]: return (my_class() == $class[sauceror] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[Outside the Club]: return (my_class() == $class[disco bandit] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Barracks]: return (my_class() == $class[accordion thief] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Nemesis Lair]: return false;
  // extraordinary zones
   case $location[El Vibrato Island]: return (itemcheck($item[el vibrato trapezoid]) || contains_text(visit_url("campground.php"),"Portal1.gif"));
   case $location[Dwarven Factory Warehouse]:
   case $location[Mine Foremens Office]: return (primecheck(100) && outfitcheck("mining gear") && white_citadel_available() && checkguild());
   case $location[The Red Queen Garden]: return (effectcheck($effect[down the rabbit hole]) || (!prep && itemcheck($item[DRINK ME potion])) || (prep && use(1,$item[DRINK ME potion])));
   case $location[A Well-Groomed Lawn]: return (itemcheck($item[antique painting of a landscape]));
   case $location[Small-O-Fier]:
   case $location[Huge-A-Ma-tron]: return (itemcheck($item[map to Professor Jacking laboratory]));
   case $location[Foyer]:
   case $location[Chapel]: return (itemcheck($item[map to vanya castle]) && equipcheck($item[continuum transfunctioner]));
   case $location[Kegger in the Woods]: return (itemcheck($item[map to the kegger in the woods]));
   case $location[Electric Lemonade Acid Parade]: return (itemcheck($item[map to the magic commune]));
   case $location[Neckback Crick]: return (itemcheck($item[map to ellsbury claim]));
  // mr. familiar zones
   case $location[Astral Mushroom (Great Trip)]: if (!primecheck(143)) return false;
   case $location[Astral Mushroom (Mediocre Trip)]: if (!primecheck(51)) return false;
   case $location[Astral Mushroom (Bad Trip)]: return (primecheck(19) && (effectcheck($effect[half-astral]) || itemcheck($item[astral mushroom])));
   case $location[Stately Pleasure Dome]:
   case $location[Mouldering Mansion]:
   case $location[Rogue Windmill]: return (effectcheck($effect[absinthe-minded]) || (!prep && itemcheck($item[tiny bottle of absinthe])) || (prep && use(1,$item[tiny bottle of absinthe])));
   case $location[Mt. Molehill]: return (effectcheck($effect[shape of...mole!]) || (!prep && itemcheck($item[llama lama gong])));
   case $location[Primordial Soup]:
   case $location[Jungles of Ancient Loathing]:
   case $location[Seaside Megalopolis]: return itemcheck($item[empty agua de vida bottle]);
  // islewar stuffs
   case $location[Wartime Hippy Camp (Frat Disguise)]: if (!outfitcheck("frat boy ensemble")) return false;
   case $location[Wartime Hippy Camp]: return (levelcheck(12) && get_property("warProgress") == "unstarted");
   case $location[Wartime Frat House (Hippy Disguise)]: if (!outfitcheck("filthy hippy disguise")) return false;
   case $location[Wartime Frat House]: return (levelcheck(12) && get_property("warProgress") == "unstarted");
   case $location[Battlefield (Frat Uniform)]: return (get_property("warProgress") == "started" && outfitcheck("frat warrior") && get_property("hippiesDefeated") != "1000");
   case $location[Battlefield (Hippy Uniform)]: return (get_property("warProgress") == "started" && outfitcheck("war hippy fatigues") && get_property("fratboysDefeated") != "1000");
   case $location[Themthar Hills]: return (get_property("warProgress") == "started" && get_property("sidequestNunsCompleted") == "none");
   case $location[Hatching Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none");
   case $location[Feeding Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none" && effectcheck($effect[filthworm larva stench]));
   case $location[Guards Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none" && effectcheck($effect[filthworm drone stench]));
   case $location[Queen Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none" && effectcheck($effect[filthworm guard stench]));
   case $location[Wartime Sonofa Beach]: return (get_property("warProgress") == "started" && get_property("sidequestLighthouseCompleted") == "none");
   case $location[Barrel with Something Burning in it]:
   case $location[Near an Abandoned Refrigerator]:
   case $location[Over Where the Old Tires Are]:
   case $location[Out by that Rusted-Out Car]: return (get_property("warProgress") == "started" && get_property("sidequestJunkyardCompleted") == "none");
   case $location[Barn]:
   case $location[Pond]:
   case $location[Back 40]:
   case $location[Other Back 40]:
   case $location[Granary]:
   case $location[Bog]:
   case $location[Family Plot]:
   case $location[Shady Thicket]: return (get_property("warProgress") == "started" && get_property("sidequestFarmCompleted") == "none");
   case $location[Hippy Camp (Stone Age)]: return (get_property("warProgress") == "finished" && get_property("sideDefeated") != "fratboys");
   case $location[Frat House (Stone Age)]: return (get_property("warProgress") == "finished" && get_property("sideDefeated") != "hippies");
   case $location[McMillicancuddy Farm]:
   case $location[Post-War Junkyard]:
   case $location[Post-War Sonofa Beach]: return (levelcheck(12) && get_property("warProgress") == "finished");
  // holiday-only
   case $location[Trick-or-Treating]:
   case $location[Yuletide Bonfire]:
   case $location[Generic Summer Holiday Swimming!]:
   case $location[Arrrboretum]: return vprint("Cannot yet detect holiday zones.  Assuming true...","olive",4);
  // clan basement
   case $location[Richard Hobo Mysticality]:
   case $location[Richard Hobo Moxie]:
   case $location[Richard Hobo Muscle]:
   case $location[A Maze of Sewer Tunnels]:
   case $location[Hobopolis Town Square]:
   case $location[Burnbarrel Blvd.]:
   case $location[Exposure Esplanade]:
   case $location[The Heap]:
   case $location[The Ancient Hobo Burial Ground]:
   case $location[The Purple Light District]: if (!contains_text(visit_url("town_clan.php"), "clanbasement.gif") ||
                                                   contains_text(visit_url("clan_basement.php?fromabove=1"), "not allowed")) return false;
                                              return true;
   case $location[The Slime Tube]: return (visit_url("town_clan.php").contains_text("clanbasement.gif") && visit_url("clan_slimetube.php").contains_text("thebucket.gif"));
  // sea
   case $location[The Briny Deeps]:
   case $location[The Brinier Deepers]:
   case $location[The Briniest Deepests]:
   case $location[An Octopus Garden]:
   case $location[The Wreck of the Edgar Fitzsimmons]:
   case $location[Madness Reef]:
   case $location[The Marinara Trench]:
   case $location[Anemone Mine]:
   case $location[The Dive Bar]:
   case $location[The Skate Park]:
   case $location[The Mer-Kin Outpost]: return candive();
  // never open
   case $location[Don Crimbo Compound]:
   case $location[Shivering Timbers]:
   case $location[Grim Grimacite Site]:
   case $location[Heartbreaker Hotel]:
   case $location[Future Market Square]:
   case $location[Mall of the Future]:
   case $location[Future Wrong Side of the Tracks]:
   case $location[Icy Peak of the Past]:
   case $location[Spectral Pickle Factory]:
   case $location[Simple Tool-Making Cave]:
   case $location[Crimbo Town Toy Factory]:
   case $location[Atomic Crimbo Toy Factory]:
   case $location[Old Crimbo Town Toy Factory]:
   case $location[Sinister Dodecahedron]:
   case $location[Spooky Fright Factory]:
   case $location[Crimborg Collective Factory]:
   case $location[Spectral Salad Factory]: return vprint(where+" is no longer adventurable.",-6);
   default: vprint("Unknown location: "+where,"olive",-2);
            return vprint("Please report this missing location here: http://kolmafia.us/showthread.php?t=2027","black",-2);
   }
}

void main(location theplace) {
   if (theplace == $location[none]) {
      foreach l in $locations[]
         if (can_adv(l,false)) vprint(l+" is available to your character.","green",7);
          else vprint(l+" is not available to your character.",-6);
      exit;
   }
   if (can_adv(theplace,false)) vprint(theplace+" is available to your character.","green",7);
   else vprint(theplace+" is not available to your character.",-6);
}