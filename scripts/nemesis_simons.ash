import <QuestLib.ash>;
import <nscomb.ash>;
import <sims_lib.ash>;

void prepare_for_lumpy()
{
	if(have_effect($effect[Bilious Briskness])==0)
	{
		add_item_condition(9-item_amount($item[vial of red slime]) , $item[vial of red slime] );
		add_item_condition(9-item_amount($item[vial of blue slime]) , $item[vial of blue slime] );
		add_item_condition(9-item_amount($item[vial of yellow slime]) , $item[vial of yellow slime] );
		if(item_amount($item[vial of yellow slime])<9 || item_amount($item[vial of red slime])<9 || item_amount($item[vial of blue slime])<9)
		{
			boolean catch=adventure(my_adventures(),$location[convention hall lobby]);
		}
		//create useful potions
		if(item_amount($item[vial of yellow slime])>8 && item_amount($item[vial of red slime])>8 && item_amount($item[vial of blue slime])>8)
		{
			cli_execute("make-useful-vials.ash");
		}
		//get slime buffs
		if(my_adventures()>0 && item_amount($item[vial of vermilion slime])>0 && item_amount($item[vial of amber slime])>0 && item_amount($item[vial of chartreuse slime])>0 && item_amount($item[vial of teal slime])>0 && item_amount($item[vial of purple slime])>0 && item_amount($item[vial of indigo slime])>0 && item_amount($item[vial of orange slime])>0 && item_amount($item[vial of green slime])>0 && item_amount($item[vial of violet slime])>0 && item_amount($item[vial of red slime])>0 && item_amount($item[vial of yellow slime])>0 && item_amount($item[vial of blue slime])>0)
		{
			use(1,$item[vial of vermilion slime]);
			use(1,$item[vial of amber slime]);
			use(1,$item[vial of chartreuse slime]);
			use(1,$item[vial of teal slime]);
			use(1,$item[vial of purple slime]);
			use(1,$item[vial of indigo slime]);
			use(1,$item[vial of orange slime]);
			use(1,$item[vial of green slime]);
			use(1,$item[vial of violet slime]);
			use(1,$item[vial of red slime]);
			use(1,$item[vial of yellow slime]);
			use(1,$item[vial of blue slime]);
		}
	}
	//get saucespheres
	if(have_effect($effect[Elemental Saucesphere])==0)
	{
		use_skill($skill[Elemental Saucesphere]);
	}
	if(have_effect($effect[Jalapeno Saucesphere])==0)
	{
		use_skill($skill[Jalapeno Saucesphere]);
	}
	if(have_effect($effect[Jabanero Saucesphere])==0)
	{
		use_skill($skill[Jabanero Saucesphere]);
	}
	if(have_effect($effect[Scarysauce])==0)
	{
		if( have_skill($skill[Scarysauce]) )
		{
			use_skill($skill[Scarysauce]);
		}
		else
		{
			//try and get a buffbot buff
			visit_url("sendmessage.php?toid=&action=send&towho=Testudinata&contact=0&message=hiya%2C+how%27s+it+going%3F&howmany1=1&whichitem1=0&sendmeat=12&messagesend=Send+Message.&pwd");
		}
	}
	//equip LEW
	cli_execute("maximize initiative, 0.1 mysticality, 0.1 spell damage");
	equip($item[17-alarm Saucepan]);
	cli_execute("recover hp");
	cli_execute("recover mp");
}

boolean allpapers()
{
	if(available_amount($item[a creased paper strip]) == 0)
	{
		return false;
	}
	if(available_amount($item[a folded paper strip]) == 0)
	{
		return false;
	}
	if(available_amount($item[a crinkled paper strip]) == 0)
	{
		return false;
	}
	if(available_amount($item[a crumpled paper strip]) == 0)
	{
		return false;
	}
	if(available_amount($item[a rumpled paper strip]) == 0)
	{
		return false;
	}
	if(available_amount($item[a torn paper strip]) == 0)
	{
		return false;
	}
	if(available_amount($item[a ragged paper strip]) == 0)
	{
		return false;
	}
	if(available_amount($item[a ripped paper strip]) == 0)
	{
		return false;
	}
	return true;
}

string nem_pass(){
	string temp,pass;
	int[string] left,right;
	int[int] order;
	cli_execute("nemesis strips");
	foreach num in $ints[3144,4138,4139,4140,4141,4142,4143,4144]{
		temp = to_string(get_property("lastPaperStrip"+num));
		left[substring(temp,0,index_of(temp,":"))] = num;
		right[substring(temp,last_index_of(temp,":")+1)] = num;
	}
	foreach st in left
		if(!(right contains st))
			order[1] = left[st];
	for num from 2 upto 8{
		foreach st in left{
			temp = to_string(get_property("lastPaperStrip"+order[num - 1]));
			if(st == substring(temp,last_index_of(temp,":")+1))
			order[num] = left[st];
		}
	}
	foreach num,itm in order{
		temp = to_string(get_property("lastPaperStrip"+itm));
		pass = pass + substring(temp,index_of(temp,":")+1,last_index_of(temp,":"));
	}
	return pass;
}

void nemesisquest()
{
	visit_url("guild.php?place=ocg&pwd");
	visit_url("guild.php?place=scg&pwd");
	if(contains_text(visit_url("questlog.php?which=1&pwd"),"Me and My Nemesis") && !contains_text(visit_url("questlog.php?which=2&pwd"),"A Dark and Dank and Sinister Quest") )
	{
		dress_for_fighting();
//setup items
		item class_item_1;
		int id_1;
		item class_item_2;
		int id_2;
		item class_item_3;
		int id_3;
		item legendary;
		item epic;
		if((my_class()==$class[seal clubber]))
		{
			class_item_1=$item[viking helmet];
			id_1=37;
			class_item_2=$item[insanely spicy bean burrito];
			id_2=316;
			class_item_3=$item[clown whip];
			id_3=2478;
			legendary=$item[Hammer of Smiting];
			epic=$item[Bjorn's Hammer];
		}
		else if(my_class()==$class[turtle tamer])
		{
			class_item_1=$item[viking helmet];
			id_1=37;
			class_item_2=$item[insanely spicy bean burrito];
			id_2=316;
			class_item_3=$item[clownskin buckler];
			id_3=2477;
			legendary=$item[Chelonian Morningstar];
			epic=$item[Mace of the Tortoise];
		}
		else if(my_class()==$class[disco bandit])
		{
			class_item_1=$item[dirty hobo gloves];
			id_1=565;
			class_item_2=$item[insanely spicy jumping bean burrito];
			id_2=1256;
			class_item_3=$item[horizontal tango];
			id_3=683;
			legendary=$item[Shagadelic Disco Banjo];
			epic=$item[Disco Banjo];
		}
		else if(my_class()==$class[accordion thief])
		{
			class_item_1=$item[dirty hobo gloves];
			id_1=565;
			class_item_2=$item[insanely spicy jumping bean burrito];
			id_2=1256;
			class_item_3=$item[aspirin]; //something you can't get
			id_3=0;
			legendary=$item[Squeezebox of the Ages];
			epic=$item[Rock and Roll Legend];
		}
		else if(my_class()==$class[pastamancer])
		{
			class_item_1=$item[stalk of asparagus];
			id_1=560;
			class_item_2=$item[insanely spicy enchanted bean burrito];
			id_2=319;
			class_item_3=$item[boring spaghetti];
			id_3=579;
			legendary=$item[Greek Pasta of Peril];
			epic=$item[Pasta of Peril];
		}
		else
		{
			class_item_1=$item[stalk of asparagus];
			id_1=560;
			class_item_2=$item[insanely spicy enchanted bean burrito];
			id_2=319;
			class_item_3=$item[tomato juice of powerful power];
			id_3=420;
			legendary=$item[17-alarm Saucepan];
			epic=$item[5-Alarm Saucepan];
		}



		if(available_amount(epic) == 0 && available_amount(legendary) == 0)
		{
			if(available_amount($item[big rock]) == 0)
			{
				cli_execute("acquire ten-leaf clover");
				if(available_amount($item[casino pass]) == 0)
				{
					cli_execute("acquire casino pass");
				}
				visit_url("casino.php?action=slot&whichslot=11");
			}
			cli_execute("acquire "+epic);
			visit_url("guild.php?place=ocg&pwd");
			visit_url("guild.php?place=scg&pwd");
		}
		//note if the script stops in the middle of this if statement, after killing the king but not making the legendary, it will next time try to kill the king forever
		if(available_amount(legendary) == 0)
		{
			print("killing the clown king to get "+legendary);
			cli_execute("conditions clear");
			while(available_amount($item[Foolscap fool's cap]) == 0 || available_amount($item[Bloody clown pants]) == 0 || available_amount($item[Clown shoes]) == 0 || available_amount($item[Big red clown nose]) == 0)
			{
				if(my_adventures()==0)
				{
					return;
				}
				adventure(1, $location[Fun House]);
			}
			if(my_adventures()>0)
			{
				cli_execute("checkpoint");
				cli_execute("equip Foolscap fool's cap");
				cli_execute("equip Bloody clown pants");
				cli_execute("equip acc1 Big red clown nose");
				cli_execute("equip acc2 clown shoes");
				set_property("choiceAdventure151", "1");
				set_property("choiceAdventure152", "1");
				cli_execute("conditions clear");
				boolean done=false;
				while(my_adventures()>0 && item_amount(legendary)==0 && contains_text(visit_url("questlog.php?which=1&pwd"),"you must defeat Beelzebozo"))
				{
					done = adventure(request_noncombat(1), $location[Fun House]);
				}
				if(contains_text(visit_url("questlog.php?which=1&pwd"),"killed the clownlord Beelzebozo"))
				{
					cli_execute("acquire "+legendary);
				}
				cli_execute("outfit checkpoint");
				visit_url("guild.php?place=ocg&pwd");
				visit_url("guild.php?place=scg&pwd");
			}
		}		
		if(!contains_text(visit_url("questlog.php?which=1&pwd"),"opened the first door in your Nemesis' cave"))
		{
			print("Getting class item 1");
			while(available_amount(class_item_1) == 0)
			{
				if(class_item_1==$item[viking helmet])
				{
					adventure(1, $location[Outskirts of The Knob]);
				}
				else if(class_item_1==$item[stalk of asparagus])
				{
					adventure(1, $location[Haunted Pantry]);
				}
				else if(class_item_1==$item[dirty hobo gloves])
				{
					adventure(1, $location[Sleazy Back Alley]);
				}
			}
			visit_url("cave.php?action=door1&action=dodoor1&whichitem="+id_1+"&pwd");
		}		
		if(!contains_text(visit_url("questlog.php?which=1&pwd"),"opened the second door in your Nemesis' cave"))
		{
			print("Getting class item 2");
			while(item_amount(class_item_2) == 0 && my_adventures()>0)
			{
				cli_execute("inv dough");
				if(item_amount($item[flat dough]) == 0)
				{
					if(item_amount($item[wad of dough]) == 0)
					{
						adventure(1, $location[cobb's Knob Kitchens]);
					}
					else
					{
						use(1,$item[wad of dough]);
					}
				}
				else if(available_amount($item[spices]) == 0)
				{
					adventure(1, $location[cobb's Knob Kitchens]);
				}
				else if(available_amount($item[jabanero pepper]) == 0)
				{
					cli_execute("acquire 1 jabanero pepper");
				}
				else if(class_item_2==$item[insanely spicy bean burrito] && available_amount($item[hill of beans]) == 0)
				{
					adventure(1, $location[treasury]);
				}
				else if(class_item_2==$item[Insanely spicy enchanted bean burrito] && available_amount($item[enchanted bean]) == 0)
				{
					adventure(1, $location[Beanbat Chamber]);
				}
				else if(class_item_2==$item[Insanely spicy jumping bean burrito] && available_amount($item[pile of jumping beans]) == 0)
				{
					adventure(1, $location[South of The Border]);
				}
				else
				{
					cli_execute("acquire "+class_item_2);
				}
			}
			visit_url("cave.php?action=door2&action=dodoor2&whichitem="+id_2+"&pwd");
		}		
		if(!contains_text(visit_url("questlog.php?which=1&pwd"),"Woo! You're past the doors and it's time to stab some bastards"))
		{
			print("Getting class item 3");
			while(available_amount(class_item_3) == 0 && !(my_class()==$class[accordion thief]))
			{
				if(class_item_3==$item[clown whip])
				{
					while(available_amount($item[clown skin]) == 0)
					{
						adventure(1, $location[Fun House]);
					}
					cli_execute("acquire clown whip");
				}
				else if(class_item_3==$item[clownskin buckler])
				{
					while(available_amount($item[clown skin]) == 0)
					{
						adventure(1, $location[Fun House]);
					}
					cli_execute("acquire "+class_item_3);
				}
				else if(class_item_3==$item[tomato juice of powerful power])
				{
					cli_execute("acquire tomato juice of powerful power");
				}
				else if(class_item_3==$item[boring spaghetti])
				{
					cli_execute("acquire boring spaghetti");
				}
				else if(class_item_3==$item[horizontal tango])
				{
					cli_execute("acquire horizontal tango");
				}
			}
			if(my_class()==$class[accordion thief])
			{
				cli_execute("cast 3 polka of plenty");
			}
			visit_url("cave.php?action=door3&action=dodoor3&whichitem="+id_3+"&pwd");
		}
		if(!allpapers())
		{
			print("Getting papers");
			cli_execute("conditions clear");
			while(!allpapers() && my_adventures()>0)
			{
				adventure(1, $location[Nemesis Cave]);
			}
		}
		if(my_adventures()==0)
		{
			return;
		}
		string my_pass = nem_pass();
		print(my_pass);
		cli_execute("equip "+legendary);
		visit_url("cave.php?action=door4&action=dodoor4&say=&say="+my_pass+"&pwd");
		visit_url("cave.php?action=sanctum&pwd");
		run_combat();

		visit_url("guild.php?place=ocg&pwd");
		visit_url("guild.php?place=scg&pwd");
	}
	else
	{
		print("already done the nemesis quest part 1");
	}
}


void pisland()
{
	dress_for_fighting();
	//get encoded documents
	visit_url("volcanoisland.php?pwd&action=npc");
	//get 5 cult memos
	cli_execute("conditions clear");
	if(item_amount($item[cult memo])!=5 && item_amount($item[decoded cult documents])==0)
	{
		print("","blue");
		add_item_condition(5-item_amount($item[cult memo]) , $item[cult memo] );
		boolean catch = adventure(my_adventures(),$location[The temple portico]);
	}
	//level a spaghetti elemental to level 3
	if(item_amount($item[cult memo])==5)
	{
		use(1,$item[cult memo]);
	}
	if(item_amount($item[Decoded cult documents])>0 && get_property("pastamancerGhostType")!="Spaghetti Elemental")
	{
		print("learning ghost","blue");
		if(contains_text(visit_url("inv_use.php?&pwd&which=3&whichitem=3884"),"Are you sure you want to do this?"))
		{
			//click yes
			visit_url("inv_use.php?whichitem=3884&confirm=true&which=3&pwd");
		}
	}
	boolean catch = cli_execute("friars familiar");
	while(to_int(get_property("pastamancerGhostExperience"))<9 && my_adventures()>0 && to_int(get_property("pastamancerGhostSummons"))<10)
	{
		print("leveling ghost","blue");
		set_property("choiceAdventure502","3");
		set_property("choiceAdventure506","1");
		set_property("choiceAdventure26","2");
		set_property("choiceAdventure28","2");
		adventure(1,$location[spooky forest]);
	}
	//get a robe
	while(!get_property("rave_open").to_boolean() && item_amount($item[Spaghetti cult robe])<1 && to_int(get_property("pastamancerGhostExperience"))>8 && my_adventures()>0 && to_int(get_property("pastamancerGhostSummons"))<10)
	{
		print("getting robe","blue");
		adventure(1,$location[The temple portico]);
	}
	//enter lair, fight guards until boss
	if(!get_property("rave_open").to_boolean() && item_amount($item[Spaghetti cult robe])!=0 && my_adventures()>0 && contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
	{
		print("opening temple","blue");
		equip($item[Spaghetti cult robe]);
		visit_url("volcanoisland.php?action=tniat&pwd");
		set_property("rave_open","true");
	}
	while(contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding") && to_int(get_property("pastamancerGhostExperience"))>8 && my_adventures()>0 && get_property("pastamancerGhostType")=="Spaghetti Elemental")
	{
		print("clearing temple","blue");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat penultimate boss
		if(contains_text(page,"Spaghetti Elemental"))
		{
			custom_fight("1","the Spaghetti Elemental",page);
		}
		else if(contains_text(page,"an evil spaghetti cult zealot"))
		{
			custom_fight("1","an evil spaghetti cult zealot",page);
		}
		else
		{
			abort(page);
		}
//		adventure(1,$location[The nemesis' lair]);
	}
	if(contains_text(visit_url("questlog.php?which=1")," got away. Again. "))
	{
		//equip LEW
		equip($item[Greek pasta of peril]);
		//do volcano maze
		print("solving maze","green");
		cli_execute("recover both");
		boolean succeeded = cli_execute("volcano solve");
		if(!succeeded)
		{
			//swim back
			print("swimming back","blue");
			visit_url("volcanomaze.php?jump=1&ajax=1&pwd",false);
			pisland();
		}
		wait(30);
		//take last step
		print("last step","green");
		string page = visit_url( "volcanomaze.php?move=6,6&ajax=1&pwd", false );
		wait(30);
		//run away from penultimate boss
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		pisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"biggest pain-in-the-ass puzzle in the entire game") )
	{
		equip($item[Greek pasta of peril]);
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat penultimate boss
		custom_fight("1","the Spaghetti Elemental",page);
		page = visit_url("choice.php?pwd&whichchoice=437&option=1&choiceform1=Continue");
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		//run away
		cli_execute("refresh inventory");
		pisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"I just want to say: good luck. We're all counting on you") )
	{
		equip($item[Greek pasta of peril]);
		boolean catch = cli_execute("ballpit");
		cli_execute("recover hp");
		cli_execute("recover mp");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat last boss
		custom_fight("1","the Spaghetti Demon",page);
	}
	visit_url("guild.php?place=ocg&pwd");
	visit_url("guild.php?place=scg&pwd");
	visit_url("volcanoisland.php?action=tniat&pwd");
	if(item_amount($item[black hymnal])>0)
	{
		use(1,$item[black hymnal]);
	}
}

void sisland()
{
	dress_for_fighting();
	//get gu gone
	if(contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
	{
		visit_url("volcanoisland.php?pwd&action=npc");
		cli_execute("conditions clear");
		add_item_condition(15-item_amount($item[vial of red slime]) , $item[vial of red slime] );
		add_item_condition(15-item_amount($item[vial of blue slime]) , $item[vial of blue slime] );
		add_item_condition(15-item_amount($item[vial of yellow slime]) , $item[vial of yellow slime] );
		if(item_amount($item[vial of yellow slime])<15 || item_amount($item[vial of red slime])<15 || item_amount($item[vial of blue slime])<15)
		{
			boolean catch=adventure(my_adventures(),$location[convention hall lobby]);
		}
		simons_have_chef();
		//create untested tertiary potions
		if(item_amount($item[vial of yellow slime])>14 && item_amount($item[vial of red slime])>14 && item_amount($item[vial of blue slime])>14)
		{
			cli_execute("make-quest-vials.ash");
		}
		//test for slimeform
		if(my_adventures()>0 && item_amount($item[vial of vermilion slime])>0 && item_amount($item[vial of amber slime])>0 && item_amount($item[vial of chartreuse slime])>0 && item_amount($item[vial of teal slime])>0 && item_amount($item[vial of purple slime])>0 && item_amount($item[vial of indigo slime])>0)
		{
			use(1,$item[vial of vermilion slime]);
			use(1,$item[vial of amber slime]);
			use(1,$item[vial of chartreuse slime]);
			use(1,$item[vial of teal slime]);
			use(1,$item[vial of purple slime]);
			use(1,$item[vial of indigo slime]);
			visit_url("volcanoisland.php?action=tniat&pwd");
		}
	}
	//enter lair, fight guards until boss
	while(my_adventures()>0 && contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
	{
		adventure(1,$location[The nemesis' lair]);
	}
	if(contains_text(visit_url("questlog.php?which=1")," got away. Again. "))
	{
		equip($item[17-alarm saucepan]);
		//do volcano maze
		print("solving maze","green");
		boolean succeeded = cli_execute("volcano solve");
		if(!succeeded)
		{
			//swim back
			print("swimming back","blue");
			visit_url("volcanomaze.php?jump=1&ajax=1&pwd",false);
			sisland();
		}
		wait(30);
		//take last step
		print("last step","green");
		string page = visit_url( "volcanomaze.php?move=6,6&ajax=1&pwd", false );
		wait(30);
		//run away from penultimate boss
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		sisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"biggest pain-in-the-ass puzzle in the entire game") )
	{
		equip($item[17-alarm saucepan]);
		boolean catch = cli_execute("ballpit");
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat penultimate boss
		custom_fight("1","Lumpy, the Sinister Sauceblob",page);
		page = visit_url("choice.php?pwd&whichchoice=437&option=1&choiceform1=Continue");
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		//run away
		sisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"I just want to say: good luck. We're all counting on you") )
	{
		prepare_for_lumpy();	
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat last boss
		custom_fight("1","Lumpy, the Demonic Sauceblob",page);
	}
	visit_url("guild.php?place=ocg&pwd");
	visit_url("guild.php?place=scg&pwd");
}

void disland()
{
	dress_for_fighting();
	//get gothy handwave
	visit_url("volcanoisland.php?pwd&action=npc");
	//gather dance moves
	while((!have_skill($skill[break it on down]) || !have_skill($skill[pop and lock it]) || !have_skill($skill[run like the wind])) && my_adventures()>0)
	{
		
		print("Learning rave skills","green");
		cli_execute("recover hp");
		cli_execute("recover mp");
		string fight = visit_url("volcanoisland.php?action=tuba&pwd");
		boolean learned=false;
		//running man
		if(fight.contains_text("continues jogging in place as he looks you up and down"))
		{
			while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
			{
				if(!learned && !have_skill($skill[run like the wind]))
				{
					if(fight.contains_text("and soon realize he isn't actually running anywhere"))
					{
						fight = use_skill($skill[gothy handwave]);
						learned=true;
					}
					else
					{
						if(item_amount($item[Facsimile dictionary])!=0)
						{
							fight = throw_item($item[Facsimile dictionary]);
						}
						else if(item_amount($item[spices])!=0)
						{
							fight = throw_item($item[spices]);
						}
						else
						{
							abort("No stasis item to throw, maybe try spectre sceptre?");
						}
					}
				}
				else
				{
					fight = attack();
				}
			}
		} //pop and lock raver
		else if(fight.contains_text("pants so large he's practically swimming in them"))
		{
			while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
			{
				if(!learned && !have_skill($skill[pop and lock it]))
				{
					if(fight.contains_text("weird rhythmic effect is puzzling"))
					{
						fight = use_skill($skill[gothy handwave]);
						learned=true;
					}
					else
					{
						if(item_amount($item[Facsimile dictionary])!=0)
						{
							fight = throw_item($item[Facsimile dictionary]);
						}
						else if(item_amount($item[spices])!=0)
						{
							fight = throw_item($item[spices]);
						}
						else
						{
							abort("No stasis item to throw, maybe try spectre sceptre?");
						}
					}
				}
				else
				{
					fight = attack();
				}
			}
		}
		else if(fight.contains_text("pacifier out of his mouth and sneers at you"))//fighting break dancing raver
		{
			while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
			{
				if(!learned && !have_skill($skill[break it on down]))
				{
					if(fight.contains_text("drops to the ground and starts spinning his legs wildly"))
					{
						fight = use_skill($skill[gothy handwave]);
						learned=true;
					}
					else
					{
						if(item_amount($item[Facsimile dictionary])!=0)
						{
							fight = throw_item($item[Facsimile dictionary]);
						}
						else if(item_amount($item[spices])!=0)
						{
							fight = throw_item($item[spices]);
						}
						else
						{
							abort("No stasis item to throw, maybe try spectre sceptre?");
						}
					}
				}
				else
				{
					fight = attack();
				}
			}
		}
	}
	//test all combos
	if(get_property("raveCombo5")=="")
	{
		boolean comb1=false;
		boolean comb2=false;
		boolean comb3=false;
		boolean comb4=false;
		boolean comb5=false;
		boolean comb6=false;
		while((!comb1 || !comb2 || !comb3 || !comb4 || !comb5 || !comb6) && my_adventures()>0)
		{
			print("Checking rave combo","green");
			cli_execute("recover hp");
			cli_execute("recover mp");
			int round=1;
			if(!comb1)
			{
				print("Checking rave combo: 1","green");
				string fight = visit_url("volcanoisland.php?action=tuba&pwd");
				while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
				{
					if(round==1)
					{
						fight = use_skill($skill[Break It On Down]);
						round=round+1;
					}
					else if(round==2)
					{
						fight = use_skill($skill[Pop and Lock It]);
						round=round+1;
					}
					else if(round==3)
					{
						fight = use_skill($skill[Run Like the Wind]);
						round=round+1;
						comb1=true;
					}
					else
					{
						fight = attack();
					}
				}
			}
			else if(!comb2)
			{
				print("Checking rave combo: 2","green");
				string fight = visit_url("volcanoisland.php?action=tuba&pwd");
				while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
				{
					if(round==1)
					{
						fight = use_skill($skill[Break It On Down]);
						round=round+1;
					}
					else if(round==2)
					{
						fight = use_skill($skill[Run Like the Wind]);
						round=round+1;
					}
					else if(round==3)
					{
						fight = use_skill($skill[Pop and Lock It]);
						round=round+1;
						comb2=true;
					}
					else
					{
						fight = attack();
					}
				}
			}
			else if(!comb3)
			{
				print("Checking rave combo: 3","green");
				string fight = visit_url("volcanoisland.php?action=tuba&pwd");
				while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
				{
					if(round==1)
					{
						fight = use_skill($skill[Pop and Lock It]);
						round=round+1;
					}
					else if(round==2)
					{
						fight = use_skill($skill[Break It On Down]);
						round=round+1;
					}
					else if(round==3)
					{
						fight = use_skill($skill[Run Like the Wind]);
						round=round+1;
						comb3=true;
					}
					else
					{
						fight = attack();
					}
				}
			}
			else if(!comb4)
			{
				print("Checking rave combo: 4","green");
				string fight = visit_url("volcanoisland.php?action=tuba&pwd");
				while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
				{
					if(round==1)
					{
						fight = use_skill($skill[Pop and Lock It]);
						round=round+1;
					}
					else if(round==2)
					{
						fight = use_skill($skill[Run Like the Wind]);
						round=round+1;
					}
					else if(round==3)
					{
						fight = use_skill($skill[Break It On Down]);
						round=round+1;
						comb4=true;
					}
					else
					{
						fight = attack();
					}
				}
			}
			else if(!comb5)
			{
				print("Checking rave combo: 5","green");
				string fight = visit_url("volcanoisland.php?action=tuba&pwd");
				while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
				{
					if(round==1)
					{
						fight = use_skill($skill[Run Like the Wind]);
						round=round+1;
					}
					else if(round==2)
					{
						fight = use_skill($skill[Break It On Down]);
						round=round+1;
					}
					else if(round==3)
					{
						fight = use_skill($skill[Pop and Lock It]);
						round=round+1;
						comb5=true;
					}
					else
					{
						fight = attack();
					}
				}
			}
			else if(!comb6)
			{
				print("Checking rave combo: 6","green");
				string fight = visit_url("volcanoisland.php?action=tuba&pwd");
				while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
				{
					if(round==1)
					{
						fight = use_skill($skill[Run Like the Wind]);
						round=round+1;
					}
					else if(round==2)
					{
						fight = use_skill($skill[Pop and Lock It]);
						round=round+1;
					}
					else if(round==3)
					{
						fight = use_skill($skill[Break It On Down]);
						round=round+1;
						comb6=true;
					}
					else
					{
						fight = attack();
					}
				}
			}
		}
	}
	//use pickpocket combo to get 6 set pieces
	int total_rave_gear=0;
	item [int] rave_gear;
	rave_gear[0]=$item[rave visor];
	rave_gear[1]=$item[glowstick on a string];
	rave_gear[2]=$item[baggy rave pants];
	rave_gear[3]=$item[candy necklace];
	rave_gear[4]=$item[pacifier necklace];
	rave_gear[5]=$item[teddybear backpack];
	rave_gear[6]=$item[rave whistle];
	foreach it in rave_gear
	{
		if(item_amount(rave_gear[it])>0)
		{
			if(rave_gear[it]==$item[rave visor] || rave_gear[it]==$item[baggy rave pants] || rave_gear[it]==$item[pacifier necklace])
			{
				total_rave_gear=total_rave_gear+2;
			}
			else
			{
				total_rave_gear=total_rave_gear+1;
			}
		}
	}
	while(total_rave_gear<7)
	{
		print("Looking for rave gear","green");
		cli_execute("recover hp");
		cli_execute("recover mp");
		//do fight with rave pickpocket
		string fight = visit_url("volcanoisland.php?action=tuba&pwd");
		int round=1;
		print("raveCombo5="+get_property("raveCombo5"),"green");
		matcher combo = create_matcher("(.+),(.+),(.+)", get_property("raveCombo5")); 
		combo.find();
		while(!fight.contains_text("slink away") && !fight.contains_text("You win the fight") )
		{
			if(round<4)
			{
				print("combo move="+combo.group(round),"green");
				fight = use_skill(combo.group(round).to_skill());
				round=round+1;
			}
			else
			{
				fight = attack();
			}
		}
		//update ravosity
		total_rave_gear=0;
		foreach it in rave_gear
		{
			if(item_amount(rave_gear[it])>0)
			{
				if(rave_gear[it]==$item[rave visor] || rave_gear[it]==$item[baggy rave pants] || rave_gear[it]==$item[pacifier necklace])
				{
					total_rave_gear=total_rave_gear+2;
				}
				else
				{
					total_rave_gear=total_rave_gear+1;
				}
			}
		}
	}
	print("Finished gathering rave gear","green");
	string equip_string="maximize moxie ";
	total_rave_gear=0;
	foreach it in rave_gear
	{
		if(item_amount(rave_gear[it])>0)
		{
			if(rave_gear[it]==$item[rave visor] || rave_gear[it]==$item[baggy rave pants] || rave_gear[it]==$item[pacifier necklace])
			{
				total_rave_gear=total_rave_gear+2;
			}
			else
			{
				total_rave_gear=total_rave_gear+1;
			}
			equip_string=equip_string+", equip "+rave_gear[it];
		}
	}
	if(!get_property("rave_open").to_boolean() && my_adventures()>0 && total_rave_gear>6)
	{
		print(equip_string,"green");
		cli_execute(equip_string);
		visit_url("volcanoisland.php?pwd&action=tniat&pwd&action=tniat&action2=try");
		cli_execute("set rave_open = true");
		dress_for_fighting();
	}
	//enter lair, fight guards until boss
	while(my_adventures()>0 && get_property("rave_open").to_boolean() && contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
	{
		adventure(1,$location[The nemesis' lair]);
	}
	if(contains_text(visit_url("questlog.php?which=1")," got away. Again. "))
	{
		print("a","green");
		//equip LEW
		equip($item[shagadelic disco banjo]);
		//do volcano maze
		print("solving maze","green");
		boolean succeeded = cli_execute("volcano solve");
		if(!succeeded)
		{
			//swim back
			print("swimming back","blue");
			visit_url("volcanomaze.php?jump=1&ajax=1&pwd",false);
			disland();
		}
		wait(30);
		//take last step
		print("last step","green");
		string page = visit_url( "volcanomaze.php?move=6,6&ajax=1&pwd", false );
		wait(30);
		//run away from penultimate boss
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"You run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		disland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"biggest pain-in-the-ass puzzle in the entire game") )
	{
		print("b","green");
		cli_execute("maximize moxie, equip shagadelic disco banjo");
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat penultimate boss
		custom_fight("1","The Spirit of New Wave",page);
		page = visit_url("choice.php?pwd&whichchoice=437&option=1&choiceform1=Continue");
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		//run away
		disland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"I just want to say: good luck. We're all counting on you") )
	{
		cli_execute("maximize moxie, equip shagadelic disco banjo");
		boolean catch = cli_execute("ballpit");
		if(have_effect($effect[incredibly hulking])==0)
		{
			use(1,$item[Ferrigno's Elixir of Power]);
		}
		cli_execute("recover hp");
		cli_execute("recover mp");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat last boss
		custom_fight("1","Demon Spirit of New Wave",page);
	}
	visit_url("guild.php?place=ocg&pwd");
	visit_url("guild.php?place=scg&pwd");
	//reset the rave_open variable
	if(contains_text(visit_url("questlog.php?which=2"),"has fallen beneath your mighty assault"))
	{
		cli_execute("set rave_open = false");
	}
}

void aisland()
{
	dress_for_fighting();
	abort("not implement");
	//visit village
	visit_url("volcanoisland.php?pwd&action=npc");
	//explore barracks for keys
	if(my_adventures()>18)
	{
		set_property("choiceAdventure409", "1");
		string [int] advstring1;
		string [int] advstring2;
		string [int] advstring3;
		string [int] advstringchoice1;
		string [int] advstringchoice2;
		string [int] advstringchoice3;
		//choices for exploration round 0
		advstring2[0] = "411";
		advstring3[0] = "413";
		advstringchoice1[0] = "1";
		advstringchoice2[0] = "1";
		advstringchoice3[0] = "1";
		//choices for exploration round 1
		advstring2[1] = "411";
		advstring3[1] = "413";
		advstringchoice1[1] = "1";
		advstringchoice2[1] = "1";
		advstringchoice3[1] = "2";
		//choices for exploration round 2
		advstring2[2] = "411";
		advstring3[2] = "413";
		advstringchoice1[2] = "1";
		advstringchoice2[2] = "1";
		advstringchoice3[2] = "3";
		//choices for exploration round 3
		advstring2[3] = "411";
		advstring3[3] = "414";
		advstringchoice1[3] = "1";
		advstringchoice2[3] = "2";
		advstringchoice3[3] = "1";
		//choices for exploration round 4
		advstring2[4] = "411";
		advstring3[4] = "414";
		advstringchoice1[4] = "1";
		advstringchoice2[4] = "2";
		advstringchoice3[4] = "2";
		//choices for exploration round 5
		advstring2[5] = "411";
		advstring3[5] = "414";
		advstringchoice1[5] = "1";
		advstringchoice2[5] = "2";
		advstringchoice3[5] = "3";
		//choices for exploration round 6
		advstring2[6] = "411";
		advstring3[6] = "415";
		advstringchoice1[6] = "1";
		advstringchoice2[6] = "3";
		advstringchoice3[6] = "1";
		//choices for exploration round 7
		advstring2[7] = "411";
		advstring3[7] = "415";
		advstringchoice1[7] = "1";
		advstringchoice2[7] = "3";
		advstringchoice3[7] = "2";
		//choices for exploration round 8
		advstring2[8] = "411";
		advstring3[8] = "415";
		advstringchoice1[8] = "1";
		advstringchoice2[8] = "3";
		advstringchoice3[8] = "3";
		//choices for exploration round 9
		advstring2[9] = "412";
		advstring3[9] = "416";
		advstringchoice1[9] = "2";
		advstringchoice2[9] = "1";
		advstringchoice3[9] = "1";
		//choices for exploration round 10
		advstring2[10] = "412";
		advstring3[10] = "416";
		advstringchoice1[10] = "2";
		advstringchoice2[10] = "1";
		advstringchoice3[10] = "2";
		//choices for exploration round 11
		advstring2[11] = "412";
		advstring3[11] = "416";
		advstringchoice1[11] = "2";
		advstringchoice2[11] = "1";
		advstringchoice3[11] = "3";
		//choices for exploration round 12
		advstring2[12] = "412";
		advstring3[12] = "417";
		advstringchoice1[12] = "2";
		advstringchoice2[12] = "2";
		advstringchoice3[12] = "1";
		//choices for exploration round 13
		advstring2[13] = "412";
		advstring3[13] = "417";
		advstringchoice1[13] = "2";
		advstringchoice2[13] = "2";
		advstringchoice3[13] = "2";
		//choices for exploration round 14
		advstring2[14] = "412";
		advstring3[14] = "417";
		advstringchoice1[14] = "2";
		advstringchoice2[14] = "2";
		advstringchoice3[14] = "3";
		//choices for exploration round 15
		advstring2[15] = "412";
		advstring3[15] = "418";
		advstringchoice1[15] = "2";
		advstringchoice2[15] = "3";
		advstringchoice3[15] = "1";
		//choices for exploration round 16
		advstring2[16] = "412";
		advstring3[16] = "418";
		advstringchoice1[16] = "2";
		advstringchoice2[16] = "3";
		advstringchoice3[16] = "2";
		//choices for exploration round 17
		advstring2[17] = "412";
		advstring3[17] = "418";
		advstringchoice1[17] = "2";
		advstringchoice2[17] = "3";
		advstringchoice3[17] = "3";
		int exploration_round=0;
		while(item_amount($item[hacienda key])<5 && my_adventures()>0)
		{
			//set the choiceadvs
			//first choiceadv
			set_property("choiceAdventure410", advstringchoice1[exploration_round]);
			//second choiceadv
			set_property("choiceAdventure"+advstring2[exploration_round], advstringchoice2[exploration_round]);
			//third choiceadv
			set_property("choiceAdventure"+advstring3[exploration_round], advstringchoice3[exploration_round]);
			adventure(1,$location[the barracks]);
			exploration_round=exploration_round+1;
		}
	}
	else
	{
		print("Not enough turns to fully explore barracks at once","red");
	}
	//enter lair, fight guards until boss
	while(my_adventures()>0 && contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
	{
		adventure(1,$location[The nemesis' lair]);
	}
	if(contains_text(visit_url("questlog.php?which=1")," got away. Again. "))
	{
		//equip LEW
		equip($item[squeezebox of the ages]);
		//do volcano maze
		print("solving maze","green");
		boolean succeeded = cli_execute("volcano solve");
		if(!succeeded)
		{
			//swim back
			print("swimming back","blue");
			visit_url("volcanomaze.php?jump=1&ajax=1&pwd",false);
			aisland();
		}
		wait(30);
		//take last step
		print("last step","green");
		string page = visit_url( "volcanomaze.php?move=6,6&ajax=1&pwd", false );
		wait(30);
		//run away from penultimate boss
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		aisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"biggest pain-in-the-ass puzzle in the entire game") )
	{
		equip($item[squeezebox of the ages]);
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat penultimate boss
		custom_fight("1","Somerset Lopez, Dread Mariachi",page);
		page = visit_url("choice.php?pwd&whichchoice=437&option=1&choiceform1=Continue");
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		//run away
		aisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"I just want to say: good luck. We're all counting on you") )
	{
		equip($item[squeezebox of the ages]);
		boolean catch = cli_execute("ballpit");
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat last boss
		custom_fight("1","Somerset Lopez, Demon Mariachi",page);
	}
	visit_url("guild.php?place=ocg&pwd");
	visit_url("guild.php?place=scg&pwd");
}

void tisland()
{
	dress_for_fighting();
	//equip turtle whip
	visit_url("volcanoisland.php?pwd&action=npc");
	cli_execute("checkpoint");
	while(!to_boolean(get_property("rave_open")))
	{
		equip($item[fouet de tortue-dressage]);
		equip($item[turtling rod]);
		if(have_effect($effect[eau de tortue])==0)
		{
			use(1,$item[turtle pheromones]);
		}
		adventure(1,$location[the outer compound]);
		if(contains_text(visit_url("volcanoisland.php?pwd&action=npc"),"inner compound swings open"))
		{
			set_property("rave_open",true);
		}
	}
	cli_execute("outfit checkpoint");
	if(contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
	{
		visit_url("volcanoisland.php?pwd&action=tniat&pwd");
		//enter lair, fight guards until boss
		while(my_adventures()>0 && contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
		{
			adventure(1,$location[The nemesis' lair]);
		}
	}
	if(contains_text(visit_url("questlog.php?which=1")," got away. Again. "))
	{
		//equip LEW
		equip($item[chelonian morningstar]);
		//do volcano maze
		print("solving maze","green");
		boolean succeeded = cli_execute("volcano solve");
		if(!succeeded)
		{
			//swim back
			print("swimming back","blue");
			visit_url("volcanomaze.php?jump=1&ajax=1&pwd",false);
			tisland();
		}
		wait(30);
		//take last step
		print("last step","green");
		string page = visit_url( "volcanomaze.php?move=6,6&ajax=1&pwd", false );
		wait(30);
		//run away from penultimate boss
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		tisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"biggest pain-in-the-ass puzzle in the entire game") )
	{
		equip($item[chelonian morningstar]);
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat penultimate boss
		custom_fight("1"," Stella, the Turtle Poacher",page);
		page = visit_url("choice.php?pwd&whichchoice=437&option=1&choiceform1=Continue");
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		//run away
		tisland();
	}
	if(contains_text(visit_url("questlog.php?which=1"),"I just want to say: good luck. We're all counting on you") )
	{
		cli_execute("maximize da, dr");
		//use turtle
		cli_execute("familiar untamed turtle");
		cli_execute("mcd 0");
		equip($item[chelonian morningstar]);
		if(have_effect($effect[Incredibly Hulking])==0)
		{
			use(1,$item[Ferrigno's Elixir of Power]);
		}
		if(have_effect($effect[Cock of the Walk])==0)
		{
			use(1,$item[Connery's Elixir of Audacity]);
		}
		if(have_effect($effect[Gr8tness])==0)
		{
			use(1,$item[Potion of temporary gr8tness]);
		}
		if(have_effect($effect[Temporary Lycanthropy])==0)
		{
			use(1,$item[blood of the wereseal]);
		}
		if(have_effect($effect[Butt-Rock Hair])==0)
		{
			use(1,$item[hair spray]);
		}
		if(have_effect($effect[Go Get 'Em, Tiger])==0)
		{
			cli_execute("use 1 ben-gal balm");
		}
		if(have_effect($effect[black face])==0)
		{
			use(1,$item[black facepaint]);
		}
		if(have_effect($effect[Radiating Black Body])==0)
		{
			use(1,$item[Black Body spray]);
		}
		boolean catch = cli_execute("ballpit");
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat last boss
		custom_fight("1"," Stella, the Demonic Turtle Poacher",page);
	}
	visit_url("guild.php?place=ocg&pwd");
	visit_url("guild.php?place=scg&pwd");
}

void scisland()
{
	dress_for_fighting();
	visit_url("volcanoisland.php?pwd&action=npc");
	//make sure club equipped
	if(item_type(equipped_item($slot[weapon]))!="club")
	{
		cli_execute("maximize muscle, equip hammer of smiting");
	}
	if(can_interact())
	{
		equip($item[non-stick pugil stick]);
	}
	if(!get_property("rave_open").to_boolean())
	{
		//shrug passives
		cli_execute("shrug scarysauce");
		cli_execute("shrug Jalapeno Saucesphere");
		cli_execute("shrug Jabanero Saucesphere");
		cli_execute("checkpoint");
		cli_execute("familiar none");
		//kill seals until 6 brains, 6 hides, 6 sinews
		cli_execute("conditions clear");
		add_item_condition(6-item_amount($item[hellseal brain]),$item[hellseal brain]);
		add_item_condition(6-item_amount($item[hellseal hide]),$item[hellseal hide]);
		add_item_condition(6-item_amount($item[hellseal sinew]),$item[hellseal sinew]);
		set_property("hpAutoRecovery","0.8");
		set_property("hpAutoRecoveryTarget","0.95");
		boolean done=false;
		while(my_adventures()>0 && !done)
		{
			//buff
			if(can_interact())
			{
				if(have_effect($effect[Incredibly Hulking])==0)
				{
					use(1,$item[Ferrigno's Elixir of Power]);
				}
				if(have_effect($effect[Cock of the Walk])==0)
				{
					use(1,$item[Connery's Elixir of Audacity]);
				}
				if(have_effect($effect[Gr8tness])==0)
				{
					use(1,$item[potion of temporary gr8tness]);
				}
			}
			else if(my_level()<16)
			{
				print("Mother hellseals are too hard in hardcore below 16","red");
				return;
			}
			//don't need to be out of hardcore for these
			if(have_effect($effect[Go Get 'Em, Tiger!])==0)
			{
				use(1,$item[Ben-Gal Balm]);
			}
			if(have_effect($effect[Radiating Black Body])==0)
			{
				use(1,$item[Black Body spray]);
			}
			if(have_effect($effect[Black Face])==0)
			{
				use(1,$item[Black facepaint]);
			}
			if(have_effect($effect[Butt-Rock Hair])==0)
			{
				use(1,$item[hair spray]);
			}
			done= adventure(1,$location[the broodling grounds]);
			if(have_effect($effect[beat up])!=0)
			{
				cli_execute("recover both");
			}
		}
		cli_execute("checkpoint familiar");
		//make set
		if(item_amount($item[hellseal brain])>5 && item_amount($item[hellseal hide])>5 && item_amount($item[hellseal sinew])>5)
		{
			visit_url("volcanoisland.php?pwd&action=npc");
			visit_url("volcanoisland.php?pwd&action=tniat");
			set_property("rave_open","true");
		}
	}	
	if(get_property("rave_open").to_boolean() && contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
	{
		//enter lair, fight guards until boss
		while(my_adventures()>0 && contains_text(visit_url("questlog.php?which=1"),"As soon as you can find where they're hiding"))
		{
			adventure(1,$location[The nemesis' lair]);
		}
	}
	if(get_property("rave_open").to_boolean() && contains_text(visit_url("questlog.php?which=1")," got away. Again. "))
	{
		//equip LEW
		equip($item[hammer of smiting]);
		//do volcano maze
		print("solving maze","green");
		boolean succeeded = cli_execute("volcano solve");
		if(!succeeded)
		{
			//swim back
			print("swimming back","blue");
			visit_url("volcanomaze.php?jump=1&ajax=1&pwd",false);
			scisland();
		}
		wait(30);
		//take last step
		print("last step","green");
		string page = visit_url( "volcanomaze.php?move=6,6&ajax=1&pwd", false );
		wait(30);
		//run away from penultimate boss
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		scisland();
	}
	if(get_property("rave_open").to_boolean() && contains_text(visit_url("questlog.php?which=1"),"biggest pain-in-the-ass puzzle in the entire game") )
	{
		equip($item[hammer of smiting]);
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat penultimate boss
		custom_fight("1","Gorgolok, the Infernal Seal",page);
		page = visit_url("choice.php?pwd&whichchoice=437&option=1&choiceform1=Continue");
		while(!contains_text(page,"slink away") && !contains_text(page,"You win the fight") && !contains_text(page,"ou run away") && page!="")
		{
			print("running away","green");
			wait(3);
			page=runaway();
		}
		cli_execute("refresh inventory");
		//run away
		scisland();
	}
	if(get_property("rave_open").to_boolean() && contains_text(visit_url("questlog.php?which=1"),"I just want to say: good luck. We're all counting on you") )
	{
		equip($item[hammer of smiting]);
		boolean catch = cli_execute("ballpit");
		cli_execute("recover both");
		string page = visit_url("volcanoisland.php?action=tniat&pwd");
		//beat last boss
		custom_fight("1","Gorgolok, the Demonic Hellseal",page);
	}
	visit_url("guild.php?place=ocg&pwd");
	visit_url("guild.php?place=scg&pwd");
	visit_url("volcanoisland.php?pwd&action=npc");
}



void nemesisquest2()
{
	//if not done with stage 2
	if(!contains_text(visit_url("questlog.php?which=2"),"the Demonic Lord of Revenge") && my_adventures()>0)
	{
		dress_for_fighting();
		if(item_amount($item[secret tropical island volcano lair map])!=0)
		{
			//check to sell the money making assassin loot
			if(item_amount($item[Heimandatz's heart])>0)
			{
				autosell(1,$item[Heimandatz's heart]);
			}
			if(item_amount($item[Argarggagarg's fang])>0)
			{
				autosell(1,$item[Argarggagarg's fang]);
			}
			if(item_amount($item[The Mariachi's guitar case])>0)
			{
				autosell(1,$item[The Mariachi's guitar case]);
			}
			if(item_amount($item[Jocko Homo's head])>0)
			{
				autosell(1,$item[Jocko Homo's head]);
			}
			if(item_amount($item[Yakisoba's hat])>0)
			{
				autosell(1,$item[Yakisoba's hat]);
			}
			if(item_amount($item[Safari Jack's moustache])>0)
			{
				autosell(1,$item[Safari Jack's moustache]);
			}
			//check to use the pet
			if(item_amount($item[Friendly cheez blob])>0)
			{
				if(!have_familiar($familiar[Pet Cheezling]))
				{
					use(1,$item[Friendly cheez blob]);
				}
				else
				{
					autosell(1,$item[Friendly cheez blob]);
				}
			}
			if(item_amount($item[adorable seal larva])>0)
			{
				if(!have_familiar($familiar[adorable seal larva]))
				{
					use(1,$item[adorable seal larva]);
				}
				else
				{
					autosell(1,$item[adorable seal larva]);
				}
			}
			if(item_amount($item[stray chihuahua])>0)
			{
				if(!have_familiar($familiar[Mariachi Chihuahua]))
				{
					use(1,$item[stray chihuahua]);
				}
				else
				{
					autosell(1,$item[stray chihuahua]);
				}
			}
			if(item_amount($item[unusual disco ball])>0)
			{
				if(!have_familiar($familiar[autonomous disco ball]))
				{
					use(1,$item[unusual disco ball]);
				}
				else
				{
					autosell(1,$item[unusual disco ball]);
				}
			}
			if(item_amount($item[macaroni duck])>0)
			{
				if(!have_familiar($familiar[macaroni duck]))
				{
					use(1,$item[macaroni duck]);
				}
				else
				{
					autosell(1,$item[macaroni duck]);
				}
			}
			if(item_amount($item[untamable turtle])>0)
			{
				if(!have_familiar($familiar[untamed turtle]))
				{
					use(1,$item[untamable turtle]);
				}
				else
				{
					autosell(1,$item[untamable turtle]);
				}
			}
			//if need to get a boat there
			if(contains_text(visit_url("questlog.php?which=1"),"assassins and found a map to the secret tropical island volcano lair"))
			{
				equip($slot[acc3], $item[pirate fledges]);
				set_property("choiceAdventure189", "3");
				cli_execute("conditions clear");
				cli_execute("condition add choiceadv");
				boolean done=false;
				while(my_adventures()>0 && !done)
				{
					done=adventure(request_noncombat(1), $location[Poop Deck]);
				}
				set_property("choiceAdventure189", "1");
				dress_for_fighting();
			}
			//do island
			if(my_adventures()>0)
			{
				if(my_class()==$class[pastamancer])
				{
					pisland();
				}
				else if(my_class()==$class[sauceror])
				{
					sisland();
				}
				else if(my_class()==$class[disco bandit])
				{
					disland();
				}
				else if(my_class()==$class[accordion thief])
				{
					aisland();
				}
				else if(my_class()==$class[turtle tamer])
				{
					tisland();
				}
				else
				{
					scisland();
				}
			}
		}
		else
		{
			print("nemesis part 2 not available, do other stuff until assassins","green");
		}
	}
	else
	{
		print("already done the nemesis quest part 2","green");
	}
}





void main()
{
	nemesisquest();
	nemesisquest2();
}
