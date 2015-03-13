script "Tower Checker";
notify bmaher;

string haveColor = "blue";
string warnColor = "orange";
string needColor = "red";
string plainColor = "black";

void printColor( string message, string color )
{
	print_html( "<font color=\"" + color + "\">" + message + "</font>" );
}

void updateScope()
{
	if( get_property( "lastTelescopeReset" ).to_int() < my_ascensions() )
	{
		visit_url( "campground.php?action=telescopelow" );
	}
}

void listStatTests()
{
	string contest1 = get_property( "nsChallenge1" );
	string contest2 = get_property( "nsChallenge2" );
	if ( contest1 == "none" ) contest1 = "unknown";
	if ( contest2 == "none" ) contest2 = "unknown";
	
	printColor( "Contests: Init, " + contest1 + ", " + contest2, plainColor );
}

void listElementTests()
{
	string element1 = get_property( "nsChallenge3" );
	string element2 = get_property( "nsChallenge4" );
	string element3 = get_property( "nsChallenge5" );
	if ( element1 == "none" ) element1 = "unknown";
	if ( element2 == "none" ) element2 = "unknown";
	if ( element3 == "none" ) element3 = "unknown";
	
	printColor( "Maze: " + element1 + ", " + element2 + ", " + element3, plainColor );
}

void checkDDKeys()
{
	int used = 0;
	int have = 0;
	int token = item_amount( $item[fat loot token] );
	string borisKey = "need";
	string jarlsKey = "need";
	string peteKey = "need";
	boolean needComma = false;
	
	# Check if you already used all the keys, or if you have all the keys
	if ( get_property( "nsTowerDoorKeysUsed" ).contains_text( "Boris's key" ) )
	{
		borisKey = "used";
		used += 1;
	}
	else if ( item_amount( $item[boris's key] ) > 0 )
	{
		borisKey = "have";
		have += 1;
	}
	if ( get_property( "nsTowerDoorKeysUsed" ).contains_text( "Jarlsberg's key" ) )
	{
		jarlsKey = "used";
		used += 1;
	}
	else if ( item_amount( $item[jarlsberg's key] ) > 0 )
	{
		jarlsKey = "have";
		have += 1;
	}
	if ( get_property( "nsTowerDoorKeysUsed" ).contains_text( "Sneaky Pete's key" ) )
	{
		peteKey = "used";
		used += 1;
	}
	else if ( item_amount( $item[sneaky pete's key] ) > 0 )
	{
		peteKey = "have";
		have += 1;
	}

	if ( used == 3 )
	{
		return;
	}

	if ( have == 3 )
	{
		printColor( "You have all the hero keys.", haveColor );
		return;
	}

	# Check if you have enough stuff to make all the keys
	string message = "";
	if ( have + token + used >= 3 )
	{
		if ( used > 0 )
		{
			message = "You have used";
			if ( borisKey == "used" )
			{
				message += " boris's key";
				needComma = true;
			}
			if ( jarlsKey == "used" )
			{
				if ( needComma ) message += " and";
				message += " jarlsberg's key";
				needComma = true;
			}
			if ( peteKey == "used" )
			{
				if ( needComma ) message += " and";
				message += " sneaky pete's key";
			}
			message += ". ";
			needComma = false;
		}
	
		message += "You have ";
		if ( borisKey == "have" )
		{
			message += " boris's key";
			needComma = true;
		}
		if ( jarlsKey == "have" )
		{
			if ( needComma ) message += ", ";
			message += " jarlsberg's key";
			needComma = true;
		}
		if ( peteKey == "have" )
		{
			if ( needComma ) message += ", ";
			message += " sneaky pete's key";
			needComma = true;
		}
		if ( token > 0 )
		{
			if ( needComma ) message += " and ";
			message += token + " " + "token" + ( token > 1 ? "s" : "" );
		}
		message += ".";
		printColor( message, haveColor );
		return;
	}
	needComma = false;
	
	# You are missing stuff
	message = "You need ";
	if ( borisKey == "need" )
	{
		message += " boris's key";
		needComma = true;
	}
	if ( jarlsKey == "need" )
	{
		if ( needComma ) message += ", ";
		message += " jarlsberg's key";
		needComma = true;
	}
	if ( peteKey == "need" )
	{
		if ( needComma ) message += ", ";
		message += " sneaky pete's key";
	}
	message += ".  You have " + token + "token" + ( token > 1 ? "s" : "" );
	printColor( message, needColor );
}

void checkStarKey()
{
	if ( get_property( "nsTowerDoorKeysUsed" ).contains_text( "Richard's star key" ) )
	{
		return;
	}
	if( available_amount( $item[richard's star key] ) > 0 )
	{
		printColor( "You have a star key.", haveColor );
		return;
	}
	if ( available_amount( $item[star] ) >= 8 && 
	     available_amount( $item[line] ) >= 7 &&
		 available_amount( $item[star chart] ) >= 1 )
	{
		printColor( "You have INGREDIENTS for a star key.", warnColor );
		return;
	}
	printColor( "You need Richard's star key.", needColor );
}

void checkDigitalKey()
{
	if ( get_property( "nsTowerDoorKeysUsed" ).contains_text( "digital key" ) ) return;

	if( available_amount( $item[digital key] ) > 0 )
	{
		printColor( "You have a digital key.", haveColor );
		return;
	}
	if ( available_amount( $item[white pixel] ) >= 30 )
	{
		printColor( "You have INGREDIENTS for a digital key.", warnColor );
		return;
	}
	printColor( "You need a digital key.", needColor );
}

void checkSkeletonKey()
{
	if ( get_property( "nsTowerDoorKeysUsed" ).contains_text( "skeleton key" ) ) return;

	if( available_amount( $item[skeleton key] ) > 0 )
	{
		printColor( "You have a skeleton key.", haveColor );
		return;
	}
	if ( available_amount( $item[skeleton bone] ) > 0 && available_amount( $item[loose teeth] ) > 0 )
	{
		printColor( "You have INGREDIENTS for a skeleton key.", warnColor );
		return;
	}
	printColor( "You need a skeleton key.", needColor );
}

void checkBoss()
{
	string path = my_path();
	if( path == "Avatar of Boris" ||
		path == "Zombie Slayer" ||
		path == "Avatar of Jarlsberg" ||
		path == "KOLHS" ||
		path == "Avatar of Sneaky Pete" ||
		path == "Heavy Rains"
	  )
	{
		return;
	}
	if ( get_property( "questL13Final" ) == "finished" || get_property( "questL13Final" ) == "step11" ) return;
	item bossItem = $item[wand of nagamar];
	if( path == "Bees Hate You" ) bossItem = $item[antique hand mirror];
	if( item_amount( bossItem ) > 0 )
	{
		printColor("You are ready for the boss", haveColor );
		return;
	}
	string article;
	if( bossItem.to_string().substring(0,1) == "a" || bossItem.to_string().substring(0,1) == "o" ) article = "an ";
	else article = "a ";
	if ( creatable_amount( bossItem ) > 0 )
	{
		printColor( "You can make " + article + bossItem, warnColor );
		return;
	}
	printColor("You need " + article + bossItem, needColor );
}

void checkMonsters()
{
	string setting = get_property( "questL13Final" );
	int step = 0;
	if ( setting == "finished" ) return;
	if ( setting != "unstarted" ) step = setting.substring( 4 ).to_int();
	
	if ( step <= 5 )
	{
		if ( item_amount( $item[beehive] ) > 0 ) printColor( "You have a beehive.", haveColor );
		else printColor( "You need a beehive.", needColor );
	}
	
	if ( step <= 7 )
	{
		if ( item_amount( $item[electric boning knife] ) > 0 ) printColor( "You have an electric boning knife.", haveColor );
		else printColor( "You need an electric boning knife.", needColor );
	}
}

void specialPathHandling()
{
	if( my_path() == "Bugbear Invasion" )
	{
		printColor( "This path doesn't have a tower.", plainColor );
		exit;
	}
}

void checkForKnownPath()
{
	if( !($strings[None, Teetotaler, Boozetafarian, Oxygenarian,
	    Bees Hate You, Way of the Surprising Fist, Trendy,
	    Avatar of Boris, Bugbear Invasion,Zombie Slayer,Class Act,
	    Avatar of Jarlsberg,BIG!,KOLHS,Class Act II: A Class For Pigs,
		Avatar of Sneaky Pete,Slow and Steady,Heavy Rains,Picky,Standard] contains my_path()) )
	{
		printColor( "Your current challenge path is not recognized by this script.  Proceed with caution.", "red" );
		wait(2);
	}
}

void main()
{
	checkForKnownPath();
	specialPathHandling();
	updateScope();
	listStatTests();
	listElementTests();
	checkDDKeys();
	checkStarKey();
	checkDigitalKey();
	checkSkeletonKey();
	checkMonsters();
	checkBoss();
}