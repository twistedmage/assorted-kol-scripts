import <improve.ash>;
import <zlib.ash>;
import <alt_farm.ash>;
import <sims_lib.ash>;
import <pvp.ash>;

void buy_item(item it, int num)
{
print("buying "+it);
	if(available_amount(it)<num)
		buy(num,it);
}

void get_item(item it, int num)
{
print("making "+it);
	if(available_amount(it)<num)
		create(num,it);
	if(available_amount(it)<num)
		buy_item(it,num);
}

void stock_hagnks()
{ 

	//clovers
	buy_item($item[disassembled clover],10);
	//bartender/chef
	get_item($item[bartender-in-the-box],1);
	get_item($item[chef-in-the-box],1);
	//make Ninja pirate zombie robot head
	get_item($item[Ninja pirate zombie robot head],1);
	//lime/cherry/jumbo olive
	buy_item($item[lime],30);
	buy_item($item[cherry],15);
	buy_item($item[jumbo olive],15);
	//tps bases
	get_item($item[grog],15);
	get_item($item[dry vodka martini],15);
	get_item($item[sangria],15);
	//milk of magnesium
	get_item($item[milk of magnesium],12);
	//key lime pies
	get_item($item[sneaky pete's key lime pie],1);
	get_item($item[boris's key lime pie],1);
	get_item($item[jarlsberg's key lime pie],1);
	get_item($item[star key lime pie],1);
	get_item($item[digital key lime pie],3);
	//wet stunt nut stew
	get_item($item[wet stew],1);
	get_item($item[stunt nuts],1);
	//fold loathing legion screwdriver
	cli_execute("fold loathing legion screwdriver");
	if(item_amount($item[boris's helm])>0)
		cli_execute("fold boris's helm (askew)");
	//chaos butterfly
	get_item($item[chaos butterfly],2);
	//afeu
	get_item($item[scroll of ancient forbidden unspeakable evil],3);
	//thin black candles for ritual
	get_item($item[thin black candle],3);
	//make grogtini
	get_item($item[grogtini],1);
	//food/drink/spleen
	buy_item($item[knob goblin lunchbox],5);
	buy_item($item[glimmering roc feather],15);
	buy_item($item[groose grease],16);
	//mojo filters
	buy_item($item[mojo filter],9);
	//tower items
	buy_item($item[bone rattle],1);
	buy_item($item[baseball],1);
	buy_item($item[plot hole],1);
	buy_item($item[meat vortex],1);
	buy_item($item[sonar-in-a-biscuit],1);
	buy_item($item[leftovers of indeterminate origin],1);
	buy_item($item[stick of dynamite],1);
	buy_item($item[knob goblin firecracker],1);
	buy_item($item[inkwell],1);
	buy_item($item[mariachi g-string],1);
	buy_item($item[photoprotoneutron torpedo],1);
	buy_item($item[pygmy blowgun],1);
	buy_item($item[barbed-wire fence],1);
	buy_item($item[fancy bath salts],1);
	buy_item($item[razor-sharp can lid],1);
	buy_item($item[frigid ninja stars],1);
	buy_item($item[tropical orchid],1);
	buy_item($item[black pepper],1);
	buy_item($item[ng],3);
	buy_item($item[bronzed locust],1);
	buy_item($item[powdered organs],1);
	buy_item($item[spider web],1);
	buy_item($item[disease],1);
	//useful stuff
	buy_item($item[large box],6);
	buy_item($item[the big book of pirate insults],1);
	//food and drink
	buy_item($item[hot hi mein],15);
	buy_item($item[sleazy hi mein],15);
	buy_item($item[spooky hi mein],15);
	buy_item($item[badass pie],30);
	buy_item($item[mon tiki],20);
	buy_item($item[gimlet],20);
	buy_item($item[mae west],20);
	//bricko mobs
	buy_item($item[bricko bat],30);
	//tomb helpers
	buy_item($item[tangle of rat tails],10);
	//war outfit
	buy_item($item[Bullet-proof corduroys],1);
	buy_item($item[reinforced beaded headband],1);
	buy_item($item[round purple sunglasses],1);
	//chewing gums
	buy_item($item[jabanero-flavored chewing gum],1);
	buy_item($item[handsomeness potion],1);
	buy_item($item[Meleegra pills],1);
	buy_item($item[pickle-flavored chewing gum],1);
	buy_item($item[marzipan skull],1);
	buy_item($item[tamarind-flavored chewing gum],1);
	buy_item($item[lime-and-chile-flavored chewing gum],1);
	get_item($item[jarlsberg's key lime pie],1);
	get_item($item[pumpkin bomb],5);
	buy_item($item[icyvapohotness inhaler],3);
	buy_item($item[cyclops eyedrops],3);
	//more quest crap
	buy_item($item[668 scroll],3);
	buy_item($item[64067 scroll],3);
	buy_item($item[goat cheese],3);
	buy_item($item[asbestos ore],3);
	buy_item($item[linoleum ore],3);
	buy_item($item[chrome ore],3);
	buy_item($item[ninja rope],1);
	buy_item($item[ninja crampons],1);
	buy_item($item[ninja carabiner],1);
	buy_item($item[acoustic guitarrr],1);
	//food that might prove good for boris?
	buy_item($item[s'more],30);
	buy_item($item[prismatic wad],10);
	buy_item($item[skeleton key],4);
	buy_item($item[borrowed time],6);
	buy_item($item[mullet wig],2);
}



void main()
{
	//pull all
	string catch=visit_url("storage.php?action=pullall&pwd");
	cli_execute("breakfast");
	
	cli_execute("mood apathetic");
	set_property("mpAutoRecovery", "0.4");
	set_property("mpAutoRecoveryTarget", "0.6");
	//money
	if(my_meat()<50000)
	{
		take_stash(50,$item[dense meat stack]);
		autosell(50,$item[dense meat stack]);
	}
		
	//alice
	cli_execute("alice.ash");
	
	//do elf quest
	if(my_inebriety()<=inebriety_limit())
		cli_execute("spaaace.ash");
	print("spaaace should be done now","lime");
	visit_url("spaaace.php?pwd&place=shop3&action=buy&whichitem=5176&quantity=2");
	if(item_amount($item[wrecked generator])<2)
		abort("spaaace doesn't seem to be done!");
	cli_execute("guild unlock");
	if(my_adventures()>30 && my_inebriety()<=inebriety_limit())
	{
		abort("Farm some manuel monsters!");
		cli_execute("alt_farm");
	}
	if(my_level()<15)
	{
		print("not high enough for every skill!","red");
	}
	//fill up empty capacity with pvp food/drink
	while(my_inebriety() <= inebriety_limit())
	{
		if(my_meat()<500)
		{
			take_stash(5,$item[dense meat stack]);
			autosell(5,$item[dense meat stack]);
		}
		if(item_amount($item[used beer])==0)
			buy(1,$item[used beer]);
		drink(1,$item[used beer]);
	}
	while(fullness_limit() - my_fullness() > 1)
	{
		if(my_meat()<500)
		{
			take_stash(5,$item[dense meat stack]);
			autosell(5,$item[dense meat stack]);
		}
		if(item_amount($item[nailswurst])==0)
			buy(1,$item[nailswurst]);
		eat(1,$item[nailswurst]);
	}
	while(spleen_limit() - my_spleen_use() > 2)
	{
		if(my_meat()<500)
		{
			take_stash(5,$item[dense meat stack]);
			autosell(5,$item[dense meat stack]);
		}
		if(spleen_limit() - my_spleen_use() > 5)
			use(1,$item[Hatorade]);
		else if(spleen_limit() - my_spleen_use() > 2)
			use(1,$item[watered down red minotaur]);
	}
	//do pvp
	do_fights();
	
	visit_url("lair2.php?preaction=key&whichkey=436"); //get easter egg balloon
	return_gear();
	cli_execute("train.ash");
//check we can ascend============================================
	if(!contains_text(visit_url("lair6.php"),"gash.gif") || 
			(my_path()=="Bugbear Invasion" && !contains_text(visit_url("place.php?whichplace=bugbearship&action=bb_bridge"),"gash.gif")))
	{
		abort("Not ready for ascension!");
	}
	else
	{
		set_property("ready_for_ascension",true);
	}
	if(gnomads_available())
	{
		if(!have_skill($skill[powers of observatiogn]) || !have_skill($skill[gnefarious pickpocketing]) || !have_skill($skill[torso awaregness]))
		{
			train_moxie_skills();
		}
	}
//blow up your zap wand=================================================
	while(daily_zap(false))
	{
	}
//untinker meat car=====================================================
	visit_url("town_right.php?action=untinker&whichitem=134&untinker=Untinker%21&pwd");
//free goofballs========================================================
	if(contains_text(visit_url("town_wrong.php?place=goofballs&pwd"),"First bottle's free, man"))
	{
		visit_url("town_wrong.php?action=buygoofballs&pwd");
	}
//final bag clean=======================================================
	cli_execute("autosell * creased paper strip");
	cli_execute("autosell * crinkled paper strip");
	cli_execute("autosell * crumpled paper strip");
	cli_execute("autosell * folded paper strip");
	cli_execute("autosell * ragged paper strip");
	cli_execute("autosell * ripped paper strip");
	cli_execute("autosell * rumpled paper strip");
	cli_execute("autosell * torn paper strip");
	setvar("priceAdvisor_obeyBuyLimit","true");
	cli_execute("set autoBuyPriceLimit = 20000");
	if(my_meat()<100000)
	{
		print("stash pulling ascension meat","blue");
		if(stash_amount($item[dense meat stack])>=100)
		{
			take_stash(100,$item[dense meat stack]);
			cli_execute("autosell * dense meat stack");
		}
		else
		{
			abort("No stacks in stash.");
		}
	}
	stock_hagnks();
	cli_execute("ocd data creator");
	print("cleaning inv");
	cli_execute("ocd inventory control");
	print("cleaning inv done");
	if(my_meat()>100000 && my_name()!="twistedmage")
	{
		int stacks=(my_meat()-100000)/1000;
		cli_execute("create "+stacks+" dense meat stack");
		put_stash(stacks,$item[dense meat stack]);
	}
	else if(my_meat()<100000 && my_name()!="twistedmage")
	{
		print("stash pulling ascension meat","blue");
		if(stash_amount($item[dense meat stack])>=100)
		{
			take_stash(100,$item[dense meat stack]);
			cli_execute("autosell * dense meat stack");
		}
		else
		{
			abort("No stacks in stash.");
		}
	}
	else //if twistedmage dump all to stash
	{
		int stacks=my_meat()/1000;
		cli_execute("create "+stacks+" dense meat stack");
		put_stash(stacks,$item[dense meat stack]);
	}	
	cli_execute("outfit birthday suit");
	cli_execute("unequip familiar");
//get trophies=====================================================
	if(my_name()=="twistedmage" && contains_text(visit_url("trophy.php"),"You're entitled to the "))
	{
		abort("Trophy to purchase first!");
	}
//burn mana=====================================================
	//if completed nuns as frat
	if(get_property("sidequestNunsCompleted")=="fratboy")
	{
		//while visits left
		while(to_int(get_property("nunsVisits"))<3)
		{
			print("nunburn");
			cli_execute("burn *");
			cli_execute("mood execute");
			//press button
			visit_url("postwarisland.php?action=nuns&place=nunnery&pwd");
			visit_url("bigisland.php?action=nuns&place=nunnery&pwd");
		}
	}
	if(item_amount($item[oscus's neverending soda])!=0)
	{
		print("oscusburn");
		if(!get_property("oscusSodaUsed").to_boolean())
		{
			cli_execute("burn *");
				cli_execute("mood execute");
			use(1,$item[oscus's neverending soda]);
		}
	}
	if(item_amount($item[Platinum Yendorian Express Card])!=0)
	{
		print("yendoburn");
		if(!get_property("expressCardUsed").to_boolean())
		{
			cli_execute("burn *");
			cli_execute("mood execute");
			use(1,$item[Platinum Yendorian Express Card]);
		}
	}
	cli_execute("burn *");
	cli_execute("mood execute");
	cli_execute("snapshot");
//ascend=====================================================
	int karmas=item_amount($item[instant karma]);
	if(karmas>3)
	{
		karmas=3;
	}
	while(karmas>0)
	{
		print("Discarding karma","green");
		visit_url("inventory.php?which=1&action=discard&pwd&whichitem=4448");
		karmas=karmas-1;
	}
	cli_execute("Tourguide 0.9.ash");
	visit_url("ascend.php");
	if(my_name()=="twistedmage")
	{
		abort("Choose the familiar yourself!");
	}
	else
	{
		//Squamous Gibberer familiar
		visit_url("ascend.php?action=ascend&ascend=Squamous%2BGibberer&confirm=on&confirm2=on&pwd");
		visit_url("valhalla.php?place=inn&pwd");
		visit_url("valhalla.php?place=consultant&pwd");
	}
}