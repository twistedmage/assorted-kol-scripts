//1666 per cast = 5
import <eatdrink.ash>;

void mood_fires()
{
	if(my_name()=="twistedmage")
	{
		string dump=visit_url("shop.php?pwd&whichshop=fdkol&action=buyitem&whichitem=5708&quantity=1");
		use(1,$item[drop of water-37]);
		if (have_skill($skill[Empathy of the Newt])) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
		if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
		if (have_skill($skill[astral shell])) cli_execute("trigger lose_effect, astral shell, cast 1 astral shell");
		if (have_skill($skill[elemental saucesphere])) cli_execute("trigger lose_effect, elemental saucesphere, cast 1 elemental saucesphere");
		if (have_skill($skill[jackasses' symphony of destruction])) cli_execute("trigger lose_effect, jackasses' symphony of destruction, cast 1 jackasses' symphony of destruction");
		if (have_skill($skill[the magical mojomuscular melody])) cli_execute("trigger lose_effect, the magical mojomuscular melody, cast 1 the magical mojomuscular melody");
		if (have_skill($skill[manicotti meditation])) cli_execute("trigger lose_effect, pasta oneness, cast 1 manicotti meditation");
		if (have_skill($skill[sauce contemplation])) cli_execute("trigger lose_effect, saucemastery, cast 1 sauce contemplation");
		cli_execute("trigger lose_effect, glittering eyelashes, use 1 glittery mascara");
		cli_execute("trigger lose_effect, mystically oiled, use 1 ointment of the occult");
		cli_execute("trigger lose_effect, extra-wet, use 1 drop of water-37");
	}
}

void mood_snakes()
{
//	if (have_skill($skill[Fat Leon's Phat Loot Lyric])) cli_execute("trigger lose_effect, Fat Leon's Phat Loot Lyric, cast 1 Fat Leon's Phat Loot Lyric");
//	if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
//	if (have_skill($skill[Empathy of the Newt])) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
//	cli_execute("trigger lose_effect, Peeled Eyeballs, use 1 Knob Goblin eyedrops");
//	cli_execute("trigger lose_effect, Heavy Petting, use 1 Knob Goblin pet-buffing spray");
}

void mood_bats()
{
	if(my_name()=="twistedmage")
	{
//		string dump=visit_url("shop.php?pwd&whichshop=fdkol&action=buyitem&whichitem=5708&quantity=1");
//		use(1,$item[drop of water-37]);
//		if (have_skill($skill[Empathy of the Newt])) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
//		if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
//		if (have_skill($skill[astral shell])) cli_execute("trigger lose_effect, astral shell, cast 1 astral shell");
//		if (have_skill($skill[elemental saucesphere])) cli_execute("trigger lose_effect, elemental saucesphere, cast 1 elemental saucesphere");
		if (have_skill($skill[Jabanero Saucesphere])) cli_execute("trigger lose_effect, Jabañero Saucesphere, cast 1 Jabañero Saucesphere");
//		if (have_skill($skill[Jalapeno Saucesphere])) cli_execute("trigger lose_effect, Jalapeño Saucesphere, cast 1 Jalapeño Saucesphere");

//		if (have_skill($skill[jackasses' symphony of destruction])) cli_execute("trigger lose_effect, jackasses' symphony of destruction, cast 1 jackasses' symphony of destruction");
//		if (have_skill($skill[the magical mojomuscular melody])) cli_execute("trigger lose_effect, the magical mojomuscular melody, cast 1 the magical mojomuscular melody");
//		if (have_skill($skill[manicotti meditation])) cli_execute("trigger lose_effect, pasta oneness, cast 1 manicotti meditation");
//		if (have_skill($skill[sauce contemplation])) cli_execute("trigger lose_effect, saucemastery, cast 1 sauce contemplation");
//		cli_execute("trigger lose_effect, glittering eyelashes, use 1 glittery mascara");
//		cli_execute("trigger lose_effect, mystically oiled, use 1 ointment of the occult");
//		cli_execute("trigger lose_effect, extra-wet, use 1 drop of water-37");
	}
}

void mood_bricks()
{
	if (have_skill($skill[Fat Leon's Phat Loot Lyric])) cli_execute("trigger lose_effect, Fat Leon's Phat Loot Lyric, cast 1 Fat Leon's Phat Loot Lyric");
	if (have_skill($skill[Leash of Linguini])) cli_execute("trigger lose_effect, Leash of Linguini, cast 1 Leash of Linguini");
	if (have_skill($skill[Empathy of the Newt])) cli_execute("trigger lose_effect, Empathy, cast 1 Empathy of the Newt");
	cli_execute("trigger lose_effect, Peeled Eyeballs, use 1 Knob Goblin eyedrops");
	cli_execute("trigger lose_effect, Heavy Petting, use 1 Knob Goblin pet-buffing spray");
}

void prepare_for_fires()
{
	if(have_familiar($familiar[magic dragonfish]))
		use_familiar($familiar[magic dragonfish]);
	if(my_name()=="twistedmage")
	{
		use_skill($skill[spirit of peppermint]);
		outfit("fires");
		equip($item[fin-bit wax]);
		cli_execute("use jackass plumber home game");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("use moveable feast");
		cli_execute("ballpit");
		cli_execute("mcd 0");
		if(!to_boolean(get_property("telescopeLookedHigh")))
			cli_execute("telescope high");
		//cli_execute("maximize 0.1 spell damage percent, hot resistance");
	}
	else
	{
		if(available_amount($item[pulled porquoise earring])<1)
			take_stash(1,$item[pulled porquoise earring]);
		cli_execute("maximize cold damage, equip fireman's helmet, equip pulled porquoise earring, -equip sugar shield"); //,equip fire axe
		if(have_effect($effect[astral shell])>0)
			cli_execute("shrug astral shell");
		if(have_effect($effect[elemental saucesphere])>0)
			cli_execute("shrug elemental saucesphere");
		if(equipped_amount($item[sugar shield])>0)
			cli_execute("unequip sugar shield");
	}
	mood_fires();
}

void prepare_for_snakes()
{
	if(have_familiar($familiar[jumpsuited hound dog]))
		use_familiar($familiar[jumpsuited hound dog]);
	else if(have_familiar($familiar[baby gravy fairy]))
		use_familiar($familiar[baby gravy fairy]);
	if(available_amount($item[fire axe])<1)
		take_stash(1,$item[fire axe]);
		
	cli_execute("ballpit");
	if(my_name()=="twistedmage")
	{
		use_skill($skill[spirit of peppermint]);
		equip($item[ittah bittah hookah]);
		cli_execute("use jackass plumber home game");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("use moveable feast");
		if(!to_boolean(get_property("telescopeLookedHigh")))
			cli_execute("telescope high");
	}
	if(available_amount($item[pulled porquoise earring])<1)
		take_stash(1,$item[pulled porquoise earring]);
	cli_execute("maximize hot resistance, 0.01 muscle, equip fire axe, equip fireman's helmet, equip pulled porquoise earring, -equip sugar shorts");
	mood_snakes();
}

void prepare_for_bats()
{
	if(have_familiar($familiar[frumious bandersnatch]))
		use_familiar($familiar[frumious bandersnatch]);
	cli_execute("shrug ode");
	if(my_name()=="twistedmage")
	{
		use_skill($skill[spirit of peppermint]);
		outfit("fires");
		equip($item[Li'l Businessman Kit]);
		cli_execute("use jackass plumber home game");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("use moveable feast");
		cli_execute("ballpit");
		cli_execute("mcd 0");
		if(!to_boolean(get_property("telescopeLookedHigh")))
			cli_execute("telescope high");
		//cli_execute("maximize 0.1 spell damage percent, hot resistance");
	}
	mood_bats();
}

void prepare_for_bricks()
{
	if(have_familiar($familiar[jumpsuited hound dog]))
		use_familiar($familiar[jumpsuited hound dog]);
	else if(have_familiar($familiar[baby gravy fairy]))
		use_familiar($familiar[baby gravy fairy]);
		
	cli_execute("ballpit");
	if(my_name()=="twistedmage")
	{
		use_skill($skill[spirit of peppermint]);
		equip($item[ittah bittah hookah]);
		cli_execute("use jackass plumber home game");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("pool strategic");
		cli_execute("use moveable feast");
		if(!to_boolean(get_property("telescopeLookedHigh")))
			cli_execute("telescope high");
		cli_execute("maximize items, 0.01 hp, equip enchanted fire extinguisher");
	}
	else
	{
		if(available_amount($item[fire axe])<1)
			take_stash(1,$item[fire axe]);
		if(available_amount($item[pulled porquoise earring])<1)
			take_stash(1,$item[pulled porquoise earring]);
		cli_execute("maximize items, 0.01 hp, equip fire axe, equip fireman's helmet, equip pulled porquoise earring");
	}
	mood_bricks();
}

void do_fires()
{
//	if(my_name()=="twistedmage" && have_effect($effect[Extra wet])<1)
//	{
////		string dump=visit_url("shop.php?pwd&whichshop=fdkol&action=buyitem&whichitem=5708&quantity=1");
//		use(1,$item[drop of water-37]);
//	}
	string page = visit_url("plains.php?action=brushfire");
		
	while(!contains_text(page,"Do it again"))
	{
		if(my_name()=="twistedmage")
			page=use_skill($skill[snowclone]);
		else
		{
			page=attack();
			if(!contains_text(page,"Do it again") && !contains_text(page,"1 (<font color=blue><b>"))
				abort("didn't do any cold damage");
		}
	}
	if(my_name()=="twistedmage" && !contains_text(page,"6 FDKOL commendations"))
		abort("Didn't get enough commendations!");
	if(my_name()!="twistedmage" && !contains_text(page,"4 FDKOL commendations"))
		abort("Didn't get enough commendations!");
}

void do_snakes()
{
	string page = visit_url("adventure.php?snarfblat=290");
	
	while(!contains_text(page,"Adventure Again"))
	{
		page=attack();
		if(!contains_text(page,"Do it again") && !contains_text(page," (<font color=blue><b>+200"))
			abort("didn't do any cold damage");
	}
	if(!contains_text(page,"4 FDKOL commendations"))
		abort("Didn't get enough commendations!");
	if(contains_text(page,"hot egg") && my_name()=="twistedmage")
	{
		abort("Looks like you got an egg! Restart script!");
	}
}

void do_bats()
{
	string page = visit_url("adventure.php?snarfblat=291");
	
	while(!contains_text(page,"Adventure Again"))
	{
		page=use_skill($skill[saucegeyser]);
		if(!contains_text(page,"Adventure Again") && !contains_text(page,"dealing <font color=blue><b>"))
			abort("didn't do any cold damage");
	}
	if(!contains_text(page,"4 FDKOL commendations"))
		abort("Didn't get enough commendations!");
}

void do_bricks()
{
	string page = visit_url("adventure.php?snarfblat=292");
		
	while(!contains_text(page,"Adventure Again"))
	{
		if(my_name()=="twistedmage")
			page=use_skill($skill[saucegeyser]);
		else
			page=attack();
		if(!contains_text(page,"Adventure Again") && !contains_text(page,"(<font color=blue><b>"))
			abort("didn't do any cold damage");
	}
}

void main()
{
	if(available_amount($item[hot daub bun])<1 && available_amount($item[molten brick])>14)
		create(1,$item[hot daub bun]);
	if(available_amount($item[ foot-long hot daub])<1 && available_amount($item[molten brick])>16)
		create(1,$item[ foot-long hot daub]);
	if(available_amount($item[ hot daub stand])<1 && available_amount($item[molten brick])>18)
		create(1,$item[ hot daub stand]);
	if((my_inebriety()<(inebriety_limit()) || my_fullness()<(fullness_limit()) || my_spleen_use()<(spleen_limit()))) //if over level 5 eat
	{
		//spleen first in case it uses cleaning items
		eatdrink(0,0,spleen_limit(),false,500,2,1,1000,false);
		//now eat
		eatdrink(fullness_limit(),0,spleen_limit(),false,500,2,1,1000,false);
		//finally pull etc and drink
		drink_with_tps(20000,false);
	}
	cli_execute("pvp.ash");
	cli_execute("mood fire");
	cli_execute("trigger clear");
	
	//pull gear
	if(available_amount($item[fireman's helmet])<1)
		take_stash(1,$item[fireman's helmet]);
		
	//prepare
//	if(my_name()!="twistedmage")
//		prepare_for_snakes();
//	else
//		prepare_for_bats();
	if(!have_outfit("Hot Daub Ensemble"))
		prepare_for_bricks();
	else
		prepare_for_snakes();
	
	//fight
	while(my_adventures()>0 && my_inebriety()<=inebriety_limit())
	{
		if(available_amount($item[fdkol commendation])>3499 && !have_skill($skill[Frigidalmatian]))
			abort("Buy frigidalmation spellbook!");
		cli_execute("mood execute");
		cli_execute("restore hp");
		cli_execute("restore mp");
		
//		if(my_name()!="twistedmage")
//			do_snakes();
//		else
//			do_bats();
		if(!have_outfit("Hot Daub Ensemble"))
			do_bricks();
		else
			do_snakes();
	}
	
	//bed time
	if(my_adventures()==0 || my_inebriety()>inebriety_limit())
	{
		//return gear
		cli_execute("outfit birthday suit");
		if(available_amount($item[fireman's helmet])>0)
			put_stash(1,$item[fireman's helmet]);
		if(available_amount($item[fire axe])>0)
			put_stash(1,$item[fire axe]);
		if(available_amount($item[pulled porquoise earring])>0)
			put_stash(1,$item[pulled porquoise earring]);
		if(can_interact() && have_effect($effect[ode to booze])==0)
		{
			if(have_effect($effect[The Sonata of Sneakiness])!=0)
			{
				cli_execute("uneffect The Sonata of Sneakiness");
			}
			if(have_effect($effect[Ur-Kel's Aria of Annoyance])!=0)
			{
				cli_execute("uneffect Ur-Kel's Aria of Annoyance");
			}
			if(have_effect($effect[Carlweather's Cantata of Confrontation])!=0)
			{
				cli_execute("uneffect Carlweather's Cantata of Confrontation");
			}
			meatmail("Noblesse Oblige",16);
			meatmail("Testudinata",11);
		}
		wait(30);
		drink_with_tps(20000,true);
		if(my_inebriety()>inebriety_limit())
		{
			cli_execute("maximize adv");
			cli_execute("exit");
		}
	}
}