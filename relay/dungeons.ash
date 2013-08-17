

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}
buffer results;
	results.append(visit_url());
	string html = visit_url("http://www.noblesse-oblige.org/calendar/daily_"+today_to_string()+".html"), mid, str = "></a></td><td width=100 height=100></td></tr><tr>";
	
	html = substring(html, 22, index_of(html, "Hermit"));
	print(html);
	
	str = "></a></td><td width=300 height=100>"+html+"</td></tr><tr>";
	
	results.replace_string("></a></td><td width=100 height=100></td></tr><tr>", str);
	results.write();
