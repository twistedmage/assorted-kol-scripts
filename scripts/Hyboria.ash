void HyboriaQuest()
{
	if (!contains_text(visit_url("questlog.php?which=2"),"Primordial Fear"))
	{
		print("You must complete Primordial Fear before starting Hyboria? I don't even...");
		return;
	}

	if (!contains_text(visit_url("questlog.php?which=2"),"Hyboria? I don't even..."))
	{
		//request_noncombat(0);
		equip($slot[acc1], $item[ring of conflict]);

		if (get_property("CUSTOM_lastHyboriaReset").to_int() < get_property("knownAscensions").to_int())
		{	
			set_property("CUSTOM_HyboriaStep", "0");
			set_property("CUSTOM_lastHyboriaReset", get_property("knownAscensions").to_int());
		}


		while(my_adventures() > 0)
		{
			int step = get_property("CUSTOM_HyboriaStep").to_int();

			if (step > 9)
			{
				if (item_amount($item[memory of a glowing crystal]) == 0)
				{
					abort("need a memory of a glowing crystal to continue");
				}
			}

			if (step == 14)
			{
				if (item_amount($item[memory of a cultist's robe]) > 0)
				{
					equip($slot[acc2], $item[memory of a cultist's robe]);
				}
				
			}

			cli_execute("mood execute");
			cli_execute("burn extra mp");

			string url = visit_url("adventure.php?snarfblat=205&pwd");

			if (url.contains_text("You can't take it any more."))
			{
				if (item_amount($item[empty agua de vida bottle]) > 0)
				{
					visit_url("memories.php");
				}
				else
				{
					abort("ran out of empty agua de vida bottles");
				}
			}
			else if (url.contains_text("Combat"))
			{
				run_combat();		
			}
			else if (url.contains_text("Cavern Entrance"))
			{
				if (item_amount($item[memory of a glowing crystal]) > 0)
				{
					visit_url("choice.php?whichchoice=360&option=2&choiceform2=Leave&pwd");
				}
				else
				{
					// uhhhh wumpus
					abort("kill the wumpus yourself!");
				}
				
			}
			else if (url.contains_text("Entrance to the Forgotten City"))
			{
				string old_action = get_property( "battleAction" );
				set_property( "battleAction" , "attack with weapon" );

				switch (step)
				{
					case 0:
						// Step 1
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=3&choiceform3=Go+West&pwd");
						visit_url("choice.php?whichchoice=371&option=3&choiceform3=Go+South&pwd");
						visit_url("choice.php?whichchoice=378&option=2&choiceform2=Search&pwd");
						// Should have 'memory of a grappling hook'
						set_property("CUSTOM_HyboriaStep", "1");
						break;
					case 1:
						// Step 2
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=3&choiceform3=Go+West&pwd");
						visit_url("choice.php?whichchoice=371&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=374&option=3&choiceform3=Climb+tower&pwd");
						// Should fight the 'giant bird-creature'
						run_combat();
						set_property("CUSTOM_HyboriaStep", "2");
						break;
					case 2:
						// Step 3
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=3&choiceform3=Go+West&pwd");
						visit_url("choice.php?whichchoice=371&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=374&option=3&choiceform3=Climb+tower&pwd");
						// Should have 'memory of half a stone circle'
						set_property("CUSTOM_HyboriaStep", "3");
						break;
					case 3:
						// Step 4
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=5&choiceform5=Examine+Well&pwd");
						visit_url("choice.php?whichchoice=372&option=2&choiceform2=Climb+down+into+well&pwd");
						// Should fight the 'giant octopus'
						run_combat();
						set_property("CUSTOM_HyboriaStep", "4");
						break;
					case 4:
						// Step 5
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=5&choiceform5=Examine+Well&pwd");
						visit_url("choice.php?whichchoice=372&option=2&choiceform2=Take+grappling+hook&pwd");
						// Should have 'memory of a grappling hook'
						set_property("CUSTOM_HyboriaStep", "5");
						break;
					case 5:
						// Step 6
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=2&choiceform2=Go+East&pwd");
						visit_url("choice.php?whichchoice=370&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=375&option=2&choiceform2=Go+upstairs&pwd");
						// Should have 'memory of an iron key'
						set_property("CUSTOM_HyboriaStep", "6");
						break;
					case 6:
						// Step 7
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=2&choiceform2=Go+East&pwd");
						visit_url("choice.php?whichchoice=370&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=375&option=3&choiceform3=Go+downstairs&pwd");
						visit_url("choice.php?whichchoice=379&option=2&choiceform2=Search+the+webs&pwd");
						// Should fight 'giant spider'
						run_combat();
						set_property("CUSTOM_HyboriaStep", "7");
						break;
					case 7:
						// Step 8
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=2&choiceform2=Go+East&pwd");
						visit_url("choice.php?whichchoice=370&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=375&option=3&choiceform3=Go+downstairs&pwd");
						visit_url("choice.php?whichchoice=379&option=2&choiceform2=Search+the+webs&pwd");
						// Should have 'memory of a small stone block'
						set_property("CUSTOM_HyboriaStep", "8");
						break;
					case 8:
						// Step 9
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=2&choiceform2=Go+East&pwd");
						visit_url("choice.php?whichchoice=370&option=3&choiceform3=Go+South&pwd");
						visit_url("choice.php?whichchoice=377&option=2&choiceform2=Go+Upstairs&pwd");
						visit_url("choice.php?whichchoice=380&option=2&choiceform2=Search+the+vines&pwd");
						// Should fight 'giant jungle python'
						run_combat();
						set_property("CUSTOM_HyboriaStep", "9");
						break;
					case 9:
						// Step 10
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=2&choiceform2=Go+East&pwd");
						visit_url("choice.php?whichchoice=370&option=3&choiceform3=Go+South&pwd");
						visit_url("choice.php?whichchoice=377&option=2&choiceform2=Go+Upstairs&pwd");
						visit_url("choice.php?whichchoice=380&option=4&choiceform4=Cut+open+the+snake&pwd");
						// Should have 'memory of a little stone block'
						set_property("CUSTOM_HyboriaStep", "10");
						break;
					case 10:
						// Step 11 (need 'memory of a glowing crystal' before this I think)
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=369&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=373&option=2&choiceform2=Put+stone+block+into+left+hole&pwd");
						visit_url("choice.php?whichchoice=373&option=2&choiceform2=Put+stone+block+into+right+hole&pwd");
						visit_url("choice.php?whichchoice=373&option=2&choiceform2=Pull+lever&pwd");
						// Doesn't take an adventure
						// Step 11a Get back to the City Center
						visit_url("choice.php?whichchoice=373&option=1&choiceform1=Go+South&pwd");
						visit_url("choice.php?whichchoice=369&option=3&choiceform3=Go+South&pwd");
						// Step 11b
						visit_url("choice.php?whichchoice=368&option=2&choiceform2=Go+East&pwd");
						visit_url("choice.php?whichchoice=370&option=3&choiceform3=Go+South&pwd");
						visit_url("choice.php?whichchoice=377&option=3&choiceform3=Go+Downstairs&pwd");
						visit_url("choice.php?whichchoice=381&option=2&choiceform2=Crawl+into+the+tunnel&pwd");
						visit_url("choice.php?whichchoice=382&option=2&choiceform2=Go+West&pwd");
						visit_url("choice.php?whichchoice=383&option=3&choiceform3=Go+South&pwd");
						visit_url("choice.php?whichchoice=384&option=2&choiceform2=Open+the+chest&pwd");
						visit_url("choice.php?whichchoice=384&option=3&choiceform3=Smash+open+the+chest&pwd");
						// Should have 'memory of a stone half-circle'
						set_property("CUSTOM_HyboriaStep", "11");
						break;
					case 11:
						// Step 12
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=2&choiceform2=Go+East&pwd");
						visit_url("choice.php?whichchoice=370&option=3&choiceform3=Go+South&pwd");
						visit_url("choice.php?whichchoice=377&option=3&choiceform3=Go+Downstairs&pwd");
						visit_url("choice.php?whichchoice=381&option=2&choiceform2=Crawl+into+the+tunnel&pwd");
						visit_url("choice.php?whichchoice=382&option=2&choiceform2=Go+West&pwd");
						visit_url("choice.php?whichchoice=383&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=385&option=4&choiceform4=Go+North&pwd");
						visit_url("choice.php?whichchoice=386&option=2&choiceform2=Ponder+the+weights&pwd");
						// Gate should be kickable now
						set_property("CUSTOM_HyboriaStep", "12");
						break;
					case 12:
						// Step 13
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=369&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=373&option=2&choiceform2=Kick+gate&pwd");
						// Gate should be destroyed
						set_property("CUSTOM_HyboriaStep", "13");
						break;
					case 13:
						// Step 14
						visit_url("choice.php?whichchoice=366&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=368&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=369&option=1&choiceform1=Go+North&pwd");
						visit_url("choice.php?whichchoice=373&option=2&choiceform2=Go+North&pwd");
						visit_url("choice.php?whichchoice=376&option=3&choiceform3=Unlock+the+temple+door&pwd");
						// Temple should be open
						set_property("CUSTOM_HyboriaStep", "14");
						break;
					default:
						// Ignore adventure
						visit_url("choice.php?whichchoice=366&option=2&choiceform2=Leave&pwd");
						return;
				}

				set_property( "battleAction" , old_action );
			}
		
			// At this point we need to equip 'memory of a cultist's robe'
		
			else if (url.contains_text("Ancient Temple"))
			{
				url = visit_url("choice.php?whichchoice=367&option=1&choiceform1=Enter+the+Temple&pwd");
				url = run_combat();
				if (url.contains_text("high priest of Ki'rhuss"))
				{
					// Fuck yeah we're done.
					visit_url("town_wrong.php?action=krakrox&pwd");
					return;
				}			
			}		
		}
	}
}

void main()
{
	HyboriaQuest();
}
