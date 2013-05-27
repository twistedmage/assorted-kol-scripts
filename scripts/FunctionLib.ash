void take_shop(int AllorOne, item it){
	if(shop_amount(it) > 0){
		print("Removing " + it + " from store inventory.");
		if(to_string(AllorOne) == "0")
			visit_url("managestore.php?action=takeall&whichitem=" + to_int(it));
		else if(to_string(AllorOne) == "1")
			visit_url("managestore.php?action=take&whichitem=" + to_int(it));
	}
}
boolean got_item(item tolookup) {
	if(item_amount(tolookup) > 0)
		return true;
	if(have_equipped(tolookup))
		return true;
	return false;
}
boolean AdvCheck(){
	return my_adventures() > 0 && my_inebriety() == 19;
}
void conditions(int n, string conditionsString){
	cli_execute("conditions clear");
	cli_execute("conditions add " + n + conditionsString);
}
void getanduse(int n, item it){
	if(item_amount(it) < n){
		int this = n - item_amount(it);
		if(stash_amount(it) > 0){
			if(stash_amount(it) > this)
				take_stash(this, it);
			else if(stash_amount(it) < this)
				take_stash(stash_amount(it), it);
		}
		else buy(this, it);
	}
	if(!use(n, it))
		if(!eat(n, it))
			if(!drink(n, it))
				return;
}
boolean checkfam(familiar pet){
	if(have_familiar(pet)){
		use_familiar(pet);
		if(can_interact())
			getanduse(1, familiar_equipment(pet));
		return true;
	}
	return false;
}
void stashall(string dowhat, item it){
	if(dowhat == "take")
		if(stash_amount(it) > 0)
			take_stash(stash_amount(it), it);
	if(dowhat == "put")
		if(item_amount(it) > 0)
			put_stash(item_amount(it), it);
}
int worthless_amount(){
	return (available_amount($item[worthless trinket]) + available_amount($item[worthless gewgaw]) + available_amount($item[worthless knick-knack]));
}
boolean save_outfit(string outfitlabel){
	visit_url("inv_equip.php?which=2&action=customoutfit&outfitname=" + outfitlabel);
	return true;
}
boolean HPcare(int target){
	while(my_hp() < target){
		if(have_effect($effect[beaten up]) > 0)
			cli_execute("uneffect beaten up");
		restore_hp(target);
	}
	return (my_hp() >= target);
}
boolean test_skill(int n, skill castme){
	if(have_effect(to_effect(castme)) == 0)
		if(have_skill(castme))
			if(my_maxmp() > mp_cost(castme)){
				use_skill(n, castme);
				return true;
			}
	return false;
}
boolean test_equip(item it){
	if(can_equip(it) && got_item(it) && !have_equipped(it)){
		equip(it);
		return true;
	}
	return false;
}
item stat_to_item(string me, stat st){
	if(me == "Chow"){
		if(st == $stat[muscle]) return $item[knob sausage chow mein];
		if(st == $stat[moxie]) return $item[rat appendix chow mein];
		if(st == $stat[mysticality]) return $item[bat wing chow mein];
		return $item[none];
	}
	if(me == "HiMein"){
		if(st == $stat[muscle]) return $item[hot hi mein];
		if(st == $stat[moxie]) return $item[spooky hi mein];
		if(st == $stat[mysticality]) return $item[sleazy hi mein];
		return $item[none];
	}
	if(me == "LoMein"){
		if(st == $stat[muscle]) return $item[Knoll lo mein];
		if(st == $stat[moxie]) return $item[Spooky lo mein];
		if(st == $stat[mysticality]) return $item[knob lo mein];
		return $item[none];
	}
	if(me == "Lasagna"){
		if(st == $stat[muscle]) return $item[gnat lasagna];
		if(st == $stat[moxie]) return $item[fishy fish lasagna];
		if(st == $stat[mysticality]) return $item[long pork lasagna];
		return $item[none];
	}
	if(me == "TPSdrink"){
		if(st == $stat[muscle]) return $item[bodyslam];
		if(st == $stat[moxie]) return $item[vesper];
		if(st == $stat[mysticality]) return $item[cherry bomb];
		return $item[none];
	}
	if(me == "SDBdrink"){
		if(st == $stat[muscle]) return $item[mon tiki];
		if(st == $stat[moxie]) return $item[mae west];
		if(st == $stat[mysticality]) return $item[gimlet];
		return $item[none];
	}
	if(me == "DBdrink"){
		if(st == $stat[muscle]) return $item[fuzzbump];
		if(st == $stat[moxie]) return $item[rockin' wagon];
		if(st == $stat[mysticality]) return $item[roll in the hay];
		return $item[none];
	}
	if(me == "ShroomWine"){
		if(st == $stat[muscle]) return $item[flaming mushroom wine];
		if(st == $stat[moxie]) return $item[stinky mushroom wine];
		if(st == $stat[mysticality]) return $item[icy mushroom wine];
		return $item[none];
	}
	if(me == "Wad"){
		if(st == $stat[muscle]) return $item[hot wad];
		if(st == $stat[moxie]) return $item[spooky wad];
		if(st == $stat[mysticality]) return $item[cold wad];
		return $item[none];
	}
	return $item[none];
}
void ClassLink(){
	if(my_class() == $class[seal clubber] || my_class() == $class[disco bandit] || my_class() == $class[pastamancer])
		visit_url("guild.php?place=scg");
	else if(my_class() == $class[turtle tamer] || my_class() == $class[accordion thief] || my_class() == $class[sauceror])
		visit_url("guild.php?place=ocg");
}
void trainfam(familiar pet, int goal){
	if(have_familiar(pet) && familiar_weight(pet) < goal){
		use_familiar(pet);
		cli_execute("train base " + goal);
	}
}
item Wand(){
	for it from 1268 upto 1272 by 1{
		if(got_item(to_item(it)))
			return to_item(it);
	}
	return $item[none];
}
boolean utilize_still(){
	item [item] spirits_n_mixers;
	spirits_n_mixers[ $item[grapefruit] ] = $item[tangerine];
	spirits_n_mixers[ $item[lemon] ] = $item[kiwi];
	spirits_n_mixers[ $item[olive] ] = $item[cocktail onion];
	spirits_n_mixers[ $item[orange] ] = $item[kumquat];
	spirits_n_mixers[ $item[soda water] ] = $item[tonic water];
	spirits_n_mixers[ $item[strawberry] ] = $item[raspberry];
	spirits_n_mixers[ $item[bottle of gin] ] = $item[bottle of Calcutta Emerald];
	spirits_n_mixers[ $item[bottle of rum] ] = $item[bottle of Lieutenant Freeman];
	spirits_n_mixers[ $item[bottle of tequila] ] = $item[bottle of Jorge Sinsonte];
	spirits_n_mixers[ $item[bottle of vodka] ] = $item[bottle of Definit];
	spirits_n_mixers[ $item[bottle of whiskey] ] = $item[bottle of Domesticated Turkey];
	spirits_n_mixers[ $item[boxed wine] ] = $item[boxed champagne];
	foreach key in spirits_n_mixers
		if(available_amount( key ) > 0 && stills_available() > 0 && available_amount(key) >= stills_available()) 
			return create(stills_available(), spirits_n_mixers[key]);
	return create(5, stat_to_item("SDBdrink", my_primestat()));
}
boolean resistance(){
	item freshener = $item[pine-fresh air freshener];
	if(test_skill(2, $skill[Elemental Saucesphere]))
		return true;
	if(test_skill(2, $skill[astral shell]))
		return true;
	if(test_equip($item[asshat]))
		return true;
	if(test_equip($item[bum cheek]))
		return true;
	if(test_equip($item[knob goblin harem veil]))
		return true;
	if(test_equip($item[pants of the slug lord]))
		return true;
	if(test_equip(freshener))
		return true;
	if(!test_equip(freshener)){
		if(!can_interact()){
			cli_execute("conditions clear");
			add_item_condition(1, freshener);
			boolean catch=adventure(my_adventures(), $location[bat hole entryway]);
		}
		else retrieve_item(1, freshener);
		if(test_equip(freshener))
			return true;
	}
	return false;
}
void main(){
	print("HAHA");
}
