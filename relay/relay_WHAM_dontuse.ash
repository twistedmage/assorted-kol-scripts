/***********************************************************************************************************************
				Script to fine tune the usage of items and skills for WHAM
************************************************************************************************************************
	Version 0.1:	Initial release
***********************************************************************************************************************/

script "WHAM_dontuse";
notify "Winterbay";

import zlib.ash;
import htmlform.ash;
string thisver = "0.1";

record dontuse
{
	string type;
	string id;
	int amount;
};
dontuse[int] not_ok;

void build_table() {
	string current, type, id;
	int amount;
	
	//Load the map of items and skills to not use from the file
	file_to_map("WHAM_dontuse_" + my_name() + ".txt", not_ok);	
	
	writeln("<table border=0>");
	writeln("<tr><th>Action type</th><th>Skill or Item ID</th><th>Skill or Item name</th><th>Amount of item to save</th><th>Remove listing?</th></tr>");

	for i from 0 to count(not_ok) {
		if (i < count(not_ok)) {
			current = not_ok[i].type + " " + not_ok[i].id;
			type = not_ok[i].type;
			id = not_ok[i].id;
			amount = not_ok[i].amount;
		} else {
			current = "new " + i;
			type = "use";
			id = "";
			amount = 0;
		}

		write("<tr><td>");
		//Select drop down
		write_select(type, current, "");
		write_option("use");
		write_option("skill");
		finish_select();
		writeln("</td><td>");
		
		write_field(id, current + "_", "");
		writeln("</td><td>");
		
		write_field((type == "use" ? to_string(to_item(to_int(id))) : to_string(to_skill(to_int(id)))), current + "__", ""); //, (type == "use" ? "itemvalidator" : "skillvalidator"));
		writeln("</td><td>");
		
		write_field(amount, current + "___", "");
		writeln("</td><td>");
		
		write_check(false, current + "____", "");
		writeln("</td></tr>");
		vprint(current + " has been generated with type = " + type + ", id = " + id + ", amount = " + amount + ".", 10);
	}
	writeln("</table>");
}

void build_page() {
//Start buliding the page
	writeln("Fine tuning of items and skills to disallow from WHAM." + check_version("relay WHAM dontuse","relay WHAM dontuse",thisver,8861) + "<br><br>");
	writeln("Instructions for use:<br>");
	writeln("&nbsp;&nbsp;&nbsp;<b>1)</b> Pick an option in the drop down (use for items and skill for ... ehh... skills).<br>");
	writeln("&nbsp;&nbsp;&nbsp;<b>2)</b> Enter either the name or number of the item or skill in question, but not both.<br>");
	writeln("&nbsp;&nbsp;&nbsp;<b>3)</b> For items indicate if you want it to be used above a certain amount.<br>");
	writeln("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The number is the amount to save (or -1 to disregard it completely).<br><br>");
	writeln("You can add one new item or skill at a time, between which you need to press the update&save button.<br><br>");
	build_table();
	
	writeln("<br>");
	write_button("Update", "Update&Save");
	writeln("</form></body></html>");
}

void main() {
	fields = form_fields();
	success = count(fields) > 0;

	int j;
	if (test_button("Update")) {
		foreach fie in fields {
			if(!contains_text(fie, "_") && fie != "Update" && (fields[fie + "_"] != "" || fields[fie + "__"] != "none") && fields[fie + "____"] != "on") {
					not_ok[j].type = fields[fie];
					not_ok[j].id = (fields[fie + "_"] != "" ? fields[fie + "_"] : (fields[fie] == "use" ? to_int(to_item(fields[fie + "__"])) : to_int(to_skill(fields[fie + "__"]))));
					not_ok[j].amount = to_int(fields[fie + "___"]);
					j = j+1;
			}
			vprint(fie + " = " + fields[fie], 10);
		}
		map_to_file(not_ok, "WHAM_dontuse_" + my_name() + ".txt");
	}
	
	write_header();
	write("</head><body><form name=\"relayform\" method=\"POST\" action=\"" + __FILE__ + "\">");
	build_page();
}