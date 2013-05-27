import <QuestLib.ash>;

void CyrptQuest()
{
    if (my_level() >= 7)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Cyrptic Emanations") && my_adventures()>0)
		{
			dress_for_fighting();
			cli_execute("conditions clear");
		   set_property("choiceAdventure154","1");
		   set_property("choiceAdventure158","1");
		   set_property("choiceAdventure160","1");
			boolean catch;
			while(available_amount($item[hobo code binder])!=0 && !contains_text(visit_url("questlog.php?which=5"),"The Defiled Nook")&& my_adventures()>0)
			{
				set_property("choiceAdventure156","2");
				cli_execute("maximize moxie, equip hobo code binder");
				catch = adventure(1,$location[defiled nook]);
			}
			set_property("choiceAdventure156","1");
			catch = adventure(request_monsterlevel(my_adventures()), $location[Defiled Nook]);
			catch = adventure(request_monsterlevel(my_adventures()), $location[Defiled Niche]);
			catch = adventure(request_monsterlevel(my_adventures()), $location[Defiled Cranny]);
			catch = adventure(request_monsterlevel(my_adventures()), $location[Defiled Alcove]);


			request_monsterlevel(0);

			catch = adventure(1, $location[Haert of the Cyrpt]);

			if (available_amount($item[chest of the bonerdagon]) != 0)
			{
				use(available_amount($item[chest of the bonerdagon]),$item[chest of the bonerdagon]);
			}

			increase_mcd();
	
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Cyrptic Emanations"))
		{
			print("You have already completed the level 7 quest.");
		}
		else
		{
			print("The level 7 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 7 to attempt this quest.");
	}
}

void main()
{
	CyrptQuest();
}
