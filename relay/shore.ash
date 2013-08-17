

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}
buffer results;
	results.append(visit_url());
	
	results.replace_string("Ranch Adventure", "Ranch Adventure  - <i>(Stick of Dynamite - "+item_amount($item[stick of dynamite])+" in inventory)</i>");
	results.replace_string("Island Getaway", "Island Getaway  - <i>(Tropical Orchid - "+item_amount($item[Tropical Orchid])+" in inventory)</i>");
	results.replace_string("Ski Resort", "Ski Resort  - <i>(Barbed-Wire Fence - "+item_amount($item[Barbed-Wire Fence])+" in inventory)</i>");
	
	if (my_level() == 11 && (item_amount($item[forged identification documents]) + item_amount($item[your father's MacGuffin diary])) == 0) {
		results.replace_string("Sail Away!", "WARNING! YOU DO NOT HAVE THE DOCUMENTS!");
	}
	
	results.write();
