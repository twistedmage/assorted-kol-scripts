//carnation in soap
//disease rumour
//cindy throws purse
//	found mouse in purse
//		<put mouse
//	ask for hanky at canapes
//ipecac in canoli

script "bumfantasy.ash";
notify bumcheekcity;

void cindyOption(int choice, string place) {
	switch (place) {
		case "restroom" :
			visit_url("adventure.php?snarfblat=374");
			visit_url("choice.php?pwd&whichchoice=822&option="+choice);
			
			/*set_property("choiceAdventure822", choice);
			adventure(1, $location[princes restroom]);
			set_property("choiceAdventure822", 0);*/
		break;
		case "dancefloor" :
			visit_url("adventure.php?snarfblat=375");
			visit_url("choice.php?pwd&whichchoice=823&option="+choice);
			
			/*set_property("choiceAdventure823", choice);
			adventure(1, $location[dance floor]);
			set_property("choiceAdventure823", 0);*/
		break;
		case "kitchen" :
			visit_url("adventure.php?snarfblat=376");
			visit_url("choice.php?pwd&whichchoice=824&option="+choice);
			
			/*set_property("choiceAdventure824", choice);
			adventure(1, $location[princes kitchen]);
			set_property("choiceAdventure824", 0);*/
		break;
		case "balcony" :
			visit_url("adventure.php?snarfblat=377");
			visit_url("choice.php?pwd&whichchoice=825&option="+choice);
			
			/*set_property("choiceAdventure825", choice);
			adventure(1, $location[princes balcony]);
			set_property("choiceAdventure825", 0);*/
		break;
		case "lounge" :
			visit_url("adventure.php?snarfblat=378");
			visit_url("choice.php?pwd&whichchoice=826&option="+choice);
			
			/*set_property("choiceAdventure826", choice);
			adventure(1, $location[princes lounge]);
			set_property("choiceAdventure826", 0);*/
		break;
		case "canapes" :
			visit_url("adventure.php?snarfblat=379");
			visit_url("choice.php?pwd&whichchoice=827&option="+choice);
			
			/*set_property("choiceAdventure827", choice);
			adventure(1, $location[princes canape]);
			set_property("choiceAdventure827", 0);*/
		break;
	}
}

void cindyVomit() {
    //Lounge, Get cigar
	cindyOption(2, "lounge");
    //Kitchen, Inspect pantry
	cindyOption(2, "kitchen");
    //Kitchen, Put cinnamon in canoli filling
	cindyOption(2, "kitchen");
    //Canapes, Take cheese
	cindyOption(3, "canapes");
    //Restroom, Take soap
	cindyOption(2, "restroom");
    //Balcony, Examine flowers
	cindyOption(2, "balcony");
    //Balcony, talk to baroness
	cindyOption(3, "balcony");
    //Balcony, talk to baroness
	cindyOption(3, "balcony");
    //Dance floor, steal hairpin from baroness
	cindyOption(4, "dancefloor");
    //Restroom, medicine cabinet, pick lock, take ipecac
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
    //Lounge, take empty cigar box
	cindyOption(2, "lounge");
    //Kitchen, set trap for mouse with soap
	cindyOption(3, "kitchen");
    //Waste turns in non-kitchen area until 12 minutes remain
    //SIMONS TURN WASTE
    //start rumor
    cindyOption(4, "lounge");	//start rumour
    	visit_url("choice.php?pwd&whichchoice=826&option=3"); //disease
    //sabotage soap
	cindyOption(2, "balcony"); //get flower
	cindyOption(3, "restroom"); //put in soap
	//get coins?
	cindyOption(1, "lounge");
	cindyOption(1, "canapes");
	cindyOption(1, "balcony");

    //Kitchen, get mouse
	cindyOption(2, "kitchen");
    //Kitchen, dose canoli tray with ipecac
	cindyOption(2, "kitchen");
    //Canapes, put mouse in cinderella's purse
	cindyOption(1, "canapes"); //2
		visit_url("choice.php?pwd&whichchoice=827&option=2");
    //Canapes, ask for handkerchief
	cindyOption(3, "canapes"); //4
    //Canapes, give cinderella the canoli (NOT SURE ABOUT NUMBER)
	cindyOption(3, "canapes"); //4
    //Hang out in ballroom until she throws up
	//SIMON GET COINS
	cindyOption(1, "kitchen");
	cindyOption(1, "balcony");
	cindyOption(1, "restroom");
	cindyOption(1, "dancefloor");
	//waste final turns
	cindyOption(1, "dancefloor"); //make her fall over
	cindyOption(1, "restroom"); //make her fall over
	cindyOption(1, "dancefloor"); //make her fall over
    //Waste turns until it is done (not sure if you need to finish or can abort) 
	
}


void cindyKill() {
    //Kitchen, Inspect pantry
	cindyOption(2, "kitchen");
    //Kitchen, Put cinnamon in canoli filling
	cindyOption(2, "kitchen");

    //Balcony, Examine flowers
	cindyOption(2, "balcony");
    //Balcony, talk to baroness
	cindyOption(3, "balcony");
    //Balcony, talk to baroness
	cindyOption(3, "balcony");
    //Dance floor, steal hairpin from baroness
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take ipecac
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=3");

	cindyOption(1, "lounge");

    //Kitchen, dose canoli tray with laudanum
	cindyOption(2, "kitchen");

	cindyOption(1, "canapes");

    //Canapes, give cinderella the canoli (NOT SURE ABOUT NUMBER)
	cindyOption(4, "canapes"); 
}

void cindyCrime() {

    //Lounge, Get cigar
	cindyOption(2, "lounge");
    cindyOption(3, "lounge");	//start rumour
    	visit_url("choice.php?pwd&whichchoice=826&option=4"); //disease
    cindyOption(2, "lounge");	//start rumour
    //Balcony, Examine flowers
	cindyOption(2, "balcony");

    //Balcony, talk to baroness
	cindyOption(3, "balcony");
    //Balcony, talk to baroness
	cindyOption(3, "balcony");
    //Dance floor, steal hairpin from baroness
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take aspirin
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=2");
    //Restroom, Take soap
	cindyOption(2, "restroom");
    //Canapes, Take cheese
	cindyOption(2, "canapes");

	//get coins?
	cindyOption(1, "lounge");
	cindyOption(1, "canapes");

	//Kick soap at butler (dance floor)
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take laudanum
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=2");

	//Spike the whiskey with the laudanum (lounge)
	cindyOption(2, "lounge");

	//Offer the Baroness some aspirin. She will then offer to be a co-conspirator. (balcony)
	cindyOption(3, "balcony");

	//get coins?
	cindyOption(1, "kitchen");
	cindyOption(1, "balcony");
	cindyOption(1, "restroom");
	cindyOption(1, "dancefloor");

	//Pick the lock in on the curio cabinet (lounge) (available with 10 turns remaining)
	cindyOption(4, "lounge");

	//Slip the silver cow creamer into Cinderella's purse (canapes table)
	cindyOption(1, "canapes"); 
		visit_url("choice.php?pwd&whichchoice=827&option=3");
	//Ask Cinderella for a handkerchief (canapes table)
	cindyOption(3, "canapes");

	//<7 turns left>
}

//best so far, gives 27
void cindyHigh() {
    //Lounge, Get cigar 30
	cindyOption(2, "lounge");
    //Balcony, talk to baroness 29
	cindyOption(3, "balcony");
    //Balcony, Examine flowers 28
	cindyOption(2, "balcony"); 
	//give carnation to prince 27
	cindyOption(2, "canapes");
    cindyOption(4, "lounge");	//start rumour 26
    	visit_url("choice.php?pwd&whichchoice=826&option=3"); //disease?
    //<cheese> 25
	cindyOption(2, "canapes");
    //<soap> 24
	cindyOption(2, "restroom");
    //<cigar box> 23
	cindyOption(2, "lounge");
	//inspect pantry (cinamon) 22
	cindyOption(2, "kitchen");
    //soapy mousetrap 21
	cindyOption(3, "kitchen");

    //Balcony, Examine flowers 20
	cindyOption(2, "balcony"); 
	//cinamon in canoli 19
	cindyOption(2, "kitchen");

    //Balcony, talk to baroness 18
	cindyOption(3, "balcony");
    //steal hairpin from baroness 17
	cindyOption(3, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take ipecac 16
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=1");

	//get flower 15
	cindyOption(2, "balcony");
	//doctor soap 14
	cindyOption(3, "restroom");

	//mouse out of trap 13
	cindyOption(2, "kitchen");
    //Kitchen, dose canoli tray with ipecac 12
	cindyOption(2, "kitchen");

	//get whiskey flask 11 <?>
	cindyOption(2, "lounge"); 

	//spike cindys glass 10
	cindyOption(3, "canapes");

    //Canapes, give cinderella the canoli 9
	cindyOption(7, "canapes");

	//mouse in purse 8
	cindyOption(2, "canapes");
		visit_url("choice.php?pwd&whichchoice=827&option=3");
	//ask for hanky 7
	cindyOption(6, "canapes");
	//Waste turn for coin <> 6
	cindyOption(1, "kitchen");
	//trip cindy 5 <vomit> <?>
	cindyOption(2, "dancefloor");
	//get soap 4 <?>
	cindyOption(2, "restroom");
	//trip cindy 3 <?>
	cindyOption(2, "dancefloor");
	//get soap 2 <?>
	cindyOption(2, "restroom");
	//trip cindy 1 <?>
	cindyOption(2, "dancefloor");
}



void witch()
{
	if(available_amount($item[peanut brittle shield])<3)
		abort("Get some peanut brittle shields from kbay");

	//create some lemon gear
	if(available_amount($item[lemon party hat])<1)
		create(1,$item[lemon party hat]);
	if(available_amount($item[lemon shirt])<1)
		create(1,$item[lemon shirt]);
	if(available_amount($item[lemon drop trousers])<1)
		create(1,$item[lemon drop trousers]);

	//food and drink buffs
	while(have_effect($effect[Sweet Tooth])<30 && (inebriety_limit()-my_inebriety()>=1))
		drink(1,$item[snakebite]);
	while(have_effect($effect[High Blood Chocolate Content])<30 && (inebriety_limit()-my_inebriety()>=3))
		drink(1,$item[chocotini]);
	while(have_effect($effect[sweet nostalgia])<30 && (inebriety_limit()-my_inebriety()>=5))
		drink(1,$item[mulled berry wine]);

	while(have_effect($effect[Improved Candy Vision])<30 && (fullness_limit()-my_fullness()>=4))
		eat(1,$item[Candy carrot cake]);
	while(have_effect($effect[Pecan Pied Piper])<30 && (fullness_limit()-my_fullness()>=3))
		eat(1,$item[pecan pie]);

	//potion buffs
	while(have_effect($effect[sourpuss])<30)
		use(1,$item[lemonhead caviar]);
	while(have_effect($effect[sweet taste])<30)
		use(1,$item[small gummi fin]);
	while(have_effect($effect[Rootin' Around])<30)
		use(1,$item[Licorice root]);
//TOO EXPENSIVE
//	while(have_effect($effect[puckered up])<80)
//		use(1,$item[sour powder]);

	//fam buffs
	cli_execute("pool aggressive;pool aggressive;pool aggressive");
	cli_execute("concert optimist primal");
	while(have_effect($effect[empathy])<30)
		use_skill(1,$skill[empathy of the newt]);
	while(have_effect($effect[leash of linguini])<30)
		use_skill(1,$skill[leash of linguini]);
	while(have_effect($effect[chorale of companionship])<30)
	{
		if(my_class()==$class[accordion thief] && my_level()>=15)
			use_skill(1,$skill[chorale of companionship]);
		else
			use(1,$item[recording of chorale of companionship]);
	}
	while(have_effect($effect[heavy petting])<30)
		use(1,$item[knob goblin pet-buffing spray]);
	while(have_effect($effect[Blue Swayed])<80)
		use(1,$item[pulled blue taffy]);
	while(have_effect($effect[Cold Hearted])<50)
		use(1,$item[love song of icy revenge]);
	while(have_effect($effect[green tongue])<30)
		use(1,$item[green snowcone]);
	while(have_effect($effect[kindly resolve])<30)
		use(1,$item[resolution: be kinder]);
	while(have_effect($effect[Man's Worst Enemy])<30)
		use(1,$item[disintegrating spiky collar]);
	while(have_effect($effect[bestial sympathy])<30)
		use(1,$item[half-orchid]);
	while(have_effect($effect[Heart of Green])<30)
		use(1,$item[green candy heart]);
	//fam exp
	if(familiar_weight(my_familiar())<20 && have_skill($skill[Curiosity of Br'er Tarrypin]))
	{
		cli_execute("friars familiar");
		while(have_effect($effect[Curiosity of Br'er Tarrypin])<30)
			use_skill(1,$skill[Curiosity of Br'er Tarrypin]);
	}


	//before we start, set up gear etc for candy
	use_familiar($familiar[peppermint rhino]);
	cli_execute("maximize candy drop, equip chocolate cow bone");
	cli_execute("use moveable feast");

	abort("Done buffing, now do stuff!");
//first adv per zone free
//4 combats, noncom, 3 combats, noncom, combat
//combats at gumdrop forest to get axies
//first round, noncom 1 at lake to find out
//		noncom 2 at <>
//
//second round, noncom 1 at forest, 2 random defences
//		noncome 2 at <>
//
//third round, non

//noncom 1 at lake (837) choice 1, tells us 2 people who won't be in attack
//noncom 1 at <> (841) choice 2 gives 2 random defences
//<noncoms>
//<use pixie axies from gumdrop forest?>
//with 897.5% candy drop
//
//rabbit 895,937,912,903,878,890
//prarie dogs = 889,889,927,1015,952,842,815 Candy,	114hp,	152 def (1 smack to kill)
//weasel 976,986,949,842
//default candy must be x*(1+8.975) = 900   around 90
//
//pixie 648, 592,560,596,563
//snake 609,629
//
//minnow 853,643,848
//pllwaioasaur 848
//
//gummi sword gives 50% which is around 45 candy
//peanut shield gives 100% which is about 90 candy
//chocolate cow bone gives 30% which is around 30 candy, and 25 extra on first smack
//licorice whip gives 100 on a crit
//furious wallop for SC forces crit
}
//spooky = fearful fettucini
//stench = kasesostrum
//

//Cinnamon arsonists, 	Chubby Brutes, 	Pole Vaulters
//piranha cold, 		weasel sleaze, 	tree spooky


//Bubble gum balloonists, 	Cinnamon arsonists,	Chubby Brutes, 	Tunnelers, 		Pole Vaulters
//pixie hot, 				piranha cold, 		weasel sleaze, 	snake stench, 	tree spooky


void main(string option) {
	cli_execute("clear mood");
	switch (option) {
		case "vomit" :
			set_property("choiceAdventure829", 1);
			use(1, $item[grimstone mask]);
			set_property("choiceAdventure829", 0);
			cindyVomit();
		break;
		case "kill" :
			set_property("choiceAdventure829", 1);
			use(1, $item[grimstone mask]);
			set_property("choiceAdventure829", 0);
			cindyKill();
		break;
		case "crime" :
			set_property("choiceAdventure829", 1);
			use(1, $item[grimstone mask]);
			set_property("choiceAdventure829", 0);
			cindyCrime();
		break;
		case "high" :
			set_property("choiceAdventure829", 1);
			use(1, $item[grimstone mask]);
			set_property("choiceAdventure829", 0);
			cindyHigh();
		break;
		case "witch" :
			set_property("choiceAdventure829", 3);
			use(1, $item[grimstone mask]);
			set_property("choiceAdventure829", 0);
			witch();
		break;
	}
}
//12229108
//12166000
//first try ~8k
//second try 9129
//third try 11110
//seems to be best to get candy on combats, and defences on noncombats (always 2 random, then 1 to balance)