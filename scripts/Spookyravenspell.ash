import <QuestLib.ash>;

void Spookyravenspell()
{
	item class_item;
	int curclass;
	skill class_skill;
	//load class item for your class
	if((my_class()==$class[seal clubber]))
	{
		class_item= $item[tattered wolf standard];
		curclass=1;
	}
	else if(my_class()==$class[turtle tamer])
	{
		class_item= $item[tattered snake standard];
		curclass=2;
	}
	else if(my_class()==$class[disco bandit] || my_class()==$class[accordion thief])
	{
		class_item= $item[bizarre illegible sheet music];
		curclass=3;
	}
	else
	{
		class_item= $item[English to A. F. U. E. Dictionary];
		curclass=4;
	}

	//load skill for your class
	if((my_class()==$class[seal clubber]))
	{
		class_skill= $skill[Snarl of the Timberwolf];
	}
	else if(my_class()==$class[turtle tamer])
	{
		class_skill= $skill[Spectral Snapper];
	}
	else if(my_class()==$class[disco bandit])
	{
		class_skill= $skill[Tango of Terror];
	}
	else if(my_class()==$class[accordion thief])
	{
		class_skill= $skill[Dirge of Dreadfulness];
	}
	else if(my_class()==$class[pastamancer])
	{
		class_skill= $skill[Fearful Fettucini];
	}
	else
	{
		class_skill= $skill[Scarysauce];
	}
	
	//check if already done
	if(have_skill(class_skill))
	{
		print("Spooky spell already attained.");
	}
	else
	{
		dress_for_fighting();
		equip($item[Lord Spookyraven's spectacles]);
		//set noncombat to look under nightstand
		if(available_amount(class_item) == 0)
		{
			print("Getting class item");
			set_property("choiceAdventure83", "3");
			while(available_amount(class_item) == 0 && my_adventures() > 0)
			{
				adventure(request_noncombat(1), $location[haunted bedroom]);
			}
		}
		//dosen't seem to detect when you gain the spell, so you waste the rest of your adventures looking
		print("Got class item");
		if(curclass==1)
		{
			set_property("choiceAdventure89", "1");
			while(my_adventures() > 0 && !contains_text(visit_url("charsheet.php"),to_string(class_skill)))
			{
				adventure(request_noncombat(1), $location[haunted gallery]);
			}
		}
		else if(curclass==2)
		{
			set_property("choiceAdventure89", "2");
			while(my_adventures() > 0 && !contains_text(visit_url("charsheet.php"),to_string(class_skill)))
			{
				adventure(request_noncombat(1), $location[haunted gallery]);
			}
		}
		else if(curclass==3)
		{
			set_property("choiceAdventure90", "1");
			while(my_adventures() > 0 && !contains_text(visit_url("charsheet.php"),to_string(class_skill)))
			{
				adventure(request_noncombat(1), $location[haunted ballroom]);
			}
		}
		else
		{
			set_property("choiceAdventure80", "3");
			set_property("choiceAdventure88", "3");
			while(my_adventures() > 0 && !contains_text(visit_url("charsheet.php"),to_string(class_skill)))
			{
				adventure(request_noncombat(1), $location[haunted library]);
			}
		}
		
	}
}

void main()
{
	if(my_adventures()>0)
	{
		Spookyravenspell();
	}
}
