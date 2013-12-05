
// Helper script for PorkFuture.ash to farm wumpuses.
// 
// CLI: "wumpusfarm [#]", or "wumpusfarm trophy" to get the trophy.
// Negative values of [#] will make it maximize ML instead of -combat, for wumpus-hair drops.

import <PorkFuture.ash>;

void main(string wumpii)
{
	int target_wumpii = 1;
	boolean trophy_mode = false;
	boolean trophy_success = false;
	int killed = 0;
	
	noncombat_mood();
	cli_execute("mood execute");
	if (contains_text(to_lower_case(wumpii),"trophy"))
	{
		if (contains_text(visit_url("trophies.php"),"dodecahardon.gif"))
			abort("You already have the Wumpus trophy!");
		else if (contains_text(visit_url("trophy.php"),"Hunter In Darkness"))
			abort("The Wumpus trophy is sitting in the trophy hut; go buy it!");
		target_wumpii = 5;
		trophy_mode = true;
		print("Unlocking Wumpus trophy...","blue");
	}
	else
	{
		target_wumpii = wumpii.to_int();
		if (target_wumpii == 0)
			target_wumpii = 1;
		if (target_wumpii < 0)
		{
			if (equipped_item($slot[pants]) == $item[Pantsgiving])
				cli_execute("maximize ml -pants");
			else
				cli_execute("maximize ml");
			target_wumpii *= -1;
		}
		if (combat_rate_modifier() > -25 && can_interact())
			cli_execute("trigger lose_effect, fresh scent, use 1 rock salt");
		if (target_wumpii > 1)
			print("Murdering "+target_wumpii+" Wumpii...","blue");
		else
			print("Murdering 1 Wumpus...","blue");
	}
	wait(5);
	
	while (killed < target_wumpii)
	{
		bottle_iku(205);
		if (in_combat())
			run_combat();
		else if (contains_text(advstring,"This is the entrance to the ancient city"))
			manual_noncom(366,2);
		else if (contains_text(advstring,"Krakrox regarded the ancient temple"))
			manual_noncom(367,2);
		else if (wumpwn())
		{
			killed += 1;
			if (trophy_mode)
			{
				if (contains_text(visit_url("trophy.php"),"Hunter In Darkness"))
				{
					trophy_success = true;
					break;
				}
				else if (killed >= 5)
					break;
			}
		}
		else if (trophy_mode)
			killed = 0;
	}
	cli_execute("mood clear");
	
	if (trophy_mode)
	{
		if (trophy_success)
			print("Hunter in Darkness trophy available! Go buy it before you get wumpwned!","blue");
		else
			print("We've fulfilled the trophy conditions, but it isn't there...?","red");
	}
	else
	{
		if (target_wumpii > 1)
			print(target_wumpii+" Wumpii murdered!","blue");
		else
			print("1 Wumpus murdered!","blue");
	}
}