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
script "canadv.ash";
notify "Theraze";
import <zlib.ash>

// This will not unlock the guild automatically by default to avoid spending adventures.
// This is a change to legacy behaviour and risks semirares and other limited availability turns.
setvar("canadv_unlockGuild", false);

// Code tweaked from nworbetan from http://kolmafia.us/showthread.php?2027-CanAdv-check-whether-you-can-adventure-at-a-given-location&p=78416&viewfull=1#post78416
// arg = "stepNx" will return N * 10 + <letters a-i transmogrified into digits 1-9>
int numerify(string arg)
{
    int max_steps = 12;
    matcher m_step = create_matcher("^step(\\d+)*$", arg);
    switch {
    case arg == "unstarted": return -1;
    case arg == "started": return 0;
    case arg == "finished": return max_steps + 1;
    case find(m_step):
        int d = group(m_step, 1).to_int();
        if (d <= max_steps) return d;
    }
    vprint("\"" + arg + "\" doesn't make any sense at all.", -3);
    return -11;
}

boolean is_not_yet(string a_string, string b_string)
{
    return (numerify(a_string) < numerify(b_string));
}

boolean is_exactly(string a_string, string b_string)
{
    return (numerify(a_string) == numerify(b_string));
}

boolean is_at_least(string a_string, string b_string)
{
    return (numerify(a_string) >= numerify(b_string));
}

boolean is_past(string a_string, string b_string)
{
    return (numerify(a_string) > numerify(b_string));
}

boolean checkguild() {                            // guild quest-unlocking
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
   if (my_lew() == $item[none]) return false;
   if (!guild_store_available()) {
      if (to_boolean(vars["canadv_unlockGuild"])) cli_execute("guild");
      else return false;
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
   if (where == $location[St. Sneaky Pete's Day Stupor]) return (my_inebriety() > 25 && contains_text(visit_url("main.php"),"St. Sneaky Pete's Day"));
   if (where == $location[Drunken Stupor]) return (my_inebriety() > inebriety_limit());
   if (my_inebriety() > inebriety_limit()) return vprint("You sheriushly shouldn't be advenshuring like thish.",-6);
   if (my_level() != to_int(get_property("lastCouncilVisit"))) visit_url("council.php");
  // load permanently unlocked zones
   string theprop = get_property("unlockedLocations");
   if (theprop == "" || index_of(theprop,"--") < 0 || substring(theprop,0,index_of(theprop,"--")) != to_string(my_ascensions()))
      theprop = my_ascensions()+"--";
   if (contains_text(theprop,where) && !prep) return true;

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
      if (prep && retrieve_item(1,req) && equip(bodzone,req)) ;
      return (item_amount(req) > 0 || have_equipped(req));
   }
   boolean equipcheck(item req) {
      return equipcheck(req,to_slot(req));
   }
   boolean famcheck(familiar req) {
      if (to_familiar(vars["is_100_run"]) != $familiar[none] && req != to_familiar(vars["is_100_run"])) return vprint("You need to equip a "+req+", which you currently can't due to being on a 100% run with a "+to_familiar(vars["is_100_run"])+".",-6);
      if (my_familiar() == req) return true;
      if (have_familiar(req) && prep) return use_familiar(req);
      return have_familiar(req);
   }
   boolean outfitcheck(string req) {
      if (!have_outfit(req)) return vprint("You don't have the '"+req+"' outfit.",-6);
      if (prep) outfit(req);
      return true;
   }
   boolean outfitequipped(string req) {
      if (!have_outfit(req)) return vprint("You don't have the '"+req+"' outfit.",-6);
      foreach num,it in outfit_pieces(req) if (!have_equipped(it)) return false;
      return true;
   }
   boolean perm_urlcheck(string url, string needle) {
      if (contains_text(visit_url(url),needle)) {
         set_property("unlockedLocations",theprop+" "+where);
         return true;
      }
      return false;
   }
   boolean perm_propcheck(string newprop, string needle) {
      if (contains_text(get_property(newprop),needle)) {
         set_property("unlockedLocations",theprop+" "+where);
         return true;
      }
      return false;
   }
   boolean perm_nopropcheck(string newprop, string needle) {
      if (!contains_text(get_property(newprop),needle)) {
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
   case $location[The Sleazy Back Alley]:
   case $location[The Haunted Pantry]:
   case $location[The Outskirts of Cobb's Knob]:
   case $location[The Dire Warren]:
   case $location[The Noob Cave]: return true;
  // casino
   case $location[Goat Party]: if (my_meat() < 5) return vprint("You need 5 meat to play the Goat Party.",-6);
   case $location[Pirate Party]:
   case $location[Lemon Party]: if (my_meat() < 10) return vprint("You need 10 meat to play the "+where+".",-6);
   case $location[The Roulette Tables]: if (my_meat() < 10) return vprint("You need 10 meat to play the "+where+".",-6);
   case $location[The Poker Room]: if (my_meat() < 30) return vprint("You need 10 meat to play the "+where+".",-6); return (itemcheck($item[casino pass]));
  // level-opened
   case $location[The Haiku Dungeon]: return (primecheck(5));
   case $location[Daily Dungeon]: return (primecheck(15));
   case $location[The Limerick Dungeon]: return (primecheck(21));
   case $location[The Spooky Forest]: return (levelcheck(2));
   case $location[A Barroom Brawl]:
   case $location[Tavern Cellar]: return (levelcheck(3));
   case $location[8-Bit Realm]: return (primecheck(20));
   case $location[The Bat Hole Entrance]: return (levelcheck(4) && primecheck(13));
   case $location[Guano Junction]: return (levelcheck(4) && primecheck(13) && resist($element[stench],prep));
   case $location[The Batrat and Ratbat Burrow]: if (get_property("questL04Bat").is_not_yet("step1")) { if (prep) use_upto(1, $item[sonar-in-a-biscuit],true); else return (item_amount($item[sonar-in-a-biscuit]) > 0); } return (levelcheck(4) && primecheck(13) && get_property("questL04Bat").is_at_least("step1"));
   case $location[The Beanbat Chamber]: if (get_property("questL04Bat").is_not_yet("step2")) { if (prep) use_upto(2 - get_property("questL04Bat").numerify() / 10, $item[sonar-in-a-biscuit],true); else return (item_amount($item[sonar-in-a-biscuit]) >= 2 - get_property("questL04Bat").numerify() / 10); } return (levelcheck(4) && primecheck(13) && get_property("questL04Bat").is_at_least("step2"));
   case $location[The Boss Bat's Lair]: if (get_property("questL04Bat").is_not_yet("step3")) { if (prep) use_upto(3 - get_property("questL04Bat").numerify() / 10, $item[sonar-in-a-biscuit],true); else return (item_amount($item[sonar-in-a-biscuit]) >= 3 - get_property("questL04Bat").numerify() / 10); } return (levelcheck(4) && get_property("questL04Bat").is_exactly("step3"));
   case $location[Cobb's Knob Kitchens]: if (!primecheck(20)) return false;
   case $location[Cobb's Knob Barracks]:
   case $location[Cobb's Knob Treasury]:
   case $location[Cobb's Knob Harem]: return (levelcheck(5) && perm_urlcheck("cobbsknob.php",to_url(where)));
   case $location[The Enormous Greater-Than Sign]: return (primecheck(44) && contains_text(visit_url("da.php"),"Greater"));
   case $location[The Dungeons of Doom]: return (primecheck(44) && perm_urlcheck("da.php","ddoom.gif"));
   case $location[Itznotyerzitz Mine (In Disguise)]:
   case $location[Itznotyerzitz Mine]: return (levelcheck(8) && primecheck(53));
   case $location[The Black Forest]: return (levelcheck(11) && primecheck(104));
  // key opened
   case $location[The Knob Shaft]:
   case $location[The Knob Shaft (Mining)]:
   case $location[Cobb's Knob Laboratory]: return (primecheck(30) && itemcheck($item[Cobb's Knob lab key]));
   case $location[Cobb's Knob Menagerie\, Level 1]: return (primecheck(35) && itemcheck($item[Cobb's Knob menagerie key]));
   case $location[Cobb's Knob Menagerie\, Level 2]: return (primecheck(40) && itemcheck($item[Cobb's Knob menagerie key]));
   case $location[Cobb's Knob Menagerie\, Level 3]: return (primecheck(45) && itemcheck($item[Cobb's Knob menagerie key]));
   case $location[Hippy Camp In Disguise]: if (!outfitcheck("filthy hippy disguise")) return false;
   case $location[Hippy Camp]: return ((itemcheck($item[dingy dinghy]) || itemcheck($item[skeletal skiff])) && get_property("warProgress") != "started" && get_property("sideDefeated") != "hippies" && get_property("sideDefeated") != "both" && primecheck(30));
   case $location[Frat House In Disguise]: if (!outfitcheck("frat boy ensemble")) return false;
   case $location[Frat House]: return ((itemcheck($item[dingy dinghy]) || itemcheck($item[skeletal skiff])) && get_property("warProgress") != "started" && get_property("sideDefeated") != "fratboys" && get_property("sideDefeated") != "both" && primecheck(30));
   case $location[The Obligatory Pirate's Cove]: return ((itemcheck($item[dingy dinghy]) || itemcheck($item[skeletal skiff])) && !have_equipped($item[pirate fledges]) && !outfitequipped("swashbuckling getup") && get_property("warProgress") != "started" && primecheck(45));
   case $location[The Castle in the Clouds in the Sky \(Basement\)]:
   case $location[The Castle in the Clouds in the Sky \(Ground Floor\)]:
   case $location[The Castle in the Clouds in the Sky \(Top Floor\)]: return (primecheck(95) && itemcheck($item[S.O.C.K.]));
   case $location[The Hole in the Sky]: return (primecheck(100) && itemcheck($item[steam-powered model rocketship]));
   case $location[The Haunted Library]: return (primecheck(40) && itemcheck($item[Spookyraven library key]));
   case $location[The Haunted Gallery]: return (itemcheck($item[Spookyraven gallery key]));
   case $location[The Haunted Ballroom]: return (itemcheck($item[Spookyraven ballroom key]));
   case $location[The Palindome]: return (primecheck(65) && equipcheck($item[talisman o' nam],$slot[acc3]));
   case $location[Fernswarthy's Basement]: return (itemcheck($item[fernswarthy's letter]) && perm_urlcheck("fernruin.php","basement.php"));
   case $location[Tower Ruins]: return (primecheck(11) && itemcheck($item[fernswarthy's letter]));
   case $location[Battlefield (Cloaca Uniform)]: return (levelcheck(4) && my_level() < 6 && my_ascensions() > 0 && itemcheck($item[fernswarthy's letter]) && outfitcheck("cloaca-cola uniform"));
   case $location[Battlefield (Dyspepsi Uniform)]: if (!outfitcheck("dyspepsi-cola uniform")) return false;
   case $location[Battlefield (No Uniform)]: return (levelcheck(4) && my_level() < 6 && my_ascensions() > 0 && itemcheck($item[fernswarthy's letter]));
   case $location[Desert (Ultrahydrated)]:
   case $location[Desert (Unhydrated)]: return (primecheck(104) && itemcheck($item[your father's macguffin diary]));
   case $location[The Oasis]: return (itemcheck($item[your father's macguffin diary]) && perm_nopropcheck("questL11Pyramid","started"));
   case $location[The Upper Chamber]:
   case $location[The Middle Chamber]: return (itemcheck($item[staff of ed]));
   case $location[Friar Ceremony Location]: return (itemcheck($item[dodecagram]) && itemcheck($item[box of birthday candles]) && itemcheck($item[eldritch butterknife]));
   case $location[Sorceress' Hedge Maze]: return (levelcheck(13) && (itemcheck($item[hedge maze key]) || contains_text(visit_url("questlog.php?which=1"),"a hedge maze")));
  // signs
   case $location[Thugnderdome]: if (!primecheck(25)) return false;
   case $location[Pump Up Moxie]: return (gnomads_available() && can_adv($location[south of the border],prep));
   case $location[The Edge of the Swamp]:
   case $location[The Dark and Spooky Swamp]:
   case $location[The Corpse Bog]:
   case $location[The Ruined Wizard Tower]:
   case $location[The Wildlife Sanctuarrrrrgh]:
   case $location[Swamp Beaver Territory]:
   case $location[The Weird Swamp Village]:
   case $location[Pump Up Mysticality]:
   case $location[Outskirts of Camp Logging Camp]: return (canadia_available());
   case $location[Camp Logging Camp]: return (canadia_available() && primecheck(30));
   case $location[Pump Up Muscle]: return (knoll_available() && (checkguild() || get_property("questM01Untinker") != "unstarted") && perm_urlcheck("plains.php","Degrassi Gnoll"));
   case $location[Bugbear Pens]: return (knoll_available() && primecheck(13) && !contains_text(visit_url("questlog.php?which=2"),"You've helped Mayor Zapruder") && contains_text(visit_url("woods.php"),"pen.gif"));
   case $location[Post-Quest Bugbear Pens]: return (knoll_available() && primecheck(13) && contains_text(visit_url("questlog.php?which=2"),"You've helped Mayor Zapruder") && perm_urlcheck("woods.php","pen.gif"));
   case $location[The Spooky Gravy Barrow]: return (knoll_available() && primecheck(40) &&
						(famcheck($familiar[spooky gravy fairy]) || famcheck($familiar[sleazy gravy fairy]) ||
						famcheck($familiar[frozen gravy fairy]) || famcheck($familiar[flaming gravy fairy]) ||
						famcheck($familiar[stinky gravy fairy])));
  // misc
   case $location[Barrel full of Barrels]: return checkguild();
   case $location[The Hidden Temple]: return (levelcheck(2) && primecheck(5) && perm_urlcheck("woods.php","temple.gif"));
   case $location[Degrassi Knoll]: return (!knoll_available() && primecheck(10) && (checkguild() || get_property("questM01Untinker") != "unstarted") && perm_urlcheck("plains.php","knoll1.gif"));
   case $location[The Fun House]: return (checkguild() && primecheck(15) && perm_urlcheck("plains.php","funhouse.gif"));
   case $location[Throne Room]: return (levelcheck(5) && !contains_text(visit_url("questlog.php?which=2"),"slain the Goblin King") && outfitcheck("harem girl disguise") &&
                                  (effectcheck($effect[knob goblin perfume]) || (!prep && itemcheck($item[knob goblin perfume])) || (prep && use(1,$item[knob goblin perfume]))));
   case $location[Muscle Vacation]:
   case $location[Mysticality Vacation]:
   case $location[Moxie Vacation]: if (my_adventures() < 3) return vprint("Not enough adventures to take a "+where+".",-6); return (perm_urlcheck("main.php","map7beach.gif"));
   case $location[South of the Border]: return (primecheck(10) && perm_urlcheck("main.php","map7beach.gif"));
   case $location[The Defiled Nook]: return (levelcheck(7) && itemcheck($item[evilometer]) && get_property("cyrptNookEvilness").to_int() > 0); 
   case $location[The Defiled Cranny]: return (levelcheck(7) && itemcheck($item[evilometer]) && get_property("cyrptCrannyEvilness").to_int() > 0); 
   case $location[The Defiled Alcove]: return (levelcheck(7) && itemcheck($item[evilometer]) && get_property("cyrptAlcoveEvilness").to_int() > 0); 
   case $location[The Defiled Niche]: return (levelcheck(7) && itemcheck($item[evilometer]) && get_property("cyrptNicheEvilness").to_int() > 0);  
   case $location[Haert of the Cyrpt]: return (levelcheck(7) && visit_url("questlog.php?which=1").contains_text("extreme Spookiness emanating"));
   case $location[Pre-Cyrpt Cemetary]: return (primecheck(11) && (checkguild() || get_property("questL07Cyrptic") != "unstarted") && !visit_url("questlog.php?which=2").contains_text("defeated the Bonerdagon"));
   case $location[Post-Cyrpt Cemetary]: return (primecheck(40) && perm_urlcheck("questlog.php?which=2","defeated the Bonerdagon"));
   case $location[The Goatlet]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("place.php?whichplace=mclargehuge","goatlet.gif"));
   case $location[Lair of the Ninja Snowmen]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("place.php?whichplace=mclargehuge","lair.gif"));
   case $location[The eXtreme Slope]: return (levelcheck(8) && perm_urlcheck("place.php?whichplace=mclargehuge","slope.gif"));
   case $location[Mist-Shrouded Peak]: return (levelcheck(8) && primecheck(53) && get_property("questL08Trapper").is_exactly("step3"));
   case $location[Whitey's Grove]: return (levelcheck(7) && primecheck(34) && (checkguild() || get_property("questL11Palindome") == "step3" || get_property("questL11Palindome") == "step4" || get_property("questL11Palindome") == "finished") && perm_urlcheck("woods.php","grove.gif"));
   case $location[The Dark Neck of the Woods]:
   case $location[The Dark Heart of the Woods]:
   case $location[The Dark Elbow of the Woods]: return (levelcheck(6) && primecheck(29) && !have_skill($skill[liver of steel]) && !have_skill($skill[stomach of steel]) &&
                                                   !have_skill($skill[spleen of steel]) && !contains_text(visit_url("questlog.php?which=2"),"cleansed the taint"));
   case $location[The Laugh Floor]:
   case $location[Infernal Rackets Backstage]:
   case $location[Pandamonium Slums]: return (primecheck(29) && (have_skill($skill[liver of steel]) || have_skill($skill[spleen of steel]) ||
                                         have_skill($skill[stomach of steel]) || perm_urlcheck("questlog.php?which=2","cleansed the taint")));
   case $location[Smut Orc Logging Camp]: return (levelcheck(9));
   case $location[A-Boo Peak]: return (levelcheck(9) && perm_propcheck("chasmBridgeProgress","30"));
   case $location[Twin Peak]: return (levelcheck(9) && perm_propcheck("chasmBridgeProgress","30"));
   case $location[Oil Peak]: return (levelcheck(9) && perm_propcheck("chasmBridgeProgress","30"));
   case $location[The Valley of Rof L'm Fao]: return (levelcheck(9) && perm_nopropcheck("questM15Lol","unstarted"));
   case $location[The Penultimate Fantasy Airship]: return (levelcheck(10) && primecheck(90) && (perm_urlcheck("plains.php","beanstalk.gif") || use(1,$item[enchanted bean])));
   case $location[The Road to White Citadel]: return (!white_citadel_available() && checkguild() && visit_url("woods.php").contains_text("wcroad.gif"));
   case $location[The Haunted Kitchen]: return (primecheck(5) && (itemcheck($item[Spookyraven library key]) || perm_urlcheck("town_right.php","manor.gif")));
   case $location[The Haunted Conservatory]: return (primecheck(6) && perm_urlcheck("town_right.php","manor.gif"));
   case $location[The Haunted Billiards Room]: return (primecheck(10) && perm_urlcheck("town_right.php","manor.gif"));
   case $location[The Haunted Bathroom]: return (primecheck(68) && to_int(get_property("lastSecondFloorUnlock")) == my_ascensions());
   case $location[The Haunted Bedroom]: return (primecheck(85) && to_int(get_property("lastSecondFloorUnlock")) == my_ascensions());
   case $location[Icy Peak]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("questlog.php?which=2","Trapper"));
   case $location[Barrrney's Barrr]: return ((itemcheck($item[dingy dinghy]) || itemcheck($item[skeletal skiff])) && (equipcheck($item[pirate fledges],$slot[acc3]) || outfitcheck("swashbuckling getup")));
   case $location[The F'c'le]: return (pirate_check("cove3_3x1b.gif"));
   case $location[The Poop Deck]: return (pirate_check("cove3_3x3b.gif"));
   case $location[Belowdecks]: return (pirate_check("cove3_5x2b.gif"));
#   case $location[Hidden City (automatic)]:
#   case $location[Hidden City (encounter)]: return (levelcheck(11) && itemcheck($item[your father's macguffin diary]) && perm_urlcheck("woods.php","hiddencity.php"));
   case $location[The Lower Chambers]: return (levelcheck(11) && perm_urlcheck("beach.php","pyramid.php"));
  // nemesis zones
   case $location[Nemesis Cave]: return (primecheck(25) && contains_text(visit_url("mountains.php"),"cave.gif"));
   case $location[The Broodling Grounds]: return (my_class() == $class[seal clubber] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Outer Compound]: return (my_class() == $class[turtle tamer] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Temple Portico]: return (my_class() == $class[pastamancer] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[Convention Hall Lobby]: return (my_class() == $class[sauceror] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[Outside the Club]: return (my_class() == $class[disco bandit] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Island Barracks]: return (my_class() == $class[accordion thief] && primecheck(90) && perm_urlcheck("topmenu.php","volcanoisland.php"));
   case $location[The Nemesis' Lair]: return false;
  // extraordinary zones
   case $location[El Vibrato Island]: return (itemcheck($item[el vibrato trapezoid]) || contains_text(visit_url("campground.php"),"Portal1.gif"));
   case $location[Dwarven Factory Warehouse]:
   case $location[The Mine Foremens' Office]: return (primecheck(100) && outfitcheck("mining gear") && white_citadel_available() && checkguild());
   case $location[The Red Queen's Garden]: return (effectcheck($effect[down the rabbit hole]) || (!prep && itemcheck($item[&quot;DRINK ME&quot; potion])) || (prep && use(1,$item[&quot;DRINK ME&quot; potion])));
   case $location[The Landscaper's Lair]: return (itemcheck($item[antique painting of a landscape]));
   case $location[Professor Jacking's Small-O-Fier]:
   case $location[Professor Jacking's Huge-A-Ma-tron]: return (itemcheck($item[map to Professor Jacking's laboratory]));
   case $location[Foyer]:
   case $location[Chapel]: return (itemcheck($item[map to vanya's castle]) && equipcheck($item[continuum transfunctioner]));
   case $location[Kegger in the Woods]: return (itemcheck($item[map to the kegger in the woods]));
   case $location[The Electric Lemonade Acid Parade]: return (itemcheck($item[map to the magic commune]));
   case $location[Neckback Crick]: return (itemcheck($item[map to ellsbury's claim]));
   case $location[Video Game Level 1]:
   case $location[Video Game Level 2]:
   case $location[Video Game Level 3]: return (itemcheck($item[GameInformPowerDailyPro Walkthru]) || itemcheck($item[GameInformPowerDailyPro magazine]));
  // mr. familiar zones
   case $location[Astral Mushroom (Great Trip)]: if (!primecheck(143)) return false;
   case $location[Astral Mushroom (Mediocre Trip)]: if (!primecheck(51)) return false;
   case $location[Astral Mushroom (Bad Trip)]: return (primecheck(19) && (effectcheck($effect[half-astral]) || itemcheck($item[astral mushroom])));
   case $location[Stately Pleasure Dome]:
   case $location[Mouldering Mansion]:
   case $location[Rogue Windmill]: return (effectcheck($effect[absinthe-minded]) || (!prep && itemcheck($item[tiny bottle of absinthe])) || (prep && use(1,$item[tiny bottle of absinthe])));
   case $location[Mt. Molehill]: return (effectcheck($effect[shape of...mole!]) || (!prep && itemcheck($item[llama lama gong])));
   case $location[The Primordial Soup]:
   case $location[The Jungles of Ancient Loathing]:
   case $location[Seaside Megalopolis]: return itemcheck($item[empty agua de vida bottle]);
   case $location[Hamburglaris Shield Generator]:
   case $location[Domed City of Grimacia]:
   case $location[Domed City of Ronaldus]: return (effectcheck($effect[transpondent]) || (!prep && itemcheck($item[transporter transponder])) || (prep && use(1,$item[transporter transponder])));
   case $location[The Clumsiness Grove]:
   case $location[The Glacier of Jerks]:
   case $location[The Maelstrom of Lovers]: return (effectcheck($effect[dis abled]) || (!prep && itemcheck($item[devilish folio])) || (prep && use(1,$item[devilish folio])));
  // islewar stuffs
   case $location[Wartime Hippy Camp (Frat Disguise)]: if (!outfitcheck("frat boy ensemble")) return false;
   case $location[Wartime Hippy Camp]: return (levelcheck(12) && get_property("warProgress") == "unstarted");
   case $location[Wartime Frat House (Hippy Disguise)]: if (!outfitcheck("filthy hippy disguise")) return false;
   case $location[Wartime Frat House]: return (levelcheck(12) && get_property("warProgress") == "unstarted");
   case $location[The Battlefield (Frat Uniform)]: return (get_property("warProgress") == "started" && outfitcheck("frat warrior") && get_property("hippiesDefeated") != "1000");
   case $location[The Battlefield (Hippy Uniform)]: return (get_property("warProgress") == "started" && outfitcheck("war hippy fatigues") && get_property("fratboysDefeated") != "1000");
   case $location[The Themthar Hills]: return (get_property("warProgress") == "started" && get_property("sidequestNunsCompleted") == "none");
   case $location[The Hatching Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none");
   case $location[The Feeding Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none" && effectcheck($effect[filthworm larva stench]));
   case $location[The Royal Guard Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none" && effectcheck($effect[filthworm drone stench]));
   case $location[The Filthworm Queen's Chamber]: return (get_property("warProgress") == "started" && get_property("sidequestOrchardCompleted") == "none" && effectcheck($effect[filthworm guard stench]));
#   case $location[Wartime Sonofa Beach]: return (get_property("warProgress") == "started" && get_property("sidequestLighthouseCompleted") == "none");
   case $location[Next to that Barrel with Something Burning in it]:
   case $location[Near an Abandoned Refrigerator]:
   case $location[Over Where the Old Tires Are]:
   case $location[Out by that Rusted-Out Car]: return (get_property("warProgress") == "started" && get_property("sidequestJunkyardCompleted") == "none");
   case $location[Mcmillicancuddy's Barn]:
   case $location[Mcmillicancuddy's Pond]:
   case $location[Mcmillicancuddy's Back 40]:
   case $location[Mcmillicancuddy's Other Back 40]:
   case $location[Mcmillicancuddy's Granary]:
   case $location[Mcmillicancuddy's Bog]:
   case $location[Mcmillicancuddy's Family Plot]:
   case $location[Mcmillicancuddy's Shady Thicket]: return (get_property("warProgress") == "started" && get_property("sidequestFarmCompleted") == "none");
   case $location[The Hippy Camp (Bombed Back to the Stone Age)]: return (get_property("warProgress") == "finished" && get_property("sideDefeated") != "fratboys");
   case $location[The Frat House (Bombed Back to the Stone Age)]: return (get_property("warProgress") == "finished" && get_property("sideDefeated") != "hippies");
   case $location[McMillicancuddy's Farm]:
   case $location[Post-War Junkyard]:
#   case $location[Post-War Sonofa Beach]: return (levelcheck(12) && get_property("warProgress") == "finished");
   case $location[Sonofa Beach]: return (levelcheck(12) && get_property("warProgress") == "finished");
  // bugbear-only
   case $location[Medbay]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataMedbay").to_int() > 2);
   case $location[Sonar]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataSonar").to_int() > 2);
   case $location[Waste Processing]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataWasteProcessing").to_int() > 2);
   case $location[Science Lab]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataScienceLab").to_int() > 5);
   case $location[Morgue]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataMorgue").to_int() > 5);
   case $location[Special Ops]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataSpecialOps").to_int() > 5);
   case $location[Engineering]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataEngineering").to_int() > 8);
   case $location[Navigation]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataNavigation").to_int() > 8);
   case $location[Galley]: return (my_path() == "Bugbear Invasion" && item_amount($item[key-o-tron]) > 0 && get_property("biodataGalley").to_int() > 8);
  // holiday-only
   case $location[Spectral Pickle Factory]: if (!primecheck(50) || today_to_string().substring(4, 8) != "0401") return false;
   case $location[Arrrboretum]: return gameday_to_string() == "Petember 4";
   case $location[Generic Summer Holiday Swimming!]: return gameday_to_string() == "Bill 3";
   case $location[Trick-or-Treating]: return (gameday_to_string() == "Porktember 8" || today_to_string().substring(4, 8) == "1031");
   case $location[The Yuletide Bonfire]: return gameday_to_string() == "Dougtember 4";
  // clan basement
   case $location[Richard's Hobo Mysticality]:
   case $location[Richard's Hobo Moxie]:
   case $location[Richard's Hobo Muscle]:
   case $location[A Maze of Sewer Tunnels]:
   case $location[Hobopolis Town Square]:
   case $location[Burnbarrel Blvd.]:
   case $location[Exposure Esplanade]:
   case $location[The Heap]:
   case $location[The Ancient Hobo Burial Ground]:
   case $location[The Purple Light District]: if (!contains_text(visit_url("town_clan.php"), "clanbasement.gif") ||
                                                   contains_text(visit_url("clan_basement.php?fromabove=1"), "not allowed")) return false;
                                              return true;
   case $location[The Slime Tube]: return (visit_url("clan_slimetube.php").contains_text("thebucket.gif"));
   case $location[Dreadsylvanian Woods]:
   case $location[Dreadsylvanian Village]:
   case $location[Dreadsylvanian Castle]: if (!contains_text(visit_url("town_clan.php"), "clanbasement.gif") ||
                                                   contains_text(visit_url("clan_basement.php?fromabove=1"), "not allowed")) return false;
                                              return true;
  // sea
   case $location[The Briny Deeps]:
   case $location[The Brinier Deepers]:
   case $location[The Briniest Deepests]:
   case $location[An Octopus's Garden]: return candive();
   case $location[The Wreck of the Edgar Fitzsimmons]: return (candive() && visit_url("seafloor.php").contains_text("shipwreckb.gif"));
   case $location[Madness Reef]: return (candive() && visit_url("seafloor.php").contains_text("reefb.gif"));
   case $location[The Marinara Trench]: return (candive() && visit_url("seafloor.php").contains_text("trenchb.gif"));
   case $location[Anemone Mine]:
   case $location[Anemone Mine (Mining)]: return (candive() && visit_url("seafloor.php").contains_text("mineb.gif"));
   case $location[The Dive Bar]: return (candive() && visit_url("seafloor.php").contains_text("divebarb.gif"));
   case $location[The Skate Park]: return (candive() && visit_url("seafloor.php").contains_text("skateparkb.gif"));
   case $location[The Mer-Kin Outpost]: return (candive() && visit_url("seafloor.php").contains_text("outpostb.gif"));
   case $location[The Coral Corral]: return (candive() && visit_url("seafloor.php").contains_text("corralb.gif"));
   case $location[The Caliginous Abyss]: return (candive() && visit_url("seafloor.php").contains_text("abyssb.gif"));
   case $location[Mer-kin Elementary School]:
   case $location[Mer-kin Gymnasium]: return (candive() && get_property("seahorseName") != "" && outfitcheck("Crappy Mer-kin Disguise"));
   case $location[Mer-kin Library]: return (candive() && get_property("seahorseName") != "" && outfitcheck("Mer-kin Scholar's Vestments"));
   case $location[Mer-kin Colosseum]: return (candive() && get_property("seahorseName") != "" && outfitcheck("Mer-kin Gladiatorial Gear"));
  // psychoanalytic jars
   case $location[Anger Man's Level]:
   case $location[Fear Man's Level]:
   case $location[Doubt Man's Level]:
   case $location[Regret Man's Level]: return ((get_campground() contains $item[jar of psychoses (The Crackpot Mystic)]) || itemcheck($item[jar of psychoses (The Crackpot Mystic)]));
   case $location[The Nightmare Meatrealm]: return ((get_campground() contains $item[jar of psychoses (The Meatsmith)]) || itemcheck($item[jar of psychoses (The Meatsmith)]));
   case $location[A Kitchen Drawer]:
   case $location[A Grocery Bag]: return ((get_campground() contains $item[jar of psychoses (The Pretentious Artist)]) || itemcheck($item[jar of psychoses (The Pretentious Artist)]));
   case $location[Chinatown Shops]:
   case $location[Triad Factory]:
   case $location[1st Floor, Shiawase-Mitsuhama Building]:
   case $location[2nd Floor, Shiawase-Mitsuhama Building]:
   case $location[3rd Floor, Shiawase-Mitsuhama Building]:
   case $location[Chinatown Tenement]: return ((get_campground() contains $item[jar of psychoses (The Suspicious-Looking Guy)]) || itemcheck($item[jar of psychoses (The Suspicious-Looking Guy)]));
   case $location[The Gourd!]: return ((get_campground() contains $item[jar of psychoses (The Captain of the Gourd)]) || itemcheck($item[jar of psychoses (The Captain of the Gourd)]));
   case $location[The Tower of Procedurally-Generated Skeletons]: return ((get_campground() contains $item[jar of psychoses (Jick)]) || itemcheck($item[jar of psychoses (Jick)]));
   case $location[The Old Man's Bathtime Adventures]: return ((get_campground() contains $item[jar of psychoses (The Old Man)]) || itemcheck($item[jar of psychoses (The Old Man)]));
  // never open
   case $location[A Massive Flying Battleship]:
   case $location[A Pile of Old Servers]:
   case $location[A Skeleton Invasion!]:
   case $location[A Supply Train]:
   case $location[A Swarm of Yeti-Mounted Skeletons]:
   case $location[Atomic Crimbo Toy Factory]:
   case $location[CRIMBCO cubicles]:
   case $location[CRIMBCO WC]:
   case $location[Crimbo Town Toy Factory]:
   case $location[Crimbokutown Toy Factory]:
   case $location[Crimborg Collective Factory]:
   case $location[Elf Alley]:
   case $location[Fierce Flying Flames]:
   case $location[Fightin' Fire]:
   case $location[Fudge Mountain]:
   case $location[Future Market Square]:
   case $location[Future Wrong Side of the Tracks]:
   case $location[Grim Grimacite Site]:
   case $location[Heartbreaker's Hotel]:
   case $location[Icy Peak of the Past]:
   case $location[Lollipop Forest]:
   case $location[Lord Flameface's Castle Belfry]:
   case $location[Lord Flameface's Castle Entryway]:
   case $location[Lord Flameface's Throne Room]:
   case $location[Mall of the Future]:
   case $location[Old Crimbo Town Toy Factory]:
   case $location[Shivering Timbers]:
   case $location[Simple Tool-Making Cave]:
   case $location[Sinister Dodecahedron]:
   case $location[Spooky Fright Factory]:
   case $location[Super-Intense Mega-Grassfire]:
   case $location[The Bonewall]:
   case $location[The Bone Star]:
   case $location[The Cannon Museum]:
   case $location[The Don's Crimbo Compound]:
   case $location[The Haunted Sorority House]:
   case $location[Spectral Salad Factory]: return vprint(where+" is no longer adventurable.",-9);
   default: vprint("Unknown location: "+where,"olive",-2);
            return vprint("Please report this missing location here: http://kolmafia.us/showthread.php?t=2027","black",-2);
   }
}

boolean can_adv(location where) {
   return can_adv(where, false);
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

check_version("The CanAdv Project","canadv","0.90",2027);