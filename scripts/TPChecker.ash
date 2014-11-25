// Tiny Plastic Series 1 and 2 Checker
// TPChecker.ash
// version 1.3

// By Spiny Twizzler and Rosa N.

// This is an informational script that tracks whether or not you have the 
// various Tiny Plastics for series one and two. You can have it check for just
// one series or both. The default behavior is to check for both.

// The script checks all of your possessions: your Display Case (if you have one),
// Hagnks, Inventory, Closet, and Equipped items. It does NOT check your store
// (if you have one). It will check mall_price for each item if historical_price
// data is older than two days.

// You will easily be able to see if you have at least one of each item in your 
// Display Case. If you possess all the plastics in a series, you will be advised,
// accordingly to your situation, in regards to the relevant trophy.

// An optional purchase mode has been added. While set to true, it will use your 
// defined total budget to purchase missing plastics in order of mall price. You may
// disable Rares from consideration, though if your budget isn't high enough, it 
// shouldn't make a difference anyhow ;)

// Revision History:
// 9/15/09 v1.0 Public Release
// 9/16/09 v1.1 Veracity refactored script, bug fix regarding trophy detection
// 9/18/09 v1.2 Implementation of purchase mode
// 9/19/09 v1.3 Improved logic for purchase mode

//***********************************************************************************
// User settings:
boolean TP1 = true; 		// Set to true to check for Tiny Plastic Series One.
boolean TP2 = true; 		// Set to true to check for Tiny Plastic Series Two.
boolean TP3 = true; 		// Set to true to check for Tiny Plastic Series Three.
boolean MP1 = true; 		// Set to true to check for Tiny Plastic Series Three.
boolean DC1 = true; 		// Set to true to check for Tiny Plastic Series Three.
boolean FF1 = true; 		// Set to true to check for Tiny Plastic Series Three.
boolean BuyFromMall = false; 	// Set to true if you want to be able to purchase from the mall
boolean BuyRares = false; 	// Set to true if you want to include Rares in your purchases
boolean MoveNeeded = true; //if tp not in display case, but is in stash, move to DC
int TPBudget = 10000; 		// Input total overall budget for the script to use for purchases
float MallPriceCushion = 1.1;	// This is a safety measure so that in the event a price
				// inflates during purchasing mode, you are protected
				// from going over budget.

				// As good practice with any script that handles purchasing things:
				// For best protection of your meat, keep extra meat in your closet!
//
//***********************************************************************************

boolean BuyIt = BuyFromMall && can_interact();

item [int] series_one;
series_one [1] = $item[tiny plastic disco bandit];
series_one [2] = $item[tiny plastic accordion thief];
series_one [3] = $item[tiny plastic turtle tamer];
series_one [4] = $item[tiny plastic seal clubber];
series_one [5] = $item[tiny plastic pastamancer];
series_one [6] = $item[tiny plastic sauceror];
series_one [7] = $item[tiny plastic mosquito];
series_one [8] = $item[tiny plastic leprechaun];
series_one [9] = $item[tiny plastic levitating potato];
series_one [10] = $item[tiny plastic angry goat];
series_one [11] = $item[tiny plastic sabre-toothed lime];
series_one [12] = $item[tiny plastic fuzzy dice];
series_one [13] = $item[tiny plastic spooky pirate skeleton];
series_one [14] = $item[tiny plastic barrrnacle];
series_one [15] = $item[tiny plastic howling balloon monkey];
series_one [16] = $item[tiny plastic stab bat];
series_one [17] = $item[tiny plastic grue];
series_one [18] = $item[tiny plastic blood-faced volleyball];
series_one [19] = $item[tiny plastic ghuol whelp];
series_one [20] = $item[tiny plastic baby gravy fairy];
series_one [21] = $item[tiny plastic cocoabo];
series_one [22] = $item[tiny plastic star starfish];
series_one [23] = $item[tiny plastic ghost pickle on a stick];
series_one [24] = $item[tiny plastic killer bee];
series_one [25] = $item[tiny plastic Cheshire bat];
series_one [26] = $item[tiny plastic coffee pixie];
series_one [27] = $item[tiny plastic bitchin' meatcar];
series_one [28] = $item[tiny plastic hermit];
series_one [29] = $item[tiny plastic Boris];
series_one [30] = $item[tiny plastic Jarlsberg];
series_one [31] = $item[tiny plastic Sneaky Pete];
series_one [32] = $item[tiny plastic Susie];

item [int] series_two;
series_two [1] = $item[tiny plastic Naughty Sorceress];
series_two [2] = $item[tiny plastic Ed the Undying];
series_two [3] = $item[tiny plastic Lord Spookyraven];
series_two [4] = $item[tiny plastic Dr. Awkward];
series_two [5] = $item[tiny plastic protector spectre];
series_two [6] = $item[tiny plastic Baron von Ratsworth];
series_two [7] = $item[tiny plastic Boss Bat];
series_two [8] = $item[tiny plastic Knob Goblin King];
series_two [9] = $item[tiny plastic Bonerdagon];
series_two [10] = $item[tiny plastic The Man];
series_two [11] = $item[tiny plastic The Big Wisniewski];
series_two [12] = $item[tiny plastic Felonia];
series_two [13] = $item[tiny plastic Beelzebozo];
series_two [14] = $item[tiny plastic conservationist hippy];
series_two [15] = $item[tiny plastic 7-foot dwarf];
series_two [16] = $item[tiny plastic angry bugbear];
series_two [17] = $item[tiny plastic anime smiley];
series_two [18] = $item[tiny plastic apathetic lizardman];
series_two [19] = $item[tiny plastic astronomer];
series_two [20] = $item[tiny plastic beanbat];
series_two [21] = $item[tiny plastic blooper];
series_two [22] = $item[tiny plastic brainsweeper];
series_two [23] = $item[tiny plastic briefcase bat];
series_two [24] = $item[tiny plastic demoninja];
series_two [25] = $item[tiny plastic filthy hippy jewelry maker];
series_two [26] = $item[tiny plastic drunk goat];
series_two [27] = $item[tiny plastic fiendish can of asparagus];
series_two [28] = $item[tiny plastic Gnollish crossdresser];
series_two [29] = $item[tiny plastic handsome mariachi];
series_two [30] = $item[tiny plastic Knob Goblin bean counter];
series_two [31] = $item[tiny plastic Knob Goblin harem girl];
series_two [32] = $item[tiny plastic Knob Goblin mad scientist];
series_two [33] = $item[tiny plastic Knott Yeti];
series_two [34] = $item[tiny plastic lemon-in-the-box];
series_two [35] = $item[tiny plastic lobsterfrogman];
series_two [36] = $item[tiny plastic ninja snowman];
series_two [37] = $item[tiny plastic Orcish Frat Boy];
series_two [38] = $item[tiny plastic G Imp];
series_two [39] = $item[tiny plastic goth giant];
series_two [40] = $item[tiny plastic cubist bull];
series_two [41] = $item[tiny plastic scary clown];
series_two [42] = $item[tiny plastic smarmy pirate];
series_two [43] = $item[tiny plastic spiny skelelton];
series_two [44] = $item[tiny plastic Spam Witch];
series_two [45] = $item[tiny plastic spooky vampire];
series_two [46] = $item[tiny plastic taco cat];
series_two [47] = $item[tiny plastic undead elbow macaroni];
series_two [48] = $item[tiny plastic warwelf];
series_two [49] = $item[tiny plastic whitesnake];
series_two [50] = $item[tiny plastic XXX pr0n];
series_two [51] = $item[tiny plastic zmobie];
series_two [52] = $item[tiny plastic Protagonist];
series_two [53] = $item[tiny plastic Spunky Princess];
series_two [54] = $item[tiny plastic topiary golem];
series_two [55] = $item[tiny plastic senile lihc];
series_two [56] = $item[tiny plastic Iiti Kitty];
series_two [57] = $item[tiny plastic Gnomester Blomester];
series_two [58] = $item[tiny plastic Trouser Snake];
series_two [59] = $item[tiny plastic Axe Wound];
series_two [60] = $item[tiny plastic Hellion];
series_two [61] = $item[tiny plastic Black Knight];
series_two [62] = $item[tiny plastic giant pair of tweezers];
series_two [63] = $item[tiny plastic fruit golem];
series_two [64] = $item[tiny plastic fluffy bunny];


item [int] series_three;
series_three [1] = $item[tiny plastic Ancient Unspeakable Bugbear];
series_three [2] = $item[tiny plastic angry space marine];
series_three [3] = $item[tiny plastic batbugbear];
series_three [4] = $item[tiny plastic Battlesuit Bugbear Type];
series_three [5] = $item[tiny plastic bee swarm];
series_three [6] = $item[tiny plastic beebee gunners];
series_three [7] = $item[tiny plastic Beebee King];
series_three [8] = $item[tiny plastic beebee queue];
series_three [9] = $item[tiny plastic black ops bugbear];
series_three [10] = $item[tiny plastic blazing bat];
series_three [11] = $item[tiny plastic bugaboo];
series_three [12] = $item[tiny plastic Bugbear Captain];
series_three [13] = $item[tiny plastic buzzerker];
series_three [14] = $item[tiny plastic cavebugbear];
series_three [15] = $item[tiny plastic Charity the Zombie Hunter];
series_three [16] = $item[tiny plastic Clancy the Minstrel];
series_three [17] = $item[tiny plastic Father McGruber];
series_three [18] = $item[tiny plastic fire servant];
series_three [19] = $item[tiny plastic four-shadowed mime];
series_three [20] = $item[tiny plastic Hank North, Photojournalist];
series_three [21] = $item[tiny plastic hypodermic bugbear];
series_three [22] = $item[tiny plastic Lord Flameface];
series_three [23] = $item[tiny plastic moneybee];
series_three [24] = $item[tiny plastic mumblebee];
series_three [25] = $item[tiny plastic Norville Rogers];
series_three [26] = $item[tiny plastic peacannon];
series_three [27] = $item[tiny plastic Queen Bee];
series_three [28] = $item[tiny plastic Rene C. Corman];
series_three [29] = $item[tiny plastic Scott the Miner];
series_three [30] = $item[tiny plastic spiderbugbear];
series_three [31] = $item[tiny plastic The Free Man];
series_three [32] = $item[tiny plastic Wu Tang the Betrayer];



item [int] micro_one;
micro_one [1] = $item[Microplushie: Otakulone];
micro_one [2] = $item[Microplushie: Hippylase];
micro_one [3] = $item[Microplushie: Bropane];
micro_one [4] = $item[Microplushie: Sororitrate];
micro_one [5] = $item[Microplushie: Gothochondria];
micro_one [6] = $item[Microplushie: Raverdrine];
micro_one [7] = $item[Microplushie: Hobomosome];
micro_one [8] = $item[Microplushie: Ermahgerdic Acid];
micro_one [9] = $item[Microplushie: Dorkonide];
micro_one [10] = $item[Microplushie: Fauxnerditide];
micro_one [11] = $item[Microplushie: Hipsterine];


item [int] diecast_one;
diecast_one [1] = $item[tiny die-cast Bashful the Reindeer];
diecast_one [2] = $item[tiny die-cast Doc the Reindeer];
diecast_one [3] = $item[tiny die-cast Dopey the Reindeer];
diecast_one [4] = $item[tiny die-cast Grumpy the Reindeer];
diecast_one [5] = $item[tiny die-cast Happy the Reindeer];
diecast_one [6] = $item[tiny die-cast Sleepy the Reindeer];
diecast_one [7] = $item[tiny die-cast Sneezy the Reindeer];
diecast_one [8] = $item[tiny die-cast Zeppo the Reindeer];
diecast_one [9] = $item[tiny die-cast factory worker elf];
diecast_one [10] = $item[tiny die-cast gift-wrapping elf];
diecast_one [11] = $item[tiny die-cast middle-management elf];
diecast_one [12] = $item[tiny die-cast pencil-pusher elf];
diecast_one [13] = $item[tiny die-cast stocking-stuffer elf];
diecast_one [14] = $item[tiny die-cast Unionize the Elves Sign];
diecast_one [15] = $item[tiny die-cast CrimboTown Toy Factory];
diecast_one [16] = $item[tiny die-cast death ray in a pear tree];
diecast_one [17] = $item[tiny die-cast turtle mech];
diecast_one [18] = $item[tiny die-cast Swiss hen];
diecast_one [19] = $item[tiny die-cast killing bird];
diecast_one [20] = $item[tiny die-cast golden ring];
diecast_one [21] = $item[tiny die-cast goose a-laying];
diecast_one [22] = $item[tiny die-cast swarm a-swarming];
diecast_one [23] = $item[tiny die-cast blade a-spinning];
diecast_one [24] = $item[tiny die-cast arc-welding Elfborg];
diecast_one [25] = $item[tiny die-cast ribbon-cutting Elfborg];
diecast_one [26] = $item[tiny die-cast Rudolphus of Crimborg];
diecast_one [27] = $item[tiny die-cast Father Crimborg];
diecast_one [28] = $item[tiny die-cast Don Crimbo];
diecast_one [29] = $item[tiny die-cast Uncle Hobo];
diecast_one [30] = $item[tiny die-cast Father Crimbo];



item [int] five_factions1;
five_factions1 [1] = $item[Gary Claybender];
five_factions1 [2] = $item[Jared the Duskwalker];
five_factions1 [3] = $item[Duke Starkiller];
five_factions1 [4] = $item[Professor What];
five_factions1 [5] = $item[Captain Kerkard];


record recMissingList {
	int price;
	item plastic; // to keep this plastic item with its associated price when we sort by price
};

//***********************************************************************************

int cost(item plastic) {
	if (historical_age(plastic) > 2) {
		return mall_price(plastic);
	}
	return historical_price(plastic);
}

//***********************************************************************************

//boolean have_display() {
//	if (!contains_text( visit_url("charsheet.php"), "Display Case"))
//		return false;
//	else
//		return true;
//}

//***********************************************************************************

boolean CanAfford(item plastic) {
	if ((BuyIt) && (my_meat() >= TPBudget) && ((mall_price(plastic)*MallPriceCushion) <= (TPBudget)))
		return true;
	else
		return false;
}

//***********************************************************************************

void check_series(string title, string num1, string num2, item [int] series, string trophy_page, string trophy_name,int num_needed)
{
	boolean have_trophy = contains_text(trophy_page, trophy_name);
	boolean HaveDisplay = have_display();
	int Missing = 0;
	int TotalInCase = 0;
	recMissingList [item] MissingList;
	int price = 0;
	int pause = 3;
	buffer table;
	boolean IsInCase;
	int qty;

	print("Checking your possessions for " + title + " items...", "green");
	print("");	

	sort series by to_lower_case(value);

	table.append("<TABLE BORDER='1' CELLPADDING='2'>");
	table.append("<TR bgcolor='#33CCCC'>");
	table.append("<TD align='left'><B>TINY PLASTIC SERIES "+ num1 + "</B></TD>");
	table.append("<TD align='right'><B>QTY</B></TD>");
	table.append("<TD align='center'><B>IN DC?</B></TD>");
	table.append("<TD align='right'><B>COST</B></TD>");
	table.append("</TR>");

	foreach i, plastic in series {
		IsInCase = false;

		qty = storage_amount(plastic) +
			closet_amount(plastic) +
			item_amount(plastic) +
			stash_amount(plastic) +
			equipped_amount(plastic);

			
		price = cost(plastic);

		if (HaveDisplay) {
			int dcount = display_amount(plastic);
			if (dcount > 0) {
				qty = qty + dcount;
				TotalInCase = TotalInCase + dcount;
				IsInCase = true;
			}
			
			//move to/from dc
			if(MoveNeeded)
			{
				//put into dc if needed
				if(!have_trophy && !IsInCase && qty>0)
				{
					print("putting "+plastic+" in dc");
					put_display(1,plastic);
				}
				//take them back out if not needed
				if(have_trophy && dcount>0)
				{
					print("taking "+plastic+" from dc");
					take_display(dcount,plastic);
				}
			}
		}
		
		
		
		if (qty < num_needed) {
			Missing = Missing + 1;
			MissingList[plastic].price = price;
			MissingList[plastic].plastic = plastic;
			// print("Adding " + MissingList[plastic].price + " to " + MissingList[plastic].plastic); // For debugging purposes
		}

		if (qty >= num_needed)
			table.append("<TR>");
		else
			table.append("<TR bgcolor='#ddb1ec'>");
		table.append("<TD align='left'>"+(plastic)+"</TD>");
		table.append("<TD align='right'>"+qty+"</TD>");
		if (IsInCase) {
			table.append("<TD align='center'>yes</TD>");
		}
		else {
			if (Qty >= num_needed) {
				table.append("<TD align='center' bgcolor='#ff6565'>no</TD>");
			}
			else {
				table.append("<TD align='center'>no</TD>");
			}
		}
		table.append("<TD align='right'>"+price+"</TD>");
		table.append("</TR>");
	}
		
	table.append("</TABLE>");

	print_html(table.to_string());
	print("");

	print_html("You are <font color='red'>missing " + Missing + "</font> out of <font color='purple'>" + count(series) +"</font> Tiny Plastics from series " + num2 );
	print("");

	if ((BuyIt) && (Missing > 0)) {
		if (TPBudget < 100) {
			print("Your current TPBudget is too low. Exiting Shopping phase", "red");
			return;
		}
		if (!BuyRares) {
			print("Removing rares from shopping list...","green");
			if (num1 == "1") {
				remove MissingList [$item[tiny plastic Boris]];
				remove MissingList [$item[tiny plastic Jarlsberg]];
				remove MissingList [$item[tiny plastic Sneaky Pete]];
				remove MissingList [$item[tiny plastic Susie]];
			}
			if (num1 == "2") {
				remove MissingList [$item[tiny plastic Naughty Sorceress]];
				remove MissingList [$item[tiny plastic Ed the Undying]];
				remove MissingList [$item[tiny plastic Lord Spookyraven]];
				remove MissingList [$item[tiny plastic Dr. Awkward]];
				remove MissingList [$item[tiny plastic protector spectre]];
			}
			if (num1 == "3") {
				remove MissingList [$item[tiny plastic four-shadowed mime]];
				remove MissingList [$item[tiny plastic Bugbear Captain]];
				remove MissingList [$item[tiny plastic Rene C. Corman]];
				remove MissingList [$item[tiny plastic Lord Flameface]];
			}
		}
		if (count(MissingList)==0) {
			print("There's nothing left in the shopping list to consider buying","green");
			return;
		}
		if (!user_confirm("Continue on to buy missing plastics?")) {
			abort("Shopping phase aborted by user");
		}	
		print("Going shopping...","blue");

		print("");

		sort MissingList by value.price;

		//foreach i, mlrec in MissingList {								// For debugging purposes
		//	print(mlrec.plastic + " " + mlrec.price);
		//}

		print("Number of missing items to shop for "+count(MissingList), "green");
		print("");
		foreach i, mlrec in MissingList {
			if (CanAfford(mlrec.plastic)) {
				price = mall_price(mlrec.plastic);
				//print("I would be buying " + mlrec.plastic + " at " + price,"blue"); // For debugging purposes
				buy (1, mlrec.plastic);
				TPBudget = TPBudget - price;
				print("");
				print("Budget is now " +TPBudget, "blue");
				if (TPBudget < 100) {
					print("Your current TPBudget is too low. Exiting Shopping phase", "red");
					break;
				}
			}
			else {
				print("Insufficient budget and/or meat on hand", "#33CCCC");
				print("Exiting shopping phase", "red");
				break;
			}
		}
	}

	if (Missing > 0) {
		return;
	}

	if (have_trophy) {
		print("You already have the " + trophy_name);
		return;
	}

	if (!have_display()) {
		print("You need to purchase a Display Case to put your Tiny Plastics in if you wish to purchase a trophy.", "red");
		return;
	}

	if (TotalInCase == count(series)) {
		print("Visit the Trophy Hut to buy your " + trophy_name);
	}
	else {
		print("You have all the necessary plastics for the " + trophy_name + ". Be sure you have one each in your Display Case.");
	}
}

//***********************************************************************************

void main()
{
	string trophy_page = visit_url("trophies.php");

	print("This is an informational script with optional support for purchasing missing Tiny Plastics from the mall.", "green");
	print("Default for purchasing is set to false for your protection. If you wish to purchase items with this script,", "green");
	print("Please set your variables at the beginning of the script as you like them:", "green");
	print("***********************************************************************************************************", "green");
	print("Current settings are... ", "blue");
	print("TP1 = " + TP1, "#33CCCC");
	print("TP2 = " + TP2, "#33CCCC");
	print("TP3 = " + TP3, "#33CCCC");
	print("MP1 = " + MP1, "#33CCCC");
	print("DC1 = " + MP1, "#33CCCC");
	print("DC1 = " + FF1, "#33CCCC");
	print("BuyFromMall = " + BuyFromMall, "#33CCCC");
	print("BuyRares = " + BuyRares, "#33CCCC");
	print("TPBudget = " + TPBudget, "#33CCCC");
	print("MallPriceCushion = " + MallPriceCushion, "#33CCCC");
	print("");

	if (TP1) {
		check_series("Tiny Plastic Series One", "1", "one", series_one, trophy_page, "Tiny Plastic Trophy",3);
		print("");
	}

	if (TP2) {
		check_series("Tiny Plastic Series Two", "2", "two", series_two, trophy_page, "Two-Tiered Tiny Plastic Trophy",3);
		print("");
	}

	if (TP3) {
		check_series("Tiny Plastic Series Three", "3", "three", series_three, trophy_page, "Three-Tiered Tiny Plastic Trophy",1);
		print("");
	}

	if (MP1) {
		check_series("Microplushie Series One", "MP1", "one", micro_one, trophy_page, "Fantastic Voyager",1);
		print("");
	}

	if (DC1) {
		check_series("Die-cast Series One", "DC1", "one", diecast_one, trophy_page, "Alia Iacta Est",1);
		print("");
	}
	if (FF1) {
		check_series("Five Factions Series One", "FF1", "one", five_factions1, trophy_page, "Alia Iacta Est",1);
		print("");
	}
	print("Tiny Plastic processing completed.","green");
}
