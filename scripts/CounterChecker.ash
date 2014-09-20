// CounterChecker
// Thanks to those whose work has been absorbed to make this: 
//    jasonharper, StormCrow42, Alhifar, Ankorite, antimarty, Miser, slyz
// Revisioned and reconstructed by Bale.

// To use:
// Install zarqon's zlib: http://kolmafia.us/showthread.php?t=2072
// set counterScript = CounterChecker.ash
// set wormwood = objective
//     objective can be any wormwood prize or stat. (eg. moxie51 or cancan skirt) 
//     You can add 51 or 1 to a stat to limit the turns you spend on your stat adventures.
//     This script is very good at figuring out what you mean, so you can just type "cancan", "skirt" or "pants".

// Supported Counters:
//  - Fortune Cookie: If you're not in hardcore it will get the available semi-rare with highest mall price.
//  - Wormwood: Will automatically get the wormwood goal of your choice. You can set the goal in CLI with:
//         set wormwood = xxx
//         where xxx is a stat or item. (Optionally add 951, 51 or 1 to limit the turns spent on stats.)
//  - Dance Card: Will adventure in Ballroom, if you're not already there and use another dance card.
//  - CLI: You can delay execution of a CLI command. To defer it for <num> turns, type this in the CLI:
//         counters add <num> cli <command>
//  - Lights Out: Will get the "Lights Out" noncombats to encounter Stephen and Elizabeth.

script "CounterChecker.ash";
notify Bale;
import <zlib.ash>
check_version("CounterChecker", "bale-counterchecker", "1.6", 2519);

// All user configurable variables are stored in a txt file in your /data directory specific to each character. 
// To change them use notepad and look for vars_<character>.txt, replacing <character> with the character's name.
// BaleCC_SrInHC             - Automate Semi-rares in Hardcore or Ronin
// BaleCC_useDanceCards      - Use another dance card after every Dancing Matilda
// BaleCC_ImprovePoolSkills  - Improve chance of winning at Pool table with semi-rares
// BaleCC_SellSemirare       - Sell the semi-rare as you get it
// These are default values here. To change for each character, edit their vars file in /data direcory.
setvar("BaleCC_SrInHC", FALSE);
setvar("BaleCC_useDanceCards", TRUE);
setvar("BaleCC_ImprovePoolSkills", FALSE);
setvar("BaleCC_SellSemirare", FALSE);
setvar("BaleCC_SemirareWindowContinue", FALSE);
setvar("BaleCC_LightsOutFightAutomated", FALSE);
setvar("BaleCC_LightsOutPreferred", "Stephen Spookyraven");

record queue_entry {
	location loc;	// Where to find the semi-rare
	int q;			// Quantity. Zero means infinite. Positive means available_amount(). Negative means to increment every time one is garnered.
	string extra;	// Some locations need extra info. Billiard room values are "item" and "stats"
};
queue_entry [int] SrQueue;
if(!file_to_map("SrQueue_"+my_name()+".txt", SrQueue)) {}

item [location] semi_rare;
	semi_rare[$location[The Haunted Billiards Room]] = $item[cube of billiard chalk];
	semi_rare[$location[Cobb's Knob Menagerie\, Level 2]] = $item[irradiated pet snacks];
	semi_rare[$location[The Outskirts of Cobb's Knob]] = $item[Knob Goblin lunchbox];
	semi_rare[$location[The Limerick Dungeon]] = $item[cyclops eyedrops];
	semi_rare[$location[The Sleazy Back Alley]] = $item[distilled fortified wine];
	semi_rare[$location[The Haunted Pantry]] = $item[tasty tart];
	semi_rare[$location[Cobb's Knob Harem]] = $item[scented massage oil];
	semi_rare[$location[The Haunted Kitchen]] = $item[freezerburned ice cube];
	semi_rare[$location[The Haunted Library]] = $item[black eyedrops];
	semi_rare[$location[The Goatlet]] = $item[can of spinach];
	semi_rare[$location[Lair of the Ninja Snowmen]] = $item[bottle of antifreeze];
	semi_rare[$location[The Valley of Rof L'm Fao]] = $item[ASCII shirt];
	semi_rare[$location[Battlefield (No Uniform)]] = $item[six-pack of New Cloaca-Cola];
	semi_rare[$location[The Batrat and Ratbat Burrow]] = $item[Dogsgotnonoz pills];
	semi_rare[$location[The Castle in the Clouds in the Sky (Top Floor)]] = $item[Mick's IcyVapoHotness Inhaler];
	semi_rare[$location[The Castle in the Clouds in the Sky (Ground Floor)]] = $item[Possibility Potion];
	semi_rare[$location[The Castle in the Clouds in the Sky (Basement)]] = $item[Super Weight-Gain 9000];
	semi_rare[$location[Guano Junction]] = $item[Eau de Guaneau];
	semi_rare[$location[Cobb's Knob Laboratory]] = $item[bottle of Mystic Shell];
	semi_rare[$location[Pre-Cyrpt Cemetary]] = $item[poltergeist-in-the-jar-o];
	semi_rare[$location[Post-Cyrpt Cemetary]] = $item[poltergeist-in-the-jar-o];
	semi_rare[$location[South of The Border]] = $item[donkey flipbook];
	semi_rare[$location[Pandamonium Slums]] = $item[SPF 451 lip balm];
	semi_rare[$location[The Hidden Park]] = $item[shrinking powder];
	semi_rare[$location[8-Bit Realm]] = $item[fire flower];
	semi_rare[$location[The Spooky Forest]] = $item[fake blood];
	semi_rare[$location[Whitey's Grove]] = $item[bag of lard];
	semi_rare[$location[Hippy Camp]] = $item[teeny-tiny magic scroll];
	semi_rare[$location[Frat House]] = $item[bottle of rhinoceros hormones];
	semi_rare[$location[The Obligatory Pirate's Cove]] = $item[bottle of pirate juice];
	semi_rare[$location[The Purple Light District]] = $item[lewd playing card];
	semi_rare[$location[Burnbarrel Blvd.]] = $item[jar of squeeze];
	semi_rare[$location[Exposure Esplanade]] = $item[bowl of fishysoisse];
	semi_rare[$location[The Heap]] = $item[concentrated garbage juice];
	semi_rare[$location[The Ancient Hobo Burial Ground]] = $item[deadly lampshade];
	semi_rare[$location[Vanya's Castle Chapel]] = $item[pixel stopwatch];
	semi_rare[$location[A-Boo Peak]] = $item[death blossom];
	semi_rare[$location[Twin Peak]] = $item[miniature boiler];
	semi_rare[$location[Oil Peak]] = $item[unnatural gas];
	semi_rare[$location[The Copperhead Club]] = $item[Flamin' Whatshisname];
	semi_rare[$location[The Red Zeppelin]] = $item[red foxglove];
	semi_rare[$location[The Haunted Boiler Room]] = $item[Bram's choker];
int[item] rare_quant;
	rare_quant[$item[distilled fortified wine]] = 3;
	rare_quant[$item[tasty tart]] = 3;
	rare_quant[$item[scented massage oil]] = 3;
	rare_quant[$item[Flamin' Whatshisname]] = 3;

// I only want to check these once, so I'm making it global
boolean can_hobo = visit_url("town_clan.php").contains_text("clanbasement.gif")    // Does the clan have a basement?
	&& !visit_url("clan_basement.php?fromabove=1").contains_text("not allowed")    // Do you have access to that basement?
	&& !visit_url("clan_hobopolis.php?place=2").contains_text("townsquare26.gif"); // Has Hodgman been killed?

// Not using this anymore, but leaving it for now in case that changes
string [string] url_check;  // Let's not check plains.php four times or mountains.php twice and so forth
string unlockedLocations = get_property("unlockedLocations");
if(unlockedLocations == "" || index_of(unlockedLocations,"--") < 0 || 
  substring(unlockedLocations,0,index_of(unlockedLocations,"--")) != to_string(my_ascensions()))
	unlockedLocations = my_ascensions()+"--";

string get_url(string url) {
	if(!(url_check contains url))
		url_check[url] = visit_url(url);
	return url_check[url];
}

// Gear up for 8-bit and Vanya's Chappel
boolean pixelize(boolean chapel) {
	if(available_amount($item[continuum transfunctioner]) == 0) {
		print("You stop off at the Crackpot Mystic's Shed and listen to a long boring story.", "blue");
		visit_url("mystic.php?action=crackyes3&crack1=Er%2C+sure%2C+I+guess+so...&pwd");
	}
	item chapel_weapon() {
		for i from 4589 to 4591
			if(available_amount(to_item(i)) > 0) return i.to_item();
		return $item[none];
	}
	item weapon = equipped_item($slot[weapon]);
	string gear = ".4 mp, .3 hp, .2 mp regen min, .1 hp regen min, +equip continuum transfunctioner, -hat -pants -shirt -offhand";
	if(chapel)
		gear+= " +equip "+chapel_weapon();
	else gear+= " -weapon";
	print("maximize "+ gear);
	return maximize(gear, false);
}

// Gear up for Guano Junction
boolean stinkup(boolean sim) {
	if(elemental_resistance($element[stench]) > (my_primestat() == $stat[Mysticality]? 5: 0)) return true;
	return maximize("1 max, 1 min, stench resistance, -tie, switch exotic parrot", sim);
}

boolean canadv(location loc) {
		
	string hobo_zone(location loc) {
		int zone() {
			switch(loc) {
			case $location[Burnbarrel Blvd.]: return 4;
			case $location[Exposure Esplanade]: return 5;
			case $location[The Heap]: return 6;
			case $location[The Ancient Hobo Burial Ground]: return 7;
			case $location[The Purple Light District]: return 8;
			}
			return 1;
		}
		return "clan_hobopolis.php?place="+zone()+"&pwd";
	}
	
	boolean unlocked(string pref) {
		return get_property(pref).to_int() == my_ascensions();
	}

	switch(loc) {
	case $location[The Outskirts of Cobb's Knob]:
	case $location[The Sleazy Back Alley]:
	case $location[The Haunted Pantry]:
		return true;
	case $location[The Limerick Dungeon]:
		return my_buffedstat(my_primestat()) > 20;
	case $location[The Haunted Kitchen]:
	case $location[The Haunted Conservatory]:
		return available_amount($item[telegram from Lady Spookyraven]) == 0 & (my_ascensions() > 0 || my_level() >= 4);
	case $location[The Haunted Billiards Room]:
		return item_amount($item[Spookyraven billiards room key]) > 0;
	case $location[The Haunted Library]:
		return available_amount($item[Spookyraven library key]) > 0;
	case $location[The Haunted Bathroom]:
	case $location[The Haunted Bedroom]:
	case $location[The Haunted Gallery]:
		return get_property("questM21Dance") != "unstarted";
	case $location[The Haunted Ballroom]:
		return $strings[step3, finished] contains get_property("questM21Dance");
	case $location[The Haunted Laboratory]:
	case $location[The Haunted Nursery]:
	case $location[The Haunted Storage Room]:
		return get_property("questM21Dance") == "finished";
	case $location[The Haunted Boiler Room]:
	case $location[The Haunted Laundry Room]:
	case $location[The Haunted Wine Cellar]:
		return get_property("questL11Manor") == "finished";
	case $location[Cobb's Knob Laboratory]:
		return available_amount($item[Cobb's Knob lab key]) > 0;
	case $location[Cobb's Knob Menagerie\, Level 2]:
		return available_amount($item[Cobb's Knob Menagerie key]) > 0;
	case $location[Cobb's Knob Harem]:
		return get_property("questL05Goblin") == "finished" || get_property("questL05Goblin") == "step1";
	case $location[The Goatlet]:
		if(get_property("questL08Trapper") == "step2") return true;
	case $location[Lair of the Ninja Snowmen]:
		return get_property("questL08Trapper") == "finished" || get_property("questL08Trapper") == "step3";
	case $location[The Valley of Rof L'm Fao]:
		return get_property("questL09Lol") == "finished" || get_property("questL09Lol") == "step1";
	case $location[Battlefield (No Uniform)]:
		return my_level() >= 4 && my_level() < 6 && my_ascensions() > 0 && available_amount($item[fernswarthy's letter]) > 0;
	case $location[The Castle in the Clouds in the Sky (Top Floor)]:
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]:
	case $location[The Castle in the Clouds in the Sky (Basement)]:
		return item_amount($item[S.O.C.K.]) + item_amount($item[intragalactic rowboat]) + item_amount($item[steam-powered model rocketship]) > 0;
	case $location[Guano Junction]:
		return get_property("questL04Bat") != "unstarted" && stinkup(true);
	case $location[The Batrat and Ratbat Burrow]:
		return get_property("questL04Bat") != "unstarted" && get_property("questL04Bat") != "started";
	case $location[South of The Border]:
		foreach it in $items[pumpkin carriage,desert bus pass, bitchin' meatcar, tin lizzie]
			if(available_amount(it) > 0) return true;
		return false;
	case $location[Pre-Cyrpt Cemetary]:
		return my_buffedstat(my_primestat()) >= 11 && get_property("questL07Cyrptic") != "finished"
		  && get_property("questG03Ego") != "unstarted";
	case $location[Post-Cyrpt Cemetary]:
		return my_buffedstat(my_primestat()) >= 40 && get_property("questL07Cyrptic") == "finished";
	case $location[The Dark Elbow of the Woods]:
	case $location[The Dark Heart of the Woods]:
	case $location[The Dark Neck of the Woods]:
		return get_property("questL06Friar") == "started";
	case $location[Pandamonium Slums]:
		return my_buffedstat(my_primestat()) >= 29 && get_property("questL06Friar") == "finished";
	case $location[The Hidden Park]:
		return get_property("questL11Worship") != "unstarted";
	case $location[8-Bit Realm]:
		return my_buffedstat(my_primestat()) >= 20 && available_amount($item[continuum transfunctioner]) > 0;
	case $location[Vanya's Castle Chapel]:
		return available_amount($item[continuum transfunctioner]) > 0 && available_amount($item[map to Vanya's Castle]) > 0
			&& (available_amount($item[pixel whip]) > 0 || available_amount($item[pixel chain whip]) > 0 || available_amount($item[pixel morning star]) > 0);
	case $location[The Spooky Forest]:
		return get_property("questL02Larva") != "unstarted";
	case $location[Whitey's Grove]:
		return get_property("questG02Whitecastle") != "unstarted" 
		  || $strings[finished, step3, step4] contains get_property("questL11Palindome");
	case $location[Hippy Camp]:
		return unlocked("lastIslandUnlock") && (get_property("questL12War") == "unstarted" || get_property("sideDefeated") == "fratboys");
	case $location[Frat House]:
		return unlocked("lastIslandUnlock") && (get_property("questL12War") == "unstarted" || get_property("sideDefeated") == "hippies");
	case $location[The Obligatory Pirate's Cove]:
		return unlocked("lastIslandUnlock") && ($strings[unstarted, finished] contains get_property("questL12War"));
	case $location[Twin Peak]:
		if(get_property("twinPeakProgress") == "15") return false;
	case $location[A-Boo Peak]:
	case $location[Oil Peak]:
		return unlocked("lastChasmReset") && get_property("chasmBridgeProgress") == "30";
	case $location[The Copperhead Club]:
		return !contains_text(get_property("questL11MacGuffin"), "started"); // Needs to be greater than unstarted or started.
	case $location[The Red Zeppelin]:
		return get_property("zeppelinProtestors") >= 80;
	case $location[The Purple Light District]:
	case $location[Burnbarrel Blvd.]:
	case $location[Exposure Esplanade]:
	case $location[The Heap]:
	case $location[The Ancient Hobo Burial Ground]:
		if(available_amount($item[hobo nickel]) < 5) return false;
		return can_hobo && visit_url(hobo_zone(loc)).contains_text(to_url(loc));
	}
	return false;
}

// This will return the location of the currently most expensive semi-rare
location expensive_semi() {
	location last_rare = get_property("semirareLocation").to_location();
	// If ImprovePoolSkills, then play a game of pool at every opportunity!
	if(get_property("poolSharkCount").to_int() < 25 && vars["BaleCC_ImprovePoolSkills"].to_boolean() && last_rare != $location[The Haunted Billiards Room])
		return $location[The Haunted Billiards Room];

	if(!canadv($location[Pandamonium Slums])) {  // Let's make sure the choice is ascension helpful
		if(available_amount($item[eldritch butterknife]) < 1)
			semi_rare[$location[The Dark Elbow of the Woods]] = $item[SPF 451 lip balm];
		else if(available_amount($item[box of birthday candles]) < 1)
			semi_rare[$location[The Dark Heart of the Woods]] = $item[SPF 451 lip balm];
		else
			semi_rare[$location[The Dark Neck of the Woods]] = $item[SPF 451 lip balm];
	}

	
	int expensive = 0;
	int rare_price;
	location best = $location[none];
	foreach locale, rare in semi_rare {
		if(locale == last_rare || !canadv(locale)) continue;
		if(historical_age(rare) > 1 || historical_price(rare) == 0)
			mall_price(rare);
		rare_price = historical_price(rare) * ((rare_quant contains rare)? rare_quant[rare]: 1); 
		if(rare_price > expensive) {
			best = locale;
			expensive = rare_price;
		}
	}
	if(best == $location[none]) {
		print("Something went wrong determing the best semi-rare. Please copy-paste this output to http://kolmafia.us/showthread.php?t=2519", "red");
		foreach locale, rare in semi_rare
			print(rare+" sells for "+historical_price(rare)+" meat.");
		abort("Please continue manually. Sorry for the bug.");
	}
	boolean plural = rare_quant contains semi_rare[best];
	print((plural? rare_quant[semi_rare[best]]+" "+semi_rare[best].plural+" are": ("A "+semi_rare[best])+" is")
	  +" currently selling for "+ rnum(historical_price(semi_rare[best]))+" meat "+(plural? " each.":"."));
	return best;
}

// semi-rare acquired, let's do it again
setvar("auto_semirare", "true");  // Weird name because it comes from zarqon's BBB
void eat_cookie() {
	int count_counters() {
		string counters = get_counters("Fortune Cookie", 0, 200);
		if(counters == "") return 0;
		return count(split_string(counters, "\t"));
	}
	
	boolean toEat() {
		if(my_path() == "Zombie Slayer")
			return vprint("You can not find a brain flavored fortune cookie, so you will have to drink a Lucky Lindy on your own.", -3);
		matcher cooks = create_matcher("(timely|always|true|never|false) ?([1-3]?)", vars["auto_semirare"]);
		if(cooks.find())
			switch(cooks.group(1)) {
			case "false":
			case "never":
			case "timely": return false;
			case "always":
			case "true":
				if(count_counters() > 3) return false; // Too many means there's a problem. Don't burn off fullness
				if(count_counters() < 1) return true;
				if(cooks.group(2) != "")
					return count_counters() > cooks.group(2).to_int();
			}
		return count_counters() < 1;
	}
	
	if(my_fullness() >= fullness_limit())
		print("If I ate even a fortune cookie I'd burst! Remember to eat a fortune cookie when the tummy is emptier.", "red");
	else while(toEat())
		eatsilent(1, $item[fortune cookie]);
}

void get_semirare() {
	int last = get_property("semirareCounter").to_int();
	
	location locale = expensive_semi();
	string billiard;
	familiar start_fam = my_familiar();
	int closet_clovers = 0;
	switch(locale) {
	case $location[The Haunted Billiards Room]:
		billiard = get_property("choiceAdventure330");
		set_property("choiceAdventure330", (vars["BaleCC_ImprovePoolSkills"].to_boolean() ? "1" : "2"));
		closet_clovers = item_amount($item[ten-leaf clover]);
		put_closet(closet_clovers, $item[ten-leaf clover]);
		break;
	case $location[8-Bit Realm]:
		cli_execute("checkpoint");
		pixelize(false);
		break;
	case $location[Vanya's Castle Chapel]:
		cli_execute("checkpoint");
		pixelize(true);
		break;
	case $location[The Obligatory Pirate's Cove]:
		cli_execute("checkpoint");
		if(have_equipped($item[pirate fledges]))
			cli_execute("unequip pirate fledges");
		break;
	case $location[Guano Junction]:
		cli_execute("checkpoint");
		stinkup(false);
		// fall through to the next section...
	case $location[The Outskirts of Cobb's Knob]:
	case $location[The Limerick Dungeon]:
	case $location[The Sleazy Back Alley]:
	case $location[The Haunted Pantry]:
	case $location[Cobb's Knob Harem]:
	case $location[The Haunted Kitchen]:
	case $location[The Haunted Library]:
	case $location[Cobb's Knob Laboratory]:
	case $location[Pre-Cyrpt Cemetary]:
	case $location[Post-Cyrpt Cemetary]:
	case $location[South of The Border]:
	case $location[The Spooky Forest]:
	case $location[Hippy Camp]:
	case $location[Frat House]:
		closet_clovers = item_amount($item[ten-leaf clover]);
		put_closet(closet_clovers, $item[ten-leaf clover]);
		break;
	}
	set_property("BaleCC_next", locale);
	(!adventure(1, locale));
	if(get_property("semirareCounter").to_int() != last) {
		// semi-rare acquired! Now set up for the next semi-rare
		if(vars["BaleCC_SellSemirare"].to_boolean() && have_shop())
			put_shop(historical_price(semi_rare[locale]), 0,
			  (rare_quant contains semi_rare[locale]? rare_quant[semi_rare[locale]]: 1), semi_rare[locale]);
		eat_cookie();
		set_property("BaleCC_next", expensive_semi());
	} else
		print("Oops, that wasn't the right number!", "red");
	if(closet_clovers > 0)
		take_closet(closet_clovers, $item[ten-leaf clover]);
	switch(locale) {
	case $location[The Haunted Billiards Room]:
		set_property("choiceAdventure330", billiard);
		break;
	case $location[Guano Junction]:
		if(start_fam != my_familiar())
			use_familiar(start_fam);
		cli_execute("outfit checkpoint");
		break;
	case $location[8-Bit Realm]:
	case $location[Vanya's Castle Chapel]:
	case $location[The Obligatory Pirate's Cove]:
		cli_execute("outfit checkpoint");
	}
}

string wormwood_choice(string goal, string choice_adv_num) {
	string [string, string] choice_num;
		choice_num ["not-a-pipe", "164"] = "2";
		choice_num ["not-a-pipe", "168"] = "2";
		choice_num ["not-a-pipe", "172"] = "2";
		choice_num ["flask of Amontillado", "170"] = "1";
		choice_num ["flask of Amontillado", "165"] = "1";
		choice_num ["flask of Amontillado", "169"] = "1";
		choice_num ["S.T.L.T.", "167"] = "3";
		choice_num ["S.T.L.T.", "171"] = "1";
		choice_num ["S.T.L.T.", "166"] = "1";
		choice_num ["fancy ball mask", "164"] = "2";
		choice_num ["fancy ball mask", "171"] = "3";
		choice_num ["fancy ball mask", "169"] = "3";
		choice_num ["albatross necklace", "170"] = "1";
		choice_num ["albatross necklace", "168"] = "3";
		choice_num ["albatross necklace", "166"] = "3";
		choice_num ["Can-Can skirt", "167"] = "3";
		choice_num ["Can-Can skirt", "165"] = "2";
		choice_num ["Can-Can skirt", "172"] = "1";
		choice_num ["Muscle", "164"] = "1";
		choice_num ["Muscle", "171"] = "2";
		choice_num ["Muscle", "169"] = "2";
		choice_num ["Moxie", "170"] = "3";
		choice_num ["Moxie", "168"] = "1";
		choice_num ["Moxie", "166"] = "2";
		choice_num ["Mysticality", "167"] = "2";
		choice_num ["Mysticality", "165"] = "3";
		choice_num ["Mysticality", "172"] = "3";
	return choice_num[goal, choice_adv_num];
}

location wormwood_location(string goal, int turn) {
	if(turn >5) {
		turn = 9;
	} else if(turn >1) {
		turn = 5;
	} else 
		turn = 1;
	
	switch(goal) {
	case "not-a-pipe":
		switch(turn) {
		case 9:
			return $location[The Stately Pleasure Dome];
		case 5:
			return $location[The Mouldering Mansion];
		case 1:
			return $location[The Rogue Windmill];
		}
	case "flask of Amontillado":
		switch(turn) {
		case 9:
			return $location[The Rogue Windmill];
		case 5:
			return $location[The Stately Pleasure Dome];
		case 1:
			return $location[The Mouldering Mansion];
		}
	case "S.T.L.T.":
		switch(turn) {
		case 9:
			return $location[The Mouldering Mansion];
		case 5:
			return $location[The Rogue Windmill];
		case 1:
			return $location[The Stately Pleasure Dome];
		}
	case "fancy ball mask":
		switch(turn) {
		case 9:
			return $location[The Stately Pleasure Dome];
		case 5:
			return $location[The Rogue Windmill];
		case 1:
			return $location[The Mouldering Mansion];
		}
	case "albatross necklace":
		switch(turn) {
		case 9:
			return $location[The Rogue Windmill];
		case 5:
			return $location[The Mouldering Mansion];
		case 1:
			return $location[The Stately Pleasure Dome];
		}
	case "Can-Can skirt":
		switch(turn) {
		case 9:
			return $location[The Mouldering Mansion];
		case 5:
			return $location[The Stately Pleasure Dome];
		case 1:
			return $location[The Rogue Windmill];
		}
	case "Muscle":
		switch(turn) {
		case 9:
			return $location[The Stately Pleasure Dome];
		case 5:
			return $location[The Rogue Windmill];
		case 1:
			return $location[The Mouldering Mansion];
		}
	case "Moxie":
		switch(turn) {
		case 9:
			return $location[The Rogue Windmill];
		case 5:
			return $location[The Mouldering Mansion];
		case 1:
			return $location[The Stately Pleasure Dome];
		}
	case "Mysticality":
		switch(turn) {
		case 9:
			return $location[The Mouldering Mansion];
		case 5:
			return $location[The Stately Pleasure Dome];
		case 1:
			return $location[The Rogue Windmill];
		}
	}
	return $location[none];
}

string set_goal(string goal, string turns){
	goal = goal.to_lower_case();
	string fix_goal(){
		switch {
		case goal == "":
			print("No goal specified, assumed goal is not-a-pipe.");
		case contains_text(goal, "pipe"):
			return "not-a-pipe";
		case contains_text(goal, "flask"):
		case contains_text(goal, "amontillado"):
		case contains_text(goal, "booze"):
		case contains_text(goal, "drink"):
			return "flask of Amontillado";
		case contains_text(goal, "s.t.l"):
		case contains_text(goal, "stl"):
		case contains_text(goal, "s t l"):
		case contains_text(goal, "s. t. l"):
		case contains_text(goal, "food"):
		case contains_text(goal, "eat"):
			return "S.T.L.T.";
		case contains_text(goal, "mus"):
			return "Muscle";
		case contains_text(goal, "mox"):
			return "Moxie";
		case contains_text(goal, "mys"):
			return "Mysticality";
		case contains_text(goal, "fancy"):
		case contains_text(goal, "ball"):
		case contains_text(goal, "mask"):
		case contains_text(goal, "hat"):
			return "fancy ball mask";
		case contains_text(goal, "albat"):
		case contains_text(goal, "nec"):
		case contains_text(goal, "acc"):
			return "albatross necklace";
		case contains_text(goal, "can"):
		case contains_text(goal, "skirt"):
		case contains_text(goal, "pant"):
			return "Can-Can skirt";
		default:
			abort("Invalid goal!");
		}
		return "";
	}
	goal = fix_goal();
	if(turns == "") {
		if(goal == "Muscle" || goal == "Moxie" || goal == "Mysticality")
			print("Goal: "+ goal+ " 9-5-1.");
		else
			print("Goal: "+ goal+ ".");
	} else
		print("Goal: "+ goal+ " "+ turns+ ".");
	return goal;
}

string runWormChoice(string page_text, string goal) {
	while(contains_text(page_text, "choice.php")) {
		## Get choice adventure number
		int begin_choice_adv_num = (index_of(page_text, "whichchoice value=") + 18);
		int end_choice_adv_num = index_of(page_text, "><input", begin_choice_adv_num);
		string choice_adv_num = substring(page_text, begin_choice_adv_num, end_choice_adv_num);
		
		string choice_adv_prop = "choiceAdventure" + choice_adv_num;
		string choice_num = wormwood_choice(goal, choice_adv_num);
		page_text = visit_url("choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num);
	}
	return page_text;
}

boolean getWormChoiceAdv(int count, location l, string goal) {
	string last_adventure = "";
	int n=0;
	while(n < count && my_adventures() >0) {
		n = n + 1;
		last_adventure = visit_url(to_url(l));
		if(contains_text(last_adventure, "choice.php")){
			runWormChoice(last_adventure, goal);
			cli_execute("mood execute");
			return true;
		} else {
			run_combat();
		}
		# here, either combat is over, or you hit a noncombat
		# now, lets restore HP and MP, as well as maintaining our mood
		cli_execute("mood execute");
		restore_hp(0);
		restore_mp(0);
	}
	return false;
}

boolean do_wormwood() {
	string action_turns(string goal) {
		if(contains_text(goal, "1")) {
			if(contains_text(goal, "5")) {
				if(contains_text(goal, "9"))
					return "9-5-1";
				return "5-1";
			} else
				return "turn 1 only";
		}
		return "";
	}
	string wwgoal = get_property("wormwood");
	string turns = action_turns(wwgoal);
	wwgoal = set_goal(wwgoal, turns);
	
	int left=have_effect($effect[Absinthe-Minded]);
	boolean getWormChoiceAdv(int to_do) {
		return getWormChoiceAdv(to_do, wormwood_location(wwgoal, left), wwgoal);
	}

	switch(left) {
	case 9:
		print_html("To change this goal, use <font color=\"blue\"><b>set wormwood = xxx</b></font>, where xxx is a stat or item. (Optionally add 951, 51 or 1 for stats.)");
	case 8:
	case 7:
		if(turns == "5-1" || turns == "turn 1 only") {
			print("Doing "+ wwgoal+ " "+ turns+ ", so first step is skipped -- check again at 5.");
			return true;
		}
		print("Worm Wood first step...");
		return getWormChoiceAdv(left-6);
	case 5:
	case 4:
		if(turns == "turn 1 only") {
			print("Doing "+ wwgoal+ " "+ turns+ ", so this step is skipped -- check again at 1.");
			return true;
		}
		print("Worm Wood second step...");
		return getWormChoiceAdv(left-3);
	case 1:
		print("Worm Wood third step...");
		return getWormChoiceAdv(left);
	default:
		print("Something went wrong with the wormwood counter or script", "red");
	}
	return false;
}

// Handle the 0-turn lights out adventure. Make sure to reset original preferences
void advLightsOut(location hauntedLoc, string choice) {
	string originalValue = get_property("lightsOutAutomation");
	try {
		set_property("lightsOutAutomation", choice);
		(!adv1(hauntedLoc, 0, ""));
	} finally
		set_property("lightsOutAutomation", originalValue);
}

location nextLightsOut(boolean [string] rooms) {
	location nextRoom, failedRoom;
	foreach prop in rooms {
		nextRoom = get_property(prop).to_location();
		if(canadv(nextRoom))
			return nextRoom;
		else if(nextRoom != $location[none] && failedRoom == $location[none])
			failedRoom = nextRoom;
	}
	if(failedRoom != $location[none])
		print_html("<font color=\"blue\">It is time for a <u>Lights Out</u> adventure at <u>"+ failedRoom +"</u>, but that location is inaccessible.</font>");
	if(get_property("lightsOutAutomation") == "0")
		print_html("<font color=\"red\">Your <u>Lights Out</u> choice adventures are currently set to <u>show in browser</u>. It is recommended that you change that.</font>");
	return $location[none];
}

boolean lightsOut() {
	if(get_revision() < 14134) // This is the first revision number that automates Lights Out. Fail gracefully if user didn't upgrade mafia.
		abort("You need to update KoLmafia in order to automate \"Light's Out\" adventures in Spookyraven.");
	location hauntedLoc;
	
	// Check for order to complete quests. In case of ambiguous information, Stephen will be preferred since it makes sense to do him first.
	if(vars["BaleCC_LightsOutPreferred"].to_lower_case().contains_text("elizabeth") || vars["BaleCC_LightsOutPreferred"].to_lower_case().contains_text("ghost"))
		hauntedLoc = nextLightsOut($strings[nextSpookyravenElizabethRoom, nextSpookyravenStephenRoom]);
	else 
		hauntedLoc = nextLightsOut($strings[nextSpookyravenStephenRoom, nextSpookyravenElizabethRoom]);
	
	// Stop if it is the Boss fight and BaleCC_LightsOutFightAutomated is false.
	if(vars["BaleCC_LightsOutFightAutomated"] == "false" && ($locations[The Haunted Laboratory, The Haunted Gallery] contains hauntedLoc)) {
		visit_url(to_url(hauntedLoc));
		if(hauntedLoc == $location[The Haunted Laboratory]) {
			visit_url("choice.php?pwd&whichchoice=903&option=1");
			visit_url("choice.php?pwd&whichchoice=903&option=1");
			visit_url("choice.php?pwd&whichchoice=903&option=3");
			visit_url("choice.php?pwd&whichchoice=903&option=1");
			visit_url("choice.php?pwd&whichchoice=903&option=1");
		} else 
			visit_url("choice.php?pwd&whichchoice=896&option=4");
		# advLightsOut(hauntedLoc, "0");
		print_html("<font color=\"blue\">It is time to fight "
			+ (hauntedLoc == $location[The Haunted Laboratory]? "Stephen Spookyraven": "the ghost of Elizabeth Spookyraven") 
			+ " at <u>"+ hauntedLoc +"</u>.</font>");
		abort();
		return false;
	}
	if(hauntedLoc != $location[none])
		advLightsOut(hauntedLoc, "1");
	return true;
}

boolean counter_report(int remain, string output) {
	if(remain < 0) remain = -1;
	switch(remain) {
	case 0:
		print_html("<font color=\"blue\">It may be time to "+output+ ".</font>");
		return true;
	case -1:
		print_html("<font color=\"blue\">Time has expired for you to "+output+ ".</font>");
		return false;
	default:
		print_html("<font color=\"blue\">In "+ remain+ " turn"+(remain > 1? "s": "")+" it will be time to "+output+ ".</font>");
	}
	print("You'll need to kill some time until then since the current action requires more than 1 turn.", "red");
	return false;
}

boolean main(string name, int remain) {
	if($strings[priceCheck, manual] contains name) {
		print("It is in the: "+expensive_semi());
		return true;
	}
	print("Checking counters now.", "blue");

	if(remain != 0) {
		// would have to waste some turns before the semi-rare - abort and let the player decide where to do so
		switch(name) {
		case "Semirare window begin":
			counter_report(remain, " eat a fortune cookie");
			return to_boolean(vars["BaleCC_SemirareWindowContinue"]);
		case "Fortune Cookie":
			return counter_report(remain, "adventure somwhere for a <i>semi-rare</i>");
		case "Wormwood":
			return counter_report(remain, "adventure at <u>Wormwood</u> for "+get_property("wormwood"));
		case "Dance Card":
			if(remain < 0 && vars["BaleCC_useDanceCards"].to_boolean() && (can_interact() || item_amount($item[dance card])> 0))
				use(1, $item[dance card]);
			return counter_report(remain, "adventure at the <u>Haunted Ballroom</u> for a dance with <i>Rotting Matilda</i>");
		case "Spookyraven Lights Out":
			return counter_report(remain, "have a Lights Out adventure at Spookyraven Manor");
		default:
			return counter_report(remain, "do something when your <u>"+ name+ "</u> counter is up");
		}
	}

	if(name.length() >= 3 && name.substring(0, 3) == "cli") {
		// counters add <num> cli <command> - deferred execution!
		cli_execute(name.substring(3));
		return true;
	}

	switch(name) {
	case "Semirare window begin":
		print("Your semi-rare might happen any moment! You might want to eat a fortune cookie now. Or not?", "red");
		return to_boolean(vars["BaleCC_SemirareWindowContinue"]);
	case "Fortune Cookie":
		if(!can_interact() && vars["BaleCC_SrInHC"] != "true") {
			print("Semi-rares choices are not automated in hardcore or ronin.", "red");
			print_html("<font color=\"FF9900\">Your last semi-rare adventure was at <u>"+get_property("semirareLocation")+"</u>, so plan accordingly.</font>");
			return false;
		} else {
			get_semirare();
			return true;
		}
	case "Wormwood":
		return do_wormwood();
	case "Dance Card":
		(!adventure(1, $location[The Haunted Ballroom]));
		if(vars["BaleCC_useDanceCards"].to_boolean() && (can_interact() || item_amount($item[dance card])> 0))
			use(1, $item[dance card]);
		return true;
	case "Spookyraven Lights Out":
		return lightsOut();
	default:
		// not something we know how to handle
		counter_report(remain, "do something because your <u>"+ name+ "</u> counter is up");
		return false;
	}
	
}
