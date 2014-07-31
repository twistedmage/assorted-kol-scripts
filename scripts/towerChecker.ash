script "Tower Checker";
notify bmaher;

string haveColor = "blue";
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

record firstGateData {
	string gatename;
	string scopeValue;
	effect neededEffect;
	item [int] effectSource;
};

firstGateData [int] firstGate;

firstGateData gate1;
gate1.gatename = "gate of bees";
gate1.scopeValue = "a mass of bees";
gate1.neededEffect = $effect[Float Like a Butterfly, Smell Like a Bee];
gate1.effectSource[0] = $item[honeypot];
firstGate[count(firstGate)] = gate1;

firstGateData gate2;
gate2.gatename = "gate of hilarity";
gate2.scopeValue = "a banana peel";
gate2.neededEffect = $effect[Comic Violence];
gate2.effectSource[0] = $item[gremlin juice];
firstGate[count(firstGate)] = gate2;

firstGateData gate3;
gate3.gatename = "gate of humility";
gate3.scopeValue = "a cowardly-looking man";
gate3.neededEffect = $effect[Wussiness];
gate3.effectSource[0] = $item[wussiness potion];
firstGate[count(firstGate)] = gate3;

firstGateData gate4;
gate4.gatename = "gate of morose morbidity and moping";
gate4.scopeValue = "a glum teenager";
gate4.neededEffect = $effect[Rainy Soul Miasma];
gate4.effectSource[0] = $item[thin black candle];
firstGate[count(firstGate)] = gate4;

firstGateData gate5;
gate5.gatename = "gate of slack";
gate5.scopeValue = "a smiling man smoking a pipe";
gate5.neededEffect = $effect[Extreme Muscle Relaxation];
gate5.effectSource[0] = $item[Mick's IcyVapoHotness Rub];
firstGate[count(firstGate)] = gate5;

firstGateData gate6;
gate6.gatename = "gate of spirit";
gate6.scopeValue = "an armchair";
gate6.neededEffect = $effect[Woad Warrior];
gate6.effectSource[0] = $item[pygmy pygment];
firstGate[count(firstGate)] = gate6;

firstGateData gate7;
gate7.gatename = "gate of the porcupine";
gate7.scopeValue = "a hedgehog";
gate7.neededEffect = $effect[Spiky Hair];
gate7.effectSource[0] = $item[super-spiky hair gel];
firstGate[count(firstGate)] = gate7;

firstGateData gate8;
gate8.gatename = "twitching gates of the suc rose";
gate8.scopeValue = "a rose";
gate8.neededEffect = $effect[Sugar Rush];
gate8.effectSource[0] = $item[Angry Farmer candy];
gate8.effectSource[1] = $item[breath mint];
gate8.effectSource[2] = $item[marzipan skull];
gate8.effectSource[3] = $item[Tasty Fun Good rice candy];
gate8.effectSource[4] = $item[Crimbo candied pecan];
gate8.effectSource[5] = $item[Crimbo fudge];
gate8.effectSource[6] = $item[Crimbo peppermint bark];
gate8.effectSource[7] = $item[that gum you like];
firstGate[count(firstGate)] = gate8;

firstGateData gate9;
gate9.gatename = "gate of the viper";
gate9.scopeValue = "a coiled viper";
gate9.neededEffect = $effect[Deadly Flashing Blade];
gate9.effectSource[0] = $item[adder bladder];
firstGate[count(firstGate)] = gate9;

firstGateData gate10;
gate10.gatename = "locked gate";
gate10.scopeValue = "a raven";
gate10.neededEffect = $effect[Locks Like the Raven];
gate10.effectSource[0] = $item[Black No. 2];
firstGate[count(firstGate)] = gate10;

void checkFirstGate()
{
	string scope1 = get_property("telescope1");
	if( scope1 == "" ) return;
	string returnString;
	string color = needColor;
	foreach x in firstGate
	{
		if( firstGate[x].scopeValue.contains_text(scope1) )
		{
			string effSource = firstGate[x].effectSource[0];
			boolean haveItem = false;
			for i from 0 upto count( firstGate[x].effectSource ) - 1
			{
				if( available_amount( firstGate[x].effectSource[i] ) > 0 )
				{
					effSource = firstGate[x].effectSource[i];
					haveItem = true;
					break;
				}
			}
			returnString = "First gate: " + firstGate[x].neededEffect +
			  "/" + effSource + " - ";

			if( haveItem )
			{
				returnString += "have";
				color = haveColor;
			}
			else returnString += "NEED";
			printColor(returnString, color);
		}
	}
}

record monsterGateData
{
	string monsterName;
	string scopeValue;
	item neededItem;
};

monsterGateData [int] monsterGate;

monsterGateData monsterGate1;
monsterGate1.monsterName = "beer batter";
monsterGate1.scopeValue = "tip of a baseball bat";
monsterGate1.neededItem = $item[baseball];
monsterGate[count(monsterGate)] = monsterGate1;

monsterGateData monsterGate2;
monsterGate2.monsterName = "best-selling novelist";
monsterGate2.scopeValue = "writing desk";
monsterGate2.neededItem = $item[plot hole];
monsterGate[count(monsterGate)] = monsterGate2;

monsterGateData monsterGate3;
monsterGate3.monsterName = "big meat golem";
monsterGate3.scopeValue = "huge face made of Meat";
monsterGate3.neededItem = $item[meat vortex];
monsterGate[count(monsterGate)] = monsterGate3;

monsterGateData monsterGate4;
monsterGate4.monsterName = "bowling cricket";
monsterGate4.scopeValue = "fancy-looking tophat";
monsterGate4.neededItem = $item[sonar-in-a-biscuit];
monsterGate[count(monsterGate)] = monsterGate4;

monsterGateData monsterGate5;
monsterGate5.monsterName = "bronze chef";
monsterGate5.scopeValue = "bronze figure holding a spatula";
monsterGate5.neededItem = $item[leftovers of indeterminate origin];
monsterGate[count(monsterGate)] = monsterGate5;

monsterGateData monsterGate6;
monsterGate6.monsterName = "concert pianist";
monsterGate6.scopeValue = "long coattails";
monsterGate6.neededItem = $item[Knob Goblin firecracker];
monsterGate[count(monsterGate)] = monsterGate6;

monsterGateData monsterGate7;
monsterGate7.monsterName = "the darkness";
monsterGate7.scopeValue = "strange shadow";
monsterGate7.neededItem = $item[inkwell];
monsterGate[count(monsterGate)] = monsterGate7;

monsterGateData monsterGate8;
monsterGate8.monsterName = "el diablo";
monsterGate8.scopeValue = "neck of a huge bass guitar";
monsterGate8.neededItem = $item[mariachi G-string];
monsterGate[count(monsterGate)] = monsterGate8;

monsterGateData monsterGate9;
monsterGate9.monsterName = "electron submarine";
monsterGate9.scopeValue = "periscope";
monsterGate9.neededItem = $item[photoprotoneutron torpedo];
monsterGate[count(monsterGate)] = monsterGate9;

monsterGateData monsterGate10;
monsterGate10.monsterName = "endangered inflatable white tiger";
monsterGate10.scopeValue = "giant white ear";
monsterGate10.neededItem = $item[pygmy blowgun];
monsterGate[count(monsterGate)] = monsterGate10;

monsterGateData monsterGate11;
monsterGate11.monsterName = "fancy bath slug";
monsterGate11.scopeValue = "slimy eyestalk";
monsterGate11.neededItem = $item[fancy bath salts];
monsterGate[count(monsterGate)] = monsterGate11;

monsterGateData monsterGate12;
monsterGate12.monsterName = "the fickle finger of f8";
monsterGate12.scopeValue = "giant cuticle";
monsterGate12.neededItem = $item[razor-sharp can lid];
monsterGate[count(monsterGate)] = monsterGate12;

monsterGateData monsterGate13;
monsterGate13.monsterName = "flaming samurai";
monsterGate13.scopeValue = "flaming katana";
monsterGate13.neededItem = $item[frigid ninja stars];
monsterGate[count(monsterGate)] = monsterGate13;

monsterGateData monsterGate14;
monsterGate14.monsterName = "giant desktop globe";
monsterGate14.scopeValue = "the North Pole";
monsterGate14.neededItem = $item[NG];
monsterGate[count(monsterGate)] = monsterGate14;

monsterGateData monsterGate15;
monsterGate15.monsterName = "giant fried egg";
monsterGate15.scopeValue = "flash of albumen";
monsterGate15.neededItem = $item[black pepper];
monsterGate[count(monsterGate)] = monsterGate15;

monsterGateData monsterGate16;
monsterGate16.monsterName = "ice cube";
monsterGate16.scopeValue = "moonlight reflecting off of what appears to be ice";
monsterGate16.neededItem = $item[hair spray];
monsterGate[count(monsterGate)] = monsterGate16;

monsterGateData monsterGate17;
monsterGate17.monsterName = "malevolent crop circle";
monsterGate17.scopeValue = "amber waves of grain";
monsterGate17.neededItem = $item[bronzed locust];
monsterGate[count(monsterGate)] = monsterGate17;

monsterGateData monsterGate18;
monsterGate18.monsterName = "possessed pipe-organ";
monsterGate18.scopeValue = "pipes with steam shooting out of them";
monsterGate18.neededItem = $item[powdered organs];
monsterGate[count(monsterGate)] = monsterGate18;

monsterGateData monsterGate19;
monsterGate19.monsterName = "pretty fly";
monsterGate19.scopeValue = "translucent wing";
monsterGate19.neededItem = $item[spider web];
monsterGate[count(monsterGate)] = monsterGate19;

monsterGateData monsterGate20;
monsterGate20.monsterName = "tyrannosaurus tex";
monsterGate20.scopeValue = "large cowboy hat";
monsterGate20.neededItem = $item[chaos butterfly];
monsterGate[count(monsterGate)] = monsterGate20;

monsterGateData monsterGate21;
monsterGate21.monsterName = "vicious easel";
monsterGate21.scopeValue = "tall wooden frame";
monsterGate21.neededItem = $item[disease];
monsterGate[count(monsterGate)] = monsterGate21;

monsterGateData monsterGate22;
monsterGate22.monsterName = "enraged cow";
monsterGate22.scopeValue = "pair of horns";
monsterGate22.neededItem = $item[barbed-wire fence];
monsterGate[count(monsterGate)] = monsterGate22;

monsterGateData monsterGate23;
monsterGate23.monsterName = "giant bee";
monsterGate23.scopeValue = "formidable stinger";
monsterGate23.neededItem = $item[tropical orchid];
monsterGate[count(monsterGate)] = monsterGate23;

monsterGateData monsterGate24;
monsterGate24.monsterName = "collapsed mineshaft golem";
monsterGate24.scopeValue = "wooden beam";
monsterGate24.neededItem = $item[stick of dynamite];
monsterGate[count(monsterGate)] = monsterGate24;

void checkTowerMonsters()
{
	for i from 2 upto 7
	{
		string scopeString = get_property( "telescope" + i );
		if( scopeString == "" ) return;
		string color = haveColor;
		foreach x in monsterGate
		{
			if( scopeString.contains_text( monsterGate[x].scopeValue ) )
			{
				string returnString = "Tower " + (i - 1) + ": ";
				returnString += monsterGate[x].neededItem + " - ";
				if( item_amount( monsterGate[x].neededItem ) > 0 )
				{
					returnString += "have";
				}
				else if( closet_amount( monsterGate[x].neededItem ) > 0 )
				{
					returnString += "CLOSET";
				}
				else
				{
					returnString += "NEED";
					color = needColor;
				}
				printColor( returnString, color );
			}
		}
	}
}

void checkAccordion()
{
	foreach thing in $items[]
	{
		if ( thing.image.substring(0,3) == "acc" && available_amount( thing ) > 0 ) return;
	}

	foreach accordion in $items[calavera concertina,Rock and Roll Legend,
			The Trickster's Trikitixa,Squeezebox of the Ages,antique accordion]
	{
		if ( available_amount( accordion ) > 0 ) return;
	}
	printColor("Accordion: NEED", needColor );
}

void checkGuitar()
{
	foreach guitar in $items[acoustic guitarrr,heavy metal thunderrr guitarrr,stone banjo,disco banjo,
					Shagadelic Disco Banjo,Seeger's Unstoppable Banjo,Crimbo ukulele,massive sitar,
					Zim Merman's guitar,4-dimensional guitar,half-sized guitar,out-of-tune biwa,plastic guitar]
	{
		if( available_amount( guitar ) > 0 )
		{
			string article;
			if( guitar.to_string().substring(0,1) == "a" || guitar.to_string().substring(0,1) == "o" ) article = "an ";
			else article = "a ";
			printColor("Guitar: You have " + article + guitar, haveColor );
			return;
		}
	}
	printColor("Guitar: NEED", needColor );
}

void checkDrum()
{
	foreach drum in $items[bone rattle,tambourine,jungle drum,hippy bongo,big bass drum,black kettle drum,broken skull]
	{
		if( available_amount( drum ) > 0 )
		{
			printColor("Drum: You have a " + drum, haveColor );
			return;
		}
	}
	printColor("Drum: NEED", needColor );
}

void checkKeys()
{
	string missingKeys;
	string color = needColor;
	foreach key in $items[boris's key,jarlsberg's key,sneaky pete's key,digital key,richard's star key,skeleton key]
	{
		if( ( item_amount( key ) < 1 ) && length(missingKeys) > 0 ) missingKeys += ", ";
		if( item_amount( key ) < 1 ) missingKeys += key;
	}
	if( length(missingKeys) == 0 )
	{
		missingKeys = "None";
		color = haveColor;
	}
	printColor( "Missing keys: " + missingKeys, color );
}

void checkStar()
{
	string missingStar;
	string path = my_path();
	boolean [item] starWeapon = $items[star crossbow,star sword,star staff];
	boolean starWeaponNeeded = true;
	string color = needColor;
	if( path == "Avatar of Boris" || path == "Way of the Surprising Fist" ) starWeaponNeeded = false;
	foreach weapon in starWeapon
	{
		if( available_amount( weapon ) > 0 )
		{
			starWeaponNeeded = false;
			break;
		}
	}
	if( starWeaponNeeded ) missingStar = "star weapon";
	foreach starItem in $items[star hat,richard's star key]
	{
		if( available_amount( starItem ) == 0 )
		{
			if( length(missingStar) > 0 ) missingStar += ", ";
			missingStar += starItem;
		}
	}
	if( !have_familiar( $familiar[star starfish] ) 
		&& path != "Avatar of Boris" 
		&& path != "Zombie Slayer" 
		&& path != "Avatar of Jarlsberg" 
		&& path != "Avatar of Sneaky Pete"
		)
	{
		if( length(missingStar) > 0 ) missingStar += ", ";
		missingStar += "Star Starfish";
	}
	if( length(missingStar) == 0 )
	{
		missingStar = "None";
		color = haveColor;
	}
	printColor( "Missing star items: " + missingStar, color );
}

void checkBoss()
{
	string path = my_path();
	if( path == "Avatar of Boris" ||
		path == "Zombie Slayer" ||
		path == "Avatar of Jarlsberg" ||
		path == "KOLHS" ||
		path == "Avatar of Sneaky Pete" ) 
	{
		return;
	}
	item bossItem = $item[wand of nagamar];
	if( path == "Bees Hate You" ) bossItem = $item[antique hand mirror];
	string article;
	if( bossItem.to_string().substring(0,1) == "a" || bossItem.to_string().substring(0,1) == "o" ) article = "an ";
	else article = "a ";
	if( item_amount( bossItem ) > 0 ) printColor("You are ready for the boss", haveColor );
	else printColor("You need " + article + bossItem, needColor );
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
		Avatar of Sneaky Pete,Slow and Steady] contains my_path()) )
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
	checkFirstGate();
	checkTowerMonsters();
	checkAccordion();
	checkGuitar();
	checkDrum();
	checkKeys();
	checkStar();
	checkBoss();
}