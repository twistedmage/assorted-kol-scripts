import "bumcheekascend.ash";
void set_combat_macro(string macroid)
{
	switch(macroid)
	{
		case "cheeseburger":
			visit_url("account.php?actions[]=autoattack&autoattack=99129100&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=0;
			break;
		case "sailors":
			visit_url("account.php?actions[]=autoattack&autoattack=99129099&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=0;
			break;
		case "warbear":
			visit_url("account.php?actions[]=autoattack&autoattack=99112152&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=0;
			break;
		default:
			abort("Unrecognised combat macro");
	}
}

void fun_guy()
{
	print("Doing fun-guy quest","green");
	use_familiar($familiar[fancypants scarecrow]);
	string max_str = "maximize items, -equip gravy-covere, +equip pantsgiving";
	print(max_str + ", +equip mayfly bait necklace");
	cli_execute(max_str + ", +equip mayfly bait necklace");
	set_combat_macro();
	setMood("i");
	
	while(my_adventures()>0 && i_a("pencil thin mushroom") < 10)
	{
		if(get_property("_mayflySummons").to_int()>=30 && equipped_amount($item[mayfly bait necklace])>0)
			cli_execute(max_str);
		adventure(1,$location[the fun-guy mansion]);
	}
	
	//hand in the quest
	int num_coins = i_a("Beach Bucks");
	visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc1");
	visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=Yeah%2C+here+you+go.");
	if(num_coins == i_a("Beach Bucks"))
	{
		abort("Tried to hand  quest, but num coins went from "+num_coins+" to "+i_a("Beach Bucks"));
	}
}

void diner()
{
	print("Doing paradise cheeseburger","green");
	setMood("");
	
	if(have_effect($effect[on the trail])>0 && get_property("olfactedMonster")!="sloppy seconds burger")
		cli_execute("uneffect on the trail");
	
	use_familiar($familiar[Pair of Stomping Boots]);
	if(i_a("moveable feast")>0)
		use(1,$item[moveable feast]);
	string max_str = "maximize familiar weight, +equip paradais, +equip pantsgiving";
	print(max_str + ", +equip mayfly bait necklace");
	cli_execute(max_str + ", +equip mayfly bait necklace");
	set_combat_macro("cheeseburger");
	while(my_adventures()>0 && !contains_text(visit_url("questlog.php?which=7"), "Take the ingredients back to "))
	{
		//done with runaways
		if(my_familiar()==$familiar[pair of stomping boots] && (get_property("_banderRunaways") >= ((familiar_weight($familiar[Pair of Stomping Boots]) + weight_adjustment())/5)))
		{
			if(my_path()!="Avatar of Sneaky Pete")
				use_familiar($familiar[artistic goth kid]);
			max_str = "maximize +equip paradais, +equip greatest american pants";
			print(max_str + ", +equip mayfly bait necklace");
			cli_execute(max_str + ", +equip mayfly bait necklace");
		}
		//done with mayfly?
		if(get_property("_mayflySummons").to_int()>=30 && equipped_amount($item[mayfly bait necklace])>0)
			cli_execute(max_str);
		adventure(1,$location[sloppy seconds diner]);
	}
	
	//hand in the quest
	int num_coins = i_a("Beach Bucks");
	visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc1");
	visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=Yeah%2C+here+you+go.");
	if(num_coins == i_a("Beach Bucks"))
	{
		abort("Tried to hand in conspiracy quest, but num coins went from "+num_coins+" to "+i_a("Beach Bucks"));
	}
}

void ship()
{
	print("Doing shipwreck","green");
	
	if(have_effect($effect[on the trail])>0 && get_property("olfactedMonster")!="son of a son of a sailor")
		cli_execute("uneffect on the trail");
		
	use_familiar($familiar[purse rat]);
	if(i_a("moveable feast")>0)
		use(1,$item[moveable feast]);
	string max_str = "maximize ml, +sea, +equip greatest american";
	print(max_str + ", +equip mayfly bait necklace");
	cli_execute(max_str + ", +equip mayfly bait necklace");
	
	setMood("l");
	set_combat_macro("sailors");
	
	use_skill(1,$skill[spirit of wormwood]);
	
	if( inebriety_limit() - my_inebriety() > 2)
	{
		use_skill(1, $skill[the ode to booze]);
		drink(1, $item[flaming caipiranha]);
	}
	
	while(my_adventures()>0 && i_a("salty sailor sal") < 50)
	{
		if(get_property("_mayflySummons").to_int()>=30 && equipped_amount($item[mayfly bait necklace])>0)
			cli_execute(max_str);
		cli_execute("restore hp");
		adventure(1,$location[the sunken party yacht]);
	}
	
	//hand in the quest
	int num_coins = i_a("Beach Bucks");
	visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc1");
	visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=Yeah%2C+here+you+go.");
	if(num_coins == i_a("Beach Bucks"))
	{
		abort("Tried to hand in conspiracy quest, but num coins went from "+num_coins+" to "+i_a("Beach Bucks"));
	}
}

void conspiracy()
{
	if(get_property("_conspiracy_done").to_boolean())
		return;
		
	//check/get quest
	visit_url("place.php?whichplace=airport_spooky&action=airport2_radio");
	visit_url("choice.php?pwd&whichchoice=984&option=1&choiceform1=Reply");
	
	//Do relevant quest
	string qlog = visit_url("questlog.php?which=7");
	if(i_a("encrypted micro-cassette recorder")>0)
	{
		if(my_path()!="Avatar of Sneaky Pete")
			use_familiar($familiar[disembodied hand]);
		string max_str = "maximize mysticality, +equip encrypted micro-cassette recorder, +equip pantsgiving";
		print(max_str + ", +equip mayfly bait necklace");
		cli_execute(max_str + ", +equip mayfly bait necklace");
		set_combat_macro("warbear");
		setMood("");
		while(contains_text(visit_url("questlog.php?which=7"),"Your mysterious contact wants you to wander around the") && my_adventures()>0)
		{
			if(get_property("_mayflySummons").to_int()>=30 && equipped_amount($item[mayfly bait necklace])>0)
				cli_execute(max_str);
			adventure(1,$location[The deep dark jungle]);
		}
	}
	else if (contains_text(qlog,"choking on the rind"))
	{
		//get directions
		visit_url("place.php?whichplace=airport_spooky&action=airport2_radio");
		string radio = visit_url("choice.php?pwd&whichchoice=984&option=1&choiceform1=Reply");
		matcher radio_mtch = create_matcher("Navigation protocol ([Lima |Romeo ]*) is advised.",radio);
		//Navigation protocol Lima Lima Romeo Lima Romeo is advised.
		abort("Not implemented");
	}
	else if(i_a("gore bucket")>0)
	{
		if(my_path()!="Avatar of Sneaky Pete")
			use_familiar($familiar[disembodied hand]);
		string max_str = "maximize mainstat, +equip gore bucket, +equip Personal Ventilation Unit";
		if(my_primestat()==$stat[moxie])
			max_str += ", -melee";
		else if(my_primestat()==$stat[muscle])
			max_str += ", +melee";
		print(max_str + ", +equip mayfly bait necklace", "green");
		cli_execute(max_str + ", +equip mayfly bait necklace");
		set_combat_macro();
		setMood("");
		while(contains_text(visit_url("questlog.php?which=7"),"Your mysterious contact wants you to go to the") && my_adventures()>0)
		{
			if(get_property("_mayflySummons").to_int()>=30 && equipped_amount($item[mayfly bait necklace])>0)
				cli_execute(max_str);
			adventure(1,$location[the Secret Government Laboratory]);
		}
	}
	else if(i_a("GPS-tracking wristwatch")>0)
	{
		if(my_path()!="Avatar of Sneaky Pete")
			use_familiar($familiar[disembodied hand]);
		string max_str = "maximize init, +equip GPS-tracking wristwatch, -equip helps-you-sleep, +equip pantsgiving";
		print(max_str + ", +equip mayfly bait necklace");
		cli_execute(max_str + ", +equip mayfly bait necklace");
		set_combat_macro();
		setMood("");
		while(i_a("Project T. L. B.")<1 && my_adventures()>0)
		{
			if(get_property("_mayflySummons").to_int()>=30 && equipped_amount($item[mayfly bait necklace])>0)
				cli_execute(max_str);
			adventure(1,$location[the deep dark jungle]);
		}
	}
	else if(i_a("Military-grade fingernail clippers")>0)
	{
		if(my_path()!="Avatar of Sneaky Pete")
			use_familiar($familiar[disembodied hand]);
		string max_str = "maximize mainstat, +equip pantsgiving";
		print(max_str + ", +equip mayfly bait necklace");
		cli_execute(max_str + ", +equip mayfly bait necklace");
		clear_combat_macro();
		setMood("");
		while(contains_text(visit_url("questlog.php?which=7"),"Your mysterious contact wants you to gather fingernail clippings from the") && my_adventures()>0)
		{
			if(get_property("_mayflySummons").to_int()>=30 && equipped_amount($item[mayfly bait necklace])>0)
				cli_execute(max_str);
			adventure(1,$location[The Mansion of Dr. Weirdeaux],"consultFingernail");
		}
	}
	else
		abort("Not sure what conspiracy quest we just got");
		
	//now hand in
	int num_coins = i_a("coinspiracy");
	visit_url("place.php?whichplace=airport_spooky&action=airport2_radio");
	visit_url("choice.php?pwd&whichchoice=984&option=1&choiceform1=Reply");	
	if(num_coins == i_a("coinspiracy"))
	{
		abort("Tried to hand in conspiracy quest, but num coins went from "+num_coins+" to "+i_a("coins-piracy"));
	}
	set_property("_conspiracy_done","true");
}

string consultFingernail(int round, string opp, string text) {
	print("called consult fingernail","purple");
	throw_item($item[Military-grade fingernail clippers]);
	throw_item($item[Military-grade fingernail clippers]);
	throw_item($item[Military-grade fingernail clippers]);
	string out = bumRunCombat();
	if(contains_text(out,"Macro Aborted")) abort("Seems macro failed");
	return get_ccs_action(round);
}	

void spring_break()
{
	//do we already have a quest?
	string quest_log = visit_url("questlog.php?which=7");
	if(contains_text(quest_log,"Pencil-Thin Mush Stash"))
	{
		fun_guy();
	}
	else if(contains_text(quest_log,"Paradise Cheeseburger"))
	{
		diner();
	}
	else if(contains_text(quest_log,"Lost Shaker of Salt"))
	{
		ship();
	}
	else
	{
		//start talking to buff jimmy
		string jimmy = visit_url("place.php?whichplace=airport_sleaze&action=airport1_npc1");
		
		//first time, we need to talk once more
		if(contains_text(jimmy,"Just Fine, Thanks"))
			jimmy = visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=Hangin%27+Just+Fine%2C+Thanks");
		
		//choose an available quest
		if(contains_text(jimmy,"I can help get your stash"))
		{
			visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=I+can+help+get+your+stash");
			visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=Ready+As+I%27ll+Ever+Be");
			fun_guy();
		}
		else if(contains_text(jimmy,"I can help you make your burger"))
		{
			visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=I+can+help+you+make+your+burger");
			visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=I+Was+Born+Ready");
			diner();
		}
		else if(contains_text(jimmy,"I can help with your saltshaker"))
		{
			visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=I+can+help+with+your+saltshaker");
			visit_url("choice.php?pwd&whichchoice=915&option=1&choiceform1=I+can+help+with+your+saltshaker");
			ship();
		}
	}
}

void diner_farm()
{
	print("Farming bucks","green");
	setMood("");
	
	if(my_path()!="Avatar of Sneaky Pete")
		use_familiar($familiar[artistic goth kid]);
	string max_str = "+equip greatest american";
	set_combat_macro("sailors"); //skip all
	while(my_adventures()>0 && get_property("_sloppyDinerBeachBucks").to_int() < 4)
	{
		adventure(1,$location[sloppy seconds diner]);
	}
	set_combat_macro();
}

void garbage_handin()
{
	if(!get_property("_dinseyGarbageDisposed").to_boolean())
	{
		if(i_a("bag of park garbage")<1)
			buy(1,$item[bag of park garbage]);
		visit_url("place.php?whichplace=airport_stench&action=airport3_tunnels");
		visit_url("choice.php?pwd&whichchoice=1067&option=6&choiceform6=Waste+Disposal");
	}
	
}

void volcano()
{
	//try to hand in
	if(!get_property("_volcanoItemRedeemed").to_boolean())
		abort("Hand in at volcano (pref loot, then travoltron, fused fuse is least desirable to hand in)");
	
	//try to get another voltron drop
/*******************quest items
	if(i_a("Saturday Night thermometer")<1 && !get_property("_infernoDiscoVisited").to_boolean())
	{
		cli_execute("familiar disembodied");
		print("maximize mainstat, +equip smooth velvet pocket, +equip smooth velvet socks, +equip smooth velvet hat");
		cli_execute("maximize mainstat, +equip smooth velvet pocket, +equip smooth velvet socks, +equip smooth velvet hat");
		//fight travoltron
		visit_url("place.php?whichplace=airport_hot&action=airport4_zone1");
		visit_url("choice.php?pwd&whichchoice=1090&option=4&choiceform4=Go+to+the+third+floor");
	}
	
	//try to get another fused fuse
	if(i_a("fused fuse")<1)
	{
		cli_execute("familiar disembodied");
		print("maximize 0.01 mainstat, -combat, +equip pantsgiving; cast 3 smooth; cast 3 sonata");
		cli_execute("maximize 0.01 mainstat, -combat, +equip pantsgiving; cast 3 smooth; cast 3 sonata");
		
		while(i_a("fused fuse")<1)
		{
			set_property("choiceAdventure1091","7");
			adventure(1, $location[LavaCo Lamp Factory]);
		}
	}
	*/
	//get buyable items
	if(i_a("gooey lava globs")< 5)
		buy(5, $item[gooey lava globs]);
	if(i_a("New Age healing crystal")< 5)
		buy(5, $item[New Age healing crystal]);
	if(i_a("superduperheated metal")< 1)
		buy(1, $item[superduperheated metal]);
//	if(i_a("SMOOCH bracers")< 3)
//		buy(3, $item[SMOOCH bracers]);
	if(i_a("smooth velvet bra")< 3)
	{
		buy(9, $item[unsmoothed velvet]);
		create(3, $item[smooth velvet bra]);
	}

if(my_path()!="Gelatinous Noob")
{	
	//if we didn't fight travoltron today, get an extra volcoino
	if(!get_property("_infernoDiscoVisited").to_boolean())
	{
		cli_execute("familiar disembodied");
		print("maximize mainstat, +equip smooth velvet pocket, +equip smooth velvet socks, +equip smooth velvet hat, +equip smooth velvet shirt, +equip smooth velvet hanky, +equip smooth velvet pants");
		cli_execute("maximize mainstat, +equip smooth velvet pocket, +equip smooth velvet socks, +equip smooth velvet hat, +equip smooth velvet shirt, +equip smooth velvet hanky, +equip smooth velvet pants");
		//visit disco
		visit_url("place.php?whichplace=airport_hot&action=airport4_zone1");
		visit_url("choice.php?pwd&whichchoice=1090&option=7&choiceform7=Go+to+the+sixth+floor");
	}
}
}

void dinsey()
{
	garbage_handin();
	//get a quest
	//http://127.0.0.1:60082/place.php?whichplace=airport_stench&action=airport3_kiosk
	//if(i_a("")<
	/* 
	electrucak maintenance - 0!
	compulsory fun - 15
	waterway debris - 20
	feed tourists - 18
	bears - (84% encounter after olfact... somehwere around 10 turns)
	rollercoaster maintenance - ~20 turns (15 after maintenance)
	sexism - 15 tusn?
	racism - 15 turns?
	*/
	
	
	
	use_familiar($familiar[disembodied hand]);
	string max_str = "maximize mainstat";
	if(my_primestat()==$stat[moxie])
		max_str += ", -melee";
	else if(my_primestat()==$stat[muscle])
		max_str += ", +melee";
	print(max_str + ", +equip mayfly bait necklace", "green");
	cli_execute(max_str + ", +equip mayfly bait necklace");
		
	abort("do dinsey");
}

void glaciest()
{
	abort("do glaciest");
}

void main()
{
//	if(i_a("beach buck")>=500)
//		abort("buy airport duty free tattoo then stop farming bucks");
	
	if(i_a("coinspiracy")>=50 && i_a("mercenary rifle")<1)
		abort("buy mercenary rifle wtih coinspiracy");
	if(i_a("coinspiracy")>=50 && i_a("mercenary pistol")<3)
		abort("buy mercenary pistol wtih coinspiracy");
/*	if(i_a("coinspiracy")>=300 && !have_skill($skill[Intimidating Mien]))
		abort("buy Intimidation Techniques book wtih coinspiracy");
	if(i_a("coinspiracy")>=300 && !have_skill($skill[Hypersane]))
		abort("buy Sanity Maintenance book wtih coinspiracy");*/
//	if(i_a("coinspiracy")>=1000)
//		print("buy tattoo wtih coinspiracy THEN STOP FARMING","red");
	if(i_a("Merc Core Field Manual: Sanity Maintenance")>0 || i_a("Merc Core Field Manual: Intimidation Techniques ")>0)
		print("READ MERC BOOKS","red");
//	if(i_a("coinspiracy")>=300)
//		abort("FINISHED SAVING FOR DUTY FREE, STOP FARMING coinspiracy");
		
	if(i_a("FunFunds")>=50 && !have_skill($skill[Dinsey Operations Expert]))
		abort("buy Dinsey Maintenance Manual with FunFunds");
	if(i_a("FunFunds")>=50 && !have_skill($skill[Olfactory Burnout]))
		abort("buy Scratch-and-Sniff Guide to Dinseylandfill with FunFunds");
	if(i_a("FunFunds")>=50 && !have_skill($skill[Garbage Nova]))
		abort("buy Trash, a Memoir with FunFunds");
	if(have_skill($skill[Garbage Nova]) && have_skill($skill[Olfactory Burnout]) &&  have_skill($skill[Dinsey Operations Expert]))
	{
		if(i_a("FunFunds")>=25 && i_a("Stinky fannypack")<3)
			abort("buy Stinky fannypack with FunFunds");
			//------------------------------
		if(i_a("FunFunds")>=25 && i_a("Garbage sticker")<3)
			abort("buy Garbage sticker with FunFunds");
		if(i_a("FunFunds")>=25 && i_a("Hazmat helmet")<2)
			abort("buy Hazmat helmet with FunFunds");
	}
	if(i_a("FunFunds")>=100)
		abort("buy dinsey tattoo with FunFunds then uncomment below");
	//if(i_a("funfunds")>=)
	//	abort("buy airport duty free tattoo then stop farming funfunds");
		
/*	if(i_a("Volcoino")>=10 && !have_skill($skill[Asbestos Heart]))
		abort("buy Lava Miner's Daughter with Volcoino");
	if(i_a("Volcoino")>=10 && !have_skill($skill[Firegate]))
		abort("buy 	The Firegate Tapes with Volcoino");
	if(i_a("Volcoino")>=10 && !have_skill($skill[Pyromania]))
		abort("buy Psycho From The Heat with Volcoino");
*/	if(have_skill($skill[Asbestos Heart]) && have_skill($skill[Pyromania]) &&  have_skill($skill[Firegate]))
	{
		if(i_a("Volcoino")>=5 && i_a("Biker's hat")<2)
			abort("buy Biker's hat with Volcoino");
		if(i_a("Volcoino")>=5 && i_a("Feathered headdress")<2)
			abort("buy Feathered headdress with Volcoino");
		if(i_a("Volcoino")>=5 && i_a("Electrician's hardhat")<2)
			abort("buy Electrician's hardhat with Volcoino");
	}
	//if(i_a("Volcoino")>=30)
	//	abort("buy volcano tattoo with valcoino then uncomment below");
	//if(i_a("Volcoino")>=20)
	//	abort("buy airport duty free tattoo then stop farming funfunds");
		

	if(i_a("Wal-Mart gift certificate")>=75 && i_a("Wal-Mart snowglobe")<1)
		abort("buy Wal-Mart snowglobe with Wal-Mart gift certificate");
	if(i_a("Wal-Mart gift certificate")>=75 && i_a("Wal-Mart nametag")<3)
		abort("buy Wal-Mart nametag with Wal-Mart gift certificate");
	if(i_a("Wal-Mart gift certificate")>=75 && i_a("Wal-Mart overalls")<2)
		abort("buy Wal-Mart overalls with Wal-Mart gift certificate");
//	if(i_a("Wal-Mart gift certificate")>=250)
//		abort("buy volcano tattoo with Wal-Mart gift certificate then uncomment below");
//	if(i_a("Wal-Mart gift certificate")>=200)
//		abort("buy airport duty free tattoo then stop farming Wal-Mart gift certificate");
		
	//spring_break();
	//conspiracy();
	//volcano();
	//diner_farm();
	dinsey();
//	glaciest();
}