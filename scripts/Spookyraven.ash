import <QuestLib.ash>;

void UnlockSpookyraven()
{
	if (get_property("lastSecondFloorUnlock").to_int() == g_knownAscensions)
	{
		print("The second floor of Spookyraven is already unlocked.");
		return;
	}

	set_library_choices();

	while (!contains_text(visit_url("town_right.php"),"manor.gif") && my_adventures()>0)
	{
		dress_for_fighting();

		cli_execute("conditions clear");
		adventure(request_noncombat(1), $location[Haunted Pantry]);
	}

	if (available_amount($item[Spookyraven library key]) == 0)
	{
		dress_for_fighting();
		cli_execute("checkpoint");
		while (available_amount($item[Spookyraven library key]) == 0 && my_adventures()>0)
		{
	
			if (available_amount($item[pool cue]) > 0)
			{
				equip($item[pool cue]);

				if (have_effect($effect[Chalky Hand]) == 0)
				{
					if (available_amount($item[handful of hand chalk]) > 0)
					{
						use(1, $item[handful of hand chalk]);
					}
				}
			}

			cli_execute("conditions clear");
			adventure(request_noncombat(1), $location[Haunted Billiards Room]);
		}
		cli_execute("outfit checkpoint");
	}

	while (contains_text(visit_url("manor.php"),"place=stairs") && my_adventures()>0)
	{
		dress_for_fighting();

		cli_execute("conditions clear");
		adventure(request_noncombat(1), $location[Haunted Library]);
		set_library_choices();
	}
}

void main()
{
	UnlockSpookyraven();
}
