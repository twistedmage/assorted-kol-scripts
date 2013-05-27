import <QuestLib.ash>;
import <sims_lib.ash>;

void TavernQuest()
{
	if (my_level() >= 3)
	{
        council();

		if (contains_text(visit_url("questlog.php?which=1"),"Ooh, I Think I Smell a Rat"))
		{
			dress_for_fighting();
			cli_execute("conditions clear");
			request_monsterlevel(0);
			visit_url("tavern.php?place=barkeep");
//			int catch = tavern();
			if(my_adventures()==0)
			{
				return;
			}
			int row=0;
			int col=5;
			while (!check_page("cellar.php","ratfaucet.gif") && my_adventures()>0)
			{
				cli_execute("recover both");
				int spot = row*5+col;
				print("Exploring square: "+spot,"blue");
				string page = visit_url("cellar.php?action=explore&whichspot=" + spot);
				if (page.contains_text("Combat"))
				{
					while(!page.contains_text("slink away") && !page.contains_text("You win the fight"))
					{
						page=run_combat();
					}
				}
				else if (page.contains_text("Had Nothing on This Cellar"))
				{
					page = visit_url("choice.php?pwd&whichchoice=514&option=1&choiceform1=Dump+out+the+crate");				
				}
				else if (page.contains_text("Those Who Came Before You"))
				{
					page = visit_url("choice.php?pwd&whichchoice=510&option=1&choiceform1=Search+the+body");				
				}
				else if (page.contains_text("Somebody left the rat faucet on"))
				{
					page = visit_url("choice.php?pwd&whichchoice=509&option=1&choiceform1=Turn+off+the+faucet");				
				}
				else if (page.contains_text("Crate Expectations"))
				{
					page = visit_url("choice.php?pwd&whichchoice=496&option=1&choiceform1=Smash+the+crates");				
				}
				else if (page.contains_text("Staring Down the Barrel"))
				{
					page = visit_url("choice.php?pwd&whichchoice=513&option=1&choiceform1=Smash+the+barrel");				
				}
				else if (page.contains_text("is it Still a Mansion"))
				{
					page = visit_url("choice.php?pwd&whichchoice=511&option=1&choiceform1=Knock+on+the+door");				
				}
				else if (page.contains_text("rat the battlements"))
				{
					page = visit_url("choice.php?pwd&whichchoice=515&option=1&choiceform1=Kick+over+the+castle");				
				}
				//go to next square
				if(col==0)
				{
					col=5;
					row=row+1;
				}
				else
				{
					col=col-1;
				}
			}

			visit_url("tavern.php?place=barkeep");
			council();
		}
		else if (contains_text(visit_url("questlog.php?which=2"),"Ooh, I Think I Smell a Rat"))
		{
			print("You have already completed the level 3 quest.");
		}
		else
		{
			print("The level 3 quest is not currently available.");
		}
	}
	else
	{
		print("You must be at least level 3 to attempt this quest.");
	}
}
void main()
{
	TavernQuest();
}