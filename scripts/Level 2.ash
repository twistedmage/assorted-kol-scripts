import <QuestLib.ash>;

void MosquitoQuest()
{
    if (my_level() >= 2)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Looking for a Larva in All the Wrong Places"))
		{
			set_property("choiceAdventure502", "2");
			set_property("choiceAdventure505", "1");
			while(available_amount($item[mosquito larva]) == 0 && my_adventures()>0)
			{
				cli_execute("conditions clear");
				adventure(1, $location[Spooky Forest]);
			}
			print("You've acquired a mosquito larva.");
			
			council();
			if(can_interact())
			{
				if(item_amount($item[Familiar-Gro™ Terrarium])==0)
				{
					buy(1,$item[Familiar-Gro™ Terrarium]);
				}
				use(1,$item[Familiar-Gro™ Terrarium]);
				cli_execute("refresh inventory");
				if(item_amount($item[Mosquito larva])>0)
				{
					use(1,$item[mosquito larva]);
				}
				use_familiar($familiar[Mosquito]);
			}
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Looking for a Larva in All the Wrong Places"))
		{
			print("You have already completed the level 2 quest.");
		}
		else
		{
			print("The level 2 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 2 to attempt this quest.");
	}
}

void main()
{
	MosquitoQuest();
}