/*
	relay_bumcheekascend.ash
	An accessory to bumcheekascend.ash to allow for easy script settings. 
	
	0.1 - Allow to reset quest settings, 
	0.2 - Check the script into SVN and remove non-working version checking

		SIMON LAST UPDATED REVISION 322
*/

script "relay_bumcheekascend.ash";
notify bumcheekcity;

record setting {
	string name;
	string type;
	string description;
	string value;
	string c;
	string d;
	string e;
};

setting[int] s;
string[string] fields;
boolean success;

boolean load_current_map(string fname, setting[int] map) {
	string domain = "http://kolmafia.co.uk/";
	string curr = visit_url(domain + fname + ".txt");
	file_to_map(fname+".txt", map);
	
	//If the map is empty or the file doesn't need updating
	if ((count(map) == 0) || (curr != "" && get_property(fname+".txt") != curr)) {
		print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"' to '"+curr+"'...");
		
		if (!file_to_map(domain + fname + ".txt", map) || count(map) == 0) return false;
		
		map_to_file(map, fname+".txt");
		set_property(fname+".txt", curr);
		print("..."+fname+".txt updated.");
	}
	
	return true;
}

void main() {
	load_current_map("bcsrelay_settings", s);
	fields = form_fields();
	success = count(fields) > 0;
	
	foreach x in fields {
		set_property(x, fields[x]);
	}
	
	writeln("<html><head><title>bumcheekascend.ash Settings 0.1</title></head><body><form action='' method='post'><h1>bumcheekascend Settings Manager 0.1</h1><table><tr><th>Name of Setting</th><th>Value</th><th>Description</th></tr>");
	foreach x in s {
		switch (s[x].type) {
			case "boolean" :
				write("<tr><td>"+s[x].name+"</td><td><select name='"+s[x].name+"'>");
				if (get_property(s[x].name) == "true") {
					write("<option value='true' selected='selected'>true</option><option value='false'>false</option>");
				} else {
					write("<option value='true'>true</option><option value='false' selected='selected'>false</option>");
				}
				writeln("</td><td>"+s[x].description+"</td></tr>");
			break;
			
			default :
				writeln("<tr><td>"+s[x].name+"</td><td><input type='text' name='"+s[x].name+"' value='"+get_property(s[x].name)+"' /></td><td>"+s[x].description+"</td></tr>");
			break;
		}
	}
	writeln("<tr><td colspan='3'><input type='submit' name='' value='Save Changes' /></td></tr></form>");
	writeln("</body></html>");
}
