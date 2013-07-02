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

record einclove {
   int[item] yield;   // all items yielded, and their average amounts
   boolean andor;     // in case of multiple item types, whether you get all types (true) or only one type (false)
   string note;       // E (X turns), X Substat, other
};
einclove[location] cloves;

string clover_string(location wear) {
   if (!load_current_map("clover_adventures",cloves) || !(cloves contains wear)) return "";
   einclove e = cloves[wear];
   buffer res;
   res.append("<td align=center>");
   boolean popped;
   foreach i,n in e.yield {
      if (popped && !e.andor) res.append(" &or; ");
      res.append("<a href=# class='cliimglink' title='wiki "+entity_encode(i)+"'><img src='/images/itemimages/"+i.image+
         "' title=\""+(n > 1 ? rnum(n)+" "+to_plural(i) : to_string(i))+"\"></a>");
      popped = true;
   }
   res.append((res.length() > 0 && e.note.length() > 0 ? "<br>" : "")+e.note+"<br>");
   if (item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]) == 0) res.append("<img src='/images/itemimages/disclover.gif'> (0)");
    else if (item_amount($item[ten-leaf clover]) > 0) res.append("<a href=# class='cliimglink' title='use * ten-leaf clover'><img src='/images/itemimages/clover.gif' title='Disassemble all clovers'></a> ("+
       rnum(item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]))+")");
     else res.append("<a href=# class='cliimglink' title='use 1 disassembled clover'><img src='/images/itemimages/disclover.gif' title='Assemble a clover'></a> ("+
       rnum(item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]))+")");
   res.append("</td>");
   return res.to_string();
}

void fight_top_level(buffer results)
{
	string[string] post = form_fields();
	if (count(post) > 0) {
	   if (post contains "cli") {                              // execute CLI commands
		  if (post["cli"] == "") { write("Nothing successfully accomplished!"); exit; }
		  write(cli_execute(post["cli"]) ? (post["cli"] == "help" ? "A complete list of CLI commands has been printed in the CLI." :
			 "Command '"+post["cli"]+"' executed.") : "Error executing '"+post["cli"]+"'.");
		  exit;
	   }
	   if (post contains "dashi") switch (post["dashi"]) {     // build Adventure Again info box
		 case "annae":
		  buffer abox;
		  abox.append("Adventure again at "+my_location()+".");
		  switch (my_location()) {
	//         case $location[]: actbox.append(""); break;
			 case $location[8-bit realm]: if (item_amount($item[digital key]) == 0) {
				abox.append("<table><tr>"); 
				foreach i in $items[red pixel, green pixel, blue pixel, white pixel] 
				   abox.append("<td align=center><img src='/images/itemimages/"+i.image+"' title='"+i+"'><br>"+rnum(item_amount(i))+"</td>");
				if (creatable_amount($item[digital key]) > 0) abox.append("<td><a href=# class='cliimglink' title='create 1 digital key'><img src='/images/itemimages/pixelkey.gif'></a></td>");
				abox.append("</tr></table>");
			 } break;
			 case $location[A-Boo Peak]: if (item_amount($item[a-boo clue]) > 0) abox.append("<p><a href=# class='cliimglink' title='use a-boo clue'><img src='/images/itemimages/map.gif' class=hand></a>"); 
				abox.append("<p>Hauntedness remaining: <b>"+get_property("booPeakProgress")+"</b>"); break;
			 case $location[guano junction]: if (item_amount($item[sonar-in-a-biscuit]) > 0 && !($strings[step3, finished] contains get_property("questL04Bat"))) 
				abox.append("<p><a href=# class='cliimglink' title='use sonar-in-a-biscuit'><img src='/images/itemimages/biscuit.gif' class=hand></a>"); break;
			 case $location[Battlefield (Frat Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("hippiesDefeated")))+"</b> hippies left."); break;
			 case $location[Battlefield (Hippy Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("fratboysDefeated")))+"</b> fratboys left."); break;
			 case $location[twin peak]: // abox.append("<p>Stench resistance (+4 needed): "+rnum(numeric_modifier("Stench Resistance"))+"<br>Item and food drops :");
				if (item_amount($item[rusty hedge trimmers]) > 0) abox.append("<p><a href=# class='cliimglink' title='use rusty hedge trimmers'><img src='/images/itemimages/hedgeclippers.gif' class=hand></a>"); break;
			 case $location[oil peak]: abox.append("<p>Pressure remaining: <b>"+get_property("oilPeakProgress")+"</b> ("+ceil(to_float(get_property("oilPeakProgress"))/6.34)+" slicks)"); break;
			 case $location[defiled nook]: if (item_amount($item[evil eye]) > 0) abox.append("<p><a href=# class='cliimglink' title='use * evil eye'><img src='/images/itemimages/zomboeye.gif' class=hand></a>");
			 case $location[defiled cranny]:
			 case $location[defiled alcove]:
			 case $location[defiled niche]: abox.append("<p><b>"+get_property("cyrpt"+excise(my_location(),"d ","")+"Evilness")+"</b> evilness left here."); break;
			 case $location[hole in the sky]: abox.append("<p><table style='padding: 0'><tr><th><img src='/images/itemimages/starchart.gif' border=0><br>"+rnum(item_amount($item[star chart]))+
				"</th><th><img src='/images/itemimages/star.gif' border=0><br>"+rnum(item_amount($item[star]))+"</th><th><img src='/images/itemimages/line.gif' border=0><br>"+rnum(item_amount($item[line]))+"</th></tr>");
				foreach i in $items[richard star key, star hat, star sword, star crossbow] if (have_item(i) == 0) abox.append("<tr><td>"+
				  (creatable_amount(i) > 0 ? "<a href=# class='cliimglink' title=\"create 1 "+i+"\"><img src='/images/itemimages/"+i.image+"' class=hand></a>" : "<img src='/images/itemimages/"+i.image+"' title=\""+i+"\" border=0>")+
				  "</td><td align=center>"+get_ingredients(i)[$item[star]]+"</td><td align=center>"+get_ingredients(i)[$item[line]]+"</td></tr>");
				abox.append("</table>"); break;		 
			 case $location[smut orc logging camp]: int planktot; for i from 5782 to 5784 planktot += item_amount(to_item(i));
				abox.append("<p>You have <b>"+planktot+"</b> of <b>"+rnum(30 - to_int(get_property("chasmBridgeProgress")))+"</b> needed planks."); break;
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
		  float[monster] arq = appearance_rates(my_location(),true);
		  if (count(arq) > 0) {
			 abox.append("<p><table><tr>");
			 monster[int] sortm;
			 foreach m in arq sortm[count(sortm)] = m;
			 sort sortm by -arq[value];
			 foreach i,m in sortm {
				if (arq[m] <= 0) continue;
				abox.append("<td align=center><a href=# class='cliimglink' title='wiki "+(m == $monster[none] ? to_string(my_location()) : m)+
				   "'><img src='/images/adventureimages/"+(m == $monster[none] ? "3doors.gif" : m.image == "" ? "question.gif" : m.image)+
				   "' title='"+(m == $monster[none] ? "Noncombat" : entity_encode(m)+(has_goal(m) > 0 ? " (goals: "+rnum(has_goal(m))+")" : ""))+
				   "' height=50 width=50></a><br>"+rnum(arq[m],1)+"%</td>");
			 }
			 abox.append(clover_string(my_location()));
			 abox.append("</tr></table>");
		  }
		  if (have_skill($skill[banishing shout]) && get_property("banishingShoutMonsters") != "") {
			  abox.append("<p><b>Banished:</b>\n<ul>");
			  foreach i,s in split_string(get_property("banishingShoutMonsters"),"\\|") abox.append("<li>"+normalized(s,"monster")+"</li>");
			  abox.append("</ul>");
		  }
		  if (my_class() == $class[avatar of jarlsberg] && get_property("_jiggleCheesedMonsters") != "") {
			  abox.append("<p><b>Banished:</b>\n<ul>");
			  foreach i,s in split_string(get_property("_jiggleCheesedMonsters"),"\\|") abox.append("<li>"+normalized(s,"monster")+"</li>");
			  abox.append("</ul>");
		  }
		  if (have_effect($effect[on the trail]) > 0 && get_property("olfactedMonster") == last_monster().to_string() && !contains_text(vars["ftf_olfact"],last_monster().to_string())) {
			 abox.append("<p><a href=# class='clilink' title='zlib ftf_olfact = "+vars["ftf_olfact"]+", "+last_monster()+"'>Always olfact this monster</a>");
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
		   if (my_class() == $class[avatar of jarlsberg] && item_amount($item[cosmic calorie]) > 19) {
			  abox.append("<p><div style='float: left; text-align: center'><a href=# class='cliimglink' title='wiki cosmic calorie'><img src='/images/itemimages/cosmiccalorie.gif' title='Cosmic Calories'></a><br><b>"+
				 rnum(item_amount($item[cosmic calorie]))+"</b></div><table style='margin-top: 0px; margin-left: 10px'>");
			  abox.append("<tr><td><a href=# class='clilink' title='use celestial olive oil'>use 20</a></td><td style='font-size: 0.75em'>+1 Elemental Resistance</td></tr>");
			  if (item_amount($item[cosmic calorie]) >= 30) abox.append("<tr><td><a href=# class='clilink' title='use celestial carrot juice'>use 30</a></td><td style='font-size: 0.75em'>+30% Item Drop</td></tr>");
			  if (item_amount($item[cosmic calorie]) >= 50) abox.append("<tr><td><a href=# class='clilink' title='use celestial au jus'>use 50</a></td><td style='font-size: 0.75em'>+5% Combats</td></tr>");
			  if (item_amount($item[cosmic calorie]) >= 60) abox.append("<tr><td><a href=# class='clilink' title='use celestial squid ink'>use 60</a></td><td style='font-size: 0.75em'>-5% Combats</td></tr>");
			  abox.append("</table>");
		   }
		  abox.write();
		  exit;
		 case "wicky":
		  buffer wbox;
		  string wickypage = to_upper_case(substring(last_monster(),0,1))+to_lower_case(replace_string(substring(last_monster(),1)," ","_"));  // This Format => This_format
		  wickypage = visit_url("http://kol.coldfront.net/thekolwiki/index.php/"+wickypage);
		  vprint("Wiki page length: "+rnum(wickypage.length()),5);
		  if (wickypage.length() > 0) { 
			 wbox.append(excise(wickypage,"\</table\>\<div style","\</div\>\<div class=\"printfooter\"\>"));
			 wbox.insert(0,"<div style");
			 vprint("Trimmed (length: "+rnum(wbox.length())+").",5);
			 wbox.replace_string("a href=\"/thekolwiki","a target='_new' href=\"http://kol.coldfront.net/thekolwiki");
		  } else wbox.append("<div><p>The page could not be loaded.  Try this instead: <a href=# class='clilink'>wiki "+last_monster()+"</a></div>");
		  wbox.write();
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
  // add "loading" div
   results.replace_string("</body>", contains_text(results,"<center><table><a name=\"end\">") ? "<div id='battab'><ul><li><a href='#bat-enhance'>Actions</a>"+
      "</li><li><a href='#kolformbox' title='Note: non-macro actions are not tracked!'>KoL</a></li><li><a href='#blacklist' class='blacktrigger'>Blacklist</a></li>"+
	  "<li><a href='#wikibox' class='wickytrigger'>Wiki</a></li></ul>"+
	  "<div id='bat-enhance' class='panel'><a href='fight.php' border=0><img id='compimg' src='images/adventureimages/3machines.gif'></a><p>Bat-Computer "+
	  "calculating...</div><div id='kolformbox' class='panel'><center>KoL forms here</center></div><div id='blacklist' class='panel'><p>The "+
	  "blacklist goes here.</div><div id='wikibox' class='panel'><p><img src='images/itemimages/book5.gif'><p>Consulting the Bat-Monstercyclopedia...</div></div>\n</body>" : 
      "<div id='bat-enhance'></div>\n</body>");
  // add the CLI box
   results.replace_string("</body>", "<div id='clibox'><span style='float: right'><font size=1>[<a href=# class='cliclose'>close</a>]</font></span>"+
      "Enter a CLI command:<p><form id='cliform' action='fight.ash' method=post>"+
      "<input name=cli type=text size=60></form><p><a href='#' class='clilink'>help</a> <a href='#' class='clilink' "+
      "title='ashwiki CLI Reference'>more help</a></div><div id='clifeedback' class='clisuccess'></div><div id='mask' class='cliclose'></div>\n</body>");
  // add scripts/stylesheet
   results.replace_string("</head>", "\n<script src='jquery1.10.1.min.js'></script>\n"+
      "<script src='jquery.dataTables.min.js'></script>\n<script src='batman.js'></script>\n"+
      "<link rel='stylesheet' type='text/css' href='batman.css'>\n</head>");
  // delete KoL's older version of jQuery
   results.replace_string("<script language=Javascript src=\"/images/scripts/jquery-1.3.1.min.js\"></script>","");
  // add doctype to force IE out of quirks mode
   results.replace_string("<html>", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" "+
      "\"http://www.w3.org/TR/html4/loose.dtd\">\n<html>");
  // fix KoL's CSS
   results.replace_string("right: 1; top: 2;\" id=\"jumptobot","right: 1px; top: 2px;\" id=\"jumptobot");
  // move KoL combat forms 
   results.replace_string("<table><a name=\"end\">","<a name=\"end\"><table id='kolforms'>");
   matcher kolf = create_matcher("\\<table id='kolforms'\\>.+?\\</table\\>",results);
   if (kolf.find()) {
      string alltheforms = kolf.group(0);
      results.replace_string(alltheforms,"");
      results.replace_string("KoL forms here",alltheforms);
   }	  
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
