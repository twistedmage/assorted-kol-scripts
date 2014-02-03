/***********************************************************************************************************************
				
				This script evaluates and performs attacks based on your skills
			With thanks to Zarqon and Bumcheekcity for the code this is based on.
			
************************************************************************************************************************
	Version 1.0: Initial public release
			1.1: Change all printouts to WHAM
				 Lower the verbosity requirement for printing useful info
			1.2: Add has_happened() to work around happened() being off by one turn if SmartStasis ended the fight before we got there
			1.3: Remove has_happened and use round > maxround instead.
				 Make sure the script aborts if you acquire temporary amnesia.
				 Make sure we don't automate queued skills longer than the user specified maxround (defaults to 50)
			1.3.1: Do not crash becuse we miss a perenthesis...
			1.4: Set the unknown_ml for specific monsters in the Cyrpt in order to be able to handle
				 them sanely in case of high unknown_ml
			1.5: Make sure to reset the unknown_ml-value no matter how we exit the script (unless the user aborts manually)
				 You can always perform at least one attack/skill in a round, take advantage of this
				 Fix some cases of the script not exiting properly when a fight ended suddenly
				 Don't open the Bag O' Tricks since the script isn't aware that you can only use it once.
			1.6: Update to work with new version of BatBrain. Also fix some silly return values.
				 Small adjustments for Avatar of Boris
			1.7: Don't use attack if an Avatar of Boris, fix error in OK().
			1.8: Yet another adaptation to Batbrain changing
				 Start re-implementing HP/MP-restoring options
			1.9: Add some extra debug-printouts at verbosity 9
				 Add a new zlib-variable WHAM_AlwaysContinue, default to false, that will try and execute a 5-skill combo even if it won't kill the monster
				 Modify the useage of Broadside and Entangling Noodles as well as Intimidating Bellow to make them slightly less wasteful
			1.9.5: Fix the modifications for Broadside and Intimidating Bellow
			1.9.6: Don't try to use Mighty Axing as an attack if you have temporary amnesia				 
			2.0: Refactor code to use BatBrain predictive abilities and thereby also to use items and gain an enormous speed boost.	
				 Banish some foes in Boris-runs if we can
			2.0.1: Fix some small things, mainly with printouts
			2.0.2: Don't use Trusty-specific skills if you're not wielding Trusty and some other fixes to ok().
			2.0.3: Add missing ) and modify the attack-repeat-macro for a potential bug-fix
			2.1: Update to be up to date with latest SS also don't enqueue items as skills, it won't work.
			2.1.1: Add missing macro()-call from the SS-function
			2.2: Fix bug with using more items than we have (hopefully)
			2.3: Fix bug with failing to enqueue some things due to the script (and thus BatBrain) being out of sync with KoL
			2.4: Fix some bugs with attacking and hitchances
			2.5: Don't throw tower items at monsters (requires zlib version r36 or higher)
				 Fix bug for banishing monsters in Boris-core
				 Add logic to handle Bugbear-hunting and special killing
			2.6: Resolve infinite loop at low MP as well as crashing while trying to delevel
				 Set guestimates for unknown_ml for the new bugbear monsters
			2.7: Fix some Temporary Amnesia related bugs (due to not rebuilding options during a fight)
			2.8: Readd the WHAM_AlwaysContinue option as a way to tell if the script should try to fight as best as it can despite the odds
				 Remove will_attack() since attack is considered among the other options anyway and the hitchance is taken into account when setting up options
				 Significantly improve stunning logic
				 Create the quit()-function to collect all exiting into one place
				 Rudimentary handling of the Operation Patriot Shield
			2.8.1: Don't double-enqueue the stunning action
			2.8.2: Fix olfactioning of bugbear monsters
				 Fix some errors with predictions
				 Start reworking the predictions to soon be able to use MP/HP restorers
			2.8.3: DOn'tuse PADL-phones or Comunication Windchimes against trendy bugbear chefs
			2.9: Don't olfact bugberas if we don't need more of that type
				 Recalculate the killer option if we enqueue a stun
				 Exit correctly if we banish a clingy pirate
			3.0: Don't use pool torpedoes if not under water
				 Try to use another item if possible if we have funkslinging
				 Fix generation of debug files
			3.0.1: Only use the gnomitronic thingamabob if it can kill the monster
			3.0.5: Include the stun even if we are going to saucesplash
				   Goodfella contracts only work with a Penguin Goodfella active
			3.0.6: Lower some verbosities for better feedback at verbosity 3 when aborting
				   Fix bug where the script thought it was enqueueing a stun while it in fact wasn't
			3.1: Adapt script for changes in BatBrain 1.24
				 Due to popular demand, add option to skip items and rely only on skills
			3.1.1: Tighten up some code
				   Fix bug with WHAM_noitemsplease caused by extra semi-colon
			3.1.2: Fix another bug with WHAM_noitemsplease. Stupid thing...
				   Also fix a bug with items being used even though they shouldn't regardless of the setting
			3.2: Forbid reusage of items and skills that can only be used once, in case Batbrain for some reason doesn't
				 Don't stasis in the basement
				 Add support for users to exclude items or skills based on their own whish via th relay_WHAM_dontuse-script
				 Don't use Imp Airs and Bus Passes if the steel organ quest isn't finished
			3.3: Remove cludge to reset your hitchance for debug printing purposes by overloading allMyOptions instead
				 Increase the hitchance limit by 0.25 when fighting Dr. Awkward sice he makes you fumble
				 Make sure we abort if the unknown_ml-value is set to 0 (as is intended)
				 Fix bug with dont_use-items where it never used an item you accepted usage of above a certain limit
				 Redefine WHAM_maxround as number of turns to use after SS has finished
				 Refactor some code
			3.3.1: Fix stupid compile bug
			3.4: Make sure as many places as possible are under the control of dont_use and WHAM_noitemsplease
				 Fix bug that prevented correct usage of once per battle items and skills
			3.5: Add support for Smash&Graagh
			3.6: Modify the script some for bear-skills and zombies
				 Also, don't reuse once-items if we enqueue an item first
			3.6.1: Don't smash for things that cannot be pickpocketed
			3.7: Fix bug with Smash & Graaagh
				 Add WHAM_happymediumglow setting to control the happy medium siphoning skill
				 Attempt to allow for multi-usable items to be used more times than the amount of item we have
			3.7.1: Fix happy medium detection
			3.7.2: Fix for mafia updating Basement monster names
			3.8: Update to account for Mafia removing articles from some monster names
				 Transfer Stasis and Custom actions over to WHAM from SmartStasis to bring them under the control of WHAM_dontuse
			3.8.1: Fix for Repeating of bearskill during stasis
				   Fix for repeating once/battle options as stasis options
				   Fix for not using olfaction as a custom options
				   Merge special actions and custom options now that they are in the same script
				   Gather all pickpocket actions in the same place
			3.9: Allow once per battle actions as stasis options with new innovative code to handle the stasis loop
				 Fix bug with Consume Burrowgrub which can be used three times and no more per battle
			3.9.1: Fix multiusing of chefstaffs
			3.9.2: Stupid regexp...
			3.9.3: Fix pirate book not being used
				   Fix, hopefully, the remaining stasis bugs...
			4.0: Limit stasising with skills to the amount of turns of it we can actually cast
				 Limit Squeeze Stress Ball to five times per day and fix detection of chef-staff jiggling
			4.1: Times happened should include performed actions as well as enqueued ones.
				 Infect the opponent if the next skill is Plague Claws and we have no already infected
				 Add WHAM_safetymargin setting to control any extra safety margin (in rounds) you may want for the stasising
				 Do not use burrowgrub more than three times per day
			4.1.1: Add WHAM_safetymargin to one more place
			4.1.2: Modify the usage of WHAM_safetymargin slightly
				   Forbid usage of Richard's Hobopolis skills due to KoL-bug causing infite loops
			4.2: Update to be in line with the recent SmartStasis release
				 Fix a burrowgrub bug
			4.2.1: Fix bug where the script would ignore your WHAM_AlwaysContinue setting.
			4.3: Do not use combat items worth more than your autoBuyPriceLimit
				 Make the attacking part of the script adhere to WHAM_safetymargin as well and not just the stasising part
			4.3.1: Consider expensive reusable items as ok even if they cost above autoBuyPriceLimit
			4.3.2: Use Duskwalker syringes against oil-monsters
			4.3.3: Correctly insert infectious bite before plague claws
			4.3.4: Only infect if we can survive the onslaught afterwards
			4.3.5: Fix bugs with incorrect checks in ok()
				   Correctly abort for unknown monsters if your unknown_ml is 0
			4.3.6: Update to align with SmartStasis 3.17
				   Raise the verbosity for the chefstaff debug printout to 8
			4.3.7: Fix stuff not being as stuffy as they should be
			4.4: Fix possibly severe bug with stasising
			4.5: SS 3.18, BB 1.31.1 compatibility fixes (including removal of WHAM_happymediumglow)
			4.6: Start separating SS from WHAM again
				 Fix some bugs with Summon Burrowgrub and the Haiku Katana
			4.6.1: Fix Haiku Katana fully
			4.7: Adapt for Jarlsberg
				 Refactor some code
				 Fix bug (hopefully) with under-stunning due to overly optimistic spells
			4.7.1: Fix stun-code to work with all elements, not just those with a colour.
				   Do not return the gnomitronic thingamabob if you cannot use it
			4.7.2: Fix version number being off
			4.8: Add workaround for attack_option going blank if called after a stun_option has been enqueued
			4.8.1: Don't use duskwalker syringes if it will kill us
			4.8.2: Fix detection of don't-use-maps if the new format is being used
				   Fix jarlsberg jiggling of limited staffs, also add banishing for Jarlsberg
				   Don't loop eternally when verbosity > 9 and a valid combat strategy is unable to be found
			4.9: Update to be on par with the new BatBrain
				 Fix some small issues with the ok()-function
				 Don't stun with 1-round stunners unless we have funkslinging and is stunning for an item
			5.0: Fix stunning bug to correctly take monster resistance into account
			5.1: Modify the usage of Staff of the All-Steak, Staff of the Staff of life and start using the cream staff to olfact monsters
			5.2: Don't abort for no apparent reason just because BatBrain says we can't continue, execute the plan instead
			5.3: Remove fix for endscombat now that BatBrain allows up to three actions after an endscombat flag has been set
				 If we plan to saucesplash don't bother finding other options first; significant speed boost
				 You can only jiggle once per combat
				 Add zlib setting WHAM_UseSeaLasso to toggle use of the Sea Lasso
			5.4: Make use of Mafia's seaLasso-tracking to decide when to stop throwing sea lassos
				 Add option to toggle speed to kill as the most important factor (will ignore any savings that a "smarter" attack method may have), WHAM_killit
				 Don't get stuck in endless loops for deleveling, also make sure to actually perform the deleveling decided upon
			5.5: Fix bug where the script would abort due to no actions found after BatBrain sets endscombat to true
		13-06-10:Try to not fire the yellow ray unless we actually want the drops
				 Force WHAM_killit to true if we are in Fernswarthy's Basement
				 Add code to handle automating Yog-Urt and Jigguwatt
		13-06-14:Don't try to stasis for so long that we cannot afford to kill the monster
		13-06-15:FIx to_int-problem for the new stasis check x 2
		13-06-21:Attempt to stasis with attack if we can hit, have a chance to crit and have one of the weapons for the Gladiator path equipped
				 Skip custom options in our various _option functions since BatBrain will allow them in opts soon
				 Add two new zlib-settings that control how much we are willing to pay to save a combat round, WHAM_roundcost_aftercore and WHAM_roundcost_ronin.
				 Also, add that value to the stasis-property so that the higher roundcost-value we have, the more valuable an action need to be to be used in stasis
				 Also, also, skip funkslinging if we either cannot find a second item to sling or said roundcost value is high enough that it is deemed unprofitable
		13-06-28:Specifically disallow useage of frosty's iceball until it can be figured out why it keeps using it
		13-06-27:Use the special skills in the Suburbs of Dis.
				 Try to handle the special bosses in the Suburbs areas
		13-06-29:Attempt to abort stasising when we learn the last skill for the gladiator weapons, will still try to stasis even if you already know all skills
				 Only do Gladiator training if the required skills are not known yet
		13-07-01:Fix WHAM_round to actually add the wanted thing and not just bulid an ever larger string and fix some to_int problems
		13-07-05:Fix warnings for incorrect typed constants
				 Move removing of custom options to ok()
				 Make the learning of Gladiator skills better by using Mafia's tracking
				 Minor code refactoring for better readability
		13-08-19:Fix BatBrain breakage
		13-08-20:Always attempt to stun if my_location().kisses > 1
		13-08-21:Fix removal of items for notiemsplease
				 Use BatBrain's new custom_action-function
		13-08-22:Fix item removal fully by reverting to the really old method...
				 Print items when debug printing, but mark them red since they are disallowed
		13-08-25:Try to blacklist KOHLS-combat items
		13-09-03:Attempt to abort when we tame a sea horse
		13-10-22:Add basic handling of Procedurally Generated Skeletons as well as Video Game bosses.
				 Don't use Noodles to stun with the revamped classes. It won't work.	
		13-11-09:Try to steal accordions if we can. RFemove more classes from noodling.
		13-11-10:Fix steal accordion and remove most of the special handling for procedural skeletons
		13-11-21:Throw Pocket Crumbs at opponents because why not?
		13-11-28:WHen using Drunkula's Wineglass anything but attack is futile
		13-11-29:Remove code for saucesplashing as that is no longer a thing
				 Entangling Noodles are only useful for Pastamancers, adapt stunning logic for the new class specific stun skills		
		14-02-01:Ban windchimes and PADL phones against Trendy Bugbear Chefs
***********************************************************************************************************************/
import <SmartStasis.ash>;

setvar("WHAM_round_limit", 15);	//Sets the amount of rounds the script should try to automate before executing its predictions
setvar("WHAM_hitchance", 0.5);	//Fraction of a chance to hit the monster with something for it to be considered
setvar("WHAM_maxround", 30);	//What turn do we want the script to stop fighting by
setvar("WHAM_AlwaysContinue", false);	//If true, will enqueue the best option and execute that to see if that opens up any new
										//options and so on until either the monster dies or you do
setvar("WHAM_noitemsplease", false);	//If true will cause the script to skip all items when fighting										
setvar("WHAM_safetymargin", 0);			//Sets the extra safety margin you want for rounds that the script will not stasis for
setvar("WHAM_UseSeaLasso", false);		//If true will use the sea lasso in the sea to train the lasso skill, does not currently know when to stop doing this
setvar("WHAM_killit", false);			//If true will attack the monster with your most powerful option, ignoring cost
setvar("WHAM_roundcost_aftercore", 50);	//Controls how much you are prepared to pay to save a round in fights in aftercore
setvar("WHAM_roundcost_ronin", 5);		//Controls how much you are prepared to pay to save a round in fights in ronin

record actions
{
	float hp;			//Monster HP an action
	float my_hp;		//My HP after an action
	float profit;		//The cost of the combination of actions that leads to hp monster HP
	string options;		//A list of the options to be used
};

record useskill
{
	int index;
	int profit;
};

//Global variables
advevent[int] myoptions;
advevent[int] restoration;
advevent stun; //Globally declared to be usable when enqueueing for real
advevent smacks;
actions[int] kill_it;
string[int] iterateoptions;
int WHAM_maxround = to_int(vars["WHAM_maxround"]);
int unknown_ml = to_int(vars["unknown_ml"]);
float hitchance = to_float(vars["WHAM_hitchance"]);
int WHAM_safetymargin = to_int(vars["WHAM_safetymargin"]);
int WHAM_roundcost_aftercore = to_int(vars["WHAM_roundcost_aftercore"]);
int WHAM_roundcost_ronin = to_int(vars["WHAM_roundcost_ronin"]);

//Load the map of items and skills to not use from the file
record dontuse
{
	string type;
	string id;
	int amount;
};
dontuse[int] not_ok;
file_to_map("WHAM_dontuse_" + my_name() + ".txt", not_ok);
if(count(not_ok) > 0)	vprint("WHAM: You should rebuild your dont_use-map with the updated relay script", 0);

//Copy actionss
actions[int] Copy_Actions(actions[int] orig) {
	actions[int] copy;
	
	for index from 0 to count(orig) - 1 {
		copy[index].hp = orig[index].hp;
		copy[index].my_hp = orig[index].my_hp;
		copy[index].profit = orig[index].profit;
		copy[index].options = orig[index].options;
	}
	return copy;
}

string spread_to_string(spread input) {
	float output;
	foreach el in $elements[]
		output = output + input[el];
	return to_string(output + input[$element[none]], "%.2f");
}	

//Quit the script and print information to the CLI/Relay browser
void quit(string input) {
	//Reset unknown_ml in case we changed it
	if(vars["unknown_ml"] != unknown_ml) {
		vars["unknown_ml"] = unknown_ml;
		updatevars();
	}
	input = "WHAM: " + input;
	//Print information to the Relay Browser
	page = visit_url("fight.php?action=macro&macrotext=abort \"" + input + "\"");
	//Print information to the gCLI and abort
	vprint(input, 0);
}

//Set unknown_ml for a couple of semi-spaded monsters not yet in Mafia
void pre_brain(monster foe, string pg) {
	havemanuel = contains_text(pg,"var monsterstats");
	if(to_int(vars["unknown_ml"]) != 0) {
		vprint("WHAM: Checking to see if WHAM sould adjust the unknown_ml for " + foe + ".", "purple", 8);
		switch (to_string(foe)) {
			default:	vprint("WHAM: No need to do anything with " + foe + ".", "purple", 8);
		}
	} else if(!havemanuel && (foe.raw_hp == -1 || foe.raw_attack == -1 || foe.raw_defense == -1))
		quit("Your unknown_ml is set to 0, handle this unkown monster yourself.");
	if($monsters[Beast with X Ears, Beast with X Eyes, Ghost of Fernswarthy's Grandfather, X Bottles of Beer on a Golem, X Stone Golem, X-dimensional Horror, X-headed Hydra] contains foe)
		set_location($location[Fernswarthy's Basement]);
	if(my_path() == "KOLHS")
		foreach i in $ints[6653,6656,6370,6374,6379,6382,6384,6385,6387]
			blacklist["use "+i] = 0;
	if(foe == $monster[Trendy Bugbear Chef]) {
		blacklist["use "+2065] = 0;
		blacklist["use "+2354] = 0;
	}
}

//Set information for the procedurally generated skeletons
void set_skeleton_info() {
	if(contains_text(to_string(last_monster()), "vicious")) {
		vprint("WHAM: Vicious skeletons deal bonus damage. Currently not handled.", "green", 5);
		//Vicious ones deal bonus damage (500 at 1100 monster attack, compared to a deadly doing ~90 damage at 1600 monster attack). 
	}
}

//Set information for the procedurally generated skeletons
void set_gameinformboss_info() {
	switch(get_property("gameProBossSpecialPower")) {
		case "Cold immunity":
			vprint("WHAM: This boss is immune to cold damage.", "green", 5);		
			mres[$element[cold]] = 1;
			break;
		case "Cold aura":
			vprint("WHAM: This boss has a cold aura that does 5-10 damage per turn.", "green", 5);		
			//res0.pdmg[$element[cold]] += 7;
			break;
		case "Hot immunity":
			vprint("WHAM: This boss is immune to hot damage.", "green", 5);		
			mres[$element[hot]] = 1;
			break;
		case "Hot aura":
			vprint("WHAM: This boss has a hot aura that does 5-10 damage per turn.", "green", 5);		
			//res.pdmg[$element[hot]] += 7;		
			break;		
		case "Ignores armor":
			vprint("WHAM: This boss is ignores some of your armor.", "green", 5);	
			break;		
		case "Blocks combat items":
			vprint("WHAM: This boss is blocks items.", "green", 5);
			noitems = 100;
			break;		
		case "Reduced physical damage":
			vprint("WHAM: This boss is resistant to physical damage.", "green", 5);		
			mres[$element[none]] = 0.5;		
			break;
		case "Reduced damage from spells":
			vprint("WHAM: This boss is takes 30% less damage from spells.", "green", 5);	
			break;
		case "Stun resistance":
			vprint("WHAM: This boss is cannot be stunned.", "green", 5);
			nostun = true;
			break;
		case "Elemental Reistance":
			vprint("WHAM: This boss is resistant to elemental damage.", "green", 5);
			foreach el in $elements[]
				mres[el] = 0.3;		
			break;
		case "Passive damage":
			vprint("WHAM: This boss deals physical damage when attacked with melee weapons.", "green", 5);	
			break;
	}
	build_options();
}
    
//Calculate number of bees if needed
int bees(monster foe) {
	int bees;
	if(my_path() == "Bees Hate You") {
		for i from 0 to length(to_string(foe)) -1 {
			if(char_at(to_lower_case(to_string(foe)),i) == "b")
				bees = bees + 1;
		}
	}
	return bees;
}

//Chose HP and MP restore options
advevent mp_option(int target) {
	if (my_stat("mp") >= target)
		return new advevent;
	sort opts by -to_profit(value);
	foreach i,opt in opts {
		if (opt.custom != "")
			continue;
		if (opt.mp <= 0)
			continue;
		if (opt.mp + my_stat("mp") >= target) {
			vprint("WHAM: Your most profitable mp-restoring option is " + opt.id + ".", "purple", 9);
			return opt;
		}
	}
	return new advevent;
}

advevent hp_option(int target) {
	if (my_stat("hp") >= target)
		return new advevent;
	sort opts by -to_profit(value);
	foreach i,opt in opts {
		if (opt.custom != "")
			continue;	
		if (dmg_taken(opt.pdmg) >= 0) //Negative pdmg = healing item
			continue;
		if (-dmg_taken(opt.pdmg) + my_stat("hp") >= target && -dmg_taken(opt.pdmg) > m_dpr(0,0)) {
			vprint("WHAM: Your most profitable healing option is " + opt.id + ".", "purple", 9);
			return opt;
		}
	}
	return new advevent;
}

//Creates a call to check specific things that batround doesn't do.
void WHAM_round(string extra) {
	//Don't try to automate longer than the sepcified turnround
	batround_insert = " if pastround " + (WHAM_maxround - 1) + "; abort \"Stopping fight because it has gone on for too long (set WHAM_maxround to a higher value if you think this was in error)\"; endif; " + extra;
	vprint("WHAM: WHAM added the following to BatRound: " + batround_insert,9);
}

//Count happenings to avoid items that have already been enqueued as many as we have
int times_happened(string occurrence) {
	if (count(happenings) == 0)
		file_to_map("happenings_"+replace_string(my_name()," ","_")+".txt",happenings);
	if (happenings contains occurrence && happenings[occurrence].turn == turncount)
		return happenings[occurrence].queued + happenings[occurrence].done;
	return 0;
}

//Function to return skills and items that are usable
boolean ok(advevent a) {
	boolean no_cunctatitis() {
		return m != $monster[Procrastination Giant] || weapon_type(equipped_item($slot[weapon])) == $stat[Moxie];
	}
	
	boolean no_teleportitis() {
		return m != $monster[x-dimensional horror] && !contains_text(to_lower_case(to_string(m)), "quantum");
	}
	
	boolean no_bears() {
		return !(happened("skill 7131") || happened("skill 7132") || happened("skill 7133") || happened("skill 7134") || happened("skill 7135") || happened("skill 7136"));
	}
	
	//If we don't want to use items, remove them from the consideration as this speeds the script up
	if(vars["WHAM_noitemsplease"] == "true" && contains_text(a.id, "use"))
		return false;
	
	if(m == $monster[Naughty Sorority Nurse] && (dmg_dealt(a.dmg) + (m_hit_chance()*dmg_dealt(retal.dmg) + dmg_dealt(baseround().dmg))) < min(monster_stat("hp"), 90)) {
		vprint(a.id + " is not OK since the monster heals more than it damages.", "purple", 9);
		return false;	//These monsters heal too much for this skill
	}
	
	if(contains_text(to_string(m), "shiny") && contains_text(a.id, "skill") && is_spell(to_skill(to_int(excise(a.id,"skill ",""))))) {
		vprint(a.id + " is not ok since this skeleton blocks spells.", "purple", 9);
		return false;
	}
	
	//Drunkula's Wineglass prohibits use of skills, items and spells
	if(equipped_item($slot[off-hand]) == $item[drunkula's wineglass] && a.id != "attack")
		return false;
	
	if(a.pdmg[$element[none]] > my_stat("hp")) {
		vprint(a.id + " is not OK since it will hurt you more than the monster.", "purple", 9);
		return false;	//Don't use something that would kill us
	}
	
	if(a.custom != "") {	//Custom actions are per definition not ok unless specifically called
		vprint(a.id + " is not OK since it is marked as a custom action.", "purple", 9);
		return false;
	}
	
	matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",a.id);
	
	if(aid.find()) {
		switch(aid.group(1)) {
			case "use ":	//If the user doesn't want WHAM to use items, don't
				if(historical_price(to_item(to_int(aid.group(2)))) > to_int(get_property("autoBuyPriceLimit")) && to_item(aid.group(2)).reusable == false)
					return false;
				break;
			case "skill ":
				if (abs(a.mp) > my_stat("mp")) //We don't have enough MP for this skill
					return false;
				break;
			case "jiggle":
				if (happened("jiggle") || happened("chefstaff"))
					return false;
				break;
		}
		
		switch(aid.group(1)+aid.group(2)) {
			case "use 2848":	//Gnomitronic thingamabob
				return (item_amount($item[gnomitronic hyperspatial demodulizer]) > 0 && !happened($item[gnomitronic hyperspatial demodulizer]));
			case "use 3391":	//Frosty's Iceball, should not be used but is anyway so disallow it
				return false;
			case "skill 66": //Flying Fire Fist
				if (have_effect($effect[Salamanderenity]) == 0)
					return true;
				foreach i in tower_items(true) {
					if (item_amount(i) == 0)
						return false;
				}
				return true; 
			case "skill 1003": //Thrust-Smack
			case "skill 1004": //Lunge-Smack
			case "skill 1005": //Lunging Thrust-Smack
			case "skill 2003": //Headbutt
			case "skill 2015": //Kneebutt
			case "skill 2103": //Head + Knee Combo
			case "skill 2005": //Shieldbutt
			case "skill 2105": //Head + Shield Combo
			case "skill 2106": //Knee + Shield Combo
			case "skill 2107": //Head + Knee + Shield Combo
			case "skill 11000": //Mighty Axing 
			case "skill 11001": //Cleave
			case "skill 12010":	//Ravenous Pounce
			case "skill 12011":	//Distracting Minion			
				return (no_cunctatitis() && no_teleportitis());
			case "skill 1023": //Harpoon!
				return no_cunctatitis();				
			case "skill 7061":	//Spring Raindrop Attack
			case "skill 7062":	//Summer Siesta
			case "skill 7063":	//Falling Leaf Whirlwind
			case "skill 7064":	//Winter's Bite Technique
				return ((equipped_amount($item[haiku katana]) - (times_happened("skill 7061") + times_happened("skill 7062") + times_happened("skill 7063") + times_happened("skill 7064"))) > 0);
			case "skill 7082":	//Major and minor He-Boulder rays
				return spread_to_string(a.dmg) != to_string(monster_stat("hp") * 6);
			case "skill 7131":
			case "skill 7132":
			case "skill 7133":
			case "skill 7134":
			case "skill 7136":
				if(!no_bears())
					return false; //Don't try multiple bear skills in one combat
			case "skill 7135":	//Bear Hug should only be used against plural monsters if you are a zombie slayer
				if (my_path() == "Zombie Slayer" && howmanyfoes > 1 && no_bears()) return true;
				else if (my_path() != "Zombie Slayer" && no_bears()) return true;
				else return false;
			case "jiggle":
				if (equipped_item($slot[weapon]) == $item[Staff of the Staff of Life] &&  to_int(get_property("_jiggleLife")) < 5)
					return to_float(my_stat("hp")) / my_maxhp() < 0.4;
				else if (equipped_item($slot[weapon]) == $item[Staff of the All-Steak] && to_int(get_property("_jiggleSteak")) < 5) {
					int[item] drops = item_drops(m);
					foreach it in drops
						if ((is_goal(it) && drops[it] < 15 && has_goal(m) > 0 && has_goal(m) < 50) || (contains_text(to_lower_case(to_string(m)), "filthworm") && m != $monster[Queen Filthworm]))
							return true;
					return false;
				} else
					return true;					
			case "attack":
				return ((my_path() != "Avatar of Boris" && no_cunctatitis() && no_teleportitis()) ||
						(my_path() == "Avatar of Boris" && (!have_equipped($item[Trusty]) && no_cunctatitis() && no_teleportitis()) || (contains_text(to_string(m),"Naughty Sorceress") || m == $monster[Bonerdagon] || have_effect($effect[temporary amnesia]) > 0)));
        }
		return true;
	}
	return false;
}

boolean ok(string event) {
	return ok(to_event(event, "", 0));
}

//Check for the skills included in calculations
void allMyOptions(float hitlimit) {
	int n = 0;
	clear(iterateoptions);
	clear(myoptions);
	if(m == $monster[dr. awkward] && hitlimit != -1)
		hitlimit = min(1, hitlimit + 0.25);
	sort opts by -to_profit(value);
	sort opts by kill_rounds(value.dmg)*-(min(value.profit,-1));
	foreach i,opt in opts {
		vprint("WHAM: Currently checking " + (contains_text(opt.id, "skill") ? to_string(to_skill(to_int(excise(opt.id,"skill ","")))) : to_string(to_item(to_int(excise(opt.id,"use ",""))))) + " which has a reported damage of " + dmg_dealt(opt.dmg) + " and is " + (ok(opt) ? "ok." : "not ok."), "blue", 11);
		if(dmg_dealt(opt.dmg) > 0) {
			vprint("WHAM: Raw damage is estimated at " + opt.dmg[$element[cold]] + " (cold), " + opt.dmg[$element[hot]] + " (hot), " + opt.dmg[$element[stench]]+ " (stench), " + opt.dmg[$element[spooky]] + " (spooky), " + opt.dmg[$element[sleaze]] + " (sleazy) and  " + opt.dmg[$element[none]] + " (physical).", "purple", 11);
		}

		if (((hitlimit != -1 ? ok(opt) : true) && hitchance(opt.id) >= hitlimit) || opt.custom != "") {
			iterateoptions[count(iterateoptions)] = opt.id;
			myoptions[n] = opt;
			n += 1;
		}
	}
}

void allMyOptions() {
	allMyOptions(0);
}

boolean has_option(string whichid) {
	foreach i,opt in myoptions {
		if (opt.id == whichid)
			return true;
	}
	return false;
}

boolean has_option(skill whichskill) {
	foreach i,opt in myoptions {
		if(has_option(get_action(whichskill).id))
			return true;
	}
	return false;
}

boolean train_skills() {
	if(my_location().zone == "The Sea" && hitchance("attack") > hitchance && critchance() > 0) {
		if(equipped_item($slot[weapon]) == $item[Mer-kin dragnet] && to_int(get_property("gladiatorNetMovesKnown")) < 3)
			return true;
		if(equipped_item($slot[weapon]) == $item[Mer-kin switchblade] && to_int(get_property("gladiatorBladeMovesKnown")) < 3)
			return true;
		if(equipped_item($slot[weapon]) == $item[Mer-kin dodgeball] && to_int(get_property("gladiatorBallMovesKnown")) < 3)
			return true;
	}
	return false;
}

advevent attack_option(boolean noitems) {
	if (ok(get_action("use 2848")) && !happened($item[gnomitronic hyperspatial demodulizer]) && monster_stat("hp") <= dmg_dealt(get_action("use 2848").dmg))
		return get_action("use 2848");
		
	float drnd = max(1.0,die_rounds());   // a little extra pessimistic
	sort opts by -dmg_dealt(value.dmg);
	sort opts by -to_profit(value);
	sort opts by kill_rounds(value.dmg)* -(min(value.profit-(can_interact() ? WHAM_roundcost_aftercore : WHAM_roundcost_ronin),-1));
	
	foreach i,opt in opts {
		vprint(opt.id + " does hurt the monster for " + dmg_dealt(opt.dmg) + " and is " + (ok(opt) ? "ok." : "not ok."), "green", 10);
		if(opt.endscombat == true && !(contains_text(opt.id, "use") && vars["WHAM_noitemsplease"] == "true") && ok(opt)) {	//If the action is marked as a combat ender it is an ok action no matter what things say further down
			smacks = opt;
			return opt;
		}

		//Skip options that are indicated as not ok
		if(!ok(opt)) {
			vprint("Skipping " + opt.id + " since it is not ok.", "purple", 9);
			continue;
		}
		//Don't choose options if the hitchance is less than the wanted
		if (hitchance(opt.id) < hitchance) {
			vprint("Skipping " + opt.id + " since the hitchance is too low.", "purple", 9);
			continue;
		}
		//Reduce RNG risk for stasisy actions
		if (kill_rounds(opt.dmg) > min(min(maxround, WHAM_maxround) - round - 1,drnd)) {
			vprint("Skipping " + opt.id + " since it is too risky.", "purple", 9);
			continue;
		}
		 //Don't choose actions worse than fleeing
		 if (opt.stun < 1 && to_profit(opt) < -runaway_cost()) {
			vprint("Skipping " + opt.id + " since it is worse than fleeing.", "purple", 9);
			continue;
		}
		//Don't attempt to overstay our welcome
		if(kill_rounds(opt.dmg) + round + WHAM_safetymargin > maxround)	{
			vprint("Skipping " + opt.id + " since it is will take too long to kill the monster.", "purple", 9);
			continue;
		}
		 //Ignore skills and items that do not hurt the monster
		 if(dmg_dealt(opt.dmg) <= 0)	{
			vprint("Skipping " + opt.id + " since it doesn't hurt the monster.", "purple", 9);
			continue;
		}
		//We don't rebuild opts while looping (for speed issues), so skip skills we cannot afford
		if(opt.mp < 0 && my_stat("mp") < abs(opt.mp)) {	
			vprint("Skipping " + opt.id + " since the MP-cost is too high.", "purple", 9);
			continue;
		}
		//WE don't want to use items so skip them
		if(noitems && contains_text(opt.id, "use")) {
			vprint("Skipping " + opt.id + " since items are dissallowed.", "purple", 9);
			continue;
		}
		vprint("WHAM: Attack option chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(to_profit(opt))+")", "purple", 8);
		smacks = opt;
		return opt;
	}
	vprint("WHAM: No valid attack options (Best option, '"+opts[0].id+"', not good enough)", "purple", 8);
	return new advevent;
}

advevent attack_option() {
	return attack_option(false);
}

//Delevel the monster so we can hit it
advevent delevel_option(boolean nodmg) {
	sort opts by -to_profit(value);
	sort opts by value.att*-(min(value.profit,-1));		
	foreach i,opt in opts {
		if(nodmg && dmg_dealt(opt.dmg) != 0)
			continue;
		if(!ok(opt))
			continue;			
		if(opt.att < 0) {
			vprint("WHAM: Your most profitable deleveling option is " + opt.id + ".", "purple", 8);
			return opt;
		}
	}
	return new advevent;
}

advevent item_option() {
	if (ok(get_action("use 2848")) && !happened($item[gnomitronic hyperspatial demodulizer]) && monster_stat("hp") <= dmg_dealt(get_action("use 2848").dmg))
		return get_action("use 2848");
	float drnd = max(1.0,die_rounds());   // a little extra pessimistic
	//sort opts by -dmg_dealt(value.dmg);	
	sort opts by -to_profit(value);
	sort opts by kill_rounds(value.dmg)*-(min(value.profit,-1));
	foreach i,opt in opts {
		if(!ok(opt))
			continue;
		if(!contains_text(opt.id, "use"))
			continue; //Ignore skills (only looking at items for this one)
		if(hitchance(opt.id) < hitchance)
			continue;			
		if(kill_rounds(opt.dmg) > min(min(maxround, WHAM_maxround) - round - 1,drnd))
			continue;   // reduce RNG risk for stasisy actions
		if(opt.stun < 1 && to_profit(opt) < -runaway_cost())
			continue;  // don't choose actions worse than fleeing
		vprint("WHAM: Item option chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(to_profit(opt))+")", "purple", 8);
		return opt;
	}
	vprint("WHAM: No valid items.", "purple", 8);
	return new advevent;
}

advevent stasis_option() {  // returns most profitable lowest-damage option
	boolean ignoredelevel = (smacks.id != "" && kill_rounds(smacks.dmg) == 1);

	if (train_skills()) {
		WHAM_round("if match " + (equipped_item($slot[weapon]) == $item[Mer-kin dragnet] ? "\"New Special Move Unlocked: Net Neutrality\"" : (equipped_item($slot[weapon]) == $item[Mer-kin switchblade] ? "\"New Special Move Unlocked: Blade Runner\"" : "\"New Special Move Unlocked: Ball Sack\"")) + "; abort \"BatBrain abort: loogie.\"; endif; ");
		plink = get_action("attack");
		return plink;
	}

	sort opts by -to_profit(value,ignoredelevel);
	sort opts by -min(kill_rounds(value),max(0,maxround - round - (5 + WHAM_safetymargin)));	
	foreach i,opt in opts {  // skip multistuns and non-multi-usable items
		if(!ok(opt))
			continue;
		if(hitchance(opt.id) < hitchance)
			continue;
		if(opt.stun > 1 || (contains_text(opt.id,"use ") && !to_item(excise(opt.id,"use ","")).reusable))
			continue;
		vprint("WHAM: Stasis option chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(opt.profit)+")",8);
		plink = opt;
		return opt;
	}
	plink = new advevent;
	return new advevent;
}

// returns cheapest multi-round stun
advevent stun_option(float rounds, boolean foritem) {
	if(my_location().kisses <= 1 && (rounds < 0.90 || die_rounds() > maxround - round || monster_stat("hp") <= 10)) { //Don't stun if we will kill it directly (add a ~10% buffer for swingy actions)
		vprint("WHAM: No need to stun this monster", "purple", 8);													  //Always attempt to stun if kisses is larger than 1
		buytime = new advevent;
		return buytime;
	}
	
	if (smacks.id == "")
		attack_option();
	sort opts by -(to_profit(value)+meatperhp*m_dpr(-adj.att,0)*min(rounds+count(custom), value.stun - 1));
	foreach i,opt in opts {
		if(!ok(opt))
			continue;
		if (opt.stun < (foritem && have_skill($skill[ambidextrous funkslinging]) && contains_text(opt.id, "use") ? 1 : 2))
			continue;
		if (hitchance(opt.id) < hitchance)
			continue;
		if (opt.id == "skill 3004" && my_class() != $class[pastamancer])
			continue;
		if (opt.id == "skill 1033" && my_class() != $class[seal clubber])
			continue;
		vprint("WHAM: Stun option chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(opt.profit)+")",8);
		buytime = opt;
		return opt;
	}
	buytime = new advevent;
	vprint("WHAM: No profitable stun option", "purple", 8);
	return buytime;
}

//Calculate options for all available spells, take damage from familiars, equipments and other sources into account
actions[int] Calculate_Options(float base_hp) {
	int i = 0;
	int starttime = gametime_to_int();
	advevent killer, delevel, hpopt, mpopt;
	actions[int] sorted_kill;
	boolean stun_enqueued, funking;
	float dam;
	
	killer = attack_option();
	foreach ele in $elements[] {
		dam = dam + killer.dmg[ele] * (mres[ele] == -1 ? 2 : (mres[ele] == 0 ? 1 : 0));
	}
	dam = dam + killer.dmg[$element[none]] * (mres[$element[none]] == -1 ? 2 : (mres[$element[none]] == 0 ? 1 : 0));
	stun = stun_option(to_float(monster_stat("hp")) / max(dam,0.0001), contains_text(killer.id, "use"));
	vprint("Monster HP is " + monster_hp() + " according to Mafia and " + monster_stat("hp") + " according to BatBrain.", 9);
	
	if(have_equipped($item[operation patriot shield]) && happened($skill[throw shield]) && !happened("shieldcrit")) {
		if(stun.id != "" && contains_text(stun.id, "skill")) {
			enqueue(stun);
			kill_it[i].hp = monster_stat("hp");
			kill_it[i].my_hp = my_stat("hp");
			kill_it[i].profit = (i == 0 ? get_action(stun).profit : kill_it[i-1].profit + get_action(stun).profit);
			kill_it[i].options = stun.id;	
		} else {
			enqueue(killer);
			kill_it[i].hp = monster_stat("hp");
			kill_it[i].my_hp = my_stat("hp");
			kill_it[i].profit = (i == 0 ? get_action(killer).profit : kill_it[i-1].profit + get_action(killer).profit);
			kill_it[i].options = killer.id;	
		}
	} else {
		while(monster_stat("hp") > 0) {
			vprint("WHAM: We estimate the round number to currently be " + round + " (loop variable " + i + ")", "purple", 9);
			if(stun.id != "" && !stun_enqueued) {
				enqueue(stun);
				kill_it[i].hp = monster_stat("hp");
				kill_it[i].my_hp = my_stat("hp");
				kill_it[i].profit = get_action(stun).profit;
				kill_it[i].options = stun.id;
				i += 1;
				if(killer.id == "" || killer.id == stun.id || (killer.mp < 0 && my_stat("mp") < abs(killer.mp)))
					killer = attack_option();
				stun_enqueued = true;
			}
			
			vprint("Monster HP is " + monster_hp() + " according to Mafia and " + monster_stat("hp") + " according to BatBrain (loop variable i = " + i + ").", 9);

			if(killer.id == "") {
				if(to_int(vars["verbosity"]) >= 10) {
					vprint("WHAM: Unable to find a good way to kill the monster, not generating any data files.", "purple", 10);
					break;
				}
				//There is no way of directly killing the mob in our current state, we need to either restore HP, MP or delevel
				//TODO: Add HP and MP restoration and weight those with deleveling, also make delevelling actually work...
				delevel = delevel_option((m == $monster[Shub-Jigguwatt, Elder God of Violence] ? true : false));
				while(delevel.id != "" && killer.id == "") {
					if(!enqueue(delevel))
						break;
					kill_it[i].hp = monster_stat("hp");
					kill_it[i].my_hp = my_stat("hp");
					kill_it[i].profit = (i == 0 ? get_action(killer).profit : kill_it[i-1].profit + get_action(killer).profit);
					kill_it[i].options = killer.id;					
					delevel = delevel_option((m == $monster[Shub-Jigguwatt, Elder God of Violence] ? true : false));
					killer = attack_option();
					i += 1;
					if(my_stat("hp") < m_dpr(0,0) || i >= min(to_int(vars["WHAM_round_limit"]),maxround))
						break;
				}
				if(killer.id == "") {
					if(!to_boolean(vars["WHAM_AlwaysContinue"])) {
						vprint("WHAM: Unable to delevel until you can kill the monster without it killing you. Try it yourself.", "purple", 3);
						reset_queue();
						return sorted_kill;
					} else {
						vprint("WHAM: Could not find a way to kill the monster. Trying the best available option since you've set WHAM_AlwaysContinue to true.", "purple", 5);
						allMyOptions(hitchance); //Recalculate our options before doing this part
						sort opts by -to_profit(value);
						sort opts by kill_rounds(value.dmg)*-(min(value.profit,-1));
						enqueue(opts[0]);
						kill_it[i].hp = monster_stat("hp");
						kill_it[i].my_hp = my_stat("hp");
						kill_it[i].profit = (i == 0 ? get_action(opts[0]).profit : kill_it[i-1].profit + get_action(opts[0]).profit);
						kill_it[i].options = opts[0].id;
						reset_queue();
						act(page); //Needed so that items that some things do not get out of synch with batbrain
						return kill_it;
					}
				}
			}

			enqueue(killer);
			kill_it[i].hp = monster_stat("hp");
			kill_it[i].my_hp = my_stat("hp");
			kill_it[i].profit = (i == 0 ? get_action(killer).profit : kill_it[i-1].profit + get_action(killer).profit);
			kill_it[i].options = killer.id;
			if(monster_stat("hp") > 0) {
				if(contains_text(killer.id, "use") && have_skill($skill[ambidextrous funkslinging]) && funking == false) {
					killer = item_option();
					funking = true;
					if(!contains_text(killer.id, "use") || (can_interact() ? WHAM_roundcost_aftercore > abs(to_profit(killer)) : WHAM_roundcost_ronin > abs(to_profit(killer)))) {
						vprint("WHAM: Skipping funkslinging because " + (!contains_text(killer.id, "use") ? "no killing item was found." : "your WHAM_roundcost-setting is higher than the cost of using the item."), "purple", 8);
						killer = attack_option();
						funking = false;
					}
				} else {
					killer = attack_option();
					funking = false;
				}
			}
			i += 1;
			
			if(i > to_int(vars["WHAM_round_limit"]) - 1) {
				reset_queue();
				act(page); //Needed so that items that some things do not get out of synch with batbrain
				vprint("WHAM: Reached WHAM_round_limit while looking for a way to kill the monster. Executing the current strategy and continuing from there.", "purple", 3);
				if(to_int(vars["verbosity"]) < 10)
					return kill_it;
				else
					break;
			}
		}
	}
		
	reset_queue();
	act(page); //Needed so that items that some things do not get out of synch with batbrain
	vprint("WHAM: Evaluating the attack but not performing it took " + (to_string(to_float(gametime_to_int() - starttime)/1000, "%.2f")) + " seconds.", "purple", 9);
	if(to_int(vars["verbosity"]) < 10)
		return kill_it;

	vprint("WHAM: Debug printing the damage dealt by your options.", "purple", 10);
	vprint(" ",10);
	allMyOptions(-1);
	sort iterateoptions by -dmg_dealt(get_action(value).dmg);

	foreach num,sk in iterateoptions {
		matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",sk);
		if(find(aid)) {
			switch(aid.group(1)) {
				case "skill ":	vprint("WHAM: " + to_string(to_skill(to_int(excise(sk,"skill ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
				case "use ":	vprint("WHAM: " + to_string(to_item(to_int(excise(sk,"use ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance && vars["WHAM_noitemsplease"] == "false" ? "blue" : "red"), 3); break;
				case "attack":	vprint("WHAM: Attack with your weapon: " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
				case "jiggle":	vprint("WHAM: Jiggle your chefstaff: " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
			}
		}
	}
	vprint(" ",10);
	sorted_kill = Copy_Actions(kill_it);
	map_to_file(sorted_kill,"WHAM_damageandcosts.txt");
	sort sorted_kill by -value.profit;
	map_to_file(sorted_kill,"WHAM_sortedbyprofit.txt");

	vprint("WHAM: Evaluating the attack but not performing it took " + (to_string(to_float(gametime_to_int() - starttime)/1000, "%.2f")) + " seconds.", "purple", 9);
	return kill_it;
}

//Enqueue actions to kill the monster with and return this
string Perform_Actions() {
	record action {
		string macroid;
		string readableid;
	};
	action[int] cast;
	int go = 0, j = 0;
	buffer print_this;
	string result;
	boolean bitten;
	
	for n from 0 to count(kill_it)-1 {
		if(kill_it[n].options == "skill 12000")
			bitten = true;
		cast[j].macroid = kill_it[n].options;
		if(cast[j].macroid == "skill 12012" && !happened($skill[Infectious Bite]) && !bitten) {
			vprint("WHAM: Infecting the opponent to up the damage of Plague Claws", "purple", 3);
			cast[j].readableid = "Infectious Bite";
			cast[j].macroid = "skill 12000";
			bitten = true;
			j += 1;
			cast[j].macroid = "skill 12012";
		}
		
		matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",cast[j].macroid);
		if(find(aid)) {
			switch(aid.group(1)) {
				case "skill ":	cast[j].readableid = to_string(to_skill(to_int(excise(kill_it[n].options, "skill ", "")))); break;
				case "use ":	cast[j].readableid = to_string(to_item(to_int(excise(kill_it[n].options, "use ", "")))); break;
				case "attack":	cast[j].readableid = "attack with your weapon"; break;
				case "jiggle":	cast[j].readableid = "jiggle your chefstaff"; break;
			}
			j += 1;
		}
	}
	clear(kill_it);
	
	if(cast[0].macroid == stun.id && count(cast) > 1) {
		vprint("WHAM: Enqueuing a stun to help with the battle", "purple", 3);
		if(!enqueue(get_action(cast[0].macroid)))
			quit("Failed to enqueue the stun " + cast[0].readableid + ". Aborting to let you figure this out.");	
		go = 1;
	}
	
	//Between each cast, make sure we have MP to cast it
	for n from go to count(cast) - 1 {
		vprint("WHAM: Enqueueing " + cast[n].readableid + " (macroid " + cast[n].macroid + ")." + (vars["verbosity"] > 7 ? " Estimated damage: " + dmg_dealt(get_action(cast[n].macroid).dmg) + "." : ""), "purple", 7);
		if(!enqueue(get_action(cast[n].macroid))) {
			if(count(queue) == 0) {
				quit("Failed to enqueue " + cast[n].readableid + ". Aborting to let you figure this out.");
			} else {
				vprint("WHAM: Failed to enqueue " + cast[n].readableid + " (entry " + (n+1) + " in the strategy).", 3);
				vprint("WHAM: The following combat strategy was attempted: ", 3);
				foreach entry in cast
					vprint(cast[entry].readableid, 3);
				quit("Failed to enqueue " + cast[n].readableid + ". There's more detailed information in the gCLI.");
			}
		} else
			vprint("WHAM: Successfully enqueued " + cast[n].readableid + ".", "purple", 8);
	}
		
	//Print the strategy
	if(to_int(vars["verbosity"]) > 2) {
		append(print_this,"WHAM: We are going to " + count(cast) + "-shot with ");
		for n from 0 to count(cast) - 1 {
			append(print_this,cast[n].readableid);
			if(n == count(cast) - 2)
				append(print_this," and ");
			else if(n == count(cast) - 1)
				append(print_this,".");
			else
				append(print_this,", ");
		}
		vprint(print_this,"purple",3);
	}
	result = macro();
	if(result == "")
		quit("Critical error: An empty macro was generated. Please report this in the WHAM thread of kolmafia.us.");
	return result;
}

//Calculate options, valid for all classes
string Evaluate_Options() {
	string result;

	if(monster_stat("hp") <= 0)
		quit("Unable to get monster HP. Fight the battle yourself");
		
	if(my_location() == $location[The Tower of Procedurally-Generated Skeletons])
		set_skeleton_info();
	if(m == $monster[Video Game Boss])
		set_gameinformboss_info();

	if(finished())
		return "";
	kill_it = Calculate_Options(monster_stat("hp")); //Set up the damage dealt
		
	if(to_int(vars["verbosity"]) > 9) //With verbosity higher than 9 we definitely only want to debug. Do that and then stop.
		quit("Verbosity of 10 or more is set. Data files for debugging have been generated. Aborting.");

	if((count(kill_it) > 0))
		Perform_Actions();
	else {
		if(to_int(vars["verbosity"]) >= 3) {
			vprint("WHAM: Unable to determine a valid combat strategy. For your benefit here are the numbers for your combat options.", "purple", 3);
		
			allMyOptions(-1);
			sort iterateoptions by -dmg_dealt(get_action(value).dmg);
			foreach num,sk in iterateoptions {
				matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",sk);
				if(find(aid)) {
					switch(aid.group(1)) {
						case "skill ":	vprint("WHAM: " + to_string(to_skill(to_int(excise(sk,"skill ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
						case "use ":	vprint("WHAM: " + to_string(to_item(to_int(excise(sk,"use ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance && vars["WHAM_noitemsplease"] == "false" ? "blue" : "red"), 3); break;
						case "attack":	vprint("WHAM: Attack with your weapon: " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
						case "jiggle":	vprint("WHAM: Jiggle your chefstaff: " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
					}
				}
			}
			vprint("WHAM: You now have the knowledge needed to go forward and be victorious","purple",3);
			quit("Unable to figure out a combat strategy. Helpful information regarding your skills have been printed to the CLI");
		} else
			quit("WHAM: Unable to figure out a valid combat strategy. Try it yourself instead. If you set verbosity to 3 or more you will get a nice output of your available skills next time.");
	}
	return page;
}

// Category II: must-do-sometime actions
void build_custom_WHAM() {
	vprint("Building custom WHAM actions...",9);
	string dummy;
	
	void encustom(advevent which) {
		if(which.id != "")
			custom[count(custom)] = merge(which,new advevent);
	}
	
	//Zombie steal
	if(should_pp && (intheclear() || has_goal(m) > 0) && has_option($skill[Smash & Graaagh])) {
		vprint("WHAM: This monster drops a goal item and has_goal(m) = " + has_goal(m), "green", 9);
		vprint("WHAM: Trying to steal an item with Smash & Graaagh", "purple", 5);
		encustom(get_action($skill[Smash & Graaagh]));
	} else if (has_option($skill[Smash & Graaagh])) {
		vprint("WHAM: This monster does not drop a goal item", "red", 9);
	}
	
	//Zombie infect
	if(has_option($skill[Infectious Bite]) && (kill_rounds(attack_option().dmg) * my_level() >= monster_hp() * 0.5) && kill_rounds(attack_option().dmg) - 1 < die_rounds()) {
		vprint("WHAM: Infecting the opponent to try and turn it", "purple", 5);
		encustom(get_action($skill[Infectious Bite]));
	}
	
	//Should we olfact this bugbear?
	boolean bugbear_olfact(location loc, string prop, int amount) {
		if(my_location() != loc && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property(prop)) < amount)
			return true;
		return false;
	}
	
	//Jarlsbergifaction
	if(contains_text(vars["ftf_olfact"],to_string(m)) && have_equipped($item[staff of the cream of the cream]) && to_int(get_property("jiggleCream")) < 5 && get_property("_jiggleCreamedMonster") != to_string(m))
		encustom(get_action($item[staff of the cream of the cream]));

	if(my_location().zone == "The Sea" && item_amount($item[sea lasso]) > 0 && vars["WHAM_UseSeaLasso"] == "true" && get_property("lassoTraining") != "expertly")
		encustom(get_action($item[sea lasso]));

	//Steal accordions, because why not
	if(has_option($skill[steal accordion])) {
		vprint("WHAM: Trying to steal an accordion", "purple", 5);
		encustom(get_action($skill[steal accordion]));
	}
	
	//Pocket Crumbs
	if(has_option($skill[Pocket Crumbs])) {
		vprint("WHAM: Throwing some pocket crumbs at yoru opponent", "purple", 5);
		encustom(get_action($skill[Pocket Crumbs]));		
	}
		
	switch (to_string(m)) {
		//Boss actions
		case "conjoined zmombie":	for i from 1 upto item_amount($item[half-rotten brain])
										encustom(get_action($item[half-rotten brain]));
									break;
		case "giant skeelton": 	for i from 1 upto item_amount($item[rusty bonesaw])
									encustom(get_action($item[rusty bonesaw]));
								break;
		case "huge ghuol":	for i from 1 upto item_amount($item[can of Ghuol-B-Gone&trade;])
								encustom(get_action($item[can of Ghuol-B-Gone&trade;]));
							break;				
			
		//Monsters to be banished as Boris, Zombie or Jarlsberg
		case "A.M.C. Gremlin":
		case "Flaming Troll":
		case "Procrastination Giant":
		case "Sabre-Toothed Goat":
		case "Senile Lihc":
		case "Slick Lihc":
			if(has_goal(m) <= 0 && (my_path() == "Avatar of Boris" || my_path() == "Zombie Slayer" || my_path() == "Avatar of Jarlsberg")) {
				if(has_option(custom_action("banish")))
					encustom(custom_action("banish"));
			}
			break;

		//Bugbears
		case "bugbear scientist":
			if(item_amount($item[quantum nanopolymer spider web]) > 0 && my_location() == $location[Science Lab]) {
				encustom(get_action($item[quantum nanopolymer spider web]));

				return;
			} else if(bugbear_olfact($location[Science Lab],"biodataScienceLab",6))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "Scavenger bugbear":
			if(bugbear_olfact($location[Waste Processing],"biodataWasteProcessing",3))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "Hypodermic bugbear":
			if(bugbear_olfact($location[Medbay],"biodataMedbay",3))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "batbugbear":
			if(bugbear_olfact($location[Sonar],"biodataSonar",3))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "bugaboo":
			if(bugbear_olfact($location[Morgue],"biodataMorgue",6))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "Black Ops Bugbear":
			if(bugbear_olfact($location[Special Ops],"biodataSpecialOps",6))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "Battlesuit Bugbear Type":
			if(bugbear_olfact($location[Engineering],"biodataEngineering",9))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "ancient unspeakable bugbear":
			if(bugbear_olfact($location[Navigation],"biodataNavigation",9))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "trendy bugbear chef":
			if(bugbear_olfact($location[Galley],"biodataGalley",9))
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
		case "liquid metal bugbear":
			if(item_amount($item[drone self-destruct chip]) > 0) {
				encustom(get_action($item[drone self-destruct chip]));

				return;
			}
			break;
		case "N-space Virtual Assistant": 
		case "creepy eye-stalk tentacle monster":
		case "anesthesiologist bugbear":
			if(have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0)
				encustom(get_action($skill[Transcendent Olfaction]));
			break;
			
		//Oil monsters
		case "oil baron":
		case "oil cartel":
		case "oil slick":
		case "oil tycoon":
			if(item_amount($item[Duskwalker syringe]) > 0 && die_rounds() > kill_rounds(smacks) + 2) //Don't use the syringe if it'll kill us
				encustom(get_action($item[Duskwalker syringe]));
			break;
		case "rampaging adding machine":
			if((is_goal($item[668 scroll]) || is_goal($item[31337 scroll]) || is_goal($item[64735 scroll]))) {
				vprint("WHAM: Fighting a RAM with scrolls set as goal.", "purple", 7);
				int[item] scrolls;
				scrolls[$item[334 scroll]] = item_amount($item[334 scroll]);
				scrolls[$item[668 scroll]] = item_amount($item[668 scroll]);
				scrolls[$item[30669 scroll]] = item_amount($item[30669 scroll]);
				scrolls[$item[33398 scroll]] = item_amount($item[33398 scroll]);
				scrolls[$item[64067 scroll]] = item_amount($item[64067 scroll]);
				if(is_goal($item[668 scroll]) && scrolls[$item[334 scroll]] >= 2) {
					encustom(get_action($item[334 scroll]));
					encustom(get_action($item[334 scroll]));
				} else if (is_goal($item[31337 scroll]) && ((scrolls[$item[334 scroll]] >= 2 || scrolls[$item[668 scroll]] > 0) && scrolls[$item[30669 scroll]] > 0)) {
					if(scrolls[$item[668 scroll]] == 0) {
						encustom(get_action($item[334 scroll]));
						encustom(get_action($item[334 scroll]));
						dummy = macro();
					}
					encustom(get_action($item[668 scroll]));
					encustom(get_action($item[30669 scroll]));
				} else if (is_goal($item[64735 scroll]) && ((scrolls[$item[334 scroll]] >= 2 || scrolls[$item[668 scroll]] > 0) && ((scrolls[$item[30669 scroll]] > 0 && scrolls[$item[33398 scroll]] > 0) || (scrolls[$item[64067 scroll]] > 0)))) {
					if(scrolls[$item[668 scroll]] == 0) {
						encustom(get_action($item[334 scroll]));
						encustom(get_action($item[334 scroll]));
						dummy = macro();
					}
					if(scrolls[$item[64067 scroll]] == 0) {				
						encustom(get_action($item[30669 scroll]));
						encustom(get_action($item[33398 scroll]));
						dummy = macro();
					}
					encustom(get_action($item[668 scroll]));
					encustom(get_action($item[64067 scroll]));
				}
			} else {
				vprint("WHAM: Fighting a RAM without scrolls set as a goal. We'll just kill it unless you abort in 20 seconds", "purple", 7);
				wait(20);
			}
			break;
		case "Shub-Jigguwatt, Elder God of Violence":
			if(dmg_dealt(basecache.dmg) > 0)
				quit("You have a passive damage source active. The fight will be lost if you automate it. I suggest you run away.");
		case "Yog-Urt, Elder Goddess of Hatred":
			if(have_effect($effect[More Like a Suckrament]) > 0) {
				int j;
				advevent heal;
				sort opts by dmg_taken(value.pdmg);
				foreach i, opt in opts {
					if(-1 * dmg_taken(opt.pdmg) > 0.9 * my_maxhp())
						j +=1;
				}
				if(j < 8 - equipped_amount($item[Mer-kin prayerbeads]))
					abort("WHAM: You have too few good healing items to fight Yog-Hurt. I suggest you run away.");
				else if(dmg_dealt(basecache.dmg) > 0)
					abort("WHAM: You have a passive damage source active. The fight will be lost if you automate it. I suggest you run away.");
				else if(!have_skill($skill[ambidextrous funkslinging])) {
					for i from 0 to 7 - equipped_amount($item[Mer-kin prayerbeads]) {
						sort opts by dmg_taken(value.pdmg);
						foreach i, opt in opts {
							if(dmg_taken(opt.pdmg) < 0) {
								heal = opt;
								break;
							}
						}
						enqueue(heal);
					}
				} else {
					for i from 0 to 7 - equipped_amount($item[Mer-kin prayerbeads]) {
						sort opts by dmg_taken(value.pdmg);
						foreach i, opt in opts {
							if(dmg_taken(opt.pdmg) < 0) {
								heal = opt;
								break;
							}
						}
						enqueue(heal);
						if(delevel_option(true).id != "")
							enqueue(delevel_option(true));
						else
							macro();
					}
				}
			}
			break;
		//The Suburbs of Dis
		case "The Terrible Pinch":
			vprint("WHAM: Fighting the terrible pinch by alternating between attacking and jars full of wind", "purple", 5);
			while(monster_stat("hp") > 0) {
				enqueue(attack_option(true));
				enqueue($item[jar full of wind]);
				macro();
			}
			break;
/*		case "Thug 1 and Thug 2":
			vprint("WHAM: Fighting Thug 1 and Thug 2 by throwing jars full of wind", "purple", 5);
			if (item_amount($item[jar full of wind]) > 9) {
				for i from 1 to 10
					enqueue($item[jar full of wind]);
				macro();
			}
			break;
		case "the large-bellied snitch":
			vprint("WHAM: Fighting the large-bellied snitch by throwing dangerous jerkcicles", "purple", 5);		
			if (item_amount($item[dangerous jerkcicle]) > 7) {
				for i from 1 to 10
					enqueue($item[dangerous jerkcicle]);
				macro(plink, "");
			}
			break;
		case "mammon the elephant":
			vprint("WHAM: Fighting mammon the elephant by throwing dangerous jerkcicles", "purple", 5);		
			if (item_amount($item[dangerous jerkcicle]) > 5) {
				for i from 1 to 6
					enqueue($item[dangerous jerkcicle]);
				macro();
			}
			break;				
		case "the bat in the spats":
			vprint("WHAM: Fighting the bat in the spats by throwing clumsiness bark", "purple", 5);		
			if (item_amount($item[clumsiness bark]) > 9) {
				for i from 1 to 10 
					enqueue($item[clumsiness bark]);
				macro();
			}
			break;*/
		case "Sorrowful Hickory":
		case "Suffering Juniper":
		case "Tormented Baobab":
		case "Whimpering Willow":
		case "Woeful Magnolia":
			if(kill_rounds(smacks.dmg) < die_rounds() && has_option($skill[Torment Plant]))
				encustom(get_action($skill[Torment Plant]));
			break;
		case "Bettie Barulio":
		case "Marcus Macurgeon":
		case "Marvin J. Sunny":
		case "Mortimer Strauss":
		case "Wonderful Winifred Wongle":
			if(kill_rounds(smacks.dmg) < die_rounds() && has_option($skill[Pinch Ghost]))
				encustom(get_action($skill[Pinch Ghost]));
			break;
		case "Brock \"Rocky\" Flox":
		case "Dolores D. Smiley":
		case "Hugo Von Douchington":
		case "Vivian Vibrian Vumian Varr":
		case "Wacky Zack Flacky":
			if(kill_rounds(smacks.dmg) < die_rounds() && has_option($skill[Tattle]))
				encustom(get_action($skill[Tattle]));
			break;
	}

	vprint("Custom WHAM actions built! ("+count(custom)+" actions)",9);
	if(!finished())
		build_custom();
}

string stasis_repeat_WHAM(int turns) {       // the string of repeat conditions for stasising
   int expskill() { int res; foreach s in $skills[] if (s.combat && have_skill(s)) res = max(res,mp_cost(s)); return res; }
   return "!hpbelow "+my_stat("hp")+                                                        // hp
      (my_stat("hp") < my_maxhp() ? " && hpbelow "+my_maxhp() : "")+
      " && !mpbelow "+my_stat("mp")+                                                        // mp
      (my_stat("mp") < min(expskill(),my_maxmp()) ? " && mpbelow "+min(expskill(),my_maxmp()) : "")+
      " && !pastround "+(turns == 0 ? floor(maxround - (3 + WHAM_safetymargin) - kill_rounds(smacks)) : (turns + round - (3 + WHAM_safetymargin))) +     // time to kill
      ((have_equipped($item[crown of thrones])) ? " && !match \"acquire an item\"" : "")+   // CoT
      ((my_fam() == $familiar[hobo monkey]) ? " && !match \"hands you some Meat\"" : "")+   // famspent
      ((my_fam() == $familiar[gluttonous green ghost]) ? " && match ggg.gif" : "")+
      ((my_fam() == $familiar[slimeling]) ? " && match slimeling.gif" : "");
}

string stasis_WHAM() {
	int turns;
	if ($monsters[naughty sorority nurse, naughty sorceress, naughty sorceress (2), pufferfish, bonerdagon] contains m)
		return page;    // never stasis these monsters
	if (m == $monster[quantum mechanic] && m_hit_chance() > 0.1)
		return page;  // avoid teleportitis
	stasis_option();
	attack_option();
	while ((to_profit(plink) > to_float(vars["BatMan_profitforstasis"]) + (can_interact() ? WHAM_roundcost_aftercore : WHAM_roundcost_ronin) || is_our_huckleberry() || train_skills()) &&
	  (round < maxround - (3 + WHAM_safetymargin) - kill_rounds(smacks) && die_rounds() > kill_rounds(smacks))) {
		vprint("Top of the stasis loop.",9);
		matcher optid = create_matcher("(skill |use |jiggle|attack)(?:(\\d+),?(\\d+)?)?",plink.id);
		matcher smackid = create_matcher("(skill |use |jiggle|attack)(?:(\\d+),?(\\d+)?)?",smacks.id);
		// special actions
		enqueue_custom();
		enqueue_combos();
		// stasis action as picked by BatBrain -- macro it until anything changes
		if (plink.id == "" && vprint("You don't have any stasis actions.","olive",4))
			break;
		
		switch {
			case (plink.id == "jiggle"):	//You can only Jiggle once per fight
				turns = 1;
				break;
			case (plink.id == "skill 7074"):
				turns = count(queue) + min(1, to_int(get_property("burrowgrubSummonsRemaining")));	//Consume Burrowgrub can be cast thrice
				break;
			case (plink.id == "skill 7061"):
			case (plink.id == "skill 7062"):
			case (plink.id == "skill 7063"):
			case (plink.id == "skill 7064"):
				turns = count(queue) + min(1, equipped_amount($item[haiku katana]) - times_happened(plink.id));
				break;
			case (optid.find() && contains_text(factors[(optid.group(1) == "use " ? "item" : (optid.group(1) == "skill " ? "skill" : "chef")), (optid.group(1) != "jiggle" ? to_int(optid.group(2)) : to_int(equipped_item($slot[weapon])))].special, "once")):
				turns = count(queue) + 1;	//Options that can only be used once, should only be used once before recalculating
				break;
			case (contains_text(plink.id, "skill")):
				int mpcost = (smackid.find() && smackid.group(1) == "skill" ? mp_cost(to_skill(to_int(smackid.group(2)))) *  kill_rounds(smacks) : 0);
				int uses = (my_mp() - mpcost) / max(1,mp_cost(to_skill(to_int(optid.group(2)))));
				turns = (uses > (maxround - (WHAM_safetymargin + 3)) ? 0 : count(queue) + uses);	//Don't try to stasis for more turns than we have MP for
				break;																				//Relies on stasis_option to have already removed skills we cannot cast more than once
			default:
				turns = 0;
				break;
		}

		macro(plink, stasis_repeat_WHAM(turns));
		
		//Reset batbrain_insert
		WHAM_round("");		
		
		if (finished())
			break;
			
		stasis_option();       // recalculate stasis/attack actions
		attack_option();
	}
	vprint("Stasis loop complete"+(count(queue) > 0 ? " (queue still contains "+count(queue)+" actions)." : "."),9);
	return page;
}

void SmartStasis() {
	vprint_html("Profit per round: "+to_html(baseround()),5);
	// custom actions
	build_custom_WHAM();
	if (count(queue) > 0 && queue[0].id == "pickpocket" && my_class() == $class[disco bandit])
		try_custom();
	else
		enqueue_custom();
		
	// combos
	build_combos();
	if (($familiars[hobo monkey, gluttonous green ghost, slimeling] contains my_fam() && !happened("famspent")) || have_equipped($item[crown of thrones]))
		try_combos();
	else
		enqueue_combos();
		
	// stasis loop
	stasis_WHAM();
	macro();
	vprint("WHAM: SmartStasis complete.", "purple", 7);
}

void main(int initround, monster foe, string pg) {
	int starttime = gametime_to_int();
	int mox = my_buffedstat($stat[moxie]);

	//Debug info
	vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);

	//Set unknown_ml for specific monsters Mafia doesn't handle and that have semi-spaded unknown_ml
	//Doing this before act() makes sure that batbrain uses our new unknown_ml-value
	pre_brain(foe, pg);
	
	//Set up the initial variables and skills
	vprint("WHAM: Setting up variables via BatBrain", "purple", 8);
	act(pg);

	if(my_location() == $location[The Tower of Procedurally-Generated Skeletons]) {
		vprint("WHAM: Setting Skeleton type.", "purple", 7);
		set_skeleton_info();
	}
	if(m == $monster[Video Game Boss]) {
		vprint("WHAM: Setting special boss power.", "purple", 7);
		set_gameinformboss_info();
	}	
	//Debug info
	vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);
	
	//Testing MP and HP restoration options
	vprint("WHAM: Current MP = " + my_mp() + " out of " + my_maxmp() + ".", "purple", 9);
	vprint("WHAM: " + (mp_option(my_maxmp() - my_mp()).id == "" ? "You have no profitable MP restoratives." : "Your best MP restoring option available is: " + mp_option(my_maxmp() - my_mp()).id), "purple", 7);
	vprint("WHAM: Current HP = " + my_hp() + " out of " + my_maxhp() + ".", "purple", 9);
	vprint("WHAM: " + (hp_option(my_maxhp() - my_hp()).id == "" ? "You have no profitable HP restoratives." : "Your best HP restoring option available is: " + hp_option(my_maxhp() - my_hp()).id), "purple", 7);
	
	//Debug printing for monster stats
	vprint("WHAM: You are fighting a " + to_string(m) + ". Mafia considers that this monster has an attack of " + monster_attack() + " or " + monster_attack(m) + " when given a monster name.", "purple", 9);
	vprint("WHAM: Mafia further considers that this monster has a defense value of " + monster_defense() + " or " + monster_defense(m) + " when given a monster name.", "purple", 9);
	vprint("WHAM: Mafia further further considers that this monster has a HP value of " + monster_hp() + " or " + monster_hp(m) + " when given a monster name.", "purple", 9);
	vprint("WHAM: Your current ML-adjustment is: " + monster_level_adjustment() + ".", "purple", 9);
	
	//Debug printing for player stats
	vprint("WHAM: You have muscle = " + my_buffedstat($stat[muscle]) + ", mysticality = " + my_buffedstat($stat[mysticality]) + ", and moxie = " + my_buffedstat($stat[moxie]),"purple", 9);
	//if(to_int(vars["verbosity"]) == 9) cli_execute("equipment");
	
	//Print base monster stats
	vprint("WHAM: Monster HP is " + (monster_hp() == 0 ? monster_stat("hp") + monster_hp() : monster_stat("hp")) + (bees(m) > 0 ? " which was increased by " + bees(m) * ceil(0.2 * monster_hp(m)) + " due to bees hating you." : "."), "purple", 4);
	
	//Add WHAM-specific stuff to batround
	WHAM_round("");
	
	 //Set up the available options that we have
	allMyOptions(hitchance);
	attack_option();

	if(to_int(vars["verbosity"]) < 10 && my_location() != $location[Fernswarthy's Basement] && my_location() != $location[The Tower of Procedurally-Generated Skeletons]) {
		//Call SmartStasis to do fun and complicated stuff
		vprint("WHAM: Running SmartStasis", "purple", 3);
		SmartStasis();
		WHAM_maxround = min(maxround, WHAM_maxround + round);
		vprint("WHAM: Running SmartStasis took " + (to_string(to_float(gametime_to_int() - starttime)/1000, "%.2f")) + " seconds.", "purple", 9);
		
		if(finished()) { //Exit the script if SS ended the fight
			vprint("WHAM: SS has finished the fight. Aborting script execution. ", "purple", 3);
			exit;
		} else {
			vprint("WHAM: SS did not finish the fight, continuing with script execution. ", "purple", 7);
			//act(page); //Re-initialize all variables to be sure we are in a correct state
		}
	}

	//If our Moxie changed due to SmartStasis re-evaluate our options
	if (my_buffedstat($stat[moxie]) < mox)
		allMyOptions(hitchance);
		
	//Debug info
	vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);

	repeat {		
		vprint("WHAM: Starting evaluation and performing of attack", "purple", 3);

		//Debug info
		vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);

		page = Evaluate_Options();
		vprint("WHAM: Evaluating the attack and performing it took " + (to_string(to_float(gametime_to_int() - starttime)/1000, "%.2f")) + " seconds.", "purple", 9);

		if(!(contains_text(page, "WINWINWIN") || page == "" || my_hp() == 0 || have_effect($effect[Beaten Up]) == 3))
			vprint("WHAM: Current monster HP is calculated to " + monster_stat("hp"), "purple", 4);

		//Debug info
		vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);
		
		if(round >= min(maxround, WHAM_maxround) && !finished())
			quit("The fight has gone on for longer than your WHAM_maxround setting. Reverting power to manual.");
			
		//Debug info
		vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);
	} until(finished() || die_rounds() <= 1 || round >= min(maxround, WHAM_maxround));

	if(foe == $monster[wild seahorse] && happened($item[sea lasso]))
		quit("You've tamed a Sea Horse. Aborting so you can decide how to continue.");
	
	//Reset unknown_ml in case we changed it
	if(vars["unknown_ml"] != unknown_ml) {
		vars["unknown_ml"] = unknown_ml;
		updatevars();
	}
}