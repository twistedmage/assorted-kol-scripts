import <QuestLib.ash>;

void id_potions()
{
	if(available_amount($item[bubbly potion])==0)
	{
		buy(1,$item[bubbly potion]);
		id_potions();
	}
	else if(available_amount($item[cloudy potion])==0)
	{
		buy(1,$item[cloudy potion]);
		id_potions();
	}
	else if(available_amount($item[dark potion])==0)
	{
		buy(1,$item[dark potion]);
		id_potions();
	}
	else if(available_amount($item[effervescent potion])==0)
	{
		buy(1,$item[effervescent potion]);
		id_potions();
	}
	else if(available_amount($item[fizzy potion])==0)
	{
		buy(1,$item[fizzy potion]);
		id_potions();
	}
	else if(available_amount($item[milky potion])==0)
	{
		buy(1,$item[milky potion]);
		id_potions();
	}
	else if(available_amount($item[murky potion])==0)
	{
		buy(1,$item[murky potion]);
		id_potions();
	}
	else if(available_amount($item[smoky potion])==0)
	{
		buy(1,$item[smoky potion]);
		id_potions();
	}
	else if(available_amount($item[swirly potion])==0)
	{
		buy(1,$item[swirly potion]);
		id_potions();
	}
	else if(!to_boolean(get_property("potions_id_"+my_name())))
	{
		while(!contains_text(visit_url("adventure.php?snarfblat=110&pwd"),"You're fighting"))
		{
			
		}
		throw_item($item[bubbly potion]);
		throw_item($item[cloudy potion]);
		throw_item($item[dark potion]);
		throw_item($item[effervescent potion]);
		throw_item($item[fizzy potion]);
		throw_item($item[milky potion]);
		throw_item($item[murky potion]);
		throw_item($item[smoky potion]);
		throw_item($item[swirly potion]);
		set_property("potions_id_"+my_name(),true);
		run_combat();
	}
}

void NaughtyQuest()
{
	boolean success=false;
	if (my_level() >= 13)
	{
        council();
		if (contains_text(visit_url("questlog.php?which=1"),"The Final Ultimate Epic Final Conflict") && !contains_text(visit_url("questlog.php?which=1"),"defeated the Naughty Sorceress and freed the King"))
		{
			dress_for_fighting();
//check if at entryway somewhere
			string log_text = visit_url("questlog.php?which=1");
			if(contains_text(log_text,"make your way to the top of the Naughty Sorceress") || contains_text(log_text,"you've encountered a giant mirror") || contains_text(log_text,"encountered three strange gates") || contains_text(log_text,"odd junction in the cave leading to the Sorceress"))
			{
				id_potions();
				cli_execute("checkpoint");
				if(available_amount($item[digital key])==0)
				{
					if(available_amount($item[continuum transfunctioner])==0)
					{
						visit_url("mystic.php?action=crackyes1&crack1=Sure%2C+old+man.++Tell+me+all+about+it.&pwd");
						visit_url("mystic.php?action=crackyes2&crack1=Against+my+better+judgment%2C+yes.&pwd");
						visit_url("mystic.php?action=crackyes3&crack1=Er%2C+sure%2C+I+guess+so...&pwd");
					}
					cli_execute("maximize items, equip continuum transfunctioner");
					cli_execute("conditions clear");
					cli_execute("condition add 1 digital key");
					success=adventure(my_adventures(),$location[8-bit realm]);
				}
				if(available_amount($item[Richard's star key])==0)
				{
					cli_execute("maximize items");
					cli_execute("conditions clear");
					cli_execute("condition add 1 Richard's star key");
					success=adventure(my_adventures(),$location[Hole in the sky]);
				}
				if(available_amount($item[star hat])==0)
				{
					cli_execute("maximize items");
					cli_execute("conditions clear");
					cli_execute("condition add 1 star hat");
					success=adventure(my_adventures(),$location[Hole in the sky]);
				}
				if(!have_familiar($familiar[star starfish]))
				{
					if(available_amount($item[star starfish])==0)
					{
						cli_execute("maximize items");
						cli_execute("conditions clear");
						cli_execute("condition add 1 star starfish");
						success=adventure(my_adventures(),$location[Hole in the sky]);
					}
					if(item_amount($item[star starfish])>0)
					{
						use(1,$item[star starfish]);
					}
				}
				item star_wep;
				if((my_class()==$class[seal clubber]) || my_class()==$class[turtle tamer])
				{
					star_wep=$item[star sword];
				}
				else if(my_class()==$class[disco bandit] || my_class()==$class[accordion thief])
				{
					star_wep=$item[star crossbow];
				}
				else
				{
					star_wep=$item[star staff];
				}
				if(available_amount(star_wep)==0)
				{
					cli_execute("maximize items");
					cli_execute("conditions clear");
					cli_execute("condition add 1 "+star_wep);
					success=adventure(my_adventures(),$location[Hole in the sky]);
				}
				if((item_amount($item[sneaky pete's key]) + item_amount($item[boris's key]) + item_amount($item[jarlsberg's key]))<3)
				{
					print("Don't have daily dungeon keys to do the lair today","red");
					return;
				}
				if(my_adventures()>0)
				{
					cli_execute("checkpoint outfit");
					cli_execute("entryway clover");
				}
			}

//check if in hedge maze
			log_text = visit_url("questlog.php?which=1");
			if(contains_text(log_text,"Currently, you're stuck in a hedge maze"))
			{
				if (visit_url("lair3.php").contains_text("hedgemaze.gif"))
				{
					while (my_adventures() > 0 && !hedgemaze())
					{
						adventure(request_monsterlevel(1), $location[Sorceress' Hedge Maze]);
					}
				}
			}
//ascending tower
			log_text = visit_url("questlog.php?which=1");
			if(contains_text(log_text,"puzzle, beat the hedge maze like a psychotic landscaper") || contains_text(log_text,"figure out the code to get through the heavy door") || contains_text(log_text,"Get in there and kick some tail") || contains_text(log_text,"except it doesn't have a goatee") || contains_text(log_text,"Sorceress's freakishly overgrown familiars"))
			{
				if(available_amount($item[red pixel potion])<8)
				{
					cli_execute("checkpoint");
					cli_execute("maximize items, equip continuum transfunctioner");
					cli_execute("conditions clear");
					cli_execute("condition add 8 red pixel potion");
					success=adventure(my_adventures(),$location[8-bit realm]);
					cli_execute("checkpoint outfit");
				}
//get all possibly needed pets
				if(!have_familiar($familiar[Levitating Potato]))
				{
					buy(1,$item[Potato sprout]);
					use(1,$item[Potato sprout]);
				}
				if(familiar_weight($familiar[Levitating Potato])<20)
				{
					cli_execute("familiar Levitating Potato");
					cli_execute("train buffed 6");
				}
				if(familiar_weight($familiar[Mosquito])<20)
				{
					cli_execute("familiar Mosquito");
					cli_execute("train buffed 6");
				}
				if(!have_familiar($familiar[Angry Goat]))
				{
					buy(1,$item[anticheese]);
					buy(1,$item[goat cheese]);
					create(1,$item[goat]);
					use(1,$item[goat]);
				}
				if(familiar_weight($familiar[Angry Goat])<20)
				{
					cli_execute("familiar Angry Goat");
					cli_execute("train buffed 6");
				}
				if(!have_familiar($familiar[Barrrnacle]))
				{
					buy(1,$item[Barrrnacle]);
					use(1,$item[Barrrnacle]);
				}
				if(familiar_weight($familiar[Barrrnacle])<20)
				{
					cli_execute("familiar Barrrnacle");
					cli_execute("train buffed 6");
				}
				if(!have_familiar($familiar[Sabre-Toothed Lime]))
				{
					buy(1,$item[sabre teeth]);
					buy(1,$item[lime]);
					create(1,$item[Sabre-toothed lime cub]);
					use(1,$item[Sabre-toothed lime cub]);
				}
				if(familiar_weight($familiar[Sabre-Toothed Lime])<20)
				{
					cli_execute("familiar Sabre-Toothed Lime");
					cli_execute("train buffed 6");
				}

	
				if (visit_url("lair4.php").contains_text("lair3.php"))
				{
					request_monsterlevel(0);
					boolean catch = cli_execute("tower");
				}
			}
			
//ready for NS
			log_text = visit_url("questlog.php?which=1");
			if(contains_text(log_text,"This is it, sparky"))
			{
				if(available_amount($item[Wand of Nagamar])==0)
				{
					cli_execute("maximize items");
					if(available_amount($item[WA])==0)
					{
						if(available_amount($item[ruby W])==0)
						{
							cli_execute("conditions clear");
							cli_execute("condition add ruby W");
							success=adventure(my_adventures(),$location[Friar's gate]);
						}
						if(available_amount($item[metallic A])==0)
						{
							cli_execute("conditions clear");
							cli_execute("condition add metallic A");
							success=adventure(my_adventures(),$location[Fantasy Airship]);
						}
						if(creatable_amount($item[WA])>0)
						{
							create(1,$item[WA]);
						}
					}
					if(available_amount($item[ND])==0)
					{
						if(available_amount($item[lowercase N])==0)
						{
							cli_execute("conditions clear");
							cli_execute("condition add lowercase N");
							success=adventure(my_adventures(),$location[orc chasm]);
						}
						if(available_amount($item[heavy D])==0)
						{
							cli_execute("conditions clear");
							cli_execute("condition add heavy D");
							success=adventure(my_adventures(),$location[Giant's Castle]);
						}
						if(creatable_amount($item[ND])>0)
						{
							create(1,$item[ND]);
						}
					}
					if(creatable_amount($item[Wand of Nagamar])>0)
					{
						create(1,$item[Wand of Nagamar]);
					}
				}
//dress for her naughtiness
				if((my_class()==$class[sauceror]) || my_class()==$class[pastamancer])
				{
					cli_execute("restore hp; restore mp");
					dress_for_fighting();
					boolean done=my_buffedstat($stat[moxie])>200;
					use(1,$item[dance card]);
					while(!done && my_adventures()>0)
					{
						print("Training moxie","blue");
						set_property("choiceAdventure90", "2");
						adventure(1,$location[Haunted Ballroom]);
						done=my_buffedstat($stat[moxie])>200;					
					}
					if(my_adventures()==0)
					{
						cli_execute("bed.ash");
					}
				}
				dress_for_fighting();
				if (visit_url("lair6.php").contains_text("place=5"))
				{
					print("Fighting the bitch","blue");
					restore_hp(my_maxhp());
					restore_mp(my_maxmp());
					if(my_class()==$class[sauceror] || my_class()==$class[pastamancer] || my_class()==$class[accordion thief])
					{
						print("Buying mmj to fuel spells","blue");
						int mmjs = item_amount($item[magical mystery juice]);
						if( mmjs<10)
						{
							buy(10-mmjs,$item[magical mystery juice]);
						}
					}
					else
					{
						print("Buying fans to fuel spells","blue");
						int fans = item_amount($item[palm frond]);
						if( fans<10)
						{
							buy(10-fans,$item[magical mystery juice]);
						}
					}
                	request_apathetic(3);
					string fight = visit_url("lair6.php?place=5");
					while(contains_text(fight,"The Naughty Sorceress"))
					{
						print(fight,"blue");
						print("trying to run combat","blue");
						fight = run_combat();
						wait(5);
						fight = visit_url("main.php");
					}
					print(fight,"green");
				}	
			}
			
			log_text = visit_url("lair6.php");
			if (contains_text(log_text,"kingprism1.gi"))
			{
				string tmp = visit_url("lair6.php?place=6&pwd");
			}

			string tmp = council();
			if(my_adventures()>0)
			{
				NaughtyQuest();
			}
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"The Final Ultimate Epic Final Conflict"))
		{
			print("You have already completed the level 13 quest.");
		}
		else
		{
			print("The level 13 quest is not currently available. (Or is completed)");
		}
	}
	else
	{
		print("You must be at least level 13 to attempt this quest.");
	}
}
void main()
{
	NaughtyQuest();
}
