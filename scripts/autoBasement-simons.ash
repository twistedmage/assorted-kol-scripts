import <zlib.ash>;

setvar("autoBasement_break_on_combat", false);
setvar("autoBasement_break_on_hp", false);
setvar("autoBasement_break_on_mp", false);
setvar("autoBasement_break_on_mox", false);
setvar("autoBasement_break_on_mys", false);
setvar("autoBasement_break_on_mus", false);
setvar("autoBasement_break_on_element", false);
setvar("autoBasement_break_on_stat", false);

setvar("autoBasement_break_on_floor", 500);
setvar("autoBasement_break_on_level", 200);
setvar("autoBasement_break_on_mp_amount", 20000);

boolean break_on_combat = vars["autoBasement_break_on_combat"].to_boolean();
boolean break_on_hp = vars["autoBasement_break_on_hp"].to_boolean();
boolean break_on_mp = vars["autoBasement_break_on_mp"].to_boolean();
boolean break_on_mox = vars["autoBasement_break_on_mox"].to_boolean();
boolean break_on_mys = vars["autoBasement_break_on_mys"].to_boolean();
boolean break_on_mus = vars["autoBasement_break_on_mus"].to_boolean();
boolean break_on_element = vars["autoBasement_break_on_element"].to_boolean();
boolean break_on_stat = vars["autoBasement_break_on_stat"].to_boolean();

int break_on_floor = vars["autoBasement_break_on_floor"].to_int();
int break_on_level = vars["autoBasement_break_on_level"].to_int();
int break_on_mp_amount = vars["autoBasement_break_on_mp_amount"].to_int();

record _items {
   item i;
   effect e;
};


_items equalizer()
{
	_items equalizer;
	if (my_primestat() == $stat[mysticality])
	{
		equalizer.i = $item[oil of expertise];
		equalizer.e = $effect[Expert Oiliness];
	}
	else if (my_primestat() == $stat[muscle])
	{
		equalizer.i = $item[oil of stability];
		equalizer.e = $effect[Stabilizing Oiliness];
	}
	else if (my_primestat() == $stat[moxie])
	{
		equalizer.i = $item[oil of slipperiness];
		equalizer.e = $effect[Slippery Oiliness];
	}

	return equalizer;
}

_items bang_potion(stat s)
{
	_items bang_potion;
	for i from 819 to 827
	{
		string potion = get_property("lastBangPotion" + to_string(i));

		if (potion == "ettin strength" && s == $stat[muscle])
		{
			bang_potion.i = i.to_item();
			bang_potion.e = $effect[Strength of Ten Ettins];
			break;
		}
		else if (potion == "mental acuity" && s == $stat[mysticality])
		{
			bang_potion.i = i.to_item();
			bang_potion.e = $effect[Strange Mental Acuity];
			break;
		}
		else if (potion == "blessing" && s == $stat[moxie])
		{
			bang_potion.i = i.to_item();
			bang_potion.e = $effect[Izchak's Blessing];
			break;
		}
		else if (potion == "")
		{
			abort("Unidentified bang potion!");
		}
	}

	return bang_potion;
}

boolean increase_stat_da(int goal, stat s, boolean hand )
{
	if (my_buffedstat(s) >= goal && raw_damage_absorption()>999) return true;

	string command = "maximize da 1000 max, 0.1 "+s+" "+goal+" max";
	if (hand == true)
	{
		command = command+", switch disembodied hand";
	}
	print(command);
	cli_execute(command);
	if (my_buffedstat(s) >= goal && raw_damage_absorption()>999) return true;

	_items[int] to_try;
	int index = 0;

	to_try[index].i = equalizer().i;
	to_try[index].e = equalizer().e;
	index = index + 1;
	to_try[index].i = $item[tomato juice of powerful power];
	to_try[index].e = $effect[Tomato Power];
	index = index + 1;
	to_try[index].i = $item[potion of temporary gr8tness];
	to_try[index].e = $effect[Gr8tness];
	index = index + 1;
	to_try[index].i = bang_potion(s).i;
	to_try[index].e = bang_potion(s).e;
	index = index + 1;
	to_try[index].i = $item[glowing El Vibrato drone];
	to_try[index].e = $effect[Inscrutable exoskeleton];
	index = index + 1;
	switch (s)
	{
	case $stat[muscle]:
		to_try[index].i = $item[Ben-Gal Balm];
		to_try[index].e = $effect[Go Get 'Em, Tiger!];
		index = index + 1;
		to_try[index].i = $item[philter of phorce];
		to_try[index].e = $effect[Phorcefullness];
		index = index + 1;
		to_try[index].i = $item[Ferrigno's Elixir of Power];
		to_try[index].e = $effect[Incredibly Hulking];
		index = index + 1;

		to_try[index].i = $item[blood of the Wereseal];
		to_try[index].e = $effect[Temporary Lycanthropy];
		index = index + 1;
		break;
	
	case $stat[mysticality]:
		to_try[index].i = $item[glittery mascara];
		to_try[index].e = $effect[Glittering Eyelashes];
		index = index + 1;
		to_try[index].i = $item[ointment of the occult];
		to_try[index].e = $effect[Mystically Oiled];
		index = index + 1;
		to_try[index].i = $item[Hawking's Elixir of Brilliance];
		to_try[index].e = $effect[On the Shoulders of Giants];
		index = index + 1;

		to_try[index].i = $item[funky dried mushroom];
		to_try[index].e = $effect[Seeing Colors];
		index = index + 1;
		break;
	
	case $stat[moxie]:
		to_try[index].i = $item[hair spray];
		to_try[index].e = $effect[Butt-Rock Hair];
		index = index + 1;
		to_try[index].i = $item[serum of sarcasm];
		to_try[index].e = $effect[Superhuman Sarcasm];
		index = index + 1;
		to_try[index].i = $item[Connery's Elixir of Audacity];
		to_try[index].e = $effect[Cock of the Walk];
		index = index + 1;

		to_try[index].i = $item[jellyfish gel];
		to_try[index].e = $effect[Old School Pompadour];
		index = index + 1;
		break;
	}

	foreach i in to_try
	{
print("testy["+i+"]="+to_try[i].e,"orange");
		if(to_string(to_try[i].e)=="none")
		{
			abort("Ran out of buffs to apply?");
		}
		if (have_effect(to_try[i].e) == 0)
		{
			use(1, to_try[i].i);
			if (my_buffedstat(s) >= goal) return true;
		}
	}

	return false;
}



boolean increase_stat(int goal, stat s, boolean hand )
{
	if (my_buffedstat(s) >= goal) return true;

	string command = "maximize " + goal.to_string() + " max, " + s.to_string();
	if (hand == true)
	{
		command = command + ", switch disembodied hand";
	}
	cli_execute(command);

	if (my_buffedstat(s) >= goal) return true;

	_items[int] to_try;
	int index = 0;

	to_try[index].i = equalizer().i;
	to_try[index].e = equalizer().e;
	index = index + 1;
	to_try[index].i = $item[tomato juice of powerful power];
	to_try[index].e = $effect[Tomato Power];
	index = index + 1;
	to_try[index].i = $item[potion of temporary gr8tness];
	to_try[index].e = $effect[Gr8tness];
	index = index + 1;
	to_try[index].i = bang_potion(s).i;
	to_try[index].e = bang_potion(s).e;
	index = index + 1;
	switch (s)
	{
	case $stat[muscle]:
		to_try[index].i = $item[Ben-Gal Balm];
		to_try[index].e = $effect[Go Get 'Em, Tiger!];
		index = index + 1;
		to_try[index].i = $item[philter of phorce];
		to_try[index].e = $effect[Phorcefullness];
		index = index + 1;
		to_try[index].i = $item[Ferrigno's Elixir of Power];
		to_try[index].e = $effect[Incredibly Hulking];
		index = index + 1;

		to_try[index].i = $item[blood of the Wereseal];
		to_try[index].e = $effect[Temporary Lycanthropy];
		index = index + 1;
		break;
	
	case $stat[mysticality]:
		to_try[index].i = $item[glittery mascara];
		to_try[index].e = $effect[Glittering Eyelashes];
		index = index + 1;
		to_try[index].i = $item[ointment of the occult];
		to_try[index].e = $effect[Mystically Oiled];
		index = index + 1;
		to_try[index].i = $item[Hawking's Elixir of Brilliance];
		to_try[index].e = $effect[On the Shoulders of Giants];
		index = index + 1;

		to_try[index].i = $item[funky dried mushroom];
		to_try[index].e = $effect[Seeing Colors];
		index = index + 1;
		break;
	
	case $stat[moxie]:
		to_try[index].i = $item[hair spray];
		to_try[index].e = $effect[Butt-Rock Hair];
		index = index + 1;
		to_try[index].i = $item[serum of sarcasm];
		to_try[index].e = $effect[Superhuman Sarcasm];
		index = index + 1;
		to_try[index].i = $item[Connery's Elixir of Audacity];
		to_try[index].e = $effect[Cock of the Walk];
		index = index + 1;

		to_try[index].i = $item[jellyfish gel];
		to_try[index].e = $effect[Old School Pompadour];
		index = index + 1;
		break;
	}

	foreach i in to_try
	{
print("testy["+i+"]="+to_try[i].e,"orange");
		if(to_string(to_try[i].e)=="none")
		{
			abort("Ran out of buffs to apply!");
		}
		if (have_effect(to_try[i].e) == 0)
		{
			use(1, to_try[i].i);
			if (my_buffedstat(s) >= goal) return true;
		}
	}

	return false;
}

boolean increase_stat_by_buffs(int goal, stat s)
{
	if (my_buffedstat(s) >= goal) return true;

	_items[int] to_try;
	int index = 0;

	to_try[index].i = equalizer().i;
	to_try[index].e = equalizer().e;
	index = index + 1;
	to_try[index].i = $item[tomato juice of powerful power];
	to_try[index].e = $effect[Tomato Power];
	index = index + 1;
	to_try[index].i = $item[potion of temporary gr8tness];
	to_try[index].e = $effect[Gr8tness];
	index = index + 1;
	to_try[index].i = bang_potion(s).i;
	to_try[index].e = bang_potion(s).e;
	index = index + 1;
	switch (s)
	{
	case $stat[muscle]:
		to_try[index].i = $item[Ben-Gal Balm];
		to_try[index].e = $effect[Go Get 'Em, Tiger!];
		index = index + 1;
		to_try[index].i = $item[philter of phorce];
		to_try[index].e = $effect[Phorcefullness];
		index = index + 1;
		to_try[index].i = $item[Ferrigno's Elixir of Power];
		to_try[index].e = $effect[Incredibly Hulking];
		index = index + 1;

		to_try[index].i = $item[blood of the Wereseal];
		to_try[index].e = $effect[Temporary Lycanthropy];
		index = index + 1;
		break;
	
	case $stat[mysticality]:
		to_try[index].i = $item[glittery mascara];
		to_try[index].e = $effect[Glittering Eyelashes];
		index = index + 1;
		to_try[index].i = $item[ointment of the occult];
		to_try[index].e = $effect[Mystically Oiled];
		index = index + 1;
		to_try[index].i = $item[Hawking's Elixir of Brilliance];
		to_try[index].e = $effect[On the Shoulders of Giants];
		index = index + 1;

		to_try[index].i = $item[funky dried mushroom];
		to_try[index].e = $effect[Seeing Colors];
		index = index + 1;
		break;
	
	case $stat[moxie]:
		to_try[index].i = $item[hair spray];
		to_try[index].e = $effect[Butt-Rock Hair];
		index = index + 1;
		to_try[index].i = $item[serum of sarcasm];
		to_try[index].e = $effect[Superhuman Sarcasm];
		index = index + 1;
		to_try[index].i = $item[Connery's Elixir of Audacity];
		to_try[index].e = $effect[Cock of the Walk];
		index = index + 1;

		to_try[index].i = $item[jellyfish gel];
		to_try[index].e = $effect[Old School Pompadour];
		index = index + 1;
		break;
	}

	foreach i in to_try
	{
print("testy["+i+"]="+to_try[i].e,"orange");
		if(to_string(to_try[i].e)=="none")
		{
			abort("Ran out of buffs to apply!");
		}
		if (have_effect(to_try[i].e) == 0)
		{
			use(1, to_try[i].i);
			if (my_buffedstat(s) >= goal) return true;
		}
	}

	return false;
}


boolean increase_stat(int goal, stat s)
{
	return increase_stat(goal, s, false);
}

int elemental_damage(int level, element e)
{
	switch (e)
	{
	case $element[cold]:	if (have_effect($effect[coldform]) > 0)		return 1;
	case $element[sleaze]:	if (have_effect($effect[sleazeform]) > 0)	return 1;
	case $element[stench]:	if (have_effect($effect[stenchform]) > 0)	return 1;
	case $element[hot]:		if (have_effect($effect[hotform]) > 0)		return 1;
	case $element[spooky]:	if (have_effect($effect[spookyform]) > 0)	return 1;
	}

	return (( to_float(level) ** 1.4) * 4.5 * 1.1) * (1.0 - (elemental_resistance(e) / 100.0));
}

void uneffect_form_except(effect e)
{
	if (e != $effect[coldform])		cli_execute("uneffect coldform");
	if (e != $effect[sleazeform])	cli_execute("uneffect sleazeform");
	if (e != $effect[stenchform])	cli_execute("uneffect stenchform");
	if (e != $effect[hotform])		cli_execute("uneffect hotform");
	if (e != $effect[spookyform])	cli_execute("uneffect spookyform");
}

void basement(int num_turns)
{
	if (num_turns > my_adventures() || num_turns == 0)
	{
		num_turns = my_adventures();
	}
	set_location($location[Fernswarthy's Basement]);
	string page = visit_url("basement.php");

	while (my_adventures() > 0 && num_turns > 0)
	{
		if (inebriety_limit() < my_inebriety())
		{
			abort("You're too drunk to screw around in a basement.");
			break;
		}
					
		int level = 0;
	
		if (page.contains_text("<b>Fernswarthy's Basement, Level "))
		{
			int start_index = index_of(page, "<b>Fernswarthy's Basement, Level ") + "<b>Fernswarthy's Basement, Level ".length();
	
			string sub = substring(page, start_index);
			sub = substring(sub, 0, index_of(sub, "</b>"));
	
			level = sub.to_int();
		}
		else
		{
			abort("You don't seem to be in the basement");
			break;
		}

		if (level > break_on_floor )
		{
			break;
		}

		if (my_level() > break_on_level  )
		{
			break;
		}

		if (have_effect($effect[beaten up]) > 0)
		{
			cli_execute("uneffect beaten up");
		}

		cli_execute("mood basement");
		cli_execute("mood execute");
	
		if (page.contains_text("Lift 'em!") || page.contains_text("Push it Real Good") || page.contains_text("Ring that Bell!"))
		{
			print("Basement: Muscle Test", "blue");
			if (break_on_mus)
			{
				break;
			}

			if (increase_stat((level ** 1.4) * 1.08, $stat[muscle]))
			{	
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{	
				break;
			}
		}
		else if (page.contains_text("Gathering:  The Magic") || page.contains_text("Mop the Floor with the Mops") || page.contains_text("Do away with the 'doo"))
		{
			print("Basement: Mysticality Test", "blue");
			if (break_on_mys)
			{
				break;
			}	

			if (increase_stat((level ** 1.4) * 1.08, $stat[mysticality]))
			{	
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{	
				break;
			}
		}
		else if (page.contains_text("Don't Wake the Baby") || page.contains_text("Grab a cue") || page.contains_text("Put on the Smooth Moves"))
		{
			print("Basement: Moxie Test", "blue");			
			if (break_on_mox)
			{
				break;
			}

			if (increase_stat((level ** 1.4) * 1.08, $stat[moxie]))
			{	
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{	
				break;
			}
		}
		else if (page.contains_text("A Festering Powder"))
		{
			print("Basement: MP Test", "blue");
			if (break_on_mp)
			{
				break;
			}

			int mp = ((level ** 1.4)* 1.67) * 1.08;

			if (mp > break_on_mp_amount)
			{
				break;
			}
			increase_stat((level ** 1.4) * 1.08, $stat[mysticality]);

			
			if (my_maxmp() >= mp )
			{	
				restore_mp(mp);
			}
			if (my_mp() >= mp)
			{	
				page = visit_url("basement.php?action=1&pwd");

				if (page.contains_text("Drained, you slump away."))
				{
					print("Got drained!");
					break;
				}
			}
			else
			{	
				break;
			}
		}
		else if (page.contains_text("Throwin' Down the Gauntlet"))
		{
			print("Basement: HP Test", "blue");
			if (break_on_hp)
			{
				break;
			}

			increase_stat_da((level ** 1.4) * 1.08, $stat[muscle],true);

			if(raw_damage_absorption()<1000)
			{
				abort("Not enough da! only "+raw_damage_absorption());
			}
			
			// Assuming DA is .1.
			int damage = (level ** 1.4) * 1.08;
			
			if (my_maxhp() > damage)
			{	
				restore_hp(damage + 10);
			}

			if (my_hp() > damage)
			{	
				page = visit_url("basement.php?action=1&pwd");

				if (page.contains_text("Midway through the gauntlet"))
				{
					print("Got pounded!");
					break;
				}
			}
			else
			{	
				break;
			}
		}
		else if (page.contains_text("Beast with") || page.contains_text("Stone Golem") || page.contains_text("Bottles of Beer on a Golem") || page.contains_text("ghost of Fernswarthy's") || page.contains_text("dimensional horror") || page.contains_text("-Headed Hydra"))
		{
			print("Basement: Monster", "blue");

			if(page.contains_text("Bottles of Beer on a Golem"))
			{
				increase_stat((level ** 1.4) * 1.08, $stat[muscle], false);
				increase_stat((level ** 1.4) * 1.08, $stat[mysticality], false);
			}
			else
			{
				increase_stat((level ** 1.4) * 1.08, $stat[muscle], false);
				cli_execute("outfit combat");
			}
			if (have_familiar($familiar[baby sandworm]))
			{
				use_familiar($familiar[baby sandworm]);
			}
			else if (have_familiar($familiar[hovering sombrero]))
			{
				use_familiar($familiar[hovering sombrero]);
			}
			restore_hp(my_maxhp());
			restore_mp(500);
print("lol1");
			page = visit_url("basement.php?action=1&pwd");
/*			
			if (break_on_combat)
			{
				break;
			}
print("lol1.5");
			page = run_combat();
print("lol1.6");
*/
			
			if(page.contains_text("Bottles of Beer on a Golem"))
			{
				page = use_skill($skill[entangling noodles]);
				while(!page.contains_text("slink away") && !page.contains_text("You win the fight") )
				{
					page = throw_item($item[divine can of silly string]);
				}
			}
			else if(page.contains_text("ghost of Fernswarthy"))
			{
				page = use_skill($skill[entangling noodles]);
				while(!page.contains_text("slink away") && !page.contains_text("You win the fight") )
				{
					page = use_skill($skill[fearful fettucini]);
				}
			}
			else
			{
				page = use_skill($skill[entangling noodles]);
				while(!page.contains_text("slink away") && !page.contains_text("You win the fight") )
				{
					page = use_skill($skill[weapon of the pastalord]);
				}
			}
			
			
			
			
			
			
			
			
			if (page.contains_text("slink away"))
			{
				print("Got beaten!");
				break;
			}
			else if (page.contains_text("You win the fight"))
			{print("lol3");
				page = visit_url("basement.php");
			}
			else if (!page.contains_text("Combat"))
			{print("lol4");
				break;
			}
		}
		else if (page.contains_text("figurecard.gif"))
		{
			if (break_on_stat)
			{
				break;
			}

			cli_execute("maximize .5 mp regen min, .5 mp regen max, switch disembodied hand");

			if (my_primestat() == $stat[mysticality])
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else if (my_primestat() == $stat[muscle])
			{
				if (my_basestat($stat[mysticality]) < my_basestat($stat[moxie]))
				{
					page = visit_url("basement.php?action=1&pwd");
				}
				else
				{
					page = visit_url("basement.php?action=2&pwd");
				}
			}
			else if (my_primestat() == $stat[moxie])
			{
				page = visit_url("basement.php?action=2&pwd");
			}
		}
		else if (page.contains_text("twojackets.gif"))
		{
			if (break_on_stat)
			{
				break;
			}

			cli_execute("maximize .5 mp regen min, .5 mp regen max, switch disembodied hand");

			if (my_primestat() == $stat[mysticality])
			{
				if (my_basestat($stat[moxie]) < my_basestat($stat[muscle]))
				{
					page = visit_url("basement.php?action=1&pwd");
				}
				else
				{
					page = visit_url("basement.php?action=2&pwd");
				}
			}
			else if (my_primestat() == $stat[muscle])
			{
				page = visit_url("basement.php?action=2&pwd");
			}
			else if (my_primestat() == $stat[moxie])
			{
				page = visit_url("basement.php?action=1&pwd");
			}
		}
		else if (page.contains_text("twopills.gif"))
		{
			if (break_on_stat)
			{
				break;
			}

			cli_execute("maximize .5 mp regen min, .5 mp regen max, switch disembodied hand");

			if (my_primestat() == $stat[mysticality])
			{
				page = visit_url("basement.php?action=2&pwd");
			}
			else if (my_primestat() == $stat[muscle])
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else if (my_primestat() == $stat[moxie])
			{
				if (my_basestat($stat[muscle]) < my_basestat($stat[mysticality]))
				{
					page = visit_url("basement.php?action=1&pwd");
				}
				else
				{
					page = visit_url("basement.php?action=2&pwd");
				}
			}
		}
		else if (page.contains_text("Singled Out"))
		{
			print("Basement: Cold & Sleaze Elemental Resistance Test", "blue");
			if (break_on_element)
			{
				break;
			}
			cli_execute("maximize .5 cold resistance, .5 sleaze resistance, switch Exotic Parrot, switch Disembodied Hand");

			uneffect_form_except($effect[coldform]);

			if ((elemental_damage(level, $element[cold]) + elemental_damage(level, $element[sleaze]) > my_maxhp()))
			{
				if( have_effect($effect[coldform]) == 0)
				{
					use(1, $item[phial of coldness]);
				}
				cli_execute("maximize sleaze resistance, switch Exotic Parrot, switch Disembodied Hand");
			}
			int damage = elemental_damage(level, $element[sleaze]) + elemental_damage(level, $element[cold]);
			increase_stat_by_buffs((damage+10)*1.08, $stat[muscle]);
			
			if (damage > my_maxhp())
			{
print("elemental_damage(level, $element[sleaze])="+elemental_damage(level, $element[sleaze]));
print("elemental_damage(level, $element[cold])="+elemental_damage(level, $element[cold]));
				break;
			}

			restore_hp(my_maxhp());
			page = visit_url("basement.php?action=1&pwd");

			if (page.contains_text("After a few minutes"))
			{
				break;
			}
		}
		else if (page.contains_text("Peace, Bra!"))
		{
			print("Basement: Sleaze & Stench Elemental Resistance Test", "blue");
			if (break_on_element)
			{
				break;
			}

			cli_execute("maximize .5 sleaze resistance, .5 stench resistance, switch Exotic Parrot, switch Disembodied Hand");

			uneffect_form_except($effect[sleazeform]);

			if ((elemental_damage(level, $element[sleaze]) + elemental_damage(level, $element[stench]) > my_maxhp()))
			{
				if( have_effect($effect[sleazeform]) == 0)
				{
					use(1, $item[phial of sleaziness]);
				}
				cli_execute("maximize stench resistance, switch Exotic Parrot, switch Disembodied Hand");
			}

			int damage = elemental_damage(level, $element[sleaze]) + elemental_damage(level, $element[stench]);
			increase_stat_by_buffs((damage+10)*1.08, $stat[muscle]);
			
			if (damage > my_maxhp())
			{
print("elemental_damage(level, $element[sleaze])="+elemental_damage(level, $element[sleaze]));
print("elemental_damage(level, $element[stench])="+elemental_damage(level, $element[stench]));
				break;
			}

			restore_hp(my_maxhp());
			page = visit_url("basement.php?action=1&pwd");

			if (page.contains_text("You reel from the indignity and the smell"))
			{
				break;
			}
		}
		else if (page.contains_text("Still Better than Pistachio"))
		{
			print("Basement: Stench & Hot Elemental Resistance Test", "blue");
			if (break_on_element)
			{
				break;
			}

			cli_execute("maximize .5 stench resistance, .5 hot resistance, switch Exotic Parrot, switch Disembodied Hand");

			uneffect_form_except($effect[stenchform]);

			if ((elemental_damage(level, $element[stench]) + elemental_damage(level, $element[hot]) > my_maxhp()))
			{
				if( have_effect($effect[stenchform]) == 0)
				{
					use(1, $item[phial of stench]);
				}	
				cli_execute("maximize hot resistance, switch Exotic Parrot, switch Disembodied Hand");
			}

			int damage = elemental_damage(level, $element[stench]) + elemental_damage(level, $element[hot]);
			increase_stat_by_buffs((damage+10)*1.08, $stat[muscle]);
			
			if (damage > my_maxhp())
			{
print("elemental_damage(level, $element[stench])="+elemental_damage(level, $element[stench]));
print("elemental_damage(level, $element[hot])="+elemental_damage(level, $element[hot]));
				break;
			}

			restore_hp(my_maxhp());
			page = visit_url("basement.php?action=1&pwd");

			if (page.contains_text("Halfway through the cone"))
			{
				break;
			}
		}
		else if (page.contains_text("Unholy Writes"))
		{
			print("Basement: Hot & Spooky Elemental Resistance Test", "blue");
			if (break_on_element)
			{
				break;
			}

			cli_execute("maximize .5 hot resistance, .5 spooky resistance, switch Exotic Parrot, switch Disembodied Hand");

			uneffect_form_except($effect[hotform]);

			if ((elemental_damage(level, $element[hot]) + elemental_damage(level, $element[spooky]) > my_maxhp()))
			{
				if( have_effect($effect[hotform]) == 0)
				{
					use(1, $item[phial of hotness]);
				}	
				cli_execute("maximize spooky resistance, switch Exotic Parrot, switch Disembodied Hand");
			}

			
			int damage = elemental_damage(level, $element[hot]) + elemental_damage(level, $element[spooky]);
			increase_stat_by_buffs((damage+10)*1.08, $stat[muscle]);
			
			if (damage > my_maxhp())
			{
print("elemental_damage(level, $element[hot])="+elemental_damage(level, $element[hot]));
print("elemental_damage(level, $element[spooky])="+elemental_damage(level, $element[spooky]));
				break;
			}

			restore_hp(my_maxhp());
			page = visit_url("basement.php?action=1&pwd");

			if (page.contains_text("you wish you had paid more attention in English class."))
			{
				break;
			}
		}
		else if (page.contains_text("The Unthawed"))
		{
			print("Basement: Spooky & Cold Elemental Resistance Test", "blue");
			if (break_on_element)
			{
				break;
			}

			cli_execute("maximize .5 spooky resistance, .5 cold resistance, switch Exotic Parrot, switch Disembodied Hand");

			uneffect_form_except($effect[spookyform]);

			if ((elemental_damage(level, $element[spooky]) + elemental_damage(level, $element[cold]) > my_maxhp()))
			{
				if( have_effect($effect[spookyform]) == 0)
				{
					use(1, $item[phial of spookiness]);
				}
				cli_execute("maximize cold resistance, switch Exotic Parrot, switch Disembodied Hand");
			}
			
			int damage = elemental_damage(level, $element[spooky]) + elemental_damage(level, $element[cold]);
			increase_stat_by_buffs((damage+10)*1.08, $stat[muscle]);
			
			if (damage > my_maxhp())
			{
print("elemental_damage(level, $element[spooky])="+elemental_damage(level, $element[spooky]));
print("elemental_damage(level, $element[cold])="+elemental_damage(level, $element[cold]));
				break;
			}

			restore_hp(my_maxhp());
			page = visit_url("basement.php?action=1&pwd");

			if (page.contains_text("You stand frozen to the spot"))
			{
				break;
			}
		}
		else
		{
			break;
		}

		num_turns = num_turns - 1;
	}

	print("Unable to continue automating the basement.");

	if (my_adventures() == 0)
	{
		print("Ran out of adventures", "red");
	}
}

check_version("AutoBasement","AutoBasement","1.0",3113);
void main(int num_turns)
{
	cli_execute("set mpAutoRecovery = 0.0");
	basement(num_turns);
}

