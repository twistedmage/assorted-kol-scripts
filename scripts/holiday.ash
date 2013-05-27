void main()
{
	cli_execute("maximize items");
	adventure(my_adventures(),$location[Mcmillicancuddy's farm]);
	cli_execute("maximize mp regen min, mp regen max, equip stinky cheese eye");
	while(my_adventures()>2)
	{
	
		cli_execute("mood execute");
		cli_execute("burn *");
		if(my_basestat($stat[muscle])<my_basestat($stat[moxie]))
		{
			if(my_basestat($stat[muscle])<my_basestat($stat[mysticality]))
			{
				adventure(1,$location[muscle vacation]);
			}
			else
			{
				adventure(1,$location[mysticality vacation]);
			}
		}
		else
		{
			if(my_basestat($stat[moxie])<my_basestat($stat[mysticality]))
			{
				adventure(1,$location[moxie vacation]);
			}
			else
			{
				adventure(1,$location[mysticality vacation]);
			}
		}
	}
}