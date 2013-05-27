//40 of each part

void main()
{
//	if(available_amount($item[hobo nickel])>3600)
//		abort("Have enough nickels!");
	//dress for farming
	print("farming nickels in town square","blue");
//	cli_execute("familiar syncopated turtle");
	cli_execute("familiar jack-in-the-box");
	string eq;
	if(available_amount($item[Flail of the Seven Aspects])!=0)
	{
//		eq+=", equip Flail of the Seven Aspects";
	}
	else if(available_amount($item[Flail of the Seven Aspects])==0)
	{
//		eq+=", equip turtling rod";
	}
	if(available_amount($item[old soft shoes])>0)
	{
		eq+=", equip old soft shoes";
	}
	if(available_amount($item[lil businessman kit])>0)
	{
		eq+=", equip businessman kit";
	}
//	eq+=", equip ring of conflict, equip space trip safety headphones";
	print("maximize items, +melee"+eq);
	cli_execute("maximize items, +melee"+eq);
	cli_execute("outfit save farm");
	equip($item[mayfly bait necklace]);
	//use once a day
/*	if(available_amount($item[moveable feast])>0)
		use(1,$item[moveable feast]);
	if(available_amount($item[legendary beat])>0)
		use(1,$item[legendary beat]);
	cli_execute("friars familiar");
	cli_execute("pool stylish");
	cli_execute("pool stylish");
	cli_execute("pool stylish");*/
	//now farm
	boolean done;
	while(my_adventures()>0)
	{
		//switch off mayflies
		if(to_int(get_property("_mayflySummons"))>29)
			outfit("farm");
		if(have_effect($effect[Eau de Tortue])==0)
		{
//			use(1,$item[Turtle pheromones]);
		}
		if(have_effect($effect[fresh scent])==0)
		{
//			use(1,$item[rock salt]);
		}
		if(have_effect($effect[smooth movements])==0)
		{
//			cli_execute("cast smooth movement");
		}
		if(have_effect($effect[sonata of sneakiness])==0)
		{
//			cli_execute("cast sonata of sneakiness");
		}
		done=adventure(1,$location[the ancient hobo burial ground]);
		if(available_amount($item[hobo nickel])>3600)
		{
			print("Have enough nickels!");
//			break;
		}
	}
	cli_execute("use * boxcar turtle");
	print("now have "+ available_amount($item[hobo nickel])+" hobo nickels");
}