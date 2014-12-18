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
		if(req)
			abort("Don't know and don't have "+sc+" get from somone else");
		print("still need "+sc+" ("+sc.to_int()+")","orange");
		return;
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
			
	if(!get_property("CRIMBO14_SCHEMATIC_7878").to_boolean() || !get_property("CRIMBO14_SCHEMATIC_7868").to_boolean() || !get_property("CRIMBO14_SCHEMATIC_7895").to_boolean())
		abort("Don't have schematics for current best bbot design (according to simulations");
		
	if(floor=1)
	{
		bs.left = 5; //swiss arm
		bs.pow+=1;
		bs.blam+=1;
		bs.zap+=1;
		
		bs.right = 3; //wrecking ball
		bs.pow_attack+=1;
		bs.shield+=1;
		
		bs.torso = 5; //Military Chassis
		bs.shield+=3;
		bs.light+=1;
		bs.blam+=1;
		
		bs.legs = 2; //hoverjack
		bs.hover+=1;
		bs.shield+=3;
	}
	
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

bot_skill floor1(bot_skill bs)
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
		if(bs.blam>=2)
		{
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=while+%281%29+shoot%28%29%3B","sized hole in the door, through which it then proceeds.");
		}
		else if(bs.lube>=1)
		{
			abort("lube");
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
		if(bs.pow>=2)
		{
			page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=break%3B+break%3B+break%3B","pounds the crap out of the gears until they stop turning.");
		}
		else if(bs.hover>=1)
		{
			abort("hover");
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
	return bs;
}

bot_skill floor2(bot_skill bs)
{

	return bs;
}

void bot_explore(int floor)
{
	bot_skills bs = choose_bot();
	string page = make_bot(bs.left, bs.right, bs.torso, bs.legs);
	
	//enter floor
	if(floor==1)
		page=bot_perform_action("choice.php?pwd&whichchoice=992&option=1&choiceform1=door.open%28floor_1%29","goes through the door");
	else
		abort("unknown floor to enter");
	
	while(bs.shield>0)
	{
		if(floor==1)
			bs=floor1(bs);
		else if(floor==2)
			bs=floor2(bs);
		else
			abort("unknown floor to adv in");
	}
	print("bot died! Moving on","purple");
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
	
	use_schematic($item[Crimbot schematic: mobile girder], true);
	use_schematic($item[Crimbot schematic: swiss arm], true);
	use_schematic($item[Crimbot schematic: power stapler], true);
	use_schematic($item[Crimbot schematic: grease gun], true);
	use_schematic($item[Crimbot schematic: grease / regular gun], true);
	use_schematic($item[Crimbot schematic: snow blower], true);
	use_schematic($item[Crimbot schematic: crab core], true);
	use_schematic($item[Crimbot schematic: dynamo head], true);
	use_schematic($item[Crimbot schematic: cyclopean], true);
	use_schematic($item[Crimbot schematic: sim-simian feet], true);
	use_schematic($item[Crimbot schematic: high-speed fan], true);
	use_schematic($item[Crimbot schematic: big wheel], true);
	use_schematic($item[Crimbot schematic: hoverjack], true);
	
	
	
	crimbo_credits();
	
	//do robot stuff
	while(my_adventures()>0 && (i_a("crimbonium fuel rod")>0 || (i_a("nugget of Crimbonium")>0 && i_a("cylindrical mold")>0)))
	{
		if(my_fullness() < fullness_limit() || my_inebriety()<inebriety_limit() || my_spleen_use() < spleen_limit())
			cli_execute("eatdrink_simon false");
			
		if(i_a("crimbonium fuel rod")==0)
			create(1,$item[crimbonium fuel rod]);
	
		bot_explore();
		
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