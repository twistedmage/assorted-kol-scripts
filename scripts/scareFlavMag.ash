print("scareFlavMag v.9, by Bale modified from scarephial v1.0, by JasonHarper (in game: Seventh)");

// skills:
skill hot = $skill[Spirit of Cayenne];
skill cold = $skill[Spirit of Peppermint];
skill stench = $skill[Spirit of Garlic];
skill spook = $skill[Spirit of Wormwood];
skill sleaze = $skill[Spirit of Bacon Grease];
skill phys = $skill[none];	// placeholder for skins

// skill => effect:
effect [skill] s2e;
s2e[hot] = $effect[Spirit of Cayenne];
s2e[cold] = $effect[Spirit of Peppermint];
s2e[stench] = $effect[Spirit of Garlic];
s2e[spook] = $effect[Spirit of Wormwood];
s2e[sleaze] = $effect[Spirit of Bacon Grease];

// and the reverse:
skill [effect] e2s;
foreach p in s2e {
	e2s[s2e[p]] = p;
}

void get_the_flavour(int turns_to_use) {
	int nickels = item_amount($item[hobo nickel]);
	int [skill] have;	// current qty of each hobo part
	int kills;
	
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
		
		skill strategy;	// corresponding to lowest part count
		int best = 9999;	// lowest part count
		int secondbest = 9999;	// needed when making skins
		foreach i in have {
			int n = have[i];
			if(((n < best) || ((n == best) && (random(2) == 0))) && n<214) {
				strategy = i;
				secondbest = best;
				best = n;
			} else if(n < secondbest) {
				secondbest = n;
			}
		}
		if(best==9999)
		{
			abort("You should have enough parts to finish Town Square.");
		}
		
		int turns = 0;
		
		if(strategy == phys) {
			turns = secondbest - best;
			if(turns == 0) turns = 1;
				// that could happen if skins were tied for lowest count		
		} else {	// need to use a skill
			use_skill(1, strategy);
			turns = have_effect(s2e[strategy]);
			//if buff duration would make us collect over 214
			if(have[strategy] + turns>214)
			{
				turns = 214-have[strategy];
			}
			if(turns == 0) abort("Magic was not favored????");
		}
		if(turns > turns_to_use) turns = turns_to_use;

		adventure(turns, $location[Hobopolis Town Square]);
		turns_to_use = turns_to_use - turns;
		if(item_amount($item[hobo nickel]) != nickels &&  equipped_amount( $item[mayfly bait necklace] )==0) {
			print("You got a hobo nickel - adjust your combat strategy!","red");		
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
	int flies = to_int(get_property("_hobo_mayflies"));
	int flies_left = 30-flies;
	int worm_juice = to_int(get_property("_aguaDrops"));
	
	if(worm_juice<5 && have_familiar($familiar[baby sandworm]))
	{
		cli_execute("familiar baby sandworm");
	}
	else if(have_familiar($familiar[frumious bandersnatch]))
	{
		cli_execute("familiar frumious bandersnatch");
	}
	else if(have_familiar($familiar[rock lobster]))
	{
		cli_execute("familiar rock lobster");
	}
	else if(have_familiar($familiar[squamous gibberer]))
	{
		cli_execute("familiar squamous gibberer");
	}
	
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
			cli_execute("maximize spell damage, 0.1 mysticality, -equip wand of oscus -equip sugar shorts, -equip sugar chapeau, equip mayfly bait necklace, equip stinky cheese eye, equip Rope with some soap on it");
			get_the_flavour(flies_left);
			set_property("_hobo_mayflies",30);
			turns_to_use=turns_to_use - flies_left;
		}
	
		//if done with flies, 
		cli_execute("maximize spell damage percent, 0.1 mysticality, -equip wand of oscus, -equip sugar shorts, -equip sugar chapeau, equip stinky cheese eye, equip Rope with some soap on it");
		get_the_flavour(turns_to_use);
	}
	else //turns less than flies needed, just fill it a bit
	{
		cli_execute("maximize spell damage percent, 0.1 mysticality, -equip wand of oscus -equip sugar shorts, -equip sugar chapeau, equip mayfly bait necklace, equip stinky cheese eye, equip Rope with some soap on it");
		get_the_flavour(turns_to_use);
		set_property("_hobo_mayflies",flies + turns_to_use);
	}
}