// ----------------------------------------------------------------------------
// EatDrink.ash
// by 
// dj_d
// 
// inspired by reportConsumables.ash, by Sandiman
//
// ----------------------------------------------------------------------------
script "EatDrink.ash"
notify "Theraze"

import <zlib.ash>;

//STATUS: removed autospading & local data files. Sort maps.
//TODO: test each type of consumption separately. Make sure recalc after consumption does the right thing. Consume-at-end. Cleanup error pricing states. Look in to other "cleaning" items.

string EATDRINK_VERSION = "3.2";
int EATDRINK_VERSION_PAGE = 1519;

int MAXMEAT = 999999999;

// --- Preferences --- //
// Note: DON'T CHANGE THESE HERE! This just sets the defaults. Changing them
// won't do anything. Go to your scripts directory and modify the file 
// vars_yourcharactername.txt

// 'true' to include items in the user's closet
boolean USE_CLOSET = to_boolean(get_property("autoSatisfyWithCloset"));

// 'true' to include items in the user's storage
boolean USE_STORAGE = to_boolean(get_property("autoSatisfyWithStorage"));

// If true, it assumes that your starting fullness & drunkenness are 0 (so
// can use it when full). You do not actually drink or eat, and no item
// updates are saved at the end.
setvar("eatdrink_simConsume", true);
boolean SIM_CONSUME = to_boolean(vars["eatdrink_simConsume"]);
// do not actually buy or consume, and pretend starting fullness is 0.

// If true, you won't receive the "Are you sure you want to..." message on 
// overdrink.
setvar("eatdrink_suppressOverdrink", true);
boolean SUPRESS_OVERDRINK = to_boolean(vars["eatdrink_suppressOverdrink"]);

// If true, you won't receive the "Are you sure you want to..." message on 
// eat without milk.
setvar("eatdrink_suppressNoMilk", false);
boolean SUPRESS_NOMILK = to_boolean(vars["eatdrink_suppressNoMilk"]);
boolean wants_milk = true;
boolean wants_lasagna = true;

// If true, you will buy food and ingredients from NPC stores. It is highly
// recommended that you closet most of your meat before running this as a
// safety precaution against bugs in the script (this is true of all scripts!).
boolean EAT_COINMASTER = to_boolean(get_property("autoSatisfyWithCoinmasters"));

// If true, you will buy food and ingredients from NPC stores. It is highly
// recommended that you closet most of your meat before running this as a
// safety precaution against bugs in the script (this is true of all scripts!).
boolean EAT_SHOP = to_boolean(get_property("autoSatisfyWithNPCs"));

// If true, you will buy food from players to consume. It is highly recommended
// that you closet most of your meat before running this as a safety precaution
// against bugs in the script (this is true of all scripts!).
boolean EAT_MALL = to_boolean(get_property("autoSatisfyWithMall"));

// If true, you will make food if you have all the ingredients available.
setvar("eatdrink_make", true);
boolean EAT_MAKE = to_boolean(vars["eatdrink_make"]);

// If true, you will eliminate food if you no longer have all the ingredients available.
setvar("eatdrink_accurateMake", true);
boolean EAT_ACCURATE = to_boolean(vars["eatdrink_accurateMake"]);

// If true, you will try to acquire an accordion if need be.
setvar("eatdrink_accordionGet", false);
boolean EAT_ACCORDION = to_boolean(vars["eatdrink_accordionGet"]) && have_skill($skill[the ode to booze]);

// Do you want to invoke Song of the Glorious Lunch before eating?
// This only works if you actually possess the skill
setvar("eatdrink_gloriousLunch", true);
boolean wants_lunch = have_skill($skill[song of the glorious lunch]) ? to_boolean(vars["eatdrink_gloriousLunch"]) : false;

// Do you want to invoke Ode before drinking?
// This only works if you actually possess the skill
setvar("eatdrink_ode", true);
boolean wants_ode = have_skill($skill[the ode to booze]) ? to_boolean(vars["eatdrink_ode"]) : false;

// Do you want to shrug your cheapest re-castable Accordion buff if you have too many?
setvar("eatdrink_shrug", false);
boolean ode_shrug = wants_ode ? to_boolean(vars["eatdrink_shrug"]) : false;

// If shopping, ignore items that cost more than PRICE FLEXIBILITY * this 
// (another safety precaution, but not as reliable as closting your meat). 
// This should not be necessary (you can set it to MAXMEAT theoretically)
// since the interplay of other variables ensures you won't spend more than
// you're willing to... still, it's good to be safe. 
setvar("eatdrink_budget", 20000);
int BUDGET = to_int(vars["eatdrink_budget"]);

// This is an attempt to allow for maximum meat spent per step. If the value
// is set to a negative number, consider all your meat as possible. If the
// value is set to anything higher, your starting meat for that step should be
// no higher than STEP_MEAT. If you have less than the amount listed, it should
// use the actual value instead. This defaults to unlimited (-1) because new
// users kept getting confused by the results, but should probably be set to a
// positive value to save users from themselves if not simulating carefully. :)
setvar("eatdrink_stepMeat", -1);
int STEP_MEAT = (my_path() == "Way of the Surprising Fist") ? 0 : to_int(vars["eatdrink_stepMeat"]);

// Before buying, making, etc stuff, it will pause this many seconds.
setvar("eatdrink_pause", 3);
int pause = to_int(vars["eatdrink_pause"]);

// 0: skip servants if in HC. 1: make servants; continue if it fails. 2: make servants; abort if it fails.
setvar("eatdrink_hardcoreServants", 2);
int HARDCORE_SERVANTS = to_int(vars["eatdrink_hardcoreServants"]);

// If not 0, buy/pull a *****-in-the-box if one's required and it's
// possible for under the set amount, and -1 meaning price is no object.
if (vars["eatdrink_getChef"] == "true")
{
  vars["eatdrink_getChef"] = 5000;
  updatevars();
}
setvar("eatdrink_getChef", 5000);
int GET_CHEF = to_int(vars["eatdrink_getChef"]);
if (vars["eatdrink_getBartender"] == "true")
{
  vars["eatdrink_getBartender"] = 30000;
  updatevars();
}
setvar("eatdrink_getBartender", 30000);
int GET_BARTENDER = to_int(vars["eatdrink_getBartender"]);

// Estimated prices are often off; you should be willing to pay somewhat more.
// Setting this closer to 1 will optimize slightly but slow things down a lot.
// It cannot be less than 1 or you'll hang. A minimum of 1.25 is recommended.
setvar("eatdrink_priceFlexibility", 1.25);
float PRICE_FLEXIBILITY = to_float(vars["eatdrink_priceFlexibility"]);

// 'true' will cause you to consider the price of food that you own already.
// 'false' means to treat items you own as free.
setvar("eatdrink_considerCostWhenOwned", true);
boolean CONSIDER_COST_WHEN_OWNED = 
  to_boolean(vars["eatdrink_considerCostWhenOwned"]);

// This makes you use items in inventory by autosell price instead during ronin
setvar("eatdrink_autosellWhileRonin", false);
boolean AUTOSELL_RONIN = to_boolean(vars["eatdrink_autosellWhileRonin"]);

//Avoid consuming noodles for Carboloading trophy or stunt runs
setvar("eatdrink_noNoodles", false);

// The score for these food & drinks will display when the script runs so you 
// can find out why it chose what it did over these. Recommended use is to 
// turn on SIM_CONSUME, then set these to your favorite diet and see if it 
// finds something better than your favorite diet. Will probalby not work for
// items with wierd characters, e.g. Genelen(tm) bottles.
setvar("eatdrink_fav_"+replace_string(to_string($item[pr0n chow mein])," ","_"),
       true);
setvar("eatdrink_fav_"+replace_string(to_string($item[rockin' wagon])," ","_"), 
       true);
setvar("eatdrink_fav_"+replace_string(to_string($item[twinkly wad])," ","_"), 
       true);
// if false, ignore favorites (speeds things up a bit)
setvar("eatdrink_favUse",false);

//Avoid consuming any of these items
setvar("eatdrink_avoid_"+replace_string(to_string($item[astral energy drink])," ","_"), true);
setvar("eatdrink_avoid_"+replace_string(to_string($item[astral hot dog])," ","_"), true);
setvar("eatdrink_avoid_"+replace_string(to_string($item[astral pilsner])," ","_"), true);
setvar("eatdrink_avoid_"+replace_string(to_string($item[booze-soaked cherry])," ","_"), true);
setvar("eatdrink_avoid_"+replace_string(to_string($item[giant marshmallow])," ","_"), true);
setvar("eatdrink_avoid_"+replace_string(to_string($item[gin-soaked blotter paper])," ","_"), true);
setvar("eatdrink_avoid_"+replace_string(to_string($item[sponge cake])," ","_"), true);
setvar("eatdrink_avoid_"+replace_string(to_string($item[wet stew])," ","_"), true);

// The interplay of the next values determines what sort of diet you'll get. 
// The difference between the two numbers is the relative value of adventures 
// and stats. Setting them both high means you're willing to spend more cash; 
// setting them both low means you're thrifty. 100/20 may put you on sausage 
// pizzas, for example, while 200/40 may get you bat wing chow mein. 
// A reasonable way to set this is "how much meat would I pay for one adventure"

//IMPORTANT: valueOfAdventures is stored in \settings\charname.txt. You have to
//change it there to set this parameter (and it's the most impactful parameter 
//to set)
int VALUE_OF_ADVENTURE = to_int(get_property("valueOfAdventure"));

// The "cost" of a Hagnk pull if you need to pull the item in ronin to get it. 
// The bigger the number, the more reluctant you'll be to pull. 
// This number also ensures that you favor high-fullness food for your pulls
// (requiring fewer) since when it's calculated, it's first divided by fullness.
setvar("eatdrink_costOfPull", 3000);
int COST_OF_PULL = to_int(vars["eatdrink_costOfPull"]);

// Likewise, "How much would I pay for a stat subpoint"
setvar("eatdrink_valueOfPrimeStat", 10);
float VALUE_OF_PRIME_STAT = to_float(vars["eatdrink_valueOfPrimeStat"]);
setvar("eatdrink_valueOfNonPrimeStat", 2);
float VALUE_OF_NONPRIME_STAT = to_float(vars["eatdrink_valueOfNonPrimeStat"]);

// "What is the minimum average adventures per consumption point"
setvar("eatdrink_minimumAverage", 1.0);
float MINIMUM_AVERAGE = to_float(vars["eatdrink_minimumAverage"]);

// "What is the minimum quality of item we're going to consider"
setvar("eatdrink_minimumQuality", 0);
int MINIMUM_QUALITY = to_int(vars["eatdrink_minimumQuality"]);

// "How many times should ingredients loop to look for creatable items"
setvar("eatdrink_loopCount", 5);
int LOOP_COUNT = to_int(vars["eatdrink_loopCount"]);

//If true, then any time your level permits it and you're missing a key
//(Boris, Jarlsberg, or Sneaky Pete), eatdrink will make the corresponding
//pie a top priority.
setvar("eatdrink_piePriority", true);
boolean PIE_PRIORITY = to_boolean(vars["eatdrink_piePriority"]);

// Some items are nontradable, so their price can't be calculated. These items
// tend to be very good (e.g. pan-galactic gargleblaster). You may not want
// to consume them lightly, so set this at MAXMEAT. If you do want to eat 
// the very best food available regardless of value, set this to 0.
setvar("eatdrink_priceOfNontradeables", MAXMEAT);
int PRICE_OF_NONTRADEABLES = to_int(vars["eatdrink_priceOfNontradeables"]);

// Some items are quest nontradables, so their price can't be calculated.
// These items tend to be okay (e.g. turtle soup). You may not want to
// consume them automatically because you want their effects, so we set this
// at MAXMEAT. If you do want to eat these, set this to something like 100.
setvar("eatdrink_priceOfQuestItems", MAXMEAT);
int PRICE_OF_QUESTITEMS = to_int(vars["eatdrink_priceOfQuestItems"]);

// Similar to the above, except sometimes the lookup fails for lousy items.
// MAXMEAT will cause items where lookup fails to be ignored from consideration.
setvar("eatdrink_priceOfUnknowns", MAXMEAT);
int PRICE_OF_UNKNOWNS = to_int(vars["eatdrink_priceOfUnknowns"]);

//if true, assume everything must be pulled. If false, use your current character state.
setvar("eatdrink_simRonin", false);
boolean SIM_RONIN = to_boolean(vars["eatdrink_simRonin"]);

// if 0, then use your actual level. If you'd like to simulate a different level (e.g. ascension planning), set it to that level.
setvar("eatdrink_simLevel", 0);
int SIM_LEVEL = to_int(vars["eatdrink_simLevel"]);

/////////////////////////////////////////////////////////////////////////////

string finalsummary;

boolean[item]tuxable;
tuxable[$item[dry martini]] = true;
tuxable[$item[dry vodka martini]] = true;
tuxable[$item[gibson]] = true;
tuxable[$item[martini]] = true;
tuxable[$item[rockin' wagon]] = true;
tuxable[$item[soft green echo eyedrop antidote martini]] = true;
tuxable[$item[vodka gibson]] = true;
tuxable[$item[vodka martini]] = true;

boolean [item]special_items;
special_items[$item[steel margarita]] = true;
special_items[$item[steel lasagna]] = true;
special_items[$item[steel-scented air freshener]] = true;
special_items[$item[bodyslam]] = true;
special_items[$item[cherry bomb]] = true;
special_items[$item[dirty martini]] = true;
special_items[$item[grogtini]] = true;
special_items[$item[sangria del diablo]] = true;
special_items[$item[vesper]] = true;
special_items[$item[boris's key lime pie]] = true;
special_items[$item[jarlsberg's key lime pie]] = true;
special_items[$item[sneaky pete's key lime pie]] = true;

boolean [item] favorites; //will be populated in main()

boolean tuxworthy(item it)
{
  return (tuxable contains it) && (have_item($item[tuxedo shirt]) > 0) &&
    can_equip($item[tuxedo shirt]);
}

void summarize(string add)
{
  logprint(add);
  print_html(add);
  finalsummary += add + "<br>";
}

boolean var_check(string vari) { 
    if(vars contains vari) 
        return vars[vari].to_boolean(); 
    return false; 
}

// Globals used for simulating consumption.
#int simmeat = MAXMEAT;
int simmeat = my_meat();
int simfullness = 0;
int siminebriety = 0;
int simspleen = 0;
float simadventures = 0.0;
int simmuscle = 0;
int simmoxie = 0;
int simmysticality = 0;
boolean simgar = false;
boolean simmilk = false;
boolean simlunch = false;
boolean simode = false;
int[item] simchoc;

int ConsumptionReportIndex = 1;

record range
{
  float max;
  float min;
};

// A single entry in our processing lists.
// Contains all relevant information about one consumable (food or booze).
record con_rec
{
  item it; //the consumable in question
  string type; //"food", "booze", or "spleen" ("overdrink" is invalid here)
  range consumptionGain; //fullness, inebriety, whatever
  int level; //min level required
  range adv; //adv gain
  range muscle;    //stat subpoint gain
  range mysticality;
  range moxie;
  int price;       //mall price
  float value;       //calculated value
  int have; 
  int using; 
  boolean mustCoinmaster;//to get it, you have to buy it from coinmasters
  boolean mustDaily;//to get it, you have to buy it from the daily shop
  boolean mustMake;//to get it, you have to make it
  boolean mustMall;//to get it, you have to buy it from players
  boolean mustPull;//to get it, you have to pull it
  boolean mustShop;//to get it, you have to buy it from NPCs
  boolean canDaily;//to get it, you can buy it from the daily shop
  boolean canShop;//to get it, you can buy it from NPCs
};

//"grub" contains all consumables in the game. It gets sorted and filtered etc.
con_rec [int] basegrub;
con_rec [int] grub;
boolean [item] fail;

con_rec [int] position;
int [item] ingredients;
int maxposition;
int nowposition;
int nomposition;

con_rec [int] specposition;
int [item] specingredients;
int specmaxposition;

int[int] bestvoa;
int usedmeat = 0;
int makeusedmeat = 0;
int makeveryusedmeat = 0;
int maybeusedmeat = 0;
int stepusedmeat = 0;

int [item] usingMake;

int [item] simitem;
int [item] simingredients;

// Converts a range of numbers (or single number) to a single number.
// If the string is a single number, that number is returned.
// If the string is a range of numbers, the average of the parsed numbers is returned.
// Modification by slyz as posted at 
// http://kolmafia.us/showthread.php?1519-EatDrink.ash-Optimize-your-daily-diet-%28and-see-how-your-old-diet-stacks-up%29.&p=32820&viewfull=1#post32820
range set_range(string rangestring)
{
  string[int] splitRange = split_string(rangestring, "-");
  range returnval;
  // If we only got 1 number, return it for both
  if (count(splitRange) == 1)
  {
    returnval.max = to_float(splitRange[0]);
    returnval.min = returnval.max;
    return returnval;
  }
  else if (splitRange[0]=="")
  {
    returnval.max = (-1.0) * to_float(splitRange[1]) ;
    returnval.min = returnval.max;
    return returnval;
  }
  // Return the 2 numbers
  returnval.min = to_float(splitRange[0]);
  returnval.max = to_float(splitRange[1]);
  return returnval;
}  

float averange (range statrange)
{ return ((statrange.max + statrange.min) / 2.0); }

int get_meat(int stage)
{
// stages: 0 - all. 1 - used. 2 - used if simulating.
  if (!SIM_CONSUME)
    return (stage > 0 && my_meat() > STEP_MEAT && STEP_MEAT >= 0 ? STEP_MEAT : my_meat()) - (stage == 1 ? makeusedmeat + stepusedmeat : 0);
  if (stage == 0) return simmeat;
  return ((simmeat - usedmeat) > STEP_MEAT && STEP_MEAT >= 0 ? STEP_MEAT + usedmeat : simmeat) - (stage >= 1 ? usedmeat + makeusedmeat + stepusedmeat : 0);
}

int get_fullness()
{
  if (!SIM_CONSUME)
    return my_fullness();
  return simfullness;
}

int get_inebriety()
{
  if (!SIM_CONSUME)
    return my_inebriety();
  return siminebriety;
}

int get_spleen()
{
  if (!SIM_CONSUME)
    return my_spleen_use();
  return simspleen;
}

int get_adventures()
{
  if (!SIM_CONSUME)
    return my_adventures();
  return to_int(simadventures);
}

int get_muscle()
{
  if (!SIM_CONSUME)
    return my_basestat($stat[SubMuscle]);
  return simmuscle;
}

int get_moxie()
{
  if (!SIM_CONSUME)
    return my_basestat($stat[SubMoxie]);
  return simmoxie;
}

int get_mysticality()
{
  if (!SIM_CONSUME)
    return my_basestat($stat[SubMysticality]);
  return simmysticality;
}

int get_level()
{
  if (SIM_LEVEL == 0)
    return my_level();
  return SIM_LEVEL;
}

int get_starter_items()
{
  return (min(1, item_amount($item[seal-skull helmet]) + equipped_amount($item[seal-skull helmet])) + min(1, item_amount($item[seal-clubbing club]) + equipped_amount($item[seal-clubbing club])) + min(1, item_amount($item[helmet turtle]) + equipped_amount($item[helmet turtle])) + min(1, item_amount($item[turtle totem]) + equipped_amount($item[turtle totem])) + min(1, item_amount($item[ravioli hat]) + equipped_amount($item[ravioli hat])) + min(1, item_amount($item[pasta spoon]) + equipped_amount($item[pasta spoon])) + min(1, item_amount($item[hollandaise helmet]) + equipped_amount($item[hollandaise helmet])) + min(1, item_amount($item[saucepan]) + equipped_amount($item[saucepan])) + min(1, item_amount($item[disco mask]) + equipped_amount($item[disco mask])) + min(1, item_amount($item[disco ball]) + equipped_amount($item[disco ball])) + min(1, item_amount($item[mariachi hat]) + equipped_amount($item[mariachi hat])) + min(1, item_amount($item[stolen accordion]) + equipped_amount($item[stolen accordion])) + min(1, item_amount($item[old sweatpants]) + equipped_amount($item[old sweatpants])));
}

int get_accordion()
{
  int turns = turns_per_cast($skill[the ode to booze]);
  if (turns > 5 || !EAT_ACCORDION || my_meat() < 250) return turns;
  if (my_meat() > 2500 && npc_price($item[antique accordion]) > 0) buy(1, $item[antique accordion]);
  else if (my_meat() > 250 && turns == 0 && npc_price($item[toy accordion]) > 0) buy(1, $item[toy accordion]);
  return (turns_per_cast($skill[the ode to booze]));
}

int get_quality(item checking)
{
  int level = -1;
  switch (checking.quality.to_lower_case())
  {
    case "crappy":
      level = 0;
      break;
    case "decent":
      level = 1;
      break;
    case "good":
      level = 2;
      break;
    case "awesome":
      level = 3;
      break;
    case "epic":
      level = 4;
      break;
  }
  return level;
}

boolean get_milk(int full)
{
  if (!SIM_CONSUME)
    return (have_effect($effect[got milk]) >= full);
  return simmilk;
}

boolean get_gar()
{
  if (numeric_modifier($item[tuesday's ruby], "muscle percent") == 5.0)
    return false;
  if (!SIM_CONSUME)
    return (have_effect($effect[gar-ish]) > 0);
  return simgar;
}

boolean get_lunch(int full)
{
  if (my_class() != $class[Avatar of Boris])
    return false;
  if (!SIM_CONSUME)
    return (have_effect($effect[song of the glorious lunch]) >= full);
  return simlunch;
}

boolean get_ode(int drink)
{
  if (!SIM_CONSUME)
    return (have_effect($effect[ode to booze]) >= drink);
  return simode;
}

boolean get_ronin()
{
  if (!SIM_RONIN)
    return (!can_interact());
  return true;
}

//will be defined later
boolean getone(item it, int price);
float value(con_rec con, boolean overdrink, boolean breakfast, boolean speculating);
boolean consumeone(con_rec con, string type, int iteration, int step);
string format_entry(con_rec entry);

int[item] brokenprice; //If you tried to buy it and failed, this is the price
boolean[item] brokenpull; //If you tried to pull it and failed
boolean[item] brokenmake; //If you tried to make it and failed

int special_prices(item it, int startprice)
{
  //These are unpriceable, so return a small number (that isn't reserved)
  if (it == $item[steel margarita] && (item_amount(it) > 0))
    return 2;
  if (it == $item[steel lasagna] && (item_amount(it) > 0))
    return 2;
  if (it == $item[steel-scented air freshener] && (item_amount(it) > 0))
    return 2;
  if (it == $item[spaghetti breakfast] && (item_amount(it) > 0))
    return 2;

  int price1 = 0;
  int price2 = 0;
  
  // special pricing rules for key lime pies
  boolean JKEY = (item_amount($item[jarlsberg's key]) > 0);
  boolean BKEY = (item_amount($item[boris's key]) > 0);
  boolean SPKEY = (item_amount($item[sneaky pete's key]) > 0);
  boolean itsa_pie = false;
  
  if (it==$item[jarlsberg's key lime pie] && (JKEY || (item_amount(it) > 0)))
    itsa_pie = true;
  else if (it==$item[boris's key lime pie] && (BKEY || (item_amount(it) > 0)))
    itsa_pie = true;
  else if (it==$item[sneaky pete's key lime pie] && 
           (SPKEY || (item_amount(it) > 0)))
    itsa_pie = true;
  
  if (itsa_pie)
  {
    price1 = mall_price($item[lime]);
    price2 = mall_price($item[pie crust]);
    if ((price1 <= 1) || (price2 <= 1))
      return 0;
    return (price1 + price2);  
  }
  
  //Special pricing rules for TPS drinks
  boolean TPS = false;
  TPS = (item_amount($item[tiny plastic sword]) > 0);

  boolean checked = false;
  if (it == $item[bodyslam] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item[bottle of tequila]);
    price2 = mall_price($item[lime]); 
    checked = true;
  }
  if (it == $item[cherry bomb] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item[bottle of whiskey]);
    price2 = mall_price($item[cherry]);
    checked = true;
  }
  if (it == $item[dirty martini] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item[bottle of gin]);
    price2 = mall_price($item[jumbo olive]); 
    checked = true;
  }
  if (it == $item[grogtini] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item[bottle of rum]);
    price2 = mall_price($item[lime]);
    checked = true;
  }
  if (it == $item[sangria del diablo] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item[boxed wine]);
    price2 = mall_price($item[cherry]);
    checked = true;
  }
  if (it == $item[vesper] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item[bottle of vodka]);
    price2 = mall_price($item[jumbo olive]);
    checked = true;
  }
  if (checked)
  {
    if ((price1 <= 1) || (price2 <= 1))
      return 0;
    int bar = 0;
    if (!have_bartender())
    {
      bar = mall_price($item[bartender-in-the-box]);
    }
    return (price1 + (price2 * 2) + bar);
  }
  return startprice;
}

setvar("eatdrink_maxAge", "2.0");
//Does not include pull costs - that's added in the final calculation
int effective_price(item it, boolean inventoried)
{
  int price = 0;
  if (!is_tradeable(it) && npc_price(it) == 0 && is_displayable(it) && it.seller == $coinmaster[none] && daily_special() != it)
  {
    if (it == $item[worthless item])
    {
      int tokenprice = ((14 - get_starter_items()) * 50) + (item_amount($item[hermit permit]) > 0 ? 0 : 100);
      vprint("HERMIT GUY:"+it.seller+" = "+tokenprice,8);
      return tokenprice;
    }
    vprint("NONTRADEABLE: "+it,8);
    return PRICE_OF_NONTRADEABLES;
  }
  if (special_items contains it)
  {
    price = special_prices(it, price);
    vprint("SPECIAL   :"+it+" = "+price,8);
  }
  else
  { 
    if (brokenprice contains it)
    {
      vprint("Apparantly there was a previous problem buying "+it+" so the new price is "+brokenprice[it],3);
      return brokenprice[it];
    }
    if (it.seller != $coinmaster[none] && it.seller.is_accessible())
    {
      int tokenprice;
      int itemprice;
      if (npc_price(it) > 0)
      {
        itemprice = npc_price(it);
        if (daily_special() == it && abs(autosell_price(it)) * 3 < itemprice)
        {
          itemprice = abs(autosell_price(it)) * 3;
          vprint("DAILY ITEM:"+it+" = "+itemprice,8);
        }
        else vprint("NPC STORES:"+it+" = "+itemprice,8);
      }
      else if (daily_special() == it)
      {
        itemprice = abs(autosell_price(it)) * 3;
        vprint("DAILY ITEM:"+it+" = "+itemprice,8);
      }
      else if (!is_tradeable(it))
      {
        if (!is_displayable(it))
        {
          itemprice = PRICE_OF_QUESTITEMS;
          vprint("QUEST ITEM:"+it+" = "+itemprice,8);
        }
        else
        {
          itemprice = PRICE_OF_NONTRADEABLES;      
          vprint("NONTRADEABLE:"+it+" = "+itemprice,8);
        }
      }
    //We'll update only if the pricing data is >maxAge days out of date.
    //Note that this is updated earlier in the script from a server so
    //you should have fresh prices.
      else if (historical_age(it) > to_float(vars["eatdrink_maxAge"]))
      {
        itemprice = mall_price(it);
        vprint("STALE     :"+it+" = "+itemprice,8);
      }
      else
      {
        itemprice = historical_price(it);
        if (itemprice == 0)
        {
          itemprice = mall_price(it);
          vprint("ERROR     :"+it+" = "+itemprice,8);
        }
        else
          vprint("HISTORICAL:"+it+" = "+itemprice,8);
      }
      if (it.seller.item == $item[none])
      {
        tokenprice = 0;
        vprint("NULL TOKEN:"+it.seller,8);
      }
      else if (it.seller == $coinmaster[Hermit])
      {
        tokenprice = ((14 - get_starter_items()) * 50) + (item_amount($item[hermit permit]) > 0 ? 0 : 100);
        vprint("HERMIT GUY:"+it.seller+" = "+tokenprice,8);
      }
      else if (npc_price(it.seller.item) > 0)
      {
        tokenprice = npc_price(it.seller.item);
        vprint("NPC STORES:"+it.seller.item+" = "+tokenprice,8);
      }
      else if (!is_tradeable(it.seller.item))
      {
        if (!is_displayable(it.seller.item))
        {
          tokenprice = PRICE_OF_QUESTITEMS;
          vprint("QUEST ITEM:"+it.seller.item+" = "+tokenprice,8);
        }
        else
        {
          tokenprice = PRICE_OF_NONTRADEABLES;      
          vprint("NONTRADEABLE:"+it.seller.item+" = "+tokenprice,8);
        }
      }
    //We'll update only if the pricing data is >maxAge days out of date.
    //Note that this is updated earlier in the script from a server so
    //you should have fresh prices.
      else if (historical_age(it.seller.item) > to_float(vars["eatdrink_maxAge"]))
      {
        tokenprice = mall_price(it.seller.item);
        vprint("STALE     :"+it.seller.item+" = "+tokenprice,8);
      }
      else
      {
        tokenprice = historical_price(it.seller.item);
        if (tokenprice == 0)
        {
          tokenprice = mall_price(it.seller.item);
          vprint("ERROR     :"+it.seller.item+" = "+tokenprice,8);
        }
        else
          vprint("HISTORICAL:"+it.seller.item+" = "+tokenprice,8);
      }
      if (itemprice < 2 && tokenprice < 2)
      {
        vprint("NONTRADEABLE: "+it,8);
        return PRICE_OF_NONTRADEABLES;      
      }
      else if (itemprice < 2)
      {
        price = tokenprice * sell_price(it.seller, it);
        vprint("COINMASTER:"+it+" = "+price,8);
      }
      else if (tokenprice < 2)
      {
        price = itemprice;
        vprint("OTHER WAYS:"+it+" = "+price,8);
      }
      else
      {
        if ((tokenprice * sell_price(it.seller, it)) < itemprice)
        {
          price = tokenprice * sell_price(it.seller, it);
          vprint("COINMASTER:"+it+" = "+price,8);
        }
        else
        {
          price = itemprice;
          vprint("OTHER WAYS:"+it+" = "+price,8);
        }
      }
    }
    else if (npc_price(it) > 0)
    {
      price = npc_price(it);
      if (daily_special() == it && abs(autosell_price(it)) * 3 < price)
      {
        price = abs(autosell_price(it)) * 3;
        vprint("DAILY ITEM:"+it+" = "+price,8);
      }
      else vprint("NPC STORES:"+it+" = "+price,8);
    }
    else if (daily_special() == it)
    {
      price = abs(autosell_price(it)) * 3;
      if (price == 0)
      {
         if (it.inebriety > 0) price = to_int(excise(visit_url("cafe.php?cafeid=2"), daily_special().to_string()+" (","Meat"));
         else price = to_int(excise(visit_url("cafe.php?cafeid=1"), daily_special().to_string()+" (","Meat"));
      }
      vprint("DAILY ITEM:"+it+" = "+price,8);
    }
    else if (!is_tradeable(it))
    {
      price = PRICE_OF_QUESTITEMS;
      vprint("QUEST ITEM:"+it+" = "+price,8);
    }
  //We'll update only if the pricing data is >maxAge days out of date.
  //Note that this is updated earlier in the script from a server so
  //you should have fresh prices.
    else if (historical_age(it) > to_float(vars["eatdrink_maxAge"]))
    {
      if (AUTOSELL_RONIN && get_ronin() && inventoried && autosell_price(it) > 0) price = autosell_price(it);
      else price = mall_price(it);
      vprint("STALE     :"+it+" = "+price,8);
    }
    else
    {
      if (AUTOSELL_RONIN && get_ronin() && inventoried && autosell_price(it) > 0) price = autosell_price(it);
      else price = historical_price(it);
      if (price == 0)
      {
        price = mall_price(it);
        vprint("ERROR     :"+it+" = "+price,8);
      }
      else
        vprint("HISTORICAL:"+it+" = "+price,8);
    }
  }
  if ((price == 0) || (price == -1) || (price == 1))
  {
    price = PRICE_OF_UNKNOWNS;
    vprint("UNKNOWN:      "+it,8);
  }
  return price;
}

int effective_price(con_rec con)
{
  if (con.have > 0 && !CONSIDER_COST_WHEN_OWNED)
    return 0; //If you have it & you don't care about price
  if (con.have < 1 && !EAT_COINMASTER && !EAT_SHOP && !EAT_MALL)
    return 0; //If you don't have any but you can't shop
  return effective_price(con.it, (con.have > 0));
}

boolean unknown_recipe(item it)
{
  return (get_property("unknownRecipe"+it.to_int()).to_boolean());
}

boolean have_ingredients(item newitem, int count, int [item] stack, int loop)
{
  int [item] fullyworking;
  int originalmeat = makeusedmeat;

  makeusedmeat = 0;  

  if (loop == 0)
  {
    foreach i in grub
      stack[grub[i].it] -= grub[i].using;
  }
  else if (loop > LOOP_COUNT) return false;

  foreach i,c in get_ingredients(newitem)
    stack[i] -= c * count;

  foreach i in stack
    fullyworking[i] = stack[i];

  foreach i in stack
  {
    if (i == $item[boris's key] || i == $item[jarlsberg's key] ||
        i == $item[sneaky pete's key] || i == $item[tiny plastic sword])
    {
      if (item_amount(i) > 0 || (USE_CLOSET && closet_amount(i) > 0))
        stack[i] = 0;
    }
    if (stack[i] < 0 && item_amount(i) > 0)
      stack[i] += item_amount(i);
    if (stack[i] < 0 && USE_CLOSET && closet_amount(i) > 0)
      stack[i] += closet_amount(i);
    if (EAT_COINMASTER && i.seller != $coinmaster[none] && effective_price(i.seller.item, false) > 0 && i.seller.is_accessible())
    {
      int coinprice = effective_price(i.seller.item, false) * sell_price(i.seller, i);
      while (stack[i] < 0 && get_meat(1) >= coinprice)
      {
        stack[i] += 1;
        makeusedmeat += coinprice;
      }
    }
    int npcprice = npc_price(i);
    while (stack[i] < 0 && EAT_SHOP && npcprice > 0 && get_meat(1) >= npcprice)
    {
      stack[i] += 1;
      makeusedmeat += npcprice;
    }
    int effective = effective_price(i, false);
    while (stack[i] < 0 && EAT_MALL && !get_ronin() && npcprice == 0 && get_meat(1) >= effective)
    {
      stack[i] += 1;
      makeusedmeat += effective;
    }
    if (stack[i] < 0 && i != newitem && EAT_MAKE && !unknown_recipe(i) && count(get_ingredients(i)) > 0)
    {
      int [item] trymake;
      foreach j in fullyworking
      {
        trymake[j] = fullyworking[j];
        if (i == j) trymake[j] -= stack[i];
      }
      if (have_ingredients(i, (stack[i] * -1), trymake, loop+1))
        stack[i] = 0;
    }
    if (stack[i] < 0)
    {
      makeusedmeat = originalmeat;
      return false;
    }
  }
  return true;
}

int [item] add_ingredients(item newitem, int count, int [item] stack, int loop)
{
  int [item] working;
  int [item] fullyworking;

  if (loop == 0)
  {
    makeveryusedmeat = 0;
    foreach i in grub
      working[grub[i].it] -= grub[i].using;
    foreach i,c in stack
    {
      working[i] += c;
      stack[i] = 0;
    }
  }
  else if (loop > LOOP_COUNT) return stack;

  foreach i,c in get_ingredients(newitem)
    working[i] -= c * count;

  foreach i in working
  {
    fullyworking[i] = working[i];
    if (working[i] >= 0) continue;
    usingMake[i] = working[i] * -1;
    if (i == $item[boris's key] || i == $item[jarlsberg's key] ||
        i == $item[sneaky pete's key] || i == $item[tiny plastic sword])
    {
      if (item_amount(i) > 0 || (USE_CLOSET && closet_amount(i) > 0))
        stack[i] = -1;
    }
    else
    {
      if (working[i] < 0 && item_amount(i) > 0)
      {
        stack[i] += (working[i] * -1) < item_amount(i) ? working[i] : (item_amount(i) * -1);
        working[i] += item_amount(i);
      }
      if (working[i] < 0 && USE_CLOSET && closet_amount(i) > 0)
      {
        stack[i] += (working[i] * -1) < closet_amount(i) ? working[i] : (closet_amount(i) * -1);
        working[i] += closet_amount(i);
      }
      if (EAT_COINMASTER && i.seller != $coinmaster[none] && effective_price(i.seller.item, false) > 0 && i.seller.is_accessible())
      {
        int coinprice = effective_price(i.seller.item, false) * sell_price(i.seller, i);
        while (working[i] < 0 && get_meat(1) >= coinprice)
        {
          stack[i] -= 1;
          working[i] += 1;
          makeveryusedmeat += coinprice;
        }
      }
      int npcprice = npc_price(i);
      while (working[i] < 0 && EAT_SHOP && npcprice > 0 && get_meat(1) >= npcprice)
      {
        stack[i] -= 1;
        working[i] += 1;
        makeveryusedmeat += npcprice;
      }
      int effective = effective_price(i, false);
      while (working[i] < 0 && EAT_MALL && !get_ronin() && npcprice == 0 && get_meat(1) >= effective)
      {
        stack[i] -= 1;
        working[i] += 1;
        makeveryusedmeat += effective;
      }
      if (working[i] < 0 && i != newitem && EAT_MAKE && !unknown_recipe(i) && count(get_ingredients(i)) > 0)
      {
        int [item] trymake;
        foreach j in fullyworking
        {
          trymake[j] = fullyworking[j];
          if (i == j) trymake[j] -= working[i];
        }
        foreach ni,nc in get_ingredients(i) { stack[ni] += (nc * working[i]); }
        working[i] = 0;
      }
    }
  }
  return stack;
}

boolean collect_ingredients(item newitem, int count, int [item] stack, int loop)
{
  int [item] working;

  if (loop == 0)
  {
    foreach i in grub
      working[grub[i].it] += grub[i].using;
    foreach i,c in stack
      working[i] -= c;
  }
  else if (loop > LOOP_COUNT) return false;

  foreach i,c in get_ingredients(newitem)
    working[i] += c * count;

  foreach i in working
  {
    if (i == $item[boris's key] || i == $item[jarlsberg's key] ||
        i == $item[sneaky pete's key] || i == $item[tiny plastic sword])
    {
      if (item_amount(i) > 0 || (USE_CLOSET && closet_amount(i) > 0))
        working[i] = 0;
    }
    if (working[i] > 0 && item_amount(i) > 0)
      working[i] -= item_amount(i);
    if (working[i] > 0 && USE_CLOSET && closet_amount(i) > 0)
      if (take_closet(closet_amount(i), i)) working[i] -= closet_amount(i);
    if (EAT_COINMASTER && i.seller != $coinmaster[none] && effective_price(i.seller.item, false) > 0 && i.seller.is_accessible())
    {
      int coinprice = effective_price(i.seller.item, false) * sell_price(i.seller, i);
      while (working[i] < 0 && get_meat(1) >= coinprice)
        if (create(1, i)) working[i] -= 1;
    }
    int npcprice = npc_price(i);
    while (working[i] > 0 && EAT_SHOP && npcprice > 0 && get_meat(2) >= npcprice)
      if (buy(1, i)) working[i] -= 1;
    int effective = effective_price(i, false);
    while (working[i] > 0 && EAT_MALL && !get_ronin() && npcprice == 0 && get_meat(2) >= effective)
      if (buy(1, i)) working[i] -= 1;
    if (working[i] > 0 && EAT_MAKE && count(get_ingredients(i)) > 0 && collect_ingredients(i, working[i], working, loop+1))
      if (create(working[i], i)) working[i] = 0;
    if (working[i] > 0)
      return false;
  }
  return true;
}

float drink_adjust(float adj_adv, float adj_con)
{
  if (simode) return adj_adv + adj_con;
  return adj_adv + min(have_effect($effect[ode to booze]), adj_con);
}

float food_adjust(float adj_adv, float adj_con)
{
  if (SIM_CONSUME)
  {
    float adv_total = adj_adv;
    if (simmilk) adv_total += adj_con;
    if (simlunch) adv_total += adj_con;
    if (have_skill($skill[gourmand])) adv_total += adj_con;
    if (have_skill($skill[neurogourmet])) adv_total += adj_con;
    return adv_total;
  }
  return adj_adv + min(have_effect($effect[got milk]), adj_con) + min(have_effect($effect[song of the glorious lunch]), adj_con) + (have_skill($skill[gourmand]) ? adj_con : 0);
}

boolean get_on_budget(int totalquantity, item it, int maxprice) 
{
   if (to_string(it) == "")
   {
     vprint("No item requested; calling that success",3);
     return true;
   }
   int quantity = totalquantity - item_amount(it);
   if (quantity < 1)
   {
     vprint("Already got that many, calling that success",3);
     return true;
   }
   int budget = quantity * maxprice;
   int startmeat = get_meat(2);
   vprint("budgeting "+budget+" for "+quantity+" additional "+it+". You have "+startmeat+" meat. You have "+item_amount(it)+" in inventory already.",3);
   if (startmeat > budget)
   {
     vprint("Looks like you have enough meat to buy it",3);
     int got = item_amount(it);
     vprint("You have "+got+" right now",3);
     int temp = buy(quantity, it, budget);
     vprint("You now have a total of "+item_amount(it),3);
     got = item_amount(it) - got;
     vprint("Purchased "+got+" "+it+" for "+(startmeat-get_meat(2))+" meat.",3);
     if (got < quantity)
     {
       vprint("Tried to get "+quantity+" "+it+" but got "+got+". Pricing error.",3); 
       if (brokenprice contains it)
       {
         vprint("Seen a problem with this one before at a price of "+brokenprice[it]+".",3);
       }
       vprint("Setting new effective price to "+BUDGET,3);
       brokenprice[it] = BUDGET;
     }
   }
   else
   {
     vprint("That doesn't appear to be enough meat, but maybe it's cheap (or maybe you've got some in the closet). Either way, let's try.",3);
     boolean retrieve_return_value = retrieve_item(quantity, it);
     vprint("retrieve_item returned "+retrieve_return_value+" and you have "+item_amount(it)+" of the "+quantity+" you requested. You have "+get_meat(2)+" meat in inventory now.",3);
   }
   return (quantity == item_amount(it));
}

boolean milk_do_body_good(int fullness, boolean check)
{
  int pullcost = (USE_STORAGE && get_ronin() && pulls_remaining() > 0) ? COST_OF_PULL : 0;
  int potionlength = 10 + (have_skill($skill[impetuous sauciness]) ? 5 : 0) + (my_class() == $class[sauceror] ? 5 : 0);
  int milkprice = mall_price($item[milk of magnesium]);
  float milkvalue = ((SIM_CONSUME || potionlength > fullness) ? fullness : potionlength) * VALUE_OF_ADVENTURE;
  boolean shouldgetmilk = (milkvalue > (milkprice + pullcost));
  int lastprice = 0;
  int displayfullness = fullness;

  // keep trying until you get it, you can't get it, or it's a bad value
  while (shouldgetmilk && !get_milk(fullness) && wants_milk)
  {
#    if (SIM_CONSUME && (item_amount($item[milk of magnesium]) > 0 || (USE_CLOSET && closet_amount($item[milk of magnesium]) > 0) || (EAT_MAKE && creatable_amount($item[milk of magnesium]) > 0) || (USE_STORAGE && (pulls_remaining() > 0) && storage_amount($item[milk of magnesium]) > 0) || (EAT_MALL && !get_ronin() && simmeat >= milkprice)))
    if (check && (item_amount($item[milk of magnesium]) > 0 || (USE_CLOSET && closet_amount($item[milk of magnesium]) > 0) || (EAT_MAKE && creatable_amount($item[milk of magnesium]) > 0) || (USE_STORAGE && !get_ronin() && storage_amount($item[milk of magnesium]) > 0) || (EAT_MALL && !get_ronin() && simmeat >= milkprice)))
      return true;
    else if (SIM_CONSUME && (item_amount($item[milk of magnesium]) > 0 || (USE_CLOSET && closet_amount($item[milk of magnesium]) > 0) || (EAT_MAKE && creatable_amount($item[milk of magnesium]) > 0) || (USE_STORAGE && !get_ronin() && storage_amount($item[milk of magnesium]) > 0) || (EAT_MALL && !get_ronin() && simmeat >= milkprice)))
    {
      simmeat -= milkprice;
      simmilk = true;
      summarize("0: <b>milk of magnesium</b> price: "+milkprice+" value: "
                + to_int(milkvalue - milkprice - pullcost));
    }
    else if (!SIM_CONSUME && !check)
    {
      lastprice = milkprice;
      if (item_amount($item[milk of magnesium]) < 1)
        getone($item[milk of magnesium], milkprice);
      if (item_amount($item[milk of magnesium]) > 0)
      {
        use(1, $item[milk of magnesium]);
        int actualprice = mall_price($item[milk of magnesium]); 
        summarize("0: <b>milk of magnesium</b> price: "+actualprice+" value: "
                  + (milkvalue - actualprice - pullcost));
      }
      else
        wants_milk = false;
      milkprice = mall_price($item[milk of magnesium]);
      displayfullness -= potionlength;
      milkvalue = (potionlength > displayfullness ? displayfullness : potionlength) * VALUE_OF_ADVENTURE;
      shouldgetmilk = (milkvalue > (milkprice + pullcost));
    }
    else wants_milk = false;
  }
  return simmilk || wants_milk;
}

boolean lasagna_do_garfield_good(int lasagnas, boolean check)
{
  int pullcost = (USE_STORAGE && get_ronin() && pulls_remaining() > 0) ? COST_OF_PULL : 0;
  int garprice = mall_price($item[potion of the field gar]);
  float garvalue = (5 * lasagnas) * VALUE_OF_ADVENTURE;
  boolean shouldgar = (garvalue > (garprice + pullcost)) && (numeric_modifier($item[tuesday's ruby], "muscle percent") != 5.0);

  // keep trying until you get it, you can't get it, or it's a bad value
  if (shouldgar && !get_gar() && wants_lasagna)
  {
    if (check && (item_amount($item[potion of the field gar]) > 0 || (USE_CLOSET && closet_amount($item[potion of the field gar]) > 0) || (EAT_MAKE && creatable_amount($item[potion of the field gar]) > 0) || (USE_STORAGE && !get_ronin() && storage_amount($item[potion of the field gar]) > 0) || (EAT_MALL && !get_ronin() && simmeat >= garprice)))
      return true;
    else if (SIM_CONSUME && (item_amount($item[potion of the field gar]) > 0 || (USE_CLOSET && closet_amount($item[potion of the field gar]) > 0) || (EAT_MAKE && creatable_amount($item[potion of the field gar]) > 0) || (USE_STORAGE && !get_ronin() && storage_amount($item[potion of the field gar]) > 0) || (EAT_MALL && !get_ronin() && simmeat >= garprice)))
    {
      simmeat -= garprice;
      simgar = true;
      summarize("0: <b>potion of the field gar</b> price: "+garprice+" value: "
                + to_int(garvalue - garprice - pullcost));
    }
    else if (!SIM_CONSUME && !check)
    {
      if (item_amount($item[potion of the field gar]) < 1)
        getone($item[potion of the field gar], garprice);
      if (item_amount($item[potion of the field gar]) > 0)
      {
        use(1, $item[potion of the field gar]);
        int actualprice = mall_price($item[potion of the field gar]); 
        summarize("0: <b>potion of the field gar</b> price: "+actualprice+" value: "
                  + (garvalue - actualprice - pullcost));
      }
      else
        wants_lasagna = false;
      garprice = mall_price($item[potion of the field gar]);
    }
    else wants_lasagna = false;
  }
  else wants_lasagna = false;
  return simgar || wants_lasagna;
}

boolean lunch_do_body_good(int fullness, boolean check)
{
  int manacost = get_property("_meatpermp").to_int();
  int shoutvalue = have_skill($skill[Good Singing Voice]) ? 10 : 5;
  int lunchvalue = ((SIM_CONSUME || shoutvalue > fullness) ? fullness : shoutvalue) * VALUE_OF_ADVENTURE;

  if (manacost == 0)
    manacost = 17;

  if (my_class() != $class[Avatar of Boris])
  {
    vprint("Skipping Song of the Glorious Lunch because you aren't Boris.",9);
    wants_lunch = false;
  }
  else
  {
    int nextcost = max(0, SIM_CONSUME ? ((mp_cost($skill[song of the glorious lunch]) * ceil(to_float(fullness) / shoutvalue)) - my_mp()) : (mp_cost($skill[song of the glorious lunch]) - my_mp())) * manacost;
    boolean shouldshout = my_maxmp() >= mp_cost($skill[song of the glorious lunch]);
    int displayfullness = fullness;

    // keep trying until you get it, you can't get it, or it's a bad value
    while (shouldshout && !get_lunch(fullness) && wants_lunch && nextcost <= get_meat(1) && lunchvalue > nextcost)
    {
      if (check)
        return true;
      else if (SIM_CONSUME)
      {
        simmeat -= nextcost;
        simlunch = true;
        summarize("0: <b>Song of the Glorious Lunch</b> price: "+nextcost+" value: "
                  + (lunchvalue - nextcost));
      }
      else if (!SIM_CONSUME)
      {
        summarize("0: <b>Song of the Glorious Lunch</b> price: "+nextcost+" value: "
                  + (lunchvalue - nextcost));
        if (!use_skill( 1 , $skill[Song of the Glorious Lunch]))
          wants_lunch = false;
        nextcost = max(0, mp_cost($skill[song of the glorious lunch]) - my_mp()) * manacost;
        displayfullness -= shoutvalue;
        lunchvalue = (shoutvalue > displayfullness ? displayfullness : shoutvalue) * VALUE_OF_ADVENTURE;
      }
      else wants_lunch = false;
    }
  }
  return simlunch || wants_lunch;
}

boolean maxed_songs()
{
  int max_song = (boolean_modifier("Four Songs") ? 4 : 3) + (boolean_modifier("Additional Song") ? 1 : 0);
  int current_at = 0;
  for song from 6001 to 6040
  {
    if (song == 6025)
      continue;  // Fuzzy matching leads to Singer's Faithful Ocelot
    if (song.to_skill().to_effect().have_effect() > 0)
      current_at += 1;
  }
  return current_at >= max_song;
}

boolean cast_ode() 
{
  if (have_effect($effect[ode to booze]) < 1 && maxed_songs())
  {
    maximize("-tie, Four Songs, Additional Song", false);
    if (maxed_songs() && ode_shrug && get_accordion() > 0)
    {
      int cheapestsong = 0;
      int cheapestvalue = 0;
      for song from 6001 to 6040
      {
        if (song == 6025)
          continue;  // Fuzzy matching leads to Singer's Faithful Ocelot
        if (song.to_skill().to_effect().have_effect() > 0 && have_skill(song.to_skill()))
          if (cheapestsong == 0 || cheapestvalue > (song.to_skill().mp_cost() * song.to_skill().to_effect().have_effect()))
          {
            cheapestsong = song;
            cheapestvalue = song.to_skill().mp_cost() * song.to_skill().to_effect().have_effect();
          }
      }
      if (cheapestsong > 0)
        cli_execute("uneffect "+cheapestsong.to_skill().to_effect());
    }
    if (maxed_songs())
    {
      vprint("Too many AT songs to cast Ode to Booze", 3);
      return false;
    }
  }
  if (have_skill($skill[the ode to booze]))
  {
    if( my_mp() < mp_cost($skill[the ode to booze]))
    {
      restore_mp(mp_cost($skill[the ode to booze]));
      if (my_mp() < mp_cost($skill[the ode to booze]))
      {
        vprint("Can't cast Ode to Booze due to lack of MP!", 3);
        return false;
      }
    }
    use_skill(1, $skill[the ode to booze]);
    if (have_effect($effect[ode to booze]) < 1)
      return false;
    else return true;
  }
  return false;
}

boolean ode_do_liver_good(int drink, boolean check)
{
  int manacost = get_property("_meatpermp").to_int();
  int accordion = get_accordion();
  int odevalue = ((SIM_CONSUME || accordion > drink) ? drink : accordion) * VALUE_OF_ADVENTURE;

  if (manacost == 0)
    manacost = 17;

  if (accordion == 0)
  {
    vprint("Skipping Ode to Booze because you don't have an accordion.",3);
    wants_ode = false;
  }
  else
  {
    int nextcost = max(0, SIM_CONSUME ? ((mp_cost($skill[the ode to booze]) * ceil(to_float(drink) / accordion)) - my_mp()) : (mp_cost($skill[the ode to booze]) - my_mp())) * manacost;
    boolean shouldgetode = my_maxmp() >= mp_cost($skill[the ode to booze]);
    int displaydrink = drink;

    // keep trying until you get it, you can't get it, or it's a bad value
    while (shouldgetode && !get_ode(drink) && wants_ode && nextcost <= get_meat(1) && odevalue > nextcost)
    {
      if (check)
        return true;
      else if (SIM_CONSUME)
      {
        simmeat -= nextcost;
        simode = true;
        summarize("0: <b>Ode to Booze</b> price: "+nextcost+" value: "
                  + (odevalue - nextcost));
      }
      else if (!SIM_CONSUME)
      {
        summarize("0: <b>Ode to Booze</b> price: "+nextcost+" value: "
                  + (odevalue - nextcost));
        if (!cast_ode())
          wants_ode = false;
        nextcost = max(0, mp_cost($skill[the ode to booze]) - my_mp()) * manacost;
        displaydrink -= accordion;
        odevalue = (accordion > displaydrink ? displaydrink : accordion) * VALUE_OF_ADVENTURE;
      }
      else wants_ode = false;
    }
  }
  return simode || wants_ode;
}

con_rec availability(con_rec con)
{
  con.have = item_amount(con.it) - con.using - usingMake[con.it];
  con.mustPull = false;
  con.mustMake = false;
  if (USE_CLOSET)
    con.have += closet_amount(con.it);
  //Don't make your digital key into pie!  Ask me how I found this bug...
  //Or your star key into a pie!
  if (EAT_MAKE && !unknown_recipe(con.it) && (con.it != $item[digital key lime pie] && con.it != $item[star key lime pie]) && count(get_ingredients(con.it)) > 0 && (creatable_amount(con.it) > 0 || (EAT_ACCURATE && get_ronin())))
  {
    if (EAT_ACCURATE && get_ronin() && (con.it != $item[digital key lime pie] && con.it != $item[star key lime pie]) && count(get_ingredients(con.it)) > 0)
    {
      int createamt = 0;
      int[item] ings;
      if (SIM_CONSUME) foreach ingred,x in simingredients { ings[ingred] += x; }
      foreach ingred,x in ingredients { ings[ingred] += x; }
      while (have_ingredients(con.it, (createamt + 1), ings, 0) && createamt + con.have < 1)
        createamt += 1;
      con.mustMake = (con.have <= 0) && (createamt > 0) && 
                     !(brokenmake contains con.it) && ((con.have + createamt) > 0);
      con.have += createamt;
    }
    else
    {
      int createamt = creatable_amount(con.it);
      con.mustMake = (con.have <= 0) && (createamt > 0) && 
                     !(brokenmake contains con.it);
      con.have += createamt;
    }
  }
#  if (USE_STORAGE && (pulls_remaining() > 0))
  if (USE_STORAGE && !get_ronin())
  {
    int storageamt = storage_amount(con.it);
    if (get_ronin())      
      if (storageamt > pulls_remaining())
        storageamt = pulls_remaining();
    con.mustPull = (con.have <= 0) && (storageamt > 0) && 
                   !(brokenpull contains con.it) && ((con.have + storageamt) > 0);
    con.have += storageamt;
  }
  return con;
}

con_rec set_price(con_rec con)
{
  con = availability(con);
  boolean available = con.have > 0;
  con.price = effective_price(con);
  con.canDaily = false;
  con.canShop = false;
  con.mustDaily = false;
  con.mustShop = false;
  con.mustMall = false;
  con.mustCoinmaster = false;
  if (fail contains con.it)
  {
    available = false;
    return con;
  }
  if (EAT_SHOP && npc_price(con.it) > 0)
  {
    if (!available)
    {
      available = true;
      con.mustShop = true;
    }
    con.canShop = true;
  }
  if (EAT_SHOP && daily_special() == con.it)
  {
    if (!available)
    {
      available = true;
      con.mustDaily = true;
    }
    con.canDaily = true;
  }
  if (EAT_MALL && !available && !get_ronin() &&
      con.price != PRICE_OF_NONTRADEABLES && is_tradeable(con.it))
  {
    available = true;
    con.mustMall = true;
  }
  if (EAT_COINMASTER && !available && con.it.seller != $coinmaster[none] && con.it.seller.is_accessible() &&
      con.price != PRICE_OF_NONTRADEABLES && (con.it.seller.available_tokens > sell_price(con.it.seller, con.it) || (EAT_MALL && effective_price(con.it.seller.item, false) > 0)))
  {
    available = true;
    con.mustCoinmaster = true;
  }
  if (!available)
  {
    if (favorites contains con.it)
    {
      vprint("Favorite "+con.it+" appears unavailable given budget, EAT_SHOP and EAT_MALL variable settings, ronin status, and/or mall price.",3);
    }
  }
  return con;
}

void set_prices()
{
  foreach i in grub
  {
    grub[i] = set_price(grub[i]);
    if (grub[i].have < 1 && !grub[i].mustShop && !grub[i].mustDaily && !grub[i].mustMall && !grub[i].mustCoinmaster) remove grub[i];
  }
}

boolean mojogiveup = false;
void filter_your_mojo(con_rec baseline)
{
  item mf = $item[mojo filter];
  con_rec con_mf; //create a mojo filter consumable record
  con_mf.it = mf;
  con_mf = availability(con_mf); //get its availability
  con_mf.price = effective_price(con_mf); //price the filter
  //Assume your last consumable is representative of what you'd get. 
  //"value" already is normalized to represent the value from 1 adventure.
  boolean shouldgetmojo = (baseline.value >= con_mf.price);
  vprint("Spleen value is "+to_int(baseline.value)+"; mojo filter to get it costs "+con_mf.price,3);
  int lastprice = 0;
  int got = item_amount(mf);
// Should do:keep trying until you get it, you can't get it, or it's a bad value
  int mojomeat = get_meat(2);
  if (shouldgetmojo && SIM_CONSUME && simmeat >= 3*con_mf.price)
  {
    simmeat -= 3 * con_mf.price;
    simspleen -= 3;
    summarize("X: <b>3 mojo filters</b> price: "+(con_mf.price*3)+" (total)");
    mojogiveup = true;
  }
  else if (shouldgetmojo && !SIM_CONSUME)
  {
    int lasttry = 0;
    int mojoused = 1;
    boolean gotone;
    while (!mojogiveup && mojomeat > con_mf.price)
    {
      gotone = false;
      getone(mf, con_mf.price);
      if (item_amount(mf) > 0)
      {
        if (use(1, mf))
        {
          summarize("M"+mojoused+": <b>mojo filter</b> price: "
                    +(mojomeat-get_meat(2)));
          mojoused += 1;
          gotone = true;
        }
      }
      else
      {
        mojogiveup = true;
        break;
      }
      mojomeat = get_meat(2);
      lasttry = con_mf.price;
      if (brokenprice contains mf)
        con_mf.price = max(con_mf.price, brokenprice[mf]);
      else 
        con_mf.price = mall_price(mf);
      mojogiveup = (!gotone && (lasttry == con_mf.price)) || (mojoused == 3);
    }
  }
}

// Chocolate processing thanks to Bale at http://kolmafia.us/showthread.php?4202-The-Unofficial-Ascend.ash-support-thread.&p=38439&viewfull=1#post38439

class [item] class_choco;
    class_choco [$item[chocolate seal-clubbing club]] = $class[Seal Clubber];
    class_choco [$item[chocolate turtle totem]] = $class[Turtle Tamer];
    class_choco [$item[chocolate pasta spoon]] = $class[Pastamancer];
    class_choco [$item[chocolate saucepan]] = $class[Sauceror];
    class_choco [$item[chocolate disco ball]] = $class[Disco Bandit];
    class_choco [$item[chocolate stolen accordion]] = $class[Accordion Thief];

item reducechoc(item it) {
    if($item[vitachoconutriment capsule] == it)
        return $item[vitachoconutriment capsule];
    else if($item[chocolate cigar] == it)
        return $item[chocolate cigar];
    return $item[fancy chocolate];   // all other chocos track together
}

string choc_prop(item it) {
    return "eatdrink_ate_"+ substring(it.reducechoc(), 0, 5);
}
setvar(choc_prop($item[vitachoconutriment capsule]),gameday_to_string() + ":0"); 
setvar(choc_prop($item[chocolate cigar]),gameday_to_string() + ":0"); 
setvar(choc_prop($item[fancy chocolate]),gameday_to_string() + ":0"); 

int chocval(item it) {
    int choc_adv;
    switch(simchoc[it.reducechoc()]) {
    case 0:
        if(class_choco contains it)
            choc_adv = 3;
        else choc_adv = 5;
        break;
    case 1:
        if(class_choco contains it)
            choc_adv = 2;
        else choc_adv = 3;
        break;
    case 2:
        choc_adv = 1;
        break;
    default:
        choc_adv = 0;
    }
    if(choc_adv > 0 && class_choco contains it)
        if(class_choco[it] != my_class())
            choc_adv -= 1;
    return choc_adv;
}
int best(boolean speculative); // defined later
void get_choc() {
    //this is cheap, but I'm going to abuse simchoc to iterate over for the main loop here (irrespective of whether I'm simulating).
    simchoc[$item[vitachoconutriment capsule]] = 0;
    simchoc[$item[chocolate cigar]] = 0;
    simchoc[$item[fancy chocolate]] = 0; //note this encompasses all other chocos too
    string choc_prop;
    foreach key in simchoc {
        choc_prop = choc_prop(key);
        int mark = index_of(vars[choc_prop], ":");
        if(index_of(vars[choc_prop], ":") != -1 && substring(vars[choc_prop], 0, mark) == gameday_to_string())
            simchoc[key] = substring(vars[choc_prop], mark+1).to_int();
        else {
            vars[choc_prop] = gameday_to_string() + ":0";
            updatevars();
            simchoc[key] = 0;
        }
    }
            
    clear(grub);
    int choco_counter = 1;
    foreach key in $items[chocolate disco ball, chocolate pasta spoon, chocolate saucepan, 
      chocolate seal-clubbing club, chocolate stolen accordion, chocolate turtle totem, fancy chocolate,
      fancy but probably evil chocolate, fancy chocolate car, beet-flavored mr. mediocrebar,
      cabbage-flavored mr. mediocrebar, sweet-corn-flavored mr. mediocrebar] {
        grub[choco_counter].it = key;
        grub[choco_counter].consumptionGain.max = 1;
        grub[choco_counter].consumptionGain.min = 1;
        grub[choco_counter].type = "choc";
        grub[choco_counter] = set_price(grub[choco_counter]);
        choco_counter += 1;
    }
    con_rec vita;
        vita.it = $item[vitachoconutriment capsule];
        vita.consumptionGain.max = 1;
        vita.consumptionGain.min = 1;
        vita.type = "choc";
        vita = set_price(vita);
    con_rec cigar;
        cigar.it = $item[chocolate cigar];
        cigar.consumptionGain.max = 1;
        cigar.consumptionGain.min = 1;
        cigar.type = "choc";
        cigar = set_price(cigar);
    con_rec choc;
    int to_consume;
    foreach it in simchoc {  //will run twice
        if(it == $item[vitachoconutriment capsule])
            choc = vita;
        else if(it == $item[chocolate cigar])
            choc = cigar;
        boolean giveup = false;
        while(!giveup && simchoc[it] < 3) {
#        for i from 1 upto 3 {  // Chocolates can only be consumed thrice
            if(it == $item[fancy chocolate]) {
                boolean canfancy = false;
                foreach i in grub {
                    if (grub[i].have < 1 && !grub[i].mustShop && !grub[i].mustDaily && !grub[i].mustMall && !grub[i].mustCoinmaster) remove grub[i];
                    else canfancy = true;
                }
                if (!canfancy) {
                    giveup = true;
                    continue;
                }
                foreach i in grub {
                    grub[i].adv.max = chocval(grub[i].it); 
                    grub[i].adv.min = grub[i].adv.max;
                    grub[i].value = value(grub[i], false, false, false);
                }
                to_consume = best(false);
                if(to_consume == 0) {
                    choc.it = $item[none];
                    choc.value = 0;
                } else
                    choc = grub[to_consume];
            } else {
                choc.adv.max = chocval(choc.it);
                choc.adv.min = choc.adv.max;
                choc.value = value(choc, false, false, false);
            }
            if(choc.value > 0) {
                vprint("Attempting to consume a "+choc.it,6);
                string consume_entry = format_entry(choc);
                logprint(consume_entry);
                if(pause > 0 && !SIM_CONSUME) {
                    vprint("Waiting to consume...",3);
                    print(consume_entry);
                    wait(pause);
                }
                if(getone(choc.it, choc.price) && consumeone(choc, "choc", 0, 0)) {
                    summarize(ConsumptionReportIndex+": "+consume_entry);
                    ConsumptionReportIndex += 1;
                    simchoc[reducechoc(choc.it)] += 1;
                    if(!SIM_CONSUME) {
                        vars[choc_prop(choc.it)] = gameday_to_string() + ":" + simchoc[reducechoc(choc.it)];
                        updatevars();
                    }
                } else {
                    //Update the price, since your purchase may have failed
                    int oldprice = grub[to_consume].price;
                    grub[to_consume].price = effective_price(grub[to_consume]);
                    vprint(grub[to_consume].it+" price updated from "+oldprice+" to "+ grub[to_consume].price+".",3);
                    print("FAIL: "+consume_entry);
                    logprint("FAIL: "+consume_entry);
                    if (oldprice == grub[to_consume].price) {
                        vprint(grub[to_consume].it+" cannot currently be consumed. Skipping.",3);
                        fail[grub[to_consume].it] = true;
                        giveup = true;
                    }
                }
            } else {
                vprint("For "+choc.it+" value "+to_int(choc.value)+" is less than or equal to zero.",6);
                giveup = true;
            }
        }
    }
} 

string format_entry(con_rec entry)
{
  string output;
  output = "<b>"+entry.it+"</b>";
  output += " lev:"+entry.level;
  output += " gain:"+averange(entry.consumptionGain);
  if (my_class() == $class[Avatar of Jarlsberg] && entry.type == "food" && have_skill($skill[The Most Important Meal]) && get_fullness() == 0)
  {
    output += " adv:"+(averange(entry.adv)+(3*averange(entry.consumptionGain)));
    output += " musc:"+(averange(entry.muscle)*3);
    output += " myst:"+(averange(entry.mysticality)*3);
    output += " mox:"+(averange(entry.moxie)*3);
  }
  else
  {
    output += " adv:"+averange(entry.adv);
    output += " musc:"+averange(entry.muscle);
    output += " myst:"+averange(entry.mysticality);
    output += " mox:"+averange(entry.moxie);
  }
  output += " meat:"+entry.price;
  output += " own:"+entry.have;
//  output += " pull:"+entry.mustPull;
//  output += " make:"+entry.mustMake;
//  output += " mall:"+entry.mustMall;
//  output += " shop:"+entry.mustShop;
//  output += " daily:"+entry.mustDaily;
  if (my_class() == $class[Avatar of Jarlsberg] && entry.type == "food" && have_skill($skill[The Most Important Meal]) && get_fullness() == 0) output += " value:"+to_int(value(entry, false, true, false))/averange(entry.consumptionGain);
  else output += " value:"+to_int(entry.value);
  return output;
}

con_rec extra_items(con_rec con)
{
  if (con.it == $item[melted Jell-o shot])
  {
    con.muscle.min = 8.3;
    con.muscle.max = 13.3;
    con.moxie.min = 8.3;
    con.moxie.max = 13.3;
    con.mysticality.min = 8.3;
    con.mysticality.max = 13.3;
  }
  if ($items[fishy fish lasagna, gnat lasagna, long pork lasagna] contains con.it && lasagna_do_garfield_good((fullness_limit() - get_fullness()) / 3, true))
  {
    con.adv.min += 5;
    con.adv.max += 5;
  }
  if ($items[goat cheese pizza, incredible pizza, mushroom pizza, plain pizza, sausage pizza, slice of pizza, white chocolate and tomato pizza] contains con.it && have_skill($skill[pizza lover]))
  {
    con.adv.min += con.it.fullness;
    con.adv.max += con.it.fullness;
  }
  if (tuxworthy(con.it))
  {
    con.adv.min += 1;
    con.adv.max += 3;
  }
  return con;
}

boolean needakey = !can_interact() || get_level() < 13;

int special_values(item it, int startvalue)
{
  //Make these valuable so they get consumed
  if (it == $item[steel margarita] && item_amount(it) > 0)
    return MAXMEAT;
  if (it == $item[steel lasagna] && item_amount(it) > 0)
    return MAXMEAT;
  if (it == $item[steel-scented air freshener] && item_amount(it) > 0)
    return MAXMEAT;
  if (it == $item[spaghetti breakfast] && !get_property("_spaghettiBreakfast").to_boolean())
    return MAXMEAT;
  if ((PIE_PRIORITY) && needakey)
  {
    // if you don't have the keys, increase the value of their pies
    if (it == $item[boris's key lime pie])
      if (item_amount($item[boris's key]) == 0)
        return MAXMEAT-1;
    if (it == $item[sneaky pete's key lime pie])
      if (item_amount($item[sneaky pete's key]) == 0)
        return MAXMEAT-1;
    if (it == $item[jarlsberg's key lime pie])
      if (item_amount($item[jarlsberg's key]) == 0)
        return MAXMEAT-1;
  }
  return startvalue;
}

void update_from_mafia(string type)
{
  boolean skipnoodles = to_boolean(vars["eatdrink_noNoodles"]);
  int gc = 1;
  foreach it in $items[]
  {
    float gainadv;
    int totalcost;
    switch (type)
    {
      case "food":
        if ((special_values(it, 1) == 1 && get_quality(it) < MINIMUM_QUALITY) || (get_ronin() && (it == $item[digital key lime pie] || it == $item[star key lime pie]))) continue;
        if (it.inebriety > 0 || it.spleen > 0) continue;
        if (my_class() == $class[Zombie Master] && !it.plural.contains_text("brains")) continue;
        if (my_class() == $class[Avatar of Jarlsberg] && (it.to_int() < 6176 || it.to_int() > 6236)) continue;
        if (skipnoodles)
        {
           boolean badnoodles = false;
           if ($items[carob chunk noodles, dry noodles, evil noodles] contains it) badnoodles = true;
           foreach ing in get_ingredients(it) if ($items[dry noodles, evil noodles] contains ing) badnoodles = true;
           if (badnoodles) continue;
        }
        totalcost = it.fullness;
        gainadv = totalcost > 0 ? (averange(set_range(it.adventures)) / totalcost) : 0;
        break;
      case "booze":
        if ((special_values(it, 1) == 1 && get_quality(it) < MINIMUM_QUALITY)) continue;
        if (it.fullness > 0 || it.spleen > 0) continue;
        if (my_class() == $class[Avatar of Jarlsberg] && (it.to_int() < 6176 || it.to_int() > 6236)) continue;
        if (my_class() == $class[Avatar of Jarlsberg] && (it.to_int() < 6176 || it.to_int() > 6236)) continue;
        if (my_path() == "KOLHS" && !it.notes.contains_text("KOLHS") && special_values(it, 1) == 1) continue;
        totalcost = it.inebriety;
        gainadv = totalcost > 0 ? (averange(set_range(it.adventures)) / totalcost) : 0;
        break;
      case "spleen":
        if (it.fullness > 0 || it.inebriety > 0) continue;
        totalcost = it.spleen;
        gainadv = totalcost > 0 ? (averange(set_range(it.adventures)) / totalcost) : 0;
        break;
      default:
        continue;
    }
    if (it != $item[none] && be_good(it) && (special_values(it, 1) != 1 || gainadv >= MINIMUM_AVERAGE) && !var_check("eatdrink_avoid_"+ replace_string(to_string(it)," ","_")))
    {
      vprint("Importing mafia info for "+it,9);
      basegrub[gc].it = it;
      basegrub[gc].type = type;
      basegrub[gc].level = it.levelreq;
      basegrub[gc].consumptionGain.max = totalcost;
      basegrub[gc].consumptionGain.min = totalcost;
      basegrub[gc].adv = set_range(it.adventures);
      basegrub[gc].muscle = set_range(it.muscle);
      basegrub[gc].mysticality = set_range(it.mysticality);
      basegrub[gc].moxie = set_range(it.moxie);
      basegrub[gc].using = simitem[it];
      basegrub[gc] = extra_items(basegrub[gc]);
      gc += 1;
    }
    else
      vprint("Skipping "+it,9);
  }
}        

void update_using_mafia(string type)
{
  int gc = 1;
  foreach i in basegrub
  {
    if (basegrub[i].level <= get_level())
    {
      grub[gc].it = basegrub[i].it;
      grub[gc].type = basegrub[i].type;
      grub[gc].level = basegrub[i].level;
      grub[gc].consumptionGain.max = basegrub[i].consumptionGain.max;
      grub[gc].consumptionGain.min = basegrub[i].consumptionGain.min;
      grub[gc].adv = basegrub[i].adv;
      grub[gc].muscle = basegrub[i].muscle;
      grub[gc].mysticality = basegrub[i].mysticality;
      grub[gc].moxie = basegrub[i].moxie;
      grub[gc].using = basegrub[i].using;
      gc += 1;
    }
    else
    {
      if (favorites contains basegrub[i].it)
      {
        vprint("Favorite "+basegrub[i].it+" has a minimum required level of "+basegrub[i].level+". Filter level is "+get_level()+". Skipping.",3);
      }
      vprint(basegrub[i].it+" does not meet level requirements. Skipping.",9);
    }
  }
}        

//One time prep for value()
int musclescore = VALUE_OF_NONPRIME_STAT;
int moxiescore = VALUE_OF_NONPRIME_STAT;
int mysticalityscore = VALUE_OF_NONPRIME_STAT;
if (my_primestat() == $stat[muscle])
  musclescore = VALUE_OF_PRIME_STAT;
if (my_primestat() == $stat[moxie])
  moxiescore = VALUE_OF_PRIME_STAT;
if (my_primestat() == $stat[mysticality])
  mysticalityscore = VALUE_OF_PRIME_STAT;
float value(con_rec con, boolean overdrink, boolean breakfast, boolean speculating)
{
  boolean lunch;
  boolean milk;
  boolean ode;
  if (con.type == "food")
  {
    lunch = wants_lunch ? lunch_do_body_good(averange(con.consumptionGain), true) : false;
    milk = wants_milk ? milk_do_body_good(averange(con.consumptionGain), true) : false;
    ode = false;
  }
  else if (con.type == "booze")
  {
    lunch = false;
    milk = false;
    ode = wants_ode ? ode_do_liver_good(averange(con.consumptionGain), true) : false;
  }
  else if ((con.type == "spleen") || (con.type == "choc"))
  {
    lunch = false;
    milk = false;
    ode = false;
  }
  else 
    abort("Value: Invalid type! '"+con.type+"' on "+con.it);
  int full = averange(con.consumptionGain);
  float advscore = 0;
  float statscore = 0;
  float costscore = 0;
  //TODO: Munchies & Opossum
  if (full != 0)
  {
    advscore = (averange(con.adv) 
                  * VALUE_OF_ADVENTURE) / full;
    statscore = ((averange(con.muscle) * musclescore / full) + 
                 (averange(con.mysticality) * mysticalityscore / full ) +
                 (averange(con.moxie) * moxiescore / full));
    if (con.mustPull)
      costscore = (con.price + COST_OF_PULL) / to_float(full);
    else
      costscore = con.price / to_float(full);
  }
  if (overdrink)
  {
    advscore = advscore * full;
    if (ode) advscore += averange(con.consumptionGain) * VALUE_OF_ADVENTURE;
    statscore = statscore * full;
    costscore = costscore * full;
  }
#  if (my_class() == $class[Avatar of Jarlsberg] && con.type == "food" && have_skill($skill[The Most Important Meal]) && get_fullness() == 0 && count(speculating ? specposition : position) == 0)
  if (breakfast)
  {
    advscore = ((averange(con.adv) + (3 * full)) * VALUE_OF_ADVENTURE);
    statscore *= 3;
  }
  float val = advscore + statscore - costscore;
  val = special_values(con.it, val);
  vprint(con.it+" full "+full+" advscore "+advscore+" statscore "+statscore+" costscore "+costscore+" val "+val+" od "+overdrink,8);
  return val;
}

void filter_type(string type)
{
  foreach i in grub
  {
    if (grub[i].type != type)
    {
      vprint(grub[i].it+" isn't a "+type+". Skipping.",9);
      remove grub[i];
    }
  }
}

boolean inbudget (con_rec con)
{
  boolean not_enough = (con.have < 1) && (con.price > get_meat(1));
  if (not_enough || (con.price > BUDGET) || (con.price == MAXMEAT) || (con.price > to_int(get_property("autoBuyPriceLimit")) && con.mustMall))
  {
    if(favorites contains con.it)
    {
      vprint("Favorite "+to_string(con.it)+" is too expensive ("+con.price+")- removing from consideration.",3);
    }
    vprint(to_string(con.it)+" is too expensive ("+con.price+")- removing from consideration.",7);
    return false;
  }
  return true;
}

void filter_final(int max, int current)
{
  foreach i in grub
  {
    grub[i] = availability(grub[i]);
    if (fail contains grub[i].it) {
        remove grub[i];
    }
    else
    {
      if (!inbudget(grub[i]))
        remove grub[i];
      else if (grub[i].consumptionGain.min > (max - current))
      {
        if(favorites contains grub[i].it)
        {
          vprint("Favorite "+to_string(grub[i].it)+" is too fattening ("+grub[i].consumptionGain.min+")- removing from consideration.",3);
        }
        vprint(to_string(grub[i].it)+" is too fattening ("+grub[i].consumptionGain.min+")- removing from consideration.",7);
        remove grub[i];
      }
      else if (grub[i].have < 1 && !(EAT_SHOP && (grub[i].canShop || grub[i].canDaily)) && !(EAT_MALL && !get_ronin() && grub[i].mustMall) && !(EAT_COINMASTER && grub[i].mustCoinmaster))
        remove grub[i];
    }
  }
}

int best(boolean speculative)
{
  if (count(grub) <= 0)
    return 0;
  vprint("Sorting by # you have",9);
  sort grub by -value.have; //less significant - how many you have
  vprint("Sorting by value",9);
  sort grub by -value.value;//more significant - the value
  if (SIM_CONSUME)
  {
    vprint("If there are favorites still in consideration, they'll be here:",7);
    if (count(favorites) > 0)
    {
      foreach i in grub
      {
        if (favorites contains grub[i].it)
        {
          print("Fav: "+format_entry(grub[i]));
          logprint("Fav: "+format_entry(grub[i]));
        }
        vprint(i+": "+format_entry(grub[i]),7);
      }
    }
  }
  //this should abort after the first iteration.
  foreach i in grub
  {
    if (grub[i].value <= 0)
    {
      if (!speculative) summarize("Best find was "+grub[1].it+" with a value of " + 
                to_int(grub[1].value) + 
                ". That's no good, so not consuming and moving on.");
      return 0;
    }
    return i;
  }
  return 0;
}

boolean will_servant(int value)
{
  if (value == 0) return false;
  if (HARDCORE_SERVANTS == 0 && get_ronin()) return false;
  return true;
}

boolean getitem(int needed, item it, int price)
{
  int initialvalue = to_int(get_property("autoBuyPriceLimit"));
  if (will_servant(GET_CHEF) && !have_chef() && it.fullness > 0)
  {
    if (getitem(1, $item[chef-in-the-box], (GET_CHEF > 0 ? GET_CHEF : 999999)))
      use(1, $item[chef-in-the-box]);
    else if (HARDCORE_SERVANTS == 2)
      abort("Unable to get your chef for under "+(GET_CHEF > 0 ? GET_CHEF : 999999)+" meat!");
  }
  if (will_servant(GET_BARTENDER) && !have_bartender() && it.inebriety > 0)
  {
    if (getitem(1, $item[bartender-in-the-box], (GET_BARTENDER > 0 ? GET_BARTENDER : 999999)))
      use(1, $item[bartender-in-the-box]);
    else if (HARDCORE_SERVANTS == 2)
      abort("Unable to get your bartender for under "+(GET_BARTENDER > 0 ? GET_BARTENDER : 999999)+" meat!");
  }
  if (item_amount(it) >= needed) return true;
  vprint("Getting "+needed+" "+it+" in "+pause+" seconds",3);
  if (pause > 0)
    wait(pause);
  try
  {
    set_property("autoBuyPriceLimit", max((initialvalue >= 1000 ? 1000 : 0), min(initialvalue * PRICE_FLEXIBILITY, floor(price * PRICE_FLEXIBILITY))));
    retrieve_item(needed, it);
  }
  finally
  {
    set_property("autoBuyPriceLimit", initialvalue);
    return item_amount(it) >= needed;
  }
}

boolean getone(item it, int price)
{
  if (SIM_CONSUME)
  {
    vprint("simulating retrieval of one "+it+".",3);
    return true;
  }
  int initialamount = item_amount(it);
  boolean gotit = true;
  int needed = 0;
  foreach i in position { if (position[i].it == it) needed += 1; }
  if (needed == 0) needed = 1;
  gotit = getitem(needed, it, price);
  if (!gotit && needed == 1 && price > 0)
  {
    int reprocessed = needed;
    while (reprocessed > 0 && !gotit)
    {
      reprocessed -= 1;
      gotit = getitem(reprocessed, it, price);
    }
    if (item_amount(it) == initialamount)
      fail[it] = true;
    return false;
  }
  if (!gotit)
  {
    if (!EAT_MALL)
      summarize("EatDrink encountered an error: You don't have "+needed+" "+it
                +" and you're not able to shop.");
    else if (price == 0)
      summarize("EatDrink encountered an error: You don't have "+needed+" "+it
                +" and it has a null price, so you can't buy it.");
    if (item_amount(it) == initialamount)
      fail[it] = true;
  }
  return gotit;
}

void stackone(con_rec con, string type, boolean speculative)
{
  if (con.it == $item[none])
    abort("Can't stack null item.");
  if (speculative)
  {
    specposition[specmaxposition] = con;
    specmaxposition += 1;
  }
  else
  {
    position[maxposition] = con;
    maxposition += 1;
  }
  if (!con.mustMake && !con.mustShop && !con.mustDaily && !con.mustMall && !con.mustCoinmaster) con.using += 1;
  if (con.mustPull || con.mustShop || con.mustDaily || con.mustMall || con.mustCoinmaster) stepusedmeat += con.price;
}

boolean consumeone(con_rec con, string type, int iteration, int step)
{
  boolean ateone = false;
  if (con.it == $item[none])
    abort("Can't consume null item.");
  if ((item_amount(con.it) > 0) || SIM_CONSUME || con.mustDaily)
  {
    if (type == "food")
    {
      //Calculate once, not twice
      int foodadventures = 0;
      int foodlasagna = 0;
      for i from step to maxposition
      {
        foodadventures += averange(position[i].consumptionGain);
        if ($items[fishy fish lasagna, gnat lasagna, long pork lasagna] contains position[i].it)
          foodlasagna += 1;
      }
      //See if you should be getting milk
      if (!get_milk(averange(con.consumptionGain)))
        milk_do_body_good(foodadventures, false);
      //See if you're Gar-ish-ly hungry
      if (foodlasagna > 0 && !get_gar())
        lasagna_do_garfield_good(foodlasagna, false);
      //SEE IF YOU SHOULD BE SHOUTING THE SONG OF THE GLORIOUS LUNCH
      if (wants_lunch && !get_lunch(averange(con.consumptionGain)))
        lunch_do_body_good(foodadventures, false);
    }                
    else if ((!get_ode(averange(con.consumptionGain))) && (type == "booze") && wants_ode)
    {
      //See if you should be getting ode
      int odeadventures = 0;
      for i from step to maxposition
        odeadventures += averange(position[i].consumptionGain);
      ode_do_liver_good(odeadventures, false);
    }                

    if (!SIM_CONSUME)
    {
      int adv_before = get_adventures();
      int muscle_before = get_muscle();
      int moxie_before = get_moxie();
      int mysticality_before = get_mysticality();
      int item_amount_before = item_amount(con.it);

      if (type == "food") {
        if (SUPRESS_NOMILK) {
           eatsilent(1, con.it);
        } else {
           eat(1, con.it);
        }
      }
      if (type == "booze")
      {
        // drinky stuff now 
        if (tuxworthy(con.it))
        { 
          cli_execute("checkpoint");
          equip($item[tuxedo shirt]);
        }
        if (SUPRESS_OVERDRINK)
          overdrink(1, con.it);
        else
          drink(1, con.it);
        if (tuxworthy(con.it))
          outfit("checkpoint");
      }
      if ((type == "spleen") || (type == "choc"))
        use(1, con.it);
      ateone = get_adventures() != adv_before || item_amount_before != item_amount(con.it);
#      if (con.mustDaily) ateone = get_adventures() != adv_before;
#      else ateone = item_amount_before != item_amount(con.it);
    }  
    else 
    {
      boolean simbreakfast = false;
      if (type == "food")
      {
        if (my_class() == $class[Avatar of Jarlsberg] && iteration == 1 && have_skill($skill[The Most Important Meal]) && get_fullness() == 0) simbreakfast = true;
        if (simbreakfast) simadventures += food_adjust(averange(con.adv), averange(con.consumptionGain)) + (3 * averange(con.consumptionGain));
        else simadventures += food_adjust(averange(con.adv), averange(con.consumptionGain));
        simfullness += con.consumptionGain.min;
      }
      if (type == "booze")
      {
        simadventures += drink_adjust(averange(con.adv), averange(con.consumptionGain));
        siminebriety += con.consumptionGain.min;
      }
      if (type == "spleen")
      {
        simadventures += averange(con.adv);
        simspleen += con.consumptionGain.min;
      }
      if (type == "choc")
      {
        simadventures += averange(con.adv);
      }
      if (simbreakfast)
      {
        simmuscle += averange(con.muscle) * 3;
        simmoxie += averange(con.moxie) * 3;
        simmysticality += averange(con.mysticality) * 3;
      }
      else
      {
        simmuscle += averange(con.muscle);
        simmoxie += averange(con.moxie);
        simmysticality += averange(con.mysticality);
      }
      ateone = true;
    }
  }
  return ateone;
}


int doneness(string type)
{
  if (type == "food")
    return get_fullness();
  if (type == "booze")
    return get_inebriety();
  if (type == "spleen")
    return get_spleen();
  abort("Doneness: Invalid type "+type);
  return 0;
}


int predoneness(string type, boolean speculative)
{
  int queued = 0;
  if (speculative)
    foreach i in specposition { queued += specposition[i].consumptionGain.min; }
  else
    foreach i in position { queued += position[i].consumptionGain.min; }
  if (type == "food" || type == "booze" ||type == "spleen")
    return queued + doneness(type);
  abort("Predoneness: Invalid type "+type);
  return 0;
}


int eatdrink(int foodMax, int drinkMax, int spleenMax, boolean overdrink)
{
//////////Check version
  check_version("EatDrink", "eatdrink", EATDRINK_VERSION,EATDRINK_VERSION_PAGE);

//////////Validate input
  if ((drinkMax > inebriety_limit()) && !SIM_CONSUME)
    abort("Error - you specified that you wanted to drink to "+drinkMax+" but your liver can only drink up to "+inebriety_limit()+". Don't forget that 'overdrinking' (that is, getting too drunk to adventure) is separate. To overdrink, specify a drinkmax of "+inebriety_limit()+" and overdrink = true.");
  if ((drinkMax < inebriety_limit()) && !SIM_CONSUME && overdrink)
    abort("Error - you said to overdrink after drinking to "+drinkMax+" but your limit is "+inebriety_limit()+". Either set overdrink to false, or raise your drink level to "+inebriety_limit()+".");

/////////Set up consumption & message tracking variables
  finalsummary = "";
  int startmeat = get_meat(0);
  int startfullness = get_fullness();
  int startinebriety = get_inebriety();
  int startspleen = get_spleen();
  int startadventures = get_adventures();
  int startmuscle = get_muscle();
  int startmoxie = get_moxie();
  int startmysticality = get_mysticality();

//////////Save your outfit
  refresh_stash(); //make sure the connection is live
  cli_execute("checkpoint");

//Load favorites from settings
  if (to_boolean(vars["eatdrink_favUse"]))
  {
    vprint("Loading favorite consumables from user settings...",3);
    foreach it in $items[]
    {
      if(var_check("eatdrink_fav_"+ replace_string(to_string(it)," ","_")))
                {                                 
        vprint("adding favorite: "+it,3);
        favorites[it] = true;
                }
    }
  } else vprint("Skipping favorites.",3);
  
//////////Print out the "starting" message that contains your config choices
  if (get_ronin())
  {
    vprint("You're in ronin, so no shopping for you.",3);
    EAT_MALL = false;
  }
  if ((item_amount($item[tiny plastic sword]) > 0) && !have_bartender())
    vprint("WARNING: You have a tiny plastic sword but no bartender, so the effective cost of TPS drinks will include the price of the bartender, making them less attractive. If you want to drink TPS drinks, you should probably buy a bartender-in-the-box before running this.","RED",3);
  summarize("Starting EatDrink.ash (version "+EATDRINK_VERSION+").");
  string begin = "Consuming up to "+foodMax+" food, "+drinkMax
    +" booze, and "+spleenMax+" spleen";
  if (SIM_LEVEL != 0)
    begin += " <b>as if you were level "+SIM_LEVEL+"</b>.";
  if (overdrink)
    begin=begin+" and then finishing off with the stiffest drink we can find.";
  summarize(begin);
  begin = "Considering food from inventory";
  if (USE_CLOSET)
    begin += " closet";
  if (USE_STORAGE && !get_ronin())
    begin += " Hagnk's";
  if (EAT_COINMASTER)
    begin += " Coinmasters";
  if (EAT_SHOP)
    begin += " NPCs";
  if (EAT_MALL)
    begin += " the mall";
  begin += ". Per-item budget cap is "+(BUDGET*PRICE_FLEXIBILITY)+".";
  summarize(begin);
  begin = "Retrieval cap is "+(to_int(get_property("autoBuyPriceLimit")));
  begin += ". Price will ";
  if (!CONSIDER_COST_WHEN_OWNED)
    begin += "not ";
  begin += "be a factor if you own it already.";
#  begin += "be a factor if you own it already. Hagnk's pulls (if enabled) will cost ";
#  begin += COST_OF_PULL+" meat each.";
  summarize(begin);
  begin = "An adventure has the value of <b>"+VALUE_OF_ADVENTURE+" meat</b>. "+my_primestat()+" subpoint is "+VALUE_OF_PRIME_STAT;
  begin += ". Nonprime stat subpoint is "+VALUE_OF_NONPRIME_STAT+".";
#  if (get_ronin())
#    begin += " Hagnk pulls are limited and their 'cost' is incorporated.";
  if (!can_eat())
    begin += " You're on a pathed ascension, so you won't eat.";
  if (!can_drink())
    begin += " You're on a pathed ascension, so you won't drink.";
  summarize(begin);
  if (SIM_CONSUME)
  {
    summarize("<b>Simulating only</b>; no purchases or "
              +"food/drink/spleen consumption.");
  }
  boolean giveup = false;

  string type = "";
  int iteration = 0;
  int conmax = 0;
  boolean can_do = false;
  boolean repeatingstep = false;
  boolean specrepeatingstep = false;
  boolean breakfast = false;
////////// 1 is eat
////////// 2 is drink
////////// 3 is spleen
////////// 4 is overdrink
  while (iteration < 4 || repeatingstep)
  {
    if (!repeatingstep) { iteration += 1; stepusedmeat = 0; }
    else repeatingstep = false;
    maxposition = 0;
    specmaxposition = 0;
    nowposition = 0;
    nomposition = 0;
    clear(position);
    clear(ingredients);
    bestvoa[iteration] = VALUE_OF_ADVENTURE;
    if (!SIM_CONSUME) makeusedmeat = 0;
    usedmeat += maybeusedmeat;
    maybeusedmeat = 0;
    if (iteration == 1)
    {
      type = "food";
      conmax = foodMax;
      can_do = can_eat();
    }
    else if (iteration == 2)
    {
      type = "booze";
      conmax = drinkMax;
      can_do = can_drink();
    }
    else if (iteration == 3)
    {
      type = "spleen";
      conmax = spleenMax;
      can_do = true;
    }
    else if (iteration == 4)
    {
      type = "booze";
      conmax = 999999;
      can_do = overdrink && can_drink();
    }
    else abort("Bad iteration.");
    vprint("Pass "+iteration+": "+type+".",3);
    if (can_do && (doneness(type) < conmax))
    {
      breakfast = (my_class() == $class[Avatar of Jarlsberg] && iteration == 1 && have_skill($skill[The Most Important Meal]) && get_fullness() == 0 && count(position) == 0);
      //Nuke grub so you can reload it
      clear(grub);
      //Nuke used ingredients if we're running for real
      if (!SIM_CONSUME)
        clear(usingMake);
      //Start summarizing and filtering
      if (iteration != 4)
        summarize(type+": At "+doneness(type)+", consuming to "+conmax+" with "+get_meat(1)+" meat.");
      else
        summarize("At drunkenness of "+doneness(type)+". Overdrinking with "+get_meat(1)+" meat.");
      vprint("Loading "+type+" map from Mafia's data",6);
      update_from_mafia(type);
      vprint("Copying "+type+" map using Mafia's data",6);
      update_using_mafia(type);
      vprint("Filtering by type",6);
      filter_type(type);
      vprint("Finding prices",6);
      set_prices();
      vprint("Setting values",6);
      foreach i in grub { grub[i].value = value(grub[i], (iteration == 4), breakfast, false); }
      ConsumptionReportIndex = 1;
      giveup = false;
      boolean triedmojo = false;
      //each pass, create a stack until you should be full after finishing. Aborts when you giveup.
      while (!(giveup || (predoneness(type, false) >= conmax) || 
               ((predoneness(type, false) > inebriety_limit()) && (iteration == 4)))) 
      {
        if (breakfast) { breakfast = false; foreach i in grub { grub[i].value = value(grub[i], (iteration == 4), breakfast, false); } }
        boolean itemsfound = (best(false) > 0);
        vprint("Finding prices",6);
        set_prices();
        vprint("Choosing "+type+" to consume.",6);
        filter_final(conmax, predoneness(type, false));
        int to_consume = best(false);
        if (to_consume == 0)
        {
          vprint("No "+type+" available that's good enough. Found "+maxposition+" items first. Moving on.",3);
          giveup = true;
          if (maxposition == 0) maxposition = -1;
        }
        else
        {
          if (grub[to_consume].mustMake)
          {
            int[item] ings;
            if (SIM_CONSUME) foreach ingred,x in simingredients { ings[ingred] += x; }
            foreach ingred,x in ingredients { ings[ingred] += x; }
            if (have_ingredients(grub[to_consume].it, 1, ings, 0))
            {
              ingredients = add_ingredients(grub[to_consume].it, 1, ingredients, 0);
              stackone(grub[to_consume], type, false);
              if (special_items contains grub[to_consume].it) { repeatingstep = true; }
              if (my_class() == $class[Avatar of Jarlsberg] && grub[to_consume].type == "food" && have_skill($skill[The Most Important Meal]) && get_fullness() == 0 && count(position) == 1) breakfast = true;
            }
            else remove grub[to_consume];
            clear(ings);
          }
          else
          {
            stackone(grub[to_consume], type, false);
            if (special_items contains grub[to_consume].it) { repeatingstep = true; }
          }
        }
        maybeusedmeat = stepusedmeat;
        if (repeatingstep) break;
      }
      int ORIGINAL_VOA = VALUE_OF_ADVENTURE;
      while ((ORIGINAL_VOA / 2) < VALUE_OF_ADVENTURE && ORIGINAL_VOA > 100)
      {
        breakfast = (my_class() == $class[Avatar of Jarlsberg] && iteration == 1 && have_skill($skill[The Most Important Meal]) && get_fullness() == 0 && count(position) == 0);
        VALUE_OF_ADVENTURE -= ORIGINAL_VOA / 9;
        specrepeatingstep = false;
        //Nuke grub so you can reload it
        clear(grub);
        vprint("Copying "+type+" map using Mafia's data for speculation",9);
        update_using_mafia(type);
        vprint("Filtering by type for speculation",9);
        filter_type(type);
        vprint("Finding prices for speculation",9);
        set_prices();
        vprint("Setting values for speculation",9);
        foreach i in grub { grub[i].value = value(grub[i], (iteration == 4), breakfast, true); }
        ConsumptionReportIndex = 1;
        giveup = false;
        boolean triedmojo = false;
        stepusedmeat = 0;
        //each pass, create a stack until you should be full after finishing. Aborts when you giveup.
        while (!(giveup || (predoneness(type, true) >= conmax) || 
                 ((predoneness(type, true) > inebriety_limit()) && (iteration == 4)))) 
        {
          if (breakfast) { breakfast = false; foreach i in grub { grub[i].value = value(grub[i], (iteration == 4), breakfast, true); } }
          vprint("Choosing "+type+" to consume.",9);
          filter_final(conmax, predoneness(type, true));
          int to_consume = best(true);
          if (to_consume == 0)
          {
            vprint("No speculative "+type+" available that's good enough. Found "+specmaxposition+" items first. Moving on.",9);
            giveup = true;
            if (specmaxposition == 0) specmaxposition = -1;
          }
          else
          {
            if (grub[to_consume].mustMake)
            {
              int[item] ings;
              if (SIM_CONSUME) foreach ingred,x in simingredients { ings[ingred] += x; }
              foreach ingred,x in specingredients { ings[ingred] += x; }
              if (have_ingredients(grub[to_consume].it, 1, ings, 0))
              {
                specingredients = add_ingredients(grub[to_consume].it, 1, specingredients, 0);
                stackone(grub[to_consume], type, true);
                if (special_items contains grub[to_consume].it) { specrepeatingstep = true; }
                if (my_class() == $class[Avatar of Jarlsberg] && grub[to_consume].type == "food" && have_skill($skill[The Most Important Meal]) && get_fullness() == 0 && count(specposition) == 1) breakfast = true;
              }
              else remove grub[to_consume];
              clear(ings);
            }
            else
            {
              stackone(grub[to_consume], type, true);
              if (special_items contains grub[to_consume].it) { specrepeatingstep = true; }
              if (my_class() == $class[Avatar of Jarlsberg] && grub[to_consume].type == "food" && have_skill($skill[The Most Important Meal]) && get_fullness() == 0 && count(specposition) == 1) breakfast = true;
            }
          }
          if (specrepeatingstep) break;
        }
        float adventurecount = 0;
        int gaincount = 0;
        float averagetest = 0.0;
        float specadventurecount = 0;
        int specgaincount = 0;
        float specaveragetest = 0.0;
        foreach i in position { adventurecount += averange(position[i].adv); gaincount += averange(position[i].consumptionGain); }
        foreach i in specposition { specadventurecount += averange(specposition[i].adv); specgaincount += averange(specposition[i].consumptionGain); }
        if ((predoneness(type, false) < conmax || predoneness(type, true) < conmax) && (repeatingstep || specrepeatingstep) && iteration != 4)
        {
          averagetest = gaincount > 0 ? adventurecount / gaincount : 0;
          specaveragetest = specgaincount > 0 ? specadventurecount / specgaincount : 0;
        }
        else
        {
          averagetest = adventurecount;
          specaveragetest = specadventurecount;
        }
        if (specaveragetest > averagetest)
        {
          vprint("Since "+specaveragetest+" is more than "+averagetest+" we are using a speculative stack of "+VALUE_OF_ADVENTURE+".",3);
          clear(position);
          foreach i in specposition { position[i] = specposition[i]; }
          maxposition = specmaxposition;
          bestvoa[iteration] = VALUE_OF_ADVENTURE;
          maybeusedmeat = stepusedmeat;
          repeatingstep = specrepeatingstep;
        }
        else vprint("Since "+specaveragetest+" is not more than "+averagetest+" we are using the normal stack instead of "+VALUE_OF_ADVENTURE+".",9);
        clear(specposition);
        clear(specingredients);
        specmaxposition = 0;
      }
      //Nuke grub so you can reload it - Fixing the mess from speculating
      clear(grub);
      update_using_mafia(type);
      filter_type(type);
      set_prices();
      foreach i in grub { grub[i].value = value(grub[i], (iteration == 4), false, false); }
      ConsumptionReportIndex = 1;
      VALUE_OF_ADVENTURE = ORIGINAL_VOA;
      if (SIM_CONSUME) foreach ingred,x in ingredients { simingredients[ingred] += x; }
      giveup = false;
      //each pass, use the stack and try to collect items for consuming. Aborts when you giveup.
      while (!(giveup || (nowposition >= maxposition)))
      {
        vprint("Obtaining "+position[nowposition].it+" to consume.",6);
        if (SIM_CONSUME) { simitem[position[nowposition].it] += 1; }
        if (position[nowposition].it == $item[none])
        {
          vprint("Something went wrong with position "+nowposition+" in the stack and it's a null item. Recalculating.",3);
          giveup = true;
          repeatingstep = true;
        }
        else if (!position[nowposition].mustDaily)
        {
          if (!getone(position[nowposition].it, position[nowposition].price))
          {
            vprint("Something went wrong with getting "+position[nowposition].it+" for "+position[nowposition].price+". Recalculating.",3);
            giveup = true;
            repeatingstep = true;
          }
          else nowposition += 1;
        }
        else nowposition += 1;
      }
      if (!repeatingstep) giveup = false;
      //each pass, consume until full. Aborts when you giveup, when you eat up to conmax, or when you drink past inebreity limit & are overdrinking.
      while (!(giveup || (nomposition >= maxposition)))
      {
        if (position[nomposition].it == $item[none])
        {
          vprint("Something went wrong with position "+nomposition+" in the stack and it's a null item. Ending stack.",3);
          maxposition -= 1;
          giveup = true;
        }
        else
        {
          string consume_entry = format_entry(position[nomposition]);
          logprint(consume_entry);
          if (pause > 0)
          {
            vprint("Waiting to consume...",3);
            print(consume_entry);
            wait(pause);
          }
          if (consumeone(position[nomposition], type, iteration, nomposition))
          {
            summarize(ConsumptionReportIndex+": "+consume_entry);
            ConsumptionReportIndex += 1;
            if (position[nomposition].it == $item[steel lasagna]) { foodMax += 5; }
            else if (position[nomposition].it == $item[steel margarita]) { drinkMax += 5; }
            else if (position[nomposition].it == $item[steel-scented air freshener]) { spleenMax += 5; }
            else if (iteration == 4) { giveup = true; }
          }
          else
          {
            if (position[nomposition].mustDaily)
               fail[position[nomposition].it] = true;
            print("FAIL: "+consume_entry);
            logprint("FAIL: "+consume_entry);
            repeatingstep = true;
            if (my_inebriety() > inebriety_limit()) {
               giveup = true;
            }
          }
          //you might have learned something (e.g. price)
          position[nomposition].value = value(position[nomposition], (iteration == 4), false, false);
          //if you're spleening and partway done, consider mojo filters, 
          //based on the quality of your last spleenable.
          if ((iteration == 3) && (get_spleen() > 5) && !triedmojo && !mojogiveup)
          {
            int checkspleen = get_spleen();
            triedmojo = true;
            filter_your_mojo(position[nomposition]);
            if (checkspleen != get_spleen()) {
              giveup = true;
              repeatingstep = true;
            }
          }
          nomposition += 1;
        }
      }
      if (iteration < 1 || iteration > 4)
        abort("Invalid iteration.");
    }
    else
      vprint("Skipping "+type+".",3);
  }
  ConsumptionReportIndex = 1;
  if (EAT_MALL) {
     summarize("choc: Checking non-filling crimbo chocolates - all 3 kinds");
     get_choc();
  }
  string finished = "Finished. ";
  if (have_effect($effect[got milk]) > 0 || (have_effect($effect[ode to booze]) > 0))
  {
    finished += "You had ";
    if (have_effect($effect[got milk]) > 0)
      finished += " Milk of Magnesium";
    if (have_effect($effect[ode to booze]) > 0)
      finished += "-Ode to Booze";
    finished += " in effect. Adventures listed above does not reflect that, but this does:";
  }
  summarize(finished);
  finished = "Spent ";
  if (SIM_CONSUME)
  {
    finished += (usedmeat+makeusedmeat+makeveryusedmeat) + " meat with additional expenditures of ";
    finished += (startmeat - get_meat(0)) + " meat. Gained Fullness: ";
  }
  else
  {
    finished += (startmeat - get_meat(0)) + " meat. Gained Fullness: ";
  }
  finished += (get_fullness() - startfullness) + ". Inebriety: ";
  finished += (get_inebriety() - startinebriety) + ". Spleen: ";
  finished += (get_spleen() - startspleen) + ".\nAdventures: ";
  finished += (get_adventures() - startadventures) + ". Muscle: ";
  finished += (get_muscle() - startmuscle) + ". Moxie: ";
  finished += (get_moxie() - startmoxie) + ". Mysticality: ";
  finished += (get_mysticality() - startmysticality)+".";
  foreach i,v in bestvoa { if (v != VALUE_OF_ADVENTURE) finished += ("\nOn step "+i+" your best value was recalculated as "+v+"."); }
  summarize(finished);
  summarize("Eating, drinking, and spleening complete. Commence merrymaking (at your own discretion).");
  print("******************************************");
  print("Now, to recap...");
  print("******************************************");
  print_html(finalsummary);
  logprint(finalsummary);
  outfit("checkpoint");
  return (get_adventures() - startadventures);
}

//This would be the version for people who want full parameter control when 
//they call it... see the PREFERENCES section at the top for documentation 
//to see what does what.
void eatdrink (int foodMax, int drinkMax, int spleenMax, boolean overdrink,
               boolean sim_consume_p, boolean supress_overdrink_p,
               boolean accurate_p, int budget_p, float price_flexibility_p,
               boolean consider_cost_when_owned_p, int cost_of_pull_p,
               int value_of_adventure_p, int value_of_prime_stat_p,
               int value_of_nonprime_stat_p, boolean pie_priority_p,
               int price_of_nontradeables_p, int price_of_unknowns_p,
               int price_of_questitems_p, boolean sim_ronin_p,
               int sim_level_p)
{
  SIM_CONSUME = sim_consume_p;
  SUPRESS_OVERDRINK = supress_overdrink_p;
  EAT_ACCURATE = accurate_p;
  BUDGET = budget_p;
  PRICE_FLEXIBILITY = price_flexibility_p;
  CONSIDER_COST_WHEN_OWNED = consider_cost_when_owned_p;
  COST_OF_PULL = cost_of_pull_p;
  VALUE_OF_ADVENTURE = value_of_adventure_p;
  VALUE_OF_PRIME_STAT = value_of_prime_stat_p;
  VALUE_OF_NONPRIME_STAT = value_of_nonprime_stat_p;
  PIE_PRIORITY =  pie_priority_p;
  PRICE_OF_NONTRADEABLES = price_of_nontradeables_p;
  PRICE_OF_UNKNOWNS = price_of_unknowns_p;
  PRICE_OF_QUESTITEMS = price_of_questitems_p;
  SIM_RONIN = sim_ronin_p;
  SIM_LEVEL = sim_level_p;
  eatdrink(foodMax, drinkMax, spleenMax, overdrink);
}

//Legacy edition:
//This would be the version for people running dj_d's ascend. 
void eatdrink (int foodMax, int drinkMax, int spleenMax, boolean overdrink,
               boolean use_inv_p, boolean use_closet_p, boolean use_storage_p, 
               boolean sim_consume_p, boolean supress_overdrink_p, 
               boolean shop_p, int budget_p, float price_flexibility_p, 
               boolean consider_cost_when_owned_p, int cost_of_pull_p, 
               int value_of_adventure_p, 
               int value_of_prime_stat_p, int value_of_nonprime_stat_p, 
               boolean pie_priority_p, int price_of_nontradeables_p,
               int price_of_unknowns_p, boolean sim_ronin_p, int sim_level_p)
{
  SIM_CONSUME = sim_consume_p;
  SUPRESS_OVERDRINK = supress_overdrink_p;
  BUDGET = budget_p;
  PRICE_FLEXIBILITY = price_flexibility_p;
  CONSIDER_COST_WHEN_OWNED = consider_cost_when_owned_p;
  COST_OF_PULL = cost_of_pull_p;
  VALUE_OF_ADVENTURE = value_of_adventure_p; 
  VALUE_OF_PRIME_STAT = value_of_prime_stat_p; 
  VALUE_OF_NONPRIME_STAT = value_of_nonprime_stat_p;
  PIE_PRIORITY =  pie_priority_p; 
  PRICE_OF_NONTRADEABLES = price_of_nontradeables_p;
  PRICE_OF_UNKNOWNS = price_of_unknowns_p; 
  SIM_RONIN = sim_ronin_p; 
  SIM_LEVEL = sim_level_p;
  eatdrink(foodMax, drinkMax, spleenMax, overdrink);
}

//If you want to include eatdrink.ash in your scripts, you can call eatdrink 
//with a more common set of additional paramters by using this convention:
void eatdrink(int foodMax, int drinkMax, int spleenMax, boolean overdrink, 
              int advmeat, int primemeat, int offmeat, int pullmeat, boolean sim)
{
  VALUE_OF_ADVENTURE = advmeat;   
  VALUE_OF_PRIME_STAT = primemeat;
  VALUE_OF_NONPRIME_STAT = offmeat; //You probably care less about it
  COST_OF_PULL = pullmeat;
  SIM_CONSUME = sim;
  eatdrink(foodMax, drinkMax, spleenMax, overdrink);
}

void main (int foodMax, int drinkMax, int spleenMax, boolean overdrink, 
           boolean sim)
{
  SIM_CONSUME = sim;
  eatdrink(foodMax, drinkMax, spleenMax, overdrink);
}
