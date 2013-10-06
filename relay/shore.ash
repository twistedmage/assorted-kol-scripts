void main() {
	buffer results;
	results.append(visit_url());
	
	void dynamite() {
		if(available_amount($item[stick of dynamite]) < 1) results.replace_string("Distant Lands Dude Ranch Adventure",
			"<font color=\"green\"><b>Distant Lands Dude Ranch Adventure (stick of dynamite needed)</b></font>");
	}

	void orchid() {
		if(available_amount($item[tropical orchid]) < 1 && available_amount($item[packet of orchid seeds]) < 1) results.replace_string("Tropical Paradise Island Getaway",
			"<font color=\"green\"><b>Tropical Paradise Island Getaway (tropical orchid needed)</b></font>");
	}

	void fence() {
		if(available_amount($item[barbed-wire fence]) < 1) results.replace_string("Large Donkey Mountain Ski Resort",
			"<font color=\"green\"><b>Large Donkey Mountain Ski Resort (barbed-wire fence needed)</b></font>");
	}
	
	if(!can_interact() && my_path() != "Bugbear Invasion") {
		if(my_path() == "Bees Hate You") {
			orchid();
		} else if(get_property("telescopeUpgrades") == "7" && !in_bad_moon()) {
			switch(get_property("telescope7")) {
			case "see a wooden beam":
				dynamite(); break;
			case "see a formidable stinger":
				orchid(); break;
			case "see a pair of horns":
				fence(); break;
			}
		} else {
			dynamite();
			orchid();
			fence();
		}
	}
	
	if(my_level() > 10 && item_amount($item[forged identification documents]) < 1 && item_amount($item[your father's MacGuffin diary]) < 1) {
		results.replace_string("<tr><td colspan=2 align=center><input class=button type=submit value=\"Sail Away! (3)\"></td></tr>",
		"<tr><td colspan=2 style=\"{border: 1px solid black; padding: 1px;}\" align=center>You shouldn't Sail Away (3) without the forged documents</td></tr>");
	}
	results.write();
}