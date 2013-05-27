// Script: Rainbow Gravitation v 1.3
// Author: Bale
// This will create a prismatic wad by transmuting elemental wads, if it can be done in Hardcore.

item [item] to_make;
to_make [$item[cold wad]] = $item[hot wad];
to_make [$item[spooky wad]] = $item[cold wad];
to_make [$item[stench wad]] = $item[spooky wad];
to_make [$item[sleaze wad]] = $item[stench wad];
to_make [$item[hot wad]] = $item[sleaze wad];

boolean mall = can_interact() && get_property("autoSatisfyWithMall").to_boolean();

// Mafia doesn't have recipes for cooking wads so I need to use visit_url()
boolean cook_wad(item it) {
	print("Cooking a twinkly wad with a "+ it+ ".");
	visit_url("craft.php?mode=cook&action=craft&a=1450&b="+ to_string(it.to_int())+ "&qty=1&master=Bake%21&pwd");
}

// Transform all wads necessary to cast the skill.
void transform_wads() {
	item [item] transmute;
	foreach key in to_make
		transmute[to_make[key]] = key;
	item choice;
	foreach key in to_make
		if(item_amount(key) < 1) {
			choice = to_make[key];
			while(item_amount(choice) < 2) {
				choice = to_make[choice];
			}
			while(item_amount(key) < 1) {
				// create(1, transmute[choice]);
				cook_wad(choice);
				choice = transmute[choice];
			}
		}
}

// Figure out the cost of transmutation, then cast Rainbow Gravitation
boolean gravitate() {
	int [item] wads;
	wads[$item[twinkly wad]] = item_amount($item[twinkly wad]);
	wads[$item[hot wad]] = item_amount($item[hot wad]);
	wads[$item[cold wad]] = item_amount($item[cold wad]);
	wads[$item[spooky wad]] = item_amount($item[spooky wad]);
	wads[$item[stench wad]] = item_amount($item[stench wad]);
	wads[$item[sleaze wad]] = item_amount($item[sleaze wad]);
	
	boolean doit = true;

	// Do I have one of every wad? If so, then ask for confirmation if transformation is needed and cast.
	boolean rainbow(){
		foreach key in to_make
			if(wads[key] < 1)
				return false;
		int twinkle_used = item_amount($item[twinkly wad]) - wads[$item[twinkly wad]];
		if(twinkle_used > 0)
			doit = true; //user_confirm("Transmuting elemental wads would use up "+ twinkle_used+ " twinkly wads.\nGravitate the Rainbow?");
		if(doit) {
			transform_wads();
			use_skill(1, $skill[Rainbow Gravitation]);
		}
		return true;
	}
	
	if(mall) {
		foreach key in wads
			if(item_amount(key) < 1)
				buy(1, key);
		use_skill(1, $skill[Rainbow Gravitation]);
		return true;
	}
	item change;
	int steps;
	foreach key in to_make
		if(wads[key] < 1) {
			change = to_make[key];
			steps = 1;
			while(wads[change] < 2) {
				change = to_make[change];
				steps = steps + 1;
			}
			wads[key] = wads[key] + 1;
			wads[change] = wads[change] - 1;
			wads[$item[twinkly wad]] = wads[$item[twinkly wad]] - steps;
			if(wads[$item[twinkly wad]] < 1) {
				print("There are insufficent twinkly wads to transmute that many elemental wads", "red");
				return false;
			}
			if(rainbow())
				return doit;
		}
		if(rainbow())
			return doit;
	return false;
}

// Can't transmute wads without Way of the Sauce
boolean need_way() {
	boolean need = false;
	foreach key in to_make
		if(item_amount(key) < 1) {
			print("You lack a "+ to_string(key)+ ".", "#FF7028");
			need = true;
		}
	if(need && !have_skill($skill[The Way of Sauce]))
		return true;
	return false;
}

// First, do I have the pre-requisites to cast Rainbow Gravitation?
boolean can_gravity() {

	int el_wad;
	int el_wads(){
		foreach key in to_make
			el_wad = el_wad + item_amount(key);
		return el_wad;
	}

	switch {
	case ! have_skill($skill[Rainbow Gravitation]):
		print("You don't have the skill to gravitate a rainbow.", "red");
		return false;
	case get_property("prismaticSummons").to_int() > 2:
		print("You've already made 3 Rainbow Wads today!", "red");
		return false;
	case mall:
		return true;
	case el_wads() < 5:
		print("There are insufficient elemental wads. Make "+ to_string(5 - el_wad) + " more, then try again.", "red");
		return false;
	case item_amount($item[twinkly wad]) < 1:
		print("You cannot use Rainbow Gravitation without a twinky wad.", "red");
		return false;
	case need_way():
		print("Without understanding the Way of the Sauce you cannot transmute wads.", "red");
		return false;
	default:
		return true;
	}
}

void main() {
	while(can_gravity())
	{
		gravitate();
	}
}
