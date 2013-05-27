/*	05.25.2010

		  hatter.ash
	Enjoying tea the mafia way.
		by That FN Ninja
	  Last edited 01/16/11
				
If you have any suggestions on ways to improve this script please post them here:
http://kolmafia.us/showthread.php?t=4262

If you find this script useful, donations in the form of in-game ninja paraphernalia
are always appreciated! Thanks and enjoy the script.				
*/
script "hatter.ash";
notify That FN Ninja;

item hat, orig;
int[item] hats;
int[item] hatsOwned;
int[effect] buffs;

buffs[$effect[Assaulted with Pepper]] = 4;
buffs[$effect[Three Days Slow]] = 6;
buffs[$effect[Cat-Alyzed]] = 7;
buffs[$effect[Anytwo Five Elevenis?]] = 8;
buffs[$effect[Coated Arms]] = 9;
buffs[$effect[Smoky Third Eye]] = 10;
buffs[$effect[Full Bottle in front of Me]] = 11;
buffs[$effect[Thick-Skinned]] = 12;
buffs[$effect[20-20 Second Sight]] = 13;
buffs[$effect[Slimy Hands]] = 14;
buffs[$effect[Bottle in front of Me]] = 15;
buffs[$effect[Fan-Cooled]] = 16;
buffs[$effect[Ginger Snapped]] = 17;
buffs[$effect[Egg on your Face]] = 18;
buffs[$effect[Pockets of Fire]] = 19;
buffs[$effect[Weapon of Mass Destruction]] = 20;
buffs[$effect[Dances with Tweedles]] = 22;
buffs[$effect[Patched In]] = 23;
buffs[$effect[You Can Really Taste the Dormouse]] = 24;
buffs[$effect[Turtle Titters]] = 25;
buffs[$effect[Cat Class, Cat Style]] = 26;
buffs[$effect[Surreally Buff]] = 27;
buffs[$effect[Quadrilled]] = 28;

void check(){
	if(to_boolean(get_property("_madTeaParty"))){
		print("You've already recieved a buff from the Mad Hatter today.", "red");
		exit;
	}
}

int getLength(item h){ return length(replace_string(h.to_string(), " ", "")); }

foreach itm in get_inventory()
	if(item_type(itm) == "hat")
		hatsOwned[itm] = getLength(itm);
		
if(equipped_item($slot[hat]) != $item[none])
	hatsOwned[equipped_item($slot[hat])] = getLength(equipped_item($slot[hat]));		
		
foreach itm in $items[]
	if(item_type(itm) == "hat")
		hats[itm] = getLength(itm);	
	
boolean down(){

	if(have_effect($effect[Down the Rabbit Hole]) > 0) return true;
	
	if(item_amount($item["DRINK ME" potion]) == 0){
	
		print("Getting a DRINK ME potion...", "blue");
		
		if(contains_text(visit_url("clan_viplounge.php?action=lookingglass"), "acquire a DRINK ME potion")){}
		else if(retrieve_item(1, $item["DRINK ME" potion])){}
		else if(can_interact() && to_boolean(get_property("autoSatisfyWithMall"))){
			print("Buying a DRINK ME potion in...", "blue");
			wait(10);
			buy(1, $item["DRINK ME" potion]);
		}
		else{
			print("Unable to get a DRINK ME potion.", "red");
			if(orig != $item[none]) equip(orig);
			exit;
		}
	}
	
	return use(1, $item["DRINK ME" potion]);
}

void hatter(){

	down();
	
	visit_url("rabbithole.php?action=teaparty");
	visit_url("choice.php?pwd&whichchoice=441&option=1");
	
	if(orig != $item[none]) equip(orig);
}	

void usage(){
	print_html("<table width=\"575\" border=\"2\" cellpadding=\"10\"><tr><td colspan=\"2\" bgcolor=\"#000000\"><center><font color=\"#FFFFFF\" size=\"6\"><b>hatter.ash &nbsp;&nbsp;Usage</b></font></center></td></tr><tr><td colspan=\"2\" bgcolor=\"#CCCCCC\"><p><font size=\"4\"><strong>Format: </strong></font>call hatter.ash [argument]</p></td></tr> <tr><td width=\"150\"><font size=\"4\"><strong>Argument</strong></font></td><td width=\"371\"><font size=\"4\"><strong>Function</strong></font></td></tr><tr><td><p>an integer value</p></td><td>Visits the hatter with a hat that has the number of non-space characters specified.</td></tr><tr><td><p>current<br />equipped</p></td><td>Visits the hatter  with the hat you are currently wearing.</td></tr><tr><td><p>hat name</p></td><td>Visits the hatter with the hat specified.</td></tr><tr><td><p>buff name</p></td><td>Gets the buff passed. Uses mafias fuzzy matching.<br /> (i.e. &quot;pep&quot; = &quot;Assaulted with Pepper&quot;)</td></tr><tr><td><p>ml<br />monster level</p></td><td>Gets: Assaulted with Pepper<br />+20 to Monster Level</td></tr><tr><td><p>fe<br />fam exp<br />familiar experience</p></td><td>Gets: Three Days Slow<br />+3 Familiar Experience Per Adventure</td></tr><tr><td><p>fw<br />fam weight<br />familiar weight</p></td><td>Gets: You Can Really Taste the Dormouse<br />+5 Familiar Weight</td></tr>  <tr><td><p>moxie</p></td><td>Gets: Cat-Alyzed<br />+10 Moxie</td></tr><tr><td><p>%moxie</p></td><td>Gets: Cat Class, Cat Style <br />+20% Moxie</td></tr><tr><td><p>muscle</p></td><td>Gets: Anytwo Five Elevenis?<br />+10 Muscle</td></tr><tr><td><p>%muscle</p></td><td>Gets: Surreally Buff<br />+20% Muscle</td></tr><tr><td><p>myst<br />mysticality</p></td><td>Gets: Smoky Third Eye<br />+10 Mysticality</td></tr><tr><td><p>%myst</p></td><td>Gets: Patched In<br />+20% Mysticality</td></tr><tr><td><p>wd<br />weapon<br />weap dam<br />weapon damage</p></td><td>Gets: Coated Arms<br />+15 Weapon Damage</td></tr> <tr><td><p>%wd<br />%weapon<br />%weap dam<br />%weapon damage</p></td><td>Gets: Weapon of Mass Destruction<br />+30% Weapon Damage</td></tr><tr><td><p>spell<br />spell dam<br />spell damage</p></td><td>Gets: Bottle in front of Me<br />+15 Spell Damage</td></tr><tr><td><p>%spell<br />%spell dam<br />%spell damage</p></td><td>Gets: Full Bottle in front of Me<br />+30% Spell Damage</td></tr><tr><td><p>sleaze<br />sleaze dam<br />sleaze damage</p></td><td>Gets: Slimy Hands<br />+10 Sleaze Damage</td></tr><tr><td><p>cold<br />cold dam<br />cold damage</p></td><td>Gets: Fan-Cooled<br />+10 Cold Damage</td></tr><tr><td><p>spooky<br />spooky dam<br />spooky damage</p></td><td>Gets: Ginger Snapped<br />+10 Spooky Damage</td></tr><tr><td><p>stench<br />stench dam<br />stench damage</p></td><td>Gets: Egg on your Face<br />+10 Stench Damage</td></tr><tr><td><p>hot<br />hot dam<br />hot damage</p></td><td>Gets: Pockets of Fire<br />+10 Hot Damage</td></tr><tr><td><p>hp<br />max hp<br />maximum hp</p></td><td>Gets: Thick-Skinned<br />+50 Maximum HP</td></tr><tr><td><p>mp<br />max mp<br />maximum mp</p></td><td>Gets: 20-20 Second Sight<br />+25 Maximum MP</td></tr><tr><td><p>stat<br />stats<br />stat gain</p></td><td>Gets: Turtle Titters<br />+3 Stats per Fight</td></tr><tr><td><p>meat</p></td><td>Gets: Dances with Tweedles<br />+40% Meat from Monsters</td></tr><tr><td><p>item<br />items</p></td><td>Gets: Quadrilled<br />+20% Item Drops from Monsters</td></tr><tr><td><p>usage<br />help<br />h<br />?</p></td><td>Use any of these keywords to print this help menu.</td></tr><tr><td colspan=\"2\" bgcolor=\"#CCCCCC\"><p><font size=\"4\"><strong>Format:</strong></font></p><br /><p>call hatter.ash [argument]</p><br /><p><font size=\"4\"><strong>Examples:</strong></font></p><br /><p><strong>call hatter.ash 22</strong><br />Gets the buff corresponding to the hat whose length (excluding whitespace) is 22.</p><br /><p><strong>call hatter.ash dance</strong>s<br />Does a fuzzy match on hat buffs to see if one contains dances and gets that buff.</p><br /><p><strong>call hatter.ash meat</strong><br />Gets the buff that will increase meat drops</p><br /><p>To call this script from within another script use cli_execute(); <br />i.e. <strong>cli_execute(\"call hatter.ash meat\");</strong></p></td></tr></table>");
	print_html("<table width=\"500\" border=\"2\" cellpadding=\"10\"><tr><td width=\"50\" height=\"87\"><img src=\"http://images.kingdomofloathing.com/otherimages/sigils/ninja.gif\" alt=\"Ninja.gif\" width=\"50\" height=\"50\"/></td><td width=\"322\" bgcolor=\"#000000\"><center><font color=\"#FFFFFF\" size=\"5\"><p><strong>hatter.ash</strong> <font color=\"#FFFFFF\" size=\"4\"> by </font> <strong>That FN Ninja</strong></p></font><font color=\"#FFFFFF\" size=\"4\"><p><em>Enjoying tea the Mafia way.</em></p></font></center></td><td width=\"50\"><img src=\"http://images.kingdomofloathing.com/otherimages/sigils/ninja.gif\" alt=\"Ninja.gif\" width=\"50\" height=\"50\"/></td></tr></table>");
}

void hatCheck(int num){

	if(num < 4 || num == 5 || num == 21 || num > 28){
		print("There are no hats in the kingdom whose length (excluding whitespace) is " + num, "red");
		exit;
	}
	
	foreach itm in hatsOwned
		if(hatsOwned[itm] == num && can_equip(itm)){
			hat = itm;
			break;
		}
	
	if(hat != $item[none]){
		equip(hat);
		hatter();
	}
	else{
		print("No suitable hat found whose length (excluding whitespace) is " + num, "red");
		print("You need to be able to wear one of the following hats:");
		
		foreach itm in hats
			if(hats[itm] == num)
				print(itm);
	}
}

void hatCheck(effect ef){
	print("Buff selected: " + ef);
	
	foreach itm in hatsOwned
		if(hatsOwned[itm] == buffs[ef] && can_equip(itm)){
			hat = itm;
			break;
		}
	
	if(hat != $item[none]){
		equip(hat);
		hatter();
	}
	else{
		print("Unable to get the " + ef + " buff.", "red");
		print("You need to be able to wear one of the following hats:");
		
		foreach itm in hats
			if(hats[itm] == buffs[ef])
				print(itm);		
	}
}

void main(string command){
	command = command.to_lower_case();
	orig = equipped_item($slot[hat]);

	switch(command){
		case "":
		case "h":
		case "?":
		case "help":
		case "usage":
			usage();
			break;
			
		case "current":
		case "equipped":
			check();
			if(equipped_item($slot[hat]) == $item[none])
				print("You don't have a hat equipped.", "red");
			else hatter();
			break;
			
		case "ml":
		case "monster level":
			check();
			hatCheck($effect[Assaulted with Pepper]);
			break;
			
		case "fe":
		case "fam exp":
		case "familiar experience":	
			check();
			hatCheck($effect[Three Days Slow]);
			break;

		case "moxie":
			check();
			hatCheck($effect[Cat-Alyzed]);
			break;

		case "muscle":
			check();
			hatCheck($effect[Anytwo Five Elevenis?]);
			break;
			
		case "myst":	
		case "mysticality":	
			check();
			hatCheck($effect[Smoky Third Eye]);
			break;			

		case "wd":
		case "weapon":
		case "weap dam":
		case "weapon damage":
			check();
			hatCheck($effect[Coated Arms]);
			break;

		case "%spell":
		case "%spell dam":
		case "%spell damage":
			check();
			hatCheck($effect[Full Bottle in front of Me]);
			break;

		case "hp":
		case "max hp":
		case "maximum hp":
			check();
			hatCheck($effect[Thick-Skinned]);
			break;

		case "mp":
		case "max mp":
		case "maximum mp":
			check();
			hatCheck($effect[20-20 Second Sight]);
			break;

		case "sleaze":
		case "sleaze dam":
		case "sleaze damage":
			check();
			hatCheck($effect[Slimy Hands]);
			break;

		case "spell":
		case "spell dam":
		case "spell damage":
			check();
			hatCheck($effect[Bottle in front of Me]);
			break;

		case "cold":
		case "cold dam":
		case "cold damage":	
			check();
			hatCheck($effect[Fan-Cooled]);
			break;

		case "spooky":
		case "spooky dam":
		case "spooky damage":
			check();
			hatCheck($effect[Ginger Snapped]);
			break;

		case "stench":
		case "stench dam":
		case "stench damage":
			check();
			hatCheck($effect[Egg on your Face]);
			break;

		case "hot":
		case "hot dam":
		case "hot damage":
			check();		
			hatCheck($effect[Pockets of Fire]);
			break;

		case "%wd":
		case "%weapon":
		case "%wep dam":
		case "%weapon damage":
			check();
			hatCheck($effect[Weapon of Mass Destruction]);
			break;

		case "meat":
			check();
			hatCheck($effect[Dances with Tweedles]);
			break;

		case "%moxie":
			check();
			hatCheck($effect[Cat Class, Cat Style]);
			break;

		case "%muscle":	
			check();
			hatCheck($effect[Surreally Buff]);
			break;
			
		case "%myst":	
		case "%mysticality":
			check();
			hatCheck($effect[Patched In]);
			break;

		case "fw":
		case "fam weight":
		case "familiar weight":
			check();
			hatCheck($effect[You Can Really Taste the Dormouse]);
			break;

		case "stats":
		case "stat":
		case "stat gain":
			check();
			hatCheck($effect[Turtle Titters]);
			break;

		case "item":
		case "items":
			check();
			hatCheck($effect[Quadrilled]);
			break;			
		
		default:
			check();
			
			if(is_integer(command))
				hatCheck(to_int(command));
			
			else if(item_type(to_item(command)) == "hat"){
				hat = to_item(command);		
			
				if(hatsOwned contains hat){
					equip(hat);
					hatter();
				}
				else print("You don't have a " + hat, "red");
			}
			
			else if(buffs contains to_effect(command))
				hatCheck(to_effect(command));
			
			else{ 
				print("Invalid command!", "red");
				print("To display a list of commands type \"hatter.ash help\"");
			}
			break;
	}
}
