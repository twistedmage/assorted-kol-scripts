void main()
{
	string ingredient="furry fur";
	int req_ing=10;
	string html=visit_url("clan_viplounge.php?action=hotdogstand");
	matcher hotdog_mtch = create_matcher("title=\\\""+ingredient+"\\\"></td><td><b>x "+req_ing+"</b></td><td class=tiny>\\((\\d*)",html);
	hotdog_mtch.find();
	print("out="+hotdog_mtch.group(1));
}