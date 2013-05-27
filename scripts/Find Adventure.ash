string run_choice( string page_text )
{
	while( contains_text( page_text , "choice.php" ) )
	{
		## Get choice adventure number
		int begin_choice_adv_num = ( index_of( page_text , "whichchoice value=" ) + 18 );
		int end_choice_adv_num = index_of( page_text , "><input" , begin_choice_adv_num );
		string choice_adv_num = substring( page_text , begin_choice_adv_num , end_choice_adv_num );
		
		string choice_adv_prop = "choiceAdventure" + choice_adv_num;
		string choice_num = get_property( choice_adv_prop );
		
		if( choice_num == "" ) abort( "Unsupported Choice Adventure!" );
		
		string url = "choice.php?pwd&whichchoice=" + choice_adv_num + "&option=" + choice_num;
		page_text = visit_url( url );
	}
	return page_text;
}

boolean find_adventure(string text, location loc, int adv)
{
	string page = "";
	string url = loc.to_url();
	int i = 0;

	text = text.to_lower_case();

	while (my_adventures() > 0 && url > 0)
	{
		page = visit_url(url);

		if (page.contains_text("Combat"))
		{
			page = run_combat();
		}
		else if (page.contains_text("choice.php"))
		{                                                    
			page = run_choice(page);
		}

		page = page.to_lower_case();

        i = i + 1;

		if (page.contains_text(text))
		{
			return true;
		}

		adv = adv - 1;
	}

	return false;
}

void main(string text, location loc, int adv)
{
	find_adventure(text, loc, adv);
}
