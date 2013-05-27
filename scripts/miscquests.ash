






void hammerquest()
{
	if(!contains_text(visit_url("questlog.php?which=2&pwd"),"handily helped Harold with his hammer"))
	{
		dress_for_fighting();
		print("doing hammer quest","blue");
		set_property("choiceAdventure112", "1");
		boolean done=false;
		while(!done)
		{
			if(my_adventures()>0)
			{
				adventure(1,$location[sleazy back alley]);
			}
			else
			{
				done=true;
			}
			if(contains_text(visit_url("questlog.php?which=2&pwd"),"handily helped Harold with his hammer"))
			{
				done=true;
			}
			print("still trying hamemr in the first while loop","blue");
		}
	}
	else
	{
		print("Done hammer quest");
	}
}



void bakerquest()
{
	if(!contains_text(visit_url("questlog.php?which=2&pwd"),"You helped the anonymous baker prepare"))
	{
		dress_for_fighting();
		print("doing baker quest","blue");
		if(available_amount($item[lit birthday cake])==0) 
		{
			set_property("choiceAdventure114", "1");
			while(available_amount($item[unlit birthday cake])==0 && my_adventures()>0)
			{
				adventure(1,$location[Haunted Pantry]);
			}
			set_property("choiceAdventure113", "1");
			while(available_amount($item[lit birthday cake])==0 && my_adventures()>0)
			{
				adventure(1,$location[Outskirts of the Knob ]);
			}
		}
		while(available_amount($item[pat-a-cake pendant])==0 && my_adventures()>0)
		{
			adventure(1,$location[Haunted Pantry]);
		}
	}
	else
	{
		print("Done baker quest");
	}

}





void woundedquest()
{
	while(!contains_text(visit_url("questlog.php?which=2&pwd"),"helped out a wounded Knob Goblin guard by bringing him some unguent") && my_adventures()>0)
	{
		dress_for_fighting();
		print("doing wounded quest","blue");
		if(available_amount($item[pungent unguent])==0) 
		{
			buy(1,$item[pungent unguent]);
		}
		set_property("choiceAdventure118", "1");
		adventure(1,$location[Outskirts of the Knob]);
	}
	if(contains_text(visit_url("questlog.php?which=2&pwd"),"helped out a wounded Knob Goblin guard by bringing him some unguent"))
	{
		print("done wounded quest");
	}
}


void Literacyquest()
{
	visit_url("town_altar.php?action=Yep.&oath=I+have+read+the+Policies+of+Loathing%2C+and+I+promise+to+abide+by+them.&t1=3&t2=1&t3=3&y1=1&y2=1&horsecolor=black&literacy=Submit&pwd");
}


void drhoboquest()
{
	if(!contains_text(visit_url("questlog.php?which=3&pwd"),"Dr. Hobo Jones's treasure.") && my_adventures()>0)
	{
		dress_for_fighting();
		print("doing dr hobo quest","blue");
		while(item_amount($item[Dr. Hobo's map])==0 && my_adventures()>0)
		{
			print("getting map","blue");
			adventure(1,$location[Outskirts of the Knob ]);
		}
		if(item_amount($item[cool whip])==0)
		{
			print("buying whip","blue");
			buy(1,$item[cool whip]);
		}
		while(item_amount($item[asparagus knife])==0 && my_adventures()>0)
		{
			print("getting asparagus knife","blue");
			adventure(1,$location[Haunted Pantry ]);
		}
		if(my_adventures()>0)
		{
			cli_execute("checkpoint");
			cli_execute("equip cool whip");
			use(1,$item[Dr. Hobo's map]);
			cli_execute("outfit checkpoint");
		}
	}
	else
	{
		print("done hobo map");
	}
}


void haikuchallengequest()
{
	if(!contains_text(visit_url("questlog.php?which=3&pwd"),"completed the Most Extreme Haiku Challenge"))
	{
		dress_for_fighting();
		print("doing haiku quest","blue");
		string next_thing;

		while(item_amount($item[Haiku challenge map])==0 && my_adventures()>0)
		{
			adventure(1,$location[Haiku Dungeon]);
		}
		if(item_amount($item[Haiku challenge map])!=0)
		{
			next_thing = visit_url("inv_use.php?&pwd&which=3&whichitem=3461");
		
			//5 sylable
			if(contains_text(next_thing,"Snatch the pebble from my hand."))
			{
				print("lol");
				next_thing = visit_url("haiku.php?action=Yep.&option=2&pwd");
			}
			else if(contains_text(next_thing,"Make the right choice and advance."))
			{
				print("lol2");//
				next_thing = visit_url("haiku.php?action=Yep.&option=1&pwd");
			}
			else if(contains_text(next_thing,"Pudgy caucasian ninja."))
			{
				print("lol3");//
				next_thing = visit_url("haiku.php?action=Yep.&option=2&pwd");
			}
			else if(contains_text(next_thing,"Hit the button and get it."))
			{
				print("lol4");//
				next_thing = visit_url("haiku.php?action=Yep.&option=3&pwd");
			}
			else
			{
				print("lol5");//
				next_thing = visit_url("haiku.php?action=Yep.&option=1&pwd");
			}


			//7 sylable
			if(contains_text(next_thing,"Snatch the pebble from my hand."))
			{
				print("lol");//
				next_thing = visit_url("haiku.php?action=Yep.&option=1&pwd");
			}
			else if(contains_text(next_thing,"Make the right choice and advance."))
			{
				print("lol2");//
				next_thing = visit_url("haiku.php?action=Yep.&option=3&pwd");
			}
			else if(contains_text(next_thing,"Pudgy caucasian ninja."))
			{
				print("lol3");//
				next_thing = visit_url("haiku.php?action=Yep.&option=3&pwd");
			}
			else if(contains_text(next_thing,"Hit the button and get it."))
			{
				print("lol4");//
				next_thing = visit_url("haiku.php?action=Yep.&option=1&pwd");
			}
			else
			{
				print("lol5");//
				next_thing = visit_url("haiku.php?action=Yep.&option=2&pwd");
			}




			//5 sylable
			if(contains_text(next_thing,"Snatch the pebble from my hand."))
			{
				print("lol");
				next_thing = visit_url("haiku.php?action=Yep.&option=2&pwd");
			}
			else if(contains_text(next_thing,"Make the right choice and advance."))
			{
				print("lol2");//
				next_thing = visit_url("haiku.php?action=Yep.&option=1&pwd");
			}
			else if(contains_text(next_thing,"Pudgy caucasian ninja."))
			{
				print("lol3");//
				next_thing = visit_url("haiku.php?action=Yep.&option=2&pwd");
			}
			else if(contains_text(next_thing,"Hit the button and get it."))
			{
				print("lol4");//
				next_thing = visit_url("haiku.php?action=Yep.&option=3&pwd");
			}
			else
			{
				print("lol5");//
				next_thing = visit_url("haiku.php?action=Yep.&option=1&pwd");
			}
		}

	}
	else
	{
		print("Done Haiku Challenge quest");
	}

}


void main()
{
	hammerquest();
	bakerquest();
	woundedquest();
	Literacyquest();
	drhoboquest();
	haikuchallengequest();
}
