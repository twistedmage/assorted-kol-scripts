import <QuestLib.ash>;
import <Spookyraven.ash>;

void SpookyravenUpstairs()
{
	UnlockSpookyraven();

	// Mafia automatically sets the bedroom choice adventures, how nice.
	set_bedroom_choices();
	if (available_amount($item[Lord Spookyraven's spectacles]) == 0)
	{
		dress_for_fighting();
		cli_execute("conditions clear");
		add_item_condition(1, $item[Lord Spookyraven's spectacles]);
		adventure(request_noncombat(my_adventures()), $location[haunted bedroom]);
		set_bedroom_choices();
	}

	if (available_amount($item[Spookyraven ballroom key]) == 0)
	{
		dress_for_fighting();
		cli_execute("conditions clear");
		add_item_condition(1, $item[Spookyraven ballroom key]);
		adventure(request_noncombat(my_adventures()), $location[haunted bedroom]);
		set_bedroom_choices();
	}

	boolean guyMadeOfBeesDefeated = get_property("guyMadeOfBeesDefeated").to_boolean();

	if (guyMadeOfBeesDefeated == false)
	{
		dress_for_fighting();
		if (available_amount($item[Antique Hand Mirror]) == 0)
		{
			set_bedroom_choices();
			cli_execute("conditions clear");
			add_item_condition(1, $item[Antique Hand Mirror]);
			adventure(request_noncombat(my_adventures()), $location[haunted bedroom]);
		}
		set_property("choiceAdventure105", "3");
		set_property("choiceAdventure402", "1");
        int guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();
		while(guyMadeOfBeesCount < 4 && my_adventures()>0)
		{
			cli_execute("conditions clear");
			print("prepping the guy made of bees. You have said his name " + guyMadeOfBeesCount + " time(s).");
			adventure(request_noncombat(1), $location[haunted bathroom]);
        	guyMadeOfBeesCount = get_property("guyMadeOfBeesCount").to_int();
		}
		set_property("choiceAdventure105", "1");
/*		
		if (guyMadeOfBeesCount ==4 && available_amount($item[Antique Hand Mirror]) != 0)
		{
			print("fighting guy made of bees");
			if (true)
			{
				cli_execute("conditions clear;conditions add 1 guy made of bee pollen");
				adventure(request_noncombat(my_adventures()), $location[haunted bathroom]);
			}
		}
*/		
//		else
//		{
//			print("You have already said the Guy Made of Bees' name " + guyMadeOfBeesCount + " times already, he's ready to be summoned.");
//		}
	}
	else
	{
		print("You have already defeated the Guy Made of Bees.");
	}
}

void main()
{
	SpookyravenUpstairs();
}
