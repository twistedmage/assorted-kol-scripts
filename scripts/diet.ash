//check you used milk of magnesium, munchies pill, and have ode to booze before running this


//add mana burning?
//check gains are what is expected
record fullness_file_entry // holds the map found in fullness.txt
{
	int consumptionGain;
	int level;	 
	string adv; 
	string muscle; 
	string mysticality;
	string moxie; 
};

record beer_types // holds the chosen beers
{
	float val;
	item beer_item;
	int level;	 
};
fullness_file_entry [item] temp_map;
if (!file_to_map("inebriety.txt", temp_map))
	abort("Failed to load inebriety.txt. Aborting.");

item beer_choice=to_item(0);

beer_types [int] my_beers;
my_beers[1].beer_item=$item[cup of primitive beer];
my_beers[1].level=temp_map[$item[cup of primitive beer]].level;
my_beers[1].val=9.75;
my_beers[2].beer_item=$item[mcmillicancuddy's special lager];
my_beers[2].level=temp_map[$item[mcmillicancuddy's special lager]].level;
my_beers[2].val=9.0;
my_beers[3].beer_item=$item[can of swiller];
my_beers[3].level=temp_map[$item[can of swiller]].level;
my_beers[3].val=9.0;
my_beers[4].beer_item=$item[rams face lager];
my_beers[4].level=temp_map[$item[rams face lager]].level;
my_beers[4].val=8.5;


void fix_milk()
{
	if(have_effect($effect[Got Milk])==0)
	{
		if(item_amount($item[Milk of magnesium])==0)
		{
			if(can_interact())
			{
				if(stash_amount($item[Milk of magnesium])!=0)
				{
					cli_execute("stash take 1 Milk of magnesium");
					use(1,$item[Milk of magnesium]);
				}
				else
				{
					use(1,$item[Milk of magnesium]);
				}
			}
			else
			{
				if(creatable_amount($item[Milk of magnesium])!=0)
				{
					cli_execute("make Milk of magnesium");
					use(1,$item[Milk of magnesium]);
				}
			}
		}
		else
		{
			use(1,$item[Milk of magnesium]);
		}
	}
}

boolean buyneeded()
{
//min of food or drink left
	int full_left=fullness_limit() - my_fullness();
	int inebriety_left=inebriety_limit() - my_inebriety();
	int nuts_needed=full_left;
	int beer_needed=full_left;
	if(inebriety_left<full_left)
	{
		nuts_needed=inebriety_left;
		beer_needed=inebriety_left;
	}
//if have buff already subtract 1 food
	if(have_effect($effect[Salty mouth])>0)
	{
		nuts_needed=nuts_needed-1;
	}
//try to stash pull them
	int pull_amt=nuts_needed-item_amount($item[packet of beer nuts]);
	if(pull_amt>0)
	{
		if(stash_amount($item[packet of beer nuts])>=pull_amt)
		{
			cli_execute("stash take "+pull_amt+" packet of beer nuts");
		}
		else
		{
			print("Not enough nuts in stash, quitting diet","red");
			exit;
		}
	}
//find best beer that can be stash pulled
	sort my_beers by -value.val;
	foreach it in my_beers
	{
print("checking beer: "+my_beers[it].beer_item,"green");	
		if(my_beers[it].level<=my_level())
		{
			pull_amt=nuts_needed-item_amount(my_beers[it].beer_item);
			if(stash_amount(my_beers[it].beer_item)>=pull_amt)
			{
				beer_choice = my_beers[it].beer_item;
				print("Beer chosen as "+beer_choice,"blue");
				break;
			}
			else
			{
print("not enough "+my_beers[it].beer_item+" in stash","green");	
			}
		}
		else
		{
print("level too low for "+my_beers[it].beer_item,"green");	
		}
	}
	if(beer_choice==to_item(0))
	{
		print("No beers good enough for beer diet.","red");
		exit;
	}
	if(pull_amt>0)
	{
		cli_execute("stash take "+pull_amt+" "+beer_choice);
	}
//if dont have that many buy up to it
	if(item_amount($item[packet of beer nuts])<nuts_needed && can_interact())
	{
		retrieve_item(nuts_needed,$item[packet of beer nuts]);
	}
	if(item_amount(beer_choice)<beer_needed && can_interact())
	{
		retrieve_item(nuts_needed,beer_choice);
	}
//if we failed or couldnt buy them...		
	if(item_amount($item[packet of beer nuts])<nuts_needed || item_amount(beer_choice)<beer_needed)
	{
		print("couldn't obtain nuts and beer","red");
		return false;
	}
	print("obtained nuts and beer","blue");
	return true;
}

boolean eatmynuts()
{
//if not too drunk
	if(can_interact() && my_fullness()<fullness_limit() && my_inebriety()<inebriety_limit() && have_effect($effect[ode to booze])==0)
	{
		if(have_skill($skill[the ode to booze]))
		{
			cli_execute("cast ode");
		}
		else
		{
			abort("You need ode!");
		}
	}
	if(my_inebriety()<inebriety_limit())
	{
		fix_milk();
//if have nuts and can eat and have a wet mouth, then eat
		int st=my_adventures();
		if(item_amount($item[packet of beer nuts])>0 && my_fullness()<fullness_limit() && have_effect($effect[Salty mouth])==0)
		{
			eatsilent(1,$item[packet of beer nuts]);
		}
		int nutadv=my_adventures() - st;
//if have drink and salty mouth, drink
		if(item_amount(beer_choice)>0 && have_effect($effect[Salty mouth])>0)
		{
			cli_execute("mood execute");
			cli_execute("burn extra");
			drink(1,beer_choice);
			int beeradv=my_adventures() - st - nutadv;
			print("ate nuts("+nutadv+") and beer("+beeradv+")","blue");
			return true;
		}
	}
	print("couldn't eat nuts and beer","red");
	return false;
}




void main()
{
	cli_execute("mood consume");
	boolean success;
	success=buyneeded();
	if(success)
	{
		while(success)
		{
			success=eatmynuts();
		}
	}
	if(my_mp()<20)
	{
		cli_execute("mood apathetic");
	}
	else
	{
		cli_execute("mood default");
	}
}

