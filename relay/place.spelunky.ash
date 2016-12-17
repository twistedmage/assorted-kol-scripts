
//spelunkyStatus
//Turns: 21, Non-combat Due, Gold: 358, Bombs: 7, Ropes: 6, Keys: 2, Buddy: , Unlocks: Jungle, Ice Caves, Temple Ruins, Spider Hole, LOLmec's Lair, Sticky Bombs, City of Goooold
//Turns: 2, Gold: 1269, Bombs: 7, Ropes: 7, Keys: 1, Buddy: , Unlocks: Jungle, Ice Caves, Temple Ruins, Spider Hole, Sticky Bombs, Crashed UFO, City of Goooold, LOLmec's Lair, Burial Ground

boolean level1_unlocked = get_property("spelunkyStatus").contains_text("Spider Hole") || get_property("spelunkyStatus").contains_text("Snake Pit");
boolean level2_unlocked = get_property("spelunkyStatus").contains_text("Beehive") || get_property("spelunkyStatus").contains_text("Burial Ground");
boolean level3_unlocked = get_property("spelunkyStatus").contains_text("Altar") || get_property("spelunkyStatus").contains_text("Crashed UFO");
boolean level4_unlocked = get_property("spelunkyStatus").contains_text("City of Goooold");

buffer spcss;
spcss.append(" \n");
spcss.append("#ptab table, #ptab th, #ptab td { border:1px solid gray; padding:2px; border-collapse:collapse; margin:0; } ");
spcss.append("\n");
spcss.append("#ptab table { width:95%; } ");
spcss.append("\n");
spcss.append("#ptab th { text-align:center; font-size:12px; } ");
spcss.append("\n");
spcss.append("#ptab td { text-align:left; font-size:12px; } ");
spcss.append("\n");

buffer phasetab;
phasetab.append("<div id=ptab>");
phasetab.append("<table>");
phasetab.append("<tr><th>Location</th><th width=28% class=phase1>Phase 1</th><th width=28% class=phase2>Phase 2</th><th width=28% class=phase3>Phase 3</th></tr>");
phasetab.append("<tr>");
phasetab.append("<td><a href=http://kol.coldfront.net/thekolwiki/index.php/The_Mines target=_blank>The Mines</a></td>");
phasetab.append("<td class=phase1><a href=http://kol.coldfront.net/thekolwiki/index.php/An_Old_Clay_Pot target=_blank>An Old Clay Pot</a><li>15-20 Gold</li><li><a href=http://kol.coldfront.net/thekolwiki/index.php/Pot target=_blank>pot</a> (off-hand throwable)</li></td>");
phasetab.append("<td class=phase2><a href=http://kol.coldfront.net/thekolwiki/index.php/A_Shop target=_blank>A Shop</a></td>");
if(level1_unlocked)
	phasetab.append("<td class=phase3>&nbsp;</td>");
else
	phasetab.append("<td class=phase3><a href=http://kol.coldfront.net/thekolwiki/index.php/It%27s_a_Trap!_A_Dart_Trap. target=_blank>It\'s a Trap! A Dart Trap.</a><br> (Following options are exclusive)<li>Open <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Snake_Pit target=_blank title=The Snake Pit>The Snake Pit</a> (with bomb)</li><li>Open <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Spider_Hole target=_blank title=The Spider Hole>The Spider Hole</a> (with rope)</li></td>");
phasetab.append("</tr>");

phasetab.append("<tr>");
phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Jungle target=_blank title=The Jungle>The Jungle</a></td>");
phasetab.append("<td class=phase1> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Shop target=_blank title=A Shop>A Shop</a></td>");
phasetab.append("<td class=phase2> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Tombstone target=_blank title=A Tombstone>A Tombstone</a><li>20-25 Gold or Buddy</li><li><a href=http://kol.coldfront.net/thekolwiki/index.php/Shotgun target=_blank title=Shotgun>shotgun</a> (with <a href=http://kol.coldfront.net/thekolwiki/index.php/Heavy_pickaxe target=_blank title=Heavy pickaxe>heavy pickaxe</a>)</li><li><a href=http://kol.coldfront.net/thekolwiki/index.php/The_Clown_Crown target=_blank title=The Clown Crown>The Clown Crown</a> (with <a href=http://kol.coldfront.net/thekolwiki/index.php/X-ray_goggles target=_blank title=X-ray goggles>x-ray goggles</a>)</li></td>");
if(level2_unlocked)
	phasetab.append("<td class=phase3>&nbsp;</td>");
else
	phasetab.append("<td class=phase3> <a href=http://kol.coldfront.net/thekolwiki/index.php/It%27s_a_Trap!_A_Tiki_Trap. target=_blank title=It\'s a Trap! A Tiki Trap.>It\'s a Trap! A Tiki Trap.</a><br> (Following options are exclusive)<li>Open <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Beehive target=_blank title=The Beehive>The Beehive</a> (with bomb)</li><li>Open <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Ancient_Burial_Ground target=_blank title=The Ancient Burial Ground>The Ancient Burial Ground</a> (with rope)</li></td>");
phasetab.append("</tr>");

phasetab.append("<tr>");
phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Ice_Caves target=_blank title=The Ice Caves>The Ice Caves</a></td>");
phasetab.append("<td class=phase1> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Shop target=_blank title=A Shop>A Shop</a></td>");
phasetab.append("<td class=phase2> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Big_Block_of_Ice target=_blank title=A Big Block of Ice>A Big Block of Ice</a><li>50-60 Gold</li><li>Gain a <a href=http://kol.coldfront.net/thekolwiki/index.php/Template:Spelunkybuddies target=_blank title=Template:Spelunkybuddies>buddy</a> or 60-70 gold (with a <a href=http://kol.coldfront.net/thekolwiki/index.php/Torch target=_blank title=Template:Spelunkybuddies>torch</a>)</li></td>");
if(level3_unlocked)
	phasetab.append("<td class=phase3>&nbsp;</td>");
else
	phasetab.append("<td class=phase3> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Landmine target=_blank title=A Landmine>A Landmine</a><br> (Following options are exclusive)<li>Open <a href=http://kol.coldfront.net/thekolwiki/index.php/Spelunkrifice target=_blank title=Spelunkrifice>The Altar</a></li><li>Open <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Crashed_U._F._O. target=_blank title=The Crashed U. F. O.>The Crashed U. F. O.</a> (with 3 ropes)</li></td>");
phasetab.append("</tr>");

phasetab.append("<tr>");
phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Temple_Ruins target=_blank title=The Temple Ruins>The Temple Ruins</a></td>");
phasetab.append("<td class=phase1> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Crate target=_blank title=A Crate>A Crate</a></td>");
phasetab.append("<td class=phase2> <a href=http://kol.coldfront.net/thekolwiki/index.php/Idolatry target=_blank title=Idolatry>Idolatry</a><li>250 Gold, and without a <a href=http://kol.coldfront.net/thekolwiki/index.php/Jetpack target=_blank title=Jetpack>jetpack</a>, <a href=http://kol.coldfront.net/thekolwiki/index.php/Spring_boots target=_blank title=Spring boots>spring boots</a>+<a href=http://kol.coldfront.net/thekolwiki/index.php/Yellow_cape target=_blank title=Yellow cape>yellow cape</a>, or <a href=http://kol.coldfront.net/thekolwiki/index.php/Template:Spelunkybuddies target=_blank title=Template:Spelunkybuddies>buddy</a> lose all HP</li></td>");
if(level4_unlocked)
	phasetab.append("<td class=phase3>&nbsp;</td>");
else
	phasetab.append("<td class=phase3> <a href=http://kol.coldfront.net/thekolwiki/index.php/It%27s_a_Trap!_A_Smashy_Trap. target=_blank title=It\'s a Trap! A Smashy Trap.>It\'s a Trap! A Smashy Trap.</a><li>Open <a href=http://kol.coldfront.net/thekolwiki/index.php/The_City_of_Goooold target=_blank title=The City of Goooold>The City of Goooold</a> (with a key)</li><li>Lose 40 HP</li></td>");
phasetab.append("</tr>");

if(!get_property("spelunkyStatus").contains_text("Snake Pit")) {
	phasetab.append("<tr>");
	phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Spider_Hole target=_blank title=The Spider Hole>The Spider Hole</a></td>");
	phasetab.append("<td class=level1 colspan=3> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Wicked_Web target=_blank title=A Wicked Web>A Wicked Web</a><li>10-20 Gold</li><li>30-50 Gold (with a <a href=http://kol.coldfront.net/thekolwiki/index.php/Torch target=_blank title=Template:Spelunkybuddies>torch</a>)</li><li>Gain a <a href=http://kol.coldfront.net/thekolwiki/index.php/Template:Spelunkybuddies target=_blank title=Template:Spelunkybuddies>buddy</a> or 20-30 gold (with <a href=http://kol.coldfront.net/thekolwiki/index.php/Sturdy_machete target=_blank title=Sturdy machete>sturdy machete</a>)</li></td>");
	phasetab.append("</tr>");
}

if(!get_property("spelunkyStatus").contains_text("Spider Hole")) {
	phasetab.append("<tr>");
	phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Snake_Pit target=_blank title=The Snake Pit>The Snake Pit</a></td>");
	phasetab.append("<td class=level1 colspan=3> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Crate target=_blank title=A Crate>A Crate</a></td>");
	phasetab.append("</tr>");
}

if(!get_property("spelunkyStatus").contains_text("Beehive")) {
	phasetab.append("<tr>");
	phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Ancient_Burial_Ground target=_blank title=The Ancient Burial Ground>The Ancient Burial Ground</a></td>");
	phasetab.append("<td class=level2 colspan=3> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Tombstone target=_blank title=A Tombstone>A Tombstone</a><li>~25 Gold</li><li><a href=http://kol.coldfront.net/thekolwiki/index.php/Shotgun target=_blank title=Shotgun>shotgun</a> (with <a href=http://kol.coldfront.net/thekolwiki/index.php/Heavy_pickaxe target=_blank title=Heavy pickaxe>heavy pickaxe</a>)</li><li><a href=http://kol.coldfront.net/thekolwiki/index.php/The_Clown_Crown target=_blank title=The Clown Crown>The Clown Crown</a> (with <a href=http://kol.coldfront.net/thekolwiki/index.php/X-ray_goggles target=_blank title=X-ray goggles>x-ray goggles</a>)</li></td>");
	phasetab.append("</tr>");
}

if(!get_property("spelunkyStatus").contains_text("Burial Ground")) {
	phasetab.append("<tr>");
	phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Beehive target=_blank title=The Beehive>The Beehive</a></td>");
	phasetab.append("<td class=level2 colspan=3> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Crate target=_blank title=A Crate>A Crate</a></td>");
	phasetab.append("</tr>");
}

if(!get_property("spelunkyStatus").contains_text("Altar")) {
	phasetab.append("<tr>");
	phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_Crashed_U._F._O. target=_blank title=The Crashed U. F. O.>The Crashed U. F. O.</a></td>");
	phasetab.append("<td class=level3 colspan=3> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Crate target=_blank title=A Crate>A Crate</a></td>");
	phasetab.append("</tr>");
}

phasetab.append("<tr>");
phasetab.append("<td> <a href=http://kol.coldfront.net/thekolwiki/index.php/The_City_of_Goooold target=_blank title=The City of Goooold>The City of Goooold</a></td>");
phasetab.append("<td class=level4 colspan=3> <a href=http://kol.coldfront.net/thekolwiki/index.php/A_Golden_Chest target=_blank title=A Golden Chest>A Golden Chest</a><li>150 Gold (with key)</li><li>80-100 Gold (with bomb)</li><li>60 Gold and lose 20 HP</li></td>");
phasetab.append("</tr>");

phasetab.append("</table>");
phasetab.append("</div>");
phasetab.append("\n");


// place.php?whichplace=spelunky
buffer spelunk(buffer page) {
	string next = get_property("spelunkyNextNoncombat");
	
	// First insert style information for current phase
	int index = page.index_of("</head>");
	if(index < 0 || !page.contains_text("<b>Tales of Spelunking</b>")) { return page; }
	
	buffer style;
	style.append("<style type='text/css'> ");
	style.append(spcss);
	style.append(" th.phase");
	style.append(next);
	style.append(" {background-color: #E6E600;} td.phase");
	style.append(next);
	if(level1_unlocked)
		style.append(", td.level1");
	if(level2_unlocked)
		style.append(", td.level2");
	if(level3_unlocked)
		style.append(", td.level3");
	if(level4_unlocked)
		style.append(", td.level4");
	style.append(" {background-color: #FFFF66;} </style>");
	page.insert(index, style);
	
	// Now insert Spelunkin' Phase and Table
	index = page.last_index_of("</center></td></tr><tr><td height=4>");
	if(index < 0) return page;
	buffer info;
	info.append("<p>Win Count: <b>");
	info.append(get_property("spelunkyWinCount"));
	info.append("</b>, Next Phase: <b>");
	info.append(next);
	info.append("</b></p>");
	info.append(phasetab);
	page.insert(index, info);
	
	return page;
}


void main() {
	visit_url().spelunk().write();
}
