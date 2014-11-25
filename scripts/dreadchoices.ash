//Perform all dreadsylvania choiceadventures via quicklinks

string polisher="twistedmage";
string brewer="twistedmage";
string keymaker="twistedmage";
string chef="twistedmage";
string chest_opener="twistedmage";
string grinder="anid";

//ash import dreadchoices.ash; clean_choices();
void clean_choices()
{
	int i=5;
	while(i<9)
	{
		set_property("_dreadchoice"+i,"false");
		i+=1;
	}
}

void do_choice(int loc, string choice, string choice2)
{
	if(get_property("_dreadchoice"+loc).to_boolean())
		return;
	string str=visit_url("clan_dreadsylvania.php?action=forceloc&loc=" + to_string(loc) );
	str=visit_url("choice.php?"+choice);
	str=visit_url("choice.php?"+choice2);
	set_property("_dreadchoice"+loc,"true");
}

void get_key()
{
	if(item_amount($item[dreadsylvanian skeleton key])<1)
		buy($coinmaster[The Terrified Eagle Inn], 1, $item[dreadsylvanian skeleton key]);
}

void send_stuff(item it, string person)
{
	if(my_name()!=person)
		cli_execute("csend * "+it+" to "+person);
}

boolean already_done(string action)
{
	return contains_text(visit_url("clan_raidlogs.php"),action);
}

void do_forest()
{
	//---------------cabin----------------
	print("Doing forest","blue");
	if(my_primestat()==$stat[muscle] && item_amount($item[old dry bone])>0 )
	{
		do_choice(1, "?pwd&whichchoice=721&option=1&choiceform1=Check+out+the+kitchen", "?pwd&whichchoice=722&option=2&choiceform2=Screw+around+with+the+flour+mill");
		send_stuff($item[bone flour],chef);
	}
	else if(!already_done("tarragon"))
	{
		do_choice(1, "?pwd&whichchoice=721&option=1&choiceform1=Check+out+the+kitchen", "?pwd&whichchoice=722&option=1&choiceform1=Raid+the+spice+rack");
		send_stuff($item[dread tarragon],chef);
	}
//	else if(item_amount($item[replica key])>0)
//	{
//		do_choice(1, "?pwd&whichchoice=721&option=2&choiceform2=Go+down+to+the+basement", "?pwd&whichchoice=723&option=3&choiceform3=Check+out+the+lockbox");
//	}
//	else if(my_class()==$class[accordion thief])
//	{
//		get_key();
//		do_choice(1, "?pwd&whichchoice=721&option=3&choiceform3=Try+the+attic", "?pwd&whichchoice=724&option=1&choiceform1=Turn+off+the+music+box");
//	}
	else if(!already_done("drove some vampires out"))
	{
		get_key();
		do_choice(1, "?pwd&whichchoice=721&option=3&choiceform3=Try+the+attic", "?pwd&whichchoice=724&option=3&choiceform3=Poke+around+in+the+rafters");
	}
	else if(item_amount($item[wax banana])>0)
	{
		do_choice(1, "?pwd&whichchoice=721&option=2&choiceform2=Go+down+to+the+basement", "?pwd&whichchoice=723&option=4&choiceform4=Stick+a+wax+banana+in+the+lock");
		send_stuff($item[complicated lock impression],keymaker);
	}	
	else //kruegerands
	{
		do_choice(1, "?pwd&whichchoice=721&option=2&choiceform2=Go+down+to+the+basement", "?pwd&whichchoice=723&option=1&choiceform1=Look+through+the+newspapers");
	}
	send_stuff($item[old dry bone],grinder);
		
	//---------------tallest tree----------------
	send_stuff($item[blood kiwi],brewer);
	if(my_primestat()==$stat[muscle] && !already_done("amber"))
	{
		do_choice(2, "?pwd&whichchoice=725&option=1&choiceform1=Climb+to+the+top", "?pwd&whichchoice=726&option=3&choiceform3=Grab+the+shiny+thing");
		send_stuff($item[moon-amber],polisher);
	}
/*	else if(my_primestat()==$stat[muscle] && !already_done("kiwi"))
	{
		if(!get_property("_dreadchoice2").to_boolean())
		{
			string str=visit_url("clan_dreadsylvania.php?action=forceloc&loc=2");
			str=visit_url("choice.php?pwd&whichchoice=725&option=1&choiceform1=Climb+to+the+top");
			if(!contains_text(str,"You are at the top of the tallest tree in the Dreadsylvanian Woods"))
				abort("Tried to get up to stomping branch but seems like we failed");
			set_property("_dreadchoice2","true");
			abort("Waiting to stomp");
		}
	}
	else if(!already_done("kiwi"))
	{
		if(!get_property("_dreadchoice2").to_boolean())
		{
			string str=visit_url("clan_dreadsylvania.php?action=forceloc&loc=2");
			str=visit_url("choice.php?pwd&whichchoice=725&option=3&choiceform3=Root+around+at+the+base");
			str=visit_url("choice.php?pwd&whichchoice=728&option=1&choiceform1=Stand+near+the+base+looking+upward");
			if(!contains_text(str,"You are standing at the base of a tall tall tree, staring upwards"))
				abort("Tried to wait at bottom of tree but seems we failed");
			set_property("_dreadchoice2","true");
			abort("Waiting to get stomped on");
		}
	}*/
	else
	{
		do_choice(2, "?pwd&whichchoice=725&option=3&choiceform3=Root+around+at+the+base", "?pwd&whichchoice=728&option=2&choiceform2=Stand+near+the+base+looking+downward");
	}
	
	//---------------burrows----------------
	do_choice(3,"?pwd&whichchoice=729&option=3&choiceform3=Go+toward+the+smelly", "?pwd&whichchoice=732&option=2&choiceform2=Dig+through+the+garbage");
}

void do_village()
{
	print("doing village","blue");
	//village square
	//get_key();
	//do_choice(4, "pwd&whichchoice=733&option=1&choiceform1=The+schoolhouse","pwd&whichchoice=734&option=2&choiceform2=Rummage+through+the+teacher%27s+desk");
	do_choice(4, "?pwd&whichchoice=733&option=2&choiceform2=The+blacksmith%27s+shop","?pwd&whichchoice=735&option=2&choiceform2=Dig+through+the+till");
	
	//skid row
	if(my_primestat()==$stat[moxie])
	{
		boolean polish=item_amount($item[moon-amber])>0;
		boolean replica_key=min(item_amount($item[complicated lock impression]), item_amount($item[intricate music box parts]))>0;
		if(polish && replica_key) //if we can do both, choose which we need more
		{
			int polished = available_amount($item[moon-amber necklace]) + available_amount($item[polished moon-amber]);
			int keys = available_amount($item[replica key]) + available_amount($item[dreadsylvania auditor's badge]);
			if(keys>polished)
				replica_key=false;
			else
				polish=false;
		}
		
		if(polish)
		{
			do_choice(5, "?pwd&whichchoice=737&option=3&choiceform3=Investigate+the+ticking+shack", "?pwd&whichchoice=739&option=3&choiceform3=Polish+the+moon-amber");
			cli_execute("inventory refresh; make moon amber necklace");
		}
		else if(replica_key)
		{
			do_choice(5, "?pwd&whichchoice=737&option=3&choiceform3=Investigate+the+ticking+shack", "?pwd&whichchoice=739&option=2&choiceform2=Make+a+key+using+the+wax+lock+impression");
			send_stuff($item[replica key],chest_opener);
		}
		else
		{
			do_choice(5, "?pwd&whichchoice=737&option=3&choiceform3=Investigate+the+ticking+shack", "?pwd&whichchoice=739&option=1&choiceform1=Rummage+through+the+shelves");
		}
	}
	else
	{
		do_choice(5, "?pwd&whichchoice=737&option=1&choiceform1=Pop+into+the+sewers", "?pwd&whichchoice=738&option=2&choiceform2=Slosh+in+the+muck");
	}
	
	if(my_name()!="twistedmage")
		cli_execute("csend * ghost thread to twistedmage");
	cli_execute("inventory refresh");
	//duke
/*	if(my_primestat()==$stat[mysticality] && item_amount($item[dread tarragon])>0 && item_amount($item[dreadful roast])>0 && item_amount($item[stinking agaricus])>0 && item_amount($item[bone flour])>0)
	{
		do_choice(6, "?pwd&whichchoice=741&option=2&choiceform2=Investigate+the+servant%27s+quarters", "?pwd&whichchoice=743&option=2&choiceform2=Make+a+shepherd%27s+pie");
	}
	else */if(item_amount($item[ghost thread])>9)
	{
		get_key();
		do_choice(6, "?pwd&whichchoice=741&option=3&choiceform3=Make+your+way+to+the+master+suite", "?pwd&whichchoice=744&option=3&choiceform3=Mess+with+the+loom");
	}
//	else if(!already_done("drove some zombies out of the village")) //reduce zombies
//	{
//		do_choice(6, "?pwd&whichchoice=741&option=1&choiceform1=Check+out+the+family+plot", "?pwd&whichchoice=742&option=1&choiceform1=Close+the+gates");
//	}
	else if(!already_done("mort"))
	{
		get_key();
		do_choice(6, "?pwd&whichchoice=741&option=3&choiceform3=Make+your+way+to+the+master+suite", "?pwd&whichchoice=744&option=2&choiceform2=Check+the+nightstand");
		send_stuff($item[eau de mort],brewer);
	}
	else
	{
		do_choice(6, "pwd&whichchoice=741&option=1&choiceform1=Check+out+the+family+plot", "pwd&whichchoice=742&option=2&choiceform2=Rob+some+graves");
	}
}

void do_castle()
{
	print("doing castle","blue");
	send_stuff($item[dreadful roast],chef);
	//great hall
	if(item_amount($item[muddy skirt])>0 && item_amount($item[dreadsylvanian seed pod])>0 && my_basestat($stat[moxie])>=200)
	{
		item prev_pants= equipped_item($slot[pants]);
		equip($item[muddy skirt]);
		get_key();
		do_choice(7, "?pwd&whichchoice=745&option=1&choiceform1=Head+to+the+ballroom", "?pwd&whichchoice=746&option=2&choiceform2=Trip+the+light+fantastic");
		equip(prev_pants);
	}
	else if(my_primestat()==$stat[mysticality])
	{
		do_choice(7, "?pwd&whichchoice=745&option=3&choiceform3=Investigate+the+dining+room", "?pwd&whichchoice=748&option=3&choiceform3=Levitate+up+to+the+rafters");
	}
	else if(!already_done("drove some vampires out of the castle")) //reduce zombies
	{
		get_key();
		do_choice(7, "?pwd&whichchoice=745&option=1", "?pwd&whichchoice=746&option=1");
	}
	else if(!already_done("roast"))
	{
		do_choice(7, "?pwd&whichchoice=745&option=3&choiceform3=Investigate+the+dining+room", "?pwd&whichchoice=748&option=1&choiceform1=Grab+the+roast");
	}
	else //stay frosty
	{
		do_choice(7, "?pwd&whichchoice=745&option=2&choiceform2=Check+out+the+kitchen", "?pwd&whichchoice=747&option=2&choiceform2=Hang+out+in+the+freezer");
	}
	
	//dungeons
	if(!already_done("agaric"))
	{
		do_choice(9, "?pwd&whichchoice=753&option=3&choiceform3=Check+out+the+guardroom", "?pwd&whichchoice=756&option=1&choiceform1=Break+off+some+choice+bits");
		send_stuff($item[stinking agaricus],chef);
	}
	else
	{
		do_choice(9, "?pwd&whichchoice=753&option=2&choiceform2=Head+for+the+boiler+room", "?pwd&whichchoice=755&option=2&choiceform2=Check+in+the+incinerator");
	}
	
	//tower
/*	if(my_primestat()==$stat[moxie] && item_amount($item[blood kiwi])>0 && item_amount($item[eau de mort])>0)
	{
		get_key();
		do_choice(8, "?pwd&whichchoice=749&option=1&choiceform1=Go+to+the+laboratory", "?pwd&whichchoice=750&option=4&choiceform4=Use+the+still");
	}
	else
	{*/
		//abort("skills");
		do_choice(8, "?pwd&whichchoice=749&option=3&choiceform3=Go+to+the+bedroom", "?pwd&whichchoice=752&option=2&choiceform2=Check+the+dresser");
//	}
}

void main()
{
	if(my_hp()==0)
		cli_execute("restore hp");
	do_forest();
	do_village();
	do_castle();
}