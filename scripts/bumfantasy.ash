//carnation in soap
//disease rumour
//cindy throws purse
//	found mouse in purse
//		<put mouse
//	ask for hanky at canapes
//ipecac in canoli
script "bumfantasy.ash";
notify bumcheekcity;
import bumcheekascend;

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



void hare()
{
	cli_execute("mood clear");
	use_familiar($familiar[disembodied hand]);
	maximize("spell damage percent",false);
	
	while(have_effect($effect[song of sauce])<30)
		use_skill(1,$skill[song of sauce]);
	while(have_effect($effect[pisces in the skyces])<30)
		use(1,$item[tobiko marble soda]);
	while(have_effect($effect[Medieval Mage Mayhem])<30)
		use(1,$item[scroll case]);
	cli_execute("use jackass plumber home game");
	cli_execute("pool strategic; pool strategic; pool strategic");
	while(have_effect($effect[Elron's Explosive Etude])<30 && my_class()==$class[accordion thief] && my_level()>=15)
		use_skill(1,$skill[Elron's Explosive Etude]);
	
	while(have_effect($effect[Puzzle Fury])<30)
		use(1,$item[37x37x37 puzzle cube]);
	while(have_effect($effect[Concentrated Concentration])<30)
		use(1,$item[concentrated cordial of concentration ]);
	while(have_effect($effect[sweet and red])<30)
		use(1,$item[Sugar cherry]);
	while(have_effect($effect[Concentration])<30)
		use(1,$item[cordial of concentration]);
	while(have_effect($effect[Aquarius Rising])<30)
		use(1,$item[disco horoscope (Aquarius)]);
	while(have_effect($effect[Erudite])<30)
		use(1,$item[black sheepskin diploma]);
		
	while(have_effect($effect[Witch Breaded])<30 && fullness_limit() - my_fullness() >=3)
		eat(1,$item[Witch's bread]);
	while(have_effect($effect[You're Not Cooking])<30 && fullness_limit() - my_fullness() >=2)
		eat(1,$item[fireman's lunch]);
	while(have_effect($effect[Filled with Magic])<30 && fullness_limit() - my_fullness() >=1)
		eat(1,$item[occult jelly donut ]);
	while(have_effect($effect[Egg Burps])<30 && fullness_limit() - my_fullness() >=1)
		eat(1,$item[plumber's lunch]);
	while(have_effect($effect[Greasy Visage])<30 && fullness_limit() - my_fullness() >=1)
		eat(1,$item[Can of Adultwitch&trade;]);
	while(have_effect($effect[Night of the Nachos])<30 && fullness_limit() - my_fullness() >=1)
		eat(1,$item[Nachos of the night]);
	while(have_effect($effect[Cold Throat])<30 && fullness_limit() - my_fullness() >=1)
		eat(1,$item[Ice cream sandwich]);
		
	while(have_effect($effect[Drunk With Power])<30 && inebriety_limit() - my_inebriety() >=3)
		drink(1,$item[elven moonshine]);
		
	while(have_effect($effect[Drunk With Power])<30 && inebriety_limit() - my_inebriety() >=3)
		drink(1,$item[elven moonshine]);
		
	while(have_effect($effect[Indescribable Flavor])<30 && spleen_limit() - my_spleen_use() >=4)
		use(1,$item[Indescribably horrible paste]);
	while(have_effect($effect[crimbo Flavor])<30 && spleen_limit() - my_spleen_use() >=4)
		use(1,$item[Crimbo paste]);
	
	//could also have put some spell crit stuff here - wizard squint, inner dog, cosmic flavour, ninja please, liquid luck?
		
	clear_combat_macro();
	set_property("customCombatScript","hare");
	set_property("battleAction","custom combat script");
	while(contains_text(visit_url("woods.php"),"i911.gif"))
	{
		cli_execute("restore mp");
		adventure(1,$location[A deserted stretch of I-911]);
	}
}

//238 381
//228 361
void wolf()
{
	//remove ml
	cli_execute("mcd 0; clear mood;shrug urkel; shrug drescher; shrug pride of the puffin");

	//noncom buffs
	while(have_effect($effect[Smooth Movements])<30)
		use_skill(1,$skill[Smooth Movement]);
	while(have_effect($effect[The Sonata of Sneakiness])<30)
		use_skill(1,$skill[The Sonata of Sneakiness]);
	while(have_effect($effect[Fresh Scent])<30)
		use(1,$item[chunk of rock salt ]);
		
	use_familiar($familiar[evil teddy bear]);
	cli_execute("friars familiar");
	cli_execute("maximize hp regen min, hp regen max, 0.01 hp, 0.01 familiar weight, -7 combat, +equip pigsticker");
	while(have_effect($effect[Green Tongue])<30)
		use(1,$item[green snowcone]);
	while(have_effect($effect[Curiosity of Br'er Tarrypin])<30)
		use_skill(1,$skill[Curiosity of Br'er Tarrypin]);
	while(have_effect($effect[Heart of White])<30)
		use(1,$item[white candy heart]);
	while(have_effect($effect[Blue Swayed])<30)
		use(1,$item[pulled blue taffy]);
	
	boolean improved_howling=false;
	boolean vending=true; //start true, only go to vendor on second/third
	int turns_left=30;
	
	while(turns_left>0)
	{
		cli_execute("restore hp");
		if(get_property("lastEncounter")=="Back Room Dealings")
			improved_howling=true;
		if(get_property("lastEncounter")=="Vendie, Vidi, Vici")
			vending=true;
			
		if(!improved_howling)
		{
			//get howling
			set_property("choiceAdventure830","3"); 
			set_property("choiceAdventure834","2"); 
			adventure(1,$location[the inner wolf gym]);
		}
		else if(!vending)//got howling
		{
			//get elemental attacks
			set_property("choiceAdventure830","2"); 
			set_property("choiceAdventure833","2"); 
			adventure(1,$location[the inner wolf gym]);
		}
		else
		{
			cli_execute("use moveable feast");
			abort("go to skid row");
		}
		turns_left-=1;
	}
	//try and get improved howling?
}
//nc on 23, nc on 13, 4
//combat with 22, 6/6, 10, 16, 2 = 10
//combat with 12, 9/9, 13, 22, 1 (5 elemental) = 24
//combat with 3, 12/12, 16, 25, 1 (5 elemental) = 49
//
//24, 6/6, 13, 13, 1 = 15
//15, 7/7, 19, 16, 2 = 24
//3, 11/11, 22, 19, 3 =48
//
//
//23, 6/6, 16, 13, 1 = 18
//14, 10/10, 19, 13, 2 = 36
//3, 13/13, 25, 19, 2 = 69
//
//hp regen doesn't trigger... nor does campfire
//should only fight brick houses, huff others

void gnome_farm()
{
	int adv_left=6;
	while(adv_left>0)
	{
		if(have_effect($effect[mush-mouth])==0)
			use(1,$item[fun-guy spore]);
		adventure(1,$location[Ye olde Medievale Villagee]);
		adv_left-=1;
	}
}

void gnome_craft()
{
	int straw   = i_a("straw");
	int leather = i_a("leather");
	int clay    = i_a("clay");
	int filling   = i_a("filling");
	int parchment = i_a("parchment");
	int glass    = i_a("glass");
	
	string st = visit_url("place.php?whichplace=ioty2014_rumple&action=workshop");
	st = visit_url("choice.php?pwd&whichchoice=845&option=2&choiceform2=Craft+Things+for+Barter");
	int min_basic = min(straw,min(leather,clay));
	while(straw>4 && filling<min_basic)
	{
		st = visit_url("choice.php?pwd&whichchoice=850&option=1&choiceform1=Turn+Straw+into+Filling+%283+Straw%29");
		straw-=3;
		filling+=1;
		min_basic = min(straw,min(leather,clay));
	}
	while(leather>4 && parchment<min_basic)
	{
		st = visit_url("choice.php?pwd&whichchoice=850&option=2&choiceform2=Turn+Leather+into+Parchment+%283+Leather%29");
		leather-=3;
		parchment+=1;
		min_basic = min(straw,min(leather,clay));
	}
	while(clay>4 && glass<min_basic)
	{
		st = visit_url("choice.php?pwd&whichchoice=850&option=3&choiceform3=Turn+Clay+into+Glass+%283+Clay%29");
		clay-=3;
		glass+=1;
		min_basic = min(straw,min(leather,clay));
	}
	st = visit_url("choice.php?pwd&whichchoice=850&option=4&choiceform4=Do+Something+Else");
	st = visit_url("choice.php?pwd&whichchoice=845&option=4&choiceform4=Go+Home");
	
	print("Straw: "+straw, "purple");
	print("Leather: "+leather, "purple");
	print("Clay: "+clay, "purple");
	print("Filling: "+filling, "purple");
	print("Parchment: "+parchment, "purple");
	print("Glass: "+glass, "purple");
}

//mother violent, father violent

void gnome_portal()
{
	//look through portal
	string st = visit_url("adventure.php?snarfblat=381");
	st = visit_url("choice.php?pwd&whichchoice=844&option=1&choiceform1=Look+into+the+Portal");
	
	//output recommendations
	string father="";
	string mother="";
	
	if(contains_text(st,"counting his possessions."))
		father+=" greed";
	if(contains_text(st,"counting her possessions."))
		mother+=" greed";
	if(contains_text(st,"father gold-plating a lily."))
		father+=" greed";
	if(contains_text(st,"mother gold-plating a lily."))
		mother+=" greed";
	if(contains_text(st,"father studying a treasure map."))
		father+=" greed";
	if(contains_text(st,"mother studying a treasure map."))
		mother+=" greed";
	if(contains_text(st,"mother writing a contract to make a high-interest loan."))
		mother+=" greed";
	if(contains_text(st,"father writing a contract to make a high-interest loan."))
		father+=" greed";
	if(contains_text(st,"mother chowing down on a fistful of bacon."))
		mother+=" gluttony";
	if(contains_text(st,"father chowing down on a fistful of bacon."))
		father+=" gluttony";
	if(contains_text(st,"father eating a chocolate rabbit."))
		father+=" gluttony";
	if(contains_text(st,"mother eating a chocolate rabbit."))
		mother+=" gluttony";
	if(contains_text(st,"father putting a fried egg on top of a cheeseburger."))
		father+=" gluttony";
	if(contains_text(st,"mother putting a fried egg on top of a cheeseburger."))
		mother+=" gluttony";
	if(contains_text(st,"father sprinkling extra cheese on a pizza already dripping with the stuff."))
		father+=" gluttony";
	if(contains_text(st,"mother sprinkling extra cheese on a pizza already dripping with the stuff."))
		mother+=" gluttony";
	if(contains_text(st,"checking his reflection in a spoon."))
		father+=" vanity";
	if(contains_text(st,"checking her reflection in a spoon."))
		mother+=" vanity";
	if(contains_text(st,"plucking his eyebrows."))
		father+=" vanity";
	if(contains_text(st,"plucking her eyebrows."))
		mother+=" vanity";
	if(contains_text(st,"father putting in a teeth-whitening tray."))
		father+=" vanity";
	if(contains_text(st,"mother putting in a teeth-whitening tray."))
		mother+=" vanity";
	if(contains_text(st,"telling everyone that the song on the radio is his."))
		father+=" vanity";
	if(contains_text(st,"telling everyone that the song on the radio is her."))
		mother+=" vanity";
	if(contains_text(st,"father asking one of the kids to find the remote control."))
		father+=" laziness";
	if(contains_text(st,"mother asking one of the kids to find the remote control."))
		mother+=" laziness";
	if(contains_text(st,"father collapsed deep in an easy chair, stifling a yawn."))
		father+=" laziness";
	if(contains_text(st,"mother collapsed deep in an easy chair, stifling a yawn."))
		mother+=" laziness";
	if(contains_text(st,"father lying on the floor"))
		father+=" laziness";
	if(contains_text(st,"mother lying on the floor"))
		mother+=" laziness";
	if(contains_text(st,"father sleeping soundly."))
		father+=" laziness";
	if(contains_text(st,"mother sleeping soundly."))
		mother+=" laziness";
	if(contains_text(st,"eyeing his spouse lasciviously."))
		father+=" lust";
	if(contains_text(st,"eyeing her spouse lasciviously."))
		mother+=" lust";
	if(contains_text(st,"father flipping through a lingerie catalog."))
		father+=" lust";
	if(contains_text(st,"mother flipping through a lingerie catalog."))
		mother+=" lust";
	if(contains_text(st,"father moaning softly."))
		father+=" lust";
	if(contains_text(st,"mother moaning softly."))
		mother+=" lust";
	if(contains_text(st,"father peeking through the blinds at the attractive neighbors."))
		father+=" lust";
	if(contains_text(st,"mother peeking through the blinds at the attractive neighbors."))
		mother+=" lust";
	if(contains_text(st,"father kicking a dog."))
		father+=" violence";
	if(contains_text(st,"mother kicking a dog."))
		mother+=" violence";
	if(contains_text(st,"father punching a hole in the wall of the house."))
		father+=" violence";
	if(contains_text(st,"mother punching a hole in the wall of the house."))
		mother+=" violence";
	if(contains_text(st,"father screaming at the television."))
		father+=" violence";
	if(contains_text(st,"mother screaming at the television."))
		mother+=" violence";
	if(contains_text(st,"stubbing his toe on an ottoman then kicking it across the room."))
		father+=" violence";
	if(contains_text(st,"stubbing her toe on an ottoman then kicking it across the room."))
		mother+=" violence";
		
	if(contains_text(st,"father cutting a huge piece of cake to eat alone."))
		father+=" greed/gluttony";
	if(contains_text(st,"mother cutting a huge piece of cake to eat alone."))
		mother+=" greed/gluttony";
	if(contains_text(st,"father opening a family-size bag of Cheat-Os, not planning on sharing them."))
		father+=" greed/gluttony";
	if(contains_text(st,"mother opening a family-size bag of Cheat-Os, not planning on sharing them."))
		mother+=" greed/gluttony";
	if(contains_text(st,"father putting a golden ring on each finger."))
		father+=" greed/vanity";
	if(contains_text(st,"mother putting a golden ring on each finger."))
		mother+=" greed/vanity";
	if(contains_text(st,"father shining a golden chalice to a reflective finish."))
		father+=" greed/vanity";
	if(contains_text(st,"mother shining a golden chalice to a reflective finish."))
		mother+=" greed/vanity";
	if(contains_text(st,"father reclined in a chair, ordering stuff from the Home Shopping Network."))
		father+=" greed/laziness";
	if(contains_text(st,"mother reclined in a chair, ordering stuff from the Home Shopping Network."))
		mother+=" greed/laziness";
	if(contains_text(st,"father trying to shortchange the maid who is washing the dishes."))
		father+=" greed/laziness";
	if(contains_text(st,"mother trying to shortchange the maid who is washing the dishes."))
		mother+=" greed/laziness";
	if(contains_text(st,"father admiring a solid marble nude statue."))
		father+=" greed/lust";
	if(contains_text(st,"mother admiring a solid marble nude statue."))
		mother+=" greed/lust";
	if(contains_text(st,"father admiring a valuable collection of artistic nudes."))
		father+=" greed/lust";
	if(contains_text(st,"mother admiring a valuable collection of artistic nudes."))
		mother+=" greed/lust";
	if(contains_text(st,"father polishing a collection of solid silver daggers."))
		father+=" greed/violence";
	if(contains_text(st,"mother polishing a collection of solid silver daggers."))
		mother+=" greed/violence";
	if(contains_text(st,"father loading a jewel-encrusted pistol with golden bullets."))
		father+=" greed/violence";
	if(contains_text(st,"mother loading a jewel-encrusted pistol with golden bullets."))
		mother+=" greed/violence";
		
	if(contains_text(st,"father checking for stretch marks while downing a huge chocolate shake."))
		father+=" gluttony/vanity";
	if(contains_text(st,"mother checking for stretch marks while downing a huge chocolate shake."))
		mother+=" gluttony/vanity";
	if(contains_text(st,"father trying to squeeze into a girdle."))
		father+=" gluttony/vanity";
	if(contains_text(st,"mother trying to squeeze into a girdle."))
		mother+=" gluttony/vanity";
	if(contains_text(st,"calling the dog over to lick french-fry grease off of his shirt."))
		father+=" gluttony/laziness";
	if(contains_text(st,"calling the dog over to lick french-fry grease off of her shirt."))
		mother+=" gluttony/laziness";
	if(contains_text(st,"father reclined in an overstuffed chair eating a bag of bacon-flavored onion rings."))
		father+=" gluttony/laziness";
	if(contains_text(st,"mother reclined in an overstuffed chair eating a bag of bacon-flavored onion rings."))
		mother+=" gluttony/laziness";
	if(contains_text(st,"father licking an all-day sucker."))
		father+=" gluttony/lust";
	if(contains_text(st,"mother licking an all-day sucker."))
		mother+=" gluttony/lust";
	if(contains_text(st,"licking his lips sensually over a rack of ribs."))
		father+=" gluttony/lust";
	if(contains_text(st,"licking her lips sensually over a rack of ribs."))
		mother+=" gluttony/lust";
	if(contains_text(st,"father tearing apart an entire roasted chicken so hard the bones snap."))
		father+=" gluttony/violence";
	if(contains_text(st,"mother tearing apart an entire roasted chicken so hard the bones snap."))
		mother+=" gluttony/violence";
	if(contains_text(st,"father throwing a bag of chips on the ground and stomping on it to open it."))
		father+=" gluttony/violence";
	if(contains_text(st,"mother throwing a bag of chips on the ground and stomping on it to open it."))
		mother+=" gluttony/violence";
		
	if(contains_text(st,"collapsed in an overstuffed chair, curling his eyelashes."))
		father+=" vanity/laziness";
	if(contains_text(st,"collapsed in an overstuffed chair, curling her eyelashes."))
		mother+=" vanity/laziness";
	if(contains_text(st,"father using the remote control to turn the TV to the Beauty Channel."))
		father+=" vanity/laziness";
	if(contains_text(st,"mother using the remote control to turn the TV to the Beauty Channel."))
		mother+=" vanity/laziness";
	if(contains_text(st,"checking out own his body and licking his lips seductively."))
		father+=" vanity/lust";
	if(contains_text(st,"checking out own her body and licking her lips seductively."))
		mother+=" vanity/lust";
	if(contains_text(st,"practicing pick-up lines on his own reflection in a window."))
		father+=" vanity/lust";
	if(contains_text(st,"practicing pick-up lines on her own reflection in a window."))
		mother+=" vanity/lust";
	if(contains_text(st,"father angrily plucking stray eyebrow hairs."))
		father+=" vanity/violence";
	if(contains_text(st,"mother angrily plucking stray eyebrow hairs."))
		mother+=" vanity/violence";
	if(contains_text(st,"father kicking the dog, then making sure the kick didn't scuff her shoes."))
		father+=" vanity/violence";
	if(contains_text(st,"mother kicking the dog, then making sure the kick didn't scuff her shoes."))
		mother+=" vanity/violence";
		
	if(contains_text(st,"lying on the floor, calling his spouse to come give a kiss."))
		father+=" laziness/lust";
	if(contains_text(st,"lying on the floor, calling her spouse to come give a kiss."))
		mother+=" laziness/lust";
	if(contains_text(st,"father reclined on the bed, idly peeping through the window to the neighbor's house."))
		father+=" laziness/lust";
	if(contains_text(st,"mother reclined on the bed, idly peeping through the window to the neighbor's house."))
		mother+=" laziness/lust";
	if(contains_text(st,"father half-heartedly kicking at the cat when it comes too close."))
		father+=" laziness/violence";
	if(contains_text(st,"mother half-heartedly kicking at the cat when it comes too close."))
		mother+=" laziness/violence";
	if(contains_text(st,"father sleepily swiping at a whining kid."))
		father+=" laziness/violence";
	if(contains_text(st,"mother sleepily swiping at a whining kid."))
		mother+=" laziness/violence";
		
	if(contains_text(st,"aggressively kissing his spouse."))
		father+=" lust/violence";
	if(contains_text(st,"aggressively kissing her spouse."))
		mother+=" lust/violence";
	if(contains_text(st,"father tearing down the blinds to peep out of the window."))
		father+=" lust/violence";
	if(contains_text(st,"mother tearing down the blinds to peep out of the window."))
		mother+=" lust/violence";
		
	print("Father: "+father, "purple");
	print("Mother: "+mother, "purple");
}

void gnome()
{
	//get ready to farm items
	setFamiliar("items");
	setMood("i");
	cli_execute("maximize items");
	
	//farm ingredients
	gnome_farm();
	
	//make materials
	gnome_craft();
	
	//look in portal
	gnome_portal();

}



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
		case "hare" :
			if(have_effect($effect[hare-brained])==0)
			{
				set_property("choiceAdventure829", 5);
				use(1, $item[grimstone mask]);
				set_property("choiceAdventure829", 0);
			}
			hare();
		break;
		case "wolf" :
			if(!contains_text(visit_url("woods.php"),"skidrow.gif"))
			{
				set_property("choiceAdventure829", 2);
				use(1, $item[grimstone mask]);
				set_property("choiceAdventure829", 0);
			}
			wolf();
		break;
		case "gnome" :
			if(!contains_text(visit_url("woods.php"),"rumplehome.gif"))
			{
				set_property("choiceAdventure829", 4);
				use(1, $item[grimstone mask]);
				set_property("choiceAdventure829", 0);
			}
			gnome();
		break;
	}
}
//12229108
//12166000
//first try ~8k
//second try 9129
//third try 11110
//seems to be best to get candy on combats, and defences on noncombats (always 2 random, then 1 to balance)