int sumIt(item it)
{
	return (item_amount(it) + closet_amount(it) + display_amount(it) + equipped_amount(it) + storage_amount(it));
}
int outfitSum(item i1,item i2,item i3)
{
	return (sumIt(i1) +sumIt(i2) + sumIt(i3));
}

void outfitDisp(string what,item i1,item i2,item i3)
{
	int oTot=sumIt(i1) +sumIt(i2) + sumIt(i3);
	if( oTot < 3 )
	{
		print("Pieces of " + what + " - " + oTot, "red");
	}
	else
	{
		print("Pieces of " + what + " - " + oTot, "blue");
	}
}
void dispItem(item what)
{
	int iTot = sumIt(what);
	if( iTot == 0 )
	{
		print(what + " - " + iTot, "red");
	}
	else
	{
		print(what + " - " + iTot, "blue");
	}

//print(what + ": " + sumIt(what));
}
void main()
{
	string skill_list = visit_url ("charsheet.php");
	//Mother Slime
	print(">> Mother Slime");
	outfitDisp("slime suit",$item[hardened slime hat],$item[hardened slime belt],$item[hardened slime pants]);
	dispItem($item[hardened slime hat]);
	dispItem($item[hardened slime pants]);
	dispItem($item[hardened slime belt]);
	dispItem($item[slime-soaked brain]);
	string slime_brain = visit_url ("desc_skill.php?whichskill=47&self=true");
	if(index_of(slime_brain , "Slimy Synapses" )!=-1)
		{
			if(slime_brain.contains_text("Your synapses are 10% lubricated")) print("You have used 1 slime-soaked brain, 9 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 20% lubricated")) print("You have used 2 slime-soaked brains, 8 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 30% lubricated")) print("You have used 3 slime-soaked brains, 7 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 40% lubricated")) print("You have used 4 slime-soaked brains, 6 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 50% lubricated")) print("You have used 5 slime-soaked brains, 5 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 60% lubricated")) print("You have used 6 slime-soaked brains, 4 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 70% lubricated")) print("You have used 7 slime-soaked brains, 3 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 80% lubricated")) print("You have used 8 slime-soaked brains, 2 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are 90% lubricated")) print("You have used 9 slime-soaked brains, 1 left to go!" , "green");
			if(slime_brain.contains_text("Your synapses are maximally lubricated")) print("You have used 10 slime-soaked brains!" , "green");
			if(!skill_list.contains_text("Slimy Synapses")) print("You have not used any slime-soaked brains" , "red");
		}
	else
		{
			print("You cannot access your skills at the moment");
		}
	dispItem($item[slime-soaked hypophysis]);
	string slime_hypophysis = visit_url ("desc_skill.php?whichskill=46&self=true");
	if(index_of(slime_hypophysis , "Slimy Sinews" )!=-1)
		{
			if(slime_hypophysis.contains_text("Your sinews are 10% lubricated")) print("You have used 1 slime-soaked hypophysis, 9 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 20% lubricated")) print("You have used 2 slime-soaked hypophyses, 8 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 30% lubricated")) print("You have used 3 slime-soaked hypophyses, 7 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 40% lubricated")) print("You have used 4 slime-soaked hypophyses, 6 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 50% lubricated")) print("You have used 5 slime-soaked hypophyses, 5 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 60% lubricated")) print("You have used 6 slime-soaked hypophyses, 4 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 70% lubricated")) print("You have used 7 slime-soaked hypophyses, 3 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 80% lubricated")) print("You have used 8 slime-soaked hypophyses, 2 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are 90% lubricated")) print("You have used 9 slime-soaked hypophyses, 1 left to go!" , "green");
			if(slime_hypophysis.contains_text("Your sinews are maximally lubricated")) print("You have used 10 slime-soaked hypophyses!" , "green");
			if(!skill_list.contains_text("Slimy Sinews")) print("You have not used any slime-soaked hypophyses" , "red");
		}
	else
		{
			print("You cannot access your skills at the moment");
		}
	dispItem($item[slime-soaked sweat gland]);
	string slime_sweat = visit_url ("desc_skill.php?whichskill=48&self=true");
	if(index_of(slime_sweat , "Slimy Shoulders" )!=-1)
		{
			if(slime_sweat.contains_text("Your shoulders are 10% lubricated")) print("You have used 1 slime-soaked sweat gland, 9 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 20% lubricated")) print("You have used 2 slime-soaked sweat glands, 8 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 30% lubricated")) print("You have used 3 slime-soaked sweat glands, 7 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 40% lubricated")) print("You have used 4 slime-soaked sweat glands, 6 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 50% lubricated")) print("You have used 5 slime-soaked sweat glands, 5 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 60% lubricated")) print("You have used 6 slime-soaked sweat glands, 4 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 70% lubricated")) print("You have used 7 slime-soaked sweat glands, 3 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 80% lubricated")) print("You have used 8 slime-soaked sweat glands, 2 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are 90% lubricated")) print("You have used 9 slime-soaked sweat glands, 1 left to go!" , "green");
			if(slime_sweat.contains_text("Your shoulders are maximally lubricated")) print("You have used 10 slime-soaked sweat glands!" , "green");
			if(!skill_list.contains_text("Slimy Shoulders")) print("You have not used any slime-soaked sweat glands" , "red");
		}
	else
		{
			print("You cannot access your skills at the moment");
		}
	dispItem($item[slimy alveolus]);	
	dispItem($item[chamoisole]);
	dispItem($item[caustic slime nodule]);
	dispItem($item[squirming Slime larva]);
	string slime_fam = visit_url("familiar.php");	
	if(index_of(slime_fam , "contains the following creatures")!=-1)
	{	
		if(slime_fam.contains_text("slimeling.gif")) print("You have a slimeling" , "green");
		if(!slime_fam.contains_text("slimeling.gif")) print("You do not have a slimeling" , "red");
	}
	else
	{
		print("You are currently unable to access your familiars" , "red" );
	}
	
	//Slime Drops
	print(">> Slime Drops");
	dispItem($item[big slimy cyst]);
	dispItem($item[Coily]);
	dispItem($item[crown-shaped beanie]);
	dispItem($item[crusty hula hoop]);
	dispItem($item[hopping socks]);
	dispItem($item[lawn dart]);
	dispItem($item[letterman's jacket]);
	dispItem($item[medium slimy cyst]);
	dispItem($item[old-school flying disc]);
	dispItem($item[poodle skirt]);
	dispItem($item[red wagon]);
	dispItem($item[rickety old unicycle]);
	dispItem($item[slimy fermented bile bladder]);
	dispItem($item[slimy sweetbreads]);
	dispItem($item[wad of slimy rags]);
	
	//Marbles
	print(">> Marbles");
	dispItem($item[small slimy cyst]);
	dispItem($item[tiny slimy cyst]);
	dispItem($item[beach ball marble]);
	dispItem($item[beige clambroth marble]);
	dispItem($item[big bumboozer marble]);
	dispItem($item[black catseye marble]);
	dispItem($item[brown crock marble]);
	dispItem($item[bumblebee marble]);
	dispItem($item[green peawee marble]);
	dispItem($item[jet bennie marble]);
	dispItem($item[lemonade marble]);
	dispItem($item[red china marble]);
	dispItem($item[steely marble]);

	//Slime-covered items
	print(">> Slime-covered items");
	dispItem($item[slime-covered club]);
	dispItem($item[slime-covered compass]);
	dispItem($item[slime-covered greaves]);
	dispItem($item[slime-covered helmet]);	
	dispItem($item[slime-covered lantern]);
	dispItem($item[slime-covered necklace]);
	dispItem($item[slime-covered shovel]);
	dispItem($item[slime-covered speargun]);
	
	
	//Crafted Caustic slime nodules
	print(">> Crafted caustic slime nodules");
	dispItem($item[baneful bandolier]);
	dispItem($item[bitter pill]);
	dispItem($item[corroded breeches]);
	dispItem($item[corrosive cowl]);	
	dispItem($item[diabolical crossbow]);
	dispItem($item[grisly shield]);
	dispItem($item[malevolent medallion]);
	dispItem($item[pernicious cudgel]);
	dispItem($item[villainous scythe]);

	
	//Candy
	print(">> Candy");
	dispItem($item[children of the candy corn]);
	dispItem($item[Good 'n' Slimy]);
	
	//Misc
	print(">> Misc");
	dispItem($item[big bundle of chamoix]);
	dispItem($item[moist sack]);
	
}