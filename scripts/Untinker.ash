import <QuestLib.ash>;

void UntinkerQuest()
{
	if ((contains_text(visit_url("questlog.php?which=1"),"My Other Car Is Made of Meat")) || (contains_text(visit_url("questlog.php?which=2"),"My Other Car Is Made of Meat")))
	{
		visit_url("forestvillage.php?action=screwquest");

		if (contains_text(visit_url("questlog.php?which=1"),"Driven Crazy"))
		{
			if (available_amount($item[rusty screwdriver]) == 0)
			{
				if (in_muscle_sign())
				{
					visit_url("knoll.php?place=smith");
				}
				else
				{
					dress_for_fighting();
					cli_execute("conditions clear");
					add_item_condition(1, $item[rusty screwdriver]);
					boolean catch=adventure(request_noncombat(my_adventures()), $location[Degrassi Knoll]);
				}
				
			}
			visit_url("forestvillage.php?place=untinker");
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Driven Crazy"))
		{
			print("You have already completed the Untinker quest.");
		}
		else
		{
			print("The Untinker quest is not currently available.");
		}
	}
	else
	{
		print("You must have gotten the Meat Car quest to attempt the Untinker Quest.");
	}
}

void main()
{
	UntinkerQuest();
}
