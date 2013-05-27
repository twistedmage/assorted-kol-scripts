import <QuestLib.ash>;
import <Meatcar.ash>;

void DinghyQuest()
{
	MeatCarQuest();

	if (available_amount($item[dingy dinghy]) == 0)
	{
		dress_for_fighting();
		cli_execute("conditions clear");

		while (available_amount($item[dinghy plans]) == 0 && my_adventures()>2)
		{

			if (my_primestat() == $stat[moxie])
			{
				visit_url("shore.php?pwd&whichtrip=3");
			}
			else if (my_primestat() == $stat[mysticality])
			{
				visit_url("shore.php?pwd&whichtrip=2");
			}
			else
			{
				visit_url("shore.php?pwd&whichtrip=1");
			}
		}

		if (available_amount($item[dingy planks]) == 0)
		{
			if ((available_amount($item[worthless gewgaw]) == 0) &&
				(available_amount($item[worthless knick-knack]) == 0) &&
				(available_amount($item[worthless trinket]) == 0))
			{
				cli_execute("conditions clear");
				cli_execute("acquire 1 worthless item");
			}
			try_acquire(1, $item[dingy planks]);
		}

		if ((available_amount($item[dinghy plans]) > 0) && (available_amount($item[dingy planks]) > 0))
		{
			use(1, $item[dinghy plans]); 
		}
	}
	else
	{
		print("You have already created a dingy dinghy.");
	}
}

void main()
{
	DinghyQuest();
}
