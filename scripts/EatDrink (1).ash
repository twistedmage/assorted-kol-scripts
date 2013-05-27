// ----------------------------------------------------------------------------
// EatDrink.ash
// by 
// dj_d
// 
// inspired by reportConsumables.ash, by Sandiman
//
// ----------------------------------------------------------------------------
script "EatDrink.ash"
notify "dj_d"

import <zlib.ash>;

//STATUS: removed autospading & local data files. Sort maps.
//TODO: test each type of consumption separately.  Make sure recalc after consumption does the right thing.  Consume-at-end.  Cleanup error pricing states. Look in to other "cleaning" items.

string EATDRINK_VERSION = "3.0";
int EATDRINK_VERSION_PAGE = 1519;

int MAXMEAT = 999999999;

// --- Preferences --- //
// Note: DON'T CHANGE THESE HERE! This just sets the defaults.  Changing them
// won't do anything.  Go to your scripts directory and modify the file 
// vars_yourcharactername.txt

// 'true' to do all your consuming at the end, after you finish acquiring 
// everything.  Not well tested, but useful if you don't have a foo-in-a-box
// and you don't want to burn turns of Got Milk making stuff. 
// NOT YET IMPLEMENTED
setvar("eatdrink_consumeLast", false);
boolean CONSUME_LAST = to_boolean(vars["eatdrink_consumeLast"]);

// 'true' to include items in the user's inventory
setvar("eatdrink_useInv", true);
boolean USE_INV = to_boolean(vars["eatdrink_useInv"]);

// 'true' to get updating pricing information from Zarqon's server - will
// greatly speed up execution
setvar("eatdrink_GetPriceServer", true);
boolean GetPriceServer = to_boolean(vars["eatdrink_GetPriceServer"]);

// 'true' to include items in the user's closet
setvar("eatdrink_useCloset", false);
boolean USE_CLOSET = to_boolean(vars["eatdrink_useCloset"]);

// 'true' to include items int he user's storage
setvar("eatdrink_useStorage", true);
boolean USE_STORAGE = to_boolean(vars["eatdrink_useStorage"]);

// If true, it assumes that your starting fullness & drunkenness are 0 (so
// can use it when full).  You do not actually drink or eat, and no item
// updates are saved at the end.
setvar("eatdrink_simConsume", true);
boolean SIM_CONSUME = to_boolean(vars["eatdrink_simConsume"]);
// do not actually buy or consume, and pretend starting fullness is 0.

// If true, you won't receive the "Are you sure you want to..." message on 
// overdrink.
setvar("eatdrink_suppressOverdrink", true);
boolean SUPRESS_OVERDRINK = to_boolean(vars["eatdrink_suppressOverdrink"]);

// If true, you will buy food to consume that is not in inventory.
// It is highly recommended that you closet most of your meat before running
// this as a safety precaution against bugs in the script (this is true of
// all scripts!).
setvar("eatdrink_shop", true);
boolean SHOP = to_boolean(vars["eatdrink_shop"]);

// If true, you will make food if you have all the ingredients available.
setvar("eatdrink_make", true);
boolean MAKE = to_boolean(vars["eatdrink_make"]);

// Do you want to invoke Ode before drinking?
// This only works if you actually possess the skill
setvar("eatdrink_ode", true);
boolean wants_ode = to_boolean(vars["eatdrink_ode"]);
if (have_skill($skill[the ode to booze]) == false)
{ wants_ode = false; }

// If you want to invoke "the ode to booze" we will do it via a mood
// list your mood here that contains Ode
setvar("eatdrink_boozeMood", "booze");
string boozeMood = to_string(vars["eatdrink_boozeMood"]);
string tempMood = "NONENONENONE";

// If shopping, ignore items that cost more than PRICE FLEXIBILITY * this 
// (another safety precaution, but not as reliable as closting your meat). 
// This should not be necessary (you can set it to MAXMEAT theoretically)
// since the interplay of other variables ensures you won't spend more than
// you're willing to... still, it's good to be safe. 
setvar("eatdrink_budget", 20000);
int BUDGET = to_int(vars["eatdrink_budget"]);

// Before buying, making, etc stuff, it will pause this many seconds.
setvar("eatdrink_pause", 3);
int pause = to_int(vars["eatdrink_pause"]);

// If true, buy/pull a *****-in-the-box if one's required
setvar("eatdrink_getChef", true);
boolean GET_CHEF = to_boolean(vars["eatdrink_getChef"]);
setvar("eatdrink_getBartender", true);
boolean GET_BARTENDER = to_boolean(vars["eatdrink_getBartender"]);

// Estimated prices are often off; you should be willing to pay somewhat more.
// Setting this closer to 1 will optimize slightly but slow things down a lot.
// It cannot be less than 1 or you'll hang.  A minimum of 1.25 is recommended.
setvar("eatdrink_priceFlexibility", 1.25);
float PRICE_FLEXIBILITY = to_float(vars["eatdrink_priceFlexibility"]);

// 'true' will cause you to consider the price of food that you own already.
// 'false' means to treat items you own as free.
setvar("eatdrink_considerCostWhenOwned", true);
boolean CONSIDER_COST_WHEN_OWNED = 
  to_boolean(vars["eatdrink_considerCostWhenOwned"]);

// The score for these food & drinks will display when the script runs so you 
// can find out why it chose what it did over these.  Recommended use is to 
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
setvar("eatdrink_favUse",true); 

// The interplay of the next values determines what sort of diet you'll get.  
// The difference between the two numbers is the relative value of adventures 
// and stats.  Setting them both high means you're willing to spend more cash; 
// setting them both low means you're thrifty.	100/20 may put you on sausage 
// pizzas, for example, while 200/40 may get you bat wing chow mein.  
// A reasonable way to set this is "how much meat would I pay for one adventure"
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

//If true, then any time your level permits it and you're missing a key
//(Boris, Jarlsberg, or Sneaky Pete), eatdrink will make the corresponding
//pie a top priority.
setvar("eatdrink_piePriority", true);
boolean PIE_PRIORITY = to_boolean(vars["eatdrink_piePriority"]);

// Some items are nontradable, so their price can't be calculated.  These items
// tend to be very good (e.g. pan-galactic gargleblaster).  You may not want
// to consume them lightly, so set this at MAXMEAT.  If you do want to eat 
// the very best food available regardless of value, set this to 0.
setvar("eatdrink_priceOfNontradeables", MAXMEAT);
int PRICE_OF_NONTRADEABLES = to_int(vars["eatdrink_priceOfNontradeables"]);

// Similar to the above, except sometimes the lookup fails for lousy items.
// MAXMEAT will cause items where lookup fails to be ignored from consideration.
setvar("eatdrink_priceOfUnknowns", MAXMEAT);
int PRICE_OF_UNKNOWNS = to_int(vars["eatdrink_priceOfUnknowns"]);

//if true, assume everything must be pulled. If false, use your current character state.
setvar("eatdrink_simRonin", false);
boolean SIM_RONIN = to_boolean(vars["eatdrink_simRonin"]);

// if 0, then use your actual level.  If you'd like to simulate a different level (e.g. ascension planning), set it to that level.
setvar("eatdrink_simLevel", 0);
int SIM_LEVEL = to_int(vars["eatdrink_simLevel"]);

// Uncomment the print statement for moderate verbosity
void verbose(string foo)
{
  print(foo);
}

// Uncomment the print statement for extreme verbosity
void verbose2(string foo)
{
//  print(foo);
}

/////////////////////////////////////////////////////////////////////////////

string finalsummary;
boolean fooddone = false;
boolean drinkdone = false;
boolean spleendone = false;
boolean overdrinkdone = false;
int gfoodMax; //making this global 'cause I'm laaaaazy

boolean[item]tuxable;
tuxable[$item[dry martini]] = true;
tuxable[$item[dry vodka martini]] = true;
tuxable[$item[gibson]] = true;
tuxable[$item[vodka martini]] = true;
tuxable[$item[vodka gibson]] = true;
tuxable[$item["rockin' wagon"]] = true;

boolean [item]special_items;
special_items[$item["steel margarita"]] = true;
special_items[$item["steel lasagna"]] = true;
special_items[$item["steel-scented air freshener"]] = true;
special_items[$item["bodyslam"]] = true;
special_items[$item["cherry bomb"]] = true;
special_items[$item["dirty martini"]] = true;
special_items[$item["grogtini"]] = true;
special_items[$item["sangria del diablo"]] = true;
special_items[$item["vesper"]] = true;

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
  finalsummary = finalsummary + add + "<br>";
}


// Globals used for simulating consumption.
int simmeat = MAXMEAT;
int simfullness = 0;
int siminebriety = 0;
int simspleen = 0;
float simadventures = 0.0;
int simmuscle = 0;
int simmoxie = 0;
int simmysticality = 0;
boolean simmilk = false;
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
  string type; //"food", "drink", or "spleen" ("overdrink" is invalid here)
  range consumptionGain; //fullness, inebriety, whatever
  int level; //min level required
  range adv; //adv gain
  range muscle;    //stat subpoint gain
  range mysticality;
  range moxie;
  int price;       //mall price
  float value;       //calculated value
  int have; 
  boolean mustMake;//to get it, you have to make it
  boolean mustPull;//to get it, you have to pull it
};

//"grub" contains all consumables in the game. It gets sorted and filtered etc.
con_rec [int]grub;

// Converts a range of numbers (or single number) to a single number.
// If the string is a single number, that number is returned.
// If the string is a range of numbers, the average of the parsed numbers is returned.
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
  // Return the 2 numbers
  returnval.min = to_float(splitRange[0]);
  returnval.max = to_float(splitRange[1]);
  return returnval;
}

float averange (range statrange)
{ return ((statrange.max + statrange.min) / 2.0); }

int get_meat()
{
  if (!SIM_CONSUME)
    return my_meat();
  return simmeat;
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

boolean get_milk()
{
  if (!SIM_CONSUME)
    return (have_effect($effect["got milk"]) > 0);
  return simmilk;
}

boolean get_ronin()
{
  if (!SIM_RONIN)
    return (!can_interact());
  return true;
}


float ode_adjust(float adj_adv)
{
  if ((have_effect($effect["ode to booze"]) > 0))
  {
    if (adj_adv <= 4)
      return adj_adv + 1;
    if (adj_adv <= 7)
      return adj_adv + 2;
    if (adj_adv <= 10)
      return adj_adv + 3;
    return adj_adv + 4;
  }
  return adj_adv;
}

float milk_adjust(range adj_adv)
{
  float milktot = 0.0;
  for milkit from to_int(adj_adv.min) upto to_int(adj_adv.max) by 1
  {
    if (get_milk())
    {
      if (milkit <= 4) milktot = milktot + to_float(milkit + 1);
      else if (milkit <= 7) milktot = milktot + to_float(milkit + 2);
      else if (milkit <= 10) milktot = milktot + to_float(milkit + 3);
	  else milktot = milktot + to_float(milkit + 4);
	}
	else
	{
	  milktot = milktot + to_float(milkit);
	}
  }
  milktot = milktot / (adj_adv.max - adj_adv.min + 1.0);
  return milktot;  // returns average of range + milk effect
}

//will be defined later
boolean getone(item it, int price);
float value(con_rec con, boolean overdrink);
boolean consumeone(con_rec con, string type);
string format_entry(con_rec entry);

int[item] brokenprice; //If you tried to buy it and failed, this is the price
boolean[item] brokenpull; //If you tried to pull it and failed
boolean[item] brokenmake; //If you tried to make it and failed
boolean get_on_budget(int totalquantity, item it, int maxprice) 
{
   if (to_string(it) == "")
   {
     verbose("No item requested; calling that success");
     return true;
   }
   int quantity = totalquantity - item_amount(it);
   if (quantity < 1)
   {
     verbose("Already got that many, calling that success");
     return true;
   }
   int budget = quantity * maxprice;
   int startmeat = my_meat();
   verbose("budgeting "+budget+" for "+quantity+" additional "+it+". You have "+
	  startmeat+" meat.  You have "+item_amount(it)+
	  " in inventory already.");
   if (startmeat > budget)
   {
     int got = buy(quantity, it, budget);
     verbose("Purchased "+got+" "+it+" for "+(startmeat-my_meat())+" meat.");
     if (got < quantity)
     {
       verbose("Tried to get "+quantity+" "+it+" but got "+
	       got+".  Pricing error."); 
       if (brokenprice contains it)
       {
	 verbose("Seen a problem with this one before at a price of "
		 + brokenprice[it] + ".");
       }
       verbose("Setting new effective price to the greater of "
	       +maxprice+" and "+(brokenprice[it]+1));
       brokenprice[it] = max(maxprice, brokenprice[it]+1);
     }
   }
   else
   {
     verbose ("That doesn't appear to be enough meat, but maybe it's cheap (or maybe you've got some in the closet).  Either way, let's try.");
     boolean retrieve_return_value = retrieve_item(quantity, it);
     verbose ("retrieve_item returned "+retrieve_return_value+" and you have "+
	      item_amount(it)+" of the "+quantity+" you requested.  You have "+
	      my_meat()+" meat in inventory now.");
   }
   return (quantity == item_amount(it));
}

void milk_do_body_good(int adv, int fullness)
{
  int toeat = gfoodMax - get_fullness();
  int pullcost = 0;
  if (USE_STORAGE && get_ronin() && pulls_remaining() > 0)
    pullcost = COST_OF_PULL;
  int milkprice = mall_price($item[milk of magnesium]);
//milk will probably give you 33% more adventures than what you're eating,
//so assume all your eating will be this item and see if the adv gain is 
//worth it.

  float milkvalue = (toeat * adv/fullness *.33) * VALUE_OF_ADVENTURE;
  boolean shouldgetmilk = (milkvalue > (milkprice + pullcost));
  int lastprice = 0;

  // keep trying until you get it, you can't get it, or it's a bad value
  while (shouldgetmilk && !get_milk() && (milkprice != lastprice)) 
  {
    if (SIM_CONSUME)
    {
      simmeat = simmeat - milkprice;
      simmilk = true;
      summarize("0: <b>milk of magnesium</b> price: "+milkprice+" value: "
		+ to_int(milkvalue - milkprice - pullcost));
    }
    else
    {
      lastprice = milkprice;
      if (item_amount($item[milk of magnesium]) < 1)
	getone($item[milk of magnesium], milkprice);
      if (item_amount($item[milk of magnesium]) > 0)
	use(1, $item[milk of magnesium]);
      int actualprice = mall_price($item[milk of magnesium]); 
      if (get_milk())
	summarize("0: <b>milk of magnesium</b> price: "+actualprice+" value: "
		  + (milkvalue - actualprice - pullcost));
      else
      {
	milkprice = mall_price($item[milk of magnesium]);
	shouldgetmilk = (milkvalue > (milkprice + pullcost));
      }
    }
  }
}


int special_prices(item it, int startprice)
{
  //These are unpriceable, so return a small number (that isn't reserved)
  if (it == $item["steel margarita"] && (item_amount(it) > 0))
    return 2;
  if (it == $item["steel lasagna"] && (item_amount(it) > 0))
    return 2;
  if (it == $item["steel-scented air freshener"] && (item_amount(it) > 0))
    return 2;

  //Special pricing rules for TPS drinks
  boolean TPS = false;
  TPS = (item_amount($item["tiny plastic sword"]) > 0);
  int price1 = 0;
  int price2 = 0;
  boolean checked = false;
  if (it == $item["bodyslam"] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item["bottle of tequila"]);
    price2 = mall_price($item["lime"]); 
    checked = true;
  }
  if (it == $item["cherry bomb"] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item["bottle of whiskey"]);
    price2 = mall_price($item["cherry"]);
    checked = true;
  }
  if (it == $item["dirty martini"] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item["bottle of gin"]);
    price2 = mall_price($item["jumbo olive"]); 
    checked = true;
  }
  if (it == $item["grogtini"] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item["bottle of rum"]);
    price2 = mall_price($item["lime"]);
    checked = true;
  }
  if (it == $item["sangria del diablo"] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item["boxed wine"]);
    price2 = mall_price($item["cherry"]);
    checked = true;
  }
  if (it == $item["vesper"] && (TPS || (item_amount(it) > 0)))
  {
    price1 = mall_price($item["bottle of vodka"]);
    price2 = mall_price($item["jumbo olive"]);
    checked = true;
  }
  if (checked)
  {
    if ((price1 <= 1) || (price2 <= 1))
      return 0;
    int bar = 0;
//    if (!have_bartender())
//    {
//      bar = mall_price($item["bartender-in-the-box"]);
//    }
    return (price1 + (price2 * 2) + bar);
  }
  return startprice;
}


setvar("eatdrink_maxAge", "2.0");
//Does not include pull costs - that's added in the final calculation
int effective_price(con_rec con)
{
  item it = con.it;
  int price = 0;
  if ((con.have > 0) && !CONSIDER_COST_WHEN_OWNED)
    return 0; //If you have it & you don't care about price
  if ((con.have == 0) && !SHOP)
    return 0; //If you don't have any but you can't shop
  if (!is_tradeable(it))
  {
    verbose2("NONTRADEABLE: "+it);
    return PRICE_OF_NONTRADEABLES;      
  }
  if (!(special_items contains it))
  { 
    if (brokenprice contains it)
    {
      verbose("Apparantly there was a previous problem buying "
	      +it+" so the new price is "+brokenprice[it]);
      return brokenprice[it];
    }
  //If checkdaily is set, that means you've consumed it before.  We'll 
  //get a live price check for maximum accuracy, since it's likely to be
  //something you'll want to consume.  Otherwise, we'll update only if 
  //the pricing data is >maxAge days out of date.  Note that this is updated
  //earlier in the script from a server so you should have fresh prices.
    if (to_boolean(vars["eatdrink_daily_"+
                          replace_string(to_string(it)," ","_")]) || 
	(historical_age(it) > to_float(vars["eatdrink_maxAge"])))
    {
      price = mall_price(it);
      if (to_boolean(vars["eatdrink_daily_"+
                            replace_string(to_string(it)," ","_")])) 
	verbose2("CHECKDAILY:"+it+" = "+price);
      else
	verbose2("STALE     :"+it+" = "+price);
    }
    else
    {
      price = historical_price(it);
      if (price == 0)
      {
	price = mall_price(it);
	verbose2("ERROR     :"+it+" = "+price);
      }
      else
	verbose2("HISTORICAL:"+it+" = "+price);
    }
  }
  else
  {
    price = special_prices(it, price);
    verbose2("SPECIAL   :"+it+" = "+price);
  }
  if ((price == 0) || (price == -1) || (price == 1))
  {
    price = PRICE_OF_UNKNOWNS;
    verbose2("UNKNOWN:      "+it);
  }
  return price;
}


con_rec availability(con_rec con)
{
  con.have = 0;
  con.mustPull = false;
  con.mustMake = false;
  if (USE_INV)
    con.have = item_amount(con.it);
  if (USE_CLOSET)
    con.have = con.have + closet_amount(con.it);
  //Don't make your digital key into pie!  Ask me how I found this bug...
  if (MAKE && (con.it != $item["digital key lime pie"])) 
  {
    int createamt = creatable_amount(con.it);
    con.mustMake = (con.have <= 0) && (createamt > 0) && 
                   !(brokenmake contains con.it);
    con.have = con.have + createamt;
  }
  if (USE_STORAGE && (pulls_remaining() > 0))
  {
    int storageamt = storage_amount(con.it);
    if (get_ronin())      
      if (storageamt > pulls_remaining())
	storageamt = pulls_remaining();
    con.mustPull = (con.have <= 0) && (storageamt > 0) && 
                   !(brokenpull contains con.it);
    con.have = con.have + storageamt;
  }
  return con;
}


boolean mojogiveup = false;
boolean filter_your_mojo(con_rec baseline)
{
  item mf = $item[mojo filter];
  con_rec con_mf; //create a mojo filter consumable record
  con_mf.it = mf;
  con_mf = availability(con_mf); //get its availability
  con_mf.price = effective_price(con_mf); //price the filter
  //Assume your last consumable is representative of what you'd get.  
  //"value" already is normalized to represent the value from 1 adventure.
  boolean shouldgetmojo = (baseline.value >= con_mf.price);
  verbose("Spleen value is "+to_int(baseline.value)
	  +"; mojo filter to get it costs "+con_mf.price);
  int lastprice = 0;
  int got = item_amount(mf);
// Should do:keep trying until you get it, you can't get it, or it's a bad value
  int mojomeat = my_meat();
  if (shouldgetmojo && SIM_CONSUME)
  {
    simmeat = simmeat - (3*con_mf.price);
    simspleen = simspleen - 3;
    summarize("X: <b>3 mojo filters</b> price: "+(con_mf.price*3)+" (total)");
    mojogiveup = true;
  }
  else if (shouldgetmojo)
  {
    int lasttry = 0;
    int mojoused = 1;
    boolean gotone = false;
    while (!mojogiveup)
    {
      getone(mf, con_mf.price);
      if (item_amount(mf) > 0)
      {
	if (use(1, mf))
	{
	  summarize("M"+mojoused+": <b>mojo filter</b> price: "
		    +(mojomeat-my_meat()));
	  mojoused = mojoused + 1;
	  gotone = true;
	}
      }
      mojomeat = my_meat();
      lasttry = con_mf.price;
      if (brokenprice contains mf)
	con_mf.price = max(con_mf.price, brokenprice[mf]);
      else 
	con_mf.price = mall_price(mf);
      mojogiveup = (!gotone && (lasttry == con_mf.price)) || (mojoused == 3);
    }
  }
}

item reducechoc(item it)
{
  if (it == $item[fancy but probably evil chocolate]) //they track together
    it = $item[fancy chocolate];
  return it;
}

int chocval(item it)
{
  int chocs;
  it = reducechoc(it);
  if (SIM_CONSUME)
    chocs = simchoc[it];
  else
    chocs = to_int(get_property("_eatdrink_"+substring(to_string(it),0,5)));
  if (chocs == 0) 
  {
    verbose2("Never used a "+it);
    return 5;
  }
  if (chocs == 1) 
  {
    verbose2("Used one "+it);
    return 3;
  }
  if (chocs == 2) 
  {
    verbose2("Used 2 "+it);
    return 1;
  }
  verbose2("Used 3 or more already of "+it);
  return 0;
}

//this is cheap, but I'm going to abuse simchoc to iterate over for the main loop here (irrespective of whether I'm simulating).
simchoc[$item["vitachoconutriment capsule"]] = 0;
simchoc[$item["fancy chocolate"]] = 0; //note this encompasses -but-evil too
boolean get_choc()
{
  foreach it in simchoc //will run twice
  {
    for i from 1 upto 3 by 1 //only useful 3 times
    {
      con_rec con_choc;
      con_choc.it = it;
      //choose cheaper of evil-or-not
      if ((it == $item[fancy chocolate]) && (historical_price(it) > 
	  historical_price($item[fancy but probably evil chocolate])))
	con_choc.it = $item[fancy but probably evil chocolate];
      con_choc.consumptionGain.max = 1; con_choc.consumptionGain.min = 1;
      con_choc.adv.max = chocval(con_choc.it); 
      con_choc.adv.min = con_choc.adv.max;
      con_choc.type = "choc";
      con_choc = availability(con_choc);
      con_choc.price = effective_price(con_choc);
      con_choc.value = value(con_choc, false);
      if (con_choc.value > 0)
      {
	simchoc[reducechoc(con_choc.it)] = simchoc[reducechoc(con_choc.it)] + 1;
	verbose2("Attempting to consume a "+con_choc.it);
	string consume_entry = format_entry(con_choc);
	logprint(consume_entry);
	if (pause > 0)
	{
	  verbose("Waiting to consume...");
	  print_html(consume_entry);
	  wait(pause);
	}
	if (consumeone(con_choc, "choc"))
	{
	  summarize(ConsumptionReportIndex+": "+consume_entry);
	  ConsumptionReportIndex = ConsumptionReportIndex + 1;
	}
	else
	{
	  print_html("FAIL: "+consume_entry);
	  logprint("FAIL: "+consume_entry);
	}
      }
      else
      {
	verbose2("For "+con_choc.it+" value "+to_int(con_choc.value)
		 +" is less than or equal to zero.");
      }
    }
  }
}

string format_entry(con_rec entry)
{
  string output;
  output = "<b>"+entry.it+"</b>";
  output = output + " lev:"+entry.level;
  output = output + " gain:"+averange(entry.consumptionGain);
  output = output + " adv:"+averange(entry.adv);
  output = output + " musc:"+averange(entry.muscle);
  output = output + " myst:"+averange(entry.mysticality);
  output = output + " mox:"+averange(entry.moxie);
  output = output + " meat:"+entry.price;
  output = output + " own:"+entry.have;
//  output = output + " pull:"+entry.mustPull;
//  output = output + " make:"+entry.mustMake;
  output = output + " value:"+to_int(entry.value);
  return output;
}

con_rec extra_items(con_rec con)
{
  if (con.it == $item["melted Jell-o shot"])
  {
    con.muscle.min = 8.3;
    con.muscle.max = 13.3;
    con.moxie.min = 8.3;
    con.moxie.max = 13.3;
    con.mysticality.min = 8.3;
    con.mysticality.max = 13.3;
  }
  //If it's the special dusty bottle, use the right numbers
  if ((to_int(con.it) >= 2271) && (to_int(con.it) <= 2276))
  {
    verbose2("Checking "+con.it+" to see if it's the special wine.");
    if (my_ascensions( )!= get_property("lastDustyBottleReset").to_int())
    {
        cli_execute("dusty");
        if (my_ascensions( )!= get_property("lastDustyBottleReset").to_int())
            return con;    
    }
    if (get_property("lastDustyBottle"+to_int(con.it)).to_int() == 4)
    {
      verbose2("It is!");
      con.muscle.min = 10;
      con.muscle.max = 15;
      con.moxie.min = 10;
      con.moxie.max = 15;
      con.mysticality.min = 10;
      con.mysticality.max = 15;
      con.adv.min = 5;
      con.adv.max = 7;
    }
  }
  return con;
}

void update_from_mafia(string type)
{
  record fullness_file_entry // holds the map found in fullness.txt
  {
    int consumptionGain;
    int level;	 
    string adv; 
    string muscle; 
    string mysticality;
    string moxie; 
  };
  string filename;
  if (type == "food") filename = "fullness.txt";
  else if (type == "drink") filename = "inebriety.txt";
  else if (type == "spleen") filename = "spleenhit.txt";
  else abort("Wrong type."+type);
  fullness_file_entry [item] temp_map;
  verbose2("Loading "+filename+".");
  if (!file_to_map(filename, temp_map))
    abort("Failed to load "+filename+". Aborting.");
  verbose2(filename+" loaded successfully.");
  int gc = 1;
  foreach it in temp_map	
  {
    //Genalen bottles are broken because of the TM. 
    if (it != $item["Genalen&trade; bottle"])
    {
      verbose2("Importing mafia info for "+it);
      grub[gc].it = it;
      grub[gc].type = type;
      grub[gc].level = temp_map[it].level;
      grub[gc].consumptionGain.max = temp_map[it].consumptionGain;
      grub[gc].consumptionGain.min = temp_map[it].consumptionGain;
      grub[gc].adv = set_range(temp_map[it].adv);
      grub[gc].muscle = set_range(temp_map[it].muscle);
      grub[gc].mysticality = set_range(temp_map[it].mysticality);
      grub[gc].moxie = set_range(temp_map[it].moxie);
      grub[gc] = extra_items(grub[gc]);
      gc = gc + 1;
    }
    else
      verbose2("Skipping "+it);
  }
}	


int special_values(item it, int startvalue)
{
  if (it == $item["steel margarita"] && (item_amount(it) > 0))
    return MAXMEAT;
  if (it == $item["steel lasagna"] && (item_amount(it) > 0))
    return MAXMEAT;
  if (it == $item["steel-scented air freshener"] && (item_amount(it) > 0))
    return MAXMEAT;
  if (PIE_PRIORITY)
  {
    // if you don't have the keys, increase the value of their pies
    if (it == $item["boris's key lime pie"])
      if (item_amount($item["boris's key"]) == 0)
	return MAXMEAT-1;
    if (it == $item["sneaky pete's key lime pie"])
      if (item_amount($item["sneaky pete's key"]) == 0)
	return MAXMEAT-1;
    if (it == $item["jarlsberg's key lime pie"])
      if (item_amount($item["jarlsberg's key"]) == 0)
	return MAXMEAT-1;
  }
  return startvalue;
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
float value(con_rec con, boolean overdrink)
{
  boolean milk;
  boolean ode;
  if (con.type == "food")
  {
    milk = get_milk();
    ode = false;
  }
  else if (con.type == "drink")
  {
    milk = false;
    ode = (have_effect($effect["ode to booze"]) > 0);
  }
  else if ((con.type == "spleen") || (con.type == "choc"))
  {
    milk = false;
    ode = false;
  }
  else 
    abort("invalid type! '"+con.type+"'");
  int full = averange(con.consumptionGain);
  float advscore = 0;
  float statscore = 0;
  float costscore = 0;
  //TODO: Munchies & Opossum
  if (full != 0)
  {
    if (milk)
    { advscore = (milk_adjust(con.adv) 
		  * VALUE_OF_ADVENTURE) / full; }
    else if (ode)
    { advscore = (ode_adjust(averange(con.adv)) 
		  * VALUE_OF_ADVENTURE) / full; }
    else
    { advscore = (averange(con.adv) 
		  * VALUE_OF_ADVENTURE) / full; }
    if (tuxworthy(con.it))
      advscore = advscore + (2 * VALUE_OF_ADVENTURE / full);
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
    statscore = statscore * full;
    costscore = costscore * full;
  }
  float val = advscore + statscore - costscore;
  val = special_values(con.it, val);
  verbose2(con.it+" full "+full+" advscore "+advscore+" statscore "
	   +statscore+" costscore "+costscore+" val "+val+" od "+overdrink); 
  return val;
}

void filter_type(string type)
{
  foreach i in grub
  {
    if (grub[i].type != type)
    {
      verbose2(grub[i].it+" isn't a "+type+". Skipping.");
      remove grub[i];
    }
  }
}


void filter_level()
{
  int level = get_level();
  foreach i in grub
  {
    if (grub[i].level > level)
    {
      if (favorites contains grub[i].it)
      {
	verbose("Favorite "+grub[i].it+" has a minimum required level of "
		+ grub[i].level+". Filter level is "+level
		+ ". Skipping.");
      }
      verbose2(grub[i].it+" does not meet level requirements. Skipping.");
      remove grub[i];
    }
  }
}

void set_prices()
{
  foreach i in grub
  {
    grub[i] = availability(grub[i]);
    boolean available = grub[i].have > 0;
    grub[i].price = effective_price(grub[i]);
    if (SHOP && !available && 
	(grub[i].price != PRICE_OF_NONTRADEABLES))
      available = true;
    if (!available)
    {
      if (favorites contains grub[i].it)
      {
	verbose("Favorite "+grub[i].it+" appears unavailable given budget, "
	      + "SHOP variable settings, ronin status, and/or mall price.");
      }
      remove grub[i];
    }
  }
}


boolean special_purchases(item it)
{
  boolean special = false;
  if (it == $item[bodyslam])
  {
    get_on_budget(2, $item[lime], mall_price($item[lime]) * PRICE_FLEXIBILITY);
    get_on_budget(1, $item[bottle of tequila], mall_price($item[bottle of tequila]) * PRICE_FLEXIBILITY);
    create(1, $item[bodyslam]);
    special = true;
  }
  else if (it == $item[cherry bomb])
  {
    get_on_budget(2, $item[cherry], mall_price($item[cherry]) * PRICE_FLEXIBILITY);
    get_on_budget(1, $item[bottle of whiskey], mall_price($item[bottle of whiskey]) * PRICE_FLEXIBILITY);
    create(1, $item[cherry bomb]);
    special = true;
  }
  else if (it == $item[dirty martini])
  {
    get_on_budget(2, $item[jumbo olive], mall_price($item[jumbo olive]) * PRICE_FLEXIBILITY);
    get_on_budget(1, $item[bottle of gin], mall_price($item[bottle of gin]) * PRICE_FLEXIBILITY);
    create(1, $item[dirty martini]);
    special = true;
  }
  if (it == $item[grogtini])
  {
    get_on_budget(2, $item[lime], mall_price($item[lime]) * PRICE_FLEXIBILITY);
    get_on_budget(1, $item[bottle of rum], mall_price($item[bottle of rum]) * PRICE_FLEXIBILITY);
    create(1, $item[grogtini]);
    special = true;
  }
  else if (it == $item[sangria del diablo])
  {
    get_on_budget(2, $item[cherry], mall_price($item[cherry]) * PRICE_FLEXIBILITY);
    get_on_budget(1, $item[boxed wine], mall_price($item[boxed wine]) * PRICE_FLEXIBILITY);
    create(1, $item[sangria del diablo]);
    special = true;
  }
  else if (it == $item[vesper])
  {
    get_on_budget(2, $item[jumbo olive], mall_price($item[jumbo olive]) * PRICE_FLEXIBILITY);
    get_on_budget(1, $item[bottle of vodka], mall_price($item[bottle of vodka]) * PRICE_FLEXIBILITY);
    create(1, $item[vesper]);
    special = true;
  }
  return special;
}


boolean inbudget (con_rec con)
{
  boolean not_enough = (con.have == 0) && (con.price > my_meat());
  if (not_enough || (con.price > BUDGET) || (con.price == MAXMEAT))
  {
    if(favorites contains con.it)
    {
      verbose("Favorite "+to_string(con.it)+" is too expensive ("+con.price
	      + ")- removing from consideration.");
    }
//    verbose2(to_string(con.it)+" is too expensive ("+con.price
//	     + ")- removing from consideration.");
    return false;
  }
  return true;
}

void filter_final(int max, int current)
{
  foreach i in grub
  {
    if (!inbudget(grub[i]))
      remove grub[i];
    else if (grub[i].consumptionGain.min > (max - current))
    {
      if(favorites contains grub[i].it)
      {
	verbose("Favorite "+to_string(grub[i].it)+" is too fattening ("
		+ grub[i].consumptionGain.min
		+ ")- removing from consideration.");
      }
      verbose2(to_string(grub[i].it)+" is too fattening ("
	       + grub[i].consumptionGain.min
	       + ")- removing from consideration.");
      remove grub[i];
    }
  }
}

int best()
{
  if (count(grub) <= 0)
    return 0;
  verbose2("Sorting by # you have");
  sort grub by -value.have; //less significant - how many you have
  verbose2("Sorting by value");
  sort grub by -value.value;//more significant - the value
  if (SIM_CONSUME)
  {
    verbose("If there are favorites still in consideration, they'll be here:");
    if (count(favorites) > 0)
    {
      foreach i in grub
      {
	if (favorites contains grub[i].it)
	{
	  print_html("Fav: "+format_entry(grub[i]));
	  logprint("Fav: "+format_entry(grub[i]));
	}
	verbose2(i+": "+format_entry(grub[i]));
      }
    }
  }
  //this should abort after the first iteration.
  foreach i in grub
  {
    if (grub[i].value <= 0)
    {
      summarize("Best find was "+grub[1].it+" with a value of " + 
		to_int(grub[1].value) + 
		".  That's no good, so not consuming and moving on.");
      return 0;
    }
    return i;
  }
  return 0;
}

boolean getone(item it, int price)
{
  if (SIM_CONSUME)
  {
    verbose("simulating consumption of one "+it+".");
    return true;
  }
  boolean gotit = false;
  if (item_amount(it) > 0)
  {
    verbose("You have at least one "+it+" in inventory.");
    if (pause > 0)
      wait(pause);
    gotit = true;
  }
  if (!gotit && closet_amount(it) > 0 && USE_CLOSET)
  {
    verbose("Taking a "+it+" from the closet");
    if (pause > 0)
      wait(pause);
    take_closet(1,it);
    if (item_amount(it) > 0)
      gotit = true;
    else
    {
      verbose("Failed to get one from the closet.");
      brokenpull[it] = true;
    }
  }
  if (!gotit && MAKE && (creatable_amount(it) >= 1))
  {
    if (!have_chef() && GET_CHEF)
    {
      if(closet_amount($item["chef-in-the-box"]) > 1)
      {
	verbose("pulling chef-in-the-box from the closet in "+pause+" seconds");
	if (pause > 0)
	  wait(pause);
	take_closet(1, $item["chef-in-the-box"]);
	use(1, $item["chef-in-the-box"]);
      }
      else if (!get_ronin())
      {
	verbose("acquiring a chef-in-the-box in "+pause+" seconds");
	if (pause > 0)
	  wait(pause);
	retrieve_item(1, $item["chef-in-the-box"]);
	use(1, $item["chef-in-the-box"]);
      }
    }
    if (!have_bartender() && GET_BARTENDER)
    {
      if(closet_amount($item["bartender-in-the-box"]) > 1)
      {
	verbose("pull bartender-in-the-box from closet in "+pause+" seconds");
	if (pause > 0)
	  wait(pause);
	take_closet(1, $item["bartender-in-the-box"]);
	use(1, $item["bartender-in-the-box"]);
      }
      else if (!get_ronin())
      {
	verbose("acquiring a bartender-in-the-box in "+pause+" seconds");
	if (pause > 0)
	  wait(pause);
	retrieve_item(1, $item["bartender-in-the-box"]);
	use(1, $item["bartender-in-the-box"]);
      }
    }
    verbose("Creating a "+it+" in "+pause+" seconds");
    if (pause > 0)
      wait(pause);
    if ((it != $item["digital key lime pie"]) &&
	(it != $item["star key lime pie"]))       //don't bake your quest items!
      create(1, it);
    if (item_amount(it) > 0)
      gotit = true;
    else
    {
      verbose("Failed to create a "+it+".");
      brokenmake[it] = true;
    }
  }
  if (!gotit && storage_amount(it)>0 && USE_STORAGE && (pulls_remaining() > 0))
  {
    verbose("Pulling a "+it+" in "+pause+" seconds");
    if (pause > 0)
      wait(pause);
    take_storage(1,it);
    if (item_amount(it) > 0)
      gotit = true;
    else
      verbose("Failed to pull a "+it+" from Hagnk's.");
  }
  if (!gotit && SHOP && (price != 0))
  {
    verbose("Shopping for a "+it+" in "+pause+" seconds");
    if (pause > 0)
      wait(pause);
    if(special_purchases(it))
      gotit = true;
    else if (get_on_budget(1, it, (price * PRICE_FLEXIBILITY)))
      gotit = true;
    else
      verbose("Failed to get "+it+" for a max price of "
	      +PRICE_FLEXIBILITY+"*"+price+"="+(PRICE_FLEXIBILITY*price));
  }
  if (!gotit && !SHOP)
    summarize("EatDrink encountered an error: You don't have a "+it
	      +" and you're not able to shop.");
  if (!gotit && (price == 0))
    summarize("EatDrink encountered an error: You don't have a "+it
	      +" and it has a null price, so you can't buy it.");
  return gotit;
}

boolean consumeone(con_rec con, string type)
{
  boolean ateone = false;
  if (con.it == $item[none])
    abort("Can't consume null item.");
  getone(con.it, con.price);
  if ((item_amount(con.it) > 0) || SIM_CONSUME)
  {
    if ((!get_milk()) && (type == "food"))
    {
      milk_do_body_good(averange(con.adv), 
			con.consumptionGain.min);
      foreach i in grub // update values with milk effects
      { grub[i].value = value(grub[i], false); }	
    }		
    if (!SIM_CONSUME)
    {
      int adv_before = my_adventures();
      int muscle_before = get_muscle();
      int moxie_before = get_moxie();
      int mysticality_before = get_mysticality();
      int item_amount_before = item_amount(con.it);

      if (type == "food")
	eat(1, con.it);
      if (type == "drink")
      {
	// Lets see if we want to get some ode via a mood!
	if (have_effect($effect[the ode to booze]) == 0 && wants_ode == true)
	{
	  // save the current mood
	  tempMood = get_property("currentMood");
	  verbose("Invoking Ode to Booze.");
	  cli_execute("mood " + boozeMood);
	  cli_execute("mood execute");
	}
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
	{ cli_execute("outfit checkpoint"); }
      }
      if ((type == "spleen") || (type == "choc"))
	use(1, con.it);
      ateone = item_amount_before != item_amount(con.it);
    }  
    else 
    {
      if (type == "food")
      {
	simfullness = simfullness + con.consumptionGain.min;
	simadventures = simadventures + milk_adjust(con.adv);
      }
      if (type == "drink")
      {
	siminebriety = siminebriety + con.consumptionGain.min;
	simadventures = simadventures + ode_adjust(averange(con.adv));
      }
      if (type == "spleen")
      {
	simspleen = simspleen + con.consumptionGain.min;
	simadventures = simadventures + averange(con.adv);
      }
      if (type == "choc")
      {
	simadventures = simadventures + averange(con.adv);
      }
      simmeat = simmeat - con.price;
      simmuscle = simmuscle + averange(con.muscle);
      simmoxie = simmoxie + averange(con.moxie);
      simmysticality = simmysticality + averange(con.mysticality);
      ateone = true;
    }
  }		     
  //if you consume something, it gets set as a property, which means
  //you'll recheck the price before consumption instead of only when the data 
  //is stale.
  if (ateone && !(special_items contains con.it) && !SIM_CONSUME)
    setvar("eatdrink_daily_"+replace_string(to_string(con.it)," ","_"),true);
  return ateone;
}


int doneness(string type)
{
  if (type == "food")
    return get_fullness();
  if (type == "drink")
    return get_inebriety();
  if (type == "spleen")
    return get_spleen();
  abort("Invalid type "+type);
  return 0;
}


void eatdrink(int foodMax, int drinkMax, int spleenMax, boolean overdrink)
{
//////////Check version
  check_version("EatDrink", "eatdrink", EATDRINK_VERSION,EATDRINK_VERSION_PAGE);

//////////Validate input
  if ((drinkMax > inebriety_limit()) && !SIM_CONSUME)
    abort("Error - you specified that you wanted to drink to "+drinkMax+" but your liver can only drink up to "+inebriety_limit()+". Don't forget that 'overdrinking' (that is, getting too drunk to adventure) is separate.  To overdrink, specify a drinkmax of "+inebriety_limit()+" and overdrink = true.");
  if ((drinkMax < inebriety_limit()) && !SIM_CONSUME && overdrink)
    abort("Error - you said to overdrink after drinking to "+drinkMax+" but your limit is "+inebriety_limit()+".  Either set overdrink to false, or raise your drink level to "+inebriety_limit()+".");

/////////Set up consumption & message tracking variables
  finalsummary = "";
  gfoodMax = foodMax;
  int startmeat = get_meat();
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
    verbose("Loading favorite consumables from user settings...");
    foreach it in $items[]
    {
//	verbose("items contains: " + it);
      if(to_boolean(vars["eatdrink_fav_"
                         + replace_string(to_string(it)," ","_")]))
		{				 
	verbose("adding favorite: " + it);
	favorites[it] = true;
		}
    }
  } else verbose("Skipping favorites.");
  
//////////Print out the "starting" message that contains your config choices
  if (get_ronin() && !SIM_CONSUME)
  {
    verbose("You're in ronin, and not simulating, so no shopping for you.");
    SHOP = false;
  }
//  if ((item_amount($item["tiny plastic sword"]) > 0) && !have_bartender())
//    verbose("WARNING: You have a tiny plastic sword but no bartender, so the effective cost of TPS drinks will include the price of the bartender, making them less attractive.  If you want to drink TPS drinks, you should probably buy a bartender-in-the-box before running this.","RED");
  summarize("Starting EatDrink.ash (version "+EATDRINK_VERSION+").");
  string begin = "Consuming up to "+foodMax+" food, "+drinkMax+" booze, and "+spleenMax+" spleen";
  if (SIM_LEVEL != 0)
    begin = begin + " <b>as if you were level "+SIM_LEVEL+"</b>.";
  if (overdrink)
    begin = begin + " and then finishing off with the stiffest drink we can find.";
  summarize(begin);
  begin = "Considering food from ";
  if (USE_INV)
    begin = begin + "inventory ";
  if (USE_CLOSET)
    begin = begin + "closet ";
  if (USE_STORAGE)
    begin = begin + "Hagnk's ";
  if (SHOP)
    begin = begin + "the mall";
  begin = begin + ". Per-item budget cap is "+(BUDGET*PRICE_FLEXIBILITY)+".";
  summarize(begin);
  begin = "Price will ";
  if (!CONSIDER_COST_WHEN_OWNED)
    begin = begin + "not";
  begin = begin+" be a factor if you own it already. Hagnk's pulls (if enabled) will cost ";
  begin = begin+COST_OF_PULL+" meat each.";
  summarize(begin);
  begin = "An adventure has the value of <b>"+VALUE_OF_ADVENTURE+" meat</b>. "+my_primestat()+" subpoint is "+VALUE_OF_PRIME_STAT;
  begin = begin +". Nonprime stat subpoint is "+VALUE_OF_NONPRIME_STAT+".";
  if (get_ronin())
    begin = begin +" Hagnk pulls are limited and their 'cost' is incorporated.";
  if (!can_eat())
    begin = begin +" You're on a pathed ascension, so you won't eat.";
  if (!can_drink())
    begin = begin +" You're on a pathed ascension, so you won't drink.";
  summarize(begin);
  if (SIM_CONSUME)
  {
    summarize("<b>Simulating only</b>; no purchases or food/drink/spleen consumption.");
  }
  boolean giveup = fooddone;

///////////Load historical pricing data
  if (GetPriceServer)
  {
    cli_execute("update prices http://zachbardon.com/mafiatools/updateprices.php?action=getmap");
    cli_execute("update prices http://nixietube.info/mallprices.txt");
  }

  string type = "";
  int max = 0;
  boolean can_do = false;
////////// 1 is eat
////////// 2 is drink
////////// 3 is spleen
////////// 4 is overdrink
  for iteration from 1 upto 4 by 1
  {
    if (iteration == 1)
    {
      type = "food";
      max = foodMax;
      can_do = can_eat();
    }
    else if (iteration == 2)
    {
      type = "drink";
      max = drinkMax;
      can_do = can_drink();
    }
    else if (iteration == 3)
    {
      type = "spleen";
      max = spleenMax;
      can_do = true;
    }
    else if (iteration == 4)
    {
      type = "drink";
      max = 999999;
      can_do = overdrink && can_drink();
    }
    else abort("Bad iteration.");
    verbose("Pass "+iteration+": "+type+".");
    if (can_do && (doneness(type) < max))
    {
      //Nuke grub so you can reload it
      clear(grub);
      //Start summarizing and filtering
      if (iteration != 4)
	summarize(type+": At "+doneness(type)+", consuming to "+max+".");
      else
	summarize("At drunkenness of "+doneness(type)+". Overdrinking.");
      verbose("Loading "+type+" map from Mafia's datafiles");
      update_from_mafia(type);
      verbose("Filtering by type");
      filter_type(type);
      verbose("Filtering by level");
      filter_level();
      verbose("Finding prices");
      set_prices();
      verbose("Setting values");
      foreach i in grub
      { grub[i].value = value(grub[i], (iteration == 4)); }
      ConsumptionReportIndex = 1;
      giveup = false;
      boolean triedmojo = false;
      while (!giveup && (doneness(type) < max)) //each pass, consume until full
      {
	verbose("Choosing "+type+" to consume.");
	filter_final(max, doneness(type));
	int to_consume = best();  
	if (to_consume == 0)
	{
	  verbose("No "+type+" available that's good enough. Moving on.");
	  giveup = true;
	}
	else
	{
	  string consume_entry = format_entry(grub[to_consume]);
	  logprint(consume_entry);
	  if (pause > 0)
	  {
	    verbose("Waiting to consume...");
	    print_html(consume_entry);
	    wait(pause);
	  }
	  if (consumeone(grub[to_consume], type))
	  {
	    summarize(ConsumptionReportIndex+": "+consume_entry);
	    ConsumptionReportIndex = ConsumptionReportIndex + 1;
	    if (iteration == 4)
	    { giveup = true; }
	  }
	  else
	  {
	    foreach i in grub // update new values (milk, ode in effect)
	    { grub[i].value = value(grub[i], (iteration == 4)); }	
	    print_html("FAIL: "+consume_entry);
	    logprint("FAIL: "+consume_entry);
	  }
	  //you might have learned something (e.g. price)
	  grub[to_consume].value = value(grub[to_consume], (iteration == 4));
	  //if you're spleening and partway done, consider mojo filters, 
	  //based on the quality of your last spleenable.
	  if ((iteration == 3) && (get_spleen() > 5) && !triedmojo)
	  {
	    triedmojo = true;
	    filter_your_mojo(grub[to_consume]);
	    //TODO: you probably need to regenerate the map, because some items you can now use have been removed due to high fullness. Also, consider that you might use your last pull(s) on mojo filters, leaving you unable to pull the spleen item to use it!
	  }
	}
      }
      if (iteration == 1)
	fooddone = true;
      else if (iteration == 2)
	drinkdone = true;
      else if (iteration == 3)
	spleendone = true;
      else if (iteration == 4)
	overdrinkdone = true;
      else
	abort("Invalid iteration.");
    }
    else
      verbose("Skipping "+type+".");
  }
  ConsumptionReportIndex = 1;
  summarize("choc: Checking non-filling crimbo chocolates - all 3 kinds");
  get_choc();
  string finished = "Finished.  ";
  if (get_milk() || (have_effect($effect["ode to booze"]) > 0))
  {
    finished = finished + "You had ";
    if (get_milk())
      finished = finished + " Milk of Magnesium";
    if ((have_effect($effect["ode to booze"]) > 0))
      finished = finished + "-Ode to Booze";
    finished = finished + " in effect.  Adventures listed above does not reflect that, but this does:";
  }
  summarize(finished);
  finished = "Spent ";
  finished = finished + (startmeat - get_meat()) + " meat.  Gained Fullness: ";
  finished = finished + (get_fullness() - startfullness) + ".  Inebriety: ";
  finished = finished + (get_inebriety() - startinebriety) + ".  Spleen: ";
  finished = finished + (get_spleen() - startspleen) + ".  Adventures: ";
  finished = finished + (get_adventures() - startadventures) + ".  Muscle: ";
  finished = finished + (get_muscle() - startmuscle) + ".  Moxie: ";
  finished = finished + (get_moxie() - startmoxie) + ".  Mysticality: ";
  finished = finished + (get_mysticality() - startmysticality)+".";
  summarize(finished);
  summarize("Eating, drinking, and spleening complete.  Commence merrymaking (at your own discretion).");
  print("******************************************");
  print("Now, to recap...");
  print("******************************************");
  print_html(finalsummary);
  logprint(finalsummary);
  cli_execute("outfit checkpoint");
  if (tempMood != "NONENONENONE")
  {
	print("Now restoring previous mood ...");
	cli_execute("mood " + tempMood);
	cli_execute("mood execute");
  }
}

//This would be the version for people who want full parameter control when 
//they call it... see the PREFERENCES section at the top for documentation 
//to see what does what.
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
  USE_INV = use_inv_p; 
  USE_CLOSET = use_closet_p; 
  USE_STORAGE = use_storage_p; 
  SIM_CONSUME = sim_consume_p;
  SUPRESS_OVERDRINK = supress_overdrink_p;
  SHOP = shop_p;
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

//If you want to include eatdrink.ash in your scripts, you can call eatdrink with a more common set of additional paramters by using this convention:
void eatdrink(int foodMax, int drinkMax, int spleenMax, boolean overdrink, int advmeat, int primemeat, int offmeat, int pullmeat, boolean sim)
{
  VALUE_OF_ADVENTURE = advmeat;   
  VALUE_OF_PRIME_STAT = primemeat;
  VALUE_OF_NONPRIME_STAT = offmeat; //You probably care less about it
  COST_OF_PULL = pullmeat;
  SIM_CONSUME = sim;
  eatdrink(foodMax, drinkMax, spleenMax, overdrink);
}

void main (int foodMax, int drinkMax, int spleenMax, boolean overdrink, boolean sim)
{
  SIM_CONSUME = sim;
  eatdrink(foodMax, drinkMax, spleenMax, overdrink);
}
