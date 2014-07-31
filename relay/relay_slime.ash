## Slime Speed Run Script by Alhifar/zeroblah
## Modifications added in from Bale, Veracity and Thok
## Many thanks to everyone who has contributed and tested!

## Currently supported skills for damage calculations:
## Attack with weapon, Thrust-Smack, Lunging Thrust-Smack, Sauceror spells, Weapon of the Pastalord, Shieldbutt,
## Fearful Fetuccini, Moxious Maneuver and divines, both single and funkslung
## Any requests for other skills to be added in should be sent to Alhifar.
script "slime.ash";
notify "Alhifar";
import <htmlform.ash>
import <zlib.ash>

## Set run type to either "larva" or "nodule" to automatically set certain settings to the most usual values for those types of runs.
setvar("SlimeTube_run_type", "");

setvar("SlimeTube_max_ml_outfit", "maxml");
setvar("SlimeTube_max_ml_familiar", "purse rat");

setvar("SlimeTube_min_ml_outfit", "minml");
setvar("SlimeTube_min_ml_familiar", "levitating potato");

string run_type = vars["SlimeTube_run_type"];

string max_ml_outfit = vars["SlimeTube_max_ml_outfit"];
string max_ml_familiar = vars["SlimeTube_max_ml_familiar"];

string min_ml_outfit = vars["SlimeTube_min_ml_outfit"];
string min_ml_familiar = vars["SlimeTube_min_ml_familiar"];

## Set use_tatter_like to true to use a tatter to escape from combat, or to false to simply kill the slime and use an adventure.
## Set which_tatter to which tatter-like item to use to escape from combats
setvar("SlimeTube_use_tatter_like", "false");
boolean use_tatter_like = vars["SlimeTube_use_tatter_like"].to_boolean();
setvar("SlimeTube_which_tatter", "green smoke bomb");

item which_tatter = vars["SlimeTube_which_tatter"].to_item();

## This CCS is ONLY used if use_tatter_like is set to false, and it is not blank
setvar("SlimeTube_max_ml_ccs", "");
setvar("SlimeTube_min_ml_ccs", "");

string max_ml_ccs = vars["SlimeTube_max_ml_ccs"];
string min_ml_ccs = vars["SlimeTube_min_ml_ccs"];

## Set this to the amount of rounds you want to add to the number of rounds expected to account for fumbles
setvar("SlimeTube_fumble_buffer", "0");
int fumble_buffer = vars["SlimeTube_fumble_buffer"].to_int();

setvar("SlimeTube_use_hottub", "true");
boolean use_hottub = vars["SlimeTube_use_hottub"].to_boolean();

setvar("SlimeTube_verbose", "true");
boolean verbose = vars["SlimeTube_verbose"].to_boolean();

## Switch between spleen familiars until all spleen items you can get are obtained,
## then switch to the familiars in the above settings
setvar( "SlimeTube_get_spleeners" , "false" );
boolean get_spleeners = vars["SlimeTube_get_spleeners"].to_boolean();

## End Options 


## Do not modify anything below this line unless you know what you are doing!
###################################################

switch( run_type )
{
	case "larva":
		max_ml_familiar = "purse rat";
		get_spleeners = false;
		break;
	case "nodule":
		use_tatter_like = false;
		get_spleeners = true;
		break;
}
		
boolean write_rcheck(boolean ov, string name, string label) {
	if(label != "" )
		write("<label>");
	if(fields contains name) {
		ov = true;
	} else if (count(fields) > 0)
		ov = false;
	write("<input type=\"checkbox\" name=\"" + name + "\"");
	if(ov)
		write(" checked");
	_writeattr();	
	if(label != "" ) {
		write(" "+label);
		writeln("</label>");
	}
	return ov;
}

float[11] slime_percent;
slime_percent[0] = 0;
slime_percent[1] = 5.33335;
slime_percent[2] = 4.00147;
slime_percent[3] = 2.90220;
slime_percent[4] = 2.01643;
slime_percent[5] = 1.32440;
slime_percent[6] =  .80555;
slime_percent[7] =  .43835;
slime_percent[8] =  .20004;
slime_percent[9] =  .06621;
slime_percent[10] = .01000;

if( get_property( "badkitty" ) != "" ) max_ml_familiar = get_property( "badkitty" );
if( get_property( "goodkitty" ) != "" ) min_ml_familiar = get_property( "goodkitty" );
set_property("choiceAdventure326","0"); 

int get_bladders()
{
	string log = visit_url( "clan_raidlogs.php" );
	int bladders;
	matcher m_bladders = create_matcher( "squeezed a Slime gall bladder" , log );
	while( m_bladders.find() ) bladders = bladders + 1;
	return bladders;
}
int expected_rounds_needed()
{
	int slime_hp = monster_hp( $monster[slime1] );
	int weapon_damage = max( 1 , floor( .1 * get_power( equipped_item( $slot[weapon] ) ).to_float() ) );
	int offhand_damage = 0;
	if( weapon_type( equipped_item( $slot[off-hand] ) ) != $stat[none] )
		offhand_damage = max( 1 , floor( .1 * get_power( equipped_item( $slot[off-hand] ) ).to_float() ) );
	int elem_damage = 0;
	foreach elem in $elements[] 
	{
		elem_damage += numeric_modifier( elem + " Damage" );
	}
	int bonus_damage = numeric_modifier( "Weapon Damage" ) + elem_damage;
	int lts_factor = 1;
	int damage;
	
	float spell_per;
	
	boolean funk = false;
	
	boolean shieldbutt = false;
	
	boolean noisemaker = false;
	boolean blowout = false;
	boolean sillystring = false;
	
	boolean shurikens = false;
	boolean cannon = false;
	boolean mortar = false;
	boolean stringozzi = false;
	boolean wotpl = false;
	boolean ff = false;
	
	boolean stream = false;
	boolean storm = false;
	boolean wave = false;
	boolean saucegeyser = false;
	
	boolean mm = false;
	boolean vts = false;
	
	int stun = 0;
	
	for i from 0 upto 30
	{
		switch ( get_ccs_action( i ) )
		{
			case "skill entangling noodles":
			case "item brick of sand":
			case "item banana peel":
			case "item jar of swamp gas":
			case "item floorboard cruft":
			case "item sausage bomb":
			case "item clingfilm tangle":
			case "item black bricko brick":
			case "item finger cuffs":
			case "item d6":
			case "item rain-doh blue balls":
				stun += 2;
				break;
			case "skill noodles of fire":
			case "item soggy used band-aid":
			case "item the lost comb":
			case "item chinese curse words":
				stun += 3;
				break;
			case "item very large caltrop":
				stun += 5;
				break;
			case "skill lunging thrust-smack":
				lts_factor = 3;
				break;
			case "skill thrust-smack":
				lts_factor = 2;
				break;
			case "skill shieldbutt":
				shieldbutt = true;
				break;
			case "item divine noisemaker, divine noisemaker":
				funk = true;
			case "item divine noisemaker":
				noisemaker = true;
				break;
			case "item divine blowout, divine blowout":
				funk = true;
			case "item divine blowout":
				blowout = true;
				break;
			case "item divine can of silly string, divine can of silly string":
				funk = true;
			case "item divine can of silly string":
				sillystring = true;
				break;
			case "skill ravioli shurikens":
				shurikens = true;
				break;
			case "skill cannelloni cannon":
				cannon = true;
				break;
			case "skill stuffed mortar shell":
				mortar = true;
				break;
			case "skill stringozzi serpent":
				stringozzi = true;
				break;
			case "skill stream of sauce":
				stream = true;
				break;
			case "skill saucestorm":
				storm = true;
				break;
			case "skill saucegeyser":
				saucegeyser = true;
				break;
			case "skill wave of sauce":
				wave = true;
				break;
			case "skill weapon of the pastalord":
				wotpl = true;
				break;
			case "skill fearful fettucini":
				ff = true;
				break;
			case "skill vicious talon slash":
				vts = true;
				break;
		}
	}

	int musc_dam = max( 0 , my_buffedstat( $stat[muscle] ) - monster_defense( $monster[slime1] ) );
	if( current_hit_stat() == $stat[Moxie] ) musc_dam = max( 0 , my_buffedstat( $stat[moxie] ) - monster_defense( $monster[slime1] ) );
	if( lts_factor == 3 )
	{
		if( my_class() == $class[Seal Clubber] )
			musc_dam = max( 0 , ( my_buffedstat( $stat[muscle] ) * 1.3 ) - monster_defense( $monster[slime1] ) );
		else musc_dam = max( 0 , ( my_buffedstat( $stat[muscle] ) * 1.25 ) - monster_defense( $monster[slime1] ) );
	}
	
	if( weapon_type( equipped_item( $slot[weapon] ) ) == $stat[none] ) musc_dam = musc_dam * .25;
	if( shieldbutt ) offhand_damage = get_power( equipped_item( $slot[off-hand] ) ) * .1;
	spell_per = ( 100 + numeric_modifier( "Spell Damage Percent" ) ) / 100;
	// Old elem spell damage calc was misinformed. Needs redone
	float elem_spell_damage = 0;
	/*
	[5:13:10 PM] Cannonfire40: Stringozzi is now 16-32+.25*myst, with poison = initial damage
	[5:13:20 PM] Cannonfire40: Before it was 16-40+.25*myst, with poison = initial damage/2
	[5:13:34 PM] Cannonfire40: Cannon now has double base damage and scales to .25*myst instead of .15*myst
	[5:13:51 PM] Cannonfire40: WotP has identical base damage and scales to .5*myst instead of .35
	[5:14:03 PM] Cannonfire40: And saucegeyser is now 60-70 + .4*myst
	*/
	
	/*
	[8:18:53 PM] Cannonfire40: Mortar isn't *bad*
	[8:18:56 PM] Cannonfire40: but it's bad for slime tube
	[8:19:03 PM] Cannonfire40: it deals the same damage as WotP now
	[8:19:05 PM] Cannonfire40: BUT
	[8:19:11 PM] Cannonfire40: it fires the round AFTER you cast it.
	[8:19:18 PM] Cannonfire40: and it's once per combat
	*/
	switch
	{
		case noisemaker:
			damage = my_buffedstat( $stat[muscle] ) * ( 1 + funk.to_int() );
			break;
		case blowout:
			damage = my_buffedstat( $stat[moxie] ) * ( 1 + funk.to_int() );
			break;
		case sillystring:
			damage = my_buffedstat( $stat[mysticality] ) * ( 1 + funk.to_int() );
			break;
		// Shurikens needs spaded
		case shurikens:
			damage = floor( spell_per * ( 3 + max( .07 * my_buffedstat( $stat[mysticality] ) , 15 ) + min( numeric_modifier( "Spell Damage" ) , 25 ) + elem_spell_damage ) );
			break;
		case cannon:
			damage = floor( spell_per * ( 16 + max( .25 * my_buffedstat( $stat[mysticality] ) , 20 ) + min( numeric_modifier( "Spell Damage" ) , 40 ) + elem_spell_damage ) );
			break;
		case stringozzi:
			damage = floor( spell_per * ( 16 + max( .25 * my_buffedstat( $stat[mysticality] ) , 20 ) + min( numeric_modifier( "Spell Damage" ) , 40 ) + elem_spell_damage ) ) * 2;
		// Stream needs spaded
		case stream:
			damage = floor( spell_per * ( 3 + max( .1 * my_buffedstat( $stat[mysticality] ) , 10 ) + min( numeric_modifier( "Spell Damage" ) , 10 ) ) );
			break;
		// Storm needs spaded
		case storm:
			damage = floor( spell_per * ( 14 + max( .2 * my_buffedstat( $stat[mysticality] ) , 25 ) + min( numeric_modifier( "Spell Damage" ) , 15 ) ) );
			break;
		// Wave needs spaded
		case wave:
			damage = floor( spell_per * ( 20 + max( .3 * my_buffedstat( $stat[mysticality] ) , 30 ) + min( numeric_modifier( "Spell Damage" ) , 25 ) ) );
			break;
		case saucegeyser:
			damage = floor( spell_per * ( 60 + ( .4 * my_buffedstat( $stat[mysticality] ) ) + numeric_modifier( "Spell Damage" ) ) );
			break;
		case wotpl:
		case ff:
			damage = floor( spell_per * ( 32 + ( .5 * my_buffedstat( $stat[mysticality] ) ) + numeric_modifier( "Spell Damage" ) ) );
			break;
		case vts:
			damage = floor( .75 * my_buffedstat( $stat[muscle] ) );
			break;
		default:
			damage = musc_dam + bonus_damage + ( weapon_damage * lts_factor ) + offhand_damage;
	}
	int rounds = ceil( slime_hp.to_float() / damage.to_float() );
	return max( 1 , rounds + stun );
}

int max_possible_damage()
{
	int def_stat = my_buffedstat( $stat[moxie] );
	if( have_skill( $skill[Hero of the Half-Shell] ) && item_type( equipped_item( $slot[off-hand] ) ) == "shield" && my_buffedstat( $stat[muscle] ) > my_buffedstat( $stat[moxie] ) )
		def_stat = my_buffedstat( $stat[muscle] );
	int slime_attack = 100 + ( numeric_modifier( "Monster Level" ) * ( my_familiar() != $familiar[O.A.F.] ).to_int() );
	int diff = max( 0 , slime_attack - def_stat );
	float absorb_frac = min( .9 , ( square_root( numeric_modifier( "Damage Absorption" ) / 10.0 ) - 1.0 ) / 10.0 );
	
	int damage = ceil( diff + ( .25 * slime_attack ) - numeric_modifier( "Damage Reduction" ) );
	damage = ceil( damage * ( 1 - absorb_frac ) );
	
	int lowest_elem = min( min( min( min( elemental_resistance( $element[hot] ), elemental_resistance( $element[cold] ) ) , elemental_resistance( $element[stench] ) ) , elemental_resistance( $element[sleaze] ) ) , elemental_resistance( $element[slime] ) );
	float elem_resist = ( 100 - lowest_elem  ).to_float() / 100.0;
	damage = ceil( damage * elem_resist );
	return max( 1 , damage );
}

int slime_damage( int turns )
{
	int noodle_turns = 0;
	for i from 0 upto 30
	{
		if( get_ccs_action( i ) == "skill entangling noodles" ) noodle_turns = 2;
	}
	if( noodle_turns > 0 && my_familiar() == $familiar[Frumious Bandersnatch] ) noodle_turns = noodle_turns + 1;
	int damage = my_maxhp() * slime_percent[min( 10 , turns )];
	return ceil( damage * ( ( 100 - elemental_resistance( $element[slime] ) ) / 100 ) ) + ( ( expected_rounds_needed() + fumble_buffer - noodle_turns ) * max_possible_damage() );
}

int slime_damage()
{
	return slime_damage( min( have_effect( $effect[Coated in Slime] ) , 10 ) );
}

boolean chamois()
{
	
	visit_url( "clan_slimetube.php?action=chamois" );
	if ( have_effect( $effect[Coated in Slime] ) > 0 )
	{
		## Tub code stolen... err... "borrowed" from matt.chugg
		if( verbose ) print( "Chamois failed!" , "red" );
		if( use_hottub && get_property( "_hotTubSoaks" ).to_int() < 5 )
		{
			if( verbose ) print ( "Using VIP bath..." );
			cli_execute( "soak 1" );
			if ( have_effect( $effect[Coated in Slime] ) > 0 )
			{
				return false;
			}
			return true;
		}
		return false;
	}
	if( verbose ) print( "Chamois successfully used." );
	return true;
}

int max_mcd()
{
	int max_mcd = 10 + ( canadia_available().to_int() );
	int mcd = 1000 - numeric_modifier( "Monster Level" ) + current_mcd();
	if( run_type == "larva" || mcd < 0 || mcd > max_mcd ) return max_mcd;
	return mcd;
}

void run_tube( int adv_to_use )
{
	if( get_property( "customCombatScript" ) != min_ml_ccs )
	{
		for i from 0 upto 30
		{
			if( get_ccs_action( i ) == "try to run away" || get_ccs_action( i ).contains_text( which_tatter.to_string() ) ) abort( "Reset your battle action to something sane!" );
		}
	}
	boolean ml_outfit_on;
	string old_action;
	string page_text;
	boolean combat;
	if( adv_to_use < 1 ) adv_to_use = my_adventures();
	else if( adv_to_use > my_adventures() ) adv_to_use = my_adventures();
	int total_adv = adv_to_use;
	int bladders = get_bladders();
	cli_execute( "autoattack disabled" );
	
	while( my_adventures() > 0 && adv_to_use > 0 )
	{
		if( slime_damage() >= my_maxhp() )
		{
			if( verbose ) print( "The slimes in the tube or that slime covering you will kill you if you don't do something! Hitting up your clan." , "blue" );
			if( !chamois() ) abort( "Slime removal failed! You won't survive another turn!" );
			if( !restore_hp( slime_damage() + 1 ) ) abort( "Unable to restore HP!" );
			if( slime_damage() >= my_maxhp() ) abort( "You can't survive after removing the coating of slime, you need more HP!" );
		}
		else if( slime_damage() >= my_hp() )
		{
			if( !restore_hp( slime_damage() + 1 ) ) abort( "Couldn't restore enough HP!" );
		}
		else if( have_effect( $effect[Coated in Slime] ) == 0 )
		{
			if( verbose ) print( "I'm feeling rather... dry. Let's go get slimy!" , "blue" );
			
			outfit( min_ml_outfit );
			// Spleener getting code "borrowed" from bleary
			if( get_spleeners )
			{
				for i from 1 upto 5
				{
					if( get_property( "_tokenDrops" ).to_int() < i && have_familiar($familiar[Rogue Program] ) )
					{
						use_familiar( $familiar[Rogue Program] );
						break;
					}
					else if (get_property( "_absintheDrops" ).to_int() < i && have_familiar($familiar[Green Pixie] ) )
					{
						use_familiar( $familiar[Green Pixie] );
						break;
					}
					else if( get_property( "_aguaDrops" ).to_int() < i && have_familiar( $familiar[Baby Sandworm] ) )
					{
						use_familiar( $familiar[Baby Sandworm] );
						break;
					}
					else if( get_property( "_gongDrops" ).to_int() < i && have_familiar( $familiar[Llama Lama] ) )
					{
						use_familiar( $familiar[Llama Lama] );
						break;
					}
				}
			}
			else use_familiar( min_ml_familiar.to_familiar() );
			if( !use_tatter_like && min_ml_ccs != "" )
			{
				set_property( "customCombatScript" , min_ml_ccs );
				set_property( "battleAction" , "custom combat script" );
			}
			ml_outfit_on = false;
			int extra_ml = ( bladders * 20 + numeric_modifier( "Monster Level" ) ) % 100;
			if( extra_ml < 0 ) extra_ml += 100;
			switch
			{
			case my_familiar() == $familiar[O.A.F.]:
				break;
			case extra_ml <= current_mcd() && !in_bad_moon():
				change_mcd( 0 );
				break;
			case extra_ml <= numeric_modifier( "ur-kel's aria of annoyance" , "Monster Level" ) && have_skill( $skill[Ur-Kel\'s Aria of Annoyance] ):
				cli_execute( "uneffect Ur-kels" );
				break;
			case !in_bad_moon() && extra_ml <= current_mcd() + numeric_modifier( "ur-kel's aria of annoyance" , "Monster Level" ) && have_skill( $skill[Ur-Kel's Aria of Annoyance] ):
				cli_execute( "uneffect Ur-kels" );
				change_mcd( 0 );
			}
			old_action = get_property( "battleAction" );
			boolean gazing = false;
			if( my_familiar() == $familiar[Frumious Bandersnatch] && get_property( "_banderRunaways" ).to_int() < floor( numeric_modifier( "Familiar Weight" ) + familiar_weight( $familiar[Frumious Bandersnatch] ) ) / 5 )
			{
				## TODO: Fix breakage when you don't have Aria available, have ode available,
				## and have 3 AT buffs already. Temp fixed by changing abort to print, possibly needs handled better
				if( have_effect( $effect[Ur-Kel's Aria of Annoyance] ) > 0 && have_skill($skill[Ur-Kel's Aria of Annoyance] ) ) cli_execute("uneffect Ur-kels");
				if( have_effect( $effect[Ode to Booze]) < 1 && have_skill( $skill[The Ode to Booze] ) )
				{
					use_skill( 1 , $skill[The Ode to Booze]);
				}
				if( have_effect( $effect[Ode to Booze] ) > 0 )
				{
					set_property( "battleAction" , "try to run away" );
				}
				else print( "Problem casting \"Ode to Booze\" to help your Bandersnatch run away. Probably too many AT Buffs." , "red" );
				
			}
			else if( my_familiar() == $familiar[Pair of stomping boots] && get_property( "_banderRunaways" ).to_int() < floor( numeric_modifier( "Familiar Weight" ) + familiar_weight( $familiar[Pair of stomping boots] ) ) / 5 )
			{
				set_property( "battleAction" , "try to run away" );				
			}
			else if( ( equipped_amount( $item[Navel Ring of Navel Gazing] ) > 0 || equipped_amount( $item[Greatest American Pants] ) > 0 ) && get_property( "_navelRunaways" ).to_int() < 3 )
			{
				gazing = true;
				set_property( "battleAction" , "try to run away" );
			}
			else if( use_tatter_like )
			{
				if( item_amount( which_tatter ) == 0 ) abort( "Out of " + which_tatter.to_plural() + "!" );
				if( have_skill( $skill[Ambidextrous Funkslinging] ) )
				{
					set_property( "battleAction" , "item " + which_tatter.to_string() + ", " + which_tatter.to_string() );
				}
				else set_property( "battleAction" , "item " + which_tatter.to_string() );
			}
			
			int ml = numeric_modifier( "Monster Level" );
			int coated_turns = max( 1 , floor( ( 1000 - ml ) / 100 ) + 1 );
			if( slime_damage( coated_turns ) >= my_maxhp() ) abort( "Your low ML outfit doesn't bring your ML low enough to survive the first turn of Coated in Slime!" );
			if( slime_damage( coated_turns ) >= my_hp() )
			{
				if( !restore_hp( slime_damage() + 1 ) ) abort( "Can't restore enough HP!" );
			}
			if( verbose ) print( "Adventure " + ( total_adv - adv_to_use + 1 ) + " out of " + total_adv , "blue" ); 

			adv1($location[The Slime Tube], -1, "");
			if( get_property( "lastEncounter" ).contains_text( "Showdown" ) ) abort( "You've reached Mother Slime!" );
			boolean combat = !( get_property("lastEncounter").contains_text("Engulfed") || get_property("lastEncounter").contains_text("Showdown") ) ;   
			if( !use_tatter_like )
			{
				if( combat ) adv_to_use = adv_to_use - 1;
			}
			if( verbose && use_tatter_like ) print( item_amount( which_tatter ) + " " + to_plural( which_tatter ) + " left!" );
			if( use_tatter_like || my_familiar() == $familiar[Frumious Bandersnatch] || gazing )
			{
				set_property( "battleAction" , old_action );
			}
			if( ( have_effect( $effect[Ode to Booze] ) > 0 && have_skill( $skill[The Ode to Booze] ) ) || ( get_property( "_banderRunaways" ).to_int() >= floor( numeric_modifier( "Familiar Weight" ) + familiar_weight( $familiar[Frumious Bandersnatch] ) ) / 5 ) )
			{
				cli_execute( "uneffect Ode to Booze" );
			}
		}
		else
		{
			if( verbose ) print( "Covered in slime, adventuring normally in the tube!" , "blue" );
			if( verbose ) print( "Adventure " + ( total_adv - adv_to_use + 1 ) + " out of " + total_adv , "blue" ); 
			if( !ml_outfit_on )
			{
				outfit( max_ml_outfit );
				use_familiar( max_ml_familiar.to_familiar() );
				if( !use_tatter_like && max_ml_ccs != "" )
				{
					set_property( "customCombatScript" , max_ml_ccs );
					set_property( "battleAction" , "custom combat script" );
				}
				ml_outfit_on = true;
				if( !in_bad_moon() ) change_mcd( max_mcd() );
			}
			if( have_skill( $skill[Ur-Kel's Aria of Annoyance] ) && have_effect( $effect[Ur-Kel's Aria of Annoyance] ) == 0 )
			{
				use_skill( 1 , $skill[Ur-Kel's Aria of Annoyance] );
			}
			adventure( 1 , $location[The Slime Tube] );
			if( get_property( "lastEncounter" ).contains_text( "Showdown" ) ) abort( "You've reached Mother Slime!" );
			adv_to_use = adv_to_use - 1;
		}
	}
}

string familiar_select(string ov, string name, string label) {
	ov = write_select(ov, name, label);
	write_option("(no familiar)","");
	foreach fam in $familiars[]
		if(have_familiar(fam)) write_option(fam.to_string());
	finish_select();
	return ov;
}

void main() {
	write_page();
	writeln( "<center><b><font size=5 color=\"blue\">Slime.ash Relay Version</font></b></center><br>" );
	writeln( "<center><font size=4><b>Clan:</b> " + get_clan_name() + "</font></center><br>" );
	writeln("<center><table border=0 cellpadding=2>");
	writeln("<tr><th></th><th align=left>Minimum ML Settings</th><th align=left>Maximal ML Settings</th></tr>");
	write("<tr><th align=right>Outfit name:</th><td>");
	vars["SlimeTube_min_ml_outfit"] = write_field(vars["SlimeTube_min_ml_outfit"], "min_ml_outfit", "");
	write("</td><td>");
	vars["SlimeTube_max_ml_outfit"] = write_field(vars["SlimeTube_max_ml_outfit"], "max_ml_outfit", "");
	write("</td></tr>");
	
	write("<tr><th align=right>Familiar:</th><td>");
	vars["SlimeTube_min_ml_familiar"] = familiar_select(vars["SlimeTube_min_ml_familiar"], "min_ml_familiar", "");
	write("</td><td>");
	vars["SlimeTube_max_ml_familiar"] = familiar_select(vars["SlimeTube_max_ml_familiar"], "max_ml_familiar", "");
	write("</td></tr>");
	
## This CCS is ONLY used if use_tatter_like is set to false, and it is not blank
	write("<tr><th align=right>CCS:</th><td>");
	vars["SlimeTube_min_ml_ccs"] = write_field(vars["SlimeTube_min_ml_ccs"], "min_ml_ccs", "");
	write("</td><td>");
	vars["SlimeTube_max_ml_ccs"] = write_field(vars["SlimeTube_max_ml_ccs"], "max_ml_ccs", "");
	write("</td></tr>");
	writeln("</table></center>");

		 
## Set use_tatter_like to true to use a tatter to escape from combat, or to false to simply kill the slime and use an adventure.
## Set which_tatter to which tatter-like item to use to escape from combats
	writeln("<p style=\"margin-right:50px; margin-left:50px;\">If tatter-likes are not used and no CCS is listed in the box above, then Slimes will be killed according to basic combat settings.</p>");
	write("<p style=\"margin-right:50px; margin-left:50px;\">");
	use_tatter_like = write_rcheck(use_tatter_like, "use_tatter_like", "Use tatter-like item to escape combat");
	vars["SlimeTube_use_tatter_like"] = use_tatter_like.to_string(); 
	write("<br \>");
	vars["SlimeTube_which_tatter"] = write_select(vars["SlimeTube_which_tatter"], "which_tatter", "If tatter-like is chosen, use: ");
	foreach tatter in $strings[divine champagne popper, Fish-oil smoke bomb, green smoke bomb, tattered scrap of paper, wumpus-hair bolo]
		write_option(tatter);
	finish_select();
	writeln("</p>");
	
## Set this to the amount of rounds you want to add to the number of rounds expected to account for fumbles
	write("<p>");
	vars["SlimeTube_fumble_buffer"] = write_field(vars["SlimeTube_fumble_buffer"].to_int(), "fumble_buffer", "How many rounds allowed to fumble: ").to_string();
	write("<br \>");
	int adv_to_use = write_field(my_adventures(), "adv_to_use", "Maximum rounds in the tube: ");
	write("<br \>");
	vars["SlimeTube_use_hottub"] = write_rcheck(vars["SlimeTube_use_hottub"].to_boolean(), "use_hottub", "Use Hot Tub ");
	write("<br \>");
	verbose = write_rcheck(verbose, "verbose", "Verbose ");
	vars["SlimeTube_verbose"] = verbose.to_string();
	write( "<br \>" );
	vars["SlimeTube_get_spleeners"] = write_rcheck( vars["SlimeTube_get_spleeners"].to_boolean() , "get_spleeners" , "Get spleen items before changing to default familiar " );
	write("</p>");
	
## Run Slime Tube!
	writeln("<center><table border=0 cellpadding=2 width=\"100%\">");
	write("<tr><td>");
	if(write_button("slime", "Run Slime Tube NOW")) {
		updatevars();
		run_tube(adv_to_use);
	}
	write("</td><td align=right>");
	if(write_button("upd", "Save Settings without running tube"))
		updatevars();
	writeln("</td></tr></table></center>");
	
	finish_page();
}