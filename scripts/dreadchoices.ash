//Perform all dreadsylvania choiceadventures via quicklinks

void do_choice(int loc, string choice, string choice2)
{
	string str=visit_url("clan_dreadsylvania.php?action=forceloc&loc=" + to_string(loc) );
	str=visit_url("choice.php?"+choice);
	str=visit_url("choice.php?"+choice2);
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
		abort("unknown choiceadvs for bone floure line 16");
		//do_choice(1, choice1a, choice1b);
		send_stuff($item[bone flour],"twistedmage");
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
		send_stuff($item[complicated lock impression],"dinala");
	}
	else if(!already_done("tarragon"))
	{
		abort("unknown choiceadvs for dread tarragon line 25");
		//do_choice(1, choice1a, choice1b);
		send_stuff($item[dread tarragon],"twistedmage");
	}
	else
		abort("Don't know what to do for cabin");
		
	//---------------tallest tree----------------
	if(my_primestat()==$stat[muscle] && !already_done("amber"))
	{
		abort("unknown choiceadvs for moon amber line 32");
		//do_choice(2, choice1a, choice1b);
		send_stuff($item[moon-amber],"twistedmage");
	}
	else if(my_primestat()==$stat[muscle])
	{
		abort("unknown choiceadvs for branch stomping line 35");
		//do_choice(2, choice1a, choice1b);
	}
	else if(!already_done("stomp"))
	{
		abort("unknown choiceadvs for looking up line 38");
		//do_choice(2, "pwd&whichchoice=725&option=3&choiceform3=Root+around+at+the+base", );
		send_stuff($item[blood kiwi],"asica");
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
	//village square
	//get_key();
	//do_choice(4, "pwd&whichchoice=733&option=1&choiceform1=The+schoolhouse","pwd&whichchoice=734&option=2&choiceform2=Rummage+through+the+teacher%27s+desk");
	abort("line 87 freddies");
	do_choice(4, "","");
	
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
			abort("line 106 choices for freddies");
			do_choice(5, "pwd&whichchoice=737&option=3&choiceform3=Investigate+the+ticking+shack", "pwd&whichchoice=739&option=1&choiceform1=Rummage+through+the+shelves");
		}
	}
	else
	{
		abort("line 101 choices for sewer drenched");
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
		do_choice(6, "", "");
	}
	else if(!already_done("gates")) //reduce zombies
	{
		abort("line 137 choice for closing the gates");
		do_choice(6, "", "");
	}
	else if(!already_done("mort"))
	{
		abort("line 131 choices for eau de mort");
		do_choice(6, "", "");
	}
	else
	{
		do_choice(6, "pwd&whichchoice=741&option=1&choiceform1=Check+out+the+family+plot", "pwd&whichchoice=742&option=2&choiceform2=Rob+some+graves");
	}
}

void do_castle()
{
	//great hall
	if(item_amount($item[muddy skirt])>0 && item_amount($item[dreadsylvanian seed pod])>0)
	{
		equip($item[muddy skirt]);
		get_key();
		do_choice(7, "pwd&whichchoice=745&option=1&choiceform1=Head+to+the+ballroom", "pwd&whichchoice=746&option=2&choiceform2=Trip+the+light+fantastic");
		cli_execute("outfit dread");
	}
	else if(my_primestat()==$stat[mysticality])
	{
		abort("line 106 choices for wax banana");
		do_choice(7, "", "");
	}
	else if(!already_done("roast"))
	{
		abort("line 111 choices for dread roas");
		do_choice(7, "", "");
	}
	
	//tower
	if(my_primestat()==$stat[moxie] && item_amount($item[blood kiwi])>0 && item_amount($item[eau de mort])>0)
	{
		abort("line 119 use still");
		do_choice(8, "", "");
	}
	else
	{
		do_choice(8, "pwd&whichchoice=749&option=3&choiceform3=Go+to+the+bedroom", "pwd&whichchoice=752&option=2&choiceform2=Check+the+dresser");
	}
	
	//dungeons
	if(!already_done("agaricus"))
	{
		abort("line 155 choices for agaricus");
		do_choice(9, "", "");
		send_stuff($item[stinking agaricus],"twistedmage");
	}
	else
	{
		do_choice(9, "pwd&whichchoice=753&option=2&choiceform2=Head+for+the+boiler+room", "pwd&whichchoice=755&option=2&choiceform2=Check+in+the+incinerator");
	}
}

void main()
{
	do_forest();
	do_village();
	do_castle();
}