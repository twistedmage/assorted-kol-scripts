import <zlib.ash>;

item walkthru = $item[GameInformPowerDailyPro walkthru];
item magazine = $item[GameInformPowerDailyPro magazine];
void DailyPro()
{
	while(my_adventures()>30)
	{
		cli_execute("inv refresh");
		if (item_amount(walkthru) == 0)
		{
			if (item_amount(magazine) == 0)
			{
				buy(1, magazine);
			}

			visit_url("inv_use.php?pwd&whichitem=6174&confirm=Yep.");
			cli_execute("inv refresh");
		}

		if (item_amount(walkthru) == 0)
		{
			abort("Failed to use a " + magazine );
		}

		adventure( my_adventures(), $location[Video Game Level 1] );
		adventure( my_adventures(), $location[Video Game Level 2] );
		while ( my_adventures() > 0 )
		{
			adv1($location[Video Game Level 3], -1, "");
			if (get_property("lastEncounter") == "A Gracious Maze")
			{
				visit_url("place.php?pwd&whichplace=faqdungeon");
			}
			else if (get_property("lastEncounter") == "")
			{
				break;
			}
		}
	}
}

void main()
{
	DailyPro();
}