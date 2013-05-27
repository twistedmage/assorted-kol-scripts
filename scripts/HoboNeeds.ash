int sumIt(item it)
{
	return (item_amount(it) + closet_amount(it) + display_amount(it) + equipped_amount(it) + storage_amount(it));
}
int outfitSum(item i1,item i2,item i3)
{
	return (sumIt(i1) +sumIt(i2) + sumIt(i3));
}

string skill_list = visit_url ("charsheet.php");

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
	//frosty
	print(">> Frosty");
	outfitDisp("Hyperborean Hobo Habiliments",$item[Frosty's carrot],$item[Frosty's nailbat],$item[Frosty's old silk hat]);
	dispItem($item[Frosty's carrot]);
	dispItem($item[Frosty's iceball]);
	dispItem($item[Frosty's nailbat]);
	dispItem($item[Frosty's old silk hat]);
	dispItem($item[Frosty's snowball sack]);
	dispItem($item[Frosty's arm]);
	
	
	
	//scratch
	print(">> Ol' Scratch");
	outfitDisp("Pyretic Panhandler Paraphernalia",$item[Ol' Scratch's ash can],$item[Ol' Scratch's ol' britches],$item[Ol' Scratch's stovepipe hat]);
	dispItem($item[Ol' Scratch's ash can]);
	dispItem($item[Ol' Scratch's infernal pitchfork]);
	dispItem($item[Ol' Scratch's manacles]);
	dispItem($item[Ol' Scratch's ol' britches]);
	dispItem($item[Ol' Scratch's stove door]);
	dispItem($item[Ol' Scratch's stovepipe hat]);

	
	//Oscus
	print(">> Oscus");
	outfitDisp("Vile Vagrant Vestments",$item[Oscus's dumpster waders],$item[Oscus's pelt],$item[Wand of Oscus]);
	dispItem($item[Oscus's dumpster waders]);
	dispItem($item[Oscus's flypaper pants]);
	dispItem($item[Oscus's garbage can lid]);
	dispItem($item[Oscus's neverending soda]);	
	dispItem($item[Oscus's pelt]);
	dispItem($item[Wand of Oscus]);
	
	
	//Zombo
	print(">> Zombo");
	outfitDisp("Dire Drifter Duds",$item[Zombo's grievous greaves],$item[Zombo's shield],$item[Zombo's skullcap]);
	dispItem($item[Zombo's empty eye]);
	dispItem($item[Zombo's grievous greaves]);
	dispItem($item[Zombo's shield]);
	dispItem($item[Zombo's shoulder blade]);	
	dispItem($item[Zombo's skull ring]);
	dispItem($item[Zombo's skullcap]);

	
	//Chester
	print(">> Chester");
	outfitDisp("Tawdry Tramp Togs",$item[Chester's bag of candy],$item[Chester's cutoffs],$item[Chester's moustache]);
	dispItem($item[Chester's Aquarius medallion]);
	dispItem($item[Chester's bag of candy]);
	dispItem($item[Chester's cutoffs]);
	dispItem($item[Chester's moustache]);
	dispItem($item[Chester's muscle shirt]);
	dispItem($item[Chester's sunglasses]);	

	//Hodgman
	print(">> Hodgman, the Hoboverlord");
	outfitDisp("Hodgman's Regal Frippery",$item[Hodgman's lobsterskin pants],$item[Hodgman's bow tie],$item[Hodgman's porkpie hat]);
	dispItem($item[Hodgman's bow tie]);
	dispItem($item[Hodgman's porkpie hat]);
	dispItem($item[Hodgman's lobsterskin pants]);
	dispItem($item[Hodgman's almanac]);	
	dispItem($item[Hodgman's lucky sock]);
	dispItem($item[Hodgman's metal detector]);
	dispItem($item[Hodgman's varcolac paw]);
	dispItem($item[Hodgman's harmonica]);	
	dispItem($item[Hodgman's garbage sticker]);
	dispItem($item[Hodgman's cane]);
	dispItem($item[Hodgman's whackin' stick]);	
	dispItem($item[Hodgman's disgusting technicolor overcoat]);
	dispItem($item[Hodgman's imaginary hamster]);
	
	//Boss Consumables
	print(">> Boss Consumables");
	dispItem($item[epic wad]);
	dispItem($item[extra-greasy slider]);
	dispItem($item[Frosty's frosty mug]);
	dispItem($item[hobo fortress blueprints]);	
	dispItem($item[Hodgman's blanket]);
	dispItem($item[jar of fermented pickle juice]);
	dispItem($item[Ol' Scratch's salad fork]);
	dispItem($item[stuffed Hodgman]);	
	dispItem($item[tin cup of mulligan stew]);
	dispItem($item[voodoo snuff]);
		
	//Boss Songs
	print(">> Boss Songs");
	dispItem($item[Benetton's Medley of Diversity]);
		if(skill_list.contains_text("Benetton")) print("You have the skill Benetton's Medley of Diversity" , "green");
		if(!skill_list.contains_text("Benetton")) print("You lack the skill Benetton's Medley of Diversity" , "red");
	dispItem($item[Chorale of Companionship]);
		if(skill_list.contains_text("Chorale")) print("You have the skill Chorale of Companionship" , "green");
		if(!skill_list.contains_text("Benetton")) print("You lack the skill Chorale of Companionship" , "red");
	dispItem($item[Elron's Explosive Etude]);
		if(skill_list.contains_text("Elron")) print("You have the skill Elron's Explosive Etude" , "green");
		if(!skill_list.contains_text("Elron")) print("You lack the skill Elron's Explosive Etude" , "red");
	dispItem($item[Hodgman's journal #1: The Lean Times]);	
		if(skill_list.contains_text("Natural Born Scrabbler")) print("You have the skill Natural Born Scrabbler" , "green");
		if(!skill_list.contains_text("Natural Born Scrabbler")) print("You lack the skill Natural Born Scrabbler" , "red");
	dispItem($item[Hodgman's journal #2: Entrepreneurythmics]);
		if(skill_list.contains_text("Thrift and Grift")) print("You have the skill Thrift and Grift" , "green");
		if(!skill_list.contains_text("Thrift and Grift")) print("You lack the skill Thrift and Grift" , "red");
	dispItem($item[Hodgman's journal #3: Pumping Tin]);
		if(skill_list.contains_text("Abs of Tin")) print("You have the skill Abs of Tin" , "green");
		if(!skill_list.contains_text("Abs of Tin")) print("You lack the skill Abs of Tin" , "red");
	dispItem($item[Hodgman's journal #4: View From The Big Top]);
		if(skill_list.contains_text("Marginally Insane")) print("You have the skill Marginally Insane" , "green");
		if(!skill_list.contains_text("Marginally Insane")) print("You lack the skill Marginally Insane" , "red");
	dispItem($item[Prelude of Precision]);	
		if(skill_list.contains_text("Prelude of Precision")) print("You have the skill Prelude of Precision" , "green");
		if(!skill_list.contains_text("Prelude of Precision")) print("You lack the skill Prelude of Precision" , "red");
	dispItem($item[The Ballad of Richie Thingfinder]);
		if(skill_list.contains_text("Richie Thingfinder")) print("You have the skill The Ballad of Richie Thingfinder" , "green");
		if(!skill_list.contains_text("Richie Thingfinder")) print("You lack the skill The Ballad of Richie Thingfinder" , "red");
	
	//The Hobo Marketplace
	print(">> The Hobo Marketplace");
	dispItem($item[crumpled felt fedora]);
	dispItem($item[battered old top-hat]);
	dispItem($item[shapeless wide-brimmed hat]);
	dispItem($item[mostly rat-hide leggings]);	
	dispItem($item[hobo dungarees]);
	dispItem($item[old patched suit-pants]);
	dispItem($item[old soft shoes]);
	dispItem($item[hobo stogie]);	
	dispItem($item[rope with some soap on it]);
	dispItem($item[sharpened hubcap]);
	dispItem($item[very large caltrop]);	
	dispItem($item[The Six-Pack of Pain]);
	dispItem($item[sealskin drum]);
	dispItem($item[washboard shield]);
	dispItem($item[spaghetti-box banjo]);
	dispItem($item[marinara jug]);
	dispItem($item[makeshift castanets]);
	dispItem($item[left-handed melodica]);
	dispItem($item[dinged-up triangle]);
	dispItem($item[hobo monkey]);
	string hobo_fam = visit_url("familiar.php");	
	if(index_of(hobo_fam , "contains the following creatures")!=-1)
	{	
		if(hobo_fam.contains_text("hobomonkey.gif")) print("You have a hobo monkey in your terrarium" , "green");
		if(!hobo_fam.contains_text("hobomonkey.gif")) print("You do not have a hobo monkey in your terrarium" , "red");
	}
	else
	{
		print("You are currently unable to access your familiars" , "red" );
	}
	
	//Exposure Esplanade
	print(">> Exposure Esplanade");
	dispItem($item[Blizzards I Have Died In]);
		if(skill_list.contains_text("Snowclone")) print("You have the skill Snowclone" , "green");
		if(!skill_list.contains_text("Snowclone")) print("You lack the skill Snowclone" , "red");
	dispItem($item[bowl of fishysoisse]);
	dispItem($item[freezin' bindle]);
	dispItem($item[frigid air mattress]);	
	dispItem($item[frozen banquet]);
	dispItem($item[Maxing, Relaxing]);
		if(skill_list.contains_text("Maximum Chill")) print("You have the skill Maximum Chill" , "green");
		if(!skill_list.contains_text("Maximum Chill")) print("You lack the skill Maximum Chill" , "red");
		
	//Burnbarrel Blvd.
	print(">> Burnbarrel Blvd.");
	dispItem($item[bed of coals]);
	dispItem($item[flamin' bindle]);
	dispItem($item[jar of squeeze]);
	dispItem($item[Kissin' Cousins]);
		if(skill_list.contains_text("Awesome Balls of Fire")) print("You have the skill Awesome Balls of Fire" , "green");
		if(!skill_list.contains_text("Awesome Balls of Fire")) print("You lack the skill Awesome Balls of Fire" , "red");
	dispItem($item[Tales from the Fireside]);
		if(skill_list.contains_text("Conjure Relaxing Campfire")) print("You have the skill Conjure Relaxing Campfire" , "green");
		if(!skill_list.contains_text("Conjure Relaxing Campfire")) print("You lack the skill Conjure Relaxing Campfire" , "red");
	
	//The Heap
	print(">> The Heap");
	dispItem($item[Biddy Cracker's Old-Fashioned Cookbook]);
		if(skill_list.contains_text("Eggsplosion")) print("You have the skill Eggsplosion" , "green");
		if(!skill_list.contains_text("Eggsplosion")) print("You lack the skill Eggsplosion" , "red");
	dispItem($item[concentrated garbage juice]);
	dispItem($item[dead guy's memento]);
	dispItem($item[dead guy's piece of double-sided tape]);	
	dispItem($item[filth-encrusted futon]);
	dispItem($item[Ralph IX cognac]);
	dispItem($item[stinkin' bindle]);
	dispItem($item[Travels with Jerry]);	
		if(skill_list.contains_text("Mudbath")) print("You have the skill Mudbath" , "green");
		if(!skill_list.contains_text("Mudbath")) print("You lack the skill Mudbath" , "red");

	//The Ancient Hobo Burial Ground
	print(">> The Ancient Hobo Burial Ground");
	dispItem($item[Asleep in the Cemetery]);
		if(skill_list.contains_text("Creepy Lullaby")) print("You have the skill Creepy Lullaby" , "green");
		if(!skill_list.contains_text("Creepy Lullaby")) print("You lack the skill Creepy Lullaby" , "red");
	dispItem($item[comfy coffin]);
	dispItem($item[deadly lampshade]);
	dispItem($item[Let Me Be!]);	
		if(skill_list.contains_text("Raise Backup Dancer")) print("You have the skill Raise Backup Dancer" , "green");
		if(!skill_list.contains_text("Raise Backup Dancer")) print("You lack the skill Raise Backup Dancer" , "red");
	dispItem($item[spooky bindle]);
	
	//The Purple Light District
	print(">> The Purple Light District");
	dispItem($item[deck of lewd playing cards]);
	dispItem($item[lewd playing card]);
	dispItem($item[Sensual Massage for Creeps]);
		if(skill_list.contains_text("Inappropriate Backrub")) print("You have the skill Inappropriate Backrub" , "green");
		if(!skill_list.contains_text("Inappropriate Backrub")) print("You lack the skill Inappropriate Backrub" , "red");
	dispItem($item[sleazy bindle]);	
	dispItem($item[stained mattress]);
	dispItem($item[Summer Nights]);
		if(skill_list.contains_text("Grease Lightning")) print("You have the skill Grease Lightning" , "green");
		if(!skill_list.contains_text("Grease Lightning")) print("You lack the skill Grease Lightning" , "red");
	
	//The Town Square
	print(">> The Town Square");
	dispItem($item['WILL WORK FOR BOOZE' sign]);
	dispItem($item[corncob pipe]);
	dispItem($item[cup of infinite pencils]);
	dispItem($item[frayed rope belt]);	
	dispItem($item[lucky bottlecap]);
	dispItem($item[Mr. Joe's bangles]);
	dispItem($item[panhandle panhandling hat]);	
	dispItem($item[rusty piece of rebar]);
	
	//The Sewers
	print(">> The Sewers");
	dispItem($item[bottle of Ooze-O]);
	dispItem($item[bottle of sewage schnapps]);
	dispItem($item[C.H.U.M. chum]);
	dispItem($item[C.H.U.M. knife]);	
	dispItem($item[C.H.U.M. lantern]);
	dispItem($item[decaying goldfish liver]);
	dispItem($item[gator skin]);
	dispItem($item[gatorskin umbrella]);	
	dispItem($item[sewer nuggets]);
	dispItem($item[sewer wad]);
	dispItem($item[unfortunate dumplings]);	
	
	//Candy
	print(">> Candy");
	dispItem($item[frostbite-flavored Hob-O]);
	dispItem($item[fry-oil-flavored Hob-O]);
	dispItem($item[garbage-juice-flavored Hob-O]);
	dispItem($item[Roll of Hob-Os]);	
	dispItem($item[sterno-flavored Hob-O]);
	dispItem($item[strawberry-flavored Hob-O]);

	//Misc
	print(">> Misc");
	dispItem($item[bindle of joy]);
	dispItem($item[boxcar turtle]);
	dispItem($item[hobo nickel]);
	
	//Hobo Code Binder
	print(">> Binder");
	dispItem($item[hobo code binder]);
	string binder_text = visit_url("questlog.php?which=5");
	if(index_of(binder_text , "hobo glyphs")!=-1)
	{
		if(!binder_text.contains_text("Noob Cave")) print("You are missing the glyph from the noob cave" , "red" );
		if(!binder_text.contains_text("The Poker Room")) print("You are missing the glyph from The Poker Room" , "red" );
		if(!binder_text.contains_text("The Cola Wars Battlefield")) print("You are missing the glyph from the Cola Wars Battlefield" , "red" );
		if(!binder_text.contains_text("The Limerick Dungeon")) print("You are missing the glyph from the Limerick Dungeon" , "red" );
		if(!binder_text.contains_text("The Enormous Greater-Than Sign")) print("You are missing the glyph from the Enormous Greater-Than Sign" , "red" );
		if(!binder_text.contains_text("The Sleazy Back Alley")) print("You are missing the glyph from the Sleazy Back Alley" , "red" );
		if(!binder_text.contains_text("House")) print("You are missing the glyph from the Fun House" , "red" );
		if(!binder_text.contains_text("The Bugbear Pen")) print("You are missing the glyph from the Bugbear Pen (pre-felonia)" , "red" );
		if(!binder_text.contains_text("The Misspelled Cemetary")) print("You are missing the glyph from the Misspelled Cemetary (pre-cyrpt)" , "red" );
		if(!binder_text.contains_text("The Road to White Citadel")) print("You are missing the glyph from the Road to White Citadel" , "red" );
		if(!binder_text.contains_text("Camp Logging Camp")) print("You are missing the glyph from Camp Logging Camp" , "red" );
		if(!binder_text.contains_text("Thugnderdome")) print("You are missing the glyph from theThugnderdome" , "red" );
		if(!binder_text.contains_text("The eXtreme Slope")) print("You are missing the glyph from the eXtreme Slope" , "red" );
		if(!binder_text.contains_text("Cobb's Knob Menagerie, Level 3")) print("You are missing the glyph from the Menagerie, Level 3" , "red" );
		if(!binder_text.contains_text("The Defiled Nook")) print("You are missing the glyph from the Defiled Nook" , "red" );
		if(!binder_text.contains_text("The Lair of the Ninja Snowmen")) print("You are missing the glyph from the Lair of the Ninja Snowmen" , "red" );
		if(!binder_text.contains_text("The Penultimate Fantasy Airship")) print("You are missing the glyph from the Penultimate Fantasy Airship" , "red" );
		if(!binder_text.contains_text("Belowdecks")) print("You are missing the glyph from Belowdecks" , "red" );
		if(!binder_text.contains_text("The Arid, Extra-Dry Desert")) print("You are missing the glyph from the Arid, Extra-Dry Desert (Unhydrated)" , "red" );
		if(!binder_text.contains_text("The Hippy/Frat Battlefield")) print("You are missing the glyph from the Battlefield (Frat Uniform)" , "red" );
		if(binder_text.contains_text("Noob") && binder_text.contains_text("Poker") && binder_text.contains_text("Cola") && binder_text.contains_text("Limerick")
			&& binder_text.contains_text("Enormous") && binder_text.contains_text("Sleazy") && binder_text.contains_text("House")
			&& binder_text.contains_text("Bugbear") && binder_text.contains_text("Misspelled") && binder_text.contains_text("Citadel")
			&& binder_text.contains_text("Logging") && binder_text.contains_text("Thugnderdome") && binder_text.contains_text("eXtreme")
			&& binder_text.contains_text("Menagerie") && binder_text.contains_text("Defiled") && binder_text.contains_text("Ninja")
			&& binder_text.contains_text("Penultimate") && binder_text.contains_text("Belowdecks") && binder_text.contains_text("Desert")
			&& binder_text.contains_text("Hippy/Frat"))print("You have a full binder (20 glyphs)" , "green" );
	}
	
	//Hobo Tattoo
	print(">> Hobo Tattoo");
	string hobo_tat = visit_url("account_tattoos.php");	
	if(index_of(hobo_tat , "These are the tattoos you have unlocked")!=-1)
	{
		if(hobo_tat.contains_text("hobotat1.gif")) print("1 of 19 upgrade, 40 nickels needed for the next upgrade, 3780 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat2.gif")) print("2 of 19 upgrades, 60 nickels needed for the next upgrade, 3740 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat3.gif")) print("3 of 19 upgrades, 80 nickels needed for the next upgrade, 3680 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat4.gif")) print("4 of 19 upgrades, 100 nickels needed for the next upgrade, 3600 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat5.gif")) print("5 of 19 upgrades, 120 nickels needed for the next upgrade, 3500 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat6.gif")) print("6 of 19 upgrades, 140 nickels needed for the next upgrade, 3380 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat7.gif")) print("7 of 19 upgrades, 160 nickels needed for the next upgrade, 3240 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat8.gif")) print("8 of 19 upgrades, 180 nickels needed for the next upgrade, 3080 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat9.gif")) print("9 of 19 upgrades, 200 nickels needed for the next upgrade, 2900 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat10.gif")) print("10 of 19 upgrades, 220 nickels needed for the next upgrade, 2700 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat11.gif")) print("11 of 19 upgrades, 240 nickels needed for the next upgrade, 2480 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat12.gif")) print("12 of 19 upgrades, 260 nickels needed for the next upgrade, 2240 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat13.gif")) print("13 of 19 upgrades, 280 nickels needed for the next upgrade, 1980 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat14.gif")) print("14 of 19 upgrades, 300 nickels needed for the next upgrade, 1700 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat15.gif")) print("15 of 19 upgrades, 320 nickels needed for the next upgrade, 1400 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat16.gif")) print("16 of 19 upgrades, 340 nickels needed for the next upgrade, 1080 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat17.gif")) print("17 of 19 upgrades, 360 nickels needed for the next upgrade, 740 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat18.gif")) print("18 of 19 upgrades, 380 nickels needed for the next upgrade, 380 nickels needed for the full tattoo" , "blue");
		if(hobo_tat.contains_text("hobotat19.gif")) print("19 of 19 upgrades, your hobo tattoo is complete!" , "green");
		if(!hobo_tat.contains_text("hobotat")) print("You have no parts of the hobo tattoo yet" , "red");
	}
	else
	{
		print("You are currently unable to access your tattoos" , "red");
	}

}