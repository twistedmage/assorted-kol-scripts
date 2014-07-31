import <sims_lib.ash>;
//import <eatdrink.ash>;

//banky and twisted should do cold
//after completion (twice). remove false from line 464 in a-questing.ash

//SEWER MAZE: CHANGE THESE 2 WHEN 20 VALVES/GRATES DONE
boolean wheels_done=false;
boolean grates_done=false;
boolean cage_sit=false;
//FROST
boolean enough_icicles=true; //CHANGE TO TRUE WHEN 50 PIPES BROKE (40 if more than 1 person is doing it)
//FIRE
boolean do_tireavalanche=true; //this should be switched to true whenever 34 tires on stack, then back to false after tirevalanche
//SLEAZE
boolean enter_club=true; //13 pipes + 8 flimflams then change to true
//SPOOKY: choose 2 players with lots of turns left who can dance
string dancer1="twistedmage";
string dancer2="twistedmage";

//which zones should we do?
boolean do_scarebo=false;
boolean do_stench=false;
boolean do_cold=false;
boolean do_hot=false;
boolean do_sleaze=false;
boolean do_spooky=true;

//hot part farmers
string name1 = "twistedmage"; //hot
string name2 = "twistedmage"; //cold
string name3 = "twistedmage"; //sleaze
string name4 = "twistedmage"; //spooky
string name5 = "twistedmage"; //stench
string name6 = "twistedmage"; //physical


void take_muscle_gear()
{
	if(available_amount($item[moist sailor's cap])==0)
	{
		cli_execute("stash take moist sailor's cap");
	}
	if(available_amount($item[letterman's jacket])==0)
	{
		cli_execute("stash take letterman's jacket");
	}
	if(available_amount($item[rhinestone cowboy shirt])==0)
	{
		cli_execute("stash take rhinestone cowboy shirt");
	}
	if(available_amount($item[fish scimitar])==0)
	{
		cli_execute("stash take fish scimitar");
	}
	if(available_amount($item[greatest american pants])==0)
	{
		cli_execute("stash take greatest american pants");
	}
	if(available_amount($item[corncob pipe])==0)
	{
		cli_execute("stash take corncob pipe");
	}
	if(available_amount($item[v for vivala mask])==0)
	{
		cli_execute("stash take v for vivala mask");
	}
	if(available_amount($item[depleted grimacite weightlifting belt])==0)
	{
		cli_execute("stash take depleted grimacite weightlifting belt");
	}
	if(available_amount($item[teflon shield])==0)
	{
		cli_execute("stash take teflon shield");
	}
	cli_execute("maximize muscle, +melee");
}

void return_muscle_gear()
{
	cli_execute("outfit birthday suit");
	cli_execute("stash put moist sailor's cap");
	cli_execute("stash put letterman's jacket");
	cli_execute("stash put rhinestone cowboy shirt");
	cli_execute("stash put fish scimitar");
	cli_execute("stash put greatest american pants");
	cli_execute("stash put corncob pipe");
	cli_execute("stash put v for vivala mask");
	cli_execute("stash put depleted grimacite weightlifting belt");
	cli_execute("stash put teflon shield");
}


boolean done_in_sewers()
{
	return check_page("clan_hobopolis.php","deeper.gif");
}

void ensure_muscle_buffs()
{
	if(have_effect($effect[go get 'em, tiger])==0)
	{
		use(1,$item[ben-gal balm]);
	}
	if(have_effect($effect[butt rock hair])==0)
	{
		use(1,$item[hair spray]);
	}
	if(have_effect($effect[temporary lycanthropy])==0)
	{
		use(1,$item[blood of the wereseal]);
	}
	if(have_effect($effect[having a ball!])==0)
	{
//		boolean catch=cli_execute("ballpit");
	}
	if(have_effect($effect[black face])==0)
	{
		use(1,$item[black facepaint]);
	}
	if(have_effect($effect[muscularrr])==0)
	{
		use(1,$item[pirate brochure]);
	}
	if(have_effect($effect[ham-fisted])==0)
	{
//		use(1,$item[flask of hamethyst juice]);
	}
}

void ensure_nocom_buffs()
{
	cli_execute("refresh effects");
	cli_execute("uneffect hippy stench");
	cli_execute("uneffect ode");
	cli_execute("uneffect musk of the moose");
	cli_execute("uneffect Carlweather's Cantata of Confrontation");
	if(have_effect($effect[fresh scent])==0)
	{
		use(1,$item[chunk of rock salt]);
	}
	if(have_effect($effect[the sonata of sneakiness])==0 && !to_boolean(get_property("_sonata_requested_"+my_name())))
	{
	
		meatmail("NotBot", 430);
//		meatmail("IocaineBot", 18);
//		meatmail("kolabuff", 23);
//		meatmail("SevenLances_com", 2);
//		meatmail("Noblesse Oblige", 21);
		set_property("_sonata_requested_"+my_name(),true);
	}
	if(have_effect($effect[Smooth Movement])==0 && have_skill($skill[Smooth Movement]))
	{
		cli_execute("cast Smooth Movement");
	}
	if(available_amount($item[ring of conflict])<1)
	{
		buy(1,$item[ring of conflict]);
	}
	cli_execute("unequip monster bait");
	cli_execute("equip acc1 ring of conflict");
	if(available_amount($item[space trip safety headphones])>0)
	{
		cli_execute("equip acc2 space trip safety");
	}
	if(have_familiar($familiar[squamous gibberer]))
		use_familiar($familiar[squamous gibberer]);
}

void ensure_com_buffs()
{
	cli_execute("mood clear");
	cli_execute("refresh effects");
	cli_execute("uneffect fresh scent");
	cli_execute("uneffect smooth movements");
	cli_execute("uneffect the sonata of sneakiness");
	cli_execute("uneffect ode");
	if(have_effect($effect[hippy stench])==0)
	{
		use(1,$item[reodorant]);
	}
	if(have_effect($effect[Carlweather's Cantata of Confrontation])==0)
	{
//		meatmail("IocaineBot", 19);
//		meatmail("kolabuff", 22);
//		meatmail("SevenLances_com", 16);
	}
	if(have_effect($effect[musk of the moose])==0 && have_skill($skill[musk of the moose]))
	{
		cli_execute("cast musk of the moose");
	}
	if(available_amount($item[monster bait])<1)
	{
		buy(1,$item[monster bait]);
	}
	cli_execute("unequip ring of conflict");
	cli_execute("equip monster bait");
	if(have_familiar($familiar[jumpsuited hound dog]))
	{
		use_familiar($familiar[jumpsuited hound dog]);
	}
}
	
int scarebo_part_amount(string part,string richard )
{
	if(part=="")
	{
		return 100000;
	}
	richard = replace_string(richard, "<b>", "");
	richard = replace_string(richard, "</b>", "");
	string [int, int] t;
	t = group_string(richard, "has (\\d+) "+part);
	int amt = to_int(t[0][1]);
	return amt;
}
	
boolean sewer_explore()
{
	if(!done_in_sewers())
	{
		if(my_adventures()<10)
		{
			abort("OUT OF ADVENTURES IN SEWER!");
		}	
		//set cage choiceadv to abort
		if(cage_sit)
			set_property("choiceAdventure211", "0");
		else
			set_property("choiceAdventure211", "1");
		set_property("choiceAdventure212", "0");
		//set all tunnel/wheel/grate choiceadvs as appropriate
		if(grates_done)
		{
			set_property("choiceAdventure198", "1");
		}
		else
		{
			set_property("choiceAdventure198", "3");
		}
		if(wheels_done)
		{
			set_property("choiceAdventure197", "1");
		}
		else
		{
			set_property("choiceAdventure197", "3");
		}
		set_property("choiceAdventure199", "1");
		//switch to hobopolis ccs
//		set_property("customCombatScript","hobopolis");
		//check have item check requirements
		if(item_amount($item[unfortunate dumplings])<1)
		{
			buy(1,$item[unfortunate dumplings]);
		}
		if(item_amount($item[sewer wad])<1)
		{
			buy(1,$item[sewer wad]);
		}
		if(item_amount($item[bottle of ooze-o])<1)
		{
			buy(1,$item[bottle of ooze-o]);
		}
		if(item_amount($item[oil of oiliness])<3)
		{
			buy(3,$item[oil of oiliness]);
		}
		if(available_amount($item[gatorskin umbrella])<1)
		{
			buy(1,$item[gatorskin umbrella]);
		}
		//check noncombat buffs
		ensure_nocom_buffs();
		//redo equipment
		string maxstr="maximize initiative, 0.01 muscle, equip gatorskin umbrella, equip ring of conflict";
		if(available_amount($item[hobo code binder])!=0)
			maxstr=maxstr+", equip hobo binder";
		if(available_amount($item[space trip safety headphones])!=0)
			maxstr=maxstr+", equip space trip safety headphones";
		cli_execute(maxstr);
		
		//do one adventure
		adventure(1,$location[a maze of sewer tunnels]);
		return true;
	}
	return false;
}

boolean farm_scarebo_parts()
{
	if(!check_page("clan_hobopolis.php?place=2","townsquare25") && !check_page("clan_hobopolis.php?place=2","townsquare26.gif"))
	{
		//get richards text
		string richard = visit_url("clan_hobopolis.php?place=3&action=talkrichard&whichtalk=3");
		if(!contains_text(richard, "bring me enough hobo bits"))
		{
			abort("You don't appear to have Town Square access.");
		}
		//set market and tent choiceadvs to avoid
		set_property("choiceAdventure225", "3");
		set_property("choiceAdventure272", "2");
		//set combat action to spankage
		set_property("customCombatScript","hobopolis");
		//work out which phial, effect and part is for this char
//		effect my_eff;
//		item my_phial=$item[none];
		string my_tuner="";
		string part="";
		if(my_name()==name1)
		{
//			my_eff=$effect[hotform];
//			my_phial=$item[phial of hotness];
			my_tuner="Spirit of Cayenne";
			part="pairs? of charred";
		}
		if(my_name()==name2 && scarebo_part_amount(part,richard)>=218)
		{
//			my_eff=$effect[coldform];
//			my_phial=$item[phial of coldness];
			my_tuner="Spirit of Peppermint";
			part="pairs? of frozen";
		}
		if(my_name()==name3 && scarebo_part_amount(part,richard)>=218)
		{
//			my_eff=$effect[sleazeform];
//			my_phial=$item[phial of sleaziness];
			my_tuner="Spirit of Bacon Grease";
			part="hobo crotch";
		}
		if(my_name()==name4 && scarebo_part_amount(part,richard)>=218)
		{
//			my_eff=$effect[spookyform];
//			my_phial=$item[phial of spookiness];
			my_tuner="Spirit of Wormwood";
			part="creepy";
		}
		if(my_name()==name5 && scarebo_part_amount(part,richard)>=218)
		{
//			my_eff=$effect[stenchform];
//			my_phial=$item[phial of stench];
			my_tuner="Spirit of Garlic";
			part="piles? of stinking";
		}
		if(my_name()==name6 && scarebo_part_amount(part,richard)>=218)
		{
//			my_eff=$effect[Butt-Rock Hair]; //dummy effect
//			my_phial=$item[hair spray]; //dummy item
			use_skill($skill[spirit of nothing]);
			my_tuner="patience of the tortoise";
			part="hobo skin";
		}
		//farm the parts!
		if(scarebo_part_amount(part,richard)<218 && my_tuner!="")
		{
			if(my_adventures()==0)
			{
				abort("OUT OF ADVENTURES IN TOWN SQUARE!");
			}
/*			//ensure phial effect
			if(have_effect(my_eff)<1)
			{
				use(1,my_phial);
			}
*/
			if(have_effect(to_effect(my_tuner))<1)
			{
				use_skill(1,to_skill(my_tuner));
			}
			//redo equipment for pure damage, ensure muscle weapon is used whatever the class is
//			take_muscle_gear();
			cli_execute("maximize spell damage percent, 0.01 spell damage, +melee");
//			ensure_muscle_buffs();
			//enforce stat level to make parts. 760 muscle should be roughly min
			if(my_buffedstat($stat[muscle])< 760)
			{
				if(have_effect($effect[incredibly hulking])==0)
					use(1,$item[Ferrigno's Elixir of Power]);
				if(have_effect($effect[phorceful])==0)
					use(1,$item[philter of phorce]);
				if(have_effect($effect[Go Get 'Em, Tiger!])==0)
					use(1,to_item(2595));
			}
			if(my_buffedstat($stat[muscle])< 760)
			{
				abort("Not enough muscle for hobo parts!");
			}
			//adventure once
			int prev_tot=scarebo_part_amount(part,richard);
			adventure(1,$location[hobopolis town square]);
			richard=visit_url("clan_hobopolis.php?place=3&action=talkrichard&whichtalk=3");
			//check we got a part
			int new_tot=scarebo_part_amount(part,richard);
			if(prev_tot>=new_tot)
			{
				abort("Number of scarebo parts went from "+prev_tot+" to "+new_tot+":(");
			}
			return true;
		}
	}
	return false;
}

boolean sidezone_stench()
{
	set_property("choiceAdventure203", "2");
	//setup noncombats
	set_property("choiceAdventure216", "2");
	set_property("choiceAdventure214", "1");
	set_property("choiceAdventure218", "0"); //wait till all exploring
	if(!check_page("clan_hobopolis.php?place=6","theheap10.gif") && !check_page("clan_hobopolis.php?place=6","theheap11.gif"))
	{
		//check noncombat buffs
		cli_execute("uneffect stenchform");
		ensure_nocom_buffs();
//		ensure_muscle_buffs();
//		take_muscle_gear();
		//redo equipment
		
		string maxstr;
		if(my_primestat()==$stat[moxie])
		{
			maxstr="maximize moxie, -melee, equip ring of conflict";
		}
		else
		{
			maxstr="maximize muscle, +melee, equip ring of conflict";
		}
		if(available_amount($item[space trip safety headphones])!=0)
			maxstr=maxstr+", equip space trip safety headphones";
		cli_execute(maxstr);
		
		//do one adventure
		adventure(1,$location[the heap]);
		return true;
	}
	else if(!do_cold && !do_hot && !do_sleaze && !do_spooky)
	{
		abort("stench seems to be done, which is last zone currently specified");
	}
	return false;
}


boolean sidezone_cold()
{
	set_property("choiceAdventure202", "2");
	//set choiceadv to open fridge, choose correct yodel and choose correct pipe
	set_property("choiceAdventure273", "2");
	if(!check_page("clan_hobopolis.php?place=5","exposureesplanade10.gif") && !check_page("clan_hobopolis.php?place=5","exposureesplanade11.gif"))
	{
		if(enough_icicles)
		{
			set_property("choiceAdventure217", "0"); //when we are ready to yodel heart out, open browser so i can uncomment return lines above
			set_property("choiceAdventure215", "2");
		}
		else
		{
			ensure_nocom_buffs();
			set_property("choiceAdventure217", "1");
			set_property("choiceAdventure215", "3");
		}
		//check noncombat buffs
//		ensure_muscle_buffs();
		//redo equipment
//		take_muscle_gear();
		string maxstr;
		if(my_primestat()==$stat[moxie])
		{
			maxstr="maximize moxie, -melee, equip ring of conflict";
		}
		else
		{
			maxstr="maximize muscle, +melee, equip ring of conflict";
		}
		if(available_amount($item[space trip safety headphones])!=0)
			maxstr=maxstr+", equip space trip safety headphones";
		cli_execute(maxstr);
		//do one adventure
		adventure(1,$location[exposure esplanade]);
		return true;
	}
	else if(!do_hot && !do_sleaze && !do_spooky)
	{
		abort("cold seems to be done, which is last zone currently specified");
	}
	return false;
}

boolean sidezone_hot()
{
	set_property("choiceAdventure201", "2");
	
	//setup noncombats
	set_property("choiceAdventure207", "2");
	set_property("choiceAdventure213", "2");
	if(do_tireavalanche)
	{
		set_property("choiceAdventure206", "1");
	}
	else
	{
		set_property("choiceAdventure206", "2");
	}
	if(!check_page("clan_hobopolis.php?place=4","burnbarrelblvd10.gif") && !check_page("clan_hobopolis.php?place=4","burnbarrelblvd11.gif"))
	{
		//check noncombat buffs
		ensure_nocom_buffs();
//		ensure_muscle_buffs();
		//redo equipment
//		take_muscle_gear();
		string maxstr;
		if(my_primestat()==$stat[moxie])
		{
			maxstr="maximize moxie, -melee, equip ring of conflict";
		}
		else
		{
			maxstr="maximize muscle, +melee, equip ring of conflict";
		}
		if(available_amount($item[space trip safety headphones])!=0)
			maxstr=maxstr+", equip space trip safety headphones";
		cli_execute(maxstr);
		//do one adventure
		adventure(1,$location[burnbarrel blvd.]);
		return true;
	}
	else if(!do_sleaze && !do_spooky)
	{
		abort("hot seems to be done, which is last zone currently specified");
	}
	return false;
}

boolean sidezone_sleaze()
{
	set_property("choiceAdventure205", "2");
	
	//setup noncombats
	set_property("choiceAdventure219", "1");
	set_property("choiceAdventure224", "2");
	if(enter_club)
	{
		set_property("choiceAdventure223", "1");
	}
	else
	{
		set_property("choiceAdventure223", "3");
	}
	if(!check_page("clan_hobopolis.php?place=8","purplelightdistrict10.gif") && !check_page("clan_hobopolis.php?place=8","purplelightdistrict11.gif"))
	{
		//check combat buffs
		ensure_com_buffs();
//		ensure_muscle_buffs();
//		take_muscle_gear();
		//redo equipment
		string maxstr;
		if(my_primestat()==$stat[moxie])
		{
			maxstr="maximize moxie, -melee, equip monster bait";
		}
		else
		{
			maxstr="maximize muscle, +melee, equip monster bait";
		}
		if(available_amount($item[dungeon fist gauntlet])!=0)
			maxstr=maxstr+", equip dungeon fist gauntlet";
		cli_execute(maxstr);
		//do one adventure
		adventure(1,$location[the purple light district]);
		return true;
	}
	else if(!do_spooky)
	{
		abort("sleaze seems to be done, which is last zone currently specified");
	}
	return false;
}

boolean sidezone_spooky()
{
	if(my_name()!=dancer1 && my_name()!=dancer2)
	{
		return false;
	}
	set_property("choiceAdventure204", "2");
	set_property("choiceAdventure220", "2");
	set_property("choiceAdventure208", "2");
	set_property("choiceAdventure221", "1");
	set_property("choiceAdventure222", "1");
	if(!check_page("clan_hobopolis.php?place=7","burialground10.gif") && !check_page("clan_hobopolis.php?place=7","burialground11.gif"))
	{
//		ensure_muscle_buffs();
//		take_muscle_gear();
		//redo equipment
		string maxstr;
		if(my_primestat()==$stat[moxie])
		{
			maxstr="maximize moxie, -melee, equip ring of conflict";
		}
		else
		{
			maxstr="maximize muscle, +melee, equip ring of conflict";
		}
		if(available_amount($item[space trip safety headphones])!=0)
			maxstr=maxstr+", equip space trip safety headphones";
		print(maxstr);
		cli_execute(maxstr);
		//check noncombat buffs
		ensure_nocom_buffs();
		//do one adventure
		adventure(1,$location[the ancient hobo burial ground]);
		return true;
	}
	else
	{
		abort("spooky seems to be done, which is last zone there is");
	}
	return false;
}

void main() //all participants need 200 banked turns
{
	set_property("choiceAdventure200", "2");
	//disable semi rares
	set_property("choiceAdventure291", "2");
	set_property("choiceAdventure292", "2");
	set_property("choiceAdventure295", "2");
	set_property("choiceAdventure293", "2");
	set_property("choiceAdventure294", "1");
	cli_execute("set hpAutoRecovery = 0.7");
	cli_execute("set hpAutoRecoveryTarget = 0.95");
	//get money
	if(my_meat()<50000 && can_interact())
	{
		print("stash pulling meat","blue");
		if(stash_amount($item[dense meat stack])>=50)
		{
			take_stash(50,$item[dense meat stack]);
			cli_execute("autosell * dense meat stack");
		}
		else
		{
			abort("No stacks in stash.");
		}
	}
	//eat/drink/spleen with high budgets
/*
	if(my_inebriety()<(inebriety_limit()) || my_fullness()<(fullness_limit()) || my_spleen_use()<(spleen_limit()))
	{
		meatmail("testudinata",1);
		meatmail("Noblesse Oblige",15);
		wait(30);
		cli_execute("refresh effects");
		eatdrink(0,0,spleen_limit(),false,3000,2,1,300000,false);
		eatdrink(fullness_limit(),0,spleen_limit(),false,3000,2,1,300000,false);
		drink_with_tps(40000,false);
	}
	*/
	boolean occured=false;
	//sewers
	occured=sewer_explore(); //150 total
	if(occured)
		return;
		
	//town square
	if(do_scarebo)
		occured=farm_scarebo_parts(); //1300 total
	if(occured)
		return;
		
	//sidezones
		
	if(do_stench)
		occured=sidezone_stench(); //300
	if(occured)
		return;
		
	if(do_cold)
		occured=sidezone_cold(); //290
	if(occured)
		return;
		
	if(do_hot)
		occured=sidezone_hot(); //around 290 turns
	if(occured)
		return;
		
	if(do_sleaze)
		occured=sidezone_sleaze(); //200 with failures
	if(occured)
		return;
		
	if(do_spooky)
		occured=sidezone_spooky(); //
	if(occured)
		return;
	abort("Didn't do anything this iteration");
		
	wait(2);
}

//then it's just necessary to kill all the bosses