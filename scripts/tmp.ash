void main()
{
	string fax = visit_url("desc_item.php?whichitem=835898159");
	if (!contains_text(fax, "This is a sheet of copier paper"))
		abort("a");
	if (contains_text(fax, "grainy, blurry likeness of a monster on it."))
		abort("b");

	matcher mon_match = create_matcher("blurry likeness of an? (.*) on it",fax);
	find(mon_match);
	print(group(mon_match,1));
/*
	string ingredient="furry fur";
	int req_ing=10;
	string html=visit_url("clan_viplounge.php?action=hotdogstand");
	matcher hotdog_mtch = create_matcher("title=\\\""+ingredient+"\\\"></td><td><b>x "+req_ing+"</b></td><td class=tiny>\\((\\d*)",html);
	hotdog_mtch.find();
	print("out="+hotdog_mtch.group(1));*/
}