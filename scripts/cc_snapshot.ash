script "snapshot.ash";
notify cheesecookie;
since r18179;

#	This is a fork of bumcheekcity's snapshot script.
#	Code comes straight from that. Website layout is copied from it.
#	Things are then hacked onto it in order to increase support. Beep beep.

	boolean debug = false;
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
		string g;
	};

	int s_si, s_sh, s_sy;
	ItemImage [int] ascrewards, booze, concocktail, confood, conmeat, conmisc, consmith, coolitems, familiars, food, hobopolis, rogueprogram, manuel, mritems, skills, slimetube, tattoos, trophies, warmedals, tracked;
	string html, htmlkoldb, htmlscope, ret;
	string bookshelfHtml, familiarNamesHtml;

int i_a(string name)
{
	if((name == "none") || (name == ""))
	{
		return 0;
	}

	item i = to_item(name);
	int amt = item_amount(i) + closet_amount(i) + equipped_amount(i) + storage_amount(i);
	amt = amt + display_amount(i) + shop_amount(i);

	//Make a check for familiar equipment NOT equipped on the current familiar.
	foreach fam in $familiars[]
	{
		if(have_familiar(fam) && fam != my_familiar())
		{
			if(name == to_string(familiar_equipped_equipment(fam)) && name != "none")
			{
				amt = amt + 1;
			}
		}
	}

	//Thanks, Bale!
	if(get_campground() contains i) amt += 1;

	return amt;
}


boolean load_current_map(string fname, ItemImage[int] map)
{
	file_to_map(fname+".txt", map);
	return true;
}

void hasConsumed(string name, string html)
{
	name = to_lower_case(name);
	name = replace_string(name, "(", "\\(");
	name = replace_string(name, ")", "\\)");
	matcher m = create_matcher(">\\s*" + name + "(?:\\s*)</a>", to_lower_case(html));
	if(find(m))
	{
		ret = ret + "|1";
	}
	else
	{
		ret = ret + "|";
	}
}

void hasItem(string name)
{
	if(i_a(name) > 0)
	{
		ret = ret + "|1";
	}
	else
	{
		ret = ret + "|";
	}
}

void hasItem(string name, string amount)
{
	if(i_a(name) > 0)
	{
		ret = ret + "|"+ i_a(name);
	}
	else
	{
		ret = ret + "|";
	}
}

void isIn(string name, string html)
{
	if(length(name) > 7)
	{
		if(index_of(name, "_thumb") >= length(name) - 6)
		{
			name = substring(name, 0, length(name) - 6);
		}
	}

	matcher reg = create_matcher(name, html);
	if(reg.find())
	{
		ret = ret + "|1";
	}
	else
	{
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
	if(reg.find())
	{
		ret = ret + "|1";
		debug("YES --- " + checkthis);
	}
	else
	{
		ret = ret + "|";
		debug("NO --- " + checkthis);
	}
}

void isInDisco(string name, string html, string a)
{
	if(a != "none")
	{
		regCheck(a, html);
	}
	else
	{
		if(index_of(html, ">"+name+"<") != -1)
		{
			ret = ret + "|1";
		}
		else
		{
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

	//Manually override monsterName in some circumstances
	if(contains_text(monsterName, "fabricator g")) {
		monsterName = "fabricator g";
	}
	if(contains_text(monsterName, "novio cad")) {
		monsterName = "novio cad";
	}
	if(contains_text(monsterName, "padre cad")) {
		monsterName = "padre cad";
	}
	if(contains_text(monsterName, "novia cad")) {
		monsterName = "novia cad";
	}
	if(contains_text(monsterName, "persona inoce")) {
		monsterName = "persona inoce";
	}

	string searchForThis = "";
	//If we specify a first fact then we should search for the monster name AND fact, else just the monster name.
	if(firstFact != "") {
		searchForThis = montag+monsterName+"</font></b><ul><li>"+firstFact;
	} else {
		searchForThis = montag+monsterName;
	}

		if(contains_text(questmanpage, searchForThis))
		{
			istart = index_of(questmanpage,searchForThis,iend);
			iend = index_of(questmanpage,montag,istart+2);
			if(istart == -1) { istart = 1; }
			if(iend == -1) { iend = length(questmanpage); }
			ssub = substring(questmanpage,istart,iend);
			matcher ii = create_matcher("(<li>)",ssub);
			rcount=0;
			while(find(ii)) { rcount += 1; }
		}

		if(forceReturn) return rcount;

		if(rcount == 0) {
			//print("trying lowercase");
			return manuelTimes(to_lower_case(monsterName), questmanpage, firstFact, true);
		}
	return rcount;
}
int manuelTimes(string monsterName, string questmanpage, string firstFact)
{
	return manuelTimes(monsterName, questmanpage, firstFact, false);
}

void isInManuel(string monstername, string html, string firstFact)
{
	ret = ret + "|" + manuelTimes(monstername, html, firstFact);
}

void famCheck(string name, string gifname, string hatchling)
{
	debug("Looking for familiar: " + name);
	if(index_of(html, "the " + name) > 0)
	{
		matcher m = create_matcher("alt=\"" + name + " .([0-9.]+)..", htmlkoldb);
		float percent = 0.0;
		while(find(m))
		{
			string percentMatch = group(m, 1);
			percent = max(percent, to_float(percentMatch));
		}

		debug("Found max percentage: " + percent);
		if(percent >= 100.0)
		{
			//100% Run
			ret = ret + "|3";
		}
		else if(percent >= 90.0)
		{
			//90% Tourguide Run
			ret = ret + "|4";
		}
		else
		{
			//Have Familiar
			ret = ret + "|1";
		}
	}
	else if(i_a(hatchling) > 0)
	{
		//Have Hatchling
		ret = ret + "|2";
	}
	else
	{
		//Dont have familiar at all.
		ret = ret + "|";
	}
}

void isInSkill(string name, string html, string overwrite)
{
	if(overwrite == "none")
	{
		overwrite = "";
	}
	if(index_of(html, ">"+name+"</a> (<b>HP</b>)") != -1)
	{
		ret = ret + "|1";
		if(name == "Slimy Shoulders")
		{
			ret = ret + "-" + s_sh;
		}
		else if(name == "Slimy Sinews")
		{
			ret = ret + "-" + s_si;
		}
		else if(name == "Slimy Synapses")
		{
			ret = ret + "-" + s_sy;
		}
	}
	else if((length(overwrite) > 0) && (index_of(html, overwrite) > 0))
	{
		ret = ret + "|1";
	}
	else if(index_of(html, ">"+name+"</a> (P)") != -1)
	{
		ret = ret + "|2";
		if(name == "Slimy Shoulders")
		{
			ret = ret + "-" + s_sh;
		}
		else if(name == "Slimy Sinews")
		{
			ret = ret + "-" + s_si;
		}
		else if(name == "Slimy Synapses")
		{
			ret = ret + "-" + s_sy;
		}
	}
	else if((name == "Toggle Optimality") && have_skill(to_skill(name)))
	{
		ret = ret + "|1";
	}
	else
	{
		ret = ret + "|";
	}
}

void tattooCheck(string outfit, string gif, string i1, string i2, string i3, string i4, string i5, string i6, string i7)
{
	if(last_index_of(html, "/"+gif+".gif") > 0)
	{
		ret = ret + "|1";
	}
	else
	{
		boolean hasallitems = (i_a(i1) > 0);
		if((i7 != "none") && (i7 != ""))
		{
			hasallitems = hasallitems && (i_a(i7) > 0);
		}
		if((i6 != "none") && (i6 != ""))
		{
			hasallitems = hasallitems && (i_a(i6) > 0);
		}
		if((i5 != "none") && (i5 != ""))
		{
			hasallitems = hasallitems && (i_a(i5) > 0);
		}
		if((i4 != "none") && (i4 != ""))
		{
			hasallitems = hasallitems && (i_a(i4) > 0);
		}
		if((i3 != "none") && (i3 != ""))
		{
			hasallitems = hasallitems && (i_a(i3) > 0);
		}
		if((i2 != "none") && (i2 != ""))
		{
			hasallitems = hasallitems && (i_a(i2) > 0);
		}
		debug(outfit+"---"+gif+"---have(" + hasallitems + ")"+i1+"("+i_a(i1)+")"+i2+"("+i_a(i2)+")"+i3+"("+i_a(i3)+")"+i4+"("+i_a(i4)+")"+i5+"("+i_a(i5)+")");

		ret = ret + "|";
		if(hasallitems)
		{
			ret = ret + "2";
		}
	}

	//This is a terrible way of doing this, but the hobo tattoo goes after the salad one.
	//We are not doing this, make it the first tattoo....
	if(gif == "saladtat")
	{
		ret = ret + "|";
		for i from 19 to 1
		{
			if(index_of(html, "hobotat"+i) != -1)
			{
				ret = ret + i;
				break;
			}
		}
	}
}

string visit_discoveries(string url)
{
	matcher reg = create_matcher("<font size=2>.*?</font>", visit_url(url));
	return replace_all(reg, "");
}

void main()
{
	if(!get_property("kingLiberated").to_boolean())
	{
		if(!user_confirm("This script should not be run while you are in-run. It may blank out some of your skills, telescope, bookshelf or some other aspect of your profile until you next run it in aftercore. Are you sure you want to run it (not recommended)?", 15000, false))
		{
			abort("User aborted. Beep");
		}
	}
	print("This is snapshot maker! This script takes a snapshot of your character and uploads it to my server at cheesellc.com", "green");

	//Check the slime skills.	(sinews, synapses, shoulders)
	s_si = get_property("skillLevel46").to_int() / 2;
	s_sy = get_property("skillLevel47").to_int();
	s_sh = get_property("skillLevel48").to_int() / 2;


	print("Updating map files...", "olive");
	load_current_map("cc_snapshot_skills", skills);
	load_current_map("cc_snapshot_tattoos", tattoos);
	load_current_map("cc_snapshot_trophies", trophies);
	load_current_map("cc_snapshot_familiars", familiars);
	load_current_map("cc_snapshot_hobopolis", hobopolis);
	load_current_map("cc_snapshot_slimetube", slimetube);
	load_current_map("cc_snapshot_warmedals", warmedals);
	load_current_map("cc_snapshot_ascensionrewards", ascrewards);
	load_current_map("cc_snapshot_dis_cocktail", concocktail);
	load_current_map("cc_snapshot_dis_food", confood);
	load_current_map("cc_snapshot_dis_meat", conmeat);
	load_current_map("cc_snapshot_dis_smith", consmith);
	load_current_map("cc_snapshot_dis_misc", conmisc);
	load_current_map("cc_snapshot_mritems", mritems);
	load_current_map("cc_snapshot_coolitems", coolitems);
	load_current_map("cc_snapshot_con_food", food);
	load_current_map("cc_snapshot_con_booze", booze);
	load_current_map("cc_snapshot_rogueprogram", rogueprogram);
	load_current_map("cc_snapshot_manuel", manuel);
	load_current_map("cc_snapshot_tracked", tracked);

	bookshelfHtml = visit_url("campground.php?action=bookshelf");
	familiarNamesHtml = visit_url("familiarnames.php");

	print("Checking skills...", "olive");
	ret = "&skills=";
	html = visit_url("charsheet.php") + bookshelfHtml;
	foreach x in skills
	{
		isInSkill(skills[x].itemname, html, skills[x].a);
	}

	print("Checking tattoos...", "olive");
	html = visit_url("account_tattoos.php");
	ret = ret + "&tattoos=";
	foreach x in tattoos
	{
		tattooCheck(tattoos[x].itemname, tattoos[x].gifname, tattoos[x].a, tattoos[x].b, tattoos[x].c, tattoos[x].d, tattoos[x].e, tattoos[x].f, tattoos[x].g);
	}

	print("Checking trophies...", "olive");
	html = visit_url("trophies.php");
	ret = ret + "&trophies=";
	foreach x in trophies
	{
		isIn("/" + trophies[x].itemname, html);
	}

	print("Checking familiars...", "olive");
	html = familiarNamesHtml;
	htmlkoldb = visit_url(" ascensionhistory.php?back=self&who=" +my_id(), false) + visit_url(" ascensionhistory.php?back=self&prens13=1&who=" +my_id(), false);
	ret = ret + "&familiars=";
	foreach x in familiars
	{
		famCheck(familiars[x].itemname, familiars[x].gifname, familiars[x].a);
	}

	print("Checking hobopolis loot and hobo codes...", "olive");
	html = visit_url("questlog.php?which=5");
	ret = ret + "&hobopolis=";
	foreach x in hobopolis
	{
		if(x >= 44 && x <= 63) {
			isIn(hobopolis[x].itemname, html);
		} else {
			hasItem(hobopolis[x].itemname);
		}
	}

	print("Checking Slime Tube loot...", "olive");
	ret = ret + "&slimetube=";
	foreach x in slimetube
	{
		hasItem(slimetube[x].itemname);
	}

	print("Checking War Medals...", "olive");
	ret = ret + "&warmedals=";
	foreach x in warmedals
	{
		hasItem(warmedals[x].itemname, "amount");
	}

	print("Checking for Telescope", "olive");
	ret = ret + "&scope=" + get_property("telescopeUpgrades").to_int();

	print("Checking for Ascension Rewards", "olive");
	ret = ret + "&ascreward=";
	foreach x in ascrewards
	{
		hasItem(ascrewards[x].itemname, "amount");
	}

	print("Checking for Mafia Tracked Data", "olive");
	ret = ret + "&tracked=";
	foreach x in tracked
	{
		ret = ret + "|" + get_property(tracked[x].a);
	}

	print("Checking for Discoveries [Cocktail]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=cocktail");
	ret = ret + "&concocktail=";
	foreach x in concocktail
	{
		isInDisco(concocktail[x].itemname, html, concocktail[x].gifname);
	}

	print("Checking for Discoveries [Food]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=cook");
	ret = ret + "&confood=";
	foreach x in confood
	{
		isInDisco(confood[x].itemname, html, confood[x].gifname);
	}

	print("Checking for Discoveries [Meat Pasting]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=combine");
	ret = ret + "&conmeat=";
	foreach x in conmeat
	{
		isInDisco(conmeat[x].itemname, html, conmeat[x].gifname);
	}

	print("Checking for Discoveries [Meatsmithing]", "olive");
	html = visit_discoveries("craft.php?mode=discoveries&what=smith");
	ret = ret + "&consmith=";
	foreach x in consmith
	{
		isInDisco(consmith[x].itemname, html, consmith[x].gifname);
	}

	print("Checking for Discoveries [Misc]", "olive");
	html = visit_url("craft.php?mode=discoveries&what=multi");
	ret = ret + "&conmisc=";
	foreach x in conmisc
	{
		isInDisco(conmisc[x].itemname, html, conmisc[x].gifname);
	}

	print("Checking for Mr. Items", "olive");


	if(!get_property("spookyAirportAlways").to_boolean() || !get_property("sleazeAirportAlways").to_boolean() || !get_property("stenchAirportAlways").to_boolean() || !get_property("coldAirportAlways").to_boolean() || !get_property("hotAirportAlways").to_boolean())
	{
		html = visit_url("place.php?whichplace=airport");
		if(!get_property("spookyAirportAlways").to_boolean() && contains_text(html, "airport_spooky"))
		{
			set_property("spookyAirportAlways", user_confirm("Mafia does not think you have Conspiracy Island but it appears that you might. Select Yes to confirm that you have it. Select No to indicate that you do not have it.", 15000, false));
		}
		if(!get_property("sleazeAirportAlways").to_boolean() && contains_text(html, "airport_sleaze"))
		{
			set_property("sleazeAirportAlways", user_confirm("Mafia does not think you have Spring Break Beach but it appears that you might. Select Yes to confirm that you have it. Select No to indicate that you do not have it.", 15000, false));
		}
		if(!get_property("stenchAirportAlways").to_boolean() && contains_text(html, "airport_stench"))
		{
			set_property("stenchAirportAlways", user_confirm("Mafia does not think you have Disneylandfill but it appears that you might. Select Yes to confirm that you have it. Select No to indicate that you do not have it.", 15000, false));
		}
		if(!get_property("hotAirportAlways").to_boolean() && contains_text(html, "airport_hot"))
		{
			set_property("hotAirportAlways", user_confirm("Mafia does not think you have That 70s Volcano but it appears that you might. Select Yes to confirm that you have it. Select No to indicate that you do not have it.", 15000, false));
		}
		if(!get_property("coldAirportAlways").to_boolean() && contains_text(html, "airport_cold"))
		{
			set_property("coldAirportAlways", user_confirm("Mafia does not think you have The Glaciest but it appears that you might. Select Yes to confirm that you have it. Select No to indicate that you do not have it.", 15000, false));
		}
	}

	html = familiarNamesHtml + bookshelfHtml;
	ret = ret + "&mritems=";
	foreach x in mritems
	{
		int itemAmount = 0;
		switch(mritems[x].itemname)
		{
			case "b":				//Bind-on-use Items
				itemAmount = i_a(to_item(mritems[x].gifname)) + i_a(to_item(mritems[x].a));
			break;

			case "f":				//Familiar
				if (index_of(html, "the " + mritems[x].a) > 0) { itemAmount = 1; }
				itemAmount = itemAmount + i_a(to_item(mritems[x].gifname));
			break;

			case "g":				//Garden Stuff
				if (index_of(html, mritems[x].b) > 0) { itemAmount = 1; }
				itemAmount = itemAmount + i_a(to_item(mritems[x].gifname)) + i_a(to_item(mritems[x].a));
			break;

			case "i":				//Item
				itemAmount = i_a(to_item(mritems[x].gifname));
			break;

			case "o":				//Foldable
				itemAmount = i_a(to_item(mritems[x].gifname));
				if (mritems[x].a != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].a)); }
				if (mritems[x].b != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].b)); }
				if (mritems[x].c != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].c)); }
				if (mritems[x].d != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].d)); }
				if (mritems[x].e != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].e)); }
				if (mritems[x].f != "none") { itemAmount = itemAmount + i_a(to_item(mritems[x].f)); }
			break;

			case "p":				//Correspondences (Pen Pal, Game Magazine, etc)
				if (contains_text(visit_url("account.php?tab=correspondence"), ">" + mritems[x].a +"</option>"))
				{
					itemAmount = 1;
				}
				itemAmount = itemAmount + i_a(to_item(mritems[x].gifname));
			break;

			case "e":				// get campground, otherwise visit page, check for matching text
				itemAmount = i_a(to_item(mritems[x].gifname));
				if(get_campground() contains to_item(mritems[x].gifname))
				{
					itemAmount = itemAmount + 1;
				}
				else if(contains_text(visit_url(mritems[x].a), mritems[x].b))
				{
					itemAmount = itemAmount + 1;
				}
			break;

			case "s":				//Check mafia setting
				itemAmount = i_a(to_item(mritems[x].gifname));
				if(get_property(mritems[x].a).to_boolean())
				{
					itemAmount = itemAmount + 1;
				}
			break;

			case "t":				//Tome, Libram, Grimore
				if(index_of(html, mritems[x].a) > 0) { itemAmount = 1; }
				itemAmount = itemAmount + i_a(to_item(mritems[x].gifname));
			break;
		}
		ret = ret + "|" + itemAmount;
	}

	print("Checking for Cool Items", "olive");
	ret = ret + "&coolitems=";
	foreach x in coolitems
	{
		hasItem(coolitems[x].itemname, "amount");
	}

	print("Checking for Consumed Food", "olive");
	html = to_lower_case(visit_url("showconsumption.php"));
	ret = ret + "&food=";
	foreach x in food
	{
		hasConsumed(food[x].itemname, html);
	}

	print("Checking for Consumed Booze", "olive");
	ret = ret + "&booze=";
	foreach x in booze
	{
		hasConsumed(booze[x].itemname, html);
	}

	print("Checking for Rogue Program Stuff", "olive");
	html = to_lower_case(visit_url("arcade.php?ticketcounter=1"));
	ret = ret + "&arcadegames=";
	foreach x in rogueprogram
	{
		if(i_a(rogueprogram[x].itemname) > 0)
		{
			ret = ret + "|1";
		}
		else if(index_of(html, rogueprogram[x].itemname) > 0)
		{
			ret = ret + "|2";
		}
		else
		{
			ret = ret + "|";
		}
	}

	print("Checking Demon Names", "olive");
//	string demon = visit_url("http://cheesellc.com/kol/cc_snapshot_demon.txt").to_string();
//	int i = 1, numdemon = demon.to_int();
	int i = 1, numdemon = 12;
	ret = ret + "&demonnames=";
	while(i <= numdemon)
	{
		ret = ret + get_property("demonName"+i) + "|";
		debug(i+get_property("demonName"+i));
		i = i + 1;
	}

	print("Checking Karma", "olive");
	string karma = visit_url("questlog.php?which=3");
	matcher m = create_matcher("Your current Karmic balance is ([0-9,]+)", karma);
	string k = "";
	while(find(m))
	{
		k = group(m, 1);
	}
	debug("You have "+k+" karma");
	ret = ret + "&karma="+k;

	print("Checking Path Points", "olive");
	ret = ret + "&paths=";
	string paths = visit_url("http://cheesellc.com/kol/cc_snapshot_paths.txt").to_string();
	string[int] pathsList = split_string(paths);
	foreach key in pathsList
	{
		ret = ret + get_property(pathsList[key])+"|";
	}

	ret = ret + "&inrun=" + !get_property("kingLiberated").to_boolean();
	ret = ret + "&snapshotversion=" + svn_info("ccascend-snapshot").last_changed_rev;

	string manuelHTML = visit_url("questlog.php?which=6&vl=a");
	if(contains_text(manuelHTML, "Monster Manuel"))
	{
		print("Checking simplified Manuel data", "olive");

		ret = ret + "&manuelsimple=";
		matcher m = create_matcher("casually(?:.*?)([0-9]+) creature(s?)[.]", manuelHTML);
		string researchVal = "0";
		if(find(m))
		{
			researchVal = group(m,1);
		}
		ret = ret + "|" + researchVal;

		m = create_matcher("thoroughly(?:.*?)([0-9]+) creature(s?)[.]", manuelHTML);
		researchVal = "0";
		if(find(m))
		{
			researchVal = group(m,1);
		}
		ret = ret + "|" + researchVal;

		m = create_matcher("exhaustively(?:.*?)([0-9]+) creature(s?)[.]", manuelHTML);
		researchVal = "0";
		if(find(m))
		{
			researchVal = group(m,1);
		}
		ret = ret + "|" + researchVal;
	}

/*
	string manuelHTML = visit_url("questlog.php?which=6&vl=a");
	if(contains_text(manuelHTML, "Monster Manuel"))
	{
		print("Starting to Check the Manuel HTML Pages (this may take a minute)...", "olive");
		manuelHTML = manuelHTML +
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
		foreach x in manuel
		{
			isInManuel(manuel[x].gifname, manuelHTML, manuel[x].a);
		}
	}
*/
	string infostring = "&version=2.6_20150515&mafiaversion="+get_version()+"&mafiarevision="+get_revision();
	html = visit_url("http://cheesellc.com/kol/profile.save.php?username="+url_encode(my_name())+ret+infostring);

	debug(ret);
	print("");
	if(index_of(html, "success") > 0) {
		print("Successfully done. Click the following URL to see your snapshot!", "green");
		print_html("<a href=\"http://cheesellc.com/kol/profile.php?u="+url_encode(my_name())+"\" target=\"_blank\">http://cheesellc.com/kol/profile.php?u="+url_encode(my_name())+"</a>");
#		print("Setup your snapshot profile here:", "green");
#		print("http://cheesellc.com/kol/profile.setup.php?u="+my_name(), "red");
	} else if(index_of(html, "fail") > 0) {
		print("The script is reporting that it failed to update.", "red");
		print("It's possible that this error is occuring because you need to update your script version.", "red");
		print("Go to http://kolmafia.us/showthread.php?t=3001 and download the latest version if so.", "red");
	} else {
		print("For some reason, the script isn't reporting a successful update.", "orange");
		print("Visit the following URL to check your snapshot.", "orange");
		print_html("<a href=\"http://cheesellc.com/kol/profile.php?u="+url_encode(my_name())+"\" target=\"_blank\">http://cheesellc.com/kol/profile.php?u="+url_encode(my_name())+"</a>");
		print("If it didn't work - try again later - my website may just be having some temporary downtime problems.", "orange");
#		print("If it worked, you can setup your snapshot profile here:", "orange");
#		print("http://cheesellc.com/kol/profile.setup.php?u="+my_name(), "red");
	}
	print("");
	print("Thanks for using snapshot maker. Your turtle mechs will be added to my collection.", "green");
}
