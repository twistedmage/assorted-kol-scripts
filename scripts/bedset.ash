import <eatdrink.ash>;
import <questlib.ash>;

void bedset()
{
	//dead guys watch
	if(available_amount($item[dead guys watch])==0)
	{
		cli_execute("conditions clear");
		cli_execute("condition add 1 dead guys watch");
		boolean catch=adventure(my_adventures(),$location[pre-cyrpt cemetary]);
	}
	//sword behind inappropriate prepositions
	if(available_amount($item[sword behind inappropriate prepositions])==0)
	{
		if(available_amount($item[facsimile dictionary])!=0)
		{
			if(have_skill($skill[Super-Advanced Meatsmithing]))
			{
				while(available_amount($item[facsimile dictionary])!=0 && my_adventures()>0)
				{
					create(1, $item[sword behind inappropriate prepositions]);
				}
			}
			else
			{
				print("Cant make an innappropriate sword this ascension");
			}
		}
	}
	//tiny plastic bitchin meatcar
	if(available_amount($item[tiny plastic Crimbo reindeer])==0)
	{
		//buy in mall
		buy(1, $item[tiny plastic Crimbo reindeer], 20000);
	}
	//clockwork maid
	if(!contains_text(visit_url("campground.php"), "maid2.gif"))
	{
		if(available_amount($item[clockwork maid])==0)
		{
			dress_for_fighting();
			if(available_amount($item[clockwork maid head])==0)
			{
				if(available_amount($item[clockwork sphere])==0)
				{
					buy(1, $item[clockwork sphere], 30000);
				}
				if(available_amount($item[maiden wig])==0)
				{
					
					if(in_muscle_sign())
					{
						if(can_interact())
						{
							buy(1, $item[maiden wig]);
						}
					}
					else
					{
						cli_execute("conditions clear");
						cli_execute("condition add 1 maiden wig");
						boolean catch = adventure(my_adventures(), $location[Degrassi Knoll]);	
					}
				}
				create(1, $item[clockwork maid head]);
			}
			if(available_amount($item[meat maid body])==0)
			{
				if (available_amount($item[meat engine]) == 0)
				{
					if (available_amount($item[cog and sprocket assembly]) == 0)
					{
						if (available_amount($item[sprocket assembly]) == 0)
						{
							while(available_amount($item[spring]) == 0 && my_adventures()>0)
							{
								
								if(in_muscle_sign())
								{
									if(can_interact())
									{
										buy(1, $item[spring]);
									}
								}
								else
								{
									adventure(1, $location[Degrassi Knoll]);
									cli_execute("use * Gnollish toolbox");
								}
							}
							while(available_amount($item[sprocket]) == 0 && my_adventures()>0)
							{
								if(in_muscle_sign())
								{
									if(can_interact())
									{
										buy(1, $item[sprocket]);
									}
								}
								else
								{
									adventure(1, $location[Degrassi Knoll]);
									cli_execute("use * Gnollish toolbox");
								}
							}
						}
						while(available_amount($item[cog]) == 0 && my_adventures()>0)
						{
							if(in_muscle_sign())
							{
								if(can_interact())
								{
									buy(1, $item[cog]);
								}
							}
							else
							{
								adventure(1, $location[Degrassi Knoll]);
								cli_execute("use * Gnollish toolbox");
							}
						}
					}
	
					if (available_amount($item[full meat tank]) == 0)
					{
						while(available_amount($item[empty meat tank]) == 0 && my_adventures()>0)
						{
							if(in_muscle_sign())
							{
								if(can_interact())
								{
									buy(1, $item[empty meat tank]);
								}
							}
							else
							{
								adventure(1, $location[Degrassi Knoll]);
								cli_execute("use * Gnollish toolbox");
							}		
						}
					}
				}
				create(1, $item[meat engine]);
				if(available_amount($item[frilly skirt])==0 && my_adventures()>0)
				{
					if(in_muscle_sign())
					{
						if(can_interact())
						{
							buy(1, $item[frilly skirt]);
						}
					}
					else
					{
						adventure(1, $location[Degrassi Knoll]);
					}
				}
				create(1, $item[Meat maid body]);
			}
			create(1, $item[clockwork maid]);
		}
		cli_execute("use 1 clockwork maid");
	}
}

void main()
{
	bedset();
}