// Bale's PostAscensionScript: newLife
//      set postAscensionScript = newLife.ash

script "newLife.ash"
notify "Bale";
import "zlib.ash";

if(check_version("newLife", "bale-new-life", "1.14.4", 2769) != "" 
  && user_confirm("The script has just been updated!\nWould you like to quit now and manually resume execution so that you can use the current version?")) {
	print("New Life aborted to complete update. Please run newLife.ash to finish setting up your current ascension.", "red");
	exit;
}

void knife_untinker(item it)
{
	if(item_amount($item[loathing legion universal screwdriver])<1)
		abort("Can't untinker without legion screwdriver");
	//use knife
	string catch = visit_url("inv_use.php?which=3&whichitem=&pwd="+my_hash(),false,true);
	//unscrew item
	catch = visit_url("inv_use.php?whichitem=4926&action=screw&dowhichitem="+to_int(it)+"&untinker=Unscrew%21&pwd="+my_hash(),false,true);
}


if(!($strings[None, Teetotaler, Boozetafarian, Oxygenarian, Bees Hate You, Way of the Surprising Fist, Trendy,
Avatar of Boris, Bugbear Invasion, Zombie Slayer, Class Act, Avatar of Jarlsberg, BIG!, KOLHS, Class Act II: A Class For Pigs, 
Avatar of Sneaky Pete, Slow and Steady, 19, Heavy Rains] contains my_path())
  && user_confirm("Your current challenge path is unknown to this script!\nUnknown and unknowable errors may take place if it is run.\nDo you want to abort?")) {
	print("Your current path is unknown to this script! A new version of this script should be released very soon.", "red");
	exit;
}

// Often I get this script out before full mafia support. Hence these variable are necessary.
// It's no longer necessary for old paths however I may need it in the future.
stat primestat = my_primestat();
string myclass = my_class();
if(my_path() == "17") {
	primestat = $stat[moxie];
	myclass = "Avatar of Sneaky Pete";
}
boolean skipStatNCs = my_path() == "BIG!" || my_path() == "Class Act II: A Class For Pigs";

// This is a wrapper for be_good() that contains exceptions for this script's purpose.
// It will also contain new content that hasn't yet made it to zlib's be_good() function since I'm impatient to make a new release.
boolean good(string it) {
	switch(my_path()) {
	case "Way of the Surprising Fist":
		// Don't autosell in Way of the Surprising Fist
		if($strings[pork elf goodies sack, baconstone, hamethyst, porquoise, chewing gum on a string] contains it) return false;
		break;
	case "Avatar of Boris":
		// Boris needs no wussy stasis. Boris also needs to save meat for an antique instrument
		if($strings[seal tooth, detuned radio, familiar] contains it) return false;
		break;
	case "Zombie Slayer":
		// Zombie Masters don't have hermit access
		if(it == "seal tooth") return false;
		break;
	case "Avatar of Jarlsberg":
	case "Avatar of Sneaky Pete":
		if(it.to_familiar() != $familiar[none] || it == "familiar") return false;
		break;
	}
	return is_unrestricted(it) && be_good(it);
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
	set_choice(876, 6, "Bedroom, White Nightstand: Skip");
	set_choice(877, 6, "Bedroom, Mahogany Nightstand: Skip");
	set_choice(878, 3, "Bedroom, Ornate Nightstand: Get spectacles");
	if(my_path() == "Bees Hate You")
		set_choice(879, 3, "Bedroom, Rustic Nightstand: Fight Mistress for Antique Mirror");
	else
		set_choice(879, 6, "Bedroom, Rustic Nightstand: Skip");
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
	set_choice(679, 1, "Spin That Wheel, Giants Get Real");
	// Hidden City!
	set_choice(781, 1, "An Overgrown Shrine (Northwest)");
	set_choice(783, 1, "An Overgrown Shrine (Southwest)");
	set_choice(785, 1, "An Overgrown Shrine (Northeast)");
	set_choice(787, 1, "An Overgrown Shrine (Southeast)");
	
	// Path specific choices
	if(my_path() == "Way of the Surprising Fist")
		set_choice(297, 1, "Haiku Dungeon: Gaffle some mushrooms");
	else
		set_choice(297, 3, "Haiku Dungeon: Skip adventure to keep looking for the Bugbear Disguise");
	if(my_path() == "Way of the Surprising Fist" && in_hardcore()) {
		set_choice(153, 2, "Defiled Alcove: get meat");
		set_choice(155, 2, "Defiled Niche: get meat");
		set_choice(157, 3, "Defiled Nook: get meat");
	} else {
		set_choice(153, 4, "Defiled Alcove: skip adventure");
		set_choice(155, 4, "Defiled Niche: skip adventure");
		set_choice(157, 4, "Defiled Nook: skip adventure");
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
		set_choice("oceanDestination", my_primestat().to_lower_case(), "At the Poop Deck: take the Wheel and Sail to "+my_primestat()+" stats");
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
	if(vars["newLife_SmashHippyStone"] == "true" && !hippy_stone_broken() && good("Hippy Stone"))
		visit_url("campground.php?confirm=on&smashstone=Yep.&pwd");
	
	if(get_dwelling() != $item[big rock])
		return;  // If dwelling is something other than a big rock, we're done here.
	boolean tent = available_amount($item[Newbiesport&trade; tent]) > 0 && good($item[Newbiesport&trade; tent])
	  && vars["newLife_UseNewbieTent"].to_boolean();
	// If the player is in Hardcore Nation it is time to send a "Please brick me" announcement!
	// I only announce it if I am ascending hardcore. Silly, but that's me.
	if( (in_hardcore() || !softBoo) & (tent || my_turncount() < 1) && get_clan_id() == 41543) {  // 41543 is the ID for HCN
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
	boolean meat4pork(int price) {
		if(my_meat() >= price) return true;
		if(item_amount($item[baconstone]) > 0) return autosell(1, $item[baconstone]);
		if(item_amount($item[hamethyst])  > 0) return autosell(1, $item[hamethyst]);
		if(item_amount($item[porquoise])  > 0) return autosell(1, $item[porquoise]);
		return false;
	}
	//SIMON: force it to sell the silly stones
	while(meat4pork(9999999)){}
	
	boolean worthless() {
		for i from 43 to 45
			if(available_amount(i.to_item()) > 0) return true;
		return false;
	}

	if(good($item[chewing gum on a string])) {

		boolean sealtooth = false; //item_amount($item[seal tooth]) == 0 && good($item[seal tooth]) && my_class() != $class[Disco Bandit];
		boolean radio = item_amount($item[detuned radio]) == 0 && knoll_available() && good($item[detuned radio]);
		int q = to_int(sealtooth) + to_int(radio);
		string garner;
		if(sealtooth) garner += "seal tooth"       + (radio? " and a ": "");
		if(radio)     garner += "detuned radio";
		if(garner != "")
			vprint("Pork Elf stones are being autosold now to garner a "+garner+".", "blue", 3);
		if(radio && item_amount($item[detuned radio]) == 0 && meat4pork(300))
			buy(1, $item[detuned radio]);
		if(sealtooth && available_amount($item[seal tooth]) == 0) {
			while(!worthless() && meat4pork(50))
				use(1, $item[chewing gum on a string]);
			if(worthless() && (available_amount($item[hermit permit]) > 0 || meat4pork(100)))
				hermit(1, $item[seal tooth]);
		}
	}
}

// Visit Mt. Noob to get pork gems.
void visit_toot() {
	vprint("The Oriole welcomes you back at Mt. Noob.", "olive", 3);
	visit_url("tutorial.php?action=toot&pwd");
	if(item_amount($item[letter from King Ralph XI]) > 0 && good($item[letter from King Ralph XI]))
		use(1, $item[letter from King Ralph XI]);
	if(vars["newLife_SellPorkForStuff"].to_boolean()) {
		if(item_amount($item[pork elf goodies sack]) > 0 && good($item[pork elf goodies sack]))
			use(1, $item[pork elf goodies sack]);
		if(item_amount($item[baconstone]) + item_amount($item[hamethyst]) + item_amount($item[porquoise]) > 0)
			buy_stuff();
	}
}

boolean use_shield() {
	if(my_path() == "Zombie Slayer" && available_amount($item[left bear arm]) > 0) return false;
	foreach i in get_inventory()
		if(item_type(i) == "shield" && can_equip(i) && good(i)) return true;
	if(item_type(equipped_item($slot[off-hand])) == "shield") return true;
	return false;
}

familiar start_familiar() {
	void set_bcca(string f) {
		if(get_property("bcasc_lastCouncilVisit") == "") return;
		// Only set this if BCCAscend has actually been run by this player
		set_property("bcasc_100familiar", f); 
		set_property("bcasc_defaultFamiliar", f); 
	}
	// Check for the zlib variable "is_100_run"
	familiar f100 = vars["is_100_run"].to_familiar();
	if(f100 == $familiar[none]) {
		set_bcca("");
	} else {
		set_bcca(vars["is_100_run"]);
		return f100;
	}
	
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
	string gear = "mainstat, 0.2 hp, 0.2 dr, 0.2 familiar weight, 0.1 spell damage, -equip sugar shield, 4 ";
	gear += my_primestat() + " experience";
	if(my_path() != "Zombie Slayer")
		gear += ", mp regen";
	// Ensure correct type of weapon
	if(primestat == $stat[Muscle])
		gear += " +melee";
	else if(primestat == $stat[Moxie])
		gear += " -melee";
	// Unarmed combat or require shield?
	if(have_skill($skill[Master of the Surprising Fist]) && have_skill($skill[Kung Fu Hustler]) && available_amount($item[Operation Patriot Shield]) < 1)
		gear +=" -weapon -offhand";  // Barehanded can be BEST at level 1!
	else if(use_shield())
		gear +=" +shield";
	if(my_path() == "Bees Hate You")
		gear += ", 0 beeosity";
	else if(my_path() == "KOLHS" || my_path() == "15")
		gear+= " -hat";
	//SIMON ADDED item bonus
	gear +=", 0.2 items";
	print("maximize "+gear,"green");
	maximize(gear, false);
}

void handle_starting_items() {
	// Free pulls
	if(good($item[brick]))
		retrieve_item(available_amount($item[brick]), $item[brick]);
	#if(my_path() == "Avatar of Jarlsberg" && available_amount($item[Jarlsberg's pan (Cosmic portal mode)]) < 1 && available_amount($item[Jarlsberg's pan]) > 0)
	#	visit_url("inv_use.php?pwd&which=2&ajax=1&whichitem=6305");

	// Unpack astral consumables
	foreach it in $items[astral hot dog dinner, astral six-pack, carton of astral energy drinks,
	  box of bear arms]
		if(item_amount(it) > 0 && good(it)) use(item_amount(it), it);

	// Put on the best stuff you've got.
	vprint("Put on your best gear.", "olive", 3);
	// First equip best familiar!
	familiar fam = (vars contains "is_100_run")? to_familiar(vars["is_100_run"]): my_familiar();
	if(fam == $familiar[none] || !good(fam) || !have_familiar(fam))
		fam = start_familiar();
	use_familiar(fam);
	equip_stuff();
}

void recovery_settings() {
	// Optimal restoration settings for level 1. These will need to be changed by level 4
	set_choice("hpAutoRecovery", "0.25", "Resetting HP/MP restoration settings to minimal");
	set_choice("hpAutoRecoveryTarget", "0.95", "");
	set_choice("manaBurningTrigger", "-0.05", "");
	set_choice("manaBurningThreshold", "0.80", "");
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
		set_choice("mpAutoRecovery", "0.3", "");
		set_choice("mpAutoRecoveryTarget", "0.6", "");
	}
	
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
			vprint("You are filled with all of Boris' skills and ready to use them.", "blue", 3);
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
		string jarl = visit_url("da.php?place=gate2");
		matcher unassigned = create_matcher("have (\\d+) skill points", jarl);
		if(unassigned.find() && unassigned.group(1).to_int() > 31) {
			foreach sk in $skills[Boil, Conjure Eggs, Conjure Dough, Fry, Coffeesphere, Egg Man, Early Riser, The Most Important Meal,
			  Conjure Vegetables, Chop, Slice, Lunch Like a King, Oilsphere, Radish Horse, Conjure Cheese, Working Lunch,
			  Bake, Conjure Potato, Conjure Meat Product, Grill, Gristlesphere, Food Coma, Hippotatomous, Never Late for Dinner,
			  Conjure Fruit, Freeze, Conjure Cream, Cream Puff, Chocolatesphere, Best Served Cold, Nightcap, Blend]
				visit_url("jarlskills.php?action=getskill&getskid="+to_int(sk));
			vprint("You are filled with all of Jarlsberg's skills, now get cooking!", "blue", 3);
		}
		break;
	}
}
boolean pull_if_good(item it)
{
	if(good(it))
	{
		print("pulling "+it);
		take_storage(1,it);
		return true;
	}
	return false;
}

void pull_and_wear_if_good(item it)
{
	if(pull_if_good(it))
	{
		equip(it);
	}
}
 
void pull_and_wear_if_good(item it, slot sl)
{
	if(pull_if_good(it))
	{
		equip(sl,it);
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
	if(available_amount($item[detuned radio]) > 0 || canadia_available())
		change_mcd(10 + canadia_available().to_int());
	//if in softcore, pull my set
	if(!in_hardcore())
	{
		cli_execute("inventory refresh");
		refresh_stash();
		if(my_name()=="twistedmage")
		{
			//hat
			if(storage_amount($item[Boris's Helm (askew)])>0)
				pull_and_wear_if_good($item[Boris's Helm (askew)]);
			else
			{
				pull_if_good($item[Boris's Helm]);
				if(available_amount($item[boris's helm])>0)
				{
					cli_execute("fold boris's helm (askew)");
					equip($item[boris's helm (askew)]);
				}
			}
			if(available_amount($item[boris's helm (askew)])==0)
			{
				pull_and_wear_if_good($item[crown of thrones]);
				if(available_amount($item[crown of thrones])>0)
					if(good("el vibrato Megadrone"))
					{
						cli_execute("enthrone El Vibrato Megadrone");
	//					else if(good("Li'l Xenomorph"))
	//					cli_execute("enthrone Li'l Xenomorph");
					}
					else
						abort("Don't know what familiar to enthrone for this path");
			}
			//myst classes want a pan offhand
			if(my_primestat()==$stat[mysticality] && my_path()!="Bees Hate You" && my_path()!="BIG!")
			{
				//pull whichever
				if(storage_amount($item[Jarlsberg's pan (Cosmic portal mode)])>0)
				{
					pull_if_good($item[Jarlsberg's pan (Cosmic portal mode)]);
				}
				else
				{
					pull_if_good($item[Jarlsberg's pan]);
				}
				//for now we will always use the portal version, might want to change it one day though
				if(available_amount($item[Jarlsberg's pan])>0)
				{
					cli_execute("fold Jarlsberg's pan (Cosmic portal mode)");
				}
				if(available_amount($item[Jarlsberg's pan (Cosmic portal mode)])>0)
					equip($item[Jarlsberg's pan (Cosmic portal mode)]);
			}
			else //others want a shield
			{
				pull_and_wear_if_good($item[operation patriot shield]);
			}
			//pull_and_wear_if_good($item[greatest american pants]);
			if(available_amount($item[pantsgiving])==0)
				pull_and_wear_if_good($item[pantsgiving]);
			
			if(my_path()!="Heavy Rains")
				pull_if_good($item[loathing legion universal screwdriver]);
			boolean screw=item_amount($item[loathing legion universal screwdriver])>0;
			if(my_path()!="Avatar of Boris" && my_path()!="Avatar of Jarlsberg")
			{
				pull_if_good($item[moveable feast]);
				pull_and_wear_if_good($item[snow suit]);
			}
			if(have_skill($skill[torso awaregness]))
			{
				if(available_amount($item[astral shirt]) < 1)
				{
					pull_and_wear_if_good($item[Sneaky Pete's leather jacket (collar popped)]);
					if(available_amount($item[sneaky pete's leather jacket (collar popped)])<1)
					{
						pull_and_wear_if_good($item[Sneaky Pete's leather jacket]);
						cli_execute("fold sneaky pete's leather jacket (collar popped)");
						if(available_amount($item[sneaky pete's leather jacket (collar popped)])<1)
						{
							equip($item[Sneaky Pete's leather jacket (collar popped)]);
						}
						else
						{
							pull_and_wear_if_good($item[cane-mail shirt]);
						}
					}
				}
			}
			
			//back
			if(good("buddy bjorn") && my_path()!="Avatar of Boris" && my_path()!="Avatar of Jarlsberg" && my_path()!="Avatar of Sneaky Pete")
			{
				pull_and_wear_if_good($item[buddy bjorn]);
				if(good("el vibrato Megadrone"))
				{
					cli_execute("bjornify El Vibrato Megadrone");
					
					
	//				else if(good("Li'l Xenomorph"))
	//				cli_execute("enthrone Li'l Xenomorph");
				}
				else
					abort("Don't know what familiar to enthrone for this path");
			}
			else
			{
				pull_and_wear_if_good($item[Camp Scout backpack]);
				if(available_amount($item[Camp Scout backpack])<1)
					pull_and_wear_if_good($item[Cloak of Dire Shadows]);
			}
			//now pull useful stuff
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
			if(my_path()=="BIG!")
			{
				if(my_class()==$class[accordion thief])
				{
					print("creating a Shakespeare's Sister's Accordion, better than bottle rocket","purple");
					
					//try to craft
					if(available_amount($item[Shakespeare's Sister's Accordion])<1 && have_skill($skill[summon smithsness]))
					{
						if(available_amount($item[lump of brituminous coal])==0)
							use_skill(1,$skill[summon smithsness]);
							
						create(1,$item[Shakespeare's Sister's Accordion]);
						equip($item[Shakespeare's Sister's Accordion]);
					}
					//pull
					if(available_amount($item[Shakespeare's Sister's Accordion])<1)
						pull_and_wear_if_good($item[Shakespeare's Sister's Accordion]);
				}
				//get somethign else instead
				if(equipped_amount($item[Shakespeare's Sister's Accordion])==0)
				{
					if(my_primestat()==$stat[moxie])
						pull_and_wear_if_good($item[bottle-rocket crossbow]);
					else
						pull_and_wear_if_good($item[haiku katana]);
				}

				pull_and_wear_if_good($item[v for vivala mask],$slot[acc2]);
				pull_and_wear_if_good($item[mr. accessory jr.],$slot[acc1]);
				if(available_amount($item[astral mask])>0)
					equip($slot[acc3],$item[astral mask]);
				else
					pull_and_wear_if_good($item[mr. accessory jr.],$slot[acc3]);
			}
			else //not big
			{
				//ice sickle is TECHNICALLY better than pliers (5 stat vs 4 stat) but pliers have nice quality of life
				if(equipped_amount($item[saucepanic])<1)
					pull_and_wear_if_good($item[thor's pliers]);
				//	pull_and_wear_if_good($item[ice sickle]);
				
				//1st acc legion necktie
				if(screw)
				{
					cli_execute("fold loathing legion necktie");
					if(good($item[loathing legion necktie]))
						equip($slot[acc1],$item[loathing legion necktie]);
				}
				
				//not trendy enough for HR
				if(my_path()!="Heavy Rains")
				{
					pull_and_wear_if_good($item[juju mojo mask],$slot[acc2]);
					//if we have no astral belt, wear fangs. Else pull fangs as superclover but dont wear 
					if(available_amount($item[astral belt])<1)
						pull_and_wear_if_good($item[plastic vampire fangs],$slot[acc3]);
					else
					{
						pull_if_good($item[plastic vampire fangs]);
						equip($slot[acc3],$item[astral belt]);
					}
				}
				else
				{
					//in heavy rains our accessory choice is pretty limmited
					//assume we got an astral, then we need 2
					int needed_accs=3;
					foreach it in $items[astral belt, astral mask, astral bracer, astral ring]
					{
						if(available_amount(it)>0)
						{
							equip($slot[acc1],it);
							needed_accs-=1;
						}
					}
					//get some
					if(my_primestat()==$stat[mysticality])
					{
						cli_execute("pull fishbone bracers  ");
						equip($slot[acc3],$item[fishbone bracers]);
						needed_accs-=1;
					}
					else
					{
						cli_execute("pull fishbone belt   ");
						equip($slot[acc3],$item[fishbone belt]);
						needed_accs-=1;
					}
					//time-twitching toolbelt 15 all stats
					//Talisman of Baio * 2 ~ +42% all stats
					//warbear laser beacon for DBS - 6,9,12 PRISMATIC damage when building momentum
					//Gauntlets of the Blood Moon - 75 hp and 5% stats and 5% items
					while(needed_accs>0)
					{
						cli_execute("pull Mr. Accessory Jr.");
						equip($item[Mr. Accessory Jr.]);
						needed_accs-=1;
					}
							
				}
			}
			if(available_amount($item[wrecked generator])<1 && can_drink() && my_path() != "KOLHS" && my_path() != "Avatar of Jarlsberg" && my_path() != "Heavy Rains")
				pull_if_good($item[wrecked generator]);
			pull_if_good($item[jar of psychoses (The Crackpot Mystic)]);
					
			//14 pulls
	//			pull_if_good($item[v for vivala mask]);
	//			if(storage_amount($item[stinky cheese eye])>0)
	//				pull_if_good($item[stinky cheese eye]);
	//			else if(storage_amount($item[stinky cheese diaper])>0)
	//				pull_if_good($item[stinky cheese diaper]);
	//			else
	//				print("Couldn't find stinky cheese item","red");
			//16 pull 
	//could also pull miniborg destroy o bot for combat
	//		if(get_property("tomeSummons").to_int() > 0 && my_path()!="Way of the Surprising Fist")
	//			use_skill(3 - get_property("tomeSummons").to_int(), $skill[Summon Stickers]);

		}
	}
	
	set_property("_photocopyUsed","false"); //in case the game crashes during ascension and it isn't reset
	cli_execute("mood default");
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
	get_bugged_balaclava();
	visit_toot();
	if(my_turncount() < 1) {
		recovery_settings();
		path_skills(extra_stuff);	// Always learn skills if true
		handle_starting_items();
		special(extra_stuff);		// Only executes if true
	}
	check_breakfast();
	start_quests();
	cli_execute("outfit save Backup");  // Accidently equiping Backup after ascending cases error. No more oops.
	cli_execute("outfit save bumcheekascend");  // Accidently equiping Backup after ascending cases error. No more oops.
	print("Welcome to your new life as a "+myclass+"!", "green");
	set_property("unlockedLocations",""); 
	set_property("ready_for_ascension",false);	
	set_property("rave_open",false);	
	cli_execute("inventory refresh");
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