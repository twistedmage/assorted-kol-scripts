script "TheSea.ash";
notify "Theraze";
import <zlib.ash>;

string thisver = "1.6.3";
check_version( "TheSea.ash", "TheSea", thisver, 8708 );

string currentquests = visit_url("questlog.php?which=1");
string completedquests = visit_url("questlog.php?which=2");
location grandpa;
if (my_primestat() == $stat[Muscle]) grandpa = $location[Anemone Mine];
else if (my_primestat() == $stat[Mysticality]) grandpa = $location[The Marinara Trench];
else if (my_primestat() == $stat[Moxie]) grandpa = $location[The Dive Bar];

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
setvar("seafloor_monkeeQuest", 5);
int TS_MONKEE_QUEST = to_int(vars["seafloor_monkeeQuest"]);

// Do you want to fax for the Neptune Flytrap, to increase the item drop rate and avoid underwater penalties?
// This will abort if set to true and you are unable to access faxbot for some reason.
setvar("seafloor_faxNeptune", false);
boolean TS_FAX_NEPTUNE = to_boolean(vars["seafloor_faxNeptune"]);

// Which version of the grandpa chat series have you done? This skips unnecessary server hits.
setvar("seafloor_grandpaChat", 0);

// Do you want it to unlock the Trophyfish encounter? This defaults to false, since you'll likely only want to do this once.
setvar("seafloor_unlockTrophyfish", false);
boolean TS_UNLOCK_TROPHYFISH = to_boolean(vars["seafloor_unlockTrophyfish"]);

// Do you want to speed up the abyss with the various equipment pieces?
// 0 - Skip. 1 - Wear what we have. 2 - Buy everything.
setvar("seafloor_abyssEquipment", 1);
int TS_ABYSS_EQUIPMENT = to_int(vars["seafloor_abyssEquipment"]);

// How do you want to complete the Outfit quest?
// 0 - Skip. 1 - Violence. 2 - Hatred. 3 - Loathing.
setvar("seafloor_outfitQuest", 0);
int TS_OUTFIT_QUEST = to_int(vars["seafloor_outfitQuest"]);

// Do you want to go through training and automation on the Gladiator quest?
setvar("seafloor_automateGladiators", true);
boolean TS_GLADIATORS = to_boolean(vars["seafloor_automateGladiators"]);

// How do you want to complete the Skate quest?
// 0 - Skip. 1 - Ice. 2 - Roller. 3 - Board. 4 - Unlock, but don't do the quest.
setvar("seafloor_skateQuest", 0);
int TS_SKATE_QUEST = to_int(vars["seafloor_skateQuest"]);

// Do you want to buy the sand dollars for the skate map if needed? If not, you will adventure for them.
setvar("seafloor_buySkateMap", false);
boolean TS_BUY_SKATEMAP = to_boolean(vars["seafloor_buySkateMap"]);

// Do you want to buy the skateboard if needed?
setvar("seafloor_buySkateBoard", false);
boolean TS_BUY_SKATEBOARD = to_boolean(vars["seafloor_buySkateBoard"]);

// Do you want to get the damp boot?
// 0 - Skip. 1 - Das Boot. 2 - Fishy pipe. 3 - Fish meat. 4 - Damp wallet. 5 - Boot/Pipe/Meat. 6 - Boot/Pipe/Wallet.
setvar("seafloor_bootQuest", 0);
int TS_BOOT_QUEST = to_int(vars["seafloor_bootQuest"]);

// Do you want to buy das boot?
setvar("seafloor_buyBoot", false);
boolean TS_BUY_BOOT = to_boolean(vars["seafloor_buyBoot"]);

// Do you want to get a sushi mat?
// 0 - Skip. 1 - Buy sand dollars. 2 - Farm sand dollars.
setvar("seafloor_getSushiMat", 0);
int TS_GET_SUSHIMAT = to_int(vars["seafloor_getSushiMat"]);

// Do you want to get an aerated helmet?
// 0 - Skip. 1 - Buy. 2 - Adventure. 3 - Fax.
setvar("seafloor_getHelmet", 0);
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

boolean solveHatred(boolean scrolling)
{
	int unknowncount = 0;
	int unknownnumber = 0;
	int unknownchoice = 0;
	int[int] dreadchoice;
	print("Time to figure out the dreadscroll!");
	for i from 1 to 8
	{
		dreadchoice[i] = get_property("dreadScroll"+i).to_int();
		if (dreadchoice[i] == 0)
		{
			print("We don't know a definite solution for "+i);
			unknownnumber = i;
			unknowncount = unknowncount + 1;
		}
	}
	if (!scrolling || unknowncount > 1)
	{
		print("We are aborting with "+unknowncount+" unknown scroll segments.");
		return false;
	}
	while (scrolling && my_adventures() > 1 && dreadchoice[unknownnumber] < 4 && have_effect($effect[deep-tainted mind]) == 0)
	{
		dreadchoice[unknownnumber] = dreadchoice[unknownnumber] + 1;
		visit_url("inv_use.php?pwd&which=3&whichitem=6353");
		visit_url("choice.php?pro1="+dreadchoice[1]+"&pro2="+dreadchoice[2]+"&pro3="+dreadchoice[3]+"&pro4="+dreadchoice[4]+"&pro5="+dreadchoice[5]+"&pro6="+dreadchoice[6]+"&pro7="+dreadchoice[7]+"&pro8="+dreadchoice[8]+"&whichchoice=703&pwd&option=1");
		if (have_effect($effect[deep-tainted mind]) == 0)
		{
			print("Got it! Congrats on your new priestdom.");
			return true;
		}
		else
		{
			print("Not this time... let's burn off "+have_effect($effect[deep-tainted mind])+" adventures fast.");
			adventure(have_effect($effect[deep-tainted mind]), $location[Cobb's Knob Treasury]);
		}
	}
	print("Looks like epic failure. Not sure why exactly, but... aww.");
	return false;
}

void prepHatred()
{
	print("Preparing for the big fight!");
	if (item_amount($item[extra-strength red potion]) < 1) buy(1, $item[extra-strength red potion]);
	if (item_amount($item[filthy poultice]) < 1) buy(1, $item[filthy poultice]);
	if (item_amount($item[gauze garter]) < 1) buy(1, $item[gauze garter]);
	if (item_amount($item[mer-kin mouthsoap]) < 1) buy(1, $item[mer-kin mouthsoap]);
	if (available_amount($item[mer-kin prayerbeads]) < 3) buy(3 - available_amount($item[mer-kin prayerbeads]), $item[mer-kin prayerbeads]);
	if (item_amount($item[red pixel potion]) < 1) buy(1, $item[red pixel potion]);
	if (item_amount($item[red potion]) < 1) buy(1, $item[red potion]);
	if (item_amount($item[scented massage oil]) < 1) buy(1, $item[scented massage oil]);
	if (item_amount($item[sea lasso]) < 1) buy(1, $item[sea lasso]);
	outfit("mer-kin scholar's vestments");
	equip($slot[acc1], $item[mer-kin prayerbeads]);
	equip($slot[acc2], $item[mer-kin prayerbeads]);
	equip($slot[acc3], $item[mer-kin prayerbeads]);
	switch (my_primestat())
	{
		case $stat[Muscle]:
			maximize("-hat, -pants, -acc1, -acc2, -acc3, -familiar, -1000 hp, mainstat, +melee, +shield, 100 elemental damage", false);
			break;
		case $stat[Mysticality]:
			maximize("-hat, -pants, -acc1, -acc2, -acc3, -familiar, -1000 hp, mainstat, spell damage", false);
			break;
		case $stat[Moxie]:
			maximize("-hat, -pants, -acc1, -acc2, -acc3, -familiar, -1000 hp, mainstat, -melee, 100 elemental damage", false);
			break;
	}
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
		visit_url("fight.php?action=useitem&whichitem=464&whichitem2=4198&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=5988&whichitem2=6344&useitem=Use+Item%28s%29");
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
		visit_url("fight.php?action=useitem&whichitem=4198&whichitem2=0&useitem=Use+Item%28s%29");
		visit_url("fight.php?action=useitem&whichitem=6344&whichitem2=0&useitem=Use+Item%28s%29");
	}
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
			visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");
			currentquests = visit_url("questlog.php?which=1");
		}
		if (TS_MONKEE_QUEST > 0 && to_int(vars["seafloor_monkeeStep"]) < TS_MONKEE_QUEST)
		{
			string seafloor = visit_url("seafloor.php");
			string monkeycastle;
			if (my_adventures() > 1 && !contains_text(seafloor,"monkeycastle.gif"))
			{
				print("Finding Little Brother in the Octopus\'s Garden.");
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
					if (my_adventures() > 1 && item_amount($item[wriggling flytrap pellet]) < 1)
					{
						if (item_amount($item[photocopied monster]) < 1) cli_execute ("fax get");
						if (item_amount($item[photocopied monster]) > 0 && !contains_text(to_lower_case(visit_url("desc_item.php?whichitem=835898159")), "neptune flytrap"))
						{
							print("Someone else hijacked your fax machine. Re-run the script to try again.");
							return;
						}
						use (1, $item[photocopied monster]);
					}
#					if (item_amount($item[wriggling flytrap pellet]) < 1)
#					{
#						print("You have failed to get the wriggling flytrap pellet in 15 attempts, or ran out of adventures.");
#						return;
#					}
				}
				if (obtain(1,"wriggling flytrap pellet",$location[An Octopus's Garden]))
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
			if (my_adventures() > 1 && monkeycastle.contains_text("\#littlebrother\""))
			{
				print("Finding Big Brother in the Wreck of the Edgar Fitzsimmons.");
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
				string originalChoice = get_property("choiceAdventure299");
				if (originalChoice != "1") set_property("choiceAdventure299", "1");
				if (!obtain(1,"choiceadv",$location[The Wreck of the Edgar Fitzsimmons]))
				{
					if (originalChoice != "1") set_property("choiceAdventure299", originalChoice);
					print("You have run out of adventures. Continue tomorrow.");
					return;
				}
				if (originalChoice != "1") set_property("choiceAdventure299", originalChoice);
				monkeycastle = visit_url("monkeycastle.php");
			}
			if (to_int(vars["seafloor_monkeeStep"]) < 2 && monkeycastle.contains_text("\#brothers\""))
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
			if (my_adventures() > 1 && monkeycastle.contains_text("\#brothers\""))
			{
				print("Finding Grandpa in the "+grandpa.to_string()+".");
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
			}
			loopcounter = 0;
			while (my_adventures() > 1 && monkeycastle.contains_text("\#brothers\"") && loopcounter < 5 && boolean_modifier("Adventure Underwater"))
			{
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
			if (my_adventures() > 1 && monkeycastle.contains_text("\#gpa\""))
			{
				print("Finding Grandma in the Mer-kin Outpost.");
				if (item_amount($item[Grandma's Map]) < 1 && !obtain(1,"grandma chartreuse yarn",$location[The Mer-kin Outpost]))
				{
					print("You have run out of adventures. Continue tomorrow.");
					return;
				}
				if (my_adventures() > 1 && boolean_modifier("Adventure Underwater"))
				{
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
					visit_url("monkeycastle.php?action=grandpastory&topic=note");
					while (my_adventures() > 1 && boolean_modifier("Adventure Underwater") && monkeycastle.contains_text("\#gpa\""))
					{
						if (count(get_goals()) > 0)
						{
							cli_execute("conditions clear");
						}
						adventure(1, $location[The Mer-kin Outpost]);
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
			if (my_adventures() > 1 && monkeycastle.contains_text("\#gfolks\""))
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
				cli_execute("checkpoint");
				if (equipped_amount($item[black glass]) < 1)
				{
					equip($item[black glass]);
				}
				if (TS_ABYSS_EQUIPMENT > 0)
				{
					boolean acomb = true;
					boolean asweater = true;
					boolean aunderwear = true;
					print("Speeding up Mom in the Caliginous Abyss with your equipment choices.");
					if (TS_ABYSS_EQUIPMENT == 1 && available_amount($item[comb jelly]) < 1)
					{
						acomb = false;
					}
					else
					{
						acomb = getsome(1, $item[comb jelly]);
					}
					if (!have_skill($skill[torso awaregness]))
					{
						asweater = false;
					}
					else
					{
						if (TS_ABYSS_EQUIPMENT == 1 && available_amount($item[shark jumper]) < 1)
						{
							asweater = false;
						}
						else
						{
							asweater = getsome(1, $item[shark jumper]);
						}
					}
					if (TS_ABYSS_EQUIPMENT == 1 && available_amount($item[scale-mail underwear]) < 1)
					{
						aunderwear = false;
					}
					else
					{
						aunderwear = getsome(1, $item[scale-mail underwear]);
					}
					if (acomb && have_effect($effect[jelly combed]) < 1)
					{
						use(1, $item[comb jelly]);
					}
					if (asweater)
					{
						equip($item[shark jumper]);
					}
					if (aunderwear)
					{
						equip($item[scale-mail underwear]);
					}
				}
				print("Finding Mom in the Caliginous Abyss.");
				loopcounter = 0;
				while (my_adventures() > 1 && monkeycastle.contains_text("\#gfolks\"") && loopcounter < 2)
				{
					loopcounter += 2;
					obtain(1, "choiceadv", $location[The Caliginous Abyss]);
					monkeycastle = visit_url("monkeycastle.php");
				}
				outfit("checkpoint");
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

void OutfitQuest()
{
	if (my_level() >= 13 && get_property("merkinQuestPath") != "done")
	{
		if (TS_MONKEE_QUEST < 4 || to_int(vars["seafloor_monkeeStep"]) < TS_MONKEE_QUEST)
		{
			print("We need to find Grandma before we can continue on our grand adventure.");
			return;
		}
		string fightpage;
		string seafloor = visit_url("seafloor.php");
		int loopcounter = 0;
		if (!seafloor.contains_text("corrala.gif") && !seafloor.contains_text("corralb.gif"))
		{
			if (my_adventures() > 1 && boolean_modifier("Adventure Underwater") && item_amount($item[mer-kin lockkey]) < 1)
			{
				print("We need a lockkey before we can open the stashbox.");
				if (!obtain(1,"mer-kin lockkey",$location[The Mer-kin Outpost]))
				{
					print("You have run out of adventures. Continue tomorrow.");
					return;
				}
			}
			if (item_amount($item[mer-kin stashbox]) < 1)
			{
				print("We need a stashbox before we can talk to Grandpa.");
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
				foreach it,entry in maximize("-combat, -tie", 0, 0, true, false) if (entry.score > 0 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
				while (my_adventures() > 1 && loopcounter < 4 && boolean_modifier("Adventure Underwater") && item_amount($item[mer-kin stashbox]) < 1)
				{
					loopcounter += 1;
					set_property("choiceAdventure"+(312 + get_property("choiceAdventure312").to_int()), (get_property("choiceAdventure"+(312 + get_property("choiceAdventure312").to_int())).to_int() % 3) + 1);
					if (!obtain(1,"choiceadv",$location[The Mer-kin Outpost]))
					{
						print("You have run out of adventures. Continue tomorrow.");
						return;
					}
				}
			}
			if (item_amount($item[mer-kin stashbox]) > 0)
			{
				use(1, $item[mer-kin stashbox]);
			}
			if (item_amount($item[mer-kin trailmap]) > 0)
			{
				use(1, $item[mer-kin trailmap]);
				print("Talking to Grandpa about currents.");
				visit_url("monkeycastle.php?action=grandpastory&topic=currents");
				seafloor = visit_url("seafloor.php");
			}
		}
		if ((seafloor.contains_text("corrala.gif") || seafloor.contains_text("corralb.gif")) && get_property("seahorseName") == "")
		{
			if (get_property("lassoTraining") != "expertly")
			{
				print("Please train with the lasso until you become expert, then re-run the script.");
				return;
			}
			print("Making sure we have the items needed to tame our mount!");
			if (!getsome(3, $item[sea cowbell])) obtain(3, $item[sea cowbell], $location[the coral corral]);
			if (!getsome(1, $item[sea lasso])) obtain(1, $item[sea lasso], $location[the coral corral]);
			boolean tamingloop = true;
			while (my_adventures() > 1 && tamingloop && boolean_modifier("Adventure Underwater"))
			{
				if (to_float(my_hp()) / my_maxhp() < to_float(get_property("hpAutoRecovery")))
				{
					restore_hp(0);
				}
				if (to_float(my_mp()) / my_maxmp() < to_float(get_property("mpAutoRecovery")))
				{
					restore_mp(0);
				}
				fightpage = visit_url("adventure.php?snarfblat=199");
				if (last_monster() == $monster[wild seahorse])
				{
					if (have_skill($skill[ambidextrous funkslinging]))
					{
						visit_url("fight.php?action=useitem&whichitem=4196&whichitem2=4196&useitem=Use+Item%28s%29");
						visit_url("fight.php?action=useitem&whichitem=4196&whichitem2=4198&useitem=Use+Item%28s%29");
					}
					else
					{
						visit_url("fight.php?action=useitem&whichitem=4196&whichitem2=0&useitem=Use+Item%28s%29");
						visit_url("fight.php?action=useitem&whichitem=4196&whichitem2=0&useitem=Use+Item%28s%29");
						visit_url("fight.php?action=useitem&whichitem=4196&whichitem2=0&useitem=Use+Item%28s%29");
						visit_url("fight.php?action=useitem&whichitem=4198&whichitem2=0&useitem=Use+Item%28s%29");
					}
					tamingloop = false;
					print("Your mount is prepared!");
				}
				else
				{
					run_combat();
				}
			}
		}
		if (get_property("seahorseName") == "")
		{
			print("Something went wrong and your seahorse appears to have escaped. Try to find it again.");
			return;
		}
		if (TS_OUTFIT_QUEST > 2)
		{
			int requiredpieces = TS_OUTFIT_QUEST - 2;
			int avail1;
			int avail2;
			int avail3;
			int avail4;
			switch (my_class())
			{
				case $class[seal clubber]:
					avail1 = available_amount($item[ass-stompers of violence]);
					avail2 = available_amount($item[treads of loathing]);
					avail3 = available_amount($item[cold stone of hatred]);
					avail4 = available_amount($item[scepter of loathing]);
					if (avail3 < 1 || avail3 + avail4 < requiredpieces) TS_OUTFIT_QUEST = 2;
					else if (avail1 < 1 || avail1 + avail2 < requiredpieces) TS_OUTFIT_QUEST = 1;
					break;
				case $class[turtle tamer]:
					avail1 = available_amount($item[brand of violence]);
					avail2 = available_amount($item[scepter of loathing]);
					avail3 = available_amount($item[girdle of hatred]);
					avail4 = available_amount($item[belt of loathing]);
					if (avail3 < 1 || avail3 + avail4 < requiredpieces) TS_OUTFIT_QUEST = 2;
					else if (avail1 < 1 || avail1 + avail2 < requiredpieces) TS_OUTFIT_QUEST = 1;
					break;
				case $class[pastamancer]:
					avail1 = available_amount($item[novelty belt buckle of violence]);
					avail2 = available_amount($item[belt of loathing]);
					avail3 = available_amount($item[staff of simmering hatred]);
					avail4 = available_amount($item[stick-knife of loathing]);
					if (avail3 < 1 || avail3 + avail4 < requiredpieces) TS_OUTFIT_QUEST = 2;
					else if (avail1 < 1 || avail1 + avail2 < requiredpieces) TS_OUTFIT_QUEST = 1;
					break;
				case $class[sauceror]:
					avail1 = available_amount($item[lens of violence]);
					avail2 = available_amount($item[goggles of loathing]);
					avail3 = available_amount($item[pantaloons of hatred]);
					avail4 = available_amount($item[jeans of loathing]);
					if (avail3 < 1 || avail3 + avail4 < requiredpieces) TS_OUTFIT_QUEST = 2;
					else if (avail1 < 1 || avail1 + avail2 < requiredpieces) TS_OUTFIT_QUEST = 1;
					break;
				case $class[disco bandit]:
					avail1 = available_amount($item[pigsticker of violence]);
					avail2 = available_amount($item[stick-knife of loathing]);
					avail3 = available_amount($item[fuzzy slippers of hatred]);
					avail4 = available_amount($item[treads of loathing]);
					if (avail3 < 1 || avail3 + avail4 < requiredpieces) TS_OUTFIT_QUEST = 2;
					else if (avail1 < 1 || avail1 + avail2 < requiredpieces) TS_OUTFIT_QUEST = 1;
					break;
				case $class[accordion thief]:
					avail1 = available_amount($item[jodhpurs of violence]);
					avail2 = available_amount($item[jeans of loathing]);
					avail3 = available_amount($item[lens of hatred]);
					avail4 = available_amount($item[goggles of loathing]);
					if (avail3 < 1 || avail3 + avail4 < requiredpieces) TS_OUTFIT_QUEST = 2;
					else if (avail1 < 1 || avail1 + avail2 < requiredpieces) TS_OUTFIT_QUEST = 1;
					break;
				default:
					break;
			}
		}
		switch(TS_OUTFIT_QUEST)
		{
			case 1:
				if (!have_outfit("mer-kin gladiatorial gear") && !have_outfit("crappy mer-kin disguise"))
				{
					print("Getting your crappy disguise together.");
					getsome(1, $item[crappy mer-kin mask]);
					getsome(1, $item[crappy mer-kin tailpiece]);
					if (!have_outfit("crappy mer-kin disguise"))
					{
						print("Crappy retrieval failed. Crap.");
						return;
					}
					maximize("10 muscle, +shield, -familiar, outfit crappy mer-kin disguise", false);
				}
				else if (have_outfit("mer-kin gladiatorial gear"))
				{
					maximize("10 muscle, +shield, -familiar, outfit mer-kin gladiatorial gear", false);
				}
				else
				{
					maximize("10 muscle, +shield, -familiar, outfit crappy mer-kin disguise", false);
				}
				set_property("choiceAdventure701", "1");
				if (!have_outfit("mer-kin gladiatorial gear"))
				{
					foreach it,entry in maximize("10 muscle, +shield, -hat, -pants, -familiar, 1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
					foreach it,entry in maximize("10 muscle, +shield, -hat, -pants, -familiar, 1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
					if (available_amount($item[mer-kin gladiator mask]) < 1)
					{
						if (!obtain(1, $item[mer-kin headguard], $location[mer-kin gymnasium]))
						{
							print("You need a headguard for your mask. How can you headbutt without a headguard?");
							return;
						}
					}
					if (available_amount($item[mer-kin gladiator tailpiece]) < 1)
					{
						if (!obtain(1, $item[mer-kin thighguard], $location[mer-kin gymnasium]))
						{
							print("You need a thighguard for your tailpiece. Can't have it falling down. Or up.");
							return;
						}
					}
					getsome(1, $item[mer-kin gladiator mask]);
					getsome(1, $item[mer-kin gladiator tailpiece]);
					if (!have_outfit("mer-kin gladiatorial gear"))
					{
						print("You still don't look very fierce. Work on that.");
						return;
					}
					outfit("mer-kin gladiatorial gear");
				}
				if (!TS_GLADIATORS)
				{
					print("You have told the script to skip automation of the gladiators.");
					return;
				}
				if (available_amount($item[mer-kin dodgeball]) < 1 || available_amount($item[mer-kin dragnet]) < 1 || available_amount($item[mer-kin switchblade]) < 1)
				{
					foreach it,entry in maximize("10 muscle, +shield, -hat, -pants, -familiar, 1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
					foreach it,entry in maximize("10 muscle, +shield, -hat, -pants, -familiar, 1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
					if (!obtain(1, $item[mer-kin dodgeball], $location[mer-kin gymnasium]) ||
						!obtain(1, $item[mer-kin dragnet], $location[mer-kin gymnasium]) ||
						!obtain(1, $item[mer-kin switchblade], $location[mer-kin gymnasium]))
					{
						print("You need some more mer-weapons. How else are you going to fight?");
						return;
					}
				}
				item buffingitem;
				while (my_adventures() > 1 && get_property("gladiatorNetMovesKnown").to_int() < 3)
				{
					equip($item[Mer-kin dragnet]);
					foreach it,entry in maximize("10 muscle, -weapon, -familiar, outfit mer-kin gladiatorial gear, -1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
					foreach it,entry in maximize("10 muscle, -weapon, -familiar, outfit mer-kin gladiatorial gear, -1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
					while (buffed_hit_stat() < 750)
					{
						if (my_primestat() == $stat[muscle] && have_effect($effect[Stabilizing Oiliness]) < 1)
						{
							buffingitem = $item[oil of stability];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[mysticality] && have_effect($effect[Expert Oiliness]) < 1)
						{
							buffingitem = $item[oil of expertise];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[moxie] && have_effect($effect[Slippery Oiliness]) < 1)
						{
							buffingitem = $item[oil of slipperiness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Incredibly Hulking]) < 1)
						{
							buffingitem = $item[ferrigno's elixir of power];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Phorcefullness]) < 1)
						{
							buffingitem = $item[philter of phorce];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Gr8tness]) < 1)
						{
							buffingitem = $item[potion of temporary gr8tness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Tomato Power]) < 1)
						{
							buffingitem = $item[tomato juice of powerful power];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else
						{
							abort("We tried (and failed) to buff your "+current_hit_stat()+" to 750. Since we failed, we are aborting to let you decide how to continue.");
						}
					}
					if (have_effect($effect[ninja, please]) < 1)
					{
						use(1, $item[natto marble soda]);
					}
					if (have_effect($effect[nightstalkin']) < 1)
					{
						use(1, $item[Nightstalker perfume]);
					}
					adventure(1, $location[mer-kin gymnasium]);
				}
				while (my_adventures() > 1 && get_property("gladiatorBladeMovesKnown").to_int() < 3)
				{
					equip($item[Mer-kin switchblade]);
					foreach it,entry in maximize("10 muscle, -weapon, -familiar, outfit mer-kin gladiatorial gear, -1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
					foreach it,entry in maximize("10 muscle, -weapon, -familiar, outfit mer-kin gladiatorial gear, -1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
					while (buffed_hit_stat() < 750)
					{
						if (my_primestat() == $stat[muscle] && have_effect($effect[Stabilizing Oiliness]) < 1)
						{
							buffingitem = $item[oil of stability];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[mysticality] && have_effect($effect[Expert Oiliness]) < 1)
						{
							buffingitem = $item[oil of expertise];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[moxie] && have_effect($effect[Slippery Oiliness]) < 1)
						{
							buffingitem = $item[oil of slipperiness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Incredibly Hulking]) < 1)
						{
							buffingitem = $item[ferrigno's elixir of power];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Phorcefullness]) < 1)
						{
							buffingitem = $item[philter of phorce];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Gr8tness]) < 1)
						{
							buffingitem = $item[potion of temporary gr8tness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Tomato Power]) < 1)
						{
							buffingitem = $item[tomato juice of powerful power];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else
						{
							abort("We tried (and failed) to buff your "+current_hit_stat()+" to 750. Since we failed, we are aborting to let you decide how to continue.");
						}
					}
					if (have_effect($effect[ninja, please]) < 1)
					{
						use(1, $item[natto marble soda]);
					}
					if (have_effect($effect[nightstalkin']) < 1)
					{
						use(1, $item[Nightstalker perfume]);
					}
					adventure(1, $location[mer-kin gymnasium]);
				}
				while (my_adventures() > 1 && get_property("gladiatorBallMovesKnown").to_int() < 3)
				{
					equip($item[Mer-kin dodgeball]);
					foreach it,entry in maximize("10 moxie, -weapon, -familiar, outfit mer-kin gladiatorial gear, -1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.skill != $skill[none] && turns_per_cast(entry.skill) > 0) use_skill(max(1, ceil(my_adventures().to_float() / turns_per_cast(entry.skill))), entry.skill);
					foreach it,entry in maximize("10 moxie, -weapon, -familiar, outfit mer-kin gladiatorial gear, -1000 combat", 0, 0, false, false) if (entry.score >= 1000 && entry.command.index_of("uneffect ") == 0 && turns_per_cast(entry.effect.to_skill()) > 0) cli_execute(entry.command);
					while (buffed_hit_stat() < 750)
					{
						if (my_primestat() == $stat[muscle] && have_effect($effect[Stabilizing Oiliness]) < 1)
						{
							buffingitem = $item[oil of stability];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[mysticality] && have_effect($effect[Expert Oiliness]) < 1)
						{
							buffingitem = $item[oil of expertise];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[moxie] && have_effect($effect[Slippery Oiliness]) < 1)
						{
							buffingitem = $item[oil of slipperiness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Cock of the Walk]) < 1)
						{
							buffingitem = $item[connery's elixir of audacity];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Superhuman Sarcasm]) < 1)
						{
							buffingitem = $item[serum of sarcasm];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Gr8tness]) < 1)
						{
							buffingitem = $item[potion of temporary gr8tness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Tomato Power]) < 1)
						{
							buffingitem = $item[tomato juice of powerful power];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else
						{
							abort("We tried (and failed) to buff your "+current_hit_stat()+" to 750. Since we failed, we are aborting to let you decide how to continue.");
						}
					}
					if (have_effect($effect[ninja, please]) < 1)
					{
						use(1, $item[natto marble soda]);
					}
					if (have_effect($effect[nightstalkin']) < 1)
					{
						use(1, $item[Nightstalker perfume]);
					}
					adventure(1, $location[mer-kin gymnasium]);
				}
				int COLOSSEUM_ROUND = get_property("lastColosseumRoundWon").to_int();
				monster nextfight;
				while (my_adventures() > 1 && COLOSSEUM_ROUND < 15)
				{
					switch(COLOSSEUM_ROUND % 3)
					{
						case 0:
							equip($item[mer-kin dragnet]);
							maximize("10 muscle, moxie, -weapon, -familiar, outfit mer-kin gladiatorial gear", false);
							if (COLOSSEUM_ROUND < 12) nextfight = $monster[mer-kin balldodger];
							else nextfight = $monster[georgepaul, the balldodger];
							break;
						case 1:
							equip($item[mer-kin switchblade]);
							maximize("10 muscle, moxie, -weapon, -familiar, outfit mer-kin gladiatorial gear", false);
							if (COLOSSEUM_ROUND < 12) nextfight = $monster[mer-kin netdragger];
							else nextfight = $monster[johnringo, the netdragger];
							break;
						case 2:
							equip($item[mer-kin dodgeball]);
							maximize("10 moxie, -weapon, -familiar, outfit mer-kin gladiatorial gear", false);
							if (COLOSSEUM_ROUND < 12) nextfight = $monster[mer-kin bladeswitcher];
							else nextfight = $monster[ringogeorge, the bladeswitcher];
							break;
					}
					while (buffed_hit_stat() < nextfight.base_defense + 10)
					{
						if (current_hit_stat() == $stat[muscle])
						{
							if (my_primestat() == $stat[muscle] && have_effect($effect[Stabilizing Oiliness]) < 1)
							{
								buffingitem = $item[oil of stability];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (my_primestat() == $stat[mysticality] && have_effect($effect[Expert Oiliness]) < 1)
							{
								buffingitem = $item[oil of expertise];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (my_primestat() == $stat[moxie] && have_effect($effect[Slippery Oiliness]) < 1)
							{
								buffingitem = $item[oil of slipperiness];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Incredibly Hulking]) < 1)
							{
								buffingitem = $item[ferrigno's elixir of power];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Phorcefullness]) < 1)
							{
								buffingitem = $item[philter of phorce];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Gr8tness]) < 1)
							{
								buffingitem = $item[potion of temporary gr8tness];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Tomato Power]) < 1)
							{
								buffingitem = $item[tomato juice of powerful power];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else
							{
								abort("We tried (and failed) to buff your "+current_hit_stat()+" to "+(nextfight.base_defense + 10)+". Since we failed, we are aborting to let you decide how to continue.");
							}
						}
						else
						{
							if (my_primestat() == $stat[muscle] && have_effect($effect[Stabilizing Oiliness]) < 1)
							{
								buffingitem = $item[oil of stability];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (my_primestat() == $stat[mysticality] && have_effect($effect[Expert Oiliness]) < 1)
							{
								buffingitem = $item[oil of expertise];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (my_primestat() == $stat[moxie] && have_effect($effect[Slippery Oiliness]) < 1)
							{
								buffingitem = $item[oil of slipperiness];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Cock of the Walk]) < 1)
							{
								buffingitem = $item[connery's elixir of audacity];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Superhuman Sarcasm]) < 1)
							{
								buffingitem = $item[serum of sarcasm];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Gr8tness]) < 1)
							{
								buffingitem = $item[potion of temporary gr8tness];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else if (have_effect($effect[Tomato Power]) < 1)
							{
								buffingitem = $item[tomato juice of powerful power];
								if (item_amount(buffingitem) < 1) buy(1, buffingitem);
								use(1, buffingitem);
							}
							else
							{
								abort("We tried (and failed) to buff your "+current_hit_stat()+" to "+(nextfight.base_defense + 10)+". Since we failed, we are aborting to let you decide how to continue.");
							}
						}
					}
					while (my_buffedstat($stat[moxie]) < nextfight.base_attack + 10)
					{
						if (my_primestat() == $stat[muscle] && have_effect($effect[Stabilizing Oiliness]) < 1)
						{
							buffingitem = $item[oil of stability];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[mysticality] && have_effect($effect[Expert Oiliness]) < 1)
						{
							buffingitem = $item[oil of expertise];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (my_primestat() == $stat[moxie] && have_effect($effect[Slippery Oiliness]) < 1)
						{
							buffingitem = $item[oil of slipperiness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Cock of the Walk]) < 1)
						{
							buffingitem = $item[connery's elixir of audacity];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Superhuman Sarcasm]) < 1)
						{
							buffingitem = $item[serum of sarcasm];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Gr8tness]) < 1)
						{
							buffingitem = $item[potion of temporary gr8tness];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else if (have_effect($effect[Tomato Power]) < 1)
						{
							buffingitem = $item[tomato juice of powerful power];
							if (item_amount(buffingitem) < 1) buy(1, buffingitem);
							use(1, buffingitem);
						}
						else
						{
							abort("We tried (and failed) to buff your moxie to "+(nextfight.base_attack + 10)+". Since we failed, we are aborting to let you decide how to continue.");
						}
					}
					if (!adventure(1, $location[mer-kin colosseum]))
					{
						abort("You fought the monster "+nextfight+" and lost. Either re-run the script or try the fight yourself.");
					}
					COLOSSEUM_ROUND = get_property("lastColosseumRoundWon").to_int();
				}
				if (item_amount($item[crayon shavings]) < 4) buy(4 - item_amount($item[crayon shavings]), $item[crayon shavings]);
				print("Time for the boss fight! Make sure you remove any sources of elemental damage first.");
				break;
			case 2:
				if (!have_outfit("mer-kin scholar's vestment") && !have_outfit("crappy mer-kin disguise"))
				{
					print("Getting your crappy disguise together.");
					getsome(1, $item[crappy mer-kin mask]);
					getsome(1, $item[crappy mer-kin tailpiece]);
					if (!have_outfit("crappy mer-kin disguise"))
					{
						print("Crappy retrieval failed. Crap.");
						return;
					}
					outfit("crappy mer-kin disguise");
				}
				else if (have_outfit("mer-kin scholar's vestment"))
				{
					outfit("mer-kin scholar's vestment");
				}
				else
				{
					outfit("crappy mer-kin disguise");
				}
				getsome(1, $item[mer-kin bunwig]);
				set_property("choiceAdventure396", "3");
				set_property("choiceAdventure397", "2");
				set_property("choiceAdventure398", "1");
				set_property("choiceAdventure399", "1");
				set_property("choiceAdventure400", "1");
				set_property("choiceAdventure401", "2");
				set_property("choiceAdventure403", "2");
				set_property("choiceAdventure705", "4");
				if (!have_outfit("mer-kin scholar's vestment"))
				{
					if (available_amount($item[mer-kin scholar mask]) < 1)
					{
						if (!obtain(1, $item[mer-kin facecowl], $location[mer-kin elementary school]))
						{
							print("You need a cowl for your mask. Every good mask needs a cowl.");
							return;
						}
					}
					if (available_amount($item[mer-kin scholar tailpiece]) < 1)
					{
						if (!obtain(1, $item[mer-kin waistrope], $location[mer-kin elementary school]))
						{
							print("You need a waistrope for your tailpiece. Can't have it falling down. Or up.");
							return;
						}
					}
					getsome(1, $item[mer-kin scholar mask]);
					getsome(1, $item[mer-kin scholar tailpiece]);
					if (!have_outfit("mer-kin scholar's vestment"))
					{
						print("You still don't look very scholarly. Work on that.");
						return;
					}
					outfit("mer-kin scholar's vestment");
				}
				if (get_property("merkinVocabularyMastery").to_int() < 100)
				{
					int neededvocab = 10 - (get_property("merkinVocabularyMastery").to_int() / 10);
					obtain(neededvocab, $item[mer-kin cheatsheet], $location[mer-kin elementary school]);
					obtain(neededvocab, $item[mer-kin wordquiz], $location[mer-kin elementary school]);
					if (item_amount($item[mer-kin cheatsheet]) < neededvocab || item_amount($item[mer-kin wordquiz]) < neededvocab)
					{
						print("You failed to cheat well enough. Maybe you ran out of adventures?");
						return;
					}
					use(neededvocab, $item[mer-kin wordquiz]);
				}
				if (get_property("dreadScroll1") == "0" && item_amount($item[mer-kin dreadscroll]) < 1) obtain(1, $item[mer-kin dreadscroll], $location[mer-kin library]);
				if (get_property("dreadScroll1") == "0" && item_amount($item[mer-kin dreadscroll]) < 1)
				{
					print("No dread for you. Check your adventures?");
					return;
				}
				if (!have_skill($skill[deep dark visions]))
				{
					obtain(1, $item[mer-kin darkbook], $location[mer-kin library]);
					if (item_amount($item[mer-kin darkbook]) < 1)
					{
						print("You couldn't find the darkbook. Probably since you ran out of adventures.");
						return;
					}
					use(1, $item[mer-kin darkbook]);
				}
				if (get_property("dreadScroll4") == "0")
				{
					obtain(1, $item[mer-kin knucklebone], $location[mer-kin library]);
					use(1, $item[mer-kin knucklebone]);
				}
				if (!solveHatred(true))
				{
					print("No luck with figuring out the deepscroll. You'll probably need to figure out a few more steps yourself.");
					return;
				}
				prepHatred();
				smiteHatred();
				abort("Best of luck finishing off the fight!");
				break;
			case 3:
				break;
		}
	}
}

void SkateQuest()
{
	if (my_level() >= 13)
	{
		string seafloor = visit_url("seafloor.php");
		if (my_adventures() > 1 && !contains_text(seafloor,"skatepark.gif") && seafloor.contains_text("monkeycastle.gif") && !contains_text(visit_url("monkeycastle.php"),"\#littlebrother\""))
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
					adventure(my_adventures(), $location[An Octopus's Garden]);
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
		if (my_adventures() > 1 && TS_SKATE_QUEST < 4 && contains_text(seafloor,"skatepark.gif") && contains_text(visit_url("sea_skatepark.php"),"rumble_"))
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
			while (my_adventures() > 1 && TS_SKATE_QUEST < 3 && available_amount(neededweapon) < 1 && loopcounter < 5)
			{
				loopcounter += 1;
				obtain(1, "choiceadv", $location[The Skate Park]);
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
				while (my_adventures() > 1 && available_amount(neededweapon) < 1 && loopcounter < 5)
				{
					loopcounter += 1;
					obtain(1, neededweapon.to_string(), $location[The Skate Park]);
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
			while (my_adventures() > 1 && (contains_text(skatepark,"rumble_a.gif") || contains_text(skatepark,"rumble_b.gif")) && loopcounter < 5)
			{
				loopcounter += 1;
				obtain(1, "choiceadv", $location[The Skate Park]);
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
			else if (available_amount($item[damp old boot]) < 1 && my_adventures() > 1 && available_amount($item[sand dollar]) < 50 && contains_text(visit_url("seafloor.php"),"monkeycastle.gif") && !contains_text(visit_url("monkeycastle.php"),"\#littlebrother\""))
			{
				if (count(get_goals()) > 0)
				{
					cli_execute("conditions clear");
				}
				add_item_condition(50 - available_amount($item[sand dollar]), $item[sand dollar]);
				adventure(my_adventures(), $location[An Octopus's Garden]);
			}
			if (available_amount($item[sand dollar]) > 49 || available_amount($item[damp old boot]) > 0)
			{
				print("Buying the boot and collecting our well-earned reward.");
				if (available_amount($item[damp old boot]) < 1) create(1, $item[damp old boot]);
				visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman");
				switch(TS_BOOT_QUEST)
				{
					case 1:
						visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=3609");
						break;
					case 2:
						visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=6314");
						break;
					case 3:
						visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=6312");
						use(1, $item[crate of fish meat]);
						break;
					case 4:
						visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=6313");
						use(1, $item[damp old wallet]);
						break;
					case 5:
						if (available_amount($item[das boot]) < 1)
							visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=3609");
						else if (available_amount($item[fishy pipe]) < 1)
							visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=6314");
						else
						{
							visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=6312");
							use(1, $item[crate of fish meat]);
						}
						break;
					case 6:
						if (available_amount($item[das boot]) < 1)
							visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=3609");
						else if (available_amount($item[fishy pipe]) < 1)
							visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=6314");
						else
						{
							visit_url("place.php?whichplace=sea_oldman&action=oldman_oldman&preaction=pickreward&whichreward=6313");
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
		if (get_campground() contains $item[sushi-rolling mat])
		{
#			print("You already have a sushi mat.");
		}
		else if (to_int(vars["seafloor_monkeeStep"]) > 1)
		{
			print("You need 50 sand dollars to buy a sushi mat.");
			if (TS_GET_SUSHIMAT == 1 && available_amount($item[sushi-rolling mat]) < 1)
			{
				getsome(50, $item[sand dollar]);
			}
			else if (my_adventures() > 1 && available_amount($item[sand dollar]) < 50 && contains_text(visit_url("seafloor.php"),"monkeycastle.gif") && !contains_text(visit_url("monkeycastle.php"),"\#littlebrother\""))
			{
				if (count(get_goals()) > 0)
				{
					cli_execute("conditions clear");
				}
				add_item_condition(50 - available_amount($item[sand dollar]), $item[sand dollar]);
				adventure(my_adventures(), $location[An Octopus's Garden]);
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
		else if (available_amount($item[bubblin' stone]) < 1)
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
			else if (my_adventures() > 1 && available_amount($item[rusty diving helmet]) < 1)
			{
				if (count(get_goals()) > 0)
				{
					cli_execute("conditions clear");
				}
				add_item_condition(1, $item[rusty diving helmet]);
				if (TS_GET_HELMET == 3)
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
					while (my_adventures() > 1 && loopcounter < 15 && creatable_amount($item[rusty diving helmet]) < 1)
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
					adventure(my_adventures(), $location[The Wreck of the Edgar Fitzsimmons]);
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

void main()
{
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
		if (TS_OUTFIT_QUEST > 0) OutfitQuest();
		if (TS_BOOT_QUEST > 0) BootQuest();
		if (TS_GET_SUSHIMAT > 0) GetSushiMat();
		if (TS_GET_HELMET > 0) GetAeratedHelmet();
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
	}
}
