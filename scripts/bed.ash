import <eatdrink.ash>;
import <awake.ash>;
import <zlib.ash>;
import <alt_farm.ash>;
import <sims_lib.ash>;


void main()
{
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
//clean bags--------------------------------------------------	
	setvar("priceAdvisor_obeyBuyLimit","true");
	cli_execute("set autoBuyPriceLimit = 20000");
	string catch = visit_url("store.php?whichstore=p");
	visit_url("store.php?whichstore=m");
	catch=visit_url("mrstore.php");
	catch = visit_url("clan_stash.php");
	cli_execute("ocd data creator.ash");
	cli_execute("ocd inventory control.ash");
	if(my_name()=="twistedmage")
	{
		//check advertising
		if(contains_text(visit_url("managestore.php"),"Current Budget: 0 Meat"))
		{
			visit_url("managestore.php?howmuch=10&advertising=Add+to+Budget&action=addad&pwd");
		}
		cli_execute("undercut no");
	}
	//return_gear();
//wear  bed set---------------------------------------------------------------------
	if( my_name() == "twistedmage")
	{
		if(item_amount($item[stinky cheese diaper])==0 && equipped_amount($item[stinky cheese diaper])==0)
		{
			cli_execute("fold stinky cheese diaper");
		}
		if(item_amount($item[loathing legion moondial])==0 && equipped_amount($item[loathing legion moondial])==0)
		{
			cli_execute("fold loathing legion moondial");
		}
		cli_execute( "maximize adventures, switch disembodied hand" );
	}
	else
	{
		cli_execute( "maximize adventures, -equip tiny plastic sword" );
	}
//check and make box servants-------------------------------
	if(!simons_have_bartender())
	{
		simons_get_bartender();
	}
	if(!simons_have_chef())
	{
		simons_get_chef();
	}
//nightcap--------------------------------------------------
    drink_with_tps(20000,true);
//burn all daily mana-----------------------------------------------------	
	//if completed nuns as frat
	if(get_property("sidequestNunsCompleted")=="fratboy")
	{
		string tmp = visit_url("island.php");
		//if island war finished
		if(get_property("warProgress")=="finished")
		{
			//while visits left
			while(to_int(get_property("nunsVisits"))<3)
			{
				cli_execute("burn *");
				cli_execute("mood execute");
				//press button
				visit_url("postwarisland.php?action=nuns&place=nunnery&pwd");
			}
		}
		else
		{
			//while visits left
			while(to_int(get_property("nunsVisits"))<3)
			{
				cli_execute("burn *");
				cli_execute("mood execute");
				//press button
				visit_url("bigisland.php?action=nuns&place=nunnery&pwd");
			}
		}
	}
	if(item_amount($item[oscus's neverending soda])!=0)
	{
		if(!get_property("oscusSodaUsed").to_boolean())
		{
			cli_execute("burn *");
			cli_execute("mood execute");
			use(1,$item[oscus's neverending soda]);
		}
	}
	if(item_amount($item[Platinum Yendorian Express Card])!=0)
	{
		if(!get_property("expressCardUsed").to_boolean())
		{
			cli_execute("burn *");
			cli_execute("mood execute");
			use(1,$item[Platinum Yendorian Express Card]);
		}
	}
	cli_execute("mood execute");
	int rest_mp = numeric_modifier("Base Resting MP") * (numeric_modifier("Resting MP Percent")+100) / 100 + numeric_modifier("Bonus Resting MP");
	int overflow = (my_mp()+rest_mp)-my_maxmp();
	if(overflow>0)
	{
		cli_execute("burn "+overflow);
	}
//empty meat---------------------------------------------------------------
/*
	int mymeat = my_meat();
	if(mymeat>0 && can_interact())
	{
		mymeat=(mymeat)/1000;
		if(mymeat>0)
		{
			cli_execute("create "+mymeat+" dense meat stack");
			put_stash(mymeat,$item[dense meat stack]);
		}
	}
	*/
//exit if done-------------------------------------------------------------	
	cli_execute("Tourguide 0.9.ash");
	if(my_adventures()==0 || my_inebriety()>inebriety_limit())
	{
		cli_execute("exit");
	}
	cli_execute("awake");
}