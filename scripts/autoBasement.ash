/*Changelog
Version History:
04-19-2011: First changed version uploaded. Fixes equipment being used by a hand or hatrack, the migration from ^ to ** for exponentials and switching outfits where an item you only have one of jumps between the main hand and your offhand.
04-20-2011: Fixed a bug in the strip_familiar-function and changed to eatsilent (thanks mredge73)
04-23-2011: Modified the reading of the combat_stat variable to avoid problems with misspelled variables. Now accepts anything that has a u,y or o as the second character...
04-26-2011: Fix the fix in the previous update...
07-03-2011: Add the Li'l Xenomorph as an item-dropping familiar and make the switching between them be slightly more efficient.
07-22-2011: Stop autoBasement from changing familiar if you are on a 100% run (controlled by the zlib-setting is_100_run)
07-27-2011: Add missing ; to make the script not fail on execution.*sigh*
08-18-2011: Add the Rogue Program as an item-dropping familiar
08-19-2011: Fix familiar dropping logic. Thanks fxer for pointing out the error.
08-21-2011: Fix the familiar dropping logic for sure this time
08-22-2011: Not to be overly confident, but I do believe this familiar dropping fix might be the last...
08-25-2011: This is getting to be a bad habit, but the familiar dropping part have been poked at again...
08-27-2011: Make it so it uses the Sandworm even if you're not going for all item drops, the way it was way back when.
10-14-2011: Change all cli_execute(maximize) calls into maximize()-calls instead. 
11-27-2011: Modify the Gauntlet-part of the script a bit to be more reliant on DA
01-09-2012: Fix the stupid maximize call.
01-16-2012: Make sure the script can handle figths under Just the best Anapest and add the new itemdropping familiars to the potential rotation
01-16-2012: Make sure we don't abort if we cannot equip an outfit during setup
01-20-2012: Just in case it ever comes up, we now also strip the pants of the scarecrow if necessary. Print a success massage after each floor to lessen confusion.
06-04-2012: Push version number to 3.0. That's the only change :)
29-04-2012 (3.1): Add autoBasement_use_Disembodied_Hand to toggle the use of the hand on or off
14-05-2012 (3.2): Set the script up to purchase stickers and sugar shorts (they are cheap and give good stat boni)
09-07-2012 (3.3): Force a refresh of your equippment when caching outfits in order to compensate for Mafia getting out of synch for whatever reason.
11-08-2012 (3.4): Add breaks to all if-checks in switches
*/

import <zlib.ash>;

// All settings and conditions below this are changed after the first time 
// the script is run by typing "zlib <variable_name> = <new value>" into the CLI.
// Changing them here after the script has run at least once will have no effect.

// Conditions to stop automation
setvar("autoBasement_break_on_combat", false);
setvar("autoBasement_break_on_hp", false);
setvar("autoBasement_break_on_mp", false);
setvar("autoBasement_break_on_mox", false);
setvar("autoBasement_break_on_mys", false);
setvar("autoBasement_break_on_mus", false);
setvar("autoBasement_break_on_element", false);
setvar("autoBasement_break_on_stat", false);
setvar("autoBasement_break_on_reward", false);

setvar("autoBasement_break_on_floor", 500);
setvar("autoBasement_break_on_level", 200);
setvar("autoBasement_break_on_mp_amount", 2000);

// Whether mp can be restored with a Jumbo Dr. Lucifer, and how much mp needs to be restored before using it.
setvar("autoBasement_use_dr_lucifer", false);
setvar("autoBasement_use_dr_lucifer_amount", 1000);

// If you don't own an item in this list it will be ignored
// Multiples of the same item can be added by entering the item twice
// For example "navel ring of navel gazing, haiku katana, haiku katana"
// This will most likely fail if you have less then the amount you request but more then 0
setvar("autoBasement_combat_equipment", "navel ring of navel gazing, equip super-sweet boom box");

// The stat to maximize when entering combat
setvar("autoBasement_combat_stat", "moxie");

// Whether familiars that drop limited items per day should be used for combats
setvar("autoBasement_get_familiar_drops", false);
setvar("autoBasement_use_Disembodied_Hand", true);

// The maximum you're willing to spend on a single potion
setvar("autoBasement_max_potion_price", 2000);
// I would suggest against modifying these, absolute increasing potions are pretty awful
setvar("autoBasement_use_percentage_potions", true);
setvar("autoBasement_use_absolute_potions", false);

//Other options
setvar("autoBasement_simulate_first", false);

// DO NOT MODIFY ANYTHING BELOW THIS LINE
boolean break_on_combat = vars["autoBasement_break_on_combat"].to_boolean();
boolean break_on_hp = vars["autoBasement_break_on_hp"].to_boolean();
boolean break_on_mp = vars["autoBasement_break_on_mp"].to_boolean();
boolean break_on_mox = vars["autoBasement_break_on_mox"].to_boolean();
boolean break_on_mys = vars["autoBasement_break_on_mys"].to_boolean();
boolean break_on_mus = vars["autoBasement_break_on_mus"].to_boolean();
boolean break_on_element = vars["autoBasement_break_on_element"].to_boolean();
boolean break_on_stat = vars["autoBasement_break_on_stat"].to_boolean();
boolean break_on_reward = vars["autoBasement_break_on_reward"].to_boolean();

int break_on_floor = vars["autoBasement_break_on_floor"].to_int();
int break_on_level = vars["autoBasement_break_on_level"].to_int();
int break_on_mp_amount = vars["autoBasement_break_on_mp_amount"].to_int();

boolean use_dr_lucifer = vars["autoBasement_use_dr_lucifer"].to_boolean();
int use_dr_lucifer_amount = vars["autoBasement_use_dr_lucifer_amount"].to_int();

string[int] combat_equipment = split_string(vars["autoBasement_combat_equipment"], ", ");
string combat_stat_string = vars["autoBasement_combat_stat"];
stat combat_stat;
switch(char_at(combat_stat_string, 1))
{
	case "u":	combat_stat = $stat[muscle]; break;
	case "y":	combat_stat = $stat[mysticality]; break;
	case "o":	combat_stat = $stat[moxie]; break;
}

boolean get_familiar_drops = vars["autoBasement_get_familiar_drops"].to_boolean();
boolean use_Disembodied_Hand = vars["autoBasement_use_Disembodied_Hand"].to_boolean();

int max_potion_price = vars["autoBasement_max_potion_price"].to_int();
boolean use_percentage_potions = vars["autoBasement_use_percentage_potions"].to_boolean();
boolean use_absolute_potions = vars["autoBasement_use_absolute_potions"].to_boolean();

boolean outfits_cached = false;

int reagent_duration = 5 + (have_skill($skill[Impetuous Sauciness]).to_int() * 5) + ((my_class() == $class[Sauceror]).to_int() * 5);

//int hp_mod = 1.0 + (have_skill($skill[Spirit of Ravioli]).to_int() * 0.25) + (have_skill($skill[Abs of Tin]).to_int() * 0.1) + (have_skill($skill[Gnomish Hardigness]).to_int() * 0.05);
//float mp_mod = 1.0 + (have_skill($skill[Wisdom of the Elder Tortoises]).to_int() * 0.5) + (have_skill($skill[Marginally Insane]).to_int() * 0.1) + (have_skill($skill[Cosmic Ugnderstanding]).to_int() * 0.05);

string maximize_familiar;
if(!have_familiar($familiar[Disembodied Hand]) || !use_Disembodied_Hand)
	maximize_familiar = ", -familiar";
else
	maximize_familiar = ", switch Disembodied Hand";

record _item {
	item i;
	effect e;
	float absolute_mod;
	float percent_mod;
	int cost;
	int duration;
	int effective_stats;
};

_item [element] elementForm;
elementForm[$element[hot]].i = $item[phial of hotness];
elementForm[$element[hot]].e = $effect[hotform];
elementForm[$element[cold]].i = $item[phial of coldness];
elementForm[$element[cold]].e = $effect[coldform];
elementForm[$element[spooky]].i = $item[phial of spookiness];
elementForm[$element[spooky]].e = $effect[spookyform];
elementForm[$element[stench]].i = $item[phial of stench];
elementForm[$element[stench]].e = $effect[stenchform];
elementForm[$element[sleaze]].i = $item[phial of sleaziness];
elementForm[$element[sleaze]].e= $effect[sleazeform];

_item [stat] equalizer;
equalizer[$stat[Mysticality]].i = $item[oil of expertise];
equalizer[$stat[Mysticality]].e = $effect[Expert Oiliness];
equalizer[$stat[Muscle]].i = $item[oil of stability];
equalizer[$stat[Muscle]].e = $effect[Stabilizing Oiliness];
equalizer[$stat[Moxie]].i = $item[oil of slipperiness];
equalizer[$stat[Moxie]].e = $effect[Slippery Oiliness];

_item [stat] [int] potions;

record _cache {
	familiar f;
	item i;
};
_cache[string] familiarCache;

record _item_data {
	effect e;
	int d;
	stat s;
};

_item_data[string] dataFile;

//Function to trap blank pages and other odd visit_url-errors
string safe_visit_url( string url )
{
    string response;
    try
    {
        response = visit_url( url );
    }
    finally
    {
        return response;
    }
    return response;
}

float cost_effectivness(_item value)
{
	vprint(value.i + " has a cost effectiveness of " + (value.percent_mod * my_basestat(my_primestat()) + value.absolute_mod) / value.cost * value.duration * value.effective_stats, 7);
	return ((value.percent_mod * my_basestat(my_primestat()) + value.absolute_mod) / value.cost * value.duration * value.effective_stats); 
}

void init()
{
	vprint("Initializing items and effects...", "green", 1);
	load_current_map("autoBasement_data", dataFile);
	foreach it in dataFile
	{
		if (it.to_item() != $item[none] && dataFile[it].e != $effect[none])
		{
			if (dataFile[it].s != $stat[none])
			{
				int index = potions[dataFile[it].s].count();
				potions[dataFile[it].s][index].i = it.to_item();
				potions[dataFile[it].s][index].e = dataFile[it].e;
				if ( dataFile[it].d != 0 )
				{
					potions[dataFile[it].s][index].duration = dataFile[it].d;
				}
				else
				{
					potions[dataFile[it].s][index].duration = reagent_duration;
				}
				potions[dataFile[it].s][index].absolute_mod = dataFile[it].e.numeric_modifier(dataFile[it].s.to_string());
				potions[dataFile[it].s][index].percent_mod = dataFile[it].e.numeric_modifier(dataFile[it].s.to_string() + " Percent") / 100.0;
				potions[dataFile[it].s][index].cost = it.to_item().mall_price();
				potions[dataFile[it].s][index].effective_stats = 1;
			}
			else
			{
				foreach s in $stats[]
				{
					int index = potions[s].count();
					potions[s][index].i = it.to_item();
					potions[s][index].e = dataFile[it].e;
					if ( dataFile[it].d != 0 )
					{
						potions[s][index].duration = dataFile[it].d;
					}
					else
					{
						potions[s][index].duration = reagent_duration;
					}
					potions[s][index].absolute_mod = dataFile[it].e.numeric_modifier(s.to_string());
					potions[s][index].percent_mod = dataFile[it].e.numeric_modifier(s.to_string() + " Percent") / 100.0;
					potions[s][index].cost = it.to_item().mall_price();
					potions[s][index].effective_stats = 3;
					if ( it == $item[mafia aria])
					{
						potions[s][index].effective_stats = 2;
					}
				}
			}
		}
	}

	foreach s in $stats[]
	{
		foreach index in potions[s]
		{
			if (potions[s][index].cost > max_potion_price)
			{
				vprint("Removing overpriced " + potions[s][index].i, 6);
			}
			else if (potions[s][index].cost <= 0 && !contains_text(to_string(potions[s][index].i), "vial"))
			{
				vprint("Removing bad priced " + potions[s][index].i, 6);
			}
			else if (potions[s][index].absolute_mod == 0.0 && potions[s][index].percent_mod == 0.0)
			{
				vprint("Removing nonbuffing " + potions[s][index].i, 6);
			}
			else if (potions[s][index].percent_mod == 0.0 && potions[s][index].absolute_mod > 0.0 && !use_absolute_potions)
			{
				vprint("Removing absolute potion " + potions[s][index].i, 6);
			}
			else if (potions[s][index].absolute_mod == 0.0 && potions[s][index].percent_mod > 0.0 && !use_percentage_potions)
			{
				vprint("Removing percentage potion " + potions[s][index].i, 6);
			}
			else if (contains_text(to_string(potions[s][index].i), "vial"))
			{
				if(item_amount($item[vial of blue slime]) > 0 && item_amount($item[vial of yellow slime]) > 0 && item_amount($item[vial of red slime]) > 0)
				{
					vprint("Setting price of vial of slime to 3 times valueOfAdventure", 6);
					potions[s][index].cost = to_int(get_property("valueOfAdventure")) * 3;
					continue;
				}
				else
					vprint("Removing bad priced " + potions[s][index].i, 6);
			}
			else
			{
				continue;
			}
			remove potions[s][index];
		}
		sort potions[s] by ((value.percent_mod * my_basestat(my_primestat()) + value.absolute_mod) / value.cost * value.duration * value.effective_stats * -1.0);
	}
	
	//Acquire cheap and good items for the non-combats
	cli_execute("stickers wrestler, wrestler, wrestler");
	retrieve_item(1, $item[sugar shorts]);

	vprint("Items and effects initialization complete!", "green", 1);
}

boolean strip_familiar(string tested_outfit)
{
	item[int] outfits = outfit_pieces(tested_outfit);
	item hand;
	item hat;
	item pants;
	familiar current = my_familiar();
	
	if(count(outfits) < 3) //Make sure we have enough pieces to test against, abort otherwise
	{
		vprint("Passed outfit (" + tested_outfit + ") contains less than 3 items. Please recheck your inventory.", "red", 0);
	}
	
	if(have_familiar($familiar[disembodied hand]))
		hand = familiar_equipped_equipment($familiar[disembodied hand]);
	if(have_familiar($familiar[hatrack]))
		hat = familiar_equipped_equipment($familiar[hatrack]);
	if(have_familiar($familiar[fancypants scarecrow]))
		pants = familiar_equipped_equipment($familiar[fancypants scarecrow]);
	
	if(hat != $item[none])
	{
		use_familiar($familiar[hatrack]);
		equip($slot[familiar],$item[none]);
		use_familiar(current);
	}
	if(hand != $item[none])
	{
		use_familiar($familiar[disembodied hand]);
		equip($slot[familiar],$item[none]);
		use_familiar(current);
	}
	if(pants != $item[none])
	{
		use_familiar($familiar[fancypants scarecrow]);
		equip($slot[familiar],$item[none]);
		use_familiar(current);
	}	
	return true;
}

boolean switch_hand(string tested_outfit)
{
	item[int] outfits = outfit_pieces(tested_outfit);
	item weapon = outfits[1];
	item offhand = outfits[2];
	
	if(item_amount(weapon) == 0 && equipped_item($slot[off-hand]) == weapon)
	{
		equip($slot[off-hand], $item[none]);
		return true;
	}
	else if(item_amount(offhand) == 0 && equipped_item($slot[weapon]) == offhand)
	{
		equip($slot[weapon], $item[none]);
		return true;
	}
	
	return false;
}

void cache_outfits()
{
	if (outfits_cached || (my_basestat($stat[Mysticality]) < 200 || my_basestat($stat[Muscle]) < 200 || my_basestat($stat[Moxie]) < 200))
	{
		return;
	}

	vprint("Caching outfits...", "green", 1);
	string custom_outfits=visit_url("account_manageoutfits.php");
	
	boolean outfit_exists(string page, string o) {
		return contains_text(page,"value=\""+o+"\"");
	}

	if (outfit_exists(custom_outfits, "Mysticality"))
	{
		strip_familiar("Mysticality");
		switch_hand("Mysticality");
		if(outfit("Mysticality")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	maximize("Mysticality" + maximize_familiar, false);
	cli_execute("outfit save Mysticality");
	familiarCache["Mysticality"].f = my_familiar();
	familiarCache["Mysticality"].i = familiar_equipped_equipment(my_familiar());

	if (outfit_exists(custom_outfits, "Muscle"))
	{
		strip_familiar("Muscle");
		switch_hand("Muscle");
		if(outfit("Muscle")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	maximize("Muscle" + maximize_familiar, false);
	cli_execute("outfit save Muscle");
	familiarCache["Muscle"].f = my_familiar();
	familiarCache["Muscle"].i = familiar_equipped_equipment(my_familiar());

	if (outfit_exists(custom_outfits, "Moxie"))
	{
		strip_familiar("Moxie");
		switch_hand("Moxie");
		if(outfit("Moxie")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	maximize("Moxie" + maximize_familiar, false);
	cli_execute("outfit save Moxie");
	familiarCache["Moxie"].f = my_familiar();
	familiarCache["Moxie"].i = familiar_equipped_equipment(my_familiar());

	if (outfit_exists(custom_outfits, "Gauntlet"))
	{
		strip_familiar("Gauntlet");
		switch_hand("Gauntlet");
		if(outfit("Gauntlet")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	maximize("HP" + maximize_familiar, false);
	cli_execute("outfit save Gauntlet");
	familiarCache["Gauntlet"].f = my_familiar();
	familiarCache["Gauntlet"].i = familiar_equipped_equipment(my_familiar());

	if (outfit_exists(custom_outfits, "MPDrain"))
	{
		strip_familiar("MPDrain");
		switch_hand("MPDrain");
		if(outfit("MPDrain")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	string command = "MP" + maximize_familiar;
	foreach it in $items[]
	{
		if (it.boolean_modifier("Moxie May Control MP") || it.boolean_modifier("Moxie Controls MP"))
		{
			command = command + ", -equip " + it.to_string();
		}
	}
	maximize(command, false);
	cli_execute("outfit save MPDrain");
	familiarCache["MP"].f = my_familiar();
	familiarCache["MP"].i = familiar_equipped_equipment(my_familiar());

	if (outfit_exists(custom_outfits, "MP Regen"))
	{
		strip_familiar("MP Regen");
		switch_hand("MP Regen");
		if(outfit("MP Regen")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	maximize(".5 MP Regen min, .5 MP Regen max" + maximize_familiar, false);
	cli_execute("outfit save MP Regen");
	familiarCache["MP Regen"].f = my_familiar();
	familiarCache["MP Regen"].i = familiar_equipped_equipment(my_familiar());

	command = combat_stat.to_string();
	foreach i in combat_equipment
	{
		item equipment = combat_equipment[i].to_item();
		if (equipment != $item[none] && available_amount(equipment) > 0 )
		{
			command = command + ", +equip " + equipment.to_string();
		}
	}
	command = command + ", -familiar";
	if(combat_stat.to_string() == "muscle")
		command = command + ", +melee";
	else if(combat_stat.to_string() == "moxie")
		command = command + ", -melee";

	if (outfit_exists(custom_outfits, "Damage"))
	{
		strip_familiar("Damage");
		switch_hand("Damage");
		if(outfit("Damage")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	maximize(command, false);
	cli_execute("outfit save Damage");
	familiarCache["Damage"].f = $familiar[none];
	familiarCache["Damage"].i = $item[none];

	outfits_cached = true;

	vprint("Outfits caching complete!", "green", 1);
}

boolean equip_cached_outfit(string o, boolean f)
{
	strip_familiar(o);
	switch_hand(o);
	outfit(o);
	if (f)
	{	
		use_familiar(familiarCache[o].f);
		equip($slot[familiar], familiarCache[o].i);
	}

	return true;
}

boolean equip_cached_outfit(string o)
{
	return equip_cached_outfit(o, true);
}

boolean try_increase_stat(int goal, stat s, string check)
{
	string estpotion = "";
	cli_execute("whatif quiet"); //Reset speculations
	switch (check)
	{
		case "hp":	if(my_maxhp() > goal) return true; break;
		case "mp":	if(my_maxmp() > goal) return true; break;
		default:	if(my_buffedstat(s) >= goal) return true; break;
	}
	
	if (have_effect(equalizer[my_primestat()].e) == 0)
	{
		vprint("Estimating effect of equalizer potion.", "purple", 7);
		estpotion = "up " + to_string(equalizer[my_primestat()].e) + "; ";
		cli_execute("whatif " + estpotion + "quiet;");
		switch (check)
		{
			case "hp":	if(my_maxhp() > goal) return true; break;
			case "mp":	if(my_maxmp() > goal) return true; break;
			default:	if(numeric_modifier("_spec", "Buffed " + to_string(s)) >= goal) return true; break;
		}
	}

	foreach i in potions[s]
	{
		if (have_effect(potions[s][i].e) == 0 && cost_effectivness(potions[s][i]) > 0.25)
		{
			estpotion = estpotion + "up " + to_string(potions[s][i].e) + "; ";
			vprint("Trying the effect of " + potions[s][i].i, "purple", 7);
			cli_execute("whatif " + estpotion + "quiet;");
			switch (check)
			{
				case "hp":	if(my_maxhp() > goal) return true; break;
				case "mp":	if(my_maxmp() > goal) return true; break;
				default:	if(numeric_modifier("_spec", "Buffed " + to_string(s)) >= goal) return true; break;
			}
		}
	}

	return false;
}

boolean try_increase_stat(int goal, stat s)
{
	return try_increase_stat(goal, s, "");
}

boolean increase_stat(int goal, stat s, string check)
{
	switch (check)
	{
		case "hp":	if(my_maxhp() > goal) return true; break;
		case "mp":	if(my_maxmp() > goal) return true; break;
		default:	if(my_buffedstat(s) >= goal) return true; break;
	}
	
	if (have_effect(equalizer[my_primestat()].e) == 0)
	{
		retrieve_item(1, equalizer[my_primestat()].i); //Try to avoid mafia going away and buying several hundreds of things
		use(1, equalizer[my_primestat()].i);
		switch (check)
		{
			case "hp":	if(my_maxhp() > goal) return true; break;
			case "mp":	if(my_maxmp() > goal) return true; break;
			default:	if(my_buffedstat(s) >= goal) return true; break;
		}
	}

	foreach i in potions[s]
	{
		if (have_effect(potions[s][i].e) == 0 && cost_effectivness(potions[s][i]) > 0.25)
		{
			retrieve_item(1, potions[s][i].i); //Try to avoid mafia going away and buying several hundreds of things
			use(1, potions[s][i].i);
			switch (check)
			{
				case "hp":	if(my_maxhp() > goal) return true; break;
				case "mp":	if(my_maxmp() > goal) return true; break;
				default:	if(my_buffedstat(s) >= goal) return true; break;
			}
		}
	}

	return false;
}

boolean increase_stat(int goal, stat s)
{
	return increase_stat(goal, s, "");
}

int elemental_damage(int level, element elem)
{
	if (have_effect(elementForm[elem].e) > 0) return 1;

	return ((level ** 1.4) * 4.5 * 1.1) * (1.0 - (elemental_resistance(elem) / 100.0));
}

void uneffect_form_except(element elem)
{
	foreach potion_element in elementForm
	{
		if (elem != potion_element)
		{
			cli_execute("uneffect " + elementForm[potion_element].e.to_string());
		}
	}
}

boolean festering_restore(int mp)
{
	if(my_mp() >= mp)
	{
		return true;
	}
    if(my_maxmp() < mp)
	{
		return false;
	}
    if(get_property("sidequestNunsCompleted") == "fratboy" && floor((mp - my_mp()) / 1000) < 3- get_property("nunsVisits").to_int())
	{
		while(mp - my_mp() > 999 && get_property("nunsVisits").to_int() < 3)
		{
			cli_execute("nuns");
		}
	}
	if (use_dr_lucifer == true)
	{
		if(mp - my_mp() < use_dr_lucifer_amount)
		{
			vprint("autoBasement_use_dr_lucifer is true, however MP restore amount (" + (mp - my_mp()).to_string() + ") is less than autoBasement_use_dr_lucifer_amount (" + use_dr_lucifer_amount.to_string() + "), restoring mp normally.", 2);
			restore_mp(mp);
		}
		else
		{
			vprint("autoBasement_use_dr_lucifer is true and MP restore amount (" + (mp - my_mp()).to_string() + ") is greater than autoBasement_use_dr_lucifer_amount (" + use_dr_lucifer_amount.to_string() + "), attempting to use a Jumbo Dr. Lucifer.", 2);
			if(my_fullness() < fullness_limit())
			{
				if (my_maxhp() * 9 < mp - my_mp())
				{
					vprint("Somehow your maxhp isn't high enough to restore enough mp with a Jumbo Dr. Lucifer. This is a very improbable situation.", "red", 2);
				}
				else
				{
					restore_hp(mp - my_mp() / 9);
					eatsilent(1, $item[Jumbo Dr. Lucifer]);
				}
			}
			else
			{
				vprint("Unable to consume a Jumbo Dr. Lucifer because you are completely full.", "red", 2);
			}
		}
	}
	else
	{
		vprint("autoBasement_use_dr_lucifer is false, restoring mp normally.", 2);
		restore_mp(mp);
	}
    
    
    if(my_mp() < mp)
	{
		return false;
	}
    return true;        
}

boolean elemental_test(int level, element elem1, element elem2)
{
	string element_familiar = ", -familiar";
	if (have_familiar($familiar[Exotic Parrot]))
	{
		element_familiar = ", switch Exotic Parrot";
	}
	else if (have_familiar($familiar[Disembodied Hand]))
	{
		element_familiar = maximize_familiar;
	}

	maximize(".5 " + to_string(elem1) + " resistance, .5 " + to_string(elem2) + " resistance, 0.01 hp" + element_familiar, false);
	
	uneffect_form_except(elem1);
	
	if((elemental_damage(level, elem1) + elemental_damage(level, elem2) > my_maxhp()) && have_effect(elementForm[elem1].e) == 0)
	{
		use(1, elementForm[elem1].i);
		maximize(to_string(elem2) + " resistance, 0.01 hp" + element_familiar, false);
	}
	
	if(elemental_damage(level, elem1) + elemental_damage(level, elem2) > my_maxhp())
	{
		float damage = elemental_damage(level, elem1) + elemental_damage(level, elem2);
		increase_stat(damage, $stat[Muscle], "hp");
	}

	if(elemental_damage(level, elem1) + elemental_damage(level, elem2) < my_maxhp())
	{
		restore_hp(my_maxhp());
		if (elemental_damage(level, elem1) + elemental_damage(level, elem2) < my_hp())
		{
			return true;
		}
	}

	return false;
}

boolean stat_test(int goal, stat s)
{
	if (!outfits_cached || !equip_cached_outfit(s.to_string()))
	{
		maximize(goal.to_string() + " max, " + s.to_string() + maximize_familiar, false);
	}

	if (vars["autoBasement_simulate_first"] == "true")
	{
		if (try_increase_stat(goal, s))
		{
			cli_execute("whatif quiet"); //Reset speculations
			return increase_stat(goal, s);
		}
		else
			return false;
	}

	return increase_stat(goal, s);
}

boolean mp_test(int goal)
{
	if (!outfits_cached || !equip_cached_outfit("MPDrain"))
	{
		string command = "MP" + maximize_familiar;
		foreach it in $items[]
		{
			if (it.boolean_modifier("Moxie May Control MP") || it.boolean_modifier("Moxie Controls MP"))
			{
				print(it);
				command = command + ", -equip " + it.to_string();
			}
		}
		maximize(command, false);
	}		

	return increase_stat(goal, $stat[Mysticality], "mp");
}

void maximize_mp_regen()
{
	if (!(outfits_cached && equip_cached_outfit("MP Regen")))
	{
		maximize(".5 mp regen min, .5 mp regen max" + maximize_familiar, false);
	}
}

void basement(int num_turns)
{
	if (num_turns > my_adventures() || num_turns == 0)
	{
		num_turns = my_adventures();
	}

	int total_num_turns = num_turns;

	init();

	string mp_recovery = get_property("mpAutoRecovery");
	string mp_recovery_target = get_property("mpAutoRecoveryTarget");
	set_property("mpAutoRecovery", "-0.05");
	set_property("mpAutoRecoveryTarget", "-0.05");

	int base_stat = my_basestat(my_primestat());
	
	set_location($location[Fernswarthy's Basement]);
	string page = safe_visit_url("basement.php");

	while (my_adventures() > 0 && num_turns > 0)
	{
		if (inebriety_limit() < my_inebriety())
		{
			vprint("You're too drunk to screw around in a basement, quitting", "red", 0);
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
			vprint("You don't seem to be in the basement, quitting", "red", 0);
			break;
		}

		if (level >= break_on_floor )
		{
			vprint("Current basement level (" + level.to_string() + ") >= autoBasement_break_on_floor (" + break_on_floor.to_string() + "), quitting", "red", 2);
			break;
		}

		if (my_level() >= break_on_level  )
		{
			vprint("Current character level (" + my_level().to_string() + ") >= autoBasement_break_on_level (" + break_on_level.to_string() + "), quitting", "red", 2);
			break;
		}

		if (have_effect($effect[beaten up]) > 0)
		{
			cli_execute("uneffect beaten up");
			vprint("You were beaten up, quitting", "red", 1);
			break;
		}

		if (available_amount($item[sugar shorts]) == 0)
			retrieve_item(1, $item[sugar shorts]);
		if (equipped_item($slot[sticker1]) != $item[scratch 'n' sniff wrestler sticker])
			cli_execute("stickers wrestler, wrestler, wrestler");
			
		cache_outfits();

		if (base_stat != my_basestat(my_primestat()))
		{
			base_stat = my_basestat(my_primestat());
			foreach s in $stats[]
			{
				sort potions[s] by ((value.percent_mod * my_basestat(my_primestat()) + value.absolute_mod) / value.cost * value.duration * value.effective_stats * -1.0);
			}
		}
	
		if (page.contains_text("Lift 'em!") || page.contains_text("Push it Real Good") || page.contains_text("Ring that Bell!"))
		{
			vprint("Basement level "+ level.to_string() +": Muscle Test", "blue", 1);
			if (break_on_mus)
			{
				vprint("autoBasement_break_on_mus is true, quitting", "red", 2);
				break;
			}

			int goal = ceil((level ** 1.4) * 1.08);
			
			if (stat_test(goal, $stat[Muscle]))
			{	
				page = visit_url("basement.php?action=1&pwd");
				vprint("Muscle Test passed", "green", 5);
			}
			else
			{	
				vprint("unable to buff Muscle to " + goal.to_string() + ", quitting", "red", 1);
				break;
			}
		}
		else if (page.contains_text("Gathering:  The Magic") || page.contains_text("Mop the Floor with the Mops") || page.contains_text("Do away with the 'doo"))
		{
			vprint("Basement level "+ level.to_string() +": Mysticality Test", "blue", 1);
			if (break_on_mys)
			{
				vprint("autoBasement_break_on_mys is true, quitting", "red", 2);
				break;
			}
			
			int goal = ceil((level ** 1.4) * 1.08);			
			
			if (stat_test(goal, $stat[Mysticality]))
			{	
				page = visit_url("basement.php?action=1&pwd");
				vprint("Mysticality Test passed", "green", 5);
			}
			else
			{	
				vprint("unable to buff Mysticality to " + goal.to_string() + ", quitting", "red", 1);
				break;
			}
		}
		else if (page.contains_text("Don't Wake the Baby") || page.contains_text("Grab a cue") || page.contains_text("Put on the Smooth Moves"))
		{
			vprint("Basement level "+ level.to_string() +": Moxie Test", "blue", 1);			
			if (break_on_mox)
			{
				vprint("autoBasement_break_on_mox is true, quitting", "red", 2);
				break;
			}

			int goal = ceil((level ** 1.4) * 1.08);

			if (stat_test(goal, $stat[Moxie]))
			{	
				page = visit_url("basement.php?action=1&pwd");
				vprint("Moxie Test passed", "green", 5);
			}
			else
			{	
				vprint("unable to buff Moxie to " + goal.to_string() + ", quitting", "red", 1);
				break;
			}
		}
		else if (page.contains_text("A Festering Powder"))
		{
			vprint("Basement level "+ level.to_string() +": MP Test", "blue", 1);
			if (break_on_mp)
			{
				vprint("autoBasement_break_on_mp is true, quitting", "red", 2);
				break;
			}

			int mp = ceil(((level ** 1.4)* 1.67) * 1.08);
			
			if (mp > break_on_mp_amount)
			{
				vprint("mp test (" + mp.to_string() + ") > autoBasement_break_on_mp_amount (" + break_on_mp_amount.to_string() + "), quitting", "red", 2);
				break;
			}

			if (mp_test(mp) &&  festering_restore(mp))
			{	
				page = visit_url("basement.php?action=1&pwd");

				if (page.contains_text("Drained, you slump away."))
				{
					break;
				}
				vprint("MP Test passed", "green", 5);
			}
			else
			{	
				vprint("unable to buff mp to " + mp.to_string() + ", quitting", "red", 1);
				break;
			}
		}
		else if (page.contains_text("Throwin' Down the Gauntlet"))
		{
			vprint("Basement level "+ level.to_string() +": HP Test", "blue", 1);
			if (break_on_hp)
			{
				vprint("autoBasement_break_on_hp is true, quitting", "red", 2);
				break;
			}
			
			int hp = ((level ** 1.4)* 10) * 1.08;
						
			if (!(outfits_cached && equip_cached_outfit("Gauntlet")))
			{
				maximize((0.0009*hp) + " da, 1 hp" + maximize_familiar, false);
			}
			
			int damage = ceil( hp * (1 - damage_absorption_percent()/100));
			
			if ( my_maxhp() < damage )
			{
				increase_stat(damage, $stat[Muscle], "hp");
			}
			
			if (my_maxhp() > damage)
			{	
				restore_hp(damage + 10);
			}

			if (my_hp() > damage)
			{	
				page = visit_url("basement.php?action=1&pwd");

				if (page.contains_text("Midway through the gauntlet"))
				{
					break;
				}
				vprint("HP Test passed", "green", 5);
			}
			else
			{	
				vprint("unable to buff hp to " + damage.to_string() + ", quitting", "red", 1);
				break;
			}
		}
		else if (page.contains_text("Beast with") || page.contains_text("Stone Golem") || page.contains_text("Bottles of Beer on a Golem") || page.contains_text("ghost of Fernswarthy's") || page.contains_text("dimensional horror") || page.contains_text("-Headed Hydra"))
		{
			vprint("Basement level "+ level.to_string() +": Monster", "blue", 1);
			if (break_on_combat)
			{
				vprint("autoBasement_break_on_combat is true, quitting", "red", 2);
				break;
			}

			int goal = ceil((level ** 1.4) * 1.08);

			if (!(outfits_cached && equip_cached_outfit("Damage", false)))
			{
				string command = combat_stat.to_string();
				foreach i in combat_equipment
				{
					item equipment = combat_equipment[i].to_item();
					if (equipment != $item[none] && available_amount(equipment) > 0 && can_equip(equipment))
					{
						command = command + ", +equip " + equipment.to_string();
					}
				}
				maximize(command, false);
			}

			increase_stat(goal, combat_stat);
			
			if(to_familiar(vars["is_100_run"]) == $familiar[none])
			{
				int mushrooms = (have_familiar($familiar[astral badger]) == true ? to_int(get_property( "_astralDrops" )) : 5);
				int absinths = (have_familiar($familiar[green pixie]) == true ? to_int(get_property( "_absintheDrops" )) : 5);
				int gongs = (have_familiar($familiar[llama lama]) == true ? to_int(get_property( "_gongDrops" )) : 5);
				int tokens =  (have_familiar($familiar[rogue program]) == true ? to_int(get_property( "_tokenDrops" )) : 5);
				int transponders =  (have_familiar($familiar[li'l xenomorph]) == true ? to_int(get_property( "_transponderDrops" )) : 5);
				int aguas = (have_familiar($familiar[baby sandworm]) == true ? to_int(get_property( "_aguaDrops" )) : 5);
				int folios = (have_familiar($familiar[blavious kloop]) == true ? to_int(get_property( "_kloopDrops" )) : 5);
				int greases = (have_familiar($familiar[bloovian groose]) == true ? to_int(get_property( "_grooseDrops" )) : 5);
				int item_drop = min(5,min(mushrooms,min(absinths,min(gongs, min(tokens, min(transponders, min(aguas, min(folios, greases))))))));
				
				if (get_familiar_drops && item_drop != 5)
				{
					if (mushrooms <= item_drop && mushrooms < 5)
					{	
						use_familiar($familiar[astral badger]);
					}
					else if (absinths <= item_drop && absinths < 5)
					{	
						use_familiar($familiar[green pixie]);
					}
					else if (gongs <= item_drop && gongs < 5)
					{
						use_familiar($familiar[llama lama]);
					}
					else if (tokens <= item_drop && tokens < 5)
					{
						use_familiar($familiar[rogue program]);
					}
					else if (transponders <= item_drop && transponders < 5)
					{
						use_familiar($familiar[li'l xenomorph]);
					}
					else if (aguas <= item_drop || aguas < 5)
					{	
						use_familiar($familiar[baby sandworm]);
					}
					else if (folios <= item_drop || folios < 5)
					{	
						use_familiar($familiar[blavious kloop]);
					}
					else if (greases <= item_drop || greases < 5)
					{	
						use_familiar($familiar[bloovian groose]);
					}
				}
				else if (have_familiar($familiar[baby sandworm]))
				{
					use_familiar($familiar[baby sandworm]);
				}
				else if (have_familiar($familiar[hovering sombrero]))
				{
					use_familiar($familiar[hovering sombrero]);
				}
			}
			else
				use_familiar(to_familiar(vars["is_100_run"]));

			restore_hp(my_maxhp());
			restore_mp(250);

			page = visit_url("basement.php?action=1&pwd");
			page = run_combat();

			if (page.contains_text("slink away"))
			{
				vprint("lost the fight, quitting", "red", 1);
				break;
			}
			else if (page.contains_text("WINWINWIN"))
			{
				page = visit_url("basement.php");
				vprint("Monster defeated", "green", 5);
			}
			else if (!page.contains_text("Combat"))
			{
				vprint("you don't seem to be in a combat, quitting", "red", 2);
				break;
			}
		}
		else if (page.contains_text("figurecard.gif"))
		{
			vprint("Basement level "+ level.to_string() +": Stat reward", "blue", 1);
			
			if (break_on_stat)
			{
				vprint("autoBasement_break_on_stat is true, quitting", "red", 1);
				break;
			}

			maximize_mp_regen();

			if (my_primestat() == $stat[Mysticality])
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else if (my_primestat() == $stat[Muscle])
			{
				if (my_basestat($stat[Mysticality]) < my_basestat($stat[Moxie]))
				{
					page = visit_url("basement.php?action=1&pwd");
				}
				else
				{
					page = visit_url("basement.php?action=2&pwd");
				}
			}
			else if (my_primestat() == $stat[Moxie])
			{
				page = visit_url("basement.php?action=2&pwd");
			}
			vprint("Stat gain received", "green", 5);
		}
		else if (page.contains_text("twojackets.gif"))
		{
			vprint("Basement level "+ level.to_string() +": Stat reward", "blue", 1);
			
			if (break_on_stat)
			{
				vprint("autoBasement_break_on_stat is true, quitting", "red", 1);
				break;
			}

			maximize_mp_regen();

			if (my_primestat() == $stat[Mysticality])
			{
				if (my_basestat($stat[Moxie]) < my_basestat($stat[Muscle]))
				{
					page = visit_url("basement.php?action=1&pwd");
				}
				else
				{
					page = visit_url("basement.php?action=2&pwd");
				}
			}
			else if (my_primestat() == $stat[Muscle])
			{
				page = visit_url("basement.php?action=2&pwd");
			}
			else if (my_primestat() == $stat[Moxie])
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			vprint("Stat gain received", "green", 5);
		}
		else if (page.contains_text("twopills.gif"))
		{
			vprint("Basement level "+ level.to_string() +": Stat reward", "blue", 1);
			
			if (break_on_stat)
			{
				vprint("autoBasement_break_on_stat is true, quitting", "red", 1);
				break;
			}

			maximize_mp_regen();

			if (my_primestat() == $stat[Mysticality])
			{
				page = visit_url("basement.php?action=2&pwd");
			}
			else if (my_primestat() == $stat[Muscle])
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else if (my_primestat() == $stat[Moxie])
			{
				if (my_basestat($stat[Muscle]) < my_basestat($stat[Mysticality]))
				{
					page = visit_url("basement.php?action=1&pwd");
				}
				else
				{
					page = visit_url("basement.php?action=2&pwd");
				}
			}
			vprint("Stat gain received", "green", 5);
		}
		else if (page.contains_text("Singled Out"))
		{
			vprint("Basement level "+ level.to_string() +": Cold & Sleaze Elemental Resistance Test", "blue", 1);
			if (break_on_element)
			{
				vprint("autoBasement_break_on_element is true, quitting", "red", 2);
				break;
			}			
			
			if (elemental_test(level, $element[cold], $element[sleaze]))
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{
				vprint("unable to pass elemental test, quitting", "red", 1);
				break;
			}

			if (page.contains_text("After a few minutes"))
			{
				break;
			}
			vprint("Elemental Resistance Test passed", "green", 5);
		}
		else if (page.contains_text("Peace, Bra!"))
		{
			vprint("Basement level "+ level.to_string() +": Sleaze & Stench Elemental Resistance Test", "blue", 1);
			if (break_on_element)
			{
				vprint("autoBasement_break_on_element is true, quitting", "red", 2);
				break;
			}			
			
			if (elemental_test(level, $element[sleaze], $element[stench]))
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{
				vprint("unable to pass elemental test, quitting", "red", 1);
				break;
			}

			if (page.contains_text("You reel from the indignity and the smell"))
			{
				break;
			}
			vprint("Elemental Resistance Test passed", "green", 5);
		}
		else if (page.contains_text("Still Better than Pistachio"))
		{
			vprint("Basement level "+ level.to_string() +": Stench & Hot Elemental Resistance Test", "blue", 1);
			if (break_on_element)
			{
				vprint("autoBasement_break_on_element is true, quitting", "red", 2);
				break;
			}
			
			if (elemental_test(level, $element[stench], $element[hot]))
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{
				vprint("unable to pass elemental test, quitting", "red", 1);
				break;
			}

			if (page.contains_text("Halfway through the cone"))
			{
				break;
			}
			vprint("Elemental Resistance Test passed", "green", 5);
		}
		else if (page.contains_text("Unholy Writes"))
		{
			vprint("Basement level "+ level.to_string() +": Hot & Spooky Elemental Resistance Test", "blue", 1);
			if (break_on_element)
			{
				vprint("autoBasement_break_on_element is true, quitting", "red", 2);
				break;
			}
				
			if (elemental_test(level, $element[hot], $element[spooky]))
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{
				vprint("unable to pass elemental test, quitting", "red", 1);
				break;
			}

			if (page.contains_text("you wish you had paid more attention in English class."))
			{
				break;
			}
			vprint("Elemental Resistance Test passed", "green", 5);
		}
		else if (page.contains_text("The Unthawed"))
		{
			vprint("Basement level "+ level.to_string() +": Spooky & Cold Elemental Resistance Test", "blue", 1);
			if (break_on_element)
			{
				vprint("autoBasement_break_on_element is true, quitting", "red", 2);
				break;
			}			
			
			if (elemental_test(level, $element[spooky], $element[cold]))
			{
				page = visit_url("basement.php?action=1&pwd");
			}
			else
			{
				vprint("unable to pass elemental test, quitting", "red", 1);
				break;
			}

			if (page.contains_text("You stand frozen to the spot"))
			{
				break;
			}
			vprint("Elemental Resistance Test passed", "green", 5);
		}
		else if(page.contains_text("De Los Dioses") || page.contains_text("The Dusk Zone") || page.contains_text("Giggity Bobbity Boo!") || page.contains_text("No Good Deed") || page.contains_text("This room is totally empty."))
		{
			vprint("Basement level "+ level.to_string() +": Reward", "blue", 1);
			if ( break_on_reward )
			{
				vprint("autoBasement_break_on_reward is true, quitting", "red", 2);
				break;
			}
			
			maximize_mp_regen();

			page = visit_url("basement.php?action=1&pwd");
			vprint("Major reward received", "green", 5);
		}
		else
		{
			vprint("unknown basement test (this should probably never happen unless the page fails to load), quitting", "red", 1);
			break;
		}

		num_turns = num_turns - 1;
	}

	set_property("mpAutoRecovery", mp_recovery);
	set_property("mpAutoRecoveryTarget", mp_recovery_target);

	if (my_adventures() == 0)
	{
		vprint("Ran out of adventures", "red", 1);
	}
	if (num_turns == 0)
	{
		vprint("Basement sucessfully automated for " + total_num_turns.to_string() + " adventures", "green", 1);
	}
	else
	{
		vprint("Basement sucessfully automated for " + (total_num_turns - num_turns).to_string() + " out of " + total_num_turns.to_string() + " adventures.", "red", 1);
	}
}

check_version("AutoBasement","AutoBasement","3.4",3113);
void main(int num_turns)
{
	basement(num_turns);
}