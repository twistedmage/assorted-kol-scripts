item [class] caveClassItems ;
caveClassItems[$class[Seal Clubber]] = $item[clown whip] ;
caveClassItems[$class[Turtle Tamer]] = $item[clownskin buckler] ;
caveClassItems[$class[Pastamancer]] = $item[boring spaghetti] ;
caveClassItems[$class[Sauceror]] = $item[tomato juice of powerful power] ;
caveClassItems[$class[Disco Bandit]] = $item[fuzzbump] ;

item[stat,int] caveMainstatItems ;
caveMainstatItems[$stat[Muscle]] [1] = $item[viking helmet]; 
caveMainstatItems[$stat[Muscle]] [2] = $item[insanely spicy bean burrito]; 
caveMainstatItems[$stat[Mysticality]] [1] = $item[stalk of asparagus]; 
caveMainstatItems[$stat[Mysticality]] [2] = $item[insanely spicy enchanted bean burrito]; 
caveMainstatItems[$stat[Moxie]] [1] = $item[dirty hobo gloves]; 
caveMainstatItems[$stat[Moxie]] [2] = $item[insanely spicy jumping bean burrito]; 

# stolen from Bale
#*****************
int max_at() { return (boolean_modifier("Four Songs").to_int() + 3); }

int current_at() {
	int total = 0;
	for song from 6003 to 6026
		if(song.to_skill().to_effect().have_effect() > 0)
			total = total + 1;
	return total;
}
#*****************

boolean openDoor ( int num, item itm ) {
	if ( !retrieve_item(1, itm) ) abort("You need 1 more "+itm+" to continue") ;
	string url = visit_url("cave.php?action=door"+num+"&pwd&action=dodoor"+num+"&whichitem="+itm.to_int());
	if ( contains_text(url, "action=door"+num) ) abort("Something happened while opening door n°"+num+", aborting.");
	return true ;
}

boolean nemesisCave() {
	int currentDoor;
	string url = visit_url("cave.php") ;
	matcher doorNum = create_matcher("action=door(\\d)", url);
	if ( doorNum.find() ) currentDoor = doorNum.group( 1 ).to_int() ;
	else return true ;

	foreach num,itm in caveMainstatItems[my_primestat()]
		if ( currentDoor == num )
			if ( openDoor(num, itm) ) currentDoor = currentDoor + 1 ;
	
	if ( currentDoor == 3 ) {
		if ( my_class() == $class[Accordion Thief] ) {
			if ( have_effect($effect[Polka of Plenty]) == 0 ) {
				if ( current_at() >=  max_at() )
					abort("Too many AT songs to get Polka of Plenty");
				if ( have_skill($skill[Polka of Plenty]) ) use_skill(1,$skill[Polka of Plenty]);
				else abort("You need to get buffed with Polka of Plenty to continue.");
			}
			url = visit_url("cave.php?action=door3&pwd");
			if ( contains_text(url, "action=door3") ) abort("Something happened while opening door n°3, aborting.");
			currentDoor = currentDoor + 1 ;
		}
		else if ( openDoor(3,caveClassItems[my_class()]) ) currentDoor = currentDoor + 1 ;
	}
	
	if ( currentDoor == 4 ) return true ;
	return false ;
}

void main() {
	if ( nemesisCave() ) print("Doors opened, you can gather the paper strips.","green");
}