/*	Original script written by Zekaonar
*	Updated by Crowther
*	Rewritten by UberFerret		
*	Maintained by digitrev	*/
script "UberPvPOptimizer.ash";
notify digitrev;
import <zlib.ash>;

//Declare all the variables
boolean showAllItems;
boolean buyGear;
int maxBuyPrice;
int topItems;
boolean limitExpensiveDisplay;
int defineExpensive;

float letterMomentWeight;
float nextLetterWeight;
float itemDropWeight;
float meatDropWeight;
float boozeDropWeight;
float initiativeWeight;
float combatWeight;
float resistanceWeight;
float powerWeight;
float damageWeight;
float negativeClassWeight;
float weaponDmgWeight;
float nakedWeight;
float hexLetterWeight;
float numeralWeight;

// Booleans for each pvp mini
boolean laconic = false;
boolean verbosity = false;
boolean egghunt = false;
boolean meatlover = false;
boolean weaponDamage = false;
boolean moarbooze = false;
boolean showingInitiative = false;
boolean peaceonearth = false;
boolean broadResistance = false;
boolean coldResistance = false;
boolean hotResistance = false;
boolean sleazeResistance = false;
boolean stenchResistance = false;
boolean spookyResistance = false;
boolean lightestLoad = false;
boolean letterCheck = false;
boolean coldDamage = false;
boolean hotDamage = false;
boolean sleazeDamage = false;
boolean stenchDamage = false;
boolean spookyDamage = false;
boolean leastGear = false;
boolean deface = false;
boolean nines = false;

//other variables
string currentLetter;
string nextLetter;
boolean dualWield = false;
item primaryWeapon;			//mainhand
item secondaryWeapon;		//offhand
item tertiaryWeapon;		//hand
item bestOffhand;
item [string] [int] gear;
familiar[int] fams;


void loadPvPProperties()
{
//Set properties
	setvar("PvP_showAllItems", true);			// When 0.0, only shows items you own or within mall budget
	setvar("PvP_buyGear", false);				// Will auto-buy from mall if below threshold price and better than what you have
	setvar("PvP_maxBuyPrice", 1000);						// Max price that will be considered to auto buy gear if you don't have it
	setvar("PvP_topItems", 10);							// Number of items to display in the output lists
	setvar("PvP_limitExpensiveDisplay", false);// Set to false to prevent the item outputs from showing items worth [defineExpensive] or more
	setvar("PvP_defineExpensive", 10000000);				// define amount for value limiter to show 10,000,000 default
//Item Weights
	setvar("PvP_letterMomentWeight", 6.0);				// Example: An "S" is worth 3 letters in laconic/verbosity
	setvar("PvP_hexLetterWeight", 4.0);					// Example: An "E" is worth 2 letters in laconic/verbosity
	setvar("PvP_numeralWeight", 4.0);
	setvar("PvP_nextLetterWeight", 0.1);					// Example: allow a future letter to be a tie-breaker
	setvar("PvP_itemDropWeight", (4.0/5.0));				// 4 per 5% drop Example: +8% items is worth 10 letters in laconic/verbosity
	setvar("PvP_meatDropWeight", (3.0/5.0));				// 3 per 5% drop Example: +25% meat is worth 15 letters in laconic/verbosity
	setvar("PvP_boozeDropWeight", (3.0/5.0));				// 3 per 5% drop Example: +20% booze is worth 12 letters in laconic/verbosity
	setvar("PvP_initiativeWeight", (4.0/10.0));			// 4 per 10% initiative Example: +20% initiative is worth 8 letters in laconic/verbosity
	setvar("PvP_combatWeight", (15.0/5.0));				// 4 per 10% combat Example: +20% combat is worth 8 letters in laconic/verbosity
	setvar("PvP_resistanceWeight", 4.9);					// Example: +1 Resistance to all elements equals 6 letters of laconic/verbosity
	setvar("PvP_powerWeight", (5.0/10.0));				// Example: 5 points for -10 points of power towards Lightest Load vs average(110) power in slot.  
	setvar("PvP_damageWeight", 4.0/10.0);					// Example: 4 points for 10 points of damage.
	setvar("PvP_negativeClassWeight", -5);				// Give a negative weight to items that are not for your class.
	setvar("PvP_weaponDmgWeight", (0.5));					// messing with this
	setvar("PvP_nakedWeight", (7.4));						//WORK IN PROGRESS

	/***Load settings ***/
	
	showAllItems = vars["PvP_showAllItems"].to_boolean();			// When false, only shows items you own or within mall budget
	buyGear = vars["PvP_buyGear"].to_boolean();					// Will auto-buy from mall if below threshold price and better than what you have
	maxBuyPrice = vars["PvP_maxBuyPrice"].to_int();					// Max price that will be considered to auto buy gear if you don't have it
	topItems = vars["PvP_topItems"].to_int();						// Number of items to display in the output lists
	limitExpensiveDisplay = vars["PvP_limitExpensiveDisplay"].to_boolean();	// Set to false to prevent the item outputs from showing items worth [defineExpensive] or more
	defineExpensive = vars["PvP_defineExpensive"].to_int();					// define amount for value limiter to show 10,000,000 default

	letterMomentWeight = vars["PvP_letterMomentWeight"].to_float();			// Example: An "S" is worth 3 letters in laconic/verbosity
	hexLetterWeight = vars["PvP_hexLetterWeight"].to_float();
	numeralWeight = vars["PvP_numeralWeight"].to_float();
	nextLetterWeight = vars["PvP_nextLetterWeight"].to_float();			// Example: allow a future letter to be a tie-breaker
	itemDropWeight = vars["PvP_itemDropWeight"].to_float();		// 4 per 5% drop Example: +8% items is worth 10 letters in laconic/verbosity
	meatDropWeight = vars["PvP_meatDropWeight"].to_float();		// 3 per 5% drop Example: +25% meat is worth 15 letters in laconic/verbosity
	boozeDropWeight = vars["PvP_boozeDropWeight"].to_float();		// 3 per 5% drop Example: +20% booze is worth 12 letters in laconic/verbosity
	initiativeWeight = vars["PvP_initiativeWeight"].to_float();	// 4 per 10% initiative Example: +20% initiative is worth 8 letters in laconic/verbosity
	combatWeight = vars["PvP_combatWeight"].to_float();		// 4 per 10% combat Example: +20% combat is worth 8 letters in laconic/verbosity
	resistanceWeight = vars["PvP_resistanceWeight"].to_float();			// Example: +1 Resistance to all elements equals 6 letters of laconic/verbosity
	powerWeight = vars["PvP_powerWeight"].to_float();			// Example: 5 points for -10 points of power towards Lightest Load vs average(110) power in slot.  
	damageWeight = vars["PvP_damageWeight"].to_float();			// Example: 4 points for 10 points of damage.
	negativeClassWeight = vars["PvP_negativeClassWeight"].to_float();			// Off class items are given a 0, adjust as you see fit.
	weaponDmgWeight = vars["PvP_weaponDmgWeight"].to_float();
	nakedWeight = vars["PvP_nakedWeight"].to_float();	//WORK IN PROGRESS
	
}

//return the class of an item
class getClass(item i)
{
	return to_class(string_modifier(i, "Class"));
}

//	Letter of the moment count	source:Zekaonar
int letterCount(item gear, string letter)
{
	if (gear == $item[none])
		return 0;
	matcher entity = create_matcher("&[^ ;]+;", gear);
	string output = replace_all(entity,"");
	matcher htmltag = create_matcher("\<[^\>]*\>",output);
	output = replace_all(htmltag,"");
	int lettersCounted=0;
	for i from 0 to length(output)-1 {
		if (char_at(output,i).to_lower_case()==letter.to_lower_case()) lettersCounted+=1;  
	}
	return lettersCounted;
}
// DEFACE count
int hexCount(item gear){
	if (gear == $item[none])
		return 0;
	/* Right now, greycat says that html entities count, so we don't need this
	matcher entity = create_matcher("&[^ ;]+;", gear);
	string output = replace_all(entity,"");
	matcher htmltag = create_matcher("\<[^\>]*\>",output);
	output = replace_all(htmltag,"");
	int lettersCounted=0;
	*/
	int lettersCounted = 0;
	string output = gear.to_string();
	for i from 0 to length(output)-1{
		if ($strings[a,b,c,d,e,f,0,1,2,3,4,5,6,7,8,9] contains char_at(output, i)) lettersCounted += 1;
	}
	return lettersCounted;
}

int numCount(item gear){
	if (gear == $item[none])
		return 0;
	int lettersCounted = 0;
	string output = gear.to_string();
	for i from 0 to length(output)-1 {
		if ($strings[0,1,2,3,4,5,6,7,8,9] contains char_at(output, i)) lettersCounted += 1;
	}
	return lettersCounted;
}

//Improved version of length() that deals with HTML entities, tags and counts them like pvp info does  source:Zekaonar
int nameLength(item i) {
	if (i == $item[none] && laconic)
		return 23;
	else if (i == $item[none] && verbosity)
		return 0;
	else if (laconic) {
		return length(i);
	} else {
		matcher entity = create_matcher("&[^ ;]+;", i);
		string output = replace_all(entity,"X");
		matcher htmltag = create_matcher("\<[^\>]*\>",output);
		output = replace_all(htmltag,"");
		return length(output);
	}
}
// Check if you have an item, or it is in the mall historically for a price within the budget
boolean canAcquire(item i) {		//source:Zekaonar
	return ((can_interact() && buyGear && maxBuyPrice >= historical_price(i) && historical_price(i) != 0) 
		|| available_amount(i)-equipped_amount(i) > 0);
}

//Chefstaves require a skill to equip
boolean isChefStaff(item i) {
	return item_type(i) == "chefstaff";
}
//Make sure the item can be equipped
boolean canEquip(item i) {
	if (can_equip(i) && (!isChefStaff(i) || my_class() == $class[Avatar of Jarlsberg] || have_skill($skill[Spirit of Rigatoni]))) {
		return true;
	} else {
		return false;
	}
}

/** generate a wiki link */
string link(String name) {
	string name2 = replace_string(name, " ", "_");
	name2 = replace_string(name2, "&quot;", "%5C%22"); 
	return '<a href="http://kol.coldfront.net/thekolwiki/index.php/'+name2+'">'+name+'</a>';
}


/** version of numeric modifier that filters out conditional bonuses like zone restrictions: The Sea ***/
float numeric_modifier2(item i, string modifier) {
	if (numeric_modifier(i,modifier) != 0) {
		string mods = string_modifier(i,"Modifiers");
		class cl = getClass( i );
		string[int] arr = split_string(mods,",");
		/**check if the item is even for my class if not don't prefer it **/
		if (cl != $class[none] && cl != my_class())
				return negativeClassWeight;
		for j from 0 to Count(arr)-1 by 1 {
			if (arr[j].index_of(modifier) !=-1) {
				if (arr[j].index_of("The Sea") != -1 || arr[j].index_of("Unarmed") != -1 || arr[j].index_of("sporadic") != -1)
					return 0;
				else return numeric_modifier(i,modifier);
			}
		}		
	}
	return 0;
}
/** function for calculating the value of a item based off the mini-game weighting */
float valuation(item i) {
	float value = 0;
	if (laconic)
		value = 23 - nameLength(i);
	else if (verbosity)
		value = nameLength(i);
		
	if (letterCheck) {
		value += letterCount(i,currentLetter)*letterMomentWeight;
		value += letterCount(i,nextLetter)*nextLetterWeight;
	}
	
	if (deface) {
		value += hexCount(i)*hexLetterWeight;
	}

	if (nines) {
		value += numCount(i)*numeralWeight;
	}

	if (egghunt)
		value += numeric_modifier2(i,"Item Drop")*itemDropWeight;
		
	if (meatlover)
		value += numeric_modifier2(i,"Meat Drop")*meatDropWeight;
		
	if (weaponDamage)
		value += numeric_modifier2(i,"Weapon Damage")*weaponDmgWeight;

	if (moarbooze)
		value += numeric_modifier2(i,"Booze Drop")*boozeDropWeight;

	if (showingInitiative)
		value += numeric_modifier2(i,"Initiative")*initiativeWeight;
		
	if (peaceonearth)
		value += numeric_modifier2(i,"Combat Rate")*combatWeight;
		
	if (broadResistance)
		value += min(numeric_modifier2(i,"Cold Resistance"),min(numeric_modifier2(i,"Hot Resistance"),
			min(numeric_modifier2(i,"Spooky Resistance"),min(numeric_modifier2(i,"Sleaze Resistance"),
			numeric_modifier2(i,"Stench Resistance")))))*resistanceWeight;

	if (coldResistance)
		value += numeric_modifier2(i,"Cold Resistance")*resistanceWeight;

	if (hotResistance)
		value += numeric_modifier2(i,"Hot Resistance")*resistanceWeight;
		
	if (sleazeResistance)
		value += numeric_modifier2(i,"Sleaze Resistance")*resistanceWeight;
		
	if (stenchResistance)
		value += numeric_modifier2(i,"Stench Resistance")*resistanceWeight;
		
	if (spookyResistance)
		value += numeric_modifier2(i,"Spooky Resistance")*resistanceWeight;

	if (coldDamage) {
		value += numeric_modifier2(i,"Cold Damage")*damageWeight+numeric_modifier2(i,"Cold Spell Damage")*damageWeight;
	}
	
	if (hotDamage) {
		value += numeric_modifier2(i,"Hot Damage")*damageWeight+numeric_modifier2(i,"Hot Spell Damage")*damageWeight;
	}
	
	if (sleazeDamage) {
		value += numeric_modifier2(i,"Sleaze Damage")*damageWeight+numeric_modifier2(i,"Sleaze Spell Damage")*damageWeight;
	}
	
	if (stenchDamage) {
		value += numeric_modifier2(i,"Stench Damage")*damageWeight+numeric_modifier2(i,"Stench Spell Damage")*damageWeight;
	}
	
	if (spookyDamage) {
		value += numeric_modifier2(i,"Spooky Damage")*damageWeight+numeric_modifier2(i,"Spooky Spell Damage")*damageWeight;
	}

	if (lightestLoad) {
		switch (i.to_slot()) {
		    case $slot[hat]:
		    case $slot[shirt]:
		    case $slot[pants]:
			value += (110-get_power(i))*powerWeight;
		}
	}
	/******
	*
	*Snipped Bjornify and Enthroning here
	*
	*****/
	return value;
}
/** version that combines 2 items for 2hand compared to 1hand + offhand or dual 1hand.
Not used atm, 2hand gets -23 penality in Laconic for empty offhand, need to test Verbose */
float valuation(item i, item i2) {
	float value = 0;
	if (laconic)
		value = 23 - nameLength(i) - nameLength(i2);
	else if (verbosity)
		value = nameLength(i) + nameLength(i2);
		
	if (letterCheck)
		value += (letterCount(i,currentLetter) + letterCount(i2,currentLetter))*letterMomentWeight;
		
	if (egghunt)
		value += (numeric_modifier2(i,"Item Drop")+numeric_modifier2(i2,"Item Drop"))*itemDropWeight;
		
	if (weaponDamage)
		value += (numeric_modifier2(i,"Weapon Damage")+numeric_modifier2(i2,"Weapon Damage"))*weaponDmgWeight;
	
	if (meatlover)
		value += (numeric_modifier2(i,"Meat Drop")+numeric_modifier2(i2,"Meat Drop"))*meatDropWeight;
				
	if (moarbooze)
		value += (numeric_modifier2(i,"Booze Drop")+numeric_modifier2(i2,"Booze Drop"))*boozeDropWeight;
		
	if (showingInitiative)
		value += (numeric_modifier2(i,"Initiative")+numeric_modifier2(i2,"Initiative"))*initiativeWeight;
		

	if (peaceonearth)
		value += (numeric_modifier2(i,"Combat Rate")+numeric_modifier2(i2,"Combat Rate"))*combatWeight;
		

	if (broadResistance) {
		value += min(numeric_modifier2(i,"Cold Resistance"),min(numeric_modifier2(i,"Hot Resistance"),
			min(numeric_modifier2(i,"Spooky Resistance"),min(numeric_modifier2(i,"Sleaze Resistance"),
			numeric_modifier2(i,"Stench Resistance")))))*resistanceWeight
			
			+ min(numeric_modifier2(i2,"Cold Resistance"),min(numeric_modifier2(i2,"Hot Resistance"),
			min(numeric_modifier2(i2,"Spooky Resistance"),min(numeric_modifier2(i2,"Sleaze Resistance"),
			numeric_modifier2(i2,"Stench Resistance")))))*resistanceWeight;
	}	

	if (coldResistance)
		value += numeric_modifier2(i,"Cold Resistance")*resistanceWeight;

	if (hotResistance)
		value += numeric_modifier2(i,"Hot Resistance")*resistanceWeight;
		
	if (sleazeResistance)
		value += numeric_modifier2(i,"Sleaze Resistance")*resistanceWeight;
		
	if (stenchResistance)
		value += numeric_modifier2(i,"Stench Resistance")*resistanceWeight;
		
	if (spookyResistance)
		value += numeric_modifier2(i,"Spooky Resistance")*resistanceWeight;

	if (coldDamage) {
		value += numeric_modifier2(i,"Cold Damage")*damageWeight+numeric_modifier2(i,"Cold Spell Damage")*damageWeight;
		value += numeric_modifier2(i2,"Cold Damage")*damageWeight+numeric_modifier2(i2,"Cold Spell Damage")*damageWeight;
	}
	
	if (hotDamage) {
		value += numeric_modifier2(i,"Hot Damage")*damageWeight+numeric_modifier2(i,"Hot Spell Damage")*damageWeight;
		value += numeric_modifier2(i2,"Hot Damage")*damageWeight+numeric_modifier2(i2,"Hot Spell Damage")*damageWeight;
	}
	
	if (sleazeDamage) {
		value += numeric_modifier2(i,"Sleaze Damage")*damageWeight+numeric_modifier2(i,"Sleaze Spell Damage")*damageWeight;
		value += numeric_modifier2(i2,"Sleaze Damage")*damageWeight+numeric_modifier2(i2,"Sleaze Spell Damage")*damageWeight;
	}
	
	if (stenchDamage) {
		value += numeric_modifier2(i,"Stench Damage")*damageWeight+numeric_modifier2(i,"Stench Spell Damage")*damageWeight;
		value += numeric_modifier2(i2,"Stench Damage")*damageWeight+numeric_modifier2(i2,"Stench Spell Damage")*damageWeight;
	}
	
	if (spookyDamage) {
		value += numeric_modifier2(i,"Spooky Damage")*damageWeight+numeric_modifier2(i,"Spooky Spell Damage")*damageWeight;
		value += numeric_modifier2(i2,"Spooky Damage")*damageWeight+numeric_modifier2(i2,"Spooky Spell Damage")*damageWeight;
	}


	return value;
}
   
/** equips gear, but also acquires it from the mall if it is under budget */
boolean gearup(slot s, item i) {
	if(i == $item[none]) 
		return false;
	//print_html(i + " " + available_amount(i) + " " + equipped_amount(i));	
	if ((available_amount(i)-equipped_amount(i)) <= 0 && can_interact() 
			&& buyGear && maxBuyPrice >= historical_price(i) && historical_price(i) != 0)
		buy(1, i, maxBuyPrice);
		
	if (available_amount(i)-equipped_amount(i) > 0) {
	    if(!(get_inventory() contains i)) {
			boolean raidCloset= get_property("autoSatisfyWithCloset").to_boolean() && closet_amount(i)>=1;
			if(raidCloset) {
				take_closet( 1, i );
			}
	    }
	    return equip(s, i);	//this is where the actual equipping happens
	}
	else 
	    return false;
}


/** pretty print item details related to the active minigames */
string gearString(item i) {
	string gearString = link(i) + " ";
	if (laconic || verbosity)
		gearString += ", " + nameLength(i) + " chars";
	if (letterCheck && letterCount(i,currentLetter) > 0)
		gearString += ", " + letterCount(i,currentLetter) + " letter " + currentLetter;
	if (egghunt && numeric_modifier2(i,"Item Drop") > 0)
		gearString += ", +" + numeric_modifier2(i,"Item Drop") + "% Item Drop";
	if (meatlover && numeric_modifier2(i,"Meat Drop") > 0)
		gearString += ", +" + numeric_modifier2(i,"Meat Drop") + "% Meat Drop";
	if (moarbooze && numeric_modifier2(i,"Booze Drop") > 0)
		gearString += ", +" + numeric_modifier2(i,"Booze Drop") + "% Booze Drop";
	if (weaponDamage && numeric_modifier2(i,"Weapon Damage") > 0)
		gearString += ", +" + numeric_modifier2(i,"Weapon Damage") + " Weapon Damage";
	if (showingInitiative && numeric_modifier2(i,"Initiative") > 0)
		gearString += ", +" + numeric_modifier2(i,"Initiative") + "% Initiative";
	if (peaceonearth && numeric_modifier2(i,"Combat Rate") > 0)
		gearString += ", +" + numeric_modifier2(i,"Combat Rate") + "% Combat";
	if (broadResistance) {	
		int resist = min(numeric_modifier2(i,"Cold Resistance"),min(numeric_modifier2(i,"Hot Resistance"),
			min(numeric_modifier2(i,"Spooky Resistance"),min(numeric_modifier2(i,"Sleaze Resistance"),
			numeric_modifier2(i,"Stench Resistance")))));
			
		if (resist > 0)
			gearString += ", +" + resist + " Elemental Resistance";
	}
	if (coldResistance) {	
		int resist = numeric_modifier2(i,"Cold Resistance");
		if (resist > 0)
			gearString += ", +" + resist + " Elemental Resistance";
	}
	if (hotResistance) {	
		int resist = numeric_modifier2(i,"Hot Resistance");
		if (resist > 0)
			gearString += ", +" + resist + " Elemental Resistance";
	}
	if (sleazeResistance) {	
		int resist = numeric_modifier2(i,"Sleaze Resistance");
		if (resist > 0)
			gearString += ", +" + resist + " Elemental Resistance";
	}
	if (stenchResistance) {	
		int resist = numeric_modifier2(i,"Stench Resistance");
		if (resist > 0)
			gearString += ", +" + resist + " Elemental Resistance";
	}
	if (spookyResistance) {	
		int resist = numeric_modifier2(i,"Spooky Resistance");
		if (resist > 0)
			gearString += ", +" + resist + " Elemental Resistance";
	}	
	if (coldDamage) {
		float damage = numeric_modifier2(i,"Cold Damage")+numeric_modifier2(i,"Cold Spell Damage");
		if (damage > 0)
			gearString += ", +" + damage + " Cold Damage";
	}	
	if (hotDamage) {
		float damage = numeric_modifier2(i,"Hot Damage")+numeric_modifier2(i,"Hot Spell Damage");
		if (damage > 0)
			gearString += ", +" + damage + " Hot Damage";
	}	
	if (sleazeDamage) {
		float damage = numeric_modifier2(i,"Sleaze Damage")+numeric_modifier2(i,"Sleaze Spell Damage");
		if (damage > 0)
			gearString += ", +" + damage + " Sleaze Damage";
	}	
	if (stenchDamage) {
		float damage = numeric_modifier2(i,"Stench Damage")+numeric_modifier2(i,"Stench Spell Damage");
		if (damage > 0)
			gearString += ", +" + damage + " Stench Damage";
	}	
	if (spookyDamage) {
		float damage = numeric_modifier2(i,"Spooky Damage")+numeric_modifier2(i,"Spooky Spell Damage");
		if (damage > 0)
			gearString += ", +" + damage + " Spooky Damage";
	}
	if (lightestLoad && (to_slot(i) == $slot[hat] || to_slot(i) == $slot[pants] || to_slot(i) == $slot[shirt]))
		gearString += ", Power: " + get_power(i);		
	if (available_amount(i) > 0)
		gearString += ", owned by player";
	else if (npc_price(i) > 0)
		gearString += ", for sale by npc for " + npc_price(i);		
	else if (historical_price(i) > 0)
		gearString += ", for sale in  the mall for " + historical_price(i);
	gearString += ", value: " + valuation(i);
	return gearString;
}


/*******
	Snipped familiars
********/


/** loop through gear to find the best one you can get and equip */
void bestGear(string slotString, slot s) {		
	for j from 0 to Count(gear[slotString])-1 by 1 {
		item g = gear[slotString][j];
		if (boolean_modifier(g,"Single Equip") && equipped_amount(g) > 0)
			continue;
		//try to handle Barely Dressed mini
		if (leastGear && valuation(g) < nakedWeight)
		{
			print_html("<b>Best Available " + s + ":</b> " + "None, value: " + nakedWeight);
			break;			
		}
		//this simultaneously checks if a piece can be equipped and tries to do so
		if (valuation(g) > 0 && ((canEquip(g) && gearup(s, g)) || (s == $slot[familiar] && canAcquire(g) && fams[j].use_familiar() && canEquip(g) && gearup(s, g)))) {	
			print_html("<b>Best Available " + s + ":</b> " + gearString(g));
			print_html(string_modifier(g,"Modifiers"));
			break;		
		}
	}
}



void main() {
	print_html("<b>UberPvPOptimizer.ash by UberFerret, a Fork of PVPBestGear by Zekaonar, maintained by digitrev</b>");
	
/**Call Preference/setting load **/
	loadPvPProperties();	
	
	print_html("Gear will be maximized for the following mini-games:");	
	print_html("<ul>");	

	
/*** Determine this season's optimization mini-games ***/	
	string page = visit_url("peevpee.php?place=rules");
	//print_html(page);
	if (index_of(page, "Verbosity") != -1) {
		verbosity = true;
		print_html("<li>Verbosity Demonstration</li>");
	}
	if (index_of(page, "It's a Mystery, Also!") != -1) {
		verbosity = true;
		print_html("<li>It's a Mystery, Also!</li>");
	}
	if (index_of(page, "Laconic") != -1) {
		if (verbosity) {
		    verbosity = false;  // Ignore them.
		} else {
		    laconic = true;
		    print_html("<li>Laconic Dresser</li>");
		}
	}
	if (index_of(page, "Outfit Compression") != -1) {
		if (verbosity) {
		    verbosity = false;  // Ignore them.
		} else {
		    laconic = true;
		    print_html("<li>Outfit Compression</li>");
		}
	}
	if (index_of(page, "Showing Initiative") != -1) {
		showingInitiative = true;
		print_html("<li>Showing Initiative</li>");
	}	
	if (index_of(page, "Early Shopper") != -1) {
		showingInitiative = true;
		print_html("<li>Early Shopper</li>");
	}	
	if (index_of(page, "Peace on Earth") != -1) {
		peaceonearth = true;
		combatWeight = -combatWeight;
		print_html("<li>Peace on Earth</li>");
	}	
	if (index_of(page, "Sooooper Sneaky") != -1) {
		peaceonearth = true;
		combatWeight = -combatWeight;
		print_html("<li>Sooooper Sneaky</li>");
	}
	if (index_of(page, "Smellin' Like a Stinkin' Rose") != -1) {
		peaceonearth = true;
		combatWeight = -combatWeight;
		print_html("<li>Smellin' Like a Stinkin' Rose</li>");
	}	
	if (index_of(page, "The Egg Hunt") != -1) {
		egghunt = true;
		print_html("<li>The Egg Hunt</li>");
	}
	if (index_of(page, "The Optimal Stat") != -1) {
		egghunt = true;
		print_html("<li>The Optimal Stat</li>");
	}
	if (index_of(page, "Meat Lover") != -1) {
		meatlover = true;
		print_html("<li>Meat Lover</li>");
	}
	if (index_of(page, "Maul Power") != -1) {
		weaponDamage = true;
		print_html("<li>Maul Power</li>");
	}	
	if (index_of(page, "Moarrrrrr Booze!") != -1) {
		moarbooze = true;
		print_html("<li>Moarrrrrr Booze!</li>");
	}
	if (index_of(page, "Holiday Spirit(s)!") != -1) {
		moarbooze = true;
		print_html("<li>Moarrr Booze!</li>");
	}
	if (index_of(page, "Broad Resistance Contest") != -1) {
		broadResistance = true;
		print_html("<li>Broad Resistance Contest</li>");
	}	
	if (index_of(page, "All Bundled Up") != -1) {
		coldResistance = true;
		print_html("<li>All Bundled Up</li>");
	}
	if (index_of(page, "Hibernation Ready") != -1) {
		coldResistance = true;
		print_html("<li>Hibernation Ready</li>");
	}
/*******	Future proofed	
	if (index_of(page, "TBD") != -1) {
		hotResistance = true;
		print_html("<li>TBD</li>");
	}	
	if (index_of(page, "TBD") != -1) {
		sleazeResistance = true;
		print_html("<li>TBD</li>");
	}			
********/
	if (index_of(page, "Hold Your Nose") != -1) {
		stenchResistance = true;
		print_html("<li>Hold Your Nose</li>");
	}	
/*******	Future proofed	
	if (index_of(page, "TBD") != -1) {
		spookyResistance = true;
		print_html("<li>TBD</li>");
	}	
	if (index_of(page, "TBD") != -1) {
		coldDamage = true;
		print_html("<li>TBD</li>");
	}	
******/
	if (index_of(page, "Ready to Melt") != -1) {
		hotDamage = true;
		print_html("<li>Ready to Melt</li>");
	}	
	if (index_of(page, "Fahrenheit 451") != -1) {
		hotDamage = true;
		print_html("<li>Fahrenheit 451</li>");
	}	
	if (index_of(page, "Hot for Teacher") != -1) {
		hotDamage = true;
		print_html("<li>Hot for Teacher</li>");
	}	
	if (index_of(page, "Innuendo Master") != -1) {
		sleazeDamage = true;
		print_html("<li>Innuendo Master</li>");
	}
/*******	Future proofed		
	if (index_of(page, "TBD") != -1) {
		stenchDamage = true;
		print_html("<li>TBD</li>");
	}	
	if (index_of(page, "TBD") != -1) {
		spookyDamage = true;
		print_html("<li>TBD</li>");
	}	
******/	
	if (index_of(page, "Lightest Load") != -1) {
		lightestLoad = true;
		print_html("<li>Lightest Load</li>");
	}		
	if (index_of(page, "Optimal Dresser") != -1) {
		lightestLoad = true;
		print_html("<li>Optimal Dresser</li>");
	}		
	if (index_of(page, "Barely Dressed") != -1) {
		leastGear = true;
		print_html("<li>Barely Dressed</li>");
	}	
	if (index_of(page, "Fashion Show") != -1) {
		lightestLoad = true;
		powerWeight =  -powerWeight;
		print_html("<li>Fashion Show</li>");
	}		
	if (index_of(page, "Spirit of Noel") != -1) {
		letterCheck = true;	
		currentLetter = "L";
		nextLetter = "L";
		letterMomentWeight = -letterMomentWeight;
		nextLetterWeight = 0;
		print_html("<li>Spirit of Noel</li>");
	}
	if (index_of(page, "Spirit Day") != -1) {
		letterCheck = true;	
		int start = index_of(page, "It's one of those crazy school spirit days where everyone wears clothes with the letter <b>");
		currentLetter = substring(page,start+91,start+92);
//		currentLetter="X";			//hacky way to force optimizing a letter
		start = index_of(page, "Changing to <b>");
		nextLetter = substring(page,start+15,start+16);
		start = index_of(page, "</b> in ");
		int end = index_of(page," seconds.)");
		string secs = substring(page,start+8,end);		
		print_html("<li>Spirit Day: " + currentLetter + ", next " + nextLetter + " </li>");
	}
	if (index_of(page, "Letter of the Moment") != -1) {
		letterCheck = true;	
		int start = index_of(page, "Who has the most <b>");
		currentLetter = substring(page,start+20,start+21);
//		currentLetter="X";			//hacky way to force optimizing a letter
		start = index_of(page, "Changing to <b>");
		nextLetter = substring(page,start+15,start+16);
		start = index_of(page, "</b> in ");
		int end = index_of(page," seconds.)");
		string secs = substring(page,start+8,end);		
		print_html("<li>Letter of the Moment: " + currentLetter + ", next " + nextLetter + " </li>");
	}
	if (index_of(page, "DEFACE") != -1) {
		deface = true;	
		print_html("<li>DEFACE</li>");
	}
	if (index_of(page, "Dressed to the 9s") != -1) {
		nines = true;
		print_html("<li>Dressed to the 9s</li>");
	}
	print_html("</ul>");
	
/*** unequip all slots ***/
	foreach i in $slots[hat, back, shirt, weapon, off-hand, pants, acc1, acc2, acc3, familiar] 
		equip(i,$item[none]);
	print_html("<br/>");	
/*******
	Snipped familiars
********/

/*** create lists of all items in each slot type ***/
	foreach i in $items[] { // This iterates over all items in the game		
		// if it's gear that you can equip, and you have it or the mall price is under threshold
		string s = to_slot(i);
		int price = npc_price(i);
		if (price == 0) 
			price = historical_price(i);
		if((!($slots[none, familiar] contains s.to_slot()) && can_equip(i)) &&  
			(showAllItems || canAcquire(i))) {
			
			string modstring = string_modifier(i,"Modifiers");
			// filter situational items that don't apply to fighting in arena
			if (modstring.index_of("Unarmed") == -1) {
			

			// create a new slot type for 2 hand and 3 hand weapons (not used atm)
				if (s == $slot[weapon] && weapon_hands(i) > 1)
					s = "2h weapon";

				gear[s] [count(gear[s])] = i;
				//length(i)
			}
		}
	}

	familiar [item] famItems;
	foreach f in $familiars[]
		if(f.have_familiar())
			famItems[familiar_equipment(f)] = f;
	string s = $slot[familiar].to_string();
	foreach it in $items[] {
		int price = npc_price(it);
		if (price == 0)
			price = historical_price(it);
		if (famItems contains it || (it.to_slot().to_string() == s && string_modifier(it, "Modifiers").contains_text("Generic"))&& (showAllItems || canAcquire(it))) {
			gear[s][count(gear[s])] = it;
			if(famItems contains it)
				fams[count(fams)] = famItems[it];
			else
				fams[count(fams)] = my_familiar();
		}
	}

/*** Top Gear display lists ***/
	sort fams by -valuation(gear["familiar"][index]);
	foreach i in $slots[hat, back, shirt, weapon, off-hand, pants, acc1, familiar] {
		int itemCount = count(gear[to_string(i)]); 
		print_html("<b>Slot <i>" + i + "</i> items considered: " + itemCount + " printing top items in slot:</b>");

		sort gear[to_string(i)] by -valuation(value);

		if(limitExpensiveDisplay == true)
		{
			for j from 0 to (topItems - 1) by 1 
				print_html((j+1) + ".) " + gearString(gear[to_string(i)][j]) );
			print_html("<br/>");
		}
		else
		{
			int dumbCounter = 0;
			int dumbCounterToo = 0;
			while(dumbCounter <= (topItems-1))
			{
				if(historical_price(gear[to_string(i)][dumbCounterToo])<= defineExpensive)
				{
					print_html((dumbCounter+1) + ".) " + gearString(gear[to_string(i)][dumbCounterToo]) );
					dumbCounterToo = dumbCounterToo + 1;
					dumbCounter = dumbCounter + 1;
				}
				else
				{
					dumbCounterToo = dumbCounterToo + 1;
				}
			}
			print_html("<br/>");
		}
	}
	
	
	
/*** DISPLAY BEST GEAR IN SLOTS ***/	
	
	
/*******
	Snipped familiars
********/

	
/*** Display best in slot  ***/	
	bestGear("hat", $slot[hat]);
	bestGear("back", $slot[back]);
	bestGear("shirt", $slot[shirt]);
		
	// determine the best possible weapon combos
	// 2hand / 3hand 
	// 1hand + offhand
	// 1hand + 1hand (if skill Double-Fisted Skull Smashing)
	if (have_skill($skill[Double-Fisted Skull Smashing])) {
		dualWield = true;
		print_html("<b>Player can dual wield 1-hand weapons.</b>");
	}

	int k = 0;
	for j from 0 to Count(gear["weapon"])-1 by 1 {
		if(canAcquire(gear["weapon"][j])) {
			primaryWeapon = gear["weapon"][j];
			k = j;
			break;			
		}
	}
	bestGear("weapon", $slot[weapon]);
	
	if (available_amount(primaryWeapon)-equipped_amount(primaryWeapon) > 1 || (historical_price(primaryWeapon) < maxBuyPrice && historical_price(primaryWeapon) > 0) && !isChefStaff(primaryWeapon))
		secondaryWeapon = primaryWeapon;
	else {
		for j from k+1 to Count(gear["weapon"])-1 by 1 {
			if(canAcquire(gear["weapon"][j]) && weapon_type(gear["weapon"][j]) == weapon_type(primaryWeapon) && !isChefStaff(primaryWeapon)) {
				secondaryWeapon = gear["weapon"][j];
				break;			
			}
		}	
	}
	for j from 0 to Count(gear["off-hand"])-1 by 1 {
		if(canAcquire(gear["off-hand"][j])) {
			bestOffhand = gear["off-hand"][j];
			k = j;
			break;			
		}
	}

	if ((!dualWield 
		|| valuation(primaryWeapon,bestOffhand) > valuation(primaryWeapon,secondaryWeapon))) {
		gearup($slot[off-hand],bestOffhand);
		print_html("<b>Best Available off-hand:</b> " + gearString(bestOffhand));
		print_html(string_modifier(bestOffhand,"Modifiers"));				
		
	} else {
		gearup($slot[off-hand],secondaryWeapon);
		print_html("<b>Best 2nd weapon:</b> " + gearString(secondaryWeapon));
		print_html(string_modifier(secondaryWeapon,"Modifiers"));						
	}
	bestGear("pants", $slot[pants]);
	bestGear("acc1", $slot[acc1]);
	bestGear("acc1", $slot[acc2]);
	bestGear("acc1", $slot[acc3]);
	bestGear("familiar", $slot[familiar]);
	
/*******
	Snipped familiars********/	

	page = visit_url("peevpee.php?place=rules");
	page = substring(page,index_of(page, "</head>")+7,length(page));	
	//print_html(page);
	
}
