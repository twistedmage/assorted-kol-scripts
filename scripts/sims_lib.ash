import <nscomb.ash>

void none_fam(int combat)
{
		if(combat>0)
			print("................. best fam: hound dog, for combat rate.","green");

		print("................. ------------------ stat fams ----------------","green");
		
		if(my_path() != "Bees hate you")
		{
			if(available_amount($item[aquaviolet jub-jub bird])>0  || available_amount($item[charpuce jub-jub bird])>0 || available_amount($item[crimsilion jub-jub bird])>0)
				print("................. best fam: tuned bandersnatch. Improves combat skills.","green");
			else
				print("................. best fam: bugged bugbear if you can handle ML (acts as potato).","green");
				
			if(my_level()>=9) //assume that ML is over 85 at level 9 and above, which is true without buffs
			{
				print("................. alternative: baby sandworm. Also drops spleen.","green");
			}
			else
			{
				print("................. alternative: untuned bandersnatch. Improves combat skills.","green");
				//spirit hobo gives mp + volleyball
				print("................. alternative: spirity hobo. Recharges MP for booze.","green");
			}
		}
		print("................. alternative: gluttonous green ghost. Recharges MP for food.","green");
		print("................. alternative: hobo spirit. Recharges MP for booze.","green");
		print("................. alternative: xenomorph. Drops transponders.","green");
		print("................. alternative: nervous tick. Increases meat.","green");
		//gluttonous green ghost gives mp + volleyball
		
		print("................. ------------------ drop fams ----------------","green");
		print("................. llama lama, gives nice spleen if you fight with bird skills.","green");
		print("................. pair of stomping boots, nearly as good and simpler spleen","green");	
		print("................. rogue program, gives worse spleen as free drop (+mp).","green");
		if(my_path() != "Bees hate you")
		{
			print("................. baby sandworm, gives worse spleen as free drop (+stats).","green");
			print("................. green pixie. gives nice spleen but requires wasted turns. also can give power leveling later.","green");
		}
		print("................. stocking mimic. Gives stats or item+meat buff items. (Also gives meat and mp.)","green");
}

void runaway_fam(int combat)
{
		//only if not all used
		int max_weight=max(familiar_weight($familiar[frumious bandersnatch]),familiar_weight($familiar[pair of stomping boots]));
		if(available_amount($item[sugar sheet])>0 || available_amount($item[sugar shield])>0 || get_property("tomeSummons").to_int()<3)
			max_weight=max_weight+10; //sugar shield
		if(have_skill($skill[leash of linguini]))
			max_weight=max_weight+5; //leash
		if(have_skill($skill[empathy of the newt]))
			max_weight=max_weight+5; //empathy
		if(have_skill($skill[amphibian sympathy]))
			max_weight=max_weight+5; //sympathy
		if(get_property("_poolGames").to_int() < 3)
			max_weight=max_weight+5; //pool table
		if(available_amount($item[green candy heart])>0)
			max_weight=max_weight+3; //green candy heart
		if(have_outfit("knob goblin elite guard") && available_amount($item[cobb's knob lab key])>0)
			max_weight=max_weight+5; //pet buffing spray
		if(get_property("sidequestArenaCompleted") == "fratboy")
			max_weight=max_weight+5; //island arena
		
		int max_runaways=floor(max_weight/5);
		
		if(my_path() != "Bees hate you" && get_property("_banderRunaways").to_int() < max_runaways)
		{
			print("................. pair of stomping boots","green");
			print("................. bandernatch (needs ode)","green");
		}
		else
		{
			none_fam(combat);
		}
}

void delay_fam(int combat)
{
	if(get_property("_Mini-HipsterAdv").to_int() < 7)
	{
		print("................. Mini-Hipster","green");
	}
	else
	{
		runaway_fam(combat);
	}
}

//global to be filled in helper, with clancys current instrument
item clancy_instrument=$item[none];

//combat param is +ve for increasing combat encounter rate, -ve for increasing noncomabt rate, and 0 for don't care
//possible goals items,meat,runaways,delay,combat,none
void suggest_fam(string main_goal, int combat)
{
	if(my_path()=="Avatar of Boris")
	{
		if(main_goal=="items")
		{
			if(available_amount($item[Bag o' Tricks])>0)
			{
				print("-(summon weasels from Bag o' Tricks with 2 charges)","green");
			}
			if(available_amount($item[greatest american pants])>0)
				print("(use super vision buff from GAP)","green");
			if(available_amount($item[clancy's lute])>0)
				print("................. give clancy the lute","green");
		}
		else if(available_amount($item[clancy's crumhorn])>0)
		{
			print("................. give clancy the crumhorn","green");
		}
		else if(main_goal=="meat")
		{
			if(available_amount($item[Bag o' Tricks])>0)
			{
				print("-(summon badgers from Bag o' Tricks with 1 charges)","green");
			}
		}
		return;
	}

	if(main_goal=="items")
	{
		if(available_amount($item[Bag o' Tricks])>0)
		{
			print("-(summon weasels from Bag o' Tricks with 2 charges)","green");
		}
		if(available_amount($item[crown of thrones])>0)
			print("(feral kobold in crown)","green");
		if(available_amount($item[greatest american pants])>0)
			print("(use super vision buff from GAP)","green");
		if(available_amount($item[spangly sombrero])>0 && combat<=0)
		{
			print("................. best fam: hatrack + spangly sombrero","green");
		}
		else if(combat>=0)
		{
			print("................. best fam: hound dog","green");
		}
		
		print("................. alternative: slimeling. pickpocket equippables and give mp","green");
		if(my_path() != "Bees hate you")
		{
			print("................. pair of stomping boots. charges spleen stomps.","green");
			print("................. alternative: green pixie. power level drops","green");
		}
		if(available_amount($item[Tiny top hat and cane])>0)
			print("................. alternative: xenomorph. volley stats","green");
	}
	else if(main_goal=="meat")
	{
		if(available_amount($item[Bag o' Tricks])>0)
		{
			print("-(summon badgers from Bag o' Tricks with 1 charges)","green");
		}
		if(available_amount($item[crown of thrones])>0)
			print("(put hobo monkey / organ grinder in crown)","green");
		if(available_amount($item[sugar chapeau])>0 || available_amount($item[sugar sheet])>0)
			print("................. Best fam: hatrack + sugar chapeau, gives stats","green");

		print("................. Best fam: hobo monkey. makes food.","green");
		print("................. alternative: organ grinder. makes food.","green");
	}
	else if(main_goal=="runaways") //runaways should be used for superlikelies, (delay?), rare noncombats or rare mobs
	{
		runaway_fam(combat);
	}
	else if(main_goal=="delay") //Mini-Hipster should be used primarily in delay zones, but also in superlikely zones (not for standard combat/noncomats)
	{
		delay_fam(combat);
	}
	else if(main_goal=="combat")
	{
		string hat;
		int weight;
		if(available_amount($item[spangly sombrero])>1)
		{
			hat="spangly sombrero";
			weight=3*min(37,(familiar_weight($familiar[mad hatrack]) + weight_adjustment()));
		}
		else if(available_amount($item[mullet wig])>1)
		{
			hat="mullet wig";
			weight=2*min(10,(familiar_weight($familiar[mad hatrack]) + weight_adjustment()));
		}
		else
		{
			hat="maiden wig";
			weight=2*min(8,(familiar_weight($familiar[mad hatrack]) + weight_adjustment()));
		}
		
		print("................. Mad hatrack + "+hat+" = "+weight+" weight potato.","green");
		if(my_path()!="Bees hate you")
		{
			print("................. Baby Bugged bugbear is "+(familiar_weight($familiar[baby bugged bugbear]) + weight_adjustment())+" weight potato, but adds 20 ML.","green");
			print("................. Frumious Bandersnatch. Improves skills.","green");
			print("................. organ grinder. Doesn't help, but might make a badass pie?","green");
		}
		weight=familiar_weight($familiar[Mini-Hipster]) + weight_adjustment();
		float action = to_float(weight)*2.5;
		action=action+25.0;
		print("................. Mini-Hipster acts "+action+" percent of the time (split between blocking, healing, meat and damage).","green");
	}
	else if(main_goal=="none")
	{
		none_fam(combat);
	}
	else
	{
		abort("................. unrecognised goal \""+main_goal+"\"");
	}
}

string visit_url_non_abort(string url)
{
	string output;
	try
	{
		output=visit_url(url);
	}
	finally
	{
		return output;
	}
	return output;
}


void train_moxie_skills()
{
	visit_url("gnomes.php?action=trainskill&whichskill=10");
	visit_url("gnomes.php?action=trainskill&whichskill=11");
	visit_url("gnomes.php?action=trainskill&whichskill=12");
	visit_url("gnomes.php?action=trainskill&whichskill=13");
	visit_url("gnomes.php?action=trainskill&whichskill=14");
}

void meatmail(string person, int send_meat)
{
	if(my_meat() > send_meat)
	{
		print("sending "+send_meat+" to "+person,"blue");
		visit_url("sendmessage.php?toid=&action=send&towho="+person+"&contact=0&message=&howmany1=1&whichitem1=0&sendmeat="+send_meat+"&messagesend=Send+Message.&pwd");
	}
	else
	{
		print("Don't have enough meat","red");
	}
}

boolean have_buff_equip()
{
	boolean have=true;
	//need accordion
	if(have_skill($skill[The Polka of Plenty]) || have_skill($skill[Fat Leon's Phat Loot Lyric]) || have_skill($skill[The Ode to Booze]) || have_skill($skill[The Sonata of Sneakiness]) || have_skill($skill[Carlweather's Cantata of Confrontation]) || have_skill($skill[Ur-Kel's Aria of Annoyance]))
	{
		if(item_amount($item[stolen accordion])==0 && item_amount($item[rock and roll legend])==0 && item_amount($item[Squeezebox of the Ages])==0 && item_amount($item[The Trickster's Trikitixa])==0)
		{
			have=false;
		}
	}
	//have saucepan
	if(have_skill($skill[Jalape&ntilde;o Saucesphere]) || have_skill($skill[Jaba&ntilde;ero Saucesphere]) || have_skill($skill[Elemental Saucesphere]) || have_skill($skill[Scarysauce]) )
	{
		if(item_amount($item[saucepan])==0 && item_amount($item[5-alarm saucepan])==0 && item_amount($item[17-alarm saucepan])==0 && item_amount($item[windsor pan of the source])==0)
		{
			have=false;
		}
	}
	//get turtle totem if needed
	if(have_skill($skill[ghostly shell]) || have_skill($skill[Tenacity of the Snapper]) || have_skill($skill[Empathy of the Newt]) || have_skill($skill[Reptilian Fortitude]) || have_skill($skill[astral shell]) || have_skill($skill[jingle bells]))
	{
		if(item_amount($item[turtle totem])==0 && item_amount($item[mace of the tortoise])==0 && item_amount($item[Chelonian Morningstar])==0 && item_amount($item[flail of the seven aspects])==0)
		{
			have=false;
		}
	}
	return have;
}

void get_buff_equip()
{
	//get accordion
	if(have_skill($skill[The Polka of Plenty]) || have_skill($skill[Fat Leon's Phat Loot Lyric]) || have_skill($skill[The Ode to Booze]) || have_skill($skill[The Sonata of Sneakiness]) || have_skill($skill[Carlweather's Cantata of Confrontation]) || have_skill($skill[Ur-Kel's Aria of Annoyance]))
	{
		if(item_amount($item[stolen accordion])==0 && item_amount($item[rock and roll legend])==0 && item_amount($item[Squeezebox of the Ages])==0 && item_amount($item[The Trickster's Trikitixa])==0)
		{
			set_property("choiceAdventure502","3");
			set_property("choiceAdventure506","1");
			set_property("choiceAdventure26","3");
			set_property("choiceAdventure29","2");
			while(item_amount($item[saucepan])==0 && my_adventures()>0 && my_meat()>30)
			{
				adventure(1,$location[The Spooky Forest]);
			}
		}
	}
	//get saucepan
	if(have_skill($skill[Jalape&ntilde;o Saucesphere]) || have_skill($skill[Jaba&ntilde;ero Saucesphere]) || have_skill($skill[Elemental Saucesphere]) || have_skill($skill[Scarysauce]) )
	{
		if(item_amount($item[saucepan])==0 && item_amount($item[5-alarm saucepan])==0 && item_amount($item[17-alarm saucepan])==0 && item_amount($item[windsor pan of the source])==0)
		{
			set_property("choiceAdventure502","3");
			set_property("choiceAdventure506","1");
			set_property("choiceAdventure26","2");
			set_property("choiceAdventure28","2");
			while(item_amount($item[saucepan])==0 && my_adventures()>0 && my_meat()>30)
			{
				adventure(1,$location[The Spooky Forest]);
			}
		}
	}
	//get turtle totem if needed
	if(have_skill($skill[ghostly shell]) || have_skill($skill[Tenacity of the Snapper]) || have_skill($skill[Empathy of the Newt]) || have_skill($skill[Reptilian Fortitude]) || have_skill($skill[astral shell]) || have_skill($skill[jingle bells]))
	{
		if(item_amount($item[turtle totem])==0 && item_amount($item[mace of the tortoise])==0 && item_amount($item[Chelonian Morningstar])==0 && item_amount($item[flail of the seven aspects])==0)
		{
			set_property("choiceAdventure502","3");
			set_property("choiceAdventure506","1");
			set_property("choiceAdventure26","1");
			set_property("choiceAdventure27","2");
			while(item_amount($item[saucepan])==0 && my_adventures()>0 && my_meat()>30)
			{
				adventure(1,$location[The Spooky Forest]);
			}
		}
	}
}

item my_epic()
{
	item epic;
	if((my_class()==$class[seal clubber]))
	{
		epic=$item[Bjorn's Hammer];
	}
	else if(my_class()==$class[turtle tamer])
	{
		epic=$item[Mace of the Tortoise];
	}
	else if(my_class()==$class[disco bandit])
	{
		epic=$item[Disco Banjo];
	}
	else if(my_class()==$class[accordion thief])
	{
		epic=$item[Rock and Roll Legend];
	}
	else if(my_class()==$class[pastamancer])
	{
		epic=$item[Pasta of Peril];
	}
	else
	{
		epic=$item[5-Alarm Saucepan];
	}
	return epic;
}

item my_legendary()
{
	item legendary;
	if((my_class()==$class[seal clubber]))
	{
		legendary=$item[Hammer of Smiting];
	}
	else if(my_class()==$class[turtle tamer])
	{
		legendary=$item[Chelonian Morningstar];
	}
	else if(my_class()==$class[disco bandit])
	{
		legendary=$item[Shagadelic Disco Banjo];
	}
	else if(my_class()==$class[accordion thief])
	{
		legendary=$item[Squeezebox of the Ages];
	}
	else if(my_class()==$class[pastamancer])
	{
		legendary=$item[Greek Pasta of Peril];
	}
	else
	{
		legendary=$item[17-alarm Saucepan];
	}
	return legendary;
}
item my_ultimate()
{
	item ultimate;
	if((my_class()==$class[seal clubber]))
	{
		ultimate=$item[Sledgehammer of the V&aelig;lkyr];
	}
	else if(my_class()==$class[turtle tamer])
	{
		ultimate=$item[Flail of the Seven Aspects];
	}
	else if(my_class()==$class[disco bandit])
	{
		ultimate=$item[Seeger's Unstoppable Banjo];
	}
	else if(my_class()==$class[accordion thief])
	{
		ultimate=$item[The Trickster's Trikitixa];
	}
	else if(my_class()==$class[pastamancer])
	{
		ultimate=$item[Wrath of the Capsaician Pastalords];
	}
	else
	{
		ultimate=$item[Windsor Pan of the Source];
	}
	return ultimate;
}

boolean check_page(string page, string text)
{
	return contains_text(visit_url(page),text);
}

boolean ensure_fancy_cocktail_kit()
{
	boolean success=contains_text(visit_url("campground.php?action=inspectkitchen"),"Queue Du Coq cocktailcrafting kit");
	if(!success)
	{
		buy(1,$item[Queue Du Coq cocktailcrafting kit]);
		use(1,$item[Queue Du Coq cocktailcrafting kit]);
	}
	success=contains_text(visit_url("campground.php?action=inspectkitchen"),"Queue Du Coq cocktailcrafting kit");
	print("ensure_fancy_cocktail_kit returning "+success);
	return success;
}

void get_paste(int amt)
{
	if(item_amount($item[meat paste])<amt)
	{
		create(amt-item_amount($item[meat paste]),$item[meat paste]);
	}
}

boolean simons_have_chef()
{
	boolean success=contains_text(visit_url("campground.php?action=inspectkitchen"),"Chef");
	return success;
}

boolean simons_have_bartender()
{
	boolean success=contains_text(visit_url("campground.php?action=inspectkitchen"),"Bartender");
	return success;
}

boolean simons_get_chef()
{
	if(simons_have_chef())
	{
		return true;
	}
	print("trying to get a chef","blue");
	if(available_amount($item[chef-in-the-box])==0)
	{
		print("making a chef","blue");
		if(available_amount($item[chef skull])==0)
		{
			print("making a chef skull","blue");
			if(available_amount($item[brainy skull])==0)
			{
				print("making a brainy skull","blue");
				if(available_amount($item[disembodied brain])==0)
				{
					if(can_interact())
					{
						print("bought brain","blue");
						buy(1,$item[disembodied brain]);
					}
					else
					{
						print("couldn't get brain","blue");
						return false;
					}
				}
				if(available_amount($item[smart skull])==0)
				{
					if(can_interact())
					{
						print("buying skull","blue");
						buy(1,$item[smart skull]);
					}
					else
					{
						print("couldn't get skull","blue");
						return false;
					}
				}
				get_paste(1);
				visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[disembodied brain].to_int())+"&b="+($item[smart skull].to_int())+"&qty=1&master=Combine%21"); //make brainy skull
			}
			if(available_amount($item[chef's hat])==0)
			{
				if(can_interact())
				{
					print("getting hat","blue");
					buy(1,$item[chef's hat]);
				}
				else
				{
					print("couldn't get hat","blue");
					return false;
				}
			}
			get_paste(1);
			visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[brainy skull].to_int())+"&b="+($item[chef's hat].to_int())+"&qty=1&master=Combine%21"); //make nothing-in-the-box
		}
		if(available_amount($item[nothing-in-the-box])==0)
		{
			print("Making nothing in hte box","blue");
			if(available_amount($item[box])==0)
			{
				if(can_interact())
				{
					print("getting box","blue");
					buy(1,$item[box]);
				}
				else
				{
					print("couldn't get box","blue");
					return false;
				}
			}
			if(available_amount($item[spring])==0)
			{
				if(can_interact())
				{
					print("getting spring","blue");
					buy(1,$item[spring]);
				}
				else
				{
					print("couldn't get spring","blue");
					return false;
				}
			}
			get_paste(1);
			visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[box].to_int())+"&b="+($item[spring].to_int())+"&qty=1&master=Combine%21"); //make nothing-in-the-box
		}
		get_paste(1);
		visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[chef skull].to_int())+"&b="+($item[nothing-in-the-box].to_int())+"&qty=1&master=Combine%21"); //make chef-in-the-box
	}
	cli_execute("refresh inventory");
	if(available_amount($item[chef-in-the-box])!=0)
	{
		print("using chef","blue");
		use(1,$item[chef-in-the-box]); //use chef in the box
		return true;
	}
	print("No result detected","blue");
	return false;
}

boolean simons_get_bartender()
{
	if(simons_have_bartender())
	{
		return true;
	}
	print("trying to make a bartender","blue");
	if(available_amount($item[bartender-in-the-box])==0)
	{
		if(available_amount($item[bartender skull])==0)
		{
			if(available_amount($item[brainy skull])==0)
			{
				if(available_amount($item[disembodied brain])==0)
				{
					if(can_interact())
					{
						buy(1,$item[disembodied brain]);
					}
					else
					{
						print("simons_get_bartender returning false","blue");
						return false;
					}
				}
				if(available_amount($item[smart skull])==0)
				{
					if(can_interact())
					{
						buy(1,$item[smart skull]);
					}
					else
					{
						print("simons_get_bartender returning false","blue");
						return false;
					}
				}
				get_paste(1);
				print("crafting brainy skull","blue");
				visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[disembodied brain].to_int())+"&b="+($item[smart skull].to_int())+"&qty=1&master=Combine%21"); //make brainy skull
			}
			if(available_amount($item[beer goggles])==0)
			{
				if(available_amount($item[beer lens])<2)
				{
					if(can_interact())
					{
						buy(2-available_amount($item[beer lens]),$item[beer lens]);
					}
					else
					{
						print("simons_get_bartender returning false","blue");
						return false;
					}
				}
				get_paste(1);
				print("crafting beer goggles","blue");
				visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[beer lens].to_int())+"&b="+($item[beer lens].to_int())+"&qty=1&master=Combine%21"); //make beer goggles
			}
			get_paste(1);
			print("crafting bartender skull","blue");
			visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[brainy skull].to_int())+"&b="+($item[beer goggles].to_int())+"&qty=1&master=Combine%21"); //make bartender skull
		}
		if(available_amount($item[nothing-in-the-box])==0)
		{
			if(available_amount($item[box])==0)
			{
				if(can_interact())
				{
					buy(1,$item[box]);
				}
				else
				{
					print("simons_get_bartender returning false","blue");
					return false;
				}
			}
			if(available_amount($item[spring])==0)
			{
				if(can_interact())
				{
					buy(1,$item[spring]);
				}
				else
				{
					print("simons_get_bartender returning false","blue");
					return false;
				}
			}
			get_paste(1);
			print("crafting nothing in the box","blue");
			visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[box].to_int())+"&b="+($item[spring].to_int())+"&qty=1&master=Combine%21"); //make nothing-in-the-box
		}
		get_paste(1);
		print("crafting crafting bartender in the box","blue");
		visit_url("craft.php?mode=combine&pwd&action=craft&a="+($item[bartender skull].to_int())+"&b="+($item[nothing-in-the-box].to_int())+"&qty=1&master=Combine%21"); //make bartender-in-the-box
	}
	cli_execute("refresh inventory");
	if(available_amount($item[bartender-in-the-box])!=0)
	{
		use(1,$item[bartender-in-the-box]); //use bartender-in-the-box
		print("simons_get_bartender returning true","blue");
		return true;
	}
	print("simons_get_bartender returning false","blue");
	return false;
}

void new_hermit(item it)
{
	while(my_meat()>50 && item_amount($item[worthless trinket])==0 && item_amount($item[worthless gewgaw])==0 && item_amount($item[worthless knick-knack])==0)
	{
		use(1,$item[chewing gum on a string]);
	}
	if(item_amount($item[worthless trinket])!=0 || item_amount($item[worthless gewgaw])!=0 || item_amount($item[worthless knick-knack])!=0)
	{
		cli_execute("hermit "+it);
	}
}

void skeleton_farm()
{
	while(my_adventures()>0)
	{
		string page = visit_url("adventure.php?snarfblat=245");
		if(contains_text(page,"nothing more to see here"))
		{
			cli_execute("use * bag of bones");
			cli_execute("stash put * bone chips");
			return;
		}
		page = attack();
		if(contains_text(page,"Stabonic scroll"))
		{
			break;
		}
		if(contains_text(visit_url("campground.php"),"Your Campsite"))
		{
			//recover 1 hp
			visit_url("galaktik.php?pwd&action=curehp&quantity=1");
		}
	}
}

//returns the lower price of either buying it, or making it from ingredients
//does not recurse
int best_price(item it)
{
	int total_price=0;
	//get ingredients
	int [item] mats = get_ingredients(it);
	int num_ingredients=0;
	item last_mat; //used if there is only one
	//count number of ingredients
	foreach mat in mats
	{
		last_mat=mat;
		num_ingredients=1+num_ingredients;
	}
	//if none, return price
	if(num_ingredients==0)
	{
		return mall_price(it);
	}
	//if one, return lowest price
	if(num_ingredients==1)
	{
		return min(mall_price(it),mall_price(last_mat));
	}
	//else recurse for each, summing, then return
	foreach mat in mats
	{
		total_price+=mall_price(mat);
	}
	return min(mall_price(it),total_price);
}

//obtains as mafia does, cheapest combination of buying and making, but dosen't
//check if it's creatable since it's broken in mafia
void smart_obtain(item it)#
{
	int total_price=0;
	//get ingredients
	int [item] mats = get_ingredients(it);
	int num_ingredients=0;
	item last_mat; //used if there is only one
	//count number of ingredients
	foreach mat in mats
	{
		last_mat=mat;
		num_ingredients=1+num_ingredients;
	}
	//if none, buy item
	if(num_ingredients==0)
	{
		buy(1,it);
	}
	//if one, buy lowest price
	if(num_ingredients==1)
	{
		if(mall_price(it)<mall_price(last_mat))
		{
			buy(1,it);
		}
		else
		{
			buy(1,last_mat);
		}
		//CREATING OF ITEM FROM MATS NOT DONE
	}
	//else recurse for each, summing, then return
	if(num_ingredients<1)
	{
		foreach mat in mats
		{
			total_price+=mall_price(mat);
		}
		if(mall_price(it)<total_price)
		{
			buy(1,it);
		}
		else
		{
			foreach mat in mats
			{
				buy(1,mat);
			}
			//CREATING OF ITEM FROM MATS NOT DONE
		}
	}
}

item choose_cheapest_item(item it1, item it2)
{
	if(best_price(it1)<best_price(it2))
	{
		return it1;
	}
	return it2;
}

void choose_and_drink_cherry_tps()
{
	item second_ingredient=choose_cheapest_item($item[old-fashioned],$item[sangria]);
	print("second_ingredient chosen="+to_string(second_ingredient),"blue");
	if(item_amount(second_ingredient)==0)
	{
		cli_execute("acquire "+to_string(second_ingredient));
	}
	craft("cocktail",1,$item[skewered cherry],second_ingredient);
	cli_execute("drink * cherry bomb");
	cli_execute("drink * sangria del diablo");
}

void choose_and_drink_olive_tps()
{
	item second_ingredient=choose_cheapest_item($item[dry martini],$item[dry vodka martini]);
	print("second_ingredient chosen="+to_string(second_ingredient),"blue");
	if(item_amount(second_ingredient)==0)
	{
		cli_execute("acquire "+to_string(second_ingredient));
	}
	craft("cocktail",1,$item[skewered jumbo olive],second_ingredient);
	cli_execute("drink * vesper");
	cli_execute("drink * dirty martini");
}

void choose_and_drink_lime_tps()
{
	item second_ingredient=choose_cheapest_item($item[tequila with training wheels],$item[grog]);
	print("second_ingredient chosen="+to_string(second_ingredient),"blue");
	if(item_amount(second_ingredient)==0)
	{
		cli_execute("acquire "+to_string(second_ingredient));
	}
	craft("cocktail",1,$item[skewered lime],second_ingredient);
	cli_execute("drink * bodyslam");
	cli_execute("drink * grogtini");
}