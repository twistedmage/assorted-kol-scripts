// OCD Inventory Control v2.1
import <PriceAdvisor.ash>;

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

void take_shop(item i) {
   visit_url("managestore.php?action=take&whichitem="+i.to_int()+"&pwd");
}

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
if(can_interact() && my_name()=="twistedmage")
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
	mall_sell($item[floaty sand]);
	mall_sell($item[floaty pebbles]);
	mall_sell($item[floaty gravel]);
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
	mall_sell($item[NG]);
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
if(item_amount($item[saucepan])==3 || item_amount($item[saucepan])==7)
{
	print("clearing out saucepan","blue");
	cli_execute("autosell saucepan");
}

// Make pies if ns beaten and use gift certificates
if (contains_text(visit_url("questlog.php?which=1"),"defeated the Naughty Sorceress and freed the King"))
{
	create(item_amount($item[Boris's key]), $item[Boris's key lime pie]);
	create(item_amount($item[Jarlsberg's key]), $item[Jarlsberg's key lime pie]);
	create(item_amount($item[Sneaky Pete's key]), $item[Sneaky Pete's key lime pie]);
	create(item_amount($item[digital key]), $item[digital key lime pie]);
	create(item_amount($item[Richard's star key]), $item[star key lime pie]);
}
cli_execute("use * Warm Subject gift certificate,  * black pension check,  * old coin purse,  * old leather wallet,  * ancient vinyl coin purse");

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



// pluralize(item, int) : Returns the plural if amount != 1, 
// otherwise the singular
// Ganked from matt.chugg's post #19 on the zlib thread, but spelled in American
string pluralize(item i, int amount)
{
	if (amount==1) return to_string(i);
	return to_plural(i);
}

string acq_string;

//acquire correct amount of first mat needed, then call recursively till all mats gained
int acquire(string orig_item, string action, int number)
{
	//separate out first amount and item
//print(action,"green");
	int pos = index_of(action," ");
	int pos2=index_of(action," ",pos+1);
	//amount is between first and second space
	int quantity = to_int(substring(action,pos,pos2));
	int pos3 = index_of(action,";");
	int pos4 = index_of(action,",");
	string mat_name;
	//item is between second space and comma or semicolon
	if(pos3<pos4 || pos4==-1)
	{
		mat_name=substring(action,pos2+1,pos3);
//print("mat_name="+mat_name,"blue");
//print("pluralize(to_item(orig_item)="+pluralize(to_item(orig_item),5),"blue");
		if(mat_name==pluralize(to_item(orig_item),quantity))
		{
//print("mod1","blue");
			int old_number=number;
//print("old_num"+old_number,"blue");
			number=ceil(to_float(number)/to_float(quantity+1));
//print("num"+number,"blue");
			quantity=number*(quantity+1)-old_number;
//print("quant="+quantity,"blue");
		}
		else
		{
			quantity=(number*quantity)-item_amount(to_item(mat_name,quantity));
		}
		//do acquire
		if(quantity>0)
		{
			print("acquire "+quantity+" "+mat_name+";","green");
			acq_string=acq_string+"acquire "+quantity+" "+mat_name+";";
		}
	}
	else
	{
		mat_name=substring(action,pos2+1,pos4);
//print("mat_name="+mat_name,"blue");
//print("pluralize(to_item(orig_item)="+pluralize(to_item(orig_item),5),"blue");
		if(mat_name==pluralize(to_item(orig_item),quantity))
		{
//print("mod2","blue");
			int old_number=number;
//print("old_num"+old_number,"blue");
			number=ceil(to_float(number)/to_float(quantity+1));
			//if comma continue to next
			number = acquire(orig_item,substring(action,pos4+1),number);
//print("num"+number,"blue");
			quantity=number*(quantity+1)-old_number;
//print("quant="+quantity,"blue");
		}
		else
		{
//print("quanta="+quantity,"blue");
			//if comma continue to next
			number = acquire(orig_item,substring(action,pos4+1),number);
			quantity=(number*quantity)-item_amount(to_item(mat_name,quantity));
//print("quantb="+quantity,"blue");
		}
		//do acquire
		if(quantity>0)
		{
			print("acquire "+quantity+" "+mat_name+";","green");
			acq_string=acq_string+"acquire "+quantity+" "+mat_name+";";
		}
	}
//print("returning "+number,"cyan");
	return number;
}

void star_craft(int stars, int lines, int repeats)
{
	while(repeats>0)
	{
		print("starchart.php?action=makesomething&numstars="+stars+"&numlines="+lines+"&pwd");
		visit_url("starchart.php?action=makesomething&numstars="+stars+"&numlines="+lines+"&pwd");
		repeats=repeats-1;
	}
}

void combine(item it1, item it2, int times)
{
	print("craft.php?mode=combine&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Combine%21&pwd");
	visit_url("craft.php?mode=combine&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Combine%21&pwd");
}

void cook(item it1, item it2, int times)
{
	print("craft.php?mode=cook&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Bake%21&pwd");
	visit_url("craft.php?mode=cook&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Bake%21&pwd");
}

void mix(item it1, item it2, int times)
{
	print("craft.php?mode=cocktail&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Shake%21&pwd");
	visit_url("craft.php?mode=cocktail&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Shake%21&pwd");
}

void smith(item it1, item it2, int times)
{
	print("setup to use smith in the box when poss");
	print("craft.php?mode=cocktail&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Tenderize%21+%281+Adventure%29&pwd");
	visit_url("craft.php?mode=cocktail&action=craft&a="+to_int(it1)+"&b="+to_int(it2)+"&qty="+times+"&master=Tenderize%21+%281+Adventure%29&pwd");
}

void wok(item it1, item it2, item it3, int times)
{
	item chosen;
	if(it1!=$item[MSG] && it1!=$item[dry noodles])
	{
		chosen=it1;
	}
	else if(it2!=$item[MSG] && it2!=$item[dry noodles])
	{
		chosen=it2;
	}
	else
	{
		chosen=it3;
	}
	print("guild.php?action=wokcook&whichitem="+to_int(chosen)+"&quantity="+times+"&pwd");
	visit_url("guild.php?action=wokcook&whichitem="+to_int(chosen)+"&quantity="+times+"&pwd");
}

foreach it in $items[] {
	if(is_tradeable(it)) {
		if(closet_amount(it)>0)
			take_closet(closet_amount(it), it);
			//if have store, remove all
		if(item_amount(it) > 0) {
			if(ocd contains it) {
				if(ocd[it].q <0)
					continue;
				cli_execute("gc");	
				switch (ocd[it].action) {
				case "mall":
					price_advice [10] all_adv = price_advisor(it,true);
					price_advice adv = all_adv[0];
					int tosell = item_amount(it)-ocd[it].q;
//print("advice="+adv.action,"olive");


//still---------------------------------------------------		
					if(contains_text(adv.action,"still"))
					{
						int cur=0;
						while(contains_text(adv.action,"still"))
						{
							cur=cur+1;
							adv = all_adv[cur];
						}
					}
//acquire mats, then continue with remainder of actionstring--------------------------
					if(index_of(adv.action,"acquire")==0)
					{
						if(tosell>0 && can_interact())
						{
							tosell = acquire(it,adv.action,tosell);
							int pos = index_of(adv.action,";");
							adv.action = substring(adv.action,pos+1);
print("remaining action string="+adv.action,"blue");							
						}
						else
						{ //if we don't have spares go to next
							continue;
						}
					}
					
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
					
//multi and single use---------------------------------------------------		
					if(contains_text(adv.action,"use "+it))
					{
						if(tosell>0)
						{
							print("use "+tosell+" "+it,"blue");
							cli_execute("use "+tosell+" "+it);
						}
						continue;
					}
					
//untinker---------------------------------------------------		
					if(contains_text(adv.action,"untinker "+it))
					{
						while(tosell>0)
						{
							cli_execute("untinker "+tosell+" "+it);
						}
						continue;
					}
					
//starchart---------------------------------------------------		
					if(contains_text(adv.action,"; starchart "))
					{
						if(tosell>0)
						{
							cli_execute(acq_string);
							int pos=index_of(adv.action,"; starchart ");
							int pos2=index_of(adv.action," ",pos+13);
							int lines = to_int(substring(adv.action,pos+12,pos2));
							pos=index_of(adv.action,",",pos2);
							pos2=index_of(adv.action," ",pos+2);
							int stars = to_int(substring(adv.action,pos+1,pos2));
							star_craft(stars,lines,tosell);
						}
					}
					
//fold---------------------------------------------------		
					if(contains_text(adv.action,"fold "))
					{
						if(tosell>0)
						{
							int pos=index_of(adv.action,";");
							pos=index_of(adv.action," ",pos+2);
							int pos2=index_of(adv.action,";",pos);
							item result = to_item(substring(adv.action,pos,pos2));
							//for sugar do make, for others do fold
							if(contains_text(to_string(result),"sugar"))
							{
								print("make "+tosell+" "+result);
								cli_execute("make "+tosell+" "+result);
							}
							else //not implemented
							{
								print("fold "+tosell+" "+result);
								cli_execute("fold "+tosell+" "+result);
							}
						}
						continue;
					}
					
//supertinker---------------------------------------------------		
					if(contains_text(adv.action,"supertinker"))
					{
						if(tosell>0)
						{
							if(in_moxie_sign())
							{
								//perform supertinkage
							}
							else
							{
								//insert name of moxie sign person
								//cli_execute("csend "+tosell+" "+it+" to xxxxxxx");
							}
						}
						continue;
					}
					
//malus---------------------------------------------------		
					if(contains_text(adv.action,"malus"))
					{
						if(tosell>0)
						{
							if(have_skill($skill[pulverize]) && (my_class()==$class[seal clubber] || my_class()==$class[turtle tamer]))
							{
								//work out what to malus
								int pos=index_of(adv.action,"malus ");
								int pos2=index_of(adv.action," ",pos+6);
								int amount = to_int(substring(adv.action,pos+5,pos2));
								pos=pos2;
								pos2=index_of(adv.action,";",pos+1);
								item to_mal = to_item(substring(adv.action,pos+1,pos2),amount);
								print(amount);
								print(to_mal);
								//perform malusage
								print("guild.php?action=malussmash&whichitem="+to_int(to_mal)+"&quantity="+tosell+"&pwd");
								//visit_url("guild.php?action=malussmash&whichitem="+to_int(to_mal)+"&quantity="+tosell+"&pwd");
							}
							else
							{
								cli_execute("csend "+tosell+" "+it+" to nimos");
							}
						}
						continue;
					}
					
//combine---------------------------------------------------		
					if(contains_text(adv.action,"combine"))
					{
						if(tosell>0)
						{
							cli_execute(acq_string);
							//work out first thing to combine
							int pos=index_of(adv.action,"combine ");
							int pos2=index_of(adv.action," ",pos+8);
							int amount1 = to_int(substring(adv.action,pos+8,pos2));
							if(amount1==1)
							{
								pos=pos2;
								pos2=index_of(adv.action,",",pos+1);
								item to_comb1 = to_item(substring(adv.action,pos+1,pos2),amount1);
//print(amount1);
//print(to_comb1);
								//work out second thing to combine
								pos=index_of(adv.action,", ",pos2);
								pos2=index_of(adv.action," ",pos+2);
								int amount2 = to_int(substring(adv.action,pos+2,pos2));
								pos=pos2;
								pos2=index_of(adv.action,";",pos+1);
								item to_comb2 = to_item(substring(adv.action,pos+1,pos2),amount2);
//print(amount2);
//print(to_comb2);
								//perform combine
								combine(to_comb1,to_comb2,tosell);
							}
							else //combining 2 of same item
							{
								pos=pos2;
								pos2=index_of(adv.action,";",pos+1);
								item to_comb1 = to_item(substring(adv.action,pos+1,pos2),amount1);
								print(amount1);
								print(to_comb1);
								combine(to_comb1,to_comb1,tosell);
							}
						}
						continue;
					}
					
//cook---------------------------------------------------		
					if(contains_text(adv.action,"cook"))
					{
						if(tosell>0)
						{
							if(my_name()=="locktite")
							{
								cli_execute(acq_string);
								//work out first thing to cook
								int pos=index_of(adv.action,"cook ");
								int pos2=index_of(adv.action," ",pos+5);
								int amount1 = to_int(substring(adv.action,pos+5,pos2));
								pos=pos2;
								pos2=index_of(adv.action,",",pos+1);
								item to_comb1 = to_item(substring(adv.action,pos+1,pos2),amount1);
								print(amount1);
								print(to_comb1);
								//work out second thing to cook
								pos=index_of(adv.action,", ",pos2);
								pos2=index_of(adv.action," ",pos+2);
								int amount2 = to_int(substring(adv.action,pos+2,pos2));
								pos=pos2;
								pos2=index_of(adv.action,";",pos+1);
								item to_comb2 = to_item(substring(adv.action,pos+1,pos2),amount2);
								print(amount2);
								print(to_comb2);
								//perform malusage
								cook(to_comb1,to_comb2,tosell);
							}
							else //send all cooking stuff to locktite
							{
								cli_execute("csend "+tosell+" "+it+" to locktite");
							}
						}
						continue;
					}
					
					
//wok---------------------------------------------------		
					if(contains_text(adv.action,"wok"))
					{
						if(tosell>0)
						{
							cli_execute(acq_string);
							//work out first thing to wok
							int pos=index_of(adv.action,"wok ");
							int pos2=index_of(adv.action," ",pos+4);
							int amount1 = to_int(substring(adv.action,pos+4,pos2));
							pos=pos2;
							pos2=index_of(adv.action,",",pos+1);
							item to_comb1 = to_item(substring(adv.action,pos+1,pos2),amount1);
							print(amount1);
							print(to_comb1);
							//work out second thing to wok
							pos=index_of(adv.action,", ",pos2);
							pos2=index_of(adv.action," ",pos+2);
							int amount2 = to_int(substring(adv.action,pos+2,pos2));
							pos=pos2;
							pos2=index_of(adv.action,",",pos+1);
							item to_comb2 = to_item(substring(adv.action,pos+1,pos2),amount2);
							print(amount2);
							print(to_comb2);
							//work out second thing to wok
							pos=index_of(adv.action,", ",pos2);
							pos2=index_of(adv.action," ",pos+2);
							int amount3 = to_int(substring(adv.action,pos+2,pos2));
							pos=pos2;
							pos2=index_of(adv.action,";",pos+1);
							item to_comb3 = to_item(substring(adv.action,pos+1,pos2),amount3);
							print(amount3);
							print(to_comb3);
							//perform malusage
							wok(to_comb1,to_comb2,to_comb3,tosell);
						}
						continue;
					}
					
//mix---------------------------------------------------		
					if(contains_text(adv.action,"mix"))
					{
						if(tosell>0)
						{
							if(my_name()=="logayn")
							{
								cli_execute(acq_string);
								//work out first thing to cook
								int pos=index_of(adv.action,"mix ");
								int pos2=index_of(adv.action," ",pos+4);
								int amount1 = to_int(substring(adv.action,pos+4,pos2));
								pos=pos2;
								pos2=index_of(adv.action,",",pos+1);
								item to_comb1 = to_item(substring(adv.action,pos+1,pos2),amount1);
								print(amount1);
								print(to_comb1);
								//work out second thing to cook
								pos=index_of(adv.action,", ",pos2);
								pos2=index_of(adv.action," ",pos+2);
								int amount2 = to_int(substring(adv.action,pos+2,pos2));
								pos=pos2;
								pos2=index_of(adv.action,";",pos+1);
								item to_comb2 = to_item(substring(adv.action,pos+1,pos2),amount2);
								print(amount2);
								print(to_comb2);
								//perform malusage
								mix(to_comb1,to_comb2,tosell);
							}
							else //send all cooking stuff to logayn
							{
								cli_execute("csend "+tosell+" "+it+" to logayn");
							}
						}
						continue;
					}
					
//cocktailcraft---------------------------------------------------		
					if(contains_text(adv.action,"cocktailcraft "))
					{
						if(tosell>0)
						{
							cli_execute(acq_string);
							//work out first thing to cook
							int pos=index_of(adv.action,"cocktailcraft ");
							int pos2=index_of(adv.action," ",pos+14);
							int amount1 = to_int(substring(adv.action,pos+14,pos2));
							pos=pos2;
							pos2=index_of(adv.action,",",pos+1);
							item to_comb1 = to_item(substring(adv.action,pos+1,pos2),amount1);
							print(amount1);
							print(to_comb1);
							//work out second thing to cook
							pos=index_of(adv.action,", ",pos2);
							pos2=index_of(adv.action," ",pos+2);
							int amount2 = to_int(substring(adv.action,pos+2,pos2));
							pos=pos2;
							pos2=index_of(adv.action,";",pos+1);
							item to_comb2 = to_item(substring(adv.action,pos+1,pos2),amount2);
							print(amount2);
							print(to_comb2);
							//perform malusage
							mix(to_comb1,to_comb2,tosell);
						}
						continue;
					}
					
//smith---------------------------------------------------		
					if(contains_text(adv.action,"smith"))
					{
						if(tosell>0)
						{
							if(my_name()=="zeldd")
							{
								cli_execute(acq_string);
								//work out first thing to cook
								int pos=index_of(adv.action,"smith ");
								int pos2=index_of(adv.action," ",pos+6);
								int amount1 = to_int(substring(adv.action,pos+6,pos2));
								pos=pos2;
								pos2=index_of(adv.action,",",pos+1);
								item to_comb1 = to_item(substring(adv.action,pos+1,pos2),amount1);
								print(amount1);
								print(to_comb1);
								//work out second thing to cook
								pos=index_of(adv.action,", ",pos2);
								pos2=index_of(adv.action," ",pos+2);
								int amount2 = to_int(substring(adv.action,pos+2,pos2));
								pos=pos2;
								pos2=index_of(adv.action,";",pos+1);
								item to_comb2 = to_item(substring(adv.action,pos+1,pos2),amount2);
								print(amount2);
								print(to_comb2);
								//perform malusage
								smith(to_comb1,to_comb2,tosell);
							}
							else //send all cooking stuff to zeldd
							{
								cli_execute("csend "+tosell+" "+it+" to zeldd");
							}
						}
						continue;
					}
					
//jewelcraft---------------------------------------------------		
					if(contains_text(adv.action,"create jewelry from"))
					{
						if(tosell>0)
						{
							//cli_execute(acq_string);
							abort("jewelcrafting not handled, need example");
						}
						continue;
					}
//trade mushroom---------------------------------------------------		
					if(contains_text(adv.action,"trade"))
					{
						if(tosell>0)
						{
							abort("add to visit suspicious guy");
						}
						continue;
					}
//mystic---------------------------------------------------		
					if(contains_text(adv.action,"have the mystic craft"))
					{
						if(tosell>0)
						{
							cli_execute(acq_string);
							int pos=index_of(adv.action,";");
							pos=index_of(adv.action," ",pos+2);
							int pos2=index_of(adv.action,";",pos);
							item result = to_item(substring(adv.action,pos,pos2));
							//for sugar do make, for others do fold
							print("make "+tosell+" "+result);
							cli_execute("make "+tosell+" "+result);
						}
						continue;
					}
//mallsell---------------------------------------------------		
					if(contains_text(adv.action,"mallsell "))
					{
						if(tosell>0)
						{
							if(my_name()!="twistedmage")
							{
								int spare = item_amount(it) - ocd[it].q;
								print("csend "+spare+" "+it+" to bankymcbank","blue");
								cli_execute("csend "+spare+" "+it+" to bankymcbank");
								continue;
							}
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
				print("ID="+to_int(it),"red");
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
