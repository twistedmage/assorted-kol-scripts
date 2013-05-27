import <Questlib.ash>;

void Fengshui()
{
	if(contains_text(visit_url("campground.php?action=inspectdwelling&pwd"), "chimes.gif"))
	{
		print("Already gotten Feng Shui.");
	}
	else
	{
		dress_for_fighting();
		if (available_amount($item[Feng Shui for Big Dumb Idiots]) == 0)
		{
			retrieve_item(1, $item[Feng Shui for Big Dumb Idiots]);
			if (available_amount($item[Feng Shui for Big Dumb Idiots]) == 0)
			{
				//farm for it
				cli_execute("conditions clear");
				add_item_condition(1, $item[Feng Shui for Big Dumb Idiots]);
				boolean catch=adventure(my_adventures(), $location[Hippy Camp]);
			}
		}
		if (available_amount($item[windchimes]) == 0)
		{
			retrieve_item(1, $item[windchimes]);
			if (available_amount($item[windchimes]) == 0)
			{
				//farm for it
				cli_execute("conditions clear");
				add_item_condition(1, $item[windchimes]);
				boolean catch=adventure(my_adventures(), $location[Hippy Camp]);
			}
		}
		if (available_amount($item[decorative fountain]) == 0)
		{
			retrieve_item(1, $item[decorative fountain]);
			if (available_amount($item[decorative fountain]) == 0)
			{
				//farm for it
				cli_execute("conditions clear");
				add_item_condition(1, $item[decorative fountain]);
				boolean catch=adventure(my_adventures(), $location[Hippy Camp]);
			}
		}
		use(1, $item[Feng Shui for Big Dumb Idiots]);
	}
	if(contains_text(visit_url("campground.php?action=inspectdwelling&pwd"), "guildapp.gif"))
	{
		print("Already placed Certificate.");
	}
	else
	{
		if (available_amount($item[Certificate of Participation]) == 0)
		{
			print("Not completed toot oriole quest yet");
		}
		else
		{
			use(1, $item[Certificate of Participation]);
		}
	}
	if(contains_text(visit_url("campground.php?action=inspectdwelling&pwd"), "beanbag.gif"))
	{
		print("Already gotten beanbag.");
	}
	else
	{
		if (available_amount($item[Beanbag chair]) == 0)
		{
			print("Need to make our own beanbag.");
			if (available_amount($item[filthy knitted dread sack]) == 0)
			{
				print("Farming for dread sack.");
				//farm for it
				cli_execute("conditions clear");
				add_item_condition(1, $item[filthy knitted dread sack]);
				boolean catch=adventure(my_adventures(), $location[Hippy Camp]);				
			}
			if (available_amount($item[hill of beans]) == 0)
			{
				print("farming for beans.");
				//farm for it
				cli_execute("conditions clear");
				add_item_condition(1, $item[hill of beans]);
				boolean catch=adventure(my_adventures(), $location[Knob Goblin Treasury]);
			}
			create(1, $item[Beanbag chair]);
		}
		use(1, $item[Beanbag chair]);
	}
}

void main()
{
	Fengshui();
}