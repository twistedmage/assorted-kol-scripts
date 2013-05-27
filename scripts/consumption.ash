int[item] booze_consumed;
int[item] food_consumed;

void add_food_consumed(string found)
{
//the format of the string when it gets here.
//<td><a class=nounder href='javascript:descitem(313835263);'>extra-spicy bloody mary</a> </td><td>1</td>
string quantstr = substring(found, last_index_of(found, "<td>") + 4, last_index_of(found, "</td>"));
string itemstr = substring(found, last_index_of(found, ";'>") + 3, last_index_of(found, "</a>"));
food_consumed[string_to_item(itemstr)] = string_to_int(quantstr);
}

void add_booze_consumed(string found)
{
//the format of the string when it gets here.
//<td><a class=nounder href='javascript:descitem(313835263);'>extra-spicy bloody mary</a> </td><td>1</td>
string quantstr = substring(found, last_index_of(found, "<td>") + 4, last_index_of(found, "</td>"));
string itemstr = substring(found, last_index_of(found, ";'>") + 3, last_index_of(found, "</a>"));
booze_consumed[string_to_item(itemstr)] = string_to_int(quantstr);
}

string replace_all(string source, string search_set, string replacewith)
{
//accept a list of items in search_set delimited by commas
//if a substring which needs replaced has a comma in it, do not use this function.
string[int] searchitems = split_string(search_set, ",");
string results = source;
foreach key in searchitems
  {
  results = replace_string(results, searchitems[key], replacewith);
  }
return results;
}

void Load_Data()
{
string consumption_page = visit_url("showconsumption.php");
if(!contains_text(consumption_page, "You have consumed the following booze items:"))
  {cli_execute("abort Booze Consuption Record not found");}
if(!contains_text(consumption_page, "You have consumed the following food items:"))
  {cli_execute("abort food Consuption Record not found");}

string food_consumedstr = substring(consumption_page, index_of(consumption_page, "You have consumed the following food items:"), index_of(consumption_page, "You have consumed the following booze items:"));
string booze_consumedstr = substring(consumption_page, index_of(consumption_page, "You have consumed the following booze items:"), length(consumption_page));

//convert html encoded spaces to string spaces.
food_consumedstr = replace_string(food_consumedstr, "&nbsp;", " ");
booze_consumedstr = replace_string(booze_consumedstr, "&nbsp;", " ");
food_consumedstr = replace_all(food_consumedstr, "</tr>,<tr>", "<crlf>");
booze_consumedstr = replace_all(booze_consumedstr, "</tr>,<tr>", "<crlf>");

//split the 2 strings into multiple strings...in the end each will contain an item, or be ignored.
string[int] booze_consumedstr_split = split_string(booze_consumedstr, "<crlf>");
string[int] food_consumedstr_split = split_string(food_consumedstr, "<crlf>");

foreach key in food_consumedstr_split
  {
  //ignore strings which do not contain valid items.
  if(contains_text(food_consumedstr_split[key], "descitem"))
    {
    add_food_consumed(food_consumedstr_split[key]);
    }
  }
foreach key in booze_consumedstr_split
  {
  //ignore strings which do not contain valid items.
  if(contains_text(booze_consumedstr_split[key], "descitem"))
    {
    add_booze_consumed(booze_consumedstr_split[key]);
    }
  }
}

//the next line is intentionally here.
//it initializes food_consumed[item] and
//BoozeConsumed[item]
Load_Data();

void main()
{
print("Foods Consumed");
foreach key in food_consumed
  {
  print(food_consumed[key] + " " + key);
  }
print("Booze Consumed");
foreach key in booze_consumed
  {
  print(booze_consumed[key] + " " + key);
  }
}