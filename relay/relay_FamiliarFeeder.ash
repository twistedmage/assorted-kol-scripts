#/******************************************************************************/
#                          Familiar Feeder Helper v0.91 beta
#                          Feeding your familiars since 2010
#*******************************************************************************/
#    
#	Familiar Feeder relay script by slyz.
#	See http://kolmafia.us/showthread.php?3919 for instructions.
#
#*******************************************************************************/
#
#	Original idea stolen from Bleary here:
#	http://kolmafia.us/showthread.php?2113&p=25376&viewfull=1#post25376
#
#	Thanks to Aqualectrix, Bale, dj_d and Zarqon for posting so much
#	helpful code for us to stea--- plund--- cop--- be inspired by!
#
#*******************************************************************************/
script "FamiliarFeeder";

import "htmlform.ash";
import "SmashLib.ash";

string thisver = "0.91 beta";

boolean debug = false ;		// if set to true, commands are not executed

//*******************/
//	  Initializing
//*******************/

// records

record create_info {
	int q ;
	float cost ;
	int[item] ingredients_to_keep ;
	float feed_mp ;
	float feed_meatpermp ;
};
record feed_info {
	item  it ;
	float feed_mp ;
	float feed_meatpermp ;
	create_info creat ;
	boolean meat_stack ;
};

// maps

int[item] keep ; 			  // map of items to keep and their quantities
string[item] concoctions ;	  // stolen from PriceAdvisor.ash
int[item] inventory ; 		  // map of inventory items and their quantities
create_info[item] creatable;  // map of feedable items that can be created from inventory and NPC stores
feed_info[int] feedable ;	  // map of feedable items
string[familiar] familiars;	  // map of familiars you can feed
boolean[item] currently_considering; // prevent infinite recursion
int[item] Ender_beer;		  // number of Bart Ender beers to feed

// global variables

int max_itm_quant ;			// used as a boundary for user input
familiar fam ;				// familiar to feed
float currentWeight ;		// familiar's weight with its equipment and the player's current modifiers
float mppercharge ;			// average amount of MP given by the familiar when it acts
float meatpermp ;			// cost of buying MP
//string message ;			// message used by the confirmation pop-up
int num_starters ;			// number of chewing gum items to feed

// shortcuts to avoid typing

familiar slimeling = $familiar[Slimeling] ;
familiar GGG = $familiar[Gluttonous Green Ghost] ;
familiar hobo = $familiar[Spirit Hobo] ;

item gum = $item[chewing gum on a string] ;
boolean[item] unfeedable_starters = $items[	worthless trinket, worthless gewgaw, worthless knick-knack, old sweatpants] ;
boolean[item] feedable_starters   = $items[	seal-skull helmet, seal-clubbing club,
											helmet turtle, turtle totem,
											ravioli hat, pasta spoon,
											Hollandaise helmet, saucepan,
											disco mask, disco ball,
											mariachi hat, stolen accordion ] ;


//********************************/
//	  Set up maps and variables
//********************************/ 

// load form fields from previous instance
fields = form_fields();

// confirmation message
//message = "Are you sure? Check the gCLI to see the command that will be executed.";

// load items to keep
if ( !file_to_map("Feeder_keep.txt", keep) )
	abort("Failed to load file Feeder_keep.txt");

// check if 'Keep' button has been used
if ( fields contains "keep" && fields["keepQuant"].is_integer() ) {
	item itm ;
	matcher item_num ;
	foreach f_name, f_value in fields {
		item_num = create_matcher("(it|itKeep)(\\d+)", f_name);
		if ( item_num.find() && f_value == "on" )
			itm = item_num.group( 2 ).to_item() ;
		else continue ;
		
		if 		( fields["keepOpt"] == "keepAll" 	 ) keep[itm] = -1 ;
		else if ( fields["keepOpt"] == "keepOne" 	 ) keep[itm] =  1 ;
		else if ( fields["keepOpt"] == "keepByQuant" ) keep[itm] = fields["keepQuant"].to_int() ;
	}
	fields["keepQuant"] = 0 ;	// reset the field to 0
	if ( !map_to_file(keep, "Feeder_keep.txt") )
		abort("Failed to save file Feeder_keep.txt");
}
void keep_cleanup() ;
keep_cleanup() ;

// map of feedable familiars and their associated CLI commands
if ( have_familiar(slimeling)	|| debug ) familiars[slimeling] = "slimeling " ;
if ( have_familiar(GGG)			|| debug ) familiars[GGG] = "ghost " ;
if ( have_familiar(hobo)		|| debug ) familiars[hobo] = "hobo " ;

// choose familiar
fam = GGG ;				// for debugging
fam = hobo ;			// for debugging
fam = slimeling ;		// for debugging
if ( count(familiars) == 0 )
	fam = my_familiar() ;		// so the script can run for people without any feedable familiars
else if ( familiars contains my_familiar() )
	fam = my_familiar() ;		// selected the current familiar if it's feedable
else foreach f in $familiars[Spirit Hobo, Slimeling, Gluttonous Green Ghost, ]
	if ( have_familiar(f) ) { fam = f; break; }	// selected the first feedable familiar found

// check if a 'Take out Familiar' button has been used in the previous instance
if ( fields contains "fam_equip_slime" ) {
	fam = slimeling ;
	if ( !debug ) use_familiar(fam) ;
}
else if ( fields contains "fam_equip_ghost" ) {
	fam = GGG ;
	if ( !debug ) use_familiar(fam) ;
}
else if ( fields contains "fam_equip_hobo" ) {
	fam = hobo ;
	if ( !debug ) use_familiar(fam) ;
}

// load corresponding maps

// handling of concoctions.txt stolen from priceAdvisor.ash
if ( !file_to_map("concoctions.txt", concoctions) )
	abort("Failed to load concoctions.txt");

// Add funny concoctions that don't load properly
concoctions[$item[bottle of gin]] = "MIX";
concoctions[$item[bottle of rum]] = "MIX";
concoctions[$item[bottle of sake]] = "MIX";
concoctions[$item[bottle of tequila]] = "MIX";
concoctions[$item[bottle of whiskey]] = "MIX";
concoctions[$item[bottle of vodka]] = "MIX";
concoctions[$item[boxed wine]] = "MIX";	

// remove Clip Art items, which are not really concoctions
for ClipArt from 5224 to 5283
{
	remove concoctions[ ClipArt.to_item() ];
}

// strip extra conditions used by Mafia -- 
// taken into account by get_ingredients(), so I don't need 'em
foreach itm, c_type in concoctions {
	c_type = replace_string(c_type, "TORSO", "");
	c_type = replace_string(c_type, "FEMALE", "");
	c_type = replace_string(c_type, "MALE", "");
	c_type = replace_string(c_type, "HAMMER", "");
	c_type = replace_string(c_type, "WEAPON", "");
	c_type = replace_string(c_type, "SSPD", "");
	c_type = replace_string(c_type, "GRIMACITE", "");
	c_type = replace_string(c_type, "SX3", "");
	
	// remove any remaining trailing ", "
	while (last_index_of(c_type, ", ") == length(c_type) - 2)
	{ c_type = substring(c_type, 0, length(c_type) - 2); }
	
	concoctions[itm] = c_type ;
}

// estimate Meat/MP (stolen from SmartStasis.ash). Will use the UniversalRecovery value if set.
if ( get_property("_meatpermp") != "" )
	meatpermp = to_float(get_property("_meatpermp"));
else {
	meatpermp = 17;  // galaktik base calc
	if ( have_outfit("Knob Goblin Elite Guard Uniform") ) meatpermp = 8; 
	if (	( my_primestat() == $stat[mysticality] || ( my_class() == $class[accordion thief] && my_level() > 8 ) )
		&&	( guild_store_available() ) )
	meatpermp = 100.0 / (1.5 * to_float(my_level()) + 5); // mmj calc if available
}

// Current familiar weight to use for calculations (with its current equipment)
// even if it isn't currently out of the terrarium
string cli_exec = "whatif up Brined Liver; ";  // Brined liver is so that the whatif command doesn't fail if nothing is added
if ( familiar_equipment(my_familiar()) != $item[none] ) cli_exec = cli_exec + "unequip familiar; ";
if ( familiar_equipped_equipment(fam)  != $item[none] ) cli_exec = cli_exec + "equip "+familiar_equipped_equipment(fam);
cli_execute(cli_exec+"; quiet;");
currentWeight = familiar_weight(fam) + numeric_modifier("_spec","familiar weight") ;

// starfish restores int((X+3)/2) to (X+3), where X is the weight of the familiar.
// slimeling has a greater range, but maybe the same mean?
mppercharge = .75 * (currentWeight + 3) ;


//*******************/
//		  Code
//*******************/

float pretty ( float num ) { return round(num*100)/100.0 ; }

// hack of Zarqon's check_version, for printing in the relay browser instead of the gCLI.
void check_version_relay(string soft, string prop, string thisver, int thread) { int w;
	switch (get_property("_version_"+prop)) {
	  case thisver: return;
	  case "": print("Checking for updates (running "+soft+" ver. "+thisver+")...");
		 matcher find_ver = create_matcher("<b>"+soft+" (.+?)</b>",visit_url("http://kolmafia.us/showthread.php?t="+thread)); w=19;
		 if (!find_ver.find()) { print("Unable to load current version info.","red"); return; }
		 set_property("_version_"+prop,find_ver.group(1));
		 if (find_ver.group(1) == thisver) { print("You have a current version of "+soft+"."); return; }
			return;
	  default:
		 writeln("<big><font color=red><b>New Version of "+soft+" Available: "+get_property("_version_"+prop)+"</b></font></big><br>");
		 writeln("Upgrade "+soft+" from "+thisver+" to "+get_property("_version_"+prop)+" here: <a HREF='http://kolmafia.us/showthread.php?t="+thread+"'>http://kolmafia.us/showthread.php?t="+thread+"</a><br><br>");
	}
}

void keep_cleanup() {
	// keep the Swashbuckling outfit only if you have the Fledges and can equip them
	if ( available_amount($item[pirate fledges]) > 0 && can_equip($item[pirate fledges]) ) {
		remove keep[$item[swashbuckling pants]];
		remove keep[$item[stuffed shoulder parrot]];
		remove keep[$item[eyepatch]];
	}

	boolean have_frat_war = true;
	foreach itm in $items[beer helmet, distressed denim pants, bejeweled pledge pin]
		if ( available_amount(itm) == 0 ) { have_frat_war = false ; break ; }

	boolean have_hippy_war = true;
	foreach itm in $items[reinforced beaded headband, bullet-proof corduroys, round purple sunglasses]
		if ( available_amount(itm) == 0 ) { have_hippy_war = false ; break ; }

	if ( have_frat_war || have_hippy_war ) {
		if ( keep[$item[filthy corduroys]] == 1 )
			remove keep[$item[filthy corduroys]];
		if ( keep[$item[filthy knitted dread sack]] == 1 && available_amount($item[Clan VIP Lounge key]) == 0 )
			remove keep[$item[filthy knitted dread sack]];
	}

	// Make sure you only keep the worst hat for the +weapon damage hatter buff
	boolean have_unfeedable_hat = false ;
	foreach itm in $items[Crimbo hat, maiden wig, rave visor, bark beret, BRICKO hat]
		if ( available_amount(itm) > 0 ) { have_unfeedable_hat = true ; break ; }

	item[int] hats;	// list of feedable hats, sorted by meatpermp
	hats[0] = $item[opera mask] ;
	hats[1] = $item[mullet wig] ;
	hats[2] = $item[goat beard] ;
	hats[3] = $item[mummy mask] ;
	hats[4] = $item[yak toupee] ;
	hats[5] = $item[balaclava ] ;
	hats[6] = $item[Mohawk wig] ;
	hats[7] = $item[chef's hat] ;
	hats[8] = $item[sleep mask] ;

	foreach i, itm in hats {
		if ( ( have_unfeedable_hat || available_amount($item[Clan VIP Lounge key]) == 0 ) && keep[hats[i]] == 1 )
		{ remove keep[hats[i]] ; continue ; }
		if ( available_amount(itm) == 0 ) continue ;
		foreach j in hats
			if ( j != i && keep[hats[j]] == 1 ) remove keep[hats[j]] ;
		break ;
	}
	
	// Make sure you keep a chef's hat if you don't have a chef-in-the-box
	boolean keep_chef_hat = 	( keep[$item[chef's hat]] != 0 )
							&& 	( can_eat() || have_familiar(GGG) )
							&&  ( item_amount( $item[chef-in-the-box] ) == 0 )
							&& !( get_campground() contains $item[chef-in-the-box] )
							&&  ( item_amount( $item[clockwork chef-in-the-box] ) == 0 )
							&& !( get_campground() contains $item[clockwork chef-in-the-box] ) ;
	if ( keep[$item[chef's hat]] == 0 && keep_chef_hat )
		keep[$item[chef's hat]] = 1 ;
	
	// Make sure you only keep the worst guitar for the Lair
	boolean have_unfeedable_guitar = false ;
	foreach itm in $items[stone banjo, Disco Banjo, Shagadelic Disco Banjo, Seeger's Unstoppable Banjo, Crimbo ukelele, Zim Merman's guitar]
		if ( available_amount(itm) > 0 ) { have_unfeedable_guitar = true ; break ; }
	
	item[int] guitars;	// list of feedable guitars, sorted by meatpermp
	guitars[0] = $item[half-sized guitar] ;
	guitars[1] = $item[massive sitar] ;
	guitars[2] = $item[heavy metal thunderrr guitarrr] ;
	guitars[3] = $item[4-dimensional guitar] ;
	guitars[4] = $item[plastic guitar] ;
	guitars[5] = $item[acoustic guitarrr] ;
	guitars[6] = $item[out-of-tune biwa] ;
	
	foreach i, itm in guitars {
		if ( have_unfeedable_guitar && keep[guitars[i]] == 1 ) { remove keep[guitars[i]] ; continue ; }
		if ( available_amount(itm) == 0 ) continue ;
		foreach j in guitars
			if ( j != i && keep[guitars[j]] == 1 ) remove keep[guitars[j]] ;
		break ;
	}
	
	// Make sure you only keep the worst drum for the Lair
	item[int] drums;	// list of feedable drums, sorted by meatpermp
	drums[0] = $item[jungle drum] ;
	drums[1] = $item[tambourine] ;
	drums[2] = $item[hippy bongo] ;
	drums[3] = $item[black kettle drum] ;
	drums[4] = $item[big bass drum] ;
	drums[5] = $item[bone rattle] ;
	foreach i, itm in drums {
		if ( available_amount(itm) == 0 ) continue ;
		foreach j in drums
			if ( j != i && keep[drums[j]] == 1 ) remove keep[drums[j]] ;
		break ;	
	}
	
	// Do not feed key lime pies because you don't get the key back
	foreach key in $items[ 	Richard's star key,
							digital key,
							Boris's key,
							Jarlsberg's key,
							Sneaky Pete's key ]
		keep[ key ] = -1 ;
	
	// Keep garnishes and booze only if you can drink
	if ( !can_drink() ) {
		remove keep[$item[coconut shell]];
		remove keep[$item[magical ice cubes]];
		remove keep[$item[little paper umbrella]];
		foreach itm in keep
			if ( item_type(itm) == "booze" )
				remove keep[itm];
	}

	// Keep food only if you can eat
	if ( !can_eat() ) {
		remove keep[$item[dry noodles]];
		remove keep[$item[spices]];
		remove keep[$item[scrumptious reagent]];
		foreach itm in keep
			if ( item_type(itm) == "food" && itm != $item[enchanted bean] && itm != $item[black pepper] )
				remove keep[itm];
	}
}

boolean is_feedable( item itm ) {
	if ( !is_tradeable(itm) || autosell_price(itm) < 1 ) return false ;
	switch ( fam ) {
		case slimeling:
			return ( !is_npc_item(itm) && get_power(itm) > 0 );
		case GGG:
			return ( !is_npc_item(itm) && item_type(itm) == "food"  && itm.levelreq > 0 && itm.adventures != "0" );
		case hobo:
			return ( item_type(itm) == "booze" && itm.levelreq > 0 && itm.adventures != "0" );
	} return false ;
}

float get_num_adv( string range ) {
	float num_adv;
	string[int] split_range = split_string(range, "-");
	if ( count(split_range) == 1 ) num_adv = split_range[0].to_float() ;
	else num_adv = ( split_range[0].to_int() + split_range[1].to_int() ) / 2.0 ;
	return num_adv ;
}

float num_charge( item itm ) {
	switch ( fam ) {
		case slimeling:
			return max(get_power(itm) / 10.0, .5);
		case GGG:
		case hobo:
			return get_num_adv(itm.adventures);
	} return 0.0 ;
}

float smash_value( item it ) {
	int value = 0 ;
	if ( !( have_skill($skill[Pulverize]) || debug ) || !is_smashable(it) )
		return value ;
	float [item] smash_yield = get_smash_yield(it);
	foreach yield in smash_yield
		value = value + autosell_price(yield) * smash_yield[yield];
	return value;
}
float itm_value( item itm ) { return max( autosell_price(itm), smash_value(itm) ); }

// the only circular concoctions are clovers, dough, and the charrrms.
// clovers have no autosell value, and shouldn't be fed, dough is an NPC item.
float get_cost( item itm ) {
	if ( autosell_price(itm) == 0 ) return -1 ;
	if ( is_npc_item(itm) ) return 2 * autosell_price(itm) ;
	if ( count(get_ingredients(itm)) > 0 ) {
		int cost = 0;
		if ( concoctions[itm] == "COMBINE" && !knoll_available() )
			cost += 10 ;
		foreach ingred, q in get_ingredients(itm) {
			if ( ingred == $item[ charrrm bracelet ] )
			{
				cost += autosell_price( ingred );
				continue;
			}
			if ( get_cost(ingred) < 0 ) return -1 ;
			cost += q * get_cost(ingred) ;
		}
		return cost ;
	}
	return itm_value(itm) ;
}

string get_advice( item itm ) {
	if ( smash_value(itm) > autosell_price(itm) ) return "Pulverize";
	return "Autosell";
}

// return all the 'to keep' items (and associated quantities) used to craft item itm
int[item] items_to_keep_used( item itm ) {
	int[item] to_keep_used;
	int[item] ingreds = get_ingredients(itm);
	currently_considering[itm] = true ;	
	foreach ingred in ingreds {
		if ( currently_considering[ingred] ) continue ;
		if ( keep[ingred] != 0 ) to_keep_used[ingred] += ingreds[ingred];
		currently_considering[ingred] = true ;	
		foreach it,q in items_to_keep_used(ingred) {
			if ( currently_considering[it] ) continue ;
			to_keep_used[it] += q;
		}
		remove currently_considering[ingred] ;
	}
	remove currently_considering[itm] ;	
	return to_keep_used ;
}

boolean is_meat_stack_item(item itm) {
	if ( itm == $item[Gnollish autoplunger] ) return true ;
	if ( get_ingredients(itm) contains $item[meat stack] ) return true ;
	return false ;
}

int get_num_trinkets() {
	int num = 0 ;
	foreach itm in $items[worthless trinket, worthless gewgaw, worthless knick-knack]
		num += to_int( available_amount(itm) > 0 ) ;
	return num ;
}

// check if crafting item itm will use adventures (loosely adapted from PriceAdvisor.ash)
boolean uses_advs( item itm ) {
	boolean uses_adv = false ;
	if ( is_npc_item(itm) ) return false ;
	if ( count(get_ingredients(itm)) == 0 ) return false ;
	
	switch ( concoctions[itm] ) {
		// always uses an adventure to make
		case "WSMITH":
		case "ASMITH":
		case "MALUS":
		case "WOK":
		case "MSTILL":  // make sure the still won't be used
		case "BSTILL":  //
		case "JEWEL":
		case "EJEWEL":
		case "EXPENSIVE":
			return true ;
		// never uses an adventure to make
		case "PIXEL":
		case "STAR":
		case "ROLL":
		case "SUSE":
		case "MIX":
		case "COOK":
			return false ;
		// sometimes uses an adventure to make
		case "SMITH":
			uses_adv = !knoll_available() ;
			break ;
		case "MIX_FANCY":
		case "ACOCK":
		case "SCOCK":
		case "SACOCK":
			uses_adv = !( get_campground() contains $item[bartender-in-the-box] || get_campground() contains $item[clockwork bartender-in-the-box] ) ;
			break ;
		case "COOK_FANCY":
		case "PASTA":
		case "SAUCE":
		case "SSAUCE":
		case "DSAUCE":
		case "TEMPURA":
			uses_adv = !( get_campground() contains $item[chef-in-the-box] || get_campground() contains $item[clockwork chef-in-the-box] ) ;
			break ;
	}

	currently_considering[itm] = true ;	
	if ( uses_adv == false )
		foreach ingred in get_ingredients(itm) {
			if ( !currently_considering[ingred]  && uses_advs(ingred) )
				return true ;
	}
	remove currently_considering[itm] ;
	return uses_adv ;
}

void init_maps() {
	clear(creatable) ;
	clear(feedable) ;
	max_itm_quant = 0 ;

	// map of items in inventory without the items to keep
	inventory = get_inventory();
	foreach itm, q in inventory {
		if ( keep[itm] > 0 ) inventory[itm] = max( 0, q + equipped_amount( itm ) - keep[itm] ) ;
		else if ( keep[itm] < 0 ) inventory[itm] = 0 ;
	}

	// fill map of creatable items you can feed
	int quant;
	foreach concoct in concoctions {
		quant = creatable_amount(concoct);
		if ( 	quant == 0 || keep[concoct] < 0 || quant + item_amount(concoct) - keep[concoct] < 1
			 || !is_feedable(concoct) || uses_advs(concoct) || get_cost(concoct) < 0 )
			continue ;
		// make sure you don't use items to keep
		foreach ingred, q in items_to_keep_used(concoct) {
			if ( keep[ingred] < 0 ) quant = 0 ;
			else quant = min ( quant, floor( (item_amount(ingred)-keep[ingred]) / q ) ) ;
		}
		if ( quant < 1 ) continue ;
		creatable[concoct].ingredients_to_keep = items_to_keep_used(concoct) ;
		creatable[concoct].cost = max( get_cost(concoct), itm_value(concoct) );
		creatable[concoct].q = quant ;
		creatable[concoct].feed_mp = mppercharge * num_charge(concoct) ;
		creatable[concoct].feed_meatpermp = creatable[concoct].cost / creatable[concoct].feed_mp ;
	}

	// add chewing gum on a string for starter items
	if ( fam == slimeling && ( my_meat() > 50 || inventory[gum] > 0 ) ) {
		float num_feedable = 12 ;
		float num_possible = 16 - get_num_trinkets() - to_int( available_amount($item[old sweatpants]) > 0 ) ;
		creatable[gum].cost = 50.0 * num_possible / num_feedable ;
		quant = floor( ( my_meat() + 50 * inventory[gum] ) / creatable[gum].cost )  ;
		creatable[gum].q = quant ;
		creatable[gum].feed_mp = mppercharge ;
		creatable[gum].feed_meatpermp = creatable[gum].cost / creatable[gum].feed_mp ;
	}
	// add Bart Ender beers 
	if ( my_level() > 2 && fam == hobo ) {
		foreach it in $items[ day-old beer, plain old beer, overpriced "imported" beer ]
		{
			creatable[it].cost = min( 5 * autosell_price(it), 100 ) ;
			creatable[it].q = floor( my_meat() / creatable[it].cost )  ;
			creatable[it].feed_mp = mppercharge * num_charge(it) ;
			creatable[it].feed_meatpermp = creatable[it].cost / creatable[it].feed_mp ;
		}
	}

	// fill map of feedable items
	int index = 0;
	max_itm_quant = 1 ;
	foreach itm in creatable {
		feedable[index].it = itm ;
		if ( inventory[itm] > 0 && itm != gum ) {
			feedable[index].feed_mp = mppercharge * num_charge(itm) ;
			feedable[index].feed_meatpermp = itm_value(itm) / feedable[index].feed_mp ;
		} else {
			feedable[index].feed_mp = creatable[itm].feed_mp ;
			feedable[index].feed_meatpermp = creatable[itm].feed_meatpermp ;
		}
		feedable[index].creat = creatable[itm] ;
		feedable[index].meat_stack = is_meat_stack_item(itm) ;
		if ( inventory[itm] + feedable[index].creat.q > max_itm_quant )
			max_itm_quant = inventory[itm] + feedable[index].creat.q ;
		index = index + 1; 
	}
	foreach itm in inventory {
		if ( inventory[itm] == 0 || creatable[itm].q > 0 || !is_feedable(itm) )
			continue ;
		feedable[index].it = itm ;
		feedable[index].feed_mp = mppercharge * num_charge(itm) ;
		feedable[index].feed_meatpermp = itm_value(itm) / feedable[index].feed_mp ;
		feedable[index].meat_stack = is_meat_stack_item(itm) ;
		if ( inventory[itm] > max_itm_quant )
			max_itm_quant = inventory[itm] ;
		index = index + 1; 
	}
	sort feedable by value.feed_meatpermp ;
}

boolean handle_gum( int num_to_feed ) {
	if ( num_to_feed < 1 ) return true ;

	int num_missing_unfeedable_starters() {
		int num = 0 ;
		foreach itm in unfeedable_starters
			if ( item_amount( itm ) + equipped_amount( itm ) == 0 )
				num += 1 ;
		return num ;
	}
	int num_missing_feedable_starters() {
		int num = 0 ;
		foreach itm in feedable_starters
			if ( item_amount( itm ) + equipped_amount( itm ) == 0 )
				num += 1 ;
		return num ;
	}
	
	int needed = num_to_feed ;
	boolean[item] unequipped ;
	int[item] in_bag ;
	int[item] in_closet ;

	foreach itm in feedable_starters {
		in_bag[itm] = item_amount(itm) ;
		in_closet[itm] = closet_amount(itm) ;
	}
	foreach itm in unfeedable_starters
		in_closet[itm] = closet_amount(itm) ;
	
	// unequip feedable starters
	foreach itm in feedable_starters {
		if ( have_equipped(itm) ) {
			equip( itm.to_slot(), $item[none] );
			unequipped[itm] = true ;
		}
	}

	// uncloset one of each unfeedable starter if there are none in inventory or equipped
	batch_open();
	foreach itm in unfeedable_starters
		if ( closet_amount(itm) > 0 && item_amount(itm) + equipped_amount(itm) == 0 )
			take_closet( 1, itm ) ;
	batch_close();

	// use gums efficiently
	while( needed > 0 ) {
		// closet feedable starters in bag if needed
		batch_open() ;
		int missing = num_missing_feedable_starters() ;
		foreach itm in feedable_starters {
			if ( item_amount(itm) > 0 ) {
				if ( num_missing_unfeedable_starters() == 0 && missing >= needed )
					break ;
				put_closet( item_amount(itm), itm );
				missing += 1 ;
			}
		}
		batch_close() ;
	
		int num_gum =  min( needed , num_missing_unfeedable_starters() + num_missing_feedable_starters() );
		if ( !retrieve_item(num_gum, gum) ) return false ;
		use(num_gum, gum) ;
		
		foreach itm in feedable_starters
			needed -= item_amount(itm) ;
	}

	// remove from the closet starter items that weren't there before
	batch_open() ;
	foreach itm in feedable_starters
		if ( closet_amount(itm) > in_closet[itm] )
			take_closet( closet_amount(itm) - in_closet[itm] , itm );
	batch_close() ;

	// return to closet unfeedable starters that were moved
	// the ones obtained while using the gums stay in your inventory
	batch_open() ;
	foreach itm in unfeedable_starters
		if ( in_closet[itm] > closet_amount(itm) )
			put_closet( 1, itm );
	batch_close() ;

	// equip starter items that were unequipped
	foreach itm in unequipped
		equip(itm) ;

	// feed starting items obtained
	string exec_feed = "slimeling ";
	foreach itm in feedable_starters
		if ( item_amount(itm) > in_bag[itm] )
			exec_feed += "0" + ( item_amount(itm) - in_bag[itm] ) + " " + itm + ", " ;

	if ( debug ) print(exec_feed);
	else cli_execute(exec_feed);
	return true ;
}

boolean handle_beer( int [ item ] beers ) {
	if ( count(Ender_beer) == 0 ) return true ;

	string exec_feed = "hobo ";
	int cost = 0;
	foreach it, q in beers cost += creatable[it].cost * ( q - inventory[it] );
	if ( cost > my_meat() ) {
		print( "It would cost you " + cost + " meat to feed all the Bart Ender beers, you do not have enough meat." );
		return false ;
	}
	foreach it, q in beers {
		buy( q, it );
		exec_feed += q + " " + it + ", ";
	}

	if ( debug ) print(exec_feed);
	else cli_execute(exec_feed);
	return true;
}

// builds the CLI command when the Feed button is used
string build_exec() {
	if ( fields["feedOpt"] == "feedByQuant" && ( fields["feedQuant"].to_int() < 1 || fields["feedQuant"].to_int() > max_itm_quant ) )
		return "";		// let the form validator warn the user

	boolean special_handling ;
	string exec_create ;
	string exec_feed = familiars[fam] ;
	string exec_gum ;
	int[item] to_create ;
	int[item] to_feed ;
	int[item] to_keep_used ;
	int q_i ;		// quantity in inventory to be fed
	int q_c ;		// quantity to be created and fed (items to keep taken into account)
	item itm ;
	string itm_field ;
	foreach i in feedable {
		special_handling = false ;
		itm = feedable[i].it;
		itm_field = "it"+itm.to_int() ;
		if ( fields[itm_field] != "on" ) {
			remove fields[itm_field] ;		// necessary so that unselected checks stay unselected
			continue ;
		}
		remove fields[itm_field] ;			// unselect the item that will be fed
		switch ( fields["feedOpt"] ) {
			case "feedAllCur":
				q_i = inventory[itm] ;
				q_c = 0 ;
				break ;
			case "feedAllCurButOne":
				q_i = inventory[itm] - 1 ;
				q_c = 0 ;
				break ;
			case "feedAll":
				q_i = inventory[itm] ;
				q_c = feedable[i].creat.q ;
				break ;
			case "feedByQuant":
				q_i = min( fields["feedQuant"].to_int() , inventory[itm] ) ;
				q_c = min( max( fields["feedQuant"].to_int() - q_i , 0 ), feedable[i].creat.q ) ;
				break ;
		}
		// update the amount of items to keep that will be used
		if ( keep[itm] != 0 ) to_keep_used[itm] += q_i ;
		// check if items to keep are used for creation, and reduce the created amount if needed
		foreach itm_to_keep, q in feedable[i].creat.ingredients_to_keep
			if ( to_keep_used[itm_to_keep] + q * q_c > item_amount(itm_to_keep) - keep[itm_to_keep] )
				q_c = max ( 0, floor( (item_amount(itm_to_keep) - keep[itm_to_keep] - to_keep_used[itm_to_keep]) / q ) ) ;
		// update the amount of items to keep that will be used
		foreach itm_to_keep, q in feedable[i].creat.ingredients_to_keep
			to_keep_used[itm_to_keep] += q * q_c ;

		if ( itm == gum ) {
			num_starters = q_i + q_c ;
			special_handling = true ;
		}
		foreach it in $items[ day-old beer, plain old beer, overpriced "imported" beer ] {
			if ( itm == it ) {
				Ender_beer[ itm ] = q_i + q_c ;
				special_handling = true ;
			}
		}
		if ( special_handling ) continue ;

		if ( q_c > 0 ) to_create[itm] = q_c ;
		if ( q_i + q_c > 0 ) to_feed[itm] = q_i + q_c ;
	}
	foreach it, q in to_create
		exec_create = exec_create + "create 0" + q + " " + it + "; " ;
	foreach it, q in to_feed
		exec_feed = exec_feed + " 0" + q + " " + it + "," ;
	
	if ( exec_feed.length() == familiars[fam].length() )
		exec_feed = "" ;
	return exec_create + exec_feed ;
}


// HTML

void addJavaToggle() {
	writeln("<script language='javascript' type='text/javascript'>");
	writeln("<!--");
	writeln("   function getCookie(c_name) {");
	writeln("      if (document.cookie.length>0) {");
	writeln("         c_start=document.cookie.indexOf(c_name + '=');");
	writeln("         if (c_start!=-1) {");
	writeln("            c_start=c_start + c_name.length+1;");
	writeln("            c_end=document.cookie.indexOf(';',c_start);");
	writeln("            if (c_end==-1) c_end=document.cookie.length;");
	writeln("            return unescape(document.cookie.substring(c_start,c_end));");
	writeln("         }");
	writeln("      } return '';");
	writeln("   }");
	writeln("");
	writeln("   function setCookie(c_name,value,expiredays) {");
	writeln("      var exdate=new Date();");
	writeln("      exdate.setUTCDate(exdate.getUTCDate()+expiredays);");
	writeln("      document.cookie=c_name + '=' + escape(value) + ((expiredays==null) ? '' : ';expires='+exdate.toUTCString())");
	writeln("   }");
	writeln("");
	writeln("   function check_visibility(id) {");
    writeln("      cookie = getCookie(id);");
    writeln("      var e = document.getElementById(id);");
    writeln("      if (cookie!=null && cookie!='') {");
    writeln("         e.style.display = cookie;");
	writeln("      } else {");
    writeln("         e.style.display = 'inline';");
    writeln("         cookie = 'inline';");
	writeln("      } setCookie(id,cookie,365)");
	writeln("	}");
	writeln("");
	writeln("   function toggle_visibility(id) {");
    writeln("      cookie = getCookie(id);");
    writeln("      var e = document.getElementById(id);");
    writeln("      if (e.style.display == 'inline') {");
    writeln("         e.style.display = 'none';");
    writeln("         cookie = 'none';");
	writeln("      } else {");
    writeln("         e.style.display = 'inline';");
    writeln("         cookie = 'inline';");
	writeln("      } setCookie(id,cookie,365)");
	writeln("	}");
    writeln("//-->");
    writeln(" </script>");
}

/*
void addCSS() {
	writeln("    <style type='text/css'>");
	writeln(
		"td.box { border: 1px solid blue; padding: 1px; }"  +
		"tr.header { background-color: blue; color: white; text-align: center; font-weight: bold; }" +
		"tr.header td { border: 0; padding: 0; }" +
		"div.input { margin: 0.3em 0; clear: both;}" + 
		"div.input label { float: left; text-align: right; width: 14em; margin-right: 1em;}" +
		"div.input input { padding: 0.15em; }"
	);
	writeln("    </style>");
}

void addJavaConfirm( string name, string message ) {
	writeln("<script type='text/javascript'>");
	writeln("<!--");
	writeln("   var answer = confirm('"+message+"');");
    writeln("   if (answer) {");
    writeln("      document.write('<input type=\"hidden\" name=\"" + name + "\" value=\"confirmed\">')");
    writeln("      document.forms[0].submit()");
    writeln("   }");
    writeln("//-->");
    writeln("</script>");
}
*/

void MainTableStart( string title, string id , boolean toggle) {
	writeln("<table width='95%' cellspacing='0' cellpadding='0'>");
	writeln("  <tr><td style='color: white;' align='center' bgcolor='blue'>");
	write  ("    <b>");
	if ( toggle )
		write("<a class='nounder' href='javascript:toggle_visibility(\"" + entity_encode(id) + "\");'>");
	write  ("<font color='white'>"+title+"</font>");
	if ( toggle )
		write("</a>");
	writeln("</b>");
	writeln("  </td></tr>");
	writeln("  <tr><td style='padding: 5px; border: 1px solid blue;'>");
	writeln("    <center>");
}
void MainTableStart( string title ) { MainTableStart(title, "" , false); }

void MainTableEnd() {
	writeln("    </center>");
	writeln("  </td></tr>");
	writeln("  <tr><td height='4'></td></tr>");
	writeln("</table>");
}

void SectionTableStart( string title, string id ) {
	MainTableStart(title, id , true) ;
	writeln("      <table>");
	writeln("        <tr><td>");
	writeln("          <div id='"+id+"' style='display: none'>");
	writeln("          <script type='text/javascript'>check_visibility('"+id+"')</script>");
	writeln("            <table width='100%'>");
}

void SectionTableEnd() {
	writeln("            </table>");
    writeln("          </div>");
    writeln("        </td></tr>");
	writeln("      </table>");
	MainTableEnd();
}

void main() {
	string title = "Familiar Feeder " + thisver;
	init_maps() ;
	
	//*****************************/
	// start the HTML form
	//*****************************/
	
	write_header();
	addJavaToggle();
	writeln("    <title>"+title+"</title>");
	writeln("    <link href='http://images.kingdomofloathing.com/styles.css' type='text/css' rel='stylesheet' />");
	// addCSS();
	finish_header();
	
	if (!debug ) check_version_relay("Familiar Feeder", "slimeling_feeder", thisver, 3919);
	
	writeln("");
	writeln("<center>");
	
	if ( debug ) writeln("<center><b>debugging<b></center><br>");
	
	
	//********************************************/
	// Process actions done in the last instance
	//********************************************/
	
	// Reset everything if reset button was used
	if ( test_button("reset") ) {
		if (debug) print("resetting");
		foreach i in fields
			remove fields[i] ;
	}
	
	// test if the 'Feed' button was used in the previous instance
	if( test_button("feed") ) {
		if ( debug ) print( "exec: "+build_exec() );
		else cli_execute( build_exec() );
		if ( !handle_gum(num_starters) ) {
			writeln("Something happened while obtaining starter items from chewing gums, please check the gCLI for more info...");
			abort("Something happened while obtaining starter items from chewing gums");
		}
		if ( !handle_beer( Ender_beer ) ) {
			writeln("Something happened while trying to buy beer from Bart Ender, please check the gCLI for more info...");
			abort("Something happened while obtaining beer from Bart Ender" );
		}
		fields["feedQuant"] = "1";
		init_maps() ;
	}
	
	//*****************************/
	// Top table
	//*****************************/
	
	MainTableStart(title);
	// MainTableStart("<a class='white' href='http://kolmafia.us/showthread.php?3919' target='_blank'>"+title+"</a>");
	writeln("      <table border=0>");
	writeln("        <tr><td width='60%' align='center'>");
	writeln("          <table border=0>");
	
	if ( familiars[fam] == "" )  // no 'Feed' or 'Equip' button if you don't have a feedable familiar.
	{
		writeln("            <tr><td align='center' >");
		writeln("              <font color='red'><b>You do not own a feedable familiar</b></font>");
		writeln("              <br>");
		writeln("              <font color='red'>Using your current familiar's weight.</font>");
		writeln("            </td></tr>");
	}
	else
	{
		writeln("            <tr><td align='center' width='33%'>");
		
		if ( ( familiars[slimeling] != "" ) && !( my_familiar() == slimeling ) )
		{
			write("              ");
			attr("class='button'");
			write_button("fam_equip_slime", "Take Slimeling out");
			writeln("");
		}
		
		writeln("            </td><td align='center' width='33%'>");
		
		if ( ( familiars[GGG] != "" ) && !( my_familiar() == GGG ) )
		{
			write  ("              ");
			attr("class='button'");
			write_button("fam_equip_ghost", "Take GGG out");
			writeln("");
		}
		
		writeln("            </td><td align='center' width='33%'>");
		
		if ( ( familiars[hobo] != "" ) && !( my_familiar() == hobo ) )
		{
			write  ("              ");
			attr("class='button'");
			write_button("fam_equip_hobo", "Take Hobo out");
			writeln("");
		}
		
		writeln("            </td></tr>");
	}
	
	writeln("          </table>");
	writeln("        </td></tr>");
	writeln("        <tr><td align='center' style='font-size:medium'>");
	write  ("          ");
	writeln("<br>With a " + currentWeight + " lb <b>" + fam + "</b> (" + pretty(mppercharge) + " MP per charge) and MP worth " + pretty(meatpermp) + " meat:");
	writeln("        </td></tr>");
	writeln("        <tr><td align=center style='font-size:small'>");
	writeln("          <font color='black'><b>Feed</b></font> - <font color='blue'><b>Feed (quantity to keep not shown)</b></font> - <font color='red'><b>Do not feed</b></font>");
	writeln("        </td></tr>");
	writeln("      </table>");
	
	MainTableEnd();
	
	writeln("<table width='95%' cellspacing='0' cellpadding='0' border='0'>");
	
	
	//*****************************/
	// table with feeding options
	//*****************************/
	
	writeln("<tr><td align='left' width='50%'>");
	
	MainTableStart("Feed Stuff");
	writeln("      <table>");
	writeln("        <tr><td colspan='2'>");
	writeln("          <center>");
	writeln("            With selected:<br>");
	writeln("              <div style='display: table'>");
	write  ("                ");
	write_radio("feedByQuant", "feedOpt", "Feed All Current", "feedAllCur");
	writeln("                <br>");
	write  ("                ");
	write_radio("Feed All Current But One", "feedAllCurButOne");
	writeln("                <br>");
	write  ("                ");
	write_radio("Feed All", "feedAll");
	writeln("                <br>");
	write  ("                ");
	write_radio("Feed Quantity:", "feedByQuant");
	write  ("                ");
	range(0,max_itm_quant);
	attr("size='4'");
	write_field(1, "feedQuant", "");
	writeln("");
	writeln("                <br>");
	writeln("              </div>");				
	writeln("          </center>");
	writeln("        </td></tr>");
	writeln("        <tr><td style='width:50%;'>");
	writeln("          <center>");
	
	// write 'Feed' button if a feedable familiar is equipped,
	if ( debug || my_familiar() == fam ) {
		attr("class='button'");
		write_button("feed", "Feed");
		writeln("");
	}
	
	writeln("          </center>");
	writeln("        </td><td style='width:50%;'>");
	writeln("          <center>");
	
	// Reset button
	write  ("            ");
	attr("class='button'");
	write_button("reset", "Reset");
	writeln("");
	writeln("          </center>");
	writeln("        </td></tr>");
	writeln("      </table>");
	MainTableEnd();
	
	
	//*****************************/
	// table with keeping options
	//*****************************/
	
	writeln("  </td><td align='right' width='50%'>");
	
	MainTableStart("Keep Stuff");
	writeln("      <table>");
	writeln("        <tr><td colspan='2'>");
	writeln("          <center>");
	writeln("            With selected:<br><br>");
	writeln("              <div style='display: table'>");
	write  ("                ");
	write_radio("keepOne", "keepOpt", "Keep All", "keepAll");
	writeln("                <br>");
	write  ("                ");
	write_radio("Keep One", "keepOne");
	writeln("                <br>");
	write  ("                ");
	write_radio("Keep Quantity:", "keepByQuant");
	write  ("                ");
	range(0,max_itm_quant);
	attr("size='4'");
	write_field(0, "keepQuant", "");
	writeln("");
	writeln("                <br>");
	writeln("              </div>");				
	writeln("          </center>");
	writeln("        </td></tr>");
	writeln("        <tr><td style='width:50%;'>");
	writeln("          <center>");
	
	// write 'Keep' button
	attr("class='button'");
	write_button("keep", "Keep");
	writeln("");
	
	writeln("          </center>");
	writeln("        </td><td style='width:50%;'>");
	writeln("          <center>");
	
	// Reset button
	write  ("            ");
	attr("class='button'");
	write_button("reset", "Reset");
	writeln("");
	writeln("          </center>");
	writeln("        </td></tr>");
	writeln("      </table>");
	MainTableEnd();
	
	writeln("  </td></tr>");
	writeln("</table>");
	
	
	//*****************************/
	// table with feedable items
	//*****************************/
	
	SectionTableStart("Feedable Items", "feed");
	
	string color ;
	string createcolor ;
	boolean f ;
	boolean c ;
	int num = 0 ;
	foreach i in feedable {
		if ( feedable[i].meat_stack ) continue ;
		if ( inventory[feedable[i].it] + feedable[i].creat.q < 1 ) continue ;
		
		f = ( inventory[feedable[i].it] > 0 ) ;
		c = ( feedable[i].creat.q > 0 ) ;
		
		if ( feedable[i].feed_meatpermp < meatpermp ) {
			if ( keep[feedable[i].it] > 0 ) color = "<font color='blue'>" ;
			else color = "<font color='black'>" ;
		}
		else color = "<font color='red'>" ;
		
		if ( c && feedable[i].creat.feed_meatpermp < meatpermp )
		{
			createcolor = "<font color='black'>" ;
		}
		else createcolor = "<font color='red'>" ;
		
		num = num + 1 ;
		if ( num%2 == 1 )
			writeln("              <tr>");
		writeln("                <td valign='top'>");
		write  ("                ");
		attr("id='it"+feedable[i].it.to_int()+"'");
		write_check( false, "it"+feedable[i].it.to_int(), "" );
		writeln("");
		writeln("                </td><td  valign='top'>");
		writeln("                  <label for='it"+feedable[i].it.to_int()+"'>");
		writeln("                    <b>"+color+feedable[i].it+"</font> ");
		writeln("                  </label>");
		//writeln("                  <br>");
		//write  ("                    ");
		write  ("("+ (feedable[i].creat.q+inventory[feedable[i].it]) + " possible, ");
		writeln(inventory[feedable[i].it] + " current)</b>");
		
		
		writeln("                  <br>");
		writeln("                  <table border=0 style='font-size:x-small'>");
		
		if ( f ) {
			writeln("                      <tr><td>");
			writeln("                        "+get_advice(feedable[i].it)+":");
			writeln("                      </td><td>");
			writeln("                        "+pretty(itm_value(feedable[i].it))+" meat");
			writeln("                      </td></tr>");
			writeln("                      <tr><td>");
			writeln("                        Feed:");
			writeln("                      </td><td>");
			writeln("                        "+pretty(feedable[i].feed_mp) + "MP");
			writeln("                      </td><td>");
			writeln("                        ("+ pretty(feedable[i].feed_meatpermp) + " meat/mp)");
			writeln("                      </td></tr>");
		}
		if ( c ) {
			writeln("                      <tr><td>");
			writeln("                        Create:");
			writeln("                      </td><td>");
			writeln("                        "+feedable[i].creat.cost+" meat");
			writeln("                      </td></tr>");
			writeln("                      <tr><td>");
			writeln("                        Feed:");
			writeln("                      </td><td>");
			writeln("                        "+pretty(feedable[i].creat.feed_mp) + "MP");
			writeln("                      </td><td>");
			writeln("                        "+createcolor+"("+ pretty(feedable[i].creat.feed_meatpermp) + " meat/mp)</font>");
			writeln("                      </td></tr>");
		}
		writeln("                  </table>");
		writeln("                </td>");
		if ( num%2 == 0 )
			writeln("              </tr>");
	}
	
	SectionTableEnd();
	
	//****************************************/
	// table with meat stack items
	//****************************************/
	
	
	if ( fam == slimeling ) {
		SectionTableStart("Meat Stack Items", "meatcreate");

		color = "<font color='black'>" ;
		num = 0 ;
		foreach i in feedable {
			if ( !feedable[i].meat_stack )
				continue ;
			
			num = num + 1 ;
			if ( num%2 == 1 )
				writeln("              <tr>");
			writeln("                <td valign='top'>");
			write  ("                ");
			attr("id='it"+feedable[i].it.to_int()+"'");
			write_check( false, "it"+feedable[i].it.to_int(), "" );
			writeln("");
			writeln("                </td><td>");
			write  ("                  ");
			writeln("<label for='it"+feedable[i].it.to_int()+"'><b>"+color+feedable[i].it+"</font> ("+(feedable[i].creat.q+inventory[feedable[i].it])+" possible, " + inventory[feedable[i].it] + " current)</b>" );
			writeln("                  <br>");
			writeln("                  <table border=0 style='font-size:x-small'>");
			writeln("                      <tr><td>");
			writeln("                        Cost:");
			writeln("                      </td><td>");
			writeln("                        "+feedable[i].creat.cost+" meat");
			writeln("                      </td></tr>");
			writeln("                  </table>");
			writeln("                </td>");
			if ( num%2 == 0 )
				writeln("              </tr>");
		}
		
		SectionTableEnd();
	}
	
	
	//****************************************/
	// table with items to keep
	//****************************************/
	
	SectionTableStart("Items to Keep", "keep");
	
	color = "<font color='black'>" ;
	num = 0 ;
	foreach itm in keep {
		if ( keep[itm] == 0 )
			continue ;
		
		num = num + 1 ;
		if ( num%2 == 1 )
			writeln("              <tr>");
		writeln("                <td valign='top'>");
		write  ("                ");
		attr("id='itKeep"+itm.to_int()+"'");
		write_check( false, "itKeep"+itm.to_int(), "" );
		writeln("");
		writeln("                </td><td>");
		write  ("                  ");
		writeln("<label for='itKeep"+itm.to_int()+"'><b>"+color+itm+"</font></b>" );
		writeln("                  <br>");
		writeln("                  <table border=0 style='font-size:small'>");
		writeln("                      <tr><td>");
		writeln("                        Keep: ");
		writeln("                      </td><td>");
		if ( keep[itm] > 0 )
			writeln("                        "+keep[itm]);
		else
			writeln("                        All");	
		writeln("                      </td></tr>");
		writeln("                  </table>");
		writeln("                </td>");
		if ( num%2 == 0 )
			writeln("              </tr>");
	}
	
	SectionTableEnd();
	
	writeln("</center>");
	finish_page();
}