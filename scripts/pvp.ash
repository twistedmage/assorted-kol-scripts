
void fill_up()
{
	if(!get_property("_fancyHotDogEaten").to_boolean() && fullness_limit() - my_fullness() > 1)
	{
		abort("Eat a devil dog");
	}
	while(my_inebriety() <= inebriety_limit())
	{
		overdrink(1,$item[beery blood]);
	}
	while(fullness_limit() - my_fullness() > 1)
	{
		eat(1,$item[gunpowder burrito]);
	}
}

void pvp_turn_burn()
{
//	while(my_adventures()>0 && my_inebriety() <= inebriety_limit())
//	{
//		adventure(1,$location[]);
//	}
}

int fights_left()
{
	//get original page
	string page=visit_url("peevpee.php?place=fight");
	
	//break stone if needed
	if(contains_text(page,"You must break your"))
	{
		string catch = visit_url("campground.php?smashstone=Yep.&confirm=on&shatter=Smash+that+Hippy+Crap%21");
		page=visit_url("peevpee.php?place=fight");
	}
	
	//pledge support if needed
	if(contains_text(page,"you must pledge your allegiance"))
	{
		string catch = visit_url("peevpee.php?action=pledge&place=fight&pwd");
		page=visit_url("peevpee.php?place=fight");
	}
	
	//find number of matches left
	matcher fights_matcher = create_matcher("You have (\\d*) fights? remaining today",page);
	if(find(fights_matcher))
	{
		int left = group(fights_matcher,1).to_int();
		print("You have "+left+" fights left");
		return left;
	}
	else
		return 0;
}

int check_swagger()
{
	//get original page
	string page=visit_url("peevpee.php?place=shop");
	
	//find swagger
	matcher swagger_matcher = create_matcher("You have (\\d*) swagger.",page);
	if(find(swagger_matcher))
	{
		int left = group(swagger_matcher,1).to_int();
		print("You have "+left+" swagger.");
		return left;
	}
	else
		return 0;
}

int check_season_swagger()
{
	//get original page
	string page=visit_url("peevpee.php?place=shop");
	
	//find swagger
	matcher swagger_matcher = create_matcher("ve earned (\\d*) swagger during",page);
	if(find(swagger_matcher))
	{
		int left = group(swagger_matcher,1).to_int();
		print("You have "+left+" swagger.");
		return left;
	}
	else
		return 0;
}

void do_fights()
{
	if(my_name()=="asica" || my_name()=="anid")
	{
		pvp_turn_burn();
		fill_up();
	}
	if(fights_left()!=0)
	{
		//equip best
		cli_execute("UberPvPOptimizer.ash");
	}
	
	//loop until done
	if(can_interact())
		cli_execute("pvp loot 0");
	else
		cli_execute("pvp flowers 0");
//	while(fights_left()>0)
//	{
		//fight person
//		string catch=visit_url("peevpee.php?place=fight&action=fight&ranked=1&stance=4&attacktype=flowers");
//	}	
	print("Done with pvp today");
	int swagger=check_swagger();
	int season_swagger=check_season_swagger();
//	if(swagger>2000 && can_interact() && season_swagger>1000)
//		abort("buy seasonal pvp item?");
	
	if(swagger>10000 && available_amount($item[cursed microwave])<1 && can_interact())
		abort("buy cursed microwave");
	if(swagger>10000 && available_amount($item[cursed pony keg])<1 && can_interact())
		abort("buy cursed pony keg");
	if(swagger>1000 && available_amount($item[insulting hat])<1 && can_interact())
		abort("buy insulting hat");
	if(swagger>2000 && available_amount($item[offensive moustache])<1 && can_interact())
		abort("buy offensive moustache");
	if(swagger>2000 && available_amount($item[hairshirt])<1 && can_interact())
		abort("buy hairshirt");
	if(swagger>2000 && available_amount($item[How to Tolerate Jerks])<1 && can_interact())
		abort("buy How to Tolerate Jerks");
//	if(swagger>5000 && available_amount($item[slap and slap again recipe])<1 && can_interact())
//		abort("buy slap and slap again recipe");
	if(swagger>5000 && available_amount($item[fettucini &eacute;pines Inconnu recipe])<1 && can_interact())
		abort("buy fettucini épines Inconnu recipe");
	if(swagger>5000 && !have_skill($skill[Summon Annoyance]) && can_interact())
		abort("buy another level of Essence of Annoyance");
	if(swagger>50 && available_amount($item[Huggler Radio])<1 && can_interact())
		abort("buy Huggler Radio");
		
}

void main()
{
	string year_str=today_to_string();
	int year = substring(year_str,0,4).to_int();
	int month = substring(year_str,4,6).to_int();
	int day = substring(year_str,6,8).to_int();
	print("Date = "+day+" "+month+" "+year,"purple");
	if(year==2015 && month==5) //increase month by 2 for each season
		abort("New pvp season, change maximizer options");
	do_fights();
}