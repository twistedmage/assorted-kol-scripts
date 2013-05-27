//Base script code by Alhifar (#1189456)
//Modifications for general strategy implementation by RoyalTonberry (#1161513)
//Note that this will tell mafia to trigger Mana Burning (near the very bottom of the script)

string hit()
{
    return visit_url( "crimbo09.php?subplace=11table&action=hit11&pwd" );
}

string stand()
{
    return visit_url( "crimbo09.php?subplace=11table&action=stand11&pwd" );
}

string double()
{
    return visit_url( "crimbo09.php?subplace=11table&action=double11&pwd" );
}

string start_game( int cost )
{
    if( cost < 1 || cost > 11 ) abort( "Invalid bet amount" );
    return visit_url( "crimbo09.php?subplace=11table&action=new11&howmany=" + cost.to_string() + "&pwd" );
}

int get_opponent( string page )
{
    matcher m = create_matcher( "http://images.kingdomofloathing.com/otherimages/cards//([1-5ak])[a-d]\\.gif" , page );
    m.find();
    string c =  m.group( 1 );
	if (c == "a")
		return 1;
	if (c == "k")
		return 5;
	return m.group(1).to_int();
}

// Generate an integer representing your hand. Each place represents the number of cards in your hand worth that face value, i.e. the hand A233 becomes 211
int get_my_hand(string page) {
	matcher m = create_matcher( "<td style=\"padding-left: .5em; font-size:3em; font-weight: bold;\" width=\"100\">(\\d+)</td>" , page );
    m.find();
	int hand = 0;
	boolean found = m.find();
	found = m.find();
	while (found) {
		string card = m.group(1);
        if(card == "a") {
			hand = hand + 1;
        } else if(card == "2") {
			hand = hand + 10;
		} else if(card == "3") {
			hand = hand + 100;
		} else if(card == "4") {
			hand = hand + 1000;
		} else {
			hand = hand +10000;
		}
		found = m.find();
	}
	return hand;
}

void main(int rounds) {
	int bet = 11;
    string page;
	int initial=item_amount($item[crimbuck]);
	int total=rounds;
    while( rounds > 0 ) {
        print("Round " + rounds + "(counting down) ... Betting " + bet, "blue");
        page = start_game( bet );
       
        while( !contains_text( page , "Play Again" ) ) {
	    int opp = get_opponent(page);
		int hand = get_my_hand(page);

            print("Hand: " + hand);
            
            if(((hand == 110 || hand == 200)&&(opp == 2 || opp == 3 || opp == 4))||(hand == 1010 && (opp == 2 || opp == 3))) {
                page = double();
                print("doubling down...");
            } else if( hand == 2 || hand == 11 || hand == 101 || hand == 20 || hand == 10010 || hand == 1100 || hand == 10100 || hand == 2000 || hand == 3 || hand == 12 || hand == 10002 || hand == 1011 || hand == 201 || hand == 30 || hand == 120 || hand == 4 || hand == 13 || hand == 103 || hand == 1003 || hand == 10003 || hand == 22 || hand == 112 || hand == 1012 || hand == 31 || ((hand == 11000 || hand == 300 || hand == 1102 || hand == 211 || hand == 130) && (opp == 1 || opp == 5)) || ((hand == 102 || hand == 21 || hand == 10101 || hand == 10012) && opp == 1) || ((hand == 10011 || hand == 202 || hand == 121 || hand == 40) && opp != 3) || ((hand == 1101 || hand == 1020 || hand == 210) && (opp != 2 && opp != 3)) || (hand == 2001 && opp == 5)) {
                page = hit();
                print("Hitting...");
            } else {
				page = stand();
                print("Standing...");
            }
        }
        if(contains_text( page, "You acquire")) {
           print("You Win!", "green");
        } else {
           print("You Lose!", "red");
        }
        rounds = rounds - 1;
		
		cli_execute("mood execute");
        //cli_execute("burn *");
    }
	int change=item_amount($item[crimbuck]) - initial;
	print("gained "+change+" crimbux in "+total+" adventures","blue");
    print("gambling complete");
}




