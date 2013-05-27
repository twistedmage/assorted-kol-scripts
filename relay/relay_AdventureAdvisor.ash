script "AdventureAdvisor.ash";

string thisver = "1.4"; 				// This is the script's version!
string thread = "http://kolmafia.us/showthread.php?4367-Adventure-Advisor&p=30941&viewfull=1#post30941";
string mfname = "AdventureAdvisor"; 	// This is the name of the map file.

// Information on every place worth visiting
record place {
	string locnick;
	string zone;
	string zonephp;
	int level;
	monster boss;
	string bossnick;
	int bosslevel;
	boolean bossonly;
	boolean aftercore;
	boolean noquest;
};
place [location] kingdom;
location [int] order;

string title = "<a href='"+thread+"' target='_blank'>Adventure Advisor</a> version "+thisver+", by <a href='showplayer.php?who=754005'>Bale</a>";
string level1 = "background-color:66FFCC; color:black;";	// Green
string level2 = "background-color:CCFF99; color:black;";	// Yellow
string level3 = "background-color:FF9966; color:white;";	// Orange
string level4 = "background-color:CC0033; color:white;";	// Red

// Some global variables modified by form submission
stat stat_choice = weapon_type(equipped_item($slot[weapon]));
if(stat_choice == $stat[none]|| stat_choice == $stat[Mysticality]) stat_choice = $stat[moxie];
#string max_min = "min";
boolean hide_after = (!get_property("kingLiberated").to_boolean());
string [string] vars;

// Beginning of form functions based strongly on jasonharper's htmlform.ash from http://kolmafia.us/showthread.php?3842
////////// GLOBAL VARIABLES

string[string] fields;	// shared result from form_fields()
boolean success;	// form successfully submitted

string write_radio(string ov, string name, string label, string value) {
	if(fields contains name) ov = fields[name];
	if(label != "") write("<label>");
	write("<input type='radio' name='" + name + "' value='" + entity_encode(value) + "'");
	if(value == ov) write(" checked");
	write(">");
	if(label != "" ) write(label+ "</label>");
	return ov;
}

string write_select(string ov, string name, string label) {
	write("<label>" +label);
	if(fields contains name) ov = fields[name];
	write("<select name='" +name);
	if(label == "") write("' id='" +name);
	write("'>");
	return ov;
}

void finish_select() {
	writeln("</select></label>");
}

void write_option(string ov, string label, string value) {
	write("<option value='" + entity_encode(value)+ "'");
	if(value == ov) write(" selected");
	writeln(">" +label+ "</option>");
}

boolean test_button(string name) {
	if(name == "")	return false;
	return success && fields contains name;
}

boolean write_button(string name, string label) {
	write("<input type='submit' name='");
	write(name+ "' value='");
	write(label+ "'>");
	return test_button(name);
}

// Reverse checkbox based on jason's write_check()
boolean write_rcheck(boolean ov, string name, string label) {
	if(label != "" ) write("<label>");
	if(fields contains name) ov = true;
	else if(count(fields) > 0) ov = false;
	write("<input id=\""+ name +"\" type='checkbox' name=\"" + name + "\"");
	if(ov) write(" checked");
	write(">");
	if(label != "" ) write(label+ "</label>");
	return ov;
}
string write_rcheck(string ov, string name, string label) {
	return write_rcheck(ov.to_boolean(), name, label).to_string();
}

// end of jasonharper's htmlform.ash

// If datafile is missing or needs updating! Download it using zarqon's automatic map updating: http://kolmafia.us/showthread.php?t=1515
boolean get_newmap(string curr) {
	print("Updating "+mfname+".txt from '"+get_property(mfname+".txt")+"' to '"+curr+"'...");
	if(!file_to_map("http://zachbardon.com/mafiatools/autoupdate.php?f="+mfname+"&act=getmap", kingdom) || count(kingdom) == 0)
		return false;
	map_to_file(kingdom, mfname+".txt");
	set_property(mfname+".txt",curr);
	print("..."+mfname+".txt updated.");
	return true;
}

void version_update() {
	string current_ver = get_property("_version_BalesAdventureAdvisor");
	// This is zarqon's automatic map updating: http://kolmafia.us/showthread.php?t=1515
	if(current_ver == "") {
		string curr = visit_url("http://zachbardon.com/mafiatools/autoupdate.php?f="+mfname+"&act=getver");
		if(!file_to_map(mfname+".txt",kingdom) || count(kingdom) == 0 || (curr != "" && get_property(mfname+".txt") != curr)) 
			get_newmap(curr);
	}
	// My rendition of zarqon's version checker. If it is unable to load version info, it will try again 20% of the time.
	if(current_ver == "" || (current_ver == "0" && random(5) == 0)) {
		matcher version = create_matcher("<b>Adventure Advisor (.+?)</b>", visit_url(thread));
		if(version.find()) {
			current_ver = version.group(1);
		} else current_ver = "0";
		set_property("_version_BalesAdventureAdvisor", current_ver);
	}
	if(current_ver.to_float() > thisver.to_float()) {
		write("<div style='font-size:140%; font-weight:bold; color:red; font-family:Arial,Helvetica,sans-serif'>New version of Bale's Adventure Advisor available: "+current_ver+"</div>");
		title = "Visit <a href='"+thread+"' target='_blank'>this post</a> to download the latest version of Adventure Advisor.";
	} else if(current_ver == "0")
		title += " &nbsp; &#x25E6; &nbsp; &#x25E6; &nbsp; &#x25E6; &nbsp; Current version info is unknown.";
	//else title += " &nbsp; &#x25E6; &nbsp; &#x25E6; &nbsp; &#x25E6; &nbsp; up to date.";
}

int monster_level(monster m) {
	float mod = 0.9;
	if(stat_choice == $stat[moxie]) mod = 1;
	switch(m) {
	// These are a whole bunch of monsters with missing data. Return an approximation of correctness.
	case $monster[Drunk Duck]:
	case $monster[Fire-Breathing Duck]:
	case $monster[Rotund Duck]:
	case $monster[Vampire Duck]:
	case $monster[Caveman Frat Boy]:
	case $monster[Caveman Frat Pledge]:
	case $monster[Caveman Sorority Girl]:
	case $monster[War Hippy Drill Sergeant]:
	case $monster[Frat Warrior Drill Sergeant]:
	case $monster[Ed the Undying (1)]:
	case $monster[Larval Filthworm]:
	case $monster[Filthworm Drone]:
	case $monster[Filthworm Royal Guard]:
	case $monster[The Queen Filthworm]:
	case $monster[Lord Spookyraven]:
	case $monster[Dr. Awkward]: return monster_attack(m) * mod;
	case $monster[Protector Spectre]: return monster_defense(m) / mod;
	case $monster[The Man]:
	case $monster[The Big Wisniewski]:
		return 255+ monster_level_adjustment() * mod;
	}
	if(stat_choice == $stat[moxie]) return monster_attack(m);
	return monster_defense(m);
}

// returns safe moxie or muscle to hit for a given location (includes +ML and MCD, skips bosses)
place get_level(location loc) {
	int high;
	place here = kingdom[loc];
	if(kingdom[loc].zone == "Volcano Lair" && loc != $location[The Temple Portico])
		// These locations don't have monster data yet
		high = monster_level_adjustment() + 170;
	else if(loc == $location[the lower chamber]) {   // Ed not listed in the location
		here.boss = $monster[Ed the Undying (1)];
		here.level = monster_level(here.boss) + 9;
		here.bosslevel = here.level;
		return here;
	} else foreach m,r in appearance_rates(loc) {
		if(m == kingdom[loc].boss) continue;
		if(r > 0) high = max(monster_level(m),high);
	}
#ash foreach m,r in appearance_rates($location[   ]) print(monster_defense(m) +" - "+ monster_attack(m) + " : " + m + " " + r);
	if(high != 0 && high != monster_level_adjustment()&& high != monster_level_adjustment() * .9)
		here.level = high + 9;
	if(here.bossonly) {
		here.bosslevel = here.level;
		foreach key, mob in get_monsters(loc) here.boss = mob;
	}
	return here;
}

void telescope() {
	item [location] tower_item;
		tower_item[$location[Ninja Snowmen]] = $item[frigid ninja stars];
		tower_item[$location[Sleazy Back Alley]] = $item[spider web];
		tower_item[$location[Haunted Bathroom]] = $item[fancy bath salts];
		tower_item[$location[Haunted Kitchen]] = $item[leftovers of indeterminate origin];
	if(my_path() == "Bees Hate You") {
		foreach loc in tower_item
			kingdom[loc].noquest = true;
	} else if(get_property("telescopeUpgrades").to_int() >= 6) {
		string [location] sight;
			sight[$location[Ninja Snowmen]] = "catch a glimpse of a flaming katana";
			sight[$location[Sleazy Back Alley]] = "catch a glimpse of a translucent wing";
			sight[$location[Haunted Bathroom]] = "see a slimy eyestalk";
			sight[$location[Haunted Kitchen]] = "see some sort of bronze figure holding a spatula";
		boolean [string] telescope;
		for x from 1 to 6
			telescope[get_property("telescope"+x)] = true;
		foreach loc, view in sight
			kingdom[loc].noquest = !telescope[view] || item_amount(tower_item[loc]) > 0;
	} else {
		foreach loc in tower_item
			kingdom[loc].noquest = item_amount(tower_item[loc]) > 0;
	}
}

void populate_kingdom() {
	// Set Kingdom locations from an external file.
	if(!file_to_map(mfname+".txt",kingdom) || count(kingdom) == 0)
		if(!get_newmap(visit_url("http://zachbardon.com/mafiatools/autoupdate.php?f="+mfname+"&act=getver")))
			abort("Kingdom location data is corrupted or missing. Troublesome!");
	
	// Remove all adventuring locations that are flatly impossible for the character.
	if(knoll_available()) {
		remove kingdom[$location[Degrassi Knoll]];
	} else {
		remove kingdom[$location[Bugbear Pens]];
		remove kingdom[$location[Spooky Gravy Barrow]];
	}
	if(!canadia_available()) {
		remove kingdom[$location[Outskirts of Camp]];
		remove kingdom[$location[Camp Logging Camp]];
	}
	if(!gnomads_available())
		remove kingdom[$location[Thugnderdome]];
	if(!can_interact() && available_amount($item[El Vibrato trapezoid]) < 1)
		remove kingdom[$location[El Vibrato Island]];
	if(!have_familiar($familiar[Astral Badger]) && !can_interact() && available_amount($item[astral mushroom]) < 1) {
		remove kingdom[$location[Astral Mushroom (Bad Trip)]];
		remove kingdom[$location[Astral Mushroom (Great Trip)]];
		remove kingdom[$location[Astral Mushroom (Mediocre Trip)]];
	}
	if(!have_familiar($familiar[Green Pixie]) && !can_interact() && available_amount($item[absinthe]) < 1) {
		remove kingdom[$location[Stately Pleasure Dome]];
		remove kingdom[$location[Mouldering Mansion]];
		remove kingdom[$location[Rogue Windmill]];
	}
	if(!have_familiar($familiar[Baby Sandworm]) && !can_interact() && available_amount($item[agua de vida]) < 1
	  && available_amount($item[empty agua de vida bottle]) < 1) {
		remove kingdom[$location[The Primordial Soup]];
		remove kingdom[$location[The Jungles of Ancient Loathing]];
		remove kingdom[$location[Seaside Megalopolis]];
	}
	if(my_level() > 5) remove kingdom[$location[Battlefield (Cloaca Uniform)]];
	
	// Set Nemesis location for each class:
	location [class] nemesis;
		nemesis[$class[Seal Clubber]] = $location[The Broodling Grounds];
		nemesis[$class[Turtle Tamer]] = $location[The Outer Compound];
		nemesis[$class[Pastamancer]] = $location[The Temple Portico];
		nemesis[$class[Sauceror]] = $location[Convention Hall Lobby];
		nemesis[$class[Disco Bandit]] = $location[Outside the Club];
		nemesis[$class[Accordion Thief]] = $location[The Barracks];
	foreach cl, loc in nemesis
		if(my_class() != cl) remove kingdom[loc];
	switch(my_class()) {
	case $class[Seal Clubber]:
		kingdom[$location[The Nemesis' Lair]].boss = $monster[Gorgolok, the Infernal Seal];
		kingdom[$location[The Nemesis' Lair]].bossnick = "Gorgolok";
		break;
	case $class[Turtle Tamer]:
		kingdom[$location[The Nemesis' Lair]].boss = $monster[Stella, the Turtle Poacher];
		kingdom[$location[The Nemesis' Lair]].bossnick = "Stella";
		break;
	case $class[Pastamancer]:
		kingdom[$location[The Nemesis' Lair]].boss = $monster[Spaghetti Elemental];
		kingdom[$location[The Nemesis' Lair]].bossnick = "Spaghetti&nbsp;Elemental";
		break;
	case $class[Sauceror]:
		kingdom[$location[The Nemesis' Lair]].boss = $monster[Lumpy, the Sinister Sauceblob];
		kingdom[$location[The Nemesis' Lair]].bossnick = "Lumpy";
		break;
	case $class[Disco Bandit]:
		kingdom[$location[The Nemesis' Lair]].boss = $monster[The Spirit of New Wave];
		kingdom[$location[The Nemesis' Lair]].bossnick = "Spirit of New Wave";
		break;
	case $class[Accordion Thief]:
		kingdom[$location[The Nemesis' Lair]].boss = $monster[Somerset Lopez, Dread Mariachi];
		kingdom[$location[The Nemesis' Lair]].bossnick = "Somerset Lopez";
		break;
	}
	
	// Check telescope to see if more zones can be ruled noquest.
	telescope();
	
	// Set quest status, based on class (Sea has three zones of which only 1 is relevant to the character.)
	switch(my_primestat()) {
	case $stat[muscle]:
		kingdom[$location[Anemone Mine]].noquest = false;
		// Gallery quest is only relevant for muscle classes
		kingdom[$location[Haunted Conservatory]].noquest = false;
		kingdom[$location[Haunted Gallery]].noquest = false;
		break;
	case $stat[mysticality]:
		kingdom[$location[The Marinara Trench]].noquest = false;
		kingdom[$location[Haunted Bathroom]].noquest = false;
		break;
	case $stat[moxie]:
		kingdom[$location[The Dive Bar]].noquest = false;
	}
	
	// Is bathole entryway quest material? Only if stench protection is not a skill.
	// Is eXtreme Slope quest material? Only if cold protection is not a skill.
	if(have_skill($skill[Astral Shell]) || have_skill($skill[Elemental Saucesphere])) {
		kingdom[$location[Bat Hole Entryway]].noquest = true;
		kingdom[$location[eXtreme Slope]].noquest = true;
	} else {
		if(have_skill($skill[Diminished Gag Reflex]))
			kingdom[$location[Bat Hole Entryway]].noquest = true;
		if(have_skill($skill[Northern Exposure]))
			kingdom[$location[eXtreme Slope]].noquest = true;
	}
	
	// Dequest Cobb's Knob Locations
	if(in_hardcore() && (available_amount($item[Crown of the Goblin King]) > 0 
	  || available_amount($item[Glass Balls of the Goblin King]) > 0 || available_amount($item[Cape of the Goblin King]) > 0))
		foreach key in $locations[Cobb's Knob Barracks, Cobb's Knob Harem, Cobb's Knob Kitchens, Throne Room]
			kingdom[key].noquest = true;
}

void zone_sort() {
	sort order by kingdom[value].zone;
	void bubble(int first, int last) {  // bubble sort based on moxie
		boolean swapped;
		location temp;
		repeat {
			swapped = false;
			last = last - 1;
			for k from first upto last
				if(kingdom[order[k]].level > kingdom[order[k+1]].level) {
					temp = order[k];
					order[k] = order[k+1];
					order[k+1] = temp;
					swapped = true;
				}
		} until(!swapped);
	}

	int i, j;
	i = 0;
	while(i < count(order) -1) {
		j = i;
		while(j < count(order) -1 && kingdom[order[i]].zone == kingdom[order[j+1]].zone)
			j +=1;
		if(j > i) bubble(i, j);
		i = j + 1;
	}
}

string zone_to_url(place where) {
	switch(where.locnick) {
	case "Haunted Pantry":
		if(available_amount($item[Spookyraven library key]) > 0) return "manor.php"; break;
	case "Outskirts of the Knob":
		if(available_amount($item[Cobb's Knob lab key]) > 0) return "cobbsknob.php"; break;
	case "Junkyard":
		if(get_property("warProgress") != "finished") return "bigisland.php?place=junkyard"; break;
	case "McMillicancuddy's Farm":
		if(get_property("warProgress") != "finished") return "bigisland.php?place=farm"; break;
	case "Sonofa Beach":
		if(get_property("warProgress") != "finished") return "bigisland.php?place=lighthouse"; break;
	}
	if(where.zonephp.contains_text("pwd=x"))
		return where.zonephp.replace_string("pwd=x", "pwd="+my_hash());
	return where.zonephp;
}

string loc_to_url(location loc) {
	if(get_property("warProgress") != "finished")
		switch(loc) {
		case $location[Post-War Junkyard]:
			return "bigisland.php?place=junkyard";
		case $location[McMillicancuddy's Farm]:
			return "bigisland.php?place=farm";
		case $location[Post-War Sonofa Beach]:
			return $location[Wartime Sonofa Beach].to_url();
		}
	return loc.to_url();
}

string level_color(int ml) {
	int pl = my_buffedstat(stat_choice);
	if(ml < 0 || ml > pl +16)
		return level4; 		// Red
	else if(ml <= pl)
		return level1; 		// Green
	else if(ml <= pl + 8)
		return level2; 		// Yellow
	return level3; 			// Orange (ml <= pl+16)
}

string print_level(int ml) {
	return ml > monster_level_adjustment() + 9? to_string(ml):"--";
}

void table_line(location where, string color) {
	if(color == level1 && test_button("checkgreen")) {
		vars[where.to_string()] = "true";
		fields["check"+where] = "on";
	}

	string link(string link, string label) {
		string foreground = "white";
		if(color == level1 || color == level2) foreground = "black";
		return "<a class='"+ foreground +"' href='"+link+"'>"+label+"</a>";
	}
	string link_loc(location loc) {
		return link(loc_to_url(loc), kingdom[loc].locnick);
	}
	string link_zone(place where) {
		return link(zone_to_url(where), where.zone);
	}

	write("<tr id=\"tr"+ where +"\" style='");
	if((vars["hide_done"] == "true" && (fields contains ("check"+where) || (count(fields) == 0 && vars[to_string(where)] == "true")))
	  || (hide_after && kingdom[where].aftercore)
	  || (vars["hide_noquest"] == "true" && kingdom[where].noquest))
		write("display:none; ");
	write(color +"'><td>");
	vars[to_string(where)] = write_rcheck(vars[to_string(where)], "check"+where, "");
	if(kingdom[where].bossonly)
		write("</td><td align=right>>&nbsp;</td><td>");
	else
		write("</td><td align=right>"+kingdom[where].level+"&nbsp;</td><td>");
	write(link_loc(where)+ "</td><td>" +link_zone(kingdom[where])+ "</td>");
	
	if(kingdom[where].boss != $monster[none]) {
		if(kingdom[where].bosslevel == 0)
			kingdom[where].bosslevel = monster_level(kingdom[where].boss) + 9;
		else if(kingdom[where].bosslevel > 0)
			kingdom[where].bosslevel += monster_level_adjustment() + 9;
		string bosscolor = level_color(kingdom[where].bosslevel);
		write("<td style='text-align:center; "+bosscolor+"'>"+print_level(kingdom[where].bosslevel)+"</td>");
		write("<td style='"+bosscolor+"'>"+kingdom[where].bossnick+"</td>");
	}
	else write("<td></td><td></td>");
	writeln("</tr>");
}

void write_locations() {
	// Set order[]
	foreach loc, where in kingdom {
		kingdom[loc] = get_level(loc);
		if(kingdom[loc].level == 0) remove kingdom[loc];
		else order[count(order)] = loc;
	}

	if(vars["sort_type"] == "zone") zone_sort();
	else if(vars["sort_type"] == "loc") sort order by kingdom[value].locnick;
	else sort order by kingdom[value].level;
	
	writeln("<center><table border=0 cellpadding=1>");
	write("<tr><td colspan='3'><div style='font-family:Arial,Helvetica,sans-serif;'>");
	if(stat_choice == $stat[moxie])
		 write("Minimum moxie to always evade");
	else write("Minimum muscle to always hit");
	writeln("</div></td></tr>");
	writeln("<tr><th></th><th>"+stat_choice+"</th><th>Location</th><th>Zone</th><th>"+stat_choice+"</th><th>Boss</th></tr>");
	boolean atleast_one = false;
	foreach key, where in order {
		if(test_button("uncheck")) {
			vars[where.to_string()] = "false";
			remove fields["check"+where];
		} else if(test_button("check")) {
			vars[where.to_string()] = "true";
			fields["check"+where] = "on";
		}
		table_line(where, level_color(kingdom[where].level));
		atleast_one = true;
	}
	if(!atleast_one)
		write("<tr style='background-color:CC0033; color:white'><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td align=center>--</td><td>No Locations Selected</td><td></td><td align=center>---</td><td></td></tr>");
	writeln("</table></center>");
}

int write_mcd() {
	string mcd = write_select(current_mcd().to_string(), "mcd", "Set MCD: ");
	write_option(mcd, "Off", "0");
	for i from 1 to (10 + to_int(canadia_available()))
		write_option(mcd, i.to_string(), i.to_string());
	finish_select();
	return mcd.to_int();
}

void set_mcd(int mcd) {
	if(mcd != current_mcd()) {
		print("Setting MCD to "+mcd, "olive");
		change_mcd(mcd);
	}
}

void legend() {
	writeln("<table border=0 cellpadding=1>");
	writeln("<tr><td>&nbsp;</td></tr>");
	writeln("<tr><th>Legend:</th></tr>");
	if(stat_choice == $stat[moxie]) {
		writeln("<tr style='"+level1+"'><td>Safe adventuring</td></tr>");
		writeln("<tr style='"+level2+"'><td>Won't get hit much</td></tr>");
		writeln("<tr style='"+level3+"'><td>Won't always get hit</td></tr>");
		writeln("<tr style='"+level4+"'><td>Monsters will smack you up!</td></tr>");
	} else {
		writeln("<tr style='"+level1+"'><td>You smack those monsters around!</td></tr>");
		writeln("<tr style='"+level2+"'><td>You can usually hit the monster</td></tr>");
		writeln("<tr style='"+level3+"'><td>You can sometimes hit</td></tr>");
		writeln("<tr style='"+level4+"'><td>Can only hit with a critical!</td></tr>");
	}
	writeln("</table>");
}

void hide_opts() {
	write("<table border=2 rules=none frame=box cellpadding=2 align=center style='border-color:blue;'><tr><th>");
	vars["hide_done"] = write_rcheck(vars["hide_done"], "hide_done", "Hide Checked Locations");
	write("</th><td>");
	write_button("check", "Check All");
	write_button("uncheck", "Un-check All");
	write_button("checkgreen", "Check Green Locations");
	writeln("</td></tr></table>");
}

void main() {
	file_to_map("AdventureAdvisor_"+my_name()+".txt", vars);
	// First check to see if done zones are current ascension. Reset if not.
	if(vars["knownAscensions"].to_int() != my_ascensions()) {
		foreach key in vars remove vars[key];
		vars["knownAscensions"]= my_ascensions();
		vars["hide_done"] = "true";
		vars["hide_noquest"] = "true";
		vars["sort_type"] = "stat";
		map_to_file(vars, "AdventureAdvisor_"+my_name()+".txt");
	}
	version_update();
	populate_kingdom();
	// write_page()
	fields = form_fields();
	success = count(fields) > 0;
	writeln("<html><head></head><body><form name='relayform' method='POST' action=''>");

	writeln("<style type='text/css'>th {background-color:blue; color:white; font-family:Arial,Helvetica,sans-serif;}</style>");
	writeln("<style type='text/css'>a:link {color:#0000CD}");
	writeln("a:visited {color:#0000CD}");
	writeln("a:hover {color:red;}");
	writeln("a.black:link {color:black; text-decoration:none;}");
	writeln("a.black:visited {color:black; text-decoration:none;}");
	writeln("a.black:hover {color:red; text-decoration:underline}");
	writeln("a.white:link {color:white; text-decoration:none;}");
	writeln("a.white:visited {color:white; text-decoration:none;}");
	writeln("a.white:hover {color:FFFF99; text-decoration:underline;}</style>");
	// write_box()
	writeln("<fieldset><legend>"+title+"</legend>");
	write("<table border=0 cellpadding=1><tr><td colspan='3'>Choose a Stat: ");
	
	// Display options
	stat_choice = write_radio(stat_choice.to_string(), "stat_choice", "Check Moxie to Evade ", "moxie").to_stat();
	#write("</td><td>");
	write_radio(stat_choice.to_string(), "stat_choice", "Check Muscle to Hit ", "muscle");
	write("</td></tr><tr><td colspan='3'>Sort by: &nbsp;");
	vars["sort_type"] = write_radio(vars["sort_type"], "sort_type", "Stat &nbsp;", "stat");
	#write("</td><td>");
	write_radio(vars["sort_type"], "sort_type", "Location &nbsp;", "loc");
	#write("</td><td>");
	write_radio(vars["sort_type"], "sort_type", "Zone ", "zone");
	writeln("</td></tr><tr><td>");
	hide_after = write_rcheck(hide_after, "hide_after", "Hide Aftercore Locations");
	write("</td><td>");
	vars["hide_noquest"] = write_rcheck(vars["hide_noquest"], "hide_nonquest", "Hide \"No Quest\" Locations");
	write("</td></tr><tr><td colspan='3'>");
	hide_opts();
	write("</td></tr><tr><td>");
	set_mcd(write_mcd());
	write("</td><td>Currently at +"+monster_level_adjustment()+" Monster Level</td></tr><tr><td>");
	writeln("</td></tr></table>");
	writeln("</fieldset>"); 	// finish_box()
	
	writeln("<br />");
	write_button("upd", "Update Locations");
	write_locations();
	legend();
	#Adjust done locations...
	map_to_file(vars, "AdventureAdvisor_"+my_name()+".txt");
	writeln("</form></body></html>"); 	// finish_page()
}

