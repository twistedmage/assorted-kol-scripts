import "Briefcase.ash";

void main()
{
	buffer page_text = visit_url();
	updateState(page_text);
	
	page_text.replace_string("alt=\"Handle (up)\"", "alt=\"Handle (up)\" style=\"opacity:0.5;\"");
	buffer extra;
	extra.append("<div>Test " + gametime_to_int() + "</div>");
	
	//page_text.replace_string("<div id=background style='position:relative;'>", "<div id=background style='position:relative;'>" + extra);
	write(page_text);
}

/*
	-Configure the enchantments.
	-Unlock drawers.
	-Unlock martini hose.
	-Collect specific martini?
	-Buffs?
	-Solve all lights.
	
	
	-Unlock crank, buttons(?)
	-First light?
	-Solve second light.
	-Solve third light.
	
*/