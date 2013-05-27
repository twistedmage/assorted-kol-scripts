import <QuestLib.ash>;

void DocQuest()
{
	if (my_level() >= 5)
	{
		if (contains_text(visit_url("plains.php"), "knob2.gif"))
		{
			visit_url("galaktik.php");
			visit_url("galaktik.php?action=startquest&pwd");

			if (contains_text(visit_url("questlog.php?which=1"),"What's Up, Doc?"))
			{
				dress_for_fighting();
				while(available_amount($item[fraudwort]) < 3 && my_adventures()>0)
				{
					adventure(request_combat(1),$location[friar's gate]);
				}
				while(available_amount($item[shysterweed]) < 3 && my_adventures()>0)
				{
					adventure(request_combat(1), $location[pre-cyrpt cemetary]);
				}
				while(available_amount($item[swindleblossom]) < 3 && my_adventures()>0)
				{
					adventure(request_combat(1), $location[knob goblin harem]);
				}

				visit_url("galaktik.php");
			}
			else if (contains_text(visit_url("questlog.php?which=2"),"What's Up, Doc?"))
			{
				print("You have already completed the Doc Galaktik quest.");
			}
			else
			{
				print("The Doc Galaktik quest is not currently available.");
			}

		}
		else
		{
			print("You must open Cobb's Knob to attempt the Doc Galaktik quest.");
		}
	}
	else
	{
		print("You must be at least level 5 to attempt the Doc Galaktik quest.");
	}
}

void main()
{
	DocQuest();
}
