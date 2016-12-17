// Bale's PostAscensionScript: newLife
//      set postAscensionScript = newLife.ash

script "newLife.ash"
notify "Bale";
since r16944; // Track Enlightenment points for The Source
import "zlib.ash";



void knife_untinker(item it)
{
	if(item_amount($item[loathing legion universal screwdriver])<1)
		abort("Can't untinker without legion screwdriver");
	//use knife
	string catch = visit_url("inv_use.php?which=3&whichitem=&pwd="+my_hash(),false,true);
	//unscrew item
	catch = visit_url("inv_use.php?whichitem=4926&action=screw&dowhichitem="+to_int(it)+"&untinker=Unscrew%21&pwd="+my_hash(),false,true);
}


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
	//TEMPORARY TO FIX MAFIA FAIL
	case "Standard":
		if(it==$item[Meat Tenderizer is Murder]) return false;
		if(contains_text(it,"psychoses") )return false;
		if(contains_text(it,"loathing legion") )return false;		
	}
	return is_unrestricted(it) && be_good(it);
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
	if(my_path() == "Nuclear Autumn") // Cannot cook a wine bomb, so spectacles are useless
		set_choice(878, 4, "Bedroom, Ornate Nightstand: Get disposable instant camera");
	else
		set_choice(878, 3, "Bedroom, Ornate Nightstand: Get spectacles");
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
	set_choice(106, 2, "Ballroom song: Non-combat");
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
	set_choice(673, 3, "Procrastination Giant's Room: skip adventure");
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
	// Ghost Dog - SIMON: handled in ascend script
	# set_choice(1106, 2, 'Ghost Dog says, "Wooof! Wooooooof!": Get buff'); // 1 is stats, 2 is buff, 3 is Ghost Dog food
	# set_choice(1107, 1, "Play Fetch with your Ghost Dog: Get 1 tennis ball");
	# set_choice(1108, my_ascensions() % 2 + 1, "Your Dog Found Something Again: Get food or booze"); // 1 is food, 2 is booze - Alternate
	
	
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
	set_choice(182, 1, "Fantasy Airship, Lack of an Encounter: Fight MechaMech for metallic A if you turn up the ML");
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
	//SIMON: force it to sell the silly stones
//	while(meat4pork(9999999)){}
	
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
	
	//SIMON: modified to actually do bales suggestion
	// Don't get the toy accordion if I have a Deck of Every Card because I'll probably prefer to sell a Mickey Mantle card and buy an antique accordion.
	if(available_amount($item[Deck of Every Card]) > 0 && be_good($item[Deck of Every Card]))
	{
		if(available_amount($item[1952 Mickey Mantle card])==0)
			cli_execute("cheat Mantle");
		autosell(1,$item[1952 Mickey Mantle card]);
		if(need_accordion())
			buy(1, $item[antique accordion]);
	}
	else {
		if(need_accordion())
			garner = trade_pork4item($item[toy accordion]);
	}
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
	
	foreach f in $familiars[He-Boulder, galloping grill, baby sandworm, hovering sombrero, Frumious Bandersnatch, Baby Bugged Bugbear, Bloovian Groose, Gluttonous Green Ghost, 
	  Spirit Hobo, Fancypants Scarecrow, Ancient Yuletide Troll, Cheshire Bat, Cymbal-Playing Monkey, Nervous Tick, 
	  Hunchbacked Minion, Uniclops, Chauvinist Pig, Dramatic Hedgehog, Blood-Faced Volleyball, Reagnimated Gnome, 
	  Jill-O-Lantern]
		if(have_familiar(f) && good(f)) return f;
	
	return $familiar[none];
}

void equip_stuff() {
	buffer gear;
	gear.append("mainstat, 0.2 hp, 0.2 dr, 0.1 spell damage, +effective 4 ");
	gear.append(primestat);
	gear.append(" experience");
	if(my_path() != "Zombie Slayer")
		gear.append(", mp regen");
	if(good("familiar"))
		gear.append(", 0.2 familiar weight");
	if(available_amount($item[sugar shield]) > 0)
		gear.append(" -equip sugar shield");
	
	// Ensure correct type of weapon
	if(primestat == $stat[Muscle])
		gear.append(" +0.5 melee");
	else if(primestat == $stat[Moxie])
		gear.append(" -0.5 melee");
	// Unarmed combat or require shield?
	if(have_skill($skill[Master of the Surprising Fist]) && have_skill($skill[Kung Fu Hustler]) && available_amount($item[Operation Patriot Shield]) < 1)
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
	//SIMON ADDED item bonus
	gear.append(", 0.2 items");
	print("maximize "+gear,"green");
	maximize(gear, false);
}

void handle_starting_items() {
	// Free pulls
	if(good($item[brick]))
		retrieve_item(available_amount($item[brick]), $item[brick]);

	// Unpack astral consumables
	foreach it in $items[astral hot dog dinner, astral six-pack, carton of astral energy drinks, box of bear arms]
		if(item_amount(it) > 0 && good(it)) use(item_amount(it), it);
	
	// In AWoL, holster your toy sixgun
	if(available_amount($item[toy sixgun]) > 0)
		equip($slot[holster], $item[toy sixgun]);
		
	// Put on the best stuff you've got.
	vprint("Put on your best gear.", "olive", 3);
	// First equip best familiar!
	familiar fam = (vars contains "is_100_run")? to_familiar(vars["is_100_run"]): my_familiar();
	if(fam == $familiar[none] || !good(fam) || !have_familiar(fam))
		fam = start_familiar();
	use_familiar(fam);
	equip_stuff();
}

// Optimal restoration settings for level 1. These will need to be changed by level 4
void recovery_settings() {
	// Ed needs no wussy healing
	if(my_path() == "Actually Ed the Undying") {
		set_choice("hpAutoRecovery", "-0.05", "Don't bother with healing");
		set_choice("hpAutoRecoveryTarget", "-0.05", "");
	} else {
		set_choice("hpAutoRecovery", "0.6", "Resetting HP/MP restoration settings to minimal");
		set_choice("hpAutoRecoveryTarget", "0.90", "");
	}
	
	// Zombie Slayers have an alternative to using mana
	if(my_path() == "Zombie Slayer") {
		if(get_property("baleUr_ZombieAuto") != "")
			set_property("baleUr_ZombieAuto", "-0.05");
		if(get_property("baleUr_ZombieTarget") != "")
			set_property("baleUr_ZombieTarget", 1);
		//simon to stop waste during moods
		set_choice("manaBurningThreshold", "-0.05", "");
		// Turn off mana restoration in combat. It causes problems in zombiecore
		set_property("autoManaRestore", "false");
	} else {
		set_choice("mpAutoRecovery", "0.2", "");
		set_choice("mpAutoRecoveryTarget", "0.4", "");
	}
	
	set_choice("manaBurningTrigger", "-0.05", "");
	set_choice("manaBurningThreshold", "0.80", "");
}

// If you are completely full of Boris or Braaaaains, this will get all the skills
void path_skills(boolean always_learn) {
	//learn source terminal skills
	cli_execute("terminal educate digitize");
	cli_execute("terminal educate extract");
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

boolean pull_if_good(item it)
{
	if(good(it))
	{
		//check for unrecognised type69
		print("pulling "+it);
		if(available_amount(it)==0)
			take_storage(1,it);
		if(available_amount(it)==0)
		{
			if(!contains_text(it,"astral") && it!=$item[none]) //ignore when we fail to pull astrals
				abort("Failed to pull "+it);
			return false;
		}
		return true;
	}
	return false;
}

boolean pull_and_wear_if_good(item it)
{
	if(pull_if_good(it))
	{
		equip(it);
		return true;
	}
	return false;
}
 
boolean pull_and_wear_if_good(item it, slot sl)
{
	if(pull_if_good(it))
	{
		equip(sl,it);
		return true;
	}
	return false;
}

void make_smithness_weapon(item it)
{
	if(available_amount(it)<1 && good(it))
	{
		if(available_amount($item[lump of brituminous coal])==0)
			use_skill(1,$skill[summon smithsness]);
			
		create(1,it);
		equip(it);
	}
}

int pull_and_wear_from_list(item[int] list)
{
	string list_str = "";
	foreach i in list
	{
		item it = list[i];
		if(pull_and_wear_if_good(it))
			return i;
		list_str = list_str + " " + it;
	}
	abort("searched whole list (see end) without finding anything suitable to wear. list=" + list_str);
	return -1;
}

int pull_and_wear_from_list(item[int] list, slot s)
{
	string list_str = "";
	foreach i in list
	{
		item it = list[i];
		if(pull_and_wear_if_good(it,s))
			return i;
		list_str = list_str + " " + it;
	}
	abort("searched whole list (see end) without finding anything suitable to wear. list=" + list_str);
	return -1;
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
	//if in softcore, pull my set
	if(in_hardcore())
	{
		if(have_skill($skill[summon smithsness]))
		{
			switch(my_class())
			{
				case($class[seal clubber]):
					make_smithness_weapon($item[Meat Tenderizer is Murder]);
					break;
				case($class[turtle tamer]):
					make_smithness_weapon($item[Ouija Board, Ouija Board]);
					break;
				case($class[pastamancer]):
					make_smithness_weapon($item[Hand that Rocks the Ladle]);
					break;
				case($class[sauceror]):
					make_smithness_weapon($item[Saucepanic]);
					break;
				case($class[disco bandit]):
					make_smithness_weapon($item[Frankly Mr. Shank]);
					break;
				case($class[accordion thief]):
					make_smithness_weapon($item[Shakespeare's Sister's Accordion]);
					break;
			}
		}
	}
	else
	{
		cli_execute("inventory refresh");
		refresh_stash();
		if(my_path()=="BIG!")
		{
			print("not automating gear for big","red");
		}
		else if(my_name()=="twistedmage")
		{
			//random stuff
			if(my_path()!="Heavy Rains")
				pull_if_good($item[loathing legion universal screwdriver]);
			boolean screw=item_amount($item[loathing legion universal screwdriver])>0;
			if(pull_if_good($item[can of rain-doh]))
				if(available_amount($item[rain-doh blue balls])==0)
					use(1,$item[can of rain-doh]);
			if(available_amount($item[box of bear arms])>0)
				use(1,$item[box of bear arms]);
	//			pull_if_good($item[jewel-eyed wizard hat]);
			//pull tps drink
	//			pull_if_good($item[grogtini]);
			//handle zombie head + maid if we have gnoll
			if( knoll_available() && pull_if_good($item[Ninja pirate zombie robot head]))
			{
				if(screw)
				{
					knife_untinker($item[ninja pirate zombie robot head]);
					knife_untinker($item[pirate zombie robot head]);
					knife_untinker($item[pirate zombie head]);
					knife_untinker($item[clockwork pirate skull]);
					knife_untinker($item[enchanted eyepatch]);
					if(my_path()!="Way of the Surprising Fist") //can't afford other meat maid pieces in wotsf
					{
						cli_execute("make clockwork maid");
						cli_execute("use clockwork maid");
					}
				}
			}
			if(available_amount($item[wrecked generator])<1 && can_drink() && my_path() != "KOLHS" && my_path() != "Avatar of Jarlsberg" && my_path() != "Heavy Rains")
				pull_if_good($item[wrecked generator]);
			pull_if_good($item[jar of psychoses (The Crackpot Mystic)]);
			
			///--------------GEAR----------
			
			//familiar
			if(good("familiar"))
			{
				item [int] fam_list;
				fam_list[count(fam_list)] = $item[moveable feast];
				fam_list[count(fam_list)] = $item[snow suit];
				fam_list[count(fam_list)] = $item[astral pet sweater];
				pull_and_wear_from_list(fam_list);
			}
			
			//hat
			item [int] hat_list;
			hat_list[count(hat_list)] = $item[astral chapeau];
			if(my_path()=="Actually Ed the Undying") //ed should wear his crown
			{
				hat_list[count(hat_list)] = $item[The Crown of Ed the Undying];
			}
			//everyone but ed should wear boris's hat
			hat_list[count(hat_list)] = $item[Boris's Helm (askew)];
			hat_list[count(hat_list)] = $item[Boris's Helm];
			hat_list[count(hat_list)] = $item[crown of thrones];
			hat_list[count(hat_list)] = $item[The Crown of Ed the Undying];
			hat_list[count(hat_list)] = $item[Helm of the Scream Emperor];
			pull_and_wear_from_list(hat_list);
			//pose hat choice actions...
			if(available_amount($item[The Crown of Ed the Undying])>0)
				cli_execute("edpiece hyena");
			if(available_amount($item[boris's helm])>0)
				cli_execute("fold boris's helm (askew)");
			if(available_amount($item[crown of thrones])>0)
			{
				if(good("el vibrato Megadrone"))
				{
					cli_execute("enthrone El Vibrato Megadrone");
//					else if(good("Li'l Xenomorph"))
//					cli_execute("enthrone Li'l Xenomorph");
				}
				else
					abort("Don't know what familiar to enthrone for this path");
			}
			
			//trousers
			item [int] pants_list;
			pants_list[count(pants_list)] = $item[astral shorts];
			pants_list[count(pants_list)] = $item[astral trousers];
			pants_list[count(pants_list)] = $item[pantsgiving];
			pants_list[count(pants_list)] = $item[greatest american pants];
			if(my_class()==$class[disco bandit])
				pants_list[count(pants_list)] = $item[The Sagittarian's leisure pants];
			if(my_basestat($stat[muscle])>=5)
				pants_list[count(pants_list)] = $item[stylish swimsuit];
			pants_list[count(pants_list)] = $item[toy Crimbot rocket legs];
			pull_and_wear_from_list(pants_list);
			
			//shirt
			if(have_skill($skill[torso awaregness]))
			{
				item [int] shirt_list;
				shirt_list[count(shirt_list)] = $item[astral shirt];
				shirt_list[count(shirt_list)] = $item[Sneaky Pete's leather jacket (collar popped)];
				shirt_list[count(shirt_list)] = $item[Sneaky Pete's leather jacket];
				shirt_list[count(shirt_list)] = $item[cane-mail shirt];
				pull_and_wear_from_list(shirt_list);
				//post shirt stuff...
				if(available_amount($item[sneaky pete's leather jacket])>0)
				{
					cli_execute("fold sneaky pete's leather jacket (collar popped)");
				}
			}
			
			//back
			item [int] back_list;
			back_list[count(back_list)] = $item[protonic accelerator pack];
			back_list[count(back_list)] = $item[buddy bjorn];
			back_list[count(back_list)] = $item[Camp Scout backpack];
			back_list[count(back_list)] = $item[Cloak of Dire Shadows];
			pull_and_wear_from_list(back_list);
			//post back actions
			if(available_amount($item[buddy bjorn])>0)
			{
				pull_and_wear_if_good($item[buddy bjorn]);
				if(good("el vibrato Megadrone"))
				{
					cli_execute("bjornify El Vibrato Megadrone");
	//				else if(good("Li'l Xenomorph"))
	//				cli_execute("enthrone Li'l Xenomorph");
				}
				else
					abort("Don't know what familiar to bjornify for this path");
			}
			
			//weapon
			item [int] wep_list;
			wep_list[count(wep_list)] = $item[astral mace];
			wep_list[count(wep_list)] = $item[astral longbow];
			wep_list[count(wep_list)] = $item[astral bludgeon];
			wep_list[count(wep_list)] = $item[astral pistol];
			wep_list[count(wep_list)] = $item[saucepanic];
			wep_list[count(wep_list)] = $item[thor's pliers];
			wep_list[count(wep_list)] = $item[ice sickle];
			pull_and_wear_from_list(wep_list);
			
			//offhand
			item [int] off_list;
			off_list[count(off_list)] = $item[astral shield];
			off_list[count(off_list)] = $item[Astral statuette];
			//myst classes want a pan offhand
			if(my_primestat()==$stat[mysticality] && my_path()!="Bees Hate You" && my_path()!="BIG!")
			{
				off_list[count(off_list)] = $item[Jarlsberg's pan (Cosmic portal mode)];
				off_list[count(off_list)] = $item[Jarlsberg's pan];
			}
			off_list[count(off_list)] = $item[operation patriot shield];
			if(my_class()==$class[seal clubber])
				off_list[count(off_list)] = $item[Meat Tenderizer is Murder];
			else if(my_class()==$class[disco bandit])
				off_list[count(off_list)] = $item[Frankly Mr. Shank];
			off_list[count(off_list)] = $item[Shield of Icy Fate];
			off_list[count(off_list)] = $item[hypnodisk];
			pull_and_wear_from_list(off_list, $slot[off-hand]);
			//post OH actions
			if(available_amount($item[Jarlsberg's pan])>0)
			{
				cli_execute("fold Jarlsberg's pan (Cosmic portal mode)");
			}
			
			//accessories
			item [int] acc_list;
			if(screw)
			{
				cli_execute("fold loathing legion necktie");
			}
			acc_list[count(acc_list)] = $item[astral belt];
			acc_list[count(acc_list)] = $item[astral mask];
			acc_list[count(acc_list)] = $item[astral bracer];
			acc_list[count(acc_list)] = $item[astral ring];
			//with level 7 shelter, the wrist boy is really good
			if(my_path()=="Nuclear Autumn" && to_int(get_property("falloutShelterLevel"))>6 && my_meat()>2000)
			{
				if(available_amount($item[wrist-boy])==0)
					buy(1,$item[wrist-boy]);
				acc_list[count(acc_list)] = $item[wrist-boy];
			}
			acc_list[count(acc_list)] = $item[loathing legion necktie];
			acc_list[count(acc_list)] = $item[juju mojo mask];
			acc_list[count(acc_list)] = $item[plastic vampire fangs];
			acc_list[count(acc_list)] = $item[Your cowboy boots];
			if(my_path()=="Heavy Rains")
			{
				if(my_primestat()==$stat[mysticality])
				{
					acc_list[count(acc_list)] = $item[fishbone bracers];
				}
				else
				{
					acc_list[count(acc_list)] = $item[fishbone belt];
				}
			}
			acc_list[count(acc_list)] = $item[Gold detective badge];
			acc_list[count(acc_list)] = $item[Talisman of Baio];
			//without level 7 it's OK, but not so great
			if(my_path()=="Nuclear Autumn" && to_int(get_property("falloutShelterLevel"))>3 && to_int(get_property("falloutShelterLevel"))<7 && my_meat()>2000)
			{
				if(available_amount($item[wrist-boy])==0)
					buy(1,$item[wrist-boy]);
				acc_list[count(acc_list)] = $item[wrist-boy];
			}
			if(my_class()==$class[disco bandit])
				acc_list[count(acc_list)] = $item[warbear laser beacon];
			acc_list[count(acc_list)] = $item[Mr. Accessory Jr.];
			acc_list[count(acc_list)] = $item[Gauntlets of the Blood Moon];
			acc_list[count(acc_list)] = $item[time-twitching toolbelt];
			
			print("------ACC1-------","lime");
			int chosen = pull_and_wear_from_list(acc_list, $slot[acc1]);
			acc_list[chosen] = $item[none]; //remove chosen item from list so not chosen again
			print("------ACC2-------","lime");
			chosen = pull_and_wear_from_list(acc_list, $slot[acc2]);
			acc_list[chosen] = $item[none]; //remove chosen item from list so not chosen again
			print("------ACC3-------","lime");
			chosen = pull_and_wear_from_list(acc_list, $slot[acc3]);
			
			//holster
			if(my_path()=="Avatar of West of Loathing")
			{
				item [int] hol_list;
				hol_list[count(hol_list)] = $item[Pecos Dave's sixgun];
				hol_list[count(hol_list)] = $item[Porquoise-handled sixgun];
				pull_and_wear_from_list(hol_list);
			}
			
					
		}
	}
	
	if(in_hardcore())
		equip_stuff();
}

void check_breakfast() {
	if(get_property("breakfastCompleted") == "true") return;
	vprint("Time for breakfast.", "blue", 3);
	cli_execute("breakfast");
	string loginScript = get_property("loginScript");
	if(loginScript != "")
		cli_execute(loginScript);
}

void start_quests()
{
	//visit artist and accept
	visit_url("town_wrong.php?place=artist");
	wait(3);
	visit_url("town_wrong.php?place=artist&getquest=1");
	//visit doc galaktik
	visit_url("galaktik.php");
	//visit guild
	visit_url("guild.php?place=challenge");
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
		//equip_stuff(); //SIMON: don't mess up intended set
	}
	check_breakfast();
	start_quests();
	cli_execute("outfit save Backup");  // Accidently equiping Backup after ascending cases error. No more oops.
	cli_execute("outfit save bumcheekascend");  // Accidently equiping Backup after ascending cases error. No more oops.
	vprint("Welcome to your new life as a "+myclass+"!", "green", 3);
	set_property("unlockedLocations",""); 
	set_property("ready_for_ascension",false);	
	set_property("rave_open",false);	
	cli_execute("inventory refresh");
	set_property("_photocopyUsed","false"); //in case the game crashes during ascension and it isn't reset
	cli_execute("mood default");
}

// These are default values here. To change for each character, edit their vars file in /data direcory or use the zlib commands.
setvar("newLife_SetupGuyMadeOfBees", FALSE); // If you like to set up the guy made of bees set this TRUE. 
setvar("newLife_FightBedstands", FALSE);	// If this is set to TRUE, you'll prefer fighting Bedstands to getting meat. (Note that mainstat is still better than fighting.)
setvar("newLife_SmashHippyStone", TRUE);	// Smash stone if you want to break it at level 1 for some PvPing!
setvar("newLife_UseNewbieTent", TRUE);		// Use newbie tent if you don't want togive your clannes a fair shot at bricking you in the face!
setvar("newLife_SellPorkForStuff", TRUE);	// Sell pork gems to purchase detuned radio, stolen accordion & seal tooth
setvar("newLife_Extras", TRUE); 			// Mixed bag of custom actions. This is personal to me, but maybe someone else will like it also

void main() {
	new_ascension();
}
