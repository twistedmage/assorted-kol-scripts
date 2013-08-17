

int i_a(string name) {
	item i = to_item(name);
	int a = item_amount(i) + closet_amount(i) + storage_amount(i) + display_amount(i);
	return a;
}
buffer results;
	results.append(visit_url());
	
	string js = "function ocean(lonlat) { document.getElementsByName('lon')[0].value=lonlat.substring(0,3);  document.getElementsByName('lat')[0].value=lonlat.substring(3); }";
	results.replace_string("<head>", "<head><script type='text/javascript'>"+js+"</script>");
	
	string option = "<option value='012084'>Muscle</option><option value='023066'>Mysticality</option><option value='022062'>Moxie</option>";
	option = option+"<option value='124031'>shimmering rainbow sand</option><option value='030085'>sinister altar fragment</option>";
	option = option+"<option value='086040'>El Vibrato power sphere</option><option value='063029'>Plinth</option>";
	results.replace_string("m?&quot;", "m?&quot;<br><center><select onchange='javascript:ocean(this.value)'><option></option>"+option+"</select></center>");
	
	results.write();
