//simon unmodified
script "missingManuel.ash";
notify turing;

#ver 1.0: Initial Release
#ver 1.1: Improved grouping and area ordering.
#         Better maintainability.
#ver 1.2: Fix acute letters.
#         Hide duplicate Slimes and Eds.
#         Fix Cadaver articles.
#ver 1.3: Version checking.
#         Fix Rene C. Corman.
#         Group Grey Goos.
#         Fix various monsters with repeated names (like protector spirits and clingy pirates).
#ver 1.4: Fix ninja snowmen and add translated vibrato monsters.
#ver 1.5: Move Corman to correct Challenge Path.
#         Reorder some areas.
#         Taco Elves
#ver 1.6: Group Crimbokutown Toy Factory elves.
#         Fix issue with Your Shadow.
#ver 1.7: Do not check if you don't have Monster Manuel.
#         Group Psychoses monsters.
#ver 1.8: Remove extra Ninja Snowman Assassin
#         Patch up the Lonely Construct. BLEARGH.
#         Tidy up psychoses now that most monsters are automatically added to their areas.
#         Add total monster count at the end for easy tracking.
#ver 1.9: Remove extra Dis bosses.
#         Group Avatar of Jarlsberg monsters.
#ver 1.10: Lonely Construct finally has its own factoids.
#          Hide seahorse.
#ver 1.11: Hide Ultra-Rare Pooltergeist.
#ver 1.12: Remove a couple of monsters no longer in mafia.
#ver 1.13: Undo previous change.  Whee!

int[monster] factoids;
boolean[location] blockedAreas;
boolean[monster] blockedMonsters;
boolean[monster] processedMonsters;
int[string] m_factoids;
int[string][string] extraMonsters; //location, monster
string[string] postAreas;
boolean[string][monster] extraAreas;
boolean[string] processedExtraAreas;

string thisver = "1.13";

//CheckVersion by Bale.
string CheckVersion() {
	string soft = "missingManuel";
	string prop = "_version_MissingManuel";
	int thread = 11428;
	int w; string page;
	boolean sameornewer(string local, string server) {
		if (local == server) return true;
		string[int] loc = split_string(local,"\\.");
		string[int] ser = split_string(server,"\\.");
		for i from 0 to max(count(loc)-1,count(ser)-1) {
			if (i+1 > count(loc)) return false;
			if (i+1 > count(ser)) return true;
			if (loc[i].to_int() < ser[i].to_int()) return false;
			if (loc[i].to_int() > ser[i].to_int()) return true;
		}
		return local == server;
	}
	switch(get_property(prop)) {
	case thisver: return "";
	case "":
		print("Checking for updates (running "+soft+" ver. "+thisver+")...");
		page = visit_url("http://kolmafia.us/showthread.php?t="+thread);
		matcher find_ver = create_matcher("<b>"+soft+" (.+?)</b>",page);
		if (!find_ver.find()) {
			print("Unable to load current version info.", "red");
			set_property(prop,thisver);
			return "";
		}
		w=19;
		set_property(prop,find_ver.group(1));
		default:
		if(sameornewer(thisver,get_property(prop))) {
			set_property(prop,thisver);
			print("You have a current version of "+soft+".");
			return "";
		}
		string msg = "<big><font color=red><b>New Version of "+soft+" Available: "+get_property(prop)+"</b></font></big>"+
		"<br><a href='http://kolmafia.us/showthread.php?t="+thread+"' target='_blank'><u>Upgrade from "+thisver+" to "+get_property(prop)+" here!</u></a><br>"+
		"<small>Think you are getting this message in error?  Force a re-check by typing \"set "+prop+" =\" in the CLI.</small><br>";
		find_ver = create_matcher("\\[requires revision (.+?)\\]",page);
		if (find_ver.find() && find_ver.group(1).to_int() > get_revision())
		msg += " (Note: you will also need to <a href='http://builds.kolmafia.us/' target='_blank'>update mafia to r"+find_ver.group(1)+" or higher</a> to use this update.)";
		print_html(msg);
		if(w > 0) wait(w);
		return "<div class='versioninfo'>"+msg+"</div>";
	}
	return "";
}

void loadData()
{
	blockedAreas = $locations[Grim Grimacite Site, The Cannon Museum, CRIMBCO cubicles, Atomic Crimbo Toy Factory, Old Crimbo Town Toy Factory, Simple Tool-Making Cave, Spooky Fright Factory, Crimborg Collective Factory];
	blockedMonsters = $monsters[
		Hockey Elemental, Count Bakula, Infinite Meat Bug, The Master of Thieves, Crazy Bastard, Baiowulf, Hypnotist of Hey Deze, The Temporal Bandit, Knott Slanding, Pooltergeist (Ultra-Rare),
		Cyrus the Virus, The Whole Kingdom,
		Don Crimbo, Edwing Abbidriel, Crys-Rock, Trollipop, The Colollilossus, The Fudge Wizard, The Abominable Fudgeman, Uncle Hobo, Underworld Tree,
		Arc-welding Elfborg, Ribbon-cutting Elfborg, Decal-applying Elfborg, Weapons-assembly Elfborg,
		Gnollish Bodybuilder, Gnollish Sorceress, Giant Pair of Tweezers, 7-Foot Dwarf,
		Hammered Yam Golem, Soused Stuffing Golem, Plastered Can of Cranberry Sauce, Inebriated Tofurkey,
		Striking Stocking-Stuffer Elf, Striking Pencil-Pusher Elf, Striking Middle-Management Elf, Striking Gift-Wrapper Elf, Striking Factory-Worker Elf,
		rock homunculus, rock snake,
		Servant Of Lord Flameface,
		The Darkness (blind),
		Fudge monkey, Fudge oyster, Fudge vulture,
		Amateur Elf, Auteur Elf, Provocateur Elf, Raconteur Elf, Saboteur Elf, Wire-Crossin' Elf, Mob Penguin Caporegime, Mob Penguin Goon, Mob Penguin Kneecapper,
		Deadwood Tree, Fur Tree, Hangman's Tree, Pumpkin Tree,
		Skeleton Invader, Two Skeleton Invaders, Three Skeleton Invaders, Four Skeleton Invaders,
		CDMoyer's Butt, Hotstuff's Butt, Jick's Butt, Mr. Skullhead's Butt, Multi Czar's Butt, Riff's Butt,
		Slime2, Slime3, Slime4, Slime5,
		Ed the Undying (2), Ed the Undying (3), Ed the Undying (4), Ed the Undying (5), Ed the Undying (6), Ed the Undying (7),
		wild seahorse];
		
	extraMonsters["The Upper Chamber"]["Tomb Rat King"] = 0;
	extraMonsters["Hobopolis Town Square"]["Gang of Hobo Muggers"] = 0;
	extraMonsters["Tavern Cellar"]["Bunch of Drunken Rats"] = 0;
	extraMonsters["Tavern Cellar"]["Drunken Rat King"] = 0;
	extraMonsters["The Red Queen's Garden"]["Croqueteer"] = 0;
	extraMonsters["The Outer Compound"]["French Guard turtle"] = 0;
	extraMonsters["Fudge Mountain"]["Swarm of fudgewasps"] = 0;
	extraMonsters["Foyer"]["Vanya's Creature"] = 0;
	extraMonsters["A Well-Groomed Lawn"]["The Landscaper"] = 0;
	extraMonsters["The Brinier Deepers"]["Trophyfish"] = 0;
	extraMonsters["Itznotyerzitz Mine"]["Mountain Man"] = 0;
	extraMonsters["The Jungles of Ancient Loathing"]["Group of cultists"] = 0;
	extraMonsters["The Jungles of Ancient Loathing"]["Ancient Temple Guardian"] = 0;
	extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (cracked)"] = 0;
	extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (mossy)"] = 0;
	extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (rough)"] = 0;
	extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (smooth)"] = 0;
	extraMonsters["F'c'le"]["Clingy Pirate (female)"] = 0;
	extraMonsters["Haunted Bedroom"]["Animated Nightstand (Mahogany) (Noncom)"] = 0;
	extraMonsters["Haunted Bedroom"]["Animated Nightstand (White) (Noncom)"] = 0;
	extraMonsters["Post-War Junkyard"]["Batwinged Gremlin (tool)"] = 0;
	extraMonsters["Post-War Junkyard"]["Erudite Gremlin (tool)"] = 0;
	extraMonsters["Post-War Junkyard"]["Spider Gremlin (tool)"] = 0;
	extraMonsters["Post-War Junkyard"]["Vegetable Gremlin (tool)"] = 0;
	extraMonsters["Ninja Snowmen"]["Ninja Snowman (Mask)"] = 0;
	extraMonsters["El Vibrato Island"]["Bizarre Construct (translated)"] = 0;
	extraMonsters["El Vibrato Island"]["Hulking Construct (translated)"] = 0;
	extraMonsters["El Vibrato Island"]["Industrious Construct (translated)"] = 0;
	extraMonsters["El Vibrato Island"]["Lonely Construct (translated)"] = 0;
	extraMonsters["El Vibrato Island"]["Menacing Construct (translated)"] = 0;
	extraMonsters["El Vibrato Island"]["Towering Construct (translated)"] = 0;
	extraMonsters["1st Floor, Shiawase-Mitsuhama Building"]["Chief Electronic Overseer"] = 0;
	//extraMonsters[""][""] = 0;

	extraAreas["Mist-Covered Icy Peak"] = $monsters[Groar, Panicking Knott Yeti];
	extraAreas["Bees Hate You"] = $monsters[Bee Swarm, Bee Thoven, Beebee Gunners, Beebee King, Beebee Queue, Buzzerker, Moneybee, Mumblebee, Queen Bee];
	extraAreas["Surprising Fist"] = $monsters[Wu Tang the Betrayer];
	extraAreas["Avatar of Boris"] = $monsters[The Avatar of Sneaky Pete, The Luter];
	extraAreas["Bugbear Invasion"] = $monsters[Ancient Unspeakable Bugbear, Anesthesiologist Bugbear, Angry Cavebugbear, Batbugbear, Battlesuit Bugbear Type, Black Ops Bugbear, Bugaboo, Bugbear Captain, Bugbear Drone, Bugbear Mortician, Bugbear Robo-Surgeon, Bugbear Scientist, Creepy Eye-Stalk Tentacle Monster, Grouchy Furry Monster, Hypodermic Bugbear, Liquid Metal Bugbear, N-space Virtual Assistant, Scavenger Bugbear, Spiderbugbear, Trendy Bugbear Chef];
	extraAreas["Zombie Slayer"] = $monsters[Angry Space Marine, Charity the Zombie Hunter, Deputy Nick Soames & Earl, Father McGruber, Father Nikolai Ravonovich, Hank North Photojournalist, Herman East Relivinator, Norville Rogers, Peacannon, Rag-tag band of survivors, Scott the Miner, Special Agent Wallace Burke Corrigan, The Free Man, Wesley J. "Wes" Campbell, Zombie-huntin' feller, Rene C. Corman];
	extraAreas["Avatar of Jarlsberg"] = $monsters[Clancy, The Avatar of Boris];
	extraAreas["Naughty Sorceress' Tower"] = $monsters[Beer Batter, Best-Selling Novelist, Big Meat Golem, Bowling Cricket, Bronze Chef, Collapsed Mineshaft Golem, Concert Pianist, El Diablo, Electron Submarine, Endangered Inflatable White Tiger, Enraged Cow, Fancy Bath Slug, Flaming Samurai, Giant Bee, Giant Desktop Globe, Giant Fried Egg, Ice Cube, Malevolent Crop Circle, Possessed Pipe-Organ, Pretty Fly, Darkness, Fickle Finger of F8, Naughty Sorceress, Naughty Sorceress (2), Naughty Sorceress (3), Tyrannosaurus Tex, Vicious Easel, Your Shadow];
	extraAreas["Mini-Hipster"] = $monsters[angry bassist, blue-haired girl, evil ex-girlfriend, peeved roommate, random scenester];
	extraAreas["Black Crayon"] = $monsters[Black Crayon Beast, Black Crayon Beetle, Black Crayon Constellation, Black Crayon Crimbo Elf, Black Crayon Demon, Black Crayon Elemental, Black Crayon Fish, Black Crayon Flower, Black Crayon Frat Orc, Black Crayon Goblin, Black Crayon Golem, Black Crayon Hippy, Black Crayon Hobo, Black Crayon Man, Black Crayon Manloid, Black Crayon Mer-kin, Black Crayon Penguin, Black Crayon Pirate, Black Crayon Shambling Monstrosity, Black Crayon Slime, Black Crayon Spiraling Shape, Black Crayon Undead Thing];
	extraAreas["BRICKO"] = $monsters[BRICKO Airship, BRICKO Bat, BRICKO Cathedral, BRICKO Elephant, BRICKO Gargantuchicken, BRICKO Octopus, BRICKO Ooze, BRICKO Oyster, BRICKO Python, BRICKO Turtle, BRICKO Vacuum Cleaner];
	extraAreas["Infernal Seals"] = $monsters[broodling seal, Centurion of Sparky, heat seal, hermetic seal, navy seal, Servant of Grodstank, shadow of Black Bubbles, Spawn of Wally, watertight seal, wet seal];
	extraAreas["Nemesis Assassins"] = $monsters[Argarggagarg the Dire Hellseal, B&eacute;arnaise zombie, Evil Spaghetti Cult Assassin, Flock of seagulls, Heimandatz Nacho Golem, Hunting Seal, Jocko Homo, Mariachi Bandolero, Menacing Thug, Mob Penguin hitman, Safari Jack Small-Game Hunter, The Mariachi With No Name, Turtle trapper, Yakisoba the Executioner];
	extraAreas["Nemeses"] = $monsters[Gorgolok the Demonic Hellseal, Gorgolok the Infernal Seal (The Nemesis' Lair), Gorgolok the Infernal Seal (Volcanic Cave), Lumpy the Demonic Sauceblob, Lumpy the Sinister Sauceblob (The Nemesis' Lair), Lumpy the Sinister Sauceblob (Volcanic Cave), Somerset Lopez Demon Mariachi, Somerset Lopez Dread Mariachi (The Nemesis' Lair), Somerset Lopez Dread Mariachi (Volcanic Cave), Stella the Demonic Turtle Poacher, Stella the Turtle Poacher (The Nemesis' Lair), Stella the Turtle Poacher (Volcanic Cave), Demon of New Wave, Spaghetti Demon, Spaghetti Elemental (Inner Sanctum), Spaghetti Elemental (The Nemesis' Lair), Spaghetti Elemental (Volcanic Cave), Spirit of New Wave (The Nemesis' Lair), Spirit of New Wave (Volcanic Cave)];
	extraAreas["Feast of Boris"] = $monsters[Candied Yam Golem, Malevolent Tofurkey, Possessed Can of Cranberry Sauce, Stuffing Golem];
	extraAreas["Día de los Muertos Borrachos"] = $monsters[Novio Cad&aacute;ver, Padre Cad&aacute;ver, Novia Cad&aacute;ver, Persona Inocente Cad&aacute;ver];
	extraAreas["TLAPD"] = $monsters[Ambulatory Pirate, Migratory Pirate, Peripatetic Pirate];
	extraAreas["Bigg's Dig"] = $monsters[reanimated baboon skeleton, reanimated bat skeleton, reanimated demon skeleton, reanimated giant spider skeleton, reanimated serpent skeleton, reanimated wyrm skeleton];
	extraAreas["Rock Event"] = $monsters[clod hopper, rock homunculus, rock snake, rockfish];
	extraAreas["Jacking's Lab"] = $monsters[Professor Jacking];
	extraAreas["The Lower Chamber"] = $monsters[Ed the Undying (1), Ed the Undying (2), Ed the Undying (3), Ed the Undying (4), Ed the Undying (5), Ed the Undying (6), Ed the Undying (7)];
	extraAreas["Altar"] = $monsters[The Thing with No Name];
	extraAreas["CLEESH"] = $monsters[Frog, Newt, Salamander];
	extraAreas["Summoning Chamber"] = $monsters[Lord Spookyraven];
	extraAreas["Grey Goo"] = $monsters[enormous blob of gray goo, largish blob of gray goo, little blob of gray goo];
	extraAreas["Taco Elves"] = $monsters[sign-twirling Crimbo elf, taco-clad Crimbo elf, tacobuilding elf];
	extraAreas["Crimbokutown Toy Factory"] = $monsters[Circuit-Soldering Animelf, Plastic-Extruding Animelf, Quality Control Animelf, Tiny-Screwing Animelf, Toy Assembling Animelf];
	extraAreas["The Gourd"] = $monsters[canned goblin conspirator, Fnord the Unspeakable, goblin conspirator, spider conspirator, spider-goblin conspirator, tin can conspirator, tin spider conspirator];
	//extraAreas[""] = $monsters[];

	postAreas["Huge-A-Ma-tron"] = "Jacking's Lab";
	postAreas["eXtreme Slope"] = "Mist-Covered Icy Peak";
	postAreas["The Middle Chamber"] = "The Lower Chamber";
	postAreas["The Glacier of Jerks"] = "Altar";
	postAreas["Haunted Wine Cellar (automatic)"] = "Summoning Chamber";
	postAreas["Bees Hate You"] = "Surprising Fist";
	postAreas["Surprising Fist"] = "Avatar of Boris";
	postAreas["Avatar of Boris"] = "Bugbear Invasion";
	postAreas["Bugbear Invasion"] = "Zombie Slayer";
	postAreas["Zombie Slayer"] = "Avatar of Jarlsberg";
	postAreas["The Nemesis' Lair"] = "Nemesis Assassins";
	postAreas["Nemesis Assassins"] = "Nemeses";
	postAreas["Sorceress' Hedge Maze"] = "Naughty Sorceress' Tower";
	postAreas["The Old Man's Bathtime Adventures"] = "The Gourd";
	//postAreas[""] = "";

}

boolean fixMonster(string name, string firstFactoid, int facts, string att, string def, string hp)
{
	if (name == "guard turtle" && contains_text(firstFactoid, "red shells"))
	{
		factoids["French Guard Turtle".to_monster()] = facts;
		return true;
	}
	if (name == "(shadow opponent)")
	{
		factoids["Your Shadow".to_monster()] = facts;
		return true;
	}
	if (name == "Hobelf" && contains_text(firstFactoid, "Hobelfs"))
	{
		factoids["Elf Hobo".to_monster()] = facts;
		return true;
	}
	if (name == "Slime Tube Monster")
	{
		factoids["Slime1".to_monster()] = facts;
		return true;
	}
	if (name == "Ed the Undying")
	{
		factoids["Ed the Undying (1)".to_monster()] = facts;
		return true;
	}
	if (name == "mimic")
	{
		if (contains_text(firstFactoid, "Mimic eggs greatly"))
		{
			factoids["Mimic (Bottom 2 Rows)".to_monster()] = facts;
			return true;
		}
		if (contains_text(firstFactoid, "The least pleasant"))
		{
			factoids["Mimic (Middle 2 Rows)".to_monster()] = facts;
			return true;
		}
		if (contains_text(firstFactoid, "The only thing a mimic"))
		{
			factoids["Mimic (Top 2 Rows)".to_monster()] = facts;
			return true;
		}
	}
	if (name == "Orcish Frat Boy")
	{
		if (contains_text(firstFactoid, "uniformly terrible grades"))
		{
			factoids["Orcish Frat Boy (Music Lover)".to_monster()] = facts;
			return true;
		}
		if (contains_text(firstFactoid, "garden variety"))
		{
			factoids["Orcish Frat Boy (Paddler)".to_monster()] = facts;
			return true;
		}
		if (contains_text(firstFactoid, "self esteem of their pledges"))
		{
			factoids["Orcish Frat Boy (Pledge)".to_monster()] = facts;
			return true;
		}
	}
	if (name == "[somebody else's butt]")
	{
		factoids["Somebody else's butt".to_monster()] = facts;
		return true;
	}
	if (name == "Ancient Protector Spirit")
	{
		if(att == "158")
		{
			extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (mossy)"] = facts;
		}
		else if(att == "162")
		{
			extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (smooth)"] = facts;
		}
		else if(att == "160" && def == "140")
		{
			extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (cracked)"] = facts;
		}
		else if(att == "156")
		{
			extraMonsters["Hidden City (automatic)"]["Ancient Protector Spirit (rough)"] = facts;
		}
		else
			return false;
		return true;
	}
	if (name == "Clingy Pirate")
	{
		if (contains_text(firstFactoid, "kind of a hassle"))
		{
			extraMonsters["F'c'le"]["Clingy Pirate (female)"] = facts;
			return true;
		}
	}
	if (name == "animated nightstand")
	{
		if (contains_text(firstFactoid, "made of teak"))
		{
			extraMonsters["Haunted Bedroom"]["Animated Nightstand (Mahogany) (Noncom)"] = facts;
			return true;
		}
		if (contains_text(firstFactoid, "disassembled with an allen wrench"))
		{
			extraMonsters["Haunted Bedroom"]["Animated Nightstand (White) (Noncom)"] = facts;
			return true;
		}
	}
	if (name == "batwinged gremlin" && contains_text(firstFactoid, "Batwinged gremlins"))
	{
		extraMonsters["Post-War Junkyard"]["Batwinged Gremlin (tool)"] = facts;
		return true;
	}
	if (name == "erudite gremlin" && contains_text(firstFactoid, "erudite gremlin has"))
	{
		extraMonsters["Post-War Junkyard"]["Erudite Gremlin (tool)"] = facts;
		return true;
	}
	if (name == "spider gremlin" && contains_text(firstFactoid, "The spider DNA"))
	{
		extraMonsters["Post-War Junkyard"]["Spider Gremlin (tool)"] = facts;
		return true;
	}
	if (name == "vegetable gremlin" && contains_text(firstFactoid, "look at the abs"))
	{
		extraMonsters["Post-War Junkyard"]["Vegetable Gremlin (tool)"] = facts;
		return true;
	}
	if (name == "ninja snowman" && contains_text(firstFactoid, "modified form of judo"))
	{
		extraMonsters["Ninja Snowmen"]["Ninja Snowman (Mask)"] = facts;
		return true;
	}
	if (name == "bizarre construct" && contains_text(firstFactoid, "this one is being singled out"))
	{
		extraMonsters["El Vibrato Island"]["Bizarre Construct (translated)"] = facts;
		return true;
	}
	if (name == "hulking construct" && contains_text(firstFactoid, "plain mayonnaise sandwich"))
	{
		extraMonsters["El Vibrato Island"]["Hulking Construct (translated)"] = facts;
		return true;
	}
	if (name == "industrious construct" && contains_text(firstFactoid, "rudimentary artificial intelligence"))
	{
		extraMonsters["El Vibrato Island"]["Industrious Construct (translated)"] = facts;
		return true;
	}
	if (name == "lonely construct" && contains_text(firstFactoid, "You shouldn't wonder why a robot would feel lonely"))
	{
		extraMonsters["El Vibrato Island"]["Lonely Construct (translated)"] = facts;
		return true;
	}
	if (name == "menacing construct" && contains_text(firstFactoid, "constructs play in a band"))
	{
		extraMonsters["El Vibrato Island"]["Menacing Construct (translated)"] = facts;
		return true;
	}
	if (name == "towering construct" && contains_text(firstFactoid, "clamp is capable of producing"))
	{
		extraMonsters["El Vibrato Island"]["Towering Construct (translated)"] = facts;
		return true;
	}
	return false;
}

void parseManuel(string URL)
{
	string page = visit_url(URL);
	matcher entry_matcher = create_matcher( "<table width=95%>(.*?)</table>", page );
	while ( entry_matcher.find() )
	{
		string entry = entry_matcher.group( 1 );

		matcher image_matcher = create_matcher( "/.*images/(.*?.gif) width=([(100)(60)])", entry );
		if ( !image_matcher.find() )
			continue;

		string image = image_matcher.group( 1 );

		matcher data_matcher = create_matcher( "<font size=.2>(.*?)</font>", entry );
		if ( !data_matcher.find() )
			continue;
		string Atk = data_matcher.group( 1 );
		if ( !data_matcher.find() )
			continue;
		string name = data_matcher.group( 1 );
		if ( !data_matcher.find() )
			continue;
		string Def = data_matcher.group( 1 );
		if ( !data_matcher.find() )
			continue;
		string HP = data_matcher.group( 1 );

		matcher fact_matcher = create_matcher( "(<li>[^<]*)", entry );
		int facts = 0;
		string firstFactoid = "";
		if ( fact_matcher.find() )
		{
			facts = 1;
			firstFactoid = fact_matcher.group( 1 );
		}
		if ( fact_matcher.find() ) facts = 2;
		if ( fact_matcher.find() ) facts = 3;
		
		if (!fixMonster(name, firstFactoid, facts, Atk, Def, HP))
		{
			monster mon = name.to_monster();
			if ( mon == $monster[ none ] )
				mon = image_to_monster( image );

			if (mon != $monster[none])
			{
				factoids[mon] = facts;
			}
			else
			{
				m_factoids[name] = facts;
			}
		}
	}
}

void parseall()
{
	print("A");
	parseManuel("questlog.php?which=6&vl=a");
	print("B");
	parseManuel("questlog.php?which=6&vl=b");
	print("C");
	parseManuel("questlog.php?which=6&vl=c");
	print("D");
	parseManuel("questlog.php?which=6&vl=d");
	print("E");
	parseManuel("questlog.php?which=6&vl=e");
	print("F");
	parseManuel("questlog.php?which=6&vl=f");
	print("G");
	parseManuel("questlog.php?which=6&vl=g");
	print("H");
	parseManuel("questlog.php?which=6&vl=h");
	print("I");
	parseManuel("questlog.php?which=6&vl=i");
	print("J");
	parseManuel("questlog.php?which=6&vl=j");
	print("K");
	parseManuel("questlog.php?which=6&vl=k");
	print("L");
	parseManuel("questlog.php?which=6&vl=l");
	print("M");
	parseManuel("questlog.php?which=6&vl=m");
	print("N");
	parseManuel("questlog.php?which=6&vl=n");
	print("O");
	parseManuel("questlog.php?which=6&vl=o");
	print("P");
	parseManuel("questlog.php?which=6&vl=p");
	print("Q");
	parseManuel("questlog.php?which=6&vl=q");
	print("R");
	parseManuel("questlog.php?which=6&vl=r");
	print("S");
	parseManuel("questlog.php?which=6&vl=s");
	print("T");
	parseManuel("questlog.php?which=6&vl=t");
	print("U");
	parseManuel("questlog.php?which=6&vl=u");
	print("V");
	parseManuel("questlog.php?which=6&vl=v");
	print("W");
	parseManuel("questlog.php?which=6&vl=w");
	print("X");
	parseManuel("questlog.php?which=6&vl=x");
	print("Y");
	parseManuel("questlog.php?which=6&vl=y");
	print("Z");
	parseManuel("questlog.php?which=6&vl=z");
	print("Now I know my ABCs!");
	parseManuel("questlog.php?which=6&vl=-");
}

int three, two, one, zero;

boolean printAll = false;

string GetLocName(string locName)
{
	if (locName == "Foyer") return "Vanya's Castle";
	if (locName == "A Well-Groomed Lawn") return "Landscaper's Map";
	if (locName == "Post-War Junkyard") return "Junkyard";
	if (locName == "1st Floor, Shiawase-Mitsuhama Building") return "Shiawase-Mitsuhama Building";
	return locName;
}

string GetMonName(string monName)
{
	if (monName == "Ed the Undying (1)") return "Ed the Undying";
	if (monName == "Slime1") return "Slime Tube Monster";
	if (monName == "Ancient Protector Spirit") return "Ancient Protector Spirit (dagger)";
	if (monName == "Clingy Pirate") return "Clingy Pirate (male)";
	if (monName == "Ninja Snowman (Hilt/Mask)") return "Ninja Snowman (Hilt)";
	return monName;
}

void printLocation(string locName, boolean[monster] mon)
{
	int q = 1;
	foreach m in mon
	{
		if (!(processedMonsters contains m || blockedMonsters contains m))
		{
			processedMonsters[m] = true;
			int missed = 0;
			if (factoids contains m) {
				missed = 3 - factoids[m];
			} else {
				missed = 3;
			}
			if (printAll || missed > 0)
			{
				if (q > 0)
				{
					print("[" + GetLocName(locName) + "]");
				}
			if (missed > 2)
			{
				print(GetMonName(m) + " (" + missed + ")", "red");
			}
			else
			{
				print(GetMonName(m) + " (" + missed + ")");
			}
				q = 0;
			}
		if (missed == 0)
			three = three + 1;
		if (missed == 1)
			two = two + 1;
		if (missed == 2)
			one = one + 1;
		if (missed == 3)
			zero = zero + 1;
		missed = 0;
		}
	}
	if (q < 1)
	{
		print("=================================");
	}
	if (postAreas contains locName)
	{
		string postArea = postAreas[locName];
		printLocation(postArea, extraAreas[postArea]);
		processedExtraAreas[postArea] = true;
	}
}

void PrintExtraMonsters(location loc, int p)
{
	int origP = p;
	string name = loc;
	int[string] monsters = extraMonsters[name];
	foreach m in monsters
	{
		int missed = 0;
		monster mon = m.to_monster();
		string mName = mon;
		if (mName == "none")
		{
			missed = 3 - monsters[m];
		}
		else
		{
			processedMonsters[mon] = true;
			if (factoids contains mon) {
				missed = 3 - factoids[mon];
			} else {
				missed = 3;
			}
		}
		if (printAll || missed > 0)
		{
			if (p > 0)
			{
				print("[" + GetLocName(loc) + "]");
			}
			if (missed > 2)
			{
				print(GetMonName(m) + " (" + missed + ")", "red");
			}
			else
			{
				print(GetMonName(m) + " (" + missed + ")");
			}
			p = 0;
		}
		if (missed == 0)
			three = three + 1;
		if (missed == 1)
			two = two + 1;
		if (missed == 2)
			one = one + 1;
		if (missed == 3)
			zero = zero + 1;
	}
	if (p < 1 && origP > 0)
	{
		print("=================================");
	}
	
}

void CheckManuel ()
{
	CheckVersion();
	printAll = user_confirm("Display full list?");

	loadData();

	print("Checking Monster Manuel...", "blue");
	parseall();
	print("Done checking Monster Manuel!", "blue");

	print("=================================");
	
	foreach loc in $locations[]
	{
		monster[int] mon_list = get_monsters(loc);
		if (blockedAreas contains loc)
		{
			int i;
			foreach i in mon_list
			{
				string blockedMonName = mon_list[i];
				if (blockedMonName == "Rene C. Corman")
				{
					//This monster shows up in another area that isn't blocked.
				}
				else
				{
					processedMonsters[mon_list[i]] = true;
				}
			}
		}
		else
		{
			int i, missed = 0;
			string txt = "";
			int p = 1;
			foreach i in mon_list
			{
				if (!(processedMonsters contains mon_list[i] || blockedMonsters contains mon_list[i]))
				{
					processedMonsters[mon_list[i]] = true;
					if (factoids contains mon_list[i]) {
						missed = 3 - factoids[mon_list[i]];
					} else {
						missed = 3;
					}
					if (printAll || missed > 0)
					{
						if (p > 0)
						{
							print("[" + GetLocName(loc) + "]");
						}
						if (missed > 2)
						{
							print(GetMonName(mon_list[i]) + " (" + missed + ")", "red");
						}
						else
						{
							print(GetMonName(mon_list[i]) + " (" + missed + ")");
						}
						p = 0;
					}
					if (missed == 0)
						three = three + 1;
					if (missed == 1)
						two = two + 1;
					if (missed == 2)
						one = one + 1;
					if (missed == 3)
						zero = zero + 1;
					missed = 0;
				}
			}
			PrintExtraMonsters(loc, p);
			if (p < 1)
			{
				print("=================================");
			}
		}
		string locName = loc;
		if (postAreas contains locName)
		{
			string postArea = postAreas[locName];
			printLocation(postArea, extraAreas[postArea]);
			processedExtraAreas[postArea] = true;
		}
	}
	
	printLocation("Bees Hate You", extraAreas["Bees Hate You"]);

	foreach area in extraAreas
	{
		if (!(processedExtraAreas contains area))
		{
			printLocation(area, extraAreas[area]);
		}
	}
	
	printLocation("Unsorted", $monsters[]);
	
	foreach monst in m_factoids
	{
		print("Unrecognized: " + monst + " (" + (3 - m_factoids[monst]) + ")");
	}
	
	print("");
	print("You have casually researched " + one + " creatures.");
	print("You have thoroughly researched " + two + " creatures.");
	print("You have exhaustively researched " + three + " creatures.");
	print("You have not researched " + zero + " creatures.");
	print("Total creatures: " + (one + two + three + zero) + ".");
	print("Done.", "blue");
}


void main ()
{
	string page = visit_url("questlog.php?which=6");
	if (contains_text(page, "[Monster Manuel]"))
	{
		CheckManuel();
	}
	else
	{
		print("Thank you, Mario, but your Monster Manuel is in another castle!", "blue");
		print("Perhaps you should consider getting one?");
		print("");
		print("=================================");
		print("[Every Single Area]");
		print("NOTHING!  ABSOLUTELY NOTHING!", "red");
		print("=================================");
		print("");
		print("You have casually researched 0 creatures.");
		print("You have thoroughly researched 0 creatures.");
		print("You have exhaustively researched 0 creatures.");
		print("You have not researched ANY creatures.");
		print("Done.", "blue");
	}
}
