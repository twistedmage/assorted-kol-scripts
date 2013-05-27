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

string get_opponent( string page )
{
    matcher m = create_matcher( "http://images.kingdomofloathing.com/otherimages/cards//([1-5ak])[a-d]\\.gif" , page );
    m.find();
    return m.group( 1 );
}

int get_num_cards( string page )
{
    int num_cards = 0;
    matcher m = create_matcher( "http://images.kingdomofloathing.com/otherimages/cards//([1-5ak])[a-d]\\.gif" , page );
    boolean found = m.find();//skip dealer's card

    found = m.find();
    while(found) {
        num_cards = num_cards + 1;
        found = m.find();
    }
    
    return num_cards;
}

boolean is_soft( string page) {
    matcher m = create_matcher( "http://images.kingdomofloathing.com/otherimages/cards//([1-5ak])[a-d]\\.gif" , page );
    boolean found = m.find();//skip dealer's card

    int num_aces = 0;
    int sum = 0;
    found = m.find();

    while(found) {
        
        string card = m.group(1);
        if(card == "a") {
           num_aces = num_aces + 1;
           sum = sum + 1;
        } else {
          if(card == "k") {
             sum = sum + 5;
          } else {
             sum = sum + card.to_int();
          }
        }
        found = m.find();
     }

boolean soft = false;
    if(num_aces > 0) {
       if(sum <= 6) {
         soft = true;
       }
    }
 return soft;
}

int get_my_sum(string page) {
    matcher m = create_matcher( "<td style=\"padding-left: .5em; font-size:3em; font-weight: bold;\" width=\"100\">(\\d+)</td>" , page );
    m.find();
    return m.group( 1 ).to_int();
}

void play( int bet , int rounds )
{
    string page;
    string opp;
	int initial=item_amount($item[crimbuck]);
	int total=rounds;

    if( bet < 1 || bet > 11 ) abort( "Invalid bet amount" );
    while( rounds > 0 ) {
        print("Round " + rounds + "(counting down) ... Betting " + bet, "blue");
        page = start_game( bet );
       
        while( !contains_text( page , "Play Again" ) ) {
	    string opp = get_opponent(page);
            int num_cards = get_num_cards(page);
	    int my_sum = get_my_sum(page);
            boolean soft = is_soft(page);

            print("num cards: " + num_cards + "  sum=" + my_sum + "    soft? " + soft);
            
            if( num_cards == 2 && ((my_sum == 5 || my_sum == 6) && (opp == "2" || opp == "3")) ) {
                page = double();
                print("doubling down...");
            } else if( my_sum < 9 ) {
                page = hit();
                print("my_sum < 9, hitting...");
            } else if(my_sum == 9 && soft) {
		page = hit();
                print("my_sum == 9 && soft, hitting...");
            } else if(num_cards == 4 && soft) {
		page = hit();
                print("4 cards && soft, hitting...");
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
        cli_execute("burn *");
    }
	int change=item_amount($item[crimbuck]) - initial;
	print("gained "+change+" crimbux in "+total+" adventures","blue");
    print("gambling complete");
	cli_execute("awake.ash");
}

void main()
{
	play(11,my_adventures());
}