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
***********************************************************************************************************************/
import <SmartStasis.ash>;

setvar("WHAM_round_limit", 15);	//Sets the amount of rounds the script should try to automate before executing its predictions
setvar("WHAM_hitchance", 0.5);	//Fraction of a chance to hit the monster with something for it to be considered
setvar("WHAM_maxround", 30);	//What turn do we want the script to stop fighting by
setvar("WHAM_AlwaysContinue", false);	//If true, will enqueue the best option and execute that to see if that opens up any new
										//options and so on until either the monster dies or you do
setvar("WHAM_noitemsplease", false);	//If true will cause the script to skip all items when fighting										
check_version("WHAM","WHAM","3.3",8861);

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

record dontuse
{
	string type;
	string id;
	int amount;
};

//Global variables
advevent[int] myoptions;
advevent[int] restoration;
advevent stun; //Globally declared to be usable when enqueueing for real
actions[int] kill_it;
string[int] iterateoptions;

dontuse[int] not_ok;
int WHAM_maxround = to_int(vars["WHAM_maxround"]);
int unknown_ml = to_int(vars["unknown_ml"]);
float hitchance = to_float(vars["WHAM_hitchance"]);

//Load the map of items and skills to not use from the file
file_to_map("WHAM_dontuse_" + my_name() + ".txt", not_ok);

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

//Function to do special stuff
string special_actions() {
	string dummy;

	//SIMON ADDED siphoning
	if(my_familiar() == $familiar[happy medium])
	{
		print("have medium","lime");
		if(contains_text(visit_url("charpane.php"),"medium_3.gif"))
		{
			print("medium fully charged","lime");
			return macro("skill " + to_int($skill[Siphon Spirit]));
		}
	}
	switch(to_string(m)) {
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
					if(have_skill($skill[Ambidextrous Funkslinging]))
						enqueue(merge(get_action($item[334 scroll]), get_action($item[334 scroll])));
					else {
						enqueue(get_action($item[334 scroll]));
						enqueue(get_action($item[334 scroll]));
					}
					return macro();	
				} else if (is_goal($item[31337 scroll]) && ((scrolls[$item[334 scroll]] >= 2 || scrolls[$item[668 scroll]] > 0) && scrolls[$item[30669 scroll]] > 0)) {
					if(have_skill($skill[Ambidextrous Funkslinging])) {
						if(scrolls[$item[668 scroll]] == 0) {
							enqueue(merge(get_action($item[334 scroll]), get_action($item[334 scroll])));
							dummy = macro();
						}
						enqueue(merge(get_action($item[668 scroll]), get_action($item[30669 scroll])));
					} else {
						if(scrolls[$item[668 scroll]] == 0) {
							enqueue(get_action($item[334 scroll]));
							enqueue(get_action($item[334 scroll]));
							dummy = macro();
						}
						enqueue(get_action($item[668 scroll]));
						enqueue(get_action($item[30669 scroll]));
					}
					return macro();
				} else if (is_goal($item[64735 scroll]) && ((scrolls[$item[334 scroll]] >= 2 || scrolls[$item[668 scroll]] > 0) && ((scrolls[$item[30669 scroll]] > 0 && scrolls[$item[33398 scroll]] > 0) || (scrolls[$item[64067 scroll]] > 0)))) {
					if(have_skill($skill[Ambidextrous Funkslinging])) {
						if(scrolls[$item[668 scroll]] == 0) {
							enqueue(merge(get_action($item[334 scroll]), get_action($item[334 scroll])));
							dummy = macro();
						}
						if(scrolls[$item[64067 scroll]] == 0) {
							enqueue(merge(get_action($item[30669 scroll]), get_action($item[33398 scroll])));
							dummy = macro();
						}
						enqueue(merge(get_action($item[668 scroll]), get_action($item[64067 scroll])));
					} else {
						if(scrolls[$item[668 scroll]] == 0) {
							enqueue(get_action($item[334 scroll]));
							enqueue(get_action($item[334 scroll]));
							dummy = macro();
						}
						if(scrolls[$item[64067 scroll]] == 0) {				
							enqueue(get_action($item[30669 scroll]));
							enqueue(get_action($item[33398 scroll]));
							dummy = macro();
						}
						enqueue(get_action($item[668 scroll]));
						enqueue(get_action($item[64067 scroll]));
					}
					return macro();
				}
			} else {
				vprint("WHAM: Fighting a RAM without scrolls set as a goal. We'll just kill it unless you abort in 20 seconds", "purple", 7);
				wait(20);
			}
			break;
		
		//Boris-banishing monsters
		case "A.M.C Gremlin":
		case "Flaming Troll":
		case "Procrastination Giant":
		case "Sabre-Toothed Goat":
		case "Senile Lihc":
		case "Slick Lihc":
			if(get_action($skill[banishing shout]).id != "")
				return macro($skill[banishing shout]);
			break;
			
		//Bugbears
		case "bugbear scientist":
			if(item_amount($item[quantum nanopolymer spider web]) > 0 && my_location() == $location[Science Lab]) {
				macro($item[quantum nanopolymer spider web]);
				return "";
			}
			else if(my_location() != $location[Science Lab] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataScienceLab")) < 6) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "Scavenger bugbear":
			if(my_location() != $location[Waste Processing] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataWasteProcessing")) < 3) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "Hypodermic bugbear":
			if(my_location() != $location[Medbay] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataMedbay")) < 3) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "batbugbear":
			if(my_location() != $location[Sonar] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataSonar")) < 3) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "bugaboo":
			if(my_location() != $location[Morgue] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataMorgue")) < 6) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "Black Ops Bugbear":
			if(my_location() != $location[Special Ops] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataSpecialOps")) < 6) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "Battlesuit Bugbear Type":
			if(my_location() != $location[Engineering] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataEngineering")) < 9) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "ancient unspeakable bugbear":
			if(my_location() != $location[Navigation] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataNavigation")) < 9) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "trendy bugbear chef":
			if(my_location() != $location[Galley] && have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0 && to_int(get_property("biodataGalley")) < 9) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
		case "liquid metal bugbear":
			if(item_amount($item[drone self-destruct chip]) > 0)
				macro("use " + to_int($item[drone self-destruct chip]));
			break;
		case "N-space Virtual Assistant": 
		case "creepy eye-stalk tentacle monster":
		case "anesthesiologist bugbear":
			if(have_skill($skill[Transcendent Olfaction]) && my_stat("mp") > mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) == 0) {
				return macro("skill " + to_int($skill[Transcendent Olfaction]));
			}
			break;
	}
	return page;
}

//Set unknown_ml for a couple of semi-spaded monsters not yet in Mafia
void set_unknown_ml(monster foe) {
	if(to_int(vars["unknown_ml"]) != 0) {
		vprint("WHAM: Checking to see if WHAM sould adjust the unknown_ml for " + foe + ".", "purple", 8);
		switch (to_string(foe)) {
			//Medbay
			case "anesthesiologist bugbear":
			case "hypodermic bugbear":	vars["unknown_ml"] = 40 + monster_level_adjustment(); updatevars(); break;
			case "bugbear robo-surgeon":	vars["unknown_ml"] = 100 + monster_level_adjustment(); updatevars(); break;
			//Wase processing
			case "creepy eye-stalk tentacle monster":
			case "Scavenger bugbear":
			case "grouchy furry monster":	vars["unknown_ml"] = 50 + monster_level_adjustment(); updatevars(); break;
			//Sonar
			case "batbugbear":	vars["unknown_ml"] = 60 + monster_level_adjustment(); updatevars(); break;
			//Science Lab
			case "bugbear scientist":
			case "spiderbugbear":	vars["unknown_ml"] = 100 + monster_level_adjustment(); updatevars(); break;
			//Morgue
			case "bugaboo":
			case "bugbear mortician":	vars["unknown_ml"] = 120 + monster_level_adjustment(); updatevars(); break;
			//Special Ops
			case "Black Ops Bugbear":	vars["unknown_ml"] = 140 + monster_level_adjustment(); updatevars(); break;
			//Engineering
			case "Battlesuit Bugbear Type":
			case "liquid metal bugbear":
			case "bugbear drone":	
			//Navigation
			case "ancient unspeakable bugbear":	
			case "N-space Virtual Assistant":	vars["unknown_ml"] = 200 + monster_level_adjustment(); updatevars(); break;
			//Galley
			case "trendy bugbear chef": vars["unknown_ml"] = 300 + monster_level_adjustment(); updatevars(); break;
			
			default:	if(contains_text(to_string(foe), "cavebugbear")) {
							string[int] verys = split_string(to_string(foe), " "); vars["unknown_ml"] = 75 * (count(verys) - 2); updatevars();
						}
						else
							vprint("WHAM: No need to do anything with " + foe + ".", "purple", 8);
		}
	} else if(monster_hp(foe) == 0)
		quit("WHAM: Your unknown_ml is set to 0, handle this unkown monster yourself.");
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
advevent mp_action(int target) {
	if (my_stat("mp") >= target)
		return new advevent;
	sort opts by -to_profit(value);
	foreach i,opt in opts {
		if (opt.mp <= 0)
			continue;
		if (opt.mp + my_stat("mp") >= target && to_profit(opt) > -500) {
			vprint("WHAM: Your most profitable mp-restoring option is " + opt.id + ".", "purple", 9);
			return opt;
		}
	}
	return new advevent;
}

advevent hp_action(int target) {
	if (my_stat("hp") >= target)
		return new advevent;
	sort opts by -to_profit(value);
	foreach i,opt in opts {
		if (dmg_taken(opt.pdmg) >= 0) //Negative pdmg = healing item
			continue;
		if (-dmg_taken(opt.pdmg) + my_stat("hp") >= target && -dmg_taken(opt.pdmg) > m_dpr(0,0)) {//&& to_profit(opt) > -500
			vprint("WHAM: Your most profitable healing option is " + opt.id + ".", "purple", 9);
			return opt;
		}
	}
	return new advevent;
}

//Delevel the monster so we can hit it
advevent Delevel() {
	sort opts by -to_profit(value);
	sort opts by value.att*-(min(value.profit,-1));		
	foreach i,opt in opts {
		if(opt.att < 0) {
			vprint("WHAM: Your most profitable deleveling option is " + opt.id + ".", "purple", 9);
			return opt;
		}
	}
	return new advevent;
}

//Creates a call to check specific things that batround doesn't do.
void WHAM_round() {
	//Don't try to automate longer than the sepcified turnround
	batround_insert = batround_insert + "if pastround " + (WHAM_maxround - 1) + "; abort \"Stopping fight because it has gone on for too long (set WHAM_maxround to a higher value if you think this was in error)\"; endif; ";
	vprint("WHAM: WHAM added the following to BatRound: " + batround_insert,9);
}

//Count happenings to avoid items that have already been enqueued as many as we have
int times_happened(string occurrence) {
	if (count(happenings) == 0)
		file_to_map("happenings_"+replace_string(my_name()," ","_")+".txt",happenings);
	if (happenings contains occurrence && happenings[occurrence].turn == turncount)
		return happenings[occurrence].queued;
	return 0;
}

//Function to return skills and items that are usable
boolean ok(advevent a) {
	boolean no_cunctatitis() {
		return m != $monster[Procrastination Giant] || weapon_type(equipped_item($slot[weapon])) == $stat[Moxie];
	}
	
	boolean no_teleportitis() {
		return m != $monster[n-dimensional horror] && !contains_text(to_lower_case(to_string(m)), "quantum");
	}

	if(m == $monster[Naughty Sorority Nurse] && (dmg_dealt(a.dmg) + (m_hit_chance()*dmg_dealt(retal.dmg) + dmg_dealt(baseround().dmg))) < 90)
		return false;	//These monsters heal too much for this skill
	if(a.pdmg[$element[none]] > my_stat("hp"))
		return false;	//Don't use something that would kill us
	





    matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",a.id);
    if(aid.find()) {
		switch(aid.group(1)) {
			case "use ":	//If the user doesn't want to use items, don't
				if(vars["WHAM_noitemsplease"] == "true")
					return false;
		}
		
		for i from 0 to count(not_ok) - 1 {
			switch(aid.group(1)) {
				case "use ":	if(not_ok[i].id == aid.group(2) && (item_amount(to_item(to_int(aid.group(2)))) - times_happened(not_ok[i].type + " " + not_ok[i].id) <= not_ok[i].amount || not_ok[i].amount == -1))
									return false;
								break;
				case "skill ":	if(not_ok[i].id == aid.group(2))
									return false;
								if(contains_text(factors["skill",to_int(a.id)].special,"once") && happened(a.id))
									return false;
								break;
			}
		}
		
		switch(aid.group(1)+aid.group(2)) {
			case "use 2065":	//PADL-phone does not work against Bugbear chefs
			case "use 2354":	//Neither does the windchimes
				return (to_string(m) != "trendy bugbear chef");
			case "use 2453":	//Goodfella contracts
				return (my_effective_familiar() == $familiar[Penguin Goodfella]);
			case "use 2848":	//Gnomitronic thingamabob
				return (!happened($item[gnomitronic hyperspatial demodulizer]));
			case "use 3391":	// Frosty's iceball. Don't use it!
				return false;
			case "use 4698":	//Imp Air
			case "use 4699":	//Bus Pass, don't use unless we are already past the steel item quest
				return (get_property("questM10Azazel") == "finished");
			case "use 5676":	//Pool torpedos only work under water
				return (my_location().zone == "The Sea");
			case "skill 66": //Flying Fire Fist
				// Don't auto-use this if it will expend Salamanderenity.
				if(have_effect($effect[Salamanderenity]) > 0) return false;
				else return true;
			case "skill 1023": //Harpoon!
				return equipped_item($slot[weapon]) != $item[none] && no_cunctatitis();
			case "skill 7081": //Open the Bag O' Tricks, can only be used once per fight. How do we control that?
				return false;
			case "skill 11000": //Mighty Axing 
			case "skill 11001": //Cleave
				return (no_cunctatitis() && no_teleportitis() && have_equipped($item[Trusty]));
			case "skill 11006": //Throw Trusty
				return have_equipped($item[Trusty]);
			case "skill 2005": //Shieldbutt
			case "skill 2105": //Head + Shield Combo
			case "skill 2106": //Knee + Shield Combo
			case "skill 2107": //Head + Knee + Shield Combo
				if(item_type(equipped_item($slot[off-hand])) != "shield") return false;
			case "skill 1003": //Thrust-Smack
			case "skill 1004": //Lunge-Smack
			case "skill 1005": //Lunging Thrust-Smack
			case "skill 2003": //Headbutt
			case "skill 2015": //Kneebutt
			case "skill 2103": //Head + Knee Combo
				if(weapon_type(equipped_item($slot[weapon])) == $stat[Moxie]) return false;
			case "skill 12011": return no_cunctatitis() && no_teleportitis();
			case "attack":
				return ((my_path() != "Avatar of Boris" && no_cunctatitis() && no_teleportitis()) ||
						(my_path() == "Avatar of Boris" && (!have_equipped($item[Trusty]) && no_cunctatitis() && no_teleportitis()) || (contains_text(to_string(m),"Naughty Sorceress") || m == $monster[Bonerdagon] || have_effect($effect[temporary amnesia]) > 0)));
        }
	}
	return true;
}  

//Check for the skills included in calculations
void allMyOptions(float hitlimit) {
	int n = 0;
	clear(iterateoptions);
	clear(myoptions);
	if(m == $monster[dr. awkward])
		hitlimit = min(1, hitlimit + 0.25);
	sort opts by -to_profit(value);
	sort opts by kill_rounds(value.dmg)*-(min(value.profit,-1));
	foreach i,opt in opts {
		if(dmg_dealt(opt.dmg) > 0) {
			vprint("WHAM: Currently checking " + (contains_text(opt.id, "skill") ? to_string(to_skill(to_int(excise(opt.id,"skill ","")))) : to_string(to_item(to_int(excise(opt.id,"use ",""))))) + " which has a reported damage of " + dmg_dealt(opt.dmg) + " and is " + (ok(opt) ? "ok." : "not ok."), "blue", 11);
			vprint("WHAM: Raw damage is estimated at " + opt.dmg[$element[cold]] + " (cold), " + opt.dmg[$element[hot]] + " (hot), " + opt.dmg[$element[stench]]+ " (stench), " + opt.dmg[$element[spooky]] + " (spooky), " + opt.dmg[$element[sleaze]] + " (sleazy) and  " + opt.dmg[$element[none]] + " (physical).", "purple", 11);
		}

		if (dmg_dealt(opt.dmg) > 0 && ok(opt) && hitchance(opt.id) >= hitlimit) {
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

advevent attack_option() {
	if (!happened($item[gnomitronic hyperspatial demodulizer]) && monster_stat("hp") <= dmg_dealt(get_action("use 2848").dmg))
		return get_action("use 2848");
	float drnd = max(1.0,die_rounds());   // a little extra pessimistic
	sort myoptions by -to_profit(value);
	sort myoptions by kill_rounds(value.dmg)*-(min(value.profit,-1));
	foreach i,opt in myoptions {


		if (contains_text(opt.id, "skill") && have_effect($effect[temporary amnesia]) > 0)
			continue;	//Ignore skills if we have amnesia
		if (contains_text(opt.id, "use") && times_happened(opt.id) >= item_amount(to_item(to_int(excise(opt.id,"use ","")))))
			continue;	//Ignore items that we do not have that many of...
		if (kill_rounds(opt.dmg) > min(min(maxround, WHAM_maxround) - round - 1,drnd))
			continue;	//Reduce RNG risk for stasisy actions
		if (opt.stun < 1 && to_profit(opt) < -runaway_cost())
			continue;	//Don't choose actions worse than fleeing
		if (abs(opt.mp) > my_stat("mp"))
			continue;	//Don't use skills we can't use due to MP problem

		if(contains_text(opt.id, "7116") && happened(opt.id))
			continue; //SIMONS HARD CODED FEED SKIPPING
		if(contains_text(opt.id, "7082") && happened(opt.id))
			continue; //SIMONS HARD CODED POINT SKIPPING
		if (contains_text(opt.note, "once") && happened(opt.id))
			continue;	//Don't retry things that can only be done once


		vprint("WHAM: Attack option chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(to_profit(opt))+")", "purple", 8);
		return opt;
	}
	vprint("WHAM: No valid attacks.", "purple", 8);
	return new advevent;
}














advevent item_option() {
	if (!happened($item[gnomitronic hyperspatial demodulizer]) && monster_stat("hp") <= dmg_dealt(get_action("use 2848").dmg))
		return get_action("use 2848");
	float drnd = max(1.0,die_rounds());   // a little extra pessimistic
	sort myoptions by -to_profit(value);
	sort myoptions by kill_rounds(value.dmg)*-(min(value.profit,-1));
	foreach i,opt in myoptions {
		if (contains_text(opt.id, "skill"))
			continue; //Ignore skills if we have amnesia
		if (contains_text(opt.id, "use"))
			if(times_happened(opt.id) >= item_amount(to_item(to_int(excise(opt.id,"use ","")))))
				continue;	//Ignore items that we do not have that many of...
		if (kill_rounds(opt.dmg) > min(min(maxround, WHAM_maxround) - round - 1,drnd))
			continue;   // reduce RNG risk for stasisy actions
		if (opt.stun < 1 && to_profit(opt) < -runaway_cost())
			continue;  // don't choose actions worse than fleeing


		vprint("WHAM: Item option chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(to_profit(opt))+")", "purple", 8);
		return opt;
	}
	vprint("WHAM: No valid items.", "purple", 8);
	return new advevent;
}

// returns cheapest multi-round stun
advevent stun_option(int rounds) {
	if(rounds == 1) { //Don't stun if we will kill it directly
		vprint("WHAM: No need to stun this monster", "purple", 8);
		buytime = new advevent;
		return new advevent;
	}
	
	sort opts by -(to_profit(value)+meatperhp*m_dpr(-adj.att,0)*min(rounds+count(custom), value.stun - 1));
	foreach i,opt in opts {

		if (opt.stun - 1 < 1 || m_dpr(0,0) * 2 * meatperhp < (contains_text(opt.id, "skill") ? mp_cost(to_skill(to_int(excise(opt.id, "skill ", "")))) * meatpermp : historical_price(to_item(to_int(excise(opt.id, "use ", "")))) / opt.stun))
			continue;


		vprint("Stun option chosen: "+opt.id+" (round "+rnum(round)+", profit: "+rnum(opt.profit)+")",8);
		buytime = opt;
		return opt;
	}
	buytime = new advevent;
	vprint("WHAM: No profitable stun option", "purple", 8);
	return new advevent;
}

//Returns if you can use sauce splash effectively
boolean can_splash() {
	if(my_location() == $location[Fernswarthy's Basement] || my_class() != $class[sauceror] || !has_option($skill[Wave of Sauce]) || !has_option($skill[Saucegeyser])
		|| !(have_effect($effect[Jaba&ntilde;ero Saucesphere]) >0 || have_effect($effect[Jalape&ntilde;o Saucesphere]) >0)
		|| dmg_dealt(get_action($skill[Wave of Sauce]).dmg) >= monster_stat("hp") || have_effect($effect[temporary amnesia]) > 0)
	{
		vprint("WHAM: We can't Saucesplash.", -8);
		vprint(to_string(my_class() != $class[sauceror]) + ", " + to_string(!have_skill($skill[Wave of Sauce])) + ", " + to_string(!have_skill($skill[Saucegeyser]))
			+ ", " + to_string(!(have_effect($effect[Jaba&ntilde;ero Saucesphere]) >0 || have_effect($effect[Jalape&ntilde;o Saucesphere]) >0))
			+ ", " + to_string(dmg_dealt(get_action($skill[Wave of Sauce]).dmg) >= monster_stat("hp")), -9);
		return false;
	}
	switch(normalize_dmgtype("sauce")) {
		case "hot":		if(numeric_modifier("spell damage") + numeric_modifier("hot spell damage") >= 25)
							vprint("WHAM: We can do a hot Saucesplash.", 9);
						else
							vprint("WHAM: We can't Saucesplash due to too little bonus spell damage.", -9);
						return numeric_modifier("spell damage") + numeric_modifier("hot spell damage") >= 25;
		case "cold":	if(numeric_modifier("spell damage") + numeric_modifier("cold spell damage") >= 25)
							vprint("WHAM: We can do a cold Saucesplash.", 9);
						else
							vprint("WHAM: We can't Saucesplash due to too little bonus spell damage.", -9);
						return numeric_modifier("spell damage") + numeric_modifier("cold spell damage") >= 25;
	}
	if(numeric_modifier("spell damage") >= 25)
		vprint("WHAM: We can do a untyped Saucesplash.", 9);
	else
		vprint("WHAM: We can't Saucesplash since you have too little bonus spell damage.", -9);
	return numeric_modifier("spell damage") >= 25;
}

//Calculate options for all available spells, take damage from familiars, equipments and other sources into account
actions[int] Calculate_Options(float base_hp) {
	int i = 0;
	int starttime = gametime_to_int();
	advevent killer, delevel;
	actions[int] sorted_kill;
	boolean stun_enqueued, funking;

	allMyOptions(hitchance); //Set up the available options that we have
	
	killer = attack_option();
	stun = stun_option(kill_rounds(killer.dmg));
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
			if(stun.id != "" && !stun_enqueued) {

				enqueue(stun);
				kill_it[i].hp = monster_stat("hp");
				kill_it[i].my_hp = my_stat("hp");
				kill_it[i].profit = get_action(stun).profit;
				kill_it[i].options = stun.id;
				i += 1;
				killer = attack_option();
				stun_enqueued = true;



			}
			if(killer.id == "") {
				if(to_int(vars["verbosity"]) >= 10) {
					quit("WHAM: Unable to find a good way to kill the monster, not generating any data files.");
				}
				//There is no way of directly killing the mob in our current state, we need to either restore HP, MP or delevel
				//TODO: Add HP and MP restoration and weight those with deleveling
				delevel = delevel();
				while(delevel.id != "" && killer.id == "") {
					if(!enqueue(delevel))
						break;
					delevel = delevel();
					killer = attack_option();
					if(my_stat("hp") < m_dpr(0,0))
						break;
				}
				if(killer.id == "" && !to_boolean(vars["WHAM_AlwaysContinue"])) {
					vprint("WHAM: Unable to delevel until you can kill the monster without it killing you. Try it yourself.", "purple", 3);
					return sorted_kill;
				} else {
					vprint("WHAM: Could not find a way to kill the monster. Trying the best available option since you've set WHAM_AlwaysContinue to true.", "purple", 5);
					allMyOptions(hitchance); //Recalculate our options before doing this part
					sort myoptions by -to_profit(value);
					sort myoptions by kill_rounds(value.dmg)*-(min(value.profit,-1));
					enqueue(myoptions[0]);
					kill_it[i].hp = monster_stat("hp");
					kill_it[i].my_hp = my_stat("hp");
					kill_it[i].profit = (i == 0 ? get_action(myoptions[0]).profit : kill_it[i-1].profit + get_action(myoptions[0]).profit);
					kill_it[i].options = myoptions[0].id;
					reset_queue();
					act(page);
					return kill_it;
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
					if(!contains_text(killer.id, "use")) {
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
				//act(page); Why did I add this? I can't remember any longer...
				vprint("WHAM: Reached WHAM_round_limit while looking for a way to kill the monster. Executing the current strategy and continuing from there.", "purple", 3);
				if(to_int(vars["verbosity"]) < 10)
					return kill_it;
			}
		}
	}
		
	reset_queue();
	act(page);
	vprint("WHAM: Evaluating the attack but not performing it took " + (to_string(to_float(gametime_to_int() - starttime)/1000, "%.2f")) + " seconds.", "purple", 9);
	if(to_int(vars["verbosity"]) < 10)
		return kill_it;

	vprint("WHAM: Debug printing the damage dealt by your options.", "purple", 10);
	vprint(" ",10);
	allMyOptions();
	sort iterateoptions by -dmg_dealt(get_action(value).dmg);

	foreach num,sk in iterateoptions {
		matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",sk);
		if(find(aid)) {
			switch(aid.group(1)) {
				case "skill ":	vprint("WHAM: " + to_string(to_skill(to_int(excise(sk,"skill ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
				case "use ":	vprint("WHAM: " + to_string(to_item(to_int(excise(sk,"use ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
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

//Enqueue spells to kill the monster with and return this
string Perform_Actions() {
	record action {
		string macroid;
		string readableid;
	};
	action[int] cast;
	int splashcost;
	int go = 0;
	buffer print_this;
	string result;
	boolean splashing;
	
	for n from 0 to count(kill_it) -1 {
		cast[n].macroid = kill_it[n].options;
		matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",cast[n].macroid);
		if(find(aid)) {
			switch(aid.group(1)) {
				case "skill ":	cast[n].readableid = to_string(to_skill(to_int(excise(kill_it[n].options, "skill ", "")))); break;
				case "use ":	cast[n].readableid = to_string(to_item(to_int(excise(kill_it[n].options, "use ", "")))); break;
				case "attack":	cast[n].readableid = "attack with your weapon"; break;
				case "jiggle":	cast[n].readableid = "jiggle your chefstaff"; break;
			}
		}
	}
	clear(kill_it);
	
	if(cast[0].macroid == stun.id && count(cast) > 1) {
		vprint("WHAM: Enqueuing a stun to help with the battle", "purple", 3);
		if(!enqueue(get_action(cast[0].macroid)))
			quit("Failed to enqueue " + cast[0].readableid + ". Aborting to let you figure this out.");	
		go = 1;
	}
		
	//Between each cast, make sure we have MP to cast it
	for n from go to count(cast) - 1 {
		splashcost = mp_cost($skill[Wave of Sauce]) + mp_cost($skill[Saucegeyser]);
		
		//If we can splash, do so, but not if not one-shotting will kill us
		if(can_splash() && die_rounds() > 1 && (my_mp() + 0.25 * mp_cost($skill[Wave of Sauce])) >= splashcost) {
			if(enqueue($skill[Wave of Sauce]))
				vprint("WHAM: Enqueueing Wave of Sauce.", "purple",8);
			else
				vprint("WHAM: Unable to enqueue Wave of Sauce.", "purple",5);
			if(enqueue($skill[Saucegeyser]))
				vprint("WHAM: Enqueueing Saucegeyser.", "purple",8);
			else
				vprint("WHAM: Unable to enqueue Saucegeyser.", "purple",5);				
			if(count(queue) > 0)
				splashing = true;
			break;
		} else {
			vprint("WHAM: Enqueueing " + cast[n].readableid + " (macroid " + cast[n].macroid + ").", "purple", 7);
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
	}
		
	//Print the strategy
	if(!splashing) {
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
	} else {
		append(print_this,"WHAM: We are going to Saucesplash with Wave of Sauce and Saucegeyser");
	}
	vprint(print_this,"purple",4);
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

	page = special_actions();	//Perform special stuff that SS doesn't do

	if(finished())
		return "";

	kill_it = Calculate_Options(monster_stat("hp")); //Set up the damage dealt
		
	if(to_int(vars["verbosity"]) > 9) //With verbosity higher than 9 we definitely only want to debug. Do that and then stop.
		quit("Verbosity of 10 or more is set. Data files for denugging have been generated. Aborting.");
	
	if((count(kill_it) > 0)) {
		Perform_Actions();
		if(!finished() && monster_hp(m) == 0)
			adj.dmg[$element[none]] = max(1,adj.dmg[$element[none]] + monster_hp()); //Make sure we remember the damage done between iterations
	} else {
		if(to_int(vars["verbosity"]) >= 3) {
			vprint("WHAM: Unable to determine a valid combat strategy. For your benefit here are the numbers for you combat skills.", "purple", 3);
			allMyOptions();
			sort iterateoptions by -dmg_dealt(get_action(value).dmg);
			foreach num,sk in iterateoptions {
				matcher aid = create_matcher("(skill |use |attack|jiggle)(?:(\\d+),?(\\d+)?)?",sk);
				if(find(aid)) {
					switch(aid.group(1)) {
						case "skill ":	vprint("WHAM: " + to_string(to_skill(to_int(excise(sk,"skill ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
						case "use ":	vprint("WHAM: " + to_string(to_item(to_int(excise(sk,"use ","")))) + ": " + to_string(dmg_dealt(get_action(sk).dmg), "%.2f") + " potential damage (raw damage: " + spread_to_string(get_action(sk).dmg) + ") and a hitchance of " + to_string(hitchance(sk)*100, "%.2f") + "%.", (hitchance(sk) > hitchance ? "blue" : "red"), 3); break;
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

void SmartStasis() {
	vprint_html("Profit per round: "+to_html(baseround()),5);
	// custom actions
	build_custom();
	switch (m) {	// add boss monster items here since BatMan is not being consulted
		case $monster[conjoined zmombie]: 	for i from 1 upto item_amount($item[half-rotten brain])
												custom[count(custom)] = get_action("use 2562");
											break;
		case $monster[giant skeelton]: 	for i from 1 upto item_amount($item[rusty bonesaw])
											custom[count(custom)] = get_action("use 2563");
										break;
		case $monster[huge ghuol]:	for i from 1 upto item_amount($item[can of ghuol-b-gone])
										custom[count(custom)] = get_action("use 2565");
									break;
	}
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
	stasis();
	macro();
	vprint("WHAM: SmartStasis complete.", "purple", 7);
}

void main(int initround, monster foe, string pg) {
	pg=act(pg);
	int starttime = gametime_to_int();

	//Debug info
	vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);

	//Set unknown_ml for specific monsters Mafia doesn't handle and that have semi-spaded unknown_ml
	//Doing this before act() makes sure that batbrain uses our new unknown_ml-value
	set_unknown_ml(foe);
	
	//Set up the initial variables and skills	
	vprint("WHAM: Setting up variables via BatBrain", "purple", 8);
	act(pg);

	//Debug info
	vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);
	
	//Testing MP and HP restoration options

	vprint("WHAM: " + (mp_action(my_maxmp() - my_mp()).id == "" ? "You have no profitable MP restoratives." : "Your best MP restoring option available is: " + mp_action(my_maxmp() - my_mp()).id), "purple", 7);

	vprint("WHAM: " + (hp_action(my_maxhp() - my_hp()).id == "" ? "You have no profitable HP restoratives." : "Your best HP restoring option available is: " + hp_action(my_maxhp() - my_hp()).id), "purple", 7);
	
	//Debug printing for monster stats
	vprint("WHAM: You are fighting a " + to_string(m) + ". Mafia considers that this monster has an attack of " + monster_attack() + " or " + monster_attack(m) + " when given a monster name.", "purple", 9);
	vprint("WHAM: Mafia further considers that this monster has a defense value of " + monster_defense() + " or " + monster_defense(m) + " when given a monster name.", "purple", 9);
	vprint("WHAM: Mafia further further considers that this monster has a HP value of " + monster_hp() + " or " + monster_hp(m) + " when given a monster name.", "purple", 9);
	vprint("WHAM: Your current ML-adjustment is: " + monster_level_adjustment() + ".", "purple", 9);
	
	//Print base monster stats
	vprint("WHAM: Monster HP is " + (monster_hp(m) == 0 ? monster_stat("hp") + monster_hp() : monster_stat("hp")) + (bees(m) > 0 ? " which was increased by " + bees(m) * ceil(0.2 * monster_hp(m)) + " due to bees hating you." : "."), "purple", 4);
	
	//Add WHAM-specific stuff to batround
	WHAM_round();

	if(to_int(vars["verbosity"]) < 10 && my_location() != $location[Fernswarthy's Basement]) {
		//Call SmartStasis to do fun and complicated stuff
		vprint("WHAM: Running SmartStasis", "purple", 3);
		SmartStasis();
		WHAM_maxround = min(maxround, WHAM_maxround + round);
		vprint("WHAM: Running SmartStasis took " + (to_string(to_float(gametime_to_int() - starttime)/1000, "%.2f")) + " seconds.", "purple", 9);
	}
	
	//Debug info
	vprint("WHAM: We currently think that the round number is: " + round + " and that the turn number is " + my_turncount() + ".", "purple", 9);
	
	repeat {		
		if(finished()) { //Exit the script if SS ended the fight, || contains_text(page, "WINWINWIN") || (happened("use 2956") && last_monster() == $monster[clingy pirate])
			vprint("WHAM: SS has finished the fight. Aborting script execution. ", "purple", 9);
			exit;
		} else {
			vprint("WHAM: SS did not finish the fight, continuing with script execution. ", "purple", 9);
			//act(page); //Re-initialize all variables to be sure we are in a correct state
		}

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
	
	//Reset unknown_ml in case we changed it
	if(vars["unknown_ml"] != unknown_ml) {
		vars["unknown_ml"] = unknown_ml;
		updatevars();
	}
}