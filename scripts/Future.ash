import <QuestLib.ash>;

void FutureQuest()
{
	if (!contains_text(visit_url("questlog.php?which=2"),"Hyboria? I don't even..."))
	{
		print("You must complete Hyboria? I don't even...before starting Future");
		return;
	}

	if (!contains_text(visit_url("questlog.php?which=2"),"Future"))
	{
		cli_execute("checkpoint");
		if (available_amount($item[ruby rod]) == 0)
		{
			equip($slot[acc1], $item[ring of conflict]);
			if (count(get_goals()) > 0)
			{
				cli_execute("conditions clear");
			}
			add_item_condition(1, $item[ruby rod]);
			adventure(request_noncombat(my_adventures()), $location[Seaside Megalopolis]);

			if (available_amount($item[ruby rod]) == 0)
			{
				abort("Didn't acquire the ruby rod.");
			}
		}

		int heat = available_amount($item[essence of heat]);
		int kink = available_amount($item[essence of kink]);
		int cold = available_amount($item[essence of cold]);
		int stench = available_amount($item[essence of stench]);
		int fright = available_amount($item[essence of fright]);

		if (heat + kink + cold + stench + fright < 5)
		{
			if (count(get_goals()) > 0)
			{
				cli_execute("conditions clear");
			}

			if (heat == 0)
			{
				add_item_condition(1, $item[essence of heat]);				
			}
			if (kink == 0)
			{
				add_item_condition(1, $item[essence of kink]);				
			}
			if (cold == 0)
			{
				add_item_condition(1, $item[essence of cold]);				
			}
			if (stench == 0)
			{
				add_item_condition(1, $item[essence of stench]);				
			}
			if (fright == 0)
			{
				add_item_condition(1, $item[essence of fright]);				
			}
			equip($slot[weapon], $item[ruby rod]);
			equip($slot[acc1], $item[monster bait]);
			adventure(request_combat(my_adventures()), $location[Seaside Megalopolis]);	

			heat = available_amount($item[essence of heat]);
			kink = available_amount($item[essence of kink]);
			cold = available_amount($item[essence of cold]);
			stench = available_amount($item[essence of stench]);
			fright = available_amount($item[essence of fright]);
			if (heat + kink + cold + stench + fright < 5)
			{
				abort("Didn't get all the essences.");
			}
		}

		if (available_amount($item[essence of cute]) == 0)
		{
			equip($slot[acc1], $item[ring of conflict]);
			if (count(get_goals()) > 0)
			{
				cli_execute("conditions clear");
			}
			add_item_condition(1, $item[essence of cute]);
			adventure(request_noncombat(my_adventures()), $location[Seaside Megalopolis]);
			if (available_amount($item[essence of cute]) == 0)
			{
				abort("Didn't get the essence of cute.");
			}
		}

		equip($slot[acc1], $item[ring of conflict]);
		if (count(get_goals()) > 0)
		{
			cli_execute("conditions clear");
		}

		while (!contains_text(visit_url("questlog.php?which=2"),"Future"))
		{
			adventure(request_noncombat(1), $location[Seaside Megalopolis]);
		}

		outfit("checkpoint");
	}
	else
	{
		print("already done?");
	}
}

void main()
{
	FutureQuest();
}
