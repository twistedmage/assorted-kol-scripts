import <QuestLib.ash>;
import <Spookyraven.ash>;
import <Pirate.ash>;
import <Hidden City.ash>;


// Stole this shit from another script
boolean pour_wines()
{
	cli_execute("checkpoint");
	cli_execute("equip Lord Spookyraven's spectacles");
	// check if we have all six wines
	boolean winecheck = false;
	if(  item_amount($item[dusty bottle of Marsala]   ) > 0
		&& item_amount($item[dusty bottle of Muscat]    ) > 0
		&& item_amount($item[dusty bottle of Port]      ) > 0
		&& item_amount($item[dusty bottle of Zinfandel] ) > 0
		&& item_amount($item[dusty bottle of Pinot Noir]) > 0
		&& item_amount($item[dusty bottle of Merlot]    ) > 0
		)
	{
		winecheck = true;
	}

	if(winecheck)
		print("got all six wines!");
	else
		print("lacking a wine!");

	// manor3.php?place=goblet
	// Right. I can check the imagenumbers and mafias get_property
	// to figure out what wines are needed
	// what ORDER do I need them in, though?
	// here be dragons...
	string goblet = visit_url("manor3.php?place=goblet");
	// first off, ditch the URL to images.kol
	string searchy = "http://images.kingdomofloathing.com";
	goblet = replace_string(goblet, searchy, "IMAGES");

	// now, the first wine has a string the other wines dont. lets remove it
	// align=center valign=bottom height=75><img src="IMAGES/otherimages/manor/glyph4.gif
	searchy = " height=75";
	goblet = replace_string(goblet, searchy, "");
	// right. Now all the wines should be something like this
	// align=center valign=bottom><img src="IMAGES/otherimages/manor/glyph4.gif
	// align=right valign=bottom><img src="IMAGES/otherimages/manor/glyph3.gif
	// align=left valign=bottom><img src="IMAGES/otherimages/manor/glyph2.gif
	searchy = " valign=bottom><img src=\"IMAGES/otherimages/manor/glyph";

	int get_wine_position(string position)
	{
		// print("position = (" + position + ")");
		for i from 1 upto 6 by 1
		{
			string findme = position + searchy + i + ".gif";
			if(contains_text(goblet, findme))
				return i;
		}
		abort("wine position not found!");
		return 0;
	}

	item get_this_wine(int wine_no)
	{
		if(get_property("lastDustyBottle2271") == wine_no)
			return to_item(2271);
		if(get_property("lastDustyBottle2272") == wine_no)
			return to_item(2272);
		if(get_property("lastDustyBottle2273") == wine_no)
			return to_item(2273);
		if(get_property("lastDustyBottle2274") == wine_no)
			return to_item(2274);
		if(get_property("lastDustyBottle2275") == wine_no)
			return to_item(2275);
		if(get_property("lastDustyBottle2276") == wine_no)
			return to_item(2276);

		abort("wine (" + wine_no + ") not found!");
		return to_item(1);
	}

	item firstwine  = get_this_wine(get_wine_position("align=center"));
	item secondwine = get_this_wine(get_wine_position("align=right"));
	item thirdwine  = get_this_wine(get_wine_position("align=left"));
	// glyph4.gif  - Marsala - 4
	// glyph3.gif  - Port    - 3
	// glyph2.gif  - Zinfand - 2
	print("wine #1 : " + to_string(firstwine));
	print("wine #2 : " + to_string(secondwine));
	print("wine #3 : " + to_string(thirdwine));

	// now, lets check that we have the various wines
	// TODO: some code to farm these wines from the cellar
	// update: done!(I think. I need to test it personally, but it *should* work)
	print("wines time","blue");
	while(available_amount(firstwine) == 0 && my_adventures()>0)
	{
		boolean tmp = adventure(request_monsterlevel(1), $location[haunted wine cellar (automatic)]);
	}

	while(my_adventures()>0 && available_amount(secondwine) == 0)
	{
		boolean tmp = adventure(request_monsterlevel(1), $location[haunted wine cellar (automatic)]);
	}

	while(my_adventures()>0 && available_amount(thirdwine) == 0)
	{
		boolean tmp = adventure(request_monsterlevel(1), $location[haunted wine cellar (automatic)]);
	}

	if ((available_amount(firstwine) == 0) || (available_amount(secondwine) == 0) || (available_amount(thirdwine) == 0))
	{
		cli_execute("outfit checkpoint");
		return false;
	}

	// well, shit. It seems to work. FUCK, YEAH
	// now, lets place the frigging wines
	// manor3.php?action=pourwine&whichwine=2275
	string pouring = "manor3.php?action=pourwine&whichwine=";
	if(  contains_text(visit_url(pouring + to_int(firstwine)),  "begins to glow more brightly")
		&& contains_text(visit_url(pouring + to_int(secondwine)), "begins to glow more brightly")
		&& contains_text(visit_url(pouring + to_int(thirdwine)),  "reveal a hidden passage")
		)
	{
		cli_execute("outfit checkpoint");
		return true;
	}

	cli_execute("outfit checkpoint");
	return false;
}

void DiaryQuest()
{
	if (available_amount($item[your father's MacGuffin diary]) == 0 && my_adventures()>0)
	{
		if (!contains_text(visit_url("woods.php"),"blackmarket.gif"))
		{
			cli_execute("conditions clear");

			if (!have_familiar($familiar[Reassembled Blackbird]))
			{
				if (creatable_amount($item[reassembled blackbird]) == 0)
				{
					while(my_adventures()>0 && available_amount($item[sunken eyes]) == 0)
					{
						adventure(request_combat(1), $location[black forest]);
					}
					while(my_adventures()>0 && available_amount($item[broken wings]) == 0)
					{
						adventure(request_combat(1), $location[black forest]);
					}
				}
			}

			while(my_adventures()>0 && available_amount($item[black market map]) == 0)
			{
				adventure(request_noncombat(1), $location[black forest]);
			}

			if (creatable_amount($item[reassembled blackbird]) > 0)
			{
				create(1, $item[reassembled blackbird]);
			}

			if (available_amount($item[reassembled blackbird]) > 0)
			{
				use(1, $item[reassembled blackbird]);
			}

			if (available_amount($item[black market map]) > 0)
			{
				use(1, $item[black market map]);
			}
		}

		if (available_amount($item[forged identification documents]) == 0)
		{
			buy(1, $item[forged identification documents]);
		}

		if (available_amount($item[can of black paint]) == 0)
		{
			try_acquire(1, $item[can of black paint]);
		}

		if (available_amount($item[forged identification documents]) > 0)
		{
			while (available_amount($item[your father's MacGuffin diary]) == 0 && my_adventures()>2)
			{
				if (my_primestat() == $stat[moxie])
				{
					adventure(request_apathetic(1), $location[Moxie Vacation]);
				}
				else if (my_primestat() == $stat[mysticality])
				{
					adventure(request_apathetic(1), $location[Mysticality Vacation]);
				}
				else
				{
					adventure(request_apathetic(1), $location[Muscle Vacation]);
				}
			}
		}

		if (available_amount($item[your father's MacGuffin diary]) > 0)
		{
			visit_url("diary.php?textversion=1");
		}
		else
		{
			abort("Failed to retrive your father's MacGuffin diary");
		}
	}
	else
	{
		visit_url("diary.php?textversion=1");
	}
}

void WorshipQuest()
{
	HiddenCityQuest();
}

void LordSpookyravenQuest()
{
	UnlockSpookyraven();
												   
	if (contains_text(visit_url("questlog.php?which=1"),"In a Manor of Spooking") && my_adventures()>0)
	{
		while(my_adventures()>0 && available_amount($item[Lord Spookyraven's spectacles]) == 0)
		{
			print("finding spectacles","blue");
			set_property("choiceAdventure84", "3");
			adventure(request_noncombat(1), $location[haunted bedroom]);
			set_property("choiceAdventure84", "1");
		}

		while(my_adventures()>0 && available_amount($item[Spookyraven ballroom key]) == 0)
		{
			print("finding ballroom key","blue");
			adventure(request_noncombat(1), $location[haunted bedroom]);
		}

        if (available_amount($item[Spookyraven ballroom key]) == 1)
		{
			cli_execute("conditions clear");
			while (!contains_text(visit_url("manor.php"), "manor3.php") && my_adventures()>0)
			{
				print("unlocking basement","blue");
                adventure(request_noncombat(1), $location[haunted ballroom]);
			}
		}
		print("testy1","blue");
		if (contains_text(visit_url("manor.php"), "manor3.php") && (!contains_text(visit_url("manor3.php"), "chambera.gif")) && (!contains_text(visit_url("manor3.php"), "chamber.gif")))
		{
			pour_wines();
		}
		print("testy2","blue");

		if (contains_text(visit_url("manor.php"), "manor3.php") && contains_text(visit_url("manor3.php"), "chambera.gif"))
		{
			if (my_adventures() > 0)
			{
				request_monsterlevel(0);
				restore_hp(my_hp());
				visit_url("manor3.php?place=chamber");
				run_combat();				
			}
		}

		if(contains_text(visit_url("manor.php"), "manor3.php") && contains_text(visit_url("manor3.php"), "chamber.gif"))
		{
			print("Lord Spookyraven has been defeated!");
		}
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"In a Manor of Spooking"))
	{
		print("You have already completed In a Manor of Spooking.");
	}
	else
	{
		print("In a Manor of Spooking is not currently available.");
	}
}

void PalindomeQuest()
{
	if (contains_text(visit_url("questlog.php?which=1"),"Never Odd Or Even"))
	{
		if (available_amount($item[Talisman o' Nam]) == 0)
		{	if (creatable_amount($item[Talisman o' Nam]) == 0)
			{
                cli_execute("checkpoint");
				PirateQuest();
				if (available_amount($item[pirate fledges]) > 0)
				{
					equip($slot[acc3], $item[pirate fledges]);
				    set_property("choiceAdventure189", "1");
					cli_execute("set oceanDestination=sphere");
					while (!contains_text(visit_url("cove.php"),"cove3_5x2b.gif") && my_adventures()>0)
					{
						adventure(request_noncombat(1), $location[Poop Deck]);
					}

					if (contains_text(visit_url("cove.php"),"cove3_5x2b.gif"))
					{
						while(my_adventures()>0 && available_amount($item[snakehead charrrm]) < 2)
						{
							adventure(request_monsterlevel(1), $location[Belowdecks]);
						}
					}
				}
				cli_execute("outfit checkpoint");
			}

			if (creatable_amount($item[Talisman o' Nam]) > 0)
			{
				create(1, $item[Talisman o' Nam]);
			}
		}

		if (available_amount($item[Talisman o' Nam]) > 0)
		{
	        if (contains_text(visit_url("questlog.php?which=1"),"If you're going to get the Staff of Fats, it looks like the first step is to get into the Palindome. Maybe it has something to do with that amulet your father mentioned in his diary? That password looks important, too."))
			{
				cli_execute("checkpoint");
				equip($slot[acc3], $item[Talisman o' Nam]);
				visit_url("plains.php");
				cli_execute("outfit checkpoint");
			}

			if (contains_text(visit_url("questlog.php?which=1"),"Congratulations, you've discovered the fabulous Palindome, rumored to be the final resting place of the legendary Staff of Fats! Now all you have to do is find it..."))
			{
				// Get the quest items
				set_property("choiceAdventure129", "1");
				set_property("choiceAdventure130", "1");
				cli_execute("checkpoint");
				while(available_amount($item[I Love Me, Vol. I]) == 0 && my_adventures()>0)
				{
					equip($slot[acc3], $item[Talisman o' Nam]);
					adventure(request_noncombat(1), $location[Palindome]);
				}
				cli_execute("outfit checkpoint");
			}

			set_property("choiceAdventure517", "1");
			if (contains_text(visit_url("questlog.php?which=1"),"Well, you found the Staff of Fats, but then you lost it again. Good going. Looks like you're going to have to track down this Mr. Alarm guy for help...") || contains_text(visit_url("questlog.php?which=1"),"Mr. Alan Alarm has agreed to help you nullify Dr. Awkward's ineptitude field (patent pending), but wants some wet stew in return. Those ingredients again: lion oil, a bird rib, and some stunt nuts. Sounds delicious!"))
			{
				if (available_amount($item[wet stunt nut stew]) == 0)
				{
					if (creatable_amount($item[wet stunt nut stew]) == 0)
					{
						boolean tmp;
						cli_execute("checkpoint");
						while(my_adventures()>0 && available_amount($item[stunt nuts]) == 0)
						{
							equip($slot[acc3], $item[Talisman o' Nam]);
							tmp = adventure(request_combat(1), $location[Palindome]);
						}
						cli_execute("outfit checkpoint");

						while(my_adventures()>0 && available_amount($item[bird rib]) == 0)
						{
							tmp = adventure(request_combat(1), $location[Whitey's Grove]);
						}

						while(my_adventures()>0 && available_amount($item[lion oil]) == 0)
						{
							tmp = adventure(request_combat(1), $location[Whitey's Grove]);
						}
					}

					if (creatable_amount($item[wet stunt nut stew]) > 0)
					{
						create(1, $item[wet stunt nut stew]);
					}
				}

				if (available_amount($item[wet stunt nut stew]) > 0)
				{
					while (available_amount($item[Mega Gem]) == 0 && my_adventures()>0)
					{
						adventure(request_noncombat(1), $location[Knob Goblin Laboratory]);
					}
				}
			}

			if (available_amount($item[Mega Gem]) > 0 && my_adventures()>0)
			{
				cli_execute("checkpoint");
				equip($slot[acc2], $item[Mega Gem]);
				equip($slot[acc3], $item[Talisman o' Nam]);
                adventure(1, $location[Palindome]);
				cli_execute("outfit checkpoint");

				if (available_amount($item[Staff of Fats]) == 0)
				{
					abort("Something went wrong and you didn't get the Staff of Fats");
				}
			}
		}

		if (my_adventures()>0 && available_amount($item[Staff of Fats]) == 0)
		{
			abort("Something went wrong and you didn't get the Staff of Fats");
		}
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"Never Odd Or Even"))
	{
		print("You have already completed Never Odd Or Even.");
	}
	else
	{
		print("Never Odd Or Even is not currently available.");
	}
}

void DesertQuest()
{
    if (contains_text(visit_url("beach.php"),"beachtop2.gif") && my_adventures()>0)
	{
		cli_execute("conditions clear");

		// Haggle for a better price
		set_property("choiceAdventure132", "2");

		while (!contains_text(visit_url("beach.php"),"oasis.gif") && my_adventures()>0)
		{
			adventure(request_apathetic(1), $location[Desert (Unhydrated)]);
		}

		while (contains_text(visit_url("questlog.php?which=1"),"You've managed to stumble upon a hidden oasis out in the desert. That should help make your desert explorations a little less... dry.") && my_adventures()>1)
		{
			adventure(request_noncombat(1), $location[Desert (Ultrahydrated)]);
		}

		if (contains_text(visit_url("questlog.php?which=1"),"The fremegn leader Gnasir has tasked you with finding a stone rose, at his abandoned encampment near the oasis. Apparently it's an ancient symbol of his tribe or something, I dunno, whatever. He's not gonna help you unless you get it for him, though."))
		{
			while(my_adventures()>0 && available_amount($item[stone rose]) == 0)
			{
				adventure(request_noncombat(1), $location[Oasis in the Desert]);
			}

			if (available_amount($item[can of black paint]) == 0)
			{
				try_acquire(1, $item[can of black paint]);
			}

			while (contains_text(visit_url("questlog.php?which=1"),"The fremegn leader Gnasir has tasked you with finding a stone rose, at his abandoned encampment near the oasis. Apparently it's an ancient symbol of his tribe or something, I dunno, whatever. He's not gonna help you unless you get it for him, though.") && my_adventures()>1)
			{
				adventure(request_noncombat(1), $location[Desert (Ultrahydrated)]);
			}
		}

		while (contains_text(visit_url("questlog.php?which=1"),"Gnasir has asked you to prove your honor and dedication to the tribe by painting his front door black. A menial task to be sure, but at least it's not dangerous.") && my_adventures()>1)
		{
			if (available_amount($item[can of black paint]) == 0)
			{
				try_acquire(1, $item[can of black paint]);
			}

			adventure(request_noncombat(1), $location[Desert (Ultrahydrated)]);
		}

		while (contains_text(visit_url("questlog.php?which=1"),"Gnasir seemed satisfied with the tasks you performed for his tribe, and has asked you to come back later.") && my_adventures()>1)
		{
			adventure(request_noncombat(1), $location[Desert (Ultrahydrated)]);
		}

		if (contains_text(visit_url("questlog.php?which=1"),"For your worm-riding training, you need to find a 'thumper', something that produces a rhythmic vibration to summon sandworms."))
		{
			while(my_adventures()>0 && available_amount($item[drum machine]) == 0)
			{
				adventure(request_combat(1), $location[Oasis in the Desert]);
			}

			while (contains_text(visit_url("questlog.php?which=1"),"For your worm-riding training, you need to find a 'thumper', something that produces a rhythmic vibration to summon sandworms.") && my_adventures()>1)
			{
				adventure(request_noncombat(1), $location[Desert (Ultrahydrated)]);
			}
		}

		if (contains_text(visit_url("questlog.php?which=1"),"worm-riding manual"))
		{
			while(my_adventures()>0 && available_amount($item[worm-riding manual pages 3-15]) == 0)
			{
				adventure(request_noncombat(1), $location[Oasis in the Desert]);
			}
		}

		while (contains_text(visit_url("questlog.php?which=1"),"You've found all of Gnasir's missing manual pages. Time to take them back to the sietch.") && my_adventures()>1)
		{
			adventure(request_noncombat(1), $location[Desert (Ultrahydrated)]);
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You've earned your hooks and are ready to ride the worm. Literally, not in the South-of-the-Border sense."))
		{
			while(my_adventures()>0 && available_amount($item[drum machine]) == 0)
			{
				adventure(request_combat(1), $location[Oasis in the Desert]);
			}
			if (available_amount($item[drum machine]) > 0)
			{
				cli_execute("checkpoint");
				equip($item[worm-riding hooks]);
				use(1, $item[drum machine]);
				cli_execute("outfit checkpoint");
			}
		}
	}
}

void PyramidQuest()
{
	if (contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme") && my_adventures()>0)
	{
		DesertQuest();

		if (!contains_text(visit_url("beach.php"),"smallpyramid.gif"))
		{
			if(my_adventures()>0)
			{
				print("The Small Pyramid is not currently available.","red");
				return;
			}
			return;
		}

		if (item_amount($item[Staff of Ed]) == 0)
		{
			create(1, $item[Staff of Ed]);
		}

		if (item_amount($item[Staff of Ed]) == 0)
		{
			abort("You should have the Staff of Ed before you attempt the pyramid quest.");
		}
		else
		{
			if (!contains_text(visit_url("beach.php"), "pyramid.php"))
			{
				visit_url("beach.php?action=woodencity");
			}
		}

		if (contains_text(visit_url("pyramid.php"), "pyramid4_1b.gif"))
		{
			if(my_adventures() >= 7)
			{
				cli_execute("recover hp");
				cli_execute("recover mp");
				wait(3);
				set_property("recoveryScript","no_recov");
				wait(3);
				print("Ready to fight Ed the Undying.","blue");

				while(item_amount($item[holy macguffin])<1 && my_adventures()>0)
				{
					adventure(request_apathetic(1), $location[Lower Chambers]);
				}
				wait(3);
				set_property("recoveryScript","Universal_recovery");
				wait(3);

				council();
			}
			else
			{
				print("Not enough adventures to fight Ed the Undying.");
			}
			return;
		}

		if ((available_amount($item[ancient bomb]) == 0) && (available_amount($item[ancient bronze token]) == 0) && (available_amount($item[carved wooden wheel]) == 0))
		{
			// first, get the carved wooden wheel
			if (contains_text(visit_url("pyramid.php"), "pyramid3a.gif"))
			{
				while(my_adventures()>0 && (available_amount($item[carved wooden wheel]) == 0))
				{
					adventure(request_noncombat(1), $location[Upper Chamber]);
				}				
			}
		}

		// Set the wheel adventures correctly
		set_property("choiceAdventure134", "1");
		set_property("choiceAdventure135", "1");

		// pyramid4_1.gif is clear, rocks (PLANT BOMB)
		// pyramid4_4.gif is bucket, clear (GET COIN)
		// pyramid4_3.gif is rocks, vending (GET BOMB)
		// pyramid4_1b.gif is post bomb
		// if we have nothing, we want the coin first
		if ((available_amount($item[ancient bomb]) == 0) && (available_amount($item[ancient bronze token]) == 0))
		{
			if (rotate_pyramid("pyramid4_4.gif", use_tomb_ratchet))
			{
				adventure(request_apathetic(1), $location[Lower Chambers]);
			}
		}

		// exchange coin for bomb
		if ((available_amount($item[ancient bomb]) == 0) && (available_amount($item[ancient bronze token]) > 0))
		{
			if(rotate_pyramid("pyramid4_3.gif", use_tomb_ratchet))
			{
				adventure(request_apathetic(1), $location[Lower Chambers]);
			}
		}
		// plant bomb
		if (available_amount($item[ancient bomb]) > 0)
		{
			if(rotate_pyramid("pyramid4_1.gif", use_tomb_ratchet))
			{
				adventure(request_apathetic(1), $location[Lower Chambers]);
			}
		}

		if (contains_text(visit_url("pyramid.php"), "pyramid4_1b.gif"))
		{
			if(my_adventures() >= 7)
			{
				cli_execute("recover hp");
				cli_execute("recover mp");
				wait(3);
				set_property("recoveryScript","no_recov");
				wait(3);
				print("Ready to fight Ed the Undying.","blue");

				adventure(request_apathetic(7), $location[Lower Chambers]);
				wait(3);
				set_property("recoveryScript","Universal_recovery");
				wait(3);

				council();
			}
			else
			{
				print("Not enough adventures to fight Ed the Undying.");
			}
		}
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"A Pyramid Scheme"))
	{
		print("You have already completed A Pyramid Scheme.");
	}
	else
	{
		print("A Pyramid Scheme is not currently available.");
	}
}

void MacGuffinQuest()
{
    if (my_level() >= 11)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"and the Quest for the Holy MacGuffin") && my_adventures()>0)
		{
			dress_for_fighting();
			//council();
			//wait(1);

			DiaryQuest();
			WorshipQuest();
			print("LordSpookyravenQuest()","blue");
			LordSpookyravenQuest();
			print("PalindomeQuest()","blue");
			PalindomeQuest();
            PyramidQuest();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"and the Quest for the Holy MacGuffin"))
		{
			print("You have already completed the level 11 quest.");
		}
		else
		{
			print("The level 11 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 11 to attempt this quest.");
	}
}

void main()
{
	MacGuffinQuest();
}
