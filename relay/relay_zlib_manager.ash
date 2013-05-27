script "relay_zlib_manager.ash"
import <zlib.ash>
import <htmlform.ash> // htmlform by Jason Harper - http://kolmafia.us/showthread.php?3842
/*
This is the variable manager for Zarqon's zlib.ash function library. 
Created by That FN Ninja

Special thanks to:
Zarqon for zlib and all the other wonderful resources he's contributed to the KoLmafia community.
Jason Harper for htmlform.ash
Heeheehee for the original zlib variable editor which was used as a starting point for this one.
*/

// add a hidden field for the filter value so the current filter results can be kept after saving
// add a filter by script name option
// possibly add a delete all script specific variables button
// possibly add a delete ALL vars button

string version = "v0.3";
string download = "http://kolmafia.us/showthread.php?4537";

record{
   string type;    // setting type
   string doc;     // documentation
   string scripts; // comma-delimited list of scripts that reference the variable
}[string] vardoc;
file_to_map("vars_documentation.txt", vardoc);  
//load_current_map("vars_documentation.txt", vardoc);

// remove obsoleted variables
foreach setting in vardoc
	if(vardoc[setting].doc.contains_text("_obsolete_"))
		remove vars[setting];

string[string] boss_map;
boss_map["Baron von Ratsworth"] = "ratsworth";
boss_map["The Boss Bat"] = "boss bat";
boss_map["The Goblin King"] = "goblin king";
boss_map["The Bonerdagon"] = "bonerdagon";
boss_map["Lord Spookyraven"] = "spookyraven";
boss_map["Dr. Akward"] = "akward";
boss_map["Ed the Undying"] = "undying";
boss_map["The Man / Big Wisniewski"] = "isle boss";
boss_map["Your Shadow"] = "shadow";
boss_map["The Naughty Sorceress"] = "sorceress";
boss_map["Your Nemesis (in the cave)"] = "nemesis cave";
boss_map["The Clownlord Beelzebozo"] = "beelzebozo";

// Jason Harper's write_choice function overloaded to accept a custom validator
int write_choice(int ov, string name, string label, boolean[int] vals, string validator);

// add_java function prototypes
void add_java_toggle();
void add_java_toggledesc();
void add_java_checkall();
void add_java_deletevar();
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
   switch (get_property("_version_ZlibVarMan")){
      case version: return;
      case "":
         matcher find_ver = create_matcher("<b>Zlib Variable Manager (.+?)</b>", visit_url(download)); 
         if(!find_ver.find()) return;
         set_property("_version_ZlibVarMan", find_ver.group(1));
         if(find_ver.group(1) == version) return;
      default:
         writeln("<tr><td align=center><font color=red>New Version of Zlib Variable Manager Available: " + get_property("_version_ZlibVarMan") + "</font>");
         writeln("<br><a href='" + download + "'>Download the latest version here.</a></td></tr><tr><td height=4></td></tr>");
   }
}

void main(){   
	write_header();
	writeln("<link href='http://images.kingdomofloathing.com/styles.css' type='text/css' rel='stylesheet'/>");
	add_java_toggle();
	add_java_toggledesc();
	add_java_checkall();
	add_java_deletevar();
	add_java_filter();	
	finish_header();

	// the intro box
	writeln("<a name='top'></a>");
	write_kolbox("<a class='nounder' href='" + download + "'><font color=white>Zlib &nbsp;Variable Manager &nbsp;" + version + "</font></a>", "black");
	writeln("<center><table><tr>");
	writeln("<td align=left style='padding-right: 100px'><a href='showplayer.php?who=1933157'><img src=http://images.kingdomofloathing.com/otherimages/sigils/ninja.gif alt='That FN Ninja' border=0></a></td>");
	writeln("<td><table><tr><td align=center>This is the <a href='http://kolmafia.us/showthread.php?2072&p=15167&viewfull=1#post15167'>variable</a> manager for <a href='showplayer.php?who=1406236'>Zarqon</a>'s");
	writeln("<a href='http://kolmafia.us/showthread.php?2072'>zlib.ash</a> function library.</td></tr><tr><td height=4></td></tr>");
	check_version();
	writeln("<tr><td align=center><input type='text' name='filter' id='filter'>&nbsp;&nbsp;<input class='button' type='button' name='filter_button' value='Filter Variables' onclick='filter_vars()'>");
	writeln("&nbsp;<input class='button' type='button' name='filter_clear' value='Clear Filter' onclick='document.getElementById(\"filter\").value = \"\"; filter_vars()'></td></tr><tr><td height=4></td></tr>");	
	writeln("<tr><td align=center><input class='button' type='button' name='desc_button' value='Show/Hide Descriptions' onclick='toggle_descriptions()'>&nbsp;");
	attr("class='button'");
	write_button("save", "Save Changes");
	writeln("&nbsp;&nbsp;<input class='button' type='button' name='cancel' value='Cancel' onclick='location.href=\"" + __FILE__ + "\"'></td></tr></table></td>");
	writeln("<td align=right style='padding-left: 100px'><a href='http://zachbardon.com/mafiatools/bats.php'><img src=http://images.kingdomofloathing.com/adventureimages/stabbats.gif alt='Bat King' border=0></a></td>");
	writeln("</tr></table></center>");	
	finish_kolbox();
	
	// the result_success box
	writeln("<div id='result_success' style='display: none;'><center><table width=95% cellspacing=0 cellpadding=0><tr><td align=center bgcolor=green>");
	writeln("<b><font color=white>Green Exclamation Points!</font></b></td></tr><tr><td style='padding: 5px; border: 1px solid green;'><center><table><tr><td>");
	writeln("Settings saved successfully!! Sweet!</td></tr></table></center></td></tr><tr><td height=4></td></tr></table></center></div>");
	
	// the result_fail box
	writeln("<div id='result_fail' style='display: none;'><center><table width=95% cellspacing=0 cellpadding=0><tr><td align=center bgcolor=red>");
	writeln("<b><font color=white>Red Exclamation Points!</font></b></td></tr><tr><td style='padding: 5px; border: 1px solid red;'><center><table><tr><td>");
	writeln("<b>WARNING:</b> Save failed! Check variables for error messages.</td></tr></table></center></td></tr><tr><td height=4></td></tr></table></center></div>");	
	
	write_kolbox("Variables:");
	writeln("<table id='settings'>");	
	
	foreach setting in vars{
		writeln("<tbody id='" + setting + "_settb'>");
	
		attr("id='" + setting + "_del'");
		write_hidden("", setting + "_delete");
	
		writeln("<tr id='" + setting + "_qd' style='display: none;'><td valign=top colspan=2><i>" + setting + " queued for deletion...</i></td></tr>");
	
		writeln("<tr id='" + setting + "_tr'><td valign=top width=300><b>");
		write_label(setting, setting + "</b>");
		writeln("<br><font size=1><a href=\"javascript:delete_var('" + setting + "_del')\">[delete?!]</a>");
		writeln("&nbsp;&nbsp;<a href=\"javascript:toggle('" + setting + "_desc')\">[show/hide description]</a></font><br>");
		writeln("</td><td valign=top>");
	  
		if(setting == "is_100_run" || setting.contains_text("ocw_f_")){
			vars[setting] = write_select(vars[setting], setting, "");
			write_option("(select familiar)", "");
			write_option("none");
			foreach fam in $familiars[]
				if(have_familiar(fam)) write_option(fam.to_string());
			finish_select();
		}

		else if(setting == "aq_fight_bosses"){
			writeln("<div id='boss_checkboxes'><table>");
			foreach boss, keyword in boss_map{
				writeln("<tr><td>");
				write_check(vars[setting].to_lower_case().contains_text(keyword), boss, "");
				writeln("</td><td>" + boss + "</td></tr>");
			}
			writeln("<tr><td colspan=2>&nbsp;<font size=2><a href='javascript:toggle_all_checkboxes(\"boss_checkboxes\")'>[select/deselect all bosses]</a></font></td></tr>");
			writeln("</table></div>");
			
			string boss_list;
			foreach boss, keyword in boss_map{
				if(fields contains boss && fields[boss] == "on"){
					if(length(boss_list) == 0)
						boss_list += keyword;
					else boss_list += ", " + keyword;
				}
			}
			vars[setting] = boss_list;			
		}

		else if(setting.contains_text("aq_mcd"))
			vars[setting] = write_choice(vars[setting].to_int(), setting, "", $ints[-1,0,1,2,3,4,5,6,7,8,9,10,11], "mcd11validator");
		
		else if(vars[setting] == "false" || vars[setting] == "true")
			vars[setting] = write_check(vars[setting].to_boolean(), setting, "").to_string();
			
		else if(vars[setting].is_integer() && vars[setting].to_int().to_string() == vars[setting]){
			attr("size=11");
			vars[setting] = write_field(vars[setting].to_int(), setting, "", "intvalidator");
		}
		
		else if(vars[setting].replace_string(".", "").is_integer() && vars[setting].to_float().to_string()== vars[setting]){
			attr("size=11");
			vars[setting] = write_field(vars[setting].to_float(), setting, "", "floatvalidator");
		}
			
		else{
			attr("size=50");
			string validator = "";
			if(setting.contains_text("ftf_")) 
				validator = "monsterlistvalidator";
				
			vars[setting] = write_field(vars[setting], setting, "", validator);
		}
		writeln("</td></tr>");
		
		writeln("<tr id='" + setting + "_desctr'><td colspan=2><div id='" + setting + "_desc' style='display: none;'><div class='tiny helpbox' style='border: 1px solid black; padding: 5px; width: 500px;'>");
		if(vardoc contains setting && vardoc[setting].doc.length() > 0)
			writeln(vardoc[setting].doc);
		else writeln("No description available.");
		writeln("</div></div></td></tr></tbody>");
	}
	writeln("</table>"); // end settings table
	
	writeln("<div style='text-align:center;'><br><table><tr><td>");
	writeln("<input class='button' type='button' name='desc_button' value='Show/Hide Descriptions' onclick='toggle_descriptions()'>");
	writeln("</td><td>&nbsp;&nbsp;&nbsp;</td><td>");
	attr("class='button'");
	if(write_button("save", "Save Changes")){
		vprint("Zlib Variable Manager:", "66666", 6);
		// delete any variables set for deletion
		foreach setting in vars{
			if(fields[setting + "_delete"] == "del"){
				writeln("<script language='javascript'>delete_persist('" + setting + "_del', false);</script>");
				vprint("Removing " + setting + " from your ZLib variables...", 6);
				remove vars[setting];
			}
		}
		
		if(map_to_file(vars, "vars_" + replace_string(my_name(), " ", "_") + ".txt"))
			vprint("Changes saved on " + today_to_string(), "66666", 6);
		writeln("<script language='javascript'>toggle('result_success');</script>");
	}
	writeln("</td><td>&nbsp;&nbsp;&nbsp;</td><td>");
	writeln("<input class='button' type='button' name='cancel' value='Cancel' onclick='location.href=\"" + __FILE__ + "\"'>");
	writeln("</td></tr></table></div>");
		
	// if there was an error during the submit ensure that the settings queued for deletion still show up that way and show the results fail message
	if(button_failed("save")){
		foreach setting in vars
			if(fields[setting + "_delete"] == "del")
				writeln("<script language='javascript'>delete_persist('" + setting + "_del', true);</script>");		
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

// heeheehee's monster map validator
string monsterlistvalidator(string name){
	string[int] list = split_string(fields[name], ", ");
	foreach key, entry in list
		if(entry.to_monster() == $monster[none]) 
			return "<br>Invalid list of monsters! <b>" + entry + "</b> is not a monster.";
	return "";
}

string mcd11validator(string name){
	if(to_int(fields[name]) == 11 && !in_mysticality_sign() && !in_bad_moon())
		return "Only characters under a mysticality or bad moon sign can set the MCD to 11.";
	return "";
}

// Jason Harper's write_choice function overloaded to accept a custom validator
int write_choice(int ov, string name, string label, boolean[int] vals, string validator){
	ov = write_select(ov, name, label);
	foreach val, bool in vals if(bool) write_option(val);
	finish_select();
	string err;
	int rv = ov;
	if(fields contains name){
		if(validator != "")
			err = call string validator(name);
		rv = fields[name].to_int();
	}
	if(err != ""){
		success = false;
		rv = ov;
		write("<font color='red'>");
		write(err);
		writeln("</font>");
	}	
	return rv;
}

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

// toggle all checkboxes in a particular area
void add_java_checkall(){
	writeln("<script type='text/javascript' language='javascript'>");
	writeln("function toggle_all_checkboxes(id){");
	writeln("	var check_boxes = document.getElementById(id).getElementsByTagName('input');");
	writeln("	var val;");
	writeln("	if(check_boxes[0].checked == 0)");
	writeln("		val = 1;");
	writeln("	else val = 0;");		
	writeln("	for(var i = 0; i < check_boxes.length; i++) check_boxes[i].checked = val;");
	writeln("}");
	writeln("</script>");
}

void add_java_deletevar(){
	writeln("<script type='text/javascript' language='javascript'>");
	writeln("function delete_var(id){");
	writeln("	var delete_this = id.substring(0, id.length - 4);");	
	writeln("	var response = confirm('Delete ' + delete_this + '!?');");
	writeln("	if(response){");
	writeln("		document.getElementById(id).value = 'del';");
	writeln("		document.getElementById(delete_this + '_tr').style.display = 'none';");
	writeln("		delete_this += '_qd';");
	writeln("		document.getElementById(delete_this).style.display = 'inline';");
	writeln("		delete_this = id.substring(0, id.length - 4) + '_desc';");
	writeln("		document.getElementById(delete_this).style.display = 'none';");	
	writeln("	}");
	writeln("}");
	writeln("function delete_persist(id, queue){");
	writeln("	var delete_this = id.substring(0, id.length - 4);");	
	writeln("	document.getElementById(delete_this + '_tr').style.display = 'none';");
	writeln("	delete_this += '_qd';");
	writeln("	if(queue) document.getElementById(delete_this).style.display = 'inline';");
	writeln("	else document.getElementById(delete_this).style.display = 'none';");
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
	writeln("		var is_desc = desc_vis[i].id.indexOf('_desc');");	
	writeln("		if(is_desc > 0 && document.getElementById(desc_vis[i].id.substring(0, desc_vis[i].id.length - 5) + '_qd').style.display != 'inline'){");		
	writeln("			first = desc_vis[i];");
	writeln("			break;");	
	writeln("		}");		
	writeln("	}");	
	writeln("	if(first.style.display == 'none')");
	writeln("		vis = 'inline';");	
	writeln("	else vis = 'none';");	
	writeln("	for(i = 0; i < desc_vis.length; i++){");
	writeln("		var is_desc = desc_vis[i].id.indexOf('_desc');");		
	writeln("		if(is_desc > 0 && document.getElementById(desc_vis[i].id.substring(0, desc_vis[i].id.length - 5) + '_qd').style.display != 'inline')");	
	writeln("			desc_vis[i].style.display = vis;");
	writeln("	}");	
	writeln("}");
	writeln("</script>");
}

// filter variables
void add_java_filter(){
	writeln("<script type='text/javascript' language='javascript'>");	
	writeln("function filter_vars(){");
	writeln("	var filter = document.getElementById('filter').value.toLowerCase();");
	writeln("	var settings = document.getElementById('settings').getElementsByTagName('tbody');");	
	writeln("	for(i = 0; i < settings.length; i++){");		
	writeln("		var is_match = settings[i].id.toLowerCase().indexOf(filter);");	
	writeln("		if(is_match >= 0 && settings[i].id.toLowerCase().indexOf('_qd') == -1)");		
	writeln("			settings[i].style.display = 'block';");
	writeln("		else settings[i].style.display = 'none';");
	writeln("	}");	
	writeln("}");
	writeln("</script>");
}
