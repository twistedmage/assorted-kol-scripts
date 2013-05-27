import <QuestLib.ash>;
import <nscomb.ash>

void UnlockTemple()
{
	if (!contains_text(visit_url("woods.php"),"temple.gif"))
	{
		dress_for_fighting();
		if (contains_text(visit_url("woods.php"),"forest.gif"))
		{
			while(((available_amount($item[spooky sapling]) == 0) || (available_amount($item[Spooky-Gro fertilizer]) == 0) || (available_amount($item[Spooky Temple map]) == 0)) && my_adventures()>0)
			{
				print("finding temple","blue");
				cli_execute("conditions clear");
				if(item_amount($item[spooky sapling]) == 0)
				{            
					while(item_amount($item[spooky sapling]) == 0)
					{
						if(my_adventures() == 0 || my_meat()<100)
						{
							print("You ran out of adventures or money trying to reveal the Hidden Temple.","green");
							return;                
						}
						
						string page;
						page = visit_url("adventure.php?snarfblat=15");
						if(page.contains_text("Arboreal Respite"))
						{
							visit_url("choice.php?pwd&whichchoice=502&option=1&choiceform1=Follow+the+old+road");
							visit_url("choice.php?pwd&whichchoice=503&option=3&choiceform3=Talk+to+the+hunter");
							visit_url("choice.php?pwd&whichchoice=504&option=3&choiceform3=Buy+a+tree+for+100+Meat");
							visit_url("choice.php?pwd&whichchoice=504&option=4&choiceform4=Take+your+leave");
						}
						else
						{
							custom_fight("0","",page);
						}
					}
				}
				else if (available_amount($item[Spooky-Gro fertilizer]) == 0)
				{
					if(available_amount($item[tree-holed coin])==0)
					{
						print("getting tree coin","blue");
						set_property("choiceAdventure502","2");
						set_property("choiceAdventure505","2");
	//					add_item_condition(1, $item[tree-holed coin]);			
					}
					else
					{
						print("getting spooky gro fertilizer","blue");
						set_property("choiceAdventure502","3");
						set_property("choiceAdventure506","2");
						add_item_condition(1, $item[Spooky-Gro fertilizer]);
					}
//					abort("need to get tree holed coin");
				}
				else if (available_amount($item[Spooky Temple map]) == 0)
				{
					set_property("choiceAdventure502","3");
					set_property("choiceAdventure506","3");
					set_property("choiceAdventure507","1");
					print("getting temple map","blue");
					add_item_condition(1, $item[Spooky Temple map]);
				}
				boolean catch=adventure(request_noncombat(1), $location[Spooky Forest]);
			}

			if ((available_amount($item[spooky sapling]) > 0) && (available_amount($item[Spooky-Gro fertilizer]) > 0) && (available_amount($item[Spooky Temple map]) > 0))
			{
				print("using map","blue");
				//set choiceadvs for normal adventuring
				set_property("choiceAdventure502","3");
				set_property("choiceAdventure506","1");
				set_property("choiceAdventure26","2");
				set_property("choiceAdventure28","2");
				use(1, $item[Spooky Temple map]);
			}
			else
			{
				print("Failed to retrieve the requried items to open the Hidden Temple.");
			}
		}
		else
		{
			print("The Spooky Forest is not currently available.");
		}
	}
	else
	{
		print("The Hidden Temple is already available.");
	}

}

void main()
{
	UnlockTemple();
}
