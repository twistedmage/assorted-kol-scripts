// Title: Discoveries.ash
// Version: 3.3
// Created by Rinn
// Modified (again) by matt,chugg

//
// modifying the following to auto create items.
//
boolean createbooze = false;
boolean createfood = false;
boolean createequipment = false;
boolean createjewelry = false;
boolean createitems = false;

boolean ignoredepleted = true;

// add this feature later!
//boolean canuntinker = false;

string [item] concoctions;
file_to_map("concoctions.txt", concoctions);

// Unlist the items that don't appear in the discoveries pages.
concoctions[$item[lit cigar]] = "UNLISTED";
concoctions[$item[Mighty Bjorn action Figure]] = "UNLISTED";
concoctions[$item[Mighty Bjorn action Figure]] = "UNLISTED";
concoctions[$item[plate of franks and beans]] = "UNLISTED";
concoctions[$item[flask of peppermint schnapps]] = "UNLISTED";
concoctions[$item[rainbow pearl earring]] = "UNLISTED";
concoctions[$item[rainbow pearl necklace]] = "UNLISTED";
concoctions[$item[rainbow pearl ring]] = "UNLISTED";
// Some items require recipes so don't need to be listed
concoctions[$item[white chocolate chip brownies]] = "UNLISTED";
concoctions[$item[concoction of clumsiness]] = "UNLISTED";

// Damn unicode characters
concoctions[to_item(1712)] = "UNLISTED";

// Change wad type for transmutations. (YOU HAVE TO COOK THESE MANUALLY, MAFIA WON'T DO IT)
concoctions[$item[cold wad]] = "SSAUCE";
concoctions[$item[sleaze wad]] = "SSAUCE";
concoctions[$item[stench wad]] = "SSAUCE";
concoctions[$item[hot wad]] = "SSAUCE";
concoctions[$item[spooky wad]] = "SSAUCE";

if (!ignoredepleted)
{
	// Add in the depleted Grimacite equipment.
	concoctions[$item[depleted Grimacite astrolabe]] = "DEPLETED";
	concoctions[$item[depleted Grimacite gravy boat]] = "DEPLETED";
	concoctions[$item[depleted Grimacite ninja mask]] = "DEPLETED";
	concoctions[$item[depleted Grimacite weightlifting belt]] = "DEPLETED";
	concoctions[$item[depleted Grimacite grappling hook]] = "DEPLETED";
	concoctions[$item[depleted Grimacite hammer]] = "DEPLETED";
	concoctions[$item[depleted Grimacite shinguards]] = "DEPLETED";	
}

boolean is_female = visit_url("desc_effect.php?whicheffect=dfcd77bff25d3dd413644f5decfbf4e8").contains_text("+6");

void discovery() {

	print("Generating list of items you've already discovered...", "blue");

	item [int] cook;
	item [int] sauce;
	item [int] ssauce;
	item [int] pasta;
	item [int] dsauce;
	item [int] tempura;

	item [int] mix;
	item [int] acock;
	item [int] scock;
	item [int] sacock;

	item [int] smith;
	item [int] smith_f;
	item [int] smith_m;
	item [int] wsmith;
	item [int] asmith;
	item [int] asmith_f;
	item [int] asmith_m;
	item [int] depleted;
	item [int] combine;

	item [int] jewel;
	item [int] ejewel;

	print("Getting list of discovered meat-pastables...");
	string pastepage = visit_url("craft.php?mode=discoveries&what=combine");
	int currentpastecount = count(split_string(pastepage,"descitem")) - 1;
	print(currentpastecount + " current meat-pasteable discoveries.");

	print("Getting list of discovered food...");
	string foodpage = visit_url("craft.php?mode=discoveries&what=cook");
	int currentfoodcount = count(split_string(foodpage,"descitem")) - 1;
	print(currentfoodcount + " current food discoveries.");

	print("Getting list of discovered arms & armor...");
	string smithpage = visit_url("craft.php?mode=discoveries&what=smith");
	int currentsmithcount = count(split_string(smithpage,"descitem")) - 1;
	print(currentsmithcount + " current arms & armor discoveries.");

	print("Getting list of discovered booze...");
	string boozepage = visit_url("craft.php?mode=discoveries&what=cocktail");
	int currentboozecount = count(split_string(boozepage,"descitem")) - 1;
	print(currentboozecount + " current booze discoveries.");

	print("Getting list of discovered jewelry...");
	string jewelrypage = visit_url("craft.php?mode=discoveries&what=jewelry");
	int currentjewelrycount = count(split_string(jewelrypage,"descitem")) - 1;
	print(currentjewelrycount + " current jewelry discoveries.");
	
	// if create items is true, the check if we can untinker afterwards
	// otherwise we won't create meat pastables
	// add untinker feature later
	//if (createitems==true) {
	//	print("Determining status of untinkerer...");
	//	canuntinker=contains_text(visit_url("town_right.php?place=untinker"),"as many as possible");
	//}

	print("Running comparison...", "blue");

	foreach i in concoctions {
		item currentitem = i;
		string crafttype = concoctions[i];
        
		switch (crafttype) {			
			case "COOK":
				if (!contains_text(foodpage, to_string(currentitem))) {
					cook[cook.count()]=currentitem;
				}
				break;

			case "SAUCE":
				if (!contains_text(foodpage, to_string(currentitem))) {
					sauce[sauce.count()]=currentitem;
				}
				break;

			case "SSAUCE":
				if (!contains_text(foodpage, to_string(currentitem))) {
					ssauce[ssauce.count()]=currentitem;
				}
				break;

			case "PASTA":
				if (!contains_text(foodpage, to_string(currentitem))) {
					pasta[pasta.count()]=currentitem;
				}
				break;

			case "DSAUCE":
				if (!contains_text(foodpage, to_string(currentitem))) {
					dsauce[dsauce.count()]=currentitem;
				}
				break;

			case "TEMPURA":
				if (!contains_text(foodpage, to_string(currentitem))) {
					tempura[tempura.count()]=currentitem;
				}
   				break;
			
			case "MIX":
				if (!contains_text(boozepage, to_string(currentitem))) {
					mix[mix.count()]=currentitem;
				}
				break;

			case "ACOCK":
				if (!contains_text(boozepage, to_string(currentitem))) {
					acock[acock.count()]=currentitem;
				}
				break;

			case "SCOCK":
				if (!contains_text(boozepage, to_string(currentitem))) {
					scock[scock.count()]=currentitem;
				}
				break;

			case "SACOCK":
				if (!contains_text(boozepage, to_string(currentitem))) {
					sacock[sacock.count()]=currentitem;
				}
				break;

			case "SMITH":
				if (!contains_text(smithpage, to_string(currentitem))) {
					if (i.to_string().contains_text("skirt") && !i.to_string().contains_text("grass skirt"))
						smith_f[smith_f.count()]=currentitem;
					else if (i.to_string().contains_text("kilt"))
						smith_m[smith_m.count()]=currentitem;
					else
						smith[smith.count()]=currentitem;
				}
				break;

			case "WSMITH":
				if (!contains_text(smithpage, to_string(currentitem))) {
					wsmith[wsmith.count()]=currentitem;
				}
				break;

			case "ASMITH":
				if (!contains_text(smithpage, to_string(currentitem))) {
					if (i.to_string().contains_text("skirt"))
						asmith_f[asmith_f.count()]=currentitem;
					else if (i.to_string().contains_text("kilt"))
						asmith_m[asmith_m.count()]=currentitem;
					else
						asmith[asmith.count()]=currentitem;
				}
				break;

			case "DEPLETED":
				if (!contains_text(smithpage, to_string(currentitem))) {
					depleted[depleted.count()]=currentitem;
				}
    			break;
			
			case "COMBINE":
				if (!contains_text(pastepage, to_string(currentitem))) {
					combine[combine.count()]=currentitem;
				}
				break;

			case "JEWEL":
				if (!contains_text(jewelrypage, to_string(currentitem))) {
					jewel[jewel.count()]=currentitem;
				}
				break;
			case "EJEWEL":
				if (!contains_text(jewelrypage, to_string(currentitem))) {
					ejewel[ejewel.count()]=currentitem;
				}
				break;

			default:
				break;
		}
	}

	print("Comparison Complete!", "green");

	print("");

	if ((cook.count() + sauce.count() + ssauce.count() + pasta.count() + dsauce.count() + tempura.count()) > 0) {
		print("You have " + (cook.count() + sauce.count() + ssauce.count() + pasta.count() + dsauce.count() + tempura.count()) + "/" + (cook.count() + sauce.count() + ssauce.count() + pasta.count() + dsauce.count() + tempura.count() + currentfoodcount) + " undiscovered cookable food:", "red");
		
		// cookable with no special skills
		if(cook.count() > 0){
			print("Of which " + cook.count() + " require no special skills:", "red");
			foreach i in cook {
				print(to_string(cook[i]));
				if (createfood==true) {
					cli_execute("try; bake 1 " + cook[i].to_string());
				}
			}
		}
		
		// require advanced saucecrafting
		if(sauce.count() > 0){
			print("Of which " + sauce.count() + " require Advanced Saucecrafting:", "red");
			foreach i in sauce {
				print(to_string(sauce[i]));
				if (createfood==true && have_skill($skill[Advanced Saucecrafting])) {
					cli_execute("try; bake 1 " + sauce[i].to_string());
				}
			}
		}
		
		// require way of sauce
		if(ssauce.count() > 0){
			print("Of which " + ssauce.count() + " require The Way of Sauce:", "red");
			foreach i in ssauce {
				print(to_string(ssauce[i]));
				if (createfood==true && have_skill($skill[The Way of Sauce]) && !i.to_string().contains_text("wad")) {
					cli_execute("try; bake 1 " + ssauce[i].to_string());
				}
			}
		}
		
		// require pastamancery
		if(pasta.count() > 0){
			print("Of which " + pasta.count() + " require Pastamastery:", "red");
			foreach i in pasta {
				print(to_string(pasta[i]));
				if (createfood==true && have_skill($skill[Pastamastery])) {
					cli_execute("try; bake 1 " + pasta[i].to_string());
				}
			}
		}
		
		// require deep saucery
		if(dsauce.count() > 0){
			print("Of which " + dsauce.count() + " require Deep Saucery:", "red");
			foreach i in dsauce {
				print(to_string(dsauce[i]));
				if (createfood==true && have_skill($skill[Deep Saucery])) {
					cli_execute("try; bake 1 " + dsauce[i].to_string());
				}
			}
		}
		
		// require tempuramancy
		if(tempura.count() > 0){
			print("Of which " + tempura.count() + " require Tempuramancy:", "red");
			foreach i in tempura {
				print(to_string(tempura[i]));
				if (createfood==true && have_skill($skill[Tempuramancy])) {
					cli_execute("try; bake 1 " + tempura[i].to_string());
				}
			}
		}
	} else {
		print("You have no undiscovered cookable food", "green");
	}

	print("");

	if ((mix.count() + acock.count() + scock.count() + sacock.count()) > 0) {
		print("You have " + (mix.count() + acock.count() + scock.count() + sacock.count()) + "/" + (mix.count() + acock.count() + scock.count() + sacock.count() + currentboozecount) +" undiscovered mixable drinks:", "red");
		
		
		// drink with no special skills
		if(mix.count() > 0){
			print("Of which " + mix.count() + " require no special skills:", "red");
			foreach i in mix {
				print(to_string(mix[i]));
				if (createbooze==true) {
					cli_execute("try; mix 1 " + mix[i].to_string());
				}
			}
		}
		
		// require advanced cocktail crafting
		if(acock.count() > 0){
		print("Of which " + acock.count() + " require Advanced Cocktailcrafting:", "red");
			foreach i in acock {
				print(to_string(acock[i]));
				if (createbooze==true && have_skill($skill[Advanced Cocktailcrafting])) {
					cli_execute("try; mix 1 " + acock[i].to_string());
				}
			}
		}
		
		// require superhuman cocktailcrafting
		if(scock.count() > 0){
			print("Of which " + scock.count() + " require Superhuman Cocktailcrafting:", "red");
			foreach i in scock {
				print(to_string(scock[i]));
				if (createbooze==true && have_skill($skill[Superhuman Cocktailcrafting])) {
					cli_execute("try; mix 1 " + scock[i].to_string());
				}
			}
		}
		
		// require salacious cocktailcrafting
		if(sacock.count() > 0){
		print("Of which " + sacock.count() + " require Salacious Cocktailcrafting:", "red");
			foreach i in sacock {
				print(to_string(sacock[i]));
				if (createbooze==true && have_skill($skill[Salacious Cocktailcrafting])) {
					cli_execute("try; mix 1 " + sacock[i].to_string());
				}
			}
		}
	} else {
		print("You have no undiscovered mixable drinks", "green");
	}
	
	print("");

	if ((smith.count() + wsmith.count() + asmith.count() + depleted.count()) > 0) {
		print("You have " + (smith.count() + wsmith.count() + asmith.count() + depleted.count()) + "/" + (smith.count() + wsmith.count() + asmith.count() + depleted.count() + currentsmithcount) + " undiscovered meatsmithing recipes:", "red");
		
		// smith with no skill
		if(smith.count() > 0){
			print("Of which " + smith.count() + " require no special skills:", "red");
			foreach i in smith {
				print(to_string(smith[i]));
				if (createequipment==true) {
					cli_execute("try; smith 1 " + smith[i].to_string());
				}	
			}
		}
		
		// smith female
		if(smith_f.count() > 0){
			print("Of which " + smith_f.count() + " require no special skills and being female:", "red");
			foreach i in smith_f {
				print(to_string(smith_f[i]));
				if (createequipment==true && is_female) {
					cli_execute("try; smith 1 " + smith_f[i].to_string());
				}
			}
		}
		
		// smith male
		if(smith_m.count() > 0) {
			print("Of which " + smith_m.count() + " require no special skills and being male:", "red");
			foreach i in smith_m {
				print(to_string(smith_m[i]));
				if (createequipment==true && !is_female) {
					cli_execute("try; smith 1 " + smith_m[i].to_string());
				}
			}	
		}

		// super meat smith
		if(wsmith.count() > 0){
			print("Of which " + wsmith.count() + " require Super-Advanced Meatsmithing:", "red");
			foreach i in wsmith {
				print(to_string(wsmith[i]));
				if (createequipment==true && my_adventures() >= 1 && have_skill($skill[Super-Advanced Meatsmithing])) {
					cli_execute("try; smith 1 " + wsmith[i].to_string());
				}
			}
		}
		
		// require armorcraftiness
		if(asmith.count() > 0){
			print("Of which " + asmith.count() + " require Armorcraftiness:", "red");
			foreach i in asmith {
				print(to_string(asmith[i]));
				if (createequipment==true && my_adventures() >= 1 && have_skill($skill[Armorcraftiness])) {
					cli_execute("try; smith 1 " + asmith[i].to_string());
				}
			}
		}
		
		// require femal armorcraftiness
		if(asmith_f.count() > 0){
			print("Of which " + asmith_f.count() + " require Armorcraftiness and being female:", "red");
			foreach i in asmith_f {
				print(to_string(asmith_f[i]));
				if (createequipment==true && my_adventures() >= 1 && have_skill($skill[Armorcraftiness]) && is_female) {
					cli_execute("try; smith 1 " + asmith_f[i].to_string());
				}
			}
		}
		
		// require male armorcraftiness
		if(asmith_m.count() > 0){
			print("Of which " + asmith_m.count() + " require Armorcraftiness and being male:", "red");
			foreach i in asmith_m {
				print(to_string(asmith_m[i]));
				if (createequipment==true && my_adventures() >= 1 && have_skill($skill[Armorcraftiness]) && !is_female) {
					cli_execute("try; smith 1 " + asmith_m[i].to_string());
				}
			}
		}
		if (!ignoredepleted && (depleted.count() > 0)) {
			print("Of which " + depleted.count() + " require depleted Grimacite plans:", "red");
			foreach i in depleted {
				print(to_string(depleted[i]));
				if (createequipment==true && my_adventures() >= 1) {
					cli_execute("try; smith 1 " + depleted[i].to_string());
				}
			}
		}
	} else {
		print("You have no undiscovered meatsmithing recipes", "green");
	}
	
	print("");
		
	if (combine.count() > 0) {
		print("You have " + combine.count() + "/" + (combine.count() + currentpastecount) + " undiscovered meat-pastables:", "red");
		foreach i in combine {
			print(to_string(combine[i]));
			if (createitems==true) {
				cli_execute("try; make 1 " + combine[i].to_string());
			}
		}
	} else {
		print("You have no undiscovered meat-pastables", "green");
	}

	print("");

	if ((jewel.count() + ejewel.count()) > 0) {
		print("You have " + (jewel.count() + ejewel.count()) + "/" + (jewel.count() + ejewel.count() + currentjewelrycount) + " undiscovered jewelry recipes:", "red");
		
		if(jewel.count() > 0){
			print("Of which " + jewel.count() + " require no special skills:", "red");
			foreach i in jewel {
				print(to_string(jewel[i]));
				if (createjewelry==true && item_amount($item[jewelry-making pliers]) > 0 && my_adventures() >= 3) {
					cli_execute("try; ply 1 " + jewel[i].to_string());
				}
			}
		}
		
		if(ejewel.count() > 0){
			print("Of which " + ejewel.count() + " require Really Expensive Jewelrycrafting:", "red");
			foreach i in ejewel {
				print(to_string(ejewel[i]));
				if (createjewelry==true && item_amount($item[jewelry-making pliers]) > 0 && my_adventures() >= 3 && have_skill($skill[Really Expensive Jewelrycrafting])) {
					cli_execute("try; ply 1 " + ejewel[i].to_string());
				}
			}
		}
	} else {
		print("You have no undiscovered jewelry recipes", "green");
	}

	print("");

	print("Be aware that the discovery pages may contain several recipes to create the same item, these will not be accounted for. In addition, some concoctions may be missing from mafia's data files as some items can be created through different means (for example, wad transmutation). Therefore, not all items can automatically be discovered with this script, and the total discoveries mafia reports may not match the actual total.", "red");
}

void main() {
	discovery();
}




