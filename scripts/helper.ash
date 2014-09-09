import <sims_lib.ash>;

boolean have_epic_or_higher()
{
	int total = available_amount(my_epic()) + available_amount(my_legendary()) + available_amount(my_ultimate());
	return (total>0);
}

boolean have_legendary_or_higher()
{
	int total = available_amount(my_legendary()) + available_amount(my_ultimate());
	return (total>0);
}

boolean can_cook_fancy()
{
	return (have_skill($skill[advanced saucecrafting]) || have_skill($skill[pastamastery]));
}

boolean have_wand()
{
	if(available_amount($item[aluminum wand])>0)
		return true;
	if(available_amount($item[ebony wand])>0)
		return true;
	if(available_amount($item[hexagonal wand])>0)
		return true;
	if(available_amount($item[marble wand])>0)
		return true;
	if(available_amount($item[pine wand])>0)
		return true;
	return false;
}

boolean potion_not_needed(string var)
{
	string type=get_property(var);
//possible needed types = "blessing","ettin strength","mental acuity","detection","teleportitis",
//never needed types = "healing","confusion","sleepiness","inebriety"
	if( type=="healing")
		return true;
	if( type=="confusion")
		return true;
	if( type=="sleepiness")
		return true;
	if( type=="inebriety")
		return true;
	return false;
}

boolean have_bang_potion()
{
	if(available_amount($item[milky potion])<0 && !potion_not_needed("lastBangPotion819"))
		return false;
	if(available_amount($item[swirly potion])<0 && !potion_not_needed("lastBangPotion820"))
		return false;
	if(available_amount($item[bubbly potion])<0 && !potion_not_needed("lastBangPotion821"))
		return false;
	if(available_amount($item[smoky potion])<0 && !potion_not_needed("lastBangPotion822"))
		return false;
	if(available_amount($item[cloudy potion])<0 && !potion_not_needed("lastBangPotion823"))
		return false;
	if(available_amount($item[effervescent potion])<0 && !potion_not_needed("lastBangPotion824"))
		return false;
	if(available_amount($item[fizzy potion])<0 && !potion_not_needed("lastBangPotion825"))
		return false;
	if(available_amount($item[dark potion])<0 && !potion_not_needed("lastBangPotion826"))
		return false;
	if(available_amount($item[murky potion])<0 && !potion_not_needed("lastBangPotion827"))
		return false;
	return true;
}

boolean fcle_available()
{
	boolean success=false;
	if(available_amount($item[pirate fledges])>0 && my_basestat($stat[mysticality])>=60)
	{
		cli_execute("outfit save tmp");
		equip($item[pirate fledges]);
		success = check_page("cove.php","cove3_3x1b.gif");
		cli_execute("outfit tmp");
	}
	else if(have_outfit("swashbuckling getup"))
	{
		cli_execute("outfit save tmp");
		outfit("swashbuckling getup");
		success = check_page("cove.php","cove3_3x1b.gif");
		cli_execute("outfit tmp");
	}
	return success;
}

void advise_pulls(string woods_string)
{
	if(can_interact() || in_hardcore())
		return;
	print("--- Consider Pulling (after consumables)---","");
	if(available_amount($item[glass of goat's milk])<1 && available_amount($item[milk of magnesium])<1 && my_fullness()< fullness_limit())
		print("milk of magnesium","");
	if(my_path()=="Avatar of Boris" && available_amount($item[mr. accessory jr.])<3)
		print("mr accessory jr.","");
	if(!have_skill($skill[inigo's incantation of inspiration]) && ((have_skill($skill[advanced cocktailcrafting]) && !simons_have_bartender() && can_drink())))
		print("bartender in the box","");
	if((can_cook_fancy() && !simons_have_chef()&& can_eat())) 
		print("chef in the box","");
//	if(available_amount($item[ring of conflict])<1)
//		print("ring of conflict (req 25 mys)","");
	if(my_path()=="Avatar of Boris" && available_amount($item[bounty-hunting helmet])<1)
		print("bounty-hunting helmet (req 25 mox)","");
	if(my_path()=="Avatar of Boris" && available_amount($item[spooky putty mitre])<1)
		print("spooky putty mitre","");
	if(available_amount($item[stinky cheese eye])<1 && available_amount($item[stinky cheese diaper])<1)
		print("stinky cheese eye for banish, items/meat, and rollover advs","");
//	if(available_amount($item[monster bait])<1)
//		print("monster bait (req 0)","");
//	if(available_amount($item[hockey stick of furious angry rage])<1)
//		print("hockey stick (req 35 mys)","");
	if(available_amount($item[spooky-gro fertilizer])<1 && !contains_text(woods_string,"hiddencity.gif") && !contains_text(woods_string,"temple.gif"))
		print("spooky-gro fertilizer","");
	if(!have_outfit("swashbuckling getup") && available_amount($item[pirate fledges])<1 && available_amount($item[the big book of pirate insults])<1)
		print("pirate insults book","");
	if(available_amount($item[wet stunt nut stew])<1 && available_amount($item[mega gem])<1)
	{
		if(available_amount($item[wet stew])<1)
			print("wet stew","");
		if(available_amount($item[stunt nuts])<1)
			print("stunt nuts","");
	}
	if(available_amount($item[greatest american pants])>0)
	{
		if(available_amount($item[ninja rope])<1)
			print("ninja rope","");
		if(available_amount($item[ninja crampons])<1)
			print("ninja crampons","");
		if(available_amount($item[ninja carabiner])<1)
			print("ninja carabiner","");
	}
	if(available_amount($item[ketchup hound])<1)
		print("ketchup hound","");
	if(available_amount($item[drum machine])<1 && available_amount($item[worm-riding hooks])<1)
		print("drum machine","");
//	if(available_amount($item[bag o' tricks])<1)
//		print("bag o' tricks for buffs","");
	if(available_amount($item[Mick's IcyVapoHotness Inhaler])<1)
		print("Mick's IcyVapoHotness Inhaler","");
	if(available_amount($item[cyclops eyedrops])<1)
		print("cyclops eyedrops","");
	print("Tower items","");
}

void advise_yellow_ray(string completed_log, string woods_string)
{
	if(have_effect($effect[everything looks yellow])!=0 || my_path() == "Bees Hate You")
	{
		return;
	}
	print("","blue");
	print("--- Consider yellow raying ---","blue");
	if(my_level()>7 && !contains_text(completed_log,"Am I my Trapper's Keeper") && !have_outfit("mining gear"))
	{
		print("- Mining gear.","blue");
	}
	if(!have_outfit("filthy hippy"))
	{
		print("- Hippy outfit.","blue");
	}
	if(my_buffedstat(my_primestat())>33 && !contains_text(completed_log,"The Goblin Who Wouldn") && (!have_outfit("harem") || available_amount($item[knob goblin perfume])<1))
	{
		print("- Harem Girl for meat per day?","blue");
	}
	if(my_buffedstat(my_primestat())>143)
	{
		print("- Swarm of scarab beatles at oasis for mojo filter, gun, food","blue");
	}
	if(my_buffedstat(my_primestat())>26)
	{
		print("- Fun house, Scary clown for clownosity or Shaky clown for basic booze (and a little clownosity).","blue");
	}
	if(my_buffedstat(my_primestat())>82)
	{
		print(" -booze giant for basic booze in menagerie 3","blue");
	}
	if(my_buffedstat(my_primestat())>126)
	{
		print("- MagiMechTech MechaMech for photoprotneutron torpedo, metallic A, and wads","blue");
	}
	if(!have_outfit("frat boy ensemble") && my_path()=="Bees hate you")
	{
		print("- Frat boy outfit.","blue");
	}
	print("Enemies in a maze of sewer tunnels for stats, or 1000 ml butt if copy left","blue");
}

void advise_fax(string completed_log, string manor_string, string manor2_string)
{
	if(my_path()=="Avatar of Boris" || get_property("_photocopyUsed")=="true")
		return;
		
	print("","maroon");
	print("--- Consider using a fax for (in priority order) ---","maroon");
	
	if(available_amount($item[digital key])<1 && available_amount($item[white pixel])<30 && my_buffedstat(my_primestat())>25)
		print("- fax (and badly romance/putty) ghost for white pixels (safemox=25).","maroon");
	
	if(available_amount($item[spangly sombrero])<1 && my_path() != "Bees Hate You")
		print("- fax + yellow ray sleepy mariachi, for sexy gear (safemox=118).","maroon");
		
	if(my_path()!="Bees hate you" && my_level()<6 && available_amount($item[glass of goat's milk])<1 && available_amount($item[milk of magnesium])<1)
		print("- Fax (and yellow ray?) dairy goat for milks","maroon");
	
	int needed_334=0;
	int needed_30669=0;
	int needed_33398=0;
	if(!contains_text(completed_log,"You have helped the Baron Rof L"))
	{
		needed_334+=2;
		needed_30669+=1;
		needed_33398+=1;
	}
	if(get_property("hermitHax0red")=="false")
	{
		needed_334+=2;
		needed_30669+=1;
	}
	if((available_amount($item[334 scroll])<needed_334 || available_amount($item[30669 scroll])<needed_30669 || available_amount($item[33398 scroll])<needed_33398))
		print("- fax (and badly romance/putty) Bad ASCII Art, for quest/31337 scroll (safemox=80).","maroon");
	
	if(get_property("sidequestLighthouseCompleted")=="none" && available_amount($item[barrel of gunpowder])<5)
		print("- fax lobsterfrogman (and badly romance/putty), for quest item (safemox=160).","maroon");
	
	if(get_property("sidequestOrchardCompleted")=="none" && available_amount($item[filthworm royal guard scent gland])<1)
		print("- fax filthworm royal guard, for stench gland (safemox=150), use high item drops or yellow ray.","maroon");
	
	if(my_level()>3 && !contains_text(visit_url("bathole.php"),"bathole_5.gif") && my_path()=="Bees hate you")
		print("- fax screambat, to help open bossbat (safemox=17). Possibly sniff it too.","maroon");
	
	if(available_amount($item[lowercase n])<1 && available_amount($item[nd])<1 && available_amount($item[wand of nagamar])<1 && my_path() != "Bees hate you")
		print("- fax xxx pr0n for lowercase n (and pron legs) (safemox=68).","maroon");
		
	print("- fax trippy floating head/urge to stare at your hands/angels of avalon for blue cupcake (safemox=20/50/142).","maroon");
}

//holds info on something to eat/drink
record consumable
{
	string text;
	int craft_turns;
	float avg_adv;
	int fullness;
	float efficiency;
};

//take details of a food, and add it to the con_map with it's efficiency
void add_food(consumable[int] con_map,string text,float avg_adv,int craft_turns,int fullness, boolean is_pizza, boolean is_saucey)
{
	//check we can eat it
	if(fullness>(fullness_limit() - my_fullness()))
	{
		return;
	}
	//else create it
	consumable con;
	con.text=text;
	con.avg_adv=avg_adv;
	if(is_pizza && have_skill($skill[pizza lover]))
	{
		con.avg_adv = avg_adv + fullness;
	}
	if(is_saucey && have_skill($skill[saucemaven]))
	{
		if(my_class()==$class[pastamancer] || my_class()==$class[sauceror])
			con.avg_adv = avg_adv + 10;
		else
			con.avg_adv = avg_adv + 5;
	}
	con.craft_turns=craft_turns;
	con.fullness=fullness;
	//account for crafting
	con.efficiency=con.avg_adv;
	if(!have_chef() && !(have_skill($skill[Inigo's Incantation of Inspiration]) && my_maxmp()>100 && my_path()!="Heavy Rains"))
		con.efficiency-=con.craft_turns;
	con.efficiency/=fullness;
	//then add it
	int new_index=count(con_map);
	con_map[new_index]=con;
}
void add_food(consumable[int] con_map,string text,float avg_adv,int craft_turns,int fullness, boolean is_pizza)
{
	add_food(con_map, text, avg_adv, craft_turns, fullness, is_pizza, false);
}
void add_food(consumable[int] con_map,string text,float avg_adv,int craft_turns,int fullness)
{
	add_food(con_map, text, avg_adv, craft_turns, fullness, false, false);
}

//copy of add food, but compare against drunken limits and bartender
void add_drink(consumable[int] con_map,string text,float avg_adv,int craft_turns,int fullness)
{
	//check we can eat it
	if(fullness>(inebriety_limit() - my_inebriety()))
	{
		return;
	}
	//else create it
	consumable con;
	con.text=text;
	con.avg_adv=avg_adv;
	con.craft_turns=craft_turns;
	con.fullness=fullness;
	//account for crafting
	con.efficiency=con.avg_adv;
	if(!have_bartender() && !(have_skill($skill[Inigo's Incantation of Inspiration]) && my_maxmp()>100))
		con.efficiency-=con.craft_turns;
	con.efficiency/=fullness;
	//then add it
	int new_index=count(con_map);
	con_map[new_index]=con;
}

void advise_food()
{
	if(my_level()>10)
		cli_execute("use * sack lunch");
	consumable [int] con_map;
	//fill map
	if(my_fullness()< fullness_limit() && can_eat())
	{
		boolean bees_ok= (my_path() != "Bees hate you");
	
		print("","purple");
		print("--- Consider Eating ---","purple");
		print("(Spices = "+available_amount($item[spices])+". For more, clover no knob kitchens)","purple");
		
		string counters = get_counters("Fortune Cookie", 0, 200);
		if(counters == "")
			print("- Eat fortune cookie","purple");
			
		if(my_level()>10 && (available_amount($item[astral hot dog dinner])>0 || available_amount($item[astral hot dog])>0))
		{
			add_food(con_map,"- ASTRAL HOTDOG ",22,0,3);
		}
			
		if(available_amount($item[knob pasty])!=0 && bees_ok)
		{
			add_food(con_map,"- knob pasty ",5.5,0,1);
		}
		if(available_amount($item[grue egg])!=0 || available_amount($item[grue egg omelette])!=0)
		{
			if(available_amount($item[crown of thrones])>0)
				add_food(con_map,"- Grue egg (requires spooky mushroom from astral badger in COT) ",24,1,4);
			else
				add_food(con_map,"- Grue egg (requires spooky mushroom from spooky forest noncombat) ",24,1,4);
		}
		if(my_level()>4 && available_amount($item[moon pie])>0 || available_amount($item[lunar isotope])>99)
		{
			add_food(con_map,"- Moon pie (brought from lunar launch o mat for 100 isotopes) ",30,0,5);
		}
		if(available_amount($item[Retenez L'Herbe Pat&eacute;])>0)
		{
			add_food(con_map,"- Retenez L'Herbe Paté ",16.5,0,3);
		}
		if(available_amount($item[pumpkin])!=0)
		{
			add_food(con_map,"- Pumpkin pie (requires bakery access) ",16.5,0,3);
		}
		if(available_amount($item[tasty tart])!=0)
		{
			add_food(con_map,"- tasty tart ",5.5,0,1);
		}
		if(available_amount($item[dry noodles])!=0 && have_skill($skill[pastamastery]))
		{			
			if(my_path() != "Bees Hate You" && my_level()>5 && (available_amount($item[scrumptious reagent])!=0 || available_amount($item[scrumdiddlyumptious solution])!=0 )&& (my_class()==$class[sauceror] || my_class()==$class[pastamancer]) && have_skill($skill[transcendental noodlecraft]) && have_skill($skill[the way of sauce]))
			{
				add_food(con_map,"-    noodles + elemental nuggets + scrumdidly solution (<element> hi mein) ",24.5-1,1,5,false,true);
			}
			
			if(have_outfit("filthy hippy") || available_amount($item[herbs])>0)
			{
				if(my_class()==$class[sauceror] || my_class()==$class[pastamancer] && have_skill($skill[transcendental noodlecraft]) && available_amount($item[spices])>1)
				{
					add_food(con_map,"-    noodles + herb + spice + knoll mushroom + saus (knob sausage chow mein) ",24.5-1,1,5);
					add_food(con_map,"-    noodles + herb + spice + knob mushroom + bat wing (bat wing chow mein) ",24.5-1,1,5);
					add_food(con_map,"-    noodles + herb + spice + spooky mushroom + rat appendix (rat appendix chow mein) ",24.5-1,1,5);
					add_food(con_map,"-    noodles + herb + spice + olive + pr0n (pr0n chow mein) ",19.5-1,1,4);
					add_food(con_map,"-    noodles + herb + spice + asparagus + tofu (tofu chow mein) ",14.5-1,1,3);
				}
			}
			
			if(my_level()>11 && my_class()==$class[sauceror] || my_class()==$class[pastamancer] && have_skill($skill[transcendental noodlecraft]))
			{
				add_food(con_map,"-    noodles + McMillicancuddy's lager + frat brats (sausage wonton) ",15-1,0,3);
				add_food(con_map,"-    noodles + megatofu + mixed wildflower greens (tofu wonton) ",14.5-1,0,3);
			}
			
			if(my_level()>10 && my_class()==$class[sauceror] || my_class()==$class[pastamancer] && have_skill($skill[transcendental noodlecraft]))
			{
				add_food(con_map,"-    noodles + gnat steak + ancient spice (gnat lasagna) (summon potion of the field gar (wine,cat,cat) as long as it's not monday for +5 adv per lasagna)",14.5-1,0,3);
				add_food(con_map,"-    noodles + long pork + black pepper (long pork lasagna) (summon potion of the field gar (wine,cat,cat) as long as it's not monday for +5 adv per lasagna)",14.5-1,0,3);
				add_food(con_map,"-    noodles + displaced fish + dehydrated caviar (fishy fish lasagna) (summon potion of the field gar (wine,cat,cat) as long as it's not monday for +5 adv per lasagna)",14.5-1,0,3);
			}
			
			if(my_level()>9)
			{
				if(available_amount($item[Gnatloaf casserole])>0 || (available_amount($item[Gnatloaf casserole])>0 && available_amount($item[Gnatloaf casserole])>0))
					add_food(con_map,"-    Gnatloaf casserole ",11.5,0,3);
				if(available_amount($item[Long pork casserole])>0 || (available_amount($item[long pork])>0 && available_amount($item[black pepper])>0))
					add_food(con_map,"-    Long pork casserole ",11.5,0,3);
				if(available_amount($item[fishy fish casserole])>0 || (available_amount($item[dehydrated caviar])>0 && available_amount($item[displaced fish])>0))
					add_food(con_map,"-    fishy fish casserole ",11.5,0,3);
			}
			
			
			if((have_outfit("filthy hippy") || available_amount($item[herbs])>0) && available_amount($item[spices])>0)
			{
				add_food(con_map,"-    noodles + herb + spice + knoll mushroom (knoll lo mein) ",17.5,2,4);
				add_food(con_map,"-    noodles + herb + spice + spooky mushroom (spooky lo mein) ",17.5,2,4);
				add_food(con_map,"-    noodles + herb + spice + knob mushroom (knob lo mein) ",17,2,4);
				add_food(con_map,"-    noodles + herb + spice + asparagus (asparagus lo mein) ",12.5,2,3);
				add_food(con_map,"-    noodles + herb + spice + olive (olive lo mein) ",12.5,2,3);
			}
			
			if(available_amount($item[scrumptious reagent])!=0 || get_property("reagentSummons").to_int()<5)
			{
				if(my_level()>5 && (available_amount($item[hellion cube])>0 || available_amount($item[hell broth])>0  || available_amount($item[hell ramen])>0))
				{
					add_food(con_map,"-    noodles + hell broth ",25,2,6,false,true);
				}
				if(my_level()>7 && (available_amount($item[goat cheese])>0 || available_amount($item[fettucini inconnu])>0))
				{
					add_food(con_map,"-    noodles + goat cheese sauce (fettucini inconnu) ",24.5,2,6,false,true);
				}
				if(my_level()>4 && (available_amount($item[knob mushroom])>0 || available_amount($item[knob sausage])>0 || available_amount($item[gnocchetti di Nietzsche])>0 || available_amount($item[spaghetti with skullheads])>0))
				{
					add_food(con_map,"-    noodles + mush/saus sauce from knob kitchens (gnoccheti di nietzsche/spaghetti with skullheads) ",24.5,2,6,false,true);
				}
				if(available_amount($item[bitchin' meatcar])>0 && (available_amount($item[marzipan skull])>0 || gnomads_available()))
				{
					add_food(con_map,"-    noodles + marzipan skullhead sauce (spaghetti con calaveras) ",23,2,6,false,true);
				}
			}
			if(available_amount($item[spices])>0)
				add_food(con_map,"-    noodles + herb + spice (delicious spicy noodles) ",11,1,3);
			add_food(con_map,"-    noodles + jabanero (painful penne pasta) (will hurt)",8.5,1,3);
			add_food(con_map,"-    noodles + herb/tomato (delicious noodles/boring spaghetti) ",7.5,1,3);
		}
		
		if((get_property("tomeSummons").to_int()<3 || available_amount($item[ultrafondue])>0) && my_path()!="Avatar of Boris")
			add_food(con_map,"- Ultrafondue from summon clipart (cheese,cheese,cheese) increases ML ",14.5,0,3);
			
		
		if((get_property("tomeSummons").to_int()<3 || available_amount($item[blunt cat claw])>0)  && my_path()!="Avatar of Boris" && my_primestat()==$stat[muscle])
			add_food(con_map,"- blunt cat claw from summon clipart (cat,donut,hammer) gives damage buff ",4,0,1);
		if((get_property("tomeSummons").to_int()<3 || available_amount($item[occult jelly donut])>0) && my_path()!="Avatar of Boris" && my_primestat()==$stat[mysticality])
			add_food(con_map,"- occult jelly donut from summon clipart (wine,donut,skull) gives spell damage buff ",4,0,1);
		if((get_property("tomeSummons").to_int()<3 || available_amount($item[frozen danish])>0) && my_path()!="Avatar of Boris" && my_primestat()==$stat[moxie])
			add_food(con_map,"- frozen danish from summon clipart (snow,donut,cheese) gives pickpocket buff ",4,0,1);
			
		if(my_path() != "Bees Hate You" && available_amount($item[filthy lucre])>0)
			add_food(con_map,"- Bowl of bounty-os ",13.5,0,3);
			
		if(my_path() != "Bees Hate You")
		{
			if(available_amount($item[badass pie])>0)
				add_food(con_map,"-    Badass pie from boss Organs",9,0,2);
			if(available_amount($item[throbbing organ pie])>0)
				add_food(con_map,"-    throbbing organ pie from sleazy Organs",8.5,0,2);
			if(available_amount($item[stomach turnover])>0 || available_amount($item[piping organ pie])>0 || available_amount($item[dead lights pie])>0)
				add_food(con_map,"-    stomach turnover/piping organ pie/dead lights pie from stinky/hot/spooky Organs",8,0,2);
			if(available_amount($item[igloo pie])>0)
				add_food(con_map,"-    igloo pie from cold Organs ",7.5,0,2);
			if(available_amount($item[liver and let pie])>0)
				add_food(con_map,"-    liver and let pie from normal Organs ",6,0,2);
		}
			
			
		if(my_buffedstat(my_primestat())>27 && my_path() != "Bees Hate You" && available_amount($item[spices])>0)
		{
			add_food(con_map,"- Insanely spicy enchanted bean burritos ",11.5,0,3);
		}
		if(my_buffedstat(my_primestat())>62 && available_amount($item[lime])>0 || available_amount($item[boris's key lime pie])>0
		 || available_amount($item[jarlsberg's key lime pie])>0 || available_amount($item[sneaky pete's key lime pie])>0)
		{
			add_food(con_map,"- Key lime pies ",15,1,4);
		}
		
		if(my_level()>11 && my_path()=="Bees hate you")
		{
			add_food(con_map,"- Upgraded hippy fruit pies ",11,0,3);
		}
		
		if(my_level()>10 && (available_amount($item[brown sugar cane])>0 || available_amount($item[centipede eggs])>0 || available_amount($item[savoy truffle])>0 || available_amount($item[cactus fruit])>0))
		{
			add_food(con_map,"-    brown sugar cane/centipeded eggs/savoy truffle/cactus fruit from mobs in oasis/desert (truffle/fruit hurts, eggs poison)",6.5,0,2);
		}
		
		if((available_amount($item[displaced fish])!=0 && available_amount($item[dehydrated caviar])!=0) || available_amount($item[fishy fish])!=0 )
		{
			add_food(con_map,"-    fishy fish (from displaced fish + dehydrated caviar) ",6,0,2);
		}
		
		if((available_amount($item[filet of tangy gnat (&quot;fotelif&quot;)])!=0 && available_amount($item[ancient spice])!=0) || available_amount($item[gnatloaf])!=0 )
		{
			add_food(con_map,"-    gnatload (from filet of gnat + ancient spice) ",6,0,2);
		}
		
		if((available_amount($item[long pork])!=0 && available_amount($item[black pepper])!=0) || available_amount($item[long pork chop sandwiches])!=0 )
		{
			add_food(con_map,"-    long pork chop sandwiches (from long pork + black pepper (check you don't need pepper for tower)) ",6,0,2);
		}
		
		if(my_level()>10 && available_amount($item[unidentified jerky])>0)
		{
			add_food(con_map,"-    unidentified jerky from mobs inside pyramid ",6,0,2);
		}
		
		if(my_level()>4 && available_amount($item[cherry])>0)
		{
			add_food(con_map,"-    Cherry pie from fruit golem / fruit basket ",9,0,3);
		}
		
		if(my_level()>3 && available_amount($item[knob nuts])>0)
		{
			add_food(con_map,"-    Knob nuts from harem guards ",3,0,1);
		}
		
		if(available_amount($item[handful of honey])>4 || available_amount($item[wild honey pie])>0)
			add_food(con_map,"- Wild Honey pie (made with 5 handful of honey) ",5,0,2);
		
		if((get_property("tomeSummons").to_int()<3 || available_amount($item[ur-donut])>0) && my_path()!="Avatar of Boris")
			add_food(con_map,"- Ur donut from summon clipart (donut,donut,donut) good stats ",2.5,0,1);
		
		if(my_level()>10 && available_amount($item[hot date])>0)
		{
			add_food(con_map,"-    hot date from mobs at oasis ",4.5,0,2);
		}
			
		cli_execute("use * hippy army mpe");
		cli_execute("use * frat army fgf");
		if(available_amount($item[super salad])>0 || (available_amount($item[megatofu])>0 && available_amount($item[mixed wildflower greens])>0))
			add_food(con_map,"- Super salad (megatofu + mixed wildflower greens) ",14.5,0,3);
			
		if(available_amount($item[beer basted brat])>0 || (available_amount($item[mcmillicancuddy's special lager])>0 && available_amount($item[frat brats])>0))
			add_food(con_map,"- beer basted brat (mcmillicancuddys lager + frat brats) ",14.5,0,3);
			
		if(available_amount($item[nutty organic salad])>0 || (available_amount($item[handful of walnuts])>0 && available_amount($item[mixed wildflower greens])>0))
			add_food(con_map,"- nutty organic salad (handful of walnuts + mixed wildflower greens) ",13.5,0,3);
			
		if(available_amount($item[super ka-bob])>0 || (available_amount($item[knob ka-bobs])>0 && available_amount($item[frat brats])>0))
			add_food(con_map,"- super ka-bob (knob ka-bobs + frat brats) ",13.5,0,3);
			
		if(available_amount($item[Genalen&trade; Bottle])>0 || available_amount($item[handful of walnuts])>0 || available_amount($item[mixed wildflower greens])>0)
			add_food(con_map,"- Basic hippy food (genalen/wildflower greens/handful of walnuts ",3,0,1);
			
		if(available_amount($item[brain-meltingly-hot chicken wings])>0 || available_amount($item[Frat brats])>0 || available_amount($item[knob ka-bobs])>0)
			add_food(con_map,"- Basic frat food (brain-meltingly-hot chicken wings/Frat brats/knob ka-bobs ",3,0,1);
		
		if(my_level()>3)
		{
			add_food(con_map,"-    Elven Hardtack from transponders ",6.5,0,3);
		}
		if(have_outfit("filthy hippy") && available_amount($item[goat cheese])>0)
		{
			add_food(con_map,"-    pizza + goat cheese ",6.5,0,3,true);
		}
		if(have_outfit("filthy hippy") && (available_amount($item[knob mushroom])>0 || available_amount($item[knob sausage])>0))
		{
			add_food(con_map,"-    pizza + mush/saus from knob kitchens ",6.5,0,3,true);
		}
		if(available_amount($item[Ye Wizard's Shack snack voucher])>0 || get_property("grimoire3Summons").to_int()==0 && my_path()!="Avatar of Boris")
		{
			add_food(con_map,"- Pocky from wizard shack (gives 30 turn damage buff. tobiko=spells, wasabi=weapons) ",6.5,0,3);
		}
		if(my_buffedstat(my_primestat())>29 && available_amount($item[lihc eye])>0)
		{
			add_food(con_map,"-    lihc eye pie ",8.5,0,4);
		}
		if(my_level()>3 && available_amount($item[crown of thrones])!=0)
		{
			add_food(con_map,"-    candycane / gingerbread bugbear from sweet nutcracker in CoT ",3,0,1);
		}
		if(available_amount($item[bag of GORP])>0)
			add_food(con_map,"-    bag of GORP ",4,0,2);
		if(available_amount($item[bag of GORF])>0)
			add_food(con_map,"-    bag of GORF ",2,0,1);
		if(available_amount($item[bag of QWOP])>0)
			add_food(con_map,"-    bag of QWOP ",5,0,1);
		if(available_amount($item[peppermint sprout])>1)
			add_food(con_map,"-    peppermint patty ",10.5,0,2);
		if(available_amount($item[skeleton])>2)
			add_food(con_map,"- skeleton quiche ",11,0,2);
		if(available_amount($item[corned-beef Reuben])>0)
			add_food(con_map,"- corned-beef Reuben ",12.5,0,3);
		if(available_amount($item[Club sandwich])>0)
			add_food(con_map,"- Club sandwich ",9.5,0,3);
		if(available_amount($item[PB&BP])>0)
			add_food(con_map,"- PB&BP ",7,0,3);
		if(available_amount($item[Taco Dan's Taco Stand Taco])>0)
			add_food(con_map,"- Taco Dan's Taco Stand Taco ",2.5,0,1);
		if(available_amount($item[carrot nose])>0)
			add_food(con_map,"- carrot cake ",8.5,0,3);
		if(available_amount($item[stolen sushi])>0)
			add_food(con_map,"- stolen sushi ",13,0,6);
		if(available_amount($item[Giant heirloom grape tomato])>0)
			add_food(con_map,"- Giant heirloom grape tomato ",14,0,5);
		cli_execute("use * Giant jar of protein powder");
		if(available_amount($item[giant grain of protein powder])>0)
			add_food(con_map,"- giant grains of protein powder ",2.5,0,1);
		if(!get_property("_fancyHotDogEaten").to_boolean())
		{
			if(my_primestat()==$stat[muscle])
				add_food(con_map,"- Hot Dog (Savage Macho Dog) ",7,0,2);
			else if(my_primestat()==$stat[mysticality])
				add_food(con_map,"- Hot Dog (One With Everything) ",7,0,2);
			else
				add_food(con_map,"- Hot Dog (Sly Dog) ",7,0,2);
			add_food(con_map,"- Hot Dog (Devil Dog) ",13,0,3); //pvp
			add_food(con_map,"- Hot Dog (Chilly Dog) ",12,0,3); //ml
			add_food(con_map,"- Hot Dog (Ghost Dog) ",12,0,3); //-combat
			add_food(con_map,"- Hot Dog (Junkyard Dog) ",12,0,3); //+combat
			add_food(con_map,"- Hot Dog (Wet Dog) ",12,0,3); //init
			add_food(con_map,"- Hot Dog (Optimal Dog) - forces semirare",4.5,0,1); //semirare
			add_food(con_map,"- Hot Dog (Sleeping Dog) ",9.5,0,2); //free rests
			add_food(con_map,"- Hot Dog (Video Games Hot Dog) ",13,0,3); //pixels items meat
		}
		if(available_amount($item[Exotic jungle fruit])>0)
			add_food(con_map,"- Exotic jungle fruit",2.5,0,1);
		if(available_amount($item[sandwich of the gods])>0)
			add_food(con_map,"- sandwich of the gods ",35,0,5);
		if(available_amount($item[root beer])>0)
			add_food(con_map,"- root beer ",4,0,1);
			
		
			
			
		if(available_amount($item[can of sardines])>0)
			add_food(con_map,"- can of sardines ",3.5,0,1);
		if(available_amount($item[Cold mashed potatoes])>0)
			add_food(con_map,"- Cold mashed potatoes ",3.5,0,1);
		if(available_amount($item[High-calorie sugar substitute])>0)
			add_food(con_map,"- High-calorie sugar substitute ",3.5,0,1);
		if(available_amount($item[Deviled egg])>0)
			add_food(con_map,"- Deviled egg ",5.5,0,1);
		if(available_amount($item[Dinner roll])>0)
			add_food(con_map,"- Dinner roll ",4,0,1);
		if(available_amount($item[pat of butter])>0)
			add_food(con_map,"- pat of butter ",3.5,0,1);
		if(available_amount($item[whole turkey leg])>0)
			add_food(con_map,"- whole turkey leg ",4.5,0,1);
		if(my_fullness() == 0 && (available_amount($item[spaghetti breakfast])>0 || (have_skill($skill[spaghetti breakfast]) && !get_property("_spaghettiBreakfast").to_boolean())))
			add_food(con_map,"- *** spaghetti breakfast (prefer to eat at higher levels, but must be first food of the day)",0.5 + 0.5 * my_level(),0,1);
		
		
		if(available_amount($item[Snow berries])>0 && (to_int(get_property("chasmBridgeProgress")) >= 30) && my_level()>=8)
			add_food(con_map,"- Snow berries ",2.5,0,1);
		if(available_amount($item[ice harvest])>0 && checkStage("bats1", false))
			add_food(con_map,"- Ice harvest ",2.5,0,1);
		if(available_amount($item[Snow berries])>2 && checkStage("bats1", false) && (to_int(get_property("chasmBridgeProgress")) >= 30) && my_level()>=8)
			add_food(con_map,"- Snow crab ",6,0,1);
	
		if(i_a("handful of smithereens")>0  || i_a("this charming flan")>0 || get_property("tomeSummons").to_int()<3)
			add_food(con_map,"- this charming flan (smithereens) ",11,0,2);
			
		if(available_amount($item[tea for one])>0)
			add_food(con_map,"- tea for one ",2.5,0,1);
		if(available_amount($item[Custard pie])>0)
			add_food(con_map,"- Custard pie ",8,0,3);
		if(available_amount($item[Candy carrot])>0)
			add_food(con_map,"- Candy carrot cake ",16,1,4);

		if(available_amount($item[Tofurkey nugget])>0)
			add_food(con_map,"- Tofurkey nugget ",7.5,0,3);
		if(available_amount($item[Packet of tofurkey gravy])>0)
			add_food(con_map,"- Packet of tofurkey gravy ",5,0,2);
		if(available_amount($item[Tofurkey gravy])>0)
			add_food(con_map,"- Tofurkey gravy ",6.5,0,2);
		if(available_amount($item[Tofurkey leg])>0)
			add_food(con_map,"- Tofurkey leg ",10.5,0,3);
		if(available_amount($item[Tube of cranberry Go-Goo])>0)
			add_food(con_map,"- Tube of cranberry Go-Goo ",10.5,0,3);
		if(available_amount($item[Can-shaped gelatinous cranberry sauce])>0)
			add_food(con_map,"- Can-shaped gelatinous cranberry sauce ",13,0,3);
		if(available_amount($item[Single-serving herbal stuffing])>0)
			add_food(con_map,"- Single-serving herbal stuffing ",14,0,4);
		if(available_amount($item[Herbal stuffing])>0)
			add_food(con_map,"- Herbal stuffing ",18,0,4);
			
		if(available_amount($item[incredible pizza])>0)
			add_food(con_map,"- incredible pizza ",13.5,0,4,true);
			
		if(available_amount($item[Sogg-Os])>0)
			add_food(con_map,"- Sogg-Os ",5,0,1);
			
		if(available_amount($item[Filet of The Fish])>0)
			add_food(con_map,"- Filet of The Fish ",99999,0,3);


		if(available_amount($item[magicberry tablets])>0)
			print("**Maybe use magicberry tablets before eating!**","purple");
	}
	
	//sort map
	sort con_map by -value.efficiency;
	//display results
	foreach key in con_map
	{
		print(con_map[key].text+" ("+con_map[key].efficiency+")","purple");
	}
}

void advise_drink(string woods_string, string beach_string, string manor_string)
{
	consumable [int] con_map;
	boolean bees_ok= (my_path() != "Bees hate you");

	if(my_inebriety()< inebriety_limit() && can_drink() && my_path()!="KOLHS")
	{
		print("","olive");
			
		print("--- Consider Drinking ---","olive");
		if(available_amount($item[crown of thrones])!=0)
		{
			print("(can get tequila from green pixie in crown of thrones)","olive");
		}
		print("(can get booze bottles from clovering frat house in disguise, barrels, noob cave, drunk goat)","olive");
		if(my_level()>4 && available_amount($item[wrecked generator])>0 || available_amount($item[lunar isotope])>99)
		{
			add_drink(con_map,"- Wrecked generator (brought from lunar launch o mat for 100 isotopes) ",30,0,5);
		}
		
		if(available_amount($item[pumpkin])>0 && bees_ok)
			add_drink(con_map,"Pumpkin beer ",5.5,0,1);
		
		if(available_amount($item[distilled fortified wine])>0 || (available_amount($item[thermos full of knob coffee])>0 && bees_ok))
			add_drink(con_map,"Semi-rare (distilled fortified wine/thermos full of knob coffee) ",5.5,0,1);
		
		if(available_amount($item[bottle of single-barrel whiskey])>0 || (available_amount($item[thermos full of knob coffee])>0 && bees_ok))
			add_drink(con_map,"bottle of single-barrel whiskey",16.5,0,3);
			
		if(my_path() != "Bees Hate You" && available_amount($item[filthy lucre])>0)
			add_drink(con_map,"- Oreille Divisée brandy from bounty hunter ",13.5,0,3);
		
		if(have_skill($skill[advanced cocktailcrafting]) && have_skill($skill[superhuman cocktailcrafting]) && (my_class()==$class[disco bandit] || my_class()==$class[accordion thief]))
			add_drink(con_map,"- use nash crosbys still to get: improved booze + improved mixer + cocktailcrafting reagent ",16,2,4);
		
		if(get_property("sidequestFarmCompleted")=="fratboy" && bees_ok)
			add_drink(con_map,"- Boilermaker, using mcmillicancuddys lager from frat army FGF ",13,0,4);
			
		if(available_amount($item[white xanadian])>0 ||  available_amount($item[shot of nepenthe schnapps])>0 || ( available_amount($item[bottle of realpagne])>0 && bees_ok))
			add_drink(con_map,"- worm wood booze (white xanadian/shot of nepenthe schnapps/bottle of realpagne) ",6.5,0,2);
		
		if(bees_ok && contains_text(woods_string,"blackforest.gif") && available_amount($item[black & tan])>1)
			add_drink(con_map,"- Black and Tan from black widow picnic baskets ",6.5,0,2);
		
		if(have_skill($skill[advanced cocktailcrafting]))
			add_drink(con_map,"- Booze + fruit + advanced cocktailcrafting reagent ",12,1,4);
		
		if(contains_text(beach_string,"oasis.gif") && available_amount($item[supernova champagne])>1)
			add_drink(con_map,"- Supernova champagne from oasis monster in oasis ",9,0,3);
			
		if(my_level()>11)
			add_drink(con_map,"- Upgraded hippy schnapps ",6,0,2);
		
		if(bees_ok && contains_text(manor_string,"sm8b.gif"))
			add_drink(con_map,"- Bottle of great dusty wine (snake label) ",6,0,2);
		
		if(my_level()>11)
			add_drink(con_map,"- booze from frat FGF or hippy MPE ",3,0,1);
		
		if(contains_text(woods_string,"grove.gif") && available_amount($item[white lightning])>0)
			add_drink(con_map,"- White lightning from whiteys grove noncom (makes you blind) ",7.5,0,3);
		
		if((have_outfit("swashbuckling outfit") || available_amount($item[pirate fledges])>0) && (available_amount($item[shot of rotgut])>0 || available_amount($item[cream stout])>0))
			add_drink(con_map,"- shot of rotgut from barrneys bar or cream stout from f'c'le ",2.5,0,1);
		
		if(my_level()>4 && available_amount($item[Cobb's Knob Wurstbrau])>0)
			add_drink(con_map,"- cobb's Cobb's Knob Wurstbrau from guards in cobbs knob barracks ",2.5,0,1);
		
		if(available_amount($item[handful of honey])>4 || available_amount($item[honey mead])>0)
			add_drink(con_map,"- Honey mead  (made with 4 handful of honey) ",5,0,2);
		
		if(have_skill($skill[advanced cocktailcrafting]))
			add_drink(con_map,"- make russian ice from vodka + ice cube reagent ",2.5,0,1);
		
		if(available_amount($item[cherry])>0 || available_amount($item[lime])>0 || available_amount($item[jumbo olive])>0)
			add_drink(con_map,"- fruit golem fruits (cherry/lime/jumbo olive) + spirits ",7.5,0,3);
		
		if((available_amount($item[Ye Wizard's Shack snack voucher])>0 || get_property("grimoire3Summons").to_int()==0) && my_path()!="Avatar of Boris")
		{
			add_drink(con_map,"- Sake from wizard shack (gives 30 turn damage buff. tobiko=spells, natto=weapons) ",7,0,3);
		}
		
		if(my_level()>3)
		{
			add_drink(con_map,"-    Elven Squeeze from transponders ",6.5,0,3);
		}
		if(my_level()>2 && available_amount($item[crown of thrones])!=0)
		{
			add_drink(con_map,"-    eggnog from sweet nutcracker in CoT ",7.5,0,3);
		}
		
		if(available_amount($item[Water purification pills])>0)
			add_drink(con_map,"- Water purification pills ",6,0,3);
		if(available_amount($item[CSA scoutmaster's &quot;water&quot;])>0)
			add_drink(con_map,"- CSA scoutmaster's &quot;water&quot; ",9,0,3);
		if(available_amount($item[CSA cheerfulness ration])>0)
			add_drink(con_map,"- CSA cheerfulness ration ",4,0,1);
		if(available_amount($item[peppermint sprout])>0)
			add_drink(con_map,"- peppermint + bottle of booze ",11.5,1,2);
		if(available_amount($item[skeleton])>4)
			add_drink(con_map,"- crystal skeleton vodka ",16,0,3);
		if(available_amount($item[carrot nose])>0)
			add_drink(con_map,"- carrot claret ",8.5,0,3);
		if(available_amount($item[open sauce])>0)
			add_drink(con_map,"- open sauce ",12,0,4);
		if(available_amount($item[imitation white russian])>0)
			add_drink(con_map,"- imitation white russian ",5,0,2);
		if(available_amount($item[pan-dimensional gargle blaster])>0)
			add_drink(con_map,"- pan-dimensional gargle blaster ",25,0,5);
			
		if(my_primestat()==$stat[muscle] && ((available_amount($item[handful of barley])>0 && available_amount($item[cluster of hops])>0) || available_amount($item[can of Br&uuml;talbr&auml;u])>0))
			add_drink(con_map,"- can of Br&uuml;talbr&auml;u ",6,0,1);
		if(my_primestat()==$stat[mysticality] && ((available_amount($item[handful of barley])>0 && available_amount($item[cluster of hops])>0) || available_amount($item[can of drooling monk])>0))
			add_drink(con_map,"- can of drooling monk ",6,0,1);
		if(my_primestat()==$stat[moxie] && ((available_amount($item[handful of barley])>0 && available_amount($item[cluster of hops])>0) || available_amount($item[can of impetuous scofflaw])>0))
			add_drink(con_map,"- can of impetuous scofflaw ",6,0,1);
			
		if(my_primestat()==$stat[muscle] && ((available_amount($item[handful of barley])>0 && available_amount($item[cluster of hops])>0 && available_amount($item[fancy beer bottle])>0 && available_amount($item[fancy beer label])>0) || available_amount($item[bottle of old pugilist])>0))
			add_drink(con_map,"- bottle of old pugilist ",12,0,2);
		if(my_primestat()==$stat[mysticality] && ((available_amount($item[handful of barley])>0 && available_amount($item[cluster of hops])>0 && available_amount($item[fancy beer bottle])>0 && available_amount($item[fancy beer label])>0) || available_amount($item[bottle of Professor Beer])>0))
			add_drink(con_map,"- bottle of Professor Beer ",12,0,2);
		if(my_primestat()==$stat[moxie] && ((available_amount($item[handful of barley])>0 && available_amount($item[cluster of hops])>0 && available_amount($item[fancy beer bottle])>0 && available_amount($item[fancy beer label])>0) || available_amount($item[bottle of Rapier Witbier])>0))
			add_drink(con_map,"- bottle of Rapier Witbier ",12,0,2);
			
		if(my_primestat()==$stat[muscle] && ((available_amount($item[handful of barley])>2 && available_amount($item[cluster of hops])>2 && available_amount($item[fancy beer bottle])>2 && available_amount($item[fancy beer label])>2) || available_amount($item[bottle of Race Car Red])>0))
			add_drink(con_map,"- bottle of Race Car Red (chance from artisanal homebrew gift package) ",20,0,3);
		if(my_primestat()==$stat[mysticality] && ((available_amount($item[handful of barley])>2 && available_amount($item[cluster of hops])>2 && available_amount($item[fancy beer bottle])>2 && available_amount($item[fancy beer label])>2) || available_amount($item[bottle of Greedy Dog])>0))
			add_drink(con_map,"- bottle of Greedy Dog (chance from artisanal homebrew gift package) ",20,0,3);
		if(my_primestat()==$stat[moxie] && ((available_amount($item[handful of barley])>2 && available_amount($item[cluster of hops])>2 && available_amount($item[fancy beer bottle])>2 && available_amount($item[fancy beer label])>2) || available_amount($item[bottle of Lambada Lambic])>0))
			add_drink(con_map,"- bottle of Lambada Lambic (chance from artisanal homebrew gift package) ",20,0,3);
			
		
		if(available_amount($item[cold one])>0 || (have_skill($skill[grab a cold one]) && !get_property("_coldOne").to_boolean()))
			add_drink(con_map,"- cold one (prefer to drink at higher levels)",6,0,1);
		if(i_a("handful of smithereens")>0  || i_a("Paint A Vulgar Pitcher")>0 || get_property("tomeSummons").to_int()<3)
			add_drink(con_map,"- Paint A Vulgar Pitcher (smithereens) ",11,0,2);
			
		if(available_amount($item[Snow berries])>0 && available_amount($item[ice harvest])>2)
			add_drink(con_map,"- Ice Island Long Tea ",6,0,4);
			
		if(available_amount($item[Unnamed cocktail])>0)
			add_drink(con_map,"- unnamed cocktail ",5,0,2);
			
		if(available_amount($item[Flamin' Whatshisname])>0)
			add_drink(con_map,"-Flamin' Whatshisname ",6,0,2);
			
		if(available_amount($item[Bottle of Evermore])>0)
			add_drink(con_map,"-Bottle of Evermore ",6,0,3);
			
		if(available_amount($item[red rum])>0 || available_amount($item[murderer's punch])>0 )
			add_drink(con_map,"- make a murderers punch from red rum and orange",9,1,3);
			
		if(available_amount($item[Wet Russian])>0)
			add_drink(con_map,"- Wet Russian",13,0,3);
	}
	//sort map
	sort con_map by -value.efficiency;
	//display results
	foreach key in con_map
	{
		print(con_map[key].text+" ("+con_map[key].efficiency+")","olive");
	}
}

void advise_spleen()
{
	if(my_spleen_use()< spleen_limit())
	{
		print("","gray");
		print("--- Consider Spleening ---","gray");
		if(available_amount($item[guy made of bee pollen])>0 && spleen_limit()-my_spleen_use()>=3)
			print("- guy made of bee pollen (2.83)","gray");
		if(spleen_limit()-my_spleen_use()>=4)
		{
			print("- glimmering roc feather, from gonging birdform (requires 15 turns of no olfaction/noodlebutt combat) (2.0 and stats)","gray");			
			print("- collect pastes from stomping boots (1.875 and stats), stomp noob cave","gray");
			print("- collect coffee pixie sticks from rogue program (1.875)","gray");
			if(my_path() != "Bees Hate You")
			{
				print("- collect agua de vida drops from baby sandworm (1.875)","gray");
				print("- collect not-a-pipe using green pixie drops (1.5 with mp and stats)","gray");
			}
		}
		if(spleen_limit()-my_spleen_use()==3 && !can_interact() && !in_hardcore())
		{
			print("- pull mojo filter and use another 4 spleen item","gray");
		}
		if(my_level()>9)
		{
			print("- Fill up with wads from pulverizing (1.0)","gray");
		}
		if(i_a("handful of smithereens")>0  || get_property("tomeSummons").to_int()<3)
			print("- handfuls of smithereens (1.5)","gray");
	}
}

void advise_semirare(string completed_log)
{
	string counters = get_counters("Fortune Cookie", 0, 60);
	if(counters == "")
		return;
			
	boolean bees_ok = (my_path() != "Bees hate you");
	print("","aqua");
	print("----- Semirare Choices -----","aqua");
	
	if(get_property("sidequestOrchardCompleted")=="none" && get_property("semirareLocation")!="Limerick Dungeon" && my_basestat(my_primestat())>20)
		print("- Cyclops eyedrops from limerick dungeon.","aqua");
	
	if(my_path()!="Way of the Surprising Fist" && get_property("sidequestNunsCompleted")=="none" && get_property("semirareLocation")!="Giant's Castle" && (available_amount($item[intragalactic rowboat])>0 || available_amount($item[S.O.C.K.])>0 ))
		print("- Inhaler from giant castle.","aqua");
	
	if(get_property("semirareLocation")!="Cobb's knob harem" && my_level()>4)
		print("- Scented massage oil in cobbs knob harem.","aqua");
	
	int needed_334=0;
	int needed_30669=0;
	int needed_33398=0;
	if(!contains_text(completed_log,"You have helped the Baron Rof L"))
	{
		needed_334+=2;
		needed_30669+=1;
		needed_33398+=1;
	}
	if(get_property("hermitHax0red")=="false")
	{
		needed_334+=2;
		needed_30669+=1;
	}
	if(needed_334>0 && my_level()>7 && get_property("semirareLocation")!="Orc Chasm")
		print("- Bad ascii art (putty/bad romance).","aqua");
	
	if(get_property("semirareLocation")!="Cobb's Knob Outskirts" && bees_ok)
		print("- food/drink semirare at cobbs knob outskirts","aqua");
	else
		print("- food/drink semirare at sleazy back alley/haunted pantry","aqua");
}

boolean quartet_correct()
{
	int cur_asc=to_int(get_property("knownAscensions"));
	int quartet_asc=to_int(get_property("lastQuartetAscension"));
	if(cur_asc==quartet_asc)
	{
		int quartet_setting=to_int(get_property("lastQuartetRequest"));
		if(quartet_setting==2)
		{
			return true;
		}
	}
	return false;
}

boolean have_staff()
{
	if(available_amount($item[staff of fats])>0)
		return true;
	if(available_amount($item[staff of ed, almost])>0)
		return true;
	if(available_amount($item[staff of ed])>0)
		return true;
	return false;
}

boolean simons_have_eye()
{
	if(available_amount($item[eye of ed])>0)
		return true;
	if(available_amount($item[headpiece of the Staff of Ed])>0)
		return true;
	if(available_amount($item[staff of ed])>0)
		return true;
	return false;
}

boolean have_war_outfit()
{
	if(have_outfit("frat warrior fatigues"))
		return true;
	if(have_outfit("war hippy fatigues"))
		return true;
	return false;
}

boolean have_guitar()
{
	if(available_amount($item[acoustic guitarrr])>0)
		return true;
	if(available_amount($item[heavy metal thunderrr guitarrr])>0)
		return true;
	if(available_amount($item[stone banjo])>0)
		return true;
	if(available_amount($item[Disco Banjo])>0)
		return true;
	if(available_amount($item[Shagadelic Disco Banjo])>0)
		return true;
	if(available_amount($item[Seeger's Unstoppable Banjo])>0)
		return true;
	if(available_amount($item[Crimbo ukulele])>0)
		return true;
	if(available_amount($item[Massive sitar])>0)
		return true;
	if(available_amount($item[4-dimensional guitar])>0)
		return true;
	if(available_amount($item[plastic guitar])>0)
		return true;
	if(available_amount($item[half-sized guitar])>0)
		return true;
	if(available_amount($item[out-of-tune biwa])>0)
		return true;
	if(available_amount($item[Zim Merman's guitar])>0)
		return true;
	if(available_amount($item[dueling banjo])>0)
		return true;
		
	return false;
}

boolean have_drum()
{
	if(available_amount($item[tambourine])>0)
		return true;
	if(available_amount($item[big bass drum])>0)
		return true;
	if(available_amount($item[black kettle drum])>0)
		return true;
	if(available_amount($item[bone rattle])>0)
		return true;
	if(available_amount($item[hippy bongo])>0)
		return true;
	if(available_amount($item[jungle drum])>0)
		return true;
		
	return false;
}

void advise_banish(string mob)
{
	//check if creepy grin already used?
	if((available_amount($item[v for vivala mask])>0) ||available_amount($item[divine champagne popper])>0 || (available_amount($item[harold's bell])>0 && my_path() != "Bees hate you") || available_amount($item[crystal skull])>0)
	{
		print("-    Use champagne popper/crystal skull/harolds bell/creepy grin to banish "+mob,"green");
	}
}

void advise_summon()
{
	if(my_path()!="Avatar of Boris" && get_property("tomeSummons").to_int()<3)
	{
		print("","black");
		
		print("----- Consider Summoning (after consumables)","black");
		if(my_level()<10 && my_primestat()==$stat[mysticality])
			print("-    potion of the field gar to improve sack lunch lasagnas (wine,cat,cat)","black");
		if(available_amount($item[bucket of wine])<1 && in_hardcore())
			print("-    bucket of wine as nightcap (wine,wine,wine)","black");
		if(available_amount($item[toasted brie])<1 && in_hardcore())
			print("-    toasted brie to improve bucket of wine nightcap by 20% (cheese,cheese,bulb)","black");
		if(available_amount($item[time halo])<1)
			print("-    time halo +5 adv (donut,clock,clock)","black");
		if(available_amount($item[aquaviolet jub-jub bird])<1  && available_amount($item[charpuce jub-jub bird])<1 && available_amount($item[crimsilion jub-jub bird])<1)
			print("-    familiar jacks and use with bandersnatch(cat,cat,cat)","black");
		if(available_amount($item[quadroculars])<1)
			print("-    familiar jacks and use with he boulder(cat,cat,cat)","black");
		if(available_amount($item[microwave stogie])<1 && in_hardcore())
			print("-    familiar jacks and use with organ grinder (cat,cat,cat)","black");
		if(available_amount($item[furry halo])<1)
			print("-    furry halo for more runaways (donut,cat,cat)","black");
		if(my_level()<6)
			print("-    borrowed time (clock,clock,clock)","black");
		if(my_path()=="Way of the Surprising Fist")
		{
			if(available_amount($item[shining halo])<1)
				print("-    shiny halo +3 stats per fight (donut,bulb,bulb)","black");
			if(available_amount($item[frosty halo])<1)
				print("-    frost halo +25% items (donut,snow,snow)","black");
		}
		if(my_path()!="Way of the Surprising Fist" && (available_amount($item[scratch 'n' sniff unicorn sticker])<3 || available_amount($item[scratch 'n' sniff upc sticker])<3))
		{
			print("-    summon stickers","black");
		}
		if(available_amount($item[sugar sheet])<3)
		{
			print("-    summon sugar sheets","black");
		}
		if(my_path()=="Way of the Surprising Fist")
		{
			print("-    potion of the captains hammer (+50 unarmed damage, 20 turns) (wine,hammer,hammer)","black");
		}
		print("-    box of hammers for 30 each stat (hammer,hammer,hammer)","black");
		print("-    clock cleaning hammer (1h club weapon, 50 power) (hammer,hammer,clock)","black");
		print("-    crystal skull to banish (skull,skull,skull)","black");
	}
}

void advise_main_goal()
{
	print("","lime");
	print("----- Main Goal -----","lime");
	if(my_level()==1)
	{
		print("- Initial leveling, eat ur-donut, use yellow and (high weight) red rays.","lime");
		return;
	}
	if(!have_skill($skill[liver of steel]) && !have_skill($skill[stomach of steel]) && !have_skill($skill[spleen of steel]))
	{
		print("- Level 6, Friars Quest, Azazel in hell. For steel organ.","lime");
		return;
	}
	if(available_amount($item[glass of goat's milk])<1 && available_amount($item[milk of magnesium])<1)
	{
		print("- Level 8, Mining outfit + mine ore, Farm goatlet for goats milk to make milk of magnesium.","lime");
		return;
	}
	if(!have_outfit("filthy hippy") || available_amount($item[dingy dinghy])<1)
	{
		print("- Dingy dinghy + hippy outfit to open hippy store.","lime");
		return;
	}
	
	if(my_path() != "Bees hate you" && !have_skill($skill[inigo's incantation of inspiration]) && ((have_skill($skill[advanced cocktailcrafting]) && !simons_have_bartender() && can_drink()) || (can_cook_fancy() && !simons_have_chef()&& can_eat())))
	{
		print("- Get in the boxen, from tower+cemetary+fun house (clovers).","lime");
		return;
	}
	

}

void advise_pie(string mob)
{
	if(my_path() != "Bees hate you")
		print("_________________ (Badass pie can be made here, from "+mob+")","green");
}

void advise_feathers()
{
	if(available_amount($item[tasty louse])>4)
		print("(convert tasty louse to feather for +20 ML and +5% moxie)","green");
	if(available_amount($item[scrumptious ice ant])>4)
		print("(convert scrumptious ice ant to feather for 40 HP+MP per fight)","green");
		
	if(my_path() == "Bees hate you")
		return;
		
	if(available_amount($item[delicious stinkbug])>4)
		print("(convert delicious stinkbug to feather for 60% meat)","green");
	if(available_amount($item[delectable fire ant])>4)
		print("(convert delectable fire ant to feather for 6 stats per fight)","green");
	if(available_amount($item[yummy death watch beetle])>4)
		print("(convert yummy death watch beetle to feather for +60% items)","green");
		
}

void advise_stat_boosters(boolean consider_pill)
{
	boolean bees_ok = ( my_path() != "Bees hate you");
	if(available_amount($item[badass pie])>0 && bees_ok && (fullness_limit()- my_fullness()>2) )
		print(",,,,,,,,,,,,,,,,, (consider using badass pie)","green");
	if(available_amount($item[bittersweettarts])>0 && bees_ok)
		print(",,,,,,,,,,,,,,,,, (consider using bittersweettarts)","green");
	if(available_amount($item[white candy heart])>0)
		print(",,,,,,,,,,,,,,,,, (consider using white candy heart)","green");
	if(available_amount($item[flavored foot massage oil])>0)
		print(",,,,,,,,,,,,,,,,, (consider using flavored foot massage oil)","green");
	if(available_amount($item[glimmering phoenix feather])>0 && (spleen_limit()> my_spleen_use()) )
		print(",,,,,,,,,,,,,,,,, (consider using glimmering phoenix feather)","green");
		
	int cur_asc=to_int(get_property("knownAscensions"));
	int dispens_asc=to_int(get_property("lastDispensaryOpen"));
	if(consider_pill && bees_ok && (cur_asc!=dispens_asc))
		print(",,,,,,,,,,,,,,,,, (consider using knob goblin learning pill)","green");
}


void main()
{
/*	council();

	string completed_log=visit_url_non_abort("questlog.php?which=2");
	string incomplete_log=visit_url_non_abort("questlog.php?which=1");
	string special_log=visit_url_non_abort("questlog.php?which=3");
	string telescope=visit_url_non_abort("campground.php?action=telescopelow");
*/	string woods_string=visit_url_non_abort("woods.php");
//	string plains_string=visit_url_non_abort("plains.php");
//	string main_string=visit_url_non_abort("main.php");
	string beach_string=visit_url_non_abort("beach.php");
	string manor_string=visit_url_non_abort("manor.php");
/*	string manor2_string=visit_url_non_abort("manor3.php");
	string pyramid_string=visit_url_non_abort("pyramid.php");
	string island_string=visit_url_non_abort("island.php");
	string trapper_string=visit_url_non_abort("trapper.php");
	string chamber_string=visit_url_non_abort("lair6.php");
	string hermit_string=visit_url_non_abort("hermit.php");
	string cyrpt_string=visit_url_non_abort("cyrpt.php");
	
	boolean fcle_open=false;
	if(my_buffedstat(my_primestat())>86)
	{
		fcle_open = fcle_available();
	}
	
	string charpane_string=visit_url_non_abort("charpane.php");
	int clancy_level=0;
	if(my_path()=="Avatar of Boris")
	{
		//read clancys level
		matcher clancy_lev_mtch = create_matcher("Level <b>(\\d*)</b>\\s*Minstrel",charpane_string);
		find(clancy_lev_mtch);
		clancy_level=group(clancy_lev_mtch,1).to_int();
		if(have_skill($skill[more to love]))
			clancy_level=clancy_level-3;
		if(have_effect($effect[Song of Accompaniment])>0)
			clancy_level=clancy_level-3;
		print("Clancy is base level "+clancy_level);
		
		//and note his instrument
		if(contains_text(charpane_string,"clancy_3")) //lute
		{
			clancy_instrument=$item[clancy's lute];
		}
		else if(contains_text(charpane_string,"clancy_2")) //crumhorn
		{
			clancy_instrument=$item[clancy's crumhorn];
		}
		else //sackbut
		{
			clancy_instrument=$item[clancy's sackbut];
		}
		print("Clancy has a "+clancy_instrument+" equipped.");
	}
	*/
	print("------------------------------------------------------------------------------------------------------------------------------","red");

	advise_food();
	advise_drink(woods_string, beach_string, manor_string);
	advise_spleen();
	advise_summon();
/*	advise_yellow_ray(completed_log,woods_string);
	advise_fax(completed_log,manor_string,manor2_string);
	advise_semirare(completed_log);*/
	advise_pulls(woods_string);
/*	advise_main_goal();
	
	
	print("","green");
	print("--- Current Quest Goals ---","green");
	advise_feathers();
//	if(available_amount($item[pretty flower])<10 && !check_page("pvp.php","may not participate in any more player fights") && (can_eat() || can_drink()))
//	{
//		print("- Pvp for flowers.","green");
//	}
	if(my_meat()>1000 && !contains_text(hermit_string,"out of stock for today"))
		print("- Grab clovers from hermit.","green");
	if(!contains_text(visit_url("town_right.php"),"manor.gif"))
	{
		print("- Discover spookyraven manor.","green");
		suggest_fam("delay", 0);
	}
	if(my_class()==$class[pastamancer] && get_property("pastamancerGhostType")!="Spice Ghost" && contains_text(visit_url("town_right.php"),"manor.gif"))
	{
		print("- Get a spice ghost from spooky kitchen.","green");
		suggest_fam("delay", 0);
	}
	if(available_amount($item[razor-sharp can lid])<1 && contains_text(telescope,"giant cuticle"))
	{
		print("- Pick up a can lid for tower.","green");
		suggest_fam("items", 1);
	}
	if(available_amount($item[spider web])<1 && contains_text(telescope,"translucent wing"))
	{
		print("- Pick up a spider web for tower.","green");
		suggest_fam("items", 1);
	}
	if(available_amount($item[knob goblin firecracker])<1 && contains_text(telescope,"long coattails"))
	{
		print("- Pick up a firecracker for tower.","green");
		suggest_fam("items", 1);
	}
	if(available_amount($item[knob goblin encryption key])<1 && contains_text(plains_string,"knob1.gif"))
	{
		print("- Get Knob encryption key","green");
		suggest_fam("none", 0);
	}
	if(available_amount($item[leftovers of indeterminate origin])<1 && contains_text(telescope,"holding a spatula"))
	{
		print("- Pick up a leftovers of indeterminate origin for tower.","green");
		suggest_fam("items", 0);
	}
//	if(!simons_have_chef() && available_amount($item[chef hat])<1 && available_amount($item[chef skull])<1 && can_cook_fancy() && can_eat() && my_path() != "Bees Hate You")
//	{
//		print("- Pick up a chef hat at knob goblin outskirts.","green");
//		suggest_fam("items", 1);
//	}
	if(my_path()=="Way of the Surprising Fist" && get_property("fistSkillsKnown").to_int()==0)
	{
		print("- Get 1st teachings of the fist at The Haiku Dungeon.","green");
	}
	if(my_path()=="Way of the Surprising Fist" && get_property("fistSkillsKnown").to_int()==1)
	{
		print("- Get 2nd teachings of the fist at A Barroom Brawl.","green");
	}
	if(my_path()=="Way of the Surprising Fist" && get_property("fistSkillsKnown").to_int()==2)
	{
		print("- Get 3rd teachings of the fist at Entryway.","green");
	}
	if(my_path()=="Way of the Surprising Fist" && get_property("fistSkillsKnown").to_int()==3)
	{
		print("- Get 4th teachings of the fist at Pandamonium Slums.","green");
	}
	if(my_path()=="Way of the Surprising Fist" && get_property("fistSkillsKnown").to_int()==4)
	{
		if(my_primestat()==$stat[muscle])
			print("- Get 5th teachings of the fist at The Haunted Conservatory.","green");
		else
			print("- Get 5th teachings of the fist at Orcish Frat House.","green");
	}
	if(!contains_text(completed_log,"I Think I Smell a Bat") && (available_amount($item[asshat])<1 && available_amount($item[bum cheek])<1 && available_amount($item[pine-fresh air freshener])<1) && !have_skill($skill[astral shell]) && !have_skill($skill[Legendary Girth]))
	{
		print("- Pick up a bum cheek.","green");
		suggest_fam("items", 1);
	}
	if(!contains_text(completed_log,"Suffering For His Art"))
	{
		print("- Finish artist quest.","green");
		suggest_fam("runaways", 0);
	}
	if(my_path()!="Way of the Surprising Fist" && my_path()!="Avatar of Boris")
	{
		int needed_rocks=0;
		if(!have_epic_or_higher())
		{
			print("- Make epic weapon from big rock + hermit.","green");
			needed_rocks+=1;
		}
		if(my_class()!=$class[accordion thief] && available_amount($item[rock and roll legend])<1)
		{
			print("- Make rock and roll legend (for AT buffs) from big rock + hermit.","green");
			needed_rocks+=1;
		}
		if(my_class()!=$class[turtle tamer] && available_amount($item[mace of the tortoise])<1 && have_skill($skill[astral shell]))
		{
			print("- Make mace of the tortoise (for TT buffs) from big rock + hermit.","green");
			needed_rocks+=1;
		}
		if(my_class()!=$class[sauceror] && available_amount($item[5-alarm saucepan])<1 && have_skill($skill[Jabanero Saucesphere]))
		{
			print("- Make 5-alarm saucepan (for SA buffs) from big rock + hermit.","green");
			needed_rocks+=1;
		}
		if(available_amount($item[big rock])<needed_rocks)
		{
			print("- Get "+needed_rocks+" more big rocks from the casino for above.","green");
			if(!knoll_available() && available_amount($item[loathing legion jackhammer])>0)
				print("(fold loathing legion jackhammer for crafting)","green");
		}
	}
	int needed_keys=2;
	if(my_path()=="Way of the Surprising Fist")
		needed_keys=3;
	int have_keys=(available_amount($item[jarlsberg's key])+available_amount($item[boris's key])+available_amount($item[sneaky pete's key]));
	if(get_property("dailyDungeonDone")!="true" && !(my_buffedstat($stat[moxie])<40 || my_buffedstat($stat[muscle])<40 || my_buffedstat($stat[mysticality])<40) && have_keys<needed_keys)
	{
		print("- Do the Daily Dungeon.","green");
		suggest_fam("none", 0);
	}
	if(my_level()>=2 && !contains_text(completed_log,"Looking for a Larva"))
	{
		print("- Do mosquito quest.","green");
		suggest_fam("runaways", -1);
	}
	if(my_level()>=2 && !contains_text(woods_string,"temple.gif"))
	{
		print("- Open hidden temple.","green");
		suggest_fam("runaways", -1);
	}
	if(my_level()>=2 && my_level()<9 && available_amount($item[spooky mushroom])<1 && can_eat())
	{
		print("- Get a spooky mushroom for eventual grue omellette, from spooky forest.","green");
		if(available_amount($item[crown of thrones])>0)
			print("(fight with astral badger in crown to get it easier)","green");
		suggest_fam("runaways", -1);
	}
	if(my_buffedstat(my_primestat())>16 && !contains_text(completed_log,"Driven Crazy") && available_amount($item[loathing legion screwdriver])==0)
	{
		print("- Do untinker (olfact gearheads if poss).","green");
		suggest_fam("runaways", 0);
	}
	if(my_level()>2 && !contains_text(completed_log,"I Think I Smell a Rat"))
	{
		print("- Do Tavern.","green");
		suggest_fam("none", 0);
	}
	if(my_level()>2 && my_path()=="Avatar of Boris" && clancy_level<2)
	{
		print("- Go to barroom brawl for clancy.","green");
		suggest_fam("none", -1);
	}
	if(my_buffedstat(my_primestat())>16 && !contains_text(main_string,"map7beach.gif"))
	{
		print("- make meat car.","green");
		suggest_fam("items", 0);
	}
	if(contains_text(main_string,"map7beach.gif") && !knoll_available() && !have_outfit("bugbear costume"))
	{
		print("- Get bugbear outfit for bakery access (best is haiku dungeon, but can also go to fun house and get box at same time).","green");
		suggest_fam("items", 1);
	}
	if(!contains_text(main_string,"island.gif") && contains_text(main_string,"map7beach.gif"))
	{
		print("- make dinghy (try for stair item).","green");
	}
	if(available_amount($item[tropical orchid])<1 && contains_text(main_string,"map7beach.gif") &&  contains_text(telescope,"formidable stinger"))
	{
		print("- Get tropical orchid for tower.","green");
	}
	if(available_amount($item[stick of dynamite])<1 && contains_text(main_string,"map7beach.gif") &&  contains_text(telescope,"wooden beam	"))
	{
		print("- Get stick of dynamite for tower.","green");
	}
	if(available_amount($item[barbed wire fence])<1 && contains_text(main_string,"map7beach.gif") &&  contains_text(telescope,"pair of horns"))
	{
		print("- Get barbed wire fence for tower.","green");
	}
	if(contains_text(visit_url("woods.php"),"tavern0.gif") && have_skill($skill[advanced cocktailcrafting]) && simons_have_bartender() &&  available_amount($item[beer lens])<2 && available_amount($item[beer goggles])<1)
	{
		print("- Get beer goggles from barroom brawl in tavern.","green");
		advise_stat_boosters(false);
		suggest_fam("items", 0);
	}
	if(my_buffedstat(my_primestat())>27 && available_amount($item[spookyraven library key])<1)
	{
		print("- Get spookyraven library key.","green");
		suggest_fam("runaways", 0);
	}
	if(my_buffedstat(my_primestat())>28 &&  available_amount($item[mariachi g string])<1 && contains_text(telescope,"huge bass guitar"))
	{
		print("- Get mariachi g string (olfact irate mariachi?).","green");
		suggest_fam("items", 1);
	}
	if(my_buffedstat(my_primestat())>21  && !contains_text(visit_url("bathole.php"),"bathole_4.gif") && !contains_text(visit_url("bathole.php"),"bathole_5.gif"))
	{
		if(available_amount($item[sonar-in-a-biscuit])<1 && my_path() != "Bees hate you")
		{
			print("- Get sonars (maybe clover it)","green");
			suggest_fam("items", 0);
		}
		if(my_path() == "Bees hate you")
		{
			print("- Fight screambats (every 8 kills)","green");
			suggest_fam("delay", 0);
		}
		print("- Open boss bat lair.","green");
		advise_stat_boosters(false);
	}
	if(my_buffedstat(my_primestat())>21 && !contains_text(completed_log,"I Smell a Bat"))
	{
		print("- Kill boss bat.","green");
		advise_pie("boss bat");
		advise_stat_boosters(false);
		suggest_fam("meat", 0);
	}
	if(my_buffedstat(my_primestat())>21 &&  available_amount($item[sonar-in-a-biscuit])<1 && contains_text(telescope,"looking tophat"))
	{
		print("- Get sonar for tower.","green");
		suggest_fam("items", 0);
	}
	if(my_buffedstat(my_primestat())>21 &&  available_amount($item[baseball])<1 && contains_text(telescope,"baseball bat"))
	{
		print("- Get baseball for tower.","green");
		suggest_fam("items", 0);
	}
//	if(my_path() != "Bees Hate You" && my_buffedstat(my_primestat())>23 && ((have_skill($skill[advanced cocktailcrafting]) && !simons_have_bartender() && can_drink()) || (can_cook_fancy() && !simons_have_chef()&& can_eat())) &&  available_amount($item[box])<1)
//	{
//		print("- Get box for in-the-boxen (clover?).","green");
//		suggest_fam("items", 0);
//	}
//	 not going to make LEW anymore, waste of turns if i havbe good gear
//	if(my_buffedstat(my_primestat())>23 && !have_legendary_or_higher())
//	{
//		print("- Kill beelzebozo for LEW.","green");
//		suggest_fam("combat", 0);
//	}
// also not going for in the boxen
//	if(my_buffedstat(my_primestat())>23 && !contains_text(plains_string,"ruins.gif") && my_path() != "Bees Hate You")
//	{
//		print("- Unlock tower in misspelled cemetary (collect spooky bugs).","green");
//		advise_stat_boosters(false);
//		suggest_fam("none", 0);
//	}
//	if(my_path() != "Bees Hate You" && contains_text(completed_log,"Cyrptic Emanations") && ((have_skill($skill[advanced cocktailcrafting]) && (!simons_have_bartender() &&  available_amount($item[bartender skull])<1) && can_drink()) || (can_cook_fancy() && !simons_have_chef() &&  available_amount($item[chef skull])<1 && can_eat())) &&  available_amount($item[smart skull])<1 &&  available_amount($item[brainy skull])<1)
//	{
//		print("- Get skull for in-the-boxen (maybe clover it).","green");
//		advise_stat_boosters(false);
//		suggest_fam("items", 0);
//	}
//	if(((have_skill($skill[advanced cocktailcrafting]) && (!simons_have_bartender() &&  available_amount($item[bartender skull])<1 && can_drink())) || (can_cook_fancy() && !simons_have_chef() &&  available_amount($item[chef skull])<1 && can_eat())) &&  available_amount($item[disembodied brain])<1 &&  available_amount($item[brainy skull])<1 && my_path() != "Bees Hate You")
//	{
//		print("- Get brain for in-the-boxen (maybe clover it, else olfact brainsweeper).","green");
//		advise_stat_boosters(false);
//		suggest_fam("items", 0);
//	}
	if(my_buffedstat(my_primestat())>25 && !contains_text(plains_string,"beanstalk.gif") && available_amount($item[enchanted bean])<1)
	{
		print("- Get enchanted bean for bean stalk.","green");
		suggest_fam("items", 0);
	}
	if(my_buffedstat(my_primestat())>28 && available_amount($item[digital key])<1 && available_amount($item[white pixel])<30 && my_maxmp()>40)
	{
		print("- Olfact bloopers in 8 bit realm (use runaways until sniffed)","green");
		if(my_class()==$class[turtle tamer] && my_path() != "Bees hate you")
		{
			print("        And use turtle pheromones","green");
		}
		advise_banish("Bullet Bill");
		advise_stat_boosters(false);
		suggest_fam("items", 0);
	}
	if(my_buffedstat(my_primestat())>33 && !contains_text(completed_log,"The Goblin Who Wouldn"))
	{
		if(my_path()!="Bees hate you" && my_path()!="Way of the Surprising Fist" && my_path()!="Avatar of Boris")
		{
			if(!have_outfit("knob goblin elite guard"))
			{
				print("- Get Knob goblin elite guard outfit from barracks.","green");
				suggest_fam("items", 0);
			}
			if(available_amount($item[knob cake])<1)
			{
				print("- Bake a Knob Cake (fancy food).","green");
			}
		}
		else
		{
			if(!have_outfit("knob goblin harem girl"))
			{
				print("- Get Knob goblin harem girl outfit from harem.","green");
				suggest_fam("items", 0);
			}
		}
	}
	if(my_level()>4 && contains_text(telescope,"tall wooden frame") && available_amount($item[disease])<1)
	{
		print("- Disease from harem girls in cobbs knob harem for tower.","green");
	}
	if(my_buffedstat(my_primestat())>55 && !contains_text(completed_log,"The Goblin Who Wouldn") && (have_outfit("harem") || have_outfit("knob goblin elite guard") ))
	{
		print("- Kill knob king (remember cake/perfume).","green");
		advise_pie("knob king");
		suggest_fam("combat", 0);
	}
	if(contains_text(main_string,"map7beach.gif") && available_amount($item[crumhorn])<1 && my_meat()>2500 && my_path()=="Avatar of Boris" && clancy_instrument!=$item[clancy's crumhorn])
	{
		print("- Buy crumhorn from uncle p.","green");
		suggest_fam("none", -1);
	}
	if(available_amount($item[cobb's knob lab key])>0  && my_path()=="Avatar of Boris" && clancy_level<3)
	{
		print("- Go to knob shaft for clancy.","green");
		suggest_fam("none", -1);
	}
	if(my_path()=="Way of the Surprising Fist" && have_outfit("knob goblin harem girl")) //detect when daily wages taken
		print("- Get daily salary from knob treasury in harem outfit.","green");
	
	
	int cur_asc=to_int(get_property("knownAscensions"));
	int dispens_asc=to_int(get_property("lastDispensaryOpen"));
	if(have_outfit("knob goblin elite guard") && available_amount($item[cobb's knob lab key])>0 && cur_asc!=dispens_asc && my_path()!="Bees hate you")
	{
		print("- Go to barracks in KGE disguise for dispensary password.","green");
	}
	if(my_buffedstat(my_primestat())>40 && available_amount($item[mega gem])<1 && ((available_amount($item[bird rib])<1 || available_amount($item[lion oil])<1) && available_amount($item[wet stew])<1) && available_amount($item[wet stunt nut stew])<1)
	{
		print("- Get wet stew ingredients from whiteys grove.","green");
		if(available_amount($item[mullet wig])<1)
		{
			print("(and mullet wig for infiltrationist).","green");
		}
		suggest_fam("items", 1);
	}
	
//	 trying to leave these outfits to level 9 now
//	if(my_buffedstat(my_primestat())>40 && contains_text(woods_string,"wcroad.gif"))
//	{
//		print("- Open white citadel (yellow ray or olfact hippy).","green");
//		if(my_path() == "Bees hate you")
//			print(" (Also need frat outfit).","green");
//		suggest_fam("items", 1);
//	}
//	if(contains_text(woods_string,"wcstore.gif") && !have_outfit("filthy hippy"))
//	{
//		print("- Get hippy outfit  (Yellow ray is a good idea, else with flytrap).","green");
//	}
//	if(contains_text(woods_string,"wcstore.gif") && !have_outfit("frat boy ensemble") && my_path() == "Bees hate you")
//	{
//		print("- Get frat outfit.","green");
//	}
	if(my_level()>6  && my_path()=="Avatar of Boris" && available_amount($item[clancy's lute])<1 && clancy_instrument!=$item[clancy's lute])
	{
		print("- Go to luters grave for clancy.","green");
		suggest_fam("none", 0);
	}
	if(my_level()>6 && !contains_text(completed_log,"Cyrptic Emanations"))
	{
		print("- Do Cyrpt quest (collect spooky bugs).","green");
		advise_pie("4 subbosses + bonerdagon");
		if(contains_text(cyrpt_string,"lr.gif"))
		{
			print("- Alcove: Maximize initiative, use peppermint twist(badly romance modern zmobie) USE HIPSTER.","green");
			advise_stat_boosters(true);
			if(available_amount($item[crown of thrones])>0)
				print("(cotton candy carnie in crown of thrones)","green");
			suggest_fam("none", 0);
		}
		if(contains_text(cyrpt_string,"ur.gif"))
		{
			print("- Niche: Olfact dirty old lihc (runaways until sniffed).","green");
			advise_stat_boosters(true);
			suggest_fam("none", 0);
		}
		if(contains_text(cyrpt_string,"ul.gif"))
		{
			print("- Nook: Maximize item drops.","green");
			advise_stat_boosters(false);
			suggest_fam("items", 0);
		}
		if(contains_text(cyrpt_string,"ll.gif"))
		{
			print("- Cranny: Maximize noncombats and ML.","green");
			advise_stat_boosters(false);
			suggest_fam("none", -1);
		}
	}
	if(contains_text(completed_log,"Cyrptic Emanations") && available_amount($item[skeleton key])<1)
	{
		print("- Get skeleton bone/loose teeth in cemetery then make a skeleton key.","green");
		suggest_fam("items", 0);
	}
	if(my_level()>5 && !contains_text(completed_log,"Trial By Friar"))
	{
		print("- Do friar quest, olfact hellion in neck (runaways until sniffed) (collect fire bugs).","green");
		suggest_fam("none", 0);
	}
	if(contains_text(completed_log,"Trial By Friar") && (available_amount($item[wa])<1  &&  available_amount($item[wand of nagamar])<1 && available_amount($item[ruby w])<1) && my_path()!="Avatar of Boris")
	{
		print("- Get a ruby w from wimps in pandamonium slums to make wand of nagamar.","green");
	}
	if(my_level()>5 && contains_text(completed_log,"Trial By Friar")  && !contains_text(completed_log,"this is Azazel in Hell"))
	{
		if(available_amount($item[Azazel's unicorn])<1 || available_amount($item[bus pass])<5)
		{
			print("- Do Backstage arena (collect fire bugs).","green");
			suggest_fam("items", -1);
		}
		if(available_amount($item[Azazel's lollipop])<1  || available_amount($item[imp air])<5)
		{
			print("- Do laugh floor (olfact CHimp) (collect fire bugs).","green");
			advise_banish("Pr imp");
			suggest_fam("items", 1);
		}
		print("- get steel organ.","green");
	}
	if(my_level()>5 && !fcle_open && (!have_outfit("Frat Boy Ensemble")) && (available_amount($item[mullet wig])<1 || available_amount($item[briefcase])<1) && (available_amount($item[hot wing])<3 || available_amount($item[frilly skirt])<1))
	{
		print("- Get some infiltrationist equipment (mullet wig+briefcase, or frilly skirt + 3 hot wings, or frat outfit).","green");
		suggest_fam("items", 1);
	}
	if(contains_text(completed_log,"Trial By Friar") && contains_text(telescope,"cowardly-looking man") && available_amount($item[wussiness potion])<1)
	{
		print("- Get wussiness potion from pandamonium slums, for tower (olfact w imp maybe).","green");
		suggest_fam("items", 1);
	}
	if(my_level()==9)
	{
		print("- Be sure to do strange leaflet.","green");
	}
	if(my_buffedstat(my_primestat())>72 && !have_outfit("swashbuckling getup") && available_amount($item[pirate fledges])<1)
	{
		print("- Get pirate outfit.","green");
		if(!can_interact() && !in_hardcore())
			print("- Pull insults book and collect insults.","green");
		suggest_fam("items", -1);
	}
	if(have_outfit("swashbuckling getup") && ((available_amount($item[abridged dictionary])<1 && available_amount($item[bridge])<1 && !check_page("mountains.php","valley2.gif")) || (available_amount($item[The the big book of pirate insults])<1 && available_amount($item[Massive Manual of Marauder Mockery])<1) ))
	{
		print("- Buy dictionary/insults at pirate store.","green");
	}
	if(my_level()>7 && !contains_text(completed_log,"Am I my Trapper's Keeper"))
	{
		if(!have_outfit("mining gear") && my_path()!="Way of the Surprising Fist" && my_path()!="Avatar of Boris")
		{
			print("- Collect mining gear  (Yellow ray is a good idea).","green");
			suggest_fam("items", -1);
		}
		if(contains_text(trapper_string,"ore oughta do the trick"))
		{
			if(my_path()=="Avatar of Boris")
				print("- Fight mountain men","green");
			else
				print("- Mine ore.","green");
		}
		if(contains_text(trapper_string,"ll cook us up some pizzas"))
		{
			print("- collect goat cheese (olfact dairy goat, use friar blessing, use runaways until sniffed).","green");
			if(available_amount($item[loathing legion can opener])>0)
				print("(fold loathing legion can opener).","green");
			advise_banish("sabre-toothed goat");
			advise_stat_boosters(false);
			suggest_fam("items", 0);
		}
		if(contains_text(trapper_string,"ll need some kind of protection from the cold"))
		{
			print("- get cold protection (astral shell/exotic parrot) and finish trapper quest.","green");
		}
	}
	if(contains_text(completed_log,"Am I my Trapper's Keeper")  && my_path()=="Avatar of Boris" && clancy_level<4)
	{
		print("- Go to icy peak for clancy.","green");
		suggest_fam("none", 0);
	}
	if(my_buffedstat(my_primestat())>61)
	{
		string catch=visit_url("manor.php?place=stairs");
		if(!contains_text(manor_string,"sm2.gif"))
		{
			print("- Go to spookyraven library and find staircase.","green");
			suggest_fam("delay", 0);
		}
	}
	if(my_buffedstat(my_primestat())>61 && available_amount($item[spookyraven gallery key])<1 && (my_primestat()==$stat[muscle]))
	{
		print("- Open conservatory from noncom in library, then adv there for gallery key.","green");
		suggest_fam("runaways", -1);
	}
	int needed_inkwells=1;
	if(my_buffedstat(my_primestat())>61 &&  available_amount($item[inkwell])<needed_inkwells && contains_text(telescope,"strange shadow"))
	{
		print("- Get inkwell for tower.","green");
		suggest_fam("items", 1);
		needed_inkwells=needed_inkwells+1;
	}
	if(my_path()!="Way of the Surprising Fist" && my_buffedstat(my_primestat())>61 &&  (available_amount($item[inkwell])<needed_inkwells || available_amount($item[disintegrating quill pen])<1 || available_amount($item[tattered scrap of paper])<1)&& available_amount($item[scroll of ancient forbidden unspeakable evil])<1)
	{
		print("- Make AFUE scroll from ingredients in libary, to help with nuns.","green");
		suggest_fam("items", 1);
	}
	if(my_buffedstat(my_primestat())>86 && have_outfit("swashbuckling getup") && !fcle_open)
	{
		print("- Collect pirate insults in barrrney's bar while doing caromch's nasty booty, infiltrationist and insult beer pong.","green");
		suggest_fam("none", 1);
	}
	if(my_buffedstat(my_primestat())>86 && available_amount($item[pirate fledges])<1 && fcle_open)
	{
		print("- Go to F'c'le to do pirate chores (olfact third pirate.).","green");
		if(available_amount($item[cocktail napkin])>0)
		{
			print("-      (Banish clingy pirate with cocktail napkin).","green");
		}
		if(available_amount($item[valuable trinket])>0)
		{
			print("-      (Banish chatty pirates with valuable trinket during noncombat).","green");
		}
		advise_banish("unneeded pirates");
		suggest_fam("items", 1);
	}
	if(my_buffedstat(my_primestat())>93 &&  available_amount($item[frigid ninja stars])<1 && contains_text(telescope,"flaming katana"))
	{
		print("- Get frigid ninja stars for tower.","green");
		suggest_fam("items", 0);
	}
	if(my_buffedstat(my_primestat())>103 &&  available_amount($item[fancy bath salts])<1 && contains_text(telescope,"slimy eyestalk"))
	{
		print("- Get fancy bath salts for tower.","green");
		suggest_fam("items", 1);
	}
	int needed_ns=0;
	if(my_buffedstat(my_primestat())>103 && available_amount($item[nd])<1  &&  available_amount($item[wand of nagamar])<1 && contains_text(completed_log,"A Quest, LOL") && my_path() != "Bees hate you" && my_path()!="Avatar of Boris")
	{
		needed_ns=needed_ns+1;
	}
	if(my_buffedstat(my_primestat())>103 &&  available_amount($item[ng])<1  && contains_text(telescope,"North Pole") && contains_text(completed_log,"A Quest, LOL"))
	{
		needed_ns=needed_ns+1;
	}	
	if(my_buffedstat(my_primestat())>103 &&  available_amount($item[lowercase n])<needed_ns && contains_text(completed_log,"A Quest, LOL"))
	{
		print("- Get "+(needed_ns-available_amount($item[lowercase n]))+" lowercase ns in valley to make wand / ng for tower (olfact pron).","green");
		advise_banish("flaming troll");
		advise_stat_boosters(false);
		suggest_fam("items", 1);
	}	
	if(contains_text(completed_log,"A Quest, LOL") && contains_text(telescope,"huge face made of Meat") && available_amount($item[meat vortex])<1)
	{
		print("- Meat vortex from meat begzor in orc chasm.","green");
	}
	if(my_buffedstat(my_primestat())>85 &&  (available_amount($item[Lord Spookyraven's spectacles])<1 &&  contains_text(manor_string,"manor2.php")))
	{
		print("- Get spectacles in spookyraven bedroom.","green");
		if(my_buffedstat(my_primestat())<171)
		{
			print("You'll need to CLEESH combats though (171 safe mox).","green");
		}
		suggest_fam("runaways", -1);
	}
	if(my_buffedstat(my_primestat())>85 &&  (available_amount($item[Spookyraven ballroom key])<1 &&  contains_text(manor_string,"manor2.php")))
	{
		print("- Get ballroom key in spookyraven bedroom (delay before first wooden nightstand noncom).","green");
		if(my_buffedstat(my_primestat())<171)
		{
			print("You'll need to CLEESH combats though (171 safe mox).","green");
		}
		suggest_fam("runaways", -1);
	}
	if(my_buffedstat(my_primestat())>168 &&  (available_amount($item[antique hand mirror])<1 &&  contains_text(manor_string,"manor2.php")) && my_path() == "Bees Hate You")
	{
		print("- Get antique hand mirror in spookyraven bedroom.","green");
		suggest_fam("combat", -1);
	}
	if(my_buffedstat(my_primestat())>116 &&  (available_amount($item[Spookyraven ballroom key])>=1 && !quartet_correct()))
	{
		print("- Go to ballroom and set quartet to -combat.","green");
		suggest_fam("runaways", -1);
	}
	if(my_level()>8 && !have_outfit("filthy hippy disguise"))
	{
		print("- Get hippy outfit from noncombats in hippy camp.","green");
		suggest_fam("runaways", -1);
	}
//	if(my_level()>8 && !have_outfit("frat boy ensemble") && my_path()=="Bees hate you")
//	{
//		print("- Get frat outfit from noncombats in frat house.","green");
//		suggest_fam("runaways", -1);
//	}
	if(my_buffedstat(my_primestat())>44 && available_amount($item[plus sign])<1 && !check_page("questlog.php?which=3","discovered the secret of the Dungeons of Doom"))
	{
		print("- Adventure in enormous greater than sign and find a plus sign.","green");
		suggest_fam("runaways", -1);
	}
	if(my_buffedstat(my_primestat())>44 && available_amount($item[plus sign])>=1 && !contains_text(special_log,"discovered the secret of the Dungeons of Doom"))
	{
		print("- Adventure in enormous greater than sign to get teleportitis then pay oracle 1000 meat (free turns best used while under teleportitis).","green");
		suggest_fam("delay", -1);
	}
	if(!have_wand() && contains_text(special_log,"discovered the secret of the Dungeons of Doom") && my_path()!="Way of the Surprising Fist" && have_keys<3)
	{
		print("- Get zapping wand in dungeons of doom (needs 5000 meat).","green");
		suggest_fam("runaways", -1);
	}
	if(contains_text(special_log,"discovered the secret of the Dungeons of Doom") && !have_bang_potion() && my_path() != "Bees Hate You")
	{
		print("- Get bang potions in dungeons of doom for lair.","green");
		advise_banish("swarm of killer bees");
		suggest_fam("items", 1);
	}
	if(my_buffedstat(my_primestat())>103 && !contains_text(completed_log,"A Quest, LOL"))
	{
		print("- Get scrolls in valley and combine. (Try for semi rare + use healing bang potion or ML on adding machine, olfact/putty/romance adding machine if ready for 31337).","green");
		advise_banish("flaming troll");
		advise_stat_boosters(false);
		suggest_fam("delay", 0);
	}
	if(my_level()>9 && !contains_text(plains_string,"beanstalk.gif"))
	{
		print("- plant bean in plains.","green");
		suggest_fam("delay", 0);
	}
	if(my_buffedstat(my_primestat())>126 && contains_text(plains_string,"beanstalk.gif") && available_amount($item[s.o.c.k])==0 && available_amount($item[intragalactic rowboat])==0)
	{
		print("- Do airship for materia (olfact mech).","green");
		suggest_fam("delay", 0);
	}
	if(contains_text(plains_string,"beanstalk.gif") && (available_amount($item[s.o.c.k])!=0 || available_amount($item[intragalactic rowboat])!=0) && contains_text(telescope,"periscope") && available_amount($item[Photoprotoneutron torpedo])==0)
	{
		print("- Get a Photoprotoneutron torpedo from mech on airship (+20ml allows noncoms to give mechs).","green");
		suggest_fam("items", 1);
	}
	if(contains_text(plains_string,"beanstalk.gif") && contains_text(telescope,"hedgehog") && available_amount($item[super-spiky hair gel])<1)
	{
		print("- Get super-spiky hair gel from protagonist on airship for tower.","green");
		suggest_fam("items", 1);
	}
	if(my_buffedstat(my_primestat())>150 && (available_amount($item[s.o.c.k])!=0 || available_amount($item[intragalactic rowboat])!=0) && !contains_text(completed_log,"You have stopped the rain of giant garbage in the Nearby Plains"))
	{
		print("- Turn wheel in castle for castle quest (olfact goth giant for candles).","green");
		advise_banish("procrastination giant");
		suggest_fam("delay", -1);
	}
	if(available_amount($item[s.o.c.k])==1 && available_amount($item[intragalactic rowboat])==0)
	{
		print("- Get castle map items and make rowboat.","green");
		advise_banish("procrastination giant");
		suggest_fam("items", 1);
	}
	
	int butterflies_needed=0;
	if(contains_text(telescope,"large cowboy hat"))
	{
		butterflies_needed+=1;
	}
	if(get_property("sidequestFarmCompleted")=="none" && my_path() != "Bees hate you")
	{
		butterflies_needed+=1;
	}
	if((available_amount($item[s.o.c.k])>0 ||available_amount($item[intragalactic rowboat])>0) && available_amount($item[chaos butterfly])<butterflies_needed)
	{
		print("- Get "+butterflies_needed+" chaos butterfly(s) in castle, for ducks/tower (olfact possibility giant).","green");
		advise_banish("procrastination giant");
		suggest_fam("items", 1);
	}
	int needed_candles=0;
	if(my_path()!="Way of the Surprising Fist")
		needed_candles+=3;
	if(contains_text(telescope,"glum teenager"))
		needed_candles+=1;
	if((available_amount($item[s.o.c.k])!=0 || available_amount($item[intragalactic rowboat])!=0) && get_property("sidequestNunsCompleted")=="none" && available_amount($item[thin black candle])<needed_candles)
	{
		print("- Get "+(needed_candles-available_amount($item[thin black candle]))+" more thin black candles so we can summon meat demon for nuns and/or pass tower (olfact goth giant?).","green");
		advise_banish("procrastination giant");
		suggest_fam("items", 1);
	}
	if((available_amount($item[s.o.c.k])>0 ||available_amount($item[intragalactic rowboat])>0) && contains_text(telescope,"writing desk") && available_amount($item[plot hole])<1)
	{
		print("- Get plot hole in castle, for tower.","green");
		suggest_fam("items", 1);
	}
	if((available_amount($item[s.o.c.k])>0 ||available_amount($item[intragalactic rowboat])>0) && contains_text(telescope,"North Pole") && available_amount($item[original g])<1 && available_amount($item[ng])<1)
	{
		print("- Get original g in castle, for tower.","green");
		suggest_fam("items", 1);
	}
	if((available_amount($item[s.o.c.k])>0 ||available_amount($item[intragalactic rowboat])>0) && contains_text(telescope,"smiling man smoking a pipe") && available_amount($item[Mick's IcyVapoHotness Rub])<1)
	{
		print("- Get Mick's IcyVapoHotness Rub from raver giant in castle for tower.","green");
		suggest_fam("items", 1);
	}
	if((available_amount($item[s.o.c.k])>0 ||available_amount($item[intragalactic rowboat])>0) && contains_text(telescope,"rose") && available_amount($item[angry farmer candy])<1)
	{
		print("- Get angry farmer candy in from raver giant in castle for tower.","green");
		suggest_fam("items", 1);
	}
	if(available_amount($item[intragalactic rowboat])!=0 && (available_amount($item[star hat])<1 || available_amount($item[Richard's star key])<1 || (available_amount($item[star sword])<1 && available_amount($item[star staff])<1 && available_amount($item[star crossbow])<1 && my_path()!="Way of the Surprising Fist") && my_path()!="Avatar of Boris"))
	{
		print("- Do hole in the sky for star hat, weapon (no weapon in wotsf) and key (olfact skinflute/camels toe. romance/olfact astronomer).","green");
		advise_stat_boosters(false);
		suggest_fam("items", 0);
	}
	if(my_level()>10 && !contains_text(woods_string,"blackmarket.gif"))
	{
		print("- Collect black market map in black forest.","green");
		suggest_fam("runaways", 0);
	}
	if(my_level()>10 && contains_text(telescope,"flash of albumen") && available_amount($item[black pepper])<1)
	{
		print("- Get black pepper in black forest, for tower (olfact black widow).","green");
		suggest_fam("items", 0);
	}
	if(my_level()>10 && contains_text(telescope,"a raven") && available_amount($item[black no. 2])<1)
	{
		print("- Get black no 2 at black forest, for tower.","green");
		suggest_fam("items", 0);
	}
	if(my_level()>10 && contains_text(telescope,"coiled viper"))
	{
		print("- Get adder bladder at black forest, for tower.","green");
		suggest_fam("items", 0);
	}
	if(available_amount($item[fathers diary])>0 && available_amount($item[talisman o' nam])==0)
	{
		print("- Go to poop deck to open belowdecks, then farm talisman o nam (olfact/copy gaudy pirate).","green");
		advise_banish("grassy pirate");
		advise_stat_boosters(true);
		suggest_fam("none", 0);
	}
	if(available_amount($item[talisman o' nam])>0 && !have_guitar())
	{
		print("- Make a stone banjo for stone mariachis.","green");
	}
	if(contains_text(beach_string,"desert.gif") && !contains_text(beach_string,"oasis.gif"))
	{
		print("- Go to arid desert until oasis open.","green");
		suggest_fam("delay", 0);
	}
	if(contains_text(incomplete_log,"ve managed to stumble upon a hidden oasis out in the desert"))
	{
		print("- Go to arid desert (ultrahydrated) to meet gnashir.","green");
		advise_banish("swarm of fire ants/rock scorpion");
		suggest_fam("delay", 0);
	}
	if(contains_text(incomplete_log,"Gnasir has tasked you with finding a stone rose") )
	{
		print("- Adventure in oasis to get a stone rose, then hand it to gnasir in the arid desert (olfact blur).","green");
		if(item_amount($item[can of black paint])<1)
		{
			print("- Also buy a can of black paint at the black market.","green");
		}
		suggest_fam("delay", 0);
	}
	if(contains_text(incomplete_log,"Gnasir seemed satisfied with the tasks you performed for his tribe") || contains_text(incomplete_log,"something that produces a rhythmic vibration to summon sandworms"))
	{
		print("- Farm a Drum machine from blur (olfact) in oasis (and pick up pages). Then return to gnashir in arid desert.","green");
		suggest_fam("delay", 0);
	}
	if(available_amount($item[worm-riding hooks])>0)
	{
		print("- equip worm-riding hooks and use drum machine.","green");
	}
	if(contains_text(beach_string,"desert.gif")  && available_amount($item[bronzed locust])<1 && contains_text(telescope,"amber waves of grain"))
	{
		print("- Get bronzed locust from plaque of locusts in arid desert, for tower (olfact plaque of locusts).","green");
		suggest_fam("items", 0);
	}
	if(available_amount($item[talisman o nam])>0 && !have_staff() && available_amount($item[i love me, vol i])<1)
	{
		print("- Adventure in palindome to get hard rock candy, photo of god, ketchup hound, ostrich egg, and place on shelf (olfact bob racecar, use +items or ray).","green");
		suggest_fam("delay", 0);
	}
	if(contains_text(beach_string,"desert.gif") && !contains_text(woods_string,"hiddencity.gif"))
	{
		print("- Go to Hidden Temple to open Hidden City.","green");
		suggest_fam("delay", 0);
	}
	if(contains_text(woods_string,"hiddencity.gif") && available_amount($item[spectre scepter])<1)
	{
		print("- Explore Hidden City with elemental damage gear, to get orbs and put on pedastals, then fight boss. (getting wandering monsters/hipster fights/llama end??? while exploring helps)","green");
		advise_pie("protector spectre");
		suggest_fam("delay", 1);
	}
	if(contains_text(woods_string,"hiddencity.gif") && available_amount($item[pygmy blowgun])<1 && contains_text(telescope,"giant white ear"))
	{
		print("- Get pygmy blowgun in hidden city, for tower.","green");
		suggest_fam("items", 1);
	}
	if(contains_text(woods_string,"hiddencity.gif") && available_amount($item[pygmy pygment])<1 && contains_text(telescope,"armchair"))
	{
		print("- Get pygmy pygment in hidden city, for tower (olfact pygmy assault squad).","green");
		suggest_fam("items", 1);
	}
	if(available_amount($item[spectre scepter])>0 && !have_drum())
	{
		print("- Either make a bone rattle from skeleton bone + broken skull (guano junction), or pick up black kettle drum from one time adv in black forest.","green");
		suggest_fam("none", -1);
	}
	if(available_amount($item[i love me, vol i])>0 && available_amount($item[mega gem])<1 && !have_staff())
	{
		if(available_amount($item[wet stunt nut stew])>0)
		{
			print("- Give wet stunt nut stew to mr alarm in cobbs knob lab.","green");
			suggest_fam("delay", 1);
		}
		else
		{
			print("- Collect ingedients for wet stunt nut stew, make it, and give it to mr alarm in cobbs knob lab.","green");
			suggest_fam("items", -1);
		}
	}
	if(available_amount($item[mega gem])>0 && !have_staff())
	{
		print("- Go to palindome and kill dr awkward.","green");
		advise_pie("dr. awkward");
		suggest_fam("combat", 0);
	}
	if(contains_text(beach_string,"desert.gif") && !contains_text(manor_string,"sm8b.gif"))
	{
		print("- Go to Haunted Ballroom, and open wine cellar.","green");
		suggest_fam("delay", -1);
	}
	if(contains_text(manor_string,"sm8b.gif") && !contains_text(manor2_string,"chambera.gif") && !contains_text(manor2_string,"chamber.gif"))
	{
		print("- Farm wines and pour into goblet to open summoning chamber (fighting without subzone allows all to drop), use friars blessing.","green");
		if(available_amount($item[loathing legion corkscrew])>0)
			print("(fold loathing legion corkscrew. Also putty mob.).","green");
		advise_stat_boosters(false);
		suggest_fam("items", 0);
	}
	if(contains_text(manor2_string,"chambera.gif") && !simons_have_eye())
	{
		print("- Kill lord spookyraven (exotic parrot + astral shell + can of black paint + titanium umbrella + oil of parrrlay + elemental saucesphere).","green");
		if(available_amount($item[loathing legion pizza stone])>0)
			print("(fold loathing legion pizza stone)","green");
		if(available_amount($item[crown of thrones])>0)
			print("(holiday log in crown of thrones)","green");
		if(available_amount($item[greatest american pants])>0)
			print("(super structure buff from GAP)","green");
		advise_pie("lord spookyraven");
	}
	if(pyramid_string!="" && !contains_text(pyramid_string,"pyramid4_1b.gif"))
	{
		if(item_amount($item[ancient bomb])>0)
			print("- Spin lower chamber to empty-left rocks-right, then enter.","green");
		else
		{
			if(item_amount($item[ancient bronze token])>0)
				print("- Spin lower chamber to rocks-left vending machine-right, then enter.","green");
			else
			{
				print("- Adventure in upper chamber for wooden wheel, then spin lower chamber to bucket-left empty-right, then enter.","green");
			}
		}
		if(my_path() == "Bees hate you")
		{
			print("-     Spin with noncombats from middle chamber.","green");
			suggest_fam("none", -1);
		}
		else
		{
			print("-     Spin with ratchets from top chamber (olfact tomb rat, also can bander runaway from others to save buff turns).","green");
			if(can_interact())
				print("(pull and throw tangles of rat tails).","green");
			advise_banish("tomb asp/tomb servant");
			advise_stat_boosters(false);
			suggest_fam("items", 1);
		}
	}
	if(pyramid_string!="" && my_path()=="Avatar of Boris" && clancy_level<5)
	{
		print("- Go to middle chamber for clancy.","green");
		suggest_fam("none", 0);
	}
	if(contains_text(incomplete_log,"re so close you can almost taste it"))
	{
		print("- Fight ed the undying.","green");
		advise_pie("eds first form");
		suggest_fam("combat", 0);
	}
	if((contains_text(pyramid_string,"pyramid4_1b.gif") || contains_text(incomplete_log,"re so close you can almost taste it")) && contains_text(telescope,"pipes with steam") && available_amount($item[powdered organs])<1)
	{
		print("- Get powdered organs from canopic jar, dropped by tomb servants in upper and middle chamber, for tower.","green");
	}
	if(my_level()>11 && !have_war_outfit())
	{
		if(my_path()!="Bees hate you")
		{
			print("- Get war frat outfit (hippy outfit in frat house + yellow ray is good idea).","green");
		}
		else
		{
			print("- Get war hippy outfit (hippy outfit in hippy camp with noncombats).","green");
			suggest_fam("items", -1);
		}
	}
	if(have_war_outfit() && !contains_text(island_string,"20.gif"))
	{
		print("- Equip war outfit and adventure in opposite camp to start war.","green");
		suggest_fam("none", -1);
	}
	if(have_war_outfit() && contains_text(island_string,"20.gif") && !contains_text(completed_log,"in the Great War. "))
	{
		print("- Island War:","green");
	
		if(my_path() != "Bees hate you")
		{
			if(available_amount($item[rock band flyers])<1)
				print("- Pick up rock band flyers.","green");
			
			if(get_property("sidequestOrchardCompleted")=="none" && available_amount($item[heart of the filthworm queen])<1)
			{
				print("- Flyer through orchard sidequest, but don't hand in (sticker sword, cyclops eyedrops, spooky feather, polka pop, lavender heart, pool table, bang/reagent potions, phat loot). (if possible use high ml).","green");
				if(available_amount($item[loathing legion many purpose hook])>0)
					print("(fold loathing legion many purpose hook)","green");
				suggest_fam("items",0);
				advise_stat_boosters(false);
			}
			
			if(get_property("sidequestJunkyardCompleted")=="none" && (available_amount($item[molybdenum crescent wrench])<1 || available_amount($item[molybdenum hammer])<1 || available_amount($item[molybdenum pliers])<1 || available_amount($item[molybdenum screwdriver])<1))
			{
				print("- Flyer through junkyard sidequest (maximize da/dr/block. Cleesh the incorrect gremlins to double flyering). (if possible use high ml).","green");
				suggest_fam("combat",0);
				advise_stat_boosters(true);
			}
			
			if(get_property("sidequestLighthouseCompleted")=="none" && available_amount($item[barrel of gunpowder])<5)
			{
				print("- Flyer through lighthouse sidequest. (if possible use high ml).","green");
				suggest_fam("none",1);
			}
			
			if(my_path()!="Way of the Surprising Fist" && get_property("sidequestNunsCompleted")=="none" && have_outfit("war hippy fatigues"))
			{
				print("- Flyer through nuns sidequest as a hippy, but stop with 1 kill left. (sticker sword, demon summon, stench feather, polka pop, nasal spray, tea party buff, pink candy heart, reagent potions, polka of plenty, inhalers). (if possible use high ml).","green");
				suggest_fam("meat",0);
				advise_stat_boosters(false);
			}
			if(get_property("sidequestArenaCompleted")=="none" && (10000-get_property("flyeredML").to_int())>0)
			{
				print("- Flyer through any unfinished areas, with ML on ("+(10000-get_property("flyeredML").to_int())+" ML left).","green");
				if(get_property("sidequestFarmCompleted")=="none")
				{
					print("- If no unfinished areas, flyer at dooks farm, with ML on (but only finish if we have 1-2 zones left when flyers are done).","green");
					advise_stat_boosters(true);
				}
				suggest_fam("none",0);
			}
			
			if(my_path()!="Way of the Surprising Fist" && get_property("sidequestNunsCompleted")=="none" && (to_int(get_property("hippiesDefeated"))>=192 || available_amount($item[spooky putty sheet])>0) || available_amount($item[rain-doh black box])>0)
			{
				print("- Nuns sidequest. (sticker sword, demon summon, spooky feather, polka pop, nasal spray, tea party buff, pink candy heart, reagent potions, polka of plenty, inhalers).","green");
				if(available_amount($item[loathing legion electric knife])>0)
					print("(fold loathing legion electric knife).","green");
				if(available_amount($item[spooky putty sheet])>0 || available_amount($item[rain-doh black box])>0)
					print("(complete as frat till 1 turn left, then putty and finish as hippy).","green");
				suggest_fam("meat",0);
				advise_stat_boosters(false);
			}
			print("- Kill hippies in battlefield (olfact green gourmet for food/drink).","green");
			advise_stat_boosters(true);
			advise_pie("big wisniewskie");
			suggest_fam("none",0);
		}
		else
		{
			
			if(get_property("sidequestOrchardCompleted")=="none")
			{
				print("- Orchard sidequest, (pet buff spray, goblin eyedrops, sticker sword, cyclops eyedrops, spooky feather, polka pop, lavender heart, pool table, bang/reagent potions, phat loot).","green");
				if(available_amount($item[bag o tricks])>0)
				{
					print("- POWER LEVEL: summon weasels from bag o tricks with 2 charges","green");
				}
				suggest_fam("items",0);
				advise_stat_boosters(false);
			}
			
			if(get_property("sidequestNunsCompleted")=="none")
			{
				print("- Nuns sidequest as hippy, (pet buff spray, goblin nasal spray, sticker sword, demon summon, stench feather, polka pop, tea party buff, pink candy heart, reagent potions, polka of plenty, inhalers, arena buff, resolution).","green");
				if(available_amount($item[bag o tricks])>0)
				{
					print("(summon badgers from bag o tricks with 1 charges)","green");
				}
				suggest_fam("meat",0);
				advise_stat_boosters(false);
			}
			
			if(get_property("sidequestFarmCompleted")=="none")
			{
				print("- Dooks quest.","green");
				advise_stat_boosters(true);
				suggest_fam("none",0);
			}
			
			if(get_property("sidequestLighthouseCompleted")=="none" && get_property("fratboysDefeated")>64)
			{
				print("- Lighthouse sidequest.","green");
				suggest_fam("none",1);
			}
			
			print("- Kill fratboys in battlefield (olfact senior grill sergeant for food/drink).","green");
			advise_stat_boosters(true);
			advise_pie("the man");
			suggest_fam("none",0);
		}
	}
	if(have_war_outfit() && contains_text(island_string,"20.gif") && contains_text(telescope,"banana peel") && available_amount($item[gremlin juice])<1)
	{
		print("- Get gremlin juice in junkyard for tower.","green");
		suggest_fam("items", 0);
	}
	int restorers = item_amount($item[filthy poultice]) + item_amount($item[gauze garter]) + item_amount($item[red pixel potion]) + (2*item_amount($item[scented massage oil]));
	if(contains_text(incomplete_log,"The Final Ultimate Epic Final Conflict") && !contains_text(chamber_string,"chamber5.gif") && !contains_text(chamber_string,"chamber4.gif") && restorers<5)
	{
		print("- Need some more healing stuff before fighting your shadow. "+(5-restorers)+"red pixel potions or "+((5-restorers)/2)+" scented massage oils should do it","green");
	}
	if(my_level()==13 && item_amount($item[wand of nagamar])<1)
	{
		print("- Make wand of nagamar.","green");
	}
	if(contains_text(incomplete_log,"The Final Ultimate Epic Final Conflict") && !check_page("lair5.php","towerup2.gif") && contains_text(telescope,"what appears to be ice") && available_amount($item[hair spray])<1)
	{
		print("- buy hair spray for tower","green");
	}
	if(contains_text(incomplete_log,"The Final Ultimate Epic Final Conflict"))
	{
		print("- Do tower and kill NS (safemox=215)","green");
		suggest_fam("combat", 0);
	}
	
	//power leveling help
	if((available_amount($item[spooky putty sheet])>0  || available_amount($item[rain-doh black box])>0) && get_property("spookyPuttyCopiesMade").to_int()<5)
		print("- Use spare putties on Bricko Bats/hipster mobs","green");
	if(available_amount(to_item(5299))>0)
	{
		if(my_primestat()==$stat[muscle])
			print("- POWER LEVEL: Vamp out > isabella > Drain Her","green");
		else if(my_primestat()==$stat[moxie])
			print("- POWER LEVEL: Vamp out > isabella > Redirect Your Desire > Go to the Bar","green");
		else
			print("- POWER LEVEL: Vamp out > isabella > Tell Her How You Feel > Find Other Prey","green");
	}
	if(available_amount($item[bag o tricks])>0)
	{
			print("- POWER LEVEL: summon chihauhau from bag o tricks with 3 charges","green");
	}
	if(my_level()>=9)
	{
		if(available_amount($item[ten-leaf clover])>0)
		{
			print("- POWER LEVEL: Clover in spookyraven zone","green");
		}
		if(available_amount($item[tiny bottle of absinthe])>0 && my_path()!="Bees hate you")
		{
			print("- POWER LEVEL: 5/1 in wormwood","green");
		}
		print("- POWER LEVEL: Roach form and unpopular","green");
		print("- POWER LEVEL: Spookyraven zone (olfact zombie waltzers)","green");
		suggest_fam("none", -1);
		
		if(get_property("_aprilShower")=="false")
		{
			print("(use shower buff to improve gains)","green");
		}
		if(get_property("_madTeaParty")=="false")
		{
			print("(consider hatters ml buff if you will be fighting)","green");
		}
	}
	
	print("done","green");*/
}