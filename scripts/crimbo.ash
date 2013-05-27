
/*
void fight(string page)
{
	while(!page.contains_text("You win the fight"))
	{
		if(page.contains_text("slink away"))
		{
			abort("lost!");
		}
		page=attack();
	}
}

void main(int num)
{
	while(num>0 && my_adventures()>0)
	{
		if(to_float(my_hp())/ to_float(my_maxhp())<0.45)
		{
			cli_execute("recover hp");
		}
		if(to_float(my_mp())/ to_float(my_maxmp())>0.8)
		{
			cli_execute("mood execute");
		}
		string page = visit_url("adventure.php?snarfblat=247");
		fight(page);
		num=num-1;
	}
}
*/



void main( )
{
	//start with 25 adventures
	adventure(50,$location[Crimbco cubicles]);
	while(my_adventures()>0)
	{
		//use tea
		use(1,$item[workytime tea]);
		//25 adventures
		adventure(25,$location[Crimbco cubicles]);
	}
}