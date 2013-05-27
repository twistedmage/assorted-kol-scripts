#***********************************************************************************#
# 12.05.09																			#
#					Dwarven Factory v1.2											#
#						Automated factory puzzle solver.							#
#								by That FN Ninja									#
#																					#
#***********************************************************************************#
#																					#
#   Have a suggestion to improve this script?  Visit:								#
#		http://kolmafia.us/showthread.php?t=2884									#
#																					#   
#   Thanks to Veracity for adding Dwarven Factory support to KoLmafia.				#
#																					#
#	Useful alias:																	#
# 	alias ds => ash import <dwarven_factory.ash> prep(); delivery();				#
#			That will complete the delivery service quest.							#
#																					#
#	If you find this script useful donations in the form of in-game ninja			#
#	paraphernalia are always appreciated! Thanks and enjoy the script.				#
#																					#
#***********************************************************************************#
script "dwarven_factory.ash";
import <miner.ash>
import <zlib.ash>
import <questlib.ash>;

boolean delivery_quest = false;	//If true will complete the Dwarven Factory Guild Quest
								//(delivery service) before solving the factory puzzle.
								
boolean puzzle = true;			//Set this to false if you only want to complete the guild quest.
boolean buyore;			//If true the script will buy ore instead of mine for it.
if(can_interact())
{
	buyore = true;			//If true the script will buy ore instead of mine for it.
}
else
{
	buyore = false;
}

//By default the script will get a piece of the Dwarvish War Uniform that you do not already have. 
//If you already have all the components of the Dwarvish War Uniform this script will just abort. 
//If you are a collector change transform to bypass this abort.							
item transform = $item[none];	//Select the piece of mining gear to transform.
								//i.e. if you collect Dwarvish War Helmets set this 
								//to miner's helmet.

int[string] drunes;
string[int] gauge;
int[item] hoppers,ore_needed;
item h1,h2,h3,h4,oi,oi_doc;
string temp,oi_rune,oidocst;

int b7tob10(string to_convert){
	foreach ltr,num in drunes
		to_convert = replace_string(to_convert,ltr,num.to_string());
	if(length(to_convert) == 3)
		to_convert = to_int(substring(to_convert,0,1))*49 + to_int(substring(to_convert,1,2))*7 + to_int(substring(to_convert,2,3))*1;
	else if(length(to_convert) == 2)
		to_convert = to_int(substring(to_convert,0,1))*7 + to_int(substring(to_convert,1,2))*1;
	else if(length(to_convert) == 1)
		to_convert = to_int(substring(to_convert,0,1))*1;
	return to_convert.to_int();
}

void hopper_check(){
	foreach num in $ints[0,1,2,3]{
		temp = visit_url("dwarfcontraption.php?action=hopper"+num+"&pwd");
		if(!contains_text(temp,"contains")){
			if(!(hoppers contains $item[chrome ore]) && item_amount($item[chrome ore]) > 0)
				visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany=1&whichore=chrome&pwd");
			if(!(hoppers contains $item[asbestos ore]) && item_amount($item[asbestos ore]) > 0)
				visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany=1&whichore=asbestos&pwd");
			if(!(hoppers contains $item[linoleum ore]) && item_amount($item[linoleum ore]) > 0)
				visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany=1&whichore=linoleum&pwd");
			if(!(hoppers contains $item[lump of coal]) && item_amount($item[lump of coal]) > 0)
				visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany=1&whichore=coal&pwd");
		}		
		if(contains_text(temp,"contains")){
			if(num == 0){
				if(contains_text(temp,"coal")){
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h1 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item();
				}
				else{
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h1 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item();
				}
			}
			if(num == 1){
				if(contains_text(temp,"coal")){
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h2 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item();
				}
				else{
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h2 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item();
				}
			}
			if(num == 2){
				if(contains_text(temp,"coal")){
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h3 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item();
				}
				else{
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h3 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item();
				}
			}
			if(num == 3){
				if(contains_text(temp,"coal")){
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h4 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"s","").to_item();
				}
				else{
					hoppers[replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item()] = substring(temp,index_of(temp,"contains")+8,index_of(temp,"contains")+11).to_int();
					h4 = replace_string(substring(temp,index_of(temp,"contains")+11,index_of(temp,".</p>")),"chunks of","").to_item();
				}
			}
		}
	}
}

void doc_check(){
	foreach itm in $items[dwarvish paper,dwarvish document,dwarvish parchment]{
		temp = to_string(get_property("lastDwarfOfficeItem"+itm.to_int()));
		if(item_amount(itm) > 0 && length(temp) == 0){
			use(1,itm);
			temp = to_string(get_property("lastDwarfOfficeItem"+itm.to_int()));
		}
		if(length(oi_rune) != 0 && length(temp) !=0 && substring(temp,0,1) == oi_rune)
			oi_doc = itm;
	}
}

void card_check(){
	foreach itm in $items[little laminated card,small laminated card,notbig laminated card,unlarge laminated card]{
		temp = to_string(get_property("lastDwarfOfficeItem"+itm.to_int()));
		while(item_amount(itm) < 1){
			if(my_adventures() == 0)
			{
				print("Out of adventures.","red");
				return;
			}
			adventure(1,$location[Mine Foremens' Office]);
		}
		if(length(temp) == 0){
			use(1,itm);
			temp = to_string(get_property("lastDwarfOfficeItem"+itm.to_int()));
		}
		if(oi_doc != $item[none]){
			if(substring(temp,0,1) == to_string(get_property("lastDwarfHopper1"))){
				if(oi_doc == to_item(3214))
					gauge[1] = substring(temp,index_of(temp,","+oi_rune)+2);
				else
					gauge[1] = substring(temp,index_of(temp,","+oi_rune)+2,index_of(temp,",",index_of(temp,","+oi_rune)+2));
			}
			if(substring(temp,0,1) == to_string(get_property("lastDwarfHopper2"))){
				if(oi_doc == to_item(3214))
					gauge[2] = substring(temp,index_of(temp,","+oi_rune)+2);
				else
					gauge[2] = substring(temp,index_of(temp,","+oi_rune)+2,index_of(temp,",",index_of(temp,","+oi_rune)+2));
			}	
			if(substring(temp,0,1) == to_string(get_property("lastDwarfHopper3"))){
				if(oi_doc == to_item(3214))
					gauge[3] = substring(temp,index_of(temp,","+oi_rune)+2);
				else
					gauge[3] = substring(temp,index_of(temp,","+oi_rune)+2,index_of(temp,",",index_of(temp,","+oi_rune)+2));
			}
			if(substring(temp,0,1) == to_string(get_property("lastDwarfHopper4"))){
				if(oi_doc == to_item(3214))
					gauge[4] = substring(temp,index_of(temp,","+oi_rune)+2);
				else
					gauge[4] = substring(temp,index_of(temp,","+oi_rune)+2,index_of(temp,",",index_of(temp,","+oi_rune)+2));
			}
		}
	}
}

void dwarf_puzzle(){
	print("Commencing Dwarven Factory Complex puzzle...","blue");
	print("");
	if(!can_interact() || get_property("autoSatisfyWithMall") == "false"){
		while(!have_outfit("Mining Gear")){
			if(my_adventures() == 0)
			{
				print("Out of adventures.","red");
				return;
			}					
			adventure(1,$location[Itznotyerzitz Mine]);
		}
	}		
	outfit("Mining Gear");	
	print("Getting the laminated cards and the punchcard...","blue");
	if(!contains_text(visit_url("dwarfcontraption.php?action=panelright&pwd"),"punchcard sticking slightly out")){
		while(item_amount($item[dwarvish punchcard]) < 1){
			if(my_adventures() == 0)
			{
				print("Out of adventures.","red");
				return;
			}
			adventure(1,$location[Mine Foremens' Office]);
		}
		visit_url("dwarfcontraption.php?action=panelright&action=dorightpanel&pwd");
	}
	card_check();
	doc_check();
	print("Hopper check...","blue");
	hopper_check();
	if(count(hoppers) < 4){
		if(buyore){
			print("Buying one of each missing ore to finish the initial hopper check...","blue");
			if(!(hoppers contains $item[chrome ore]) && item_amount($item[chrome ore]) == 0)
				buy(1,$item[chrome ore]);
			if(!(hoppers contains $item[asbestos ore]) && item_amount($item[asbestos ore]) == 0)
				buy(1,$item[asbestos ore]);
			if(!(hoppers contains $item[linoleum ore]) && item_amount($item[linoleum ore]) == 0)
				buy(1,$item[linoleum ore]);
			if(!(hoppers contains $item[lump of coal]) && item_amount($item[lump of coal]) == 0 && item_amount($item[lump of diamond]) == 0)
				buy(1,$item[lump of diamond]);
		}
		else{
			print("Mining for one of each missing ore to finish the initial hopper check...","blue");
			reset_mining_values();
			if(!(hoppers contains $item[chrome ore]) && item_amount($item[chrome ore]) == 0)
				chrome = 1;
			if(!(hoppers contains $item[asbestos ore]) && item_amount($item[asbestos ore]) == 0)
				asbestos = 1;
			if(!(hoppers contains $item[linoleum ore]) && item_amount($item[linoleum ore]) == 0)
				linoleum = 1;
			if(!(hoppers contains $item[lump of coal]) && item_amount($item[lump of coal]) == 0 && item_amount($item[lump of diamond]) == 0)
				diamond = 1;
			if(diamond > 0 || linoleum > 0 || asbestos > 0 || chrome > 0)
				mine_stuff();
		}
		if(!(hoppers contains $item[lump of coal]) && item_amount($item[lump of coal]) == 0 && item_amount($item[lump of diamond]) > 0)
			visit_url("dwarfcontraption.php?action=chamber&action=dochamber&howmany=1&whichitem=3200&pwd");
		hopper_check();
		print("Hopper ores identified!","green");
	}
	temp = to_string(get_property("lastDwarfDigitRunes"));
	if(contains_text(temp,"-") || length(temp) == 0){
		print("");
		print("Solving the digit code...","blue");
		while(contains_text(temp,"-") || length(temp) == 0){
			visit_url("dwarffactory.php?action=dodice");
			temp = to_string(get_property("lastDwarfDigitRunes"));
		}
		print("Digit code solved!","green");
	}
	foreach num in $ints[0,1,2,3,4,5,6]
		drunes[substring(temp, num, num + 1)] = num;
	print("");
	print("Selecting outfit item and identifying it's word rune...","blue");
	if(transform != $item[none]){
		oi = transform;
		if(oi == $item[miner's helmet]){
			print("Dwarvish War Helmet selected.","blue");
			visit_url("dwarfcontraption.php?action=panelleft&action=doleftpanel&activatewhich3=%C2%A0%C2%A0%C2%A0%C2%A0&pwd");	
		}
		if(oi == $item[7-Foot Dwarven mattock]){
			print("Dwarvish War Mattock selected.","blue");
			visit_url("dwarfcontraption.php?action=panelleft&action=doleftpanel&activatewhich2=%C2%A0%C2%A0%C2%A0%C2%A0&pwd");
		}
		if(oi == $item[miner's pants]){
			print("Dwarvish War Kilt selected.","blue");
			visit_url("dwarfcontraption.php?action=panelleft&action=doleftpanel&activatewhich1=%C2%A0%C2%A0%C2%A0%C2%A0&pwd");
		}		
	}
	else if(have_item("dwarvish war helmet") == 0){
		oi = $item[miner's helmet];
		print("Dwarvish War Helmet selected.","blue");
		visit_url("dwarfcontraption.php?action=panelleft&action=doleftpanel&activatewhich3=%C2%A0%C2%A0%C2%A0%C2%A0&pwd");
	}
	else if(have_item("dwarvish war mattock") == 0){
		oi = $item[7-Foot Dwarven mattock];
		print("Dwarvish War Mattock selected.","blue");
		visit_url("dwarfcontraption.php?action=panelleft&action=doleftpanel&activatewhich2=%C2%A0%C2%A0%C2%A0%C2%A0&pwd");
	}
	else if(have_item("dwarvish war kilt") == 0){
		oi = $item[miner's pants];
		print("Dwarvish War Kilt selected.","blue");
		visit_url("dwarfcontraption.php?action=panelleft&action=doleftpanel&activatewhich1=%C2%A0%C2%A0%C2%A0%C2%A0&pwd");
	}
	while(length(to_string(get_property("lastDwarfFactoryItem"+oi.to_int()))) != 1){
		if(my_adventures() == 0)
			{
				print("Out of adventures.","red");
				return;
			}		
		adventure(1,$location[Factory Warehouse]);
	}
	print("Outfit item word ruin identified!","green");
	oi_rune = to_string(get_property("lastDwarfFactoryItem"+oi.to_int()));
	doc_check();
	if(oi_doc == $item[none]){
		print("");
		print("Getting outfit items corresponding dwarf document...","blue");
		while(oi_doc == $item[none]){
			if(my_adventures() == 0)
			{
				print("Out of adventures.","red");
				return;
			}		
			adventure(1,$location[Mine Foremens' Office]);
			doc_check();
		}
		print(oi_doc+" obtained!","green");
	}
	card_check();
	print("");
	print("Setting the gauges...","blue");
	visit_url("dwarfcontraption.php?action=gauges&temp0="+b7tob10(gauge[1])+"&temp1="+b7tob10(gauge[2])+"&temp2="+b7tob10(gauge[3])+"&temp3="+b7tob10(gauge[4])+"&action=dogauges&pwd");
	print("Gauges set!!","green");
	print("");
	print("Calculating how much ore is need for each hopper...","blue");
	oidocst = to_string(get_property("lastDwarfOfficeItem"+oi_doc.to_int()));
	foreach num in $ints[1,2,3,4]{
		temp = to_string(get_property("lastDwarfHopper"+num));
		if(num == 1)
			ore_needed[h1] = b7tob10(substring(oidocst,index_of(oidocst,","+temp)+2,index_of(oidocst,","+temp)+4));
		if(num == 2)
			ore_needed[h2] = b7tob10(substring(oidocst,index_of(oidocst,","+temp)+2,index_of(oidocst,","+temp)+4));
		if(num == 3)
			ore_needed[h3]= b7tob10(substring(oidocst,index_of(oidocst,","+temp)+2,index_of(oidocst,","+temp)+4));
		if(num == 4)
			ore_needed[h4] = b7tob10(substring(oidocst,index_of(oidocst,","+temp)+2,index_of(oidocst,","+temp)+4));
	}
	reset_mining_values();
	foreach itm in hoppers{
		if(itm == $item[chrome ore])
			chrome = ore_needed[itm] - hoppers[itm];
		if(itm == $item[asbestos ore])
			asbestos = ore_needed[itm] - hoppers[itm];
		if(itm == $item[linoleum ore])
			linoleum = ore_needed[itm] - hoppers[itm];
		if(itm == $item[lump of coal])
			diamond = ore_needed[itm] - hoppers[itm] - item_amount($item[lump of coal]);
	}
	if(diamond > 0 || linoleum > 0 || asbestos > 0 || chrome > 0){
		if(buyore){
			print("Buying the required ore:","blue");
			if(chrome - item_amount($item[chrome ore]) > 0){
				print(chrome - item_amount($item[chrome ore])+" chrome ore");
				buy(chrome - item_amount($item[chrome ore]),$item[chrome ore]);
				if(item_amount($item[chrome ore]) != chrome)
					abort("Unable to buy the neccessary chrome ore!");
			}
			if(asbestos - item_amount($item[asbestos ore]) > 0){
				print(asbestos - item_amount($item[asbestos ore])+" asbestos ore");
				buy(asbestos - item_amount($item[asbestos ore]),$item[asbestos ore]);
				if(item_amount($item[asbestos ore]) != asbestos)
					abort("Unable to buy the neccessary asbestos ore!");				
			}
			if(linoleum - item_amount($item[linoleum ore]) > 0){
				print(linoleum - item_amount($item[linoleum ore])+" linoleum ore");
				buy(linoleum - item_amount($item[linoleum ore]),$item[linoleum ore]);
				if(item_amount($item[linoleum ore]) != linoleum)
					abort("Unable to buy the neccessary linoleum ore!");				
			}
			if(diamond - item_amount($item[lump of diamond]) > 0){
				print(diamond - item_amount($item[lump of diamond])+" lump of diamond");
				buy(diamond - item_amount($item[lump of diamond]),$item[lump of diamond]);
				if(item_amount($item[lump of diamond]) != diamond)
					abort("Unable to buy the neccessary lumps of diamond!");				
			}
		}
		else{
			print("Mining for:","blue");
			if(chrome - item_amount($item[chrome ore]) > 0)
				print(chrome - item_amount($item[chrome ore])+" chrome ore");
			if(asbestos - item_amount($item[asbestos ore]) > 0)	
				print(asbestos - item_amount($item[asbestos ore])+" asbestos ore");
			if(linoleum - item_amount($item[linoleum ore]) > 0)	
				print(linoleum - item_amount($item[linoleum ore])+" linoleum ore");
			if(diamond - item_amount($item[lump of diamond]) > 0)	
				print(diamond - item_amount($item[lump of diamond])+" lump of diamond");
			print("");
			mine_stuff();
		}
	}
	print("");
	print("Filling the hoppers...","blue");
	visit_url("dwarfcontraption.php?action=chamber&action=dochamber&howmany="+diamond+"&whichitem=3200&pwd");
	foreach num in $ints[0,1,2,3]{
		temp = visit_url("dwarfcontraption.php?action=hopper"+num+"&pwd");
		if(contains_text(temp,"chrome"))
			visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany="+chrome+"&whichore=chrome&pwd");
		if(contains_text(temp,"asbestos"))	
			visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany="+asbestos+"&whichore=asbestos&pwd");
		if(contains_text(temp,"linoleum"))
			visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany="+linoleum+"&whichore=linoleum&pwd");
		if(contains_text(temp,"coal"))
			visit_url("dwarfcontraption.php?action=hopper"+num+"&action=dohopper"+num+"&howmany="+(ore_needed[$item[lump of coal]] - hoppers[$item[lump of coal]])+"&whichore=coal&pwd");
	}
	visit_url("dwarfcontraption.php?action=panelright&action=dorightpanel&action=doredbutton&pwd");
	if(contains_text(visit_url("dwarfcontraption.php?action=bin&pwd"),"acquire an item")){
		print("");
		print_html("<font size=5><b><font color=000000>P</font><font color=00002D>u</font><font color=00005A>z</font><font color=000087>z</font><font color=0000B4>l</font><font color=0000E1>e</font> <font color=0000E1>S</font><font color=0000C0>o</font><font color=0000A0>l</font><font color=000080>v</font><font color=000060>e</font><font color=000040>d</font><font color=000020>!</font><font color=000000>!</font></b></font>");
		set_property("lastDwarfSolvedAsc",to_string(my_ascensions()));
		print("");
		print("Autoselling laminated cards...","blue");
		foreach itm in $items[little laminated card,small laminated card,notbig laminated card,unlarge laminated card,dwarvish paper,dwarvish document,dwarvish parchment]
			autosell(1,itm);
	}
	else
	{
		print("Something went wrong!","red");
		cli_execute("dwarven_factory.ash");
	}
}

void delivery(){
	if(!contains_text(visit_url("questlog.php?which=2&pwd"),"factory")){
		print("Completing the Delivery Service guild quest...","blue");
		if(!can_interact() || get_property("autoSatisfyWithMall") == "false"){
			while(!have_outfit("Mining Gear")){
				if(my_adventures() == 0)
			{
				print("Out of adventures.","red");
				return;
			}					
				adventure(1,$location[Itznotyerzitz Mine]);
			}
		}		
		outfit("Mining Gear");
		while(item_amount($item[thick padded envelope]) < 1){
			if(my_adventures() == 0)
			{
				print("Out of adventures.","red");
				return;
			}	
			adventure(1,$location[Mine Foremens' Office]);
		}
		visit_url("guild.php?place=paco&pwd");
	}
	if(contains_text(visit_url("questlog.php?which=2&pwd"),"factory"))
		print("Delivery Service quest completed.","green");
	else
		print("Unable to complete the Delivery Service guild quest.","red");
}

void prep(){
	if(!contains_text(visit_url("questlog.php?which=2&pwd"),"White Citadel"))
	{
		print("You must complete the White Citadel quest before you can unlock the Dwarven Factory.");
		cli_execute("citadel.ash");
	}
	if(my_basestat(my_primestat()) < 100)
		abort("You need a mainstat of 100 (unbuffed) to gain access to the Dwarven Factory.");
	if(!contains_text(visit_url("questlog.php?which=2&pwd"),"factory") && !contains_text(visit_url("questlog.php?which=1&pwd"),"factory"))
		visit_url("guild.php?place=paco&pwd");
}

check_version("Dwarven Factory","dwarven_factory","1.2",2884);

void main(){
	prep();
	if(delivery_quest)
		delivery();
	if(puzzle){
		if(have_outfit("Dwarvish War Uniform") && transform == $item[none]){
			print("You already have the Dwarvish War Uniform so doing the puzzle would be a waste.","blue");
			print("If you are a collector set the transform variable to bypass this check.","red");
			return;
		}
		if(get_property("lastDwarfSolvedAsc") != "" && to_string(my_ascensions()) == to_string(get_property("lastDwarfSolvedAsc")))
		{
			print("You've already solved the dwarven factory puzzle this ascension!");
			return;
		}
		dress_for_fighting();
		dwarf_puzzle();
	}
}