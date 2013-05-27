import <QuestLib.ash>;

void BatQuest()
{  
	if (my_level() >= 4) 
	{
		council();
		cli_execute("conditions clear");
	
		if (contains_text(visit_url("questlog.php?which=1"),"Ooh, I Think I Smell a Bat."))
		{
			dress_for_fighting();
			if (!contains_text(visit_url("questlog.php?which=1"),"You've discovered the Boss Bat's chamber"))
			{
  				try_acquire(3, $item[sonar-in-a-biscuit]);

  				try_storage(3, $item[sonar-in-a-biscuit]);
  
				while( my_adventures()>0 && !contains_text(visit_url("bathole.php"),"bathole_4.gif"))
				{
					if(item_amount($item[sonar-in-a-biscuit])!=0)
					{
						use(1, $item[sonar-in-a-biscuit]);
					}
					else
					{
						cli_execute("maximize stench resistance, 0.01 items");
						if ((elemental_resistance($element[stench]) == 0.0) || (my_primestat()==$stat[mysticality] && (elemental_resistance($element[stench]) == 5.0)))
						{
							adventure(request_monsterlevel(1), $location[sleazy back alley]);
						}
						else
						{
							adventure(request_monsterlevel(1), $location[guano junction]);
						}
					}
				}
			}
			else
			{
				print("You've already unlocked the Boss Bat's chamber.");
			}
			
            if (contains_text(visit_url("questlog.php?which=1"),"You've discovered the Boss Bat's chamber"))
			{
				request_monsterlevel(0);

				while (available_amount($item[Boss Bat bandana]) == 0 && my_adventures()>0)
				{
					adventure(1, $location[boss bat's lair]);
				}				
			}
			else
			{
				print("The Boss Bat's chamber is not available.");
			}

			increase_mcd();
			
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Ooh, I Think I Smell a Bat."))
		{
			print("You have already completed the level 4 quest.");
		}
		else
		{
			print("The level 4 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 4 to attempt this quest.");
	}
}

void main()
{
	BatQuest();
}
