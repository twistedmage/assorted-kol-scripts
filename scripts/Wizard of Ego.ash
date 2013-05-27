import <QuestLib.ash>;

void WizardQuest()
{
	if (my_basestat(my_primestat()) >= 11 && my_adventures()>0)
	{
		visit_url("guild.php?place=scg");
		visit_url("guild.php?place=ocg");
		visit_url("guild.php?place=scg");
		visit_url("guild.php?place=ocg");


		if (contains_text(visit_url("questlog.php?which=1"),"The Wizard of Ego"))
		{
			boolean catch;
			dress_for_fighting();
			if (contains_text(visit_url("questlog.php?which=1"),"You've been tasked with digging up the grave of an ancient and powerful wizard and bringing back a key that was buried with him. What could possibly go wrong?"))
			{
				if ((available_amount($item[Fernswarthy's key]) == 0) || (available_amount($item[Fernswarthy's letter]) == 0))
				{
					cli_execute("conditions clear");
					add_item_condition(1, $item[Fernswarthy's key]);	
					catch=adventure(request_noncombat(my_adventures()), $location[pre-cyrpt cemetary]);
				}

				visit_url("guild.php?place=scg");
				visit_url("guild.php?place=ocg");
				visit_url("guild.php?place=scg");
				visit_url("guild.php?place=ocg");

			}
			//if i am now able to go to the battlefield, do it!
			if(my_level()>3 && my_level()<6 && (in_mysticality_sign() || in_muscle_sign() || in_moxie_sign()))
			{
				catch=adventure(my_adventures(),$location[Battlefield (No Uniform)]);
			}
			else if (my_basestat(my_primestat()) >= 18)
			{
				if (available_amount($item[dusty old book]) == 0 || available_amount($item[manual of labor]) == 0 || available_amount($item[manual of transmission]) == 0 || available_amount($item[manual of dexterity]) == 0)
				{
                    visit_url("fernruin.php");

					cli_execute("conditions clear");
					add_item_condition(1, $item[dusty old book]);	
					catch=adventure(request_noncombat(my_adventures()), $location[fernswarthy's ruins]);
				}

				visit_url("guild.php?place=scg");
				visit_url("guild.php?place=ocg");
				visit_url("guild.php?place=scg");
				visit_url("guild.php?place=ocg");

			}
			else
			{
				print("Your prime stat must be at least 18 to continue The Wizard of Ego quest.");
			}

		}
		else if (contains_text(visit_url("questlog.php?which=2"),"The Wizard of Ego"))
		{
			print("You have already completed the The Wizard of Ego quest.");
		}
		else
		{
			print("The Wizard of Ego quest is not currently available.");
		}
	}
	else
	{
		print("Your prime stat must be at least 11 to start The Wizard of Ego quest.");
	}
}

void main()
{
	WizardQuest();
}
