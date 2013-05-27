//##############################################################################
//                               SmashLib.ash
//                              by aqualectrix
//
// Expected results of smashing.
//##############################################################################
// Requires ZLib
//##############################################################################
// Smash elements and pseudo-elements are represented by strings: 
// 	twinkly, cold, hot, sleaze, stench, useless, epic, sea salt, ultimate,
//  sugar, depleted Grimacite, Crovacite
//
// Smash tiers are represented by strings: 
//  1P, 2P, 3P, 1N, 2N, 3N, 1W, 2W, 3W, exception
//
// Smash yields are items:
//  twinkly powder, twinkly nugget, twinkly wad
//  hot/cold/sleaze/spooky/stench powder, nugget, wad, jewel (via to_jewel())
//  useless powder, epic wad, ultimate wad, sea salt crystal, 
//  chunk of depleted Grimacite, sugar shard, wad of Crovacite
//##############################################################################

script "SmashLib.ash"

import <zlib.ash>

check_version("SmashLib", "smashlib", "1.2", 3065);

// Functions for scriptwriters:
boolean is_smashable(item it);
boolean is_malusable(item it);
boolean smash(int quantity, item it);
item to_jewel(element el);
float [string] get_smash_element(item it);
string get_smash_tier(item it);
float [item] get_smash_yield(item it);
float [string] get_wad_yield(item it, boolean malus);
float [string] get_wad_yield(int [item] its, boolean malus);
void print_smash_report(item it);
void print_smash_report(string it_str);

// Handy alias:
// alias sr => ash import <SmashLib.ash> print_smash_report($item[%%])


// Load exceptional cases from pulverize.txt
string [item] pulverize_exceptions;
if (!file_to_map("pulverize.txt", pulverize_exceptions))
{ vprint("Failed to load pulverize.txt", 0); }

// Load equipment information from equipment.txt
record file_equip_data
{
	int power;
	string complete_requirement;
	string type;
};
file_equip_data [item] equipment;
if (!file_to_map("equipment.txt",equipment))
{ vprint("Failed to load equipment.txt", 0); }
// turn string requirement into int requirement with no requirement type
/*
record equip_data
{
	int power;
	int requirement;
};
equip_data [item] equipment;
int index = -1;
foreach e in file_equipment
{
	equip_data tmp;
	tmp.power=file_equipment[e].power;
	
	index = index_of(file_equipment[e].complete_requirement, ":");
	if (index > 0)
		tmp.requirement = to_int(substring(file_equipment[e].complete_requirement, 5));
	else
		tmp.requirement = 0;
	equipment[e]=tmp;
}
*/

// is_smashable(item) : Returns true if item smashes, false otherwise
// Note: Returns false for malusable items (powders, nuggets, etc.)
boolean is_smashable(item it)
{
	if (pulverize_exceptions contains it)
	{
		if (pulverize_exceptions[it] == "nosmash" || pulverize_exceptions[it] == "upgrade")
			return false;
		return true;
	}
			
	if ($slots[hat, weapon, off-hand, shirt, pants, acc1, acc2, acc3] contains to_slot(it))
		return true;
		
	return false;
}

// is_malusable(item) : Returns true if item can be malus'd to a higher form
// (Includes floaties)
boolean is_malusable(item it)
{
	return (pulverize_exceptions[it] == "upgrade");
}

// smash(int, item) : Smashes the given quantity of items.  
// Returns false if item is unsmashable or the smash cannot be performed.
// Negative quanities (-x) smash all-but-x, as per Mafia norm.
boolean smash(int quantity, item it)
{
	if (!is_smashable(it)) { return false; }
	
	return(cli_execute("smash " + quantity + " " + it));
}

// to_jewel(string) : Given an element (a real one), 
// returns the jewel of that element (as an item).
// If the element is not a real one, returns $item[none]
item to_jewel(element el)
{
	switch (el)
	{
		case $element[cold]:
			return $item[glacial sapphire];
		case $element[hot]:
			return $item[steamy ruby];
		case $element[sleaze]:
			return $item[tawdry amethyst];
		case $element[spooky]:
			return $item[unearthly onyx];
		case $element[stench]:
			return $item[effluvious emerald];
		default:
			return $item[none];
	}
	return $item[none];  // never gets here, but to please the parser...
}

// get_smash_element(item) : Returns a map of floats, keyed by strings.  
// "key" is an element type; value is the fraction of results of that type
// If an element is not a possible result, it is not in the returned map.
// If an item is unsmashable, return an empty map.
// Possible elements are:
//   twinkly, cold, hot, sleaze, stench, useless, epic, 
//   sea salt, ultimate, sugar, depleted Grimacite, and Crovacite
float [string] get_smash_element(item it)
{
	float [string] result;

	if (!is_smashable(it))
		return result;
		
	if (is_npc_item(it))
	{	
		result["useless"] = 1.0;
		return result;
	}
		
		
	// handle exceptional cases
	if (pulverize_exceptions contains it)
	{
		switch(pulverize_exceptions[it])
		{
			// note that upgradeables and nosmashes fail is_smashable()
			case "useless powder":
				result["useless"] = 1.0;
				break;
			case "epic wad":
				result["epic"] = 1.0;
				break;
			case "sea salt crystal":
				result["sea salt"] = 1.0;
				break;
			case "ultimate wad":
				result["ultimate"] = 1.0;
				break;
			case "sugar shard":
				result["sugar"] = 1.0;
				break;
			case "chunk of depleted Grimacite":
				result["depleted Grimacite"] = 1.0;
				break;
			case "wad of Crovacite":
				result["Crovacite"] = 1.0;
				break;
		}
		
		return result;
	}
	
	// handle normal cases
	result["twinkly"] = 1.0;
	
	// check damage
	if (numeric_modifier(it, "cold damage") > 0 || numeric_modifier(it, "cold spell damage") > 0)
		result["cold"] = 1.0;
	if (numeric_modifier(it, "hot damage") > 0 || numeric_modifier(it, "hot spell damage") > 0)
		result["hot"] = 1.0;
	if (numeric_modifier(it, "sleaze damage") > 0 || numeric_modifier(it, "sleaze spell damage") > 0)
		result["sleaze"] = 1.0;
	if (numeric_modifier(it, "spooky damage") > 0 || numeric_modifier(it, "spooky spell damage") > 0)
		result["spooky"] = 1.0;
	if (numeric_modifier(it, "stench damage") > 0 || numeric_modifier(it, "stench spell damage") > 0)
		result["stench"] = 1.0;
	
	// check resistance
	if (numeric_modifier(it, "cold resistance") > 0)
	{
		result["hot"] = 1.0;
		result["spooky"] = 1.0;
	}
	if (numeric_modifier(it, "hot resistance") > 0)
	{
		result["sleaze"] = 1.0;
		result["stench"] = 1.0;
	}
	if (numeric_modifier(it, "sleaze resistance") > 0)
	{
		result["cold"] = 1.0;
		result["spooky"] = 1.0;
	}
	if (numeric_modifier(it, "spooky resistance") > 0)
	{
		result["hot"] = 1.0;
		result["stench"] = 1.0;
	}
	if (numeric_modifier(it, "stench resistance") > 0)
	{
		result["cold"] = 1.0;
		result["sleaze"] = 1.0;
	}
	
	// fractionize
	float num_types = 0;
	foreach piece in result
	{ num_types = num_types + result[piece]; }  // count 'em up
	foreach piece in result
	{ result[piece] = result[piece] / num_types; }
	
	return result;
}

// get_smash_tier(item) : Returns a string representing the smash tier
// Possible strings are:
//		1P, 2P, 3P, 1N, 2N, 3N, 1W, 2W, 3W, exception
// If the item is unsmashable, returns an empty string.
// If "exception" is returned, check pulverize_exceptions instead.
string get_smash_tier(item it)
{
	if (!is_smashable(it))
		return "";
		
	if (is_npc_item(it))
		return "exception";
		
	if (pulverize_exceptions contains it)
		return "exception";
		
	int power = equipment[it].power;
	int requirement;
	int index = index_of(equipment[it].complete_requirement, ":");
	if (index > 0)
		requirement = to_int(substring(equipment[it].complete_requirement, 5));
	else
		requirement = 0;
		
	if (power > 0)  // if it has a power...
	{
		if (power <= 35)  return "1P";  // 1 powder
		if (power <= 55)  return "2P";  // 2 powders
		if (power <= 75)  return "3P";  // 3 powders
		if (power <= 95)  return "1N";  // 1 nugget or 4 powders
		if (power <= 115) return "2N";  // 2 nuggets or 3 powders + 1 nugget
		if (power <= 135) return "3N";  // 3 nuggets
		if (power <= 155) return "1W";  // 1 wad or 4 nuggets
		if (power <= 175) return "2W";  // 2 wads or 3 nuggets + 1 wad
		if (power >=  180) return "3W";  // 3 wads
	}
	else // use equip requirement as a proxy
	{
		if (requirement <= 2)  return "1P";
		if (requirement <= 13) return "2P";
		if (requirement <= 23) return "3P";
		if (requirement <= 33) return "1N";
		if (requirement <= 43) return "2N";
		if (requirement <= 53) return "3N";
		if (requirement <= 63) return "1W";
		if (requirement <= 73) return "2W";
		if (requirement >= 75)  return "3W";
	}
	
	
	return "";
}

// get_smash_yield(item) : Returns a map of floats, keyed by strings
// "key" is a possible yield; value is the expected amount of that yield
// If a yield is not possible, it is not included in the map.
// If the item is unsmashable, returns an empty map.
// Possible keys are:
// 		twinkly powder, twinkly nugget, twinkly wad
//    hot/cold/sleaze/spooky/stench powder, nugget, wad, jewel
//    useless powder
//    epic wad
//    ultimate wad
//    sea salt crystal
//    chunk of depleted Grimacite
//    sugar shard
//    wad of Crovacite
float [item] get_smash_yield(item it)
{
	float [item] result;
	
	if (!is_smashable(it))
		return result;
		
	string tier = get_smash_tier(it);
	float [string] element_type = get_smash_element(it);
	
	switch(tier)
	{
		case "1P":  // One powder
			foreach piece in element_type
			{ result[to_item(piece + " powder")] = element_type[piece]; }
			break;
		case "2P":  // Two powders
			foreach piece in element_type
			{ result[to_item(piece + " powder")] = 2 * element_type[piece]; }
			break;
		case "3P":  // Three powders	
			foreach piece in element_type
			{ result[to_item(piece + " powder")] = 3 * element_type[piece]; }
			break;
		case "1N":  // One nugget or four powders, 50% chance			
			foreach piece in element_type
			{
				result[to_item(piece + " nugget")] = .5 * element_type[piece];
				result[to_item(piece + " powder")] =  2 * element_type[piece];
			}
			break;
		case "2N":  // One nugget + 3 powders or 2 nuggets, 50% chance			
			foreach piece in element_type
			{
				result[to_item(piece + " nugget")] = 1.5 * element_type[piece];
				result[to_item(piece + " powder")] = 1.5 * element_type[piece];
			}
			break;
		case "3N":  // Three nuggets		
			foreach piece in element_type
			{ result[to_item(piece + " nugget")] = 3 * element_type[piece]; }
			break;
		case "1W":  // One jewel or one wad or four nuggets, .5% / 49.5% / 50% chance
			foreach piece in element_type
			{	
				if (piece == "twinkly") // no twinkly jewels
				{ result[to_item(piece + " wad")] = .5 * element_type[piece]; }
				else
				{
					result[to_jewel(to_element(piece))] = .005 * element_type[piece];
					result[to_item(piece + " wad")] =   .495 * element_type[piece];
				}
				result[to_item(piece + " nugget")] = 2 * element_type[piece];
			}
			break;
		case "2W":  // Two jewels or one jewel + one wad or two wads or one jewel + three nuggets or one wad + three nuggets, .05% / .5% / 49.45% / .5% / 49.5%
			foreach piece in element_type
			{
				if (piece == "twinkly") // no twinkly jewels
				{ result[to_item(piece + " wad")] = 1.5 * element_type[piece]; }
				else
				{
					result[to_jewel(to_element(piece))] = .011 * element_type[piece];
					result[to_item(piece + " wad")] = 1.489 * element_type[piece];
				}
				result[to_item(piece + " nugget")] = 1.5 * element_type[piece];
			}
			break;
		case "3W":  // Three jewels or two jewels + one wad or one jewel + two wads or three wads, .01% / .1% / 1% / 98.89%	
			foreach piece in element_type
			{
				if (piece == "twinkly") // no twinkly jewels
				{ result[to_item(piece + " wad")] = 3.0 * element_type[piece]; }
				else
				{
					result[to_jewel(to_element(piece))] = .0123 * element_type[piece];
					result[to_item(piece + " wad")] = 2.9877 * element_type[piece];
				}
			}
			break;
		case "exception":
			if (element_type contains "useless")
				result[to_item("useless powder")] = 1.0;
			if (element_type contains "epic")
				result[to_item("epic wad")] = 1.0;
			if (element_type contains "ultimate")
				result[to_item("ultimate wad")] = 1.0;
			if (element_type contains "sea salt")
				result[to_item("sea salt crystal")] = 1.0;
			if (element_type contains "depleted Grimacite")
				result[to_item("chunk of depleted Grimacite")] = 1.0;
			if (element_type contains "sugar")
				result[to_item("sugar shard")] = 1.0;
			if (element_type contains "Crovacite")
				result[to_item("wad of Crovacite")] = 1.0;
				
			break;
	}
		
	return result;
}

// get_wad_yield(item, boolean) : Returns a map of floats keyed by strings
// "key" is an element; value is the expected number of wads of that element
// If malus is true, also includes wads created by malusing powders and nuggets
// Wad yield does not include jewel yield.
// If item is unsmashable, returns empty map.
// If item is smashable, but yields no wads, returns an empty map.  
// (If malus is true, and it smashes to an acceptable element, 
//  map will not be empty.)
// Keys may be:
//		twinkly, cold, hot, sleaze, spooky, stench
float [string] get_wad_yield(item it, boolean malus)
{
	float [string] result;
	
	if (!is_smashable(it))
		return result;
		
	float [item] smash_yield = get_smash_yield(it);
	float [string] smash_elements = get_smash_element(it);
	
	// Are we dealing with allowed elements?
	if (smash_elements contains "twinkly")  // all normal smashes have twinkly
	{	
		// How many wads just from smashing?
		foreach piece in smash_elements
		{ result[piece] = smash_yield[to_item(piece + " wad")]; }
		
		// Should we malus?
		if (!malus)
			return result;
		
		// Include Malusing
		foreach piece in smash_elements
		{
			result[piece] = result[piece] + .2 * smash_yield[to_item(piece + " nugget")] + .04 * smash_yield[to_item(piece + " powder")];
		}
	}
	
	return result;
}

// get_wad_yield(int [item], boolean): Returns a map of floats keyed by strings
// Works just like get_wad_yield(item, boolean), but for multiple items of 
// varied quantities: pass in a map of ints keyed by items, where the ints are 
// the number of that item to smash.
float [string] get_wad_yield(int [item] its, boolean malus)
{
	float [string] result;
	float [string] single_result;
	
	foreach it in its
	{
		single_result = get_wad_yield(it, malus);
		foreach piece in $strings["twinkly", "cold", "hot", "sleaze", "spooky", "stench"]
		{ result[piece] = result[piece] + (its[it] * single_result[piece]); }
	}
	
	return result;
}

// print_smash_report(item) : Prints item, tier, elements, and expected yield
void print_smash_report(item it)
{
	print_html("<b>" + it + "</b>");
	
	print("Tier: " + get_smash_tier(it));
	
	float [string] elements = get_smash_element(it);
	print("Elements:");
	foreach piece in elements
	{ print("&nbsp;" + piece + ": " + elements[piece]); }
	
	float [item] yield = get_smash_yield(it);
	print("Expected Yields:");
	foreach type in yield
	{ print("&nbsp;" + type + ": " + yield[type]); }	
}

// print_smash_report(string) : Prints item, tier, elements, and expected yield
void print_smash_report(string it_str)
{
	print_smash_report(to_item(it_str));
}