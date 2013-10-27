void open_choiceadv()
{
	//open choiceadv
	string dump=visit_url("town.php?action=trickortreat");
}

void do_block()
{
	open_choiceadv();
	int i=0;
	while(i<12)
	{
		print("Exploring house "+i,"blue");
		string txt =visit_url("choice.php?whichchoice=804&option=3&whichhouse="+i);
		if(contains_text(txt,"Steve"))
		{
			abort("Fight boss!");
		}
		else if(contains_text(txt,"bowl of candy"))
		{
			print("Got a bowl of candy!","blue");
			string dump=visit_url("choice.php?pwd&whichchoice=806&option=2&choiceform2=Resist+the+temptation");
			open_choiceadv();
		}
		else if(contains_text(txt,"You're fighting"))
		{
			print("Fighting!","blue");
			txt=run_combat();
			if(!contains_text(txt,"WINWINWIN"))
				abort("Got beaten up!");
			cli_execute("mood execute; restore hp; restore mp");
			open_choiceadv();
		}
		i+=1;
	}
	
}

void open_new_block()
{
	if(my_adventures()>=5)
	{
		print("opening a new block","blue");
		visit_url("choice.php?whichchoice=804&pwd&option=1");
	}
	else
		abort("not enough turns to open new block");
}

void trick_or_treat()
{
	//cancel if previously stuck in choiceadv
	string dump=visit_url("main.php");
	//dress up
	if(have_outfit("clothing of loathing"))
		outfit("clothing of loathing");
	else if(have_outfit("dreadful skeleton outfit"))
		outfit("dreadful skeleton outfit");
	else if(have_outfit("swashbuckling getup"))
		outfit("swashbuckling getup");
	else
		abort("Couldn't decide on an outfit");
	
	while(true)
	{
		do_block();
		open_new_block();
	}
}

void main()
{
	trick_or_treat();
}