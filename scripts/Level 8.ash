import <QuestLib.ash>;

void TrapperQuest()
{
    if (my_level() >= 8)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Am I my Trapper's Keeper?"))
		{
			visit_url("trapper.php");
	
			if (contains_text(visit_url("questlog.php?which=1"),"The Tr4pz0r wants you to infiltrate Itznotyerzitz Mine, and bring him back 3 chunks of"))
			{
				dress_for_fighting();
				item ore = $item[chrome ore];
				
				if (contains_text(visit_url("trapper.php"), "chrome ore"))
				{
					ore = $item[chrome ore];
				}
				else if (contains_text(visit_url("trapper.php"), "asbestos ore"))
				{
					ore = $item[asbestos ore];
				}
				else if (contains_text(visit_url("trapper.php"), "linoleum ore"))
				{
					ore = $item[linoleum ore];
				}

				try_acquire(3, ore);
				try_storage(3, ore);
				if(can_interact())
				{
					buy(3, ore);
				}

				if ((!have_outfit("mining gear")))
				{
					try_acquire(1, $item[miner's helmet]);
					try_acquire(1, $item[7-Foot Dwarven mattock]);
					try_acquire(1, $item[miner's pants]);
		
					try_storage(1, $item[miner's helmet]);
					try_storage(1, $item[7-Foot Dwarven mattock]);
					try_storage(1, $item[miner's pants]);

					if (!have_outfit("mining gear"))
					{
						cli_execute("conditions clear");
                        set_location($location[Itznotyerzitz Mine]);
						cli_execute("conditions add outfit");
						adventure(request_noncombat(my_adventures()), $location[Itznotyerzitz Mine]);
					}
				}
	
				if ((available_amount(ore) < 3) && (have_outfit("mining gear")))
				{
					cli_execute("checkpoint");
					outfit("mining gear");
					print("Until I add automatic mining, you'd be better off mining by hand as it will be more optimal.");
					cli_execute("outfit checkpoint");
					abort("You should mine manually.");
					return;
				}
	
				visit_url("trapper.php");
			}
	
			if (contains_text(visit_url("questlog.php?which=1"),"The Tr4pz0r wants you to bring him 6 chunks of goat cheese from the Goatlet."))
			{
				if ((!have_outfit("mining gear")))
				{
					try_acquire(1, $item[miner's helmet]);
					try_acquire(1, $item[7-Foot Dwarven mattock]);
					try_acquire(1, $item[miner's pants]);
		
					try_storage(1, $item[miner's helmet]);
					try_storage(1, $item[7-Foot Dwarven mattock]);
					try_storage(1, $item[miner's pants]);

					if (!have_outfit("mining gear"))
					{
						cli_execute("conditions clear");
                        set_location($location[Itznotyerzitz Mine]);
						cli_execute("conditions add outfit");
						adventure(request_noncombat(my_adventures()), $location[Itznotyerzitz Mine]);
					}
				}
				cli_execute("outfit mining gear");
				adventure(1, $location[goatlet]);
				dress_for_fighting();
				if (available_amount($item[goat cheese]) < 6)
				{
					try_acquire(6, $item[goat cheese]);
					try_storage(6, $item[goat cheese]);

					if (available_amount($item[goat cheese]) < 6)
					{
						if (!have_outfit("mining gear"))
						{
							try_acquire(1, $item[miner's helmet]);
							try_acquire(1, $item[7-Foot Dwarven mattock]);
							try_acquire(1, $item[miner's pants]);
				
							try_storage(1, $item[miner's helmet]);
							try_storage(1, $item[7-Foot Dwarven mattock]);
							try_storage(1, $item[miner's pants]);
		
							if (!have_outfit("mining gear") &&
								(user_confirm("Would you like to adventure for the mining gear?")))
							{
								cli_execute("conditions clear");
								set_location($location[Itznotyerzitz Mine]);
								cli_execute("conditions add outfit");
			
								adventure(request_noncombat(my_adventures()), $location[Itznotyerzitz Mine]);
							}
						}

						cli_execute("conditions clear");
						add_item_condition(6 - available_amount($item[goat cheese]), $item[goat cheese]);
						adventure(request_monsterlevel(my_adventures()), $location[goatlet]);
					}

				}
	
				visit_url("trapper.php");
			}
	
			if (contains_text(visit_url("questlog.php?which=1"),"The Tr4pz0r wants you to find some way to protect yourself from the cold. If you can't find a way to do it magically, you can probably find some warm clothes on the eXtreme Slope of Mt. McLargeHuge."))
			{
				dress_for_fighting();
				cli_execute("checkpoint");
				familiar current_familiar = my_familiar();
	
				if ((elemental_resistance($element[cold]) == 0.0) && (user_confirm("Attempt to gain cold resistance from a buff?")))
				{
					if (have_skill($skill[Astral Shell]))
					{
						use_skill(1, $skill[Astral Shell]);
					}
					else if (have_skill($skill[Elemental Saucesphere]))
					{
						use_skill(1, $skill[Elemental Saucesphere]);
					}
					else if (have_skill($skill[Scarysauce]))
					{
						use_skill(1, $skill[Scarysauce]);
					}
					else
					{
						print("You don't have any buffs that provide cold resistance.");
					}
	
					if (elemental_resistance($element[cold]) == 0.0)
					{
						print("Failed to gain cold resistance from a buff.");
					}
				}
				if ((elemental_resistance($element[cold]) == 0.0) && (user_confirm("Attempt to gain cold resistance from a familiar?")))
				{
					if (have_familiar($familiar[Exotic Parrot]))
					{
						use_familiar($familiar[Exotic Parrot]);
					}
					else
					{
						print("You don't have any familiars that provide cold resistance.");
					}
	
					if (elemental_resistance($element[cold]) == 0.0)
					{
						print("Failed to gain cold resistance from a familiar.");
					}
				}
				if ((elemental_resistance($element[cold]) == 0.0)
					&& (user_confirm("Attempt to gain cold resistance from a cheap consumable?")))
				{
					if (available_amount($item[cold powder]) == 0)
					{
						try_acquire(1, $item[cold powder]);

						try_storage(1, $item[cold powder]);

						use(1, $item[cold powder]);
					}
					else
					{
						print("You don't have any cheap consumables that provide cold resistance.");
					}
	
					if (elemental_resistance($element[cold]) == 0.0)
					{
						print("Failed to gain cold resistance from a cheap consumable.");
					}
				}

				try_acquire(1, $item[eXtreme scarf]);
				try_acquire(1, $item[snowboarder pants]);
				try_acquire(1, $item[eXtreme mittens]);
	
				try_storage(1, $item[eXtreme scarf]);
				try_storage(1, $item[snowboarder pants]);
				try_storage(1, $item[eXtreme mittens]);
	
				if ((elemental_resistance($element[cold]) == 0.0) && (user_confirm("Would you like to acquire the eXtreme Cold-Weather Gear?")))
				{
					if (!have_outfit("eXtreme Cold-Weather Gear") &&
						(user_confirm("Would you like to adventure for the eXtreme Cold-Weather Gear?")))
					{
						cli_execute("conditions clear");
						set_location($location[eXtreme Slope]);
						cli_execute("conditions add outfit");
	
						adventure(request_noncombat(my_adventures()), $location[eXtreme Slope]);
					}
					else
					{
						print("You already have the eXtreme Cold-Weather Gear.");
					}
	
					outfit("eXtreme Cold-Weather Gear");
				}
	
				if (elemental_resistance($element[cold]) == 0.0)
				{
					visit_url("trapper.php"); 
				}
				else
				{
					print("Failed to gain cold resistance from any source.");
				}
	
			   use_familiar(current_familiar);
			   cli_execute("outfit checkpoint");
			}
	
			visit_url("trapper.php");
	
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Am I my Trapper's Keeper?"))
		{
			print("You have already completed the level 8 quest.");
		}
		else
		{
			print("The level 8 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 8 to attempt this quest.");
	}
}

void main()
{
	TrapperQuest();
}

//	if(!can_interact() && available_amount(OreNeeded) < 3){
//		int i;
//		i = 54;
//		visit_url("mining.php?mine=1&reset=1");
//		while(i > 9 && item_amount(OreNeeded) < 3){
//			visit_url("mining.php?mine=1&which=" + i + "&pwd=");
//			if(my_hp() < my_maxhp() /2)
//				restore_hp(my_maxhp());
//			if(i == 49) i = 46;
//			else if(i == 41) i = 38;
//			else if(i == 33) i = 30;
//			else if(i == 25) i = 22;
//			else if(i == 17) i = 14; 45
//			else if(i == 9){
//				visit_url("mining.php?mine=1&reset=1");
//				i = 54;
//				refresh_status();
//			}
//			else i = i -1;
//		}
//	}