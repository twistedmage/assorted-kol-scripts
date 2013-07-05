script "TheSea.ash";
notify Theraze;
import <bumcheekascend.ash>;
import <zlib.ash>;


//predeclare
void GetSushiMat();

//Allows a wider range of macros to be chosen, or falls back on the standard putty / stat macro
void set_combat_macro_name(string macro)
{
	switch(macro)
	{
		case "lasso" :
			visit_url("account.php?actions[]=autoattack&autoattack=9999547&flag_aabosses=1&pwd&action=Update");
		break;
		case "seahorse" :
			visit_url("account.php?actions[]=autoattack&autoattack=99100629&flag_aabosses=1&pwd&action=Update");
		break;
		case "gladiator" :
			visit_url("account.php?actions[]=autoattack&autoattack=99100626&flag_aabosses=1&pwd&action=Update");
		break;
		case "library1" :
			visit_url("account.php?actions[]=autoattack&autoattack=99100627&flag_aabosses=1&pwd&action=Update");
		break;
		case "library2" :
			visit_url("account.php?actions[]=autoattack&autoattack=99100628&flag_aabosses=1&pwd&action=Update");
		break;
		case "library3" :
			visit_url("account.php?actions[]=autoattack&autoattack=99100630&flag_aabosses=1&pwd&action=Update");
		break;
		default:
			set_combat_macro();
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

//simons functions which use bumcheekascend to set up gear, familiar, mood
//inputs should be combinations of +/- and i
void prepare_for(string type,location loc)
{
	if(have_effect($effect[fishy])<1)
	{
		//if we have rescued big brother and can get a sushi mat
		//we may well want to eat a bento box sushi with a worktea, to get fishy and a clue
		if(contains_text(visit_url("monkeycastle.php"),"\#brothers\"")&& get_property("workteaClue")=="")
		{
			if(user_confirm("Do you want to eat a Bento Box."))
			{
				if(i_a("white rice")<1)
					buy(1,$item[white rice]);
				if(i_a("seaweed")<1)
					buy(1,$item[seaweed]);
				if(i_a("beefy fish meat")<1)
					buy(1,$item[beefy fish meat]);
				if(i_a("glistening fish meat")<1)
					buy(1,$item[glistening fish meat]);
				if(i_a("slick fish meat")<1)
					buy(1,$item[slick fish meat]);
				if(i_a("mer-kin lunchbox")<1)
					buy(1,$item[mer-kin lunchbox]);
				if(i_a("tempura avocado")<1)
					buy(1,$item[tempura avocado]);
				if(i_a("Mer-kin weaksauce")<1)
					buy(1,$item[Mer-kin weaksauce]);
				if(i_a("Mer-kin worktea")<1)
					buy(1,$item[Mer-kin worktea]);
				GetSushiMat();
				cli_execute("create bento box");
			}
		}
		else if(inebriety_limit() - my_inebriety() > 2 && user_confirm("Do you want to drink a Flaming Caipiranha."))
		{
			use_skill(1,$skill[ode to booze]);
			drink(1,$item[Flaming Caipiranha]);
		}
	}
	if(have_effect($effect[fishy])<1)
	{
		abort("ran out of fishy and have full bladder");
	}

	//--------------------flowers--------------------
	choose_all_plants(type, loc);
				
	//--------------------familiar------------------
	//fam types accepted: items, itemsnc, ""
	if(contains_text(type,"i"))
	{
		setFamiliar("itemsw");
	}
	else
		setFamiliar("");
	
	//---------------------gear-----------------------
	//input for maximizer
	string max_str="maximize +sea";
	
	if(loc==$location[mer-kin library])
		max_str+=", +outfit mer-kin scholar";
	if(loc==$location[mer-kin colosseum])
		max_str+=", +outfit mer-kin gladiator, -ml";
	if(loc==$location[mer-kin gymnasium])
		max_str+=", +outfit mer-kin gladiator";
	if(get_property("lassoTraining")!= "expertly")
		max_str+=", +equip sea cowboy hat, +equip sea chaps";
	//if untrained with gladiator weapons ?
		
	if(contains_text(type,"i"))
		max_str+=", items";
	if(contains_text(type,"-"))
		max_str+=", -100 combat";
	if(contains_text(type,"+"))
		max_str+=", +100 combat";

	if(loc==$location[coral corral])
		max_str+=", equip navel ring";

	print("running "+max_str);
	cli_execute(max_str);
	
	//----------------------buffs-------------------
	//types accepted: -, +, i, 
	setMood(type);
	//potions
	cli_execute("trigger lose_effect, incredibly Hulking, use 1 Ferrigno's Elixir of Power");
	cli_execute("trigger lose_effect, cock of the walk, use 1 connery's elixir of audacity");
	cli_execute("trigger lose_effect, Superhuman Sarcasm, use 1 serum of sarcasm");
	cli_execute("trigger lose_effect, Phorcefullness, use 1 philter of phorce");
	if(my_primestat()==$stat[mysticality])
		cli_execute("trigger lose_effect, on the shoulders of giants, use 1 hawking's elixir of brilliance");
		
	if(loc==$location[mer-kin colosseum])
	{
		//more potions
		if(my_primestat()==$stat[muscle])
			cli_execute("trigger lose_effect, Stabilizing Oiliness, use 1 Oil of stability");
		if(my_primestat()==$stat[mysticality])
			cli_execute("trigger lose_effect, Expert Oiliness, use 1 Oil of expertise");
		if(my_primestat()==$stat[moxie])
			cli_execute("trigger lose_effect, Slippery Oiliness, use 1 Oil of slipperines");
		
		cli_execute("trigger lose_effect, Tomato Power, use 1 Tomato juice of powerful power");
		cli_execute("trigger lose_effect, Chalky Hand, use 1 handful of hand chalk");
		cli_execute("trigger lose_effect, Gr8tness, use 1 potion of temporary gr8tness ");
	}
	
	//lasso / seahorse
	if(loc==$location[coral corral])
	{
		if(i_a("sea lasso")<1)
			buy(1,$item[sea lasso]);
		if(i_a("sea cowbell")<3)
			buy(3,$item[sea cowbell]);
		if(i_a("pulled indigo taffy")<3)
			buy(3,$item[pulled indigo taffy]);
		set_combat_macro_name("seahorse");
	}
	else if(loc==$location[Mer-kin Colosseum])
	{
		if(i_a("pulled blue taffy")<15)
			buy(15,$item[pulled blue taffy]);
		set_combat_macro_name("gladiator");
	}
	else if(get_property("lassoTraining")!= "expertly")
	{
		if(i_a("sea lasso")<1)
			buy(1,$item[sea lasso]);
		set_combat_macro_name("lasso");
	}
	else if(loc==$location[mer-kin library])
	{
		if(i_a("pulled yellow taffy")<1)
			buy(1,$item[pulled yellow taffy]);
		if(get_property("_merkin_word2")=="")
		{
			if(i_a("mer-kin healscroll")<1)
				buy(1,$item[mer-kin healscroll]);
			set_combat_macro_name("library3");
		}
		else if(get_property("_merkin_word5")=="")
		{
			if(i_a("mer-kin killscroll")<1)
				buy(1,$item[mer-kin killscroll]);
			set_combat_macro_name("library2");
		}
		else
		{
			set_combat_macro_name("library1");
		}
	}
	else
		set_combat_macro_name(false);
}

string thisver = "1.6.2";
check_version( "TheSea.ash", "TheSea", thisver, 8708 );

string currentquests = visit_url("questlog.php?which=1");
string completedquests = visit_url("questlog.php?which=2");
string otherquests = visit_url("questlog.php?which=3");
location grandpa;
if (my_primestat() == $stat[Muscle]) grandpa = $location[Anemone Mine];
else if (my_primestat() == $stat[Mysticality]) grandpa = $location[Marinara Trench];
else if (my_primestat() == $stat[Moxie]) grandpa = $location[Dive Bar];

// Set default value to not closet meat.
setvar("seafloor_closetMeat", -1);
int TS_CLOSETMEAT = to_int(vars["seafloor_closetMeat"]) >= 0 ? max(0, my_meat() - to_int(vars["seafloor_closetMeat"])) : -1;

// Sets the default outfit and maximization string. If both are set, it will use maximize.
// Note if your outfit includes a weapon, you will potentially have problems with the Skate quest.
// Also note that if you set these, you'll need to include some method of breathing underwater.
setvar("seafloor_maximizeString", "");
setvar("seafloor_outfit", "");
string TS_MAXIMIZE = vars[ "seafloor_maximizeString" ];
string TS_OUTFIT = vars[ "seafloor_outfit" ];

// Quest completion. This should get set automatically.
setvar("seafloor_monkeeAscension", my_ascensions());
setvar("seafloor_monkeeStep", 0);

// How many monkees do you want to find?
// 0 - Skip. 1 - Little Brother. 2 - Big Brother. 3 - Grandpa. 4 - Grandma, 5 - Mom.
setvar("seafloor_monkeeQuest", 3);
int TS_MONKEE_QUEST = to_int(vars["seafloor_monkeeQuest"]);

// Do you want to fax for the Neptune Flytrap, to increase the item drop rate and avoid underwater penalties?
// This will abort if set to true and you are unable to access faxbot for some reason.
setvar("seafloor_faxNeptune", true);
boolean TS_FAX_NEPTUNE = to_boolean(vars["seafloor_faxNeptune"]);

// Which version of the grandpa chat series have you done? This skips unnecessary server hits.
setvar("seafloor_grandpaChat", 0);

// Do you want it to unlock the Trophyfish encounter? This defaults to false, since you'll likely only want to do this once.
setvar("seafloor_unlockTrophyfish", false);
boolean TS_UNLOCK_TROPHYFISH = to_boolean(vars["seafloor_unlockTrophyfish"]);

// How do you want to complete the Outfit quest?
// 0 - Skip. 1 - Violence. 2 - Hatred. 3 - Loathing.
setvar("seafloor_outfitQuest", 0);
int TS_OUTFIT_QUEST = to_int(vars["seafloor_outfitQuest"]);

// How do you want to complete the Skate quest?
// 0 - Skip. 1 - Ice. 2 - Roller. 3 - Board. 4 - Unlock, but don't do the quest.
setvar("seafloor_skateQuest", 0);
int TS_SKATE_QUEST = to_int(vars["seafloor_skateQuest"]);

// Do you want to buy the sand dollars for the skate map if needed? If not, you will adventure for them.
setvar("seafloor_buySkateMap", true);
boolean TS_BUY_SKATEMAP = to_boolean(vars["seafloor_buySkateMap"]);

// Do you want to buy the skateboard if needed?
setvar("seafloor_buySkateBoard", true);
boolean TS_BUY_SKATEBOARD = to_boolean(vars["seafloor_buySkateBoard"]);

// Do you want to get the damp boot?
// 0 - Skip. 1 - Das Boot. 2 - Fishy pipe. 3 - Fish meat. 4 - Damp wallet. 5 - Boot/Pipe/Meat. 6 - Boot/Pipe/Wallet.
setvar("seafloor_bootQuest", 4);
int TS_BOOT_QUEST = to_int(vars["seafloor_bootQuest"]);

// Do you want to buy das boot?
setvar("seafloor_buyBoot", true);
boolean TS_BUY_BOOT = to_boolean(vars["seafloor_buyBoot"]);

// Do you want to get a sushi mat?
// 0 - Skip. 1 - Buy sand dollars. 2 - Farm sand dollars.
setvar("seafloor_getSushiMat", 0);
int TS_GET_SUSHIMAT = to_int(vars["seafloor_getSushiMat"]);

// Do you want to get an aerated helmet?
// 0 - Skip. 1 - Buy. 2 - Adventure. 3 - Fax.
setvar("seafloor_getHelmet", 1);
int TS_GET_HELMET = to_int(vars["seafloor_getHelmet"]);

boolean getsome(int amount, item needed)
{
	boolean succeeded = false;
	string originalabpl = get_property("autoBuyPriceLimit");
	string originalaswm = get_property("autoSatisfyWithMall");
	string originalaswn = get_property("autoSatisfyWithNPCs");
	if (item_amount(needed) >= amount) return true;
	try
	{
		set_property("autoBuyPriceLimit", mall_price(needed));
		set_property("autoSatisfyWithMall", "true");
		set_property("autoSatisfyWithNPCs", "true");
		succeeded = retrieve_item(amount, needed);
	}
	finally
	{
		set_property("autoBuyPriceLimit", originalabpl);
		set_property("autoSatisfyWithMall", originalaswm);
		set_property("autoSatisfyWithNPCs", originalaswn);
	}
	return succeeded;
}

void GrandpaChat()
{
	print("Talking to Grandpa about all sorts of interesting things.");
	visit_url("monkeycastle.php?action=grandpastory&topic=Wizardfish");
	visit_url("monkeycastle.php?action=grandpastory&topic=avius+ticklium&grandpastories=Ask%21");
	visit_url("monkeycastle.php?action=grandpastory&topic=Eel");
	visit_url("monkeycastle.php?action=grandpastory&topic=Neptune+flytrap");
	visit_url("monkeycastle.php?action=grandpastory&topic=Octopus");
	visit_url("monkeycastle.php?action=grandpastory&topic=Wreck");
	visit_url("monkeycastle.php?action=grandpastory&topic=Diver");
	visit_url("monkeycastle.php?action=grandpastory&topic=Reef");
	visit_url("monkeycastle.php?action=grandpastory&topic=Belle");
	visit_url("monkeycastle.php?action=grandpastory&topic=Fisherfish");
	visit_url("monkeycastle.php?action=grandpastory&topic=Mine");
	visit_url("monkeycastle.php?action=grandpastory&topic=Clownfish");
	visit_url("monkeycastle.php?action=grandpastory&topic=Lounge+lizardfish");
	visit_url("monkeycastle.php?action=grandpastory&topic=Nurse+shark");
	visit_url("monkeycastle.php?action=grandpastory&topic=Scales");
	visit_url("monkeycastle.php?action=grandpastory&topic=Groupie");
	vars["seafloor_grandpaChat"] = 1;
	updatevars();
}

void prepHatred()
{
	print("Preparing for the big fight!");
	set_combat_macro_name(false);
	cli_execute("familiar squamous");
	//reduce hp
	cli_execute("uneffect phorcefullness; uneffect incredibly hulking; uneffect reptilian fortitude; uneffect a few extra pounds; uneffect urkel");
	getsome(1, $item[extra-strength red potion]);
	getsome(1, $item[filthy poultice]);
	getsome(1, $item[gauze garter]);
	getsome(1, $item[red pixel potion]);
	getsome(1, $item[green pixel potion]);
	getsome(1, $item[red potion]);
	getsome(1, $item[scented massage oil]);
	getsome(1, $item[sea lasso]);
	getsome(1, $item[mer-kin mouthsoap]);
	getsome(3, $item[mer-kin prayerbeads]);
	equip($slot[acc1], $item[mer-kin prayerbeads]);
	equip($slot[acc2], $item[mer-kin prayerbeads]);
	equip($slot[acc3], $item[mer-kin prayerbeads]);
	switch (my_primestat())
	{
		case $stat[Muscle]:
			maximize("sea, outfit mer-kin scholar, -acc1, -acc2, -acc3, -1000 hp, mainstat, +melee, +shield, 100 elemental damage", false);
			break;
		case $stat[Mysticality]:
			maximize("sea, outfit mer-kin scholar, -acc1, -acc2, -acc3, -1000 hp, mainstat, spell damage", false);
			break;
		case $stat[Moxie]:
			maximize("sea, outfit mer-kin scholar, -acc1, -acc2, -acc3, -1000 hp, mainstat, -melee, 100 elemental damage", false);
			break;
	}
	cli_execute("restore hp");
	print("Now go and prosper greatly!");
}

void smiteHatred()
{
	visit_url("sea_merkin.php?action=temple");
	visit_url("choice.php?pwd&whichchoice=710&option=1&choiceform1=Enter.");
	visit_url("choice.php?pwd&whichchoice=711&option=1&choiceform1=Drink.");
	visit_url("choice.php?pwd&whichchoice=712&option=1&choiceform1=I%EF%BF%BD+YOG-URT%21");
	if (have_skill($skill[ambidextrous funkslinging]))
	{
		//simon disabled deleveling
		//visit_url("fight.php?action=useitem&whichitem=464&whichitem2=4198&useitem=Use+Item%28s%29");
		//visit_url("fight.php?action=useitem&whichitem=5988&whichitem2=6344&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=464&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=5988&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=5996&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=2369&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=2402&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=2438&whichitem2=0&useitem=Use+Item%28s%29");
	}
	else
	{
		visit_url("fight.php?action=useitem&whichitem=464&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=5988&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=5996&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=2369&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=2402&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=2438&whichitem2=0&useitem=Use+Item%28s%29");
		//simon disabled deleveling
		//visit_url("fight.php?action=useitem&whichitem=4198&whichitem2=0&useitem=Use+Item%28s%29");
		//visit_url("fight.php?action=useitem&whichitem=6344&whichitem2=0&useitem=Use+Item%28s%29");
	}
	run_combat();
}

void smiteViolence()
{
	visit_url("sea_merkin.php?action=temple");
	visit_url("choice.php?pwd&whichchoice=706&option=1&choiceform1=Enter+the+Temple");
	visit_url("choice.php?pwd&whichchoice=707&option=1&choiceform1=Receive+the+Blessing+of+Shub-Jigguwat");
	visit_url("choice.php?pwd&whichchoice=708&option=1&choiceform1=Summon+Shub-Jigguwat");
	if (have_skill($skill[ambidextrous funkslinging]))
	{
		//simon disabled deleveling
		visit_url("fight.php?action=useitem&whichitem=5703&whichitem2=5703&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=5703&whichitem2=5703&useitem=Use+Item%28s%29");
	}
	else
	{
		visit_url("fight.php?action=useitem&whichitem=5703");
		visit_url("fight.php?action=useitem&whichitem=5703");
		visit_url("fight.php?action=useitem&whichitem=5703");
		visit_url("fight.php?action=useitem&whichitem=5703");
	}
	abort("copy end text line 415");
	string txt=run_combat();
	//finish up
	visit_url("choice.php");
	visit_url("choice.php?pwd&whichchoice=709&option=1&choiceform1=The+Eyes+Have+It");
}

void MonkeeQuest()
{
	if (my_level() >= 13)
	{
		int loopcounter = 0;
		if (my_ascensions() != to_int(vars["seafloor_monkeeAscension"]))
		{
			print("Resetting Monkee quest status.");
			vars["seafloor_monkeeAscension"] = my_ascensions();
			vars["seafloor_monkeeStep"] = 0;
			updatevars();
		}
		if (!contains_text(currentquests,"An Old Guy and The Ocean") && !contains_text(completedquests,"An Old Guy and The Ocean"))
		{
			print("Unlocking the sea.");
			visit_url("oldman.php?action=talk");
			currentquests = visit_url("questlog.php?which=1");
		}
		if (TS_MONKEE_QUEST > 0 && to_int(vars["seafloor_monkeeStep"]) < TS_MONKEE_QUEST)
		{
			string seafloor = visit_url("seafloor.php");
			string monkeycastle;
			if (my_adventures() > 0 && !contains_text(seafloor,"monkeycastle.gif"))
			{
				print("Finding Little Brother in the Octopus\'s Garden.");
				prepare_for("i",$location[dire warren]);
				cli_execute("use legendary beat");
				if (TS_FAX_NEPTUNE && !get_property("_photocopyUsed").to_boolean() && item_amount($item[wriggling flytrap pellet]) < 1)
				{
					if(!is_online("faxbot"))
					{
						print("Faxbot is offline! Try the script again later.");
						return;
					}
					loopcounter = 0;
					while (get_property( "photocopyMonster" ) != "neptune flytrap" && loopcounter < 5)
					{
						loopcounter += 1;
						if (item_amount ( $item[photocopied monster] ) != 0)
						{
							cli_execute ("fax put");
						}
						chat_private ("faxbot", "neptune_flytrap" );
						wait (60);
						cli_execute ("fax get");
					}
					if (my_adventures() > 0 && item_amount($item[wriggling flytrap pellet]) < 1)
					{
						if (item_amount($item[photocopied monster]) < 1) cli_execute ("fax get");
						if (item_amount($item[photocopied monster]) > 0 && !contains_text(to_lower_case(visit_url("desc_item.php?whichitem=835898159")), "neptune flytrap"))
						{
							print("Someone else hijacked your fax machine. Re-run the script to try again.");
							return;
						}
						use (1, $item[photocopied monster]);
					}
				}
				//now the old fashioned way
				while(i_a("wriggling flytrap pellet")<1)
				{
					prepare_for("i",$location[octopus garden]);
					adventure(1,$location[octopus garden]);
				}
				if (item_amount($item[wriggling flytrap pellet]) < 1)
				{

					print("You have failed to get the wriggling flytrap pellet by fax.");
				}
				else
				{
					use(1, $item[wriggling flytrap pellet]);
					seafloor = visit_url("seafloor.php");
				}
			}
			if (!contains_text(seafloor,"monkeycastle.gif"))
			{
				print("You were unable to unlock the many-windowed castle. Try again later.");
				return;
			}
			if (to_int(vars["seafloor_monkeeStep"]) < 1)
			{
				visit_url("monkeycastle.php?who=1");
				vars["seafloor_monkeeStep"] = 1;
				updatevars();
			}
			monkeycastle = visit_url("monkeycastle.php");
			if (!boolean_modifier("Adventure Underwater") || monkeycastle.contains_text("without some way of breathing underwater"))
			{
				print("You'll need to figure out how you're going to breathe underwater first...");
				return;
			}
			if (to_int(vars["seafloor_monkeeStep"]) >= TS_MONKEE_QUEST)
			{
				return;
			}
			if (my_adventures() > 0 && monkeycastle.contains_text("\#littlebrother\""))
			{
				print("Finding Big Brother in the Wreck of the Edgar Fitzsimmons.");
				string originalChoice = get_property("choiceAdventure299");
				if (originalChoice != "1") set_property("choiceAdventure299", "1");
				
				while(!contains_text(visit_url("monkeycastle.php"),"\#brothers\""))

				{
					print("Finding big brother","lime");
					prepare_for("-",$location[Wreck of the Edgar Fitzsimmons]);
					adventure(1,$location[Wreck of the Edgar Fitzsimmons]);



				}
				if (originalChoice != "1") set_property("choiceAdventure299", originalChoice);
				monkeycastle = visit_url("monkeycastle.php");
			}
			if (to_int(vars["seafloor_monkeeStep"]) == 1 && monkeycastle.contains_text("\#brothers\""))
			{
				monkeycastle = visit_url("monkeycastle.php");
				if (!boolean_modifier("Adventure Underwater") || monkeycastle.contains_text("without some way of breathing underwater"))
				{
					print("You'll need to figure out how you're going to breathe underwater first...");
					return;
				}
				visit_url("monkeycastle.php?who=2");
				visit_url("monkeycastle.php?who=1");
				vars["seafloor_monkeeStep"] = 2;
				updatevars();
			}
			if (to_int(vars["seafloor_monkeeStep"]) >= TS_MONKEE_QUEST)
			{
				return;
			}
			if (my_adventures() > 0 && monkeycastle.contains_text("\#brothers\""))
			{
				print("Finding Grandpa in the "+grandpa.to_string()+".");
			}
			loopcounter = 0;
			while (my_adventures() > 0 && monkeycastle.contains_text("\#brothers\"") && loopcounter < 5 && boolean_modifier("Adventure Underwater"))
			{
				print("Searching for grandpa","lime");
				prepare_for("-",grandpa);
				loopcounter += 1;
				if (!obtain(1,"choiceadv",grandpa))
				{
					print("You have run out of adventures. Continue tomorrow.");
					return;
				}
				else
				{
					monkeycastle = visit_url("monkeycastle.php");
				}
			}
			if (to_int(vars["seafloor_monkeeStep"]) < 3 && monkeycastle.contains_text("\#gpa\""))
			{
				monkeycastle = visit_url("monkeycastle.php");
				if (!boolean_modifier("Adventure Underwater") || monkeycastle.contains_text("without some way of breathing underwater"))
				{
					print("You'll need to figure out how you're going to breathe underwater first...");
					return;
				}
				cli_execute("refresh all");
				if (to_int(vars["seafloor_grandpaChat"]) < 1) GrandpaChat();
				if (TS_UNLOCK_TROPHYFISH)
				{
					print("Talking to Grandpa about the Trophyfish.");
					visit_url("monkeycastle.php?action=grandpastory&topic=Trophyfish");
					vars["seafloor_unlockTrophyFish"] = false;
					updatevars();
				}
				print("Talking to Grandpa about Grandma.");
				visit_url("monkeycastle.php?action=grandpastory&topic=Grandma");
				vars["seafloor_monkeeStep"] = 3;
				updatevars();
			}
			if (to_int(vars["seafloor_monkeeStep"]) >= TS_MONKEE_QUEST)
			{
				return;
			}
			if (my_adventures() > 0 && monkeycastle.contains_text("\#gpa\""))
			{
				print("Finding Grandma in the Mer-kin Outpost.");
				while (item_amount($item[Chartreuse Yarn]) < 1)
				{
					prepare_for("-i", $location[mer-kin outpost]);
					adventure(1,$location[mer-kin outpost]);


				}
				if (my_adventures() > 0 && boolean_modifier("Adventure Underwater"))
				{
					visit_url("monkeycastle.php?action=grandpastory&topic=note");
					if(i_a("grandma map")<1)
						abort("Failed to get grandmas map");
					while (my_adventures() > 1 && boolean_modifier("Adventure Underwater") && monkeycastle.contains_text("\#gpa\""))
					{
						if (count(get_goals()) > 0)
						{
							cli_execute("conditions clear");
						}
						adventure(1, $location[mer-kin outpost]);
						monkeycastle = visit_url("monkeycastle.php");
					}
					if (my_adventures() < 2)
					{
						print("You have run out of adventures. Continue tomorrow.");
						return;
					}
				}
			}
			if (to_int(vars["seafloor_monkeeStep"]) < 4 && monkeycastle.contains_text("\#gfolks\""))
			{
				monkeycastle = visit_url("monkeycastle.php");
				if (!boolean_modifier("Adventure Underwater") || monkeycastle.contains_text("without some way of breathing underwater"))
				{
					print("You'll need to figure out how you're going to breathe underwater first...");
					return;
				}
				vars["seafloor_monkeeStep"] = 4;
				updatevars();
			}
			if (to_int(vars["seafloor_monkeeStep"]) >= TS_MONKEE_QUEST)
			{
				return;
			}
			if (my_adventures() > 0 && monkeycastle.contains_text("\#gfolks\""))
			{
				if (available_amount($item[black glass]) < 1)
				{
					print("Collecting the black glass from the Big Brother.");
					visit_url("monkeycastle.php?who=1");
					visit_url("monkeycastle.php?who=2");
					if (!retrieve_item(13, $item[sand dollar]))
					{
						print("We need 13 sand dollars to continue.");
						return;
					}
					create(1, $item[black glass]);
				}
				if (equipped_amount($item[black glass]) < 1)
				{
					equip($item[black glass]);
				}
				print("Finding Mom in the Caliginous Abyss.");
				loopcounter = 0;
				while (my_adventures() > 0 && monkeycastle.contains_text("\#gfolks\"") && loopcounter < 2)
				{
					prepare_for("", $location[caliginous abyss]);
					loopcounter += 2;
					obtain(1, "choiceadv", $location[caliginous abyss]);
					monkeycastle = visit_url("monkeycastle.php");
				}
			}
			if (to_int(vars["seafloor_monkeeStep"]) < 5 && monkeycastle.contains_text("\#errybody\""))
			{
				vars["seafloor_monkeeStep"] = 5;
				updatevars();
				print("You have completed the Sea Monkee quest.");
			}
		}
		else if (to_int(vars["seafloor_monkeeStep"]) >= TS_MONKEE_QUEST)
		{
			print("You have already completed the Monkee quest.");
		}
		else
		{
			print("The Monkee quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 13 to attempt this quest.");
	}
}

void SkateQuest()
{
	if (my_level() >= 13)
	{
		string seafloor = visit_url("seafloor.php");
		if (my_adventures() > 0 && !contains_text(seafloor,"skatepark.gif") && seafloor.contains_text("monkeycastle.gif") && !contains_text(visit_url("monkeycastle.php"),"\#littlebrother\""))
		{
			if (!boolean_modifier("Adventure Underwater") || contains_text(visit_url("monkeycastle.php"),"without some way of breathing underwater"))
			{
				print("You'll need to figure out how you're going to breathe underwater first...");
				return;
			}
			print("Unlocking the Skate Park.");
			if (item_amount($item[sand dollar]) < 25)
			{
				if (TS_BUY_SKATEMAP)
				{
					getsome(25, $item[sand dollar]);
				}
				else
				{
					if (count(get_goals()) > 0)
					{
						cli_execute("conditions clear");
					}
					add_item_condition(25 - available_amount($item[sand dollar]), $item[sand dollar]);
					prepare_for("i", $location[octopus garden]);
					adventure(my_adventures(), $location[octopus garden]);
					if (my_adventures() < 2)
					{
						print("You have run out of adventures. Continue tomorrow.");
						return;
					}
				}
			}
			if (item_amount($item[sand dollar]) > 24)
			{
				(!create(1, $item[map to the Skate Park]));
				seafloor = visit_url("seafloor.php");
			}
		}
		if (TS_SKATE_QUEST == 4)
		{
			print("You have unlocked the Skate Park.");
			return;
		}
		if (my_adventures() > 0 && TS_SKATE_QUEST < 4 && contains_text(seafloor,"skatepark.gif") && contains_text(visit_url("sea_skatepark.php"),"rumble_"))
		{
			int loopcounter = 0;
			item neededweapon = $item[skate board];
			if (TS_SKATE_QUEST == 1)
			{
				if (get_property("choiceAdventure403").to_int() != 1) set_property("choiceAdventure403", "1");
				neededweapon = $item[skate blade];
			}
			else if (TS_SKATE_QUEST == 2)
			{
				if (get_property("choiceAdventure403").to_int() != 2) set_property("choiceAdventure403", "2");
				neededweapon = $item[brand new key];
			}
			else
			{
				if (available_amount($item[skate blade]) > available_amount($item[brand new key]))
				{
					if (get_property("choiceAdventure403").to_int() != 2) set_property("choiceAdventure403", "2");
				}
				else
				{
					if (get_property("choiceAdventure403").to_int() != 1) set_property("choiceAdventure403", "1");
				}
			}
			print("You will need a "+neededweapon.to_string()+" to complete your Skate Park quest.");
			while (my_adventures() > 0 && TS_SKATE_QUEST < 3 && available_amount(neededweapon) < 1 && loopcounter < 5)
			{
				loopcounter += 1;
				prepare_for("-", $location[skate park]);
				obtain(1, "choiceadv", $location[skate park]);
			}
			if (TS_BUY_SKATEBOARD && available_amount(neededweapon) < 1)
			{
				getsome(1, neededweapon);
			}
			if (TS_SKATE_QUEST == 3)
			{
				if (TS_BUY_SKATEBOARD && available_amount(neededweapon) < 1)
				{
					getsome(1, neededweapon);
				}
				loopcounter = 0;
				while (my_adventures() > 0 && available_amount(neededweapon) < 1 && loopcounter < 5)
				{
					loopcounter += 1;
					prepare_for("i", $location[skate park]);
					obtain(1, neededweapon.to_string(), $location[skate park]);
				}
			}
			if (my_adventures() < 1)
			{
				print("You have run out of adventures. Continue tomorrow.");
				return;
			}
			if (equipped_item($slot[weapon]) != neededweapon)
			{
				print("Equipping your Skate Park weapon.");
				equip($slot[weapon], neededweapon);
			}
			print("\'For peace!\' will be our battle cry! To the Skate Park!");
			loopcounter = 0;
			string skatepark = visit_url("sea_skatepark.php");
			while (my_adventures() > 0 && (contains_text(skatepark,"rumble_a.gif") || contains_text(skatepark,"rumble_b.gif")) && loopcounter < 5)
			{
				loopcounter += 1;
				prepare_for("-", $location[skate park]);
				obtain(1, "choiceadv", $location[skate park]);
				skatepark = visit_url("sea_skatepark.php");
			}
			if (!contains_text(skatepark,"rumble_"))
			{
				print("You have completed the Skate Park quest.");
			}
			else
			{
				print("Your stats are either too low to adventure at the Skate Park or you ran out of adventures. Fix that.");
			}
			return;
		}
		else
		{
			print("You have already completed the Skate Park quest.");
			return;
		}
	}
	else
	{
		print("You must be at least level 13 to attempt this quest.");
	}
}

void BootQuest()
{
	if (my_level() >= 13)
	{
		if (currentquests.contains_text("An Old Guy and The Ocean") && to_int(vars["seafloor_monkeeStep"]) > 1)
		{
			print("You need 50 sand dollars to complete this quest.");
			if (TS_BUY_BOOT && available_amount($item[damp old boot]) < 1)
			{
				getsome(50, $item[sand dollar]);
			}
			else if (available_amount($item[damp old boot]) < 1 && my_adventures() > 0 && available_amount($item[sand dollar]) < 50 && contains_text(visit_url("seafloor.php"),"monkeycastle.gif") && !contains_text(visit_url("monkeycastle.php"),"\#littlebrother\""))
			{
				if (count(get_goals()) > 0)
				{
					cli_execute("conditions clear");
				}
				add_item_condition(50 - available_amount($item[sand dollar]), $item[sand dollar]);
				prepare_for("i", $location[octopus garden]);
				adventure(my_adventures(), $location[octopus garden]);
			}
			if (available_amount($item[sand dollar]) > 49 || available_amount($item[damp old boot]) > 0)
			{
				print("Buying the boot and collecting our well-earned reward.");
				if (available_amount($item[damp old boot]) < 1) create(1, $item[damp old boot]);
				visit_url("oldman.php?action=talk");
				switch(TS_BOOT_QUEST)
				{
					case 1:
						visit_url("oldman.php?action=pickreward&whichreward=3609");
						break;
					case 2:
						visit_url("oldman.php?action=pickreward&whichreward=6314");
						break;
					case 3:
						visit_url("oldman.php?action=pickreward&whichreward=6312");
						use(1, $item[crate of fish meat]);
						break;
					case 4:
						visit_url("oldman.php?action=pickreward&whichreward=6313");
						use(1, $item[damp old wallet]);
						break;
					case 5:
						if (available_amount($item[das boot]) < 1)
							visit_url("oldman.php?action=pickreward&whichreward=3609");
						else if (available_amount($item[fishy pipe]) < 1)
							visit_url("oldman.php?action=pickreward&whichreward=6314");
						else
						{
							visit_url("oldman.php?action=pickreward&whichreward=6312");
							use(1, $item[crate of fish meat]);
						}
						break;
					case 6:
						if (available_amount($item[das boot]) < 1)
							visit_url("oldman.php?action=pickreward&whichreward=3609");
						else if (available_amount($item[fishy pipe]) < 1)
							visit_url("oldman.php?action=pickreward&whichreward=6314");
						else
						{
							visit_url("oldman.php?action=pickreward&whichreward=6313");
							use(1, $item[damp old wallet]);
						}
						break;
				}
			}
		}
		else if (completedquests.contains_text("An Old Guy and The Ocean"))
		{
			print("You have already completed the Old Guy and The Ocean quest.");
		}
		else
		{
			print("Something went very wrong with your Old Guy and The Ocean quest.");
		}
	}
	else
	{
		print("You must be at least level 13 to attempt this quest.");
	}
}

void GetSushiMat()
{
	if (my_level() >= 13)
	{
		if (get_campground() contains $item[sushi mat])
		{
#			print("You already have a sushi mat.");
		}
		else if (to_int(vars["seafloor_monkeeStep"]) > 1)
		{
			print("You need 50 sand dollars to buy a sushi mat.");
			if (TS_GET_SUSHIMAT == 1 && available_amount($item[sushi mat]) < 1)
			{
				getsome(50, $item[sand dollar]);
			}
			else if (my_adventures() > 0 && available_amount($item[sand dollar]) < 50 && contains_text(visit_url("seafloor.php"),"monkeycastle.gif") && !contains_text(visit_url("monkeycastle.php"),"\#littlebrother\""))
			{
				if (count(get_goals()) > 0)
				{
					cli_execute("conditions clear");
				}
				add_item_condition(50 - available_amount($item[sand dollar]), $item[sand dollar]);
				prepare_for("i", $location[octopus garden]);
				adventure(my_adventures(), $location[octopus garden]);
			}
			if (available_amount($item[sand dollar]) > 49)
			{
				print("Buying a sushi mat for our campsite.");
				create(1, $item[sushi-rolling mat]);
				use(1, $item[sushi-rolling mat]);
			}
		}
	}
	else
	{
		print("You must be at least level 13 to buy a sushi mat.");
	}
}

void GetAeratedHelmet()
{
	if (my_level() >= 13)
	{
		if (available_amount($item[aerated diving helmet]) > 0)
		{
#			print("You already have an aerated diving helmet.");
		}
		else if (available_amount($item[bubblin stone]) < 1)
		{
			print("You need a bubblin' stone to make an aerated diving helmet.");
		}
		else
		{
			print("You need a rusty diving helmet.");
			if (TS_GET_HELMET == 1 && available_amount($item[rusty diving helmet]) < 1)
			{
				getsome(1, $item[rusty diving helmet]);
			}
			else if (my_adventures() > 0 && available_amount($item[rusty diving helmet]) < 1)
			{
				if (count(get_goals()) > 0)
				{
					cli_execute("conditions clear");
				}
				add_item_condition(1, $item[rusty diving helmet]);
				if (TS_GET_HELMET == 3 && get_property("_photocopyUsed") != "false")

				{
					int loopcounter = 0;
					if(!is_online("faxbot"))
					{
						print("Faxbot is offline! Try the script again later.");
						return;
					}
					while (get_property( "photocopyMonster" ) != "unholy diver" && loopcounter < 5)
					{
						loopcounter += 1;
						if (item_amount ( $item[photocopied monster] ) != 0)
						{
							cli_execute ("fax put");
						}
						chat_private ("faxbot", "unholy_diver" );
						wait (60);
						cli_execute ("fax get");
					}
					loopcounter = 0;
					while (my_adventures() > 0 && loopcounter < 15 && creatable_amount($item[rusty diving helmet]) < 1)
					{
						loopcounter += 1;
						if (item_amount($item[photocopied monster]) < 1) cli_execute ("fax get");
						if (item_amount($item[photocopied monster]) > 0 && !contains_text(to_lower_case(visit_url("desc_item.php?whichitem=835898159")), "unholy diver"))
						{
							print("Someone else hijacked your fax machine. Re-run the script to try again.");
							return;
						}
						use (1, $item[photocopied monster]);
					}
					loopcounter = 0;
				}
				else
				{
					prepare_for("i", $location[Wreck of the Edgar Fitzsimmons]);
					adventure(my_adventures(), $location[Wreck of the Edgar Fitzsimmons]);
				}
			}
			if (creatable_amount($item[aerated diving helmet]) > 0)
			{
				create(1, $item[aerated diving helmet]);
			}
		}
	}
	else
	{
		print("You must be at least level 13 to buy a sushi mat.");
	}
}

//---------------------------simons quest extensions
void deepcity_unlock()
{
	if(get_property("deepcity_unlocked")!=my_ascensions())
	{
		if(get_property("corral_unlocked")!=my_ascensions() && !contains_text(visit_url("seafloor.php"),"corrala.gif"))
		{
			// get lockkey
			if(i_a("mer-kin lockkey")==0)
			{
				//Set this, to tell us if we find the choiceadv before we think we have a key
				set_property("choiceAdventure313", 0);
				set_property("choiceAdventure314", 0);
				set_property("choiceAdventure315", 0);
				
				while(i_a("mer-kin lockkey")==0)
				{
					prepare_for("i", $location[mer-kin outpost]);
					print("Farming a lockkey","lime");
					adventure(1,$location[mer-kin outpost]);
				}
			}
			if(i_a("mer-kin stashbox")==0 && i_a("mer-kin trailmap")==0)
			{
				// get lockkey
				while(i_a("mer-kin stashbox")==0)
				{
					print("Farming a Stashbox","lime");
					int cur_choice=1;
					//rely on mafia to set tent choiceadventure, we just set the subadv
					if(get_property("merkin_tent_explored1")!=my_ascensions())
					{
						set_property("choiceAdventure313", 1);
						set_property("choiceAdventure314", 1);
						set_property("choiceAdventure315", 1);
					}
					else if(get_property("merkin_tent_explored2")!=my_ascensions())
					{
						set_property("choiceAdventure313", 2);
						set_property("choiceAdventure314", 2);
						set_property("choiceAdventure315", 2);
						cur_choice=2;
					}
					else if(get_property("merkin_tent_explored3")!=my_ascensions())
					{
						set_property("choiceAdventure313", 3);
						set_property("choiceAdventure314", 3);
						set_property("choiceAdventure315", 3);
						cur_choice=3;
					}
					else
						abort("We shouldn't still be searching for a stashbox if all tent choices are done");
						
					prepare_for("-", $location[mer-kin outpost]);
					adventure(1,$location[mer-kin outpost]);
					
					//note if we have explored that choiceadv
					if(contains_text(get_property("lastEncounter"),"Intent"))
					{
						set_property("merkin_tent_explored"+cur_choice,my_ascensions());
						cur_choice+=1;
					}					
				}
			}
			//get a map
			if(i_a("mer-kin trailmap")==0)
			{
				use(1,$item[mer-kin stashbox]);
			}
			//use map then 
			if(i_a("mer-kin trailmap")==1)
			{
				use(1,$item[mer-kin trailmap]);
				visit_url("seafloor.php?action=currents");
				visit_url("monkeycastle.php?action=grandpastory&topic=currents");
			}
		}
		if(contains_text(visit_url("seafloor.php"),"corrala.gif"))
			set_property("corral_unlocked",my_ascensions());
		else
			abort("Failed to unlock corral");
		
		//train lasso
		while(get_property("lassoTraining")!= "expertly")
		{
			//brinier deeps has lots of combat and a nice semirare
			prepare_for("i", $location[The Brinier Deepers]);
			adventure(1,$location[The Brinier Deepers]);
		}
		//get seahorse
		while(contains_text(visit_url("seafloor.php?action=currents"),"far too strong for you to swim against"))
		{
			prepare_for("i", $location[Coral Corral]);
			//macros don't seem to fire for seahorses so we have to do it this way
			string txt=visit_url("adventure.php?snarfblat=199");
			txt=visit_url("fight.php?action=macro&macrotext=&whichmacro=100629&macro=Execute+Macro");
			
			//adventure(1,$location[Coral Corral]);
		}
		if(!contains_text(visit_url("seafloor.php?action=currents"),"far too strong for you to swim against"))
			set_property("deepcity_unlocked",my_ascensions());
		else
			abort("failed to open deepcity");
	}
}

//gladiator path - beat colloseum
void gladiator_path()
{
	//go through colloseum using right weapon for each fight
	while(!to_boolean(get_property("_merkin_temple_open")))
	{
		prepare_for("", $location[Mer-Kin colosseum]);
		//equip appropriate weapon
		string next_fight=get_property("_merkin_colosseum_nextfight");
		if(next_fight=="balldodger")
			equip($item[mer-kin dragnet]);
		else if(next_fight=="netdragger")
			equip($item[mer-kin switchblade]);
		else if(next_fight=="bladeswitcher")
			equip($item[mer-kin dodgeball]);
		else
		{
			print("_merkin_colosseum_nextfight property was a "+next_fight+" so i'll assume we are starting colloseum from beginning, and will use a dragnet","green");
			equip($item[mer-kin dragnet]);
		}

		cli_execute("mood execute; restore hp");
		print("Fighting in colosseum","lime");
		//just like seahorses, macros don't fire here... so force gladiator macro with visit_url
		string txt = visit_url("adventure.php?snarfblat=210");
		//are we in round 5?
		boolean round_5=contains_text(txt,">Round 5");
		
		txt=visit_url("fight.php?action=macro&macrotext=&whichmacro=100626&macro=Execute+Macro");
		if(contains_text(txt,"WINWINWIN"))
		{
			if(next_fight=="netdragger")
				set_property("_merkin_colosseum_nextfight","bladeswitcher");
			else if(next_fight=="bladeswitcher")
				set_property("_merkin_colosseum_nextfight","balldodger");
			else
				set_property("_merkin_colosseum_nextfight","netdragger");
				
			//are we done now?
			if(contains_text(txt,"the medallion becomes a sigil of liquid fire"))
				set_property("_merkin_temple_open","true");
		}
		else
			abort("Failed to kill gladiator");
			
		//
		if(round_5)
		{
			boolean tmp=cli_execute("ballpit; telescope high");
		}

		//sometimes we get disarmed and mafia doesn't know, so do this
		cli_execute("inventory refresh");
		txt=visit_url("inventory.php?which=2");
	}

	//boss fight
	prepare_for("", $location[Mer-Kin gymnasium]); //mafia doesn't recognise temple
	//remove mp
	cli_execute("burn *");
	//no passive damage
	cli_execute("uneffect scarysauce; uneffect jalap; uneffect jaba; familiar squamous gibberer");
	if(i_a("crayon shavings")<4)
		buy(4,$item[crayon shavings]);
	
	smiteViolence();
}

//scholar path - learn religious words
void scholar_path()
{
	if(!to_boolean(get_property("_merkin_temple_open")))
	{
		//learn vocabulary
		if(get_property("merkin_vocab")!=my_ascensions())
		{
			buy(10-i_a("mer-kin wordquiz"),$item[mer-kin wordquiz]);
			buy(10-i_a("mer-kin cheatsheet"),$item[mer-kin cheatsheet]);
			use(10,$item[mer-kin wordquiz]);
			cli_execute("inventory refresh");
			if(i_a("mer-kin wordquiz")!=0)
				abort("Failed to use wordquizes");
			else
				set_property("merkin_vocab",my_ascensions());
		}
		
		//figure out special words farming library, using healscroll and killscroll
		//words 1,6,8
		while(get_property("_merkin_word1")=="")
		{
			if(get_property("_merkin_word8")=="")
				set_property("choiceAdventure704",1);
			else if(get_property("_merkin_word6")=="")
				set_property("choiceAdventure704",2);
			else if(get_property("_merkin_word1")=="")
				set_property("choiceAdventure704",3);
			else
				abort("Something went wrong, line 1096 thesea.ash");
			print("learning "+get_property("choiceAdventure704")+"rd library catalog word","green");
				
			prepare_for("-", $location[Mer-Kin Library]);
			abort("Don't currently remember words from choiceadv line 1100");
			adventure(1,$location[Mer-Kin Library]);
			if(contains_text(get_property("lastEncounter"),"Playing the Catalog Card"))
				abort("Remember new word");
		}
		
		//use knucklebone
		if(get_property("_merkin_word4")=="")
		{
			print("learning knucklebone word","green");
			abort("line 923, visit url to use knucklebone and record word, or wait for mafia support");
			string html = visit_url("inv_use.php?which=3&whichitem=6357");
		}
		
		//cast Deep Dark Visions
		while(get_property("_merkin_word3")=="")
		{
			print("learning deep-dark-visions word","green");
			if(have_effect($effect[spookyform])==0)
				use(1,$item[phial of spookiness]);
				
			if(my_mp()<100 || my_hp()<500)
				abort("Can't operate with less than 100mp and 500 hp");
			string html=visit_url("skills.php?pwd&action=Skillz&whichskill=90&skillform=Use+Skill&quantity=1");
			if(contains_text(html,"of Cards") || contains_text(html,"Blues") || contains_text(html,"Pancakes") || contains_text(html,"Pain"))
			{
				print(html,"red");
				abort("found word! ");
			}
		}
		while(i_a("mer-kin dreadscroll")<1)
		{
			print("getting dreadscroll","green");
			prepare_for("-", $location[Mer-Kin Library]);
			adventure(1,$location[Mer-Kin Library]);
		}
		
		//fill the dreadscroll
	#	int pro1,pro2,pro3,pro4,pro5,pro6,pro7,pro8;
	#	switch(get_property("_merkin_word3"))
	#	{
	#		case 
	#			pro
	#	}
		#pro2 = healscroll - 1 starfish. 2 moonfish. 3 sunfish. 4 planetfish.
	#pro3 = DDV - 1 Cards. 2 Blues. 3 Pancakes. 4 Pain.
	#pro4 = knucklebone - 1 north. 2 south. 3 east. 4 west.
	#pro5 = killscroll - 1 red. 2 black. 3 green. 4 yellow.
	#pro7 = worktea - 1 eel. 2 turtle. 3 shark. 4 whale.         - workteaClue

	#pro1 = LIBRARY - 1 LONELY. 2 DOUBLED. 3 THRICE-CURSED. 4 FOURTH.
	#pro6 = library - 1 blind. 2 giant. 3 finless. 4 two-headed.
	#pro8 = library - 1 1KSY. 2 22SS. 3 CT. 4 aBNDC.
	#	abort("line 984 visit_url to fill in dreadscroll?");
	#		visit_url("inv_use.php?pwd&which=3&whichitem=6353");
//		string html=visit_url("choice.php?pro1=1&pro2=1&pro3=1&pro4=1&pro5=1&pro6=1&pro7=1&pro8=1&whichchoice=703&pwd&option=1");
//	
//		if(contains_text(html,"I guess you're the Mer-kin High Priest now"))
//			set_property("_merkin_temple_open","true");
//		else
//			abort("Failed to fill in dreadscroll");
	}

	prepHatred();
	smiteHatred();
	//boss fight?
	set_combat_macro_name(false);
	cli_execute("familiar squamous");
	cli_execute("uneffect phorcefullness; uneffect incredibly hulking; uneffect reptilian fortitude; uneffect a few extra pounds; uneffect urkel");
	//reduce hp
	getsome(1, $item[extra-strength red potion]);
	getsome(1, $item[filthy poultice]);
	getsome(1, $item[gauze garter]);
	getsome(1, $item[red pixel potion]);
	getsome(1, $item[green pixel potion]);
	getsome(1, $item[red potion]);
	getsome(1, $item[scented massage oil]);
	getsome(1, $item[sea lasso]);
	getsome(1, $item[mer-kin mouthsoap]);
	getsome(3, $item[mer-kin prayerbeads]);
	equip($slot[acc1], $item[mer-kin prayerbeads]);
	equip($slot[acc2], $item[mer-kin prayerbeads]);
	equip($slot[acc3], $item[mer-kin prayerbeads]);
	maximize("sea, outfit mer-kin scholar, -acc1, -acc2, -acc3, -1000 hp, 0.1 mainstat", false);
	cli_execute("restore hp");
}
//-----------------------------------------------------

void main()
{
	int prev_adv_val = to_int(get_property("valueOfAdventure"));
	set_property("valueOfAdventure","10000");
	if (my_inebriety() > inebriety_limit())
	{
		print("The Sea is too dangerous to try to traverse while intoxicated to the levels you're attempting. Try again tomorrow.");
		return;
	}
	if (my_level() < 13)
	{
		print("The Sea is too dangerous for youngsters. Try again when you've older.");
		return;
	}
	try
	{
		if (TS_CLOSETMEAT >= 0)
		{
			put_closet(TS_CLOSETMEAT);
		}
		if (TS_MAXIMIZE != "" || TS_OUTFIT != "")
		{
			cli_execute("checkpoint");
			if (TS_MAXIMIZE != "")
			{
				maximize(TS_MAXIMIZE, false);
			}
			else
			{
				outfit(TS_OUTFIT);
			}
		}
		MonkeeQuest();
		if (TS_SKATE_QUEST > 0) SkateQuest();

		if (TS_BOOT_QUEST!=0) BootQuest();
		if (TS_GET_SUSHIMAT > 0) GetSushiMat();
		if (TS_GET_HELMET > 0) GetAeratedHelmet();
		//simons quests
		deepcity_unlock();
		
		//ask to set it if not set
		if(get_property("_merkin_path_to_take")=="")
		{
			if(user_confirm("Do you want to take the gladiator path this time?"))
				set_property("_merkin_path_to_take","gladiator");
			else
				set_property("_merkin_path_to_take","scholar");
		}
		
		//do the chosen path
		string path=get_property("_merkin_path_to_take");
		if(path=="gladiator")
		{
			gladiator_path();
		}
		else if(path=="scholar")
		{
			scholar_path();
		}
		else
			abort("Unrecognised path variable "+path);
	}
	finally
	{
		if (TS_CLOSETMEAT >= 0)
		{
			take_closet(TS_CLOSETMEAT);
		}
		if (TS_MAXIMIZE != "" || TS_OUTFIT != "")
		{
			outfit("checkpoint");
		}
		set_property("valueOfAdventure",prev_adv_val);
	}
}
