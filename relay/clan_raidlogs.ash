/*Clan Raidlogs by Almighty Sapling
TODO:
Loot Manager
Update Manager
*/
string[string] contexts;
string[string] FF=form_fields();
string page;
string abortMessage;
//total, player, area, section
int[string,string,string] data;
int[int,string,string]odata;
string[string] options;

int runType=-1;
//Consts
boolean activeComment=false;//uncomment next line for testing.
activeComment=true;
string clearID="!Made it<br>Through";
string[string,string] theMatcher;

theMatcher["Parts",".place"]="3&action=talkrichard&whichtalk=3";
theMatcher["Parts",".image"]="http://images.kingdomofloathing.com/adventureimages/richardmoll.gif";
theMatcher["Parts","Skins"]="Richard has <b>(\\d+)</b> hobo skin";
theMatcher["Parts","Crotches"]="Richard has <b>(\\d+)</b> hobo crotch";
theMatcher["Parts","Skulls"]="Richard has <b>(\\d+)</b> creepy hobo skull";
theMatcher["Parts","Guts"]="Richard has <b>(\\d+)</b> pile";
theMatcher["Parts","Eyes"]="Richard has <b>(\\d+)</b> pairs? of frozen hobo";
theMatcher["Parts","Boots"]="Richard has <b>(\\d+)</b> pairs? of charred hobo";
theMatcher["Parts","!Bandages"]="has <b>(\\d+)</b> bandages";
theMatcher["Parts","!Grenades"]="has <b>(\\d+)</b> grenades";
theMatcher["Parts","!Protein Shakes"]="has <b>(\\d+)</b> protein";

theMatcher["Sewer",clearID]="made it through the sewer";
theMatcher["Sewer","&nbsp;Gators"]="defeated a sewer gator";
theMatcher["Sewer","&nbsp;C.H.U.M.s"]="defeated a C. H. U. M.";
theMatcher["Sewer","&nbsp;Goldfish"]="defeated a giant zombie goldfish";
theMatcher["Sewer","Defeats"]="was defeated by";
theMatcher["Sewer","Explored<br>Tunnels"]="explored";
theMatcher["Sewer","Opened<br>Grates"]="sewer grate";
theMatcher["Sewer","Turned<br>Valves"]="lowered the water level";
theMatcher["Sewer","Gnawed<br>Through Cage"]="gnawed through";
theMatcher["Sewer","Found Cage<br>Empty"]="empty cage";
theMatcher["Sewer","Rescued<br>Caged Player"]="rescued";

theMatcher["TS",".place"]="2";
theMatcher["TS",".image"]="http://images.kingdomofloathing.com/adventureimages/hodgman.gif";
theMatcher["TS","&nbsp;Normal Hobo"]="defeated  Normal hobo";
theMatcher["TS","Defeats"]="was defeated by  Normal";
theMatcher["TS","Market<br>Trips"]="went shopping in the Marketplace";
theMatcher["TS","Performed"]="took the stage";
theMatcher["TS","Busked"]="passed";
theMatcher["TS","Moshed"]="mosh";
theMatcher["TS","Ruined<br>Show"]="ruined";
theMatcher["TS","Made<br>Bandages"]="bandage";
theMatcher["TS","Made<br>Grenades"]="grenade";
theMatcher["TS","Made<br>Shakes"]="protein shake";

theMatcher["TS","!Hodgman"]="defeated  Hodgman";
theMatcher["TS","!bossloss"]="was defeated by  H";

theMatcher["BB",".gmatcher"]="Blvd\\.";
theMatcher["BB",".place"]="4";
theMatcher["BB",".image"]="http://images.kingdomofloathing.com/adventureimages/olscratch.gif";
theMatcher["BB","&nbsp;Hot Hobo"]="defeated  Hot hobo";
theMatcher["BB","Defeats"]="defeated by  Hot";
theMatcher["BB","!Ol' Scratch"]="defeated  Ol";
theMatcher["BB","!bossloss"]="defeated by  Ol";
theMatcher["BB","Threw Tire"]="on the fire";
theMatcher["BB","Tirevalanche"]="tirevalanche";
theMatcher["BB","Diverted<br>Steam"]="diverted some steam away";
theMatcher["BB","Opened<br>Door"]="clan coffer";
theMatcher["BB","Burned<br>by Door"]="hot door";

theMatcher["EE",".gmatcher"]="Esplanade";
theMatcher["EE",".place"]="5";
theMatcher["EE",".image"]="http://images.kingdomofloathing.com/adventureimages/frosty.gif";
theMatcher["EE","&nbsp;Cold Hobo"]="defeated  Cold hobo";
theMatcher["EE","Defeats"]="defeated by  Cold";
theMatcher["EE","!Frosty"]="defeated  Frosty";
theMatcher["EE","!bossloss"]="defeated by  Frosty";
theMatcher["EE","Freezers"]="freezer";
theMatcher["EE","Fridges"]="fridge";
theMatcher["EE","Pipes Busted"]="broke";
theMatcher["EE","Diverted Water<br>Out"]="diverted some cold water out of";
theMatcher["EE","Diverted Water<br>to BB"]="diverted some cold water to";
theMatcher["EE","Yodeled<br>(a little)"]="yodeled a little";
theMatcher["EE","Yodeled<br>(a lot)"]="yodeled quite a bit";
theMatcher["EE","Yodeled<br>(like crazy)"]="yodeled like crazy";

theMatcher["Heap",".gmatcher"]="Heap";
theMatcher["Heap",".place"]="6";
theMatcher["Heap",".image"]="http://images.kingdomofloathing.com/adventureimages/oscus.gif";
theMatcher["Heap","&nbsp;Stench Hobo"]="defeated  Stench hobo";
theMatcher["Heap","Defeats"]="defeated by  Stench";
theMatcher["Heap","!Oscus"]="defeated  Oscus";
theMatcher["Heap","!bossloss"]="defeated by  Oscus";
theMatcher["Heap","Trashcanos"]="trashcano eruption";
theMatcher["Heap","Buried<br>Treasure"]="buried treasure";
theMatcher["Heap","Sent<br>Compost"]="Burial Ground";

theMatcher["AHBG",".gmatcher"]="Ground";
theMatcher["AHBG",".place"]="7";
theMatcher["AHBG",".image"]="http://images.kingdomofloathing.com/adventureimages/zombo.gif";
theMatcher["AHBG","&nbsp;Spooky Hobo"]="defeated  Spooky hobo";
theMatcher["AHBG","Defeats"]="defeated by  Spooky";
theMatcher["AHBG","!Zombo"]="defeated  Zombo";
theMatcher["AHBG","!bossloss"]="defeated by  Zombo";
theMatcher["AHBG","Sent Flowers"]="flower";
theMatcher["AHBG","Raided Tombs"]="raided";
theMatcher["AHBG","Watched<br>Dancers"]="zombie hobos dance";
theMatcher["AHBG","Failed to<br>Impress"]="failed to impress";
theMatcher["AHBG","Busted<br>Moves"]="busted";

theMatcher["PLD",".gmatcher"]="District";
theMatcher["PLD",".place"]="8";
theMatcher["PLD",".image"]="http://images.kingdomofloathing.com/adventureimages/chester.gif";
theMatcher["PLD","&nbsp;Sleaze Hobo"]="defeated  Sleaze hobo";
theMatcher["PLD","Defeats"]="defeated by  Sleaze";
theMatcher["PLD","!Chester"]="defeated  Chester";
theMatcher["PLD","!bossloss"]="defeated by  Chester";
theMatcher["PLD","Raided<br>Dumstpers"]="dumpster";
theMatcher["PLD","Sent Trash"]="sent some trash";
theMatcher["PLD","Bamboozled"]="bamboozled";
theMatcher["PLD","Flimflammed"]="flimflammed";
theMatcher["PLD","Danced"]="danced like a superstar";
theMatcher["PLD","Barfights"]="barfight";
//TODO: add uncle hobo

//Slimetube
theMatcher["Slime",".image"]="http://images.kingdomofloathing.com/adventureimages/motherslime.gif";
theMatcher["Slime","&nbsp;Slimes"]="defeated a";
theMatcher["Slime","Defeats"]="defeated by a Slime";
theMatcher["Slime","!Mother Slime"]="defeated  Mother Slime";
theMatcher["Slime","!bossloss"]="defeated by  Mother";
theMatcher["Slime","Tickled"]="tickled";
theMatcher["Slime","Squeezed"]="squeezed";

//Haunted House
theMatcher["Haunted",".image"]="http://images.kingdomofloathing.com/adventureimages/necbromancer.gif";
theMatcher["Haunted","Defeats"]="was defeated by";
theMatcher["Haunted","&nbsp;Wolves"]="defeated  sexy sorority werewolf";
theMatcher["Haunted","&nbsp;Zombies"]="defeated  sexy sorority zombie";
theMatcher["Haunted","&nbsp;Ghosts"]="defeated  sexy sorority ghost";
theMatcher["Haunted","&nbsp;Vamps"]="defeated  sexy sorority vampire";
theMatcher["Haunted","&nbsp;Skeletons"]="defeated  sexy sorority skeleton";
theMatcher["Haunted","!Wolves"]="took care of some werewolves";
theMatcher["Haunted","!Ghosts"]="trapped some ghosts";
theMatcher["Haunted","!Zombies"]="took out some zombies";
theMatcher["Haunted","!Skeletons"]="took out some skeletons";
theMatcher["Haunted","!Vamps"]="slew some vamp";
theMatcher["Haunted","!NoiseUp"]="(?:cranked up the spooky noise|noiseon)";
theMatcher["Haunted","!NoiseDown"]="(?:turned down the spooky noise|noiseoff)";
theMatcher["Haunted","!DarkUp"]="(?:closed some windows|darkup)";
theMatcher["Haunted","!DarkDown"]="(?:opened up some windows|darkdown)";
theMatcher["Haunted","!FogUp"]="(?:turned up the fog|fogup)";
theMatcher["Haunted","!FogDown"]="(?:turned down the fog|fogdown)";
theMatcher["Haunted","!Mirrors"]="(?:snagged a funhouse|gotmirror)";
theMatcher["Haunted","!Bullet"]="(?:made a silver shotgun|madeshell)";
theMatcher["Haunted","!Chainsaw"]="(?:grabbed a chain|gotchain)";
theMatcher["Haunted","!Trap"]="(?:snagged a ghost|gottrap)";
theMatcher["Haunted","!Guides"]="(?:picked up some staff|gotmaps)";
theMatcher["Haunted","!Costume"]="(?:grabbed a sexy|gotcostume)";
theMatcher["Haunted","!Necbromancer"]="defeated  The Necbromancer";
theMatcher["Haunted","!bossloss"]="defeated by  The Necbromancer";

theMatcher["DreadInn",".carriage"]="carriageman (\\d+) sheet";
theMatcher["DreadInn",".temp"]="action: v_cold";
theMatcher["DreadWoods",".dist"]="<b>([\\d,]+)</b> monster\\(s\\) in the Forest";
theMatcher["DreadVillage",".dist"]="<b>([\\d,]+)</b> monster\\(s\\) in the Village";
theMatcher["DreadCastle",".dist"]="<b>([\\d,]+)</b> monster\\(s\\) in the Castle";

theMatcher["DreadWoods","&nbsp;"]="defeated( by)?  (hot|cold|spooky|stench|sleaze) (bugbear|werewolf)";
theMatcher["DreadWoods","!Werewolf"]="defeated( by)? The Great Wolf of the Air";
theMatcher["DreadWoods","!Bugbear"]="defeated( by)?  Falls-From-Sky";
theMatcher["DreadWoods","+Cabin.11"]="acquired some dread tarragon";
theMatcher["DreadWoods","+Cabin.12"]="made some bone flour";
theMatcher["DreadWoods","+Cabin.13"]="made the forest less stinky";
theMatcher["DreadWoods","+Cabin.21"]="recycled some newspapers";
theMatcher["DreadWoods","+Cabin.22"]="read an old diary";
theMatcher["DreadWoods","+Cabin.23"]="got a Dreadsylvanian auditor's badge";
theMatcher["DreadWoods","+Cabin.24"]="made an impression of a complicated lock";
theMatcher["DreadWoods","+Cabin.30"]="unlocked the attic of the cabin";
theMatcher["DreadWoods","+Cabin.31"]="made the forest less spooky";
theMatcher["DreadWoods","+Cabin.32"]="drove some werewolves out of the forest";
theMatcher["DreadWoods","+Cabin.33"]="drove some vampires out of the castle";
theMatcher["DreadWoods","+Cabin.34"]="flipped through a photo album";
//4? 5-pencil, 6-leave
theMatcher["DreadWoods","+Tree.11"]="(?:wasted some fruit|knocked some fruit loose)";
theMatcher["DreadWoods","+Tree.12"]="made the forest less sleazy";
theMatcher["DreadWoods","+Tree.13"]="acquired a chunk of moon-amber";
theMatcher["DreadWoods","+Tree.20"]="unlocked the fire watchtower";
theMatcher["DreadWoods","+Tree.21"]="drove some ghosts out of the village";
theMatcher["DreadWoods","+Tree.22"]="rifled through a footlocker";
theMatcher["DreadWoods","+Tree.23"]="lifted some weights";
theMatcher["DreadWoods","+Tree.31"]="got a blood kiwi";
theMatcher["DreadWoods","+Tree.32"]="got a cool seed pod";
//theMatcher["DreadWoods","+Tree.33"]="";
theMatcher["DreadWoods","+Burrows.11"]="made the forest less hot";
theMatcher["DreadWoods","+Burrows.12"]="got intimate with some hot coals";
theMatcher["DreadWoods","+Burrows.13"]="made a cool iron ingot";
theMatcher["DreadWoods","+Burrows.21"]="made the forest less cold";
theMatcher["DreadWoods","+Burrows.22"]="listened to the forest's heart";
theMatcher["DreadWoods","+Burrows.23"]="drank some nutritious forest goo";
theMatcher["DreadWoods","+Burrows.31"]="drove some bugbears out of the forest";
theMatcher["DreadWoods","+Burrows.32"]="found and sold a rare baseball card";

theMatcher["DreadVillage","&nbsp;"]="defeated( by)?  (hot|cold|spooky|stench|sleaze) (ghost|zombie)";
theMatcher["DreadVillage","!Ghost"]="defeated( by)?  Mayor Ghost";
theMatcher["DreadVillage","!Zombie"]="defeated( by)? the Zombie Homeowners";
theMatcher["DreadVillage","+Square.10"]="unlocked the schoolhouse";
theMatcher["DreadVillage","+Square.11"]="drove some ghosts out of the village";
theMatcher["DreadVillage","+Square.12"]="collected a ghost pencil";
theMatcher["DreadVillage","+Square.13"]="read some naughty carvings";
theMatcher["DreadVillage","+Square.21"]="made the village less cold";
theMatcher["DreadVillage","+Square.22"]="looted the blacksmith's till";
theMatcher["DreadVillage","+Square.23"]="made (?:a|some) cool(?:ing)? iron";
theMatcher["DreadVillage","+Square.31"]="made the village less spooky";
theMatcher["DreadVillage","+Square.32"]="was hung by a clanmate";
//theMatcher["DreadVillage","+Square.33"]="";//gawking
theMatcher["DreadVillage","+Square.34"]="hung a clanmate";
theMatcher["DreadVillage","+Skid Row.11"]="made the vill?age less stinky";
theMatcher["DreadVillage","+Skid Row.12"]="swam in a sewer";
theMatcher["DreadVillage","+Skid Row.21"]="drove some skeletons out of the castle";
theMatcher["DreadVillage","+Skid Row.22"]="made the village less sleazy";
theMatcher["DreadVillage","+Skid Row.23"]="moved some bricks around";
theMatcher["DreadVillage","+Skid Row.31"]="looted the tinker's shack";
theMatcher["DreadVillage","+Skid Row.32"]="made a complicated key";
theMatcher["DreadVillage","+Skid Row.33"]="polished some moon-amber";
theMatcher["DreadVillage","+Skid Row.34"]="made a clockwork bird";
theMatcher["DreadVillage","+Skid Row.35"]="got some old fuse";
theMatcher["DreadVillage","+Estate.11"]="drove some zombies out of the village";
theMatcher["DreadVillage","+Estate.12"]="robbed some graves";
theMatcher["DreadVillage","+Estate.13"]="read some lurid epitaphs";
theMatcher["DreadVillage","+Estate.21"]="made the village less hot";
theMatcher["DreadVillage","+Estate.22"]="made a shepherd's pie";
theMatcher["DreadVillage","+Estate.23"]="raided some naughty cabinets";
theMatcher["DreadVillage","+Estate.30"]="unlocked the master suite";
theMatcher["DreadVillage","+Estate.31"]="drove some werewolves out of the forest";
theMatcher["DreadVillage","+Estate.32"]="got a bottle of eau de mort";
theMatcher["DreadVillage","+Estate.33"]="made a ghost shawl";

theMatcher["DreadCastle","&nbsp;"]="defeated( by)?  (hot|cold|spooky|stench|sleaze) (skeleton|vampire)";
theMatcher["DreadCastle","!Vampire"]="defeated( by)?  Count Drunkula";
theMatcher["DreadCastle","!Skeleton"]="defeated( by)?  The Unkillable Skeleton";
theMatcher["DreadCastle","+Great Hall.10"]="unlocked the ballroom";
theMatcher["DreadCastle","+Great Hall.11"]="drove some vampires out of the castle";
theMatcher["DreadCastle","+Great Hall.12"]="twirled on the dance floor";
theMatcher["DreadCastle","+Great Hall.21"]="made the castle less cold";
theMatcher["DreadCastle","+Great Hall.22"]="frolicked in a freezer";
theMatcher["DreadCastle","+Great Hall.31"]="got some roast beast";
theMatcher["DreadCastle","+Great Hall.32"]="made the castle less stinky";
theMatcher["DreadCastle","+Great Hall.33"]="got a wax banana";
theMatcher["DreadCastle","+Tower.10"]="unlocked the lab";
theMatcher["DreadCastle","+Tower.11"]="drove some bugbears out of the forest";
theMatcher["DreadCastle","+Tower.12"]="drove some zombies out of the village";
theMatcher["DreadCastle","+Tower.13"]="fixed The Machine";
theMatcher["DreadCastle","+Tower.14"]="made a blood kiwitini";
theMatcher["DreadCastle","+Tower.21"]="drove some skeletons out of the castle";
theMatcher["DreadCastle","+Tower.22"]="read some ancient secrets";
theMatcher["DreadCastle","+Tower.23"]="learned to make a moon-amber necklace";
theMatcher["DreadCastle","+Tower.31"]="made the castle less sleazy";
theMatcher["DreadCastle","+Tower.32"]="raided a dresser";
theMatcher["DreadCastle","+Tower.33"]="got magically fingered";
theMatcher["DreadCastle","+Dungeon.11"]="made the castle less spooky";
theMatcher["DreadCastle","+Dungeon.12"]="did a whole bunch of pushups";
theMatcher["DreadCastle","+Dungeon.13"]="took a nap on a prison cot";
theMatcher["DreadCastle","+Dungeon.21"]="made the castle less hot";
theMatcher["DreadCastle","+Dungeon.22"]="sifted through some ashes";
theMatcher["DreadCastle","+Dungeon.23"]="relaxed in a furnace";
theMatcher["DreadCastle","+Dungeon.31"]="got some stinking agaric";
theMatcher["DreadCastle","+Dungeon.32"]="rolled around in some mushrooms";

theMatcher["DreadPencil","DreadWoods.Cabin"]="loc=1";
theMatcher["DreadPencil","DreadWoods.Tree"]="loc=2";
theMatcher["DreadPencil","DreadWoods.Burrows"]="loc=3";
theMatcher["DreadPencil","DreadVillage.Square"]="loc=4";
theMatcher["DreadPencil","DreadVillage.Skid Row"]="loc=5";
theMatcher["DreadPencil","DreadVillage.Estate"]="loc=6";
theMatcher["DreadPencil","DreadCastle.Great Hall"]="loc=7";
theMatcher["DreadPencil","DreadCastle.Tower"]="loc=8";
theMatcher["DreadPencil","DreadCastle.Dungeon"]="loc=9";

//End Consts

string noSpaces(string input){
 matcher m=create_matcher("\\s",input);
 return m.replace_all("");
}

int abs(int i){
 if(i<0)return -i;
 return i;
}

string expand(string s){
 switch(s){
  case "TS":return "Town Square";
  case "BB":return "Burnbarrel<br>Blvd.";
  case "EE":return "Exposure<br>Esplanade";
  case "AHBG":case "BG":return "Ancient Hobo<br>Burial Ground";
  case "PLD":return "Purple Light<br>District";
  case "Slime":return "Slime Tube";
  case "Parts":return "Richard";
  case "DreadWoods":case "Woods":return "The Woods";
  case "DreadVillage":case "Village":return "The Village";
  case "DreadCastle":case "Castle":return "The Castle";
 }
 return s;
}

string bossName(string s){
 switch(s){
  case "TS":return "Hodgman";
  case "BB":return "Ol' Scratch";
  case "EE":return "Frosty";
  case "Heap":return "Oscus";
  case "AHBG":case "BG":return "Zombo";
  case "PLD":return "Chester";
  case "Slime":return "Mother Slime";
  case "Parts":return "Richard";
  case "Woods":if(data[".data","DreadWoods"] contains "!Werewolf")return "The Great Wolf of the Air";
   else if(data[".data","DreadWoods"] contains "!Bugbear")return "Falls-From-Sky";
   else return "Unknown";
  case "Village":if(data[".data","DreadVillage"] contains "!Ghost")return "Mayor Ghost";
   else if(data[".data","DreadVillage"] contains "!Zombie")return "Zombie HOA";
   else return "Unknown";
  case "Castle":if(data[".data","DreadCastle"] contains "!Vampire")return "Count Drunkula";
   else if(data[".data","DreadCastle"] contains "!Skeleton")return "Unkillable Skeleton";
   else return "Unknown";
  case "Inn":return "Carriageman";
 }
 return s;
}

string linkify(string u){
 return "<a href=\"showplayer.php?who="+data[".data",".id",u]+"\">"+u+"</a>";
}

string imageOf(string who){
 switch(who){
  case "The Great Wolf of the Air":return "http://images.kingdomofloathing.com/adventureimages/wolfoftheair.gif";
  case "Falls-From-Sky":return "http://images.kingdomofloathing.com/adventureimages/fallsfromsky.gif";
  case "Mayor Ghost":return "http://images.kingdomofloathing.com/adventureimages/mayorghost.gif";
  case "Zombie HOA":return "http://images.kingdomofloathing.com/adventureimages/zombiehoa.gif";
  case "Count Drunkula":return "http://images.kingdomofloathing.com/adventureimages/drunkula.gif";
  case "Unkillable Skeleton":return "http://images.kingdomofloathing.com/adventureimages/ukskeleton.gif";
  case "Carriageman":return "http://images.kingdomofloathing.com/otherimages/dv/biginn.gif";
 }
 return "http://images.kingdomofloathing.com/adventureimages/question.gif";
}

string linkTo(string where){
 switch(where){
  case "Inn":return "shop.php?whichshop=dv";
  case "Woods":return "adventure.php?snarfblat=338";
  case "Cabin":return "clan_dreadsylvania.php?action=forceloc&loc=1";
  case "Tree":return "clan_dreadsylvania.php?action=forceloc&loc=2";
  case "Burrows":return "clan_dreadsylvania.php?action=forceloc&loc=3";
  case "Village":return "adventure.php?snarfblat=339";
  case "Square":return "clan_dreadsylvania.php?action=forceloc&loc=4";
  case "Skid Row":return "clan_dreadsylvania.php?action=forceloc&loc=5";
  case "Estate":return "clan_dreadsylvania.php?action=forceloc&loc=6";
  case "Castle":return "adventure.php?snarfblat=340";
  case "Great Hall":return "clan_dreadsylvania.php?action=forceloc&loc=7";
  case "Tower":return "clan_dreadsylvania.php?action=forceloc&loc=8";
  case "Dungeon":return "clan_dreadsylvania.php?action=forceloc&loc=9";
 }
 return "clan_basement.php";
}

string capitalize(string s){
 if(s.length()<2)return s.to_upper_case();
 return s.char_at(0).to_upper_case()+s.substring(1);
}

string pullField(int[string,string] fakeField, string fName){
 string rv;
 foreach s,i in fakeField[fName] rv=s;
 return rv;
}

string getName(string l){
 matcher m=create_matcher("(?:<b>)?([\\w\\s_]+) \\(#(\\d+)\\)",l);
 if(!m.find())return ".";
 data[".data",".id",m.group(1)]=m.group(2).to_int();
 return m.group(1);
}

int getTurns(string l){
 matcher m=create_matcher("\\((\\d+) turns?\\)",l);
 if(!m.find())return 0;
 return m.group(1).to_int();
}

int parseImageN(string l){
 matcher m=create_matcher("(?<!sewer)(\\d+)\\.gif",l);
 if(!m.find())return -1;
 return m.group(1).to_int();
}

int parseImageS(string l){
 matcher m=create_matcher("(tube_boss|\\d+)\\.gif",l);
 if(!m.find())return -1;
 if(m.group(1)=="tube_boss")return 10;
 return m.group(1).to_int();
}

void parseHB(string hobo){
 string[int] lines;
 matcher m=create_matcher("Sewers:</b><blockquote>(.+?)</blockquote>",hobo);
 string w;
 int t;
 string tp;
 if(m.find()){
  data[".data","Hobo",".hasdata"]=1;
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["Sewer"]{
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l);
   t=getTurns(l);
   data[w,"Sewer",pointName]+=t;
   data[w,"Sewer",".total"]+=t;
   data[w,".hobo",".total"]+=t;
   data[".total","Sewer",pointName]+=t;
   data[".total","Sewer",".total"]+=t;
   data[".total",".hobo",".total"]+=t;
   break;
  }
 }else{
  data[".data","Hobo",".hasdata"]=-1;
  data[".data","Sewer",".hasdata"]=-1;
 }
 m=create_matcher("Town Square:</b><blockquote>(.+?)</blockquote>",hobo);
 if(m.find()){
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["TS"]{
   if(pointName.char_at(0)==".")continue;
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l);
   t=getTurns(l);
   data[w,"TS",pointName]+=t;
   data[w,"TS",".total"]+=t;
   data[w,".hobo",".total"]+=t;
   data[".total","TS",pointName]+=t;
   data[".total","TS",".total"]+=t;
   data[".total",".hobo",".total"]+=t;
   break;
  }  
 }else{
  data[".data","TS",".hasdata"]=-1;
 }
 data[".data","BB",".open"]=0;
 data[".data","EE",".open"]=0;
 data[".data","Heap",".open"]=0;
 data[".data","AHBG",".open"]=0;
 data[".data","PLD",".open"]=0;
 if(runType<0){
  tp=visit_url("clan_hobopolis.php?place=2");
  m=create_matcher("Town Square \\(picture #(\\d+)(o?)\\)",tp);
  if(m.find()){
   data[".data","TS",".image"]=m.group(1).to_int();
   if(data[".data","TS",".image"]==125)data[".data","TS",".image"]=13;
   data[".data","TS",".open"]=(m.group(2)=="o"?1:0);
   data[".data","BB",".open"]=-1;
   data[".data","EE",".open"]=-1;
   data[".data","Heap",".open"]=-1;
   data[".data","AHBG",".open"]=-1;
   data[".data","PLD",".open"]=-1;
  }else data[".data","TS",".image"]=-1;
  switch(data[".data","TS",".image"]){
   case 26:case 25:case 24:case 23:case 22:case 21:case 20:case 19:case 18:case 17:case 16:case 15: case 14: case 13:case 12:case 11:case 10:
    data[".data","PLD",".open"]=1;
   case 9:case 8:data[".data","AHBG",".open"]=1;
   case 7:case 6:data[".data","Heap",".open"]=1;
   case 5:case 4:data[".data","EE",".open"]=1;
   case 3:case 2:data[".data","BB",".open"]=1;break;
   case 1:case 0:break;
  }
 }
 data[".data","BB",".hasdata"]=-1;
 data[".data","EE",".hasdata"]=-1;
 data[".data","Heap",".hasdata"]=-1;
 data[".data","AHBG",".hasdata"]=-1;
 data[".data","PLD",".hasdata"]=-1;
 foreach area in $strings[BB,EE,Heap,AHBG,PLD]{
  if(data[".data",area,".open"]>-1){
   m=create_matcher(theMatcher[area,".gmatcher"]+":</b><blockquote>(.+?)</blockquote>",hobo);
   if(m.find()){
    data[".data",area,".open"]=1;
    data[".data",area,".hasdata"]=1;
    lines=split_string(m.group(1),"<br>");
    foreach ln,l in lines foreach pointName,mString in theMatcher[area]{
     if(pointName.char_at(0)==".")continue;
     m=create_matcher(mString,l);
     if(!m.find())continue;
     w=getName(l);
     t=getTurns(l);
     data[w,area,pointName]+=t;
     data[w,area,".total"]+=t;
     data[w,".hobo",".total"]+=t;
     data[".total",area,pointName]+=t;
     data[".total",area,".total"]+=t;
     data[".total",".hobo",".total"]+=t;
     break;
    }
   }
   if((runType<0)&&(data[".data","TS",".image"]>-1)){
    tp=visit_url("clan_hobopolis.php?place="+theMatcher[area,".place"]);
    data[".data",area,".image"]=parseImageN(tp);
   }
   if(data[".total",area,"!"+area.bossName()]>0)data[".data",area,".image"]=11;
  }
 }
 m=create_matcher("Miscellaneous</b><blockquote>(.+?)</blockquote>",hobo);
 if(m.find()){
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["TS"]{
   if(pointName.char_at(0)==".")continue;
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l);
   t=getTurns(l);
   data[w,"TS",pointName]+=t;
   data[w,"TS",".total"]+=t;
   data[w,".hobo",".total"]+=t;
   data[".total","TS",pointName]+=t;
   data[".total","TS",".total"]+=t;
   data[".total",".hobo",".total"]+=t;
   break;
  }
 }
 if(data[".total","TS","!Hodgman"]>0)data[".data","TS",".image"]=26;
 foreach pointName,mString in theMatcher["Parts"] data[".data","Richard",pointName]=0;
 if(runType<0){
  tp=visit_url("clan_hobopolis.php?place=3&action=talkrichard&whichtalk=3");
  if(tp.contains_text("a scarehobo")){
   foreach pointName,mString in theMatcher["Parts"]{
    if(pointName.char_at(0)==".")continue;
    m=create_matcher(mString,tp);
    if(!m.find())continue;
    data[".data","Richard",pointName]=m.group(1).to_int();
   }
  }
 }
}

void parseST(string st){
 matcher m=create_matcher("Miscellaneous</b><blockquote>(.+?)</blockquote>",st);
 int t;
 string w;
 string[int] lines;
 if(m.find()){
  data[".data","Slime",".hasdata"]=1;
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["Slime"]{
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l);
   t=getTurns(l);
   data[w,"Slime",pointName]+=t;
   data[w,"Slime",".total"]+=t;
   data[".stotal","Slime",pointName]+=t;
   data[".stotal","Slime",".total"]+=t;
   break;
  }
 }else{
  data[".data","Slime",".hasdata"]=-1;
 }
 if(runType<0)data[".data","Slime",".image"]=parseImageS(visit_url("clan_slimetube.php"));
 if(data[".stotal","Slime","!Mother Slime"]>0)data[".data","Slime",".image"]=11;
}

void parseHH(string hh){
 matcher m=create_matcher("Miscellaneous</b><blockquote>(.+?)</blockquote>",hh);
 int t;
 string w;
 string[int] lines;
 if(m.find()){
  data[".data","Haunted",".hasdata"]=1;
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["Haunted"]{
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l);
   t=getTurns(l);
   data[w,"Haunted",pointName]+=t;
   data[w,"Haunted",".total"]+=t;
   data[".htotal","Haunted",pointName]+=t;
   data[".htotal","Haunted",".total"]+=t;
   break;
  }
 }else{
  data[".data","Haunted",".hasdata"]=-1;
 }
}

string spoiler(string zone, string what){
 switch(zone){
  case"DreadWoods":case"Woods":
   switch(what){
    case"Hot":return "Burrows->Heat->Cork";
    case"Cold":return "Burrows->Cold->Read";
    case"Spooky":return "Cabin->Attic->Music Box";
    case"Sleaze":return "Tree->Climb->Kick Nest";
    case"Stench":return "Cabin->Kitchen->Disposal";
   }
   break;
  case"DreadVillage":case"Village":
   switch(what){
    case"Hot":return "Estate->Quarters->Ovens";
    case"Cold":return "Square->Blacksmith->Furnace";
    case"Spooky":return "Square->Gallows->Paint Noose";
    case"Sleaze":return "Skid Row->Tenements->Paint";
    case"Stench":return "Skid Row->Sewers->Unclog";
   }
   break;
  case"DreadCastle":case"Castle":
   switch(what){
    case"Hot":return "Dungeon->Boiler->Steam";
    case"Cold":return "Great Hall->Kitchen->Lower Freezer";
    case"Spooky":return "Dungeon->Cell Block->Flush";
    case"Sleaze":return "Tower->Bedroom->Parrot";
    case"Stench":return "Great Hall->Dining Room->Dishes";
   }
   break;
 }
 return "";
}

string[int] layout;
layout[1]="Cabin,Unlock(Attic),Freddies(10),Auditor's Badge(1),Music Box(-Spooky)";
layout[2]="Square,Unlock(Schoolhouse),Freddies(10),Ghost Pencil(10)";
layout[3]="Great Hall,Unlock(Ballroom),Dreadful Roast(1),Wax Banana(1)";
layout[4]="Tree,Unlock(Watchtower),Freddies(10),Blood Kiwi(Stomped),Moon-Amber(1)";
layout[5]="Skid Row,Freddies(10)";
layout[6]="Tower,Unlock(Laboratory),Freddies(10)";
layout[7]="Burrows,Freddies(10)";
layout[8]="Estate,Unlock(Suite),Freddies(10)";
layout[9]="Dungeon,Freddies(10),Stinking Agaricus(1)";
string dreadNonComStr(string zone, int opt){
 switch(zone){
  case"+Cabin":
   switch(opt){
    case 11:return "Dread Tarragon";
    case 12:return "Bone Flour";
    case 13:return "-Stench";
    case 21:return "Freddies";
    case 22:return "Bored Stiff";
    case 23:return "Auditor's Badge";
    case 24:return "Lock Impression";
    case 30:return "Attic";
    case 31:return "-Spooky";
    case 32:return "-Werewolves";
    case 33:return "-Vampires";
    case 34:return "Moxie";
   }
   break;
  case"+Tree":
   switch(opt){
    case 11:return "Stomped";
    case 12:return "-Sleaze";
    case 13:return "Moon-Amber";
    case 20:return "Watchtower";
    case 21:return "-Ghosts";
    case 22:return "Freddies";
    case 23:return "Muscle";
    case 31:return "Blood Kiwi";
    case 32:return "Seed Pod";
    case 33:return "Owl Folder";
   }
   break;
  case"+Burrows":
   switch(opt){
    case 11:return "-Hot";
    case 12:return "Coals";
    case 13:return "Cool Ingot";
    case 21:return "-Cold";
    case 22:return "Myst";
    case 23:return "Bounty";
    case 31:return "-Bugbears";
    case 32:return "Freddies";
   }
   break;
  case"+Square":
   switch(opt){
    case 10:return "Schoolhouse";
    case 11:return "-Ghosts";
    case 12:return "Ghost Pencil";
    case 13:return "Myst";
    case 21:return "-Cold";
    case 22:return "Freddies";
    case 23:return "Cool Iron Equipment";
    case 31:return "-Spooky";
    case 32:return "Trap Door Item";
    case 33:return "-";
    case 34:return "Pulled Lever";
   }
   break;
  case"+Skid Row":
   switch(opt){
    case 11:return "-Stench";
    case 12:return "Drenched";
    case 21:return "-Skeletons";
    case 22:return "-Sleaze";
    case 23:return "Muscle";
    case 31:return "Freddies";
    case 32:return "Replica Key";
    case 33:return "Polished Amber";
    case 34:return "Songbird";
    case 35:return "Old Fuse";
   }
   break;
  case"+Estate":
   switch(opt){
    case 11:return "-Zombies";
    case 12:return "Freddies";
    case 13:return "50 Ways";
    case 21:return "-Hot";
    case 22:return "Shepherd's Pie";
    case 23:return "Moxie";
    case 30:return "Suite";
    case 31:return "-Werewolves";
    case 32:return "Eau de Mort";
    case 33:return "Ghost Shawl";
   }
   break;
  case"+Great Hall":
   switch(opt){
    case 10:return "Ballroom";
    case 11:return "-Vampires";
    case 12:return "Moxie";
    case 21:return "-Cold";
    case 22:return "Frosty";
    case 31:return "Dreadful Roast";
    case 32:return "-Stench";
    case 33:return "Wax Banana";
   }
   break;
  case"+Tower":
   switch(opt){
    case 10:return "Laboratory";
    case 11:return "-Bugbears";
    case 12:return "-Zombies";
    case 13:return "Fixed The Machine";
    case 14:return "Bloody Kiwitini";
    case 21:return "-Skeletons";
    case 22:return "Myst";
    case 23:return "Necklace Recipe";
    case 31:return "-Sleaze";
    case 32:return "Freddies";
    case 33:return "Fingered";
   }
   break;
  case"+Dungeon":
   switch(opt){
    case 11:return "-Spooky";
    case 12:return "Muscle";
    case 13:return "MP";
    case 21:return "-Hot";
    case 22:return "Freddies";
    case 23:return "Stats";
    case 31:return "Stinking Agaricus";
    case 32:return "Spore-Wreathed";
   }
   break;
 }
 return "";
}

void formatDreadOptions(){
 boolean classLock(string nc, int directory){
  switch(nc){
   case"Tree":if(((directory/10)==1)&&(my_primestat()!=$stat[muscle]))return true;return false;
   case"Skid Row":if(((directory/10)==3)&&(my_primestat()!=$stat[moxie]))return true;return false;
   case"Tower":if(((directory/10)==2)&&(my_primestat()!=$stat[mysticality]))return true;return false;
  }
  return false;
 }
 boolean keyLocked(string nc, int directory){
  if(data[".data"]contains(".unlock."+nc))return false;
  switch(nc){
   case"Cabin":if((directory/10)!=3)return false;return true;
   case"Tree":if((directory/10)!=2)return false;return true;
   case"Square":if((directory/10)!=1)return false;return true;
   case"Estate":if((directory/10)!=3)return false;return true;
   case"Tower":if((directory/10)!=1)return false;return true;
   case"Great Hall":if((directory/10)!=1)return false;return true;
  }
  return false;
 }
 matcher m=create_matcher("([^.]+)\\.(.*)","");
 string zone;
 string nc;
 string menu;
 int[string]resultList;
 foreach area,locNum in theMatcher["DreadPencil"]{
  m.reset(area);
  if(!m.find())continue;
  zone=m.group(1);
  nc=m.group(2);
  menu=nc.noSpaces()+"td";
  if(data[my_name(),zone,"+"+nc]%10!=0){
   contexts[menu]+='"done": {name: "You\'ve already adventured here!", disabled: true}';
   continue;
  }
  if( (("Cabin Tree Burrows".contains_text(nc))&&(data[".data","DreadWoods",".dist"]>999))||
     (("Square Skid Row Estate".contains_text(nc))&&(data[".data","DreadVillage",".dist"]>999))||
     (("Great Hall Tower Dungeon".contains_text(nc))&&(data[".data","DreadCastle",".dist"]>999)) ){
   contexts[menu]+='"done": {name: "This area is finished.", disabled: true}';
   continue;
  }
  if( (("Square Skid Row Estate".contains_text(nc))&&(data[".data","Dread",".carriage"]<1000))||
     (("Great Hall Tower Dungeon".contains_text(nc))&&(data[".data","Dread",".carriage"]<2000)) ){
   contexts[menu]+='"done": {name: "The carriageman isn\'t drunk enough to bring you here.", disabled: true}';
   continue;
  }  
  if(data[".data",".pencil",nc]==1){
   boolean empty=true;
   boolean first=true;
   boolean keyOp=false;
   clear(resultList);
   for tens from 1 to 3 for ones from 1 to 5 resultList[dreadNonComStr("+"+nc,tens*10+ones)]=tens*10+ones;
   remove resultList[""];
   if((resultList contains "Freddies")&&(data[".data",zone,"+"+nc+".Freddies"]<10)){
    contexts[menu]+='"g'+locNum.char_at(4)+resultList["Freddies"]+'": {name: "Collect Freddies", accesskey:"f"';
    if(classLock(nc,resultList["Freddies"]))contexts[menu]+=", disabled: true";
    else if(keyLocked(nc,resultList["Freddies"])){
     keyOp=true;
     contexts[menu]+=', icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}';
    }
    contexts[menu]+='},';
    empty=false;
   }
   foreach e in $strings[Hot,Cold,Spooky,Sleaze,Stench] if((resultList contains ("-"+e))&&(data[".data",zone,"."+e]==0)){
    if((zone=="DreadVillage")&&(e=="Cold")&&(data[".data",zone,".Hot"]!=0))continue;
    empty=false;
    if(first){
     contexts[menu]+='"elemList": {name: "Banish Element", accesskey:"e", items:{';
     first=false;
    }
    contexts[zone+"_"+e]='"g'+locNum.char_at(4)+resultList["-"+e]+'": {name: "Banish '+e+'", accesskey:"b"';
    contexts[menu]+='"g'+locNum.char_at(4)+resultList["-"+e]+'": {name: "'+e+'", accesskey:"'+e.char_at(0)+' '+e.char_at(1)+'"';
    if(classLock(nc,resultList["-"+e])){
     contexts[zone+"_"+e]+=", disabled: true";
     contexts[menu]+=", disabled: true";
    }else if(keyLocked(nc,resultList["-"+e])){
     keyOp=true;
     contexts[zone+"_"+e]+=', icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}';
     contexts[menu]+=', icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}';
    }
    if((zone=='DreadVillage')&&(e=='Hot')&&(data[".data",zone,".Cold"]==0))contexts[zone+"_"+e]+=", callback: function(key, options){if(confirm('Cold has not been banished yet, banishing Hot now will make this impossible, do you wish to continue?')){window.location='clan_raidlogs.ash?cmd=g621';}}";
    contexts[zone+"_"+e]+='},';
    if(keyOp)contexts[zone+"_"+e]+='"toggle": {name: "Use Dreadsylvania Key", callback: function() {this.data(\''+nc.noSpaces()+'Disabled\', !this.data(\''+nc.noSpaces()+'Disabled\')); return false;}}';
    contexts[menu]+='},';
   }
   if(!first)contexts[menu]+='}},';
   first=true;
   foreach e in $strings[Bugbears,Werewolves,Ghosts,Zombies,Skeletons,Vampires] if((resultList contains ("-"+e))&&(data[".data",zone,"+"+nc+".-"+e]==0)){
    empty=false;
    if(first){
     contexts[menu]+='"monList": {name: "Banish Monster", accesskey:"m", items:{';
     first=false;
    }
    contexts[menu]+='"g'+locNum.char_at(4)+resultList["-"+e]+'": {name: "'+e+'", accesskey:"'+e.char_at(0)+' '+e.char_at(1)+'"';
    if(classLock(nc,resultList["-"+e]))contexts[menu]+=", disabled: true";
    else if(keyLocked(nc,resultList["-"+e])){
     keyOp=true;
     contexts[menu]+=', icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}';
    }
    contexts[menu]+='},';
   }
   if(!first)contexts[menu]+='}},';
   if(!empty)contexts[menu]+='"sep1": "---------",';
   switch(nc){
    case"Cabin":
     contexts[menu]+='"kitchenList": {name: "Kitchen", items:{';
     contexts[menu]+='"g111": {name: "Collect Dread Tarragon"},';
     contexts[menu]+='"g112": {name: "Grind Bone into Flour"'+((my_primestat()==$stat[muscle])&&(item_amount($item[old dry bone])>0)?"":", disabled: true")+'},';
     contexts[menu]+='"g113": {name: "Banish Stench"'+(data[".data",zone,".Stench"]==0?"":", disabled: true")+'}}},';
     contexts[menu]+='"basementList": {name: "Basement", items:{';
     contexts[menu]+='"g121": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"g122": {name: "Gain Bored Stiff"},';
     contexts[menu]+='"g123": {name: "Collect Auditor\'s Badge"'+((item_amount($item[replica key])>0)&&(data[".data",zone,"+"+nc+".Auditor's Badge"]<1)?"":", disabled: true")+'},';
     contexts[menu]+='"g124": {name: "Make Lock Impression"'+(item_amount($item[wax banana])>0?"":", disabled: true")+'}}},';
     contexts[menu]+='"atticList": {name: "Attic", '+(keyLocked(nc,30)?'icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}, ':"")+'items:{';
     contexts[menu]+='"g131": {name: "Banish Spooky"'+(data[".data",zone,".Spooky"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g132": {name: "Banish Werewolves"'+(data[".data",zone,"+"+nc+".-Werewolves"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g133": {name: "Banish Vampires"'+(data[".data",zone,"+"+nc+".-Vampires"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g134": {name: "Moxie Stats"}}},';
     break;
    case"Tree":
     contexts[menu]+='"topList": {name: "Top", '+(classLock(nc,10)?"disabled: true, ":"")+'items:{';
     contexts[menu]+='"g211": {name: "Drop Blood Kiwi"'+(data[".data",zone,"+"+nc+".Stomped"]>0?", disabled: true":"")+'},';
     contexts[menu]+='"g212": {name: "Banish Sleaze"'+(data[".data",zone,".Sleaze"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g213": {name: "Collect Moon-Amber"'+(data[".data",zone,"+"+nc+".Moon-Amber"]>0?", disabled: true":"")+'}}},';
     contexts[menu]+='"towerList": {name: "Fire Tower", '+(keyLocked(nc,20)?'icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}, ':"")+'items:{';
     contexts[menu]+='"g221": {name: "Banish Ghosts"'+(data[".data",zone,"+"+nc+".-Ghosts"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g222": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"g223": {name: "Muscle Stats"}}},';
     contexts[menu]+='"baseList": {name: "Base", items:{';
     contexts[menu]+='"r231": {name: "Wait for Blood Kiwi"'+(data[".data",zone,"+"+nc+".Stomped"]>0?", disabled: true":"")+'},';
     contexts[menu]+='"g232": {name: "Collect Seed Pod"},';
     contexts[menu]+='"g233": {name: "Collect Owl Folder"'+(equipped_amount($item[over-the-shoulder folder holder])>0?"":", disabled: true")+'}}},';
     break;
    case"Burrows":
     contexts[menu]+='"hotList": {name: "Heat", items:{';
     contexts[menu]+='"g311": {name: "Banish Hot"'+(data[".data",zone,".Hot"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g312": {name: "Gain Dragged Through the Coals"},';
     contexts[menu]+='"g313": {name: "Smelt Cool Iron"'+(item_amount($item[old ball and chain])>0?"":", disabled: true")+'}}},';
     contexts[menu]+='"coldList": {name: "Cold", items:{';
     contexts[menu]+='"g321": {name: "Banish Cold"'+(data[".data",zone,".Cold"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g322": {name: "Mysticality Stats"},';
     contexts[menu]+='"g323": {name: "Gain Nature\'s Bounty"}}},';
     contexts[menu]+='"smellyList": {name: "Smelly", items:{';
     contexts[menu]+='"g331": {name: "Banish Bugbears"'+(data[".data",zone,"+"+nc+".-Bugbears"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g332": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'}}},';
     break;
    case"Square":
     contexts[menu]+='"schoolList": {name: "Schoolhouse", '+(keyLocked(nc,10)?'icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}, ':"")+'items:{';
     contexts[menu]+='"g411": {name: "Banish Ghosts"'+(data[".data",zone,"+"+nc+".-Ghosts"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g412": {name: "Collect Ghost Pencil"'+(data[".data",zone,"+"+nc+".Ghost Pencil"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"g413": {name: "Mysticality Stats"}}},';
     contexts[menu]+='"blackList": {name: "Blacksmith", items:{';
     contexts[menu]+='"g421": {name: "Banish Cold"'+((data[".data",zone,".Cold"]==0)&&(data[".data",zone,".Hot"]==0)?"":", disabled: true")+'},';
     contexts[menu]+='"g422": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"r423": {name: "Smith Cool Iron"'+((item_amount($item[hothammer])>0)&&(item_amount($item[cool iron ingot])>0)&&(item_amount($item[warm fur])>0)?"":", disabled: true")+'}}},';
     contexts[menu]+='"gallowsList": {name: "Gallows", items:{';
     contexts[menu]+='"g431": {name: "Banish Spooky"'+(data[".data",zone,".Spooky"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"r432": {name: "Wait for '+(my_primestat()==$stat[muscle]?"Hangman's Hood":(my_primestat()==$stat[moxie]?"Clockwork Key":"Cursed Ring"))+'"'+(data[".data"] contains ".hung"?", disabled: true":"")+'},';
     contexts[menu]+='"g434": {name: "Pull the Lever"'+(data[".data"] contains ".hung"?", disabled: true":"")+'}}},';
     break;
    case"Skid Row":
     contexts[menu]+='"sewerList": {name: "Sewers", items:{';
     contexts[menu]+='"g511": {name: "Banish Stench"'+(data[".data",zone,".Stench"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g512": {name: "Gain Sewer-Drenched"}}},';
     contexts[menu]+='"tenementsList": {name: "Tenements", items:{';
     contexts[menu]+='"g521": {name: "Banish Skeletons"'+(data[".data",zone,"+"+nc+".-Skeletons"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g522": {name: "Banish Sleaze"'+(data[".data",zone,".Sleaze"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g523": {name: "Muscle Stats"}}},';
     contexts[menu]+='"shackList": {name: "Ticking Shack", '+(classLock(nc,30)?"disabled: true, ":"")+'items:{';
     contexts[menu]+='"g531": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"g532": {name: "Replicate Key"'+((item_amount($item[intricate music box parts])>0)&&(item_amount($item[complicated lock impression])>0)?"":", disabled: true")+'},';
     contexts[menu]+='"g533": {name: "Polish Moon-Amber"'+(item_amount($item[moon-amber])>0?"":", disabled: true")+'},';
     contexts[menu]+='"g534": {name: "Assemble Songbird"'+((item_amount($item[intricate music box parts])>2)&&(item_amount($item[dreadsylvanian clockwork key])>0)?"":", disabled: true")+'},';
     contexts[menu]+='"g535": {name: "Collect Old Fuse"}}},';
     break;
    case"Estate":
     contexts[menu]+='"plotList": {name: "Family Plot", items:{';
     contexts[menu]+='"g611": {name: "Banish Zombies"'+(data[".data",zone,"+"+nc+".-Zombies"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g612": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"g613": {name: "Gain 50 Ways"}}},';
     contexts[menu]+='"quarterList": {name: "Servant\'s Quarters", items:{';
     contexts[menu]+='"g621": {name: "Banish Hot"'+(data[".data",zone,".Hot"]==0?"":", disabled: true")+(data[".data",zone,".Cold"]==0?", callback: function(key, options){if(confirm('Cold has not been banished yet, banishing Hot now will make this impossible, do you wish to continue?')){window.location='clan_raidlogs.ash?cmd=621';}}":"")+'},';
     contexts[menu]+='"g622": {name: "Make Pie"'+((item_amount($item[dread tarragon])>0)&&(item_amount($item[bone flour])>0)&&(item_amount($item[dreadful roast])>0)&&(item_amount($item[stinking agaricus])>0)?"":", disabled: true")+'},';
     contexts[menu]+='"g623": {name: "Moxie Stats"}}},';
     contexts[menu]+='"suiteList": {name: "Master Suite", '+(keyLocked(nc,30)?'icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}, ':"")+'items:{';
     contexts[menu]+='"g631": {name: "Banish Werewolves"'+(data[".data",zone,"+"+nc+".-Werewolves"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g632": {name: "Collect Eau de Mort"},';
     contexts[menu]+='"g633": {name: "Sew Ghost Shawl"'+(item_amount($item[ghost thread])>9?"":", disabled: true")+'}}},';
     break;
    case"Great Hall":
     contexts[menu]+='"ballroomList": {name: "Ballroom", '+(keyLocked(nc,10)?'icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}, ':"")+'items:{';
     contexts[menu]+='"g711": {name: "Banish Vampires"'+(data[".data",zone,"+"+nc+".-Vampires"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g712": {name: "Moxie Stats"}}},';
     contexts[menu]+='"kitchenList": {name: "Kitchen", items:{';
     contexts[menu]+='"g721": {name: "Banish Cold"'+(data[".data",zone,".Cold"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g722": {name: "Gain Staying Frosty"}}},';
     contexts[menu]+='"diningList": {name: "Dining Room", items:{';
     contexts[menu]+='"g731": {name: "Collect Dreadful Roast"'+(data[".data",zone,"+"+nc+".Dreadful Roast"]>0?", disabled: true":"")+'},';
     contexts[menu]+='"g732": {name: "Banish Stench"'+(data[".data",zone,".Stench"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g733": {name: "Collect Wax Banana"'+(my_primestat()==$stat[mysticality]?"":", disabled: true")+'}}},';
     break;
    case"Tower":
     contexts[menu]+='"labratoryList": {name: "Laboratory", '+(keyLocked(nc,10)?'icon: "key", disabled: function(key, opt){return !this.data(\''+nc.noSpaces()+'Disabled\');}, ':"")+'items:{';
     contexts[menu]+='"g811": {name: "Banish Bugbears"'+(data[".data",zone,"+"+nc+".-Bugbears"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g812": {name: "Banish Zombies"'+(data[".data",zone,"+"+nc+".-Zombies"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g813": {name: "'+(data[".data"] contains ".machine"?"Visit":"Repair")+' the Machine"'+((data[".data"] contains ".machine")||(item_amount($item[skull capacitor])>0)?"":", disabled: true")+'},';
     contexts[menu]+='"g814": {name: "Mix Blood Kiwitini"'+((item_amount($item[eau de mort])>0)&&(item_amount($item[blood kiwi])>0)&&(my_primestat()==$stat[moxie])?"":", disabled: true")+'}}},';
     contexts[menu]+='"booksList": {name: "Books", '+(classLock(nc,20)?"disabled: true, ":"")+'items:{';
     contexts[menu]+='"g821": {name: "Banish Skeletons"'+(data[".data",zone,"+"+nc+".-Skeletons"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g822": {name: "Myst Stats"},';
     contexts[menu]+='"g823": {name: "Learn Necklace Recipe"}}},';
     contexts[menu]+='"bedroomList": {name: "Bedroom", items:{';
     contexts[menu]+='"g831": {name: "Banish Sleaze"'+(data[".data",zone,".Sleaze"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g832": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"g833": {name: "Gain Magically Fingered"}}},';
     break;
    case"Dungeon":
     contexts[menu]+='"cellList": {name: "Cell Block", items:{';
     contexts[menu]+='"g911": {name: "Banish Spooky"'+(data[".data",zone,".Spooky"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g912": {name: "Muscle Stats"},';
     contexts[menu]+='"g913": {name: "MP"}}},';
     contexts[menu]+='"boilerList": {name: "Boiler Room", items:{';
     contexts[menu]+='"g921": {name: "Banish Hot"'+(data[".data",zone,".Hot"]==0?"":", disabled: true")+'},';
     contexts[menu]+='"g922": {name: "Collect Freddies"'+(data[".data",zone,"+"+nc+".Freddies"]<10?"":", disabled: true")+'},';
     contexts[menu]+='"g923": {name: "All Stats"}}},';
     contexts[menu]+='"guardList": {name: "Guardroom", items:{';
     contexts[menu]+='"g931": {name: "Collect Stinking Agaricus"'+(data[".data",zone,"+"+nc+".Stinking Agaricus"]>0?", disabled: true":"")+'},';
     contexts[menu]+='"g932": {name: "Gain Spore-Wreathed"}}},';
     break;
   }
   if(keyOp)contexts[menu]+='"sep2": "---------", "toggle": {name: "Use Dreadsylvania Key", callback: function() {this.data(\''+nc.noSpaces()+'Disabled\', !this.data(\''+nc.noSpaces()+'Disabled\')); return false;}}';
  }
 }
}

void parseDread(string dread){
 string sub;
 int t;
 string w;
 string pn;
 matcher m;
 matcher nc;
 foreach zone in $strings[Woods, Village, Castle]{
  data[".data","Dread"+zone,".dist"]=0;
  data[".data","Dread"+zone,".hasdata"]=-1;
 }
 foreach zone in $strings[Woods, Village, Castle]{
  m=create_matcher(theMatcher["Dread"+zone,".dist"],dread);
  if(m.find())data[".data","Dread"+zone,".dist"]=min(1000,m.group(1).to_int());
 }
 m=create_matcher("<center>",dread);
 if(m.find()){
  data[".data","Dread",".hasdata"]=1;
  m=create_matcher("<b>(\\d+)</b> kisses earned",dread);
  if(m.find())data[".data","Dread","kisses"]=m.group(1).to_int();
  foreach zone in $strings[Inn, Woods, Village, Castle] foreach pointName,mString in theMatcher["Dread"+zone]{
   sub="";
   switch(zone){
    case "Inn":sub=dread;break;
    case "Woods":
     m=create_matcher("<b>The Woods</b><blockquote(.+?)/blockquote>",dread);
     if(m.find())sub=m.group(1);
     break;
    case "Village":
     m=create_matcher("<b>The Village</b><blockquote(.+?)/blockquote>",dread);
     if(m.find())sub=m.group(1);
     break;
    case "Castle":
     m=create_matcher("<b>The Castle</b><blockquote(.+?)/blockquote>",dread);
     if(m.find())sub=m.group(1);
     break;
   }
   if(sub=="")continue;
   if(zone!="Inn")data[".data","Dread",".hasdata"]+=1;
   m=create_matcher(">[^<]+"+mString+"[^<]+<",sub);
   while(m.find()){
    w=getName(m.group());
    t=getTurns(m.group());
    if(pointName.char_at(0)=="."){
     switch(pointName){
      case ".carriage":
       data[w,"Dread",pointName]+=m.group(1).to_int();
       data[".data","Dread",pointName]+=m.group(1).to_int();
       break;
      case ".temp":
       data[".data","DreadVillage",".cold"]=-1;
       data[".data","DreadVillage",".kisses"]+=1;
       data[w,"DreadVillage","+Square"]=201;
       data[w,"DreadVillage",".total"]+=1;
       data[w,".dread",".total"]+=1;
       data[".dtotal","DreadVillage","+Square"]+=1;
       data[".dtotal","DreadVillage",".total"]+=1;
       data[".dtotal",".dread",".total"]+=1;
       break;
     }
     continue;
    }
    data[".data","Dread"+zone,".hasdata"]=1;
    switch(pointName.char_at(0)){
     case "&":
       if(m.group(1)==" by"){
        pn=".Defeat.";
        data[w,"Dread"+zone,"Defeats"]+=t;
        data[".dtotal","Dread"+zone,"Defeats"]+=t;
        data[w,"Dread"+zone,".Defeat.All."+m.group(3).capitalize()]+=t;
        data[".dtotal","Dread"+zone,".Defeat.All."+m.group(3).capitalize()]+=t;
       }else{
        pn=".Kill.";
        data[w,"Dread"+zone,"&nbsp;"+m.group(3).capitalize()]+=t;
        data[w,"Dread"+zone,".Kills"]+=t;
        data[".dtotal","Dread"+zone,"&nbsp;"+m.group(3).capitalize()]+=t;
        data[".dtotal","Dread"+zone,".Kills"]+=t;
       }
       pn+=m.group(2).capitalize()+"."+m.group(3).capitalize();
      break;
     case "!":
       if(m.group(1)==" by"){
        pn="!bossloss";
        data[".data","Dread"+zone,pointName]=1;
        data[".dtotal","Dread"+zone,"Defeats"]+=0;
       }else{
        pn="!Boss";
        data[".data","Dread"+zone,pointName]=1;
        data[".data","Dread"+zone,".dist"]=1001;
        data[w,"Dread"+zone,".Kills"]+=t;
        data[".dtotal","Dread"+zone,".Kills"]+=t;
       }
      break;
     case "+":
       nc=create_matcher("(\\+[\\w\\s]+)\\.(-?\\d+)",pointName);
       if(!nc.find())abort("No.");
       pn=nc.group(1);
       t=0;
       if(dreadNonComStr(pn,nc.group(2).to_int())=="Trap Door Item"){       
        data[".data",".hung",w]=1;
        data[w,"DreadCastle",".hung"]=1;
       }else if(dreadNonComStr(pn,nc.group(2).to_int())=="Pulled Lever"){
        data[".data",".hanger",w]=1;
        data[w,"DreadCastle",".hanger"]=1;
       }
       if(dreadNonComStr(pn,nc.group(2).to_int())=="Fixed The Machine"){
        data[".data",".machine",w]=1;
        data[w,"DreadCastle",".machine"]=1;
       }else if(nc.group(2).to_int()%10==0){
        data[".data",".unlock."+pn.substring(1),w]=1;
        data[w,"Dread"+zone,".unlock"]+=1;
       }else{
        data[w,"Dread"+zone,pn]=nc.group(2).to_int();
        data[w,"Dread"+zone,".total"]+=1;
        data[w,".dread",".total"]+=1;
        data[".dtotal","Dread"+zone,pn]+=1;
        data[".dtotal","Dread"+zone,".total"]+=1;
        data[".dtotal",".dread",".total"]+=1;
        data[".data","Dread"+zone,pn+"."+dreadNonComStr(pn,nc.group(2).to_int())]+=1;
        switch(dreadNonComStr(pn,nc.group(2).to_int())){
         case "-Hot":data[".data","Dread"+zone,".hot"]=-1;data[".data","Dread"+zone,".kisses"]+=1;break;
         case "-Spooky":data[".data","Dread"+zone,".spooky"]=-1;data[".data","Dread"+zone,".kisses"]+=1;break;
         case "-Stench":data[".data","Dread"+zone,".stench"]=-1;data[".data","Dread"+zone,".kisses"]+=1;break;
         case "-Cold":data[".data","Dread"+zone,".cold"]=-1;data[".data","Dread"+zone,".kisses"]+=1;break;
         case "-Sleaze":data[".data","Dread"+zone,".sleaze"]=-1;data[".data","Dread"+zone,".kisses"]+=1;break;
         case "-Bugbears":data[".data","DreadWoods",".tilt"]-=1;break;
         case "-Werewolves":data[".data","DreadWoods",".tilt"]+=1;break;
         case "-Ghosts":data[".data","DreadVillage",".tilt"]-=1;break;
         case "-Zombies":data[".data","DreadVillage",".tilt"]+=1;break;
         case "-Skeletons":data[".data","DreadCastle",".tilt"]-=1;break;
         case "-Vampires":data[".data","DreadCastle",".tilt"]+=1;break;
        }
       }
      break;
     default:
      pn=pointName;
    }
    data[w,"Dread"+zone,pn]+=t;
    data[w,"Dread"+zone,".total"]+=t;
    data[w,".dread",".total"]+=t;
    data[".dtotal","Dread"+zone,pn]+=t;
    data[".dtotal","Dread"+zone,".total"]+=t;
    data[".dtotal",".dread",".total"]+=t;
   }
  }
 }else{
  data[".data","Dread",".hasdata"]=-1;
 }
 if(runType==-1){
  sub=visit_url("clan_dreadsylvania.php");
  foreach area,mString in theMatcher["DreadPencil"]{
   m=create_matcher(mString,sub);
   if(!m.find())continue;
   m=create_matcher("[^.]+\\.(.*)",area);
   if(!m.find())continue;
   data[".data",".pencil",m.group(1)]=1;
  }
  formatDreadOptions();
 }
}

string getData(){
 string ret="";
 string hobo="NONE";
 string st="NONE";
 string hh="NONE";
 string dread="NONE";
 matcher m;
 if(runType==0){
  if(page.contains_text("<b>Hobopolis run,"))runType=1;
  else if(page.contains_text("<b>Slime Tube run,"))runType=2;
  else if(page.contains_text(": run,"))runType=3;
  else if(page.contains_text("<b>Dreadsylvania run,"))runType=4;
  else runType=-1;
 }
 switch(runType){
  case 1:
   m=create_matcher("<b>Hobopolis run,(.+?)</table>",page);
   if(m.find())hobo=m.group(1);
   ret=hobo;
   data[".data","TS",".image"]=-2;
   data[".data","BB",".image"]=-2;
   data[".data","EE",".image"]=-2;
   data[".data","Heap",".image"]=-2;
   data[".data","AHBG",".image"]=-2;
   data[".data","PLD",".image"]=-2;
   break;
  case 2:
   m=create_matcher("<b>Slime Tube run,(.+?)</table>",page);
   if(m.find())st=m.group(1);
   ret=st;
   data[".data","Slime",".image"]=-2;
   break;
  case 3:
   m=create_matcher("run,(.+?)</table>",page);
   if(m.find())hh=m.group(1);
   ret=hh;
   break;
  case 4:
   m=create_matcher("run,(.+?)</table>",page);
   if(m.find())dread=m.group(1);
   ret=dread;
   break;
  default:
   m=create_matcher("<div id='Hobopolis'>(.+?)</div>",page);
   if(m.find())hobo=m.group(1);
   m=create_matcher("<div id='SlimeTube'>(.+?)</div>",page);
   if(m.find())st=m.group(1);
   m=create_matcher("<div id='HauntedHouse'>(.+?)</div>",page);
   if(m.find())hh=m.group(1);
   m=create_matcher("<div id='Dreadsylvania'>(.+?)</div>",page);
   if(m.find())dread=m.group(1);
   break;
 }
 parseHB(hobo);
 parseST(st);
 parseHH(hh);
 parseDread(dread);
 if(activeComment)map_to_file(data,"raidlog/rawdata.txt");
 return ret;
}

void pageHeader(){
 /*
  Tables: use tableD, [element]T
  Header: use rowD, [element]I, font-size:13px;
  Odd rows: use rowD, [element]O
  Even rows: use rowD
  Totals: use rowD, [element]I
  
  T-comes from table
  O-comes from shaded
  I-comes from header/totals
 */
 writeln("<html><head><style type=\"text/css\">");
 writeln(".directory td,.directory th{font-size:11px;border:0px;border-collapse:separate;padding:0px 10px;}");
 writeln(".submit{font-size:11px;border:0px;border-collapse:separate;padding:0px 0px;background:transparent;text-decoration:underline;cursor:pointer;}");
 writeln(".opts td{text-decoration:underline}");
 writeln(".tableD{font-size:11px;border:1px solid;border-spacing:0px;border-collapse:separate;background-color:#FFFFFF;width:100%;}");
 writeln(".imgtable td{width:75px !important;}");
 writeln(".rowD th,.rowD td{font-size:11px;text-align:center;padding:0px 3px;}");
 writeln("table:not(.tots).sortable tbody tr:nth-child(odd):not(:hover) td, table.tots.sortable tbody tr:nth-child(even):not(:hover) td{background-color:#FFFFFF}");
 writeln("table.sortable tbody tr:hover *{background-color:#000080 !important;color:#FFFFFF !important;}");
 writeln("tr.HL *{background-color:#94c5e9 !important;}");
 writeln("select, select option{font-size:11px;}");
 writeln(".rowL th,.rowL td{font-size:9px;text-align:left;padding:0px 3px;}");
 writeln(".bossKiller{font-weight:bold;color:black !important;}");
 writeln(".clear{font-weight:bold;color:darkgreen !important;}");
 writeln(".smalltxt{font-size:10px;color:black;background-color:white;font-weight:normal;padding:1px;height:auto;}");
 writeln(".smallbtn{font-size:9px;font-style:normal;color:black;border-color:gray;background-color:lightgray;font-weight:bold;height:16px;}");
 writeln(".eMsg{font-size:14px; font-weight:bold; border:3px solid red;}");

/* writeln(".DreadCastleT, .DreadCastleT tr td center div table{border-color:#CFB53B;}");
 writeln(".DreadCastleT tr:nth-child(1) td:only-child, .DreadCastleT tr td center div table tr:last-child td{font-weight:bold;color:white;background-color:#303030;}");
 writeln(".DreadCastleT tr td center div:nth-child(1) table tr>*{background-color:#B0B0B0;}");
*/
 writeln(".contextBox {border:2px solid blue;background-color:white;}");
 writeln(".SkinsC{color:black;}");
 writeln(".TST{border-color:black;}");
 writeln(".TSI{font-weight:bold;color:white;background-color:#17037D;}");
 writeln(".TSO{background-color:#E3E2EA;}");

 writeln(".SewerT, .PartsT, .DreadInnT{border-color:brown;}");
 writeln(".SewerI, .PartsI, .DreadInnI{font-weight:bold;color:white;background-color:#98790C;}");
 writeln(".SewerO, .PartsO, .DreadInnO{background-color:#DED3AB;}");

 writeln(".BootsC{color:#D93636;}");
 writeln(".BBT{border-color:red;}");
 writeln(".BBI, .HotI{font-weight:bold;color:white;background-color:#D93636;}");
 writeln(".BBO, .HotO{background-color:#FDC5C5;}");

 writeln(".EyesC{color:#3B7FEF;}");
 writeln(".EET{border-color:blue;}");
 writeln(".EEI, .ColdI{font-weight:bold;color:white;background-color:#3B7FEF;}");
 writeln(".EEO, .ColdO{background-color:#B8D3FE;}");

 writeln(".GutsC{color:#438C5B;}");
 writeln(".HeapT{border-color:green;}");
 writeln(".HeapI, .StenchI{font-weight:bold;color:white;background-color:#438C5B;}");
 writeln(".HeapO, .StenchO{background-color:#A8D8B8;}");

 writeln(".SkullsC{color:#919191;}");
 writeln(".AHBGT{border-color:gray;}");
 writeln(".AHBGI, .SpookyI{font-weight:bold;color:white;background-color:#919191;}");
 writeln(".AHBGO, .SpookyO{background-color:#DEDBDB;}");

 writeln(".CrotchesC{color:#B12DA6;}");
 writeln(".PLDT{border-color:purple;}");
 writeln(".PLDI, .SleazeI{font-weight:bold;color:white;background-color:#B12DA6;}");
 writeln(".PLDO, .SleazeO{background-color:#FAC1F5;}");

 writeln(".SlimeT{border-color:green;}");
 writeln(".SlimeI{font-weight:bold;color:white;background-color:#146803;}");
 writeln(".SlimeO{background-color:#C0D4BF;}");

 writeln(".HauntedT{border-color:#FFA500;}");
 writeln(".HauntedI{font-weight:bold;color:white;background-color:#101010;}");
 writeln(".HauntedO{background-color:#FFA500;}");
 
 
 writeln(".DreadCastleC{color:#303030;}");
 writeln(".DreadCastleT{border-color:#CFB53B;}");
 writeln(".DreadCastleI{font-weight:bold;color:white;background-color:#303030;}");
 writeln(".DreadCastleO{background-color:#B0B0B0;}");
 writeln(".DreadCastleE{background-color:#C8C8C8;}");
 
 writeln(".DreadVillageC{color:#98790C;}");
 writeln(".DreadVillageT{border-color:brown;}");
 writeln(".DreadVillageI{font-weight:bold;color:white;background-color:#98790C;}");
 writeln(".DreadVillageO{background-color:#D7CAA6;}");
 writeln(".DreadVillageE{background-color:#FFF1C5;}");
 
 writeln(".DreadWoodsC{color:#254117;}");
 writeln(".DreadWoodsT{border-color:#green;}");
 writeln(".DreadWoodsI{font-weight:bold;color:white;background-color:#254117;}");
 writeln(".DreadWoodsO{background-color:#93B38B;}");
 writeln(".DreadWoodsE{background-color:#A8C8A0;}");
 writeln(".context-menu-item:not(.icon-key) {padding:2px 2px 2px 12px !important;}");
 writeln(".context-menu-item.icon-key { padding:2px 2px 2px 24px !important; background-image:url(http://images.kingdomofloathing.com/itemimages/dv_key.gif); background-size:18px 18px; background-repeat:no-repeat;}");
 writeln("</style>");
 writeln("<script language=\"Javascript\" type=\"text/javascript\" src=\"sorttable.js\"></script>");
 writeln("<script language=\"Javascript\" type=\"text/javascript\">function tog(e){ var i=document.getElementById(e);if(i.style.display=='none'){i.style.display='inline';}else{i.style.display='none';}}");
 writeln("function tog2(e){var i1=document.getElementById(e); var i2=document.getElementById(e+'2'); if(i1.style.display=='inline'){i1.style.display='none'; i2.style.display='inline';}else if(i2.style.display=='inline'){i2.style.display='none';}else{i1.style.display='inline';}}");
 writeln("function hideAll(){['Hobo','Slime','Haunted','Dread'].forEach(function(name){var i1=document.getElementById(name+'Tab'); if(i1==null)return; i1.style.textDecoration='underline'; i1.style.cursor='pointer'; i1=document.getElementById(name+'Div'); if(i1==null)return; i1.style.display='none';});}");
 writeln("function show(e){hideAll(); var sub=new XMLHttpRequest; sub.open('GET','KoLmafia/sideCommand?cmd=set+raidlogStartPage='+e+'&pwd="+my_hash()+"'); sub.send(); var i1=document.getElementById(e+'Div'); i1.style.display='inline'; i1=document.getElementById(e+'Tab'); i1.style.textDecoration='none'; i1.style.cursor='default';}");
 writeln("function openContext(e,d){var div=document.getElementById('context'+d); div.style.display='inline'; div.style.position='absolute'; div.style.top=e.clientY+2; div.style.left=e.clientX; div.style.overflowy='auto';}");
 writeln("function updateTots(area){var td=document.getElementById(area+\"Ps\"); var allIs=document.getElementById(area+\"Table\").getElementsByTagName(\"input\"); var t=0; for(i=0;i<allIs.length;i++){ t=t+Number(allIs[i].value); } td.innerHTML=t;}</script>");
 int i=page.index_of("</head>");
 matcher m=create_matcher("(http://images\\.kingdomofloathing\\.com|images)/scripts/jquery.+?js",page.substring(12,i));
 if(m.find())write(m.replace_first("jquery-1.10.2.min.js"));
 writeln("<link rel=\"stylesheet\" type=\"text/css\" href=\"jquery.contextMenu.css\">");
 writeln("<script type='text/javascript' src=\"jquery.contextMenu.js\"></script>");
 writeln("<script type=\"text/javascript\">$(window).load(function(){");
 if(runType<0)foreach menu in contexts writeln("$(function(){$.contextMenu({selector: '."+menu+"', callback: function(key,options){ window.location='"+__FILE__+"?cmd='+key;}, items: {"+contexts[menu]+"}});});");
 writeln("});</script></head><body>");
 write("<center>");
 write("<table class=\"directory\"><tr><td><a href=\""+__FILE__+"\">");
 if(runType>0)write("Current Runs</a></td>");
 else write("Refresh</a></td>");
 if((!(data[".data"] contains get_property("raidlogStartPage")))||(data[".data",get_property("raidlogStartPage"),".hasdata"]==-1)){
  foreach z in $strings[Hobo, Slime, Haunted, Dread] if((data[".data"]contains z)&&(data[".data",z,".hasdata"]!=-1))set_property("raidlogStartPage",z);
 }
 if(((runType<0)||(runType==1))&&(data[".data","Hobo",".hasdata"]!=-1))write("<td style=\"text-decoration:"+(get_property("raidlogStartPage")=="Hobo"?"none; cursor:default;":"underline; cursor:pointer;")+"\" id=\"HoboTab\" onclick=\"show('Hobo');\">Hobopolis</td>");
 if(((runType<0)||(runType==2))&&(data[".data","Slime",".hasdata"]!=-1))write("<td style=\"text-decoration:"+(get_property("raidlogStartPage")=="Slime"?"none; cursor:default;":"underline; cursor:pointer;")+"\" id=\"SlimeTab\" onclick=\"show('Slime');\">Slimetube</td>");
 if(((runType<0)||(runType==3))&&(data[".data","Haunted",".hasdata"]!=-1))write("<td style=\"text-decoration:"+(get_property("raidlogStartPage")=="Haunted"?"none; cursor:default;":"underline; cursor:pointer;")+"\" id=\"HauntedTab\" onclick=\"show('Haunted');\">Haunted House</td>");
 if(((runType<0)||(runType==4))&&(data[".data","Dread",".hasdata"]!=-1))write("<td style=\"text-decoration:"+(get_property("raidlogStartPage")=="Dread"?"none; cursor:default;":"underline; cursor:pointer;")+"\" id=\"DreadTab\" onclick=\"show('Dread');\">Dreadsylvania</td>");
 write("<td><a href=\"clan_basement.php\">Basement</a></td>");
 writeln("</tr></table>");
 if(abortMessage!=""){
  writeln("<div class=\"eMsg\">"+abortMessage+"</div>");
 }
}

string withColor(string e){
 switch(e){
  case "Hot":return "<span class=\"BootsC\">Hot</span>";
  case "Cold":return "<span class=\"EyesC\">Cold</span>";
  case "Spooky":return "<span class=\"SkullsC\">Spooky</span>";
  case "Sleaze":return "<span class=\"CrotchesC\">Sleaze</span>";
  case "Stench":return "<span class=\"GutsC\">Stench</span>";
 }
 return e;
}

void formatHBT(){
 write("<table><tr class=\"rowD\">");
 foreach area in $strings[Parts,BB,EE,Heap,AHBG,PLD,TS] write("<td class=\""+area+"I\">"+area.bossName()+"</td>");
 write("</tr><tr>");
 foreach area in $strings[Parts,BB,EE,Heap,AHBG,PLD,TS] write("<td class=\""+area+"O\"><a href=\"clan_hobopolis.php?place="+theMatcher[area,".place"]+"\"><img src=\""+theMatcher[area,".image"]+"\" width=\"80px\" height=\"80px\" /></a></td>");
 write("</tr><tr class=\"rowD\">");
 write("<td><div style=\"border:1px solid brown;\">");
 foreach thing in $strings[Skins,Boots,Eyes,Guts,Skulls,Crotches]{
  write("<span class=\""+thing+"C\">"+data[".data","Richard",thing]+" "+thing+"</span><br>");
 }
 write("</div></td>");
 foreach area in $strings[BB,EE,Heap,AHBG,PLD]{
  write("<td width=\"75px\" class=\""+area+"I\">");
  switch(data[".data",area,".image"]){
   case -2:
    write("<font size=\"0.9em\">Data not available.</font>");
    break;
   case -1:
    write("<font size=\"0.9em\">Area not open yet or unavailable to you.</font>");
    break;
   case 10:
    write("<font size=\"0.9em\">Boss is ready for a fight!</font>");
    break;
   case 11:
    write("<font size=\"0.9em\">Defeated by ");
    foreach user in data{
     if(user.char_at(0)==".")continue;
     if(data[user,area,"!"+area.bossName()]<1)continue;
     write(user+"</font>");
     break;
    }
    break;
   default:
    write(data[".data",area,".image"]+"0% Complete");
  }
  write("</td>");
 }
 write("<td width=\"75px\" class=\"TSI\">");
 switch(data[".data","TS",".image"]){
  case -2:
   write("<font size=\"0.9em\">Data not available.</font>");
   break;
  case -1:
   write("<font size=\"0.9em\">Area not open yet or unavailable to you.</font>");
   break;
  case 25:
   write("<font size=\"0.9em\">Boss is ready for a fight!</font>");
   break;
  case 26:
   write("<font size=\"0.9em\">Defeated by ");
   foreach user in data{
    if(user.char_at(0)==".")continue;
    if(data[user,"TS","!Hodgman"]<1)continue;
    write(user+"</font>");
    break;
   }
   break;
  default:
   write(to_string(data[".data","TS",".image"]*4)+"% Complete");
   write("<br>Tent is "+(data[".data","TS",".open"]==1?"Open":"Closed")+"</td>");
 }
 write("</tr><tr><td colspan=\"7\"><form action=\"clan_hobopolis.php\" method=\"post\">");
 write("<input type=\"hidden\" name=\"preaction\" value=\"simulacrum\"><input type=\"hidden\" name=\"place\" value=\"3\">");
 write("<input class=\"smalltxt\" type=\"text\" name=\"qty\" value=\"0\" size=\"4\"><input class=\"smallbtn\" type=\"submit\" value=\"Make Scarehobos\">");
 writeln("</form></td></tr></table><br>");
}

void formatHB(string show){
 write("<div id=\"HoboDiv\" style=\"display:"+show+"\">");
 write("<table class=\"directory\"><tr>");
 write("<td><a href=\"clan_hobopolis.php?place=1\">Sewers</a></td>");
 write("<td><a href=\"clan_hobopolis.php?place=2\">Town Square</a></td>");
 write("<td><a href=\""+__FILE__+"?conman=1\">Consumable Distro</a></td>");
 write("<td><a href=\""+__FILE__+"?lootman=1\">Loot Manager</a></td></tr></table>");
 formatHBT();
 write("<table class=\"tableD TST\"><tr class=\"rowD\"><td class=\"TSI\" onclick=\"tog('totTable')\">Totals</td></tr><tr><td><center><div id=\"totTable\" style=\"display:inline;\"><table class=\"tots sortable tableD TST\">");
 write("<tr class=\"rowD\"><th class=\"TSI\">Players</th>");
 foreach s in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{//Full area table Headers
  if(data[".data",s,".hasdata"]==-1)continue;
  write("<th class=\""+s+"I\">"+expand(s)+"</th>");
 }
 clear(odata);
 write("<th class=\"TSI\">Totals</th>");
 boolean customTotals=false;
 foreach att in $strings[marketMatter,richardMatter,defeatsMatter,sewersMatter] if(options["hobo."+att]=="n")customTotals=true;
 if(customTotals)write("<th class=\"TSI\">Adjusted Total</th>");
 write("</tr>");
 int tmp;
 foreach user in data{//Sort data
  if(user.char_at(0)==".")continue;
  if(data[user,".hobo",".total"]<1)continue;
  odata[count(odata)]=data[user];
  odata[count(odata)-1,".name",user]=1;
  tmp=data[user,".hobo",".total"];
  if(options["hobo.marketMatter"]=="n")tmp-=data[user,"TS","Market<br>Trips"];
  if(options["hobo.richardMatter"]=="n"){
   tmp-=data[user,"TS","Made<br>Bandages"];
   tmp-=data[user,"TS","Made<br>Grenades"];
   tmp-=data[user,"TS","Made<br>Shakes"];
  }
  if(options["hobo.defeatsMatter"]=="n"){
   foreach area in $strings[TS,BB,EE,Heap,AHBG,PLD]{
    tmp-=data[user,area,"Defeats"];
    tmp-=data[user,area,"!bossloss"];
   }
   if(options["hobo.sewersMatter"]=="on")tmp-=data[user,"Sewer","Defeats"];
  }
  if(options["hobo.sewersMatter"]=="n")tmp-=data[user,"Sewer",".total"];  
  odata[count(odata)-1,".hobo",".rtotal"]=tmp;
 }
 sort odata by (value["Sewer",clearID]==0?5000:0)-value[".hobo",".rtotal"];
 foreach index in odata{//Full Area Table Data
  write("<tr class=\"rowD"+(odata[index].pullField(".name")==my_name()?" HL":"")+"\"><td class=\"TSO\" style=\"text-align:left\">"+linkify(odata[index].pullField(".name"))+"</td>");
  foreach s in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{
   if(data[".data",s,".hasdata"]==-1)continue;
   write("<td class=\""+s+"O\">"+odata[index,s,".total"]+"</td>");
  }
  write("<td class=\"TSO\">"+odata[index,".hobo",".total"]+"</td>");
  if(customTotals)write("<td class=\"TSO\">"+odata[index,".hobo",".rtotal"]+"</td>");
  write("</tr>");
 }
 write("<tfoot><tr class=\"rowD\"><td class=\"TSI\">Total</td>");
 foreach s in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{//Full Area Table Total
  if(data[".data",s,".hasdata"]==-1)continue;
  write("<td class=\""+s+"I\">"+data[".total",s,".total"]+"</td>");
 }
 write("<td class=\"TSI\">"+data[".total",".hobo",".total"]);
 if(customTotals){
  tmp=data[".total",".hobo",".total"];
  if(options["hobo.marketMatter"]=="n")tmp-=data[".total","TS","Market<br>Trips"];
  if(options["hobo.richardMatter"]=="n"){
   tmp-=data[".total","TS","Made<br>Bandages"];
   tmp-=data[".total","TS","Made<br>Grenades"];
   tmp-=data[".total","TS","Made<br>Shakes"];
  }
  if(options["hobo.defeatsMatter"]=="n"){
   foreach area in $strings[TS,BB,EE,Heap,AHBG,PLD]{
    tmp-=data[".total",area,"Defeats"];
    tmp-=data[".total",area,"!bossloss"];
   }
   if(options["hobo.sewersMatter"]=="on")tmp-=data[".total","Sewer","Defeats"];
  }
  if(options["hobo.sewersMatter"]=="n")tmp-=data[".total","Sewer",".total"];  
  write("<td class=\"TSI\">"+tmp+"</td>");
 }
 writeln("</tr></tfoot></table></div></center></td></tr></table><br>");
 foreach area in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{//Per-area tables
  if(data[".data",area,".hasdata"]<0)continue;
  write("<table class=\"tableD "+area+"T\"><tr class=\"rowD\"><td class=\""+area+"I\" onclick=\"tog('"+area+"Table')\">"+expand(area)+"</td></tr><tr><td><center><div id=\""+area+"Table\" style=\"display:inline;\"><table class=\"sortable tableD "+area+"T\"><tr>");
  write("<th class=\""+area+"O\">Players</th>");
  foreach s in theMatcher[area]{//per-area headers
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".total",area,s]<1)&&((s!="Defeats")||data[".total",area,"!bossloss"]<1))continue;
   write("<th class=\""+area+"O\">"+s+"</th>");
  }
  write("<th class=\""+area+"O\">Totals</th></tr>");
  clear(odata);
  foreach user in data{//Get and sort data
   if(user.char_at(0)==".")continue;
   if(data[user,area,".total"]<1)continue;
   odata[count(odata)]=data[user];
   odata[count(odata)-1,".name",user]=1;
  }
  sort odata by (area=="Sewer"?(1-value["Sewer",clearID])*5000-value[area,".total"]:-value[area,".total"]);
  foreach index in odata{//per-area table data
   write("<tr class=\"rowD"+(odata[index].pullField(".name")==my_name()?" HL":"")+"\"><td class=\""+area+"O\" style=\"text-align:left\">");
   write(linkify(odata[index].pullField(".name"))+((area=="Sewer")&&(odata[index,"Sewer",clearID]>0)?" <span class=\"clear\">(Clear"+(odata[index,"Sewer",clearID]>1?" x"+odata[index,"Sewer",clearID]:"")+")</span>":"")+(odata[index,area,"!"+area.bossName()]>0?" <span class=\"bossKiller\">(Boss)</span>":"")+"</td>");
   foreach s in theMatcher[area]{//per-area table data
    if(".!".contains_text(s.char_at(0)))continue;
    if((data[".total",area,s]<1)&&((s!="Defeats")||data[".total",area,"!bossloss"]<1))continue;
    write("<td class=\""+area+"O\">"+odata[index,area,s]+((s=="Defeats")&&(odata[index,area,"!bossloss"]>0)?" ("+odata[index,area,"!bossloss"]+")":"")+"</td>");
   }
   write("<td class=\""+area+"O\">"+odata[index,area,".total"]+"</td></tr>");
  }
  write("<tfoot><tr class=\"rowD\"><td class=\""+area+"I\">Total</td>");
  foreach s in theMatcher[area]{//per-area totals row
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".total",area,s]<1)&&((s!="Defeats")||data[".total",area,"!bossloss"]<1))continue;
   write("<td class=\""+area+"I\">"+data[".total",area,s]+((s=="Defeats")&&(data[".total",area,"!bossloss"]>0)?" ("+data[".total",area,"!bossloss"]+")":"")+"</td>");
  }
  writeln("<td class=\""+area+"I\">"+data[".total",area,".total"]+"</td></tr></tfoot></table></div></center></td></tr></table><br>");
 }
 write("<form name=\"opts\" action=\""+__FILE__+"?submitOpts=1&dungeon=hobo\" method=\"POST\"><table class=\"directory opts\"><tr><th>Count To Total:</th>");
 write("<td>Market <input type=\"checkbox\" name=\"hobo.marketMatter\""+(options["hobo.marketMatter"]=="on"?" checked=\"checked\"":"")+"></td>");
 write("<td>Richard <input type=\"checkbox\" name=\"hobo.richardMatter\""+(options["hobo.richardMatter"]=="on"?" checked=\"checked\"":"")+"></td>");
 write("<td>Defeats <input type=\"checkbox\" name=\"hobo.defeatsMatter\""+(options["hobo.defeatsMatter"]=="on"?" checked=\"checked\"":"")+"></td>");
 write("<td>Sewer <input type=\"checkbox\" name=\"hobo.sewersMatter\""+(options["hobo.sewersMatter"]=="on"?" checked=\"checked\"":"")+"></td>");
 writeln("<th colspan=2>[<input class=\"submit\" type=\"submit\" value=\"Save\">]</th></tr></table></form></div>");
}

void formatST(string show){
 write("<div id=\"SlimeDiv\" style=\"display:"+show+"\"><table class=\"directory\"><tr><td><a href=\"/clan_slimetube.php\">Slimetube</a></td></tr></table><table><tr><td width=\"80px\" valign=\"top\"><table>");//all of ST
 write("<tr class=\"rowD\"><td class=\"SlimeI\">Mother Slime</td></tr><tr><td class=\"SlimeO\"><a href=\"/clan_slimetube.php\"><img src=\""+theMatcher["Slime",".image"]+"\" width=\"80px\" height=\"80px\" /></a></td></tr><tr class=\"rowD\"><td class=\"SlimeI\">");
 switch(data[".data","Slime",".image"]){//Write the boss table text
  case -2:
   write("<font size=\"0.9em\">Data not available.</font>");
   break;
  case -1:
   write("<font size=\"0.9em\">Area not available to you.</font>");
   break;
  case 10:write("<font size=\"0.9em\">Boss is ready for a fight!</font>");break;
  case 11:write("<font size=\"0.9em\">Defeated by ");
   foreach user in data{
    if(user.char_at(0)==".") continue;
    if(data[user,"Slime","!Mother Slime"]<1) continue;
    write(user+"</font>");
    break;
   }
   break;
  default:write(data[".data","Slime",".image"]+"0% Complete");  
 }
 write("</td></tr></table></td><td width=\"100%\"><table class=\"tableD SlimeT\"><tr class=\"rowD\"><td class=\"SlimeI\" onclick='tog(SlimeTable);'>Slime Tube</td></tr><tr><td><center><div id=\"SlimeTable\" style=\"display:inline;\">");
 write("<table class=\"sortable tableD SlimeT\"><tr class=\"rowD\"><th class=\"SlimeO\">Players</th>");
 foreach s in theMatcher["Slime"]{//Slime table header row
  if(".!".contains_text(s.char_at(0)))continue;
  if((data[".stotal","Slime",s]<1)&&((s!="Defeats")||data[".stotal","Slime","!bossloss"]<1))continue;
  write("<th class=\"SlimeO\">"+s+"</th>");
 }
 write("<th class=\"SlimeO\">Totals</th>");
 boolean customTotals=false;
 foreach att in $strings[defeats] if(options["slime."+att]=="n")customTotals=true;
 if(customTotals)write("<th class=\"SlimeO\">Adjusted Total</th></tr>");
 else write("</tr>");
 clear(odata);
 int tmp;
 foreach user in data{//data collection and sorting
  if(user.char_at(0)==".")continue;
  if(data[user,"Slime",".total"]<1)continue;
  tmp=data[user,"Slime",".total"];
  odata[count(odata)]=data[user];
  odata[count(odata)-1,".name",user]=1;
  if(options["slime.defeats"]=="n"){
   tmp-=data[user,"Slime","Defeats"];
   tmp-=data[user,"Slime","!bossloss"];
  }
  odata[count(odata)-1,"Slime",".rtotal"]=tmp;
 }
 sort odata by -value["Slime",".rtotal"];
 foreach index in odata{//slime table rows
  write("<tr class=\"rowD"+(odata[index].pullField(".name")==my_name()?" HL":"")+"\"><td class=\"SlimeO\" style=\"text-align:left\">"+linkify(odata[index].pullField(".name"))+"</td>");
  foreach s in theMatcher["Slime"]{
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".stotal","Slime",s]<1)&&((s!="Defeats")||data[".stotal","Slime","!bossloss"]<1))continue;
   write("<td class=\"SlimeO\">"+odata[index,"Slime",s]+((s=="Defeats")&&(odata[index,"Slime","!bossloss"]>0)?" ("+odata[index,"Slime","!bossloss"]+")":"")+"</td>");
  }
  write("<td class=\"SlimeO\">"+odata[index,"Slime",".total"]+"</td>");
  if(customTotals)write("<td class=\"SlimeO\">"+odata[index,"Slime",".rtotal"]+"</td></tr>");
  else write("</tr>");
 }
 write("<tfoot><tr class=\"rowD\"><td class=\"SlimeI\">Total</td>");
 foreach s in theMatcher["Slime"]{
  if(".!".contains_text(s.char_at(0)))continue;
  if((data[".stotal","Slime",s]<1)&&((s!="Defeats")||data[".stotal","Slime","!bossloss"]<1))continue;
  write("<td class=\"SlimeI\">"+data[".stotal","Slime",s]+((s=="Defeats")&&(data[".stotal","Slime","!bossloss"]>0)?" ("+data[".stotal","Slime","!bossloss"]+")":"")+"</td>");
 }
 write("<td class=\"SlimeI\">"+data[".stotal","Slime",".total"]+"</td>");
 if(customTotals){
  tmp=data[".stotal","Slime",".total"];
  if(options["slime.defeats"]=="n"){
   tmp-=data[".stotal","Slime","Defeats"];
   tmp-=data[".stotal","Slime","!bossloss"];
  }
  write("<td class=\"SlimeI\">"+tmp+"</td>");
 }
 writeln("</tr></tfoot></table></div></center></td></tr></table></td></tr></table>");
 write("<form name=\"opts\" action=\""+__FILE__+"?submitOpts=1&dungeon=slime\" method=\"POST\"><table class=\"directory opts\"><tr><th>Count To Total:</th>");
 write("<td>Defeats <input type=\"checkbox\" name=\"slime.defeats\""+(options["slime.defeats"]=="on"?" checked=\"checked\"":"")+"></td>");
 writeln("<th colspan=2>[<input class=\"submit\" type=\"submit\" value=\"Save\">]</th></tr></table></form></div>");
}

void formatHH(string show){
 write("<div id=\"HauntedDiv\" style=\"display:"+show+"\"><table><tr><td width=\"80px\" valign=\"top\"><table>");//all of HH
 write("<tr class=\"rowD\"><td class=\"HauntedI\">Necbromancer</td></tr><tr><td width=\"90px\" class=\"HauntedO\"><a href=\"/clan_hh.php\"><img src=\""+theMatcher["Haunted",".image"]+"\" width=\"90px\" height=\"90px\" /></a></td></tr><tr class=\"rowD\"><td class=\"HauntedI\">");
/* switch(data[".htotal","Haunted","!Necbromancer"]){//Write the boss table text
  case 1:write("<font size=\"0.9em\">Defeated by ");
   foreach user in data{
    if(user.char_at(0)==".") continue;
    if(data[user,"Haunted","!Necbromancer"]<1) continue;
    write(user+"</font>");
    break;
   }
   break;
  default:
   write("<font size=\"0.9em\"></font>");
   break;
 }*/
 int tmp=0;
 boolean customTotals=false;
 foreach att in $strings[defeats] if(options["haunted."+att]=="n")customTotals=true;
 clear(odata);
 foreach user in data{//data collection and sorting
  if(user.char_at(0)==".")continue;
  if(data[user,"Haunted",".total"]<1)continue;
  odata[count(odata)]=data[user];
  odata[count(odata)-1,".name",user]=1;
  tmp=data[user,"Haunted","!Mirrors"];
  tmp+=data[user,"Haunted","!Bullet"];
  tmp+=data[user,"Haunted","!Chainsaw"];
  tmp+=data[user,"Haunted","!Trap"];
  tmp+=data[user,"Haunted","!Guides"];
  tmp+=data[user,"Haunted","!Costume"];
  odata[count(odata)-1,"Haunted","Collected<br>Item"]=tmp;
  tmp=data[user,"Haunted","!NoiseUp"];
  tmp+=data[user,"Haunted","!NoiseDown"];
  tmp+=data[user,"Haunted","!DarkUp"];
  tmp+=data[user,"Haunted","!DarkDown"];
  tmp+=data[user,"Haunted","!FogUp"];
  tmp+=data[user,"Haunted","!FogDown"];
  odata[count(odata)-1,"Haunted","Mod ML"]=tmp;
  tmp=data[user,"Haunted",".total"];
  if(options["haunted.defeats"]=="n"){
   tmp-=data[user,"Haunted","Defeats"];
   tmp-=data[user,"Haunted","!bossloss"];
  }
  odata[count(odata)-1,"Haunted",".rtotal"]=tmp;
 }
 sort odata by -value["Haunted",".rtotal"];
 odata[count(odata),".name",".total"]=1;
 foreach s in theMatcher["Haunted"] if(s.char_at(0)=="&")odata[count(odata)-1,"Haunted",s]=0;
 for n from 0 upto count(odata)-2 foreach c,v in odata[n,"Haunted"] odata[count(odata)-1,"Haunted",c]+=v;
 if(activeComment)map_to_file(odata,"raidlog/HHodata.txt");
 write("</td></tr></table></td><td width=\"100%\"><table class=\"tableD HauntedT\"><tr class=\"rowD\"><td class=\"HauntedI\" onclick='tog(HauntedTable);'>Haunted Sorority House</td></tr><tr><td><center><div id=\"HauntedTable\" style=\"display:inline;\">");
 write("<table class=\"sortable tableD HauntedT\"><tr class=\"rowD\"><th class=\"HauntedO\">Players</th>");
 foreach s in odata[count(odata)-1,"Haunted"]{//haunted table header row
  if(".!".contains_text(s.char_at(0)))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&"))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
  write("<th class=\"HauntedO\">"+s+"</th>");
 }
 write("<th class=\"HauntedO\">Totals</th>");
 if(customTotals)write("<th class=\"HauntedO\">Adjusted Total</th></tr>");
 else write("</tr>");
 foreach index in odata{//haunted table rows
  if(index==count(odata)-1)break;
  write("<tr class=\"rowD"+(odata[index].pullField(".name")==my_name()?" HL":"")+"\"><td class=\"HauntedO\" style=\"text-align:left\">"+linkify(odata[index].pullField(".name"))+(odata[index,"Haunted","!Necbromancer"]>0?" ("+odata[index,"Haunted","!Necbromancer"]+")":"")+(odata[index,"Haunted","!Guides"]>0?" (G)":"")+"</td>");
  foreach s in odata[count(odata)-1,"Haunted"]{
   if(".!".contains_text(s.char_at(0)))continue;
   if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
   write("<td class=\"HauntedO\">"+odata[index,"Haunted",s]+((s=="Defeats")&&(odata[index,"Haunted","!bossloss"]>0)?" ("+odata[index,"Haunted","!bossloss"]+")":""));
   if("&".contains_text(s.char_at(0)))write(" ["+odata[index,"Haunted","!"+s.substring(6)]+"]");
   write("</td>");
  }
  write("<td class=\"HauntedO\">"+odata[index,"Haunted",".total"]+"</td>");
  if(customTotals)write("<td class=\"HauntedO\">"+odata[index,"Haunted",".rtotal"]+"</td>");
  write("</tr>");
 }
 write("<tfoot><tr class=\"rowD\"><td class=\"HauntedI\">Total</td>");
 foreach s in odata[count(odata)-1,"Haunted"]{//Haunted table totals
  if(".!".contains_text(s.char_at(0)))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
  write("<td class=\"HauntedI\">"+odata[count(odata)-1,"Haunted",s]+((s=="Defeats")&&(odata[count(odata)-1,"Haunted","!bossloss"]>0)?" ("+odata[count(odata)-1,"Haunted","!bossloss"]+")":""));
  if("&".contains_text(s.char_at(0)))write(" ["+odata[count(odata)-1,"Haunted","!"+s.substring(6)]+"]");
  write("</td>");
 }
 write("<td class=\"HauntedI\">"+odata[count(odata)-1,"Haunted",".total"]+"</td>");
 if(customTotals)write("<td class=\"HauntedI\">"+odata[count(odata)-1,"Haunted",".rtotal"]+"</td>");
 write("</tr><tr class=\"rowD\"><td class=\"HauntedI\">Current<br>Remaining:</td>");
 boolean nomod=true;
 foreach s in odata[count(odata)-1,"Haunted"]{//haunted table current estimates
  if(".!".contains_text(s.char_at(0)))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
  if((s.char_at(0)!="&")&&(s!="Mod ML")){
   write("<td class=\"HauntedI\"></td>");
   continue;
  }
  if(s=="Mod ML"){
   nomod=false;
   tmp=odata[count(odata)-1,"Haunted","!DarkUp"]-odata[count(odata)-1,"Haunted","!DarkDown"];
   tmp+=odata[count(odata)-1,"Haunted","!FogUp"]-odata[count(odata)-1,"Haunted","!FogDown"];
   tmp+=odata[count(odata)-1,"Haunted","!NoiseUp"]-odata[count(odata)-1,"Haunted","!NoiseDown"];
   write("<td class=\"HauntedI\" style=\"font-weight:bold;\">ML: "+tmp+"</td>");
   continue;
  }
  tmp=300-odata[count(odata)-1,"Haunted",s];
  tmp-=floor(odata[count(odata)-1,"Haunted","!"+s.substring(6)]*((s=="&nbsp;Wolves")||(s=="&nbsp;Vamps")?17.5:12.5));
  write("<td class=\"HauntedI\">"+tmp+"</td>");
 }
 if(nomod)write("<td class=\"HauntedI\">ML: 0</td>");
 else write("<td class=\"HauntedI\"></td>");
 if(customTotals)write("<td class=\"HauntedI\"></td>");
 writeln("</tr></tfoot></table></div></center></td></tr></table></td></tr></table>");
 write("<form name=\"opts\" action=\""+__FILE__+"?submitOpts=1&dungeon=haunted\" method=\"POST\"><table class=\"directory opts\"><tr><th>Count To Total:</th>");
 write("<td>Defeats <input type=\"checkbox\" name=\"haunted.defeats\""+(options["haunted.defeats"]=="on"?" checked=\"checked\"":"")+"></td>");
 writeln("<th colspan=2>[<input class=\"submit\" type=\"submit\" value=\"Save\">]</th></tr></table></form></div>");
}

void formatDreadTable(){
 write("<table class=\"imgtable\"><tr class=\"rowD\">");
 foreach area in $strings[Inn, Woods, Village, Castle] write("<td class=\"Dread"+area+"I\">"+area+"</td>");
 write("</tr><tr>");
 foreach area in $strings[Inn, Woods, Village, Castle] write("<td class=\"Dread"+area+"O\" style=\"text-align:center\"><a href=\""+area.linkTo()+"\"><img src=\""+area.bossName().imageOf()+"\" width=\"80px\" height=\"80px\" /></a></td>");
 write("</tr><tr class=\"rowD\">");
 foreach area in $strings[Inn, Woods, Village, Castle] write("<td class=\"Dread"+area+"I\">"+area.bossName()+"</td>");
 write("</tr><tr class=\"rowD\">");
 write("<td><div style=\"border:1px solid brown;\">");
 write("<span class=\"CrotchesC\">"+data[".data","Dread","kisses"]+" Kisses</span><br>");
 if(data[".data","Dread",".carriage"]>999)write("<span class=\"DreadVillageC\">Village Open</span><br>");
 if(data[".data","Dread",".carriage"]>1999)write("<span class=\"DreadCastleC\">Castle Open</span><br>");
 else write("<span>"+data[".data","Dread",".carriage"]+" sheets</span");
 write("</div></td>");
 foreach area in $strings[Woods, Village, Castle]{
  write("<td width=\"75px\" class=\"Dread"+area+"I\">");
  switch(data[".data","Dread"+area,".dist"]){
   case 1000:
    write("<font size=\"0.9em\">Boss is ready for a fight!</font>");
    break;
   case 1001:
    write("<font size=\"0.9em\">Defeated by ");
    foreach user in data{
     if(user.char_at(0)==".")continue;
     if(data[user,"Dread"+area,"!Boss"]<1)continue;
     write(user+"</font>");
     break;
    }
    break;
   case -2:
    write("<font size=\"0.9em\">Data not available.</font>");
    break;
   case -1:
    if((area=="Village")&&(data[".data","Dread",".carriage"]<1000)){
     write("<font size=\"0.9em\">Area not open yet.</font>");
     break;
    }
    if((area=="Castle")&&(data[".data","Dread",".carriage"]<2000)){
     write("<font size=\"0.9em\">Area not open yet.</font>");
     break;
    }
   default:
    write(to_string(1000-data[".data","Dread"+area,".dist"])+" Kill"+(data[".data","Dread"+area,".dist"]!=999?"s":"")+" Remain"+(data[".data","Dread"+area,".dist"]!=999?"":"s"));
  }
  write("</td>");
 }
 writeln("</tr></table><br>");
}

void formatDreadNCTable(){
 write("<table class=\"tableD TST\"><tr class=\"RowD\">");
 foreach area in $strings[DreadWoods, DreadVillage, DreadCastle] write("<th class=\""+area+"I\" style=\"max-width:40%; min-width:28%\">"+area.expand()+"</th>");
 string[int] list;
 boolean odd=false;
 string zone;
 matcher m=create_matcher("([^(]+)\\((.+)\\)","");
 foreach i in layout{
  switch(i%3){
   case 0:zone="DreadCastle";break;
   case 1:zone="DreadWoods";write("<tr class=\"RowD\">");break;
   case 2:zone="DreadVillage";break;
  }
  list=split_string(layout[i],",");
  write("<td class=\""+list[0].noSpaces()+"td "+(odd?zone+"E":zone+"O")+"\">");
  write("<span style=\"font-weight:bold;\">"+(data[".data",".pencil",list[0]]==1?"<a href=\""+list[0].linkTo()+"\">"+list[0]+"</a>":list[0])+"</span><br>");
  if((i==6)&&(data[".data"] contains ".machine"))write("<span style=\"font-weight:bold\">"+data[".data"].pullField(".machine")+"</span> has fixed The Machine.<br>");
  if((i==2)&&(data[".data"] contains ".hung"))write("<span style=\"font-weight:bold\">"+data[".data"].pullField(".hung")+"</span> was hung by <span style=\"font-weight:bold\">"+data[".data"].pullField(".hanger")+"</span>.<br>");
  foreach i2 in list if(i2>0){
   m.reset(list[i2]);
   if(!m.find())continue;
   switch(m.group(1)){
    case"Unlock":
     write("<span style=\"font-style:italic\">"+m.group(2));
     if(data[".data"] contains (".unlock."+list[0]))write(" unlocked by <span style=\"font-weight:bold\">"+data[".data"].pullField(".unlock."+list[0]));
     else write(" <span style=\"font-weight:bold\">locked");
     write("</span>.</span><br>");
     break;
    case"Music Box":
     write("Music Box parts ");
     if(data[".data",zone,"+Cabin.-Spooky"]>0)write("unavailable.<br>");
     else write("available.<br>");
     break;
    case"Blood Kiwi":
     write("Blood Kiwi");
     if(data[".data",zone,"+Tree.Blood Kiwi"]==data[".data",zone,"+Tree.Stomped"])write(" "+data[".data",zone,"+Tree.Blood Kiwi"]+"/1<br>");
     else write(" unavailable.<br>");
     break;
    default:
     write(m.group(1)+": "+data[".data",zone,"+"+list[0]+"."+m.group(1)]+"/"+m.group(2)+"<br>");
     break;
   }
  }
  write("</td>");
  if(i%3==0){
   odd=!odd;
   write("</tr>");
  }
 }
 write("</tr><tr style=\"height:5px;\"><td class=\"DreadWoodsI\"></td><td class=\"DreadVillageI\"></td><td class=\"DreadCastleI\"></td>");
 write("</tr></table>");
}

void formatDread(string show){
 write("<div id=\"DreadDiv\" style=\"display:"+show+"\"><table class=\"directory\"><tr>");
 write("<td><a href=\"clan_dreadsylvania.php\">Dreadsylvania</a></td><td><a href=\"shop.php?whichshop=dv\">Inn</a></td></tr></table>");
 formatDreadTable();
 if(data[".data","Dread",".hasdata"]<2){
  write("<table class=\"tableD TST\"><tr class=\"RowD\"><td class=\"allDread TSI\" onclick=\"tog('DreadTotsTable')\">Totals</td></tr>");
  write("<tr><td><center><div id=\"DreadTotsTable\" style=\"display:inline\">");
  formatDreadNCTable();
  writeln("</div></center></td></tr></table><br>");
  return;
 }
 write("<table class=\"tableD TST\"><tr class=\"RowD\"><td class=\"allDread TSI\" onclick=\"tog2('DreadTotsTable')\">Totals</td></tr>");
 write("<tr><td><center><div id=\"DreadTotsTable");
 if(options["dread.limitTable"]=="on")write("2\" style=\"display:none;\"");
 else if(options["dread.limitTable"]=="none")write("\" style=\"display:none;");
 else write("\" style=\"display:inline;");
 write("\"><table class=\"tots sortable tableD TST\"><tr><th class=\"TSI\">Players</th>");
 foreach area in $strings[DreadWoods, DreadVillage, DreadCastle] if(data[".dtotal",area,".total"]>0)write("<th class=\""+area+"I\">"+area.expand()+"</th>");
 write("<th class=\"TSI\">Totals</th>");
 boolean customTotals=false;
 foreach att in $strings[defeats] if(options["dread."+att]=="n")customTotals=true;
 if(customTotals)write("<th class=\"TSI\">Adjusted Total</th>");
 write("</tr>");
 clear(odata);
 int tmp;
 foreach user in data{//Get and sort data
  if(user.char_at(0)==".")continue;
  if(data[user,".dread",".total"]<1)continue;
  odata[count(odata)]=data[user];
  odata[count(odata)-1,".name",user]=1;
  tmp=data[user,".dread",".total"];
  if(options["dread.defeats"]=="n") foreach area in $strings[DreadWoods, DreadVillage, DreadCastle]{
   tmp-=data[user,area,"Defeats"];
   tmp-=data[user,area,"!bossloss"];
  }
  odata[count(odata)-1,".dread",".rtotal"]=tmp;
 }
 sort odata by -value[".dread",".rtotal"];
 foreach index in odata{
  write("<tr class=\"rowD"+(odata[index].pullField(".name")==my_name()?" HL":"")+"\"><td class=\"TSO\" style=\"text-align:left\">");
  write(linkify(odata[index].pullField(".name"))+"</td>");
  foreach area in $strings[DreadWoods, DreadVillage, DreadCastle] if(data[".dtotal",area,".total"]>0)write("<td class=\""+area+"O\">"+odata[index,area,".total"]+"</td>");
  write("<td class=\"TSO\">"+odata[index,".dread",".total"]+"</td>");
  if(customTotals)write("<td class=\"TSO\">"+odata[index,".dread",".rtotal"]+"</td></tr>");
  else write("</tr>");
 }
 write("<tfoot><tr class=\"rowD\"><td class=\"TSI\">Total</td>");
 foreach area in $strings[DreadWoods, DreadVillage, DreadCastle] if(data[".dtotal",area,".total"]>0)write("<td class=\""+area+"I\">"+data[".dtotal",area,".total"]+"</td>");
 write("<td class=\"TSI\">"+data[".dtotal",".dread",".total"]+"</td>");
 if(customTotals){
  tmp=data[".dtotal",".dread",".total"];
  if(options["dread.defeats"]=="n") foreach area in $strings[DreadWoods, DreadVillage, DreadCastle]{
   tmp-=data[".dtotal",area,"Defeats"];
   tmp-=data[".dtotal",area,"!bossloss"];
  }
  write("<td class=\"TSI\">"+tmp+"</td>");
 }
 write("</tr></foot></table></div>");
 if(options["dread.limitTable"]!="on")write("<div id=\"DreadTotsTable2\" style=\"display:none;\">");
 else if(options["dread.limitTable"]=="none")write("<div id=\"DreadTotsTable2\" style=\"display:none;\">");
 else write("<div id=\"DreadTotsTable\" style=\"display:inline;\">");
 formatDreadNCTable();
 writeln("</div></center></td></tr></table><br>");
 foreach area in $strings[DreadWoods, DreadVillage, DreadCastle]{//Per-area tables
  if(data[".data",area,".hasdata"]<0)continue;
  write("<table class=\"tableD "+area+"T\"><tr class=\"RowD\"><td colspan=\"3\" id=\""+area+"tr\" class=\""+area+"I\" onclick=\"tog2('"+area+"Table')\">"+expand(area)+"</td></tr>");
  write("<tr class=\"RowL\"><td>Kiss Level: "+to_string(1+data[".data",area,".kisses"])+"</td><td>Elements:");
  foreach e in $strings[Hot, Cold, Spooky, Sleaze, Stench] if((data[".data",area,".kisses"]>4)||(data[".data",area,"."+e]!=-1)) write(" <span class=\""+area+"_"+e+(data[".data",area,".kisses"]<5?"\" title=\""+area.spoiler(e):"")+"\">"+e.withColor()+"</span>");
  write("</td><td>Monster Shift: ");
  if(data[".data",area,".tilt"]<0)switch(area){
   case "DreadWoods":write("Werewolves");break;
   case "DreadVillage":write("Zombies");break;
   case "DreadCastle":write("Vampires");break;
  }else if(data[".data",area,".tilt"]>0)switch(area){
   case "DreadWoods":write("Bugbears");break;
   case "DreadVillage":write("Ghosts");break;
   case "DreadCastle":write("Skeletons");break;
  }else write("None");
  if(abs(data[".data",area,".tilt"])>1)write(" (x"+abs(data[".data",area,".tilt"])+")");
  write("</td></tr><tr><td colspan=\"3\"><center><div id=\""+area+"Table\" style=\"display:inline;\"><table class=\"sortable tableD "+area+"T\"><tr>");
//  write("</td></tr><tr><td colspan=\"3\"><center><div id=\""+area+"Table\" style=\"display:inline;\"><table class=\"sortable tableD\"><tr>");
  write("<th class=\""+area+"O\">Players</th>");
  foreach s in data[".dtotal",area]{//per-area headers
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".dtotal",area,s]<1)&&((s!="Defeats")||data[".dtotal",area,"!bossloss"]<1))continue;
   write("<th class=\""+(s.char_at(0)=="+"?s.substring(1).noSpaces()+"td ":"")+area+"O\">"+(s.char_at(0)=="+"?s.substring(1):s)+"</th>");
  }
  write("<th class=\""+area+"O\">Totals</th></tr>");
  clear(odata);
  foreach user in data{//Get and sort data
   if(user.char_at(0)==".")continue;
   if(data[user,area,".total"]+data[user,area,".unlock"]+data[user,area,".machine"]<1)continue;
   odata[count(odata)]=data[user];
   odata[count(odata)-1,".name",user]=1;
  }
  sort odata by -value[area,".total"];
  foreach index in odata{//per-area table data
   write("<tr class=\"rowD"+(odata[index].pullField(".name")==my_name()?" HL":"")+"\"><td class=\""+area+"O\" style=\"text-align:left\">");
   write(linkify(odata[index].pullField(".name")));
   for i from 1 upto odata[index,area,".unlock"] write(" <span style=\"color:gold\">&#9733;</span>");
   write((odata[index,area,"!Boss"]>0?" <span class=\"bossKiller\">(Boss)</span>":"")+"</td>");
   foreach s in data[".dtotal",area]{//per-area table data
    if(".!".contains_text(s.char_at(0)))continue;
    if((data[".dtotal",area,s]<1)&&((s!="Defeats")||data[".dtotal",area,"!bossloss"]<1))continue;
    write("<td class=\""+area+"O\">"+(s.char_at(0)=="+"?dreadNonComStr(s,odata[index,area,s]):odata[index,area,s]+((s=="Defeats")&&(odata[index,area,"!bossloss"]>0)?" ("+odata[index,area,"!bossloss"]+")":""))+"</td>");
   }
   write("<td class=\""+area+"O\">"+odata[index,area,".total"]+"</td></tr>");
  }
  write("<tfoot><tr class=\"rowD\"><td class=\""+area+"I\">Total</td>");
  foreach s in data[".dtotal",area]{//per-area totals row
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".dtotal",area,s]<1)&&((s!="Defeats")||data[".dtotal",area,"!bossloss"]<1))continue;
   write("<td class=\""+area+"I\">"+data[".dtotal",area,s]+((s=="Defeats")&&(data[".dtotal",area,"!bossloss"]>0)?" ("+data[".dtotal",area,"!bossloss"]+")":"")+"</td>");
  }
  write("<td class=\""+area+"I\">"+data[".dtotal",area,".total"]+"</td></tr></tfoot></table></div>");
  write("<div id=\""+area+"Table2\" style=\"display:none;\"><table class=\"tableD "+area+"T\"><tr><th class=\""+area+"O\">Players</th>");
  string[int] specs;
  foreach pn in data[".dtotal",area] if(pn.char_at(0)=="&")specs[count(specs)]=pn.substring(6);
  boolean[string,string] exists;
  foreach i,s in specs{
   foreach e in $strings[Hot, Cold, Spooky, Sleaze, Stench] if((data[".dtotal",area,".Kill."+e+"."+s]+data[".dtotal",area,".Defeat."+e+"."+s])>0)exists[s,e]=true;
   exists[s,"All"]=true;
   write("<th class=\""+area+"O\" colspan=\""+count(exists[s])+"\">"+s+"</th>");
  }
  write("<th class=\""+area+"O\">Totals</th></tr><tr><th></th>");
  foreach i,s in specs foreach e in $strings[Hot, Cold, Spooky, Sleaze, Stench, All] if(exists[s,e])write("<th>"+e.withColor()+"</th>");
  write("<th></th></tr>");
  clear(odata);
  foreach user in data{//Get and sort data
   if(user.char_at(0)==".")continue;
   if((data[user,area,".Kills"]+data[user,area,"Defeats"])<1)continue;
   odata[count(odata)]=data[user];
   odata[count(odata)-1,".name",user]=1;
  }
  sort odata by -(value[area,".Kills"]+value[area,"Defeats"]);
  boolean odd=false;
  foreach index in odata{
   odd=!odd;
   write("<tr class=\"rowD\"><td class=\""+(odd?area+"O":"rowEven")+"\" style=\"text-align:left\">");
   write(linkify(odata[index].pullField(".name"))+(odata[index,area,"!Boss"]>0?" <span class=\"bossKiller\">(Boss)</span>":"")+"</td>");
   foreach i,s in specs foreach e in $strings[Hot, Cold, Spooky, Sleaze, Stench, All] if(exists[s,e])
    write("<td class=\""+(odd?(e=="All"?area:e)+"O":"rowEven")+"\">"+odata[index,area,(e=="All"?"&nbsp;"+s:".Kill."+e+"."+s)]+(odata[index,area,".Defeat."+e+"."+s]>0?":"+odata[index,area,".Defeat."+e+"."+s]:"")+"</td>");
   write("<td class=\""+(odd?area+"O":"rowEven")+"\">"+odata[index,area,".Kills"]+(odata[index,area,"Defeats"]>0?":"+odata[index,area,"Defeats"]:"")+"</td></tr>");
  }
  write("<tr class=\"rowD\"><td class=\""+area+"I\">Total</td>");
  foreach i,s in specs foreach e in $strings[Hot, Cold, Spooky, Sleaze, Stench, All] if(exists[s,e])
   write("<td class=\""+(e=="All"?area:e)+"I\">"+data[".dtotal",area,(e=="All"?"&nbsp;"+s:".Kill."+e+"."+s)]+(data[".dtotal",area,".Defeat."+e+"."+s]>0?":"+data[".dtotal",area,".Defeat."+e+"."+s]:"")+"</td>");
  writeln("<td class=\""+area+"I\">"+data[".dtotal",area,".Kills"]+(data[".dtotal",area,"Defeats"]>0?":"+data[".dtotal",area,"Defeats"]:"")+"</td></tr></table></div></center></td></tr></table><br>");
 }
 write("<form name=\"opts\" action=\""+__FILE__+"?submitOpts=1&dungeon=dread\" method=\"POST\"><table class=\"directory opts\"><tr>");
 write("<td>Totals Table:</td><th><select name=\"dread.limitTable\"><option value=\"n\""+(options["dread.limitTable"]=="n"?" selected":"")+">Turns</option>");
 write("<option value=\"on\""+(options["dread.limitTable"]=="on"?" selected":"")+">Noncombats</option>"+"<option value=\"none\""+(options["dread.limitTable"]=="none"?" selected":"")+">Collapsed</option></select></th>");
 write("<th>Count To Total:</th><td>Defeats <input type=\"checkbox\" name=\"dread.defeats\""+(options["dread.defeats"]=="on"?" checked=\"checked\"":"")+"></td>");
 writeln("<th colspan=2>[<input class=\"submit\" type=\"submit\" value=\"Save\">]</th></tr></table></form></div>");
}

void loadOptions(){
 string[string]temp;
 options["hobo.marketMatter"]="n";
 options["hobo.richardMatter"]="n";
 options["hobo.defeatsMatter"]="n";
 options["hobo.sewersMatter"]="n";
 options["slime.defeats"]="n";
 options["haunted.defeats"]="n";
 options["dread.defeats"]="n";
 options["dread.limitTable"]="n";
 file_to_map("raidlog/options.txt",temp);
 foreach oN,oV in temp options[oN]=oV;
 matcher m=create_matcher("(\\w+)\\.(\\w+)","");
 if(FF contains "submitOpts")foreach oN in options{
  m.reset(oN);
  if(!m.find())continue;
  if(m.group(1)!=FF["dungeon"])continue;
  if(FF contains oN)options[oN]=FF[oN];
  else options[oN]="n";
 }
 map_to_file(options,"raidlog/options.txt");
}

void formatData(){
 string defPage=get_property("raidlogStartPage");
 if(data[".data","Hobo",".hasdata"]!=-1)formatHB((defPage=="Hobo"?"inline":"none"));
 if(data[".data","Slime",".hasdata"]!=-1)formatST((defPage=="Slime"?"inline":"none"));
 if(data[".data","Haunted",".hasdata"]!=-1)formatHH((defPage=="Haunted"?"inline":"none"));
 if(data[".data","Dread",".hasdata"]!=-1)formatDread((defPage=="Dread"?"inline":"none"));
 write("</center>");
}

void pageFooter(){
 int i=page.index_of("<body>");
 write(page.substring(i+6).replace_string('width=700','width="100%"'));
}

int kmail(string to, string message, int meat, int[item] stuff){
 if(meat>my_meat()){
  print("Not enough meat to send.");
  return 3;
 }
 string itemstring = "";
 int j=0;
 string[int] itemstrings;
 foreach i in stuff{
  if (is_tradeable(i)||is_giftable(i)){
   j=j+1;
   itemstring=itemstring+"&howmany"+j+"="+stuff[i]+"&whichitem"+j+"="+to_int(i);
   if (j>10){
    itemstrings[count(itemstrings)]=itemstring;
    itemstring='';
    j=0;
   }
  }
 }
 if(itemstring!="")itemstrings[count(itemstrings)]=itemstring;
 if(count(itemstrings)==0)itemstrings[0]="";
 foreach q in itemstrings{
  string url=visit_url("sendmessage.php?pwd="+my_hash()+"&action=send&towho="+to+"&message="+message+"&sendmeat="+meat+itemstrings[q]);
  if(contains_text(url,"That player cannot receive Meat or items")){
   print("Player may not receive meat/items.");
   return 2;
  }
  if(!contains_text(url,"Message sent.")){
   print("Unknown error. The message probably did not go through.");
   return -1;
  }
 }
 return 1;
}

void lootManager(){
 pageHeader();
 write("WIP");
 write("</center></body></html>");
}

void conMan1(){
 int[string] points;
 foreach user in data{
  if(user.char_at(0)==".")continue;
  foreach area in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{
   foreach thing,val in data[user,area]{
    if(thing.char_at(0)==".")continue;
    if(options["hobo.defeatsMatter"]=="n"){
     if(thing=="!bossloss")continue;
     if(thing=="Defeats")continue;
    }
    if(area=="Sewer"){
     if((options["hobo.sewersMatter"]=="n")&&(thing!="Opened<br>Grates")&&(thing!="Turned<br>Valves"))continue;
    }
    if((options["hobo.marketMatter"]=="n")&&(thing=="Market<br>Trips"))continue;
    if((options["hobo.richardMatter"]=="n")&&(thing.substring(0,5)=="Made<"))continue;
    points[user]+=val;
    points[".t"]+=val;
   }
  }
 }
 
 write("<form name=\"conman\" action=\""+__FILE__+"?conman=2\" method=\"POST\">");
 write("<table><tr><td valign=\"top\"><table id=\"dropTable\"><tr><th colspan=2>Drops</th></tr>");
 //3,3,3,2,2,1...
 foreach i in $strings[Sliders,Pickle Juice,Banquets,Blankets,Hodge Stew,Forks,Mugs,Snuff]{
  write("<tr><td>"+i+"</td><td><input name=\"i."+i+"\" type=\"text\" value=\"0\" onchange=\"updateTots('drop');\"></td></tr>");
 }
 write("<tr><td>Total Items:</td><td><span id=\"dropPs\">0</span></td></tr>");
 write("</table></td><td valign=\"top\"><table id=\"userTable\"><tr><th colspan=2>Player Data</th></tr>");
 foreach user,p in points{
  if(user==".t")continue;
  write("<tr><td>"+user+"</td><td><input name=\"u."+user+"\" type=\"text\" value=\""+p+"\" onchange=\"updateTots('user');\"></td></tr>");
 }
 write("<tr><td>Total Points</td><td><span id=\"userPs\">"+points[".t"]+"</span></td></tr>");
 write("</table></td></tr><tr><td colspan=2><input type=\"Submit\" value=\"Submit\"></td></tr></table></form>");
}

void conMan2(){
 int[string] drops;
 int[string] usersT;
 foreach d,s in FF switch(d.char_at(0)){
  case "i":drops[d.substring(2)]+=s.to_int();break;
  case "u":if(s.to_int()!=0)usersT[d.substring(2)]+=s.to_int();break;
 }
 int dv=0;
 int pv=0;
 foreach s,v in usersT pv+=v;
 foreach s in $strings[Sliders,Pickle Juice] dv+=3*drops[s];
 foreach s in $strings[Banquets,Blankets,Hodge Stew] dv+=2*drops[s];
 foreach s in $strings[Forks,Mugs,Snuff] dv+=drops[s];
 record{
  string name;
  int points;
  int[string] drops;
 }[int] users;
 foreach n,p in usersT{
  users[count(users)+1].name=n;
  users[count(users)].points=floor(p*1.0*dv/pv);
 }
 sort users by -usersT[value.name];
 int extraPoints=dv;
 foreach u,v in users extraPoints-=v.points;
 int passback=count(users);
 users[count(users)+1].name=".Extra";
 int token=1;
 for i from 1 to passback if(users[i].points==0){token=i;break;}
 while(extraPoints>0){
  users[token].points+=1;
  extraPoints-=1;
  token+=1;
  if(token>passback)token=1;
 }
 token=passback;
 boolean fail;
 int bush;
 int VoD=3;
 foreach thing in $strings[Sliders,Pickle Juice,Banquets,Blankets,Hodge Stew,Forks,Mugs,Snuff]{
  if(thing=="Banquets")VoD=2;
  if(thing=="Forks")VoD=1;
  fail=false;
  if(drops[thing]==0)continue;
  while(drops[thing]>0){
   bush=token;
   token+=1;
   if(token>passback)token=1;
   while(bush!=token){
    if(users[token].points>=VoD){
     users[token].drops[thing]+=1;
     users[token].points-=VoD;
     drops[thing]-=1;
     break;
    }
    token+=1;
    if(token>passback)token=1;
   }
   if(bush==token){
    if(users[token].points>=VoD){
     users[token].drops[thing]+=1;
     users[token].points-=VoD;
     drops[thing]-=1;    
    }else{
     users[passback+1].drops[thing]+=drops[thing];
     drops[thing]=0;
    }
   }
  }
 }
 write("<form name=\"finalize\" action=\""+__FILE__+"?conman=3\" method=\"POST\"><table class=\"tableD EET\"><tr><th colspan=3 class=\"EEI\">The Distro</th></tr>");
 boolean first;
 boolean alt=false;
 foreach i,v in users{
  alt=!alt;
  write("<tr"+(alt?" class=\"EEO\"":"")+"><td rowspan=\""+count(v.drops)+"\" valign=\"top\">"+v.name+"</td>");
  first=true;
  foreach thing,amt in v.drops {
   if(!first)write("<tr"+(alt?" class=\"EEO\"":"")+">");
   write("<td>"+thing+"</td><td><input type=\"text\" value=\""+amt.to_string()+"\" name=\"u."+v.name+"."+thing+"\"></td>");
   first=false;
   write("</tr>");
  }
  if(count(v.drops)==0)write("<td>War</td><td>What is it good for?</td></tr>");
 }
 write("<tr><td colspan=3><input type=\"Submit\" value=\"Submit\"></td></tr></table></form>");
}

void conMan3(){
 int[string,item] stuff;
 string[int] split;
 foreach name,amount in FF if(name.substring(0,2)=="u."){
  split=split_string(name,"\\.");
  switch(split[2]){
   case "Sliders":stuff[split[1],$item[extra-greasy slider]]=amount.to_int();
   case "Pickle Juice":stuff[split[1],$item[jar of fermented pickle juice]]=amount.to_int();
   case "Banquets":stuff[split[1],$item[frozen banquet]]=amount.to_int();
   case "Blankets":stuff[split[1],$item[Hodgman's blanket]]=amount.to_int();
   case "Hodge Stew":stuff[split[1],$item[tin cup of mulligan stew]]=amount.to_int();
   case "Forks":stuff[split[1],$item[Ol' Scratch's salad fork]]=amount.to_int();
   case "Mugs":stuff[split[1],$item[Frosty's frosty mug]]=amount.to_int();
   case "Snuff":stuff[split[1],$item[voodoo snuff]]=amount.to_int();
  }
 }
 int[item] held=stuff[".Extra"];
 remove stuff[".Extra"];
 boolean[string] check;
 foreach u,i,a in stuff if(a==0)remove stuff[u,i];
 foreach u in stuff if(kmail(u,"",0,stuff[u])==1){
  check[u]=true;
  remove stuff[u];
 }
 map_to_file(stuff,"raidlog\\undistro.txt");
 if(count(check)>0){
  write("Distro complete for the following members:<br>");
  foreach c in check write("&nbsp;"+c+"<br>");
 }
 if(count(stuff)>0){
  write("<br>Distro held for the following members:<br>");
  foreach c in stuff write("&nbsp;"+c+"<br>");
  write("Data saved to data\\raidlog\\undistro.txt");
 }
}

void consumablesManager(){
 pageHeader();
 switch(FF["conman"]){
  case "1":if(!activeComment)getData();
           else file_to_map("raidlog/rawdata.txt",data);
           conMan1();break;
  case "2":conMan2();break;
  case "3":conMan3();break;
 }
 write("</center></body></html>");
}

void noAccess(){
 writeln('<html><head><script language="Javascript" type="text/Javascript">');
 writeln('function redirect(){ }');
 writeln('</script><meta http-equiv="refresh" content="0; URL=./clan_basement.php?fromabove=1"></head><body onload="redirect();">No basement access. Sorry. <a href="clan_hall.php">Back to Clan Hall</a></body></html>');
}

boolean executeCommand(string cmd){
 matcher m;
 string p=visit_url("clan_raidlogs.php");
 boolean moveTo=false;
 if(cmd.char_at(0)=='r')moveTo=true;
 cmd=cmd.substring(1);
 if(cmd.to_int()>0){
  if("13 22 41 63 71 81".contains_text(cmd.substring(0,2))){
   switch(cmd.char_at(0)){
    case"1":m=create_matcher(theMatcher["DreadWoods","+Cabin.30"],p);break;
    case"2":m=create_matcher(theMatcher["DreadWoods","+Tree.20"],p);break;
    case"4":m=create_matcher(theMatcher["DreadVillage","+Square.10"],p);break;
    case"6":m=create_matcher(theMatcher["DreadVillage","+Estate.30"],p);break;
    case"7":m=create_matcher(theMatcher["DreadCastle","+Great Hall.10"],p);break;
    case"8":m=create_matcher(theMatcher["DreadCastle","+Tower.10"],p);break;
   }
   if(!m.find()){
    if(!retrieve_item(1,$item[dreadsylvanian skeleton key])){
     abortMessage="Failed to acquire Dreadsylvanian skeleton key.";
     return false;
    }
   }
  }
  visit_url("clan_dreadsylvania.php?action=forceloc&loc="+cmd.char_at(0));
  visit_url("adventure.php?snarfblat="+to_string((cmd.char_at(0).to_int()-1)/3+338));
  p=visit_url("choice.php?forceoption=0");
  m=create_matcher("whichchoice value=(\\d*)",p);
  if(!m.find())return false;
  p=visit_url("choice.php?pwd="+my_hash()+"&whichchoice="+m.group(1)+"&option="+cmd.char_at(1));
  m.reset(p);
  if(!m.find())return false;
  p=visit_url("choice.php?pwd="+my_hash()+"&whichchoice="+m.group(1)+"&option="+cmd.char_at(2));
  if(moveTo){
   write(p);
   return true;
  }
 }else{
 }
 return false;
}

void main(){
 if((FF contains "cmd")&&(executeCommand(FF["cmd"])))return;
 if(FF contains "viewlog")page=visit_url("clan_raidlogs.php?viewlog="+FF["viewlog"]);
 else if(FF contains "oldLogs")page=visit_url("clan_oldraidlogs.php?startrow="+FF["oldLogs"]);
 else page=visit_url("clan_raidlogs.php");
 if(page==""){
  noAccess();
  return;
 }
 loadOptions();
 matcher m=create_matcher("a href=\"clan_viewraidlog\\.php\\?viewlog=",page);
 page=m.replace_all("a target=mainpane href=\""+__FILE__+"?viewlog=");
 //replace all viewlog links in page
 m=create_matcher("src=clan_oldraidlogs\\.php",page);
 page=m.replace_all("src=\""+__FILE__+"?oldLogs=0\"");
 m=create_matcher("clan_oldraidlogs\\.php\\?startrow=(\\d+)",page);
 while(m.find()){
  page=m.replace_first("\"clan_raidlogs.php?oldLogs="+m.group(1)+"\"");
  m.reset(page);  
 }
 if(FF contains "oldLogs"){
  write(page);
  return;
 }
 if(FF contains "viewlog"){
  runType=0;
 }
 if(FF contains "lootman"){
  lootManager();
  return;
 }
 if(FF contains "conman"){
  consumablesManager();
  return;
 }
 getData();
 pageHeader();
 formatData();
 pageFooter();
}