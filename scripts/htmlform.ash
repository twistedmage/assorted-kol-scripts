void main()
{
	print("htmlform v0.1, by JasonHarper@pobox.com (Seventh, in game)");
	print("This is a library of functions for building relay browser scripts - it does nothing on its own.");
	print("Documentation can be found at http://kolmafia.us/showthread.php?3842");
}

////////// GLOBAL VARIABLES - PUBLIC

string[string] fields;	// shared result from form_fields()
boolean success;	// form successfully submitted

////////// GLOBAL VARIABLES - PRIVATE

buffer _attr;	// attribute overrides for next tag
float _rangeMin, _rangeMax;	// limits set by range()
boolean _rangeSet;	// limits have been set
string _select;	// current value for <select> tag
string _radioVal, _radioName;	// state to allow 2-arg write_radio()

////////// TOPLEVEL FUNCTIONS
// Overall structure of a script using this library must be either:
// write_header() - <styles & scripts> - finish_header() - <fields> - finish_page()
// or:
// write_page() - <fields> - finish_page()
// All other functions are valid only where <fields> are shown above.

void write_header()
{
	fields = form_fields();
	success = count(fields) > 0;
	_rangeSet = false;
	_attr.set_length(0);
	writeln("<html><head>");
}

void finish_header()
{
	write("</head><body><form name=\"relayform\" method=\"POST\" action=\"\">");
}

// Convenience function for simple scripts that don't need to put anything
// (such as style definitions or scripts) in the <head> section:
void write_page()
{
	write_header();
	finish_header();
}

void finish_page()
{
	writeln("</form></body></html>");
}

////////// UTILITIES

// Specifies an arbitrary HTML attribute to be added to the next tag written.
// If called multiple times, a space is inserted between attributes.
void attr( string val )
{
	_attr.append(" ");
	_attr.append(val);
}

// Internal function to write any user-specified attributes, followed by
// the closing bracket of a tag.
void _writeattr()
{
	write(_attr.to_string());
	write(">");
	_attr.set_length(0);
}

// Specifies a range of allowed values for the next field that uses
// intvalidate or floatvalidate.
void range(float min, float max)
{
	_rangeMin = min;
	_rangeMax = max;
	_rangeSet = true;
}

// Generates a box around a group of related fields.
// Must be balanced with finish_box().
void write_box(string label)
{
	writeln("<fieldset>");
	if (label != "") {
		write("<legend");
		_writeattr();
		write(label);
		writeln("</legend>");
	}
}

void finish_box()
{
	writeln("</fieldset>");
}

////////// VALIDATORS
// write_field() and write_textarea() take an optional parameter which is the
// name of a validator function.  The function is called with one string parameter
// (the name of the field, which can be looked up in fields[]), and must return
// a string - if it's not empty, the new value is rejected, and the string is
// shown in red after the field.  Validators can also modify the value in
// fields[], to do things like expanding an abbreviated item name, or rounding
// a numeric input to a multiple of 10.

string nonemptyvalidator(string name)
{
	if (fields[name] == "") return "This field is required.";
	return "";
}

string intvalidator(string name)
{
	if (!is_integer(fields[name])) {
		_rangeSet = false;
		return "A whole number is requred.";
	}
	if (_rangeSet) {
		_rangeSet = false;
		int val = to_int(fields[name]);
		if (val < _rangeMin) {
			return "Value must be at least " + ceil(_rangeMin);
		}
		if (val > _rangeMax) {
			return "Value must be no more than " + floor(_rangeMax);
		}
	}
	return "";
}

string floatvalidator(string name)
{
	if (!create_matcher("^[-+]?(?:\\d+|\\d+\\.\\d*|\\.\\d+)$",
		fields[name]).find()) {
		_rangeSet = false;
		return "A number is required.";
	}
	if (_rangeSet) {
		_rangeSet = false;
		float val = to_float(fields[name]);
		if (val < _rangeMin) {
			return "Value must be at least " + _rangeMin;
		}
		if (val > _rangeMax) {
			return "Value must be no more than " + _rangeMax;
		}
	}
	return "";
}

string itemvalidator(string name)
{
	item it = to_item(fields[name]);
	if (it == $item[none]) {
		return "A valid item is required.";
	}
	fields[name] = to_string(it);	// normalize
	return "";
}

string itemnonevalidator(string name)
{
	item it = to_item(fields[name]);
	if (it == $item[none] && !contains_text(fields[name], "none")) {
		return "A valid item or 'none' is required.";
	}
	fields[name] = to_string(it);	// normalize
	return "";
}

string locationvalidator(string name)
{
	location it = to_location(fields[name]);
	if (it == $location[none]) {
		return "A valid location is required.";
	}
	fields[name] = to_string(it);	// normalize
	return "";
}

string skillvalidator(string name)
{
	skill it = to_skill(fields[name]);
	if (it == $skill[none]) {
		return "A valid skill is required.";
	}
	fields[name] = to_string(it);	// normalize
	return "";
}

string effectvalidator(string name)
{
	effect it = to_effect(fields[name]);
	if (it == $effect[none]) {
		return "A valid effect is required.";
	}
	fields[name] = to_string(it);	// normalize
	return "";
}

string familiarvalidator(string name)
{
	familiar it = to_familiar(fields[name]);
	if (it == $familiar[none]) {
		return "A valid familiar is required.";
	}
	fields[name] = to_string(it);	// normalize
	return "";
}

string monstervalidator(string name)
{
	monster it = to_monster(fields[name]);
	if (it == $monster[none]) {
		return "A valid monster is required.";
	}
	fields[name] = entity_decode(it);	// normalize
	return "";
}

////////// BASIC FIELDS

string write_field(string ov, string name, string label, string validator)
{
	if (label != "" ) {
		write("<label>");
		write(label);
	}
	string err;
	string rv = ov;
	if (fields contains name) {
		if (validator != "") {
			err = call string validator(name);
		}
		rv = fields[name];
	}
	write("<input");
	if (!contains_text(_attr, "type=")) {
		write(" type=\"text\"");
	}
	write(" name=\"");
	write(name);
	if (label == "") {
		write("\" id=\"");
		write(name);
	}
	write("\" value=\"");
	write(entity_encode(rv));
	write("\"");
	_writeattr();	
	if (err != "") {
		success = false;
		rv = ov;
		write("<font color=\"red\">");
		write(err);
		writeln("</font>");
	}
	if (label != "" ) {
		writeln("</label>");
	}
	return rv;
}

string write_field(string ov, string name, string label)
{
	return write_field(ov, name, label, "");
}

int write_field(int ov, string name, string label, string validator)
{
	return to_int(write_field(to_string(ov), name, label, validator));
}

int write_field(int ov, string name, string label)
{
	return write_field(ov, name, label, "intvalidator");
}

float write_field(float ov, string name, string label, string validator)
{
	return to_float(write_field(to_string(ov), name, label, validator));
}

float write_field(float ov, string name, string label)
{
	return write_field(ov, name, label, "floatvalidator");
}

item write_field(item ov, string name, string label, string validator)
{
	return to_item(write_field(to_string(ov), name, label, validator));
}

item write_field(item ov, string name, string label)
{
	return write_field(ov, name, label, "itemvalidator");
}

location write_field(location ov, string name, string label, string validator)
{
	return to_location(write_field(to_string(ov), name, label, validator));
}

location write_field(location ov, string name, string label)
{
	return write_field(ov, name, label, "locationvalidator");
}

skill write_field(skill ov, string name, string label, string validator)
{
	return to_skill(write_field(to_string(ov), name, label, validator));
}

skill write_field(skill ov, string name, string label)
{
	return write_field(ov, name, label, "skillvalidator");
}

effect write_field(effect ov, string name, string label, string validator)
{
	return to_effect(write_field(to_string(ov), name, label, validator));
}

effect write_field(effect ov, string name, string label)
{
	return write_field(ov, name, label, "effectvalidator");
}

familiar write_field(familiar ov, string name, string label, string validator)
{
	return to_familiar(write_field(to_string(ov), name, label, validator));
}

familiar write_field(familiar ov, string name, string label)
{
	return write_field(ov, name, label, "familiarvalidator");
}

// Discrepancy: monster values may have character entities in them.
monster write_field(monster ov, string name, string label, string validator)
{
	return to_monster(write_field(entity_decode(ov), name, label, validator));
}

monster write_field(monster ov, string name, string label)
{
	return write_field(ov, name, label, "monstervalidator");
}

string write_textarea(string ov, string name, string label, int cols, int rows, string validator)
{
	if (label != "" ) {
		write("<label>");
		write(label);
	}
	string err;
	string rv = ov;
	if (fields contains name) {
		if (validator != "") {
			err = call string validator(name);
		}
		rv = fields[name];
	}
	write("<textarea name=\"");
	write(name);
	if (label == "") {
		write("\" id=\"");
		write(name);
	}
	write("\" cols=\"");
	write(cols);
	write("\" rows=\"");
	write(rows);
	write("\"");
	_writeattr();	
	write(entity_encode(rv));
	writeln("</textarea>");
	if (err != "") {
		success = false;
		rv = ov;
		write("<font color=\"red\">");
		write(err);
		writeln("</font>");
	}
	if (label != "" ) {
		writeln("</label>");
	}
	return rv;
}

string write_textarea(string ov, string name, string label, int cols, int rows)
{
	return write_textarea(ov, name, label, cols, rows, "");
}

boolean write_check(boolean ov, string name, string label)
{
	if (label != "" ) {
		write("<label>");
		write(label);
	}
	if (fields contains name && fields[name] != "") {
		ov = true;
	} else if (count(fields) > 0) {
		// Unfortunately, there's no way to detect the presence
		// of a checkbox that's not currently checked - assume
		// it's actually there if there are any submitted fields.
		ov = false;
	}
	write("<input type=\"checkbox\" name=\"");
	write(name);
	write("\"");
	if (ov) {
		write(" checked");
	}
	_writeattr();	
	if (label != "" ) {
		writeln("</label>");
	}
	return ov;
}

void write_radio(string label, string value)
{
	if (label != "" ) {
		write("<label>");
	}
	write("<input type=\"radio\" name=\"");
	write(_radioName);
	write("\" value=\"");
	write(entity_encode(value));
	write("\"");
	if (value == _radioVal) {
		write(" checked");
	}
	_writeattr();	
	if (label != "" ) {
		write(label);
		writeln("</label>");
	}
}

string write_radio(string ov, string name, string label, string value)
{
	_radioName = name;
	if (fields contains name) {
		_radioVal = fields[name];
	} else {
		_radioVal = ov;
	}
	write_radio(label, value);
	return _radioVal;
}

int write_radio(int ov, string name, string label, string value)
{
	return to_int(write_radio(to_string(ov), name, label, value));
}

float write_radio(float ov, string name, string label, string value)
{
	return to_float(write_radio(to_string(ov), name, label, value));
}

item write_radio(item ov, string name, string label, string value)
{
	return to_item(write_radio(to_string(ov), name, label, value));
}

location write_radio(location ov, string name, string label, string value)
{
	return to_location(write_radio(to_string(ov), name, label, value));
}

class write_radio(class ov, string name, string label, string value)
{
	return to_class(write_radio(to_string(ov), name, label, value));
}

stat write_radio(stat ov, string name, string label, string value)
{
	return to_stat(write_radio(to_string(ov), name, label, value));
}

skill write_radio(skill ov, string name, string label, string value)
{
	return to_skill(write_radio(to_string(ov), name, label, value));
}

effect write_radio(effect ov, string name, string label, string value)
{
	return to_effect(write_radio(to_string(ov), name, label, value));
}

familiar write_radio(familiar ov, string name, string label, string value)
{
	return to_familiar(write_radio(to_string(ov), name, label, value));
}

slot write_radio(slot ov, string name, string label, string value)
{
	return to_slot(write_radio(to_string(ov), name, label, value));
}

monster write_radio(monster ov, string name, string label, string value)
{
	return to_monster(write_radio(to_string(ov), name, label, value));
}

element write_radio(element ov, string name, string label, string value)
{
	return to_element(write_radio(to_string(ov), name, label, value));
}

string write_hidden(string ov, string name)
{
	if (fields contains name) {
		ov = fields[name];
	}
	write("<input type=\"hidden\" name=\"");
	write(name);
	write("\" value=\"");
	write(entity_encode(ov));
	write("\"");
	_writeattr();
	return ov;
}

// Write a label that's not immediately adjacent to its field -
// for example, if the labels are in a separate column of a table.
// Only valid with a write_field() or write_textarea() that had a blank label.
void write_label(string name, string label)
{
	write("<label for=\"");
	write(name);
	write("\"");
	_writeattr();
	write(label);
	writeln("</label>");
}

////////// SELECTORS
// Every call to write_select() must be balanced by a call to finish_select().
// In between, the only valid calls are write_option(), and balanced (but
// non-overlapping) pairs of write_group() & finish_group().

string write_select(string ov, string name, string label)
{
	write("<label>");
	write(label);
	if (fields contains name) {
		ov = fields[name];
	}
	write("<select name=\"");
	write(name);
	if (label == "") {
		write("\" id=\"");
		write(name);
	}
	write("\"");
	_writeattr();	
	_select = ov;
	return ov;
}

void finish_select()
{
	writeln("</select></label>");
}

void write_group(string label)
{
	write("<optgroup label=\"");
	write(entity_encode(label));
	write("\"");
	_writeattr();	
}

void finish_group()
{
	writeln("</optgroup>");
}

void write_option(string label, string value)
{
	write("<option value=\"");
	write(entity_encode(value));
	write("\"");
	if (value == _select) {
		write(" selected");
	}
	_writeattr();	
	write(label);
	writeln("</option>");
}

void write_option(string labelAndValue)
{
	write_option(labelAndValue, labelAndValue);
}

int write_select(int ov, string name, string label)
{
	return to_int(write_select(to_string(ov), name, label));
}

float write_select(float ov, string name, string label)
{
	return to_float(write_select(to_string(ov), name, label));
}

item write_select(item ov, string name, string label)
{
	return to_item(write_select(to_string(ov), name, label));
}

location write_select(location ov, string name, string label)
{
	return to_location(write_select(to_string(ov), name, label));
}

class write_select(class ov, string name, string label)
{
	return to_class(write_select(to_string(ov), name, label));
}

stat write_select(stat ov, string name, string label)
{
	return to_stat(write_select(to_string(ov), name, label));
}

skill write_select(skill ov, string name, string label)
{
	return to_skill(write_select(to_string(ov), name, label));
}

effect write_select(effect ov, string name, string label)
{
	return to_effect(write_select(to_string(ov), name, label));
}

familiar write_select(familiar ov, string name, string label)
{
	return to_familiar(write_select(to_string(ov), name, label));
}

slot write_select(slot ov, string name, string label)
{
	return to_slot(write_select(to_string(ov), name, label));
}

monster write_select(monster ov, string name, string label)
{
	return to_monster(write_select(to_string(ov), name, label));
}

element write_select(element ov, string name, string label)
{
	return to_element(write_select(to_string(ov), name, label));
}

item write_choice(item ov, string name, string label, int[item] vals)
{
	ov = write_select(ov, name, label);
	foreach it, qty in vals write_option(it + " (" + qty + ")", it);
	finish_select();
	return ov;
}

string write_choice(string ov, string name, string label, boolean[string] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

int write_choice(int ov, string name, string label, boolean[int] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

float write_choice(float ov, string name, string label, boolean[float] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

item write_choice(item ov, string name, string label, boolean[item] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

location write_choice(location ov, string name, string label, boolean[location] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

class write_choice(class ov, string name, string label, boolean[class] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

stat write_choice(stat ov, string name, string label, boolean[stat] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

skill write_choice(skill ov, string name, string label, boolean[skill] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

effect write_choice(effect ov, string name, string label, boolean[effect] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

familiar write_choice(familiar ov, string name, string label, boolean[familiar] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

slot write_choice(slot ov, string name, string label, boolean[slot] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

monster write_choice(monster ov, string name, string label, boolean[monster] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

element write_choice(element ov, string name, string label, boolean[element] vals)
{
	ov = write_select(ov, name, label);
	foreach val, bool in vals if (bool) write_option(val);
	finish_select();
	return ov;
}

////////// BUTTONS

// Check if a named button was the reason for this successful pageload
boolean test_button(string name)
{
	if (name == "")	return false;
	return success && fields contains name;
}

// Generate a submit button.  Returns same value as test_button().
boolean write_button(string name, string label)
{
	write("<input type=\"submit\" name=\"");
	write(name);
	write("\" value=\"");
	write(label);
	write("\"");
	_writeattr();
	return test_button(name);
}