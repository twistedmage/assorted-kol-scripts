void main()
{
	//get token if needed
	if(can_interact())
	{
		if(available_amount($item[Game Grid token])<1)
			buy(1,$item[Game Grid token]);
	}
	
	//check if poss
	if(available_amount($item[Game Grid token])>0)
	{
		string st = visit_url("place.php?whichplace=arcade&action=arcade_plumber");
		if(contains_text(st,"and you don't have any")
			abort("Something is messed up with token_check.ash. Returned string was :"+st);
	}

	if(available_amount($item[defective Game Grid token])>0)
		abort("GOT A DEFECTIVE TOKEN!");
}