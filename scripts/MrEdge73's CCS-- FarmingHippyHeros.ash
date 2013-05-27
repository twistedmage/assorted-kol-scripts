// Version Tracking
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
string HCCSURL="http://kolmafia.us/showthread.php?t=2082";
string HCCSverExtension="HCCS";
string HCCSFile="MrEdge73's CCS-- FarmingHippyHeros.ash";
int HCCSversion = 20090714;
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 

//Hero Farmer! -- Hippy Edition
//******************************************************************************
/*
MrEdge73's Hero Farmer
Hippy Version: 20090714HCCS
Frat Version: 20090612FCCS
Created by Justin Edge (mredge73) 

This CCS is designed to get you all of the Hero Items while adventuring in the Battlefield!

Question: How does it work?
It adventures normally until you reach image 24, this is where your first hero can show up.  
It will CLEESH a set number of turns (default 20) before giving up and adventuring normally.
It should never CLEESH any hero listed.
It will do that for every image that a hero is expected to appear on besides image 26 and 28
On Image 30 and/or 31 it will now look for all of your heros that you did not kill yet for a set number of turns (default 50)

Question: How does it know if I killed a hero yet?
It checks your inventory and equipment for the dropped item, so if you are hunting heros DO NOT have the item you are looking for in inventory
The closet is fine.

Question: What if I don't want to hunt a certain hero?
You can edit out the hero you do not want to hunt for in the hero list below

Question: What is its success rate?
Varies by what you put in the CLEESH max turn variables.  The battlefield is still not fully spaded for hero drops so I am unsure of its sucess rate.
I can assure you that I have had a 100% success rate on all heros killing Frat Boys but not killing Hippys...yet.

Theory Source: http://kol.coldfront.net/thekolwiki/index.php/Talk:The_Battlefield

Use:
This is what your CCS should look like when when using Hero Farmer! with FTF and SS:
Zarqon's FirstTingsFirst.ash and SmartStasis.ash are strong suggestions but not necessary for the Hero Farmer!

[ default ]
consult FirstThingsFirst.ash
attack

[ gremlin ]
consult SmartStasis.ash
attack

[ Battlefield (Frat Uniform) ]
consult MrEdge73's CCS-- FarmingHippyHeros.ash
consult FirstThingsFirst.ash
attack

[ Battlefield (Hippy Uniform) ]
consult MrEdge73's CCS-- FarmingFratHeros.ash
consult FirstThingsFirst.ash
attack

*/
//******************************************************************************
/*
version 20090714
added Slow Talking Elliot 

version 20090710
Changed IsHero Function to include all heros
removed Neil and Zim from default hero search

version 20090612
Alpha Version Release
*/
//******************************************************************************
//amount of turns spent Cleeshing before giving up on current image
int TurnsWasted= 20;
//amount of turns wasted on image 30 or 31 trying to get all of the heros that you did not already get
int FinalFarming=50;

//have Item checks inventory and equipped but not closet
//******************************************************************************
boolean haveItem(item thingy)
{
	if(item_amount(thingy)>0)
		return true;
	if(have_equipped( thingy ))
		return true;
		
	return false;
}

//Hero List
//Comment out any that you do not want to try, add in any that you want to make sure you get
//******************************************************************************
monster [int] hippyhero;
hippyhero[21]=$monster[Slow Talkin' Elliot];
hippyhero[24]=$monster[Neil];
hippyhero[25]=$monster[Zim Merman];
hippyhero[27]=$monster[C.A.R.N.I.V.O.R.E. Operative];
hippyhero[29]=$monster[Glass of Orange Juice];

boolean [int] hippydead;
hippydead[21]=haveItem($item[Slow Talkin' Elliot's dogtags]);
hippydead[24]=haveItem($item[longhaired hippy wig]);
hippydead[25]=haveItem($item[Zim Merman's guitar]);
hippydead[27]=haveItem($item[C.A.R.N.I.V.O.R.E. button]);
hippydead[29]=haveItem($item[orange peel hat]);

//tries to use a skill
//******************************************************************************
string try_skill(string page, skill tocast) 
{
	if (have_skill(tocast) && my_mp() >= mp_cost(tocast)) 
		return use_skill(tocast);
	return page;
}

//Checks if the Foe is a battlefield hero
//******************************************************************************
boolean IsHero(monster BadMan)
{
	switch (BadMan)
	{
	case $monster[Neil]:
		return true;	
	case $monster[Zim Merman]:
		return true;
	case $monster[C.A.R.N.I.V.O.R.E. Operative]:
		return true;
	case $monster[Glass of Orange Juice]:
		return true;
	case $monster[Slow Talkin' Elliot]:
		return true;	
	}
	return false;
}

//Gets Hero Image by hippies defeated, cannot check the battlefield because stuck in fight.php
//******************************************************************************
int GetImage()
{
	int dead=get_property("hippiesDefeated").to_int();
		
	switch
	{
		case dead<3: return 0; break;
		case dead<9: return 1; break;
		case dead<17: return 2; break;
		case dead<28: return 3; break;
		case dead<40: return 4; break;
		case dead<52: return 5; break;
		case dead<64: return 6; break;
		case dead<80: return 7; break;
		case dead<96: return 8; break;
		case dead<114: return 9; break;
		case dead<132: return 10; break;
		case dead<152: return 11; break;
		case dead<172: return 12; break;
		case dead<192: return 13; break;
		case dead<224: return 14; break;
		case dead<258: return 15; break;
		case dead<294: return 16; break;
		case dead<332: return 17; break;
		case dead<372: return 18; break;
		case dead<414: return 19; break;
		case dead<458: return 20; break;
		case dead<506: return 21; break;
		case dead<556: return 22; break;
		case dead<606: return 23; break;
		case dead<658: return 24; break;
		case dead<711: return 25; break;
		case dead<766: return 26; break;
		case dead<822: return 27; break;
		case dead<880: return 28; break;
		case dead<939: return 29; break;
		case dead<999: return 30; break;
		case dead==999: return 31; break;
		case dead>=1000: return 32; break;
	}
	return 0;
}

//Hero Farmer Main
//******************************************************************************
void HeroFarmer(monster foe, string url)
{
	if(get_property("warProgress")== "started")
	{	
		int hippyimage=GetImage();
		print("You Landed on image "+hippyimage,"purple");
		
		if(hippyhero[hippyimage] != $monster[none])	// if true, landed on hippy hero image
		{	
			if(!hippydead[hippyimage] && !IsHero(foe)) //not a hero, cleesh enemy so counter does not advance
			{					
				print("Hero CCS is looking for:  "+to_string(hippyhero[hippyimage]),"blue");
				int count=to_int(get_property("_"+to_string(hippyimage)+"hippyCLEESH"));
				if(count<=TurnsWasted)
				{
					print("Did not encounter "+to_string(hippyhero[hippyimage])+" so will ClEESH this bad guy and try again","blue");
					url= try_skill(url,$skill[CLEESH]);
					set_property("_"+to_string(hippyimage)+"hippyCLEESH" , count+1);
				}
				else
				{
					if(!IsHero(foe))
						print("Could not find "+to_string(hippyhero[hippyimage])+" in "+to_string(TurnsWasted)+" turns, moving on to the next image","blue");
				}
			}
		}
			
		if (hippyimage>=30 && hippyimage<32)
		{
			int count=to_int(get_property("_"+to_string(hippyimage)+"hippyCLEESH"));
			boolean cleeshed=false;
			
			foreach hero in hippydead
			{
				if (hippydead[hero]==false)
					print("Hero CCS is looking for:  "+to_string(hippyhero[hero]),"blue");
			}

			foreach hero in hippydead
			{
				if (!cleeshed && hippydead[hero]==false && !IsHero(foe) && count<=FinalFarming)
				{					
					print("Did not encounter "+to_string(hippyhero[hero])+" so will ClEESH this bad guy and try again","blue");
					url= try_skill(url,$skill[CLEESH]);	
					set_property("_"+to_string(hippyimage)+"hippyCLEESH" , count+1);
					cleeshed=true;
				}
				else
				{	
					if(!cleeshed && hippydead[hero]==false && !IsHero(foe))
						print("Could not find "+to_string(hippyhero[hero])+" in "+to_string(FinalFarming)+" turns, moving on to the next image","blue");
				}				
			}					
		}
		
		if(hippyimage>30)
		{
			boolean [monster] log;
			foreach entry in hippyhero
				log[hippyhero[entry]]=hippydead[entry];
			
			map_to_file(log, my_name()+"HippyHeroFarmer"+today_to_string()+".txt");		
		}
	}
}

//Version Check Funcion --property added to check once a day
//******************************************************************************
boolean CheckVersion(string file, int version, string Extension, string URL)
{
	if(get_property("_"+file) != "good" && get_property("_"+file) != "bad")
	{
		print("Checking Version...","blue");
		
		if (contains_text(visit_url(URL),(to_string(version)+Extension) )) 
		{
			print("You are up to date on this project! <"+file+">","green");
			set_property("_"+file , "good");
			return true;
		}
		else
		{
			print_html("<FONT color=#c00000><B>This script version is not up to date!</B></FONT><br /><FONT color=#4f6228>~"+file+"~</FONT>");
			print_html("<FONT color=#c00000>Please check </FONT><U><FONT color=#0000ff><A HREF="+URL+">"+URL+"</A></U></FONT><FONT color=#c00000> for updates!</Font><br /><br />");
			set_property("_"+file , "bad");
			return false;
		}
	}
	
	if (get_property("_"+file) == "bad")
		print("You are not up to date on this project! Please check:  "+URL,"red");
	
	return true;
}

//Main
//******************************************************************************
void main(int initround, monster foe, string url)
{
   CheckVersion(HCCSFile, HCCSversion, HCCSverExtension, HCCSURL);
   HeroFarmer(foe,url);
}   
   