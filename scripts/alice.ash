void sell_card(item card)
{
	int amount=available_amount(card);
	if(amount<7)
		return;
	visit_url("gamestore.php?action=tradein&whichitem="+to_int(card)+"&quantity="+(amount-6));
}

float get_efficiency(item it, float return_val)
{
	return return_val/mall_price(it);
}

void main()
{
	cli_execute("inventory refresh");
	cli_execute("use * Pack of Alice's Army Cards");
	cli_execute("use * Single Alice's Army Foil");
	cli_execute("use * Pack of Alice's Army Foil Cards");
	for id from 4967 to 5007
	{
		sell_card(to_item(id));
	}
	
	//individual foil has average return 92.5 at cost of 100 = 0.925
	//pack of foils has average return of 675 for cost of 750 = 0.867
	
	//now buy individual foils, or quit
	matcher credit_mtch = create_matcher("You currently have (\\d*) store credit",visit_url("gamestore.php?place=cashier"));
	find(credit_mtch);
	int num_foils=group(credit_mtch,1).to_int()/100;
	if(num_foils>0)
	{
		visit_url("gamestore.php?action=redeem&whichitem=5008&quantity="+num_foils);
	
		//call script again
		cli_execute("alice.ash");
	}
	else
	{
		print("currently have "+group(credit_mtch,1)+" credits","lime");
		
		//mall prices
		float pack_eff = get_efficiency($item[Pack of Alice's Army Cards],13.5);
		float foil_eff = get_efficiency($item[Single Alice's Army Foil],92.5);
		float pack_foil_eff = get_efficiency($item[Pack of Alice's Army Foil Cards],675);
		float boost_eff = get_efficiency($item[Alice's Army booster box],30.0*13.5);
		item best = $item[Pack of Alice's Army Cards];
		float best_eff = pack_eff;
		if(best_eff < foil_eff)
		{
			best = $item[Single Alice's Army Foil];
			best_eff = foil_eff;
		}
		if(best_eff < pack_foil_eff)
		{
			best = $item[Pack of Alice's Army Foil Cards];
			best_eff = pack_foil_eff;
		}
		if(best_eff < boost_eff)
		{
			best = $item[Alice's Army booster box];
			best_eff = boost_eff;
		}
		print("Max efficiency is "+best+" for "+mall_price(best)+" ("+best_eff+" meat per credit)","lime");
	}
}