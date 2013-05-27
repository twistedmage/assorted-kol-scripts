//run old ver buff script first

import <eatdrink.ash>;
import <zlib.ash>;
import <EatSushi.ash>;
import <improve.ash>;
import <train.ash>;
import <questlib.ash>;
import <Universal_recovery.ash>
import <nscomb.ash>;
import <canadv.ash>;
import <sims_lib.ash>;
import <miner.ash>;

void crimbo_fam(string farmtype)
{
	//change to correct fam
	if(farmtype=="lollipops")
	{
		use_familiar($familiar[Peppermint Rhino]);
		equip($item[sugar shield]);
	}
	//use angel to romance wasps
	else if(farmtype=="fudge" && have_familiar($familiar[obtuse angel]) && to_int(get_property("_badlyRomanticArrows"))==0)
	{
		use_familiar($familiar[obtuse angel]);
		equip($item[quake of arrows]);
	}
	else if(have_familiar($familiar[squamous gibberer]))
	{
		use_familiar($familiar[squamous gibberer]);
	}
	
	//make sure we've used our moveable feast
	if(available_amount($item[moveable feast])>0)
		use(1,$item[moveable feast]);
}

void crimbo11_buffs(string farmtype)
{
	if(farmtype=="lollipops")
	{
		//set choiceadv to visit garage
		set_property("choiceAdventure557","3");
		//set garage to make...
		if(available_amount($item[sucker bucket])<1)
			set_property("choiceAdventure558","1"); //bucket
		else if(available_amount($item[sucker kabuto])<1)
			set_property("choiceAdventure558","2"); //hat
		else if(available_amount($item[sucker hakama])<1)
			set_property("choiceAdventure558","3"); //pants
		else if(available_amount($item[sucker tachi])<1)
			set_property("choiceAdventure558","4"); //sword
		else
			set_property("choiceAdventure558","5"); //scaffold
		if(available_amount($item[sugar shield])<1)
			create(1,$item[sugar shield]);
		equip($item[sugar shield]);
		//licorice root
		if(have_effect(to_effect(957))<1)
			use(1,$item[licorice root]);
		//pet buffing spray
		if(have_effect($effect[heavy petting])<1)
			use(1,$item[knob goblin pet-buffing spray]);
	}
	else if(farmtype=="fudge")
	{
		//twistedmage should pull all hot fudge
		if(my_name()=="twistedmage")
			take_stash(stash_amount($item[Superheated fudge]),$item[Superheated fudge]);
			
		//make or dump any hot fudge
		if(available_amount($item[Superheated fudge])>0)
		{
			if(have_skill($skill[the way of sauce]))
			{
				create(available_amount($item[Superheated fudge]),$item[fluid of fudge-finding]);
			}
			else
			{
				put_stash(available_amount($item[Superheated fudge]),$item[Superheated fudge]);
			}
		}
		
		//pull and use a load of fudge potions
		if(have_effect($effect[fudgehound])<1)
		{
			refresh_stash();
			take_stash(stash_amount($item[fluid of fudge-finding]),$item[fluid of fudge-finding]);
			while(have_effect($effect[fudgehound])< my_adventures() && available_amount($item[fluid of fudge finding])>0)
			{
				use(1,$item[fluid of fudge-finding]);
			}
			
		}
		
		//dump remaining fudge potions
		put_stash(available_amount($item[fluid of fudge-finding]),$item[fluid of fudge-finding]);
			
		//set choice to get hot fudge, if we don't have the buff, or we are done with wasps
		if(have_effect($effect[fudgehound])<1 || to_int(get_property("_fudgeWaspFights"))>2)
		{
			set_property("choiceAdventure559","4");
			
		}
		else //set choiceadv to fight wasps
		{
			set_property("choiceAdventure559","2");
		}
		if(have_effect($effect[fresh scent])<1)
			use(1,$item[rock salt]);
		print("buffing with fudge lily");
		if(have_effect(to_effect(962))<1)
			use(1,to_item(5436));
	}
	
	//change familiar
	crimbo_fam(farmtype);
	
	//put away finished putty sheet
	if( to_int(get_property("spookyPuttyCopiesMade"))>4 && item_amount($item[spooky putty sheet])>0)
	{
		put_closet(1,$item[spooky putty sheet]);
	}
}

void crimbo11(string farmtype)
{
	if(farmtype!="fudge" && farmtype!="gummi" && farmtype!="lollipops")
		abort("crimbo11() : unrecognised farm type \""+farmtype+"\"");
	//eat fudsicles if we wany fudge
	if(farmtype=="fudge")
	{
		if(my_fullness()<10)
		{
			use(1,$item[milk of magnesium]);
			if(to_item(5440)==to_item("nothing"))
				abort("don't know what a fudgesicle is");
			eat(10,to_item(5440));
		}	
	}
	//now eat and drink normally
	if(my_inebriety()<(inebriety_limit()) || my_fullness()<(fullness_limit()) || my_spleen_use()<(spleen_limit()))
	{
		//spleen first in case it uses cleaning items
		eatdrink(0,0,spleen_limit(),false,1000,2,1,my_meat(),false);
		//now eat
		eatdrink(fullness_limit(),0,spleen_limit(),false,1000,2,1,my_meat(),false);
		//finally pull etc and drink	
		drink_with_tps(200000,false);
	}
	//take putty sheet out of closet
	if(closet_amount($item[spooky putty sheet])>0)
		take_closet(1,$item[spooky putty sheet]);
	//once per day buffs
	if(available_amount($item[legendary beat])>0)
		use(1,$item[legendary beat]);
	cli_execute("friars familiar");
	cli_execute("pool stylish");
	cli_execute("pool stylish");
	cli_execute("pool stylish");
	//maximize items, peanut shield if available
	string maxstring;
	if(farmtype=="lollipops")
	{
		maxstring="items, -equip sugar shorts, -equip sugar shield";
		if(available_amount($item[peanut brittle shield])>0)
			maxstring+=", +equip peanut brittle shield";
		if(available_amount($item[Cane-mail shirt])>0)
			maxstring+=", +equip Cane-mail shirt";
		maxstring+=", +equip pearidot earrings, +equip fudgecycle";
		if(available_amount($item[Tourmalime tourniquet])>0)
			maxstring+=", +equip Tourmalime tourniquet";
	}
	if(farmtype=="fudge")
	{
		maxstring="mp regen min, mp regen max, 0.01 exp, equip ring of conflict, -equip sugar shorts, -equip sugar shield";
		if(available_amount($item[velcro broadsword])>0)
			maxstring+=", +equip velcro broadsword";
		if(available_amount($item[Tourmalime tourniquet])>0)
			maxstring+=", +equip Tourmalime tourniquet";
	}
	if(farmtype=="gummi")
	{
		maxstring="mp regen min, mp regen max, 0.01 exp,  -equip sugar shorts, -equip sugar shield";
		if(have_outfit("dwarvish war uniform"))
			maxstring+=", outfit dwarvish war uniform";
		else
		{
			maxstring+=", outfit Mining Gear";
			while(have_effect($effect[object detection])< my_adventures())
			{
				cli_execute("use 1 potion of detection");
			}
		}
	}
	print("maximize "+maxstring);
	cli_execute("maximize  "+maxstring);
	
	//run mining script for gummi
	if(farmtype=="gummi")
	{
		cli_execute("ashq import <miner.ash> greeningot = 30000000; mine_stuff();");
	}
	else
	{
		//loop the farming
		while(my_adventures()>0)
		{
			crimbo11_buffs(farmtype);
			//use putty
			if(available_amount($item[spooky putty monster])>0)
				use(1,$item[spooky putty monster]);
			else
			{
				if(farmtype=="lollipops")
					adventure(1,$location[lollipop forest]);
				else if(farmtype=="fudge")
					adventure(1,$location[Fudge Mountain]);
			}
		}
	}
}


void buffbots()
{
	if(!to_boolean(get_property("_buffed_"+my_name())))
	{			
		if(have_effect($effect[jalapeno saucesphere])<1000 && have_effect($effect[jabanero saucesphere])<1000 ) //jalapeno and jabanero saucesphere
		{
			meatmail("testudinata",3);
		}		
		if(have_effect($effect[ghostly shell])<1000 && have_effect($effect[astral shell])<1000 ) //ghostly and astral shell
		{
			meatmail("testudinata",4);
		}		
		if(have_effect($effect[tenacity of the snapper])<1000 && have_effect($effect[reptilian fortitude])<1000 ) //fort and tenacity
		{
			meatmail("testudinata",9);
		}
		if(have_effect($effect[polka of plenty])<1000 && my_name()=="twistedmage") //polka
		{
			meatmail("kolabuff",9);
			meatmail("iocainebot",7);
			meatmail("testudinata",6);
			meatmail("Noblesse Oblige",17);
		}
		if(have_effect($effect[fat leons phat loot lyric])<1000 && my_name()=="twistedmage") //phat loot
		{
			meatmail("kolabuff",18);
			meatmail("iocainebot",14);
			meatmail("testudinata",7);
			meatmail("Noblesse Oblige",8);
		}
//=======================================================================================================		
		if(have_effect($effect[elemental saucesphere])<1000) //elemental
		{
			meatmail("kolabuff",14);
			meatmail("iocainebot",11);
			meatmail("testudinata",5);
			meatmail("Noblesse Oblige",6);
		}
		if(have_effect($effect[Jalapeno Saucesphere])<1000) //jalapen
		{
			meatmail("kolabuff",6);
			meatmail("iocainebot",4);
			meatmail("Noblesse Oblige",12);
		}
		if(have_effect($effect[jabanero saucesphere])<1000) //jabenaro
		{
			meatmail("kolabuff",15);
			meatmail("iocainebot",12);
			meatmail("Noblesse Oblige",10);
		}
		if(have_effect($effect[scarysauce])<1000) //scarysauce
		{
			meatmail("kolabuff",16);
			meatmail("testudinata",47);
		}
		if(have_effect($effect[ghostly shell])<1000) //ghostly
		{
			meatmail("iocainebot",6);
			meatmail("kolabuff",8);
			meatmail("Noblesse Oblige",9);
		}
		if(have_effect($effect[reptilian fortitude])<1000) //reptilian
		{
			meatmail("iocainebot",13);
			meatmail("kolabuff",17);
			meatmail("Noblesse Oblige",20);
		}
		if(have_effect($effect[empathy])<1000) //empathy
		{
			meatmail("iocainebot",15);
			meatmail("kolabuff",20);
			meatmail("testudinata",8);
			meatmail("Noblesse Oblige",7);
		}
		if(have_effect($effect[tenacity of the snapper])<1000) //tenacity
		{
			meatmail("iocainebot",8);
			meatmail("kolabuff",10);
			meatmail("Noblesse Oblige",23);
		}
		if(have_effect($effect[astral shell])<1000) //astral
		{
			meatmail("iocainebot",10);
			meatmail("kolabuff",13);
			meatmail("Noblesse Oblige",2);
		}
		set_property("_buffed_"+my_name(),true);
	}
}


void feed_sock(item food)
{
	int amount=available_amount(food);
	if(amount!=0)
	{
		print("Feeding "+amount+" "+food+" to the sock","blue");
		visit_url("familiarbinger.php?action=binge&qty="+amount+"&whichitem="+to_int(food)+"&pwd");
	}
	else
	{
		print("No "+food+" to feed him","blue");
	}
}

void morning()
{
	if(my_mp()<20)
	{
		cli_execute("mood apathetic");
	}
	else
	{
		cli_execute("mood default");
	}
	if(my_name()=="lol")
	{
//------------------------TEMP FOR COLA FARM-----------------------------
		cli_execute("set loginScript = scripts\\colafarm.ash");
		cli_execute("colafarm.ash");
		cli_execute("exit");
//-----------------------------------------------------------------------
	}
	if(my_level()>18)
	{
//		abort("maybe do elf alley.");
	}
	else if(my_name()!="twistedmage")
	{
		cli_execute("set loginScript = scripts\\awake.ash");
	}
	if(!to_boolean(get_property("_params_set_"+my_name())))
	{
		cli_execute("set masterRelayOverride = bUMRATSv0.11.ash");
		cli_execute("set useCrimboToysHardcore = true");
		cli_execute("set alwaysGetBreakfast = true");
		cli_execute("set grabCloversHardcore = false");
		cli_execute("set grabCloversSoftcore = false");
		cli_execute("set grimoireSkillsHardcore = false");
		cli_execute("set grimoireSkillsSoftcore = all");
		cli_execute("set cacheMallSearches = true");
		cli_execute("set initialDesktop = AdventureFrame,CommandDisplayFrame");
		cli_execute("set initialFrames");	
		cli_execute("set autoPlantHardcore = false");
		cli_execute("set autoPlantSoftcore = true");
		cli_execute("set autoSatisfyWithCloset = true");
		cli_execute("set autoSatisfyWithMall = true");
		cli_execute("set autoSatisfyWithNPCs = true");
		cli_execute("set autoSatisfyWithStash = false");
		cli_execute("set preferredWebBrowser = C\:\\Users\\sims\\AppData\\Local\\Google\\Chrome\\Application\\chrome.exe");
		cli_execute("set removeMalignantEffects = false");
		cli_execute("zlib bbb_miniboss_items = 0");
		cli_execute("set recoveryScript = Universal_recovery");
		cli_execute("set postAscensionScript = newLife.ash");
		cli_execute("set betweenBattleScript = BestBetweenBattle.ash");
		cli_execute("set counterScript = CounterChecker.ash");
		cli_execute("set wormwood = !pipe");
		cli_execute("set battleAction = custom");
		set_property("customCombatScript","default");
		cli_execute("set manaBurningThreshold = 0.70");
		cli_execute("set hpAutoRecovery = 0.3");
		cli_execute("set hpAutoRecoveryTarget = 0.7");
		cli_execute("set mpAutoRecovery = 0.3");
		cli_execute("set mpAutoRecoveryTarget = 0.7");
		cli_execute("set autoSphereID = true");
		cli_execute("zlib bbb_turtles = 0");
		cli_execute("zlib auto_semirare = never");
		set_property("choiceAdventure502","3");
		set_property("choiceAdventure506","1");
		set_property("choiceAdventure26","2");
		set_property("choiceAdventure28","2");
		set_property("autoRepairBoxServants",false);
		cli_execute("zlib verbosity = 6");
		if(my_name()!="twistedmage")
		{
			cli_execute("zlib BaleCC_SrInHC = true");
			cli_execute("zlib BaleCC_useDanceCards = TRUE");
			cli_execute("zlib BaleCC_ImprovePoolSkills = FALSE");
			cli_execute("set breakfastHardcore = Advanced Cocktailcrafting,Advanced Saucecrafting,Pastamastery,Summon Crimbo Candy");
			cli_execute("set breakfastSoftcore = Advanced Cocktailcrafting,Advanced Saucecrafting,Pastamastery,Summon Crimbo Candy");
		}
		else
		{
			cli_execute("zlib BaleCC_SrInHC = false");
			cli_execute("zlib BaleCC_useDanceCards = FALSE");
			cli_execute("zlib BaleCC_ImprovePoolSkills = true");
			cli_execute("set breakfastHardcore = ");
			cli_execute("set breakfastSoftcore = Advanced Cocktailcrafting,Advanced Saucecrafting,Pastamastery,Summon Crimbo Candy,Lunch Break");
		}
		if(!can_interact())
		{
			cli_execute("set hpAutoRecoveryItems = free disco rest;galaktik's curative nostrum;medicinal herb's medicinal herbs;scroll of drastic healing;scented massage oil;cannelloni cocoon;visit the nuns;red pixel potion;really thick bandage;filthy poultice;gauze garter;bottle of vangoghbitussin;plump juicy grub;cotton candy bale;ancient magi-wipes;cotton candy pillow;green pixel potion;phonics down;disco power nap;cotton candy cone;palm-frond fan;honey-dipped locust;tongue of the walrus;red paisley oyster egg;red polka-dot oyster egg;red striped oyster egg;cotton candy plug;tiny house;cotton candy skoshe;disco nap;lasagna bandages;doc galaktik's homeopathic elixir;cast;cotton candy smidgen;tongue of the otter;sugar shard;doc galaktik's restorative balm;doc galaktik's ailment ointment;cotton candy pinch;forest tears;doc galaktik's pungent unguent");
		}
		else
		{
			cli_execute("set hpAutoRecoveryItems = free disco rest;galaktik's curative nostrum;scroll of drastic healing;scented massage oil;cannelloni cocoon;visit the nuns;red pixel potion;really thick bandage;filthy poultice;gauze garter;bottle of vangoghbitussin;plump juicy grub;cotton candy bale;ancient magi-wipes;cotton candy pillow;green pixel potion;phonics down;disco power nap;cotton candy cone;palm-frond fan;honey-dipped locust;tongue of the walrus;red paisley oyster egg;red polka-dot oyster egg;red striped oyster egg;cotton candy plug;tiny house;cotton candy skoshe;disco nap;lasagna bandages;doc galaktik's homeopathic elixir;cast;cotton candy smidgen;tongue of the otter;sugar shard;doc galaktik's restorative balm;doc galaktik's ailment ointment;cotton candy pinch;forest tears;doc galaktik's pungent unguent");
		}
		cli_execute("set mpAutoRecoveryItems = platinum yendorian express card;free disco rest;galaktik's fizzy invigorating tonic;visit the nuns;oscus's neverending soda;unstable quark + junk item;high-pressure seltzer bottle;natural fennel soda;bottle of vangoghbitussin;monstar energy beverage;carbonated soy milk;carbonated water lily;nardz energy beverage;blue pixel potion;cotton candy bale;bottle of monsieur bubble;ancient magi-wipes;unrefined mountain stream syrup;cotton candy pillow;phonics down;tonic water;cotton candy cone;palm-frond fan;honey-dipped locust;marquis de poivre soda;delicious shimmering moth;green pixel potion;blue paisley oyster egg;blue polka-dot oyster egg;blue striped oyster egg;cotton candy plug;knob goblin superseltzer;blatantly canadian;cotton candy skoshe;tiny house;cotton candy smidgen;dyspepsi-cola;cloaca-cola;cotton candy pinch;sugar shard;mountain stream soda;magical mystery juice;black cherry soda;knob goblin seltzer;cherry cloaca cola;soda water");
		if(can_interact() && stash_amount($item[dense meat stack])>800)
		{
			visit_url("raffle.php?action=buy&where=0&f=Buy+Tickets&quantity=10&pwd");
		}
		while(check_page("campground.php?action=advent","left to punch out right now"))
		{
			print("Getting advent stuff");
			visit_url("campground.php?preaction=openadvent");
		}
		/*
		if(contains_text(visit_url("woods.php"),"arboretum.gif"))
		{
			set_property("choiceAdventure438", "1");
			set_property("choiceAdventure209", "1");
			set_property("choiceAdventure210", "1");
			if(item_amount($item[bag of crotchety pine saplings])!=0)
			{
				cli_execute("unequip weapon");
				equip($item[bag of crotchety pine saplings]);
			}
			adventure(1,$location[Arrrboretum]);
			if(item_amount($item[bag of crotchety pine saplings])!=0)
			{
				cli_execute("unequip weapon");
				equip($item[bag of crotchety pine saplings]);
			}
			adventure(2,$location[Arrrboretum]);
		}
		*/
		set_property("_params_set_"+my_name(),true);
	}
	if(can_interact())
	{
		buffbots();
	}
	if(have_familiar($familiar[stocking mimic]) && my_name()!="twistedmage")
	{
/*	
		cli_execute("familiar stocking mimic");
		feed_sock($item[pickle-flavored chewing gum]);
		feed_sock($item[angry farmer candy]);
		feed_sock($item[alphabet gum]);
		feed_sock($item[breath mint]);
		feed_sock($item[Daffy Taffy]);
		feed_sock($item[lime-and-chile-flavored chewing gum]);
		feed_sock($item[jabanero-flavored chewing gum]);
		feed_sock($item[tamarind-flavored chewing gum]);
		feed_sock($item[Mr. Mediocrebar]);
		feed_sock($item[Tasty Fun Good rice candy]);
		feed_sock($item[Yummy Tummy bean]);
		feed_sock($item[crazy little Turkish delight]);
		feed_sock($item[Bit O' Ectoplasm]);
		feed_sock($item[white chocolate chips]);
*/		
	}
	//if we can interact and have less than 10% mana, we probably burned it on breakfast.
	if(can_interact() && (to_float(my_hp())/to_float( my_maxhp()))<0.1)
	{
		//lets take a hot shower to try and get it back, and maybe learn a recipe
		cli_execute("shower hot");
	}
	
//improve spirits, create wads, zap stuff
	banquet();
//join clan--------------------------------------	
	if(my_level()>2 && my_level()<5)
	{
		string clancheck = visit_url("clan_hall.php");
		if(contains_text(clancheck,"You are currently whitelisted by 1 clan"))
		{
			visit_url("showclan.php?recruiter=1&whichclan=80012&action=joinclan&apply=Apply+to+this+Clan&confirm=on&pwd");
			print("Joined clan","blue");
		}
	}
//end join clan--------------------------------------	
//start eating------------------------------------
	if(have_skill($skill[canticle of carboloading]) && can_interact() && !get_property("_carboloaded_today").to_boolean())
	{
		use_skill($skill[canticle of carboloading]);
		set_property("_carboloaded_today",true);
		set_property("carboLoading",0);
	}
	if(available_amount($item[creepy voodoo doll])>0)
	{
		cli_execute("use creepy voodoo doll");
	}
	//collect slime
	if(my_class()==$class[sauceror] && contains_text(visit_url("questlog.php?which=2"),"Me and My Nemesis"))
	{
		while(contains_text(visit_url("volcanoisland.php?pwd&action=npc"),"Get some slime (1)"))
		{
			visit_url("volcanoisland.php?pwd&action=npc&pwd&action=npc&subaction=getslime");
		}
	}
	cli_execute("refresh effects");
	if(have_effect($effect[ode to booze])==0 && can_interact())
	{
		meatmail("testudinata",1);
		meatmail("Noblesse Oblige",15);
	}
	cli_execute("diet.ash");
	int karmas=item_amount($item[instant karma]);
	while(karmas>0)
	{
		print("Discarding karma","green");
		visit_url("inventory.php?which=1&action=discard&pwd&whichitem=4448");
		karmas=karmas-1;
	}
//crimbo11("lollipops");
	//spend turns of unaccompanied miner
	free_mine();
	if( my_name() == "twistedmage")
	{
//---------------------------EAT AND DRINK
//eat and drink while you have ode to booze, leave enough for 1 sake and 1 sushi
		if(my_inebriety()<(inebriety_limit()) || my_fullness()<(fullness_limit()) || my_spleen_use()<(spleen_limit()))
		{
			//spleen first in case it uses cleaning items
			eatdrink(0,0,spleen_limit(),false,2000,2,1,my_meat(),false);
			//finally pull etc and drink	
			drink_with_tps(200000,false);
			//now eat
			eatdrink(fullness_limit(),0,spleen_limit(),false,2000,2,1,my_meat(),false);
		}
//Eat 1xsushi and drink sake
//		eat_sushi(true,0);
//----------------------------GET TEMPURA + 27 SAND DOLLARS
//		cli_execute( "outfit noncombat" );
//		cli_execute( "familiar Squamous Gibberer" );
//use moveable feast now
//		visit_url("inv_use.php?&pwd&which=2&whichitem=4135 ");
//equip fireworks
//		cli_execute("equip little box of fireworks ");
//		use_upto(1,NC_ITEM1,true);
//		use_upto(1,NC_ITEM2,true);
//tempura
//		cli_execute( "skate merry" );
//		cli_execute( "skate band" );
//		add_item_condition( 3 , $item[bubbling tempura batter] ); commented because we assume we will get 3 while using up bandshell buff
//		adventure(30, FARM_LOCATION2);
//---------------------------FINISH FISHY BUFF IN OCTOPUS GARDEN
//buffs
//		cli_execute( "skate eclectic eels" );
//		cli_execute( "concert Winklered" );
//		cli_execute( "friars blessing food" );
//		cli_execute( "familiar Dancing Frog" );
//use moveable feast now
//		visit_url("inv_use.php?&pwd&which=2&whichitem=4135 ");
//		cli_execute( "outfit octopus" );
//farm garden 30 times till buffs wear off
//		adventure(30, FARM_LOCATION3);
//----------------------------DO BOUNTY
//		cli_execute("maximize "+ my_primestat() +" exp" );
//		cli_execute("fold stinky cheese eye");
//		cli_execute("equip stinky cheese eye");
//		if(have_familiar($familiar[hound dog]))
//		{
//			cli_execute( "familiar hound dog" );
//		}
//		else
//		{
//			cli_execute("familiar hovering sombrero");
//		}
//equip fireworks
//		cli_execute("equip little box of fireworks ");
//		cli_execute( "bounty.ash hunt best" );
//		cli_execute( "bounty.ash *" );
//---------------------------end bounty, get buffs		
//---------------------------hobo
		cli_execute("familiar jumpsuited hound dog");
		cli_execute("maximize items, equip navel, equip mayfly bait, equip old soft shoes");
		cli_execute("equip businessman");
		abort("enable mayfly macro and fight 30 times (in sidezones), then equip mr. accessory jr, change macro, and comtinue");
//---------------------------hobo		

		cli_execute( "outfit water" );		
		cli_execute( "skate eclectic eels" );
		cli_execute( "concert Winklered" );
		cli_execute( "outfit items" );
		if(have_familiar($familiar[Squamous Gibberer]))
		{
			cli_execute( "familiar Squamous Gibberer" );
		}
//---------------------------end buffs
	}
	else
	{
//learn spells---------------------------------
		Trainspells();
//start eatdrink-------------------------------------------------
		if((my_inebriety()<(inebriety_limit()) || my_fullness()<(fullness_limit()) || my_spleen_use()<(spleen_limit()))) //if over level 5 eat
		{
			//spleen first in case it uses cleaning items
			eatdrink(0,0,spleen_limit(),false,500,2,1,1000,false);
			//now eat
			eatdrink(fullness_limit(),0,spleen_limit(),false,500,2,1,1000,false);
			//finally pull etc and drink
			drink_with_tps(20000,false);
		}	
//end eatdrink get clovers----------------------------------
/*
		if(can_interact())
		{
			cli_execute("hermit");
			string herm = visit_url("hermit.php");	
			int clovers=0;
			if(contains_text(herm,"5 left in stock for today"))
			{
				clovers=5;
			}
			if(contains_text(herm,"4 left in stock for today"))
			{
				clovers=4;
			}
			if(contains_text(herm,"3 left in stock for today"))
			{
				clovers=3;
			}
			if(contains_text(herm,"2 left in stock for today"))
			{
				clovers=2;
			}
			if(contains_text(herm,"1 left in stock for today"))
			{
				clovers=1;
			}
			if(clovers!=0)
			{
				cli_execute("hermit "+clovers+" clover");
			}		
		}
		*/
//----------------------end clovers do barrels
/*		cli_execute( "maximize exp, -equip tiny plastic sword" );
		if(have_familiar($familiar[Squamous Gibberer]))
		{
			cli_execute( "familiar Squamous Gibberer" );
		}
		cli_execute( "barrels.ash" );*/
//--------------------- do bounty
		//buy bounty gear
		if(!have_skill($skill[transcendent olfaction]) && item_amount($item[filthy lucre])>199)
		{
			visit_url("bhh.php");
			abort("have to buy olfaction book");
		}
		if(!in_bad_moon() && !have_familiar($familiar[jumpsuited hound dog]) && item_amount($item[filthy lucre])>99)
		{
			visit_url("bhh.php");
			abort("have to buy  hound dog");
		}
		if(can_interact() && available_amount($item[bounty hunting helmet])<1 && item_amount($item[filthy lucre])>14)
		{
			visit_url("bhh.php");
			abort("have to buy bounty hat");
		}
		if(can_interact() && available_amount($item[bounty hunting pants])<1 && item_amount($item[filthy lucre])>14)
		{
			visit_url("bhh.php");
			abort("have to buy bounty pants");
		}
		if(!have_skill($skill[transcendent olfaction]) || !have_familiar($familiar[jumpsuited hound dog]) || item_amount($item[bounty hunting helmet])<1 || item_amount($item[bounty hunting pants])<1)
		{
			cli_execute("maximize "+ my_primestat());
			cli_execute( "bounty.ash hunt best" );
			cli_execute( "bounty.ash *" );
		   if(available_amount($item[spooky putty monster])!=0)
			{	
				cli_execute("recover both");
				use(1,$item[spooky putty monster]);
			}
		}
//get buffs------------------------------------
		if(can_adv($location[skate park],false) && contains_text(visit_url("sea_skatepark.php"),"Comet_skate.gif"))
		{
			cli_execute( "skate Finstrong" );
		}
		else if(can_adv($location[skate park],false) && contains_text(visit_url("sea_skatepark.php"),"Lutz.gif"))
		{
			cli_execute( "skate Fishy" );
		}
		else if(can_adv($location[skate park],false) && contains_text(visit_url("sea_skatepark.php"),"Chess2.gif"))
		{
			cli_execute( "skate eclectic eels" );
			cli_execute( "skate merry" );
			cli_execute( "skate band" );
		}
		if(contains_text(visit_url(),"6F.gif"))
		{
			cli_execute( "concert Winklered" );
		}
		else if(contains_text(visit_url(),"6H.gif"))
		{
			cli_execute( "concert Dilated Pupils" );
		}
//do quests then farm------------------------------------------		
		if(have_familiar($familiar[dancing frog]))
		{
			cli_execute( "familiar dancing frog" );
		}
// check drink me potion------------------------------------------		
		if(my_name()!="twistedmage" && item_amount(to_item(4508))!=0)
		{
			abort("Looks like you are supposed to do something with a drink me potion");
		}
		cli_execute( "a-questing.ash" );
		dress_for_fighting();
		print("farming","blue");
		cli_execute( "alt_farm.ash" );
		if(my_adventures()==0 || my_inebriety()>inebriety_limit())
		{
			cli_execute("exit");
	//		cli_execute("bed.ash");
		}
		cli_execute("awake");
//end alt stuff		
	}
//repeat	
	if(my_adventures()==0 || my_inebriety()>inebriety_limit())
	{
		cli_execute("exit");
	}
	cli_execute("awake");
}

void main()
{
	//----------------------------------------
	visit_url("main.php");
	visit_url("store.php?whichstore=m");
	//----------------------------------------
//---------------------digging
	visit_url("plains.php?action=bigg"); //get shovel
//	cli_execute("biggdig "+my_adventures());
	if(my_name()!="twistedmage")
	{
		cli_execute("csend * fossilized limb to twistedmage");
		cli_execute("csend * fossilized wing to twistedmage");
		cli_execute("csend * fossilized spike to twistedmage");
		cli_execute("csend * volcanic ash to twistedmage");
		cli_execute("csend * unearthed potsherd to twistedmage");
		cli_execute("csend * fossilized baboon skull to twistedmage");
		cli_execute("csend * fossilized bat skull to twistedmage");
		cli_execute("csend * fossilized serpent skull to twistedmage");
		cli_execute("csend * fossilized spine to twistedmage");
		cli_execute("csend * fossilized torso to twistedmage");
	}
//----------------------------
	if(item_amount($item[Clan VIP Lounge key])!=0)
	{
		string text = visit_url("clan_viplounge.php?action=crimbotree&pwd");
	}
	cli_execute("hagnk * meat");
	if(item_amount($item[raffle prize box])!=0)
	{
		abort("You have a raffle prize box!");
	}
	if(my_meat()<150000 && can_interact() && contains_text(visit_url("town_clan.php"),"rumpusroom.gif"))
	{
		print("stash pulling meat","blue");
		if(stash_amount($item[dense meat stack])>=150)
		{
			take_stash(150,$item[dense meat stack]);
			cli_execute("autosell * dense meat stack");
		}
		else
		{
			abort("No stacks in stash.");
		}
	}
//get pet sorted----------------------------------------------------------
	if(my_level()<10 && my_familiar()==$familiar[none] && can_interact() && my_meat()>500 && item_amount($item[mosquito larva])>0)
	{
		if(item_amount($item[Familiar-Gro Terrarium])==0)
		{
			buy(1,$item[Familiar-Gro Terrarium]);
		}
		use(1,$item[Familiar-Gro Terrarium]);
		use(1,$item[mosquito larva]);
		use_familiar($familiar[Mosquito]);
	}
//run awake or bed as needed----------------------------------------------
	if(my_adventures()>0 && my_inebriety()<=inebriety_limit())
	{
		morning();
	}
	else
	{
		cli_execute("bed.ash");
	}
}