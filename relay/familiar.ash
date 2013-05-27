import </relay/familiar_hatrack.ash>;
float[familiar,string] mapfam;
file_to_map("famkills.txt",mapfam);

string secondpass(string fams, familiar tourguide, float killtotal, float lifetimetotal)
{
foreach i in $familiars[]
{
	string locater;
	string fam = to_string(i);
	matcher findfam = create_matcher("pound " + fam + " \\([\\d,]* (exp(erience)?|candies), [\\d,]* kills?\\)",fams);
	if (find(findfam))
	{
		locater = substring(fams,0,end(findfam));
		fams = substring(fams,end(findfam));
	}
	else
		continue;
	matcher findkills = create_matcher("([\\d,]* kills?\\))$",locater);
	float kills;
	if (find(findkills))
		kills = to_float(substring(locater,start(findkills),end(findkills)-6));
	if (i == $familiar[bandersnatch])
		kills += to_int(get_property("totalBanderRunaways"));
	float previouskills = to_float(mapfam[i,my_name()]);
	float percentage;
	if (killtotal != 0)
		percentage = to_float(truncate(((kills - previouskills)/killtotal)*10000))/100;
	float lifetime = to_float(truncate((kills/lifetimetotal)*10000))/100;
	string add;
	string add2;
	string add3;
	if ((tourguide == i) && (killtotal != 0))
	{
		if (percentage < 90.0)
		{
			add = "<font color=red> ";
			add3 = ceil((9*killtotal)-(10*(kills-previouskills))) + " combats remaining until 90%.";
		}
		else if (percentage < 91.0)
			add = "<font color=orange> ";
		else if (percentage == 100.0)
			add = "<font color=00FF00> ";
		else
			add = "<font color=green> ";
		if (percentage > 90.0)
			add3 = "You have a safety margin of " + floor(((kills-previouskills)/0.9) - killtotal) + " combats.";
		add2 = "</font>";
	}
	else
		add = " ";
	if (percentage != 0.0)
		locater += add + percentage + "% " + add2;
	if (lifetime != 0.0)
		locater += "<font size=1> \(" + lifetime + "%\)</font>";
	locater += fams;
	fams = locater;
	matcher current = create_matcher("pound " + fam,fams);
	if ((find(current)) && (to_familiar(fam) == tourguide) && (add3 != ""))
	{
		matcher afteradd = create_matcher("<table><tr><td valign=center>Equipment:",fams);
		if (find(afteradd))
		{
			locater = substring(fams,0,start(afteradd));
			fams = substring(fams,start(afteradd));
		}
		else
		{
			matcher afteradd2 = create_matcher("<p><form name",fams);
			if (find(afteradd2))
			{
				locater = substring(fams,0,start(afteradd2));
				fams = substring(fams,start(afteradd2));
			}
		}
		locater += "<table><tr><td valign=center>Tourguide status: " + add3 + "</td></tr></table>" + fams;
		fams = locater;
	}
/*
	if (tourguide == i)
	{
		matcher refind = create_matcher(to_int(to_familiar(fam)) + "\\&pwd=[\\w]*\">\\[take with you\\]</a></font>",fams);
		if (find(refind))
		{
			locater = substring(fams,0,end(refind));
			fams = substring(fams,end(refind));
		}
		locater += add3 + fams;
		fams = locater;
	}
*/
}
return fams;
}

string firstpass(string fams)
{
float killtotal;
float lifetimetotal;
familiar tourguide;
float tourkills;
foreach i in $familiars[]
{
	string locater;
	string fam = to_string(i);
	matcher findfam = create_matcher("pound " + fam + " \\([\\d,]* (exp(erience)?|candies), [\\d,]* kills?\\)",fams);
	if (find(findfam))
		locater = substring(fams,0,end(findfam));
	else
		continue;
	matcher findkills = create_matcher("([\\d,]* kills?\\))$",locater);
	float currentkills;
	if (find(findkills))
		currentkills = to_float(substring(locater,start(findkills),end(findkills)-6));
	float previouskills = to_float(mapfam[i,my_name()]);
	killtotal += (currentkills - previouskills);
	lifetimetotal += currentkills;
	if ((currentkills - previouskills) > tourkills)
	{
		tourguide = i;
		tourkills = (currentkills - previouskills);
	}
}
killtotal += to_int(get_property("totalBanderRunaways")) + to_int(get_property("totalNavelRunaways"));
return secondpass(fams,tourguide,killtotal,lifetimetotal);
}

void familiar_relay()
{
	print("familiar_relay called","blue");
	buffer page; 
//hatrack stuff *******
	if (hatrack_check()) {
		page = hatrack_preaction();
	//} else if (XXX_check()) {
	//	page = XXX_preaction();
	} else {
		page = visit_url();
	}
	page = hatrack_main(page);
	//page = XXX_main(page);

	string fams =page.to_string();
//****************
	fams = firstpass(fams);
	write(fams);
}

void main()
{
	void familiar_relay();
}