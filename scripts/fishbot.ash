script "fishbot.ash"
notify "digitrev";

import "canadv.ash";
import "vprops.ash";

int[string] fish_count;
location[string] fishing_holes;

boolean consume = define_property("fishbot.consume", "boolean", "false").to_boolean();

void parse_fish() {
	//Determine how many fish the floundry currently has
	string floundry = visit_url("clan_viplounge.php?action=floundry");
	matcher fish = create_matcher("<br>([0-9,]+) (carp|cod|trout|bass|hatchetfish|tuna)", floundry);

	while (fish.find()) {
		fish_count[fish.group(2)] = fish.group(1).to_int();
	}
}

void parse_holes() {
	//Determine where we can find the fish
	string floundry = visit_url("clan_viplounge.php?action=floundry");
	matcher fish = create_matcher("<b>(carp|cod|trout|bass|hatchetfish|tuna):</b> ([^<]+)", floundry);

	while (fish.find()) {
		fishing_holes[fish.group(1)] = fish.group(2).to_location();
	}

}

location least_fish() {
	//Find the location that contains the least number of fish that we can adventure in
	int f = -1;
	location l;
	foreach x in fish_count {
		if (can_adv(fishing_holes[x]) && (f < 0 || fish_count[x] < f)) {
			f = fish_count[x];
			l = fishing_holes[x];
		}
	}
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
	maximize("fishing skill, 0.01 combat", 0, 2, false);

	//Are we drunk? Try to equip a wineglass, otherwise just stop
	if (my_inebriety() > inebriety_limit() && !equip($item[Drunkula's wineglass]))
		abort("We're too drunk to fish. Try finding a wineglass.");
}

void keep_up_buffs() {
	//Each fish is worth one "adventure"
	//If fishbot.consume is true, allow eating/drinking/spleening, otherwise ensure that item consumption won't take up organ space
	foreach i, r in maximize("fishing skill", 0, 2, true, false) {
		if (r.item.numeric_modifier("Effect Duration") * r.score / 100.0 * get_property("valueOfAdventure").to_float() >= r.item.item_price()
			&& (consume || (r.item.inebriety + r.item.fullness + r.item.spleen) == 0))
			cli_execute(r.command);
	}
}

void main(int adventures) {
	parse_fish();
	//Don't fish if we can't. parse_fish() will guarantee that we have get a fishin' pole if we can get one
	if ($item[fishin' pole].available_amount() == 0)
		abort("You can't fish without a pole, city slicker.");
	parse_holes();
	equip_gear();

	//Don't adventure when we can't
	int adv = adventures;
	while (adv > 0 && my_adventures() > 0) {
		keep_up_buffs();
		location lf = least_fish();
		if (lf == $location[none]){
			abort("You can't seem to find any suitable fishing holes. Check the Floundry and see what you can unlock.");
		}
		familiar f = my_familiar();
		can_adv(lf, true);
		adventure(1, lf);
		f.use_familiar();

		//Increase the fish count, so we'll keep an even stock
		foreach fish, cnt in found_fish() {
			fish_count[fish] += cnt;
		}
		adv -= 1;
	}
}