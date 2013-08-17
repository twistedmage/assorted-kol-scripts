

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}
buffer results;
	results.append(visit_url());
	
	string dungeon = "<br>You have "+item_amount($item[skeleton bone])+" skeleton bone(s) and "+item_amount($item[loose teeth])+" loose teeth.";
	dungeon = dungeon + "<font size=1>[<a href='Kolmafia/sideCommand?cmd=make skeleton key&pwd="+my_hash()+"'>make skeleton key</a>]</font>";
	
	results.replace_string("locked door.", "locked door. "+dungeon);
	results.write();
