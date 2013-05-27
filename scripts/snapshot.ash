/*
	bumcheekcity's snapshot.ash v2.7

	This script takes a snapshot of your character, level, stats, everything, and prints it in wikicode.
	Mad props to Terrabull and Zarqon for being cool. 

	Changelog:
	0.1 - Initial Implementation. Only Hobopolis done yet. 
	0.2 - Completed the Familiars check, including the 90/100% check.
	0.3 - Added Slime Tube, Tattoos. <Added Stocking Mimic as Familiar>
	0.4 - Added Skill check.
	0.5 - Fixed various tattoos, fixed tome skills, sped up script.
	0.6 - Trophies added. Hobo Code added. Various small fixes.
	0.7 - Fixed misspelt Hobo Codes. Added option for no description on trophies, war medals. Fixed tattoos, display case bug. <Added Crimbo 2009 tattoo, familiar>
	0.8 - Changed script massively. Few various fixes and tweaks on top of that.
	0.9 - Changed script massively again. Now it's on my server. 
	1.0 - Minor fixes. Released script.
	1.1 - If a password is set, then require the password to update your snapshot. Make tattoos use the "/" and ".gif" part of the gifname to make sure it
		matches the whole string. Add Slime skill strength checking. Fix familiar 90/100% run checking for those with a space in their username. Check for telescope strength.
		Ascension reward checking. 
	1.2 - Discoveries. Mr. Items. 
	1.3 - Bugfixing. Add multi-use discoveries. 
	1.4 - Bugfixing. Fixed the store/DC blue text. 
	2.0 - No longer need your password to update. "Misc. Rare Items" check. Frostys arm now counts in chefstaff form. Maps moved to my server. 
	2.1 - Added Consumption Records.
	2.2 - Added checking of the Arcade Games, Uncle Hobo Stuff, Demon Names and Mr. Store Garden things. 
	2.3 - Add pen pal support. 
		- Improve checking of the familiars% runs to use the kol server and only count runs to the king.
		- Add karma tracking.
		- Abort if trendy.
	2.4 - Abort if AoB and Bugbear Invasion.
		- Fixed telescope error when in Bugbear Invasion Path (RNG-HeHateMe)
		- Fix for Bugbear Invasion. 
	2.5 - Check the second page of KoLDB for those people who ascend too much and have 100% runs on earlier pages. 
		- Match discoveries with upper and lower case.
		- Search for and warn about banned paths. 
		- Support for Monster Hunting using the Manuel.
		- Support for Zombie/Boris/etc. Points
	2.6 - Fix bug where 100% runs wouldn't show up.
	2.7 - Remove the one-click crafting and inventory images debug information. This is not needed.
		- Change to fix to look at kolmafia.co.uk only.
*/

script "snapshot.ash";
notify bumcheekcity;

	if (index_of(visit_url("http://kolmafia.us/showthread.php?t=3001"), "2.7</b>") == -1)
	{
		print("There is a new version available - go download the next version of snapshot.ash at http://kolmafia.us/showthread.php?t=3001!", "red");
	}
	boolean debug = true;
	void debug(string s)
	{
		if (debug) { print(s, "blue"); }
	}

	record ItemImage
	{
		string itemname;
		string gifname;
		string a;
		string b;
		string c;
		string d;
		string e;
		string f;
	};

	boolean description = true, hasallitems = false, hasdisplay  = false, hashobotattoo = false, hasstore = false;
	int a, d, itemAmount, s, s_si, s_sh, s_sy;
	ItemImage [int] ascrewards, booze, concocktail, confood, conjewel, conmeat, conmisc, consmith, coolitems, familiars, food, hobopolis, rogueprogram, manuel, mritems, skills, slimetube, tattoos, trophies, warmedals;
	string html, htmlkoldb, htmlscope, ret;

int i_a(string name) {
	item i = to_item(name);
	a = item_amount(i) + closet_amount(i) + equipped_amount(i) + storage_amount(i);
	d = 0;
	s = 0;
	if (hasdisplay) { d = display_amount(i); }
	if (hasstore)   { s = shop_amount(i); }
	
	//Make a check for familiar equipment NOT equipped on the current familiar. 
	foreach fam in $familiars[]
	{
		if (have_familiar(fam) && fam != my_familiar())
		{
			if (name == to_string(familiar_equipped_equipment(fam)) && name != "none")
			{
				a = a + 1;
			}
		}
	}
	
	return a + d + s;
}

boolean load_current_map(string fname, ItemImage[int] map) 
{
	string domain = "http://kolmafia.co.uk/";
	string curr = visit_url(domain + "index.php?name=" + fname);
	file_to_map(fname+".txt", map);
	
	//If the map is empty or the file doesn't need updating
	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) 
	{
		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) 
		{
			return false;
		}
		
		map_to_file(map, fname+".txt");
		set_property(fname+".txt", curr);
		print("..."+fname+".txt updated.");
	}
	
	return true;
}

void hasConsumed(string name, string html)
{
	if (index_of(to_lower_case(html), ">"+to_lower_case(name)+"</a>") > 0)
	{
		ret = ret + "|1";
	} else {
		ret = ret + "|";
	}
}

void hasItem(string name)
{
	if (i_a(name) > 0)
	{
		ret = ret + "|1";
	} else {
		ret = ret + "|";
	}
}

void hasItem(string name, string amount)
{
	if (i_a(name) > 0)
	{
		ret = ret + "|"+i_a(name);
	} else {
		ret = ret + "|";
	}
}

void isIn(string name, string html)
{
	if (length(name) > 7)
	{
		if (index_of(name, "_thumb") >= length(name) - 7)
		{
			name = substring(name, 0, length(name) - 7);
		}
	}
	
	if (index_of(html, name) != -1)
	{
		ret = ret + "|1";
	} else {
		ret = ret + "|";
	}
}

void regCheck(string checkthis, string html)
{
	checkthis = replace_string(checkthis, "+", "\\+");
	checkthis = replace_string(checkthis, "(0)", "\\(([0-9]+)\\)");
	checkthis = replace_string(checkthis, "</b>", "(</a>){0,1}</b>");
	checkthis = replace_string(checkthis, "</b> <font", "</b>(\\s){0,1}<font");
	checkthis = replace_string(checkthis, "<font size=1>", "<font size=1>(?:<font size=2>\\[<a href=\"craft.php\\?mode=\\w+&a=\\d+&b=\\d+\">\\w+</a>\\]</font>)?");
	
	matcher reg = create_matcher(checkthis, html);
	if (reg.find())
	{
		ret = ret + "|1";
		debug("YES --- " + checkthis);
	} else {
		ret = ret + "|";
		debug("NO --- " + checkthis);
	}
}

void isInDisco(string name, string html, string a)
{
	if (a != "none")
	{
		regCheck(a, html);
	} else {
		if (index_of(html, ">"+name+"<") != -1)
		{
			ret = ret + "|1";
		} else {
			ret = ret + "|";
		}
	}
}

//forceReturn basically stops the script trying to check for a lowercase version of the monster. 
int manuelTimes(string monsterName, string questmanpage, string firstFact, boolean forceReturn) {
	string montag="<td rowspan=4 valign=top class=small><b><font size=\+2>";
	int istart=0;
	int iend=0;
	string ssub="";
	int rcount=0;
	
	string searchForThis = "";
	//If we specify a first fact then we should search for the monster name AND fact, else just the monster name. 
	if (firstFact != "") {
		searchForThis = montag+monsterName+"</font></b><ul><li>"+firstFact;
	} else {
		searchForThis = montag+monsterName;
	}

		if (contains_text(questmanpage, searchForThis))
		{
			istart = index_of(questmanpage,searchForThis,iend);
			iend = index_of(questmanpage,montag,istart+2);
			if (istart == -1) { istart = 1; }
			if (iend == -1) { iend = length(questmanpage); }
			ssub = substring(questmanpage,istart,iend);
			matcher ii = create_matcher("(<li>)",ssub);
			rcount=0;
			while (find(ii)) { rcount += 1; }		
		}

		if (forceReturn) return rcount;

		if (rcount == 0) {
			//print("trying lowercase");
			return manuelTimes(to_lower_case(monsterName), questmanpage, firstFact, true);
		}
	return rcount;
}
int manuelTimes(string monsterName, string questmanpage, string firstFact) { return manuelTimes(monsterName, questmanpage, firstFact, false); }

void isInManuel(string monstername, string html, string firstFact) {
	ret = ret + "|" + manuelTimes(monstername, html, firstFact);
}

void famCheck(string name, string gifname, string hatchling)
{
	if (index_of(html, name) > 0)
	{
		if (index_of(htmlkoldb, "alt=\""+name+" (100%)") > 0)
		{
			//100% Run
			ret = ret + "|3";
		} else if (index_of(htmlkoldb, "alt=\""+name+" (9") > 0) {
			//90% Tourguide Run
			ret = ret + "|4";
		} else {
			//Have Familiar
			ret = ret + "|1";
		}
	} else if (i_a(hatchling) > 0) {
		//Have Hatchling
		ret = ret + "|2";
	} else {
		//Dont have familiar at all.
		ret = ret + "|";
	}
}

void isInSkill(string name, string html, string overwrite)
{
	if (overwrite == "none") { overwrite = ""; }
	if (index_of(html, ">"+name+"</a> (<b>HP</b>)") != -1)
	{
		if (name == "Slimy Shoulders")
		{
			ret = ret + "|1-" + s_sh;
		} else if (name == "Slimy Sinews") {
			ret = ret + "|1-" + s_si;
		} else if (name == "Slimy Synapses") {
			ret = ret + "|1-" + s_sy;
		} else {
			ret = ret + "|1";
		}
	} else if (length(overwrite) > 0 && index_of(html, overwrite) > 0) {
		ret = ret + "|1";
	} else if (index_of(html, ">"+name+"</a> (P)") != -1) {
		if (name == "Slimy Shoulders")
		{
			ret = ret + "|2-" + s_sh;
		} else if (name == "Slimy Sinews") {
			ret = ret + "|2-" + s_si;
		} else if (name == "Slimy Synapses") {
			ret = ret + "|2-" + s_sy;
		} else {
			ret = ret + "|2";
		}
	} else {
		ret = ret + "|";
	}
}

void tattooCheck(string outfit, string gif, string i1, string i2, string i3, string i4, string i5)
{
	hasallitems = false;
	if (last_index_of(html, "/"+gif+".gif") > 0)
	{
		ret = ret + "|1";
	} else {
		debug(outfit+"---"+gif+"---"+i1+"("+i_a(i1)+")"+i2+"("+i_a(i2)+")"+i3+"("+i_a(i3)+")"+i4+"("+i_a(i4)+")"+i5+"("+i_a(i5)+")");
		if (i5 != "none")
		{
			if (i_a(i1) > 0 && i_a(i2) > 0 && i_a(i3) > 0 && i_a(i4) > 0 && i_a(i5) > 0) { hasallitems = true; }
		} else if (i4 != "none") {
			if (i_a(i1) > 0 && i_a(i2) > 0 && i_a(i3) > 0 && i_a(i4) > 0) { hasallitems = true; }
		} else if (i3 != "none") {
			if (i_a(i1) > 0 && i_a(i2) > 0 && i_a(i3) > 0) { hasallitems = true; }
		} else {
			if (i_a(i1) > 0 && i_a(i2) > 0) { hasallitems = true; }
		}
	
		if (hasallitems)
		{
			ret = ret + "|2";
		} else {
			ret = ret + "|";
		}
	}
	
	//This is a terrible way of doing this, but the hobo tattoo goes after the salad one. 
	if (gif == "saladtat")
	{
		if (index_of(html, "hobotat19") != -1)
		{
			ret = ret + "|19";
		} else {
			for i from 18 to 1
			{
				if (index_of(html, "hobotat"+i) != -1 && !hashobotattoo)
				{
					ret = ret + "|"+i;
					hashobotattoo = true;
				}
			}
			if (!hashobotattoo)
			{
				ret = ret + "|";
			}
		}
	}
}

string visit_discoveries(string url) {
    matcher reg = create_matcher("<font size=2>.*?</font>", visit_url(url));
    return replace_all(reg, "");
}

void mainSnapshot() {
	string bannedpaths = visit_url("http://kolmafia.co.uk/snapshot_bannedpaths.txt");
	if (contains_text(bannedpaths, my_path()) && my_path() != "") {
		if (!user_confirm("This script should not be run while you are in the path you are in. It may blank out some of your skills, telescope, bookshelf or some other aspect of your profile until you next run it outside of the current path restrictions. Are you sure you want to run it (not recommended)?")) {
			abort("OK");
		}
	}
	print("This is bumcheekcity's snapshot maker! This script takes a snapshot of your character and uploads it to my server at bumcheekcity.com", "green");
	print("Updating map files...", "olive");
	load_current_map("snapshot_skills", skills);
	load_current_map("snapshot_tattoos", tattoos);
	load_current_map("snapshot_trophies", trophies);
	load_current_map("snapshot_familiars", familiars);
	load_current_map("snapshot_hobopolis", hobopolis);
	load_current_map("snapshot_slimetube", slimetube);
	load_current_map("snapshot_warmedals", warmedals);
	load_current_map("snapshot_ascensionrewards", ascrewards);
	load_current_map("snapshot_dis_cocktail", concocktail);
	load_current_map("snapshot_dis_food", confood);
	load_current_map("snapshot_dis_jewel", conjewel);
	load_current_map("snapshot_dis_meat", conmeat);
	load_current_map("snapshot_dis_smith", consmith);
	load_current_map("snapshot_dis_misc", conmisc);
	load_current_map("snapshot_mritems", mritems);
	load_current_map("snapshot_coolitems", coolitems);
	load_current_map("snapshot_con_food", food);
	load_current_map("snapshot_con_booze", booze);
	load_current_map("snapshot_rogueprogram", rogueprogram);
	load_current_map("snapshot_manuel", manuel);
	
	print("Checking skills...", "olive");
	ret = "&skills=";
	html = visit_url("charsheet.php") + visit_url("campground.php?action=bookshelf");
	foreach x in skills { isInSkill(skills[x].itemname, html, skills[x].a); }
	print("Checking tattoos...", "olive");
	html = visit_url("account_tattoos.php");
	ret = ret + "&tattoos=";
	foreach x in tattoos { tattooCheck(tattoos[x].itemname, tattoos[x].gifname, , tattoos[x].a, tattoos[x].b, tattoos[x].c, tattoos[x].d, tattoos[x].e); }
	
	print("Checking trophies...", "olive");
	html = visit_url("trophies.php");
	ret = ret + "&trophies=";
	foreach x in trophies { isIn(trophies[x].itemname, html); }
	
	print("Checking familiars...", "olive");
	html = visit_url("familiarnames.php");
	//htmlkoldb = visit_url("ascensionhistory.php?back=self&who="+my_id(), false);
	htmlkoldb = visit_url(" ascensionhistory.php?back=self&who=" +my_id(), false) + visit_url(" ascensionhistory.php?back=self&prens13=1&who=" +my_id(), false);
	ret = ret + "&familiars=";
	foreach x in familiars { famCheck(familiars[x].itemname, familiars[x].gifname, familiars[x].a); }
	
	print("Checking hobopolis loot and hobo codes...", "olive");
	html = visit_url("questlog.php?which=5");
	ret = ret + "&hobopolis=";
	foreach x in hobopolis {
		if (x >= 44 && x <= 63) {
			isIn(hobopolis[x].itemname, html);
		} else {
			hasItem(hobopolis[x].itemname);
		}
	}
	
	print("Checking Slime Tube loot...", "olive");
	ret = ret + "&slimetube=";
	foreach x in slimetube { hasItem(slimetube[x].itemname); }
	
	print("Checking War Medals...", "olive");
	ret = ret + "&warmedals=";
	foreach x in warmedals {
		hasItem(warmedals[x].itemname, "amount"); }
	if (in_bad_moon()) {
		ret = ret + "&scope=9";
	} else {
		print("Checking for Telescope", "olive");
		ret = ret + "&scope=";
		htmlscope = visit_url("campground.php?action=telescopelow");
		if (index_of(htmlscope, "You peer into the eyepiece of the telescope") != -1 ) {
			htmlscope = substring(htmlscope, index_of(htmlscope, "You peer into the eyepiece of the telescope"));
			htmlscope = substring(htmlscope, 0, index_of(htmlscope, "</td>"));
			if (index_of(htmlscope, "sixth and final window") > 0)
			{
				ret = ret + "7";
			} else if (index_of(htmlscope, "see a fifth window") > 0) {
				ret = ret + "6";
			} else if (index_of(htmlscope, "see another window") > 0) {
				ret = ret + "5";
			} else if (index_of(htmlscope, "see a third window") > 0) {
				ret = ret + "4";
			} else if (index_of(htmlscope, "see a second window") > 0) {
				ret = ret + "3";
			} else if (index_of(htmlscope, "raise the telescope a little higher") > 0) {
				ret = ret + "2";
			} else if (index_of(htmlscope, "a strange ring of mountains") > 0) {
				ret = ret + "1";
			}
		}
	}
	
	print("Checking for Ascension Rewards", "olive");
	ret = ret + "&ascreward=";
	foreach x in ascrewards { hasItem(ascrewards[x].itemname, "amount"); }
	
	print("Checking for Discoveries [Cocktail]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=cocktail");
	ret = ret + "&concocktail=";
	foreach x in concocktail { isInDisco(concocktail[x].itemname, html, concocktail[x].gifname); }
	
	print("Checking for Discoveries [Food]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=cook");
	ret = ret + "&confood=";
	foreach x in confood { isInDisco(confood[x].itemname, html, confood[x].gifname); }
	
	print("Checking for Discoveries [Jewelery]", "olive");
	html = visit_url("craft.php?mode=discoveries&what=jewelry");
	ret = ret + "&conjewel=";
	foreach x in conjewel { isInDisco(conjewel[x].itemname, html, conjewel[x].gifname); }
	
	print("Checking for Discoveries [Meat Pasting]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=combine");
	ret = ret + "&conmeat=";
	foreach x in conmeat { isInDisco(conmeat[x].itemname, html, conmeat[x].gifname); }
	
	print("Checking for Discoveries [Meatsmithing]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=smith");
	ret = ret + "&consmith=";
	foreach x in consmith { isInDisco(consmith[x].itemname, html, consmith[x].gifname); }
	
	print("Checking for Discoveries [Misc]", "olive");
	html = visit_url("craft.php?mode=discoveries&what=multi");
	ret = ret + "&conmisc=";
	foreach x in conmisc { isInDisco(conmisc[x].itemname, html, conmisc[x].gifname); }
	
	print("Checking for Mr. Items", "olive");
	html = visit_url("familiarnames.php") + visit_url("campground.php?action=bookshelf");
	ret = ret + "&mritems=";
	foreach x in mritems {
		itemAmount = 0;
		switch (mritems[x].itemname) {	
			//Bind-on-use Items
			case "b" :
				itemAmount = i_a(to_item(mritems[x].gifname)) + i_a(to_item(mritems[x].a));
			break;
			//Familiar
			case "f" :
				if (index_of(html, mritems[x].a) > 0) { itemAmount = 1; }
				itemAmount = itemAmount + i_a(to_item(mritems[x].gifname));
			break;
			//Garden Stuff
			case "g" :
				if (index_of(html, mritems[x].b) > 0) { itemAmount = 1; }
				itemAmount = itemAmount + i_a(to_item(mritems[x].gifname)) + i_a(to_item(mritems[x].a));
			break;
			//Item
			case "i" :
				itemAmount = i_a(to_item(mritems[x].gifname));
			break;
			//Foldable
			case "o" :
				itemAmount = i_a(to_item(mritems[x].gifname)) + i_a(to_item(mritems[x].a)) + i_a(to_item(mritems[x].b)) + i_a(to_item(mritems[x].c)) + i_a(to_item(mritems[x].d));
				if (mritems[x].e != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].e)); }
				if (mritems[x].f != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].f)); }
			break;
			//Pen Pal Kit
			case "p" :
				if (contains_text(visit_url("messages.php"), ">[Pen Pal]</a>")) {
					itemAmount = 1;
				}
			break;
			//Tome, Libram, Grimore
			case "t" :
				if (index_of(html, mritems[x].a) > 0) { itemAmount = 1; }
				itemAmount = itemAmount + i_a(to_item(mritems[x].gifname));
			break;
		}
		ret = ret + "|" + itemAmount;
	}
	
	print("Checking for Cool Items", "olive");
	ret = ret + "&coolitems=";
	foreach x in coolitems { hasItem(coolitems[x].itemname, "amount"); }
	
	print("Checking for Consumed Food", "olive");
	html = to_lower_case(visit_url("showconsumption.php"));
	ret = ret + "&food=";
	foreach x in food { hasConsumed(food[x].itemname, html);  }
	
	print("Checking for Consumed Booze", "olive");
	ret = ret + "&booze=";
	foreach x in booze { hasConsumed(booze[x].itemname, html); }
	
	print("Checking for Rogue Program Stuff", "olive");
	if (visit_url("town_wrong.php").contains_text("arcade")) {  
		html = to_lower_case(visit_url("arcade.php?ticketcounter=1"));
		ret = ret + "&arcadegames=";
		foreach x in rogueprogram {
			if (i_a(rogueprogram[x].itemname) > 0) {
				ret = ret + "|1";
			} else if (index_of(html, rogueprogram[x].itemname) > 0) {
				ret = ret + "|2";
			} else {
				ret = ret + "|";
			}
		}
	}
	
	print("Checking Demon Names", "olive");
	string demon = visit_url("http://kolmafia.co.uk/snapshot_demon.txt").to_string();
	int i = 1, numdemon = demon.to_int();
	ret = ret + "&demonnames=";
	while (i <= numdemon) {
		ret = ret + get_property("demonName"+i) + "|";
		print(i+get_property("demonName"+i));
		i = i + 1;
	}
	
	print("Checking Karma", "olive");
	string karma = visit_url("questlog.php?which=3");
	matcher m = create_matcher("Your current Karmic balance is ([0-9,]+)", karma);
	string k = "";
	while (find(m)) {
		k = group(m, 1);
	}
	print("You have "+k+" karma");
	ret = ret + "&karma="+k;

	print("Checking Path Points", "olive");
	ret = ret + "&paths=";
	string paths = visit_url("http://kolmafia.co.uk/snapshot_paths.txt").to_string();
	string[int] pathsList = split_string(paths);
	foreach key in pathsList {
		ret = ret + get_property(pathsList[key])+"|";
	}
	
	if (contains_text(visit_url("questlog.php"), "Monster Manuel")) {
		//Prepare the big HTML file. 
		print("Starting to Check the Manuel HTML Pages...", "olive");
		string manuelHTML;
		manuelHTML = visit_url("questlog.php?which=6&vl=a") +
				visit_url("questlog.php?which=6&vl=b") +
				visit_url("questlog.php?which=6&vl=c") +
				visit_url("questlog.php?which=6&vl=d") +
				visit_url("questlog.php?which=6&vl=e") +
				visit_url("questlog.php?which=6&vl=f") +
				visit_url("questlog.php?which=6&vl=g") +
				visit_url("questlog.php?which=6&vl=h") +
				visit_url("questlog.php?which=6&vl=i") +
				visit_url("questlog.php?which=6&vl=j") +
				visit_url("questlog.php?which=6&vl=k") +
				visit_url("questlog.php?which=6&vl=l") +
				visit_url("questlog.php?which=6&vl=m") +
				visit_url("questlog.php?which=6&vl=n") +
				visit_url("questlog.php?which=6&vl=o") +
				visit_url("questlog.php?which=6&vl=p") +
				visit_url("questlog.php?which=6&vl=q") +
				visit_url("questlog.php?which=6&vl=r") +
				visit_url("questlog.php?which=6&vl=s") +
				visit_url("questlog.php?which=6&vl=t") +
				visit_url("questlog.php?which=6&vl=u") +
				visit_url("questlog.php?which=6&vl=v") +
				visit_url("questlog.php?which=6&vl=w") +
				visit_url("questlog.php?which=6&vl=x") +
				visit_url("questlog.php?which=6&vl=y") +
				visit_url("questlog.php?which=6&vl=z") +
				visit_url("questlog.php?which=6&vl=-");
	
		print("Checking Monster Manuel", "olive");
		ret = ret + "&manuel=";
		foreach x in manuel {
			isInManuel(manuel[x].gifname, manuelHTML, manuel[x].a);
		}
	}
	
	string infostring = "&version=2.5&mafiaversion="+get_version()+"&mafiarevision="+get_revision();
	html = visit_url("http://bumcheekcity.com/kol/profile.save.php?username="+url_encode(my_name())+ret+infostring);	

	debug(ret);
		
	print("");
	if (index_of(html, "success") > 0) {
		print("Successfully done. Visit the following URL to see your snapshot!", "green");
		print("http://bumcheekcity.com/kol/profile.php?u="+my_name(), "red");
		print("Setup your snapshot profile here:", "green");
		print("http://bumcheekcity.com/kol/profile.setup.php?u="+my_name(), "red");
		print(visit_url("http://bumcheekcity.com/kol/profile.after.php?u="+my_name()+infostring+"&result=success"));  
	} else if (index_of(html, "fail") > 0) {
		print("The script is reporting that it failed to update.", "red");
		print("It's possible that this error is occuring because you need to update your script version.", "red");
		print("Go to http://kolmafia.us/showthread.php?t=3001 and download the latest version if so.", "red");
		print(visit_url("http://bumcheekcity.com/kol/profile.after.php?u="+my_name()+infostring+"&result=fail")); 
	} else {
		print("For some reason, the script isn't reporting a successful update.", "orange");
		print("Visit the following URL to check your snapshot.", "orange");
		print("http://bumcheekcity.com/kol/profile.php?u="+my_name(), "red");
		print("If it didn't work - try again later - my website may just be having some temporary downtime problems.", "orange");
		print("If it worked, you can setup your snapshot profile here:", "orange");
		print("http://bumcheekcity.com/kol/profile.setup.php?u="+my_name(), "red");
		print(visit_url("http://bumcheekcity.com/kol/profile.after.php?u="+my_name()+infostring+"&result=dontknow"));
	}
	print("");
	print("Thanks for using bumcheekcity's snapshot maker. Your soul will be added to my collection.", "green");
}

void main() {

	//Check for a display case.
	if (index_of(visit_url("/displaycollection.php?who=" + my_id()), "This player doesn't have a display case...") == -1) {
		//Then they have a display case. But I have to check if there's anything in there. 
		if (index_of(visit_url("/displaycollection.php?who=" + my_id()), "This display case is currently empty.") == -1)
		{
			//Then they have at least one item in there. 
			hasdisplay = true;
			debug("You have a display case with at least one item in it.");
		} else {
			debug("You have a display case, but no items in it.");
		}
	} else {
		debug("You have no display case.");
	}

	//Check for a store.
	if (index_of(visit_url("charsheet.php"), "in the Mall of Loathing") > 0)
	{
		if (index_of(visit_url("mallstore.php?whichstore="+my_id()), "This store's inventory is currently empty. Try again later.") == -1)
		{
			hasstore = true;
			debug("You have a store with at least one item in it.");
		} else {
			debug("You have a store, but no items in it.");
		}
	} else {
		debug("You have no store.");
	}
	
	/* This should no longer be needed.
	//Now check the options set. 
	if (index_of(visit_url("account.php"), "<input type=checkbox name=invimages value=1 checked> Hide Inventory Images") > 0)
	{
		debug("Inventory Images are Hidden.");
	} else {
		debug("Inventory Images are not Hidden.");
	}

	//Now check the options set. 
	if (index_of(visit_url("account.php"), "<input type=checkbox name=oneclickcraft value=1> Turn On One-Click Crafting") > 0)
	{
		debug("One-Click Crafting is turned off.");
	} else {
		debug("One-Click Crafting is turned on.");
	}
	*/

	//Check the slime skills.
	string slime_brain = visit_url ("desc_skill.php?whichskill=47&self=true");
	if(index_of(slime_brain , "Slimy Synapses" )!=-1)
	{
		if(slime_brain.contains_text("Your synapses are 10% lubricated")) s_sy = 1;
		if(slime_brain.contains_text("Your synapses are 20% lubricated")) s_sy = 2;
		if(slime_brain.contains_text("Your synapses are 30% lubricated")) s_sy = 3;
		if(slime_brain.contains_text("Your synapses are 40% lubricated")) s_sy = 4;
		if(slime_brain.contains_text("Your synapses are 50% lubricated")) s_sy = 5;
		if(slime_brain.contains_text("Your synapses are 60% lubricated")) s_sy = 6;
		if(slime_brain.contains_text("Your synapses are 70% lubricated")) s_sy = 7;
		if(slime_brain.contains_text("Your synapses are 80% lubricated")) s_sy = 8;
		if(slime_brain.contains_text("Your synapses are 90% lubricated")) s_sy = 9;
		if(slime_brain.contains_text("Your synapses are maximally lubricated")) s_sy = 10;
	}
	string slime_hypophysis = visit_url ("desc_skill.php?whichskill=46&self=true");
	if(index_of(slime_hypophysis , "Slimy Sinews" )!=-1)
	{
		if(slime_hypophysis.contains_text("Your sinews are 10% lubricated")) s_si = 1;
		if(slime_hypophysis.contains_text("Your sinews are 20% lubricated")) s_si = 2;
		if(slime_hypophysis.contains_text("Your sinews are 30% lubricated")) s_si = 3;
		if(slime_hypophysis.contains_text("Your sinews are 40% lubricated")) s_si = 4;
		if(slime_hypophysis.contains_text("Your sinews are 50% lubricated")) s_si = 5;
		if(slime_hypophysis.contains_text("Your sinews are 60% lubricated")) s_si = 6;
		if(slime_hypophysis.contains_text("Your sinews are 70% lubricated")) s_si = 7;
		if(slime_hypophysis.contains_text("Your sinews are 80% lubricated")) s_si = 8;
		if(slime_hypophysis.contains_text("Your sinews are 90% lubricated")) s_si = 9;
		if(slime_hypophysis.contains_text("Your sinews are maximally lubricated")) s_si = 10;
	}
	string slime_sweat = visit_url ("desc_skill.php?whichskill=48&self=true");
	if(index_of(slime_sweat , "Slimy Shoulders" )!=-1)
	{
		if(slime_sweat.contains_text("Your shoulders are 10% lubricated")) s_sh = 1;
		if(slime_sweat.contains_text("Your shoulders are 20% lubricated")) s_sh = 2;
		if(slime_sweat.contains_text("Your shoulders are 30% lubricated")) s_sh = 3;
		if(slime_sweat.contains_text("Your shoulders are 40% lubricated")) s_sh = 4;
		if(slime_sweat.contains_text("Your shoulders are 50% lubricated")) s_sh = 5;
		if(slime_sweat.contains_text("Your shoulders are 60% lubricated")) s_sh = 6;
		if(slime_sweat.contains_text("Your shoulders are 70% lubricated")) s_sh = 7;
		if(slime_sweat.contains_text("Your shoulders are 80% lubricated")) s_sh = 8;
		if(slime_sweat.contains_text("Your shoulders are 90% lubricated")) s_sh = 9;
		if(slime_sweat.contains_text("Your shoulders are maximally lubricated")) s_sh = 10;
	}

	mainSnapshot();
}
