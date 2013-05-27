/*
	relay_bumSeMan.ash v0.3
	Originally built to change bumcheekascend settings, bumSeMan (bumcheekcity's Setting's Manager) now supports changing settings for a multitidue of scripts. Or will do.
	
	0.1 - Standard bumcheekascend settings. 
	0.2 - Allow to reset quest settings. Make prettier.
	0.3 - Add support for headers and zLib settings.
*/

script "relay_bumcheekascend.ash";
notify bumcheekcity;

if (index_of(visit_url("http://kolmafia.us/showthread.php?t=5470"), "0.3</b>") == -1) {
	print("There is a new version available - go download the next version of bumcheekascend.ash at http://kolmafia.us/showthread.php?t=5470!", "red");
}

record rec { 
	string d; 
};
record setting {
	string name;
	string type;
	string description;
	string value;
	string c;
	string d;
	string e;
};

setting[int] s, t;
string[string] fields;
boolean success;
string serv, tab;

/******************
* BEGIN FUNCTIONS *
******************/

string head() {
	string r = "<html><head><title>bumSeMan Settings Manager 0.3</title>";
	r += "<style type='text/css'>";
	r += "* { font-family: Verdana; font-size:11px; }";
	r += "th { font-size:14px; font-weight: blue; background-color: red; }";
	r += "input, select, button, textarea {	margin-left: 5px; border: 1px solid gray; }";
	r += "input:focus, select:focus, textarea:focus {	border: 1px solid red; background: #F3F3F4; }";
	r += "</style>";
	r += "</head>";
	return r;
}

void input(string type, string name, string value, string description) {
	switch (type) {
		case "boolean" :
			write("<tr><td>"+name+"</td><td><select name='"+name+"'>");
			if (value == "true") {
				write("<option value='true' selected='selected'>true</option><option value='false'>false</option>");
			} else {
				write("<option value='true'>true</option><option value='false' selected='selected'>false</option>");
			}
			writeln("</td><td>"+description+"</td></tr>");
		break;
		
		case "header" :
			write("<tr><td colspan='2'><h2>"+name+"</h2></td></tr>");
		break;
		
		default :
			writeln("<tr><td>"+name+"</td><td><input type='text' name='"+name+"' value='"+value+"' /></td><td>"+description+"</td></tr>");
		break;
	}
}
void input(string type, string name, string value) { input(type, name, value, "default desciprion"); }

boolean load_current_map(string fname, setting[int] map, string server) {
	print("loading map "+fname+" on server "+server, "purple");
	string curr, domain;

	switch (server) {
		case "bumcheekcity" :
			domain = "http://bumcheekcity.com/kol/maps/";
			curr = visit_url("http://bumcheekcity.com/kol/maps/index.php?name="+fname);
		break;
		
		case "zarqon" :
			domain = "http://zachbardon.com/mafiatools/autoupdate.php?f=";
			curr = visit_url("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getver");
		break;
		
		default :
			abort(fname+"-"+server);
		break;
	}
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

void showForm(setting [int] s) {
	foreach x in s {
		input(s[x].type, s[x].name, get_property(s[x].name), s[x].description);
	}
}
void showForm(string str, string server) {
	rec [string, string] m;
	
	switch (str) {
		case "prefRefChoiceAdv" :
			file_to_map("defaults.txt",m); 
			foreach t,p,d in m {
				if (contains_text(p, "choiceAdventure")) {
					input("text", p, get_property(p), t+" - default '"+d.d+"'");
				}
			}
		break;
		
		case "prefRefGlobal" :
			file_to_map("defaults.txt",m); 
			foreach t,p,d in m {
				if (t == "global") {
					input("text", p, get_property(p), t+" - default '"+d.d+"'");
				}
			}
		break;
		
		case "prefRefOther" :
			file_to_map("defaults.txt",m); 
			foreach t,p,d in m {
				if (!contains_text(p, "choiceAdventure") && t != "global") {
					input("text", p, get_property(p), t+" - default '"+d.d+"'");
				}
			}
		break;
		
		default:
			load_current_map(str, s, server);
			showForm(s);
		break;
	}
}
void showForm(string s) { showForm(s, ""); }

string tabList() {
	string ret;

	load_current_map("bumseman_scripts", t, "bumcheekcity");
	foreach x in t {
		ret += "<li><a href='?tab="+t[x].name+"&server="+t[x].type+"'>"+t[x].description+"</a></li>";
	}
	//print(ret);
	return "<ul>"+ret+"</ul>";
}

void writeTab(string t, string v) {
	write("<li");
	//if(fields[t] == v) write(" class='see'");
	write("><input type='submit' class='nav' name='"+t+ "' value='"+v+"'>");
	writeln("</li>");
}

void main() {
	fields = form_fields();
	success = count(fields) > 0;
	
	foreach x in fields {
		print(x+") "+fields[x]);
		print("test");
		if (x == "tab") {
			tab = fields[x];
			print("Setafting the above");
		} else if (x == "server") {
			serv = fields[x];
			print("Setsting the above");
		} else {
			print("Setting the above");
			set_property(x, fields[x]);
		}
	}
	
	writeln(head()+"<body><form action='' method='post'><h1>bumSeMan Settings Manager 0.3</h1>"+tabList()+"<table><tr><th>Name of Setting</th><th>Value</th><th>Description</th></tr>");
	
	if (tab != "") showForm(tab, serv);
	
	writeln("<tr><td colspan='3'><input type='submit' name='' value='Save Changes' /></td></tr></form>");
	writeln("</body></html>");
}