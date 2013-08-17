

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}
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
