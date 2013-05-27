import <questlib.ash>;



void littlemonkey()
{
	//talk to old man
	visit_url("oldman.php?action=talk");
	if(!contains_text(visit_url("questlog.php?which=1&pwd"),"Hey, Hey, They're Sea Monkees") && !contains_text(visit_url("questlog.php?which=2&pwd"),"Hey, Hey, They're Sea Monkees"))
	{
		dress_for_wet();
		//perhaps should maximize items
		cli_execute("conditions clear");
		cli_execute("condition add wriggling flytrap pellet");
		adventure(my_adventures(),$location[An Octopus's Garden]);
		cli_execute("use 1 wriggling flytrap pellet");
		visit_url("monkeycastle.php?who=1&pwd");
	}
	else
	{
		print("Little brother already rescued.");
	}
}


void bigmonkey()
{
	if(contains_text(visit_url("questlog.php?which=1&pwd"),"asked you to find his older brother"))
	{
		dress_for_wet();
		cli_execute("conditions clear");
		cli_execute("condition add choiceadv");
		set_property("choiceAdventure299", "1");
		adventure(my_adventures(),$location[The Wreck of the Edgar Fitzsimmons]);
		visit_url("monkeycastle.php?who=2&pwd");
		visit_url("monkeycastle.php?who=1&pwd");
	}
	else
	{
		if(contains_text(visit_url("questlog.php?which=1&pwd"),"An Old Guy and The Ocean") && available_amount($item[sand dollar])>40)
		{
			cli_execute("buy damp old boot");
			visit_url("oldman.php?action=talk");
		}
		print("Big brother already rescued.");
	}
}

void pamonkey()
{
	if(contains_text(visit_url("questlog.php?which=1&pwd"),"Little Brother has asked you to rescue his grandpa."))
	{
		dress_for_wet();
		location grandpas_loc;
		if((my_class()==$class[seal clubber]) || my_class()==$class[turtle tamer])
		{
			grandpas_loc= $location[Anemone mine];
		}
		else if(my_class()==$class[disco bandit] || my_class()==$class[accordion thief])
		{
			grandpas_loc= $location[The dive bar];
		}
		else
		{
			grandpas_loc= $location[The marinara trench];
		}
		
//This is supposed to adventure in there fighting until the aqcuire skill text comes
//it may fail for non combats before you get the skill. It may also fail because
//adventure() does not return the url. It's also possible the run_combat() is not needed
//as it is inside adventure
		while(!contains_text(adventure(1,grandpas_loc),"You acquire a skill"))
		{
			run_combat();
		}
		//ask him everything
		cli_execute("grandpa.ash");
	}
	else
	{
		print("Grandpa already rescued.");
	}
}

void mamonkey()
{
//is there something else in quest log after you are told about grandma?
	if(contains_text(visit_url("questlog.php?which=1&pwd"),"You've rescued Grandpa, and he's got lots and lots of stories to tell."))
	{
		dress_for_wet();
		if(available_amount($item[Grandma's Map])==0)
		{
			while(available_amount($item[Grandma's Note])==0 || available_amount($item[Grandma's Fuchsia Yarn])==0 || available_amount($item[Grandma's Chartreuse Yarn])==0)
			{
				adventure(1,$location[The Mer-Kin Outpost]);
			}
			visit_url("monkeycastle.php?who=3&action=grandpastory&topic=Note&pwd");
		}
		else
		{
			//i think granny is the guaranteed next adventure. have to check
			adventure(1,$location[The Mer-Kin Outpost]);
		}
	}
	else
	{
		print("Grandma already rescued.");
	}
}


void main()
{
	littlemonkey();
	bigmonkey();
	pamonkey();
	mamonkey();
}
