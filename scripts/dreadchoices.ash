//Perform all dreadsylvania choiceadventures via quicklinks

string polisher="twistedmage";
string brewer="twistedmage";
string keymaker="twistedmage";
string chef="dinala";


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
	if(my_class()==$class[accordion thief])
	{
		get_key();
		do_choice(1, "pwd&whichchoice=721&option=3&choiceform3=Try+the+attic", "pwd&whichchoice=724&option=1&choiceform1=Turn+off+the+music+box");
	}
	else if(my_primestat()==$stat[muscle] && item_amount($item[old dry bone])>0 )
	{
		do_choice(1, "?pwd&whichchoice=721&option=1&choiceform1=Check+out+the+kitchen", "choice.php?pwd&whichchoice=722&option=2&choiceform2=Screw+around+with+the+flour+mill");
		send_stuff($item[bone flour],chef);
	}
	else if(item_amount($item[replica key])>0)
	{
		abort("unknown choiceadvs for auditors badge line 19");
		//do_choice(1, choice1a, choice1b);
		send_stuff($item[dreadsylvania auditor's badge],"twistedmage");
	}
	else if(item_amount($item[wax banana])>0)
	{
		abort("unknown choiceadvs for lock impression line 22");
		//do_choice(1, choice1a, choice1b);
		send_stuff($item[complicated lock impression],keymaker);
	}
	else if(!already_done("tarragon"))
	{
		do_choice(1, "pwd&whichchoice=721&option=1&choiceform1=Check+out+the+kitchen", "choice.php?pwd&whichchoice=722&option=1&choiceform1=Raid+the+spice+rack");
		send_stuff($item[dread tarragon],chef);
	}
//	else
//		abort("Don't know what to do for cabin");
		
	//---------------tallest tree----------------
	send_stuff($item[blood kiwi],brewer);
	if(my_primestat()==$stat[muscle] && !already_done("amber"))
	{
		abort("unknown choiceadvs for moon amber line 32");
		//do_choice(2, choice1a, choice1b);
		send_stuff($item[moon-amber],polisher);
	}
	else if(my_primestat()==$stat[muscle] && !already_done("kiwi"))
	{
		if(!get_property("_dreadchoice2").to_boolean())
		{
			string str=visit_url("clan_dreadsylvania.php?action=forceloc&loc=2");
			str=visit_url("choice.php?pwd&whichchoice=725&option=1&choiceform1=Climb+to+the+top");
			set_property("_dreadchoice2","true");
			abort("Waiting to stomp");
		}
	}
	else if(!already_done("kiwi"))
	{
		if(!get_property("_dreadchoice2").to_boolean())
		{
			do_choice(2, "choice.php?pwd&whichchoice=725&option=3&choiceform3=Root+around+at+the+base","?pwd&whichchoice=728&option=1&choiceform1=Stand+near+the+base+looking+upward");
			abort("Waiting to get stomped on");
		}
	}
	else
	{
		do_choice(2, "pwd&whichchoice=725&option=3&choiceform3=Root+around+at+the+base", "pwd&whichchoice=728&option=2&choiceform2=Stand+near+the+base+looking+downward");
	}
	
	//---------------burrows----------------
	do_choice(3,"pwd&whichchoice=729&option=3&choiceform3=Go+toward+the+smelly", "pwd&whichchoice=732&option=2&choiceform2=Dig+through+the+garbage");
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
		if(item_amount($item[moon-amber])>0)
		{
			abort("choices for polishing");
			do_choice(5, "pwd&whichchoice=737&option=3&choiceform3=Investigate+the+ticking+shack", "");
		}
		else if(item_amount($item[complicated lock impression])>0 && item_amount($item[intricate music box parts])>0)
		{
			abort("line 100 choices for replica key");
			do_choice(5, "pwd&whichchoice=737&option=3&choiceform3=Investigate+the+ticking+shack", "");
			send_stuff($item[replica key],"twistedmage");
		}
		else
		{
			do_choice(5, "pwd&whichchoice=737&option=3&choiceform3=Investigate+the+ticking+shack", "pwd&whichchoice=739&option=1&choiceform1=Rummage+through+the+shelves");
		}
	}
	else
	{
		do_choice(5, "pwd&whichchoice=737&option=1&choiceform1=Pop+into+the+sewers", "pwd&whichchoice=738&option=2&choiceform2=Slosh+in+the+muck");
	}
	
	//duke
	if(my_primestat()==$stat[mysticality] && item_amount($item[dread tarragon])>0 && item_amount($item[dreadful roast])>0 && item_amount($item[stinking agaricus])>0 && item_amount($item[bone flour])>0)
	{
		abort("line 120 choices for cooking shepherds pie");
		do_choice(6, "", "");
	}
	else if(item_amount($item[ghost thread])>9)
	{
		get_key();
		abort("line 126 choices for making ghost shawl");
		do_choice(6, "pwd&whichchoice=741&option=3&choiceform3=Make+your+way+to+the+master+suite", "");
	}
	else if(!already_done("drove some zombies out of the village")) //reduce zombies
	{
		abort("line 137 choice for closing the gates");
		do_choice(6, "", "");
	}
	else if(!already_done("mort"))
	{
		get_key();
		do_choice(6, "?pwd&whichchoice=741&option=3&choiceform3=Make+your+way+to+the+master+suite", "?pwd&whichchoice=744&option=2&choiceform2=Check+the+nightstand");
	}
	else
	{
		do_choice(6, "pwd&whichchoice=741&option=1&choiceform1=Check+out+the+family+plot", "pwd&whichchoice=742&option=2&choiceform2=Rob+some+graves");
	}
}

void do_castle()
{
	print("doing castle","blue");
	//great hall
	if(item_amount($item[muddy skirt])>0 && item_amount($item[dreadsylvanian seed pod])>0 && my_basestat($stat[moxie])>=200)
	{
		equip($item[muddy skirt]);
		get_key();
		do_choice(7, "pwd&whichchoice=745&option=1&choiceform1=Head+to+the+ballroom", "pwd&whichchoice=746&option=2&choiceform2=Trip+the+light+fantastic");
		cli_execute("outfit dread");
	}
	else if(my_primestat()==$stat[mysticality])
	{
		do_choice(7, "?pwd&whichchoice=745&option=3&choiceform3=Investigate+the+dining+room", "?pwd&whichchoice=748&option=3&choiceform3=Levitate+up+to+the+rafters");
	}
	else if(!already_done("roast"))
	{
		abort("line 111 choices for dread roas");
		do_choice(7, "", "");
	}
	
	//dungeons
	if(!already_done("agaric"))
	{
		do_choice(9, "?pwd&whichchoice=753&option=3&choiceform3=Check+out+the+guardroom", "?pwd&whichchoice=756&option=1&choiceform1=Break+off+some+choice+bits");
		send_stuff($item[stinking agaricus],chef);
	}
	else
	{
		do_choice(9, "pwd&whichchoice=753&option=2&choiceform2=Head+for+the+boiler+room", "pwd&whichchoice=755&option=2&choiceform2=Check+in+the+incinerator");
	}
	
	//tower
	if(my_primestat()==$stat[moxie] && item_amount($item[blood kiwi])>0 && item_amount($item[eau de mort])>0)
	{
		abort("line 119 use still");
		do_choice(8, "", "");
	}
	else
	{
		//abort("skills");
		do_choice(8, "pwd&whichchoice=749&option=3&choiceform3=Go+to+the+bedroom", "pwd&whichchoice=752&option=2&choiceform2=Check+the+dresser");
	}
}

void main()
{
	do_forest();
	do_village();
	do_castle();
}