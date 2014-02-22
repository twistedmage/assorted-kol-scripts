// Bale's all purpose Universal recovery script
// http://kolmafia.us/showthread.php?t=1780
script "Universal_recovery.ash";
notify "Bale";
string thisver = "3.13";		// This is the script's version!

// To use this script, put Universal_recovery in the /script directory. 
// Then in the Graphical CLI type:
// 		set recoveryScript = Universal_recovery
// also, download relay_Universal_Recovery and put it in the /relay directory.

// OPTIONS:
// All options can be set using relay_Universal_Recovery. Do not edit them in this script.

// Recovery options for this script are ALSO controlled by KolMafia's HP/MP usage section of the 
// Adventuring tab. This makes use of settings to restore HP and MP, but ignores most of the check boxes
// below with a few exceptions: See relay UI for a list of which healing options can be disabled.
// In mallcore mode it will always use the cheapest item regardless of settings.

// STATUS EFFECTS:
// This script will attempt to cure beaten up and all kinds of poisoning, since those have a powerful
// effect on maximum hp and mp. I recommend unchecking "Auto-remove malignant status effects" from
// KolMafia's General Preferences and adding other malignant status like cunctatitis that really
// trouble you in your mood to be uneffected. You'll save a fortune in SGEEAs.

// OTHER INFORMATION:
// This program will attempt the most optimal method of healing. In ronin or hardcore resources are
// limited and scarce, so it will try to waste absolutely nothing. Out of ronin it will always use the
// best value, purchasing whatever's needed, so that you can sell the more expensive restoratives.

// This will refuse to use anything in the closet, so that should be used to store anything which the
// player does not want expended. Only actual inventory and meat will be expended by this script. 

record restorative_info {
	int minhp;
	int maxhp;
	int minmp;
	int maxmp;
	float avehp;
	float avemp;
#	boolean combat;
};
restorative_info [item] heal;	// This is the map of all restoratives and how much they heal.
string fname = "recoveryScript_map_v2"; 	// This is the name of the map file.

record skill_info {				// Used for storing healing skill data
	float ave;
	int mp;
};
skill_info [skill] skills;	  // This is the map of all skills the character has. See populate_skills()

// If a string is not an int, this function returns the default value.
int default_int(string pref, int def) {
	return !is_integer(pref) ? def : to_int(pref);
}

// These properties are set by the relay browser UI:
   // Verbosity: 0=none, 1=normal, 2=verbose, 3=chatterbox
int Verbosity = get_property("baleUr_Verbosity").default_int(1);
   // Is it allowable to purchase from the mall or NPCS?
int baleUr_Purchase = get_property("baleUr_Purchase").default_int(3);
boolean buy_mall = baleUr_Purchase > 2 || (baleUr_Purchase == 1 && get_property("autoSatisfyWithMall").to_boolean());
boolean buy_npc = baleUr_Purchase > 1 || (baleUr_Purchase == 1 && get_property("autoSatisfyWithNPCs").to_boolean());
boolean fist_safely = !get_property("baleUr_FistPurchase").to_boolean() && my_path() == "Way of the Surprising Fist";
if(fist_safely) {
	buy_mall = false;
	buy_npc = false;
}
boolean bees = my_path() == "Bees Hate You";
boolean boris = my_path() == "Avatar of Boris";
boolean zombie = my_path() == "Zombie Slayer";
	
   // If this is set to true, this script will not use the hot tub. That way you can save it for use in the Slime Tube.
boolean DontUseHotTub = get_property("baleUr_DontUseHotTub").to_boolean();
   // Using up existing stock of MMJ, even if more cannot be purchased in this ascension! 
boolean UseMmjStock = get_property("baleUr_UseMmjStock").to_boolean();
   // Minimum usage of a birdform item. Less than this percentage and it will be considered a waste. (Other restores require 100%)
float BirdThreshold = get_property("baleUr_BirdThreshold").to_float(); if(BirdThreshold == 0) BirdThreshold = 0.1;
   // Use up inventory in mallmode
boolean UseInventoryInMallmode = get_property("baleUr_UseInventoryInMallmode").to_boolean();
   // Use free disco rests for HP, MP or both? both = ""
string DiscoResting = get_property("baleUr_DiscoResting");
   // Correct Beaten Up, poisoned and a host of other status effects.
boolean ignoreStatus = get_property("baleUr_ignoreStatus").to_boolean();
boolean AlwaysContinue = get_property("baleUr_AlwaysContinue").to_boolean();

// These are the default values to restore hp and mp.
int hp_trigger, hp_target, mp_trigger, mp_target;
void set_autohealing() {
	hp_trigger = floor(my_maxhp() * to_float(get_property("hpAutoRecovery")));
	hp_target = ceil(my_maxhp() * to_float(get_property("hpAutoRecoveryTarget")));
	if(zombie) {
		mp_trigger = floor(get_property("baleUr_ZombieAuto") == ""? -1: to_float(get_property("baleUr_ZombieAuto")));
		mp_target = get_property("baleUr_ZombieTarget").to_int();
	} else {
		mp_trigger = floor(my_maxmp() * to_float(get_property("mpAutoRecovery")));
		mp_target = ceil(my_maxmp() * to_float(get_property("mpAutoRecoveryTarget")));
	}
} set_autohealing();

int objective;			// This is the target passed to the recoveryScript.
string start_type;		// This is the type passed to the recoveryScript.
item null = $item[Xlyinia's notebook];	// The purpose of the null is that it restores nothing. Obviously.
	// Can the character cure beaten up without an item?
boolean tongue = have_skill($skill[Tongue of the Walrus]);
	// Can the character purchase magical mystery juice?
boolean buy_mmj = ($classes[Pastamancer, Sauceror] contains my_class()) || (my_class() == $class[accordion thief] && my_level() >= 9);
	// Check preferences to see what forms of healing are allowed.
string hpAutoRecoveryItems = get_property("hpAutoRecoveryItems");
string mpAutoRecoveryItems = get_property("mpAutoRecoveryItems");
	// Is there a familiar that grants spleen items?
boolean spleenfam =have_familiar($familiar[Green Pixie]) || have_familiar($familiar[LLama lama])
	|| have_familiar($familiar[Baby Sandworm]) || have_familiar($familiar[Rogue Program])
	|| have_familiar($familiar[Pair of Stomping Boots]);
	// Use Medicinal Herb's medicinal herbs?
boolean use_herb = contains_text(hpAutoRecoveryItems, "medicinal herb's medicinal herbs")
	&& !(bees || boris || zombie) && my_level() > 2
	&& (my_primestat() == $stat[muscle] || item_amount($item[Medicinal Herb's medicinal herbs]) > 0
	|| (my_class() == $class[accordion thief] && my_level() >= 9));
	// Number of free Disco Rests, HP restored by resting at camp, MP restored by resting at camp.
int disco = to_int(have_skill($skill[Disco Nap]))
	+ 2* to_int(have_skill($skill[Adventurer of Leisure]))
	+ to_int(have_skill($skill[Executive Narcolepsy]))
	+ 10*to_int(have_skill($skill[Food Coma]))
	+ 5*to_int(have_skill($skill[Dog Tired]));
	// For the 6 basic clases, possessing an Unconscious Collective gives 3 rests.
if(my_class().to_int() < 7 && have_familiar($familiar[Unconscious Collective])) disco += 3;
int rest_hp = numeric_modifier("Base Resting HP") * (numeric_modifier("Resting HP Percent")+100) / 100 + numeric_modifier("Bonus Resting HP");
int rest_mp = numeric_modifier("Base Resting MP") * (numeric_modifier("Resting MP Percent")+100) / 100 + numeric_modifier("Bonus Resting MP");
	// If the character has properties set to not auto-purhase from mall, then always stay in hardcore mode.
boolean mallcore = can_interact() && buy_mall && (my_ascensions() > 0 || my_level() > 4);
	// Switch equipment to minimize casting cost of skills in ronin/hardcore? (delete end to do it in mallcore)
boolean switch_gear = get_property("switchEquipmentForBuffs").to_boolean() && !can_interact();
item [slot] mp_gear;         // Optimal gear for low mana cost. Set in mp_gear()
boolean cant_switch = true;  // Set to false in mp_gear() if the character has equipment to switch for buffing. Used in cast()
int mana_mod = 0; 		// This is the mana cost difference between current gear and mp_gear.

int rpp = 0;	// These three values are used to save items for fighting your shadow.
int gg = 0;		// These are the red pixel potions, gauze and filthy poultices to save.
int fp = 0;		// I made them global variables because they are used in several places.
item reserve = null;		// This is a spare mp restorative kept for combat use.
item reserve_purch = null;	// In addition, some knob goblin seltzers or mmj may be held in reserve.
int  reserve_num = 0;		// Hold this many of them.

// Datafile is missing or needs updating! Download it using zarqon's automatic map updating: http://kolmafia.us/showthread.php?t=1515
boolean get_newmap(string curr) {
	if(Verbosity > 0) print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
	if(!file_to_map("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getmap", heal) || count(heal) == 0)
		return false;
	map_to_file(heal, fname+".txt");
	set_property(fname+".txt",curr);
	if(Verbosity > 0) print("..."+fname+".txt updated.");
	return true;
}

// Set values for all restoratives usable out of combat.
void restore_values() {
	// Set all simple restorative values from an external file.
	if(!file_to_map(fname+".txt",heal) || count(heal) == 0)
		if(!get_newmap(visit_url("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getver")))
			abort("Restorative data is corrupted or missing. Troublesome!");
	heal[$item[magical mystery juice]].minmp = floor(my_level() * 1.5 + 4.0);
	heal[$item[magical mystery juice]].avemp =       my_level() * 1.5 + 5.0;
	heal[$item[magical mystery juice]].maxmp = ceil (my_level() * 1.5 + 6.0);
	if(have_equipped($item[Dyspepsi-Cola-issue canteen])) { // This item doubles cola effectiveness
		heal[$item[Cloaca-Cola]] = new restorative_info(0, 0, 20, 28, 0.0, 24.0);
		heal[$item[Dyspepsi-Cola]] = new restorative_info(0, 0, 20, 28, 0.0, 24.0);
	}
	if(to_item("potion of healing") != $item[none]) 	// This is the Dungeon of Doom healing potion.
		heal[to_item("potion of healing")] = new restorative_info(4, 16, 4, 16, 10.0, 10.0);
	// Get rid of those oyster eggs so that I don't waste time with them later.
	foreach egg in $items[blue paisley oyster egg, blue polka-dot oyster egg, blue striped oyster egg, 
	  red paisley oyster egg, red polka-dot oyster egg, red striped oyster egg]
		remove heal [egg];
	// Add pseudo items that can be used to MAKE recovery items.
	heal[$item[Palm frond]] = new restorative_info(18, 22, 18, 22, 20.0, 20.0);
	if(!bees && (mallcore || contains_text(hpAutoRecoveryItems, "really thick bandage")))
		heal[$item[mummy wrapping]] = new restorative_info(50, 60, 0, 0, 55.0, 0.0);
	if(mallcore)  // This is only handled freely in mallcore mode
		heal[$item[six-pack of New Cloaca-Cola]] = new restorative_info(0, 0, 840, 960, 0.0, 900.0);
	if(buy_mmj && !guild_store_available() && !fist_safely) {
		if(my_level() > 3 && start_type == "MP") 	// Best remind the player he should open his guild store already
			if((my_primestat() == $stat[mysticality] && Verbosity > 0) || Verbosity > 1)
				print("You'd be able to purchase magical mystery juice if you opened your guild store", "red");
		buy_mmj = false;
	}
	if(item_amount($item[Azazel's unicorn]) > 0 || have_skill($skill[Liver of Steel]) 
	  || have_skill($skill[Stomach of Steel]) || have_skill($skill[Spleen of Steel])) {
		heal[$item[beer-scented teddy bear]] = new restorative_info(0, 0, 15, 20, 0.0, 17.5);
		heal[$item[comfy pillow]] = new restorative_info(20, 30, 0, 0, 25.0, 0.0);
	}
	if(bees)
		foreach it in heal
			if(it.to_string().to_lower_case().index_of("b") != -1)
				remove heal[it];
	heal[null] = new restorative_info(0, 0, 0, 0, 0.0, 0.0);
}

// This ensures the safety of ammunition to attack the shadow with.
// It assumes that rpps are to be used to heal with only if the character does not have funkslinging.
// If out of ronin and hardcore, then this function will never be called.
void shadow_prep() {
	int getable(item i, int need) {
		return min(item_amount(i) + closet_amount(i), max(0, need));
	}
	rpp = (!have_skill($skill[Ambidextrous Funkslinging]) && getable($item[red pixel potion], 4) > 0)? 1: 0;
	gg = getable($item[gauze garter], 6 - rpp);
	fp = getable($item[filthy poultice], 6 - rpp - gg);
	rpp = rpp + getable($item[red pixel potion], 4 - rpp - gg - fp);
}

// Will return true if the user is afflicted with a given status effect
boolean beset(effect e) {
	return have_effect(e) > 0;
}

// Will return true if the user is afflicted with any one of a number of $effects[]
boolean beset(boolean [effect] badstuff) {
	foreach e in badstuff
		if(have_effect(e) > 0) return true;
	return false;
}

int mpcost(skill sk) {
	if(have_effect($effect[Chilled to the Bone]) > 0)
		return 3 ** (my_location().kisses - 1) + mp_cost(sk);
	return mp_cost(sk);
}

// This will return the character's best equipment for reducing mp cost. There are two times that this function
// is called. When trying to cure beaten up or when healing with skills. It is much less important to check 
// changes to Max HP when casting tongue skills. It will be called a second time after Beaten Up has been cured.
// This includes softcore items in case the user desires softcore item switching, which can only be enabled by a clever user deleting 18 characters from 1 line near the beginning of the script.
item [slot] mp_gear(int target) {
	item [slot] gear;
		gear[$slot[acc3]] = null; // If null is returned in acc3, then I know nothing was found
	// This function will revoke the failure condition
	void unset_failure() {
		if(gear[$slot[acc3]] == null)
			remove gear [$slot[acc3]];
	}
	
	if(beset($effect[Dreams and Lights]))
		return gear; 	// The effect is more powerful than any gear and doesn't stack with it. That's enough

	boolean [slot] acc; // Just a list of currently unneeded accessory slots
		acc[$slot[acc1]] = false;
		acc[$slot[acc2]] = false;
		acc[$slot[acc3]] = false;
	int start_bonus = numeric_modifier("Mana Cost");
	int best_bonus = start_bonus;
	
	// This will test to see if the new item is compatible with the old setup if parameters are set to test_gear
	boolean test_gear(slot where, item it) {
		// First test to see if it will cause a problem with maximum HP or MP
		int local_target = target;
		if(objective == 0 && target < my_maxhp())
			local_target = target * .95;
		string whatif = "whatif";
		foreach key in gear
			if(gear[key] != $item[none] && gear[key] != null)
				whatif = whatif + " equip "+ key+ " "+ gear[key]+ ";";
		whatif = whatif+ " equip "+ where+ " "+ it+";";
		cli_execute(whatif+ " quiet");
		int changed_hp = numeric_modifier("_spec", "Buffed HP Maximum");
		int changed_mp = numeric_modifier("_spec", "Buffed MP Maximum");
		if(beset($effect[Beaten Up])) {  	// If beaten up, this is evaluating tongue skills.
			int tongue_target = 20* have_skill($skill[Tongue of the Walrus]).to_int() + 15; 
			// tongue is 35 with Walrus or 15 without. (Since that's what a tongue skill will heal.)
			// skill costs will be evaluated again later when healing HP.
			if(tongue_target < local_target)
				local_target = tongue_target;
		}
		if(changed_hp < local_target || changed_hp < my_hp() || changed_mp < my_mp())
			return false;
		// Now test to see if the gear will actually reduce mana cost in that slot
		foreach slt in $slots[hat, acc1, acc2, acc3] // Places where a mana cost reducing item can be worn
			if(equipped_item(slt) != $item[none] 
			  && !(gear contains slt && gear[slt] != $item[none] && gear[slt] != null))
				whatif = whatif + " unequip "+ slt+ ";";
		whatif = whatif + " equip " + where + " " + it + ";";
		cli_execute(whatif + " quiet");
		return numeric_modifier("_spec", "Mana Cost") < best_bonus;
	}
	
	slot equip_type;		// This is the slot where a given item is equipped.
	foreach mana_gear in $items[Brimstone Bracelet, plexiglass pocketwatch, jewel-eyed wizard hat, 
	  navel ring of navel gazing, stainless steel solitaire, woven baling wire bracelets, 
	  solid baconstone earring, baconstone bracelet] 	// Test all items that reduce mana cost
		if(item_amount(mana_gear) > 0 && can_equip(mana_gear)) {
			if(cant_switch) cant_switch = false;
			equip_type = mana_gear.to_slot();	// This is the type of equipment, by slot it equips in.
			if(equip_type == $slot[acc1]) {			// If it is an accessory, figure out best accessory slot.
				if(count(acc) > 0)
					foreach slt in acc
						if(test_gear(slt, mana_gear)) {
							unset_failure();
							gear[slt] = mana_gear;
							remove acc[slt];
							best_bonus = numeric_modifier("_spec", "Mana Cost");
							break;
						}
			} else if(test_gear(equip_type, mana_gear)) {
				unset_failure();
				gear[equip_type] = mana_gear;
				best_bonus = numeric_modifier("_spec", "Mana Cost");
			}
		}
	
	if(start_bonus <= best_bonus) 	// That would be mean the best mana cost gear is ALREADY equipped.
		gear[$slot[acc3]] = null;
	mana_mod = best_bonus - start_bonus;
	return gear;
}

// This creates the list of all skills that the character possesses. This is only called if restoring HP.
boolean populate_skills(int target) {
	clear(mp_gear);
	mp_gear = mp_gear(target);
	if(have_skill($skill[Cannelloni Cocoon])) skills[$skill[Cannelloni Cocoon]].ave = 999999999;
	if(have_skill($skill[Tongue of the Walrus])) skills[$skill[Tongue of the Walrus]].ave = 35;
	if(have_skill($skill[Disco Nap])) 
		skills[$skill[Disco Nap]].ave = have_skill($skill[Adventurer of Leisure])? 40: 20;
	if(have_skill($skill[Lasagna Bandages])) skills[$skill[Lasagna Bandages]].ave =20;
	if(have_skill($skill[Laugh It Off])) skills[$skill[Laugh It Off]].ave =1.5;
	if(have_skill($skill[Bite Minion])) skills[$skill[Bite Minion]].ave =max(my_maxhp()/10, 10);
	if(have_skill($skill[Devour Minions])) skills[$skill[Devour Minions]].ave =max(my_maxhp()/2, 20);
	if(have_skill($skill[Shake It Off])) skills[$skill[Shake It Off]].ave = 999999999;
	foreach key in skills
		skills[key].mp = max(mpcost(key) + mana_mod, 1);
	return true;
}

boolean mp_heal(int target);
// This will cast a skill. The advantage of this over use_skill is to control equipping of -MP Cost items and it sets _meatperhp
boolean cast(int q, skill it) {
	if(it == $skill[none]) return false;
	if(it == $skill[Cannelloni Cocoon] || it == $skill[Shake It Off]) {
		if(my_hp() >= my_maxhp()) return true;
		set_property("_meatperhp", to_string(max(skills[it].mp * get_property("_meatpermp").to_float() / (my_maxhp() - my_hp()), 0.001)));
	} else if(!beset($effect[Beaten Up]))
		set_property("_meatperhp", to_string(skills[it].mp * get_property("_meatpermp").to_float() / skills[it].ave));
	if(q * skills[it].mp > my_maxmp())
		q = floor(my_maxmp() / skills[it].mp);
	if(q == 0) return false;
	if(!switch_gear || cant_switch) {
		if(my_mp() < skills[it].mp) mp_heal(skills[it].mp);
		return use_skill(q, it);
	}
	if(!can_interact())
		set_property("switchEquipmentForBuffs", "false");
	if(mp_gear[$slot[acc3]] == null) {
		if(my_mp() < skills[it].mp) mp_heal(skills[it].mp);
		use_skill(q, it);
	} else {
		item [slot] prior;
		foreach slt in mp_gear 
			if(mp_gear[slt] != $item[none]) {
				prior[slt] = equipped_item(slt);
				equip(slt, mp_gear[slt]);
			}
		if(my_mp() < skills[it].mp) mp_heal(skills[it].mp);
		use_skill(q, it);
		foreach slt in prior
			equip(slt, prior[slt]);
	}
	if(!can_interact())
		set_property("switchEquipmentForBuffs", "true");
	return true;
}

// This will return the amount of an item that I have in inventory and am allowed to use.
int for_use(item it) {
	switch(it) {
	case $item[New Cloaca-Cola]:
		return item_amount(it) + 6 * item_amount($item[six-pack of New Cloaca-Cola]); 
	case $item[mummy wrapping]:
		if(!contains_text(hpAutoRecoveryItems, "really thick bandage")) return 0;
	case $item[Palm frond]:
		int q = item_amount(it);
		return q %2 == 1 ? q-1 : q;
	case $item[red pixel potion]:
		if(!contains_text(hpAutoRecoveryItems, to_string(it))) return 0;
		return item_amount(it) - rpp;
	case $item[gauze garter]: 
		if(!contains_text(hpAutoRecoveryItems, to_string(it))) return 0;
		return item_amount(it) - gg;
	case $item[filthy poultice]: 
		if(!contains_text(hpAutoRecoveryItems, to_string(it))) return 0;
		return item_amount(it) - fp;
	case $item[Medicinal Herb's medicinal herbs]:
	case $item[scroll of drastic healing]:
	case $item[scented massage oil]:
		if(!contains_text(hpAutoRecoveryItems, to_string(it))) return 0;
	case reserve:
		return max(0, item_amount(it) -1);
	case reserve_purch:
		return max(0, item_amount(it) -reserve_num);
	}
	return item_amount(it);
}

// This will buy an item. The advantage over buy or aquire is that it will check to see if I have q of the item
// in inventory (but not closet) and then buy any extra needed. Returns true if it returns any items at all.
boolean purchase(int q, item it) {
	int price;
	switch(it) {
	case $item[magical mystery juice]:
	case $item[Medicinal Herb's medicinal herbs]:
		price = 100;
		break;
	default:
		price = historical_price(it);
	}
	// Stores with limits are a bitch
	int buyit(int x, item doodad, int limit) {
		int bought = buy(x, it, limit);
		if(bought > 0 || x == 1)
			return bought;
		return buy(1, it, limit);
	}
	if(buyit(q- for_use(it), it, min(ceil(price*1.25),get_property("autoBuyPriceLimit").to_int())) > 0 || for_use(it) > 0)
		return true; 	// for_use() needs to be checked both before and after that purchase ;)
	return false;
}

// This will tell me how many of a given restorative I need to restore a minimum quantity of hp/mp
// without over-restoring the other stat. It will count inventory as if Palm fronds were fans and six-packs 
// were New Cloaca-Cola, but won't consider mummy wrappings as thick bandages.
// Will not return items needed to fight against your shadow or reserved "mp combat healing" items.
int inv_quant(item it, int amount, string type){
	float roughquantity;
	int quantity;
	if(type=="MP") {
		if(heal[it].maxmp == 0) return 0;
		if(heal[it].minmp == 999999999) return 1;
		roughquantity = to_float(amount)/ heal[it].maxmp;
		quantity = floor(roughquantity);
		if(ceil(roughquantity) * heal[it].maxmp *.95 + my_mp() <= my_maxmp())
			quantity = ceil(roughquantity);
		while(quantity * heal[it].avehp *.95 + my_hp() > my_maxhp())
			quantity = quantity - 1; // If I'm in hardcore, the item is too valuable to over-restore the other stat.
	} else { 	// type == "HP"
		if(heal[it].maxhp == 0) return 0;
		if(heal[it].minhp == 999999999) return 1;
		roughquantity = to_float(amount)/ heal[it].maxhp;
		quantity = floor(roughquantity);
		if(ceil(roughquantity) * heal[it].maxhp *.95 + my_hp() <= my_maxhp())
			quantity = ceil(roughquantity);
		if(!zombie)
			while(quantity * heal[it].avemp *.95 + my_mp() > my_maxmp() && quantity > 0)
				quantity = quantity - 1; // If I'm in hardcore, the item is too valuable to over-restore the other stat.
	}
	quantity = min(quantity, for_use(it));
	if((it == $item[Palm frond] || it == $item[mummy wrapping]) && quantity %2 == 1 )
		return quantity - 1;
	return quantity;
}

// This will use an item from inventory. It will transform palm fronds in fans and six-packs into New Cloaca cola as necessary.
// amount is only for recalculating six packs.
void use_inv(int q, item it, int amount){
	switch(it) {
	case $item[Palm frond]:
		for i from 1 upto (q/2)
			use(2, $item[Palm frond]);
		use(q/2, $item[palm-frond fan]);
		break;
	case $item[mummy wrapping]:
		for i from 1 upto (q/2)
			use(2, $item[mummy wrapping]);
		use(q/2, $item[Really thick bandage]);
		break;
	case $item[New Cloaca-Cola]:
		if(q > item_amount(it))
			use(ceil((q - item_amount(it))/6.0), $item[six-pack of New Cloaca-Cola]);
		use(q, it);
		break;
	case $item[six-pack of New Cloaca-Cola]:
		use(q, $item[six-pack of New Cloaca-Cola]);
		use(min(q*6, inv_quant($item[New Cloaca-Cola], amount, "MP")), $item[New Cloaca-Cola]);
		break;
	default:
		use(q, it);
	}
}
void use_inv(int q, item it){
	use_inv(q, it, 0);
}

// This will return the skill that has the cheapest mp cost to heal up to target hp. Since some -mp cost
// can throw off the balance of Tongue of the Walrus vs Disco Power Nap and Cannelloni Cocoon, all must be tested.
skill find_cheapest_skill(int target) {
	float amount = target - my_hp();
	skill cheapest = $skill[none];
	int cheapest_cost = 987654321;
	int cost;
	foreach key, value in skills {
		if(value.ave == 0) continue;  // Essential -- checking count(skills) isn't enough.
		cost = ceil(amount / value.ave) * value.mp;
		if(cost < cheapest_cost && value.mp <= my_maxmp()) {
			cheapest = key;
			cheapest_cost = cost;
		}
	}
	return cheapest;
}

// This will return the cost of healing with Doc Galaktik's services. If doit == TRUE, then it will actually
// purchase the service from Doc, otherwise it only returns a value.
int galaktik(int amount, boolean doit, string type) {
	int [string, boolean] galaktik_price;
		galaktik_price["HP", true] = 6;
		galaktik_price["HP", false] = 10;
		galaktik_price["MP", true] = 12;
		galaktik_price["MP", false] = 17;
	int cost = galaktik_price[type, galaktik_cures_discounted()]; 
	if(doit) {
		amount = min(amount, floor(my_meat()/ cost));   // If actually healing, don't spend non-existent meat.
		if(amount > 0)
			cli_execute("galaktik "+type+ " "+ to_string(amount));
	}
	return cost * amount;
}

// How many times do I need to cast the skill? The second is concerned with max MP.
float cast_quant_total(skill it, int target){
    if(it == $skill[none] || skills[it].mp > my_maxmp()) return 0;
    return max(to_float(target - my_hp())/ skills[it].ave, 1.0);
}
float cast_quant(skill it, int target) {
    if(it == $skill[none] || skills[it].mp > my_maxmp()) return 0;
    return max(1.0, min(cast_quant_total(it,target), my_maxmp() / skills[it].mp));
}

// This is the mallcore equivalent of inv_quant. Note that this returns float instead of int.
float mall_quant(item it, int amount, string type){
	if(it == null) return (-1);  	// cost is negative because mall_price() of null is -1, so when they're multiplied...
	float ave;
	if(type == "MP")
		switch {
		case heal[it].maxmp == 0:
			return 0;
		case heal[it].minmp == 999999999:
			return 1;
		default:
			ave = heal[it].avemp;
		} 
	else // type == "HP"
		switch {
		case heal[it].maxhp == 0:
			return 0;
		case heal[it].minhp == 999999999:
			return 1;
		default:
			ave = heal[it].avehp;
		} 
	return (ave == 0) ? 0 : amount/ave;
}

// Returns price of an item or if the character wants to use inventory, it will return 1 for an item in inventory. (Ugh!)
int item_price(item it) {
	if(UseInventoryInMallmode && item_amount(it) > 0) return 1;
	switch(it) {
	// Untradeables, might as well use them
	case $item[beer-scented teddy bear]:
	case $item[comfy pillow]:
		return 1;
	case $item[magical mystery juice]:
	case $item[Medicinal Herb's medicinal herbs]:
		return npc_price(it);
	}
	if(historical_age(it) > 1.5) 	// Ensure that historical_price() is good
		return mall_price(it);
	return historical_price(it);
}

// This will return the best value from the mall. Returns null if the best is Doc Galaktik's restoration.
// Don't forget to consider the costs of Palm frond, six-pack of New Cloaca-Cola & mummy wrapping.
item best_mall(int amount, string type) {
	item best_item = null;
	float best_cost = galaktik(amount, false, type); // This is a good price to beat. For low values it might even be best!
	float q, cost;
	if(Verbosity > 2) print("To heal with Doc Galaktik would cost "+best_cost+ " meat. Now to beat that price...", "blue");
	foreach key in heal {
		if(!(is_tradeable(key) || key == $item[magical mystery juice] || key == $item[Medicinal Herb's medicinal herbs])
		  || (type == "HP" && heal[key].maxhp == 0) || (type == "MP" && heal[key].maxmp == 0))
			continue; 	// Wrong type of restorative so there's no reason to waste processing time.
		if(Verbosity > 2) print("testing "+key+"...");
		q = mall_quant(key, amount, type);
		cost = q * item_price(key);
		switch(key) { 	// Need to check some special cases
		case $item[Delicious shimmering moth]:
		case $item[plump juicy grub]:
			if(!beset($effect[Form of...Bird!]))
				continue;		// Only use moths and grubs if currently in birdform.
			break;
		case $item[Medicinal Herb's medicinal herbs]:
			if(use_herb && my_spleen_use() < spleen_limit())
				cost = q * 100;
			else cost = -1;		// Don't use medicinal herbs unless specified in options.
			break;
		case $item[magical mystery juice]:
			if(buy_mmj || (for_use($item[magical mystery juice]) > 0 && UseMmjStock))
				cost = q * 100;
			else cost = -1;		// Make certain mmj can be purchased.
			break;
		case $item[scroll of drastic healing]:
			cost = cost *2/3;	// 1/3 of the time the scroll is re-used, so it is effectively cheaper.
			break;
		}
		if(Verbosity > 2) {
			if(cost > 0) print("Could heal "+amount+type+" with "+to_string(q.ceil())+" "+key+" for "+cost+" meat.", "Purple");
			else print("Cannot use "+key+".", "Purple");
		}
		if(cost < best_cost && cost > 0) { 	// Unpurchasable items have a ZERO cost.
			best_cost = cost;
			best_item = key;
			if(Verbosity > 2) print(best_item+" is now the best for restoring "+type+".", "blue");
		}
	}
	if(Verbosity > 1) {
		if(best_item == null) print("In mallmode, best "+type+ " restorative is: Doc Galaktik's services. Huh?", "red");
		else print("In mallmode, best "+type+ " restorative is: "+best_item+ " @ "+best_cost+" meat total.", "blue");
	}
	// Set meat per MP so that the information is available to other scripts, like zarqon's SmartStasis
	if(type == "MP")
		set_property("_meatpermp", to_string((best_item == $item[magical mystery juice]
		  ? 100.0 : item_price(best_item))/ heal[best_item].avemp));
	return best_item;
}

// This will ensure that something is on hand, if it isn't in inventory it will purchase or else
// abort if there isn't enough meat on hand. Finally it will use the items that are procured.
// Because of potentially rising prices, this will only purchase up to 10 at a time and simply fail to use more.
boolean use_mall(int q, item it, int amount){
	int ihave;
	switch(it) {
	case $item[mummy wrapping]:
	case $item[Palm frond]:
		ihave = item_amount(it);
		if(q %2 == 1)
			q += 1;
		break;
	case $item[magical mystery juice]:
		if(!buy_mmj) {
			ihave = for_use($item[magical mystery juice]);
			q = min(q, ihave);
			break;
		}  // If I can't buy MMJ, try not to use what doesn't exist.
	default:
		ihave = for_use(it);
	}
	if(UseInventoryInMallmode && ihave > 0)
		q = min(q, ihave);   // This item may be underpriced just because it is in inventory. Don't purchase more!
	if(Verbosity > 1) print("Trying to use "+q+" "+it, "green");
	if(q > ihave) {
		if(my_meat() < historical_price(it))
			abort("Running out of meat! Time to take some out of the closet...");
		if(!purchase(q, it))
			return false;     // Try again with another item since prices were wrong.
	}
	if(it == $item[scroll of drastic healing])
		set_property("_meatperhp", to_string(historical_price(it)/ (my_maxhp() - my_hp()+.001)));
	else if(heal[it].avehp > 0 && heal[it].avemp == 0 && !beset($effect[Beaten Up]))
		set_property("_meatperhp", to_string(historical_price(it)/ heal[it].avehp));
	use_inv(min(q, available_amount(it)), it, amount);
	return true;
}

// This will tell how much meat it would cost to restore an amount of mp, based on percentage of the cost to bulk
// restore 25% of max MP. Used to figure out if a skill should be used in mall_heal() and cheapest_besteup().
int mp_to_meat(int amount) {
	if(amount == 0) return 0;
	item best = best_mall(my_maxmp()*.25, "MP");
	int price = ceil(historical_price(best) * mall_quant(best, amount, "MP"));
	if(Verbosity > 1) print("Mall price to restore "+amount+"MP is "+price+" meat.", "blue");
	return price;
}

// This will handle all item based healing outside of ronin/hardcore. 
// It will heal from the mall using the best value for restoratives.
boolean mall_heal(int target, string type) {
	if(start_type == "MP" && target < mp_target)
		target = mp_target;
	int amount;
	item best_item;			// This is the best mall value for healing.
	float q_item;			// This is the number of that item to use.
	skill best_skill;	// This is the skill that would be used to heal HP if chosen.
	int q_skill;		// This is the number of times that skill would be cast to heal HP.
	int old = 0;
	repeat {
		if(type == "HP") {
			amount = target - my_hp();
			best_skill = find_cheapest_skill(target);
			q_skill = cast_quant(best_skill, target).ceil();
		} else
			amount = target - my_mp();
		best_item = best_mall(amount, type);
		q_item = mall_quant(best_item, amount, type).ceil();
		if(q_item < 1)
			q_item = 1;
		if(type == "HP" && best_skill != $skill[none] && q_skill > 0
		  && mp_to_meat(cast_quant_total(best_skill, target).ceil() * skills[best_skill].mp) <= q_item * historical_price(best_item)) {
			if(Verbosity > 1) print("Cast a healing skill.", "blue");
			if(my_mp() >= skills[best_skill].mp * q_skill)
				cast(q_skill, best_skill);
			else {
				mall_heal(skills[best_skill].mp * q_skill, "MP");
				old = old - 1; 	// mp restoration may have restored hp. Do another iteration and recalc
			}
		} else if(best_item == null) {
			if(Verbosity > 1) print("Restoring with Doc Galaktik", "blue");
			galaktik(amount, true, type);
		} else if(!use_mall(q_item, best_item, target)) {
			if(Verbosity > 1) print("Failed to use an item from the mall.", "red");
			old = old -1;  // If no item was used, this becomes a do-over.
		}
		if(Verbosity > 1) print("Current HP: "+my_hp()+", MP: "+ my_mp(), "blue");
		// Now check for success or critical failure
		if(type == "HP")
			switch {
			case my_hp() >= target:
			case target < my_maxhp() && my_hp() >= target * .95: 	// Success!
				return true;
			case my_hp() > old: 		// Need to keep restoring.
				old = my_hp();
				break;
			case my_hp() < old:			// Either failed to restore twice or actually lost HP! FAIL!
				return false;
			default: 		// my_hp() == old: Failed to restore HP once. Don't let it happen twice in a row.
				old = old +1;
			}
		else // Type == "MP"
			switch {
			case my_mp() >= target: 	// Success!
				return true;
			case my_mp() > old: 		// Need to keep restoring.
				old = my_mp();
				break;
			case my_mp() < old:			// Either failed to restore twice or actually lost MP! FAIL!
				return false;
			default: 		// my_mp() == old: Failed to restore MP once. Don't let it happen twice in a row.
				old = old +1;
			}
	} until(false);
	return false;
}

// This returns meat per mp in hardcore. Use with: set_property("_meatpermp", meatpermp());
string meatpermp() {
	switch {
	case zombie:
		return (have_skill($skill[summon horde]) ? "80.0" : "100.0");
	case buy_mmj:
		return to_string(100.0/ heal[$item[magical mystery juice]].avemp);
	case black_market_available() && !bees:
		return to_string(80.0/ heal[$item[black cherry soda]].avemp);
	case dispensary_available() && !bees:
		return to_string(80.0/ heal[$item[knob goblin seltzer]].avemp);
	case white_citadel_available():
		return to_string(80.0/ heal[$item[Regular Cloaca Cola]].avemp);
	case galaktik_cures_discounted():
		return "12.0";
	}
	return "17.0";
}

// Returns best value to purchase HP in Hardcore
float meatperhp() {
	if(zombie)
		return (100.0 / (my_maxhp() / (have_skill($skill[summon horde]) ? 8 : 10)));
	if(galaktik_cures_discounted() && contains_text(hpAutoRecoveryItems, "curative nostrum"))
		return 6.0;
	return 60.0/ heal[$item[Doc Galaktik's Ailment Ointment]].avehp;
}

// This will set _meatperhp and _meatpermp, considering the possibility of healing with skills.
void meatper() {
	populate_skills(hp_target);
	if(mallcore)
		best_mall(my_maxmp()*1.25, "MP"); 	// This function will set _meatpermp
	else set_property("_meatpermp", meatpermp());
	// Now find _meatperhp
	float item_mph, skill_mph;
	skill best_skill = find_cheapest_skill(my_maxhp()*1.25);
	if(best_skill == $skill[none])
		skill_mph = 987654321.0;
	else if(best_skill == $skill[Cannelloni Cocoon] || best_skill == $skill[Shake It Off])
		skill_mph = skills[best_skill].mp * get_property("_meatpermp").to_float() / (my_maxhp() * .75);
	else skill_mph = skills[best_skill].mp * get_property("_meatpermp").to_float() / skills[best_skill].ave;
	if(mallcore) {
		item best_item = best_mall(my_maxhp()*1.25, "HP");
		if(best_item == $item[scroll of drastic healing])
			item_mph = historical_price(best_item)/ (my_maxhp()* .75);
		else item_mph = historical_price(best_item)/ heal[best_item].avehp;
	} else
		item_mph = meatperhp();
	set_property("_meatperhp", to_string(max(skill_mph < item_mph ? skill_mph : item_mph, 0.001)));
}

// It is non-trivial to decides if nuns should be used to restore HP. Decides how much nuns should be used.
// During the IsleWar, a frat boy cannot access the zone, if he hasn't killed 192 hippies. 
// Returns true to end all HP recovery or false if more HP recovery is needed.
boolean visit_nuns(int target, string type) {
	void go_nuns(int x) {
		if(get_property("warProgress") != "finished" && to_int(get_property("hippiesDefeated")) < 192
		  && string_modifier("Outfit") == "Frat Warrior Fatigues") {
				equip($slot[pants], $item[none]);
				for i from 1 upto x
					cli_execute("nuns");
				equip($item[distressed denim pants]);
				return;
		}
		for i from 1 upto x
			cli_execute("nuns");
	}
	
	int visits_left = 3 - get_property("nunsVisits").to_int();
	if(visits_left < 1) return false;
	if(type == "MP" && mpAutoRecoveryItems.contains_text("visit the nuns") && get_property("sidequestNunsCompleted") == "fratboy") {
		if(my_maxmp() <= 1100) {
			if(my_mp() < my_maxmp() /8.0) 	// Nuns are only used if they'll give LOTS of mp.
				go_nuns(1);
		} else if(my_maxmp() - my_mp() >= 1000) {
			int visits = min(visits_left, floor((target - my_mp()) / 1000));
			if(visits == 0) visits = 1;
			go_nuns(visits);
		}
		return (my_mp() >= target);
	}
	if(type == "HP" && hpAutoRecoveryItems.contains_text("visit the nuns") && get_property("sidequestNunsCompleted") == "hippy") {
		if(my_maxhp() < 1600 && my_hp() < my_maxhp() /6.0) {
			go_nuns(1);
		} else if(target - my_hp() >= 1000) {
			float visits = (target - my_hp()) / 1000.0;
			if(visits - visits.floor() > .8) visits = min(visits.ceil(), visits_left);
				else visits = min(visits.floor(), visits_left);
			go_nuns(visits);
		}
		return (my_hp() >= target);
	}
	return false;
}

// This handles all visits to the hot tub, including getting the VIP Key out of Hangks.
boolean hot_tub() {
	if(have_effect($effect[Once-Cursed]) > 0 || have_effect($effect[Twice-Cursed]) > 0 || have_effect($effect[Thrice-Cursed]) > 0) return false;
	if(DontUseHotTub || (in_bad_moon() && get_property("kingLiberated") == "false") 
	  || available_amount($item[Clan VIP Lounge key]) == 0 || to_int(get_property("_hotTubSoaks")) >4
	   || my_location() == $location[The Slime Tube])
		return false;
	if(item_amount($item[Clan VIP Lounge key]) < 1)
		retrieve_item(1, $item[Clan VIP Lounge key]);
	cli_execute("soak");
	return true;
}

// Shall I restore HP with the Hot Tub? Note that as adventures run out, it becomes more important to use up soaks
boolean use_hot_tub() {
	int hotTubSoaks = get_property("_hotTubSoaks").to_int();
	if(hotTubSoaks > 4) return false;
	if(my_hp() < my_maxhp() /8) return hot_tub();
	int expec_adv = my_adventures() + 3.5 * (fullness_limit() - my_fullness()) 
	  + 3.5 * (inebriety_limit() - my_inebriety());
	if(spleenfam) expec_adv += (((spleen_limit() - my_spleen_use()) / 4) * 1.88);
	if(expec_adv < 10 * (5 - hotTubSoaks))
		return hot_tub();
	return false;
}

// Can I restore MP with the April Shower?
boolean use_april_shower() {
	if(available_amount($item[Clan VIP Lounge key]) == 0 || to_boolean(get_property("_aprilShower"))
	  || (in_bad_moon() && !can_interact()))
		return false;
	switch(get_property("baleUr_AprilShower")) {
	case "hardcore": return !can_interact();
	case "aftercore": return can_interact();
	case "always": return true;
	}
	return false;
}

// This will return all restoratives from inventory which are not excessive, sorted by strongest first.
// type is "HP" or "MP". This is only for hardcore/ronin usage, otherwise price is more important.
// This will also check six-pack of New Cloaca-Cola and palm fronds in case they are latent restoratives.
// This will not choose any item that heals ALL hp because those are too valuble to use casually.
// Also, items that restore from beaten up are not chosen by this function if the character has no tongue skill.
item [int] choose_inventory(string type) {
	item [int] options;				// This will be a list of all options for healing.
	if(type == "HP") {				// This will collect the HP type restoratives in inventory.
		int max_heal = my_maxhp() - my_hp();	// Only restoratives that won't overheal will be accepted.
		foreach key, value in heal
			switch(key) {
			case $item[personal massager]: 	// personal massagers won't work if you aren't beaten up.
			case $item[scented massage oil]:
			case $item[Medicinal Herb's medicinal herbs]:
			case $item[scroll of drastic healing]:
				break;		// Don't count full healing items. They're accounted for later.
			case $item[plump juicy grub]: 
				if(beset($effect[Form of...Bird!]) && item_amount(key) > 0)
					options[count(options)] = key;
				break;
			case $item[tiny house]:
			case $item[forest tears]: 	// Save unbeaters if character lacks a tongue skill
				if(tongue && item_amount(key)>0 && value.maxhp *.90 <= max_heal)
					options[count(options)] = key;
				break;
			case $item[Palm frond]: // Only use these if there is at least 2.
			case $item[mummy wrapping]:
				if(item_amount(key)>1 && value.maxhp *.90 <= max_heal)
					options[count(options)] = key;
				break;
			default: 
				if(item_amount(key)>0 && value.maxhp *.90 <= max_heal && value.maxhp >0)
					options[count(options)] = key;
			}
		sort options by -heal[value].maxhp;
	} else {					// This will collect the MP type restoratives in inventory.
		int max_heal = my_maxmp() - my_mp();	// Only restoratives that won't overheal will be accepted.
		foreach key, value in heal
			switch(key) {
			case $item[personal massager]: 	// personal massagers won't work if you aren't beaten up.
				break;
			case $item[Delicious shimmering moth]:
				if(beset($effect[Form of...Bird!]) && item_amount(key) > 0)
					options[count(options)] = key;
				break;
			case $item[tiny house]: 	// Save unbeaters if character lacks a tongue skill
				if(tongue && item_amount(key)>0 && value.maxmp *.90 <= max_heal)
					options[count(options)] = key;
				break;
			case $item[Palm frond]: // Only use these if there are at least 2.
				if(item_amount(key)>1 && value.maxmp *.90 <= max_heal)
					options[count(options)] = key;
				break;
			default:
				if(item_amount(key)>0 && value.maxmp *.90 <= max_heal && value.maxmp >0)
					options[count(options)] = key;
			}
		if(item_amount($item[New Cloaca-Cola]) < 1 && item_amount($item[six-pack of New Cloaca-Cola]) > 0
		  && heal[ $item[New Cloaca-Cola] ].maxmp *.90 <= max_heal)
			options[count(options)] = $item[New Cloaca-Cola];
		sort options by -heal[value].maxmp;
	}
	return options;
}

// This is the most that can be healed with restoratives in inventory. Don't include shadow healing or reserve.
int max_heal(item [int] options) {
	// hold is the amount to hold in reserve for whatever reason.
	int healwith_this(item this, int hold) {
		int this_many = item_amount(this) - hold;
		if(this_many <= 0) return 0;
		if((this == $item[Palm frond] || this == $item[mummy wrapping]) && this_many %2 == 1)
			this_many = this_many -1;
		// Don't over-restore!
		this_many = min(this_many, inv_quant(this, my_maxhp() - my_hp(), "HP"));
		return ceil(heal[this].avehp * this_many);
	}

	int total_heal = 0;
	foreach key, it in options
		switch(it) {
		case $item[red pixel potion]: 
			total_heal = total_heal + healwith_this(it, rpp);
			break;
		case $item[gauze garter]:
			total_heal = total_heal + healwith_this(it, gg);
			break;
		case $item[filthy poultice]:
			total_heal = total_heal + healwith_this(it, fp);
			break;
		default:
			total_heal = total_heal + healwith_this(it, it == reserve ? 1 : 0);
		}
	return total_heal;
}

// Restore mp from items in inventory.
boolean inv_mp_restore(int target) {
	if(Verbosity > 1) print("Try to heal MP from inventory.", "blue");
	if(beset($effect[Form of...Bird!]) && item_amount($item[Delicious shimmering moth]) > 0 
	  && heal[$item[Delicious shimmering moth]].avemp* BirdThreshold + my_mp() <= my_maxmp())
  		use(inv_quant($item[Delicious shimmering moth], target- my_mp(), "MP").max(1), $item[Delicious shimmering moth]);
	if(my_mp() >= target) return true;
	item [int] options = choose_inventory("MP");
	int q;
	boolean done;
	repeat {
		done = true;
		for i from 0 upto count(options)-1 {
			q = inv_quant(options[i], target- my_mp(), "MP");
			if(q>0) {
				use_inv(q, options[i], target);
				if(my_mp() >= target) return true;
				done = false;
			}
		}
	} until(done);
	return false;
}

// At the very end, MP needs to be purchased with meat. Figure out how to do this most efficiently.
boolean purchase_mp(int target) {
	if(!buy_npc) return false;
	if(my_mp() >= target) return true;
	int old_mp, cost;
	item best_buy = null;
	boolean fizzy = contains_text(mpAutoRecoveryItems, "fizzy invigorating tonic"); // Can use Doc Galaktik?
	repeat {
		old_mp = my_mp();
		if(buy_mmj && my_meat() >= 100) {
			best_buy = $item[magical mystery juice];
			cost = 100;
		} else if(my_meat() >= 80 && 6 + my_mp() <= my_maxmp() || !fizzy) {
			if(black_market_available() && !bees)
				best_buy = $item[black cherry soda];
			else if(dispensary_available() && !bees)
				best_buy = $item[knob goblin seltzer];
			else if(white_citadel_available())
				best_buy = $item[Regular Cloaca Cola];
			else best_buy = null;
			cost = 80;
		} else best_buy = null;
		if(best_buy != null) {
			int q = ceil((target - my_mp()) / heal[best_buy].avemp);
			if(q == 0) q = 1;
			if(my_meat()< q * cost)
				q = floor(my_meat()/cost);
			purchase(q, best_buy); 	// If we don't have anything to use, then we're done.
			q = min(q, for_use(best_buy));
			use(q, best_buy);
		} else if(fizzy) {
			// Let's not heal all the way to mp_target if not required -- expensive!
			if(start_type == "MP")
				target = objective == 0 ? min(target *.9, mp_trigger) : objective;
				// In the case that objective !=0, target is lowered to original minimum
			if(target <= my_mp()) return true;
			galaktik(target - my_mp(), true, "MP");
		}
	} until(old_mp >= my_mp() || my_mp() >= target);
	set_property("_meatpermp", meatpermp());
	if(my_mp() < target) {
		if(my_meat() >= 80 && best_buy != null)
			print("Cannot spend meat to fully restore MP! Failed to use "+best_buy+" for some reason.", "red");
		else if(!fizzy && ((galaktik_cures_discounted() && my_meat() > 11)|| my_meat() > 16))
			print("Cannot restore MP because fizzy invigorating tonic is disabled!", "red");
		else print("Insufficient meat to fully restore MP without wasting restoratives!", "red");
	}
	return (my_mp() >= target);
}

boolean lure_minion(int target) {
	if(have_skill($skill[Lure Minions])) {
		if(Verbosity > 2) print("Need to Lure Minions with Brains");
		// Need to keep enough brains for today and half of tomorrow.
		int brains_needed = ceil(fullness_limit() * 1.5) - my_fullness();
		int check_brains(int brains) {
			if(brains_needed == 0) return brains;
			int temp = max(brains - brains_needed, 0);
			brains_needed = max(brains_needed - brains, 0);
			return temp;
		}
		boolean exchanged = false;
		boolean lure(int x, int type) {  // type is both choice and number of minions per brain, up to 3.
			// How many times do I do this to reach target?
			x = min(ceil(to_float(target - my_mp()) / type), x);
			if(Verbosity > 2) print("Using "+x+" brains of level "+ type);
			if(x > 0) {
				if(!exchanged) // Start choice adventure first time only
					visit_url("skills.php?pwd&action=Skillz&whichskill=12002&skillform=Use+Skill&quantity=1");
				visit_url("choice.php?pwd&whichchoice=599&option="+type+"&quantity="+ x);
				exchanged = true;
			}
			return my_mp() >= target;
		}
		check_brains(item_amount($item[hunter brain]));
		check_brains(item_amount($item[boss brain]));
		// Count hunter and boss brains, but do not trade them, so number need not be remembered
		int spare_good = check_brains(item_amount($item[good brain]));
		int spare_decent = check_brains(item_amount($item[decent brain]));
		int spare_crappy = check_brains(item_amount($item[crappy brain]));
		// Reserve them in order from best to worst. Then trade them worst first. Stop once one returns true.
		if(lure(spare_crappy, 1) || lure(spare_decent, 2) || lure(spare_good, 3)) {}
		// Finish choice adventure if started
		if(exchanged) visit_url("choice.php?pwd&whichchoice=599&option=5");
		return my_mp() >= target;
	}
	if(Verbosity > 2) print("Don't know how to Lure Minions");
	return false;
}

boolean summon_minion(int target) {
	if(have_skill($skill[Summon Minion])) {
		if(Verbosity > 2) print("Need to Summon Minions with Meat");
		int x = target - my_mp();
		// Never use Summon Minion if you have Summon Horde because +20% combats could cause trouble
		if(have_skill($skill[Summon Horde])) {
			x = ceil(x / 12.0);
			x = min(my_meat() / 1000, x);
			if(Verbosity > 2) print("Summoning a horde "+ x+" times");
			if(x > 0) {
				visit_url("skills.php?pwd&action=Skillz&whichskill=12026&skillform=Use+Skill&quantity=1");
				for cast from 1 to x
					visit_url("choice.php?pwd&whichchoice=601&option=1");
				visit_url("choice.php?pwd&whichchoice=601&option=2");
			}
		} else {
			x = min(my_meat() / 100, x);
			if(Verbosity > 2) print("Summoning "+x+" minions");
			if(x > 0) {
				visit_url("skills.php?pwd&action=Skillz&whichskill=12021&skillform=Use+Skill&quantity=1");
				visit_url("choice.php?pwd&whichchoice=600&option=1&quantity=" + x);
				visit_url("choice.php?pwd&whichchoice=600&option=2");
			}
		}
	} else if(Verbosity > 2) print("Don't know how to Summon Minions");
	return my_mp() >= target;
}

// This restores mp, first from nuns (if completed as fratboy), then Oscus' Soda, then free disco rests,
// then inventory, then purchasing as necessary.
boolean mp_heal(int target){
	if(zombie) {
		if(Verbosity > 0) print("Restoring Horde! Currently at "+ my_hp()+ " of " + my_maxhp()+ " HP, "+ my_mp()+ " Horde, current meat: "+my_meat()+" ... Target Horde = "+ target+ ".", "#33CCCC");
		return lure_minion(target) || summon_minion(target);
	}
	if(target > my_maxmp())
		target = my_maxmp();
	if(Verbosity > 0) print("Restoring MP! Currently at "+ my_hp()+ " of " + my_maxhp()+ " HP, "+ my_mp()+ " of " + my_maxmp()+ " MP, current meat: "+my_meat()+" ... Target MP = "+ target+ ".", "#33CCCC");
	if(item_amount($item[Platinum Yendorian Express Card])>0 && get_property("expressCardUsed") == "false"
	  && my_mp() < (my_maxmp() /9) && contains_text(mpAutoRecoveryItems, "platinum yendorian express card"))
		use(1, $item[Platinum Yendorian Express Card]); 	// Yendorian Express Card is only used if it'll give OODLES of mp!
	if(use_april_shower() && (my_mp() + 999 < my_maxmp() || my_mp() * 8 < my_maxmp()))
		cli_execute("shower hot");
	if(visit_nuns(target, "MP")) return true;	// Nuns are only used if they'll give LOTS of mp.
	if(item_amount($item[Oscus's neverending soda])>0 && get_property("oscusSodaUsed") == "false"
	  && (my_mp()+300 <= my_maxmp() || my_mp() < my_maxmp()/8.0) && contains_text(mpAutoRecoveryItems, "neverending soda"))
		use(1, $item[Oscus's neverending soda]);
	if(beset($effect[Form of...Bird!]) && !mallcore && item_amount($item[Delicious shimmering moth]) > 0 
	  && heal[$item[Delicious shimmering moth]].avemp* BirdThreshold + my_mp() <= my_maxmp())
  		use(inv_quant($item[Delicious shimmering moth], target- my_mp(), "MP").max(1), $item[Delicious shimmering moth]);
	if(contains_text(mpAutoRecoveryItems, "free disco rest") 
	  && (numeric_modifier("Base Resting MP") >= 10 || bees))
		while(to_int(get_property("timesRested")) < disco  && my_mp()<target
		  && my_maxmp() - my_mp() >=rest_mp && (DiscoResting != "hp" || (my_maxhp() - my_hp())/2 >= rest_hp))
			cli_execute("rest");
	if(my_mp() >= target) return true;
	if(mallcore) {
		if(mall_heal(target, "MP")) {
			if(Verbosity > 1) print("My meat: "+my_meat()+". Should be successfully healed...", "green");
			return true;
		} else {
			if(Verbosity > 1) print("My meat: "+my_meat()+". Sadly I think healing failed...", "red");
			return false;
		}
	}	// If in mallcore, that took care of everything.
	if(inv_mp_restore(target)) return true;		// Are inventory items enough?
	// Should I use the Clan Sofa? Only hit the server to look for the sofa if preferences say to rest there.
	if(contains_text(mpAutoRecoveryItems, "sleep on your clan sofa") && my_level()*5 > rest_mp && my_adventures() > 0
	  && contains_text(visit_url("clan_rumpus.php"), "otherimages/clanhall/rump5_3.gif")) {
		if((my_maxmp() - my_mp()) >=my_level()*5 && (my_maxhp() - my_hp()) >= my_level()*5) {
			int x = (target - my_mp())/ (my_level()*5);
			while(x*my_level()*5 +my_hp() > my_maxhp())
				x = x - 1;
			x = min(x, my_adventures());
			if(x > 0)
				cli_execute("sofa "+x);  //visit_url("clan_rumpus.php?preaction=nap&numturns="+ x + "&pwd");
		}
	} else if(my_adventures() > 0 && contains_text(mpAutoRecoveryItems, "rest at your campground"))
		while(my_mp() < target && my_mp() < my_maxmp() &&(my_maxmp() - my_mp() >=rest_mp && my_maxhp() - my_hp() >= rest_hp || AlwaysContinue) && my_adventures() > 0)
			cli_execute("rest");			// This will waste adventures resting if set in HP/MP Usage.
	if(my_mp() >= target) return true;
	if(Verbosity > 1) print("Last attempt to purchase MP with meat.", "blue");
	return purchase_mp(target);		// Restoration has failed, so lets restore mp with meat.
}

// Items to restore HP are insufficient to the task. Try to fully restore HP with a full healing item or cocoon.
boolean fullheal() {
	if(Verbosity > 2) print("Trying to fullheal", "#002080");
	skill cheap_skill = find_cheapest_skill(my_maxhp());
	int galaktik_price = galaktik(my_maxhp() - my_hp(), false, "HP");
	string select_method() {
		switch {
		case beset($effect[Form of...Bird!]) && item_amount($item[plump juicy grub]) > 0 
		  && heal[$item[plump juicy grub]].avehp + my_hp() >= my_maxhp() && !bees:
			return use(1, $item[plump juicy grub]);
		case use_herb && my_spleen_use() < (spleenfam? (spleen_limit()%4): spleen_limit())
		  && (item_amount($item[Medicinal Herb's medicinal herbs]) >0 || (my_meat() >=100 && my_primestat() == $stat[muscle] && buy_npc)):
			if(item_amount($item[Medicinal Herb's medicinal herbs]) < 1)
				retrieve_item(1, $item[Medicinal Herb's medicinal herbs]);
			return use(1, $item[Medicinal Herb's medicinal herbs]);
		case skills[cheap_skill].ave + my_hp() >= my_maxhp() && (my_mp() >= skills[cheap_skill].mp
		  || (my_maxmp() >= skills[cheap_skill].mp && mp_heal(skills[cheap_skill].mp))):
			if(my_hp() >= my_maxhp()) return true;
			return cast(1, cheap_skill);
		case galaktik_price <= 100 && my_meat() >= galaktik_price && !zombie:
			return galaktik(my_maxhp() - my_hp(), true, "HP");
		case item_amount($item[scroll of drastic healing]) >0 && contains_text(hpAutoRecoveryItems, "drastic healing"):
			return use(1, $item[scroll of drastic healing]);
		case contains_text(hpAutoRecoveryItems, "scented massage oil") 
		  && item_amount($item[scented massage oil]) >0:
			return use(1, $item[scented massage oil]);
		}
		// Select something which is just too big for normal use
		foreach key, value in heal
			if(item_amount(key) >0 && value.avehp > my_maxhp() - my_hp() && value.maxhp > 120 && my_maxhp() > 100 && my_hp() < my_maxhp() / 5)
				return use(1, key);
		return false;
	} select_method();
	return (my_hp() == my_maxhp());
}

// Restore hp from items in inventory. Note that full heal items are used first and to conserve them
// they're only used if necessary or hp are particularly low. If needed, full heal items will also be
// used at the end because there wasn't enough of other items.
boolean inv_hp_restore(int target, item [int] options) {
	if(Verbosity > 1) print("Try to heal HP from inventory.", "blue");
	if(my_hp() < ceil(my_maxhp() / 6.0) || max_heal(options) < target - my_hp())
		if(fullheal()) return true;
	if(beset($effect[Form of...Bird!]) && item_amount($item[plump juicy grub]) > 0  && !bees
	  && heal[$item[plump juicy grub]].avehp * BirdThreshold + my_hp() <= my_maxhp())
  		use(inv_quant($item[plump juicy grub], target- my_hp(), "HP").max(1), $item[plump juicy grub]);
	if(my_hp()>=target) return true;
	int q;
	boolean done;
	repeat {
		done = true;
		for i from 0 upto count(options)-1 {
			q = inv_quant(options[i], target- my_hp(), "HP");
			if(q>0) {
				use_inv(q, options[i]);
				if(my_hp() >= target) return true;
				done = false;
			}
		}
	} until(done);
	// If that didn't do the job, then I'm probably close so let's check.
	int quantity_limt(item this) {
		int limit = inv_quant(this, target- my_hp(), "HP");
		if(limit > 0) return limit;
		if(heal[this].avemp *.95 + my_mp() > my_maxmp()) return 0;
		return 1;
	}
	if(my_hp() < target*.9 || target == my_maxhp())
		for i from count(options)-1 downto 0
			if(heal[options[i]].avehp*.85 <= my_maxhp()- my_hp() && options[i].for_use() > 0) {
				q = quantity_limt(options[i]);
				if(q>0) {
					use_inv(q, options[i]);
					if(my_hp() >= target *.90) return true;
				}
			}
	return false;
}

// If out of ronin/hardcore this will determine the method of recovering from beaten up that costs least meat.
boolean cheapest_beatup() {
	int [string] price;
	item test;
	foreach doodad in $strings[Space Tours Tripple, tiny house, forest tears, Soft green echo eyedrop antidote] {
		test = doodad.to_item();
		if(historical_age(test) > 2) price[doodad] = mall_price(test); 	// Ensure price is good
		else price[doodad] = historical_price(test);
	}
	if(have_skill($skill[Tongue of the Walrus]) && my_maxmp() >= skills[$skill[Tongue of the Walrus]].mp)
		price["Tongue of the Walrus"] = mp_to_meat(skills[$skill[Tongue of the Walrus]].mp);
	string best = "";
	price[best] = 999999999;
	foreach it in price
		if(price[it] < price[best])
			best = it;
	switch (best) {
	case "":
		break;
	case "Tongue of the Walrus":
		if(my_mp() >= skills[$skill[Tongue of the Walrus]].mp || mp_heal(skills[$skill[Tongue of the Walrus]].mp))
			cast(1, $skill[Tongue of the Walrus]);
		break;
	default:
		use_mall(1, best.to_item(), 1);
	}
	if(!beset($effect[Beaten Up])) {			// If cured, then maxhp and maxmp have changed!
		set_autohealing();
		return true;
	}
	print("Unable to cure beaten up! Go adventure someplace wussier.", "red");
	return false;
}

// This cures beaten up. Preferably with items if available, then tongues.
// Finally, if that doesn't work, it will use softs ONLY if the character does not have Olfaction.
boolean cure_beatenup(int target){
	if(Verbosity > 0) print("You've had the crap beaten out of you... attempting to find some more crap.", "#33CCCC");
	if(hot_tub()) {			// If cured, then maxhp and maxmp have changed!
		set_autohealing();
		return true;
	}
	
	// Resting restores Beaten Up!
	if(contains_text(mpAutoRecoveryItems, "free disco rest") && (numeric_modifier("Base Resting MP") >= 10 || bees)
	  && to_int(get_property("timesRested")) < disco && my_maxmp() - my_mp() >= rest_mp)
		return cli_execute("rest");
	
	populate_skills(1);
	
	// Sneaky Pete has only one trick, but it does EVERYTHING. Check again for the strange case of high HP beaten up later.
	if(have_skill($skill[Shake It Off]) && my_hp() < my_maxhp() / 5 && my_maxmp() >= skills[$skill[Shake It Off]].mp
		  && (my_mp() >= skills[$skill[Shake It Off]].mp || mp_heal(skills[$skill[Shake It Off]].mp)))
			return cast(1, $skill[Shake It Off]);
	
	// Zombie Master recovery
	if(have_skill($skill[Devour Minions]))
		return cast(1, $skill[Bite Minion]);

	if(mallcore)  	// Switch to mallcore mode if out of ronin.
		return cheapest_beatup();
	cli_execute("whatif uneffect beaten up; quiet");
	int maxhp = numeric_modifier("_spec", "Buffed HP Maximum");
	int maxmp = numeric_modifier("_spec", "Buffed MP Maximum");
	// Test a restorative to see if an average return will over restore. returns TRUE if it doesn't waste.
	boolean test_waste(item healing_item) {
		return heal[healing_item].avehp <= maxhp - my_hp() && heal[healing_item].avemp <= maxmp - my_mp();
	}

	if(target == 0)				// This matters for Walrus vs Otter calculation
		target = ceil(maxhp * to_float(get_property("hpAutoRecoveryTarget")));
	if(tongue) {			// If the character has a tongue skill, I'm pickier about using tiny houses.
		switch {
		case item_amount($item[personal massager]) >0:
			use(1, $item[personal massager]); break;	// If beaten up outside of battle, it didn't auto-use!
		case item_amount($item[Space Tours Tripple]) > 0:
			use(1, $item[Space Tours Tripple]);
		case item_amount($item[forest tears]) >0 && test_waste($item[forest tears]):
			use(1, $item[forest tears]); break;
		case item_amount($item[tiny house]) >0 && test_waste($item[tiny house]):
			use(1, $item[tiny house]); break;
		}
	} else {
		switch {
		case item_amount($item[personal massager]) >0:
			use(1, $item[personal massager]); break;	// If beaten up outside of battle, it didn't auto-use!
		case item_amount($item[Space Tours Tripple]) > 0:
			use(1, $item[Space Tours Tripple]);
		case item_amount($item[tiny house]) >0 && test_waste($item[tiny house]):
			use(1, $item[tiny house]); break;
		case item_amount($item[forest tears]) >0:
			use(1, $item[forest tears]); break;
		case item_amount($item[tiny house]) >0:		// Desperately use tiny house even if healing is wasted
			use(1, $item[tiny house]); break;
		}
	}
	
	// Sneaky Pete has only one trick, but it does EVERYTHING! If HP is high and character is beaten up, it failed earlier
	if(have_skill($skill[Shake It Off]) && my_maxmp() >= skills[$skill[Shake It Off]].mp
		  && (my_mp() >= skills[$skill[Shake It Off]].mp || mp_heal(skills[$skill[Shake It Off]].mp)))
			return cast(1, $skill[Shake It Off]);
	
	if(beset($effect[Beaten Up]) && have_skill($skill[Tongue of the Walrus]) && my_maxmp() >= skills[$skill[Tongue of the Walrus]].mp
		  && (my_mp() >= skills[$skill[Tongue of the Walrus]].mp || mp_heal(skills[$skill[Tongue of the Walrus]].mp)))
			cast(1, $skill[Tongue of the Walrus]);
	if(beset($effect[Beaten Up]) && item_amount($item[Soft green echo eyedrop antidote])>1 
	  && !have_skill($skill[Transcendent Olfaction]))	// Don't use SGEEAs for this if you have Olfaction!
		cli_execute ("uneffect beaten up"); 		// Also, won't ever use last SGEEA.
	if(!beset($effect[Beaten Up])) {			// If cured, then maxhp and maxmp have changed!
		set_autohealing();
		return true;
	}
	
	// Resting restores Beaten Up! Use an action to do it if allowed
	if(my_adventures() > 0 && contains_text(hpAutoRecoveryItems, "rest at your campground"))
		return cli_execute("rest");
	
	print("Unable to cure beaten up! Go adventure someplace wussier.", "red");
	return false;
}

// This uses skills to restore HP!
boolean skill_restore(int target) {
	if(Verbosity > 1) print("Try to heal HP with skills.", "blue");
	int q;
	skill cheap_skill;
	int old = my_hp();
	repeat {
		cheap_skill = find_cheapest_skill(target);
		q = cast_quant(cheap_skill, target).floor();
		if(cheap_skill == $skill[none]) return false;
		if(!zombie) // Limit by maximum mp if not a Zombie
			q = min(q, floor(my_maxmp() / skills[cheap_skill].mp));
		if(q == 0) return false;
		if(meatperhp() * min(target - my_hp(), q*skills[cheap_skill].ave) < get_property("_meatpermp").to_float() * q*skills[cheap_skill].mp)
			return false;   // It would be cheaper to purchase ailment ointment at Doc Galaktik!
		if(my_mp() >= skills[cheap_skill].mp * q)
			cast(q, cheap_skill);
		else {
		if(Verbosity > 2) print("Need "+(skills[cheap_skill].mp * q)+" MP to cast that skill.");
			if(mp_heal(skills[cheap_skill].mp * q))
				old = old - 1; 	// mp restoration may have restored hp. Do another iteration and recalc
		}
		switch {
		case my_hp() >= target: 	// Success!
		case my_hp() >= target * .94 && target < my_maxhp() && objective == 0: 	// Save some mp if possible
			return true;
		case my_hp() > old: 		// Need to keep restoring.
			old = my_hp();
			break;
		case my_hp() < old:			// Either failed to restore twice or actually lost HP! FAIL!
			return false;
		default: 		// my_hp() == old: Failed to restore HP once. That's a bad sign, but I'll try again.
			old = old +1;
		}
	} until(false);
	return false;
}

// At the very end, HP needs to be purchased with meat. Figure out how to do this most efficiently.
boolean purchase_hp(int target) {
	if(!buy_npc) return false;
	if(objective == 0) {   // Let's not be stubborn. Lets save meat by getting close enough
		if(target * .9 > hp_trigger) {
			if(Verbosity > 0) print("Recovery target reduced to healing trigger ("+hp_trigger+")to conserve meat.", "#66CC00");
			target = hp_trigger + 1;
		} else target = max(hp_trigger, target * .9);
	} else if(target > objective)
		target = objective;		// In the case that objective !=0, target is lowered to original minimum
	while(my_meat() >= 60 && my_hp() < target && !zombie)
		if(galaktik_cures_discounted() && contains_text(hpAutoRecoveryItems, "curative nostrum")) {
			galaktik(target - my_hp(), true, "HP");
		} else if(my_meat() >= 60) {
			int q = floor((target - my_hp()) / 9.0);
			if(q == 0)
				q = 1;
			if(my_meat()< q * 60)
				q = floor(my_meat()/60.0);
			purchase(q, $item[Doc Galaktik's Ailment Ointment]);
			use(q, $item[Doc Galaktik's Ailment Ointment]);
		}
	if(my_meat() < 60 && my_hp() < target)
		print("Insufficient meat to fully restore HP without wasting restoratives!", "red");
	return (my_hp() >= target);
}

// This returns true if the character is currently mining
boolean noncom() {
	switch(my_location()) {
	#case $location[The Gummi Mine]:
	case $location[Itznotyerzitz Mine (in Disguise)]:
		if(string_modifier("outfit") == "Dwarvish War Uniform") return true;
	case $location[The Knob Shaft (Mining)]:
		return string_modifier("outfit") == "Mining Gear";
	case $location[Anemone Mine]:
		return have_equipped($item[Mer-kin digpick]);
	}
	return false;
}

// This restores hp. Firsts it cures beaten up. To heal hp it uses (in order):
// First nuns if completed as hippy, then from inventory, then skills, finally purchasing as necessary.
// Skills are after inventory because they consume a more valuable resource: mp
boolean hp_heal(int target){
	if(target > my_maxhp())
		target = my_maxhp();
	if(Verbosity > 0) print("Restoring HP! Currently at "+ my_hp()+ " of " + my_maxhp()+ " HP, "+ my_mp()+ " of " + my_maxmp()+ " MP, current meat: "+my_meat()+" ... Target HP = "+ target+ ".", "#66CC00");
	// First line of defense is plump juicy grubs. If ONE will do the job then do it!
	if(!mallcore && beset($effect[Form of...Bird!]) && item_amount($item[plump juicy grub]) > 0 
	  && heal[$item[plump juicy grub]].avehp + my_hp() >= my_maxhp()  && !bees
	  && heal[$item[plump juicy grub]].avehp * BirdThreshold + my_hp() <= my_maxhp()) {
		use(1, $item[plump juicy grub]);
		if(my_hp() >= target) return true;
	}
	
	populate_skills(target);
	skill cheap_skill = find_cheapest_skill(target);		// What is the cheapest skill to heal HP?
	// If MP runs low, mixed HP/MP items are frequently used, so check to see if we need MP first.
	int min_mp = mp_trigger;
	if(cheap_skill != $skill[none]) {
		if(!noncom()) {
			min_mp = min_mp + skills[cheap_skill].mp;
			if(min_mp > my_maxmp() *.75 && mp_trigger < my_maxmp() *.75) {
				min_mp = my_maxmp() * .75;
			} else if(min_mp > my_maxmp())
				min_mp = my_maxmp();
		}
		if(my_mp()< min_mp) {
			if(Verbosity > 2) print("Will need MP, so restoring it now to improve efficiency.", "green");
			mp_heal(min_mp);
			if(Verbosity > 2) print("MP restored. Returning to HP restoration.", "green");
		} 			// MP restored, get on with it.
	}
	
	// Let's not use the nuns if Caneloni Cocoon would be used later.
	boolean use_nuns() {
		if((have_skill($skill[Cannelloni Cocoon]) || have_skill($skill[Shake It Off])) && get_property("nunsVisits").to_int() * 1000 + my_hp() < my_maxhp())
			return false;
		return true;
	}
	if(my_hp() >= target || use_hot_tub() || (use_nuns() && visit_nuns(target, "HP")))
		return true; 	// Several full heals are tried in sequence. If any are true, then we're done
	if(mallcore) {
		if(mall_heal(target, "HP")) {
			if(Verbosity > 1) print("My meat: "+my_meat()+". Should be successfully healed...", "green");
			return true;
		} else {
			if(Verbosity > 1) print("My meat: "+my_meat()+". Sadly I think healing failed...", "red");
			return false;
		}
	}	// If out of ronin, that took care of everything.
	item [int] options = choose_inventory("HP");
	shadow_prep();		// Prepare for fighting shadow. Global vars rpp, gg, fp are set by this.
	boolean futile = max_heal(options) < target - my_hp();	// Can I heal with Inventory?
	cheap_skill = find_cheapest_skill(target);		// What is the cheapest skill to heal HP?
	if(futile) {
		if(fullheal()) return true;
		if(cheap_skill != $skill[none] && cast_quant(cheap_skill, target)>0) {
			// Inventory won't completely heal, so better to cast this skill BEFORE wasting a healing item
			if(my_mp()>= skills[cheap_skill].mp || ((my_maxhp() >= skills[cheap_skill].mp || zombie) && mp_heal(skills[cheap_skill].mp))) {
				if(my_hp() >= target) return true; // mp restoration may have restores hp
				cast(1, cheap_skill);
			}
			futile = max_heal(options) < target - my_hp();	// Recheck futility
		}
		if(my_hp() >= target) return true;
	}
	if(contains_text(hpAutoRecoveryItems, "free disco rest") 
	  && (numeric_modifier("Base Resting MP") >= 10 || bees))
		while(to_int(get_property("timesRested")) < disco  && my_hp()<target
		  && my_maxhp() - my_hp() >=rest_hp && (DiscoResting != "mp" || my_maxmp() - my_mp() >= rest_mp))
			cli_execute("rest");
	if(my_hp() >= target || inv_hp_restore(target, options))	// Heal with items from inventory
		return true;
	if(target - my_hp() < 10)			// There is so little to heal, it isn't worth casting a spell.
		return purchase_hp(target);
	if(skill_restore(target)) 			// Let's try to restore HP by casting skills.
		return true;
	// Should I use the Clan Sofa? Only hit the server to look for the sofa if preferences say to rest there.
	if(contains_text(hpAutoRecoveryItems, "sleep on your clan sofa") && my_level()*5 > rest_hp && my_adventures() > 0
	  && contains_text(visit_url("clan_rumpus.php"), "otherimages/clanhall/rump5_3.gif")) {
		if((my_maxmp() - my_mp()) >=my_level()*5 && (my_maxhp() - my_hp()) >= my_level()*5) {
			int x = (target - my_hp())/ (my_level()*5);
			while(x*my_level()*5 +my_mp() > my_maxmp())
				x = x - 1;
			x = min(x, my_adventures());
			if(x > 0)
				cli_execute("sofa "+x);
		} 
	} else if(my_adventures() > 0 && contains_text(hpAutoRecoveryItems, "rest at your campground"))
		while(my_hp() < target && my_hp() < my_maxhp() && (my_maxmp() - my_mp() >=rest_mp && my_maxhp() - my_hp() >= rest_hp || AlwaysContinue) && my_adventures() > 0)
			cli_execute("rest");			// This will waste adventures resting if set in HP/MP Usage.
	if((objective == 0 && my_hp() >= target*.9) || (objective !=0 && my_hp() >= objective))
		return true;
	if(Verbosity > 1) print("Last attempt to purchase HP with meat.", "blue");
	return purchase_hp(target);		// Restoration has failed, so lets try to restore hp with meat.
}

// This will cure poisoning. It will only fail if the character does not possess an antidote, or can't afford to buy one.
// It will also attempt to keep a few spare anti-anti-antidotes in inventory, for emergency in-combat use.
boolean unpoison() {
	if(zombie)		 // Zombie Masters don't stay poisoined and cannot purchase antidotes.
		return true;

	// Am I poisoned?
	boolean poisoned() {
		return beset($effects[Hardly Poisoned at All, A Little Bit Poisoned, Really Quite Poisoned,
			Somewhat Poisoned, Majorly Poisoned]);
	}
	// Won't purchase antidotes if not allowed to purchase from NPC stores.
	void acquire_antidote(int howmany) {
		if(howmany > item_amount($item[anti-anti-antidote]))
			retrieve_item(howmany, $item[anti-anti-antidote]);
	}
	
	if(poisoned()) {
		if(my_hp() < my_maxhp() /4) {
			if(!hot_tub())
				use(1, $item[anti-anti-antidote]);
		} else
			use(1, $item[anti-anti-antidote]);
		set_autohealing();
	}
	if(my_level() > 4 && buy_npc) 	// There's no reason to stockpile antidotes until level 5, minimum
		switch {
		case my_meat() > 6000: acquire_antidote(4);
			break;
		case my_meat() > 3000: acquire_antidote(3);
			break;
		case my_meat() > 1200: acquire_antidote(2);
			break;
		case my_meat() > 200:  acquire_antidote(1);
		}
	return !poisoned();
}

// If Hot Tub would be used by the script anyway, then lets use it to clear up your status!!
void cure_status() {
	if(!unpoison()) print("Can't cure poison! OOoch! It burns in my veins!", "red");
	if(get_property("removeMalignantEffects").to_boolean()) return;
	boolean skill_pop = false;
	boolean skill_cure(skill cure) {
		if(!skill_pop)
			skill_pop = populate_skills(hp_target);
		return cast(1, cure);
	}
	
	if(beset($effect[Temporary Amnesia]) && !use_hot_tub())
		print("You've got Temporary Amnesia. That's bad, but only you can decide if you want to use an SGEEA "
			+(available_amount($item[Clan VIP Lounge key]) == 0? "": "or dip in the Hot Tub ")
			+"to cure it.", "red");
	
	if(have_skill($skill[Devour Minions]) && beset($effects[Cunctatitis, Apathy, Tetanus, Barking Dogs, 
	  Turned Into a Skeleton, Sleepy, Apathy, All Covered In Whatsit, Flared Nostrils, Socialismydia]))
		skill_cure($skill[Bite Minion]);
	
	if(beset($effects[Apathy, Easily Embarrassed, Prestidigysfunction, Tenuous Grip on Reality, 
	  The Colors...])
	  && !use_hot_tub() && have_skill($skill[Disco Nap]) && have_skill($skill[Adventurer of Leisure]))
		skill_cure($skill[Disco Nap]);

	if(beset($effect[N-Spatial vision]) && my_location() == $location[Navigation]) {
		if(item_amount($item[bugbear purification pill]) > 0)
			use(1, $item[bugbear purification pill]);
		else if(!(have_skill($skill[Adventurer of Leisure]) && skill_cure($skill[Disco Nap])) && retrieve_item(1, $item[bugbear purification pill]))
			use(1, $item[bugbear purification pill]);
	}
	
	if(beset($effects[Cunctatitis, Tetanus, Socialismydia]) && !use_hot_tub()) {
		if(have_skill($skill[Disco Nap]) && have_skill($skill[Adventurer of Leisure]))
			skill_cure($skill[Disco Nap]);
		else if(item_amount($item[ancient Magi-Wipes]) > 0
		  && heal[$item[ancient Magi-Wipes]].avemp < my_maxmp() - my_mp())
			use(1, $item[ancient Magi-Wipes]);
	}

	if(beset($effects[Embarrassed, Sleepy]) && !use_hot_tub()
	  || (my_primestat() == $stat[Mysticality] && beset($effects[Confused, Light-Headed]))) {
		if(have_skill($skill[Disco Nap]))
			skill_cure($skill[Disco Nap]);
		else if(have_skill($skill[Disco Nap]) && have_skill($skill[Adventurer of Leisure]))
			skill_cure($skill[Disco Nap]);
		else if(!tongue && item_amount($item[tiny house]) > 0
		  && heal[$item[tiny house]].avemp < my_maxmp() - my_mp())
			use(1, $item[tiny house]);
	}
}

// What additional healing items should be purchased for potential combat use?
void choose_reserve_purch() {
	if(mallcore) {
		float best_value = 0;
		float value;
		foreach key, choice in heal
			if(is_tradeable(key) && key.combat && choice.minmp > 20) {
				if(historical_price(key) == 0) mall_price(key); // Ensure price is non-zero
				value = choice.avemp / historical_price(key);
				if(value > best_value) {
					reserve_purch = key;
					best_value = value;
				}
			}
		if(!buy_mmj && (item_amount($item[magical mystery juice]) > 2 && UseMmjStock)
		  && reserve_purch != $item[magical mystery juice]) {
			value = heal[$item[magical mystery juice]].avemp /100.0;
			if(value > best_value) {
				reserve_purch = $item[magical mystery juice];
				best_value = value;
			}
		}
		if(reserve_purch != null)
			reserve_num = ceil(100.0/heal[reserve_purch].minmp);
	} else if(buy_npc) {
		if(buy_mmj) {
			reserve_purch = $item[magical mystery juice];
		} else if(dispensary_available() && !bees)
			reserve_purch = $item[Knob Goblin seltzer];
		switch {
		case reserve_purch == null:
			break;
		case my_meat() > 6000: reserve_num = 3;
			break;
		case my_meat() > 2000: reserve_num = 2;
			break;
		case my_meat() > 280: reserve_num = 1;
		}
	} else reserve_purch = null;
}

// This will choose a healing item to hold in reserve for combat use. 
// Global variable reserve is set here and 1 of that item will not be used for healing.
void reserve_healing() {
	if(zombie) return;
	choose_reserve_purch();
	if(!mallcore && buy_npc) {
		// Try to be frugal and consider on-hand reserve if in hardcore/ronin.
		foreach key, value in heal {
			if(item_amount(key) > 0 && value.minmp > heal[reserve].minmp && key.combat)
				reserve = key;
		}
		if(reserve_purch == reserve || heal[reserve].minmp < heal[reserve_purch].minmp)
			reserve = null;
		if(reserve == null)
			reserve_num = reserve_num +1;
		else if(heal[reserve].minmp > 3* heal[reserve_purch].minmp)
			reserve_num = reserve_num -2;
		else if(heal[reserve].minmp > 2* heal[reserve_purch].minmp)
			reserve_num = reserve_num -1;
		if(reserve_num <0)
			reserve_num = 0;
	}
	int purch_have = item_amount(reserve_purch);
	if(reserve_purch == $item[magical mystery juice] && my_meat() < 100 * (reserve_num-purch_have))
		reserve_num = floor(reserve_num /100.0);
	else if (reserve_purch == $item[Knob Goblin seltzer] && my_meat() < 80 * (reserve_num-purch_have))
		reserve_num = floor(reserve_num /80.0);
	if(purch_have < reserve_num) {
		switch (reserve_purch) {
		case null: break;
		case $item[Knob Goblin seltzer]:
			if(!dispensary_available() || bees)
				break;
		case $item[magical mystery juice]:
		default:
			print("Purchasing some "+ to_plural(reserve_purch) + " for use as a combat restorative.", "blue");
			retrieve_item(reserve_num, reserve_purch);
		}
		set_property("_meatpermp", meatpermp());   // Access to MMJ or seltzer might have just changed.
	}
	purch_have = item_amount(reserve_purch);
	if(purch_have < reserve_num) {
		reserve_num = purch_have;
		if(purch_have <1) reserve_purch = null;
	}
}

// My rendition of zarqon's version checker
// checks script version once daily, returns empty string, OR div with update message inside
string check_version() {
	string soft = "Universal Recovery";
	string prop = "_version_BalesUniversalRecovery";
	int thread = 1780;
	int w; string page;
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
	switch(get_property(prop)) {
	case thisver: return "";
	case "":
		print("Checking for updates (running "+soft+" ver. "+thisver+")...");
		page = visit_url("http://kolmafia.us/showthread.php?t="+thread);
		matcher find_ver = create_matcher("<b>"+soft+" (.+?)</b>",page);
		if (!find_ver.find()) {
			print("Unable to load current version info.", "red");
			set_property(prop,thisver);
			return "";
		}
		w=19;
		set_property(prop,find_ver.group(1));
		default:
		if(sameornewer(thisver,get_property(prop))) {
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
		if(w > 0) wait(w);
		return "<div class='versioninfo'>"+msg+"</div>";
	}
	return "";
}

// Once per day check to see if the version is current, data is current and pricelist updating for mallcore mode
// Much of this routine is very much owed to zarqon
void daily_handling() {
	if(get_property("_version_BalesUniversalRecovery") == "") {
		// This is zarqon's automatic map updating: http://kolmafia.us/showthread.php?t=1515
		string curr = visit_url("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getver");
		if(!file_to_map(fname+".txt",heal) || count(heal) == 0
		  || (curr != "" && get_property(fname+".txt") != curr))
			get_newmap(curr);
		// If you're using scripts like this, you should automatically update prices from KoL's price list maintained by fewyn. 
		if(get_property("sharePriceData") == "false") {
			cli_execute("update prices http://kolmafia.us/scripts/updateprices.php?action=getmap");
			set_property("sharePriceData", "true");
		}
		// cli_execute("update prices http://nixietube.info/mallprices.txt"); # JasonHarper's price list is backup for kolmafia.us
		// Set _meatpermp and meatperhp today so they can be used by other scripts right away
		restore_values();
		meatper();
		if(svn_exists("mafiarecovery")) {
			cli_execute("svn update mafiarecovery");
			set_property("_version_BalesUniversalRecovery", thisver);
		}
		else check_version();
	}
}

void manaburn_healing() {
	if(!boris) return;
	float manaBurningThreshold = get_property("manaBurningThreshold").to_float();
	if(manaBurningThreshold < 0) return;
	int extra_mp = my_mp() - manaBurningThreshold * my_maxmp();
	if(extra_mp < 1 || my_hp() >= my_maxhp())
		return;
	
	int casts = min(extra_mp, (my_maxhp() - my_hp()) / 1.5);
	use_skill(casts, $skill[Laugh It Off]);
}

// Let's start restoring. This will cure poisoning, cure beaten up and finally heal HP or MP.
// Returns false if cannot fully heal.
boolean restore(string type, int amount) {
	daily_handling(); 	// This will do some stuff on the first run of the day
	if(Verbosity > 2) print("Calling Universal Recovery "+thisver+" for type="+type+", amount="+amount,"red");
	// If you are Unhydrated or mining, then only 1 HP is needed and status effects are irrelevant.
	// If you are Unhydrated or mining, then only 1 HP is needed, no MP necessary and status effects are irrelevant.
	if(amount == 0 && noncom()) {
		if(type == "MP") {
			if(Verbosity > 0) print("Restoring no MP since it is irrelevant here", "#66CC00");
			return true;
		}
		if(my_hp() < 1 && hp_trigger >= 0) {
			if(Verbosity > 0) print("Restoring only 1 HP since more is irrelevant here", "#66CC00");
			if(zombie)
				hp_heal(1);
			else
				galaktik(1, true, "HP");
		}
		return my_hp() > 0;
	}
	objective = amount;			// The global variable will inform other procedures of default if == 0.
	start_type = type; 			// To save me if hp recovery calls mp recovery.
	restore_values();
	if(!ignoreStatus) cure_status();
	reserve_healing();
	manaburn_healing();
	if(type == "MP") {
		if(objective == 0 && mp_trigger < 0) return true;
		if(!ignoreStatus && beset($effect[Beaten Up]) && objective == 0 && hp_trigger >= 0)
			cure_beatenup(objective);
		// Check to see if the player needs MP for auto-Olfaction.
		if(get_property("autoOlfact") != "" && !beset($effect[On the Trail])
		  && my_mp() < mpcost($skill[Transcendent Olfaction]) && my_maxmp() >= mpcost($skill[Transcendent Olfaction])) {
			if(objective == 0)
				amount = mpcost($skill[Transcendent Olfaction]);
			else
				amount = max(mpcost($skill[Transcendent Olfaction]), amount);
			objective = amount;
		}
		if(objective == 0 || (objective >0 && amount < mp_target && mp_trigger > 0))
			amount = mp_target;
		if((objective != 0 && my_mp() <= amount) || (objective == 0 && my_mp()<= mp_trigger))
			return mp_heal(amount);
	}
	else {	// type == "HP"
		if(objective ==0 && hp_trigger < 0) return true;
		int start_hp = my_hp();
		if(!ignoreStatus && beset($effect[Beaten Up]))
			cure_beatenup(objective);
		if(objective ==0 || (objective >0 && amount > start_hp && amount < hp_target))
			amount = hp_target;
	    if((objective != 0 && my_hp() < objective) || (objective == 0 && (start_hp<= hp_trigger || my_hp() < hp_trigger)))
			return hp_heal(amount);
	}
	return true;
}

void check_restore(string type, int amount) {
	if(AlwaysContinue || fist_safely) {
		if(!restore(type, amount)) {
			set_property("baleUr_"+type+"trouble", "true");
			print("Did not fully restore "+ type + " for some reason.", "red");
		} else if(beset($effect[Beaten Up])) {
			set_property("baleUr_"+type+"trouble", "true");
		} else set_property("baleUr_"+type+"trouble", "false");
	} else {
		if(!restore(type, amount))
			abort("Did not fully restore "+ type + " for some reason.");
		else if(beset($effect[Beaten Up]))
			abort("Did not recover from being Beaten Up!");
	}
}

// Passes all restoration logic to restore() to improve inclusion in another restoreScript.
boolean main(string type, int amount) {
	check_restore(type, amount);
	return true;	// This ensures that mafia does not attempt to heal with resources that are being conserved.
}
