import <eatdrink.ash>;
import <questlib.ash>;

void getsummon()
{
	if(my_class()==$class[pastamancer])
	{
		if(get_property("pastamancerGhostType")!="Boba Fettucini")
		{
			dress_for_fighting();
			print("You have the wrong, or no, ghost type, lets fix that!","blue");
			cli_execute("conditions clear");
			cli_execute("condition add Twitching trigger finger");
			boolean catch = adventure(my_adventures(),$location[Desert (Unhydrated)]);
			//now try to use it
			if(contains_text(visit_url("inv_use.php?&pwd&which=3&whichitem=3789"),"Are you sure you want to do this?"))
			{
				//click yes
				visit_url("inv_use.php?whichitem=3789&confirm=true&which=3&pwd");
			}
			//now remove naughty effects
			while(my_adventures()>0 && my_buffedstat(my_primestat())< my_basestat(my_primestat()))
			{
				set_property("choiceAdventure502","3");
				set_property("choiceAdventure506","1");
				set_property("choiceAdventure26","2");
				set_property("choiceAdventure28","2");
				adventure(1,$location[spooky forest]);
			}
		}
		else
		{
			print("Already got a bobba fet, you lucky man!","blue");
		}
	}
	else
	{
		print("cant get a summon pet since you're not a pastamancer");
	}
}

void main()
{
	getsummon();
}