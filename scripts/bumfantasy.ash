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

//disease rumor = +2
//doctored soap = +3
//klepto rumour = +3

void cindyVomitCrime() {
    //Lounge, Get cigar 30
	cindyOption(2, "lounge");
    cindyOption(3, "lounge");	//start rumour 29
    	visit_url("choice.php?pwd&whichchoice=826&option=4"); //klepto
	//inspect pantry 28
	cindyOption(2, "kitchen");
    //Balcony, Examine flowers 27
	cindyOption(2, "balcony"); 

    //Balcony, talk to baroness 26
	cindyOption(3, "balcony");
    //Balcony, talk to baroness 25
	cindyOption(3, "balcony");
    //Dance floor, steal hairpin from baroness 24
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take aspirin 23
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=2");
    //Restroom, Take soap 22
	cindyOption(2, "restroom");
    //Canapes, Take cheese 21
	cindyOption(2, "canapes");

	//get cigar box 20
	cindyOption(2, "lounge");
	//mousetrap with soap 19
	cindyOption(3, "kitchen");

	//Kick soap at butler (dance floor) 18
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take laudanum 17
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=2");

	//Spike the whiskey with the laudanum (lounge) 16
	cindyOption(2, "lounge"); //not sure about number

    cindyOption(3, "lounge");	//examin cabinet 15
	//Offer the Baroness some aspirin. She will then offer to be a co-conspirator. (balcony) 14
	cindyOption(3, "balcony");

    //Restroom, medicine cabinet, pick lock, take ipecac 13
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
	//get mouse out of trap 12
	cindyOption(2, "kitchen");
    //Kitchen, dose canoli tray with ipecac 11
	cindyOption(4, "kitchen");

	//Pick the lock in on the curio cabinet (lounge) (available with 10 turns remaining) 10
	cindyOption(4, "lounge");

    //Canapes, give cinderella the canoli 9
	cindyOption(7, "canapes");
	//Slip the silver cow creamer into Cinderella's purse (canapes table) 8
	cindyOption(2, "canapes"); 
		visit_url("choice.php?pwd&whichchoice=827&option=5");

    //Canapes, ask for handkerchief 7
	cindyOption(6, "canapes");
	//put mouse in cinderella's purse 6
	cindyOption(2, "canapes");
		visit_url("choice.php?pwd&whichchoice=827&option=3");

	//get flower 5
	cindyOption(2, "balcony");
	//doctor soap 4
	cindyOption(3, "restroom");

	<get soap> //3
	<trip cindy> //2

	<ballroom coin + watch vomit 1>? (do I have to watch?) 1
}
<make her eat 2 canolli instead of 1, need cinammon?>





void cindyVomitCrime2() {
    //Lounge, Get cigar 30
	cindyOption(2, "lounge");
    cindyOption(3, "lounge");	//start rumour 29
    	visit_url("choice.php?pwd&whichchoice=826&option=4"); //klepto
	//inspect pantry 28
	cindyOption(2, "kitchen");
    //Restroom, Take soap 27
	cindyOption(2, "restroom");
    //Canapes, Take cheese 26
	cindyOption(2, "canapes");

    //Balcony, Examine flowers 25
	cindyOption(2, "balcony"); 
	//get cigar box 24
	cindyOption(2, "lounge");
	//mousetrap with soap 23
	cindyOption(3, "kitchen");

    //Balcony, talk to baroness 22
	cindyOption(3, "balcony");
    //Balcony, talk to baroness 21
	cindyOption(3, "balcony");
    //Dance floor, steal hairpin from baroness 20
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take aspirin 19
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=2");

    cindyOption(3, "lounge");	//examin cabinet 18
	//get mouse out of trap 17
	cindyOption(2, "kitchen");

	//Kick soap at butler (dance floor) 16
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take laudanum 15
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=2");

	//Spike the whiskey with the laudanum (lounge) 14
	cindyOption(2, "lounge"); //not sure about number

	//Offer the Baroness some aspirin. She will then offer to be a co-conspirator. (balcony) 13
	cindyOption(3, "balcony");

    //Restroom, medicine cabinet, pick lock, take ipecac 12
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
    //Kitchen, dose canoli tray with ipecac 11
	cindyOption(4, "kitchen");

	//Pick the lock in on the curio cabinet (lounge) (available with 10 turns remaining) 10
	cindyOption(4, "lounge");

    //Canapes, give cinderella the canoli 9
	cindyOption(7, "canapes");
	//Slip the silver cow creamer into Cinderella's purse (canapes table) 8
	cindyOption(2, "canapes"); 
		visit_url("choice.php?pwd&whichchoice=827&option=5");

    //Canapes, ask for handkerchief 7
	cindyOption(6, "canapes");
	//put mouse in cinderella's purse 6
	cindyOption(2, "canapes");
		visit_url("choice.php?pwd&whichchoice=827&option=3");

	//get flower 5
	cindyOption(2, "balcony");
	//doctor soap 4
	cindyOption(3, "restroom");

	<get soap> //3
	<trip cindy> //2

	<ballroom coin + watch vomit 1>? (do I have to watch?) 1
}
<creamer in purse>
<ask hanky>
<mouse in purse>
<ask hanky>
<give ipecac canapes 16>
<>




void cindyDrunkCrime() {
    //Lounge, Get cigar 30
	cindyOption(2, "lounge");
    cindyOption(3, "lounge");	//start rumour 29
    	visit_url("choice.php?pwd&whichchoice=826&option=4"); //klepto
	// 28
	<>
    //Balcony, Examine flowers 27
	cindyOption(2, "balcony"); 

    //Balcony, talk to baroness 26
	cindyOption(3, "balcony");
    //Balcony, talk to baroness 25
	cindyOption(3, "balcony");
    //Dance floor, steal hairpin from baroness 24
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take aspirin 23
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=2");
    //Restroom, Take soap 22
	cindyOption(2, "restroom");
    // 21
	<>

	//get cigar box 20
	<>
	//mousetrap with soap 19
	<>

	//Kick soap at butler (dance floor) 18
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take laudanum 17
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=2");

	//Spike the whiskey with the laudanum (lounge) 16
	cindyOption(2, "lounge"); //not sure about number

    cindyOption(3, "lounge");	//examin cabinet 15
	//Offer the Baroness some aspirin. She will then offer to be a co-conspirator. (balcony) 14
	cindyOption(3, "balcony");

    //Restroom, medicine cabinet, pick lock, take ipecac 13
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
	//get mouse out of trap 12
	<>
    //Kitchen, dose canoli tray with ipecac 11
	cindyOption(4, "kitchen");

	//Pick the lock in on the curio cabinet (lounge) (available with 10 turns remaining) 10
	cindyOption(4, "lounge");

    //Canapes, give cinderella the canoli 9
	cindyOption(7, "canapes");
	//Slip the silver cow creamer into Cinderella's purse (canapes table) 8
	cindyOption(2, "canapes"); 
		visit_url("choice.php?pwd&whichchoice=827&option=5");

    //Canapes, ask for handkerchief 7
	cindyOption(6, "canapes");
	//put mouse in cinderella's purse 6
	<>

	//get flower 5
	cindyOption(2, "balcony");
	//doctor soap 4
	cindyOption(3, "restroom");

	<get soap> //3
	<trip cindy> //2

	<ballroom coin + watch vomit 1>? (do I have to watch?) 1
}
<flask in purse?>
<drunk rumour + tripping?>
<spike things?>











<give prince carnation>
void cindyDrunkVomit() {
    //Lounge, Get cigar 30
	cindyOption(2, "lounge");
    //Balcony, talk to baroness 29
	cindyOption(3, "balcony");
    //Balcony, Examine flowers 28
	cindyOption(2, "balcony"); 
	//give carnation to prince 27
	cindyOption(2, "canapes");
	//inspect pantry 26
	cindyOption(2, "kitchen");

    //Balcony, Examine flowers 25
	cindyOption(2, "balcony"); 

    //Balcony, talk to baroness 24
	cindyOption(3, "balcony");
    //steal hairpin from baroness 23
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take ipecac 22
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
    //Kitchen, dose canoli tray with ipecac 21
	cindyOption(3, "kitchen");
    //Canapes, Take cheese 20
	cindyOption(6, "canapes");
	//get cigar box 19
	cindyOption(2, "lounge");

    //Canapes, give cinderella the canoli 18
	cindyOption(5, "canapes");

	//mousetrap with no additives 17
	cindyOption(2, "kitchen");

    cindyOption(4, "lounge");	//start rumour 16
    	visit_url("choice.php?pwd&whichchoice=826&option=3"); //disease?

	//get flower 15
	cindyOption(2, "balcony");
	//doctor soap 14
	cindyOption(3, "restroom");
	//get some soap 13 <?>
	cindyOption(2, "restroom");
    //Kitchen, dose canoli tray with ipecac 12
	cindyOption(4, "kitchen");
	//get mouse out of trap 11
	cindyOption(2, "kitchen");

	//get whiskey flask 10 <?>
	cindyOption(2, "lounge"); 

    //Canapes, give cinderella the canoli 9
	cindyOption(7, "canapes");

	//put mouse in cinderella's purse 8
	<>

    //Canapes, ask for handkerchief 7
	cindyOption(6, "canapes");

	//spike cindys glass 6 <?>
	cindyOption(, "canapes");
	//trip cindy 5 <?>
	cindyOption(, "dancefloor");
	//get soap 4 <?>
	cindyOption(2, "restroom");
	//trip cindy 3 <?>
	cindyOption(, "dancefloor");
	//get soap 2 <?>
	cindyOption(2, "restroom");
	//trip cindy 1 <?>
	cindyOption(, "dancefloor");
}


<give prince carnation>
void cindyDrunkVomit() {
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

    //Balcony, Examine flowers 25
	cindyOption(2, "balcony"); 

    //Balcony, talk to baroness 24
	cindyOption(3, "balcony");
    //steal hairpin from baroness 23
	cindyOption(2, "dancefloor");

    //Restroom, medicine cabinet, pick lock, take ipecac 22
	cindyOption(3, "restroom");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
		visit_url("choice.php?pwd&whichchoice=822&option=1");
    //Kitchen, dose canoli tray with ipecac 21
	cindyOption(3, "kitchen");
	//inspect pantry (cinamon) 20
	cindyOption(2, "kitchen");
	//cinamon in canoli 19
	cindyOption(2, "kitchen");

    //Canapes, give cinderella the canoli 18
	cindyOption(5, "canapes");

	//cinamon in purse 17
	cindyOption(2, "canapes");
		visit_url("choice.php?pwd&whichchoice=827&option=3");
	//ask for hanky 16
	cindyOption(4, "canapes");

	//get flower 15
	cindyOption(2, "balcony");
	//doctor soap 14
	cindyOption(3, "restroom");

	//get some soap 13 <?>
	cindyOption(2, "restroom");
    //Kitchen, dose canoli tray with ipecac 12
	cindyOption(3, "kitchen");

	//get whiskey flask 11 <?>
	cindyOption(3, "lounge"); 

    //Canapes, give cinderella the canoli 10
	cindyOption(<>, "canapes");

	//spike cindys glass 9
	cindyOption(2, "canapes");
	<>
	<>
	<>
	//trip cindy 5 <?>
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




//best so far, gives 27
void cindyDrunkVomit() {
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
	<>
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







void main(string option) {
	cli_execute("clear mood");
	switch (option) {
		case "vomit" :
			use(1, $item[grimstone mask]);
			visit_url("choice.php?whichchoice=829&option=1&pwd=");
			cindyVomit();
		break;
		case "kill" :
			use(1, $item[grimstone mask]);
			visit_url("choice.php?whichchoice=829&option=1&pwd=");
			cindyKill();
		break;
		case "crime" :
			use(1, $item[grimstone mask]);
			visit_url("choice.php?whichchoice=829&option=1&pwd=");
			cindyCrime();
		break;
		case "high" :
			use(1, $item[grimstone mask]);
			visit_url("choice.php?whichchoice=829&option=1&pwd=");
			cindyHigh();
		break;
	}
}
