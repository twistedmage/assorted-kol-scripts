//start off the day with:
// init: pick a fight (frat arena) - 50 - (20 adv, once per day) 
// init: pool stylishly - 50 - (10 adv, 3 times per day) 
// init: potion of fishy speed - 50 - (20 adv, once ever)
// ML: mad tea party wearing pail- 20 - (once per day)
//use yendorian card


void burn_mp()
{
	int excess=my_mp()-(0.3*to_float( my_maxhp())); //try to leave 30% mp
	if(excess>0)
		cli_execute("burn "+ excess +" mp");
}

void recover_stuff()
{
	if((to_float(my_hp())/to_float( my_maxhp()))<0.2)
		cli_execute("recover hp");
	if((to_float(my_mp())/to_float( my_maxmp()))<0.2)
		cli_execute("recover mp");
}

void refresh_item_effect(effect in_effect, item in_item, int needed_turns)
{
	int prev_turns=have_effect(in_effect);
	while(prev_turns<needed_turns)
	{
		use(1,in_item);
		int new_turns=have_effect(in_effect);
		if(new_turns<=prev_turns)
			abort("After using item "+in_item+" turns of "+in_effect+" went from "+prev_turns+" to "+new_turns);
		prev_turns=new_turns;
	}
}

void refresh_item_effect(effect in_effect, item in_item)
{
	refresh_item_effect(in_effect, in_item, 1);
}


void refresh_skill_effect(effect in_effect, skill in_skill, int needed_turns)
{
	int prev_turns=have_effect(in_effect);
	while(prev_turns<needed_turns)
	{
		use_skill(in_skill);
		int new_turns=have_effect(in_effect);
		if(new_turns<=prev_turns)
			abort("After using skill "+in_skill+" turns of "+in_effect+" went from "+prev_turns+" to "+new_turns);
		prev_turns=new_turns;
	}
}

void refresh_skill_effect(effect in_effect, skill in_skill)
{
	refresh_skill_effect(in_effect, in_skill, 1);
}

void main()
{
	//ensure hand, and equip with old school mafia knick...
	use_familiar($familiar[disembodied hand]);
	cli_execute("maximize ml, equip mirrored aviator shade, equip leather aviator's cap");
	
	while(my_adventures()>0)
	{

		recover_stuff();
		
		//ml effects
		refresh_skill_effect($effect[Ur-Kel's Aria of Annoyance], $skill[Ur-Kel's Aria of Annoyance]);
		refresh_item_effect($effect[mysteriously handsome], $item[handsomeness potion]);
		refresh_item_effect($effect[the cupcake of wrath], $item[green-frosted astral cupcake]);
		refresh_item_effect($effect[Contemptible Emanations], $item[cologne of contempt]);
		refresh_item_effect($effect[The Great Tit's Blessing], $item[glimmering great tit feather]);
		refresh_item_effect($effect[juiced and jacked], $item[pumpkin juice]);
		refresh_item_effect($effect[Eau D'enmity], $item[perfume of prejudice]);

		//go to defend valhala
		visit_url("invasion.php?action=5");
		visit_url("choice.php?pwd&whichchoice=534&option=3&choiceform3=Land+in+a+docking+bay"); //ml choice
		
	}
}