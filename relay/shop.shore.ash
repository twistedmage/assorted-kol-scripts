
buffer telescope(buffer page) {
	
	void dynamite() {
		if(available_amount($item[stick of dynamite]) < 1) page.replace_string("dude ranch souvenir crate",
			"<font color=\"green\"><b>dude ranch souvenir crate<br />(stick of dynamite needed)</b></font>");
	}

	void orchid() {
		if(available_amount($item[tropical orchid]) < 1 && available_amount($item[packet of orchid seeds]) < 1) page.replace_string("tropical island souvenir crate",
			"<font color=\"green\"><b>tropical island souvenir crate<br />(tropical orchid needed)</b></font>");
	}

	void fence() {
		if(available_amount($item[barbed-wire fence]) < 1) page.replace_string("ski resort souvenir crate",
			"<font color=\"green\"><b>ski resort souvenir crate<br />(barbed-wire fence needed)</b></font>");
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
	
	return page;
}

void main() {
	visit_url().telescope().write();
}