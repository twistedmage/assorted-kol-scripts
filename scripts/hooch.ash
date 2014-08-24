import bumcheekascend;

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
	max_str += ", +equip super-absorbent tarp, +equip birdbone corset, +equip law-abiding citizen cane, +equip hep waders, +equip banjo kazoo mount, +equip flask flops, +equip time-twitching toolbelt";
	if(i_a("time lord participation mug")>0)
		max_str +=", +equip time lord participation mug";
	+equip 4-dimensional fez, 
	cli_execute("maximize "+max_str);
	setMood("i");
	
	while(true)
		adventure(1,$location[An illicit bohemian party]);
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
			
	while(true)
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
	if(i_a("4-dimensional fez")>0)
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
	if(i_a("time-twitching toolbelt")>0)
		cli_execute("stash put * time-twitching toolbelt");
	if(i_a("time lord participation mug")>0)
		cli_execute("stash put * time lord participation mug");
}

void pull_gear()
{
	cli_execute("refresh stash");
	cli_execute("stash take * 4-dimensional fez");
	cli_execute("stash take * super-absorbent tarp");
	cli_execute("stash take * birdbone corset");
	cli_execute("stash take * law-abiding citizen cane");
	cli_execute("stash take * hep waders");
	cli_execute("stash take * banjo kazoo mount");
	cli_execute("stash take * flask flops");
	cli_execute("stash take * time-twitching toolbelt");
	cli_execute("stash take * time lord participation mug");	
}


//ash set_property("SIMON_CAVVEDONE","true");
void main()
{
	pull_gear();
	set_combat_macro();
	set_property("valueOfAdventure","2000");
	if(!get_property("SIMON_CAVVEDONE").to_boolean())
		cave();
	else
		farm_hooch();
}