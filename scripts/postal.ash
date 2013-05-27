

import <canadv.ash>;
import <zlib.ash>;

string [int] questlogs;
string [int] locations;
int start=26;
int a;
string questscreen;

void doquest(string place,string whattoget)
{
boolean done=false;
while (!done)
	{
	adv1(place.to_location(),-1,"");
	if (contains_text(visit_url("questlog.php?which=1"),whattoget))
		done=true;
	}
}

void main()
{
questscreen=visit_url("questlog.php?which=1");
if (!in_moxie_sign())
	abort("You didn't ascend under a moxie sign: you won't be able to complete the quest during this ascension");
if (!contains_text(visit_url("questlog.php?which=2"),"You've built a new meat car from parts. Impressive!"))
	abort("You don't have a meatcar yet. Complete the relative guild quest.");
if (my_inebriety()>inebriety_limit())
	abort("You are too drunk to complete the complete the quest.");
load_current_map("postal_questlogs",questlogs);
load_current_map("postal_locations",locations);
print("Determining current quest advancement...");
visit_url("gnomes.php?place=elder");
foreach x in questlogs
	{
	if (contains_text(questscreen,questlogs[x]))
		{
		print("Match found.");
		start=x;
		print("You currently are at step "+start);
		}
	}
if (start>25)
		abort("You already completed the quest.");
for a from start to 25
	{
	if ((!can_adv(locations[a].to_location(),false)) && (a!=5) && (a!=21))
		abort("You cannot currently adventure at "+locations[a]+". You cannot complete the quest");
	}
if (my_adventures()<(26-start))
	abort("You don't have enough adventures left to complete the quest");
if ((string_modifier("Outfit")=="Filthy Hippy Disguise") && (start<=17))
	abort("You cannot complete the quest while wearing the filthy hippy disguise. Wear something else.");
for a from start to 25
	doquest(locations[a],questlogs[a+1]);
print("Quest completed.","blue");
visit_url("gnomes.php?place=elder");
}