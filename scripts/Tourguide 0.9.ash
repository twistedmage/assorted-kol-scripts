/* -------------------------------------------------------------------------------- //
// Tourguide.ash v0.9																//
// Written by Sentrion (#1932869)													//
//																					//
// This script is to be used in conjunction with the relay script familiar.ash.		//
// The relay script will append familiar percentages in your terrarium, which		//
// is particularly useful for tourguide (90%+) runs.								//
//																					//
// Run this script at the beginning of an ascension, and for more accurate			//
// results, at the end of each day.													//
//																					//
// Losses in fights are *not* counted. Therefore, percentages will be slightly off.	//
// Please use familiar.ash only as an estimate.										//
//																					//
// -------------------------------------------------------------------------------- */

script "Tourguide.ash";

string fams = visit_url("familiar.php");

// This will create a file called famkills.txt which records the number of kills all
// your familiars have at the beginning of an ascension, in order to keep track of
// number of kills in the current run alone.
if (my_turncount() == 0)
{
set_property("totalBanderRunaways","");
set_property("totalNavelRunaways","");
float[familiar,string] mapfam;
foreach i in $familiars[]
{
	string locater;
	string fam = to_string(i);
	matcher findfam = create_matcher("pound " + fam + " \\([\\d,]* (exp(erience)?|candies), [\\d,]* kills?\\)",fams);
	if (find(findfam))
		locater = substring(fams,start(findfam),end(findfam));
	else
		continue;
	matcher findfam2 = create_matcher("([\\d,]* kills?\\))$",locater);
	if (find(findfam2))
		locater = substring(locater,start(findfam2),end(findfam2) - 6);
	mapfam[to_familiar(fam),my_name()] = to_float(locater);
}
set_property("totalBanderRunaways",0);
set_property("totalNavelRunaways",0);
map_to_file(mapfam,"famkills.txt");
}

// This should be run at the end of every day. It records the number of runaways used,
// since KoL's familiar combat counter is incremented at the beginning of a fight.
// This can safely be run multiple times per day.
int banderRunaways = to_int(get_property("_banderRunaways"));
int lastBanderRunaways = to_int(get_property("_lastBanderRunaways"));
int navelRunaways = to_int(get_property("_navelRunaways"));
int lastNavelRunaways = to_int(get_property("_lastNavelRunaways"));
int totalBanderRunaways = to_int(get_property("totalBanderRunaways"));
int totalNavelRunaways = to_int(get_property("totalNavelRunaways"));
if (banderRunaways != lastBanderRunaways)
	totalBanderRunaways += (banderRunaways - lastBanderRunaways);
if (navelRunaways != lastNavelRunaways)
	totalNavelRunaways += (navelRunaways - lastNavelRunaways);
lastBanderRunaways = banderRunaways;
lastNavelRunaways = navelRunaways;
set_property("_lastBanderRunaways",lastBanderRunaways);
set_property("_lastNavelRunaways",lastNavelRunaways);
set_property("totalBanderRunaways",totalBanderRunaways);
set_property("totalNavelRunaways",totalNavelRunaways);