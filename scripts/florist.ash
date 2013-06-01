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
print("checking zone type for "+loc);
	//outdoor
	if($locations[wartime sonofa beach, battlefield (hippy uniform), 8-bit realm, pirate cove, Goatlet, eXtreme Slope, F'c'le, Smut Orc Logging Camp, A-Boo Peak, Spooky Forest, Oil Peak, Fantasy Airship, Black Forest, Poop Deck, Palindome, Whitey's Grove, Desert (ultrahydrated), Oasis in the Desert, wartime Frat House, Pond, back 40, Other Back 40, Themthar Hills, Over Where the Old Tires Are, Out By that Rusted-Out Car, Hole in the Sky, outskirts of the knob, Dark Elbow of the Woods, Dark Heart of the Woods, Dark Neck of the Woods, Hippy Camp, Orc Chasm, Next to that Barrel with Something Burning in it, Near an Abandoned Refrigerator, Hidden City (Automatic)] contains loc)
		return 0;
	
	//indoor
	if($locations[Haunted Library, Haunted Conservatory, Haunted Gallery, Haunted Bedroom, Barrrney's Barrr, Haunted Ballroom, Giant's Castle (Ground Floor), Giant's Castle (Top Floor), Belowdecks, Barn, Haunted Pantry, Hey Deze Arena, Belilafs Comedy Club, Haunted Billiards Room, Haunted Bathroom] contains loc)
		return 1;
	
	//underground
	if($locations[upper chamber, middle chamber, Cobb's Knob Barracks, Cobb's Knob Kitchens, Defiled Nook, Defiled Alcove, Defiled Cranny, Defiled Niche, Itznotyerzitz Mine, Greater-Than Sign, Dungeons of Doom, Beanbat Chamber, Giant's Castle (Basement), Cobb's Knob Laboratory, Haunted Wine Cellar (Southwest), Haunted Wine Cellar (Southeast), Haunted Wine Cellar (northwest), Haunted Wine Cellar (northeast), Guards' Chamber, Queen's chamber, Bat Hole Entryway, Boss Bat's Lair, Feeding Chamber] contains loc)
		return 2;
		
	//underwater
	if($locations[An Octopus's Garden, Marinara Trench, mer-kin outpost, coral corral, Wreck of the Edgar Fitzsimmons, Dive Bar, Anemone Mine, Madness Reef, Caliginous Abyss, Briny Deeps, Brinier Deepers, Briniest Deepest, Mer-kin Colosseum, mer-kin library] contains loc)
		return 3;
		
	//no enemies so don't bother
	if($locations[Hidden Temple] contains loc)
		return 1;
		
	abort("unknown location type for "+loc);
	return -1;
}

//tidy up the zone text to fit mafia style
location mafia_style_zone(string loc)
{
	//remove "The " prefix whioch mafia doesn't seem to like
	if(substring(loc,0,4)=="The ")
		loc=substring(loc,4);
	//modify text
	if(loc=="Sonofa Beach")
		loc="wartime sonofa beach";
	else if(loc=="Obligatory Pirate's Cove")
		loc="Pirate Cove";
	else if(loc=="Enormous Greater-Than Sign")
		loc="Greater-Than Sign";
	else if(loc=="Penultimate Fantasy Airship")
		loc="Fantasy Airship";
	else if(loc=="Castle in the Clouds in the Sky (Basement)")
		loc="Giant's Castle (Basement)";
	else if(loc=="Castle in the Clouds in the Sky (Ground Floor)")
		loc="Giant's Castle (Ground Floor)";
	else if(loc=="Castle in the Clouds in the Sky (Top Floor)")
		loc="Giant's Castle (Top Floor)";
	else if(loc=="Castle in the Clouds in the Sky (Top Floor)")
		loc="Giant's Castle (Top Floor)";
	else if(loc=="Arid, Extra-Dry Desert")
		loc="Desert (ultrahydrated)";
	else if(loc=="Orcish Frat House")
		loc="wartime Frat House";
	else if(loc=="Royal Guard Chamber")
		loc="Guards' Chamber";
	else if(loc=="Filthworm Queen's Chamber")
		loc="Queen's Chamber";
	else if(loc=="McMillicancuddy's Barn")
		loc="Barn";
	else if(loc=="McMillicancuddy's Pond")
		loc="Pond";
	else if(loc=="McMillicancuddy's Back 40")
		loc="Back 40";
	else if(loc=="McMillicancuddy's Other Back 40")
		loc="Other Back 40";
	else if(loc=="Outskirts of Cobb's Knob")
		loc="outskirts of the knob";
	else if(loc=="Bat Hole Entrance")
		loc="Bat Hole Entryway";
	else if(loc=="Infernal Rackets Backstage")
		loc="Hey Deze Arena";
	else if(loc=="Laugh Floor")
		loc="Belilafs Comedy Club";
	else if(loc=="Valley of Rof L'm Fao")
		loc="Orc Chasm";
	else if(loc=="Hidden City")
		loc="Hidden City (Automatic)";
	
	
		
		
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
print("checking usage of "+pl.name+" in zone_type "+pl.zone_type);
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
	print("currently "+num_planted+" plants in the zone","lime");
	return num_planted;
}

//can we use this plant (not used, enough space and wont destroy another)
boolean is_usable(plant pl, location loc, string html)
{

print("checking "+pl.name);
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
		print("plant "+pli+" of "+count(plants)+" gives "+plants[pli].bonus_type+" and we want "+type);
		//looking for items?
		if(plants[pli].bonus_type=="items")
		{
			if(!contains_text(type,"i"))
				remove plants[pli]; //don't waste it in a non item zone
			else
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
			print("plant "+pli+" of "+count(plants)+" gives "+plants[pli].bonus_type+" and we want "+str);
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
			print("plant "+plants[pli].name+" of "+count(plants)+" gives "+plants[pli].bonus_type+" and we want damage");
			
			if(contains_text(plants[pli].bonus_type,"cold"))
			{
				if(loc!=$location[icy peak] && loc!=$location[Ninja Snowmen] && loc!=$location[exposure esplanade] && loc!=$location[Pond])
					return pli;
				else
					remove plants[pli];
			}
			else if(contains_text(plants[pli].bonus_type,"hot"))
			{
				if(loc!=$location[Burnbarrel Blvd.] && loc!=$location[Back 40] && loc!=$location[dark neck of woods] && loc!=$location[dark heart of woods] && loc!=$location[dark elbow of woods] && loc!=$location[hey deze arena] && loc!=$location[belilafs comedy club] && loc!=$location[pandamonium slums] && loc!=$location[cobb's knob kitchens] && loc!=$location[haunted pantry] && loc!=$location[outskirts of the knob] && loc!=$location[desert (ultrahydrated)])
					return pli;
				else
					remove plants[pli];
			}
			else if(contains_text(plants[pli].bonus_type,"sleaze"))
			{
				if(loc!=$location[Battlefield (Hippy uniform)] && loc!=$location[Frat House (Stone Age)] && loc!=$location[Frat House] && loc!=$location[Hole in Sky] && loc!=$location[Other Back 40] && loc!=$location[purple light district] && loc!=$location[extreme slope] && loc!=$location[fun house] && loc!=$location[ruins] && loc!=$location[Pirate Cove] && loc!=$location[White Citadel]&& loc!=$location[Degrassi Knoll]&& loc!=$location[Anemone Mine]&& loc!=$location[Cobb's Knob Harem])
					return pli;
				else
					remove plants[pli];
			}
			else if(contains_text(plants[pli].bonus_type,"stench"))
			{
				if(loc!=$location[heap] && loc!=$location[bog] && loc!=$location[hippy camp] && loc!=$location[Hippy Camp (Stone Age)] && loc!=$location[ Battlefield (frat uniform)] && loc!=$location[White Citadel] && loc!=$location[F'c'le] && loc!=$location[eXtreme Slope] && loc!=$location[Haunted Pantry] && loc!=$location[sleazy back alley] && loc!=$location[bugbear pens] && loc!=$location[hatching chamber] && loc!=$location[feeding chamber] && loc!=$location[guards chamber] && loc!=$location[queens chamber])
					return pli;
				else
					remove plants[pli];
			}
			else if(contains_text(plants[pli].bonus_type,"spooky"))
			{
				if(loc!=$location[ancient hobo burial ground] && loc!=$location[family plot] && loc!=$location[post-cyrpt cemetary] && loc!=$location[pre-cyrpt cemetary] && loc!=$location[Spooky Gravy Barrow] && loc!=$location[bugbear pens] && loc!=$location[haunted library] && loc!=$location[haunted billiards room] && loc!=$location[fun house] && loc!=$location[Marinara Trench] && loc!=$location[Wreck of Edgar Fitzsimmons] && loc!=$location[haunted gallery] && loc!=$location[haunted ballroom] && loc!=$location[Spectral Pickle Factory] && loc!=$location[knob shaft] && loc!=$location[haunted bathroom] && loc!=$location[haunted bedroom] && loc!=$location[haunted conservatory] && loc!=$location[haunted kitchen] && loc!=$location[spooky forest] && loc!=$location[haunted pantry] && loc!=$location[oasis] && loc!=$location[middle chamber] && loc!=$location[upper chamber] && loc!=$location[defiled nook] && loc!=$location[defiled niche] && loc!=$location[defiled cranny] && loc!=$location[defiled alcove])
					return pli;
				else
					remove plants[pli];
			}
			else if(contains_text(plants[pli].bonus_type,"weapon"))
			{
				if(loc!=$location[haunted billiards room] && loc!=$location[knob shaft] && loc!=$location[icy peak] && loc!=$location[ruins])
					return pli;
				else
					remove plants[pli];
			}
		}
	}
	//quit if the only plants left were unsuitable
	if(count(plants)==0)
		return -1;
	//abort if we get here
	print("got to the end of plants loop, "+count(plants)+" plants were unused","red");
	foreach pli in plants
		print(pli+" "+plants[pli].name,"red");
	abort("fix it");
	return -1;
}

void choose_all_plants(string type, location loc)
{
	if(my_name()!="twistedmage")
		return;
	//get friars html
	string friar_str=visit_url("forestvillage.php?action=floristfriar");
	//string friar_str=visit_url("choice.php?option=4&whichchoice=720");
	if(contains_text(friar_str,"go scout out an appropriate location for me to plant something"))
	{
		print("No current zone");
		//force mafia to recognise that we quit the choiceadv?
		visit_url("forestvillage.php");
		return;
	}
	
	//are we in the location we think we are?
	//<td>Ah, <b>The Battlefield (Hippy Uniform)</b>! I have a numbe
	matcher cur_locm = create_matcher("Ah, <b>([,0-9a-zA-Z \\(\\)\\'\\-]*)</b>\\!",friar_str);
	if(!cur_locm.find())
	{
		print("Couldn't detect location from string ","red");
		print(friar_str,"red");
		abort("");
	}
	print("Friars zone string="+cur_locm.group(1),"blue");
	location cur_loc=mafia_style_zone(cur_locm.group(1));
	print("mafia style loc="+cur_loc,"blue");
	if(cur_loc!=loc)
		return;
	
	//do we have any space here?
	int num_planted=number_planted(friar_str);
print("num planted="+num_planted);
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
print("possible plants="+ count(plants));
	while(num_planted<3 && count(plants)!=0)
	{
		int pli=choose_best_plant(type,loc,plants);
		
		//was anything left useful?
		if(pli==-1)
		{
			//force mafia to recognise that we quit the choiceadv?
			visit_url("forestvillage.php");
			return;
		}

		friar_str = place_plant(plants[pli]);
		remove plants[pli];
		num_planted=number_planted(friar_str);
	}
	//force mafia to recognise that we quit the choiceadv?
	visit_url("forestvillage.php");
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