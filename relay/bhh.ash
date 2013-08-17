

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}


buffer results;
	results.append(visit_url());
	
	string bhh = "You have a total of <b>"+i_a("filthy lucre")+"</b> <img src='http://images.kingdomofloathing.com/itemimages/lucre.gif' /> Filthy Lucre in all sources.";
	results.replace_string("I only accept filthy lucre.", "I only accept filthy lucre.<b><p><center>"+bhh+"</center></p></b>");
	
	results.write();
