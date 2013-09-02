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
			while(my_adventures()>0 && get_property("lastAdventure") != "Skull, Skull, Skull")
				bumAdv($location[The defiled nook], "", "itemsnc", "1 choiceadv", "Hunting for deboner", "-");
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
	abort("Not implemented");
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
			while(my_adventures()>0 && get_property("lastAdventure") != "Duffel on the Double")
				bumAdv($location[The extreme slope], "", "itemsnc", "1 choiceadv", "Hunting for frostigkraut", "-");
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
	abort("Not implemented");
}
void unlock_wet()
{
	//wet dog
	if(i_a("Engorged Sausages and You")>0)
		abort("Have a Engorged Sausages and You! Disable this part of hotdog_ulock.ash");
	if(!get_property("_wet_checked_today").to_boolean())
	{
		//manor 2 open
		if(can_adv($location[the haunted bedroom]))
		{
			set_property("choiceAdventure85", 4);
			while(my_adventures()>0 && get_property("lastAdventure") != "One Nightstand (Wooden)")
				bumAdv($location[the haunted bedroom], "", "itemsnc", "", "Hunting for engorged sausage book", "-");
		}
		set_property("_wet_checked_today","true");
	}
}
void unlock_optimal()
{
	//optimal dog
	if(i_a("optimal spreadsheet")>0)
		abort("Have a optimal spreadsheet! Disable this part of hotdog_ulock.ash");
	while(my_adventures()>0 && can_adv($location[cobb's knob menagerie\, level 1]))
		bumAdv($location[cobb's knob menagerie\, level 1], "", "items", "", "Hunting for frostigkraut", "i");
}
void unlock_sleeping()
{
	//sleeping dog
	if(i_a("dream of a dog")>0)
		abort("Have a dream of a dog! Disable this part of hotdog_ulock.ash");
	abort("Not implemented");
}
	
	/*
The unlocker in the Haunted Bedroom comes from a new choice that is added to the WOODEN nightstand noncombat adventure. On any given day, a given character account will either have the new choice or not. If you see the NC and it doesn't have the new choice, you can stop looking there.

The unlocker in the eXtreme Slope comes from a new choice that is added to the Duffel Bag noncombat adventure. Same deal as the wooden nightstand -- if it's not there, stop looking.

The unlocker in Menagerie 1 appears to be from an ultra-rare monster, using whatever mechanisms UR monsters use.

The unlocker in Fern's Basement comes from the great great great ... grandfather ghost, with a very low drop rate. I have no idea whether +item helps or not.

The unlocker in the Haunted Conservatory is a rare drop from the skeletal cat (sniff it!). No idea whether +item helps.
The unlocker from resting probably has some ridiculously low rate of occurrence. You can get it from your daily free rests only if you don't have an Unconscious Collective familiar. If you have one of those, you can't get it from free rests; just from turn-costing rests.
The others... I don't know.
*/
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
	unlock_ghost();
	unlock_junkyard();
	unlock_sleeping();
}

void main()
{
	unlock_hotdogs();
}