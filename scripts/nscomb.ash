// ------------------------------------------------------------------
//  main
// ------------------------------------------------------------------



void custom_fight(string roundString, string encounterString, string pageString)
{
	if(contains_text(encounterString,"snow queen"))
	{
		if(have_skill($skill[saucegeyser]))
		{
			if(my_mp() < mp_cost($skill[saucegeyser]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					attack();
				}
			}
			use_skill($skill[saucegeyser]);
		}
		else if(have_skill($skill[Stuffed Mortar Shell]))
		{
			if(my_mp() < mp_cost($skill[Stuffed Mortar Shell]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					attack();
				}
			}
			use_skill($skill[Stuffed Mortar Shell]);
		}
		else
		{
			use_skill($skill[CLEESH]);
			attack();
		}
	}
	else if(contains_text(encounterString,"Spaghetti Demon"))
	{
		while(!contains_text(pageString,"slink away") && !contains_text(pageString,"You win the fight"))
		{
			if(!contains_text(pageString," reinforcing the bonds on several"))
			{
				pageString=use_skill($skill[entangling noodles]);
			}
			else
			{
				pageString=use_skill($skill[Weapon of the pastalord]);
			}
		}
	}
	else if(contains_text(encounterString,"Gorgolok, the Demonic Hellseal"))
	{
		while(!contains_text(pageString,"slink away") && !contains_text(pageString,"You win the fight"))
		{
			if(my_mp() < mp_cost($skill[lunging thrust-smack]))
			{
				pageString=use_skill($skill[lunging thrust-smack]);
			}
			else
			{
				pageString=attack();
			}
		}
	}
	else if(contains_text(encounterString,"Stella, the Demonic Turtle Poacher"))
	{
		boolean aspects_used=false;
		while(!contains_text(pageString,"slink away") && !contains_text(pageString,"You win the fight"))
		{
			if(contains_text(pagestring,"battlecry praising the glorious turtle"))
			{
				aspects_used=true;
			}
			if(aspects_used==false)
			{
				pagestring=use_skill($skill[Turtle of Seven Tails]);
			}
			else
			{
				if(my_mp()>12)
				{
					pagestring=use_skill($skill[Head + Knee + Shield Combo]);
				}
				else
				{
					pagestring=attack();
				}
			}
		}
	}
	else if(contains_text(encounterString,"Lumpy, the Demonic Sauceblob"))
	{
		while(!contains_text(pageString,"slink away") && !contains_text(pageString,"You win the fight"))
		{
			pageString = use_skill($skill[saucemageddon]);
		}
	}
	else if(contains_text(encounterString,"Demon Spirit of New Wave"))
	{
		while(!contains_text(pageString,"slink away") && !contains_text(pageString,"You win the fight"))
		{
			if(contains_text(pageString,"Spirit turns a knob on his mixing board"))
			{
				pageString = use_skill($skill[Funk Bluegrass Fusion]);
			}
			else
			{
				pageString = attack();
			}
		}
	}
	else if(contains_text(encounterString,"Somerset Lopez, Demon Mariachi"))
	{
		while(!contains_text(pageString,"slink away") && !contains_text(pageString,"You win the fight"))
		{
			abort("No tactics for him yet");
		}
	}
	else if(contains_text(encounterString,"elf"))
	{
		if(have_skill($skill[saucegeyser]))
		{
			if(my_mp() < mp_cost($skill[saucegeyser]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					attack();
				}
			}
			use_skill($skill[saucegeyser]);
		}
		else if(have_skill($skill[Weapon of the pastalord]))
		{
			if(my_mp() < mp_cost($skill[Weapon of the pastalord]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					attack();
				}
			}
			use_skill($skill[Weapon of the pastalord]);
		}
		else if(have_skill($skill[Stuffed Mortar Shell]))
		{
			if(my_mp() < mp_cost($skill[Stuffed Mortar Shell]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					attack();
				}
			}
			use_skill($skill[Stuffed Mortar Shell]);
		}
		else
		{
			attack();
		}
	}
	else if(contains_text(encounterString,"Spirit of New Wave") || contains_text(encounterString,"Gorgolok, the Infernal Seal") || contains_text(encounterString,"Stella, the Turtle Poacher") || contains_text(encounterString,"Spaghetti Elemental") || contains_text(encounterString,"Lumpy, the Sinister Sauceblob") || contains_text(encounterString,"Somerset Lopez, Dread Mariachi"))
	{
		while(!contains_text(pageString,"slink away") && !contains_text(pageString,"You win the fight"))
		{
			if(have_skill($skill[saucegeyser]))
			{
				if(my_mp() < mp_cost($skill[saucegeyser]))
				{
					if(available_amount($item[Magical mystery juice])>0)
					{
						pageString = throw_item($item[Magical mystery juice]);
					}
					else if(available_amount($item[Bottle of Monsieur Bubble])>0)
					{
						pageString = throw_item($item[Bottle of Monsieur Bubble]);
					}
					else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
					{
						pageString = throw_item($item[Unrefined Mountain Stream syrup]);
					}
					else if(available_amount($item[Green pixel potion])>0)
					{
						pageString = throw_item($item[Green pixel potion]);
					}
					else if(available_amount($item[Palm-frond fan])>0)
					{
						pageString = throw_item($item[Palm-frond fan]);
					}
					else if(available_amount($item[Knob Goblin superseltzer])>0)
					{
						pageString = throw_item($item[Knob Goblin superseltzer]);
					}
					else
					{
						pageString = attack();
					}
				}
				pageString = use_skill($skill[saucegeyser]);
			}
			else if(have_skill($skill[weapon of the pastalord]))
			{
				if(my_mp() < mp_cost($skill[weapon of the pastalord]))
				{
					if(available_amount($item[Magical mystery juice])>0)
					{
						pageString = throw_item($item[Magical mystery juice]);
					}
					else if(available_amount($item[Bottle of Monsieur Bubble])>0)
					{
						pageString = throw_item($item[Bottle of Monsieur Bubble]);
					}
					else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
					{
						pageString = throw_item($item[Unrefined Mountain Stream syrup]);
					}
					else if(available_amount($item[Green pixel potion])>0)
					{
						pageString = throw_item($item[Green pixel potion]);
					}
					else if(available_amount($item[Palm-frond fan])>0)
					{
						pageString = throw_item($item[Palm-frond fan]);
					}
					else if(available_amount($item[Knob Goblin superseltzer])>0)
					{
						pageString = throw_item($item[Knob Goblin superseltzer]);
					}
					else
					{
						pageString = attack();
					}
				}
				pageString = use_skill($skill[weapon of the pastalord]);
			}
			else
			{
				pageString = attack();
			}
		}
	}
	else
	{
		print("calling default nscomb","green");
		if(equipped_amount($item[windsor pan of the source])>0)
		{
			if(my_mp() < mp_cost($skill[saucemageddon]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					pageString = throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					pageString = throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					pageString = throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					pageString = throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					pageString = throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					pageString = throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					pageString = attack();
				}
			}
			pageString = use_skill($skill[saucemageddon]);
		}
		else if(have_skill($skill[saucegeyser]))
		{
			if(my_mp() < mp_cost($skill[saucegeyser]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					pageString = throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					pageString = throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					pageString = throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					pageString = throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					pageString = throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					pageString = throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					pageString = attack();
				}
			}
			pageString = use_skill($skill[saucegeyser]);
		}
		else if(have_skill($skill[weapon of the pastalord]))
		{
			if(my_mp() < mp_cost($skill[weapon of the pastalord]))
			{
				if(available_amount($item[Magical mystery juice])>0)
				{
					pageString = throw_item($item[Magical mystery juice]);
				}
				else if(available_amount($item[Bottle of Monsieur Bubble])>0)
				{
					pageString = throw_item($item[Bottle of Monsieur Bubble]);
				}
				else if(available_amount($item[Unrefined Mountain Stream syrup])>0)
				{
					pageString = throw_item($item[Unrefined Mountain Stream syrup]);
				}
				else if(available_amount($item[Green pixel potion])>0)
				{
					pageString = throw_item($item[Green pixel potion]);
				}
				else if(available_amount($item[Palm-frond fan])>0)
				{
					pageString = throw_item($item[Palm-frond fan]);
				}
				else if(available_amount($item[Knob Goblin superseltzer])>0)
				{
					pageString = throw_item($item[Knob Goblin superseltzer]);
				}
				else
				{
					pageString = attack();
				}
			}
			pageString = use_skill($skill[weapon of the pastalord]);
		}
		else
		{
			pageString = attack();
		}
	}
}

void main(string roundString, string encounterString, string pageString)
{
	custom_fight(roundString, encounterString, pageString);
}

//repeatedly call run combat on the current string until fight is over
void use_run_combat(string input)
{
	while(!contains_text(input,"slink away") && !contains_text(input,"You win the fight"))
	{
		print("trying to run combat","blue");
		input = run_combat();
	}
}
