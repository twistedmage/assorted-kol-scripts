notify "Bale";
// Campground v1.4
// Annotates the telescope results.

void override() {
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
			telescope["see a large cowboy hat"] = new lair("Tyrannosaurus Tex", "a ", $item[chaos butterfly], "in the Giant's Castle");
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
			telescope["see what looks like a writing desk"] = new lair("a best-selling novelist", "a ", $item[plot hole], "in the Giant's Castle");
			telescope["see the tip of a baseball bat"] = new lair("beer batter", "a ", $item[baseball], "from a Baseball Bat at Guano Junction");
			telescope["see what seems to be a giant cuticle"] = new lair("the fickle finger of f8", "a ", $item[razor-sharp can lid], "from any can in the Haunted Pantry");
			telescope["see a pair of horns"] = new lair("an enraged cow", "", $item[barbed-wire fence], "by taking a Mountain vacation");
			telescope["see a formidable stinger"] = new lair("a giant bee", "a ", $item[tropical orchid], "by taking an Island vacation");
			telescope["see a wooden beam"] = new lair("a collapsed mineshaft golem", "a ", $item[stick of dynamite], "by taking a Ranch vacation");
			
			telescope["an armchair"] = new lair("", "", $item[pygmy pygment], "from a Pygmy Assault Squad at the Hidden City");
			telescope["a cowardly-looking man"] = new lair("", "a ", $item[wussiness potion], "from a W Imp at Friar's Gate");
			telescope["a banana peel"] = new lair("", "", $item[gremlin juice], "from any gremlin in the Junkyard");
			telescope["a coiled viper"] = new lair("", "an ", $item[adder bladder], "from a Black Adder at the Black Forest");
			telescope["a rose"] = new lair("", "", $item[Angry Farmer candy], "from a Raver Giant in the Giant's Castle (or other candy)");
			telescope["a glum teenager"] = new lair("", "a ", $item[thin black candle], "in the Giant's Castle");
			telescope["a hedgehog"] = new lair("", "", $item[super-spiky hair gel], "from a Protagonist in the Penultimate Fantasy Airship");
			telescope["a raven"] = new lair("", "", $item[Black No. 2], "from a Black Panther at the Black Forest");
			telescope["a smiling man smoking a pipe"] = new lair("", "", $item[Mick's IcyVapoHotness Rub], "in the Giant's Castle");
		
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

void main() {
	if(form_field("skilluse") != 1) override();
} 
