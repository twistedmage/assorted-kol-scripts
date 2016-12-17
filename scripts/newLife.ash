// Bale's PostAscensionScript: newLife
//      set postAscensionScript = newLife.ash

script "newLife.ash"
notify "Bale";
since r16944; // Track Enlightenment points for The Source
import "zlib.ash";

if(!($strings[None, Standard, Teetotaler, Boozetafarian, Oxygenarian, Bees Hate You, Way of the Surprising Fist, Trendy,
Avatar of Boris, Bugbear Invasion, Zombie Slayer, Class Act, Avatar of Jarlsberg, BIG!, KOLHS, Class Act II: A Class For Pigs, 
Avatar of Sneaky Pete, Slow and Steady, Heavy Rains, Picky, Actually Ed the Undying, One Crazy Random Summer, Community Service,
Avatar of West of Loathing, The Source, Nuclear Autumn] 
  contains my_path()) && user_confirm("Your current challenge path is unknown to this script!\nUnknown and unknowable errors may take place if it is run.\nDo you want to abort?")) {
	vprint("Your current path is unknown to this script! A new version of this script should be released very soon.", -1);
	exit;
}

// Often I get this script out before full mafia support. Hence these variable are used.
// It's no longer necessary for old paths however I may need it in the future.
stat primestat = my_primestat();
class myclass = my_class();
# if(my_path() == "17") {
	# primestat = $stat[moxie];
	# myclass = $class[Avatar of Sneaky Pete];
# }
boolean skipStatNCs = my_path() == "BIG!" || my_path() == "Class Act II: A Class For Pigs";

// This is a wrapper for be_good() that contains exceptions for this script's purpose.
// It will also contain new content that hasn't yet made it to zlib's be_good() function since I'm impatient to make a new release.
boolean good(string it) {
	switch(my_path()) {
	case "Avatar of Boris":
	case "Avatar of Jarlsberg":
	case "Avatar of Sneaky Pete":
		if(it == "familiar") return false;
		break;
	case "Actually Ed the Undying":
		if(it == "familiar"|| it == "Hippy Stone") return false;
		break;
	}
	return be_good(it);
}

boolean good(item it) {
	switch(my_path()) {
	case "Way of the Surprising Fist": // Don't autosell in Way of the Surprising Fist
		if($items[pork elf goodies sack, baconstone, hamethyst, porquoise, chewing gum on a string] contains it) return false;
		break;
	case "Avatar of Boris": // Boris needs no wussy stasis. Boris also needs to save meat for an antique instrument
		if($items[seal tooth, detuned radio] contains it) return false;
		break;
	case "Zombie Slayer":
		if(it == $item[seal tooth]) return false; // Zombie Masters don't have hermit access
		break;
	case "Actually Ed the Undying":  // Ed has no campground
		if(it == $item[Newbiesport&trade; tent]) return false;
		break;
	case "BIG!":
		if($items[detuned radio] contains it) return false; // Unnecessary expense
		break;
	case "Nuclear Autumn":
		if($items[chewing gum on a string] contains it) return false; 
		break;
	}
	return be_good(it);
}

boolean good(familiar f) {
	return be_good(f); 
}


void set_choice(string adventure, string choice, string purpose) {
	if(get_property(adventure) != choice) {
		if(purpose != "")
			vprint(purpose, "olive", 3);
		set_property(adventure, choice);
	}
}
void set_choice(string adventure, int choice, string purpose) {
	set_choice(adventure, to_string(choice), purpose);
}
void set_choice(int adventure, int choice, string purpose) {
	set_choice("choiceAdventure" + to_string(adventure), to_string(choice), purpose);
}

void set_choice_adventures() {
	// These choices are sometimes changed during an ascension, so make certain that they are changed back.
	// No need for comments on each line because the last parameter explains what each choice adventure does.
	set_choice(502, 2, "Spooky Forest: Get the mosquito");
	set_choice(505, 1, "");
	set_choice(507, 1, "");
	set_choice(112, 2, "Harold's Hammer is suboptimal");
	set_choice(4, 3, "No poultrygeist is needed");
	set_choice(25, 3, "Dungeon of Doom: Don't buy a mimic");
	set_choice(875, 1, "Billiards Room: Play Pool");
	set_choice(888, 4, "Library, Rise of the House of Spookyraven: Ignore");
	set_choice(889, 4, "Library, Fall of the House of Spookyraven: Ignore");
	set_choice(877, 1, "Bedroom, Mahogany Nightstand: old coin purse");
	if(in_hardcore() && my_path() == "Nuclear Autumn") // Cannot cook a wine bomb, so spectacles are useless
		set_choice(878, 3, "Bedroom, Ornate Nightstand: Get disposable instant camera");
	else
		set_choice(878, 4, "Bedroom, Ornate Nightstand: Get spectacles");
	if(my_path() == "Bees Hate You")
		set_choice(879, 3, "Bedroom, Rustic Nightstand: Fight Mistress for Antique Mirror");
	else if(primestat == $stat[Moxie] || my_path() == "The Source")
		set_choice(879, 1, "Bedroom, Rustic Nightstand: Get Moxie Stats");
	else
		set_choice(879, 2, "Bedroom, Rustic Nightstand: Get grouchy restless spirit");
	set_choice(880, 1, "Bedroom, Elegant Nightstand: Get Lady Spookyraven's finest gown");
	set_choice(106, 2, "Ballroom song: Non-combat");
	set_choice(89, 6, "Haunted Gallery: Ignore 'Out in the Garden'");
	set_choice("louvreDesiredGoal", 7, "Haunted Gallery: Get Lady Spookyraven's dancing shoes");
	set_choice("lightsOutAutomation", 1, "Lights Out at Spookyraven Manor: Free adventures FTW!");
	set_choice(451, 3, "Greater-than Sign: Get plus sign");
	set_choice(523, 4, "Defiled Cranny: Fight swarm of ghoul whelps");
	set_choice(22, 4, "Pirate's Cove: Complete the Outfit (eyepatch or pants)");
	set_choice(23, 4, "Pirate's Cove: Complete the Outfit (eyepatch or parrot)");
	set_choice(24, 4, "Pirate's Cove: Complete the Outfit (parrot or pants)");
	set_choice(556, 1, "Itznotyerzitz Mine: Complete the Outfit");
	set_choice(15, 4, "eXtreme Slope: Complete the Outfit (mittens or scarf)");
	set_choice(16, 4, "eXtreme Slope: Complete the Outfit (scarf or pants)");
	set_choice(17, 4, "eXtreme Slope: Complete the Outfit (mittens or pants)");
	#set_choice(575, 2, "eXtreme Slope, Duffel on the Double: Frostigkraut");
	set_choice(182, 4, "Fantasy Airship: Get the model airship");
	set_choice(134, 1, "Wheel in the Pyramid: Put wheel on spoke and turn it");
	set_choice(135, 1, "Wheel in the Pyramid: Turn Wheel");
	set_choice(139, 3, "Hippies on the Verge of War, Bait and Switch: Fight a cadet");
	set_choice(140, 3, "Hippies on the Verge of War, Thin Tie-Dyed Line: Fight a drill sergeant");
	set_choice(142, 3, "Hippies on the Verge of War, Blockin' Out the Scenery (Frat Boy Ensemble): Start the War!");
	set_choice(143, 3, "Frats on the Verge of War, Catching Some Zetas: Fight a pledge");
	set_choice(144, 3, "Frats on the Verge of War, One Less Room Than In That Movie: Fight a drill sergeant");
	set_choice(146, 3, "Frats on the Verge of War, Fratacombs (War Hippy Fatigues): Start the War!");
	set_choice(136, 4, "Hippy Camp: Complete the Outfit");
	set_choice(137, 4, "Hippy Camp: Complete the Outfit");
	set_choice(138, 4, "Frat House: Complete the Outfit");
	// Giant's Castle, there are a lot of items that can change optimality. Few are ALWAYS correct so reset others to manual
	set_choice(669, 0, "Furry Giant's Room: Manual");
	set_choice(670, 0, "Fitness Giant's Room: Manual");
	set_choice(671, 0, "Neckbeard Giant's Room: Manual");
	set_choice(672, 3, "Possibility Giant's Room: skip adventure");
	set_choice(673, 1, "Procrastination Giant's Room: very overdue library book");
	set_choice(674, 3, "Renaissance Giant's Room: skip adventure");
	set_choice(675, 0, "Goth Giant's Room: Manual");
	set_choice(676, 0, "Raver Giant's Room: Manual");
	set_choice(677, 0, "Steam Punk Giant's Room: Manual");
	set_choice(678, 0, "Punk Rock Giant's Room: Manual");
	if(my_path() == "Actually Ed the Undying")
		set_choice(679, 2, "Ed Spins That Wheel, Giants Get Real");
	else
		set_choice(679, 1, "Spin That Wheel, Giants Get Real");
	// Hidden City!
	set_choice(781, 1, "An Overgrown Shrine (Northwest)");
	set_choice(783, 1, "An Overgrown Shrine (Southwest)");
	set_choice(785, 1, "An Overgrown Shrine (Northeast)");
	set_choice(787, 1, "An Overgrown Shrine (Southeast)");
	// For NS'15
	if(my_path() == "Actually Ed the Undying") { // Ed Doesn't work the NS Tower
		set_choice(923, 1, "Black Forest, Head to the Blackberry patch");
		set_choice(924, 1, "Black Forest, Head to the Blackberry patch");
		set_choice(1026, 3, "Ed has no need for an electric boning knife");
	} else {
		set_choice(923, 1, "Black Forest, Head to the Blackberry patch");
		set_choice(924, 3, "Black Forest, Get beehive");
		set_choice(1018, 1, "Black Forest, Get beehive");
		set_choice(1019, 1, "Black Forest, Get beehive");
		set_choice(1026, 2, "Giant's Castle, Get electric boning knife");
	}
	if(be_good($item[munchies pill]))
		set_choice("violetFogGoal", 8, "Violet Fog is great place to get the munchies.");
	else
		set_choice("violetFogGoal", 0, "Violet Fog is too out of date to care about.");
	// Ghost Dog
	# set_choice(1106, 2, 'Ghost Dog says, "Wooof! Wooooooof!": Get buff'); // 1 is stats, 2 is buff, 3 is Ghost Dog food
	set_choice(1107, 1, "Play Fetch with your Ghost Dog: Get 1 tennis ball");
	set_choice(1108, my_ascensions() % 2 + 1, "Your Dog Found Something Again: Get food or booze"); // 1 is food, 2 is booze - Alternate
	
	// Path specific choices
	if(my_path() == "Way of the Surprising Fist")
		set_choice(297, 1, "Haiku Dungeon: Gaffle some mushrooms");
	else
		set_choice(297, 3, "Haiku Dungeon: Skip adventure to keep looking for the Bugbear Disguise");
	if(my_path() == "Way of the Surprising Fist" && in_hardcore()) {
		set_choice(153, 2, "Defiled Alcove: get meat");
		set_choice(155, 3, "Defiled Nook: get meat");
		set_choice(157, 2, "Defiled Niche: get meat");
	} else {
		set_choice(153, 4, "Defiled Alcove: skip adventure");
		set_choice(157, 4, "Defiled Niche: skip adventure");
		if(my_path() == "Zombie Slayer" && !have_familiar($familiar[Hovering Skull]) && storage_amount($item[talkative skull]) == 0)
			set_choice(155, 1, "Defiled Nook: get talkative skull familiar");
		else
			set_choice(155, 4, "Defiled Nook: skip adventure");
	}
	if($strings[Way of the Surprising Fist, Avatar of Boris] contains my_path()) {
		// Can't use the outfit, so get some meat
		set_choice(18, 3, "Itznotyerzitz Mine: Get some meat");
		set_choice(19, 3, "Itznotyerzitz Mine: Get some meat");
		set_choice(20, 3, "Itznotyerzitz Mine: Get some meat");
	} else {
		set_choice(18, 4, "Itznotyerzitz Mine: Complete the Outfit (mattock or pants)");
		set_choice(19, 4, "Itznotyerzitz Mine: Complete the Outfit (helmet or pants)");
		set_choice(20, 4, "Itznotyerzitz Mine: Complete the Outfit (helmet or mattock)");
	}
	// If this is a Bad Bee run and you go to McMillicancuddy's Farm, then this is optimal (no chaos Butterfly)
	if(my_path() == "Bees Hate You") {
		set_choice(147, 1, "McMillicancuddy's Farm: Granary");
		set_choice(148, 2, "McMillicancuddy's Farm: Family Plot");
		set_choice(149, 1, "McMillicancuddy's Farm: Shady Thicket");
	} else {
		set_choice(147, 3, "McMillicancuddy's Farm: Pond");
		set_choice(148, 1, "McMillicancuddy's Farm: Back 40");
		set_choice(149, 2, "McMillicancuddy's Farm: The Other Back 40");
	}
	// In BIG! There is no need for leveling up
	if(skipStatNCs) {
		set_choice("oceanDestination", "ignore", "At the Poop Deck: Skip the wheel");
	} else {
		set_choice("oceanDestination", to_lower_case(primestat), "At the Poop Deck: take the Wheel and Sail to "+primestat+" stats");
	}
	
	// Prime Stat specific choices
	vprint("Setting choice adventures for "+ primestat +" class.", 3);
	switch(primestat) {
	case $stat[muscle]:
		set_choice(73, 1, "Whitey's Grove: Get Muscle stats");
		set_choice(74, 2, "Whitey's Grove: Get boxes of wine");
		set_choice(75, 2, "Whitey's Grove: Get white lightning");
		set_choice(90, 3, "Ballroom Curtains: skip adventure");
		set_choice(184, 1, "That Explains all the Eyepatches in Barrrney's Barrr: fight a pirate");
		set_choice(186, 1, "A Test of Testarrrsterone in Barrrney's Barrr: get stats");
		set_choice(191, 3, "F'c'le, Chatterboxing: get Muscle stats");
		set_choice(402, 1, "Bathroom, Don't Hold a Grudge: Get Muscle stats");
		set_choice(141, 2, "Hippies on the Verge of War, Blockin' Out the Scenery: Get rations");
		set_choice(145, 1, "Frats on the Verge of War, Fratacombs: Get Muscle stats");
		set_choice(793, 1, "Take Muscle vacation.");
		set_choice(876, 2, "Bedroom, White Nightstand: Get Muscle stats");
		if(my_path() == "The Source")
			set_choice(153, 1, "Defiled Alcove: Desperately need mainstat when fighting the Source");
		break;
	case $stat[mysticality]:
		set_choice(73, 3, "Whitey's Grove: Get wedding cake and rice");
		set_choice(74, 2, "Whitey's Grove: Get boxes of wine");
		set_choice(75, 1, "Whitey's Grove: Get Mysticality stats");
		set_choice(90, 3, "Ballroom Curtains: skip adventure");
		set_choice(184, 2, "That Explains all the Eyepatches in Barrrney's Barrr: shot of rotgut");
		set_choice(186, 1, "A Test of Testarrrsterone in Barrrney's Barrr: get stats");
		set_choice(191, 4, "F'c'le, Chatterboxing: get Mysticality stats");
		set_choice(402, 2, "Bathroom, Don't Hold a Grudge: Get Mysticality stats");
		set_choice(141, 1, "Hippies on the Verge of War, Blockin' Out the Scenery: Get Mysticality stats");
		set_choice(145, 2, "Frats on the Verge of War, Fratacombs: Get food");
		set_choice(793, 2, "Take Mysticality vacation.");
		if(my_path() == "The Source") {
			set_choice(157, 1, "Defiled Niche: Desperately need mainstat when fighting the Source");
			set_choice(876, 2, "Bedroom, White Nightstand: Get Muscle stats");
		} else
			set_choice(876, 1, "Bedroom, White Nightstand: old leather wallet");
		break;
	case $stat[moxie]:
		set_choice(73, 3, "Whitey's Grove: Get wedding cake and rice");
		set_choice(74, 1, "Whitey's Grove: Get Moxie stats");
		set_choice(75, 2, "Whitey's Grove: Get white lightning");
		if(skipStatNCs)  // No need to level up in BIG!
			set_choice(90, 3, "Ballroom Curtains: skip adventure");
		else
			set_choice(90, 2, "Ballroom Curtains: get Moxie stats");
		set_choice(184, 1, "That Explains all the Eyepatches in Barrrney's Barrr: fight a pirate");
		set_choice(186, 3, "A Test of Testarrrsterone in Barrrney's Barrr: get lots of Moxie"); 
		set_choice(191, 1, "F'c'le, Chatterboxing: get Moxie stats");
		set_choice(402, 3, "Bathroom, Don't Hold a Grudge: Get Moxie stats");
		set_choice(141, 2, "Hippies on the Verge of War, Blockin' Out the Scenery: Get rations");
		set_choice(145, 2, "Frats on the Verge of War, Fratacombs: Get food");
		set_choice(793, 3, "Take Moxie vacation.");
		if(my_path() == "The Source") {
			set_choice(876, 2, "Bedroom, White Nightstand: Get Muscle stats");
			set_choice(155, 1, "Defiled Nook: Desperately need mainstat when fighting the Source");
		} else
		set_choice(876, 1, "Bedroom, White Nightstand: old leather wallet");
		break;
	}
	if(vars["newLife_SetupGuyMadeOfBees"].to_boolean())
		set_choice(105, 3, "Bathroom, Having a Medicine Ball: Say, \"Guy made of Bees.\"");
	else if(primestat == $stat[mysticality] && !skipStatNCs)
		set_choice(105, 1, "Bathroom, Having a Medicine Ball: Get Mysticality stats");
	else {
		set_choice(105, 2, "Bathroom, Having a Medicine Ball: Skip adventure");
		set_choice(107, 4, "");
	}
	
	// Set up for Dis in a Jif. Feature Creep?
	// This way I can change them later to get a specific buff without worry about completing the quest next ascension.
	set_choice(560, 1, "Clumsiness Grove, Prepare for Fighting");
	set_choice(561, 1, "Clumsiness Grove, The Thorax");
	set_choice(563, 1, "Clumsiness Grove, Prepare for Fighting");
	set_choice(564, 1, "Maelstrom of Lovers, Prepare for Fighting");
	set_choice(565, 1, "Maelstrom of Lovers, The Terrible Pinch");
	set_choice(566, 1, "Maelstrom of Lovers, Prepare for Fighting");
	set_choice(567, 1, "Glacier of Jerks, Prepare for Fighting");
	set_choice(568, 1, "Glacier of Jerks, Mammon the Elephant");
	set_choice(569, 1, "Glacier of Jerks, Prepare for Fighting");
	
	vprint("Optimal ascension choices set.", "blue", 3);
}

void campground(boolean softBoo) {
	// Break the hippy stone?
	if(vars["newLife_SmashHippyStone"] == "true" && !hippy_stone_broken() && good("Hippy Stone")) {
		vprint("Smashing that hippy-dippy crap so you can have some violent fun!", "olive", 3);
		string pvp = visit_url("peevpee.php?confirm=on&action=smashstone&pwd");
		if(pvp.contains_text("Pledge allegiance to"))
			visit_url("peevpee.php?action=pledge&place=fight&pwd");
	}
	
	if(get_dwelling() != $item[big rock])
		return;  // If dwelling is something other than a big rock, we're done here.
	boolean tent = available_amount($item[Newbiesport&trade; tent]) > 0 && good($item[Newbiesport&trade; tent])
	  && vars["newLife_UseNewbieTent"].to_boolean();
	// If the player is in Hardcore Nation it is time to send a "Please brick me" announcement!
	// I only announce it if I am ascending hardcore. Silly, but that's me.
	if( (in_hardcore() || !softBoo) && (tent || my_turncount() < 1) && get_clan_id() == 41543) {  // 41543 is the ID for HCN
		chat_clan(now_to_string("MM/dd/yyyy hh:mm aaa") + " - Welcome Back to the Kingdom of Loathing. Noob.");
		// Pause for a suitable bricking window.
		if(tent) {
			vprint("Pausing to give all enemies... Um, I mean clannies a fair chance for bricking!", "olive", 3);
			wait(gametime_to_int() > 84600000? 30: 180);  // Only 30 seconds if close to rollover.
		}
	}
	// Put up the tent.
	if(tent) use(1, $item[Newbiesport&trade; tent]);
}

void get_bugged_balaclava() {
	if(have_familiar($familiar[Baby Bugged Bugbear]) && good(($familiar[Baby Bugged Bugbear])) && good($item[bugged beanie])
	  && good($item[bugged balaclava]) && familiar_equipped_equipment($familiar[Baby Bugged Bugbear]) == $item[none]) {
		vprint("Getting your baby buggy bugbear balaclavaed.", "olive", 3);
		familiar fam = my_familiar();
		use_familiar($familiar[Baby Bugged Bugbear]);
		if(available_amount($item[bugged balaclava]) < 1) {
			if(available_amount($item[bugged beanie]) < 1)
				visit_url("arena.php");
			use(1,$item[bugged beanie]);
		}
		equip($item[bugged balaclava]);
		use_familiar(fam);
	}
}

void buy_stuff() {
	boolean need_accordion() {
		if(my_path() == "Avatar of West of Loathing") // Cowboys don't need accordions
			return false;
		// ATs come with a stolen accordion and ability to steal more
		if(myclass != $class[Accordion Thief] && item_amount($item[toy accordion]) == 0 && available_amount($item[antique accordion]) == 0 && good($item[toy accordion]))
			foreach s in $skills[]
				if(have_skill(s) && s.class == $class[Accordion Thief] && s.buff == true && s.dailylimit < 0)
					return true; 	// Only need an accordion if the character can cast a AT skill (Unlimited skills only!)
		return false;
	}

	boolean meat4pork(item it) {
		// In case you want to use Thor's Pliers to smith Black Gold with a pork gem, preseve one the best for your class. Organize list to cause that.
		boolean [item] gem_list() {
			if(primestat == $stat[muscle]) return $items[hamethyst, porquoise, baconstone];
			if(primestat == $stat[moxie])  return $items[baconstone, hamethyst, porquoise];
			return $items[baconstone, porquoise, hamethyst]; // This is Myst
		}
		
		if(my_meat() < npc_price(it)) {
			item [int] pork;
			foreach gem in gem_list()
				if(item_amount(gem) > 0) pork [count(pork)] = gem;
			if(count(pork) == 0) return false;
			sort pork by - item_amount(value);
			autosell(1, pork[0]);  // Sell the gem with the greatest quantity
		}
		return my_meat() >= npc_price(it);
	}
	
	string trade_pork4item(item it) {
		if(available_amount(it) == 0) {
			if(meat4pork(it) && retrieve_item(1, it))
				return to_string(it);
			vprint("Failed to acquire a " + it, -3);
		}
		return "";
	}
	
	boolean worthless() {
		for i from 43 to 45
			if(available_amount(i.to_item()) > 0) return true;
		return false;
	}
	
	// a is the new string, cat is the contatenated final string
	string and_string(string a, string cat) {
		if(cat == "")
			return a;
		if(a == "")
			return cat;
		if(cat.contains_text(" and a "))
			return a + ", "+ cat;
		return a + " and a "+ cat;
	}

	string garner;
	
	// Don't get the toy accordion if I have a Deck of Every Card because I'll probably prefer to sell a Mickey Mantle card and buy an antique accordion.
	if(need_accordion() && !(available_amount($item[Deck of Every Card]) > 0 && be_good($item[Deck of Every Card])))
		garner = trade_pork4item($item[toy accordion]);
		
	if(knoll_available() && good($item[detuned radio]))
		garner = trade_pork4item($item[detuned radio]).and_string(garner);
	
	// Need miniature life preserver in Heavy Rains
	if(my_path() == "Heavy Rains")
		garner = trade_pork4item($item[miniature life preserver]).and_string(garner);
	
	// For disco bandits, Suckerpunch is better than seal tooth
	if(myclass != $class[Disco Bandit] && item_amount($item[seal tooth]) == 0 && good($item[seal tooth]) && good($item[chewing gum on a string])) {
		while(!worthless() && meat4pork($item[chewing gum on a string]))
			use(1, $item[chewing gum on a string]);
		if(worthless() && (available_amount($item[hermit permit]) > 0 || meat4pork($item[hermit permit]))) {
			hermit(1, $item[seal tooth]);
			garner = "seal tooth".and_string(garner);
		}
	}

	if(garner != "")
		vprint("Pork Elf stones were sold to garner a "+garner+".", "blue", 3);
}

void get_stuff() {
	get_bugged_balaclava();
	if(vars["newLife_SellPorkForStuff"].to_boolean()) {
		if(item_amount($item[pork elf goodies sack]) > 0 && good($item[pork elf goodies sack]))
			use(1, $item[pork elf goodies sack]);
		if(item_amount($item[baconstone]) + item_amount($item[hamethyst]) + item_amount($item[porquoise]) + my_meat() > 0)
			buy_stuff();
	}
	// Get your cowboy boots from the LT&T Office
	if(get_property("telegraphOfficeAvailable") ==  "true") {
		visit_url("place.php?whichplace=town_right&action=townright_ltt");
		run_choice(8);
	}
	// Clan Floundry -- get the fishin' pole. I hate the server hit, but I don't have another option yet
	if(available_amount($item[Clan VIP Lounge key]) > 0 && visit_url("clan_viplounge.php").contains_text("vipfloundry.gif"))
		visit_url("clan_viplounge.php?action=floundry");
	// 11th Precinct
	if(get_property("hasDetectiveSchool") == "true")
		visit_url("place.php?whichplace=town_wrong&action=townwrong_precinct");
}

// Visit Mt. Noob to get pork gems.
void visit_toot() {
	vprint("The Oriole welcomes you back at Mt. Noob.", "olive", 3);
	visit_url("tutorial.php?action=toot&pwd");
	item letter = $item[letter from King Ralph XI];
	if(my_path() == "Actually Ed the Undying")
		letter = $item[letter to Ed the Undying];
	if(item_amount(letter) > 0 && good(letter))
		use(1, letter);
}

boolean use_shield() {
	if(my_path() == "Zombie Slayer" && available_amount($item[left bear arm]) > 0) return false;
	foreach i in get_inventory()
		if(item_type(i) == "shield" && can_equip(i) && good(i)) return true;
	if(item_type(equipped_item($slot[off-hand])) == "shield") return true;
	return false;
}

familiar start_familiar() {
	familiar f100 = vars["is_100_run"].to_familiar();	// Is this a 100% familiar run?
	// If player has used BCCAscend, normalize familiar settings with "is_100_run"
	if(get_property("bcasc_lastCouncilVisit") != "") {
		if(f100 == $familiar[none]) {
			set_property("bcasc_100familiar", ""); 
		} else {
			set_property("bcasc_100familiar", f100); 
			set_property("bcasc_defaultFamiliar", f100); 
		}
	}
	if(f100 != $familiar[none]) return f100;
	
	if(my_path() == "Zombie Slayer" && have_familiar($familiar[Hovering Skull]))
		return $familiar[Hovering Skull];
	
	foreach f in $familiars[He-Boulder, Frumious Bandersnatch, Baby Bugged Bugbear, Grim Brother, Bloovian Groose, Gluttonous Green Ghost, 
	  Spirit Hobo, Fancypants Scarecrow, Ancient Yuletide Troll, Cheshire Bat, Cymbal-Playing Monkey, Nervous Tick, 
	  Hunchbacked Minion, Uniclops, Chauvinist Pig, Dramatic Hedgehog, Blood-Faced Volleyball, Reagnimated Gnome, 
	  Jill-O-Lantern, Hovering Sombrero]
		if(have_familiar(f) && good(f)) return f;
	
	return $familiar[none];
}

void equip_stuff() {
	buffer gear;
	gear.append("0.2 mainstat, 0.2 hp, 0.2 dr, 0.1 spell damage, +effective 4 ");
	gear.append(primestat);
	gear.append(" experience");
	if(my_path() != "Zombie Slayer")
		gear.append(", mp regen");
	if(good("familiar"))
		gear.append(", 0.2 familiar weight");
	if(available_amount($item[sugar shield]) > 0)
		gear.append(" -equip sugar shield");
	
	// Unarmed combat or require shield?
	if(!have_skill($skill[Summon Smithsness]) && have_skill($skill[Master of the Surprising Fist]) && have_skill($skill[Kung Fu Hustler]) && available_amount($item[Operation Patriot Shield]) < 1)
		gear.append(" -weapon -offhand");  // Barehanded can be BEST at level 1!
	else if(use_shield())
		gear.append(" +shield");
	
	// Things to equip or not equip for specific path
	switch(my_path()) {
	case "Bees Hate You":
		gear.append(", 0 beeosity");
		break;
	case "KOLHS":
		gear.append(" -hat");
		break;
	case "Heavy Rains":
		if(available_amount($item[miniature life preserver]) > 0) {
			equip($item[miniature life preserver]);
			lock_familiar_equipment(true);
			gear.append(" -familiar");
		}
		break;
	case "One Crazy Random Summer":
		gear.append(", 5 Random Monster Modifiers");
		break;
	}
	maximize(gear, false);
}

void handle_starting_items() {
	// Free pulls
	if(good($item[brick]))
		retrieve_item(available_amount($item[brick]), $item[brick]);

	// Unpack astral consumables
	foreach it in $items[astral hot dog dinner, astral six-pack, carton of astral energy drinks, box of bear arms]
		if(item_amount(it) > 0 && good(it)) use(item_amount(it), it);
	
	// In AWoL, holster your toy sixgun or, if you're casual about it, Pecos Dave's sixgun.
	item best_gun() {
		foreach gun in $items[Pecos Dave's sixgun, porquoise-handled sixgun, hamethyst-handled sixgun, baconstone-handled sixgun, custom sixgun, makeshift sixgun, reliable sixgun, rinky-dink sixgun, toy sixgun]
			if(available_amount(gun) > 0) return gun;
		return $item[none];
	}
	if(my_path() == "Avatar of West of Loathing")
		equip($slot[holster], best_gun());
		
	// Put on the best stuff you've got.
	vprint("Put on your best gear.", "olive", 3);
	// First equip best familiar!
	familiar fam = (vars contains "is_100_run")? to_familiar(vars["is_100_run"]): my_familiar();
	if(fam == $familiar[none] || !good(fam) || !have_familiar(fam))
		fam = start_familiar();
	use_familiar(fam);
}

// Optimal restoration settings for level 1. These will need to be changed by level 4
void recovery_settings() {
	// Ed needs no wussy healing
	if(my_path() == "Actually Ed the Undying") {
		set_choice("hpAutoRecovery", "-0.05", "Don't bother with healing");
		set_choice("hpAutoRecoveryTarget", "-0.05", "");
	} else {
		set_choice("hpAutoRecovery", "0.30", "Resetting HP/MP restoration settings to minimal");
		set_choice("hpAutoRecoveryTarget", "0.95", "");
	}
	
	// Zombie Slayers have an alternative to using mana
	if(my_path() == "Zombie Slayer") {
		if(get_property("baleUr_ZombieAuto") != "")
			set_property("baleUr_ZombieAuto", "-0.05");
		if(get_property("baleUr_ZombieTarget") != "")
			set_property("baleUr_ZombieTarget", 1);
		// Turn off mana restoration in combat. It causes problems in zombiecore
		set_property("autoManaRestore", "false");
	} else {
		set_choice("mpAutoRecovery", "0.0", "");
		set_choice("mpAutoRecoveryTarget", "0.0", "");
	}
	
	set_choice("manaBurningTrigger", "-0.05", "");
	set_choice("manaBurningThreshold", "0.80", "");
}

// If you are completely full of Boris or Braaaaains, this will get all the skills
void path_skills(boolean always_learn) {
	switch(my_path()) {
	case "Avatar of Boris":
		// Thanks to Weatherboy: http://kolmafia.us/showthread.php?10000-Multi-training-Boris-Skills
		matcher borisskills = create_matcher("learn (\\d+) more", visit_url("da.php?place=gate1"));
		if(borisskills.find() && to_int(borisskills.group(1)) > 29) {
			for t from 1 to 3
				for i from 1 to 10
					visit_url("da.php?whichtree="+t+"&action=borisskill");
			vprint("You are filled with all of Boris' skills and are ready to use them.", "blue", 3);
		}
		break;
	case "Zombie Slayer":
		matcher zombieskills = create_matcher("You have (\\d+) zombie point", visit_url("campground.php?action=grave"));
		int points;
		if(zombieskills.find())
			points = to_int(zombieskills.group(1));
		// Unless always_learn is set, only study if ALL skills can be learned
		if(points > 29 || (always_learn && points > 0)) {
			// Always learn Hunger first for Neurogourmet & Ravenous Pounce, then Master, then Anger.
			foreach t in $strings[Hunger, Master, Anger] {
				if(points > 0) {
					vprint("Studying the Zombie "+t+" skills.", "blue", 3);
					for i from 1 to min(points, 10)
						visit_url("campground.php?pwd&whichtree="+t+"&preaction=zombieskill");
				}
				points -= 10; // I honestly don't care if it goes negative
			}
			vprint("You are filled with Zobmie Master skills and hunger to use them.", "blue", 3);
		}
		break;
	case "Avatar of Jarlsberg":
		matcher jarlskills = create_matcher("have (\\d+) skill points", visit_url("da.php?place=gate2"));
		if(jarlskills.find() && jarlskills.group(1).to_int() > 31) {
			foreach sk in $skills[Boil, Conjure Eggs, Conjure Dough, Fry, Coffeesphere, Egg Man, Early Riser, The Most Important Meal,
			  Conjure Vegetables, Chop, Slice, Lunch Like a King, Oilsphere, Radish Horse, Conjure Cheese, Working Lunch,
			  Bake, Conjure Potato, Conjure Meat Product, Grill, Gristlesphere, Food Coma, Hippotatomous, Never Late for Dinner,
			  Conjure Fruit, Freeze, Conjure Cream, Cream Puff, Chocolatesphere, Best Served Cold, Nightcap, Blend]
				visit_url("jarlskills.php?action=getskill&getskid="+to_int(sk));
			vprint("You are filled with all of Jarlsberg's skills, now get cooking!", "blue", 3);
		}
		break;
	case "Avatar of Sneaky Pete":
		matcher peteskills = create_matcher("<b>(\\d+)</b> skill points available", visit_url("da.php?place=gate3"));
		if(peteskills.find() && peteskills.group(1).to_int() > 29) {
			visit_url("choice.php?whichchoice=867&pwd&option=4"); // All 10 Loveable Rogue
			visit_url("choice.php?whichchoice=867&pwd&option=5"); // All 10 Motorcycle Guy
			visit_url("choice.php?whichchoice=867&pwd&option=6"); // All 10 Dangerous Rebel
			vprint("You are filled with all of Sneaky Pete's skills, so hit the St.", "blue", 3);
		}
		break;
	case "Actually Ed the Undying":
		matcher edskills = create_matcher("You may memorize (\\d+) more pages", visit_url("place.php?whichplace=edbase&action=edbase_book"));
		if(edskills.find() && edskills.group(1).to_int() > 20) {
			for skillid from 0 to 20
				visit_url("choice.php?whichchoice=1051&option=1&pwd&skillid=" + skillid);
			vprint("Go forth and wreck just Vengeance upon "+my_name()+" with all your Skills, thus sayeth the Book of the Undying.", "blue", 3);
		}
		break;
	case "Avatar of West of Loathing":
		// If you have 10 skill points in a given book, learn all skills in that book
		foreach book in $items[Tales of the West: Cow Punching, Tales of the West: Beanslinging, Tales of the West: Snake Oiling] {
			string prop;
			class awol = to_class(to_int(book) - 8937); // The three skill books and the classes they teach are in the same order
			if(awol == $class[Cow Puncher]) prop = "awolPointsCowpuncher";
			else if(awol == $class[Beanslinger]) prop = "awolPointsBeanslinger";
			else prop = "awolPointsSnakeoiler";
			int points = to_int(get_property(prop));
			if(my_class() == awol)
				points = min(max(points, 1) + my_level(), 10);
			if(points >= 10) {
				visit_url('inv_use.php?pwd&which=3&whichitem=' + to_int(book));
				for sk from 0 to 9
					visit_url("choice.php?whichchoice=" + to_string(to_int(awol) + 1159) + "&option=1&pwd&whichskill=" + sk);
			}
		}
		break;
	case "The Source":
		if(get_property("sourceEnlightenment").to_int() > 10) {
			visit_url("place.php?whichplace=manor1&action=manor1_sourcephone_ring");
			for x from 1 to 11
				visit_url("choice.php?whichchoice=1188&option=1&pwd&skid=" + x);
		}
		break;
	// This isn't exactly learning new skills, but it is relevant and convenient to put it here.
	case "Nuclear Autumn":
		int shelter = to_int(get_property("falloutShelterLevel"));
		if(shelter >= 5 && get_property("falloutShelterChronoUsed") == "false") {
			print("Visiting your fallout shelter's Chronodynamics Laboratory.", "blue");
			visit_url("place.php?whichplace=falloutshelter&action=vault5");
		}
		if(shelter >= 8 && get_property("falloutShelterCoolingTankUsed") == "false") {
			print("Visiting your fallout shelter's Main Reactor.", "blue");
			visit_url("place.php?whichplace=falloutshelter&action=vault8");
		}
		break;
	}
}

// If you've got a Shrine to the Barrel God, get free stuff from the barrel.
void free_barrels() {
	if(!in_bad_moon() && get_property("barrelShrineUnlocked") == "true") {
		print("Seek free stuff from the Barrel full of Barrels since you have the Barrel god's blessing.", "blue");
		matcher barrel = create_matcher('<div class="ex"><a class="spot" href="([^"]+)"><img title="A barrel"', visit_url("barrel.php"));
		while(barrel.find())
			visit_url(barrel.group(1));
	}
}

// This is stuff I like to do, but not everyone will be happy with.
void special(boolean bonus_actions) {
	if(!bonus_actions) return;
	boolean pull_it(item it) {
		if(!good(it)) return false;
		if(item_amount(it) + equipped_amount(it) > 0)
			return true;
		if(storage_amount(it) < 1 || pulls_remaining() < 1)
			return false;
		take_storage(1, it);
		return true;
	}
	vprint("Now for a few things that "+my_name()+" wants to do.", "blue", 3);
	if(available_amount($item[detuned radio]) > 0 || canadia_available() || (gnomads_available() && my_path() == "Actually Ed the Undying"))
		change_mcd(10 + canadia_available().to_int());
	
	// transmission from planet Xi -> Xiblaxian holo-wrist-puter simcode -> Xiblaxian holo-wrist-puter
	if(available_amount($item[Xiblaxian holo-wrist-puter]) == 0 && good($item[Xiblaxian holo-wrist-puter]))
		foreach it in $items[transmission from planet Xi, Xiblaxian holo-wrist-puter simcode]
			if(available_amount(it) > 0 && good(it))
				use(1, it);
	
	// In softcore I want to pull stuff
	if(!in_hardcore() && my_path() != "Community Service") {
		if(my_path() == "BIG!") {  // Most pulls involve leveling up, so BIG is very different!
			if(!knoll_available() && pull_it($item[Loathing Legion knife]))
				cli_execute("fold Loathing Legion universal screwdriver");
		} else {
			if(my_path() != "KOLHS, Class Act II: A Class For Pigs" && pull_it($item[Loathing Legion knife]))
				cli_execute("fold Loathing Legion necktie");
			if(pull_it($item[Juju Mojo Mask])) equip($slot[acc2],$item[Juju Mojo Mask]);
			
			// Pull Pants!
			(pull_it($item[Greatest American Pants]) || pull_it($item[Pantsgiving]));
			
			boolean bearArms = my_path() == "Zombie Slayer" && (available_amount($item[right bear arm]) > 0 && available_amount($item[left bear arm]) > 0 || available_amount($item[box of bear arms]) > 0);
			
			// Offhand: Use Jarlsberg's Pan if mainstat is Myst. For other mainstat or no Pan, use OPS
			if(!(have_skill($skill[Summon Smithsness]) || bearArms))
				if(primestat != $stat[mysticality] || !(pull_it($item[Jarlsberg's pan]) || pull_it($item[Jarlsberg's pan (Cosmic portal mode)])))
					pull_it($item[Operation Patriot Shield]);
			
			// Get a weapon, only if none is in inventory already and you don't have Smithsness
			if(!(have_skill($skill[Summon Smithsness]) || bearArms) && primestat != $stat[Moxie] && item_amount($item[astral mace]) + item_amount($item[astral bludgeon]) + item_amount($item[right bear arm]) < 1)
				(pull_it($item[Thor's Pliers]) || pull_it($item[ice sickle]));
			
			// Shirt
			if(have_skill($skill[Torso Awaregness]) && available_amount($item[astral shirt]) < 1)
				(pull_it($item[Sneaky Pete's leather jacket]) || pull_it($item[Sneaky Pete's leather jacket (collar popped)]) || pull_it($item[cane-mail shirt]));
			
			// Back
			if(available_amount($item[protonic accelerator pack]) == 0 || !good($item[protonic accelerator pack])) // New guear never needs to be pulled anymore!
				if(!have_familiar($familiar[El Vibrato Megadrone]) && good($familiar[El Vibrato Megadrone]) && pull_it($item[Buddy Bjorn]))
					cli_execute("bjornify El Vibrato Megadrone");
			
			// Best Hat? Jarlsberg comes with all the hat he needs and some other paths auto-pull their Path Hat
			if(my_path() != "Avatar of Jarlsberg" && available_amount($item[The Crown of Ed the Undying]) < 1 && available_amount($item[Boris's Helm]) < 1 && available_amount($item[Boris's Helm (askew)]) < 1) {
				if(available_amount($item[Buddy Bjorn]) < 1 && have_familiar($familiar[El Vibrato Megadrone]) && good($familiar[El Vibrato Megadrone]) && pull_it($item[Crown of Thrones]))
					cli_execute("enthrone El Vibrato Megadrone");
				else if(pull_it($item[Boris's Helm]))
					cli_execute("fold Boris's Helm (askew)");
				else if(!pull_it($item[Boris's Helm (askew)]))
					pull_it($item[The Crown of Ed the Undying]);
			}
		}
		
		// Select best familiar item if familiars can be used
		if(good("familiar") && available_amount($item[astral pet sweater]) < 1 && my_path() != "Heavy Rains")
			(pull_it($item[moveable feast]) || pull_it($item[snow suit]) || pull_it($item[little box of fireworks]) || pull_it($item[plastic pumpkin bucket]));
		
		// Ultimate Combat Item
		if(available_amount($item[empty Rain-Doh can]) == 0 && pull_it($item[can of Rain-Doh]))
			use(1, $item[can of Rain-Doh]);
	}
	
	cli_execute("mood default");
}

void check_breakfast() {
	if(get_property("breakfastCompleted") == "true") return;
	vprint("Time for breakfast.", "blue", 3);
	cli_execute("breakfast");
	string loginScript = get_property("loginScript");
	if(loginScript != "")
		cli_execute(loginScript);
}

void new_ascension() {
	boolean extra_stuff = vars["newLife_Extras"].to_boolean();  // Do extra stuff if this is true
	set_choice_adventures();
	campground(extra_stuff);
	visit_toot();
	get_stuff();
	if(my_turncount() < 1) {
		recovery_settings();
		path_skills(extra_stuff);	// Always learn skills if true
		handle_starting_items();
		free_barrels();
		special(extra_stuff);		// Only executes if true
		equip_stuff();
	}
	check_breakfast();
	cli_execute("outfit save Backup");  // Accidently equiping Backup after ascending cases error. No more oops.
	vprint("Welcome to your new life as a "+myclass+"!", "green", 3);
}

// These are default values here. To change for each character, edit their vars file in /data direcory or use the zlib commands.
setvar("newLife_SetupGuyMadeOfBees", FALSE); // If you like to set up the guy made of bees set this TRUE. 
setvar("newLife_SmashHippyStone", FALSE);	// Smash stone if you want to break it at level 1 for some PvPing!
setvar("newLife_UseNewbieTent", TRUE);		// Use newbie tent if you don't want togive your clannes a fair shot at bricking you in the face!
setvar("newLife_SellPorkForStuff", TRUE);	// Sell pork gems to purchase detuned radio, toy accordion & seal tooth
setvar("newLife_Extras", FALSE); 			// Mixed bag of custom actions. This is personal to me, but maybe someone else will like it also

void main() {
	new_ascension();
}
