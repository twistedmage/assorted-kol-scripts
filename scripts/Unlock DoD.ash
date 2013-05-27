import <QuestLib.ash>;

void UnlockDoD()
{
	boolean catch;
	if (!contains_text(visit_url("questlog.php?which=3"),"You have discovered the secret of the Dungeons of Doom"))
	{
		dress_for_fighting();
		//get plus sign
			cli_execute("conditions clear");
		while (available_amount($item[plus sign]) == 0 && my_adventures()>0)
		{
			set_property("choiceAdventure451", "3");

			if (have_effect($effect[Teleportitis]) > 0)
			{
				cli_execute("uneffect Teleportitis");
			}

			add_item_condition(1,$item[dead mimic]);
			catch = adventure(request_apathetic(1), $location[Greater-Than Sign]);
		}

		while(available_amount($item[plus sign]) > 0 && my_adventures()>0)
		{
			set_property("choiceAdventure451", "5");
			if ((my_meat() < 1000))
			{
				abort("You need at least 1000 meat to pay the oracle.");
				return;				
			}

			//get teleportitis
			add_item_condition(1,$item[dead mimic]);
			while (have_effect($effect[Teleportitis]) == 0 && my_adventures()>0)
			{
				catch = adventure(request_apathetic(1), $location[Greater-Than Sign]);
			}

			//try to meet oracle
			if ((have_effect($effect[Teleportitis]) > 0) && (my_meat() > 1000))
			{
				// Oracle is an autostop adventure.
				catch = adventure(request_apathetic(have_effect($effect[Teleportitis])), $location[Greater-Than Sign]);
			}
			
			//if we got drunk
			if(my_inebriety()> inebriety_limit())
			{
				print("We got drunk from the lame teleportitis, lets go to bed","red");
				cli_execute("bed.ash");
			}

			//try to use plus
			catch = use(1, $item[plus sign]);
		}

		if (have_effect($effect[Teleportitis]) > 0)
		{
			cli_execute("uneffect Teleportitis");
		}
		set_property("choiceAdventure451", "4");
	}
	else
	{
		boolean have_wand=false;
		for i from 1268 to 1272
			if(item_amount(to_item(i)) > 0)
			{
				have_wand=true;
			}
		print("have_wand="+have_wand,"blue");	
		if(!have_wand)
		{
			set_property("choiceAdventure25", "2");
			while(my_meat()>5000 && my_adventures()>0 && item_amount($item[dead mimic])<1)
			{
				add_item_condition(1,$item[dead mimic]);
				catch = adventure(1,$location[dungeons of doom]);
			}
			set_property("choiceAdventure25", "3");
			if(item_amount($item[dead mimic])>0)
			{
				use(1,$item[dead mimic]);
			}
		}
		print("You have already unlocked the Dungeons of Doom.");
	}
    
}

void main()
{
	UnlockDoD();
}
