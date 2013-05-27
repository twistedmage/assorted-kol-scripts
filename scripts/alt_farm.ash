import <eatdrink.ash>;
import <questlib.ash>;
import <canadv.ash>;
import <sims_lib.ash>;

//returns the available amount plus the number equipped on all familiars
int true_available_amount(item it)
{
	int amount=0;
	amount=available_amount(it);
	foreach fam in $familiars[]
	{
		if(familiar_equipped_equipment(fam)==it)
		{
			amount+=1;
		}
	}
	return amount;
}

void dress_for_item_farming()
{
	print("dressing for items","blue");
	visit_url("inv_equip.php?pwd&which=2&action=unequip&type=container"); //unequip mr container just in case
	cli_execute("inventory refresh");
	refresh_stash();
	if(available_amount($item[flaming pink shirt])==0)
	{
		if(stash_amount($item[flaming pink shirt])==0)
		{
			abort("flaming pink shirt missing from stash.");
		}
		take_stash(1,$item[flaming pink shirt]);
	}
	if(available_amount($item[bottle rocket crossbow])==0)
	{
		if(stash_amount($item[bottle rocket crossbow])==0)
		{
			abort("bottle rocket crossbow missing from stash.");
		}
		take_stash(1,$item[bottle rocket crossbow]);
	}
	if(available_amount($item[hypnodisk])==0)
	{
		if(stash_amount($item[hypnodisk])==0)
		{
			abort("hypnodisk missing from stash.");
		}
		take_stash(1,$item[hypnodisk]);
	}
	if(available_amount($item[mr. container])==0)
	{
		if(stash_amount($item[mr. container])==0)
		{
			abort("mr. container missing from stash.");
		}
		take_stash(1,$item[mr. container]);
	}
	if(available_amount($item[mr. accessory jr])<3)
	{
		if(stash_amount($item[mr. accessory jr])<3)
		{
			abort("mr. accessory jr x 3 missing from stash.");
		}
		take_stash(3,$item[mr. accessory jr]);
	}
	if(have_familiar($familiar[jumpsuited hound dog]))
	{
		use_familiar($familiar[jumpsuited hound dog]);
	}
	else if(have_familiar($familiar[dancing frog]))
	{
		use_familiar($familiar[dancing frog]);
	}
	else if(have_familiar($familiar[gravy fairy]))
	{
		use_familiar($familiar[gravy fairy]);
	}
	else
	{
		abort("Have no jumpsuited hound dog, or dancing frog, or fairy get one or choose something else");
	}
	if(true_available_amount($item[miniature gravy covered maypole])==0)
	{
		if(stash_amount($item[miniature gravy covered maypole])==0)
		{
			if(!retrieve_item(1,$item[miniature gravy covered maypole]))
			{
				abort("miniature gravy covered maypole missing from stash.");
			}
		}
		else
		{
			take_stash(1,$item[miniature gravy covered maypole]);
		}
	}
	if(!have_outfit("alt_items"))
	{
		//equip($item[bounty hunting helmet]);
		equip($item[bounty hunting pants]);
		if(have_skill($skill[torso awaregness]))
		{
			equip($item[flaming pink shirt]);
		}
		equip($item[bottle rocket crossbow]);
		equip($item[hypnodisk]);
		print("equipping mr container","blue");
		visit_url("inv_equip.php?pwd&which=2&action=equip&whichitem=482"); //equip mr container
		equip($slot[acc1],$item[mr. accessory jr]);
		equip($slot[acc2],$item[mr. accessory jr]);
		equip($slot[acc3],$item[mr. accessory jr]);
		cli_execute("outfit save alt_items");
	}
	outfit("alt_items");
	equip($item[miniature gravy covered maypole]);
}

void dress_for_oasis_farming()
{
	print("dressing for oasis","blue");
	visit_url("inv_equip.php?pwd&which=2&action=unequip&type=container"); //unequip mr container just in case
	cli_execute("inventory refresh");
	refresh_stash();
	if(available_amount($item[origami pasties])==0)
	{
		if(stash_amount($item[origami pasties])==0)
		{
			abort("origami pasties missing from stash.");
		}
		take_stash(1,$item[origami pasties]);
	}
	if(available_amount($item[bottle-rocket crossbow])==0)
	{
		if(stash_amount($item[bottle-rocket crossbow])==0)
		{
			abort("bottle-rocket crossbow missing from stash.");
		}
		take_stash(1,$item[bottle-rocket crossbow]);
	}
	if(available_amount($item[hypnodisk])==0)
	{
		if(stash_amount($item[hypnodisk])==0)
		{
			abort("hypnodisk missing from stash.");
		}
		take_stash(1,$item[hypnodisk]);
	}
	if(available_amount($item[mr. container])==0)
	{
		if(stash_amount($item[mr. container])==0)
		{
			abort("mr. container missing from stash.");
		}
		take_stash(1,$item[mr. container]);
	}
	if(available_amount($item[mr. accessory jr.])<3)
	{
		if(stash_amount($item[mr. accessory jr.])<3)
		{
			abort("mr. accessory jr. x3 missing from stash.");
		}
		take_stash(3,$item[mr. accessory jr.]);
	}
	/*
	if(have_familiar($familiar[stocking mimic]))
	{
		use_familiar($familiar[stocking mimic]);
	}
	else 
	*/
	if(have_familiar($familiar[dancing frog]))
	{
		use_familiar($familiar[dancing frog]);
	}
	else if(have_familiar($familiar[jumpsuited hound dog]))
	{
		use_familiar($familiar[jumpsuited hound dog]);
	}
	else if(have_familiar($familiar[baby gravy fairy]))
	{
		use_familiar($familiar[baby gravy fairy]);
	}
	else
	{
		abort("Have no stocking mimic, get one or choose something else");
	}
	if(available_amount($item[miniature gravy covered maypole])==0)
	{
		if(stash_amount($item[miniature gravy covered maypole])==0)
		{
			if(!retrieve_item(1,$item[miniature gravy covered maypole]))
			{
				abort("miniature gravy covered maypole missing from stash.");
			}
		}
		else
		{
			take_stash(1,$item[miniature gravy covered maypole]);
		}
	}
	if(!have_outfit("alt_oasis"))
	{
		if(have_skill($skill[torso awaregness]))
		{
			equip($item[origami pasties]);
		}
		equip($item[bottle rocket crossbow]);
		equip($item[hypnodisk]);
		print("equipping mr container","blue");
		visit_url("inv_equip.php?pwd&which=2&action=equip&whichitem=482"); //equip mr container
		//equip($item[bounty hunting helmet]);
		equip($item[bounty hunting pants]);
		equip($slot[acc1],$item[mr. accessory jr]);
		equip($slot[acc2],$item[mr. accessory jr]);
		equip($slot[acc3],$item[mr. accessory jr]);
		cli_execute("outfit save alt_oasis");
	}
	outfit("alt_oasis");
	equip($item[miniature gravy covered maypole]);
}

void dress_for_worm_farming()
{
	print("dressing for worms","blue");
	visit_url("inv_equip.php?pwd&which=2&action=unequip&type=container"); //unequip mr container just in case
	cli_execute("inventory refresh");
	refresh_stash();
	if(available_amount($item[origami pasties])==0)
	{
		if(stash_amount($item[origami pasties])==0)
		{
			abort("origami pasties missing from stash.");
		}
		take_stash(1,$item[origami pasties]);
	}
	if(available_amount($item[bottle-rocket crossbow])==0)
	{
		if(stash_amount($item[bottle-rocket crossbow])==0)
		{
			abort("bottle-rocket crossbow missing from stash.");
		}
		take_stash(1,$item[bottle-rocket crossbow]);
	}
	if(available_amount($item[hypnodisk])==0)
	{
		if(stash_amount($item[hypnodisk])==0)
		{
			abort("hypnodisk missing from stash.");
		}
		take_stash(1,$item[hypnodisk]);
	}
	if(available_amount($item[mr. container])==0)
	{
		if(stash_amount($item[mr. container])==0)
		{
			abort("mr. container missing from stash.");
		}
		take_stash(1,$item[mr. container]);
	}
	if(available_amount($item[mr. accessory jr.])<3)
	{
		if(stash_amount($item[mr. accessory jr.])<3)
		{
			abort("mr. accessory jr. x3 missing from stash.");
		}
		take_stash(3,$item[mr. accessory jr.]);
	}
	if(have_familiar($familiar[dancing frog]))
	{
		use_familiar($familiar[dancing frog]);
	}
	else if(have_familiar($familiar[jumpsuited hound dog]))
	{
		use_familiar($familiar[jumpsuited hound dog]);
	}
	else if(have_familiar($familiar[gravy fairy]))
	{
		use_familiar($familiar[gravy fairy]);
	}
	else
	{
		abort("Have no dancing frog or gravy fairy, get one or choose something else");
	}
	if(available_amount($item[lucky tam o'shatner])==0)
	{
		if(stash_amount($item[lucky tam o'shatner])==0)
		{
			if(!retrieve_item(1,$item[lucky tam o'shatner]))
			{
				abort("lucky tam o'shatner missing from stash.");
			}
		}
		else
		{
			take_stash(1,$item[lucky tam o'shatner]);
		}
	}
	if(!have_outfit("alt_worm"))
	{
		if(have_skill($skill[torso awaregness]))
		{
			equip($item[origami pasties]);
		}
		equip($item[bottle rocket crossbow]);
		equip($item[hypnodisk]);
		print("equipping mr container","blue");
		visit_url("inv_equip.php?pwd&which=2&action=equip&whichitem=482"); //equip mr container
		//equip($item[bounty hunting helmet]);
		equip($item[bounty hunting pants]);
		equip($slot[acc1],$item[mr. accessory jr.]);
		equip($slot[acc2],$item[mr. accessory jr.]);
		equip($slot[acc3],$item[mr. accessory jr.]);
		cli_execute("outfit save alt_worm");
	}
	outfit("alt_worm");
	equip($item[lucky tam o'shatner]);
}

void return_gear()
{
//	visit_url("inv_equip.php?pwd&which=2&action=unequip&type=container"); //unequip mr container just in case
//	cli_execute("inventory refresh");
//	cli_execute("outfit birthday suit");
///	cli_execute("unequip familiar");
//	cli_execute("stash put * flaming pink shirt");
//	cli_execute("stash put * bottle rocket crossbow");
//	cli_execute("stash put * hypnodisk");
//	cli_execute("stash put * mr. container");
//	cli_execute("stash put * mr. accessory jr.");
//	boolean catch = retrieve_item(1,$item[miniature gravy covered maypole]);
//	cli_execute("stash put * miniature gravy covered maypole");
//	cli_execute("stash put * origami pasties");
//	catch = retrieve_item(1,$item[lucky tam o'shatner]);
//	cli_execute("stash put * lucky tam o'shatner");
//	cli_execute("stash put * elvish sunglasses");
}

void dress_for_frat_pickpocketing()
{
	print("dressing for pickpocket","blue");
	visit_url("inv_equip.php?pwd&which=2&action=unequip&type=container"); //unequip mr container just in case
	cli_execute("inventory refresh");
	refresh_stash();
	if(available_amount($item[flaming pink shirt])==0)
	{
		if(stash_amount($item[flaming pink shirt])==0)
		{
			abort("flaming pink shirt missing from stash.");
		}
		take_stash(1,$item[flaming pink shirt]);
	}
	if(available_amount($item[bottle-rocket crossbow])==0)
	{
		if(stash_amount($item[bottle-rocket crossbow])==0)
		{
			abort("bottle-rocket crossbow missing from stash.");
		}
		take_stash(1,$item[bottle-rocket crossbow]);
	}
	if(available_amount($item[hypnodisk])==0)
	{
		if(stash_amount($item[hypnodisk])==0)
		{
			abort("hypnodisk missing from stash.");
		}
		take_stash(1,$item[hypnodisk]);
	}
	if(available_amount($item[mr. container])==0)
	{
		if(stash_amount($item[mr. container])==0)
		{
			abort("mr. container missing from stash.");
		}
		take_stash(1,$item[mr. container]);
	}
	if(available_amount($item[mr. accessory jr.])<1)
	{
		if(stash_amount($item[mr. accessory jr.])<1)
		{
			abort("mr. accessory jr. x1 missing from stash.");
		}
		take_stash(1,$item[mr. accessory jr.]);
	}
	if(available_amount($item[elvish sunglasses])<1)
	{
		if(stash_amount($item[elvish sunglasses])<1)
		{
			abort("elvish sunglasses missing from stash.");
		}
		take_stash(1,$item[elvish sunglasses]);
	}
/*
	if(have_familiar($familiar[stocking mimic]))
	{
		use_familiar($familiar[stocking mimic]);
	}
	else
	{
		abort("Have no stocking mimic, get one or choose something else");
	}
	*/
	if(available_amount($item[lucky tam o'shatner])==0)
	{
		if(stash_amount($item[lucky tam o'shatner])==0)
		{
			if(!retrieve_item(1,$item[lucky tam o'shatner]))
			{
				abort("lucky tam o'shatner missing from stash.");
			}
		}
		else
		{
			take_stash(1,$item[lucky tam o'shatner]);
		}
	}
	if(!have_outfit("alt_pp"))
	{
		if(have_skill($skill[torso awaregness]))
		{
			equip($item[flaming pink shirt]);
		}
		equip($item[bottle rocket crossbow]);
		equip($item[hypnodisk]);
		print("equipping mr container","blue");
		visit_url("inv_equip.php?pwd&which=2&action=equip&whichitem=482"); //equip mr container
		//equip($item[bounty hunting helmet]);
		equip($item[bounty hunting pants]);
		equip($slot[acc1],$item[mr. accessory jr]);
		equip($slot[acc2],$item[elvish sunglasses]);
		if(available_amount($item[bling of the new wave])>0)
		{
			equip($slot[acc3],$item[bling of the new wave]);
		}
		cli_execute("outfit save alt_pp");
	}
	outfit("alt_pp");
	equip($item[lucky tam o'shatner]);
}


void main()
{
	if(my_level()>13 && in_moxie_sign())
	{
		if(!have_skill($skill[powers of observatiogn]) || !have_skill($skill[gnefarious pickpocketing]) || !have_skill($skill[torso awaregness]))
		{
			train_moxie_skills();
		}
	}
	if(my_adventures()!=0)
	{
		cli_execute("maximize item, 0.01 moxie");

		//if mox higher than muscle choose safe based on muscle
		int mox = my_buffedstat($stat[moxie]);
		if(mox < my_buffedstat($stat[muscle]))
		{
			mox = my_buffedstat($stat[muscle]);
		}

//add el vibrato?

		if(have_familiar($familiar[Dancing Frog]))
		{
   			cli_execute( "familiar Dancing Frog");
		}


		cli_execute("conditions clear");

		//get tempura batter
		if(have_skill($skill[tempuramancy]) && get_property("tempuraSummons")<3)
		{
			if(my_maxmp()*0.7<200)
			{
				abort("Don't have enough mp to be sure in trench");
			}
			cli_execute("mood -combat");
			while(get_property("tempuraSummons")<3 && my_adventures()>0)
			{
				if(my_mp()<200)
				{
					cli_execute("recover mp");
				}
				adventure(1, $location[Marinara Trench]);
			}
		}

		//begin farming locations
		if(mox > 182 && can_adv($location[Oasis in the desert],false))
		{
			if(can_interact())
			{
				dress_for_worm_farming();
				cli_execute("stash take * drum machine");
				cli_execute("sandwormfarm.ash");	
				dress_for_oasis_farming();		
			}				
			location FARM_LOCATION = $location[Oasis in the desert];
			adventure(my_adventures(), FARM_LOCATION);
		}
//===============================================================================================
/*
		if( mox > 457 && my_level()>23 && can_adv($location[an octopus's garden],false))
		{
			dress_for_wet();
			location FARM_LOCATION = $location[An Octopus's garden];
			adventure(my_adventures(), FARM_LOCATION);
			cli_execute( "csend * flytrap pellet to twistedmage");
			cli_execute( "csend * sea radish to twistedmage");
			cli_execute( "csend * sand dollar to twistedmage");
			cli_execute( "csend * slimy chest to twistedmage");
			cli_execute( "csend * sea avocado to twistedmage");
			cli_execute( "csend * sea carrot to twistedmage");
			cli_execute( "csend * sea cucumber to twistedmage");
			cli_execute( "csend * sea honeydew to twistedmage");	
			cli_execute( "csend * sea lychee to twistedmage");
			cli_execute( "csend * sea tangelo to twistedmage");		
		}
		*/
		if(mox > 47 && canadia_available()) //need 1 more hockey stick
		{
			adventure(my_adventures(),$location[Camp Logging Camp]);
		}
		else if( mox > 12 && can_adv($location[spooky forest],false)) //need 1 more baio
		{
			set_property("choiceAdventure502","3");
			set_property("choiceAdventure506","1");
			set_property("choiceAdventure26","2");
			set_property("choiceAdventure28","2");
			location FARM_LOCATION = $location[Spooky Forest];
			adventure(my_adventures(), FARM_LOCATION);
		}
		else if(mox > 33 && can_adv($location[haunted billiard room],false)) //need 17-ball
		{
			adventure(my_adventures(),$location[haunted billiard room]);
		}
		else //crazy bastard sword
		{
			location FARM_LOCATION = $location[sleazy back alley];
			adventure(my_adventures(), FARM_LOCATION);		
		}
		//I also miss counterclockwise watch, but not much to do about it
	}
	print("farming finished","blue");

	return_gear();
//mail all scroll stuff and semi rares
//	cli_execute( "stash put * drum machine");
}