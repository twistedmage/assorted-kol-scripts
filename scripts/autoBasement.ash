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
06-05-2013 (4.0): Major update to make the script use the new maximize-features and no longer rely on the built-in datafile
06-05-2013: Consolidate the check for not ok commands into the ok()-function
06-08-2013: Point out that raising autoBasement_max_potion_price might help with getting past failed levels
06-11-2013: If max_potion_price is larger than autoBuyPriceLimit, raise the latter to the former (and reset at the end of the script)
			Make sure we equip the cached outfits before we do the test for which it is intended
			Don't abort due to being Beaten Up if we can remove it
			Make sure we honor the combat-equipment setting when maximizing
			Make sure that we continue to honor the disallowing of precentage based and absolute potions
			Fix several bugs with the maximize_wrap function and the elemental_test function that would lead to either overbuffing or failure
			Move the debug printing to verbosity levels 7 and 9 respectively
06-12-2013: Actually cache an Elemental Resistance outfit so we can use it
			Fix bug with overbuffing for Gauntlet tests
			Don't use up irreplaceable currencies (such as FDKOL and AWOL commendations)
			Also don't use up the fudge wand
2013-06-13: Clean up the code for coinmaster handling
			Fix the over-buffing for the Gauntlet for real (hopefully)
2013-06-14: Remove version checking. Official release of the SVN version
2013-06-16: Maximize for initiative as well if we use myst as our combat stat
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
setvar("autoBasement_break_on_level", 30);
setvar("autoBasement_break_on_mp_amount", 2000);

// Whether mp can be restored with a Jumbo Dr. Lucifer, and how much mp needs to be restored before using it.
setvar("autoBasement_use_dr_lucifer", false);
setvar("autoBasement_use_dr_lucifer_amount", 1000);

// Do you want to use eating, drinking and spleening to buff
setvar("autoBasement_eat_to_buff", false);
setvar("autoBasement_drink_to_buff", false);
setvar("autoBasement_spleen_to_buff", false);

// If you don't own an item in this list it will be ignored
// Multiples of the same item can be added by entering the item twice
// For example "navel ring of navel gazing, haiku katana, haiku katana"
// This will most likely fail if you have less then the amount you request but more then 0
setvar("autoBasement_combat_equipment", "navel ring of navel gazing");

// The stat to maximize when entering combat
setvar("autoBasement_combat_stat", "Muscle");

// Whether familiars that drop limited items per day should be used for combats
setvar("autoBasement_get_familiar_drops", false);
setvar("autoBasement_use_Disembodied_Hand", true);

// The maximum you're willing to spend on a single potion
setvar("autoBasement_max_potion_price", 2000);
// I would suggest against modifying these, absolute increasing potions are pretty awful
setvar("autoBasement_use_percentage_potions", true);
setvar("autoBasement_use_absolute_potions", false);

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

boolean autoBasement_eat_to_buff = vars["autoBasement_eat_to_buff"].to_boolean();
boolean autoBasement_drink_to_buff = vars["autoBasement_drink_to_buff"].to_boolean();
boolean autoBasement_spleen_to_buff = vars["autoBasement_spleen_to_buff"].to_boolean();

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

record _cache {
	familiar f;
	item i;
};
_cache[string] familiarCache;

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

boolean strip_familiar(string tested_outfit)
{
	item[int] outfits = outfit_pieces(tested_outfit);
	item hand;
	item hat;
	item pants;
	familiar current = my_familiar();
	
	if(count(outfits) < 3) //Make sure we have enough pieces to test against, abort otherwise
	{
		vprint("Passed outfit (" + tested_outfit + ") contains fewer than 3 items. Please recheck your inventory.", "red", 0);
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

boolean ok(item it, string command, effect ef) {
	if($coinmasters[FDKOL Tent, A. W. O. L. Quartermaster, Fudge Wand] contains it.seller)
		return false;
	if(it.fullness > 0 && autoBasement_eat_to_buff == false)
		return false;
	if(it.inebriety > 0 && autoBasement_drink_to_buff == false && my_inebriety() + it.inebriety > inebriety_limit())
		return false;
	if(it.spleen > 0 && autoBasement_spleen_to_buff == false)
		return false;
	if(contains_text(command, "gong"))
		return false;
	if(command == "")
		return false;
	if(!use_percentage_potions && (numeric_modifier(ef, "Maximum HP Percent") > 0 || numeric_modifier(ef, "Maximum MP Percent") > 0 || numeric_modifier(ef, "Moxie Percent") > 0 || numeric_modifier(ef, "Muscle Percent") > 0 || numeric_modifier(ef, "Mysticality Percent") > 0))
		return false;
	if(!use_absolute_potions && (numeric_modifier(ef, "Maximum HP") > 0 || numeric_modifier(ef, "Maximum MP") > 0 || numeric_modifier(ef, "Moxie") > 0 || numeric_modifier(ef, "Muscle") > 0 || numeric_modifier(ef, "Mysticality") > 0))
		return false;
	return true;
}

boolean maximize_wrap(string max_string, int goal, int current) {
	float[int] sum;
	string[int] perform;
	int j;
	
	if(current > goal)
		return true;
	
	foreach i, rec in maximize(max_string, max_potion_price, 1, true, true) {
		if(!ok(rec.item, rec.command, rec.effect))
			continue;
	
		if(rec.score > 0) {
			perform[j] = rec.command;
			if(j==0)
				sum[j] = rec.score;
			else
				sum[j] = sum[j-1] + rec.score;
			j += 1;
		}
	}

	if(sum[j-1] + current > goal) {
		for i from 0 to j-1 {
			vprint("Max_string = " + max_string, 9);
			if(contains_text(max_string, "Disembodied Hand") && my_familiar() == $familiar[none])
				use_familiar($familiar[disembodied hand]);

			cli_execute(perform[i]);
			if(sum[i] + current >  goal)
				return true;
		}
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

	if (outfit_exists(custom_outfits, "Mysticality")) {
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
	
	if (outfit_exists(custom_outfits, "Elemental Resistance")) {
		strip_familiar("Elemental Resistance");
		switch_hand("Elemental Resistance");
		if(outfit("Elemental Resistance")) {} //Make sure we don't abort if we cannot equip the outfit
	}
	cli_execute("refresh equip");
	maximize("all res" + maximize_familiar, false);
	cli_execute("outfit save Elemental Resistance");
	familiarCache["Elemental Resistance"].f = my_familiar();
	familiarCache["Elemental Resistance"].i = familiar_equipped_equipment(my_familiar());	

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

boolean increase_stat(int goal, stat s, string check)
{
	switch (check)
	{
		case "hp":	if(my_maxhp() > goal) return true; break;
		case "mp":	if(my_maxmp() > goal) return true; break;
		default:	if(my_buffedstat(s) >= goal) return true; break;
	}

	return maximize_wrap((check == "" ? to_string(s) : check), goal, (check == "hp" ? my_maxhp() : check == "mp" ? my_maxmp() : my_buffedstat(s)));
}

boolean increase_stat(int goal, stat s)
{
	return increase_stat(goal, s, "");
}

boolean increase_stat(int goal, string command, stat s) {
	if(my_buffedstat(s) >= goal) return true;

	return maximize_wrap(command, goal, my_buffedstat(s));
}

int elemental_damage(int level, element elem)
{
	boolean isWeak(element ele) {
		switch(ele) {
			case $element[cold]: return (have_effect($effect[sleazeform]) > 0 || have_effect($effect[stenchform]) > 0);
			case $element[hot]: return (have_effect($effect[coldform]) > 0 || have_effect($effect[spookyform]) > 0);
			case $element[spooky]: return (have_effect($effect[coldform]) > 0 || have_effect($effect[sleazeform]) > 0);
			case $element[stench]: return (have_effect($effect[spookyform]) > 0 || have_effect($effect[hotform]) > 0);
			case $element[sleaze]: return (have_effect($effect[hotform]) > 0 || have_effect($effect[stenchform]) > 0);
			default: return true;
		}
	}
	if (have_effect(elementForm[elem].e) > 0) return 1;
	
	float base_damage = ((level ** 1.4) * 4.5 * 1.1);
	float M = (my_class() == $class[pastamancer] || my_class() == $class[sauceror] ? 5 : 0);
	float R = numeric_modifier("_spec", to_string(elem) + " resistance");
	
	vprint("Element: " + elem, 7);
	vprint("Base Damage: " + base_damage, 7);
	vprint("CLass modifier: " + M, 7);
	vprint("Elemental resistance:"  + R, 7);
	vprint("isWeak(elem): " + isWeak(elem), 7);
	vprint("Fraction of damage resisted: " + ((90.0 - 50.0 * (5.0/6.0) ** (R -4) + M)/100.0), 7);
	vprint("---", 7);
	
	if(R <= 3)
		return base_damage * (1.0 - (10 * R + M)/100.0) * (to_int(isWeak(elem)) + 1);
	else
		return base_damage * (1.0 - (90.0 - 50.0 * (5.0/6.0) ** (R -4) + M)/100.0) * (to_int(isWeak(elem)) + 1);
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
	float[int] sum;
	string[int] perform, perform_whatif;
	int j;
	float damage = elemental_damage(level, elem1) + elemental_damage(level, elem2);
	vprint("0", "purple", 7);
	cli_execute("whatif quiet");
	damage = elemental_damage(level, elem1) + elemental_damage(level, elem2);
	vprint("1", "purple", 7);
	if(damage < my_maxhp()) {
		restore_hp(my_maxhp());
		if(damage < my_hp())
			return true;
	}
	vprint("2", "purple", 7);
	if(outfits_cached) {
		strip_familiar("Elemental Resistance");
		switch_hand("Elemental Resistance");
		equip_cached_outfit("Elemental Resistance");
	}
	
	damage = elemental_damage(level, elem1) + elemental_damage(level, elem2);
	vprint("3", "purple", 7);	
	if(damage < my_maxhp()) {
		restore_hp(my_maxhp());
		if(damage < my_hp())
			return true;
	}
	vprint("4", "purple", 7);	
	if (have_familiar($familiar[Exotic Parrot]))
	{
		element_familiar = ", switch Exotic Parrot";
	}
	else if (have_familiar($familiar[Disembodied Hand]))
	{
		element_familiar = maximize_familiar;
	}

	uneffect_form_except(elem1);
	
	damage = elemental_damage(level, elem1) + elemental_damage(level, elem2);
	
	if(damage < my_maxhp()) {
		restore_hp(my_maxhp());
		if(damage < my_hp())
			return true;
	}
	vprint("5", "purple", 7);	
	foreach i, rec in maximize(".5 " + to_string(elem1) + " resistance, .5 " + to_string(elem2) + " resistance, 0.01 hp" + element_familiar, max_potion_price, 1, true, true) {
		if(!ok(rec.item, rec.command, rec.effect))
			continue;
		if(rec.score > 0) {
			if(j == 0) {
				perform[j] = rec.command;
				perform_whatif[j] = (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
			} else {
				perform[j] = perform[j-1] + "; " + rec.command;
				perform_whatif[j] = perform_whatif[j-1] + "; " + (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
			}
			j += 1;
		}
	}
	for i from 0 to j-1 {
		cli_execute("whatif " + perform_whatif[i] + "; quiet");
		if(elemental_damage(level, elem1) + elemental_damage(level, elem2) < my_maxhp()) {
			cli_execute(perform[i]);
			vprint(6, "purple", 7);
			break;
		} else if(i == j-1) {
			vprint("Chugging a " + elementForm[elem1].i + " and moving on from there.", 5);
			cli_execute("use 1 " + elementForm[elem1].i);
		}
		cli_execute("whatif quiet");
	}
	vprint(7, "purple", 7);
	cli_execute("whatif quiet");
	j = 0;
	if (elemental_damage(level, elem1) + elemental_damage(level, elem2) > my_maxhp() && have_effect(elementForm[elem1].e) > 0) {
		foreach i, rec in maximize(to_string(elem2) + " resistance, 0.01 hp" + element_familiar, max_potion_price, 1, true, true) {
			if(!ok(rec.item, rec.command, rec.effect))
				continue;
			if(contains_text(rec.command, "phial"))
				continue;
			if(rec.score > 0) {
				if(j == 0) {
					perform[j] = rec.command;
					perform_whatif[j] = (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
				} else {
					perform[j] = perform[j-1] + "; " + rec.command;
					perform_whatif[j] = perform_whatif[j-1] + "; " + (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
				}
				j += 1;
			}
		}	
		vprint(8, "purple", 7);
		for i from 0 to j-1 {
			cli_execute("whatif " + perform_whatif[i] + "; quiet");
			if(elemental_damage(level, elem1) + elemental_damage(level, elem2) < my_maxhp()) {
				cli_execute(perform[i]);
				break;
			} else if(i == j-1) {
				vprint("Executing the maximizer commands and moving on to HP maximization.", 5);
				cli_execute(perform[i]);
			}
			cli_execute("whatif quiet");
		}
		cli_execute("whatif quiet");
	}
	vprint(9, "purple", 7);
	damage = elemental_damage(level, elem1) + elemental_damage(level, elem2);
	if(damage > my_maxhp())
		maximize_wrap("hp", ceil(damage), my_maxhp());

	vprint(10, "purple", 7);
	if(elemental_damage(level, elem1) + elemental_damage(level, elem2) < my_maxhp())
	{
		restore_hp(my_maxhp());
		cli_execute("whatif quiet;");
		if (elemental_damage(level, elem1) + elemental_damage(level, elem2) < my_hp())
		{
			return true;
		}
	}

	return false;
}

boolean stat_test(int goal, stat s)
{
	if(outfits_cached) {
		strip_familiar(s.to_string());
		switch_hand(s.to_string());		
		equip_cached_outfit(s.to_string());
	}
	return maximize_wrap(s.to_string() + maximize_familiar + ", -tie", goal, to_int(my_buffedstat(s)));
}

boolean mp_test(int goal)
{
	if (outfits_cached) {
		strip_familiar("MPDrain");
		switch_hand("MPDrain");
		equip_cached_outfit("MPDrain");
	}
	string command = "MP" + maximize_familiar;
	foreach it in $items[]
	{
		if (it.boolean_modifier("Moxie May Control MP") || it.boolean_modifier("Moxie Controls MP"))
		{
			print(it);
			command = command + ", -equip " + it.to_string();
		}
	}
	if(maximize_wrap(command, goal, my_maxmp()))
		return true;
	else
		return maximize_wrap("10 mysticality, " + command, goal, my_maxmp());
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

	string mp_recovery = get_property("mpAutoRecovery");
	string mp_recovery_target = get_property("mpAutoRecoveryTarget");
	string autoBuyLimit = get_property("autoBuyPriceLimit");
	set_property("mpAutoRecovery", "-0.05");
	set_property("mpAutoRecoveryTarget", "-0.05");
	set_property("autoBuyPriceLimit", max(max_potion_price,get_property("autoBuyPriceLimit").to_int()));

	int base_stat = my_basestat(my_primestat());
	
	string page = safe_visit_url("basement.php");

	while (my_adventures() > 0 && num_turns > 0)
	{
		set_location($location[Fernswarthy's Basement]);
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
			vprint("Current basement level (" + level.to_string() + ") >= autoBasement_break_on_floor (" + break_on_floor.to_string() + "), quitting", "red", 1);
			break;
		}

		if (my_level() >= break_on_level  )
		{
			vprint("Current character level (" + my_level().to_string() + ") >= autoBasement_break_on_level (" + break_on_level.to_string() + "), quitting", "red", 1);
			break;
		}

		if (have_effect($effect[beaten up]) > 0)
		{
			vprint("You are beaten up, attenmpting to remove", "red", 1);
			cli_execute("uneffect beaten up");
			if(have_effect($effect[beaten up]) > 0) {
				vprint("Unable to uneffect beaten up, quitting", "red", 1);
				break;
			}
		}

		if (available_amount($item[sugar shorts]) == 0)
			retrieve_item(1, $item[sugar shorts]);
		if (equipped_item($slot[sticker1]) != $item[scratch 'n' sniff wrestler sticker])
			cli_execute("stickers wrestler, wrestler, wrestler");
			
		cache_outfits();
		cli_execute("refresh inv"); //Attempt to avoid Mafia getting out of sync by refreshing the inventory between levels
		//cli_execute("refresh equip");

		if (base_stat != my_basestat(my_primestat()))
		{
			base_stat = my_basestat(my_primestat());
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
			
			if(outfits_cached) {
				strip_familiar("Gauntlet");
				switch_hand("Gauntlet");		
				equip_cached_outfit("Gauntlet");
			}
			
			int damage = ceil( hp * (1 - damage_absorption_percent()/100));
			
			float[int] sum;
			string[int] perform, perform_whatif;
			int j;
			if(damage > my_maxhp()) {
				foreach i, rec in maximize((0.0009*hp) + " da, 1 hp" + maximize_familiar, max_potion_price, 1, true, true) {
					if(!ok(rec.item, rec.command, rec.effect))
						continue;
					if(rec.score > 0) {
						if(j == 0) {
							perform[j] = rec.command;
							perform_whatif[j] = (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
						} else {
							perform[j] = perform[j-1] + "; " + rec.command;
							perform_whatif[j] = perform_whatif[j-1] + "; " + (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
						}
						j += 1;
					}
				}
				cli_execute("whatif quiet");
				for i from 0 to j-1 {
					cli_execute("whatif " + perform_whatif[i] + "; quiet");
					damage = ceil( hp * (1 - min(90.0, (square_root(numeric_modifier("_spec", "Damage Absorption") * 10) - 10))/100));					
					if(damage < numeric_modifier("_spec", "Buffed HP Maximum")) {
						cli_execute(perform[i]);
						break;
					} else if(i == j-1)
						cli_execute(perform[i]);
					cli_execute("whatif quiet");
				}
				cli_execute("whatif quiet");
				j = 0;
				if (damage > my_maxhp() && raw_damage_absorption() < 1000) {
					foreach i, rec in maximize("da, hp", max_potion_price, 1, true, true) {
						if(!ok(rec.item, rec.command, rec.effect))
							continue;
						if(rec.score > 0) {
							if(j == 0) {
								perform[j] = rec.command;
								perform_whatif[j] = (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
							} else {
								perform[j] = perform[j-1] + "; " + rec.command;
								perform_whatif[j] = perform_whatif[j-1] + "; " + (!(contains_text(rec.command, "equip") || contains_text(rec.command, "familiar")) ? "up " + to_string(rec.effect) : rec.command);
							}

							j += 1;
						}
					}
					cli_execute("whatif quiet");
					for i from 0 to j-1 {
						cli_execute("whatif " + perform_whatif[i] + "; quiet");
						damage = ceil( hp * (1 - min(90.0, (square_root(numeric_modifier("_spec", "Damage Absorption") * 10) - 10))/100));
						if(damage < numeric_modifier("_spec", "Buffed HP Maximum")) {
							cli_execute(perform[i]);
							break;
						} else if(i == j-1)
							cli_execute(perform[i]);
						cli_execute("whatif quiet");
					}
				}
				cli_execute("whatif quiet");
				if(damage < my_maxhp())
					maximize_wrap("hp", ceil(damage), my_maxhp());
			}
			
			if (my_maxhp() > damage)
			{	
				restore_hp(damage + 30);
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
			if (break_on_combat) {
				vprint("autoBasement_break_on_combat is true, quitting", "red", 2);
				break;
			}

			int goal = ceil((level ** 1.4) * 1.08);

			if(outfits_cached) {
				strip_familiar("Damage");
				switch_hand("Damage");
				equip_cached_outfit("Damage");
				increase_stat(goal, combat_stat);
			} else {
				string command = combat_stat.to_string();
				foreach i in combat_equipment
				{
					item equipment = combat_equipment[i].to_item();
					if (equipment != $item[none] && available_amount(equipment) > 0 && can_equip(equipment))
					{
						command = command + ", +equip " + equipment.to_string();
					}
				}
				increase_stat(goal, command, combat_stat);
			}
			
			command = "";
			foreach sl in $slots[] {
				command = command + ", -" + to_string(sl);
				if(sl == $slot[familiar])
					break;
			}
			wait(20);
			goal = 2*ceil(level ** 1.4);
			float damage = max(1.0,max(0.0,max(goal,0.0) - my_defstat()) + 0.225*max(goal,0.0) - numeric_modifier("Damage Reduction")) * (1 - minmax((square_root(numeric_modifier("Damage Absorption")/10) - 1)/10,0,0.9));
			increase_stat(damage * 1.1, "hp" + command, combat_stat);
			print("Estimated damage: " + damage);
			print("Estimated monster attack: " + goal);
			
			if(to_familiar(vars["is_100_run"]) == $familiar[none]) {
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
	set_property("autoBuyPriceLimit", autoBuyLimit);

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
		vprint("Basement sucessfully automated for " + (total_num_turns - num_turns).to_string() + " out of " + total_num_turns.to_string() + " adventures. If the script failed due to being unable to buff you high enough you can either try to level up some or raise \"autoBasement_max_potion_price\" to a higher value.", "red", 1);
	}
}

void main(int num_turns)
{
	basement(num_turns);
}