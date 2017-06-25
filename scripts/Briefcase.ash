since r18080;
//Briefcase.ash
//Usage: "briefcase help" in the graphical CLI.
//Also includes a relay override.

string __briefcase_version = "1.1";
//Debug settings:
boolean __setting_enable_debug_output = false;
boolean __setting_debug = false;

boolean __setting_confirm_actions_that_will_use_a_click = false;

boolean __setting_output_help_before_main = false;

boolean __setting_do_not_actually_use_clicks = false; //FIXME only partially implemented, and only use with confirm_actions

//Utlity:
//Mafia's text output doesn't handle very long strings with no spaces in them - they go horizontally past the text box. This is common for to_json()-types.
//So, add spaces every so often if we need them:
buffer processStringForPrinting(string str)
{
    buffer out;
    int limit = 50;
    int comma_limit = 25;
    int characters_since_space = 0;
    for i from 0 to str.length() - 1
    {
    	if (str.length() == 0) break;
        string c = str.char_at(i);
        out.append(c);
        
        if (c == " ")
            characters_since_space = 0;
        else
        {
            characters_since_space++;
            if (characters_since_space >= limit || (c == "," && characters_since_space >= comma_limit)) //prefer adding spaces after a comma
            {
                characters_since_space = 0;
                out.append(" ");
            }
        }
    }
    return out;
}

void printSilent(string line, string font_colour)
{
    print_html("<font color=\"" + font_colour + "\">" + line.processStringForPrinting() + "</font>");
}

void printSilent(string line)
{
    print_html(line.processStringForPrinting());
}

void listAppend(string [int] list, string entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(int [int] list, int entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

int [int] listCopy(int [int] l)
{
    int [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

string listJoinComponents(string [int] list, string joining_string, string and_string)
{
	buffer result;
	boolean first = true;
	int number_seen = 0;
	foreach i, value in list
	{
		if (first)
		{
			result.append(value);
			first = false;
		}
		else
		{
			if (!(list.count() == 2 && and_string != ""))
				result.append(joining_string);
			if (and_string != "" && number_seen == list.count() - 1)
			{
				result.append(" ");
				result.append(and_string);
				result.append(" ");
			}
			result.append(value);
		}
		number_seen = number_seen + 1;
	}
	return result.to_string();
}

string listJoinComponents(string [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(int [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert ints to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(int [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


boolean stringHasPrefix(string s, string prefix)
{
	if (s.length() < prefix.length())
		return false;
	else if (s.length() == prefix.length())
		return (s == prefix);
	else if (substring(s, 0, prefix.length()) == prefix)
		return true;
	return false;
}

boolean [string] listInvert(string [int] list)
{
	boolean [string] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

string [int] listInvert(boolean [string] list)
{
    string [int] out;
    foreach m, value in list
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

//x^p
int powi(int x, int p)
{
    return x ** p;
}

int [int] stringToIntIntList(string input, string delimiter)
{
	int [int] out;
	if (input == "")
		return out;
	foreach key, v in input.split_string(delimiter)
	{
		out.listAppend(v.to_int());
	}
	return out;
}

int [int] stringToIntIntList(string input)
{
	return stringToIntIntList(input, ",");
}

//File state:
boolean __did_read_file_state = false;
string [string] __file_state;
string __file_state_filename = "kgbriefcase_tracking_" + my_id() + ".txt";


void writeFileState()
{
    if (!__did_read_file_state)
        return;
    map_to_file(__file_state, __file_state_filename);
}

void readFileState()
{
    file_to_map(__file_state_filename, __file_state);
    __did_read_file_state = true;
    
    //Reset if our ascension number changes:
    if (__file_state["filestate last ascension number"].to_int() != my_ascensions())
    {
    	string [string] blank_state;
    	__file_state = blank_state;
    	__file_state["filestate last ascension number"] = my_ascensions();
    	writeFileState();
    }
    if (__file_state["filestate last daycount"].to_int() != my_daycount())
    {
    	//Clear dailies:
        foreach key in __file_state
        {
            if (key.length() > 0 && key.stringHasPrefix("_"))
            {
                //printSilent("deleting key \"" + key + "\"");
                remove __file_state[key];
            }
        }
    	__file_state["filestate last daycount"] = my_daycount();
    	writeFileState();
    }
	
}

readFileState();
int convertTabConfigurationToBase10(int [int] configuration, int [int] permutation)
{
	//We don't need to know permutations for this:
	if (configuration.count() == 6 && configuration[0] == 2 && configuration[1] == 2 && configuration[2] == 2 && configuration[3] == 2 && configuration[4] == 2 && configuration[5] == 2)
		return 728;
	if (configuration.count() == 6 && configuration[0] == 0 && configuration[1] == 0 && configuration[2] == 0 && configuration[3] == 0 && configuration[4] == 0 && configuration[5] == 0)
		return 0;
	if (permutation.count() != 6)
		return 0;
	int base_ten = 0;
	foreach i in configuration
	{
		int v = configuration[i];
		if (v < 0 || v > 2)
			return -1;
		int permutation_index = permutation[i];
		base_ten += v * powi(3, 5 - permutation_index);
	}
	return base_ten;
}

boolean configurationsAreEqual(int [int] configuration_a, int [int] configuration_b)
{
	if (configuration_a.count() != configuration_b.count()) return false;
	foreach i in configuration_a
	{
		if (configuration_a[i] != configuration_b[i]) return false;
	}
	return true;
}

//Briefcase state and parsing:
int LIGHT_STATE_UNKNOWN = -1;
int LIGHT_STATE_OFF = 0;
int LIGHT_STATE_BLINKING = 1;
int LIGHT_STATE_ON = 2;

int ACTION_TYPE_UNKNOWN = -1;
int ACTION_TYPE_NONE = 0;
int ACTION_TYPE_LEFT_ACTUATOR = 1;
int ACTION_TYPE_RIGHT_ACTUATOR = 2;
int ACTION_TYPE_BUTTON = 3;
int ACTION_TYPE_TAB = 4;

int [int] __button_functions = {-1, 1, -10, 10, -100, 100};

Record BriefcaseState
{
	int [int] dial_configuration; //0 to 5
	int [int] horizontal_light_states; //1 to 6
	int [int] tab_configuration; //1 to 6
	int [int] vertical_light_states; //1 to 3
	
	boolean crank_unlocked;
	boolean left_drawer_unlocked;
	boolean right_drawer_unlocked;
	boolean martini_hose_unlocked;
	boolean antennae_unlocked;
	boolean buttons_unlocked;
	
	boolean handle_up;
	
	int antennae_charge;
	int lightrings_number; //0 for none
	
	boolean [string] last_action_results;
};


string BriefcaseLightDescriptionShort(int status)
{
	if (status == LIGHT_STATE_OFF)
		return "0";
	else if (status == LIGHT_STATE_ON)
		return "1";
	else if (status == LIGHT_STATE_BLINKING)
		return "B";
	else
		return "?";
}

string convertDialConfigurationToString(int [int] dial_configuration)
{
	string out;
	for i from 0 to 5
	{
		if (dial_configuration[i] == 10)
			out += "A";
		else
			out += dial_configuration[i];
		if (i == 2)
			out += "-";
	}
	return out;
}

string [int] BriefcaseStateDescription(BriefcaseState state)
{
	string [int] description;
    
    int clicks_used = MAX(get_property("_kgbClicksUsed").to_int(), __file_state["_clicks"].to_int());
	
	string clicks_line = "Clicks used: " + clicks_used;
	int clicks_limit = 11;
	if (__file_state["_flywheel charged"].to_boolean())
		clicks_limit = 22;
		
	int clicks_remaining = MAX(0, clicks_limit - clicks_used);
	if (clicks_remaining > 0)
		clicks_line += " (<strong>" + clicks_remaining + "</strong>? remaining)";
	description.listAppend(clicks_line);
    
    
	string dials_line = "Dials: ";
	dials_line += convertDialConfigurationToString(state.dial_configuration);
	description.listAppend(dials_line);
	
	string horizontal_lights_line = "Horizontal lights: ";
	for i from 1 to 6
		horizontal_lights_line += BriefcaseLightDescriptionShort(state.horizontal_light_states[i]);
	description.listAppend(horizontal_lights_line);
	
	string tab_configuration_line = "Tab configuration: ";
	for i from 0 to 5
		tab_configuration_line += state.tab_configuration[i];
	
	if (__file_state["tab permutation"] != "")
		tab_configuration_line += " (" + convertTabConfigurationToBase10(state.tab_configuration, stringToIntIntList(__file_state["tab permutation"])) + ")";
	description.listAppend(tab_configuration_line);
	
	description.listAppend("Mastermind lights: " + BriefcaseLightDescriptionShort(state.vertical_light_states[1]) + BriefcaseLightDescriptionShort(state.vertical_light_states[2])  + BriefcaseLightDescriptionShort(state.vertical_light_states[3]));
	
	string [int] things_unlocked;
	if (state.crank_unlocked)
		things_unlocked.listAppend("crank");
	if (state.left_drawer_unlocked)
		things_unlocked.listAppend("left drawer");
	if (state.right_drawer_unlocked)
		things_unlocked.listAppend("right drawer");
	if (state.martini_hose_unlocked)
		things_unlocked.listAppend("martini hose");
	if (state.antennae_unlocked)
		things_unlocked.listAppend("antennae");
	if (state.buttons_unlocked)
		things_unlocked.listAppend("buttons");
	
	description.listAppend("Unlocked: " + things_unlocked.listJoinComponents(", ", "and"));
	if (state.handle_up)
		description.listAppend("Handle: UP");
	else
		description.listAppend("Handle: DOWN");
	if (state.antennae_unlocked)
		description.listAppend("Antennae charge: " + state.antennae_charge);
	if (state.lightrings_number > 0)
		description.listAppend("lightrings: lightrings" + state.lightrings_number + ".gif");
		
	if (state.last_action_results.count() > 0)
		description.listAppend("Last action results: " + state.last_action_results.listInvert().listJoinComponents(", "));
	
	if (__file_state["_out of clicks for the day"].to_boolean())
		description.listAppend("<font color=\"red\">Out of clicks for the day.</font>");
	return description;
}

int [int] parseTabState(buffer page_text)
{
	int [int] tab_configuration;
	for tab_id from 0 to 5
	{
		string [int][int] matches = page_text.group_string("<div id=kgb_tab" + (tab_id + 1) + "[^>]*>(.*?)</div>");
		string line = matches[0][1];
		int value = -1;
		if (line.contains_text("A Short Tab"))
			value = 1;
		else if (line.contains_text("A Long Tab"))
			value = 2;
		else
			value = 0;
		tab_configuration[tab_id] = value;
	}
	return tab_configuration;
}

string constructTabIdentifierForTab(int pressed_tab_number, int pressed_tab_state)
{
	buffer tab_identifier;
	if (pressed_tab_number > 1)
	{
		for i from 1 to pressed_tab_number - 1
		{
			tab_identifier.append("x");
		}
	}
	tab_identifier.append(pressed_tab_state);
	if (pressed_tab_number < 6)
	{
		for i from pressed_tab_number + 1 to 6
		{
			tab_identifier.append("x");
		}
	}
	return tab_identifier.to_string();
}

BriefcaseState __state;
BriefcaseState parseBriefcaseStatePrivate(buffer page_text, int action_type, int action_number)
{
	if (page_text.length() == 0)
	{
		abort("Unable to load briefcase?");
	}
	if (page_text.contains_text("<script>document.location.reload();</script>"))
	{
		//We should reload the page for state:
		print_html("Revisiting page...");
		page_text = visit_url("place.php?whichplace=kgb");
	}
	BriefcaseState state;
	//Intruder alert! Red spy is in the base!
	//Protect the briefcase!
	
	for dial_id from 1 to 6
	{
		string [int][int] matches = page_text.group_string("href=place.php.whichplace=kgb&action=kgb_dial" + dial_id + "><img src=\".*?/otherimages/kgb/char(.).gif\"");
		string c = matches[0][1];
		//printSilent("c = \"" + c + "\"");
		if (c == "a")
			state.dial_configuration[dial_id - 1] = 10;
		else
			state.dial_configuration[dial_id - 1] = c.to_int();
		//state.dial_configuration[dial_id]
	}
	for light_id from 1 to 6
	{
		string [int][int] matches = page_text.group_string("<div id=kgb_light" + light_id + ".*?otherimages/kgb/light_(.*?)\.gif");
		string light_state_string = matches[0][1];
		//printSilent(light_id + " light_state_string = \"" + light_state_string + "\"");
		int light_state = LIGHT_STATE_UNKNOWN;
		if (light_state_string == "off")
			light_state = LIGHT_STATE_OFF;
		if (light_state_string == "blinking")
			light_state = LIGHT_STATE_BLINKING;
		if (light_state_string == "on")
			light_state = LIGHT_STATE_ON;
		
		state.horizontal_light_states[light_id] = light_state;
	}
	state.tab_configuration = parseTabState(page_text);
	for mastermind_id from 1 to 3
	{
		string [int][int] matches = page_text.group_string("<div id=kgb_mastermind" + mastermind_id + ".*?otherimages/kgb/light_(.*?)\.gif");
		string light_state_string = matches[0][1];
		int light_state = LIGHT_STATE_UNKNOWN;
		if (light_state_string == "off")
			light_state = LIGHT_STATE_OFF;
		if (light_state_string == "blinking")
			light_state = LIGHT_STATE_BLINKING;
		if (light_state_string == "on")
			light_state = LIGHT_STATE_ON;
		state.vertical_light_states[mastermind_id] = light_state;
	}
	
	state.crank_unlocked = page_text.contains_text("place.php?whichplace=kgb&action=kgb_crank");
	state.left_drawer_unlocked = page_text.contains_text("place.php?whichplace=kgb&action=kgb_drawer2");
	state.right_drawer_unlocked = page_text.contains_text("place.php?whichplace=kgb&action=kgb_drawer1");
	state.martini_hose_unlocked = page_text.contains_text("place.php?whichplace=kgb&action=kgb_dispenser");
	state.antennae_unlocked = page_text.contains_text("otherimages/kgb/ladder");
	
	state.handle_up = !page_text.contains_text("place.php?whichplace=kgb&action=kgb_handledown");
	
	string [int][int] ladder_matches = page_text.group_string("otherimages/kgb/ladder([0-8]).gif");
	if (ladder_matches.count() > 0)
		state.antennae_charge = ladder_matches[0][1].to_int();
	string [int][int] lightrings_matches = page_text.group_string("otherimages/kgb/lightrings([0-6]).gif");
	if (lightrings_matches.count() > 0)
		state.lightrings_number = lightrings_matches[0][1].to_int();
	state.buttons_unlocked = page_text.contains_text("otherimages/kgb/button.gif");
	
	
	
	//Parse results:
	string results_string = page_text.group_string("<b>Results:</b></td></tr><tr><td style=\"padding: 5px; border: 1px solid blue;\"><center><table><tr><td>(.*?)</td></tr></table>")[0][1];
	
	string [int] results = split_string(results_string, "<br>");
	
	
	foreach key, result in results
	{
		//Filter out common nonsense:
		if (result == "" || result == "You grab your KGB.")
			continue;
		state.last_action_results[result] = true;
	}
	if (state.last_action_results.count() > 0 && __setting_enable_debug_output)
		printSilent("Results: \"" + state.last_action_results.listInvert().listJoinComponents("\" / \"").entity_encode() + "\"", "gray");
	
	//Do some post-processing:
	if (state.last_action_results["Click!"])
	{
		if (my_id() == 1557284)
			print("KGBRIEFCASEDEBUG: Click!");
		__file_state["_clicks"] =__file_state["_clicks"].to_int() + 1;
		writeFileState();
	}
	if (state.last_action_results["Click click click!"])
	{
		if (my_id() == 1557284)
			print("KGBRIEFCASEDEBUG: Click click click!");
		__file_state["_clicks"] =__file_state["_clicks"].to_int() + 3;
		writeFileState();
	}
	if (state.last_action_results["Nothing happens. Hmm. Maybe it's out of... clicks?  For the day?"])
	{
		if (my_id() == 1557284)
			print("KGBRIEFCASEDEBUG: Out of... clicks? For the day?");
		//__file_state["_clicks"] = 22;
		__file_state["_out of clicks for the day"] = true;
		writeFileState();
	}
	//This seems to be inaccurate at the moment, so don't draw conclusions:
	if (__file_state["_clicks"].to_int() >= 22 && !__file_state["_out of clicks for the day"].to_boolean() && false)
	{
		__file_state["_out of clicks for the day"] = true;
		writeFileState();
	}
	
	if (state.horizontal_light_states[1] == LIGHT_STATE_ON && state.horizontal_light_states[2] != LIGHT_STATE_ON && (action_type == ACTION_TYPE_LEFT_ACTUATOR || action_type == ACTION_TYPE_RIGHT_ACTUATOR) && state.last_action_results["You press the lock actuator to the side."] && !state.last_action_results["You hear a mechanism whirr for a moment inside the case on the left side."] && !state.last_action_results["You hear a mechanism whirr for a moment inside the case on the right side."])
	{
		//printSilent("Logging mastermind...");
		//Save the mastermind state:
		string line;
		if (action_type == ACTION_TYPE_LEFT_ACTUATOR)
			line += "L|";
		else
			line += "R|";
		line += state.dial_configuration.listJoinComponents(",") + "|" + state.vertical_light_states.listJoinComponents(",");
		if (__file_state["mastermind log"].length() != 0)
			__file_state["mastermind log"] += "•";
		__file_state["mastermind log"] += line;
		writeFileState();
	}
	
	if (state.last_action_results["You press a button on the side of the case."] && action_type == ACTION_TYPE_BUTTON)
	{
		boolean tabs_are_moving = false;
		boolean should_write = true;
		int [int] current_tab_configuration = state.tab_configuration.listCopy();
		if (state.horizontal_light_states[3] == LIGHT_STATE_ON && !(__state.tab_configuration[0] == 0 && __state.tab_configuration[1] == 0 && __state.tab_configuration[2] == 0 && __state.tab_configuration[3] == 0 && __state.tab_configuration[4] == 0 && __state.tab_configuration[5] == 0)) //can't be moving, last was 0,0,0,0,0,0
		{
			//Are they moving?
			buffer page_text_2 = visit_url("place.php?whichplace=kgb");
			state.tab_configuration = parseTabState(page_text_2);
			if (!configurationsAreEqual(current_tab_configuration, state.tab_configuration))
			{
				tabs_are_moving = true;
			}
			if (current_tab_configuration[0] == 0 && current_tab_configuration[1] == 0 && current_tab_configuration[2] == 0 && current_tab_configuration[3] == 0 && current_tab_configuration[4] == 0 && current_tab_configuration[5] == 0) //there is no way to know if the tabs were moving; just don't write this one?
			{
				should_write = false;
			}
		}
		//Save previous tab state, button pressed, and current tab state:
		if (should_write)
		{
			string line;
			line += action_number + "|";
			line += __state.tab_configuration.listJoinComponents(",") + "|";
			line += current_tab_configuration.listJoinComponents(",");
			line += "|" + tabs_are_moving;
			if (__file_state["button tab log"].length() != 0)
				__file_state["button tab log"] += "•";
			__file_state["button tab log"] += line;
			writeFileState();
		}
	}
	if (state.last_action_results["You pull a tab out from the bottom of the case, and then it retracts to its original position."] && action_type == ACTION_TYPE_TAB)
	{
		//Save the result of the tab action:

		//Soooo... are the tabs moving? If so, we'll reject. (currently)
		int pressed_tab_number = action_number;
		int pressed_tab_state = state.tab_configuration[pressed_tab_number - 1];
		boolean tabs_are_moving = false;
		int [int] current_tab_configuration = state.tab_configuration.listCopy();
		if (state.horizontal_light_states[3] == LIGHT_STATE_ON)
		{
			//Are they moving?
			buffer page_text_2 = visit_url("place.php?whichplace=kgb");
			state.tab_configuration = parseTabState(page_text_2);
			if (!configurationsAreEqual(current_tab_configuration, state.tab_configuration))
			{
				tabs_are_moving = true;
			}
		}
		if (!tabs_are_moving)
		{
			boolean consistent_tab = true;
			int effect_number = -1; //using the 00X system
			if (state.last_action_results["(duration: 100 Adventures)"])
			{
				//The weird tab. I think this is random? Maybe? I dunno, I only heard whispers.
				consistent_tab = false;
			}
			foreach result in state.last_action_results
			{
				//Try to match effect image:
				string [int][int] matches = result.group_string("itemimages/effect00([0-9]+).gif");
				if (matches.count() > 0)
				{
					effect_number = matches[0][1].to_int();
				}
			}
			if (effect_number != -1)
			{
				if (!consistent_tab) //the 100-length tab is weird, we'll log it as 0
					effect_number = 0;
				//Now, we want to log this tab as having this effect:
				//Hmm, what format do we want?
				//	tab xxxx2x effect	5
				//	tab effect 5	xxxx2x
				//	tab effects	5|xxxx2x•6|1xxxxx
				//I think the second one? It seems the easiest to query? We can just iterate 0-11 for discovery purposes.
				//Oh, and "tab_number,state" is better.
				
				//Construct tab identifier:
				//string tab_identifier = constructTabIdentifierForTab(pressed_tab_number, pressed_tab_state);
				
				string file_key = "tab effect " + effect_number;
				__file_state[file_key] = pressed_tab_number + "," + pressed_tab_state;
				writeFileState();
			}
		}
	}
	
	if (state.last_action_results["As you flipped the handle down that last time, the case hopped up, spun around, and returned to its initial configuration."])
	{
		printSIlent("Reset detected.");
		string [string] saved_values;
		//FIXME we could save button tab log, except what if that's wrong?
		boolean [string] properties_to_save = $strings[_clicks,_flywheel charged];
		foreach key in properties_to_save
			saved_values[key] = __file_state[key];
		
		//print_html("saved_values = " + saved_values.to_json());
		string [string] blank;
		__file_state = blank;
		writeFileState();
		readFileState();
		
		foreach key in properties_to_save
			__file_state[key] = saved_values[key];
		__file_state["initial dial configuration"] = state.dial_configuration.listJoinComponents(",");
		writeFileState();
	}
	
	if (!(state.tab_configuration[0] == 0 && state.tab_configuration[1] == 0 && state.tab_configuration[2] == 0 && state.tab_configuration[3] == 0 && state.tab_configuration[4] == 0 && state.tab_configuration[5] == 0))
	{
		//Save lightrings value:
		string tab_configuration_string = state.tab_configuration.listJoinComponents(",");
		boolean found = false;
		foreach key, entry_string in __file_state["lightrings observed"].split_string("•")
		{
			if (entry_string == "") continue;
			string [int] entry = entry_string.split_string("\\|");
			if (entry[0] == tab_configuration_string)
			{
				found = true;
				break;
			}
		}
		if (!found)
		{
			if (__file_state["lightrings observed"].length() != 0)
				__file_state["lightrings observed"] += "•";
			__file_state["lightrings observed"] += tab_configuration_string + "|" + state.lightrings_number;
			writeFileState();
		}
	}
	
	foreach action in state.last_action_results
	{
		if (action.contains_text("You look inside the left-side drawer."))
		{
			__file_state["_left drawer collected"] = true;
			writeFileState();
		}
		if (action.contains_text("You look inside the right-side drawer."))
		{
			__file_state["_right drawer collected"] = true;
			writeFileState();
		}
		if (action.contains_text("You take out one of the tiny martini glasses and pour yourself a drink."))
		{
			__file_state["_martini hose collected"] = __file_state["_martini hose collected"].to_int() + 1;
			writeFileState();
		}
	}
	
	return state;
}

BriefcaseState parseBriefcaseStatePrivate(buffer page_text)
{
	return parseBriefcaseStatePrivate(page_text, ACTION_TYPE_NONE, -1);
}

void updateState(buffer page_text, int action_type, int action_number)
{
	__state = parseBriefcaseStatePrivate(page_text, action_type, action_number);
}

void updateState(buffer page_text)
{
	updateState(page_text, ACTION_TYPE_NONE, -1);
}
void actionSetDialsTo(int [int] dial_configuration)
{
	int breakout = 11 * 6 + 1;
	printSilent("Setting dials to " + convertDialConfigurationToString(dial_configuration) + "...");
	for i from 0 to 5
	{
		while (__state.dial_configuration[i] != dial_configuration[i] && breakout > 0)
		{
			breakout -= 1;
			//printSilent("Moving dial " + (i + 1) + "...", "gray");
			int [int] previous_dial_state = __state.dial_configuration.listCopy();
			updateState(visit_url("place.php?whichplace=kgb&action=kgb_dial" + (i + 1), false, false));
			if (configurationsAreEqual(__state.dial_configuration, previous_dial_state))
			{
				abort("Unable to interact with the briefcase?");
				return;
			}
			//printSilent("__state = " + __state.to_json());
		}
	}
}


void actionVisitBriefcase()
{
	printSilent("Loading briefcase...", "gray");
	updateState(visit_url("place.php?whichplace=kgb", false, false));
}

void actionPressLeftActuator()
{
	printSilent("Clicking left actuator...", "gray");
	if (__setting_confirm_actions_that_will_use_a_click && !user_confirm("READY?"))
		abort("Aborted.");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_actuator1", false, false), ACTION_TYPE_LEFT_ACTUATOR, -1);
}

void actionPressRightActuator()
{
	printSilent("Clicking right actuator...", "gray");
	if (__setting_confirm_actions_that_will_use_a_click && !user_confirm("READY?"))
		abort("Aborted.");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_actuator2", false, false), ACTION_TYPE_RIGHT_ACTUATOR, -1);
}

void actionManipulateHandle()
{
	printSilent("Toggling handle...", "gray");
	if (__state.handle_up)
		updateState(visit_url("place.php?whichplace=kgb&action=kgb_handleup", false, false));
	else
		updateState(visit_url("place.php?whichplace=kgb&action=kgb_handledown", false, false));
}

void actionSetHandleTo(boolean up)
{
	if (__state.handle_up != up)
		actionManipulateHandle();
}

void actionTurnCrank()
{
	printSilent("Turning crank.", "gray");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_crank", false, false));
}

void actionPressButton(int button_id) //1 through 6
{
    if (button_id < 1 || button_id > 6) return;
    
	string line = "Clicking button " + button_id + ".";
	if (__file_state["B" + button_id + " tab change"] != "" && __state.handle_up)
	{
		int value = __file_state["B" + button_id + " tab change"].to_int();
		
		line += " (";
		if (value > 0)
			line += "+";
		line += value;
		line += ")";
	}
	printSilent(line, "gray");
	if (__setting_confirm_actions_that_will_use_a_click && !user_confirm("READY?"))
		abort("Aborted.");
    if (__setting_do_not_actually_use_clicks)
        return;
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_button" + button_id, false, false), ACTION_TYPE_BUTTON, button_id);
}

void actionPressTab(int tab_id)
{
	printSilent("Clicking tab " + tab_id + ".", "gray");
	if (__setting_confirm_actions_that_will_use_a_click && !user_confirm("READY?"))
		abort("Aborted.");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_tab" + tab_id, false, false), ACTION_TYPE_TAB, tab_id);
}

void actionCollectLeftDrawer()
{
	printSilent("Collecting from left drawer.", "gray");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_drawer2", false, false));
	if (__state.last_action_results["The drawer is empty now, but you can hear gears inside the case steadily turning. Maybe you should check back tomorrow?"]);
	{
		__file_state["_left drawer collected"] = true;
		writeFileState();
	}
	
}

void actionCollectRightDrawer()
{
	printSilent("Collecting from right drawer.", "gray");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_drawer1", false, false));
	if (__state.last_action_results["The drawer is empty now, but you can hear gears inside the case steadily turning. Maybe you should check back tomorrow?"]);
	{
		__file_state["_right drawer collected"] = true;
		writeFileState();
	}
}

void actionCollectMartiniHose()
{
	printSilent("Collecting from martini hose.", "gray");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_dispenser", false, false));
	if (__state.last_action_results["Hmm. Nothing happens. Looks like it's out of juice for today."])
	{
		__file_state["_martini hose collected"] = 3;
		writeFileState();
	}
}

//Tasks:
void openLeftDrawer()
{
	if (__state.left_drawer_unlocked) return;
	printSilent("Opening left drawer...");
	if (__file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Unable to open left drawer, out of clicks for the day.");
		return;
	}
	//222-any not 2(?) left
	//int [int] configuration = {2, 2, 2, 0, 0, 0};
	if (true)
	{
		int [int] configuration = {2, 2, 2, 0, 0, 0};
		for i from 3 to 5
			configuration[i] = __state.dial_configuration[i];
		if (configuration[3] == 2 && configuration[4] == 2 && configuration[5] == 2)
			configuration[3] = 3;
		actionSetDialsTo(configuration);
	}
	else
	{
		int [int] configuration = {0, 0, 0, 2, 2, 2};
		for i from 0 to 2
			configuration[i] = __state.dial_configuration[i];
		if (configuration[0] == 2 && configuration[1] == 2 && configuration[2] == 2)
			configuration[0] = 3;
		actionSetDialsTo(configuration);
	}
	actionPressLeftActuator();
}

void openRightDrawer()
{
	if (__state.right_drawer_unlocked) return;
	printSilent("Opening right drawer...");
	if (__file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Unable to open right drawer, out of clicks for the day.");
		return;
	}
	//any not 2(?)-222 right
	//handle state matters...?
	if (false)
	{
		int [int] configuration = {2, 2, 2, 0, 0, 0};
		for i from 3 to 5
			configuration[i] = __state.dial_configuration[i];
		if (configuration[3] == 2 && configuration[4] == 2 && configuration[5] == 2)
			configuration[3] = 3;
		actionSetDialsTo(configuration);
	}
	else
	{
		int [int] configuration = {0, 0, 0, 2, 2, 2};
		for i from 0 to 2
			configuration[i] = __state.dial_configuration[i];
		if (configuration[0] == 2 && configuration[1] == 2 && configuration[2] == 2)
			configuration[0] = 3;
		actionSetDialsTo(configuration);
	}
	actionPressRightActuator();
}

void unlockCrank()
{
	if (__state.crank_unlocked) return;
	printSilent("Unlocking crank...");
	if (__file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Unable to unlock crank, out of clicks for the day.");
		return;
	}
	//000-000 handle down left actuator
	int [int] dial_configuration = {0, 0, 0, 0, 0, 0};
	actionSetDialsTo(dial_configuration);
	actionSetHandleTo(false);
	actionPressLeftActuator();
}

void unlockMartiniHose()
{
	if (__state.martini_hose_unlocked) return;
	printSilent("Unlocking martini hose...");
	if (__file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Unable to unlock martini hose, out of clicks for the day.");
		return;
	}
	//000-000 or 111-111 or 222-222 etc, handle up, left actuator
	int [int] dial_configuration = {0, 0, 0, 0, 0, 0};
	actionSetDialsTo(dial_configuration);
	actionSetHandleTo(true);
	actionPressLeftActuator();
}

void unlockButtons()
{
	//012-210 or XYZ-ZYX palindrome, press either actuator
	if (__state.buttons_unlocked) return;
	printSilent("Unlocking buttons...");
	if (__file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Unable to unlock buttons, out of clicks for the day.");
		return;
	}
	int [int] dial_configuration = {0, 1, 2, 2, 1, 0};
	actionSetDialsTo(dial_configuration);
	actionPressLeftActuator();
}

void lightFirstLight()
{
	if (__state.horizontal_light_states[1] == LIGHT_STATE_ON) return;
	printSilent("Lighting first light...");
	//Press left and right actuators:
	actionPressLeftActuator();
	actionPressRightActuator();
}

int mastermindSolidCountForCodes(int [int] dials_a, int [int] dials_b)
{
	int solid_count = 0;
	foreach key in dials_a
	{
		if (dials_a[key] == dials_b[key])
			solid_count++;
	}
	return solid_count;
}

int mastermindBlinkingCountForCodes(int [int] code_a, int [int] code_b)
{
	int count = 0;
	
	//so, bug(?): list initialisation does not reset properly between function calls
	//use this initialisation, and it will not work as expected:
	boolean [int] marked_positions;// = {0:false, 1:false, 2:false};
	for i from 0 to 2
		marked_positions[i] = false;
	//print_html("marked_positions = " + marked_positions.to_json());
	
	foreach i in code_a
	{
		if (code_a[i] != code_b[i])
		{
			//Not a solid.
			//Does this digit exist in a non-solid position? If so, mark it.
			foreach j in code_a
			{
				if (i == j) continue;
				if (code_a[j] == code_b[j]) continue; //j is solid position, ignore
				if (marked_positions[j]) continue;
				if (code_a[i] == code_b[j]) //we found one
				{
					marked_positions[j] = true;
					count++;
					break;
				}
			}
		}
	}
	
	return count;
}

int [int] mastermindRawCodeToList(int raw_code)
{
	int operating_code = raw_code;
	int [int] result;
	result.listAppend(operating_code / 11 / 11);
	operating_code -= result[0] * 11 * 11;
	result.listAppend(operating_code / 11);
	operating_code -= result[1] * 11;
	result.listAppend(operating_code);
	
	//printSilent(raw_code + " becomes " + result.listJoinComponents(", "));
	return result;
}

void lightSecondLight()
{
	if (__state.horizontal_light_states[2] == LIGHT_STATE_ON) return;
	printSilent("Solving second light...");
	//Solve mastermind puzzle:
	boolean [int] valid_states_left;
	boolean [int] valid_states_right;
	for i from 0 to 1330
	{
		valid_states_left[i] = true;
		valid_states_right[i] = true;
	}
	boolean [int] states_already_tested_left;
	boolean [int] states_already_tested_right;
	boolean left_side_solved = false;
	boolean right_side_solved = false;
	int breakout = 111;
	while (!__file_state["_out of clicks for the day"].to_boolean() && __state.horizontal_light_states[2] != LIGHT_STATE_ON && breakout > 0)
	{
		breakout -= 1;
		//Calculate remaining possible choices:
		//At the moment, just pick one at random:
		//By random, I mean the one with the most unique digits.
		//Enter that code:
		//Try it:
		//Save that light configuration:
		//Or do that in parse state?
		
		string [int] first_level_mastermind = __file_state["mastermind log"].split_string("•");
		foreach key, mastermind_entry_string in first_level_mastermind
		{
			if (mastermind_entry_string == "") continue;
			string [int] entry = mastermind_entry_string.split_string("\\|");
			if (entry.count() != 3) continue;
			string side = entry[0];
			string [int] dials_raw = entry[1].split_string(",");
			string [int] lights_raw = entry[2].split_string(",");
			
			//Convert data:
			int [int] entry_dials; //0 through 2, relevant side only
			int entry_solid_lights = 0;
			int entry_blinking_lights = 0; //relaxen
			foreach key, dial in dials_raw
			{
				if (side == "L")
				{
					if (key > 2) continue;
				}
				if (side == "R")
				{
					if (key < 3) continue;
				}
				entry_dials.listAppend(dial.to_int());
			}
			//Convert lights to solid/blinking count:
			foreach key, light_state_string in lights_raw
			{
				int light_state = light_state_string.to_int();
				if (light_state == LIGHT_STATE_ON)
					entry_solid_lights++;
				if (light_state == LIGHT_STATE_BLINKING)
					entry_blinking_lights++;
			}
			if (entry_solid_lights >= 3)
			{
				if (side == "L")
					left_side_solved = true;
				if (side == "R")
					right_side_solved = true;
			}
			//printSilent(side + ": " + entry_dials.listJoinComponents(", ") + " - " + entry_solid_lights + " - " + entry_blinking_lights);
			//Eliminate any mastermind entries that don't correspond to this truth.
			boolean [int] valid_states_using;
			boolean [int] states_already_tested;
			if (side == "L")
			{
				valid_states_using = valid_states_left;
				states_already_tested = states_already_tested_left;
			}
			else if (side == "R")
			{
				valid_states_using = valid_states_right;
				states_already_tested = states_already_tested_left;
			}
			else
			{
				printSilent("Error in datafile, unable to solve second light.", "red");
				return;
			}
			foreach dials_raw, is_valid in valid_states_using
			{
				if (!is_valid) continue;
				int [int] testing_dials = mastermindRawCodeToList(dials_raw);
				//Assume this is the answer. Would entry_dials versus this setup result in the same blinking/solid count?
				int expected_solid_count = mastermindSolidCountForCodes(entry_dials, testing_dials);
				if (expected_solid_count != entry_solid_lights)
				{
					//print_html(testing_dials.listJoinComponents(",") + " / " + expected_solid_count + " is not solid " + entry_solid_lights + " against " + entry_dials.listJoinComponents(","));
					valid_states_using[dials_raw] = false;
					continue;
				}
				int expected_blinking_count = mastermindBlinkingCountForCodes(testing_dials, entry_dials);
				//print_html("testing_dials = " + testing_dials.to_json() + ", entry_dials = " + entry_dials.to_json() + ", expected_blinking_count = " + expected_blinking_count);
				if (expected_blinking_count != entry_blinking_lights)
				{
					//print_html(testing_dials.listJoinComponents(",") + " / " + expected_blinking_count + " is not blinking " + entry_blinking_lights + " against " + entry_dials.listJoinComponents(","));
					valid_states_using[dials_raw] = false;
					continue;
				}
				if (testing_dials[0] == entry_dials[0] && testing_dials[1] == entry_dials[1] && testing_dials[2] == entry_dials[2])
					states_already_tested[dials_raw] = true;
			}
		}
		if (left_side_solved && right_side_solved)
		{
			printSilent("But... we already solved this?");
			return;
		}
		//Now pick the one we want:
		//Ehh... the first one with the most distinct values?
		boolean [int] valid_states_using;
		boolean [int] states_already_tested;
		string side_solving = "L";
		if (left_side_solved)
			side_solving = "R";
		if (side_solving == "L")
		{
			valid_states_using = valid_states_left;
			states_already_tested = states_already_tested_left;
		}
		else
		{
			//solve right:
			valid_states_using = valid_states_right;
			states_already_tested = states_already_tested_left;
		}
		int number_of_valid_states = 0;
		int [int] picked_choice;
		int picked_choice_distinct_values = 0;
		foreach dials_raw, is_valid in valid_states_using
		{
			if (!is_valid)
				continue;
			number_of_valid_states++;
			if (states_already_tested[dials_raw]) continue;
			
			int [int] dials = mastermindRawCodeToList(dials_raw);
			int number_of_distinct_values = 0;
			if (dials[0] != dials[1] && dials[0] != dials[2])
				number_of_distinct_values++;
			if (dials[1] != dials[0] && dials[1] != dials[2])
				number_of_distinct_values++;
			if (dials[2] != dials[1] && dials[2] != dials[0])
				number_of_distinct_values++;
			if (number_of_distinct_values > picked_choice_distinct_values)
			{
				picked_choice = dials;
				picked_choice_distinct_values = number_of_distinct_values;
				if (picked_choice_distinct_values >= 3 && false)
					break;
			}
		}
		if (picked_choice.count() == 0)
		{
			printSilent("Unable to solve mastermind, out of choices.");
			return;
		}
		//Set dials to this choice, press the correct actuator:
		
		printSilent("At least " + number_of_valid_states + " valid mastermind states.");
		printSilent("Picked " + side_solving + " " + picked_choice.listJoinComponents(", ") + ".");
		int [int] dial_configuration = listCopy(__state.dial_configuration);
		if (side_solving == "L")
		{
			for i from 0 to 2
				dial_configuration[i] = picked_choice[i];
		}
		else
		{
			for i from 0 to 2
				dial_configuration[i + 3] = picked_choice[i];
		}
		actionSetDialsTo(dial_configuration);
		//break;
		if (side_solving == "L")
		{
			actionPressLeftActuator();
		}
		else
			actionPressRightActuator();
	}
	if (__state.horizontal_light_states[2] != LIGHT_STATE_ON && __file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Can't solve yet, out of clicks for the day.");
	}
}
void generateAllTabPermutations(int [int][int] all_permutations, int [int] current_permutation)
{
	if (current_permutation.count() >= 6) return;
	for i from 0 to 5
	{
		boolean no = false;
		foreach j in current_permutation
		{
			if (current_permutation[j] == i)
			{
				no = true;
				break;
			}
		}
		if (no) continue;
		
		int [int] permutation = current_permutation.listCopy();
		permutation.listAppend(i);
		if (permutation.count() == 6)
			all_permutations[all_permutations.count()] = permutation;
		
		generateAllTabPermutations(all_permutations, permutation);
	}
}

Record TabStateTransition
{
	int button_id;
	int [int] before_tab_configuration;
	int [int] after_tab_configuration;
	boolean tabs_were_moving;
};


int [int] addNumberToTabConfiguration(int [int] configuration, int amount, int [int] permutation, boolean should_output)
{
	if (should_output)
		printSilent("addNumberToTabConfiguration(" + configuration + ", " + amount + ", " + permutation + ")");
	//Convert base-three number into base-ten:
	int base_ten = convertTabConfigurationToBase10(configuration, permutation);
	if (should_output)
		printSilent("base_ten of " + configuration.listJoinComponents(", ") + " = " + base_ten);
	//Add number:
	base_ten += amount;
	//Cap:
	if (base_ten < 0) base_ten = 0;
	if (base_ten > 728) base_ten = 728;
	//Convert back again:
	int [int] next_configuration;
	for i from 0 to 5
		next_configuration.listAppend(-1);
	
	int [int] permutation_inverse;
	//for i from 0 to 5
		//permutation_inverse.listAppend(-1);
	foreach i in permutation
	{
		permutation_inverse[permutation[i]] = i;
	}
	foreach i in configuration
	{
		int index_value = powi(3, 5 - i);
		int v = (base_ten / index_value);
		base_ten -= v * index_value;
		next_configuration[permutation_inverse[i]] = v;
	}
	
	if (should_output)
		printSilent("next_configuration = " + next_configuration.listJoinComponents(", "));
	
	return next_configuration;
}

void calculateStateTransitionInformation(int [int][int] all_permutations, TabStateTransition transition, boolean [int][int][int] valid_possible_button_configurations)
{
	//printSilent("calculateStateTransitionInformation(all_permutations, " + transition.to_json());
	//This button is one of six, and the permutation is one of 720.
	//So, out of all of those, which could we possibly be?
	boolean stop = false;
	for button_function_id from 0 to 5
	{
		int change_amount = __button_functions[button_function_id];
		if (transition.tabs_were_moving)
			change_amount -= 1;
		
		foreach i in all_permutations
		{
			//console.log(transition.button_id + ", " + button_function_id + ", " + i);
			if (!(valid_possible_button_configurations contains transition.button_id))
			{
				printSilent("Internal error, valid possible button configurations malformed: " + transition.button_id + ", " + button_function_id + ", " + i);
			}
			if (!valid_possible_button_configurations[transition.button_id][button_function_id][i])
				continue;
			int [int] permutation = all_permutations[i];
			boolean should_output = false;
			/*if (permutation[0] == 1 && permutation[1] == 0 && permutation[2] == 3 && permutation[3] == 4 && permutation[4] == 2 && permutation[5] == 5 && button_function_id == 5)
				should_output = true;*/
			//Apply button_function to transition.before_tab_configuration. Do we get transition.after_tab_configuration?
			int [int] configuration = transition.before_tab_configuration.listCopy();
			int [int] next_configuration = addNumberToTabConfiguration(configuration, change_amount, permutation, should_output);
			
			if (configurationsAreEqual(transition.after_tab_configuration, next_configuration))
			{
				//We could possibly be button_function_id, permutation.
			}
			else
			{
				if (should_output)
				{
					printSilent("invalidating " + permutation.listJoinComponents(", ") + " as part of button " + button_function_id + ", configuration = " + configuration.listJoinComponents(", ") + ", next_configuration = " + next_configuration.listJoinComponents(", ") + ", actual = " + transition.after_tab_configuration.listJoinComponents(", "));
				}
				//We aren't. Eliminate it.
				//console.log("! " + transition.button_id + ", " + button_function_id + ", " + i + " - " + next_configuration + ", " + transition.after_tab_configuration);
				valid_possible_button_configurations[transition.button_id][button_function_id][i] = false;
			}
			if (false)
			{
				int [int] configuration_test = addNumberToTabConfiguration(configuration, 0, permutation, false);
				if (!configurationsAreEqual(configuration_test, configuration))
				{
					printSilent("ERROR: " + configuration_test + " is not " + configuration + " on permutation " + permutation);
					addNumberToTabConfiguration(configuration, 0, permutation, true);
					printSilent("END ERROR");
					stop = true;
				}
			}
			if (stop)
				break;
		}
		if (stop)
			break;
	}
}

//Returns functional_ids - valid_button_functions
boolean [int][int] calculateTabs()
{
	boolean finished = true;
	foreach s in $strings[tab permutation,B1 tab change,B2 tab change,B3 tab change,B4 tab change,B5 tab change,B6 tab change]
	{
		if (__file_state[s] == "")
		{
			finished = false;
			break;
		}
	}
	if (finished)
	{
		boolean [int][int] valid_button_functions;
		int [int] button_functions_inverse;
		foreach key, value in __button_functions
		{
			button_functions_inverse[value] = key;
		}
		for button_actual_id from 0 to 5
		{
			int value = __file_state["B" + (button_actual_id + 1) + " tab change"].to_int();
			int functional_id = button_functions_inverse[value];
			valid_button_functions[button_actual_id][functional_id] = true;
		}
		return valid_button_functions;
	}
	//Parse button tab log:
	TabStateTransition [int] state_transitions;
	string [int] log_split = __file_state["button tab log"].split_string("•");
	foreach key, entry_string in log_split
	{
		if (entry_string == "") continue;
		string [int] entry = entry_string.split_string("\\|");
		if (entry.count() != 3 && entry.count() != 4) continue;
		
		TabStateTransition state_transition;
		state_transition.button_id = entry[0].to_int() - 1;
		
		foreach key, v in entry[1].split_string(",")
			state_transition.before_tab_configuration.listAppend(v.to_int());
		foreach key, v in entry[2].split_string(",")
			state_transition.after_tab_configuration.listAppend(v.to_int());
		
		if (entry.count() == 4)
			state_transition.tabs_were_moving = entry[3].to_boolean();
		
		state_transitions[state_transitions.count()] = state_transition;
	}
	//printSilent("state_transitions = " + state_transitions.to_json());

	//__button_functions
	int [int][int] all_permutations;
	
	int [int] blank;
	generateAllTabPermutations(all_permutations, blank);
	//printSilent("all_permutations = " + all_permutations.to_json());
	//printSilent("all_permutations.count() = " + all_permutations.count());
	boolean [int][int][int] valid_possible_button_configurations; //button_actual_id, button_functional_id, permutation_id
	for button_actual_id from 0 to 5
	{
		boolean [int][int] button_list;
		for button_functional_id from 0 to 5
		{
			boolean [int] button_2_list;
			foreach permutation_id in all_permutations
			{
				button_2_list[permutation_id] = true;
			}
			button_list[button_functional_id] = button_2_list;
		}
		valid_possible_button_configurations[button_actual_id] = button_list;
	}
	
	foreach key, transition in state_transitions
	{
		if (transition.button_id >= 0)
			calculateStateTransitionInformation(all_permutations, transition, valid_possible_button_configurations);
	}
	if (false)
	{
		//debugging:
		foreach key in valid_possible_button_configurations
		{
			foreach key2 in valid_possible_button_configurations[key]
			{
				foreach key3 in valid_possible_button_configurations[key][key2]
				{
					if (valid_possible_button_configurations[key][key2][key3])
					{
						printSIlent(key + ", " + key2 + ", " + key3 + " is valid");
					}
				}
			}
		}
	}
	//Now, learn from valid_possible_button_configurations:
	//Calculate valid_permutation_ids:
	boolean [int] valid_permutation_ids;
	foreach permutation_id in all_permutations
		valid_permutation_ids[permutation_id] = true;
	//Calculate valid permutations:
	foreach permutation_id in all_permutations
	{
		for button_actual_id from 0 to 5
		{
			boolean has_valid_combination = false;
			for button_functional_id from 0 to 5
			{
				if (valid_possible_button_configurations[button_actual_id][button_functional_id][permutation_id])
				{
					//console.log(permutation_id + ": " + button_actual_id + ", " + button_functional_id);
					has_valid_combination = true;
				}
				if (has_valid_combination)
					break;
			}
			if (!has_valid_combination)
			{
				//printSilent(button_actual_id + " has no solution for " + permutation_id + " (" + all_permutations[permutation_id].listJoinComponents(", ") + ")");
				//console.log(permutation_id + " invalidated by " + button_actual_id);
				valid_permutation_ids[permutation_id] = false;
				break;
			}
		}
	}
	//printSilent("valid_permutation_ids = " + valid_permutation_ids.to_json());
	int [int][int] valid_permutations;
	foreach permutation_id in all_permutations
	{
		if (valid_permutation_ids[permutation_id])
			valid_permutations[valid_permutations.count()] = all_permutations[permutation_id];
	}
	
	//printSilent("valid_permutation_ids = " + valid_permutation_ids.to_json());
	//__button_functions
	boolean [int][int] valid_button_functions;
	boolean [int] button_fuctions_identified;
	for i from 0 to 5
		button_fuctions_identified[i] = false;
	for button_actual_id from 0 to 5
	{
		boolean [int] functions;
		for button_functional_id from 0 to 5
		{
			boolean possible = false;
			foreach permutation_id in all_permutations
			{
				if (!valid_permutation_ids[permutation_id])
					continue;
				if (!valid_possible_button_configurations[button_actual_id][button_functional_id][permutation_id])
				{
					continue;
				}
				possible = true;
				//console.log(button_actual_id + ", " + button_functional_id + ", " + all_permutations[permutation_id] + " is valid");
			}
			if (possible)
			{
				//functions.listAppend(button_functional_id);
				functions[button_functional_id] = true;
			}
		}
		valid_button_functions[valid_button_functions.count()] = functions;
		if (functions.count() == 1)
		{
			foreach button_functional_id in functions
			{
				button_fuctions_identified[button_functional_id] = true;
				break;
			}
		}
	}
	//Update valid_button_functions with button_fuctions_identified:
	for button_actual_id from 0 to 5
	{
		if (valid_button_functions[button_actual_id].count() == 1) continue;
		boolean [int] new_list;
		foreach v in valid_button_functions[button_actual_id]
		{
			//int v = valid_button_functions[button_actual_id][i];
			if (!button_fuctions_identified[v])
				new_list[v] = true;
		}
		valid_button_functions[button_actual_id] = new_list;
	}
	
	if (valid_permutations.count() == 1)
	{
		int [int] valid_permutation = valid_permutations[0];
		if (__file_state["tab permutation"] == "")
			printSilent("Found valid permutation: " + valid_permutation.listJoinComponents(", "));
		__file_state["tab permutation"] = valid_permutation.listJoinComponents(",");
		writeFileState();
	}
	//printSilent("valid_button_functions = " + valid_button_functions.to_json());
	foreach button_id in valid_button_functions
	{
		boolean [int] functions = valid_button_functions[button_id];
		if (functions.count() == 1)
		{
			
			int change;
			foreach function_id in functions
				change = __button_functions[function_id];
			__file_state["B" + (button_id + 1) + " tab change"] = change;
			writeFileState();
			//printSilent("B" + (button_id + 1) + ": " + change);
		}
	}
	
	return valid_button_functions;
}
void outputHelp()
{
	printSilent("Briefcase.ash v" + __briefcase_version + ". Commands:");
	printSilent("");
	printSilent("<strong>enchantment</strong> or <strong>e</strong> - changes briefcase enchantment (type \"briefcase enchantment\" for more information.)");
	printSilent("<strong>unlock</strong> - unlocks most everything we know how to unlock.");
    printSilent("<strong>buff</strong> or <strong>b</strong> - obtain tab buffs.");
	printSilent("<strong>status</strong> - shows current briefcase status");
	printSilent("<strong>help</strong>");
	printSilent("");
	printSilent("<strong>drawers</strong> or <strong>left</strong> or <strong>right</strong> - unlocks all/left/right drawers");
	printSilent("<strong>hose</strong> - unlocks martini hose");
	printSilent("<strong>drink</strong> - acquires three splendid martinis");
	printSilent("");
	printSilent("<strong>charge</strong> - charges flywheel (most commands do this automatically)");
	printSilent("<strong>second</strong> - lights #2, solves mastermind puzzle");
	printSilent("<strong>third</strong> - lights #3, solves tab puzzle");
	printSilent("<strong>identify</strong> - identifies the tab function of all six buttons");
	printSilent("<strong>solve</strong> - unlocks everything we know how to unlock, also solves puzzles. <strong>You probably want the \"unlock\" command instead.</strong>");
	printSilent("<strong>reset</strong> - resets the briefcase");
}

void outputStatus()
{
	printSilent("Briefcase v" + __briefcase_version + " status:");
	string [int] out;
	foreach key, s in BriefcaseStateDescription(__state)
		out.listAppend(s);
	if (__file_state["_flywheel charged"].to_boolean())
		out.listAppend("Flywheel charged.");
	if (__file_state["lightrings target number"] != "")
		out.listAppend("Puzzle #3 target number: " + __file_state["lightrings target number"].to_int());
	if (__file_state["initial dial configuration"] != "")
	{
		out.listAppend("Initial dial configuration: " + convertDialConfigurationToString(stringToIntIntList(__file_state["initial dial configuration"])));
	}
	
	if (__file_state["tab permutation"] != "")
	{
		int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
		
		int [int] other_notation;
		foreach j in tab_permutation
		{
			other_notation.listAppend(powi(3, 5 - tab_permutation[j]));
		}
		
		out.listAppend("Tab permutation: (" + other_notation.listJoinComponents(", ") + ")");
	}
	string [int] buttons_line;
	for i from 1 to 6
	{
		string key = "B" + i + " tab change";
		if (__file_state[key] == "") continue;
		
		int value = __file_state["B" + i + " tab change"].to_int();
		buttons_line.listAppend("<strong>B" + i + ":</strong> " + value);
	}
	if (buttons_line.count() > 0)
		out.listAppend("Buttons: " + buttons_line.listJoinComponents(", "));
	
	//Indent with nbsp:
	string tabs = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
	if (out.count() > 0)
		print_html(tabs + out.listJoinComponents("<br>" + tabs));
}
int [int] discoverTabPermutation(boolean allow_actions)
{
	if (__file_state["tab permutation"] != "") return stringToIntIntList(__file_state["tab permutation"]);
    unlockButtons();
	actionSetHandleTo(true);
	int breakout = 111;
	if (__state.horizontal_light_states[3] == LIGHT_STATE_ON && false) //it totally can do this now. maybe.
	{
		int [int] blank;
		if (!allow_actions) return blank;
		//Are the tabs moving?
		int [int] previous_tab_permutation = __state.tab_configuration.listCopy();
		actionVisitBriefcase();
		
		if (!configurationsAreEqual(previous_tab_permutation, __state.tab_configuration))
		{
			printSilent("We can't discover tab permutations with moving tabs, yet. Sorry. Reset the briefcase?");
			return blank;
		}
	}
	while (__file_state["tab permutation"] == "" && !__file_state["_out of clicks for the day"].to_boolean() && breakout > 0)
	{
		breakout -= 1;
		boolean [int][int] valid_button_functions = calculateTabs();
		//printSilent("valid_button_functions = " + valid_button_functions.to_json());
		
        if (__file_state["tab permutation"] != "") //second test
            break;
		int chosen_function_id_to_use = 5; //100
		
		int two_count = 0;
		foreach i, value in __state.tab_configuration
		{
			if (value == 2)
				two_count++;
		}
		if (two_count >= 5) //the number is almost certainly too high
			chosen_function_id_to_use = 2; //-10. not ideal, but prevents ping-ponging
		int next_chosen_button = -1;
		foreach button_actual_id in valid_button_functions
		{
			//foreach key, button_functional_id
			if (valid_button_functions[button_actual_id][chosen_function_id_to_use])
			{
				if (next_chosen_button != -1)
				{
					if (valid_button_functions[next_chosen_button].count() < valid_button_functions[button_actual_id].count())
						continue;
				}
				next_chosen_button = button_actual_id;
				//break;
			}
		}
		if (next_chosen_button == -1)
		{
			abort("internal error while discovering tab permutation, not sure what to do next");
			int [int] blank;
			return blank;
		}
		//abort("next_chosen_button = " + next_chosen_button);
		if (!allow_actions)
			break;
		actionPressButton(next_chosen_button + 1);
		//break;
		//abort("write me " + next_chosen_button);
	}
	
	if (__file_state["tab permutation"] != "") return stringToIntIntList(__file_state["tab permutation"]);
	int [int] blank;
	return blank;
}


boolean __discover_button_with_function_id_did_press_button = false; //secondary return
int discoverButtonWithFunctionID(int function_id, boolean private_is_rescursing, boolean only_press_once)
{
	if (!private_is_rescursing)
		__discover_button_with_function_id_did_press_button = false;
	unlockButtons();
	discoverTabPermutation(true);
	int value_wanted = __button_functions[function_id];
	
	int breakout = 23;
	while (!__file_state["_out of clicks for the day"].to_boolean() && breakout > 0)
	{
		breakout -= 1;
		boolean [int][int] valid_button_functions = calculateTabs();
		for i from 1 to 6
		{
			if (__file_state["B" + i + " tab change"].to_int() == value_wanted)
				return i - 1;
		}
		actionSetHandleTo(true);
		int current_number = convertTabConfigurationToBase10(__state.tab_configuration, stringToIntIntList(__file_state["tab permutation"]));
		if (current_number == 0 && (function_id == 0 || function_id == 2 || function_id == 4))
		{
			//they want to discover a negative number and we're at zero
			actionPressButton(discoverButtonWithFunctionID(5, true, only_press_once) + 1); //add 100 first
            if (only_press_once)
                break;
			continue;
		}
		else if (current_number == 728 && (function_id == 1 || function_id == 3 || function_id == 5))
		{
			//they want to discover a positive number and we're at zero
			actionPressButton(discoverButtonWithFunctionID(4, true, only_press_once) + 1); //subtract 100 first
            if (only_press_once)
                break;
			continue;
		}
		//printSilent("valid_button_functions = " + valid_button_functions.to_json());
		int next_chosen_button = -1;
		foreach button_id in valid_button_functions
		{
			if (valid_button_functions[button_id][function_id])
			{
				next_chosen_button = button_id;
				break;
			}
		}
		if (next_chosen_button == -1)
		{
			abort("internal error while discovering button functions, not sure what to do next");
			return -1;
		}
		__discover_button_with_function_id_did_press_button = true;
		actionPressButton(next_chosen_button + 1);
        if (only_press_once)
            break;
	}
	for i from 1 to 6
	{
		if (__file_state["B" + i + " tab change"].to_int() == value_wanted)
			return i - 1;
	}
	return -1;
}

int discoverButtonWithFunctionID(int function_id, boolean private_is_rescursing)
{
    return discoverButtonWithFunctionID(function_id, private_is_rescursing, false);
}

int discoverButtonWithFunctionID(int function_id)
{
	return discoverButtonWithFunctionID(function_id, false);
}

void setTabsToNumber(int desired_base_ten_number, boolean only_press_once, int minimum_allowed_number)
{
	//int convertTabConfigurationToBase10(int [int] configuration, int [int] permutation)
	discoverTabPermutation(true);
	
	actionSetHandleTo(true);
    printSilent("Setting tabs to number " + desired_base_ten_number + "...", "gray");
	int breakout = 111;
	while (!__file_state["_out of clicks for the day"].to_boolean() && breakout > 0)
	{
		breakout -= 1;
		int current_number = convertTabConfigurationToBase10(__state.tab_configuration, stringToIntIntList(__file_state["tab permutation"]));
		if (current_number == desired_base_ten_number)
			return;
        if (minimum_allowed_number != -1 && current_number >= minimum_allowed_number)
            return;
		int delta = desired_base_ten_number - current_number;
		//printSilent("desired_base_ten_number = " + desired_base_ten_number + " current_number = " + current_number + " delta = " + delta);
		
		if (delta > 50 || desired_base_ten_number == 728)
		{
			int button_id = discoverButtonWithFunctionID(5, false, true);
            if (button_id == -1) break;
			if (!__discover_button_with_function_id_did_press_button)
				actionPressButton(button_id + 1);
		}
		else if (desired_base_ten_number == 0)
		{
			int button_id = discoverButtonWithFunctionID(4, false, true);
            if (button_id == -1) break;
			if (!__discover_button_with_function_id_did_press_button)
				actionPressButton(button_id + 1);
		}
		else if (delta > 5)
		{
			int button_id = discoverButtonWithFunctionID(3, false, true);
            if (button_id == -1) break;
			if (!__discover_button_with_function_id_did_press_button)
				actionPressButton(button_id + 1);
		}
		else if (delta > 0)
		{
			int button_id = discoverButtonWithFunctionID(1, false, true);
            if (button_id == -1) break;
			if (!__discover_button_with_function_id_did_press_button)
				actionPressButton(button_id + 1);
		}
		else if (delta < -50)
		{
			int button_id = discoverButtonWithFunctionID(4, false, true);
            if (button_id == -1) break;
			if (!__discover_button_with_function_id_did_press_button)
				actionPressButton(button_id + 1);
		}
		else if (delta < -5)
		{
			int button_id = discoverButtonWithFunctionID(2, false, true);
            if (button_id == -1) break;
			if (!__discover_button_with_function_id_did_press_button)
				actionPressButton(button_id + 1);
		}
		else
		{
			int button_id = discoverButtonWithFunctionID(0, false, true);
            if (button_id == -1) break;
			if (!__discover_button_with_function_id_did_press_button)
				actionPressButton(button_id + 1);
		}
		if (only_press_once)
			break;
	}
}

void setTabsToNumber(int desired_base_ten_number, boolean only_press_once)
{
    setTabsToNumber(desired_base_ten_number, only_press_once, -1);
}

void setTabsToNumber(int desired_base_ten_number)
{
	setTabsToNumber(desired_base_ten_number, false);
}

Record LightringsEntry
{
	int lightrings_id;
	int [int] tab_configuration;
};

int [int] calculatePossibleLightringsValues(boolean allow_actions, boolean only_return_unvisited_lightrings)
{
	//Parse lightrings observed:
	int [int] permutation = discoverTabPermutation(allow_actions);
	if (permutation.count() == 0)
	{
		int [int] blank;
		return blank;
	}
	
	boolean [int] visited_numbers;
	LightringsEntry [int] lightrings_entries;
	foreach key, entry_string in __file_state["lightrings observed"].split_string("•")
	{
		if (entry_string == "") continue;
		string [int] entry_list = entry_string.split_string("\\|");
		
		LightringsEntry entry;
		entry.tab_configuration = stringToIntIntList(entry_list[0]);
		entry.lightrings_id = entry_list[1].to_int();
		visited_numbers[convertTabConfigurationToBase10(entry.tab_configuration, permutation)] = true;
		
		lightrings_entries[lightrings_entries.count()] = entry;
		//printSilent(lightrings_id + " on " + tab_configuration.listJoinComponents(", "));
	}
	//printSilent("lightrings_entries = " + lightrings_entries.to_json());

	int [int][int][int] lightrings_seen_values;
	for lightrings_id from 0 to 6
	{
		int [int][int] blank;
		lightrings_seen_values[lightrings_seen_values.count()] = blank;
	}
	foreach key, entry in lightrings_entries
	{
		//if (entry.lightrings_id < 1) continue;
		
		boolean found = false;
		foreach i in lightrings_seen_values[entry.lightrings_id]
		{
			if (configurationsAreEqual(lightrings_seen_values[entry.lightrings_id][i], entry.tab_configuration))
			{
				found = true;
				break;
			}
		}
		if (!found)
			lightrings_seen_values[entry.lightrings_id][lightrings_seen_values[entry.lightrings_id].count()] = entry.tab_configuration;
	}
	boolean [int] possible_lightrings_numbers;
	for i from 0 to 728
	{
		possible_lightrings_numbers[i] = true;
	}
	//printSilent("lightrings_seen_values = " + lightrings_seen_values.to_json());
	//Process lightrings:
	
	int [int][int][int] lightrings_range_modifications = 
	{{},
	{{-100, -76}, {76, 100}},
	{{-75, -51}, {51, 75}},
	{{-50, -26}, {26, 50}},
	{{-25, -11}, {11, 25}},
	{{-10, -6}, {6, 10}},
	{{-5, 5}}};
	//printSilent("lightrings_range_modifications = " + lightrings_range_modifications.to_json());
	
	for lightrings_id from 1 to 6
	{
		foreach i in lightrings_seen_values[lightrings_id]
		{
			int [int] tab_configuration = lightrings_seen_values[lightrings_id][i];
			int base_ten = convertTabConfigurationToBase10(tab_configuration, permutation);
			//The answer has to be in a specific range. Invalidate all numbers that aren't in that range.
			for answer from 0 to 728
			{
				if (!possible_lightrings_numbers[answer]) continue;
				boolean is_valid = false;
				foreach range_id in lightrings_range_modifications[lightrings_id]
				{
					int [int] range_relative = lightrings_range_modifications[lightrings_id][range_id];
					if (answer >= base_ten + range_relative[0] && answer <= base_ten + range_relative[1])
						is_valid = true;
				}
				if (!is_valid)
					possible_lightrings_numbers[answer] = false;
			}
		}
	}
	int [int] possible_lightrings_answers_final;
	for i from 0 to 728
	{
		if (visited_numbers[i] && only_return_unvisited_lightrings)
			continue;
		if (possible_lightrings_numbers[i])
			possible_lightrings_answers_final.listAppend(i);
	}
	if (possible_lightrings_answers_final.count() == 1 && !only_return_unvisited_lightrings)
	{
		__file_state["lightrings target number"] = possible_lightrings_answers_final[0];
		writeFileState();
	}
	//printSilent("possible_lightrings_answers_final = " + possible_lightrings_answers_final.listJoinComponents(", "));
	return possible_lightrings_answers_final;
}

void lightThirdLight()
{
	if (__state.horizontal_light_states[3] == LIGHT_STATE_ON) return;
	printSilent("Solving third light...");
	discoverButtonWithFunctionID(5); //100
	discoverButtonWithFunctionID(3); //10
	discoverButtonWithFunctionID(1); //1
	//Solve moving tabs:
	//First, calculate permutation / what the buttons do:
	//Should we solve all six buttons first? ...yes? It would probably work better.
	for function_id from 0 to 5
		discoverButtonWithFunctionID(function_id);
	
	int breakout = 111;
	while (!__file_state["_out of clicks for the day"].to_boolean() && __state.horizontal_light_states[3] != LIGHT_STATE_ON && breakout > 0)
	{
		breakout -= 1;
		int [int] possible_lightrings_values = calculatePossibleLightringsValues(true, true);
		if (possible_lightrings_values.count() <= 100 && possible_lightrings_values.count() > 0)
			printSilent("Possible lightrings values: " + possible_lightrings_values.listJoinComponents(", "));
		if (possible_lightrings_values.count() == 0)
		{
			printSilent("Unable to solve puzzle.");
			return;
		}
		
		//Only press once, since we want to recalculate lightrings every press:
		setTabsToNumber(possible_lightrings_values[0], true);
	}
	if (__state.horizontal_light_states[3] != LIGHT_STATE_ON && __file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Can't solve yet, out of clicks for the day.");
	}
}
void collectSplendidMartinis()
{
	//FIXME don't do this if we don't have enough clicks for the day to finish?
	if (__file_state["_martini hose collected"].to_int() >= 3)
	{
		printSilent("Already collected from the hose today.");
		return;
	}
	discoverButtonWithFunctionID(5); //100
	unlockMartiniHose();
	for i from 1 to 3
	{
		if (__file_state["_martini hose collected"].to_int() >= 3)
			break;
		setTabsToNumber(728, false, 726); //FIXME don't bother if we're >= 725...? but, the moving tabs?
		int current_number = convertTabConfigurationToBase10(__state.tab_configuration, stringToIntIntList(__file_state["tab permutation"]));
		if (current_number >= 726)
		{
			actionCollectMartiniHose();
		}
		else
		{
			printSilent("Can't collect splendid martinis. Maybe out of clicks?", "red");
			return;
		}
	}
}



void chargeFlywheel()
{
	if (__file_state["_flywheel charged"].to_boolean())
		return;
	unlockCrank();
	if (!__state.crank_unlocked)
	{
		printSilent("Unable to charge flywheel, crank not unlocked.", "red");
		return;
	}
	printSilent("Charging flywheel...");
	actionSetHandleTo(true);
	
	for i from 1 to 11
	{
		actionTurnCrank();
		if (!__state.last_action_results["You turn the crank."])
		{
			abort("Internal error charging the flywheel.");
			return;
		}
		if (__state.last_action_results["Nothing seems to happen."])
		{
			printSilent("Flywheel already charged today.");
			__file_state["_flywheel charged"] = true;
			writeFileState();
			return;
		}
		//You hear what sounds like a flywheel inside the case spinning up.
		//You hear what sounds like a flywheel inside the case spinning up..
		boolean flywheel_spinning_up = false;
		foreach result in __state.last_action_results
		{
			if (result.contains_text("You hear what sounds like a flywheel inside the case spinning up"))
			{
				flywheel_spinning_up = true;
				break;
			}
		}
		if (!flywheel_spinning_up)
		{
			printSilent("Flywheel isn't spinning up.");
			return;
		}
		if (__state.last_action_results["You hear what sounds like a flywheel inside the case spinning up..........."])
		{
			//Done!
			break;
		}
	}	
	
	actionSetHandleTo(false);
	if (__state.last_action_results["That flywheel sound you heard earlier reaches a fever pitch, and then cuts out.  The case emanates warmth."])
	{
		__file_state["_flywheel charged"] = true;
		writeFileState();
	}
}

void chargeAntennae()
{
	if (!__state.antennae_unlocked)
		lightThirdLight();
	
	if (!__state.antennae_unlocked)
	{
		printSilent("Unable to charge antennae, not unlocked.");
		return;
	}
	actionSetHandleTo(false);
	for i from 1 to 7
	{
		if (__state.antennae_charge == 7)
			break;
		actionTurnCrank();
		
		if (!__state.last_action_results["You turn the crank."] || !__state.last_action_results["You hear the whine of a capacitor charging inside the case."])
			break;
	}
}
int [int] __briefcase_enchantments; //slot -> enchantment, in order
void parseBriefcaseEnchantments()
{
	for i from 0 to 2
		__briefcase_enchantments[i] = -1;
	printSilent("Viewing briefcase enchantments.", "gray");
	buffer page_text = visit_url("desc_item.php?whichitem=311743898");
	
	string [int] enchantments = page_text.group_string("<font color=blue>(.*?)</font></b></center>")[0][1].split_string("<br>");
	foreach key, enchantment in enchantments
	{
		if (enchantment == "Weapon Damage +25%")
			__briefcase_enchantments[0] = 0;
		else if (enchantment == "Spell Damage +50%")
			__briefcase_enchantments[0] = 1;
		else if (enchantment == "+5 <font color=red>Hot Damage</font>")
			__briefcase_enchantments[0] = 2;
		else if (enchantment == "+10% chance of Critical Hit")
			__briefcase_enchantments[0] = 3;
		else if (enchantment == "+25% Combat Initiative")
			__briefcase_enchantments[1] = 0;
		else if (enchantment == "Damage Absorption +100")
			__briefcase_enchantments[1] = 1;
		else if (enchantment == "Superhuman Hot Resistance (+5)")
			__briefcase_enchantments[1] = 2;
		else if (enchantment == "Superhuman Cold Resistance (+5)")
			__briefcase_enchantments[1] = 3;
		else if (enchantment == "Superhuman Spooky Resistance (+5)")
			__briefcase_enchantments[1] = 4;
		else if (enchantment == "Superhuman Stench  Resistance (+5)") //that extra space is only for this enchantment
			__briefcase_enchantments[1] = 5;
		else if (enchantment == "Superhuman Sleaze Resistance (+5)")
			__briefcase_enchantments[1] = 6;
		else if (enchantment == "Regenerate 5-10 MP per Adventure")
			__briefcase_enchantments[2] = 0;
		else if (enchantment == "+5 Adventure(s) per day")
			__briefcase_enchantments[2] = 1;
		else if (enchantment == "+5 PvP Fight(s) per day")
			__briefcase_enchantments[2] = 2;
		else if (enchantment == "Monsters will be less attracted to you")
			__briefcase_enchantments[2] = 3;
		else if (enchantment == "Monsters will be more attracted to you")
			__briefcase_enchantments[2] = 4;
		else if (enchantment == "+25 to Monster Level")
			__briefcase_enchantments[2] = 5;
		else if (enchantment == "-3 MP to use Skills")
			__briefcase_enchantments[2] = 6;
	}
	if (__briefcase_enchantments[0] == -1 || __briefcase_enchantments[1] == -1 || __briefcase_enchantments[2] == -1)
	{
		printSilent("__briefcase_enchantments = " + __briefcase_enchantments.to_json());
		printSilent("Unparsed briefcase enchantments: " + enchantments.listJoinComponents(", ", "and").entity_encode());
	}
}

string decorateEnchantmentOutput(string word, int slot_id, int id)
{
	string output = "<strong>";
	if (__briefcase_enchantments[slot_id] == id)
		output += "<font color=\"red\">";
	output += word;
	if (__briefcase_enchantments[slot_id] == id)
		output += "</font>";
	output += "</strong>";
	return output;
}

void handleEnchantmentCommand(string command)
{
	string [int] words = command.split_string(" ");
	
	parseBriefcaseEnchantments();
	if (words.count() < 2)
	{
		printSilent("The enchantment command lets you modify the enchantment on the briefcase. This costs daily clicks, and resets upon ascending.");
		printSilent("Available enchantment slots:");
		printSilent("");
		printSilent("Slot 1:");
		printSilent(decorateEnchantmentOutput("weapon", 0, 0) + ": +25% weapon damage");
		printSilent(decorateEnchantmentOutput("spell", 0, 1) + ": +50% spell damage");
		printSilent(decorateEnchantmentOutput("prismatic", 0, 2) + ": +5 prismatic damage");
		printSilent(decorateEnchantmentOutput("critical", 0, 3) + ": +10% critical hit");
		printSilent("");
		printSilent("Slot 2:");
		printSilent(decorateEnchantmentOutput("init", 1, 0) + ": +25% initiative");
		printSilent(decorateEnchantmentOutput("absorption", 1, 1) + ": +100 Damage Absorption");
		printSilent(decorateEnchantmentOutput("hot", 1, 2) + " or " + decorateEnchantmentOutput("cold", 1, 3) + " or " + decorateEnchantmentOutput("spooky", 1, 4) + " or " + decorateEnchantmentOutput("stench", 1, 5) + " or " + decorateEnchantmentOutput("sleaze", 1, 6) + ": +5 (type) resistance");
		printSilent("");
		printSilent("Slot 3:");
		printSilent(decorateEnchantmentOutput("regen", 2, 0) + ": 5-10 HP/MP regen");
		printSilent(decorateEnchantmentOutput("adventures", 2, 1) + ": +5 adventures/day");
		printSilent(decorateEnchantmentOutput("fights", 2, 2) + ": +5 PvP fights/day");
		printSilent(decorateEnchantmentOutput("-combat", 2, 3) + ": -5% combat");
		printSilent(decorateEnchantmentOutput("+combat", 2, 4) + ": +5% combat");
		printSilent(decorateEnchantmentOutput("ml", 2, 5) + ": +25 ML");
		printSilent(decorateEnchantmentOutput("skills", 2, 6) + ": -3 MP to use skills");
		
		printSilent("");
		printSilent("The command \"briefcase enchantment prismatic init adventures\" would give your briefcase +5 prismatic damage, +25% init, and +5 adventures/day.");
		printSilent("\"briefcase e -combat\" would give it -combat.");
	}
	else
	{	
		outputStatus();
		chargeFlywheel();
		unlockButtons();
		actionSetHandleTo(false);
		int [int] desired_slot_configuration;
		foreach key, word in words
		{
			if (key == 0) continue;
			word = word.to_lower_case();
			
			if (word == "weapon")
				desired_slot_configuration[0] = 0;
			else if (word == "spell")
				desired_slot_configuration[0] = 1;
			else if (word == "prismatic" || word == "rainbow" || word == "prism")
				desired_slot_configuration[0] = 2;
			else if (word == "critical")
				desired_slot_configuration[0] = 3;
				
			else if (word == "init" || word == "initiative")
				desired_slot_configuration[1] = 0;
			else if (word == "absorption" || word == "da")
				desired_slot_configuration[1] = 1;
			else if (word == "hot")
				desired_slot_configuration[1] = 2;
			else if (word == "cold")
				desired_slot_configuration[1] = 3;
			else if (word == "spooky")
				desired_slot_configuration[1] = 4;
			else if (word == "stench")
				desired_slot_configuration[1] = 5;
			else if (word == "sleaze")
				desired_slot_configuration[1] = 6;
				
			else if (word == "regen")
				desired_slot_configuration[2] = 0;
			else if (word == "adventures" || word == "adventure" || word == "adv")
				desired_slot_configuration[2] = 1;
			else if (word == "fights" || word == "fites" || word == "fight" || word == "fite")
				desired_slot_configuration[2] = 2;
			else if (word == "-combat")
				desired_slot_configuration[2] = 3;
			else if (word == "+combat")
				desired_slot_configuration[2] = 4;
			else if (word == "ml" || word == "monsterlevel")
				desired_slot_configuration[2] = 5;
			else if (word == "skills")
				desired_slot_configuration[2] = 6;
            else
            {
                printSilent("Unknown enchantment \"" + word + "\".");
                continue;
            }
		}
		int [int] max_for_slot = {4, 7, 7};
		int [int] base_button_for_slot = {1, 3, 5};
		//printSilent("desired_slot_configuration = " + desired_slot_configuration.to_json());
		foreach slot_id, id in desired_slot_configuration
		{
			//Set this slot:
			int breakout = 8;
			while (!__file_state["_out of clicks for the day"].to_boolean() && __briefcase_enchantments[slot_id] != id && breakout > 0)
			{
				if (__briefcase_enchantments[slot_id] == -1)
				{
					abort("implement parsing this specific enchantment");
				}
				breakout -= 1;
				//Which direction would be ideal?
				//Left, or right?
				int delta_left = __briefcase_enchantments[slot_id] - id;
				if (delta_left < 0)
					delta_left += max_for_slot[slot_id];
				if (delta_left >= max_for_slot[slot_id])
					delta_left -= max_for_slot[slot_id];
				int delta_right = id - __briefcase_enchantments[slot_id];
				if (delta_right < 0)
					delta_right += max_for_slot[slot_id];
				if (delta_right >= max_for_slot[slot_id])
					delta_right -= max_for_slot[slot_id];
				//printSilent("delta_left = " + delta_left + ", delta_right = " + delta_right);
				//note that I internally switched these around, so "left" and "right" really mean the opposite in terms of what's on the case
				if (delta_left < delta_right)
				{
					//Go left:
					actionPressButton(base_button_for_slot[slot_id] + 1);
				}
				else
				{
					//Go right:
					actionPressButton(base_button_for_slot[slot_id]);
				}
				parseBriefcaseEnchantments();
			}
		}
	}
}
Record Tab
{
    int id;
    int length;
    boolean valid;
};

Tab TabFromFileBuff(int buff_id)
{
    Tab result;
    string [int] tab_effect = __file_state["tab effect " + buff_id].split_string(",");
    
    if (tab_effect.count() == 2)
    {
        int tab_id = tab_effect[0].to_int() - 1;
        int tab_length = tab_effect[1].to_int();
        if (tab_id >= 0 && tab_id <= 5 && tab_length >= 1 && tab_length <= 2)
        {
            result.id = tab_id;
            result.length = tab_length;
            result.valid = true;
        }
    }
    return result;
}

int [int] computePathToNumber(int target_number, int starting_number)
{
    int current_number = starting_number;
    int [int] buttons_pressed;
    while (current_number != target_number)
    {
        int delta = target_number - current_number;
        
        int chosen = 0;
        if (delta > 50 || target_number == 728)
        {
            chosen = 100;
        }
        else if (target_number == 0)
        {
            chosen = -100;
        }
        else if (delta > 5)
        {
            chosen = 10;
        }
        else if (delta > 0)
        {
            chosen = 1;
        }
        else if (delta < -50)
        {
            chosen = -100;
        }
        else if (delta < -5)
        {
            chosen = -10;
        }
        else
        {
            chosen = -1;
        }
        if (chosen == 0)
        {
            printSilent("Internal error computing " + current_number + " to " + target_number);
            break;
        }
        buttons_pressed.listAppend(chosen);
        current_number += chosen;
        if (current_number < 0) current_number = 0;
        if (current_number > 728) current_number = 728;
    }
    return buttons_pressed;
}

//Same as computePathToNumber, minus the overhead(?) of managing a list.
int computePathLengthToNumber(int target_number, int starting_number)
{
    int current_number = starting_number;
    int buttons_pressed = 0;
    
    while (current_number != target_number)
    {
        int delta = target_number - current_number;
        
        int chosen = 0;
        if (delta > 50 || target_number == 728)
        {
            chosen = 100;
        }
        else if (target_number == 0)
        {
            chosen = -100;
        }
        else if (delta > 5)
        {
            chosen = 10;
        }
        else if (delta > 0)
        {
            chosen = 1;
        }
        else if (delta < -50)
        {
            chosen = -100;
        }
        else if (delta < -5)
        {
            chosen = -10;
        }
        else
        {
            chosen = -1;
        }
        if (chosen == 0)
        {
            printSilent("Internal error computing " + current_number + " to " + target_number);
            break;
        }
        current_number += chosen;
        if (current_number < 0) current_number = 0;
        if (current_number > 728) current_number = 728;
        buttons_pressed++;
    }
    return buttons_pressed;
}

//Returns true if done.
boolean incrementTabConfiguration(int [int] configuration, int ignoring_index)
{
	//Try next code:
	int i = 5;
	while (i >= 0)
	{
        if (i == ignoring_index)
        {
            i--;
            continue;
        }
		configuration[i]++;
		if (configuration[i] > 2)
		{
			configuration[i] = 0;
			i--;
		}
		else
			break;
	}
	if (i < 0)
		return true;
	return false;
}

int countNumberOfUnknownTabs(int [int] tab_configuration, boolean [int][int] tabs_known)
{
    int count = 0;
    for tab_id from 0 to 5
    {
        if (tab_configuration[tab_id] == 0) continue;
        if (!tabs_known[tab_id][tab_configuration[tab_id]])
            count++;
    }
    return count;
}

int computeBestTargetNumberForTab(int tab_id, int tab_length, boolean [int][int] tabs_known)
{
    int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
    int current_briefcase_number = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
    int best_found_path_length = -1;
    int best_found_tab_id = -1;
    int best_found_target_number = -1;
    int best_found_tabs_at_final = -1;
    //Go through every possible number, pick the one with the least button presses, do that:
    int [int] operating_configuration;
    for i from 0 to 5
        operating_configuration[i] = 0;

    operating_configuration[tab_id] = tab_length;
    while (true)
    {
        int operating_configuration_base_ten = convertTabConfigurationToBase10(operating_configuration, tab_permutation);
        int path_length = computePathLengthToNumber(operating_configuration_base_ten, current_briefcase_number);
        boolean should_replace = false;
        //FIXME increment operating_configuration keeping tab_id stable:
        if (best_found_path_length == -1 || path_length < best_found_path_length)
        {
            should_replace = true;
        }
        else if (path_length == best_found_path_length)
        {
            int found_tabs_at_final = countNumberOfUnknownTabs(operating_configuration, tabs_known);
            if (found_tabs_at_final > best_found_tabs_at_final)
                should_replace = true;
        }
        if (should_replace)
        {
            best_found_path_length = path_length;
            best_found_tab_id = tab_id;
            best_found_target_number = operating_configuration_base_ten;
            best_found_tabs_at_final = countNumberOfUnknownTabs(operating_configuration, tabs_known);
        }
        boolean done = incrementTabConfiguration(operating_configuration, tab_id);
        if (done)
            break;
    }
    //Now, reach best_found_target_number:
    if (best_found_target_number == -1)
    {
        abort("Internal error: unable to compute a good target number.");
        return -1;
    }
    //printSilent("best_found_target_number = " + best_found_target_number + " unlocking " + best_found_tabs_at_final + " tabs of path length " + best_found_path_length + ".");
    return best_found_target_number;
}


void pressTab(int tab_id, int tab_length)
{
    //printSilent("Activating buff of tab " + tab_id + " of length " + tab_length);
    //We have to reach this tab state using the least clicks, then press the tab:
    
    while (__state.tab_configuration[tab_id] != tab_length)
    {
        boolean [int][int] tabs_known;
        int best_found_target_number = computeBestTargetNumberForTab(tab_id, tab_length, tabs_known);
        setTabsToNumber(best_found_target_number, true); //only press once, because if we discover the wrong button, maybe we'll find a new one...?
    }
    if (__state.tab_configuration[tab_id] == tab_length)
    {
        actionPressTab(tab_id + 1);
        return;
    }
    else
    {
        printSilent("Unable to help.");
    }
    
}

effect [int] __spy_buff_id_to_effect = {1:$effect[Punch Another Day], 2:$effect[For Your Brain Only], 3:$effect[Quantum of Moxie], 4:$effect[License to Punch], 5:$effect[Thunderspell], 6:$effect[Goldentongue], 7:$effect[The Living Hitpoints], 8:$effect[Initiative and Let Die], 9:$effect[A View to Some Meat], 10:$effect[Items Are Forever], 11:$effect[The Spy Who Loved XP]};
int [effect] __spy_effect_to_buff_id = {$effect[Punch Another Day]:1, $effect[For Your Brain Only]:2, $effect[Quantum of Moxie]:3, $effect[License to Punch]:4, $effect[Thunderspell]:5, $effect[Goldentongue]:6, $effect[The Living Hitpoints]:7, $effect[Initiative and Let Die]:8, $effect[A View to Some Meat]:9, $effect[Items Are Forever]:10, $effect[The Spy Who Loved XP]:11};
string [effect] __buff_descriptions = {$effect[Punch Another Day]:"+30 muscle", $effect[For Your Brain Only]:"+30 myst", $effect[Quantum of Moxie]:"+30 moxie", $effect[License to Punch]:"+100% muscle", $effect[Thunderspell]:"+100% myst", $effect[Goldentongue]:"+100% moxie", $effect[The Living Hitpoints]:"+100% HP/MP", $effect[Initiative and Let Die]:"+50% init", $effect[A View to Some Meat]:"+100% meat", $effect[Items Are Forever]:"+50% item", $effect[The Spy Who Loved XP]:"+5 stats/fight"};

void outputBuffHelpLine(boolean [effect] buffs_know_about, Tab [effect] buffs_to_tabs, boolean [int][int] tabs_known, boolean [string] commands, effect buff_effect)
{
    boolean is_known = buffs_know_about[buff_effect];
    Tab t = buffs_to_tabs[buff_effect];
    boolean within_configuration = is_known && (__state.tab_configuration[t.id] == t.length);
    
    int clicks_to_reach = 0;
    if (is_known && !within_configuration)
    {
        int best_target_number = computeBestTargetNumberForTab(t.id, t.length, tabs_known);
        int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
        int current_briefcase_number = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
        clicks_to_reach = computePathLengthToNumber(best_target_number, current_briefcase_number);
    }

    buffer line;
    boolean first = true;
    foreach command in commands
    {
        if (first)
        {
            first = false;
        }
        else
        {
            line.append(", or ");
        }
        
        line.append("<strong>");
        if (within_configuration)
            line.append("<font color=\"red\">");
        line.append(command);
        if (within_configuration)
            line.append("</font>");
        line.append("</strong>");
    }
    line.append(": ");
    line.append(__buff_descriptions[buff_effect]);
    
    line.append(" (");
    if (!is_known)
        line.append("not yet known");
    else
    {
        if (within_configuration)
            line.append("active");
        else
            line.append(clicks_to_reach + " click" + (clicks_to_reach > 1 ? "s" : "") + " to reach");
    }
    line.append(")");
    
    string colour = "";
    if (!is_known)
        colour = "#444444";
    
    printSilent(line, colour);
}

void handleBuffCommand(string command)
{
	string [int] words = command.split_string(" ");
	
	if (words.count() < 2)
	{
		
		//What buffs do we know about?
		boolean [effect] buffs_know_about;
        //boolean [effect] buffs_within_current_configuration;
        Tab [effect] buffs_to_tabs;
        boolean [int][int] tabs_known;
		for buff_id from 1 to 11
		{
			if (__file_state["tab effect " + buff_id] != "")
			{
                effect buff_effect = __spy_buff_id_to_effect[buff_id];
				buffs_know_about[buff_effect] = true;
                Tab t = TabFromFileBuff(buff_id);
                if (t.valid)
                    tabs_known[t.id][t.length] = true;
                //if (__state.tab_configuration[t.id] == t.length)
                    //buffs_within_current_configuration[buff_effect] = true;
                buffs_to_tabs[buff_effect] = t;
			}
		}
        printSilent("The buff command will let you use the briefcase's tab buffs. Each one takes at least three clicks, plus discovery time, and lasts for fifty turns.");
        printSilent("");
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[meat], $effect[A View to Some Meat]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[item], $effect[Items Are Forever]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[init], $effect[Initiative and Let Die]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[experience,xp], $effect[The Spy Who Loved XP]);
        printSilent("");
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[hp,mp], $effect[The Living Hitpoints]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[muscle], $effect[License to Punch]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[myst], $effect[Thunderspell]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[moxie], $effect[Goldentongue]);
        printSilent("");
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[muscle_absolute], $effect[Punch Another Day]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[myst_absolute], $effect[For Your Brain Only]);
        outputBuffHelpLine(buffs_know_about, buffs_to_tabs, tabs_known, $strings[moxie_absolute], $effect[Quantum of Moxie]);
        
        printSilent("");
        printSilent("The command \"briefcase buff item\" would spend clicks until we obtained the +50% item buff. \"briefcase buff meat\" would do the same for +meat.");
        //printSilent("<strong>meat</strong>: +100% meat (known)");
        //printSilent("<strong>items</strong>: +50% item (known, ready)", "red");
		//printSilent("buffs_know_about = " + buffs_know_about.to_json());
		//printSilent("buffs_within_current_configuration = " + buffs_within_current_configuration.to_json());
	}
	else
	{	
		outputStatus();
		chargeFlywheel();
		unlockButtons();
        discoverTabPermutation(true);
		actionSetHandleTo(true);
        
        if (__state.horizontal_light_states[3] == LIGHT_STATE_ON)
        {
            //Are the tabs moving?
            int [int] previous_tab_permutation = __state.tab_configuration.listCopy();
            actionVisitBriefcase();
            
            if (!configurationsAreEqual(previous_tab_permutation, __state.tab_configuration))
            {
                //This could theoreticaly be supported, but it would be complicated.
                printSilent("Buff command disabled while tabs are moving. Reset the briefcase? Or wind down the tabs?");
                return;
            }
        }
        //For computing deltas (have we gained this buff already)
        int [effect] starting_effect_count;
        foreach e in __spy_effect_to_buff_id
        {
            starting_effect_count[e] = e.have_effect();
        }
        for word_id from 1 to words.count() - 1
        {
            //Parse buff:
            effect desired_buff = $effect[none];
            string word = words[word_id].to_lower_case();
            if (word == "meat")
                desired_buff = $effect[A View to Some Meat];
            else if (word == "item" || word == "items")
                desired_buff = $effect[Items Are Forever];
            else if (word == "init" || word == "initiative")
                desired_buff = $effect[Initiative and Let Die];
            else if (word == "xp" || word == "exp" || word == "experience" || word == "stats")
                desired_buff = $effect[The Spy Who Loved XP];
            else if (word == "hp" || word == "mp" || word == "hitpoints")
                desired_buff = $effect[The Living Hitpoints];
            else if (word == "muscle_absolute" || word == "muscle_abs" || word == "punch")
                desired_buff = $effect[Punch Another Day];
            else if (word == "myst_absolute" || word == "myst_abs" || word == "brain")
                desired_buff = $effect[For Your Brain Only];
            else if (word == "moxie_absolute" || word == "moxie_abs" || word == "quantum")
                desired_buff = $effect[Quantum of Moxie];
            else if (word == "muscle_percentage" || word == "muscle_per" || word == "license" || word == "muscle")
                desired_buff = $effect[License to Punch];
            else if (word == "myst_percentage" || word == "myst_per" || word == "thunderspell" || word == "myst" || word == "mysticality")
                desired_buff = $effect[Thunderspell];
            else if (word == "moxie_percentage" || word == "moxie_per" || word == "goldentongue" || word == "moxie")
                desired_buff = $effect[Goldentongue];
            /*else if (word == "muscle")
            {
                if (my_basestat($stat[muscle]) >= 30)
                    desired_buff = $effect[License to Punch];
                else
                    desired_buff = $effect[Punch Another Day];
            }
            else if (word == "myst" || word == "mysticality")
            {
                if (my_basestat($stat[mysticality]) >= 30)
                    desired_buff = $effect[Thunderspell];
                else
                    desired_buff = $effect[For Your Brain Only];
            }
            else if (word == "moxie")
            {
                if (my_basestat($stat[moxie]) >= 30)
                    desired_buff = $effect[Goldentongue];
                else
                    desired_buff = $effect[Quantum of Moxie];
            }*/
            
            if (desired_buff == $effect[none])
            {
                printSilent("Unknown buff \"" + word + "\".");
                continue;
            }
            if (desired_buff.have_effect() > starting_effect_count[desired_buff]) //already happened
                continue;
            int desired_buff_id = __spy_effect_to_buff_id[desired_buff];
            //Try to identify it, if we don't know about it:
            if (__file_state["tab effect " + desired_buff_id] != "")
            {
                Tab t = TabFromFileBuff(desired_buff_id);
                if (t.valid)
                {
                    pressTab(t.id, t.length);
                }
            }
            
            //FIXME this part, where it's already identified
            //FIXME also don't re-do this if we already identified it earlier in another part of the loop
            int breakout = 25;
			while (!__file_state["_out of clicks for the day"].to_boolean() && breakout > 0)
            {
                if (desired_buff.have_effect() > starting_effect_count[desired_buff]) //we found it somehow, maybe the random tab
                    break;
                //Since we don't know the buff, we'll try identifying tabs.
                //Compute every tab's known state:
                boolean [int][int] tabs_known; //position, length
                boolean [int][int] desirable_tabs;
                for tab_id from 0 to 5
                {
                    for tab_length from 1 to 2
                    {
                        tabs_known[tab_id][tab_length] = false;
                        desirable_tabs[tab_id][tab_length] = false;
                    }
                }
                for buff_id from 0 to 11
                {
                    Tab t = TabFromFileBuff(buff_id);
                    if (t.valid)
                    {
                        tabs_known[t.id][t.length] = true;
                        if (buff_id == 10 || buff_id == 9) //+item, +meat
                            desirable_tabs[t.id][t.length] = true;
                    }
                }
                /*if (__setting_debug)
                {
                    //for now:
                    for tab_id from 0 to 5
                        tabs_known[tab_id][2] = true;
                }*/
                //printSilent("tabs_known = " + tabs_known.to_json());
                //Out of all the tabs currently active, are any unknown? If so, press them:
                int chosen_tab = -1;
                for tab_id from 0 to 5
                {
                    if (__state.tab_configuration[tab_id] > 0 && !tabs_known[tab_id][__state.tab_configuration[tab_id]])
                    {
                        chosen_tab = tab_id;
                        break;
                    }
                }
                if (chosen_tab != -1)
                {
                    //abort("YOU WERE THE CHOSEN " + chosen_tab);
                    //press:
                    actionPressTab(chosen_tab + 1);
                    continue;
                }
                
                //If there aren't any, we need to change our button state. Ideally, we want to spend the minimum number of button presses to reach a new tab to press.
                //That sounds complicated...
                //Go through each tab we don't know about, compute all numbers that tab is compatible with, compute the least distance (in button presses) to reach that point, pick the choice with the least presses?
                //I suppose the ideal would be "compute the path that uses the least number of button presses" weighing likelyhood of reaching that tab, but that would be too much for ASH, I think.
                //Also, try to take into account multiples? Like -100 might give us two new tabs instead of one? Or even three?
                
                //Though...
                //Don't we only have six buttons?
                //We could do a pre-pass, where if pressing one of the six buttons results in a new tab, press that. Taking into account if there are more than one unknown tabs for that.
                //Mostly I'm suggesting this because I can't think of a generic way to do the "more than one tab" test with the generic solution.
                //Well, hmm...
                //By definition, the generic solution will only contain new tabs in the final state.
                //As such, we can examine that final state, and count the number of unknown tabs.
                //And use that for tiebreaking?
                
                
                int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
                int current_briefcase_number = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
                
                int best_found_path_length = -1;
                int best_found_tab_id = -1;
                int best_found_target_number = -1;
                int best_found_tabs_at_final = -1;
                int best_found_desirable_tabs = -1;
                for tab_id from 0 to 5
                {
                    for tab_length from 1 to 2
                    {
                        if (tabs_known[tab_id][tab_length]) continue;
                        //Generate every possible number with this tab_id and length, and calculate the minimum distance to reach it:
                        int [int] operating_configuration;
                        for i from 0 to 5
                            operating_configuration[i] = 0;
                        
                        operating_configuration[tab_id] = tab_length;
                        while (true)
                        {
                            //printSilent("operating_configuration = " + operating_configuration.listJoinComponents(", "));
                            int operating_configuration_base_ten = convertTabConfigurationToBase10(operating_configuration, tab_permutation);
                            int path_length = computePathLengthToNumber(operating_configuration_base_ten, current_briefcase_number);
                            //printSilent("operating_configuration_base_ten = " + operating_configuration_base_ten + ", path_length = " + path_length);
                            boolean should_replace = false;
                            int desirable_tabs_count = 0;
                            for i from 0 to 5
                            {
                                if (desirable_tabs[i][operating_configuration[i]])
                                    desirable_tabs_count++;
                            }
                            //FIXME increment operating_configuration keeping tab_id stable:
                            if (best_found_path_length == -1 || path_length < best_found_path_length)
                            {
                                should_replace = true;
                            }
                            else if (path_length == best_found_path_length)
                            {
                                int found_tabs_at_final = countNumberOfUnknownTabs(operating_configuration, tabs_known);
                                if (found_tabs_at_final > best_found_tabs_at_final)
                                    should_replace = true;
                                if (desirable_tabs_count > best_found_desirable_tabs)
                                {
                                    should_replace = true;
                                    //printSilent("desirable_tabs_count = " + desirable_tabs_count + ", best_found_desirable_tabs = " + best_found_desirable_tabs);
                                }
                                
                            }
                            if (should_replace)
                            {
                                best_found_path_length = path_length;
                                best_found_tab_id = tab_id;
                                best_found_target_number = operating_configuration_base_ten;
                                best_found_tabs_at_final = countNumberOfUnknownTabs(operating_configuration, tabs_known);
                                best_found_desirable_tabs = desirable_tabs_count;
                            }
                            boolean done = incrementTabConfiguration(operating_configuration, tab_id);
                            if (done)
                            {
                                break;
                            }
                        }
                    }
                }
                //Now, reach best_found_target_number:
                if (best_found_target_number == -1)
                {
                    abort("Internal error: unable to compute a good target number.");
                    return;
                }
                printSilent("best_found_target_number = " + best_found_target_number + " unlocking " + best_found_tabs_at_final + " tabs of path length " + best_found_path_length + ".");
                setTabsToNumber(best_found_target_number, true); //only press once, because if we discover the wrong button, maybe we'll find a new one...?
            }
            
        }
	}
	
}


//FIXME lights four-six.
//Once it's spaded.
//... if it's spaded?
//(what if it's never spaded)


void makeTabsMove()
{
	//FIXME implement this
	if (__state.horizontal_light_states[3] != LIGHT_STATE_ON)
	{
		lightThirdLight();
		return;
	}
	abort("FIXME make tabs move");
}


void recalculateVarious()
{
	calculateTabs();
	if (__file_state["lightrings target number"] == "" && __file_state["lightrings observed"] != "")
		calculatePossibleLightringsValues(false, false);
}


if (__setting_output_help_before_main)
	outputHelp();
void main(string command)
{
	if ($item[kremlin's greatest briefcase].item_amount() + $item[kremlin's greatest briefcase].equipped_amount() == 0) //'
	{
		printSilent("You don't seem to own a briefcase.");
		return;
	}
	//readFileState(); //done already
	
	if (command == "help" || command == "" || command.replace_string(" ", "").to_string() == "")
	{
		if (!__setting_output_help_before_main)
		{
			outputHelp();
		}
		return;
	}
	if (__setting_output_help_before_main)
	{
		printSilent("");
		printSilent("<hr>");
		printSilent("");
	}
	
	actionVisitBriefcase();
	recalculateVarious();
	
	if (command == "status")
	{
		outputStatus();
		return;
	}
	if (command == "discover")
		discoverTabPermutation(true);
	
	//Do things we should always do:
	lightFirstLight();
	
	if (command == "charge" || command == "flywheel")
	{
		chargeFlywheel();
		printSilent("Done.");
		return;
	}
	if (command == "antennae" || command == "jacobs" || command == "ladder" || command == "jacob")
	{
		chargeAntennae();
		printSilent("Done.");
		return;
	}
	if (command == "reset")
	{
		boolean yes = user_confirm("Reset the briefcase? Are you sure?");
		if (!yes)
			return;
		//up (initial) -> down -> up -> down -> up does not reset
		int flips = 4;
		if (__state.handle_up)
			flips = 5;
		for i from 1 to flips
			actionManipulateHandle();
		printSilent("Done.");
		return;
	}
	if (command.stringHasPrefix("enchantment") || command.stringHasPrefix("e ") || command == "e")
	{
		handleEnchantmentCommand(command);
		return;
	}
	
	if (command.stringHasPrefix("buff") || command.stringHasPrefix("b ") || command == "b")
	{
        handleBuffCommand(command);
		return;
	}
	
	chargeFlywheel();
	
	outputStatus();
	if (command == "hose")
	{
		unlockMartiniHose();
	}
	if (command == "drawers")
	{
		openLeftDrawer();
		openRightDrawer();
	}
	if (command == "left")
	{
		openLeftDrawer();
	}
	if (command == "right")
	{
		openRightDrawer();
	}
	if (command == "unlock" || command == "solve")
	{
		unlockCrank();
		unlockMartiniHose();
		openLeftDrawer();
		openRightDrawer();
		unlockButtons();
	}
	if (command == "solve")
	{
        boolean yes = user_confirm("Are you sure you want to solve the briefcase? You probably want \"unlock\" instead. Solving the puzzles is not worthwhile at the moment, and may break the buff command.");
        if (!yes)
            return;
		lightSecondLight();
		lightThirdLight();
	}
	if (command == "second" || command == "mastermind")
	{
		lightSecondLight();
	}
	if (command == "third")
	{
		lightThirdLight();
	}
	if (command == "splendid" || command == "epic" || command == "martini" || command == "martinis" || command == "booze" || command == "drink" || command == "drinks")
	{
		//Increment tabs to 222222, collect splendid martinis:
		collectSplendidMartinis();
	}
	if (command == "identify")
	{
		calculateTabs();
		for function_id from 0 to 5
			discoverButtonWithFunctionID(function_id);
		int [int] possible_lightrings_values = calculatePossibleLightringsValues(true, false);
		if (possible_lightrings_values.count() < 100 && possible_lightrings_values.count() > 0)
			printSilent("Possible lightrings values: " + possible_lightrings_values.listJoinComponents(", "));
	}
	if (command.stringHasPrefix("tab"))
	{
		int tab_to_click = command.split_string(" ")[1].to_int();
		if (tab_to_click > 0 && tab_to_click <= 6)
		{
			actionPressTab(tab_to_click);
		}
	}
	if (command.stringHasPrefix("button"))
	{
		unlockButtons();
		string [int] split_command = command.split_string(" ");
		if (split_command.count() > 1)
		{
			int button_to_click = split_command[1].to_int();
			if (button_to_click > 0 && button_to_click <= 6)
			{
				actionPressButton(button_to_click);
				outputStatus();
			}
		}
	}
	//Internal:
    if (command == "discover_permutation")
    {
        discoverTabPermutation(true);
    }
	if (command == "handle")
	{
		actionManipulateHandle();
		if (__state.handle_up)
			printSilent("Handle is now UP.");
		else
			printSilent("Handle is now DOWN.");
	}
	if (command == "test_dials")
	{
		int [int] dial_configuration = {0, 1, 2, 2, 1, 0};
		actionSetDialsTo(dial_configuration);
	}
	if (command == "test_tab_construction")
	{
		for i from 1 to 6
		{
			for j from 0 to 2
			{
				string test = constructTabIdentifierForTab(i, j);
				printSilent(i + ", " + j + ": " + test);
			}
		}
	}
    if (command == "test_tab_path")
    {
        int current_number = convertTabConfigurationToBase10(__state.tab_configuration, stringToIntIntList(__file_state["tab permutation"]));
        foreach number in $ints[111, 727, 654, 719]
            printSilent("Path to " + number + ": " + computePathToNumber(number, current_number).listJoinComponents(", ") + " (length should be " + computePathLengthToNumber(number, current_number) + ")");
    }
	
	//After all that, do other stuff:
	//Collect drawers:
	if (__state.left_drawer_unlocked && !__file_state["_left drawer collected"].to_boolean())
	{
		actionCollectLeftDrawer();
	}
	if (__state.right_drawer_unlocked && !__file_state["_right drawer collected"].to_boolean())
	{
		actionCollectRightDrawer();
	}
	print("Done.");
}

/*
Seen messages: 
You press the lock actuator to the side.
" The tab situation at the bottom of the case changes." / "Click!" / "You press a button on the side of the case."

"(duration: 50 Adventures)" / "Click click click!" / "You pull a tab out from the bottom of the case, and then it retracts to its original position." / "Your briefcase bleeps and a little needle pops out of the lining. Warily, you prick your finger, and immediately feel an intense rush of adrenaline that makes you feel like you could beat a sumo wrestler to death with a leather sofa.<center><table><tr><td&g t;<img class=hand src="https://s3.amazonaws.com/images.kingdomo floathing.com/itemimages/effect004.gif" onClick='eff("db08e7fe4feec0a00fa8e9c5686c522 2");' width=30 height=30 alt="License to Punch" title="License to Punch"></td><td valign=center class=effect>You acquire an effect: <b>License to Punch</b>"

"You hear the whine of a capacitor charging inside the case." / "You turn the crank."
"You flip the handle up."
"You flip the handle down."
Nothing happens. Hmm. Maybe it's out of... clicks?  For the day?
*/
//"<b>-3 MP to use Skills</b></font>" / "<font color=blue><s>Regenerate 5-10 HP & MP per Adventure</s>" / "A symphony of mechanical buzzing and whirring ensues, and your case seems to be... different somehow." / "Click!" / "You press a button."