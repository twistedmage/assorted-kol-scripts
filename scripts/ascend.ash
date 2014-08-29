import <improve.ash>;
import <zlib.ash>;
//import <alt_farm.ash>;
//import <sims_lib.ash>;
import <pvp.ash>;

void stock_hotdog(string html, string ingredient, int req_ing, int desired_dogs)
{
	matcher hotdog_mtch = create_matcher("title=\\\""+ingredient+"\\\"></td><td><b>x "+req_ing+"</b></td><td class=tiny>\\((\\d*) in stock\\)",html);
	if(hotdog_mtch.find())
	{
		int in_stock= hotdog_mtch.group(1).to_int()/req_ing;
		int more_needed=desired_dogs - in_stock;
		if(more_needed<1)
			return;
		//restock
		int needed_ingredients=more_needed*req_ing;
		buy(needed_ingredients - item_amount(to_item(ingredient)),to_item(ingredient));
		print("Currently have "+in_stock+" of these hotdogs in stock. Adding "+more_needed+
				" more by donating "+needed_ingredients+" "+ingredient,"blue");
				
		//which dog is this
		int dog=0;
		switch(ingredient)
		{
			case "furry fur":
				//savage macho dog
				dog=-93;
				break;
			case "hot wad":
				//devil dog
				dog=-96;
				break;
			case "cold wad":
				//chilly dog
				dog=-97;
				break;
			case "spooky wad":
				//ghost dog
				dog=-98;
				break;
			case "stench wad":
				//junkyard dog
				dog=-99;
				break;
			case "cranberries":
				//one with everything
				dog=-94;
				break;
			case "gauze hammock":
				//sleeping dog
				dog=-101;
				break;
			case "tattered scrap of paper":
				//optimal dog
				dog=-102;
				break;
			case "sleaze wad":
				//wet dog
				dog=-100;
				break;
			case "skeleton bone":
				//sly dog
				dog=-95;
				break;
			default:
				abort("Unrecognised dog on ascend line 30, using ingredient "+ingredient);
		}
		//clan_viplounge.php?preaction=hotdogsupply&whichdog=-93&quantity=1
		visit_url("clan_viplounge.php?preaction=hotdogsupply&whichdog="+dog+"&quantity="+needed_ingredients);
	}
	else
	{
		print("Not unlocked hotdog requiring "+ingredient,"red");
	}
}

void stock_hotdogs()
{
	//title="furry fur"></td><td><b>x 10</b></td><td class=tiny>(0 in stock)
	string hotdog_str=visit_url("clan_viplounge.php?action=hotdogstand");
	stock_hotdog(hotdog_str,"furry fur",10,5);
	stock_hotdog(hotdog_str,"cranberries",10,5);
	stock_hotdog(hotdog_str,"skeleton bone",10,5);
	stock_hotdog(hotdog_str,"hot wad",25,5);
	stock_hotdog(hotdog_str,"cold wad",25,5);
	stock_hotdog(hotdog_str,"spooky wad",25,5);
	stock_hotdog(hotdog_str,"stench wad",25,5);
	stock_hotdog(hotdog_str,"sleaze wad",25,5);
	stock_hotdog(hotdog_str,"gauze hammock",10,5);
	stock_hotdog(hotdog_str,"issue of GameInformPowerDailyPro magazine",3,5);
	stock_hotdog(hotdog_str,"tattered scrap of paper",25,5);
}

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
	//key lime pies
	get_item($item[sneaky pete's key lime pie],1);
	get_item($item[boris's key lime pie],1);
	get_item($item[jarlsberg's key lime pie],1);
	get_item($item[star key lime pie],1);
	get_item($item[digital key lime pie],3);
	//wet stunt nut stew
	get_item($item[wet stew],1);
	buy_item($item[stunt nuts],1);
	//chaos butterfly
	buy_item($item[chaos butterfly],2);
	//afeu
	get_item($item[scroll of ancient forbidden unspeakable evil],3);
	//thin black candles for ritual
	buy_item($item[thin black candle],3);
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
	buy_item($item[jaba&ntilde;ero-flavored chewing gum],1);
	buy_item($item[handsomeness potion],1);
	buy_item($item[Meleegra&trade; pills],1);
	buy_item($item[pickle-flavored chewing gum],1);
	buy_item($item[marzipan skull],1);
	buy_item($item[tamarind-flavored chewing gum],1);
	buy_item($item[lime-and-chile-flavored chewing gum],1);
	get_item($item[jarlsberg's key lime pie],1);
	get_item($item[pumpkin bomb],5);
	buy_item($item[Mick's IcyVapoHotness Inhaler],3);
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
	buy_item($item[jar of psychoses (The Crackpot Mystic)],2);
	buy_item($item[cane-mail shirt],1);
	buy_item($item[antique machete],1);
	buy_item($item[spooky mushroom],1);
	buy_item($item[killing jar],1);
	buy_item($item[filthy knitted dread sack],1);
	buy_item($item[blackberry galoshes],1);
	buy_item($item[Unconscious Collective Dream Jar],16);
	buy_item($item[logging hatchet],1);
	buy_item($item[hot wing],3);
	buy_item($item[Meat-inflating powder],2);
	buy_item($item[disposable instant camera],1);
	buy_item($item[polka pop],10);
	
	//stuff for twistedmage
	if(my_name()=="twistedmage")
	{
		//fold loathing legion screwdriver
		if(item_amount($item[loathing legion universal screwdriver])<1)
			cli_execute("fold loathing legion universal screwdriver");
		if(item_amount($item[Sneaky Pete's leather jacket (collar popped)])<1)
			cli_execute("fold Sneaky Pete's leather jacket (collar popped)");
		if(item_amount($item[boris's helm])>0)
			cli_execute("fold boris's helm (askew)");
		//make grogtini
		get_item($item[grogtini],1);
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
	}
	else
	{
		//milk of magnesium
		buy_item($item[milk of magnesium],12);
	}
}



void main()
{
	if(get_clan_name()!="PAIN")
		abort("change clan back to PAIN");
		
	//pull all
	string catch=visit_url("storage.php?action=pullall&pwd");
	cli_execute("breakfast");
	
	cli_execute("mood apathetic");
	set_property("mpAutoRecovery", "0.4");
	set_property("mpAutoRecoveryTarget", "0.6");
		
	//alice
	cli_execute("alice.ash");
	stock_hotdogs();
	
	//do elf quest
	if(my_adventures()> 40 && my_inebriety()<=inebriety_limit())
	{
		cli_execute("spaaace.ash");
		print("spaaace should be done now","lime");
//		int prev_wg=item_amount($item[wrecked generator]);
		visit_url("shop.php?pwd&whichshop=elvishp3&action=buyitem&whichrow=207&bigform=Buy+Item&quantity=2");
//		int new_wg=item_amount($item[wrecked generator]);
//		if(new_wg - prev_wg < 2)
		if(have_effect($effect[transpondent])<1)
			use(1,$item[transporter transponder]);
		if(!contains_text(visit_url("place.php?whichplace=spaaacegrimace"),"elvishparadise.gif"))
			abort("spaaace doesn't seem to be done!");
	}
	cli_execute("guild unlock");
	if(my_adventures()>30 && my_inebriety()<=inebriety_limit())
	{
		if(my_name()=="twistedmage")
			abort("Farm some manuel monsters!");
		else
			cli_execute("hotdog_unlock");
	}
	if(my_level()<15)
	{
		print("not high enough for every skill!","red");
	}
	//fill up empty capacity with pvp food/drink
	while(my_inebriety() <= inebriety_limit())
	{
		if(item_amount($item[used beer])==0)
			buy(1,$item[used beer]);
		drink(1,$item[used beer]);
	}
	while(fullness_limit() - my_fullness() > 1)
	{
		if(item_amount($item[nailswurst])==0)
			buy(1,$item[nailswurst]);
		eat(1,$item[nailswurst]);
	}
	while(spleen_limit() - my_spleen_use() > 2)
	{
		if(spleen_limit() - my_spleen_use() > 5)
			use(1,$item[Hatorade]);
		else if(spleen_limit() - my_spleen_use() > 2)
			use(1,$item[watered-down red minotaur]);
	}
	//do pvp
	do_fights();
	
	visit_url("lair2.php?preaction=key&whichkey=436"); //get easter egg balloon
//	return_gear();
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
//			train_moxie_skills();
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
	stock_hagnks();
	cli_execute("ocd data creator");
	print("cleaning inv");
	cli_execute("ocd inventory control");
	print("cleaning inv done");
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
//	if(my_name()=="twistedmage")
//	{
		abort("Choose the familiar yourself!");
//	}
//	else
//	{
		//Squamous Gibberer familiar
//		visit_url("ascend.php?action=ascend&ascend=Squamous%2BGibberer&confirm=on&confirm2=on&pwd");
//		visit_url("valhalla.php?place=inn&pwd");
//		visit_url("valhalla.php?place=consultant&pwd");
//	}
}