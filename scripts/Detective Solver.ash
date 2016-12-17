//Detective Solver.ash
//Completes all three daily cases for the eleventh precinct.
//This script is in the public domain.
since 17.1;
string __version = "1.1.2";

string __historical_data_file_name = "Detective_Solver_" + my_id() + "_Historical_Data.txt";
int __setting_time_limit = 300;
int __setting_max_attempts = 100;
int __setting_visit_url_limit = 400;
boolean __setting_allow_automatic_accusations = true;

boolean __setting_debug = false;
boolean __setting_output_various_debug_text = false;






//Code from Guide:
void listAppend(string [int] list, string entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
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

buffer to_buffer(string str)
{
	buffer result;
	result.append(str);
	return result;
}

//to_int will print a warning, but not halt, if you give it a non-int value.
//This function prevents the warning message.
int to_int_silent(string value)
{
	if (is_integer(value))
        return to_int(value);
	return 0;
}

string capitaliseFirstLetter(string v)
{
	buffer buf = v.to_buffer();
	if (v.length() <= 0)
		return v;
	buf.replace(0, 1, buf.char_at(0).to_upper_case());
	return buf.to_string();
}

//Utility:
string lineariseMap(boolean [string] map)
{
	buffer output;
	boolean first = true;
	foreach s in map
	{
		if (first)
			first = false;
		else
			output.append(", ");
		output.append(s);
	}
	
	return output.to_string();
}

string lineariseMap(boolean [int] map)
{
	buffer output;
	boolean first = true;
	foreach s in map
	{
		if (first)
			first = false;
		else
			output.append(", ");
		output.append(s);
	}
	
	return output.to_string();
}

string stringAddSpacersEvery(string s, int distance)
{
	buffer out;
	//easiest no-effort implementation, which isn't particularly efficient:
	for i from 0 to s.length() - 1
	{
		if ((i + 1) % distance == 0)
			out.append("\n");
		out.append(s.char_at(i));
	}
	
	return out.to_string();
}

//Main:
boolean __extended_time_limit_previously = false; //only allow this once
boolean __disable_output = false;
boolean [string] __seen_core_text_test_data;
boolean __write_test_data = false;
boolean __abort_on_match_failure = false;
int __dollars_earned = 0;

int CORE_TEXT_MATCH_TYPE_UNKNOWN = 0;
int CORE_TEXT_MATCH_TYPE_NAME = 1;
int CORE_TEXT_MATCH_TYPE_LOCATION = 2;
int CORE_TEXT_MATCH_TYPE_OCCUPATION = 3;
int CORE_TEXT_MATCH_TYPE_NO_INFORMATION = 4;
int CORE_TEXT_MATCH_TYPE_BUGGED = 5;

string coreTextMatchTypeDescription(int type)
{
	if (type == CORE_TEXT_MATCH_TYPE_UNKNOWN)
		return "unknown";
	else if (type == CORE_TEXT_MATCH_TYPE_NAME)
		return "name";
	else if (type == CORE_TEXT_MATCH_TYPE_LOCATION)
		return "location";
	else if (type == CORE_TEXT_MATCH_TYPE_OCCUPATION)
		return "occupation";
	else if (type == CORE_TEXT_MATCH_TYPE_NO_INFORMATION)
		return "no information";
	else if (type == CORE_TEXT_MATCH_TYPE_BUGGED)
		return "bugged";
	return "";
}

//Not the killer, but cross-examining
Record InterrogationClaim
{
	int type_interrogated_by; //NAME or OCCUPATION - the type we asked about
	int claim_type; //NAME, OCCUPATION, LOCATION
	int person_asking_about_by_location_id;
	string claim;
	boolean verified;
	boolean was_true;
};

void listAppend(InterrogationClaim [int] list, InterrogationClaim entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

Record Individual
{
	boolean exists;
	string name;
	string occupation;
	int location_id;
	string personality;
	
	boolean asked_about_killer;
	boolean proven_liar;
	
	boolean knows_about_killer;
	string suspects_killer_name;
	string suspects_killer_occupation;
	
	boolean [string] possible_choices_by_name;
	boolean [string] possible_choices_by_occupation;
	boolean [int] possible_choices_by_name_location_ids;
	boolean [int] possible_choices_by_occupation_location_ids;
	
	boolean [int] choices_name_we_visited_by_location_id;
	boolean [int] choices_occupation_we_visited_by_location_id;
	InterrogationClaim [int] interrogation_claims;
};

Individual IndividualMakeBlank()
{
	Individual blank;
	return blank;
}

void listAppend(Individual [int] list, Individual entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

int IndividualGetInformationCount(Individual i)
{
	int information_count = 0;
	if (i.name != "")
		information_count += 1;
	if (i.occupation != "")
		information_count += 1;
	if (i.location_id > 0)
		information_count += 1;
	return information_count;
}

int IndividualGetInformationCountIgnoringType(Individual i, int type)
{
	int information_count = 0;
	if (i.name != "" && type != CORE_TEXT_MATCH_TYPE_NAME)
		information_count += 1;
	if (i.occupation != "" && type != CORE_TEXT_MATCH_TYPE_OCCUPATION)
		information_count += 1;
	if (i.location_id > 0 && type != CORE_TEXT_MATCH_TYPE_LOCATION)
		information_count += 1;
	return information_count;
}

Record SolveState
{
	int [string] location_names_to_ids;
	string [int] location_ids_to_names;
	Individual [int] known_individuals;
	boolean [int] location_ids_visited;
	
	int minutes_elapsed;
	int last_location_visited;
	int known_killer_location_id; //valid when > 0
	
	boolean failed; //can't load for whatever reason, stop loop
};

SolveState __state;

//If the string is empty, return replacement string instead. Used for filling in ? for unknown values.
string processEmptyStringAs(string s, string replacement)
{
	if (s == "")
		return replacement;
	return s;
}

void IndividualOutput(Individual i)
{
	if (!i.exists)
		return;
	if (__disable_output)
		return;
	print_html(processEmptyStringAs(i.name, "?") + ", the victim's " + processEmptyStringAs(i.occupation, "?") + " in the " + __state.location_ids_to_names[i.location_id] + ".");
	
	string [int] attributes;
	if (i.personality != "")
		attributes.listAppend(i.personality);
	if (i.proven_liar)
		attributes.listAppend("a proven <font color=red>liar</font>");
	if (i.asked_about_killer)
		attributes.listAppend("we've asked about the killer");
	if (i.asked_about_killer)
	{
		if (i.knows_about_killer)
		{
			if (i.suspects_killer_name != "")
				attributes.listAppend("they know the killer's name: " + i.suspects_killer_name);
			if (i.suspects_killer_occupation != "")
				attributes.listAppend("they know the killer's occupation: " + i.suspects_killer_occupation);
			//attributes.listAppend("they know information about the killer: " + i.suspects_killer_name + i.suspects_killer_occupation);
		}
		else
			attributes.listAppend("they do not know about the killer");
	}
	
	if (attributes.count() > 0)
		print_html(attributes.listJoinComponents(", ", "and").capitaliseFirstLetter() + ".");
	//print_html(i.to_json().replace_string(",", ", "));
	if (__setting_debug || true) //should be readable enough
	{
		/*if (i.possible_choices_by_name.count() > 0)
			print_html("possible_choices_by_name = " + i.possible_choices_by_name.lineariseMap());
		if (i.possible_choices_by_occupation.count() > 0)
			print_html("possible_choices_by_occupation = " + i.possible_choices_by_occupation.lineariseMap());
		if (i.possible_choices_by_name_location_ids.count() > 0)
			print_html("possible_choices_by_name_location_ids = " + i.possible_choices_by_name_location_ids.lineariseMap());
		if (i.possible_choices_by_occupation_location_ids.count() > 0)
			print_html("possible_choices_by_occupation_location_ids = " + i.possible_choices_by_occupation_location_ids.lineariseMap());
		if (i.choices_name_we_visited_by_location_id.count() > 0)
			print_html("choices_name_we_visited_by_location_id = " + i.choices_name_we_visited_by_location_id.lineariseMap());
		if (i.choices_occupation_we_visited_by_location_id.count() > 0)
			print_html("choices_occupation_we_visited_by_location_id = " + i.choices_occupation_we_visited_by_location_id.lineariseMap());*/
		
		if (i.interrogation_claims.count() > 0)
		{
			foreach key, claim in i.interrogation_claims
			{
				buffer claim_output;
				claim_output.append("Asked by " + coreTextMatchTypeDescription(claim.type_interrogated_by));
				claim_output.append(", claimed the " + coreTextMatchTypeDescription(claim.claim_type));
				claim_output.append(" in the " + __state.location_ids_to_names[claim.person_asking_about_by_location_id]);
				claim_output.append(" was \"" + claim.claim + "\"");
				claim_output.append(" which was ");
				if (claim.verified)
				{
					claim_output.append("verified");
					if (claim.was_true)
						claim_output.append(" and correct");
					else
						claim_output.append(" and a <font color=red>lie</font>");
				}
				else
					claim_output.append("not verified");
				claim_output.append(".");
				print_html(claim_output);
			}
			//print_html("interrogation_claims = " + i.interrogation_claims.to_json());
		}
	}
	print_html("");
}

void SolveStateOutput(SolveState state)
{
	if (__disable_output)
		return;
	//print_html("State: ");
	if (false)
	{
		string [int] locations_output;
		foreach name, id in state.location_names_to_ids
		{
			locations_output.listAppend(id + ": " + name);
		}
		print_html("Locations: " + locations_output.listJoinComponents(", ", "and") + ".");
	}
	print_html("Individuals: ");
	foreach key, i in state.known_individuals
	{
		IndividualOutput(i);
	}
	if (state.location_ids_visited.count() > 0)
	{
		//print_html("Visited location ids " + state.location_ids_visited.lineariseMap() + ".");
		string [int] locations_output;
		foreach location_id in state.location_ids_visited
		{
			locations_output.listAppend(state.location_ids_to_names[location_id]);
		}
		print_html("Visited locations " + locations_output.listJoinComponents(", ", "and") + ".");
	}
	print_html(state.minutes_elapsed + " minutes elapsed.");
	if (state.last_location_visited > 0)
		print_html("Current location: " + state.location_ids_to_names[state.last_location_visited]);
	if (state.known_killer_location_id > 0)
		print_html("We know the killer! They're in the " + state.location_ids_to_names[state.known_killer_location_id] + ".");
	//print_html("State = " + state.to_json().stringAddSpacersEvery(150));
}

Individual SolveStateLookupIndividualByName(SolveState state, string name)
{
	foreach key, i in state.known_individuals
	{
		if (i.name == name)
			return i;
	}
	Individual blank;
	return blank;
}

Individual SolveStateLookupIndividualByOccupation(SolveState state, string occupation)
{
	foreach key, i in state.known_individuals
	{
		if (i.occupation == occupation)
			return i;
	}
	Individual blank;
	return blank;
}

Individual SolveStateLookupIndividualByLocationID(SolveState state, int location_id)
{
	foreach key, i in state.known_individuals
	{
		if (i.location_id == location_id)
			return i;
	}
	Individual blank;
	return blank;
}

//This function is like a sponge. Partial relationships fed in can be re-correlated later.
//So, if you say person in room 5 is the writer, then later say the person in room 5 is named William Gibson, those two data points will be cross-correlated and merged.
void SolveStateAddIndividualInformation(string name, string occupation, int location_id)
{
	//Do we have an individual matching these attributes?
	if (name != "")
	{
		Individual i = __state.SolveStateLookupIndividualByName(name);
		if (i.exists)
		{
			if (occupation != "")
				i.occupation = occupation;
			if (location_id > 0)
				i.location_id = location_id;
			return;
		}
	}
	if (occupation != "")
	{
		Individual i = __state.SolveStateLookupIndividualByOccupation(occupation);
		if (i.exists)
		{
			if (name != "")
				i.name = name;
			if (location_id > 0)
				i.location_id = location_id;
			return;
		}
	}
	if (location_id > 0)
	{
		Individual i = __state.SolveStateLookupIndividualByLocationID(location_id);
		if (i.exists)
		{
			if (name != "")
				i.name = name;
			if (occupation != "")
				i.occupation = occupation;
			return;
		}
	}
	
	//No? Add it anyways:
	Individual i;
	i.exists = true;
	i.name = name;
	i.occupation = occupation;
	i.location_id = location_id;
	__state.known_individuals.listAppend(i);
}


void SolveStateReverifyClaims(SolveState state)
{
	foreach key, i in state.known_individuals
	{
		if (false && i.proven_liar) //FIXME stop early later? or not
			continue;
		foreach key2, claim in i.interrogation_claims
		{
			if (claim.verified)
				continue;
			//Are they telling the truth?
			Individual person_talking_about = state.SolveStateLookupIndividualByLocationID(claim.person_asking_about_by_location_id);
			if (!person_talking_about.exists)
				continue;
			boolean ended_up_being_true = false;
			if (claim.claim_type == CORE_TEXT_MATCH_TYPE_NAME)
			{
				if (person_talking_about.name == "")
					continue;
				if (person_talking_about.name == claim.claim)
					ended_up_being_true = true;
			}
			else if (claim.claim_type == CORE_TEXT_MATCH_TYPE_OCCUPATION)
			{
				if (person_talking_about.occupation == "")
					continue;
				if (person_talking_about.occupation == claim.claim)
					ended_up_being_true = true;
			}
			else if (claim.claim_type == CORE_TEXT_MATCH_TYPE_LOCATION)
			{
				if (person_talking_about.location_id <= 0)
					continue;
				int claim_location_id = state.location_names_to_ids[claim.claim];
				if (person_talking_about.location_id == claim_location_id) //note they are not always telling the truth if it's their own location
					ended_up_being_true = true;
			}
			else
			{
				continue;
			}
			
			
			claim.verified = true;
			claim.was_true = ended_up_being_true;
			if (!ended_up_being_true)
			{
				if (!i.proven_liar && !__disable_output)
					print_html(i.name + " <font color=red>lies</font>.");
				i.proven_liar = true;
				//break; //FIXME stop early later? or not
			}
		}
	}
}

void SolveStateFindKiller(SolveState state)
{
	//Checking what we know, can we deduce the killer?
	int people_that_cannot_give_information_on_the_killer = 0;
	foreach key, i in state.known_individuals
	{
		if (i.proven_liar || (i.asked_about_killer && !i.knows_about_killer))
		{
			 people_that_cannot_give_information_on_the_killer += 1;
		}
	}
	foreach key, i in state.known_individuals
	{
		if (i.proven_liar)
			continue;
		if (!i.knows_about_killer)
			continue;
		
		//Use lie hypothesis - liars always lie unless they're asked about name and give a location.
		boolean trustworthy = false;
		//Do they have a verified claim that was true?
		foreach key2, claim in i.interrogation_claims
		{
			if (!claim.verified)
				continue;
			if (!claim.was_true)
				continue;
			//if (!(claim.type_interrogated_by == CORE_TEXT_MATCH_TYPE_NAME && claim.claim_type == CORE_TEXT_MATCH_TYPE_LOCATION)) //no information from this
			if (true)
			{
				trustworthy = true;
				break;
			}
		}
		//Alternatively, is everyone else untrustworthy?
		if (people_that_cannot_give_information_on_the_killer == 8)
		{
			trustworthy = true;
		}
		
		
		if (trustworthy)
		{
			//J'accuse!
			Individual killer;
			if (i.suspects_killer_name != "")
				killer = state.SolveStateLookupIndividualByName(i.suspects_killer_name);
			else if (i.suspects_killer_occupation != "")
				killer = state.SolveStateLookupIndividualByOccupation(i.suspects_killer_occupation);
			if (killer.exists)
			{
				state.known_killer_location_id = killer.location_id;
				return;
			}
		}
	}
}

void SolveStateVerifyLieHypothesis(SolveState state)
{
	//Old hypothesis: If we asked by name, and they gave a location, they are always telling the truth. In every other case, liars are lying.
	//CDM seems to have changed this. New hypothesis: Liars always lie.
	boolean failed = false;
	foreach key, i in state.known_individuals
	{
		foreach key2, claim in i.interrogation_claims
		{
			if (!claim.verified)
				continue;
			boolean state_must_be_true = false;
			boolean state_must_be_false = false;
			if (i.proven_liar)
			{
				if (false && claim.type_interrogated_by == CORE_TEXT_MATCH_TYPE_NAME && claim.claim_type == CORE_TEXT_MATCH_TYPE_LOCATION)
					state_must_be_true = true;
				else
					state_must_be_false = true;
			}
			//else
				//state_must_be_true = true;
			if (state_must_be_true && !claim.was_true)
			{
				if (!__disable_output)
					print_html("Lie hypothesis incorrect for " + i.location_id + ". Must be true, and it wasn't: " + claim.to_json());
				//return;
				failed = true;
			}
			else if (state_must_be_false && claim.was_true)
			{
				if (!__disable_output)
					print_html("Lie hypothesis incorrect " + i.location_id + ". Must be false, and it wasn't: " + claim.to_json());
				//return;
				failed = true;
			}
		}
	}
	if (!failed && !__disable_output)
		print_html("Lie hypothesis currently holding.");
	
}


Record CoreTextMatcher
{
	string regex_indicating_match;
	string regex_extractor;
	int type;
};

//There could be other matchers, for intro text, asking about themselves, etc. But we don't use that information.
CoreTextMatcher [int] __core_text_matchers_by_name;
CoreTextMatcher [int] __core_text_matchers_by_occupation;
CoreTextMatcher [int] __core_text_matchers_killer;

CoreTextMatcher CoreTextMatcherMake(string regex_indicating_match, string regex_extractor, int type)
{
	CoreTextMatcher result;
	result.regex_indicating_match = regex_indicating_match;
	result.regex_extractor = regex_extractor;
	result.type = type;
	return result;
}

void listAppend(CoreTextMatcher [int] list, CoreTextMatcher entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

Record CoreTextMatch
{
	int type;
	string match;
};

void listAppend(CoreTextMatch [int] list, CoreTextMatch entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

CoreTextMatch findCoreTextMatch(string core_text, CoreTextMatcher [int] matchers)
{
	CoreTextMatch blank;
	CoreTextMatch [int] results;
	
	foreach key, m in matchers
	{
		//print_html("Testing against \"" + m.containing_text_indicating_match + "\"");
		if (core_text.group_string(m.regex_indicating_match).count() > 0)
		{
			CoreTextMatch result;
			string [int][int] match = core_text.group_string(m.regex_extractor);
			if (m.type != CORE_TEXT_MATCH_TYPE_NO_INFORMATION && m.type != CORE_TEXT_MATCH_TYPE_BUGGED)
			{
				if (match.count() == 0)
				{
					//print_html("Failed match on \"" + m.regex_indicating_match.entity_encode() + "\"");
					continue;
				}
				result.match = match[0][1];
				if (result.match == "")
				{
					//print_html("Failed match on \"" + m.regex_indicating_match.entity_encode() + "\"");
					continue;
				}
				//Adjust match:
				if (m.type == CORE_TEXT_MATCH_TYPE_OCCUPATION)
				{
					if (result.match.contains_text("the victim's "));
						result.match = result.match.replace_string("the victim's ", "");
					if (result.match.contains_text("the "));
						result.match = result.match.replace_string("the ", "");
					if (result.match.contains_text("'s "))
					{
						//Madelyn's cousin, etc
						result.match = result.match.group_string("'s (.*)")[0][1];
					}
				}
				else if (m.type == CORE_TEXT_MATCH_TYPE_LOCATION)
				{
					if (result.match.contains_text("the "));
						result.match = result.match.replace_string("the ", "");
				}
				if (result.match.contains_text("?"))
				{
					if (!__disable_output)
						print_html("MATCH ERROR for matcher \"" + m.regex_indicating_match.entity_encode() + "\", has question mark: \"" + result.match.entity_encode() + "\" Source text is \"" + core_text + "\"");
					if (__abort_on_match_failure)
						abort("Match failure");
					return blank;
				}
				if (result.match.contains_text("<"))
				{
					if (!__disable_output)
						print_html("MATCH ERROR for matcher \"" + m.regex_indicating_match.entity_encode() + "\", has HTML: \"" + result.match.entity_encode() + "\" Source text is \"" + core_text + "\"");
					if (__abort_on_match_failure)
						abort("Match failure");
					return blank;
				}
				if (result.match != "" && result.match.char_at(0) == " ")
				{
					if (!__disable_output)
						print_html("MATCH ERROR for matcher \"" + m.regex_indicating_match.entity_encode() + "\", starts with a space: \"" + result.match.entity_encode() + "\" Source text is \"" + core_text + "\"");
					if (__abort_on_match_failure)
						abort("Match failure");
					return blank;
				}
				/*if (result.match.length() >= 20)
				{
					if (!!__disable_output)
						print_html("MATCH ERROR for matcher \"" + m.regex_indicating_match.entity_encode() + "\", seems to be too long: \"" + result.match.entity_encode() + "\" Source text is \"" + core_text + "\"");
					if (__abort_on_match_failure)
						abort("Match failure");
					return blank;
				}*/
			}
			result.type = m.type;
			
			/*if (result.type == CORE_TEXT_MATCH_TYPE_NO_INFORMATION)
				print_html("matched no information from \"" + m.regex_indicating_match.entity_encode() + "\"");
			else
				print_html("matched \"" + result.match + "\" of type " + result.type);*/
				
				
			if (results.count() > 0)
			{
				foreach key, r2 in results
				{
					if (r2.match == result.match)
						continue;
					if (!__disable_output)
						print_html("MATCH ERROR for matcher \"" + m.regex_indicating_match.entity_encode() + "\", has too many results: \"" + result.match.entity_encode() + "\" Source text is \"" + core_text + "\"");
					if (__abort_on_match_failure)
						abort("Match failure");
					return blank;
				}
			}
			
			results.listAppend(result);
		}
	}
	if (results.count() > 0)
	{
		return results[0];
	}
	
	return blank;
}

void verifyMatchers(CoreTextMatcher [int] matchers)
{
	foreach key, m in matchers
	{
		if ((m.regex_indicating_match.contains_text("?") && !m.regex_indicating_match.contains_text("\\?")) || (m.regex_extractor.contains_text("?") && !m.regex_extractor.contains_text("\\?")))
		{
			abort("Matcher \"" + m.regex_indicating_match.entity_encode() + "\" / \"" + m.regex_extractor.entity_encode() + "\" contains unescaped question mark.");
		}
	}
}

void initialiseCoreTextMatchers()
{
	//Killer:
	//Unknown:
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Jeez, man, you got me. ...Ha ha, no wait, that sounded bad. I mean, like, you got me, not you got me, right. Like, I dunno who did it.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Heck if I know, dude,\" she says. \"Like, your guess is as good as mine, right.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Heck if I know, dude,\" he says. \"Like, your guess is as good as mine, right.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Dang, dude, like, you're the detective, right. I dunno from this whole murder thing, I'm just mindin' my own.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("committed suicide, don't you see! To put everyone off the scent!\"<p>\"Well, I've seen the pictures,\" you say, \"and I can pretty much confirm it wasn't a suicide", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("ya wanna know, but my rep'll take a real dive if people think I'm a rat, you know what I'm sayin'.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("I was all the way on the other side of the house when it happened, and I didn't hear a thing. Sorry.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("I hate to disappoint ya, but I haven't got a clue who could've done it. Far as I know, everyone in this house loved ", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Who do you think is the most likely to be the killer.\" you ask.<p>\"No idea,\" he says, turning a page in his book", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"No idea,\" he says, turning a page in his book.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>He ignores you and keeps reading.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>He shakes his head slightly, but doesn't say anything.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Well, in my poem I'm attributing the murder to a black shadow wrought from the ghosts of those murdered by capitalism", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("I think it was probably either a raven, or a metaphor for the tyranny of social expectations", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Don't you get it. Don't you <i>see.</i> They <i>all</i> did it! They're all in on it together!", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("If I knew that, I wouldn't be out of my mind with fear!", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("I do not feel that the question of who murdered", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("his is not my field of knowledge or experience, Detective,", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("because it is only through the interest of people such as yourself that our society can withstand the forces of chaos for the brief time that we inhabit this universe. However, I do not share your interest.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"If I knew that, this ridiculous little mishap would have been handled already!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Perhaps you should figure it out, Detective, so that I needn't stand around this place answering your questions any longer!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"if you cannot be bothered to do your own job, I most certainly am not going to do it for you.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"What, now you want me to do your damn job for you.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Get the hell outta here! Even if I <i>did</i> know, I still wouldn't tell a cop!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Why, I haven't the faintest idea. I was rather hoping you could tell me, or else I won't be able to give my poem a proper ending.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Look, cop -- I don't know who did it, and if I did, I still wouldn't tell you! Get out of my face, already!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"If you hadn't ordered me to stay in here, maybe I'd be able to tell you! How about I just follow you around, I promise I won't get in the way!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"I sure wish I knew! I've been looking all over for clues, but the bad guy really covered their tracks on this one!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"I haven't figured it out yet. This is bunches harder than when I solved the Mystery of Pirate Island!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Who the devil's that.\"<p>\"Made it up. Sorry, it was a shot in the dark.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Sorry, old bean. I can certainly understand why you'd ascribe me a certain Sherlockian intelligence, but I haven't the first clue of who might have done that deed.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Not the slightest idea. Not a tiddle, nor a jot. I could no more tell you the name of", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>She ignores you and keeps reading.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"No idea,\" she says, turning a page in her book.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"No idea who it was. If they tried that on me, though, I'd tear them in half. Literally. I've been practicing on sides of beef.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"No idea. I was blastin' my delts at the time, so I didn't notice anything unusual.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"If they try and pull that murder stuff on me, though, I'll tie 'em in a knot like a fireplace poker!\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("You're asking me. Why not ask me something I know the answer to, like who's supposed to clean the toilets around here. The answer to that is not, in fact, me, but guess what. I end up having to do it anyway.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("but I do know they'd have saved me a lot of trouble if they'd killed me too. Guess they couldn't be bothered to waste the bullet or whatever.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"but I guarantee if you ask anyone else, they'll all say it was me. That's how it goes around here. I do all the work, and do I get any of the credit. No, don't bother answering, it's a rhetorical question and the answer is perfectly obvious anyway.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>She shakes her head slightly, but doesn't say anything.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>He shakes his head slightly, but doesn't say anything.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION));
	
	
	

	//	([^\.]*)\.
	//	([^,]*),
	//	([^\\?]*)\\?
	
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("if you correlate everyone's movements and alibis on this chart I made...\" <p>\"The short version, please,\" you interrupt. <p>\"It's gotta be", "It's gotta be ([^!]*)", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("notebook and quickly scans the pages. \"I think it's", "\"I think it's (.*), Detective!", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("can't prove it, but if you send these hair and fingerprint samples to the police lab...\"<p>\"I'll just take your word for it, kid.", "Oh, it's definitely (.*), Detective!", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Well, since you asked me, Detective,", "I would say it was undoubtedly that snivelling little upstart of a (.*)\\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Well, since you asked me, Detective,", "I would say it was undoubtedly that snivelling little upstart of an (.*)\\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Are you serious, Detective. Have you <i>met</i> them", "Without question, it was ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Very well, if it will get me out of this miserable situation more quickly. It was", "It was (.*) --", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("That's the query whizzing around everyone's racetrack today. Who put the nails in poor old", "It was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("It's interesting you should ask me that, Detective, because I was just asking myself the very same", "Oh! It was ([^,]*), of course.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("And that's the honest truth, not a fib to get out of an unpleasant betrothal arrangement, I assure you.", "\"It was ([^,]*), Detective,\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Oh, that's as easy as tearing a telephone in half,\"", "\"It was ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("muscles at you in several bodybuilder poses. You aren't sure how that relates to the question.", "\"That's easy, it was her ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("muscles at you in several bodybuilder poses. You aren't sure how that relates to the question.", "\"That's easy, it was his ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"...Like I don't wanna be a narc or whatever, so I don't wanna name names, you know dude. But okay, I will say you should check out", "I will say you should check out ([^\.]*)\. Like for real, you know.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"I wondered when you were finally gonna get around to asking that! Like, jeez, right. Listen, it was totes", "it was totes ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Okay well like, hold onto your hat dude -- it was", "-- it was (.*)! Like crazy, right. Like who would've guessed that. But it so totally was!\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("I can't think of a single decent rhyme for", ", \"it was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"It was the grim spectre of guilt, which gripped", "<p>\"No metaphors, please.\"<p>\"It was his ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"It was the grim spectre of guilt, which gripped", "<p>\"No metaphors, please.\"<p>\"It was her ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Well, obviously, it was karmic debt for decades of selfish corporatism,\"", "\"It was his ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Well, obviously, it was karmic debt for decades of selfish corporatism,\"", "\"It was her ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"You think they'll do that anyway, though,\" you say. \"If you tell me who it is, I can at least help avenge you.\"<p>\"Good point. Okay, it was", "<p>\"Good point. Okay, it was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("p>\"Okay, I'll tell you, but I need police protection!\"", "looks around, then whispers, \"It was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"if I was working for them, then I'd already know who did it, so it wouldn't matter if you told me.\"<p>\"...I guess you have a point. All right, it was", "All right, it was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"I hope you will relish that feeling of surprise, for it is one of the few ways in which a person can prove ", "<p>\"The killer was ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"If you have witnessed for yourself the lizard-like quality of their eyes, Detective, you must undoubtedly have reached the same conclusion.\"", "<p>\"I can only assume it was ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Every decision we make, every event we experience, kills our past self and creates a new ", "\"Ah. In that case, it was her ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Every decision we make, every event we experience, kills our past self and creates a new ", "\"Ah. In that case, it was his ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("I haven't got any evidence for this, y'unnerstand. But if ya ask me -- which you did -- I'd say it was", "I'd say it was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Well Detective, you know what they always say,\"", "\"The (.*) did it!\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Well I gotta say, Detective, I wasn't expecting such a direct line of questioning,\"", "\"Tell ya what, I'll give ya a hint: check out ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Do you have some kind of evidence for that.\" you ask.<p>No response.", "<p>\"It was ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Why do you say that. ...Hello.\"", "\"I think it was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Can you tell me anything more concrete.\"<p>\"No.\"", "<p>\"Investigate ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"How about a name.\" you ask.<p>\"How about up yours, cop.\"", "\"if I was you -- and I'm friggin' glad I'm not, hah -- but if I was you I'd look into ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Do you have any evidence for that.\"<p>\"Yeah, sure. Right here in my pocket.\"", "\"Okay. It was ([^\.]*)\.\"<p>", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Hey buddy, these muscles don't lie.\"", "says. \"It was ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("That's what I figure.\"<p>\"Why do you say that.\" you ask.<p>\"Because I'm a friggin' psychic. Get bent!\"", "<p>\"Oh, well, it was probably ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Do you actually expect me to rat out one of my precious friends and/or colleagues.\"<p>\"...Are you joking.\"<p>\"Yes.", "<p>\"...Are you joking.\"<p>\"Yes. (.*) killed", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Does it make you happy to know that. If it does, please let me know, because having never experienced that emotion myself, it's difficult for me to detect it in others.\"", "<p>\"It was ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"if I tell you, what's in it for me.\"<p>\"Nothing.\"<p>\"Oh good, my standard compensation. Okay, it was", "Okay, it was ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	
	
	
	//	([^\.]*)\.
	//	([^,]*),
	//	([^\\?]*)\\?
	
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("You really want to know who I think did it.", "\"It was (.*) for sure, Detective!", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Okay, so, first I measured some footprints out in the driveway, and...\"", "<p>\"Oh, okay! It was (.*)!\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("says excitedly. \"Means, motive, and opportunity -- just like the Junior Detective's Handbook says!\"", "\"It's just gotta be (.*), Detective,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Do you have any evidence to back that up.\"<p>She glances up at you, then turns a page and keeps reading.", "\"Hmm.\" After a long pause, she mutters, \"Probably ([^\.]*)\.\"<p>", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Do you have any evidence to back that up.\"<p>He glances up at you, then turns a page and keeps reading.", "\"Hmm.\" After a long pause, he mutters, \"Probably ([^\.]*)\.\"<p>", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"<p>\"Okay,\" you say. \"And why do you say that.\"<p>.* turns a page and goes back to her reading.", "head to the side in thought for a moment. \"\.\.\.([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"<p>\"Okay,\" you say. \"And why do you say that.\"<p>.* turns a page and goes back to his reading.", "head to the side in thought for a moment. \"\.\.\.([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("looks up at you, and thinks for a second. \"Hmm...\"<p>\"Yes.\"<p>\"\.\.\.probably ", "\"\.\.\.probably ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Yeah, it's not enough that I have to do everything else around here, I might as well solve the murder for the detective too,\"", "\"It was ([^\.]*)\. There\. Happy.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Yeah, sure. Why not. I might as well tell you, what do I care anyway. It was", "It was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("Go ahead and make a big show about how you solved the case all by yourself with your big detective skills, I don't expect to receive any credit for the information.\"", "\"All right. It was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Have you not witnessed for yourself the madness that gnaws at the core of their being, brought on by irrational fear of the unknown.\"<p>\"I guess not,\" you shrug.", "<p>\"It was ([^,]*), Detective,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"The desperate eyes, the hunger, the growl of an animal. No human who would take a life can truly hide these things.\"", "<p>\"Great. Okay. So\.\.\..\"<p>\"([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"You need only ask yourself, who among these people is so ruled by fear that they would take the life of another in order to prolong their own existence, miserable though it may be.\"", "<p>\"...Just answer the question, please.\"<p>\"([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Who in this house is hungrier for elevation from their miserable station than", "\"Who in this house is hungrier for elevation from their miserable station than ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("I've never encountered a more obvious criminal.\"", "\"Well, that's very astute of you, Detective. In my view, it must have been ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("A prime specimen of the criminal underclass.\"", "\"Who could it possibly have been except ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Well, that's a rum go. I hadn't even considered the question. I suppose it must've been", "\"Well, that's a rum go. I hadn't even considered the question. I suppose it must've been ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"...We're pretty sure it was someone in this house,\" you say.<p>\"Oh! Well, it was", "<p>\"Oh! Well, it was ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Not quite cricket, you know. ...Then again, neither is murder, what. Very well, you've forced my hand. It was ", "\"Not quite cricket, you know. ...Then again, neither is murder, what. Very well, you've forced my hand. It was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Okay, well, you didn't hear this from me, right dude. But it was", "But it was ([^\.]*)\. Don't ask me how I know, but like, scout's honor.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Aw jeez, man. I can't be havin' people think I'm the sorta dude who talks to cops, you know. But, okay, it was", "But, okay, it was ([^\.]*)\. Just, like, keep it on the down-low, right.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"You wanna know who did it, dude. I know for sure who did it. It was", "It was ([^\.]*)\. No question.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"My life wouldn't be worth a plugged nickel if the wrong people found out I told you this. But it was", "But it was ([^\.]*)\. I can't risk tellin' ya any more than that.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Ain't every day a police detective asks my opinion on a thing like that! Sorry though, I just don't know what to tell ya. <i>.cough.", ".cough.([^\*]*).cough.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Ya dragged it out of me. The killer was", "The killer was ([^\.]*)\. And I trust you'll remember how helpful I was to you, if we should ever cross paths again!\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"I don't know a thing! Why are you even asking me. Even if I did know, I certainly wouldn't tell you!\" And then she looks around and whispers, \"It was", "\"It was ([^!]*)!\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"I don't know a thing! Why are you even asking me. Even if I did know, I certainly wouldn't tell you!\" And then he looks around and whispers, \"It was", "\"It was ([^!]*)!\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\", shows it to you, then stuffs it in her mouth and swallows it.", "writes the name \"([^\"]*)\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\", shows it to you, then stuffs it in his mouth and swallows it.", "writes the name \"([^\"]*)\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("<p>\"Of course I know! They don't get anything past me! It was", "<p>\"Of course I know! They don't get anything past me! It was ([^!]*)!\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"I mean, I haven't quite finished my poem yet, and I wouldn't like to spoil the dramatic reveal for you, but I could read you what I have so far and...\"<p>\"Just the name, please.\"<p>\"It was", "\"It was ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"but I'm having trouble with that part anyway. What's a good rhyme for '", "\"but I'm having trouble with that part anyway. What's a good rhyme for '([^']*)'", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"I suppose it does make for a more satisfying conclusion to my poem if you actually apprehend the criminal. Very well, it was", "\"I suppose it does make for a more satisfying conclusion to my poem if you actually apprehend the criminal. Very well, it was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Yeah, fine, okay. You wanna know who did it. It was", "It was ([^\.]*)\. You happy now.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"but I am sick to death of sitting around here. So I'll tell you: it was", "\"but I am sick to death of sitting around here. So I'll tell you: it was ([^\.]*)\. Can I friggin' go now\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"Well, since you ask so friggin' nice and all -- it was", "\"Well, since you ask so friggin' nice and all -- it was ([^\.]*)\. Whaddya think of that.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("says. \"Nothing gets past <i>these</i> muscles!\"<p>\"I... don't know what that means, but who.\" you ask. <p>", "<p>\"([^\.]*)\. Can you believe it. A skinny twig like that.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("And if I wasn't so busy with Arm Day, I'd wring that scrawny neck myself.\"", "says. I know who it was. It was ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_killer.listAppend(CoreTextMatcherMake("\"If you're asking me, then you must recognize my power!\"<p>\"I... what.\"<p>\"It was", "<p>\"It was ([^\.]*)\. As plain as these sick pecs!\"", CORE_TEXT_MATCH_TYPE_NAME));
	
	
	
	
	
	
	
	//	([^\.]*)\.
	//	([^,]*),
	//	([^\\?]*)\\?
	
	
	//By name:
	//This may give us information, but maybe not - FIXME check
	//shifty, bertie, and paranoid give no information responses.
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Don't care much for her, though. She's up to something shifty, if you ask me.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION)); //shifty
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Don't care much for him, though. He's up to something shifty, if you ask me.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION)); //shifty
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Why, I could tell you some real stories, Detective!\"<p>\"That won't be necessary,\" you say. <p>\"Just as well. I'd forgotten you were a policeman for a moment.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION)); //bertie
	
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("For all I know, that's a lizard underneath that human skin.\"", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION)); //paranoid
	
	
	
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Or once you follow her around for a while, peeking out from behind lampposts and stuff.", "That's ([^!]*)!", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Or once you follow him around for a while, peeking out from behind lampposts and stuff.", "That's ([^!]*)!", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("She is pretty friendly. I haven't found anything to tie her to the scene of the crime yet", "<p>\"She's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("He is pretty friendly. I haven't found anything to tie him to the scene of the crime yet", "<p>\"He's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("She's way at the bottom of my suspects list, though.", "says. \"She's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("He's way at the bottom of my suspects list, though.", "says. \"He's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Quite a polite and good-natured", "<p>\"Ah yes, ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Yes, our interactions have been pleasant, though I have little reason to speak with", "<p>\"You're referring to ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"A perfectly charming woman, despite her upbringing.\"", "<p>\"Yes, Detective, that is ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"A perfectly charming man, despite his upbringing.\"", "<p>\"Yes, Detective, that is ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I don't think I know anyone by that name... oh, are you referring to", "oh, are you referring to ([^\.]*)\. Ha ha, no, I do not associate with", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Ah, you're referring to that creature that ", "refers to as her ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Ah, you're referring to that creature that ", "refers to as his ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("is utterly beneath my notice, Detective. I have nothing whatsoever to say about that", "snorts derisively. \"(.*) is utterly beneath my notice,", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"He's a real straight-shooter. Real trustworthy.\"", "\"Oh sure, ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"She's a real straight-shooter. Real trustworthy.\"", "\"Oh sure, ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("good people. Dependable, you know.\"", "<p>\"Yeah, that's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Ever since she first became", "\"Ever since she first became ([^\.]*)\. Practically inseparable, her and me.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Ever since he first became", "\"Ever since he first became ([^\.]*)\. Practically inseparable, him and me.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Don't care much for him. He's a crook, if you ask me.\"", "<p>\"Yeah, that's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Don't care much for her. She's a crook, if you ask me.\"", "<p>\"Yeah, that's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I know <i>of</i> him, but that's about it. We ain't what you'd call 'chummy'.\"", "<p>\"Oh, you mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I know <i>of</i> her, but that's about it. We ain't what you'd call 'chummy'.\"", "<p>\"Oh, you mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I trust that man about as far as I can throw him.\"", "That's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I trust that woman about as far as I can throw her.\"", "That's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("you know. Very polite and appreciative of my work, though I fear most of it goes over", "\"We get along quite well. She's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("you know. Very polite and appreciative of my work, though I fear most of it goes over", "\"We get along quite well. He's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("has essentially no understanding of the poetic form, poor soul, but", "\"(.*) and I have a very cordial relationship,\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"We get along reasonably well, though he hasn't the artistic education of a raccoon.\"", "\"You're referring to ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"We get along reasonably well, though she hasn't the artistic education of a raccoon.\"", "\"You're referring to ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("No, that feeble-minded blowhard and I have little in common, Detective. Well,", "eyes dramatically. \"The ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Doesn't like your poetry, eh.\"<p>", "<p>\"He's ([^,]*), and an absolute philistine,\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Doesn't like your poetry, eh.\"<p>", "<p>\"She's ([^,]*), and an absolute philistine,\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("No, I have no time for a person with such reprehensible ignorance of the fine arts.", "\"Oh -- you mean ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I mean, kinda. We don't, like, hang. Real unchill woman. I think she's", "I think she's (.*) or something.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I mean, kinda. We don't, like, hang. Real unchill man. I think he's", "I think he's (.*) or something.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Like a primo buzzkill.\"<p>\"I need something more concrete than that.\"<p>\"Right, right. Umm... I think", "Umm... I think she's (.*)\. Can't tell ya much more than that, man.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Like a primo buzzkill.\"<p>\"I need something more concrete than that.\"<p>\"Right, right. Umm... I think", "Umm... I think he's (.*)\. Can't tell ya much more than that, man.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I've run into her a couplea times. She's a real bummer, though. Like, zero fun.\"", "\"Yeah man. That's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I've run into him a couplea times. He's a real bummer, though. Like, zero fun.\"", "\"Yeah man. That's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("great. Funny as hell. But, like, deep, you know.\"", "\"Oh, that's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Like, maybe you wouldn't think it to meet him, but like deep down, you know. He's good people.\"", "\"Oh, uhh... Well, he's ([^,]*), does that help.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Like, maybe you wouldn't think it to meet her, but like deep down, you know. She's good people.\"", "\"Oh, uhh... Well, she's ([^,]*), does that help.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We don't get to hang out much, but he's fun.\"", "\"He's cool, he's a real bro. He's, like, (.*) and stuff.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We don't get to hang out much, but she's fun.\"", "\"She's cool, she's a real bro. She's, like, (.*) and stuff.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\".<p>\"Is there anything else you can tell me.\"<p>Silence.", "nods slightly. \"([^\"]*)\".<p>", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We get along.\"<p>\"Is that all.\"<p>\"That's all.\"", "shrugs. \"([^\.]*)\. We get along.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Okay. Anything else.\"<p>\"He doesn't disturb me while I'm reading.\"", "<p>\"([^,]*),\" comes the murmured reply.<p>", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Okay. Anything else.\"<p>\"She doesn't disturb me while I'm reading.\"", "<p>\"([^,]*),\" comes the murmured reply.<p>", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Well, here's what I have to say about that particular bounder, Detective: Hmph! And furthermore, tut!\"", "p>\"Great Scott, do you mean Old ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake(", you know -- and a boor, and a bore, and a bounder to boot!\"", "\"He's ([^,]*), you know -- and a boor, and a bore,", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake(", you know -- and a boor, and a bore, and a bounder to boot!\"", "\"She's ([^,]*), you know -- and a boor, and a bore,", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Hah! No, Detective -- you'd need to pay me a fair penny just to stand behind", "\"Hmm and also hmm. Oh, steady on, do you mean Old ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Hmm. Oh, I don't speak a word of Greek. Something about columns, I expect.\"", "\"Marvelous man, just brilliant. He's ([^,]*), did you know that.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Hmm. Oh, I don't speak a word of Greek. Something about columns, I expect.\"", "\"Marvelous woman, just brilliant. She's ([^,]*), did you know that.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("says. \"Did you know he's", "\"Did you know he's ([^\.]*)\. I was flabbergasted when I found out!\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("says. \"Did you know she's", "\"Did you know she's ([^\.]*)\. I was flabbergasted when I found out!\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We don't talk much, but I'm pretty sure she's not part of The Conspiracy.", "\"She's ([^\.]*)\. We don't talk much,", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We don't talk much, but I'm pretty sure he's not part of The Conspiracy.", "\"He's ([^\.]*)\. We don't talk much,", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"She's okay, I think. If she's an agent, they haven't activated her yet. But if they do, I'll know.\"", "<p>\"You mean ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"He's okay, I think. If he's an agent, they haven't activated him yet. But if they do, I'll know.\"", "<p>\"You mean ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("actively dangerous. At least, I haven't seen anything to indicate it yet. But I'm watching.\"", "<p>\"([^\.]*)\. Well, I don't trust", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("if you paid me. Not even in gold. Or bitcoins.\"", "creepy (.*) if you paid me.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("is an excellent thinker. Our topics of interest are largely dissimilar, but one must expose oneself to new things, or else stagnate and die.\"", "<p>\"You are referring to ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("is very brave, and fearlessness is the primary requirement for a human being to control", "<p>\"This is ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"An excellent mind. Very imaginative. Imagination is very important, Detective, for it is one of the few advantages than a human has over an animal.\"", "<p>\"Ah yes. ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("of small mind, with no dreams or imagination.", "<p>\"You are referring to ([^,]*), I believe,\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("says, \"and I wish that you would not.\"", "<p>\"You are speaking of ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"If such a title continues to have any significance after this day's events.", "<p>\"This is the name of ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("has a pretty good motive for the murder, what with the life insurance and all!\"", "says. \"That's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<i>real</i> suspicious! Did you know", "\"That's ([^,]*), and", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("has a lot of gambling debts to some very dangerous people!\"", ", \"I know a bunch of stuff about her! She's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("has a lot of gambling debts to some very dangerous people!\"", ", \"I know a bunch of stuff about him! He's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"An ass.\"<p>\"Okay. Can you tell me anything more... concrete.\"<p>", "\"([^\.]*)\. Garbage.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Anything else you can tell me.\"<p>\"Hmph.\"", "scowls. \"The ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("frowns. \"Wish I didn't know her.", "frowns. \"Wish I didn't know her. ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("frowns. \"Wish I didn't know him.", "frowns. \"Wish I didn't know him. ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We don't have much in common, but we get along pretty well", "<p>\"He's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We don't have much in common, but we get along pretty well", "<p>\"She's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"We swap training tips all the time. Well, I tell", "<p>\"Oh sure, that's ([^,]*), I know", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("across the room, heh heh. Oh, don't give me that look,", "\"That's ([^\.]*)\. I challenged", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("-- a skinny little sneak. I trust", "grunts. \"That's (.*) -- a skinny little sneak. I trust", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I've got no use for that scrawny runt of a", "\"I've got no use for that scrawny runt of a ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I've got no use for that scrawny runt of a", "\"I've got no use for that scrawny runt of an ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Pathetic. All talk and no fight.\"", "<p>\"Yeah, I know that wimp. That's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake(", and that's all I wanna know about that jerk.\"", "All I know is she's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake(", and that's all I wanna know about that jerk.\"", "All I know is he's ([^,]*),", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("that's all I know. I wouldn't trust that sack of crap with my life.\"", "<p>\"You mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I ain't got a single good word to say about that sleazy friggin' weasel.\"", ", that's ([^\.]*)\. I ain't got a single good", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("one of the most suspicious of the bunch! I've seen the way", "\"([^\.]*)\. He's one of the most suspicious of the bunch!", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("one of the most suspicious of the bunch! I've seen the way", "\"([^\.]*)\. She's one of the most suspicious of the bunch!", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Or was, I guess. He's okay. I never had any trouble with him.\"", "He's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Or was, I guess. She's okay. I never had any trouble with her.\"", "She's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("He's cool, he's a good person. Don't you be hasslin' him!\"", "([^\.]*)\. He's cool, he's a good person.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("She's cool, she's a good person. Don't you be hasslin' her!\"", "([^\.]*)\. She's cool, she's a good person.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake(", right. He's cool, I got no beef with him.\"", "You mean ([^,]*), right.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake(", right. She's cool, I got no beef with her.\"", "You mean ([^,]*), right.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("get less verbal abuse from her than from the others. Which is nice of her.\"", "\"She's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("get less verbal abuse from him than from the others. Which is nice of him.\"", "\"He's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("She actually does what she's supposed to, instead of expecting me to do it. That's worth a lot in my book. Well, a little.\"", "\"She's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("He actually does what he's supposed to, instead of expecting me to do it. That's worth a lot in my book. Well, a little.\"", "\"He's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Err... do the others.\" you ask.<p>\"Well, no. But they'd like to. I can tell.\"", "<p>\"That's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Not that you'd know it. I'm the one who does all the work around here. But do I get any thanks. No, of course not. Just the blame.\"", "\"Yeah, that's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("He's horrible. At least he's horrible to me. Now that I think about it, in that respect he's no different from anyone else, really.\"", "\"He's ([^\.]*)\. He's horrible.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("She's horrible. At least she's horrible to me. Now that I think about it, in that respect she's no different from anyone else, really.\"", "\"She's ([^\.]*)\. She's horrible.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("got stuck with a (.*) like me, either. Unlucky, I suppose.\"", "got stuck with a (.*) like him.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("got stuck with a (.*) like me, either. Unlucky, I suppose.\"", "got stuck with a (.*) like her.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("got stuck with an (.*) like me, either. Unlucky, I suppose.\"", "got stuck with an (.*) like him.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("got stuck with an (.*) like me, either. Unlucky, I suppose.\"", "got stuck with an (.*) like her.", CORE_TEXT_MATCH_TYPE_OCCUPATION));
	
	
	
	
	//	([^\.]*)\.
	//	([^,]*),
	//	([^\\?]*)\\?
	
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Well jeez, Detective! Have you <i>met</i> her. She <i>super</i>-suspicious!", "Go to (.*) and see for yourself!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Well jeez, Detective! Have you <i>met</i> him. He <i>super</i>-suspicious!", "Go to (.*) and see for yourself!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I bet the FBI has a rap sheet on him a mile long! Maybe Interpol too!", "Oh, he's in (.*) --", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I bet the FBI has a rap sheet on her a mile long! Maybe Interpol too!", "Oh, she's in (.*) --", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("But you can tell just by looking at her that she has <i>tons</i> of underworld connections!", "in the (.*) right now, I could be the Bad Cop for", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("But you can tell just by looking at him that he has <i>tons</i> of underworld connections!", "in the (.*) right now, I could be the Bad Cop for", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"I have nothing in particular to say about that", "\"We have little occasion to interact. I believe she is in the (.*) at present\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"I have nothing in particular to say about that", "\"We have little occasion to interact. I believe he is in the (.*) at present\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("and I do not interact in any significant way,\"", "\"but she seems fairly respectable. If you wish to know more, I can only recommend you go to the (.*) and ask", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("and I do not interact in any significant way,\"", "\"but he seems fairly respectable. If you wish to know more, I can only recommend you go to the (.*) and ask", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Our relationship is perfectly cordial, though I don't have much else to say about her. She is in the", "She is in the ([^,]*), if you require more information than that\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Our relationship is perfectly cordial, though I don't have much else to say about him. He is in the", "He is in the ([^,]*), if you require more information than that\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Other than that, I have absolutely nothing to say about", "\"That... <i>guttersnipe</i> can be found in the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I do not associate with people of such low breeding and reprehensible moral character, Detective,\"", "\"You may speak to her yourself, if you wish -- she's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I do not associate with people of such low breeding and reprehensible moral character, Detective,\"", "\"You may speak to him yourself, if you wish -- he's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I don't know why you would take an interest in that rude little nobody, Detective. If you wish to lower yourself even further by actually speaking with", "is in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"We don't pal around -- she's not really my cup of tea. She's in the", "\"We don't pal around -- she's not really my cup of tea. She's in the ([^,]*), though, if you wanna meet her yourself.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"We don't pal around -- he's not really my cup of tea. He's in the", "\"We don't pal around -- he's not really my cup of tea. He's in the ([^,]*), though, if you wanna meet him yourself.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("If she says anything about me, though, it's a total lie.\"", "\"She's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("If he says anything about me, though, it's a total lie.\"", "\"He's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("'s great, just great,\"", "\"Go check out the ([^,]*), that's where", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"That man's a real peach. He's over in the", "\"That man's a real peach. He's over in the (.*) -- tell him I said hi.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"That woman's a real peach. She's over in the", "\"That woman's a real peach. She's over in the (.*) -- tell her I said hi.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Two peas in a pod, that's us. He'll be in the", "\"Two peas in a pod, that's us. He'll be in the ([^,]*), tell him I sent ya\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Two peas in a pod, that's us. She'll be in the", "\"Two peas in a pod, that's us. She'll be in the ([^,]*), tell her I sent ya\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"He is always asking me to read him my poems. I mean, I'm sure he would, if he wasn't always in such a rush, poor dear. You might find him in the ", "You might find him in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"She is always asking me to read her my poems. I mean, I'm sure she would, if she wasn't always in such a rush, poor dear. You might find her in the ", "You might find her in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"In fact, he once told me his favorite poem was one of mine.\"", "\"Very well! He's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"In fact, she once told me her favorite poem was one of mine.\"", "\"Very well! She's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We're quite companionable. He's quite an attentive and astute listener. He's in the", "\"We're quite companionable. He's quite an attentive and astute listener. He's in the (.*) -- I'm positive that if you ask him, he'll tell you all about how he loves my work.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("We're quite companionable. She's quite an attentive and astute listener. She's in the", "\"We're quite companionable. She's quite an attentive and astute listener. She's in the (.*) -- I'm positive that if you ask her, she'll tell you all about how she loves my work.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I refuse to speak to -- or of -- that savage.", "in the ([^,]*), if you wish to see what the modern educational system does to a person.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake(", there would be no art in this world but what might be found upon a television screen. You'll find", "in the ([^,]*), if you wish to behold such a monster for yourself.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("and that is all I have to say about a person who thinks any poem longer than a limerick is 'boring as hell', endquote.\"", "can be found in the ([^,]*), Detective,", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"He seemed like real bad news to me. He's in the", "He's in the (.*) if you're looking for him.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"She seemed like real bad news to me. She's in the", "She's in the (.*) if you're looking for her.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Except he's a total control freak buzzkill. Like, he's in the", "Like, he's in the (.*), so like, just check out that scene for yourself and you'll see.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Except she's a total control freak buzzkill. Like, she's in the", "Like, she's in the (.*), so like, just check out that scene for yourself and you'll see.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"But no. Not like <i>know</i>-know, y'know. We aren't, like, friends. He's pretty uncool, if you ask me. Real drag. He's probably in the", "He's probably in the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"But no. Not like <i>know</i>-know, y'know. We aren't, like, friends. She's pretty uncool, if you ask me. Real drag. She's probably in the", "She's probably in the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Oh man, all I know about him is that he's like the coolest! He's wild as hell, go check out the", "go check out the (.*) and see for yourself!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Oh man, all I know about her is that she's like the coolest! She's wild as hell, go check out the", "go check out the (.*) and see for yourself!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"He's a solid bro. He'll be in the", "in the (.*), that's where he hangs out. Tell him I said hey.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"She's a solid bro. She'll be in the", "in the (.*), that's where she hangs out. Tell her I said hey.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"He's like, crazy cool. He's a real trip. He's in the", "in the (.*), give him a high-five for me.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"She's like, crazy cool. She's a real trip. She's in the", "in the (.*), give her a high-five for me.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I would be delighted to get any kind of information at all out of you.\"", "<p>\"She's in the (.*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I would be delighted to get any kind of information at all out of you.\"", "<p>\"He's in the (.*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("sniffs disdainfully. \"", "sniffs disdainfully. \"([^\.]*)\.\"<p>\"...Anything else.\"<p>\"She's a jerk.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("sniffs disdainfully. \"", "sniffs disdainfully. \"([^\.]*)\.\"<p>\"...Anything else.\"<p>\"He's a jerk.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Good lord. Don't wear yourself out, saying that many words all at once.\"", "\"and she's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Good lord. Don't wear yourself out, saying that many words all at once.\"", "\"and he's in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("head. \"Don't know him well.", "He's in the ([^,]*), I think.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("head. \"Don't know her well.", "She's in the ([^,]*), I think.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Seen him around. That's all.\"<p>\"Where.\"<p>\"In the", "\"In the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"Seen her around. That's all.\"<p>\"Where.\"<p>\"In the", "\"In the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("shrugs.<p>\"Nothing at all.\"<p>\"He's in the", "in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("shrugs.<p>\"Nothing at all.\"<p>\"She's in the", "in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"if you'll excuse the 'bloody'. Could set your hat alight with a glare,", "in the (.*), go see for yourself!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"That twitching nose, those beady little eyes... Go have a look in the", "Go have a look in the (.*), Detective -- you'll find the resemblance positively uncanny!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Well, there's nothing like a good friend, Detective,\"", "\"and that creature currently residing within the (.*) is nothing like a good friend!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"All the way back! Practically <i>antediluvian</i>,", "If you see him in the ([^,]*), give him a 'What-ho!' from me, won't you.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"All the way back! Practically <i>antediluvian</i>,", "If you see her in the ([^,]*), give her a 'What-ho!' from me, won't you.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("A pollen purveyor's leg-hinges! A... Well, I can't think of another one.", "in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Well, two pints. One for each of you. Hah! Drinking the same pint, that'd be ridiculous! When you see", "in the ([^,]*), tell", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("has it all wired up with recording devices.", "\"I don't even go near the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"and you will too, if you know what's good for you. Just keep out of the", "\"and you will too, if you know what's good for you. Just keep out of the ([^!]*)", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I don't want anything to do with that tool of the Illuminati,\"", "in the (.*) if you want, but you better wear something metallic on your head.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"At least, I've seen no overt indications that", "been sent to get me. You'd better go to the (.*) and check", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"At least I don't think so. Not right now. Everyone's got their price, though. Everyone can be bought.", "in the (.*), go check", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Maybe. I'm not sure, though. I can't be certain. I can't ever be certain. Always gotta be watching.", "in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("did the murder. At least, I haven't found any evidence to suggest it yet!\"", "in the (.*) right now,\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("chewing gum with you, if you ask!\"", "in the (.*) right now.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("did it, but it's dangerous to make assumptions before you have all the facts. That's like the first rule of detectiveing!\"", "in the ([^\.]*)\. I don't think", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("outlook on life is, in many ways, quite refreshing.\"", "\"Presently, she is in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("outlook on life is, in many ways, quite refreshing.\"", "\"Presently, he is in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"We are cordial with one another, but speak little. It is refreshing to know someone who does not insist on small talk at every encounter.\"", "is in the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Detective. We have participated in friendly debate on occasion.", "\"You will find her in the ([^,]*), Detective.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("Detective. We have participated in friendly debate on occasion.", "\"You will find him in the ([^,]*), Detective.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Refusing to accept responsibility for", "<p>\"You will find this woman in the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Refusing to accept responsibility for", "<p>\"You will find this man in the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Perhaps you will discover a use for her where I have not.\"", "<p>\"She is in the (.*) at the moment,\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Perhaps you will discover a use for him where I have not.\"", "<p>\"He is in the (.*) at the moment,\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I must warn you, Detective, that she has little regard for the truth.\"", "<p>\"Mmm. You will find her in the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I must warn you, Detective, that he has little regard for the truth.\"", "<p>\"Mmm. You will find him in the ([^,]*),", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Never complains when I accidentally break one of the flimsy little chairs they've got around here.", "be in the ([^,]*), if you're looking for", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"A bit scrawny, but a real go-getter. Smart as a whip, too, always helps me out with the math when I'm counting calories.", "usually in the ([^,]*), you can find", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("beats me at chess, and then I beat", "in the (.*) if you want to meet", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("<p>\"I could break that punk in half with my pinky fingers,\"", "in the ([^,]*), go see for yourself what a weakling", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("If you wanna meet the world's biggest wimp, just go to the", "just go to the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("if a stiff breeze hasn't carried", "\"You'll find her in the ([^,]*), if a stiff breeze hasn't carried her away, hah!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("if a stiff breeze hasn't carried", "\"You'll find him in the ([^,]*), if a stiff breeze hasn't carried him away, hah!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("You think I'm gonna help you pin this on one of my friends, think again, cop!", "She's in the ([^,]*), you can go talk to her yourself!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("You think I'm gonna help you pin this on one of my friends, think again, cop!", "He's in the ([^,]*), you can go talk to him yourself!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("is my friend, and I don't talk to cops about my friends. Haul your cop ass to the", "Haul your cop ass to the (.*) and ask", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("But that's all I'm gonna say to a cop.\"", "I think she's over in the ([^\.]*)\. But that's", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("But that's all I'm gonna say to a cop.\"", "I think he's over in the ([^\.]*)\. But that's", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("cigarette out on the floor. \"If you wanna know about", "go to the (.*) and ask her yourself. I don't want anything to do with her.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("cigarette out on the floor. \"If you wanna know about", "go to the (.*) and ask him yourself. I don't want anything to do with him.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I can tell you that piece of crap is stinking up the", "<p>\"I can tell you that piece of crap is stinking up the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I can't stand the sight of that slimy worm. I think", "I think she's in the ([^\.]*)\. Go see for yourself what a piece of crap", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("I can't stand the sight of that slimy worm. I think", "I think he's in the ([^\.]*)\. Go see for yourself what a piece of crap", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("doesn't immediately blame me when things go wrong around here. As they inevitably do. And as everyone else inevitably does.\"", "in the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("someone could have a nice conversation with. Someone other than me.\"", "be in the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Which is okay. I don't expect him to take any interest in me. Why should he, I'm just the only one who does any work around here, after all. He's probably in the", "He's probably in the ([^,]*), having a grand old time.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"Which is okay. I don't expect her to take any interest in me. Why should she, I'm just the only one who does any work around here, after all. She's probably in the", "She's probably in the ([^,]*), having a grand old time.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("much either. Or myself, come to think of it. So we've got that much in common, at least.\"", "'s in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("That's where I'd be, if I was here and I wanted to avoid me.\"", "'s probably in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I bet she'll tell you she doesn't know me, though. Probably considers me beneath her notice. Go on and ask her, you'll see. She's in the", "She's in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"I bet he'll tell you he doesn't know me, though. Probably considers me beneath his notice. Go on and ask him, you'll see. He's in the", "He's in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("seems fairly respectable. If you wish to know more, I can only recommend you go to", "I can only recommend you go to the (.*) and ask", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_name.listAppend(CoreTextMatcherMake("\"We have little occasion to interact. I believe", "is in the (.*) at present.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	
	
	
	
	
	
	//	([^\.]*)\.
	//	([^,]*),
	//	([^\\?]*)\\?
	
	
	
	
	
	
	
	
	
	//By occupation:
	//Jock and nancydrew have bugged/no information responses by occupation
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("all words and hot air. No muscle, no backbone.", "", CORE_TEXT_MATCH_TYPE_NO_INFORMATION)); //This does actually give information - on gender - but we don't track that information //jock
	
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("creeps me out. There's something real fishy about", "", CORE_TEXT_MATCH_TYPE_BUGGED)); //\"Can you tell me anything about Madelyn Wilson's physician.\" you ask.<p>\"Gross. Yeah,\" Nicky says. \"That's the victim's physician. He creeps me out. There's something real fishy about him, Detective!\" //nancydrew
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I'm pretty sure he's hiding something, but I guess that doesn't necessarily make him the killer. Lots of people around here have stuff they wanna keep secret.\"", "", CORE_TEXT_MATCH_TYPE_BUGGED)); //nancydrew
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I'm pretty sure she's hiding something, but I guess that doesn't necessarily make her the killer. Lots of people around here have stuff they wanna keep secret.\"", "", CORE_TEXT_MATCH_TYPE_BUGGED)); //nancydrew
	
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("As pleasant a luncheon companion as I've had, at least from the lower strata of society.\"", "says. \"([^\.]*)\. As pleasant a luncheon companion as I've had,", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Utterly unsuited to the upper-class lifestyle, of course.\"", "name is ([^\.]*)\. Charming", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"She's delightful -- wonderful sense of humor. What a shame she'll never amount to anything.\"", "<p>\"([^\.]*)\. Why yes,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"He's delightful -- wonderful sense of humor. What a shame he'll never amount to anything.\"", "<p>\"([^\.]*)\. Why yes,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("eally suffered from the most appalling luck, to be stuck with", "such as ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"That loathsome little insect of a", "\"I presume you are asking about ([^,]*),\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("demands. \"I didn't, but your request is noted,\" you reply.", "<p>\"Ugh! Do not even breathe the name (.*) in my presence, Detective!\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake(". I don't recommend you waste your time with her though, Detective. That ain't gonna be a, whaddyacallit -- a profitable endeavor.\"", "\"Her name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake(". I don't recommend you waste your time with him though, Detective. That ain't gonna be a, whaddyacallit -- a profitable endeavor.\"", "\"His name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("head. \"Yeah, no. I don't need the stress, know what I mean.\"", "... Oh. You mean ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Know her like a kick in the teeth. Got about as much need for her, too.\"", "\"Yeah, I know ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Know him like a kick in the teeth. Got about as much need for him, too.\"", "\"Yeah, I know ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Heck, we're such good pals I practically forgot", "mutters. \"...Oh! You mean ([^!]*)!", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("great, a real riot. You need someone to watch your back, that's who you need, is", "<p>\"D'you mean ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake(", we go way back. Waaay back. Can't say enough good things about", "<p>\"Oh sure, that's ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("doesn't know very much about poetry, I'm afraid, but I'm doing my best to educate", "<p>\"Are you referring to ([^\\?]*)\\?\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"No, thank you.\"<p>\"It's very clever.\"<p>\"I'm sure it is.\"", "<p>\"Oh yes, (.*) and I get along quite well. Just the other day", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"He never seems to have time to hear my poems, but he always seems so saddened by the fact, I can't help but forgive him.\"", "<p>\"Yes, (.*) and I get along rather well,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"She never seems to have time to hear my poems, but she always seems so saddened by the fact, I can't help but forgive her.\"", "<p>\"Yes, (.*) and I get along rather well,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("is a boorish lout with the literary education of a ham sandwich.\"", "name is ([^,]*), and", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake(" I'm afraid I don't associate with people whose idea of a dictionary has little pictures of superheroes providing examples for each definition.\"", "\"You're referring to ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I might as well attempt to converse with the raccoon that knocks over the trash bins in the evening.\"", "<p>\"Do you mean ([^\.]*)\. Bah,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I'm not real into him. He's a real buzzkill, you know.\"", "\"His name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I'm not real into her. She's a real buzzkill, you know.\"", "\"Her name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("comes in the room, I'm, like, <i>gone</i>. Like 'No thank you,' right. Who needs that kind of drama.\"", "\"Him. ([^\.]*)\. Phew,", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("comes in the room, I'm, like, <i>gone</i>. Like 'No thank you,' right. Who needs that kind of drama.\"", "\"Her. ([^\.]*)\. Phew,", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("well enough to say hey to. And then get the hell out of Dodge because dang, man, right.\"", "<p>\"You mean ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Yeah dude! He's a riot! He's like, way cool. Real party animal, know what I mean.\"", "<p>\"You mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Yeah dude! She's a riot! She's like, way cool. Real party animal, know what I mean.\"", "<p>\"You mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Plays a mean hackey-sack, you know. You wouldn't expect that, but like, wow.\"", "<p>\"Oh, that's ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I dunno, like, we don't hang out a lot, right, but he's pretty cool. Real casual.\"", "<p>\"Umm... oh, you mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I dunno, like, we don't hang out a lot, right, but she's pretty cool. Real casual.\"", "<p>\"Umm... oh, you mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"...That's it, huh.\"<p>\"Mm-hmm.\"", "<p>\"Name's ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("We don't talk.\"<p>\"Do you actually talk to anyone.\"<p>", "<p>\"([^\.]*)\. We don't talk.\"<p>", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Can you tell me anything at all about her.\"<p>\"She's awful.\"<p>\"...Anything else.\"<p>\"No.\"", "<p>\"Don't really know her. Name's ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Can you tell me anything at all about him.\"<p>\"He's awful.\"<p>\"...Anything else.\"<p>\"No.\"", "<p>\"Don't really know him. Name's ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Can you tell me anything about him.\"<p>Shrug. \"Seemed reasonable enough.\"", "nods. \"([^\.]*)\.\"<p>", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Can you tell me anything about her.\"<p>Shrug. \"Seemed reasonable enough.\"", "nods. \"([^\.]*)\.\"<p>", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("doesn't get on my nerves like some people.\"<p>\"Like who.\"<p>", "<p>\"Know him a little. His name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("doesn't get on my nerves like some people.\"<p>\"Like who.\"<p>", "<p>\"Know her a little. Her name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"...Anything else. Anything at all.\"<p>Shrug.", "<p>\"His name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"...Anything else. Anything at all.\"<p>Shrug.", "<p>\"Her name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("legitimate moniker. ... ...Well, yes, probably. Can't quite imagine someone calling themselves '", "Can't quite imagine someone calling themselves '([^']*)' by choice, can you.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Well! I'm not one to tell tales out of school, but well. Hmph! Yes. Tch! With perhaps a Hoh! and Tsk! for good measure.\"", "p>\"Do you mean ([^,]*), Detective.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Nasty piece of work. Face like a horse. And I shall leave the question of which bit of the horse to your own deductive prowess.\"", "\"That little blighter goes by the name ([^,]*), Detective.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("doesn't know what's going on around here. Maybe that'll keep", "<p>\"Pfft, (.*) is just a dupe, a patsy!\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I'm not one hundred percent on her, but I think she might be okay. I'm keeping my eyes on her.\"", "<p>\"Oh, you mean ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I'm not one hundred percent on him, but I think he might be okay. I'm keeping my eyes on him.\"", "<p>\"Oh, you mean ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("So far she seems to check out fine, but you can't be too careful these days.\"", "name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("So far he seems to check out fine, but you can't be too careful these days.\"", "name's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("She's real nice! ...Wait, you don't think she did the murder, do you.\"", "<p>\"Oh sure, that's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("He's real nice! ...Wait, you don't think he did the murder, do you.\"", "<p>\"Oh sure, that's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I'd be real surprised if she did it, Detective! But I guess you have to cover all the bases in our line of work!\"", "<p>\"Oh, you mean ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I'd be real surprised if he did it, Detective! But I guess you have to cover all the bases in our line of work!\"", "<p>\"Oh, you mean ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("p>\"You should be sitting here quietly without investigate anything,\" you say sternly. <p>\"Aw, gee!\"", "<p>\"Uh-huh, that's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("a real suspicious character, if you ask me! Keep your eyes peeled!\"", "nods. \"That's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("In as much as any two humans, with our limited understanding of the universe filtered by our barely-evolved brains, can be said to truly be friends.\"", "\"Yes, I consider (.*) to be a friend, Detective", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I have found him to be quite companionable, and thoughtful in his opinions.\"", "\"This person's name is ([^,]*), Detective,", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I have found her to be quite companionable, and thoughtful in her opinions.\"", "\"This person's name is ([^,]*), Detective,", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("quite fearless and comfortable with the unknown. I regard these as remarkable qualities.\"", "\"Yes, that is ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I have nothing to recommend of such a cowardly, beady-eyed vole of a human being.\"", "\"I believe you are speaking of ([^,]*), Detective,\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("is a petulant child, demanding candy from a universe that does not listen.\"", "\"You are referring to ([^,]*), I presume", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"My interactions with her have been unpleasant, without exception.\"", "\"This woman you are speaking of, her name is ([^,]*),\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"My interactions with him have been unpleasant, without exception.\"", "\"This man you are speaking of, his name is ([^,]*),\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake(", doesn't bug me when I'm working out, you know.\"", "name's ([^\.]*)\. Seems a decent sort.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Probably couldn't handle the weight of a large phone book, but not everybody has muscles as glorious as mine.\"", "Oh, you mean ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("with the muscles of a... I dunno, one of those bugs that look like sticks, or something.\"", "\"Sure, that's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I don't know anything about her except that she's a real ass and I don't want anything to do with her. Does that help.\"", "\"Yeah, you mean ([^,]*), right", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I don't know anything about him except that he's a real ass and I don't want anything to do with him. Does that help.\"", "\"Yeah, you mean ([^,]*), right", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I haven't got a damn thing to say about that piece of crap.\"", "Oh -- you mean that jerkbag ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("ights a cigarette and thinks for a moment. \"...Oh! You mean", "Oh! You mean ([^\.]*)\. Yeah, I don't give a crap about that", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("pretty cool.\"<p>\"...And.\" you ask.<p>\"And that's all I'm gonna say to a cop, cop!\"", "that's ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("seems okay. That's all I know, though, so choke on it.\"", "called ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Do you mean can't, or won't.\" you ask.<p>\"What I mean is: get bent, cop!\"", "Oh, you mean ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("is even a real human being!\"", "\"Do you mean ([^\\?]*)\\? Ha ha ha, are you kidding.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("mail -- mission orders disguised as innocuous credit-card offers!\"", "<p>\"([^\.]*)\. Stay away from", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("always watching me! Watching and waiting!\"", "name's ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Sure, I know her. I mean, as well as I know anybody, which isn't very well, but she says hello to me sometimes, and that's more than I get from most people.\"", "\"\.\.\.Oh, you mean ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Sure, I know him. I mean, as well as I know anybody, which isn't very well, but he says hello to me sometimes, and that's more than I get from most people.\"", "\"\.\.\.Oh, you mean ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"...I can't tell if you're being sarcastic.\"<p>\"Yeah, me neither,\"", "\"Everyone loves ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Not a long one. And I was doing most of the talking. But still, I guess that counts for a little something.\"", "\"That's ([^,]*),\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("just sits around all day while everyone else does all the work. And by 'everyone else' I mean me.\"", "\"That's ([^\.]*)\. Totally useless.", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Well, if you're expecting me to say anything nice about", "Oh. You're talking about ([^,]*),\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("isn't much of one if you ask me.\"<p>\"I don't think I will.\"", "I'm aware of around here is ([^,]*),", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Now that you mention it, I do seem to remember something about", "No, sorry Detective, I don't know who that is, dash it all\. \.\.\.Oh! Unless you mean ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("seems quite respectable. Stable sort, plenty of atoms up in the old thinkpiece.\"", "\"That's ([^,]*), isn't it.\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("very well, I regret to inform. Seems nice enough.\"", "\"Unless I'm well off the mark, you're referring to ([^,]*),\"", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Dunno what that scrawny little weasel could possibly be good for. I guess if you had some sand, you could kick it in", "says. \"([^,]*), I think", CORE_TEXT_MATCH_TYPE_NAME));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("at least be useful as a barbell, hah!\"", "name's ([^\.]*)\. Totally useless. Maybe if", CORE_TEXT_MATCH_TYPE_NAME));
	
	
	//	([^\.]*)\.
	//	([^,]*),
	//	([^\\?]*)\\?
	
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I believe I've seen them in the mansion from time to time, however. Go look in the", "Go look in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I've seen them around, of course, but I certainly didn't take any notice. Perhaps they're in the", "Perhaps they're in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"but I've never really had occasion to speak with them. We travel in entirely different circles. Perhaps you should try the", "Perhaps you should try the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I know of that person, but have never found it necessary to interact with them,\"", "\"I believe they're in the (.*) at the moment.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"I will not lower myself to that person's level by deigning to speak to them,\"", "\"If you wish to know about them, try the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("says, \"I know nothing about them, and nor do I care to.\"", "\"Apart from the fact that they are in the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("muses. \"I think I know who you mean, Detective, but I dunno them real well. I think they're in the", "I think they're in the ([^,]*), though.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("p>\"I know who that is, Detective, but we don't talk much,\"", "\"Try the ([^,]*), they're usually skulking around there.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Nothin' but trouble. Probably hangin' around the", "Probably hangin' around the ([^,]*), if you've got time to waste.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("says, \"but we run into each other from time to time, sure. They're alright. Check in the", "Check in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Not real well, but we've chatted. Charming, real charming type. Probably in the", "Probably in the ([^,]*), if I hadda guess.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("great. I don't know them much more than to say hello to, but I can tell they're a decent sort. Check in the", "Check in the ([^,]*), if you wanna chat.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"that I would almost suspect they were avoiding me deliberately! But I believe you'll find them in the", "But I believe you'll find them in the (.*) at the moment.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("says. \"We don't interact much, as we've very little in common. But you can find them in the", "But you can find them in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Not a poetic bone in that entire body, of course. Such a pity. You might try", "ou might try the ([^,]*), if you've a need to speak with them.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Not until they apologize for comparing my 'Opus", "<p>\"I'll have nothing to do with that savage in the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"I have nothing good to say about that... person,\"", "\"Their presence in the (.*) is lowering the average intelligence of the household by at least thirty points.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"which is why I'm not there myself. One might as well read one's poetry to a pickled eel.\"", "<p>\"That barbarian is currently occupying the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("eyes light up. \"Oh, yeah, dude! I know who you mean. They're cool. Go check out the", "Go check out the ([^,]*), you'll find 'em there.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("That's where I'd look, if I was looking.\"", "says. \"I guess look in the ([^\\?]*)\\?", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("says. \"They're cool, but we're not like bros or anything. Check the", "Check the ([^,]*), maybe.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Man, I got nothing to say about that freak. Try the", "Try the ([^,]*), if you wanna see a real headcase, dude.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("and see for yourself. Hope you got a high tolerance for bummers though, dude.\"", "\"I dunno, maybe like, check out the (.*) and see for yourself", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("when they're there, which is like always, and that's all I need to know, right.\"", "\"I know enough to stay the hell out of the (.*) when they're there, which is like always,", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Any opinion on them.\"<p>Shrug. \"Seems okay.\"", "<p>\"They're in the ([^\.]*)\.\"<p>", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"What do you think of them.\"<p>\"'S'alright.\"", "<p>\"Only know them a little. They're in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("shrugs. \"Try the", "shrugs. \"Try the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("is the very reason I'm in here and not in the", "very reason I'm in here and not in the ([^\.]*)\. Absolutely frightful individual.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("with that person than a snowman could stand to vacation within a fizzing volcano, Detective", "I'm afraid I could no more stand to be in the (.*) with that person than a snowman", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"allow me to say one word: <i>balderdash.</i>\"", "<p>\"As concerns the individual currently occupying the ([^,]*), Detective,\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"If we're thinking of the same person, that is. With the um", "In the ([^\\?]*)\\? Is that the one\\?\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"What was the name... hmm... Began with an S, I believe. Or an R. ...No, it's no good, I'm afraid, old chap. You'll have to go to", "You'll have to go to the (.*) and ask for yourself.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Yes yes, we're quite close.\"<p>\"Do you know their name.\" you ask.<p>\"Haven't the foggiest.\"", "Indubitably, even, if I'm correct in assuming that to be a word. Spends a lot of time in the ([^,]*), don't you know.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I've seen them around, but we never talk. Can't risk my secrets getting out. They'll be in the", "They'll be in the ([^,]*), though. Maybe you'll see something I haven't.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I can't risk talking to people I don't know and trust. They're in", "They're in the ([^,]*), if you think you haven't got anything to lose.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"but I don't know them well. I see them around. No suspicious moves yet, but it's only a matter of time.", "You can find them in the ([^,]*), check them out for yourself.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("says. \"Oh, I know who they <i>claim</i> to be, but that person in the", "but that person in the (.*) isn't who they say they are, you mark my words!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"No! Keep well away from that one!\"", "in the ([^,]*), so stay out of there! Don't risk being subverted by that hypnotic gaze!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"There's no such person!\"", "! Go to the (.*) and ask them for yourself, you'll see!\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"I dunno much of anything about them, Detective,\"", "\"I'm pretty sure they're in the (.*) right now, though.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Sorry, Detective, I barely know them to say hi to.\"", "<p>\"All I know is they're in the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Hmm. I know who that is, but I dunno much of anything about them. Sorry, Detective,\"", "\"They're in the ([^,]*), maybe you can investigate them there.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"They seem nice enough, but I've never really talked to them, Detective,\"", "\"I think they're in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"We've never really talked or anything.\"", "<p>\"They're in the ([^,]*), if I know who you mean, Detective,\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I was trying to figure out who that was, we've never really been introduced.\"", "<p>\"That must be who's in the (.*) right now, Detective,", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Regrettably, I can tell you no more, as we have had no opportunity for conversation. They are in", "hey are in the ([^,]*), I believe.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"That is the impression I have, though we have not conversed at any length.\"", "\"If you seek them out in the ([^,]*), I believe you will find them to be quite reasonable, Detective,", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"I regret that I have had little interaction with this person,\"", "Perhaps, Detective, when you find them in the ([^,]*), you might send my regards.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"and I have resolved not to spend mine upon such a person. But, you must judge for yourself. You will find them in the", "You will find them in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"This is by choice, as I am certain that they have nothing to offer me. Perhaps it will be a different matter for you, in which case you can find them in the", "hich case you can find them in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I have spoken with them on rare occasion, Detective,\"", "\"It was not worth my time. But the (.*) is where you can find them.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"And that's all you're going to say.\"<p>\"Mm-hmm.\"", "<p>\"They're in the ([^\.]*)\.\"<p>", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"No.\"<p>\"Nothing at all.\"<p>\"Try the", "<p>\"Try the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Met them once.\"<p>\"And.\"<p>\"And they're in the", "\"And they're in the (.*) if you want to try it yourself.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Hmm, I know who that is, but don't know much about 'em,\"", "\"I think they'd be in the (.*) at this time of day.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Not real well, but we make smalltalk from time to time. Which is the only kind of talk they could make, hah!", "They're in the (.*) if you wanna see 'em.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"They aren't interested in bodybuilding, and I'm not interested in... whatever.", "Try the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Forget that wimp,\"", "<p>\"Pfft. They'll be in the ([^\.]*)\. That's all I know or care.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Little do they know, my ears are as strong as the rest of me! Heck, I can hear them in", "Heck, I can hear them in the (.*) right now.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Yeah, I know who you mean, but we don't talk. Look in the", "Look in the (.*) if you have questions for them, I guess.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("I ain't gonna even say that piece of crap's name. Go to", "Go to the (.*) and find out for yourself.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Oh, <i>that</i> jerkoff. Go to the", "Go to the (.*) and see for yourself why I wouldn't", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Umm... Yeah, I think I know who you mean, but I can't think of their name. Never cared to know.", "They're probably in the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("Don't know 'em too well, but I guess they're okay.\"", "Oh, umm... I think I know who you mean. In the ([^\.]*)\.", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("<p>\"Okay,\" you say, making a note of it. \"Can you tell me anything about them.\"<p>\"Nah. S'alright, I guess. We don't really interact.\"", "p>\"Hmm, yeah. I think I saw them in the ([^\\?]*)\\?\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Don't know much about 'em. Alright, I suppose. Go find out for yourself -- in the", "-- in the ([^,]*), I think.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"We don't talk much. Well, we don't talk at all. But they've never said anything mean to me. Never said anything to me.\"<p>\"Are you certain this person actually exists.\" you ask.<p>\"Oh", "\"Oh, I've <i>seen</i> them, yeah. In the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"They mostly avoid me. I mean, everyone does, but they're better at it than most. You might find them in the", "You might find them in the ([^\.]*)\.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"I don't have a single unkind word to say about that person,\"", "<p>\"Do you have anything at all to say about them.\"<p>\"No. Well, they're probably in the ([^\.]*)\. Does that count.\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("but I can't think of anyone I'd want to talk to less.\"<p>\"I can,\" you mutter.", "\"Well, if you want to talk to them, they're in the ([^,]*), but I can't think", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Probably leaving cigarette butts everywhere. And who do you think will be expected to clean them up. You're a detective -- go ahead and guess.\"", "\"They're in the ([^,]*),\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	__core_text_matchers_by_occupation.listAppend(CoreTextMatcherMake("\"Though why you would want to do that is beyond me. I'd rather throw myself out of a window. ...Actually, I might do that anyway.\"", "\"You'll find them in the ([^,]*), if you want to talk to them,\"", CORE_TEXT_MATCH_TYPE_LOCATION));
	
	
	
	
	//	([^\.]*)\.
	//	([^,]*),
	//	([^\\?]*)\\?
	
	
	
	
	verifyMatchers(__core_text_matchers_killer);
	verifyMatchers(__core_text_matchers_by_name);
	verifyMatchers(__core_text_matchers_by_occupation);
}

initialiseCoreTextMatchers();

CoreTextMatch parseCoreText(Individual individual_interrogating, string url_to_access, string core_text)
{
	CoreTextMatch match;
	if (!individual_interrogating.exists)
		return match;
		
	//print_html("core_text = " + core_text.replace_string("\"", "\\\"").replace_string("?", ".").entity_encode());
	
	if ((__write_test_data || my_id() == 1557284) && !(__seen_core_text_test_data contains core_text)) //always collect data if you are me
	{
		if (!__disable_output)
			logprint("DETECTIVE_SOLVER_CORE_TEXT __core_text_test_data.listAppend(listMake(\"" + url_to_access + "\", \"" + core_text.replace_string("\"", "\\\"") + "\"));");
		__seen_core_text_test_data[core_text] = true;
	}
	//Try to match:
	if (url_to_access.contains_text("ask=killer"))
	{
		individual_interrogating.asked_about_killer = true;
		match = findCoreTextMatch(core_text, __core_text_matchers_killer);
		if (match.type == CORE_TEXT_MATCH_TYPE_NO_INFORMATION)
		{
			if (__setting_debug && __setting_output_various_debug_text && !__disable_output)
				print_html("No information on killer.");
			individual_interrogating.knows_about_killer = false;
		}
		else if (match.type == CORE_TEXT_MATCH_TYPE_UNKNOWN)
		{
			individual_interrogating.knows_about_killer = false;
			if (!__disable_output)
				print_html("<font color=red>Unknown match on core text for killer.</font> Input text is \"" + core_text.entity_encode() + "\"");
			if (__abort_on_match_failure)
				abort("match failure");
		}
		else if (match.type == CORE_TEXT_MATCH_TYPE_BUGGED)
		{
			if (!__disable_output)
				print_html("Bugged information on killer.");
			individual_interrogating.knows_about_killer = false;
		}
		else if (match.type == CORE_TEXT_MATCH_TYPE_OCCUPATION || match.type == CORE_TEXT_MATCH_TYPE_NAME)
		{
			individual_interrogating.knows_about_killer = true;
			if (match.type == CORE_TEXT_MATCH_TYPE_NAME)
				individual_interrogating.suspects_killer_name = match.match;
			else if (match.type == CORE_TEXT_MATCH_TYPE_OCCUPATION)
				individual_interrogating.suspects_killer_occupation = match.match;
			if (__setting_debug && __setting_output_various_debug_text && !__disable_output)
				print_html("<font color=teal>MATCH on killer: \"" + match.match.entity_encode() + "\"</font>");
		}
		else
		{
			abort("unable to discover");
			if (!__disable_output)
				print_html("<font color=red>Unknown match type for killer.</font> Input text is \"" + core_text.entity_encode() + "\"");
			if (__abort_on_match_failure)
				abort("match failure");
		}
	}
	else if (url_to_access.contains_text("ask="))
	{
		int person_asking_about_by_location_id;
		boolean is_rel_question = false;
		boolean visited_previously = false;
		if (url_to_access.contains_text("ask=rel"))
		{
			match = findCoreTextMatch(core_text, __core_text_matchers_by_occupation);
			is_rel_question = true;
			person_asking_about_by_location_id = url_to_access.group_string("w=([0-9]*)")[0][1].to_int_silent();
			if (individual_interrogating.choices_occupation_we_visited_by_location_id[person_asking_about_by_location_id])
				visited_previously = true;
			individual_interrogating.choices_occupation_we_visited_by_location_id[person_asking_about_by_location_id] = true;
		}
		else
		{
			match = findCoreTextMatch(core_text, __core_text_matchers_by_name);
			person_asking_about_by_location_id = url_to_access.group_string("ask=([0-9]*)")[0][1].to_int_silent();
			if (individual_interrogating.choices_name_we_visited_by_location_id[person_asking_about_by_location_id])
				visited_previously = true;
			individual_interrogating.choices_name_we_visited_by_location_id[person_asking_about_by_location_id] = true;
		}
		//print_html("person_asking_about_by_location_id = " + person_asking_about_by_location_id);
		
		if (match.type == CORE_TEXT_MATCH_TYPE_LOCATION)
		{
			int claim_location_id = __state.location_names_to_ids[match.match];
			
			//assume NO_INFORMATION
			if (claim_location_id == individual_interrogating.location_id && individual_interrogating.location_id > 0) //bug, unreliable?
				match.type = CORE_TEXT_MATCH_TYPE_NO_INFORMATION;
			
		}
		
		if (match.type == CORE_TEXT_MATCH_TYPE_NO_INFORMATION)
		{
			if (__setting_debug && __setting_output_various_debug_text && !__disable_output)
				print_html("No information on question.");
		}
		else if (match.type == CORE_TEXT_MATCH_TYPE_UNKNOWN)
		{
			string question_type = "name question";
			if (url_to_access.contains_text("ask=rel"))
				question_type = "occupation question";
			if (!__disable_output)
				print_html("<font color=red>Unknown match on core text for " + question_type + ".</font> Input text is \"" + core_text.entity_encode() + "\"");
			if (__abort_on_match_failure)
				abort("match failure");
		}
		else if (match.type == CORE_TEXT_MATCH_TYPE_BUGGED)
		{
			if (__setting_debug && __setting_output_various_debug_text && !__disable_output)
				print_html("Bugged match on question.");
		}
		else if (match.type == CORE_TEXT_MATCH_TYPE_OCCUPATION || match.type == CORE_TEXT_MATCH_TYPE_NAME || match.type == CORE_TEXT_MATCH_TYPE_LOCATION)
		{
			if (__setting_debug && __setting_output_various_debug_text && !__disable_output)
				print_html("<font color=teal>MATCH on question: \"" + match.match.entity_encode() + "\"</font>");
			
			//We do this in two steps. First we add claims to the list, then we post-process them later, because sometimes we get incomplete information we can't verify yet.
			InterrogationClaim claim;
			if (is_rel_question)
			{
				claim.type_interrogated_by = CORE_TEXT_MATCH_TYPE_OCCUPATION;
				//individual_interrogating.choices_occupation_we_visited_by_location_id[person_asking_about_by_location_id] = true;
			}
			else
			{
				claim.type_interrogated_by = CORE_TEXT_MATCH_TYPE_NAME;
				//individual_interrogating.choices_name_we_visited_by_location_id[person_asking_about_by_location_id] = true;
			}
			claim.claim_type = match.type;
			claim.claim = match.match;
			claim.person_asking_about_by_location_id = person_asking_about_by_location_id;
			claim.verified = false;
			
			if (!visited_previously)
				individual_interrogating.interrogation_claims.listAppend(claim);
			
			
		}
		else
		{
			if (!__disable_output)
				print_html("<font color=red>Unknown match type for question.</font> Input text is \"" + core_text.entity_encode() + "\"");
			if (__abort_on_match_failure)
				abort("match failure");
		}
		//A question? Do something about it.		
		//wham.php?ask=rel&w=4&visit=2 - relation of the victim (occupation)
		//or
		//wham.php?ask=1&visit=2 - person (by name)
	}
	return match;
}

void parseCoreTextFromPageText(Individual individual_interrogating, string url_to_access, string page_text)
{
	//string [int][int] matches = group_string(page_text.replace_string("\r", "").replace_string("\n", "").replace_string("\t", ""), "<!-- <div [^>]*> -->(.*)<!-- </div> -->");
	string [int][int] matches = group_string(page_text.replace_string("\r", "").replace_string("\n", "").replace_string("\t", ""), "<td colspan=2 width=500>(.*)<!-- </div> -->");
	//<!-- <div style="width: 460px; height: 110px; padding: 20px; position: relative; text-align: center; " > --> Click a room on the map to move to that room <!-- </div> -->
	//print_html("parseCoreText matches = " + matches.to_json().entity_encode());
	if (matches.count() == 0)
	{
		//future proof against CDM noticing the other div disappearing:
		matches = group_string(page_text.replace_string("\r", "").replace_string("\n", "").replace_string("\t", ""), "<td colspan=2 width=500>(.*)</td>");
	}
	
	if (matches.count() == 0)
		return;
	
	string core_text = matches[0][1];
	parseCoreText(individual_interrogating, url_to_access, core_text);
}





void parseMinutes(string page_text)
{
	string [int][int] matches = page_text.group_string("<td align=left>You have been on this case for ([0-9]*) minutes</td>");
	if (matches.count() == 0)
		return;
		
	boolean first_minutes_elapsed = false;
	
	if (__state.minutes_elapsed <= 0)
		first_minutes_elapsed = true;
	__state.minutes_elapsed = matches[0][1].to_int();
	if (first_minutes_elapsed && !__extended_time_limit_previously)
	{
		//Temporarily extend the time limit:
		__setting_time_limit = MIN(600, MAX(__setting_time_limit, __state.minutes_elapsed + 100));
		__extended_time_limit_previously = true;
	}
}

void parseMap(string page_text)
{
	string [int][int] matches = group_string(page_text, "<a class=nounder href=\"wham.php.visit=([0-9])\"><font size=2><b>([^<]*)</b>");
	//print_html("map matches = " + matches.to_json().entity_encode());
	foreach key in matches
	{
		string location_id = matches[key][1];
		string location_name = matches[key][2];
		//print_html("location_id = \"" + location_id + "\" location_name = \"" + location_name + "\"");
		int location_id_int = location_id.to_int_silent();
		__state.location_names_to_ids[location_name] = location_id_int;
		__state.location_ids_to_names[location_id_int] = location_name;
	}
}

Individual parseIndividual(string page_text)
{
	//<td align=center width=200>
	//<td align=center width=200><img src="https://s3.amazonaws.com/images.kingdomofloathing.com/adventureimages/suspect_shifty_f.gif"><br><b>Evelyn Guy</b><br>dental hygienist	<p>(Game Room)<p>
	string [int][int] matches = group_string(page_text, "<td align=center width=200>[^<]*<img[^>]*>[^<]*<br>[^<]*<b>([^<]*)</b>[^<]*<br>[\t\n]*([^<\t\n]*)[^<]*<p>[^\(]*\\(([^\)]*)");
	if (matches.count() == 0)
		return IndividualMakeBlank();
	string name = matches[0][1];
	string occupation = matches[0][2];
	string location_name = matches[0][3];
	int location_id = __state.location_names_to_ids[location_name];
	//print_html("name = \"" + name + "\" occupation = \"" + occupation + "\" location_name = \"" + location_name + "\"");
	//print_html("individual matches = " + matches.to_json().entity_encode());
	//Try to find an individual matching this:
	
	SolveStateAddIndividualInformation(name, occupation, location_id);
	
	return __state.SolveStateLookupIndividualByLocationID(location_id);
}

void parseIndividualChoices(Individual individual_interrogating, string page_text)
{
	if (!individual_interrogating.exists)
		return;
	
	//Learn personality:
	string personality = group_string(page_text, "/adventureimages/suspect_([^\\.]*)\.gif")[0][1];
	if (personality.contains_text("_f")) //nancydrew vs. nancydrew_f
	{
		personality = personality.replace_string("_f", "");
	}
	individual_interrogating.personality = personality;
	//<a href="wham.php?ask=self&visit=2">herself</a>
	string [int][int] matches = group_string(page_text, "<a href=\"wham.php.ask=([^&]*)&visit=([0-9]*)\">([^<]*)</a>");
	//print_html("choice matches = " + matches.to_json().entity_encode());
	//killer, self, [person name]
	foreach key in matches
	{
		string ask_type = matches[key][1];
		string visit_id = matches[key][2];
		string name_identifier = matches[key][3];
		
		if (ask_type == "self" || ask_type == "killer")
			continue;
		if (ask_type.is_integer())
		{
			int subject_location_id = ask_type.to_int_silent();
			SolveStateAddIndividualInformation(name_identifier, "", subject_location_id);
			individual_interrogating.possible_choices_by_name_location_ids[subject_location_id] = true;
		}
		//print_html("ask_type = \"" + ask_type + "\" visit_id = \"" + visit_id + "\" name_identifier = \"" + name_identifier + "\"");
		individual_interrogating.possible_choices_by_name[name_identifier] = true;
	}
	
	//the victim's [occupation]
	//wham.php?ask=rel&w=1&visit=4
	string [int][int] matches2 = group_string(page_text, "<a href=\"wham.php.ask=rel&w=([0-9]*)&visit=([0-9]*)\">([^<]*)</a>");
	//print_html("choice matches2 = " + matches2.to_json().entity_encode());
	foreach key in matches2
	{
		string w = matches2[key][1];
		string visit_id = matches2[key][2];
		string occupation_identifier = matches2[key][3];
		int subject_location_id = w.to_int_silent();
		
		occupation_identifier = occupation_identifier.replace_string("the victim's ", "");
		SolveStateAddIndividualInformation("", occupation_identifier, subject_location_id);
		
		//print_html("w = \"" + w + "\" visit_id = \"" + visit_id + "\" occupation_identifier = \"" + occupation_identifier + "\"");
		individual_interrogating.possible_choices_by_occupation[occupation_identifier] = true;
		individual_interrogating.possible_choices_by_occupation_location_ids[subject_location_id] = true;
	}
	
}

void parseVisited(string url_to_access)
{
	string [int][int] matches = group_string(url_to_access, "visit=([0-9]*)");
	if (matches.count() == 0)
		return;
	string place_visited = matches[0][1];
	//print_html("place_visited = \"" + place_visited + "\"");
	if (place_visited.is_integer())
	{
		int place_visited_id = place_visited.to_int();
		__state.location_ids_visited[place_visited_id] = true;
		__state.last_location_visited = place_visited_id;
	}
}
void parseAccusation(string url_to_access, string page_text)
{
	int dollars_earned_from_this_case = 0;
	boolean solved = false;
	int minutes_solved_in = 0;
	//You failed, in 6958 minutes. Oh well, you still get a paycheck, for what it's worth
	if (page_text.contains_text("Oh well, you still get a paycheck, for what it's worth"))
	{
		minutes_solved_in = page_text.group_string("You failed, in ([0-9]*) minutes")[0][1].to_int_silent();
		dollars_earned_from_this_case += 3;
		if (!__disable_output)
			print("Oh no... the accusation was wrong. I am so sorry!");
	}
	else if (page_text.contains_text("Congratulations! You solved the case"))
	{
		solved = true;
		//You solved the case in 28 minutes
		minutes_solved_in = page_text.group_string("You solved the case in ([0-9]*) minutes")[0][1].to_int_silent();
		int bonus_dollars = page_text.group_string("detective skill, you've been awarded ([0-9]*) cop dollars")[0][1].to_int_silent();
		dollars_earned_from_this_case += 3;
		dollars_earned_from_this_case += bonus_dollars;
		if (!__disable_output)
			print("Solved the case in " + minutes_solved_in + " minutes, earning " + bonus_dollars + " bonus dollars.");
	}
	else if (!__disable_output)
		print_html("I'm not sure what happened. We accused somebody, and then...");
	
	if (!__setting_debug && dollars_earned_from_this_case > 0)
	{
		__dollars_earned += dollars_earned_from_this_case;
		//Update data files:
		string [string] historical_data_file;
		file_to_map(__historical_data_file_name, historical_data_file);
		historical_data_file["total dollars earned"] = historical_data_file["total dollars earned"].to_int_silent() + dollars_earned_from_this_case;
		historical_data_file["total cases taken"] = historical_data_file["total cases taken"].to_int_silent() + 1;
		if (solved)
			historical_data_file["total cases solved"] = historical_data_file["total cases solved"].to_int_silent() + 1;
		historical_data_file["total minutes taken"] = historical_data_file["total minutes taken"].to_int_silent() + minutes_solved_in;
		map_to_file(historical_data_file, __historical_data_file_name);
	}
}

void parse(string url_to_access, string page_text)
{
	if (url_to_access.contains_text("accuse="))
	{
		parseAccusation(url_to_access, page_text);
		return;
	}
	parseMinutes(page_text);
	//Parse out map:
	parseMap(page_text);
	//Parse out who they are:
	Individual individual_interrogating = parseIndividual(page_text);
	//Parse out possible choices:
	parseIndividualChoices(individual_interrogating, page_text);
	parseVisited(url_to_access);
	
	parseCoreTextFromPageText(individual_interrogating, url_to_access, page_text);
	
	SolveStateReverifyClaims(__state);
	
	SolveStateFindKiller(__state);
	if (__setting_debug && __setting_output_various_debug_text)
		SolveStateOutput(__state);
	if (__setting_debug)
		SolveStateVerifyLieHypothesis(__state);
}

int __visit_url_calls = 0;
void visitAndParse(string url_to_access)
{
	if (__visit_url_calls >= __setting_visit_url_limit)
	{
		__state.failed = true;
		if (!__disable_output)
			print_html("Went past self visit_url limit.");
		return;
	}
	__visit_url_calls += 1;
	//Output description of the URL we are loading:
	string output_description = "Loaded \"" + url_to_access + "\"";
	
	int visit_id = -1;
	string visit_name;
	if (url_to_access.contains_text("visit="))
	{
		visit_id = url_to_access.group_string("visit=([0-9]*)")[0][1].to_int_silent();
		visit_name = __state.location_ids_to_names[visit_id];
		if (visit_name == "")
		{
			if (visit_id == 1) //This is where we start out.
				visit_name = "the first room";
			else
				visit_name = "location ID " + visit_id;
		}
		else
			visit_name = "the " + visit_name;
	}
	
	if (url_to_access.contains_text("wham.php?visit="))
	{
		output_description = "Visiting " + visit_name + ".";
	}
	else if (url_to_access.contains_text("ask=killer"))
		output_description = "Asking in " + visit_name + " about the killer.";
	else if (url_to_access.contains_text("ask=rel"))
	{
		int person_asking_about_by_location_id = url_to_access.group_string("w=([0-9]*)")[0][1].to_int_silent();
		output_description = "Asking in " + visit_name + " about the person in the " + __state.location_ids_to_names[person_asking_about_by_location_id] + " by occupation.";
	}
	else if (url_to_access.contains_text("ask=self"))
	{
		output_description = "Asking in " + visit_name + " about themselves.";
	}
	else if (url_to_access.contains_text("ask="))
	{
		int person_asking_about_by_location_id = url_to_access.group_string("ask=([0-9]*)")[0][1].to_int_silent();
		output_description = "Asking in " + visit_name + " about the person in the " + __state.location_ids_to_names[person_asking_about_by_location_id] + " by name.";
	}
	else if (url_to_access.contains_text("accuse="))
	{
		int person_accusing_by_location_id = url_to_access.group_string("accuse=([0-9]*)")[0][1].to_int_silent();
		output_description = "Accusing the person in the " + __state.location_ids_to_names[person_accusing_by_location_id] + ".";
	}
	if (__setting_debug)
		output_description += " (" + url_to_access + ")";
		
	if (!__disable_output)
		print_html("<font color=\"#002255\">" + output_description + "</font>");
	
	string page_text = visit_url(url_to_access, false, false);
	if (page_text.contains_text("You are not on a case.") || !page_text.contains_text("blue><b>Who killed "))
	{
		__state.failed = true;
		return;
	}
	
	parse(url_to_access, page_text);
}

void collectTestData()
{
	__write_test_data = true;
	//Warning: sends many server requests.
	//Meet everyone:
	if (true)
	{
		for visit from 1 to 9
		{
			visitAndParse("wham.php?visit=" + visit);
		}
	}
	if (true)
	{
		for visit from 1 to 9
		{
			for other from 1 to 9
			{
				if (other == visit)
					continue;
				for samples from 1 to 9
				{
					visitAndParse("wham.php?ask=" + other + "&visit=" + visit);
					visitAndParse("wham.php?ask=rel&w=" + other + "&visit=" + visit);
				}
			}
			for samples from 1 to 9
			{
				visitAndParse("wham.php?ask=killer&visit=" + visit);
			}
		}
	}
	if (!__disable_output)
		print_html("Done.");
}

boolean tryToSolveCase()
{
	SolveState reset;
	__state = reset;
	if (get_property("_detectiveCasesCompleted").to_int_silent() >= 3)
	{
		if (!__disable_output)
			print_html("Out of cases for the day.");
		return false;
	}
	//Are we on a case?
	buffer page_text = visit_url("wham.php");
	if (page_text.contains_text("You are not on a case."))
	{
		//You are (not) on a case.
		//Start a new one:
		page_text = visit_url("place.php?whichplace=town_wrong&action=townwrong_precinct");
		if (page_text.contains_text("blue><b>The Wrong Side of the Tracks</b>"))
		{
			if (!__disable_output)
				print_html("You probably don't have a precinct, detective.");
			return false;
		}
		if (page_text.contains_text("(0 more cases today)")) //no more
		{
			if (!__disable_output)
				print_html("Out of cases for the day.");
			return false;
		}
		page_text = visit_url("choice.php?whichchoice=1193&option=1");
		//You don't need to click through, it just goes to wham.php anyways.
	}
	else if (!page_text.contains_text("blue><b>Who killed "))
	{
		if (!__disable_output)
			print_html("Unknown error with wham.php. Bailing out.");
		return false;
	}
	
	if (!__disable_output)
	{
		print_html("");
		print_html("Solving a new case...");
	}
	int attempts = 0;
	while (__setting_time_limit > __state.minutes_elapsed && attempts < __setting_max_attempts)
	{
		if (__state.failed)
		{
			if (!__disable_output)
				print_html("Cannot continue for unknown reason.");
			return false;
		}
		attempts += 1;
		if (__state.last_location_visited <= 0)
		{
			//We haven't visited anywhere - visit the first person.
			visitAndParse("wham.php?visit=1");
			continue;
		}
		
		
		//Do we have someone we can trust who accused the killer?
		if (__state.known_killer_location_id > 0)
		{
			Individual killer = __state.SolveStateLookupIndividualByLocationID(__state.known_killer_location_id);			
			if (killer.exists)
			{
				string killer_identifier = killer.name;
				if (killer.name == "")
					killer_identifier = "the " + killer.occupation;
				if (killer_identifier == "")
					killer_identifier = "the person" + killer.location_id;
				
				killer_identifier += " located in the " + __state.location_ids_to_names[killer.location_id];
				SolveStateOutput(__state);
				
				if (!__disable_output)
					print_html("<font color=red>I accuse " + killer_identifier + "!</font>");
				if (__setting_allow_automatic_accusations)
				{
					visitAndParse("wham.php?accuse=" + killer.location_id + "&visit=" + killer.location_id);
				}
				else
					return false;
				return true;
			}
		}
		
		//We're somewhere.
		//Who are we currently at?
		Individual currently_interrogating = __state.SolveStateLookupIndividualByLocationID(__state.last_location_visited);
		
		
		
		
		if (false)
		{
			//Testing: let's ask them every question, because I am curious if there's any inconsistencies.
			for other_person from 1 to 9
			{
				if (other_person == currently_interrogating.location_id)
					continue;
				visitAndParse("wham.php?ask=" + other_person + "&visit=" + currently_interrogating.location_id);
				visitAndParse("wham.php?ask=rel&w=" + other_person + "&visit=" + currently_interrogating.location_id);
			}
		}
		
		if (!currently_interrogating.asked_about_killer)
		{
			//We haven't asked them about the killer yet.
			visitAndParse("wham.php?ask=killer&visit=" + currently_interrogating.location_id);
			currently_interrogating.asked_about_killer = true;
			continue;
		}
		
		boolean pick_someone_else = false;
		//Do we have unverified information they've given us? If so, leave:
		boolean current_subject_has_unverified_claims = false;
		foreach key, claim in currently_interrogating.interrogation_claims
		{
			if (!claim.verified)
			{
				current_subject_has_unverified_claims = true;
				break;
			}
		}
		if (current_subject_has_unverified_claims)
			pick_someone_else = true;
		
		if (!(currently_interrogating.proven_liar || !currently_interrogating.knows_about_killer) && !pick_someone_else) //if they're not a liar or don't know about the killer
		{
			//Ask a question about someone we have the most information for.
			//Now, we can ask by both name and occupation.
			//Should try to ask shifty/paranoid by occupation, and jock/nancydrew by name, if you have a choice between one or the other, due to reasons.
			//FIXME implement this
			
			int chosen_person_to_ask_by_name = -1;
			int chosen_person_to_ask_by_name_relevant_information_count = 0;
			foreach location_id in currently_interrogating.possible_choices_by_name_location_ids
			{
				if (currently_interrogating.choices_name_we_visited_by_location_id[location_id])
					continue;
			
				Individual target = __state.SolveStateLookupIndividualByLocationID(location_id);
				int information_count = target.IndividualGetInformationCountIgnoringType(CORE_TEXT_MATCH_TYPE_NAME); //only qualify information we can gain
				
				if (information_count > chosen_person_to_ask_by_name_relevant_information_count)
				{
					chosen_person_to_ask_by_name_relevant_information_count = information_count;
					chosen_person_to_ask_by_name = location_id;
				}
			}
			
			int chosen_person_to_ask_by_occupation = -1;
			int chosen_person_to_ask_by_occupation_relevant_information_count = 0;
			foreach location_id in currently_interrogating.possible_choices_by_occupation_location_ids
			{
				if (currently_interrogating.choices_occupation_we_visited_by_location_id[location_id])
					continue;
			
				Individual target = __state.SolveStateLookupIndividualByLocationID(location_id);
				int information_count = target.IndividualGetInformationCountIgnoringType(CORE_TEXT_MATCH_TYPE_OCCUPATION); //only qualify information we can gain
				
				if (information_count > chosen_person_to_ask_by_occupation_relevant_information_count)
				{
					chosen_person_to_ask_by_occupation_relevant_information_count = information_count;
					chosen_person_to_ask_by_occupation = location_id;
				}
			}
			
			if (chosen_person_to_ask_by_name == -1 && chosen_person_to_ask_by_occupation == -1)
			{
				pick_someone_else = true;
			}
			else
			{
				//Pick which one we ask by:
				boolean ask_by_occupation = false;
				//Pick the type we have the most information for:
				if (chosen_person_to_ask_by_occupation_relevant_information_count > chosen_person_to_ask_by_name_relevant_information_count)
					ask_by_occupation = true;
				else if (chosen_person_to_ask_by_occupation_relevant_information_count < chosen_person_to_ask_by_name_relevant_information_count)
					ask_by_occupation = false;
				else if (random(2) == 0) //they're tied, pick randomly, why not?
					ask_by_occupation = true;
				if (currently_interrogating.personality == "jock" || currently_interrogating.personality == "nancydrew")
				{
					//Prefer to ask by name for these:
					ask_by_occupation = false;
				}
				if (currently_interrogating.personality == "shifty" || currently_interrogating.personality == "paranoid" || currently_interrogating.personality == "bertie")
				{
					//Prefer to ask by occupation:
					ask_by_occupation = true;
				}
				
				if (chosen_person_to_ask_by_name == -1) //can't
					ask_by_occupation = true;
				else if (chosen_person_to_ask_by_occupation == -1)
					ask_by_occupation = false;
				
				if (chosen_person_to_ask_by_occupation != -1 && ask_by_occupation)
				{
					visitAndParse("wham.php?ask=rel&w=" + chosen_person_to_ask_by_occupation + "&visit=" + currently_interrogating.location_id);
					continue;
				}
				else if (chosen_person_to_ask_by_name != -1)
				{
					visitAndParse("wham.php?ask=" + chosen_person_to_ask_by_name + "&visit=" + currently_interrogating.location_id);
					continue;
				}
			}
		}
		
		if (currently_interrogating.proven_liar || !currently_interrogating.knows_about_killer || pick_someone_else)
		{
			//Nothing more can be gained from this. Try someone else:
			int desired_visit_location = -1;
			for visit_id from 1 to 9
			{
				if (__state.location_ids_visited[visit_id])
					continue;
				desired_visit_location = visit_id;
				break;
			}
			
			//Is there an individual who has made a claim about the killer, but we weren't able to verify yet, but they probably have additional options available to us now?
			foreach key, i in __state.known_individuals
			{
				if (i.proven_liar)
					continue;
				if (!i.knows_about_killer)
					continue;
				//They're not lying and they know about the killer.
				//Do they have unproven claims? If so, don't revisit just yet.
				boolean have_unverified_claims = false;
				foreach key2, claim in i.interrogation_claims
				{
					if (!claim.verified)
					{
						have_unverified_claims = true;
						break;
					}
				}
				if (have_unverified_claims) //verify them first, by visiting around
					continue;
				//Do they have any questions we haven't asked yet?
				boolean should_ask_them = false;
				foreach key2, i2 in __state.known_individuals
				{
					if (i2.location_id == i.location_id)
						continue;
					if (i2.occupation == "") //we don't know their occupation yet, can't ask
						continue;
					if (currently_interrogating.choices_occupation_we_visited_by_location_id[i2.location_id]) //already asked
						continue;
					//We know about them, we know their occupation, but we haven't asked them some things... let's head back.
					should_ask_them = true;
					break;
				}
				if (should_ask_them)
				{
					desired_visit_location = i.location_id;
					break;
				}
				//if (currently_interrogating.choices_occupation_we_visited_by_location_id[location_id])
			}
			
			//Is there somewhere we need to verify incomplete information on?
			boolean [int] locations_have_individuals_we_need_to_verify;
			foreach key, i in __state.known_individuals
			{
				if (i.proven_liar)
					continue;
				foreach key2, claim in i.interrogation_claims
				{
					if (claim.verified)
						continue;
					locations_have_individuals_we_need_to_verify[claim.person_asking_about_by_location_id] = true;
				}
			}
			foreach visit_id in locations_have_individuals_we_need_to_verify
			{
				if (__state.location_ids_visited[visit_id])
					continue;
				desired_visit_location = visit_id;
				break;
			}
			
			if (desired_visit_location == __state.last_location_visited)
			{
				SolveStateOutput(__state);
				if (!__disable_output)
					print_html("Internal error: Trying to visit the location we are already at.");
				return false;
			}
			if (desired_visit_location == -1)// || __state.location_ids_visited[desired_visit_location])
			{
				SolveStateOutput(__state);
				if (!__disable_output)
					print_html("Ran out of locations to try.");
				return false;
			}
				
			
			visitAndParse("wham.php?visit=" + desired_visit_location);
			continue;
		}
	}
	SolveStateOutput(__state);
	if (__setting_time_limit <= __state.minutes_elapsed)
	{
		if (!__disable_output)
			print_html("Went over time limit, apologies.");
	}
	
	if (attempts >= __setting_max_attempts)
	{
		if (!__disable_output)
			print_html("Went over maximum attempts, apologies.");
	}
		
	return false;
}

//Add in TRUE for quiet to prevent all output. Useful if being used in another script.
void solveAllCases(boolean quiet)
{
	if (quiet)
		__disable_output = true;
	int attempts = 0;
	boolean success = false;
	while (attempts <3)
	{
		success = tryToSolveCase();
		if (!success)
			break;
		attempts += 1;
	}
	if ((success || __dollars_earned > 0) && !__disable_output)
	{
		//Doesn't list the dollars we get from visiting the precinct every day... should it?
		string final_output = "Completed solving cases.";
		if (__dollars_earned > 0)
		{
			final_output += " Earned " + __dollars_earned + " cop dollars.";
			
			string [string] historical_data_file;
			file_to_map(__historical_data_file_name, historical_data_file);
			int historical_dollars_earned = historical_data_file["total dollars earned"].to_int_silent();
			int historical_cases_taken = historical_data_file["total cases taken"].to_int_silent();
			int historical_minutes_taken = historical_data_file["total minutes taken"].to_int_silent();
			if (historical_cases_taken > 0 && historical_cases_taken > 3)
			{
				//Display historical rewards/day, as I think that's the most meaningful. ("how many days is it until I can get X?")
				float average_dollars_per_case = historical_dollars_earned.to_float() / historical_cases_taken.to_float();
				float average_dollars_per_day = average_dollars_per_case * 3;
				
				float averages_minutes_per_case = historical_minutes_taken.to_float() / historical_cases_taken.to_float();
				
				final_output += " Historical average is " + average_dollars_per_day.round() + " dollars/day and " + averages_minutes_per_case.round() + " minutes/case.";
			}
		}
		print_html(final_output);
	}
}

void main()
{
	if (!__disable_output)
		print_html("Detective Solver.ash version " + __version);
	if (__setting_debug)
	{
		__setting_time_limit = 7000;
		__setting_visit_url_limit = 2000;
	}
	
	if (__setting_debug && false) //do not enable unless you love sending server requests
	{
		collectTestData();
		return;
	}
	
	solveAllCases(false);
}
