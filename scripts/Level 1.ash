import <QuestLib.ash>;

void NoobQuest()
{
    if (my_level() >= 1)
	{
		council();

		visit_url("tutorial.php?action=toot");
		visit_url("tutorial.php?action=toot");

		if (available_amount($item[Letter from King Ralph XI]) == 1)
		{
			use(1, $item[Letter from King Ralph XI]);
			visit_url("tutorial.php?action=toot");
			council();
		}

		if (contains_text(visit_url("questlog.php?which=1"),"Toot!"))
		{         
			dress_for_fighting();  
			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to adventure in Noob Cave until you find the pile of shiny pebbles he hid there."))
			{
				print("finding pebbles","blue");
				cli_execute("conditions clear");
				add_item_condition(1, $item[pile of shiny pebbles]);
				boolean catch=adventure(my_adventures(), $location[noob cave]);

				visit_url("tutorial.php?action=toot");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to go to the skills menu and buff yourself up a bit."))
			{
				print("buffing and dressing","blue");
				
				if (my_class() == $class[Seal Clubber])
				{
                    equip($item[seal-skull helmet]);
					equip($item[seal-clubbing club]);

					use_skill(1, $skill[Seal Clubbing Frenzy]);
				}
				else if (my_class() == $class[Turtle Tamer])
				{
					equip($item[helmet turtle]);

					use_skill(1, $skill[Patience of the Tortoise]);    
				}
				else if (my_class() == $class[Pastamancer])
				{
					equip($item[pasta spoon]);
					equip($item[ravioli hat]);

					use_skill(1, $skill[Manicotti Meditation]);
				}
				else if (my_class() == $class[Sauceror])
				{
					equip($item[saucepan]);

					use_skill(1, $skill[Sauce Contemplation]);
				}
				else if (my_class() == $class[Disco Bandit])
				{
					equip($item[disco ball]);
					equip($item[disco mask]);

					use_skill(1, $skill[Disco Aerobics]);
				}
				else if (my_class() == $class[Accordion Thief])
				{
					equip($item[mariachi pants]);
					equip($item[stolen accordion]);

					use_skill(1, $skill[Moxie of the Mariachi]);
				}

				visit_url("tutorial.php?action=toot");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to kill rabbits in the Dire Warren until you can recover a liver from one of them.  Eew."))
			{
				print("getting liver","blue");
				cli_execute("conditions clear");
				add_item_condition(1, $item[bunny liver]);
				boolean catch=adventure(my_adventures(), $location[Dire Warren]);
                
				visit_url("tutorial.php?action=toot");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to continue fighting rabbits in the Dire Warren until you've collected 40 Meat."))
			{
				print("getting meat","blue");
				cli_execute("conditions clear");
				while (my_meat() < 40 && my_adventures()>0)
				{
					adventure(1, $location[Dire Warren]);
				}
                
				visit_url("tutorial.php?action=toot");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to bring him some chewing gum on a string.  You can buy it at The Market, in Market Square, in Seaside Town."))
			{
				print("getting gum","blue");
				if (my_meat() >= 30)
				{

					buy(1, $item[chewing gum on a string]);
				}
                
				visit_url("tutorial.php?action=toot");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to go to Seaside Town and fish a worthless trinket out of the sewer for him."))
			{
				print("fishing for trinket","blue");
				cli_execute("conditions clear");
//				while ((available_amount($item[worthless trinket]) + available_amount($item[worthless gewgaw]) + available_amount($item[worthless knick-knack])) == 0 && my_adventures()>0)
//				{
//					adventure(1, $location[Unlucky Sewer]);
//				}
				cli_execute("conditions clear");
				boolean catch=cli_execute("obtain 1 worthless item");
				visit_url("tutorial.php?action=toot");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to take a hermit permit and a worthless trinket to the Hermitage, in the Big Mountains, and trade them to the hermit for a golden twig."))
			{
                hermit(1, $item[golden twig]);

				visit_url("tutorial.php?action=toot");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"The Toot Oriole wants you to use some Meat Paste (which you can make in the miscellaneous section of your inventory) to put the parts of his Mighty Bjorn action figure back together."))
			{
				create(1, $item[Mighty Bjorn action figure]);

				visit_url("tutorial.php?action=toot");

				use(1, $item[Certificate of Participation]);
			}

            visit_url("tutorial.php?action=toot");

			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Toot!"))
		{
			print("You have already completed the level 1 quest.");
		}
		else
		{
			print("The level 1 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 1 to attempt this quest. Wait what!?");
	}
}

void main()
{
	NoobQuest();
}
