import bumcheekascend;

void wild_west()
{
	string max_str="maximize items, 0.01 mainstat";
	if(my_primestat()==$stat[muscle])
		max_str+=" +melee";
	if(my_primestat()==$stat[moxie])
		max_str+=" -melee";
	if(i_a("time-twitching toolbelt")>0)
		max_str+=" +equip time-twitching toolbelt";
	if(i_a("pantsgiving")>0)
		max_str+=" +equip pantsgiving";
	if(i_a("time cloak")>0)
	{
		max_str+=" +equip time cloak";
	}
	else if(i_a("time cape")>0)
	{
		max_str+=" +equip time cape";
	}
	cli_execute(max_str);
	setFamiliar("items");
	while(my_adventures()>0)
	{
		setMood("i");
		if(have_effect($effect[brainworm])==0 && inebriety_limit() - my_inebriety() >= 3)
			drink(1, $item[shot of mescal]);
		
		if(i_a("pocket ace")>0)
			set_property("choiceAdventure998",5);
		else
			set_property("choiceAdventure998",2);
			
		adventure(1,$location[the rowdy saloon]);
//		adventure(1,$location[the spooky old abandoned mine]);
	}	
}

void cave()
{
	if(!get_property("_borrowedTimeUsed").to_boolean())
		use(1,$item[borrowed time]);

	//choose teams
	if(!get_property("SIMON_TEAM").to_boolean())
	{
		visit_url("place.php?whichplace=twitch&action=twitch_votingbooth");
		visit_url("choice.php?pwd&whichchoice=950&option=3&choiceform3=Choose+a+team");
		visit_url("choice.php?pwd&whichchoice=952&option=3&choiceform3=Give+me+that+money+and+pick+for+me");
		visit_url("choice.php?pwd&whichchoice=950&option=6&choiceform6=Leave+the+booth");
		set_property("SIMON_TEAM","true");
	}
			
	if(!get_property("SIMON_DANCAVE").to_boolean())
		visit_url("place.php?whichplace=twitch&action=twitch_dancave1");
	set_property("SIMON_DANCAVE","true");
	
	//setup gear etc
	if(have_outfit("twitch"))
	{
		cli_execute("outfit twitch");
	}
	else
	{
		string max_str = "0.01 "+to_string(my_primestat());
		max_str += ", items, +equip time-twitching toolbelt";
		cli_execute("maximize "+max_str);
		cli_execute("outfit save twitch");
	}
	setMood("i");
	
/*		if(have_familiar($familiar[mini-hipster]))
		{
			if(get_property("_hipsterAdv").to_int()<7)
			{
				use_familiar($familiar[mini-hipster]);
			}
			else
			{
				use_familiar($familiar[frumious bandersnatch]);
				use_skill(1,$skill[the ode to booze]);
				clear_combat_macro();
				abort("runaways");
			}
		}
		else*/
			setFamiliar("items");
			
	while(true)
	{
		set_property("choiceAdventure955", 3); //talk to ook
/*		if(get_property("SIMON_OOK").to_int()==3)
			set_property("choiceAdventure954", 3); //ask password
		else
		{
			set_property("choiceAdventure954", 1); //ask password
		}
	*/		
		//set_property("choiceAdventure954", );
		//play chance, trade paper, trade scissors, play chance
		adventure(1,$location[The cave before time]);
//		abort("a");
	}
}
//asica - done all
//anid - done all
//dinala - done all
//twistedmage - done all, 80
//play chance, trade paper, trade scissors, play chance

void farm_hooch()
{
	if(!get_property("_borrowedTimeUsed").to_boolean())
		use(1,$item[borrowed time]);
		
	//get hooch gear
	if(have_familiar($familiar[disembodied hand]))
		use_familiar($familiar[disembodied hand]);
	else
		setFamiliar("items");
	string max_str = "0.01 "+to_string(my_primestat());
	max_str += ", +equip super-absorbent tarp, +equip law-abiding citizen cane, +equip hep waders, +equip banjo kazoo mount, +equip flask flops, +equip time-twitching toolbelt";
	if(have_skill($skill[torso awaregness]))
		max_str += ", +equip birdbone corset";
	if(i_a("time lord participation mug")>0)
		max_str +=", +equip time lord participation mug";
	cli_execute("maximize "+max_str);
	setMood("i");
	
	while(my_adventures()>0)
	{
		matcher hooch_mtch = create_matcher("Hooch:</td><td align=left><b>(\\d*) / (\\d*)",visit_url("charpane.php"));
		find(hooch_mtch);
		int cur_hooch = group(hooch_mtch,1).to_int();
		int max_hooch = group(hooch_mtch,2).to_int();
		if(max_hooch - cur_hooch < 5)
		{
			visit_url("place.php?whichplace=twitch&action=twitch_shoerepair");
			visit_url("choice.php?pwd&whichchoice=973&option=2&choiceform2=Turn+in+Hooch+%281+Adventure%29");
		}
		adventure(1,$location[An illicit bohemian party]);
	}
	//need to hand in
}


void capsule_farm()
{	
	//setup gear etc
	if(have_outfit("twitch"))
	{
		cli_execute("outfit twitch");
	}
	else
	{
		string max_str = "0.01 "+to_string(my_primestat());
		max_str += ", items, +equip time-twitching toolbelt";
		cli_execute("maximize "+max_str);
		cli_execute("outfit save twitch");
	}
	setMood("i");
	setFamiliar("items");
			
	while(my_adventures()>0)
	{
		set_property("choiceAdventure955", 2); //capsule
		adventure(1,$location[The cave before time]);
		if(i_a("Twitching time capsule")!=0)
		{
			cli_execute("stash put * twitching time capsule");
		}
	}
}

void dump_gear()
{
	cli_execute("outfit birthday suit");
/*	if(i_a("4-dimensional fez")>0)
		cli_execute("stash put * 4-dimensional fez");
	if(i_a("super-absorbent tarp")>0)
		cli_execute("stash put * super-absorbent tarp");
	if(i_a("birdbone corset")>0)
		cli_execute("stash put * birdbone corset");
	if(i_a("law-abiding citizen cane")>0)
		cli_execute("stash put * law-abiding citizen cane");
	if(i_a("hep waders")>0)
		cli_execute("stash put * hep waders");
	if(i_a("banjo kazoo mount")>0)
		cli_execute("stash put * banjo kazoo mount");
	if(i_a("flask flops")>0)
		cli_execute("stash put * flask flops");
	if(i_a("time lord participation mug")>0)
		cli_execute("stash put * time lord participation mug");*/
	if(i_a("time-twitching toolbelt")>0)
		cli_execute("stash put * time-twitching toolbelt");
}

void pull_gear()
{
	cli_execute("refresh_stash");
/*	cli_execute("stash take * 4-dimensional fez");
	cli_execute("stash take * super-absorbent tarp");
	cli_execute("stash take * birdbone corset");
	cli_execute("stash take * law-abiding citizen cane");
	cli_execute("stash take * hep waders");
	cli_execute("stash take * banjo kazoo mount");
	cli_execute("stash take * flask flops");
	cli_execute("stash take * time lord participation mug");*/
	cli_execute("stash take * time-twitching toolbelt");	
}



void roman_farm()
{
	//setup gear etc
	if(have_outfit("twitch"))
	{
		cli_execute("outfit twitch");
	}
	else
	{
		string max_str = "0.01 "+to_string(my_primestat());
		max_str += ", items, +equip time-twitching toolbelt";
		if(i_a("pantsgiving")>0)
			max_str +=", +equip pantsgiving";
		cli_execute("maximize "+max_str);
		cli_execute("outfit save twitch");
	}
	setMood("i");
	setFamiliar("items");
	int advs=1;
	int desired_gear = 2;
	while(my_adventures()>0)
	{
//		adventure(1,$location[The Roman Forum]);
		if(available_amount(to_item(7722))<desired_gear || available_amount(to_item(7724))<desired_gear)
		{
			set_property("choiceAdventure979", 2); //99 cent store
			if(available_amount(to_item(7722))<desired_gear)
				set_property("choiceAdventure982", 1); //buy hat
			else
				set_property("choiceAdventure982", 2); //pteruges
		}
		else
		{
			//set_property("choiceAdventure979", 1); //blessings
			set_property("choiceAdventure979", 6); //gamble
			set_property("choiceAdventure983", 1); //gamble		for real
		}
		/*
		betweenBattle();
		print("adventure "+to_string(advs),"purple");
		visit_url("adventure.php?snarfblat=414");
		string str=bumRunCombat();*/
		adventure(1,$location[the roman forum]);
		advs+=1;
//		if(!contains_text(str,"WINWINWIN"))
//			abort("Seem to have failed?");
	}
}


void apocalypse()
{
//	clear_combat_macro();
	if(to_int(get_property("_hipsterAdv"))< 7 && have_familiar($familiar[mini-hipster]))
		use_familiar($familiar[mini-hipster]);
	if(have_familiar($familiar[warbear drone]))
		use_familiar($familiar[warbear drone]);
	else
		use_familiar($familiar[mosquito]);
	//outfit
	string max_str = "0.01 "+to_string(my_primestat())+", +equip time-twitching toolbelt";
	if(my_primestat()==$stat[muscle])
		max_str += ", +melee";
	if(my_primestat()==$stat[moxie])
		max_str += ", -melee";
	
	if(my_primestat()==$stat[mysticality])
		max_str += ", 100 spell damage percent, spell damage";	
	else
		max_str += ", 100 weapon damage percent, weapon damage, elemental damage";
	if(i_a("mayfly bait")>0 && get_property("_mayflySummons").to_int() <30)
		max_str += "+equip mayfly bait";	
	cli_execute("maximize "+max_str);
	setMood("");
	
	//
	while(my_adventures()>0)
	{
/*		if(my_primestat()==$stat[muscle])
		{
			if(have_effect($effect[Incredibly Hulking])==0)
			{
				use(1,$item[Ferrigno's Elixir of Power]);
			}
			if(have_effect($effect[Phorcefullness])==0)
			{
				use(1,$item[philter of phorce]);
			}
			if(have_effect($effect[ham-fisted])==0)
			{
				use(1,$item[jug of hamethyst juice]);
			}
		}
		else if(my_primestat()==$stat[moxie])
		{
			if(have_effect($effect[superhuman sarcasm])==0)
			{
				use(1,$item[serum of sarcasm]);
			}
			if(have_effect($effect[cock of the walk])==0)
			{
				use(1,$item[Connery's Elixir of Audacity]);
			}
			if(have_effect($effect[je ne sais porquoise])==0)
			{
				use(1,$item[jug of porquoise juice]);
			}
		}*/
		cli_execute("mood execute; restore hp; restore mp");
		string str = visit_url("adventure.php?snarfblat=418");
		str=bumRunCombat();
	}
	
}

//ash set_property("SIMON_CAVVEDONE","true");
void main()
{
	cli_execute("inventory refresh");
	
//	pull_gear();
//	set_combat_macro();
//	set_property("valueOfAdventure","2000");
	wild_west();
	if(!get_property("SIMON_CAVVEDONE").to_boolean())
	{
		cave();
	}
	else
	{
		apocalypse();
		//roman_farm();
		//capsule_farm();
	}
//		farm_hooch();
}
//stuff from new store
//anid has earbuds
//3 iflail (asica has one, twistedmage has one)
//ishield (twistedmage has)
