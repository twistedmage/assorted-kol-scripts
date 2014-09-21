//		last compared version 522

script "bumcheekascend.ash";

import "florist.ash";

//simons global which remembers current combat macro choice
int using_putty=0;

//simon preset some prefs
set_property("bcasc_castEmpathy","true");
set_property("bcasc_unlockHiddenTavern","true");
set_property("bcasc_prepareFoodAndDrink","true");
set_property("bcasc_SwapFood","true");
set_property("bcasc_cellarWineBomb","true");

string bcasc_version = "0.56";
string bcasc_doWarAs = get_property("bcasc_doWarAs"), bcasc_100familiar = get_property("bcasc_100familiar"), bcasc_warOutfit;
boolean bcasc_bartender = get_property("bcasc_bartender").to_boolean(), bcasc_bedroom = get_property("bcasc_bedroom").to_boolean(), 
		bcasc_chef = get_property("bcasc_chef").to_boolean(), bcasc_cloverless = get_property("bcasc_cloverless").to_boolean(), 
		bcasc_doSideQuestArena = get_property("bcasc_doSideQuestArena").to_boolean(), bcasc_doSideQuestJunkyard = get_property("bcasc_doSideQuestJunkyard").to_boolean(),
		bcasc_doSideQuestBeach = get_property("bcasc_doSideQuestBeach").to_boolean(), bcasc_doSideQuestOrchard = get_property("bcasc_doSideQuestOrchard").to_boolean(), 
		bcasc_doSideQuestNuns = get_property("bcasc_doSideQuestNuns").to_boolean(), bcasc_doSideQuestDooks = get_property("bcasc_doSideQuestDooks").to_boolean(), 
		bcasc_fightNS = get_property("bcasc_fightNS").to_boolean(), bcasc_MineUnaccOnly = get_property("bcasc_MineUnaccOnly").to_boolean(), 
		bcasc_AllowML = get_property("bcasc_AllowML").to_boolean(), bcasc_ignoreSafeMoxInHardcore = get_property("bcasc_ignoreSafeMoxInHardcore").to_boolean(),
		bcasc_getLEW = get_property("bcasc_getLEW").to_boolean(), bcasc_RunSCasHC = get_property("bcasc_RunSCasHC").to_boolean(),
		bcasc_unlockHiddenTavern = get_property("bcasc_unlockHiddenTavern").to_boolean(), bcasc_castEmpathy = get_property("bcasc_castEmpathy").to_boolean(),
		bcasc_cellarWineBomb = get_property("bcasc_cellarWineBomb").to_boolean();
//don't do lighthouse if it will be a waste
if(!have_skill($skill[musk of the moose]) || !have_skill($skill[Carlweather's Cantata of Confrontation])) bcasc_doSideQuestBeach=false;
 
/***************************************
* DO NOT EDIT ANYTHING BELOW THIS LINE *
***************************************/

string [int] avatarTree;
if(my_path() == "Avatar of Boris") {
	avatarTree[0] = "Study";
	avatarTree[1] = "Study Fighting";
	avatarTree[2] = "Study Shouting";
	avatarTree[3] = "Study Feasting";
} else if (my_path() == "Avatar of Jarlsberg") {
	avatarTree[0] = "Study";
	avatarTree[1] = "The Path of Breakfast";
	avatarTree[2] = "The Path of Lunch";
	avatarTree[3] = "The Path of Dinner";
	avatarTree[4] = "The Path of Dessert";
}

string bcParseOptions(string inputString, string validOptions) {
	boolean [string] optionUsed;
	string outputString, char;
			
	inputString = to_lower_case(inputString);	
	inputString = replace_string(inputString," ","");

// alias human readable fight(ing) shout(ing) feast(ing) auto man(ual) lute crum(horn) to 1 2 3 321 0 L C
// passing this lot in to this function via options seems far too much like hard work, so leave
// as a hard coded list for now. (it does the right thing when abused for Clancy option parsing)
	inputString = replace_string(inputString,"fight","1");
	inputString = replace_string(inputString,"shout","2");
	inputString = replace_string(inputString,"feast","3");
	inputString = replace_string(inputString,"auto","321");
	inputString = replace_string(inputString,"man","0");
	inputString = replace_string(inputString,"lute","L");
	inputString = replace_string(inputString,"crum","C");
  	
// now filter out characters not in validOptions, and duplicates
	if (inputString != "") {
		for c from 0 to length(inputString) - 1 {
			char = char_at(inputString, c);
			if (contains_text(validOptions, char) && !optionUsed[char]) {
				optionUsed[char] = true;
				outputString += char;
			}
		}
	}

	return outputString;
}

void eat_hot_dog(string dog,location loc)
{
	if(item_amount($item[clan vip lounge key])>0)
	{
		if(my_path()!="Avatar of Jarlsberg" && my_fullness() < fullness_limit())
		{
			if(!get_property("_fancyHotDogEaten").to_boolean())
			{
				if(get_property("_hotdogcheck_"+loc)=="")
				{
					set_property("_hotdogcheck_"+loc,"true");
					abort("maybe eat a "+dog);
				}
			}
		}
	}
}

string avatarOptions  = bcParseOptions(get_property("bcasc_borisSkills"),"0123");		
if (avatarOptions != "") avatarOptions += "0"; // if we run out of options, default to manual stop 

string clancyOptions = bcParseOptions(get_property("bcasc_trainClancy"),"01LC");	

if (bcasc_doWarAs == "frat") {
	bcasc_warOutfit = "frat warrior";
} else if (bcasc_doWarAs == "hippy") {
	bcasc_warOutfit = "war hippy";
} else if (bcasc_doWarAs == "abort") {
	bcasc_warOutfit = "abort";
} else {
	//abort("Please specify whether you would like to do the war as a frat or hippy by downloading the relay script at http://kolmafia.us/showthread.php?t=5470 and setting the settings for the script.");
	bcasc_doWarAs = "frat";
	bcasc_warOutfit = "frat warrior";
	bcasc_doSideQuestArena = true;
	bcasc_doSideQuestJunkyard = true;
	bcasc_doSideQuestBeach = true;
	print("BCC: IMPORTANT - You have not specified whether you would like to do the war as a frat or a hippy. As a result, the script is assuming you will be doing it as a frat, doing the Arena, Junkyard and Beach. Visit the following page to download a script to help you change these settings. http://kolmafia.us/showthread.php?t=5470");
	wait(5);
}

record lairItem {
	string gatename;
	string effectname;
	string a; //Item name 1
	string b;
	string c;
	string d;
	string e;
};
record alias {
	string cliref;
	string functionname;
};
lairItem [int] lairitems;
string councilhtml, html;
int max_bees = 0;
if (get_property("bcasc_maxBees").to_int() > 0) max_bees = get_property("bcasc_maxBees").to_int();

//SIMON predeclare

void use_putty();
void setMood(string var);
boolean bcascWand();
boolean bcascWand(boolean force);
boolean bumMiniAdv(int adventures, location loc);
boolean bumMiniAdvNoAbort(int adventures, location loc);
boolean bcascMacguffinDiary();
void use_rain_man(monster mob);
void use_rain_man();

boolean load_current_map(string fname, lairItem[int] map) {
	print("BCC: Trying to check " + fname + " on the Bumcheekcity servers.", "purple");
	string domain = "http://kolmafia.co.uk/";
	string curr = visit_url(domain + "index.php?name=" + fname);
	file_to_map(fname+".txt", map);
	
	//If the map is empty or the file doesn't need updating
	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) 
	{
		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) 
		{
			return false;
		}
		map_to_file(map, fname+".txt");
		set_property(fname+".txt", curr);
		print("..."+fname+".txt updated.");
		return true;
	}
	
	return true;
}

boolean load_current_map(string fname, alias[int] map) {
	print("BCC: Trying to check " + fname + " on the Bumcheekcity servers.", "purple");
	string domain = "http://kolmafia.co.uk/";
	string curr = visit_url(domain + "index.php?name=" + fname);
	file_to_map(fname+".txt", map);
	
	//If the map is empty or the file doesn't need updating
	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) 
	{
		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) 
		{
			return false;
		}
		map_to_file(map, fname+".txt");
		set_property(fname+".txt", curr);
		print("..."+fname+".txt updated.");
		return true;
	}
	
	return true;
}

boolean load_current_map(string fname, string[int] map) {
	print("BCC: Trying to check " + fname + " on the Bumcheekcity servers.", "purple");
//	string domain = "http://bumcheekcity.com/kol/maps/";
//	string curr = visit_url("http://bumcheekcity.com/kol/maps/index.php?name="+fname+"&username="+my_name());
	string domain = "http://kolmafia.co.uk/";
	string curr = visit_url(domain + "index.php?name=" + fname);
	file_to_map(fname+".txt", map);
	
	//If the map is empty or the file doesn't need updating
	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) 
	{

		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) 
		{
			return false;
		}
		map_to_file(map, fname+".txt");
		set_property(fname+".txt", curr);
		print("..."+fname+".txt updated.");
	}
	
	return true;
}

/******************
* BEGIN FUNCTIONS *
******************/

boolean tomes_left()
{
	//assume not in casual
	int tot_summons=get_property("_sugarSummons").to_int() + get_property("_clipartSummons").to_int() + get_property("_radlibSummons").to_int() + get_property("_snowconeSummons").to_int() + get_property("_stickerSummons").to_int();
	return tot_summons<3;
}

void ascendLog(string finished) {
	string [int] settingsMap;
	string settings = "{";
	string stages;
	string turns = my_turncount().to_string();
	string days = my_daycount().to_string();
	string ascnum = my_ascensions().to_string();
	string url = "http://bumcheekcity.com/kol/asclog.php?username="+my_name()+"&mafiaversion="+get_version()+"&mafiarevision="+get_revision();
		url += "&scriptversion="+bcasc_version+"&finished="+finished+"&scriptname="+__FILE__+"&days="+days+"&turns="+turns+"&ascnum="+ascnum;
	
	load_current_map("bcsrelay_settings", settingsMap);
	foreach x in settingsMap {
		settings += "\""+settingsMap[x]+"\":"+url_encode(get_property(settingsMap[x]))+",";
	}
	url += "&settings="+settings+"}";
	
	string api = visit_url("api.php?what=status&for=bumcheekascend v"+bcasc_version);
	
	api = replace_all(create_matcher("\"pwd\":\"[a-z0-9]+\",", api), "");
	
	url += "&api="+api;
	
    string response;
    try { response = visit_url(url); }
	finally { response = "a"; }
}

boolean have_path_familiar(familiar fam) {
	if(my_path() == "Trendy")
		return have_familiar(fam) && is_trendy(fam);
	else if(my_path() == "Bees Hate You")
		return have_familiar(fam) && !contains_text(to_lower_case(to_string(fam)), "b");
	else if(my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg")
		return false;
	else if(my_path() == "Avatar of Sneaky Pete")
		return false;
	else
		return have_familiar(fam);
}

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + (get_property("autoSatisfyWithCloset") == "true" ? closet_amount(i) : 0) + equipped_amount(i);
	
	//Make a check for familiar equipment NOT equipped on the current familiar. 
	foreach fam in $familiars[] {
		if (have_path_familiar(fam) && fam != my_familiar()) {
			if (name == to_string(familiar_equipped_equipment(fam)) && name != "none") {
				a = a + 1;
			}
		}
	}
	
	//print("Checking for item "+name+", which it turns out I have "+a+" of.", "fuchsia");
	return a;
}


//SIMON ADDED FUNCTIONS
boolean putties_possible()
{
	//how many putties can we make?
	int putty_methods = min(1,i_a("rain-doh black box") + i_a("rain-doh box full of monster")) + min(1,i_a("spooky putty sheet") + i_a("spooky putty monster"));
	int max_putties = 0;
	if(putty_methods==1)
		max_putties=5;
	else if(putty_methods==2)
		max_putties=6;
		
	boolean putties_left=(to_int(get_property("spookyPuttyCopiesMade")) + to_int(get_property("_raindohCopiesMade")))< max_putties;
	return  putties_left;
}

void clear_combat_macro()
{
	print("Clearing combat macro","lime");
	visit_url("account.php?actions[]=autoattack&autoattack=0&flag_aabosses=1&pwd&action=Update");
	using_putty=0;
}

void set_combat_macro(boolean use_putty)
{
/*	switch(my_primestat())
	{
		case $stat[muscle] :
			if(use_putty)
				visit_url("account.php?actions[]=autoattack&autoattack=9974885&flag_aabosses=1&pwd&action=Update");
			else
				visit_url("account.php?actions[]=autoattack&autoattack=9982716&flag_aabosses=1&pwd&action=Update");
		break;
		case $stat[moxie] :
			if(use_putty)
				visit_url("account.php?actions[]=autoattack&autoattack=9974886&flag_aabosses=1&pwd&action=Update");
			else
				visit_url("account.php?actions[]=autoattack&autoattack=9982715&flag_aabosses=1&pwd&action=Update");
		break;
		case $stat[mysticality] :
				if(use_putty)
					visit_url("account.php?actions[]=autoattack&autoattack=9974884&flag_aabosses=1&pwd&action=Update");
				else
					visit_url("account.php?actions[]=autoattack&autoattack=9982714&flag_aabosses=1&pwd&action=Update");
		break;
		default:
			abort("Unrecognised mainstat in set_combat_macro()");
	}*/
	if(use_putty)
	{
		//putty
		if(monster_level_adjustment() > 151 && using_putty!=-3)
		{
			visit_url("account.php?actions[]=autoattack&autoattack=99126415&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=-3;
		}
		else if(monster_level_adjustment() > 75 && using_putty!=-2)
		{
			visit_url("account.php?actions[]=autoattack&autoattack=99126413&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=-2;
		}
		else if(using_putty!=-1)
		{
			visit_url("account.php?actions[]=autoattack&autoattack=99106733&flag_aabosses=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=-1;
		}
	}
	else if(!use_putty)
	{
		//noputty
		if(monster_level_adjustment() > 151 && using_putty!=3)
		{
			visit_url("account.php?actions[]=autoattack&autoattack=99126414&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=3;
		}
		else if(monster_level_adjustment() > 75 && using_putty!=2)
		{
			visit_url("account.php?actions[]=autoattack&autoattack=99126412&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=2;
		}
		else if(using_putty!=1)
		{
			visit_url("account.php?actions[]=autoattack&autoattack=99106734&flag_aabosses=1&flag_compactmanuel=1&pwd&action=Update");
			using_putty=1;
		}
	}
	
	//find and write out chosen macro
	string skill_str =visit_url("account.php?tab=combat");
	matcher skill_mtch = create_matcher("option selected=\"selected\" value=\"(\\d*)\">([\\w \(\)]*)",skill_str);
	if(skill_mtch.find())
	{
		print("combat macro set to \""+skill_mtch.group(2)+"\"","lime");
	}
	else
		abort("Matcher couldn't work out what combat macro was chosen");
}

void set_combat_macro()
{
	//should we use the putty or non putty macro?
	if(putties_possible())
		set_combat_macro(true);
	else
		set_combat_macro(false);
}

void get_dungeon_kit()
{
	//only do it in ronin, or we'll waste any we have saved
	if(!can_interact())
	{
		while(i_a("GameInformPowerDailyPro magazine")>0)
		{
			int num_kits = i_a("dungeoneering kit");
			//use it
			string str=visit_url("inv_use.php?pwd&which=3&whichitem=6174");
			str=visit_url("inv_use.php?pwd&confirm=Yep.&whichitem=6174");
			//now adv in dungeon for kit
			cli_execute("mood clear"); //no need to fire mood when we won't spend an adv
			adv1($location[Video Game Level 1],0,"");
			if(i_a("dungeoneering kit") != (num_kits+1))
				abort("Seems to have failed, went from "+num_kits.to_string()+" to "+i_a("dungeoneering kit").to_string());
		}
		//got all the kits we can, now use them
		cli_execute("use * dungeoneering kit");
	}
}

void vamp_out()
{
	print("Checking vamping","lime");
	if(available_amount($item[plastic vampire fangs])>0 && !to_boolean(get_property("_interviewIsabella")))
	{
		//equip fangs
		equip($item[plastic vampire fangs]);
		
		//visit isabella
		if(my_primestat()==$stat[muscle])
			set_property("choiceAdventure546","4");
		else if(my_primestat()==$stat[mysticality])
			set_property("choiceAdventure546","5");
		else
			set_property("choiceAdventure546","6");
		print("about to start vamping","lime");
		visit_url("town.php?action=vampout");
		print("begun vamping","lime");
		visit_url("choice.php?whichchoice=546&option=2&choiceform2=Visit+Isabella%27s&pwd");
		print("visited isabella","lime");
		visit_url("choice.php?pwd&whichchoice=546&option=1&choiceform1=See+Where+the+Night+Takes+You");
		print("saw where the night takes us","lime");
		
		//make choices based on primestat
		if(my_primestat()==$stat[muscle])
		{
			visit_url("choice.php?pwd&whichchoice=546&option=3&choiceform3=Drain+Her+Dry");
			print("drained her","lime");
		}
		else if(my_primestat()==$stat[moxie])
		{
			visit_url("choice.php?pwd&whichchoice=546&option=2&choiceform2=Redirect+Your+Desire");
			print("redirected desire","lime");
			visit_url("choice.php?pwd&whichchoice=546&option=2&choiceform2=Go+to+the+Bar");
			print("went to bar","lime");
			visit_url("choice.php?pwd&whichchoice=546&option=1&choiceform1=Drink+the+RealBlud");
			print("drank the blood","lime");
		}
		else
		{
			visit_url("choice.php?pwd&whichchoice=546&option=3&choiceform3=Tell+Her+How+You+Feel");
			visit_url("choice.php?pwd&whichchoice=546&option=1&choiceform1=Find+Other+Prey");
		}
	}
}

boolean hasShield() {
	foreach it, i in get_inventory() {
		if (item_type(it) == "shield" && can_equip(it))
			return true;
	}
	if (item_type(equipped_item($slot[off-hand])) == "shield")
		return true;
	return false;
}

boolean isExpectedMonster(string opp) {
	location loc = my_location();

	boolean haveOutfitEquipped(string outfit) {
		boolean anyEquipped = false;
		boolean allEquipped = true;
		foreach key, thing in outfit_pieces(outfit) {
			if (have_equipped(thing)) {
				anyEquipped = true;
			} else {
				allEquipped = false;
				break;
			}
		}

		return anyEquipped && allEquipped;
	}

	//Fix up location appropriately. :(
	if (loc == $location[wartime frat house]) {
		if (haveOutfitEquipped("hippy disguise") || haveOutfitEquipped("war hippy fatigues"))
			loc = $location[wartime frat house (hippy disguise)];
	} else if (loc == $location[wartime hippy camp]) {
		if (haveOutfitEquipped("frat boy ensemble") || haveOutfitEquipped("frat warrior fatigues"))
		loc = $location[wartime hippy camp (frat disguise)];
	}

	monster mon = opp.to_monster();
	boolean expected = appearance_rates(loc) contains mon;
	return expected;
}

//Checks to see if we need to hunt for a certain key in KOLHS
boolean need_key(location loc) {
	switch(loc) {
		case $location[8-bit Realm]:
			if(i_a("universal key") > 0 || i_a("digital key") > 0) return false;
			break;
		case $location[The Hole in the Sky]:
			if(i_a("richard's star key") > 0 || (i_a("richard's star key") == 0 && i_a("universal key") > 0 && i_a("digital key") > 0) || (i_a("richard's star key") == 0 && i_a("universal key") > 1 && i_a("digital key") == 0)) return false;
			break;
//		case $location[Daily Dungeon]:
	}
	return true;
}

//Returns the string which we'll use for the maximiser, or nothing if this would be inappropriate. 
string prepSNS() {
	void fold() {
		visit_url("bedazzle.php?action=fold&pwd=");
	}
	
	//If we don't have a sticker tome, abort.
	if (!can_interact() && !contains_text(visit_url("campground.php?action=bookshelf"), "Sticker")) {
		return "";
	} else {
		item i = $item[scratch 'n' sniff UPC sticker];
		foreach s in $slots[sticker1, sticker2, sticker3] {
			if (equipped_item(s) != i && item_amount(i) > 0) {
				equip(s, i);
			}
		}
	}

	if (my_primestat() == $stat[Moxie] && in_hardcore()) {
		if (i_a("scratch n sniff sword") > 0) fold();
		if (i_a("scratch n sniff crossbow") > 0) return "+equip scratch n sniff crossbow";
		return "";
	} else {
		if (i_a("scratch n sniff crossbow") > 0) fold();
		if (i_a("scratch n sniff sword") > 0) return "+equip scratch n sniff sword";
		return "";
	}
	return "";
}

string safe_visit_url(string url) {
    string response;
    try { response = visit_url( url ); }
    finally { return response; }
    return response;
}

//Thanks to Bale and slyz here!
effect [item] allBangPotions() {
	effect [item] potion;
	for id from 819 to 827 {
		switch( get_property("lastBangPotion"+id) ) {
			case "sleepiness": potion[id.to_item()] = $effect[ Sleepy ]; break;
			case "confusion": potion[id.to_item()] = $effect[ Confused ]; break;
			case "inebriety": potion[id.to_item()] = $effect[ Antihangover ]; break;
			case "ettin strength": potion[id.to_item()] = $effect[ Strength of Ten Ettins ]; break;
			case "blessing": potion[id.to_item()] = $effect[ Izchak's Blessing ]; break;
			case "healing": break;
			default: potion[id.to_item()] = get_property("lastBangPotion"+id).to_effect();
		}
	}
	return potion;
}

//Returns true if we have a shield and Hero of the Halfshell.
boolean anHero() {
	if (!have_skill($skill[Hero of the Half-Shell])) return false;
	if (my_path() == "Way of the Surprising Fist" || my_path() == "Zombie Slayer") return false;  
	if (!(my_primestat() == $stat[Muscle])) return false;
	if (get_property("bcasc_lastShieldCheck") == today_to_string()) return true;
	
	if(hasShield()) {
		cli_execute("set bcasc_lastShieldCheck = "+today_to_string());
		print("BCC: You appear to have a shield. If you autosell your last shield, this script is going to behave very strangely and you're an idiot.", "purple");
		return true;
	}
	
	print("BCC: You don't have a shield. It might be better to get one. ", "purple");
	return false;
}

//Returns a string of "dark potion", or whatever. 
effect effectWeNeed() {
	string html = visit_url("lair1.php?action=gates");
	effect e = $effect[none];
	
	if (contains_text(html, "Gate of Light")) { e = $effect[Izchak's Blessing]; }
	if (contains_text(html, "Gate of That Which is Hidden")) { e = $effect[Object Detection]; }
	if (contains_text(html, "Gate of the Mind")) { e = $effect[Strange Mental Acuity]; }
	if (contains_text(html, "Gate of the Ogre")) { e = $effect[Strength of Ten Ettins]; }
	if (contains_text(html, "Gate that is Not a Gate")) { e = $effect[Teleportitis]; }
	print("BCC: The effect we need for the gate is "+e.to_string(), "purple");
	if (e == $effect[none]) abort("Error determining effect needed to pass the gates!");
	return e;
}
string bangPotionWeNeed() {
	
	effect e = effectWeNeed();
	foreach pot, eff in allBangPotions() {
		if (e == eff) {
			print("BCC: The potion we need is the "+pot, "purple");
			return pot;
		}
	}
	print("BCC: We could not yet determine which potion gives us the necessary effect.", "purple");
	return "";
}

void bcAutoAvatar(string avatar) {
	int i, avatarOption, avatarLength;
	string avatarResult;
	string gate = (my_path() == "Avatar of Boris" ? "gate1" : (my_path() == "Avatar of Jarlsberg" ? "gate2" : "gate3"));

	if (avatar == "Jarlsberg") {
		print("BCC: You have free Jarlsberg-points, but the script cannot yet do anything with them.", "purple");
	} else if (avatarOptions != "") {
		avatarLength = length(avatarOptions);
		for i from 0 to avatarlength - 1 {
			avatarOption = char_at(avatarOptions,i).to_int();
			avatarResult = visit_url("da.php?place=" + gate);
			while (contains_text(avatarResult, "hungering for knowledge") && contains_text(avatarResult, avatarTree[avatarOption])) {
				if (avatarOption == 0) abort("BCC: stopping so you can worship in the glory of " + avatar + "."); 
				print("BCC: "+avatarTree[avatarOption], "purple");
				avatarResult = visit_url("da.php?whichtree="+avatarOption+"&action=" + avatar + "skill");
			}
		}
	} else {
		print("BCC: Not worshipping in glory of " + avatar + ".","purple");
	}
}

boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme, string combat, string consultScript);
void setMood(string combat); //Predeclare to make clancy work
string bumRunCombat();
boolean bumAdv(location loc);

void bcAutoClancy() {
	void clancyLoop(location loc)
	{
		print("Doing clancy loop in "+loc,"purple");
		while(my_adventures()>0 && contains_text(visit_url("questlog.php?which=1"),"The Minstrel Cycle"))
		{
	
			//place florist friar plants
			choose_all_plants("", loc);
			
			bumMiniAdvNoAbort(1, loc);
		}
		print("Done with clancy!","purple");
	}


// convert options to mode string, manual overrides auto, handle options being in any order
	string clancyMode = "";
	if (contains_text(clancyOptions,"0")) {
		clancyMode = "0";
	} else {
		if (contains_text(clancyOptions,"1")) {
			clancyMode = "1";
		}
	}
	 
	boolean luteOnly = contains_text(clancyOptions,"L");
	if (((minstrel_instrument() == $item[Clancy's lute]) || (i_a("Clancy's lute") > 0)) && luteOnly) clancyMode = "L";

	if (clancyMode == "")  print("BCC: Ignoring Clancy", "purple");
	if (clancyMode == "L") print("BCC: Ignoring Clancy as we have a Lute", "purple");
	 			
	if ((clancyMode == "0") || (clancyMode == "1")) {
		string charpane = visit_url("charpane.php");
		if (contains_text(charpane, "_att.gif")) {
			print("BCC: accepting next Clancy quest.", "purple"); 
			string clancyHtml = visit_url("main.php?action=clancy");
			matcher clancyMatch = create_matcher("<b>Your Minstrel ([a-zA-Z]+)</b>", clancyHtml);
			if (clancyMatch.find()) {
				string minstrel = clancyMatch.group(1);
				print("minstrel is "+minstrel,"purple");

// FIXME - waiting for someone clever to write the auto-code, need to -combat first
				switch (minstrel) {
					case "Vamps"	: visit_url("choice.php?pwd&whichchoice=571&option=1");
							break;
//A Barroom Brawl		Encounter: Jackin' the Jukebox

					case "Clamps"	: visit_url("choice.php?pwd&whichchoice=572&option=1");
							break;
//cobbsknob.php?action=tolabs	Encounter: A Miner Variation

					case "Stamps"	: visit_url("choice.php?pwd&whichchoice=573&option=1");
							break;
//plains.php?action=lutergrave	Encounter: The Luter

					case "Camps"	: visit_url("choice.php?pwd&whichchoice=576&option=1");
							break;
//The Icy Peak			Encounter: Mercury Rising

					case "Scamp"	: visit_url("choice.php?pwd&whichchoice=577&option=1");
							break;
//The Middle Chamber		Encounter: Don't You Know Who I Am?

					default		: abort("BCC: ERROR - bcAutoClancy() - Unexpected minstrel status: "+minstrel);
				}
			} else {
				abort("BCC: ERROR - bcAutoClancy() - Failed to find a match when paying attention to Clancy.");
			}
		}
		//actually do the quest
		string clancyHtml = visit_url("questlog.php?which=1");
		if(contains_text(clancyHtml,"The Minstrel Cycle"))
		{
			matcher clancyMatch = create_matcher("Clancy would like you to ([a-zA-Z ]+),", clancyHtml);
			if (clancyMatch.find()) {
				string minstrel = clancyMatch.group(1);
				print("minstrel quest is "+minstrel,"purple");

// FIXME - waiting for someone clever to write the auto-code, need to -combat first
				switch (minstrel) {
					case "take him to the Typical Tavern"	: 
							clancyLoop($location[A Barroom Brawl]);
							break;
//A Barroom Brawl		Encounter: Jackin' the Jukebox

					case "take him to the Knob Shaft"	: 
							clancyLoop($location[the knob shaft]);
							break;
//cobbsknob.php?action=tolabs	Encounter: A Miner Variation

					case "find the grave of The Luter"	: 
							visit_url("place.php?whichplace=plains&action=lutersgrave");
							run_combat();
							break;
//plains.php?action=lutergrave	Encounter: The Luter

					case "take him to the The Icy Peak"	: 
							clancyLoop($location[The Icy Peak]);
							break;
//The Icy Peak			Encounter: Mercury Rising

					case "take him to the Ancient Buried Pyramid" :
							clancyLoop($location[The Middle Chamber]);
							break;
//The Middle Chamber		Encounter: Don't You Know Who I Am?

					default		: abort("BCC: ERROR - bcAutoClancy() - Unexpected minstrel quest: "+minstrel);
				}
		} else {
			print ("BCC: Clancy has no quest.", "purple");
		}
		if(contains_text(visit_url("questlog.php?which=1"),"The Minstrel Cycle"))
			abort("clancy wants you to do something (not sure what)");
		}
	}
}

void bcCrumHorn() {
	if ((my_path() == "Avatar of Boris") && ((minstrel_instrument() != $item[clancy's crumhorn]) && (i_a("clancy's crumhorn") == 0)) && (contains_text(clancyOptions,"C"))) {
		if (my_meat() > 3000) {
			print("BCC: buying the Crumhorm from uncle P's", "purple");
			if(i_a("post-holiday sale coupon")>0)use(1,$item[post-holiday sale coupon]);
			buy(1 , $item[clancy's crumhorn]);
		} else {
			print("BCC: not enough meat yet for a Crumhorn", "purple");
		}	
	}
}

void bcascBugbearHunt(); //Pre-declare so that the next function won't crash

void get_kolhs_buff(string bufftype)
{
	if(my_path()=="KOLHS" && to_int(get_property("_kolhsSavedByTheBell"))<3)
	{
		//which buff is for us
		effect mybuff;
		int mychoice;
		
		if(bufftype=="stats")
		{
			if(my_primestat()==$stat[muscle])
			{
				if(get_property("_kolhsCutButNotDried").to_boolean())
					return;
				mybuff=$effect[Cut But Not Dried];
				mychoice=4;
			}
			else if(my_primestat()==$stat[mysticality])
			{
				if(get_property("_kolhsPoeticallyLicenced").to_boolean())
					return;
				mybuff=$effect[Poetically Licensed];
				mychoice=2;
			}
			else
			{
				if(get_property("_kolhsIsskayLikeAnAshtray").to_boolean())
					return;
				mybuff=$effect[Isskay like an Ashtray]; //mopxie
				mychoice=5;
			}
		}
		
		if(bufftype=="meat" || bufftype=="items")
		{
			if(get_property("_kolhsSchoolSpirited").to_boolean())
				return;
			mybuff=$effect[school spirited];
			mychoice=1;
		}
		
		if(bufftype=="camera")
		{
			mybuff=$effect[none];
			mychoice=3;
		}
			
		//should we get it?
		if(have_effect(mybuff)<1)
		{
			set_property("choiceAdventure772",mychoice);
			cli_execute("checkpoint");
			familiar fam = my_familiar();
			use_familiar($familiar[steam-powered cheerleader]);
			cli_execute("unequip hat");
			print("trying to get kolhs buff","blue");
			adv1($location[The Hallowed Halls],1,"");
			print("finished trying","blue");
			use_familiar(fam);
			cli_execute("outfit checkpoint");
			if(have_effect(mybuff)==0)
				abort("Failed to get kolhs buff");
		}
	}
}

//version of bcCouncil which can force a visit
void bcCouncil(boolean force) {
	//if we have shower buff, use stat shit
	if( my_path()=="Heavy Rains" || (have_effect($effect[muscle unbound]) + have_effect($effect[thaumodynamic]) + have_effect($effect[so fresh and so clean]))>0)
	{
		cli_execute("use * 31337 scroll");
		cli_execute("use * stat script");
		cli_execute("use * hermit script");
		cli_execute("use * chest of the bonerdagon");
		if (my_level()>8 && i_a("giant pinky ring") == 0 && get_dwelling() != $item[Frobozz Real-Estate Company Instant House (TM)]) { 
			cli_execute("leaflet stats");
			if (my_path() != "Bees Hate You") { if (cli_execute("use 1 instant house")) {} }
		}
		//seems to only work second time
		vamp_out();
		vamp_out();
		//get a kolhs stat buff
		get_kolhs_buff("stats");
	}
	int lastVisit = get_property("bcasc_lastCouncilVisit").to_int();
	int thisVisit = 1000 * my_ascensions()+my_level();
	if (force || lastVisit < thisVisit || lastVisit / 1000 != my_ascensions() || lastVisit % 1000 <= my_level()) {
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());
		
		string visitString = thisVisit.to_string();
		set_property("bcasc_lastCouncilVisit", visitString);
		visit_url("council.php");
		if (my_path() == "Avatar of Boris") {
			bcAutoAvatar(substring(my_path(), 10));
			bcAutoClancy();
		}
	}
	//We want to run this everytime so that it gets called when needed
	if (my_path() == "Bugbear Invasion") {
		if (i_a("BURT") >= 5 && i_a("key-o-tron") == 0)
			retrieve_item(1, $item[key-o-tron]);
		if (i_a("key-o-tron") > 0 && inebriety_limit() > 15)
			bcascBugbearHunt();
	}
	visit_url("questlog.php?which=1");
	visit_url("questlog.php?which=2");
}

void bcCouncil() {bcCouncil(false);}

//Thanks, Rinn!
string beerPong(string page) {
	record r {
		string insult;
		string retort;
	};

	r [int] insults;
	insults[1].insult="Arrr, the power of me serve'll flay the skin from yer bones!";
	insults[1].retort="Obviously neither your tongue nor your wit is sharp enough for the job.";
	insults[2].insult="Do ye hear that, ye craven blackguard?  It be the sound of yer doom!";
	insults[2].retort="It can't be any worse than the smell of your breath!";
	insults[3].insult="Suck on <i>this</i>, ye miserable, pestilent wretch!";
	insults[3].retort="That reminds me, tell your wife and sister I had a lovely time last night.";
	insults[4].insult="The streets will run red with yer blood when I'm through with ye!";
	insults[4].retort="I'd've thought yellow would be more your color.";
	insults[5].insult="Yer face is as foul as that of a drowned goat!";
	insults[5].retort="I'm not really comfortable being compared to your girlfriend that way.";
	insults[6].insult="When I'm through with ye, ye'll be crying like a little girl!";
	insults[6].retort="It's an honor to learn from such an expert in the field.";
	insults[7].insult="In all my years I've not seen a more loathsome worm than yerself!";
	insults[7].retort="Amazing!  How do you manage to shave without using a mirror?";
	insults[8].insult="Not a single man has faced me and lived to tell the tale!";
	insults[8].retort="It only seems that way because you haven't learned to count to one.";

	while (!page.contains_text("victory laps"))
	{
		string old_page = page;

		if (!page.contains_text("Insult Beer Pong")) abort("You don't seem to be playing Insult Beer Pong.");

		if (page.contains_text("Phooey")) {
			print("Looks like something went wrong and you lost.", "lime");
			return page;
		}
	
		foreach i in insults {
			if (page.contains_text(insults[i].insult)) {
				if (page.contains_text(insults[i].retort)) {
					print("Found appropriate retort for insult.", "lime");
					print("Insult: " + insults[i].insult, "lime");
					print("Retort: " + insults[i].retort, "lime");
					page = visit_url("beerpong.php?value=Retort!&response=" + i);
					break;			
				} else {
					print("Looks like you needed a retort you haven't learned.", "red");
					print("Insult: " + insults[i].insult, "lime");
					print("Retort: " + insults[i].retort, "lime");
	
					// Give a bad retort
					page = visit_url("beerpong.php?value=Retort!&response=9");
					return page;
				}
			}
		}

		if (page == old_page) abort("String not found. There may be an error with one of the insult or retort strings."); 
	}

	print("You won a thrilling game of Insult Beer Pong!", "lime");
	return page;
}

void betweenBattle() {
	cli_execute("mood execute; uneffect beaten up;");
	
	//setup zombie heal props
	if (my_path() == "Zombie Slayer")
	{
		//recover at mylevel, up to 3* mylevel
		set_property("baleUr_ZombieAuto",to_string(my_level()));
		set_property("baleUr_ZombieTarget",to_string(3*my_level()));
	}
	if (to_float(my_hp()) / my_maxhp() < to_float(get_property("hpAutoRecovery"))) restore_hp(0); 
	//keep 3*level zombies in horde
	if (my_path() == "Zombie Slayer")
		if(my_mp()< to_int(get_property("baleUr_ZombieAuto"))) restore_mp(0);
	else if (to_float(my_mp()) / my_maxmp() < to_float(get_property("mpAutoRecovery"))) restore_mp(0);  

	if (have_effect($effect[Beaten Up]) > 0) abort("Script could not remove Beaten Up.");
	if (my_adventures() == 0)
	{
		cli_execute("shower "+my_primestat());
		abort("No adventures left :(");
	}
	
	//summon cosmic shit
	if(!to_boolean(get_property("_conjuredEggs")) && have_skill($skill[Conjure Eggs]) && my_mp()>30)
	{
		use_skill($skill[Conjure Eggs]);
		set_property("_conjuredEggs","true");
	}
	if(!to_boolean(get_property("_conjuredDough")) && have_skill($skill[Conjure Dough]) && my_mp()>30)
	{
		use_skill($skill[Conjure Dough]);
		set_property("_conjuredDough","true");
	}
	if(!to_boolean(get_property("_conjuredCheese")) && have_skill($skill[Conjure Cheese]) && my_mp()>30)
	{
		use_skill($skill[Conjure Cheese]);
		set_property("_conjuredCheese","true");
	}
	if(!to_boolean(get_property("_conjuredPotato")) && have_skill($skill[Conjure Potato]) && my_mp()>30)
	{
		use_skill($skill[Conjure Potato]);
		set_property("_conjuredPotato","true");
	}
	if(!to_boolean(get_property("_conjuredMeat")) && have_skill($skill[Conjure Meat Product]) && my_mp()>30)
	{
		use_skill($skill[Conjure Meat Product]);
		set_property("_conjuredMeat","true");
	}
	if(!to_boolean(get_property("_conjuredFruit")) && have_skill($skill[Conjure Fruit]) && my_mp()>30)
	{
		use_skill($skill[Conjure Fruit]);
		set_property("_conjuredFruit","true");
	}
	if(!to_boolean(get_property("_conjuredCream")) && have_skill($skill[Conjure Cream]) && my_mp()>30)
	{
		use_skill($skill[Conjure Cream]);
		set_property("_conjuredCream","true");
	}
	if(!to_boolean(get_property("_conjuredVegetables")) && have_skill($skill[Conjure Vegetables]) && my_mp()>10)
	{
		use_skill($skill[Conjure Vegetables]);
		set_property("_conjuredVegetables","true");
	}
	if(i_a("Really dense meat stack")>0)
		cli_execute("autosell * really dense meat stack");
	if(i_a("dense meat stack")>0)
		cli_execute("autosell * dense meat stack");
	if(i_a("meat stack")>0)
		cli_execute("autosell * meat stack");
	if(i_a("CSA discount card")>0)
		cli_execute("use * CSA discount card");
	if(!to_boolean(get_property("_fireStartingKitUsed")) && i_a("CSA fire starting kit")>0)
	{
		set_property("choiceAdventure595","1"); //use the sticks
		cli_execute("use csa fire starting kit");
	}
	//if (get_counters("fortune cookie", 0, 0) == "Fortune Cookie" && get_property("counterScript") != "") cli_execute("call " + get_property("counterScript Fortune Cookie"));
}

void bprint(string message) {
	print("BCC: We have completed the stage " + message,"purple");
}

boolean buMax(string maxme, int maxMainstat) {
	if (get_property("bcasc_dontTouchStuff") == "true") {
		print("BCC: Not changing outfit as bcasc_dontTouchStuff is true", "purple");
		return true;
	}
	print("BCC: Maximizing '"+maxme+"'", "blue");
	
	//SIMON: prevent mask conflicts
	if(available_amount($item[Juju Mojo Mask])>0 && available_amount($item[v for vivala mask])>0)
	{
		if(equipped_amount($item[v for vivala mask])>0)
			cli_execute("unequip v for vivala mask");
		if(equipped_amount($item[Juju Mojo Mask])>0)
			cli_execute("unequip Juju Mojo Mask");
	}
	
	if (my_path() == "Way of the Suprising Fist") maxme += " -weapon -offhand";
	if (my_path() == "Avatar of Boris" && !contains_text(maxme, "outfit")) {
		if (i_a("Boris's Helm") > 0) maxme += " +equip Boris's Helm";
		else if (i_a("Boris's Helm (askew)") > 0) maxme += " +equip Boris's Helm (askew)";
	}
	
	//folding
	if(my_name()=="twistedmage")
	{
		if (i_a("Loathing Legion necktie") == 0 && my_path()!="Heavy Rains") //not trendy
			cli_execute("fold Loathing Legion necktie");
		//if we are high level  we don't need ml
		if(my_level()>=13)
		{
			//if we had a popped collar from before, unpop and change outfit
			if (i_a("Sneaky Pete's leather jacket (collar popped)") > 0)
			{
				cli_execute("outfit bumcheekascend");
				cli_execute("fold Sneaky Pete's leather jacket");
				cli_execute("equip Sneaky Pete's leather jacket");
				cli_execute("outfit save bumcheekascend");
			}
		}
		else //normal circumstances we want the +ml from popped collar
		{
			if (i_a("Sneaky Pete's leather jacket") > 0)
				cli_execute("fold Sneaky Pete's leather jacket (collar popped)");		
		}
	}
	
	//in heavy rains, catcher's mitt is really important for items
	if(my_path() == "Heavy Rains" && contains_text(maxme,"item") && i_a("fishbone catcher's mitt")>0)
		maxme += " +equip fishbone catcher's mitt";
	
	if(my_path() == "Avatar of Sneaky Pete" && !contains_text(maxme, "outfit")) {
		if (i_a("Sneaky Pete's leather jacket") > 0) maxme += " +equip Sneaky Pete's leather jacket";
		else if (i_a("Sneaky Pete's leather jacket (collar popped)") >0) maxme += " +equip Sneaky Pete's leather jacket (collar popped)";
	}

	if (!in_hardcore() && !bcasc_RunSCasHC) {
		if (cli_execute("outfit bumcheekascend")) {}
		//SIMON: if we are supposed to maximize resistance, do it without tiebreaker
		foreach el in $elements[]
		{
			if(contains_text(maxme,el+" res"))
			{
				cli_execute("maximize "+el+" res -1 tie");
			}
		}
		if (contains_text(maxme, "+outfit") && contains_text(maxme, "+equip")) {
			string [int] strs = split_string(maxme, "[\\+\\,]");
			foreach i in strs {
				if (strs[i] != "") {
					//print(strs[i], "green");
					cli_execute(strs[i]);
				}
			}
			return true;
		}
		if (contains_text(maxme, "+outfit")) {
			cli_execute("outfit "+maxme.replace_string("+outfit ", ""));
			return true;
		}
		if (contains_text(maxme, "pirate fledges")) {
			cli_execute("equip acc3 pirate fledges");
			return true;
		}
		if (contains_text(maxme, "mega gem")) {
			cli_execute("equip acc3 mega gem");
			cli_execute("equip acc2 talisman o' nam");
			return true;
		}
		if (contains_text(maxme, "talisman")) {
			cli_execute("equip acc3 talisman o' nam");
			return true;
		}
		if (contains_text(maxme, "nuns")) {
			cli_execute("outfit "+bcasc_warOutfit);
			return true;
		}
		//if we are supposed to equip something specific, just do it without tie
		if(contains_text(maxme,"equip")){
			print("maximize "+maxme+" -1 tie","lime");
			cli_execute("maximize "+maxme+" -1 tie");
		}		
		return true;
	}

	//We should sell these to avoid hassle with muscle classes.
	foreach i in $items[antique helmet, antique shield, antique greaves, antique spear, drowsy sword] {
		autosell(item_amount(i), i);
	}

	//Just a quick check for this.
	if (contains_text(maxme, "continuum transfunctioner") && my_primestat() == $stat[Muscle]) {
		cli_execute("maximize "+max_bees+" beeosity, mainstat "+(my_path() == "Way of the Surprising Fist" ? "" : " +melee -ml, "+maxme));
		return true;
	}
	if (contains_text(maxme, "knob goblin elite") && !(my_path() == "Way of the Surprising Fist")) {
		if (my_basestat($stat[Muscle]) < 15) abort("You need 15 base muscle to equip the KGE outfit.");
		if (my_basestat($stat[Moxie]) < 15) abort("You need 15 base moxie to equip the KGE outfit.");
		cli_execute("maximize "+max_bees+" beeosity, mainstat -ml, "+maxme); 
		return true;
	}
	if (maxme.contains_text("items") && have_path_familiar($familiar[Fancypants Scarecrow])) {
		maxme += " -equip spangly mariachi pants";
	}else if (maxme.contains_text("items") && have_path_familiar($familiar[Mad Hatrack])) {
		maxme += " -equip spangly mariachi pants";
	}
	//The hilarious comedy prop is basically never the good choice.
	if (i_a($item[hilarious comedy prop]) > 0 && !contains_text(maxme, "hp regen")) {
        maxme = maxme + " -equip hilarious comedy prop";
    }

	//Manual override for the nuns.
	if (contains_text(maxme, "nuns")) {
		cli_execute("maximize mainstat " + ((bcasc_AllowML) ? "" : "-10 ml") + " +outfit "+bcasc_warOutfit);
		switch (my_primestat()) {
			case $stat[Muscle] : 		cli_execute("maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, "+(my_path() == "Way of the Surprising Fist" ? " " : " +melee ")+((anHero() && !contains_text(maxme, "UV-re")) ? "+shield" : "") + ((bcasc_AllowML) ? "" : " -10 ml") + " +muscle experience " + (my_path() == "Zombie Slayer" ? "" : "+0.5 mp regen min +0.5 mp regen max, .5 hp, ")+maxme); break;
			case $stat[Mysticality] : 	cli_execute("maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, "+" +10spell damage +mysticality experience +init +5 mp regen min +5 mp regen max, .5 hp, " + ((bcasc_AllowML) ? "" : "-10 ml, ")+maxme); break;
			case $stat[Moxie] : 		cli_execute("maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, "+(my_path() == "Way of the Surprising Fist" ? " " : " -melee ") + ((bcasc_AllowML) ? "" : "-10 ml") + " +moxie experience +0.5 mp regen min +0.5 mp regen max, .5 hp, "+maxme); break;
		}
		string sns = prepSNS();
		if (sns != "") {
			equip(to_item(sns.replace_string("+equip ", "")));
		}
		return true;
	}
	
	//Basically, we ALWAYS want and -ml, for ALL classes. Otherwise we let an override happen. 
	string max_str;
	switch (my_primestat()) {
		case $stat[Muscle] :            max_str="maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, "+(my_path() == "Way of the Surprising Fist" ? " " : " +melee ")+((anHero()) ? "+shield" : "") + ((bcasc_AllowML) ? "" : " -10 ml") + " +muscle experience " + (my_path() == "Zombie Slayer" ? "" : "+0.5 mp regen min +0.5 mp regen max 5 hp, ")+maxme; break;
		case $stat[Mysticality] : 	max_str="maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, "+" +10spell damage +mysticality experience +5 mp regen min +5 mp regen max +init 5 hp, " + ((bcasc_AllowML) ? "" : "-10 ml")+maxme; break;
		case $stat[Moxie] :             max_str="maximize "+max_bees+" beeosity, mainstat "+maxMainstat+" max, "+(my_path() == "Way of the Surprising Fist" ? " " : " -melee 5 hp, ") + ((bcasc_AllowML) ? "" : "-10 ml") + " +moxie experience +0.5 mp regen min +0.5 mp regen max "+maxme; break;
	}
	
	print("max string="+max_str,"lime");
	cli_execute(max_str);
	return true;
}
boolean buMax(string maxme)
{
	boolean out= buMax(maxme, 999999999);
	//SIMON added to prevent messing with bjorn
	if(equipped_amount($item[buddy bjorn])>0 && my_bjorned_familiar( )!=$familiar[el vibrato megadrone])
		cli_execute("bjornify El Vibrato Megadrone");
	return out;
}
boolean buMax() { return buMax(""); }

//This is just a glorified wrapper for adventure()
boolean bumMiniAdv2(int adventures, location loc, string override) {
	print("bb");
	betweenBattle();
	print("putty");
//	maybe don't change macros when doing miniadvs?
//	use_putty();
	
	//force off putty in bugbear spaceship
	if(loc==$location[Medbay] || loc==$location[Waste processing] || loc==$location[Sonar] || loc==$location[Science Lab] || loc==$location[Morgue] || loc==$location[Special Ops] || loc==$location[Engineering] || loc==$location[Navigation] || loc==$location[Galley])
		set_combat_macro(false);
	//if we are testing bang potions, disable macro
	if(override=="consultDOD")
	{
		print("clearing combat macro to test potions","lime");
		clear_combat_macro();
	}
	
	if (override != "") {
		try {
			adventure(adventures, loc, override);
			boolean success = true;
		} finally {
			return success;
		}
	} else if (my_primestat() == $stat[Mysticality] && in_hardcore()) {
		try {
			adventure(adventures, loc, "consultMyst");
			boolean success = true;
		} finally {
			return success;
		}
	} else {
		try {
			adventure(adventures, loc);
			boolean success = true;
		} finally {
			return success;
		}
	}
}

boolean bumMiniAdvNoAbort(int adventures, location loc, string override) {
	if(!bumMiniAdv2(adventures, loc, override)) {
		//abort("BCC: You aborted, so so am I. This abort may have been caused by a rogue condition not being met. If this is unexpected, please paste the CLI output, as well as the results of typing 'condition check' without the quotes, into the mafia CLI window now.");
	}
	return true;
}
boolean bumMiniAdvNoAbort(int adventures, location loc) { return bumMiniAdvNoAbort(adventures, loc, ""); }

boolean bumMiniAdv(int adventures, location loc, string override) {
	if(!bumMiniAdv2(adventures, loc, override)) {
		abort("BCC: You aborted, so so am I. This abort may have been caused by a rogue condition not being met. If this is unexpected, please paste the CLI output, as well as the results of typing 'condition check' without the quotes, into the mafia CLI window now.");
	}
	return true;
}
boolean bumMiniAdv(int adventures, location loc) { return bumMiniAdv(adventures, loc, ""); }

string bumRunCombat(string consult) {
	//If we're not in a combat, we don't need to run this
	if (!contains_text(visit_url("fight.php"), "Combat")) {
		print("BCC: You aren't in a combat (or something to do with Ed which I can't work out), so bumRunCombat() doesn't need to do anything.", "purple");
		return to_string(run_combat());
	}
	
	print("Calling bumruncombat with consult "+consult,"purple");
	
	if (consult != "") {
		print("BCC: This isn't actually adventuring at noob cave. Don't worry! (Consult Script = "+consult+")", "purple");
		adv1($location[noob cave], -1, consult);
	}
	else if (my_primestat() == $stat[Mysticality] && in_hardcore()) {
		print("BCC: This isn't actually adventuring at noob cave. Don't worry! (Myst)", "purple");
		adv1($location[noob cave], -1, "consultMyst");
	}
	//SIMON COMMENTED
/*	else if (can_interact()) {
		print("BCC: This isn't actually adventuring at noob cave. Don't worry. (Can_Interact() == True)", "purple");
		adv1($location[noob cave], -1, "consultCasual");
	}*/
//	if(monster_level_adjustment()>=150)
//		abort("ML is so high, stunners don't work and we will probably get beaten up. Not running macro.");
	print("BCC: Run_Combat() being used normally.", "purple");
	string str;
	switch(my_name())
	{
		case "twistedmage":
			//noputty
			if(monster_level_adjustment() > 151)
			{
				str = to_string(visit_url("fight.php?action=macro&macrotext=&whichmacro=126414&macro=Execute+Macro"));
			}
			else if(monster_level_adjustment() > 75)
			{
				str = to_string(visit_url("fight.php?action=macro&macrotext=&whichmacro=126412&macro=Execute+Macro"));
			}
			else
			{
				str = to_string(visit_url("fight.php?action=macro&macrotext=&whichmacro=106734&macro=Execute+Macro"));
			}
		break;
		case "anid":
			str = to_string(visit_url("fight.php?action=macro&macrotext=&whichmacro=107718&macro=Execute+Macro"));
		break;
		case "dinala":
			str = to_string(visit_url("fight.php?action=macro&macrotext=&whichmacro=107605&macro=Execute+Macro"));
		break;
		case "asica":
			str = to_string(visit_url("fight.php?action=macro&macrotext=&whichmacro=107719&macro=Execute+Macro"));
		break;
		default:
			abort("unrecognised player "+my_name());
	}
	if(contains_text(str,"Macro Aborted")) abort("Seems like macro failed :"+str);
	return str;
}
string bumRunCombat() { return bumRunCombat(""); }

boolean canMCD() {
	if (knoll_available() && item_amount($item[detuned radio]) == 0 && my_meat() < 300) return false;
	return ((knoll_available() || canadia_available()) || (gnomads_available() && (item_amount($item[bitchin' meatcar]) + item_amount($item[bus pass]) + item_amount($item[pumpkin carriage])) > 0));
}

boolean canZap() {
	int wandnum = 0;
	if (item_amount($item[dead mimic]) > 0) use(1, $item[dead mimic]);
	for wand from  1268 to 1272 {
		if (item_amount(to_item(wand)) > 0) {
			wandnum = wand;
		}
	}
	if (wandnum == 0) { return false; }
	return (!(contains_text(visit_url("wand.php?whichwand="+wandnum), "feels warm") || contains_text(visit_url("wand.php?whichwand="+wandnum), "careful")));
}

//Returns true if we've completed this stage of the script. 
boolean checkStage(string what, boolean setAsWell) {
	if (setAsWell) {
		print("BCC: We have completed the stage ["+what+"] and need to set it as so.", "navy");
		set_property("bcasc_stage_"+what, my_ascensions());
	}
	if (get_property("bcasc_stage_"+what) == my_ascensions()) {
		print("BCC: We have completed the stage ["+what+"].", "navy");
		return true;
	}
	print("BCC: We have not completed the stage ["+what+"].", "navy");
	return false;
}
boolean checkStage(string what) { return checkStage(what, false); }

int cloversAvailable(boolean makeOneTenLeafClover) {
	if (bcasc_cloverless) {
		if (item_amount($item[ten-leaf clover]) > 0 && my_path() != "Bees Hate You")
			use(item_amount($item[ten-leaf clover]), $item[ten-leaf clover]);
		else if(item_amount($item[ten-leaf clover]) > 0)
			put_closet(item_amount($item[ten-leaf clover]), $item[ten-leaf clover]);
		print("BCC: You have the option for a cloverless ascention turned on, so we won't be using them.", "purple");
print("a","lime");
		return 0;
	}
	
	if (get_property("bcasc_lastHermitCloverGet") != today_to_string()) {
		print("BCC: Getting Clovers", "purple");
		if (my_path() != "Zombie Slayer")
			if (cli_execute("hermit * clover")) {}
		else
			if (buys_item($coinmaster[Hermit],$item[Ten-leaf clover])) {}
		set_property("bcasc_lastHermitCloverGet", today_to_string());
	} else {
		print("BCC: We've already got Clovers Today", "purple");
	}
	
	if (my_path() != "Bees Hate You") {
		if (makeOneTenLeafClover && (item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover])) > 0) {
			print("BCC: We're going to end up with one and exactly one ten leaf clover", "purple");
			if (item_amount($item[ten-leaf clover]) > 0) {
				cli_execute("use * ten-leaf clover; use 1 disassembled clover;");
			} else {
				cli_execute("use 1 disassembled clover;");
			}
		}
	} else {
		if (makeOneTenLeafClover && (item_amount($item[ten-leaf clover]) + closet_amount($item[ten-leaf clover])) > 0) {
			print("BCC: We're going to end up with one and exactly one ten leaf clover", "purple");
			if (item_amount($item[ten-leaf clover]) > 0) {
				put_closet(item_amount($item[ten-leaf clover]) - 1, $item[ten-leaf clover]);
			} else {
				take_closet(1,$item[ten-leaf clover]);
			}
		}		
	}
	
	return (my_path() == "Bees Hate You") ? item_amount($item[ten-leaf clover]) + closet_amount($item[ten-leaf clover]) : item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]);
}
int cloversAvailable() { return cloversAvailable(false); }

boolean get_smiths_item(item it)
{
	if(available_amount(it)>0)
		return true;

	//try to make it, either by summoning or just crafting
	if(available_amount(it)<1 && have_skill($skill[summon smithsness]))
	{
		if(i_a("brituminous coal")==0)
		{
			use_skill(1,$skill[summon smithsness]);
		}
		create(1,it);
	}

	//last resort to pull it
	if(available_amount(it)<1 && stash_amount(it)>0)
	{
		cli_execute("pull "+it);
	}
	
	if(available_amount(it)>0)
		return true;
	return false;
}

//Checks for saucepans and turtle totems and summons if not found and asked to
boolean have_castitems(class who, boolean get_them) {
	switch(who) {
		case $class[sauceror]:
				if (i_a("saucepan") + i_a("5-Alarm Saucepan") + i_a("17-alarm Saucepan") + i_a("Windsor Pan of the Source") + i_a("warbear oil pan") + i_a("oil pan") + i_a("saucepanic") + i_a("frying brainpan") > 0)
						return true;
				else if(get_them)
				{
					//saucepanic is better than basically anything, so prefer to grab that
			 		if(get_them && i_a("saucepanic")==0)
						if(get_smiths_item($item[saucepanic]))
							return true;
					//last restort, get a crap pan
					while (i_a("saucepan") == 0) {
						use(1, $item[chewing gum on a string]);
						if (i_a("saucepan") > 0)
							return true;
					}
				}
				return false;
		case $class[turtle tamer]:
				//if we are willing to get something, make sure we have the best possible, don't settle for something crap because we will probably burn a lot of mana
				if(get_them)
				{
					//best is to pull a mace of the tortoise (10 turns)
					if(i_a("mace of the tortoise")==0)
						cli_execute("pull mace of the tortoise");
					if(i_a("mace of the tortoise")>0)
						return true;

					//if that failed, try to get a smiths one (7 turns)
					if(get_smiths_item($item[Ouija Board, Ouija Board]))
						return true;

					//if that failed, settle for a crap totem (that's gonna be expensive)
					while (i_a("Turtle totem") == 0) {
						use(1, $item[chewing gum on a string]);
						if (i_a("Turtle totem") > 0)
							return true;
					}
				}
				//not getting new, just checking
				if (i_a("Turtle totem") + i_a("Mace of the Tortoise") + i_a("Chelonian Morningstar") + i_a("Flail of the Seven Aspects") + i_a("Ouija Board, Ouija Board") > 0)
					return true;
				return false;
		case $class[accordion thief]:

		 		//non ats only have 2 choices
		 		if(my_class()!=$class[accordion thief])
		 		{
		 			if(i_a("antique accordion")==0 && get_them)
		 			{
		 				if(my_meat()>2500)
		 				{
							if(i_a("post-holiday sale coupon")>0)use(1,$item[post-holiday sale coupon]);
							buy(1,$item[antique accordion]);
							cli_execute("autosell * toy accordion");
		 				}
		 			}
				 	if (i_a("toy accordion") + i_a("antique accordion") > 0)
						return true;
					return false;
		 		}

		 		//ats have many choices, mostly stolen
		 		if(get_them && i_a("Shakespeare's Sister's Accordion")==0)
					get_smiths_item($item[Shakespeare's Sister's Accordion]);
		 		//do we have anything?
				if (i_a("accord ion") + i_a("accordion file") + i_a("Accordion of Jordion") + i_a("accordionoid rocca") + i_a("alarm accordion") + i_a("autocalliope") + i_a("Bal-musette accordion") + i_a("baritone accordion") + i_a("beer-battered accordion") + i_a("bone bandoneon") + i_a("Cajun accordion") + i_a("ghost accordion") + i_a("guancertina") + i_a("mama's squeezebox") + i_a("non-Euclidean non-accordion") + i_a("peace accordion") + i_a("pentatonic accordion") + i_a("pygmy concertinette") + i_a("quirky accordion") + i_a("toy accordion") + i_a("antique accordion") + i_a("Shakespeare's Sister's Accordion") + i_a("Rock and Roll Legend") + i_a("Skipper's accordion") + i_a("Squeezebox of the Ages") + i_a("Stolen accordion") + i_a("The Trickster's Trikitixa") + i_a("Warbear exhaust manifold") + i_a("Zombie accordion") > 0)
						 return true;
				 return false;
		default:
			abort("Unrecognised class equipment requested: "+who);
	}
	return false;
}


//Do we have enough elemntal resistance available?
boolean get_res(element ele, int target, boolean do_stuff) {
	float sum;
	string[int] perform;
	int j;
	foreach i, rec in maximize(to_string(ele) + " resistance" + (bcasc_100familiar == "" ? ", switch exotic parrot" : ""), 0, (can_interact() ? 1 : 0), true, true) {
		if(rec.score > 0) {
			perform[j] = rec.command;
			sum = sum + rec.score;
			j += 1;
		}
	}

	if(sum + elemental_resistance(ele) / 10 >= target) {
		if(do_stuff) {
			for j from 0 to count(perform) - 1 {
				cli_execute(perform[j]);
				if(elemental_resistance(ele) / 10 >= target)
					return true;
			}
		} else {
			return true;			
		}
	}
	return false;
}

/**************** below is simons commented out version (from old bcc)
//Do we have enough elemntal resistance available?
boolean get_res(element ele, int target, boolean do_stuff) {
    int coldi, colds, coldo, hoti, hots, hoto, stenchi, stenchs, stencho, sleazei, sleazes, sleazeo, spookyi, spookys, spookyo;
    string clothes;
    switch(ele) {
		case $element[cold]:
	foreach doodad in $skills[] {
		if (have_skill(doodad) && numeric_modifier( doodad , "Cold Resistance" ) > 0)
			colds = colds + numeric_modifier( doodad , "Cold Resistance" );
	}
	if (colds >= target) {
		if (do_stuff) {
			if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
			if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
			if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
		}
		cli_execute("mood execute");
		return true;
	}

	maximize("Cold Resistance " + target + " max", true);
	coldi = numeric_modifier("_spec", "Cold Resistance");
	if (colds + coldi >= target) {
		if (do_stuff) {
			buMax("");
			buMax("cold resistance " + target + " max");
			if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
			if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
			if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
		}
		cli_execute("mood execute");
		return  true;
	}

	if (have_outfit("eXtreme Cold-Weather Gear")) {
		coldo = 5;
		clothes = "eXtreme Cold-Weather Gear";
	} else if (have_outfit("Hot Daub Ensemble")) {
		coldo = 3;
		clothes = "Hot Daub Ensemble";
	 } else if (have_outfit("Frigid Northlands Garb")) {
			 coldo = 3;
			 clothes = "Frigid Northlands Garb";
	} else if (have_outfit("Hot and Cold Running Ninja Suit")) {
		coldo = 2;
		clothes = "Hot and Cold Running Ninja Suit";
	}
		
	if (colds + coldo >= target) {
		if (do_stuff) {
			buMax("outfit " + clothes);
			if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
			if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
			if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
		}
		cli_execute("mood execute");
		return true;
	}
	
	if (bcasc_100familiar == "" && have_path_familiar($familiar[Exotic Parrot]) && have_skill($skill[Amphibian Sympathy])) {
		if(coldo + colds + 1 >= target && do_stuff) {
			buMax("outfit " + clothes);
			if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
			if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
			if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
			cli_execute("familiar parrot");
		} else if (coldi + colds >= 3 && do_stuff) {
			buMax("cold resistance " + target + " max");
			if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
			if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
			if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");						
			cli_execute("familiar parrot");
		}
		cli_execute("mood execute");
		return true;
	}
			break;
		case $element[hot]:
		foreach doodad in $skills[] {
				if (have_skill(doodad) && numeric_modifier( doodad , "Hot Resistance" ) > 0)
					hots = hots + numeric_modifier( doodad , "Hot Resistance" );
			}
			if (hots >= target) {
				if (do_stuff) {
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
				}
				cli_execute("mood execute");
				return true;
			}

			maximize("Hot Resistance " + target + " max", true);
			hoti = numeric_modifier("_spec", "Hot Resistance");
			if (hots + hoti >= target) {
				if (do_stuff) {
					buMax("");
					maximize("hot resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
				}
				cli_execute("mood execute");
				return true;
			}

			if (have_outfit("Hot and Cold Running Ninja Suit")) {
				hoto = 2;
				clothes = "Hot and Cold Running Ninja Suit";
			}
				
			if (hots + hoto >= target) {
				if (do_stuff) {
					buMax("outfit " + clothes);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
				}
				cli_execute("mood execute");
				return true;
			}
			
			if (bcasc_100familiar == "" && have_path_familiar($familiar[Exotic Parrot])) {
				if(hoto + hots + 1 >= target && do_stuff) {
					buMax("outfit " + clothes);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
					cli_execute("familiar parrot");
					cli_execute("mood execute");
					return true;
				} else if (hoti + hots + 1 >= target && do_stuff) {
					buMax("");
					maximize("hot resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");						
					cli_execute("familiar parrot");
					cli_execute("mood execute");
					return true;
				}
			}
			break;
		case $element[stench]:
			foreach doodad in $skills[] {
				if (have_skill(doodad) && numeric_modifier( doodad , "stench Resistance" ) > 0)
					stenchs = stenchs + numeric_modifier( doodad , "stench Resistance" );
			}
			if (stenchs >= target) {
				if (do_stuff) {
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
				}
				cli_execute("mood execute");
				return true;
			}

			maximize("stench Resistance " + target + " max", true);
			stenchi = numeric_modifier("_spec", "stench Resistance");
			if (stenchs + stenchi >= target) {
				if (do_stuff) {
					buMax("");
					maximize("stench resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
				}
				cli_execute("mood execute");
				return true;
			}

			if (have_outfit("Arboreal Raiment")) {
				stencho = 3;
				clothes = "Arboreal Raiment";
			}
				
			if (stenchs + stencho >= target) {
				if (do_stuff) {
					buMax("outfit " + clothes);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
				}
				cli_execute("mood execute");
				return true;
			}
			
			if (bcasc_100familiar == "" && have_path_familiar($familiar[Exotic Parrot]) && have_skill($skill[Amphibian Sympathy]) && have_skill($skill[Leash of Linguini]) && have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) {
				if(stencho + stenchs + 1 >= target && do_stuff) {
					buMax("outfit " + clothes);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
					if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
					if (have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy");
					cli_execute("familiar parrot");
					cli_execute("mood execute");
					return true;
				} else if (stenchi + stenchs + 1 >= target && do_stuff) {
					buMax("");
					maximize("stench resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");						
					if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
					if (have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy");					
					cli_execute("familiar parrot");
					cli_execute("mood execute");
					return true;
				}
				
			}
			break;		
		case $element[sleaze]:
			foreach doodad in $skills[] {
				if (have_skill(doodad) && numeric_modifier( doodad , "sleaze Resistance" ) > 0)
					sleazes = sleazes + numeric_modifier( doodad , "sleaze Resistance" );
			}
			if (sleazes >= target) {
				if (do_stuff) {
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");					
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
				}
				cli_execute("mood execute");
				return true;
			}

			maximize("sleaze Resistance " + target + " max", true);
			sleazei = numeric_modifier("_spec", "sleaze Resistance");
			if (sleazes + sleazei >= target) {
				if (do_stuff) {
					buMax("");
					maximize("sleaze resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
				}
				cli_execute("mood execute");
				return true;
			}

			if (bcasc_100familiar == "" && have_path_familiar($familiar[Exotic Parrot]) && have_skill($skill[Amphibian Sympathy]) && have_skill($skill[Leash of Linguini]) && have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true) && (i_a("sugar shield") + i_a("cracker")) > 0) {
				if (sleazei + sleazes + 1 >= target && do_stuff) {
					buMax("");
					maximize("sleaze resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Scarysauce]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Scarysauce, cast 1 Scarysauce");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
					if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
					if (have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy");	
					cli_execute("familiar parrot");
					cli_execute("mood execute");
					return true;
				}
			}
			break;			
		case $element[spooky]:
			foreach doodad in $skills[] {
				if (have_skill(doodad) && numeric_modifier( doodad , "spooky Resistance" ) > 0)
					spookys = spookys + numeric_modifier( doodad , "spooky Resistance" );
			}
			if (spookys >= target) {
				if (do_stuff) {
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
				}
				cli_execute("mood execute");
				return true;
			}

			maximize("spooky Resistance " + target + " max", true);
			spookyi = numeric_modifier("_spec", "spooky Resistance");
			if (spookys + spookyi >= target) {
				if (do_stuff) {
					buMax("");
					maximize("spooky resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");			
				}
				cli_execute("mood execute");
				return true;
			}

			if (bcasc_100familiar == "" && have_path_familiar($familiar[Exotic Parrot]) && ((to_int(have_skill($skill[Amphibian Sympathy])) +  to_int(have_skill($skill[Leash of Linguini])) + to_int(have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) >= 2) || (i_a("sugar shield") + i_a("cracker")) > 0)) {
				if (spookyi + spookys + 1 >= target && do_stuff) {
					buMax("");
					maximize("spooky resistance " + target + " max", false);
					if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, Elemental Saucesphere, cast 1 Elemental Saucesphere");
					if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Astral Shell, cast 1 Astral Shell");
					if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
					if (have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy");	
					cli_execute("familiar parrot");
					cli_execute("mood execute");
					return true;
				}
			}
			break;			
	}
	
	return false;
}*/

string consultJarl(int round, string opp, string text) {
	if (get_property("bcasc_doJarlAsCCS") == "true") return get_ccs_action(round);
	
	if (opp == "rampaging adding machine") {
		print("The script will not, at the moment, automatically fight rampagaing adding machines. Please fight manually.");
		return "abort";
	}	

	boolean [skill] allMySkills() {
		boolean [skill] allmyskills;
		
		foreach s in $skills[Curdle, Boil, Fry, Slice, Chop, Bake, Grill, Freeze, Blend] {
			if (have_skill(s)) { allmyskills[s] = true; }
		}
		return allmyskills;
	}
	
	//Checks if the monster we're fighting is weak against element e. Returns the multiplier for our spell.
	int isWeak(element e) {
		boolean [element] weakElements;
 
		switch (monster_element()) {
		   case $element[cold]:   weakElements = $elements[spooky, hot];    break;
		   case $element[spooky]: weakElements = $elements[hot, stench];    break;
		   case $element[hot]:    weakElements = $elements[stench, sleaze]; break;
		   case $element[stench]: weakElements = $elements[sleaze, cold];   break;
		   case $element[sleaze]: weakElements = $elements[cold, spooky];   break;
		   default: return 1;
		}
		
		if (weakElements contains e) {
			print("BCC: Weak Element to our pasta tuning.", "olive");
			return 2;
		} else if (monster_element() == e) {
			print("BCC: Strong Element to our pasta tuning.", "olive");
			return 0.01;
		} else {
			print("BCC: Neutral Element to our pasta tuning.", "olive");
			return 1;
		}
		return 1;
	}
	
	//This should return the MP used to cast the spell. Basically give it the MP and it checks the modifiers you have on.
	int mpCost(int baseMP) {
		return baseMP;
	}
	
	float wtfpwnageExpected(skill s) {
		float bAbs = numeric_modifier("Spell Damage");
		float bPer = numeric_modifier("Spell Damage Percent")/100 + 1;
		//Should multiply the bonuses below by bonus spell damage. 
		float bCol = numeric_modifier("Cold Spell Damage");
		float bHot = numeric_modifier("Hot Spell Damage");
		float bSte = numeric_modifier("Stench Spell Damage");
		float bSle = numeric_modifier("Sleaze Spell Damage");
		float bSpo = numeric_modifier("Spooky Spell Damage");
		float bElm = bCol+bHot+bSte+bSle+bSpo;
		float myst = my_buffedstat($stat[Mysticality]);
		print("BCC: These are the figures for "+to_string(s)+": Bonus: "+bAbs+" and "+bPer+"%//"+bCol+"/"+bHot+"/"+bSte+"/"+bSle+"/"+bSPo+"/El: "+bElm+"/Myst: "+myst, "purple");
		
		//Uses the above three functions to estimate the wtfpwnage from a given skill. 
		switch (s) {
			case $skill[Curdle] :
				return 0 * isWeak($element[stench]);
			case $skill[Boil] :
				return max(10 * mpCost(5), (12.5*bPer + .4*my_buffedstat($stat[mysticality]) + bAbs))*isWeak($element[hot]);
			case $skill[Fry] :
				return 0 * isWeak($element[sleaze]);
			case $skill[Slice] :
				return 0 * isWeak($element[none]);
			case $skill[Chop] :
				return max(100 * mpCost(20), (25*bPer + .5*my_buffedstat($stat[mysticality]) + bAbs));
			case $skill[Bake] :
				return 0;
			case $skill[Grill] :
				return 0;
			case $skill[Freeze] :
				return max(10 * mpCost(5), (12.5*bPer + .4*my_buffedstat($stat[mysticality]) + bAbs))*isWeak($element[cold]);
			default:
				return 0;
		}
		return -1;
	}
	
	int hp = monster_hp();
	print("BCC: Monster HP is "+hp, "purple");
	int wtfpwn;
	int mostDamage;
	skill bestSkill;
	boolean [skill] oneShot;
	boolean [skill] twoShot;
	boolean [skill] threeShot;
	boolean [skill] fourShot;
	boolean oneShotHim = true;
	string cast;
	
	foreach s in allMySkills() {
		wtfpwn = wtfpwnageExpected(s);
		
		if (wtfpwn > mostDamage) {
			bestSkill = s;
		}
		
		print("BCC: I expect "+wtfpwn+" damage from "+to_string(s), "purple");
		if (wtfpwn > hp) {
			//Then we can one-shot the monster with this skill.
			oneShot[s] = true;
		} else if (wtfpwn > hp/2) {
			twoShot[s] = true;
		} else if (wtfpwn > hp/3) {
			threeShot[s] = true;
		}else if (wtfpwn > hp/5) {
			fourShot[s] = true;
		}
	}
	
	//If we're fighting the NS, then it's best skill, ALL THE TIME.
	if (contains_text(text, "Naughty Sorceress")) {
		print("BCC: This is the Naughty Sorceress you're fighting here. SPELL ALL THE THINGS!", "purple");
		if (contains_text(text, ">Entangling Noodles (")) {
			return "skill Entangling Noodles";
		}
		return "skill "+to_string(bestSkill);
	}
	
	//Returns which skill has the lowest MP in a given range of skills. 
	skill lowestMP(boolean [skill] ss) {
		int lowestMPCostSoFar = 999999;
		skill skillToReturn = $skill[none];
		
		foreach s in ss {
			if (mp_cost(s) < lowestMPCostSoFar) {
				lowestMPCostSoFar = mp_cost(s);
				skillToReturn = s;
			}
		}
		return skillToReturn;
	}	
	
	//If we can one-shot AND noodles/twoshot isn't cheaper, do that. 
	if (count(oneShot) > 0) {
		if (have_skill($skill[Blend])) {
			if (count(twoShot) > 0) {
				int mpOneShot = mp_cost(lowestMP(oneShot));
				int mpTwoShot = mp_cost(lowestMP(twoShot));
				if (mpOneShot > 7+2*mpTwoShot) {
					print("BCC: We're actually NOT going to one-shot because Blend and then two shotting would be cheaper.", "purple");
					oneShotHim = false;
				}
			}
		}
	}
	
	if (oneShotHim && count(oneShot) > 0) {
		cast = to_string(lowestMP(oneShot));
		print("BCC: We are going to one-shot with "+cast, "purple");
		return "skill "+cast;
	} else {
		//Basically, we should cast noodles if we haven't already done this, and we're not going to one-shot the monster. 
		if (contains_text(text, ">Blend (")) {
			return "skill Blend";
		}
		if (count(twoShot) > 0) {
			cast = to_string(lowestMP(twoShot));
			print("BCC: We are going to two-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(threeShot) > 0) {
			cast = to_string(lowestMP(threeShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(fourShot) > 0) {
			cast = to_string(lowestMP(fourShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
	}
	print("Please fight the remainder of the fight yourself. You will be seeing this because you do not as Jarlsberg have a spell powerful enough to even four-shot the monster. If you wish to use a CCS or a combat script like WHAM to handle fights, set bcasc_doJarlAsCCS to true in the settings manager.", "red");
	return "abort";
}

//Has to be before the other consult functions, as they call it some of the time. 
string consultMyst(int round, string opp, string text) {
	if (my_path() == "Avatar of Jarlsberg") return consultJarl(round, opp, text);
	if (get_property("bcasc_doMystAsCCS") != "true") return get_ccs_action(round);
	
	if (opp == "rampaging adding machine") {
		print("The script will not, at the moment, automatically fight rampagaing adding machines. Please fight manually.");
		return "abort";
	}
	
	//Override for olfaction. 
	if (contains_text(get_ccs_action(round), "olfact")) {
		if (contains_text(text, ">Transcendent Olfaction (")) {
			return "skill Transcendent Olfaction";
		}
	}

	boolean [skill] allMySkills() {
		boolean [skill] allmyskills;
		
		foreach s in $skills[Spaghetti Spear, Ravioli Shurikens, Cannelloni Cannon, Stuffed Mortar Shell, Weapon of the Pastalord, Fearful Fettucini,
			Salsaball, Stream of Sauce, Saucestorm, Wave of Sauce, Saucegeyser, K&auml;seso&szlig;esturm, Surge of Icing] {
			if (have_skill(s)) { allmyskills[s] = true; }
		}
		return allmyskills;
	}
	
	//Returns the element of the cookbook we have on, if we have one. 
	element cookbook(boolean isPasta) {
		//These two work for all classes spells.
		if (equipped_amount($item[Gazpacho's Glacial Grimoire]) > 0) return $element[cold];
		if (equipped_amount($item[Codex of Capsaicin Conjuration]) > 0) return $element[hot];
		if (!isPasta) return $element[none];
		//Else the following three work for only pasta spells.
		if (equipped_amount($item[Cookbook of the Damned]) > 0) return $element[stench];
		if (equipped_amount($item[Necrotelicomnicon]) > 0) return $element[spooky];
		if (equipped_amount($item[Sinful Desires]) > 0) return $element[sleaze];
		return $element[none];
	}
	
	element elOfSpirit(effect e) {
		switch (e) {
			case $effect[Spirit of Cayenne]: return $element[hot];
			case $effect[Spirit of Peppermint]: return $element[cold];
			case $effect[Spirit of Garlic]: return $element[stench];
			case $effect[Spirit of Wormwood]: return $element[spooky];
			case $effect[Spirit of Bacon Grease]: return $element[sleaze];
		}
		return $element[none];
	}
	
	//This estimates monster HP if necessary.
	int monsterHP() {
		if (monster_hp(to_monster(opp)) > 0) {
			return monster_hp();
		}
		
		print("BCC: This script is estimating this ("+to_string(opp)+") monster's HP as "+monster_attack()+" "+monster_hp()+".", "purple");
		
		return monster_attack() - monster_hp();
	}
	
	//Checks if the monster we're fighting is weak against element e. For sauce spells, if called directly. 
	int isWeak(element e) {
		boolean [element] weakElements;
 
		switch (monster_element()) {
		   case $element[cold]:   weakElements = $elements[spooky, hot];    break;
		   case $element[spooky]: weakElements = $elements[hot, stench];    break;
		   case $element[hot]:    weakElements = $elements[stench, sleaze]; break;
		   case $element[stench]: weakElements = $elements[sleaze, cold];   break;
		   case $element[sleaze]: weakElements = $elements[cold, spooky];   break;
		   default: return 1;
		}
		
		if (weakElements contains e) {
			print("BCC: Weak Element to our pasta tuning.", "olive");
			return 2;
		} else if (monster_element() == e) {
			print("BCC: Strong Element to our pasta tuning.", "olive");
			return 0.01;
		} else {
			print("BCC: Neutral Element to our pasta tuning.", "olive");
			return 1;
		}
		return 1;
	}
	//Checks if the monster we're fighting is weak against the Flavor of Magic element. For pasta spells. 
	int isWeak() {
		foreach e in $effects[Spirit of Cayenne, Spirit of Peppermint, Spirit of Garlic, Spirit of Wormwood, Spirit of Bacon Grease] {
			if (have_effect(e) > 0) {
				print("BCC: We are under the effect of "+to_string(e), "olive");
				return isWeak(elOfSpirit(e));
			}
		}
		return 1;
	}
	//Checks if the monster is weak against whatever Sauce element would be appropriate. The actual string is ignored.
	int isWeak(string ignored) {
		return isWeak($element[none]);
	}
	
	//Returns which skill has the lowest MP in a given range of skills. 
	skill lowestMP(boolean [skill] ss) {
		int lowestMPCostSoFar = 999999;
		skill skillToReturn = $skill[none];
		
		foreach s in ss {
			if (mp_cost(s) < lowestMPCostSoFar) {
				lowestMPCostSoFar = mp_cost(s);
				skillToReturn = s;
			}
		}
		return skillToReturn;
	}
	
	float wtfpwnageExpected(skill s) {
		float bAbs = numeric_modifier("Spell Damage");
		float bPer = numeric_modifier("Spell Damage Percent")/100 + 1;
		//Should multiply the bonuses below by bonus spell damage. 
		float bCol = numeric_modifier("Cold Spell Damage");
		float bHot = numeric_modifier("Hot Spell Damage");
		float bSte = numeric_modifier("Stench Spell Damage");
		float bSle = numeric_modifier("Sleaze Spell Damage");
		float bSpo = numeric_modifier("Spooky Spell Damage");
		float bElm = bCol+bHot+bSte+bSle+bSpo;
		float myst = my_buffedstat($stat[Mysticality]);
		print("BCC: These are the figures for "+to_string(s)+": Bonus: "+bAbs+" and "+bPer+"%//"+bCol+"/"+bHot+"/"+bSte+"/"+bSle+"/"+bSPo+"/El: "+bElm+"/Myst: "+myst, "purple");
		
		//Uses the above three functions to estimate the wtfpwnage from a given skill. 
		switch (s) {
			case $skill[Spaghetti Spear] :
				return (2.5*bPer + min(5, bAbs))*isWeak();
			case $skill[Ravioli Shurikens] :
				return (5.5*bPer + 0.07*myst*bPer + min(25, bAbs) + bElm)*isWeak();
			case $skill[Cannelloni Cannon] :
				return (12*bPer + 0.15*myst*bPer + min(40, bAbs) + bElm)*isWeak();
			case $skill[Stuffed Mortar Shell] :
				return (40*bPer + 0.35*myst*bPer + min(55, bAbs) + bElm)*isWeak();
			case $skill[Weapon of the Pastalord] :
				float weak = isWeak();
				if (weak == 2) weak = 1.5;
				return (48*bPer + 0.35*myst*bPer + bAbs + bElm)*weak;
			case $skill[Fearful Fettucini] :
				return (48*bPer + 0.35*myst*bPer + bAbs + bElm)*isWeak($element[spooky]);
			case $skill[Salsaball] :
				return (2.5*bPer + min(5, bAbs))*isWeak($element[hot]);
			case $skill[Stream of Sauce] :
				return (3.5*bPer + 0.10*myst*bPer + min(10, bAbs) + bElm)*isWeak("");
			case $skill[Saucestorm] :
				return (16*bPer + 0.20*myst*bPer + min(15, bAbs) + bElm)*isWeak("");
			case $skill[Wave of Sauce] :
				return (22*bPer + 0.30*myst*bPer + min(25, bAbs) + bElm)*isWeak("");
			case $skill[Saucegeyser] :
				return (40*bPer + 0.35*myst*bPer + min(10, bAbs) + bElm)*isWeak("");
			case $skill[K&auml;seso&szlig;esturm] :
				return (16*bPer + 0.20*myst*bPer + min(15, bAbs) + bElm)*isWeak($element[stench]);
			case $skill[Surge of Icing] :
				//Sugar Rush has an effect on this skill. 
				return (16*bPer + 0.20*myst*bPer + min(15, bAbs) + bElm);
			default:
				return 0;
		}
		return -1;
	}

	int hp = monsterHP();
	print("BCC: Monster HP is "+hp, "purple");
	int isWeak = isWeak();
	int wtfpwn;
	int mostDamage;
	skill bestSkill;
	boolean [skill] oneShot;
	boolean [skill] twoShot;
	boolean [skill] threeShot;
	boolean [skill] fourShot;
	boolean oneShotHim = true;
	string cast;
	
	foreach s in allMySkills() {
		wtfpwn = wtfpwnageExpected(s);
		
		if (wtfpwn > mostDamage) {
			bestSkill = s;
		}
		
		print("BCC: I expect "+wtfpwn+" damage from "+to_string(s), "purple");
		if (wtfpwn > hp) {
			//Then we can one-shot the monster with this skill.
			oneShot[s] = true;
		} else if (wtfpwn > hp/2) {
			twoShot[s] = true;
		} else if (wtfpwn > hp/3) {
			threeShot[s] = true;
		}else if (wtfpwn > hp/5) {
			fourShot[s] = true;
		}
	}
	
	//If we're fighting the NS, then it's best skill, ALL THE TIME.
	if (contains_text(text, "Naughty Sorceress")) {
		print("BCC: This is the Naughty Sorceress you're fighting here. SPELL ALL THE THINGS!", "purple");
		if (contains_text(text, ">Entangling Noodles (")) {
			return "skill Entangling Noodles";
		}
		return "skill "+to_string(bestSkill);
	}
	
	//If we can one-shot AND noodles/twoshot isn't cheaper, do that. 
	if (count(oneShot) > 0) {
		if (have_skill($skill[Entangling Noodles])) {
			if (count(twoShot) > 0) {
				int mpOneShot = mp_cost(lowestMP(oneShot));
				int mpTwoShot = mp_cost(lowestMP(twoShot));
				if (mpOneShot > 3+2*mpTwoShot) {
					print("BCC: We're actually NOT going to one-shot because noodles and then two shotting would be cheaper.", "purple");
					oneShotHim = false;
				}
			}
		}
	}
	
	if (oneShotHim && count(oneShot) > 0) {
		cast = to_string(lowestMP(oneShot));
		print("BCC: We are going to one-shot with "+cast, "purple");
		return "skill "+cast;
	} else {
		//Basically, we should cast noodles if we haven't already done this, and we're not going to one-shot the monster. 
		if (contains_text(text, ">Entangling Noodles (")) {
			return "skill Entangling Noodles";
		}
		if (count(twoShot) > 0) {
			cast = to_string(lowestMP(twoShot));
			print("BCC: We are going to two-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(threeShot) > 0) {
			cast = to_string(lowestMP(threeShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
		if (count(fourShot) > 0) {
			cast = to_string(lowestMP(fourShot));
			print("BCC: We are going to three-shot with "+cast, "purple");
			return "skill "+cast;
		}
	}
	print("Please fight the remainder of the fight yourself. You will be seeing this because you do not have a spell powerful enough to even four-shot the monster.", "red");
	return "abort";
}

string consultBarrr(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (round == 0 || round == 1) {
		if (my_path() == "Bees Hate You") return "item Massive Manual of Marauder Mockery";
		return "item the big book of pirate insults";
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultBugbear(int round, string opp, string text) {
	switch (my_location()) {
		case $location[Engineering]:	if (opp == "liquid metal bugbear" && i_a("drone self-destruct chip") > 0) {
											print("BCC: Using a drone self-destruct chip to kill this liquid metal bugbear.", "purple");
											return "item drone self-destruct chip";
										}
										else
											return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
		case $location[Science Lab]:	if (opp == "bugbear scientist" && i_a("quantum nanopolymer spider web") > 0) {
											print("BCC: Using a quantum nanopolymer spider web to silence the scientist.", "purple");
											return "item quantum nanopolymer spider web";
										}
										else
											return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
}		

string consultSyringePenguin(int round, string opp, string text) {
	print("called consult syringe","purple");
	if (i_a("DNA extraction syringe")>0 && opp.to_monster().phylum==$phylum[penguin])
	{
		print("Trying to use syringe","purple");
		throw_item($item[DNA extraction syringe]);
		print("Tried to use syringe","purple");
	}
	string out = bumRunCombat();
	if(contains_text(out,"Macro Aborted")) abort("Seems macro failed");
	return get_ccs_action(round);
}		

string consultSyringeFish(int round, string opp, string text) {
	print("called consult syringe","purple");
	if (i_a("DNA extraction syringe")>0 && opp.to_monster().phylum==$phylum[fish])
	{
		print("Trying to use syringe","purple");
		throw_item($item[DNA extraction syringe]);
		print("Tried to use syringe","purple");
	}
	string out = bumRunCombat();
	if(contains_text(out,"Macro Aborted")) abort("Seems macro failed");
	return get_ccs_action(round);
}

string consultSyringeConstellation(int round, string opp, string text) {
	print("called consult syringe","purple");
	if (i_a("DNA extraction syringe")>0 && opp.to_monster().phylum==$phylum[constellation])
	{
		print("Trying to use syringe","purple");
		throw_item($item[DNA extraction syringe]);
		print("Tried to use syringe","purple");
	}
	string out = bumRunCombat();
	return get_ccs_action(round);
}	

string consultSyringeDude(int round, string opp, string text) {
	print("called consult syringe","purple");
	if (i_a("DNA extraction syringe")>0 && opp.to_monster().phylum==$phylum[dude])
	{
		print("Trying to use syringe","purple");
		throw_item($item[DNA extraction syringe]);
		print("Tried to use syringe","purple");
	}
	string out = bumRunCombat();
	return get_ccs_action(round);
}

string consultCasual(int round, string opp, string text) {
	print("BCC: Round: "+round+" Opp: "+opp, "purple");

	if (get_property("bcasc_doCasualAsHC") != "false") {
		print("BCC: You have selected to do casual runs like hardcore (using your CCS). Feel free to change this setting in the relay browser if you want a one-day-casual set of runaways..", "purple");
		bumRunCombat();
	} else {
		print("BCC: You do not have the option set to do casual runs as Hardcore. This means the script will attempt to use the default action specified in your bcasc_defaultCasualAction setting. The current setting is designed for a one-day casual. To make this all go away, set bcasc_doCasualAsHC to true in the relay script.", "purple");
	}
	
	boolean bookThisMonster() {
		return $strings[tetchy pirate, toothy pirate, tipsy pirate] contains opp;
	}

	boolean fightThisMonster() {
		if (opp == "cleanly pirate" && item_amount($item[rigging shampoo]) == 0) return true;
		if (opp == "creamy pirate" && item_amount($item[ball polish]) == 0) return true;
		if (opp == "curmudgeonly pirate" && item_amount($item[mizzenmast mop]) == 0) return true;
	
		return $strings[Ed the Undying, ancient protector spirit, protector spirit, gaudy pirate, modern zmobie, conjoined zmombie, gargantulihc, huge ghuol, giant skeelton, 
			dirty old lihc, swarm of ghuol whelps, big swarm of ghuol whelps, giant swarm of ghuol whelps, The Bonerdagon, The Boss Bat, booty crab,
			black panther, black adder, Dr. Awkward, Lord Spookyraven, Protector Spectre, lobsterfrogman, The Knob Goblin King] contains opp;
	}
	
	boolean olfactThisMonster() {
		if (opp == "cleanly pirate" && item_amount($item[ball polish]) == 1 && item_amount($item[mizzenmast mop]) == 1) return true;
		if (opp == "creamy pirate" && item_amount($item[mizzenmast mop]) == 1 && item_amount($item[rigging shampoo]) == 1) return true;
		if (opp == "curmudgeonly pirate" && item_amount($item[ball polish]) == 1 && item_amount($item[rigging shampoo]) == 1) return true;
		
		return $strings[dirty old lihc] contains opp;
	}
	
	boolean pickpocketThisMonster() {
		return $strings[spiny skelelton, toothy sklelton] contains opp;
	}	

	//Pickpocket a certain whitelist of monsters, else those monsters with no item drops cause issues.
	if (contains_text(text, "type=submit value=\"Pick") && pickpocketThisMonster()) {
		print("BCC: Yoink!", "purple");
		return "pickpocket";
	}
		
	//If we have RBF, we may as well use them. 
	if (item_amount($item[rock band flyers]) > 0) {
		if (contains_text(text, ">Entangling Noodles (")) {
			print("BCC: Noodle pre-flyer", "purple");
			return "skill Entangling Noodles";
		}
		print("BCC: Use Flyers", "purple");
		return "item rock band flyers";
	}
		
	//If we have JBF, we may as well use them. 
	if (item_amount($item[jam band flyers]) > 0) {
		if (contains_text(text, ">Entangling Noodles (")) {
			print("BCC: Noodle pre-flyer", "purple");
			return "skill Entangling Noodles";
		}
		print("BCC: Use Flyers", "purple");
		return "item jam band flyers";
	}
		
		
	//If we have BPI, we may as well use them. 
	if (item_amount($item[The Big Book of Pirate Insults]) > 0 && bookThisMonster() && (round == 0 || round == 1)) {
		print("BCC: Use the Big Book of Pirate Insults", "purple");
		return "item Big Book of Pirate Insults";
	}
		
	//Monsters to simply attack
	//print(opp);
	if (fightThisMonster()) {
		print("BCC: One of the few monsters we're going to attack.", "purple");
		if (round == 2) {
			print("BCC: Special Action", "purple");
			return "special action";
		}
		
		if (olfactThisMonster()) {
			if (have_effect($effect[on the trail]) == 0 && my_mp() >= 40 && contains_text(text, "Olfaction (")) {
				print("BCC: And olfact. Gotta get me some of that sweet monster smell...", "purple");
				return "skill olfaction";
			}
		}
		
		print("BCC: Attack", "purple");
		return "attack with weapon";
	}
	
	//Special Case 
	if ($strings[rampaging adding machine] contains opp) {
		if (have_skill($skill[Ambidextrous Funkslinging])) {
			if (item_amount($item[64735 scroll]) == 0) {
				if (item_amount($item[64067 scroll]) > 0 && item_amount($item[668 scroll]) > 0) {
					return "item 64067 scroll, 668 scroll";
				}
				
				if (item_amount($item[64067 scroll]) == 0) {
					return "item 30669 scroll, 33398 scroll";
				}
				
				if (item_amount($item[668 scroll]) == 0) {
					return "item 334 scroll, 334 scroll";
				}
			}
		} else {
			print("BCC: Fight this one yourself.", "purple");
			return "abort";
		}
	}
	
	get_ccs_action(round);
	if (get_property("bcasc_defaultCasualAction") != "") return get_property("bcasc_defaultCasualAction");
	
	print("BCC: Attacking is the default action for casual runs. Change bcasc_defaultCasualAction in the relay script if you want something else.", "purple");
	return "attack";
}

string consultCyrus(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (round == 1) {
		if (bcasc_doWarAs == "frat") {
			return "item rock band flyers";
		} else {
			return "item jam band flyers";
		}
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

//This consult script is just to be used to sling !potions against 
string consultDoD(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	foreach pot, eff in allBangPotions() {
		if (item_amount(pot) > 0) {
			if (eff == $effect[none]) return "item "+pot;
			print("BCC: We've identified "+pot+" already.", "purple");
		}
	}
	print("BCC: We've identified all the bang potions we have to hand.", "purple");
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultGMOB(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (contains_text(text, "Guy Made Of Bees")) {
		print("BCC: We are fighting the GMOB!", "purple");
		if (bcasc_doWarAs == "frat") {
			if(item_amount(to_item("antique hand mirror")) == 0 || !have_skill($skill[ambidextrous funkslinging]))
				return "item rock band flyers";
			else
				return "item rock band flyers,antique hand mirror";
		} else {
			if(item_amount(to_item("antique hand mirror")) == 0 || !have_skill($skill[ambidextrous funkslinging]))
				return "item jam band flyers";
			else
				return "item jam band flyers,antique hand mirror";
		}
	}
	print("BCC: We are not fighting the GMOB!", "purple");
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

item thingToGet = $item[none];
string consultHeBo(int round, string opp, string text) {
	print("in consultHeBo fighting "+opp+" round "+round,"lime");
//removed stupid check for "isexpectedmonster" since it breaks raying faxes
	//If we're under the effect "Everything Looks Yellow", then ignore everything and attack.
	if (have_effect($effect[Everything Looks Yellow]) > 0) {
		print("BCC: We would LIKE to use a Yellow Ray somewhere in this zone, but we can't because Everything Looks Yellow.", "purple");
		return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
	}
	print("Checking if monster is valid for hebo","purple");

	boolean isGateItemMonster = contains_text(text, "A.M.C. gremlin") || contains_text(text, "batwinged gremlin") || contains_text(text, "erudite gremlin")
		|| contains_text(text, "spider gremlin") || contains_text(text, "vegetable gremlin") || contains_text(text, "W imp")
		|| (thingToGet == $item[thin black candle] && contains_text(text, "Goth Giant"))
		|| (thingToGet == $item[Mick's IcyVapoHotness Rub] && contains_text(text, "Raver Giant"))
		|| (thingToGet == $item[pygmy pygment] && contains_text(text, "pygmy assault squad"))
		|| (thingToGet == $item[super-spiky hair gel] && contains_text(text, "Protagonist"))
		|| (thingToGet == $item[Tasty Fun Good rice candy] && contains_text(text, "Anime Smiley"))
		|| (thingToGet == $item[angry farmer candy] && contains_text(text, "Raver Giant"))
		|| (thingToGet == $item[adder bladder] && contains_text(text, "black adder"))
		|| (thingToGet == $item[Black No. 2] && contains_text(text, "black panther"))
		|| (thingToGet == $item[handsomeness potion] && contains_text(text, "handsome mariachi"))
		|| (thingToGet == $item[marzipan skull] && contains_text(text, "mariachi calavera"));
	boolean isMariachiMonster = contains_text(text, "grungy pirate") || contains_text(text, "scary clown") || contains_text(text, "creepy clown") || contains_text(text, "pygmy assault squad");
	boolean isTowerItemMonster =  (thingToGet == $item[baseball] && contains_text(text, "baseball bat"))
		|| ((thingToGet == $item[plot hole] || thingToGet == $item[chaos butterfly]) && contains_text(text, "Possibility Giant"))
		|| (thingToGet == $item[meat vortex] && contains_text(text, "me4t begZ0r")) 
		|| (thingToGet == $item[sonar-in-a-biscuit] && (contains_text(text, "briefcase bat") || contains_text(text, "doughbat")	|| contains_text(text, "perpendicular bat") || contains_text(text, "skullbat") || contains_text(text, "vampire bat") || contains_text(text, "baseball bat")))
		|| (thingToGet == $item[leftovers of indeterminate origin] && contains_text(text, "demonic icebox")) 
		|| (thingToGet == $item[Knob Goblin firecracker] && contains_text(text, "Sub-Assistant Knob Mad Scientist")) 
		|| (thingToGet == $item[inkwell] && contains_text(text, "writing desk"))
		|| (thingToGet == $item[mariachi G-string] && contains_text(text, "irate mariachi"))
		|| (thingToGet == $item[photoprotoneutron torpedo] && contains_text(text, "MagiMechTech MechaMech"))
		|| (thingToGet == $item[pygmy blowgun] && contains_text(text, "pygmy blowgunner"))
		|| (thingToGet == $item[fancy bath salts] && contains_text(text, "claw-foot bathtub"))
		|| (thingToGet == $item[razor-sharp can lid] && (contains_text(text, "fiendish can of asparagus") || contains_text(text, "possessed can of tomatoes")))
		|| (thingToGet == $item[frigid ninja stars] && (contains_text(text, "Ninja Snowman") && !contains_text(text, "ninja snowman assassin")))
		|| (thingToGet == $item[black pepper] && contains_text(text, "black widow"))
		|| (thingToGet == $item[lowercase N] && contains_text(text, "XXX pr0n"))
		|| (thingToGet == $item[original G] && contains_text(text, "Alphabet Giant"))
		|| (thingToGet == $item[bronzed locust] && contains_text(text, "plaque of locusts"))
		|| (thingToGet == $item[canopic jar] && contains_text(text, "tomb servant"))
		|| (thingToGet == $item[spider web] && (contains_text(text, "big creepy spider") || contains_text(text, "completely different spider")))
		|| (thingToGet == $item[disease] && contains_text(text, "disease-in-the-box"));

	//Let's check that the monster IS the correct one
	if (contains_text(text, "hippy jewelry maker") || contains_text(text, "Dwarf Foreman") || contains_text(text, "Racecar")
			|| contains_text(text, "War Hippy") || contains_text(text, "Frat Warrior") || contains_text(text, "War Pledge") || contains_text(text, "sleepy mariachi")
			|| contains_text(text, "surprised mariachi") || contains_text(text, "alert mariachi")
			|| isGateItemMonster || isMariachiMonster || isTowerItemMonster
			|| (thingToGet == $item[metallic A] && contains_text(text, "MagiMechTech MechaMech"))) {
			print("It was a valid monster","purple");
		if (my_path() == "Bees Hate You") {
			print("BCC: We are trying to use the HeBoulder, but you can't use it (nor a pumpkin bomb or a light) due to bees hating you, so I'm attacking.", "purple");
			return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
		}
		
		//list of stuns
		string[int] stunners;
		int roundnum=0;
		if(i_a("rain-doh blue balls")>0)
		{
			stunners[roundnum]="item rain-doh blue balls";
			roundnum=roundnum+1;
		}
		if(i_a("rain-doh indigo cup")>0)
		{
			stunners[roundnum]="item rain-doh indigo cup";
			roundnum=roundnum+1;
		}
		if(have_skill($skill[entangling noodles]))
		{
			stunners[roundnum]="skill entangling noodles";
			roundnum=roundnum+1;
		}
		
		if (item_amount($item[yellowcake bomb]) > 0) {
			print("BCC: We are trying to use the HeBoulder, but yellowcake bomb is better.", "purple");
			return "item yellowcake bomb";
		}
		else if (my_familiar() == $familiar[He-Boulder]) {
			print("BCC: We are using the hebo against the right monster.", "purple");
			if (contains_text(text, "yellow eye")) {
				return "skill point at your opponent";
			} else {
				//try to stun
				if(round<3)
				{
					return stunners[round];
				}
				switch (my_class()) {
					case $class[turtle tamer] : return "skill toss";
					case $class[seal clubber] : return "skill clobber";
					case $class[pastamancer] : return "skill Spaghetti Spear";
					case $class[sauceror] : return "skill salsaball";
					case $class[Disco Bandit] : return "skill suckerpunch";
					case $class[Accordion Thief] : return "skill sing";
					default: abort("unsupported class");
				}
				roundnum=roundnum+1;
			}
		} else if (my_lightning()>=5 && have_skill($skill[Ball Lightning])) {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run), so I'm using a ball lightning.", "purple");
			return "skill ball lightning";
		} else if (have_effect($effect[nanoballsy])>=40) {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run), so I'm unleashing nanites.", "purple");
			return "skill unleash nanites";
		} else if (item_amount($item[unbearable light]) > 0) {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run), so I'm using an unbearable light.", "purple");
			return "item unbearable light";
		} else if (item_amount($item[pumpkin bomb]) > 0) {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run), so I'm using a pumpkin bomb.", "purple");
			return "item pumpkin bomb";
		} else if (item_amount($item[Golden Light]) > 0) {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run), so I'm using a Golden Light.", "purple");
			return "item Golden Light";
		} else if (my_path() == "Avatar of Sneaky Pete" && have_skill($skill[flash headlight]) && get_property("peteMotorbikeHeadlight") == "Ultrabright Yellow Bulb") {
			print("BCC: We are trying to use the HeBoulder, but you are in an AoSP run, so I'm using Flash Headlight.", "purple");
			return "skill flash headlight";
		} else {
			print("BCC: We are trying to use the HeBoulder, but you don't have one (or perhaps are on a 100% run without pumpkins or clipart), so I'm attacking.", "purple");
			return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
		}
	}
	print("BCC: We are trying to use the HeBoulder, but this is not the right monster, so I'm attacking.", "purple");
	
	if (my_familiar() == $familiar[He-Boulder] && have_effect($effect[Everything Looks Red]) == 0 && contains_text(text, "red eye"))
	{
		return "skill point at your opponent";
	}
	
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultJunkyard(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	boolean isRightMonster = false;
	
	//AMC Gremlins are useless. 
	if (opp == $monster[a.m.c. gremlin]) {
		if (item_amount($item[divine champagne popper]) > 0) return "item divine champagne popper";
		return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
	} else {
		//Check to see if the monster CAN carry the item we want. This comes straight from Zarqon's SmartStasis.ash. 
		if (my_location() == to_location(get_property("currentJunkyardLocation"))) {
			print("BCC: Right location.", "purple");
			isRightMonster = (item_drops() contains to_item(get_property("currentJunkyardTool")));
		} else {
			print("BCC: Wrong location.", "purple");
			isRightMonster = (!(item_drops() contains to_item(get_property("currentJunkyardTool"))));
		}
	}
	
	if (isRightMonster) {
		print("BCC: We have found the correct monster, so will stasis until the item drop occurrs.", "purple");
		if (contains_text(text, "It whips out a hammer") || contains_text(text, "He whips out a crescent") || contains_text(text, "It whips out a pair") || contains_text(text, "It whips out a screwdriver")) {
			print("BCC: The script is trying to use the moly magnet. This may be the cause of the NULL errors here.", "purple");
			return "item molybdenum magnet";
		} else {
			if (my_hp() < 50 || round > 15) {
				//print("BCC: Let's cast bandages to heal you.", "purple");
				return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
				//For some reason, this doesn't work at all and I can't work out why. 
				return "skill lasagna bandages";
			} else {
				switch (my_class()) {
					case $class[turtle tamer] : return "skill toss";
					case $class[seal clubber] : return "skill clobber";
					case $class[Pastamancer] : return "skill Spaghetti Spear";
					case $class[Sauceror] : return "skill Salsaball";
					case $class[Disco Bandit] : return "skill suckerpunch";
					case $class[Accordion Thief] : return "skill sing";
				}
				if (i_a("seal tooth") > 0) return "item seal tooth";
				if (i_a("facsimile dictionary") > 0) return "item facsimile dictionary";
				if (i_a("spectre scepter") > 0) return "item spectre scepter";
			}
		}
	} else {
		print("BCC: This is the wrong monster.", "purple");
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultObtuse(int round, string opp, string text) {
	print("BCC: Consulting for anything we want to fire a romantic arrow at.", "purple");
	if (my_familiar() == $familiar[Obtuse Angel]) {
		print("BCC: Obtuse Angel detected.", "purple");
		if (contains_text(text, "romantic arrow (")) {
			print("BCC: Romantic Arrow Detected.", "purple");
			return "skill fire a badly romantic arrow";
		}
		return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
	}
	if (my_familiar() == $familiar[Reanimated Reanimator]) {
		print("BCC: Reanimated Reanimator detected.", "purple");
		if (contains_text(text, "wink at "+my_familiar().name)) {
			print("BCC: wink at "+my_familiar().name+" Detected.", "purple");
			return "skill wink at "+my_familiar().name;
		}
		return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
	}
	return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round)); 
}

string consultRunaway(int round, string opp, string text) {
	if (!isExpectedMonster(opp)) return ((my_primestat() == $stat[Mysticality] && in_hardcore()) ? consultMyst(round, opp, text) : get_ccs_action(round));
	if (round == 1 && have_skill($skill[Entangling Noodles])) { return "skill entangling noodles"; }
	return "try to run away";
}


void use_skeleton_buddy()
{
	if(have_effect($effect[skeletal buddy])<1 && i_a("skeleton")>0)
	{
		visit_url("inv_use.php?pwd&which=3&whichitem=5881");
		visit_url("choice.php?pwd&whichchoice=603&option=5&choiceform5=A+T-shirt+reading+%22The+Weasel%22");
	}
}

void drink_booze(item booze)
{
	if(have_effect($effect[fat leon's phat loot lyric])>0)
		cli_execute("shrug fat leons phat loot lyric");
	else if(have_effect($effect[the moxious madrigal])>0)
		cli_execute("shrug the moxious madrigal");
	if(have_skill($skill[the ode to booze]) && have_castitems($class[accordion thief], true))
		use_skill(1,$skill[the ode to booze]);
	drink(1,booze);
}

void defaultMood(boolean castMojo) {
	print("Setting default mood","purple");
	if(castMojo)
		print("Casting mojo (or other buffs)","purple");
				
	//Save time in casual runs. 
	cli_execute("mood bumcheekascend");
	cli_execute("mood clear");
	cli_execute("trigger gain_effect, just the best anapests, uneffect just the best anapests");
	if (have_skill($skill[Empathy of the Newt]))
		cli_execute("trigger lose_effect, empathy , cast 1 Empathy of the Newt");
	if (have_skill($skill[Leash of Linguini]))
		cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");

	if (my_class()==$class[accordion thief] && my_level()>=15 && have_skill($skill[Chorale of Companionship]) && my_maxmp() > mp_cost($skill[Chorale of Companionship]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Chorale of Companionship, cast 1 Chorale of Companionship");

	//stats are useful in most paths, but heavy rains has tonnes of ml, and big doesnt require levelling
	if(my_path()!="BIG!" && my_path()!="Heavy Rains")
	{
		if (have_skill($skill[Ur-Kel's Aria of Annoyance]) && have_castitems($class[accordion thief], true))
				cli_execute("trigger lose_effect, Ur-Kel's Aria of Annoyance, cast 1 Ur-Kel's Aria of Annoyance");
		if (have_skill($skill[Drescher's Annoying Noise]) && have_castitems($class[accordion thief], true))
				cli_execute("trigger lose_effect, Drescher's Annoying Noise, cast 1 Drescher's Annoying Noise");
		if (have_skill($skill[pride of the puffin]))
				cli_execute("trigger lose_effect, pride of the puffin, cast 1 pride of the puffin");
	}
	if(familiar_weight(my_familiar())<20)
		if (have_skill($skill[Curiosity of Br'er Tarrypin]) && my_path()!="Heavy Rains")
			cli_execute("trigger lose_effect, Curiosity of Br'er Tarrypin, cast 1 Curiosity of Br'er Tarrypin");

	//generic survivability
//	if (have_skill($skill[astral shell]))
//		cli_execute("trigger lose_effect, astral shell, cast 1 astral shell");
//	if (have_skill($skill[Moxie of the Mariachi]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Mariachi Mood, cast 1 Moxie of the Mariachi");
//	if (have_skill($skill[Disco Aerobics]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Disco State of Mind, cast 1 Disco Aerobics");
//	if (have_skill($skill[Blubber Up])) cli_execute("trigger lose_effect, Blubbered Up, cast 1 Blubber Up");
		
	//use fire kits for pvp fights
	if(!to_boolean(get_property("_fireStartingKitUsed")) && i_a("CSA fire starting kit")>0)
	{
		set_property("choiceAdventure595","1"); //use the sticks
		cli_execute("use csa fire starting kit");
	}
	if(i_a("CSA discount card")>0)
		use(1,$item[CSA discount card]);
	if(i_a("Handful of tips")>0)
		use(1,$item[Handful of tips]);
	
	//if we have skeletons planted and already made a skeletal skiff
	if(i_a("skeleton")>0 && i_a("skeletal skiff")>0)
	{
		//if we can't eat quiche
		if(my_path()=="Avatar of Jarlsberg" || my_path() == "zombie slayer" || !can_eat())
		{
			//if we can't drink the vodka, use them all
			if(!can_drink() || my_path()=="Avatar of Jarlsberg")
			{
				use_skeleton_buddy();
			} //use until multiple of 5, so we can get vodka
			else if(i_a("skeleton")%5!=0)
			{
				use_skeleton_buddy();
			}
		}
		else
		{	//can eat but can't drink means eat until multiple ofp 3
			if((!can_drink() || my_path()=="Avatar of Jarlsberg") && i_a("skeleton")%3!=0)
			{
				use_skeleton_buddy();
			} //can eat and can drink
			else if(i_a("skeleton")%5!=0 && i_a("skeleton")%3!=0)
			{
				use_skeleton_buddy();
			}
		}
	}
	//in kolhs drink so we can get more booze
	if(my_path()=="KOLHS" && (inebriety_limit() - my_inebriety())>=2)
	{
		if(i_a("can of the cheapest beer")>0)
			drink_booze($item[can of the cheapest beer]);
		if(i_a("bottle of fruity &quot;wine&quot;")>0)
			drink_booze($item[bottle of fruity &quot;wine&quot;]);
		if(i_a("single swig of vodka")>0)
			drink_booze($item[single swig of vodka]);
	}
	
	//summon dreadsylvania food and booze
	if(have_skill($skill[spaghetti breakfast]) && !get_property("_spaghettiBreakfast").to_boolean())
		use_skill(1,$skill[spaghetti breakfast]);
	if(have_skill($skill[grab a cold one]) && !get_property("_coldOne").to_boolean() && my_path()!="Avatar of Jarlsberg" && my_path()!="KOLHS")
		use_skill(1,$skill[grab a cold one]);
	
	//summon a knife
	if(have_skill($skill[That's not a knife]) && !get_property("_discoKnife").to_boolean())
	{		
		if(my_level()>=11 && available_amount($item[soap knife])<1) //11+
			use_skill(1,$skill[That's not a knife]);
		else if(my_level()>=8 && available_amount($item[candy knife])<1) //8-10
			use_skill(1,$skill[That's not a knife]);
		else if(my_level()>=6 && available_amount($item[sharpened spoon])<1) //6-7
			use_skill(1,$skill[That's not a knife]);
		else if(my_level()>=4 && available_amount($item[broken beer bottle])<1) //4-5
			use_skill(1,$skill[That's not a knife]);
		else if(available_amount($item[boot knife])<1) //1-3
			use_skill(1,$skill[That's not a knife]);
	}
	
	//use some stat buffs
	if(i_a("Squat-Thrust Magazine")>0 && have_effect($effect[squatting and thrusting])==0)
		use(1,$item[squat-thrust magazine]);
	if(i_a("O'RLY manual")>0 && have_effect($effect[You Read The Manual])==0)
		use(1,$item[O'RLY manual]);
	if(i_a("Ye Olde Bawdy Limerick")>0 && have_effect($effect[from nantucket])==0)
		use(1,$item[Ye Olde Bawdy Limerick]);
	if(i_a("flavored foot massage oil")>0 && have_effect($effect[feet of strawberry])==0
		&& have_effect($effect[feet of grapefruit])==0 &&  have_effect($effect[feet of watermelon])==0)
		use(1,$item[flavored foot massage oil]);
	if(i_a("white candy heart")>0 && have_effect($effect[heart of white])==0)
		use(1,$item[white candy heart]);
	if(i_a("white candy heart")>0 && have_effect($effect[heart of white])==0)
		use(1,$item[white candy heart]);
	if(i_a("Effermint&trade; tablets")>0 && have_effect($effect[winning smile])==0)
		use(1,$item[Effermint&trade; tablets]);
	if(i_a("Ogres and Oubliettes&trade; module")>0 && have_effect($effect[Ogred and Oublietted])==0)
		use(1,$item[Ogres and Oubliettes&trade; module]);
	if(i_a("Gummi turtle")>0 && have_effect($effect[Gummi-Grin])==0)
		use(1,$item[Gummi turtle]);

	//it's wimpy (unless low llevel) but might as well use it
	if(i_a("scroll of Puddingskin")>0 && have_effect($effect[Puddingskin])==0)
		use(1,$item[scroll of Puddingskin]);
		
	//random pantsgiving item buffs
	if(i_a("Gym membership card")>0)
		use(1,$item[Gym membership card]);
	if(i_a("Old candy wrapper")>0 && have_effect($effect[litterbug])==0)
		use(1,$item[Old candy wrapper]);
	if(i_a("Finger exerciser")>0 && have_effect($effect[Strong Grip])==0)
		use(1,$item[Finger exerciser]);
	if(i_a("Dented spoon")>0 && have_effect($effect[There Is A Spoon])==0)
		use(1,$item[Dented spoon]);
	if(i_a("Nail file")>0 && have_effect($effect[Extra-Sharp Weapon])==0)
		use(1,$item[Nail file]);
	if(i_a("Old love note")>0 && have_effect($effect[Memories of Puppy Love])==0)
		use(1,$item[Old love note]);
	
	
	if(i_a("orcish hand lotion")>0 && have_effect($effect[hairy palms])==0)
		use(1,$item[orcish hand lotion]);
//	if(i_a("")>0 && have_effect($effect[])==0)
//		use(1,$item[]);
//	if(i_a("")>0 && have_effect($effect[])==0)
//		use(1,$item[]);
	

	//confiscated items
	if(i_a("Confiscated cell phone")>0 && have_effect($effect[OMG WTF])==0)
		use(1,$item[Confiscated cell phone]);
	if(i_a("Confiscated comic book")>0 && have_effect($effect[Superheroic])==0)
		use(1,$item[Confiscated comic book]);
	if(i_a("Confiscated love note")>0 && have_effect($effect[Notably Lovely])==0)
		use(1,$item[Confiscated love note]);


	if(i_a("old bronzer")>0 && have_effect($effect[sepia tan])==0)
		use(1,$item[old bronzer]);
	if(i_a("old rosewater cream")>0 && have_effect($effect[rosewater mark])==0)
		use(1,$item[old rosewater cream]);
	if(i_a("old eyebrow pencil")>0 && have_effect($effect[Browbeaten])==0)
		use(1,$item[old eyebrow pencil]);

	//wizards buffs if we are in softcore because we wont be eating the food/drink
	if(can_interact() && i_a("Ye Wizard's Shack snack voucher")>0)
	{
		if(my_primestat()==$stat[muscle])
			use(1,$item[wasabi marble soda]);
		else if(my_primestat()==$stat[mysticality])
			use(1,$item[tobiko marble soda]);
		else
			use(1,$item[natto marble soda]);
	}

	//galloping grill
	if(i_a("liquid smoke")>0 && have_effect($effect[liquidy smoky])==0)
		use(1,$item[liquid smoke]);
	if(i_a("bowl of marinade")>0 && have_effect($effect[marinated])==0)
		use(1,$item[bowl of marinade]);
	if(i_a("Dollop of barbecue sauce")>0 && have_effect($effect[Barbecue Saucy])==0)
		use(1,$item[Dollop of barbecue sauce]);
	if((i_a("ashen soda")>0 || (i_a("hot ashes")>0 && (i_a("soda water")>0 || my_meat()>=70))) && have_effect($effect[ashen burps])==0)
		use(1,$item[ash soda]);
	if(i_a("Bottle of lighter fluid")>0 && have_effect($effect[lit up])==0)
		use(1,$item[Bottle of lighter fluid]);

	if(i_a("mocking turtle")>0 && have_effect($effect[Tortious])==0)
		use(1,$item[mocking turtle]);
	if(i_a("cigar box turtle")>0 && have_effect($effect[Colorful Gratitude])==0)
		use(1,$item[cigar box turtle]);
	if(i_a("irradiated turtle")>0 && have_effect($effect[Turtle Power])==0)
		use(1,$item[irradiated turtle]);

	//have to be a bit conservative in wosf
	if(my_path() == "Way of the Surprising Fist") {
		if (my_level() < 7 && castMojo && have_skill($skill[The Magical Mojomuscular Melody]) && my_path() != "BIG!") cli_execute("trigger lose_effect, The Magical Mojomuscular Melody, cast 1 The Magical Mojomuscular Melody");
		if (have_skill($skill[Miyagi Massage])) cli_execute("trigger lose_effect, Retrograde Relaxation, cast 1 Miyagi Massage");
		if (have_skill($skill[Salamander Kata])) cli_execute("trigger lose_effect, Salamanderenity, cast 1 Salamander Kata");
		if (have_skill($skill[worldpunch])) cli_execute("trigger lose_effect, Earthen Fist, cast 1 Worldpunch");
	}	
	else {

		//these are prettyt pointless, only use them when we have too much mana to use
		if((equipped_amount($item[crown of thrones])>0 || equipped_amount($item[buddy bjorn])>0) && cli_execute("ash import zlib; be_good($familiar[el vibrato megadrone])"))
		{
			//bit of init is helpful
			if (have_skill($skill[Springy Fusilli]) && my_maxmp() > mp_cost($skill[Springy Fusilli]) * 2) cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
			if (have_skill($skill[Walberg's Dim Bulb]) && my_maxmp() > mp_cost($skill[Walberg's Dim Bulb]) * 2) cli_execute("trigger lose_effect, Walberg's Dim Bulb, cast 1 Walberg's Dim Bulb");
			
			if(can_interact())
			{
				if (have_skill($skill[antibiotic saucesphere]) && have_castitems($class[sauceror], true))
					cli_execute("trigger lose_effect, antibiotic saucesphere, cast 1 antibiotic saucesphere");
				if (have_skill($skill[ghostly shell]) && have_castitems($class[turtle tamer], true))
					cli_execute("trigger lose_effect, ghostly shell, cast 1 ghostly shell");
				if (have_skill($skill[iron palm technique])) cli_execute("trigger lose_effect, iron palms, cast 1 iron palm technique");
				if (have_skill($skill[springy fusilli])) cli_execute("trigger lose_effect, springy fusilli, cast 1 springy fusilli");
				if (have_skill($skill[holiday weight gain]))
					cli_execute("trigger lose_effect, a few extra pounds, cast 1 holiday weight gain");
				if (have_skill($skill[jingle bells]) && have_castitems($class[turtle tamer], true))
					cli_execute("trigger lose_effect, jingle jangle jingle, cast 1 jingle bells");
				if (have_skill($skill[elemental saucesphere]) && have_castitems($class[sauceror], true)) cli_execute("trigger lose_effect, elemental saucesphere, cast 1 elemental saucesphere");
				if (have_skill($skill[reptilian fortitude]) && have_castitems($class[turtle tamer], true))
					cli_execute("trigger lose_effect, reptilian fortitude, cast 1 reptilian fortitude");
				if (have_skill($skill[scarysauce]) && have_castitems($class[sauceror], true))
					cli_execute("trigger lose_effect, scarysauce, cast 1 scarysauce");
				//these are guaranteed for myst, but others can use them to spend mana
				if (have_skill($skill[Jalape&ntilde;o Saucesphere]) && have_castitems($class[sauceror], true))
					cli_execute("trigger lose_effect, jalape&ntilde;o saucesphere, cast 1 jalape&ntilde;o saucesphere");
			}
		}
		switch (my_primestat()) {
			case $stat[Muscle] :
				if (my_level() > 5 && my_path() != "Bees Hate You" && my_path() != "BIG!") { cli_execute("trigger lose_effect, Tiger!, use 5 Ben-Gal Balm"); }
				if (my_level() < 7 && castMojo && have_skill($skill[The Magical Mojomuscular Melody]) && my_path() != "BIG!" && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Magical Mojomuscular Melody, cast 1 The Magical Mojomuscular Melody");
				if (anHero()) {
		//			if (have_skill($skill[The Power Ballad of the Arrowsmith]) && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Power Ballad of the Arrowsmith, cast 1 The Power Ballad of the Arrowsmith");
				} else {
					if (castMojo && have_skill($skill[The Moxious Madrigal]) && my_path() != "BIG!" && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Moxious Madrigal, cast 1 The Moxious Madrigal");
				}
				if (have_skill($skill[Patience of the Tortoise]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Patience of the Tortoise, cast 1 Patience of the Tortoise");
				if (have_skill($skill[Seal Clubbing Frenzy]) && my_path() != "BIG!") cli_execute("trigger lose_effect, Seal Clubbing Frenzy, cast 1 Seal Clubbing Frenzy");
				if (my_level() > 9 && have_skill($skill[Rage of the Reindeer])) cli_execute("trigger lose_effect, Rage of the Reindeer, cast 1 Rage of the Reindeer");
				if (have_skill($skill[tenacity of the snapper]) && have_castitems($class[turtle tamer], true))
					cli_execute("trigger lose_effect, tenacity of the snapper, cast 1 tenacity of the snapper");
				if (have_skill($skill[spiky shell]) && have_castitems($class[turtle tamer], true))
					cli_execute("trigger lose_effect, spiky shell, cast 1 spiky shell");
				if (have_skill($skill[Grease Up])) cli_execute("trigger lose_effect, Takin' It Greasy, cast 1 Grease Up");
			break;
			
			case $stat[Mysticality] :
				if (my_path() == "Avatar of Jarlsberg") {
					if (my_level() > 5 && my_meat() > 2000 && my_path() != "BIG!") { cli_execute("trigger lose_effect, Butt-Rock Hair, use 5 hair spray"); }
					if (my_level() > 5 && my_meat() > 2000) { cli_execute("trigger lose_effect, Glittering Eyelashes, use 5 glittery mascara"); }
				} else {
					if (my_level() > 5 && my_meat() > 2000) { cli_execute("trigger lose_effect, Butt-Rock Hair, use 5 hair spray"); }
					if (my_level() > 5 && my_meat() > 2000) { cli_execute("trigger lose_effect, Glittering Eyelashes, use 5 glittery mascara"); }
					if ((my_level() < 7 && castMojo && have_skill($skill[The Moxious Madrigal]) && have_castitems($class[accordion thief], true)) && my_path() != "BIG!") cli_execute("trigger lose_effect, The Moxious Madrigal, cast 1 The Moxious Madrigal");
					if (my_level() < 7  && have_skill($skill[Springy Fusilli])) cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
					if (have_skill($skill[Manicotti Meditation]) && my_level() < 5) cli_execute("trigger lose_effect, Pasta Oneness, cast 1 Manicotti Meditation");
					if (have_skill($skill[Sauce Contemplation]) && my_level() < 5) cli_execute("trigger lose_effect, Saucemastery, cast 1 Sauce Contemplation");
					if ((i_a("saucepan") + i_a("5-alarm saucepan") + i_a("17-alarm saucepan") > 0) && have_skill($skill[Jalape&ntilde;o Saucesphere]) && my_class() == $class[sauceror]) cli_execute("trigger lose_effect, Jalape&ntilde;o Saucesphere, cast 1 Jalape&ntilde;o Saucesphere");
					if (have_skill($skill[Springy Fusilli]) && my_class() == $class[Pastamancer]) cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
					if (have_skill($skill[spiky shell]) && have_castitems($class[turtle tamer], true))
						cli_execute("trigger lose_effect, spiky shell, cast 1 spiky shell");
					if (have_skill($skill[Sauce Monocle]))
						cli_execute("trigger lose_effect, Sauce Monocle, cast 1 Sauce Monocle");
					if (have_skill($skill[Blood Sugar Sauce Magic]))
						cli_execute("trigger lose_effect, Blood Sugar Sauce Magic, cast 1 Blood Sugar Sauce Magic");
						
				}
			break;
			
			case $stat[Moxie] :
				if (castMojo && have_skill($skill[The Moxious Madrigal]) && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Moxious Madrigal, cast 1 The Moxious Madrigal");
				if (my_level() < 7 && castMojo && have_skill($skill[The Magical Mojomuscular Melody]) && my_path() != "BIG!" && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Magical Mojomuscular Melody, cast 1 The Magical Mojomuscular Melody");
				if (my_level() > 5) { cli_execute("trigger lose_effect, Butt-Rock Hair, use 5 hair spray"); }
				if (have_skill($skill[tenacity of the snapper]))
					cli_execute("trigger lose_effect, tenacity of the snapper, cast 1 tenacity of the snapper");
				if (have_skill($skill[Grease Up])) cli_execute("trigger lose_effect, Takin' It Greasy, cast 1 Grease Up");

				if (my_class()==$class[accordion thief] && my_level()>=15 && have_skill($skill[Benetton's Medley of Diversity]) && my_maxmp() > mp_cost($skill[Benetton's Medley of Diversity]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Benetton's Medley of Diversity, cast 1 Benetton's Medley of Diversity");
				
				if (my_class()==$class[accordion thief] && my_level()>=15 && have_skill($skill[Prelude of Precision]) && my_maxmp() > mp_cost($skill[Prelude of Precision]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Prelude of Precision, cast 1 Prelude of Precision");
			break;
		}
		
	}
	print("finished default mood","purple");
}
void defaultMood() { defaultMood(true); }

//Thanks, picklish!
boolean faxMeA(monster mon) {
	// Time to wait for FaxBot in seconds.
    int wait_time = 60;
    // Number of tries to repeat before failing.
    int faxbot_tries = 1;

    // Return the text to search for in the photocopied monster item
    // description to verify that this fax has the right monster. Most of the
    // time this is just to_string(monster), but there are special cases due to
    // KoLmafia's naming scheme.
    string photocopy_text(monster mon) {
        switch (mon) {
            case $monster[Knight (snake)]: return "knight";
            case $monster[Somebody Else's Butt]: return "butt";
            case $monster[Slime1]: return "slime";
            case $monster[Slime2]: return "slime";
            case $monster[Slime3]: return "slime";
            case $monster[Slime4]: return "slime";
            case $monster[Slime5]: return "slime";
            case $monster[Bad ASCII Art]: return "bad ASCII art";
        }

        return mon;
    }

    // Return true if you have a fax and it contains this monster.
    boolean check_fax(monster mon) {
        if (item_amount($item[photocopied monster]) == 0)
            return false;

        string fax = visit_url("desc_item.php?whichitem=835898159");
        if (!contains_text(fax, "This is a sheet of copier paper"))
            return false;
        if (contains_text(fax, "grainy, blurry likeness of a monster on it."))
            return false;

		matcher mon_match = create_matcher("blurry likeness of an? (.*) on it",fax);
		find(mon_match);
		if(group(mon_match,1)==mon)
			return true;
		return false;
    }

    // Returns true if we were able to get a fax into the inventory.
    boolean get_fax() {
        if (item_amount($item[photocopied monster]) != 0)
            return true;
        cli_execute("fax get");
        return item_amount($item[photocopied monster]) != 0;
    }

    // Returns true if we were able to remove all faxes from the inventory.
    boolean put_fax() {
        if (item_amount($item[photocopied monster]) == 0)
            return true;
        cli_execute("fax put");
        return item_amount($item[photocopied monster]) == 0;
    }

    // Return the request string that FaxBot expects for a given monster.
    // See: http://kolspading.com/forums/viewtopic.php?f=13&t=169
    string faxbot_name(monster mon) {
        switch (mon) {
            case $monster[Blooper]: return "blooper";
            case $monster[Knob Goblin Elite Guard Captain]: return "kge";
            case $monster[Lobsterfrogman]: return "lobsterfrogman";
            case $monster[Rampaging Adding Machine]: return "adding_machine";
            case $monster[Sleepy Mariachi]: return "sleepy_mariachi";
            case $monster[Bad ASCII Art]: return "ascii";
            case $monster[7-Foot Dwarf]: return "miner";
            case $monster[Alphabet Giant]: return "alphabet";
            case $monster[Angels of Avalon]: return "avalon";
            case $monster[Astronomer]: return "astronomer";
            case $monster[Batwinged Gremlin]: return "batwinged";
            case $monster[Blur]: return "blur";
            case $monster[Bob Racecar]: return "bob";
            case $monster[Booze Giant]: return "booze";
            case $monster[Brainsweeper]: return "brainsweeper";
            case $monster[Cleanly Pirate]: return "cleanly";
            case $monster[Creamy Pirate]: return "creamy";
            case $monster[Curmudgeonly Pirate]: return "curmudgeonly";
            case $monster[Dairy Goat]: return "dairy_goat";
            case $monster[Dirty Thieving Brigand]: return "brigand";
            case $monster[Erudite Gremlin]: return "erudite";
            case $monster[Furry Giant]: return "furry";
            case $monster[Gang of Hobo Muggers]: return "muggers";
            case $monster[Gaudy Pirate]: return "gaudy";
            case $monster[Ghost]: return "ghost";
            case $monster[Gnollish Crossdresser]: return "crossdresser";
            case $monster[Gnollish Gearhead]: return "gearhead";
            case $monster[Gnollish Tirejuggler]: return "tirejuggler";
            case $monster[Goth Giant]: return "goth";
            case $monster[Knob Goblin Harem Girl]: return "Cobb's Knob Harem_girl";
            case $monster[Hellion]: return "hellion";
            case $monster[Remains of a Jilted Mistress]: return "jilted";
            case $monster[Knight (snake)]: return "knight";
            case $monster[Lemon-in-the-Box]: return "lemonbox";
            case $monster[Ninja Snowman Janitor]: return "janitor";
            case $monster[Peeved Roommate]: return "hipster";
            case $monster[Quantum Mechanic]: return "mechanic";
            case $monster[Quiet Healer]: return "healer";
            case $monster[Raver Giant]: return "raver";
            case $monster[Screambat]: return "screambat";
            case $monster[Shaky Clown]: return "shaky";
            case $monster[Skeletal Sommelier]: return "wine";
            case $monster[Skinflute]: return "skinflute";
            case $monster[Spider Gremlin]: return "spider_gremlin";
            case $monster[Swarm of Scarab Beatles]: return "beatles";
            case $monster[Tomb Rat]: return "tomb_rat";
            case $monster[Unemployed Knob Goblin]: return "beer_lens";
            case $monster[Vegetable Gremlin]: return "vegetable";
            case $monster[War Hippy Elite Fire Spinner]: return "fire_spinner";
            case $monster[White Lion]: return "white_lion";
            case $monster[Whitesnake]: return "white_snake";
            case $monster[Zombie Waltzers]: return "waltzers";
            case $monster[Baseball Bat]: return "baseball";
            case $monster[Big Creepy Spider]: return "spider";
            case $monster[Black Widow]: return "black_widow";
            case $monster[Plaque of Locusts]: return "locust";
            case $monster[Claw-foot Bathtub]: return "bathtub";
            case $monster[Demonic Icebox]: return "icebox";
            case $monster[Grungy Pirate]: return "grungy";
            case $monster[Handsome Mariachi]: return "handsomeness";
            case $monster[Irate Mariachi]: return "irate";
            case $monster[MagiMechTech MechaMech]: return "mech";
            case $monster[Mariachi Calavera]: return "calavera";
            case $monster[Pygmy Assault Squad]: return "pygmy_assault";
            case $monster[Sub-Assistant Knob Mad Scientist]: return "firecracker";
            case $monster[Tomb Servant]: return "tomb_servant";
            case $monster[Writing Desk]: return "writing_desk";
            case $monster[XXX pr0n]: return "pron";
            case $monster[W Imp]: return "wimp";
            case $monster[Reanimated Baboon Skeleton]: return "reanim_baboon";
            case $monster[Reanimated Bat Skeleton]: return "reanim_bat";
            case $monster[Reanimated Demon Skeleton]: return "reanim_demon";
            case $monster[Reanimated Giant Spider Skeleton]: return "reanim_spider";
            case $monster[Reanimated Serpent Skeleton]: return "reanim_serpent";
            case $monster[Reanimated Wyrm Skeleton]: return "reanim_wyrm";
            case $monster[Clod Hopper]: return "clodhopper";
            case $monster[Rockfish]: return "rockfish";
            case $monster[Toilet-Papered Tree]: return "tp_tree";
            case $monster[C. H. U. M. Chieftain]: return "chieftain";
            case $monster[Scary Pirate]: return "cursed";
            case $monster[Hustled Spectre]: return "hustled_spectre";
            case $monster[Neptune Flytrap]: return "neptune_flytrap";
            case $monster[Slime1]: return "slime";
            case $monster[Slime2]: return "slime";
            case $monster[Slime3]: return "slime";
            case $monster[Slime4]: return "slime";
            case $monster[Slime5]: return "slime";
            case $monster[Unholy Diver]: return "unholy_diver";
            case $monster[Large Kobold]: return "kobold";
            case $monster[Smarmy Pirate]: return "smarmy";
            case $monster[Spam Witch]: return "spam_witch";
            case $monster[Triffid]: return "triffid";
            case $monster[Bolt-Cuttin' Elf]: return "bolt_elf ";
            case $monster[Cement Cobbler Penguin]: return "cement_penguin";
            case $monster[Mesmerizing Penguin]: return "mesmerizing";
            case $monster[Mob Penguin Demolitionist]: return "demolitionist";
            case $monster[Monkey Wrenchin' Elf]: return "monkey_elf ";
            case $monster[Propaganda-spewin' Elf]: return "prop_elf";
            case $monster[Hobelf]: return "hobo_elf";
            case $monster[Somebody Else's Butt]: return "bigbutt";
        }

        return "";
    }

    // Attempt to request a monster from FaxBot. Returns true if successful.
    boolean faxbot_request(monster mon) {
        string request = faxbot_name(mon);
        if (request == "")
            return false;

        if (!put_fax())
            return false;

        print("BCC:Making faxbot request for " + request + ". (Waiting for " + wait_time + " seconds.)", "purple");

        chat_private("FaxBot", request);
        wait(wait_time);

        if (!get_fax())
            return false;

        return check_fax(mon);
    }

    if (faxbot_name(mon) == "") {
        print("BCC: Unknown fax monster: " + mon, "red");
        return false;
    }

    print("BCC: Checking existing fax first. Don't panic if this is the wrong monster - we won't use the wrong monster.", "purple");
    if (!get_fax()) {
        print("BCC: Unable to get fax. Do you have a fax machine?", "red");
        return false;
    }
    if (check_fax(mon)) {
        print("BCC: You already have a " + mon + " fax.", "purple");
        return true;
    }

    for i from 1 to faxbot_tries {
        if (faxbot_request(mon)) {
            print("BCC: Successfully got a " + mon + " fax.", "purple");
            return true;
        }
    }

    print("BCC: Unable to receive fax for " + mon + " after " + faxbot_tries + " tries.", "red");
    return false;
}

//Returns true if we have the elite guard outfit. 
boolean haveElite() {
	if (get_property("lastDispensaryOpen") != my_ascensions()) return false;
	int a,b,c;
	if (i_a("Knob Goblin elite helm") > 0) { a = 1; }
	if (i_a("Knob Goblin elite polearm") > 0) { b = 1; }
	if (i_a("Knob Goblin elite pants") > 0) { c = 1; }
	return (a+b+c==3)&&(i_a("Cobb's Knob lab key")>0);
}

//identifyBangPotions will be true if we've identified them all out of {blessing, detection, acuity, strength, teleport}, false if there are still some left to identify. 
boolean identifyBangPotions() {
	//Returns the number of the 5 important potions we've found. 
	int numPotionsFound() {
		int i = 0;
		foreach pot, eff in allBangPotions() {
			switch (eff) {
				case $effect[Izchak's Blessing] :
				case $effect[Object Detection] :
				case $effect[Strange Mental Acuity] :
				case $effect[Strength of Ten Ettins] :
				case $effect[Teleportitis] :
					i = i + 1;
				break;
			}
		}
		return i;
	}
	
	//Returns true if there are some unknown potions that we should find out about by throwing them against monsters. (i.e. we HAVE them)
	boolean somePotionsUnknown() {
		foreach pot, eff in allBangPotions() {
			if (eff == $effect[none] && item_amount(pot) > 0) return true;
		}
		return false;
	}

	boolean drunkenPotionKnown() {
		foreach pot, eff in allBangPotions() {
			if (eff == $effect[antihangover]) return true;
		}
		return false;
	}
	
	boolean usedPotion = false;
	while (numPotionsFound() < 5 && somePotionsUnknown()) {
		//if we know inebriety potion, test on ourselves
		if (drunkenPotionKnown()) {
			print("Testing potions by using them","lime");
			usedPotion = false;
			foreach pot, eff in allBangPotions() {
				if (item_amount(pot) > 0) {
					if (eff == $effect[none] && !usedPotion) {
						use(1, pot);
						usedPotion = true;
					}
				}
			}
		} else { //if there is a risk of drunknenness test on mobs
			print("Testing potions by adventuring","lime");
			clear_combat_macro();
			bumMiniAdv(1, $location[The Smut Orc Logging Camp], "consultDoD");
		}
	}
	print("BCC: We have found "+numPotionsFound()+"/5 important DoD potions", "purple");
	return (numPotionsFound() >= 5);
}

// arg = "stepNx" will return N * 10 + <letters a-i transmogrified into digits 1-9>
int numerify(string arg)
{
    int max_steps = 12;
    matcher m_step = create_matcher("^step(\\d+)([a-i]?)$", arg);
    switch {
    case arg == "unstarted": return -1;
    case arg == "started": return 0;
    case arg == "finished": return max_steps * 10 + 10;
    case arg == "step0": break;
    case find(m_step): //for i from 0 to 2 print("group " + i + " = \"" + group(m_step, i) + "\"");
        string d = group(m_step, 1);
        string s = group(m_step, 2);
        // if d <= max_steps && there's no extra "0"s return maths
        if (length(d) <= (d.to_int() > max_steps ? 0 : (d.to_int() > 9 ? 2 : 1))) return d.to_int() * 10 + (s == "" ? 0 : index_of("_abcdefghi", s));
    }
    return -11;
}

boolean is_at_least(string a_string, string b_string) {
    return (numerify(a_string) >= numerify(b_string));
}

boolean is_past(string a_string, string b_string) {
    return (numerify(a_string) > numerify(b_string));
}

boolean is_not_yet(string a_string, string b_string) {
	return (numerify(a_string) < numerify(b_string));
}

boolean is_equal_to(string a_string, string b_string) {
	return (numerify(a_string) == numerify(b_string));
}

int numPirateInsults() {
	int t = 0, i = 1;
	while (i <= 8) {
		if (get_property("lastPirateInsult"+i) == "true") {
			t = t + 1;
		}
		i = i + 1;
	}
	return t;
}

int numOfWand() {
	if (item_amount($item[dead mimic]) > 0) use(1, $item[dead mimic]);
	for wandcount from  1268 to 1272 {
		if (item_amount(to_item(wandcount)) > 0) {
			return wandcount;
		}
	}
	return 0;
}

int numUniqueKeys() {
	int keyb, keyj, keys;
	if (i_a("boris's key") > 0) { keyb = 1; }
	if (i_a("jarlsberg's key") > 0) { keyj = 1; }
	if (i_a("sneaky pete's key") > 0) { keys = 1; }
	return keyb+keyj+keys;
}

//Creates cocktails and reagent pasta.
boolean omNomNom() {
	int howManyDoWeHave(string type) {
		int numberOfItems;
		
		switch (type) {
			case "acc" :
				foreach i in $items[tropical swill, pink pony, slip 'n' slide, fuzzbump, ocean motion, fruity girl swill, ducha de oro, horizontal tango, 
					roll in the hay, a little sump'm sump'm, blended frozen swill, slap and tickle, rockin' wagon, perpendicular hula, calle de miel] {
					numberOfItems += item_amount(i);
				}
			break;
			
			case "reagentpasta" :
				foreach i in $items[fettucini inconnu, gnocchetti di Nietzsche, hell ramen, spaghetti with Skullheads, spaghetti con calaveras] {
					numberOfItems += item_amount(i);
				}
			break;
			
			case "scc" :
				foreach i in $items[Neuromancer, vodka stratocaster, Mon Tiki, teqiwila slammer, Divine, Gordon Bennett, gimlet, yellow brick road, 
					mandarina colada, tangarita, Mae West, prussian cathouse] {
					numberOfItems += item_amount(i);
				}
			break;
		}
		
		return numberOfItems;
	}
	
	int needBooze() {
		return to_int((inebriety_limit() - my_inebriety())/4);
	}
	
	int needFood() {
		return to_int((fullness_limit() - my_fullness())/6);
	}
	
	if (get_property("bcasc_prepareFoodAndDrink") != "true") return false;
	//Only do this if we're rich enough or something. Might want this to not be exactly the same as willMood(), so copying rather than using the function. 
	if (!(haveElite() || my_meat() > 5000 || my_mp() > 100 || my_level() > 9)) return false;
	if (!in_hardcore()) return false;
	
	if (have_skill($skill[Pastamastery]) && have_skill($skill[Advanced Saucecrafting])) {
		print("BCC: Preparing Food (Have "+howManyDoWeHave("reagentpasta")+" Reagent Pastas)", "purple");
		
		foreach i in $items[fettucini inconnu, gnocchetti di Nietzsche, hell ramen, spaghetti with Skullheads, spaghetti con calaveras] {
			if (item_amount($item[dry noodles]) == 0) cli_execute("cast pastamastery");
			if (item_amount($item[scrumptious reagent]) == 0) cli_execute("cast advanced sauce");
			if (creatable_amount(i) > 0 && howManyDoWeHave("reagentpasta") < needFood()) {
				cli_execute("make 1 "+to_string(i));
			}
		}
	}
	
	if (have_skill($skill[Advanced Cocktailcrafting])) {
		print("BCC: Preparing Booze (Have "+howManyDoWeHave("scc")+" SCC and "+howManyDoWeHave("acc")+" ACC)", "purple");
		
		if (have_skill($skill[Superhuman Cocktailcrafting])) {
			foreach i in $items[Neuromancer, vodka stratocaster, Mon Tiki, teqiwila slammer, Divine, Gordon Bennett, gimlet, yellow brick road, 
						mandarina colada, tangarita, Mae West, prussian cathouse] {
				if (get_property("cocktailSummons") < 3 + to_int(have_skill($skill[Superhuman Cocktailcrafting]))*2) cli_execute("cast 5 cocktail");
				if (creatable_amount(i) > 0 && howManyDoWeHave("acc") + howManyDoWeHave("scc") < needBooze()) {
					cli_execute("make 1 "+to_string(i));
				}
			}
		}
			
		foreach i in $items[tropical swill, pink pony, slip 'n' slide, fuzzbump, ocean motion, fruity girl swill, ducha de oro, horizontal tango, 
					roll in the hay, a little sump'm sump'm, blended frozen swill, slap and tickle, rockin' wagon, perpendicular hula, calle de miel] {
			if (get_property("cocktailSummons") < 3 + to_int(have_skill($skill[Superhuman Cocktailcrafting]))*2) cli_execute("cast 5 cocktail");
			if (creatable_amount(i) > 0 && howManyDoWeHave("acc") + howManyDoWeHave("scc") < needBooze()) {
				cli_execute("make 1 "+to_string(i));
			}
		}
	}
	return true;
}

string runChoice(string page_text) {
	while( contains_text( page_text , "choice.php" ) ) {
		## Get choice adventure number
		int begin_choice_adv_num = ( index_of( page_text , "whichchoice value=" ) + 18 );
		int end_choice_adv_num = index_of( page_text , "><input" , begin_choice_adv_num );
		string choice_adv_num = substring( page_text , begin_choice_adv_num , end_choice_adv_num );
		
		string choice_adv_prop = "choiceAdventure" + choice_adv_num;
		string choice_num = get_property( choice_adv_prop );
		
		if( choice_num == "" ) abort( "Unsupported Choice Adventure!" );
		
		string url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
		page_text = visit_url( url );
	}
	return page_text;
}

void sellJunk() {	
	if (my_path() == "Way of the Surprising Fist") return;
	foreach i in $items[meat stack, dense meat stack, meat paste, magicalness-in-a-can, moxie weed, strongness elixir] {
		if (item_amount(i) > 0) autosell(item_amount(i), i);
	}
	foreach i in $items[Old coin purse, old leather wallet, black pension check, warm subject gift certificate, Penultimate Fantasy chest] {
		if (item_amount(i) > 0) use(item_amount(i), i);
	}
}

//Returns the safe Moxie for given location, by going through all the monsters in it.
int safeMox(location loc) {
	if (get_property("bcasc_dontTouchStuff") == "true") {
		print("BCC: Safe Moxie for "+to_string(loc)+" ignored as bcasc_dontTouchStuff is true", "purple");
		return 0;
	}
	//Softcore is deemed to be able to take care of virtually any ML. 
	//SIMON changed this, returning 0 for every zone means you want to level in the first zone on the list, i.e. somewhere crap...
	if (loc == $location[The Primordial Soup]) return 0;
	
	//Scaling monsters play havoc with this. The actual number used isn't really important as we'll only hit this after Level 11 anyway. 
	if (loc == $location[The Hidden Temple]) return 60;
	
	int ret = 0;
	
	//Find the hardest monster. 
	foreach mob, freq in appearance_rates(loc) {
		if (freq >= 0 && mob != $monster[Guy Made of Bees] && mob != $monster[Baron von Ratsworth]) ret = max(ret, monster_attack(mob));
	}
	//Note that monster_attack() takes into account ML. So just add something to account for this.
	return ret + 4;
}

//Function to tell if we can adventure at a specific location
boolean can_adv(location where) {
	// load permanently unlocked zones
	string theprop = get_property("unlockedLocations");
	if (theprop == "" || index_of(theprop,"--") < 0 || substring(theprop,0,index_of(theprop,"--")) != to_string(my_ascensions()))
		theprop = my_ascensions()+"--";
	if (contains_text(theprop,where)) return true;

	boolean primecheck(int req) {
		if (my_buffedstat(my_primestat()) < req)
			return false;
		return true;
	}
	boolean levelcheck(int req) {
		if (my_level() < req) return false;
		return true;
	}
	boolean itemcheck(item req) {
		if (available_amount(req) == 0)
			return false;
		return true;
	}
	boolean equipcheck(item req) {
		if (!can_equip(req)) return false;
		return (item_amount(req) > 0 || have_equipped(req));
	}
	boolean outfitcheck(string req) {
		if (!have_outfit(req)) return false;
		return true;
	}
	boolean perm_urlcheck(string url, string needle) {
		if (contains_text(visit_url(url),needle)) {
			set_property("unlockedLocations",theprop+" "+where);
			return true;
		}
		return false;
	}
	boolean pirate_check(string url) {
	  if (!(equipcheck($item[pirate fledges]) || outfitcheck("swashbuckling getup"))) return false;
	  return true;
	}

	// begin location checking
	if (contains_text(to_string(where),"Haunted Wine Cellar"))
		return (levelcheck(11) && itemcheck($item[your father's macguffin diary]) && perm_urlcheck("place.php?whichplace=spookyraven1","sm8b.gif"));
	switch (where) {
	// always open
	case $location[The Sleazy Back Alley]:
	case $location[The Haunted Pantry]:
	case $location[the outskirts of cobb's knob]: return true;
	// level-opened
	case $location[The Spooky Forest]: return (levelcheck(2));
	case $location[A Barroom Brawl]: return (my_path() != "Zombie Slayer" && levelcheck(3));
	case $location[8-Bit Realm]: return (primecheck(20));
	case $location[the bat hole entrance]: return (levelcheck(4) && primecheck(13));
	case $location[Guano Junction]: return (levelcheck(4) && primecheck(13) && numeric_modifier("Stench Resistance") > 0);
	case $location[The Batrat and Ratbat Burrow]:
	case $location[The Beanbat Chamber]: if (!primecheck(13)) return false;
									if (!levelcheck(4)) return false;
									string bathole = visit_url("place.php?whichplace=bathole");
									int sonarsneeded = to_int(!contains_text(bathole,"batratroom.gif")) +
										to_int(!contains_text(bathole,"batbeanroom.gif"));
									if (sonarsneeded > 0) {
										return (item_amount($item[sonar-in-a-biscuit]) >= sonarsneeded);
									}
									return (perm_urlcheck("place.php?whichplace=bathole",to_url(where)));
	case $location[Cobb's Knob Kitchens]: if (!primecheck(20)) return false;
	case $location[Cobb's Knob Barracks]:
	case $location[Cobb's Knob Treasury]:
	case $location[Cobb's Knob Harem]: if ((!levelcheck(5) || contains_text(visit_url("place.php?whichplace=plains"), "knob1.gif")) || (have_equipped($item[Knob Goblin elite helm]) && have_equipped($item[Knob Goblin elite polearm]) && have_equipped($item[Knob Goblin elite pants]))) return false; return true;
	case $location[The Enormous Greater-Than Sign]: return (primecheck(44) && contains_text(visit_url("da.php"),"Greater"));
	case $location[The Dungeons of Doom]: return (primecheck(44) && perm_urlcheck("da.php","ddoom.gif"));
	case $location[Itznotyerzitz Mine]: return (levelcheck(8) && primecheck(53));
	case $location[The Black Forest]: return (levelcheck(11) && primecheck(104));
	// key opened
	case $location[Cobb's Knob Laboratory]: return (primecheck(30) && itemcheck($item[Cobb's Knob lab key]));
	case $location[Cobb's Knob Menagerie\, Level 1]: return (primecheck(35) && itemcheck($item[Cobb's Knob Menagerie key]));
	case $location[Cobb's Knob Menagerie\, Level 2]: return (primecheck(40) && itemcheck($item[Cobb's Knob Menagerie key]));
	case $location[Cobb's Knob Menagerie\, Level 3]: return (primecheck(45) && itemcheck($item[Cobb's Knob Menagerie key]));
	case $location[Hippy Camp]: return (get_property("lastIslandUnlock").to_int() == my_ascensions() && get_property("warProgress") != "started" && get_property("sideDefeated") != "hippies" && get_property("sideDefeated") != "both" && primecheck(30));
	case $location[Frat House]: return (get_property("lastIslandUnlock").to_int() == my_ascensions() && get_property("warProgress") != "started" && get_property("sideDefeated") != "fratboys" && get_property("sideDefeated") != "both" && primecheck(30));

	case $location[The Obligatory Pirate's Cove]: return (itemcheck($item[dingy dinghy]) && !is_wearing_outfit("swashbuckling getup") && !have_equipped($item[pirate fledges]) && get_property("warProgress") != "started" && primecheck(45));
	case $location[The Castle in the Clouds in the Sky (Basement)]: return (primecheck(95) && item_amount($item[S.O.C.K.]) > 0);
	case $location[The Castle in the Clouds in the Sky (Ground Floor)]: return (primecheck(95) && item_amount($item[S.O.C.K.]) > 0);
	case $location[The Castle in the Clouds in the Sky (Top Floor)]: return (primecheck(95) && item_amount($item[S.O.C.K.]) > 0);
	case $location[The Hole in the Sky]: return (primecheck(100) && itemcheck($item[steam-powered model rocketship]));
	case $location[The Haunted Library]: return (primecheck(40) && itemcheck($item[Spookyraven library key]));
	case $location[The Haunted Gallery]: return (get_property("questM21Dance") != "unstarted");
	case $location[The Haunted Ballroom]: return (get_property("questM21Dance") == "finished");
	case $location[Inside the Palindome]: return (primecheck(65) && equipcheck($item[Talisman o' Nam]));
	case $location[Tower Ruins]: return (primecheck(18) && itemcheck($item[Fernswarthy's letter]));
	case $location[The Oasis]: return (itemcheck($item[your father's macguffin diary]) && perm_urlcheck("place.php?whichplace=desertbeach","oasis.gif"));
	case $location[The Upper Chamber]:
	case $location[The Middle Chamber]: return (itemcheck($item[staff of ed]));
	// signs
	case $location[Thugnderdome]: if (my_path() != "Zombie Slayer" && gnomads_available() && !primecheck(25)) return false;
	case $location[Outskirts of Camp Logging Camp]: return (my_path() != "Zombie Slayer" && canadia_available());
	case $location[Camp Logging Camp]: return (my_path() != "Zombie Slayer" && canadia_available() && primecheck(30));
	case $location[Post-Quest Bugbear Pens]: return (my_path() != "Zombie Slayer" && knoll_available() && primecheck(13) && contains_text(visit_url("questlog.php?which=2"),"You've helped Mayor Zapruder") && perm_urlcheck("woods.php","pen.gif"));
	case $location[the bugbear pen]: return (my_path() != "Zombie Slayer" && knoll_available() && primecheck(13) && !contains_text(visit_url("questlog.php?which=2"),"You've helped Mayor Zapruder") && perm_urlcheck("woods.php","pen.gif"));
	// misc
	case $location[The Degrassi Knoll Garage]: return (!knoll_available() && primecheck(10) && guild_store_available( ) && perm_urlcheck("place.php?whichplace=plains","knoll1.gif"));
	case $location[The \"Fun\" House]: return (guild_store_available( ) && primecheck(15) && perm_urlcheck("place.php?whichplace=plains","funhouse.gif"));
	case $location[Pre-Cyrpt Cemetary]: return (primecheck(11) && guild_store_available( ) && !visit_url("questlog.php?which=2").contains_text("defeated the Bonerdagon"));
	case $location[Post-Cyrpt Cemetary]: return (primecheck(40) && perm_urlcheck("questlog.php?which=2","defeated the Bonerdagon"));
	case $location[The Goatlet]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("mclargehuge.php","bottommiddle.gif"));
	case $location[Lair of the Ninja Snowmen]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("mclargehuge.php","leftmiddle.gif"));
	case $location[The eXtreme Slope]: return (levelcheck(8) && perm_urlcheck("mclargehuge.php","rightmiddle.gif"));
	case $location[Whitey's Grove]: return (levelcheck(7) && primecheck(34) && guild_store_available( ) && perm_urlcheck("woods.php","grove.gif"));
	case $location[The Laugh Floor]:
	case $location[Infernal Rackets Backstage]:
	case $location[Pandamonium Slums]: return (primecheck(29) && (have_skill($skill[liver of steel]) || have_skill($skill[spleen of steel]) ||
										 have_skill($skill[stomach of steel]) || perm_urlcheck("questlog.php?which=2","cleansed the taint")));
	case $location[The Valley of Rof L'm Fao]: return (levelcheck(9) && perm_urlcheck("mountains.php","valley2.gif"));
	case $location[The Penultimate Fantasy Airship]: return (levelcheck(10) && primecheck(90) && (perm_urlcheck("place.php?whichplace=plains","beanstalk.gif") || use(1,$item[enchanted bean])));
	case $location[The Road to the White Citadel]: return (!white_citadel_available() && guild_store_available( ) && visit_url("woods.php").contains_text("wcroad.gif"));
	case $location[The Haunted Kitchen]: return (primecheck(5) && (itemcheck($item[Spookyraven library key]) || perm_urlcheck("place.php?whichplace=town_right","manor.gif")));
	case $location[The Haunted Conservatory]: return (primecheck(6) && perm_urlcheck("place.php?whichplace=town_right","manor.gif"));
	case $location[The Haunted Billiards Room]: return (primecheck(10) && perm_urlcheck("place.php?whichplace=town_right","manor.gif"));
	case $location[The Haunted Bathroom]: return (primecheck(68) && get_property("questM21Dance") != "unstarted");
	case $location[The Haunted Bedroom]: return (primecheck(85) && get_property("questM21Dance") != "unstarted");
	case $location[The Icy Peak]: return (levelcheck(8) && primecheck(53) && perm_urlcheck("questlog.php?which=2","L337 Tr4pz0r") && numeric_modifier("Cold Resistance") > 0);
	//case $location[Barrrney's Barrr]: return (get_property("lastIslandUnlock").to_int() == my_ascensions() && (equipcheck($item[pirate fledges]) || outfitcheck("swashbuckling getup"))); - problematic
	case $location[The F'c'le]: return (pirate_check("cove3_3x1b.gif"));
	case $location[The Poop Deck]: return (pirate_check("cove3_3x3b.gif"));
	case $location[Belowdecks]: return (pirate_check("cove3_5x2b.gif"));
//	case $location[Hidden City (encounter)]: return (levelcheck(11) && itemcheck($item[your father's macguffin diary]) && perm_urlcheck("woods.php","hiddencity.php"));
	default: return false;
	}
}

//Changes the familiar based on a string representation of what we want. 
//SIMON CHANGED FUNCTION NAME
boolean innerSetFamiliar(string famtype) {
	item bootsSpleenThing() {
		for i from 5198 to 5219 {
			if (item_amount(to_item(i)) > 0) return to_item(i);
		}
		return $item[none];
	}

	//The very first thing is to check 100% familiars
	if(bcasc_100familiar != "" && my_path() != "Avatar of Boris" && my_path() != "Avatar of Jarlsberg" && my_path() != "Avatar of Sneaky Pete") {
		print("BCC: Your familiar is set to a 100% "+bcasc_100familiar, "purple");
		cli_execute("familiar "+bcasc_100familiar);
		return true;
	}
		
	if (my_path() == "Avatar of Boris") {	//Lute = +item, Crumhorn = +stats, Sackbut = +HP/MP
		print("setting clancys instrument");
		string charpane = visit_url("charpane.php");
		if((famtype == "items" || famtype == "itemsnc" || famtype == "equipmentnc")) {
			print("using lute");
			if(minstrel_instrument() == $item[Clancy's lute])
				return true;
			else if(i_a("Clancy's lute") > 0) {
				use(1, $item[Clancy's lute]);
				return true;
			}
		} 
		print("using crumhorn/sackbut");
		if(i_a("Clancy's crumhorn") > 0) {
			use(1, $item[Clancy's crumhorn]);
			return true;
		} else if(minstrel_instrument() == $item[Clancy's crumhorn]) {
			return true;
		} else if(i_a("Clancy's sackbut") > 0){
			use(1, $item[Clancy's sackbut]);
			return true;
		} else {
			return true;
		}
	} else if(my_path()=="Avatar of Jarlsberg" && get_property("bcasc_SwapFood") == "true")
	{
		//assume that even if we don't have fullness skills we will soon
		int drink_space_left=19- my_inebriety();
		if(!have_skill($skill[liver of steel]))
			drink_space_left-=5;
		int food_space_left=15- my_fullness();
		
		//how many ingredients does that translate to, assuming we eat ice cream (uses cream) and drink chunky marys (potato + veg) with filler drink of nachojito (no familiar foods)
		//don't need to save any eggs
		int veg_to_save=(drink_space_left/4)+1; //1 per 4 drunk (+1)
		int pot_to_save=(drink_space_left/4)+1;//1 per 4 drunk (+1)
		int cream_to_save=2*(food_space_left/7); //2 per 7 food
		
		//prefer cream puff and egg man if we need those boosts
		if(have_skill($skill[Cream Puff]) && famtype == "ml" && i_a("cosmic cream") > cream_to_save) {
			use_skill(1, $skill[Cream Puff]);
			return true;
		} else if(have_skill($skill[egg man]) && (famtype == "items" || famtype == "equipmentnc" || famtype == "itemsnc" || famtype == "obtuseangel" || famtype=="obtuseangel_simon") && i_a("cosmic egg") > 0) {
			use_skill(1, $skill[egg man]);
			return true;
		} //if we need init prefer that
		else if(have_skill($skill[Radish Horse]) && famtype == "init" && i_A("cosmic vegetable") > veg_to_save) {
			use_skill(1, $skill[Radish Horse]);
			return true;
		} //primary default fam = potato
		else if(have_skill($skill[Hippotatomous]) && i_a("cosmic potato") > pot_to_save) {
			use_skill(1, $skill[Hippotatomous]);
			return true;
		} //second default fam = init (even if we don't explicitly need it)
		else if(have_skill($skill[Radish Horse]) && i_A("cosmic vegetable") > veg_to_save) {
			use_skill(1, $skill[Radish Horse]);
			return true;
		}
		return false;
	}
	
	if (famtype == "nothing") {
		use_familiar($familiar[none]);
		return true;
	}

	if (famtype == "blackforest") {
		print("trying to use some kind of blackbird","purple");
		if (have_path_familiar($familiar[Reassembled Blackbird])) {
			use_familiar($familiar[Reassembled Blackbird]);
			return true;
		} else if (have_path_familiar($familiar[Reconstituted Crow])) {
			use_familiar($familiar[Reconstituted Crow]);
			return true;
		}
	}

	//Then a quick check for if we have Everything Looks Yellow
	if ((have_effect($effect[Everything Looks Yellow]) > 0 || (my_path() == "Bees Hate You") || my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" && my_path() != "Avatar of Sneaky Pete") && famtype == "hebo") { famtype = "items"; }
	
	//in heavy rains, most standard familiar types are better served by their aquatic counterparts
	if(my_path()=="Heavy Rains")
	{
		if(contains_text(famtype, "items") && have_familiar($familiar[Grouper Groupie]))
		{
			use_familiar($familiar[Grouper Groupie]);
			return true;
		}
		if(famtype=="meat" && have_familiar($familiar[Urchin Urchin]))
		{
			use_familiar($familiar[Urchin Urchin]);
			return true;
		}
	}
		
	//THEN a quick check for a spanglerack
	if(i_a("spangly mariachi pants") > 0 && have_path_familiar($familiar[fancypants scarecrow]) &&
	(contains_text(famtype, "items") || contains_text(famtype, "equipment")) && famtype!="itemsw") { //not underwater
		print("BCC: We are going to be using the spanglepants for items. Yay Items!", "purple");
		use_familiar($familiar[Fancypants Scarecrow]);
		if (equipped_item($slot[familiar]) != $item[spangly mariachi pants]) equip($slot[familiar], $item[spangly mariachi pants]);
		if (equipped_item($slot[familiar]) == $item[spangly mariachi pants]) return true;
		print("BCC: There seemed to be a problem and you don't have the spangly mariachi pants equipped. I'll use a 'normal' item drop familiar.", "purple");
	}else if (i_a("spangly sombrero") > 0 && have_path_familiar($familiar[Mad Hatrack]) &&
	(contains_text(famtype, "items") || contains_text(famtype, "equipment")) && famtype!="itemsw") { //not underwater
		print("BCC: We are going to be using a spanglerack for items. Yay Items!", "purple");
		use_familiar($familiar[Mad Hatrack]);
		if (equipped_item($slot[familiar]) != $item[spangly sombrero]) equip($slot[familiar], $item[spangly sombrero]);
		if (equipped_item($slot[familiar]) == $item[spangly sombrero]) return true;
		print("BCC: There seemed to be a problem and you don't have a spangly sombrero equipped. I'll use a 'normal' item drop familiar.", "purple");
	} 
	
	//then a cheerleader check
	if(have_familiar($familiar[Steam-powered cheerleader]) && get_property("_cheerleaderSteam").to_int()>0) //cheerleader is a possibility
	{
		if(famtype=="itemsnc" || (famtype=="items" && !have_familiar($familiar[jumpsuited hound dog]))) //and is suitable
		{
			use_familiar($familiar[steam-powered cheerleader]);
			return true;
		}
	}
	
	//Finally, actually start getting familiars.
	if (famtype != "") {
		string [int] famlist;
		load_current_map("bcs_fam_"+famtype, famlist);
		foreach x in famlist {
			print("Checking for familiar '"+famlist[x]+"' where x="+x, "purple");
			if (have_path_familiar(famlist[x].to_familiar())) {
				use_familiar(famlist[x].to_familiar());
				return true;
			}
		}
	}

	//organ grinder
	if((contains_text(get_property("pieStuffing"),"fish") || contains_text(get_property("pieStuffing"),"boss")) && get_property("_pieDrops").to_int() < 3)
	{
		print("finishing off a badass pie. Pie contents="+get_property("pieStuffing"),"blue");
		use_familiar($familiar[Knob Goblin Organ Grinder]);
		return true;
	}
	
	print("BCC: Switching Familiar for General Use", "aqua");
	int maxspleen = 15;
	if (have_skill($skill[Spleen of Steel])) maxspleen = 20;
	//account for filters
	maxspleen+=min(i_a("mojo filter"),3-get_property("currentMojoFilters").to_int());
	//if we are going to be able to use astral energy drink
	if(i_a("carton of astral energy drinks")>0) use(1, $item[carton of astral energy drinks]);
	int energy_drinks = i_a("astral energy drink");
	int usable_energy_drinks = min(energy_drinks,(maxspleen - my_spleen_use())/8);
	print("Have "+energy_drinks+" energy drinks. Maxspleen="+maxspleen+". Can use "+usable_energy_drinks+" energy drinks","purple");
	
	void use_filter()
	{
		//if we are full don't endlessley use them
		if(spleen_limit()==my_spleen_use())
			return;
		//use a filter if modulo 4==3 (i.e. one filter away from extra use)
		if((spleen_limit() - my_spleen_use())%4==3)
		{
			if(i_a("mojo filter")>0)
			{
				use(1,$item[mojo filter]);
				//can't use a filter with no spleen use
				if(my_spleen_use()==0) return;
			}
			else
			{
				if(!in_hardcore() && storage_amount($item[mojo filter])>0 && pulls_remaining()>0)
					abort("You may want to pull a mojo filter");
			}
		}
	}
	
	if (get_property("bcasc_doNotUseSpleen") != "true") {
		//Before we do anything, let's check if there's any spleen to do. May as well do this as we go along.
		if (my_spleen_use() <= maxspleen-4) {
			use_filter();
			print("BCC: Going to try to use some spleen items if you have them.", "purple");
		
			//first check energy drinks
			while(my_level()>=11 && i_a("astral energy drink")>0 && my_spleen_use() <= spleen_limit()-8)
			{
				use_filter();
				use(1, $item[astral energy drink]);
			}
			
			if((my_daycount()>3 && in_hardcore()) || my_daycount()>1)
				maxspleen-=usable_energy_drinks*8;
			print("spleen to fill with non-astral stuff="+maxspleen,"purple");
			
			//then check grease
			while (my_spleen_use()  <= maxspleen-4 && item_amount($item[groose grease]) > 0) {
				use_filter();
				use(1, $item[groose grease]);
				cli_execute("uneffect just the best anapests");
			}
			while (my_spleen_use()  <= maxspleen-4 && item_amount($item[unconscious collective dream jar]) > 0) {
				use(1, $item[unconscious collective dream jar]);
			}
			//now check other stuff
			if (my_level() >= 4) {
				print("BCC: Going to try to use some spleen items if you have them.", "purple");
				
				while (my_spleen_use()  <= maxspleen-4 && item_amount($item[agua de vida]) > 0) {
					use(1, $item[agua de vida]);
					use_filter();
				}
				
				while (bootsSpleenThing() != $item[none] && my_spleen_use()  <= maxspleen-4) {
					use_filter();
					use(1, bootsSpleenThing());
				}
				
				visit_url("place.php?whichplace=town_wrong");
				while (my_spleen_use()  <= maxspleen-4 && (available_amount($item[coffee pixie stick]) > 0 || item_amount($item[Game Grid token]) > 0)) {
					if (available_amount($item[coffee pixie stick]) == 0) {
						visit_url("arcade.php?action=skeeball&pwd="+my_hash());
					}
					use (1, $item[coffee pixie stick]);
					use_filter();
				}
			}
		}
		
		//If they have these, then check for spleen items that we have. 
		if (my_spleen_use() + (i_a("agua de vida") + i_a("coffee pixie stick") + i_a("Game Grid token") + i_a("Game Grid ticket")/10 + i_a("groose grease") + i_a("unconscious collective dream jar")) * 4 < maxspleen + 4) {
			print("Spleen: "+my_spleen_use()+" Agua: "+i_a("agua de vida")+" Stick: "+i_a("coffee pixie stick")+" Token: "+i_a("Game Grid token") + " Grease: " + i_a("groose grease") + " Dream Jar: " + i_a("unconscious collective dream jar"), "purple");
			print("Total Spleen: "+(my_spleen_use() + (i_a("agua de vida") + i_a("coffee pixie stick") + i_a("Game Grid token") + i_a("groose grease") + i_a("unconscious collective dream jar")) * 4), "purple");
			
			//Then we have space for some spleen items.
			if (have_path_familiar($familiar[Unconscious Collective]) && have_path_familiar($familiar[Bloovian Groose])) {
				if (to_int(get_property("_dreamJarDrops")) <= to_int(get_property("_grooseDrops"))) {
					use_familiar($familiar[Unconscious Collective]);
					return true;
				} else {
					use_familiar($familiar[Bloovian Groose]);
					return true;
				}
			} else if (have_path_familiar($familiar[Unconscious Collective])) {
				use_familiar($familiar[Unconscious Collective]);
				return true;
			} else if (have_path_familiar($familiar[Bloovian Groose])) {
				use_familiar($familiar[Bloovian Groose]);
				return true;
			} else if (have_path_familiar($familiar[Rogue Program]) && have_path_familiar($familiar[Baby Sandworm])) {
				//Then randomly pick between the two.
				if (to_int(get_property("_tokenDrops")) <= to_int(get_property("_aguaDrops"))) {
					use_familiar($familiar[Rogue Program]);
					return true;
				} else {
					use_familiar($familiar[Baby Sandworm]);
					return true;
				}
			} else if (have_path_familiar($familiar[Rogue Program])) {
				use_familiar($familiar[Rogue Program]);
				return true;
			} else if (have_path_familiar($familiar[Baby Sandworm])) {
				use_familiar($familiar[Baby Sandworm]);
				return true;
			}
		}
	}
	
	//try for crayon shavings for bugbears
	if(my_path()=="Bugbear Invasion" && to_int(get_property("_hipsterAdv"))< 7)
	{
		use_familiar(to_familiar("artistic goth kid"));
		return true;
	}		
	
	//if we still need a psycho jar
/*	if(get_property("_jungDrops")==0 && have_path_familiar($familiar[angry jung man]))
	{
		use_familiar($familiar[angry jung man]);
		return true;
	}*/
	
	//If we set a familiar as default, use it. 
	if (get_property("bcasc_defaultFamiliar") != "") {
		print("BCC: Setting the default familiar to your choice of '"+get_property("bcasc_defaultFamiliar")+"'.", "purple");
		return use_familiar(to_familiar(get_property("bcasc_defaultFamiliar")));
	}
	
	print("BCC: Using a default stat familiar.", "purple");
	//Now either we have neither of the above, or we have enough spleen today.
	//Sombrero type familiars are probably best in all zones from itznotyerzitz mine onwards (level 8 quest plus)
	//but to simplify things since we don't know the zone, lets just prefer a sombrero at all times
	//THIS ONLY APPLIES IF WE HAVE A LOT OF ML
	if(monster_level_adjustment()>=100)
	{
		if (have_path_familiar($familiar[galloping grill])) {
			use_familiar($familiar[galloping grill]);
			return true;
		}
		if (have_path_familiar($familiar[baby sandworm])) {
			use_familiar($familiar[baby sandworm]);
			return true;
		}
		if (have_path_familiar($familiar[hovering sombrero])) {
			use_familiar($familiar[hovering sombrero]);
			return true;
		}
	}
	//if we went through the above (low ml, no fams, can't use them on path) try some volleyball types
	if (have_path_familiar($familiar[Frumious Bandersnatch])) {
		use_familiar($familiar[Frumious Bandersnatch]);
		if((i_a("crimsilion jub-jub bird")+i_a("aquaviolet jub-jub bird") + i_a("charpuce jub-jub bird")) == 0 && ((have_skill($skill[summon clip art]) && tomes_left()) || i_a("box of familiar jacks")>0))
			cli_execute("use 1 box of familiar jacks");
		//now fold and equip correct bird
		item chosen_bird=$item[crimsilion jub-jub bird];
		if(my_primestat()==$stat[moxie])
			chosen_bird=$item[charpuce jub-jub bird];
		if(my_primestat()==$stat[mysticality])
			chosen_bird=$item[aquaviolet jub-jub bird];
		if(i_a(chosen_bird)<1)
			cli_execute("fold "+chosen_bird);
		equip(chosen_bird);
		return true;
	} 
	if (have_path_familiar($familiar[baby bugged bugbear])) {
		use_familiar($familiar[baby bugged bugbear]);
		return true;
	} 
	if (have_path_familiar($familiar[Li'l Xenomorph])) {
		use_familiar($familiar[Li'l Xenomorph]);
		return true;
	} 
	if (have_path_familiar($familiar[Hovering Skull])) {
		use_familiar($familiar[Hovering Skull]);
		return true;
	} 
	if (have_path_familiar($familiar[Gluttonous Green Ghost])) {
		use_familiar($familiar[Gluttonous Green Ghost]);
		return true;
	} 
	if (have_path_familiar($familiar[Smiling Rat])) {
		use_familiar($familiar[Smiling Rat]);
		return true;
	} 
	if (have_path_familiar($familiar[Blood-Faced Volleyball])) {
		use_familiar($familiar[Blood-Faced Volleyball]);
		return true;
	}
	return false;
}

//SIMON ADDED WRAPPER FUNCTION WITH FEASTING
boolean setFamiliar(string famtype) {
	print("choosing a "+famtype+" familiar","purple");
	boolean result = innerSetFamiliar(famtype);
	print("innersetfamiliar chose "+ my_familiar());
	if(my_path()=="Avatar of Jarlsberg")
		return true;
	
	//in heavy rains, our familiars need help
	if(my_path() == "Heavy Rains" && !boolean_modifier("Underwater Familiar"))
	{
		equip($item[miniature life preserver]);
		return result;
	}
	
	if(i_a("snow suit")>0)
	{
		//open decorate page
		string catch=visit_url("inv_use.php?pwd&which=2&whichitem=6150");
		//do we need items?
		if(famtype=="items" || famtype=="itemsnc" || famtype=="equipmentnc" || famtype=="hebo" || famtype=="obtuseangel" || famtype=="obtuseangel_simon")
			catch=visit_url("choice.php?pwd&whichchoice=640&option=3&choiceform3=Add+a+Sensitive+Carrot+Nose");
		else //otherwise go for mp regen hat
			catch=visit_url("choice.php?pwd&whichchoice=640&option=5&choiceform5=Add+a+Magical+Hat");
	}
	print("finished checking snow suit");
	
	//put on correct fam item
	if(my_familiar()==$familiar[disembodied hand] || my_familiar()==$familiar[fancypants scarecrow] || my_familiar()==$familiar[mad hatrack])
	{
		print("equip familiar with normal gear");
		if(contains_text(famtype,"meat"))
		{
			cli_execute("maximize meat +1 familiar");
		}
		else if(contains_text(famtype,"items") || contains_text(famtype,"obtuseangel")
			|| contains_text(famtype,"equipmentnc") || contains_text(famtype,"hebo"))
		{
			cli_execute("maximize items +1 familiar");
		}
		else if(contains_text(famtype,"init"))
		{
			cli_execute("maximize initiative +1 familiar");
		}
		else
		{
			cli_execute("maximize exp +1 familiar");
		}
	}
	else if(my_familiar()!=$familiar[none])
	{
		print("deciding what to do with a standard familiar");
		//equip snow suit if we have and it's not melted, else moveable feast
		item best_eq= equipped_item($slot[familiar]);
		//allow bander to keep it's item at least
		if(best_eq!=$item[crimsilion jub-jub bird] && best_eq!=$item[charpuce jub-jub bird] && best_eq!=$item[aquaviolet jub-jub bird])
		{
			if(i_a("moveable feast")>0)
				best_eq=$item[moveable feast];
			if(i_a("snow suit")>0 && (get_property("_snowSuitCount").to_int()<75 || i_a("moveable feast")==0))
				best_eq=$item[snow suit];
			print("best fam eq is "+best_eq);
			if(best_eq!=$item[none])
				equip(best_eq);
		}
	}
	print("finished choosing fam gear");
	
	if(my_path()=="Avatar of Boris") return result;
	if(result)
		if(available_amount($item[moveable feast])>0 && !contains_text(get_property("_feastedFamiliars"),to_string(my_familiar())))
			if(equipped_amount($item[moveable feast])>0)
				cli_execute("unequip moveable feast; use moveable feast; equip moveable feast");
			else if(i_a("moveable feast")>0)
				cli_execute("use moveable feast");
	print("finished using moveable feast");
	return result;
}

boolean setMCD(int moxie, int sMox) {
	if (get_property("bcasc_disableMCD") == "true") return false;
	
	if (canMCD()) {
		print("BCC: We CAN set the MCD.", "purple");
		
		//We do. Check maxMCD value
		int maxmcd = 10;
		int mcdval = my_buffedstat(my_primestat()) - sMox;
		
		if (mcdval > maxmcd || !in_hardcore() || (bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) {
			mcdval = maxmcd;
		}
		cli_execute("mcd "+mcdval);
		return true;
	}
	return false;
}

//Thanks Rinn and Theraze!
boolean traverse_temple()
{
	betweenBattle();
	
	while(i_a("stone wool") != 0)
	{
		if (have_effect($effect[Stone-Faced]) == 0)
			use(1, $item[stone wool]);
		
		string page = visit_url("adventure.php?snarfblat=280");			
		if (!checkStage("nostril"))
		{
			if(i_a("nostril of the serpent") == 0)
			{
				set_property("choiceAdventure582", "1");
				runChoice(page);
				set_property("choiceAdventure579", "2");
				runChoice(page);
			}
			else
			{
				visit_url("choice.php?whichchoice=582&option=2&pwd");
				visit_url("choice.php?whichchoice=580&option=2&pwd");
				visit_url("choice.php?whichchoice=584&option=4&pwd");
				visit_url("choice.php?whichchoice=580&option=1&pwd");
				visit_url("choice.php?whichchoice=123&option=2&pwd");
				visit_url("choice.php");
				cli_execute("dvorak");
				visit_url("choice.php?whichchoice=125&option=3&pwd");
				checkStage("nostril", true);
				return true;
			}
		}
	}

	string page = visit_url("adventure.php?snarfblat=280");
	
	if (contains_text(page, "Combat"))
	{
		run_combat();
	}
	else if (contains_text(page, "Hidden Heart of the Hidden Temple"))
	{
		if(i_a("nostril of the serpent") < 1 || my_adventures() < 3)
		{
			set_property("choiceAdventure580", "1");
			runChoice(page);
		}
		else
		{
			visit_url("choice.php?whichchoice=580&option=2&pwd");
			visit_url("choice.php?whichchoice=584&option=4&pwd");
			visit_url("choice.php?whichchoice=580&option=1&pwd");
			visit_url("choice.php?whichchoice=123&option=2&pwd");
			visit_url("choice.php");
			cli_execute("dvorak");
			visit_url("choice.php?whichchoice=125&option=3&pwd");
			return true;
		}
	}
	else if (contains_text(page, "Such Great Heights"))
	{
		if(get_property("choiceAdventure579") != "2" && item_amount($item[the Nostril of the Serpent]) < 1)
		{
			set_property("choiceAdventure579", "2");
		}
		runChoice(page);
	}
	else if (contains_text(page, "Such Great Depths"))
	{
		if(get_property("choiceAdventure581") == "0")
		{
			set_property("choiceAdventure581", "2");
		}
		runChoice(page);
	}
	else
	{
		runChoice(page);
	}

	return false;
}

//Thanks, Rinn!
string tryBeerPong() {
	//get rid of book
	cli_execute("closet put * big book of pirate insults");
	cli_execute("closet put * massive manual of marauder mockery");
	string page = visit_url("adventure.php?snarfblat=157");
	
	if (contains_text(page, "Combat")) {
		//The way I use this, we shouldn't ever have a combat with this script, but there's no harm in a check for a combat. 
		if ((numPirateInsults() < 6) && (contains_text(page, "Pirate"))) throw_item($item[The Big Book of Pirate Insults]);
		while(!page.contains_text("You win the fight!")) page = bumRunCombat();
	} else if (contains_text(page, "Arrr You Man Enough?")) {
		int totalInsults = numPirateInsults();
		if (totalInsults > 5) {
			print("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue");
			page = beerPong( visit_url( "choice.php?pwd&whichchoice=187&option=1" ) );
		} else {
			print("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue");
			print("Arrr You Man Enough?", "red");
			page = visit_url( "choice.php?pwd&whichchoice=187&option=2" );
		}
	} else if (contains_text(page, "Arrr You Man Enough?")) {
		//Doesn't this do just the same as above? Rinn has it like this, so I'll leave it like this for the moment. 
		page = beerPong(page);
	} else {
		page = runChoice(page);
	}

	return page;
}

monster whatShouldIFax() {
	if (my_adventures() == 0) return $monster[none]; // don't try and fax a monster if you have no adventures left to fight it
	
	//fax machine isn't trendy anyway
	if (my_path()=="Heavy Rains")
	{
		use_rain_man();
		return $monster[none];
	}
	
	if (get_property("bcasc_lastFax") == today_to_string() || get_property("_photocopyUsed") != "false") return $monster[none];
	if (get_property("bcasc_doNotFax") == true) return $monster[none];
	if (can_interact() && !bcasc_RunSCasHC) return $monster[none];
	if (my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete") return $monster[none];
	if (item_amount($item[Clan VIP Lounge key]) == 0) return $monster[none];
	if (!contains_text(visit_url("clan_viplounge.php"), "faxmachine.gif")) return $monster[none];
	
	//Set p to be primestat as a shortcut.
	//SIMON SAYS LETS JUST ASSUME WE CAN KILL ANYTHING
	int p = 1000; //my_buffedstat(my_primestat());
//	if (my_primestat() == $stat[Mysticality]) p = p + 30;
	print("p="+p,"lime");
	
	//simon changed faxing
/*	
	print("ghost="+monster_attack($monster[ghost]),"lime");
	if(i_a("digital key")<1 && i_a("white pixel")<=10) //don't fax if we already faxed a ghost, don't waste more than 1
		if (p > monster_attack($monster[ghost]))
		{
			setMood("i");
			buMax();
			setFamiliar("items");
			return $monster[ghost];
		} <use psycho jar insttead of ghost fax>
*/
	
	if(i_a("spangly mariachi pants")==0 && i_a("spangly sombrero")==0 && my_path()!="Heavy Rains")
	{
		setMood("");
		buMax();
		setFamiliar("hebo");
		return $monster[sleepy mariachi];
	}
//	if (my_path() != "Bees Hate You" && my_path() != "Way of the Surprising Fist" && (i_a("Knob Goblin elite helm") == 0 || i_a("Knob Goblin elite polearm") == 0 || i_a("Knob Goblin elite pants") == 0)) {
//		if (p > monster_attack($monster[Knob Goblin Elite Guard Captain])) return $monster[Knob Goblin Elite Guard Captain];
//	}
	

	print("a"+my_level() > 10 && p > monster_attack($monster[lobsterfrogman]));
	if (my_level() > 11 && p > monster_attack($monster[lobsterfrogman]) && bcasc_doSideQuestBeach && !to_boolean(get_property("sidequestLighthouseCompleted"))) {
		print("b"+(bcasc_doSideQuestBeach && i_a("barrel of gunpowder") < 5 && (get_property("sidequestLighthouseCompleted") == "none")));
		if (bcasc_doSideQuestBeach && i_a("barrel of gunpowder") < 5 && (get_property("sidequestLighthouseCompleted") == "none")) {
			setMood("");
			buMax();
			setFamiliar("");
			return $monster[lobsterfrogman];
		}
	}
	
	return $monster[none];
}

boolean willMood() {
	return (!in_hardcore() || haveElite() || my_meat() > 5000 || my_mp() > 100 || my_path() == "Avatar of Jarlsberg");
}

void zapKeys() {
	if (item_amount($item[fat loot token]) > 0) {
		foreach i in $items[boris's key, jarlsberg's key, sneaky pete's key] {
			if (item_amount(i) == 0) {
				//buy($coinmaster[Vending Machine], 1, i);
				if(i == $item[boris's key])
					visit_url("shop.php?pwd&whichshop=damachine&action=buyitem&whichrow=93&bigform=Buy+Item&quantity=1");
				if(i == $item[jarlsberg's key])
					visit_url("shop.php?pwd&whichshop=damachine&action=buyitem&whichrow=94&bigform=Buy+Item&quantity=1");
				if(i == $item[sneaky pete's key])
					visit_url("shop.php?pwd&whichshop=damachine&action=buyitem&whichrow=95&bigform=Buy+Item&quantity=1");
				return;
			}
		}
	}
	
	if (canZap()) {
		if (i_a("boris's ring") + i_a("jarlsberg's earring") + i_a("sneaky pete's breath spray") > 0 ) {
			print("BCC: Your wand is safe, so I'm going to try to zap something");
			if (i_a("boris's ring") > 0) { cli_execute("zap boris's ring"); 
			} else if (i_a("jarlsberg's earring") > 0) { cli_execute("zap jarlsberg's earring"); 
			} else if (i_a("sneaky pete's breath spray") > 0) { cli_execute("zap sneaky pete's breath spray"); 
			} else if (i_a("jarlsberg's key") > 1) { cli_execute("zap jarlsberg's key");  
			} else if (i_a("sneaky pete's key") > 1) { cli_execute("zap sneaky pete's key"); 
			} else if (i_a("boris's key") > 1) { cli_execute("zap boris's key");  
			}
		}
	} else {
		print("BCC: You don't have a wand, or it's not safe to use one. No Zapping for you.", "purple");
	}
}

void get_gene_tonic()
{
	string str = visit_url("campground.php?action=workshed");
	str = visit_url("campground.php?action=dnapotion");
}

void use_genetics_lab(string req)
{
	print("called use_genetics_lab","lime");
	cli_execute("inventory refresh");
	if(i_a("DNA extraction syringe")>0)
	{
		string curDNA = get_property("dnaSyringe");
		
		//hybridize ourselves with penguin/dude
		if(!get_property("_dnaHybrid").to_boolean())
		{
			boolean use_penguin=false;
			if(my_level()>=11 && use_penguin)	//high enough to find a penguin
			{
				if(curDNA=="penguin" && have_effect($effect[Human-Penguin Hybrid])==0)
				{
					string str = visit_url("campground.php?action=workshed");
					str = visit_url("campground.php?action=dnainject");
					return;
				}
			}
			else if(my_path()=="Heavy Rains")
			{
				if(curDNA=="fish" && have_effect($effect[Human-Fish Hybrid])==0)
				{
					string str = visit_url("campground.php?action=workshed");
					str = visit_url("campground.php?action=dnainject");
					return;
				}
			}
			else //use a dude
			{
				if(curDNA=="dude" && have_effect($effect[Human-Human Hybrid])==0)
				{
					string str = visit_url("campground.php?action=workshed");
					str = visit_url("campground.php?action=dnainject");
					return;
				}
			}
		}
				
		//use gene tonics
		if(contains_text(req,"n") && have_effect($effect[Human-Insect Hybrid])==0 && i_a("Gene Tonic: Insect")>0)
		{
			use(1,$item[Gene Tonic: Insect]);
		}
		if(contains_text(req,"m") && have_effect($effect[Human-Constellation Hybrid  ])==0 && i_a("Gene Tonic: Constellation")>0)
		{
			use(1,$item[Gene Tonic: Constellation]);
		}
		if(contains_text(req,"orchard") && have_effect($effect[Human-Human Hybrid])==0 && i_a("Gene Tonic: Dude")>0)
		{
			use(1,$item[Gene Tonic: Dude]);
		}
		if(contains_text(req,"res") && have_effect($effect[Human-Elemental Hybrid])==0 && i_a("Gene Tonic: Elemental")>0)
		{
			use(1,$item[Gene Tonic: Elemental]);
		}
		
		//make new gene tonics
		if(get_property("_dnaPotionsMade").to_int() > 2)
			return;
			
		if(curDNA=="insect"  && i_a("Gene Tonic: insect")==0)
		{
			get_gene_tonic();
			return;
		}
		if(curDNA=="constellation"  && i_a("Gene Tonic: constellation")==0)
		{
			get_gene_tonic();
			return;
		}
		if(curDNA=="dude" && i_a("Gene Tonic: dude")==0)
		{
			get_gene_tonic();
			return;
		}
		if(curDNA=="elemental" && i_a("Gene Tonic: Elemental")==0)
		{
			get_gene_tonic();
			return;
		}
		//could also use weird - 4 stats (posessed toy chest, barrel mimic, )
	}
	print("finished use_genetics_lab","lime");
}

void collect_dna(string req)
{
	print("called collect_dna","lime");
	cli_execute("inventory refresh");
	if(i_a("DNA extraction syringe")>0)
	{
		string curDNA = get_property("dnaSyringe");
		
		if(!get_property("_dnaHybrid").to_boolean())
		{
			boolean go_for_penguin=false; //I changed my mind about this, the intrinsic poison is annoying and it's too late in the ascension
			if(my_level()>=11 && go_for_penguin) //go for penguin
			{
				//try to get to copperhead club
				if(!can_adv($location[the copperhead club]))
				{
					bcascMacguffinDiary();
					//if(!can_adv($location[the copperhead club]))
					if(!contains_text(visit_url("place.php?whichplace=town_wrong"),"copperclub.gif"))
						abort("Failed to open copperhead club");
				}
				if(curDNA=="penguin")
				{
					use_genetics_lab("i");
					set_combat_macro();
					return;
				}
				while(have_effect($effect[Human-Penguin Hybrid])==0)
				{
					//already released gong?
					if(get_property("")!="gong")
					{
						//we REALLY need to get rid of the bullet storm to survive in here
						set_property("choiceAdventure855","1");
						if(have_effect($effect[Crappily Disguised as a Waiter])==0)
						{
							if(i_a("crappy waiter disguise")==0)
								cli_execute("pull crappy waiter disguise");
							use(1,$item[crappy waiter disguise]);
						}
					}
					abort("what property relates to behind the stache choice?");
					
					//look for mob penguin capo
					print("Trying to get dna from mob penguin capo","purple");
					clear_combat_macro();
					bumAdv($location[The copperhead club], "", "", "", "Getting penguin dna", "", "consultSyringePenguin");
				
					curDNA = get_property("dnaSyringe");
					if(contains_text(get_property("lastEncounter"),"Mob Penguin Capo") && curDNA!="penguin")
						abort("We just fought a mob penguin capo and didn't get our dna!");
					
					if(curDNA=="penguin")
					{
						use_genetics_lab("i");
						set_combat_macro();
						return;
					}
				}
			}
			else if(my_path()=="Heavy Rains")
			{
				//in heavy rains, our familiars are always low weight, so lets do a fish hybrid
				curDNA = get_property("dnaSyringe");
				if(curDNA!="fish" && have_effect($effect[human-fish hybrid])==0)
				{
					use_rain_man($monster[piranhadon]);
					curDNA = get_property("dnaSyringe");
				}
				if(contains_text(get_property("lastEncounter"),"Piranhadon") && curDNA!="fish")
					abort("We conjured a piranhadon and didn't get our dna!");
				
				if(curDNA=="fish")
				{
					use_genetics_lab("");
					set_combat_macro();
					return;
				}
			}
			else //go for dude
			{
				print("going for dude hybridization","lime");
				if(curDNA=="dude")
				{
					use_genetics_lab("i");
					return;
				}
				
				while(have_effect($effect[Human-Human Hybrid])==0)
				{		
					//look for mob penguin capo
					print("Trying to get dna from amateur ninja or ancient insane monk","purple");
					clear_combat_macro();
					bumAdv($location[The Haiku Dungeon], "", "", "", "Getting dude dna", "", "consultSyringeDude");
					
					//need to refresh dna since mafia doesn't follow it in haiku dungeon
					string str = visit_url("campground.php?action=workshed");
					
					curDNA = get_property("dnaSyringe");
					if(contains_text(get_property("lastEncounter"),"Amateur ninja") && curDNA!="dude")
						abort("We just fought an Amateur ninja and didn't get our dna!");
					if(contains_text(get_property("lastEncounter"),"Ancient insane monk") && curDNA!="dude")
						abort("We just fought an Ancient insane monk and didn't get our dna!");
						
					if(curDNA=="dude")
					{
						use_genetics_lab("i");
						set_combat_macro();
						return;
					}
				}
			}
		}
		
		//check for gene tonics
		if(get_property("_dnaPotionsMade").to_int() > 2)
			return;
		
		//insect = spiders - sleazy back alley
		//elemental = Ninja Snowman, 
		//humanoid could also give low level meat, but support isn't in combat macro or use_genetics_lab	
		if(curDNA=="constellation")
		{
			use_genetics_lab("m");
			return;
		}
		while(contains_text(req,"m") && have_effect($effect[Human-Constellation Hybrid])==0 && i_a("steam-powered model rocketship")>0)
		{			
			//look for constellation
			print("Trying to get dna from constellation","purple");
			clear_combat_macro();
			bumAdv($location[The hole in the sky], "", "", "", "Getting constellation dna", "", "consultSyringeConstellation");
			
			curDNA = get_property("dnaSyringe");
			if(contains_text(get_property("lastAdventure"),"The hole in the sky") && curDNA!="constellation")
				abort("We just fought a Constellation and didn't get our dna!");
			
			if(curDNA=="constellation")
			{
				use_genetics_lab("m");
				return;
			}
		}
	}
}

/***********************************************
* BEGIN FUNCTIONS THAT RELY ON OTHER FUNCTIONS *
***********************************************/

void cast_rain_man(int mob_id)
{
	visit_url("skills.php?pwd&action=Skillz&whichskill=16011&skillform=Use+Skill&quantity=1");
	visit_url("choice.php?pwd&whichchoice=970&whichmonster="+mob_id.to_string()+"&option=1&choice2=and+Fight%21");
}


void use_rain_man(monster mob)
{
	if(my_rain()<50)
		return;
	print("Deciding whether to use rain man","green");
	if(mob==$monster[piranhadon])
	{
		print("rain man'ing a piranhadon","green");
		clear_combat_macro();
		cast_rain_man(1601);
		bumRunCombat("consultSyringeFish");
		return;
	}
	else if(mob==$monster[none])
	{
		if (my_level() > 11 && bcasc_doSideQuestBeach && !to_boolean(get_property("sidequestLighthouseCompleted"))) {
			if (bcasc_doSideQuestBeach && i_a("barrel of gunpowder") < 5 && (get_property("sidequestLighthouseCompleted") == "none")) {
				//if we have already copied this, don't rain man it
				if($monster[lobsterfrogman] == to_monster(get_property("spookyPuttyMonster")) || $monster[lobsterfrogman] == to_monster(get_property("rainDohMonster")))
					return;
			
				print("rain man'ing a LFM","green");
				cli_execute("mood execute");
				buMax();
				setFamiliar("obtuseangel_simon");
				clear_combat_macro();
				cast_rain_man(970);
				bumRunCombat("consultObtuse");
				return;
			}
		}
	
	}
	else
	{
		abort("Unrecognised monster requested for rain man: "+mob);
	}
	
/*
!writing desk	/w FaxBot writing_desk	Partial Spookyraven Manor unlock	Yes	None	Requires 4 copies. Allows skipping The Haunted Kitchen, The Haunted Billiards Room and The Haunted Library! <also fax, and implement skipping>
You must read the telegram before fighting these. You need to fight 5 of these to open Spookyraven's second floor, bypassing all of the first floor zones. With the Reanimated Reanimator you can wink at the first one, Rain Man a second one, and then wait for the 3 wandering copies.

sleepy mariachi	/w FaxBot sleepy_mariachi	Item drops, Moxie stats	No	Yellow ray	Saves several powerleveling turns for Moxie classes; makes the best Fairies in the game

ninja snowman assassin	/w FaxBot ninja_assassin	Level 8 quest	Yes	Survival	Saves ~12 turns (or 3 pulls) when copied twice


lobsterfrogman	/w FaxBot lobsterfrogman	Sonofa Beach quest	No	None	Saves ~4 turns (and lots of RNG swing) over finding each one manually 
(per copy, up to a total of ~20 turns for 5 copies)

Quantum Mechanic	/w FaxBot mechanic	blessed large box (The Three Gates)	No	150% items	Saves ~12 turns (or 1 pull) by letting you skip the DoD entirely
Orcish Frat Boy Spy	/w FaxBot frat_spy	Level 12 quest and/or the Nuns trick	No	234% items	- Saves 1-2 yellow rays, depending on if you need anything from The Hippy Store
- Saves 8 turns if it frees up resources that enable the Nuns trick
dirty thieving brigand
ghost <morbid skull>


mountain man (requires Monster Manuel): With Unaccompanied Miner being type69ed, your only speedy choices for acquiring the ore you need in Hardcore are mountain men, clovers, and zapping.

screambat: Its screams can't be washed away by water, like sonars can. You must open the bathole before fighting these.
gaudy pirate: You have to fight 2 of these... but remember, you also have to unlock the Belowdecks to use the gaudy keys. If you still need insults, you can use The Big Book of Pirate Insults during these fights.
Baa'baa'bu'ran: Good for not only unlocking The Hidden City, but with the 3rd stone wool you can use it for 3 extra Adventures or extra stats.
alley catfish: Its whiskers (potion) help you prevent items washing away, and it's a fish, whose DNA you may want to extract.
piranhadon: A useful source of freshwater fishbones as well as fish DNA. The large Spell Damage bonus fishbone bracers will allow you to defeat strong monsters more easily, if you're using spells.
gremlins, assorted types: Be sure to select the correct on

Semi-Rare Monsters	/w FaxBot kge
/w FaxBot miner
/w FaxBot baabaaburan	Knob Goblin Elite Guard Uniform
Mining Gear
stone wool	Varies	None
234% items
Up to 400% items	In case you weren't able to structure your SRs around them, or if your path blocks fortune cookies
mountain man	/w FaxBot mountain_man	Drops ore	Yes	150% items for one of each ore, YR for two of each	Alternative to mining or clovering ores
modern zmobie	/w FaxBot modern_zmobie	The Defiled Alcove	Yes	None	Saves several turns in the Alcove over encountering them directly
remains of a jilted mistress	/w FaxBot jilted	antique hand mirror	No	150% items	Saves several turns hunting for One Nightstand (Wooden) for Myst classes, if powerleveling in the Haunted Bathroom is desired.
Bad ASCII Art,
rampaging adding machine	/w FaxBot ascii
/w FaxBot adding_machine	A Quest, LOL	Varies	None	For players who want the Meat from this quest or want to copy the ASCII art for 31337 scrolls
Sorceress's Quest Monsters	(varies)	The Three Gates or the Tower	No	(varies)	If you need a hard-to-find gate or tower item
*/
}

void use_rain_man()
{
	use_rain_man($monster[none]);
}


void setMood(string combat) {
	if (get_property("bcasc_disableMoods") == "true") {
		cli_execute("mood apathetic"); 
		return;
	}
	
	if(have_effect($effect[temporary amnesia])>0)
		cli_execute("uneffect temporary amnesia");
	if(have_effect($effect[temporary amnesia])>0)
		abort("failed to remove temporary amnesia. Mood will probably go crazy until you can cast spells again");

	if(my_path()=="KOLHS" && get_property("_kolhsAdventures").to_int()>=40 && (get_property("yearbookCameraPending")!="true" || get_property("yearbookCameraTarget")==""))
		abort("Need to do the yearbook thing!");

	cli_execute("mood bumcheekascend");
	cli_execute("mood clear");
	defaultMood(combat == "");

	//gene tonics
	use_genetics_lab(combat);

	//use heavy rains buff items
	if(my_path()=="Heavy Rains")
	{
		
		//stop items washing away
		if(contains_text(combat,"i") && i_a("catfish whiskers")>0 && have_effect($effect[Fishy Whiskers])==0)
			use(1,$item[catfish whiskers]);
		//init to help fighting
		if(i_a("gourmet gourami oil")>0 && have_effect($effect[Fishy\, Oily])==0)
			use(1,$item[gourmet gourami oil]);
		
		//learning order, thunder
		if(i_a("thunder thigh")>0)
			visit_url("inv_use.php?pwd&which=3&whichitem=7648");	
		while(i_a("thunder thigh")>0)
		{
			if(!have_skill($skill[thundercloud]))
				visit_url("choice.php?pwd&whichchoice=967&option=2");
			else if(!have_skill($skill[thunder clap]))
				visit_url("choice.php?pwd&whichchoice=967&option=1");
			else if(in_hardcore() && !have_skill($skill[Thunder Down Underwear ]))
				visit_url("choice.php?pwd&whichchoice=967&option=6");
			else if(!have_skill($skill[thunderheart]))
				visit_url("choice.php?pwd&whichchoice=967&option=4");
			else if(!have_skill($skill[Thunderstrike]))
				visit_url("choice.php?pwd&whichchoice=967&option=5");
			else if(!have_skill($skill[Thunder Thighs]))
				visit_url("choice.php?pwd&whichchoice=967&option=7");
			else if(!have_skill($skill[Thunder Bird]))
				visit_url("choice.php?pwd&whichchoice=967&option=3");
			else if(!have_skill($skill[Thunder Down Underwear ]))
				visit_url("choice.php?pwd&whichchoice=967&option=6");
			else
				break;
		}

		//learning order, rain
		if(i_a("aquaconda brain")>0)
			visit_url("inv_use.php?pwd&which=3&whichitem=7647");		
		while(i_a("aquaconda brain")>0)
		{
			if(!have_skill($skill[rain man]))
				visit_url("choice.php?pwd&whichchoice=968&option=1&choiceform1=Rain+Man");
			else if(!have_skill($skill[rainy day]))
				visit_url("choice.php?pwd&whichchoice=968&option=2");
			else if(!have_skill($skill[rain dance]))
				visit_url("choice.php?pwd&whichchoice=968&option=4");
			else if(!have_skill($skill[rainbow]))
				visit_url("choice.php?pwd&whichchoice=968&option=5");
			else if(!have_skill($skill[make it rain]))
				visit_url("choice.php?pwd&whichchoice=968&option=3");
			else if(!have_skill($skill[rain delay]))
				visit_url("choice.php?pwd&whichchoice=968&option=7");
			else if(!have_skill($skill[rain coat]))
				visit_url("choice.php?pwd&whichchoice=968&option=6");
			else
				break;
			abort("use rain man faxes see http://kol.coldfront.net/thekolwiki/index.php/Heavy_Rains/Strategy");
		}	

		//learning order, lightning
		if(i_a("lightning milk")>0)
			visit_url("inv_use.php?pwd&which=3&whichitem=7646");
		while(i_a("lightning milk")>0)
		{
			if(!have_skill($skill[Lightning Strike]))
				visit_url("choice.php?pwd&whichchoice=969&option=1");
			else if(!have_skill($skill[Ball Lightning]))
				visit_url("choice.php?pwd&whichchoice=969&option=3");
			else if(!have_skill($skill[Riding the Lightning]))
				visit_url("choice.php?pwd&whichchoice=969&option=7");
			else if(!have_skill($skill[Sheet Lightning]))
				visit_url("choice.php?pwd&whichchoice=969&option=4");
			else if(!have_skill($skill[Clean-Hair Lightning]))
				visit_url("choice.php?pwd&whichchoice=969&option=2");
			else if(!have_skill($skill[Lightning Rod]))
				visit_url("choice.php?pwd&whichchoice=969&option=6");
			else if(!have_skill($skill[Lightning Bolt]))
				visit_url("choice.php?pwd&whichchoice=969&option=5");
			else
				break;
		}		

	
		//thunder skills
		//in hardcore, prefer to make gear first
		if(in_hardcore() && i_a("Thunder down underwear")==0)
		{
			if(my_thunder()>=60 && have_skill($skill[Thunder down underwear]))
				use_skill(1,$skill[Thunder down underwear]);			
		}
		else
		{
			if(my_thunder()>=20 && have_effect($effect[personal thundercloud])==0 && have_skill($skill[thundercloud]))
				use_skill(1, $skill[thundercloud]);
			if(my_thunder()>=20 && have_effect($effect[Thunderheart])==0 && have_skill($skill[Thunderheart]))
				use_skill(1, $skill[Thunderheart]);
				
			//if we are full, might as well burn some
			if(my_thunder()>90)
			{
				if(have_skill($skill[thundercloud]))
					use_skill(1, $skill[thundercloud]);
				if(have_skill($skill[Thunderheart]))
					use_skill(1, $skill[Thunderheart]);
			}
		}
		
		//rain skills
		//in hardcore, prefer to make gear first
		if(in_hardcore() && i_a("Famous blue raincoat")==0)
		{
			if(my_rain()>=40 && have_skill($skill[rain coat]))
				use_skill(1,$skill[rain coat]);			
		}
		else
		{
			if(my_rain()>=20 && have_effect($effect[The Rain In Loathing])==0 && have_skill($skill[Rainy Day]))
				use_skill(1,$skill[Rainy Day]);
			if(my_rain()>=10 && have_effect($effect[Rain Dancin'])==0 && have_skill($skill[Rain Dance]))
				use_skill(1,$skill[Rain Dance]);
			if(my_rain()>85) //try not to waste any
				use_rain_man();
		}
		
		//lightning skills
		//in hardcore, prefer to make gear first
		if(in_hardcore() && i_a("Lightning rod")==0 && my_primestat()==$stat[mysticality])
		{
			if(my_lightning()>=20 && have_skill($skill[Lightning Rod]))
				use_skill(1,$skill[Lightning Rod]);			
		}
		else
		{
			if(my_lightning()>=10 && have_effect($effect[Stormswaddled])==0 && have_skill($skill[Sheet Lightning]))
				use_skill(1,$skill[Sheet Lightning]);
			if(my_lightning()>=10 && have_effect($effect[Charged Hair])==0 && have_skill($skill[Clean-Hair Lightning]))
				use_skill(1,$skill[Clean-Hair Lightning]);
		}
		
		//fishbones
		int bones = i_a("freshwater fishbone");
		if(bones>=5)
		{
			//combat helper accessory
			if(my_primestat()==$stat[mysticality])
			{
				if(bones>=5 && i_a("fishbone bracers")==0)
				{
					create(1,$item[fishbone bracers]);
					cli_execute("outfit bumcheekascend");
					equip($slot[acc1],$item[fishbone bracers]);
					cli_execute("outfit save bumcheekascend");
					
					bones = i_a("freshwater fishbone");
				}
			}
			else
			{
				if(bones>=5 && i_a("fishbone belt")==0)
				{
					create(1,$item[fishbone belt]);
					cli_execute("outfit bumcheekascend");
					equip($slot[acc1],$item[fishbone belt]);
					cli_execute("outfit save bumcheekascend");
					
					bones = i_a("freshwater fishbone");
				}
			}
			//items helper
			if(bones>=30 && i_a("Fishbone catcher's mitt")==0)
			{
				create(1,$item[Fishbone catcher's mitt]);
				bones = i_a("freshwater fishbone");
			}
			
		}
	}

	//SIMON CHANGED
	if (my_path() != "Avatar of Boris" && my_path() != "Zombie Slayer" && my_path() !="Avatar of Jarlsberg" && my_path() != "Avatar of Sneaky Pete") {
		print("setting normal paths mood","lime");
		if (contains_text(combat,"+")) {
			if (willMood()) {
				print("BCC: Need moar combat! WAAARGH!", "purple");
				if (have_skill($skill[Musk of the Moose]) && my_maxmp() > mp_cost($skill[Musk of the Moose]) * 2) cli_execute("trigger lose_effect, Musk of the Moose, cast 1 Musk of the Moose");
				if (have_skill($skill[Carlweather's Cantata of Confrontation]) && my_maxmp() > mp_cost($skill[Carlweather's Cantata of Confrontation]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Carlweather's Cantata of Confrontation, cast 1 Carlweather's Cantata of Confrontation");
				cli_execute("trigger gain_effect, The Sonata of Sneakiness, uneffect sonata of sneakiness");
				if(i_a("musk turtle")>0 && have_effect($effect[High Colognic])==0)
					use(1,$item[musk turtle]);
			}
		} 
		if (contains_text(combat,"-")) {
			if (willMood()) {
				print("BCC: Need less combat, brave Sir Robin!", "purple");
				if (have_skill($skill[Smooth Movement]) && my_maxmp() > mp_cost($skill[Smooth Movement]) * 2) cli_execute("trigger lose_effect, Smooth Movements, cast 1 smooth movement");
				if (have_skill($skill[The Sonata of Sneakiness]) && my_maxmp() > mp_cost($skill[The Sonata of Sneakiness]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Sonata of Sneakiness, cast 1 sonata of sneakiness");
				cli_execute("trigger gain_effect, Carlweather's Cantata of Confrontation, uneffect Carlweather's Cantata of Confrontation");

				//if we dont need any more snow boards, use them for -combat
				if(i_a("snow berries")>0 && (to_int(get_property("chasmBridgeProgress")) >= 30) && get_property("lastChasmReset").to_int()==my_ascensions() && checkStage("bats1"))
				{
					if(have_effect($effect[snow shoes])==0)
					{
						create(1,$item[snow cleats]);
						use(1,$item[snow cleats]);
					}
				}
				cli_execute("trigger gain_effect, Carlweather's Cantata of Confrontation, uneffect Carlweather's Cantata of Confrontation");
			}
		}
		if (contains_text(combat,"i")) {
			if (willMood()) {
				print("BCC: Need items!", "purple");
				if (have_skill($skill[Fat Leon's Phat Loot Lyric]) && my_maxmp() > mp_cost($skill[Fat Leon's Phat Loot Lyric]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Fat Leon's Phat Loot Lyric, cast 1 Fat Leon's Phat Loot Lyric");
				if (my_class()==$class[accordion thief] && my_level()>=15 && have_skill($skill[The Ballad of Richie Thingfinder]) && my_maxmp() > mp_cost($skill[The Ballad of Richie Thingfinder]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Ballad of Richie Thingfinder, cast 1 The Ballad of Richie Thingfinder");
				if (have_skill($skill[Leash of Linguini]) && my_maxmp() > mp_cost($skill[Leash of Linguini]) * 2) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
				if (bcasc_castEmpathy && have_skill($skill[Empathy of the Newt]) && my_maxmp() > mp_cost($skill[Empathy of the Newt]) * 2 && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
				if (have_skill($skill[Singer's Faithful Ocelot]) && my_maxmp() > mp_cost($skill[Singer's Faithful Ocelot]) * 2) cli_execute("trigger lose_effect, Singer's Faithful Ocelot, cast 1 Singer's Faithful Ocelot");
			}
		}
		if (contains_text(combat,"n")) {
			//talk to grim brother if not already done
			if(have_familiar($familiar[grim brother]) && !get_property("_grimBuff").to_boolean())
			{
				visit_url("familiar.php?action=chatgrim&pwd");
				visit_url("choice.php?pwd&whichchoice=835&option=1&choiceform1=The+One+About+the+Stepdaughter+and+the+Glass+Clothing"); //choice 1, soles of glass
			}

			if (willMood()) {
				print("BCC: Need initiative!", "purple");
				if(i_a("giraffe-necked turtle")>0 && have_effect($effect[Adorable Lookout])==0)
					use(1,$item[giraffe-necked turtle]);
				if (have_skill($skill[Springy Fusilli]) && my_maxmp() > mp_cost($skill[Springy Fusilli]) * 2) cli_execute("trigger lose_effect, Springy Fusilli, cast 1 Springy Fusilli");
				if (have_skill($skill[Cletus's Canticle of Celerity]) && my_maxmp() > mp_cost($skill[Cletus's Canticle of Celerity]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Cletus's Canticle of Celerity, cast 1 Cletus's Canticle of Celerity");
				if (have_skill($skill[Walberg's Dim Bulb]) && my_maxmp() > mp_cost($skill[Walberg's Dim Bulb]) * 2) cli_execute("trigger lose_effect, Walberg's Dim Bulb, cast 1 Walberg's Dim Bulb");
				//its so rare that we need initiative, lets just go all out
				if(item_amount($item[Okee-Dokee soda])>0) cli_execute("trigger lose_effect, , use 1 Okee-Dokee soda");
				if(item_amount($item[yellow candy heart])>0) cli_execute("trigger lose_effect, Heart of Yellow, use 1 yellow candy heart");
				if(item_amount($item[upsy daisy])>0) cli_execute("trigger lose_effect, Ass Over Teakettle, use 1 upsy daisy");
				if(item_amount($item[peppermint twist])>0) cli_execute("trigger lose_effect, peppermint twisted, use 1 peppermint twist");
				if(guild_store_available() && (my_primestat() == $stat[muscle] || (my_class()==$class[accordion thief] && my_level()>=9))) cli_execute("trigger lose_effect, ticking clock, use 1 cheap wind up clock");
				cli_execute("trigger lose_effect, hustlin, pool 3");
			}
		}
		if (contains_text(combat,"m")) {
			print("BCC: Need meat (this will always trigger)!", "purple");
			if (have_skill($skill[The Polka of Plenty]) && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Polka of Plenty, cast 1 Polka of Plenty");
			if (my_class()==$class[accordion thief] && my_level()>=15 && have_skill($skill[The Ballad of Richie Thingfinder]) && my_maxmp() > mp_cost($skill[The Ballad of Richie Thingfinder]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Ballad of Richie Thingfinder, cast 1 The Ballad of Richie Thingfinder");
		}
		if (contains_text(combat,"l") && my_path()!="BIG!") {
			if (willMood()) {
				print("BCC: Need bigger monsters!", "purple");
				if (have_skill($skill[Ur-Kel's Aria of Annoyance]) && my_maxmp() > mp_cost($skill[Ur-Kel's Aria of Annoyance]) * 2) cli_execute("trigger lose_effect, Ur-Kel's Aria of Annoyance, cast 1 Ur-Kel's Aria of Annoyance");
				if (have_skill($skill[Drescher's Annoying Noise]) && my_maxmp() > mp_cost($skill[Drescher's Annoying Noise]) * 2) cli_execute("trigger lose_effect, Drescher's Annoying Noise, cast 1 Drescher's Annoying Noise");
				if (have_skill($skill[Pride of the Puffin])) cli_execute("trigger lose_effect, Pride of the Puffin, cast 1 Pride of the Puffin");
			}
		} 
		
		//choose a dreadsylvania song (mutually exclusive)
		if(my_maxmp()>200)
		{
			if (contains_text(combat,"n") && have_skill($skill[song of slowness])) 
				cli_execute("trigger lose_effect, song of slowness, cast 1 song of slowness"); //init is the only directly useful one
			else if ((my_primestat()==$stat[muscle] || my_primestat()==$stat[moxie]) && have_skill($skill[song of the north]))
				cli_execute("trigger lose_effect, song of the north, cast 1 song of the north"); //wep dmg
			else if (my_primestat()==$stat[mysticality] && have_skill($skill[song of sauce]))
				cli_execute("trigger lose_effect, song of sauce, cast 1 song of sauce"); //spell dmg
			else if (have_skill($skill[song of bravado]))
				cli_execute("trigger lose_effect, song of bravado, cast 1 song of bravado"); //all stats
			else if (have_skill($skill[song of starch]))
				cli_execute("trigger lose_effect, song of starch, cast 1 song of starch"); //hp
		}
		
		//facial expressions (mutually exclusive)
		if (contains_text(combat,"m") && have_skill($skill[disco leer])) //meat
			cli_execute("trigger lose_effect, Disco Leer, cast 1 Disco Leer");
		else if (contains_text(combat,"n") && have_skill($skill[Suspicious Gaze])) //initiative
			cli_execute("trigger lose_effect, Suspicious Gaze, cast 1 Suspicious Gaze");
			//only get stats less than level 10
		else if(my_level()<10 && my_primestat()==$stat[moxie] && have_skill($skill[knowing smile])) //moxie stats
			cli_execute("trigger lose_effect, knowing smile, cast 1 knowing smile");
		else if(my_level()<10 && my_primestat()==$stat[muscle] && have_skill($skill[Patient Smile])) //mus stats
			cli_execute("trigger lose_effect, Patient Smile, cast 1 Patient Smile");
		else if(my_level()<10 && my_primestat()==$stat[mysticality] && have_skill($skill[Wry Smile])) //myst stats
			cli_execute("trigger lose_effect, Wry Smile, cast 1 Wry Smile");
			//at high levels care more about crit
		else if(my_level()>=10 && my_primestat()==$stat[mysticality] && have_skill($skill[Wizard Squint])) //spell crit
			cli_execute("trigger lose_effect, Wizard Squint, cast 1 Wizard Squint");
		else if(my_level()>=10 && my_primestat()==$stat[mysticality] && have_skill($skill[Arched Eyebrow of the Archmage])) //general spell damage
			cli_execute("trigger lose_effect, Arched Eyebrow of the Archmage, cast 1 Arched Eyebrow of the Archmage");
		else if(my_level()>=10 && my_primestat()==$stat[mysticality] && have_skill($skill[icy glare])) //cold spell damage
			cli_execute("trigger lose_effect, icy glare, cast 1 icy glare");
			//at low levels care about damage
		else if(my_level()<10 && my_primestat()==$stat[mysticality] && have_skill($skill[Arched Eyebrow of the Archmage])) //general spell damage
			cli_execute("trigger lose_effect, Arched Eyebrow of the Archmage, cast 1 Arched Eyebrow of the Archmage");
		else if(my_level()<10 && my_primestat()==$stat[mysticality] && have_skill($skill[icy glare])) //cold spell damage
			cli_execute("trigger lose_effect, icy glare, cast 1 icy glare");
		else if(my_level()<10 && my_primestat()==$stat[mysticality] && have_skill($skill[Wizard Squint])) //spell crit
			cli_execute("trigger lose_effect, Wizard Squint, cast 1 Wizard Squint");
			
		else if (my_primestat()!=$stat[mysticality] && have_skill($skill[snarl of the timberwolf])) //spooky damage
			cli_execute("trigger lose_effect, snarl of the timberwolf, cast 1 snarl of the timberwolf");
		else if (my_primestat()!=$stat[mysticality] && have_skill($skill[Scowl of the Auk])) //weapon damage
			cli_execute("trigger lose_effect, Scowl of the Auk, cast 1 Scowl of the Auk");	
		else if(my_primestat()!=$stat[moxie] && have_skill($skill[Stiff Upper Lip])) //da use it if we don't need moxie
			cli_execute("trigger lose_effect, Stiff Upper Lip, cast 1 Stiff Upper Lip");		
		else if(have_skill($skill[disco smirk])) //moxie
			cli_execute("trigger lose_effect, disco smirk, cast 1 disco smirk");

		//tt blessings + boons
		if(have_effect($effect[spirit pariah])==0 && my_class()==$class[turtle tamer])
		{
			if (contains_text(combat,"n") && have_skill($skill[Blessing of the Storm Tortoise])) //init + mp
			{
				if(have_effect($effect[Blessing of the Storm Tortoise])==0 && have_effect($effect[grand Blessing of the Storm Tortoise])==0 && have_effect($effect[glorious Blessing of the Storm Tortoise])==0 && have_effect($effect[disdain of the Storm Tortoise])==0)
				{
					use_skill($skill[Blessing of the Storm Tortoise]);
					if(my_class()==$class[turtle tamer] && have_skill($skill[spirit boon]))
						cli_execute("trigger lose_effect, boon of the storm tortoise, cast 1 spirit boon");
				}
			}
			else if (have_skill($skill[Blessing of the War Snapper])) //weapon daamge + muscle
			{
				if(have_effect($effect[Blessing of the War Snapper])==0 && have_effect($effect[grand Blessing of the War Snapper])==0 && have_effect($effect[glorious Blessing of the War Snapper])==0 && have_effect($effect[disdain of the War Snapper])==0)
				{
					use_skill($skill[Blessing of the War Snapper]);
					if(my_class()==$class[turtle tamer] && have_skill($skill[spirit boon]))
						cli_execute("trigger lose_effect, boon of the war snapper, cast 1 spirit boon");
				}
			}
			else if (have_skill($skill[Blessing of She-Who-Was])) //myst + spooky damage
			{
				if(have_effect($effect[Blessing of She-Who-Was])==0 && have_effect($effect[grand Blessing of She-Who-Was])==0 && have_effect($effect[glorious Blessing of She-Who-Was])==0 && have_effect($effect[disdain of She-Who-Was])==0)
				{
					use_skill($skill[Blessing of She-Who-Was]);
					if(my_class()==$class[turtle tamer] && have_skill($skill[spirit boon]))
						cli_execute("trigger lose_effect, boon of she-who-was, cast 1 spirit boon");
				}
			}
		}
		
			
		//ranged damage for moxies
		if(my_primestat()==$stat[moxie] && have_skill($skill[disco fever]))
			cli_execute("trigger lose_effect, disco fever, cast 1 disco fever");
		
		//reduce physical damage for everyone
		if (my_level()>3 && have_skill($skill[Shield of the Pastalord]))
			cli_execute("trigger lose_effect, Shield of the Pastalord, cast 1 Shield of the Pastalord");
			
		//summon a pasta thrall
		if(my_class()==$class[pastamancer])
		{
			if (contains_text(combat,"i") && have_skill($skill[Bind Spice Ghost]) && my_maxmp()>=250) //item drops, free spices, longer entangling noodles
			{
				if(my_thrall()!=$thrall[spice ghost])
					use_skill($skill[Bind Spice Ghost]);
			}
			else if (contains_text(combat,"n") && have_skill($skill[Bind Angel Hair Wisp])) //initiative, block crits, block attacks
			{
				if(my_thrall()!=$thrall[angel hair wisp])
					use_skill($skill[Bind Angel Hair Wisp]);
			}
			else if (contains_text(combat,"m") && have_skill($skill[Bind Lasagmbie])) //meat drops, spooky damage, spooky spell damage
			{
				if(my_thrall()!=$thrall[lasagmbie])
					use_skill($skill[Bind Lasagmbie]);
			}
			else if (have_skill($skill[Bind Spaghetti Elemental])) //stats, block first hit, spell damage
			{
				if(my_thrall()!=$thrall[Spaghetti Elemental])
					use_skill($skill[Bind Spaghetti Elemental]);
			}
			else if (my_primestat()==$stat[muscle] && have_skill($skill[Bind Undead Elbow Macaroni])) //upgrade mus to myst, weapon damage, crit chance
			{
				if(my_thrall()!=$thrall[Elbow Macaroni])
					use_skill($skill[Bind Undead Elbow Macaroni]);
			}
			else if (have_skill($skill[Bind Vampieroghi])) //life drain, remove negative effects, extra hp
			{
				if(my_thrall()!=$thrall[Vampieroghi])
					use_skill($skill[Bind Vampieroghi]);
			}
			else if (have_skill($skill[Bind Vermincelli])) //mp regen, poison foe, extra mp
			{
				if(my_thrall()!=$thrall[Vermincelli])
					use_skill($skill[Bind Vermincelli]);
			}
			else if (have_skill($skill[Bind Penne Dreadful])) //upgrade mox to mys, delevel, dr
			{
				if(my_thrall()!=$thrall[Penne Dreadful])
					use_skill($skill[Bind Penne Dreadful]);
			}
		}
		
		//level up the thrall
		if(my_class()==$class[pastamancer])
		{
			thrall thr=my_thrall();
			if(thr.level>1 && thr.level<9)
			{
				if(i_a("experimental carbon fiber pasta additive")>0)
				{
					if(!get_property("_pastaAdditive").to_boolean())
						use(1,$item[Experimental carbon fiber pasta additive]);
				}
				else
					cli_execute("pull 1 Experimental carbon fiber pasta additive");
			}
		}
		
		//soul sauce
		if(contains_text(combat,"n") && have_skill($skill[Soul Saucery]) && my_class()==$class[sauceror])
			cli_execute("trigger lose_effect, soulerskates, ash if(my_soulsauce() >= 25){cli_execute(\"cast 1 Soul Rotation\");}");
		
		if(my_class()==$class[sauceror] && have_skill($skill[Soul Saucery])) //if we get full, burn some off
			cli_execute("trigger lose_effect, Soul Funk, ash if(my_soulsauce() >= 100){cli_execute(\"cast 1 Soul Funk\");}");
			
	} else if(my_path() == "Avatar of Boris"){
		print("setting boris paths mood","lime");
		// Since we can only have one song, checking in the order of best priority.
		// Assume non-combats will always save the most turns, followed by items, then combats
		// Trigger Accompaniment if no other song is required to get some benefit.
		// No check is currently made for ML song, as this could significantly increase combat difficulty.
		// Return once a song has been cast to prevent overwriting.
		if (contains_text(combat,"-")) {
			print("BCC: Need less combat, brave Sir Clancy!", "purple");
			if (have_skill($skill[Song of Solitude])) cli_execute("trigger lose_effect, Song of Solitude, cast 1 Song of Solitude");
		} else if (contains_text(combat,"i")) {
			print("BCC: Need items!", "purple");
			if (have_skill($skill[Song of Fortune])) cli_execute("trigger lose_effect, Song of Fortune, cast 1 Song of Fortune");
		} else if (contains_text(combat, "m")) {
			print("BCC: Need meat!", "purple");
			if (have_skill($skill[Song of Fortune])) cli_execute("trigger lose_effect, Song of Fortune, cast 1 Song of Fortune");			
		} else if (contains_text(combat,"+")) {
			print("BCC: Need moar combat! BATTLE!", "purple");
			if (have_skill($skill[Song of Battle])) cli_execute("trigger lose_effect, Song of Battle, cast 1 Song of Battle");
		//SIMON: Added song of cockiness below
		//if we dont need anything, use cockiness if we have it
		} else if (have_skill($skill[Song of Cockiness ])) {
			print("BCC: Need to run a song! Cockiness chosen by default", "purple");
			cli_execute("trigger lose_effect, Song of Cockiness , cast 1 Song of Cockiness");
		// No other song was found, run song of Accompaniment to get some benefit from the song slot.
		} else if (have_skill($skill[Song of Accompaniment ])) {
			print("BCC: Need to run a song! Accompaniment chosen by default", "purple");
			cli_execute("trigger lose_effect, Song of Accompaniment , cast 1 Song of Accompaniment");
		}
		//SIMON: Added pep talk
		//if we have pep talk, turn it on
		if (have_skill($skill[pep talk]) && (!in_hardcore() || my_level()>6)) {
			print("BCC: Also choosing pep talk", "purple");
			cli_execute("trigger lose_effect, overconfident , cast 1 Pep Talk");
		}
	} else if(my_path() == "Zombie Slayer"){ //SIMON ADDED
		print("setting zombie paths mood","lime");
		if (contains_text(combat,"-")) {
			print("BCC: Need less combat, brave Sir Robin!", "purple"); 
			if (have_skill($skill[Disquiet Riot])) cli_execute("trigger lose_effect, Disquiet Riot, cast 1 Disquiet Riot");
		}
		if (contains_text(combat,"+")) {
			print("BCC: Need moar combat! WAAARGH!", "purple");
			if (have_skill($skill[Summon Horde])) cli_execute("trigger lose_effect, Waking the Dead, cast_summon_minion.ash");
		}
		if (contains_text(combat,"i")) {
			print("BCC: Need items!", "purple");
			if (have_skill($skill[Scavenge])) cli_execute("trigger lose_effect, Scavengers Scavenging, cast 1 Scavenge");
		}
		if (have_skill($skill[Ag-grave-ation]) && !contains_text(combat,"w")) // && (!in_hardcore() || my_level()>6))
		{
			print("BCC: Lets crank some ML", "purple");
			cli_execute("trigger lose_effect, Zomg WTF, cast 1 Ag-grave-ation");
		}
		if (have_skill($skill[Zombie Chow])){
			print("BCC: Cranking our familiar", "purple");
			cli_execute("trigger lose_effect, chow downed , cast 1 Zombie Chow");
		}
	} else if (my_path() == "Avatar of Jarlsberg") {
		print("setting jarlsberg paths mood","lime");
		if (contains_text(combat,"-")) {
			print("BCC: Need less combat, hide behind chocolate!", "purple");
			if (have_skill($skill[Chocolatesphere])) cli_execute("trigger lose_effect, Chocolatesphere, cast 1 Chocolatesphere");
//		} else if (contains_text(combat,"i")) {
//			//Nothing for items?
//		} else if (contains_text(combat, "m")) {
//			//Nothing for meat?		
		} else if (contains_text(combat,"+")) {
			print("BCC: Need moar combat! Coffee it is!", "purple");
			if (have_skill($skill[Coffeesphere])) cli_execute("trigger lose_effect, Coffeesphere, cast 1 Coffeesphere");
		}
		else if (contains_text(combat,"l")) 
		{
			print("BCC: These monsters are WEAK! Let's gristle them up!", "purple");
			//ML
			if (have_skill($skill[Gristlesphere])) cli_execute("trigger lose_effect, Gristlesphere, cast 1 Gristlesphere");
		}
		else
		{
			print("BCC: Default, buff defense with oil", "purple");
			//ML
			if (have_skill($skill[oilsphere])) cli_execute("trigger lose_effect, oilsphere, cast 1 oilsphere");
		}
	} else if (my_path() == "Avatar of Sneaky Pete") {
		if (contains_text(combat, "-")) {
			print("BCC: Need less combat, let's rev our engine!", "purple");
			if (have_skill($skill[rev engine]) && get_property("peteMotorbikeMuffler") == "Extra-Quiet Muffler") cli_execute("trigger lose_effect, Muffled, cast 1 Rev Engine");
			print("BCC: Need less combat, Let's get Broody!", "purple");
			if (have_skill($skill[Brood])) cli_execute("trigger lose_effect, Brooding, cast 1 Brood");
			if (i_a($item[pile of ashes]) > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[pile of ashes]) > 0 && have_effect($effect[ashen]) == 0) {use(1, $item[pile of ashes]);}");
		}
		if (contains_text(combat, "+")) {
			print("BCC: Need more combat, let's rev our engine", "purple");
			if (have_skill($skill[rev engine]) && get_property("peteMotorbikeMuffler") == "Extra-Loud Muffler") cli_execute("trigger lose_effect, Unmuffled, cast 1 Rev Engine");
		}
		if (contains_text(combat, "i")) {
			print("BCC: Need more items!", "purple");
			if (have_skill($skill[Check Hair]) && my_maxmp() > mp_cost($skill[Check Hair]) * 2) cli_execute("trigger lose_effect, Of course it looks great, cast 1 Check Hair");
		}
		if (contains_text(combat, "m")) {
			print("BCC: Need more meat. Spending a turn to change intrinsic (currently not implemented).", "purple");
			//if (have_skill($skill[Check Mirror]) && my_audience() >= 20) use_skill(1, $skill[Check Mirror]);
		}
		if (contains_text(combat, "n")) {
			print("BCC: Need more initative!", "purple");
			if (have_skill($skill[Live Fast])) cli_execute("trigger lose_effect, Living Fast, cast 1 Live Fast");
		}
		if (contains_text(combat, "l")) {
			print("BCC: Need tougher monsters. These are too weak!", "purple");
			if (have_skill($skill[Biker Swagger])) cli_execute("trigger lose_effect, Biker Swagger, cast 1 Biker Swagger");
		}
	}
	//buffs for all paths
	if (contains_text(combat,"i")) {
		if (haveElite() && my_meat() > 3000) cli_execute("trigger lose_effect, Peeled Eyeballs, use 1 Knob Goblin eyedrops");
	} 
	if (contains_text(combat, "m")) {
		if (haveElite() && my_meat() > 3000) cli_execute("trigger lose_effect, wasabi sinuses, use 1 Knob Goblin nasal spray");
	}
	if (contains_text(combat, "+") && i_a("cosmic calorie")>50) {
		cli_execute("trigger lose_effect, celestial saltiness, ash if(combat_rate_modifier() > -25.0){cli_execute(\"use 1 celestial au jus\");}");
	}
	if (contains_text(combat, "-") && i_a("cosmic calorie")>60) {
		cli_execute("trigger lose_effect, celestial camouflage, ash if(combat_rate_modifier() > -25.0){cli_execute(\"use 1 celestial squid ink\");}");
	}
	//"orchard" is code for "no seriously, lots of items"
	if (contains_text(combat, "orchard")) {
		if (i_a("cosmic calorie")>30) cli_execute("trigger lose_effect, celestial vision, use 1 celestial carrot juice");
		if (i_a("lavender candy hear") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[lavender candy heart]) > 0 && have_effect($effect[Heart of Lavender]) <= 1) {use(1, $item[lavender candy heart]);}");
		if (i_a("resolution: be happier") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[resolution: be happier]) > 0 && have_effect($effect[Joyful Resolve]) <= 1) {use(1, $item[resolution: be happier]);}");
		if (i_a("blue snowcone") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[blue snowcone]) > 0 && have_effect($effect[blue tongue]) <= 1 && have_effect($effect[red tongue]) == 0) {use(1, $item[blue snowcone]);}");
		if (have_skill($skill[Empathy of the Newt]) && my_maxmp() > mp_cost($skill[Empathy of the Newt]) * 2 && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
		if (i_a("green candy heart") > 0) cli_execute("trigger unconditional, ,ashq if(item_amount($item[green candy heart]) > 0 && have_effect($effect[Heart of Green]) <= 1) {use(1, $item[green candy heart]);}");
		if(i_a("polka pop")==0)
			cli_execute("pull 2 polka pop");
		if(i_a("polka pop")!=0 && have_effect($effect[polka face])==0)
			use(2,$item[polka pop]);
		get_kolhs_buff("items");
	}
	
	//if we are wearing smith gear, boost smithness
	//flask is best boost, so always try for that. Suggest food/drink after
	if(equipped_amount($item[A Light that Never Goes Out])>0 || equipped_amount($item[half a purse])>0)
	{
		//number of speen/flask/summons
		int ns=i_a("handful of smithereens");
		int nf=i_a("flaskfull of hollow");
		int nu=get_property("tomeSummons").to_int();
		
		//if we have not enough spleen of flasks, but some summons, use one
		while(nf==0 && ns<2 && nu>0)
		{
			print("summoning some smithness","purple");
			use_skill(1,$skill[summon smithsness]);
			ns=i_a("handful of smithereens");
			nf=i_a("flaskfull of hollow");
			nu=nu-1;
		}
		
		//if we have no flasks, but some spleen, make a flask
		if(nf==0 && ns>2)
		{
			cli_execute("create flaskfull of hollow");
			nf=nf+1;
			ns=ns-2;
		}
		
		//if we have a flask now, put it on mood
		if(nf>0)
			cli_execute("trigger lose_effect, merry smithsness, use 1 flaskfull of hollow");
			
		//if we have smithereens left, suggest the user eats/drink/snorts them
		if(ns>0 && !get_property("_smith_food_suggested").to_boolean() && ((fullness_limit() - my_fullness())>=2 || (inebriety_limit() - my_inebriety())>=2 ||  (spleen_limit() - my_spleen_use())>=1 ) )
		{
			set_property("_smith_food_suggested","true");
			abort("Maybe try eating a \"miserable pie\", drinking a \"Strikes Again Bigmouth\" or snorting some smithereens to boost smithsness. (total smithereens = "+ns+")");
		}
	}
	
}

//Where is it best to level?
location level_location(int value) {
	location best = $location[The Haunted pantry];
	int one;
	int two = safeMox(best);
	location preferred;
	switch(my_primestat()) {
		case $stat[Muscle]: preferred = $location[The Haunted Gallery];
		case $stat[Mysticality]: preferred = $location[The Haunted Bathroom];
		case $stat[Moxie]: preferred = $location[The Haunted Ballroom];
	}
	//my_buffedstat(my_primestat())
	if (value < 120 || !can_adv(preferred)) {
	foreach loc in $locations[The Sleazy Back Alley, The Haunted Pantry, The Outskirts of Cobb's Knob, The Spooky Forest, A Barroom Brawl, 8-Bit Realm, 
			The Bat Hole Entrance, Guano Junction, The Batrat and Ratbat Burrow, The Beanbat Chamber, Cobb's Knob Kitchens, Cobb's Knob Barracks, Cobb's Knob Treasury, 
			Cobb's Knob Harem, The Enormous Greater-Than Sign, The Dungeons of Doom, Itznotyerzitz Mine, The Black Forest, The Knob Shaft, Cobb's Knob Laboratory, Cobb's Knob Menagerie\, Level 1, 
			Cobb's Knob Menagerie\, Level 2, Cobb's Knob Menagerie\, Level 3, Hippy Camp, Frat House, The Obligatory Pirate's Cove, The Castle in the Clouds in the Sky (Basement), The Hole in the Sky, The Haunted Library, The Haunted Gallery, 
			The Haunted Ballroom, Inside the Palindome, Tower Ruins, The Oasis, The Upper Chamber, The Middle Chamber, Thugnderdome, 
			Outskirts of Camp Logging Camp, Camp Logging Camp, Post-Quest Bugbear Pens, The Bugbear Pen, The Degrassi Knoll Garage, The \"Fun\" House, 
			Pre-Cyrpt Cemetary, Post-Cyrpt Cemetary, The Goatlet, Lair of the Ninja Snowmen, The eXtreme Slope, Whitey's Grove, The Laugh Floor, 
			Infernal Rackets Backstage, Pandamonium Slums, The Valley of Rof L'm Fao, The Penultimate Fantasy Airship, The Road to the White Citadel, The Haunted Kitchen, The Haunted Conservatory, 
			The Haunted Billiards Room, The Haunted Bathroom, The Haunted Bedroom, The Icy Peak, Barrrney's Barrr, The F'c'le, The Poop Deck, Belowdecks]
		{
			print("checking "+loc,"blue");
			if (can_adv(loc)) {
				one = safeMox(loc);
				print("can adv there. It's safemox is "+one+" compared to current best "+two+" and limit "+value,"blue");
				if (one == 0 || (one < value && one > two)) {
					best = loc;
					two = safeMox(best);
				}
			}
		}
	} else {
		return preferred;
	}
	return best;
}

boolean levelMe(int sMox, boolean needBaseStat) {
	boolean canBallroom() {
		return get_property("lastBallroomUnlock") == my_ascensions();
	}

	boolean canBarr() {
		if (i_a("pirate fledges") > 0) return true;
		if (i_a("eyepatch") > 0 && i_a("swashbuckling pants") > 0 && i_a("stuffed shoulder parrot") > 0) return true;
		return false;
	}

	print("BCC: levelMe("+sMox+", "+to_string(needBaseStat)+") called.", "fuchsia");
	if (bcasc_ignoreSafeMoxInHardcore && needBaseStat == false) {
		//SIMON: This fucks up our gear etc even if we are about to decide not to level
		//buMax();
		print("BCC: But we don't care about safe moxie so we won't bother.", "purple");
		return true;
	}		
	
	//In softcore/casual we'll always assume we're strong enough to wtfpwn everything. 
	if (!needBaseStat && !in_hardcore()) return true; 
	
	if (have_effect($effect[Beaten Up]) > 0) {
		cli_execute("uneffect beaten up");
	}
	if (have_effect($effect[Beaten Up]) > 0) { abort("Please cure beaten up"); }

	//Uneffect poisoning since it screws with the calculation of how many buffed stats I need to level
	if (have_effect(to_effect(436)) > 0 || have_effect(to_effect(284)) > 0 || have_effect(to_effect(283)) > 0 || 
			have_effect(to_effect(282)) > 0 || have_effect(to_effect(264)) > 0 || have_effect(to_effect(8)) > 0) {
		use(1, $item[anti-anti-antidote]);
	}
	if (have_effect(to_effect(436)) > 0 || have_effect(to_effect(284)) > 0 || have_effect(to_effect(283)) > 0 || 
			have_effect(to_effect(282)) > 0 || have_effect(to_effect(264)) > 0 || have_effect(to_effect(8)) > 0) {
		abort("Please cure your poisoning");
	}
	
	if (needBaseStat) {
		if (my_basestat(my_primestat()) >= sMox) return true;
		print("Need to Level up a bit to get at least "+sMox+" base Primestat", "fuchsia");
		//SIMON: This fucks up our gear etc even if we are about to decide not to level
		//buMax();
	} else {
		//SIMON: This fucks up our buffs etc even if we are about to decide not to level
		//buMax();
		//setMood("");
		//cli_execute("mood execute");

		int extraMoxieNeeded = sMox - my_buffedstat(my_primestat());
		if (extraMoxieNeeded <= 0) return true;
		print("Need to Level up a bit to get at least "+sMox+" buffed Primestat. This means getting "+extraMoxieNeeded+" Primestat.", "fuchsia");
		sMox = my_basestat(my_primestat()) + extraMoxieNeeded;
		
		if (my_primestat() == $stat[Mysticality]) {
			//Don't level for buffed stat AT ALL above level 10
			if (my_level() >= 10) {
				print("BCC: But, we're a myst class and at or over level 10, so we won't bother with buffed stats.", "fuchsia");
				return true;
			}
			
			//Because of the lack of need of +mainstat, we'll only care if we need 20 or more. 
			extraMoxieNeeded = extraMoxieNeeded - 20;
			print("BCC: But, we're a myst class, so we don't really mind about safe moxie that much. We'll only try to get "+sMox+" instead.", "fuchsia");
			if (extraMoxieNeeded <= 0) return true;
		}
		
		if (my_path() == "Way of the Surprising Fist") {
			//Because of the lack of need of +mainstat, we'll only care if we need 20 or more. 
			extraMoxieNeeded = extraMoxieNeeded - 20 - (my_level() * 3);
			print("BCC: But, we're in a fist run, so we don't really mind about safe moxie that much. We'll only try to get "+sMox+" instead.", "fuchsia");
			if (extraMoxieNeeded <= 0) return true;
		}
	}
	cli_execute("goal clear; goal set "+sMox+" "+to_string(my_primestat()));
	
	//SIMON ADDED LINES BELOW
	//seems to only work second time
	vamp_out();
	vamp_out();
	
	location levelHere;
	switch (my_primestat()) {
		case $stat[Muscle] :
			if (my_buffedstat($stat[Muscle]) < 120 || !can_adv($location[the haunted gallery])) {
				print("I need "+sMox+" base muscle (going levelling)", "fuchsia");
				if(to_boolean(get_property("bcasc_dontLevelInTemple")))
					abort("BCC: You want to handle levelling yourself.");
				else {
					setMood("");
					setFamiliar("");
					levelHere = level_location(my_buffedstat(my_primestat()));
					//place florist friar plants
					choose_all_plants("", levelHere);
					
					return bumMiniAdv(my_adventures(), levelHere);
				}
			} else {
				setMood("-");
				setFamiliar("");
				print("I need "+sMox+" base muscle (going to Gallery)", "fuchsia");
				set_property("choiceAdventure89","6"); // ignore maidens
				
				//Get as many clovers as possible. The !capture is so that it doesn't abort on failure. 
				print("BCC: Attempting to get clovers to level with. (Don't worry - if don't want to use them to level, we won't).", "purple");
				cloversAvailable();
				
				if (cloversAvailable() > 1 && get_property("bcasc_doNotCloversToLevel") != "true") {
					print("BCC: Going to use clovers to level.", "purple");
					//First, just quickly use all ten-leaf clovers we have. 
					if(my_path() != "Bees Hate you") {
						//First, just quickly use all ten-leaf clovers we have. 
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("use * ten-leaf clover");
						}
					
						while (my_basestat($stat[Muscle]) < sMox && item_amount($item[disassembled clover]) > 1) {
							if (my_adventures() == 0)
							{
								cli_execute("shower "+my_primestat());
								abort("No adventures left :(");
							}
							print("BCC: We have "+item_amount($item[disassembled clover])+" clovers and are using one to level.", "purple");
							use(1, $item[disassembled clover]);
							visit_url("adventure.php?snarfblat=394&confirm=on");
						}
					} else {
						//Bees hate broken clovers so use the closet instead
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("closet put * ten-leaf clover");
						}
					
						while (my_basestat($stat[Muscle]) < sMox && closet_amount($item[ten-leaf clover]) > 1) {
							if (my_adventures() == 0)
							{
								cli_execute("shower "+my_primestat());
								abort("No adventures left :(");
							}
							print("BCC: We have "+closet_amount($item[ten-leaf clover])+" clovers and are using one to level.", "purple");
							take_closet(1, $item[ten-leaf clover]);
							visit_url("adventure.php?snarfblat=394&confirm=on");
						}
					}	
				}
				if(my_basestat(my_primestat()) < sMox)
				{
					//place florist friar plants
					choose_all_plants("", $location[The Haunted Gallery]);
					
					return bumMiniAdv(my_adventures(), $location[The Haunted Gallery]);
				}
			}
		break;
		
		case $stat[Mysticality] :
			if (my_buffedstat($stat[Mysticality]) < 80 || !can_adv($location[the haunted bathroom])) {
				print("I need "+sMox+" base Mysticality (going levelling)", "fuchsia");
				if(to_boolean(get_property("bcasc_dontLevelInTemple")))
					abort("BCC: You want to handle levelling yourself.");
				else {
					setMood("");
					setFamiliar("");
					levelHere = level_location(my_buffedstat(my_primestat()));
					//place florist friar plants
					choose_all_plants("", levelHere);
					
					return bumMiniAdv(my_adventures(), levelHere);
				}
			} else {
				setMood("-");
				setFamiliar("");
				print("I need "+sMox+" base Mysticality (going to Bathroom)", "fuchsia");
				
				//Get as many clovers as possible. The !capture is so that it doesn't abort on failure. 
				print("BCC: Attempting to get clovers to level with. (Don't worry - if don't want to use them to level, we won't).", "purple");
				cloversAvailable();
		
				set_property("choiceAdventure105","1");
				set_property("choiceAdventure402","2");
				if (cloversAvailable() > 1 && get_property("bcasc_doNotCloversToLevel") != "true") {
					print("BCC: Going to use clovers to level.", "purple");
					//First, just quickly use all ten-leaf clovers we have. 
					if(my_path() != "Bees Hate you") {
						//First, just quickly use all ten-leaf clovers we have. 
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("use * ten-leaf clover");
						}
					
						while (my_basestat($stat[Mysticality]) < sMox && item_amount($item[disassembled clover]) > 1) {
							if (my_adventures() == 0)
							{
								cli_execute("shower "+my_primestat());
								abort("No adventures left :(");
							}
							print("BCC: We have "+item_amount($item[disassembled clover])+" clovers and are using one to level.", "purple");
							use(1, $item[disassembled clover]);
							visit_url("adventure.php?snarfblat=392&confirm=on");
						}
					}
					else {
						//Bees hate broken clovers so use the closet instead
						if (item_amount($item[ten-leaf clover]) > 0) {
							cli_execute("closet put * ten-leaf clover");
						}
					
						while (my_basestat($stat[Mysticality]) < sMox && closet_amount($item[ten-leaf clover]) > 1) {
							if (my_adventures() == 0)
							{
								cli_execute("shower "+my_primestat());
								abort("No adventures left :(");
							}
							print("BCC: We have "+closet_amount($item[ten-leaf clover])+" clovers and are using one to level.", "purple");
							take_closet(1, $item[ten-leaf clover]);
							visit_url("adventure.php?snarfblat=392&confirm=on");
						}
					}						
				}
				if(to_int(get_property("choiceAdventure105")) != 1)
					set_property("choiceAdventure105",1);
				set_property("choiceAdventure882", 1); //get towel
				if(my_basestat(my_primestat()) < sMox)
				{
					//place florist friar plants
					choose_all_plants("", $location[The Haunted Bathroom]);
					
					return bumMiniAdv(my_adventures(), $location[The Haunted Bathroom]);
				}
			}
		break;
		
		case $stat[Moxie] :
			if (my_buffedstat($stat[Moxie]) < 90 || my_basestat($stat[mysticality]) < 25 || (!canBarr() && !canBallroom())) {
				print("I need "+sMox+" base Moxie (going levelling)", "fuchsia");
				if(to_boolean(get_property("bcasc_dontLevelInTemple")))
					abort("BCC: You want to handle levelling yourself.");
				else {
					setMood("");
					setFamiliar("");
					levelHere = level_location(my_buffedstat(my_primestat()));
					//place florist friar plants
					choose_all_plants("", levelHere);
					
					return bumMiniAdv(my_adventures(), levelHere);
				}
			} else if (my_path() != "way of the surprising fist" && my_buffedstat($stat[Moxie]) < 120 && canBarr()) {
				setMood("-i");
				setFamiliar("");
				//There's pretty much zero chance we'll get here without the swashbuckling kit, so we'll be OK.
				if(i_a("pirate fledges") == 0 || my_basestat($stat[mysticality]) < 60)
					buMax("+outfit swashbuckling getup");
				else
					buMax("+equip pirate fledges");
				//place florist friar plants
				choose_all_plants("", $location[Barrrney's barrr]);
				
				return bumMiniAdv(my_adventures(), $location[Barrrney's Barrr]);
			} else {
				setMood("-i");
				setFamiliar("itemsnc");
				print("I need "+sMox+" base moxie", "fuchsia");
				
				//Get as many clovers as possible. The !capture is so that it doesn't abort on failure. 
				print("BCC: Attempting to get clovers to level with. (Don't worry - if don't want to use them to level, we won't).", "purple");
				cloversAvailable();
				
				//If we're above level 11, then use clovers as necessary. 
				if (my_level() >= 10) {
					if (my_adventures() == 0)
					{
						cli_execute("shower "+my_primestat());
						abort("No adventures left :(");
					}
					if (cloversAvailable() > 1 && get_property("bcasc_doNotCloversToLevel") != "true") {
						print("BCC: Going to use clovers to level.", "purple");
						if(my_path() != "Bees Hate you")
						{
							//First, just quickly use all ten-leaf clovers we have. 
							if (item_amount($item[ten-leaf clover]) > 0) {
								cli_execute("use * ten-leaf clover");
							}
							while (my_basestat($stat[Moxie]) < sMox && item_amount($item[disassembled clover]) > 1) {
								if (my_adventures() == 0)
								{
									cli_execute("shower "+my_primestat());
									abort("No adventures left :(");
								}
								print("BCC: We have "+item_amount($item[disassembled clover])+" clovers and are using one to level.", "purple");
								use(1, $item[disassembled clover]);
								visit_url("adventure.php?snarfblat=395&confirm=on");
							}
						}
						else
						{
							//Bees hate broken clovers so use the closet instead
							if (item_amount($item[ten-leaf clover]) > 0) {
								cli_execute("closet put * ten-leaf clover");
							}
							while (my_basestat($stat[Moxie]) < sMox && closet_amount($item[ten-leaf clover]) > 1) {
								if (my_adventures() == 0)
								{
									cli_execute("shower "+my_primestat());
									abort("No adventures left :(");
								}
								print("BCC: We have "+closet_amount($item[ten-leaf clover])+" clovers and are using one to level.", "purple");
								take_closet(1, $item[ten-leaf clover]);
								visit_url("adventure.php?snarfblat=395&confirm=on");
							}
						}
					}
				}
			
				cli_execute("goal clear");
				setFamiliar("itemsnc");
				while (my_basestat($stat[Moxie]) < sMox) {
					if (my_adventures() == 0)
					{
						cli_execute("shower "+my_primestat());
						abort("No adventures left :(");
					}
					if ((my_buffedstat($stat[Moxie]) < 130) && canMCD() && !(bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) cli_execute("mcd 0");
					if (item_amount($item[dance card]) > 0) {
						use(1, $item[dance card]);
						//place florist friar plants
						choose_all_plants("", $location[The Haunted ballroom]);
						
						bumMiniAdv(4, $location[The Haunted Ballroom]);
					} else {
						//place florist friar plants
						choose_all_plants("", $location[The Haunted ballroom]);
						
						bumMiniAdv(1, $location[The Haunted Ballroom]);
					}
				}
				if(my_basestat($stat[Moxie]) < sMox) return true;
			}
		break;
	}
	return false;
}
boolean levelMe(int sMox) { return levelMe(sMox, false); }

//simon added use putty
void use_putty()
{
	boolean have_copy = (i_a("rain-doh box full of monster") + i_a("spooky putty monster") + i_a("Wax bugbear")) > 0;
	while(have_copy && my_adventures() > 0)
	{
		//choose putty type, preference for raindoh
		item putty = $item[spooky putty monster];
		monster mob = to_monster(get_property("spookyPuttyMonster"));
		if(i_a("rain-doh box full of monster")>0)
		{
			putty = $item[rain-doh box full of monster];
			mob = to_monster(get_property("rainDohMonster"));
		}
		if(i_a("wax bugbear")>0)
		{
			putty = $item[wax bugbear];
			mob = to_monster(get_property("waxMonster"));
		}
	
		//decide if we should reputty, and get dressed appropriately, based on specific monster?
		boolean reputty = putties_possible();
		print("We have "+ (reputty ? "some " : "no ") +"putties left","lime");
		if(reputty)
		{
			switch(mob)
			{
				case $monster[lobsterfrogman]:
					setMood("");
					buMax();
					setFamiliar("");
					//we need to reputty up to the penultimate barrel
					int putty_barrels=4;
					reputty = i_a("barrel of gunpowder")<putty_barrels && bcasc_doSideQuestBeach && !to_boolean(get_property("sidequestLighthouseCompleted"));
					break;
				case $monster[morbid skull]:
					setMood("i");
					buMax();
					setFamiliar("items");
					reputty = (i_a("digital key")<1 && i_a("white pixel")<26); //only putty if we need all 5 pixels
					break;
				case $monster[ghost]:
					setMood("i");
					buMax();
					setFamiliar("items");
					reputty = (i_a("digital key")<1 && i_a("white pixel")<26); //only putty if we need all 5 pixels
					break;

				case $monster[gaudy pirate]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = (i_a("talisman o nam")<1 && (i_a("snakehead charm") + i_a("gaudy key"))<1);
					break;
				case $monster[dirty old lihc]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("cyrptNicheEvilness"))>=30;
					break;
				case $monster[modern zmobie]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("cyrptAlcoveEvilness"))>=30;
					break;
//				case $monster[smut orc pervert]: <no longer puttyable>
//					setMood("");
//					buMax();
//					setFamiliar("");
//					reputty = to_int(get_property("chasmBridgeProgress")) < 25;
//					break;
				//bugbears for invasion. can use crayon shavings
				case $monster[Scavenger bugbear]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataWasteProcessing")) < 3;
					break;
				case $monster[hypodermic bugbear]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataMedbay")) < 3;
					break;
				case $monster[batbugbear]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataSonar")) < 3;
					break;
				case $monster[bugbear scientist]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataScienceLab")) < 6;
					break;
				case $monster[bugaboo]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataMorgue")) < 6;
					break;
				case $monster[Black Ops Bugbear]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataSpecialOps")) < 6;
					break;
	 			case $monster[Battlesuit Bugbear type]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataEngineering")) < 9;
					break;
				case $monster[ancient unspeakable bugbear]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataNavigation")) < 9;
					break;
				case $monster[trendy bugbear chef]:
					setMood("");
					buMax();
					setFamiliar("");
					reputty = to_int(get_property("biodataGalley")) < 9;
					break;	
				default:
					abort("Unrecognised mob when choosing reputty: "+mob);
			}
		}
		set_combat_macro(reputty);
		cli_execute("mood execute");
		
		//fight the putty monster
		print("Fighting "+mob+" from putty. We are "+ (reputty ? " " : "not ") +"going to reputty","lime");
		visit_url("inv_use.php?pwd=&which=3&whichitem="+to_int(putty));
		bumRunCombat((mob == $monster[lobsterfrogman]) ? "consultLFM" : "");
		
		//do we have another copy to repeat the process with?
		have_copy = (i_a("rain-doh box full of monster") + i_a("spooky putty monster")) > 0;
	}
	set_combat_macro();
}

boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme, string combat, string consultScript, int maxAdvs) {
	//Prepare food if appropriate. 
	omNomNom();
	
	int sMox = safeMox(loc);
	buMax(maxme, sMox);
	
	sellJunk();
	setFamiliar(famtype);
	
	//First, we'll check the faxes. 
	monster f = whatShouldIFax();
	if (f != $monster[none]) {
		familiar old = my_familiar();
		print("BCC: We are going to fax a "+to_string(f), "purple");
		
		if (faxMeA(f)) {
			set_property("bcasc_lastFax", today_to_string());
			if (f == $monster[sleepy mariachi]) {
				setFamiliar("hebo");
				clear_combat_macro();
				visit_url("inv_use.php?pwd=&which=3&whichitem=4873");
				bumRunCombat("consultHeBo");
			}
			//SIMON : Commented below
//			if (f == $monster[rampaging adding machine]) abort("Can't fight the adding machine. Do this manually.");
			if (f == $monster[lobsterfrogman]) {setFamiliar("obtuseangel_simon"); }
			//Have to do this rather than use() because otherwise, mafia fights immediately.
			visit_url("inv_use.php?pwd=&which=3&whichitem=4873");
			bumRunCombat((f == $monster[lobsterfrogman]) ? "consultObtuse" : "");
		} else {
			print("BCC: The monster faxing failed for some reason. Let's continue as normal though.", "purple");
		}
		use_familiar(old);
	} else {
		print("BCC: Nothing to fax according to whatShouldIFax", "purple");
	}
	
	//simon added use of putty before advs
	use_putty();
	print("bumadv finished setting use_putty()","lime");
	print("current goals are "+goals,"lime");
	//if goal is BURTS and we have crayon shavings, force the putty combat macro
	if(my_path()=="bugbear invasion" && contains_text(goals,"BURT") && i_a("crayon shavings")>0)
	{
		print("forcing putty use","lime");
		set_combat_macro(true);
	}
	
	//Make sure we use free runaways for the Stomping Boots if we are to try and run away, but not if we are trying for a 100% run
	if (consultScript == "consultRunaway" && bcasc_100familiar == "") {
		if (have_path_familiar($familiar[Pair of Stomping Boots]))
		{
			clear_combat_macro();
			use_familiar($familiar[Pair of Stomping Boots]);
			//maximize weight, not fam equip
			maximize("familiar +familiar weight",false);
			if(i_a("moveable feast")>0)
				use(1,$item[moveable feast]);
		}
		else if (have_path_familiar($familiar[Frumious Bandersnatch]))
		{
			clear_combat_macro();
			use_familiar($familiar[Frumious Bandersnatch]);
			//maximize weight, not fam equip
			maximize("familiar +familiar weight",false);
			if(i_a("moveable feast")>0)
				use(1,$item[moveable feast]);
		}
	}
		
	//Do we have a HeBo, and are we blocked from using it by a 100% run? Have to do this first, because we re-set the goals below.
	if ((my_path() != "Bees Hate You") && (consultScript == "consultHeBo") && (my_familiar() != $familiar[He-Boulder]) && have_effect($effect[Everything Looks Yellow]) == 0) {
		if (contains_text(visit_url("campground.php?action=bookshelf"), "Summon Clip Art")) {
			if(i_a("unbearable light") == 0)
			{
				print("BCC: We are getting an unbearable light, which the script prefers to pumpkin bombs where possible.", "purple");
				cli_execute("make 1 unbearable light");
			}
		} else {		
			print("BCC: We don't have the HeBo equipped, so we're either on a 100% run or you just don't have one. Trying a pumpkin bomb. If you have one, we'll use it.", "purple");
			if (get_campground()[$item[pumpkin]] > 0) {
				 //Hit the pumpkin patch, but only pick pumpkins if we have pumpkins to pick
				visit_url("campground.php?action=garden&pwd="+my_hash());
			}
			
			//Have a quick check for a KGF first. 
			if (i_a("pumpkin bomb") == 0 && i_a("pumpkin") > 0 && i_a("knob goblin firecracker") == 0) {
				cli_execute("conditions clear; conditions set 1 knob goblin firecracker");
				adventure(my_adventures(), $location[the outskirts of cobb's knob]);
			}
			
			if (((i_a("pumpkin") > 0 && i_a("knob goblin firecracker") > 0)) || i_a("pumpkin bomb") > 0) {
				if (i_a("pumpkin bomb") == 0) { cli_execute("make pumpkin bomb"); }
			}
			//That's it. It's just about getting a pumpkin bomb in your inventory. Nothing else.
		}
		if((my_familiar() == $familiar[he-boulder] || i_a("unbearable light")>0 || i_a("pumpkin bomb")>0) && have_effect($effect[Everything Looks Yellow]) == 0)
			clear_combat_macro();
	}

	//We initially set the MCD to 0 just in case we had it turned on before. 
	if (my_adventures() == 0)
	{
		cli_execute("shower "+my_primestat());
		abort("No adventures left :(");
	}
	if (canMCD() && !(bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) cli_execute("mcd 0");
	
	if (length(printme) > 0) {
		print("BCC: "+printme, "purple");
	}
	
	cli_execute("trigger clear");
	setMood(combat);

	cli_execute("mood execute");
	
	if (my_buffedstat(my_primestat()) < sMox && !bcasc_ignoreSafeMoxInHardcore && loc != $location[The Haunted Bedroom])        {
		//Do something to get more moxie.
		print("Need to Level up a bit to get "+sMox+" Mainstat", "fuschia");
		levelMe(sMox);
		//In case levelMe changed our outfit and we really need something.
		if (maxme != "")
			buMax(maxme, sMox);
	}
	cli_execute("mood execute");
	if (length(printme) > 0) {
	 	print("BCC: "+printme, "purple");
    }
	
	//Goals must be set after trying to levelme()
	cli_execute("goal clear");
	if (length(goals) > 0) {
		print("BCC: Setting goals of '"+goals+"'...", "lime");
		string[int] split_goals = split_string(goals, ", ");
		for i from 0 to count(split_goals) - 1
		{
			if (!contains_text(split_goals[i], "+"))
				cli_execute("goal set "+split_goals[i]);
			else
				cli_execute("goal add " + split_goals[i]);
		}			
			
		split_goals = get_goals();
		if(count(split_goals) == 0) {
			print("BCC: All goals have already been met, moving on.", "lime");
			return true;
		}
		
	}
	
	//Finally, check for and use the MCD if we can. No need to do this in 
	if (my_buffedstat(my_primestat()) > sMox) {
		print("BCC: We should set the MCD if we can.", "purple");
		//Check if we have access to the MCD
		setMCD(my_buffedstat(my_primestat()), sMox);
	}
	//Force to 0 in Junkyard
	if (loc == $location[Next to that Barrel with Something Burning in it] || loc == $location[Near an Abandoned Refrigerator] || loc == $location[Over Where the Old Tires Are] || loc == $location[Out By that Rusted-Out Car]) {
		print("BCC: We're adventuring in the Junkyard. Let's turn the MCD down...", "purple");
		if (canMCD()) cli_execute("mcd 0");
		//simon: check super structure
		if(equipped_amount($item[greatest american pants])>0 && have_effect($effect[super structure])<1)
		{
			print("And lets also put on super structure","lime");
			visit_url("inventory.php?action=activatesuperpants");
			visit_url("choice.php?pwd&whichchoice=508&option=2&choiceform2=Super+Structure");
		}
	}
	//Force to correct MCD levels in Boss Bat, Knob King and Bonderdagon
	int b, k, d;
	switch (my_primestat()) {
		case $stat[muscle]: b = 8; k = 0; d=10; break;
		case $stat[mysticality]: b = 4; k = 3; d=5; break;
		case $stat[moxie]: b = 4; k = 7; d=10; break;
	}
	if (canMCD() && loc == $location[The Boss Bat's Lair]) { cli_execute("mcd "+b); }
	if (canMCD() && loc == $location[Throne Room]) { cli_execute("mcd "+k); }
	if (canMCD() && loc == $location[Haert of the Cyrpt]) { cli_execute("mcd "+d); }
	
	int adventureThis = my_adventures();
	//If we set some given quantity of adventures, set this. 
	if (maxAdvs > 0) {
		adventureThis = maxAdvs;
	}
	
	//set relevant flavour of magic for zone
	if(have_skill($skill[Flavour of magic]))
	{
		//cold mobs
		if(loc==$location[The Icy Peak] || loc==$location[Lair of the Ninja Snowmen] || loc==$location[exposure esplanade] || loc==$location[McMillicancuddy's Pond])
		{
			if (have_effect($effect[Spirit of wormwood]) == 0) use_skill(1, $skill[Spirit of wormwood]);
		}
		//hot mobs
		else if(loc==$location[Burnbarrel Blvd.] || loc==$location[mcmillicancuddy's back 40] || loc==$location[The Dark neck of the woods] || loc==$location[The Dark heart of the woods] || loc==$location[The Dark elbow of the woods] || loc==$location[Infernal Rackets Backstage] || loc==$location[The Laugh Floor] || loc==$location[pandamonium slums] || loc==$location[cobb's knob kitchens] || loc==$location[The Haunted pantry] || loc==$location[The Outskirts of Cobb's Knob] || loc==$location[The Arid\, Extra-Dry Desert])
		{
			if (have_effect($effect[Spirit of bacon grease]) == 0) use_skill(1, $skill[Spirit of bacon grease]);
		}
		//sleaze mobs
		else if(loc==$location[The Battlefield (Hippy uniform)] || loc==$location[The Orcish Frat House (Bombed Back to the Stone Age)] || loc==$location[Frat House] || loc==$location[The Hole in the sky] || loc==$location[mcmillicancuddy's other back 40] || loc==$location[The Purple Light District] || loc==$location[The eXtreme Slope] || loc==$location[the \"fun\" house] || loc==$location[Tower Ruins] || loc==$location[The Obligatory Pirate's Cove] || loc==$location[The Road to the White Citadel]&& loc==$location[The Degrassi Knoll Gym]&& loc==$location[Anemone Mine]&& loc==$location[Cobb's Knob Harem])
		{
			if (have_effect($effect[Spirit of Peppermint]) == 0) use_skill(1, $skill[Spirit of Peppermint]);
		}
		//stench mobs
		else if(loc==$location[The Heap] || loc==$location[mcmillicancuddy's bog] || loc==$location[hippy camp] || loc==$location[The Hippy Camp (Bombed Back to the Stone Age)] || loc==$location[ The Battlefield (frat uniform)] || loc==$location[The Road to the White Citadel] || loc==$location[The F'c'le] || loc==$location[The eXtreme Slope] || loc==$location[The Haunted Pantry] || loc==$location[The Sleazy Back Alley] || loc==$location[the bugbear pen] || loc==$location[post-quest bugbear pens] || loc==$location[The hatching chamber] || loc==$location[The Feeding Chamber] || loc==$location[The Royal Guard Chamber] || loc==$location[The Filthworm Queen's Chamber])
		{
			if (have_effect($effect[Spirit of Peppermint]) == 0) use_skill(1, $skill[Spirit of Peppermint]);
		}
		//spooky mobs
		else if(loc==$location[The Ancient Hobo Burial Ground] || loc==$location[McMillicancuddy's Family Plot] || loc==$location[post-cyrpt cemetary] || loc==$location[pre-cyrpt cemetary] || loc==$location[The Spooky Gravy Burrow] || loc==$location[the bugbear pen] || loc==$location[post-quest bugbear pens] || loc==$location[The Haunted library] || loc==$location[The Haunted billiards room] || loc==$location[the \"fun\" house] || loc==$location[The Marinara Trench] || loc==$location[The Wreck of the Edgar Fitzsimmons] || loc==$location[The Haunted gallery] || loc==$location[The Haunted ballroom] || loc==$location[Spectral Pickle Factory] || loc==$location[the knob shaft] || loc==$location[The Haunted bathroom] || loc==$location[The Haunted bedroom] || loc==$location[The Haunted conservatory] || loc==$location[The Haunted kitchen] || loc==$location[The Spooky Forest] || loc==$location[The Haunted pantry] || loc==$location[The Oasis] || loc==$location[The Middle Chamber] || loc==$location[The Upper Chamber] || loc==$location[The Defiled nook] || loc==$location[The Defiled niche] || loc==$location[The Defiled cranny] || loc==$location[The Defiled alcove])
		{
			if (have_effect($effect[Spirit of garlic]) == 0) use_skill(1, $skill[Spirit of garlic]);
		}
	}
	
	//SIMON CHANGED TO SINGLE ADV LOOPING WITH PUTTIES
	boolean goals_done=false;
	boolean used_adv=true;
	while(my_adventures()>0 && !goals_done && used_adv)
	{
	
		//place florist friar plants
		print("a","lime");
		choose_all_plants(combat, loc);
		print("b","lime");
		betweenBattle();
		print("c","lime");
		use_putty();
		print("d","lime");
		
		if (can_interact()) {
			print("adventuring with consultCasual","purple");
			used_adv=adventure(1, loc, "consultCasual");
		} else if (consultScript != "") {
			print("adventuring with consult="+consultScript,"purple");
			clear_combat_macro();
			used_adv=adventure(1, loc, consultScript);
		} else if (my_primestat() == $stat[Mysticality] && in_hardcore()) {
			print("adventuring with consultMyst","purple");
			used_adv=adventure(1, loc, "consultMyst");
		} else {
			print("adventuring without consult function handle","purple");
			used_adv=adventure(1, loc);
		}
		print("e","lime");
		//if adventure hasn't autostopped, check goals
		goals_done=cli_execute("goals check");
		print("conditions check: "+goals_done,"lime");
		print("used adv: "+used_adv,"lime");
	}
	
	if (my_adventures() == 0)
	{
		cli_execute("shower "+my_primestat());
		abort("No adventures left :(");
	}
	else
		return true;
	return false; // Make the compiler happy...
}
boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme, string combat, string consultScript) { return bumAdv(loc, maxme, famtype, goals, printme, combat, consultScript, 0); }
boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme, string combat) { return bumAdv(loc, maxme, famtype, goals, printme, combat, ""); }
boolean bumAdv(location loc, string maxme, string famtype, string goals, string printme) { return bumAdv(loc, maxme, famtype, goals, printme, ""); }
boolean bumAdv(location loc, string maxme, string famtype, string goals) { return bumAdv(loc, maxme, famtype, goals, ""); }
boolean bumAdv(location loc, string maxme, string famtype) { return bumAdv(loc, maxme, famtype, "", ""); }
boolean bumAdv(location loc, string maxme) { return bumAdv(loc, maxme, "", "", ""); }
boolean bumAdv(location loc) { return bumAdv(loc, "", "", "", ""); }

boolean bumUse(int n, item i) {
	if (n > item_amount(i)) n = item_amount(i);
	if (n > 0) return use(n, i);
	return false;
}

/**********************************
* START THE ADVENTURING FUNCTIONS *
**********************************/

boolean bcasc8Bit() {
	if (checkStage("8bit")) return true;
	//SIMON CHANGED BELOW
//	if (!in_hardcore() || can_interact()) return checkStage("8bit", true);	
	if (can_interact() && !bcasc_RunSCasHC) return checkStage("8bit", true);
	if (my_path() == "Bugbear Invasion") return false;
	if (!need_key($location[8-bit Realm])) { 	
		checkStage("8bit", true);
		return true;
	}
	
	//can we get to Fear Man's Level?
	if(!contains_text(visit_url("campground.php"),"junggate_3"))
	{
		print("fear mans level not currently open","blue");
		if(get_property("_psychoJarUsed").to_boolean())
		{
			print("Can't use a crackpot mystic psycho jar because some other jar was already used.","red");
		}
		else
		{
			print("no psycho jar used yet","blue");
			if(i_a("jar of psychoses (The Crackpot Mystic)")<1)
			{
				print("dont have a crackpot jar yet","blue");
				if(i_a("psychoanalytic jar")>0)
				{
					print("making one","blue");
					visit_url("shop.php?whichshop=mystic&action=jung&whichperson=mystic");
				}
				else
				{
					print("Wanted to go to crackpot mystics psychoses but didn't have a jar","blue");
				}
			}
			//now use it
			if(i_a("jar of psychoses (The Crackpot Mystic)")>0)	
			{
				print("we have a crackpot jar, ;ets use it","blue");
				use(1,$item[jar of psychoses (The Crackpot Mystic)]);
			}
		}
	}
	boolean use_jar=contains_text(visit_url("campground.php"),"junggate_3");
	
	//Guarantee that we have an equippable 1-handed ranged weapon.
	if (my_primestat() == $stat[Moxie] && !use_jar) {
		while (i_a("disco ball") == 0) use(1, $item[chewing gum on a string]); 
	}
	
	while (i_a("digital key") == 0) {
		//First, we have to make sure we have at least one-handed moxie weapon to do this with. 	
		if (i_a("continuum transfunctioner") == 0) {
			visit_url("place.php?whichplace=forestvillage&action=fv_mystic");
			if (my_path() != "Zombie Slayer") {
				visit_url("choice.php?pwd&whichchoice=664&option=1&choiceform1=Sure%2C+old+man.++Tell+me+all+about+it.");
				visit_url("choice.php?pwd&whichchoice=664&option=1&choiceform1=Against+my+better+judgment%2C+yes.");
				visit_url("choice.php?pwd&whichchoice=664&option=1&choiceform1");
			}
		}
		if(use_jar)
		{
			print("going to fear man","blue");
			set_property("choiceAdventure644","3");
			bumAdv($location[Fear Man's Level], "+item drop", "items", "1 digital key", "Getting the digital key (from fear man)", "i");
		}
		else
		{
			print("going to 8 bit realm","blue");
			bumAdv($location[8-bit realm], "+equip continuum transfunctioner +item drop", "items", "1 digital key", "Getting the digital key (from 8 bit)", "i");
		}
	}
		
	if(have_effect($effect[consumed by fear])>0)
		cli_execute("hottub");
	if(have_effect($effect[consumed by fear])>0)
		cli_execute("uneffect consumed by fear");
	if (i_a("digital key") > 0) checkStage("8bit", true);
	return true;
}

boolean bcascAirship() {
	buffer page = visit_url("place.php?whichplace=plains");
	boolean planted = contains_text(page, "climb_beanstalk.gif");
	if (checkStage("airship")) return true;
	
	if (can_interact() && i_a("enchanted bean") == 0 && !planted) buy(1, $item[enchanted bean]);
	
	while (i_a("enchanted bean") == 0 && !planted)
		bumAdv($location[The Beanbat Chamber], "", "items", "1 enchanted bean", "Getting an Enchanted Bean");
		
	//Plant the bean ourselves in order to avoid problems with BHY runs (and potential future paths)
	if(!planted)
	 	page = visit_url("place.php?whichplace=plains&action=garbage_grounds");

	
	string airshipGoals = "1 metallic A, 1 S.O.C.K.";
	if (!in_hardcore() || my_path() == "Bees Hate You" || my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Bugbear Invasion" || my_path() == "Zombie Slayer") airshipGoals = "1 S.O.C.K.";
 	
	if(my_path()=="Bugbear Invasion" && to_int(get_property("biodataEngineering"))<9)
		airshipGoals=", +"+(9 - to_int(get_property("biodataEngineering"))) + " BURT";
	
	if(i_a("S.O.C.K.")<1)
		setMood("-i");
		cli_execute("mood execute");
		if(combat_rate_modifier() > -25.0)
			cli_execute("swim sprints");
		else 
			cli_execute("swim laps");
		if(combat_rate_modifier() > -25.0)
			eat_hot_dog("Ghost dog",$location[The Penultimate Fantasy Airship]);
	while (i_a("S.O.C.K.")<1) {
		if(i_a("model airship")<1)
			set_property("choiceAdventure182", "4"); //airship
		else
			set_property("choiceAdventure182", "2"); //chest
		bumAdv($location[The Penultimate Fantasy Airship], "", "itemsnc", airshipGoals, "Opening up the Castle by adventuring in the Airship", "-i");
	}
	
	cli_execute("use * fantasy chest");
	if (i_a("S.O.C.K.")>0) {
		checkStage("airship", true);
		return true;
	}
	return false;
}

boolean bcascBats1() {
	string[int] clover_result;
	boolean stenchOK(){
		//SIMON CHANGED
		boolean safe=false;
		if (my_primestat() == $stat[mysticality]) {
			safe=elemental_resistance($element[stench]) > 5;
		}
		safe=elemental_resistance($element[stench]) > 0;
		
		if(safe)
			return true;
		//try to use gap buff
		if(available_amount($item[greatest american pants])>0)
		{
			//10 turns should be enough
			equip($item[greatest american pants]);
			visit_url("inventory.php?action=activatesuperpants");
			visit_url("choice.php?pwd&whichchoice=508&option=2&choiceform2=Super+Structure");
			
			cli_execute("refresh effects");
			if(have_effect($effect[super structure])>0)
				return true;
		}
		return false;
	}

	if (checkStage("bats1")) return true;
	if (use(3, $item[sonar-in-a-biscuit])) {}
	//Guano
	if (!contains_text(visit_url("questlog.php?which=2"), "slain the Boss Bat")) {
		//There's no need to get the air freshener if you have the Stench Resist Skill
		if (!stenchOK()) {
			buMax("+1000 stench res");
			//Check it NOW (i.e. see if we have stench resistance at all, and try the exotic parrot if you don't.
			if(!stenchOK() && have_path_familiar($familiar[Exotic Parrot])) {
				cli_execute("familiar parrot");
				buMax("+1000 familiar weight");
			}
			//Check it NOW (i.e. see if we have stench resistance at all, and get an air freshener if you don't.
			if (!stenchOK()) {
				while (!have_skill($skill[Diminished Gag Reflex]) && (i_a("Pine-Fresh air freshener") == 0))
					bumAdv($location[the bat hole entrance], "", "items", "1 Pine-Fresh air freshener", "Getting a pine-fresh air freshener.");
			}
			buMax("+1000 stench res");
			if(!stenchOK() && (bcasc_100familiar == "" || bcasc_100familiar.to_familiar() == $familiar[Exotic Parrot]) && have_path_familiar($familiar[Exotic Parrot])) {
				//SIMON CHANGED
				abort("There is some error getting stench resist - perhaps you don't have enough Myst to equip the air freshener? Please manually sort this out.");
				return false;
			}
		}
		
		//need to open boss
		if(!contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg4"))
		{
			//possible to get a snow shovel?
			if(contains_text(visit_url("campground.php"),"wintergarden"))
			{
				//get + use snow shovel
				if(i_a("snow berries")>3 && i_a("ice harvest")>0)
				{
					create(1,$item[snow shovel]);
					string str=visit_url("inv_use.php?which=2&whichitem=7085");
					//use(1,$item[snow shovel]);
				}
				else //wait until we can get one (tomorrow)
				{
					return false;
				}
			}
		}
		
		buMax("+10 stench res");
		if (my_path() != "Bees Hate You") {
			while (item_amount($item[sonar-in-a-biscuit]) < 1 && !contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg4")) {
				//Let's use a clover if we can.
				print("trying to get sonars ","lime");
				if (i_a("sonar-in-a-biscuit") == 0 && cloversAvailable(true) > 0) {
					print("trying to clover bat hole","lime");
					clover_result[0] = visit_url("adventure.php?snarfblat=31&confirm=on");
					if(!contains_text(clover_result[0], "but you see a few biscuits left over from whatever bizarre tea party")) {
						map_to_file(clover_result, "BCCDebug.txt");
						abort("BCC: There was a problem using your clover (probably not enough stench detection, page written to data/bccdebug.txt). Please try it manually.");
					}
				} else {
					print("adventuring for sonars","lime");
					bumAdv($location[Guano Junction], "+10stench res", "items", "1 sonar-in-a-biscuit", "Getting a Sonars");
				}
				if (cli_execute("use * sonar-in-a-biscuit")) {}
			}
			if (cli_execute("use * sonar-in-a-biscuit")) {}
		} else {
			//The screambat should show up every 8 turns, but make it 9 to account for potential bees
			if(contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg1")) {
				print("BCC: Hunting for the first screambat.");
				repeat {
					//place florist friar plants
					choose_all_plants("i", $location[guano junction]);
					
					bumminiAdv(1, $location[Guano Junction], "");
				} until(last_monster() == $monster[screambat]);
			}
			if(contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg2")) {
				print("BCC: Hunting for a second screambat.");
				repeat {
					//place florist friar plants
					choose_all_plants("i", $location[The Batrat and Ratbat Burrow]);
					
					bumminiAdv(1, $location[The Batrat and Ratbat Burrow], "");
				} until(last_monster() == $monster[screambat]);
			}
			if(contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg3")) {
				print("BCC: Hunting for a third screambat.");
				repeat {
					//place florist friar plants
					choose_all_plants("i", $location[The Beanbat Chamber]);
					
					bumminiAdv(1, $location[The Beanbat Chamber], "");
				} until(last_monster() == $monster[screambat]);
			}
		}
	}

	string bathole = visit_url("place.php?whichplace=bathole");
	if (contains_text(bathole, "bathole_bg4") || contains_text(bathole, "bathole_bg5")) {
		checkStage("bats1", true);
		return true;
	}
	return false;
}

boolean bcascBats2() {
	if (checkStage("bats2")) return true;
	if (!checkStage("bats1")) return false;
	while (index_of(visit_url("questlog.php?which=1"), "I Think I Smell a Bat") > 0) {
		if (!contains_text(visit_url("place.php?whichplace=bathole"), "bathole_bg4")) {
			cli_execute("set bcasc_stage_bats1 = 0");
			bcascBats1();
		}
		
		if (canMCD()) cli_execute("mcd 4");
		if(my_path()=="Heavy Rains")
			abort("Fight aquabat yourself, hard damage cap of 12");
		bumAdv($location[The Boss Bat's Lair], "", "meatbossbat", "1 batskin belt", "WTFPWNing the Boss Bat", "m");
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());
	}
	checkStage("bats1", true);
	checkStage("bats2", true);
	return true;
}

//Declared as a global variable so it gets saved between function-calls
boolean checkme;
void bcascBugbearHunt() {
	if(!checkme) {
		use(1, $item[key-o-tron]);
		checkme = true;
	}
	//get detector
	if(i_a("bugbear detector") == 0)
	{
		cli_execute("pull bugbear detector");
	}
	if(i_a("bugbear detector") == 0)
	{
		if(i_a("BURT")>24)
			cli_execute("equip bugbear detector");
	}
	
	print("BCC: Checking if we can hunt any new bugbears.", "purple");
	while (to_int(get_property("statusWasteProcessing")) < 3 && my_adventures() > 0)
		bumAdv($location[The Sleazy Back Alley], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "", "+" + (3 - to_int(get_property("statusWasteProcessing"))) + " BURT", "BCC: Hunting for Scavenger bugbears.", "+");
		
	while (to_int(get_property("statusMedbay")) < 3 && my_adventures() > 0 && my_level()>1)
		bumAdv($location[The Spooky Forest], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (3 - to_int(get_property("statusMedbay"))) + " BURT", "BCC: Hunting for Hypodermic bugbears.", "+");
		
	while (checkStage("bats1") && to_int(get_property("statusSonar")) < 3 && my_adventures() > 0 && my_level()>3)
		bumAdv($location[The Beanbat Chamber], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (3 - to_int(get_property("statusSonar"))) + " BURT", "BCC: Hunting for batbugbears.", "+");

	while (checkStage("knobking") && to_int(get_property("statusScienceLab")) < 6 && my_adventures() > 0 && my_level()>4)
		bumAdv($location[Cobb's Knob Laboratory], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (6 - to_int(get_property("statusScienceLab"))) + " BURT", "BCC: Hunting for bugbear scientists.", "+");
		
	while (checkStage("cyrpt") && to_int(get_property("statusMorgue")) < 6 && my_adventures() > 0 && my_level()>6)
		bumAdv($location[Post-Cyrpt Cemetary], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (6 - to_int(get_property("statusMorgue"))) + " BURT", "BCC: Hunting for bugaboos.", "+");	
	 
	while (is_equal_to(get_property("questL08Trapper"), "finished") && to_int(get_property("statusSpecialOps")) < 6 && my_adventures() > 0 && my_level()>7)
		bumAdv($location[Lair of the Ninja Snowmen], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (6 - to_int(get_property("statusSpecialOps"))) + " BURT", "BCC: Hunting for Black Ops Bugbears.", "");

	while (checkStage("airship") && to_int(get_property("statusEngineering")) < 9 && my_adventures() > 0 && my_level()>9)
		bumAdv($location[The Penultimate Fantasy Airship], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (9 - to_int(get_property("statusEngineering"))) + " BURT", "BCC: Hunting for Battlesuit Bugbear Types.", "");
		
	while (checkStage("manorlibrary") && to_int(get_property("statusNavigation")) < 9 && my_adventures() > 0 && my_basestat(my_primestat()) > 90 && my_level()>10)
		bumAdv($location[The Haunted Gallery], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (9 - to_int(get_property("statusNavigation"))) + " BURT", "BCC: Hunting for ancient unspeakable bugbears.", "");		
	
	while (get_property("questL12War") == "finished" && to_int(get_property("statusGalley")) < 9 && my_adventures() > 0) {
		if (bcasc_doWarAs == "frat")
			bumAdv($location[The Hippy Camp (Bombed Back to the Stone Age)], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (9 - to_int(get_property("statusGalley"))) + " BURT", "BCC: Hunting for trendy bugbear chefs.", "");
		else
			bumAdv($location[The Orcish Frat House (Bombed Back to the Stone Age)], (i_a("bugbear detector") > 0 ? "+equip bugbear detector" : ""), "",  "+" + (9 - to_int(get_property("statusGalley"))) + " BURT", "BCC: Hunting for trendy bugbear chefs.", "");
	}
}

//To do: Make it check for the property lastEncounter to see if the area is done yet
void bcascBugbearShip() {
	string bugbearship = visit_url("place.php?whichplace=bugbearship");
	if (!contains_text(bugbearship, "Science Lab")) //If the Science lab is visible then the first floor is already done
	{
		//Medbay
		if(!checkStage("Medbay")) {
			buMax();
			setFamiliar("");
			print("BCC: Hunting for the robosurgeon.", "purple");
			//force off copying, don't care about it now
			set_combat_macro(false);
			while (to_string(last_monster()) != "bugbear robo-surgeon" && get_property("lastEncounter") != "Staph from the Staff") {
	
				//place florist friar plants
				choose_all_plants("", $location[medbay]);
				
				bumminiAdv(1,$location[Medbay]);
			}
			checkStage("Medbay", true);
		}

		//Waste Processing
		if(!checkStage("WasteProcessing")) {
			buMax("items");
			//force off copying, don't care about it now
			set_combat_macro(false);
			buMax("");
			setFamiliar("items");	
			print("Hunting for juicy juicy garbage.");
			setMood("i");
			while (i_a("bugbear communicator badge") == 0) {
	
				//place florist friar plants
				choose_all_plants("i", $location[waste processing]);
				
				bumminiAdv(1,$location[Waste Processing]);
				if(i_a("handful of juicy garbage")>0)
					use(item_amount($item[handful of juicy garbage]), $item[handful of juicy garbage]);
			}
			while(get_property("lastEncounter") != "You're a Compactor Impacter!" && get_property("lastEncounter") != "Smell Bad!")
			{
				buMax("+equip bugbear communicator badge");
	
				//place florist friar plants
				choose_all_plants("", $location[waste processing]);
				
				bumminiAdv(1,$location[Waste Processing]);
			}
			if (get_property("lastEncounter") == "You're a Compactor Impacter!" || get_property("lastEncounter") == "Smell Bad!")
				checkStage("WasteProcessing", true);
		}

		//Sonar
		if (!checkStage("Sonar")) {
			string sonar_room;
			int index;
			int value1, value2, value3;
			buMax("");
			setMood("-");
			//force off copying, don't care about it now
			set_combat_macro(false);
			sonar_room = visit_url("adventure.php?snarfblat=283");
			while(!contains_text(sonar_room, "Sayonara, Sonar!")) {
				if(contains_text(sonar_room, "Combat"))
					run_combat();
				else if (!contains_text(sonar_room, "So Close and Yet So Nar")) {
					index = index_of(sonar_room, "name=pingvalue") + 28;
					value1 = to_int(char_at(sonar_room, index));
					index = index_of(sonar_room, "name=whurmvalue") + 29;
					value2 = to_int(char_at(sonar_room, index));
					index = index_of(sonar_room, "name=boomchuckvalue") + 33;
					value3 = to_int(char_at(sonar_room, index));
					if (value1 != 2)
						sonar_room = visit_url("choice.php?whichchoice=588&pwd&option=1&pingvalue=2&butt1=Set+Pinging+Machine");
					else if (value2 != 4)
						sonar_room = visit_url("choice.php?whichchoice=588&pwd&option=2&whurmvalue=4&butt2=Set+Whurming+Machine");
					else if (value3 != 8)
						sonar_room = visit_url("choice.php?whichchoice=588&pwd&option=3&boomchuckvalue=8&butt3=Set+Boomchucking+Machine");
					else
						checkStage("Sonar", true);
				}
				if(my_adventures() > 0) {
					betweenBattle();
					sonar_room = visit_url("adventure.php?snarfblat=283");
				} else
					abort("BCC: No adventures left to confuse the batbugbears.");
			}
			
			checkStage("Sonar", true);
		}
	} else {
		checkStage("Medbay", true);
		checkStage("WasteProcessing", true);
		checkStage("Sonar", true);
	}
	
	bugbearship = visit_url("place.php?whichplace=bugbearship");
	if (!contains_text(bugbearship, "Engineering")) //If Engineering is visible then the second floor is already done
	{
		//force off copying, don't care about it now
		set_combat_macro(false);
		//Science Lab
		while (!checkStage("ScienceLab")) {
			buMax("items");
			setFamiliar("items");
			print("Silencing bugbear scientists..");
			setMood("i");
	
			//place florist friar plants
			choose_all_plants("i", $location[science lab]);
				
			bumminiAdv(1,$location[Science Lab],"consultBugbear");
			if(get_property("lastEncounter")=="Room Fulla Spiders")
				checkStage("ScienceLab", true);
		}

		//Morgue
		if (!checkStage("Morgue")) {
			buMax("items");
			//force off copying, don't care about it now
			set_combat_macro(false);
			set_property("choiceAdventure589", 6);
			buMax("");
			setFamiliar("items");
			setMood("+i");
			//figure out how many tweezers we still need
			int current_step=1;
			while(current_step<6){
				if(checkStage("Morgue"+current_step))
				{
					current_step+=1;
				}
				else break;
			}
			print("starting from stage "+current_step,"lime");
			while(i_a("bugbear autopsy tweezers")<5-current_step)
			{
				print("Gathering "+(5-current_step)+" autopsy tweezers.","lime");
	
				//place florist friar plants
				choose_all_plants("", $location[morgue]);
				
				bumminiAdv(1,$location[Morgue]);
				if(get_property("lastEncounter")=="The Ghost in You")
				{
					current_Step=5;
				}
			}
			if (get_property("lastEncounter") != "Operation Successful, Patient Still Deceased" && get_property("lastEncounter")!="The Ghost in You") {
				while(current_step<6){
					if(!checkStage("Morgue"+current_step))
					{
						set_property("choiceAdventure589", current_step);
						buMax("");
						setFamiliar("");	
						print("Removing limbs.","lime");
						setMood("-");
	
				//place florist friar plants
				choose_all_plants("", $location[morgue]);
				
						bumminiAdv(1,$location[Morgue]);
						if(get_property("lastEncounter")=="The Ghost in You" || get_property("lastEncounter")=="Autopsy Auturvy")
						{
							print("Last encounter was "+get_property("lastEncounter")+"so assuming the "+current_step+"organ was removed");
							checkStage("Morgue"+current_step,true);
							current_step+=1;
						}
					}
				}
			}
			while (get_property("lastEncounter") != "Operation Successful, Patient Still Deceased" && get_property("lastEncounter")!="The Ghost in You")
			{
			
	
				//place florist friar plants
				choose_all_plants("", $location[morgue]);
				
				bumMiniAdv(1, $location[Morgue]); //One last adventure to mark it as complete, account for wandering monsters
			}
			checkStage("Morgue", true);
		}
						
		//Special Ops
		if (!checkStage("SpecialOps")) {
			string specialops;
			if (i_a("UV monocular") == 0) {
				if (i_a("BURT") >= 50)
					retrieve_item(1, $item[UV monocular]);
				else
					abort("BCC: You don't have enough BURT (Reynolds). Please farm until you have 50 and can get a UV monocular");
			}
			if (i_a("UV monocular") > 0) {
				//equip brightening shit
				string max_str = "+equip UV monocular";
				if(i_a("rain-doh green lantern")>0)
					max_str+=", +equip rain-doh green lantern";
				else if(i_a("magic lantern")>0)
					max_str+=", +equip magic lantern";
				if(i_a("Fluorescent lightbulb")>0)
					max_str+=", +equip Fluorescent lightbulb";
				if(i_a("fire")>0)
					max_str+=", +equip fire";
				buMax(max_str);
				
				//force off copying, don't care about it now
				set_combat_macro(false);
				//shoot a flare if we haven't done and can do
				specialops = visit_url("adventure.php?snarfblat=286");
				if (i_a("flaregun") > 0 && contains_text(specialops, "Shoot a flare")) {
					set_property("choiceAdventure590", 2);
					print("BCC: Shooting a flare into the darkness.");
				} else {
					set_property("choiceAdventure590", 1);
					print("BCC: No flare available. Adventuring once before automating.");
				}
				runChoice(specialops);
				set_property("choiceAdventure590", 1);
				buMax(max_str);
				setFamiliar("");	
				print("BCC: Hunting for Black Ops bugbears.");
				setMood("+");
				while(get_property("lastEncounter") != "Turn Off The Dark" && get_property("lastEncounter")!="Fade to Black")
				{
	
					//place florist friar plants
					choose_all_plants("", $location[special ops]);
					
					bumminiAdv(1,$location[Special Ops]);
				}
				if(get_property("lastEncounter") == "Turn Off The Dark" || get_property("lastEncounter")=="Fade to Black")
					checkStage("SpecialOps", true);
			}
		}
	} else {
		checkStage("ScienceLab", true);
		checkStage("Morgue", true);
		checkStage("SpecialOps", true);
	}
	bugbearship = visit_url("place.php?whichplace=bugbearship");
	if (contains_text(bugbearship, "Engineering")) {
		//Engineering
		if (!checkStage("Engineering")) {
			buMax("items");
			//force off copying, don't care about it now
			set_combat_macro(false);
			setFamiliar("items");	
			print("Destroying Liquid metal bugbears.");
			setMood("i");
			while (get_property("lastEncounter") != "An Engineered Success" &&	get_property("lastEncounter") != "No More Murderbots For You")
			{
	
				//place florist friar plants
				choose_all_plants("", $location[engineering]);
				
				bumminiAdv(1,$location[Engineering],"consultBugbear");
			}
				
			if(get_property("lastEncounter") == "An Engineered Success" ||	get_property("lastEncounter") == "No More Murderbots For You")
				checkStage("Engineering", true);
		}
		
		//Navigation
		if (!checkStage("Navigation")) {
			buMax();
			setFamiliar("");	
			//force off copying, don't care about it now
			set_combat_macro(false);
			while (get_property("lastEncounter") != "The Water Cooler of Madness" && get_property("lastEncounter") != "Out of N-Space") {
				while(have_effect($effect[N-Spatial vision]) == 0 && get_property("lastEncounter") != "The Water Cooler of Madness" && get_property("lastEncounter") != "Out of N-Space")
				{
	
					//place florist friar plants
					choose_all_plants("", $location[navigation]);
				
					bumMiniAdv(1, $location[Navigation]);
				}
				if(have_effect($effect[N-Spatial vision]) > 0) {
					if (have_skill($skill[Adventurer of Leisure]))
						use_skill(1, $skill[Adventurer of Leisure]);
					else if (i_a("bugbear purification pill") > 0)
						use(1, $item[bugbear purification pill]);
					else if (i_a("soft green echo eyedrop antidote") > 0)
						//SIMON CHANGED
						//use(1, $item[soft green echo eyedrop antidote]);
						cli_execute("uneffect N-Spatial vision");
					else {
						checkStage("Navigation", true);
						abort("BCC: Unable to remove N-Spatial vision, please handle the Navigation room yourself. The script will continue as if you had when restarted.");
					}
				}
			}
			checkStage("Navigation", true);
		}		
		
		//Galley
		if (!checkStage("Galley")) {
			buMax("");
			setFamiliar("");
			print("Fighting angry cavebugbears, this might be problematic.","lime");
			while(get_property("lastEncounter") != "Darwin's Revenge" && get_property("lastEncounter") != "Haute Dish")
			{
				if(i_a("pacification grenade")<1 && i_a("BURT")>2)
					create(1,$item[pacification grenade]);
	
				//place florist friar plants
				choose_all_plants("", $location[galley]);
				
				bumMiniAdv(1,$location[Galley]);
				
			}
			if(get_property("lastEncounter") != "Darwin's Revenge" && get_property("lastEncounter") != "Haute Dish")
				checkStage("Galley", true);
		}
	} else
		abort("BCC: Something went wrong opening the third floor. Please handle the second floor manually and rerun the script.");
}

boolean bcascCastle() {
	if (checkStage("castle")) return true;

	void setCastleChoices() {
		if(i_a("drum 'n' bass 'n' drum 'n' bass record") > 0)
			set_property("choiceAdventure675", 2);
		else
			set_property("choiceAdventure675", 4);
		set_property("choiceAdventure676", 3);
		if(i_a("model airship") != 0)
			set_property("choiceAdventure677", 1);
		else
			set_property("choiceAdventure677", 2);
		set_property("choiceAdventure678", 4);
		set_property("choiceAdventure679", 1);
		set_property("choiceAdventure680", 1);
	}	
	
	//0=basement, 1=ground floor, 2=top floor, 3=quest done, 4=hits open
	int level;
	if(get_property("lastCastleGroundUnlock")!=my_ascensions())
		level = 0;
	else if(get_property("lastCastleTopUnlock")!=my_ascensions())
		level = 1;
	else if(contains_text(visit_url("questlog.php?which=1"), "The Rain on the Plains is Mainly Garbage"))
	{
		setCastleChoices();
		level = 2;
	}
	else if (my_path() != "Bugbear Invasion" && i_a("steam-powered model rocketship") == 0)
		level = 3;
	else
		level = 4;
		
	while(level == 0) {
		setMood("-");
		setFamiliar("");		
		
		if(i_a("amulet of extreme plot significance") > 0 || (i_a("titanium assault umbrella") > 0 && my_path() != "Avatar of Boris" && my_path() != "Way of the Surprising Fist")) {
			set_property("choiceAdventure669", 1);
			set_property("choiceAdventure670", 4);
			set_property("choiceAdventure671", 4);
			
			if(i_a("amulet of extreme plot significance") > 0 && i_a("titanium assault umbrella") > 0 && my_path() != "Avatar of Boris" && my_path() != "Way of the Surprising Fist") {
				buMax("+equip amulet of extreme plot significance, +equip titanium assault umbrella, +melee");
				print("BCC: Opening up the Ground Floor (both special items).", "purple");
				while(!contains_text(get_property("lastEncounter"), "The Fast and the Furry-ous") && !contains_text(get_property("lastEncounter"), "You Don't Mess Around with Gym"))
				{
	
					//place florist friar plants
					choose_all_plants("", $location[The Castle in the Clouds in the Sky (Basement)]);
					
					bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
				}
				level = 1;
			} else if (i_a("titanium assault umbrella") > 0 && my_path() != "Avatar of Boris" && my_path() != "Way of the Surprising Fist") {
				buMax("+equip titanium assault umbrella, +melee");
				print("BCC: Opening up the Ground Floor (titanium umbrella).", "purple");
				while(!contains_text(get_property("lastEncounter"), "The Fast and the Furry-ous") && !contains_text(get_property("lastEncounter"), "Arise!"))
				{
	
					//place florist friar plants
					choose_all_plants("", $location[The Castle in the Clouds in the Sky (Basement)]);
					
					bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
				}
				level = 1;					
			} else {
				buMax("+equip amulet of extreme plot significance");
				print("BCC: Opening up the Ground Floor (amulet of plot significance).", "purple");
				while(!contains_text(get_property("lastEncounter"), "You Don't Mess Around with Gym") && !contains_text(get_property("lastEncounter"), "Arise!"))
				{
	
					//place florist friar plants
					choose_all_plants("", $location[The Castle in the Clouds in the Sky (Basement)]);
					
					bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
				}
				level = 1;
			}
			set_combat_macro();
		} else {
			set_property("choiceAdventure669", 1);
			set_property("choiceAdventure670", 1);
			set_property("choiceAdventure671", 4);
			if(i_a("massive dumbbell") == 0)
				bumAdv($location[The Castle in the Clouds in the Sky (Basement)], "items", "itemsnc", "", "Getting a Massive Dumbbell", "-i");
			
			set_property("choiceAdventure669", 1);
			set_property("choiceAdventure670", 1);
			set_property("choiceAdventure671", 1);
			while(!contains_text(get_property("lastEncounter"), "Out in the Open Source"))
			{
	
				//place florist friar plants
				choose_all_plants("", $location[The Castle in the Clouds in the Sky (Basement)]);
				
				bumMiniAdv(1, $location[The Castle in the Clouds in the Sky (Basement)]);
			}
			cli_execute("refresh inv"); //Mafia does not remove the dumbbell yet
			level = 1;
		}
	}
	buMax();
	while(level == 1) {
		set_property("choiceAdventure672", 3);
		set_property("choiceAdventure673", 3);
		set_property("choiceAdventure674", 3);
		print("BCC: Opening up the Top Floor (it's going to take 11 turns)", "purple");
		while(!contains_text(get_property("lastEncounter"), "Top of the Castle, Ma"))
		{
	
			//place florist friar plants
			choose_all_plants("", $location[The Castle in the Clouds in the Sky (ground floor)]);
			bumAdv($location[The Castle in the Clouds in the Sky (Ground floor)], "items", "itemsnc", "", "opening top floor", "-i");
		}
		level = 2;
	}
	while (level == 2) {
		while(get_property("lastEncounter") != "Are you a Man or a Mouse?" && get_property("lastEncounter") != "Keep On Turnin' the Wheel in the Sky") {
			setCastleChoices();
	
			//place florist friar plants
			choose_all_plants("", $location[The Castle in the Clouds in the Sky (top floor)]);
			setFamiliar("itemsnc");
			setMood("-i");
			if(i_a("mohawk wig")==0 && !in_hardcore())
				cli_execute("pull mohawk wig");
			if(i_a("mohawk wig")!=0)
			{
				set_property("choiceAdventure678", 1); //get punk rock giant to help us
				bumax("+equip mohawk wig");
			}
			print("Finishing the quest (any way we can)","purple");
			bumMiniAdv(1,$location[The Castle in the Clouds in the Sky (top floor)]);
		}
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());
		if(my_path() != "Bugbear Invasion" && i_a("steam-powered model rocketship") == 0)
			level = 3;
		else
			level = 4;
	}
	while (level == 3) {
			set_property("choiceAdventure675", 4);
			set_property("choiceAdventure676", 3);
			set_property("choiceAdventure677", 2);
			set_property("choiceAdventure678", 2);
			bumAdv($location[The Castle in the Clouds in the Sky (top floor)], "", "itemsnc", "steam-powered model rocketship", "Picking up a steam-powered model rocketship to open up The Hole in the Sky", "-");
			
		if(i_a("steam-powered model rocketship") > 0)
			level=4;
	}

	checkStage("castle", true);
	return true;
}

boolean bcascChasm() {
	if (checkStage("chasm")) return true;
	int needLowercaseN() {
		int result = 1;
		for i from 2 to 7 {
			if (get_property("telescope" + i) == "see what appears to be the North Pole") {
				result = result + 1;
				break;
			}
		}
		if (!in_hardcore() || my_path() == "Bees Hate You" || my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" || my_path() == "Bugbear Invasion" || my_path() == "Zombie Slayer") result = result - 1;
		if (i_a("lowercase N") >= 1) result = result - i_a("lowercase N");
		return result;
	}

	buffer chasm;
	if (to_int(get_property("chasmBridgeProgress")) < 30) {
		if ((i_a("dictionary") == 0 && is_not_yet(get_property("questM15Lol"), "finished")) && index_of(visit_url("place.php?whichplace=orc_chasm"), "cross_chasm.gif") == -1) {
			cli_execute("outfit swashbuckling getup");
			if(i_a("post-holiday sale coupon")>0)use(1,$item[post-holiday sale coupon]);
			cli_execute("buy 1 abridged dictionary");
			print("BCC: Using the dictionary.", "purple");
			if (is_not_yet(get_property("questM01Untinker"), "finished"))
				cli_execute("untinker");
			cli_execute("untinker abridged dictionary");
		}
	
		if(i_a("smut orc keepsake box") > 0)
		use(item_amount($item[smut orc keepsake box]), $item[smut orc keepsake box]);	
		
		//Update Mafia's internal variable for the bridge
		if (to_int(get_property("lastChasmReset")) != my_ascensions())
			chasm = visit_url("place.php?whichplace=orc_chasm");
		//Disassemble the bridge and use all parts we have
		chasm = visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));

		//make + use snow boards (if we aren't saving for bathole)
		while(i_a("snow berries")>1 && checkStage("bats1"))
		{
			create(1,$item[snow boards]);
			use(1,$item[snow boards]);
		}
		
		//Prepare for adventuring
		if(!in_hardcore() && i_a("loadstone")==0)
			cli_execute("pull loadstone");
		if(!in_hardcore() && my_primestat()!=$stat[moxie] && i_a("logging hatchet")==0)
			cli_execute("pull logging hatchet");

		string max_str="items";
		if(i_a("loadstone")>0)
			max_str+=", +equip loadstone";
		if(i_a("logging hatchet")>0)
			max_str+=", +equip logging hatchet";
		if(my_primestat()==$stat[muscle])
			max_str+=", +melee";
		else if(my_primestat()==$stat[moxie])
			max_str+=", -melee";
		buMax(max_str);
		setFamiliar("items");
		setMood("i");
		
		//Finish buliding the bridge
		while (to_int(get_property("chasmBridgeProgress")) < 30) {
	
			//place florist friar plants
			choose_all_plants("", $location[The Smut Orc Logging Camp]);
				
			bumMiniAdv(1, $location[The Smut Orc Logging Camp]);
			if(i_a("smut orc keepsake box") > 0)
				use(item_amount($item[smut orc keepsake box]), $item[smut orc keepsake box]);		
			chasm = visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		}
	}

	//Adventure in the different peaks
	//Update the quest status
	chasm = visit_url("place.php?whichplace=highlands&action=highlands_dude");

	//A-boo Peak - Kill ghosts until you can light the pyre
	while(!contains_text(visit_url("place.php?whichplace=highlands"), "fire1.gif")) {
		restore_hp(my_maxhp());
		if(have_effect($effect[beaten up])>0)
			cli_execute("rest");
		if(have_effect($effect[beaten up])>0)
			abort("during a-boo clue usage, couldn't cure beaten up");
		while(i_a("a-boo clue")<1)
		{
			bumAdv($location[A-boo peak], "item, +10 elemental damage, -spooky damage", "items", "1 A-Boo clue", "Getting a clue", "i");
			if (get_property("lastEncounter") == "Come On Ghosty, Light My Pyre") {
				checkStage("aboopeak", true);
				break;
			}
		}
		if (get_property("lastEncounter") == "Come On Ghosty, Light My Pyre") {
			checkStage("aboopeak", true);
			break;
		}
		//TODO: Add some cheap/easily accesible +HP and +res consumables
		maximize("hp", false);
		maximize("spooky resistance, cold resistance, " + ((bcasc_100familiar == "" || bcasc_100familiar.to_familiar() == $familiar[Exotic Parrot]) && have_path_familiar($familiar[exotic parrot]) ? "switch exotic parrot" : "") + " -1 tie", false);
		if (have_effect($effect[elemental saucesphere]) == 0 && have_skill($skill[elemental saucesphere]) && have_castitems($class[sauceror], true)) use_skill(1, $skill[elemental saucesphere]);
		use_genetics_lab("res");
		if (have_effect($effect[astral shell]) == 0 && have_skill($skill[astral shell]) && have_castitems($class[turtle tamer], true)) use_skill(1, $skill[astral shell]);
		if (have_effect($effect[Protection from Bad Stuff]) == 0 && available_amount($item[scroll of Protection from Bad Stuff])>0) use(1, $item[scroll of Protection from Bad Stuff]);

		restore_hp(my_maxhp());
		
		int expected_boo_damage(int unmodified)
		{
			int damage=((100.0 - elemental_resistance($element[cold]))/100.0)*unmodified;
			damage+=((100.0 - elemental_resistance($element[spooky]))/100.0)*unmodified;
			print("Expecting "+damage+" damage from this round of clue hunting","lime");
			return damage;
		}
		
		//simon fixed
		use(1, $item[ A-Boo clue]);
		chasm = visit_url("adventure.php?snarfblat=296");
		if (contains_text(chasm, "choice.php")) {
			chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Talk+to+the+Ghosts");
			if (have_effect($effect[beaten up]) == 0 && my_hp() > expected_boo_damage(25))
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Try+to+Talk+Some+Sense+into+Them");
			if (have_effect($effect[beaten up]) == 0 && my_hp() > expected_boo_damage(50))
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Make+a+Suggestion");
			if (have_effect($effect[beaten up]) == 0 && my_hp() > expected_boo_damage(125))
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Take+Command");
			if (have_effect($effect[beaten up]) == 0 && my_hp() > expected_boo_damage(250))
				chasm = visit_url("choice.php?pwd&whichchoice=611&option=1&choiceform1=Join+the+Conversation");
			chasm = visit_url("choice.php?pwd&whichchoice=611&option=2&choiceform1=Flee+the+Scene");
		} else {
			print("seems our clue was interupted by something","lime");
			bumRunCombat();	//In case a holiday monster or similar screws up the using of the clue
		}
	}
	//If we've arrived here we should've finished the stage
	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire1.gif") && !checkStage("aboopeak"))
		checkStage("aboopeak", true);

	//The Oil Peak - Kill oil monsters to lower the preassure, raised ML makes this go faster (TODO: Possibly add way of allowing +ML here)
	while (!checkStage("oilpeak") && !contains_text(visit_url("place.php?whichplace=highlands"), "fire3.gif")) {
		bumAdv($location[oil peak], "", (bcasc_AllowML ? "ml" : ""), "", "Lowering the oil pressure", "1");
		if (get_property("lastEncounter") == "Unimpressed with Pressure")
			checkStage("oilpeak", true);
	}
	//If we've arrived here we should've finished the stage
	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire3.gif") && !checkStage("oilpeak"))
		checkStage("oilpeak", true);		

	if (!checkStage("twinpeak") && !contains_text(visit_url("place.php?whichplace=highlands"), "fire2.gif")) {
		boolean loop = true;
		//Twin peak (hedge trimmers and ChoiceAdv606)
		if(my_path() != "Bees Hate You") {
			if (!checkstage("peakitems")) {
				print("Doing peak items");
				setFamiliar("nothing");
				print("maximizing equipment");
				if(my_primestat()==$stat[moxie])
					cli_execute("maximize items -melee");
				else if(my_primestat()==$stat[muscle])
					cli_execute("maximize items +melee");
				else
					cli_execute("maximize items");
				print("setting mood");
				setMood((my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" ? "i" : "-i"));
				print("activating mood");
				cli_execute("mood execute");
				betweenBattle();
				string[int] perform;
				float sum=to_int(item_drop_modifier());
				int j=0;
				int itempenalty = 0;
				if (my_path() == "Avatar of Jarlsberg" && my_companion() == "Eggman") {
					if (have_skill($skill[Working Lunch])) itempenalty = 75;
					else itempenalty = 50;
				} else if (my_path() == "Avatar of Boris" && minstrel_instrument() == $item[Clancy's lute]) {
					itempenalty = (55*5*minstrel_level())**.5+((minstrel_level()*5)-3);
				}
				if (to_int(item_drop_modifier() + numeric_modifier("food drop") - itempenalty) < 50) {
					foreach i, rec in maximize("item, food drop", 0, (can_interact() ? 1 : 0), true, true) {
						if(rec.score > 0) {
							perform[j] = rec.command;
							sum = sum + rec.score;
							j += 1;
						}
					}
					if(sum > 50.0) {
						for i from 0 to count(perform) - 1 {
							cli_execute(perform[i]);
							if(item_drop_modifier() + numeric_modifier("food drop") - itempenalty > 50.0)
								break;
						}
					}
				}
				setFamiliar("items");	

				while(loop) {
					print("looking for adv / hedge trimmers");
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "name=whichchoice value=604")) {
						chasm = visit_url("choice.php?pwd&whichchoice=604&option=1&choiceform1=Continue...");
						chasm = visit_url("choice.php?pwd&whichchoice=604&option=1&choiceform1=Everything+goes+black.");
					} else if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
				}
				//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0)
				{
					print("USING hedge trimmers");
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;				
				}
				visit_url("choice.php?pwd&whichchoice=606&option=2&choiceform2=Search+the+pantry");	//Needs +50% item (no familiar)
				string html = visit_url("choice.php?pwd&whichchoice=608&option=1&choiceform1=Search+the+shelves");
				//The hedge trimmer is removed, but Mafia is unaware
				if (trimmers) cli_execute("refresh inv");
				if(contains_text(html,"for the entire length of the 90"))
					checkstage("peakitems", true);
				else
					abort("Something seems to have failed in peakitems");
			}

			if (!checkStage("peakstench")) {
				betweenBattle();
				loop = true;
				while(loop == true) {
					//SIMON MOVED THIS
					 if (elemental_resistance($element[stench]) / 10 < 4) {
						get_res($element[stench], 4, true);
						if(numeric_modifier("stench resistance") < 4) {
							abort("BCC: Unable to buff stench resistance high enough. Please do the stench-choice (Room 237) yourself, the script will move on to the next step when you rerun it.");
						}
					}
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
				}	
				//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0)
				{
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;
				}
				string html1 = visit_url("choice.php?pwd&whichchoice=606&option=1&choiceform1=Investigate+Room+237");	//Needs 4 stench res or more
				string html2 = visit_url("choice.php?pwd&whichchoice=607&option=1&choiceform1=Carefully+inspect+the+body");
				if (trimmers) cli_execute("refresh inv");
				if(contains_text(html2,"pull out a tiny square of paper"))
					checkStage("peakstench", true);
				else
				{
					print("html:\n"+html1,"blue");
					print("\n","blue");
					print("html:\n"+html2,"blue");
					abort("Something seems to have failed in peakstench");
				}
			}

			if(!checkStage("peakoil")) {
				while(i_a("bubblin' crude") < 12 && i_a("jar of oil") == 0) {
					bumAdv($location[oil peak], "items", "items", "12 bubblin' crude", "Creating a jar of oil", "i");
				}
				if(i_a("jar of oil")<1)
					cli_execute("create 1 jar of oil");	
				setMood("-i");
				buMax("items");
				cli_execute("mood execute");
				loop = true;
				while(loop == true) {
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
				}	
				//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0)
				{
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;
				}
					visit_url("choice.php?pwd&whichchoice=606&option=3&choiceform3=Follow+the+faint+sound+of+music");
					visit_url("choice.php?pwd&whichchoice=609&option=1&choiceform1=Examine+the+painting");
					string html = visit_url("choice.php?pwd&whichchoice=616&option=1&choiceform1=Mingle");
					//The hedge trimmer is removed, but Mafia is unaware
					if (trimmers) cli_execute("refresh inv");
					if(contains_text(html,"The sole exceptions are a man in a tuxedo and a fat man in a bear costume"))
						checkStage("peakoil", true);
					else
						abort("Something seems to have failed in peakoil. String was:"+html);
			}

			if (!checkStage("peakinit")) {
				buMax("initiative");	//Need +init to be 40% or more
				setFamiliar("init");
				if (boolean_modifier("Four Songs") || boolean_modifier("Additional Song"))
					setMood("-in");
				else
					setMood("-n"); //dont set mood for items, since we can only have 3 songs (urkel,sonata,celerity)
				cli_execute("mood execute");
				string[int] perform;
				float sum;
				int j;
				if (numeric_modifier("initiative") < 40) {
					foreach i, rec in maximize("initiative", 0, (can_interact() ? 1 : 0), true, true) {
						if(rec.score > 0) {
							perform[j] = rec.command;
							sum = sum + rec.score;
							j += 1;
						}
					}
				}
				if(sum > 40.0) {
					for i from 0 to count(perform) - 1 {
						cli_execute(perform[i]);
						if(numeric_modifier("initiative") > 40.0)
							break;
					}
				}
				if (numeric_modifier("initiative") < 40) {
					abort("BCC: Unable to buff initiative high enough. Please do the initiative-choice (should be the only available option) yourself, the script will move on to the next step when you rerun it.");
				}
				loop = true;
				while(loop == true) {
					print("looping for hedge trimmers");
					chasm = visit_url("adventure.php?snarfblat=297");
					if (contains_text(chasm, "choice.php"))
						loop = false;
					else {
						bumRunCombat();
						betweenBattle();
					}
					if(i_a("rusty hedge trimmers") > 0)
						loop = false;
				}
				//Use the hedge trimmers
				boolean trimmers = false;
				if(i_a("rusty hedge trimmers") > 0)
				{
					print("trimming hedge");
					visit_url("inv_use.php?pwd&which=3&whichitem=5115");
					trimmers = true;
				}
				visit_url("choice.php?pwd&whichchoice=606&option=4&choiceform4=Wait+--+who%27s+that%3F");
				visit_url("choice.php?pwd&whichchoice=610&option=1&choiceform1=Pursue+your+double");
				string html = visit_url("choice.php?pwd&whichchoice=617&option=1&choiceform1=And+then...");
				//The hedge trimmer is removed, but Mafia is unaware
				if (trimmers) cli_execute("refresh inv");
				if(contains_text(html,"or if it's inhabited by some kind of weird personified spirit of the Evil That Men Do"))
					checkStage("peakinit", true);
				else
					abort("Something seems to have failed in peakinit");
			}
			if(i_a("gold wedding ring") > 0)
				checkStage("twinpeak", true);
			else
				abort("BCC: Something went wrong while going through the Twin Peak. Please check for yourself.");
			} else {
			//abort("BCC: The bees make you unable to use oil thingies. Please run the peak yourself and burn the shit down.");
			set_property("choiceAdventure606", 6);
			set_property("choiceAdventure618", 2);
			while(!contains_text(visit_url("questlog.php?which=2"),"There Can Be Only One Topping"))
			{
				bumAdv($location[twin peak], "", "", "", "We are going to burn down this beeloving mansion!", "+");
				visit_url("place.php?whichplace=highlands&action=highlands_dude");
			}
		}		
	}
	//If we've arrived here we should've finished the stage
	if (contains_text(visit_url("place.php?whichplace=highlands"), "fire2.gif") && !checkStage("twinpeak"))
		checkStage("twinpeak", true);	
	//Let's get our reward
	chasm = visit_url("place.php?whichplace=highlands&action=highlands_dude");
	
	if ((get_property("bcasc_ROFL") == "true" && is_not_yet(get_property("questM15Lol"), "finished")) || needLowercaseN() > 0) {
		if (get_property("bcasc_ROFL") == "true") {
			while (contains_text(visit_url("questlog.php?which=1"), "A Quest, LOL")) {
				if (index_of(visit_url("questlog.php?which=1"), "The Highland Lord told you that the Baron Rof L'm Fao") > 0) {
					if (can_interact()) {
						buy(1, $item[668 scroll]);
						buy(1, $item[64067 scroll]);
					}
					else if(!in_hardcore())
					{
						if(i_a("668 scroll")<1 && i_a("334 scroll")<2)
							cli_execute("pull 668 scroll");
						//failed to pull? 
						if(i_a("668 scroll")<1 && i_a("334 scroll")<2)
							return false;
						if(i_a("64067 scroll")<1 && (i_a("30669 scroll")<1 || i_a("33398 scroll")<1))
							cli_execute("pull 64067 scroll");
						//failed to pull? 
						if(i_a("64067 scroll")<1 && (i_a("30669 scroll")<1 || i_a("33398 scroll")<1))
							return false;
						
					cli_execute("set addingScrolls = 1");
					}
				
					cli_execute("set addingScrolls = 1");
					 while(i_a("64735 scroll") == 0 || needLowercaseN() > 0) {
						bumAdv($location[The Valley of Rof L'm Fao], "", "items", "1 64735 scroll, " + needLowercaseN() + " lowercase N", "Get me the 64735 Scroll", "i");
					}
					if (cli_execute("use 64735 scroll")) {}
				} else {
					abort("For some reason we haven't bridged the chasm.");
				}
			}
		}
		else {
			bumAdv($location[The Valley of Rof L'm Fao], "items", "items", needLowercaseN() + " lowercase N", "Gathering some lowercase n.", "i");
		}
	}
	if(contains_text(chasm,"totally lit all th")) //should match completion, and previously completed texts
		checkStage("chasm", true);
	return true;
}

boolean bcascCyrpt() {
	boolean stageDone(string name) {
		if (get_revision() < 9260 && get_revision() > 0) abort("You need to update your Mafia to handle the cyrpt. A revision of at least 9260 is required. This script is only ever supported for a latest daily build.");
		print("The "+name+" is at "+get_property("cyrpt"+name+"Evilness")+"/50 Evilness...", "purple");
		return (get_property("cyrpt"+name+"Evilness") < 1);
	}
	
	if (checkStage("cyrpt")) return true;
	
	if (!contains_text(visit_url("questlog.php?which=2"), "defeated the Bonerdagon")) {
		set_property("choiceAdventure523", "4");
		use(1, $item[evilometer]);

		while (!stageDone("Niche")) bumAdv($location[The Defiled Niche], "", "", "", "Un-Defiling the Niche (1/4)");
if(!get_property("_nookwarned").to_boolean())
{
set_property("_nookwarned","true");
abort("nook - get debonair deboners from choiceadv, line 6137");
	
		while (!stageDone("Nook")) {
		

			setFamiliar("items");
			buMax("items");
			setMood("i");
			
			if (item_amount($item[evil eye]) > 0) use(i_a("evil eye"), $item[evil eye]);
			bumAdv($location[The Defiled Nook], "items", "items", "1 evil eye", "Un-Defiling the Nook (2/4)", "i");
			if (item_amount($item[evil eye]) > 0) use(1, $item[evil eye]);
		}
}
		while (!stageDone("Alcove")) {	//Kill modern zmobies (+initiative) to decrease evil
			setFamiliar("init");
			eat_hot_dog("Wet dog",$location[The Defiled Alcove]);
			if (item_amount($item[yellow candy heart]) > 0) use(1,$item[yellow candy heart]);
			bumAdv($location[The Defiled Alcove], "init", "init", "", "Un-Defiling the Alcove (3/4)", "n-");
		}
		if(!stageDone("Cranny"))
			cli_execute("swim laps");
		while (!stageDone("Cranny")) {	//Kill swarms of ghuol welps (+NC, +ML) to decrease evil
			set_property("choiceAdventure523",4);
			eat_hot_dog("chilly dog",$location[The Defiled Cranny]);
			bumAdv($location[The Defiled Cranny], "", "ml", "", "Un-Defiling the Cranny (4/4)", "-l");
		}
		if (my_buffedstat(my_primestat()) > 101) {
			//buff a bit since he can be tough
			if(cli_execute("telescope high")){}
			if(equipped_amount($item[greatest american pants])>0)
			{
				if(have_effect($effect[super structure])<1)
				{
					visit_url("inventory.php?action=activatesuperpants");
					visit_url("choice.php?pwd&whichchoice=508&option=2&choiceform2=Super+Structure");
				}
				if(have_effect($effect[super speed])<1)
				{
					visit_url("inventory.php?action=activatesuperpants");
					visit_url("choice.php?pwd&whichchoice=508&option=4&choiceform2=Super+Speed");
				}
				if(have_effect($effect[super accuracy])<1)
				{
					visit_url("inventory.php?action=activatesuperpants");
					visit_url("choice.php?pwd&whichchoice=508&option=5&choiceform2=Super+Accuracy");
				}
			}
			
			set_property("choiceAdventure527", "1");
			if(stageDone("Nook") && stageDone("Alove") && stageDone("Niche") && stageDone("Cranny"))
				bumAdv($location[Haert of the Cyrpt], "", "meatboss");
			visit_url("council.php");
			set_property("lastCouncilVisit", my_level());
			if (item_amount($item[chest of the Bonerdagon]) > 0) {
//				if (cli_execute("use chest of the Bonerdagon")) {}
				checkStage("cyrpt", true);
				return true;
			}
		}
	} else {
		checkStage("cyrpt", true);
		return true;
	}
	return false;
}

void bcascDailyDungeon() {
	if (my_adventures() < 10 || my_path() == "Bugbear Invasion") return;
	zapKeys();
	int targetKeys = (get_property("bcasc_3KeysNoWand").to_boolean()) ? 3 : 2;
	print("targetKeys="+targetKeys+" numuniquekeys="+numUniqueKeys(),"lime");
	//SIMON CHANGED, assume we will eat pies
	if(!in_hardcore() && my_path()!="Zombie Slayer" && my_path()!="Avatar of Jarlsberg")
	{
		print("----------------------------------------","red");
		print("Remember to eat key lime pies!","red");
		print("----------------------------------------","red");
	}
	if (numUniqueKeys() >= targetKeys || (!in_hardcore() && my_path()!="Zombie Slayer" && my_path()!="Avatar of Jarlsberg")) return;
	
	int amountKeys;
	print("Making skeleton keys","lime");
	//Make skeleton keys if we can.
	if (i_a("skeleton bone") > 1 && i_a("loose teeth") > 1) {
		if (i_a("skeleton bone") > i_a("loose teeth")) {
			amountKeys = i_a("loose teeth") - 1;
		} else {
			amountKeys = i_a("skeleton bone") - 1;
		}
		cli_execute("make "+amountKeys+" skeleton key");
	}
	print("visiting daily dungeon","lime");
	while (get_property("dailyDungeonDone") != "true" && my_adventures() > 0) {
		if (have_skill($skill[Astral Shell]) && have_castitems($class[turtle tamer], true)) {
			cli_execute("cast 3 astral shell");
		} else if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true)) {
			cli_execute("cast 3 elemental saucesphere");
		}
		adventure(my_adventures(), $location[the daily dungeon]);
		if (my_adventures() == 0)
		{
			cli_execute("shower "+my_primestat());
			abort("No adventures left in daily dungeon:(");
		}
	}
	
	zapKeys();
}


boolean bcascDinghyHippy() {
	if (checkStage("dinghy")) return true;
	//We shore first so that we can get the hippy outfit ASAP.
	if (get_property("lastIslandUnlock").to_int() != my_ascensions()) {
		//try to make a skelton boat
		if(i_a("skeleton")>=7)
			cli_execute("make skeletal skiff");
		
		if(i_a("skeletal skiff")==0)
		{
			//if we have skeletons planted and still day one, leave it for now
			if(contains_text(visit_url("campground.php"),"bonegarden") && my_daycount()==1)
				return false;
				
			//otherwise do it old fashioned way	
			if (index_of(visit_url("place.php?whichplace=desertbeach"), "can't go to Desert Beach") > 0)
				visit_url("guild.php?place=paco");
			
			cli_execute("inventory refresh");
			while (item_amount($item[Shore Inc. Ship Trip Scrip]) < 3 && my_adventures() > 2 && item_amount($item[dinghy plans]) < 1) {
				cli_execute("mood clear");
				switch (my_primestat()) {
					case $stat[Muscle] :
						set_property("choiceAdventure793", "1");
						break;
					case $stat[Mysticality] :
						set_property("choiceAdventure793", "2");
						break;
					case $stat[Moxie] :
						set_property("choiceAdventure793", "3");
						break;
				}
				adventure(1, $location[The Shore, Inc. Travel Agency]);
			}

			if (item_amount($item[dinghy plans]) < 1) buy($coinmaster[The Shore\, Inc. Gift Shop], 1, ($item[dinghy plans]));
			if (item_amount($item[dingy planks]) < 1) buy(1, $item[dingy planks]);
			use(1, $item[dinghy plans]);
			if (item_amount($item[dingy dinghy]) == 0) {
				abort("There was a problem creating the dinghy. Please do this manually.");
			}
		}
	}
	
	if (can_interact()) {
		buy(1, $item[filthy knitted dread sack]);
		buy(1, $item[filthy corduroys]);
		return checkStage("dinghy", true);
	}
	if (get_property("questL12War") == "finished")
		return checkStage("dinghy", true);
	
	//if not in hardcore, pull outfit or jump out and wait for tomorrow
	if(!in_hardcore())
	{
		if(i_a("filthy knitted dread sack")<1)
			cli_execute("pull filthy knitted dread sack");
		if(i_a("filthy corduroys")<1)
			cli_execute("pull filthy corduroys");
			
		if (i_a("filthy knitted dread sack") == 0 || i_a("filthy corduroys") == 0) return false;
	}
	
	//if (!in_hardcore()) return checkStage("dinghy", true);
	
	while ((i_a("filthy knitted dread sack") == 0 || i_a("filthy corduroys") == 0) && have_effect($effect[Everything Looks Yellow]) == 0)
		bumAdv($location[Hippy Camp], "", "hebo", "1 filthy knitted dread sack, 1 filthy corduroys", "Getting Hippy Kit", "i", "consultHeBo");
		
	
	if (i_a("filthy knitted dread sack") > 0 && i_a("filthy corduroys") > 0) {
		checkStage("dinghy", true);
		return true;
	}
	return false;
}

void bcascEpicWeapons() {
	if (bcasc_cloverless) return;
	if (!in_hardcore()) return;
	if (my_path() == "Avatar of Boris" || my_path() == "Zombie Slayer") return;
	
	//Returns true if you lack one of the kickass astral weapons for your Mox/Mus class as appropriate.
	boolean dontHaveAstral() {
		switch (my_primestat()) {
			case $stat[Muscle] :
				return (i_a("astral mace") == 0);
			
			case $stat[Moxie] :
				return (i_a("astral longbow") + i_a("astral pistol") == 0);
		}
		return true;
	}
	
	boolean getEpic(string className, string baseWeapon, string theOtherThingYouNeed, string theEpicWeaponYouWantToGet) {
		print("BCC: Getting the "+className+" Epic Weapon", "purple");
		
		if (can_interact()) return buy(1, to_item(theEpicWeaponYouWantToGet));
		if (i_a(theEpicWeaponYouWantToGet) > 0) return true;
		
		while (i_a(baseWeapon) == 0) use(1, $item[chewing gum on a string]);
		if (i_a(theOtherThingYouNeed) == 0) {
			if (cli_execute("hermit "+theOtherThingYouNeed)) {}
		}
		
		if (i_a("big rock") == 0 && cloversAvailable(true) > 0) {
			print("BCC: Getting the Big Rock", "purple");
			visit_url("casino.php?action=slot&whichslot=11&confirm=on");
		}
		
		visit_url("guild.php?place=scg");
		visit_url("guild.php?place=scg");
		if (my_meat() < 1000 && i_a("tenderizing hammer") == 0 && !knoll_available()) return false;
		if (cli_execute("make "+theEpicWeaponYouWantToGet)) {}
		return true;
	}
	
	boolean requireRNR() {
		float n = 0;
		if (have_skill($skill[ The Moxious Madrigal ])) n += 0.1 + (0.1 * to_float(my_primestat() == $stat[Moxie]));
		if (have_skill($skill[ The Magical Mojomuscular Melody ])) n += 0.1 + (0.3 * to_float(my_primestat() == $stat[Mysticality]));
		if (have_skill($skill[ Cletus's Canticle of Celerity ])) n += 0.1;
		if (have_skill($skill[ The Power Ballad of the Arrowsmith ])) n += (0.5 * to_float(my_primestat() == $stat[Muscle]));
		if (have_skill($skill[ The Polka of Plenty ])) n += 0.1;
		if (have_skill($skill[ Jackasses' Symphony of Destruction ])) n += 0.2;
		if (have_skill($skill[ Fat Leon's Phat Loot Lyric ])) n += 0.8;
		if (have_skill($skill[ Brawnee's Anthem of Absorption ])) n += 0.1;
		if (have_skill($skill[ The Psalm of Pointiness ])) n += 0.1;
		if (have_skill($skill[ Stevedave's Shanty of Superiority ])) n += 0.2;
		if (have_skill($skill[ Aloysius' Antiphon of Aptitude ])) n += 0.2;
		if (have_skill($skill[ The Ode to Booze ])) n += 0.6;
		if (have_skill($skill[ The Sonata of Sneakiness ])) n += 0.5;
		if (have_skill($skill[ Ur-Kel's Aria of Annoyance ])) n += 0.4;
		if (have_skill($skill[ Dirge of Dreadfulness ])) n += 0.1;
		if (have_skill($skill[ Inigo's Incantation of Inspiration ])) n+= 0.7;
		return (n >= 1.0);
	}
	
	if(my_path() != "way of the surprising fist") {
		if (my_class() == $class[Disco Bandit] && my_basestat(my_primestat()) > 10 && i_a("Disco Banjo") == 0 && i_a("Shagadelic Disco Banjo") == 0 && i_a("Seeger's Unstoppable Banjo") == 0) {
			if (dontHaveAstral())
				if (getEpic("DB", "disco ball", "banjo strings", "disco banjo"))
					return;
		}
		
		if (my_class() == $class[Turtle Tamer] && my_basestat(my_primestat()) > 10 && i_a("Mace of the Tortoise") == 0 && i_a("Chelonian Morningstar") == 0 && i_a("Flail of the Seven Aspects") == 0) {
			if (dontHaveAstral())
				if (getEpic("TT", "turtle totem", "chisel", "Mace of the Tortoise"))
					return;
		}
		
		if (my_class() == $class[Seal Clubber] && my_basestat(my_primestat()) > 10 && i_a("Bjorn's Hammer") == 0 && i_a("Hammer of Smiting") == 0 && i_a("Sledgehammer of the V&aelig;lkyr") == 0) {
			if (dontHaveAstral())
				if (getEpic("SC", "seal-clubbing club", "seal tooth", "Bjorn's Hammer"))
					return;
		}
		
		if (my_class() == $class[Sauceror] && my_basestat(my_primestat()) > 10 && (have_skill($skill[jalape&ntilde;o saucesphere]) || bcasc_bartender || bcasc_chef) && i_a("5-alarm Saucepan") == 0 && i_a("17-alarm Saucepan") == 0 && i_a("Windsor Pan of the Source") == 0) {
			if (getEpic("S", "saucepan", "jaba&ntilde;ero pepper", "5-alarm Saucepan"))
				return;
		}
		
		if (my_class() == $class[Pastamancer] && my_basestat(my_primestat()) > 10 && (!have_skill($skill[springy fusilli]) || bcasc_bartender || bcasc_chef) && i_a("Pasta of Peril") == 0 && i_a("Greek Pasta of Peril") == 0 && i_a("Wrath of the Capsaician Pastalords") == 0) {
			if (getEpic("P", "pasta spoon", "petrified noodles", "Pasta of Peril"))
				return;
		}

		if (my_class() == $class[Accordion Thief] && my_basestat(my_primestat()) > 10 && i_a("Rock and Roll Legend") == 0 && i_a("Squeezebox of the Ages") == 0 && i_a("The Trickster's Trikitixa") == 0 && requireRNR()) {
			if(getEpic("AT", "stolen accordion", "hot buttered roll", "rock and roll legend"))
				;
		}
 	}
	
	return;
}

boolean bcascFriars() {
	boolean needRubyW() {
		if (!in_hardcore() || my_path() == "Bees Hate You" || my_path() == "Avatar of Boris" || my_path() == "Bugbear Invasion" || my_path() == "Zombie Slayer" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete") return false;
		return true;
	}
	
	if (checkStage("friars")) return true;
	if (visit_url("friars.php&pwd").to_string() != "") {}
	if (visit_url("friars.php?action=ritual&pwd").to_string() != "") {}
	if (visit_url("friars.php?action=ritual&pwd").to_string() != "") {}
	
	if (index_of(visit_url("friars.php"), "friars.gif") > 0) {
		setMood("-");
		cli_execute("mood execute");
		if(combat_rate_modifier() > -25.0)
			cli_execute("swim sprints");
		if(combat_rate_modifier() > -25.0)
			eat_hot_dog("Ghost dog",$location[The Dark Elbow of the Woods]);
		print("BCC: Gotta get the Friars' Items", "purple");
		while (item_amount($item[eldritch butterknife]) == 0)
			bumAdv($location[The Dark Elbow of the Woods], "", "", "1 eldritch butterknife", "Getting butterknife from the Elbow (1/3)", "-");
			
		while (item_amount($item[box of birthday candles]) == 0)
			bumAdv($location[The Dark Heart of the Woods], "", "", "1 box of birthday candles", "Getting candles from the Heart (2/3)", "-");
			
		while (item_amount($item[dodecagram]) == 0) {
			if (needRubyW()) {
				bumAdv($location[The Dark Neck of the Woods], "", "items", "1 dodecagram, 1 ruby w", "Getting dodecagram from the Neck (3/3)", "-");
			} else {
				bumAdv($location[The Dark Neck of the Woods], "", "", "1 dodecagram", "Getting dodecagram from the Neck (3/3)", "-");
			}
		}
			
		print("BCC: Yay, we have all three items. I'm off to perform the ritual!", "purple");
		if (visit_url("friars.php?action=ritual&pwd="+my_hash()).to_string() != "") {}
	}
	if (contains_text(visit_url("friars.php"), "pandamonium.php")) {
		checkStage("friars", true);
		return true;
	}
	return false;
}

boolean bcascFriarsSteel() {
	//SIMON ADDED
	boolean have_steel()
	{
		return (have_skill($skill[Liver of Steel]) || have_skill($skill[Spleen of Steel]) || have_skill($skill[Stomach of Steel]));
	}
	if (checkStage("friarssteel")) return true;
	if (get_property("bcasc_skipSteel") == "true") return checkStage("friarssteel", true);
	if (have_steel()) return checkStage("friarssteel", true);
	if (my_path() == "Avatar of Boris" && (minstrel_instrument() != $item[Clancy's lute] && i_a("Clancy's lute") == 0)) return false;
	if (my_path() == "KOLHS" && my_name()!="twistedmage") return false; //in kolhs you don't get enough booze to go over 10 drunkeness, unless you have huge +item available and get it in hallowed halls

	boolean logicPuzzleDone() {
		/*    
			* Jim the sponge cake or pillow
			* Flargwurm the cherry or sponge cake
			* Blognort the marshmallow or gin-soaked paper
			* Stinkface the teddy bear or gin-soaked paper 
		*/
		if (item_amount($item[sponge cake]) + item_amount($item[comfy pillow]) + item_amount($item[gin-soaked blotter paper]) + item_amount($item[giant marshmallow]) + item_amount($item[booze-soaked cherry]) + item_amount($item[beer-scented teddy bear]) == 0) return false;
		
		int j = 0, f = 0, b = 0, s = 0, jf, bs;
		string sven = visit_url("pandamonium.php?action=sven");
		if (contains_text(sven, "<option>Bognort")) b = 1;
		if (contains_text(sven, "<option>Flargwurm")) f = 1;
		if (contains_text(sven, "<option>Jim")) j = 1;
		if (contains_text(sven, "<option>Stinkface")) s = 1;
		jf = j+f;
		bs = b+s;
		
		boolean x, y;
		x = ((item_amount($item[sponge cake]) >= jf) || (item_amount($item[sponge cake]) + item_amount($item[comfy pillow]) >= jf) || (item_amount($item[sponge cake]) + item_amount($item[booze-soaked cherry]) >= jf) || (item_amount($item[comfy pillow]) + item_amount($item[booze-soaked cherry]) >= jf));
		y = ((item_amount($item[gin-soaked blotter paper]) >= bs) || (item_amount($item[gin-soaked blotter paper]) + item_amount($item[giant marshmallow]) >= bs) || (item_amount($item[gin-soaked blotter paper]) + item_amount($item[beer-scented teddy bear]) >= bs) || (item_amount($item[beer-scented teddy bear]) + item_amount($item[giant marshmallow]) >= bs));
		print("BCC: x is "+x+" and y is "+y+". j, f, b, s are "+j+", "+f+", "+b+", "+s+".", "purple");
		return x && y;
	}
	
	if (to_string(visit_url("pandamonium.php")) != "") {}
	if (to_string(visit_url("pandamonium.php")) != "") {}
	if (checkStage("friarssteel")) return true;
	//Let's do this check now to get it out the way. 
	if (!contains_text(visit_url("questlog.php?which=1"), "this is Azazel in Hell")) {
		print("BCC: Unable to detect organ of steel quest.", "purple");
		return false;
	} else if (contains_text(visit_url("questlog.php?which=2"), "this is Azazel in Hell")) {
		checkStage("friarssteel", true);
		return true;
	}

	string steelName() {
		if (!can_drink() && !can_eat()) { return "steel-scented air freshener"; }
		if (!can_drink() || my_path() == "Avatar of Boris" || my_path()=="Zombie Slayer") { return "steel lasagna"; }
		return "steel margarita";
	}
	boolean steelDoIt() {
		if (!can_drink() && !can_eat()) { return use(1,$item[steel-scented air freshener]); }
		if (!can_drink() || my_path() == "Avatar of Boris" || my_path()=="Zombie Slayer") { return eatsilent(1,$item[steel lasagna]); }
		return overdrink(1,$item[steel margarita]);
	}
	//SIMON CHANGEd
	int steelSpaceLeft() {
		int limt;
		if (!can_drink() && !can_eat()) { return spleen_limit() - my_spleen_use(); }
		if (!can_drink() || my_path() == "Avatar of Boris" || my_path()=="Zombie Slayer") { return fullness_limit() - my_fullness(); }
		return inebriety_limit() - my_inebriety();
	}
	
	if (i_a(steelName()) > 0 && steelSpaceLeft()>5) {
		steelDoIt();
		if (have_steel()) {
			checkStage("friarssteel", true);
			return true;
		} else {
			abort("There was some problem using the steel item. Perhaps use it manually?");
		}
	}
	
	//use the first days friars buff to get up our new item fam
	cli_execute("friars familiar");
	
	while (item_amount($item[Azazel's unicorn]) == 0) {
		//I'm hitting this page a couple times quietly because I'm fairly sure that the first time you visit him,
		//there's no drop-downs and this makes the script act screwy.
		visit_url("pandamonium.php?action=sven");
		visit_url("pandamonium.php?action=sven");
	
		//Solve the logic puzzle in the Hey Deze Arena to receive Azazel's unicorn
		cli_execute("mood execute");
		buMax();
		levelMe(safeMox($location[Infernal Rackets Backstage]), false);
		print("BCC: Getting Azazel's unicorn and the bus passes", "purple");
		setFamiliar("itemsnc");
		cli_execute("mood execute; conditions clear");
		while(i_a("bus pass")<5)
			bumAdv($location[Infernal Rackets Backstage], "", "itemsnc", "5 bus pass", "Let's get the bus passes first", "i");
		while (!logicPuzzleDone()) {
	
			//place florist friar plants
			choose_all_plants("i", $location[Infernal Rackets Backstage]);
				
			bumMiniAdv(1, $location[Infernal Rackets Backstage]);
		}
		int bog = 0, sti = 0, fla = 0, jim = 0;
		if (item_amount($item[giant marshmallow]) > 0) { bog = to_int($item[giant marshmallow]); }
		if (item_amount($item[beer-scented teddy bear]) > 0) { sti = to_int($item[beer-scented teddy bear]); }
		if (item_amount($item[booze-soaked cherry]) > 0) { fla = to_int($item[booze-soaked cherry]); }
		if (item_amount($item[comfy pillow]) > 0) { jim = to_int($item[comfy pillow]); }
		if (bog == 0) bog = to_int($item[gin-soaked blotter paper]);
		if (sti == 0) sti = to_int($item[gin-soaked blotter paper]);
		if (fla == 0) fla = to_int($item[sponge cake]);
		if (jim == 0) jim = to_int($item[sponge cake]);
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Bognort")) visit_url("pandamonium.php?action=sven&bandmember=Bognort&togive="+bog+"&preaction=try");
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Stinkface")) visit_url("pandamonium.php?action=sven&bandmember=Stinkface&togive="+sti+"&preaction=try");
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Flargwurm")) visit_url("pandamonium.php?action=sven&bandmember=Flargwurm&togive="+fla+"&preaction=try");
		if (contains_text(visit_url("pandamonium.php?action=sven"), "<option>Jim")) visit_url("pandamonium.php?action=sven&bandmember=Jim&togive="+jim+"&preaction=try");
		if (item_amount($item[Azazel's unicorn]) == 0) abort("The script doesn't have the unicorn, but it should have. Please do this part manually.");
	}
	
	while (item_amount($item[Azazel's lollipop]) == 0) {
		//levelMe(safeMox($location[The Laugh Floor]));
		void tryThis(item i, string preaction) {
			if (i_a(i) > 0) { 
				equip(i);
				visit_url("pandamonium.php?action=mourn&preaction="+preaction); 
			}
		}
	
		//Adventure in Belilafs Comedy Club until you encounter Larry of the Field of Signs. Equip the observational glasses and Talk to Mourn. 
		print("BCC: Getting Azazel's lollipop", "purple");
		eat_hot_dog("junkyard dog",$location[The Laugh Floor]);
		while (i_a($item[observational glasses]) == 0) bumAdv($location[The Laugh Floor], "", "items", "1 observational glasses, 5 imp air", "Getting the Observational Glasses", "i");
		if (my_path() != "Avatar of Boris") cli_execute("unequip weapon");
		if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") tryThis($item[Victor, the Insult Comic Hellhound Puppet], "insult");
		tryThis($item[observational glasses], "observe");
		if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") tryThis($item[hilarious comedy prop], "prop");
	}
	
	while (item_amount($item[Azazel's tutu]) == 0) {
		//After collecting 5 cans of imp air and 5 bus passes from the comedy blub and backstage, go the Moaning Panda Square to obtain Azazel's tutu. 
		print("BCC: Getting Azazel's tutu", "purple");
		while (item_amount($item[bus pass]) < 5) bumAdv($location[Infernal Rackets Backstage], "", "items", "5 bus pass", "Getting the 5 Bus Passes", "i");
		while (item_amount($item[imp air]) < 5)  bumAdv($location[The Laugh Floor], "", "items", "5 imp air", "Getting the 5 Imp Airs", "i");
		visit_url("pandamonium.php?action=moan");
	}
	
	visit_url("pandamonium.php?action=temp");
	steelDoIt();
	if (have_steel()) {
		checkStage("friarssteel", true);
		return true;
	} else {
		abort("There was some problem using the steel item. Perhaps use it manually?");
	}
	abort("There was some problem using the steel item. Perhaps use it manually or something?");
	return false;
}

boolean bcascGuild() {
	if ((!in_hardcore() && !bcasc_RunSCasHC) || my_path() == "Avatar of Boris" || my_path() == "Zombie Slayer" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete") return checkStage("guild", true);
	if (checkStage("guild")) return true;
	setFamiliar("");
	location loc;
	while (!guild_store_available()) {
		switch (my_primestat()) {
			case $stat[Muscle] : loc = $location[the outskirts of cobb's knob]; break;
			case $stat[Mysticality]: loc = $location[The Haunted Pantry]; break;
			case $stat[Moxie] : 
				loc = $location[The Sleazy Back Alley];
				buMax("");
				if (item_type(equipped_item($slot[pants])) != "pants") return false;
			break;
		}
		print("BCC: The script is trying to unlock the guild quest. If this adventures forever in the starting area, type 'ash set_property(\"bcasc_stage_guild\", my_ascensions())' into the CLI to stop it.", "purple");
	
		//place florist friar plants
		choose_all_plants("", loc);
		
		bumMiniAdv(1, loc);
		visit_url("guild.php?place=challenge");		
	}
	visit_url("guild.php?place=challenge");		
	
	if (guild_store_available() && my_basestat(my_primestat()) > 12) {
		checkStage("guild", true);
		return true;
	}
	return false;
}

boolean bcascHoleInTheSky() {
	if (checkStage("hits")) return true;
	if (can_interact()) {
		//Don't need to do anything here because the lair automatically gets these. 
	}
//SIMON: chANGed below
	if (can_interact() || my_path() == "Bugbear Invasion")
	{
		print("skipping hits");
		return checkStage("hits", true);
	}
	if (item_amount($item[steam-powered model rocketship]) == 0) {
		set_property("choiceAdventure675", 4);
		set_property("choiceAdventure676", 3);
		set_property("choiceAdventure677", 2);
		set_property("choiceAdventure678", 2);
		bumAdv($location[The Castle in the Clouds in the Sky (Top Floor)], "", "", "steam-powered model rocketship", "Picking up a steam-powered model rocketship to open up the Hole in the Sky", "-");
	}
	
	setFamiliar("items");
	setMood("i");
	buMax();
	cli_execute("conditions clear");
	levelMe(safeMox($location[The Hole in the Sky]));
	cli_execute("conditions clear");
	if(!in_hardcore() && i_a("star hat")<1)
		cli_execute("pull star hat");
	if(!in_hardcore() && i_a("star crossbow")<1)
		cli_execute("pull star crossbow");
	
	while (i_a("star hat") == 0 || (i_a("star crossbow") == 0 && my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") || need_key($location[The Hole in the Sky])) {
		print("doing hits adv","lime");
	
		//place florist friar plants
		choose_all_plants("i", $location[The Hole in the Sky]);
		
		bumMiniAdv(1, $location[The Hole in the Sky]);
		if (item_amount($item[star chart]) > 0) {
			if (i_a("star hat") == 0 && creatable_amount($item[star hat]) > 0) { if(!retrieve_item(1, $item[star hat])) {} }
			if (i_a("star crossbow") == 0 && creatable_amount($item[star crossbow]) > 0 && item_amount($item[star chart]) > 0 && my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") { if(!retrieve_item(1, $item[star crossbow])) {} }
			if(i_a("Richard's star key") == 0 && creatable_amount($item[Richard's star key]) > 0 && !retrieve_item(1, $item[Richard's star key]))
			{
				abort("Line 6444 should be able to make a star key, but didn't....");
			}
		}
	}
	checkStage("hits", true);
	return true;
}

boolean bcascFunHouse() {
	if (bcasc_cloverless) return false;
	if (!in_hardcore()) return false;
	if (my_path() == "Avatar of Boris" || my_path() == "Zombie Slayer" || my_path() == "Way of the Surprising Fist") return false;

	//Returns true if you lack one of the kickass astral weapons for your Mox/Mus class as appropriate.
	boolean dontHaveAstral() {
		switch (my_primestat()) {
			case $stat[Muscle] :
				return (i_a("astral mace") + i_a("astral bludgeon") == 0);
			case $stat[Moxie] :
				return (i_a("astral longbow") + i_a("astral pistol") == 0);
		}
		return false;
	}

	void makeClownosity() {
		if (!maximize("4 clownosity -familiar -1 tie", true)) {
			int clownosity = min(i_a($item[big red clown nose]), 3) + min(i_a($item[clown shoes]), 3) + min(i_a($item[bloody clown pants]), 1)
				+ (2 * min(i_a($item[polka-dot bow tie]), 1)) + (2 * min(i_a($item[balloon sword]), 1)) + (2 * min(i_a($item[clownskin belt]), 3));

			if (i_a($item[clown skin]) > 0) {
				if (i_a($item[clown wig]) == 0 && (i_a($item[clown skin]) >= 2 || clownosity == 2 || clownosity == 3)) {
					cli_execute("make clown wig");
				}
	
				if (i_a($item[clown skin]) >= 1 && i_a($item[big red clown nose]) >= 1 && (i_a($item[clown wig]) >= 1
						|| (clownosity == 2 && i_a($item[big red clown nose]) >= 2) || clownosity == 3)) {

					cli_execute("make clownskin belt");
				}
			}
	
			if (my_primestat() == $stat[Muscle] && i_a($item[balloon sword]) == 0 && i_a($item[long skinny balloon]) >= 3) {
				cli_execute("make balloon sword");
			}
	
			if (i_a($item[balloon helmet]) == 0 && i_a($item[clown wig]) == 0 && i_a($item[foolscap fool's cap]) == 0 && i_a($item[long skinny balloon]) >= 2 && clownosity == 3) {
				cli_execute("make balloon helmet");		
			}
		}
	}

	boolean getLegendaryEpic(string className, string epicWeapon, string theOtherThingYouNeed, string theLegendaryEpicWeaponYouWantToGet) {
		if (i_a(epicWeapon) == 0) { return false; }

		print("BCC: Getting the "+className+" Legendary Epic Weapon", "purple");

		if (i_a(theOtherThingYouNeed) == 0) {
			// Hit the guild page until we see the clown thingy.
			while (!contains_text(visit_url("place.php?whichplace=plains"), "funhouse.gif")) {
				print("BCC: Visiting the guild to unlock the funhouse", "purple");
				visit_url("guild.php?place=scg");
			}

			makeClownosity();

			if (!maximize("4 clownosity -familiar -1 tie", true)) {
				set_property("choiceAdventure151", "2"); // DON'T fight the Clownlord

				//Prepare for adventuring
				buMax("items");
				setFamiliar("items");
				setMood("i");

				print("BCC: Adventuring once at a time to get clownosity items.", "purple");

				while (!maximize("4 clownosity -familiar -1 tie", true)) {
	
					//place florist friar plants
					choose_all_plants("i", $location[the \"fun\" house]);
					
					bumMiniAdv(1, $location[the \"fun\" house]);
					makeClownosity();
				}
			}

			set_property("choiceAdventure151", "1"); // fight the Clownlord

			//Prepare for adventuring
			buMax("items");
			setFamiliar("items");
			setMood("");
			maximize("4 clownosity -familiar -1 tie", false);

			print("BCC: Getting "+theOtherThingYouNeed+".", "purple");

			cli_execute("condition add 1 " + theOtherThingYouNeed);
	
			//place florist friar plants
			choose_all_plants("", $location[the \"fun\" house]);
				
			bumMiniAdv(my_adventures(), $location[the \"fun\" house]);
		}

		if (cli_execute("make "+theLegendaryEpicWeaponYouWantToGet)) {}
		return true;
	}

	if (my_class() == $class[Seal Clubber] && my_buffedstat(my_primestat()) > 15 && i_a("Bjorn's Hammer") == 1 && i_a("Hammer of Smiting") == 0 && i_a("Sledgehammer of the V&aelig;lkyr") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("SC", "Bjorn's Hammer", "distilled seal blood", "Hammer of Smiting");
	}

	if (my_class() == $class[Turtle Tamer] && my_buffedstat(my_primestat()) > 15 && i_a("Mace of the Tortoise") == 1 && i_a("Chelonian Morningstar") == 0 && i_a("Flail of the Seven Aspects") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("TT", "Mace of the Tortoise", "turtle chain", "Chelonian Morningstar");
	}

	if (my_class() == $class[Pastamancer] && my_buffedstat(my_primestat()) > 15 && (!have_skill($skill[springy fusilli]) || bcasc_bartender || bcasc_chef) && i_a("Pasta of Peril") == 1 && i_a("Greek Pasta of Peril") == 0 && i_a("Wrath of the Capsaician Pastalords") == 0) {
		return getLegendaryEpic("P", "Pasta of Peril", "high-octane olive oil", "Greek Pasta of Peril");
	}

	if (my_class() == $class[Sauceror] && my_buffedstat(my_primestat()) > 15 && (have_skill($skill[jalape&ntilde;o saucesphere]) || bcasc_bartender || bcasc_chef) && i_a("5-alarm Saucepan") == 1 && i_a("17-alarm Saucepan") == 0 && i_a("Windsor Pan of the Source") == 0) {
		return getLegendaryEpic("S", "5-Alarm Saucepan", "Peppercorns of Power", "17-alarm Saucepan");
	}

	if (my_class() == $class[Disco Bandit] && my_buffedstat(my_primestat()) > 15 && i_a("Disco Banjo") == 1 && i_a("Shagadelic Disco Banjo") == 0 && i_a("Seeger's Unstoppable Banjo") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("DB", "Disco Banjo", "vial of mojo", "Shagadelic Disco Banjo");
	}

	if (my_class() == $class[Accordion Thief] && my_buffedstat(my_primestat()) > 15 && i_a("Rock and Roll Legend") == 1 && i_a("Squeezebox of the Ages") == 0 && i_a("The Trickster's Trikitixa") == 0) {
		if (dontHaveAstral())
			return getLegendaryEpic("AT", "Rock and Roll Legend", "golden reeds", "Squeezebox of the Ages");
	}

	return false;
}
boolean bcascInnaboxen() {
	if (bcasc_cloverless) return false;
	if (my_path() == "Bees Hate You" || my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarslberg" || my_path() == "Avatar of Sneaky Pete") return false;
	if (checkStage("innaboxen")) return true;
	if (!in_hardcore()) return checkStage("innaboxen", true);
	boolean trouble = false;
	
	int[item] campground = get_campground();
	if((bcasc_bartender && campground contains to_item("bartender-in-the-box")) && (bcasc_chef && campground contains to_item("chef-in-the-box"))) {
		checkStage("innaboxen", true);
		return true;
	} else if((bcasc_bartender && !bcasc_chef) && campground contains to_item("bartender in-the-box")) {
		checkStage("innaboxen", true);
		return true;
	} else if((!bcasc_bartender && bcasc_chef) && campground contains to_item("chef-n-the-box")) {
		checkStage("innaboxen", true);
		return true;
	} else if(!bcasc_bartender && !bcasc_chef) {
		checkStage("innaboxen", true);
		return true;
	}
	
	//Thanks, gruddlefitt!
	item bcascWhichEpic() {
		item [class] epicMap;
		epicMap[$class[Seal Clubber]] = $item[Bjorn's Hammer];
		epicMap[$class[Turtle Tamer]] = $item[Mace of the Tortoise];
		epicMap[$class[Pastamancer]] = $item[Pasta of Peril];
		epicMap[$class[Sauceror]] = $item[5-Alarm Saucepan];
		epicMap[$class[Disco Bandit]] = $item[Disco Banjo];
		epicMap[$class[Accordion Thief]] = $item[Rock and Roll Legend];
		return epicMap[my_class()];
	}
	
	boolean getBox() {
		//I know, we should already have run this, but what's a visit to the hermit between friends?
		if (i_a("box") > 0) { return true; }
		item epicWeapon = bcascWhichEpic();
		if (item_amount(epicWeapon) == 0) { return false; }
		
		//Then hit the guild page until we see the clown thingy.
		while (!contains_text(visit_url("place.php?whichplace=plains"), "funhouse.gif")) {
			print("BCC: Visiting the guild to unlock the funhouse", "purple");
			visit_url("guild.php?place=scg");
		}
		
		if (cloversAvailable(true) > 0) {
			visit_url("adventure.php?snarfblat=20&confirm=on");
			return true;
		}
		
		return false;
	}
	
	if (index_of(visit_url("questlog.php?which=2"), "defeated the Bonerdagon") > 0) {
		//At this point, we can clover the Cemetary for innaboxen. 
		cloversAvailable();
		
		//Apart from the brain/skull, we need a box and spring and the chef's hat/beer goggles.
		if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Chef-in-the-Box") && bcasc_chef) {
			//We're not even going to bother to try if we don't have a chef's hat. 
			if (i_a("chef's hat") > 0 && (i_a("spring") > 0 || knoll_available())) {
				print("BCC: Going to try to make a chef", "purple");
				if (getbox()) {
					if (creatable_amount($item[chef-in-the-box]) == 0) {
						//Then the only thing we could need would be brain/skull, as we've checked for all the others. 
						if (cloversAvailable(true) > 0) {
							visit_url("adventure.php?snarfblat=58&confirm=on");
							cli_execute("use chef-in-the-box");
						} else {
							print("BCC: Uhoh, we don't have enough clovers to get the brain/skull we need.", "purple");
							trouble = true;
						}
					} else {
						cli_execute("use chef-in-the-box");
					}
				} else {
					print("BCC: There was a problem getting the box.", "purple");
					trouble = true;
				}
			}
		}
		
		if (bcasc_bartender) {
			if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Bartender-in-the-Box")) {
				if (i_a("spring") > 0 || knoll_available()) {
					print("BCC: Going to try to get a bartender.", "purple");
					if (getBox()) {
						if (creatable_amount($item[bartender-in-the-box]) == 0) {
							if (creatable_amount($item[brainy skull]) + available_amount($item[brainy skull]) == 0) {
								if (cloversAvailable(true) > 0) {
									visit_url("adventure.php?snarfblat=58&confirm=on");
								} else {
									print("BCC: Uhoh, we don't have enough clovers to get the brain/skull we need.", "purple");
									trouble = true;
								}
							}
							
							while (creatable_amount($item[beer goggles]) + available_amount($item[beer goggles]) == 0) {
								bumAdv($location[A Barroom Brawl], "", "items", "1 beer goggles", "Getting the beer goggles");
							}
							
							if (creatable_amount($item[bartender-in-the-box]) > 0) {
								cli_execute("use bartender-in-the-box");
							}
						} else {
							cli_execute("use bartender-in-the-box");
						}
					} else {
						print("BCC: There was a problem getting the box.", "purple");
						trouble = true;
					}
				}
			}
		}
		
		if (!trouble) {
			checkStage("innaboxen", true);
			return true;
		} else {
			return false;
		}
	} else {
		return false;
	}
}

boolean bcascKnob() {
	if (checkStage("knob")) return true;
	while (contains_text(visit_url("place.php?whichplace=plains"), "knob1.gif") && item_amount($item[knob goblin encryption key]) == 0) {
		bumAdv($location[the outskirts of cobb's knob], "", "", "1 knob goblin encryption key", "Let's get the Encryption Key");
	}
	checkStage("knob", true);
	return true;
}

boolean bcascKnobKing() {
	if (checkStage("knobking")) return true;
	if (is_equal_to(get_property("questL05Goblin"), "finished")) return checkStage("knobking", true);
	//Before we go into the Cobb's Knob Harem, we gotta use the map. 
	if (item_amount($item[Cobb's Knob map]) > 0) {
		use(1, $item[Cobb's Knob map]);
	}
	
	if (can_interact()) {
		print("BCC: You can interact, so do this the lazy way.", "purple");
		while (is_not_yet(get_property("questL05Goblin"), "finished")) {
			cli_execute("outfit Knob Goblin Harem Girl disguise");
			cli_execute("use knob goblin perfume");
			if(my_path()=="Heavy Rains")
				abort("Fight aquagoblin yourself");
			bumAdv($location[Throne Room], "+outfit Knob Goblin Harem Girl disguise", "meatboss", "", "Killing the Knob King");
		}
		if(get_property("questL05Goblin")=="finished")
			return checkStage("knobking", true);
		else
			abort("Somehow failed to beat the goblin king");
	}
	
	if (is_not_yet(get_property("questL05Goblin"), "finished")) {
		if (my_path() != "Bees Hate You" && my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris" && my_primestat() != $stat[Moxie]) {
			//First we need the KGE outfit. 
			while (i_a($item[Knob Goblin elite pants]) == 0 || i_a($item[Knob Goblin elite polearm]) == 0 || i_a($item[Knob Goblin elite helm]) == 0) {
				bumAdv($location[Cobb's Knob Barracks], "", "items", "1 Knob Goblin elite pants, 1 Knob Goblin elite polearm, 1 Knob Goblin elite helm", "Getting the KGE Outfit");
			}

			//Then we need the cake. 
			if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Dramatic")) {
				if (!use(1, to_item("Dramatic range")))
				if (!contains_text(visit_url("campground.php?action=inspectkitchen"), "Dramatic")) abort("You need a dramatic oven for this to work.");
			}

			if (my_basestat($stat[muscle]) >= 15 && my_basestat($stat[moxie]) >= 15) {
				while (available_amount($item[Knob cake]) + creatable_amount($item[Knob cake]) == 0) {
					while (item_amount($item[Knob frosting]) == 0) {
						bumAdv($location[Cobb's Knob Kitchens], "+outfit knob goblin elite guard uniform", "", "1 knob frosting", "Getting the Knob Frosting");
					}
					
					while (available_amount($item[unfrosted Knob cake]) + creatable_amount($item[unfrosted Knob cake]) == 0) {
						bumAdv($location[Cobb's Knob Kitchens], "+outfit knob goblin elite guard uniform", "", "1 Knob cake pan, 1 knob batter", "Getting the Knob Pan and Batter");
					}
				}
				if (item_amount($item[Knob cake]) == 0) {
					if(to_boolean(get_property("requireBoxServants"))) {
						if(user_confirm("BCC: You have requireBoxServants set to true. The script want to create a Knob Cake, do you wish to continue?")) {
							set_property("requireBoxServants", false);
							if (cli_execute("make knob cake")) {}
							set_property("requireBoxServants", true);
						}
					}
					else 
					{
						if (cli_execute("make knob cake")) {}
					}
				}

				//Now the Knob Goblin King has 55 Attack, and we'll be fighting him with the MCD set to 7. So that's 55+7+7=69 Moxie we need. 
				//Arbitrarily using 75 because will need the Cobb's Knob Harem outfit equipped. 
				if (item_amount($item[Knob cake]) > 0) {
					if(my_buffedstat(my_primestat()) < 75)
						return false;
					buMax("+outfit knob goblin elite guard uniform");
					if(my_path()=="Heavy Rains")
						abort("Fight aquagoblin yourself");
					while (!contains_text(visit_url("questlog.php?which=2"), "slain the Goblin King")) {
						bumAdv($location[Throne Room], "+outfit knob goblin elite guard uniform", "meatboss", "", "Killing the Knob King");
					}
					checkStage("knobking", true);
					return true;
				}

				if (contains_text(visit_url("questlog.php?which=2"), "slain the Goblin King") && !dispensary_available() && my_path() != "Bees Hate You") {
					//Just get the password.
					cli_execute("outfit knob goblin elite guard uniform");
					while (!dispensary_available() && my_path() != "Bees Hate You" ) {
						print("BCC: Adventuring once to learn it's FARQUAR. Surely you'd remember this when you reincarnate?", "purple");
						adventure(1, $location[Cobb's Knob Barracks]);
					}
				}
			}
		} else {
			//Bees hate Cobb's Knob Harem girl outfits slightly less, and moxie classes need a ranged weapon.
			while (i_a($item[Knob Goblin Harem pants]) == 0 || i_a($item[Knob Goblin Harem Veil]) == 0) {
				bumAdv($location[Cobb's Knob Harem], "", "items", "1 Knob Goblin Harem pants, 1 Knob Goblin Harem Veil", "Getting the Cobb's Knob Harem Outfit", "i");
			}
			
			//Then we need to be perfumed up, but not before we're powerful enough to beat Mr King
			//Now the Knob Goblin King has 55 Attack, and we'll be fighting him with the MCD set to 7. So that's 55+7+7=69 Moxie we need. 
			//Arbitrarily using 75 because will need the Cobb's Knob Harem outfit equipped. 
			buMax();
			if (my_buffedstat(my_primestat()) >= 75) {
				if(my_path() == "Bees Hate You" || (my_path() != "Bees Hate You" && i_a($item[Knob Goblin perfume]) == 0)) {
					print("BCC: Getting perfumed up for the King");
					cli_execute("outfit Knob Goblin Harem Girl Disguise");
					while(have_effect($effect[Knob Goblin Perfume]) == 0)
					{
						bumminiAdv(1, $location[Cobb's Knob Harem]);
					}
				}
				else
					use(1, $item[Knob Goblin perfume]);

				buMax("+outfit Knob Goblin Harem Girl Disguise");
				if(my_path()=="Heavy Rains")
					abort("Fight aquagoblin yourself");
				bumAdv($location[Throne Room], "+outfit Knob Goblin Harem Girl Disguise", "meatboss", "", "Killing the Knob King");
				checkStage("knobking", true);
				return true;
			}
		}
	} else {
		checkStage("knobking", true);
		return true;
	}
	return false;
}

boolean bcascKnobPassword() {
	if (item_amount($item[Cobb's Knob lab key]) == 0) return false;
	if (my_path() == "Bees Hate You" || my_path() == "Way of the Surprising Fist" || my_path() == "Avatar of Boris") return false;
	while (!dispensary_available() && my_path() != "Bees Hate You") {
		while (i_a($item[Knob Goblin elite pants]) == 0 || i_a($item[Knob Goblin elite polearm]) == 0 || i_a($item[Knob Goblin elite helm]) == 0) {
			bumAdv($location[Cobb's Knob Barracks], "", "items", "1 Knob Goblin elite pants, 1 Knob Goblin elite polearm, 1 Knob Goblin elite helm", "Getting the KGE Outfit");
		}
		cli_execute("outfit knob goblin elite guard uniform");
		
		if (my_adventures() == 0)
		{
			cli_execute("shower "+my_primestat());
			abort("No adventures left trying to learn farquar :(");
		}
		print("BCC: Adventuring once to learn it's FARQUAR. Surely you'd remember this when you reincarnate.", "purple");
		adventure(1, $location[Cobb's Knob Barracks]);
	}
	if (dispensary_available())
		return true;
	else
		return false;
}

void bcascLairFightNS() {
	print("BCC: Fighting the NS", "purple");

	set_property("choiceAdventure685", "1"); //AoJ choiceadv
	set_property("choiceAdventure686", "1"); //AoJ choiceadv
	set_property("choiceAdventure687", "1"); //AoJ choiceadv
	set_property("choiceAdventure688", "1"); //AoJ choiceadv
	if (canMCD()) cli_execute("mcd 0");
		
	if (my_path() != "Avatar of Boris" && my_path() != "Avatar of Sneaky Pete" && my_path() != "Avatar of Jarlsberg" && my_path() != "Zombie Slayer" && my_path() != "KOLHS" && my_path() != "Heavy Rains") {
		if (item_amount($item[wang]) > 0) cli_execute("untinker wang");
		if (item_amount($item[ng]) > 0) cli_execute("untinker ng");
		if (item_amount($item[wand of nagamar]) == 0) {
			if (!retrieve_item(1, $item[wand of nagamar])) {
				if (!take_storage(1, $item[wand of nagamar])) {
					if (i_a($item[ruby W]) == 0) {thingToGet = $item[ruby W]; bumAdv($location[Pandamonium Slums], "items", "hebo", "1 ruby W", "Getting a ruby W", "i", "consultHeBo");}
					if (i_a($item[metallic A]) == 0) {thingToGet = $item[metallic A]; bumAdv($location[The Penultimate Fantasy Airship], "items", "hebo", "1 metallic A", "Getting a metallic A", "i", "consultHeBo");}
					if (i_a($item[lowercase N]) == 0) {thingToGet = $item[lowercase n]; bumAdv($location[The Valley of Rof L'm Fao], "items", "hebo", "1 lowercase N", "Getting a lowercase N", "i", "consultHeBo");}
					if (i_a($item[original G]) == 0) {thingToGet = $item[original G]; bumAdv($location[The Castle in the Clouds in the Sky (Basement)], "items", "hebo", "1 original G", "Getting an original G", "i", "consultHeBo");}
					cli_execute("make wand of nagamar");
				}
			}
		}
		if (item_amount($item[wand of nagamar]) == 0) abort("Failed to get the wand!");
	}
	
	print("maximizeing","lime");
	if(i_a("boris's helm (askew)")>0)
		cli_execute("fold boris's helm");
	string maxstr;
	if(my_primestat()==$stat[moxie])
	{
		maxstr="maximize mox, -0.1 ML, +weapon damage, elemental damage -1 tie";
		if(my_path()!="Way of the Surprising Fist")
			maxstr+=", -melee";
	}
	else
	{
		maxstr="maximize mus, -0.1 ML, +5 weapon damage, +5 elemental damage, -1 tie";
		if(my_path()!="Way of the Surprising Fist")
			maxstr+=", +melee";
	}
	print("running maximizer with stirng "+maxstr);
	cli_execute(maxstr);
	if(my_path()!="Avatar of Boris" && my_path()!="Way of the Surprising Fist")
	{
		print("now maximizing \"maximize -tie, +shield\"");
		cli_execute("maximize -tie, +shield");
	}
	print("heal","lime");
	cli_execute("uneffect beaten up; restore hp; restore mp");
	
	setFamiliar("");
	if (bcasc_fightNS && my_path() != "Bugbear Invasion") {
		if(my_path()=="Heavy Rains")
		{
			if(have_familiar($familiar[Cuddlefish]))
				use_familiar($familiar[Cuddlefish]);
			//	<green lantern>;
			//dummy buffs
			if(have_effect($effect[Go Get \'Em\, Tiger!])==0)
				use(1,$item[Ben-Gal&trade; Balm]);
			if(have_effect($effect[Glittering Eyelashes])==0)
				use(1,$item[glittery mascara]);
			if(have_effect($effect[Butt-Rock Hair])==0)
				use(1,$item[hair spray]);
			if(have_effect($effect[Radiating Black Body&trade;])==0)
				use(1,$item[black body&trade; spray]);
			if(have_effect($effect[Black Face])==0)
				use(1,$item[black facepaint]);
			if(have_effect($effect[Erudite])==0)
				use(1,$item[black sheepskin diploma]);
			if(have_effect($effect[Pasta Oneness])==0)
				use_skill(1,$skill[manicotti meditation]);
			if(have_effect($effect[Seal Clubbing Frenzy])==0)
				use_skill(1,$skill[seal clubbing frenzy]);
			if(have_effect($effect[Patience of the Tortoise])==0)
				use_skill(1,$skill[patience of the tortoise]);
			if(have_effect($effect[Saucemastery])==0)
				use_skill(1,$skill[sauce contemplation]);
			if(have_effect($effect[Disco State of Mind])==0)
				use_skill(1,$skill[disco aerobics]);
			if(have_effect($effect[Mariachi Mood])==0)
				use_skill(1,$skill[moxie of the mariachi]);
			if(have_effect($effect[walberg's dim bulb])==0)
				use_skill(1,$skill[walberg's dim bulb]);
			if(have_effect($effect[springy fusilli])==0)
				use_skill(1,$skill[springy fusilli]);
			if(have_effect($effect[disco fever])==0)
				use_skill(1,$skill[disco fever]);
			if(have_effect($effect[jalape&ntilde;o saucesphere])==0)
				use_skill(1,$skill[jalape&ntilde;o saucesphere]);

			//suvivability
			if(have_effect($effect[Shield of the Pastalord])==0 && have_skill($skill[shield of the pastalord]))
				use_skill(1,$skill[Shield of the Pastalord]);
			if(have_effect($effect[astral shell])==0)
				use_skill(1,$skill[astral shell]);
			if(have_effect($effect[ghostly shell])==0)
				use_skill(1,$skill[ghostly shell]);
			if(have_effect($effect[leash of linguini])==0)
				use_skill(1,$skill[leash of linguini]);
			if(have_effect($effect[Blubbered Up])==0)
				use_skill(1,$skill[blubber up]);
			if(have_effect($effect[sauce monocle])==0)
				use_skill(1,$skill[sauce monocle]);
			if(have_effect($effect[song of sauce])==0)
				use_skill(1,$skill[song of sauce]);
			if(have_effect($effect[frigidalmatian])==0)
				use_skill(1,$skill[frigidalmatian]);
			if(have_effect($effect[tenacity of the snapper])==0)
				use_skill(1,$skill[tenacity of the snapper]);
			if(have_effect($effect[reptilian fortitude])==0)
				use_skill(1,$skill[reptilian fortitude]);
			if(have_effect($effect[elemental saucesphere])==0)
				use_skill(1,$skill[elemental saucesphere]);
			if(have_effect($effect[scarysauce])==0)
				use_skill(1,$skill[scarysauce]);
			if(have_effect($effect[empathy])==0)
				use_skill(1,$skill[empathy of the newt]);
			if(have_effect($effect[stevedave's shanty of superiority])==0)
				use_skill(1,$skill[stevedave's shanty of superiority]);
			if(have_skill($skill[Jackasses' Symphony of Destruction]) && have_effect($effect[Jackasses' Symphony of Destruction])==0)
				use_skill(1,$skill[Jackasses' Symphony of Destruction]);

				
			//remove rain ml
			cli_execute("uneffect the rain in loathing; uneffect Personal Thundercloud; uneffect ashen burps");
			clear_combat_macro();
			abort("Kill the sorceress yourself (try to stunlock");
		}
		visit_url("lair6.php?place=5");
//abort("fight the sorceress yourself, remove this abort from line 4850 when you have better combat skills");
		for i from 1 to 3 {
			if (!contains_text(bumRunCombat(), "You win the fight!")) {
				abort("Maybe you should fight Her Naughtiness yourself...");
			}
		}
		ascendLog("yes");
		if (!contains_text(visit_url("trophy.php"), "not currently entitled to")) abort("You're entitled to some trophies!");
		print("BCC: Hi-keeba!", "purple");
		visit_url("lair6.php?place=6");
		if (get_property("bcasc_getItemsFromStorage") == "true") {
			print("BCC: Getting all your items out of Storage. Not all bankers are evil, eh?", "purple");
			visit_url("storage.php?action=pullall&pwd=");
		}
		abort("Tada! Thank you for using bumcheekascend.ash.");
	} else if (my_path() == "Bugbear Invasion") {
		print("attempting to kill the captain!");
		string txt = visit_url("place.php?whichplace=bugbearship&action=bb_bridge");
		if(contains_text(txt,"it vomits a massive spray of acid onto the lock next to the bridge door"))
			txt = visit_url("place.php?whichplace=bugbearship&action=bb_bridge");
		if(!contains_text(txt,"Water drips from pipes overhead into massive bottomless pits on either side of the catwalk"))
			abort("Something wrong with string. Expected it to contain \"Water drips from pipes overhead into massive bottomless pits on either side of the catwalk\"but read \n\n"+txt);
			
		txt=visit_url("choice.php?pwd&whichchoice=591&option=1&choiceform1=...");
		if(!contains_text(txt,"Half of his face has been replaced by a metal plate riveted into his skull"))
			abort("Something wrong with string. Expected it to contain \"Half of his face has been replaced by a metal plate riveted into his skull\"but read \n\n"+txt);
			
		txt=visit_url("choice.php?pwd&whichchoice=592&option=1&choiceform1=...");
		if(!contains_text(txt,"It is true that our first colonists have gone native and forgotten who they are"))
			abort("Something wrong with string. Expected it to contain \"It is true that our first colonists have gone native and forgotten who they are\"but read \n\n"+txt);
			
		txt=visit_url("choice.php?pwd&whichchoice=593&option=1&choiceform1=Let%27s+Get+It+Started+In+Here");
		if(!contains_text(txt,"They must choose the captain with an arm"))
			abort("Something wrong with string. Expected it to contain \"They must choose the captain with an arm\" but read \n\n"+txt);
			
		string results=bumRunCombat();
		print(results,"lime");
		if(contains_text(results, "You win the fight"))
		{
			print("BCC: Hi-keeba!", "purple");
			visit_url("lair6.php?place=6");
			print("BCC: Getting all your items out of Storage. Not all bankers are evil, eh?", "purple");
			visit_url("storage.php?action=pullall&pwd=");
			abort("Tada! Thank you for using bumcheekascend.ash.");
		}
		else
		{
			abort("Got beaten up by bugbear captain");
		}
	} else {
		abort("Bring it on.");
	}
}

boolean bcascLairFirstGate() {
	boolean tryPull(string i, boolean abortOnFailure) {
		item it = to_item(i);
		
		if(pulls_remaining() > 0)
			if (take_storage(1, it))
				return true;
		if (abortOnFailure) abort("We need a '"+i+"', but the script cannot get this item (if you are in softcore, you can't pull it either).");
		return false;
	}
	boolean tryPull(string i) { return tryPull(i, false); }

	if (checkStage("lair1")) return true;
	load_current_map("bumrats_lairitems", lairitems);
	html = visit_url("lair1.php?action=gates");
	int numGatesWeHaveItemFor = 0;
	
	foreach x in lairitems {
		if (contains_text(html, lairitems[x].gatename)) {
			print("BCC: We see "+lairitems[x].gatename, "purple");
			
			if (lairitems[x].a == "dod") {
				while (item_amount(bangPotionWeNeed().to_item()) == 0 && have_effect(effectWeNeed())==0) {
					cli_execute("use * dead mimic; use * large box; use * small box");
					
					setFamiliar("items");
					setMood("i+");
					while (!identifyBangPotions() && (bangPotionWeNeed() == "")) {
						if(!in_hardcore() && available_amount($item[large box])==0)
							cli_execute("pull large box");
						//if we have a box use it
						if(available_amount($item[large box])>0)
						{
							cli_execute("use * dead mimic; use * large box; use * small box");
						}
						else //otherwise get one
						{
	
							//place florist friar plants
							cli_execute("conditions clear");
							choose_all_plants("i", $location[The Dungeons of Doom]);
							
							bumMiniAdv(1, $location[The Dungeons of Doom]);
						}
					}
					
					//if we ae done with above loop we know what potion we want, but may not have it
					if(item_amount(bangPotionWeNeed().to_item()) == 0 || have_effect(effectWeNeed())==0)
					{
						if(!in_hardcore())
							cli_execute("pull "+bangPotionWeNeed());
						else 
						{
							bumAdv($location[The Dungeons of Doom], "", "", "1 "+bangPotionWeNeed(), "Farming bang potion", "+i");
						}
					}
				}
				
				if (item_amount(bangPotionWeNeed().to_item()) > 0 || have_effect(effectWeNeed())>0) { numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1; }
				continue;
			} 
				
			//try to pull if needed
			if(!in_hardcore() && i_a(lairitems[x].a) < 1)
				cli_execute("pull "+lairitems[x].a);
			
			if (i_a(lairitems[x].a) > 0 || have_effect(to_effect(lairitems[x].effectname)) > 0) {
				print("BCC: We have the effect/item, for that gate.", "purple");
				numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
			} else {
				print("BCC: We do not have the item for that gate. (We need a "+lairitems[x].a+" for that.)", "purple");
				
				//So get the item, using a clover for the gum.  
				if (contains_text(lairitems[x].a, "chewing gum") && i_a(to_string(lairitems[x].a)) == 0) {
					print("BCC: I'm going to get the chewing gum using a clover.", "purple");
					if (i_a("pack of chewing gum") == 0) {
						if (cloversavailable(true) > 0) {
							visit_url("adventure.php?snarfblat=45&confirm=on");
							cli_execute("use pack of chewing gum");
							numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						} else {
							print("BCC: I dont have a clover, so am going to adventure to get the gum. .", "purple");
							if(bumAdv($location[South of the Border], "", "", "1 " + to_string(lairitems[x].a), "Hunting for Chewing Gums", "-"))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						}
					} else {
						cli_execute("use pack of chewing gum");
						numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
					}
				} else {
					//Now check for any other item(s).
					thingToGet = to_item(lairitems[x].a);
					switch (lairitems[x].a) {
						case " gremlin juice" :
						case "gremlin juice" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("gremlin juice")==0)
								 (bumAdv($location[post-war junkyard], "items", "hebo", "1 gremlin juice", "Getting gremlin juice", "i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "wussiness potion" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("wussiness potion")==0)
								 (bumAdv($location[Pandamonium Slums], "items", "hebo", "1 wussiness potion", "Getting a wussiness potion", "+i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "thin black candle" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("thin black candle")==0)
								 (bumAdv($location[The Castle in the Clouds in the Sky (Top Floor)], "items", "hebo", "1 thin black candle", "Getting a thin black candle", "-i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "Mick's IcyVapoHotness Rub" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("Mick's IcyVapoHotness Rub")==0)
								(bumAdv($location[The Castle in the Clouds in the Sky (Top Floor)], "items", "hebo", "1 Mick's IcyVapoHotness Rub", "Getting a Mick's IcyVapoHotness Rub", "+i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "pygmy pygment" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("pygmy pygment")==0)
								 (bumAdv($location[The Hidden Park], "items", "hebo", "1 pygmy pygment", "Getting some pygmy pygment", "+i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "super-spiky hair gel" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else {
								bumUse(i_a($item[Penultimate Fantasy chest]), $item[Penultimate Fantasy chest]);
								
								if (i_a($item[super-spiky hair gel]) == 0) {
									buMax("items");
									setFamiliar("hebo");
									setMood("i");
									
									while (i_a($item[super-spiky hair gel]) == 0) {
	
										//place florist friar plants
										choose_all_plants("I", $location[The Penultimate Fantasy Airship]);
										
										bumMiniAdv(1, $location[The Penultimate Fantasy Airship], "consultHeBo");
										bumUse(i_a($item[Penultimate Fantasy chest]), $item[Penultimate Fantasy chest]);
									}
								}
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							}
						break;
						
						case "Angry Farmer candy" :
						case "Tasty Fun Good rice candy" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("Angry Farmer Candy")==0 && i_a("Tasty Fun Good rice Candy")==0)
							{
								 bumAdv((lairitems[x].a == "Tasty Fun Good rice candy" ? $location[The Valley of Rof L'm Fao] : $location[The Castle in the Clouds in the Sky (Top Floor)]), "items", "hebo", "1 " + lairitems[x].a, "Getting " + (lairitems[x].a == "Angry Farmer candy" ? "an" : "a") + lairitems[x].a, "i", "consultHeBo");
								}
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "adder bladder" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("adder bladder")==0)
								 (bumAdv($location[The Black Forest], "items", "hebo", "1 adder bladder", "Getting an adder bladder", "i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "Black No. 2" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("Black No. 2")==0)
								 (bumAdv($location[The Black Forest], "items", "hebo", "1 Black No. 2", "Getting a Black No. 2", "i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "handsomeness potion" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("handsomeness potion")==0)
								 (bumAdv($location[South of the Border], "items", "hebo", "1 handsomeness potion", "Getting a handsomeness potion", "+i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "Meleegra pills" :
							if (tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("Meleegra pills")==0)
								 (bumAdv($location[South of the Border], "items", "items", "1 Meleegra pills", "Getting some Meelegra pills", "-i"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						case "marzipan skull" :
							if (gnomads_available()) {
								cli_execute("buy marzipan skull");
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							} else if(tryPull(lairitems[x].a))
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
							else while(i_a("marzipan skull")==0)
								 (bumAdv($location[South of the Border], "items", "hebo", "1 marzipan skull", "Getting a marzipan skull", "-i", "consultHeBo"));
								numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;
						break;
						
						default :
							if (lairitems[x].a != "") {
								if(tryPull(lairitems[x].a, true)) {numGatesWeHaveItemFor = numGatesWeHaveItemFor + 1;}
							} else {
								//abort("Due to the way the gates are handled, the script aborts here. Please re-run it.");
							}
						break;
					}
					thingToGet = $item[none];
				}
			}
		}
	}
	
	print("BCC: The number of gates for which we have items is "+numGatesWeHaveItemFor, "purple");
	//When we get to this point, check if we have all the items. 
	if (numGatesWeHaveItemFor == 3 || (my_path() == "Bees Hate You" && numGatesWeHaveItemFor == 1)) {
		if (get_property("bcasc_useCloverInEntryway") == "true") {
			if (cloversAvailable() > 0 && my_path() != "Bees Hate You") use(1, $item[disassembled clover]);
			else if (cloversAvailable() > 0) take_closet(1, $item[ten-leaf clover]);
		}
		if (entryway()) {
			print("BCC: We got through the whole entryway. That's fairly unlikely at this point....", "purple");
		} else {
			//Check that lair2.php appears, because we should have got through the gates and at least be in the Mariachi bit.
			if (!contains_text(visit_url("lair1.php"), "lair2.php")) {
				print("We successfully got through lair1.php and probably a section of lair2.php as well.", "purple");
			} else {
				abort("We did not successfully get to lair2.php. This is a major error. You should probably do the rest of this manually.");
			}
		}
	} else {
		abort("We do not have all the items for the gates. This script cannot yet get them. ");
	}
	
	checkStage("lair1", true);
	return true;
}

boolean bcascLairMariachis() {
	if (checkStage("lair2")) return true;
	print("BCC: We are doing the Mariachi part.", "purple");
	cli_execute("maximize hp -equip tambourine -equip big bass drum -equip black kettle drum");
	
	//Before we do anything, we must ensure we have the instruments. 
	
	
	//We should have two keys. Two DISTINCT keys.
	if (numUniqueKeys() >= 2) {
		if (i_a("makeshift SCUBA gear") == 0) {
			if (i_a("boris's key") > 0 && i_a("fishbowl") == 0 && i_a("hosed fishbowl") == 0 && i_a("makeshift scuba gear")==0) {
				print("BCC: We have boris's key, but no fishbowl. Do the entryway.", "purple");
				if (entryway()) {}
			}
			if (i_a("jarlsberg's key") > 0 && i_a("fishtank") == 0 && i_a("hosed tank") == 0 && i_a("makeshift scuba gear")==0) {
				print("BCC: We have jarlsberg's key, but no fisktank. Do the entryway.", "purple");
				if (entryway()) {}
			}
			if (i_a("sneaky pete's key") > 0 && i_a("fish hose") == 0 && i_a("hosed tank") == 0 && i_a("hosed fishbowl") == 0 && i_a("makeshift scuba gear")==0) {
				print("BCC: We have sneaky pete's key, but no fish hose. Do the entryway.", "purple");
				if (entryway()) {}
			}
		
			if (numOfWand() > 0 && i_a("makeshift scuba gear")==0) {
				if (canZap()) {
					//At this point, we haven't used our wand and have two distinct keys. 
					if (numUniqueKeys() >= 3) {
						print("BCC: You had all three keys. You don't need to zap them.", "purple");
					} else {
						//abort("za");
						if ((i_a("boris's key") > 0) && (my_path() != "Avatar of Boris")) {
							cli_execute("zap boris's key");
						} else {
							cli_execute("zap jarlsberg's key");
						}
					}
				} else {
					print("BCC: Your wand is not perfectly safe to zap, and as such we will not attempt to do so.", "purple");
				}
			} else if(i_a("makeshift scuba gear")==0){
				print("You don't have a wand. Lets get one.","red");
				bcascWand(true);
				print("Now restart mariachis","purple");
				return bcascLairMariachis();
			}
		}
		
		boolean armed() {
			return contains_text(visit_url("lair2.php"), "lair3.php");
		}

		if (entryway()) {}
		if (!armed()) {
			print("BCC: Maybe we're missing an instrument.", "purple");
			boolean haveAny(boolean[item] array) {
				print("Checking have any instrument","lime");
				foreach thing in array {
					if (i_a(thing) > 0)
					{
						print("already have "+thing,"lime");
						return true;
					}
				}
				print("Trying to pull / buy","lime");
				//So we don't have any of the things. Pull one. Or buy one. 
				if (!in_hardcore()) {
					foreach thing in array {
						if (can_interact()) {
							print("Buying "+thing,"lime");
							buy(1, thing);
						} else {
							print("Pulling "+thing,"lime");
							take_storage(1, thing);
						}
						if (i_a(thing) > 0) return true;
					}
				}
				return false;
			}

			boolean[item] strings = $items[
				acoustic guitarrr,
				heavy metal thunderrr guitarrr,
				stone banjo,
				Disco Banjo,
				Shagadelic Disco Banjo,
				Seeger's Unstoppable Banjo,
				Crimbo ukulele,
				Massive sitar,
				4-dimensional guitar,
				plastic guitar,
				half-sized guitar,
				out-of-tune biwa,
				Zim Merman's guitar,
			];
			boolean[item] squeezings = $items[stolen accordion,calavera concertina,Rock and Roll Legend,Squeezebox of the Ages,The Trickster's Trikitixa,];
			boolean[item] drums = $items[tambourine,big bass drum,black kettle drum,bone rattle,hippy bongo,jungle drum,];

			while (!haveAny(strings))
				 bumAdv($location[Belowdecks], "item, +equip pirate fledges", "items", "1 acoustic guitarrr", "Getting a guitar", "i");
				
			while (!haveAny(squeezings))
				use(1, $item[chewing gum on a string]);
				
			while (!haveAny(drums))
			{
				if(can_adv($location[the \"fun\" house]))
					bumAdv($location[the \"fun\" house], "items", "hebo", "1 big bass drum", "Getting a big bass drum", "i", "consultHeBo");
				else
				{
					bumAdv($location[The Hidden Park], "items", "hebo", "1 Jungle drum", "Getting a Jungle drum", "i", "consultHeBo");
				}
			}
			
			if (entryway()) {}
		}
		
		if (entryway()) {}
		if (armed()) {
			checkStage("lair2", true);
			return true;
		} else {
			abort("Failed to arm the mariachis"); 
		}
	} else {
		abort("You don't have two distinct legend keys. This script will not attempt to zap anything.");
	}
	abort("There has been a problem in the mariachi section. Please report this issue and complete the mariachi bit manually.");
	return false;
}

void bcascTowerItem() {
	switch (thingToGet) {
		case $item[baseball]:
			if (get_res($element[stench], 1, true) && i_a($item[sonar-in-a-biscuit]) > 0 && cloversAvailable(true) > 0) {
				visit_url("adventure.php?snarfblat=31&confirm=on");
			} else {
				bumAdv($location[Guano Junction], "item,  stench resistance", "hebo", "1 baseball", "Getting a baseball", "i", "consultHeBo");
			}
		break;
		
		case $item[plot hole]:
			bumAdv($location[The Castle in the Clouds in the Sky (Ground Floor)], "items", "hebo", "1 plot hole", "Getting a plot hole", "i", "consultHeBo");
		break;
		
		case $item[meat vortex]:
			bumAdv($location[The Valley of Rof L'm Fao], "items", "hebo", "1 meat vortex", "Getting a meat vortex", "i", "consultHeBo");
		break;
		
		case $item[sonar-in-a-biscuit]:
			if (get_res($element[stench], 1, true) && cloversAvailable(true) > 0) {
				visit_url("adventure.php?snarfblat=31&confirm=on");
			} else {
				bumAdv($location[Guano Junction], "item, stench resistance", "hebo", "1 sonar-in-a-biscuit", "Getting sonar-in-a-biscuit", "i", "consultHeBo");
			}
		break;
		
		case $item[leftovers of indeterminate origin]:
			if (cloversAvailable(true) > 0) {
				visit_url("adventure.php?snarfblat=388&confirm=on");
			} else {
				bumAdv($location[The Haunted Kitchen], "items", "hebo", "1 leftovers of indeterminate origin", "Getting leftovers of indeterminate origin", "i", "consultHeBo");
			}
		break;
		
		case $item[Knob Goblin firecracker]:
			bumAdv($location[the outskirts of cobb's knob], "items", "hebo", "1 Knob Goblin firecracker", "Getting a Knob Goblin firecracker", "i", "consultHeBo");
		break;
		
		case $item[inkwell]:
			bumAdv($location[The Haunted Library], "items", "hebo", "1 inkwell", "Getting an inkwell", "i", "consultHeBo");
		break;
		
		case $item[mariachi G-string]:
			bumAdv($location[South of the Border], "items", "hebo", "1 mariachi G-string", "Getting a mariachi G-string", "i", "consultHeBo");
		break;
		
		case $item[photoprotoneutron torpedo]:
			bumAdv($location[The Penultimate Fantasy Airship], "items", "hebo", "1 photoprotoneutron torpedo", "Getting a photoprotoneutron torpedo", "i", "consultHeBo");
		break;
		
		case $item[pygmy blowgun]:
			bumAdv($location[The Hidden Park], "items", "hebo", "1 pygmy blowgun", "Getting a pygmy blowgun", "i", "consultHeBo");
		break;
		
		case $item[fancy bath salts]:
			bumAdv($location[The Haunted Bathroom], "items", "hebo", "1 fancy bath salts", "Getting fancy bath salts", "i", "consultHeBo");
		break;
		
		case $item[razor-sharp can lid]:
			bumAdv($location[The Haunted Pantry], "items", "hebo", "1 razor-sharp can lid", "Getting a razor-sharp can lid", "i", "consultHeBo");
		break;
		
		case $item[frigid ninja stars]:
			bumAdv($location[Lair of the Ninja Snowmen], "items", "hebo", "1 frigid ninja stars", "Getting frigid ninja stars", "i", "consultHeBo");
		break;
		
		case $item[black pepper]:
			cli_execute("use * black picnic basket");
			while (i_a($item[black pepper]) == 0 && cloversAvailable(true) > 0) {
				visit_url("adventure.php?snarfblat=405&confirm=on");
				bumUse(1, $item[black picnic basket]);
			}
			while (i_a($item[black pepper]) == 0) {
				bumAdv($location[The Black Forest], "items", "hebo", "1 black picnic basket", "Getting black pepper", "i", "consultHeBo");
				bumUse(1, $item[black picnic basket]);
			}
		break;
		
		case $item[NG]:
			if ((i_a($item[lowercase N]) == 0 || i_a($item[original G]) == 0) && i_a($item[wang]) > 0) {
				cli_execute("untinker wang");
				return;
			}
			
			if (i_a($item[lowercase N]) == 0 && i_a($item[Wand of Nagamar]) > 0) cli_execute("untinker Wand of Nagamar");
			if (i_a($item[lowercase N]) == 0 && i_a($item[ND]) > 0) cli_execute("untinker ND");

			if (i_a($item[lowercase N]) == 0) bumAdv($location[The Valley of Rof L'm Fao], "items", "hebo", "1 lowercase n", "Getting a lowercase N", "i", "consultHeBo");
			if (i_a($item[original G]) == 0) bumAdv($location[The Castle in the Clouds in the Sky (Basement)], "items", "hebo", "1 original G", "Getting an original G", "i", "consultHeBo");
			
			cli_execute("make NG");
		break;
		
		case $item[hair spray]:
			retrieve_item(1, $item[hair spray]);
		break;
		
		case $item[bronzed locust]:
			bumAdv($location[The Arid\, Extra-Dry Desert], "items", "hebo", "1 bronzed locust", "Getting a bronzed locust", "i", "consultHeBo");
		break;
		
		case $item[powdered organs]:
			cli_execute("use * canopic jar");
			while (i_a($item[powdered organs]) == 0) {
				bumAdv($location[The Upper Chamber], "items", "hebo", "1 canopic jar", "Getting powdered organs", "i", "consultHeBo");
				bumUse(1, $item[canopic jar]);
			}
		break;
		
		case $item[spider web]:
			bumAdv($location[The Sleazy Back Alley], "items", "hebo", "1 spider web", "Getting a spider web", "i", "consultHeBo");
		break;
		
		case $item[chaos butterfly]:
			bumAdv($location[The Castle in the Clouds in the Sky (Ground Floor)], "items", "hebo", "1 chaos butterfly", "Getting a chaos butterfly", "i", "consultHeBo");
		break;
		
		case $item[disease]:
			bumAdv($location[Cobb's Knob Harem], "items", "hebo", "1 disease", "Getting disease", "i", "consultHeBo");
		break;
		
		case $item[stick of dynamite]:
			if (item_amount($item[Shore Inc. Ship Trip Scrip]) < 1) {
				set_property("choiceAdventure793", "1");
				adventure(1, $location[The Shore, Inc. Travel Agency]);
			}
			if (i_a($item[dude ranch souvenir crate]) < 1) buy($coinmaster[The Shore\, Inc. Gift Shop], 1, ($item[dude ranch souvenir crate]));
			use(1, $item[dude ranch souvenir crate]);
		break;
		
		case $item[barbed-wire fence]:
			if (item_amount($item[Shore Inc. Ship Trip Scrip]) < 1) {
				set_property("choiceAdventure793", "3");
				adventure(1, $location[The Shore, Inc. Travel Agency]);
			}
			if (i_a($item[ski resort souvenir crate]) < 1) buy($coinmaster[The Shore\, Inc. Gift Shop], 1, ($item[ski resort souvenir crate]));
			use(1, $item[ski resort souvenir crate]);
		break;
		
		case $item[tropical orchid]:
			if (item_amount($item[Shore Inc. Ship Trip Scrip]) < 1) {
				set_property("choiceAdventure793", "2");
				adventure(1, $location[The Shore, Inc. Travel Agency]);
			}
			if (i_a($item[tropical island souvenir crate]) < 1) buy($coinmaster[The Shore\, Inc. Gift Shop], 1, ($item[tropical island souvenir crate]));
			use(1, $item[tropical island souvenir crate]);
		break;
	}
}

void bcascLairTower() {
	//Firstly, maximize HP and make sure we have a sugar shield to get through the shadow/familiars. 
	cli_execute("maximize "+max_bees+" beeosity, hp; restore hp");
	if (i_a("sugar shield") == 0 && have_skill($skill[summon sugar sheets])) { if (cli_execute("cast summon sugar; make sugar shield")) {} }
	
	//Then get through the place.
	cli_execute("use * pile of candy");
	cli_execute("use * penultimate fantasy chest");
	cli_execute("use * canopic jar");
	cli_execute("use * black picnic basket");
	item missing = $item[steaming evil];
	
	if (in_hardcore()) {
		missing = guardians();
		while (missing != $item[none]) {
			thingToGet = missing;
			bcascTowerItem();
			thingToGet = $item[none];
			missing = guardians();
		}
		try {
			if (have_effect($effect[Billiards Belligerence]) == 0) {
				if (cli_execute("pool 1")) {}
			}
		}
		finally {
			if (cli_execute("concert dilated pu")) {}
			
			if (contains_text(visit_url("lair6.php"), "?place=5")) {
				bcascLairFightNS();
			} else if (my_path()=="Avatar of Jarlsberg" && contains_text(visit_url("lair6.php"), "?place=3")) {
				string tmp = visit_url("lair6.php?place=3");
				run_combat();
				bcascLairFightNS();
			} else {
				abort("You are stuck at the top of the tower.");
			}
		}
	} else {
		//If softcore/casual then we have the option to pull or buy items.
		while (missing != $item[none]) {
			missing = guardians();
			if (missing != $item[none] && can_interact()) {
				buy(1, missing);
			}
			if (missing != $item[none] && pulls_remaining() > 0) {
				take_storage(1, missing);
			}
		}
		if (have_effect($effect[Billiards Belligerence]) == 0) {
			if (cli_execute("pool 1")) {}
		}
		if (get_property("sidequestArenaCompleted") == "hippy" && cli_execute("concert Optimist Primal")) {}
		
		if (contains_text(visit_url("lair6.php"), "?place=5")) {
			bcascLairFightNS();
		} else if (my_path()=="Avatar of Jarlsberg" && contains_text(visit_url("lair6.php"), "?place=3")) {
			string tmp = visit_url("lair6.php?place=3");
			run_combat();
			bcascLairFightNS();
		} else {
			abort("You are stuck at the top of the tower.");
		}
	}
}

boolean bcascMacguffinFinal() {
	if (checkStage("macguffinfinal")) return true;

	if (!contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme") && !contains_text(visit_url("questlog.php?which=2"),"A Pyramid Scheme")) {
		if(i_a("staff of ed")==0) create(1,$item[staff of ed]);
		if (!contains_text(visit_url("place.php?whichplace=desertbeach"),"pyramid.php")) visit_url("place.php?whichplace=desertbeach&action=db_pyramid1");
	}

	if (contains_text(visit_url("questlog.php?which=1"),"A Pyramid Scheme")) {
		//unlock middle
		while (!get_property("middleChamberUnlock").to_boolean()) {
			bumAdv($location[The Upper Chamber], "", "", "choiceadv", "Getting the initial choice adventure", "-");
		}

		//unlock lower
		while (!get_property("lowerChamberUnlock").to_boolean() || !get_property("controlRoomUnlock").to_boolean()) {
			bumAdv($location[The Middle Chamber], "", "", "choiceadv", "Getting the initial choice adventure", "-");
		}

		int turnsNeeded;
		if (contains_text(visit_url("place.php?whichplace=pyramid"),"action=pyramid_state1a")) {
			turnsNeeded = 0;
		} else if (i_a("ancient bomb") > 0) {
			turnsNeeded = 3;
		} else if (i_a("ancient bronze token") > 0) {
			turnsNeeded = 7;
		} else {
			turnsNeeded = 10;
		}

		if (can_interact() && my_path()!="Bees Hate You") {
			retrieve_item(turnsNeeded - i_a("crumbling wooden wheel"), $item[tomb ratchet]);
		}

		//do pyramid twisting
		if (!contains_text(visit_url("place.php?whichplace=pyramid"),"action=pyramid_state1a") && my_adventures() > turnsNeeded / 3) {
			//Set to turn the wheel. 134 is the initial and 135 subsequent visits. 
			set_property("choiceAdventure134","1");
			set_property("choiceAdventure135","1");
			setMood("-");
			cli_execute("mood execute");
			if(combat_rate_modifier() > -25.0)
				cli_execute("swim sprints");
			else 
				cli_execute("swim laps");
			if(combat_rate_modifier() > -25.0)
				eat_hot_dog("Ghost dog",$location[The Middle Chamber]);
			
			while (i_a("crumbling wooden wheel") + i_a("tomb ratchet") < turnsNeeded) {
				bumAdv($location[The Upper Chamber], "", "", (turnsNeeded - i_a("tomb ratchet"))+" crumbling wooden wheel", "Getting the wheels needed to finish this", "-");
			}

			int turnsUsed = 0;
			if (item_amount($item[ancient bronze token]) == 0 && item_amount($item[ancient bomb]) == 0) {
				print("BCC: Getting the token.", "purple");
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
				turnsUsed = 0;
				while (turnsUsed < 3) {
					turnsUsed += 1;
					if (i_a("crumbling wooden wheel") > 0) {
						visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
 					} else {
						visit_url("choice.php?whichchoice=929&option=2&pwd="+my_hash());
 					}
 				}
				visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
			}

			if (item_amount($item[ancient bronze token]) > 0 && item_amount($item[ancient bomb]) == 0) {
				print("BCC: Exchanging the token for bomb.", "purple");
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
				turnsUsed = 0;
				while (turnsUsed < 4) {
					turnsUsed += 1;
					if (i_a("crumbling wooden wheel") > 0) {
						visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
					} else {
						visit_url("choice.php?whichchoice=929&option=2&pwd="+my_hash());
					}
				}
				visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
 			}

			if (item_amount($item[ancient bomb]) > 0) {
				print("BCC: Using the bomb to open the chamber.", "purple");
				visit_url("place.php?whichplace=pyramid&action=pyramid_control");
				turnsUsed = 0;
				while (turnsUsed < 3) {
					turnsUsed += 1;
					if (i_a("crumbling wooden wheel") > 0) {
						visit_url("choice.php?pwd&whichchoice=929&option=1&choiceform1=Use+a+wheel+on+the+peg&pwd="+my_hash());
					} else {
						visit_url("choice.php?whichchoice=929&option=2&pwd="+my_hash());
					}
				}
				visit_url("choice.php?pwd&whichchoice=929&option=5&choiceform5=Head+down+to+the+Lower+Chambers+%281%29&pwd="+my_hash());
			}
		}
		
		//Fight Ed
//		abort("line 7507 try ed yourself");
		if (my_adventures() < 7) { abort("You don't have enough adventures to fight Ed."); }
		print("BCC: Fighting Ed", "purple");
		visit_url("place.php?whichplace=pyramid&action=pyramid_state1a");
		bumRunCombat();
		while (item_amount($item[Holy MacGuffin]) == 0) {
			if (my_hp() == 0) abort("Oops, you died. Probably better fight this one yourself.");
			visit_url("fight.php");
			bumRunCombat();
		}
	}
	if (item_amount($item[Holy MacGuffin]) != 0) {
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());
	}
	if (contains_text(visit_url("questlog.php?which=2"),"A Pyramid Scheme")) {
		checkStage("macguffinfinal", true);
		return true;
	}
	return false;
}

boolean bcascMacguffinHiddenCity() {
	boolean tryPull(item it) {
		
		if(pulls_remaining() > 0)
			if (take_storage(1, it))
				return true;
		return false;
	}

	void openStage(int shrineSnarfblat, string locationName) {
		while (!contains_text(visit_url("place.php?whichplace=hiddencity"), locationName)) {
			print("clearing vines and finding "+locationName,"blue");
			equip($slot[weapon], $item[antique machete]);
			setMood("-");
			bumMiniAdv(1,to_location(shrineSnarfblat));
		}
	}

	//set choiceadvs
	set_property("choiceAdventure781", 1);
	set_property("choiceAdventure783", 1);
	set_property("choiceAdventure785", 1);
	set_property("choiceAdventure787", 1);
	
	
	if (checkStage("macguffinhiddencity")) return true;
	if (item_amount($item[ancient amulet]) > 0 || item_amount($item[Headpiece of the Staff of Ed]) > 0 || item_amount($item[Staff of Ed, almost]) > 0 || item_amount($item[Staff of Ed]) > 0) {
		checkStage("macguffinhiddencity", true);
		return true;
	}

	//1 - Get antique machete. 
	if (pulls_remaining() > 0 && available_amount($item[antique machete]) == 0) {
		tryPull($item[antique machete]);
	}

	while (available_amount($item[antique machete]) == 0) {
		set_property("choiceAdventure789", 2);
		bumAdv($location[The Hidden Park], "", "", "1 antique machete", "Getting the machete", "-");
	}

	//2 - Clear all vines and unlock hidden city area. 
	openStage(346, "The Hidden Apartment Building");
	openStage(347, "The Hidden Hospital");
	openStage(348, "The Hidden Office Building");
	openStage(349, "The Hidden Bowling Alley");

	//3 - Dumpster dive until 3 bowling balls or 3 outfit pieces. Then knock over dumpster.
	while (get_property("relocatePygmyJanitor") != my_ascensions()) {
		set_property("choiceAdventure789", "2");
		bumAdv($location[The Hidden Park], "", "", "1 choiceadv", "Relocating Pygmy Janitors from the buildings to the park.", "-");
	}
	
	//4 - Park until book of matches. (Use them)
	if (bcasc_unlockHiddenTavern && get_property("hiddenTavernUnlock").to_int() != my_ascensions()) {
		while (item_amount($item[book of matches]) == 0) {
			bumAdv($location[The Hidden Park], "", "items", "1 book of matches", "Getting the book of matches.", "i");
		}
		use(1, $item[book of matches]);
	}


	if (item_amount($item[stone triangle]) == 0) {
		if(i_a("liquid ice")>0) use(1,$item[liquid ice]);
		//5 - Apartment: Get cursed three times. If we hit the NC without 3, get cursed, else fight spirit.
		while (item_amount($item[moss-covered stone sphere]) == 0) {
			set_property("choiceAdventure780", "1");
			setMood("-");
			if(my_thrall()==$thrall[Vampieroghi])
				use_skill(1,$skill[dismiss pasta thrall]);
			if (my_thrall() == $thrall[Vampieroghi]) abort("BCC: Change your thrall. The Vampieroghi will keep removing the curse and wasting turns.");
			print("Getting the moss-covered stone sphere.","purple");
			//bumMiniAdv(1,$location[The Hidden Apartment Building]);
			bumAdv($location[The Hidden Apartment Building], "5 elemental damage", "", "1 choiceadv", "Getting the moss-covered stone sphere.", "-");
		}
		while (item_amount($item[moss-covered stone sphere]) == 1) {
			bumMiniAdv(1, $location[An Overgrown Shrine (Northwest)], "");
		}
	}
	
	if (item_amount($item[stone triangle]) == 1) {
		//6 - Office: Get 5 McClusky files, and clip. Then fight spirit.
		while (item_amount($item[crackling stone sphere]) == 0) {
			if(item_amount($item[McClusky file (complete)])>0)
			{
				set_property("choiceAdventure786", "1");
			}
			else
			{
				if(item_amount($item[boring binder clip])>0)
				{
					if(item_amount($item[McClusky file (page 1)])>0 && item_amount($item[McClusky file (page 2)])>0 && item_amount($item[McClusky file (page 3)])>0 && item_amount($item[McClusky file (page 4)])>0 && item_amount($item[McClusky file (page 5)])>0)
					{
						//got complete file!
						use(1,$item[boring binder clip]);
						set_property("choiceAdventure786", "1");
					}
					else
					{
						//need files only so fight accountants
						set_property("choiceAdventure786", "3");
					}
				}
				else
				{
					//need binder clip so raid supplies
					print("Looking for a binder clip","green");
					set_property("choiceAdventure786", "2");
				}
			}
			bumAdv($location[The Hidden Office Building], "5 elemental damage", "", "1 choiceadv", "Getting the crackling stone sphere.", "-");
			
			if(item_amount($item[boring binder clip])<=0 && get_property("choiceAdventure786")!="2" && item_amount($item[McClusky file (complete)])<=0 && item_amount($item[crackling stone sphere]) != 1)
				abort("BBB is fucking up the choiceadv for getting binder clip again");
		}
		while (item_amount($item[crackling stone sphere]) == 1) {
			bumMiniAdv(1, $location[An Overgrown Shrine (Northeast)], "");
		}
	}

	
	if (item_amount($item[stone triangle]) == 2) {
		//7 - Hospital: Fight surgeons to get doctor gear, then wear it and defeat spirit.
		while (available_amount($item[dripping stone sphere]) == 0) {
			while (available_amount($item[bloodied surgical dungarees]) == 0 && available_amount($item[surgical apron]) == 0 && (available_amount($item[half-size scalpel]) == 0 || my_buffedstat($stat[muscle]) < $monster[protector spectre].base_defense) && available_amount($item[head mirror]) == 0 && available_amount($item[surgical mask]) == 0) {
				print("BCC: Adventuring one turn at a time to get surgeon's disguise.", "purple");
				bumMiniAdv(1, $location[The Hidden Hospital], "");
			}

			string equip = "5 elemental damage, ";
			if (available_amount($item[bloodied surgical dungarees]) > 0) {
				equip += "+equip bloodied surgical dungarees, ";
			}
			if (available_amount($item[surgical apron]) > 0 && have_skill($skill[torso awaregness]) && !contains_text(to_string(equipped_item($slot[shirt])), "Sneaky Pete")) {
				equip += "+equip surgical apron, ";
			}
			if (available_amount($item[half-size scalpel]) > 0 && my_buffedstat($stat[muscle]) > $monster[protector spectre].base_defense) {
				equip += "+equip half-size scalpel, ";
			}
			if (available_amount($item[head mirror]) > 0) {
				equip += "+equip head mirror, ";
			}
			if (available_amount($item[surgical mask]) > 0) {
				equip += "+equip surgical mask, ";
 			}

			set_property("choiceAdventure784", "1");
			bumAdv($location[The Hidden Hospital], equip, "", "1 choiceadv", "Getting the dripping stone sphere.", "-");
		}
		while (item_amount($item[dripping stone sphere]) == 1) {
			bumMiniAdv(1, $location[An Overgrown Shrine (Southwest)], "");
		}
	}

	if (item_amount($item[stone triangle]) == 3) {
		//8 - Bowling Alley: Adventure until have scorched stone sphere.
		while (item_amount($item[scorched stone sphere]) == 0) {
			//ensure we skip drunk pygmys
			if(i_a("bowl of scorpions")==0)
				buy(1,$item[bowl of scorpions]);
			set_property("choiceAdventure788", "1");
			bumAdv($location[The Hidden Bowling Alley], "+item drop, 5 elemental damage", "items", "1 scorched stone sphere", "Getting the scorched stone sphere.", "i-");
		}
		while (item_amount($item[scorched stone sphere]) == 1) {
			bumMiniAdv(1, $location[An Overgrown Shrine (Southeast)], "");
		}
	}
	if(item_amount($item[stone triangle]) != 4)
	{
		abort("We currently have "+item_amount($item[stone triangle])+" stone triangles, at the time when we are about to unlock ziggarut.");
	}

	//10 - Fight boss. 
	if (item_amount($item[stone triangle]) == 4) {
		//make sure lianas are cleared
		set_property("choiceAdventure791", "2");
		equip($slot[weapon], $item[antique machete]);
		bumAdv($location[A Massive Ziggurat], "-weapon, ", "", "1 choiceadv", "Defeating the last Protector Spectre.", "");
		bumAdv($location[A Massive Ziggurat], "-weapon, ", "", "1 choiceadv", "Defeating the last Protector Spectre.", "");
		bumAdv($location[A Massive Ziggurat], "-weapon, ", "", "1 choiceadv", "Defeating the last Protector Spectre.", "");

		//kill boss
		set_property("choiceAdventure791", "1");
		bumAdv($location[A Massive Ziggurat], "5 elemental damage", "", "1 choiceadv", "Defeating the last Protector Spectre.", "");
	}

	if (item_amount($item[ancient amulet]) > 0 || item_amount($item[Headpiece of the Staff of Ed]) > 0 || item_amount($item[Staff of Ed, almost]) > 0 || item_amount($item[Staff of Ed]) > 0) {

		checkStage("macguffinhiddencity", true);
		return true;
	} else {
		print("There was a problem completing the hidden city quest. Please complete the quest manually, then run this script again to continue.", "red");
		abort();
	}
	return false;
}

boolean bcascOpenTemple() {
	while (item_amount($item[spooky temple map]) + item_amount($item[tree-holed coin]) == 0) {
		set_property("choiceAdventure502", "2");
		set_property("choiceAdventure505", "2");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get a Tree-Holed Coin", "-");
	}
	
	while (item_amount($item[spooky temple map]) == 0) {
		set_property("choiceAdventure502", "3");
		set_property("choiceAdventure506", "3");
		set_property("choiceAdventure507", "1");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get the map", "-");
	}
	
	while (item_amount($item[spooky-gro fertilizer]) == 0) {
		set_property("choiceAdventure502", "3");
		set_property("choiceAdventure506", "2");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get the fertilizer", "-");
	}
	
	while (item_amount($item[spooky sapling]) == 0 && my_adventures() > 0) {
		cli_execute("mood execute");
		if (contains_text(visit_url("adventure.php?snarfblat=15"), "Combat")) {
			bumRunCombat();
		} else {
			visit_url("choice.php?whichchoice=502&option=1&pwd="+my_hash());
			visit_url("choice.php?whichchoice=503&option=3&pwd="+my_hash());
			if (item_amount($item[bar skin]) > 0) visit_url("choice.php?whichchoice=504&option=2&pwd="+my_hash());
			visit_url("choice.php?whichchoice=504&option=3&pwd="+my_hash());
			visit_url("choice.php?whichchoice=504&option=4&pwd="+my_hash());
		}
	}
	
	print("Using Spooky Temple Map", "blue");
	return use(1, $item[spooky temple map]);
}

boolean bcascMacguffinPalindome() {
	if (checkStage("macguffinpalin")) return true;

	if (!contains_text(visit_url("questlog.php?which=1"), "Never Odd") && !contains_text(visit_url("questlog.php?which=2"), "Never Odd")) {
		bumAdv($location[Inside the Palindome], "+equip talisman o' nam", (in_hardcore()) ? "hebo" : "", "", "Adventuring once to unlock the Palindome quest", "i-", (in_hardcore()) ? "consultHeBo" : "", 1); 
	}
	
	if (equipped_amount($item[talisman o' nam]) == 0) equip($item[talisman o' nam]);

	while (!contains_text(visit_url("place.php?whichplace=palindome"), "drawkwardlabel.gif") && item_amount(to_item("i love me vol i")) == 0) {
		if (can_interact()) {
			retrieve_item(1, $item[stunt nuts]);
		}
		if (my_meat() < (500 * (2 - i_a("photograph of God") - i_a("photograph of a red nugget")))) abort("You're going to need more meat for this.");

		bumAdv($location[Inside the Palindome], "+equip talisman o' nam", (in_hardcore()) ? "hebo" : "", "1 stunt nuts, 1 I Love Me Vol I, photograph of a dog, photograph of God, photograph of a red nugget, photograph of an ostrich egg", "Getting I love me vol i (and hopefully other quest items)", "i-", (in_hardcore()) ? "consultHeBo" : ""); 
	}

	//Unlock Dr. Awkward
	if(i_a("I Love Me Vol I")>0)
		use(1,$item[&quot;I Love Me\, Vol. I&quot;]);

	//unlock Mr. Alarm
	buffer palindome;
	if(!contains_text(visit_url("place.php?whichplace=palindome"),"mralarmlabel")) {
		if (my_meat() < (500 * (2 - i_a("photograph of God") - i_a("photograph of a red nugget")))) abort("You're going to need more meat for this.");

		if(i_a("photograph of a dog")==0 && i_a("disposable instant camera")==0)
			abort("We somehow got to palindome without previously getting a camera");
		
		while(i_a("photograph of a dog")==0 || i_a("photograph of God")==0 || i_a("photograph of a red nugget")==0 || i_a("photograph of an ostrich egg")==0)
			bumAdv($location[Inside the Palindome], "+equip talisman o' nam", (in_hardcore()) ? "hebo" : "", "photograph of a dog, photograph of God, photograph of a red nugget, photograph of an ostrich egg", "Getting all photographs the Palindome has to offer", "i-", (in_hardcore()) ? "consultHeBo" : ""); 

		//if we didn't get stunt nuts, farm or pull them now
		if(!in_hardcore())
		{
			if(i_a("wet stew")<1 && i_a("wet stunt nut stew")<1)
				cli_execute("pull wet stew");
			if(i_a("stunt nuts")<1 && i_a("wet stunt nut stew")<1)
				cli_execute("pull stunt nuts");
		}

		print("unlocking mr alarm","purple");
		palindome = visit_url("place.php?whichplace=palindome&action=pal_drlabel");
		palindome = visit_url("choice.php?whichchoice=872&option=1&photo1=2259&photo2=7264&photo3=7263&photo4=7265");
		use(1, $item[&quot;2 Love Me\, Vol. 2&quot;]);
		palindome = visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
		//<maybe need to heal here?>
	}

	if(!contains_text(visit_url("place.php?whichplace=palindome"),"mralarmlabel"))
		abort("Somehow failed to open mr alarm");
		
	while(contains_text(visit_url("questlog.php?which=1"), "a bowl of wet stunt nut stew")) {
		while (item_amount($item[wet stunt nut stew]) < 1) {
			print("Getting stunt nut stew","green");
			if(!in_hardcore() && i_a("wet stew")<1 && i_a("wet stunt nut stew") < 1)
				cli_execute("pull wet stew");
				
			while (item_amount($item[wet stew]) == 0 && (item_amount($item[bird rib]) == 0 || item_amount($item[lion oil]) == 0)) {
				visit_url("guild.php?place=paco");
				bumAdv($location[whitey's grove], "", "items", "1 lion oil, 1 bird rib", "Getting the wet stew items from Whitey's Grove", "+i"); 
			}
			
			//Note that we probably already have the stunt nuts
			if(!in_hardcore() && i_a("stunt nuts")<1)
				cli_execute("pull stunt nuts");
			while (i_a("stunt nuts") == 0)
				bumAdv($location[inside the palindome], "", "items", "1 stunt nuts", "Getting the stunt nuts from the Palindome, which you should probably already have");
			create(1, $item[wet stunt nut stew]);
		}
	}
			
	//Get the Mega Gem
	if (i_a("mega gem") == 0)
	{
		if (equipped_amount($item[talisman o' nam]) == 0) equip($item[talisman o' nam]);
		if (item_amount($item[wet stunt nut stew]) == 0) abort("Failed to cook up some tasty wet stunt nut stew.");
		palindome = visit_url("place.php?whichplace=palindome&action=pal_mrlabel");
	}
		
	if (i_a("mega gem") == 0) abort("That's weird. You don't have the Mega Gem.");
	
	//Fight Dr. Awkward
	cli_execute("restore hp; condition clear;");
	buMax("+equip Talisman o' Nam +equip Mega Gem");
	if (!in_hardcore()) {
		//Then we have to manually equip the talisman and mega gem because of buMax() limitations
		equip($slot[acc1], $item[Talisman o' Nam]);
		equip($slot[acc2], $item[Mega Gem]);
	}
	setFamiliar("meatboss");
	
	//Enter the fight
	if (item_amount($item[Staff of Fats])== 0) {
		if(my_path()=="Heavy Rains")
			abort("Kill dr awkward yourself, spells reduced to 1 damage");
		palindome = visit_url("place.php?whichplace=palindome&action=pal_drlabel");
		palindome = visit_url("choice.php?pwd&whichchoice=131&option=1&choiceform1=War%2C+sir%2C+is+raw%21");
		bumRunCombat();

		if (item_amount($item[Staff of Fats]) == 0) abort("Looks like Dr. Awkward opened a can of whoop-ass on you. Try fighting him manually.");
	}
	
	if (item_amount($item[Staff of Fats]) > 0) {
		checkStage("macguffinpalin", true);
		return true;
	}

	return false;
}

boolean bcascMacguffinDiary()
{
	if (checkStage("macguffindiary")) return true;
	council();
	while (!contains_text(visit_url("woods.php"), "blackmarket.gif")) {	
		set_property("choiceAdventure923", "1");
		set_property("choiceAdventure924", "1");
		//get shoes if possible
		if(i_a("blackberry galoshes")==0 && my_basestat($stat[moxie]) >=60)
		{
			cli_execute("pull blackberry galoshes");
			//make shoes if possible
			if(i_a("blackberry galoshes")==0 && i_a("blackberry")>3)
			{
				set_property("choiceAdventure923", "1");
				set_property("choiceAdventure924", "2");
				set_property("choiceAdventure177", "4");
			}

		}
		while(i_a("black map")==0)
			bumAdv($location[The Black Forest], "", "", "", "Finding the black market", "-");
		
		if(i_a("reconstituted crow")==0)
		{
			if(cli_execute("make reconstituted crow")){}
		}
		if(i_a("reassembled blackbird")==0)
		{
			if(cli_execute("make reassembled blackbird")){}
		}

		setFamiliar("blackforest");
		string max = "";
		if (i_a("reassembled blackbird") == 0 && i_a("reconstituted crow") == 0) {
			max = "item, ";
		}
		if (i_a("blackberry galoshes")>0 && my_basestat($stat[moxie]) >=60) {
			print("trying to put on galoshes ","purple");
			max = max + " +equip blackberry galoshes, ";
		}
		buMax(max + "+combat");
		if(equipped_amount($item[blackberry galoshes])==0 && i_a("blackberry galoshes")>0 && my_basestat($stat[moxie]) >=60)
			abort("failed to equip galosh");
		setMood((my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" ? max : max + "+"));
		cli_execute("mood execute");
		bumMiniAdv(1, $location[The Black Forest]);
	}
	
	if (item_amount($item[your father's MacGuffin diary]) == 0) {
		if (my_path() == "Way of the Surprising Fist" && item_amount($item[forged identification documents]) == 0) {
			abort("You need to fight Wu Tang the Betrayer to get the documents. He's really strong, so the script won't do this.");
		}
		
		print("BCC: Obtaining and Reading the Diary", "purple");
		if(my_meat()<5000 && i_a("forged identification documents")==0) abort("not enough meat (5000) to get forged id");
		if(!retrieve_item(1,$item[forged identification documents])) abort("BCC: You failed to acquire the forged identification documents. Do you lack the funds?");
		while (item_amount($item[your father's MacGuffin diary]) < 1 && my_adventures() > 2) {
			switch (my_primestat()) {
				case $stat[Muscle] :
					set_property("choiceAdventure793", "1");
				break;
				case $stat[Mysticality] :
					set_property("choiceAdventure793", "2");
				break;
				case $stat[Moxie] :
					set_property("choiceAdventure793", "3");
				break;
			}
			cli_execute("conditions clear");
			cli_execute("mood clear");
			print("getting diary","blue");
			adventure(1, $location[The Shore, Inc. Travel Agency]);
		}
		use(1, $item[your father's MacGuffin diary]);
	}
	if(i_a("your father's MacGuffin diary")>0)
	{
		checkStage("macguffindiary", true);
		return true;
	}
	return false;
}

boolean bcascMacguffinPrelim() {
	bcascMacguffinDiary();
	if (checkStage("macguffinprelim")) return true;
	
	if (!contains_text(visit_url("woods.php"),"hiddencitylink.gif") && my_adventures() > 3)
	{
		buMax("items");
		setFamiliar("itemsnc");
		setMood("-i");
	}
	while (!contains_text(visit_url("woods.php"),"hiddencitylink.gif") && my_adventures() > 3) {
		if (to_int(get_property("lastTempleUnlock")) != my_ascensions())
	 	    bcascOpenTemple();
		traverse_temple();
	}
	
	//At this point, Zarqon opens up the bedroom. But I'd like to do this earlier. 
	//Setting an abort() here to make sure we can get in. 
	if (get_property("questM21Dance") != "finished") abort("You'll need to open the Ballroom");
	while (!contains_text(visit_url("place.php?whichplace=manor1"),"sr_floor1_stairsdown.gif")) {
		print("BCC: Opening the Spookyraven Cellar", "purple");
	
		//place florist friar plants
		choose_all_plants("", $location[The Haunted ballroom]);
		set_property("choiceAdventure921", "1");
		bumMiniAdv(1, $location[The Haunted ballroom]);
		betweenBattle();
	}
	//SIMON ADDED
	cli_execute("inventory refresh");
	string maxstring = "+equip pirate fledges";
	if (my_basestat($stat[mysticality]) < 60) maxstring = "+outfit swashbuckling getup";
	if(i_a("gaudy key")>1)
	{
		cli_execute("maximize "+maxstring);
		if (cli_execute("make talisman o nam")) {}
		cli_execute("inventory refresh");
		if(i_a("talisman o nam")<1) {abort("failed to use gaudy keys");}
	}
	if (cli_execute("make talisman o nam")) {}
	while (i_a("Talisman o' Nam") == 0) {
		//We will almost certainly have the fledges equipped due to maximizing our Moxie. We re-equip them if we don't have them. 
		//SIMON ADDED
		buMax(maxstring);
		
		if (!contains_text(visit_url("place.php?whichplace=cove"), "cove3_5x2b.gif")) {
			if (get_property("choiceAdventure189") == "0") {
				set_property("choiceAdventure189", 2);
			}
			set_property("oceanAction", "continue");
			set_property("oceanDestination", my_primestat().to_string());
			bumAdv($location[The Poop Deck], maxstring, "", "", "Opening Belowdecks", "-");
		}
		bumAdv($location[Belowdecks], maxstring, "", "2 gaudy key", "Getting the Talisman");
		if(i_a("gaudy key")>1)
		{
			cli_execute("maximize "+maxstring);
			if (cli_execute("make talisman o nam")) {}
			cli_execute("inventory refresh");
			if(i_a("talisman o nam")<1) {abort("failed to use gaudy keys");}
		}
		cli_execute("maximize "+maxstring);
		if (cli_execute("make talisman o nam")) {}
		cli_execute("inventory_refresh");
	}
	
	checkStage("macguffinprelim", true);
	return true;
}

boolean bcascMacguffinSpooky() {
	if (checkStage("macguffinspooky")) return true;
	if (contains_text(visit_url("questlog.php?which=1"),"Spooking")) {
		if (!contains_text(visit_url("questlog.php?which=1"),"secret black magic laboratory")) {
			//Get the Spectacles if you don't have them already. 
			while (i_a("Lord Spookyraven's spectacles") == 0) {
				//Correctly set Ornate Nightstand
				set_property("choiceAdventure878", 3);
				bumAdv($location[The Haunted Bedroom], "", "", "Lord Spookyraven's spectacles", "Getting the Spectacles");
				
				print("finished adv, using adv1 to do choice","green");
				adv1($location[noob cave],-1,"");
				if(!contains_text(get_property("lastEncounter"),"Nightstand"))
					abort("We accidentally went to noob cave instead of finishing the choiceadv");
				print("did choice, continuing","green");
			}
		}

		buffer page = visit_url("place.php?whichplace=manor4");
		if (contains_text(page, "manor4_chamberwall") && item_amount($item[recipe: mortar-dissolving solution]) == 0) {
			page = visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
			equip($item[lord spookyraven's spectacles]);
			use(1, $item[recipe: mortar-dissolving solution]);
		}

		if (contains_text(page, "manor4_chamberwall")) {
			if (bcasc_cellarWineBomb && (contains_text(visit_url("questlog.php?which=1"),"Gather the explosive ingredients") || contains_text(visit_url("questlog.php?which=1"),"Heat up the explosive mixture") || contains_text(visit_url("questlog.php?which=1"),"Use the explosive on the"))
					&& my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") {
				if (available_amount($item[unstable fulminate]) == 0 && item_amount($item[wine bomb]) == 0) {
					while (item_amount($item[bottle of Chateau de Vinegar]) == 0) {
						bumAdv($location[The Haunted Wine Cellar], "items", "items", "1 bottle of Chateau de Vinegar", "Collecting ingredients for a wine bomb", "i");
					}
					while (item_amount($item[blasting soda]) == 0) {
						bumAdv($location[The Haunted Laundry Room], "items", "items", "1 blasting soda", "Collecting ingredients for a wine bomb", "i");
					}
					
					cli_execute("make unstable fulminate");
				}
				
				string maxstr = "ml, +equip unstable fulminate";
				if(my_primestat()==$stat[moxie])
					maxstr += ", -melee";
				else if(my_primestat()==$stat[muscle])
					maxstr += ", +melee";
				while (available_amount($item[unstable fulminate]) > 0 && item_amount($item[wine bomb]) == 0) {
					bumAdv($location[The Haunted Boiler Room], maxstr, "ml", "1 wine bomb", "Making a wine bomb", "l");
 				}
 			} else {
				while (item_amount($item[loosening powder]) == 0) {
					bumAdv($location[The Haunted Kitchen], "", "", "1 loosening powder", "Collecting ingredients for mortar-dissolver", "-");
				}
				while (item_amount($item[powdered castoreum]) == 0) {
					bumAdv($location[The Haunted Conservatory], "", "", "1 powdered castoreum", "Collecting ingredients for mortar-dissolver", "-");
				}
				while (item_amount($item[drain dissolver]) == 0) {
					bumAdv($location[The Haunted Bathroom], "", "", "1 drain dissolver", "Collecting ingredients for mortar-dissolver", "-");
				}
				while (item_amount($item[triple-distilled turpentine]) == 0) {
					bumAdv($location[The Haunted Gallery], "", "", "1 triple-distilled turpentine", "Collecting ingredients for mortar-dissolver", "-");
				}
				while (item_amount($item[detartrated anhydrous sublicalc]) == 0) {
					bumAdv($location[The Haunted Laboratory], "", "", "1 detartrated anhydrous sublicalc", "Collecting ingredients for mortar-dissolver", "-");
				}
				while (item_amount($item[triatomaceous dust]) == 0) {
					bumAdv($location[The Haunted Storage Room], "", "", "1 triatomaceous dust", "Collecting ingredients for mortar-dissolver", "-");
				}
			}
			page = visit_url("place.php?whichplace=manor4&action=manor4_chamberwall");
		}
		
		if (contains_text(page, "manor4_chamberboss")) {
			buMax();
			print("BCC: Fighting Spookyraven", "purple");
			restore_hp(my_maxhp());
			if (have_skill($skill[Elemental Saucesphere]) && have_castitems($class[sauceror], true))
				cli_execute("cast Elemental Saucesphere");
			if(have_skill($skill[astral shell]) && have_effect($effect[astral shell])<1 && have_castitems($class[turtle tamer], true))
				cli_execute("cast astral shell");
			if(my_meat()>1000 && have_effect($effect[red door syndrome])<1)
			{
				if(i_a("post-holiday sale coupon")>0)use(1,$item[post-holiday sale coupon]);
				cli_execute("use can of black paint");
			}
			if(i_a("programmable turtle")>0 && have_effect($effect[Spiro Gyro])==0)
				use(1,$item[programmable turtle]);
			if(i_a("pec oil")>0 && have_effect($effect[Oiled-Up])<1)
				cli_execute("use pec oil");
			if (have_effect($effect[Protection from Bad Stuff]) == 0 && available_amount($item[scroll of Protection from Bad Stuff])>0) use(1, $item[scroll of Protection from Bad Stuff]);

			//try to use gap buff
			if(available_amount($item[greatest american pants])>0)
			{
				//10 turns should be enough
				equip($item[greatest american pants]);
				visit_url("inventory.php?action=activatesuperpants");
				visit_url("choice.php?pwd&whichchoice=508&option=2&choiceform2=Super+Structure");
			}
			
			setFamiliar("meatboss");
			if(my_path()=="Heavy Rains")
				abort("Fight lord spookyraven yoursself (damage cap and damaging spells");
			visit_url("place.php?whichplace=manor4&action=manor4_chamberboss");
			bumRunCombat();
			if (item_amount($item[eye of ed]) == 0) abort("The Spooky man pwned you with his evil. Fight him yourself.");
		}
	}

	if (item_amount($item[eye of ed]) > 0) {
		checkStage("macguffinspooky", true);
		return true;
	}
	
	return false;
}

boolean bcascMacguffinPyramid() {
	boolean canEquipCompass() {
		return (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris");
	}
	
	string compassEquip() {
		string maxstr = "";
		if(my_primestat()==$stat[moxie])
			maxstr += "-melee";
		else if(my_primestat()==$stat[muscle])
			maxstr += "+melee";
		if (canEquipCompass()) {
			maxstr += " +equip UV-resistant compass";
		}
		return maxstr;
	}

	void get_drum_machine()
	{
		if(i_a("drum machine")>0) return;
		if (can_interact())
		{
			buy(1, $item[drum machine]);
			return;
		}
		if(!in_hardcore())
		{		
			cli_execute("pull drum machine");
			if(i_a("drum machine")>0)
				return;
		}
		while(i_a("drum machine") == 0)
		{
			bumAdv($location[The Oasis], "", "items", "1 drum machine", "Getting drum machine", "i");
		}
	}


	if (checkStage("macguffinpyramid")) return true;
	

	if (!contains_text(visit_url("questlog.php?which=1"),"Just Deserts") || contains_text(visit_url("questlog.php?which=1"),"found the little pyramid") || contains_text(visit_url("questlog.php?which=1"),"found the hidden buried pyramid")) {
 		//We've done the pyramid
		return checkStage("macguffinpyramid", true);
	} else {
		//get uv compass
		if (canEquipCompass()) {
			if(i_a("UV-resistant compass")==0)
			{
				print("BCC: You do not have a UV Compass. Let's get one.", "purple");
				if (item_amount($item[Shore Inc. Ship Trip Scrip]) < 1) {
					switch(my_primestat())
					{
						case $stat[Muscle] :
							set_property("choiceAdventure793", "1");
							break;
						case $stat[Mysticality] :
							set_property("choiceAdventure793", "2");
							break;
						case $stat[Moxie] :
							set_property("choiceAdventure793", "3");
							break;
					}
					adventure(1, $location[The Shore, Inc. Travel Agency]);
				}
				buy($coinmaster[The Shore\, Inc. Gift Shop], 1, ($item[UV-resistant compass]));
			}
 		} else {
			print("BCC: You cannot equip a UV Compass. Let's not get one.", "purple");
		}
		
		//unlock oasis
		if(!contains_text(visit_url("place.php?whichplace=desertbeach"),"oasis.gif"))
		{
			print("BCC: Oasis doesn't appear - let's spend ten adventures.", "purple");
			bumAdv($location[The Arid\, Extra-Dry Desert], compassEquip(), "", "", "", "", "", 10);
		}
		
		//meet gnasir
		set_property("choiceAdventure805","1");
		while (!contains_text(visit_url("place.php?whichplace=desertbeach"), "gnasir.gif")) 
		{
			if(have_effect($effect[ultrahydrated])==0)
				bumAdv($location[The Oasis], "items", "items", "", "", "", "", 1);
			print("meeting gnasir","purple");
			bumAdv($location[The Arid\, Extra-Dry Desert], compassEquip(), "", "", "", "", "", have_effect($effect[Ultrahydrated]));
		}
		
		//use any mysteriously obtained pamphlets
		if(i_a("desert sightseeing pamphlet")>0)
			use(i_a("desert sightseeing pamphlet"),$item[desert sightseeing pamphlet]);
		
		//get stone rose in oasis, with hipster, maybe drum machine
		if((get_property("gnasirProgress").to_int() & 1) == 0)
		{
			while(i_a("stone rose")==0)
				bumAdv($location[The Oasis], "", "hipster", "1 stone rose", "Getting the stone rose", "i");

			string txt=visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
			txt=visit_url("choice.php?pwd&whichchoice=805&option=2&choiceform2=%22I+found+your+stone+rose.%22");
			visit_url("choice.php?pwd&whichchoice=805&option=1&choiceform1=%22No%2C+that%27s+all.%22");
			if(!contains_text(txt,"give the stone rose to Gnasir"))
				abort("something went wrong handing in stone rose");
			use(1,$item[desert sightseeing pamphlet]);
		}

		//buy + hand in black paint
		if((get_property("gnasirProgress").to_int() & 2)==0)
		{
			if(i_a("post-holiday sale coupon")>0)use(1,$item[post-holiday sale coupon]);
			buy(1, $item[can of black paint]);
			cli_execute("inventory refresh");
			if(i_a("can of black paint")==0)
				abort("Failed to buy can of black paint");
			
			string txt=visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
			txt=visit_url("choice.php?pwd&whichchoice=805&option=2&choiceform2=%22I+brought+some+black+paint+for+your+door.%22");
			visit_url("choice.php?pwd&whichchoice=805&option=1&choiceform1=%22No%2C+that%27s+all.%22");
			if(!contains_text(txt,"ou hold up the bucket of black paint"))
				abort("something went wrong handing in black paint");
				
			use(1,$item[desert sightseeing pamphlet]);
		}
		
		//get a killing jar in library?
		//worthwhile only if <7 turns, which is what standard exploring will take
		if((get_property("gnasirProgress").to_int() & 4)==0)
		{
			if(!in_hardcore() && i_a("killing jar")==0)	
				cli_execute("pull killing jar");
			
			//get one, if it will take <7.5 turns
			if(i_a("killing jar")==0)
			{
				buMax("+i");
				setFamiliar("items");
				//75+x% combat chance, 1/3 chance of librarian, 0.1*items chance of drop
				float com=0.75 + numeric_modifier("combat rate")/100.0;
				float drop_chance=0.1*(1.0 + numeric_modifier("item drop")/100.0);
				float chance_per_adv= com * 0.3333 * drop_chance;
				
				//chance of finishing in <8 turns = 1-(1-cpa)^8
				//accept if chance is more than 95%
				float chance_of_finishing_in_time=1.0-((1.0-chance_per_adv)**8);
				if(chance_of_finishing_in_time>0.95)
				{
					while(i_a("killing jar")==0)
						bumAdv($location[The haunted library], "", "items", "1 killing jar", "Getting a killing jar", "+i");
				}
				else
				{
					print("Current modifiers mean we have only a "+chance_of_finishing_in_time*100.0+"% chance of the killing jar being worthwhile, so we are skipping it (req 95%+)","green");
				}
			}
			
			if(i_a("killing jar")>0)
			{
				string txt=visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
				txt=visit_url("choice.php?pwd&whichchoice=805&option=2&choiceform2=%22I+brought+you+that+killing+jar+you+wanted.%22");
				visit_url("choice.php?pwd&whichchoice=805&option=1&choiceform1=%22No%2C+that%27s+all.%22");
				if(!contains_text(txt,"hand Gnasir the glass jar"))
					abort("something went wrong handing in killing jar");
				use(1,$item[desert sightseeing pamphlet]);
			}
		}
		
		//fight mobs to unlock
		while(get_property("desertExploration").to_int()<100)
		{
			if(have_effect($effect[ultrahydrated])==0)
			{
				cli_execute("conditions clear");
				adventure(1,$location[The Oasis]);
			}
			//explore in desert with compass
			bumAdv($location[The arid\, extra-dry desert], compassEquip(), "items", "", "Exploring the desert", "i");

			//if we get all the worm riding pages, go worm riding
			if(i_a("worm riding manual page")>=15)
			{
				print("Collected worm manual pages","purple");
				get_drum_machine();
				string txt=visit_url("place.php?whichplace=desertbeach&action=db_gnasir");
				txt=visit_url("choice.php?pwd&whichchoice=805&option=2&choiceform2=%22I+think+I+found+all+the+missing+pages+of+your+book.%22");
				visit_url("choice.php?pwd&whichchoice=805&option=1&choiceform1=%22No%2C+that%27s+all.%22");
				if (item_amount($item[worm-riding hooks]) == 0) abort("something went wrong handing in manual pages.");
			}
			
			//ride
			if (item_amount($item[worm-riding hooks]) > 0)
			{
				print("Wormriding","purple");
				if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") {
					cli_execute("checkpoint; equip worm-riding hooks; use drum machine; outfit checkpoint");
				} else {
					cli_execute("use drum machine");
				}
				cli_execute("inventory refresh");
				if (item_amount($item[worm-riding hooks]) != 0) abort("something went wrong trying to wormride.");
			}	
		}
	}
	
	if(get_property("desertExploration").to_int()<100)
		abort("something went wrong discovering the pyramid");
	checkStage("macguffinpyramid", true);
	return true;
}

boolean bcascManorBathroom() {
	if (checkStage("manorbathroom")) return true;

	string questLog = visit_url("questlog.php?which=1");
	if(contains_text(questLog, "Lady Spookyraven's Dance")) {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		if (!contains_text(questLog, "her powder puff from the Haunted Bathroom") && contains_text(questLog, "her powder puff")) {
			checkStage("manorbathroom", true);
			return true;
		}
	} else {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		if(!contains_text(visit_url("questlog.php?which=1"), "Lady Spookyraven's Dance") && !contains_text(visit_url("questlog.php?which=7"),"Lady Spookyraven's Necklace")) {
			checkStage("manorbathroom", true);
			return true;
		}
	}

	if (my_buffedstat(my_primestat()) >= 85) {
		switch (my_primestat()) {
			case $stat[Muscle] :		set_property("choiceAdventure402", "1");	break;
			case $stat[Mysticality] :	set_property("choiceAdventure402", "2");	break;
			case $stat[Moxie] :			set_property("choiceAdventure402", "3");	break;
		}

		set_property("choiceAdventure882", 1); //get towel
		while (i_a("Lady Spookyraven's powder puff") == 0) {
			if (get_property("guyMadeOfBeesCount") < 4) {
				set_property("choiceAdventure105","3"); // say "guy made of bees"
			} else {
				set_property("choiceAdventure105","2");
				set_property("choiceAdventure107","4"); // skip adventure 
			}
		
			buMax("-combat");
			setMood((my_path() == "Avatar of Boris" || my_path() == "Avatar of Jarlsberg" || my_path() == "Avatar of Sneaky Pete" ? "" : "-"));
			cli_execute("mood execute");
			bumMiniAdv(1, $location[The Haunted Bathroom]);
		}

		if (i_a("Lady Spookyraven's powder puff") > 0) {
			checkStage("manorbathroom", true);
			return true;
		}
	}

	return false;
}

boolean bcascManorBedroom() {
	if (checkStage("manorbedroom")) return true;

	string questLog = visit_url("questlog.php?which=1");
	if(contains_text(questLog, "Lady Spookyraven's Dance")) {
		if (!contains_text(questLog, "her gown from the Haunted Bedroom") && contains_text(questLog, "her gown")) {
			checkStage("manorbedroom", true);
			return true;
		}
	} else {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		if(!contains_text(visit_url("questlog.php?which=1"), "Lady Spookyraven's Dance") && !contains_text(visit_url("questlog.php?which=1"), "Lady Spookyraven's Necklace")) {
			checkStage("manorbedroom", true);
			return true;
		}
	}

	if (my_path() == "Way of the Suprising Fist") {
		set_property("choiceAdventure876", "2"); // White=Muscle
	} else {
		set_property("choiceAdventure876", "1"); // White=Wallet
	}
	set_property("choiceAdventure877", "1"); // Mahogany=Coin Purse (We don't want to fight or get nothing from under the nightstand)
	set_property("choiceAdventure879", "1"); // Rustic=Moxie
	set_property("choiceAdventure880", "1"); // Elegant=Gown

	if(my_buffedstat(my_primestat()) >= 85) {
		while (i_a("Lady Spookyraven's finest gown") == 0) {
			if (i_a("Lord Spookyraven's spectacles") == 0) {
				set_property("choiceAdventure878", "3"); // Ornate=Spectacles
			} else if(i_a("disposable instant camera")==0){
				set_property("choiceAdventure878", "4"); // Ornate=Camera
			} else {
				set_property("choiceAdventure878", "1"); // Ornate=meat
			}
			print("adventuring for gown","green");
			bumminiAdv(1,$location[The Haunted Bedroom]);
			
			print("finished adv, using adv1 to do choice","green");
			adv1($location[noob cave],-1,"");
			if(!contains_text(get_property("lastEncounter"),"Nightstand"))
				abort("We accidentally went to noob cave instead of finishing the choiceadv");
			print("did choice, continuing","green");
		}
		//if we still haven't got a camera, try to pull
		if(i_a("disposable instant camera") == 0)
			cli_execute("pull disposable instant camera");
		set_property("choiceAdventure878", "4"); // Ornate=Camera
		while (i_a("disposable instant camera") == 0) {
			print("adventuring for instant camera","green");
			bumminiAdv(1,$location[The Haunted Bedroom]);
			
			print("finished adv, using adv1 to do choice","green");
			adv1($location[noob cave],-1,"");
			if(!contains_text(get_property("lastEncounter"),"Nightstand"))
				abort("We accidentally went to noob cave instead of finishing the choiceadv");
			print("did choice, continuing","green");
		}

		if (i_a("Lady Spookyraven's finest gown") > 0) {
			checkStage("manorbedroom", true);
			return true;
		}
	}

	return false;
}

boolean bcascManorGallery() {
	if (checkStage("manorgallery")) return true;

	string questLog = visit_url("questlog.php?which=1");
	if(contains_text(questLog, "Lady Spookyraven's Dance")) {
		if (!contains_text(questLog, "her shoes from the Haunted Gallery") && contains_text(questLog, "her shoes")) {
			checkStage("manorgallery", true);
			return true;
		}
	} else {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		if(!contains_text(visit_url("questlog.php?which=1"), "Lady Spookyraven's Dance") && !contains_text(visit_url("questlog.php?which=1"), "Lady Spookyraven's Necklace")) {
			checkStage("manorgallery", true);
			return true;
		}
	}

	if (my_buffedstat(my_primestat()) >= 85) {
		set_property("louvreGoal", "7");
		set_property("louvreDesiredGoal", "7");
		while (i_a("Lady Spookyraven's dancing shoes") == 0) {
			bumAdv($location[The Haunted Gallery], "", "", "Lady Spookyraven's dancing shoes", "Getting Lady Spookyraven's dancing shoes", "-");
		}

		if (i_a("Lady Spookyraven's dancing shoes") > 0) {
			checkStage("manorgallery", true);
		return true;
		}
	}

	return false;
}

boolean bcascManorBallroom() {
	if (checkStage("manorballroom")) return true;

	if (i_a("Lady Spookyraven's powder puff") + i_a("Lady Spookyraven's finest gown") + i_a("Lady Spookyraven's dancing shoes") >= 3) {
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		bumMiniAdv(1, $location[The Haunted Ballroom]);
		visit_url("place.php?whichplace=manor3&action=manor3_ladys");
		checkStage("manorballroom", true);
 		return true;
 	}

	if (get_property("questM21Dance") == "finished" || contains_text(visit_url("place.php?whichplace=manor2"), "snarfblat=395")) {
		checkStage("manorballroom", true);
		return true;
	}

 	return false;
 }


//SIMON Added this
boolean bcascSetSong()
{
	if (checkStage("setsong")) return true;
	set_property("choiceAdventure106", "2");
	while(to_int(get_property("lastQuartetAscension"))< my_ascensions())
		bumAdv($location[The Haunted Ballroom], "", "", "", "Setting the strung up quartet song", "-");
		
	if(get_property("lastQuartetRequest")!="2")
		abort("I thought we just set the quartet, but it seems to be on the wrong song now");

	if(to_int(get_property("lastQuartetAscension"))==my_ascensions() && get_property("lastQuartetRequest")!="2")
	{
		checkStage("setsong", true);
		return true;
	}
	return false;
}

boolean bcascManorBilliards() {
	if (checkStage("manorbilliards")) return true;
	print("bcascManorBilliards");

	void set_pool_choices()
	{
		print("Setting pool choiceadv (current skill="+get_property("poolSkill")+")", "blue");
		if(get_property("poolSkill").to_int()<16)
		{
			print("Training pool","blue");
			set_property("choiceAdventure875", 2);
		}
		else
		{
			print("beating ghost","blue");
			set_property("choiceAdventure875", 1);		
		}
	}
	//Ensure to set choiceadvs correctly.
#	set_property("choiceAdventure77", 2);
#	set_property("choiceAdventure330", 2);
#visit_url("inv_use.php?which=3&whichitem=7304&pwd&ajax=1");
#	set_property("choiceAdventure900", 2);

	//Kitchen
	if (item_amount($item[Spookyraven billiards room key]) == 0) {
		print("BCC: Getting the Billiards Key", "purple");
		if(have_path_familiar($familiar[Exotic Parrot]))
			cli_execute("familiar parrot");
		buMax("+1000 stench res, +1000 hot res");
		use_genetics_lab("res");
		while (item_amount($item[Spookyraven billiards room key]) == 0) {
			if (have_effect($effect[elemental saucesphere]) == 0 && have_skill($skill[elemental saucesphere]) && have_castitems($class[sauceror], true)) use_skill(1, $skill[elemental saucesphere]);
			if (have_effect($effect[astral shell]) == 0 && have_skill($skill[astral shell]) && have_castitems($class[turtle tamer], true)) use_skill(1, $skill[astral shell]);
			if (have_effect($effect[Protection from Bad Stuff]) == 0 && available_amount($item[scroll of Protection from Bad Stuff])>0) use(1, $item[scroll of Protection from Bad Stuff]);
			bumMiniAdv(1, $location[The Haunted Kitchen]);
		}
	}

	//Billiards Room
	while (item_amount($item[Spookyraven library key]) == 0) {
		while (i_a("pool cue") == 0) {
			set_pool_choices();
			bumAdv($location[The Haunted Billiards Room], (my_primestat() == $stat[mysticality]) ? "" : "+100000 elemental dmg", "", "1 pool cue", "Getting the Pool Cue", "-i");
		}
		
		print("BCC: Getting the Library Key", "purple");
		cli_execute("goal clear");
		while (item_amount($item[Spookyraven library key]) == 0) {
			set_pool_choices();
			if (i_a("handful of hand chalk") > 0 || have_effect($effect[Chalky Hand]) > 0) {
				print("BCC: We have either a hand chalk or Chalky Hands already, so we'll use the hand chalk (if necessary) and play some pool!", "purple");
				if (i_a("handful of hand chalk") > 0 && have_effect($effect[Chalky Hand]) == 0) {
					use(1, $item[handful of hand chalk]);
				}
			}
			bumAdv($location[The Haunted Billiards Room], (my_primestat() == $stat[mysticality]) ? "" : "+100000 elemental dmg", "", "", "playing pool", "-i");
		}
	}
	if (item_amount($item[Spookyraven library key]) > 0) {
		checkStage("manorbilliards", true);
		return true;
	}
	return false;
}

boolean bcascManorLibrary() {
	if (checkStage("manorlibrary")) return true;
	set_property("choiceAdventure888", "4"); //Rise
	if(my_primestat()==$stat[muscle])
	{
		set_property("choiceAdventure889", "2");  //Fall - musc
	}
	else
	{
		set_property("choiceAdventure889", "1");  //Fall - skip
	}
	
	//already done?
	visit_url("place.php?whichplace=manor1&action=manor1_ladys");
	if(!contains_text(visit_url("questlog.php?which=7"),"Lady Spookyraven's Necklace"))
	{
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		checkStage("manorlibrary", true);
		return true;
	}
		
	//Open up the second floor of the manor. 
	while (available_amount($item[Lady Spookyraven's necklace]) == 0) {
		bumAdv($location[The Haunted Library], "", "", "1 lady spookyraven's necklace", "Opening Second floor of the Manor", "+");
	}
	if (available_amount($item[Lady Spookyraven's necklace]) > 0) {
		visit_url("place.php?whichplace=manor1&action=manor1_ladys");
	}
	else
		abort("Failed to get necklace");
	
	//if we are done, get next stage
	if(!contains_text(visit_url("questlog.php?which=7"),"Lady Spookyraven's Necklace"))
	{
		visit_url("place.php?whichplace=manor2&action=manor2_ladys");
		checkStage("manorlibrary", true);
		return true;
	}
	return false;
}

boolean bcascMeatcar() {
	if (checkStage("meatcar")) return true;
	
	if (contains_text(visit_url("place.php?whichplace=desertbeach"), "db_shore")) return checkStage("meatcar", true);
	
	if (my_path() != "Bees Hate You" || knoll_available()) {
		if (item_amount($item[bitchin' meatcar]) + item_amount($item[pumpkin carriage]) + item_amount($item[desert bus pass]) == 0) {
			print("BCC: Getting the Meatcar", "purple");
			//Gotta hit up paco.
			visit_url("guild.php?place=paco");
			if (item_amount($item[sweet rims]) + item_amount($item[dope wheels]) == 0)
				cli_execute("buy 1 sweet rims");
			
			if (!knoll_available()) {
				print("BCC: Making the meatcar, getting the stuff from the Gnolls. Damned Gnolls...", "purple");
				visit_url("forestvillage.php?action=screwquest&submit=&quot;Sure Thing.&quot;");
				buMax();
				use(item_amount($item[gnollish toolbox]), $item[gnollish toolbox]);
				while (creatable_amount($item[bitchin' meatcar]) == 0) {
					use(item_amount($item[gnollish toolbox]), $item[gnollish toolbox]);
					if (my_adventures() == 0)
					{
						cli_execute("shower "+my_primestat());
						abort("No adventures left :(");
					}
		
					//place florist friar plants
					choose_all_plants("", $location[The degrassi knoll Garage]);
					
					bumMiniAdv(1, $location[The Degrassi Knoll Garage]);
				}
			}
			cli_execute("make bitchin' meatcar");
			visit_url("guild.php?place=paco");
		}
	} else if(i_a("pumpkin") > 0) {
		if (item_amount($item[pumpkin carriage]) + item_amount($item[desert bus pass]) == 0) {
			print("BCC: Bees hate You: Getting a Pumpkin Carriage", "purple");
			//Gotta hit up paco.
			visit_url("guild.php?place=paco");
			if (item_amount($item[sweet rims]) + item_amount($item[dope wheels]) == 0)
				cli_execute("buy 1 sweet rims");
				
			print("BCC: Making the dope wheels, getting the stuff from the Gnolls. Damned Gnolls...", "purple");
			visit_url("forestvillage.php?action=screwquest&submit=&quot;Sure Thing.&quot;");			
			buMax();
			while (creatable_amount($item[dope wheels]) == 0) {
				if (my_adventures() == 0)
				{
					cli_execute("shower "+my_primestat());
					abort("No adventures left :(");
				}
	
				//place florist friar plants
				choose_all_plants("", $location[The degrassi knoll Garage]);
				
				bumMiniAdv(1, $location[The Degrassi Knoll Garage]);
			}
			cli_execute("make pumpkin carriage");
			visit_url("guild.php?place=paco");
		}
	} else {
		if(my_meat() > 5000)
		{
			if(i_a("post-holiday sale coupon")>0) use(1,$item[post-holiday sale coupon]);
			cli_execute("buy 1 desert bus pas");
		}
		else
			abort("BCC: Bees Hate You. You have no pumpkins. You have no meat. Go fix!");
	}
	checkStage("meatcar", true);
	return true;
}

//Thanks, picklish!
boolean bcascMining() {
	if (checkStage("mining")) return true;
	print("about to do mining stage","lime");
	string trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	if (my_level() >= 8 && !contains_text(trapper, "ore and some consarned goat cheese") && !contains_text(trapper, "fix the lift until you bring me that")) {
		print("Looks like we're done.", "purple");
		checkStage("mining", true);
		return true;
	}

	string goalString = get_property("trapperOre");
	item goal = to_item(goalString);

	if (goal != $item[asbestos ore] && goal != $item[chrome ore] && goal != $item[linoleum ore])
		abort("Can't figure out which ore to look for.");

	// Seed ore locations with what mafia knows about.
	int[int] oreLocations;
	string mineLayout = get_property("mineLayout1");
	int start = 0;
	while (true) {
		int num_start = index_of(mineLayout, '#', start);
		if (num_start == -1) break;
		int num_end = index_of(mineLayout, '<', num_start);
		if (num_end == -1) break;
		int end = index_of(mineLayout, '>', num_end);
		if (end == -1) break;

		if (contains_text(substring(mineLayout, num_end, end), goalString)) {
			int spot = to_int(substring(mineLayout, num_start + 1, num_end));
			oreLocations[count(oreLocations)] = spot;
		}
		start = end;
	}

	boolean rowContainsEmpty(string mine, int y) {
		for x from 1 to 6 {
			if (contains_text(mine, "Open Cavern (" + x + "," + y + ")"))
				return true;
		}

		return false;
	}

	boolean canMine(string mine, int x, int y, boolean onlySparkly) {
		if (x < 0 || x > 7 || y < 0 || y > 7) return false;
		int index = x + y * 8; 
		boolean clickable = (index_of(mine, "mining.php?mine=1&which=" + index + "&") != -1);

		if (!clickable || !onlySparkly) return clickable;

		return contains_text(mine, "Promising Chunk of Wall (" + x + "," + y + ")");
	}

	int adjacentSparkly(string mine, int index) {
		int x = index % 8;
		int y = index / 8;

		if (canMine(mine, x, y - 1, true)) return index - 8;
		if (canMine(mine, x - 1, y, true)) return index - 1;
		if (canMine(mine, x + 1, y, true)) return index + 1;
		if (canMine(mine, x, y + 1, true)) return index + 8;
		return - 1;
	}

	int findSpot(string mine, boolean[int] rows, boolean[int] cols) {
		foreach sparkly in $booleans[true, false] {
			foreach y in cols {
				foreach x in rows {
					if (canMine(mine, x, y, sparkly))
						return x + y * 8;
				}
			}
		}
		return -1;
	}
	if(my_path() != "Avatar of Boris") {
		if (my_path() != "Way of the Surprising Fist") {
			cli_execute("outfit mining gear");
		} else {
			if (!have_skill($skill[Worldpunch])) abort("You need the skill Worldpunch, grasshopper.");
		}
	}

	while (item_amount(goal) < 3) {
		if(my_path() != "Avatar of Boris") {
			if (my_hp() == 0) cli_execute("restore hp");
			if ((my_path() == "Way of the Surprising Fist") && (have_effect($effect[Earthen Fist]) == 0)) {
				if (my_mp() < mp_cost($skill[Worldpunch])) restore_mp(mp_cost($skill[Worldpunch]));
				cli_execute("cast Worldpunch");
			}
				
			string mine = visit_url("mining.php?intro=1&mine=1");
			if (contains_text(mine, "You can't mine without the proper equipment.")) abort("Couldn't equip mining gear.");

			boolean willCostAdventure = contains_text(mine, "takes one Adventure.");
			if (have_skill($skill[Unaccompanied Miner]) && willCostAdventure && have_effect($effect[Teleportitis]) == 0 && my_level() < 12) {
				if (bcasc_MineUnaccOnly) {
					print("BCC: No more mining today. I'll come back later.", "purple");
					return false;
				}
			}
			if (my_adventures() == 0 && willCostAdventure)
			{
				cli_execute("shower "+my_primestat());
				abort("No adventures left :(");
			}

			int choice = -1;
			string why = "Mining around found ore";
			// Ore is always coincident, so look nearby if we've aleady found some.
			if (count(oreLocations) > 0) {
				foreach key in oreLocations {
					choice = adjacentSparkly(mine, oreLocations[key]);
					if (choice != -1)
						break;
				}
			}


			// Prefer mining the middle first.  It leaves more options.
			boolean[int] rows = $ints[3, 4, 2, 5, 1, 6];
			// First, try to mine up to the top four rows if we haven't yet.
			if (choice == -1 && !rowContainsEmpty(mine, 6)) {
				choice = findSpot(mine, rows, $ints[6]);
				why = "Mining upwards";
			} 
			if (choice == -1 && !rowContainsEmpty(mine, 5)) {
				choice = findSpot(mine, rows, $ints[5]);
				why = "Mining upwards";
			}
					
			// Top three rows contain most ore.  Fourth row may contain ore.
			// Prefer second row and digging towards the middle because it
			// opens up the most potential options.  This could be more
			// optimal, but it's not a bad heuristic.
			if (choice == -1) {
				choice = findSpot(mine, rows, $ints[2, 3, 1, 4]);
				why = "Mining top four rows";
			}
			// There's only four pieces of the same ore in each mine.
			// Maybe you accidentally auto-sold them or something?
			if (choice == -1 || count(oreLocations) == 4) {
				print("BCC: Resetting mine!", "purple");
				visit_url("mining.php?mine=1&reset=1&pwd");
				oreLocations.clear();
				continue;
			}
			print(why + ": " + (choice % 8) + ", " + (choice / 8) + ".", "purple");
			string result = visit_url("mining.php?mine=1&which=" + choice + "&pwd");
			if (index_of(result, goalString) != -1) {
				oreLocations[count(oreLocations)] = choice;
			}
		}
		else {
			bumAdv($location[Itznotyerzitz Mine], "", "items", "3 " + goal, "Adventuring for the ore of the mountain man.", "i");
		}
	}

	if (have_effect($effect[Beaten Up]) > 0) cli_execute("unaffect beaten up");
	visit_url("place.php?whichplace=mclargehuge&action=trappercabin");

	checkStage("mining", true);
	return true;
}

boolean bcascMirror() {
	if(my_path() != "Bees Hate You") return false;
	if(checkStage("mirror")) return true;

	set_property("choiceAdventure85", 5); //hotdog / key / combat
	while(i_a("antique hand mirror") == 0) {
		bumAdv($location[The Haunted Bedroom], "", "itemsnc", "antique hand mirror", "Getting an anqique hand mirror to tackle the end boss.", "-i");
		
		print("finished adv, using adv1 to do choice","green");
		adv1($location[noob cave],-1,"");
		if(!contains_text(get_property("lastEncounter"),"Nightstand"))
			abort("We accidentally went to noob cave instead of finishing the choiceadv");
		print("did choice, continuing","green");
	}
	
	checkStage("mirror", true);
	return true;
}

void bcascNaughtySorceress() {
	if (contains_text(visit_url("main.php"), "lair.php")) {
		//Get through the initial three doors. 
		while (!contains_text(visit_url("lair1.php"), "lair2.php")) {
			bcascLairFirstGate();
		}
		
		//Now try to get through the rest of the entryway.
		while (!contains_text(visit_url("lair2.php"), "lair3.php")) {
			bcascLairMariachis();
		}
		
		//Get through the hedge maze. Though we'll only ever spend one adventure at a time here, we use bumAdv for moxie maximiazation. 
		while (!contains_text(visit_url("lair3.php"), "lair4.php")) {
			if (item_amount($item[hedge maze puzzle]) == 0) bumAdv($location[Sorceress' Hedge Maze], "", "items", "1 hedge maze puzzle", "Getting another Hedge Maze", "i");
			if (hedgemaze()) {}
		}
		
		while (!contains_text(visit_url("lair4.php"), "lair5.php")) {
			bcascLairTower();
		}
		
		while (!contains_text(visit_url("lair5.php"), "lair6.php")) {
			bcascLairTower();
		}
		
		while (!contains_text(visit_url("lair6.php"), "?place=5")) {
			bcascLairTower();
		}
		
		bcascLairFightNS();
	} else if (my_path() == "Bugbear Invasion") {
		bcascLairFightNS();
	} else {
		abort("There is some error and you don't appear to be able to access the lair...");
	}
}

boolean bcascPantry() {
	if (to_int(get_property("lastManorUnlock")) == my_ascensions()) return checkStage("pantry", true);
	visit_url("inv_use.php?which=3&whichitem=7304&pwd&ajax=1");
#	while (contains_text(visit_url("place.php?whichplace=town_right"), "pantry.gif")) {
#		bumAdv($location[The Haunted Pantry], "", "", "", "Let's open the Pantry");
#	}
	return true;
}

boolean bcascPirateFledges() {
	boolean hitTheBarrr = false;
	if (checkStage("piratefledges")) return true;
	
	while ((i_a("eyepatch") == 0 || i_a("swashbuckling pants") == 0 || i_a("stuffed shoulder parrot") == 0) && i_a("pirate fledges") == 0) {
		bumAdv($location[The Obligatory Pirate's Cove], "", "equipmentnc", "1 eyepatch, 1 swashbuckling pants, 1 stuffed shoulder parrot", "Getting the Swashbuckling Kit", "-i");
	}
	
	if (i_a("pirate fledges") == 0) {
		buMax("+outfit swashbuckling getup");
		
		//The Embarassed problem is only an issue if you're a moxie class. Otherwise, ignore it.
		if (my_primestat() == $stat[Moxie]) {
			cli_execute("speculate up Embarrassed; quiet");
			int safeBarrMoxie = 93;
			int specMoxie = 0;
			while (!hitTheBarrr && in_hardcore()) {
				specMoxie = numeric_modifier("_spec", "Buffed Moxie");
				if (specMoxie > safeBarrMoxie || bcasc_ignoreSafeMoxInHardcore) { hitTheBarrr = true; }
				if (!hitTheBarrr) { levelMe(my_basestat($stat[Moxie])+3, true); }
			}
			
			setMCD(specMoxie, safeBarrMoxie);
		} else {
			cli_execute("mcd 0");
			levelMe(safeMox($location[Barrrney's Barrr]));
		}
		
		buMax("+outfit swashbuckling getup");

		//Check if we've unlocked the f'c'le at all.
		if (index_of(visit_url("cove.php"), "cove3_3x1b.gif") == -1) {
			//put away insult book
			if(i_a("big book of pirate insults")>1)
			{
				cli_execute("closet put big book of pirate insults");
			}
			if(i_a("massive manual of marauder mockery")>1)
			{
				cli_execute("closet put massive manual of marauder mockery");
			}
			
			string maxstr;
			if(my_path() != "Avatar of Boris")
			{
				maxstr="+outfit swashbuckling getup";
				
				if(i_a("ice harvest")>2 || i_a("ice bucket")>0)
				{
					if(i_a("ice bucket")==0)
					{
						create(1,$item[ice bucket]);
					}
					maxstr=maxstr+", +equip ice bucket";
				}
				else
				{
					//try to make a light and add it to maxstr
					if(i_a("A Light that Never Goes Out")<1 && have_skill($skill[summon smithsness]))
					{
						if(i_a("brituminous coal")==0)
						{
							use_skill(1,$skill[summon smithsness]);
						}
						cli_execute("create a light that never goes out");
					}

					if(i_a("A Light that Never Goes Out")<1 && stash_amount($item[a light that never goes out])>0)
					{
						cli_execute("pull a light that never goes out");
					}
					if(i_a("A Light that Never Goes Out")>0)
					{
						maxstr=maxstr+", +equip A Light that Never Goes Out";
					}
				}
					
				buMax(maxstr);
			} else {
				outfit("swashbuckling getup");
				equip($item[Trusty]);
			}
			setFamiliar("");
			setMood("i");
			
			if (my_path() != "Bees Hate You") {
				if (i_a("the big book of pirate insults") == 0) {
					if(i_a("post-holiday sale coupon")>0)use(1,$item[post-holiday sale coupon]);
					buy(1, $item[the big book of pirate insults]);
				}
			} else {
				if (i_a("Massive Manual of Marauder Mockery") == 0) {
					if(i_a("post-holiday sale coupon")>0)use(1,$item[post-holiday sale coupon]);
					buy(1, $item[Massive Manual of Marauder Mockery]);
				}
			}
			
			cli_execute("condition clear");
			//Have we been given the quest at all?
			while (!contains_text(visit_url("questlog.php?which=1"), "I Rate, You Rate")) {
				print("BCC: Adventuring once at a time to meet the Cap'm for the first time.", "purple");
				if (can_interact()) {
	
					//place florist friar plants
					choose_all_plants("", $location[barrrney's barrr]);
					
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultCasual");
				} else {
	
					//place florist friar plants
					choose_all_plants("", $location[barrrney's barrr]);
					
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultBarrr");
				}
			}
			
			//Check whether we've completed the beer pong quest.
			if (index_of(visit_url("questlog.php?which=1"), "Caronch has offered to let you join his crew") > 0) {
				print("BCC: Getting and dealing with the Cap'm's Map.", "purple");
				
				if (i_a("Cap'm Caronch's Map") == 0)
					bumAdv($location[Barrrney's Barrr], "+outfit swashbuckling getup", "", "1 Cap'm Caronch's Map", "", "Getting the Cap'm's Map", "consultBarrr");
				
				//Use the map and fight the giant crab.
				if (i_a("Cap'm Caronch's Map") > 0) {
					print("BCC: Using the Cap'm's Map and fighting the Giant Crab", "purple");
					use(1, $item[Cap'm Caronch's Map]);
					bumRunCombat();
					if (have_effect($effect[Beaten Up]) > 0 || i_a("Cap'm Caronch's nasty booty")== 0) abort("Uhoh. Please use the map and fight the crab manually.");
				} else {
					abort("For some reason we don't have the map even though we should have.");
				}
			}
			
			//If we have the booty, we'll need to get the map.
			if (i_a("Cap'm Caronch's nasty booty") > 0)
				bumAdv($location[Barrrney's Barrr], "+outfit swashbuckling getup", "", "1 Orcish Frat House blueprints", "Getting the Blueprints", "", "consultBarrr");
			
			//Now, we'll have the blueprints, so we'll need to make sure we have 8 insults before using them. 
			while (numPirateInsults() < 6) {
				if(i_a("the big book of pirate insults")==0 && i_a("massive manual of marauder mockery")==0)
					abort("Trying to get insults without book");
				print("BCC: Adventuring one turn at a time to get 6 insults. Currently, we have "+numPirateInsults()+" insults.", "purple");
				if (my_adventures() == 0)
				{
					cli_execute("shower "+my_primestat());
					abort("No adventures left :(");
				}
				if (can_interact()) {
	
					//place florist friar plants
					choose_all_plants("", $location[Barrrney's Barrr]);
				
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultCasual");
				} else {
	
					//place florist friar plants
					choose_all_plants("", $location[Barrrney's Barrr]);
					
					bumMiniAdv(1, $location[Barrrney's Barrr], "consultBarrr");
				}
			}
			
			print("BCC: Currently, we have "+numPirateInsults()+" insults. This is enough to continue with beer pong.", "purple");
			
			//Need to use the blueprints.
			if (index_of(visit_url("questlog.php?which=1"), "Caronch has given you a set of blueprints") > 0) {
				//try to pull whats needed
				if(!in_hardcore())
				{
					int route1pulls = 3-i_a("hot wing");
					if(!knoll_available())
						route1pulls += 1-i_a("frilly skirt");
					int route2pulls = 1-i_a("mullet wig");
					route2pulls += 1-i_a("briefcase");
					if(route1pulls < route2pulls)
					{
						if(i_a("hot wing")<3)
							cli_execute("pull "+to_string(3-i_a("hot wing"))+" hot wing");
						if(i_a("frilly skirt")<1 && !knoll_available())
							cli_execute("pull frilly skirt");
					}
					else
					{
						if(i_a("mullet wig")<1)
							cli_execute("pull mullet wig");
						if(i_a("briefcase")<1)
							cli_execute("pull briefcase");
					}
					
				}
				//now do it
				if(i_a("mullet wig") > 0 && i_a("briefcase") > 0) {
					print("BCC: Using the mullet wig and briefcase to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("equip mullet wig");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					visit_url("choice.php?whichchoice=188&option=2&choiceform2=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else if(i_a("Orcish baseball cap") > 0 && i_a("homoerotic frat-paddle") > 0 && i_a("Orcish cargo shorts") > 0) {
					print("BCC: Using the Frat Outfit to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("outfit frat boy ensemble");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					visit_url("choice.php?whichchoice=188&option=1&choiceform1=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else if ((knoll_available() || i_a("frilly skirt") > 0) && i_a("hot wing") >= 3) {
					print("BCC: Using the skirt and hot wings to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("equip frilly skirt");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					visit_url("choice.php?whichchoice=188&option=3&choiceform3=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else if(my_adventures() > 0) {
					while((i_a("Orcish baseball cap") == 0 || i_a("homoerotic frat-paddle") == 0 || i_a("Orcish cargo shorts") == 0))
						bumAdv($location[Frat House], "", "items", "", "Getting the Frat Outfit to burgle the Frat House...", "-i");
					if(my_adventures() == 0) {
						abort("Please use the blueprints. I was not able to use them automatically, unfortunately :(");
					}
					print("BCC: Using the Frat Outfit to burgle the Frat House...", "purple");
					cli_execute("checkpoint");
					cli_execute("outfit frat boy ensemble");
					visit_url("inv_use.php?which=3&whichitem=2951&pwd");
					visit_url("choice.php?whichchoice=188&option=1&choiceform1=Catburgle&pwd");
					cli_execute("outfit checkpoint");
				} else {
					abort("Please use the blueprints. I was not able to use them automatically, unfortunately :(");
				}
			}
			
			if (i_a("Cap'm Caronch's dentures") > 0) {
				buMax("+outfit swashbuckling getup");
				print("BCC: Giving the dentures back to the Cap'm.", "purple");
				while (available_amount($item[Cap'm Caronch's dentures]) > 0) bumMiniAdv(1, $location[Barrrney's Barrr]);
			}
			
			print("BCC: Now going to do the beer pong adventure.", "purple");
			
			while (my_adventures() > 0) {
				if (tryBeerPong().contains_text("victory laps")) {
					break;					
				}
			}
		}
		
		
		//When we get to here, we've unlocked the f'c'le. We must assume the user hasn't used the mop, polish or shampoo.
		//use some once per day item buffs if we can
		cli_execute("pool 3"); //probably used by cyrpt for init
		if(i_a("The Legendary Beat")>0) use(1,$item[The Legendary Beat]);
		if(i_a("goblin water")>0) use(1,$item[goblin water]);
		get_kolhs_buff("items");
		if(i_a("lavender candy heart")>0) use(1,$item[lavender candy heart]);
		if(numeric_modifier("Item Drop")<200 && dispensary_available() && have_effect($effect[heavy petting])<10) use(1,$item[Knob Goblin pet-buffing spray]);
		if(numeric_modifier("Item Drop")<200 && dispensary_available() && have_effect($effect[peeled eyeballs])<10) use(1,$item[knob goblin eyedrops]);
	}
	
	while (i_a("pirate fledges") == 0) {
		eat_hot_dog("Junkyard dog",$location[The F'C'le]);
		bumAdv($location[The F'c'le], "+outfit swashbuckling getup", "items", "1 pirate fledges", "Getting the Pirate Fledges, finally!", "+i");
	}
	checkStage("piratefledges", true);
	return true;
}

boolean bcascSpookyForest() {
	if (to_int(get_property("lastTempleUnlock")) == my_ascensions()) {bprint("spookyforest"); return true;}
	while (is_not_yet(get_property("questL02Larva"),"finished") && my_adventures() > 0) {
		set_property("choiceAdventure502", "2");
		set_property("choiceAdventure505", "1");
		bumAdv($location[The Spooky Forest], "", "", "1 choiceadv", "Let's get the mosquito", "-");
		visit_url("council.php");
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());
	}
	
	if (my_level() >= 11 && get_property("bcasc_dontLevelInTemple") == "true") {
		checkStage("spookyforest", true);
		return true;
	}
	
	if (to_int(get_property("lastTempleUnlock")) != my_ascensions() && get_property("bcasc_openTempleLater") != "true") {
		bcascOpenTemple();
	}
	bprint("spookyforest");
	return true;
}

//Thanks, picklish!
boolean bcascTavern() {
	//if we haven't done larva return
	if(!is_equal_to(get_property("questL02Larva"), "finished")) return false;
	if (is_equal_to(get_property("questL03Rat"), "finished")) {bprint("tavern"); return true;}

	setFamiliar("");
	cli_execute("mood execute");
	levelMe(safeMox($location[The Typical Tavern Cellar]));
	if (canMCD() && !(bcasc_AllowML && bcasc_ignoreSafeMoxInHardcore)) cli_execute("mcd 0");
	visit_url("council.php");
	visit_url("tavern.php?place=barkeep");
	setMood("");
	buMax();
	
	//Re-get the current tavern layout.
	visit_url("cellar.php");

	
	while (!get_property("tavernLayout").contains_text("3")) {
		if (my_adventures() == 0)
		{
			cli_execute("shower "+my_primestat());
			abort("No adventures left :(");
		}
		print("BCC: We are adventuring at the tavern", "purple");
		tavern();
	}
	visit_url("rats.php?action=faucetoff");
	visit_url("tavern.php?place=barkeep");
	visit_url("tavern.php?place=barkeep");

	//for zombies, try to kill baron
	if(my_path() == "Zombie Slayer")
	{
		set_property("choiceAdventure511","1");
		string layout=get_property("tavernLayout");
		print("layout="+layout,"lime");
		while (!get_property("tavernLayout").contains_text("4") && !get_property("tavernLayout").contains_text("6")) {
			print("BCC: We are adventuring at the tavern to find the baron", "purple");
			if (my_adventures() == 0)
			{
				cli_execute("shower "+my_primestat());
				abort("No adventures left :(");
			}
			betweenBattle();
			//check along bottom row
			if(char_at(layout,20)=="0")
			{
				print("char_at(20)="+char_at(layout,20),"lime");
				print("21","lime");
				visit_url("cellar.php?action=explore&whichspot=21");
				bumRunCombat();
			}
			else if(char_at(layout,21)=="0")
			{
				print("char_at(21)="+char_at(layout,21),"lime");
				print("22","lime");
				visit_url("cellar.php?action=explore&whichspot=22");
				bumRunCombat();
			}
			else if(char_at(layout,22)=="0")
			{
				print("char_at(22)="+char_at(layout,22),"lime");
				print("23","lime");
				visit_url("cellar.php?action=explore&whichspot=23");
				bumRunCombat();
			}
			else if(char_at(layout,23)=="0")
			{
				print("char_at(23)="+char_at(layout,23),"lime");
				print("24","lime");
				visit_url("cellar.php?action=explore&whichspot=24");
				bumRunCombat();
			}
			else if(char_at(layout,24)=="0")
			{
				print("char_at(24)="+char_at(layout,24),"lime");
				print("25","lime");
				visit_url("cellar.php?action=explore&whichspot=25");
				bumRunCombat();
			}
			else
			{
				abort("I think i've checked the bottom row of the tavern without finding the baron");
			}
			layout=get_property("tavernLayout");
		}
	}
	bprint("tavern");
	return is_equal_to(get_property("questL03Rat"), "finished"); 
}

boolean bcascTeleportitisBurn() {
	if (have_effect($effect[Teleportitis]) == 0) return true;
	print("BCC: Burning off teleportitis", "purple");
	// We used to be able to burn this off at the shore, but can't now.
	if (have_effect($effect[Teleportitis]) == 0) return true;
	bcascMining();
	if (have_effect($effect[Teleportitis]) == 0) return true;
	bcascDailyDungeon();
	if (have_effect($effect[Teleportitis]) == 0) return true;
	if(i_a("soft green echo eyedrop antidote")>0) cli_execute("uneffect teleportitis");
	bumMiniAdv(have_effect($effect[Teleportitis]), $location[The Haunted Kitchen]);
	return true;
}

boolean bcascTelescope() {
	if (checkStage("lair0")) return true;
//	if (!in_hardcore() && !bcasc_RunSCasH) return false;
	if (my_level() >= 13) {
		if (contains_text(visit_url("lair1.php"), "lair2.php")) return true;
	}
	if(my_daycount()<3) //don't pull before day 3, we need those pulls for other things
		return false;
	cli_execute("use * canopic jar");
	cli_execute("use * black picnic basket");

	record lair { 
		string loc;
		string a;
		string thing;
		string section;
		boolean autoadventure;
		string maxme;
	};
	
	lair [string] telescope;
	lair level;
	string telescopetext;
	telescope["catch a glimpse of a flaming katana"] 			= new lair("Ninja Snowmen", "a ", "frigid ninja stars", "questL08Trapper", true);
	telescope["catch a glimpse of a translucent wing"] 			= new lair("The Sleazy Back Alley", "a ", "spider web", "guild", true);
	telescope["see a fancy-looking tophat"] 				= new lair("Guano Junction", "a ", "sonar-in-a-biscuit", "bats1", true, " +stench resistance ");
	telescope["see a flash of albumen"] 					= new lair("Black Forest", "", "black pepper", "macguffinprelim", false);
	telescope["see a giant white ear"] 					= new lair("The Hidden Park", "a ", "pygmy blowgun", "macguffinhiddencity", true);
	telescope["see a huge face made of Meat"] 				= new lair("Orc Chasm", "a ", "meat vortex", "chasm", true);
	telescope["see a large cowboy hat"] 					= new lair("The Castle in the Clouds in the Sky (Ground Floor)", "a ", "chaos butterfly", "castle", true);
	telescope["see a periscope"] 						= new lair("Fantasy Airship", "a ", "photoprotoneutron torpedo", "airship", true);
	telescope["see a slimy eyestalk"] 					= new lair("Haunted Bathroom", "", "fancy bath salts", "manorbedroom", true);
	telescope["see a strange shadow"] 					= new lair("Haunted Library", "an ", "inkwell", "manorbilliards", true);
	telescope["see moonlight reflecting off of what appears to be ice"] 	= new lair("The Market", "an", "hair spray", "buyfromthemarket", false);
	telescope["see part of a tall wooden frame"] 				= new lair("Cobb's Knob Harem", "a ", "disease", "knobking", true);
	telescope["see some amber waves of grain"]				= new lair("The Arid\, Extra-Dry Desert", "a ", "bronzed locus", "macguffinpyramid", true);
	telescope["see some long coattails"] 					= new lair("Outskirts of the Knob", "a ", "Knob Goblin firecracker", "guild", true);
	telescope["see some pipes with steam shooting out of them"] 		= new lair("Middle Chamber", "", "powdered organs", "macguffinfinal", false);
	telescope["see some sort of bronze figure holding a spatula"]		= new lair("Haunted Kitchen", "", "leftovers of indeterminate origin", "pantry", true);
	telescope["see the neck of a huge bass guitar"] 			= new lair("South of the Border", "a ", "mariachi G-string", "dinghy", true);
	telescope["see what appears to be the North Pole"] 			= new lair("Orc Chasm", "an ", "NG", "chasm", false);
	telescope["see what looks like a writing desk"] 			= new lair("The Castle in the Clouds in the Sky (Ground Floor)", "a ", "plot hole", "castle", true);
	telescope["see the tip of a baseball bat"] 				= new lair("Guano Junction", "a ", "baseball", "bats1", true, " +stench resistance ");
	telescope["see what seems to be a giant cuticle"] 			= new lair("Haunted Pantry", "a ", "razor-sharp can lid", "guild", true);
	telescope["see a pair of horns"] 					= new lair("Moxie Vacation", "", "barbed-wire fence", "dinghy", false);
	telescope["see a formidable stinger"] 					= new lair("Mysticality Vacation", "a ", "tropical orchid", "dinghy", false);
	telescope["see a wooden beam"] 						= new lair("Muscle Vacation", "a ", "stick of dynamite", "dinghy", false);
	telescope["an armchair"] 						= new lair("The Hidden Park", "", "pygmy pygment", "macguffinhiddencity", true);
	telescope["a cowardly-looking man"] 					= new lair("Pandamonium Slums", "a ", "wussiness potion", "Pandamonium Slums", false);
	telescope["a banana peel"] 						= new lair("Next to that Barrel with Something Burning in it", "", "gremlin juice", "post-war junkyard", false);
	telescope["a coiled viper"] 						= new lair("Black Forest", "an ", "adder bladder", "macguffinprelim", true);
	telescope["a rose"] 							= new lair("The Castle in the Clouds in the Sky (Top Floor)", "", "Angry Farmer candy", "castle", true);
	telescope["a glum teenager"] 						= new lair("The Castle in the Clouds in the Sky (Top Floor)", "a ", "thin black candle", "castle", true);
	telescope["a hedgehog"] 						= new lair("Fantasy Airship", "", "super-spiky hair gel", "airship", true);
	telescope["a raven"] 							= new lair("Black Forest", "", "Black No. 2", "macguffinprelim", true);
	telescope["a smiling man smoking a pipe"] 				= new lair("The Castle in the Clouds in the Sky (Top Floor)", "", "Mick's IcyVapoHotness Rub", "castle", true);
	
	if (my_path() == "Bees Hate You") {
		if (i_a("packet of orchid seeds") > 0 && i_a("tropical orchid") == 0) use(1, $item[packet of orchid seeds]) ;
		if (i_a("honeypot") == 0 && i_a("handful of honey") >= 3) create(1, $item[honeypot]);
	} else {
		if (get_property("telescopeUpgrades") >= 1) {
			if (get_property("lastTelescopeReset") != get_property("knownAscensions")) cli_execute("telescope");
			
			for i from get_property("telescopeUpgrades").to_int() downto 1 {
				telescopetext = get_property("telescope"+i);
				print("Checking telescope "+i+", "+telescopetext,"lime");
				level = telescope[telescopetext];

				if (i_a(level.thing) == 0) {
					//print("contains_text(level.section, quest) = " + contains_text(level.section, "quest")  + ", level.section = " + level.section);
					if (((contains_text(level.section, "quest") ? is_at_least(get_property(level.section),"finished") : get_property("bcasc_stage_"+level.section) == my_ascensions()) || level.section == "") && (level.loc != "")) {
						if(level.thing == $item[hair spray] && available_amount($item[hair spray])<1)
							buy(1,$item[hair spray]);
						else if(level.thing == $item[ng] && i_a("ng")<1 && i_a("lowercase n")>0 && i_a("original g")>0)
							create(1,$item[ng]);
						else if(!in_hardcore())
							cli_execute("pull "+level.thing);
							
						if(i_a(level.thing)<1)
						{
							if (level.autoadventure) {
								if(i_a(level.thing)==0)
									bumAdv(to_location(level.loc), level.maxme, "items", "1 "+level.thing, "Getting "+level.a+level.thing+" for the NS tower because we have finished the stage '"+level.section+" in this script.");
							} else {
								print("BCC: Please get "+level.thing+" for telescope part "+i+" from '"+level.loc+"' yourself", "purple");
								return false;
							}
						}
					} else {
						print("BCC: You haven't completed the stage '"+level.section+"' for the "+level.thing+" for telescope part "+i, "purple");
					}
				} else {
					print("BCC: You have at least one "+level.thing+" for telescope part "+i, "purple");
				}
			}
		}
	}
			
	return true;
}

boolean bcascTrapper() {
	if (is_equal_to(get_property("questL08Trapper"), "finished")) {bprint("Trapper"); return true;}

	string trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	item ore = to_item(get_property("trapperOre"));
	if(ore!=$item[none])
	{
		//SIMON TRY TO PULL ORE
		if(i_a(get_property("trapperOre"))<3 && !in_hardcore())
		{
			print("trying to pull ore","lime");
			cli_execute("pull "+(3-i_a(get_property("trapperOre")))+" "+ore);
		}
			
		while (i_a(get_property("trapperOre")) < 3 && !checkStage("mining")) {
			while ((my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") && ((i_a("miner's helmet") == 0 || i_a("7-Foot Dwarven mattock") == 0 || i_a("miner's pants") == 0))) {
				set_property("choiceAdventure556", 1);
				bumAdv($location[Itznotyerzitz Mine], "", "items", "1 miner's helmet, 1 7-Foot Dwarven mattock, 1 miner's pants", "Getting the Mining Outfit", "i");
				set_property("choiceAdventure556", 2);
				trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
			}
			if (my_path() != "Way of the Surprising Fist" && my_path() != "Avatar of Boris") cli_execute("outfit mining gear");
			if (!bcascMining()) {
				print("BCC: The script has stopped mining for ore, probably because you ran out of unaccomapnied miner adventures. We'll try again tomorrow.", "purple");
				return false;
			}
		}
	}

	//Set the mining part to complete if we have three ore at this point to avoid hunting potential softcore problems
	if (i_a(get_property("trapperOre")) == 3 && !checkStage("mining"))
		checkStage("mining", true);

	while (contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "that cheese") && !is_past(get_property("questL08Trapper"),"step1") && i_a("goat cheese")<3) {
		if (can_interact()) {
			cli_execute("acquire 3 goat cheese");
		} else {
			cli_execute("friars food");
			string old = get_property("choiceAdventure162");
			if(my_path()=="Avatar of Boris")
				set_property("choiceAdventure162", 3); //Boris hates rocks
			bumAdv($location[The Goatlet], "", "items", "3 goat cheese", "Getting Goat Cheese", "i");
			set_property("choiceAdventure162", old); //Reset in order to not screw anyone up in a future ascencion
		}
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
	}
	if(contains_text(visit_url("place.php?whichplace=mclargehuge&action=trappercabin"), "that cheese"))
		abort("We seem to have failed to get the cheese/ore");
//	abort("check current value of get_property(questL08Trapper)");
	//SIMON TRY TO PULL climbing gear
	if(!(my_path() == "Avatar of Sneaky Pete" && get_property("peteMotorbikeTires") == "Snow Tires"))
	{
		if(i_a("ninja rope")<1 && !in_hardcore())
			cli_execute("pull ninja rope");
		if(i_a("ninja crampons")<1 && !in_hardcore())
			cli_execute("pull ninja crampons");
		if (i_a("ninja carabiner") == 0)
			cli_execute("pull ninja carabiner");
	}
	if (((have_skill($skill[Musk of the Moose]) || have_skill($skill[Carlweather's Cantata of Confrontation]) || (my_path() == "Avatar of Sneaky Pete" && (get_property("peteMotorbikeTires") == "Snow Tires" || get_property("peteMotorbikeMuffler") == "Extra-Loud Muffler"))) && willMood() && get_res($element[cold], 5, false)) || (i_a("ninja carabiner")>0 && i_a("ninja rope")>0 && i_a("ninja crampons")>0)) {
		if (is_not_yet(get_property("questL08Trapper"),"finished")) {
			print("BCC: Getting some climbing gear.", "purple");

			setMood("+n");
			 if (have_castitems($class[sauceror], true) && have_skill($skill[Jalape&ntilde;o Saucesphere]) && my_class() == $class[sauceror]) cli_execute("trigger lose_effect, Jalape&ntilde;o Saucesphere, cast 1 Jalape&ntilde;o Saucesphere");
			buMax("initiative");
			
			if(canMCD()){
				cli_execute("mcd 0;");
			}
			while (i_a("ninja carabiner") == 0 && !(my_path() == "Avatar of Sneaky Pete" && get_property("peteMotorbikeTires") == "Snow Tires")) {
	
				//place florist friar plants
				choose_all_plants("", $location[Lair of the Ninja Snowmen]);
				
				//SIMON, needs to be plus combat
				bumminiAdv(1, $location[Lair of the Ninja Snowmen]);
			}
		}
		
		if (is_not_yet(get_property("questL08Trapper"),"finished")) {
			betweenBattle();
			cli_execute("mood clear");
			print("BCC: Climbing up to the The Icy Peak and searching for Groar.", "purple");
			//SIMON ADDED NEXT FEW LINES OF COLD RES STUFF
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[oilsphere])<4 && have_skill($skill[oilsphere]))
				use_skill($skill[oilsphere]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[elemental saucesphere])<4 && have_skill($skill[elemental saucesphere]))
				use_skill(1,$skill[elemental saucesphere]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[scarysauce])<4 && have_skill($skill[scarysauce]))
				use_skill(1,$skill[scarysauce]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[astral shell])<1 && have_skill($skill[astral shell]))
				use_skill(1,$skill[astral shell]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[Well-Oiled])<4 && available_amount($item[Oil of Parrrlay])>0)
				use(1,$item[Oil of Parrrlay]);
//			if(elemental_resistance($element[cold]) <48 && have_effect($effect[Red Door Syndrome])<4 && my_meat()>1000)
//				use(1,$item[can of black paint]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[Insulated Trousers])<4 && available_amount($item[cold powder])>0)
				use(1,$item[cold powder]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[fever from the flavor])<4 && available_amount($item[bottle of antifreeze])>0)
				use(1,$item[bottle of antifreeze]);
			if (elemental_resistance($element[cold]) <48 && have_effect($effect[Protection from Bad Stuff]) == 0 && available_amount($item[scroll of Protection from Bad Stuff])>0) use(1, $item[scroll of Protection from Bad Stuff]);

			//try to use gap buff
			if(available_amount($item[greatest american pants])>0)
			{
				//10 turns should be enough
				equip($item[greatest american pants]);
				visit_url("inventory.php?action=activatesuperpants");
				visit_url("choice.php?pwd&whichchoice=508&option=2&choiceform2=Super+Structure");
				
				cli_execute("refresh effects");
			}
			if(elemental_resistance($element[cold]) <48)
				buMax("+1000 cold res");
			if(elemental_resistance($element[cold]) <48)
				abort("couldn't get enough cold resistance for The Icy Peak");
			
			trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
			//Adventure once at the The Icy Peak to move the quest forwar
			trapper = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			cli_execute("condition clear");
			while(i_a("Groar's fur")<1)
			{
				print("Finding and fighting Groar!","green");
				if(my_path()=="Heavy Rains")
					abort("Fight groar yourself (he reflects spells)");
				bumMiniAdv(1,$location[Mist-Shrouded Peak]);
			}
		}
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		if(i_a("fuzzy busby") + i_a("fuzzy earmuffs") + i_a("fuzzy montera") > 0)
			set_property("questL08Trapper","finished");
		if (!is_equal_to(get_property("questL08Trapper"),"finished"))
			abort("didn't finish trapper");
	} else {
		if(!contains_text(visit_url("place.php?whichplace=mclargehuge"),"cloudypeak2")){
	//	if (is_not_yet(get_property("questL08Trapper"),"finished")) {
			print("BCC: Getting snowboarding outfit.", "purple");
			set_property("choiceAdventure575", 2); //hotdog
			while(!have_outfit("eXtreme Cold-Weather Gear"))
			{
				setMood("i");
				setFamiliar("items");
				buMax("items");
			
				bumadv($location[The eXtreme Slope], "", "items", "eXtreme scarf, snowboarder pants, eXtreme mittens", "Getting the eXtreme outfit", "i");
			}
			set_property("choiceAdventure575", 2); //hotdog
			
			print("BCC: Doing snowboarding tricks.", "purple");
			buMax("+outfit eXtreme Cold-Weather Gear");
			//if (is_not_yet(get_property("questL08Trapper"), "step3")) {
//			while(!contains_text(visit_url("charpane.php"),"extmeter3")){
			while (is_not_yet(get_property("questL08Trapper"), "step3") && !(my_path() == "Avatar of Sneaky Pete" && get_property("peteMotorbikeTires") == "Snow Tires")) {
				bumMiniAdv(1, $location[The eXtreme Slope]);
	
				//place florist friar plants
				choose_all_plants("", $location[The eXtreme Slope]);
				
			}
			print("BCC: Unlocking peak with snowboard.", "purple");
			trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
			//Adventure once at the The Icy Peak to move the quest forward
			trapper = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
		}
//		abort("check current value of get_property(questL08Trapper)");
		if (is_not_yet(get_property("questL08Trapper"),"finished") && contains_text(visit_url("place.php?whichplace=mclargehuge"),"cloudypeak2")) {
			print("BCC: Dressing warm and Trekking up peak for Groar.", "purple");
			
			//SIMON ADDED NEXT FEW LINES OF COLD RES STUFF
			buMax();
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[oilsphere])<4 && have_skill($skill[oilsphere]))
				use_skill($skill[oilsphere]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[elemental saucesphere])<4 && have_skill($skill[elemental saucesphere]))
				use_skill(1,$skill[elemental saucesphere]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[scarysauce])<4 && have_skill($skill[scarysauce]))
				use_skill(1,$skill[scarysauce]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[astral shell])<1 && have_skill($skill[astral shell]))
				use_skill(1,$skill[astral shell]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[Well-Oiled])<4 && available_amount($item[Oil of Parrrlay])>0)
				use(1,$item[Oil of Parrrlay]);
//			if(elemental_resistance($element[cold]) <48 && have_effect($effect[Red Door Syndrome])<4 && my_meat()>1000)
//				use(1,$item[can of black paint]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[Insulated Trousers])<4 && available_amount($item[cold powder])>0)
				use(1,$item[cold powder]);
			if(elemental_resistance($element[cold]) <48 && have_effect($effect[fever from the flavor])<4 && available_amount($item[bottle of antifreeze])>0)
				use(1,$item[bottle of antifreeze]);
			if (elemental_resistance($element[cold]) <48 && have_effect($effect[Protection from Bad Stuff]) == 0 && available_amount($item[scroll of Protection from Bad Stuff])>0) use(1, $item[scroll of Protection from Bad Stuff]);
			//try to use gap buff
			if(available_amount($item[greatest american pants])>0)
			{
				//10 turns should be enough
				equip($item[greatest american pants]);
				visit_url("inventory.php?action=activatesuperpants");
				visit_url("choice.php?pwd&whichchoice=508&option=2&choiceform2=Super+Structure");
				
				cli_execute("refresh effects");
			}
			if(elemental_resistance($element[cold]) <48)
				buMax("+1000 cold res");
			if(elemental_resistance($element[cold]) <48)
				abort("couldn't get enough cold resistance for The Icy Peak");
				
			trapper = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak");
			while(i_a("Groar's fur")<1)
			{
				if (my_path() == "Avatar of Sneaky Pete" && get_property("peteMotorbikeTires") == "Snow Tires") {
					trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
					trapper = visit_url("place.php?whichplace=mclargehuge&action=cloudypeak2");
					adventure(1, $location[Mist-Shrouded Peak]);
				} else
				{
					bumAdv($location[Mist-Shrouded Peak], "+outfit eXtreme Cold-Weather Gear", "", "Groar's fur", "Finding and fighting Groar!");
				}
			}
		}
		trapper = visit_url("place.php?whichplace=mclargehuge&action=trappercabin");
		if(i_a("fuzzy busby") + i_a("fuzzy earmuffs") + i_a("fuzzy montera") > 0)
			set_property("questL08Trapper","finished");
		if (!is_equal_to(get_property("questL08Trapper"),"finished"))
			abort("didn't finish trapper");
	}

	if (is_equal_to(get_property("questL08Trapper"), "finished")) {
		checkStage("trapper",true);
		bprint("Trapper");
		return true;
	}
	return false;
}

boolean bcascToot() {
    if (checkStage("toot")) { return true;}
    visit_url("tutorial.php?action=toot");
    if (item_amount($item[letter from King Ralph XI]) > 0) use(1, $item[letter from King Ralph XI]);
	
	if (get_property("bcasc_sellgems") == "true") {
		if (item_amount($item[pork elf goodies sack]) > 0 && my_path() != "Way of the Surprising Fist") use(1, $item[pork elf goodies sack]);
		if (my_path() != "Way of the Surprising Fist") foreach stone in $items[hamethyst, baconstone, porquoise] autosell(item_amount(stone), stone);
	}
	if (my_class() == $class[Accordion Thief] && i_a("stolen accordion") == 0 && i_a("Rock and Roll Legend") == 0 && i_a("Squeezebox of the Ages") == 0 && i_a("The Trickster's Trikitixa") == 0) {
		print("BCC: Getting an Accordion before we start.", "purple");
		while (i_a("stolen accordion") == 0) use(1, $item[chewing gum on a string]);
	}
	
	//KoLMafia doesn't clear these on ascension.
	set_property("mineLayout1", "");
	set_property("trapperOre", "");
	set_property("bcasc_lastFax", "");
	set_property("bcasc_lastHermitCloverGet", "");
	set_property("bcasc_lastShieldCheck", "");
	set_property("lastChasmReset", my_ascensions());
	set_property("chasmBridgeProgress", 0);

    checkStage("toot", true);
	return true;
}


void bcascKOLHS()
{
	if(get_property("_kolhsAdventures").to_int()<40)
	{
		set_property("choiceAdventure772",0); //in case we accidentally go too far
		//what is our inttrinsic? also se choiceadv
		effect intrinsic=$effect[nerd is the word]; //myst
		effect wrong_intrinsic1=$effect[greaser lightnin'];
		effect wrong_intrinsic2=$effect[jamming with the jocks];
		location zone=$location[chemistry class];
		
		if(my_primestat()==$stat[muscle])
		{
			intrinsic=$effect[jamming with the jocks];
			wrong_intrinsic1=$effect[greaser lightnin'];
			wrong_intrinsic2=$effect[nerd is the word];
			zone=$location[shop class];
		}
		else if(my_primestat()==$stat[moxie])
		{
			intrinsic=$effect[greaser lightnin'];
			wrong_intrinsic1=$effect[nerd is the word];
			wrong_intrinsic2=$effect[jamming with the jocks];
			zone=$location[art class];
		}
		
		buMax("");
		cli_execute("unequip hat");
		setMood("");
		use_familiar($familiar[steam-powered cheerleader]); //no weight restriction, unlike other fams

		//burn 40 turns
		while(get_property("_kolhsAdventures").to_int()<40)
		{
			//set choiceadv for intrinsic
			if(have_effect($effect[jamming with the jocks])!=0)
			{
				set_property("choiceAdventure700","1");
			}
			else if(have_effect($effect[greaser lightnin'])!=0)
			{
				set_property("choiceAdventure700","3");
			}
			else if(have_effect($effect[nerd is the word])!=0)
			{
				set_property("choiceAdventure700","2");
			}
			
			//if we have enough approval but no intrinsic, get it
			if(get_property("_kolhsAdventures").to_int() < 20 && have_effect(intrinsic)==0 && have_effect(wrong_intrinsic1)==0 && have_effect(wrong_intrinsic2)==0)
			{
				print("Getting intrisic: "+intrinsic,"blue");
				setMood("i");
//TEMP TO GET 
clear_combat_macro();
//NERD INTRINSIC visit_url("account.php?actions[]=autoattack&autoattack=99125693&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
//JOCK
visit_url("account.php?actions[]=autoattack&autoattack=99126147&flag_aabosses=1&flag_wowbar=1&flag_compactmanuel=1&pwd&action=Update");
string skill_str =visit_url("account.php?tab=combat");
matcher skill_mtch = create_matcher("option selected=\"selected\" value=\"(\\d*)\">([\\w \(\)]*)",skill_str);
if(skill_mtch.find())
{
	print("combat macro set to \""+skill_mtch.group(2)+"\"","lime");
}
else
	abort("Matcher couldn't work out what combat macro was chosen");
//abort("get intrinsic for trophy");
				
				bumMiniAdv(1,$location[The Hallowed Halls]);
			}
			else
			{
//if($location[shop class] != get_property("semirareLocation").to_location())
//abort("Eat spaghetti breakfast, then optimal dog, and fight shop teacher in shop class (last loc = "+get_property("semirareLocation")+")");
				set_combat_macro();
				setMood("i");
				if(have_effect(intrinsic)==0)
					print("Got wrong (or no) intrinsic :(","red");
				print("burning school "+get_property("_kolhsAdventures")+"/40","blue");
				bumMiniAdv(1,zone);
			}
		}
	}
}

boolean bcascWand(boolean force) {
	if (checkStage("wand")) return true;
	if (!force && !in_hardcore() || my_path() == "Bugbear Invasion") return false;
	
	print("Getting a wand","purple");
	
	//Before we do the next thing, let's just check for and use the dead mimic.
	if (i_a("dead mimic") > 0) {
		cli_execute("use dead mimic");
		if (my_path() != "Bees Hate You") cli_execute("use * small box; use * large box");
	}
	
	
	//Check for a wand. Any wand will do. 
	if (i_a("aluminum wand") + i_a("ebony wand") + i_a("hexagonal wand") + i_a("marble wand") + i_a("pine wand") == 0) {
		//Use the plus sign if we have it. Just in case someone's found the oracle but forgotten to use the plus sign.
		if (i_a("plus sign") > 0) { if (cli_execute("use plus sign")) {} }

		//Need at least 1000 meat for the oracle adventure.  Let's be safe and say 2000.
		if (my_meat() < 2000) {
			print("BCC: Waiting on the oracle until you have more meat.", "purple");
			return false;
		}
		
		//Check for the DoD image. 
		while (index_of(visit_url("da.php"), "greater.gif") > 0) {
			//Then we need to check for the plus sign. 
			if (i_a("plus sign") == 0) {
				set_property("choiceAdventure451","3");
				bumAdv($location[The Enormous Greater-Than Sign], "", "itemsnc", "1 plus sign", "Getting the Plus Sign", "-");
			}
			while (have_effect($effect[Teleportitis]) == 0) {
				set_property("choiceAdventure451","5");
				bumAdv($location[The Enormous Greater-Than Sign], "", "itemsnc", "1 choiceadv", "Getting Teleportitis", "-");
			}
			set_property("choiceAdventure451","3");

			//place florist friar plants
			choose_all_plants("", $location[The Enormous Greater-Than Sign]);
			
			bumMiniAdv(1, $location[The Enormous Greater-Than Sign]);
			if (i_a("plus sign") > 0) { if (cli_execute("use plus sign")) {} }
		}
		
		if (have_effect($effect[Teleportitis]) > 0) bcascTeleportitisBurn();

		//Then we have to get the wand itself. Must have at least 5000 meat for this, so use 6000 for safety. 
		if ((!get_property("bcasc_3KeysNoWand").to_boolean() || force) && my_meat() > 6000) {
			set_property("choiceAdventure25","2");
			while(i_a("dead mimic")<1)
				bumAdv($location[The Dungeons of Doom], "", "itemsnc", "1 dead mimic", "Getting a Dead Mimic", "-");
		} else {
			return false;
		}
	}
	if (i_a("dead mimic") > 0) cli_execute("use dead mimic");
	if (numOfWand() > 0) {
		checkStage("wand", true);
		return true;
	}
	return false;
}
boolean bcascWand() {return bcascWand(false);}

void fix_clockwork_maid()
{
	if(!knoll_available())
		return;
	
	if (is_not_yet(get_property("questM01Untinker"), "finished"))
		cli_execute("untinker");
	
	if(i_a("ninja pirate zombie robot head")>0)
		cli_execute("untinker ninja pirate zombie robot head");
	if(i_a("pirate zombie robot head")>0)
		cli_execute("untinker pirate zombie robot head");
	if(i_a("pirate zombie head")>0)
		cli_execute("untinker pirate zombie head");
	if(i_a("clockwork pirate skull")>0)
		cli_execute("untinker clockwork pirate skull");
	if(i_a("enchanted eyepatch")>0)
		cli_execute("untinker enchanted eyepatch");
	if(my_path()!="Way of the Surprising Fist" && i_a("clockwork sphere")>0) //can't afford other meat maid pieces in wotsf
	{
		cli_execute("make clockwork maid");
		cli_execute("use clockwork maid");
	}
}
/********************************************************
* START THE FUNCTIONS CALLING THE ADVENTURING FUNCTIONS *
********************************************************/

void bcs1() {
if(my_level()>=4 && my_level()<=5 && my_basestat($stat[mysticality])>=20)
	abort("Go to cola battlefield with Lord Spookyraven's ear trumpet");
	if(my_path()=="KOLHS")
		bcascKOLHS();
	get_dungeon_kit();
	//dna intrinsic
	collect_dna("i");
	if(my_level()>2)
		bcascTavern();
	//SImON ADDED: check for friars before others
	if(my_level()>5)
	{
		bcascFriars();
		bcascFriarsSteel();
	}
	if(my_level()>1)
		bcascSpookyForest();
    bcascToot();
	bcascGuild();
	bcCouncil();
	bcascKnob();
	bcascPantry();
	cli_execute("guild"); //if we are lucky we may just have to hand in now
	levelMe(5, true);
}

void bcs2() {
	bcCouncil();
	fix_clockwork_maid();
	bcascSpookyForest();
	if(my_level()>5)
	{
		bcascFriars();
		bcascFriarsSteel();
	}
	levelMe(8, true);
}

void bcs3() {
	bcCouncil();
	
	//If we're an AT, we should make our Epic Weapon now. It'll be the best weapon for a long time. 
	bcascEpicWeapons();
	bcascTavern();
	if(my_level()>5)
	{
		bcascFriars();
		bcascFriarsSteel();
	}
	if(bcasc_getLEW) bcascFunHouse();
	
	levelMe(13, true);
}

void bcs4() {
	bcCouncil();	
	bcascBats1();	//questL04Bats
	bcascMeatcar();
	bcascBats2();	//questL04Bats
	//SIMON ADDED
	if(my_path()=="Zombie Slayer")
		bcascDailyDungeon();
	bcasc8Bit();
	levelMe(20, true);
}

void bcs5() {
	bcCouncil();
	//SImON ADDED: check for friars before others
	if(my_level()>5)
	{
		bcascFriars();
		bcascFriarsSteel();
	}
	
	bcascKnobKing();	//questL05Knob
	bcascDinghyHippy();	//lastIslandUnlock?
	bcCrumHorn();
	if (my_inebriety() < 15) bcascManorBilliards();//lastLibraryUnlock?
	
	levelMe(29, true);
}

void bcs6() {
	bcCouncil();
	
	bcascFriars();		//questL06Friars
	//Setting a second call to this as we want the equipment before the steel definitely. 
	bcascKnobKing();	//questL05Knob
	bcascKnobPassword();//dispensary_available()
	bcascFriarsSteel();
	
	//Get the Swashbuckling Kit. The extra moxie boost will be incredibly helpful for the Cyrpt
	if(i_a("skeletal skiff")>0 || i_a("dingy dinghy")>0)
	{
		boolean have_book=true;
		if(!in_hardcore() && i_a("big book of pirate insults")<1)
		{
			cli_execute("pull big book of pirate insults");
			have_book=i_a("big book of pirate insults")>0;
		}
		//skip this if we are not in hardcore but didn't manage to get the book
		if(my_path() != "Bugbear Invasion" && have_book) {
			while ((i_a("eyepatch") == 0 || i_a("swashbuckling pants") == 0 || i_a("stuffed shoulder parrot") == 0) && i_a("pirate fledges") == 0) {
				bumAdv($location[The Obligatory Pirate's Cove], "", "equipmentnc", "1 eyepatch, 1 swashbuckling pants, 1 stuffed shoulder parrot", "Getting the Swashbuckling Kit", "-i");
			}
		} else if(have_book){
			while ((i_a("eyepatch") == 0 || i_a("swashbuckling pants") == 0 || i_a("stuffed shoulder parrot") == 0 || i_a("flaregun") == 0) && i_a("pirate fledges") == 0) {
				bumAdv($location[The Obligatory Pirate's Cove], "", "equipmentnc", "1 eyepatch, 1 swashbuckling pants, 1 stuffed shoulder parrot, 1 flaregun", "Getting the Swashbuckling Kit (and a flaregun)", "-i");
			}
		}
		else
			print("Not farming pirate gear right now since we don't have a book but should be able to pull one tomorrow.","lime");
	}
	
	if (checkstage("ManorBilliards")) bcascManorLibrary();
	levelMe(40, true);
}

void bcs7() {
	bcCouncil();
	
	//SIMON MOVED
	bcascFriarsSteel();
	bcascCyrpt();
	bcascInnaboxen();
	if(bcasc_bedroom) {
		bcascManorBilliards();
		bcascManorLibrary();
		bcascManorBathroom();
		bcascManorBedroom();
		bcascManorGallery();
		bcascManorBallroom();
	}
	else
	{
		abort("Simon wants to set_property(\"bcasc_bedroom\",\"true\"");
	}
	
	levelMe(53, true);
}

void bcs8() {
	bcCouncil();
	bcascPirateFledges();
	bcascSetSong();
	bcascTrapper();
	bcascWand();
	bcascMirror();
	
	levelMe(68, true);
}

void bcs9() {
	bcCouncil();
	bcascDailyDungeon();
	
	bcascChasm();
	
	levelMe(85, true);
}

void bcs10() {
	bcCouncil();
	
	bcascAirship();
	bcascCastle();
	
	levelMe(104, true);
}

void bcs11() {
	bcCouncil();
	
	bcascMacguffinPrelim();
	if(!bcasc_bedroom) {
		bcascManorBilliards();
		bcascManorLibrary();
		bcascManorBathroom();
		bcascManorBedroom();
		bcascManorGallery();
		bcascManorBallroom();
	}
	bcascMacguffinPalindome();
	bcascMacguffinSpooky();
	bcascMacguffinPyramid();
	bcascMacguffinHiddenCity();
	//Lets get to level 12 and use flyers on these 2
//	bcascHoleInTheSky();
//	bcascMacguffinFinal();
	
	levelMe(125, true);
}

void bcs12() {
	boolean doSideQuest(string name) {
		if (checkStage("warstage_"+name)) return true;
		print("BCC: Starting SideQuest '"+name+"'", "purple");
		
		//We have to have these functions outside the switch. 
		int estimated_advs() { return ceil((100000 - to_float(get_property("currentNunneryMeat"))) / (1000 + (10*meat_drop_modifier()))); }
		
		int numMolyItems() { return item_amount($item[molybdenum hammer]) + item_amount($item[molybdenum crescent wrench]) + item_amount($item[molybdenum pliers]) + item_amount($item[molybdenum screwdriver]); }
		
		string visit_yossarian(boolean use_uniform) {
			print("BCC: Visiting Yossarian...", "purple");
			if(use_uniform)
				if (cli_execute("outfit "+bcasc_warOutfit)) {}
			return visit_url("bigisland.php?action=junkman&pwd=");
		}
		
		switch (name) {
			case "arena" :
				//SIMON ADDED
				if (my_path() == "Bees hate you") return true;
				if (get_property("sidequestArenaCompleted") != "none") return checkStage("warstage_"+name, true);
				print("BCC: doSideQuest(Arena)", "purple");
				
				//First, either get the flyers or turn in the 10000ML if needed, then check if it's complete. 
				if (get_property("flyeredML").to_int() > 9999 || item_amount($item[jam band flyers]) + item_amount($item[rock band flyers]) == 0)
				{
					cli_execute("outfit "+bcasc_warOutfit);
					visit_url("bigisland.php?place=concert&pwd=");
				}
				if (get_property("sidequestArenaCompleted") != "none") return true;
				if (item_amount($item[jam band flyers]) + item_amount($item[rock band flyers]) == 0) abort("There was a problem acquiring the flyers for the Arena quest.");
				
				//do left over quests
				bcascMacguffinFinal();
				bcascHoleInTheSky();
				
				//do some sidequests
				if (get_property("flyeredML").to_int() < 9999)
					if (bcasc_doSideQuestOrchard) doSideQuest("orchard");
//				if (get_property("flyeredML").to_int() < 9999)
//				if (bcasc_doSideQuestNuns && my_path()!="Way of the Surprised Fist") doSideQuest("nuns");
					
				//check if we are done before flyering junkyard
				if (get_property("flyeredML").to_int() < 9999)
					if (bcasc_doSideQuestBeach) doSideQuest("beach");
				
				//check if we are done before flyering junkyard
				if (get_property("flyeredML").to_int() < 9999)
					if (bcasc_doSideQuestJunkyard) doSideQuest("junkyard");
				print("flyering","green");
					
				//finally resort to gmob or flyering pointless mobs in hits
				if (get_property("flyeredML").to_int() < 4999)
				{
					print("BCC: Finding the GMoB to flyer him...", "purple");
					set_property("choiceAdventure105","3");     // say "guy made of bees"
					switch (my_primestat()) {
						case $stat[Muscle] :		set_property("choiceAdventure402", "1");	break;
						case $stat[Mysticality] :	set_property("choiceAdventure402", "2");	break;
						case $stat[Moxie] :			set_property("choiceAdventure402", "3");	break;
					}
					set_property("choiceAdventure882", 1); //get towel
					while (to_int(get_property("guyMadeOfBeesCount")) < 5 && get_property("flyeredML").to_int() < 10000) {
						bumAdv($location[The Haunted Bathroom], "", "", "1 choiceadv", "You need to say 'Guy made of bees' "+(5-to_int(get_property("guyMadeOfBeesCount")))+" more times.", "-", "consultGMOB");
					}
				}
				else
					while(get_property("flyeredML").to_int() < 9999)
					{
						if(my_path()!="Bugbear Invasion")
						{
							//place florist friar plants
							choose_all_plants("l", $location[The Hole in the Sky]);
							eat_hot_dog("chilly dog",$location[The Hole in the Sky]);
							print("flyering hits","blue");
							bumMiniAdv(1,$location[The Hole in the Sky]);
						}
						else
						{
							//place florist friar plants
							choose_all_plants("l", $location[The Middle Chamber]);
							eat_hot_dog("chilly dog",$location[The Middle Chamber]);
							print("flyering middle chamber","blue");
							bumMiniAdv(1,$location[the middle chamber]);
						}
					}
				
				//hand in
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=concert&pwd=");
				visit_url("bigisland.php?place=concert&pwd=");
				return checkStage("warstage_"+name, true);
				
			case "beach" :
				if (get_property("sidequestLighthouseCompleted") != "none") return true;
				print("BCC: doSideQuest(Beach)", "purple");
				bumUse(4, $item[reodorant]);
				while (i_a("barrel of gunpowder") < 5) {
					print("Getting gunpowder","lime");
					//SIMON ADDED 2 LINES BELOW
//					while(i_a("barrel of gunpowder") < 5 && available_amount($item[Rain-Doh box full of monster])>0 && my_adventures()>0)
//						use(1,$item[Rain-Doh box full of monster]);
					if (i_a("Rain-Doh black box") + i_a("spooky putty mitre") + i_a("spooky putty leotard") + i_a("spooky putty ball") + i_a("spooky putty sheet") + i_a("spooky putty snake") > 0) {
						//SIMON MODIFIED LINES BELOW
//						abort("BCC: You have some putty method, but the script doesn't support puttying at the beach, so we aborted to save you a bunch of turns. Do the beach manually.");
					}
					if(have_effect($effect[silent running])<1)
						cli_execute("uneffect silent running");
					eat_hot_dog("Junkyard dog",$location[Sonofa Beach]);
					bumAdv($location[Sonofa Beach], "", "", "5 barrel of gunpowder", "Getting the Barrels of Gunpowder", "+");
//					//SIMON CHANGED
//					if(i_a("barrel of gunpowder") < 5)
//					{
//						setMood("+");
	
						//place florist friar plants
//						choose_all_plants("", $location[Sonofa Beach]);
						
//						v(1, $location[Sonofa Beach]);
//					}
				}
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
				visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
				if (get_property("sidequestLighthouseCompleted") != "none")
					return checkStage("warstage_"+name, true);
				else
					return false;
			case "dooks" :
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				if (get_property("sidequestFarmCompleted") != "none") return true;
				print("BCC: doSideQuest(Dooks)", "purple");
				cli_execute("outfit "+bcasc_warOutfit);
				set_property("choiceAdventure147","3");
				set_property("choiceAdventure148","1");
				set_property("choiceAdventure149","2");
				
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				
				//Use a chaos butterfly against a generic duck
				buMax(""); //get rid of the war outfit before we go further
				setFamiliar("");
				while (!contains_text(visit_url("bigisland.php?place=farm"), "snarfblat=143")) {
					if (i_a("chaos butterfly") > 0 && my_path() != "Bees hate You") {
						string url;
						boolean used_butterfly = get_property("SIMON_last_butterfly")==my_ascensions();
						if(!used_butterfly)
						{
							//try to pull one
							if(i_a("chaos butterfly")==0 && !in_hardcore())
								cli_execute("pull chaos butterfly");
							//farm one
							while(i_a("chaos butterfly")==0)
								bumAdv($location[The Castle in the Clouds in the Sky (Ground floor)], "items", "itemsnc", "chaos butterfly", "getting chaos butterfly for dooks trick", "-i");
							
							//now we have one... use it
							clear_combat_macro();
							url = visit_url("adventure.php?snarfblat=137");
							if (contains_text(url, "Combat")) {
								throw_item($item[chaos butterfly]);
								set_property("SIMON_last_butterfly",my_ascensions());
								bumRunCombat();
							} else 
								abort("Failed to enter combat at the barn for some reason");
							set_combat_macro();
							
						}
						//now clear barn
						while(contains_text(visit_url("bigisland.php?place=farm"), "farm5d.gif"))
						{

							//place florist friar plants
							choose_all_plants("", $location[McMillicancuddy's Barn]);
							
							bumAdv($location[McMillicancuddy's Barn]);
						}
					} else {
						while(contains_text(visit_url("bigisland.php?place=farm"), "farm5d.gif"))
						{
	
							//place florist friar plants
							choose_all_plants("", $location[McMillicancuddy's Barn]);
							
							bumAdv($location[McMillicancuddy's Barn]);
						}
					}
				}
				while(contains_text(visit_url("bigisland.php?place=farm"), "farm1d.gif"))
				{
		
					//place florist friar plants
					choose_all_plants("", $location[McMillicancuddy's Pond]);
					
					bumAdv($location[McMillicancuddy's Pond]);
				}
				while(contains_text(visit_url("bigisland.php?place=farm"), "farm2d.gif"))
				{
		
					//place florist friar plants
					choose_all_plants("", $location[mcmillicancuddy's back 40]);
					
					bumAdv($location[mcmillicancuddy's back 40]);
				}
				while(contains_text(visit_url("bigisland.php?place=farm"), "farm3d.gif"))
				{
		
					//place florist friar plants
					choose_all_plants("", $location[mcmillicancuddy's other back 40]);
					
					bumAdv($location[mcmillicancuddy's other back 40]);
				}
				
				cli_execute("outfit "+bcasc_warOutfit);
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				visit_url("bigisland.php?place=farm&action=farmer&pwd=");
				
				if (get_property("sidequestFarmCompleted") != "none")
					return checkStage("warstage_"+name, true);
				else
					return false;
			case "junkyard" :
				//SIMON ADDED
				if (my_path() == "Bees hate you") return true;
				if (get_property("sidequestJunkyardCompleted") != "none") return true;
				print("BCC: doSideQuest(Junkyard)", "purple");
				//SIMON: turn off macro
//				visit_url("account.php?actions[]=autoattack&autoattack=0&flag_wowbar=1&pwd&action=Update");
				//start quest if needed
				if(get_property("currentJunkyardTool") == "")
					visit_yossarian(true);
				visit_yossarian(false);
				while (get_property("currentJunkyardTool") != "" && available_amount(to_item(get_property("currentJunkyardTool")))<1) {
					cli_execute("maximize "+my_primestat()+", +DA, +10DR, "
							+(my_primestat() == $stat[moxie] ? " -melee " : "+melee ")
							+(available_amount($item[greatest american pants])==0 ? "" : " +equip greatest american pants "));
						//Force to 0 in Junkyard
					setFamiliar("");
					if(have_familiar($familiar[frumious bandersnatch]))
					{
						use_familiar($familiar[frumious bandersnatch]); //don't use galloping grill or it will kill them
						if(have_skill($skill[the ode to booze]) && have_effect($effect[ode to booze])==0)
							use_skill(1,$skill[the ode to booze]);
					}
					
					if (canMCD()) cli_execute("mcd 0");
					//simon: check super structure
					if(equipped_amount($item[greatest american pants])>0 && have_effect($effect[super structure])<1)
					{
						print("And lets also put on super structure","lime");
						visit_url("inventory.php?action=activatesuperpants");
						visit_url("choice.php?pwd&whichchoice=508&option=2&choiceform2=Super+Structure");
					}
					print("Getting "+get_property("currentJunkyardTool")+"...","lime");
		
					//place florist friar plants
					choose_all_plants("gre", to_location(get_property("currentJunkyardLocation")));
					
					bumMiniAdv2(1,to_location(get_property("currentJunkyardLocation")), "consultJunkyard");
					print("a","lime");
					visit_yossarian(false);
					print("b","lime");
				}
				visit_yossarian(true);
				//SIMON: turn on macro
//				visit_url("account.php?actions[]=autoattack&autoattack=9974885&flag_aabosses=1&pwd&action=Update");
				if(bcasc_doWarAs == "frat")
					abort("research War Frat Mobile Grill Unit in battlefield using hippy uniform");
				if (get_property("sidequestJunkyardCompleted") != "none")
					return checkStage("warstage_"+name, true);
				else
					return false;
			case "nuns" :
				if(my_path()=="Way of the Surprised Fist")
					abort("For some reason script is trying to run nuns in WOSF!");
				if (get_property("sidequestNunsCompleted") != "none") return true;
				print("BCC: doSideQuest(Nuns)", "purple");
				collect_dna("m");
				setFamiliar("meat");
				
				//Set up buffs and use items as necessary.
				cli_execute("trigger clear");
				//SIMON ADDED#
				if((i_a("peppermint sprout") + i_a("peppermint twist"))>1 && have_effect($effect[peppermint twisted])<1) cli_execute("use 2 peppermint twist");
				get_kolhs_buff("items");
				
				if (have_effect($effect[sinuses for miles]) == 0)
				{
					if(i_a("mick'c icyvapohotness inhaler")<1 && !in_hardcore())
						cli_execute("pull 2 mick's icyvapohotness inhaler");
					bumUse(2, $item[mick's icyvapohotness inhaler]);
				}
				if (have_effect($effect[Big Meat Big Prizes]) == 0)
				{
					if(i_a("Meat-inflating powder")<1 && !in_hardcore())
						cli_execute("pull 2 Meat-inflating powder");
					bumUse(2, $item[Meat-inflating powder]);
				}
				if(i_a("polka pop")==0)
					cli_execute("pull 2 polka pop");
				if(i_a("polka pop")!=0 && have_effect($effect[polka face])==0)
					bumUse(2,$item[polka pop]);
				if (have_effect($effect[red tongue]) == 0) bumUse(3, $item[red snowcone]);
				if (get_property("sidequestArenaCompleted") == "fratboy" && cli_execute("concert 2")) {}
				if (get_property("demonName2") != "" && cli_execute("summon 2")) {}
				if (i_a("filthy knitted dread sack") > 0 && i_a("\"DRINK ME\" potion") > 0 && cli_execute("hatter filthy knitted dread sack")) {}
				if (my_path() != "Bees Hate You") bumUse(ceil((estimated_advs()-have_effect($effect[wasabi sinuses]))/10), $item[Knob Goblin nasal spray]);
				bumUse(ceil((estimated_advs()-have_effect($effect[your cupcake senses are tingling]))/20), $item[pink-frosted astral cupcake]);
				bumUse(ceil((estimated_advs()-have_effect($effect[heart of pink]))/10), $item[pink candy heart]);
				bumUse(ceil((estimated_advs()-have_effect($effect[heart of green]))/10), $item[green candy heart]);
				bumUse(ceil((estimated_advs()-have_effect($effect[Greedy Resolve]))/20), $item[resolution: be wealthier]);
				if (have_skill($skill[The Polka of Plenty]) && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Polka of Plenty, cast 1 The Polka of Plenty");
				if (my_class()==$class[accordion thief] && my_level()>=15 && have_skill($skill[The Ballad of Richie Thingfinder]) && my_maxmp() > mp_cost($skill[The Ballad of Richie Thingfinder]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, The Ballad of Richie Thingfinder, cast 1 The Ballad of Richie Thingfinder");
				if (have_skill($skill[Empathy of the Newt]) && have_castitems($class[turtle tamer], true)) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
				if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
				if (my_class()==$class[accordion thief] && my_level()>=15 && have_skill($skill[Chorale of Companionship]) && my_maxmp() > mp_cost($skill[Chorale of Companionship]) * 2 && have_castitems($class[accordion thief], true)) cli_execute("trigger lose_effect, Chorale of Companionship, cast 1 Chorale of Companionship");
				if (dispensary_available()) cli_execute("trigger lose_effect, Wasabi Sinuses, use 1 Knob Goblin nasal spray");
				if (dispensary_available()) cli_execute("trigger lose_effect, Heavy Petting, use 1 Knob Goblin pet-buffing spray");
				
				//try to make a half purse
				if(i_a("half a purse")<1 && have_skill($skill[summon smithsness]))
				{
					if(i_a("brituminous coal")==0)
						use_skill(1,$skill[summon smithsness]);
					cli_execute("create half a purse");
				}
				if(i_a("half a purse")<1)
					cli_execute("pull half a purse");
				//Put on the outfit and adventure, printing debug information each time. 
				buMax("nuns");
				get_kolhs_buff("meat");
				cli_execute("condition clear");
				while (my_adventures() > 0 && prepSNS() != "whatever" && bumMiniAdv(1, $location[The Themthar Hills]) && get_property("currentNunneryMeat").to_int() < 100000) {
					print("BCC: Nunmeat retrieved: "+get_property("currentNunneryMeat")+" Estimated adventures remaining: "+estimated_advs(), "green");
	
					//place florist friar plants (the only meat plant is underwater, so don't ask for that specifically
					choose_all_plants("", $location[The Themthar Hills]);
					
				}
				
				if(get_property("sidequestNunsCompleted") != "none") return checkStage("warstage_"+name, true);
				visit_url("bigisland.php?place=nunnery");
				break;
			case "orchard" :
				if(item_amount($item[heart of the filthworm queen])>0)
				{
					//check if enough are dead to hand in
					if (bcasc_doWarAs != "frat" || to_int(get_property("hippiesDefeated")) >=64)
					{
						print("checking filthworm completeness","lime");
						cli_execute("outfit "+bcasc_warOutfit);
						visit_url("bigisland.php?place=orchard&action=stand");
						visit_url("bigisland.php?place=orchard&action=stand");
					}
				}
				if (get_property("sidequestOrchardCompleted") != "none") return true;
				print("BCC: doSideQuest(Orchard)", "purple");

				while (item_amount($item[heart of the filthworm queen]) == 0) {
				
					while (have_effect($effect[Filthworm Guard Stench]) == 0) {
						while (have_effect($effect[Filthworm Drone Stench]) == 0) {
							while (have_effect($effect[Filthworm Larva Stench]) == 0) {
								eat_hot_dog("Video Games Hot dog",$location[The Hatching Chamber]);
								bumAdv($location[The Hatching Chamber], "", "items", "1 filthworm hatchling scent gland", "Getting the Hatchling Gland (1/3)", "iorchard");
								if(i_a("filthworm hatchling scent gland")>0)
									use(1, $item[filthworm hatchling scent gland]);
							}
							bumAdv($location[The Feeding Chamber], "", "items", "1 filthworm drone scent gland", "Getting the Drone Gland (2/3)", "iorchard");
							if(i_a("filthworm drone scent gland")>0)
								use(1, $item[filthworm drone scent gland]);
						}
						bumAdv($location[The Royal Guard Chamber], "", "items", "1 filthworm royal guard scent gland", "Getting the Royal Guard Gland (3/3)", "iorchard");
						if(i_a("filthworm royal guard scent gland")>0)
							use(1, $item[filthworm royal guard scent gland]);
					}
					bumAdv($location[The Filthworm Queen's Chamber], "", "", "1 heart of the filthworm queen", "Fighting the Queen");
				}
				
				if(item_amount($item[heart of the filthworm queen])>0)
				{
					//check if enough are dead to hand in
					if (bcasc_doWarAs != "frat" || to_int(get_property("hippiesDefeated")) >=64)
					{
						cli_execute("outfit "+bcasc_warOutfit);
						visit_url("bigisland.php?place=orchard&action=stand&pwd=");
						visit_url("bigisland.php?place=orchard&action=stand&pwd=");
					}
				}
				if (get_property("sidequestOrchardCompleted") != "none") checkStage("warstage_"+name, true);
		}
		return false;
	}
	
	void item_turnin(item i) {
		sell(i.buyer, item_amount(i), i);
	}
	
	boolean killSide(int numDeadNeeded) {
		setFamiliar("");
		setMood("i");

		if (my_adventures() == 0)
		{
			cli_execute("shower "+my_primestat());
			abort("No adventures left :(");
		}
		cli_execute("condition clear");
		
		int numKilled;
		if (bcasc_doWarAs == "abort") {
			abort("You have told us not to automate the battlefield. Please complete it yourself or change your settings. ");
		} else if (bcasc_doWarAs == "frat") {
			numKilled = to_int(get_property("hippiesDefeated"));
			buMax("+outfit frat warrior fatigues");
		} else if (bcasc_doWarAs == "hippy") {
			numKilled = to_int(get_property("fratboysDefeated"));
			buMax("+outfit war hippy fatigues");
		} else {
			abort("There has been an error trying to defeat the enemies on the battlefield. Please report this. ");
		}
		print("BCC: Attempting to kill up to "+numDeadNeeded+" enemies in the war. You have "+numKilled+" dead already, attempting to do the war as a "+bcasc_doWarAs+".", "purple");
		
		while (numKilled < numDeadNeeded) {
			
			if (my_adventures() == 0)
			{
				cli_execute("shower "+my_primestat());
				abort("No adventures in the Battlefield.");
			}
			
			if (bcasc_doWarAs == "frat") {
	
				//place florist friar plants
				choose_all_plants("", $location[The Battlefield (Frat Uniform)]);
				
				bumMiniAdv(1, $location[The Battlefield (Frat Uniform)]);
				numKilled = to_int(get_property("hippiesDefeated"));
			} else if (bcasc_doWarAs == "hippy") {
	
				//place florist friar plants
				choose_all_plants("", $location[The Battlefield (Hippy Uniform)]);
				
				bumMiniAdv(1, $location[The Battlefield (Hippy Uniform)]);
				numKilled = to_int(get_property("fratboysDefeated"));
			} else {
				abort("You have specified a wrong type of side to do the war as. Please change that (the setting is called bcasc_doWarAs");
			}
		}
		
		return (numKilled >= numDeadNeeded);
	}

	bcCouncil();
	if (index_of(visit_url("questlog.php?which=1"), "Make War, Not... Oh, Wait") > 0) {
		//First, get the outfit as necessary. 
		if (bcasc_doWarAs == "abort") {
			abort("You have told us that you would like to complete the war yourself. Please do so or change your settings.");
		} else if (bcasc_doWarAs == "hippy") {
			while (i_a("reinforced beaded headband") == 0 || i_a("bullet-proof corduroys") == 0 || i_a("round purple sunglasses") == 0) 
				bumAdv($location[Wartime Hippy Camp], "+outfit filthy hippy disguise", "", "1 reinforced beaded headband, 1 bullet-proof corduroys, 1 round purple sunglasses", "Getting the War Hippy Outfit");
		} else if (bcasc_doWarAs == "frat") {
			while (i_a("beer helmet") == 0 || i_a("distressed denim pants") == 0 || i_a("bejeweled pledge pin") == 0) 
				bumAdv($location[Wartime Frat House], "+outfit filthy hippy disguise", "hebo", "1 beer helmet, 1 distressed denim pants, 1 bejeweled pledge pin", "Getting the Frat Warrior Outfit", "i", "consultHeBo");
		} else {
			abort("Please specify if you want the war done as a Hippy or a Fratboy.");
		}
		
		while (my_basestat($stat[mysticality]) < 70) {
			set_property("choiceAdventure105","1");
			set_property("choiceAdventure402","2");
			bumAdv($location[The Haunted Bathroom], "", "", "70 mysticality", "Getting 70 myst to equip the " + bcasc_warOutfit + " outfit", "-");
		} 
		
		//So now we have the outfit. Let's check if the war has kicked off yet. 
		while(!contains_text(visit_url("questlog.php?which=1"), "war between the hippies and frat boys started")) {
			if (bcasc_doWarAs == "abort") {
				abort("You have told us that you would like to complete the war yourself. Please do so or change your settings.");
			} else if (bcasc_doWarAs == "hippy") {
				bumAdv($location[Wartime Frat House (Hippy Disguise)], "+outfit war hippy fatigues", "", "1 choiceadv", "Starting the war by irritating the Frat Boys", "-");
			} else if (bcasc_doWarAs == "frat") {
				//I can't quite work out which choiceAdv number I need. Check it later. Plus, it should be "start the war" anyway. 
				//cli_execute("set choiceAdventure142");
				bumAdv($location[Wartime Hippy Camp (Frat Disguise)], "+outfit frat warrior fatigues", "", "1 choiceadv", "Starting the war by irritating the Hippies", "-");
			}
		}
		
		//At this point the war should be started. 
		if (bcasc_doWarAs == "abort") {
			abort("You have told us that you would like to complete the war yourself. Please do so or change your settings.");
		} else if (bcasc_doWarAs == "hippy") {
			if (i_a("reinforced beaded headband") == 0 || i_a("bullet-proof corduroys") == 0 || i_a("round purple sunglasses") == 0) {
				abort("What the heck did you do - where's your War Hippy outfit gone!?");
			}
			if (bcasc_doSideQuestOrchard) doSideQuest("orchard");
			if (bcasc_doSideQuestDooks) doSideQuest("dooks");
			if (bcasc_doSideQuestNuns && my_path()!="Way of the Surprising Fist") doSideQuest("nuns");
			killSide(64);
			if (bcasc_doSideQuestBeach || i_a("barrel of gunpowder") >= 5) doSideQuest("beach");
			killSide(192);
			if (bcasc_doSideQuestJunkyard) doSideQuest("junkyard");
			killSide(458);
			if (bcasc_doSideQuestArena) doSideQuest("arena");
			//do this with flyers if it's left
			bcascMacguffinFinal();
			bcascHoleInTheSky();
			killSide(1000);
		} else if (bcasc_doWarAs == "frat") {
			if (i_a("beer helmet") == 0 || i_a("distressed denim pants") == 0 || i_a("bejeweled pledge pin") == 0) {
				abort("What the heck did you do - where's your Frat Warrior outfit gone!?");
			}
			if (bcasc_doSideQuestArena) doSideQuest("arena");
			//do this with flyers if it's left
			bcascMacguffinFinal();
			bcascHoleInTheSky();
			if (bcasc_doSideQuestJunkyard) doSideQuest("junkyard");
			if (bcasc_doSideQuestBeach || i_a("barrel of gunpowder") >= 5) doSideQuest("beach");
			killSide(64);
			if (bcasc_doSideQuestOrchard) doSideQuest("orchard");
			killSide(192);
			if (bcasc_doSideQuestNuns && my_path()!="Way of the Surprising Fist") doSideQuest("nuns");
			killSide(458);
			if (bcasc_doSideQuestDooks) doSideQuest("dooks");
			killSide(1000);
		}
		
		if (get_property("bcasc_sellWarItems") == "true") {
			//Sell all stuff.
			if (bcasc_doWarAs == "hippy") {
				item_turnin($item[red class ring]);
				item_turnin($item[blue class ring]);
				item_turnin($item[white class ring]);
				item_turnin($item[beer helmet]);
				item_turnin($item[distressed denim pants]);
				item_turnin($item[bejeweled pledge pin]);
				item_turnin($item[PADL Phone]);
				item_turnin($item[kick-ass kicks]);
				item_turnin($item[perforated battle paddle]);
				item_turnin($item[bottle opener belt buckle]);
				item_turnin($item[keg shield]);
				item_turnin($item[giant foam finger]);
				item_turnin($item[war tongs]);
				item_turnin($item[energy drink IV]);
				item_turnin($item[Elmley shades]);
				item_turnin($item[beer bong]);
				buy($coinmaster[Dimemaster], $coinmaster[dimemaster].available_tokens/2, $item[filthy poultice]);
			} else if (bcasc_doWarAs == "frat") {
				item_turnin($item[pink clay bead]);
				item_turnin($item[purple clay bead]);
				item_turnin($item[green clay bead]);
				item_turnin($item[bullet-proof corduroys]);
				item_turnin($item[round purple sunglasses]);
				item_turnin($item[reinforced beaded headband]);
				item_turnin($item[hippy protest button]);
				item_turnin(to_item("Lockenstock"));
				item_turnin($item[didgeridooka]);
				item_turnin($item[wicker shield]);
				item_turnin($item[lead pipe]);
				item_turnin($item[fire poi]);
				item_turnin($item[communications windchimes]);
				item_turnin($item[Gaia beads]);
				item_turnin($item[hippy medical kit]);
				item_turnin($item[flowing hippy skirt]);
				item_turnin($item[round green sunglasses]);
				buy($coinmaster[Quartersmaster], $coinmaster[Quartersmaster].available_tokens/2, $item[gauze garter]);
			}
		} else {
			if (!checkStage("prewarboss")) {
				checkStage("prewarboss", true);
				abort("Stopping to let you sell war items.  Run script again to continue. Note that the script will not fight the boss as Muscle or Myst, so do that manually to if appropriate.");
			}
		}
		
		// Kill the boss.
		int bossMoxie = 230;
		buMax("+outfit "+bcasc_warOutfit);
		setMood("");
		cli_execute("mood execute");
		
		//Now deal with getting the moxie we need.
		//SIMON CHANGED THIS
		if (my_buffedstat(my_primestat()) < bossMoxie && !to_boolean(get_property("_ballpit")) && !in_bad_moon()) cli_execute("ballpit");
		if (my_buffedstat(my_primestat()) < bossMoxie && !to_boolean(get_property("telescopeLookedHigh")) && get_property("telescopeUpgrades") > 0 && !in_bad_moon()) cli_execute("telescope look high");
		if (my_buffedstat(my_primestat()) < bossMoxie && have_skill($skill[Advanced Saucecrafting])) cli_execute("cast * advanced saucecraft");
		switch (my_primestat()) {
			case $stat[Moxie] :
				if (my_buffedstat($stat[Moxie]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0 && have_skill($skill[Advanced Saucecrafting])) cli_execute("use 1 serum of sarcasm");
				if (my_buffedstat($stat[Moxie]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0 && have_skill($skill[Advanced Saucecrafting])) cli_execute("use 1 tomato juice of power");
				if (my_buffedstat($stat[Moxie]) < bossMoxie&& my_primestat() == $stat[moxie]) abort("Can't get to " + bossMoxie + " moxie for the boss fight.  You're on your own.");
				break;
			case $stat[muscle] :
				if (my_buffedstat($stat[muscle]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0 && have_skill($skill[Advanced Saucecrafting])) cli_execute("use 1 Philter of phorce");
				if (my_buffedstat($stat[muscle]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0 && have_skill($skill[Advanced Saucecrafting])) cli_execute("use 1 tomato juice of power");
				if (my_buffedstat($stat[muscle]) < bossMoxie) abort("Can't get to " + bossMoxie + " muscle for the boss fight.  You're on your own.");
				break;
			case $stat[mysticality] :
				if (my_buffedstat($stat[mysticality]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0 && have_skill($skill[Advanced Saucecrafting])) cli_execute("use 1 Ointment of the occult");
				if (my_buffedstat($stat[mysticality]) < bossMoxie && item_amount($item[scrumptious reagent]) > 0 && have_skill($skill[Advanced Saucecrafting])) cli_execute("use 1 tomato juice of power");
				if (my_buffedstat($stat[mysticality]) < bossMoxie) abort("Can't get to " + bossMoxie + " mysticality for the boss fight.  You're on your own.");
				break;
			default :
				abort("unrecognised mainstat.");
				break;
		}
		
		cli_execute("restore hp;restore mp");
		visit_url("bigisland.php?place=camp&whichcamp=1");
		visit_url("bigisland.php?place=camp&whichcamp=2");
		visit_url("bigisland.php?action=bossfight&pwd");
		if (index_of(bumRunCombat(), "WINWINWIN") == -1) abort("Failed to kill the boss!\n");
		visit_url("council.php");
		set_property("lastCouncilVisit", my_level());
	}
	
	levelMe(148, true);
}

void bcs13() {
	boolean tower_items;
	bcCouncil(true); //force a visit to hand in
	
	if (!checkStage("lair0")) {
		if (my_path() != "Bugbear Invasion")
			tower_items = bcascTelescope();
		checkStage("lair0", true);
		if(!tower_items && my_path() != "Bugbear Invasion")
			abort("BCC: You need tower items that the script won't automatically get. Go get them yourself.");
	}
	load_current_map("bumrats_lairitems", lairitems);
	if (my_path() == "Bugbear Invasion") {
		bcascBugbearHunt();
		bcascBugbearShip();
	}
	bcascNaughtySorceress();
}


void bumcheekcend() {
	ascendLog("");
	if ((get_property("bcasc_telescope") == "true") && (get_property("bcasc_telescopeAsYouGo") == "true") && (!checkStage("lair0"))) {
		print("Doing a check for Telescope Items", "green");
		bcascTelescope();
	}
	
	print("Level 1 Starting", "green");
	bcs1();
	print("Level 2 Starting", "green");
	bcs2();
	print("Level 3 Starting", "green");
	bcs3();
	print("Level 4 Starting", "green");
	bcs4();
	print("Level 5 Starting", "green");
	bcs5();
	print("Level 6 Starting", "green");
	bcs6();
	print("Level 7 Starting", "green");
	bcs7();
	print("Level 8 Starting", "green");
	bcs8();
	print("Level 9 Starting", "green");
	bcs9();
	print("Level 10 Starting", "green");
	bcs10();
	print("Level 11 Starting", "green");
	bcs11();
	print("Level 12 Starting", "green");
	bcs12();
	print("Level 13 Starting", "green");
	bcs13();
}

void mainWrapper() {
	//use gyro if poss
	if(!to_boolean(get_property("_warbearGyrocopterUsed")))
	{
		print("----------CAN USE GYROCOPTER!---------","red");
		if(i_a("warbear gyrocopter")==0)
			print("----------(BUT DON'T HAVE ONE!---------","red");
		else
		{	
			//use gryo
			visit_url("curse.php?whichitem=7038");
			if(my_name()=="dinala")
				visit_url("curse.php?action=use&pwd&whichitem=7038&targetplayer=anid&curse=0");
			else
				visit_url("curse.php?action=use&pwd&whichitem=7038&targetplayer=dinala&curse=0");
		}
		cli_execute("inventory refresh");
		if(can_interact() && i_a("warbear gyro")>0 && my_name()!="twistedmage")
			cli_execute("csend * warbear gyro to twistedmage");		
	}
		
//	if(my_level()==4 || my_level()==5)
//		abort("do cola battlefield");
	if(to_boolean(get_property("_jickJarAvailable")))
		print("----------JICK JAR AVAILABLE!---------","red");
	
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("Thankyou for using bumcheekcity's ascension script. Please report all bugs on the KoLMafia thread with a copy+paste from the CLI of the problematic points, and your username. Also ask on the thread on the kolmafia.us forum for help and assistance with the script, particularly first time problems, and issues setting it up. ", "purple");
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("******************************************************************************************", "purple");
	print("");
	print("");
	print("");
	//SIMON: call pvp script
	if(my_name()=="twistedmage")
		cli_execute("pvp.ash");
	
	alias [int] aliaslist;
	if (load_current_map("bcs_aliases", aliaslist) && get_property("bcasc_lastAliasVersion") != bcasc_version) {
		print("BCC: Registering aliases for script use. Check the forum thread - http://kolmafia.us/showthread.php?t=4963 - for more information", "purple");


		cli_execute("alias bcasc => ash import <" + __FILE__ + ">; mainWrapper();");
		foreach x in aliaslist {
			print("Setting alias '"+aliaslist[x].cliref+"' for function '"+aliaslist[x].functionname+"'.", "purple");
			cli_execute("alias bcasc_"+aliaslist[x].cliref+" => ash import <" + __FILE__ + ">; bcasc"+aliaslist[x].functionname+"();");
		}
		set_property("bcasc_lastAliasVersion", bcasc_version);
	}
	
	if (my_inebriety() > inebriety_limit()) abort("You're drunk. Don't run this script when drunk, fool.");
	
	if (get_property("autoSatisfyWithNPCs") != "true") {
		set_property("autoSatisfyWithNPCs", "true");
	}
	
	if (get_property("autoSatisfyWithCoinmasters") != "true") {
		set_property("autoSatisfyWithCoinmasters", "true");
	}
	
	if (get_property("bcasc_shutUpAboutOtherScripts") != "true") {
		if (get_property("recoveryScript") == "") {
			print("You do not have a recoveryScript set. I highly recommend Bale's 'Universal Recovery' - http://kolmafia.us/showthread.php?t=1780 - You may find this script runs into problems with meat without it.", "red");
			print("To not be reminded about supplementry scripts, please set the appropriate option in the relay script (which you can find on the kolmafia.us forum thread for this script).", "red");
			wait(1);
		}
		
		if (get_property("counterScript") == "") {
			print("You do not have a counterScript set. I highly recommend Bale's 'CounterChecker' http://kolmafia.us/showthread.php?t=2519 - This script, in combination with bumcheekascend, will allow you to get semi rares if you eat fortune cookies.", "red");
			print("To not be reminded about supplementry scripts, please set the appropriate option in the relay script (which you can find on the kolmafia.us forum thread for this script).", "red");
			wait(1);
		}
	}
	//SIMON: turn on macro
	set_combat_macro();
	
	if (!in_hardcore() && get_property("bcasc_doNotRemindAboutSoftcore") != "true") {
		print("You are in softcore. The script behaves differently for softcore and requires you to follow the small number of instructions in the following page - http://kolmafia.us/showthread.php?t=4963", "red");
		//abort("To remove this notice and be able to use the script, please set the appropriate option in the relay script (which you can find on the kolmafia.us forum thread for this script).");
	}
	
	if (have_effect($effect[Teleportitis]) > 0 && my_level() < 13) {
		if (!contains_text("da.php", "greater.gif") && my_level() >= 8)
			bcascWand();
		} else {
			bcascTeleportitisBurn();
	}

	print("******************", "green");
	print("Ascending Starting", "green");
	print("******************", "green");
	
	//Let's clear out goals at the start of the script to avoid problems.
	cli_execute("goals clear");
	
	//Before we start, we'll need an accordion. Let's get one. 
	sellJunk();
	//Do a quick check to see if the person has set the script to adventure at the daily dungeon every day.
	if (my_level() > 6 && get_property("bcasc_dailyDungeonEveryday") == "true") {
		cli_execute("adv * daily dungeon");
	}
	
	bumcheekcend();
	
	print("******************", "green");
	print("Ascending Finished", "green");
	print("******************", "green");
}

void main() {
	mainWrapper();
}