//##############################################################################
//                             PriceAdvisor
//                            by aqualectrix
//
// What should you do with your loot?
//##############################################################################
// Requires SmashLib, ZLib
//##############################################################################
// Scripts using PriceAdvisor extensively are encouraged to add the lines
//
// cli_execute("update prices http://zachbardon.com/mafiatools/updateprices.php?action=getmap");
//cli_execute("update prices http://nixietube.info/mallprices.txt");
//
// at the beginning of said script to use shared price data, and the line
// 
// cli_execute("spade prices http://zachbardon.com/mafiatools/updateprices.php");
// 
// at the end to share gathered price data.
//##############################################################################

script "PriceAdvisor.ash"

import <SmashLib.ash>
import <sims_lib.ash>;

check_version("PriceAdvisor", "priceadvisor", "1.62", 3110);

// Should PA only advise acquiring things below your autoBuyPriceLimit?
setvar("priceAdvisor_obeyPriceLimit", false);
// Should PA only advise acquiring things that are npc_item or at mallmin?
setvar("priceAdvisor_conservative", false);
// Should PA only output things that are CLI-executable?
setvar("priceAdvisor_CLIexecutable", false);

// Advice
record price_advice
{
	string action; // instructions on what to do to get price
	float price;   // net meat gain from doing action
};

// Functions for scriptwriters:
price_advice best_advice(item it, boolean consider_more);
price_advice [item] best_advice(boolean [item] its, boolean consider_more);
price_advice [int] price_advisor(item it, boolean consider_more);
price_advice [item] [int] price_advisor(boolean [item] its, boolean consider_more);
void print(price_advice advice);
void print(price_advice [int] advice);
price_advice max(price_advice a, price_advice b);

// Maps for scriptwriters:
float [item] meat_use;  // EV of meat for using an item
float [item] [item] item_use;  // items and EV of items for using an item
string [item] [item] ingredients; // map from ingredients to concoctions and coconction type

// Caching and infinite-recursion-prevention:
price_advice [item][boolean] best_cache;
boolean [item] currently_considering; // prevent circular opportunity costs & infinite recursion
void clear_advice_cache();


// Handy alias:
// alias pa => ash import <PriceAdvisor.ash> print(price_advisor($items[%%], true))


// Set up maps and variables:

float adv_val = to_float(get_property("valueOfAdventure"));
float still_val = to_float(get_property("valueOfStill"));
int buy_limit = to_int(get_property("autoBuyPriceLimit"));
boolean obey_limit = to_boolean(vars["priceAdvisor_obeyPriceLimit"]);
boolean conservative = to_boolean(vars["priceAdvisor_conservative"]);
boolean executable_only = to_boolean(vars["priceAdvisor_CLIexecutable"]);

if(!load_current_map("use_for_meat", meat_use))
	vprint("Failed to load file use_for_meat.txt", 0);

if(!load_current_map("use_for_items", item_use))
	vprint("Failed to load file use_for_items.txt", 0);
	
string [item] concoctions;
if (!file_to_map("concoctions.txt", concoctions))
	vprint("Failed to load concoctions.txt", 0);
	
// Add "use" items with conditional results
boolean have_wand = false;
for i from 1268 to 1272
{ if (available_amount(to_item(i)) > 0) have_wand = true; }
if (have_wand)
{
	item_use[$item[dead mimic]][$item[bubbly potion]] = 1.389;
	item_use[$item[dead mimic]][$item[cloudy potion]] = 1.389;
	item_use[$item[dead mimic]][$item[dark potion]] = 1.389;
	item_use[$item[dead mimic]][$item[effervescent potion]] = 1.389;
	item_use[$item[dead mimic]][$item[fizzy potion]] = 1.389;
	item_use[$item[dead mimic]][$item[milky potion]] = 1.389;
	item_use[$item[dead mimic]][$item[murky potion]] = 1.389;
	item_use[$item[dead mimic]][$item[smoky potion]] = 1.389;
	item_use[$item[dead mimic]][$item[swirly potion]] = 1.389;
	item_use[$item[dead mimic]][$item[ring of adornment]] = .125;
	item_use[$item[dead mimic]][$item[ring of aggravate monster]] = .125;
	item_use[$item[dead mimic]][$item[ring of cold resistance]] = .125;
	item_use[$item[dead mimic]][$item[ring of conflict]] = .125;
	item_use[$item[dead mimic]][$item[ring of fire resistance]] = .125;
	item_use[$item[dead mimic]][$item[ring of gain strength]] = .125;
	item_use[$item[dead mimic]][$item[ring of increase damage]] = .125;
	item_use[$item[dead mimic]][$item[ring of teleportation]] = .125;  // wiki speculates that this doesn't drop, or drops at a severely reduced rate
}
else // not the real condition, alas, but I've no way to check 3 days
{
	item_use[$item[dead mimic]][$item[aluminum wand]] = .2;
	item_use[$item[dead mimic]][$item[ebony wand]] = .2;
	item_use[$item[dead mimic]][$item[hexagonal wand]] = .2;
	item_use[$item[dead mimic]][$item[marble wand]] = .2;
	item_use[$item[dead mimic]][$item[pine wand]] = .2;
}

int hippy = to_int(get_property("sidequestFarmCompleted") == "hippy");
item_use[$item[Hippy Army MPE]][$item[handful of walnuts]] = .7 - .2 * hippy;
item_use[$item[Hippy Army MPE]][$item[mixed wildflower greens]] = .7 - .2 * hippy;
item_use[$item[Hippy Army MPE]][$item[cruelty-free wine]] = .533 - .2 * hippy;
item_use[$item[Hippy Army MPE]][$item[Genalen&trade; Bottle]] = .533 - .2 * hippy;
item_use[$item[Hippy Army MPE]][$item[thistle wine]] = .533 - .2 * hippy;
if (to_boolean(hippy))
	item_use[$item[Hippy Army MPE]][$item[megatofu]] = 1;
	
int frat = to_int(get_property("sidequestFarmCompleted") == "fratboys");
item_use[$item[Frat Army FGF]][$item[brain-meltingly-hot chicken wings]] = .533 - .2 * frat;
item_use[$item[Frat Army FGF]][$item[knob ka-bobs]] = .533 - .2 * frat;
item_use[$item[Frat Army FGF]][$item[frat brats]] = .533 - .2 * frat;
item_use[$item[Frat Army FGF]][$item[can of Swiller]] = .7 - .2 * frat;
item_use[$item[Frat Army FGF]][$item[melted Jell-o shot]] = .7 - .2 * frat;
if (to_boolean(frat))
	item_use[$item[Frat Army FGF]][$item[McMillicancuddy's Special Lager]] = frat;
	
// Add funny concoctions that don't load properly
concoctions[$item[bottle of gin]] = "MIX";
concoctions[$item[bottle of rum]] = "MIX";
concoctions[$item[bottle of sake]] = "MIX";
concoctions[$item[bottle of tequila]] = "MIX";
concoctions[$item[bottle of whiskey]] = "MIX";
concoctions[$item[bottle of vodka]] = "MIX";
concoctions[$item[boxed wine]] = "MIX";

// A backwards mapping from ingredient to concoction,
// taking into account your skills.
// get_ingredients() provides the concoction to ingredient map
string c_type;
string item_name;
string base_item_name;
/*
foreach concoct in concoctions
{
*/
foreach it in $items[]
{
	if(concoctions contains it)
	{

		c_type = concoctions[it];
		
		// strip extra conditions used by Mafia -- 
		// taken into account by get_ingredients(), so I don't need 'em
		c_type = replace_string(c_type, "TORSO", "");
		c_type = replace_string(c_type, "FEMALE", "");
		c_type = replace_string(c_type, "MALE", "");
		c_type = replace_string(c_type, "HAMMER", "");
		c_type = replace_string(c_type, "WEAPON", "");
		c_type = replace_string(c_type, "SSPD", "");
		c_type = replace_string(c_type, "GRIMACITE", "");
		
		// remove any remaining trailing ", "
		while (last_index_of(c_type, ", ") == length(c_type) - 2)
		{ c_type = substring(c_type, 0, length(c_type) - 2); }
		
		
		// Note that without the relevant skill, and other requirements,
		// get_ingredients() returns an empty list
		foreach ingred in get_ingredients(it)
		{ ingredients[ingred][it] = c_type; }
		
		// wadbot makes malus requirements non-required
		if (c_type == "MALUS" && count(get_ingredients(it)) == 0)
		{
			item_name = to_string(it);
			base_item_name = substring(item_name, 0, index_of(item_name, " "));
			
			if (contains_text(item_name, "nuggets"))
				ingredients[to_item(base_item_name + " powder")][it] = c_type;
			else if (contains_text(item_name, "wad"))
				ingredients[to_item(base_item_name + " nuggets")][it] = c_type;
			else if (contains_text(item_name, "pebbles"))
				ingredients[to_item(base_item_name + " sand")][it] = c_type;
			else if (contains_text(item_name, "gravel"))
				ingredients[to_item(base_item_name + " pebbles")][it] = c_type;
			else if (contains_text(item_name, "rock"))
				ingredients[to_item(base_item_name + " gravel")][it] = c_type;
		}
	}
}


// Functions

// print(price_advice) : Prints an action and net meat return
void print(price_advice advice)
{
	if (advice.price >= 0)
	{ vprint(advice.action + ": " + advice.price + " meat", 1); }
	else
	{ vprint(advice.action + ": " + advice.price + " meat", 4); }
}

// print(price_advice [int]) : Prints a list of actions and their net meat
void print(price_advice [int] advice)
{
	foreach rank in advice
	{ print(advice[rank]); }
}

// print(price_advice [item]) : Prints a list of items and their best advice
void print(price_advice [item] advice)
{
	foreach it in advice
	{
		print_html("<b>" + it + ":</b>");
		print(advice[it]);
		vprint("", 1);
	}
}

// print(price_advice [item] [int]) : Prints a list of items and their advice
void print(price_advice [item] [int] advice)
{
	foreach it in advice
	{
		print_html("<b>" + it + ":</b>");
		print(advice[it]);
		vprint("", 1);
	}
}

// clear_advice_cache() : Clears best_cache map
// Useful if you've got a bunch of new prices and want to re-evaluate
void clear_advice_cache()
{
	clear(best_cache);
}

// max(price_advice, price_advice) : Returns a copy of the price_advice 
// with higher price.  Returns a copy of the first parameter if prices are tied.
price_advice max(price_advice a, price_advice b)
{
	price_advice better;
	
	if (b.price > a.price)
	{ better = new price_advice(b.action, b.price); }
	else
	{ better = new price_advice(a.action, a.price); }

	return better;
}

// has_circular_end_product(item, string) : returns true if any of the "sell" 
// actions sells the initial item it.  Prevents such ridiculous advice as 
// "use ten-leaf clover; use disassembled clover; mallsell ten-leaf clover".
boolean has_circular_end_product(string action)
{
	string remaining_action = action;
	int sell_index = last_index_of(remaining_action, "sell ");
	item end_product;
	
	while (sell_index > 0)
	{
		end_product = to_item(substring(remaining_action, sell_index + 5));

		if (currently_considering contains end_product)
			return true;

		if (sell_index - 6 < 0)
			break;
		remaining_action = substring(remaining_action, 0, sell_index - 6);
		sell_index = last_index_of(remaining_action, "sell ");
	}
	
	return false;
}

// replace_with_multiple(string, int) : Returns a copy of str
// with all integers replaced with integer * multiplier
// Negative integers are not replaced -- this is deliberate,
// as Mafia interprets -x as "all but x".
string replace_with_multiple(string str, int multiplier)
{
	matcher integer = create_matcher("(?<!\\S)([\\d]+)(?!\\S)", str);
	string replaced = str;
	int multiplicand = 0;
	
	while(find(integer))
	{
		multiplicand = to_int(group(integer, 1));
		replaced = replace_string(replaced, group(integer, 1), to_string(multiplier * multiplicand));
	}
		
	return replaced;
}

// best_advice(item, boolean) : Returns a price_advice with the best price 
// and action to take to get that price.
// Populates and takes advantage of best_cache.
// If consider_more is true, consider more than just autosell vs. mallsell
price_advice best_advice(item it, boolean consider_more)
{
	if (best_cache contains it && best_cache[it] contains consider_more)
	{ return new price_advice(best_cache[it][consider_more].action, best_cache[it][consider_more].price);}
	
	price_advice [int] advice = price_advisor(it, consider_more);
	best_cache[it][consider_more] = advice[0];

	return new price_advice(advice[0].action, advice[0].price);
}

// best_advice(boolean [item], boolean : Returns a map of items to their
// best actions and prices.  If consider_more is true, considers more than
// just autosell and mallsell.
price_advice [item] best_advice(boolean [item] its, boolean consider_more)
{
	price_advice [item] advice;
	
	foreach it in its
	{ advice[it] = best_advice(it, consider_more); }
	
	return advice;
}

// smash_advice(item, boolean) : Returns a price_advice of the best expected
// result of smashing.
// If consider_more is true, consider more than just autosell vs. mallsell
// If item is not smashable, returns 0
price_advice smash_advice(item it, boolean consider_more)
{
	price_advice advice;
	advice.action = "smash 1 " + it;
	advice.price = 0.0;

	if (!is_smashable(it))
	{ return new price_advice("", 0.0); }
		
	float [item] smash_yield = get_smash_yield(it);
	price_advice single_advice;
	
	// Find expected value
	foreach yield in smash_yield
	{ 
		single_advice = best_advice(yield, consider_more);
		
		if (single_advice.action == "")
		{ return new price_advice("", 0.0); }
		
		advice.action = advice.action + "; " + single_advice.action;
		advice.price = advice.price + single_advice.price * smash_yield[yield];
	}
	return advice;
}

// concocted_advice(item, int, item, int [item], price_advice, float) : 
// Returns the best action and price for an item in a concoction result given 
// the ingredients, the best gain for the result, and
// the initial opportunity cost (meat paste, adventures, etc.)
// Calculates and takes into account the opportunity cost of using the other
// ingredients in the concoction.
price_advice concocted_advice(item result, int result_amount, item it, int [item] ingreds, price_advice gain, float opportunity_cost)
{
	price_advice concoct;
	int quant = 0;
	price_advice temp;
	
	// Bail on invalid gain
	if (gain.action == "")
	{ return new price_advice("", 0.0); }
	
	gain.price = gain.price * result_amount;
		
	// if you must acquire things, consider them
	if (count(ingreds) > 1 || ingreds[it] > 1)
	{
		concoct.action = "acquire ";

		foreach ing in ingreds
		{
			quant = ingreds[ing];
			
			// If this is the queried item and we only need one, skip it.
			// If we need more than one, we only need quant - 1.
			if (ing == it)
			{
				if (quant == 1) continue;
				else quant = quant - 1;
			}
			
			temp = best_advice(ing, ing != it);
			
			// If a sub-result was invalid, so is this.  Bail.
			if (temp.action == "")
			{ return new price_advice("", 0.0); }
			
			// Obey buying preferences
			if ((obey_limit && historical_price(ing) > buy_limit && available_amount(ing) < quant) 
			    ||
			    (conservative && !is_npc_item(ing) && historical_price(ing) > max(100, 2 * autosell_price(ing))))
			{ return new price_advice("", 0.0); }
			
			// If an item has opportunity cost == autosell,
			// you may still need to buy it at mallsell if you don't own it
			if (temp.price == autosell_price(ing))
			{
				// as many as you have cost autosell
				opportunity_cost = opportunity_cost + min(quant, available_amount(ing)) * temp.price;
				
				// any more cost mallsell
				opportunity_cost = opportunity_cost + max(0, quant - available_amount(ing)) * historical_price(ing);
			}
			else
			{ opportunity_cost = opportunity_cost + (quant * temp.price); }
			
			concoct.action = concoct.action + quant + " " + ing + ", ";
		}
			
		// replace the final "," of the acquire string with ";"
		int len = length(concoct.action);
		if (substring(concoct.action, len - 2, len) == ", ")
		{
			concoct.action = substring(concoct.action, 0, len - 2);
			concoct.action = concoct.action + "; ";
		}
	}
	
	concoct.price = gain.price - opportunity_cost;	

	if (result_amount == 1)
	{concoct.action = concoct.action  + "make 1 " + result + "; " + gain.action;}
	else
	{
		concoct.action = concoct.action + replace_with_multiple("make 1 " + result + "; " + gain.action, result_amount);
	}
	
	return concoct;
}

// price_advisor(item, boolean) : Returns a sorted map of price advice, 
// from best price to least.  Keys start at 0 and go to (count - 1).
// If consider_more is true, consider more than just autosell vs. mallsell
price_advice [int] price_advisor(item it, boolean consider_more)
{
	price_advice [int] advice;
	price_advice special;
	price_advice gain;
	price_advice temp;
	int [item] ingreds;
	
	int [item] campground = get_campground();

	// Autoselling -- if possible
	price_advice autosell;
	autosell.action = "autosell 1 " + it;
	autosell.price = autosell_price(it);
	if (autosell.price > 0)
		advice[count(advice)] = autosell;
		
	// Mallselling -- if not stuck at minprice
	if (is_tradeable(it))
	{
		price_advice mallsell;
		mallsell.action = "mallsell 1 " + it; 
		if (historical_age(it) > 1)
		{ mallsell.price = mall_price(it); }
		else
		{ mallsell.price = historical_price(it); }
		
		if ((autosell.price == 0 && mallsell.price > 100) || 
		    mallsell.price > max(2 * autosell.price, 100))
		
			advice[count(advice)] = mallsell;
	}
	
	// Unsellable!
	if (count(advice) == 0)  // no autosell or mallsell
	{
		if (executable_only) special.action = "";
		else special.action = it + " can't or doesn't sell";
		special.price = 0.0;
		advice[count(advice)] = new price_advice(special.action, special.price);
	}

	// Consider more options
	if (consider_more && !(currently_considering contains it))
	{
		currently_considering[it] = true;
		
		// Equipment -- smashed and sold
		if (is_smashable(it))
		{
			price_advice smash = smash_advice(it, true);
			
			if (smash.action != "")
				advice[count(advice)] = smash;
		}
		
		// Using, including using with requirements
		if (meat_use contains it || item_use contains it)
		{
			price_advice use;
			use.action = "use 1 " + it;
			use.price = meat_use[it];
			item required_item;
			boolean bad_result = false;
			
			foreach it2 in item_use[it]
			{ 
				temp = best_advice(it2, !(currently_considering contains it2));
				
				// If sub-result is invalid, result is invalid
				if (temp.action == "")
				{ 
					bad_result = true;
				  break;
				}

				if ( item_use[it][it2] < 0 ) // item is the required item
				{ 
					required_item = it2; 
					use.price = use.price + temp.price;
				}
				else
				{ 
					use.action = use.action + "; " + temp.action;
					use.price = use.price + item_use[it][it2] * temp.price;
				}
			}
			
			if (required_item != $item[none])
				use.action = "acquire 1 " + required_item + "; " + use.action;
				
			if (!has_circular_end_product(use.action) && !bad_result)
				advice[count(advice)] = use;
		}
	
		// Untinkering
		if (concoctions contains it && concoctions[it] == "COMBINE")
		{
			price_advice untinker;
			untinker.action = "untinker " + it;
			boolean bad_result = false;
			
			ingreds = get_ingredients(it);
			foreach it2 in ingreds
			{
				temp = best_advice(it2, !(currently_considering contains it2));
				
				// If sub-result is invalid, result is invalid
				if (temp.action == "")
				{
					bad_result = true;
					break;
				}
				
				if (ingreds[it2] == 1)
				{ untinker.action = untinker.action + "; " + temp.action; }
				else
				{ untinker.action = untinker.action + "; " + replace_with_multiple(temp.action, ingreds[it2]); }
				untinker.price = untinker.price + ingreds[it2] * temp.price;
			}
			
			if (!has_circular_end_product(untinker.action) && !bad_result)
				advice[count(advice)] = untinker;
		}

		// Special cases
		switch(it)
		{
			case $item[gloomy black mushroom]:  // can trade for an oily
				gain = best_advice($item[oily golden mushroom], !(currently_considering contains $item[oily golden mushroom]));
				
				if (gain.action != "")
				{
					if (executable_only) 
					{ 
						special.action = "town_wrong.php?place=goofballs&sleazy=1; " + gain.action;
					}
					else 
					{
						special.action = "trade " + it + " to the Suspicious-Looking Guy; " + gain.action;
					}
					special.price = gain.price;
					
					advice[count(advice)] = new price_advice(special.action, special.price);
				}
				break;
			case $item[cold nuggets]:  // missing recipes from reading concoctions.txt
			case $item[hot nuggets]:
			case $item[sleaze nuggets]:
			case $item[spooky nuggets]:
			case $item[stench nuggets]:
				item_name = to_string(it);
				base_item_name = substring(item_name, 0, index_of(item_name, " "));
				gain = best_advice(to_item(base_item_name + " wad"), !(currently_considering contains to_item(base_item_name + " wad")));
				
				ingreds[it] = 5;
				special = concocted_advice(to_item(base_item_name + " wad"), 1, it, ingreds, gain, 0);
				
				if (special.action != "")
					advice[count(advice)] = new price_advice(special.action, special.price);
				break;
		}
		
		// Concoctions -- don't advise on NPC buyables
		if (ingredients contains it && !is_npc_item(it))
		{
			price_advice [string] concoct_types;

			float opportunity_cost = 0.0;
			
			foreach concoct in ingredients[it]
			{ 
				// prevent bizzare circular opportunity costs
				if(currently_considering contains concoct) continue;
 
 				ingreds = get_ingredients(concoct);
				gain = best_advice(concoct, true);
				opportunity_cost = 0.0;
				temp.action = "";
				temp.price = 0.0;
				
				currently_considering[concoct] = true;
				
				// consider
				switch (ingredients[it][concoct])
				{
					case "SUSE":
						if (item_use contains it) // prevent duplicate advice
							break;
							
						temp = concocted_advice(concoct, 1, it, ingreds, gain, 0);						
						break;
					case "MUSE":    // Multi-use
					case "STAR":    // Starchart
					case "PIXEL":   // Pixelcrafting
					case "SUGAR":   // Sugar sheet
					case "TINKER":  // Supertinkering
						temp = concocted_advice(concoct, 1, it, ingreds, gain, 0);
						break;
					case "MALUS":  
						if (count(ingreds) == 0)  // if malus not available, ingreds is empty
						{
							item_name = to_string(concoct);
							base_item_name = substring(item_name, 0, index_of(item_name, " "));
							
							if (contains_text(item_name, "nuggets"))
								ingreds[to_item(base_item_name + " powder")] = 5;
							else if (contains_text(item_name, "wad"))
								ingreds[to_item(base_item_name + " nuggets")] = 5;
							else if (contains_text(item_name, "pebbles"))
								ingreds[to_item(base_item_name + " sand")] = 5;
							else if (contains_text(item_name, "gravel"))
								ingreds[to_item(base_item_name + " pebbles")] = 5;
							else if (contains_text(item_name, "rock"))
								ingreds[to_item(base_item_name + " gravel")] = 5;
						}

						temp = concocted_advice(concoct, 1, it, ingreds, gain, 0);
						break;
					case "COMBINE":
						if (!in_muscle_sign()) opportunity_cost = 10;  // Plunger

						temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);
						break;
					case "COOK":
					case "PASTA":
					case "TEMPURA":
					case "SAUCE":
					case "SAUCE, SX3":
					case "SSAUCE":
					case "SSAUCE, SX3":
					case "DSAUCE":
						if (!simons_have_chef()) opportunity_cost = adv_val;  // chef-in-a-box
						else if (campground[$item[clockwork chef-in-the-box]] > 0)
						{ opportunity_cost = best_advice($item[clockwork chef-in-the-box], false).price / 360; }
						else
						{ opportunity_cost = best_advice($item[chef-in-the-box], false).price / 90.0; }
					
						if ((ingredients[it][concoct] == "SAUCE, SX3" || ingredients[it][concoct] == "SSAUCE, SX3") && my_class() == $class[sauceror])
						{
							temp = concocted_advice(concoct, 3, it, ingreds, gain, opportunity_cost);
						}
						else
						{
							temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);						
						}
						
						break;
					case "WOK":
						opportunity_cost = adv_val;
					
						temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);
						break;
					case "MIX":
						if (!simons_have_bartender()) opportunity_cost = adv_val;  // bartender
						else opportunity_cost = best_advice($item[bartender-in-the-box], false).price / 90.0;
						
						if ($items[bottle of gin, bottle of rum, bottle of sake, bottle of tequila, bottle of whiskey, bottle of vodka, boxed wine] contains concoct)
						{	
							temp = concocted_advice(concoct, 3, it, ingreds, gain, opportunity_cost);
						}
						else
						{
							temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);	
						}
						
						break;
					case "ACOCK":
					case "SCOCK":
					case "SACOCK":
						if (!simons_have_bartender()) opportunity_cost = adv_val;
						else if (campground[$item[clockwork bartender-in-the-box]] > 0)
						{ opportunity_cost = best_advice($item[clockwork bartender-in-the-box], false).price / 360; }
						else 
						{ opportunity_cost = best_advice($item[bartender-in-the-box], false).price / 90.0; }
						
						temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);
						break;
					case "BSTILL":
					case "MSTILL":
						opportunity_cost = still_val;
						
						temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);
						break;
					case "SMITH":
					case "WSMITH":
					case "ASMITH":
						if (!in_muscle_sign() || ingredients[it][concoct] != "SMITH")
							opportunity_cost = adv_val;

						temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);
						break;
					case "JEWEL":
					case "EJEWEL":
						opportunity_cost = 3 * adv_val;  // Yikes!
						
						temp = concocted_advice(concoct, 1, it, ingreds, gain, opportunity_cost);
						break;
				}
				
				if (temp.action != "")
					advice[count(advice)] = new price_advice(temp.action, temp.price);	
					
				remove currently_considering[concoct];
			}
		}
		remove currently_considering[it];
	}

	sort advice by -(value.price);
	return advice;
}

// price_advisor(boolean [item], boolean) : Returns a map from items
// to ranked lists of price advice.  If consider_more is true, considers more
// than just autosell and mallsell.
price_advice [item] [int] price_advisor(boolean [item] its, boolean consider_more)
{
	price_advice [item] [int] advice;
	
	foreach it in its
	{
		advice[it] = price_advisor(it, consider_more);
	}
	
	return advice;
}