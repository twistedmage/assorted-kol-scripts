print("scarephial v1.0, by JasonHarper@pobox.com (in game: Seventh)");

// phials:
item hot = $item[phial of hotness];
item cold = $item[phial of coldness];
item stench = $item[phial of stench];
item spook = $item[phial of spookiness];
item sleaze = $item[phial of sleaziness];
item phys = $item[none];	// placeholder for skins

// phial => effect:
effect [item] p2e;
p2e[hot] = $effect[Hotform];
p2e[cold] = $effect[Coldform];
p2e[stench] = $effect[Stenchform];
p2e[spook] = $effect[Spookyform];
p2e[sleaze] = $effect[Sleazeform];

// and the reverse:
item [effect] e2p;
foreach p in p2e {
	e2p[p2e[p]] = p;
}

void farm(int turns_to_use) {
	int nickels = item_amount($item[hobo nickel]);
	int [item] have;	// current qty of each hobo part
	int kills;
	
	if(turns_to_use == 0) turns_to_use = 9999;
	if(turns_to_use > my_adventures()) turns_to_use = my_adventures();
	if(my_inebriety() > inebriety_limit()) abort("You're drunk!");

	while(true) {
		string richard = visit_url(
			"clan_hobopolis.php?place=3&action=talkrichard&whichtalk=3");
		if(!contains_text(richard, "bring me enough hobo bits")) {
			abort("You don't appear to have Town Square access.");
		}
		richard = replace_string(richard, "<b>", "");
		richard = replace_string(richard, "</b>", "");
		string [int, int] t;
		t = group_string(richard, "has (\\d+) pairs? of charred");
		have[hot] = to_int(t[0][1]);
		t = group_string(richard, "has (\\d+) pairs? of frozen");
		have[cold] = to_int(t[0][1]);
		t = group_string(richard, "has (\\d+) piles? of stinking");
		have[stench] = to_int(t[0][1]);
		t = group_string(richard, "has (\\d+) creepy");
		have[spook] = to_int(t[0][1]);
		t = group_string(richard, "has (\\d+) hobo crotch");
		have[sleaze] = to_int(t[0][1]);
		t = group_string(richard, "has (\\d+) hobo skin");
		have[phys] = to_int(t[0][1]);
		
		t = group_string(visit_url("clan_hobopolis.php?place=2"),
			"townsquare(\\d+)\\.gif");
		kills = to_int(t[0][1]);
		if(kills == 125) kills = 13;
		kills = kills * 125;
		if(turns_to_use <= 0) break;
		
		item strategy;	// corresponding to lowest part count
		int best = 9999;	// lowest part count
		int secondbest = 9999;	// needed when making skins
		foreach i in have {
			int n = have[i];
			if((n < best) || ((n == best) && (random(2) == 0))) {
				strategy = i;
				secondbest = best;
				best = n;
			} else if(n < secondbest) {
				secondbest = n;
			}
		}
		
		if(best * 8 + kills >= 3000-125) {
			abort("You may have enough parts to finish Town Square.");
		}
		
		int turns = 0;
		foreach e in e2p {
			if(have_effect(e) > 0) turns = have_effect(e);
			// the phial effects are mutually exclusive, only one can be non-zero
		}
		
		if(turns > 0) {
			// already have an effect, use it even if it's not optimal		
		} else if(strategy == phys) {
			turns = secondbest - best;
			if(turns == 0) turns = 1;
				// that could happen if skins were tied for lowest count		
		} else {	// need to use a phial
			if((my_class() != $class[Sauceror]) &&
				item_amount(strategy) <= 0) {
				// for non-saucerors, buying generally cheaper than making
				buy(3, strategy);
			}
			use(1, strategy);
			turns = have_effect(p2e[strategy]);
			if(turns == 0) abort("Phial didn't take effect????");
		}
		if(turns > turns_to_use) turns = turns_to_use;

		adventure(turns, $location[Hobopolis Town Square]);
		turns_to_use = turns_to_use - turns;
		if(item_amount($item[hobo nickel]) != nickels && equipped_amount($item[mayfly bait necklace])==0 && equipped_amount($item[lil businessman kit])==0 ) {
			abort("You got a hobo nickel - adjust your combat strategy!");		
		}
	}

	print("At least " + kills + " of the 3000 town square hobos have been killed.");
	print("Hobo parts: " + have[hot] + " hot, " + have[cold] + " cold, " +
		have[stench] + " stench, " + have[spook] + " spook, " + 
		have[sleaze] + " sleaze, and " + have[phys] + " skins.");
}


void main(int turns_to_use) {
	if(turns_to_use == 0) turns_to_use = 9999;
	if(turns_to_use > my_adventures()) turns_to_use = my_adventures();
	int flies = to_int(get_property("_mayflySummons"));
	int flies_left = 30-flies;
	
	if(have_familiar($familiar[squamous gibberer]))
	{
		cli_execute("familiar squamous gibberer");
	}
	string eq="maximize weapon damage percent, 0.01 weapon damage, -equip vinyl boots, -equip sugar shorts, -equip sugar chapeau, -equip sugar shield, equip stinky cheese eye, equip hobo stogie, equip lil businessman kit";
	
	//more turns than mayflies left
	if(turns_to_use>flies_left && available_amount($item[mayfly bait necklace])!=0)
	{
		if(item_amount($item[stinky cheese eye])<1 && equipped_amount($item[stinky cheese eye])<1 )
		{
			cli_execute("fold stinky cheese eye");
		}
		//if not yet done with flies, fill it to 30
		if(flies_left!=0)
		{
			cli_execute(eq+", +equip mayfly bait necklace");
			farm(flies_left);
			turns_to_use=turns_to_use - flies_left;
		}
	
		//if done with flies, 
			cli_execute(eq);
		farm(turns_to_use);
	}
	else //turns less than flies needed, just fill it a bit
	{
		cli_execute(eq);
		farm(turns_to_use);
	}
}