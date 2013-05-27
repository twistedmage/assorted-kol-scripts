//run old ver buff script first

import <eatdrink.ash>;

void main()
{


	if( my_name() == "twistedmage")
	{
//drink while you have ode to booze
		cli_execute("zlib eatdrink_budget = 20000");
		eatdrink(fullness_limit(),inebriety_limit(),spleen_limit(),true,200,25,5,1000,false);
		cli_execute( "outfit items" );
		cli_execute( "familiar jitterbug" );
		location FARM_LOCATION1 = $location[McMillicancuddy's Farm];
		adventure(15, FARM_LOCATION1);

		cli_execute( "bounty.ash accept small" );
		cli_execute( "bounty.ash 40" );
//		milk of magnesium;
		
		cli_execute( "eatdrink.ash" );
//		eatsushi.ash;
		cli_execute( "familiar dancing frog" );
		cli_execute( "outfit water" );
//tempura
		location FARM_LOCATION2 = $location[The Marinara Trench];
		add_item_condition( 3 , $item[bubbling tempura batter] );

//		Cli_execute( "conditions add +3 bubbling tempura batter" );
//		Cli_execute( "adventure 100 Itznotyerzitz Mine" );
//		add_item_condition(1, 3 bubbling tempura batter);
		adventure(1, FARM_LOCATION2);

//buffs
		cli_execute( "skate bandshell" );
		cli_execute( "skate merry" );
		cli_execute( "skate eclectic eels" );
		cli_execute( "concert Winklered" );
		cli_execute( "friars blessing food" );
	}
	else
	{
		if(my_level()>7) //if over level 7 run eatdrink
		{
			cli_execute("zlib eatdrink_budget = 1000");
			eatdrink(fullness_limit(),inebriety_limit(),spleen_limit(),true,50,25,5,1000,false);
		}
		cli_execute( "outfit meat" );
		cli_execute( "familiar Squamous Gibberer" );
		cli_execute( "bounty.ash accept small" );
		cli_execute( "bounty.ash 40" );
		if(my_level()>7) //if over level 7 farm rice
		{
//white rice	
			cli_execute( "outfit rice" );
			set_property("choiceAdventure73", "3");
			location FARM_LOCATION3 = $location[Whitey's Grove];
			add_item_condition( 3 , $item[white rice] );
			adventure(1, FARM_LOCATION3);
		}
		cli_execute( "familiar dancing frog" );
		cli_execute( "hermit" );
		cli_execute( "barrel.ash" );
//		upgrade booze?
//		make milk of magnesia + mail to twisted
//		make sake + mail		
	}
}