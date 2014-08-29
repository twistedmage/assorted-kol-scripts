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
			clear_combat_macro();
			set_property("choiceAdventure155", "4");
			set_property("battleAction","try to run away");
			cli_execute("goal clear");
			setFamiliar("items");
			cli_execute("mood clear");
		//	cli_execute("maximize items, -combat frequency");
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
	abort("run autobasement");
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
	if(get_property("last_chilly_checked_asc").to_int()<my_ascensions())
	{
		//extreme peak open
		if(contains_text(visit_url("place.php?whichplace=mclargehuge"),"adventure.php?snarfblat=273"))
		{
			//set choiceadv for deboner, set combat to runaway, then adv until choiceadventure
			set_property("choiceAdventure575", 2);
			cli_execute("goal clear");
			setFamiliar("items");
			cli_execute("mood clear");
			cli_execute("maximize items, -combat frequency");
			if (have_skill($skill[Smooth Movement])) cli_execute("trigger lose_effect, Smooth Movements, cast 1 smooth movement");
			if (have_skill($skill[The Sonata of Sneakiness])) cli_execute("trigger lose_effect, The Sonata of Sneakiness, cast 1 sonata of sneakiness");
			while(my_adventures()>0 && get_property("lastEncounter") != "Duffel on the Double")
			{
				adv1($location[The extreme slope], -1, "");
			}
		}
		set_property("last_chilly_checked_asc",my_ascensions());
	}
}
void unlock_ghost()
{
	//ghost dog
	int desired_bones=1;
	if(my_name()=="twistedmage")
		desired_bones=3;
	if(i_a("gnawed-up dog bone")>=desired_bones)
		abort("Have a gnawed-up dog bone! Disable this part of hotdog_ulock.ash");
	if(my_name()!="twistedmage")
	{
		print("************* SKIPPING GHOST DOG FOR NON TWISTEDMAGE CHARS**************","red");
		return;
	}
	use_familiar($familiar[nosy nose]);
	abort("line 111 Set combat macro to skeletal_cat");
	while(my_adventures()>0 && i_a("gnawed-up dog bone")<desired_bones)
	{
		print("Hunting for dog bone","blue");
		adventure(1,$location[haunted conservatory]);
	}
}
void unlock_junkyard()
{
	//junkyard dog
	if(i_a("Grey Guanon")>0)
		abort("Have a Grey Guanon! Disable this part of hotdog_ulock.ash");

	while(my_adventures()>0 && i_a("Grey Guanon")<1)
	{
		bumAdv($location[guano junction], "stench res", "", "", "Hunting for guanon", "");
	}
}
void unlock_wet()
{
	//wet dog
	if(i_a("Engorged Sausages and You")>0)
		abort("Have a Engorged Sausages and You! Disable this part of hotdog_ulock.ash");
	//manor 2 open
	if(can_adv($location[the haunted bedroom]))
	{
		//choiceadvs
		set_property("choiceAdventure878", 4); //disposablle camera
		set_property("choiceAdventure880", 2); //elegant nightstick
		set_property("choiceAdventure879", 4); //sausages or moxie

		while(my_adventures()>0 && !get_property("_wet_checked_today").to_boolean())
		{
			bumAdv($location[the haunted bedroom], "", "", "", "looking for engorged sausages (wet dog)", "");
			run_combat();

//			cli_execute("mood execute");
			if(get_property("lastEncounter")=="One Rustic Nightstand")
				set_property("_wet_checked_today","true");
		}
	}
}
void unlock_optimal()
{
	//optimal dog
	if(i_a("optimal spreadsheet")>0)
		abort("Have a optimal spreadsheet! Disable this part of hotdog_ulock.ash");
	//unlock menagerie
	while(my_adventures()>0 && !can_adv($location[cobb's knob menagerie\, level 1]))
	{
		adventure(1,$location[cobb's knob laboratory]);
	}


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
	abort("sleeping Not implemented");
}
	
void unlock_hotdogs()
{
	unlock_video(); //2 more
	unlock_sly(); //4 more
	unlock_wet(); //2 more
	unlock_chilly(); //1 more
	unlock_junkyard(); //1 extra
	unlock_ghost(); //3 more
	unlock_optimal(); //1 more
//	unlock_savage(); //0 more
//	unlock_sleeping(); //0 more
//	unlock_owe(); //0 more
//	unlock_devil(); //0 more
	abort("Try to get everything again, to wear as gear");
}

void main()
{
	unlock_hotdogs();
}