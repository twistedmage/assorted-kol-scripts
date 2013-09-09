import "bumcheekascend.ash"

void unlock_video()
{
	//video games hot dog
	if(i_a("defective game grid token")>0)
		abort("Have a defective game grid token! Disable this part of hotdog_ulock.ash");
	//happens during breakfast, just ensure it has
	if(i_a("game grid ticket")<1)
		buy(1,$item[game grid ticket]);
	if(!get_property("_defectiveTokenChecked").to_boolean())
	{
		cli_execute("breakfast");
		if(!get_property("_defectiveTokenChecked").to_boolean())
		{
			abort("checking game grid for defective token not enabled as part of breakfast?");
		}
	}
}
void unlock_savage()
{
	//savage macho dog
	if(i_a("vicious spiked collar")>0)
		abort("Have a vicious spiked collar! Disable this part of hotdog_ulock.ash");
	abort("savage dog not implemented");
}
void unlock_sly()
{
	//sly dog
	if(i_a("debonair deboner")>0)
		abort("Have a debonair deboner! Disable this part of hotdog_ulock.ash");
	if(!get_property("_sly_checked_today").to_boolean())
	{
		//crypt not done
		if(get_property("cyrptNookEvilness").to_int() > 25)
		{
			//set choiceadv for deboner, set combat to runaway, then adv until choiceadventure
			set_property("choiceAdventure155", "4");
			set_property("battleAction","try to run away");
			cli_execute("goal set 1 choiceadv");
			setFamiliar("items");
			cli_execute("mood clear");
			cli_execute("maximize items, -combat frequency");
			if (have_skill($skill[Smooth Movement])) cli_execute("trigger lose_effect, Smooth Movements, cast 1 smooth movement");
			if (have_skill($skill[The Sonata of Sneakiness])) cli_execute("trigger lose_effect, The Sonata of Sneakiness, cast 1 sonata of sneakiness");
			while(my_adventures()>0 && get_property("lastEncounter") != "Skull, Skull, Skull")
				adventure(1,$location[The defiled nook]);
			set_property("battleAction","custom combat script");
		}
		set_property("_sly_checked_today","true");
	}
}
void unlock_owe()
{
	//one with everything
	if(i_a("ancient hot dog wrapper")>0)
		abort("Have a ancient hot dog wrapper! Disable this part of hotdog_ulock.ash");
	abort("Not implemented");
}
void unlock_devil()
{
	//devil dog
	if(i_a("chicle de salchicha")>0)
		abort("Have a chicle de salchicha! Disable this part of hotdog_ulock.ash");
	setFamiliar("items");
	cli_execute("mood clear");
	while(my_adventures()>0 && can_adv($location[south of the border]) && i_a("chicle de salchicha")<1)
		adventure(1,$location[south of the border]);
}
void unlock_chilly()
{
	//chilly dog
	if(i_a("jar of frostigkraut")>0)
		abort("Have a jar of frostigkraut! Disable this part of hotdog_ulock.ash");
	if(!get_property("_chilly_checked_today").to_boolean())
	{
		//extreme peak open
		if(contains_text(visit_url("place.php?whichplace=mclargehuge"),"adventure.php?snarfblat=273"))
		{
			//set choiceadv for deboner, set combat to runaway, then adv until choiceadventure
			set_property("choiceAdventure575", 2);
			cli_execute("goal set 1 choiceadv");
			setFamiliar("items");
			cli_execute("mood clear");
			cli_execute("maximize items, -combat frequency");
			if (have_skill($skill[Smooth Movement])) cli_execute("trigger lose_effect, Smooth Movements, cast 1 smooth movement");
			if (have_skill($skill[The Sonata of Sneakiness])) cli_execute("trigger lose_effect, The Sonata of Sneakiness, cast 1 sonata of sneakiness");
			while(my_adventures()>0 && get_property("lastEncounter") != "Duffel on the Double")
			{
				adventure(1,$location[The extreme slope]);
			}
		}
		set_property("_chilly_checked_today","true");
	}
}
void unlock_ghost()
{
	//ghost dog
	if(i_a("gnawed-up dog bone")>0)
		abort("Have a gnawed-up dog bone! Disable this part of hotdog_ulock.ash");
	abort("Not implemented");
}
void unlock_junkyard()
{
	//junkyard dog
	if(i_a("Grey Guanon")>0)
		abort("Have a Grey Guanon! Disable this part of hotdog_ulock.ash");
	while(my_adventures()>0 && can_adv($location[cobb's knob menagerie\, level 1]) && i_a("Grey Guanon")<1)
		bumAdv($location[guano junction], "", "", "", "Hunting for guanon", "");
}
void unlock_wet()
{
	//wet dog
	if(i_a("Engorged Sausages and You")>0)
		abort("Have a Engorged Sausages and You! Disable this part of hotdog_ulock.ash");
	//manor 2 open
	if(can_adv($location[the haunted bedroom]))
	{
		setFamiliar("items");
		cli_execute("mood clear");
		cli_execute("maximize items, -combat frequency");
		if (have_skill($skill[Smooth Movement])) cli_execute("trigger lose_effect, Smooth Movements, cast 1 smooth movement");
		if (have_skill($skill[The Sonata of Sneakiness])) cli_execute("trigger lose_effect, The Sonata of Sneakiness, cast 1 sonata of sneakiness");
		while(my_adventures()>0 && !get_property("_wet_checked_today").to_boolean())
		{
			set_property("choiceAdventure85", 4);
			cli_execute("mood execute");
			string txt=visit_url("adventure.php?snarfblat=108");
			if(contains_text(txt,"a simple wooden nightstand"))
				set_property("_wet_checked_today","true");
			run_combat();
		}
	}
}
void unlock_optimal()
{
	//optimal dog
	if(i_a("optimal spreadsheet")>0)
		abort("Have a optimal spreadsheet! Disable this part of hotdog_ulock.ash");
	setFamiliar("items");
	cli_execute("mood clear");
	while(my_adventures()>0 && can_adv($location[cobb's knob menagerie\, level 1]))
		adventure(1,$location[cobb's knob menagerie\, level 1]);
}
void unlock_sleeping()
{
	//sleeping dog
	if(i_a("dream of a dog")>0)
		abort("Have a dream of a dog! Disable this part of hotdog_ulock.ash");
	abort("Not implemented");
}
	
void unlock_hotdogs()
{
	unlock_video();
//	unlock_savage();
	unlock_sly();
	unlock_chilly();
	unlock_wet();
	unlock_optimal();
	unlock_owe();
	unlock_devil();
//	unlock_ghost();
//	unlock_junkyard();
	unlock_sleeping();
}

void main()
{
	unlock_hotdogs();
}