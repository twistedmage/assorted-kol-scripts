since r18080;
//Briefcase.ash
//Usage: "briefcase help" in the graphical CLI.
//Also includes a relay override.

string __briefcase_version = "2.0.1";
//Debug settings:
boolean __setting_enable_debug_output = false;
boolean __setting_debug = false;

boolean __setting_confirm_actions_that_will_use_a_click = false;

boolean __setting_output_help_before_main = false;

boolean __setting_do_not_actually_use_clicks = false; //FIXME only partially implemented, and only use with confirm_actions

boolean __setting_have_dark_background = true;

string __setting_background_colour = "#E1E3E7";
string __setting_light_colour = "#87888A";
//WARNING: All listAppend functions are flawed.
//Specifically, there's a possibility of a hole that causes order to be incorrect.
//But, the only way to fix that is to traverse the list to determine the maximum key.
//That would take forever...

string listLastObject(string [int] list)
{
    if (list.count() == 0)
        return "";
    return list[list.count() - 1];
}

void listAppend(string [int] list, string entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(string [int] list, string [int] entries)
{
	foreach key in entries
		list.listAppend(entries[key]);
}

string [int] listUnion(string [int] list, string [int] list2)
{
    string [int] result;
    foreach key, s in list
        result.listAppend(s);
    foreach key, s in list2
        result.listAppend(s);
    return result;
}

void listAppendList(boolean [item] destination, boolean [item] source)
{
    foreach it, value in source
        destination[it] = value;
}

void listAppendList(boolean [string] destination, boolean [string] source)
{
    foreach key, value in source
        destination[key] = value;
}

void listAppendList(boolean [skill] destination, boolean [skill] source)
{
    foreach key, value in source
        destination[key] = value;
}

void listAppend(item [int] list, item entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(item [int] list, item [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}



void listAppend(int [int] list, int entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(float [int] list, float entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(location [int] list, location entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(element [int] list, element entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppendList(location [int] list, location [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}

void listAppend(effect [int] list, effect entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(skill [int] list, skill entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(familiar [int] list, familiar entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(monster [int] list, monster entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(phylum [int] list, phylum entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(buffer [int] list, buffer entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(slot [int] list, slot entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(thrall [int] list, thrall entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}





void listAppend(string [int][int] list, string [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(skill [int][int] list, skill [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(familiar [int][int] list, familiar [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(int [int][int] list, int [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(item [int][int] list, item [int] entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

void listAppend(skill [int] list, boolean [skill] entry)
{
    foreach v in entry
        list.listAppend(v);
}

void listAppend(item [int] list, boolean [item] entry)
{
    foreach v in entry
        list.listAppend(v);
}

void listPrepend(string [int] list, string entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}

void listPrepend(skill [int] list, skill entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}

void listAppendList(skill [int] list, skill [int] entries)
{
	foreach key in entries
        list.listAppend(entries[key]);
}

void listPrepend(location [int] list, location entry)
{
	int position = 0;
	while (list contains position)
		position -= 1;
	list[position] = entry;
}


void listClear(string [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(int [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(item [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(location [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(monster [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}

void listClear(skill [int] list)
{
	foreach i in list
	{
		remove list[i];
	}
}


void listClear(boolean [string] list)
{
	foreach i in list
	{
		remove list[i];
	}
}


string [int] listMakeBlankString()
{
	string [int] result;
	return result;
}

item [int] listMakeBlankItem()
{
	item [int] result;
	return result;
}

skill [int] listMakeBlankSkill()
{
	skill [int] result;
	return result;
}

location [int] listMakeBlankLocation()
{
	location [int] result;
	return result;
}

monster [int] listMakeBlankMonster()
{
	monster [int] result;
	return result;
}

familiar [int] listMakeBlankFamiliar()
{
	familiar [int] result;
	return result;
}




string [int] listMake(string e1)
{
	string [int] result;
	result.listAppend(e1);
	return result;
}

string [int] listMake(string e1, string e2)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

string [int] listMake(string e1, string e2, string e3)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4, string e5)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

string [int] listMake(string e1, string e2, string e3, string e4, string e5, string e6)
{
	string [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	result.listAppend(e6);
	return result;
}

int [int] listMake(int e1)
{
	int [int] result;
	result.listAppend(e1);
	return result;
}

int [int] listMake(int e1, int e2)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

int [int] listMake(int e1, int e2, int e3)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

int [int] listMake(int e1, int e2, int e3, int e4)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

int [int] listMake(int e1, int e2, int e3, int e4, int e5)
{
	int [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

item [int] listMake(item e1)
{
	item [int] result;
	result.listAppend(e1);
	return result;
}

item [int] listMake(item e1, item e2)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

item [int] listMake(item e1, item e2, item e3)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

item [int] listMake(item e1, item e2, item e3, item e4)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

item [int] listMake(item e1, item e2, item e3, item e4, item e5)
{
	item [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
	return result;
}

skill [int] listMake(skill e1)
{
	skill [int] result;
	result.listAppend(e1);
	return result;
}

skill [int] listMake(skill e1, skill e2)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3, skill e4)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	return result;
}

skill [int] listMake(skill e1, skill e2, skill e3, skill e4, skill e5)
{
	skill [int] result;
	result.listAppend(e1);
	result.listAppend(e2);
	result.listAppend(e3);
	result.listAppend(e4);
	result.listAppend(e5);
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


string listJoinComponents(item [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert items to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(item [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(monster [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}
string listJoinComponents(monster [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(effect [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(effect [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}


string listJoinComponents(familiar [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(familiar [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}



string listJoinComponents(location [int] list, string joining_string, string and_string)
{
	//lazy:
	//convert locations to strings, join that
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(location [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}

string listJoinComponents(phylum [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(phylum [int] list, string joining_string)
{
	return listJoinComponents(list, joining_string, "");
}



string listJoinComponents(skill [int] list, string joining_string, string and_string)
{
	string [int] list_string;
	foreach key in list
		list_string.listAppend(list[key].to_string());
	return listJoinComponents(list_string, joining_string, and_string);
}

string listJoinComponents(skill [int] list, string joining_string)
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


void listRemoveKeys(string [int] list, int [int] keys_to_remove)
{
	foreach i in keys_to_remove
	{
		int key = keys_to_remove[i];
		if (!(list contains key))
			continue;
		remove list[key];
	}
}

int listSum(int [int] list)
{
    int v = 0;
    foreach key in list
    {
        v += list[key];
    }
    return v;
}


string [int] listCopy(string [int] l)
{
    string [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

int [int] listCopy(int [int] l)
{
    int [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

monster [int] listCopy(monster [int] l)
{
    monster [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

element [int] listCopy(element [int] l)
{
    element [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

skill [int] listCopy(skill [int] l)
{
    skill [int] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

boolean [monster] listCopy(boolean [monster] l)
{
    boolean [monster] result;
    foreach key in l
        result[key] = l[key];
    return result;
}

//Strict, in this case, means the keys start at 0, and go up by one per entry. This allows easy consistent access
boolean listKeysMeetStrictRequirements(string [int] list)
{
    int expected_value = 0;
    foreach key in list
    {
        if (key != expected_value)
            return false;
        expected_value += 1;
    }
    return true;
}
string [int] listCopyStrictRequirements(string [int] list)
{
    string [int] result;
    foreach key in list
        result.listAppend(list[key]);
    return result;
}

string [string] mapMake()
{
	string [string] result;
	return result;
}

string [string] mapMake(string key1, string value1)
{
	string [string] result;
	result[key1] = value1;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3, string key4, string value4)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	result[key4] = value4;
	return result;
}

string [string] mapMake(string key1, string value1, string key2, string value2, string key3, string value3, string key4, string value4, string key5, string value5)
{
	string [string] result;
	result[key1] = value1;
	result[key2] = value2;
	result[key3] = value3;
	result[key4] = value4;
	result[key5] = value5;
	return result;
}

string [string] mapCopy(string [string] map)
{
    string [string] result;
    foreach key in map
        result[key] = map[key];
    return result;
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


boolean [int] listInvert(int [int] list)
{
	boolean [int] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [location] listInvert(location [int] list)
{
	boolean [location] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [item] listInvert(item [int] list)
{
	boolean [item] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [monster] listInvert(monster [int] list)
{
	boolean [monster] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

boolean [familiar] listInvert(familiar [int] list)
{
	boolean [familiar] result;
	foreach key in list
	{
		result[list[key]] = true;
	}
	return result;
}

int [int] listConvertToInt(string [int] list)
{
	int [int] result;
	foreach key in list
		result[key] = list[key].to_int();
	return result;
}

item [int] listConvertToItem(string [int] list)
{
	item [int] result;
	foreach key in list
		result[key] = list[key].to_item();
	return result;
}

string listFirstObject(string [int] list)
{
    foreach key in list
        return list[key];
    return "";
}

//(I'm assuming maps have a consistent enumeration order, which may not be the case)
int listKeyForIndex(string [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(location [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(familiar [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(item [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int listKeyForIndex(monster [int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

int llistKeyForIndex(string [int][int] list, int index)
{
	int i = 0;
	foreach key in list
	{
		if (i == index)
			return key;
		i += 1;
	}
	return -1;
}

string listGetRandomObject(string [int] list)
{
    if (list.count() == 0)
        return "";
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

item listGetRandomObject(item [int] list)
{
    if (list.count() == 0)
        return $item[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

location listGetRandomObject(location [int] list)
{
    if (list.count() == 0)
        return $location[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

familiar listGetRandomObject(familiar [int] list)
{
    if (list.count() == 0)
        return $familiar[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}

monster listGetRandomObject(monster [int] list)
{
    if (list.count() == 0)
        return $monster[none];
    if (list.count() == 1)
    	return list[listKeyForIndex(list, 0)];
    return list[listKeyForIndex(list, random(list.count()))];
}


boolean listContainsValue(monster [int] list, monster vo)
{
    foreach key, v2 in list
    {
        if (v2 == vo)
            return true;
    }
    return false;
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

int [int] listInvert(boolean [int] list)
{
    int [int] out;
    foreach m, value in list
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

skill [int] listInvert(boolean [skill] list)
{
    skill [int] out;
    foreach m, value in list
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

monster [int] listInvert(boolean [monster] monsters)
{
    monster [int] out;
    foreach m, value in monsters
    {
        if (value)
            out.listAppend(m);
    }
    return out;
}

location [int] listInvert(boolean [location] list)
{
    location [int] out;
    foreach k, value in list
    {
        if (value)
            out.listAppend(k);
    }
    return out;
}

familiar [int] listInvert(boolean [familiar] list)
{
    familiar [int] out;
    foreach k, value in list
    {
        if (value)
            out.listAppend(k);
    }
    return out;
}

item [int] listInvert(boolean [item] list)
{
    item [int] out;
    foreach k, value in list
    {
        if (value)
            out.listAppend(k);
    }
    return out;
}

skill [int] listConvertStringsToSkills(string [int] list)
{
    skill [int] out;
    foreach key, s in list
    {
        out.listAppend(s.to_skill());
    }
    return out;
}

monster [int] listConvertStringsToMonsters(string [int] list)
{
    monster [int] out;
    foreach key, s in list
    {
        out.listAppend(s.to_monster());
    }
    return out;
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


float __setting_indention_width_in_em = 1.45;
string __setting_indention_width = __setting_indention_width_in_em + "em";

string __html_right_arrow_character = "&#9658;";

buffer HTMLGenerateTagPrefix(string tag, string [string] attributes)
{
	buffer result;
	result.append("<");
	result.append(tag);
	foreach attribute_name, attribute_value in attributes
	{
		//string attribute_value = attributes[attribute_name];
		result.append(" ");
		result.append(attribute_name);
		if (attribute_value != "")
		{
			boolean is_integer = attribute_value.is_integer(); //don't put quotes around integer attributes (i.e. width, height)
			
			result.append("=");
			if (!is_integer)
				result.append("\"");
			result.append(attribute_value);
			if (!is_integer)
				result.append("\"");
		}
	}
	result.append(">");
	return result;
}

buffer HTMLGenerateTagPrefix(string tag)
{
    buffer result;
    result.append("<");
    result.append(tag);
    result.append(">");
    return result;
}

buffer HTMLGenerateTagSuffix(string tag)
{
    buffer result;
    result.append("</");
    result.append(tag);
    result.append(">");
    return result;
}

buffer HTMLGenerateTagWrap(string tag, string source, string [string] attributes)
{
    buffer result;
    result.append(HTMLGenerateTagPrefix(tag, attributes));
    result.append(source);
    result.append(HTMLGenerateTagSuffix(tag));
	return result;
}

buffer HTMLGenerateTagWrap(string tag, string source)
{
    buffer result;
    result.append(HTMLGenerateTagPrefix(tag));
    result.append(source);
    result.append(HTMLGenerateTagSuffix(tag));
	return result;
}

buffer HTMLGenerateDivOfClass(string source, string class_name)
{
	if (class_name == "")
		return HTMLGenerateTagWrap("div", source);
	else
		return HTMLGenerateTagWrap("div", source, mapMake("class", class_name));
}

buffer HTMLGenerateDivOfClass(string source, string class_name, string extra_style)
{
	return HTMLGenerateTagWrap("div", source, mapMake("class", class_name, "style", extra_style));
}

buffer HTMLGenerateDivOfStyle(string source, string style)
{
	if (style == "")
		return HTMLGenerateTagWrap("div", source);
	
	return HTMLGenerateTagWrap("div", source, mapMake("style", style));
}

buffer HTMLGenerateDiv(string source)
{
    return HTMLGenerateTagWrap("div", source);
}

buffer HTMLGenerateSpan(string source)
{
    return HTMLGenerateTagWrap("span", source);
}

buffer HTMLGenerateSpanOfClass(string source, string class_name)
{
	if (class_name == "")
		return HTMLGenerateTagWrap("span", source);
	else
		return HTMLGenerateTagWrap("span", source, mapMake("class", class_name));
}

buffer HTMLGenerateSpanOfStyle(string source, string style)
{
	if (style == "")
    {
        buffer out;
        out.append(source);
        return out;
    }
	return HTMLGenerateTagWrap("span", source, mapMake("style", style));
}

buffer HTMLGenerateSpanFont(string source, string font_colour, string font_size)
{
	if (font_colour == "" && font_size == "")
    {
        buffer out;
        out.append(source);
        return out;
    }
		
	buffer style;
	
	if (font_colour != "")
    {
		//style += "color:" + font_colour + ";";
        style.append("color:");
        style.append(font_colour);
        style.append(";");
    }
	if (font_size != "")
    {
		//style += "font-size:" + font_size + ";";
        style.append("font-size:");
        style.append(font_size);
        style.append(";");
    }
	return HTMLGenerateSpanOfStyle(source, style.to_string());
}

buffer HTMLGenerateSpanFont(string source, string font_colour)
{
    return HTMLGenerateSpanFont(source, font_colour, "");
}

string HTMLConvertStringToAnchorID(string id)
{
    if (id.length() == 0)
        return id;
    
	id = to_string(replace_string(id, " ", "_"));
	//ID and NAME must begin with a letter ([A-Za-z]) and may be followed by any number of letters, digits ([0-9]), hyphens ("-"), underscores ("_"), colons (":"), and periods (".")
    
	//FIXME do that
	return id;
}

string HTMLEscapeString(string line)
{
    return entity_encode(line);
}

string HTMLStripTags(string html)
{
    matcher pattern = create_matcher("<[^>]*>", html);
    return pattern.replace_all("");
}


string [string] generateMainLinkMap(string url)
{
    return mapMake("class", "r_a_undecorated", "href", url, "target", "mainpane");
}



string HTMLGreyOutTextUnlessTrue(string text, boolean conditional)
{
    if (conditional)
        return text;
    return HTMLGenerateSpanFont(text, "gray");
}
//These settings are for development. Don't worry about editing them.
string __version = "1.4.31a1";

//Debugging:
boolean __setting_debug_mode = false;
boolean __setting_debug_enable_example_mode_in_aftercore = false; //for testing. Will give false information, so don't enable
boolean __setting_debug_show_all_internal_states = false; //displays usable images/__misc_state/__misc_state_string/__misc_state_int/__quest_state

//Display settings:
boolean __setting_entire_area_clickable = false;
boolean __setting_side_negative_space_is_dark = true;
boolean __setting_fill_vertical = true;
int __setting_image_width_large = 100;
int __setting_image_width_medium = 70;
int __setting_image_width_small = 30;

boolean __show_importance_bar = true;
boolean __setting_show_navbar = true;
boolean __setting_navbar_has_proportional_widths = false; //doesn't look very good, remove?
boolean __setting_gray_navbar = true;
boolean __use_table_based_layouts = false; //backup implementation. not compatible with media queries. consider removing?
boolean __setting_use_kol_css = false; //images/styles.css
boolean __setting_show_location_bar = true;
boolean __setting_enable_location_popup_box = true;
boolean __setting_location_bar_uses_last_location = false; //nextAdventure otherwise
boolean __setting_location_bar_fixed_layout = true;
boolean __setting_location_bar_limit_max_width = true;
float __setting_location_bar_max_width_per_entry = 0.35;
boolean __setting_small_size_uses_full_width = false; //implemented, but disabled - doesn't look amazing. reduced indention width instead to compensate
boolean __setting_enable_outputting_all_numberology_options = true;

string __setting_unavailable_colour = "#7F7F7F";
string __setting_line_colour = "#B2B2B2";
string __setting_dark_colour = "#C0C0C0";
string __setting_modifier_colour = "#404040";
string __setting_navbar_background_colour = "#FFFFFF";
string __setting_page_background_colour = "#F7F7F7";

string __setting_media_query_large_size = "@media (min-width: 500px)";
string __setting_media_query_medium_size = "@media (min-width: 350px) and (max-width: 500px)";
string __setting_media_query_small_size = "@media (max-width: 350px) and (min-width: 225px)";
string __setting_media_query_tiny_size = "@media (max-width: 225px)";

float __setting_navbar_height_in_em = 2.3;
string __setting_navbar_height = __setting_navbar_height_in_em + "em";
int __setting_horizontal_width = 600;
boolean __setting_ios_appearance = false; //no don't

record CSSEntry
{
    string tag;
    string class_name;
    string definition;
    int importance;
};

CSSEntry CSSEntryMake(string tag, string class_name, string definition, int importance)
{
    CSSEntry entry;
    entry.tag = tag;
    entry.class_name = class_name;
    entry.definition = definition;
    entry.importance = importance;
    return entry;
}

record CSSBlock
{
    CSSEntry [int] defined_css_classes;
    string identifier;
};

CSSBlock CSSBlockMake(string identifier)
{
    CSSBlock result;
    result.identifier = identifier;
    return result;
}

buffer CSSBlockGenerate(CSSBlock block)
{
    buffer result;
    
    if (block.defined_css_classes.count() > 0)
    {
        boolean output_identifier = (block.identifier != "");
        if (output_identifier)
        {
            result.append("\t\t\t");
            result.append(block.identifier);
            result.append(" {\n");
        }
        sort block.defined_css_classes by value.importance;
    
        foreach key in block.defined_css_classes
        {
            CSSEntry entry = block.defined_css_classes[key];
            result.append("\t\t\t");
            if (output_identifier)
                result.append("\t");
        
            if (entry.class_name == "")
                result.append(entry.tag + " { " + entry.definition + " }");
            else
                result.append(entry.tag + "." + entry.class_name + " { " + entry.definition + " }");
            result.append("\n");
        }
        if (output_identifier)
            result.append("\n\t\t\t}\n");
    }
    return result;
}

void listAppend(CSSEntry [int] list, CSSEntry entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

record Page
{
	string title;
	buffer head_contents;
	buffer body_contents;
	string [string] body_attributes; //[attribute_name] -> attribute_value
	
    CSSBlock [string] defined_css_blocks; //There is always an implicit "" block.
};


Page __global_page;



Page Page()
{
	return __global_page;
}

buffer PageGenerateBodyContents(Page page_in)
{
    return page_in.body_contents;
}

buffer PageGenerateBodyContents()
{
    return Page().PageGenerateBodyContents();
}

buffer PageGenerate(Page page_in)
{
	buffer result;
	
	result.append("<!DOCTYPE html>\n"); //HTML 5 target
	result.append("<html>\n");
	
	//Head:
	result.append("\t<head>\n");
	result.append("\t\t<title>");
	result.append(page_in.title);
	result.append("</title>\n");
	if (page_in.head_contents.length() != 0)
	{
        result.append("\t\t");
		result.append(page_in.head_contents);
		result.append("\n");
	}
	//Write CSS styles:
    if (page_in.defined_css_blocks.count() > 0)
    {
        if (true)
        {
            result.append("\t\t");
            result.append(HTMLGenerateTagPrefix("style", mapMake("type", "text/css")));
            result.append("\n");
        }
        result.append(page_in.defined_css_blocks[""].CSSBlockGenerate()); //write first
        foreach identifier in page_in.defined_css_blocks
        {
            CSSBlock block = page_in.defined_css_blocks[identifier];
            if (identifier == "") //skip, already written
                continue;
            result.append(block.CSSBlockGenerate());
        }
        if (true)
        {
            result.append("\t\t</style>\n");
        }
    }
    result.append("\t</head>\n");
	
	//Body:
	result.append("\t");
	result.append(HTMLGenerateTagPrefix("body", page_in.body_attributes));
	result.append("\n\t\t");
	result.append(page_in.body_contents);
	result.append("\n");
		
	result.append("\t</body>\n");
	

	result.append("</html>");
	
	return result;
}

void PageGenerateAndWriteOut(Page page_in)
{
	write(PageGenerate(page_in));
}

void PageSetTitle(Page page_in, string title)
{
	page_in.title = title;
}

void PageAddCSSClass(Page page_in, string tag, string class_name, string definition, int importance, string block_identifier)
{
    //print_html("Adding block_identifier \"" + block_identifier + "\"");
    if (!(page_in.defined_css_blocks contains block_identifier))
        page_in.defined_css_blocks[block_identifier] = CSSBlockMake(block_identifier);
    page_in.defined_css_blocks[block_identifier].defined_css_classes.listAppend(CSSEntryMake(tag, class_name, definition, importance));
}

void PageAddCSSClass(Page page_in, string tag, string class_name, string definition, int importance)
{
    PageAddCSSClass(page_in, tag, class_name, definition, importance, "");
}

void PageAddCSSClass(Page page_in, string tag, string class_name, string definition)
{
    PageAddCSSClass(page_in, tag, class_name, definition, 0);
}


void PageWriteHead(Page page_in, string contents)
{
	page_in.head_contents.append(contents);
}

void PageWriteHead(Page page_in, buffer contents)
{
	page_in.head_contents.append(contents);
}


void PageWrite(Page page_in, string contents)
{
	page_in.body_contents.append(contents);
}

void PageWrite(Page page_in, buffer contents)
{
	page_in.body_contents.append(contents);
}

void PageSetBodyAttribute(Page page_in, string attribute, string value)
{
	page_in.body_attributes[attribute] = value;
}


//Global:

buffer PageGenerate()
{
	return PageGenerate(Page());
}

void PageGenerateAndWriteOut()
{
	write(PageGenerate());
}

void PageSetTitle(string title)
{
	PageSetTitle(Page(), title);
}

void PageAddCSSClass(string tag, string class_name, string definition)
{
	PageAddCSSClass(Page(), tag, class_name, definition);
}

void PageAddCSSClass(string tag, string class_name, string definition, int importance)
{
	PageAddCSSClass(Page(), tag, class_name, definition, importance);
}

void PageAddCSSClass(string tag, string class_name, string definition, int importance, string block_identifier)
{
	PageAddCSSClass(Page(), tag, class_name, definition, importance, block_identifier);
}

void PageWriteHead(string contents)
{
	PageWriteHead(Page(), contents);
}

void PageWriteHead(buffer contents)
{
	PageWriteHead(Page(), contents);
}

//Writes to body:

void PageWrite(string contents)
{
	PageWrite(Page(), contents);
}

void PageWrite(buffer contents)
{
	PageWrite(Page(), contents);
}

void PageSetBodyAttribute(string attribute, string value)
{
	PageSetBodyAttribute(Page(), attribute, value);
}


void PageInit()
{
	PageAddCSSClass("a", "r_a_undecorated", "text-decoration:none;color:inherit;");
	PageAddCSSClass("", "r_centre", "margin-left:auto; margin-right:auto;text-align:center;");
	PageAddCSSClass("", "r_bold", "font-weight:bold;");
	PageAddCSSClass("", "r_end_floating_elements", "clear:both;");
	
	
	PageAddCSSClass("", "r_element_stench", "color:green;");
	PageAddCSSClass("", "r_element_hot", "color:red;");
	PageAddCSSClass("", "r_element_cold", "color:blue;");
	PageAddCSSClass("", "r_element_sleaze", "color:purple;");
	PageAddCSSClass("", "r_element_spooky", "color:gray;");
    
    //50% desaturated versions of above:
	PageAddCSSClass("", "r_element_stench_desaturated", "color:#427F40;");
	PageAddCSSClass("", "r_element_hot_desaturated", "color:#FF7F81;");
	PageAddCSSClass("", "r_element_cold_desaturated", "color:#6B64FF;");
	PageAddCSSClass("", "r_element_sleaze_desaturated", "color:#7F407F;");
	PageAddCSSClass("", "r_element_spooky_desaturated", "color:gray;");
	
	PageAddCSSClass("", "r_indention", "margin-left:" + __setting_indention_width + ";");
	
	//Simple table lines:
	PageAddCSSClass("div", "r_stl_container", "display:table;");
	PageAddCSSClass("div", "r_stl_container_row", "display:table-row;");
    PageAddCSSClass("div", "r_stl_entry", "padding:0px;margin:0px;display:table-cell;");
    PageAddCSSClass("div", "r_stl_spacer", "width:1em;");
}



string HTMLGenerateIndentedText(string text, string width)
{
	if (__use_table_based_layouts) //table-based layout
		return "<table cellpadding=0 cellspacing=0 width=100%><tr>" + HTMLGenerateTagWrap("td", "", mapMake("style", "width:" + width + ";")) + "<td>" + text + "</td></tr></table>";
	else //div-based layout:
		return HTMLGenerateDivOfClass(text, "r_indention");
}

string HTMLGenerateIndentedText(string [int] text)
{

	buffer building_text;
	foreach key in text
	{
		string line = text[key];
		building_text.append(HTMLGenerateDiv(line));
	}
	
	return HTMLGenerateIndentedText(to_string(building_text), __setting_indention_width);
}

string HTMLGenerateIndentedText(string text)
{
	return HTMLGenerateIndentedText(text, __setting_indention_width);
}


string HTMLGenerateSimpleTableLines(string [int][int] lines, boolean dividers_are_visible)
{
	buffer result;
	
	int max_columns = 0;
	foreach i in lines
	{
		max_columns = max(max_columns, lines[i].count());
	}
	
	if (__use_table_based_layouts)
	{
		//table-based layout:
		result.append("<table style=\"margin-right: 10px; width:100%;\" cellpadding=0 cellspacing=0>");
	
	
        int intra_i = 0;
		foreach i in lines
		{
            if (intra_i > 0)
            {
                result.append("<tr><td colspan=1000><hr></td></tr>");
            }
			result.append("<tr>");
			int intra_j = 0;
			foreach j in lines[i]
			{
				string entry = lines[i][j];
				result.append("<td align=");
				if (false && max_columns == 1)
					result.append("center");
				else if (intra_j == 0)
					result.append("left");
				else
					result.append("right");
				if (lines[i].count() < max_columns && intra_j == lines[i].count() - 1)
				{
					int calculated_colspan = max_columns - lines[i].count() + 1;
					result.append(" colspan=" + calculated_colspan);
				}
				result.append(">");
				result.append(entry);
				result.append("</td>");
				intra_j += 1;
			}
			result.append("</tr>");
            intra_i += 1;
		}
	
	
		result.append("</table>");
	}
	else
	{
		//div-based layout:
        int intra_i = 0;
        int last_cell_count = 0;
        result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_stl_container")));
		foreach i in lines
		{
            if (intra_i > 0)
            {
                result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_stl_container_row")));
                for i from 1 to last_cell_count //no colspan with display:table, generate extra (zero-padding, zero-margin) cells:
                {
                    string separator = "";
                    if (dividers_are_visible)
                        separator = "<hr>";
                    else
                        separator = "<hr style=\"opacity:0\">"; //laziness - generate an invisible HR, so there's still spacing
                    result.append(HTMLGenerateDivOfClass(separator, "r_stl_entry"));
                }
                result.append("</div>");
                last_cell_count = 0;
            }
            result.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_stl_container_row")));
            int intra_j = 0;
			foreach j in lines[i]
			{
				string entry = lines[i][j];
                if (intra_j > 0)
                {
                    result.append(HTMLGenerateDivOfClass("", "r_stl_entry r_stl_spacer"));
                    last_cell_count += 1;
                }
				result.append(HTMLGenerateDivOfClass(entry, "r_stl_entry"));
                last_cell_count += 1;
                
                intra_j += 1;
			}
			
            result.append("</div>");
            intra_i += 1;
		}
        result.append("</div>");
	}
	return result.to_string();
}

string HTMLGenerateSimpleTableLines(string [int][int] lines)
{
    return HTMLGenerateSimpleTableLines(lines, true);
}

string HTMLGenerateElementSpan(element e, string additional_text, boolean desaturated)
{
    string line = e;
    if (additional_text != "")
        line += " " + additional_text;
    return HTMLGenerateSpanOfClass(line, "r_element_" + e + (desaturated ? "_desaturated" : ""));
}

string HTMLGenerateElementSpan(element e, string additional_text)
{
    return HTMLGenerateElementSpan(e, additional_text, false);
}
string HTMLGenerateElementSpanDesaturated(element e, string additional_text)
{
    return HTMLGenerateElementSpan(e, additional_text, true);
}
string HTMLGenerateElementSpanDesaturated(element e)
{
    return HTMLGenerateElementSpanDesaturated(e, "");
}


//Allows error checking. The intention behind this design is Errors are passed in to a method. The method then sets the error if anything went wrong.
record Error
{
	boolean was_error;
	string explanation;
};

Error ErrorMake(boolean was_error, string explanation)
{
	Error err;
	err.was_error = was_error;
	err.explanation = explanation;
	return err;
}

Error ErrorMake()
{
	return ErrorMake(false, "");
}

void ErrorSet(Error err, string explanation)
{
	err.was_error = true;
	err.explanation = explanation;
}

void ErrorSet(Error err)
{
	ErrorSet(err, "Unknown");
}

//Coordinate system is upper-left origin.

int INT32_MAX = 2147483647;



float clampf(float v, float min_value, float max_value)
{
	if (v > max_value)
		return max_value;
	if (v < min_value)
		return min_value;
	return v;
}

float clampNormalf(float v)
{
	return clampf(v, 0.0, 1.0);
}

int clampi(int v, int min_value, int max_value)
{
	if (v > max_value)
		return max_value;
	if (v < min_value)
		return min_value;
	return v;
}

float clampNormali(int v)
{
	return clampi(v, 0, 1);
}

//random() will halt the script if range is <= 1, which can happen when picking a random object out of a variable-sized list.
//There's also a hidden bug where values above 2147483647 will be treated as zero.
int random_safe(int range)
{
	if (range < 2 || range > 2147483647)
		return 0;
	return random(range);
}

float randomf()
{
    return random_safe(2147483647).to_float() / 2147483647.0;
}

//to_int will print a warning, but not halt, if you give it a non-int value.
//This function prevents the warning message.
//err is set if value is not an integer.
int to_int_silent(string value, Error err)
{
    //to_int() supports floating-point values. is_integer() will return false.
    //So manually strip out everything past the dot.
    //We probably should just ask for to_int() to be silent in the first place.
    int dot_position = value.index_of(".");
    if (dot_position != -1 && dot_position > 0) //two separate concepts - is it valid, and is it past the first position. I like testing against both, for safety against future changes.
    {
        value = value.substring(0, dot_position);
    }
    
	if (is_integer(value))
        return to_int(value);
    ErrorSet(err, "Unknown integer \"" + value + "\".");
	return 0;
}

int to_int_silent(string value)
{
	return to_int_silent(value, ErrorMake());
}

//Silly conversions in case we chose the wrong function, removing the need for a int -> string -> int hit.
int to_int_silent(int value)
{
    return value;
}

int to_int_silent(float value)
{
    return value;
}


float sqrt(float v, Error err)
{
    if (v < 0.0)
    {
        ErrorSet(err, "Cannot take square root of value " + v + " less than 0.0");
        return -1.0; //mathematically incorrect, but prevents halting. should return NaN
    }
	return square_root(v);
}

float sqrt(float v)
{
    return sqrt(v, ErrorMake());
}

float fabs(float v)
{
    if (v < 0.0)
        return -v;
    return v;
}

int abs(int v)
{
    if (v < 0)
        return -v;
    return v;
}

int ceiling(float v)
{
	return ceil(v);
}

int pow2i(int v)
{
	return v * v;
}

float pow2f(float v)
{
	return v * v;
}

//x^p
float powf(float x, float p)
{
    return x ** p;
}

//x^p
int powi(int x, int p)
{
    return x ** p;
}

record Vec2i
{
	int x; //or width
	int y; //or height
};

Vec2i Vec2iMake(int x, int y)
{
	Vec2i result;
	result.x = x;
	result.y = y;
	
	return result;
}

Vec2i Vec2iCopy(Vec2i v)
{
    return Vec2iMake(v.x, v.y);
}

Vec2i Vec2iZero()
{
	return Vec2iMake(0,0);
}

boolean Vec2iValueInRange(Vec2i v, int value)
{
    if (value >= v.x && value <= v.y)
        return true;
    return false;
}

record Vec2f
{
	float x; //or width
	float y; //or height
};

Vec2f Vec2fMake(float x, float y)
{
	Vec2f result;
	result.x = x;
	result.y = y;
	
	return result;
}

Vec2f Vec2fCopy(Vec2f v)
{
    return Vec2fMake(v.x, v.y);
}

Vec2f Vec2fZero()
{
	return Vec2fMake(0.0, 0.0);
}

boolean Vec2fValueInRange(Vec2f v, float value)
{
    if (value >= v.x && value <= v.y)
        return true;
    return false;
}


record Rect
{
	Vec2i min_coordinate;
	Vec2i max_coordinate;
};

Rect RectMake(Vec2i min_coordinate, Vec2i max_coordinate)
{
	Rect result;
	result.min_coordinate = Vec2iCopy(min_coordinate);
	result.max_coordinate = Vec2iCopy(max_coordinate);
	return result;
}

Rect RectCopy(Rect r)
{
    return RectMake(r.min_coordinate, r.max_coordinate);
}

Rect RectMake(int min_x, int min_y, int max_x, int max_y)
{
	return RectMake(Vec2iMake(min_x, min_y), Vec2iMake(max_x, max_y));
}

Rect RectZero()
{
	return RectMake(Vec2iZero(), Vec2iZero());
}


void listAppend(Rect [int] list, Rect entry)
{
	int position = list.count();
	while (list contains position)
		position += 1;
	list[position] = entry;
}

//Allows for fractional digits, not just whole numbers. Useful for preventing "+233.333333333333333% item"-type output.
//Outputs 3.0, 3.1, 3.14, etc.
float round(float v, int additional_fractional_digits)
{
	if (additional_fractional_digits < 1)
		return v.round().to_float();
	float multiplier = powf(10.0, additional_fractional_digits);
	return to_float(round(v * multiplier)) / multiplier;
}

//Similar to round() addition above, but also converts whole float numbers into integers for output
string roundForOutput(float v, int additional_fractional_digits)
{
	v = round(v, additional_fractional_digits);
	int vi = v.to_int();
	if (vi.to_float() == v)
		return vi.to_string();
	else
		return v.to_string();
}


float floor(float v, int additional_fractional_digits)
{
	if (additional_fractional_digits < 1)
		return v.floor().to_float();
	float multiplier = powf(10.0, additional_fractional_digits);
	return to_float(floor(v * multiplier)) / multiplier;
}

string floorForOutput(float v, int additional_fractional_digits)
{
	v = floor(v, additional_fractional_digits);
	int vi = v.to_int();
	if (vi.to_float() == v)
		return vi.to_string();
	else
		return v.to_string();
}


float TriangularDistributionCalculateCDF(float x, float min, float max, float centre)
{
    //piecewise function:
    if (x < min) return 0.0;
    else if (x > max) return 1.0;
    else if (x >= min && x <= centre)
    {
        float divisor = (max - min) * (centre - min);
        if (divisor == 0.0)
            return 0.0;
        
        return pow2f(x - min) / divisor;
    }
    else if (x <= max && x > centre)
    {
        float divisor = (max - min) * (max - centre);
        if (divisor == 0.0)
            return 0.0;
        
            
        return 1.0 - pow2f(max - x) / divisor;
    }
    else //probably only happens with weird floating point values, assume chance of zero:
        return 0.0;
}

//assume a centre equidistant from min and max
float TriangularDistributionCalculateCDF(float x, float min, float max)
{
    return TriangularDistributionCalculateCDF(x, min, max, (min + max) * 0.5);
}

float averagef(float a, float b)
{
    return (a + b) * 0.5;
}

boolean numberIsInRangeInclusive(int v, int min, int max)
{
    if (v < min) return false;
    if (v > max) return false;
    return true;
}


buffer to_buffer(string str)
{
	buffer result;
	result.append(str);
	return result;
}

buffer copyBuffer(buffer buf)
{
    buffer result;
    result.append(buf);
    return result;
}

//split_string returns an immutable array, which will error on certain edits
//Use this function - it converts to an editable map.
string [int] split_string_mutable(string source, string delimiter)
{
	string [int] result;
	string [int] immutable_array = split_string(source, delimiter);
	foreach key in immutable_array
		result[key] = immutable_array[key];
	return result;
}

//This returns [] for empty strings. This isn't standard for split(), but is more useful for passing around lists. Hacky, I suppose.
string [int] split_string_alternate(string source, string delimiter)
{
    if (source.length() == 0)
        return listMakeBlankString();
    return split_string_mutable(source, delimiter);
}

string slot_to_string(slot s)
{
    if (s == $slot[acc1] || s == $slot[acc2] || s == $slot[acc3])
        return "accessory";
    else if (s == $slot[sticker1] || s == $slot[sticker2] || s == $slot[sticker3])
        return "sticker";
    else if (s == $slot[folder1] || s == $slot[folder2] || s == $slot[folder3] || s == $slot[folder4] || s == $slot[folder5])
        return "folder";
    else if (s == $slot[fakehand])
        return "fake hand";
    else if (s == $slot[crown-of-thrones])
        return "crown of thrones";
    else if (s == $slot[buddy-bjorn])
        return "buddy bjorn";
    return s;
}

string slot_to_plural_string(slot s)
{
    if (s == $slot[acc1] || s == $slot[acc2] || s == $slot[acc3])
        return "accessories";
    else if (s == $slot[hat])
        return "hats";
    else if (s == $slot[weapon])
        return "weapons";
    else if (s == $slot[off-hand])
        return "off-hands";
    else if (s == $slot[shirt])
        return "shirts";
    else if (s == $slot[back])
        return "back items";
    
    return s.slot_to_string();
}


string format_today_to_string(string desired_format)
{
    return format_date_time("yyyyMMdd", today_to_string(), desired_format);
}


string [int] __int_to_wordy_map;
string int_to_wordy(int v) //Not complete, only supports a handful:
{
    if (__int_to_wordy_map.count() == 0)
    {
        __int_to_wordy_map = split_string("zero,one,two,three,four,five,six,seven,eight,nine,ten,eleven,twelve,thirteen,fourteen,fifteen,sixteen,seventeen,eighteen,nineteen,twenty,twenty-one,twenty-two,twenty-three,twenty-four,twenty-five,twenty-six,twenty-seven,twenty-eight,twenty-nine,thirty,thirty-one", ",");
    }
    if (__int_to_wordy_map contains v)
        return __int_to_wordy_map[v];
    return v.to_string();
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

boolean stringHasSuffix(string s, string suffix)
{
	if (s.length() < suffix.length())
		return false;
	else if (s.length() == suffix.length())
		return (s == suffix);
	else if (substring(s, s.length() - suffix.length()) == suffix)
		return true;
	return false;
}

string capitaliseFirstLetter(string v)
{
	buffer buf = v.to_buffer();
	if (v.length() <= 0)
		return v;
	buf.replace(0, 1, buf.char_at(0).to_upper_case());
	return buf.to_string();
}

string pluralise(float value, string non_plural, string plural)
{
	if (value == 1.0)
		return value + " " + non_plural;
	else
		return value + " " + plural;
}

string pluralise(int value, string non_plural, string plural)
{
	if (value == 1)
		return value + " " + non_plural;
	else
		return value + " " + plural;
}

string pluralise(int value, item i)
{
	return pluralise(value, i.to_string(), i.plural);
}

string pluralise(item i) //whatever we have around
{
	return pluralise(i.available_amount(), i);
}

string pluralise(effect e)
{
    return pluralise(e.have_effect(), "turn", "turns") + " of " + e;
}

string pluraliseWordy(int value, string non_plural, string plural)
{
	if (value == 1)
    {
        if (non_plural == "more time") //we're gonna celebrate
            return "One More Time";
        else if (non_plural == "more turn")
            return "One More Turn";
		return value.int_to_wordy() + " " + non_plural;
    }
	else
		return value.int_to_wordy() + " " + plural;
}

string pluraliseWordy(int value, item i)
{
	return pluraliseWordy(value, i.to_string(), i.plural);
}

string pluraliseWordy(item i) //whatever we have around
{
	return pluraliseWordy(i.available_amount(), i);
}


//Additions to standard API:
//Auto-conversion property functions:
boolean get_property_boolean(string property)
{
	return get_property(property).to_boolean();
}

int get_property_int(string property)
{
	return get_property(property).to_int_silent();
}

location get_property_location(string property)
{
	return get_property(property).to_location();
}

float get_property_float(string property)
{
	return get_property(property).to_float();
}

monster get_property_monster(string property)
{
	return get_property(property).to_monster();
}

//Returns true if the propery is equal to my_ascensions(). Commonly used in mafia properties.
boolean get_property_ascension(string property)
{
    return get_property_int(property) == my_ascensions();
}

element get_property_element(string property)
{
    return get_property(property).to_element();
}

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

//Due to how relay scripts operate, we theoretically could have this script running simultaneously with another.
//We'll use a "locking" mechanism based off of properties and gametime_to_int() to prevent them from interfering.
//A lock on a briefcase... how absurd!

string __lock_property_name = "_kgbriefcase_lock_time";
boolean __lock_gained = false;

int __last_time_set = -1;
void gainActionLock()
{
    if (__lock_gained)
        return;
    while (get_property(__lock_property_name) != "")
    {
        int time = get_property_int(__lock_property_name);
        int delta = gametime_to_int() - time;
        if (delta > 15 * 1000 || delta < -1000)
        {
            printSilent("Assuming script timeout, executing...");
            break;
        }
        waitq(1);
    }
    //printSilent("Gain lock.");
    int time = gametime_to_int();
    set_property(__lock_property_name, time);
    __last_time_set = time;
    
    __lock_gained = true;
}

boolean lockIsUsedBySomeoneElse()
{
    if (__lock_gained)
        return false;
    if (get_property(__lock_property_name) != "")
        return true;
    return false;
}

void releaseActionLock()
{
    if (!__lock_gained)
        return;
    //printSilent("Release lock.");
    __lock_gained = false;
    if (get_property_int(__lock_property_name) == __last_time_set)
        set_property(__lock_property_name, "");
    __last_time_set = -1;
}

//All actions update lock time, if needed. This allows us to lower the breakout time threshold.
void updateLockTime()
{
    if (!__lock_gained)
        return;
    if (gametime_to_int() - get_property_int(__lock_property_name) > 5 * 1000 && get_property_int(__lock_property_name) == __last_time_set)
    {
        int time = gametime_to_int();
        set_property(__lock_property_name, time);
        __last_time_set = time;
    }
    
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
    boolean case_opening_unlocked; //strictly speaking, not needed, since sixth light
	
	boolean handle_up;
	
	int antennae_charge;
	int lightrings_number; //0 for none
	
	boolean [string] last_action_results;
    
    boolean know_last_was_moving;
    boolean last_action_was_moving;
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
    if (state.case_opening_unlocked)
		things_unlocked.listAppend("opening case");
    
	
    if (things_unlocked.count() > 0)
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
    state.case_opening_unlocked = page_text.contains_text("place.php?whichplace=kgb&action=kgb_daily");
	
	
	
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
			logprint("KGBRIEFCASEDEBUG: Click!");
		__file_state["_clicks"] =__file_state["_clicks"].to_int() + 1;
		writeFileState();
	}
	if (state.last_action_results["Click click click!"])
	{
		if (my_id() == 1557284)
			logprint("KGBRIEFCASEDEBUG: Click click click!");
		__file_state["_clicks"] =__file_state["_clicks"].to_int() + 3;
		writeFileState();
	}
	if (state.last_action_results["Nothing happens. Hmm. Maybe it's out of... clicks?  For the day?"])
	{
		if (my_id() == 1557284)
			logprint("KGBRIEFCASEDEBUG: Out of... clicks? For the day?");
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
                state.know_last_was_moving = true;
                state.last_action_was_moving = true;
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
                state.know_last_was_moving = true;
                state.last_action_was_moving = true;
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
void actionSetDialsTo(int [int] dial_configuration)
{
    updateLockTime();
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


void actionVisitBriefcase(boolean silence)
{
    updateLockTime();
    if (!silence)
        printSilent("Loading briefcase...", "gray");
	updateState(visit_url("place.php?whichplace=kgb", false, false));
}

void actionVisitBriefcase()
{
    actionVisitBriefcase(false);
}

void actionPressLeftActuator()
{
    updateLockTime();
	printSilent("Clicking left actuator...", "gray");
	if (__setting_confirm_actions_that_will_use_a_click && !user_confirm("READY?"))
		abort("Aborted.");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_actuator1", false, false), ACTION_TYPE_LEFT_ACTUATOR, -1);
}

void actionPressRightActuator()
{
    updateLockTime();
	printSilent("Clicking right actuator...", "gray");
	if (__setting_confirm_actions_that_will_use_a_click && !user_confirm("READY?"))
		abort("Aborted.");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_actuator2", false, false), ACTION_TYPE_RIGHT_ACTUATOR, -1);
}

void actionManipulateHandle()
{
    updateLockTime();
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
    updateLockTime();
	printSilent("Turning crank.", "gray");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_crank", false, false));
}

void actionPressButton(int button_id) //1 through 6
{
    if (button_id < 1 || button_id > 6) return;
    updateLockTime();
    
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
    updateLockTime();
	printSilent("Clicking tab " + tab_id + ".", "gray");
	if (__setting_confirm_actions_that_will_use_a_click && !user_confirm("READY?"))
		abort("Aborted.");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_tab" + tab_id, false, false), ACTION_TYPE_TAB, tab_id);
}

void actionCollectLeftDrawer()
{
    updateLockTime();
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
    updateLockTime();
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
    updateLockTime();
	printSilent("Collecting from martini hose.", "gray");
	updateState(visit_url("place.php?whichplace=kgb&action=kgb_dispenser", false, false));
	if (__state.last_action_results["Hmm.  Nothing happens.  Looks like it's out of juice for today."])
	{
		__file_state["_martini hose collected"] = 3;
		writeFileState();
	}
}


boolean testTabsAreMoving()
{
    if (__state.horizontal_light_states[3] == LIGHT_STATE_ON)
    {
        int [int] previous_tab_permutation = __state.tab_configuration.listCopy();
        actionVisitBriefcase();
        
        if (!configurationsAreEqual(previous_tab_permutation, __state.tab_configuration))
            return true;
    }
    return false;
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
			states_already_tested = states_already_tested_right;
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
			if (number_of_distinct_values > picked_choice_distinct_values || picked_choice.count() == 0)
			{
				picked_choice = dials;
				picked_choice_distinct_values = number_of_distinct_values;
				if (picked_choice_distinct_values >= 3 && false)
					break;
			}
		}
		if (picked_choice.count() == 0)
		{
			printSilent("Unable to solve mastermind, out of choices. " + number_of_valid_states + " valid states.");
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
		printSilent("addNumberToTabConfiguration(" + configuration.listJoinComponents("") + "," + amount + ", " + permutation.listJoinComponents("") + ")");
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
			/*if (permutation[0] == 5 && permutation[1] == 0 && permutation[2] == 2 && permutation[3] == 4 && permutation[4] == 3 && permutation[5] == 1 && button_function_id == 5)
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
        {
			state_transition.tabs_were_moving = entry[3].to_boolean();
            if (state_transition.tabs_were_moving && state_transitions.count() > 0)
            {
                TabStateTransition last_state_transition = state_transitions[state_transitions.count() - 1];
                if (configurationsAreEqual(state_transition.before_tab_configuration, last_state_transition.after_tab_configuration) && !last_state_transition.tabs_were_moving)
                {
                    //They (probably) hit the target number - which is a special case, so it's not moving yet. This is a hack, but, umm... kind of one that's impossible to avoid?
                    state_transition.tabs_were_moving = false;
                }
            }
        }
		
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
						printSilent(key + ", " + key2 + ", " + key3 + " is valid");
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
	printSilent("<strong>solve</strong> - unlocks everything we know how to unlock, also solves puzzles. <strong>You may want the \"unlock\" command instead.</strong>");
	printSilent("");
	printSilent("<strong>drawers</strong> or <strong>left</strong> or <strong>right</strong> - unlocks all/left/right drawers");
	printSilent("<strong>hose</strong> - unlocks martini hose");
	printSilent("<strong>drink</strong> or <strong>collect</strong> - acquires three splendid martinis and other dailies");
	printSilent("");
    printSilent("Unimportant commands:");
	printSilent("<strong>charge</strong> - charges flywheel (most commands do this automatically)");
	printSilent("<strong>second</strong> or <strong>third</strong> - lights respective light");
	printSilent("<strong>identify</strong> - identifies the tab function of all six buttons");
	printSilent("<strong>reset</strong> - resets the briefcase");
    printSilent("<strong>stop</strong> - stops moving tabs");
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
int [int] discoverTabPermutation(boolean allow_actions, boolean only_try_once)
{
	if (__file_state["tab permutation"] != "") return stringToIntIntList(__file_state["tab permutation"]);
    unlockButtons();
	actionSetHandleTo(true);
	int breakout = 111;
    boolean trying_negative = false;
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
        if (__state.tab_configuration[0] == 0 && __state.tab_configuration[1] == 0 && __state.tab_configuration[2] == 0 && __state.tab_configuration[3] == 0 && __state.tab_configuration[4] == 0 && __state.tab_configuration[5] == 0)
            trying_negative = false;
		if (two_count >= 5 || trying_negative) //the number is almost certainly too high
        {
			chosen_function_id_to_use = 2; //-10. not ideal, but prevents ping-ponging
            trying_negative = true;
        }
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
			abort("Internal error while discovering tab permutation, not sure what to do next. Try the command \"briefcase clear\"?");
			int [int] blank;
			return blank;
		}
		//abort("next_chosen_button = " + next_chosen_button);
		if (!allow_actions)
			break;
        actionSetHandleTo(true);
		actionPressButton(next_chosen_button + 1);
        if (only_try_once)
            break;
		//break;
		//abort("write me " + next_chosen_button);
	}
	
	if (__file_state["tab permutation"] != "") return stringToIntIntList(__file_state["tab permutation"]);
	int [int] blank;
	return blank;
}

int [int] discoverTabPermutation(boolean allow_actions)
{
    return discoverTabPermutation(allow_actions, false);
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

void setTabsToNumber(int desired_base_ten_number, boolean only_press_once, boolean [int] other_allowed_numbers)
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
        if (other_allowed_numbers[current_number])
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
    boolean [int] blank;
    setTabsToNumber(desired_base_ten_number, only_press_once, blank);
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
		//printSilent(entry.lightrings_id + " on " + entry.tab_configuration.listJoinComponents(", "));
	}
	//printSilent("lightrings_entries = " + lightrings_entries.to_json());

    //lightrings id -> monotonic key -> tab configurations
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
	{{{-1000, -101}, {101, 1000}},
	{{-100, -76}, {76, 100}},
	{{-75, -51}, {51, 75}},
	{{-50, -26}, {26, 50}},
	{{-25, -11}, {11, 25}},
	{{-10, -6}, {6, 10}},
	{{-5, 5}}};
	//printSilent("lightrings_range_modifications = " + lightrings_range_modifications.to_json());
	
	for lightrings_id from 0 to 6
	{
		foreach i in lightrings_seen_values[lightrings_id]
		{
			int [int] tab_configuration = lightrings_seen_values[lightrings_id][i];
			int base_ten = convertTabConfigurationToBase10(tab_configuration, permutation);
            //printSilent("base_ten = " + base_ten);
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
                //if (!is_valid && possible_lightrings_numbers[answer])
                    //printSilent(base_ten + " invalidating " + answer);
				if (!is_valid)
                {
					possible_lightrings_numbers[answer] = false;
                }
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
	//printSilent("possible_lightrings_answers_final (" + possible_lightrings_answers_final.count() + ") = " + possible_lightrings_answers_final.listJoinComponents(", "));
	return possible_lightrings_answers_final;
}

void lightThirdLight(boolean try_to_reach_moving_tabs_regardless)
{
	if (__state.horizontal_light_states[3] == LIGHT_STATE_ON && !try_to_reach_moving_tabs_regardless) return;
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
	while (!__file_state["_out of clicks for the day"].to_boolean() && (__state.horizontal_light_states[3] != LIGHT_STATE_ON || (try_to_reach_moving_tabs_regardless && !testTabsAreMoving())) && breakout > 0)
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
        //Pick the one nearest to us:
        int picked_number = -1;
        int picked_path_length = -1;
        int current_number_base_ten = convertTabConfigurationToBase10(__state.tab_configuration, stringToIntIntList(__file_state["tab permutation"]));
        foreach key, value in possible_lightrings_values
        {
            int length = computePathLengthToNumber(value, current_number_base_ten);
            if (picked_number == -1 || picked_path_length > length)
            {
                picked_number = value;
                picked_path_length = length;
            }
        }
		setTabsToNumber(picked_number, true);
	}
	if ((__state.horizontal_light_states[3] != LIGHT_STATE_ON || (try_to_reach_moving_tabs_regardless && !testTabsAreMoving())) && __file_state["_out of clicks for the day"].to_boolean())
	{
		printSilent("Can't solve yet, out of clicks for the day.");
	}
}

void lightThirdLight()
{
    lightThirdLight(false);
}
void useMovingTabsToReachValidNumbers(boolean [int] using_valid_numbers, int [int] tab_permutation)
{
    //!(using_valid_numbers contains convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation))
    int starting_number = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
    //Tabs may be moving, visit briefcase a bit to change to valid state?
    int smallest_delta = -1;
    foreach valid_number in using_valid_numbers
    {
        if (valid_number >= starting_number) continue;
        int delta = starting_number - valid_number;
        if (smallest_delta == -1 || delta < smallest_delta)
            smallest_delta = delta;
    }
    
    if (smallest_delta < 55 && smallest_delta > 0)
    {
        //printSilent("smallest_delta = " + smallest_delta);
        for i from 1 to smallest_delta
        {
            if (using_valid_numbers contains convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation))
                break;
            int before = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
            actionVisitBriefcase();
            int now = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
            //printSilent("before = " + before + " now = " + now);
            if (convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation) == starting_number) //not moving
                break;
        }
    }
}

int MARTINI_TYPE_BASIC = 1;
int MARTINI_TYPE_IMPROVED = 2;
int MARTINI_TYPE_SPLENDID = 3;

void collectMartinis(int martini_type, boolean should_take_action)
{
	//FIXME don't do this if we don't have enough clicks for the day to finish?
	if (__file_state["_martini hose collected"].to_int() >= 3)
	{
		printSilent("Already collected from the hose today.");
		return;
	}
    if (martini_type == MARTINI_TYPE_BASIC)
    {
        if (should_take_action)
        {
            unlockMartiniHose();
            for i from 1 to 3
            {
                if (__file_state["_martini hose collected"].to_int() >= 3)
                    break;
                actionCollectMartiniHose();
            }
        }
        return;
    }
    if (martini_type != MARTINI_TYPE_SPLENDID)
    {
        //Improved is not tab sum of 5. Tab sum of 6 is valid.
        abort("not yet implemented");
        return;
    }
    if (should_take_action)
    {
        unlockMartiniHose();
        discoverButtonWithFunctionID(5); //100
    }
    
    int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
    
    boolean [int] valid_splendid_numbers = $ints[485, 647, 701, 719, 725, 727, 728];
    boolean [int] valid_splendid_numbers_moving;
    foreach value in valid_splendid_numbers
    {
        if (value < 728)
            valid_splendid_numbers_moving[value + 1] = true;
    }
    
	for i from 1 to 3
	{
		if (__file_state["_martini hose collected"].to_int() >= 3)
			break;
        
        boolean [int] using_valid_numbers = valid_splendid_numbers;
        
        //if (__state.horizontal_light_states[3] == LIGHT_STATE_ON && !(using_valid_numbers contains convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation)))
        if (testTabsAreMoving())
        {
            using_valid_numbers = valid_splendid_numbers_moving;
            useMovingTabsToReachValidNumbers(using_valid_numbers, tab_permutation);
        }
        if (!(using_valid_numbers contains convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation)) && should_take_action)
        {
            boolean [int] using_valid_numbers_extra;
            foreach v in using_valid_numbers
                using_valid_numbers_extra[v] = true;
            using_valid_numbers_extra[727] = true; //looper stop looping
            setTabsToNumber(728, false, using_valid_numbers_extra);
            if ((__state.know_last_was_moving && __state.last_action_was_moving) || (!__state.know_last_was_moving && testTabsAreMoving()))
            {
                using_valid_numbers = valid_splendid_numbers_moving;
                useMovingTabsToReachValidNumbers(using_valid_numbers, tab_permutation);
            }
        }
        //Tabs can be moving here when they weren't before.
		int current_number = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
		if (using_valid_numbers contains current_number)
		{
			actionCollectMartiniHose();
		}
		else
		{
            if (should_take_action)
                printSilent("Can't collect splendid martinis. Maybe out of clicks?", "red");
			return;
		}
        //abort("well?");
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
    
    //So, caching!
    //If clicks haven't changed since last view, we probably are the same.
    int clicks_used = get_property_int("_kgbClicksUsed");
    if ((__file_state contains "_enhancements_cache_clicks_used") && __file_state["_enhancements_cache_clicks_used"].to_int() == clicks_used)
    {
        //Parse and return:
        foreach key, value in __file_state["_enhancements_cache"].split_string(",")
        {
            __briefcase_enchantments[key] = value.to_int();
        }
        return;
    }
    
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
    else
    {
        //Cache!
        __file_state["_enhancements_cache_clicks_used"] = clicks_used;
        __file_state["_enhancements_cache"] = __briefcase_enchantments.listJoinComponents(",");
        writeFileState();
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

buffer handleEnchantmentCommand(string command, boolean from_relay)
{
    buffer out;
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
        if (__file_state["_out of clicks for the day"].to_boolean())
        {
            if (!from_relay)
                printSilent("Out of clicks for the day.");
            out.append(HTMLGenerateSpanFont("Unable to change enchantment, out of clicks for the day.", "red"));
            return out;
        }
        if (!from_relay)
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
			else if (word == "-combat" || word == "minuscombat")
				desired_slot_configuration[2] = 3;
			else if (word == "+combat" || word == "pluscombat")
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
            if (__briefcase_enchantments[slot_id] == id)
            {
                out.append("Enchantment changed.");
            }
            else
            {
                out.append(HTMLGenerateSpanFont("Unable to reach desired enchantment.", "red"));
            }
		}
	}
    return out;
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

int computeBestTargetNumberForTab(int tab_id, int tab_length, boolean [int][int] tabs_known, boolean allow_action)
{
    discoverTabPermutation(allow_action); //we absolutely need this
    if (__file_state["tab permutation"] == 0)
        return -1;
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
    int breakout = 111;
    while (__state.tab_configuration[tab_id] != tab_length && breakout > 0 && !__file_state["_out of clicks for the day"].to_boolean())
    {
        breakout -= 1;
        boolean [int][int] tabs_known;
        int best_found_target_number = computeBestTargetNumberForTab(tab_id, tab_length, tabs_known, true);
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
        if (__file_state["tab permutation"] == "") //just guess, don't discover tab permutation
            clicks_to_reach = 5;
        else
        {
            int best_target_number = computeBestTargetNumberForTab(t.id, t.length, tabs_known, true);
            int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
            int current_briefcase_number = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
            clicks_to_reach = computePathLengthToNumber(best_target_number, current_briefcase_number);
        }
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

buffer handleBuffCommand(string command, boolean from_relay)
{
    buffer out;
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
        if (!from_relay)
            outputStatus();
		chargeFlywheel();
		unlockButtons();
		actionSetHandleTo(true); //this needs to be somewhere else
        
        if (testTabsAreMoving())
        {
            //This could theoreticaly be supported, but it would be complicated.
            if (!from_relay)
                printSilent("Buff command disabled while tabs are moving. Try \"briefcase stop\".");
            else
                out.append(HTMLGenerateSpanFont("Buff command disabled while tabs are moving.", "red"));
            return out;
        }
        //For computing deltas (have we gained this buff already)
        int [effect] starting_effect_count;
        foreach e in __spy_effect_to_buff_id
        {
            starting_effect_count[e] = e.have_effect();
        }
        int [effect] desired_buffs;
        effect [int] desired_buffs_linear;
        boolean last_was_all = false;
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
            else if (word == "all")
            {
                last_was_all = true;
                continue;
            }
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
            desired_buffs[desired_buff] += 1;
            desired_buffs_linear.listAppend(desired_buff);
            if (last_was_all)
            {
                for i from 1 to 6
                {
                    desired_buffs[desired_buff] += 1;
                    desired_buffs_linear.listAppend(desired_buff);
                }
            }
        }
        foreach key, desired_buff in desired_buffs_linear
        {
            if (desired_buff.have_effect() >= starting_effect_count[desired_buff] + 50 * desired_buffs[desired_buff]) //already happened
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
            int breakout = 35;
			while (!__file_state["_out of clicks for the day"].to_boolean() && breakout > 0)
            {
                if (desired_buff.have_effect() >= starting_effect_count[desired_buff] + 50 * desired_buffs[desired_buff]) //we found it somehow, maybe the random tab
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
                
                calculateTabs();
                if (__file_state["tab permutation"] == "")
                {
                    //We don't know our tab permutation yet.
                    //We could waste time discovering it...
                    //But instead, let's just press a button that might be +100? Umm. Only if we aren't near the max... this is so hard.
                    if (__state.tab_configuration[0] == 2 && __state.tab_configuration[1] == 2 && __state.tab_configuration[2] == 2 && __state.tab_configuration[3] == 2 && __state.tab_configuration[4] == 2 && __state.tab_configuration[5] == 2) //We're at max, we give up, please discover the tabs for us.
                        discoverTabPermutation(true);
                    else
                    {
                        //Find a +100 button and button press:
                        //discoverButtonWithFunctionID() currently requires knowledge of tab permutations.
                        //So, umm...
                        discoverTabPermutation(true, true); //only do one action while discovering tab permutation maybe...?
                    }
                    continue;
                }
                //discoverTabPermutation(true);
                
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
                    return out;
                }
                printSilent("Best found target number: " + best_found_target_number + " unlocking " + best_found_tabs_at_final + " tabs of path length " + best_found_path_length + ".");
                setTabsToNumber(best_found_target_number, true); //only press once, because if we discover the wrong button, maybe we'll find a new one...?
            }
        }
            
        int [effect] delta_effects;
        foreach e in __spy_effect_to_buff_id
        {
            int delta = e.have_effect() - starting_effect_count[e];
            if (delta > 0)
                delta_effects[e] = delta;
        }
        string [int] buffs_gained_description;
        foreach e in desired_buffs
        {
            if (delta_effects[e] == 0)
                out.append(HTMLGenerateSpanFont("Unable to gain buff " + e + ".", "red"));
            else
                buffs_gained_description.listAppend(e + " (" + delta_effects[e] + " turns)");
        }
        if (buffs_gained_description.count() > 0)
            out.append("Gained " + buffs_gained_description.listJoinComponents(", ", "and") + ".");
	}
	return out;
}
void lightLastLights()
{
    if (__state.horizontal_light_states[6] == LIGHT_STATE_ON)
        return;
    lightSecondLight();
    lightThirdLight();
    if (__state.horizontal_light_states[2] != LIGHT_STATE_ON || __state.horizontal_light_states[3] != LIGHT_STATE_ON || __state.horizontal_light_states[1] != LIGHT_STATE_ON)
    {
        printSilent("Need the second and third lights solved first.");
        return;
    }
    //Make sure tabs are moving:
    //Discover moving tabs number:
    if (__file_state["lightrings target number"] == "")
    {
        //Are tabs moving? No? Then we still have a problem.
        int breakout = 400;
        while (testTabsAreMoving() && __file_state["lightrings target number"] == "" && breakout > 0)
        {
            breakout -= 1;
            calculatePossibleLightringsValues(false, false);
        }
        if (__file_state["lightrings target number"] == "")
        {
            printSilent("Running experimental untested code.");
            lightThirdLight(true);
        }
    }
    if (__file_state["lightrings target number"] == "")
    {
        printSilent("Unable to discover lightrings target number, wait until tomorrow.");
        return;
    }
    int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
    
    //Try to reach just above that:
    int target_lightrings_number = __file_state["lightrings target number"].to_int();
    int starting_number_needed = target_lightrings_number + 21; //twenty is a guess; in reality it's... 1 + 7 + 4?
    
    //Make sure we're moving:
    if (!testTabsAreMoving())
    {
        setTabsToNumber(target_lightrings_number);
    }
    if (!testTabsAreMoving())
    {
        printSilent("Unable to make tabs move, maybe try again tomorrow?");
        return;
    }
    int breakout = 111;
	actionSetHandleTo(true);
    //We need to be target_lightrings_number + a bunch. Honestly, just press +100 until we're over that number, then refresh until we're down to the correct spot.
    while (convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation) < starting_number_needed && !__file_state["_out of clicks for the day"].to_boolean() && breakout > 0)
    {
        actionPressButton(discoverButtonWithFunctionID(5) + 1);
        breakout -= 1;
    }
    if (convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation) < starting_number_needed)
    {
        printSilent("Unable to reach starting spot, wait until tomorrow.");
        return;
    }
    //Charge antennae until we're in position:
	actionSetHandleTo(false);
    breakout = 300;
    printSilent("Turning crank down to starting position. This may take a bit.");
    while (convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation) > target_lightrings_number + 4 && breakout > 0)
    {
        breakout -= 1;
        actionTurnCrank();
    }
    if (convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation) != target_lightrings_number + 4)
    {
        printSilent("Internal error, unable to open, sorry.");
        return;
    }
    //R-e-s-e-t:
    actionManipulateHandle();
    actionManipulateHandle();
    actionManipulateHandle();
    actionManipulateHandle();
    
}

void recalculateVarious()
{
	calculateTabs();
	if (__file_state["lightrings target number"] == "" && __file_state["lightrings observed"] != "")
		calculatePossibleLightringsValues(false, false);
}

void collectOnceDailies()
{
    //Will collect splendid martinis, if we can with no cost.
    
	//Collect drawers:
	if (__state.left_drawer_unlocked && !__file_state["_left drawer collected"].to_boolean())
	{
		actionCollectLeftDrawer();
	}
	if (__state.right_drawer_unlocked && !__file_state["_right drawer collected"].to_boolean())
	{
		actionCollectRightDrawer();
	}
    if (__state.case_opening_unlocked && !__file_state["_case opened"].to_boolean())
    {
        printSilent("Opening case...", "gray");
        updateState(visit_url("place.php?whichplace=kgb&action=kgb_daily"));
        __file_state["_case opened"] = true;
        writeFileState();
    }
    //So, can we collect martinis?
    if (__state.horizontal_light_states[3] != LIGHT_STATE_ON && __file_state["_martini hose collected"].to_int() < 3)
    {
        collectMartinis(MARTINI_TYPE_SPLENDID, false);
    }
}

buffer executeCommandCore(string command, boolean from_relay)
{
    buffer out;
    if ($item[kremlin's greatest briefcase].item_amount() + $item[kremlin's greatest briefcase].equipped_amount() == 0) //'
	{
        if (from_relay)
            out.append("You don't seem to own a briefcase.");
        else
            printSilent("You don't seem to own a briefcase.");
		return out;
	}
    if (!get_property("svnUpdateOnLogin").to_boolean() && !from_relay)
    {
        printSilent("Consider enabling Preferences>SVN>Update installed SVN projects on login; this script is changing often.");
    }
	//readFileState(); //done already
	
	if (command == "help" || command == "" || command.replace_string(" ", "").to_string() == "")
	{
		if (!__setting_output_help_before_main)
		{
			outputHelp();
		}
		return out;
	}
	if (__setting_output_help_before_main && !from_relay)
	{
		printSilent("");
		printSilent("<hr>");
		printSilent("");
	}
    
    
	
	if (command == "clear")
    {
        boolean yes = user_confirm("Clear your tracking values? This should only be done if the script is erroring.");
        if (!yes)
            return out;
        print("Clearing tracking settings...");
        string [string] blank;
        __file_state = blank;
        writeFileState();
        return out;
    }
	
	actionVisitBriefcase(true);
	recalculateVarious();
	
	if (command == "status")
	{
		outputStatus();
		return out;
	}
	if (command == "discover")
		discoverTabPermutation(true);
	
	//Do things we should always do:
	lightFirstLight();
	
	if (command == "charge" || command == "flywheel")
	{
		chargeFlywheel();
		printSilent("Done.");
		return out;
	}
	if (command == "antennae" || command == "jacobs" || command == "ladder" || command == "jacob")
	{
		chargeAntennae();
		printSilent("Done.");
		return out;
	}
	if (command == "reset")
	{
		boolean yes = user_confirm("Reset the briefcase? Are you sure?");
		if (!yes)
			return out;
		//up (initial) -> down -> up -> down -> up does not reset
		int flips = 4;
		if (__state.handle_up)
			flips = 5;
		for i from 1 to flips
			actionManipulateHandle();
		printSilent("Done.");
		return out;
	}
	if (command.stringHasPrefix("enchantment") || command.stringHasPrefix("e ") || command == "e")
	{
		return handleEnchantmentCommand(command, from_relay);
	}
	
	if (command.stringHasPrefix("buff") || command.stringHasPrefix("b ") || command == "b")
	{
        return handleBuffCommand(command, from_relay);
	}
	
	chargeFlywheel();
	
    if (!from_relay)
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
        if (!can_interact() && !from_relay)
        {
            boolean yes = user_confirm("Are you sure you want to solve the briefcase? You probably want \"unlock\" instead. Or maybe not.");
            if (!yes)
                return out;
        }
		lightSecondLight();
		lightThirdLight();
        lightLastLights();
	}
	if (command == "second" || command == "mastermind")
	{
		lightSecondLight();
	}
	if (command == "third")
	{
		lightThirdLight();
	}
	if (command == "splendid" || command == "epic" || command == "martini" || command == "martinis" || command == "booze" || command == "drink" || command == "drinks" || command == "collect" || command == "splendid martini")
	{
		//Increment tabs to 222222, collect splendid martinis:
		collectMartinis(MARTINI_TYPE_SPLENDID, true);
	}
    if (command == "basic" || command == "basic martini")
    {
        collectMartinis(MARTINI_TYPE_BASIC, true);
    }
    if (command == "improved" || command == "improved martini")
    {
        collectMartinis(MARTINI_TYPE_IMPROVED, true);
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
    if (command == "stop")
    {
        boolean tabs_are_moving = testTabsAreMoving();
        if (tabs_are_moving)
        {
            actionSetHandleTo(true);
            int breakout = 23;
            while (!__file_state["_out of clicks for the day"].to_boolean() && breakout > 0)
            {
                //Press the -100 button over and over again:
                if (__state.tab_configuration.count() == 6 && __state.tab_configuration[0] == 0 && __state.tab_configuration[1] == 0 && __state.tab_configuration[2] == 0 && __state.tab_configuration[3] == 0 && __state.tab_configuration[4] == 0 && __state.tab_configuration[5] == 0)
                    break;
                breakout -= 1;
                actionPressButton(discoverButtonWithFunctionID(4, false, false) + 1);
            }
            tabs_are_moving = testTabsAreMoving();
            if (tabs_are_moving)
                printSilent("Unable to stop tabs.");
            else
                printSilent("Tabs stopped.");
        }
        else
            printSilent("Tabs stopped.");
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
    collectOnceDailies();
    print("Done.");
    return out;
}

buffer executeCommand(string command, boolean from_relay)
{
    gainActionLock();
    buffer result = executeCommandCore(command, from_relay);
    releaseActionLock();
    return result;
}

buffer generateFirstText()
{
    int clicks_remaining = clampi(22 - get_property_int("_kgbClicksUsed"), 0, 22);
    int banishes_remaining = clampi(3 - get_property_int("_kgbTranquilizerDartUses"), 0, 3);
    buffer out;
    
    //out.append("<br>");
    string [int] things_remaining;
    if (clicks_remaining > 0)
        things_remaining.listAppend(clicks_remaining + " click" + (clicks_remaining > 1 ? "s" : ""));
    else if (__file_state["_out of clicks for the day"].to_boolean())
        out.append(HTMLGenerateTagWrap("div", "Out of clicks for the day.", mapMake("class", "r_centre", "style", "color:#FF0000;font-size:1.2em;")));
    else
        things_remaining.listAppend("0? clicks");
    if (banishes_remaining > 0)
        things_remaining.listAppend(banishes_remaining + " banish" + (banishes_remaining > 1 ? "es" : ""));
    if (things_remaining.count() > 0)
        out.append(HTMLGenerateTagWrap("div", things_remaining.listJoinComponents(", ") + " remaining.", mapMake("class", "r_centre", "style", "font-size:1.2em;")));
    out.append("<br>");
    
    buffer out2;
    
    if (__file_state["_martini hose collected"].to_int() < 3 || __setting_debug)
    {
        out2.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table;width:100%;")));
        out2.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-row;")));
        
        //foreach s in $strings[Basic,Improved,Splendid]
        boolean ezandora_is_too_lazy_to_write_improved_martini_code = !__setting_debug;
        for i from 0 to 2
        {
            int item_id = 9494 + i;
            item it = item_id.to_item();
            
            string description = "Mix " + it.plural;
            
            string style = "display:table-cell;width:33%;";
            style += "text-align:center;";
            string command = it.to_string();
            if (i == 0)
            {
                //style += "text-align:right;";
                description += HTMLGenerateSpanOfClass(" (1)", "briefcase_subtext");
            }
            else if (i == 1)
            {
                //style += "text-align:center;";
                description += HTMLGenerateSpanOfClass(" (~8)", "briefcase_subtext");
            }
            else if (i == 2)
            {
                //style += "text-align:left;";
                description += HTMLGenerateSpanOfClass(" (~13)", "briefcase_subtext");
            }
            
            
            if (ezandora_is_too_lazy_to_write_improved_martini_code && it == $item[improved martini])
            {
                out2.append(HTMLGenerateTagPrefix("div", mapMake("style", style)));
                description = "[to be written]";
            }
            else
                out2.append(HTMLGenerateTagPrefix("div", mapMake("style", style, "class", "briefcase_entry briefcase_button", "onclick", "executeBriefcaseCommand('" + command + "');")));
            //out2.append(it.replace_string(" martini", ""));
            out2.append(description);
            out2.append("</div>"); //cell
        }
        out2.append("</div>"); //row
        out2.append("</div>"); //table
    }
    if (!__state.left_drawer_unlocked || __setting_debug)
    {
        out2.append(HTMLGenerateTagWrap("div", "Open left drawer " + HTMLGenerateSpanOfClass("(1)", "briefcase_subtext") + "<br>" + HTMLGenerateSpanOfClass("Three exploding cigars", "briefcase_subtext"), mapMake("class", "r_centre briefcase_entry briefcase_button", "onclick", "executeBriefcaseCommand('left');")));
    }
    if (!__state.right_drawer_unlocked || __setting_debug)
    {
        string reward = "Three exploding cigars";
        if (my_path() == "License to Adventure")
            reward = "Minions-be-gone";
        out2.append(HTMLGenerateTagWrap("div", "Open right drawer " + HTMLGenerateSpanOfClass("(1)", "briefcase_subtext") + "<br>" + HTMLGenerateSpanOfClass(reward, "briefcase_subtext"), mapMake("class", "r_centre briefcase_entry briefcase_button", "onclick", "executeBriefcaseCommand('right');")));
    }
    
    if (!__state.case_opening_unlocked || __setting_debug)
    {
        //out2.append("<br>");
        out2.append(HTMLGenerateTagWrap("div", "Open case" + HTMLGenerateSpanOfClass(" (22)", "briefcase_subtext") + "<br>" + HTMLGenerateSpanOfClass("Takes ~two days", "briefcase_subtext"), mapMake("class", "r_centre briefcase_entry briefcase_button", "onclick", "executeBriefcaseCommand('solve');")));
    }
    if (out2.length() > 0)
    {
        out.append(out2);
        out.append("<hr>");
    }
    return out;
}

buffer generateEnchantmentText()
{
    int clicks_remaining = clampi(22 - get_property_int("_kgbClicksUsed"), 0, 22);
    
    buffer out;
    out.append(HTMLGenerateTagWrap("div", "Enchantments", mapMake("style", "font-size:1.5em;", "class", "r_centre")));
    //out.append(HTMLGenerateTagWrap("div", "1 click per rotation", mapMake("style", "color:" + __setting_light_colour + ";", "class", "r_centre")));
    out.append("<br>");
    out.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table;width:100%;")));
    out.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-row;")));
    
    parseBriefcaseEnchantments();
    
    //Slot, id
    string [int][int] enchantments_description;
    string [int][int] enchantments_commands;
    for i from 0 to 2
    {
        enchantments_description[i] = listMakeBlankString();
        enchantments_commands[i] = listMakeBlankString();
    }
    foreach s in $strings[+25% Weapon Damage,+50% Spell Damage,+5 Prismatic Damage,+10% Critical Hit]
        enchantments_description[0].listAppend(s);
    foreach s in $strings[+25% init,+100 Damage Absorption,+5 Hot res,+5 Cold res,+5 Spooky res,+5 Stench res,+5 Sleaze res]
        enchantments_description[1].listAppend(s);
    foreach s in $strings[+5-10 HP/MP regen,+5 adventures/day,+5 PvP fights/day,-5% combat,+5% combat,+25 ML,-3MP to use skills]
        enchantments_description[2].listAppend(s);
        
    foreach s in $strings[weapon,spell,prismatic,critical]
        enchantments_commands[0].listAppend(s);
    foreach s in $strings[init,absorption,hot,cold,spooky,stench,sleaze]
        enchantments_commands[1].listAppend(s);
    foreach s in $strings[regen,adventures,fights,minuscombat,pluscombat,ml,skills]
        enchantments_commands[2].listAppend(s);
    int [int] display_slot_mapping; //display to actual
    display_slot_mapping[2] = 0;
    display_slot_mapping[3] = 1;
    display_slot_mapping[1] = 2;
    //__briefcase_enchantments
    
    int [int] max_for_slot = {4, 7, 7};
    for display_slot_id from 1 to 3
    {
        int slot_id = display_slot_mapping[display_slot_id];
        //int display_slot_id = display_slot_mapping
        //Slots:
        out.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;width:33%;")));
        out.append(HTMLGenerateDivOfStyle("Slot " + display_slot_id, "font-size:1.5em;"));
        foreach enchantment_id, description in enchantments_description[slot_id]
        {
            string command = enchantments_commands[slot_id][enchantment_id];
            string active_description;
            active_description += description;
            
            //not very good looking, distracting, disable:
            /*if (active_description == "+5 Prismatic Damage")
            {
                active_description = "+5 ";
                string [int] element_classes = {"r_element_hot", "r_element_stench", "r_element_cold", "r_element_sleaze", "r_element_spooky"};
                string [int] colours = {"#FF0000", "#FF7F00", "#FFFF00", "green", "#0000FF", "#4B0082", "#9400D3"};
                for i from 3 to description.length() - 1
                {
                    string c = description.char_at(i);
                    //RGBPG
                    active_description += HTMLGenerateSpanOfClass(c, element_classes[(i - 3) % element_classes.count()]);
                    //active_description += HTMLGenerateSpanFont(c, colours[(i - 3) % colours.count()]);
                }
            }*/
            boolean clickable = true;
            string button_style;
            if (__briefcase_enchantments[slot_id] == enchantment_id)
            {
                clickable = false;
                button_style = "font-weight:bold;"; //color:red;
            }
            //Copy and pasted? criminal
            int delta_left = __briefcase_enchantments[slot_id] - enchantment_id;
            if (delta_left < 0)
                delta_left += max_for_slot[slot_id];
            if (delta_left >= max_for_slot[slot_id])
                delta_left -= max_for_slot[slot_id];
            int delta_right = enchantment_id - __briefcase_enchantments[slot_id];
            if (delta_right < 0)
                delta_right += max_for_slot[slot_id];
            if (delta_right >= max_for_slot[slot_id])
                delta_right -= max_for_slot[slot_id];
            int clicks_to_reach = MIN(delta_left, delta_right);
            
            if (clicks_to_reach > clicks_remaining && clickable)
            {
                button_style += "color:" + __setting_light_colour + ";";
            }
            else if (clickable)
                active_description += HTMLGenerateSpanOfClass(" (" + clicks_to_reach + ")", "briefcase_subtext");
            
            string button_class = "briefcase_entry";
            if (clickable)
                button_class += " briefcase_button";
            string [string] div_map;
            div_map["class"] = button_class;
            div_map["style"] = button_style;
            if (clickable)
                div_map["onclick"] = "executeBriefcaseCommand('enchantment " + command + "');";
            out.append(HTMLGenerateTagWrap("div", active_description, div_map));
        }
        //out.append("__briefcase_enchantments[slot_id] = " + __briefcase_enchantments[slot_id]);
        out.append("</div>"); //cell
    }
    
    
    out.append("</div>"); //row
    out.append("</div>"); //table
    return out;
}

buffer generateBuffText()
{
    buffer out;
    out.append(HTMLGenerateTagWrap("div", "Buffs", mapMake("style", "font-size:1.5em;", "class", "r_centre")));
    out.append(HTMLGenerateTagWrap("div", "50 turns", mapMake("style", "color:" + __setting_light_colour + ";", "class", "r_centre")));
    out.append("<br>");
    out.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table;width:100%;")));
    out.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-row;")));
    
    
    string [int][int] buffs_description;
    string [int][int] buffs_images;
    effect [int][int] buffs_effects;
    string [int][int] buffs_commands;
    for slot_id from 0 to 2
    {
        buffs_description[slot_id] = listMakeBlankString();
        buffs_images[slot_id] = listMakeBlankString();
        buffs_commands[slot_id] = listMakeBlankString();
        effect [int] blank;
        buffs_effects[slot_id] = blank;
    }
    
    foreach s in $strings[+100% meat,+50% item,+50% init,+5 stats/fight]
        buffs_description[0].listAppend(s);
    foreach s in $strings[+100% muscle,+100% myst,+100% moxie,+100% HP/MP]
        buffs_description[1].listAppend(s);
    foreach s in $strings[+30 muscle,+30 myst,+30 moxie]
        buffs_description[2].listAppend(s);
        
    foreach s in $strings[meat.gif,potion9.gif,fast.gif,fitposter.gif]
        buffs_images[0].listAppend(s);
    foreach s in $strings[bigdumbbell.gif,tinystars.gif,greaserint.gif,dna.gif]
        buffs_images[1].listAppend(s);
    foreach s in $strings[bigdumbbell.gif,tinystars.gif,greaserint.gif]
        buffs_images[2].listAppend(s);
    
    //moxie - bigglasses.gif
        
    foreach e in $effects[A View to Some Meat,Items Are Forever,Initiative and Let Die,The Spy Who Loved XP]
        buffs_effects[0].listAppend(e);
    foreach e in $effects[License to Punch,Thunderspell,Goldentongue,The Living Hitpoints]
        buffs_effects[1].listAppend(e);
    foreach e in $effects[Punch Another Day,For Your Brain Only,Quantum of Moxie]
        buffs_effects[2].listAppend(e);
        
    foreach s in $strings[meat,item,init,experience]
        buffs_commands[0].listAppend(s);
    foreach s in $strings[muscle_percentage,myst_percentage,moxie_percentage,hp]
        buffs_commands[1].listAppend(s);
    foreach s in $strings[muscle_absolute,myst_absolute,moxie_absolute]
        buffs_commands[2].listAppend(s);
    
    int identified_tabs_count = 0;
    for buff_id from 0 to 11
    {
        if (__file_state["tab effect " + buff_id] != "")
            identified_tabs_count += 1;
    }
    int missing_tabs_count = 12 - identified_tabs_count;
    
        
   for slot_id from 0 to 2
   {
        out.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;width:33%;")));
        foreach fake_id in buffs_description[slot_id]
        {
            buffer line;
            string image = buffs_images[slot_id][fake_id];
            effect buff_effect = buffs_effects[slot_id][fake_id];
            string command = buffs_commands[slot_id][fake_id];
            int buff_id = __spy_effect_to_buff_id[buff_effect];
            
            boolean known = (__file_state["tab effect " + buff_id] != "");
            Tab t = TabFromFileBuff(buff_id);
            
            boolean within_configuration = known && (__state.tab_configuration[t.id] == t.length);
            string button_style;
            if (!known)
                button_style += "color:" + __setting_light_colour + ";";
            if (true)
            {
                line.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table;")));
                line.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-row;")));
                line.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;")));
                line.append("<img src=\"images/itemimages/" + image + "\" style=\"mix-blend-mode:multiply;\">");
                line.append("</div>");
                line.append(HTMLGenerateTagPrefix("div", mapMake("style", "display:table-cell;vertical-align:middle;padding-left:5px;")));
                if (within_configuration)
                    line.append(HTMLGenerateSpanOfStyle(buffs_description[slot_id][fake_id], "font-weight:bold;"));
                else
                    line.append(buffs_description[slot_id][fake_id]);
                
                boolean is_estimate = false;
                int clicks_using = 3;
                if (known && !within_configuration)
                {
                    boolean [int][int] tabs_known; //FIXME actual
                    int [int] tab_permutation = stringToIntIntList(__file_state["tab permutation"]);
                    if (tab_permutation.count() == 0)
                    {
                        //Have to also discover tab permutation before we can realistically reach this spot:
                        clicks_using += 5; //I dunno?
                        is_estimate = true;
                    }
                    else
                    {
                        int best_target_number = computeBestTargetNumberForTab(t.id, t.length, tabs_known, false);
                        int current_briefcase_number = convertTabConfigurationToBase10(__state.tab_configuration, tab_permutation);
                        clicks_using += computePathLengthToNumber(best_target_number, current_briefcase_number);
                    }
                }
                if (!known)
                {
                    //int estimate = round(3.0 * to_float(missing_tabs_count) * 0.75);
                    //Expected value of clicks:
                    //int estimate = round(3.0 * missing_tabs_count_float * (missing_tabs_count_float + 1.0) * 0.5 / missing_tabs_count_float);
                    float estimate_ignoring_tab_manipulation = 1.5 * to_float(missing_tabs_count + 1);
                    float tab_manipulation_estimate = 0.5 * to_float(missing_tabs_count + 1); //clicks to reach each tab; we're assuming one click to reach one tab, which is almost certainly wrong. also we could take into account unknown tabs we already know about
                    int estimate = round(estimate_ignoring_tab_manipulation + tab_manipulation_estimate);
                    is_estimate = true;
                    clicks_using = estimate;
                }
                string clicks_using_string = clicks_using;
                if (is_estimate)
                    clicks_using_string = "~" + clicks_using;
                line.append(HTMLGenerateSpanOfClass(" (" + clicks_using_string + ")", "briefcase_subtext"));
                
                string [int] secondary_line;
                //FIXME clicks to
                if (buff_effect.have_effect() > 0)
                {
                    secondary_line.listAppend(buff_effect.have_effect() + " turn" + (buff_effect.have_effect() > 1 ? "s" : ""));
                }
                if (secondary_line.count() > 0)
                {
                    line.append(HTMLGenerateTagPrefix("span", mapMake("class", "briefcase_subtext")));
                    line.append("<br>" + secondary_line.listJoinComponents(", "));
                    line.append("</span>");
                }
                
                line.append("</div>");
                line.append("</div>");
                line.append("</div>");
            }
            else
            {
                line.append(buffs_description[slot_id][fake_id]);
            }
            out.append(HTMLGenerateTagWrap("div", line, mapMake("class", "briefcase_entry briefcase_button", "style", button_style, "onclick", "executeBriefcaseCommand('buff " + command + "');")));
            
        }
        out.append("</div>"); //cell
   }
    
    out.append("</div>"); //row
    out.append("</div>"); //table
    
    return out;
}

buffer generatePageText(boolean body_only)
{
    PageInit();
    PageSetTitle("Kremlin's Greatest Briefcase");
    
    PageWriteHead(HTMLGenerateTagPrefix("meta", mapMake("name", "viewport", "content", "width=device-width")));
    PageWriteHead("<script type=\"text/javascript\" src=\"place.kgb.js\"></script>");
    
    //Stylin':
    PageAddCSSClass("body", "", "cursor:default;background:" + (__setting_have_dark_background ? __setting_background_colour : "white") + ";font-family:'Helvetica-Light', 'Helvetica-Scenario', Arial, Helvetica, sans-serif;font-size:15px;text-shadow:1px 1px 1px #FFFFFF;");
    PageAddCSSClass("hr", "", "height: 1px; border: 0px; width: 80%;background: " + __setting_light_colour + "; margin-top:24px;margin-bottom:24px;"); //box-shadow: 0px 0px 0px 0px white;
    //PageAddCSSClass("div", "briefcase_entry", "padding:7px;border:1px solid " + __setting_light_colour + ";border-radius:5px;margin-top:7px;");
    PageAddCSSClass("div", "briefcase_entry", "padding:7px;");
    PageAddCSSClass("div", "briefcase_button:hover", "background:" + (__setting_have_dark_background ? "white" : __setting_background_colour) + ";cursor:pointer;border-radius:5px;");
    PageAddCSSClass("", "briefcase_subtext", "font-size:0.9em;color:" + __setting_light_colour + ";"); //they're just unusually good friends
    PageAddCSSClass("", "briefcase_popup", "z-index:5;transition:opacity 1.0s linear;background-color:white; border-radius:5px 0px 0px 5px;padding:10px;margin-top:10px;font-size:1.2em;"); //border-width:1px; border-color:" + __setting_light_colour + "; border-style: solid
    //box-shadow: 0px 0px 3.0px 8.0px " + __setting_background_colour + ";"
    //
    
    PageWrite(HTMLGenerateTagWrap("div", "v" + __briefcase_version, mapMake("style", "position:absolute;right:5px;top:5px;color:" + __setting_light_colour + ";font-size:0.8em;")));
    PageWrite(HTMLGenerateTagWrap("div", "", mapMake("style", "position:absolute;right:0px;background:" + __setting_background_colour + ";box-shadow: 0px 0px 3.0px 5.0px " + __setting_background_colour + ";", "id", "briefcase_notification_div")));
    //Main div:
    PageWrite(HTMLGenerateTagPrefix("div", mapMake("style", "margin-left:auto;margin-right:auto;max-width:630px;", "id", "briefcase_main_holder_div")));
    
    buffer core;
    //core.append(random(1000));
    core.append(HTMLGenerateTagWrap("div", "Kremlin's Greatest Briefcase", mapMake("style", "font-size:2.0em;font-weight:bold;", "class", "r_centre")));
    
    /*core.append(HTMLGenerateTagPrefix("div", mapMake("class", "r_centre")));
    if (clicks_remaining > 0)
        core.append(clicks_remaining + " click " + (clicks_remaining > 1 ? "s" : "") + " remaining.");
    else
        core.append("<span style=\"color:red;\">Out of clicks for the day.</span>");
    if (banishes_remaining > 0)
        core.append(" " + banishes_remaining + " banish" + (banishes_remaining > 1 ? "s" : ""));
    core.append(HTMLGenerateTagSuffix("div"));*/
    core.append(generateFirstText());
    //core.append("<hr>");
    core.append(generateEnchantmentText());
    core.append("<hr>");
    core.append(generateBuffText());
    core.append("<hr>");
    core.append(HTMLGenerateTagWrap("div", "Disable GUI", mapMake("class", "r_centre briefcase_entry briefcase_button", "onclick", "disableGUI();")));
    
    //Page end
    core.append(HTMLGenerateTagSuffix("div"));
    
    PageWrite(core);
    if (body_only)
        return core;
    else
        return PageGenerate();
}

void handleFormRelayRequest()
{
    string [string] form_fields = form_fields();
    //print_html("form_fields = " + form_fields.to_json());
    
    string [string] response;
    
    boolean output_body_html = true;
    string type = form_fields["type"];
    if (type == "execute_command")
    {
        string command = form_fields["command"];
        //print_html("Execute command \"" + form_fields["command"] + "\"");
        
        boolean [item] items_tracking = $items[basic martini,improved martini,splendid martini,exploding cigar,can of Minions-Be-Gone,golden gun,golden gum,tiny plastic golden gundam];
        int [item] item_count_before;
        foreach it in items_tracking
            item_count_before[it] = it.item_amount();
        buffer command_result = executeCommand(form_fields["command"], true);
        
        //Display items acquired:
        int [item] item_count_delta;
        foreach it in items_tracking
        {
            int delta = it.item_amount() - item_count_before[it];
            //delta = random(3); //GUI testing
            if (delta > 0)
                item_count_delta[it] = delta;
        }
        string [int] items_gained_description;
        foreach it, amount in item_count_delta
        {
            string line = it;
            if (amount > 1)
                line += " (" + amount + ")";
            items_gained_description.listAppend(line);
        }
        if (items_gained_description.count() > 0)
        {
            if (command_result.length() > 0)
                command_result.append("<br>");
            command_result.append("Acquired " + items_gained_description.listJoinComponents(", ", "and") + ".");
        }
        
        
        response["popup result"] = command_result;
        //response["popup result"] = "Acquired 3 exploding cigars";
    }
    if (type == "disable_gui")
    {
        set_property("kgbbriefcase_disable_gui", "true");
        output_body_html = false;
    }
    if (type == "enable_gui")
    {
        set_property("kgbbriefcase_disable_gui", "false");
        output_body_html = false;
    }
    
    if (output_body_html)
    {
        if (__state.dial_configuration.count() == 0) //FIXME explicit boolean if we haven't been visited?
            actionVisitBriefcase(true);
        response["core HTML"] = generatePageText(true);
    }
    
    //print_html("response = " + response.to_json().entity_encode());
    write(response.to_json());
}

void relayScriptMain()
{
    if (form_fields()["relay_request"] != "")
    {
        handleFormRelayRequest();
        return;
    }
    if (get_property_boolean("kgbbriefcase_disable_gui"))
    {
        buffer page_text = visit_url();
        string extra = "<div onclick=\"var form_data = 'relay_request=true&type=enable_gui'; var request = new XMLHttpRequest(); request.onreadystatechange = function() { if (request.readyState == 4) { if (request.status == 200) { location.reload() } } }; request.open('POST', 'place.kgb.ash'); request.send(form_data);\" style=\"text-decoration:underline;cursor:pointer;\">Enable GUI</div><br>";
        page_text.replace_string("<a href=inventory.php>Back to your Inventory</a>", extra + "<a href=inventory.php>Back to your Inventory</a>");
        page_text.replace_string("alt=\"Handle (up)\"", "alt=\"Handle (up)\" style=\"opacity:0.5;\""); //oOoOOoooo ghost handle
        write(page_text);
        return;
    }
    actionVisitBriefcase(true);
    if (!lockIsUsedBySomeoneElse())
    {
        gainActionLock();
        collectOnceDailies();
        releaseActionLock();
    }

    //buffer page_text = visit_url();
    //write(page_text);
    
    write(generatePageText(false));
}


if (__setting_output_help_before_main)
	outputHelp();

void main(string command)
{
    executeCommand(command, false);
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