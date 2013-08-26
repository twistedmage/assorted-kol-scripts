#***********************************************************************************#
# 11.01.09																			#
#							   Miner v2.5											#
#						Mining ore the mafia way									#
#							by That FN Ninja										#
#						  Last edited 06/10/11										#
#																					#
#***********************************************************************************#
#																					#
#   For farming items in the Itznotyerzitz Mine, Knob Shaft, & Anemone Mine.		#
#		Has an option to complete the ore portion of the Tr4pz0r quest.				#
#   	Has an option to open Cobb's Knob Laboratory.								#
#																					#
#   Have a suggestion to improve this script?										#
#		Visit: http://kolmafia.us/showthread.php?t=2883								#
#																					#   
#   Thanks to Zarqon, Jason Harper, mredge73, & Bale								#
#		for helping me fix my n00bish scripting errors.								#
#																					#
#	Useful alias:																	#
#		alias tore => ashq import <miner.ash> get_tore = true; mine_stuff();		#
#			That will complete the mining portion of the Trapper quest. 			#
#		alias fmine => ashq import <miner.ash> free_mine();							#
#			That will use your 5 free mines from Unaccompanied Miner.				#
#																					#
#	Notable functions:																#
#		boolean mine(int amount, item ore)											#
#			Tries to retrieve amount of ore and then mines for the rest.			#
#		boolean mine(int[item] ore)													#
#			Same as above accept with a map of ore.									#
#		boolean free_mine()															#
#			This uses the 5 free mining attempts granted by Unaccompanied Miner		#
#																					#
#	If you find this script useful donations in the form of in-game ninja			#
#	paraphernalia are always appreciated! Thanks and enjoy the script.				#
#																					#
#***********************************************************************************#
script "miner.ash";
notify That FN Ninja;
import <zlib.ash>

boolean get_tore = false;		// If true will get the ore the trapper is asking for.

boolean mine_all = false;		// If true will mine all walls in cavern instead of just the top 3 rows.
// ***WARNING*** Mining all walls consumes 36 adv. per cavern as opposed to 21 for just the top 3 rows.
								// Almost all ore is found in the top 3 rows.
								
// Note: These items can only be aquired in mine1 - Itznotyerzitz Mine.
int asbestos = 0;				// Set the amount of asbestos ore to mine for.
int chrome = 0;					// Set the amount of chrome ore to mine for.
int linoleum = 0;				// Set the amount of linoleum ore to mine for.
int diamond = 0;				// Set the amount of lumps of diamond to mine for.

// Note: These items can only be aquired in mine2 - The Knob Shaft.
int bubblewrap = 0;				// Set the amount of bubblewrap ore to mine for.
int cardboard = 0;				// Set the amount of cardboard ore to mine for.
int styrofoam = 0;				// Set the amount of styrofoam ore to mine for.

// Note: These items can only be aquired in mine3 - Anemone Mine.
// ***WARNING*** Mining in the Anemone mine cosumes 2 advetures per wall!!
// Unless you have the fishy effect, which this script does not attempt to maintain.
int teflon = 0;					// Set the amount of teflon ore to mine for.
int velcro = 0;					// Set the amount of velcro ore to mine for.
int vinyl = 0;					// Set the amount of vinyl ore to mine for.
// ***WARNING*** Only one marine aquamarine can be found per cavern!!
int aquamarine = 0;				// Set the amount of marine aquamarines to mine for.

// Note: These items can only be aquired in mine4 - The Knob Shaft.
int bananagate = 0;				// Set the amount of bananagates to mine for.
int kumquartz = 0;				// Set the amount of kumquartzs to mine for.
int pearidot = 0;				// Set the amount of pearidots to mine for.
int strawberyl = 0;				// Set the amount of strawberyls to mine for.
int tourmalime = 0;				// Set the amount of tourmalimes to mine for.
int greeningot = 0;				// Set the amount of green gummi ingots to mine for.
int redingot = 0;				// Set the amount of red gummi ingots to mine for.
int yellowingot = 0;				// Set the amount of yellow gummi ingots to mine for.

// Note: These items can be found in both mines. However, this script will mine for them in
// Itznotyerzitz Mine.
int stonepower = 0;				// Set the amount of stones of eXtreme power to mine for.
int meatstack = 0;				// Set the amount of meat stacks to mine for.

boolean open_mine2 = false;		// If true & you are at least lvl 5 will gain access to The Knob Shaft.
								// This opens Cobb's Knob Laboratory if it's not already open.							

boolean asked = false;			// Set this to true if you plan on mining in the anemone mine
								// and have already asked grandpa about it.
								
////////////////////// ***END OF USER PREFERENCES*** \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

int mine_num;
int counter = 54;
boolean m1open = contains_text(visit_url("mclargehuge.php"), "bottomright");
boolean m3open, do_free;
boolean m4open = substring(today_to_string(), 4, 6) == "12" && contains_text(visit_url("campground.php?action=advent"), "mining.php?mine=4");
string dig;
boolean set_amount(int amount, item itm);
familiar fam = my_familiar();
item fam_equipment = familiar_equipped_equipment(my_familiar());

void counter_change(){	
	int loopcount = 0;
	int checking;
	boolean detecting = (have_outfit("Dwarvish War Uniform") && (mine_num == 1 || mine_num == 4)) || have_effect($effect[object detection]) > 0;

	while (loopcount < 2){
		loopcount += 1;
		checking = 54;
		while (checking > 8){
			if (dig.contains_text("href='mining.php?mine=" + mine_num.to_string() + "&which=" + checking.to_string() + "&pwd") && dig.contains_text("Promising Chunk of Wall (" + (checking % 8) + "," + (checking / 8) + ")")){
				counter = checking;
				return;
			}
			switch{
				case $ints[17, 25, 33, 41, 49] contains checking: checking -= 3; break;
				default: checking -= 1; break;
			}
		}
		checking = 9;
		while (checking < 55){
			if (checking > 14 && !mine_all && detecting && dig.contains_text("Open Cavern (" + (checking % 8) + "," + (checking / 8) + ")")){
				if (my_path() == "Way of the Surprising Fist" && have_effect($effect[earthen fist]) < 1)
					cli_execute("skill worldpunch");

				dig = visit_url("mining.php?mine=" + mine_num + "&reset=1&pwd");
				counter = 54;
			}
			else if (checking > 30 && !mine_all && dig.contains_text("Open Cavern (" + (checking % 8) + "," + (checking / 8) + ")")){
				if (my_path() == "Way of the Surprising Fist" && have_effect($effect[earthen fist]) < 1)
					cli_execute("skill worldpunch");

				dig = visit_url("mining.php?mine=" + mine_num + "&reset=1&pwd");
				counter = 54;
			}
			else if (checking > 46 && mine_all && dig.contains_text("Open Cavern (" + (checking % 8) + "," + (checking / 8) + ")")){
				if (my_path() == "Way of the Surprising Fist" && have_effect($effect[earthen fist]) < 1)
					cli_execute("skill worldpunch");

				dig = visit_url("mining.php?mine=" + mine_num + "&reset=1&pwd");
				counter = 54;
			}
			if (dig.contains_text("href='mining.php?mine=" + mine_num.to_string() + "&which=" + checking.to_string() + "&pwd")){
				counter = checking;
				return;
			}
			switch{
				case $ints[14, 22, 30, 38, 46] contains checking: checking += 3; break;
				default: checking += 1; break;
			}
		}
	}
#	switch{
#		case $ints[38, 46, 54] contains counter:
#			if(mine_all) counter -= 3;
#			else counter -= 8;
#			break;
#		case $ints[17, 25] contains counter: counter -= 3; break;
#		case counter == 9:
#			if (my_path() == "Way of the Surprising Fist" && have_effect($effect[earthen fist]) < 1)
#				cli_execute("skill worldpunch");
#
#			dig = visit_url("mining.php?mine=" + mine_num + "&reset=1&pwd");
#			counter = 54;
#			break;
#		default: counter -= 1;
#	}
}

void reset_mining_values(){
	vprint("Resetting mining values...", "66666", 4);
	meatstack = 0; stonepower = 0; diamond = 0; 
	styrofoam = 0; cardboard = 0; bubblewrap = 0; 
	linoleum = 0; chrome = 0; asbestos = 0;
	teflon = 0; velcro = 0; vinyl = 0; aquamarine = 0;
	bananagate = 0; kumquartz = 0; pearidot = 0; strawberyl = 0;
	tourmalime = 0; greeningot = 0; redingot = 0; yellowingot = 0;
}

boolean trapper_ore(){
	vprint("Checking the Tr4pz0r for ore...", 2);
	reset_mining_values();
	
	string trapper = visit_url("trapper.php");
	foreach ore in $strings[chrome ore, asbestos ore, linoleum ore]
		if(trapper.contains_text(ore)){
			set_amount(3, ore.to_item());
			vprint("The L337 Tr4pz0r wants 3 chunks of " + ore + ".", "blue", 2);
			break;
		}
	
	if(chrome == 0 && asbestos == 0 && linoleum == 0) return vprint("The L337 Tr4pz0r isn't currently asking for ore!", -2);
	
	vprint("", 2);
	return vprint("Let the mining begin!", "blue", 4);
}

boolean openknob(){
	if(!visit_url("plains.php").contains_text("knob1.gif")) return true;	
	vprint("", 2);
	vprint("Opening Cobb's Knob...", "blue", 2);
		
	if(item_amount($item[Cobb's Knob map]) < 1) visit_url("council.php");
		
	if(!obtain(1, "Knob Goblin encryption key", $location[The Outskirts of Cobb's Knob]))
		return vprint("Unable to obtain the Knob Goblin encryption key.", -2);
		
	use(1, $item[Cobb's Knob map]);
	return vprint("Cobb's Knob opened successfully.", "green", 2);
}

boolean openlab(){
	if(!openknob()) return false;
	if(obtain(1, "Cobb's Knob lab key", $location[Cobb's Knob Harem]))
		return vprint("Knob lab opened successfully", 2);
	else return vprint("Unable to gain access to the lab.", -2);
}

void restore_outfit(){
	vprint("", 2);
	vprint("Restoring outfit...", "66666", 4);	
	use_familiar(fam);
	outfit("Backup");
	if(fam_equipment != $item[none]) equip(fam_equipment);
}

boolean mine_stuff(){
	boolean maxregen;

	if(get_tore && !trapper_ore()) return false;

	if(item_amount($item[asbestos ore]) >= asbestos && 
	item_amount($item[chrome ore]) >= chrome && 
	item_amount($item[linoleum ore]) >= linoleum && 
	item_amount($item[lump of diamond]) >= diamond && 
	item_amount($item[stone of eXtreme power]) >= stonepower && 
	item_amount($item[meat stack]) >= meatstack && 
	item_amount($item[bubblewrap ore]) >= bubblewrap && 
	item_amount($item[cardboard ore]) >= cardboard && 
	item_amount($item[styrofoam ore]) >= styrofoam &&
	item_amount($item[teflon ore]) >= teflon && 
	item_amount($item[velcro ore]) >= velcro && 
	item_amount($item[vinyl ore]) >= vinyl && 
	item_amount($item[marine aquamarine]) >= aquamarine && 
	item_amount($item[bananagate]) >= bananagate && 
	item_amount($item[kumquartz]) >= kumquartz && 
	item_amount($item[pearidot]) >= pearidot && 
	item_amount($item[strawberyl]) >= strawberyl && 
	item_amount($item[tourmalime]) >= tourmalime &&
	item_amount($item[green gummi ingot]) >= greeningot && 
	item_amount($item[red gummi ingot]) >= redingot && 
	item_amount($item[yellow gummi ingot]) >= yellowingot)
		return vprint("Sufficient ore on hand. No mining required.", "green", 2);
		
	if(my_inebriety() > inebriety_limit()) return vprint("You're too drunk to do any mining.", -2);
		
	cli_execute("outfit save Backup");
	
	while(counter <= 54){
			
		if(mine_num != 1 && (item_amount($item[asbestos ore]) < asbestos || item_amount($item[chrome ore]) < chrome || item_amount($item[linoleum ore]) < linoleum || item_amount($item[lump of diamond]) < diamond || item_amount($item[stone of eXtreme power]) < stonepower || item_amount($item[meat stack]) < meatstack)){
			vprint("Setting mine_num to mine1: Itznotyerzitz Mine.", "66666", 4);	
			mine_num = 1;
		}
		else if(mine_num != 2 && (item_amount($item[bubblewrap ore]) < bubblewrap || item_amount($item[cardboard ore]) < cardboard || item_amount($item[styrofoam ore]) < styrofoam)){
			vprint("Setting mine_num to mine2: The Knob Shaft.", "66666", 4);
			mine_num = 2;
		}
		else if(mine_num != 3 && (item_amount($item[teflon ore]) < teflon || item_amount($item[velcro ore]) < velcro || item_amount($item[vinyl ore]) < vinyl || item_amount($item[marine aquamarine]) < aquamarine)){
			vprint("Setting mine_num to mine3: Anemone Mine.", "66666", 4);
			mine_num = 3;
		}
		else if(mine_num != 4 && (item_amount($item[bananagate]) < bananagate || item_amount($item[kumquartz]) < kumquartz || item_amount($item[pearidot]) < pearidot || item_amount($item[strawberyl]) < strawberyl || item_amount($item[tourmalime]) < tourmalime || item_amount($item[green gummi ingot]) < greeningot || item_amount($item[red gummi ingot]) < redingot || item_amount($item[yellow gummi ingot]) < yellowingot)){
			vprint("Setting mine_num to mine4: The Gummi Mine.", "66666", 4);
			mine_num = 4;
		}
			
		if(my_adventures() == 0 && !do_free){
			restore_outfit();
			return vprint("Out of adventures.", -2);
		}

		if(mine_num == 3 && my_adventures() < 2 && have_effect($effect[fishy]) == 0){
			restore_outfit();
			return vprint("You need two adventures to go underwater adventuring.", -2);
		}
			
		if(mine_num == 1 && my_level() >= 8 && !m1open){
			visit_url("council.php");
			visit_url("trapper.php");
		}
		
		if(mine_num == 1 && my_level() < 8)
			return vprint("You cannot access Itznotyerzitz Mine yet!", -2);
			
		if(mine_num == 2 && my_level() < 5)
			return vprint("You cannot access The Knob Shaft yet!", -2);
			
		if(mine_num == 2 && item_amount($item[Cobb's Knob lab key]) < 1 && !open_mine2)
			return vprint("You cannot access The Knob Shaft yet!", -2);	
			
		if(mine_num == 2 && my_level() >= 5 && item_amount($item[Cobb's Knob lab key]) < 1 && open_mine2){
			vprint("Attempting to open Cobb's Knob Laboratory...", "blue", 2);			
			if(!openlab()) return false;
		}			
		
		if(mine_num == 4 && !m4open)
			return vprint("You cannot currently access The Gummi Mines!", -2);


		if(my_basestat($stat[Moxie]) < 25 || my_basestat($stat[Muscle]) < 25)
			return vprint("25 Muscle & Moxie is required to put on Mining Gear!", -2);
			
		if(item_amount($item[asbestos ore]) < asbestos || 
		item_amount($item[chrome ore]) < chrome || 
		item_amount($item[linoleum ore]) < linoleum || 
		item_amount($item[lump of diamond]) < diamond || 
		item_amount($item[stone of eXtreme power]) < stonepower || 
		item_amount($item[meat stack]) < meatstack || 
		item_amount($item[bubblewrap ore]) < bubblewrap || 
		item_amount($item[cardboard ore]) < cardboard || 
		item_amount($item[styrofoam ore]) < styrofoam ||
		item_amount($item[teflon ore]) < teflon || 
		item_amount($item[velcro ore]) < velcro || 
		item_amount($item[vinyl ore]) < vinyl || 
		item_amount($item[marine aquamarine]) < aquamarine ||
		item_amount($item[bananagate]) < bananagate || 
		item_amount($item[kumquartz]) < kumquartz || 
		item_amount($item[pearidot]) < pearidot || 
		item_amount($item[strawberyl]) < strawberyl || 
		item_amount($item[tourmalime]) < tourmalime ||
		item_amount($item[green gummi ingot]) < greeningot || 
		item_amount($item[red gummi ingot]) < redingot || 
		item_amount($item[yellow gummi ingot]) < yellowingot){
		
			if(my_hp() <= 0) visit_url("galaktik.php?action=curehp&quantity=1&pwd");
			
			if(mine_num == 3){	
				vprint("Equipping underwater gear...", "66666", 4);
			
				if(have_item("aerated diving helmet") > 0) equip($item[aerated diving helmet]);
				else if(have_item("makeshift SCUBA gear") > 0) equip($slot[acc1], $item[makeshift SCUBA gear]);
				else return vprint("You need an air supply source to adventure underwater.", -2);
				
				if(equipped_item($slot[weapon]) != $item[Mer-kin digpick]){
					if(retrieve_item(1, $item[Mer-kin digpick])) equip($item[Mer-kin digpick]);
					else{
						restore_outfit();
						return vprint("You need a Mer-kin digpick to mine in the Anemone mine.", -2);
					}
				}
					
				if(fam != $familiar[none])
					if(fam_equipment != $item[little bitty bathysphere] && fam_equipment != $item[das boot]){
						if(item_amount($item[das boot]) > 0) equip($item[das boot]);
						else if(item_amount($item[little bitty bathysphere]) > 0) equip($item[little bitty bathysphere]);
						else use_familiar($familiar[none]);
					}

				if(!m3open){
					string main = visit_url("main.php");
					if((main.contains_text("map4_sea.gif") || (main.contains_text("map4_oldman.gif") && visit_url("oldman.php?action=talk").contains_text(""))) && contains_text(visit_url("seafloor.php"), "mineb.gif"))
						m3open = true;
					else{
						restore_outfit();
						return vprint("You don't have access to the Anemone mine.", -2);
					}
				}
				
				if(!asked){
					vprint("Asking Grandpa about Anemone...", "66666", 4);
					cli_execute("grandpa anemone");
					asked = true;
				}
			}
			else if (my_path() != "Way of the Surprising Fist"){
				if(have_outfit("Dwarvish War Uniform")) outfit("Dwarvish War Uniform");
				else{
					if(!have_outfit("Mining Gear") && (!can_interact() || get_property("autoSatisfyWithMall") == "false")){
						vprint("Unable to buy mining gear. Adventuring for it instead...", "66666", 4);
						
						while(!have_outfit("Mining Gear")){
							if(my_adventures() == 0) return vprint("Out of adventures.", -2);
							adventure(1, $location[Itznotyerzitz Mine]);
						}
					}
					(outfit("Mining Gear"));
				}
			}
			
			if(!maxregen){
				vprint("Attempting to equip some HP regen items...", "66666", 4);
				if (my_path() != "Way of the Surprising Fist")
					cli_execute("maximize hp regen max -hat -weapon -pants -acc1");
				else
					cli_execute("maximize hp regen max");
				maxregen = true;
			}			
			
			if(do_free && visit_url("mining.php?mine=" + mine_num.to_string()).contains_text("Mining a chunk of the cavern wall takes")){
				set_property("_freeMinesDepleted", "true");
				restore_outfit();
				return vprint("Free mines depleted!", "blue", 2);
			}
			
			if (my_path() == "Way of the Surprising Fist" && have_effect($effect[earthen fist]) < 1)
				cli_execute("skill worldpunch");

			if (dig == ""){
				dig = visit_url("mining.php?mine=" + mine_num.to_string() + "&pwd");
			}

			counter_change();
			dig = visit_url("mining.php?mine=" + mine_num.to_string() + "&which=" + counter.to_string() + "&pwd");
			
			if(dig.contains_text("You start digging")) vprint("Just mined wall " + counter, "66666", 4);
			else vprint("Wall " + counter + " was already mined.", "66666", 4);
			
			if(my_hp() <= 0) visit_url("galaktik.php?action=curehp&quantity=1&pwd");
			
			if(get_tore && contains_text(visit_url("trapper.php"), "cheese")){
				restore_outfit();
				return vprint("Miner, miner, you're quite the miner!", "green", 2);
			}
		}
		else{
			restore_outfit();
			return vprint("Miner, miner, you're quite the miner!", "green", 2);
		}
	}
	
	restore_outfit();
	return false;
}

boolean set_amount(int amount, item itm){
	switch(itm){
		case $item[chrome ore]: chrome = amount; break;
		case $item[linoleum ore]: linoleum = amount; break;
		case $item[asbestos ore]: asbestos = amount; break;
		case $item[lump of diamond]: diamond = amount; break;
		case $item[styrofoam ore]: styrofoam = amount; break;
		case $item[bubblewrap ore]: bubblewrap = amount; break;
		case $item[cardboard ore]: cardboard = amount; break;
		case $item[stone of eXtreme power]: stonepower = amount; break;
		case $item[teflon ore]: teflon = amount; break;
		case $item[velcro ore]: velcro = amount; break;
		case $item[vinyl ore]: vinyl = amount; break;
		case $item[marine aquamarine]: aquamarine = amount; break;
		case $item[meat stack]: meatstack = amount; break;
		case $item[bananagate]: bananagate = amount; break;
		case $item[kumquartz]: kumquartz = amount; break;
		case $item[pearidot]: pearidot = amount; break;
		case $item[strawberyl]: strawberyl = amount; break;
		case $item[tourmalime]: tourmalime = amount; break;
		case $item[green gummi ingot]: greeningot = amount; break;
		case $item[red gummi ingot]: redingot = amount; break;
		case $item[yellow gummi ingot]: yellowingot = amount; break;
		
		default: return vprint("Unrecognized item: " + itm, -2);
	}
	return true;
}

boolean mine(int[item] ore){
		
	get_tore = false;
	mine_all = false;
	reset_mining_values();

	foreach itm, amt in ore
		if(!set_amount(amt, itm)) return vprint("Error: This script does not support mining " + itm + ".", -2);
	
	vprint("Attempting to retrieve ore before mining...", "66666", 4);
	
	if(count(ore) > 1){
		int[item] copy = ore;
		int high, wanted; item most;
		while(true){
			foreach itm, amt in copy{
				wanted = amt - item_amount(itm);
				if(wanted > high){
					most = itm;
					high = wanted;
				}
			}
			vprint(most + " selected. High = " + high, "66666", 10);
			if(high == 0 || count(copy) == 0) break;
			
			if(item_amount(most) >= copy[most]) remove copy[most];
			
			vprint("Attempting retrieval...", "66666", 10);
			if(!retrieve_item(min(item_amount(most) + high, item_amount(most) + 3), most))
				remove copy[most];
			high = 0;
		}
	}
	else foreach itm, amt in ore
		if(!retrieve_item(amt, itm)){}
	
	vprint("", 2);
	vprint("Mining for what could not be retrieved...", "66666", 4);		
	return mine_stuff();
}

boolean mine(int amount, item ore){
	int[item] to_mine;
	to_mine[ore] = amount;
	return mine(to_mine);
}

item best_ore(){
	boolean[item] ore;

	if(item_amount($item[Cobb's Knob lab key]) > 0)
		foreach itm in $items[styrofoam ore, bubblewrap ore, cardboard ore]
			ore[itm] = true;
			
	if(m1open)
		foreach itm in $items[asbestos ore, chrome ore, linoleum ore, lump of diamond]
			ore[itm] = true;
			
	string main = visit_url("main.php");
	if((main.contains_text("map4_sea.gif") || (main.contains_text("map4_oldman.gif") && visit_url("oldman.php?action=talk").contains_text(""))) && contains_text(visit_url("seafloor.php"), "mineb.gif")){
		m3open = true;
		
		if((have_item("aerated diving helmet") > 0 || have_item("makeshift SCUBA gear") > 0) && have_item("Mer-kin digpick") > 0)		
			foreach itm in $items[teflon ore, velcro ore, vinyl ore]
				ore[itm] = true;		
	}
										
	if(m4open)
		foreach itm in $items[bananagate, kumquartz, pearidot, strawberyl, tourmalime, green gummi ingot, red gummi ingot, yellow gummi ingot]
			ore[itm] = true;
			
	int price; item best;
	
	vprint("", 2);
	vprint("Calculating the best ore to mine...", "blue", 2);
	
	foreach itm in ore{
		if(can_interact()){
			if(mall_price(itm) > price){
				best = itm;
				price = mall_price(itm);
			}
		}
		else{
			if(autosell_price(itm) > price){
				best = itm;
				price = autosell_price(itm);
			}		
		}
	}
	
	if(best == $item[none]) vprint("You don't have access to any mines!", -2);
	else if(can_interact()){
		vprint("Current mall prices indicate that the best ore to mine would be...", "blue", 3);
		vprint("the " + best + ", which is selling for: " + price + " meat.", "blue", 3);
	}
	else{
		vprint("According to their autosell prices the best ore to mine would be...", "blue", 3);
		vprint("the " + best + ", which is autosells for: " + price + " meat.", "blue", 3);
	}
	vprint("", 3);
	return best;
}

boolean free_mine(){
	if(!have_skill($skill[Unaccompanied Miner])) return vprint("You don't have the skill Unaccompanied Miner!", -2);
	if(to_boolean(get_property("_freeMinesDepleted"))) return vprint("You've already used your 5 free mines for today!", 2);		
	if(my_level() < 5) return vprint("You don't have access to any mines yet!", -2);
		
	do_free = true;
	
	if(m1open && !contains_text(visit_url("questlog.php?which=2&pwd"), "Tr4pz0r") && trapper_ore()){
		get_tore = false;
		mine_all = false;
		mine_stuff();
	}
		
	if(!to_boolean(get_property("_freeMinesDepleted"))){
		item best = best_ore();
		if(best != $item[none]){
			get_tore = false;
			mine_all = false;
			reset_mining_values();			
			set_amount(item_amount(best) + 5, best);
			mine_stuff();
		}
	}
	return true;
}

check_version("Miner", "miner", "2.5", 2883);
void main(){ mine_stuff(); }