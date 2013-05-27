import <QuestLib.ash>;

void MeatCarQuest()
{
	visit_url("guild.php?place=paco");

	if ((contains_text(visit_url("questlog.php?which=1"),"My Other Car Is Made of Meat")) || (available_amount($item[bitchin' meatcar]) == 0))
	{
		print("Getting meatcar","blue");
		if(in_muscle_sign())
		{
			if (available_amount($item[meat engine]) == 0)
			{
				if (available_amount($item[cog and sprocket assembly]) == 0)
				{
					if (available_amount($item[sprocket assembly]) == 0)
					{
						if (available_amount($item[spring]) == 0)
						{
							buy(1, $item[spring]);
						}
						if (available_amount($item[sprocket]) == 0)
						{
							buy(1, $item[sprocket]);
						}
					}
					if (available_amount($item[cog]) == 0)
					{
						buy(1, $item[cog]);
					}
				}
	
				if (available_amount($item[full meat tank]) == 0)
				{
					if (available_amount($item[empty meat tank]) == 0)
					{
						buy(1, $item[empty meat tank]);				
					}
				}
			}

			if (available_amount($item[dope wheels]) == 0)
			{
				if (available_amount($item[tires]) == 0)
					buy(1, $item[tires]);
			}
		}
		else
		{
			dress_for_fighting();
			while(item_amount($item[spring]) == 0 || item_amount($item[sprocket]) == 0 || item_amount($item[cog]) == 0 || item_amount($item[empty meat tank]) == 0 || item_amount($item[tires]) == 0 && my_adventures() > 0)
			{
				adventure(1, $location[Degrassi Knoll]);

				if(item_amount($item[Gnollish toolbox]) > 0)
				{	
					use(item_amount($item[Gnollish toolbox]), $item[Gnollish toolbox]);
				}
			}
		}

		if (available_amount($item[dope wheels]) == 0)
		{
			if (available_amount($item[sweet rims]) == 0 && my_adventures()>0)
			{
				print("Getting rims from hermit","blue");
				cli_execute("hermit sweet rims");
			}
		}
		if(creatable_amount($item[bitchin' meatcar]) > 0)
		{
			create(1, $item[bitchin' meatcar]);
			visit_url("guild.php?place=paco");
		}
	}
	else if ((contains_text(visit_url("questlog.php?which=2"),"My Other Car Is Made of Meat")) || (available_amount($item[bitchin' meatcar]) > 0))
	{
		print("You have already completed the Bitchin' Meatcar quest.");
	}
	else
	{
		print("The Bitchin' Meatcar quest is not currently available.");
	}	
}
void main()
{
	MeatCarQuest();
}