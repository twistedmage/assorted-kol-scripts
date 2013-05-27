// Bale's EatSushi v 1.0
// This will figure out what sake and sushi is cheapest. Then it will eat it for you.
// This is extremely self-contained so that eat_sushi can included in another script breakfast script without any conflicts.

script "Eat Sushi.ash";

// If you never want to be asked about toppings, set this to false.
boolean check_toppings = true;

// If included in another script, call this with true to check toppings, or false to not check toppings.
// spare_tummy is in case you want to make sure it leaves extra fullness for other food, like fortune cookies.
void eat_sushi(boolean toppings, int spare_tummy) {

	record comparison_shop {
		item it;
		int price;
	};
	
	// This figures out the cheapest infused sake to drink and acquires a bottle. It will also deduce if it is
	// cheaper to purchase it from the mall, or make a bottle from ingredients.
	item infuse_sake() {
		comparison_shop [int] sakes;
			sakes[0].it = $item[berry-infused sake];
			sakes[1].it = $item[citrus-infused sake];
			sakes[2].it = $item[melon-infused sake];
		comparison_shop [int] fruits;
			fruits[0].it = $item[sea lychee];
			fruits[1].it = $item[sea tangelo];
			fruits[2].it = $item[sea honeydew];
//		foreach i in sakes
//			sakes[i].price = mall_price(sakes[i].it);
		foreach i in fruits
			fruits[i].price = mall_price(fruits[i].it) + mall_price($item[bottle of Pete's Sake]);
//return sakes[0].it;
		sort sakes by sakes[index].price;
		sort fruits by fruits[index].price;
//		if(sakes[0].price <= fruits[0].price) {   //line commmented out since have no skill to make sake
		if(true){
			retrieve_item(1, sakes[0].it);
			return sakes[0].it;
		}
		retrieve_item(1, fruits[0].it);
		retrieve_item(1, $item[bottle of Pete's Sake]);
		item [item] make_sake;
			make_sake[$item[sea lychee]] = $item[berry-infused sake];
			make_sake[$item[sea tangelo]] = $item[citrus-infused sake];
			make_sake[$item[sea honeydew]] = $item[melon-infused sake];
		create(1, make_sake[fruits[0].it]);
		return make_sake[fruits[0].it];
	}
	
	if(my_fullness() + spare_tummy > fullness_limit()) {
		print("Tummy too full for sushi.", "red");
		return;
	}
	
	string topping = "";
	if(toppings) {
		print("You can choose a topping for your sushi. Either sea salt, dragonfish caviar or eel sauce.");
//		if(user_confirm("Would you like sea salt on your sushi?\n(Costs "+mall_price($item[sea salt crystal])+" meat and adds 10 turns of Salty Dogs per roll.)")) {
//			topping = "salty ";
//		} else if(user_confirm("Would you like dragonfish caviar on your sushi?\n(Costs "+mall_price($item[dragonfish caviar])+" meat and adds 5 turns of Fishy per roll.)")) {
			topping = "magical ";
//		} else if(user_confirm("Would you like eel sauce on your sushi?\n(Costs "+mall_price($item[eel sauce])+" meat and adds 3 adventures per roll.)")) {
//			topping = "electric ";
//		}
	}
	
	if(have_effect($effect[Warm Belly]) < 1) {
		// Always prefer infused sake to regular since it gives much better adventure returns.
		if(inebriety_limit() >= my_inebriety() +4) {
			drink(1, infuse_sake());
		} else if(inebriety_limit() >= my_inebriety() +1) {
			buy(1, $item[bottle of Pete's Sake]);
			drink(1, $item[bottle of Pete's Sake]);
		}
	}
	// If sake was not drunk, then ask the user if he really wants to go ahead with Sushi eating.
	// Eating sushi without a warm belly is really not recommended.
	if(have_effect($effect[Warm Belly]) < 1)
		if(!user_confirm("Cannot drink sake!\nDo you want to eat your sushi anyway?"))
			abort("Cannot eat sushi without a glass of sake.");
	
	comparison_shop [int] fishmeat;
	fishmeat[0].it = $item[glistening fish meat];
	fishmeat[1].it = $item[beefy fish meat];
	fishmeat[2].it = $item[slick fish meat];
	comparison_shop [int] veggie;
	veggie[0].it = $item[sea radish];
	veggie[1].it = $item[sea avocado];
	veggie[2].it = $item[sea carrot];
	veggie[3].it = $item[sea cucumber];
	
	string [item, item] maki;
		maki[ $item[beefy fish meat], $item[sea cucumber] ]  = "giant dragon roll";
		maki[ $item[beefy fish meat], $item[sea carrot] ]  = "musclebound rabbit roll";
		maki[ $item[beefy fish meat], $item[sea avocado] ]  = "python roll";
		maki[ $item[beefy fish meat], $item[sea radish] ]  = "Jack LaLanne roll";
		maki[ $item[glistening fish meat], $item[sea cucumber] ] = "wise dragon roll ";
		maki[ $item[glistening fish meat], $item[sea carrot] ]  = "white rabbit roll ";
		maki[ $item[glistening fish meat], $item[sea avocado] ] = "ancient serpent roll";
		maki[ $item[glistening fish meat], $item[sea radish] ]  = "wizened master roll";
		maki[ $item[slick fish meat], $item[sea cucumber] ] = "tricky dragon roll";
		maki[ $item[slick fish meat], $item[sea carrot] ] = "sneaky rabbit roll";
		maki[ $item[slick fish meat], $item[sea avocado] ] = "slippery snake roll";
		maki[ $item[slick fish meat], $item[sea radish] ] = "eleven oceans roll";
		
	// Sorts out cheapest prices for fishmeat and veggies.
	void fishprice_sort() {
		foreach i in fishmeat
			fishmeat[i].price = mall_price(fishmeat[i].it);
//		sort fishmeat by fishmeat[index].price;
		foreach i in veggie
			veggie[i].price = mall_price(veggie[i].it);
//		sort veggie by veggie[index].price;
	}
	
	int x = floor((fullness_limit() - my_fullness() - spare_tummy)/3);
	retrieve_item(x, $item[white rice]);
	retrieve_item(x, $item[seaweed]);
	switch(topping) {
	case "salty ":
		retrieve_item(x, $item[sea salt crystal]);
		break;
	case "magical ":
		retrieve_item(x, $item[dragonfish caviar]);
		break;
	case "electric ":
		retrieve_item(x, $item[eel sauce]);
		break;
	}
	fishprice_sort();
	retrieve_item(x, veggie[0].it);
	retrieve_item(x, fishmeat[0].it);
	cli_execute("create "+ x+ " "+ topping+ maki[fishmeat[0].it, veggie[0].it]);
}

void main() {
	eat_sushi(check_toppings, 0);
}