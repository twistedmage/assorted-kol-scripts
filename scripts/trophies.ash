import <consumption.ash>;

boolean [string] trophies;
int [string] trophyCounter;

// level trophies
trophies["Duke of Disco"] = false;
trophies["Scourge of Seals"] = false;
trophies["Tzar of Turtles"] = false;
trophies["Potentate of Pasta"] = false;
trophies["Sauciest Saucier"] = false;
trophies["Maestro of Mariachi"] = false;

// consumption trophies
trophies["I Heart Canadia"] = false;
trophies["Platinum Skull"] = false;
trophies["Disgusting Cocktail"] = false;
trophies["The Ghuol Cup"] = false;
trophies["Bouquet of Hippies"] = false;
trophies["Weeping Pizza"] = false;
trophies["Phileas Foggy"] = false;
trophies["Failure to Communicate"] = false;
trophies["Best Meal of My Life"] = false;
trophies["Three-Tiered Trophy"] = false;
trophies["Awwww, Yeah"] = false; // not exactly consumption, but our estimate is based on it.

// skill based
trophies["Jack of Several Trades"] = false;
trophies["Trivially Skilled"] = false;
trophies["Eerily Skilled"] = false;

// hardcore
trophies["Golden Meat Stack"] = false;
trophies["Gourdcore"] = false;

// tiny plastic
trophies["Tiny Plastic Trophy"] = false;
trophies["Two-Tiered Tiny Plastic Trophy"] = false;

// Creation discoveries
trophies["Master Paster"]=false;
trophies["Golden Spatula"]=false;
trophies["Mellon Baller, Shot Caller"]=false;
trophies["BAM!"]=false;
trophies["Speakeasy Savant"]=false;
trophies["Honky Tonk Hero"]=false;
trophies["Cantina Commander"]=false;
trophies["Apprentice Meatsmacker"]=false;
trophies["Journeyman Meatsmacker"]=false;
trophies["Master Meatsmacker"]=false;
trophies["Preciousss"]=false;


// misc trophies we can track
trophies["Little Chickadee"] = false;
trophies["I Love A Parade"] = false;
trophies["Big Boat"] = false;
trophies["Little Boat"] = false;
trophies["100 Pound Load"] = false;
trophies["300 Pound Load"] = false;
trophies["Black Hole Terrarium"] = false;
trophies["Your Log Saw Something That Night"] = false;
trophies["Amateur Tour Guide"] = false;
trophies["Professional Tour Guide"] = false;

int [string] familiarpct;

// used for tiny plastic count. Return 1 if you have at least one, otherwise 0.
int own_one(item it)
{
	if (item_amount(it)>0)
		return 1;
	if (closet_amount(it)>0)
		return 1;
	if (display_amount(it)>0)
		return 1;
	if (storage_amount(it)>0)
		return 1;
	
	return 0;
}

int count_discoveries(string mode)
{
	int a;


	string discovery = visit_url("craft.php?mode=discoveries&what="+mode);
	a = index_of(discovery,"onClick=\"descitem");

	int count = 0;
	
	while (a>0)
	{
		count = count+1;
		a = index_of(discovery,"onClick=\"descitem",a+2);
	}
	
	return count;
}


void FindOneFamiliar(string list, string fam)
{
	if (!contains_text(list,fam))
		return; // familiar isn't in this list, so skip the rest.
		
	int loc = index_of(list,fam);
	if (loc>0)
	{
		// found it
		string sub = substring (list,loc + length(fam));
		loc = index_of(sub,"(");
		string pct = substring(sub,loc + 1);
		loc = index_of(pct,"%");
		pct = substring(pct,0,loc);
		int num = to_int(pct);
		if (familiarpct[fam]<num)
			familiarpct[fam]=num;
		FindOneFamiliar(sub,fam); // send remaining list in case there is more than one entry for this fam.
	}
	
}

void ParseAscensionRecords(string list)
{

	foreach fam in familiarpct
	{
		//look for this familiar in the list...
		FindOneFamiliar(list,fam);
	}
}

void FindFamiliarNumbers()
{
	// look through the ascension records for unique familars
	

	for x from 1 upto 100
	{
		familiar oneFam = int_to_familiar ( x );
		if (have_familiar(oneFam))
		{
			familiarpct[to_string(oneFam)] = 0;
		}
	}
	// now we have a list of all of our familiars. Look through ascension records for most used % for each
	
	string records = visit_url("ascensionhistory.php?back=self&who=" + my_id());
	ParseAscensionRecords(records);
	
	records = visit_url("ascensionhistory.php?back=self&prens13=1&who=" + my_id());
	ParseAscensionRecords(records);

}


void MainTrophyInfo()
{
		
	// collect trophy info from basic places to save server hits
	string installed = visit_url("trophies.php");

	foreach key in trophies
	{
		if (contains_text(installed,key))
			trophies[key]=true;
		if (key == "Failure to Communicate")
		{
			// ash has issues finding this trophy (?)
			if (contains_text(installed,"Communicate"))
				trophies[key]=true;
			
		}
	}
	
	foreach key in trophies
	{
		trophyCounter[key]=0;
	}
	
	if (trophies["I Love A Parade"] == false)
		trophyCounter["I Love A Parade"] = item_amount( $item[handful of confetti] ) + closet_amount( $item[handful of confetti] ) + storage_amount( $item[handful of confetti] ) + display_amount( $item[handful of confetti] );

	if (trophies["Big Boat"] == false || trophies["Little Boat"] == false)
	{
		string shore = visit_url("shore.php");
		if (contains_text(shore,"You have taken")) // only track once we have access to the shore and have been there once.
		{
			int loc = index_of(shore,"You have taken");
			
			string sub = substring(shore,loc+15);
			
			loc = index_of(sub," ");
			sub = substring(sub,0,loc);
			trophycounter["Big Boat"] = to_int(sub);
			trophycounter["Little Boat"] = to_int(sub);
		}
	}
	
	if (trophies["100 Pound Load"] == false || trophies["300 Pound Load"] == false || trophies["Black Hole Terrarium"] == false)
	{
		int weight = 0;
		// figure out approx familiar weights
		for fam from 1 upto 100
		{
			familiar oneFam = int_to_familiar ( fam );
			if (have_familiar(oneFam))
			{
				weight = weight + familiar_weight( oneFam );
			}
		}
		trophycounter["100 Pound Load"] = weight;
		trophycounter["300 Pound Load"] = weight;
		trophycounter["Black Hole Terrarium"] = weight;
	}
	
	if (trophies["Gourdcore"] == false && in_hardcore())
	{
		string gourd = visit_url("questlog.php?which=1");
		if (contains_text(gourd,"Out of Your Gourd"))
		{			
			int loc = index_of(gourd,"He's asking you to bring back ");
			gourd = substring(gourd,loc+30);
			loc = index_of(gourd," ");
			gourd = substring(gourd,0,loc);
			for c from 5 upto to_int(gourd)-1
			{
				trophycounter["Gourdcore"] = trophycounter["Gourdcore"] + c;
			}

		} else {
			gourd = visit_url("questlog.php?which=2");
			if (contains_text(gourd,"Out of Your Gourd"))
				trophycounter["Gourdcore"]=1000; // we're already eligible
		}
	}
	
	if (trophies["Amateur Tour Guide"] == false || trophies["Professional Tour Guide"] == false)
	{
		FindFamiliarNumbers();

		int count = 0;
		foreach fam in familiarpct
		{
			if (familiarpct[fam]>=90)
				count = count + 1;
		}

		trophycounter["Amateur Tour Guide"] = count;
		trophycounter["Professional Tour Guide"] = count;
	}
	
	
	
	trophycounter["Master Paster"]=count_discoveries("combine");
	trophycounter["Golden Spatula"]=count_discoveries("cook");
	trophycounter["Mellon Baller, Shot Caller"]=trophycounter["Golden Spatula"];
	trophycounter["BAM!"]=trophycounter["Golden Spatula"];
	trophycounter["Speakeasy Savant"]=count_discoveries("cocktail");
	trophycounter["Honky Tonk Hero"]=trophycounter["Speakeasy Savant"];
	trophycounter["Cantina Commander"]=trophycounter["Speakeasy Savant"];
	trophycounter["Apprentice Meatsmacker"]=count_discoveries("smith");
	trophycounter["Journeyman Meatsmacker"]=trophycounter["Apprentice Meatsmacker"];
	trophycounter["Master Meatsmacker"]=trophycounter["Apprentice Meatsmacker"];
	trophycounter["Preciousss"]=count_discoveries("jewelry");

}

void PrintMyTrophies()
{
	int count = 0;
	print ("Installed trophies:","blue");
	foreach key in trophies
	{
		if (trophies[key])
		{
			print("&nbsp;&nbsp;&nbsp;&nbsp;" + key,"blue");
			count = count + 1;
		}
	}
	print ("Total trophies: " + count, "blue");
}


void PrintProgressNote(string award, int current, int needed, string note)
{
	if (trophies[award] = true)
		return; // we already have this trophy anyway.
		
		
	// if there is no actual progress towards the trophy, don't display it...
	// this is mainly to hide consumption trophies until someone is "on the path" towards getting it
	if (current == 0)
		return;
		
	if (current>needed)
		current=needed;
	float pct = current/needed;
	
	
	pct = round(pct * 100);
	
	if (note != "")
		note = " [" + note + "]";

	string msg = "";
	if (current==needed)
		msg =  " <font color='blue'>(" + to_int(pct) + "%) : " + award + " (available, or only trivial work remains!)" + note + "</font>";
	else
		msg =  " <font color='green'>(" + to_int(pct) + "%) : " + award + note + "</font>";

	print_html("<table width = 200 cellpadding=0 cellspacing=0 border=0><tr><td bgcolor='green' width="+pct+"%></td><td bgcolor='#99FF99' width="+(100-pct)+"%></td></tr></table>&nbsp;" + msg);
		

}

void PrintProgress(string award, int current, int needed)
{
	PrintProgressNote(award, current, needed, "");
}


void ProgressLevel30()
{
	// I don't know how to easily check the substats with mafia and it seems like overkill to parse it out
	// manually. This will still get a better estimate of % remaining than just comparing stat to needed stat (845).
	int substatneeded = 845 * 845;
	int substats = my_basestat(my_primestat()) * my_basestat(my_primestat());
	
	
	string l30 = "";
	
	if (my_class() == $class[Seal Clubber])
		l30 = "Scourge of Seals";	
	if (my_class() == $class[Disco Bandit])
		l30 = "Duke of Disco";
	if (my_class() == $class[Turtle Tamer])
		l30 = "Tzar of Turtles";
	if (my_class() == $class[Pastamancer])
		l30 = "Potentate of Pasta";
	if (my_class() == $class[Sauceror])
		l30 = "Sauciest Saucier";
	if (my_class() == $class[Accordion Thief])
		l30 = "Maestro of Mariachi";
	
	if (trophies[l30])
		return; // we already have this trophy!
		
	// mainstat 845 = level 30, so base percentage on that.
	
	PrintProgress(l30,substats,substatneeded);
}


void ProgressConsumption()
{
	PrintProgress("Phileas Foggy",booze_consumed[$item[Around the World]],80);
	PrintProgress("I Heart Canadia",booze_consumed[$item[White Canadian]],30);
	PrintProgress("Platinum Skull",food_consumed[$item[spaghetti with Skullheads]],5);
	PrintProgress("Disgusting Cocktail",booze_consumed[$item[tomato daiquiri]],5);
	PrintProgress("The Ghuol Cup",food_consumed[$item[ghuol guolash]],11);
	PrintProgress("Bouquet of Hippies",food_consumed[$item[herb brownies]],420);
	PrintProgress("Weeping Pizza",food_consumed[$item[white chocolate and tomato pizza]],5);
	PrintProgress("Failure to Communicate",food_consumed[$item[lucky surprise egg]],5);
	PrintProgressNote("Awwww, Yeah",food_consumed[$item[black pudding]],500,"Approximate");
	
	
	
	// this one is different since it is in stages...
	int status = 0;
	if (food_consumed[$item[White Citadel burger]]<60)
		status = food_consumed[$item[White Citadel burger]];
	else
		status = 60;
		
	if (food_consumed[$item[White Citadel fries]]<10)
		status = status + food_consumed[$item[White Citadel fries]];
	else
		status = status + 10;
		
	PrintProgressNote("Best Meal of My Life",status,70,"Colas aren't counted");
	
	// don't display anything about the three tieded trophy unless we can do something about it.
	if (fullness_limit() == 35 && my_fullness() == 0)
		PrintProgressNote("Three-Tiered Trophy",1,10000,"All you need to do is eat it!");
	else
	{
		if (food_consumed[$item["three-tiered wedding cake"]]>0)
		PrintProgress("Three-Tiered Trophy",1,1);
	}

}

boolean HasPermanentSkill(string sheet, string whatskill)
{
	if ( contains_text(sheet, whatskill +"</a> (<b>HP</b>)") || contains_text(sheet,whatskill + "</a> (P)"))
		return true;
	
	return false;
}

void ProgressSkills()
{
	
	string sheet = visit_url("charsheet.php");
	
	int jack = 0;
	if ( HasPermanentSkill(sheet,"Cosmic Ugnderstanding"))
		jack = jack + 1;
	if ( HasPermanentSkill(sheet,"Gnefarious Pickpocketing"))
		jack = jack + 1;
	if ( HasPermanentSkill(sheet,"Gnomish Hardigness"))
		jack = jack + 1;
	if ( HasPermanentSkill(sheet,"Powers of Observatiogn"))
		jack = jack + 1;
	if ( HasPermanentSkill(sheet,"Torso Awaregness"))
		jack = jack + 1;

	if (in_hardcore())
		PrintProgressNote("Jack of Several Trades",jack,5, "Hardcore may mask SC perm'd skills");	 
	else
		PrintProgress("Jack of Several Trades",jack,5);	 
	
	//eerily skilled doesn't look at only perm'd skills, so we can use built in mafia check for these.
	int spook = 0;
	if ( have_skill($skill["Snarl of the Timberwolf"]))
		spook = spook + 1;
	if ( have_skill($skill["Spectral Snapper"]))
		spook = spook + 1;
	if ( have_skill($skill["Fearful Fettucini"]))
		spook = spook + 1;
	if ( have_skill($skill["Scarysauce"]))
		spook = spook + 1;
	if ( have_skill($skill["Tango of Terror"]))
		spook = spook + 1;
	if ( have_skill($skill["Dirge of Dreadfulness"]))
		spook = spook + 1;
	if (in_hardcore())
		PrintProgressNote("Eerily Skilled",spook,6, "Hardcore may mask SC perm'd skills");	 
	else
		PrintProgress("Eerily Skilled",spook,6);	 

	int trivial = 0;
	if ( HasPermanentSkill(sheet,"Seal Clubbing Frenzy"))
		trivial = trivial + 1;
	if ( HasPermanentSkill(sheet,"Patience of the Tortoise"))
		trivial = trivial + 1;
	if ( HasPermanentSkill(sheet,"Manicotti Meditation"))
		trivial = trivial + 1;
	if ( HasPermanentSkill(sheet,"Sauce Contemplation"))
		trivial = trivial + 1;
	if ( HasPermanentSkill(sheet,"Disco Aerobics"))
		trivial = trivial + 1;
	if ( HasPermanentSkill(sheet,"Moxie of the Mariachi"))
		trivial = trivial + 1;
	if (in_hardcore())
		PrintProgressNote("Trivially Skilled",trivial,6, "Hardcore may mask SC perm'd skills");	 
	else
		PrintProgress("Trivially Skilled",trivial,6);	 
 
}

void TrophyProgressAll()
{
	
	string tro = visit_url("trophy.php");
	if (!contains_text(tro,"You're not currently entitled to any trophies"))
	{
		print("&nbsp;");
		print("You have a trophy available to pick up immediately!","red");
		print("&nbsp;");
	}
	print ("Trophy progress: ","green");
	ProgressLevel30();
	ProgressConsumption();
	ProgressSkills();
	
	if (my_inebriety()>30)	// only display if there's some small chance we're trying for it.
		PrintProgress("Little Chickadee",my_inebriety(),1000);

	PrintProgress("I Love A Parade",trophycounter["I Love A Parade"],11);
	
	PrintProgress("Little Boat",trophycounter["Little Boat"],100);
	if (trophycounter["Big Boat"]>100) // don't display until we're past "Little Boat"
		PrintProgress("Big Boat",trophycounter["Big Boat"],1000);
	
	PrintProgress("100 Pound Load",trophycounter["100 Pound Load"],100);
	if (trophycounter["300 Pound Load"]>100) // don't display until past "100"
		PrintProgress("300 Pound Load",trophycounter["300 Pound Load"],300);
	if (trophycounter["Black Hole Terrarium"]>300) // don't display until past "300"
		PrintProgress("Black Hole Terrarium",trophycounter["Black Hole Terrarium"],500);
	
	if (in_hardcore())
	{
		PrintProgress("Golden Meat Stack",my_meat(),1000000);
		PrintProgress("Gourdcore",trophycounter["Gourdcore"],315);
	}
	
	// always easy to get...
	PrintProgress("Your Log Saw Something That Night",1,1);
	
	PrintProgress("Amateur Tour Guide",trophycounter["Amateur Tour Guide"],10);
	
	if (trophycounter["Professional Tour Guide"]>10) // don't display until past "amateur"
		PrintProgress("Professional Tour Guide",trophycounter["Professional Tour Guide"],30);

	PrintProgress("Master Paster",trophycounter["Master Paster"],69);
	
	PrintProgress("Golden Spatula",trophycounter["Golden Spatula"],50);
	if (trophycounter["Mellon Baller, Shot Caller"]>50) // don't display until past "50"
		PrintProgress("Mellon Baller, Shot Caller",trophycounter["Mellon Baller, Shot Caller"],100);
	if (trophycounter["BAM!"]>100) // don't display until past "100"
		PrintProgress("BAM!",trophycounter["BAM!"],150);

	PrintProgress("Speakeasy Savant",trophycounter["Master Paster"],20);
	if (trophycounter["Honky Tonk Hero"]>20) // don't display until past "20"
		PrintProgress("Honky Tonk Hero",trophycounter["Honky Tonk Hero"],50);
	if (trophycounter["Cantina Commander"]>50) // don't display until past "50"
		PrintProgress("Cantina Commander",trophycounter["Cantina Commander"],100);


	PrintProgress("Apprentice Meatsmacker",trophycounter["Apprentice Meatsmacker"],50);
	if (trophycounter["Journeyman Meatsmacker"]>50) // don't display until past "50"
		PrintProgress("Journeyman Meatsmacker",trophycounter["Journeyman Meatsmacker"],100);
	if (trophycounter["Master Meatsmacker"]>100) // don't display until past "100"
		PrintProgress("Master Meatsmacker",trophycounter["Master Meatsmacker"],150);

	PrintProgress("Preciousss",trophycounter["Preciousss"],30);


//	PrintProgress("Tiny Plastic Trophy",trophycounter["Tiny Plastic Trophy"],64);
//	PrintProgress("Two-Tiered Tiny Plastic Trophy",trophycounter["Two-Tiered Tiny Plastic Trophy"],64);

}

MainTrophyInfo();

void main()
{
	TrophyProgressAll();
}