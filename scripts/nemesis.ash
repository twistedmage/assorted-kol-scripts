#/******************************************************************************/
#                              nemesis.ash v2.7
#                         Slaying those Nemesises since 2010
#*******************************************************************************/
#
#	Nemesis Quest script by slyz.
#	See http://kolmafia.us/showthread.php?4761 for instructions.
#
#*******************************************************************************/
#
#	Thanks to Zarqon, Bale, Rinn, Alhifar, Mr Purple and many others for posting
#	so much helpful code for us to stea--- plund--- cop--- be inspired by!
#
#*******************************************************************************/
script "Nemesis Quest Script";
notify slyz ;
import "zlib.ash";

#/*****************************************************************************************\#
#																							#
#								Global variables and functions								#
#																							#
#\*****************************************************************************************/#

// global variables

// NOTE: after running this script, changing these variables here in the script will have no
// effect. You can view ("zlib vars") or edit ("zlib <settingname> = <value>") values in the CLI.
setvar( "nemesis_farm", true );
setvar( "nemesis_farm_location", $location[ The Castle in the Clouds in the Sky (Top Floor) ] );
setvar( "nemesis_farm_familiar", $familiar[ none ] );
setvar( "nemesis_farm_outfit", "");
setvar( "nemesis_farm_mood", "");
setvar( "nemesis_farm_CCS", "");
setvar( "nemesis_autobuy_LTS", "");

if ( my_class() == $class[ Seal Clubber ] && !have_skill( $skill[ Lunging Thrust-Smack ] ) )
{
	string msg = "Should the script buy Lunging Thrust-Smack (10k) to kill Mother Hellseals?";
	if ( vars[ "nemesis_autobuy_LTS" ] == "" && user_confirm( msg ) )
	{
		vars[ "nemesis_autobuy_LTS" ] = "true";
		updatevars();
	}
	else if ( vars[ "nemesis_autobuy_LTS" ] != "true" )
	{
		vars[ "nemesis_autobuy_LTS" ] = "false";
		updatevars();
		vprint( "The script will let you kill Mother Hellseals", "red", 1 );
	}
}

// Save settings so they can be restored when exiting the script
cli_execute( "checkpoint clear; checkpoint" );
familiar previous_familiar = my_familiar();
string previous_battleaction = get_property( "battleAction" );
string previous_CCS = get_property( "customCombatScript" );
string previous_mood = get_property( "currentMood" );
string previous_autoSteal = get_property( "autoSteal" );
string previous_autoEntangle = get_property( "autoEntangle" );
int previous_poop_choice = get_property( "choiceAdventure189" ).to_int();
int previous_autoattack = get_auto_attack();
set_auto_attack( 0 );
int previous_MCD = current_mcd();
if ( previous_MCD > 0 ) change_mcd( 0 );	// you weren't that anxious to get stats, were you?

// check for 100% runs
boolean is100run = vars[ "is_100_run" ].to_familiar() != $familiar[ none ];
if ( is100run ) vprint( "100% run detected, this script will use only your " + vars[ "is_100_run" ].to_familiar() , "green", 1 );

// sanity check
if ( previous_battleaction == "try to run away" ) vprint( "Mafia's combat strategy is set to run away, aborting.", 0 );

// functions
void setadv( int numadv, int numchoice )
{
	set_property( "choiceAdventure"+numadv.to_string(),numchoice.to_string() );
}

void restore_settings( boolean exiting )
{
	vprint( "Restoring initial settings...",2 );
	use_familiar( previous_familiar );
	cli_execute ( "outfit checkpoint" );
	set_property( "battleAction",previous_battleaction );
	set_property( "customCombatScript",previous_CCS );
	cli_execute ( "mood "+previous_mood );
	set_property( "autoSteal",previous_autoSteal );
	set_property( "autoEntangle",previous_autoEntangle );
	setadv( 189, previous_poop_choice );
	if ( exiting )
	{
		if ( current_mcd() != previous_MCD ) change_mcd( previous_MCD );
		set_auto_attack( previous_autoattack );
	}
}
void restore_settings() { restore_settings( true ); }

void die( string die_message )
{
	restore_settings();
	abort( die_message );
}

boolean test_combat( location loc, boolean keep_trying )
{
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Adventuring to see if "+loc+" is safe.",6 );

	string previous_remove = get_property( "removeMalignantEffects" );
	set_property( "removeMalignantEffects", "false" );

	if ( have_effect( $effect[ Beaten Up ] ) > 0 ) cli_execute("uneffect beaten up");

	boolean trap;		// trap for the return value of adventure()
	boolean do = true;
	while ( do ) {
		if ( loc == $location[ The Nemesis' Lair ] )
		{
			if ( visit_url( "volcanoisland.php?action=tniat" ).contains_text( "Combat" ) )
				run_combat();
		}
		else trap = adventure( 1,loc );
		do = ( keep_trying && get_property("lastEncounter").to_monster() == $monster[ none ] );
	}
	set_property( "removeMalignantEffects", previous_remove );

	if ( have_effect( $effect[ Beaten Up ] ) > 0 )
		return vprint( "It's not safe to adventure in "+loc+", exiting...",-1 );
	return vprint( "It's safe to adventure in "+loc+", continuing.",6 );
}
boolean test_combat( location loc ) { return test_combat( loc, true ); }

int get_price( item it ) {
	if ( historical_age(it) > 1 || historical_price(it) == 0 )
		return mall_price(it) ;
	return historical_price(it) ;
}

boolean does_damage( item it )
{
	if ( $items[ Plastic pumpkin bucket,
				 Little box of fireworks,
				 Moveable feast,
				 Ittah bittah hookah,
				 Tiny costume wardrobe,
				 Oversized fish scaler,
				 Fishy wand ] contains it )
		return true;
	for i from 2570 to 2574
		if ( i.to_item() == it )
			return true;
	return false;
}

void safe_fam_equip()
{
	if ( my_familiar().familiar_equipped_equipment().does_damage() )
	{
		item it = $item[ none ];
		if ( item_amount( $item[ Mayflower bouquet ] ) > 0 )
			it = $item[ Mayflower bouquet ];
		else if ( my_familiar().familiar_equipment().item_amount() > 0 )
			it = my_familiar().familiar_equipment();
		else if ( item_amount( $item[ lead necklace ] ) > 0 )
			it = $item[ lead necklace ];
		equip( $slot[ familiar ], it );
	}
}

# stolen from Bale
#*****************
int max_at() { return (boolean_modifier("Four Songs").to_int() + boolean_modifier("additional song").to_int() + 3); }

int current_at() {
	int total = 0;
	for song from 6003 to 6026
		if ( song.to_skill().to_effect().have_effect() > 0 )
			total = total + 1;
	return total;
}
#*****************


#/*****************************************************************************************\#
#																							#
#								Legendary Epic Weapon quest									#
#																							#
#\*****************************************************************************************/#

// Legendary Epic Weapons
string [ class ] LEWs;
LEWs[ $class[ Seal Clubber ] ] 		= "Hammer of Smiting" ;
LEWs[ $class[ Turtle Tamer ] ] 		= "Chelonian Morningstar" ;
LEWs[ $class[ Pastamancer ] ] 		= "Greek Pasta of Peril" ;
LEWs[ $class[ Sauceror ] ] 			= "17-alarm Saucepan" ;
LEWs[ $class[ Disco Bandit ] ] 		= "Shagadelic Disco Banjo" ;
LEWs[ $class[ Accordion Thief ] ] 	= "Squeezebox of the Ages" ;
item LEW = LEWs[ my_class() ].to_item() ;

// get 4 clownosity. Could be optimized some more to avoid waste.
boolean get_clownosity()
{
	record clown_item {
		item it;
		float clownosity;
		int price;
	};
	clown_item [ int ] clown;
	clown[ count(clown) ] = new clown_item( $item[ clown shoes ], 1.0, get_price( $item[ clown shoes ] ) );
	clown[ count(clown) ] = new clown_item( $item[ bloody clown pants ], 1.0, get_price( $item[ bloody clown pants ] ) );
	clown[ count(clown) ] = new clown_item( $item[ balloon helmet ], 1.0, get_price( $item[ balloon helmet ] ) );
	clown[ count(clown) ] = new clown_item( $item[ balloon sword ], 2.0, get_price( $item[ balloon sword ] ) );
	clown[ count(clown) ] = new clown_item( $item[ foolscap fool's cap ], 1.0, get_price( $item[ foolscap fool's cap ] ) );
	clown[ count(clown) ] = new clown_item( $item[ big red clown nose ], 1.0, get_price( $item[ big red clown nose ] ) );
	clown[ count(clown) ] = new clown_item( $item[ polka-dot bow tie ], 2.0, get_price( $item[ polka-dot bow tie ] ) );
	clown[ count(clown) ] = new clown_item( $item[ clown wig ], 2.0, get_price( $item[ clown wig ] ) );
	clown[ count(clown) ] = new clown_item( $item[ clownskin belt ], 2.0, get_price( $item[ clownskin belt ] ) );
	clown[ count(clown) ] = new clown_item( $item[ clownskin buckler ], 2.0, get_price( $item[ clownskin buckler ] ) );
	clown[ count(clown) ] = new clown_item( $item[ clown whip ], 2.0, get_price( $item[ clown whip ] ) );
	clown[ count(clown) ] = new clown_item( $item[ clownskin harness ], 2.0, get_price( $item[ clownskin harness ] ) );
	sort clown by value.price / value.clownosity;

	// equip items that are available
	foreach i in clown
	{
		if ( numeric_modifier( "Clownosity" ) >= 4.0 ) continue;
		if ( available_amount( clown[ i ].it ) == 0 ) continue;
		if ( have_equipped( clown[ i ].it ) ) continue;

		slot s = clown[ i ].it.to_slot();
		// check if there is an accessory slot free
		if ( s == $slot[ acc1 ] )
			foreach sl in $slots[ acc1, acc2, acc3, none ]
				if ( equipped_item( sl ).numeric_modifier( "Clownosity" ) == 0.0 ) { s = sl; break; }
		// no accessory slot free, check if there is an accessory with less clownosity than the currently considered one
		if ( s == $slot[none] && clown[ i ].it.numeric_modifier( "Clownosity" ) == 2.0 )
			foreach sl in $slots[ acc1, acc2, acc3, none ]
				if ( equipped_item( sl ).numeric_modifier( "Clownosity" ) == 1.0 ) { s = sl; break; }

		if ( s != $slot[none] ) equip( s, clown[ i ].it );
	}

	// retrieve more items if needed
	int i = 0;
	float clownosity_needed = 4.0 - numeric_modifier( "Clownosity" );
	while ( clownosity_needed > 0.0 && i < count( clown ) )
	{
		if ( available_amount( clown[ i ].it ) > 0 ) continue;

		// check if the currently considered item is better than one already equipped
		slot s = clown[ i ].it.to_slot();
		if ( s == $slot[ acc1 ] )	// accessories
			foreach sl in $slots[ acc1, acc2, acc3, none ]
				if ( equipped_item( sl ).numeric_modifier( "Clownosity" ) < clown[ i ].it.numeric_modifier( "Clownosity" ) )
				{
					s = sl;
					break;
				}
		else if ( equipped_item( s ).numeric_modifier( "Clownosity" ) >= clown[ i ].it.numeric_modifier( "Clownosity" ) )
			s = $slot[ none ];

		if ( s == $slot[ none ] ) continue;

		retrieve_item( 1,clown[ i ].it );
		if ( available_amount( clown[ i ].it ) > 0 )
			clownosity_needed -= clown[ i ].clownosity;

		i += 1;
	}
	return maximize( "4 clownosity -familiar -tie", true );
}

// get Funhouse item
boolean get_FUN( item FUN )
{
	if ( available_amount( FUN ) > 0 ) return vprint( "Funhouse item already obtained",6 );
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Acquiring Funhouse item...","green",2 );

	// get 4 Clownosity. This could use some optimisation (and taking into account no mall access)
	if ( !maximize( "4 clownosity -familiar -tie", true ) || !get_clownosity() || !maximize( "4 clownosity -familiar -tie", false ) )
		return vprint( "More Clownosity needed!",-1 );

	// crude mood
	if ( have_skill( to_skill( $effect[ The Sonata of Sneakiness ] ) ) && have_effect( $effect[ The Sonata of Sneakiness ] ) == 0 && current_at() <  max_at() )
		use_skill( 1, to_skill( $effect[ The Sonata of Sneakiness ] ) );
	if ( have_skill( to_skill( $effect[ Smooth Movements ] ) ) && have_effect( $effect[ Smooth Movements ] ) == 0  )
		use_skill( 1, to_skill( $effect[ Smooth Movements ] ) );

	// adventure in the The "Fun" House until you beat Beelzebozo
	setadv( 151,1 ); // fight the Clownlord

	cli_execute ( "mood apathetic" );
	use_familiar( previous_familiar );

	return ( test_combat( $location[ The "Fun" House ] ) && obtain( 1,to_string(FUN),$location[ The "Fun" House ] ) );
}

// get LEW
boolean get_LEW()
{
	if ( my_basestat( my_primestat() ) < 12 ) return vprint( "Try the LEW quest again when you have 12 base mainstat",-1 );
	if ( available_amount( LEW ) > 0 ) return vprint( "LEW already obtained", 6 );
	vprint( "Acquiring LEW...", "green", 2 );

	// make sure you unlock your class NPC
	if ( !visit_url( "guild.php" ).contains_text( "place=scg" ) )
		cli_execute( "guild" );

	item EW ; item FUN ;
	foreach it in get_ingredients( LEW )
	{
		if ( count( get_ingredients( it ) ) > 0 ) EW = it ;
		else FUN = it ;
	}

	if ( !retrieve_item( 1,EW ) ) return vprint( "Unable to obtain your Epic Weapon, please craft/buy one.",-1 ) ;

	// visit guild NPC to make sure you have the quest
	visit_url( "guild.php?place=scg" );
	// REALLY make sure you have the quest.
	visit_url( "guild.php?place=scg" );

	if ( !get_FUN( FUN ) ) return vprint( "Could not obtain Funhouse item",-1 ) ;
	return retrieve_item( 1,LEW );
}


#/*****************************************************************************************\#
#																							#
#									Nemesis Cave quest										#
#																							#
#\*****************************************************************************************/#

item [ class ] caveClassItems ;
item [ class, int ] caveClassItemsDisco ;
caveClassItems[ $class[ Seal Clubber ] ] 	= $item[ clown whip ] ;
caveClassItems[ $class[ Turtle Tamer ] ] 	= $item[ clownskin buckler ] ;
caveClassItems[ $class[ Pastamancer ] ] 	= $item[ boring spaghetti ] ;
caveClassItems[ $class[ Sauceror ] ] 		= $item[ tomato juice of powerful power ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 1 ] 	= $item[ Pink pony ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 2 ] 	= $item[ slip 'n' slide ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 3 ] 	= $item[ fuzzbump ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 4 ] 	= $item[ ocean motion ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 5 ] 	= $item[ ducha de oro ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 6 ] 	= $item[ calle de miel ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 7 ] 	= $item[ Slap and tickle ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 8 ] 	= $item[ a little sump'm sump'm ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 9 ] 	= $item[ Rockin' wagon ] ;
caveClassItemsDisco [ $class[ Disco Bandit ] ] [ 10 ] 	= $item[ perpendicular hula ] ;

item[ stat,int ] caveMainstatItems ;
caveMainstatItems[ $stat[ Muscle ] ] [ 1 ] 		= $item[ viking helmet ];
caveMainstatItems[ $stat[ Muscle ] ] [ 2 ] 		= $item[ insanely spicy bean burrito ];
caveMainstatItems[ $stat[ Mysticality ] ] [ 1 ] = $item[ stalk of asparagus ];
caveMainstatItems[ $stat[ Mysticality ] ] [ 2 ] = $item[ insanely spicy enchanted bean burrito ];
caveMainstatItems[ $stat[ Moxie ] ] [ 1 ] 		= $item[ dirty hobo gloves ];
caveMainstatItems[ $stat[ Moxie ] ] [ 2 ] 		= $item[ insanely spicy jumping bean burrito ];

//--------------------------//
//	Guild Class NPC texts   //
//--------------------------//

// finishing the LEW quest

/*
-> "Big Mountains"
*/

// Subsequent visits:

/*
SC:
TT:
	"Have you defeated your Nemesis yet? No? ...Have I mentioned how vitally important it is that you do so and reclaim our stolen artifact? I'm pretty sure I mentioned that."
S:
PM:
	"Please make haste, <name>. We need you to defeat your Nemesis and retrieve that artifact as quickly as possible."
DB:
AT:
	"Haven't beat your Nemesis yet, eh? Look bud, I don't mean to get on your case, but we really don't have a lot of time to be messing around, you know?"
*/

boolean startCaveQuest()
{
	if ( my_basestat( my_primestat() ) < 25 ) return vprint( "Try the Nemesis Cave quest again when you have 25 base mainstat", -1 );
	if ( available_amount( LEW ) == 0 ) return vprint( "You need to make your Legendary Epic Weapon to unlock the Nemesis Cave quest", -1 );
	if ( visit_url( "mountains.php" ).contains_text( "cave.php" ) ) return vprint( "Nemesis Cave already unlocked", 6 );
	vprint( "Opening Nemesis Cave...","green",2 );

	// visit guild NPC to get the quest
	string response = visit_url( "guild.php?place=scg" );

	// check if the cave is available
	if ( 	response.contains_text( "Big Mountains" )
		 || response.contains_text( "Have you defeated your Nemesis yet" )
		 || response.contains_text( "Please make haste" )
		 || response.contains_text( "beat your Nemesis yet" )
	) return vprint( "Nemesis Cave Quest successfully unlocked", 6 );

	return vprint( "Could not unlock the Nemesis Cave Quest for some reason.", -1 );
}

boolean caveDoors()
{
	// find what the current closed door is
	int currentDoor;
	string url = visit_url( "cave.php" ) ;
	matcher doorNum = create_matcher( "action=door(\\d)", url );
	if ( doorNum.find() ) currentDoor = doorNum.group( 1 ).to_int() ;
	else return vprint( "Nemesis Cave doors already opened",6 );
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "opening Nemesis Cave doors...","green",2 );

	boolean openCaveDoor( int num, item itm )
	{
		if ( !retrieve_item( 1, itm ) )
			return vprint( "You need 1 more " + itm + " to open door n°" + num + ", exiting.",-1 ) ;

		string url = visit_url( "cave.php?action=door" + num + "&action=dodoor" + num + "&whichitem=" + itm.to_int() );
		if ( contains_text( url, "action=door"+num ) )
			return vprint( "Something happened while opening door n°" + num + ", exiting.",-1 );

		return vprint( "Door n°"+num+" opened.",6 ) ;
	}

	// open doors 1 & 2
	foreach num,itm in caveMainstatItems[ my_primestat()  ]
		if ( currentDoor == num && openCaveDoor( num, itm ) )
			currentDoor += 1 ;

	// open door 3 (might want to add code to get polka from a buffbot)
	if ( currentDoor == 3 )
	{
		if ( my_class() == $class[ Accordion Thief ] )
		{
			if ( have_effect( $effect[ Polka of Plenty ] ) < 15 )
			{
				if ( current_at() >=  max_at() )
					return vprint( "You have too many AT songs to get Polka of Plenty for door n°3", -1 );
				if ( !have_skill( $skill[ The Polka of Plenty ] ) )
					return vprint( "You need to get buffed with 15 turns of Polka of Plenty to open door n°3.",-1 );
				use_skill( 1, $skill[ The Polka of Plenty ] ) ;
				if ( have_effect( $effect[ Polka of Plenty ] ) < 15 )
					return vprint( "Something happened when trying to cast Polka of Plenty.",-1 );
			}
			url = visit_url( "cave.php?action=door3" );
			if ( contains_text( url, "action=door3" ) )
				return vprint( "Something happened while opening door n°3, exiting.",-1 );
			currentDoor += 1 ;
		}
		else if ( my_class() == $class[ Disco Bandit ] )
		{
			foreach boozeIndex in caveClassItemsDisco[my_class() ]
			{
				if ( openCaveDoor(3,caveClassItemsDisco[my_class()][boozeIndex] ) )
				{
					currentDoor += 1 ;
					break;
				}
			}
		}
		else if ( openCaveDoor( 3,caveClassItems[ my_class() ] ) )
			currentDoor += 1 ;
	}

	// door 4 is handled by caveLastDoor()
	if ( currentDoor == 4 ) return vprint( "Nemesis Cave doors opened",6 );
	return vprint( "Something happened while opening the Nemesis Cave doors, exiting.",-1 );
}

boolean gatherPaperStrips()
{
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Gathering paper strips...","green",2 );

	use_familiar( best_fam("items") );
	maximize( "item drop -familiar -tie", false );
	set_location( $location[ Nemesis Cave ] );
	cli_execute( "conditions clear; conditions set 8 any paper strip" );

	if ( !test_combat( $location[ Nemesis Cave ] ) )
		return vprint( "Paper strips have not been gathered",-1 );

	if ( adventure( my_adventures(),$location[ Nemesis Cave ] ) )
		return vprint( "Out of adventures, exiting...",-1 );

	return vprint( "Paper strips gathered",6 );
}

string getPaperStripsPassword()
{
	string password = "";

	// check if all the paper strips have been identified
	cli_execute( "nemesis strips" );
	if ( get_property( "lastPaperStripReset" ) != get_property( "knownAscensions" ) )
		return password;

	// reproduced from KoLMafia's NemesisManager.java (thanks Veracity/JasonHarper!)
	record paperstrip { string left; string right; string word; };
	int current_strip;
	paperstrip [ int ] strips;
	paperstrip [ int ] ordered_strips;
	int [ string ] lefts;
	int [ string ] rights;

	boolean parseStrip( int i )
	{
		string [ int ] id = get_property("lastPaperStrip"+i).split_string( ":" );
		if ( id[ 0 ] == "" ) return false;
		int index = count(strips);
		strips[ index ].left  = id[ 0 ];
		strips[ index ].word  = id[ 1 ];
		strips[ index ].right = id[ 2 ];
		lefts [ id[ 0 ] ] = index;
		rights[ id[ 2 ] ] = index;
		return true;
	}
	if ( !parseStrip(3144) ) return password;
	for i from 4138 to 4144 if ( !parseStrip(i) ) return password;

	// Find leftmost paper strip
	foreach i in strips
	{
		if ( !( rights contains strips[ i ].left ) )
		{
			ordered_strips[ 0 ] = strips[ i ];
			current_strip = i;
			break;
		}
	}

	// Order remaining paper strips
	while ( count(ordered_strips) < count(strips) )
	{
		current_strip = lefts[ strips[ current_strip ].right ];
		ordered_strips[ count(ordered_strips) ] = strips[ current_strip ];
	}

	foreach i in ordered_strips
		password += ordered_strips[ i ].word;

	return password;
}

boolean caveLastDoor()
{
	// open the last door with the password
	if ( getPaperStripsPassword() == "" && !gatherPaperStrips() )
		return vprint( "Could not gather paper strips",-1 );

	string password = getPaperStripsPassword();
	if ( password == "" )
		return vprint( "For some reason, the paper strips have not been identified!",-1 );

	string response = visit_url( "cave.php?action=door4" );
	if ( response.contains_text( "you've already fought your Nemesis" ) )
		return vprint( "You have already killed your Nemesis.",6 );

	response = visit_url( "cave.php?action=door4&action=dodoor4&say="+password );
	if ( response.contains_text( "Nothing much happens" ) )
		return vprint( "The following password did no work in the Nemesis Cave: "+password,-1 );

	// Fight your Nemesis
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Fighting the Nemesis in the Cave...","green",2 );

	if ( equipped_item( $slot[ weapon ] ) != LEW ) equip( $slot[ weapon ],$item[ none ] );
	switch ( my_primestat() )
	{
		case $stat[ Muscle ]:
		case $stat[ Mysticality ]:
			maximize( "Muscle, -weapon -familiar -tie", false );
			break;
		case $stat[ Moxie ]:
			maximize( "Moxie, -weapon -familiar -tie", false );
			break;
	}
	equip( LEW );
	use_familiar( best_fam("combat") );
	set_property( "battleAction", "attack with weapon" );
	cli_execute( "mood apathetic" );
	restore_hp( 0 );
	restore_mp( 0 );

	visit_url( "cave.php?action=sanctum" );
	response = run_combat();
	if ( !response.contains_text( "WINWINWIN" ) )
		return vprint( "Failed to beat your Nemesis in the cave!",-1 );

	set_property( "battleAction", previous_battleaction );
	return vprint( "Nemesis Cave quest done!","green",1 );
}

boolean nemesisCave()
{
	return ( startCaveQuest() && caveDoors() && caveLastDoor() );
}


#/*****************************************************************************************\#
#																							#
#								Opening the Volcano island									#
#																							#
#\*****************************************************************************************/#

item MAP = $item[ secret tropical island volcano lair map ];

//--------------------------//
//	Guild Class NPC texts   //
//--------------------------//

// finishing the Cave quest

/*
Mus:
	"Terrific," he sighs. "she must have hidden it somewhere else. Probably has a secret tropical island volcano lair or something. All right, I'll get our guys on trying to find out where she's hiding. When they find something, I'll let you know."
Myst:
	"That is not the artifact we're looking for. Is that all he had? This is most unfortunate. he must have a secret tropical island volcano lair or something similar, on which he's hidden the artifact. I will put our divination specialists to the task of locating it -- when I will have more information for you, you will be contacted."
	"We have not located your Nemesis as yet. Rest assured that, when we do, you will be alerted immediately."
Mox:
	"Fantastic. All right, I'll get our spies onto finding out where he hid the artifact. Probably some secret tropical island volcano lair or something. I'll call you when we've got a lead."
	"Yeah, we haven't found your Nemesis yet. You'll be the first to know, all right?"


-> "secret tropical island volcano lair or something"
*/

// Before meeting the first/second hitman:

/*
SC:
TT:
	"Sorry, we haven't found your Nemesis yet. We'll contact you when we find something out."
S:
PM:
	"We have not located your Nemesis as yet. Rest assured that, when we do, you will be alerted immediately."
DB:
AT:
	"Yeah, we haven't found your Nemesis yet. You'll be the first to know, all right?"
	
-> "t (located|found) your Nemesis"
*/

// After meeting the first/second hitman:

/*
SC:
TT:
		"<Player Name>! Thank goodness you're here -- some pretty shady characters have been asking about you."
	"Yeah, I had a run-in with some of them," you mutter darkly. "It looks like there's a price on my head."
	"Your Nemesis' work, I'll wager. I wish I could tell you we'd tracked down his location, but (s)he's proving to be devilishly sneaky. You'd better watch your back."
	"Yeah, thanks."
S:
PM:
		"Ah, <Player Name>, it is good to see you safe. There have been some notably disreputable-looking people inquiring about you."
	"Yeah, I had a run-in with some of them," you mutter darkly. "It looks like there's a price on my head."
	"Undoubtedly an attempt at revenge by your Nemesis. Unfortunately, (s)he has somehow managed to defeat all attempts to locate him via magical means. We will continue our attempts, but in the meantime, please use the utmost caution."
	"Yeah, thanks."
DB:
AT:
		"[player], buddy, good to see you've still got your head attached. There's some pretty sketchy people looking for you, and believe me, I know from sketchy."
	"Yeah, I had a run-in with some of them," you mutter darkly. "It looks like there's a price on my head."
	"Yep, that's what we're hearing. No dice on trying to find his hideout yet, either. You might wanna lie low till the heat's off. 'Course, that could be a pretty long time."
	"Yeah, thanks."


-> "Yeah, I had a run-in with some of them,"
*/

// with the Map

/*
-> "it was a secret tropical volcano island after all"
*/

boolean getVolcanoMap()
{
	if ( item_amount( MAP ) > 0 ) return vprint( "Volcano Map already obtained",6 );

	// make sure the quest has been given by the guild NPC
	string response = visit_url("guild.php?place=scg");
	matcher finishCaveQuest = create_matcher( "secret tropical island volcano lair or something",response );
	matcher beforeHitmen = create_matcher( "t (located|found) your Nemesis",response );
	matcher afterHitmen = create_matcher( "Yeah, I had a run-in with some of them",response );

	if ( !finishCaveQuest.find() && !beforeHitmen.find() && !afterHitmen.find() )
		return vprint( "You have to finish the Nemesis Cave quest before continuing",-1 );

	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	if ( !can_interact() ) return vprint( "You are still in-run, please run this script again once you obtain the Volcano Map.", -1 );
	if ( !vars[ "nemesis_farm" ].to_boolean() ) die( "Please run this script again once you obtain the Volcano Map." );
	vprint( "Now to spend some turns while waiting for the hitmen...","green", 2 );

	location farm_location = vars[ "nemesis_farm_location" ].to_location();
	familiar farm_familiar = ( is100run ? vars[ "is_100_run" ].to_familiar() : vars[ "nemesis_farm_familiar" ].to_familiar() );
	string farm_outfit = vars[ "nemesis_farm_outfit" ];
	string farm_mood = vars[ "nemesis_farm_mood" ];
	string farm_CCS = vars[ "nemesis_farm_CCS" ];

	// check if Mafia understands the zlib vars
	if ( farm_location == $location[ none ] )
		return vprint( "Mafia did not understand this location: " + vars[ "nemesis_farm_location" ] + ". Please check your nemesis_farm_location zlib setting.",-1 );
	if ( vars["nemesis_farm_familiar"] != "none" && vars["nemesis_farm_familiar"] != "" && farm_familiar == $familiar[none] )
		return vprint( "Mafia did not understand this familiar: " + vars[ "nemesis_farm_familiar" ] + ". Please check your nemesis_farm_familiar zlib setting.",-1 );

	// get ready to farm
	if ( farm_familiar != $familiar[ none ] ) use_familiar( farm_familiar );
	else use_familiar( previous_familiar );

	if ( farm_outfit != "" )
	{
		cli_execute( "outfit "+farm_outfit );
	}
	else
	{
		cli_execute( "outfit checkpoint" );
		cli_execute( "checkpoint" );
	}

	if ( farm_mood != "" ) cli_execute( "mood "+farm_mood );
	else cli_execute( "mood "+previous_mood );
	cli_execute( "mood execute" );

	if ( farm_CCS != "" )
	{
		set_property( "battleAction", "custom combat script" );
		set_property( "customCombatScript", farm_CCS );
	}
	else
	{
		set_property( "battleAction", previous_battleaction );
		set_property( "customCombatScript", previous_CCS );
	}

	set_property( "autoSteal", previous_autoSteal );

	// add an abort in the mood if the previous monster dropped the map but you didn't get it
	cli_execute( "trigger unconditional, , ashq if (get_property('lastEncounter').to_monster().item_drops() contains $item["+MAP+"] && item_amount($item["+MAP+"])==0)abort('You were beaten up by the last hitman - aborting');" );

	// farm until you have the map or run out of advs
	return ( test_combat(farm_location) && obtain( 1, MAP.to_string(), farm_location ) );
}

boolean openVolcanoIsland()
{
	if ( !getVolcanoMap() ) return vprint( "Could not get the Volcano Map.",-1 );

	set_property( "battleAction", previous_battleaction );
	set_property( "customCombatScript", previous_CCS );

	//make sure the island isn't available
	if ( !visit_url("volcanoisland.php").contains_text( "There's no island out there." ) )
		return vprint( "The Volcano Island is already available.",6 );

	// visit guild
	string response = visit_url("guild.php?place=scg");
	matcher volcanoUnlock = create_matcher( "it was a secret tropical .+? after all", response );
	if ( !volcanoUnlock.find() )
		return vprint( "Could not unlock the Volcano Island choice in the Poop Deck for some reason, exiting...",-1 );

	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Unlocking the Volcano Island...","green",2 );

	restore_settings( false );

	//make sure you can access the Poop Deck
	if ( my_basestat( $stat[ Mysticality ] ) > 60 && available_amount( $item[ Pirate fledges ] ) > 0 )
		equip( $slot[ acc1 ], $item[ Pirate fledges ] );
	else if ( have_outfit( "Swashbuckling Getup" ) )
		outfit( "Swashbuckling Getup" );
	else return vprint( "You can't access the Poop Deck, exiting...",-1 );

	// Get some +NC
	if ( available_amount( $item[ Ring of Conflict ] ) > 0 )
		equip( $slot[ acc2 ], $item[ Ring of Conflict ] );
	if ( available_amount( $item[ Space Trip safety headphones ] ) > 0 )
		equip( $slot[ acc3 ], $item[ Space Trip safety headphones ] );
	foreach eff in $effects[Carlweather's Cantata of Confrontation, Musk of the Moose]
		if ( have_effect( eff ) > 0 ) cli_execute( "uneffect " + eff );

	// adventure in the Poop Deck
	setadv( 189, 0 ); // just to be sure Mafia doesn't automatically manage the O Cap'm choice adventure
	while ( my_adventures() > 0 )
	{
		// Crude mood maintenance
		restore_hp( 0 );
		restore_mp( 0 );
		if ( have_skill( to_skill( $effect[ The Sonata of Sneakiness ] ) ) && have_effect( $effect[ The Sonata of Sneakiness ] ) == 0 && current_at() <  max_at() )
			use_skill( 1, to_skill( $effect[ The Sonata of Sneakiness ] ) );
		if ( have_skill( to_skill( $effect[ Smooth Movements ] ) ) && have_effect( $effect[ Smooth Movements ] ) == 0  )
			use_skill( 1, to_skill( $effect[ Smooth Movements ] ) );

		print( "" );
		response = visit_url( "adventure.php?snarfblat=159" );
		if ( !response.contains_text( "choice.php" ) ) { run_combat(); continue; }
		if ( !response.contains_text( "Show the tropical island volcano lair map" ) )
			abort( "Could not unlock the Volcano Island choice in the Poop Deck for some reason, returning manual control!" );
		visit_url( "choice.php?pwd&whichchoice=189&option=3" );
		visit_url( "volcanoisland.php?pwd&action=arrive" );
		return vprint( "Volcano island unlocked!",6 );
	}
	return vprint( "Out of adventures.",-1 );
}


#/*****************************************************************************************\#
#																							#
#								Unlocking the Nemesis Lair									#
#																							#
#\*****************************************************************************************/#


//------------------//
//	Seal Clubber	//	Thanks to Mr Purple @ kolmafia.us
//------------------//

boolean check_LTS()
{
	if ( have_skill( $skill[ Lunging Thrust-Smack ] ) ) return vprint( "You already know LTS.", 8 );
	if ( !vars[ "nemesis_autobuy_LTS" ].to_boolean() ) return vprint( "If you want the script to buy LTS automatically, type \"zlib nemesis_autobuy_LTS = true\" in the gCLI.", -1 );
	if ( my_meat() < 10000 ) return vprint( "Not enough meat to buy LTS.", -1 );
	return visit_url( "guild.php?action=buyskill&skillid=5" ).contains_text( "You learn a new skill" );
}

boolean gathered_hellseal_parts()
{
	foreach it in $items[ hellseal brain, hellseal hide, hellseal sinew ]
		if ( item_amount( it ) < 6 ) return false;
	return true;
}

int [ item ] update_burst_parts()
{
	int [ item ] burst_parts;
	foreach it in $items[ burst hellseal brain, shredded hellseal hide, torn hellseal sinew ]
		burst_parts[ it ] = item_amount( it );
	return burst_parts;
}

boolean got_burst_hellseal_parts( int [ item ] burst_parts )
{
	foreach it in burst_parts
		if ( item_amount( it ) > burst_parts[ it ] ) return true;
	return false;
}

/*
record passive_damage_map
{
	item [ int ] gear;
	effect [ int ] effects;
};

passive_damage_map passive_damage_sources()
{
	vprint( "Checking passive damage sources on the KoL Wiki...", 6 );

	passive_damage_map res;

	string wiki = visit_url( "http://kol.coldfront.net/thekolwiki/index.php/Passive_Damage" );
	matcher wikimatcher = create_matcher( "<td><a(?:[^>]+)>([^<]+)</a>\\n</td>\\n<td>(?:<a[^<]+</a> )*([^<\\s\\n]+)", wiki );

	while ( wikimatcher.find() )
	{
		print( "found one");
		string it = wikimatcher.group( 1 );
		string source = wikimatcher.group( 2 ).replace_string( "Accessory", "acc1" );

		if ( source == "Effect" || source == "Buff" )
			res.effects[ res.effects.count() ] = it.to_effect();
		else if ( source.to_slot() != $slot[ none ] )
			res.gear[ res.gear.count() ] = it.to_item();
	}

	return res;
}
*/

float LTS_damage( int mother_level, item wpn )
{
	if ( wpn.item_type() != "club" ) return 0;
	if ( wpn.weapon_hands() != 2 ) return 0;

	cli_execute( "speculate equip " + wpn + "; quiet;" );

	// calculate minimum damage due to difference between attack and defense
	float mus = numeric_modifier( "_spec", "Buffed Muscle" );
	float musadj = 1.0;
	float ml = numeric_modifier( "_spec", "Monster Level" );
	float basemondef = 150 * 1.385 ** mother_level ;
	float mondef = 0.9 * ( basemondef + ml + min( 5, floor( basemondef * 0.05 ) ) );
	float musdmg = max( 0, floor( mus * musadj ) - mondef );

	// calculate minimum weapon damage
	float wpndmg = get_power( wpn ) * 0.1 * 3 + numeric_modifier( "_spec", "Weapon Damage" );

	// calculate total physycal damage
	float wpndmgpct = numeric_modifier( "_spec", "Weapon Damage Percent" ) / 100.0;
	float dam = ( musdmg + wpndmg ) * ( 1.0 + wpndmgpct );

	// add elemental damage
	foreach el in $elements[] dam += numeric_modifier( "_spec", el + " Damage" );

	vprint( "LTS damage against a level " + mother_level + " Mother with a " + wpn + ": " + dam, 10 );
	return dam;
}
float LTS_damage( int mother_level ) { return LTS_damage( mother_level, equipped_item( $slot[ weapon ] ) ); }

float mother_damage( int mother_level, item wpn )
{
	cli_execute( "speculate equip " + wpn + "; quiet;" );

	float mox = numeric_modifier( "_spec", "Buffed Moxie" ) ;

	// calculate monster attack
	float basemonatt = 150 * 1.385 ** mother_level ;
	float ml = numeric_modifier( "_spec", "Monster Level" );
	float monatt = basemonatt + ml + min( 5, floor( basemonatt * 0.05 ) );

	// calculate base damage
	float dam = max( 0, monatt - mox ) + monatt * 0.25 - numeric_modifier( "_spec", "Damage Reduction" );

	// calculate damage after damage absorbtion
	float da = numeric_modifier( "_spec", "Damage Absorption" );
	float absfrac = min( 0.9, max( 0, ( square_root( da / 10.0 ) - 1.0 ) / 10.0 ) );
	dam = dam * ( 1.0 - absfrac );

	vprint( "Level " + mother_level + " Mother damage with a " + wpn + ": " + dam, 10 );
	return dam;
}
float mother_damage( int mother_level ) { return mother_damage( mother_level, equipped_item( $slot[ weapon ] ) ); }

int num_LTS_needed( int mother_level, item wpn )
{
	cli_execute( "speculate equip " + wpn + "; quiet;" );
	float mother_hp = 160.0 + numeric_modifier( "_spec", "Monster Level" );
	return ceil( mother_hp / LTS_damage( mother_level, wpn ) );
}
int num_LTS_needed( int mother_level ) { return num_LTS_needed( mother_level, equipped_item( $slot[ weapon ] ) ); }

float hp_loss( int mother_level, item wpn )
{
	cli_execute( "speculate equip " + wpn + "; quiet;" );
	int numhits = max( 1, num_LTS_needed( mother_level, wpn ) - 2 * have_skill( $skill[ Entangling Noodles ] ).to_int() );
	float hp_loss = numhits * mother_damage( mother_level, wpn );

	vprint( "Total HP loss with a " + wpn + ": " + hp_loss, 10 );
	return hp_loss;
}
float hp_loss( int mother_level ) { return hp_loss( mother_level, equipped_item( $slot[ weapon ] ) ); }

int my_maxhp( item wpn )
{
	cli_execute( "speculate equip " + wpn + "; quiet;" );
	vprint( "max hp with a " + wpn + ": " + numeric_modifier( "_spec", "Buffed HP Maximum" ) , 10 );
	return numeric_modifier( "_spec", "Buffed HP Maximum" );
}

boolean is_onehitting( int mother_level )
{
	float mother_hp = 160.0 + numeric_modifier( "_spec", "Monster Level" );
	return ( LTS_damage( mother_level ) >= mother_hp );
}

boolean get_2h_club()
{
	item [ int ] clubs;

	// check for available clubs
	boolean hasclub = false;
	foreach it in $items[]
	{
		if ( it.item_type() != "club" || it.weapon_hands() != 2 ) continue;
		if ( !can_equip( it ) ) continue;
		if ( available_amount( it ) > 0 ) hasclub = true ;
		clubs[ clubs.count() ] = it;
	}
	if ( hasclub ) return true;

	// If you don't have any club available, buy the cheapest one
	sort clubs by value.mall_price();
	foreach i, c in clubs
	{
		if ( mall_price( c ) == 0 || mall_price( c ) > 5000 ) continue;
		if ( !retrieve_item( 1, c ) ) continue;
		return item_amount( c ) > 0;
	}
	return false;
}

boolean equip_2h_club()
{
	// check for available clubs
	item [ int ] clubs;
	foreach it in $items[]
	{
		if ( it.item_type() != "club" || it.weapon_hands() != 2 ) continue;
		if ( !can_equip( it ) ) continue;
		if ( available_amount( it ) == 0 ) continue;
		clubs[ clubs.count() ] = it;
	}
	if ( clubs.count() == 0 ) return vprint( "No club available.", -1 );

	// decide which club is best
	int mother_level = 11;
	repeat
	{
		mother_level -= 1;
		sort clubs by hp_loss( mother_level, value ) ; //  / my_maxhp( value ).to_float();
	}
	until ( mother_level == 1 || hp_loss( mother_level, clubs[ 0 ] ) < my_maxhp( clubs[ 0 ] ) );

	vprint( clubs[ 0 ] + " chosen.", "green", 6 );
	if ( !retrieve_item( 1, clubs[ 0 ] ) ) return vprint( "Something happened while trying to retrieve a " + clubs[ 0 ] + ".", -1 );

	equip( clubs[ 0 ] );
	return ( equipped_amount( clubs[ 0 ] ) > 0 );
}

item choose_stasis()
{
	foreach it in $items[ spices, seal tooth, dictionary, spectre scepter ]
	{
		if ( available_amount( it ) > 0 && retrieve_item( 1, it ) ) return it;
	}
	foreach it in $items[ spices, seal tooth ]
	{
		if ( retrieve_item( 1, it ) ) return it;
	}
	return $item[ none ];
}

boolean make_pup_wail( item stasis_item )
{
	string macro = "while !match \"screeching wail\"; use " + stasis_item.to_int() + "; endwhile;";
	string page = visit_url( "fight.php?action=macro&macrotext=" + macro );
	return page.contains_text( "screeching wail" ) ;

	/*
	int i = 0;
	while ( i < 30 )
	{
		if ( stasis_item != $item[ none ] ) page = visit_url( "fight.php?action=useitem&whichitem=" + stasis_item.to_int() );
		else page = visit_url( "fight.php?action=skill&whichskill=1022" );
		i += 1;
		if ( page.contains_text( "screeching wail" ) ) return true;
		if ( page.contains_text( "Adventure Again" ) ) return false;
		if ( !page.contains_text( "hellseal pup" ) ) return false;
	}
	return false;
	*/
}

familiar choose_potato()
{
	if ( is100run ) return vars[ "is_100_run" ].to_familiar();
	foreach fam in $familiars[ Squamous Gibberer, Temporal Riftlet, Cotton Candy Carnie, Emo Squid, Levitating Potato, Untamed Turtle, Cuddlefish ]
		if ( have_familiar( fam ) ) return fam;
	return $familiar[ Blood-Faced Volleyball ];
}

boolean get_hellseal_disguise()
{
	if ( item_amount( $item[ hellseal disguise ] ) > 0 ) return vprint( "You already have the hellseal disguise.", 6 );
	if ( !check_LTS() ) return vprint( "The script can't kill Mother Hellseals without Lunging Thrust-Smack. It's up to you now.", -1 );
	if ( !get_2h_club() ) return vprint( "You need a 2-handed club to continue.", -1 );

	// remember how many burst parts you had before starting
	int [ item ] old_burst_parts = update_burst_parts();

	// obtain passive damage sources from data file_to_map
	string [ string ] passive_damage_sources_map;
	if ( !file_to_map( "nemesis_passive_damage_sources.txt", passive_damage_sources_map ) )
		return vprint( "Something happened while trying to load nemesis_passive_damage_sources.txt.", -1 );

	effect [ int ] passive_damage_effects;
	item [ int ] passive_damage_gear;
	foreach it, type in passive_damage_sources_map
	{
		if ( type == "effect" ) passive_damage_effects[ passive_damage_effects.count() ] = it.to_effect();
		if ( type == "gear" ) passive_damage_gear[ passive_damage_gear.count() ] = it.to_item();
	}

	// uneffect sources of passive damage
	foreach i,e in passive_damage_effects
	{
		if ( have_effect( e ) > 0 ) cli_execute( "uneffect " + e );
		if ( have_effect( e ) > 0 ) return vprint( "Mafia couldn't uneffect " + e + ", you need to remove it before continuing.", -1 );
	}

	// maximize HP and damage while avoiding gear that gives passive damage
	string cmd = "DA, 0.1 hp, weapon dmg, 0.1 weapon damage percent, elemental dmg, -weapon, -offhand, -familiar" ;
	foreach i,g in passive_damage_gear
	{
		cmd += ", -equip " + g;
	}
	maximize( cmd, false );

	// use whatever +HP or +damage buffs you have
	cli_execute ( "mood apathetic" );
	skill [ int ] buffs;
	foreach sk in $skills[ Rage of the Reindeer, Snarl of the Timberwolf, Holiday Weight Gain, Reptilian Fortitude, Tenacity of the Snapper ]
	{
		if ( !have_skill( sk ) ) continue;
		buffs[ buffs.count() ] = sk;
	}

	void maintain_buffs()
	{
		foreach i, sk in buffs
		{
			if ( have_effect( sk.to_effect() ) < 0 ) use_skill( 1, sk );
		}
	}
	maintain_buffs();

	// equip the best 2 handed club available
	//equip( $slot[ weapon ], $item[ none ] );
	//equip( $slot[ off-hand ], $item[ none ] );
	if ( !equip_2h_club() ) return vprint( "The script couldn't find a 2 handed club to equip for some reason.", -1 );

	// decide which mother level we want
	int wanted_mother_level = 10;
	while ( wanted_mother_level > 1 && hp_loss( wanted_mother_level ) > my_maxhp() )
	{
		wanted_mother_level -= 1;
	}
	if ( wanted_mother_level == 1 && hp_loss( wanted_mother_level ) >= my_maxhp() )
		return vprint( "You can't kill Mother Hellseals. You should probably get better HP and weapon damage buffs.", -1 );
	vprint( "You can kill level " + wanted_mother_level + " Mother Hellseals. Let's get the clubbing started.","green",4 );

	// choose familiar, make sure its equipment doesn't make it deal damage
	use_familiar( choose_potato() );
	safe_fam_equip();

	// acquire something to stasis with
	item stasis_item = choose_stasis();

	// noodle-LTS macro
	string macro;
	if ( have_skill( $skill[ entangling noodles ] ) && !is_onehitting( wanted_mother_level ) ) macro += "skill 3004;";
	macro += "skill 1005; repeat;";

	// track mother level
	int current_mother_level = 1;
	int parse_mother_level( string page )
	{
		matcher damage_matcher = create_matcher( "You lose (\\d[\\d,]*) hit points", page );
		if ( !damage_matcher.find() ) return current_mother_level;
		int damage = damage_matcher.group( 1 ).to_int();

		for i from 1 to 10
		{
			if ( damage > mother_damage( i ) ) continue;
			return i;
		}
		return current_mother_level;
	}

	string page;
	while ( my_adventures() > 0 )
	{
		maintain_buffs();
		if ( !restore_hp( hp_loss( wanted_mother_level ) ) )  return vprint( "Unable to heal... please configure Mafia's automatic HP restoring", -1 );
		if ( !restore_mp( 8 * num_LTS_needed( wanted_mother_level ) + 3 * to_int( !is_onehitting( wanted_mother_level ) ) ) ) return vprint( "Unable to restore MP... please configure Mafia's automatic MP restoring", -1 );

		// adventure at the Broodling Grounds
		print( "" );
		page = visit_url( "volcanoisland.php?action=tuba" );

		// Hellseal pup fight
		if ( page.contains_text( "hellseal pup" ) )
		{
			if ( current_mother_level < wanted_mother_level && make_pup_wail( stasis_item ) )
			{
				current_mother_level += 1;
				// finish fight
				visit_url( "fight.php?action=macro&macrotext=attack;repeat;" );
				continue;
			}
			// run away
			visit_url( "fight.php?action=runaway" );
			continue;
		}

		// We are fighting a mother. Deduce the level from the first hit.
		current_mother_level = parse_mother_level( page );
		vprint( "Level " + current_mother_level + " Mother Hellseal", "green", 6 );
		visit_url( "fight.php?action=macro&macrotext=" + macro );

		if ( gathered_hellseal_parts() && visit_url( "volcanoisland.php?action=npc" ).contains_text( "hellseal disguise" ) && item_amount( $item[ hellseal disguise ] ) > 0 )
			return vprint( "Hellseal disguise obtained.", 6 );

		if ( got_burst_hellseal_parts( old_burst_parts ) ) return vprint( "You got a burst hellseal part, there is a source of damage the script isn't aware of.", -1 );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

boolean nemesis_Seal_Clubber()
{
	if ( !get_hellseal_disguise() )
		return vprint( "Could not obtain the hellseal disguise.",-1 );

	// unlock the Lair
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	if ( visit_url( "volcanoisland.php?action=tniat" ).contains_text( "RIP AND TEAR" ) )
		return vprint( "Nemesis Lair unlocked!","green",2 );
	return vprint( "Something happened while unlocking the Nemesis Lair, exiting...",-1 );
}


//------------------//
//	Turtle Tamer	//	Thanks to Mr Purple @ kolmafia.us
//------------------//

// combat filter, needs to be at the top level
boolean tame_french( string page )
{
	// build combat macro
	string macro;
	if ( have_skill( $skill[ entangling noodles ] ) ) macro += "skill 3004; ";
	if ( last_monster() == $monster[ French Guard turtle ] )
	{
		vprint( "Ze turtle, it is française!", "green", 4 );
		macro += "skill 7083; ";
	}
	else
	{
		macro += "attack; ";
	}
	macro += "repeat;";
	page = visit_url( "fight.php?action=macro&macrotext=" + macro );

	return page.contains_text( "escort it out of the compound" );
}

boolean free_turtles()
{
	// visit the NPC and parse for the number of turtles left to save
	int turtles_left;
	string npc = visit_url( "volcanoisland.php?action=npc" );
	matcher turtlesleft = create_matcher( "Just (\\d) more" , npc );
	if ( turtlesleft.find() ) turtles_left = turtlesleft.group( 1 ).to_int() ;
	else if ( npc.contains_text( "I am discovaired" ) ) turtles_left = 6;
	else if ( npc.contains_text( "returning my hard-shelled friends" ) ) turtles_left = 6;
	else if ( npc.contains_text( "the remainder of them" ) ) turtles_left = 5;
	else if ( npc.contains_text( "swings open" ) ) turtles_left = 0;
	else if ( npc.contains_text( "practice their backflips" ) ) turtles_left = 0;
	else return vprint( "Something happened while parsing the NPC text, the number of turtles left to free wasn't determined.", -1 );

	if ( turtles_left == 0 ) return vprint( "You already freed the turtles", 6 );
	if ( available_amount( $item[ Fouet de tortue-dressage ] ) == 0 ) return vprint( "Something happened, you don't have a Fouet de tortue-dressage.", -1 );
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Freeing the turtles...", "green", 4 );

	cli_execute ( "mood execute" );
	if ( my_buffedstat( $stat[ muscle ] ) < ( 150 + monster_level_adjustment() ) )
		maximize( "muscle -weapon -familiar -tie", false );
	equip( $item[ Fouet de tortue-dressage ] );
	use_familiar( best_fam("delevel") );
	safe_fam_equip();
	cli_execute( "conditions clear" );

	while ( my_adventures() > 0 )
	{
		restore_hp( 0 );
		if ( my_mp() < 20 && !restore_mp( 20 ) ) return vprint( "Out of MP, exiting... please configure Mafia's automatic MP restoring",-1 );
		cli_execute ( "mood execute" );
		print( "" );
		boolean tamed = visit_url( "volcanoisland.php?action=tuba" ).tame_french();
		if ( tamed ) turtles_left -= 1;
		vprint( ( 6 - turtles_left ) + "/6 turtles tamed", "green", 4 );
		if ( turtles_left == 0 ) return vprint( "Turtles freed.", 6 );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

boolean nemesis_Turtle_Tamer()
{
	// free turtles
	if ( !free_turtles() )
		return vprint( "Could not free all the turtles.",-1 );

	// unlock the Lair
	string npc = visit_url( "volcanoisland.php?action=npc" );
	if (	npc.contains_text( "compound swings open" )
		||	npc.contains_text( "practice their backflips" ) )
	{
		return vprint( "Nemesis Lair unlocked!","green",1 );
	}
	return vprint( "Something happened while unlocking the Nemesis Lair, exiting...",-1 );
}


//------------------//
//	Pastamancer		//   Thanks to Mr Purple @ kolmafia.us
//------------------//

string orb_look()
{
	if ( item_amount( $item[ crystal orb of spirit wrangling ] ) == 0 ) return "none";
	string orb_text = visit_url( "inv_use.php?whichitem=4295&action=look&ajax=1&pwd=" + my_hash(), false );
	if ( orb_text.contains_text( "don't see" ) )
		return "none" ;
	if ( orb_text.contains_text( "Spaghetti Elemental" ) )
		return "Spaghetti Elemental" ;
	return "other" ;
}

boolean get_decoded_doc()
{
	if ( item_amount( $item[ decoded cult documents ] ) > 0 ) return vprint( "You already have the decoded cult documents.", 6 );
	if ( item_amount( $item[ encoded cult documents ] ) < 1 && !visit_url( "volcanoisland.php?action=npc" ).contains_text( "important cult documents") )
		return vprint( "Could not obtain the encoded cult documents from the volcano NPC.",-1 );
	if ( item_amount( $item[ cult memo ] ) == 5 )
		return ( use( 1, $item[ cult memo ] ) && item_amount( $item[ decoded cult documents ] ) > 0 );
	vprint( "Obtaining cult memos...","green",2 );

	// farm 5 cult memos
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	cli_execute ( "mood execute" );
	if ( my_buffedstat( $stat[ moxie ] ) < ( 155 + monster_level_adjustment() ) )
		maximize( "item, moxie, -melee, -ML, -familiar -tie", false );
	use_familiar( best_fam("item") );
	cli_execute( "conditions clear" );

	while ( my_adventures() > 0 )
	{
		if ( item_amount( $item[ cult memo ] ) == 5 )
			return ( use( 1, $item[ cult memo ] ) && item_amount( $item[ decoded cult documents ] ) > 0 );

		adventure( 1 ,$location[ The Temple Portico ] );
		vprint( item_amount( $item[ cult memo ] ) + "/5 memos obtained", "green", 4 );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

boolean get_spaghetti()
{
	if ( !get_decoded_doc() ) return vprint( "Could not obtain the decoded cult documents.",-1 );
	vprint( "Making sure the Spaghetti Elemental is our guardian...","green",2 );

	record { string player; string orb; } guardian;
	guardian.player=my_thrall().to_string();
	/*guardian.orb = orb_look();

	if ( item_amount( $item[ crystal orb of spirit wrangling ] ) > 0 )
	{
		use( 1 , $item[ crystal orb of spirit wrangling ] );
		guardian.player = guardian.orb;
		guardian.orb = orb_look();
	}*/

	// if we have a Spaghetti Elemental with us
	if ( guardian.player == "Spaghetti Elemental" ) return true;

	// if we have a Spaghetti Elemental in the Orb
	if ( guardian.orb == "Spaghetti Elemental" ) return use( 1 , $item[ crystal orb of spirit wrangling ] );

	// if we have a guardian with us and in the Orb, let the user decide which one to discard
	if ( guardian.player == "other" && guardian.orb == "other" )
		return vprint( "You have a Pasta Guardian with you and a Pasta Guardian in the Crystal orb of spirit wrangling. Please take the one you wish to discard out and use the decoded cult documents before running the script again.", -1);

	// if we have a guardian with us and the Orb is empty, store it before creating a link with the Spaghetti Elemental
	if ( guardian.player == "other" ) use( 1 , $item[ crystal orb of spirit wrangling ] );

	// if we don't have a guardian with us or if we don't have an Orb, create a link with the Spaghetti Elemental
	return use( 1 , $item[ decoded cult documents ] );
}


boolean get_cult_robe()
{
	if ( available_amount( $item[ spaghetti cult robe ] ) > 0 ) return vprint( "You already have the spaghetti cult robe.", 6 );
	vprint( "Obtaining a spaghetti cult robe...","green",2 );

	// Level up your Spaghetti Elemental and obtain the spaghetti cult robe
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	cli_execute ( "mood execute" );
	if ( my_buffedstat( $stat[ moxie ] ) < ( 155 + monster_level_adjustment() ) )
		maximize( "item, moxie, -ML, -familiar -tie", false );
	use_familiar( previous_familiar );
	cli_execute( "conditions clear" );

	int ghost_level;
	string ghost_type = "Spaghetti Elemental";
	boolean out_of_summons ;

	while ( my_adventures() > 0 )
	{
		if ( available_amount( $item[ spaghetti cult robe ] ) > 0 ) return vprint( "Spaghetti cult robe obtained.", 6 );
		if ( out_of_summons ) return vprint( "Out of Guardian summons for the day, re-run this script tomorrow.", -1 );
		if ( ghost_type != "Spaghetti Elemental" ) return vprint( "For some reason, you don't have a Spaghetti Elemental as your Guardian. Exiting...", -1 );

		restore_hp( 0 );
		restore_mp( 0 );

		// visit the Temple Portico
		print( "" );
		string response = visit_url( "volcanoisland.php?action=tuba" );

		if ( !response.contains_text( "Combat" ) ) continue;

		matcher ghost_matcher = create_matcher( "value=\"Summon (?:\\w+) the Level (\\d+) (.+?)\">", response );
		if ( !ghost_matcher.find() )
		{
			out_of_summons = true ;
		}
		else
		{
			ghost_level = ghost_matcher.group( 1 ).to_int() ;
			ghost_type  = ghost_matcher.group( 2 ) ;
		}

		if ( !out_of_summons ) response = visit_url("fight.php?action=summon");
		if ( response.contains_text( "looks stronger" ) ) ghost_level += 1 ;
		run_combat();

		vprint( "Your " + ghost_type + " is level " + ghost_level, "green", 4 );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

boolean nemesis_Pastamancer()
{
	if ( visit_url( "volcanoisland.php?action=npc" ).contains_text( "Sounds like you finally got inside, eh" ) )
		return vprint( "Nemesis Lair already unlocked.", 6 );

	// get a Spaghetti Elemental
	if ( !get_spaghetti() )
		return vprint( "Unable to establish a link with a Spaghetti Elemental.",-1 );

	// get a spaghetti cult robe
	if ( !get_cult_robe() )
		return vprint( "Unable to obtain a spaghetti cult robe.",-1 );

	// unlock the Lair
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	equip( $item[ spaghetti cult robe ] );
	if ( visit_url( "volcanoisland.php?action=tniat" ).contains_text( "the hood of your robe" ) )
		return vprint( "Nemesis Lair unlocked!","green",2 );
	return vprint( "Something happened while unlocking the Nemesis Lair, exiting...",-1 );
}


//------------------//
//	Sauceror		//
//------------------//

boolean get_slimeform()
{
	if ( have_effect( $effect[ slimeform ] ) > 0 ) return vprint( "You already have the slimeform effect.",6 );
	vprint( "Obtaining the slimeform effect...","green",2 );

	boolean[item] tertiary = $items[
		vial of vermilion slime, vial of amber slime, vial of chartreuse slime,
		vial of teal slime, vial of purple slime, vial of indigo slime,
	];

	// check if the vial that gives slimeform is known:
	item slime_vial = $item[ none ];
	foreach ter in tertiary
		if ( get_property( "lastSlimeVial"+ter.to_int() ) == "slimeform" )
			slime_vial = ter;
	if ( slime_vial != $item[ none ] && retrieve_item( 1, slime_vial ) )
		return use( 1,slime_vial );

	// farm vials until we get the slimeform effect
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	cli_execute ( "mood execute" );
	if ( my_buffedstat( $stat[ moxie ] ) < ( 155 + monster_level_adjustment() ) )
		maximize( "moxie, -ML, -familiar -tie", false );
	use_familiar( best_fam("delevel") );
	safe_fam_equip();
	set_property( "battleAction", "item bottle of Gone" );
	set_property( "autoEntangle", "true" );
	cli_execute( "conditions clear" );

	if ( !test_combat( $location[Convention Hall Lobby], false ) )
		return vprint( "Please buff our Moxie to " + ( 155 + monster_level_adjustment() ), -1 );

	while ( my_adventures() > 0 )
	{
		// if you know which potion gives slimeform, check if you can make one
		foreach ter in tertiary
			if ( get_property( "lastSlimeVial"+ter.to_int() ) == "slimeform" )
				slime_vial = ter;

		if ( slime_vial != $item[ none ] && retrieve_item( 1, slime_vial ) )
		{
			return use( 1,slime_vial );
		}
		else // check if a new tertiary vial can be made
		{
			foreach ter in tertiary
			{
				if ( get_property( "lastSlimeVial"+ter.to_int() ) == "" && creatable_amount( ter ) > 0 )
				{
					if( !create( 1,ter ) ) return vprint( "Mafia won't craft the vials, please check if you have chef...",-1 );
					use( 1,ter );
					if ( have_effect( $effect[ slimeform ] ) > 0 ) return vprint( "Slimeform effect obtained",6 );
				}
			}
		}
		// get a primary color vial
		adventure( 1,$location[Convention Hall Lobby] );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

boolean nemesis_sauceror()
{
	// get slimeform
	if ( !get_slimeform() )
		return vprint( "Could not obtain the slimeform effect.",-1 );

	// grab the convention bag
	visit_url( "volcanoisland.php?action=tuba" );

	// unlock the Lair
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	if ( visit_url( "volcanoisland.php?action=tniat" ).contains_text( "wobble up" ) )
		return vprint( "Nemesis Lair unlocked!","green",2 );
	return vprint( "Something happened while unlocking the Nemesis Lair, exiting...",-1 );
}


//------------------//
//	Disco Bandit	//
//------------------//

int num_rave_skills_known()
{
	int num = 0 ;
	foreach sk in $skills[ Break It On Down, Pop and Lock It, Run Like the Wind ]
		if ( have_skill( sk ) ) num += 1 ;
	return num ;
}

int num_combos_known()
{
	int num = 0 ;
	if ( get_property( "lastNemesisReset" ) != get_property("knownAscensions") ) return num;
	for i from 1 to 6
		if ( get_property( "raveCombo" + i ) != "" ) num += 1;
	return num ;
}

boolean combo_identified()
{
	if ( get_property( "lastNemesisReset" ) != get_property("knownAscensions") ) return false;
	if ( get_property( "raveCombo5" ) != "" ) return true;
	return false;
}

/*
boolean identify_combo()
{
	if ( get_property( "lastNemesisReset" ) != get_property("knownAscensions") ) return false;
	if ( get_property( "raveCombo5" ) != "" ) return true;
	if ( num_combos_known() < 5 ) return false;

	// 5/6 Rave combos have been identified, the last one is Rave Steal
	vprint( "Identifying last Rave combo", "green", 4 );
	string [ int ] rave_possible;
	rave_possible[ 1 ] = "Break It On Down,Pop and Lock It,Run Like the Wind";
	rave_possible[ 2 ] = "Break It On Down,Run Like the Wind,Pop and Lock It";
	rave_possible[ 3 ] = "Pop and Lock It,Break It On Down,Run Like the Wind";
	rave_possible[ 4 ] = "Pop and Lock It,Run Like the Wind,Break It On Down";
	rave_possible[ 5 ] = "Run Like the Wind,Pop and Lock It,Break It On Down";
	rave_possible[ 6 ] = "Run Like the Wind,Break It On Down,Pop and Lock It";

	for i from 1 to 6
	{
		boolean known = false;
		for j from 1 to 6
		{
			if ( get_property( "raveCombo" + j ) == rave_possible[ i ] )
			{
				known = true ;
				break;
			}
		}
		if ( !known )
		{
			set_property( "raveCombo5", rave_possible[ i ] );
			break;
		}
	}
	return true;
}
*/

/*
boolean check_raveosity()
{
	int raveosity ;
	int [ item ] rave_items ;
	rave_items[ $item[ rave visor ] ] = 2 ;
	rave_items[ $item[ baggy rave pants ] ] = 2 ;
	rave_items[ $item[ pacifier necklace ] ] = 2 ;
	rave_items[ $item[ teddybear backpack ] ] = 1 ;
	rave_items[ $item[ glowstick on a string ] ] = 1 ;
	rave_items[ $item[ candy necklace ] ] = 1 ;
	rave_items[ $item[ rave whistle ] ] = 1 ;

	foreach it, rav in rave_items
		if ( item_amount( it ) > 0 || equipped_amount( it ) > 0 ) raveosity += rav ;

	vprint( raveosity + "/7 raveosity possible","green",4 );
	if ( raveosity < 6 ) return false;
	return true;
}

boolean equip_raveosity()
{

	int raveosity ;
	int [ item ] rave_items ;
	rave_items[ $item[ rave visor ] ] = 2 ;
	rave_items[ $item[ baggy rave pants ] ] = 2 ;
	rave_items[ $item[ pacifier necklace ] ] = 2 ;
	rave_items[ $item[ teddybear backpack ] ] = 1 ;
	rave_items[ $item[ glowstick on a string ] ] = 1 ;
	rave_items[ $item[ candy necklace ] ] = 1 ;
	rave_items[ $item[ rave whistle ] ] = 1 ;

	foreach it, rav in rave_items
		if ( item_amount( it ) > 0 || equipped_amount( it ) > 0 ) raveosity += rav ;

	vprint( raveosity + "/7 raveosity possible","green",4 );
	if ( raveosity < 6 ) return false;

	foreach it in rave_items
	{
		if ( item_amount( it ) > 0 && equipped_amount( it ) == 0 )
		{
			if ( it == $item[ glowstick on a string ] && equipped_item( $slot[ weapon ] ).weapon_hands() > 1 )
				equip( $slot[ weapon ], $item[ none ] );
			equip( it );
		}
	}
	return ( numeric_modifier( "Raveosity" ) >= 7.0 );
}
*/

boolean check_raveosity()
{
	return maximize( "7 raveosity -tie -familiar", true );
}

boolean equip_raveosity()
{
	return maximize( "7 raveosity -tie -familiar", false );
}

boolean learn_rave_skills()
{
	if ( num_rave_skills_known() == 3 ) return vprint( "You have already learned the Rave skills.",6 );
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Learning the Rave skills...","green",2 );

	// adventure outside the club to learn the Rave moves
	cli_execute ( "mood execute" );

	if ( have_equipped( $item[ Space Trip safety headphones ] ) || my_buffedstat( $stat[ moxie ] ) < ( 155 + monster_level_adjustment() ) )
		maximize( "moxie, -melee, -ML, -equip safety headphones, -familiar, -tie", false );
	// use_familiar( best_fam("delevel") );
	safe_fam_equip();
	set_property( "autoEntangle","false" );
	cli_execute( "conditions clear" );

	// use (a slightly tweaked version of) Royaltonberry's gothy_handwave.balls KoL macro
	string macro = "pickpocket; ";	// dummy action that KoL will execute before starting the combat
	macro += "while !pastround 28;";
	macro += 	"if monstername breakdancing raver && !hasskill 50;";
	macro += 		"if match \"raver drops to the ground\";";
	macro += 			"skill 49;";
	macro += 			"goto __endwhile0;";
	macro += 		"endif;";
	macro += 		"goto __endif2;";
	macro += 	"endif;";
	macro += 	"if monstername pop-and-lock raver && !hasskill 51;";
	macro += 		"if match \"spastic and jerky\";";
	macro += 			"skill 49;";
	macro += 			"goto __endwhile0;";
	macro += 		"endif;";
	macro += 		"goto __endif2;";
	macro += 	"endif;";
	macro += 	"if monstername running man && !hasskill 52;";
	macro += 		"if match \"raver turns and runs away\" || match \"raver turns around and flees\";";
	macro += 			"skill 49;";
	macro += 			"goto __endwhile0;";
	macro += 		"endif;";
	macro += 		"goto __endif2;";
	macro += 	"endif;";
	macro += 	"goto __endwhile0;";
	macro += 	"mark __endif2;";
	macro += 	"skill 5021;";
	macro += "endwhile;";
	macro += "mark __endwhile0;";
	macro += "attack;";
	macro += "repeat";

	while ( my_adventures() > 0 )
	{
		if ( my_mp() < 5 && !restore_mp( 5 ) ) return vprint( "Out of MP, exiting... please configure Mafia's automatic MP restoring",-1 );
		adventure( 1 ,$location[ Outside the Club ], macro );
		vprint( num_rave_skills_known() + "/3 moves learned", "green", 4 );
		if ( num_rave_skills_known() == 3 ) return vprint( "Rave skills learned.",6 );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

// combat filter, needs to be at the top level
string randrave( int rnd, string opp, string text )
{
	if ( combo_identified() ) return "combo Rave Steal";
	return "combo Random Rave";
}

boolean learn2combo()
{
	if ( num_rave_skills_known() < 3 ) return vprint( "You have not learned all the Rave skills, exiting...",-1 );
	if ( get_property( "raveCombo5" ) != "" && get_property( "lastNemesisReset" ) == get_property( "knownAscensions" ) )
		return vprint( "Rave Steal combo already identified.",6 );
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Testing combos...","green",2 );

	// adventure outside the club until you identify Rave Steal
	cli_execute ( "mood execute" );
	if ( have_equipped( $item[ Space Trip safety headphones ] ) || my_buffedstat( $stat[ moxie ] ) < ( 155 + monster_level_adjustment() ) )
		maximize( "moxie, -melee, -ML, -equip safety headphones, -familiar -tie", false );
	// use_familiar( best_fam( "delevel" ) );
	safe_fam_equip();
	set_property( "autoEntangle", "false" );
	cli_execute( "conditions clear" );

	while ( my_adventures() > 0 )
	{
		if ( my_mp() < 20 && !restore_mp( 20 ) ) return vprint( "Out of MP, exiting... please configure Mafia's automatic MP restoring",-1 );
		vprint( num_combos_known() + "/6 combos known","green", 4 );
		adventure( 1 ,$location[ Outside the Club ], "randrave" );
		//if ( identify_combo() ) return vprint( "Rave Steal combo identified.",6 );
		if ( combo_identified() ) return vprint( "Rave Steal combo identified.",6 );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

/*
// combat filter, needs to be at the top level
string ravesteal( int rnd, string opp, string text )
{
	string [int ] combo;
	matcher rave_steal = create_matcher( "(.+),(.+),(.+)", get_property( "raveCombo5" ) );
    rave_steal.find();
	for i from 1 to 3 combo[ i ] = rave_steal.group( i ) ;
	if ( rnd == 0 ) return "steal";
	if ( rnd < 4  ) return combo[ rnd ];
	return "attack";
}
*/

boolean get_raveosity()
{
	if ( get_property( "raveCombo5" ) == "" || get_property( "lastNemesisReset" ) != get_property( "knownAscensions" ) )
		return vprint( "You have not identified the Rave Steal combo, exiting...",-1 );
	if ( check_raveosity() ) return vprint( "Enough Raveosity items gathered.",6 );
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Gathering Raveosity items...","green",2 );

	// adventure outside the club using Rave Steal until you get enough Raveosity items
	cli_execute ( "mood execute" );
	if ( have_equipped( $item[ Space Trip safety headphones ] ) || my_buffedstat( $stat[ moxie ] ) < ( 155 + monster_level_adjustment() ) )
		maximize( "moxie, -melee, -ML, -equip safety headphones, -familiar -tie", false );
	// use_familiar( best_fam( "delevel" ) );
	safe_fam_equip();
	set_property( "autoEntangle","false" );
	cli_execute( "conditions clear" );

	string macro = "pickpocket; ";	// dummy action that KoL will execute before starting the combat
	matcher rave_steal = create_matcher( "(.+),(.+),(.+)", get_property( "raveCombo5" ) );
	if ( !rave_steal.find() ) return vprint( "I can't understand the raveCombo5 property: " + get_property( "raveCombo5" ),-1 );
	for i from 1 to 3 macro += "skill " + rave_steal.group( i ).to_skill().to_int() +"; ";
	macro += "attack; repeat;";

	while ( my_adventures() > 0 )
	{
		if ( my_mp() < 10 && !restore_mp( 10 ) ) return vprint( "Out of MP, exiting... please configure Mafia's automatic MP restoring",-1 );
		adventure( 1 ,$location[ Outside the Club ], macro );
		//adventure( 1 ,$location[ Outside the Club ], "ravesteal" );
		if ( check_raveosity() ) return vprint( "Enough Raveosity items gathered.",6 );

	}
	return vprint( "Out of adventures, exiting...",-1 );
}


boolean nemesis_Disco_Bandit()
{
	// learn Rave Combos
	if ( !learn_rave_skills() ) return vprint( "The Rave Moves were not learned.",-1 );

	// identify the Rave Steal combo
	if ( !learn2combo() ) return vprint( "The Rave Steal combo was not identified.",-1 );

	// gather Raveosity items
	if ( !get_raveosity() ) return vprint( "Unable to gather enough Raveosity.",-1 );

	// equip Raveosity items
	if ( !equip_raveosity() ) return vprint( "Something happened while equiping Raveosity items.",-1 );

	// unlock the Lair
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	visit_url( "volcanoisland.php?action=tniat" );
	if ( visit_url( "volcanoisland.php?action=tniat&action2=try" ).contains_text( "opens the door" ) )
		return vprint( "Nemesis Lair unlocked!","green",2 );
	return vprint( "Something happened while unlocking the Nemesis Lair, exiting...",-1 );
}


//------------------//
//	Accordion Thief	//
//------------------//

item hkey = $item[ hacienda key ] ;

string to_string_result( int i )
{
	switch( i )
	{
		case 1: return "nothing";
		case 2: return "special";
		case 3: return "combat_no_key";
		case 4: return "combat_key";
	}
	return "" ;
}

int to_int_result( string res )
{
	switch( res )
	{
		case "nothing":			return 1 ;
		case "special":			return 2 ;
		case "combat_no_key":	return 3 ;
		case "combat_key":		return 4 ;
	}
	return 0 ;
}

int get_current_adv( string html )
{
	matcher adv = create_matcher( "name=whichchoice value=(\\d+)", html );
	if ( adv.find() ) return adv.group( 1 ).to_int() ;
	//adv = create_matcher( "(?i)you sneak (?:around|back)", html );
	//if ( adv.find() ) return 409 ;
	vprint( "Problem encountered while naviguating the Barracks: encountered an unexpected adventure", -1 );
	vprint( "Please type 'zlib verbosity = 10' in the gCLI, naviguate out of the current adventure, and try again so you can post the details.", 0 );
	return 0 ;
}

boolean get_keys()
{
	if ( item_amount( hkey ) == 5 ) return vprint( "You already have the Hacienda keys.",6 );
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	vprint( "Obtaining Hacienda keys...","green",2 );

	int loc ;

	// create an array that contains the choices
	record { int [ int ] choices; } [ int ] barrack ;

	// Choice 409 is The Island Barracks: 1 = only option
	barrack[ 409 ].choices[ 1 ] = 410 ;

	// Choice 410 is A Short Hallway: 1 = left, 2 = right, 3 = exit
	barrack[ 410 ].choices[ 1 ] = 411 ;
	barrack[ 410 ].choices[ 2 ] = 412 ;
	barrack[ 410 ].choices[ 3 ] = 0 ;

	// Choice 411 is Hallway Left: 1 = kitchen, 2 = dining room, 3 = storeroom, 4 = exit
	barrack[ 411 ].choices[ 1 ] = 413 ;
	barrack[ 411 ].choices[ 2 ] = 414;
	barrack[ 411 ].choices[ 3 ] = 415 ;

	// Choice 412 is Hallway Right: 1 = bedroom, 2 = library, 3 = parlour, 4 = exit
	barrack[ 412 ].choices[ 1 ] = 416 ;
	barrack[ 412 ].choices[ 2 ] = 417;
	barrack[ 412 ].choices[ 3 ] = 418 ;

	// Choice 413 is Kitchen: 		1  = cupboards		2  = pantry 	3  = fridges
	// Choice 414 is Dining Room: 	4  = tables			5  = sideboard	6  = china cabinet
	// Choice 415 is Store Room: 	7  = crates			8  = workbench	9  = gun cabinet
	// Choice 416 is Bedroom: 		10 = beds			11 = dressers	12 = bathroom
	// Choice 417 is Library: 		13 = bookshelves	14 = chairs		15 = chess set
	// Choice 418 is Parlour: 		16 = pool table		17 = bar		18 = fireplace
	for i from 413 to 418
		for j from 1 to 3
			barrack[ i ].choices[ j ] = 3 * ( i - 413 ) + j ;

	// create an array that contains the locations and their results
	// 0 = unknown, 1 = nothing, 2 = special (key or hint), 3 = combat ( key not obtained ), 4 = combat ( key obtained )
	record {
		boolean visited;
		int result;
	}  [ int ] locations ;

	for i from 1 to 18
	{
		locations[ i ].visited = get_property( "nemesis_AT_" + i + "_visited" ).to_boolean() ;
		locations[ i ].result  = get_property( "nemesis_AT_" + i + "_result" ).to_int_result() ;
	}

	// track how many keys have been obtained from special locations
	int num_NC_keys = get_property( "nemesis_AT_noncombat_keys" ).to_int() ;

	// array containing hints and the corresponding locations
	string [ int ] hints;
	hints[ 1 ]  = "a potato peeler" ;
	hints[ 2 ]  = "an empty sardine can" ;
	hints[ 3 ]  = "an apple core" ;
	hints[ 4 ]  = "a silver pepper-mill" ;
	hints[ 5 ]  = "the lid from a can of sterno" ;
	hints[ 6 ]  = "an empty teacup" ;
	hints[ 7 ]  = "a small crowbar" ;
	hints[ 8 ]  = "a pair of needle-nose pliers" ;
	hints[ 9 ]  = "an empty rifle cartridge" ;
	hints[ 10 ] = "a long nightcap with a pom-pom on the end" ;
	hints[ 11 ] = "a dirty sock" ;
	hints[ 12 ] = "a toothbrust" ;

	// local functions
	int has_hint( string text )
	{
		foreach place, hint in hints
			if ( text.contains_text( hint ) ) return place ;
		return 0 ;
	}

	int get_parent( int adv )
	{
		foreach b in barrack
			foreach choice, child in barrack[ b ].choices
				if ( child == adv ) return b ;
		return -1 ;
	}

	int get_choice( int adv )
	{
		if ( get_parent( adv ) == -1 ) return -1;
		foreach choice, child in barrack[ get_parent( adv ) ].choices
			if ( child == adv ) return choice ;
		return 0 ;
	}

	string print_loc( int i )
	{
		return "location " + i + " - parent: " + get_parent( i ) + ", visited: " + locations[ i ].visited + ", result: " + to_string_result( locations[ i ].result ) ;
	}

	void print_locs()
	{
		for i from 1 to 18 vprint( print_loc( i ), 10 );
	}

	void update_loc( int i )
	{
		if ( locations[ i ].result == 0 )
		{
			// check if the other locations in the room are known
			boolean room_nothing ;
			boolean room_special ;
			boolean room_combat ;
			foreach n, j in barrack[ get_parent( i ) ].choices
			{
				if ( j == i ) continue ;
				if ( locations[ j ].result == 1 ) room_nothing = true ;
				if ( locations[ j ].result == 2 ) room_special  = true ;
				if ( locations[ j ].result >= 3 ) room_combat = true ;
			}
			if ( room_special && room_combat  ) locations[ i ].result = 1 ;
			if ( room_combat  && room_nothing ) locations[ i ].result = 2 ;
			if ( room_special && room_nothing ) locations[ i ].result = 3 ;
		}
		vprint( print_loc( i ), 10 );
		set_property( "nemesis_AT_" + i + "_visited", locations[ i ].visited );
		set_property( "nemesis_AT_" + i + "_result" , locations[ i ].result.to_string_result() );
	}

	void update_locs()
	{
		foreach i in locations update_loc( i ) ;
		set_property( "nemesis_AT_noncombat_keys", num_NC_keys ) ;
	}

	boolean skip_loc( int i )
	{
		// if we already know what is in the location, skip exploring
		if ( locations[ i ].result > 0 ) return true ;

		// if we already found a special location in that room, skip exploring
		foreach n, j in barrack[ get_parent( i ) ].choices
		{
			if ( locations[ j ].result == 2 ) return true ;
		}

		// explore away
		return false ;
	}

	int choose_loc()
	{
		// if we already obtained 4 keys from the Barracks, skip exploring
		if ( num_NC_keys == 4 )
		{
			vprint( "We have already found 4 keys in the Barracks, leaving.", -4 );
			return 0;
		}

		// if we received a hint, go there directly
		foreach i in locations
			if ( locations[ i ].result == 2 && !locations[ i ].visited  ) return i ;

		// go to the first unknown location in a room where no special location has been found
		foreach i in locations
			if ( !skip_loc( i ) ) return i ;

		// try to pickpocket a key from a mariachi
		foreach i in locations
			if ( locations[ i ].result == 3 ) return i ;

		// explore more to find more mariachis to pickpocket (or if part of the barracks where visited outside the script).
		foreach i in locations
			if ( locations[ i ].result == 0 ) return i ;

		// everything was visited, leave the adventure
		vprint( "Everything was visited, leaving the Barracks", -4 );
		return 0 ;
	}

	string naviguate_barrack( string html, int goal )
	{
		if ( get_parent( goal ) == -1 ) vprint( "Problem encountered while naviguating the Barracks: location " + goal + " does not have a parent.", 0 );
		if ( get_choice( goal ) == 0  ) vprint( "Problem encountered while naviguating the Barracks: parent " + get_parent( goal ) + " does not have a choice for location " + goal + ".", 0 );

		if ( get_parent( goal ) != get_current_adv( html ) )
			html = naviguate_barrack( html, get_parent( goal ) );

		vprint( "Navigating to adventure " + goal + ". Current adventure: " + get_current_adv( html ) + ", choosing option " + get_choice( goal ) + ".", 10 );
		return visit_url( "choice.php?whichchoice=" + get_current_adv( html ) + "&option=" + get_choice( goal ) );
	}

	// maximize initiative and set mafia to pickpocket then runaway
	use( item_amount( $item[ fisherman's sack ] ), $item[ fisherman's sack ] );
	maximize( "initiative, -1000 combat, -familiar -tie", false );
	set_property( "autoSteal", "true" );
	set_property( "battleAction","try to run away" );
	if ( have_familiar( $familiar[ Frumious Bandersnatch ] ) && !is100run ) use_familiar( $familiar[ Frumious Bandersnatch ] );
	cli_execute( "conditions clear" );

	update_locs();

	while ( my_adventures() > 0 )
	{
		// crude mood maintenance
		if ( my_hp() < 1 && !restore_hp( 1 ) ) return vprint( "Unable to heal... please configure Mafia's automatic HP restoring", -1 );
		// runaways
		if ( my_familiar() ==  $familiar[ Frumious Bandersnatch ] && get_property( "_banderRunaways" ).to_int() < floor( numeric_modifier( "Familiar Weight" ) + familiar_weight( $familiar[ Frumious Bandersnatch ] ) ) / 5 && have_effect( $effect[ Ode to Booze ] ) == 0 && have_skill( $skill[ The Ode to Booze ] ) && current_at() < max_at() )
			use_skill( 1, $skill[ The Ode to Booze ] );
		// init
		if ( have_effect( $effect[ Springy Fusilli ] ) == 0 && have_skill( $skill[ Springy Fusilli ] ) )
			use_skill( 1, $skill[ Springy Fusilli ] );
		if ( have_effect( $effect[ Fishily Speeding ] ) == 0 && item_amount( $item[ potion of fishy speed ] ) > 0 )
			use( 1, $item[ potion of fishy speed ] );
		// NC
		if ( have_effect( $effect[ The Sonata of Sneakiness ] ) == 0 && have_skill( $skill[ The Sonata of Sneakiness ] ) && current_at() < max_at() )
			use_skill( 1, $skill[ The Sonata of Sneakiness ] );
		if ( have_effect( $effect[ Smooth Movements ] ) == 0 && have_skill( $skill[ Smooth Movement ] ) )
			use_skill( 1, $skill[ Smooth Movement ] );
		if ( have_effect( $effect[ Inky Camouflage ] ) == 0 && item_amount( $item[ vial of squid ink ] ) > 0 )
			use( 1, $item[ vial of squid ink ] );

		// visit The Barracks
		print( "" );
		string response = visit_url( "volcanoisland.php?action=tuba" );

		// check if we are in a combat
		if ( response.contains_text( "Combat" ) )
		{
			run_combat() ;
			vprint( item_amount( hkey ) + "/5 Hacienda keys obtained","green",4 );
			if ( item_amount( hkey ) == 5 ) return vprint( "Hacienda keys obtained",6 );
			continue ;
		}

		// visit a location
		int num_hkeys = item_amount( hkey );
		loc = choose_loc() ;
		vprint( "Visiting location " + loc + "...", 10 );
		response = naviguate_barrack( response, loc );

		if ( response.contains_text( "you sneak back out" ) )
		{
			// we exited the adventure
		}
		else if ( response.contains_text( "Fight!" ) )
		{
			locations[ loc ].visited = true;
			if ( locations[ loc ].result < 3 ) locations[ loc ].result = 3;

			run_combat() ;

			if ( item_amount( hkey ) > num_hkeys ) locations[ loc ].result = 4;
		}
		else
		{
			locations[ loc ].visited  = true; 
			if ( item_amount( hkey ) > num_hkeys )
			{
				locations[ loc ].result = 2;
				num_NC_keys += 1 ;
			}
			else if ( has_hint( response ) > 0 )
			{
				locations[ loc ].result = 2;
				int place = has_hint( response ) ;
				vprint( "Hint found in location " + loc + ", location " + place + " has a key.", "green", 6 ) ;
				if ( locations[ place ].result == 0 ) locations[ place ].result = 2;
				if ( locations[ place ].result != 2 ) vprint( "The hint '" + hints[ place ] + "' was found in location " + loc + ", but the location " + place + " was visited and did not contain a key.", -1 ) ;
			}
			if ( locations[ loc ].result != 2 ) locations[ loc ].result = 1;
		}

		update_locs();

		vprint( item_amount( hkey ) + "/5 Hacienda keys obtained","green",4 );
		if ( item_amount( hkey ) == 5 ) return vprint( "Hacienda keys obtained",6 );
	}
	return vprint( "Out of adventures, exiting...",-1 );
}

boolean nemesis_Accordion_Thief()
{
	if ( get_property( "nemesis_AT_lastReset" ) != get_property( "knownAscensions" ) )
	{
		for i from 1 to 18
		{
			set_property( "nemesis_AT_" + i + "_visited", "" );
			set_property( "nemesis_AT_" + i + "_result", "" );
		}
		set_property( "nemesis_AT_noncombat_keys", "0" ) ;
		set_property( "nemesis_AT_lastReset", get_property( "knownAscensions" ) );
	}

	// get Hacienda keys
	if ( !get_keys() ) return vprint( "Failed to gather the Hacienda keys.",-1 );

	// unlock the Lair
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	if ( visit_url( "volcanoisland.php?action=tniat" ).contains_text( "unlock the front door" ) )
		return vprint( "Nemesis Lair unlocked!","green",2 );
	return vprint( "Something happened while unlocking the Nemesis Lair, exiting...",-1 );
}


//------------------//
//	 All Classes	//
//------------------//

boolean openLair()
{
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	if ( visit_url( "volcanoisland.php?pwd&action=npc" ).contains_text( "There's no island out there." ) )
		return vprint( "Somehow, the Volcano Island is not accessible!",-1 );

	// visit the lair to check if it's unlocked
	restore_settings( false );
	restore_hp( 0 );
	restore_mp( 0 );

	boolean unlocked = false ;
	boolean retry;

	repeat
	{
		retry = false;
		print( "" );
		string response = visit_url( "volcanoisland.php?action=tniat" );

		// DBs can get a choice from the bouncer
		if ( contains_text( response , "bouncer" ) )
			response = visit_url( "volcanoisland.php?action=tniat&action2=try" );

		if ( contains_text( response , "Combat" ) )
		{
			run_combat();
			foreach i, mon in get_monsters( $location[The Nemesis' Lair] )
			{
				if ( mon == last_monster() ) unlocked = true ;
			}
			if ( !unlocked ) retry = true;
		}
		else if (	response.contains_text( "Legendary Epic Weapon" )
				||	response.contains_text( "fiendish final puzzle" )	// volcano maze
				||	response.contains_text( "RIP AND TEAR" )			// SC
	//			||	response.contains_text( "" )						// TT
				||	response.contains_text( "the hood of your robe" )	// PM
				||	response.contains_text( "wobble up" )				// S
				||	response.contains_text( "opens the door" )			// DB
				||	response.contains_text( "unlock the front door" )	// AT
		)	unlocked = true ;
	} until ( !retry );

	if ( unlocked ) return vprint( "The Nemesis Lair was already unlocked!", 6 );

	string classLair = "nemesis_"+my_class().to_string().replace_string( " ","_" );
	return call boolean classLair();
}


#/*****************************************************************************************\#
#																							#
#										Nemesis Lair										#
#																							#
#\*****************************************************************************************/#


boolean nemesisLair()
{
	if ( my_adventures() == 0 ) return vprint( "Out of adventures.",-1 );
	restore_settings( false );

	string command;
	switch ( my_primestat() )
	{
		case $stat[ Muscle ]:
		case $stat[ Mysticality ]: command += "Muscle, "; break;
		case $stat[ Moxie ]: command += "Moxie, -offhand, "; break;
	}
	command += " -weapon, -ML, -familiar, -tie";
	maximize( command, false );
	equip( LEW );
	restore_hp( 0 );
	restore_mp( 0 );

	vprint( "Unlocking Volcano Maze...","green",2 );
	if ( !test_combat( $location[ The Nemesis' Lair ], false ) )
		return vprint( "Please buff your Moxie or Muscle to " + ( 180 + monster_level_adjustment() ), -1 );

	while ( my_adventures() > 0 )
	{
		restore_hp( 0 );
		restore_mp( 0 );
		print( "" );
		string response = visit_url( "volcanoisland.php?action=tniat" );
		if ( contains_text( response , "Combat" ) )
		{
			run_combat();
		}
		else break;
	}

	// solve volcano maze
	if ( !visit_url( "volcanoisland.php?action=tniat" ).contains_text( "fiendish final puzzle" ) )
		return vprint( "Something happened while unlocking the Volcano Maze, exiting...",-1 );
	else vprint( "Volcano Maze unlocked","green",4 );

	vprint( "Mafia will now try to solve the Volcano Maze, please wait...", "green", 1 );
	while ( !cli_execute( "volcano visit; volcano solve" ) )
	{
		// No solution find, swim back to shore and try again
		vprint( "Swimming back to shore...", "red", 1 );
		cli_execute( "volcano jump" );
	}

	return vprint( "Mafia finished trying to solve the Maze. If it didn't, try swimming back to shore and using the 'Solve' button in the Relay Browser.", "green", 1 );
}


#/*****************************************************************************************\#
#																							#
#									Master Function											#
#																							#
#\*****************************************************************************************/#

// Ultimate Legendary Epic Weapons
string [ class ] ULEWs ;
ULEWs[ $class[ Seal Clubber ] ] 	= "Sledgehammer of the V&aelig;lkyr" ;
ULEWs[ $class[ Turtle Tamer ] ] 	= "Flail of the Seven Aspects" ;
ULEWs[ $class[ Pastamancer ] ] 		= "Wrath of the Capsaician Pastalords" ;
ULEWs[ $class[ Sauceror ] ] 		= "Windsor Pan of the Source" ;
ULEWs[ $class[ Disco Bandit ] ] 	= "Seeger's Unstoppable Banjo" ;
ULEWs[ $class[ Accordion Thief ] ] 	= "The Trickster's Trikitixa" ;
item ULEW = ULEWs[ my_class() ].to_item();

void nemesisQuest()
{
	if ( available_amount( ULEW ) > 0 ) { vprint( "Nemesis quest already done!", "green", 1 ); exit; } 

	// reset step if this is the first time the script is run on this ascension
	if ( get_property( "nemesis_lastReset" ) != get_property( "knownAscensions" ) )
	{
		set_property( "nemesis_Step", "0" );
		set_property( "nemesis_lastReset", get_property( "knownAscensions" ) );
	}
	int step = get_property("nemesis_Step").to_int();

	// go through the steps
	if ( step == 0 ) // LEW quest
	{
		if ( !get_LEW() ) die( "Problem occured while acquiring the LEW, exiting...");
		step = 1; set_property( "nemesis_Step", "1" );
	}
	if ( step == 1 ) // Nemesis Cave
	{
		if ( !nemesisCave() ) die( "Problem occured while doing the Nemesis Cave, exiting..." );
		step = 2; set_property( "nemesis_Step", "2" );
	}
	if ( step == 2 ) // Open the Volcano island
	{
		if ( !openVolcanoIsland() ) die( "Problem occured while opening the Volcano island, exiting...");
		step = 3; set_property( "nemesis_Step", "3" );
	}
	if ( step == 3 ) // Unlock the Nemesis Lair
	{
		if ( !openLair() ) die( "Problem occured while opening the Nemesis Lair, exiting...");
		step = 4; set_property( "nemesis_Step", "4" );
	}
	if ( step == 4 ) // Nemesis Lair and Volcano Maze
	{
		if ( !nemesisLair() ) die( "Problem occured while going through the Nemesis Lair, exiting...");
		step = 5; set_property( "nemesis_Step", "5" );
	}
	if ( step == 5 ) // Nemesis Fight
	{
		vprint( "Your Nemesis is waiting for you!","green",1 );
		vprint( "Don't forget to visit your guild after you kill him.","green",1 );
		die( "exiting...");
	}
	die( "Reached the end of the script, exiting..." );
}

void main()
{
	try
	{
		nemesisQuest();
	}
	finally
	{
		restore_settings();
	}
}