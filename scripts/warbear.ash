void use_pot(string pot, string buff)
{
	if(have_effect(to_effect(buff))==0)
	{
		use(1,to_item(pot));
		/*refresh_stash();
		if(stash_amount(to_item(pot))>0)
		{
			take_stash(1,to_item(pot));
			use(1,to_item(pot));
		}
		else
			abort("no "+pot+" left");*/
	}
}

void use_food(string pot, string buff, int cost)
{
	if(have_effect(to_effect(buff))==0 && fullness_limit()-my_fullness()>=cost)
	{
		//refresh_stash();
		if(stash_amount(to_item(pot))>0)
		{
			take_stash(1,to_item(pot));
			if(have_effect($effect[got milk])<cost) use(1,$item[milk of magnesium]);
			eat(1,to_item(pot));
		}
		else
			print("no "+pot+" left","red");
	}
}

void use_drink(string pot, string buff, int cost)
{
	if(have_effect(to_effect(buff))==0 && inebriety_limit()-my_inebriety()>=cost)
	{
		//refresh_stash();
		if(stash_amount(to_item(pot))>0)
		{
			take_stash(1,to_item(pot));
			drink(1,to_item(pot));
		}
		else
			print("no "+pot+" left","red");
	}
}

void dump_pots()
{
	/*cli_execute("stash put * warbear wardance potion");
	cli_execute("stash put * warbear bearserker potion");
	cli_execute("stash put * warbear liquid overcoat");
	
	cli_execute("stash put * warbear feasting bread");
	cli_execute("stash put * warbear warrior bread");
	cli_execute("stash put * warbear thermoregulator bread");
	
	cli_execute("stash put * warbear feasting mead");
	cli_execute("stash put * warbear bearserker mead");
	cli_execute("stash put * warbear blizzard mead");
	*/
	cli_execute("stash put * warbear battery");
	
	cli_execute("stash put * warbear helm fragment");
	cli_execute("stash put * warbear trouser fragment");
	cli_execute("stash put * warbear accoutrements chunk");
	
	cli_execute("stash put * blind-packed die-cast metal toy");
	
	refresh_stash();
	/*if(stash_amount($item[warbear helm fragment])>36)
		abort("make Warbear electro-spiked helm and add to script if good");
	if(stash_amount($item[warbear trouser fragment])>36)
		abort("make warbear bearserker greaves and add to script if good");
	if(stash_amount($item[warbear accoutrements chunk])>=21)
		abort("make fleece-lined warscarf");*/
}

void harvest_robots()
{
	print("harvesting robots","green");
	if(get_property("_robots_harvested").to_boolean())
		return;
		
	//crimbo town
	visit_url("place.php?whichplace=crimbo2013");
	//krampus
	visit_url("place.php?whichplace=crimbo2013&action=cr13_krampus");
	int i=1;
	while(i<=8)
	{
		visit_url("choice.php?whichchoice=810&option=1&slot="+i+"&pwd");
		i=i+1;
	}
	set_property("_robots_harvested","true");
	print("harvesting done","green");
	dump_pots();
}

void final_buffs()
{
	boolean dump=cli_execute("ballpit");
	dump=cli_execute("pool aggressive");
	
	if(have_effect(to_effect("Forbear, Warbears!"))==0)
	{
		if(fullness_limit()-my_fullness()>=4)
		{
			abort("eat mid level food and drink");
		}
		else
			print("too full for vendor food","red");
	}
	
	if(have_effect(to_effect("loaded forwarbear"))==0)
	{
		if(inebriety_limit()-my_inebriety()>=4)
		{
			abort("eat mid level food and drink");
		}
		else
			print("too drunk for vendor food","red");
	}
}

void warbear_officers()
{
	//num beaten
	int num_beaten2=get_property("_warbear2_beaten").to_int();
	int num_beaten3=get_property("_warbear3_beaten").to_int();
	print("already beaten "+num_beaten2+" officers and "+num_beaten3+" high rank officers");
	
	int base_unpotted_turns=0;
	
	//gear
	print("gear","green");
	string m="maximize -100 ML, elemental damage, equip hoverbelt, 0.1 ";
	if(my_primestat()==$stat[muscle])
	{
		m=m+"muscle, +melee";
	}
	else
	{
		m=m+"moxie, -melee";
	}
	if(my_class()==$class[accordion thief])
	{
		m=m+", type accordion";
	}
	
	if(available_amount($item[warbear spiked helm])>0)
	{
		m=m+", equip warbear spiked helm";
		base_unpotted_turns=base_unpotted_turns+10;
	}
	if(available_amount($item[warbear bearserker greaves])>0)
	{
		m=m+", equip warbear bearserker greaves";
		base_unpotted_turns=base_unpotted_turns+10;
	}
	if(available_amount($item[warbear plasma bowtie])>0)
	{
		m=m+", equip warbear plasma bowtie";
		base_unpotted_turns=base_unpotted_turns+10;
	}
	if(my_class()==$class[pastamancer])
	{
		m=m+", equip energy bracers";
		base_unpotted_turns=base_unpotted_turns+10;
	}
	else if(available_amount($item[warbear fleece-lined warscarf])>0)
	{
		m=m+", equip warbear fleece-lined warscarf";
		base_unpotted_turns=base_unpotted_turns+10;
	}
	print(m,"green");
	cli_execute(m); 
	
	//thrall = angelhair
	if(my_class()==$class[pastamancer] && my_thrall()!=$thrall[angel hair wisp])
		use_skill($skill[bind angel hair wisp]);
	
	//fam
	if(have_familiar($familiar[warbear drone]))
	{
		use_familiar($familiar[warbear drone]);
		equip($item[warbear drone codes]);
	}
	else
	{
		use_familiar($familiar[levitating potato]);
		equip($item[sugar shield]);
	}
	
	//ml over 10 is number of unpotted tursn
	float ml=numeric_modifier("Monster Level");
	int unpotted_turns=base_unpotted_turns+ml/(-10.0);

	cli_execute("closet put * personal massager");
	while(my_adventures()>0)
	{
		if((num_beaten2+num_beaten3)>=(30+unpotted_turns))
		{
			print("Probably beaten enough today ("+num_beaten2+" officers and "+num_beaten3+" high rank officers)","red");
			return;
		}
		
		//charge belt
		if(contains_text(visit_url("desc_item.php?whichitem=531580874"),"it's currently blank"))
		{
			refresh_stash();
			if(stash_amount($item[warbear battery])>0)
			{
				take_stash(1,$item[warbear battery]);
				use(1,$item[warbear battery]);
			}
			else
				abort("out of charge and batteries after "+num_beaten2+" officers and "+num_beaten3+" high rank officers");
		}

		//dance pots
		use_pot("warbear wardance potion","dances with warbears");
		use_food("Warbear feasting bread","Gift of the Warbear",3);
		use_drink("Warbear feasting mead","Warbear Loot Lust",3);
		//combat pots
		if((num_beaten2+num_beaten3)>unpotted_turns)
		{
			print("beaten more than "+unpotted_turns+" so taking more pots","green");
			use_pot("Warbear bearserker potion","Bearserker Bearrage");
			use_pot("Warbear liquid overcoat","Warbear on the Inside");
			use_food("Warbear warrior bread","Warriors, Come out to Playyyy",3);
			use_food("Warbear thermoregulator bread","Superheated Guts",3);
			use_drink("Warbear bearserker mead","Warbear Warlust",3);
			use_drink("Warbear blizzard mead","warbear blubber",3);
			
			if(my_primestat()==$stat[muscle])
				use_pot("Mer-kin strongjuice","Juiced Out");
			else
				use_pot("Mer-kin cooljuice","Juiced");
		}
		if((num_beaten2+num_beaten3)>=(10+unpotted_turns))
		{
			print("and even crap food","green");
			final_buffs();
		}
		if((num_beaten2+num_beaten3)>=(20+unpotted_turns))
		{
			boolean catch;
			if(my_name()=="twistedmage")
			{
				catch=cli_execute("telescope high");
			}
			catch=cli_execute("use home game");
				
		}
			
		cli_execute("mood bumcheekascend; mood execute;restore hp");
		if(my_class()==$class[pastamancer])
			cli_execute("restore mp");
			
		if(available_amount($item[warbear badge])>0)
		{
			print("fighting bear high officer "+num_beaten3,"green");
			//adventure(1,$location[warbear fortress (third level)]);
			string txt=visit_url("adventure.php?snarfblat=368");
			string txt2=run_combat();
			if(have_effect($effect[beaten up])>0)
				abort("got beaten up by bear high officer "+num_beaten3+" (also beat "+num_beaten2+" officers)");
			num_beaten3=num_beaten3+1;
			set_property("_warbear3_beaten",num_beaten3);
		}
		else
		{
			print("fighting bear officer "+num_beaten2,"green");
			//adventure(1,$location[warbear fortress (second level)]);
			string txt=visit_url("adventure.php?snarfblat=367");
			string txt2=run_combat();
			if(have_effect($effect[beaten up])>0)
				abort("got beaten up by bear officer "+num_beaten2+" (also beat "+num_beaten3+" high officers)");
			num_beaten2=num_beaten2+1;
			set_property("_warbear2_beaten",num_beaten2);
		}
	}
}

void warbear_infantry()
{
	cli_execute("eatdrink_simon false");
	cli_execute("eatdrink_simon false");
	cli_execute("shrug anapests; uneffect qwop");
	if(have_familiar($familiar[squamous gibberer]))
		use_familiar($familiar[squamous gibberer]);
	string m;
	if(my_primestat()==$stat[muscle])
		m="maximize muscle";
	else
		m="maximize moxie";
	if(available_amount($item[pantsgiving])>0)
		m=m+", +equip pantsgiving";

	cli_execute(m);
	
	if(have_familiar($familiar[warbear drone]))
	{
		use_familiar($familiar[warbear drone]);
		equip($item[warbear drone codes]);
	}
	else
	{
		use_familiar($familiar[levitating potato]);
		equip($item[sugar shield]);
	}
	
	cli_execute("mood apathetic");
	while(my_adventures()>0)
	{
		adventure(10,$location[warbear fortress (first level)]);
		if(my_fullness()!=fullness_limit())
			cli_execute("eatdrink_simon false");
	}
}

void main(boolean officers)
{
	harvest_robots();
	if(officers)
		warbear_officers();
	else
	{
		warbear_infantry();
		cli_execute("eatdrink_simon");
		cli_execute("ocd data creator;ocd inventory control");
	}
}