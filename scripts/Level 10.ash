import <QuestLib.ash>;

void CastleMapQuest()
{
	if (my_level() >= 10)
	{
		if (available_amount($item[intragalactic rowboat]) == 0)
		{
			dress_for_fighting();
			if (true)
			{
				set_wheel_quest_choices();
				while (get_property("currentWheelPosition") != "map quest" && my_adventures()>0)
				{
		
					adventure(request_noncombat(1), $location[Giant's Castle]);
				}
		
				try_acquire(1, $item[giant needle]);
				try_acquire(1, $item[furry fur]);
				try_acquire(1, $item[awful poetry journal]);
		
				try_storage(1, $item[giant needle]);
				try_storage(1, $item[furry fur]);
				try_storage(1, $item[awful poetry journal]);
		
				if (creatable_amount($item[intragalactic rowboat]) == 0)
				{
					if ((available_amount($item[giant needle]) == 0) || (available_amount($item[furry fur]) == 0) || (available_amount($item[awful poetry journal]) == 0))
					{
						cli_execute("conditions add castle map items");
                        adventure(request_combat(my_adventures()), $location[Giant's Castle]);
					}
				}
		
				if (available_amount($item[giant castle map]) > 0)
				{
					use(1, $item[giant castle map]);
				}
		
				if (creatable_amount($item[intragalactic rowboat]) > 0)
				{
					create(1, $item[intragalactic rowboat]);
				}
			}
		}
		else
		{
			print("You have already completed the giant castle map quest.");
		}
	}
	else
	{
		print("You must be at least level 10 to attempt this quest.");
	}
}

void TrashQuest()
{
	if (my_level() >= 10)
	{
        council();

		boolean catch;
		if (contains_text(visit_url("questlog.php?which=1"),"The Rain on the Plains is Mainly Garbage"))
		{
			dress_for_fighting();
			if (!contains_text(visit_url("plains.php"),"beanstalk.gif"))
			{
				try_acquire(1, $item[enchanted bean]);
	
				try_storage(1, $item[enchanted bean]);

				if (available_amount($item[enchanted bean]) == 0)
				{
					cli_execute("conditions clear");
					add_item_condition(1, $item[enchanted bean]);
					catch=adventure(request_monsterlevel(my_adventures()), $location[beanbat chamber]);
				}

				use(1, $item[enchanted bean]);
			}

			if (contains_text(visit_url("plains.php"),"beanstalk.gif"))
			{
				if (!contains_text(visit_url("beanstalk.php"),"castle.gif"))
				{
					cli_execute("conditions clear");
					add_item_condition(1, $item[S.O.C.K.]);
					catch=adventure(request_noncombat(my_adventures()), $location[fantasy airship]);
				}
			}

			if (get_property("currentWheelPosition") == "muscle")
			{
				set_wheel_quest_choices();
				cli_execute("conditions clear");
				cli_execute("conditions add 1 choiceadv");
				catch=adventure(request_noncombat(my_adventures()), $location[Giant's Castle]);
			}

			council();

		}
		else if (contains_text(visit_url("questlog.php?which=2"),"The Rain on the Plains is Mainly Garbage"))
		{
			print("You have already completed the level 10 quest.");
		}
		else
		{
			print("The level 10 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 10 to attempt this quest.");
	}
}

void main()
{
	TrashQuest();
	CastleMapQuest();
}