import bumcheekascend.ash;


void advent()
{
	string advent=visit_url("campground.php?action=advent");
	foreach num in $ints[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
	{
		if(contains_text(advent, "whichadvent="+num))
			advent=visit_url("campground.php?preaction=openadvent&whichadvent="+num);
	}
}

void crimbo_mining_camp_prep()
{	
	string max_str="maximize items";
	if(my_primestat()==$stat[moxie])
		max_str += ", -melee";
	else if(my_primestat()==$stat[muscle])
		max_str += ", +melee";

	if(i_a("pantsgiving")>0 && get_property("_pantsgivingFullness").to_int()<2)
	{
		if(get_property("_crimbonium_itemp_outfit").to_boolean())
			cli_execute("outfit crimbonium_itemp");
		else
		{
			max_str += ", +equip pantsgiving";
			cli_execute(max_str);
			cli_execute("outfit save crimbonium_itemp");
			set_property("_crimbonium_itemp_outfit","true");
		}
	}
	else
	{
		if(get_property("_crimbonium_item_outfit").to_boolean())
			cli_execute("outfit crimbonium_item");
		else
		{
			cli_execute(max_str);
			cli_execute("outfit save crimbonium_item");
			set_property("_crimbonium_item_outfit","true");
		}
	}
	
	setFamiliar("items");
	setMood("i");
	cli_execute("mood execute");
	if(have_effect($effect[beaten up])>0)
		cli_execute("restore hp");
	cli_execute("mcd 0");
}

void crimbo_mining_camp()
{	
	adventure(1, $location[The Crimbonium Mining Camp]);		
}

int[int] crimbo_mine_prep()
{
	string max_str="maximize hp regen min, hp regen max, outfit High-Radiation Mining Gear";
	
	if(get_property("_crimbonium_regen_outfit").to_boolean())
		cli_execute("outfit crimbonium_regen");
	else
	{
		cli_execute(max_str);
		cli_execute("outfit save crimbonium_regen");
		set_property("_crimbonium_regen_outfit","true");
	}
	cli_execute("mood apathetic");
	
//	if(have_effect($effect[crimbonar])==0 && have_effect($effect[object detection])==0)
//		cli_execute("use potion of detection");
	
	// Seed ore locations with what mafia knows about.
	int[int] oreLocations;
	string mineLayout = get_property("mineLayout5");
	string goalString="nugget of Crimbonium";
	int start = 0;
	while (true) {
		int num_start = index_of(mineLayout, '#', start);
		if (num_start == -1) break;
		int num_end = index_of(mineLayout, '<', num_start);
		if (num_end == -1) break;
		int end = index_of(mineLayout, '>', num_end);
		if (end == -1) break;

		if (contains_text(substring(mineLayout, num_end, end), goalString)) {
			int spot = to_int(substring(mineLayout, num_start + 1, num_end));
			oreLocations[count(oreLocations)] = spot;
		}
		start = end;
	}
	
	return oreLocations;
}

int[int] crimbo_mine(int[int] oreLocations, string mine)
{
	boolean rowContainsEmpty(string mine, int y) {
		for x from 1 to 6 {
			if (contains_text(mine, "Open Cavern (" + x + "," + y + ")"))
				return true;
		}

		return false;
	}

	boolean canMine(string mine, int x, int y, boolean onlySparkly) {
		if (x < 0 || x > 7 || y < 0 || y > 7) return false;
		int index = x + y * 8; 
		boolean clickable = (index_of(mine, "mining.php?mine=5&which=" + index + "&") != -1);

		if (!clickable || !onlySparkly) return clickable;

		return contains_text(mine, "Promising Chunk of Wall (" + x + "," + y + ")");
	}

	int adjacentSparkly(string mine, int index) {
		int x = index % 8;
		int y = index / 8;

		if (canMine(mine, x, y - 1, true)) return index - 8;
		if (canMine(mine, x - 1, y, true)) return index - 1;
		if (canMine(mine, x + 1, y, true)) return index + 1;
		if (canMine(mine, x, y + 1, true)) return index + 8;
		return - 1;
	}

	int findSpot(string mine, boolean[int] rows, boolean[int] cols) {
		foreach sparkly in $booleans[true, false] {
			foreach y in cols {
				foreach x in rows {
					if (canMine(mine, x, y, sparkly))
						return x + y * 8;
				}
			}
		}
		return -1;
	}

	if (my_hp() == 0) visit_url("galaktik.php?pwd&action=curehp&quantity=1");
	if (contains_text(mine, "You can't mine without the proper equipment.")) abort("Couldn't equip mining gear.");

	boolean willCostAdventure = contains_text(mine, "takes one Adventure.");
	if (my_adventures() == 0 && willCostAdventure)
	{
		cli_execute("shower "+my_primestat());
		abort("No adventures left :(");
	}

	int choice = -1;
	string why = "Mining around found ore";
	// Ore is always coincident, so look nearby if we've aleady found some.
	if (count(oreLocations) > 0) {
		foreach key in oreLocations {
			choice = adjacentSparkly(mine, oreLocations[key]);
			if (choice != -1)
				break;
		}
	}


	// Prefer mining the middle first.  It leaves more options.
	boolean[int] rows = $ints[3, 4, 2, 5, 1, 6];
	// First, try to mine up to the top four rows if we haven't yet.
	if (choice == -1 && !rowContainsEmpty(mine, 6)) {
		choice = findSpot(mine, rows, $ints[6]);
		why = "Mining upwards";
	} 
	if (choice == -1 && !rowContainsEmpty(mine, 5)) {
		choice = findSpot(mine, rows, $ints[5]);
		why = "Mining upwards";
	}
			
	// Top three rows contain most ore.  Fourth row may contain ore.
	// Prefer second row and digging towards the middle because it
	// opens up the most potential options.  This could be more
	// optimal, but it's not a bad heuristic.
	if (choice == -1) {
		choice = findSpot(mine, rows, $ints[2, 3, 1, 4]);
		why = "Mining top four rows";
	}
	// There's only four pieces of the same ore in each mine.
	// Maybe you accidentally auto-sold them or something?
	if (choice == -1 || count(oreLocations) == 6) {
		print("BCC: Resetting mine!", "purple");
		visit_url("mining.php?mine=5&reset=1&pwd");
		oreLocations.clear();
		return oreLocations;
	}
	string goalString="nugget of Crimbonium";
	print(why + ": " + (choice % 8) + ", " + (choice / 8) + ".", "purple");
	string result = visit_url("mining.php?mine=5&which=" + choice + "&pwd");
	if (index_of(result, goalString) != -1) {
		oreLocations[count(oreLocations)] = choice;
	}
	return oreLocations;
}

int update_mold_counter(int num_molds, int turns_since_mold_drop)
{
	//update turns since mold drop
	if(num_molds+1 == i_a("cylindrical mold"))
	{
		turns_since_mold_drop = 0;
	}
	else if(num_molds == i_a("cylindrical mold"))
	{
		turns_since_mold_drop += 1;
	}
	else
	{
		abort("num molds went from "+num_molds+" to "+i_a("cylindrical mold"));
	}
	set_property("_turns_since_mold_drop",turns_since_mold_drop);
	return i_a("cylindrical mold");
}

void crimbonium()
{
	int turns_since_mold_drop = get_property("_turns_since_mold_drop").to_int();
	int num_molds = i_a("cylindrical mold");
	
	while(my_adventures()>0)
	{
		if(my_fullness() < fullness_limit() || my_inebriety()<inebriety_limit() || my_spleen_use() < spleen_limit())
			cli_execute("eatdrink_simon false");
	
		//use the oil
		while(i_a("flask of tainted mining oil")>0 && have_effect($effect[Oily Legs])==0 && have_effect($effect[loose joints])==0)
		{
			if(turns_since_mold_drop>30)
			{
				abort("It's been "+turns_since_mold_drop+" turns since we got a mold to drop, maybe it's time to give up");
			}
			use(1,$item[flask of tainted mining oil]);
		}
		
		//if we got a mining buff, use it
		if(have_outfit("High-Radiation Mining Gear") && have_effect($effect[Oily Legs])>0 && my_adventures()>0)
		{
			int[int] oreLocations = crimbo_mine_prep();
			string mine = visit_url("place.php?whichplace=desertbeach&action=db_crimbo14mine");
			boolean willCostAdventure = contains_text(mine, "takes one Adventure.");
			while(have_outfit("High-Radiation Mining Gear") && (have_effect($effect[Oily Legs])>0 || !willCostAdventure))
			{
				print("using up oily legs in mine","purple");
				oreLocations = crimbo_mine(oreLocations,mine);
				mine = visit_url("place.php?whichplace=desertbeach&action=db_crimbo14mine");
				willCostAdventure = contains_text(mine, "takes one Adventure.");
			}
		}
		//if we got robo drop buff, use it
		else if(have_effect($effect[loose joints])>0)
		{
			crimbo_mining_camp_prep();
			while(have_effect($effect[loose joints])>0 && my_adventures()>0)
			{
				if(turns_since_mold_drop>30)
				{
					abort("It's been "+turns_since_mold_drop+" turns since we got a mold to drop, maybe it's time to give up");
				}
				print("using up robo drop buff in mining camp. Have "+num_molds+" molds (turns since drop ="+turns_since_mold_drop+")","purple");
//				cli_execute("shower "+my_primestat());
				crimbo_mining_camp();
				
				num_molds =  update_mold_counter(num_molds, turns_since_mold_drop);
				turns_since_mold_drop=get_property("_turns_since_mold_drop").to_int();

			}
		}
		//or try to get some oil
		else
		{
	//		abort("Out of oil, maybe can share some");
			crimbo_mining_camp_prep();
			print("trying to get buff potion. Have "+num_molds+" molds (turns since drop ="+turns_since_mold_drop+")","purple");
			if(turns_since_mold_drop>30)
			{
				abort("It's been "+turns_since_mold_drop+" turns since we got a mold to drop, maybe it's time to give up");
			}
			crimbo_mining_camp();
			num_molds =  update_mold_counter(num_molds, turns_since_mold_drop);
			turns_since_mold_drop=get_property("_turns_since_mold_drop").to_int();
		}
	}
}

void crimbo14()
{
	advent();
	if(pvp_attacks_left()>0 && my_name()=="twistedmage" && have_effect($effect[Oily Legs])==0 && have_effect($effect[loose joints])==0)
		cli_execute("pvp.ash");
	
	//use leftover fuel rods, then get todays fuel rods, then use them
	crimbonium();
}

void main()
{
	crimbo14();
}