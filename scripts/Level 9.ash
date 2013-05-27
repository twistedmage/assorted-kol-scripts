import <QuestLib.ash>;
import <Dinghy.ash>;

void LOLQuest()
{
	if (my_level() >= 9)
	{

		if (contains_text(visit_url("questlog.php?which=1"),"A Quest, LOL"))
		{
			dress_for_fighting();
			if (!contains_text(visit_url("mountains.php"),"valley2.gif"))
			{
				DinghyQuest();

				if ((available_amount($item[abridged dictionary]) == 0) && (available_amount($item[bridge]) == 0))
				{
					try_acquire(1, $item[eyepatch]);
					try_acquire(1, $item[swashbuckling pants]);
					try_acquire(1, $item[stuffed shoulder parrot]);
		
					try_storage(1, $item[eyepatch]);
					try_storage(1, $item[swashbuckling pants]);
					try_storage(1, $item[stuffed shoulder parrot]);

					if ((!have_outfit("swashbuckling getup")) &&
						(user_confirm("Would you like to adventure for the swashbuckling getup?")))
					{
						cli_execute("conditions clear");
						set_location($location[Pirate Cove]);
						cli_execute("conditions add outfit");
	
						adventure(request_noncombat(my_adventures()), $location[Pirate Cove]);
					}
	
					if (have_outfit("swashbuckling getup"))
					{
						cli_execute("checkpoint");
						outfit("swashbuckling getup");
						buy(1, $item[abridged dictionary]);
						cli_execute("outfit checkpoint");
					}
				}
			}

            		if (available_amount($item[abridged dictionary]) > 0)
            		{
				cli_execute("untinker abridged dictionary");
			}

			if (available_amount($item[bridge]) > 0 && my_adventures()>0)
			{
				adventure(1, $location[orc chasm]);
			}

			if (contains_text(visit_url("questlog.php?which=1"),"Now that you've found your way to the Valley beyond the Orc Chasm, you must make your way to the gates of the Baron's fortress."))
			{
				cli_execute("conditions clear");

				if (available_amount($item[64735 scroll]) == 0)
				{
                    			add_item_condition(1, $item[64735 scroll]);
				}

				if (available_amount($item[31337 scroll]) == 0)
				{
				boolean catch;
					if (true)
					{
						add_item_condition(1, $item[31337 scroll]);
						catch = adventure(request_monsterlevel(my_adventures()), $location[orc chasm]);
					}
				}

				if (available_amount($item[64735 scroll]) == 0)
				{
					adventure(request_monsterlevel(my_adventures()), $location[orc chasm]);
				}
			}

			if ((available_amount($item[64735 scroll]) > 0) && (available_amount($item[dictionary]) > 0))
			{
				use (1, $item[64735 scroll]);

				if (available_amount($item[31337 scroll]) > 0)
				{
					use (1, $item[31337 scroll]);
					if (available_amount($item[stat script]) > 0)
					{
						use (1, $item[stat script]);
					}
					if (available_amount($item[hermit script]) > 0)
					{
						use (1, $item[hermit script]);
					}
				}
			}

            		council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"A Quest, LOL"))
		{
			print("You have already completed the level 9 quest.");
		}
		else
		{
			print("The level 9 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 9 to attempt this quest.");
	}
}

void main()
{
	LOLQuest();
}
