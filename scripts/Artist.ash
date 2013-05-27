import <QuestLib.ash>;

void ArtistQuest()
{
	visit_url("town_wrong.php?place=artist");

	if (contains_text(visit_url("questlog.php?which=1"),"Suffering For His Art"))
	{
		if(available_amount($item[pretentious palette]) == 0)
		{
			cli_execute("conditions clear");
			add_item_condition(1, $item[pretentious palette]);
			adventure(request_noncombat(my_adventures()), $location[Haunted Pantry]);
		}
		if (available_amount($item[pretentious paintbrush]) == 0)
		{
			cli_execute("conditions clear");
			add_item_condition(request_noncombat(1), $item[pretentious paintbrush]);
			adventure(request_noncombat(my_adventures()), $location[Outskirts of the Knob]);
		}
		if (available_amount($item[pail of pretentious paint]) == 0)
		{
			cli_execute("conditions clear");
			add_item_condition(request_noncombat(1), $item[pail of pretentious paint]);
			adventure(request_noncombat(my_adventures()), $location[Sleazy Back Alley]);
		}

		visit_url("town_wrong.php?place=artist");
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"Suffering For His Art"))
	{
		print("You have already completed the Pretentious Artist quest.");
	}
	else
	{
		print("The Pretentious Artist quest is not currently available.");
	}
}

void main()
{
	ArtistQuest();
}