import <Quests.ash>;
import <Checklist.ash>;
import <Fengshui.ash>;
import <miscquests.ash>;
import <nemesis.ash>;

boolean have_instrument()
{
	if(my_name()=="zeldd")
	{
		if(available_amount($item[marinara jug])!=0)
		{
			return true;
		}
	} 
	else if(my_name()=="nimos")
	{
		if(available_amount($item[washboard shield])!=0)
		{
			return true;
		}
	}
	else if(my_name()=="nomis")
	{
		if(available_amount($item[makeshift castanets])!=0)
		{
			return true;
		}
	}
	else if(my_name()=="logayn")
	{
		if(available_amount($item[spaghetti-box banjo])!=0)
		{
			return true;
		}
	}
	else if(my_name()=="sauceress")
	{
		if(available_amount($item[sealskin drum])!=0)
		{
			return true;
		}
	}
	else if(my_name()=="polkette")
	{
		if(available_amount($item[left-handed melodica])!=0)
		{
			return true;
		}
	}
	else
	{
		//char is not supposed to have instrument
		return true;
	}
	return false;
}

boolean can_get_instrument()
{
	if(my_name()=="zeldd")
	{
		if(my_class()==$class[sauceror])
		{
			return true;
		}
	} 
	else if(my_name()=="nimos")
	{
		if(my_class()==$class[turtle tamer])
		{
			return true;
		}
	}
	else if(my_name()=="nomis")
	{
		if(my_class()==$class[disco bandit])
		{
			return true;
		}
	}
	else if(my_name()=="logayn")
	{
		if(my_class()==$class[pastamancer])
		{
			return true;
		}
	}
	else if(my_name()=="sauceress")
	{
		if(my_class()==$class[seal clubber])
		{
			return true;
		}
	}
	else if(my_name()=="polkette")
	{
		if(my_class()==$class[accordion thief])
		{
			return true;
		}
	}
	return false;
}


void main()
{
	dress_for_fighting();
	if(my_mp()<20 || !have_buff_equip())
	{
		cli_execute("mood apathetic");
	}
	else
	{
		cli_execute("mood default");
	}
	if(item_amount($item[Cobb's Knob map])>0 && available_amount($item[Knob Goblin encryption key]) != 0)
	{
		use(1,$item[Cobb's Knob map]);
	}
	if(my_level()<2)
	{
		Noobquest();
		literacyquest();
		ArtistQuest();
		hammerquest();
		bakerquest();
		woundedquest();
	}
	if(my_level()>1)
	{
		print("MosquitoQuest","blue");
		MosquitoQuest();
		print("dolphin check","blue");
		dolphin_check();
		print("slug_check","blue");
		slug_check();
		print("drhoboquest","blue");
		drhoboquest();
	}
	get_buff_equip();
	if(my_mp()<20 || !have_buff_equip())
	{
		cli_execute("mood apathetic");
	}
	else
	{
		cli_execute("mood default");
	}
	if(my_level()>3)
	{
		dress_for_fighting();
		cli_execute("guild");
		cli_execute("train.ash");
	}
	if(my_level()>4)
	{
		TavernQuest();
		MeatCarQuest();
	}
	if(my_level()>6)
	{
		BatQuest();
	}
	if(my_level()>3 && !(get_property("dailyDungeonDone") == "true") && my_adventures()>0)
	{
		print("checking need a key","blue");
		int key1=item_amount($item[Boris's key]);
		int key2=item_amount($item[Jarlsberg's key]);
		int key3=item_amount($item[Sneaky Pete's key]);
		int totalkeys = key1+key2+key3;
		if(totalkeys<3)
		{
			print("need a key","blue");
			cli_execute("dailydungeon.ash");
		}
	}
	if(my_level()>7)
	{
		DinghyQuest();
		UntinkerQuest();
		GoblinQuest();
	}
	if(my_level()>7)
	{
		haikuchallengequest();
		FriarsQuest();
		SteelQuest();
		DocQuest();
	}
	if(my_level()>7)
	{
		cli_execute("mayorquest.ash");
		cli_execute("citadel.ash");
		WizardQuest();
	}
	if(my_level()>8)
	{
		while(available_amount($item[hobo code binder])!=0 && !contains_text(visit_url("questlog.php?which=5"),"The Enormous Greater-Than Sign")&& my_adventures()>0 && !contains_text(visit_url("questlog.php?which=3"),"You have discovered the secret of the Dungeons of Doom"))
		{
			print("Farming for greater than sign","blue");
			set_property("choiceAdventure451", "1");
			cli_execute("maximize moxie, equip hobo code binder");
			boolean catch = adventure(1,$location[greater-than sign]);
		}
		print("about to check unlockdod","blue");
		UnlockDoD();
		while(available_amount($item[hobo code binder])!=0 && !contains_text(visit_url("questlog.php?which=5"),"The Misspelled Cemetary")&& my_adventures()>0 && !contains_text(visit_url("questlog.php?which=2"),"Cyrptic Emanations") )
		{
			print("Farming for pre-cyrpt glyph","blue");
			cli_execute("maximize moxie, equip hobo code binder");
			boolean catch = adventure(1,$location[Pre-Cyrpt Cemetary]);
		}
		CyrptQuest();
	}
	if(my_level()>8)
	{
		cli_execute("bedset.ash");
	}
	if(my_level()>8)
	{
		cli_execute("leaflet.ash");
		TrapperQuest();
	}
	if(my_level()>8)
	{
		fengshui();
		nemesisquest();
	}	
	if(my_level()>9)
	{
		LOLQuest();
	}
	if(my_level()>12)
	{
		TrashQuest();
		CastleMapQuest();
		cli_execute("dwarven_factory.ash");
		cli_execute("nemesis");
		print("about to call macguffinquest","blue");
		MacGuffinQuest();
		nemesisquest2();
		cli_execute("getsummon.ash");
		print("about to call unlockgallery","blue");
		UnlockGallery();
		cli_execute("Pagoda.ash");
		print("about to call spookyraven upstairs","blue");
		cli_execute("Spookyraven upstairs.ash");
		print("about to call spookyravenspell","blue");
		cli_execute("Spookyravenspell.ash");
	}
	if(my_level()>13)
	{
		cli_execute("zlib ocw_warplan = simoptimal");
		cli_execute("zlib ocw_nunspeed = false");
		cli_execute("zlib ocw_change_to_meat = true");
		cli_execute("zlib defaultoutfit = combat");
		cli_execute("zlib ocw_o_junkyard = combat");
		cli_execute("zlib ocw_o_lighthouse = combat");
		if(have_familiar($familiar[Squamous Gibberer]))
		{
			cli_execute("zlib ocw_f_lighthouse = Squamous Gibberer");
			cli_execute("zlib ocw_f_default = Squamous Gibberer");
		}
		else
		{
			cli_execute("zlib ocw_f_lighthouse = Mosquito");
			cli_execute("zlib ocw_f_default = Mosquito");
		}
		cli_execute("Wossname.ash");
	}
	if(my_level()>14)
	{
		cli_execute("npzr.ash");
		NaughtyQuest();
		//universally available glyphs
		if(item_amount($item[hobo code binder])!=0)
		{
			while(!contains_text(visit_url("questlog.php?which=5"),"Noob Cave")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Noob cave]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"The Arid, Extra-Dry Desert")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Desert (unhydrated)]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"Cobb's Knob Menagerie")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Menagerie 3]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"The eXtreme Slope")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[eXtreme Slope]);
			}
			while(!contains_text(visit_url("questlog.php?which=5")," House")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Fun House]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"Lair of the Ninja Snowmen")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Ninja Snowmen]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"The Limerick Dungeon")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Limerick Dungeon]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"The Penultimate Fantasy Airship")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Fantasy Airship]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"The Poker Room")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Poker Room]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"The Sleazy Back Alley")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Sleazy Back Alley]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"Belowdecks")&& my_adventures()>0)
			{
				cli_execute("maximize moxie, equip hobo code binder, equip pirate fledges");
				adventure(1,$location[Belowdecks]);
			}
		}
		//sign glyphs
		if(item_amount($item[hobo code binder])!=0)
		{
			
			while(!contains_text(visit_url("questlog.php?which=5"),"Thugnderdome")&& my_adventures()>0 && in_moxie_sign())
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Thugnderdome]);
			}
			while(!contains_text(visit_url("questlog.php?which=5"),"Camp Logging Camp")&& my_adventures()>0 && in_mysticality_sign())
			{
				cli_execute("maximize moxie, equip hobo code binder");
				adventure(1,$location[Camp Logging Camp]);
			}
		}
		set_property("choiceAdventure225","3");//tent
		if(my_class() ==$class[turtle tamer] && my_adventures()>0)
		{
			//get syncopated turtle
			while(my_adventures()>0 && item_amount($item[syncopated turtle])==0 && !have_familiar($familiar[syncopated turtle]))
			{
				print("getting turtle pet","blue");
				if(available_amount($item[Flail of the Seven Aspects])!=0 && equipped_amount($item[Flail of the Seven Aspects])==0)
				{
					equip($item[Flail of the Seven Aspects]);
				}
				else if(available_amount($item[Flail of the Seven Aspects])==0)
				{
					equip($item[turtling rod]);
				}
				if(have_effect($effect[Eau de Tortue])==0)
				{
					use(1,$item[turtle pheromones]);
				}
				adventure(1,$location[hippy camp]);
			}
			if(item_amount($item[syncopated turtle])!=0 && !have_familiar($familiar[syncopated turtle]))
			{
				print("using turtle pet","blue");
				use(1,$item[syncopated turtle]);
			}
			int nickles_needed=0;
			if(!have_instrument())
			{
				nickles_needed=nickles_needed+99;
			}
			if(available_amount($item[hobo code binder])==0)
			{
				nickles_needed=nickles_needed+30;
			}
			nickles_needed=nickles_needed- item_amount($item[hobo nickel]);
			cli_execute("conditions clear");
			boolean done;
			if(nickles_needed>0)
			{
				done=false;
				add_item_condition(nickles_needed,$item[hobo nickel]);
			}
			else
			{
				done=true;
			}
			//need to be sure sewer is cleared
			set_property("choiceAdventure211","1");//binder
			set_property("requireSewerTestItems","false");
			while(!done && !contains_text(visit_url("clan_hobopolis.php"),"deeper.gif") && my_adventures()>9)
			{
				print("opening sewers and getting nickels","blue");
				if(available_amount($item[Flail of the Seven Aspects])!=0 && equipped_amount($item[Flail of the Seven Aspects])==0)
				{
					equip($item[Flail of the Seven Aspects]);
				}
				else if(available_amount($item[Flail of the Seven Aspects])==0)
				{
					equip($item[turtling rod]);
				}
				cli_execute("familiar syncopated turtle");
				if(have_effect($effect[Eau de Tortue])==0)
				{
					use(1,$item[Turtle pheromones]);
				}
				done=adventure(1,$location[A Maze of Sewer Tunnels]);
			}
			if(contains_text(visit_url("clan_hobopolis.php"),"deeper.gif"))
			{
				//now farm!
				while(!done && my_adventures()>0)
				{
					print("farming nickels in town square","blue");
					if(available_amount($item[Flail of the Seven Aspects])!=0 && equipped_amount($item[Flail of the Seven Aspects])==0)
					{
						equip($item[Flail of the Seven Aspects]);
					}
					else if(available_amount($item[Flail of the Seven Aspects])==0)
					{
						equip($item[turtling rod]);
					}
					cli_execute("familiar syncopated turtle");
					if(have_effect($effect[Eau de Tortue])==0)
					{
						use(1,$item[Turtle pheromones]);
					}
					done=adventure(1,$location[Hobopolis town square]);
					cli_execute("use * boxcar turtle");
				}
				while(item_amount($item[hobo nickel])>29&& item_amount($item[hobo code binder])==0 && my_adventures()>0)
				{
					print("buying binder","blue");
					set_property("choiceAdventure230","1");//binder
					set_property("choiceAdventure272","2");//market
					adventure(1,$location[Hobopolis town square]);
				}
				while(item_amount($item[hobo nickel])>98 && !have_instrument() && can_get_instrument() && my_adventures()>0)
				{
					print("buying instrument","blue");
					set_property("choiceAdventure230","2");//binder
					set_property("choiceAdventure272","1");//market
					equip($item[hobo code binder]);
					adventure(1,$location[Hobopolis town square]);
				}
			}
		}
		//People who are done added here
		if(my_name()!="twistedmage" && my_name()!="bankymcbank" && my_name()!="logayn" && my_name()!="moxy_proxy"  && my_adventures()>0 && contains_text(visit_url("questlog.php?which=1"),"defeated the Naughty Sorceress and freed the King") &&	contains_text(visit_url("lair6.php"),"gash.gif"))
		{
			set_property("ready_for_ascension",true);
			abort("Ready for ascension!");
		}
	}
	if(my_level()>23 && my_level()<29)
	{
//			cli_execute("seamonkey.ash");
	}
	if( my_name() == "twistedmage")
	{
//primordial fear
		HyboriaQuest();
		FutureQuest();
	}
}


//----------QUESTS NOT COMPLETED
/*
El Vibrato Island Quest
primordial fear
*/
