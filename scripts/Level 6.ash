import <QuestLib.ash>;
import <nscomb.ash>;

void FriarsQuest()
{
    if (my_level() >= 6)
	{
        council();
		string catch;
		if (contains_text(visit_url("questlog.php?which=1"),"Trial By Friar"))
		{
			dress_for_fighting();
			while(available_amount($item[Eldritch Butterknife]) == 0 && my_adventures()!=0)
			{
				catch=visit_url("adventure.php?snarfblat=237");
				use_run_combat(catch);
				cli_execute("recover both");
			}
			while (available_amount($item[box of birthday candles]) == 0 && my_adventures()!=0)
			{
				catch=visit_url("adventure.php?snarfblat=238");
				use_run_combat(catch);
				cli_execute("recover both");
			}
			while(available_amount($item[Dodecagram]) == 0 && my_adventures()!=0)
			{
				catch=visit_url("adventure.php?snarfblat=239");
				use_run_combat(catch);
				cli_execute("recover both");
			}
			if (my_adventures()!=0)
			{
				cli_execute("refresh inventory");
				catch=visit_url("friars.php?action=ritual&pwd");
				catch=visit_url("friars.php?action=ritual&pwd");
			}
			
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Trial By Friar"))
		{
			print("You have already completed the level 6 quest.");
		}
		else
		{
			print("The level 6 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 6 to attempt this quest.");
	}
}
void SteelQuest()
{
	if (my_level() >= 6)
	{
		if (contains_text(visit_url("questlog.php?which=2"),"Trial By Friar"))
		{
			if (!contains_text(visit_url("questlog.php?which=2"),"this is Azazel in Hell.")) 
			{
				dress_for_fighting();
				if (available_amount($item[Azazel's unicorn]) == 0)
				{
					cli_execute("conditions clear");
					add_item_condition(1, $item[Azazel's unicorn]);
					adventure(request_monsterlevel(my_adventures()), $location[Friar's Gate]);
				}
				if (available_amount($item[Azazel's lollipop]) == 0)
				{
					cli_execute("conditions clear");
					add_item_condition(1, $item[Azazel's lollipop]);
					adventure(request_monsterlevel(my_adventures()), $location[Friar's Gate]);
				}
				if (available_amount($item[Azazel's tutu]) == 0)
				{
					cli_execute("conditions clear");
					add_item_condition(1, $item[Azazel's tutu]);
					adventure(request_monsterlevel(my_adventures()), $location[Friar's Gate]);
				}
				
				cli_execute("conditions clear");
				while (!contains_text(visit_url("questlog.php?which=2"),"this is Azazel in Hell.") && my_adventures()>0)
				{
					adventure(request_monsterlevel(1), $location[Friar's Gate]);
				}

				if (available_amount($item[steel margarita]) > 0)
					overdrink(1, $item[steel margarita]);

				if (available_amount($item[steel lasagna]) > 0)
					eat(1, $item[steel lasagna]);

				if (available_amount($item[steel-scented air freshener]) > 0)
					use(1, $item[steel-scented air freshener]);
			}
			else
			{
				print("You have already completed the Azazel Quest.");
			}
		}
		else
		{
			print("You must first complete the level 6 quest to attempt this quest.");
		}
	}
	else
	{
		print("You must be at least level 6 to attempt this quest.");
	}
}
void main()
{
    FriarsQuest();
	SteelQuest();
}