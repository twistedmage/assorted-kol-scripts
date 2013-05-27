//Base script code by Alhifar (#1189456)
//Modifications for strategy implementation by RoyalTonberry (#1161513)
//Many thanks go out to mtfns (#1352033), for his work in creating the Optimal Table.

//Note that this can tell mafia to trigger Mana Burning (near the very bottom of the script)

boolean burn_mana = false;//set this to true if you want to burn mana.



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

//this is redundant with the above function, but for some reason, the ASH implementation of array structures is
//wonky and does not recognize the amount of things in the array.
string[int] get_my_cards( string page )
{
    int num_cards = 0;
    matcher m = create_matcher( "http://images.kingdomofloathing.com/otherimages/cards//([1-5ak])[a-d]\\.gif" , page );
    boolean found = m.find();//skip dealer's card
    string[int] my_cards; 

    found = m.find();
    while(found) {
        my_cards[num_cards] = m.group(1);
        num_cards = num_cards + 1;
        found = m.find();
    }
    
    return my_cards;
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


//just used for sorting, so simply treat an Ace as a 1.
int card_value(string card) {
  int value = 0;
  if(card == "a") {
     value = 1;
  } else if(card == "k") {
     value = 5;
  } else {
     value = card.to_int();
  }
  return value;
}

string[int] sort(string[int] original, int num_cards) {
    int i = 0;
    while(i < num_cards) {
       string min = original[i];

       int j = i+1;
       int swap_index = i;
       while(j < num_cards) {
          if(card_value(original[j]) < card_value(min)) {
             min = original[j];
             swap_index = j;
          }
          j = j + 1;
       }
       if(i != swap_index) {
           string temp = original[i];
           original[i] = original[swap_index];
           original[swap_index] = temp;
       }

       i = i + 1;
    }

    return original;
}

string array_to_string(string[int] arr, int len) {
   string str;

   int i = 0;
   while(i < len) {
       str = str + " " + arr[i];
       i = i + 1;
   }

   return str;
}


void main( int bet , int rounds )
{
    string page;
    string opp;
	int initial=item_amount($item[crimbuck]);
	int total=rounds;

    if( bet < 1 || bet > 11 ) abort( "Invalid bet amount" );
    while( rounds > 0 ) {
        print("Round " + rounds + " (counting down) ... Betting " + bet, "blue");
        page = start_game( bet );
       
        while( !contains_text( page , "Play Again" ) ) {
	    string opp = get_opponent(page);
            
	    int my_sum = get_my_sum(page);
            boolean soft = is_soft(page);
            int num_cards = get_num_cards(page);

            string[int] my_cards = sort(get_my_cards(page), num_cards);

            print("Hand: " + array_to_string(my_cards, num_cards) + "  ----   num cards: " + num_cards + "  ----  sum=" + my_sum + " -----   soft? " + soft + " ---- dealer shows " + opp);

            if(soft) {
                if(num_cards == 4) {
                    page = hit();
                } else {
                    if(my_sum == 10) {
                         if(num_cards == 3 && opp == "a") {
                              page = hit();
                         } else {
                              page = stand();
                         }
                    } else if(my_sum == 11) {
                        page = stand();
                    } else {
                        page = hit();
                    }
                }
            } else {//if !soft
                if(my_sum == 4 || my_sum == 7) {
                    page = hit();
                } else if(my_sum == 10) {
                    page = stand();
                } else if(my_sum == 5) { 
                    if(opp == "2" || opp == "3" || opp == "4") {
                        page = double();
                    } else {
                        page = hit();
                    }
                } else if(my_sum == 6) {
                    if(opp == "2" || opp == "3") {
                        page = double();
                    } else if(opp == "4" && my_cards[1] == "4") {//opp is 4 and our hand is "2 4"
                        page = double();
                    } else {
                        page = hit();
                    }
                } else if(my_sum == 8) {
                    if(opp == "4" || opp == "5" || opp == "a" || opp == "k") {
                        page = hit();
                    } else {
                       if(num_cards == 2) {
                           page = hit();
                       } else {
                           //special cases go here
                           if(opp == "2") {
                              if(    (my_cards[0] == "2" && my_cards[1] == "2" && my_cards[2] == "4") 
                                  || (my_cards[0] == "2" && my_cards[1] == "3" && my_cards[2] == "3") ) {
                                 page = stand();
                              } else {
                                 page = hit();
                              }
                           } else if(opp == "3") {
                              if(    (my_cards[0] == "2" && my_cards[1] == "2" && my_cards[2] == "4") 
                                  || (my_cards[0] == "2" && my_cards[1] == "3" && my_cards[2] == "3")
                                  || (my_cards[0] == "2" && my_cards[1] == "2" && my_cards[2] == "2" && my_cards[3] == "2") 
                                  || (my_cards[0] == "A" && my_cards[1] == "2" && my_cards[2] == "3" && my_cards[3] == "5")
                                  || (my_cards[0] == "A" && my_cards[1] == "2" && my_cards[2] == "2" && my_cards[3] == "3")
                                  || (my_cards[0] == "A" && my_cards[1] == "A" && my_cards[2] == "3" && my_cards[3] == "3") ) {
                                 page = stand();
                              } else {
                                 page = hit();
                              }
                           }
                       }
                    }
                } else if(my_sum == 9) {
                    if(opp == "2" || opp == "3" || opp == "4") {
                        page = stand();
                    } else {
                        if(num_cards == 2) {
                            page = hit();
                        } else {
                            //special cases go here
                            if(opp == "a") {
                              if(    (my_cards[0] == "A" && my_cards[1] == "4" && my_cards[2] == "4") 
                                  || (my_cards[0] == "2" && my_cards[1] == "2" && my_cards[2] == "4")
                                  || (my_cards[0] == "2" && my_cards[1] == "3" && my_cards[2] == "5") ) {
                                 page = stand();
                              } else {
                                 page = hit();
                              }
                            } else if(opp == "5" || opp == "k") {

                              if(    (my_cards[0] == "A" && my_cards[1] == "3" && my_cards[2] == "5") 
                                  || (my_cards[0] == "2" && my_cards[1] == "2" && my_cards[2] == "4")
                                  || (my_cards[0] == "2" && my_cards[1] == "3" && my_cards[2] == "5") 
                                  || (my_cards[0] == "A" && my_cards[1] == "A" && my_cards[2] == "2" && my_cards[3] == "5") ) {
                                 page = stand();
                              } else {
                                 page = hit();
                              }
                            }
                        }
                    }
                } else {//stand on Hard 10 and 11
                    page = stand();
                }
            }

        }
	int my_sum = get_my_sum(page);
	print("I have: " + my_sum);
        if(contains_text( page, "You acquire")) {
           print("You Win!", "green");
        } else {
           print("You Lose!", "red");
        }
	
        rounds = rounds - 1;
        if(burn_mana) {
			cli_execute("mood execute");
            cli_execute("burn *");
        }
    }
	int change=item_amount($item[crimbuck]) - initial;
	print("gained "+change+" crimbux in "+total+" adventures","blue");
    print("gambling complete");
}