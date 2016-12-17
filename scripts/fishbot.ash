script "fishbot.ash"
notify "digitrev";

import "canadv.ash";

int[string] fish_count;
location[string] fishing_holes;

void parse_fish() {
	//Determine how many fish the floundry currently has
	string floundry = visit_url("clan_viplounge.php?action=floundry");
	matcher fish = create_matcher("<br>([0-9,]+) (carp|cod|trout|bass|hatchetfish|tuna)", floundry);

	while (fish.find()) {
		print(fish.group(2) + " -> " + fish.group(1));
		fish_count[fish.group(2)] = fish.group(1).to_int();
	}
}

void parse_holes() {
	//Determine where we can find the fish
	string floundry = visit_url("clan_viplounge.php?action=floundry");
	matcher fish = create_matcher("<b>(carp|cod|trout|bass|hatchetfish|tuna):</b> ([^<]+)", floundry);

	while (fish.find()) {
		print(fish.group(1) + " -> " + fish.group(2) + "(" + fish.group(2).to_location() + ")");
		fishing_holes[fish.group(1)] = fish.group(2).to_location();
	}

}

location least_fish() {
	//Find the location that contains the least number of fish that we can adventure in
	int f = -1;
	location l;
	print("z");
	foreach x in fish_count {
		print(fishing_holes[x]);
		if (can_adv(fishing_holes[x]) && (f < 0 || fish_count[x] < f)) {
			f = fish_count[x];
			l = fishing_holes[x];
		}
	}
	print("x");
	return l;
}

int[string] found_fish() {
	//Parse the number of fish we found in the last adevnture
	int[string] r;
	string f;
	int c;


	string log = session_logs(1)[0];
	matcher advs = create_matcher("\\["+my_turncount().to_string()+"\\][^\\[]+", log);
	while (advs.find()) {
		//Only find the last fish found
		f = "";
		c = 0;
		matcher fish = create_matcher("After Battle: \\+([0-9]+) (carp|cod|trout|bass|hatchetfish|tuna)", advs.group(0));
		while (fish.find()) {
			f = fish.group(2);
			c = fish.group(1).to_int();
		}
	}
	r[f] = c;
	return r;
}

int item_price(item it) {
	//Untradeable items have no price
	//Find the cheapest of the mall price or the NPC shop price
	float price = 999999999;
	if (!it.tradeable)
		price = 0;
	if (it.historical_age() > 1)
		price = it.mall_price();
	else
		price = it.historical_price();
	if (it.is_npc_item() && it.npc_price() > 0)
		price = min(price, it.npc_price());
	return price;
}

void equip_gear() {
	//Make sure we have any buyable fishing gear
	foreach it in $items[fishin' hat] {
		if (it.available_amount() < 1 && it.item_price() < min(get_property("autoBuyPriceLimit").to_int(), my_meat()))
			buy(1, it);
	}

	//Increase combat rate, because non-combats can't drop fish
	maximize("100 fishing skill, combat, 0.01 mainstat", 0, 2, false);

	//Are we drunk? Try to equip a wineglass, otherwise just stop
	if (my_inebriety() > inebriety_limit() && !equip($item[Drunkula's wineglass]))
		abort("We're too drunk to fish. Try finding a wineglass.");
}

void keep_up_buffs() {
	//Each fish is worth one "adventure"
	print("r");
	foreach i, r in maximize("fishing skill", 0, 2, true, false) {
		if (r.item.numeric_modifier("Effect Duration") * r.score / 100.0 * get_property("valueOfAdventure").to_float() >= r.item.item_price())
			cli_execute(r.command);
	}
	print("s");
}

void main(int adventures) {
	if(have_effect($effect[Carlweather's Cantata of Confrontation])<adventures)
	{
		print("WARNING: haven't got enough cantata to last during fishing. maybe get from buffbot?","red");
		wait(10);	
	}
	
	//open zones
	if(!can_adv($location[The skeleton store]))
	{
		visit_url("shop.php?whichshop=meatsmith");
		visit_url("shop.php?whichshop=meatsmith&action=talk");
		visit_url("choice.php?pwd&whichchoice=1059&option=1&choiceform1=Sure%2C+I%27ll+go+check+it+out.");
	}
	if(!can_adv($location[madness bakery]))
	{
		visit_url("shop.php?whichshop=armory");
		visit_url("shop.php?whichshop=armory&action=talk");
		visit_url("choice.php?pwd&whichchoice=1065&option=1&choiceform1=Okay%2C+fine.++I%27ll+go+get+your+pie.");
	}
	if(!can_adv($location[the overgrown lot]))
	{
		visit_url("shop.php?whichshop=doc");
		visit_url("shop.php?whichshop=doc&action=talk");
		visit_url("choice.php?pwd&whichchoice=1064&option=1&choiceform1=Sure%2C+I%27ll+go+pick+some+flowers.");
	}
	if(!can_adv($location[the fungal nethers]))
	{
		visit_url("guild.php?place=scg");
		visit_url("guild.php?place=scg");
		visit_url("guild.php?place=scg");
		visit_url("guild.php?place=ocg");
		visit_url("guild.php?place=ocg");
		visit_url("guild.php?place=ocg");
	}
	
	

	parse_fish();
	//Don't fish if we can't. parse_fish() will guarantee that we have get a fishin' pole if we can get one
	if ($item[fishin' pole].available_amount() == 0)
		abort("You can't fish without a pole, city slicker.");
	parse_holes();
	equip_gear();
	print("a");

	//Don't adventure when we can't
	int adv = adventures;
	while (adv > 0 && my_adventures() > 0) {
		keep_up_buffs();
		location lf = least_fish();
	print("b");
		if (lf == $location[none]){
			abort("You can't seem to find any suitable fishing holes. Check the Floundry and see what you can unlock.");
		}
		familiar f = my_familiar();
		can_adv(lf, true);
		adventure(1, lf);
		f.use_familiar();
	print("c");

		//Increase the fish count, so we'll keep an even stock
		foreach fish, cnt in found_fish() {
			fish_count[fish] += cnt;
		}
		adv -= 1;
	print("d");
	}
}