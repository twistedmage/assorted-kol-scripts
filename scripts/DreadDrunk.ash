
// DreadDrunk 1.01: Feed booze to the carriage-dude. -- guyy
// 
// Will buy and feed booze that costs the least meat per sheet, so as to not waste your meat. 
// 
// Input: "village" or "castle" to unlock a specified zone, or an exact number of sheets.
// "list [number]" prints a value-ordered list of the top [number] feedable booze, but doesn't feed anything.
// If you input nothing or something invalid, it will unlock the castle.

script "DreadDrunk.ash";
notify guyy;

int[string] quality_value;

string tween_text(string searchme, string pre, string post)
{
	int starts, ends;
	starts = index_of(searchme,pre);
	if (starts >= 0)
		ends = index_of(searchme,post,starts);
	if (starts >= 0 && ends > 0 && (starts + length(pre)) < ends)
		return substring(searchme, (starts + length(pre)), ends);
	else
		return "";
}

int[item] boozers;
item[float] boozers_effs;
string[float] boozers_xtra;
int[item] boozer_min_price;
float ahtem_eff;
item best_boozer;
float best_eff = 0;
int best_price;
int maller_pricer;
void get_best_boozer()
{
	best_boozer = $item[none];
	best_eff = 0;
	foreach ahtem, sheets in boozers
	{
		if (sheets > 0)
		{
			if (historical_price(ahtem).to_float() > 0)
				ahtem_eff = boozers[ahtem] / historical_price(ahtem).to_float();
			if (ahtem_eff > best_eff)
			{
				maller_pricer = mall_price(ahtem);
				if (maller_pricer.to_float() > 0)
				{
					ahtem_eff = boozers[ahtem] / maller_pricer.to_float();
					if (ahtem_eff > best_eff)
					{
						best_boozer = ahtem;
						best_eff = ahtem_eff;
						best_price = maller_pricer;
					}
				}
			}
		}
	}
}

int avrij(string raynj)
{
	if (!contains_text(raynj,"-"))
		return(to_int(raynj));
		
	raynj = " |"+raynj+"/";
	float minval = tween_text(raynj,"|","-").to_float();
	float maxval = tween_text(raynj,"-","/").to_float();
	
	return floor((minval + maxval) / 2.0).to_int();
}

string man_carriage;
int get_sheets()
{
	return tween_text(man_carriage,"carriageman is currently "," sheet").to_int();
}

void main(string sheets)
{
	man_carriage = visit_url("clan_dreadsylvania.php?place=carriage");
	if (!contains_text(man_carriage,"Carriageman"))
		abort("Can't get to Dreadsylvania!");
	
	int meatspent = 0;
	int desired_sheets;
	if (contains_text(sheets.to_lower_case(),"vill"))
		desired_sheets = 1000;
	else if (contains_text(sheets.to_lower_case(),"cast") || contains_text(sheets.to_lower_case(),"list"))
		desired_sheets = 2000;
	else
		desired_sheets = to_int(sheets);
	if (desired_sheets <= 0 || desired_sheets > 2000)
		desired_sheets = 2000;
	int current_sheets = get_sheets();
	int x_boozers, haz_boozers, got_boozers;
	
	boolean[item] invalid_boozers;
	
	boolean all_npc_ingredients(item ahtem)
	{
		int[item] bewz = get_ingredients(ahtem);
		if (is_npc_item(ahtem))
			return true;
		boolean greedyents = false;
		foreach thing in bewz
		{
			greedyents = true;
			if (!all_npc_ingredients(thing))
				return false;
		}
		return greedyents;
	}
	
	foreach ahtem in $items[]
	{
		// non-tradeables, non-discardables, and NPC store items can't be fed to him.
		if (ahtem != $item[none] && item_type(ahtem) == "booze" && is_tradeable(ahtem) && !invalid_boozers[ahtem] && 
		autosell_price(ahtem) > 0 && !all_npc_ingredients(ahtem) && !contains_text(ahtem.to_string(),"dusty bottle of "))
		{
			boozers[ahtem] = avrij(ahtem.adventures);
			// fix incorrect sheet quantities
			if (ahtem == $item[snifter of thoroughly aged brandy])
				boozers[ahtem] = 3;
			if (boozers[ahtem] == 22 && contains_text(ahtem.to_string().to_lower_case(),"corpse"))
				boozers[ahtem] = 21;
			if (historical_price(ahtem).to_float() > 0)
			{
				ahtem_eff = (boozers[ahtem] / historical_price(ahtem).to_float());
				//while (boozers_effs[ahtem_eff] != $item[none])
				//	ahtem_eff += 1;
				if (boozers_effs[ahtem_eff] == $item[none])
					boozers_effs[ahtem_eff] = ahtem;
				else
					boozers_xtra[ahtem_eff] += "<br> ----- "+ahtem.to_string()+" ("+historical_price(ahtem)+" meat, "+boozers[ahtem]+" sheets)";
			}
		}
	}
	
	if (contains_text(sheets.to_lower_case(),"list"))
	{
		matcher numbear = create_matcher("list ([0-9]*)",sheets);
		int numlisted = 11;
		if (find(numbear))
			numlisted = group(numbear,1).to_int();
	
		sort boozers_effs by index;
		
		item last_thing;
		int total_booze = count(boozers_effs);
		string kolor = "gray";
		string effy;
		foreach effs, ahtem in boozers_effs
		{
			if (total_booze <= numlisted)
			{
				last_thing = ahtem;
				if (effs > 0)
					effy = to_int(1/effs);
				else
					effy = "infinite";
				if (total_booze == 1)
					kolor = "blue";
				else if (total_booze <= 5)
					kolor = "green";
				else if (effy != "infinite" && effy.to_int() <= 100)
					kolor = "black";
				print_html("<span style='color:"+kolor+";'>"+total_booze+". "+ahtem.to_string()+" ("+historical_price(ahtem)+" meat, "+boozers[ahtem]+" sheets, "+effy+" meat per sheet)"+boozers_xtra[effs]+"</span>");
			}
			total_booze -= 1;
		}
		
		print("");
		x_boozers = ceil((2000.0 - current_sheets).to_float() / boozers[last_thing].to_float());
		print("Best booze is "+last_thing.to_string()+" ("+effy+" meat per sheet).","blue");
		if (current_sheets < 2000)
			print("Expected cost of boozing to the castle: "+(historical_price(last_thing)*x_boozers)+" meat. (Actual cost will probably be somewhat higher.)", "blue");
		else
			print("The Carriageman is thoroughly sheeted already.","blue");
	}
	else
	{
		while (current_sheets < desired_sheets)
		{
			get_best_boozer();
			if (best_boozer != $item[none])
			{
				x_boozers = ceil((desired_sheets - current_sheets).to_float() / boozers[best_boozer].to_float());
				print("Feeding "+x_boozers+" "+to_string(best_boozer)+" ("+(best_price*x_boozers)+" meat, "+(boozers[best_boozer]*x_boozers)+" sheets, ~"+(best_price/boozers[best_boozer])+" meat per sheet).","blue");
				//wait(5);
				if (my_meat() < x_boozers * best_price)
					abort("Not enough meat! This dose of booze costs "+(x_boozers*best_price)+" meat.");
				haz_boozers = item_amount(best_boozer);
				if (x_boozers - haz_boozers > 0)
				{
					got_boozers = buy(x_boozers - haz_boozers,best_boozer,best_price) + haz_boozers;
					meatspent += (got_boozers - haz_boozers) * best_price;
				}
				else
					got_boozers = x_boozers;
				if (got_boozers <= 0)
				{
					while (got_boozers < x_boozers)
					{
						if (buy(1,best_boozer,best_price) == 1)
						{
							got_boozers += 1;
							meatspent += best_price;
						}
						else
							break;
					}
					print("Couldn't buy enough at that price. Will need to buy something else.","red");
					//boozers[best_boozer] = 0;
				}
				if (got_boozers > 0)
				{
					man_carriage = visit_url("clan_dreadsylvania.php?place=carriage&action=feedbooze&whichbooze="+to_int(best_boozer)+"&boozequantity="+got_boozers);
					current_sheets = get_sheets();
					if (contains_text(man_carriage,"That'd be a waste") || contains_text(man_carriage,"already plenty drunk"))
						print("Someone dumped in booze before you did, so you may have some left over.","red");
					else if (!contains_text(man_carriage,"gladly accepts your booze"))
					{
						invalid_boozers[best_boozer] = true;
						boozers[best_boozer] = -1;
						print("ALERT: "+to_string(best_boozer)+" is not a valid carriageman-drunkener! This needs to be added to the do-not-use list.","red");
					}
				}
			}
			else
				abort("Can't find any suitable booze!");
		}
		
		print("The Carriageman is sheeted all the way to "+current_sheets+". Meat spent: "+meatspent,"blue");
	}
}