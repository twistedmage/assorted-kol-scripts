// UI for Universal_recovery.ash by Bale
// http://kolmafia.us/showthread.php?t=1780
string thisver = "1.3";

// Beginning of copy-paste from jasonharper's htmlform.ash from http://kolmafia.us/showthread.php?3842

////////// GLOBAL VARIABLES - PUBLIC

string[string] fields;	// shared result from form_fields()
boolean success;	// form successfully submitted

////////// GLOBAL VARIABLES - PRIVATE

string _select;	// current value for <select> tag

void write_page() {
	fields = form_fields();
	success = count(fields) > 0;
	writeln("<html><head>");
	write("</head><body><form name=\"relayform\" method=\"POST\" action=\"\">");
}

void finish_page() {
	writeln("</form></body></html>");
}

void write_box(string label) {
	writeln("<fieldset>");
	if(label != "")
		write("<legend>"+ label +"</legend>");
}

void finish_box() {
	writeln("</fieldset>");
}

string write_radio(string ov, string name, string label, string value) {
	if(fields contains name)
		ov = fields[name];
	if(label != "")
		write("<label>");
	write("<input type=\"radio\" name=\"" + name + "\" value=\"" + entity_encode(value) + "\"");
	if(value == ov)
		write(" checked");
	write(">");
	if(label != "" )
		write(label+ "</label>");
	return ov;
}

string write_hidden(string ov, string name) {
	if(fields contains name)
		ov = fields[name];
	write("<input type=\"hidden\" name=\""+ name +"\" value=\""+ entity_encode(ov)+ "\">");
	return ov;
}

string write_select(string ov, string name, string label) {
	write("<label>"+ label);
	if(fields contains name)
		ov = fields[name];
	write("<select name=\""+ name);
	if(label == "")
		write("\" id=\""+ name);
	write("\">");
	_select = ov;
	return ov;
}

void finish_select() {
	writeln("</select></label>");
}

void write_option(string label, string value) {
	write("<option value=\""+ entity_encode(value)+ "\"");
	if(value == _select)
		write(" selected");
	write(">" + label);
	writeln("</option>");
}

boolean test_button(string name) {
	if(name == "") return false;
	return success && fields contains name;
}

boolean write_button(string name, string label) {
	write("<input type=\"submit\" name=\""+ name+ "\" value=\""+ label+ "\">");
	return test_button(name);
}

// end of jasonharper's htmlform.ash

// Rewrote jasons's write_check so that I could reverse the order of checkbox and label
boolean write_check(boolean ov, string name, string label, boolean after) {
	if(label != "" ) {
		write("<label>");
		if(!after) write(label);
	}
	if(fields contains name) {
		ov = true;
	} else if (count(fields) > 0)
		ov = false;
	write("<input type=\"checkbox\" name=\"" + name + "\"");
	if(ov)
		write(" checked");
	write(">");
	if(label != "" ) {
		if(after) write(" "+label);
		writeln("</label>");
	}
	return ov;
}

// this mimic's jason's old write_check
boolean write_check(boolean ov, string name, string label) {
	return write_check(ov, name, label, false);
}

void numeric_dropdown(string pref, string fail, string message) {
	set_property(pref, write_select(get_property(pref), pref, ""));
	if(fail != "") {
		write_option(fail, "-0.05");
		write_option(message+ "0%", "0.0");
	}
	foreach i in $ints[5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95]
		write_option(message+ i +"%", to_string(i / 100.0));
	if(fail == "")
		write_option(message+ "100%", "1.0");
	finish_select();
}

void zombie_dropdown(string pref, string fail, string message) {
	set_property(pref, write_select(get_property(pref), pref, ""));
	if(fail != "") {
		write_option(fail, "-0.05");
		write_option(message+ "0", "0.0");
	}
	foreach i in $ints[1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 18, 22, 26, 30, 34, 38, 42, 46, 50]
		write_option(message+ i, i);
	if(fail == "")
		write_option(message+ "55", "55");
	finish_select();
}

void levels() {
	boolean zombie = my_path() == "Zombie Slayer";
//	writeln("<tr><th width=\"50%\" align=left>Stop automation</th><th align=left>Mana burning:</th></tr>");
	writeln("<tr><th width=\"50%\" align=left>Restore your Health:</th><th align=left>"+(zombie? "Restore your Zombie Horde": "Restore your Mana")+":</th></tr>");
	write("<tr><td>");
	numeric_dropdown("hpAutoRecovery", "Do not auto-recover health", "Auto-recover health at ");
	write("</td><td>");
	if(zombie)
		zombie_dropdown("baleUr_ZombieAuto", "Do not auto-recover Horde", "Auto-recover Horde at ");
	else
		numeric_dropdown("mpAutoRecovery", "Do not auto-recover mana", "Auto-recover mana at ");
	writeln("</td></tr>");
	write("<tr><td>");
	numeric_dropdown("hpAutoRecoveryTarget", "", "Try to recover health up to ");
	write("</td><td>");
	if(zombie)
		zombie_dropdown("baleUr_ZombieTarget", "", "Try to recover Horde up to ");
	else
		numeric_dropdown("mpAutoRecoveryTarget", "", "Try to recover mana up to ");
	writeln("</td></tr>");
	write("<tr><td align=center>");
	if(write_button("hp", "Update & Restore HP"))
		restore_hp(0);
	write("</td><td align=center>");
	if(write_button("mp", "Update & Restore "+(zombie? "Horde": "MP")))
		restore_mp(0);
	writeln("</td></tr>");
}

string set_item(string it, string itemlist, boolean useit) {
	it = it.to_lower_case();
	string remove_item(string list, string doodad){
		matcher findItem = create_matcher("(.*?);?"+doodad+";?(.*)", list);
		if(findItem.find()) {
			if(findItem.group(1).length() > 0 && findItem.group(2).length() > 0)
				list = findItem.group(1) + ";" + findItem.group(2);
			else if(findItem.group(1).length() > 0)
				list = findItem.group(1);
			else list = findItem.group(2);
		}
		return list;
	}
		
	if(useit) {
		if(itemlist.contains_text(it)) return itemlist;
		else return itemlist + ";"+ it;
	}
	if(itemlist.contains_text(it)) return remove_item(itemlist, it);
	return itemlist;
}

void items() {
	string hpAutoRecoveryItems = get_property("hpAutoRecoveryItems");
	string mpAutoRecoveryItems = get_property("mpAutoRecoveryItems");
	string [int] hpItems;
	string [int] mpItems;
	if(can_interact()) {
		foreach it in $strings[Sleep on your clan sofa,Rest at your campground,Free disco rest,Galaktik's Curative Nostrum,
		  Visit the Nuns,Medicinal Herb's medicinal herbs]
			hpItems[count(hpItems)] = it;
		foreach it in $strings[Sleep on your clan sofa,Rest at your campground,Free disco rest,Galaktik's Fizzy Invigorating Tonic,
		  Visit the Nuns,x,Platinum Yendorian Express Card,Oscus's neverending soda]
			mpItems[count(mpItems)] = it;
	} else {
		foreach it in $strings[Sleep on your clan sofa,Rest at your campground,Free disco rest,Galaktik's Curative Nostrum,
		  Doc Galaktik's Ailment Ointment,Visit the Nuns,Medicinal Herb's medicinal herbs,scroll of drastic healing,
		  scented massage oil,red pixel potion,really thick bandage,filthy poultice,gauze garter]
			hpItems[count(hpItems)] = it;
		foreach it in $strings[Sleep on your clan sofa,Rest at your campground,Free disco rest,Galaktik's Fizzy Invigorating Tonic,x,
		  Visit the Nuns,x,x,x,x,x,Platinum Yendorian Express Card,Oscus's neverending soda]
			mpItems[count(mpItems)] = it;
	}
	writeln("<tr><th width=\"50%\" align=left>Configurable HP restores:</th><th align=left>Configurable MP restores:</th></tr>");
	for j from 0 to max(count(hpItems), count(mpItems)) - 1 {
		write("<tr><td align=right>");
		if(hpItems[j] != "" && hpItems[j] != "x")
			hpAutoRecoveryItems = set_item(hpItems[j], hpAutoRecoveryItems, 
			  write_check(hpAutoRecoveryItems.contains_text(hpItems[j].to_lower_case()), "hp"+hpItems[j], hpItems[j]));
		write("</td><td align=right>");
		if(mpItems[j] != ""&& mpItems[j] != "x")
			mpAutoRecoveryItems = set_item(mpItems[j], mpAutoRecoveryItems, 
			  write_check(mpAutoRecoveryItems.contains_text(mpItems[j].to_lower_case()), "mp"+mpItems[j], mpItems[j]));
		writeln("</td></tr>");
	}
	set_property("hpAutoRecoveryItems", hpAutoRecoveryItems);
	set_property("mpAutoRecoveryItems", mpAutoRecoveryItems);
}

// Universal_recovery options!
void ur() {
	writeln("<tr><th align=center colspan=2>Universal Recovery Options</th></tr>");
	// Set preferences for Birdform recovery items
	write("<tr><td>Prefer to use Birdform items if you can use at least ");
	if(get_property("baleUr_BirdThreshold") == "")
		set_property("baleUr_BirdThreshold", "0.1");
	numeric_dropdown("baleUr_BirdThreshold", "", "");
	write(" of full value.");
	write("</td></tr>");
	if(available_amount($item[Clan VIP Lounge key]) > 0) {
		// Use April Shower for MP?
		write("<tr><td><b>Allow use of April Shower to restore MP?</b></td></tr>");
		string AprilShower = get_property("baleUr_AprilShower");
		write("<tr><td>&nbsp; &nbsp; ");
		set_property("baleUr_AprilShower", write_radio(AprilShower, "baleUr_AprilShower", "Never ", ""));
		write_radio(AprilShower, "baleUr_AprilShower", "Hardcore/Ronin Only ", "hardcore");
		write_radio(AprilShower, "baleUr_AprilShower", "Aftercore Only ", "aftercore");
		write_radio(AprilShower, "baleUr_AprilShower", "Anytime", "always");
		write("</td></tr>");
		// Set preference for using Hot Tub
		write("<tr><td>");
		set_property("baleUr_DontUseHotTub", write_check(get_property("baleUr_DontUseHotTub").to_boolean(),
		  "baleUr_DontUseHotTub", "Refuse to use Hot Tub", true));
		write("</td></tr>");
	}
	// Stay in hardcore mode
	write("<tr><td>");
	set_property("baleUr_UseInventoryInMallmode", write_check(get_property("baleUr_UseInventoryInMallmode").to_boolean(), 
	  "baleUr_UseInventoryInMallmode", "Prefer using inventory instead of mall, regardless of value", true));
	write("</td></tr>");
	// Set preference for using MMJ
	write("<tr><td>");
	set_property("baleUr_UseMmjStock", write_check(get_property("baleUr_UseMmjStock").to_boolean(),
	  "baleUr_UseMmjStock", "Use MMJ in stock, even if it cannot be purchased this ascension", true));
	write("</td></tr>");
	// Set compatibility with Ascend.ash to never abort automation
	write("<tr><td>");
	set_property("baleUr_AlwaysContinue", write_check(get_property("baleUr_AlwaysContinue").to_boolean(),
	  "baleUr_AlwaysContinue", "Never abort automation, even if restoration fails", true));
	write("</td></tr>");
	// Set preference for Disco Resting
	write("<tr><td><b>Use free disco rests for:</b> ");
	string disco_rest = get_property("baleUr_DiscoResting");
	set_property("baleUr_DiscoResting", write_radio(disco_rest, "baleUr_DiscoResting", "Full HP only ", "hp"));
	write_radio(disco_rest, "baleUr_DiscoResting", "Full MP only ", "mp");
	write_radio(disco_rest, "baleUr_DiscoResting", "Both", "");
	write("</td></tr>");
	// Set Verbosity level
	write("<tr><td><b>Verbosity Level:</b> ");
	string curr_verb = get_property("baleUr_Verbosity");
	if(curr_verb == "") curr_verb = "1";
	set_property("baleUr_Verbosity", write_radio(curr_verb, "baleUr_Verbosity", "Off ", "0"));
	write_radio(curr_verb, "baleUr_Verbosity", "Normal ", "1");
	write_radio(curr_verb, "baleUr_Verbosity", "Verbose ", "2");
	write_radio(curr_verb, "baleUr_Verbosity", "Super Verbose", "3");
	write("</td></tr>");
	// Set purchasing preferences
	write("<tr><td><b>Allow recovery to purchase restoratives?</b></td></tr>");
	string curr_purch = get_property("baleUr_Purchase");
	if(!is_integer(curr_purch)) curr_purch = "1";
	write("<tr><td>&nbsp; &nbsp; ");
	set_property("baleUr_Purchase", write_radio(curr_purch, "baleUr_Purchase", "Never ", "0"));
	write_radio(curr_purch, "baleUr_Purchase", "Use KolMafia Preference ", "1");
	write_radio(curr_purch, "baleUr_Purchase", "From NPCs Only ", "2");
	write_radio(curr_purch, "baleUr_Purchase", "Purchase Freely", "3");
	write("</td></tr>");
	write("<tr><td>&nbsp; &nbsp; ");
	set_property("baleUr_FistPurchase", write_check(get_property("baleUr_FistPurchase").to_boolean(), 
	  "baleUr_FistPurchase", "Allow purchasing during the \"Way of the Surprising Fist\" challenge", true));
	write("</td></tr>");
}

// My rendition of zarqon's version checker
// checks script version once daily, returns empty string, OR div with update message inside
string check_version() {
	string soft = "Universal Recovery Configuration";
	string prop = "_version_BalesUniversalRecoveryUI";
	int thread = 1780;
	string page;
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
	switch (get_property(prop)) {
	case thisver: return "";
	case "":
		print("Running "+soft+" version: "+thisver,"gray");
		print("Checking for updates (running "+soft+" ver. "+thisver+")...");
		page = visit_url("http://kolmafia.us/showthread.php?t="+thread);
		matcher find_ver = create_matcher("<b>"+soft+" (.+?)</b>",page);
		if (!find_ver.find()) {
			print("Unable to load current version info.", "red");
			set_property(prop,thisver);
			return "";
		}
		set_property(prop,find_ver.group(1));
		default:
		if (sameornewer(thisver,get_property(prop))) {
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
		return "<div class='versioninfo'>"+msg+"</div>";
	}
	return "";
}

void main() {
	write_page();
	write("<style type=\"text/css\">th {background-color:blue; color:white; font-family:Arial,Helvetica,sans-serif;}</style>");
	writeln("<style type=\"text/css\">a:link {color:#0000CD}");
	writeln("a:visited {color:#0000CD}");
	writeln("a:hover {color:red;}</style>");
	write(check_version());
	write_box("<a href='http://kolmafia.us/showthread.php?1780' target=\"_blank\">Universal Recovery</a>, by <a href='showplayer.php?who=754005'>Bale</a>.");
	// Update Button!
	if(fields contains "updcol")
		switch(fields["updcol"]) {
		case "blue":
			fields["updcol"] = "green";
			break;
		case "green":
			fields["updcol"] = "Darkorange";
			break;
		case "Darkorange":
			fields["updcol"] = "magenta";
			break;
		case "magenta":
			fields["updcol"] = "blue";
		}
	write("<table border=0 cellpadding=1 width=\"100%\"><tr><td align=right>");
/*
	write("<tr><td align=right>");
//	numeric_dropdown("autoAbortThreshold", "Stop automation if auto-recovery fails", "Stop if health at ");
	write("</td><td align=right>");
	numeric_dropdown("manaBurningThreshold", "Do not rebalance buffs", "Recast buffs until ");
	writeln("</td></tr>");
*/
	if(test_button("upd") || test_button("hp")|| test_button("mp"))
		write("<span style=\"color:"+write_hidden("blue", "updcol")+"\"> Updated! </span>");
	write_button("upd", "Update");
	write("</td></tr></table>");
	// Form
	writeln("<center><table border=1 cellpadding=2>");
	writeln("<tr><td><table border=0 cellpadding=1 width=\"100%\">");
	levels();
	writeln("</table></td></tr>");
	writeln("<tr><td><table border=0 rules=cols cellpadding=1 width=\"100%\">");
	items();
	writeln("</table></td></tr>");
	writeln("<tr><td><table border=0 cellpadding=1 width=\"100%\">");
	ur();
	writeln("</table></td></tr>");
	writeln("</table></center>");
	// Update Button 2
#	if(write_button("upd", "Update"))
#		write("<span style=\"color:"+write_hidden("blue", "updcol")+"\"> Updated!</span>");
	write_button("upd", "Update");
	if(test_button("upd") || test_button("hp")|| test_button("mp"))
		write("<span style=\"color:"+write_hidden("blue", "updcol")+"\"> Updated! </span>");
	finish_box();
	finish_page();
}
