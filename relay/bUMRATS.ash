/*
	bUMRATS.ash
	The master relay override script. To use this, put it in your /relay/ directory and type:
	set masterRelayOverride = bUMRATS.ash
	into the CLI window. To disable this script type:
		set masterRelayOverride = 
	into the CLI window.

	0.1 - Shows the link to Paco in the beach.php
		- Total number of lucre in bhh.php
		- Spoils telescope items in campground.php (thanks, Bale!)
		- Spoils mainstat locations in cyrpt.php
		- Add link to make skeleton key(s) in dungeon.php
		- Add spoiler for DD in dungeons.php
		- Shows f'c'le items, castle items, one-click moly magnet use in fight.php
		- Spoils everything (ish) in inventory.php
		- Drop down for Virgin Booty adventure in ocean.ash
		- Protects against bad clicking in pyramid.php
		- Reminds people of the "Reminder:" in questlog.php
		- Spoils tower items in shore.php
		- Totally overwrites topmenu.php
		- One click solver for town_altar.php
		- Link to come back to here with parrot in trapper.php
		- Link to Transfunc from mystic in woods.php
	0.2 - Add stasis button, one click boulder ray use in fight.php
		- Fix bug in inventory.php
		- Add dropdown for relay_*.ash in topmenu.php
		- Fix bug with showing link to mystic if you have the Transfunc equipped in woods.php
	0.3 - Item checker in for chefstaffs in guild.php
		- Version checker in main.php
		- Change "M" and "W" to "Mall" and "Wiki" in topmenu.php.
	0.4 - Spun whole thing into one script.
	0.5 - Fixed bug whereby inventory wouldn't show items on equipping one. 
		- Fixed "red eye" bug whereby it would print the link for other items as well as the He-Boulder ray. 
	0.6 - Remove "sewer" link. The sewer is dead! Long live the chewing-gum-on-a-string!
		- Clanhop option in the topmenu.
		- Add links to the right/wrong side of the tracks to correspond to the other side's stuff.
		- Lets you know what monster you have just recieved from the fax machine.
		- Fixed chat single-click thing.
	0.7 - Upgrade the charpane to show counters. 
		- Crypt Spoilers
		- Respect settings in bumSeMan.
		- Improve shore (only tell you item if you don't have it).
	0.8 - Implement Checklist Page based on hccheck.ash
		- Implement easy Wiki Manager
	0.9 - Include the settings manager into this script.
		- Include zLib settings in the settings manager.
		- Wiki Manager now includes familiars. 
		- Fix bug where it included hagnks and display items in the shore spoiler. 
	0.10- AoB Support
		- Set some default options for CHIT.
	0.11- Made Molybdenum Magnet text a little prettier.
		- Added wiki links to all item/skill/familiar description pop ups.
		- Added traveling trader cipher.
		- Moved spoilers for the cyrpt.
		- Added IceColdFever's topmenu.  Set bumrats_useICFTopMenu to true if you want to use it.
		- Automate a lot of the pandamonium quest. 
		- Fix bug if you aren't whitelisted to any clans. 
	0.12- Incorporate some sort of networth.ash clone.
	1.00- new item file format and new items
		- a whole bunch of bug fixes
		- broken links fixed, only show knoll if musc, moved Unt, added Guild/Lair/Sea
		- decorate inv in closet and hagnks
	1.01- change location of data file and script.
	    - various HC checker fixes.
		- various bug fixes.
	1.02- move data file location changes
	1.03- new inventory format
		- HC checklist tower instruments
	1.04- the 1.03 "new" inventory format was just me playing with "Show Inventory Images". Inv detail works with and without.
		- HC checklist boris changes.
	
	
	TODO fix boulder ray for the fried egg
	TODO make skeleton key link	
	TODO fix mystic
	TODO check zombie master guild link
	TODO HC WAND CHECK FOR BUGBEAR also guild links
	TODO bottle of goofballs
	
*/

import "familiar.ash"
import "familiar_hatrack.ash"
import "clan_raidlogs.ash"
import "craft.ash"
import "charpane.ash"
import "fight.ash"
import "adventure.ash"
import "BatMan_RE.ash"
import "questlog.ash"
import "game.ash"

string ashVersion = "1.04";

//Prints a string if I want it to. Just comment out the line for debugging.
boolean debug(string write) {
	//print("DEBUG: " + write, "blue");
	return true;
}

//Prints a string always. Just if I want to debug ONE thing, not the entire script. 
boolean debugalways(string write) {
	print("DEBUG: " + write, "blue");
	return true;
}

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}

record ItemImage {
	string description;
};

record HoboStr {
	string reg;
	int good;
	string place;
};

boolean load_current_map_bum(string fname, ItemImage[string] map) {
	string domain = "http://kolmafia.co.uk/";
	string curr = visit_url(domain + fname);
	file_to_map(fname+".txt", map);
	
	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) {
		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0)  return false;
		map_to_file(map, fname+".txt");
		set_property(fname+".txt", curr);
		print("..."+fname+".txt updated.");
	}
	return true;
}

boolean load_current_image_map(string fname, ItemImage[string] map) {
	string domain = "http://kolmafia.co.uk/";
	
	string curr = visit_url(domain + fname + ".txt");
	file_to_map(fname+".txt", map);
	
	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) {
		print("Updating "+fname+".txt"); // from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0)  return false;
		map_to_file(map, fname+".txt");
		set_property(fname+".txt", curr);
		print("..."+fname+".txt updated.");
	}
	return true;
}

boolean load_current_image_map2(string fname, ItemImage[string] map) {

	file_to_map(fname+".txt", map);
	return true;
	
}



void bcheader() {
	writeln("<html>");
	writeln("<head>");
	writeln("<title>bumcheekcity's bUMRATS</title>");
	writeln("<style type='text/css'>");
	writeln("* {font-family: Verdana, Arial;font-size:10px;}");
	writeln("#wrapper {width: 95%; margin: auto; border: 2px solid black;}");
	writeln("legend {font-weight: bold; font-size: 14px;}");
	writeln("ul.tabbernav {margin:0; padding: 3px 1px 0; border-bottom: 1px solid black; font: bold 12px Verdana, sans-serif;}");
	writeln("ul.tabbernav li {list-style: none; margin: 0; display: inline;}");
	writeln("ul.tabbernav li input {padding: 3px 0.5em; margin-left: 3px; border: 1px solid black; border-bottom: 1px solid black; background: #DDDDEE; text-decoration: none;}");
	writeln("ul.tabbernav li input:hover {color: #000000; background: #AAAAEE; border-color: black;}");
	writeln("ul.tabbernav li.tabberactive input {background-color: white; border-bottom: 1px solid white;}");
	writeln("ul.tabbernav li.tabberactive input:hover {color: #000000; background: white; border-bottom: 1px solid white;}");
	writeln("</style>");
	writeln("</head>");
	writeln("</body>");
	writeln("<div id='wrapper'>");
}

void bcfooter() {
	writeln("</div>");
	writeln("</body");
	writeln("</html>");
}

void bumcheek_beach() {
	buffer results;
	results.append(visit_url());
	
	string beach = "<a href='guild.php?place=paco'>Go see paco...</a>";
	results.replace_string("Desert Beach is.</td></tr>", "Desert Beach is.</td></tr><tr><td>" + beach + "</td></tr>");
	
	results.write();
}

void bumcheek_bhh() {
	buffer results;
	results.append(visit_url());
	
	string bhh = "You have a total of <b>"+i_a("filthy lucre")+"</b> <img src='http://images.kingdomofloathing.com/itemimages/lucre.gif' /> Filthy Lucre in all sources.";
	results.replace_string("I only accept filthy lucre.", "I only accept filthy lucre.<b><p><center>"+bhh+"</center></p></b>");
	
	results.write();
}

void bumcheek_campground() {
	buffer results;
	results.append(visit_url());
	if(results.contains_text("You peer into the eyepiece of the telescope")) {
		
		record lair {
			string mob;
			string a;
			item kill;
			string where;
		};
		lair [string] telescope;
			telescope["catch a glimpse of a flaming katana"] = new lair("a flaming samurai", "a ", $item[frigid ninja stars], "from any Ninja Snowman at their lair on Mt McLarge Hugh");
			telescope["catch a glimpse of a translucent wing"] = new lair("a pretty fly", "a ", $item[spider web], "from any spider at the Sleazy Back Alley");
			telescope["see a fancy-looking tophat"] = new lair("a bowling cricket", "a ", $item[sonar-in-a-biscuit], "from any bat at Guano Junction");
			telescope["see a flash of albumen"] = new lair("a giant fried egg", "", $item[black pepper], "from a Black Spider's black picnic basket at the Black Woods");
			telescope["see a giant white ear"] = new lair("an endangered inflatable white tiger", "a ", $item[pygmy blowgun], "from a Pygmy Blowgunner at the Hidden City");
			telescope["see a huge face made of Meat"] = new lair("a big meat golem", "a ", $item[meat vortex], "from a Me4t BegZ0r at the Orc Chasm");
			telescope["see a large cowboy hat"] = new lair("Tyrannosaurus Tex", "a ", $item[chaos butterfly], "in the Giant Castle (ground floor)");
			telescope["see a periscope"] = new lair("an electron submarine", "a ", $item[photoprotoneutron torpedo], "from a MagiMechTech MechaMech in the Fantasy Airship");
			telescope["see a slimy eyestalk"] = new lair("a fancy bath slug", "", $item[fancy bath salts], "from a Claw-foot Bathtub in the Haunted Bathroom");
			telescope["see a strange shadow"] = new lair("the darkness", "an ", $item[inkwell], "from a Writing Desk in the Haunted Library");
			telescope["see moonlight reflecting off of what appears to be ice"] = new lair("an ice cube", "", $item[hair spray], "which is for sale in the Market");
			telescope["see part of a tall wooden frame"] = new lair("a vicious easel", "a ", $item[disease], "in the \"Fun\" House or Knob Harem");
			telescope["see some amber waves of grain"] = new lair("a malevolent crop circle", "a ", $item[bronzed locust], "from a Plaque of Locusts at the Arid Extra-Dry Desert");
			telescope["see some long coattails"] = new lair("a concert pianist", "a ", $item[Knob Goblin firecracker], "from a Sub-Assistant Knob Mad Scientist at the outskirts of Cobb's Knob");
			telescope["see some pipes with steam shooting out of them"] = new lair("a possessed pipe-organ", "", $item[powdered organs], "from a Tomb Servant's canopic jar at the middle chamber of the Pyramid");
			telescope["see some sort of bronze figure holding a spatula"] = new lair("the Bronze Chef", "", $item[leftovers of indeterminate origin], "from a Demonic Icebox in the Haunted Kitchen");
			telescope["see the neck of a huge bass guitar"] = new lair("El Diablo", "a ", $item[mariachi G-string], "from an Irate Mariachi, south of the border");
			telescope["see what appears to be the North Pole"] = new lair("a giant desktop globe", "an ", $item[NG], "by pasting a 'lowercase n' from XXX pr0n to an 'original G' from an Alphabet Giant");
			telescope["see what looks like a writing desk"] = new lair("a best-selling novelist", "a ", $item[plot hole], "in the Giant Castle (ground floor)");
			telescope["see the tip of a baseball bat"] = new lair("beer batter", "a ", $item[baseball], "from a Baseball Bat at Guano Junction");
			telescope["see what seems to be a giant cuticle"] = new lair("the fickle finger of f8", "a ", $item[razor-sharp can lid], "from any can in the Haunted Pantry");
			telescope["see a pair of horns"] = new lair("an enraged cow", "", $item[barbed-wire fence], "by taking a Mountain vacation");
			telescope["see a formidable stinger"] = new lair("a giant bee", "a ", $item[tropical orchid], "by taking an Island vacation");
			telescope["see a wooden beam"] = new lair("a collapsed mineshaft golem", "a ", $item[stick of dynamite], "by taking a Ranch vacation");
			
			telescope["an armchair"] = new lair("", "", $item[pygmy pygment], "from a Pygmy Assault Squad at the Hidden City");
			telescope["a cowardly-looking man"] = new lair("", "a ", $item[wussiness potion], "from a W Imp at Friar's Gate");
			telescope["a banana peel"] = new lair("", "", $item[gremlin juice], "from any gremlin in the Junkyard");
			telescope["a coiled viper"] = new lair("", "an ", $item[adder bladder], "from a Black Adder at the Black Forest");
			telescope["a rose"] = new lair("", "", $item[Angry Farmer candy], "from a Raver Giant in the Giant Castle top floor (or other candy)");
			telescope["a glum teenager"] = new lair("", "a ", $item[thin black candle], "in the Giant Castle (top floor)");
			telescope["a hedgehog"] = new lair("", "", $item[super-spiky hair gel], "from a Protagonist in the Penultimate Fantasy Airship");
			telescope["a raven"] = new lair("", "", $item[Black No. 2], "from a Black Panther at the Black Forest");
			telescope["a smiling man smoking a pipe"] = new lair("", "", $item[Mick's IcyVapoHotness Rub], "in the Giant Castle (basement)");
		
		int i1 = results.index_of("You focus the telescope");
		results.delete(i1, results.index_of("Unfortunately, you"));
		
		if(get_property("lastTelescopeReset") != get_property("knownAscensions"))
			cli_execute("telescope");
		string view;
		// Work backwards, inserting each line in front of the previous.
		for level from get_property("telescopeUpgrades").to_int() downto 1 {
			view = get_property("telescope"+level);
			if(level == 1) {
				results.insert(i1,"<p>You raise the telescope a little higher, and see the base of a tall brick tower.</p>");
				if(available_amount(telescope[view].kill) < 1)
					results.insert(i1,"<p>At the entrace of the cave you see a wooden gate with an elaborate carving of "+view
					  +". To pass the test will require "+telescope[view].a+"<span style=\"color:red; font-weight:bold\">"
					  +telescope[view].kill+"</span> which you need to get "+telescope[view].where+".</p>");
				 else
					results.insert(i1, "<p><span style=\"color:green\">At the entrace of the cave you see a wooden gate with an elaborate carving of "+view
					  +". You can pass that test because you have "+telescope[view].a+telescope[view].kill+".</span></p>");
			} else {
				if(telescope[view].kill == $item[hair spray] && get_property("autoSatisfyWithNPCs") == "true")
					results.insert(i1, "<p><span style=\"color:green\">On floor "+to_string(level-1)+", you see "
					  +telescope[view].mob+". You can always purchase "+telescope[view].a+telescope[view].kill+" to kill it with.</span></p>");
				else if(available_amount(telescope[view].kill) < 1)
					results.insert(i1, "<p>On floor "+to_string(level-1)+", you see "+telescope[view].mob
					  +". To kill it you need to get "+telescope[view].a+"<span style=\"color:red; font-weight:bold\">"
					  +telescope[view].kill+"</span> "+telescope[view].where+".</p>");
				else
					results.insert(i1, "<p><span style=\"color:green\">On floor "+to_string(level-1)+", you see "
					  +telescope[view].mob+". You have "+telescope[view].a+telescope[view].kill+" to kill it with.</span></p>");
			}
		}
	} else if(get_property("telescopeUpgrades") != 0)  // Add link at top of page to peer at lair
		results.replace_string("<body>\n<centeR>", "<body>\n<centeR><a target=mainpane href=\"campground.php?action=telescopelow\">Peer at Sorceress' Lair</a>");
	results.write();
}

void bumcheek_charpane() {
	if (get_property("bumrats_changeCharpane") == "false") return;

	buffer results;
	results.append(visit_url());
	
	//Make Char Image Smaller
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/sealclubber_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/turtletamer_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/pastamancer_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/sauceror_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/discobandit_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/accordionthief_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/sealclubber_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/turtletamer_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/pastamancer_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/sauceror_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/discobandit_f.gif\" width=60 height=100 border=0>", "");
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/accordionthief_f.gif\" width=60 height=100 border=0>", "");
	
	//Make the other images smaller
	results.replace_string("<img src", "<img width=20 height=20 src");
	results.replace_string("class=hand", "");
	
	//Make TDs small
	results.replace_string("<td", "<td style='font-size:10px'");
	
	results.replace_string("<center>You'd better keep an eye on your drinking...</center>", "");
	results.replace_string("<font size=2", "<font size=1");
	
	results.write();
}

void bumcheek_charpane_chit() {
	string [string] chitSource;
	string [string] chitBricks;
	string [string] chitPickers;
	string [string] chitTools;
	string [string] chitEffectsMap;
	boolean isCompact = false;
	boolean inValhalla = false;
	string imagePath = "http://bumcheekcity.com/kol/bumrats/";
	string chitVersion = "0.5";

	/*****************************************************
		String functions
	*****************************************************/

	string formatInt(int n) {
		//copied and adapted from zlib's rnum to also handle 4-digit numbers
		buffer cr;
		boolean neg;
		if (n < 0) { neg = true; n = -n; }
		cr.append(to_string(n));
		if (cr.length() > 3) for i from 1 to floor((cr.length()-1) / 3.0)
			cr.insert(cr.length()-(i*3)-(i-1),",");
		if (neg) return "-" + to_string(cr);
		return to_string(cr);
	}
	
	string formatInt(float f) {
		return formatInt(to_int(f));
	}

	string formatStats(int buffed, int unbuffed) {
		if (buffed > unbuffed) {
			return '<span style="color:blue">' + formatInt(buffed) + '</span>&nbsp;&nbsp;(' + unbuffed + ')';
		} else if (buffed < unbuffed) {
			return '<span style="color:red">' + formatInt(buffed) + '</span>&nbsp;&nbsp;(' + unbuffed + ')';
		}
		return to_string(buffed);
	}

	string formatModifier(int modifier) {
		if( modifier > 0 ) {
			return "+" + formatInt(modifier);
		}
		return formatInt(modifier);
	}

	string formatModifier(float modifier) {
		if( modifier > 0 ) {
			return "+" + round(modifier*100)/100.0 + "%";
		}
		return "" + round(modifier*100)/100.0 + "%";
	}

	string progressSubStats(int mainstat, int substat) {
		int lower = mainstat**2;
		int upper = (mainstat + 1)**2;
		int range = upper - lower;
		int current = substat - lower;
		int needed = range - current;
		float progress = (current * 100.0) / range;
		return '<div class="progressbox" title="' + current + ' / ' + range + ' (' + needed + ' needed)"><div class="progressbar" style="width:' + progress + '%"></div></div>';
	}

	string progressCustom(int current, int limit, string hover, int severity, boolean active) {
		string color = "";
		string title = "";
		string border = "";
		
		switch (severity) {
			case -1	: color = "#D0D0D0"; 	break;		//disabled
			case 0	: color = "blue"; 		break;		//neutral
			case 1	: color = "green"; 		break;		//good
			case 2	: color = "orange"; 	break;		//bad
			case 3	: color = "red"; 		break;		//ugly
			case 4	: color = "#707070"; 	break;		//full
			case 5	: color = "black"; 		break;		//busted
			default	: color = "blue";
		}
		switch (hover) {
			case "" : title = ""; break;
			case "auto": title = ' title="' + current + ' / ' + limit + '"'; break;
			default: title = ' title="' + hover +'"';
		}
		if (active) border = ' style="border-color:#707070"';
		if (limit == 0) limit = 1;
		
		float progress = (min(current, limit) * 100.0) / limit;
		buffer result;
		result.append('<div class="progressbox"' + title + border + '">');
		result.append('<div class="progressbar" style="width:' + progress + '%;background-color:' + color + '"></div>');
		result.append('</div>');
		return result.to_string();
	}


	string helperDanceCard() {
		//Bail if the user doesn't want to see the helper
		string pref = get_property("bumrats_chit.helpers.dancecard");
		if (pref != "true") {
			return "";
		}
		
		buffer result;
		result.append('<table id="chit_matilda" class="chit_brick" cellpadding="0" cellspacing="0">');
		result.append('<tr><th colspan="2">Dance Card</th></tr>');
		result.append('<tr>');
		result.append('<td class="icon" width="30"><img src="images/itemimages/guildapp.gif"></td>');
		result.append('<td class="location">');
		result.append('<a href="' + to_url($location[Haunted Ballroom]) + '" class="visit" target="mainpane">Haunted Ballroom</a>');
		result.append('You have a date with Matilda');
		result.append('</td>');
		result.append('</tr>');
		result.append('</table>');
		chitTools["helpers"] = "You have some expired counters|helpers.png";
		return result.to_string();
	}

	string helperWormwood() {
		//Bail if the user doesn't want to see the helper
		string pref = get_property("bumrats_chit.helpers.wormwood");
		if (pref == "none" || pref == "") {
			return "";
		}
		
		// Set up all the location and reward data
		location [string] zones;
			zones["windmill"] = $location[rogue windmill];
			zones["mansion"] = $location[mouldering mansion];
			zones["dome"] = $location[stately pleasure dome];
				
		string [string] rewards;
			rewards["moxie"] = "discomask.gif|Gain Moxie Substats";
			rewards["muscle"] = "strboost.gif|Gain Muscle Substats";
			rewards["mysticality"] = "wand.gif|Gain Mysticality Substats";
			rewards["pipe"] = "notapipe.gif|Not-a-pipe";
			rewards["mask"] = "ballmask.gif|fancy ball mask";
			rewards["cancan"] = "cancanskirt.gif|Can-Can skirt";
			rewards["food"] = "sammich.gif|S.T.L.T.";
			rewards["necklace"] = "albaneck.gif|albatross necklace";
			rewards["booze"] = "flask.gif|flask of Amontillado";
			
		string [string, int] targets;
			targets["moxie", 9] = "windmill|Check the upstairs apartment|Absinthe-Minded";
			targets["moxie", 5] = "mansion|Approach the Man|Absinthe-Minded";
			targets["moxie", 1] = "dome|Walk the main deck|Absinthe-Minded";
			targets["muscle", 9] = "dome|Swim laps in the pool|Absinthe-Minded";
			targets["muscle", 5] = "windmill|Pitch in and help|Absinthe-Minded";
			targets["muscle", 1] = "mansion|Open the door|Absinthe-Minded";
			targets["mysticality", 9] = "mansion|Climb to the second floor|Absinthe-Minded";
			targets["mysticality", 5] = "dome|Ponder the measureless expanse |Absinthe-Minded";
			targets["mysticality", 1] = "windmill|Chat with the midnight tokers|Absinthe-Minded";
			
			targets["pipe", 9] = "dome|Wade in the Alph|Absinthe-Minded";
			targets["pipe", 5] = "mansion|Approach the Cat|Spirit of Alph";
			targets["pipe", 1] = "windmill|Chat with the jokers|Feelin' Philosophical";
			targets["mask", 9] = "dome|Wade in the Alph|Absinthe-Minded";
			targets["mask", 5] = "windmill|Pitch yourself into showbusiness|Spirit of Alph";
			targets["mask", 1] = "mansion|Ascend|Dancing Prowess";
			targets["cancan", 9] = "mansion|Climb to the belfry|Absinthe-Minded";
			targets["cancan", 5] = "dome|Investigate a nearby squeaky noise|Bats in the Belfry";
			targets["cancan", 1] = "windmill|Chat with the smokers|Good with the Ladies";
			targets["food", 9] = "mansion|Climb to the belfry|Absinthe-Minded";
			targets["food", 5] = "windmill|Pitch yourself up the stairs|Bats in the Belfry";
			targets["food", 1] = "dome|Go up to the crow's nest|No Vertigo";
			targets["necklace", 9] = "windmill|Check out the restrooms|Absinthe-Minded";
			targets["necklace", 5] = "mansion|Approach the Woman|Rat-Faced";
			targets["necklace", 1] = "dome|Check out the helm|Unusual Fashion Sense";
			targets["booze", 9] = "windmill|Check out the restrooms|Absinthe-Minded";
			targets["booze", 5] = "dome|Explore some side-tunnels|Rat-Faced";
			targets["booze", 1] = "mansion|Descend|Night Vision";
			
		//Normalize turns of Absinthe-Minded remaining
		int absinthe = have_effect($effect[Absinthe-Minded]);
		if(absinthe > 5) {
			absinthe = 9;
		} else if (absinthe > 1) {
			absinthe = 5;
		} else {
			absinthe = 1;
		}
		
		string [int] goals = split_string(pref, ",");	//split desired goals into separate strings
		string goal;											
		string goalname;
		string goalturns;
		
		//Helper functions to normalize goals
		string fix_goalname() {
			switch {
			case goal == "":
			case contains_text(goal, "none"):
				return "none";
			case contains_text(goal, "pipe"):
			case contains_text(goal, "spleen"):
				return "pipe";
			case contains_text(goal, "flask"):
			case contains_text(goal, "amont"):
			case contains_text(goal, "booze"):
				return "booze";
			case contains_text(goal, "s.t.l"):
			case contains_text(goal, "stl"):
			case contains_text(goal, "s t l"):
			case contains_text(goal, "s. t. l"):
			case contains_text(goal, "food"):
				return "food";
			case contains_text(goal, "reward"):
				return "rewards";
			case contains_text(goal, "main"):
				return to_string(my_primestat()).to_lower_case();
			case contains_text(goal, "stat"):
				return "stats";
			case contains_text(goal, "mus"):
				return "muscle";
			case contains_text(goal, "mox"):
				return "moxie";
			case contains_text(goal, "mys"):
				return "mysticality";
			case contains_text(goal, "fancy"):
			case contains_text(goal, "ball"):
			case contains_text(goal, "mask"):
			case contains_text(goal, "hat"):
				return "mask";
			case contains_text(goal, "albat"):
			case contains_text(goal, "nec"):
			case contains_text(goal, "acc"):
				return "necklace";
			case contains_text(goal, "can"):
			case contains_text(goal, "skirt"):
			case contains_text(goal, "pant"):
				return "cancan";
			default:
				return "none";		//If we can't recognize it, we'll ignore it...
			}
			return "none";
		}
		string fix_goalturns() {
			switch {
			case contains_text(goal, "9"):
				return "951";
			case contains_text(goal, "5"):
				return "51";
			case contains_text(goal, "1"):
				return "1";
			default:
				return "951";
			}
			return "951";
		}
		
		//Compile a (sorted) list of goals to include
		string [string] goallist;
		
		for i from 0 to goals.count()-1 {
			
			goal = replace_string(goals[i], " ", "").to_string().to_lower_case();
			
			goalname = fix_goalname();
			goalturns = fix_goalturns();
			
			if (contains_text(goalturns, to_string(absinthe))) {
				switch (goalname) {
				case "none":
					break;
				case "stats":
					goallist[i + "a"] = "muscle";
					goallist[i + "b"] = "mysticality";
					goallist[i + "c"] = "moxie";
					break;
				case "rewards":
					goallist[i + "a"] = "pipe";
					goallist[i + "b"] = "mask";
					goallist[i + "c"] = "cancan";
					goallist[i + "d"] = "food";
					goallist[i + "e"] = "booze";
					goallist[i + "f"] = "necklace";
					break;
				default:
					goallist[to_string(i)] = goalname;
				}
			}
		}
		
		string [3] target;
		string [2] reward;
		location zone;
		effect musthave;
		string hint;
		buffer result;
		buffer rowdata;
		int rows = 0;
		int [string] addeditems;
		
		//Iterate through the normalized list of goals, and show only those that are still achievable (based on required effects)
		foreach key, value in goallist {
			if (!(addeditems contains value)) {
				reward = split_string(rewards[value], "\\|");
				target = split_string(targets[value, absinthe], "\\|");
				zone = zones[target[0]];
				hint = target[1];
				musthave = to_effect(target[2]);		
				if (have_effect(musthave) > 0) {
					rowdata.append('<tr class="section">');
					rowdata.append('<td class="icon" title="' + reward[1] + '"><img src="images/itemimages/' + reward[0] + '"></td>');
					rowdata.append('<td class="location" title="' + reward[1] + '"><a class="visit" target="mainpane" href="' + to_url(zone) + '">' + to_string(zone) + '</a>' + hint + '</td>');
					rowdata.append('<tr>');
					rows = rows + 1;
					addeditems[value] = 1;
				}
			}
		}
		
		//wrap everything up in a pretty table
		if (rows > 0) {
			result.append('<table id="chit_wormwood" class="chit_brick" cellpadding="0" cellspacing="0">');
			result.append('<tr class="helper"><th colspan="2">Wormwood</th></tr>');
			result.append(rowdata);
			result.append('</table>');
			
			chitTools["helpers"] = "You have some expired counters|helpers.png";
		}
		
		return result;
	}

	string helperSemiRare() {
		//Bail if the user doesn't want to see the helper
		string pref = get_property("bumrats_chit.helpers.semirare");
		if (pref != "true") {
			return "";
		}
		
		buffer result;
		
		//Set up all the locations we support
		string [location] rewards;
			rewards[$location[sleazy back alley]] = "wine.gif|Distilled fotified wine (3)|0";
			rewards[$location[haunted pantry]] = "pie.gif|Tasty tart (3)|0";
			rewards[$location[limerick dungeon]] = "eyedrops.gif|cyclops eyedrops|21";
			rewards[$location[orc chasm]] = "scroll2.gif|Fight Bad ASCII Art|68";
			rewards[$location[giant's castle (top floor)]] = "inhaler.gif|Mick's IcyVapoHotness Inhaler|95";
			rewards[$location[kitchens]] = "elitehelm.gif|Fight KGE Guard Captain|20";
			rewards[$location[outskirts of the knob]] = "lunchbox.gif|Knob Goblin lunchbox|0";
			
		int lastCounter = to_int(get_property("semirareCounter"));
		string lastLocation = get_property("semirareLocation");
		location lastZone = to_location(lastLocation);
		string message;
		
		if (lastCounter == 0) {
			message = "No semirare so far during this ascension";
		} else {
			message = "Last semirare found " + (turns_played()-lastCounter) + " turns ago (on turn " + lastCounter + ") in " + lastZone;	
		}
		
		//Iterate through all the predefined zones
		string[3] reward;
		buffer rowdata;
		int rows = 0;
		foreach zone, value in rewards {
			reward = split_string(value, "\\|");
			if (zone != lastZone) {
				if (my_basestat(my_primestat()) >= to_int(reward[2])) {
					rowdata.append('<tr class="section">');
					rowdata.append('<td class="icon" width="30" title="' + reward[1] + '"><img src="images/itemimages/' + reward[0] + '"></td>');
					rowdata.append('<td class="location" title="' + reward[1] + '"><a class="visit" target="mainpane" href="' + to_url(zone) + '">' + to_string(zone) + '</a>' + reward[1] + '</td>');
					rowdata.append('</tr>');
					rows = rows + 1;
				}
			}
		}
		
		//wrap everything up in a pretty table
		if (rows > 0) {
			result.append('<table id="chit_semirares" class="chit_brick" cellpadding="0" cellspacing="0">');
			result.append('<tr class="helper"><th colspan="2">Semi-Rares</th></tr>');
			result.append('<tr>');
			result.append('<td class="info" colspan="2">' + message + '</td>');
			result.append('</tr>');
			result.append(rowdata);
			result.append('</table>');		
			chitTools["helpers"] = "You have some expired counters|helpers.png";
		}
		
		return result;
	}

	//SIMON MODIFIED TYPE
	record bumbuff {
		string effectImage;
		string effectName;
		string effectType;
		string effectStyle;
		string effectAlias;
		string effectHTML;
		int effectTurns;
		boolean isIntrinsic;
	};

	bumbuff parseBuff(string source, boolean isIntrinsic) {
		bumbuff myBuff;
		
		boolean onTrail = (index_of(source, "On the Trail") > 0);
		boolean isBird = (index_of(source, "Form of...Bird!") > 0);
		isIntrinsic = (index_of(source, "&infin;") > 0);
		myBuff.isIntrinsic = isIntrinsic;
		boolean canShrug = true;
		boolean doArrows = get_property("relayAddsUpArrowLinks").to_boolean();
		
		string columnIcon = "";
		string columnEffect = "";
		string columnTurns = "";
		string columnArrow = "";
		matcher pattern;
		
		boolean showIcons = true;
		if ( (get_property("bumrats_chit.effects.showicons")=="false") || isCompact) {
			showIcons = false;
		}
		
		//Split source row into the 2 columns
		string column1;
		string column2;
		matcher columnMatcher = create_matcher("<td\>(.*?)</td\><td(.*?)\>(.*?)</td\>", source);
		if (find(columnMatcher)) {
			column1 = group(columnMatcher, 1);
			column2 = group(columnMatcher, 3);
		}
		
		//Get Effect Name
		if (onTrail) {
			myBuff.effectName = "On the Trail";
		}  else if (isBird) {
			myBuff.effectName = "Form of...Bird!";
		} else {
			pattern = create_matcher("\>(.*?) \\(", column2);
			if (find(pattern)) {
				myBuff.effectName = group(pattern, 1);
			} else {
				myBuff.effectName = "Oops";
			}
		}
		
		//Get Image
		columnIcon = column1;
		pattern = create_matcher('<img src=\\"/images/itemimages/(.*?)\\"', column1);
		if (find(pattern)) {
			myBuff.effectImage = group(pattern, 1);
		}
		
		//Get turns
		string spoiler;
		string turns;
		if (onTrail) {
			pattern = create_matcher("On the Trail \\((.*?), (.*?)\\)", column2);
			if (find(pattern)) {
				spoiler = group(pattern, 1);
				turns = group(pattern, 2);
			}
		
		} else if (isBird) {
			pattern = create_matcher("\\((.*?), (\\d+)\\)", column2);
			if (find(pattern)) {
				spoiler = group(pattern, 1);
				turns = group(pattern, 2);
			} else {
				pattern = create_matcher("\\((.*?)\\)", column2);
				if (find(pattern)) {
					turns = group(pattern, 1);
				}
			}
				
		} else {
			//pattern = create_matcher("\\(<a (.*?)</a\>\\)", column2);
			pattern = create_matcher("\\((<a .*?</a\>)\\)", column2);
			if (find(pattern)) {
				turns = group(pattern, 1);
			} else {
				pattern = create_matcher("\\((.*?)\\)", column2);
				if (find(pattern)) {
					turns = group(pattern, 1);
				}
			}
		}
		
		//(<a href="/KoLmafia/sideCommand?cmd=uneffect+A+Little+Bit+Evil+%28Accordion+Thief%29&pwd=706b759ccd3b4a
		//423a7300f9f0c2fa7c" title="Use a remedy to remove the A Little Bit Evil (Accordion Thief) effect">10</a>)
		
		canShrug = false;
		if (isIntrinsic) {
			myBuff.effectTurns = 0;
		} else 
			pattern = create_matcher("\>(.*?)<", turns);
			if (find(pattern)) {
				myBuff.effectTurns = to_int(group(pattern, 1));
				canShrug = true;
			} else if (is_integer(turns)) {
				myBuff.effectTurns = to_int(turns);
			} else {
				myBuff.effectTurns = 0;
		}
		columnTurns = turns;
		
		//Get Arrows
		if (doArrows) {
			if (myBuff.effectTurns == 0) {
				pattern = create_matcher("\\)</font\>&nbsp;(<a .*?</a\>)", column2);
			} else {
				//pattern = create_matcher("\\)&nbsp;<a (.*?)</a\>", column2);
				pattern = create_matcher("\\)&nbsp;(<a .*?</a\>)", column2);
			}
			if (!isIntrinsic && find(pattern)) {
				columnArrow = group(pattern, 1).replace_string("/images/up.gif", imagePath + "up.png").replace_string("/images/redup.gif", imagePath + "upred.png");
				//columnArrow = "<a " + columnArrow + "</a>";
			} else {
				columnArrow = "&nbsp;";
			}
		}
		
		//Apply any styling/renaming as specified in effects map
		if (chitEffectsMap contains myBuff.effectName) {
			pattern = create_matcher('type:\"(.*?)\"', chitEffectsMap[myBuff.effectName]);
			if (find(pattern)) {
				mybuff.effectType = group(pattern, 1);
			}
			pattern = create_matcher('alias:\"(.*?)\"', chitEffectsMap[myBuff.effectName]);
			if (find(pattern)) {
				mybuff.effectAlias = group(pattern, 1);
			} else {
				mybuff.effectAlias = myBuff.effectName;
			}
			pattern = create_matcher('style:\"(.*?)\"', chitEffectsMap[myBuff.effectName]);
			if (find(pattern)) {
				mybuff.effectStyle = group(pattern, 1);
			}
		} else {
			myBuff.effectAlias = myBuff.effectName;
		}
		
		//Add spoiler info
		if (onTrail) {
			myBuff.effectAlias = myBuff.effectAlias + spoiler;
		} else if (isBird && spoiler != "") {
			myBuff.effectAlias = myBuff.effectAlias + spoiler;
		}
		
		//Replace effect icons, if enabled
		string [string] classmap;
		classmap["at"] = "accordion.gif";
		classmap["sc"] = "club.gif";
		classmap["tt"] = "turtle.gif";
		classmap["sa"] = "saucepan.gif";
		classmap["pm"] = "pastaspoon.gif";
		classmap["db"] = "discoball.gif";
		
		if ((index_of(get_property("bumrats_chit.effects.classicons"), myBuff.effectType) > -1) && (classmap contains myBuff.effectType)) {
			columnIcon =  columnIcon.replace_string(myBuff.effectImage, classmap[myBuff.effectType]);
		}
		
		//Uncomment line below to hide effect discriptions (Temporary ugly hack)
		//myBuff.effectAlias = "";
		
		buffer result ;
		result.append('<tr class="effect" style="' + myBuff.effectStyle + '">');
		if (showIcons) {
			result.append('<td class="icon">' + columnIcon + '</td>');
		}
		if (isIntrinsic) {
			if (doArrows) {
				result.append('<td class="info" colspan="2">' + myBuff.effectAlias + '</td>');
				result.append('<td class="infinity">&infin;</td>');
			} else {
				result.append('<td class="info">' + myBuff.effectAlias + '</td>');
				result.append('<td class="infinity right">&infin;</td>');
			}
		} else {
			result.append('<td class="info">' + myBuff.effectAlias + '</td>');
			if (!doArrows) {
				result.append('<td class="right">' + columnTurns + '</td>');
			} else if (canShrug) {
				result.append('<td class="shrug">' + columnTurns + '</td>');
			} else {
				result.append('<td class="noshrug">' + columnTurns + '</td>');
			}
			if (doArrows) {
				if (columnArrow == "") {
					result.append('<td>&nbsp;</td>');
				} else {
					result.append('<td class="powerup">' + columnArrow + '</td>');
				}
			}
		}
		result.append('</tr>');
		
		myBuff.effectHTML = result.to_string();
		
		return myBuff;
	}

	void bakeEffects() {
		buffer result;
		buffer buffs;
		buffer intrinsics;
		buffer songs;
		buffer helpers;
		bumbuff[int] cookies;
		int total = 0;
		int buffCount = 0;
		int intrinsicCount = 0;
		int songCount = 0;
		
		//Get layout preferences
		string layout = get_property("bumrats_chit.effects.layout").to_lower_case().replace_string(" ", "");
		if (layout == "") layout = "buffs,intrinsics";
		boolean showSongs = contains_text(layout,"songs");
		
		//Load effects map
		string mapfile = "chit_effects.txt";
		if (get_property("bumrats_chit.effects.usermap") == "true") {
			mapfile = "chit_effects_" + my_name() + ".txt";
		}
		if (!file_to_map(mapfile, chitEffectsMap)) {
			print("CHIT: Effects map could not be loaded (" + mapfile + ")", "purple");
		}
		
		bumbuff currentbuff;
		
		//Regular Effects
		matcher rowMatcher = create_matcher("<tr\>(.*?)</tr\>", chitSource["effects"]);
		while (find(rowMatcher)) {
			currentbuff = parseBuff(group(rowMatcher, 1), false);
			
			if ( (get_property("bumrats_chit.effects.wrapCookie") == true) && (currentBuff.effectName == "Fortune Cookie") ) {
				if (count(cookies) == 0) buffs.append("<COOKIES>");
				cookies[count(cookies)]=currentbuff;
				buffCount += 1;
				total += 1;
				continue;
			}
			if (currentBuff.isIntrinsic) {
				intrinsics.append(currentbuff.effectHTML);
				intrinsicCount += 1;
			} else if ((currentbuff.effectType == "at") && showSongs) {
				songs.append(currentbuff.effectHTML);
				songCount += 1;
			} else {
				buffs.append(currentbuff.effectHTML);
				buffCount += 1;
			}
			total += 1;
			
			if (currentbuff.effectTurns == 0) {
				if (currentbuff.effectName == "Fortune Cookie")  {
					helpers.append(helperSemiRare());
				}
				if (currentbuff.effectName == "Wormwood")  {
					helpers.append(helperWormwood());
				}
				if (currentbuff.effectName == "Dance Card")  {
					helpers.append(helperDanceCard());
				}
			}
		}
		
		if (count(cookies) > 0){
			matcher m=create_matcher("(<a .+?>\\d+</a>)","");
			for i from 1 upto count(cookies)-1 {
				m.reset(cookies[i].effectHTML);
				if (!m.find()) continue;
				cookies[0].effectHTML=replace_string(cookies[0].effectHTML,"</a\></td\>","</a>, "+m.group(1)+"</td>").to_string();
			}
			cookies[0].effectHTML=replace_string(cookies[0].effectHTML,"<td class=\"sh","<td colspan=\"2\" class=\"sh").to_string();
			cookies[0].effectHTML=replace_string(cookies[0].effectHTML,"<td class=\"powerup\">&nbsp;</td>","").to_string();
			buffs.replace_string("<COOKIES>",cookies[0].effectHTML);
		}
		//Intrinsic Effects
		rowMatcher = create_matcher("<tr\>(.*?)</tr\>", chitSource["intrinsics"]);
		while (find(rowMatcher)){
			currentbuff = parseBuff(group(rowMatcher, 1),true);
			intrinsics.append(currentbuff.effectHTML);
			intrinsicCount = intrinsicCount + 1;
			total = total + 1;
		}

		if (intrinsicCount > 0 ) {
			intrinsics.insert(0, '<tbody class="intrinsics">');
			intrinsics.append('</tbody>');
		}
		if (songCount > 0 ) {
			songs.insert(0, '<tbody class="songs">');
			songs.append('</tbody>');
		}
		if (buffCount > 0) {
			buffs.insert(0, '<tbody class="buffs">');
			buffs.append('</tbody>');
		}
		
		if (total > 0) {
			result.append('<table id="chit_effects" class="chit_brick" cellpadding="0" cellspacing="0">');
			result.append('<thead><tr><th colspan="4">Effects</th></tr></thead>');
			string [int] drawers = split_string(layout, ",");
			for i from 0 to (drawers.count() - 1) {
				switch (drawers[i]) {
					case "buffs": result.append(buffs); break;
					case "songs": result.append(songs); break;
					case "intrinsics": result.append(intrinsics); break;
					default: //ignore all other values
				}
			}
			result.append('</table>');
		}
		
		chitBricks["effects"] = result;
		if (helpers.to_string() != "") chitBricks["helpers"] = helpers;
	}

	void bakeElements() {
		buffer result;
		
		result.append('<table id="chit_elements" class="chit_brick" cellpadding="0" cellspacing="0">');
		result.append('<tr><th>Elements</th></tr>');
		result.append("<tr><td>");
		result.append('<img src="http://kol.coldfront.net/thekolwiki/images/1/19/Elements2.gif">');
		result.append("</tr>");
		result.append("</table>");
		
		chitBricks["elements"] = result;
	}

	void bakeTrail() {
		string source = chitSource["trail"];
		buffer result;
		
		result.append('<table id="chit_trail" class="chit_brick" cellpadding="0" cellspacing="0">');
		
		//Container
		string url = "main.php";
		matcher target = create_matcher('href=\"(.*?)\" target=mainpane\>Last Adventure:</a\>', source);
		if (find(target)) {
			url = group(target, 1);
		}
		result.append('<tr><th><a class="visit" target="mainpane" href="' + url + '">Last Adventure</a></th></tr>');
		
		//Last Adventure
		target = create_matcher('target=mainpane href=\"(.*?)\"\>(.*?)</a\><br\></font\>', source);
		if (find(target)) {
			result.append('<tr><td class="last"><a class="visit" target="mainpane" href="' + group(target, 1) + '">' + group(target, 2) + '</a></td></tr>');
		}
		
		//Other adventures
		matcher others = create_matcher("<nobr\>(.*?)</nobr\>", source);
		while (find(others)) {
			target = create_matcher('target=mainpane href=\"(.*?)\"\>(.*?)</a\>', group(others, 1));
			if (find(target)) {
				result.append('<tr><td><a class="visit" target="mainpane" href="' + group(target, 1) + '">' + group(target, 2) + '</a></td></tr>');
			}
		}
		
		result.append("</table>");
		
		chitBricks["trail"] = result;
		chitTools["trail"] = "Recent Adventures|trail.png";
	}

	void pickerFamiliar(familiar myfam, item famitem, boolean isFed) {
		int [item] allmystuff = get_inventory();
		string [item] addeditems;
		buffer picker;
		string encoded = "";
		string url = "";
		
		item [int] generic;
		//Mr. Store Familiar Equipment
		generic[1]=$item[moveable feast];
		generic[2]=$item[little box of fireworks];
		generic[3]=$item[plastic pumpkin bucket];
		generic[4]=$item[lucky tam o'shanter];
		generic[5]=$item[lucky tam o'shatner];
		generic[6]=$item[mayflower bouquet];
		generic[7]=$item[miniature gravy-covered maypole];
		generic[8]=$item[wax lips];
		generic[9]=$item[tiny costume wardrobe];

		//Mr. Store Foldables
		generic[100]=$item[2225];	//flaming familiar doppelgänger
		generic[101]=$item[3194];	//origami "gentlemen's" magazine
		generic[102]=$item[4924];	//Loathing Legion helicopter
		
		//Special items
		generic[200]=$item[ittah bittah hookah];	
		generic[201]=$item[li'l businessman kit];
		generic[202]=$item[little bitty bathysphere];
		
		//Summonable
		generic[300]=$item[sugar shield];
		
		void addEquipment(item it, string cmd) {
			if (!(addeditems contains it)) {
				string encoded = url_encode(to_string(it));
				string addme = "";
				string url = "";
				string hover = "";
				string action = to_string(it);
				switch (cmd) {
					case "remove":
						hover = "Unequip " + it.to_string();
						action = "Remove equipment";
						url = "/KoLmafia/sideCommand?cmd=remove+familiar&pwd=" + my_hash();
						break;
					case "inventory":
						hover = "Equip " + it.to_string();
						url = "/KoLmafia/sideCommand?cmd=equip+familiar+" + encoded + "&pwd=" + my_hash();
						break;
					case "fold":
						hover = "Fold and equip " + it.to_string();
						url = "/KoLmafia/sideCommand?cmd=fold+" + encoded + ";equip+familiar+" + encoded + "&pwd=" + my_hash();
						break;
					case "make":
						hover = "Make and equip " + it.to_string();
						url = "/KoLmafia/sideCommand?cmd=make+" + encoded + ";equip+familiar+" + encoded + "&pwd=" + my_hash();
						break;
					case "retrieve":
						hover = "Retrieve and equip " + it.to_string();
						url = "/KoLmafia/sideCommand?cmd=equip+familiar+" + encoded + "&pwd=" + my_hash();
						break;
					default:	
						hover = "Equip " + it.to_string();
						url = "/KoLmafia/sideCommand?cmd=equip+familiar+" + encoded + "&pwd=" + my_hash();
				}
				picker.append('<tr class="pickitem">');
				picker.append('<td class="' + cmd + '"><a class="change" href="' + url + '" title="' + hover + '">' + action + '</a></td>');
				picker.append('<td class="icon"><a class="change" href="' + url + '" title="' + hover + '"><img src="/images/itemimages/' + it.image + '"></a></td>');
				picker.append('</tr>');
				addeditems[it] = to_string(it);
			}
		}
		
		void addLoader(string message) {
			picker.append('<tr class="pickloader" style="display:none">');
			picker.append('<td class="info">' + message + '</td>');
			picker.append('<td class="icon"><img src="/images/itemimages/karma.gif"></td>');
			picker.append('</tr>');
		}
		void addSadFace(string message) {
			if (count(addeditems) == 0) {
				picker.append('<tr class="picknone">');
				picker.append('<td class="info" colspan="2">');
				picker.append(message);
				picker.append('<br><br>Poor ' + myfam.name + '</td>');
				picker.append('</tr>');
			}
		}
		
		void pickEquipment() {
			//Most common equipment for current familiar
			item common = familiar_equipment(myfam);
			boolean havecommon = false;
			if (allmystuff contains common) {
				havecommon = true;
			} else {
				foreach foldable in get_related(common, "fold") {
					if ( allmystuff contains foldable) {
						common = foldable;
						havecommon = true;
						break;
					}
				}
			}
			if (havecommon) {
				addEquipment(common, "inventory");
				foreach foldable in get_related(common, "fold") {
					addEquipment(foldable, "fold");
				}
			}
			
			//Generic equipment
			foreach n, piece in generic {
				if (allmystuff contains piece) {
					addEquipment(piece, "inventory");
				} else if (available_amount(piece) > 0 ) {
					addEquipment(piece, "retrieve");
				} else if (n==100 || n==101 || n==102) {
					foreach foldable in get_related(piece, "fold") {
						if (available_amount(foldable) > 0 ) {
							addEquipment(piece, "fold");
							break;
						}
					}
				}
			}
			
			//Make Sugar Shield
			item shield = $item[sugar shield];
			if (!(addeditems contains shield)) {
				item sheet = $item[sugar sheet];
				if (allmystuff contains sheet) {
					addEquipment(shield, "make");
				}
			}
			
			//Check rest of inventory
			foreach thing in allmystuff {
				if ( (item_type(thing) == "familiar equipment") && (can_equip(thing))) {
					addEquipment(thing, "inventory");
				}
			}
		}
		
		void pickEquipmentBySlot(string slottype) {
			string pref = get_property("bumrats_chit.familiar."+slottype);
			if (pref != "") {
				string [int] equipmap = split_string(pref, ",");
				item equip;
				foreach i in equipmap {
					equip = to_item(equipmap[i]);
					if ( allmystuff contains equip) {
						addEquipment(equip, "inventory");
					} else if ( available_amount(equip) > 0 ) {
						addEquipment(equip, "retrieve");
					} else {
						foreach foldable in get_related(equip, "fold") {
							if ( allmystuff contains foldable) {
								addEquipment(equip, "fold");
							}
						}
					}
				}
			}
		}
		
		void pickClancy() {
			string pref = "Clancy's sackbut,Clancy's crumhorn,Clancy's lute";
			if (pref != "") {
				string [int] clancymap = split_string(pref, ",");
				item instrument;
				foreach i in clancymap {
					instrument = to_item(clancymap[i]);
					if ( allmystuff contains instrument) {
						addEquipment(instrument, "inventory");
					} else if ( available_amount(instrument) > 0 ) {
						addEquipment(instrument, "retrieve");
					} else {
						foreach foldable in get_related(instrument, "fold") {
							if ( allmystuff contains foldable) {
								addEquipment(instrument, "fold");
							}
						}
					}
				}
			}
		}
		
		void pickChameleon() {
			string [string] mods;
			file_to_map("modifiers.txt", mods);
			
			//Scan inventory
			foreach thing in allmystuff {
				if (item_type(thing) == "familiar equipment") {
					if (mods contains to_string(thing)) {
						if ( (!contains_text(mods[to_string(thing)], "Generic")) && 
							 (!contains_text(to_string(thing), "pet rock")) ) {
							addEquipment(thing, "inventory");
						}
					}
				}
			}
		}
		
		picker.append('<div id="chit_pickerfam" class="chit_skeleton" style="display:none">');
		picker.append('<table class="chit_picker" cellspacing="0" cellpadding="0">');
		picker.append('<tr><th colspan="2">Equip Thine Familiar Well</th></tr>');
		
		//Feeding time
		string [familiar] feedme;
		feedme[$familiar[Slimeling]] = "Mass Slime";
		feedme[$familiar[Stocking Mimic]] = "Give lots of candy";
		feedme[$familiar[Spirit Hobo]] = "Encourage Chugging";
		feedme[$familiar[Gluttonous Green Ghost]] = "Force Feed";
		if (feedme contains myfam) {
			picker.append('<tr class="pickitem"><td class="action" colspan="2"><a class="done" target="mainpane" href="familiarbinger.php">' + feedme[myfam] + '</a></tr>');
		}
		
		// Use link for Moveable Feast
		if (myfam != $familiar[Comma Chameleon] && !isFed) {
			item feast = $item[moveable feast];
			if (famitem == feast) {
				url = '/KoLmafia/sideCommand?cmd=remove+familiar;use+moveable+feast;equip+familiar+moveable+feast&pwd=' + my_hash();
				picker.append('<tr class="pickitem">');
				picker.append('<td class="action" colspan="2"><a class="change" href="' + url + '">Use Moveable Feast</a></td>');
				picker.append('</tr>');
			} else if (allmystuff contains feast) {
				url = '/KoLmafia/sideCommand?cmd=use+moveable+feast&pwd=' + my_hash();
				picker.append('<tr class="pickitem">');
				picker.append('<td class="action" colspan="2"><a class="change" href="' + url + '">Use Moveable Feast</a></td>');
				picker.append('</tr>');
			}
		}
		//Bugged Bugbear (Get free equipment from Arena)
		if (myfam == $familiar[Baby Bugged Bugbear]) {
			if ((available_amount($item[4575]) + available_amount($item[4576]) + available_amount($item[4577])) == 0) {
				url = 'arena.php';
				picker.append('<tr class="pickitem"><td class="action" colspan="2"><a class="done" target="mainpane" href="' + url + '">Visit the Arena</a></tr>');
			}
		}
		
		//Handle Current Equipment
		if (famitem != $item[none]) {
			addEquipment(famitem, "remove");
			foreach foldable in get_related(famitem, "fold") {
				if ( (item_type(foldable) == "familiar equipment") && (can_equip(foldable))) {
					addEquipment(foldable, "fold");
				}
			}
		}
	
		if (my_path() == "Avatar of Boris") {
				addLoader("Changing Instrument...");
				pickClancy();
				addSadFace("You don't have any instrument for your " + myfam + ".");
		}
		
		switch (myfam) {
			case $familiar[mad hatrack]:
				addLoader("Changing Hats...");
				pickEquipmentBySlot("hats");
				addSadFace("You don't have any hats for your " + myfam + ".");
				break;
			case $familiar[disembodied hand]:
				addLoader("Changing Weapons...");
				pickEquipmentBySlot("weapons");
				addSadFace("You don't have any weapons for your " + myfam + ".");
				break;
			case $familiar[fancypants scarecrow]:
				addLoader("Changing Pants...");
				pickEquipmentBySlot("pants");
				addSadFace("You don't have any pants for your " + myfam + ".");
				break;
			case $familiar[comma chameleon]:
				addLoader("Changing Equipment...");
				pickChameleon();
				addSadFace("You don't have any equipment for your " + myfam + ".");
				break;
			default:
				addLoader("Changing Equipment...");
				pickEquipment();
				addSadFace("You don't have any equipment for your " + myfam + ".");
		}
		picker.append('</table></div>');
		
		chitPickers["equipment"] = picker;
	}

	void bakeFamiliar() {
		string source = chitSource["familiar"];
		
		string famname = "Familiar";
		string famtype = "(None)";
		string actortype = "";
		string famimage = "blank.gif";
		string equiptype = "";
		string equipimage = "blank.gif";
		string famweight = "";
		string info = "";
		string famstyle = "";
		boolean isFed = false;
		string charges = "";
		
		familiar myfam = my_familiar();
		familiar actor = my_familiar();
		item famitem = $item[none];
		
		if (myfam != $familiar[none]) {
			famtype = to_string(myfam);
			actortype = famtype;
			famimage = myfam.image;
		}
		
		boolean isChameleon = (myfam == $familiar[Comma Chameleon]);
		boolean isHand = (myfam == $familiar[Disembodied Hand]);
		boolean isHatRack = (myfam == $familiar[Mad Hatrack]);
		
		//Get Familiar Name
		matcher nameMatcher = create_matcher("<b\><font size\=2\>(.*?)</a\></b\>, the", source);
		if (find(nameMatcher)){
			famname = group(nameMatcher, 1);
		}
		
		//Drops
		matcher dropMatcher = create_matcher("<b\>Familiar:</b></br>\\((.*?)\\)</font>", source);
		if (find(dropMatcher)){
			info = group(dropMatcher, 1);
			switch ( myfam ) {
				case $familiar[frumious bandersnatch]:
					info = "Runaways: " + info;
					break;
				case $familiar[rogue program]:
					info = "Tokens: " + info;
					break;
				case $familiar[green pixie]:
					info = "Absinthe: " + info;
					break;
				case $familiar[baby sandworm]:
					info = "Agua: " + info;
					break;
				case $familiar[llama lama]:
					info = "Gongs: " + info;
					break;
				case $familiar[astral badger]:
					info = "Shrooms: " + info;
					break;
				case $familiar[Mini-Hipster]:
					info = "Fights: " + info;
					break;
				case $familiar[li'l xenomorph]:
					info = "Transponders: " + info;
					break;
				default:
			}
		}
		
		matcher weightMatcher = create_matcher("</a\></b\>, the <b\>(.*?)</b\> pound ", source);
		matcher feastMatcher = create_matcher("the <i\>extremely</i\> well-fed", source);
		
		//Is the familiar Well Fed?
		if (find(feastMatcher)) {
			weightMatcher = create_matcher("</a\></b\>, the <i\>extremely</i\> well-fed <b\>(.*?)</b\> pound ", source);
			isFed = true;
		}
		
		//Get Familiar Weight
		if (find(weightMatcher)) {
			famweight = group(weightMatcher, 1);
		} else if (myfam != $familiar[none]) {
			famweight = to_string(familiar_weight(myfam) + weight_adjustment());
		}
		
		//Get equipment info
		if (isChameleon) {
			famitem = $item[none];
			equiptype = to_string(famitem);
			matcher actorMatcher = create_matcher("</b\> pound (.*?),", source);
			if (find(actorMatcher)) {
				actortype = group(actorMatcher, 1);
				actor = to_familiar(actortype);
				equipimage = actor.image;
				info = actortype;
			}
		} else {
			famitem = familiar_equipped_equipment(my_familiar());
			if (famitem != $item[none]) {
				equiptype = to_string(famitem);
				equipimage = famitem.image;
			}
		}
		
		// Get Hatrack info
		if (isHatRack) {
			info = "None";
			if (famitem != $item[none]) {
				info = "Unknown effect";
				string [string] mods;
				file_to_map("modifiers.txt", mods);
				if (mods contains to_string(famitem)) {
					matcher m = create_matcher('Familiar Effect: \\"(.*?), cap (.*?)\\"', mods[to_string(famitem)]);
					if (find(m)) {
						info = replace_string(group(m, 1), "x", " x ");
						if (group_count(m) > 1 ) {
							famweight = famweight + " / " + group(m, 2);
						}
					}
				}
			}
		}	
		
		// Sugar Charges
		if (famitem == $item[sugar shield]) {
			charges = to_string( 31 - to_int(get_property("sugarCounter4183")));
		} else 	if (famitem == $item[sugar chapeau]) {
			charges = to_string( 31 - to_int(get_property("sugarCounter4181")));
		}
			
		string hover = "Visit your terrarium";	
		
		//Extra goodies for 100% runs
		boolean protect = false;
		if (to_familiar(get_property("bumrats_is_100_run")) != $familiar[none]) {
			if (myfam == to_familiar(get_property("bumrats_is_100_run"))) {
				famstyle = famstyle + "color:green;";
				if (get_property("bumrats_chit.familiar.protect") == "true") {
					hover = "Don't ruin your 100% run!";
					protect = true;
				}
			} else {
				famstyle = famstyle + "color:red;";
			}
		}
	
		if(my_path() == "Avatar of Boris") {
			famtype = "Clancy";
			actortype = famtype;
			protect = true;
			// Familiar Weight: <Font size=1>Level <b>2</b> Minstrel</font>
			matcher level = create_matcher("Level <b>(.*?)</b> Minstrel", source);
			if(find(level)) famweight = level.group(1).to_int();
			// Familiar Image: <img src=http://images.kingdomofloathing.com/otherimages/clancy_2.gif width=60 height=100 border=0>
			matcher image = create_matcher("(otherimages/.*?) width=60", source);
			if(find(image)) famimage = image.group(1);

			// Does Clancy want attention?
			// <b>2</b> Minstrel</font><br><a target=mainpane href=main.php?action=clancy><img src=http://images.kingdomofloathing.com/otherimages/clancy_2_att.gif
			string clancyLink;
			matcher att = create_matcher("Minstrel</font><br><a target=mainpane href=(.*?)>", source);
			if(find(att)) clancyLink = att.group(1);
			
			// What is Clancy equipped with?
			if(famimage.contains_text("_1"))
				equiptype = "Clancy's sackbut";
			else if(famimage.contains_text("_2"))
				equiptype = "Clancy's crumhorn";
			else if(famimage.contains_text("_3"))
				equiptype = "Clancy's lute";
			equipimage = equiptype.to_item().image;
			
			info = '<br><span style="color:#606060;font-weight:normal">Level ' + famweight + ' Minstrel</span>';
			
			//Finally start some output
			buffer result;
			result.append('<table id="chit_familiar" class="chit_brick" cellpadding="0" cellspacing="0">');
			#result.append('<th width="40" title="Buffed Weight" style="color:blue">' + famweight + '</th>');
			
			#result.append('<th title="' + hover + '">' + famname + '</th>');
			result.append('</tr><tr>');
			result.append('<td class="icon" title="Your Faithful Minstrel">');
			if(clancyLink == "") {
				result.append('<img src="/images/' + famimage + '" width=50 height=100 border=0>');
			} else {
				result.append('<a target=mainpane href='+clancyLink+' class="familiarpick">');
				result.append('<img src="/images/' + famimage + '" width=50 height=100 border=0></a>');
			}
			result.append('</td>');
			result.append('<td class="info" style="' + famstyle + '">' + famtype + info + '</td>');
			result.append('<td class="icon" title="' + equiptype + '">');
			result.append('<a class="chit_launcher" rel="chit_pickerfam" href="#">');
			result.append('<img src="/images/itemimages/' + equipimage + '" width=30 height=30 border=0>');
			result.append('</a></td>');
			result.append('</tr>');
			
			result.append('</table>');
			chitBricks["familiar"] = result;

			//Add Equipment Picker
			pickerFamiliar(myfam, famitem, isFed);

			return;
		}
		
		//Add final touches to additional info
		if (info != "") {
			info = '<br><span style="color:#606060;font-weight:normal">(' + info + ')</span>';
		}
		
		//Finally start some output
		buffer result;
		result.append('<table id="chit_familiar" class="chit_brick" cellpadding="0" cellspacing="0">');
		if (isFed) {
			result.append('<tr class="wellfed">');
		} else {
			result.append('<tr>');
		}	
		result.append('<th width="40" title="Buffed Weight" style="color:blue">' + famweight + '</th>');
		
		if (protect) {
			result.append('<th title="' + hover + '">' + famname + '</th>');
		} else {
			result.append('<th><a target=mainpane href="familiar.php" class="familiarpick" title="' + hover + '">' + famname + '</a></th>');
		}
		if (charges == "") {
			result.append('<th width="30">&nbsp;</th>');
		} else {
			result.append('<th width="30" title="Charges remaining">' + charges + '</th>');
		}
		result.append('</tr><tr>');
		result.append('<td class="icon" title="' + hover + '">');
		if (protect) {
			result.append('<img src="/images/itemimages/' + famimage + '" width=30 height=30 border=0>');
		} else {
			result.append('<a target=mainpane href="familiar.php" class="familiarpick">');
			result.append('<img src="/images/itemimages/' + famimage + '" width=30 height=30 border=0>');
			result.append('</a>');
		}
		result.append('</td>');
		result.append('<td class="info" style="' + famstyle + '">' + famtype + info + '</td>');
		if (famtype == "(None)") {
			result.append('<td class="icon">');
			result.append('</td>');
		} else {
			if (equiptype == "") {
				result.append('<td class="icon" title="Equip your familiar">');
			} else {
				result.append('<td class="icon" title="' + equiptype + '">');
			}
			result.append('<a class="chit_launcher" rel="chit_pickerfam" href="#">');
			result.append('<img src="/images/itemimages/' + equipimage + '" width=30 height=30 border=0>');
			result.append('</a></td>');
		}
		result.append('</tr>');
		
		//Add Progress bar if we have one
		matcher progMatcher = create_matcher("<table title\='(.*?)' cellpadding\=0", source);
		if (find(progMatcher)) {
			string[1] minmax = split_string(group(progMatcher, 1), " / ");
			int current = to_int(minmax[0]);
			int upper = to_int(minmax[1]);
			float progress = (current * 100.0) / upper;
			result.append('<tr><td colspan="3" class="progress" title="' + current + ' / ' + upper + '" >');
			result.append('<div class="progressbar" style="width:' + progress + '%"></div></td></tr>');
		}
		result.append('</table>');
		chitBricks["familiar"] = result;
		
		//Add Equipment Picker
		if (myfam != $familiar[none]) {
			pickerFamiliar(myfam, famitem, isFed);
		}
	}

	void bakeToolbar() {
		buffer result;
		
		void addRefresh() {
			result.append('<ul style="float:left"><li><a href="charpane.php" title="Reload"><img src="' + imagePath + 'refresh.png"></a></li></ul>');
		}
		
		void addMood() {
			string source = chitSource["mood"];
			if (source == "") {
				return;
			} else if (contains_text(source, "save+as+mood")) {
				result.append('<li>');
				result.append('<a title="Save as Mood" href="/KoLmafia/sideCommand?cmd=save+as+mood&pwd=' + my_hash() + '">');
				result.append('<img src="' + imagePath + 'moodsave.png">');
				result.append('</a></li>');
			} else if (contains_text(source, "mood+execute")) {
				string moodname = "???";
				matcher pattern = create_matcher("\>mood (.*?)</a\>", source);
				if (find(pattern)) {
					moodname = group(pattern, 1);
				}
				result.append('<li>');
				result.append('<a title="Execute Mood: ' + moodname + '" href="/KoLmafia/sideCommand?cmd=mood+execute&pwd=' + my_hash() + '">');
				result.append('<img src="' + imagePath + 'moodplay.png">');
				result.append('</a></li>');
			} else if (contains_text(source, "burn+extra+mp")) {
				result.append('<li>');
				result.append('<a title="Burn extra MP" href="/KoLmafia/sideCommand?cmd=burn+extra+mp&pwd=' + my_hash() + '">');
				result.append('<img src="' + imagePath + 'moodburn.png">');
				result.append('</a></li>');
				
				//[<a title="I'm feeling moody" href="/KoLmafia/sideCommand?cmd=burn+extra+mp&pwd=ea073fd3cf87360cd2316377bd85c92f" style="color:black">burn extra mp</a>]
				
			} else {
				result.append('<li>');
				result.append('<img src="' + imagePath + 'moodnone.png">');
				result.append('</li>');
			}
		}
		
		void addTools () {
			result.append('<ul>');
			
			string layout = get_property("bumrats_chit.toolbar.layout").to_lower_case().replace_string(" ", "");
			if (layout == "") layout = "quests,modifiers";
			
			string [int] bricks = split_string(layout,",");
			string brick;
			string [int] toolprops;
			string toolicon;
			string toolhover;
			for i from 0 to (bricks.count()-1) {
				brick = bricks[i];
				if(brick=="mood"){
					addMood();
					continue;
				}
				if ((chitTools contains brick) && (chitBricks contains brick)) {
					toolprops = split_string(chitTools[brick],"\\|");
					if (chitBricks[brick] == "") {
						result.append('<li>');
						result.append('<img src="' + imagePath + toolprops[1] + '" title="' + toolprops[0] + '" >');
						result.append('</li>');
					} else {
						result.append('<li>');
						result.append('<a class="tool_launcher" title="' + toolprops[0] + '" href="#" rel="' + brick +'">');
						result.append('<img src="' + imagePath + toolprops[1] + '">');
						result.append('</a>');
						result.append('</li>');
					}
				}
			}
			result.append("</ul>");
		}
		
		result.append('<table id="chit_toolbar" cellpadding="0" cellspacing="0"><tr><th>');
		addRefresh();
		if (!inValhalla) {
			addTools();
		}
		result.append('</th></tr>');
		result.append('</table>');	
		chitBricks["toolbar"] = result;
	}

	void bakeModifiers() {
		buffer result;
		
		//Heading
		result.append('<table id="chit_modifiers" class="chit_brick" cellpadding="0" cellspacing="0">');
		result.append('<thead>');
		result.append('<tr>');
		result.append('<th colspan="2">Modifiers</th>');
		result.append('</tr>');
		result.append('</thead>');
		
		result.append('<tbody>');
		result.append('<tr>');
		result.append('<td class="label">Meat Drop</td>');
		result.append('<td class="info">' + formatModifier(meat_drop_modifier()) + '</td>');
		result.append('</tr>');
		result.append('<tr>');
		result.append('<td class="label">Item Drop</td>');
		result.append('<td class="info">' + formatModifier(item_drop_modifier()) + '</td>');
		result.append('</tr>');
		//result.append('<tr>');
		//result.append('<td class="label">Forced Drops</td>');
		//result.append('<td class="info">' + ceil(100.0 * (100.0/(100.0 + item_drop_modifier()))) + '%</td>');
		//result.append('</tr>');
		result.append('</tbody>');
		
		result.append('<tbody>');
		result.append('<tr>');
		result.append('<td class="label">Monster Level</td>');
		result.append('<td class="info">' + formatModifier(monster_level_adjustment()) + '</td>');
		result.append('</tr>');
		result.append('<tr>');
		result.append('<td class="label">Initiative</td>');
		result.append('<td class="info">' + formatModifier(initiative_modifier()) + '</td>');
		result.append('</tr>');
		result.append('<tr>');
		result.append('<td class="label">Combat Rate</td>');
		result.append('<td class="info">' + formatModifier(combat_rate_modifier()) + '</td>');
		result.append('</tr>');
		result.append('</tbody>');
		
		result.append('<tbody>');
		result.append('<tr>');
		result.append('<td class="label">Damage Absorption</td>');
		result.append('<td class="info">' + formatInt(raw_damage_absorption()) + ' (' + formatModifier(damage_absorption_percent()) + ')</td>');
		result.append('</tr>');
		result.append('<tr>');
		result.append('<td class="label">Damage Reduction</td>');
		result.append('<td class="info">' + formatInt(damage_reduction()) + '</td>');
		result.append('</tr>');
		result.append('</tbody>');
		
		result.append('<tbody>');
		result.append('<tr>');
		result.append('<td class="label">Spell Damage</td>');
		result.append('<td class="info">' + formatModifier(to_int(numeric_modifier("Spell Damage"))) + ' / ' + formatModifier(numeric_modifier("Spell Damage Percent")) + '</td>');
		result.append('</tr>');
		result.append('<tr>');
		result.append('<td class="label">Weapon Damage</td>');
		result.append('<td class="info">' + formatModifier(to_int(numeric_modifier("Weapon Damage"))) + ' / ' + formatModifier(numeric_modifier("Weapon Damage Percent")) + '</td>');
		result.append('</tr>');
		result.append('<tr>');
		result.append('<td class="label">Ranged Damage</td>');
		result.append('<td class="info">' + formatModifier(to_int(numeric_modifier("Ranged Damage"))) + ' / ' + formatModifier(numeric_modifier("Ranged Damage Percent")) + '</td>');
		result.append('</tr>');
		result.append('</tbody>');
		
		result.append('</table>');
		chitBricks["modifiers"] = result.to_string();
	}

	void bakeSubStats() {
		buffer result;
		
		void addMuscle() {
			result.append('<tr>');
			result.append('<td class="label">Muscle</td>');
			result.append('<td class="info">' + formatStats(my_buffedstat($stat[muscle]), my_basestat($stat[muscle])) + '</td>');
			result.append('<td class="progress">' + progressSubStats(my_basestat($stat[muscle]), my_basestat($stat[submuscle])) + '</td>');
			result.append('</tr>');
		}
		
		void addMysticality() {
			result.append('<tr>');
			result.append('<td class="label">Myst</td>');
			result.append('<td class="info">' + formatStats(my_buffedstat($stat[mysticality]), my_basestat($stat[mysticality])) + '</td>');
			result.append('<td class="progress">' + progressSubStats(my_basestat($stat[moxie]), my_basestat($stat[submoxie])) + '</td>');
			result.append('</tr>');
		}
		
		void addMoxie() {
			result.append('<tr>');
			result.append('<td class="label">Moxie</td>');
			result.append('<td class="info">' + formatStats(my_buffedstat($stat[moxie]), my_basestat($stat[moxie])) + '</td>');
			result.append('<td class="progress">' + progressSubStats(my_basestat($stat[mysticality]), my_basestat($stat[submysticality])) + '</td>');
			result.append('</tr>');
		}
		
		//Heading
		result.append('<table id="chit_substats" class="chit_brick" cellpadding="0" cellspacing="0">');
		result.append('<thead>');
		result.append('<tr>');
		result.append('<th colspan="3">Substats</th>');
		result.append('</tr>');
		result.append('</thead>');
		result.append('<tbody>');
		
		addMuscle();
		addMysticality();
		addMoxie();
		
		result.append('</tbody>');
		result.append('</table>');
		chitBricks["substats"] = result.to_string();
	}

	void bakeOrgans() {
		buffer result;
		
		int severity = 0;
		string message = "";
		string progress = "";
		float ratio;
		
		void addSpleen() {
			if (my_level() < 4) {
				severity = -1;
				message = "You're too young to be taking drugs";
			} else if (my_spleen_use() == spleen_limit()) {
				severity = 4;
				message = "Your spleen can't take any more abuse today";
			} else if ((spleen_limit() - my_spleen_use()) < 4) {
				severity = 2;
				message = "Your spleen has taken quite a bit of damage";
			} else if ( my_spleen_use() == 0) {
				severity = 1;
				message = "Your spleen is in great shape!";
			} else {
				severity = 1;
				message = "Your spleen is in pretty good shape";	
			}
			result.append('<tr>');
			result.append('<td class="label">Spleen</td>');
			result.append('<td class="info">' + my_spleen_use() + ' / ' + spleen_limit() + '</td>');
			result.append('<td class="progress">' + progressCustom(my_spleen_use(), spleen_limit(), message, severity, false) + '</td>');
			result.append('</tr>');
		}
		
		void addStomach() {
			if (can_eat()) {
				if (my_fullness() == spleen_limit()) {
					severity = 4;
					message = "You're too full to eat anything else";
				} else {
					severity = 1;
					message = "Hmmm...pies";	
				}
				result.append('<tr>');
				result.append('<td class="label">Stomach</td>');
				result.append('<td class="info">' + my_fullness() + ' / ' + fullness_limit() + '</td>');
				result.append('<td class="progress">' + progressCustom(my_fullness(), fullness_limit(), message, severity, (have_effect($effect[Got Milk]) > 0)) + '</td>');
				result.append('</tr>');
			}
		}
		
		void addLiver() {
			if (can_drink()) {
				if ( my_inebriety() > 25) {
					severity = 5;
					message = "Sneaky!";
				} else if ( my_inebriety() > inebriety_limit()) {
					severity = 5;
					message = "You are falling-down drunk";
				} else if (my_inebriety() == inebriety_limit()) {
					severity = 4;
					message = "You can't handle any more booze today";
				} else if ((inebriety_limit() - my_inebriety()) < 3) {
					severity = 3;
					message = "You can barely stand up straight...";
				} else if ((inebriety_limit() - my_inebriety()) < 5) {
					severity = 2;
					message = "You'd better keep an eye on your drinking...";
				} else if ( my_inebriety() == 0) {
					severity = 1;
					message = "You are stone-cold sober";
				} else {
					severity = 1;
					message = "Your drinking is still under control";	
				}
				result.append('<tr>');
				result.append('<td class="label">Liver</td>');
				result.append('<td class="info">' + my_inebriety() + ' / ' + inebriety_limit() + '</td>');
				result.append('<td class="progress">' + progressCustom(my_inebriety(), inebriety_limit(), message, severity, (have_effect($effect[Ode to Booze]) > 0)) + '</td>');
				result.append('</tr>');
			}
		}
		
		//Heading
		result.append('<table id="chit_organs" class="chit_brick" cellpadding="0" cellspacing="0">');
		result.append('<thead>');
		result.append('<tr>');
		result.append('<th colspan="3">Consumption</th>');
		result.append('</tr>');
		result.append('</thead>');
		
		addStomach();
		addLiver();
		addSpleen();
		
		result.append('</table>');
		chitBricks["organs"] = result.to_string();
	}

	//BCHIT
	void bakeStats() {
		string stats = chitSource["stats"];
		string health = chitSource["health"]; 
		buffer result;
		
		boolean showBars = to_boolean(get_property("bumrats_chit.stats.showbars"));
		int severity = 0;
		string message = "";
		string progress = "";
		float ratio;
		
		int severity(int low, int high) {
			if (low < high/4) return 1;
			if (low < 2*high/4) return 2;
			if (low < 3*high/4) return 3;
			return 4;
		}
		
		void bumAdd(string title, int one, int two, string showBar) {
			result.append('<tr>');
			result.append('<td class="label">'+title+'</td>');
			result.append('<td class="info">' + formatStats(one, two) + '</td>');
			if (showBars) result.append('<td class="progress">' + showBar + '</td>');
			result.append('</tr>');
		}
		
		void bumAdd(string s) {
			switch (s) {
				case "Muscle" :
				case "Mysticality" :
				case "Moxie" :
					bumAdd(s, my_buffedstat(to_stat(s)), my_basestat(to_stat(s)), progressSubStats(my_basestat(to_stat(s)), my_basestat(to_stat(s))));
				break;
			}
		}
		
		void addMainStat() {
			switch (my_primestat()) {
				case $stat[muscle]:			bumAdd("Muscle");		break;
				case $stat[mysticality]:	bumAdd("Mysticality");	break;
				case $stat[moxie]: 			bumAdd("Moxie");			break;
			}
		}
		
		void addFamiliar(boolean ico){
			if(my_familiar()==$familiar[none])return;
			matcher nameMatcher = create_matcher("<b\><font size\=2\>(.*?)</a\></b\>, the", chitsource["familiar"]);
			string famname="";
			if (find(nameMatcher)){
				famname = group(nameMatcher, 1);
			}
			boolean equipmentShown=false;
			string righttext;
			familiar myfam=my_familiar();
			item famitem=familiar_equipped_equipment(my_familiar());
			string famweight = to_string(familiar_weight(my_familiar()) + weight_adjustment());
			result.append("<tr><td class=\"label\" title=\""+famname+(ico?", the "+myfam.to_string():"")+"\"><a target=mainpane href=\"familiar.php\">"+(ico?"<img src=\"/images/itemimages/"+myfam.image+"\">":my_familiar().to_string())+"</a>");
			if(ico&&(famitem!=$item[none]))equipmentShown=true;
			result.append("</td>");
			matcher dropMatcher = create_matcher("<b>Familiar:</b><br>\\((.*?)\\)</font>", chitsource["familiar"]);
			string info;
			if (find(dropMatcher)) {
				info = group(dropMatcher, 1);
				righttext='<td class="progress">'+info+"</td>";
			} else switch(myfam) {
				case $familiar[mad hatrack]:
				case $familiar[disembodied hand]:
				case $familiar[fancypants scarecrow]:
				case $familiar[comma chameleon]:
					if(famitem!=$item[none]&&(!equipmentShown)){
						righttext='<td class="progress"><a class="chit_launcher" rel="chit_pickerfam" href="#"><img src="/images/itemimages/'+famitem.image+'" title="'+famitem.to_string()+'"></a></td>';
						equipmentShown=true;
						break;
					}
				default:
					matcher progMatcher = create_matcher("<table title\='(.*?)' cellpadding\=0", chitsource["familiar"]);
					if (find(progMatcher)) {
						string[1] minmax = split_string(group(progMatcher, 1), " / ");
						int current = to_int(minmax[0]);
						int upper = to_int(minmax[1]);
						float progress = (current * 100.0) / upper;
						message = current.to_string()+" / "+upper.to_string();
						righttext = '<td class="progress">'+progressCustom(current,upper,message,0,false)+"</td>";
					} else if (famitem!=$item[none]&&(!equipmentShown)) {
						righttext = '<td class="progress"><a class="chit_launcher" rel="chit_pickerfam" href="#"><img src="/images/itemimages/'+famitem.image+'" title="'+famitem.to_string()+'"></a></td>';
						equipmentShown = true;
					} else righttext = '<td class="progress"></td>';
			}
			if(ico&&(famitem!=$item[none])) result.append('<td class="info"><a class="chit_launcher" rel="chit_pickerfam" href="#"><img src="/images/itemimages/'+famitem.image+'" title="'+famitem.to_string()+' ('+famweight+')"></a></td>');
			else if(equipmentShown)result.append('<td class="info">'+famweight+'</td>');
			else result.append('<td class="info" title="'+(famitem!=$item[none]?famitem.to_string():'')+'"><a class="chit_launcher" rel="chit_pickerfam" href="#">'+famweight+'</a></td>');
			result.append(righttext);
			result.append("</tr>");
			if (myfam != $familiar[none]) pickerFamiliar(myfam, famitem, true);
		}
		
				
		void addAxel() {
			if (index_of(health, "axelottal.gif") > -1) {
				matcher axelMatcher = create_matcher("axelottal.gif\" /\></td\><td align=left\><b\>(.*?)</b\>", health);
				if (find(axelMatcher)) {
					message = "Axel Courage";
					int courage = to_int(group(axelMatcher, 1));
					if (courage <= 15) {
						severity = 3;
					} else if (courage >= 35) {
						severity = 1;
					} else {
						severity = 2;
					}
					
					//result.append('<tr style="background-color:khaki">');
					result.append('<tr>');
					result.append('<td class="label">Axel</td>');
					result.append('<td class="info">' + courage + ' / 50</td>');
					progress = progressCustom(courage, 50, message, severity, false);
					if (showBars) result.append('<td class="progress">' + progress + '</td>');
					result.append('</tr>');
				}
			}
		}
		
		string mcdname;
		string mcdlabel;
		string mcdtitle;
		string mcdpage;
		string mcdchange;
		string mcdbusy;
		int mcdmax =10;
		boolean mcdAvailable = true;
		boolean mcdSettable = true;
		
		void addML(boolean name) {
			//Muscle Signs
			mcdname = "Monster Level";
			mcdlabel = "ML";
			mcdtitle = "Touch that dial.";
			mcdbusy = "Tuning MCD...";
			if (knoll_available()) {
				if(name){
					mcdname = "Detuned Radio";
					mcdlabel = "Radio";
					mcdtitle = "Turn it up or down, man";
					mcdbusy = "Tuning Radio...";
				}
				mcdtitle = "Turn it up or down.";
				mcdpage = "inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=2682";
				mcdchange = "inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=2682&tuneradio=";
				if (item_amount($item[detuned radio]) == 0) {
					mcdSettable = false;
					if (my_meat() < 300) {
						progress = '<span title="You can\'t afford a Radio">Buy Radio</span>';
					} else {
						progress = '<a title="Buy a Detuned Radio (300 meat)" href="/KoLmafia/sideCommand?cmd=buy+detuned+radio&pwd=' + my_hash() + '">Buy Radio</a>';
					}
				} else {
					progress = progressCustom(current_mcd(), mcdmax, mcdtitle, 5, false);
				}
			} else if (gnomads_available()) {
			// Moxie Signs
				if(name){
					mcdname = "Annoy-o-Tron 5000";
					mcdlabel = "AOT5K";
					mcdtitle = "Touch that dial!";
					mcdbusy = "Changing Dial...";
				}
				mcdpage = "gnomes.php?place=machine";
				mcdchange = "gnomes.php?action=changedial&whichlevel=";
				if ((item_amount($item[bitchin' meatcar]) + item_amount($item[bus pass]) + item_amount($item[pumpkin carriage])) == 0) {
					mcdSettable = false;
					progress = '<span title="The Gnomad camp has not been unlocked yet">Camp not available</span>';
				} else {
					progress = progressCustom(current_mcd(), mcdmax, mcdtitle, 5, false);
				}
				
			// Myst Signs
			} else if (canadia_available()) {
				if(name){
					mcdname = "Mind-Control Device";
					mcdlabel = "MCD";
					mcdtitle = "Touch that dial!";
					mcdbusy = "Changing Dial...";
				}
				mcdmax = 11;
				mcdpage = "canadia.php?place=machine";
				mcdchange = "canadia.php?action=changedial&whichlevel=";
				progress = progressCustom(current_mcd(), mcdmax, mcdtitle, 5, false);
			} else if (in_bad_moon()) {
				if (name) {
					mcdname = "Heartbreaker's Hotel";
					mcdlabel = "Hotel";
					mcdtitle = "Hotel Floor #" + current_mcd();
				}
				mcdpage = "heydeze.php";
				mcdchange = "";
				mcdSettable = false;
				progress = progressCustom(current_mcd(), mcdmax, mcdtitle, 5, false);
			} else {
				if (name) mcdtitle = "No MCD Available";
				mcdpage = "";
				mcdchange = "";
				mcdSettable = false;
				mcdAvailable = false;
				progress = '<span title="You don\'t have access to a MCD">Not available</span>';
			}
			
			result.append('<tr>');
			if (mcdpage == "") {
				result.append('<td class="label">' + mcdlabel + '</td>');
			} else {
				result.append('<td class="label"><a href="' + mcdpage + '" target="mainpane" title="' + mcdname + '">' + mcdlabel + '</a></td>');
			}
			
			string mcdvalue = "";
			if (mcdAvailable) {
				if (mcdSettable) {
					mcdValue = '<a href="#" class="chit_launcher" rel="chit_pickermcd" title="' + mcdtitle + '">' + to_string(current_mcd()) + '</a>';
				} else {
					mcdvalue = '<span title="' + mcdname + '">' + to_string(current_mcd()) + '</span>';
				}
				if (monster_level_adjustment() > current_mcd()) {
					mcdvalue = '<span style="color:blue" title="Total ML">' + formatModifier(monster_level_adjustment()) + '</span>&nbsp;&nbsp;(' + mcdvalue + ')';
				} else if (monster_level_adjustment() < current_mcd()) {
					mcdvalue = '<span style="color:red" title="Total ML">' + formatModifier(monster_level_adjustment()) + '</span>&nbsp;&nbsp;(' + mcdvalue + ')';
				}
			} else {
				mcdvalue = '<span title="' + mcdname + '">' + to_string(monster_level_adjustment()) + '</span>';
			}
			
			result.append('<td class="info">' + mcdvalue + '</td>');
			
			if (showBars) {
				if (mcdSettable) {
					result.append('<td class="progress"><a href="#" id="chit_mcdlauncher" class="chit_launcher" rel="chit_pickermcd">' + progress + '</a></td>');
				} else {
					result.append('<td class="progress">' + progress + '</td>');
				}
			}
			result.append('</tr>');
		}
		
		void addTrail() {
			string source = chitSource["trail"];
			
			//Container
			string url = "main.php";
			matcher target = create_matcher('href=\"(.*?)\" target=mainpane\>Last Adventure:</a\>', source);
			if (find(target)) {
				url = group(target, 1);
			}
			result.append('<tr>');
			result.append('<td class="label"><a class="visit" target="mainpane" href="' + url + '">Last</a></td>');
			
			//Last Adventure
			target = create_matcher('target=mainpane href=\"(.*?)\"\>(.*?)</a\><br\></font\>', source);
			if (find(target)) {
				result.append('<td class="info" colspan="2"><a class="visit" target="mainpane" href="' + group(target, 1) + '">' + group(target, 2) + '</a></td>');
			} else {
				result.append('<td class="info" colspan="2">(None)</td>');
			}
			result.append('</tr>');
		}
		
		void addSection(string section) {
			string [int] rows = split_string(section, ",");
			string brick;
			result.append("<tbody>");
			for i from 0 to (rows.count()-1) {
				brick = rows[i];
				switch (brick) {
					case "mainstat":addMainstat();		break;
					case "muscle":	bumAdd("Muscle");		break;
					case "myst":	bumAdd("Mysticality");	break;
					case "moxie":	bumAdd("Moxie");			break;
					case "spleen":	bumAdd("Spleen", my_spleen_use(), spleen_limit(), progressCustom(my_spleen_use(), spleen_limit(), "", severity(my_spleen_use(), spleen_limit()), false));		break;
					case "stomach":	bumAdd("Stomach", my_fullness(), fullness_limit(), progressCustom(my_fullness(), fullness_limit(), "", severity(my_fullness(), fullness_limit()), false));		break;
					case "liver":	bumAdd("Stomach", my_inebriety(), inebriety_limit(), progressCustom(my_inebriety(), inebriety_limit(), "", severity(my_inebriety(), inebriety_limit()), false));			break;
					case "familiar":addFamiliar(false);	break;
					case "famicon":	addFamiliar(true);	break;
					case "hp":		bumAdd("HP", my_hp(), my_maxhp(), progressCustom(my_hp(), my_maxhp(), "", severity(my_hp(), my_maxhp()), false));			break;
					case "mp":		bumAdd("MP", my_mp(), my_maxmp(), progressCustom(my_mp(), my_maxmp(), "", severity(my_mp(), my_maxmp()), false));			break;
					case "axel":	addAxel();			break;
					case "mcd":		addML(true);		break;
					case "ml":		addML(false);		break;
					case "trail":	addTrail();			break;
					default:
				}
			}
			result.append("</tbody>");
		}
		
		//BCHIT: END STATS BIT
		
		//Heading
		if (showBars) {
			result.append('<table id="chit_stats" class="chit_brick" cellpadding="0" cellspacing="0">');
		} else {
			result.append('<table id="chit_stats" class="chit_brick nobars" cellpadding="0" cellspacing="0">');
		}
		result.append('<thead>');
		result.append('<tr>');
		result.append('<th colspan="3">My Stats</th>');
		result.append('</tr>');
		result.append('</thead>');
		
		string layout = get_property("bumrats_chit.stats.layout");
		if (layout == "") layout = "muscle,myst,moxie|stomach,liver,spleen|hp,mp,axel|mcd";
		layout = to_lower_case(replace_string(layout, " ",""));
		string [int] sections = split_string(layout, "\\|");
		for i from 0 to (sections.count()-1) {
			if (sections[i] != "") {
				addSection(sections[i]);
			}
		}
		
		result.append('</table>');
		chitBricks["stats"] = result.to_string();
		
		//Create MCD picker
		if (mcdSettable) {
			result.set_length(0);
			
			string [int] mcdmap;
			mcdmap[0] = "Turn it off";
			mcdmap[1] = "Turn it mostly off";
			mcdmap[2] = "Ratsworth's money clip";
			mcdmap[3] = "Glass Balls of the King";
			mcdmap[4] = "Boss Bat britches";
			mcdmap[5] = "Rib of the Bonerdagon";
			mcdmap[6] = "Horoscope of the Hermit";
			mcdmap[7] = "Cape of the Goblin King";
			mcdmap[8] = "Boss Bat bling";
			mcdmap[9] = "Ratsworth's tophat";
			mcdmap[10] = "Vertebra of the Bonerdagon";
			mcdmap[11] = "It goes to 11?";
			
			result.append('<div id="chit_pickermcd" class="chit_skeleton" style="display:none">');	
			result.append('<table class="chit_picker" cellspacing="0" cellpadding=0>');
			result.append('<tr><th colspan="2">' + mcdtitle + '</th></tr>');
			
			//Loader
			result.append('<tr class="pickloader" style="display:none">');
			result.append('<td class="info">' + mcdbusy + '</td>');
			result.append('<td class="icon"><img src="/images/itemimages/karma.gif"></td>');
			result.append('</tr>');
			
			string mcdtext;
			for mcdlevel from 0 to mcdmax {
				mcdtext = mcdmap[mcdlevel];
				if (mcdlevel == current_mcd()) {
					result.append('<tr class="pickitem current"><td class="info">' + mcdtext + '</td>');
				} else {
					result.append('<tr class="pickitem"><td class="info"><a class="change" target="mainpane" href="' + mcdchange + mcdlevel + '">' + mcdtext + '</a></td>');
				}
				result.append('<td class="level">' + mcdlevel + '</td>');
				result.append('</tr>');
			}
			
			result.append('</table>');
			result.append('</div>');
			
			chitPickers["mcd"] = result.to_string();
		}
	}

	void bakeMCD() {
	
		buffer result;
		string mcdname;
		string mcdtitle;
		string mcdpage;
		string mcdchange;
		string mcdbusy;
		int mcdmax = 10;
		boolean isAvailable = true;
		
		if (knoll_available()) {
			mcdname = "Detuned Radio";
			mcdtitle = "Turn it up or down, man";
			if (item_amount($item[detuned radio]) == 0) {
				isAvailable = false;
			} else {
				mcdpage = "inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=2682";
				mcdchange = "inv_use.php?pwd=" + my_hash() + "&which=3&whichitem=2682&tuneradio=";
				mcdbusy = "Tuning Radio...";
			}
		} else if (gnomads_available()) {
			mcdname = "Annoy-o-Tron 5000";
			mcdtitle = "Touch that dial!";
			mcdpage = "gnomes.php?place=machine";
			mcdchange = "gnomes.php?action=changedial&whichlevel=";
			mcdbusy = "Changing Dial...";
			if ((item_amount($item[bitchin' meatcar]) + item_amount($item[bus pass]) + item_amount($item[pumpkin carriage])) == 0) {
				isAvailable = false;
			}
			
		} else if (canadia_available()) {
			mcdmax = 11;
			mcdname = "Mind-Control Device";
			mcdtitle = "Touch that dial!";
			mcdpage = "canadia.php?place=machine";
			mcdchange = "canadia.php?action=changedial&whichlevel=";
			mcdbusy = "Changing Dial...";
		} else if (in_bad_moon()) {
			isAvailable = false;
		}
		
		if (isAvailable) {
		
			string [int] mcdmap;
			mcdmap[0] = "Turn it off";
			mcdmap[1] = "Turn it mostly off";
			mcdmap[2] = "Ratsworth's money clip";
			mcdmap[3] = "Glass Balls of the King";
			mcdmap[4] = "Boss Bat britches";
			mcdmap[5] = "Rib of the Bonerdagon";
			mcdmap[6] = "Horoscope of the Hermit";
			mcdmap[7] = "Cape of the Goblin King";
			mcdmap[8] = "Boss Bat bling";
			mcdmap[9] = "Ratsworth's tophat";
			mcdmap[10] = "Vertebra of the Bonerdagon";
			mcdmap[11] = "It goes to 11?";
			
			result.append('<table id="chit_mcd" class="chit_brick" cellpadding="0" cellspacing="0">');
			result.append('<thead>');
			result.append('<tr>');
			result.append('<th colspan="2" rel="' + mcdbusy + '"><a href="' + mcdpage + '" target="mainpane" title="' + mcdtitle + '">' + mcdname + '</a></th>');
			result.append('</tr>');
			result.append('</thead><tbody>');
			
			string url;
			string mcdtext;
			for mcdlevel from 0 to mcdmax {
				url = '/KoLmafia/sideCommand?cmd=mcd+' + mcdlevel + '&pwd=' + my_hash();
				mcdtext = mcdmap[mcdlevel];
				if (mcdlevel == current_mcd()) {
					result.append('<tr class="current"><td class="info">' + mcdtext + '</td>');
				} else {
					result.append('<tr class="change"><td class="info"><a target="mainpane" href="' + mcdchange + mcdlevel + '">' + mcdtext + '</a></td>');
				}
				result.append('<td class="level">' + mcdlevel + '</td>');
				result.append('</tr>');
			}
			
			if (current_mcd() == 0 ) {
				chitTools["mcd"] = mcdname + " (" + current_mcd() + ")|mcdoff.png";
			} else {
				chitTools["mcd"] = mcdname + " (" + current_mcd() + ")|mcdon.png";
			}
			
		result.append('</tbody></table>');
		result.append('</table>');
		chitBricks["mcd"] = result;
		
		} else {
			chitBricks["mcd"] = "";
		}
	}


	void bakeCharacter() {
		string source = chitSource["character"];
		buffer result;
		
		//Name
		/*
		string myName = "";
		matcher nameMatcher = create_matcher("href=\"charsheet.php\"\><b\>(.*?)</b\></a\>", source);
		if (find(nameMatcher)){
			myName = group(nameMatcher, 1);
		} else {
			myName = my_name();
		}
		*/
		
		//Title
		string myTitle = my_class();
		if (get_property("bumrats_chit.character.title") == "true") {
			matcher titleMatcher = create_matcher("<br\>(.*?)<br\>(.*?)<", source);
			if (find(titleMatcher)) {
				myTitle = group(titleMatcher, 2);
				if (index_of(myTitle, "(Level ") == 0) {
					myTitle = group(titleMatcher, 1);
				}
			} else {
				titleMatcher = create_matcher("<br\>(.*?)<", source);
				if (find(titleMatcher)) {
					myTitle = group(titleMatcher, 1);
				}
			}
		}
		
		//Avatar
		string myAvatar = "";
		if (get_property("bumrats_chit.character.avatar") != "false") {
			matcher avatarMatcher = create_matcher('<img src=\"(.*?)\" width=60 height=100 border=0\>', source);
			if (find(avatarMatcher)){
				myAvatar = group(avatarMatcher, 1);
			}
		}
		
		//Outfit
		string myOutfit = "";
		matcher outfitMatcher = create_matcher('<center class=tiny>Outfit: (.*?)</center>', source);
		if (find(outfitMatcher)){
			myOutfit = group(outfitMatcher, 1);
			myTitle = myOutfit;
		}
		
		//Class-spesific stuff
		string myGuild = "";
		int myMainStats = my_basestat(my_primestat());
		int mySubStats = 0;
		switch (my_class()) {
			case $class[Pastamancer]:
			case $class[Sauceror]:			
				myGuild = "guild.php?guild=m";
				mySubStats = my_basestat($stat[submysticality]);
				break;
			case $class[Accordion Thief]:
			case $class[Disco Bandit]:	
				myGuild = "guild.php?guild=t";
				mySubStats = my_basestat($stat[submoxie]);
				break;
			case $class[Turtle Tamer]:
			case $class[Seal Clubber]:	
				myGuild = "guild.php?guild=f";
				mySubStats = my_basestat($stat[submuscle]);
				break;
			case $class[Avatar of Boris]:	
				myGuild = "da.php?place=gate1";
				mySubStats = my_basestat($stat[submuscle]);
				break;				
			case $class[Avatar of Jarlsberg]:	
				myGuild = "da.php?place=gate2";
				mySubStats = my_basestat($stat[submysticality]);
				break;	
			case $class[Zombie Master]:
				myGuild = "campground.php";
				mySubStats = my_basestat($stat[submuscle]);
				break;
		}
		
		//LifeStyle
		string myLifeStyle = "";
		string ronin = "--";
		if (get_property("kingLiberated") == true) {
			myLifeStyle = "Aftercore";
		} else if (in_bad_moon()) {
			myLifeStyle = "Bad Moon";
		} else if (in_hardcore()) {
			myLifeStyle = "Hardcore";
		} else if (can_interact()) {
			myLifeStyle = "Casual";
		} else {
			myLifeStyle = '<a target=mainpane href="storage.php">Ronin</a>: ' + formatInt(1000 - turns_played());
		}
		
		//Path
		string myPath = "";
		if (myLifestyle == "Aftercore") {
			myPath = "No Restrictions";
		} else if (my_path() == "None") {
			myPath = "No Path";
		} else if (my_path() == "6" || my_path().contains_text("Surprising Fist")) {
			myPath = "Surprising Fist";
			//myPath = "Surprising Fist: " + get_property("fistSkillsKnown");
		} else {
			myPath = my_path();
		}	
		if (myPath == "Bees Hate You") {
			int bees = 0;
			matcher bs;
			foreach s in $slots[] {
				item q = equipped_item(s);
				if (q != $item[none]) {
					bs = create_matcher("[Bb]", to_string(q));
					while (bs.find()) {
						bees = bees + 1;
					}
				}
			}
			if (bees > 0) {
				myPath = '<span style="color:red" title="Beeosity">Bees Hate You (' + bees + ')</span>';
			}
		}
		
		//Stat Progress
		int x = my_level();
		int y = x + 1;
		int lower = (x**4)-(4*x**3)+(14*x**2)-(20*x)+25;
		if (x==1) lower=9;
		int upper = (y**4)-(4*y**3)+(14*y**2)-(20*y)+25;
		int range = upper - lower;
		int current = mySubStats - lower;
		int needed = range - current;
		float progress = (current * 100.0) / range;
		
		//Level + Council
		string councilStyle = "";
		string councilText = "Visit the Council";
		if ( (to_int(get_property("lastCouncilVisit")) < my_level()) && (my_level() < 14)) {
			councilStyle = ' style="background-color:#F0F060"';
			councilText = "The Council wants to see you urgently";
		}
		
		result.append('<table id="chit_character" class="chit_brick" cellpadding="0" cellspacing="0">');
		
		result.append('<tr>');
		if (myAvatar == "") {
			result.append('<th colspan="2"><a target="mainpane" href="charsheet.php">' + my_name() + '</a></th>');
		} else {
			result.append('<th colspan="3"><a target="mainpane" href="charsheet.php">' + my_name() + '</a></th>');
		}
		result.append('</th>');
		result.append('</tr>');
		
		result.append('<tr>');
		if (myAvatar != "") {
			result.append('<td rowspan="4" class="avatar"><a target="mainpane" href="charsheet.php"><img src="' + myAvatar + '"></a></td>');
		}
		if (length(myGuild) > 0)
			result.append('<td class="label"><a target="mainpane" href="' + myGuild +'" title="Visit your guild">' + myTitle + '</a></td>');
		result.append('<td class="level" rowspan="2"' + councilStyle + '><a target="mainpane" href="council.php" title="' + councilText + '">' + my_level() +	'</a></td>');
		result.append('</tr>');
		
		result.append('<tr>');
		result.append('<td class="info">' + myLifeStyle + '</td>');
		result.append('</tr>');
		
		result.append('<tr>');
		result.append('<td class="info">' + myPath + '</td>');
		result.append('<td class="turns" title="Turns played">' + formatInt(turns_played()) + '</td>');
		result.append('</tr>');	
		
		result.append('<tr>');
		result.append('<td class="label" style="color:darkred;font-weight:bold" title="Meat">' + formatInt(my_meat()) + '</td>');
		result.append('<td class="turns" style="color:darkred;font-weight:bold" title="Turns remaining">' + my_adventures() + '</td>');
		result.append('</tr>');
		
		if (index_of(source, "<table title=") > -1) {
			result.append('<tr>');
			result.append('<td class="progress" colspan="3" title="' + formatInt(current) + ' / ' + formatInt(range) + ' (' + formatInt(needed) + ' substats needed)" >');
			result.append('<div class="progressbar" style="width:' + progress + '%"></div></td>');
			result.append('</tr>');
		}
		result.append('</table>');
		
		chitBricks["character"] = result;
	}

	void bakeQuests() {
		string source = chitSource["quests"]; 
		buffer result;	
		boolean hasQuests = (index_of(source, "<div>(none)</div>") == -1) && (index_of(source, "This Quest Tracker is a work in progress") == -1);
		boolean hideQuests = (get_property("bumrats_chit.quests.hide") == "true");
		
		//See if we actually need to display anything
		if ((source == "") || (!hasQuests && hideQuests)) {
			//We're done here
			//chitBricks["quests"] = "";
			return;
		}
		
		//Otherwise we start building our table	
		result.append('<div id="nudgeblock">');
		result.append('<table id="nudges" class="chit_brick" cellpadding="0" cellspacing="0">');
		
		result.append('<tr>');
		result.append('<th><a target="mainpane" href="questlog.php">Current Quests</a></th>');
		result.append('</tr>');
		
		matcher rowMatcher = create_matcher("<tr(.*?)tr\>", source);
		string quest = "";
		while (find(rowMatcher)) {
			quest = group(rowMatcher,0);
			if (contains_text(quest, "<div>(none)</div>")) {
				quest = replace_string(quest, "<div>", "");
				quest = replace_string(quest, "</div>", "");
			} else if (contains_text(quest, "Evilometer")) {
				string evil = "";
				int e;
				
				e = to_int(get_property("cyrptAlcoveEvilness"));
				if (e > 25) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled alcove]) +'" target="mainpane">Alcove:</a> ' + e + ' (+init)';
				} else if (e > 0) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled alcove]) +'" target="mainpane">Alcove:</a> ' + e + ' (Boss ready)';
				} else {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Alcove</s>';
				}
				
				e = to_int(get_property("cyrptCrannyEvilness"));
				if (e > 25) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled cranny]) +'" target="mainpane">Cranny:</a> ' + e + ' (+NC, +ML)';
				} else if (e > 0) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled cranny]) +'" target="mainpane">Cranny:</a> ' + e + ' (Boss ready)';
				} else {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Cranny</s>';
				}
				
				e = to_int(get_property("cyrptNicheEvilness"));
				if (e > 25) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled niche]) +'" target="mainpane">Niche:</a> ' + e + ' (sniff dirty old lihc)';
				} else if (e > 0) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled niche]) +'" target="mainpane">Niche:</a> ' + e + ' (Boss ready)';
				} else {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Niche</s>';
				}
				
				e = to_int(get_property("cyrptNookEvilness"));
				if (e > 25) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled nook]) +'" target="mainpane">Nook:</a> ' + e + ' (+items)';
				} else if (e > 0) {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <a href="' + to_url($location[defiled nook]) +'" target="mainpane">Nook:</a> ' + e + ' (Boss ready)';
				} else {
					evil += '<br>&nbsp;&nbsp;&nbsp;* <s>Nook</s>';
				}
				
				//quest = replace_string(quest, "Evilometer", evil + "Evilometer");
				quest = replace_string(quest, "<p>", "<br>");
				quest = replace_string(quest, "</div>", evil + "</div>");
			}
			result.append(quest);	
		}
		result.append('</table>');
		
		//Append any javascript uncle CDM inlucded
		matcher jsMatcher = create_matcher("<script(.*?)script\>", source);
		if (find(jsMatcher)) {
			result.append(group(jsMatcher,0));
		}
		
		result.append("</div>");
		
		chitBricks["quests"] = result;
		chitTools["quests"] = "Current Quests|quests.png";
	}

	void bakeHeader() {
		string source = chitSource["header"];
		buffer result;
		
		//Try to get IE to play nicely in the absense of a proper doctype
		result = source.replace_string('<head>', '<head>\n<meta http-equiv="X-UA-Compatible" content="IE=8" />\n');
		
		//Add CSS to the <head> tag
		result = result.replace_string('</head>', '\n<link rel="stylesheet" href="http://bumcheekcity.com/kol/bumrats/chit.css">\n</head>');
		
		//Add JavaScript just before the <body> tag. 
		//Ideally this should go into the <head> tag too, but KoL adds jQuery outside of <head>, so that won't work
		result = result.replace_string('<body', '\n<script type="text/javascript" src="http://bumcheekcity.com/kol/bumrats/chit.js"></script>\n<body');
		
		chitBricks["header"] = result.to_string();
	}

	void bakeFooter() {
		buffer result;
		result.append(chitSource["footer"]);
		
		chitBricks["footer"] = result.to_string();
	}


	string sort(string[int] ts) {
		int bigv;
		int bigi;
		string res;
		matcher c = create_matcher("[>(](\\d+)[<(]","");
		while ( count(ts)>0 ) {
			bigv = 0;
			bigi = 0;
			foreach i,s in ts {
				c.reset(s);
				if ( !c.find() ) {
					if ( bigv == 0 ) bigi = i;
					continue;
				}
				bigv = max(bigv,c.group(1).to_int());
				if ( bigv == c.group(1).to_int() ) bigi=i;
			}
			res = ts[bigi] + res;
			remove ts[bigi];
		}
		return res;
	}

	//Parse the page and break it up into smaller consumable chunks
	boolean parsePage(buffer original) {
		string startwith = "";
		string endwith = "";
		int startat = 0;
		int endat = 0;
		
		buffer source;
		source.append(original);
		
		boolean shortcut(int startat, int endat, string name) {
			if (endat == -1) {
				print("CHIT: Error parsing "+name, "purple");
				//Returning from parsePage
				return false;
			} else {
				chitSource[name] = (substring(source, startat, endat));
				source.delete(startat, endat);
			}
			return true;
		}
		
		boolean shortcut(int startat, string endwith, string name) {
			return shortcut(startat, index_of(source, endwith), name);
		}
		
		boolean shortcut(string startwith, int endat, string name) {
			return shortcut(index_of(source, startwith), endat, name);
		}
		
		boolean shortcut(string startwith, string endwith, string name) {
			return shortcut(index_of(source, startwith), index_of(source, endwith), name);
		}
		
		if (!shortcut(0, "<center id='rollover'", "header")) return false;
		if (!shortcut("</body></html>", length(source), "footer")) return false;
		if (!shortcut("<center id='rollover'", "</center>", "rollover")) return false;
		if (!shortcut(0, "<table align=center><tr><td align=right>Muscle:", "character")) return false;
		if (!shortcut(0, "<table cellpadding=3 align=center>", "stats")) return false;
		if (!shortcut(0, "</table>", "health")) return false;
		
		
		
		// Spooky Little girl
		if ( index_of(source, "axelottal.gif") > 0) {
			startwith = "<table>";
			startat = index_of(source, startwith);
			endwith = "</table>";
			endat = index_of(source, endwith);
			if ( (startat == -1) || (endat == -1) || (startat > endat) ) {
				print("CHIT: Error parsing Axel", "purple");
				//Returning from parsePage
				return false;
			} else {
				chitSource["health"] = chitSource["health"] + substring(source, startat, endat + length(endwith));
				source.delete(0, endat + length(endwith));
			}
		}
		
		// MCD/Radio May or may not be present
		if ( index_of(source, ">Detuned Radio<") > 0) {
			shortcut("<font size=2>", "</font>", "mcd");
		} else {
			//TODO: Parse MCD Devices for non-muscle moon signs
		}
		
		// Quests: May or may not be present
		if ( index_of(source, '<center id="nudgeblock">') > 0) {
			startwith = '<center id="nudgeblock">';
			startat = index_of(source, startwith);
			endwith = "</script>";
			endat = index_of(source, endwith, startat);
			if (endat == -1) {
				endwith = "</tr></table><p></center>";
				endat = index_of(source, endwith, startat);
			}
			if ( (startat == -1) || (endat == -1) || (startat > endat) ) {
				print("CHIT: Error parsing quests", "purple");
				//Returning from parsePage
				return false;
			} else {
				chitSource["quests"] = (substring(source, startat, endat + length(endwith)));
				source.delete(0, endat + length(endwith));
			}
		}
		
		// Recent Adventures: May or may not be present
		if ( index_of(source, "Last Adventure:") > 0) {
			startwith = '<center><font size=2>';
			startat = index_of(source, startwith);
			endwith = "</center>";
			endat = index_of(source, endwith);
			if ( (startat == -1) || (endat == -1) || (startat > endat) ) {
				print("CHIT: Error parsing recent adventures", "purple");
				//Returning from parsePage
				return false;
			} else {
				chitSource["trail"] = (substring(source, startat, endat + length(endwith)));
				source.delete(0, endat + length(endwith));
			}
		}
		
		// Familiar: Could also be after effects block
		if ( index_of(source, "Familiar:") > 0) {
			//First check for (none)
			startwith = "<p><span class=small><b>Familiar:</b>";
			startat = index_of(source, startwith);
			if (startat > -1) {
				endwith = ">none</a>)</span>";
				endat = index_of(source, endwith, startat);
				if (endat == -1) {
					print("CHIT: Error parsing familiar", "purple");
					//Returning from parsePage
					return false;
				}
				chitSource["familiar"] = (substring(source, startat, endat + length(endwith)));
				source.delete(startat, endat + length(endwith));
				
			} else { //Check for current familiar
				startwith = '<p><table width=90%>';
				startat = index_of(source, startwith);
				if (startat == -1) {
					print("CHIT: Error parsing familiar", "purple");
					//Returning from parsePage
					return false;
				}
				endwith = "</table></center>";
				endat = index_of(source, endwith);
				if (endat == -1) {
					print("CHIT: Error parsing familiar", "purple");
					//Returning from parsePage
					return false;
				}
				chitSource["familiar"] = (substring(source, startat, endat + length(endwith)));
				source.delete(startat, endat + length(endwith));
			}
		} else if (my_path() == "Avatar of Boris") {
			startwith = '<b>Clancy</b>';
			startat = index_of(source, startwith);
			if (startat == -1) {
				print("CHIT: Error parsing familiar", "purple");
				//Returning from parsePage
				return false;
			}
			endwith = "</font></center>";
			endat = index_of(source, endwith);
			if (endat == -1) {
				print("CHIT: Error parsing familiar", "purple");
				//Returning from parsePage
				return false;
			}
			chitSource["familiar"] = (substring(source, startat, endat + length(endwith)));
			source.delete(startat, endat + length(endwith));
		}
		
		// Mood:
		if ( index_of(source, "Effects:") > 0) {
			shortcut('<center><p><b><font size=2>Effects:', "</center>", "mood");
		}
		
		// Intrinsic Effects
		if ( index_of(source, "Intrinsics:") > 0) {
			startwith = '<center><p><b><font size=2>Intrinsics:</font>';
			startat = index_of(source, startwith);
			if (startat == -1) {
				print("CHIT: Error parsing intrinsics", "purple");
				//Returning from parsePage
				return false;
			}
			endwith = "</td></tr></table></center>";
			endat = index_of(source, endwith, startat);
			if (endat == -1) {
				print("CHIT: Error parsing intrinsics", "purple");
				//Returning from parsePage	
				return false;
			}
			chitSource["intrinsics"] = substring(source, startat, endat + length(endwith));
			//chitSource["effects"] = substring(source, startat, endat + length(endwith));
			source.delete(startat, endat + length(endwith));
		}
		
		//<center><font size=1>[<a href="charpane.php">refresh</a>]</font>
		
		// Refresh Link
		shortcut('<center><font size=1>[<a href="charpane.php">refresh</a>]</font>', length(source), "refresh");
		
		// Buffs
		startwith = '<center><table><tr><td>';
		startat = index_of(source, startwith);
		if (startat > -1) {
			endwith = "</td></tr></table>";
			endat = index_of(source, endwith, startat);
			if (endat == -1) {
				print("CHIT: Error parsing buffs", "purple");
				//Returning from parsePage
				return false;
			}
			chitSource["effects"] = substring(source, startat, endat + length(endwith));
			//chitSource["effects"] = chitSource["effects"] + substring(source, startat, endat + length(endwith));
			source.delete(startat, endat + length(endwith));
		}
		
		// Counters if no effects are present
		if ( ( chitSource["effects"] == "" ) && ( get_property("relayCounters") != "" ) ){
			string c=get_property("relayCounters");
			string[int] sorting;
			matcher m=create_matcher("(\\d+):([\\w ]+):(.+?)(?::|$)",c);
			while ( m.find() ) {
				sorting[count(sorting)]='<tr><td><img src="http://images.kingdomofloathing.com/itemimages/'+m.group(3)+'"></td><td valign=center><font size=2>'+m.group(2)+' (<a href="">'+to_string(m.group(1).to_int()-my_turncount())+'</a>)</td></tr>';
			}
			chitSource["effects"]=sort(sorting);
		}
		
		//Whatever is left
		chitSource["wtfisthis?"] = to_string(source);
		
		return true;
	}

	void bakeValhalla() {
		buffer result;
		string myName = my_name();
		string myOutfit = "";
		string myLifeStyle = "Valhalla";
		string myPath = "";
		string inf = '<img src="/images/otherimages/inf_small.gif">';
		string karma = "??";
		
		matcher nameMatcher = create_matcher("<b\>(.*?)</b\></a\><br>Level", chitSource["character"]);
		if (find(nameMatcher)){
			myName = group(nameMatcher, 1);
		}
		matcher karmaMatcher = create_matcher('alt\="Karma" title\="Karma"\><br\>(.*?)</td\>', chitSource["health"]);
		if (find(karmaMatcher)) {
			karma = group(karmaMatcher, 1);
		}
		
		result.append('<table id="chit_character" class="chit_brick" cellpadding="0" cellspacing="0">');
		result.append('<tr><th colspan="3"><a target="mainpane" href="charsheet.php">' + myName + '</a></th></tr>');
		
		result.append('<tr>');
		result.append('<td rowspan="4" class="avatar"><a target="mainpane" href="charsheet.php"><img src="/images/otherimages/spirit.gif"></a></td>');
		result.append('<td class="label">Astral Spirit</a></td>');
		result.append('<td class="level" rowspan="2" style="background-color:white"><img src="/images/otherimages/inf_large.gif"></td>');
		result.append('</tr>');
		
		result.append('<tr><td class="info">Valhalla</td></tr>');
		result.append('<tr class="section"><td class="label">Karma</td><td class="turns" rowspan="2" style="background-color:white"><img src="/images/itemimages/karma.gif"></td></tr>');
		result.append('<tr><td class="label" style="color:darkred;font-weight:bold">' + karma + '<td></tr>');		
		result.append('</table>');
		
		int severity = 0;
		string message = "";
		string progress = "";
		result.append('<table id="chit_stats" class="chit_brick" cellpadding="0" cellspacing="0">');
		
		//Heading
		result.append('<thead><tr><th colspan="3">My Stats</th></tr></thead>');
		
		severity = -1;
		message = "&infin; / &infin;";
		progress = progressCustom(0, 10000, message, severity, false);
		
		foreach s in $strings[Muscle, Myst, Moxie, Spleen, Stomach, Liver, HP, MP] {
			result.append('<tr><td class="label" width="40px">'+s+'</td><td class="info" width="60px">'+inf+'</td><td class="progress">' + progress + '</td></tr>');
		}
		
		result.append('</table>');
		
		chitBricks["valhalla"] = result;
	}

	void bakeBricks() {
		bakeHeader();
		bakeFooter();
		
		string [string] defaultLayouts;
		defaultLayouts["roof"] = "character,stats,familiar,trail";
		defaultLayouts["walls"] = "helpers,effects";
		defaultLayouts["floor"] = "update";
		defaultLayouts["toolbar"] = "quests,modifiers";
		
		if (inValhalla) {
			bakeValhalla();
		} else {
			foreach layout in $strings[roof, walls, floor, toolbar] {
				string prefname = "chit." + layout + ".layout";
				if (get_property("bumrats_"+prefname).to_lower_case().replace_string(" ", "").to_string() != "") {
					layout = get_property("bumrats_"+prefname).to_lower_case().replace_string(" ", "");
				} else {
					layout = defaultLayouts[layout];
				}
				string [int] bricks = split_string(layout,",");
				string brick;
				for i from 0 to (bricks.count()-1) {
					brick = bricks[i];
					if (!(chitBricks contains brick)) {
						switch (brick) {
							case "character":	bakeCharacter();	break;
							case "stats":		bakeStats();		break;
							case "familiar":	bakeFamiliar();		break;
							case "trail":		bakeTrail();		break;
							case "quests":		bakeQuests();		break;
							case "effects":		bakeEffects();		break;
							case "mcd":			bakeMCD();			break;
							case "substats":	bakeSubstats();		break;
							case "organs":		bakeOrgans();		break;
							case "modifiers":	bakeModifiers();	break;
							case "elements":	bakeElements();		break;
						}
					}
				}
			}
		}
		
		bakeToolBar();
	}

	buffer addBricks(string layout) {
		buffer result;
		if (layout != "") {
			string [int] bricks = split_string(layout,",");
			string brick;
			for i from 0 to (bricks.count()-1) {
				brick = bricks[i];
				switch (brick) {
					case "toolbar":	
					case "header":	
					case "footer":	
						break;	//Special Bricks that are inserted manually in the correct places
					default: 
						result.append(chitBricks[brick]);
				}
			}
		}
		return result;
	}

	buffer buildRoof() {
		buffer result;
		string layout = get_property("bumrats_chit.roof.layout").to_lower_case().replace_string(" ", "");
		if (layout == "") layout = "character,stats,familiar,trail";
		
		if (inValhalla) {
			result.append('<div id="chit_roof" class="chit_chamber">');
			result.append(chitBricks["valhalla"]);
			result.append('</div>');
		} else if (layout != "") {
			result.append('<div id="chit_roof" class="chit_chamber">');
			result.append(addBricks(layout));
			result.append('</div>');
		}
		return result;
	}

	buffer buildWalls() {
		buffer result;
		string layout = get_property("bumrats_chit.walls.layout").to_lower_case().replace_string(" ", "");
		if (layout == "") layout = "helpers,effects";
		
		if (inValhalla) {
			return result;
		} else if (layout != "") {
			result.append('<div id="chit_walls" class="chit_chamber">');
			result.append(addBricks(layout));
			result.append('</div>');
		}
		return result;
	}

	buffer buildFloor() {
		buffer result;
		string layout = get_property("bumrats_chit.floor.layout").to_lower_case().replace_string(" ", "");
		if (layout == "") layout = "update";
		
		result.append('<div id="chit_floor" class="chit_chamber">');
		if (inValhalla) {
			//don't add anything else
		} else {
			result.append(addBricks(layout));
		}
		result.append(chitBricks["toolbar"]);
		result.append('</div>');
		return result;
	}

	buffer buildCloset() {
		buffer result;
		
		if (inValhalla) {
			return result;
		}
		
		result.append('<div id="chit_closet">');
		
		foreach key,value in chitPickers {
			result.append(value);
		}
		
		string layout = get_property("bumrats_chit.toolbar.layout").to_lower_case().replace_string(" ", "");
		
		string [int] bricks = split_string(layout,",");
		string brick;
		for i from 0 to (bricks.count()-1) {
			brick = bricks[i];
			switch (brick) {
				case "helpers":
				case "quests":
				case "mcd":
				case "trail":
				case "substats":
				case "organs":
				case "modifiers":
				case "elements":
					if ((chitBricks contains brick) && (chitBricks[brick] != "")) {
						result.append('<div id="chit_tool' + brick + '" class="chit_skeleton" style="display:none">');
						result.append(chitBricks[brick]);
						result.append('</div>');
					}
					break;
				default: 
					break;	//Special Bricks that are inserted manually in the correct places
			}
		}
		
		result.append('</div>');
		return result;
	}

	buffer buildHouse() {
		buffer house;
		house.append('<div id="chit_house">');
		house.append(buildRoof());
		house.append(buildWalls());
		house.append(buildFloor());
		house.append(buildCloset());
		house.append('</div>');
		return house;
	}

	buffer modifyPage(buffer source) {
		
		buffer page;
		
		//Set default values for zlib variables
		/*
		setvar("chit.checkversion", true);
		setvar("chit.character.avatar", true);
		setvar("chit.character.title", true);
		setvar("chit.quests.hide", false);
		setvar("chit.familiar.hats", "spangly sombrero,sugar chapeau");
		setvar("chit.familiar.pants", "spangly mariachi pants");
		setvar("chit.familiar.weapons", "time sword");
		setvar("chit.familiar.protect", false);
		setvar("chit.effects.classicons", "none");
		setvar("chit.effects.wrapCookie", "false");
		setvar("chit.effects.showicons", true);
		setvar("chit.effects.layout","buffs,intrinsics");
		setvar("chit.effects.usermap",false);
		setvar("chit.helpers.wormwood", "stats,spleen");
		setvar("chit.helpers.dancecard", true);
		setvar("chit.helpers.semirare", true);
		setvar("chit.roof.layout","character,stats,familiar,trail");
		setvar("chit.walls.layout","helpers,effects");
		setvar("chit.floor.layout","");
		setvar("chit.stats.showbars",true);
		setvar("chit.stats.layout","muscle,myst,moxie|stomach,liver,spleen|hp,mp,axel|mcd");
		setvar("chit.toolbar.layout","quests,modifiers,mood");
		*/
		
		if( index_of(source, 'alt="Karma" title="Karma"><br>') > 0 ) {
			inValhalla = true;
		}
		if( index_of(source, "Familiar:")+index_of(source, "Clancy") == -1 ) {
			isCompact = true;
		}
		
		if (isCompact) {
			print("CHIT: Compact Character Pane not supported", "purple");
			return source;
		} else if (!parsePage(source)) {
			return source;
		} else {
			//All good so far...
		}
		
		//Set default values for toolbar icons
		chitTools["helpers"] = "No helpers available|helpersnone.png";
		chitTools["quests"] = "No quests available|questsnone.png";
		chitTools["mcd"] = "MCD not available|mcdnone.png";
		chitTools["trail"] = "No recent adventures|trailnone.png";
		chitTools["substats"] = "Substats|stats.png";
		chitTools["organs"] = "Consumption|organs.png";
		chitTools["modifiers"] = "Modifiers|modifiers.png";
		chitTools["elements"] = "Elements|elements.png";
		
		// Bake all the bricks we're gonna need
		bakeBricks();
		
		//Build the house
		page.append(chitBricks["header"]);
		page.append(buildHouse());
		page.append(chitBricks["footer"]);
		
		return page;
	}

	buffer page = visit_url();
	page = modifyPage(page);
	page.write();
}

void bumcheek_crypt() {
	if(get_property("cyrptTotalEvilness")>0)
	{
		buffer results;
		results.append(visit_url());
		results.replace_string("Sniff Dirty Lihc","Sniff Dirty Lihc (Mysticality)");
		results.replace_string("Item Drop","Item Drops for evil eyes (Moxie)");
		results.replace_string("ML & Noncombat","ML & Noncombat (HP MP Stats)");
		results.replace_string("Initiative","Initiative (Muscle)");
		results.write();
	}
}

void bumcheek_dungeon() {
	buffer results;
	results.append(visit_url());
	
	string dungeon = "<br>You have "+item_amount($item[skeleton bone])+" skeleton bone(s) and "+item_amount($item[loose teeth])+" loose teeth.";
	dungeon = dungeon + "<font size=1>[<a href='Kolmafia/sideCommand?cmd=make skeleton key&pwd="+my_hash()+"'>make skeleton key</a>]</font>";
	
	results.replace_string("locked door.", "locked door. "+dungeon);
	results.write();
}

void bumcheek_dungeons() {
	buffer results;
	results.append(visit_url());
	string html = visit_url("http://www.noblesse-oblige.org/calendar/daily_"+today_to_string()+".html"), mid, str = "></a></td><td width=100 height=100></td></tr><tr>";
	
	html = substring(html, 22, index_of(html, "Hermit"));
	print(html);
	
	str = "></a></td><td width=300 height=100>"+html+"</td></tr><tr>";
	
	results.replace_string("></a></td><td width=100 height=100></td></tr><tr>", str);
	results.write();
}

void bumcheek_fight() {
	buffer results;
	results.append(visit_url());
	
	string js = "function moly() { document.getElementsByName(\"whichitem\")[0].value=2497; document.forms[\"useitem\"].submit(); }";
	js       += "function stasis(i) { document.getElementsByName(\"whichitem\")[0].value=i; document.forms[\"useitem\"].submit(); }";
	js       += "function yr() { document.getElementsByName(\"whichskill\")[0].value=7082; document.forms[\"skill\"].submit(); }";
	results.replace_string("<head>", "<head><script type='text/javascript'>"+js+"</script>");
	
	string fcle = " <font size=1>[ball polish: "+item_amount($item[ball polish])+", rigging shampoo: "+item_amount($item[rigging shampoo])+", mizz mop: "+item_amount($item[mizzenmast mop])+"]</font>";
	results.replace_string("<b>ball polish</b>", "<b>ball polish</b>"+fcle);
	results.replace_string("<b>rigging shampoo</b>", "<b>rigging shampoo</b>"+fcle);
	results.replace_string("<b>mizzenmast mop</b>", "<b>mizzenmast mop</b>"+fcle);
	
	string moly = "<a href='javascript:moly()'><b>USE MOLY MAGNET</b></a>";
	results.replace_string("It whips out a hammer", moly+" <font color=#FF00FF>It whips out a hammer</font>");
	results.replace_string("He whips out a crescent wrench", moly+" <font color=#FF00FF>He whips out a crescent wrench</font>");
	results.replace_string("It whips out a pair of pliers", moly+" <font color=#FF00FF>It whips out a pair of pliers</font>");
	results.replace_string("It whips out a screwdriver", moly+" <font color=#FF00FF>It whips out a screwdriver</font>");
	
	string boulder = "<a href='javascript:yr()'><b>USE BOULDER RAY</b></a>";
	results.replace_string("s red eye", "s red eye "+boulder);
	results.replace_string("blue eye", "blue eye "+boulder);
	results.replace_string("yellow eye", "yellow eye "+boulder);
	
	int s;
	string stasis;
	if (results.index_of(">spices") > 0) {
		s = 8;
	} else if (results.index_of(">turtle totem") > 0) {
		s = 4;
	} else if (results.index_of(">facsimile dictionary") > 0) {
		s = 1316;
	} else if (results.index_of(">dictionary") > 0) {
		s = 536;
	} else if (results.index_of(">seal tooth") > 0) {
		s = 2;
	} else if (results.index_of(">fat stacks of cash") > 0) {
		s = 185;
	} else if (results.index_of(">spectre scepter") > 0) {
		s = 2678;
	} else {
		s = 0;
	}
	if (s > 0)
	{
		stasis = "<input type='submit' value='Stasis' onClick='javascript:stasis(\""+s+"\");'>";
	} else {
		stasis = "<input type='submit' value='No Stasis' disabled='disabled'>";
	}
	results.replace_string("<input class=button type=submit onclick=\"return killforms", stasis+"<input class=button type=submit onclick=\"return killforms");
	
	results.write();
}

void bumcheek_forestvillage() {
	buffer results;
	results.append(visit_url());
	
	if (item_amount($item[continuum transfunctioner])+equipped_amount($item[continuum transfunctioner]) == 0) {
		string mystic = "a<a href=forestvillage.php?action=mystic><img src=http://images.kingdomofloathing.com/otherimages/forestvillage/mystic.gif width=100 height=100 border=0 alt=\"The Crackpot Mystic's Shed\" title=\"The Crackpot Mystic's Shed\"></a>";
		string form = "<form method='post' action='choice.php' name='choiceform1'><input type='hidden' value='" + my_hash() + "' name='pwd'><input type=hidden name=whichchoice value=664><input type=hidden name=option value=1>";
		form = form + "<input type='submit' value='Er, sure, I guess so...' class='button'></form>";
		results.replace_string(mystic, form);
	}
	
	results.write();
}

void bumcheek_guild() {
	buffer results;
	results.append(visit_url());
	
	matcher i = create_matcher("<b>([A-Za-z0-9 ]+)[ \(]?([0-9]+)?[\)]?</b>", results);
	string iname, qty;
	while (i.find()) {
		iname = i.group(1);
		qty   = i.group(2);
		if (qty == 0) { qty = 1; }
		print(iname);
		print(qty);
		if (item_amount(to_item(iname)) >= to_int(qty))
		{
			results.replace_string(iname, iname+" <img src='http://bumcheekcity.com/images/green.png' width='24px' /> ");
		} else if (item_amount(to_item(iname)) == 0) {
			results.replace_string(iname, iname+" <img src='http://bumcheekcity.com/images/red.png' width='16px' /> ");
		} else {
			results.replace_string(iname, iname+" <img src='http://bumcheekcity.com/images/yellow.png' width='24px' /> <span style='font-size:10px'>["+item_amount(to_item(iname))+"/"+qty+"]</span> ");
		}
	}
	
	results.write();
}

boolean bumcheek_inventory() {
	ItemImage[string] itemmap;
	matcher m;
	string descid, eff, name, rep;
	int drunk, full, level, spleen;
	load_current_image_map("bumrats_items", itemmap);
	
	buffer results;
	results.append(visit_url());
		string dis;

	// check if images are on/off
	// NOTE! There are THREE pages between value and name!! 
	if (index_of(visit_url("account.php?tab=inventory"), "value=\"1\"   name=\"flag_invimages") > 0) {
		debug("Inventory Images are Hidden.");
		//<b class="ircm"><a onClick='javascript:descitem(642177415,0, event);'>hot wing</a></b>&nbsp;<span>(12)</span>		
		m = create_matcher("[\(0-9+],0, event[\)];'>([0-9A-Za-z-:;',.\"\?\& ]+)</a></b>\&nbsp;<span>[\(0-9\)]*</span>", results);
	} else {
		debug("Inventory Images are not Hidden.");
		//<b class="ircm">blackberry</b>&nbsp;<span>(2)</span><font size=1><br>	
		m = create_matcher("<b class=\"ircm\">([0-9A-Za-z-:;',.\"\?\& ]+)</b>\&nbsp;<span>[\(0-9\)]*</span><font size=1>", results);
	}		
		
	while (m.find()) {
				
		name = m.group(1);

		// use mafia item files
		descid = to_item(name).descid;
		drunk  = to_item(name).inebriety;
		full   = to_item(name).fullness;
		level  = to_item(name).levelreq;
		spleen = to_item(name).spleen;
			
		eff    = itemMap[name].description;

		rep = "";
		if (length(eff) > 0) {
			rep = eff;		
		}
		
		if (full+drunk+spleen > 0)
		{
			rep = eff + " [";
			if (full > 0) { rep = rep+full+"f "; }
			if (drunk > 0) { rep = rep+drunk+"d "; } 
			if (spleen > 0) { rep = rep+spleen+"s "; }
			rep = substring(rep,0,length(rep)-1)+"]";
		}
		
		if (length(rep) > 0 && rep != "no") {
			rep = "<font color='blue' size='1'>"+rep+"</font>";
			results.replace_string(m.group(0), m.group(0)+"<br />"+rep);
		}
	}
	print("display put "+dis);
	
	results.write();
	
	return true;
}

void bumcheek_lchat() {
	return;
}

void bumcheek_main() {

	buffer results;
	results.append(visit_url());

	// check version
	buffer sourceforge;
	string name;
	sourceforge.append(visit_url("http://sourceforge.net/projects/bumcheekascend/files/"));
	
	//bUMRATSv0.12.ash || bUMRATSv1.01.ash
	matcher m = create_matcher("bUMRATSv([0-9.]+).ash</a>", sourceforge);
	while (m.find()) {		
		name = m.group(1);
		if (name.to_float() > ashVersion.to_float())
		{		
			string main = "<body><center><table cellspacing='0' width='95%'><tbody><tr><td style='color: white;' align='center' bgcolor='red'><b>bUMRATS Update</b></td></tr>";
			main += "<tr><td style='padding: 5px; border: 1px solid red;'>A new version of bUMRATS is available. Visit ";
			main += "<a target='_blank' href='http://sourceforge.net/projects/bumcheekascend/files/'>SourceForge</a> to download the new version.</td></tr></table><br /></center>";
			results.replace_string("<body>", main);
			break;
		}
	}
	
	results.write();
}

void bumcheek_ocean() {
	buffer results;
	results.append(visit_url());
	
	string js = "function ocean(lonlat) { document.getElementsByName('lon')[0].value=lonlat.substring(0,3);  document.getElementsByName('lat')[0].value=lonlat.substring(3); }";
	results.replace_string("<head>", "<head><script type='text/javascript'>"+js+"</script>");
	
	string option = "<option value='012084'>Muscle</option><option value='023066'>Mysticality</option><option value='022062'>Moxie</option>";
	option = option+"<option value='124031'>shimmering rainbow sand</option><option value='030085'>sinister altar fragment</option>";
	option = option+"<option value='086040'>El Vibrato power sphere</option><option value='063029'>Plinth</option>";
	results.replace_string("m?&quot;", "m?&quot;<br><center><select onchange='javascript:ocean(this.value)'><option></option>"+option+"</select></center>");
	
	results.write();
}

void bumcheek_pandamonium() {
	buffer results;
	results.append(visit_url());
	
	boolean haveSteel() {
		if (item_amount($item[steel margarita]) > 0) return true;
		if (item_amount($item[steel lasagna]) > 0) return true;
		if (item_amount($item[steel-scented air freshener]) > 0) return true;
		
		//Drunkenness
		if (inebriety_limit() == 19) return true;
		
		//Fullness
		int fullLim = 15;
		if (my_path() == "avatar of boris") fullLim += 5;
		if (have_skill($skill[Legendary Appetite])) fullLim += 5;
		if (fullness_limit() > fullLim) return true;
		
		//Spleen
		if (spleen_limit() == 20) return true;
		
		return false;
	}
	
	if (item_amount($item[imp air]) >= 5 && item_amount($item[bus pass]) >= 5) {
		visit_url("pandamonium.php?action=moan");
		visit_url("pandamonium.php?action=moan");
		print("bUMRATS: Getting the tutu.", "purple");
	}
	
	if (item_amount($item[observational glasses]) + equipped_amount($item[observational glasses])  > 0) {
		if (!haveSteel() && item_amount($item[Azazel's lollipop]) == 0) {
			cli_execute("checkpoint");
			equip($item[observational glasses]);
			visit_url("pandamonium.php?action=mourn&preaction=observe");
			cli_execute("outfit checkpoint");
			print("bUMRATS: Getting the lollipop.", "purple");
		}
	}
	
	if (!haveSteel() && item_amount($item[Azazel's unicorn]) == 0) {
		int bog = 0, sti = 0, fla = 0, jim = 0;
		string html = visit_url("pandamonium.php?action=sven").to_string();
		if (item_amount($item[giant marshmallow]) > 0) { bog = to_int($item[giant marshmallow]); }
		if (item_amount($item[beer-scented teddy bear]) > 0) { sti = to_int($item[beer-scented teddy bear]); }
		if (item_amount($item[booze-soaked cherry]) > 0) { fla = to_int($item[booze-soaked cherry]); }
		if (item_amount($item[comfy pillow]) > 0) { jim = to_int($item[comfy pillow]); }
		if (bog == 0) bog = to_int($item[gin-soaked blotter paper]);
		if (sti == 0) sti = to_int($item[gin-soaked blotter paper]);
		if (fla == 0) fla = to_int($item[sponge cake]);
		if (jim == 0) jim = to_int($item[sponge cake]);
		if (contains_text(html, "Give Bognort")) cli_execute("sven Bognort="+bog);
		if (contains_text(html, "Give Stinkface")) cli_execute("sven Stinkface="+sti);
		if (contains_text(html, "Give Flargwurm")) cli_execute("sven Flargwurm="+fla);
		if (contains_text(html, "Give Jim")) cli_execute("sven Jim="+jim);
		print(bog+" - "+sti+" - "+fla+" - "+jim);
		print("bUMRATS: Getting the unicorn.", "purple");
	}
	
	if (item_amount($item[Azazel's lollipop]) + item_amount($item[Azazel's tutu]) + item_amount($item[Azazel's unicorn]) == 3) {
		visit_url("pandamonium.php?action=temp");
		visit_url("pandamonium.php?action=temp");
		print("bUMRATS: Getting the steel item.", "purple");
		results.replace_string("<img src=http://images.kingdomofloathing.com/otherimages/woods/pandamonium.gif width=600 height=500 border=0 usemap=#panda>", "bUMRATS: The steel quest has been completed for you.");
	}
	
	results.write();
}

void bumcheek_pyramid() {
	buffer results;
	results.append(visit_url());
	
	//The ones with the rats that steal your stuff.
	results.replace_string("<a href=\"pyramid.php?action=lower\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_2.gif\" width=500 height=137 border=0></a>", "<a href=\"javascript:alert('No');\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_2.gif\" width=500 height=137 border=0></a>");
	results.replace_string("<a href=\"pyramid.php?action=lower\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_5.gif\" width=500 height=137 border=0></a>", "<a href=\"javascript:alert('No');\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_5.gif\" width=500 height=137 border=0></a>");
	
	if (item_amount($item[ancient bronze token]) == 0) {
		results.replace_string("<a href=\"pyramid.php?action=lower\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_3.gif\" width=500 height=137 border=0></a>", "<a href=\"javascript:alert('No');\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_3.gif\" width=500 height=137 border=0></a>");
	} else {
		results.replace_string("<a href=\"pyramid.php?action=lower\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_4.gif\" width=500 height=137 border=0></a>", "<a href=\"javascript:alert('No');\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_4.gif\" width=500 height=137 border=0></a>");
	}
	if (item_amount($item[ancient bomb]) == 0) {
		results.replace_string("<a href=\"pyramid.php?action=lower\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_1.gif\" width=500 height=137 border=0></a>", "<a href=\"javascript:alert('No');\"><img src=\"http://images.kingdomofloathing.com/otherimages/pyramid/pyramid4_1.gif\" width=500 height=137 border=0></a>");
	}
	
	results.write();
}

void bumcheek_questlog() {
	buffer results;
	results.append(visit_url());
	
	string repl = "5000 characters.</td></tr>";
	string with = "5000 characters.</td></tr><tr><td><font color='red'>Did you know? If you prefix your quest entry with the text <b>reminder:</b>,<br />the thing you write will be shown in a yellow reminder box when you next log in.</td></tr>";
	
	results.replace_string(repl, with);
	results.write();
}

void bumcheek_shore() {
	buffer results;
	results.append(visit_url());
	
	results.replace_string("Ranch Adventure", "Ranch Adventure  - <i>(Stick of Dynamite - "+item_amount($item[stick of dynamite])+" in inventory)</i>");
	results.replace_string("Island Getaway", "Island Getaway  - <i>(Tropical Orchid - "+item_amount($item[Tropical Orchid])+" in inventory)</i>");
	results.replace_string("Ski Resort", "Ski Resort  - <i>(Barbed-Wire Fence - "+item_amount($item[Barbed-Wire Fence])+" in inventory)</i>");
	
	if (my_level() == 11 && (item_amount($item[forged identification documents]) + item_amount($item[your father's MacGuffin diary])) == 0) {
		results.replace_string("Sail Away!", "WARNING! YOU DO NOT HAVE THE DOCUMENTS!");
	}
	
	results.write();
}

void bumcheek_starchart() {
	//Doesn't do anything yet.
}

void bumcheek_topmenu() {
	if (get_property("bumrats_changeTopmenu") == "false") return;

	//This function defined for neatness.
	string writeLink(string name, string html) {
		return "<a target='mainpane' href='"+html+".php'>"+name+"</a>";
	}
	string writeLink(string name) { return writeLink(name, name); }

	//Start at the beginning. 
	writeln("<!DOCTYPE html>");
	writeln("<html>");
	writeln("<head>");
	writeln("<title>bumcheekcity's Charplane</title>");
	writeln("<style type='text/css'>a{color:#000;font-size:11px;font-family:arial;margin:0;padding:0;} .a{background-color:#eeeeee;} .abc{float:left;text-align:center;padding-right:3px;line-height:13px;} .title a{font-size:13px;font-weight:bold;} #wrapper{margin:0 auto; width:1000px;}</style>");
	writeln("</head>");
	writeln("<body style='margin:0;'><script type='text/javascript'>function SelectAll(id){document.getElementById(id).focus();document.getElementById(id).select();}</script>");

	writeln("<div id='wrapper'>");
	writeln("<div class='abc'><span class='title'><a target='mainpane' href='inventory.php'>inventory</a></span><br><a target='mainpane' href='inventory.php?which=1'>cons</a> <a target='mainpane' href='inventory.php?which=2'>equ</a> <a target='mainpane' href='inventory.php?which=3'>misc</a><br><a target='mainpane' href='craft.php'>craft</a> <a target='mainpane' href='sellstuff.php'>sell</a> <a target='mainpane' href='multiuse.php'>multi</a></div>");
	writeln("<div class='abc a'><span class='title'><a target='mainpane' href='main.php'>main</a> <a target='mainpane' href='account.php'>account</a> <a target='mainpane' href='town_clan.php'>clan</a></span><br><a target='mainpane' href='clan_raidlogs.php'>logs</a> <a target='mainpane' href='clan_slimetube.php'>slime</a> <a target='mainpane' href='clan_hobopolis.php'>sew</a> <a target='mainpane' href='clan_hobopolis.php?place=2'>hobo</a><br><a target='mainpane' href='campground.php'>camp</a> <a target='mainpane' href='messages.php'>mess</a> <a target='mainpane' href='questlog.php'>ques</a> <a target='mainpane' href='skills.php'>skills</a></div>");
	writeln("<div class='abc'><form method='post' action='mall.php' name='searchform' target='mainpane'><input id='pudnuggler' onClick='SelectAll(\"pudnuggler\");' class='text' type='text' size='20' name='pudnuggler' style='font-size: 9px; width: 20px; border: 1px solid black;'/><input type='hidden' name='category' value='allitems' /><br /><input class='button' type='submit' value='Mall' style='background-color:#FFFFFF;border:2px solid black;font-family:Arial,Helvetica,sans-serif;font-size:8pt;font-weight:bold;'/></form></div>");
	writeln("<div class='abc'><form method='post' action='http://kol.coldfront.net/thekolwiki/index.php/Special:Search' name='search' target='_blank'><input class='text' id='text2' onClick='SelectAll(\"text2\");' type='text' size='20' name='search' style='font-size: 9px; width: 20px; border: 1px solid black;'/><br /><input name='go' type='submit' value='Wiki' style='background-color:#FFFFFF;border:2px solid black;font-family:Arial,Helvetica,sans-serif;font-size:8pt;font-weight:bold;'/></form></div>");
	writeln("<div class='abc a'><span class='title'><a target='mainpane' href='town.php'>town</a> <a target='mainpane' href='town_wrong.php'>wr</a> <a target='mainpane' href='town_right.php'>ri</a> <a target='mainpane' href='town_market.php'>mar</a></span><br><a target='mainpane' href='bhh.php'>bhh</a> <a target='mainpane' href='manor.php'>manor</a><br> <a target='mainpane' href='town_right.php?place=gourd'>gou</a> <a target='mainpane' href='storage.php'>hag</a>");

	string guild = "";
	switch (my_class())
	{
		case $class[Avatar of Jarlsberg]:
			guild = "da.php?place=gate2";
			break;
		case $class[Avatar of Boris]:
			guild = "da.php?place=gate1";
			break;
		case $class[Zombie Master]:
			guild = "campground.php";
			break;
		case $class[Seal Clubber]:
		case $class[Turtle Tamer]:
			guild = "guild.php?guild=m";
			break;
		case $class[Disco Bandit]:
		case $class[Accordion Thief]:
			guild = "guild.php?guild=t";
			break;
		case $class[Pastamancer]:
		case $class[Sauceror]:
			guild = "guild.php?guild=f";
			break;
	}

	if (length(guild) > 0)
		writeln(" <a target='mainpane' href='"+guild+"'>guild</a></div>");	
	writeln("<div class='abc'><span class='title'><a target='mainpane' href='place.php?whichplace=plains'>plains</a></span><br>");
	if (knoll_available()) //adventure.php? snarfblat=18
		writeln("<a target='mainpane' href='knoll.php'>knoll</a>");
	writeln(" <a target='mainpane' href='cobbsknob.php'>knob</a><br><a target='mainpane' href='crypt.php'>cyr</a> <a target='mainpane' href='bathole.php'>bat</a> <a target='mainpane' href='beanstalk.php'>bean</a></div>");
	writeln("<div class='abc a'><span class='title'><a target='mainpane' href='mountains.php'>mountains</a></span><br><a target='mainpane' href='barrel.php'>barrels</a> <a target='mainpane' href='da.php'>da</a> <a target='mainpane' href='tutorial.php'>noob</a><br><a target='mainpane' href='place.php?whichplace=mclargehuge&action=trappercabin'>tr4pz0r</a> <a target='mainpane' href='hermit.php?autoworthless=on&autopermit=on'>hermit</a></div>");
	writeln("<div class='abc'><span class='title'><a target='mainpane' href='beach.php'>beach</a> <a target='mainpane' href='island.php'>island</a></span><br><a target='mainpane' href='pyramid.php'>pyramid</a> <a target='mainpane' href='shore.php'>shore</a><br> <a target='mainpane' href='bordertown.php'>bordertown</a></div>");
	writeln("<div class='abc a'><span class='title'><a target='mainpane' href='woods.php'>woods</a></span><br><a target='mainpane' href='tavern.php'>tavern</a> <a target='mainpane' href='forestvillage.php?place=untinker'>unt</a> <br/><a target='mainpane' href='friars.php'>friars</a> </div>");
	writeln("<div class='abc'><span class='title'><span class='title'><a target='mainpane' href='oldman.php'>sea</a></span><br><a target='mainpane' href='volcanoisland.php'>vol</a></span><br><span class='title'><a target='mainpane' href='lair.php'>lair</a></span></div>");
	writeln("<div class='abc a'><span class='title'><a target='mainpane' href='#'>misc</a></span><br><a href='adminmail.php' target='mainpane'>bug</a> <a href='donatepopup.php' target='_blank'>donate</a><br><a href='bumcheekcitys_bumrats.php' target='mainpane'>MORE SCRIPTS</a></div>");
	writeln("</div>");
	
	//Now get the drop-down of relay_*.ash scripts.
	buffer results;
	results.append(visit_url());
	
	string select;
	// make sure the relay_*.ash dropdown exists first ...
	if (index_of(results, "<select ") >= 0 && index_of(results, "</select>") >= 0)
	{
		string select = substring(results, index_of(results, "<select "), index_of(results, "</select>"));
		writeln(select+"</select>");
	}
	writeln("<a target='mainpane' href='forestvillage.php?action=floristfriar'>flor</a>");
	//forestvillage.php?action=floristfriar
	//choice.php?option=4&whichchoice=720

	//Now we're going to drop-down all the clans we have whitelisted. The fact that this requires another page hit is of no consequence to the topmenu.
	string html = visit_url("clan_signup.php");
	
	if (index_of(html, "Apply to a Clan") < 0) {
		writeln("<br /><b><font color=blue><a href='topmenu.php'>RELOAD THIS ONCE YOU'RE NOT IN A FIGHT</a></font></b>");
	}

	if (index_of(html, "<select name=whichclan>") >= 0 && index_of(html, "<input type=submit class=button value='Go to Clan'>") >= 0)
	{
		select = substring(html, index_of(html, "<select name=whichclan>")+23, index_of(html, "<input type=submit class=button value='Go to Clan'>"));
		writeln("<form name='apply' target='mainpane' action='showclan.php'><input type='hidden' value='"+my_hash()+"' name='pwd'><input type='hidden' name='action' value='joinclan' />");
		writeln("<select onchange='this.form.submit()' name='whichclan'><option>-change clan-</option>"+select);
		writeln("<input type='hidden' name='confirm' value='on'><input type='submit' name='submit' value='ClanHop' /></form>");
	}
	
	writeln("<a target='mainpane' href='forestvillage.php?action=floristfriar.php'>flor</a>");
	//choice.php?option=4&whichchoice=720
}

void bumcheek_town_altar() {
	buffer results;
	results.append(visit_url());
	
	string form = "<center><span style='color:red;font-weight:bold;'>Wouldn't life be easier if everything had 'win' buttons?</span><br><form name='bumliteracy' action='' method='post'><input type='hidden' name='action' value='Yep.' />";
	form += "<input type='hidden' name='oath' value='I have read the Policies of Loathing, and I promise to abide by them.' />";
	form += "<input type='hidden' name='t1' value='3' />";
	form += "<input type='hidden' name='t2' value='1' />";
	form += "<input type='hidden' name='t3' value='3' />";
	form += "<input type='hidden' name='y1' value='1' />";
	form += "<input type='hidden' name='y2' value='1' />";
	form += "<input type='hidden' name='pwd' value='"+my_hash()+"' />";
	form += "<input type='hidden' name='horsecolor' value='Black' />";
	form += "<input type='submit' value='Prove Yourself Literate!' /></form>";
	results.replace_string("ghostaltar.gif\">", "ghostaltar.gif\">"+form);
	
	results.write();
}

void bumcheek_town_right() {
	buffer results;
	results.append(visit_url());
	
	results.replace_string("<table><tr><td rowspan=3", "<table><tr><td rowspan=3>TEST</td><td rowspan=3");
	
	results.write();
}

void bumcheek_town_wrong() {
	buffer results;
	results.append(visit_url());
	
	results.replace_string("title=\"The Tracks\"></a></td>", "title=\"The Tracks\"></a></td><td rowspan=3><a href='storage.php'>Hagnk</a><br /><a href='town_right.php?place=gourd'>Gourd Tower</a><br /><a href='guild.php?place=f'>Muscle Guild</a><br /><a href='guild.php?place=m'>Myst Guild</a><br /><a href='manor.php'>Manor</a></td>");
	
	results.write();
}

void bumcheek_trapper() {
	buffer results;
	results.append(visit_url());
	
	string cmd = "sideCommand?cmd=familiar parrot;trapper.php;familiar "+to_string(my_familiar())+"&pwd="+my_hash();
	string js = "function trapper() { top.mainpane.document.location.href = '/KoLmafia/"+cmd+"'; top.mainpane.document.location.href = 'trapper.php'; }";
	results.replace_string("<head>", "<head><script type='text/javascript'>"+js+"</script>");
	
	results.replace_string("alt=\"The Trapper\"></center>", "alt=\"The Trapper\"><a href='javascript:trapper()'><font size=1>[come back here with a parrot]</font></a></center>");
	
	results.write();
}

void bumcheekcitys_bumrats() {
	bcheader();
	writeln("<p><a href='bumcheekcitys_hardcore_checklist.php'>bumcheekcity's Hardcore Checklist</a></p>");
	writeln("<p><a href='bumcheekcitys_networth.php'>bumcheekcity's Networth Clone</a></p>");
	writeln("<p><a href='bumcheekcitys_wiki_shortcut.php'>bumcheekcity's Wiki Shortcut for New Items</a></p>");
	writeln("<p><a href='bumcheekcitys_settings_manager.php'>bumcheekcity's Settings Manager</a></p>");
	bcfooter();
}

//Let's get checkin'
void bumcheekcitys_hardcore_checklist() {
	string [int] bufferedoutput;
	int buffernumber = 1;
	int[item] Telescope;
	string[item] Telescope1;
	string[item] Telescope2;
	string[item] Telescope3;
	string[int] upgrade;
	int telescopeupgrade;
	//Gate 1
	Telescope1[$item[pygmy pygment]]="an armchair";
	Telescope1[$item[wussiness potion]]="a cowardly-looking man";
	Telescope1[$item[gremlin juice]]="a banana peel";
	Telescope1[$item[adder bladder]]="a coiled viper";
	Telescope1[$item[Angry Farmer candy]]="a rose";
	Telescope1[$item[thin black candle]]="a glum teenager";
	Telescope1[$item[super-spiky hair gel]]="a hedgehog";
	Telescope1[$item[Black No. 2]]="a raven";
	Telescope1[$item[Mick's IcyVapoHotness Rub]]="a smiling man";

	//Tower 1-5
	Telescope2[$item[frigid ninja stars]]="catch a glimpse of a flaming katana";
	Telescope2[$item[spider web]]="catch a glimpse of a translucent wing";
	Telescope2[$item[sonar-in-a-biscuit]]="see a fancy-looking tophat";
	Telescope2[$item[black pepper]]="see a flash of albumen";
	Telescope2[$item[pygmy blowgun]]="see a giant white ear";
	Telescope2[$item[meat vortex]]="see a huge face made of Meat";
	Telescope2[$item[chaos butterfly]]="see a large cowboy hat";
	Telescope2[$item[photoprotoneutron torpedo]]="see a periscope";
	Telescope2[$item[fancy bath salts]]="see a slimy eyestalk";
	Telescope2[$item[inkwell]]="see a strange shadow";
	Telescope2[$item[hair spray]]="see moonlight reflecting off of what appears to be ice";
	Telescope2[$item[disease]]="see part of a tall wooden frame";
	Telescope2[$item[bronzed locust]]="see some amber waves of grain";
	Telescope2[$item[Knob Goblin firecracker]]="see some long coattails";
	Telescope2[$item[powdered organs]]="see some pipes with steam shooting out of them";
	Telescope2[$item[leftovers of indeterminate origin]]="see some sort of bronze figure holding a spatula";
	Telescope2[$item[mariachi G-string]]="see the neck of a huge bass guitar";
	Telescope2[$item[NG]]="see what appears to be the North Pole";
	Telescope2[$item[plot hole]]="see what looks like a writing desk";
	Telescope2[$item[baseball]]="see the tip of a baseball bat";
	Telescope2[$item[razor-sharp can lid]]="see what seems to be a giant cuticle";

	//Tower 6
	Telescope3[$item[tropical orchid]]="formidable stinger";
	Telescope3[$item[stick of dynamite]]="wooden beam";
	Telescope3[$item[barbed-wire fence]]="pair of horns";

	//Used for determining the number of N's and G's needed in Level 9/10 checks. 
	boolean northPoleDef   = false;
	boolean northPoleMaybe = true;

	/*
	  FINISH DECLARING GLOBAL VARIABLES
	*/

	//Stores the output for a given level.
	boolean bufferoutput(string stuff) {
	  //Add text to buffer
	  if (length(stuff) > 0) {
		bufferedoutput[buffernumber] = stuff;
		buffernumber = buffernumber + 1;
	  }
	  return true;
	}

	//Prints the output for a given level. 
	boolean bufferoutput(int level) {
	  //Is there anything to say, i.e. is the array empty?
	  if (length(bufferedoutput[1]) > 0) {
		//Print level number.
		writeln("<fieldset>");
		writeln("<legend>Commencing Level " + to_string(level) + " checks...</legend>");
		//Print all output.
		foreach i in bufferedoutput {
		  writeln("<p>"+bufferedoutput[i]+"</p>");
		}
		//Clear buffer.
		clear(bufferedoutput);
		buffernumber = 1;
		writeln("</fieldset>");
	  }
	  return true;
	}

	//Used for Bad Moon to check for the NS Familiars.
	boolean checkFamiliar(string famname, string itemname) {
	  if (!have_familiar(to_familiar(famname))) {
		if (item_amount(to_item(itemname)) == 0) {
		  print("You do not have the " + itemname + ".");
		} else {
		  if (in_bad_moon()) {
			use(1, to_item(itemname));
		  } else {
			print("You have the " + itemname + ", but no " + famname + " in your terranium.");
		  }
		}
	  } else {
		debug("You have the " + famname + ".");
	  }
	  return true;
	}

	string hasItem(string itemname, int amount)
	{
	  int numgot = item_amount(to_item(itemname)) + closet_amount(to_item(itemname));
	  if (have_equipped(to_item(itemname)))
	  {
		numgot = numgot + 1;
	  }
	  
	  //First, let's just double-check if it's a scope item.
	  if (Telescope[to_item(itemname)] > 0)
	  {
		//Then it is.
		if (numgot >= amount)
		{
		  //Then we have the required quantites of items. YAY!
		  return "";
		} else {
		  if (Telescope[to_item(itemname)] == 1)
		  {
			//Then it's possibly needed.
			if (amount == 1)
			{
			  return "You (might) need " + amount + " " + itemname + ".";
			} else {
			  return "You (might) need " + amount + " " + itemname + ". You have " + numgot + ", needing " + (amount - numgot);
			}
		  } else if (Telescope[to_item(itemname)] == 2) {
			//Then it's definitely needed.
			if (amount == 1)
			{
			  return "YOU DEFINITELY NEED " + amount + " " + itemname + ".";
			} else {
			  return "YOU DEFINITELY NEED " + amount + " " + itemname + ". You have " + numgot + ", needing " + (amount - numgot);
			}
		  } else {
			//Then it's definitely NOT needed. Only here for debugging, really.
			//return "YOU DONT NEED THE ITEM - " + itemname;
			return "";
		  }
		} 
	  } else {
		//It's not a tower item.
		if (numgot >= amount)
		{
		  //Then we have the required quantites of items. YAY!
		  return "";
		} else {
		  if (amount == 1)
		  {
			return "You need " + amount + " " + itemname + ".";
		  } else {
			return "You need " + amount + " " + itemname + ". You have " + numgot + ", needing " + (amount - numgot);
		  }
		} 
	  }
	  return "";
	}

	//Prints the total quantity of the items. Useful for stuff in the same Zap group. 
	int hasHowManyOf(string [string] itemlist)
	{
	  int amount;
	  foreach var in itemlist
	  {
		amount = amount + item_amount(to_item(var)) + closet_amount(to_item(var));
	  }
	  return amount;
	}

	//Checks if you have an outfit.
	string outfitCheck(string item1, string item2, string item3, string outfitname)
	{
	  int n1 = item_amount(to_item(item1));
	  int n2 = item_amount(to_item(item2));
	  int n3;
	  if (length(item3) > 0) 
	  { 
		n3 = item_amount(to_item(item3)); 
	  } else {
		n3 = 1; 
	  }
	  
	  if (have_equipped(to_item(item1))) { n1 = n1 + 1; }
	  if (have_equipped(to_item(item2))) { n2 = n2 + 1; }
	  if (have_equipped(to_item(item3))) { n3 = n3 + 1; }
	  
	  debug(outfitname + " " + n1 + " - " + n2 + " - " + n3);
	  
	  if (n1 >= 1 && n2 >= 1 && n3 >= 1)
	  {
		debug("You have the " + outfitname + ".");
		return "";
	  } else {
		if (n1 + n2 + n3 >= 3)
		{
		  return "You don't have the " + outfitname + ", but you could Zap it.";
		} else if (n1 + n2 + n3 == 0) {
		  return "You don't have any items for the " + outfitname + ".";
		} else {
		  hasItem(item1, 1);
		  hasItem(item2, 1);
		  if (length(item3) > 0) { hasItem(item3, 1); }
		  return "You don't have some of the items for the " + outfitname + ".";
		}
		return "";
	  }
	  return "";
	}

	void telescope()
	{
	  /*
		First, let's set up the main array Telescope
		This array will store:
		Telescope[$item[itemname]] = "1" (possibly needed)
		Telescope[$item[itemname]] = "2" (definitely needed)
		Telescope[$item[itemname]] = "3" (definitely not needed)
	  */
	  foreach Itemm in Telescope1 {
		Telescope[Itemm] = 1;
	  }
	  foreach Itemm in Telescope2 {
		Telescope[Itemm] = 1;
	  }
	  foreach Itemm in Telescope3 {
		Telescope[Itemm] = 1;
	  }
	  
		//Mafia does not refresh telescope values upon entering BM. Else get the scope number.
		if (in_bad_moon())
		{
			telescopeupgrade = 0;
		} else {
		  telescopeupgrade = to_int(get_property("telescopeUpgrades"));
		}
		
		if (telescopeupgrade > 0)
		{
		  upgrade[1] = get_property("telescope1");
		  upgrade[2] = get_property("telescope2");
		  upgrade[3] = get_property("telescope3");
		  upgrade[4] = get_property("telescope4");
		  upgrade[5] = get_property("telescope5");
		  upgrade[6] = get_property("telescope6");
		  upgrade[7] = get_property("telescope7");
		  
		  //If we have a telescope, we can ALWAYS see the first gate.
			foreach Itemm in Telescope1
			{
				if(Telescope1[Itemm] == upgrade[1])
				{
					Telescope[Itemm] = 2;
				} else {
				  Telescope[Itemm] = 3;
				}
			}
			
			//Now, if the power of the scope is >=6, we know the items for Tower 1-5 are definite.
			//Else if the power is 2-5 inclusive, we can conclude less.
			if (telescopeupgrade >= 6)
			{
			  foreach Itemm in Telescope2
			  {
				if ((Telescope2[Itemm] == upgrade[2]) || (Telescope2[Itemm] == upgrade[3]) || (Telescope2[Itemm] == upgrade[4]) || (Telescope2[Itemm] == upgrade[5]) || (Telescope2[Itemm] == upgrade[6]))
				{
				  Telescope[Itemm] = 2;
				} else {
				  Telescope[Itemm] = 3;
				}
			  }
			} else if (telescopeupgrade >= 2) {
			  foreach Itemm in Telescope2
			  {
				//This time, we won't set Telescope[item] = 3, because we don't know what we DONT need if we have < 6 telescope upgrades.
				if ((Telescope2[Itemm] == upgrade[2]) || (Telescope2[Itemm] == upgrade[3]) || (Telescope2[Itemm] == upgrade[4]) || (Telescope2[Itemm] == upgrade[5]))
				{
				  Telescope[Itemm] = 2;
				}
			  }
			}
			
			//Finally if the power is 7, we can find out about the last Shore item for Tower 6.
			if (telescopeupgrade == 7)
			{
			  foreach Itemm in Telescope3
			{
				if(Telescope3[Itemm] == upgrade[7])
				{
					Telescope[Itemm] = 2;
				} else {
				  Telescope[Itemm] = 3;
				}
			}
			}
		}
		
		/*
		This is obviously just for testing.
		foreach number in upgrade
		{
		  print(to_string(number) + " === " + to_string(upgrade[number]), "blue");
		}
		
		foreach Item in Telescope
		{
		  print(to_string(Item) + " --- " + to_string(Telescope[Item]));
		}
		abort();
	  */
	}
	
	bcheader();
	string [string] urltext;
	//Check if a URL contains a particular string. 
	boolean urlContains(string url, string needle)
	{
	  string html;
	  if (length(urltext[url]) > 0)
	  {
		//print("You have already visited " + url + ".", "green");
		html = urltext[url];
	  } else {
		//print("You have not already visited " + url + " so I am storing it for you.", "red");
		html = visit_url(url);
		urltext[url] = html;
	  }
	  if (index_of(html, needle) > 0)
	  {
		return true;
	  } else {
		return false;
	  }
	}

  //Before ANYTHING, throw a hit to council.php. This is because some of the quests (for example, the boss bat)
  //don't update the quest log, even though they're done, unless one visits the council.
  //Doing it via urlContains caches it, rather than using visit_url directly. 
  urlContains("council.php", "");
  
  //Then, check the telescope.
  telescope();

  // zapwand
  boolean hasZapWand = false;
  hasZapWand = item_amount($item[aluminum wand]) + item_amount($item[ebony wand]) + item_amount($item[hexagonal wand]) + item_amount($item[marble wand]) + item_amount($item[pine wand]) >= 1;

  //Just before we start, check the Wand of Nagamar Situation. We'll use this a bit later on. 
  boolean hasWandOfNagamar = false;
  boolean needWandOfNagamar = true;
  boolean hasWA = false;
  boolean hasND = false;
  boolean hasNG = false;
  if (item_amount($item[Wand of Nagamar]) >= 1)
  {
    debug("You have the Wand of Nagamar");
    hasWandOfNagamar = true;
  } else {

		switch (my_class()) {
			case $class[Avatar of Boris]:	
			case $class[Avatar of Jarlsberg]:
				debug("Class does not need the Wand of Nagamar");
				needWandOfNagamar = false;
				break;

			default:
				if (item_amount($item[WA]) >= 1 && item_amount($item[ND]) >= 1)
				{
				  hasWandOfNagamar = true;
				}
				if (item_amount($item[WA]) >= 1)
				{
				  hasWA = true;
				}
				if (item_amount($item[ND]) >= 1)
				{
				  hasND = true;
				}
				if (item_amount($item[NG]) >= 1)
				{
				  hasNG = true;
				}
			break;
		}
  }
  
  //CHECK FOR FAMILIARS IN BAD MOON
  if (in_bad_moon())
  {
  	print("Commencing Bad Moon Checks");
  	
  	checkFamiliar("Angry Goat", "goat");
  	checkFamiliar("Barrrnacle", "barrrnacle");
  	checkFamiliar("Levitating Potato", "potato sprout");
  	checkFamiliar("Mosquito", "mosquito larva");
  	checkFamiliar("Sabre-Toothed Lime", "sabre-toothed lime cub");
  	checkFamiliar("Star Starfish", "star starfish");
  }
  
  //Some variables appear to need to be declared here. (Infiltration, you see.)
  boolean hasOrcOutfit = false;
  boolean couldZapOrcOutfit = false;
  
  //I've done this so I can override it for testing. 
  int my_level;
  my_level = my_level();
  //my_level = 13;
  
  //Level 1 Checks:
  if (my_level >= 1)
  {
    //Keys
    string [string] itemlist;
    itemlist["Boris's key"] = "You don't have Boris's Key.";
    itemlist["Jarlsberg's key"] = "You don't have Jarlsberg's Key";
    itemlist["Sneaky Pete's key"] = "You don't have Sneaky Pete's Key";
    if (hasHowManyOf(itemlist) < 2 || (hasHowManyOf(itemlist) == 2 && !hasZapWand))
    {
        bufferoutput("You only have " + hasHowManyOf(itemlist) + " of Boris's Key, Jarlsberg's Key and/or Sneaky Pete's Key and " + item_amount($item[fat loot token]) + " fat loot tokens.");
    } else {
      debug("You have at least two of the Boris/Jarl/Pete's Keys and zap wand");
    }
    
    //Discover Spookyraven Manor
    if (urlContains("town_right.php", "manor.gif"))
    {
      debug("Spookyraven Manor has been discovered.");
    } else {
      bufferoutput("You have not yet discovered Spookyraven Manor");
    }
    
    //Knob Goblin Encryption Key
    
    if (urlContains("place.php?whichplace=plains", "knob2.gif"))
    {
      debug("You can go inside Cobb's Knob.");
    } else {
      if (item_amount($item[Knob Goblin encryption key]) > 0)
      {
        debug("You have the Knob Goblin Encryption Key.");
      } else {
        bufferoutput("You do not have the Knob Goblin Encryption Key.");
      }
    }
    
    bufferoutput(hasItem("razor-sharp can lid", 1));
    bufferoutput(hasItem("leftovers of indeterminate origin", 1));
    bufferoutput(hasItem("spider web", 1));
    
	//
	// check for NS instruments
	//

	// stringed
	clear(itemlist);
    itemlist["acoustic guitarrr"] = "You don't have an acoustic guitarrr.";
    itemlist["heavy metal thunderrr guitarrr"] = "You don't have a heavy metal thunderrr guitarrr.";
    itemlist["stone banjo"] = "You don't have a stone banjo.";
    itemlist["Disco Banjo"] = "You don't have a Disco Banjo.";
    itemlist["Shagadelic Disco Banjo"] = "You don't have a Shagadelic Disco Banjo.";
    itemlist["Seeger's Unstoppable Banjo"] = "You don't have a Seeger's Unstoppable Banjo.";
    itemlist["4-dimensional guitar"] = "You don't have a 4-dimensional guitar.";
    itemlist["Crimbo ukelele"] = "You don't have a Crimbo ukelele.";
    itemlist["dueling banjo"] = "You don't have a dueling banjo.";
    itemlist["half-sized guitar"] = "You don't have a half-sized guitar.";
    itemlist["Massive sitar"] = "You don't have a Massive sitar.";
    itemlist["out-of-tune biwa"] = "You don't have an out-of-tune biwa.";
    itemlist["plastic guitar"] = "You don't have a plastic guitar.";
    itemlist["Zim Merman's guitar "] = "You don't have a Zim Merman's guitar .";
	if (hasHowManyOf(itemlist) < 1)
    {
		if (item_amount($item[ten-leaf clover]) > 0 || item_amount($item[disassembled clover]) > 0 || item_amount($item[big rock]) > 0)
			bufferoutput("You do not have a stringed instrument for the NS Lair but may be able to craft a stone banjo.");		
		else
			bufferoutput("You do not have an stringed instrument for the NS Lair.");
	}

	// accordions
	clear(itemlist);
    itemlist["calavera concertina"] = "You don't have a calavera concertina.";
	itemlist["stolen accordion"] = "You don't have a stolen accordion.";
    itemlist["Rock and Roll Legend"] = "You don't have a Rock and Roll Legend.";
    itemlist["Squeezebox of the Ages"] = "You don't have a Squeezebox of the Ages.";
    itemlist["The Trickster's Trikitixa"] = "You don't have a The Trickster's Trikitixa.";
	if (hasHowManyOf(itemlist) < 1)
    {
		bufferoutput("You do not have an accordion for the NS Lair.");
	}

	// percussion
	clear(itemlist);
    itemlist["big bass drum"] = "You don't have a big bass drum.";
	itemlist["black kettle drum"] = "You don't have a black kettle drum.";
    itemlist["bone rattle"] = "You don't have a bone rattle.";
    itemlist["hippy bongo"] = "You don't have a hippy bongo.";
    itemlist["jungle drum"] = "You don't have a jungle drum.";
    itemlist["tambourine"] = "You don't have a tambourine.";
	if (hasHowManyOf(itemlist) < 1)
    {
		if (item_amount($item[skeleton bone]) > 0 && item_amount($item[broken skull]) > 0)
			bufferoutput("You do not have a percussion instrument for the NS Lair but can craft a bone rattle.");		
		else
			bufferoutput("You do not have a percussion instrument for the NS Lair.");
	}

    bufferoutput(1);
  }
  
  if (my_level >= 2)
  {
    //Mosquito Larva
    if (!have_familiar($familiar[Mosquito]))
    {
      if (item_amount($item[mosquito larva]) == 0)
      {
	        if (urlContains("questlog.php?which=2", "Looking for a Larva in All the Wrong Places"))
				debug("Mosquito quest completed");
			else
				bufferoutput("You do not have the Mosquito Larva.");
      } else {
        bufferoutput("You have the Mosquito Larva, but no Mosquito in your terranium.");
      }
    } else {
      debug("You have the Mosquito");
    }
    
    //Unlocked Hidden Temple
    if (urlContains("questlog.php?which=3", "You have discovered the Hidden Temple."))
    {
      debug("The Hidden Temple has been discovered.");
    } else {
      bufferoutput("You have not yet discovered The hidden Temple.");
      
      //Check for the items
      if (item_amount($item[spooky sapling]) == 1 && item_amount($item[spooky-gro fertilizer]) == 1 && item_amount($item[spooky temple map]) == 1)
      {
        bufferoutput("You have all the items to unlock the hidden temple, so it's being unlocked...");
        use(1, $item[spooky temple map]);
      } else {
        bufferoutput(hasItem("spooky sapling", 1));
        bufferoutput(hasItem("spooky-gro fertilizer", 1));
        bufferoutput(hasItem("spooky temple map", 1));
      }
    }
    
    //Loaded Dice
    if (in_bad_moon())
    {
      bufferoutput(hasItem("loaded dice", 1));
    }
    bufferoutput(2);
  }
  
  if (my_level >= 3)
  {
    //Dinghy Plans or skiff
    if (item_amount($item["dingy dinghy"]) > 0 || item_amount($item["skeletal skiff"]) > 0)
    {
      debug("You have discovered the Island");
    } else {
      if (item_amount($item[dingy planks]) > 0 && item_amount($item[dinghy plans]) > 0)
      {
        bufferoutput("You have the dingy items, so using the dinghy plans now...");
        use(1, $item[dinghy plans]);
      } else {
        bufferoutput(hasItem("dingy planks", 1));
        bufferoutput(hasItem("dinghy plans", 1));
		bufferoutput(item_amount($item[skeleton]));
      }
    }
    
    //Gate 6 Items
    
    //Pool Cue, Hand Chalk, Library Key
    if (item_amount($item[Spookyraven library key]) > 0)
    {
      debug("You have unlocked the Spookyraven Library");
    } else {
      bufferoutput("You need to unlock the Spookyraven Library.");
    }
    
    //NS Items from South of the Border
    bufferoutput(hasItem("lime-and-chile-flavored chewing gum", 1));
    bufferoutput(hasItem("jabañero-flavored chewing gum", 1));
    bufferoutput(hasItem("pickle-flavored chewing gum", 1));
    bufferoutput(hasItem("tamarind-flavored chewing gum", 1));
    bufferoutput(hasItem("handsomeness potion", 1));
    bufferoutput(hasItem("Meleegra pills", 1));
    bufferoutput(hasItem("marzipan skull", 1));
    bufferoutput(hasItem("mariachi G-string", 1));
    bufferoutput(3);
  }
  
  if(my_level >= 4)
  {
    //Boss Bat's Cave
    if (urlContains("questlog.php?which=2", "You have slain the Boss Bat."))
    {
      debug("You have Defeated the Boss Bat.");
    } else {
      bufferoutput("You need to Defeat the Boss Bat.");
    }
    
    //Enchanted Bean for Level 10 Quest
    if (urlContains("questlog.php?which=3", "You have planted a Beanstalk in the Nearby Plains."))
    {
      debug("You have already planted the Enchanted Bean.");
    } else {
      //We'll plant the bean in the level 10 checks. 
      bufferoutput(hasItem("enchanted bean", 1));
    }
    
    //Digital key
    if (item_amount($item[digital key]) > 0)
    {
      debug("You have the Digital Key");
    } else {
      //Check if they have 30 white. Also need to check for making them out of RGB.
      int minothercol = min(item_amount($item[red pixel]), min(item_amount($item[blue pixel]), item_amount($item[green pixel])));
      int totalwhite  = item_amount($item[white pixel]) + minothercol;
      if (totalwhite >= 30)
      {
        bufferoutput("You have 30 or more white pixels, so let's make the key...");
        create(1, $item[digital key]);
      } else {
        bufferoutput("You don't have 30 white pixels. You have " + item_amount($item[white pixel]) + " white pixels, and at least " + minothercol + " others, for a total of " + totalwhite + ".");
      }
    }
    
    //Various NS Items
    bufferoutput(hasItem("sonar-in-a-biscuit", 1));
    bufferoutput(hasItem("baseball", 1));
    bufferoutput(hasItem("disease", 1));
    bufferoutput(4);
  }
  
  if(my_level >= 5)
  {
    //Cobb's Knob Outfit
    if (urlContains("questlog.php?which=2", "You have slain the Goblin King."))
    {
      debug("You have killed the Knob Goblin King.");
    } else {
      bufferoutput(outfitCheck("Knob Goblin harem pants", "Knob Goblin harem veil", "", "Harem Outfit"));
      bufferoutput(hasItem("Knob Goblin perfume", 1));
      bufferoutput("You have not defeated the Goblin King");
    }
    bufferoutput(5);
  }
  
  if(my_level >= 6)
  {
    //Whitey's Grove. Infiltration Equip is handled in the Lv7 Code.
    if ((item_amount($item[wet stew]) + item_amount($item[wet stunt nut stew]) + item_amount($item[Mega Gem]) == 0) || have_equipped($item[Mega Gem]))
    {
      //Then the ingredients for the wet stew are needed.
      bufferoutput(hasItem("lion oil", 1));
      bufferoutput(hasItem("bird rib", 1));
    }
    
    //Orc & Hippy Outfits. 
    bufferoutput(outfitCheck("filthy knitted dread sack", "filthy corduroys", "", "Hippy Disguise"));
    if (length(outfitCheck("Orcish baseball cap", "homoerotic frat-paddle", "Orcish cargo shorts", "Orcish Frat Boy Outfit")) == 0)
    {
      hasOrcOutfit = true;
    } else {
      //There really is no need to actually check for this.
      //bufferoutput(outfitCheck("Orcish baseball cap", "homoerotic frat-paddle", "Orcish cargo shorts", "Orcish Frat Boy Outfit"));
    }
    
    //Friars
    if (urlContains("questlog.php?which=2", "You have cleansed the taint of the Deep Fat Friars."))
    {
      debug("You've already helped the Friars.");
    } else {
      if(item_amount($item[eldritch butterknife]) + item_amount($item[dodecagram]) + item_amount($item[box of birthday candles]) == 3)
      {
        bufferoutput("You have all the Friars' Items let's go perform the ritual NO URL AVAILABLE!!!!!!!11");
        //go to the URL
      } else {
        bufferoutput(hasItem("eldritch butterknife", 1));
        bufferoutput(hasItem("dodecagram", 1));
        bufferoutput(hasItem("box of birthday candles", 1));        
      }
    }
    if (!hasWandOfNagamar && !hasWA)
    {
      bufferoutput(hasItem("ruby W", 1));
    }
    bufferoutput(hasItem("wussiness potion", 1));
    bufferoutput(6);
  }
  
  if(my_level >= 7)
  {
    //Pirates Outfit. Infiltration gear checked below. 
    if ((item_amount($item[pirate fledges]) == 0) && (!have_equipped($item[pirate fledges])))
    {
      //First, check if the F'c'le is unlocked. If it is, they only need the three cleaning items. 
      //MUST CHECK THIS IS RIGHT
      if (urlContains("questlog.php?which=1", "joined Cap'm Caronch's crew"))
      {
        //F'c'le is unlocked. 
        bufferoutput(hasItem("ball polish", 1));
        bufferoutput(hasItem("mizzenmast mop", 1));
        bufferoutput(hasItem("rigging shampoo", 1));
      } else {
        //Do they have the Blueprints, or the dentures they would give?
        if (item_amount($item[Cap'm Caronch's Dentures]) == 1)
        {
          bufferoutput("You have the Dentures. Give them to the Captain in the Barr to unlock the F'c'le.");
        } else if (item_amount($item[Orcish Frat House Blueprints]) == 1) {
          bufferoutput("You have the Blueprints. Get your infiltration gear on and go get the dentures.");
        } else if (item_amount($item[Cap'm Caronch's nasty booty]) == 1) {
          bufferoutput("You have the Nasty Booty. Give it to the Cap'm in the Barr.");
        } else if (item_amount($item[Cap'm Caronch's map]) == 1) {
          bufferoutput("You have the Map. Go fight the massive crab for the Nasty Booty.");
        } else {
          //Check they have Swashbuckling stuff. There is just no way anybody's got here with 25 Myst/Mox.
          if (have_outfit("Swashbuckling Getup"))
          {
            debug("You don't have the Cap'm's map yet. Put your swashbuckling kit on and go get it.");
          } else {
            bufferoutput("You don't have the Swashbuckling Getup.");
          }
        }
      }
    } else {
      debug("You already have your Pirate Fledges.");
    }
    
    //Check infiltration gear. 
    if ((item_amount($item[pirate fledges]) == 0) && (!have_equipped($item[pirate fledges])))
    {
      //Then they're going to need the infiltration gear. IF they haven't unlocked the F'c'le
      if (!urlContains("questlog.php?which=1", "joined Cap'm Caronch's crew"))
      {
        if (hasOrcOutfit || 
          (item_amount($item[mullet wig]) >= 1 && item_amount($item[briefcase]) >= 1) || 
          (((item_amount($item[frilly skirt]) >= 1) || in_muscle_sign()) && item_amount($item[hot wing]) >= 3))
        {
          debug("You have an Infiltration Outfit");
        } else {
          if (couldZapOrcOutfit)
          {
            bufferoutput("You don't have any Infiltration Kit, but could Zap the Orc Outfit.");
          } else {
            bufferoutput("You don't have any Infiltration Kit at all.");
          }
        }
      }
    }
    
    //Dungeons of Doom. Need to check for potions.
    if (urlContains("questlog.php?which=3", "You have discovered the secret of the Dungeons of Doom."))
    {
      debug("The Dungeons of Doom have been unlocked.");
    } else {
      bufferoutput("You should unlock the Dungeons of Doom.");
    }
    
    //Check for Zap Wand. Technically not necessary, but I don't care. 
    if (hasZapWand)
    {
      debug("You have a Zap Wand");
    } else {
      bufferoutput("You don't have a Zap Wand. You'll almost certainly want to get one.");
    }
    
    //Skeleton Bone. 
    if (item_amount($item[skeleton key]) >= 1)
    {
      debug("You have a Skeleton Key.");
    } else {
      bufferoutput(hasItem("Skeleton Bone", 1));
      bufferoutput(hasItem("Loose Teeth", 1));
    }
    
    //Rest of the Crypt.
    if (urlContains("questlog.php?which=2", "You've undefiled the Cyrpt, and defeated the Bonerdagon.")) 
    {
      debug("You have undefiled the crypt.");
    } else {
      bufferoutput("You need to undefile the crypt."); 
    }
    
    //Haunted Library
    if (urlContains("town_right.php", "manor.php"))
    { 
      if (urlContains("manor.php", "manor2.php"))
      {
        debug("You've unlocked the Second Floor of the Manor.");
      } else {
        bufferoutput("You need to unlock the Second Floor of the Manor.");
      }
    }
    
    bufferoutput(hasItem("inkwell", 1));
    bufferoutput(7);
  }
  
  if(my_level >= 8)
  {
    boolean visittrapzor;
    
    if (urlContains("questlog.php?which=2", "You have helped the Trapper"))
    {
      debug("The Mt. McLargeHuge Quest is done.");
	}
	else if (urlContains("questlog.php?which=1", "You're ready to ascend to the Icy Peak of Mt. McLargeHuge")) 
	{
        bufferoutput("Ascend to the Ice Peak of Mt. McLargeHuge and investigate.");     	  
    } else {
      if (urlContains("questlog.php?which=1", "The Tr4pz0r wants you to find some way to protect yourself from the cold.")) 
      {
        //Then we definately need to visit the tr4pz0r.
        bufferoutput("You need to visit the trapzor");
        visittrapzor = true;
      }
      
      if (urlContains("questlog.php?which=1", "The Tr4pz0r wants you to bring him 3 chunks of goat cheese from the Goatlet.")) 
      {
        if (visittrapzor || item_amount($item[goat cheese]) >= 3)
        {
          if (have_skill($skill[Northern Exposure]))
          {
            visit_url("trapper.php");
            bufferoutput("I finished off the Tr4pz0r's Quest for you. Aren't I nice?");
          } else if (have_familiar($familiar[Exotic Parrot])) {
            familiar currentfam = my_familiar();
            use_familiar($familiar[Exotic Parrot]);
            visit_url("trapper.php");
            bufferoutput("I finished off the Tr4pz0r's Quest for you. Aren't I nice?");
            use_familiar(currentfam);
          } else {
            bufferoutput("Get some Cold Resist and meet the Tr4pz0r!");
          }
        } else {
          bufferoutput(hasItem("goat cheese", 3));
        }
      } else {
        if (length(outfitCheck("miner's helmet", "miner's pants", "7-foot dwarven mattock", "Mining Outfit")) > 0)
        {
          bufferoutput("You now need 3 of the ore the 1337 Tr4pz0r wanted from you.");
        }
      }
    }
    bufferoutput(hasItem("frigid ninja stars", 1));
    bufferoutput(8);
  }
  
  if(my_level >= 9)
  {
    //Orc Chasm
    if (urlContains("questlog.php?which=1", "A Quest, LOL"))
    {
      debug("You've done the Highlands Quest");
    } else {
        bufferoutput("You need to help Black Angus in the Highlands.");
    }



	// TODO move this check out, we'll always only need to max (for now)
    int totalNs = item_amount($item[lowercase N]) + item_amount($item[NG]) + item_amount($item[ND]) + item_amount($item[Wand of Nagamar]);

    if (totalNs < 2)
    {  
		  int numNneeded = 0;
		  if (needWandOfNagamar) { numNneeded = 1; }
      
		  //The telescope check is applied manually for this one item, as it is required 
		  //for the wand AND the NG, which is a tower item. 
		  if (telescopeupgrade >= 6)
		  {
			//We can see all of the tower items. 
			foreach num in upgrade
			{
			  if (upgrade[num] == "see what appears to be the North Pole")
			  {
				numNneeded = numNneeded + 1;
				northPoleMaybe = false;
			  }
			}
			//So, if we've gone through all 5 of towers 1-5 and NOT seen the Giant Desktop Globe, we know we DON'T need the 
			//NG, and hence the extra N. 
			if (!northPoleDef)
			{
			  northPoleMaybe = false;
			}
		  } else if (telescopeupgrade >= 2) {
			//We can see some of the tower items.
			foreach num in upgrade
			{
			  if (upgrade[num] == "see what appears to be the North Pole")
			  {
				numNneeded = numNneeded + 1;
				northPoleMaybe = false;
			  }
			}
			//Here, note that we don't set northPoleMaybe to be false if northPoleDef is false too.
		  }
      
		  if (numNneeded > 0) {
			if (northPoleMaybe) {
				bufferoutput("You (might) need a total of " + (numNneeded + 1) +" lowercase N's. You have " + totalNs + " at the moment.");

			}
			else {
				bufferoutput("You DEFINITELY need a total of " + numNneeded + " lowercase N's. You have " + totalNs + " at the moment.");
			}
		}

	}
	

    bufferoutput(hasItem("fancy bath salts", 1));  
    bufferoutput(9);  
  }
  
  if(my_level >= 10)
  {
    if (urlContains("questlog.php?which=3", "You have planted a Beanstalk"))
    {
      debug("The beanstalk is planted");
      if (item_amount($item[steam-powered model rocketship]) == 1)
      {
		if(!urlContains("questlog.php?which=2", "The Rain on the Plains is Mainly Garbage"))
			bufferoutput("You need to finish the Castle Quest.");

        debug("You've unlocked the Hole in the Sky");
        bufferoutput(hasItem("Richard's Star Key", 1));
        bufferoutput(hasItem("star hat", 1));
        if (item_amount($item[star crossbow]) + item_amount($item[star sword]) + item_amount($item[star staff]) == 0)
			if (my_path() != "Avatar of Boris")
				bufferoutput("You need 1 of either the Star Crossbow, Sword or Staff");
      } else if (item_amount($item[S.O.C.K.]) == 1) {
		if(urlContains("questlog.php?which=2", "The Rain on the Plains is Mainly Garbage"))
			bufferoutput("You need to finish the Castle Quest.");

          bufferoutput("You need to unlock the Hole in the Sky.");
      } else {
        bufferoutput("You need to unlock the castle.");
      }
    } else {
      if (item_amount($item["enchanted bean"]) > 0)
      {
        bufferoutput("You have the Enchanted Bean, let's use it...");
        use(1, $item[enchanted bean]);        
      }
    }
    
    bufferoutput(hasItem("super-spiky hair gel", 1));
    bufferoutput(hasItem("photoprotoneutron torpedo", 1));
    bufferoutput(hasItem("thin black candle", 1));
    bufferoutput(hasItem("Mick's IcyVapoHotness Rub", 1));
	int totalGs = item_amount($item[NG]) + item_amount($item[original G]);
    if (northPoleDef)
	{
		//Then we definitely need an NG. 
		if (totalGs < 1) { bufferoutput("You DEFINITELY need an original G."); }
	} else if (northPoleMaybe) {
		if (totalGs < 1) { bufferoutput("You (might) need an original G."); }
	}
    if (needWandOfNagamar && !hasWandOfNagamar && !hasWA)
    {
      //The WA is not a Tower item, so we only need one metallic A in total. 
      bufferoutput(hasItem("metallic A", 1));
    }
    bufferoutput(hasItem("chaos butterfly", 1));
    bufferoutput(hasItem("plot hole", 1));
    bufferoutput(10);
  }
  
  if(my_level >= 11)
  {
    //Have we finished the Level 11 Quest?
    if (urlContains("questlog.php?which=2", "You've handed the Holy MacGuffin over to the Council"))
    {
      debug("You've completed the Level 11 Quest");
    } else {
      if (item_amount($item[Holy MacGuffin]) == 1)
      {
        //Nobody will ever see this because of the initial hit to council.php. But left here just in case. It's harming no-one. 
        bufferoutput("You've got the Holy MacGuffin - go give it to the Council!");
      } else {
        //Is the Pyramid Opened?
        if (item_amount($item["Staff of Ed"]) == 1)
        {
          //Just make sure that the pyramid has been opened, otherwise we get a blank page error 3 lines below.
          urlContains("beach.php?action=hiddencity", "");
          //Then yes, it's opened. 
          if (urlContains("pyramid.php", "pyramid4_1b.gif"))
          {
            bufferoutput("You need to go beat the crap out of Ed the Undying.");
          } else {
            bufferoutput("You need to go Unlock the Lower Chamber to go beat Ed.");
          }
        } else {
          //Have we even got the diary?
          if (item_amount($item[your father's MacGuffin diary]) == 0)
          {
            bufferoutput("You need to go get your Father's Diary");
          } else {
            //Oasis & Desert
            if (urlContains("beach.php?action=hiddencity", "smallpyramid.gif"))
            {
              debug("You've done the Oasis/Desert Quest to unlock the Pyramid.");
            } else {
              if (item_amount($item[worm-riding hooks]) >= 1) 
              {
                if (item_amount($item[drum machine]) > 0)
                {
                  bufferoutput("You have the worm-riding hooks and drum machine, so let's use them...");
                  item oldweapon  = equipped_item($slot[weapon]);
                  item oldoffhand = equipped_item($slot[off-hand]);
                  
                  equip($item[worm-riding hooks]);
                  use(1, $item[drum machine]);
                  
                  equip($slot[weapon], oldweapon);
                  equip($slot[off-hand], oldoffhand);
                } else {
                  bufferoutput("You have the worm-riding hooks, but no drum machine. Get one.");
                }
              } else if (urlContains("questlog.php?which=1", "stumble upon a hidden oasis out in the desert")) {
                bufferoutput("You've unlocked the Oasis. You need to meet Gnasir for the first time.");
              } else if (urlContains("questlog.php?which=1", "The fremegn leader Gnasir has tasked you with finding a stone rose")) {  
                if (item_amount($item[stone rose]) > 0)
                {
                  bufferoutput("You have the stone rose. Give it to Gnasir.");
                } else {
                  bufferoutput("You need to give the Stone Rose to Gnasir (and find it first)");
                  bufferoutput(hasItem("stone rose", 1));
                }
                bufferoutput(hasItem("can of black paint", 1));
                bufferoutput(hasItem("drum machine", 1));
              } else if (urlContains("questlog.php?which=1", "Gnasir seemed satisfied with the tasks you performed for his tribe, and has asked you to come back later.")) {
                bufferoutput("You gave the stone rose to Gnasir. Keep adventuring in the Ultrahydrated Desert until you find him again.");
                bufferoutput(hasItem("drum machine", 1));
              } else if (urlContains("questlog.php?which=1", "For your worm-riding training, you need to find a 'thumper'")) {
                if (item_amount($item[drum machine]) > 0)
                {
                  bufferoutput("You have a drum machine, you need to adventure in the Ultrahydrated Desert to give it to Gnasir");
                } else {
                  bufferoutput("You need to get a drum machine from the Oasis, then give it to Gnasir.");
                }
              } else if (urlContains("questlog.php?which=1", "You need to find fifteen missing pages from Gnasir's worm-riding manual. Have fun!")) {
                bufferoutput("You need to find the fifteen pages from the worm-riding manual. You haven't found any.");
              } else if (urlContains("questlog.php?which=1", "One worm-riding manual page down, fourteen to go.")) {
                bufferoutput("You need to find the fifteen pages from the worm-riding manual. You've found page one.");
              } else if (urlContains("questlog.php?which=1", "Two worm-riding manual pages down, thirteen to go. Sigh.")) {
                bufferoutput("You need to find the fifteen pages from the worm-riding manual. You've found two pages.");
              } else if (item_amount($item[worm-riding manual pages 3-15]) >= 1) {
                bufferoutput("You need to give the worm-riding manual back to Gnasir in the Desert.");
              } else {
                bufferoutput("The Oasis/Desert part is not done, but this script can't work out where you are.");
              }
            }
            //Palindrome
            if (item_amount($item[Staff of Fats]) + item_amount($item[Staff of Ed, almost]) + item_amount($item[Staff of Ed]) >= 1)
            {
              debug("You've completed the Palindome Section");
            } else {
              if ((item_amount($item[Mega Gem]) >= 1) || have_equipped($item[Mega Gem]))
              {
                bufferoutput("You have the Mega Gem, now you just need to kill Dr. Awkward.");
              } else if (item_amount($item[I Love Me, Vol. I]) == 1) {
                //Note that the bird rib and lion oil are handled in the Lv4 section. 
                if (item_amount($item[wet stew]) + item_amount($item[wet stunt nut stew]) == 0)
                {
                  bufferoutput(hasItem("stunt nuts", 1));
                }
                bufferoutput("You need to get the Mega Gem from the Laboratory.");
              } else if ((item_amount($item[Talisman o' Nam]) > 0) || (have_equipped($item[Talisman o' Nam]))) {
                bufferoutput("You have to put all the stuff on the shelves.");
                bufferoutput(hasItem("hard rock candy", 1));
                bufferoutput(hasItem("photograph of God", 1));
                bufferoutput(hasItem("hard-boiled ostrich egg", 1));
                bufferoutput(hasItem("ketchup hound", 1));
              } else {
                bufferoutput("Go unlock Belowdecks and get the Talisman o' Nam");
              }
            }
            //Ruins
            if (item_amount($item[ancient amulet]) + item_amount($item[Staff of Ed, almost]) + item_amount($item[headpiece of the Staff of Ed]) + item_amount($item[Staff of Ed]) >= 1)
            {
              debug("You've completed the Hidden Ruins section.");
            } else if(urlContains("plains.php", "hiddencity.gif")) {
              bufferoutput("You need to unlock the Hidden Temple");
            } else {
              if (item_amount($item["triangular stone"]) < 4)
              {
                bufferoutput("You need to go fight the Ancient Protector Spirit.");
              }
            }
            //Spookyraven Wine Celler
            //Remember, we have already checked that the Manor and Second Floor are unlocked.
            if (item_amount($item[Eye of Ed]) + item_amount($item[headpiece of the Staff of Ed]) + item_amount($item[Staff of Ed]) >= 1)
            {
              debug("You've done the Spookyraven section.");
            } else if (urlContains("manor.php", "sm8b.gif")) {
              bufferoutput("You've unlocked the second floor. Go collect the wine and defeat Lord Spookyraven.");
            } else {
              bufferoutput("Go unlock the basement of Spookyraven Manor.");
            }
          }
        }
      }
    }
    
    bufferoutput(hasItem("pygmy pygment", 1));
    bufferoutput(hasItem("pygmy blowgun", 1));
    bufferoutput(hasItem("powdered organs", 1));
    bufferoutput(hasItem("adder bladder", 1));
    bufferoutput(hasItem("Black No. 2", 1));
    bufferoutput(hasItem("bronzed locust", 1));
    bufferoutput(hasItem("black pepper", 1));
    bufferoutput(11);
  }
  
  if(my_level >= 12)
  {
    if (urlContains("questlog.php?which=2", "Make War, Not... Oh, Wait"))
    {
      debug("You've done the Level 12 Quest.");
    } else {
      bufferoutput("You haven't done the Level 12 Quest.");
    }
    bufferoutput(hasItem("gremlin juice", 1));
    bufferoutput(12);
  }
  
  if (my_level >= 10)
  {
    //I want this here to be the last thing that's printed. 
    if (needWandOfNagamar && item_amount($item[wand of nagamar]) == 0)
    {
      print("You do not have the Wand of Nagamar!", "red");
    }
  }
  
  bcfooter();
}

void bumcheekcitys_networth() {
	boolean use_display = true;

	boolean have_store() {	
		return !(contains_text(visit_url("managestore.php"), "Buy a Store:"));
	}

	//Thanks to Veracity!
	buffer pnum_helper(buffer b, int n, int level) {
		if ( n >= 10 ) pnum_helper( b, n / 10, level + 1 );
		b.append( to_string( n % 10 ) );
		if ( level > 0 && level % 3 == 0 ) b.append( "," );
		return b;
	}

	buffer pnum( buffer b, int n ) {
	  if ( n < 0 ) {
		b.append( "-" );
		n = -n;
	  }
	  return pnum_helper( b, n, 0 );
	}

	string pnum(int n) {
	  buffer b;
	  return pnum( b, n ).to_string();
	}

	//Thanks for the helper function, Spiny!
	int my_storage_meat() {
	  string storage = visit_url("storage.php?which=5");
	  string storagemeat = substring(storage, index_of(storage,"have "), index_of(storage," meat"));
	  return to_int(storagemeat);
	}

	record entry {
	  item it;
	  int price;
	  int amount;
	};

	int total = 0;
	if (count($items[]) > 100000) abort("Error - open the script and increase all instances of the number 100000 to something bigger than "+count($items[]));
	entry [100000] all;
	int itcount = 0;

	//update prices
	cli_execute("update prices http://zachbardon.com/mafiatools/updateprices.php?action=getmap");
	cli_execute("update prices http://nixietube.info/mallprices.txt");

	boolean store = have_store();

	//thanks to Bale for noticing that nontradeable autosellables were being ignored...
	foreach it in $items[] {
		int amount =  available_amount(it) + storage_amount(it);
		if (store) amount = amount + shop_amount(it);
		if (use_display)  amount = amount + display_amount(it);
		if (amount > 0) {
			int price = 0;
			if (is_tradeable(it)) {
				if (historical_age(it) > 7) {
					price = mall_price(it);
				} else {
					price = historical_price(it);
					price = max(0, price);
				}
				if (((price == 0)|| (price > 5000000)) && (is_tradeable(it))) price = mall_price(it);
				if ((price == 0) && (autosell_price(it) > 0)) price = autosell_price(it);
			}
			
			if (price > 500000000) {
				print("Not considering price for "+to_string(it)+", which you have "+amount+" of.", "blue");
				price = 0;
			}
			
			if (price > 0)
			{
				print("Considering "+it+"...");
				all[itcount].it = it;
				all[itcount].price = price;
				all[itcount].amount = amount;
			}
			itcount = itcount + 1;
			total = total + (price * amount);
		}
	}

	print("Sorting....");
	sort all by (value.price * value.amount);
	itcount = 0;
	writeln("<table><tr><th>Quantity:</th><th>Item:</th><th>Value (Individual)</th><th>Total ValueL</th></tr>");
	while (itcount < 100000) {
	  if (all[itcount].it != $item[none]) {
		writeln("<tr><td style='text-align:right'>"+pnum(all[itcount].amount)+"</td><td>"+all[itcount].it+"</td><td style='text-align:right'>"+pnum(all[itcount].price)+"</td><td style='text-align:right'>"+pnum(all[itcount].price * all[itcount].amount)+"</td></tr>");
	  }
	  itcount = itcount + 1;
	}

	writeln("<tr><td colspan='2'>&nbsp;</td><td style='text-align:right'>Liquid Meat</td><td  style='text-align:right'>"+pnum(my_meat() + my_closet_meat() + my_storage_meat())+"</td></tr>");
	writeln("<tr><td colspan='2'>&nbsp;</td><td style='text-align:right'>Total</td><td  style='text-align:right'>"+pnum(total)+"</td></tr></table>");
}

void bumcheekcitys_settings_manager() {
	record rec { 
		string d; 
	};
	record setting {
		string name;
		string type;
		string description;
		string value;
		string c;
		string d;
		string e;
	};

	setting[int] s, t;
	string[string] fields;
	boolean success;
	string serv, tab;

	string head() {
		string r = "<html><head><title>bumSeMan Settings Manager 0.2</title>";
		r += "<style type='text/css'>";
		r += "* { font-family: Verdana; font-size:11px; }";
		r += "th { font-size:14px; font-weight: blue; background-color: red; }";
		r += "input, select, button, textarea {	margin-left: 5px; border: 1px solid gray; }";
		r += "input:focus, select:focus, textarea:focus {	border: 1px solid red; background: #F3F3F4; }";
		r += "</style>";
		r += "</head>";
		return r;
	}

	void input(string type, string name, string value, string description) {
		switch (type) {
			case "boolean" :
				write("<tr><td>"+name+"</td><td><select name='"+name+"'>");
				if (value == "true") {
					write("<option value='true' selected='selected'>true</option><option value='false'>false</option>");
				} else {
					write("<option value='true'>true</option><option value='false' selected='selected'>false</option>");
				}
				writeln("</td><td>"+description+"</td></tr>");
			break;
			
			default :
				writeln("<tr><td>"+name+"</td><td><input type='text' name='"+name+"' value='"+value+"' /></td><td>"+description+"</td></tr>");
			break;
		}
	}
	void input(string type, string name, string value) { input(type, name, value, "default description"); }

	boolean load_current_map_bum(string fname, setting[int] map, string server) {
		print("loading map "+fname+" on server "+server, "purple");
		string curr, domain;

		switch (server) {
			case "bumcheekcity" :
				domain = "http://kolmafia.co.uk/";
				curr = visit_url("http://kolmafia.co.uk/" + fname + ".txt");
			break;
			
			case "zarqon" :
				domain = "";
				curr = "vars_"+replace_string(my_name()," ","_");
			break;
			
			default :
				abort(fname+"-"+server);
			break;
		}
		file_to_map(fname+".txt", map);
		
		//If the map is empty or the file doesn't need updating
		if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) {
			print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
			
			if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) return false;
			
			map_to_file(map, fname+".txt");
			set_property(fname+".txt", curr);
			print("..."+fname+".txt updated.");
		}
		
		return true;
	}

	void showForm(setting [int] s) {
		foreach x in s {
			input(s[x].type, s[x].name, get_property(s[x].name), s[x].description);
		}
	}
	void showForm(string str, string server) {
		rec [string, string] m;
		
		switch (str) {
			case "prefRefChoiceAdv" :
				file_to_map("defaults.txt",m); 
				foreach t,p,d in m {
					if (contains_text(p, "choiceAdventure")) {
						input("text", p, get_property(p), t+" - default '"+d.d+"'");
					}
				}
			break;
			
			case "prefRefGlobal" :
				file_to_map("defaults.txt",m); 
				foreach t,p,d in m {
					if (t == "global") {
						input("text", p, get_property(p), t+" - default '"+d.d+"'");
					}
				}
			break;
			
			case "prefRefOther" :
				file_to_map("defaults.txt",m); 
				foreach t,p,d in m {
					if (!contains_text(p, "choiceAdventure") && t != "global") {
						input("text", p, get_property(p), t+" - default '"+d.d+"'");
					}
				}
			break;
			
			case "zLib" :
				file_to_map("vars_"+replace_string(my_name()," ","_")+".txt",m); 
				writeln("<input type='hidden' name='zlib' value='1' />");
				foreach t,p,d in m {
					input("text", t, p, t);
				}
			break;
			
			default:
				load_current_map_bum(str, s, server);
				showForm(s);
			break;
		}
	}
	void showForm(string s) { showForm(s, ""); }

	string tabList() {
		string ret;

		load_current_map_bum("bumseman_scripts", t, "bumcheekcity");
		foreach x in t {
			ret += "<li><a href='?tab="+t[x].name+"&server="+t[x].type+"'>"+t[x].description+"</a></li>";
		}
		return "<ul>"+ret+"</ul>";
	}

	void writeTab(string t, string v) {
		write("<li");
		//if(fields[t] == v) write(" class='see'");
		write("><input type='submit' class='nav' name='"+t+ "' value='"+v+"'>");
		writeln("</li>");
	}

	fields = form_fields();
	success = count(fields) > 0;
	string[string] vars;
	
	foreach x in fields {
		if (form_field("zlib") == 1) file_to_map("vars_"+replace_string(my_name()," ","_")+".txt",vars);
	
		print(x+") "+fields[x], "blue");
		if (x == "tab") {
			tab = fields[x];
		} else if (x == "server") {
			serv = fields[x];
		} else if (form_field("zlib") == 1) {
			vars[x] = fields[x];
		} else {
			set_property(x, fields[x]);
		}
		
		if (form_field("zlib") == 1) map_to_file(vars, "vars_"+replace_string(my_name()," ","_")+".txt");
	}
	
	writeln(head()+"<body><form action='' method='post'><h1>bumSeMan Settings Manager 0.2</h1>"+tabList()+"<table><tr><th>Name of Setting</th><th>Value</th><th>Description</th></tr>");
	
	if (tab != "") showForm(tab, serv);
	
	writeln("<tr><td colspan='3'><input type='submit' name='' value='Save Changes' /></td></tr></form>");
	writeln("</body></html>");
}

void bumcheekcitys_wiki_shortcut() {
	string classAbbrev(string s) {
		s = to_lower_case(s);
		
		if (contains_text(s, "turtle tamer")) return "tt";
		if (contains_text(s, "seal club")) return "sc";
		if (contains_text(s, "pasta")) return "pm";
		if (contains_text(s, "sauce")) return "s";
		if (contains_text(s, "disco bandit")) return "db";
		if (contains_text(s, "accordion")) return "at";
		
		return "";
	}
	void quickPrint(string s) {
		writeln(s+"<br />");
	}
	
	string quickMatch(string regex, string bigstring, string prefix, string suffix, int group) {
		print(regex, "blue");
		matcher m = create_matcher(regex, bigstring);
		if (m.find()) {
			quickPrint(prefix+m.group(group)+suffix);
			return prefix+m.group(group)+suffix;
		}
		return "";
	}
	string quickMatch(string regex, string bigstring, string prefix, string suffix) {
		return quickMatch(regex, bigstring, prefix, suffix, 1);
	}
	string quickMatch(string regex, string bigstring, int group) {
		return quickMatch(regex, bigstring, "", "", group);
	}
	string quickMatch(string regex, string bigstring) {
		return quickMatch(regex, bigstring, "", "", 1);
	}
	
	void bumWikiFamiliar(string id) {
		string html = visit_url("desc_familiar.php?which="+id);
		
		quickPrint("<h2>Main Familiar Page</h2>");
		quickPrint("{{familiar|");
		quickMatch("<center><b>(.*)</b><p>", html, "famid=", "|");
		quickMatch("<table><tr><td><font face=Arial,Helvetica>(.*)<br>(.*)<br>(.*)</font></td></tr></table>", html, "H1=", "|", 1);
		quickMatch("<table><tr><td><font face=Arial,Helvetica>(.*)<br>(.*)<br>(.*)</font></td></tr></table>", html, "H2=", "|", 2);
		quickMatch("<table><tr><td><font face=Arial,Helvetica>(.*)<br>(.*)<br>(.*)</font></td></tr></table>", html, "H3=", "|", 3);
		quickPrint("function=???|");
		quickPrint("hatchling=???|");
		quickPrint("equipment=???|");
		quickPrint("throne=???|");
		quickPrint("");
		quickPrint("At the end of Combat:");
		quickPrint("*Enthroned in the [[Crown of Thrones]]:");
		quickPrint("*With [[lucky Tam O'Shanter]] equipped:");
		quickPrint("*With [[miniature gravy-covered maypole]] equipped:");
		quickPrint("*With [[wax lips]] equipped:");
		quickPrint("*==References==");
		quickPrint("}");
		
		quickPrint("<h2>Information for the Familiar Item Page");
		quickPrint("<h2>Data: Familiar Page</h2>");
		quickPrint("<includeonly>{{{{{format}}}|");
		quickMatch("<center><b>(.*)</b><p>", html, "name=", "|");
		quickPrint("gender=???|");
		quickMatch("http://images\.kingdomofloathing\.com/itemimages/(.*)\.gif", html, "image=", ".gif|");
		quickPrint("{{{1|}}}}}</includeonly><noinclude>{{{{FULLPAGENAME}}|format=familiar/meta}}</noinclude>");
	}

	void bumWikiItem(string id, string descid) {
		string a;
		string effid;
		string html = visit_url("desc_item.php?whichitem="+descid);
		string outid;
		matcher m;
		
		quickPrint("{{item|");
		quickPrint("itemid="+id+"|");
		quickPrint("descid="+descid+"|");
		
		print(html);
		print("AAA", "red");
		print(substring(html, index_of(html, "<blockquote>")+12));
		a = substring(html, index_of(html, "<blockquote>")+12, index_of(html, "<br><br>"));
		quickPrint("description="+a+"|");
		
		quickmatch("Type\: <b>([0-9a-zA-Z ]+)</b>", html, "type=", "|");
		
		if (contains_text(html, "(Meat Pasting component)")) quickPrint("paste=1|");
		if (contains_text(html, "(Meat Smithing component)")) quickPrint("smith=1|");
		if (contains_text(html, "(Jewelrymaking component)")) quickPrint("jewelry=1|");
		
		if (contains_text(html, "(Fancy Cocktailcrafting component)")) {
			quickPrint("cocktail=fancy|");
		} else if (contains_text(html, "Cocktailcrafting component)")) {
			quickPrint("cocktail=1|");
		}
		
		if (contains_text(html, "(Fancy Cooking ingredient)")) {
			quickPrint("cook=fancy|");
		} else if (contains_text(html, "Cooking ingredient)")) {
			quickPrint("cook=1|");
		}
		
		if (contains_text(html, "(can also be used in combat)")) quickPrint("alsocombat=1|");
		
		quickmatch("Power\: <b>([0-9a-zA-Z ]+)</b>", html, "power=", "|");
		if (contains_text(html, "off-hand item (shield)")) quickPrint("powertype=Damage Reduction|");
		
		
		quickmatch("<br>([A-Za-z]+) Required: <b>([0-9]+)</b>", html, "stat=", "|");
		quickmatch("<br>([A-Za-z]+) Required: <b>([0-9]+)</b>", html, "statreq=", "|", 2);
		
		quickmatch("<br>Level required: <b>([0-9]+)</b>", html, "level=", "|");
		
		quickmatch("href=\"desc_effect\.php\?whicheffect=([0-9a-z]+)\" >([0-9A-Za-z ]+)</a></b><br>Duration: <b>([0-9]+)", html, "effect=", "|", 2);
		quickmatch("href=\"desc_effect\.php\?whicheffect=([0-9a-z]+)\" >([0-9A-Za-z ]+)</a></b><br>Duration: <b>([0-9]+)", html, "duration=", "|", 3);

		quickmatch("whichoutfit=([0-9]+)\",\"\",\"height=200,width=300\"\\)'>([0-9A-Za-z ]+)</span>", html, "outfit=", "|", 2);
		
		if (contains_text(html, "Cannot be traded or discarded")) {
			quickprint("notrade=1|");
			quickprint("autosell=0|");
		} else {
			if (contains_text(html, "Cannot be traded or discarded")) quickprint("notrade=1|");
			quickmatch("Selling Price: <b>([0-9,]+) Meat", html, "autosell=", "|");
		}
		
		if (contains_text(html, "<b>Gift Item</b>")) quickprint("gift=1|");
		if (contains_text(html, "<b>Quest Item</b>")) quickprint("quest=1|");
		
		quickmatch("Enchantment:<br><b><font color=blue>(.*)</font>", html, "enchantment=", "|");
		quickmatch("([0-9.]+)x chance of Critical Hit", html, "critical=", "|");
		quickmatch("-([0-9]+) MP to use Skills", html, "mpreduce=", "|");
		if (contains_text(html, "cannot be equipped while in Hardcore")) quickprint("nohardcore=1|");
		if (contains_text(html, "You may not equip more than one of these at a time")) quickprint("limit=1|");
		if (contains_text(html, "Free pull from Hagnk")) quickprint("hagnk=1|");
		if (contains_text(html, "This item grants a skill")) quickprint("grantskill=1|");
		if (contains_text(html, "this item will be installed in your")) quickprint("lounge=1|");
		
		m = create_matcher("Bonus for ([A-Za-z ]+) only", html);
		if (m.find()) {
			quickprint("enchclass="+classAbbrev(m.group(1)));
		}
		m = create_matcher("This item only works for ([A-Za-z ]+) Spells", html);
		if (m.find()) {
			quickprint("spelltype="+classAbbrev(m.group(1)));
		}
		m = create_matcher("Only ([A-Za-z ]+) may use this item", html);
		if (m.find()) {
			quickprint("class="+classAbbrev(m.group(1)));
		}
		quickprint("}}");
		
		/*
			haiku=1 for items whose name and description are shown as a haiku
			autocat=no to prevent this template from performing various automatic categorizations, such as for examples. This may not prevent other templates used within this one (such as {{Item/plural}}) from categorizing the page, however.
			bluenote=note for items with a bold, blue, left-justified note in their description, such as the Clan VIP Lounge key. This will not add any extra text to the value passed in.
		*/
	}
	
	bcheader();
	writeln("<h1>bumcheekcity's Wiki Shortcut</h1>");
	
	string [string] ff;
	ff = form_fields();
	if (count(ff) > 0) {
		writeln("<fieldset><legend>Posted Form Values for Debugging and Information</legend><table>");
		foreach s in ff {
			writeln("<tr><td>"+s+"</td><td>"+ff[s]+"</td></tr>");
		}
		writeln("</table></fieldset>");
	}

	writeln("<fieldset><legend>Generate Wiki Code</legend><form action='' method='post'><table>");
	writeln("<tr><td>Type:</td><td><select name='type'><option></option>");
	foreach s in $strings[adventure (not implemented yet), effect (not implemented yet), familiar, item, location (not implemented yet), outfit (not implemented yet), skill (not implemented yet)] {
		writeln("<option value='"+s+"'>"+s+"</option>");
	}
	writeln("</select></td></tr>");
	writeln("<tr><td>ID:</td><td><input type='text' name='id' /></td></tr>");
	writeln("<tr><td>DescID:</td><td><input type='text' name='descid' /></td></tr>");
	writeln("<tr><td colspan='2'><input type='submit' value='Generate Wiki Code' /></td></tr>");
	writeln("</table></form></fieldset>");
	
	if (form_field("type") != "") {
		writeln("<fieldset><legend>Generated Wiki Code</legend>");
	}
	
	switch (form_field("type")) {
		case "adventure" :
			
		break;
		
		case "effect" :
			
		break;
		
		case "familiar" :
			bumWikiFamiliar(form_field("id"));
		break;
		
		case "item" :
			bumWikiItem(form_field("id"), form_field("descid"));
		break;
		
		case "location" :
		
		break;
		
		case "outfit" :
		
		break;
		
		case "skill" :
		
		break;
		
		default :
		break;
	}
	
	if (form_field("type") != "") {
		writeln("</fieldset>");
	}
	
	bcfooter();
}

void chit() {
	buffer page = visit_url();
	//page = modifyPage(page);
	page.write();
}

void icecoldfever_popups()
{
	buffer results;
	
	results.append(visit_url());
	int start = index_of(results, "<b>");
	int end = index_of(results, "</b>");
	string name_of_item = substring(results, start+3,end);
	
	name_of_item = replace_string(name_of_item, " ", "_");
	
	insert(results, start, "<a target=_blank href=http://kol.coldfront.net/thekolwiki/index.php/"+name_of_item+">");
	int new_end = index_of(results, "</b>");
	insert(results, new_end + 4, "</a>");
	
	results.write();

}

void icecoldfever_topmenu()
{
	buffer results;
	results.append(visit_url());

	string inventory_link = "href=\"inventory.php?which=1\">inv</a><a target=mainpane href=\"inventory.php?which=2\">ent</a><a target=mainpane href=\"inventory.php?which=3\">ory</a>";
	results.replace_string("href=\"inventory.php\">inventory</a>", inventory_link);
	
	string quests_link = "href=\"questlog.php?which=1\">que</a><a target=mainpane href=\"questlog.php?which=4\">sts</a>";
	results.replace_string("href=\"questlog.php\">quests</a>", quests_link);
	
	string town_link = ">town:</a> <a target=mainpane href=\"town_wrong.php\">{W</a> <a target=mainpane href=\"town_right.php\">R</a> <a target=mainpane href=\"dungeons.php\">dungeons}</a>";
	results.replace_string(">town</a>", town_link);
	
	string campground_link = ">camp</a>";
	results.replace_string(">campground</a>", campground_link);
	
	string mountains_link = ">mtns</a>";
	results.replace_string(">mountains</a>", mountains_link);

	string manor_link = ">plains</a> <a target=mainpane href=\"manor.php\">manor</a>";
	results.replace_string(">plains</a>", manor_link);
	
	string martini_guy_link = "<a target=mainpane href=\"showplayer.php?who=" +my_id()+ "\" ><img src=\"http://images.kingdomofloathing.com/otherimages/smallleftswordguy.gif\" width=33 height=40 border=0></a>";
	results.replace_string("<img src=\"http://images.kingdomofloathing.com/otherimages/smallleftswordguy.gif\" width=33 height=40>", martini_guy_link);

	if(my_level() > 9)
	{
		string beanstalk_link = ">plains</a> <a target=mainpane href=\"beanstalk.php\">stalk</a>";
		results.replace_string(">plains</a>", beanstalk_link);
	}
	if(my_level() > 12)
	{
		string sea_link = ">beach</a> <a target=mainpane href=\"thesea.php\">sea</a>";
		results.replace_string(">beach</a>", sea_link);
	}
	
	if(contains_text(results, ">volcano</a>"))
	{
		string new_line = ">volcano</a></br><!-- Line3 -->";
		results.replace_string(">volcano</a>", new_line);
	}
	else if(contains_text(results, ">island</a>"))
	{
		string new_line = ">island</a></br><!-- Line3 -->";
		results.replace_string(">island</a>", new_line);
	}
	else if(my_level() < 2)
	{
		string new_line = ">manor</a></br><!-- Line3 -->";
		results.replace_string(">manor</a>", new_line);
	}
	else
	{
		string new_line = ">woods</a></br><!-- Line3 -->";
		results.replace_string(">woods</a>", new_line);
	}
	
	string bum_links = ">donate</a> <a href='bumcheekcitys_hardcore_checklist.php' target='mainpane'>checklist</a> <a href='bumcheekcitys_wiki_shortcut.php' target='mainpane'>wiki gen</a>";
	results.replace_string(">donate</a>", bum_links);
	
	string line3_links = "<a target=mainpane href=\"town_market.php\">market</a> <a target=mainpane href=\"hermit.php\">hermit</a> <a target=mainpane href=\"bhh.php\">bhh</a> <a target=mainpane href=\"managecollection.php\">DC</a> <a target=mainpane href=\"store.php?whichstore=m\">general</a> <a target=mainpane href=\"galaktik.php\">dr.</a> <a target=mainpane href=\"store.php?whichstore=g\">lab</a> <a target=mainpane href=\"store.php?whichstore=h\">fruit</a> <a target=mainpane href=\"council.php\">council</a> <a target=mainpane href=\"guild.php\">guild</a> <a target=_blank href=\"http://kolmafia.us/forum.php\">mafia</a> <a target=_blank href=\"http://kol.coldfront.net/thekolwiki/index.php/Main_Page\">wiki</a>";
	results.replace_string("<!-- Line3 -->", line3_links);
	
	string moons_link_ronald = "><a href=\"http://noblesse-oblige.org/calendar/\" target=_blank>Ronald</a><";
	results.replace_string(">Ronald<", moons_link_ronald);
	
	string moons_link_grimace = "><a href=\"http://noblesse-oblige.org/calendar/\" target=_blank>Grimace</a><";
	results.replace_string(">Grimace<", moons_link_grimace);
	
	results.replace_string("All material Copyright &copy; 2010,<br><a target=\"_blank\" href=\"http://asymmetric.net\">Asymmetric Publications, LLC</a>", "");

	string MM_Menu = "<select onchange='if (this.selectedIndex>0) { top.mainpane.location=this.options[this.selectedIndex].value; this.options[0].selected=true;}'><option></option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=a'>A</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=b'>B</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=c'>C</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=d'>D</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=e'>E</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=f'>F</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=g'>G</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=h'>H</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=i'>I</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=j'>J</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=k'>K</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=l'>L</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=m'>M</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=n'>N</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=o'>O</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=p'>P</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=q'>Q</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=r'>R</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=s'>S</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=t'>T</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=u'>U</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=v'>V</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=w'>W</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=x'>X</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=y'>Y</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=z'>Z</option>";
    MM_Menu += "<option value='questlog.php?which=6&vl=-'>-</option>";
 	  	 
    results.replace_string("<select onchange", MM_menu + "</select> <select onchange");
	
	results.write();
	
}

void traveler() {
	string input = visit_url();

	string gen_from = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	string gen_to = "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm";
	
	string char_rot13(string c) {
		int at = index_of(gen_from, c);
		if (at == -1)
			return c;
		return substring(gen_to, at, at+ 1);
	}
	
	matcher m = create_matcher("and says \&quot\;([^\;]*)\&quot\;", input);
	if (find(m)) {
		string msg_i = group(m, 1);
		string msg_o = "";
		int i = 0;
		while(i < length(msg_i)) {
			msg_o = msg_o + char_rot13(substring(msg_i, i, i + 1));
			i = i + 1;
		}
		write(replace_string(input, "understand the following:", "understand he said: " + msg_o));
	} else {
		write(input);
	}
}

void main() {
	switch( get_path() ) {
		case "beach.php": bumcheek_beach(); break;
		case "bhh.php": bumcheek_bhh(); break;
		case "bumcheekcitys_bumrats.php": bumcheekcitys_bumrats(); break;
		case "bumcheekcitys_hardcore_checklist.php": bumcheekcitys_hardcore_checklist(); break;
		case "bumcheekcitys_networth.php": bumcheekcitys_networth(); break;
		case "bumcheekcitys_settings_manager.php": bumcheekcitys_settings_manager(); break;
		case "bumcheekcitys_wiki_shortcut.php": bumcheekcitys_wiki_shortcut(); break;
		//This is actually Bale's. But naming conventions are important. 
		case "campground.php": if(form_field("skilluse") != 1) bumcheek_campground(); break;
		//case "charpane.php" : bumcheek_charpane(); break;
		//case "clan_raidlogs.php" : bumcheek_clan_raidlogs(); break;
		//case "clan_viplounge.php" : bumcheek_clan_viplounge(); break;
		case "crypt.php": bumcheek_crypt(); break;
		case "desc_effect.php": icecoldfever_popups(); break;
		case "desc_familiar.php": icecoldfever_popups(); 	break;
		case "desc_item.php": icecoldfever_popups(); break;
		case "desc_skill.php": icecoldfever_popups(); break;
		case "dungeon.php": bumcheek_dungeon(); break;
		case "dungeons.php": bumcheek_dungeons(); break;
		//case "fight.php": bumcheek_fight(); break;
		case "forestvillage.php": bumcheek_forestvillage(); break;	
		case "guild.php": bumcheek_guild(); break;
		case "inventory.php": if(form_field("skilluse") != 1 && form_field("ajax") != 1) bumcheek_inventory(); break;	
		case "closet.php": if(form_field("skilluse") != 1 && form_field("ajax") != 1) bumcheek_inventory(); break;
		case "storage.php": if(form_field("skilluse") != 1 && form_field("ajax") != 1) bumcheek_inventory(); break;		
		//case "lchat.php": bumcheek_lchat(); break;
		case "main.php": bumcheek_main(); break;
		case "ocean.php": bumcheek_ocean(); break;
		case "pandamonium.php": bumcheek_pandamonium(); break;
		case "pyramid.php": bumcheek_pyramid(); break;
		case "questlog.php": bumcheek_questlog(); break;
		case "shore.php": bumcheek_shore(); break;		
		case "starchart.php" : bumcheek_starchart(); break;
		case "topmenu.php":
			if(get_property("bumrats_useICFTopMenu") == "true")
			{
				icecoldfever_topmenu();
			} else {
				bumcheek_topmenu();
			} break;
		case "town_altar.php": bumcheek_town_altar(); break;
		//case "town_right.php": bumcheek_town_right(); break;
		case "town_wrong.php": bumcheek_town_wrong(); break;
		case "trapper.php": bumcheek_trapper(); break;
		case "traveler.php": traveler(); break;
		
		//my own added scripts
		case "familiar.php": familiar_relay(); break;
		case "craft.php": craft_relay(); break;
		case "clan_raidlogs.php": clan_raidlogs_relay(); break;
		case "charpane.php" : charpane_relay(); break;
		case "fight.php": fight_relay(); break;
		case "adventure.php" : adventure_relay(); break;
		case "BatMan_RE.ash" : batman_enhance(); break;
		case "game.php" : game_relay(); break;
	}
}
