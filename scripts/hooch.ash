import bumcheekascend;

void farm_hooch()
{
	if(!get_property("_borrowedTimeUsed").to_boolean())
		use(1,$item[borrowed time]);
		
	//get hooch gear
	setFamiliar("hipster");
	string max_str = "0.01 "+to_string(my_primestat());
	max_str += ", +equip 4-dimensional fez, +equip super-absorbent tarp, +equip birdbone corset, +equip law-abiding citizen cane, +equip hep waders, +equip banjo kazoo mount, +equip flask flops, +equip time-twitching toolbelt";
	if(i_a("time lord participation mug")>0)
		max_str +=", +equip time lord participation mug";
	cli_execute("maximize "+max_str);
	setMood("i");
	
	adventure(1,$location[An illicit bohemian party]);
	//need to hand in
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
	while(true)
	{
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
//dinala - done all
//twistedmage - done paper, 109
//play chance, trade paper, trade scissors, play chance

//ash set_property("SIMON_CAVVEDONE","true");
void main()
{
	set_combat_macro();
	set_property("valueOfAdventure","2000");
	if(!get_property("SIMON_CAVVEDONE").to_boolean())
		cave();
	else
		farm_hooch();
}