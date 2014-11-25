//run old ver buff script first

import <eatdrink.ash>;
import <zlib.ash>;
import <EatSushi.ash>;
import <improve.ash>;
import <train.ash>;
import <questlib.ash>;
import <Universal_recovery.ash>
import <nscomb.ash>;
import <canadv.ash>;


//if out of ronin, and stats in right range, and can eat then eat
//if in roninor stats can't go down more, leave it 
void naughty_breakfast()
{
	if(my_primestat()!=$stat[moxie])
	{
		if(can_interact() && have_effect($effect[got milk])==0 && (fullness_limit() - my_fullness())>3)
		{
			use(1,$item[milk of magnesium]);
		}
		while(can_interact() && my_basestat(my_primestat())>13 && (fullness_limit() - my_fullness())>3)
		{
			if(my_primestat()==$stat[muscle])
			{
				eat(1,$item[Brimstone Chicken Sandwich]);
			}
			else
			{
				eat(1,$item[double bacon beelzeburger]);
			}
		}
	}
	else
	{
		if(have_effect($effect[ode to booze])==0 && can_interact())
		{
			meatmail("testudinata",11);
			abort("You miss ode, thus your breakfast would be teh sux, fix it.");
		}
		while(can_interact() && my_basestat(my_primestat())>13 && (inebriety_limit() - my_inebriety())>3)
		{
			drink(1,$item[imp ale]);
		}
	}
	cli_execute("refresh effects");
	if(have_effect($effect[ode to booze])==0 && can_interact())
	{
		meatmail("testudinata",1);
		print("You miss ode, thus your breakfast would be teh sux, fix it.","red");
	}
	//drink non stat tps stuff and overdrink
	while(can_interact() && (inebriety_limit() - my_inebriety() > 2))
	{
		if(my_level()>3 && inebriety_limit() - my_inebriety() > 3)
		{
			if(my_primestat()==$stat[muscle])
			{
				drink(1,$item[rockin' wagon]);
			}
			else if(my_primestat()==$stat[moxie])
			{
				drink(1,$item[fuzzbump]);
			}
			else
			{
				drink(1,$item[rockin' wagon]);
			}
		}
		else
		{
			if(my_primestat()==$stat[muscle])
			{
				drink(1,$item[strawberry wine]);
			}
			else if(my_primestat()==$stat[moxie])
			{
				drink(1,$item[whiskey sour]);
			}
			else
			{
				drink(1,$item[strawberry wine]);
			}
		}
	}
}

//if we can lower our stats, do so until we can't
//then try eating and drinking non stat stuff
void naughty_dinner()
{
	if(can_interact()&& (fullness_limit() - my_fullness())>3)
	{
		use(1,$item[milk of magnesium]);
	}
	//use stat reducers
	if(my_basestat(my_primestat())>13)
	{
		if(my_primestat()!=$stat[moxie])
		{
			while(can_interact() && (fullness_limit() - my_fullness())>3 && my_basestat(my_primestat())>13)
			{
				if(my_primestat()==$stat[muscle])
				{
					eat(1,$item[Brimstone Chicken Sandwich]);
				}
				else
				{
					eat(1,$item[double bacon beelzeburger]);
				}
			}
		}
		else
		{
			while(can_interact() && (inebriety_limit() - my_inebriety())>3 && my_basestat(my_primestat())>13)
			{
				drink(1,$item[imp ale]);
			}
		}
	}
	//eat non stat stuff
	while(can_interact() && (fullness_limit() - my_fullness())>3 && my_level()>4)
	{
		if(my_primestat()==$stat[muscle])
		{
			eat(1,$item[rat appendix stir-fry]);
		}
		else if(my_primestat()==$stat[moxie])
		{
			eat(1,$item[Knob sausage stir-fry]);
		}
		else
		{
			eat(1,$item[rat appendix stir-fry]);
		}
	}
	cli_execute("refresh effects");
	if(have_effect($effect[ode to booze])==0 && can_interact())
	{
		meatmail("testudinata",1);
		print("You miss ode, thus your breakfast would be teh sux, fix it.","red");
	}
	//drink non stat tps stuff and overdrink
	while(can_interact() && (inebriety_limit() >= my_inebriety()))
	{
		if(my_level()>3)
		{
			if(my_primestat()==$stat[muscle])
			{
				drink(1,$item[rockin' wagon]);
			}
			else if(my_primestat()==$stat[moxie])
			{
				drink(1,$item[fuzzbump]);
			}
			else
			{
				drink(1,$item[rockin' wagon]);
			}
		}
		else
		{
			if(my_primestat()==$stat[muscle])
			{
				drink(1,$item[strawberry wine]);
			}
			else if(my_primestat()==$stat[moxie])
			{
				drink(1,$item[whiskey sour]);
			}
			else
			{
				drink(1,$item[strawberry wine]);
			}
		}
	}
	cli_execute("exit");
}


void cola_farm()
{
	cli_execute("familiar unconcious dream collective");
	cli_execute("mood apathetic");
	
	while(my_level()<2 && my_adventures()>0)
	{
		adventure(1,$location[sleazy back alley]);
	}
	council();
	while(my_basestat(my_primestat())<11 && my_adventures()>0)
	{
		//try for a baio
		set_property("choiceAdventure502","3");
		set_property("choiceAdventure506","1");
		set_property("choiceAdventure26","2");
		set_property("choiceAdventure28","2");
		adventure(1,$location[spooky forest]);
	}
	if(my_basestat(my_primestat())>=11)
	{
		while(contains_text(visit_url("guild.php?place=trainer"),"until you are a full member of the"))
		{
			print("doing challenge","blue");
			visit_url("guild.php?action=chal");
		}
		if(!contains_text(visit_url("questlog.php?which=1"),"The Wizard of Ego"))
		{
			print("accepting wizard of ego quest","blue");
			visit_url("guild.php?place=ocg&pwd");
			visit_url("guild.php?place=scg&pwd");
			visit_url("guild.php?place=ocg&pwd");
			visit_url("guild.php?place=scg&pwd");
		}
		while(!contains_text(visit_url("questlog.php?which=1"),"you got the key and turned it in") && !contains_text(visit_url("questlog.php?which=1")," you've been given back the key to Fernswarthy") && !contains_text(visit_url("questlog.php?which=2"),"The Wizard of Ego")  && my_adventures()>0 && can_interact())
		{
			visit_url("guild.php?place=ocg&pwd");
			visit_url("guild.php?place=scg&pwd");
			visit_url("guild.php?place=ocg&pwd");
			visit_url("guild.php?place=scg&pwd");
			if(item_amount($item[grave robbing shovel])<1)
			{
				print("getting shovel","blue");
				buy(1,$item[grave robbing shovel]);
			}	
			print("getting ferswarthys key","blue");
			adventure(1,$location[pre-cyrpt Cemetary]);
		}
		//if not out of ronin farm sign gym
		while(my_adventures()>0 && !can_interact())
		{
			print("farming off stat","blue");
			if(my_primestat()!=$stat[mysticality] && in_mysticality_sign())
			{
				adventure(1,$location[pump up mysticality]);
			}
			else
			{
				cli_execute("sleep 1");
			}
		}
		//if don't have uniform get it
/*		if(can_interact())
		{
			print("checking and getting outfit","blue");
			if(item_amount($item[Dyspepsi-Cola helmet])==0 && equipped_amount($item[Dyspepsi-Cola helmet])==0)
			{
				buy(1,$item[Dyspepsi-Cola helmet]);
			}
			if(item_amount($item[Dyspepsi-Cola shield])==0 && equipped_amount($item[Dyspepsi-Cola shield])==0)
			{
				buy(1,$item[Dyspepsi-Cola shield]);
			}
			if(item_amount($item[Dyspepsi-Cola fatigues])==0 && equipped_amount($item[Dyspepsi-Cola fatigues])==0)
			{
				buy(1,$item[Dyspepsi-Cola fatigues]);
			}
		}	*/
		//now farm
		if(can_interact() && my_adventures()>0)
		{
			string combat_stat;
			if(my_buffedstat($stat[moxie])>my_buffedstat($stat[muscle]))
			{
				combat_stat="-melee";
			}
			else
			{
				combat_stat="+melee";
			}
			while(my_level()<4 && my_adventures()>0)
			{
				print("leveling to 4","blue");
				cli_execute("maximize "+ my_primestat()+" exp");
				adventure(1,$location[spooky forest]);
			}
			
			while(my_adventures()>0)
			{
				while(my_level()>3 && my_level()<6)
				{
					//set choiceadvs to bad stats
					<>;
					adventure(1,$location[Battlefield (No Uniform)]);
				}
				//eat basic hotdogs
				if(my_fullness()<fullness_limit())
					abort("Need to fill up before losing stats to hotdogs");
				while(my_level()>5)
				{
					string st = visit_url("clan_viplounge.php?preaction=eathotdog&whichdog=-92");
					if(contains_text(st,"don't feel up to"))
						abort("problem with hotdog");
				}
			}
		}
	}
}

void cola_morning()
{
	cli_execute("mood default");
	print("naughty breakfast","blue");
	naughty_breakfast();
	print("about to cola farm","blue");
	cola_farm();
	//if we've failed hard, lets just try to ascend
	if(my_level()>8)
	{
		cli_execute("a-questing.ash");
	}
	print("about to naughty dinner","blue");
	naughty_dinner();
}


void main()
{
//run awake or bed as needed----------------------------------------------
	if(my_adventures()>0 && my_inebriety()<=inebriety_limit())
	{
		print("cola morning","blue");
		cola_morning();
	}
	else
	{
		print("naughty dinner","blue");
		naughty_dinner();
	}
}