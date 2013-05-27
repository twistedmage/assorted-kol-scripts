import <QuestLib.ash>;
import <Dinghy.ash>;

int insult_count()
{
	int totalInsults = 0;
	for i from 1 upto 8
	{
		if (to_boolean(get_property("lastPirateInsult" + to_string(i))))
		{
			totalInsults = totalInsults + 1;
		}
	}

	return totalInsults;

}

string beer_pong(string page)
{
	record r
	{
		string insult;
		string retort;
	};

	r [int] insults;

	insults[1].insult="Arrr, the power of me serve'll flay the skin from yer bones!";
	insults[1].retort="Obviously neither your tongue nor your wit is sharp enough for the job.";

	insults[2].insult="Do ye hear that, ye craven blackguard?  It be the sound of yer doom!";
	insults[2].retort="It can't be any worse than the smell of your breath!";

	insults[3].insult="Suck on <i>this</i>, ye miserable, pestilent wretch!";
	insults[3].retort="That reminds me, tell your wife and sister I had a lovely time last night.";

	insults[4].insult="The streets will run red with yer blood when I'm through with ye!";
	insults[4].retort="I'd've thought yellow would be more your color.";

	insults[5].insult="Yer face is as foul as that of a drowned goat!";
	insults[5].retort="I'm not really comfortable being compared to your girlfriend that way.";

	insults[6].insult="When I'm through with ye, ye'll be crying like a little girl!";
	insults[6].retort="It's an honor to learn from such an expert in the field.";

	insults[7].insult="In all my years I've not seen a more loathsome worm than yerself!";
	insults[7].retort="Amazing!  How do you manage to shave without using a mirror?";

	insults[8].insult="Not a single man has faced me and lived to tell the tale!";
	insults[8].retort="It only seems that way because you haven't learned to count to one.";

	while (!page.contains_text("victory laps"))
	{
		string old_page = page;

		if (!page.contains_text("Insult Beer Pong"))
		{
			abort("You don't seem to be playing Insult Beer Pong.");			
		}

		if (page.contains_text("Phooey"))
		{
			print("Looks like something went wrong and you lost.", "red");
			return page;
		}
	
		foreach i in insults
		{
			if (page.contains_text(insults[i].insult))
			{
				if (page.contains_text(insults[i].retort))
				{
					print("Found appropriate retort for insult.", "green");
					print("Insult: " + insults[i].insult);
					print("Retort: " + insults[i].retort);
					page = visit_url("beerpong.php?value=Retort!&response=" + i);
					break;			
				}
				else
				{
					print("Looks like you needed a retort you haven't learned.", "red");
					print("Insult: " + insults[i].insult);
					print("Retort: " + insults[i].retort);
	
					// Give a bad retort
					page = visit_url("beerpong.php?value=Retort!&response=9");
					return page;
				}
			}
		}

		if (page == old_page)
		{
			abort("String not found. There may be an error with one of the insult or retort strings.");
		}
	}

	print("You won a thrilling game of Insult Beer Pong!", "green");
	return page;
}

string pirate_fight()
{
	if (available_amount($item[The Big Book of Pirate Insults]) == 0)
	{
		buy(1, $item[The Big Book of Pirate Insults]);
	}
	if (available_amount($item[The Big Book of Pirate Insults]) == 0)
	{
        abort("Couldn't buy The Big Book of Pirate Insults");
	}

	request_monsterlevel(0);

	string page = visit_url("adventure.php?snarfblat=157");
	
	if (contains_text(page, "Combat"))
	{
		if (insult_count() < 8)
		{
			if (contains_text(page, "Pirate"))
			{
				throw_item($item[The Big Book of Pirate Insults]);
			}
        }
		while(!page.contains_text("You win the fight!"))
		{
			page = run_combat();
		}

		print("You have learned " + to_string(insult_count()) + "/8 pirate insults.", "blue");
	}
	else if (contains_text(page, "Arrr You Man Enough?"))
	{
		int totalInsults = insult_count();
		if (totalInsults > 6)
		{
			print("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue");
			page = beer_pong( visit_url( "choice.php?pwd&whichchoice=187&option=1" ) );
		}
		else
		{
			print("You have learned " + to_string(totalInsults) + "/8 pirate insults.", "blue");
			print("Arrr You Man Enough?", "red");
			page = visit_url( "choice.php?pwd&whichchoice=187&option=2" );
		}
	}
	else if (contains_text(page, "Arrr You Man Enough?"))
	{
		page = beer_pong(page);
	}
	else
	{
		page = run_choice(page);
	}

	return page;
}

void PirateQuest()
{
	set_pirate_choices();

	if (available_amount($item[pirate fledges]) == 0)
	{
		DinghyQuest();

		try_acquire(1, $item[eyepatch]);
		try_acquire(1, $item[swashbuckling pants]);
		try_acquire(1, $item[stuffed shoulder parrot]);

		try_storage(1, $item[eyepatch]);
		try_storage(1, $item[swashbuckling pants]);
		try_storage(1, $item[stuffed shoulder parrot]);

		if ((!have_outfit("swashbuckling getup")) &&
			(true))
		{
			cli_execute("conditions clear");
			set_location($location[Pirate Cove]);
			cli_execute("conditions add outfit");

			adventure(request_noncombat(my_adventures()), $location[Pirate Cove]);
		}

		if (!contains_text(visit_url("questlog.php?which=1"),"I Rate, You Rate"))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
	
			while (my_adventures() > 0 && (available_amount($item[Cap'm Caronch's Map]) == 0))
			{
				pirate_fight();
			}
	
			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"A salty old pirate named Cap'm Caronch has offered to let you join his crew if you find some treasure for him."))
		{print("----TEST2");
			if (available_amount($item[Cap'm Caronch's Map]) > 0 && my_adventures()>0)
			{

				use(1, $item[Cap'm Caronch's Map]);
				run_combat();
			}
		}

		if (contains_text(visit_url("questlog.php?which=1"),"Now that you've found Cap'm Caronch's booty (and shaken it a few times), you should probably take it back to him."))
		{print("----TEST3");
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
	
			while (my_adventures() > 0 && (available_amount($item[Orcish Frat House blueprints]) == 0))
			{
				pirate_fight();
			}
	
			cli_execute("outfit checkpoint");
		}

		// Get the insults before using the frat house map
		if (insult_count() <= 6)
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");

			while (my_adventures() > 0 && insult_count() <= 6)
			{
				pirate_fight();
			}

			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"Cap'm Caronch has given you a set of blueprints to the Orcish Frat House, and asked you to steal his dentures back from the Frat Orcs."))
		{
			if (available_amount($item[Orcish Frat House blueprints]) > 0 && my_adventures()>0)
			{
				if (available_amount($item[Cap'm Caronch's dentures]) == 0)
				{
					if ((available_amount($item[frilly skirt]) == 0) && (available_amount($item[hot wing]) >= 3))
					{
						if (in_muscle_sign())
						{
							buy(1, $item[frilly skirt]);
						}
					}
	
					if ((available_amount($item[frilly skirt]) > 0) && (available_amount($item[hot wing]) >= 3))
					{
						cli_execute("checkpoint");
						equip($item[frilly skirt]);
						set_property("choiceAdventure188", "3");
						use(1, $item[Orcish Frat House blueprints]);
						cli_execute("outfit checkpoint");
					}
				}

				if (available_amount($item[Cap'm Caronch's dentures]) == 0)
				{
					if ((available_amount($item[mullet wig]) > 0) && (available_amount($item[briefcase]) > 1))
					{
						cli_execute("checkpoint");
						equip($item[mullet wig]);
						set_property("choiceAdventure188", "2");
						use(1, $item[Orcish Frat House blueprints]);
						cli_execute("outfit checkpoint");
					}
				}

				if (available_amount($item[Cap'm Caronch's dentures]) == 0)
				{
					boolean catch;
					while(!have_outfit("Frat Boy Ensemble") && my_adventures()>0)
					{
						cli_execute("conditions clear");
						set_location($location[Frat House]);
						cli_execute("conditions add outfit");
						catch = adventure(request_monsterlevel(1), $location[Frat House]);
					}
					cli_execute("conditions clear");
	
					if (have_outfit("Frat Boy Ensemble"))
					{
						cli_execute("checkpoint");
						outfit("Frat Boy Ensemble");
						set_property("choiceAdventure188", "1");
						use(1, $item[Orcish Frat House blueprints]);
						cli_execute("outfit checkpoint");
					}
				}
			}
		}

		if (contains_text(visit_url("questlog.php?which=1")," time to take the nasty things back to him"))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
			cli_execute("inventory refresh");
			while (available_amount($item[Cap'm Caronch's dentures]) > 0)
			{
				print("pirate_fight time","blue");
				pirate_fight();
			}                  
			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You've completed two of Cap'm Caronch's tasks, but (surprise surprise) he's got a third one for you before you can join his crew."))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
			while (my_adventures() > 0)
			{
				if (pirate_fight().contains_text("victory laps"))
				{
					break;					
				}
			}
			cli_execute("outfit checkpoint");
		}

		if (contains_text(visit_url("questlog.php?which=1"),"You have successfully joined Cap'm Caronch's crew!"))
		{
			cli_execute("checkpoint");
			outfit("swashbuckling getup");
			cli_execute("conditions clear");
			while ((my_adventures() > 0) && available_amount($item[pirate fledges]) == 0 && my_adventures()>0)
			{
				print("Looking for pirate cleaning items");
				adventure(request_monsterlevel(1), $location[F'c'le]);

				if (available_amount($item[mizzenmast mop]) > 0)
				{
					use(1, $item[mizzenmast mop]);
				}
				if (available_amount($item[ball polish]) > 0)
				{
					use(1, $item[ball polish]);
				}
				if (available_amount($item[rigging shampoo]) > 0)
				{
					use(1, $item[rigging shampoo]);
				}
			}
			cli_execute("outfit checkpoint");
		}
	}
	else
	{
		print("You have already have the pirate fledges.");
	}
}

void main()
{
	PirateQuest();
}
