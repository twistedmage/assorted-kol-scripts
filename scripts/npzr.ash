import <questlib.ash>;

void NPZR()
{
	if(my_name()!="twistedmage")
	{
		print("No more wasted meat on slackers! No NPZR for you.");
		if(available_amount($item[chest of the Bonerdagon]) != 0)
		{
			use(1,$item[chest of the Bonerdagon]);
		}
		return;
	}
	if(!have_familiar($familiar[Ninja Pirate Zombie Robot]) && available_amount($item[chest of the Bonerdagon]) == 0)
	{
		print("Seems you already used your chest of the bonerdagon, better luck next life.","red");
	}
	else if (!have_familiar($familiar[Ninja Pirate Zombie Robot]))
	{
		dress_for_fighting();
		if(available_amount($item[Ninja Pirate Zombie Robot]) == 0)
		{
			familiar prev=my_familiar();
			//get extras in inv
			while(available_amount($item[blundarrrbus]) == 0 && my_adventures() > 0)
			{
				if(!have_familiar($familiar[Spooky Pirate Skeleton]))
				{
					if(available_amount($item[Pirate skull]) == 0)
					{
						if(available_amount($item[eyepatch]) == 0 && my_adventures() > 0)
						{
							cli_execute("conditions clear");
							cli_execute("condition add 1 eyepatch");
							boolean catch=adventure(my_adventures(),$location[pirate cove]);
						}
						if(available_amount($item[brainy skull]) == 0)
						{
							if(available_amount($item[smart skull]) == 0 && my_adventures() > 0)
							{
								cli_execute("conditions clear");
								cli_execute("condition add 1 smart skull");
								boolean catch=adventure(my_adventures(),$location[post-cyrpt cemetary]);
							}
							if(available_amount($item[disembodied brain]) == 0 && my_adventures() > 0)
							{
								cli_execute("conditions clear");
								cli_execute("condition add 1 disembodied brain");
								boolean catch=adventure(my_adventures(),$location[Fernswarthy's Ruins]);
							}
							create(1,$item[brainy skull]);
						}
						create(1,$item[Pirate skull]);
					}
					if (available_amount($item[Sunken chest]) == 0 && my_adventures() > 0)
					{
						cli_execute("conditions clear");
						cli_execute("condition add 1 Sunken chest");
						boolean catch=adventure(my_adventures(),$location[pirate cove]);
					}
					if (available_amount($item[pirate pelvis]) == 0 && my_adventures() > 0)
					{
						cli_execute("conditions clear");
						cli_execute("condition add 1 pirate pelvis");
						boolean catch=adventure(my_adventures(),$location[pirate cove]);
					}
					if (available_amount($item[Skeleton bone]) < 8 && my_adventures() > 0)
					{
						cli_execute("conditions clear");
						cli_execute("condition add 8 Skeleton bone");
						boolean catch=adventure(my_adventures(),$location[post-cyrpt cemetary]);
					}
					use(1,$item[Pirate skull]);
					use(1,$item[Spooky Pirate Skeleton]);
					cli_execute("familiar Spooky Pirate Skeleton");
				}
				cli_execute("train turns 1");
				cli_execute("unequip blundarrrbus");
			}
			use_familiar(prev);
			while(available_amount($item[cheap toaster]) == 0 && my_adventures() > 3)
			{
				adventure(1,$location[Moxie Vacation]);
			}
			if (available_amount($item[clockwork claws]) == 0)
			{
				buy(1,$item[clockwork claws]);
			}
			if (available_amount($item[clockwork sheet]) == 0 && my_adventures() > 0)
			{
				buy(1,$item[clockwork sheet]);
			}
			if (available_amount($item[clockwork spine]) == 0 && my_adventures() > 0)
			{
				buy(1,$item[clockwork spine]);
			}
			if (available_amount($item[disembodied brain]) == 0 && my_adventures() > 0)
			{
				cli_execute("conditions clear");
				cli_execute("condition add 1 disembodied brain");
				boolean catch=adventure(my_adventures(),$location[Fernswarthy's Ruins]);
			}
			if (available_amount($item[frigid ninja stars]) == 0 && my_adventures() > 0)
			{
				cli_execute("conditions clear");
				cli_execute("condition add 1 frigid ninja stars");
				boolean catch=adventure(my_adventures(),$location[Ninja Snowmen]);
			}
			if (available_amount($item[icy-hot katana]) == 0)
			{
				if(available_amount($item[icy katana hilt]) == 0 && my_adventures() > 0)
				{
					cli_execute("conditions clear");
					cli_execute("condition add 1 icy katana hilt");
					boolean catch=adventure(my_adventures(),$location[ninja snowmen]);
				}
				if(available_amount($item[hot katana blade]) == 0 && my_adventures() > 0)
				{
					cli_execute("conditions clear");
					cli_execute("condition add 1 hot katana blade");
					boolean catch=adventure(my_adventures(),$location[Friar's Gate]);
				}
				create(1,$item[icy-hot katana]);
			}
			if (available_amount($item[pine tar]) == 0)
			{
				buy(1,$item[pine tar]);
			}
			if (available_amount($item[skeleton bone]) == 0 && my_adventures() > 0)
			{
				cli_execute("conditions clear");
				cli_execute("condition add 1 skeleton bone");
				boolean catch=adventure(my_adventures(),$location[Post-Cyrpt Cemetary]);
			}
			if (available_amount($item[spiked femur]) == 0 && my_adventures() > 0)
			{
				cli_execute("conditions clear");
				cli_execute("condition add 1 spiked femur");
				boolean catch=adventure(my_adventures(),$location[Post-Cyrpt Cemetary]);
			}

			if (available_amount($item[star throwing star]) == 0 && my_adventures() > 0)
			{
				cli_execute("conditions clear");
				//cli_execute("condition add 4 stas");
				//cli_execute("condition add 2 lins");
				//cli_execute("condition add 1 star chart");
				cli_execute("condition add 1 star throwing star");
				boolean catch=adventure(my_adventures(),$location[Hole in the sky]);
				//create(1,$item[star throwing star]);
			}
			if (available_amount($item[teeny-tiny ninja stars]) == 0 && my_adventures() > 0)
			{
				buy(1,$item[teeny-tiny ninja stars]);
			}
			if (available_amount($item[ninja pirate zombie robot head]) == 0)
			{
				if (available_amount($item[pirate zombie robot head]) == 0)
				{
					if (available_amount($item[pirate zombie head]) == 0)
					{
						if (available_amount($item[clockwork pirate skull]) == 0)
						{
							if (available_amount($item[clockwork sphere]) == 0)
							{
								buy(1, $item[clockwork sphere]);
							}
							if(available_amount($item[enchanted eyepatch]) == 0)
							{
								if(available_amount($item[eyepatch]) == 0 && my_adventures() > 0)
								{
									cli_execute("conditions clear");
									cli_execute("condition add 1 eyepatch");
									boolean catch=adventure(my_adventures(),$location[pirate cove]);
								}
								if(available_amount($item[lihc eye]) == 0 && my_adventures() > 0)
								{
									cli_execute("conditions clear");
									cli_execute("condition add 1 lihc eye");
									boolean catch=adventure(my_adventures(),$location[post-cyrpt cemetary]);
								}
								create(1,$item[enchanted eyepatch]);
							}
							create(1,$item[clockwork pirate skull]);
						}
						if (available_amount($item[zombie pineal gland]) == 0)
						{
							abort("Buy a zombie pineal gland :(");
						}
						create(1,$item[pirate zombie head]);
					}
					if (available_amount($item[glowing red eye]) == 0 && my_adventures() > 0)
					{
						cli_execute("conditions clear");
						cli_execute("condition add 1 glowing red eye");
						boolean catch=adventure(my_adventures(),$location[Fantasy Airship]);
					}
					create(1,$item[pirate zombie robot head]);
				}
				if (available_amount($item[cold ninja mask]) == 0 && my_adventures() > 0)
				{
					cli_execute("conditions clear");
					cli_execute("condition add 1 cold ninja mask");
					boolean catch=adventure(my_adventures(),$location[Ninja Snowmen]);
				}
				create(1,$item[ninja pirate zombie robot head]);
			}
			use(1,$item[ninja pirate zombie robot head]);
		}
		else
		{
			//put in terarium
			use(1,$item[Ninja Pirate Zombie Robot]);
		}
	}
	else
	{
		print("already Have an NPZR");
	}	
}
void main()
{
	NPZR();
}