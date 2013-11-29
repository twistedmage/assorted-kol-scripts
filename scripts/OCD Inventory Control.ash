// OCD Inventory Control v2.1
import <PriceAdvisor.ash>;
//import <sims_lib.ash>;

if(!get_property("_inv_cleaned_"+my_name()).to_boolean())
{
	//discard ruined hellseal pieces
	int disc_amount = item_amount($item[burst hellseal brain]);
	for i from 0 upto disc_amount by 1
	{
		visit_url("inventory.php?which=3&action=discard&pwd&whichitem=3877");
	}
	disc_amount = item_amount($item[shredded hellseal hide]);
	for i from 0 upto disc_amount by 1
	{
		visit_url("inventory.php?which=3&action=discard&pwd&whichitem=3875");
	}
	disc_amount = item_amount($item[torn hellseal sinew]);
	for i from 0 upto disc_amount by 1
	{
		visit_url("inventory.php?which=3&action=discard&pwd&whichitem=3879");
	}

	cli_execute("update prices http://zachbardon.com/mafiatools/updateprices.php?action=getmap");
	cli_execute("update prices http://nixietube.info/mallprices.txt");

	// "OCD Data.txt" holds a list of all items to autosell, pulverize or prevent from being mallsold. 
	// The associated int is how many of them to keep.
	// If the value is -1 or less, none will be disposed of.

	boolean restore_outfit = false; 	// This is nice for periodic aftercore usage...
	item fam_equip;
	if(restore_outfit) {
		fam_equip = familiar_equipped_equipment(my_familiar());
		cli_execute("outfit save Backup");
	}

	// First empty out Hangks, so it can be accounted for by what follows.
	visit_url("storage.php?action=takeall&pwd");
	// Now strip, so I can dispose of EVERYTHING!
	cli_execute("outfit birthday suit");

//	void take_shop(item i) {
//	   visit_url("managestore.php?action=take&whichitem="+i.to_int()+"&pwd");
//	}

	void take_shop_all(item i) {
	   visit_url("managestore.php?action=takeall&whichitem="+i.to_int()+"&pwd");
	}



	void mall_sell(item it)
	{
		if(item_amount(it)>0)
		{
			cli_execute("mallsell * "+it);
		}
	}


	record item_disposal {
		int q;
		string action;
	};

	item_disposal [item] ocd;
	file_to_map("OCD Data.txt", ocd);

	cli_execute("autosell * meat stack");
	cli_execute("autosell * meat paste");
	cli_execute("autosell * pile of gold coins");
	cli_execute("autosell * yakisoba's hat");
	cli_execute("autosell * friendly cheez blob");
	cli_execute("autosell * Argarggagarg's fang");
	cli_execute("autosell * Heimandatz's heart");
	cli_execute("autosell * handful of confetti");
	cli_execute("autosell * stray chihuahua");
	cli_execute("autosell * The Mariachi's guitar case");
	cli_execute("autosell * untamable turtle");
	
	if(can_interact())
	{
		//put all restorers in mall
		mall_sell($item[carbonated water lily]);
		mall_sell($item[Dyspepsi-Cola]);
		mall_sell($item[tiny house]);
		mall_sell($item[phonics down]);
		mall_sell($item[scroll of drastic healing]);
		mall_sell($item[filthy poultice]);
		mall_sell($item[natural fennel soda]);
		mall_sell($item[Monstar energy beverage]);
		mall_sell($item[gauze garter]);
		mall_sell($item[palm frond]);
		mall_sell($item[Mountain Stream soda]);
		mall_sell($item[cast]);
		mall_sell($item[red pixel potion]);
		mall_sell($item[unrefined Mountain Stream syrup]);
		//put all ingredients in mall
		mall_sell($item[fairy gravy boat]);
		mall_sell($item[Meat maid body]);
		mall_sell($item[pretty flower]);
		mall_sell($item[bowl of cottage cheese]);
		mall_sell($item[Spooky-Gro fertilizer]);
		mall_sell($item[rusty metal shaft]);
		mall_sell($item[rusty metal key]);
		mall_sell($item[sword hilt]);
		mall_sell($item[helmet recipe]);
		mall_sell($item[pants kit]);
		mall_sell($item[dried face]);
		mall_sell($item[meat golem]);
		mall_sell($item[spooky shrunken head]);
		mall_sell($item[crossbow string]);
		mall_sell($item[cog and sprocket assembly]);
		mall_sell($item[anticheese]);
		mall_sell($item[stone of eXtreme power]);
		mall_sell($item[ghuol egg]);
		mall_sell($item[skeleton bone]);
		mall_sell($item[ghuol ears]);
		mall_sell($item[lihc eye]);
		mall_sell($item[gnoll lips]);
		mall_sell($item[uncooked chorizo]);
		mall_sell($item[disembodied brain]);
		mall_sell($item[batgut]);
		mall_sell($item[bat wing]);
		mall_sell($item[enchanted bean]);
		mall_sell($item[loose teeth]);
		mall_sell($item[bat guano]);
		mall_sell($item[rat appendix]);
		mall_sell($item[yak skin]);
		mall_sell($item[grumpy old man charrrm]);
		mall_sell($item[lump of coal]);
		mall_sell($item[clown skin]);
		mall_sell($item[demon skin]);
		mall_sell($item[mummy wrapping]);
		mall_sell($item[long pork]);
		mall_sell(to_item(2528)); //filet of tangy gnat ("fotelif")
		mall_sell($item[sugar sheet]);
		mall_sell($item[displaced fish]);
		mall_sell($item[leathery bat skin]);
		mall_sell($item[leathery cat skin]);
		mall_sell($item[stolen office supplies]);
		mall_sell($item[spooky bark]);
		mall_sell($item[brass dorsal fin]);
		mall_sell($item[skate skates]);
		mall_sell($item[skate skin]);
		mall_sell($item[twitching claw]);
		mall_sell($item[pulsing flesh]);
		mall_sell($item[parasitic claw]);
		mall_sell($item[seaweed]);
		mall_sell($item[dragonfish caviar]);
		mall_sell($item[Mer-kin pressureglobe]);
		mall_sell($item[white rice]);
		mall_sell($item[slab of sponge]);
		mall_sell($item[glistening fish meat]);
		mall_sell($item[gator skin]);
		mall_sell($item[synthetic stuffing]);
		mall_sell($item[toy hoverpad]);
		mall_sell($item[booty chest charrrm]);
		mall_sell($item[cannonball charrrm]);
		mall_sell($item[copper ha'penny charrrm]);
		mall_sell($item[silver tongue charrrm]);
		mall_sell($item[handful of sand]);
		mall_sell($item[bejeweled pledge pin]);
		mall_sell($item[clay peace-sign bead]);
		mall_sell($item[beach glass necklace]);
		mall_sell($item[black snake skin]);
		mall_sell($item[bird rib]);
		mall_sell($item[lion oil]);
		mall_sell($item[tarrrnish charrrm]);
		mall_sell($item[meat engine]);
		mall_sell($item[yeti fur]);
		mall_sell($item[white pixel]);
		mall_sell($item[stuffing]);
		mall_sell($item[felt]);
		mall_sell($item[twinkly powder]);
		mall_sell($item[hot powder]);
		mall_sell($item[spooky powder]);
		mall_sell($item[stench powder]);
		mall_sell($item[sleaze powder]);
		mall_sell($item[twinkly nuggets]);
		mall_sell($item[cold nuggets]);
		mall_sell($item[spooky nuggets]);
		mall_sell($item[sleaze nuggets]);
		mall_sell($item[cold powder]);
		//put all food in mall
		mall_sell($item[insanely spicy bean burrito]);
		mall_sell($item[goat cheese pizza]);
		mall_sell($item[piece of wedding cake]);
		mall_sell($item[abominable snowcone]);
		//put all drink in mall
		mall_sell($item[McMillicancuddy's Special Lager]);
		mall_sell($item[melted Jell-o shot]);
		mall_sell($item[cruelty-free wine]);
		mall_sell($item[thistle wine]);
		mall_sell($item[shot of rotgut]);
		mall_sell($item[Imp Ale]);
		mall_sell($item[Ent cider]);
		mall_sell($item[papaya slung]);
		mall_sell($item[Ram's Face Lager]);
		mall_sell($item[ice-cold Sir Schlitz]);
		//put all spleen in mall
	}

	//handle saucepands
	if(item_amount($item[saucepan])==4 || item_amount($item[saucepan])==8)
	{
		print("clearing out saucepan","blue");
		cli_execute("autosell saucepan");
	}
	//handle 7 ball
	if(item_amount($item[7-ball])==2)
	{
		print("clearing out 7-ball","blue");
		cli_execute("autosell 7-ball");
	}

	// Make pies if ns beaten and use gift certificates
	if (contains_text(visit_url("questlog.php?which=1"),"defeated the Naughty Sorceress and freed the King"))
	{
		//first make all pie crusts
		int pie_amount = item_amount($item[Boris's key]) + item_amount($item[Jarlsberg's key])+ item_amount($item[Sneaky Pete's key]) + item_amount($item[digital key])+ item_amount($item[Richard's star key]);
		pie_amount-=item_amount($item[pie crust]);
		buy(pie_amount-item_amount($item[wad of dough]),$item[wad of dough]);
		buy(pie_amount-item_amount($item[gnollish pie tin]),$item[gnollish pie tin]);
		visit_url("craft.php?mode=cook&mode=cook&pwd&action=craft&a=158&b=159&qty="+pie_amount+"&master=Bake%21");
		
		//now make pies
		item key;
		item key_lime;
		for i from 0 upto 5 by 1
		{
			if(i==0)
			{
				key=$item[boris's key];
				key_lime=$item[boris's key lime];
			}
			else if(i==1)
			{
				key=$item[sneaky pete's key];
				key_lime=$item[sneaky pete's key lime];
			}
			else if(i==2)
			{
				key=$item[jarlsberg's key];
				key_lime=$item[jarlsberg's key lime];
			}
			else if(i==3)
			{
				key=$item[digital key];
				key_lime=$item[digital key lime];
			}
			else if(i==4)
			{
				key=$item[richard's star key];
				key_lime=$item[star key lime];
			}
			//make key lime
			visit_url("craft.php?mode=cook&mode=cook&pwd&action=craft&a="+to_int(key)+"&b=333&qty="+item_amount(key)+"&master=Bake%21");
			//make pie
			visit_url("craft.php?mode=cook&mode=cook&pwd&action=craft&a="+to_int(key_lime)+"&b=160&qty="+item_amount(key_lime)+"&master=Bake%21");
		}
	}
	cli_execute("use * Warm Subject gift certificate,  * black pension check,  * old coin purse,  * old leather wallet,  * ancient vinyl coin purse");
	cli_execute("use * mer kin thingpouch");
	
	// Now strip, so I can dispose of everything. (bugbear outfit might have been equipped by the above.)
	cli_execute("outfit birthday suit");

	int mall_q = 0;
	int mall_line = 0;
	string [int] mall;

	int auto_q = 0;
	int auto_line = 0;
	string [int] auto;

	int pulv_q = 0;
	int pulv_line = 0;
	string [int] pulv;

	int price;
	int mall_total = 0;
	int auto_total = 0;

	int unknown=0;


	foreach it in $items[] {
		if(is_tradeable(it)) {
			if(closet_amount(it)>0)
				take_closet(closet_amount(it), it);
				//if have store, remove all
			if(item_amount(it) > 0) {
				if(ocd contains it) {
					if(ocd[it].q <0) //skip ones where we keep all
						continue;
					int tosell = item_amount(it)-ocd[it].q;
					if(tosell <=0) //skip if we have correct number
						continue;
					cli_execute("gc");	
					switch (ocd[it].action) {
					case "mall":
						price_advice [10] all_adv = price_advisor(it,false);
						price_advice adv = all_adv[0];
	//print("advice="+adv.action,"olive");


	//autosell---------------------------------------------------				
						if(contains_text(adv.action,"autosell "))
						{
							if(tosell>0)
							{
								if(auto_q != 0)
									auto[auto_line]= auto[auto_line] + ", ";
								auto_total = autosell_price(it) * (item_amount(it)-ocd[it].q) + auto_total;
								auto[auto_line]= auto[auto_line] + to_string(item_amount(it)-ocd[it].q)+ " "+to_string(it);
								auto_q = auto_q + 1;
								if(auto_q == 11)
								{
									auto_line = auto_line +1;
									auto_q = 0;
								}
							}
							continue;
						}
					
	//smash---------------------------------------------------		
						if(contains_text(adv.action,"smash "+it))
						{
							if(tosell>0)
							{
								int spare = item_amount(it) - ocd[it].q;
								if(have_skill($skill[pulverize]))
								{
									print("smash "+spare+" "+it,"blue");
									cli_execute("smash "+spare+" "+it);
									continue;
								}
								print("csend "+spare+" "+it+" to nimos","blue");
								cli_execute("csend "+spare+" "+it+" to nimos");
							}
							continue;
						}
						
	//mallsell---------------------------------------------------		
						if(contains_text(adv.action,"mallsell "))
						{
							if(tosell>0)
							{
								if(item_amount(it) <= ocd[it].q)
									continue;
								if(mall_q != 0)
									mall[mall_line]= mall[mall_line] + ", ";
								mall[mall_line]= mall[mall_line] + to_string(item_amount(it)-ocd[it].q)+ " "+to_string(it);
								mall_q = mall_q + 1;
								if(mall_q == 11)
								{
									mall_line = mall_line +1;
									mall_q = 0;
								}
							}
							continue;
						}
						else
						{
							print("Unknown action "+adv.action,"red");
						}
						continue;
					}
				} else {
					print("save [$item["+it+"]] = ;","red");
					//print("ID="+to_int(it),"red");
					//as long as it's not the "drink me" potion count as unknown
					if(to_int(it)!=4508)
					{
						unknown=unknown+1;	
					}					
				}
			}
		}
	}



	if(auto[0]. length() != 0) {
		foreach key in auto {
			print("autosell "+ auto[key], "blue");
			cli_execute("autosell "+ auto[key]);
		}
	}
	if(mall[0]. length() != 0) {
		foreach key in mall {
			print("mallsell "+ mall[key], "blue");
			cli_execute("mallsell "+ mall[key]);
		}
	}
	cli_execute("undercut");
	if(pulv[0]. length() != 0) {
		foreach key in pulv {
			print("pulverize "+ pulv[key], "blue");
			cli_execute("pulverize "+ pulv[key]);
		}
	}

	if(auto_total >0)
		print("Total autosale value: "+auto_total, "blue");
	if(mall_total >0)
		print("Total mall value: "+mall_total, "blue");
	if(restore_outfit) {
		outfit("Backup");
		if(fam_equip != $item[none])
			equip($slot[familiar], fam_equip);
	}


	if(unknown!=0)
	{
		abort("Unknown items="+unknown);
	}

	//Since a lot of price data was just garnered...
	cli_execute("spade prices http://zachbardon.com/mafiatools/updateprices.php");

	print("This inventory is clean.", "green");
	set_property("_inv_cleaned_"+my_name(),true);
}
