import bumcheekascend.ash;

int floor_to_exp=1;
boolean pref_schems=false;

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

void crimbo_handin(int row, int n)
{
	if(n==0)
		return;
	print("handing in "+n+" "+row);
	string dump = visit_url("shop.php?whichshop=crimbo14turnin&action=buyitem&quantity="+n+"&whichrow="+row);
	if(!contains_text(dump,"You acquire"))
	{
		print("failed to hand in\n html="+dump, "red");
		abort("");
	}
}

void use_schematic(item sc, boolean req)
{
	if(get_property("CRIMBO14_SCHEMATIC_"+sc.to_int()).to_boolean())
	{
		if(available_amount(sc)>0)
			print("Have spare "+sc+" ("+sc.to_int()+")","purple");
		return;
	}
	if(available_amount(sc)==0)
	{
		print("still need "+sc+" ("+sc.to_int()+")","orange");
		if(mall_price(sc)<10000)
			buy(1,sc);
		else
		{
			print("too expensive to buy","orange");
			return;
		}
	}
	//string dump = visit_url("");
	print("using "+sc,"purple");
	use(1,sc);
	set_property("CRIMBO14_SCHEMATIC_"+sc.to_int(), "true");
}

void crimbo_credits()
{
	print("handing in for credits");
	
	//turn in stuff
	while(i_a("peppermint tailings")>9 || i_a("recovered elf toothbrush")>0 || i_a("recovered elf magazine")>0 || i_a("recovered elf sleeping pills")>0 || i_a("recovered elf underpants")>0 || i_a("recovered elf pocketwatch")>0 || i_a("recovered elf wallet")>0 || i_a("recovered elf photo album")>0 || i_a("recovered elf smartphone")>0)
	{
		crimbo_handin(397, i_a("peppermint tailings")/10);
		crimbo_handin(390, i_a("recovered elf toothbrush"));
		crimbo_handin(389, i_a("recovered elf magazine"));
		crimbo_handin(391, i_a("recovered elf sleeping pills"));
		crimbo_handin(392, i_a("recovered elf underpants"));
		crimbo_handin(394, i_a("recovered elf pocketwatch"));
		crimbo_handin(393, i_a("recovered elf wallet"));
		crimbo_handin(395, i_a("recovered elf photo album"));
		crimbo_handin(396, i_a("recovered elf smart phone"));
		cli_execute("inventory refresh");
	}
	//vend
	string dump;
	int req_hat=1;
	int req_pants=1;
	int req_wep=1;
	if(my_name()=="twistedmage")
	{
		req_hat=2;
		req_pants=2;
		req_wep=3;
	}
	
	if(i_a("crimbo credit")>=75 && i_a("toy Crimbot mega face")<req_hat)
	{
		print("buying crimbot face","purple");
		dump = visit_url("shop.php?whichshop=crimbo14&action=buyitem&quantity=1&whichrow=401");
		cli_execute("inventory refresh");
	}
	if(i_a("crimbo credit")>=75 && i_a("toy Crimbot power glove")<req_wep)
	{
		print("buying crimbot power glove","purple");
		dump = visit_url("shop.php?whichshop=crimbo14&action=buyitem&quantity=1&whichrow=402");
		cli_execute("inventory refresh");
	}
	if(i_a("crimbo credit")>=75 && i_a("toy Crimbot super fist")==0)
	{
		print("buying crimbot super fist","purple");
		dump = visit_url("shop.php?whichshop=crimbo14&action=buyitem&quantity=1&whichrow=403");
		cli_execute("inventory refresh");
	}
	if(i_a("crimbo credit")>=75 && i_a("toy Crimbot rocket legs")<req_pants)
	{
		print("buying crimbot legs","purple");
		dump = visit_url("shop.php?whichshop=crimbo14&action=buyitem&quantity=1&whichrow=404");
		cli_execute("inventory refresh");
	}
		
	print("num crimbo credits="+i_a("crimbo credit"),"orange");
}

record bot_skills
{
	int pow;
	int zap;
	int blam;
	int roll;
	int run;
	int shield;
	int light;
	int lube;
	int hover;
	int freeze;
	int pinch;
	int decode;
	int burn;
	
	int left;
	int right;
	int torso;
	int legs;
};

string make_bot(int left, int right, int torso, int legs)
{
	if(left<0 || right<0 || torso<0 || legs<0)
		abort("unknown part code chosen");
	print("making bot");
	
	string dump = visit_url("place.php?whichplace=crimbo2014&action=c14_factory");
	dump = visit_url("choice.php?leftarm="+left+"&rightarm="+right+"&torso="+torso+"&propulsion="+legs+"&choice1=Deploy+this+Crimbot+%281+fuel+rod%2C+1+Adventure%29&whichchoice=991&option=1&pwd");
	if(!contains_text(dump, "You finalize the Crimbot's design and step up to the telepresence controls"))
	{
		print("failed to make robot. Page html was:\n"+dump,"red");
		abort("");
	}
	return dump;
}

bot_skills choose_bot(int floor)
{
	bot_skills bs;
		
	if(floor==1)
	{
		if(get_property("CRIMBO14_SCHEMATIC_7880").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7890").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7874").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7903").to_boolean())
		{
			bs.left = 7; //swiss arm
			bs.blam+=1;
			bs.pow+=1;
			bs.zap+=1;
			
			bs.right = 7; //grease / regular gun
			bs.blam+=1;
			bs.lube+=1;
			
			bs.torso = 11; //Refrigerator Chassis
			bs.shield+=5;
			bs.light+=1;
			bs.freeze+=1;
			
			bs.legs = 10; //Heavy Treads
			bs.shield+=2;
			bs.roll+=1;
			bs.pow+=1;
		}
		else if(get_property("CRIMBO14_SCHEMATIC_7880").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7886").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7868").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7901").to_boolean())
		{
			bs.left = 7; //swiss arm
			bs.blam+=1;
			bs.pow+=1;
			bs.zap+=1;
			
			bs.right = 3; //wrecking ball
			bs.pow+=1;
			bs.shield+=1;
			
			bs.torso = 5; //Military Chassis
			bs.shield+=3;
			bs.light+=1;
			bs.blam+=1;
			
			bs.legs = 8; //hoverjack
			bs.shield+=2;
			bs.hover+=1;
		}
		else if(get_property("CRIMBO14_SCHEMATIC_7879").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7890").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7868").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7901").to_boolean())
		{
			bs.left = 6; //mobile girder
			bs.shield+=3;
			
			bs.right = 7; //grease / regular gun
			bs.lube+=1;
			bs.blam+=1;
			
			bs.torso = 5; //Military Chassis
			bs.shield+=3;
			bs.light+=1;
			bs.blam+=1;
			
			bs.legs = 8; //hoverjack
			bs.shield+=2;
			bs.hover+=1;
		}
		else
			abort("Dont know what robot to make for floor 1");
	}
	else if(floor==2)
	{
		if(get_property("CRIMBO14_SCHEMATIC_7879").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7890").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7869").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7902").to_boolean())
		{
			bs.left = 6; //Mobile Girder
			bs.shield+=3;
			
			bs.right = 7; //grease / regular gun
			bs.lube+=1;
			bs.blam+=1;
			
			bs.torso = 6; //crab core
			bs.shield+=4;
			bs.pinch+=1;
			
			bs.legs = 9; //gun legs
			bs.blam+=1;
			bs.run+=2;
		}
		if(get_property("CRIMBO14_SCHEMATIC_7880").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7901").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7891").to_boolean())
		{
			bs.left = 7; //swiss arm
			bs.blam+=1;
			bs.pow+=1;
			bs.zap+=1;
			
			bs.right = 7; //grease / regular gun
			bs.lube+=1;
			bs.blam+=1;
			
			bs.torso = 6; //crab core
			bs.shield+=4;
			bs.pinch+=1;
			
			bs.legs = 8; //hoverjack
			bs.shield+=2;
			bs.hover+=1;
		}
		else
		{
			bs.left = 6; //mobile girder
			bs.shield+=3;
			
			bs.right = 5; //power stapler
			bs.zap+=1;
			bs.pinch+=1;
			
			bs.torso = 7; //dynamo head
			bs.shield+=4;
			bs.zap+=1;
			
			bs.legs = 6; //high speed fan
			bs.shield+=1;
			bs.hover+=1;
		}
	}
	else if(floor==3)
	{
		if(!pref_schems)
		{
			if(get_property("CRIMBO14_SCHEMATIC_7904").to_boolean()) // have rocket skirt
			{
				if(!(get_property("CRIMBO14_SCHEMATIC_7879").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7886").to_boolean() && get_property("CRIMBO14_SCHEMATIC_7873").to_boolean()))
					abort("pieces missing");
				bs.left = 6; //mobile girder
				bs.shield+=3;
				
				bs.right = 3; //wrecking ball
				bs.pow+=1;
				bs.shield+=1;
				
				bs.torso = 10; //Nerding Module
				bs.shield+=5;
				bs.decode+=1;
				
				bs.legs = 11; //Rocket Skirt
				bs.shield+=2;
				bs.hover+=1;
				bs.burn+=1;
			}
			else
			{
				if(get_property("CRIMBO14_SCHEMATIC_7894").to_boolean())
					abort("Pieces missing");
				bs.left = 6; //mobile girder
				bs.shield+=3;
				
				bs.right = 11; //lamp filler
				bs.lube+=1;
				bs.burn+=1;
				
				bs.torso = 10; //Nerding Module
				bs.shield+=5;
				bs.decode+=1;
				
				bs.legs = 8; //hoverjack
				bs.shield+=2;
				bs.hover+=1;
			}
		}
		else
		{
			if(get_property("CRIMBO14_SCHEMATIC_7904").to_boolean()) // have rocket skirt
			{
				bs.left = 6; //mobile girder
				bs.shield+=3;
				
				bs.right = 9; //cold shoulder
				bs.pow+=1;
				bs.freeze+=1;
				
				bs.torso = 10; //Nerding Module
				bs.shield+=5;
				bs.decode+=1;
				
				bs.legs = 11; //Rocket Skirt
				bs.shield+=2;
				bs.hover+=1;
				bs.burn+=1;
			}
			else
			{
				bs.left = 6; //mobile girder
				bs.shield+=3;
				
				bs.right = 9; //cold shoulder
				bs.pow+=1;
				bs.freeze+=1;
				
				bs.torso = 10; //Nerding Module
				bs.shield+=5;
				bs.decode+=1;
				
				bs.legs = 8; //hoverjack
				bs.shield+=2;
				bs.hover+=1;
			}
		}
	}
	else
		abort("unrecognised floor");
	
	return bs;
}

string bot_perform_action(string url, string outcome)
{
	string dump = visit_url(url);
	if(!contains_text(dump, outcome))
	{
		print("Bot action failed. Expected \""+outcome+"\" but html was\n"+dump,"red");
		abort("");
	}
	return dump;
}

int read_damage(string page)
{
	matcher dmg_mtch = create_matcher("Your Crimbot takes <b>(\\d*)</b> damage.", page);
	find(dmg_mtch);
	return group(dmg_mtch,1).to_int();
}

void floor1(bot_skills bs, string page)
{
	while(bs.shield>0)
	{
		//kill turret with blast
		if(contains_text(page, "The camera reveals a ceiling-mounted turret between your Crimbot and the door to the next room."))
		{
			if(bs.blam>0)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=RUN+BLAST.BAS","your Crimbot disables the turret");
			}
			else
				abort("dunno what to do");
		}
		//smash open crates
		else if(contains_text(page, "The camera reveals a big stack of metal bins between your Crimbot and its goal."))
		{
			if(bs.pow>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=%2Fbin%2Fbash","knock over the pile of crates");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=%2Fdev%2Fclimb","climbs to the top of the heap of crates. Once it's at the top, it tumbles down the other side and lands in a heap");
				bs.shield-=read_damage(page);
			}
		}
		//copy room
		else if(contains_text(page, "The camera reveals what was apparently once a copy room"))
		{
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=perl+eyes.pl","focuses on the document long enough for you to print a copy");
		}
		//flame jets
		else if(contains_text(page, "camera reveals a hallway whose walls are lined with flame"))
		{
			if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=gunup+fd+500+gundown","manages to bend most of the pipes shut by shooting them");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=repeat+10+%5B+fd+50+%5D","takes on a decidedly more post-apocalyptic appearance as it slowly gets more and more burned");
				bs.shield-=read_damage(page);
			}
		}
		//doorbot
		else if(contains_text(page, "The door you're trying to steer your Crimbot through turns out to be a robot."))
		{
			if(bs.pow>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=set+door_protocol+_PUNCH","easily punches the Doorbot open");
			}
			else if(bs.zap>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=set+door_protocol+_SHOCK","causing it to open violently with a shower of sparks and a metallic gasp.");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform3=set+door_protocol+_GO_AROUND","goes around the door, which involves plowing headfirst through a wall");
			}
		}
		//conveyor
		else if(contains_text(page, "The floor of the room your Crimbot is in is a maze of rapid conveyor belts, and the panel that controls their speed is on the opposite side of the room!"))
		{
			if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=maze.solve%28fast%29","shuts down the conveyor belts");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=maze.solve%28slow%29","clumsily navigates the moving walkways, falling all over itself");
				bs.shield-=read_damage(page);
			}
		}
		//lockers
		else if(contains_text(page, "You pause to wonder what kind of stuff they do in a Crimbo Elf gym"))
		{
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=open+locker%3B+get+all+from+locker%3B+n%3B","loots the locker (which doesn't turn out to contain much) and drops the spoils into a pneumatic recovery tube");
		}
		//wind
		else if(contains_text(page, "The slight wobble of the camera reveals that your Crimbot must traverse a wind tunnel to proceed."))
		{
			if(bs.pow>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=fan.speed%3D0","punches the fan until it stops blowing");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=gfortran+forward.f","wobbles slowly forward against the wind, repeatedly getting hit in the face with flying debris.");
				bs.shield-=read_damage(page);
			}
		}
		//mookbot
		else if(contains_text(page, "The camera reveals a confrontation between your Crimbot and a small but thuggish-looking robot."))
		{
			if(bs.blam>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=gun.shoot%28%29","s what somebody should have told that Mookbot.");
			}
			else if(bs.pow>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=blam_pow_socko","punches the Mookbot. The speaker relays a satisfying crunching sound.");
			}
			else
				abort("sleep it");
		}
		//sawblade
		else if(contains_text(page, "The camera reveals that your Crimbot is in a room dominated by a single giant fast"))
		{
			if(bs.run>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=pathfind%28HIGH_EVASION%29","skillfully pilot itself past the fast-moving sawblade.");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=do%2Bwhile%2B1%2Bwalkforward%2528%2529","moves as fast as it can, but it turns out to not be fast enough to avoid having some parts of it sawed off.");
				bs.shield-=read_damage(page);
			}
		}
		//bearings
		else if(contains_text(page, "The camera reveals that your Crimbot's only way forward is through a room that appears to be designated for loose ball bearing storage."))
		{
			if(bs.roll>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=vlc+drama.mp4","manages to traverse the entire floor, only falling down once.");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=vlc+comedy.avi","repeatedly falls down on the ball bearings");
				bs.shield-=read_damage(page);
			}
		}
		//bulkybot
		else if(contains_text(page, "The camera reveals an oversized but simple robot standing between your Crimbot and the way forward."))
		{
			if(bs.pow>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=for+%28%24i%3D1%3B%24i%3C10%3B%24i%2B%2B%29+punch%28%29%3B","s as easy as knocking over a vending machine");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=break%253B","manages to squeeze past the Bulkybot, but some of its electronic internal organs get squished in the process.");
				bs.shield-=read_damage(page);
			}
		}
		//rusted
		else if(contains_text(page, "camera reveals a big metal door that has been corroded by caustic chemicals to the point where it can no longer be opened normally"))
		{
			if(bs.lube>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=while+%281%29+shoot%28%29%3B","lubricates the latch on the door and easily opens it");
			}
			else if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=while+%281%29+shoot%28%29%3B","sized hole in the door, through which it then proceeds.");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform3=DEFAULT%3A","repeatedly smash itself against the wall next to the door until it finally breaks through.");
				bs.shield-=read_damage(page);
			}
		}
		//office space 
		else if(contains_text(page, "The camera reveals that staple of modern life"))
		{
		/*
			if(bs.pow>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=UNZIP+FILING.CAB","pounds on the file cabinet until it opens");
			}
			else
			{*/
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=open+%2Fhome%2Fdesktop"," watch as your Crimbot yanks a drawer out of the desk and overturns it into a pneumatic recovery tube.");
			//}
		}
		//dillema
		else if(contains_text(page, "The camera, by showing you both a desk and a restroom door, presents your Crimbot with the classic workplace choice"))
		{
			//skill -> page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=paper.shuffle%28%29","Even pretending to work yields a usable document");
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=break%3B+%2F%2F+restroom","and even finds a discarded object on the counter next to the sink");
		}
		//Zippybot
		else if(contains_text(page, "The camera reveals a fast-moving wheeled robot darting around on the floor in front of your Crimbot."))
		{
			if(bs.zap>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=floor+%3D+monkey%3B+monkey.shock%28%29%3B"," The Zippybot stops moving and starts comically emitting black smoke");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=wait%28200%29%3B","Your Crimbot tries to wait until the obnoxious little robot leaves, but ends up tripping over it anyway.");
				bs.shield-=read_damage(page);
			}
		}
		//dark closet
		else if(contains_text(page, "pretty dark inside, and you don't see any kind of light switch."))
		{
			if(bs.light>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=ILLUMINATE.EXE","is able to carelessly sweep two objects into a pneumatic recovery tube.");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=GRAB.COM","grabs a random object from a shelf and tosses it into a pneumatic recovery tube.");
			}
		}
		//war of gears
		else if(contains_text(page, "The camera reveals a room that clearly wasn't intended to be walked through -- the floor is a writhing and creaking mass of interlocked gears and cogs and stuff."))
		{
			if(bs.hover>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=break%3B+break%3B+break%3B","safely avoiding the gears and finding a loose schematic stuck against an air intake vent");
			}
			else if(bs.pow>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=break%3B+break%3B+break%3B","pounds the crap out of the gears until they stop turning.");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform3=while+%280%29+nothing%3B","getting gnawed off as it walks across the gears");
				bs.shield-=read_damage(page);
			}
		}
		//closing time
		else if(contains_text(page, "The camera reveals a long hallway, and a distant door slowly but surely grinding itself closed."))
		{
			if(bs.run>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=set+speed+%3D+gallop%3B","darts through the door before it closes, but stubs its toe on something on the other side");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=set+speed+%3D+mosey%3B","quite make it through the door in time, and ends up leaving a little bit of itself behind.");
				bs.shield-=read_damage(page);
			}
		}
		//security drone
		else if(contains_text(page, "The camera reveals that your Crimbot has been detained by a low-level hovering security robot."))
		{
			if(bs.blam>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=shoot%5B0%5D","dispatches the security drone");
			}
			else if(bs.zap>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=SHORTCIRCUIT.BAT","sound as your Crimbot scrambles the security drone's tiny metal mind.");
			}
			else
			{
				abort("mosey");
				bs.shield-=read_damage(page);
			}
		}
		//The Monster Masher!
		else if(contains_text(page, "The camera reveals that your Crimbot is in a room whose walls are slowly grinding closer together -- you must have accidentally directed it into some sort of trash compactor"))
		{
			if(bs.zap>=2)
			{
				abort("zap");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=return+null%3B","is rendered slightly narrower");
				bs.shield-=read_damage(page);
			}
		}
		//unhurt locker
		else if(contains_text(page, "re about to leave and resume exploring when you catch a glimpse of an unlocked footlocker near the tiny bed."))
		{
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=%2Fbin%2Fraid%2Flocker","flips over the foot locker, dumping its contents into a pneumatic recovery tube.");
		}
		//paperchase
		else if(contains_text(page, "maybe some kind of climate control malfunction combined with some kind of filing cabinet accident"))
		{
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","grabs one of the sheets and holds it in front of its camera long enough for you to make a printout");
		}
		//other
		else
		{
			print("unknown thing\n"+page,"red");
			abort("");
		}
	}
	print("bot died! Moving on","purple");
}

void floor2(bot_skills bs, string page)
{
	while(bs.shield>0)
	{
		//Compugilist
		if(contains_text(page, "The screen shows an imminent fight between your Crimbot and a robot that seems to have been optimized for fistfighting"))
		{
			if(bs.pow>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","wins a protracted boxing match against its opponent. You should charge people to watch this stuff");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","this doesn't make its opponent not a fighter");
				bs.shield-=read_damage(page);
			}
		}
		//Festively Armed
		else if(contains_text(page, "Festooned is a good word for it"))
		{
			if(bs.lube>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","leaving its dozens of guns pointed harmlessly at the ceiling");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","bedecked robot shoots a big hole in it");
				bs.shield-=read_damage(page);
			}
		}
		//Bot Your Shield
		else if(contains_text(page, "s just a security robot hiding behind a massive metal plate with a single hole in it"))
		{
			if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","levels an extremely precise shot through the hole in the Shieldbot");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","makes like a tree and stands still until the Shieldbot gets tired of pummeling it and leaves");
				bs.shield-=read_damage(page);
			}
		}
		//Whatcha Thinkin'?
		else if(contains_text(page, "A massive dome dominates"))
		{
			if(bs.zap>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","scrambling its eggs");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","AT WHAT COST");
				bs.shield-=read_damage(page);
			}
		}
		//The Corporate Ladder
		else if(contains_text(page, "The camera reveals that your Crimbot has made its way into a maintenance shaft"))
		{
			 page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","slowly ascends the ladder.");
		}
		//This Gym Is Much Nicer
		else if(contains_text(page, "The camera slowly pans across the locker room of the factory"))
		{
			if(pref_schems)
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","relays a picture of the schematic taped to the inside of a nerd elf");
			else
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","grabs some goodies out of a jock el");
		}
		//Still Life With Despair
		else if(contains_text(page, "The camera reveals the most common scene from modern life"))
		{
			if(pref_schems)
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","causing a schematic to appear on its screen");
			else
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","grabs some goodies out of the top drawer of the desk and tosses ");
		}
		//Hope You Have A Beretta
		else if(contains_text(page, "There are some technical manuals within reach"))
		{
			/*if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","shoots the straps of the backpack until it falls into a conveniently");
			}
			else
			{*/
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","carefully grabs the schematic and holds it in front of the camera");
			//}
		}
		//Off The Rails
		else if(contains_text(page, "The camera reveals a narrow railing above a treacherous fall"))
		{
			if(bs.roll>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","The camera wobbles thrillingly as");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","teeters on the edge of the abyss");
				bs.shield-=read_damage(page);
			}
		}
		//A Vent Horizon
		else if(contains_text(page, "your Crimbot is going to have to move past a vent spewing corrosive gas."))
		{
			if(bs.freeze>=1)
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","slowly being eaten away by the corrosive gas");
				bs.shield-=read_damage(page);
			}
		}
		//A Pressing Concern
		else if(contains_text(page, "The camera reveals that your Crimbot has gotten itself into a little bit of a pickle"))
		{
			if(bs.run>=2)
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","gets savaged by the press");
				bs.shield-=read_damage(page);
			}
		}
		//The Floor Is Like Lava
		else if(contains_text(page, "The camera reveals that your Crimbot has somehow landed in a foundry bucket filled with molten metal."))
		{
			if(bs.hover>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","floats just high enough over the molten metal that only the very bottom part of it gets melted");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","up as it sinks into the molten metal");
				bs.shield-=read_damage(page);
			}
		}
		//Pants in High Places
		else if(contains_text(page, "pants dangling from a catwalk"))
		{
			if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","shoots down the pants");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","clumsily hitting its head on a girder as it does.");
				bs.shield-=read_damage(page);
			}
		}
		//Cage Match
		else if(contains_text(page, "The camera shows a Crimbot schematic enclosed in an electrified cage."))
		{
			if(bs.zap>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","overloads the electric cage and faxes you a copy of the schematic inside.");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","tries to open the cage manually");
				bs.shield-=read_damage(page);
			}
		}
		//Birdbot is the Wordbot
		else if(contains_text(page, "like robot flying near the ceiling of the factory floor"))
		{
			if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","blasts the birdbot out of the sky");
			}
			else
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","");
				bs.shield-=read_damage(page);
			}
		}
		//Humpster Dumpster
		else if(contains_text(page, "The camera feed shows a rusted"))
		{
			if(bs.lube>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","greases open the dumpster, then presses the interior button that flushes its contents into a pneumatic recovery tube.");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","unable to open the dumpster and instead hits itself in the head with a crowbar.");
				bs.shield-=read_damage(page);
			}
		}
		//I See You
		else if(contains_text(page, "The camera reveals a security robot with the biggest eyes you"))
		{
			if(bs.light>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","blinding the security robot so thoroughly that it explodes");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","some kind of ridiculous nonsense protocol for a while");
				bs.shield-=read_damage(page);
			}
		}
		//other
		else
		{
			print("unknown thing\n"+page,"red");
			abort("");
		}
	}
	print("bot died! Moving on","purple");
	if(i_a("crimbot schematic: Swiss Arm") + i_a("crimbot schematic: Snow Blower") + i_a("crimbot schematic: Hoverjack") >1)
		abort("got one!");
}

void floor3(bot_skills bs, string page)
{
	while(bs.shield>0)
	{
		//Unfinished Business
		if(contains_text(page, "camera reveals a robot in the process of assembling itself"))
		{
			if(bs.burn>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","burns all of the wiring inside the unfinished robot");
			}
			else if(bs.lube>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","squirts a bunch of extra lubricant onto the unfinished robot's bits");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","Why is there tar in these things");
				bs.shield-=read_damage(page);
			}
		}
		//Risk vs. Reward
		else if(contains_text(page, "The camera reveals a pair of doors"))
		{
			//page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","");
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","scoots through the less scary of the two doors");
		}
		//Clear Cut Decision
		else if(contains_text(page, "What an unambiguous choice you've been presented with"))
		{
			if(pref_schems)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","transmits an image of the top schematic in the stack");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","empties the lost and found box into the nearest pneumatic recovery tube");
			}
		}
		//What a Grind
		else if(contains_text(page, "field of view slowly descends as you realize that your Crimbot is being fed into a massive industrial shredder"))
		{
			if(bs.hover>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","minimizing the shreddage as if it were the opposite of a heavy metal guitarist");
				bs.shield-=read_damage(page);
			}
			else if(bs.lube>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","spews lubricant in every direction");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","panics and dives even deeper into the teeth of the shredder.");
				bs.shield-=read_damage(page);
			}
		}
		//Et Tu, Brutebot?
		else if(contains_text(page, "The camera reveals a hulking brute of a robot between your Crimbot and its objective"))
		{
			if(bs.pow>=3)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","manages to throw enough punches to knock the Brutebot out in the first round.");
			}
			else if(bs.pow>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","wins the fight in the second round");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","takes a lunch break while the Brutebot breaks several of its parts");
				bs.shield-=read_damage(page);
			}
		}
		//Fire! Fire! Fire!
		else if(contains_text(page, "he camera reveals that your Crimbot has wandered into an incinerato"))
		{
			if(bs.run>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","darts out of the incinerator after getting only partially reduced to molten slag");
				bs.shield-=read_damage(page);
			}
			else if(bs.freeze>=2)
			{
				abort("don't know what text to check for");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","relaxes and allows most of its body to be consumed in flame");
				bs.shield-=read_damage(page);
			}
		}
		//I See What You Saw
		else if(contains_text(page, "camera reveals a robot seemingly designed to take detailed photographs of things and then destroy those things with a massive mouth"))
		{
			if(bs.light>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","flashes its lights in a confusing pattern");
			}
			else if(bs.pinch>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","twiddles some of the Sawbot");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","but the Sawbot just bites");
				bs.shield-=read_damage(page);
			}
		}
		//Too Few Cooks
		else if(contains_text(page, "The camera reveals the scene of a robot having gone haywire in a kitchen"))
		{
			if(pref_schems && bs.freeze>=1)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","cools down the fridge to the point where it can safely recover the schematic and fax it to you");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","presses the button on the microwave");
			}
		}
		//Dorkbot 4000
		else if(contains_text(page, "looking robot poring over what used to be a fire escape map and is now probably a map that would lead you directly into a makeshift furnace."))
		{
			if(bs.decode>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","tells an extremely confusing joke");
			}
			else if(bs.zap>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","tricks the dweeby robot into shaking its hand");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","which explodes as a result of the unexpected kindness");
				bs.shield-=read_damage(page);
			}
		}
		//Ultrasecurity Megabot
		else if(contains_text(page, "The camera reveals a menacing security robot attempting to shackle your Crimbot and presumably toss it into the robo"))
		{
			if(bs.decode>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","resulting in an only somewhat-painful explosion");
				bs.shield-=read_damage(page);
			}
			else if(bs.pow>=3)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","This is why you don't see many old-fashioned robots around these days");
				bs.shield-=read_damage(page);
			}
			else
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","");
				bs.shield-=read_damage(page);
			}
		}
		//Phony
		else if(contains_text(page, "camera reveals that your Crimbot has discovered an elf smartphone"))
		{
			if(pref_schems)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","");
			}
		}
		//Gunception
		else if(contains_text(page, "mera displays a ceiling mounted gun turret made of smaller guns"))
		{
			if(bs.blam>=3)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","carefully fires a single bullet into each of the guns in the turret");
			}
			else if(bs.blam>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","shoots down the turret in a hail of gunfire");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","focuses its attention on the coffee machine instead of the many bullets piercing its metal");
				bs.shield-=read_damage(page);
			}
		}
		//Messy, Messy
		else if(contains_text(page, "The camera reveals a tabletop on which a Crimbot schematic has been carelessly draped over the top of some kind of lumpy object"))
		{
			if(pref_schems || bs.burn==0)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","grabs the schematic and holds it up to its ");
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","");
			}
		}
		//Freeze!
		else if(contains_text(page, "suppression system has been activated, and your Crimbot is being hosed down with liquid nitrogen"))
		{
			if(bs.roll>=2)
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","and only suffers a minor case of electronic brain freeze");
			}
			else if(bs.burn>=2)
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","turns its electronic brain to the purpose of 1980s nostalgia as the freezing liquid turns it into something resembling Jack Nicholson at the end of The Shining");
				bs.shield-=read_damage(page);
			}
		}
		//Flameybot
		else if(contains_text(page, "reveals a robot whose left arm is a flamethrowe"))
		{
			if(bs.freeze>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","fights fire with ice");
				bs.shield-=read_damage(page);
			}
			else if(bs.zap>=2)
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","");
				bs.shield-=read_damage(page);
			}
			else
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","flails around in circles while the Flameybot douses it in fire.");
				bs.shield-=read_damage(page);
			}
		}
		//The Big Guns
		else if(contains_text(page, "The camera reveals a huge bazooka"))
		{
			if(bs.light>=2)
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=sheet_get%28random%29","");
				bs.shield-=read_damage(page);
			}
			else if(bs.pinch>=2)
			{
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform1=sheet_get%28random%29","manages to turn down the bazooka turret");
				bs.shield-=read_damage(page);
			}
			else
			{
				abort("a");
				page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform1=sheet_get%28random%29","");
				bs.shield-=read_damage(page);
			}
		}
		//other
		else
		{
			print("unknown thing\n"+page,"red");
			abort("");
		}
	}
	print("bot died! Moving on","purple");
	if(i_a("crimbot schematic: Swiss Arm") + i_a("crimbot schematic: Snow Blower") + i_a("crimbot schematic: Hoverjack") >1)
		abort("got one!");
}

void bot_explore(int floor)
{
	bot_skills bs = choose_bot(floor);
	string page = make_bot(bs.left, bs.right, bs.torso, bs.legs);
	
	//enter floor
	if(floor==1)
	{
		page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=door.open%28floor_1%29","goes through the door");
		floor1(bs,page);
	}
	else if(floor==2)
	{
		page=bot_perform_action("choice.php?pwd&whichchoice=992&option=2&choiceform2=mount+%2F+stairs","turns the doorknob and heads upstairs.");
		floor2(bs,page);
	}
	else if(floor==3)
	{
		page=bot_perform_action("choice.php?pwd&whichchoice=992&option=3&choiceform2=mount+%2F+stairs","makes short work of the elevator");
		floor3(bs,page);
	}
	else
	{
		abort("unknown floor to enter");
	}
}	

void crimbo_town()
{
	//check elves
	string dump = visit_url("place.php?whichplace=crimbo2014&action=c14_elfcamp");
	dump = visit_url("place.php?whichplace=crimbo2014&action=c14_factory");
	dump = visit_url("choice.php?choice6=Leave&whichchoice=991&option=6&pwd");
	
	//use all the schematics
	use_schematic($item[Crimbot schematic: Wrecking Ball], false);
	use_schematic($item[Crimbot schematic: Tripod Legs], false);
	use_schematic($item[Crimbot schematic: Gun Face], false);
	use_schematic($item[Crimbot schematic: Bug Zapper], false);
	
	use_schematic($item[Crimbot schematic: Big Head], true);
	use_schematic($item[Crimbot schematic: Heavy-Duty Legs], true);
	use_schematic($item[Crimbot schematic: Mega Vise], true);
	use_schematic($item[Crimbot schematic: Power Arm], true);
	use_schematic($item[Crimbot schematic: Rodent Gun], true);
	use_schematic($item[Crimbot schematic: Rollerfeet], true);
	use_schematic($item[Crimbot schematic: Security Chassis], true);
	use_schematic($item[Crimbot schematic: military Chassis], true);
	use_schematic($item[Crimbot schematic: Rivet Shocker], true);
	
	use_schematic($item[Crimbot schematic: Ribbon Manipulator], true);
	use_schematic($item[Crimbot schematic: data analyzer], true);
	
	use_schematic($item[Crimbot schematic: mobile girder], true);
	use_schematic($item[Crimbot schematic: swiss arm], true);
	use_schematic($item[Crimbot schematic: power stapler], true);
	use_schematic($item[Crimbot schematic: grease gun], true);
	use_schematic($item[Crimbot schematic: grease / regular gun], true);
	use_schematic($item[Crimbot schematic: snow blower], true);
	use_schematic($item[Crimbot schematic: crab core], true);
	use_schematic($item[Crimbot schematic: dynamo head], true);
	use_schematic($item[Crimbot schematic: cyclopean torso], true);
	use_schematic($item[Crimbot schematic: sim-simian feet], true);
	use_schematic($item[Crimbot schematic: high-speed fan], true);
	use_schematic($item[Crimbot schematic: big wheel], true);
	use_schematic($item[Crimbot schematic: hoverjack], true);
	
    use_schematic($item[Crimbot schematic: Camera Claw], true);
    use_schematic($item[Crimbot schematic: Bit Masher], true);
    use_schematic($item[Crimbot schematic: Maxi-Mag Lite], true);
    use_schematic($item[Crimbot schematic: Lamp Filler], true);
    use_schematic($item[Crimbot schematic: Candle Lighter], true);
    use_schematic($item[Crimbot schematic: Cold Shoulder], true);
    use_schematic($item[Crimbot schematic: Refrigerator Chassis], true);
    use_schematic($item[Crimbot schematic: Nerding Module], true);
    use_schematic($item[Crimbot schematic: Really Big Head], true);
    use_schematic($item[Crimbot schematic: Rocket Skirt], true);
    use_schematic($item[Crimbot schematic: Heavy Treads], true);
    use_schematic($item[Crimbot schematic: Gun Legs], true);
	
	
	crimbo_credits();
	
	//do robot stuff
	while(my_adventures()>0 && (i_a("crimbonium fuel rod")>0 || (i_a("nugget of Crimbonium")>0 && i_a("cylindrical mold")>0)))
	{
		if(my_fullness() < fullness_limit() || my_inebriety()<inebriety_limit() || my_spleen_use() < spleen_limit())
			cli_execute("eatdrink_simon false");
			
		if(i_a("crimbonium fuel rod")==0)
			create(1,$item[crimbonium fuel rod]);
	
		bot_explore(floor_to_exp);
		
		cli_execute("inventory refresh");
	}
	
	crimbo_credits();
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
		while(i_a("Flask of mining oil")>0 && have_effect($effect[Oily Legs])==0 && have_effect($effect[loose joints])==0)
		{
			if(turns_since_mold_drop>40)
			{
				abort("It's been "+turns_since_mold_drop+" turns since we got a mold to drop, maybe it's time to give up");
			}
			use(1,$item[Flask of mining oil]);
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
		//	abort("Out of oil, maybe can share some");
			crimbo_mining_camp_prep();
			print("trying to get buff potion","purple");
			crimbo_mining_camp();
			num_molds =  update_mold_counter(num_molds, turns_since_mold_drop);
			turns_since_mold_drop=get_property("_turns_since_mold_drop").to_int();
		}
	}
}

void crimbo14()
{
	cli_execute("inventory refresh");
	if(my_name()=="twistedmage")
		visit_url("account.php?actions[]=autoattack&autoattack=99112152&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");

	advent();
	if(pvp_attacks_left()>0 && my_name()=="twistedmage" && have_effect($effect[Oily Legs])==0 && have_effect($effect[loose joints])==0)
		cli_execute("pvp.ash");
	
	//use leftover fuel rods, then get todays fuel rods, then use them
	crimbo_town();
	//crimbonium();
	crimbo_town();
}

void main()
{
	crimbo14();
}