import <Find Adventure.ash>;
import <sims_lib>;

boolean should_acquire = true;
boolean should_pull = true;
boolean ask_acquire = false;
boolean ask_pull = true;
boolean change_mood = true;
boolean change_familiar = true;

boolean use_tomb_ratchet = false;	// UNTESTED

// NOTES:
// USE AT YOUR OWN RISK! Shit could go terribly wrong! In all my testing nothing has so far. Report any bugs to Epicgamer (#37195).
// 
// Mood Changes: the request_combat and request_noncombat functions are called whevever I believe a change to combat rate is helpful.
// Most other advetures use request_monsterlevel(). reqest_apathetic is called when buffs or familiars are worthess (beach vacation).
// YOU'LL WANT TO CHANGE THESE FUNCTIONS TO BE RELEVENT TO YOUR SKILLSET AND PLAY STYLE!
// 
// These scripts aren't fully automatic, you'll be asked on occasion for input for what to adventure for or what boss drop to get.
// Also I haven't automated Insult Beer Pong, however I have automated learning the insults.
// Much is assumed, usually if you need an outfit it will be adventured for (if you have acquiring and pulling enabled, you'll be
// asked beforehand), I've done a massive amount of error checking so I don't belive you'll waste any adventures of getting items
// you already own.

int g_knownAscensions = get_property("knownAscensions").to_int();

int max_mcd()
{
	return 10 + ( in_mysticality_sign().to_int() );
}

void dress_for_fighting()
{
	if(my_name()=="twistedmage")
	{
		print("NOT CHANGING GEAR FOR TWISTED","red");
	}
	else
	{
		cli_execute("conditions clear");
		//setup outfit
		if((my_class()==$class[seal clubber]) || my_class()==$class[turtle tamer])
		{
			print("dress_for_fighting performing \"maximize melee, 0.1 muscle, 0.01 items, -equip tiny plastic sword, -equip sugar shorts, -equip sugar chapeau\"","blue");
			cli_execute("maximize melee, 0.1 muscle, 0.01 items, -equip tiny plastic sword, -equip sugar shorts, -equip sugar chapeau");
			cli_execute("outfit save combat");
		}
		else if(my_class()==$class[disco bandit] || my_class()==$class[accordion thief])
		{
			print("dress_for_fighting performing \"maximize ranged damage, 0.1 moxie, 0.01 items, -equip tiny plastic sword, -equip sugar shorts, -equip sugar chapeau\"","blue");
			cli_execute("maximize ranged damage, 0.1 moxie, 0.01 items, -equip tiny plastic sword, -equip sugar shorts, -equip sugar chapeau");
			cli_execute("outfit save combat");
		}
		else
		{
			print("dress_for_fighting performing \"maximize spell damage, mysticality, 0.01 items, -equip tiny plastic sword, -equip sugar shorts, -equip sugar chapeau\"","blue");
			cli_execute("maximize spell damage, mysticality, 0.01 items, -equip tiny plastic sword, -equip sugar shorts, -equip sugar chapeau");
			cli_execute("outfit save combat");
		}
	}
	if(my_mp()<20 || !have_buff_equip())
	{
		cli_execute("mood apathetic");
	}
	else
	{
		cli_execute("mood default");
		cli_execute("mood execute");
	}	
}

void dress_for_wet()
{
	dress_for_fighting();
	if(available_amount($item[Aerated diving helmet])!=0)
	{
		cli_execute("equip Aerated diving helmet");
	}
	else if(can_interact() && available_amount($item[bubblin' stone])!=0)
	{
		cli_execute("make Aerated diving helmet");
		cli_execute("equip Aerated diving helmet");
	}
	else if(available_amount($item[makeshift SCUBA gear])!=0)
	{
		cli_execute("equip makeshift SCUBA gear");
	}
	else
	{
		abort("Error couldn't breathe underwater!");
	}
	if(my_mp()<20 || !have_buff_equip())
	{
		cli_execute("mood apathetic");
	}
	else
	{
		cli_execute("mood default");
		cli_execute("mood execute");
	}	
}

void update_mcd(int level)
{
	if (current_mcd() == level)
		return;
	if ((in_muscle_sign() && !retrieve_item(1,$item[detuned radio])) ||
       (in_moxie_sign() && available_amount($item[bitchin' meatcar]) == 0))
		return;
	print("MCD called in questlib","green");	
	change_mcd(level);
}

void increase_mcd()
{
	update_mcd(max_mcd());
}

int request_combat(int adventures)
{
	if (change_mood)
	{
		if (change_familiar)
		{
//			use_familiar($familiar[Jumpsuited Hound Dog]);
		}
	
		cli_execute("uneffect sonata");
		cli_execute("uneffect smooth movements");
		if(my_mp()<20 || !have_buff_equip())
		{
			cli_execute("mood apathetic");
		}
		else
		{
			cli_execute("mood +combat");
			cli_execute("mood execute");
			cli_execute("burn extra mp");
		}
	}
	increase_mcd();

	return adventures;
}

int request_noncombat(int adventures)
{
	if (change_mood)
	{
		if (change_familiar)
		{
			if (have_familiar($familiar[dancing frog]))
			{
				use_familiar($familiar[dancing frog]);		
			}
		}
	
		cli_execute("uneffect cantata");
		cli_execute("uneffect musk");
		if(my_mp()<20 || !have_buff_equip())
		{
			cli_execute("mood apathetic");
		}
		else
		{
			cli_execute("mood -combat");
			cli_execute("mood execute");
			cli_execute("burn extra mp");
		}	
	}

	increase_mcd();

	return adventures;
}

int request_monsterlevel(int adventures)
{
	if (change_mood)
	{
		if (change_familiar)
		{
			if (my_level() < 5)
			{
				if(have_familiar($familiar[Llama Lama]))
				{
					use_familiar($familiar[Llama Lama]);
				}		
			}
			else
			{
				if(have_familiar($familiar[dancing frog]))
				{
					use_familiar($familiar[dancing frog]);
				}
			}
		}
	
		cli_execute("uneffect cantata, sonata");
		cli_execute("uneffect smooth movements");
		cli_execute("uneffect musk");
		if(my_mp()<20 || !have_buff_equip())
		{
			cli_execute("mood apathetic");
		}
		else
		{
			cli_execute("mood ml");
			cli_execute("mood execute");
			cli_execute("burn extra mp");
		}	
	}

	increase_mcd();

	return adventures;
}

int request_default(int adventures)
{
	if (change_mood)
	{
		if (change_familiar)
		{
			if (my_level() < 5)
			{
				use_familiar($familiar[Llama Lama]);		
			}
			else
			{
				use_familiar($familiar[dancing frog]);
			}
		}
	
		cli_execute("uneffect cantata, sonata");
		cli_execute("uneffect smooth movements");
		cli_execute("uneffect musk");
		if(my_mp()<20 || !have_buff_equip())
		{
			cli_execute("mood apathetic");
		}
		else
		{
			cli_execute("mood default");
			cli_execute("mood execute");
			cli_execute("burn extra mp");
		}
	}

	increase_mcd();

	return adventures;
}
int request_apathetic(int adventures)
{
	if (change_mood)
	{
		cli_execute("mood apathetic");
		cli_execute("burn extra mp");
	}

	return adventures;
}

boolean try_acquire(int quanity, item it)
{
	if (!should_acquire)
	{
		return false;
	}

	// Don't accidently pull anything.
	cli_execute("budget 0");

	if (available_amount(it) < quanity)
	{
		if ( !ask_acquire || user_confirm("Would you like to attempt to acquire " + to_string(quanity - available_amount(it)) + " " + to_string(it) + "?"))
		{
            return retrieve_item(quanity - available_amount(it), it);
		}
		return false;
	}
	return true;
}

boolean try_storage(int quanity, item it)
{
	if (!should_pull)
	{
		return false;
	}

	// Don't accidently pull anything.
	cli_execute("budget 0");

	if (available_amount(it) < quanity)
	{
        if (pulls_remaining() > 0)
		{
			if (storage_amount(it) > 0)
			{
				if ( !ask_pull || user_confirm("Would you like to attempt to pull " + to_string(quanity - available_amount(it)) + " " + to_string(it) + " from your storage?"))
				{
					if (storage_amount(it) >= quanity - available_amount(it))
					{
						return take_storage(quanity - available_amount(it), it);
					}
					else
					{
						return take_storage(storage_amount(it), it);
					}
				}
				return false;
			}
			return false;
		}
		return false;
	}
	return true;
}

boolean rotate_pyramid(string wanted, boolean ratchet)
{
	while(my_adventures() > 0 && !contains_text(visit_url("pyramid.php"), wanted))
	{
		if(ratchet)
		{
			if ((available_amount($item[tomb ratchet]) == 0))
			{
				try_acquire(1, $item[tomb ratchet]);
			}
			if ((available_amount($item[tomb ratchet]) > 0))
			{	
				use(1, $item[tomb ratchet]);						
			}
			else
			{
				cli_execute("conditions clear; conditions add 1 choiceadv");              
				adventure(request_noncombat(my_adventures()), $location[The Middle Chamber]); 
			}
		}
		else
		{
			cli_execute("conditions clear; conditions add 1 choiceadv");
			adventure(request_noncombat(my_adventures()), $location[The Middle Chamber]);
		}
	}

	if (my_adventures() == 0)
	{
		return false;
	}
	return true;
}

void set_library_choices()
{
	// Take a Look, it's in a Book! (Rise): Unlock the second floor, then skip the adventure.
	if (get_property("lastSecondFloorUnlock").to_int() == g_knownAscensions)
		set_property("choiceAdventure80", "4");
	else
		set_property("choiceAdventure80", "99");

	// Take a Look, it's in a Book! (Fall): Unlock the Haunted Gallery first, then unlock the second floor, then skip the adventure.
	if (get_property("lastGalleryUnlock").to_int() == g_knownAscensions)
	{
		if (get_property("lastSecondFloorUnlock").to_int() == g_knownAscensions)
			set_property("choiceAdventure81", "4");
		else
			set_property("choiceAdventure81", "99");
	}
	else
	{
		set_property("choiceAdventure81", "1");
		set_property("choiceAdventure87", "2");
	}
}

void set_bedroom_choices()
{
	// One Nightstand (White): Fight an animated nightstand.
	set_property("choiceAdventure82", "3");

	// One Nightstand (Mahogany): Fight an animated nighstand.
	// Additionally you could check if you have Lord Spookyraven's spectacles equipped, and get your quest item if you don't already have it or the skill.
	set_property("choiceAdventure83", "2");

	// One Nightstand (Ornate): Get Lord Spookyraven's spectacles, else get myst substats.
	if (available_amount($item[Lord Spookyraven's spectacles]) == 0)
		set_property("choiceAdventure84", "3");
	else
		set_property("choiceAdventure84", "2");

	// One Nightstand (Wooden): Fight the remains of a jilted mistress if we already have the ballroom key.
	// Mafia will figure out the ballroom key adventures for us, but not the mirror.
	if (available_amount($item[Spookyraven ballroom key]) == 1)
		set_property("choiceAdventure85", "5"); //hotdog / key / combat
}

void set_bathroom_choices()
{
	// Having a Medicine Ball: Defeat the guy made of bees, then skip the adventure.
	// I check for whether or not I want to kill him in a differnet script.
	if (get_property("guyMadeOfBeesDefeated").to_boolean() == false)
		set_property("choiceAdventure105", "3");
	else
	{
		set_property("choiceAdventure105", "2");
		set_property("choiceAdventure107", "4");
	}
}

void set_pirate_choices()
{
	// Fucking drunkeness bullshit choice adventure.
	// That Explains All The Eyepatches: Don't get drunk, always get a shot of rotgut instead.
	if (my_primestat() == $stat[mysticality])
        set_property("choiceAdventure184", "2");
	else if (my_primestat() == $stat[muscle])
		set_property("choiceAdventure184", "2");
	else if (my_primestat() == $stat[moxie])
		set_property("choiceAdventure184", "3");
}

void set_wheel_stat_choices()
{
	// Wheel in the Clouds in the Sky, Keep On Turning: Turn to my_primestat().
	if (my_primestat() == $stat[moxie])
	{
		set_property("choiceAdventure9", "2"); 
		set_property("choiceAdventure10", "2");
		set_property("choiceAdventure11", "1"); 
		set_property("choiceAdventure12", "3");	
	}
	else if (my_primestat() == $stat[muscle])
	{
		set_property("choiceAdventure9", "3"); 
		set_property("choiceAdventure10", "2");
		set_property("choiceAdventure11", "1"); 
		set_property("choiceAdventure12", "1");	
	}
	else if (my_primestat() == $stat[mysticality])
	{
		set_property("choiceAdventure9", "1"); 
		set_property("choiceAdventure10", "3");
		set_property("choiceAdventure11", "2"); 
		set_property("choiceAdventure12", "1");	
	}
}

void set_wheel_quest_choices()
{
	// Wheel in the Clouds in the Sky, Keep On Turning: Set to quest position (also to reduce noncombat rate).
	set_property("choiceAdventure9", "2"); 
	set_property("choiceAdventure10", "1");
	set_property("choiceAdventure11", "3"); 
	set_property("choiceAdventure12", "2");
}

void main()
{
}
