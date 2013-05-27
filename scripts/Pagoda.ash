import <questlib.ash>;

## Script created by Zammywarrior(#644117) [KoL name] Hippymon [KoLmafia forum name].
## This script is designd to create a pagoda in your campground
## for you. Questions? Comments? Please K-mail them to ZammyWarrior via KoL.
void main(){
	if(contains_text(visit_url("campground.php"), "pagoda.gif"))
	{
		print("Already gotten pagoda.");
	}
	else
	{
		boolean catch;
		dress_for_fighting();
		if(available_amount($item[pagoda plans])==0)
		{
			while(item_amount($item[Elf Farm Raffle ticket]) == 0 && my_adventures()>0)
			{
				adventure(1, $location[Palindome]);
			}
			retrieve_item(1, $item[ten-leaf clover]);
			use(1, $item[Elf Farm Raffle ticket]);
		}
		while(item_amount($item[guitar pick]) == 0 && my_adventures()>0)
		{
			adventure(1, $location[Palindome]);
		}
		if(item_amount($item[heavy metal sonata])==0)
		{
			cli_execute("acquire heavy metal sonata");
		}
		if(item_amount($item[heavy metal thunderrr guitarrr])==0)
		{
			cli_execute("acquire heavy metal thunderrr guitarrr");
		}
		if(item_amount($item[hey deze map]) == 0 && item_amount($item[hey deze nuts]) == 0)
		{
			cli_execute("conditions clear");
			add_item_condition(1, $item[hey deze map]);
			adventure(my_adventures(), $location[friar's gate]);
		}
		if(item_amount($item[hey deze map]) == 1 && item_amount($item[guitar pick]) == 0 && item_amount($item[guitar pick]) == 0 && item_amount($item[heavy metal sonata])==0)
		{
			use(1, $item[Hey Deze map]);
		}
		if(item_amount($item[ketchup hound])==0)
		{
			cli_execute("acquire ketchup hound");
		}
		if(item_amount($item[ketchup hound])!=0)
		{
			use(1, $item[ketchup hound]);
		}
	}
}