

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}

	//This function defined for neatness.
	string writeLink(string name, string html) {
		return "<a target='mainpane' href='"+html+".php'>"+name+"</a>";
	}
	string writeLink(string name) { return writeLink(name, name); }
if (get_property("bumrats_changeTopmenu") != "false") {

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
}
