import <QuestLib.ash>;

void GoblinQuest()
{
	if (my_level() >= 5)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"The Goblin Who Wouldn't Be King"))
		{
			dress_for_fighting();
			if (!contains_text(visit_url("plains.php"),"knob2.gif"))
			{
				if (available_amount($item[Knob Goblin encryption key]) == 0)
				{
					cli_execute("conditions clear");
					add_item_condition(1, $item[Knob Goblin encryption key]);
					adventure(request_noncombat(my_adventures()), $location[outskirts of the Knob]);
				}
				use(1, $item[Cobb's Knob map]);
			}
			else
			{
				print("Cobb's Knob is already available.");
			}

			try_acquire(1, $item[Knob Goblin perfume]);
			try_acquire(1, $item[Knob Goblin harem pants]);
			try_acquire(1, $item[Knob Goblin harem veil]);

			try_storage(1, $item[Knob Goblin perfume]);
			try_storage(1, $item[Knob Goblin harem pants]);
			try_storage(1, $item[Knob Goblin harem veil]);
	
			if ((!have_outfit("knob goblin harem girl disguise")) || (available_amount($item[knob goblin perfume]) == 0))
			{
				cli_execute("conditions clear");
				set_location($location[Knob Goblin Harem]);
				cli_execute("conditions add outfit");

				if (available_amount($item[knob goblin perfume]) == 0)
				{
					add_item_condition(1, $item[knob goblin perfume]);
				}
				adventure(request_noncombat(my_adventures()), $location[Knob Goblin Harem]);
			}
  
	
			if ((have_outfit("knob goblin harem girl disguise")) && (available_amount($item[knob goblin perfume]) > 0) && my_adventures()>0)
			{
				request_monsterlevel(0);

				cli_execute("checkpoint");
				outfit("Knob Goblin Harem Girl Disguise");
				use(1, $item[knob goblin perfume]);
				adventure(1, $location[King's Chamber]);
				cli_execute("outfit checkpoint");
			}

			increase_mcd();
	
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"The Goblin Who Wouldn't Be King"))
		{
			print("You have already completed the level 5 quest.");
		}
		else
		{
			print("The level 5 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 5 to attempt this quest.");
	}
}

void main()
{
	GoblinQuest();
}
