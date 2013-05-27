import <Universal_recovery.ash>

item improvement(item [item] upgrade){
	item best;
	int profit = 0;
	int test_profit;
	foreach key in upgrade {
		test_profit = mall_price(upgrade[key]) - mall_price(key);
		if(test_profit > profit) {
			best = key;
			profit = test_profit;
		}
	}
	return best;
}

boolean improve_spirits() {
	if(my_class() != $class[disco bandit] && my_class() != $class[accordion thief]) {
		print("You're not a moxie class, so no booze refinement for you.", "blue");
		return false;
	}
	if(!can_interact() || !have_skill($skill[superhuman cocktailcrafting])) {
		print("You're too small to refine booze.", "blue");
		return false;
	}
	if(stills_available() == 0) {
		print("you have no uses left at the still", "#FFA500");
		return false;
	}
	cli_execute("stash take * bottle of sewage schnapps");
	int sewage=item_amount($item[bottle of sewage schnapps]);
	if(sewage>stills_available())
	{
		sewage=stills_available();
	}
	create(sewage,$item[bottle of Ooze-O]);
	cli_execute("stash put * bottle of sewage schnapps");
	cli_execute("csend * bottle of Ooze-O to twistedmage");

	/*
	int drinks = (stills_available()+item_amount($item[Boxed champagne]))/2;
	retrieve_item(drinks, $item[orange]);
	create(drinks, $item[kumquat]);
	if(stash_amount($item[boxed wine])>=stills_available())
	{
		take_stash(stills_available(), $item[boxed wine]);
		create(stills_available(), $item[Boxed champagne]);
	}
	else if(stash_amount($item[bottle of gin])>=stills_available())
	{
		retrieve_item(stills_available(), $item[boxed wine]);
		create(stills_available(), $item[Boxed champagne]);
	}
	create(drinks, $item[Gordon Bennett]);
	cli_execute("stash put * Gordon Bennett");
	*/

	item [item] upgrade;
	upgrade[$item[bottle of gin]] = $item[bottle of Calcutta Emerald];
	upgrade[$item[bottle of rum]] = $item[bottle of Lieutenant Freeman];
	upgrade[$item[bottle of tequila]] = $item[bottle of Jorge Sinsonte];
	upgrade[$item[bottle of vodka]] = $item[bottle of Definit];
	upgrade[$item[bottle of whiskey]] = $item[bottle of Domesticated Turkey];
	upgrade[$item[boxed wine]] = $item[boxed champagne];
	upgrade[$item[grapefruit]] = $item[tangerine];
	upgrade[$item[lemon]] = $item[kiwi];
	upgrade[$item[olive]] = $item[cocktail onion];
	upgrade[$item[orange]] = $item[kumquat];
	upgrade[$item[soda water]] = $item[tonic water];
	upgrade[$item[strawberry]] = $item[raspberry];
	upgrade[$item[bottle of sake]] = $item[bottle of Pete's Sake];
	item still = improvement(upgrade);
	print("Creating " + stills_available()+ " " +upgrade[still]+ " to sell @ "+mall_price(upgrade[still]), "blue");
	retrieve_item(stills_available(), still);
	create(stills_available(), upgrade[still]);
	return true;
}

void prismatic_breakfast() {
	int pris_left = 3 - to_int(get_property("prismaticSummons"));
      	if(have_skill($skill[Rainbow Gravitation]) && pris_left > 0)
	{
		cli_execute("Rainbow Gravitation.ash");
	}
}

boolean zappp(item whatsit) {
   print("zapping "+whatsit, "green");
   if (item_amount(whatsit) == 0) return false;
   cli_execute("zap 1 "+whatsit);
   return true;
}

//tries to complete a 3 piece set passed in
boolean zap_set(item set_item_1, item set_item_2, item set_item_3)
{
	print("checking zap set:"+set_item_1+" "+set_item_2+" "+set_item_3,"green");
	if(available_amount(set_item_1)==0 || available_amount(set_item_2)==0 || available_amount(set_item_3)==0)
	{
		print("Set incomplete!","green");
		if(available_amount(set_item_1)>1)
		{
			print("zapping "+set_item_1,"olive");
			zappp(set_item_1);
			return true;
		}
		if(available_amount(set_item_2)>1)
		{
			print("zapping "+set_item_2,"olive");
			zappp(set_item_2);
			return true;
		}
		if(available_amount(set_item_3)>1)
		{
			print("zapping "+set_item_3,"olive");
			zappp(set_item_3);
			return true;
		}
	}
	return false;
}


//tries to complete a tiny plastic set passed in, from stash
boolean stash_zap(item set_item_1, item set_item_2, item set_item_3, item set_item_4, item set_item_5, item set_item_6, item set_item_7, item set_item_8, item set_item_9, item set_item_10, item set_item_11, item set_item_12, item set_item_13, item set_item_14, item set_item_15, item set_item_16,item set_item_17, item set_item_18, item set_item_19, item set_item_20, item set_item_21, item set_item_22, item set_item_23, item set_item_24, item set_item_25, item set_item_26, item set_item_27, item set_item_28, item set_item_29, item set_item_30, item set_item_31, item set_item_32,item set_item_33, item set_item_34, item set_item_35, item set_item_36, item set_item_37, item set_item_38, item set_item_39, item set_item_40, item set_item_41, item set_item_42, item set_item_43, item set_item_44, item set_item_45, item set_item_46, item set_item_47, item set_item_48, item set_item_49, item set_item_50)
{
	boolean zapped=false;
	if(stash_amount(set_item_1)==0 || stash_amount(set_item_2)==0 || stash_amount(set_item_3)==0 || stash_amount(set_item_4)==0 || stash_amount(set_item_5)==0 || stash_amount(set_item_6)==0 || stash_amount(set_item_7)==0 || stash_amount(set_item_8)==0 || stash_amount(set_item_9)==0 || stash_amount(set_item_10)==0 || stash_amount(set_item_11)==0 || stash_amount(set_item_12)==0 || stash_amount(set_item_13)==0 || stash_amount(set_item_14)==0 || stash_amount(set_item_15)==0 || stash_amount(set_item_16)==0 || stash_amount(set_item_17)==0 || stash_amount(set_item_18)==0 || stash_amount(set_item_19)==0 || stash_amount(set_item_20)==0 || stash_amount(set_item_21)==0 || stash_amount(set_item_22)==0 || stash_amount(set_item_23)==0 || stash_amount(set_item_24)==0 || stash_amount(set_item_25)==0 || stash_amount(set_item_26)==0 || stash_amount(set_item_27)==0 || stash_amount(set_item_28)==0 || stash_amount(set_item_29)==0 || stash_amount(set_item_30)==0 || stash_amount(set_item_31)==0 || stash_amount(set_item_32)==0 || stash_amount(set_item_33)==0 || stash_amount(set_item_34)==0 || stash_amount(set_item_35)==0 || stash_amount(set_item_36)==0 || stash_amount(set_item_37)==0 || stash_amount(set_item_38)==0 || stash_amount(set_item_39)==0 || stash_amount(set_item_40)==0 || stash_amount(set_item_41)==0 || stash_amount(set_item_42)==0 || stash_amount(set_item_43)==0 || stash_amount(set_item_44)==0 || stash_amount(set_item_45)==0 || stash_amount(set_item_46)==0 || stash_amount(set_item_47)==0 || stash_amount(set_item_48)==0 || stash_amount(set_item_49)==0 || stash_amount(set_item_50)==0)
	{
		if(stash_amount(set_item_1)>1)
		{
			print("zapping "+set_item_1, "olive"); cli_execute("stash take 1 "+set_item_1);
			zappp(set_item_1);
			zapped= true;
		}
		else if(stash_amount(set_item_2)>1)
		{
			print("zapping "+set_item_2, "olive"); cli_execute("stash take 1 "+set_item_2);
			zappp(set_item_2);
			zapped= true;
		}
		else if(stash_amount(set_item_3)>1)
		{
			print("zapping "+set_item_3, "olive"); cli_execute("stash take 1 "+set_item_3);
			zappp(set_item_3);
			zapped= true;
		}
		else if(stash_amount(set_item_4)>1)
		{
			print("zapping "+set_item_4, "olive"); cli_execute("stash take 1 "+set_item_4);
			zappp(set_item_4);
			zapped= true;
		}
		else if(stash_amount(set_item_5)>1)
		{
			print("zapping "+set_item_5, "olive"); cli_execute("stash take 1 "+set_item_5);
			zappp(set_item_5);
			zapped= true;
		}
		else if(stash_amount(set_item_6)>1)
		{
			print("zapping "+set_item_6, "olive"); cli_execute("stash take 1 "+set_item_6);
			zappp(set_item_6);
			zapped= true;
		}
		else if(stash_amount(set_item_7)>1)
		{
			print("zapping "+set_item_7, "olive"); cli_execute("stash take 1 "+set_item_7);
			zappp(set_item_7);
			zapped= true;
		}
		else if(stash_amount(set_item_8)>1)
		{
			print("zapping "+set_item_8, "olive"); cli_execute("stash take 1 "+set_item_8);
			zappp(set_item_8);
			zapped= true;
		}
		else if(stash_amount(set_item_9)>1)
		{
			print("zapping "+set_item_9, "olive"); cli_execute("stash take 1 "+set_item_9);
			zappp(set_item_9);
			zapped= true;
		}
		else if(stash_amount(set_item_10)>1)
		{
			print("zapping "+set_item_10, "olive"); cli_execute("stash take 1 "+set_item_10);
			zappp(set_item_10);
			zapped= true;
		}
		else if(stash_amount(set_item_11)>1)
		{
			print("zapping "+set_item_11, "olive"); cli_execute("stash take 1 "+set_item_11);
			zappp(set_item_11);
			zapped= true;
		}
		else if(stash_amount(set_item_12)>1)
		{
			print("zapping "+set_item_12, "olive"); cli_execute("stash take 1 "+set_item_12);
			zappp(set_item_12);
			zapped= true;
		}
		else if(stash_amount(set_item_13)>1)
		{
			print("zapping "+set_item_13, "olive"); cli_execute("stash take 1 "+set_item_13);
			zappp(set_item_13);
			zapped= true;
		}
		else if(stash_amount(set_item_14)>1)
		{
			print("zapping "+set_item_14, "olive"); cli_execute("stash take 1 "+set_item_14);
			zappp(set_item_14);
			zapped= true;
		}
		else if(stash_amount(set_item_15)>1)
		{
			print("zapping "+set_item_15, "olive"); cli_execute("stash take 1 "+set_item_15);
			zappp(set_item_15);
			zapped= true;
		}
		else if(stash_amount(set_item_16)>1)
		{
			print("zapping "+set_item_16, "olive"); cli_execute("stash take 1 "+set_item_16);
			zappp(set_item_16);
			zapped= true;
		}
		else if(stash_amount(set_item_17)>1)
		{
			print("zapping "+set_item_17, "olive"); cli_execute("stash take 1 "+set_item_17);
			zappp(set_item_17);
			zapped= true;
		}
		else if(stash_amount(set_item_18)>1)
		{
			print("zapping "+set_item_18, "olive"); cli_execute("stash take 1 "+set_item_18);
			zappp(set_item_18);
			zapped= true;
		}
		else if(stash_amount(set_item_19)>1)
		{
			print("zapping "+set_item_19, "olive"); cli_execute("stash take 1 "+set_item_19);
			zappp(set_item_19);
			zapped= true;
		}
		else if(stash_amount(set_item_20)>1)
		{
			print("zapping "+set_item_20, "olive"); cli_execute("stash take 1 "+set_item_20);
			zappp(set_item_20);
			zapped= true;
		}
		else if(stash_amount(set_item_21)>1)
		{
			print("zapping "+set_item_21, "olive"); cli_execute("stash take 1 "+set_item_21);
			zappp(set_item_21);
			zapped= true;
		}
		else if(stash_amount(set_item_22)>1)
		{
			print("zapping "+set_item_22, "olive"); cli_execute("stash take 1 "+set_item_22);
			zappp(set_item_22);
			zapped= true;
		}
		else if(stash_amount(set_item_23)>1)
		{
			print("zapping "+set_item_23, "olive"); cli_execute("stash take 1 "+set_item_23);
			zappp(set_item_23);
			zapped= true;
		}
		else if(stash_amount(set_item_24)>1)
		{
			print("zapping "+set_item_24, "olive"); cli_execute("stash take 1 "+set_item_24);
			zappp(set_item_24);
			zapped= true;
		}
		else if(stash_amount(set_item_25)>1)
		{
			print("zapping "+set_item_25, "olive"); cli_execute("stash take 1 "+set_item_25);
			zappp(set_item_25);
			zapped= true;
		}
		else if(stash_amount(set_item_26)>1)
		{
			print("zapping "+set_item_26, "olive"); cli_execute("stash take 1 "+set_item_26);
			zappp(set_item_26);
			zapped= true;
		}
		else if(stash_amount(set_item_27)>1)
		{
			print("zapping "+set_item_27, "olive"); cli_execute("stash take 1 "+set_item_27);
			zappp(set_item_27);
			zapped= true;
		}
		else if(stash_amount(set_item_28)>1)
		{
			print("zapping "+set_item_28, "olive"); cli_execute("stash take 1 "+set_item_28);
			zappp(set_item_28);
			zapped= true;
		}
		else if(stash_amount(set_item_29)>1)
		{
			print("zapping "+set_item_29, "olive"); cli_execute("stash take 1 "+set_item_29);
			zappp(set_item_29);
			zapped= true;
		}
		else if(stash_amount(set_item_30)>1)
		{
			print("zapping "+set_item_30, "olive"); cli_execute("stash take 1 "+set_item_30);
			zappp(set_item_30);
			zapped= true;
		}
		else if(stash_amount(set_item_31)>1)
		{
			print("zapping "+set_item_31, "olive"); cli_execute("stash take 1 "+set_item_31);
			zappp(set_item_31);
			zapped= true;
		}
		else if(stash_amount(set_item_32)>1)
		{
			print("zapping "+set_item_32, "olive"); cli_execute("stash take 1 "+set_item_32);
			zappp(set_item_32);
			zapped= true;
		}
		else if(stash_amount(set_item_33)>1)
		{
			print("zapping "+set_item_33, "olive"); cli_execute("stash take 1 "+set_item_33);
			zappp(set_item_33);
			zapped= true;
		}
		else if(stash_amount(set_item_34)>1)
		{
			print("zapping "+set_item_34, "olive"); cli_execute("stash take 1 "+set_item_34);
			zappp(set_item_34);
			zapped= true;
		}
		else if(stash_amount(set_item_35)>1)
		{
			print("zapping "+set_item_35, "olive"); cli_execute("stash take 1 "+set_item_35);
			zappp(set_item_35);
			zapped= true;
		}
		else if(stash_amount(set_item_36)>1)
		{
			print("zapping "+set_item_36, "olive"); cli_execute("stash take 1 "+set_item_36);
			zappp(set_item_36);
			zapped= true;
		}
		else if(stash_amount(set_item_37)>1)
		{
			print("zapping "+set_item_37, "olive"); cli_execute("stash take 1 "+set_item_37);
			zappp(set_item_37);
			zapped= true;
		}
		else if(stash_amount(set_item_38)>1)
		{
			print("zapping "+set_item_38, "olive"); cli_execute("stash take 1 "+set_item_38);
			zappp(set_item_38);
			zapped= true;
		}
		else if(stash_amount(set_item_39)>1)
		{
			print("zapping "+set_item_39, "olive"); cli_execute("stash take 1 "+set_item_39);
			zappp(set_item_39);
			zapped= true;
		}
		else if(stash_amount(set_item_40)>1)
		{
			print("zapping "+set_item_40, "olive"); cli_execute("stash take 1 "+set_item_40);
			zappp(set_item_40);
			zapped= true;
		}
		else if(stash_amount(set_item_41)>1)
		{
			print("zapping "+set_item_41, "olive"); cli_execute("stash take 1 "+set_item_41);
			zappp(set_item_41);
			zapped= true;
		}
		else if(stash_amount(set_item_42)>1)
		{
			print("zapping "+set_item_42, "olive"); cli_execute("stash take 1 "+set_item_42);
			zappp(set_item_42);
			zapped= true;
		}
		else if(stash_amount(set_item_43)>1)
		{
			print("zapping "+set_item_43, "olive"); cli_execute("stash take 1 "+set_item_43);
			zappp(set_item_43);
			zapped= true;
		}
		else if(stash_amount(set_item_44)>1)
		{
			print("zapping "+set_item_44, "olive"); cli_execute("stash take 1 "+set_item_44);
			zappp(set_item_44);
			zapped= true;
		}
		else if(stash_amount(set_item_45)>1)
		{
			print("zapping "+set_item_45, "olive"); cli_execute("stash take 1 "+set_item_45);
			zappp(set_item_45);
			zapped= true;
		}
		else if(stash_amount(set_item_46)>1)
		{
			print("zapping "+set_item_46, "olive"); cli_execute("stash take 1 "+set_item_46);
			zappp(set_item_46);
			zapped= true;
		}
		else if(stash_amount(set_item_47)>1)
		{
			print("zapping "+set_item_47, "olive"); cli_execute("stash take 1 "+set_item_47);
			zappp(set_item_47);
			zapped= true;
		}
		else if(stash_amount(set_item_48)>1)
		{
			print("zapping "+set_item_48, "olive"); cli_execute("stash take 1 "+set_item_48);
			zappp(set_item_48);
			zapped= true;
		}
		else if(stash_amount(set_item_49)>1)
		{
			print("zapping "+set_item_49, "olive"); 
			cli_execute("stash take 1 "+set_item_49);
			zappp(set_item_49);
			zapped= true;
		}
		else if(stash_amount(set_item_50)>1)
		{
			print("zapping "+set_item_50, "olive");
			cli_execute("stash take 1 "+set_item_50);
			zappp(set_item_50);
			zapped= true;
		}
	}
	cli_execute("stash put * "+set_item_1);
	cli_execute("stash put * "+set_item_2);
	cli_execute("stash put * "+set_item_3);
	cli_execute("stash put * "+set_item_4);
	cli_execute("stash put * "+set_item_5);
	cli_execute("stash put * "+set_item_6);
	cli_execute("stash put * "+set_item_7);
	cli_execute("stash put * "+set_item_8);
	cli_execute("stash put * "+set_item_9);
	cli_execute("stash put * "+set_item_10);
	cli_execute("stash put * "+set_item_11);
	cli_execute("stash put * "+set_item_12);
	cli_execute("stash put * "+set_item_13);
	cli_execute("stash put * "+set_item_14);
	cli_execute("stash put * "+set_item_15);
	cli_execute("stash put * "+set_item_16);
	cli_execute("stash put * "+set_item_17);
	cli_execute("stash put * "+set_item_18);
	cli_execute("stash put * "+set_item_19);
	cli_execute("stash put * "+set_item_20);
	cli_execute("stash put * "+set_item_21);
	cli_execute("stash put * "+set_item_22);
	cli_execute("stash put * "+set_item_23);
	cli_execute("stash put * "+set_item_24);
	cli_execute("stash put * "+set_item_25);
	cli_execute("stash put * "+set_item_26);
	cli_execute("stash put * "+set_item_27);
	cli_execute("stash put * "+set_item_28);
	cli_execute("stash put * "+set_item_29);
	cli_execute("stash put * "+set_item_30);
	cli_execute("stash put * "+set_item_31);
	cli_execute("stash put * "+set_item_32);
	cli_execute("stash put * "+set_item_33);
	cli_execute("stash put * "+set_item_34);
	cli_execute("stash put * "+set_item_35);
	cli_execute("stash put * "+set_item_36);
	cli_execute("stash put * "+set_item_37);
	cli_execute("stash put * "+set_item_38);
	cli_execute("stash put * "+set_item_39);
	cli_execute("stash put * "+set_item_40);
	cli_execute("stash put * "+set_item_41);
	cli_execute("stash put * "+set_item_42);
	cli_execute("stash put * "+set_item_43);
	cli_execute("stash put * "+set_item_44);
	cli_execute("stash put * "+set_item_45);
	cli_execute("stash put * "+set_item_46);
	cli_execute("stash put * "+set_item_47);
	cli_execute("stash put * "+set_item_48);
	cli_execute("stash put * "+set_item_49);
	cli_execute("stash put * "+set_item_50);
	return zapped;
}


boolean daily_zap(boolean safe) {
	print("Looking to zap...");
	set_property("choiceAdventure25", "3");
	int whichwand = 0;
	for i from 1268 to 1272
		if(item_amount(to_item(i)) > 0) whichwand = i;
	switch {
	case whichwand == 0:
		print("You don't have a wand.", "red");
		set_property("choiceAdventure25", "2");
		return false;
	case (contains_text(visit_url("wand.php?whichwand="+whichwand),"feels warm") && safe):
			print("Already zapped today. Afraid of Kabloo-ey!", "red");
			return true;
	//zap sets
	case zap_set($item[boris's key],$item[sneaky pete's key],$item[jarlsberg's key]):
	case zap_set($item[hardened slime pants], $item[hardened slime belt],$item[hardened slime hat]):
	case zap_set($item[Chester's bag of candy], $item[Chester's cutoffs],$item[Chester's moustache]):
	case zap_set($item[Ol' Scratch's ash can], $item[Ol' Scratch's ol' britches],$item[Ol' Scratch's stovepipe hat]):
	case zap_set($item[Oscus's dumpster waders], $item[Oscus's pelt],$item[Wand of Oscus]):
	case zap_set($item[Zombo's grievous greaves], $item[Zombo's shield],$item[Zombo's skullcap]):
	case zap_set($item[Hodgman's bow tie], $item[Hodgman's lobsterskin pants],$item[Hodgman's porkpie hat]):
//tiny plastic 1+2 rares
//	case stash_zap($item[tiny plastic boris],$item[tiny plastic jarlsberg],$item[tiny plastic sneaky pete],$item[tiny plastic susie], $item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie], $item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie], $item[tiny plastic susie],$item[tiny plastic susie], $item[tiny plastic susie],$item[tiny plastic susie], $item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie],$item[tiny plastic susie]):
//	case stash_zap($item[tiny plastic Ed the Undying],$item[tiny plastic Lord Spookyraven],$item[tiny plastic Dr. Awkward],$item[tiny plastic protector spectre], $item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying], $item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying], $item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying], $item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying], $item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying],$item[tiny plastic Ed the Undying]):
//tiny plastic 1+2 semi-rares
//	case stash_zap($item[tiny plastic disco bandit],$item[tiny plastic accordion thief],$item[tiny plastic turtle tamer],$item[tiny plastic seal clubber], $item[tiny plastic pastamancer],$item[tiny plastic sauceror],$item[tiny plastic bitchin' meatcar],$item[tiny plastic hermit],$item[tiny plastic disco bandit], $item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit], $item[tiny plastic disco bandit],$item[tiny plastic disco bandit], $item[tiny plastic disco bandit],$item[tiny plastic disco bandit], $item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit],$item[tiny plastic disco bandit]):
//	case stash_zap($item[tiny plastic baron von ratsworth],$item[tiny plastic boss bat],$item[tiny plastic Knob Goblin King],$item[tiny plastic Bonerdagon], $item[tiny plastic The Man],$item[tiny plastic The Big Wisniewski],$item[tiny plastic Felonia],$item[tiny plastic Beelzebozo],$item[tiny plastic conservationist hippy], $item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat], $item[tiny plastic boss bat],$item[tiny plastic boss bat], $item[tiny plastic boss bat],$item[tiny plastic boss bat], $item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat],$item[tiny plastic boss bat]):
//tiny plastic 1+2 commons
//	case stash_zap($item[tiny plastic Mosquito],$item[tiny plastic leprechaun],$item[tiny plastic levitating potato],$item[tiny plastic angry goat], $item[tiny plastic sabre-toothed lime],$item[tiny plastic fuzzy dice],$item[tiny plastic spooky pirate skeleton],$item[tiny plastic barrrnacle],$item[tiny plastic howling balloon monkey], $item[tiny plastic stab bat],$item[tiny plastic grue],$item[tiny plastic blood-faced volleyball],$item[tiny plastic ghuol whelp],$item[tiny plastic baby gravy fairy], $item[tiny plastic cocoabo],$item[tiny plastic star starfish], $item[tiny plastic ghost pickle on a stick],$item[tiny plastic killer bee], $item[tiny plastic cheshire bat],$item[tiny plastic coffee pixie],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito],$item[tiny plastic Mosquito]):
//	case stash_zap($item[tiny plastic 7-foot dwarf],$item[tiny plastic angry bugbear],$item[tiny plastic anime smiley],$item[tiny plastic apathetic lizardman], $item[tiny plastic astronomer],$item[tiny plastic beanbat],$item[tiny plastic blooper],$item[tiny plastic brainsweeper],$item[tiny plastic briefcase bat], $item[tiny plastic demoninja],$item[tiny plastic filthy hippy jewelry maker],$item[tiny plastic drunk goat],$item[tiny plastic fiendish can of asparagus],$item[tiny plastic Gnollish crossdresser], $item[tiny plastic handsome mariachi],$item[tiny plastic Knob Goblin bean counter], $item[tiny plastic Knob Goblin harem girl],$item[tiny plastic Knob Goblin mad scientist], $item[tiny plastic Knott Yeti],$item[tiny plastic lemon-in-the-box],$item[tiny plastic lobsterfrogman],$item[tiny plastic ninja snowman],$item[tiny plastic Orcish Frat Boy],$item[tiny plastic G imp], $item[tiny plastic goth giant],$item[tiny plastic cubist bull],$item[tiny plastic scary clown],$item[tiny plastic smarmy pirate],$item[tiny plastic spiny skelelton], $item[tiny plastic Spam Witch],$item[tiny plastic spooky vampire],$item[tiny plastic taco cat],$item[tiny plastic undead elbow macaroni],$item[tiny plastic warwelf], $item[tiny plastic whitesnake],$item[tiny plastic XXX pr0n], $item[tiny plastic zmobie],$item[tiny plastic Protagonist], $item[tiny plastic Spunky Princess],$item[tiny plastic topiary golem],$item[tiny plastic senile lihc],$item[tiny plastic Iiti Kitty],$item[tiny plastic Gnomester Blomester],$item[tiny plastic Trouser Snake], $item[tiny plastic Axe Wound],$item[tiny plastic Hellion],$item[tiny plastic Black Knight],$item[tiny plastic giant pair of tweezers], $item[tiny plastic fruit golem],$item[tiny plastic fluffy bunny]):
//	case zap_set($item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ], $item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ], $item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ],$item[tiny plastic ], $item[tiny plastic ],$item[tiny plastic ], $item[tiny plastic ],$item[tiny plastic ], $item[tiny plastic ],$item[tiny plastic ],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[],$item[]):
	case zappp($item[slime-soaked sweat gland]):
	case (available_amount($item[slime-soaked brain])>1 && zappp($item[slime-soaked brain])):
	case zappp($item[green-frosted astral cupcake]):
	case zappp($item[orange-frosted astral cupcake]):
	case zappp($item[purple-frosted astral cupcake]):
	case zappp($item[33398 scroll]):
		return true;
	default:
		print("You have nothing more to zap.","red");
	}
	return false;
}


void dailybuffs()
{
	if(have_skill($skill[Elron's Explosive Etude]))
	{
		print("trying to cast "+$skill[Elron's Explosive Etude]+" on twistedmage");//cast amap
		while(!contains_text(visit_url("skills.php?action=Skillz.&whichskill=6022&specificplayer=1192853&bufftimes=1&pwd"),"can't cast that many"))
		{
			if( my_mp() <= 50)
 			{	
				int amount =50;
				objective=amount;
				
					mp_heal(amount);
				
 			}
			print("casted 1 "+$skill[Elron's Explosive Etude]+" on twistedmage");//cast amap
		}
		cli_execute("status refresh");
	}
	if(have_skill($skill[The Ballad of Richie Thingfinder]))
	{
		while(!contains_text(visit_url("skills.php?action=Skillz.&whichskill=6020&specificplayer=1192853&bufftimes=1&pwd"),"can't cast that many"))
		{
			print("casting 1 "+$skill[The Ballad of Richie Thingfinder]+" on twistedmage");//cast amap
		}
		cli_execute("status refresh");
	}
	if(have_skill($skill[Benetton's Medley of Diversity]))
	{
		while(!contains_text(visit_url("skills.php?action=Skillz.&whichskill=6021&specificplayer=1192853&bufftimes=1&pwd"),"can't cast that many"))
		{
			print("casting 1 "+$skill[Benetton's Medley of Diversity]+" on twistedmage");//cast amap
		}
		cli_execute("status refresh");
	}
	if(have_skill($skill[Chorale of Companionship]))
	{
		while(!contains_text(visit_url("skills.php?action=Skillz.&whichskill=6023&specificplayer=1192853&bufftimes=1&pwd"),"can't cast that many"))
		{
			print("casting 1 "+$skill[Chorale of Companionship]+" on twistedmage");//cast amap
		}
		cli_execute("status refresh");
	}
	if(have_skill($skill[Prelude of Precision]))
	{
		while(!contains_text(visit_url("skills.php?action=Skillz.&whichskill=6024&specificplayer=1192853&bufftimes=1&pwd"),"can't cast that many"))
		{
			print("casting 1 "+$skill[Prelude of Precision]+" on twistedmage");//cast amap
		}
		cli_execute("status refresh");
	}
	if(have_skill($skill[Donho's Bubbly Ballad]))
	{
		while(!contains_text(visit_url("skills.php?action=Skillz.&whichskill=6026&specificplayer=1192853&bufftimes=1&pwd"),"can't cast that many"))
		{
			print("casting 1 "+$skill[Donho's Bubbly Ballad]+" on twistedmage");//cast amap
		}
		cli_execute("status refresh");
	}
}

void banquet() {
	improve_spirits();
	prismatic_breakfast();
	//open all chests etc
	cli_execute("use * less-than-three-shaped box");
	if(can_interact())
	{
		cli_execute("use * smoldering box");
	}
	cli_execute("use * anniversary gift box");
	cli_execute("use * Chester's bag of candy");
	cli_execute("use * small slimy cyst");
	cli_execute("use * tiny slimy cyst");
	cli_execute("use * medium slimy cyst");
	cli_execute("use * big slimy cyst");
	cli_execute("use * Penultimate Fantasy chest");
	cli_execute("use * small box");
	cli_execute("use * large box");
	cli_execute("use * dead mimic");
   	cli_execute( "use * ancient cursed foot locker");
   	cli_execute( "use * ornate ancient cursed chest");
   	cli_execute( "use * gilded ancient cursed chest");
   	cli_execute( "use * flytrap pellet");
   	cli_execute( "use * slimy chest");
   	cli_execute( "drink * steel margarita");
   	cli_execute( "eat * steel lasagna");
   	cli_execute( "use * steel-scented air freshener");
   	cli_execute( "use * Ancient vinyl coin purse");	
   	cli_execute( "use * Black pension check");	
   	cli_execute( "use * old coin purse");	
   	cli_execute( "use * old leather wallet");	
   	cli_execute( "use * Warm Subject gift certificate");	
   	cli_execute( "use * canopic jar");	
   	cli_execute( "use * briefcase");	
   	cli_execute( "use * Gnollish toolbox");
	cli_execute( "use * Mer-kin thingpouch");
	cli_execute( "use * 31337 scroll");
	cli_execute( "use * hermit script");
	cli_execute( "use * stat script");
	cli_execute( "use * meat globe");
	cli_execute( "use * fat wallet");
	cli_execute( "use * black picnic basket");
	cli_execute( "use * Boozehounds Anonymous token");
	cli_execute( "use * pile of candy");
	cli_execute( "use * scroll of pasta summoning");
	cli_execute( "use * six pack of Mountain Stream");
	cli_execute( "use * Frat Army FGF");
	cli_execute( "use * Hippy Army MPE");
	cli_execute("use * smudged alchemical recipe");
	cli_execute("use * imitation crab crate");
	cli_execute("use * six-pack of New Cloaca-Cola");
	cli_execute("use * spooky cosmetics bag");
	cli_execute("use * fisherman sack");
	cli_execute("use * wad of slimy rags");
	cli_execute("use * pixellated moneybag");
//	cli_execute("csend * lewd playing card to twistedmage");
	
	int scrolls = item_amount($item[inkwell]);
	if(scrolls>item_amount($item[disintegrating quill pen]))
	{
		scrolls = item_amount($item[disintegrating quill pen]);
	}
	if(scrolls>item_amount($item[tattered scrap of paper]))
	{
		scrolls = item_amount($item[tattered scrap of paper]);
	}
	use(scrolls,$item[disintegrating quill pen]);
	
	scrolls = item_amount($item[duct tape])/4;
	while(scrolls>0)
	{
		use(4,$item[duct tape]);
		scrolls=scrolls-1;
	}
//	cli_execute("use * ");
	cli_execute("use * pork elf goodies sack");
	cli_execute("use * duct tape wallet");
	cli_execute("autosell * dusty animal skull");
	cli_execute("use * duct tape wallet");
	cli_execute("autosell * crumbling rat skull");
	
	
	if(can_interact())
	{
		cli_execute("use * plain brown wrapper");
	}
	cli_execute("use * fat wallet");
	cli_execute( "use * bottle of used blood");
	cli_execute( "use * chest of the bonerdagon");
	
	//send some usables to twisted
	if(my_name()=="twistedmage")
	{
		cli_execute( "use * dollhive");
	}
	else
	{
		cli_execute( "csend * dollhive to twistedmage");
	}
	if(item_amount($item[underworld trunk])!=0)
	{
		abort("Do something with that underworld trunk man!");
	}
	daily_zap(true);

//	dailybuffs();
}

void main() {
	banquet();
}