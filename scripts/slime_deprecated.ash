## Slime Speed Run Script by Alhifar/zeroblah
## Modifications added in from Bale, Veracity and Thok
## Many thanks to everyone who has contributed and tested!

## Currently supported skills for damage calculations:
## Attack with weapon, Thrust-Smack, Lunging Thrust-Smack, Sauceror spells, Weapon of the Pastalord, Shieldbutt,
## Fearful Fetuccini, Moxious Maneuver and divines, both single and funkslung
## Any requests for other skills to be added in should be sent to Alhifar.
script "slime.ash";

string version = "STABLE";

## Set run type to either "larva" or "nodule" to automatically set certain settings to the most usual values for those types of runs.
string run_type = "nodule";

string max_ml_outfit = "ml-slime";
string max_ml_familiar = "purse rat";

string min_ml_outfit = "minml";
string min_ml_familiar = "levitating potato";

## Set use_tatter_like to true to use a tatter to escape from combat, or to false to simply kill the slime and use an adventure.
## Set which_tatter to which tatter-like item to use to escape from combats
boolean use_tatter_like = false;
item which_tatter = $item[divine champagne popper];

## This CCS is ONLY used if use_tatter_like is set to false, and it is not blank
string max_ml_ccs = "";
string min_ml_ccs = "";

## Set this to the amount of rounds you want to add to the number of rounds expected to account for fumbles
int fumble_buffer = 0;

boolean use_hottub = true;
boolean verbose = true;



		

## Do not modify anything below this line unless you know what you are doing!
###################################################

float[11] slime_percent;
slime_percent[0] = 0;
slime_percent[1] = 5.334167;
slime_percent[2] = 4.001677;
slime_percent[3] = 2.9025;
slime_percent[4] = 2.016667;
slime_percent[5] = 1.325;
slime_percent[6] = .805833;
slime_percent[7] = .4391667;
slime_percent[8] = .200833;
slime_percent[9] = .066667;
slime_percent[10] = .01;

if( get_property( "badkitty" ) != "" ) max_ml_familiar = get_property( "badkitty" );
if( get_property( "goodkitty" ) != "" ) min_ml_familiar = get_property( "goodkitty" );

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
	if( weapon_type( equipped_item( $slot[offhand] ) ) != $stat[none] )
		offhand_damage = max( 1 , floor( .1 * get_power( equipped_item( $slot[offhand] ) ).to_float() ) );
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
	
	boolean stream = false;
	boolean storm = false;
	boolean wave = false;
	boolean saucegeyser = false;
	
	boolean wotpl = false;
	boolean ff = false;
	
	boolean mm = false;
	boolean vts = false;
	
	for i from 0 upto 30
	{
		switch ( get_ccs_action( i ) )
		{
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
			case "skill moxious maneuver":
				mm = true;
				break;
			case "skill vicious talon slash":
				vts = true;
				break;
		}
	}
/*
TODO: Add Capped Pasta spells
Name      Base     Myst percent     Myst cap	 Spell damage cap
Pastamancer spells
Cannelloni Cannon 	8-16 	15% 	+20 	+40*
Stuffed Mortar Shell 	16-40 	25% 	+30 	+60*
*/
	int musc_dam = max( 0 , ( my_buffedstat( $stat[muscle] ) ) - monster_defense( $monster[slime1] ) );
	if( mm ) musc_dam = max( 0 , ( my_buffedstat( $stat[moxie] ) ) - monster_defense( $monster[slime1] ) );
	if( have_skill( $skill[Eye of the Stoat] ) && lts_factor == 3 )
	{
		if( my_class() == $class[Seal Clubber] )
			musc_dam = max( 0 , ( my_buffedstat( $stat[muscle] ) * 1.3 ) - monster_defense( $monster[slime1] ) );
		else musc_dam = max( 0 , ( my_buffedstat( $stat[muscle] ) * 1.25 ) - monster_defense( $monster[slime1] ) );
	}
	
	if( weapon_type( equipped_item( $slot[weapon] ) ) == $stat[none] ) musc_dam = musc_dam * .25;
	if( shieldbutt ) offhand_damage = get_power( equipped_item( $slot[offhand] ) ) * .1;
	spell_per = ( 100 + numeric_modifier( "Spell Damage Percent" ) ) / 100;
	float elem_spell_damage;
	foreach elem in $elements[]
	{
		elem_spell_damage += numeric_modifier( elem.to_string() + " Spell Damage" );
	}
	switch
	{
		case noisemaker:
			damage = my_buffedstat( $stat[muscle] );
			break;
		case blowout:
			damage = my_buffedstat( $stat[moxie] );
			break;
		case sillystring:
			damage = my_buffedstat( $stat[mysticality] );
			break;
		case shurikens:
			damage = floor( spell_per * ( 3 + max( .07 * my_buffedstat( $stat[mysticality] ) , 15 ) + min( numeric_modifier( "Spell Damage" ) , 25 ) + elem_spell_damage ) );
			break;
		case stream:
			damage = floor( spell_per * ( 3 + max( .1 * my_buffedstat( $stat[mysticality] ) , 10 ) + min( numeric_modifier( "Spell Damage" ) , 10 ) ) );
			break;
		case storm:
			damage = floor( spell_per * ( 14 + max( .2 * my_buffedstat( $stat[mysticality] ) , 25 ) + min( numeric_modifier( "Spell Damage" ) , 15 ) ) );
			break;
		case wave:
			damage = floor( spell_per * ( 20 + max( .3 * my_buffedstat( $stat[mysticality] ) , 30 ) + min( numeric_modifier( "Spell Damage" ) , 25 ) ) );
			break;
		case saucegeyser:
			damage = floor( spell_per * ( 35 + ( .35 * my_buffedstat( $stat[mysticality] ) ) + numeric_modifier( "Spell Damage" ) ) );
			break;
		case wotpl:
		case ff:
			damage = floor( spell_per * ( 32 + ( .35 * my_buffedstat( $stat[mysticality] ) ) + numeric_modifier( "Spell Damage" ) ) );
			break;
		case vts:
			damage = floor( .75 * my_buffedstat( $stat[muscle] ) );
		default:
			damage = musc_dam + bonus_damage + ( weapon_damage * lts_factor ) + offhand_damage;
	}
	int rounds = ceil( slime_hp.to_float() / damage.to_float() );
	return max( 1 , rounds );
}

int max_possible_damage()
{
	int def_stat = my_buffedstat( $stat[moxie] );
	if( have_skill( $skill[Hero of the Halfshell] ) && item_type( equipped_item( $slot[offhand] ) ) == "shield" && my_buffedstat( $stat[muscle] ) > my_buffedstat( $stat[moxie] ) )
		def_stat = my_buffedstat( $stat[muscle] );
	int slime_attack = 100 + ( numeric_modifier( "Monster Level" ) * ( my_familiar() != $familiar[O.A.F] ).to_int() );
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
	int max_mcd = 10 + ( in_mysticality_sign().to_int() );
	int mcd = 1000 - numeric_modifier( "Monster Level" ) + current_mcd();
	if( run_type == "larva" || mcd < 0 || mcd > max_mcd ) return max_mcd;
	return mcd;
}
string run_adv( string page_text )
{
	matcher m_choice = create_matcher( "whichchoice value=(\\d+)" , page_text );
	while( contains_text( page_text , "choice.php" ) )
	{
		m_choice.reset( page_text );
		m_choice.find();
		string choice_adv_num = m_choice.group( 1 );
		
		string choice_adv_prop = "choiceAdventure" + choice_adv_num;
		string choice_num = get_property( choice_adv_prop );
		
		if( choice_adv_num == "326" && choice_num == "0" ) adventure( 1 , $location[Slime Tube] );
		
		if( choice_num == "0" ) abort( "Manual control requested for choice #" + choice_adv_num );
		if( choice_num == "" ) abort( "Unsupported Choice Adventure!" );
		
		string url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
		page_text = visit_url( url );
	}
	if( contains_text( page_text , "Combat" ) ) run_combat();
	return page_text;
}

void main( int adv_to_use )
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
			use_familiar( min_ml_familiar.to_familiar() );
			if( !use_tatter_like && min_ml_ccs != "" )
			{
				set_property( "customCombatScript" , min_ml_ccs );
				set_property( "battleAction" , "custom combat script" );
			}
			ml_outfit_on = false;
			int extra_ml = ( bladders * 20 + numeric_modifier( "Monster Level" ) ) % 100;
			switch
			{
			case my_familiar() == $familiar[O.A.F.]:
				break;
			case extra_ml <= current_mcd():
				change_mcd( 0 );
				break;
			case extra_ml <= numeric_modifier( "ur-kel's aria of annoyance" , "Monster Level" ) && have_skill( $skill[Ur-Kel's Aria of Annoyance] ):
				cli_execute( "uneffect Ur-kels" );
				break;
			case extra_ml <= current_mcd() + numeric_modifier( "ur-kel's aria of annoyance" , "Monster Level" ) && have_skill( $skill[Ur-Kel's Aria of Annoyance] ):
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
				if( have_effect( $effect[Ode to Booze]) < 1 && have_skill( $skill[Ode to Booze] ) )
				{
					use_skill( 1 , $skill[Ode to Booze]);
				}
				if( have_effect( $effect[Ode to Booze] ) > 0 )
				{
					set_property( "battleAction" , "try to run away" );
				}
				else print( "Problem casting \"Ode to Booze\" to help your Bandersnatch run away. Probably too many AT Buffs." , "red" );
				
			}
			else if( equipped_amount( $item[Navel Ring of Navel Gazing] ) > 0 && get_property( "_navelRunaways" ).to_int() < 3 )
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

			adv1($location[slime tube], -1, "");
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
			if( ( have_effect( $effect[Ode to Booze] ) > 0 && have_skill( $skill[Ode to Booze] ) ) || ( get_property( "_banderRunaways" ).to_int() >= floor( numeric_modifier( "Familiar Weight" ) + familiar_weight( $familiar[Frumious Bandersnatch] ) ) / 5 ) )
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
				change_mcd( max_mcd() );
			}
			if( have_skill( $skill[Ur-Kel's Aria of Annoyance] ) && have_effect( $effect[Ur-Kel's Aria of Annoyance] ) == 0 )
			{
				use_skill( 1 , $skill[Ur-Kel's Aria of Annoyance] );
			}
			adventure( 1 , $location[The Slime Tube] );
			adv_to_use = adv_to_use - 1;
		}
	}
}