import <hobopolis.ash>;

void main()
{
	if(have_familiar($familiar[squamous gibberer]))
		use_familiar($familiar[squamous gibberer]);
	/*if(my_level()>12 && have_effect($effect[the royal we])<500)
	{
		if(fullness_limit()- my_fullness()>10)
		{
			use(1,$item[milk of magnesium]);
		}
		if(fullness_limit()- my_fullness()>0)
		{
			use(1,$item[milk of magnesium]);
		}
		eat(fullness_limit()- my_fullness(),$item[queen cookie]);
	}*/
	while(my_adventures()>0) //call forever, even if hobopolis is done, this allows me to use updated info each call
	{
		cli_execute("hobopolis.ash");
	}
}