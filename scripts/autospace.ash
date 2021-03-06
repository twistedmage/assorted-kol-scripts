/*
stannius' semi-automatic spaaace script

What it Does:
* Completes the Repair the Elves' Shield Generator Quest.
* Burns adventures.
* Changes your equiment and effects.
* Uses items (see SETTINGS). Buys transponders (if needed, and mall is accessible and allowed by mafia settings) and cheap wind-up clocks.
* Changes familiars (unless the zlib var is_100_run is set)

What it Does Not/What you Should Do:
* See USER SETTINGS below
* It is up to you to create a custom combat script that will handle scaling monsters, preferably without taking damage. Might I suggest entangling noodles + an auto-hit skill (spell, shieldbutt, etc). Also, olfact "survivor" if you have olfaction.
* Leave an AT song slot free. (And keep in mind that the script changes equipment, so don't count on having four songs)
* Have in inventory: transponders, deodorant/pine needles, yellow candy hearts, and cheap wind-up clocks.
* If you have any suggestions, requests, problems, complaints, whatever... send stannius a kmail or (same name) gmail 
*/

// Script housekeeping
script "spaaace.ash";
import "zlib.ash";
check_version("stannius' semi-automatic spaaace script", "stannius_spaaace", "0.8", 6969);

/* USER SETTINGS
*  NOTE: after running this script, changing these variables here in the script will have no
*  effect. You can view ("zlib vars") or edit ("zlib <settingname> = <value>") values in the CLI.
*/
setvar("verbosity", 3); // shared setting for message verbosity
setvar("is_100_run", $familiar[none]); // shared setting for "100% familiar run"
setvar("spaaace_useitems", true); // use some items giving helpful effects (see "Have in inventory:" above). in the future, may include stunning/combat items.
setvar("spaaace_escortmanually", false); // set to true if you want to handle the "Escort Axel Otto around the moons" part of the quest yourself. It is the trickiest part.

/* END USER SETTINGS */

/// script variables
// uses its own mood. does not attempt to use user mood.
string MOOD_NAME = "stannius_spaaace";

// placeholder item to signify that it's time for the final step of the quest.
item REPAIR_GENERATOR_SIGNIFIER = $item[lunar isotope];

// list of AT songs used by this script, and their presence at script startup
boolean[skill] AT_songs_used;

// initial character settings. will attempt to restore at end of run
familiar previous_familiar;
string previous_mood;
int previous_MCD;

/// end script variables

/// <summary>
/// Fills a map of AT effects used by this script, and their current state at script startup.
/// </summary>
/// <remarks> Script will attempt not to shrug effects that were active at startup. If they run out, that's the user's responsibility.</remarks>
void GetAtEffectList()
{
    foreach skill in $skills[Carlweather's Cantata of Confrontation, Fat Leon's Phat Loot Lyric, Brawnee's Anthem of Absorption, Cletus's Canticle of Celerity]
    {
        AT_songs_used[skill] = (have_effect(to_effect(skill)) > 0);
    }
}

/// <summary>
/// Wrapper around vprint, that automatically gives things the colors I prefer.
/// </summary>
/// <param name="message">same as vprint</param>
/// <param name="level">same as vprint (zlib setting "verbosity")</param>
/// <returns>same as vprint</param>
boolean sprint(string message, int level)
{
    string get_color(int level)
    {
        switch(level)
        {
            case 1:
            case 4:
                return "green";
            case 2:
            case -2:
                return "purple";
            case 3:
            case -3:
            case 10:
                return "#ffA500"; // orange doesn't work due to a bug in java
            case 6:
            case -6:
                return "blue";
        }
        return "";
    }
    string color = get_color(level);
    
    if(color == "")
    {
        // default colors: if (level <= 0) red; else black;
        return vprint(message, level);
    } else {
        return vprint(message, color, level);
    }
}

void PrintSettingsInfo()
{
    void print_setting(string setting, string description)
    {
        sprint(setting + " = " + vars[setting] + " [" + description + "]", 4);
    }
    
    sprint("Using the following settings:", 4);
    print_setting("is_100_run", "100% familiar run; shared setting amongst many scripts");
    print_setting("spaaace_useitems", "use items for effects. e.g. transponders, yellow hearts, deodorant/pine needles.");
    print_setting("spaaace_escortmanually", "handle the \"escort mission\" part of the quest yourself.");
}

/// <summary>
/// Check for item in inventory.
/// </summary>
/// <param name="itemToCheck">item to look for</param>
/// <param name="failIfMissing">if true, item's non-presence is a fatal error, and method aborts (ash version of throwing an exception?)</param>
/// <returns>true if item is in inventory/equipped/etc</returns>
boolean ItemCheck(item itemToCheck, boolean failIfMissing)
{
    if(available_amount(itemToCheck) < 1)
    {
        if(failIfMissing){
            sprint("Unable to obtain " + itemToCheck + ".", 0);
        }
        else
        {
            sprint("Need " + itemToCheck + ".", 6);
        }
        return false;
    }
    else
    {
        return true;
    }
}

/// <summary>
/// Check for item in inventory.
/// </summary>
/// <param name="itemToCheck">item to look for</param>
/// <returns>true if item is in inventory/equipped/etc</returns>
boolean HasItem(item itemToCheck)
{
    return ItemCheck(itemToCheck, false);
}

/// <summary>
/// Check for item in inventory.
/// </summary>
/// <param name="itemToCheck">item to look for</param>
/// <returns>none. aborts if item is missing.</returns>
void AssertHasItem(item itemToCheck)
{
    ItemCheck(itemToCheck, true);
}

/// <summary>
/// Get an $item indicating what the next goal is in our quest.
/// </summary>
/// <returns>An $item object needed to advance the quest. May be a placeholder item, e.g. REPAIR_GENERATOR_SIGNIFIER.</returns>
item GetNextStep()
{
    sprint("Checking quest log for next step", 6);

    // We have to check a few things "backwards" because they consume items from previous steps

    string questLogPage2 = visit_url("questlog.php?which=2");

    if (contains_text(questLogPage2, "Congratulations! You've saved a few of the elves!"))
    {
        sprint("Quest Is Complete!", 1);
        return $item[none]; 
    }

    string questLogPage1 = visit_url("questlog.php?which=1");

    //After obtaining an E.M.U. Unit:
    if (contains_text(questLogPage1,"Find and repair the shield generator on Hamburglaris."))
    {
        sprint("Next step: Use the E.M.U. Unit to repair the generator on Hamburglaris.", 2);
        if(HasItem($item[E.M.U. Unit]))
        {
            return REPAIR_GENERATOR_SIGNIFIER;
        }
        else
        {
            sprint("... Except you don't have an E.M.U. Unit. Perhaps you lost Porko? Getting another one.", 2);
            sprint("Not returning from GetNextStep should backtrack to the appropriate items.", 10);
        }
    }

    //After finding a spooky little girl:
    if (HasItem($item[spooky little girl])
        //||contains_text(questLogPage1,"Escort Axel around the moons.") // this text still shows even if you lose the SLG
        )
    {
        AssertHasItem($item[spooky little girl]); // in the case of hitting quest log line above
        sprint("Next step: Escort Axel around the moons.", 2);
        return $item[E.M.U. Unit];
    }
    
    foreach nextItem in $items[
        E.M.U. rocket thrusters,
        E.M.U. joystick,
        E.M.U. harness,
        E.M.U. helmet,
        spooky little girl]
    {
        if(nextItem == $item[spooky little girl])
        {
            // this block of code is redundant. I guess I don't trust my understanding of ASH's loops.
            foreach nextItem in $items[
                E.M.U. rocket thrusters,
                E.M.U. joystick,
                E.M.U. harness,
                E.M.U. helmet]
            {
                AssertHasItem(nextItem);
            }
        }

        if(!HasItem(nextItem))
        {
            sprint("Next step: Acquire a(n) " + to_string(nextItem), 2);
            return nextItem;
        }
    }

    sprint("script bug in GetNextStep.", 0);
    return $item[none]; // will never be hit due to abort above. ash will not compile unless there is a return statement.
}

/// <summary>
/// If player has the skill, add it to the mood.
/// </summary>
/// <param name="skillname">skill to look for/add trigger for</param>
/// <returns>true if character has skill, false otherwise</returns>
/// <remarks>This does not use buffbots
/// This method only works for skills that are the same name as their effects</remarks>
boolean AddTriggerIfHaveSkill(string skillname)
{
    skill s = to_skill(skillname);
    if(have_skill(s))
    {
        cli_execute("trigger lose_effect, " + skillname + ", cast 1 " + skillname);

        // shrug other AT effect previously cast by this script
        if(AT_songs_used contains s) // is an AT song used by this script
        {
            foreach competingATSong in AT_songs_used {
                sprint("Checking " + competingATSong + " for shrugability", 10);
                if(competingATSong != s  // don't shrug the target effect :)
                    && !AT_songs_used[competingATSong] // don't shrug if the user cast the buff before running the script
                    && have_effect(to_effect(competingATSong)) > 0)
                {
                    sprint("Shrugging " + competingATSong + " to make room for " + skillname, 6);
                    cli_execute("shrug " + competingATSong);
                }
            }
        }

        return true;
    }
    else
    {
        return false;
    }
}

/// <summary>
/// If player has the item, add it to the mood.
/// </summary>
/// <param name="i">item to look for</param>
/// <param name="e">effect to add trigger for</param>
/// <param name="acquireFromNPC">if true, attempt to acquire from NPC stores</param>
/// <returns>true if added to mood</returns>
boolean AddTriggerIfHaveItem(item i, effect e, boolean acquireFromNPC)
{
    if(!to_boolean(vars["spaaace_useitems"]))
        return false;

    if(acquireFromNPC && 
        (available_amount(i) == 0) &&
        (npc_price(i) > 0)) // only buy from npc stores
    {
        buy(1, i);
    }
    
    if(available_amount(i) > 0)
    {
        cli_execute("trigger lose_effect, " + to_string(e) + ", use 1 " + to_string(i));
        return true;
    }
    else
    {
        sprint("A(n) " + to_string(i) + " would be helpful. Consider acquiring some.", 3);
        return false;
    }
}

/// <summary>
/// Manage equipment, effects, and familiar.
/// </summary>
/// <param name="targetItem">An $item object needed to advance the quest. May be a placeholder item, e.g. REPAIR_GENERATOR_SIGNIFIER.</param>
void GetDressedAndSetTheMood(item targetItem)
{
    string outfit = "";
    familiar sideOf = my_familiar();

    cli_execute("mood " + MOOD_NAME + "; mood clear");

    // Transpondent. If user doesn't want script to use items, abort instead.    
    cli_execute("trigger lose_effect, Transpondent, " + ((to_boolean(vars["spaaace_useitems"])) ? "use 1 transporter transponder" : "abort" ));

    // abort if user gets butt handed to them
    cli_execute("trigger gain_effect, Beaten Up, abort");

    AddTriggerIfHaveSkill("leash of linguini");
    AddTriggerIfHaveSkill("springy fusilli");
    AddTriggerIfHaveSkill("empathy");

    switch(targetItem)
    {
        case REPAIR_GENERATOR_SIGNIFIER:
            sprint("Equipping E.M.U. unit", 6);
            outfit += "+equip e.m.u. unit,";
            // continue to the next case
        case $item[spooky little girl]:
            sideOf = best_fam("combat"); // combat means attack, not combat frequency
            outfit += "-combat";
            AddTriggerIfHaveSkill("smooth movement");
            AddTriggerIfHaveSkill("the sonata of sneakiness");
            if(!AddTriggerIfHaveItem($item[chunk of rock salt], $effect[fresh scent], false))
            {
                AddTriggerIfHaveItem($item[deodorant], $effect[fresh scent], false);
            }

            break;
        case $item[E.M.U. Unit]:
            sideOf = best_fam("dodge");
            outfit += "initiative, DA, DR, 1 hand, +equip spooky little girl, -0.001 moxie, -0.001 muscle"; // -moxie in an attempt to reduce damage taken; -muscle in an attempt to reduce monster HP
            if(!AddTriggerIfHaveSkill("Brawnee's Anthem of Absorption"))
            {
                // script promised to only use one AT song at a time. not sure which is more useful; both are somewhat marginal.
                AddTriggerIfHaveSkill("Cletus's Canticle of Celerity");
            }
            AddTriggerIfHaveItem($item[yellow candy heart], $effect[heart of yellow], false);
            AddTriggerIfHaveItem($item[cheap wind-up clock], $effect[ticking clock], true);

            break;
        default:
            sideOf = best_fam("items");
            outfit += "item";
            AddTriggerIfHaveSkill("Fat Leon's Phat Loot Lyric");
            break;
    }

    switch (my_primestat())
    {
        case $stat[Muscle]:
            outfit += ", +melee";
            if(targetItem != $item[E.M.U. Unit])
            {
                outfit += ", 1 hand, +shield";
            }
            break;
        case $stat[Mysticality]:
            outfit += ", +0.1 spell damage";
            break;
        case $stat[Moxie]:
            outfit += ", -melee";
            break;
    }
    outfit += ", 0.01 mainstat";

    sprint("maximize " + outfit, 10);
    maximize(outfit, false);

    if(sideOf != my_familiar() && sideOf != $familiar[none] && vars["is_100_run"] == $familiar[none])
    {
        sprint("Switching familiar to a side of " + to_string(sideOf), 3);
        use_familiar(sideOf);
    }
    else
    {
        sprint("Familiar not changed (" + to_string(sideOf) + "," + to_string(my_familiar()) + "," + vars["is_100_run"] + ")", 10);
    }
}

/// <summary>
/// Adventure in the given location until you acquire the given item.
/// </summary>
/// <param name="target">An $item object needed to advance the quest. May be a placeholder item, e.g. REPAIR_GENERATOR_SIGNIFIER.</param>
void AdventuresInSpaaace(item target, location loc)
{
    GetDressedAndSetTheMood(target);

    if(my_adventures() <= 0)
    {
        sprint("Ran out of adventures :(", 0);
    }

    cli_execute("conditions clear");
    add_item_condition( 1, target );

    adventure(my_adventures(), loc);
}

/// <summary>
/// Choose the specified choice in the specified choice adventure.
/// </summary>
/// <param name="choice">Choice adventure number</param>
/// <param name="option">Value of button to "click"</param>
/// <param name="name">Name of the button to "click". Not sure if or how this is used by kol.</param>
string NavigateChoiceAdventure(int choice, int option, string name)
{
    string urlifiedName = replace_string( name, " ", "+");
    return visit_url("choice.php?whichchoice=" + choice + "&option=" + option + "&choiceform1=" + urlifiedName + "&pwd");
}

/// <summary>
/// Parse the charpane to see how Axel is feeling
/// </summary>
/// <returns>int representing courage. 50 (max) if not found.</returns>
int CheckAxelCourageCounter()
{
    string charpane = visit_url("charpane.php");
    matcher courage_left = create_matcher("Axel Courage:(?:<[^>]*>)*(\\d+)" , charpane);
    if(courage_left.find()) {
        string courage_right = courage_left.group(1);
        sprint("Courage left " + courage_right, 10);
        return to_int(courage_right);
    }

    // the counter only shows up after one adventure with SLG
    sprint("Courage counter not found. Ass-u-ming 50", 10);
    return 50;
}

/// <summary>
/// Combat filter that substitutes "shieldbutt" with a different skill if you have SLG equipped.
/// </summary>
/// <param name="round"></param>
/// <param name="opp"></param>
/// <param name="text"></param>
/// <returns></returns>
/// <remarks>like a CCS, but in ASH. aka consult script</remarks>
string SubstituteOutShieldbutt(int round, string opp, string text)
{
    string configuredAction = get_ccs_action(round);
    if(configuredAction != "skill shieldbutt" ||
       !have_equipped($item[spooky little girl])) // this check is deliberately redundant with check in calling method.
    {
        return configuredAction;
    }

    sprint("shieldbutt won't work without a shield.", -3);
    foreach skill in $skills[lunging thrust-smack, thrust-smack, spectral snapper, clobber, toss]
    {
        if(have_skill(skill))
        {
            sprint("substituting skill " + to_string(skill), 3);
            return "skill " + to_string(skill);
        }
    }

    sprint("no suitable replacement action found. attempting a simple attack.", -2);
    return "attack with weapon";
}

/// <summary>
/// Acquires effect Transpondent if you don't already have it.
/// </summary>
boolean CheckTranspondence()
{
    if(have_effect($effect[Transpondent]) > 0)
        return true;
    if(vars["spaaace_useitems"] != "true")
    {
        sprint("You are not transpondent and have disabled item use. Use a transponder and try again.", 0);
        return false;
    }

    use_upto(1, $item[Transporter Transponder], true);
    return (have_effect($effect[Transpondent]) > 0);
}

/// <summary>
/// Adventure in a Domed City, one at a time, until Axel shows you the Laboratory
/// </summary>
/// <param="step">E.M.U. Unit, presumably.</param>
/// <returns>true for success, false otherwise</returns>
boolean BringAxelCarefullyOvertoNoncombat(item step)
{
    if(to_boolean(vars["spaaace_escortmanually"]))
    {
        sprint("It's time to escort Axel Otto. Deferring to you as requested.", -2);
        sprint("Equip spooky little girl and adventure in either Dome.", -2);
        sprint("(To have the script do this automatically, set \"zlib spaaace_escortmanually = false\")", 0);
        exit;
    }

    set_property( "choiceAdventure539", "1" );
    GetDressedAndSetTheMood(step);
    for i from 1 to 13 { // 13 should be enough adventures. ~10 turns escorting + 1 turn to get the Unit + 1 to spare
        if(my_adventures() <= 0)
        {
            sprint("Ran out of adventures :(", 0);
            return false;
        }

        int axelCourageBefore = CheckAxelCourageCounter();

        // adventure only one adventure (at a time)
        // automagically replace "shieldbutt" with a different skill in the CCS, since the player obviously doesn't have a shield equipped.
        // don't add condition. it prevents one-at-a-time adventuring
        adventure(1, $location[Domed City of Grimacia], "SubstituteOutShieldbutt"); // either location would work
    
        string suggestion = "Add some buffs/item effects to \n    increase weapon or spell damage (kill them quicker)\n    boost init (less chance for them to hit you), \n    DA, DR, etc. (when they hit you, it hurts less)\nAnd/or stun the monsters, with noodles and/or combat items.";
        if(available_amount(step) >= 1)
        {
            sprint(to_string(step) + " obtained", 6);
            // only code path in this method which returns success
            return true;
        }
        else if(available_amount($item[spooky little girl]) <= 0)
        {
            sprint("Spooky little girl missing. Perhaps you took too much damage? \n" + suggestion + "... and try again.", 0);
        }
        else if ((axelCourageBefore - CheckAxelCourageCounter()) > 5)
        {
            sprint("You took some hits there. You might want to abort (press/hold down Esc key) \nand " + suggestion, -3);
        }
    }
    // if we didn't reurn true above, we failed
    return false; 
}

/// <summary>
/// Play the special-purpose Porko game FTW!
/// </summary>
/// <returns>true for success, false otherwise</returns>
/// <remarks>Is it possible to lose this game?</remarks>
boolean PlayPorkoToSaveTheWorld()
{
    sprint("Clearing out any residual lastPorkoExpected data from previous games", 10);
    set_property("lastPorkoExpected", "");

    NavigateChoiceAdventure(538, 1, "See what you have to lose");

    sprint("Hitting choice.php again, with no arguments, to load the board into mafia." + get_property("lastPorkoExpected"), 10); // thanks bumpork
    string national_pork_board = visit_url("choice.php");
    string porkoProbs = get_property("lastPorkoExpected");
    sprint("Probablities: " + porkoProbs, 6);

    string [int] bananaSplit = split_string(porkoProbs,":");
    int iBest = 5;
    float bestOdds = -1.0;
    foreach index in bananaSplit {
        float valueOfChoice = to_float(bananaSplit[index]);
        if(valueOfChoice > bestOdds)
        {
            iBest = index + 1; // array is 0-based, choices are 1-based
            bestOdds = valueOfChoice;
        }
    }

    sprint ("best choice is " + iBest + " at " + bestOdds + " ev.", 3);
    if(bestOdds != 1.0)
    {
        sprint("lastPorkoExpected does not contain the expected 100% chance of success (no more and no less). This is possibly stale data and/or a programming error.", 0);
    }

    string result = NavigateChoiceAdventure(540, iBest, "Irrelevant text");
    return result.contains_text("WHOOMPWHOOMPWHOOMP");
}

/// <summary>
/// Adventure in Hamburglaris, one at a time, until you hit Big Time Generator
/// </summary>
/// <param="step">REPAIR_GENERATOR_SIGNIFIER, presumably.</param>
/// <returns>true for success, false otherwise</returns>
boolean HamburglarisAdventureManually(item step)
{
    sprint("Adventuring one adventure at a time in the generator.", 6);
    // due to choice adventure, have to handle this ourselves
    GetDressedAndSetTheMood(step);

    boolean repairComplete = false;
    while(my_adventures() > 0 && !repairComplete)
    {
        sprint("repairComplete = " + repairComplete, 10);
        // manually visit adventure page
        string url = visit_url(to_url($location[Hamburglaris Shield Generator]));

        if (url.contains_text("Combat"))
        {
            run_combat();        
        }
        else if (url.contains_text("Big-Time Generator"))
        {
            repairComplete = PlayPorkoToSaveTheWorld();
            sprint("repairComplete = " + repairComplete, 10);

            string reward = visit_url("spaaace.php?place=grimace"); // get reward
            if(!repairComplete || !reward.contains_text("lunar isotopes"))
            {
                sprint("Lost Porko. This should not happen and probably indicates lag/and or a bug.", 0);
            }
        }
        else
        {
            sprint("Unexpected choice adventure. Deferring to kolmafia.", 6);
            adv1($location[Hamburglaris Shield Generator], -1, "");
        }
    }
    return repairComplete;
}

/// <summary>
/// Perform one sub-step of the quest.
/// </summary>
/// <param name="step">An $item object needed to advance the quest. May be a placeholder item, e.g. REPAIR_GENERATOR_SIGNIFIER.</param>
void PerformStep(item step)
{
    if(step == $item[ none ] // signifies quest complete or error condition. this should not happen but check just in case.
        || (step != REPAIR_GENERATOR_SIGNIFIER // possible to get the placeholder item in combats, so don't do this check
            && available_amount(step) >= 1)) // already have the item, nothing to do here
    {
        sprint("Step " + step  + " is already complete", -6);
        return;
    }

    boolean success = true;
    switch(step)
    {
        case $item[Map to Safety Shelter Ronald Prime]:
            AdventuresInSpaaace(step, $location[Domed City of Ronaldus]);
            break;
        case $item[Map to Safety Shelter Grimace Prime]:
            AdventuresInSpaaace(step, $location[Domed City of Grimacia]);
            break;
        case $item[E.M.U. rocket thrusters]:
            PerformStep($item[Map to Safety Shelter Ronald Prime]);

            if(!CheckTranspondence())
                break;

            visit_url("inv_use.php?which=3&whichitem=5171&pwd");
            NavigateChoiceAdventure(535, 1, "Take a Look Around");
            NavigateChoiceAdventure(535, 1, "Try the Swimming Pool");
            NavigateChoiceAdventure(535, 2, "To the Left, to the Left");
            NavigateChoiceAdventure(535, 1, "Take the Red Door");
            NavigateChoiceAdventure(535, 1, "Step through the Glowy-Orange Thing");
            
            break;
        case $item[E.M.U. joystick]:
            PerformStep($item[Map to Safety Shelter Ronald Prime]);

            if(!CheckTranspondence())
                break;

            visit_url("inv_use.php?which=3&whichitem=5171&pwd");
            NavigateChoiceAdventure(535, 1, "Take a Look Around");
            NavigateChoiceAdventure(535, 2, "Check out the Armory");
            NavigateChoiceAdventure(535, 2, "My Left Door");
            NavigateChoiceAdventure(535, 1, "Crawl through the Ventilation Duct");
            NavigateChoiceAdventure(535, 1, "Step through the Glowy Thingy");

            break;
        case $item[E.M.U. harness]:
            PerformStep($item[Map to Safety Shelter Grimace Prime]);

            if(!CheckTranspondence())
                break;

            visit_url("inv_use.php?which=3&whichitem=5172&pwd");
            NavigateChoiceAdventure(536, 1, "Down the Hatch!");
            NavigateChoiceAdventure(536, 2, "Check Out The Coat Check");
            NavigateChoiceAdventure(536, 1, "Exit, Stage Left");
            NavigateChoiceAdventure(536, 2, "Be the Duke of the Hazard");
            NavigateChoiceAdventure(536, 1, "Enter the Transporter");

            break;
        case $item[E.M.U. helmet]:
            PerformStep($item[Map to Safety Shelter Grimace Prime]);

            if(!CheckTranspondence())
                break;

            visit_url("inv_use.php?which=3&whichitem=5172&pwd");
            NavigateChoiceAdventure(536, 1, "Down the Hatch!");
            NavigateChoiceAdventure(536, 2, "Check Out The Coat Check");
            NavigateChoiceAdventure(536, 2, "Stage Right, Even");
            NavigateChoiceAdventure(536, 2, "Try the Starboard Door");
            NavigateChoiceAdventure(536, 1, "Step Through the Transporter");

            break;
        case $item[spooky little girl]:
            AdventuresInSpaaace(step, $location[Domed City of Ronaldus]); // either location would work
            break;
        case $item[E.M.U. Unit]:
            success = BringAxelCarefullyOvertoNoncombat(step);
            break;
        case REPAIR_GENERATOR_SIGNIFIER:
            success = HamburglarisAdventureManually(step);
            break;
        default:
            sprint("Programmer error: unsupported case statement", 0);
    }

    // check for success
    if(!success || available_amount(step) <= 0)
        sprint("failure to perform step", 0);
}

void SaveInitialSettings()
{
    sprint("Saving initial character state.", 3);

    GetAtEffectList();

    // copied from nemesis.ash
    cli_execute( "checkpoint" );
    previous_familiar = my_familiar();
    previous_mood = get_property( "currentMood" );
    previous_MCD = current_mcd();
    if ( previous_MCD > 0 ) change_mcd( 0 );	// you weren't that anxious to get stats, were you?

    cli_execute("conditions clear");

    //string previous_battleaction = get_property( "battleAction" );
    //string previous_CCS = get_property( "customCombatScript" );
    //string previous_autoSteal = get_property( "autoSteal" );
    //string previous_autoEntangle = get_property( "autoEntangle" );
    //int previous_autoattack = get_auto_attack();
    //set_auto_attack( 0 );
}

void RestoreInitialSettings()
{
    sprint("Restoring initial character state.", 3);

    use_familiar( previous_familiar );
    cli_execute ( "mood "+previous_mood );
    if ( previous_MCD > 0 ) change_mcd( previous_MCD );
    cli_execute("conditions clear");
}

void main()
{
    PrintSettingsInfo();
    SaveInitialSettings();

    try
    {
        item nextStep;
        repeat {
            nextStep = GetNextStep();
            PerformStep(nextStep);
        } until (nextStep == $item[ none ]);
    }
    finally
    {
        RestoreInitialSettings();
    }
}

/*
Changelog
0.1 Initial version
0.2 Changes to equipment maximization: Add "1 hand" when SLG is equipped; don't equip shield and SLG at the same time. 
    Use consult script/filter that mostly passes through, but replaces shieldbutt with LTS when SLG is equipped.
    Fix infinite loops in Porko code. (Oops. Unfortunately I wasn't able to test this code in the first version.)
    Add comments.
0.3 Add version checking
    Fix off-by-one error in PlayPorko
    Use MOOD_NAME variable
0.4 Uses only one AT song at a time. Allow user to keep two others (not three, due to equipment changing). Shrug the one that was cast by this script, if any.
    Use zlib's sprint logging method to manage verbosity of messages
    Don't set condition in Escort step; it was aborting the script.
0.5 Reacquire SLG after losing her. (still aborts in this case; bug fix is to gracefully restart)
    Abort if the best PorkoProb is not exactly 1.0.
    Use Canticle and/or yellow candy hearts during SLG quest, if available. (I don't know what % of people have canticle vs. brawnee's anthem.)
0.6 Fix bug with porko game not actually checking the probabilities
    Keep track of Axel's "courage" and warn user if it is going down too fast. Leave it to them to abort.
    Give a low weight to "-moxie" in SLG maximization and add "-muscle" for a simliar purpose
    Adventure in Grimacia for the SLG and Ronaldus with the SLG (since either location would work for either step. and I think variety is a virtue.)
    Remove version number from "official" script name.
0.7 Abort if beaten up
    Change familiars (using zlib's best_fam. honors is_100_run)
    Save some user settings at start of execution. Restore them when complete.
    Add user preferences for: item use; abort when it's time for escort mission;
    Use cheap wind-up clocks (buys them from NPC store if available)
    Expand message upon losing SLG
0.8     
*/