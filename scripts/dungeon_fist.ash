void fight()
{
	//begin fight
	string result=visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Fight%21");
	while(contains_text(result,"value=\"Attack!\">"))
	{
		result=visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Attack%21");
	}

}

void play_dungeon_fist()
{
	//start game
	visit_url("arcade.php?action=game&whichgame=3&pwd");
	//west
	visit_url("choice.php?pwd&whichchoice=486&option=3&choiceform3=Go+West");
	//fight
	fight();
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+South");
	//fight
	fight();
	//east
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+East");
	//west
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+West");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//east
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+East");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//fight
	fight();
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//fight
	fight();
	//east
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+East");
	//east
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+East");
	//fight
	fight();
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+South");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//west
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+West");
	//west
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+West");
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+South");
	//east
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+East");
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+South");
	//fight
	fight();
	//east
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+East");
	//fight
	fight();
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+South");
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Go+South");
	//use potion
	visit_url("choice.php?pwd&whichchoice=486&option=2&choiceform2=Use+Potion");
	//<KEY!!!>
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//west
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+West");
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=3&choiceform3=Go+South");
	//south
	visit_url("choice.php?pwd&whichchoice=486&option=3&choiceform3=Go+South");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//west
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+West");
	//north
	visit_url("choice.php?pwd&whichchoice=486&option=1&choiceform1=Go+North");
	//west
	visit_url("choice.php?pwd&whichchoice=486&option=3&choiceform3=Go+West");
}

void main()
{
	cli_execute("maximize mp regen min, mp regen max");
	while(my_adventures()>5 && item_amount($item[game grid token])>0)
	{
		if(item_amount($item[game grid ticket])>4999)
		{
			abort("Enough tokens to buy boom-box");
		}
		cli_execute("burn *");
		play_dungeon_fist();
	}
	cli_execute("alt_farm");
	cli_execute("awake");
}