//structure for a plant
record plant
{
	string name;
	int zone_type;
	int number;
	boolean territorial;
	float amount;
	string bonus_type;
};

//0 - outdoor
//1 - indoor
//2 - underground
//3 - underwater
int zone_type(location loc)
{
	//outdoor
	if($locations[the very unquiet garves, pandamonium slums, the sleazy back alley, Sonofa Beach, The Battlefield (hippy uniform), 8-bit realm, The Obligatory Pirate's Cove, The Goatlet, The eXtreme Slope, The F'c'le, The Smut Orc Logging Camp, A-Boo Peak, The Spooky Forest, Oil Peak, The Penultimate Fantasy Airship, The Black Forest, The Poop Deck, Inside the Palindome, Whitey's Grove, The Arid\, Extra-Dry Desert, The Oasis, wartime Frat House, McMillicancuddy's Pond, mcmillicancuddy's back 40, mcmillicancuddy's other back 40, The Themthar Hills, Over Where the Old Tires Are, Out By that Rusted-Out Car, The Hole in the Sky, the outskirts of cobb's knob, The Dark Elbow of the Woods, The Dark Heart of the Woods, The Dark Neck of the Woods, Hippy Camp, The Valley of Rof L'm Fao, Next to that Barrel with Something Burning in it, Near an Abandoned Refrigerator, Twin Peak, Fear Man's Level, The Hidden Park,An Overgrown Shrine (Northwest), A Massive Ziggurat] contains loc)
		return 0;
	
	//indoor
	if($locations[Lair of the Ninja Snowmen, The Haunted Library, The Haunted Conservatory, The Haunted Gallery, The Haunted Bedroom, Barrrney's Barrr, The Haunted Ballroom, The Castle in the Clouds in the Sky (Ground Floor), The Castle in the Clouds in the Sky (Top Floor), Belowdecks, McMillicancuddy's Barn, The Haunted Pantry, Infernal Rackets Backstage, The Laugh Floor, The Haunted Billiards Room, The Haunted Bathroom, The Hidden Apartment Building, The Hidden Office Building, The Hidden Bowling Alley, The hidden hospital, The Haunted Kitchen, The Haunted Laboratory, The Haunted Storage Room, The Haunted Wine Cellar,The Haunted Laundry Room, The Haunted Boiler Room, The Copperhead Club] contains loc)
		return 1;
	
	//underground
	if($locations[The Batrat and Ratbat Burrow, Guano Junction, The Upper Chamber, The Middle Chamber, Cobb's Knob Barracks, Cobb's Knob Kitchens, The Defiled Nook, The Defiled Alcove, The Defiled Cranny, The Defiled Niche, Itznotyerzitz Mine, The Enormous Greater-Than Sign, The Dungeons of Doom, The Beanbat Chamber, The Castle in the Clouds in the Sky (Basement), Cobb's Knob Laboratory, The Royal Guard Chamber, The Filthworm Queen's Chamber, The Bat Hole Entrance, The Boss Bat's Lair, The Feeding Chamber,Cobb's Knob Harem,The hatching chamber, cobb's knob menagerie\, level 1, cobb's knob menagerie\, level 2, The Haiku Dungeon] contains loc)
		return 2;
		
	//underwater
	if($locations[An Octopus's Garden, The Marinara Trench, The mer-kin outpost, The coral corral, The Wreck of the Edgar Fitzsimmons, The Dive Bar, Anemone Mine, Madness Reef, The Caliginous Abyss, The Briny Deeps, The Brinier Deepers, The Briniest Deepests, Mer-kin Colosseum, mer-kin library] contains loc)
		return 3;
		
	//no enemies so don't bother
//	if($locations[The Hidden Temple] contains loc)
//		return 1;
		
	abort("unknown location type for "+loc);
	return -1;
}

//tidy up the zone text to fit mafia style
location mafia_style_zone(string loc)
{
	//remove "The " prefix whioch mafia doesn't seem to like
//	if(substring(loc,0,4)=="The ")
//		loc=substring(loc,4);
	//modify text
/*	if(loc=="Sonofa Beach")
		loc="Sonofa Beach";
	else if(loc=="Obligatory Pirate's Cove")
		loc="The Obligatory Pirate's Cove";
	else if(loc=="Enormous The Enormous Greater-Than Sign")
		loc="The Enormous Greater-Than Sign";
	else if(loc=="Penultimate The Penultimate Fantasy Airship")
		loc="The Penultimate Fantasy Airship";
	else if(loc=="Royal Guard Chamber")
		loc="The Royal Guard Chamber";
	else if(loc=="Filthworm The Filthworm Queen's Chamber")
		loc="The Filthworm Queen's Chamber";
	else if(loc=="McMillicancuddy's McMillicancuddy's Barn")
		loc="McMillicancuddy's Barn";
	else if(loc=="McMillicancuddy's McMillicancuddy's Pond")
		loc="McMillicancuddy's Pond";
	else if(loc=="Bat Hole Entrance")
		loc="The Bat Hole Entrance";
	else if(loc=="Laugh Floor")
		loc="The Laugh Floor";
	else */ if(loc=="Hidden City")
		loc="Hidden City (Automatic)";
	else if(loc=="The Orcish Frat House")
		loc="wartime Frat House";
	else if(loc=="[DungeonFAQ - Level 1]")
		loc="Video Game Level 1";
	else if(loc=="The Cola Wars Battlefield")
		loc="battlefield (no uniform)";
		
	
		
		
	//<>
	else
	{
		//try direct parse
		location loca = to_location(loc);
		if(loca==$location[none])
			abort("The location string "+loc+" was parsed as zone "+loca);
		return loca;
	}
	//return location object
	return to_location(loc);
}

//has the plant been used today
//may be able to use mafia tracking?
boolean is_unused(plant pl, string html)
{
//	<td><b>Rabid Dogwood</b>   </td><td class=small>(there's already one of these!)</td><td>
//	<td><b>Rutabeggar</b>   </td><td class=small><font color=blue><b>+25% Item drops</b></font> (territorial)</td><td>
	matcher plant_hdr=create_matcher("(<td><b>"+pl.name+"</b>&nbsp;&nbsp;&nbsp;</td><td class=small>)",html);
	if(!plant_hdr.find())
	{
		print("Couldn't find requested plant "+pl.name,"red");
		print(html,"red");
		abort("");
	}
	//skip to the end of header
	int plant_pos=end(plant_hdr);
	
	//is it directly followed by "(there's already one of these!)" or "(out of stock, come back tomorrow!)"
	int used_note_pos1=index_of(html, "(there's already one of these!)",plant_pos);
	int used_note_pos2=index_of(html, "(out of stock, come back tomorrow!)",plant_pos);
//	print("header for plant "+pl.name+" at "+plant_pos+" used note at "+used_note_pos);
	return (used_note_pos1!=plant_pos && used_note_pos2!=plant_pos);
}

//have we put a territorial plant down here
boolean territorial_placed(string html)
{
	//('Really destroy your existing territorial plants?')
	return (index_of(html,"('Really destroy your existing territorial plants?')")!= -1);
}

//how many are already planted here?
int number_planted(string html)
{
	//after floristfriar.gif, how many noplant.gif can we find?
	int friar_idx=index_of(html,"floristfriar.gif");
	if(friar_idx==-1)
	{
		print("Couldn't find picture of florist friar ","red");
		print(html,"red");
		abort("");
	}
	string sub_html = substring(html,friar_idx);
	
	//count noplant.gifs
	int num_planted=3;
	int noplant_idx=index_of(sub_html,"noplant.gif");
	while(noplant_idx!=-1)
	{
		num_planted-=1;
		noplant_idx=index_of(sub_html,"noplant.gif",noplant_idx+11);
	}
	return num_planted;
}

//can we use this plant (not used, enough space and wont destroy another)
boolean is_usable(plant pl, location loc, string html)
{

	return (zone_type(loc)==pl.zone_type) &&
		is_unused(pl,html) &&
		!(territorial_placed(html) && pl.territorial) && 
		(number_planted(html)!=3);
		
}

string place_plant(plant pl)
{
	print("Planting a "+pl.name,"green");
	return visit_url("choice.php?whichchoice=720&option=1&plant="+pl.number);
}

//from a culled list, choose which plant to use of a given type
//using naming scheme from bumcheekascend setMood()
//meat isn't specifically checked for since only underwater plants provide it
int choose_best_plant(string type, location loc, plant[int] plants)
{
	//first pass checks for exactly what we wanted
	foreach pli in plants
	{
		//looking for items?
		if(plants[pli].bonus_type=="items")
		{
			if(contains_text(type,"i"))
				return pli;
		}
		//looking for initiative?
		if(contains_text(type,"n") && plants[pli].bonus_type=="initiative")
			return pli;
		//looking for ml?
		if(contains_text(type,"l") && plants[pli].bonus_type=="ml")
			return pli;
	}
	print("failed to find exactly what we want");
	
	//second pass chooses something useful
	foreach str in $strings[exp, ml, moxie exp, muscle exp, mysticality exp, Damage Absorption, Weakens Monster, hp regen min, mp regen min, initiative, meat]
	{
		foreach pli in plants
		{
			if(plants[pli].bonus_type==str)
				return pli;
		}
	}
	print("Failed to find a useful bonus, lets check for damaging plants");
	if(type=="gre")
	{
		print("not using damage platns against gremlins","green");
		return -1;
	}
	
	//third pass chooses a suitable damage plant for zone
	foreach pli in plants
	{
		if(contains_text(plants[pli].bonus_type,"damage"))
		{ 		
			if(contains_text(plants[pli].bonus_type,"cold"))
			{
				if(loc!=$location[The Icy Peak] && loc!=$location[Lair of the Ninja Snowmen] && loc!=$location[exposure esplanade] && loc!=$location[McMillicancuddy's Pond])
					return pli;
			}
			else if(contains_text(plants[pli].bonus_type,"hot"))
			{
				if(loc!=$location[Burnbarrel Blvd.] && loc!=$location[mcmillicancuddy's back 40] && loc!=$location[The Dark neck of the woods] && loc!=$location[The Dark heart of the woods] && loc!=$location[The Dark elbow of the woods] && loc!=$location[Infernal Rackets Backstage] && loc!=$location[The Laugh Floor] && loc!=$location[pandamonium slums] && loc!=$location[cobb's knob kitchens] && loc!=$location[The Haunted pantry] && loc!=$location[The Outskirts of Cobb's Knob] && loc!=$location[The Arid\, Extra-Dry Desert])
					return pli;
			}
			else if(contains_text(plants[pli].bonus_type,"sleaze"))
			{
				if(loc!=$location[The Battlefield (Hippy uniform)] && loc!=$location[The Orcish Frat House (Bombed Back to the Stone Age)] && loc!=$location[Frat House] && loc!=$location[The Hole in the sky] && loc!=$location[mcmillicancuddy's other back 40] && loc!=$location[The Purple Light District] && loc!=$location[The eXtreme Slope] && loc!=$location[the \"fun\" house] && loc!=$location[Tower Ruins] && loc!=$location[The Obligatory Pirate's Cove] && loc!=$location[The Road to the White Citadel]&& loc!=$location[The Degrassi Knoll Gym]&& loc!=$location[Anemone Mine]&& loc!=$location[Cobb's Knob Harem])
					return pli;
			}
			else if(contains_text(plants[pli].bonus_type,"stench"))
			{
				if(loc!=$location[The Heap] && loc!=$location[mcmillicancuddy's bog] && loc!=$location[hippy camp] && loc!=$location[The Hippy Camp (Bombed Back to the Stone Age)] && loc!=$location[ The Battlefield (frat uniform)] && loc!=$location[The Road to the White Citadel] && loc!=$location[The F'c'le] && loc!=$location[The eXtreme Slope] && loc!=$location[The Haunted Pantry] && loc!=$location[The Sleazy Back Alley] && loc!=$location[the bugbear pen] && loc!=$location[post-quest bugbear pens] && loc!=$location[The hatching chamber] && loc!=$location[The Feeding Chamber] && loc!=$location[The Royal Guard Chamber] && loc!=$location[The Filthworm Queen's Chamber])
					return pli;
			}
			else if(contains_text(plants[pli].bonus_type,"spooky"))
			{
				if(loc!=$location[The Ancient Hobo Burial Ground] && loc!=$location[McMillicancuddy's Family Plot] && loc!=$location[the very unquiet garves] && loc!=$location[the unquiet garves] && loc!=$location[The Spooky Gravy Burrow] && loc!=$location[the bugbear pen] && loc!=$location[post-quest bugbear pens] && loc!=$location[The Haunted library] && loc!=$location[The Haunted billiards room] && loc!=$location[the \"fun\" house] && loc!=$location[The Marinara Trench] && loc!=$location[The Wreck of the Edgar Fitzsimmons] && loc!=$location[The Haunted gallery] && loc!=$location[The Haunted ballroom] && loc!=$location[Spectral Pickle Factory] && loc!=$location[the knob shaft] && loc!=$location[The Haunted bathroom] && loc!=$location[The Haunted bedroom] && loc!=$location[The Haunted conservatory] && loc!=$location[The Haunted kitchen] && loc!=$location[The Spooky Forest] && loc!=$location[The Haunted pantry] && loc!=$location[The Oasis] && loc!=$location[The Middle Chamber] && loc!=$location[The Upper Chamber] && loc!=$location[The Defiled nook] && loc!=$location[The Defiled niche] && loc!=$location[The Defiled cranny] && loc!=$location[The Defiled alcove])
					return pli;
			}
			else if(contains_text(plants[pli].bonus_type,"weapon"))
			{
				if(loc!=$location[The Haunted billiards room] && loc!=$location[the knob shaft] && loc!=$location[The Icy Peak] && loc!=$location[Tower Ruins])
					return pli;
			}
		}
	}
	
	return -1;
}

void choose_all_plants(string type, location loc)
{
	if(my_name()!="twistedmage")
		return;
	//get friars html
	string friar_str=visit_url("place.php?whichplace=forestvillage&action=fv_friar");
	//string friar_str=visit_url("choice.php?option=4&whichchoice=720");
	if(contains_text(friar_str,"go scout out an appropriate location for me to plant something")
	|| contains_text(friar_str,"You can't get there") || contains_text(friar_str,"bakery.gif"))
	{
		print("No current zone");
		//force mafia to recognise that we quit the choiceadv?
		visit_url("forestvillage.php");
		return;
	}
	
	//are we in the location we think we are?
	//<td>Ah, <b>The Battlefield (Hippy Uniform)</b>! I have a numbe
	matcher cur_locm = create_matcher("Ah, <b>([,\\.0-9a-zA-Z \\(\\)\\'\\-\\!\\[\\]]*)</b>\\!",friar_str);
	if(!cur_locm.find())
	{
		print("Couldn't detect location from string ","red");
		print(friar_str,"red");
		abort("");
	}
	location cur_loc=mafia_style_zone(cur_locm.group(1));
	if(cur_loc!=loc)
	{
		visit_url("forestvillage.php");
		return;
	}
	
	//do we have any space here?
	int num_planted=number_planted(friar_str);
	if(num_planted>2)
	{
		//force mafia to recognise that we quit the choiceadv?
		visit_url("forestvillage.php");
		return;
	}
	
	//load plants map
	plant[int] plants;
	file_to_map("flowers.txt",plants);
	
	//cull map to only usable
	foreach pli in plants
		if(!is_usable(plants[pli],loc,friar_str))
			remove plants[pli];
	
	//do the planting 
	while(num_planted<3 && count(plants)!=0)
	{
		int pli=choose_best_plant(type,loc,plants);
		
		//was anything left useful?
		if(pli==-1)
		{
			//force mafia to recognise that we quit the choiceadv?
			visit_url("forestvillage.php");
			visit_url("main.php");
			return;
		}

		friar_str = place_plant(plants[pli]);
		remove plants[pli];
		num_planted=number_planted(friar_str);
	}
	//force mafia to recognise that we quit the choiceadv?
	visit_url("forestvillage.php");
	visit_url("main.php");
}

void main()
{
	print("debugging florist script","blue");

	plant[int] plants;
	file_to_map("flowers.txt",plants);
	
	//debug, list plants loaded
	foreach pl in plants
		print(pl+" "+plants[pl].name);
}