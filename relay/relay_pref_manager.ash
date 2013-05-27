script "relay_pref_manager.ash"
notify "That FN Ninja"
import <htmlform.ash> // htmlform by Jason Harper - http://kolmafia.us/showthread.php?3842
/*
This is a relay KoLmafia preference manager created by That FN Ninja

Special thanks to:
Jason Harper for htmlform.ash

add a filter or search box
change delete button to a reset button

needs special handleing
	breakfastHardcore
	breakfastSoftcore
	chatFontSize
*/
string version = "v0.2";
string download = "";
//default[type (global or user), property]
string [string, string] prefs; 
file_to_map("defaults.txt", prefs); 

// add_java function prototypes
void add_java_toggle();
void add_java_toggledesc();
void add_java_filter();

boolean button_failed(string name){
	return fields contains name && !success;
}

void write_kolbox(string title, string bgcolor){
	writeln("<center><table width=95% cellspacing=0 cellpadding=0><tr><td align=center bgcolor=" + bgcolor + "><b>");
	writeln("<font color=white>" + title + "</font>");
	writeln("</b></td></tr><tr><td style='padding: 5px; border: 1px solid " + bgcolor + ";'><center><table><tr><td>");
}
void write_kolbox(string title){ write_kolbox(title, "blue"); }

void finish_kolbox(){
	writeln("</td></tr></table></td></tr><tr><td height=4></td></tr></table>");
}

// modified version of Zarqon's check_version function
void check_version(){
   switch (get_property("_version_prefMan")){
      case version: return;
      case "":
         matcher find_ver = create_matcher("<b>KoLmafia Preference Manager (.+?)</b>", visit_url(download)); 
         if(!find_ver.find()) return;
         set_property("_version_prefMan", find_ver.group(1));
         if(find_ver.group(1) == version) return;
      default:
         writeln("<tr><td align=center><font color=red>New Version of KoLmafia Preference Manager Available: " + get_property("_version_prefMan") + "</font>");
         writeln("<br><a href='" + download + "'>Download the latest version here.</a></td></tr><tr><td height=4></td></tr>");
   }
}

void main(){   
	write_header();
	writeln("<link href='http://images.kingdomofloathing.com/styles.css' type='text/css' rel='stylesheet'/>");
	add_java_toggle();
	add_java_toggledesc();
	add_java_filter();
	finish_header();

	// the intro box
	writeln("<a name='top'></a>");
	write_kolbox("KoLmafia &nbsp;Preference Manager &nbsp;" + version, "black");
	writeln("<center><table><tr>");
	writeln("<td align=left style='padding-right: 100px'><a href='showplayer.php?who=1933157'><img src=http://images.kingdomofloathing.com/otherimages/sigils/ninja.gif alt='That FN Ninja' border=0></a></td>");
	writeln("<td><table><tr><td align=center>This is a preference manager for editing all your KoLmafia preferences.</td></tr><tr><td height=4></td></tr>");
	check_version();
	writeln("<tr><td align=center><input type='text' name='filter' id='filter'>&nbsp;&nbsp;<input class='button' type='button' name='filter_button' value='Filter Preferences' onclick='filter_prefs()'>");
	writeln("&nbsp;<input class='button' type='button' name='filter_clear' value='Clear Filter' onclick='document.getElementById(\"filter\").value = \"\"; filter_prefs()'></td></tr><tr><td height=4></td></tr>");	
	writeln("<tr><td align=center><input class='button' type='button' name='desc_button' value='Show/Hide Descriptions' onclick='toggle_descriptions()'>&nbsp;");
	attr("class='button'");
	write_button("save", "Save Changes");
	writeln("&nbsp;&nbsp;<input class='button' type='button' name='cancel' value='Cancel' onclick='location.href=\"" + __FILE__ + "\"'></td></tr></table></td>");
	writeln("<td align=right style='padding-left: 100px'><a href='showplayer.php?who=1933157'><img src=http://images.kingdomofloathing.com/otherimages/sigils/ninja.gif alt='That FN Ninja' border=0></a></td>");
	writeln("</tr></table></center>");	
	finish_kolbox();
	
	// the result_success box
	writeln("<div id='result_success' style='display: none;'><center><table width=95% cellspacing=0 cellpadding=0><tr><td align=center bgcolor=green>");
	writeln("<b><font color=white>Green Exclamation Points!</font></b></td></tr><tr><td style='padding: 5px; border: 1px solid green;'><center><table><tr><td>");
	writeln("Settings saved successfully!! Sweet!</td></tr></table></center></td></tr><tr><td height=4></td></tr></table></center></div>");
	
	// the result_fail box
	writeln("<div id='result_fail' style='display: none;'><center><table width=95% cellspacing=0 cellpadding=0><tr><td align=center bgcolor=red>");
	writeln("<b><font color=white>Red Exclamation Points!</font></b></td></tr><tr><td style='padding: 5px; border: 1px solid red;'><center><table><tr><td>");
	writeln("<b>WARNING:</b> Save failed! Check preferences for error messages.</td></tr></table></center></td></tr><tr><td height=4></td></tr></table></center></div>");	
	
	write_kolbox("Kolmafia Preferences:");
	writeln("<table id='settings'>");	
	
	foreach type, setting, def in prefs{
		writeln("<tbody id='" + setting + "_settb'>");
	
		writeln("<tr id='" + setting + "'><td valign=top width=300><b>");
		write_label(setting, setting + "</b>");
		writeln("<br><font size=1>[reset?!]");	// add href
		writeln("&nbsp;&nbsp;<a href=\"javascript:toggle('" + setting + "_desc')\">[show/hide description]</a></font><br></td>");
		writeln("<td valign=top'>");
		
		if(def == "false" || def == "true")
			set_property(setting, write_check(get_property(setting).to_boolean(), setting, "").to_string());
		else{
			attr("size=50");
			set_property(setting, write_field(get_property(setting), setting, ""));
		}
		writeln("</td></tr>");
		
		writeln("<tr id='" + setting + "_desctr'><td colspan=2><div id='" + setting + "_desc' style='display: none;'><div class='tiny helpbox' style='border: 1px solid black; padding: 5px; width: 500px;'>");
		// parse mafia wiki for preference documentation
		writeln("No description available.");
		writeln("</div></div></td></tr></tbody>");
	}
	writeln("</table><div style='text-align:center;'><br><table><tr><td>");
	writeln("<input class='button' type='button' name='desc_button' value='Show/Hide Descriptions' onclick='toggle_descriptions()'>");
	writeln("</td><td>&nbsp;&nbsp;&nbsp;</td><td>");
	attr("class='button'");
	if(write_button("save", "Save Changes")){
		//vprint("KoLmafia Preference Manager:", "66666", 6);	
		//vprint("Changes saved on " + today_to_string(), "66666", 6);
		writeln("<script language='javascript'>toggle('result_success');</script>");	
	}
	writeln("</td><td>&nbsp;&nbsp;&nbsp;</td><td>");
	writeln("<input class='button' type='button' name='cancel' value='Cancel' onclick='location.href=\"" + __FILE__ + "\"'>");
	writeln("</td></tr></table></div>");
		
	// if there was an error during the submit ensure that the settings queued for deletion still show up that way and show the results fail message
	if(button_failed("save")){	
		writeln("<script language='javascript'>toggle('result_fail');</script>");
	}
	
	finish_kolbox();
	
	// for debug
	/*
	writeln(count(fields));
	foreach thing, value in fields
		writeln(thing + " = " + value + "<br>");
	writeln("<br><br>" + success);
	*/
	
	finish_page();
}

#---------- Custom Validators -------------------#

#---------------- Java Functions --------------------#

// toggle element
void add_java_toggle(){
	writeln("<script type='text/javascript' language='javascript'>");
	writeln("function toggle(id){");
    writeln("	var element = document.getElementById(id);");
    writeln("	if(element.style.display == 'inline')");
    writeln("		element.style.display = 'none';");
	writeln("	else element.style.display = 'inline';");
	writeln("}");	
    writeln("</script>");
}

// toggle descriptions
void add_java_toggledesc(){
	writeln("<script type='text/javascript' language='javascript'>");
	writeln("function toggle_descriptions(){");
	writeln("	var desc_vis = document.getElementsByTagName('div');");
	writeln("	var vis, first;");
	writeln("	for(i = 0; i < desc_vis.length; i++){");
	writeln("		if(desc_vis[i].id.indexOf('_desc') > 0){");		
	writeln("			first = desc_vis[i];");
	writeln("			break;");	
	writeln("		}");		
	writeln("	}");	
	writeln("	if(first.style.display == 'none')");
	writeln("		vis = 'inline';");	
	writeln("	else vis = 'none';");	
	writeln("	for(i = 0; i < desc_vis.length; i++)");	
	writeln("		if(desc_vis[i].id.indexOf('_desc') > 0)");	
	writeln("			desc_vis[i].style.display = vis;");
	writeln("}");
	writeln("</script>");
}

// filter preferences
void add_java_filter(){
	writeln("<script type='text/javascript' language='javascript'>");	
	writeln("function filter_prefs(){");
	writeln("	var filter = document.getElementById('filter').value.toLowerCase();");
	writeln("	var settings = document.getElementById('settings').getElementsByTagName('tbody');");
	writeln("	for(i = 0; i < settings.length; i++){");	
	writeln("		if(settings[i].id.toLowerCase().indexOf(filter) >= 0)");		
	writeln("			settings[i].style.display = 'block';");
	writeln("		else settings[i].style.display = 'none';");	
	writeln("	}");	
	writeln("}");
	writeln("</script>");
}

