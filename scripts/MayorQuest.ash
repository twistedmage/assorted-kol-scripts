import <FunctionLib.ash>;
import <questLib.ash>;
## Script created by Zammywarrior(#644117) [KoL name] Hippymon [KoLmafia forum name].
## This script is designd to complete the Spooky Gravy Barrow 
## quest for you. Questions? Comments? Please K-mail them to ZammyWarrior via KoL.

familiar StarterFam = my_familiar();
boolean mayor(string checkme){
	return contains_text(visit_url("knoll.php?place=mayor"), checkme);
}
void Tame_The_Bears(){
	dress_for_fighting();
	cli_execute("conditions clear");
	add_item_condition(1, $item[annoying pitchfork]);
	boolean catch=adventure(my_adventures(), $location[bugbear pens]);
	visit_url("knoll.php?place=mayor");
}
void Mushroom(){
	dress_for_fighting();
	familiar FrozenFairy = $familiar[frozen gravy fairy];
	familiar FlamingFairy = $familiar[flaming gravy fairy];
	familiar StinkyFairy = $familiar[stinky gravy fairy];
	familiar SleazyFairy = $familiar[sleazy gravy fairy];
	familiar SpookyFairy = $familiar[spooky gravy fairy];
	if(mayor("bring me a frozen mushroom") || mayor("need a frozen mushroom")){
		retrieve_item(1, $item[frozen mushroom]);
		visit_url("knoll.php?place=mayor");
	}
	else if(mayor("bring me a flaming mushroom") || mayor("need a flaming mushroom")){
		retrieve_item(1, $item[flaming mushroom]);
		visit_url("knoll.php?place=mayor");
	}
	else if(mayor("bring me a stinky mushroom") || mayor("need a stinky mushroom")){
		retrieve_item(1, $item[stinky mushroom]);
		visit_url("knoll.php?place=mayor");
	}
	if(got_item($item[pregnant frozen mushroom]))
		use(1, $item[pregnant frozen mushroom]);
	if(got_item($item[pregnant flaming mushroom]))
		use(1, $item[pregnant flaming mushroom]);
	if(got_item($item[pregnant stinky mushroom]))
		use(1, $item[pregnant stinky mushroom]);
	refresh_status();
	if(!checkfam(FrozenFairy))
		if(!checkfam(FlamingFairy))
			if(!checkfam(StinkyFairy))
				if(!checkfam(SpookyFairy))
					if(!checkfam(SleazyFairy))
						abort("Familiar problem!!");
}
void Felonia(){
	dress_for_fighting();
	cli_execute("set choiceAdventure5 = 2"); 
	if(!got_item($item[inexplicably glowing rock])){
		cli_execute("conditions clear");
		add_item_condition(1, $item[inexplicably glowing rock]);
		boolean catch=adventure(my_adventures(), $location[Spooky Gravy Barrow]);
	}
	if(!got_item($item[spooky glove])){
		if(!got_item($item[spooky fairy gravy])){
			cli_execute("conditions clear");
			add_item_condition(1, $item[spooky fairy gravy]);
			boolean catch=adventure(my_adventures(), $location[Spooky Gravy Barrow]);
		}
		if(!got_item($item[small leather glove])){
			cli_execute("conditions clear");
			add_item_condition(1, $item[small leather glove]);
			boolean catch=adventure(my_adventures(), $location[Spooky Gravy Barrow]);
		}
		if(creatable_amount($item[spooky glove]) > 0)
			create(1, $item[spooky glove]);
	}
	if(!got_item($item[spooky glove]))
		abort("Spooky glove problem.");
	equip($item[spooky glove]);
	cli_execute("set choiceAdventure5 = 1"); 
	cli_execute("set choiceAdventure7 = 1"); 
	cli_execute("conditions clear");
	cli_execute("condition add spooky cosmetics bag");
	boolean catch=adventure(my_adventures(), $location[Spooky Gravy Barrow]);
}
void main(){
	if(!in_muscle_sign())
	{
		print("Not in muscle sign!");
		return;
	}
	if(mayor("newest citizen") || mayor("bugbears' annoyance"))
		Tame_The_Bears();
	if(available_amount($item[hobo code binder])!=0)
	{	
		while(!contains_text(visit_url("questlog.php?which=5"),"The Bugbear Pen")&& my_adventures()>0 && in_muscle_sign())
		{
			cli_execute("maximize moxie, equip hobo code binder");
			adventure(1,$location[Bugbear Pens]);
		}	
	}
	refresh_status();
	if(can_interact() && my_adventures()>0)
		Mushroom();
	if(mayor("stop the spooky gravy fairies") && my_adventures()>0)
		Felonia();
}