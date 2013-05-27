/******************************************************************************
                              BatMan Relay

               more clicking, less profit.  no wait...
                       more worry, less information.  no wait...
                                the opposite of all of that.
*******************************************************************************

   Documentation and discussion of this script is here:
   http://kolmafia.us/showthread.php?t=10042

   Feel appreciative?  Send me a bat! (Or bat-related item)

******************************************************************************/
import <zlib.ash>

float turns_till_goals(boolean usespec) {
   float totalgoalitems;
   foreach i,s in get_goals() {
      matcher numthings = create_matcher("(\\d+) (.*)",s);
      if (!numthings.find() || !is_goal(numthings.group(2).to_item())) continue;
      totalgoalitems += numthings.group(1).to_int();
   }
   return totalgoalitems / max(has_goal(my_location(),usespec),0.0001);
}

void fight_top_level(buffer results)
{
	string[string] post = form_fields();
	if (count(post) > 0) {
	   if (post contains "cli") {                                   // execute CLI commands
		  if (post["cli"] == "") { write("Nothing successfully accomplished!"); exit; }
		  write(cli_execute(post["cli"]) ? (post["cli"] == "help" ? "A complete list of CLI commands has been printed in the CLI." :
			 "Command '"+post["cli"]+"' executed.") : "Error executing '"+post["cli"]+"'.");
		  exit;
	   }
	   if (post contains "dashi" && post["dashi"] == "annae") {     // build Adventure Again info box
		  buffer abox;
		  abox.append("Adventure again at "+my_location()+".");
		  switch (my_location()) {
	//         case $location[]: actbox.append(""); break;
			 case $location[A-Boo Peak]: if (item_amount($item[a-boo clue]) > 0) abox.append("<p><a href=# class='clilink' title='use a-boo clue'><img src='/images/itemimages/map.gif' class=hand border=0></a>"); break;
			 case $location[Battlefield (Frat Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("hippiesDefeated")))+"</b> hippies left."); break;
			 case $location[Battlefield (Hippy Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("fratboysDefeated")))+"</b> fratboys left."); break;
			 case $location[defiled nook]: if (item_amount($item[evil eye]) > 0) abox.append("<p><a href=# class='clilink' title='use * evil eye'><img src='/images/itemimages/zomboeye.gif' class=hand border=0></a>");
			 case $location[defiled cranny]:
			 case $location[defiled alcove]:
			 case $location[defiled niche]: abox.append("<p><b>"+get_property("cyrpt"+excise(my_location(),"d ","")+"Evilness")+"</b> evilness left here."); break;
			 case $location[barrrney barrr]: int insultsknown; for n from 1 to 8 if (get_property("lastPirateInsult"+n) == "true") insultsknown += 1;
				if (insultsknown < 8) abox.append("<p>You know <b>"+insultsknown+"</b> insults."); break;
			 case $location[dungeon of doom]: abox.append("<p>"); for i from 819 to 827 abox.append(to_item(i)+(item_amount(to_item(i)) > 0 ? " ("+item_amount(to_item(i))+")" : "")+": "+
				(($strings[blessing, detection, mental acuity, ettin strength, teleportitis] contains get_property("lastBangPotion"+i)) ? "<b>"+get_property("lastBangPotion"+i)+"</b>" : get_property("lastBangPotion"+i))+"<br>"); break;
			 case $location[haunted billiards]: if (item_amount($item[library key]) == 0 && have_item($item[pool cue]) > 0 &&
													item_amount($item[hand chalk]) > 0 && have_effect($effect[chalky hand]) == 0)
				abox.append("<p><a href=# class='clilink' title='use hand chalk'>use hand chalk</a>"); break;
			 case $location[Next to that Barrel with Something Burning in it]:
			 case $location[Near an Abandoned Refrigerator]:
			 case $location[Over Where the Old Tires Are]:
			 case $location[Out By that Rusted-Out Car]: if (get_property("currentJunkyardTool") == "") {
				   if (have_outfit("Frat Warrior")) abox.append("<p><a href=# class='clilink' title='checkpoint; outfit frat warrior; bigisland.php?action=junkman&pwd=; outfit checkpoint'>visit Yossarian as frat</a>");
				   if (have_outfit("War Hippy")) abox.append("<p><a href=# class='clilink' title='checkpoint; outfit war hippy; bigisland.php?action=junkman&pwd=; outfit checkpoint'>visit Yossarian as hippy</a>");
				} break;
		  }
		  if (have_skill($skill[banishing shout]) && get_property("banishingShoutMonsters") != "") {
			  abox.append("<p><b>Banished:</b>\n<ul>");
			  foreach i,s in split_string(get_property("banishingShoutMonsters"),"\\|") abox.append("<li>"+normalized(s,"monster")+"</li>");
			  abox.append("</ul>");
		  }
		  if (have_effect($effect[on the trail]) > 0 && get_property("olfactedMonster") == last_monster().to_string() && !contains_text(vars["ftf_olfact"],last_monster().to_string())) {
	//         always olfact this monster link
		  }
		  if (count(get_goals()) == 0) abox.append("<p>All goals met. <a href='#' class='clilink edit' title='conditions set'>add goals</a>");
		   else {
			  float gturns = turns_till_goals(false);
			  abox.append("<p><b>Goals remaining"+(gturns < 9999 ? " (satisfied in <b>~"+rnum(max(1.0,gturns))+"</b> turns)" : "")+":</b>"+
				 " <a href=# class='clilink' title='conditions clear'>clear</a>\n<ul>");
			  foreach i,g in get_goals() abox.append("<li>"+g+" <a href=# class='clilink' title=\"conditions remove "+g+"\">remove</a></li>");
			  abox.append("</ul>");
			  if (goal_exists("item")) foreach i in get_inventory() if (can_equip(i) && numeric_modifier(i,"Item Drop") > 0) {
				 if (numeric_modifier(i,"Item Drop") <= numeric_modifier(equipped_item(to_slot(i)),"Item Drop")) continue;
				 cli_execute("whatif equip "+i+"; quiet");
				 float newturns = turns_till_goals(true);
				 if (newturns < gturns) {
					abox.append("<br><a href=# class='clilink' title=\"equip "+i+"\">Save "+rnum(gturns-newturns)+" turns by equipping "+i+".</a>");
					if (i.to_slot() == $slot[acc1]) for j from 1 to 3 abox.append(" <a href=# class='clilink' title=\"equip acc"+j+" "+i+"\">"+j+"</a>");
				 }
			  }
		   }
		  abox.write();
		  exit;
	   }
	   if (post contains "setml") {
		  vars["unknown_ml"] = max(0,to_int(post["setml"]));
		  updatevars();
	   }
	}

	// 100% run enforcement
	if (to_familiar(vars["is_100_run"]) != $familiar[none] && my_familiar() != to_familiar(vars["is_100_run"]))
	   use_familiar(to_familiar(vars["is_100_run"]));
	   
	// load the KoL page
	if (post contains "runcombat" && post["runcombat"] == "heckyes") results.append(run_combat());
	 else results.append(visit_url());
}

void add_features(buffer results) {
  // add the CLI box
   results.replace_string("</body>", "<div id='clibox'><span style='float: right'><font size=1>[<a href=# class='cliclose'>close</a>]</font></span>"+
      "Enter a CLI command:<p><form id='cliform' action='fight.ash' method=post>"+
      "<input name=cli type=text size=60></form><p><a href='#' class='clilink'>help</a> <a href='#' class='clilink' "+
      "title='ashwiki CLI Reference'>more help</a></div><div id='clifeedback' class='clisuccess'></div><div id='mask' class='cliclose'></div>\n</body>");
  // add "loading" div
   results.replace_string("<center><table><a name=\"end\">", "<div id='bat-enhance'><img id='compimg' src='images/adventureimages/3machines.gif'><p>Bat-Computer calculating...</div><center><table><a name=\"end\">");
   if (!contains_text(results,"bat-enhance")) results.replace_string("</body>", "<div id='bat-enhance'></div>\n</body>");
  // add headers/scripts/stylesheet
   results.replace_string("</head>", "\n<script src=\"jquery1.7.1.min.js\"></script>\n"+
      "<script src=\"jquery.dataTables.min.js\"></script>\n<script src=\"batman.js\"></script>\n"+
      "<link rel='stylesheet' type='text/css' href='batman.css'>\n</head>");
  // delete KoL's older version of jQuery
   results.replace_string("<script language=Javascript src=\"/images/scripts/jquery-1.3.1.min.js\"></script>","");
  // add doctype to force IE out of quirks mode
   results.replace_string("<html><head>", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" "+
      "\"http://www.w3.org/TR/html4/loose.dtd\">\n<html><head>");
  // fix KoL's CSS
   results.replace_string("right: 1; top: 2;\" id=\"jumptobot","right: 1px; top: 2px;\" id=\"jumptobot");
  // enable enhanced Manuel 
   results.replace_string("<table><tr><td><img id='monpic","<table><tr id='nowfighting'><td><img id='monpic");
   results.replace_string("<td width=30></td><td>","<td width=30></td><td id='manuelcell'>");

   // change runaway to repeat
   results.replace_string("<form name=runaway action=fight.php method=post><input type=hidden name=action value=\"runaway\">",
      "<form name=runaway action=fight.php method=post><input type=hidden name=action value='macro'><input type=hidden name=macrotext value=\"runaway; repeat\">");
}
void fight_relay() {
buffer results;
fight_top_level(results);
  // enhance it
   add_features(results);
  // write it
   results.write();
}
void main() {
	fight_relay();
}
