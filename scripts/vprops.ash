since r17920;

// Properties are mappings from string to string: a (string) name has a (string) value.
//
// The string value can represent one of the following simple ASH data types:
//
// "string"
// "boolean"	boolean to_boolean( string ); string to_string( boolean );
// "int"	int to_int( string ); string to_string( int );
// "float"	float to_float( string ); string to_string( float );
// "item"	item to_item( string ); string to_string( item );
// "location"	location to_location( string ); string to_string( location );
// "class"	class to_class( string ); string to_string( class );
// "stat"	stat to_stat( string ); string to_string( stat );
// "skill"	skill to_skill( string ); string to_string( skill );
// "effect"	effect to_effect( string ); string to_string( effect );
// "familiar"	familiar to_familiar( string ); string to_string( familiar );
// "monster"	monster to_monster( string ); string to_string( monster );
// "element"	element to_element( string ); string to_string( element );
// "phylum"	phylum to_phylum( string ); string to_string( phylum );
// "coinmaster"	coinmaster to_coinmaster( string ); string to_string( coinmaster );
// "thrall"	thrall to_thrall( string ); string to_string( thrall );
// "bounty"	bounty to_bounty( string ); string to_string( bounty );
// "servant"	servant to_servant( string ); string to_string( servant );
// "vykea"	vykea to_vykea( string ); string to_string( vykea );
//
// They can also represent collections of those simple types:
//
// "list" -> TYPE [int] - an ordered collection, allowing duplicates.
// "set" -> boolean [TYPE] - an unordered collection with no duplicates
//
// Collections are put into strings by listing them in the natural order
// of the key, separated by a delimiter character. By default, the
// delimiter is "|", but "," or ";" or anything else can be used
//
// (Internally, this uses split_string(), which takes a regex, not a
// string. Since "|" is a special character in a regex, for convenience,
// we turn "|" into "\\|". But you are welcome to use an actual regex,
// rather than a "delimiter character" if you wish.)
//
// Since the key of a "list" is an int, the elements of the list are
// ordered and duplicate values are allowed.
//
// Since the key of a "set" is any datatype, the elements of the set
// are not ordered and duplicate keys are not allowed.

// You can use the appropriate built-in ASH function to convert between
// simple ASH data types and a string, or vice versa, as listed above.
//
// This package provides coercion functions for "list" and "set" types.
// The versions without "delimiter" assume "|".

string [int] fixed_split_string( string input, string delimiter )
{
    static string[] EMPTY_ARRAY;
    if ( input == "" ) {
	return EMPTY_ARRAY;
    }
    string delim = delimiter == "|" ? "\\|" : delimiter;
    return input.split_string( delim );
}

// Sets:

boolean [boolean] to_set_of_boolean( string set, string delimiter )
{
    boolean [boolean] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_boolean( str ) ] = true;
    }
    return retval;
}

boolean [boolean] to_set_of_boolean( string set )
{
    return to_set_of_boolean( set, "|" );
}

string to_string( boolean [boolean] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [boolean] set )
{
    return to_string( set, "|" );
}

boolean [int] to_set_of_int( string set, string delimiter )
{
    boolean [int] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_int( str ) ] = true;
    }
    return retval;
}

boolean [int] to_set_of_int( string set )
{
    return to_set_of_int( set, "|" );
}

string to_string( boolean [int] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [int] set )
{
    return to_string( set, "|" );
}

boolean [float] to_set_of_float( string set, string delimiter )
{
    boolean [float] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_float( str ) ] = true;
    }
    return retval;
}

boolean [float] to_set_of_float( string set )
{
    return to_set_of_float( set, "|" );
}

string to_string( boolean [float] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [float] set )
{
    return to_string( set, "|" );
}

boolean [string] to_set_of_string( string set, string delimiter )
{
    boolean [string] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ str ] = true;
    }
    return retval;
}

boolean [string] to_set_of_string( string set )
{
    return to_set_of_string( set, "|" );
}

string to_string( boolean [string] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( it );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [string] set )
{
    return to_string( set, "|" );
}

boolean [item] to_set_of_item( string set, string delimiter )
{
    boolean [item] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_item( str ) ] = true;
    }
    return retval;
}

boolean [item] to_set_of_item( string set )
{
    return to_set_of_item( set, "|" );
}

string to_string( boolean [item] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [item] set )
{
    return to_string( set, "|" );
}

boolean [location] to_set_of_location( string set, string delimiter )
{
    boolean [location] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_location( str ) ] = true;
    }
    return retval;
}

boolean [location] to_set_of_location( string set )
{
    return to_set_of_location( set, "|" );
}

string to_string( boolean [location] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [location] set )
{
    return to_string( set, "|" );
}

boolean [class] to_set_of_class( string set, string delimiter )
{
    boolean [class] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_class( str ) ] = true;
    }
    return retval;
}

boolean [class] to_set_of_class( string set )
{
    return to_set_of_class( set, "|" );
}

string to_string( boolean [class] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [class] set )
{
    return to_string( set, "|" );
}

boolean [stat] to_set_of_stat( string set, string delimiter )
{
    boolean [stat] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_stat( str ) ] = true;
    }
    return retval;
}

boolean [stat] to_set_of_stat( string set )
{
    return to_set_of_stat( set, "|" );
}

string to_string( boolean [stat] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [stat] set )
{
    return to_string( set, "|" );
}

boolean [skill] to_set_of_skill( string set, string delimiter )
{
    boolean [skill] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_skill( str ) ] = true;
    }
    return retval;
}

boolean [skill] to_set_of_skill( string set )
{
    return to_set_of_skill( set, "|" );
}

string to_string( boolean [skill] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [skill] set )
{
    return to_string( set, "|" );
}

boolean [effect] to_set_of_effect( string set, string delimiter )
{
    boolean [effect] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_effect( str ) ] = true;
    }
    return retval;
}

boolean [effect] to_set_of_effect( string set )
{
    return to_set_of_effect( set, "|" );
}

string to_string( boolean [effect] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [effect] set )
{
    return to_string( set, "|" );
}

boolean [familiar] to_set_of_familiar( string set, string delimiter )
{
    boolean [familiar] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_familiar( str ) ] = true;
    }
    return retval;
}

boolean [familiar] to_set_of_familiar( string set )
{
    return to_set_of_familiar( set, "|" );
}

string to_string( boolean [familiar] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [familiar] set )
{
    return to_string( set, "|" );
}

boolean [monster] to_set_of_monster( string set, string delimiter )
{
    boolean [monster] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_monster( str ) ] = true;
    }
    return retval;
}

boolean [monster] to_set_of_monster( string set )
{
    return to_set_of_monster( set, "|" );
}

string to_string( boolean [monster] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [monster] set )
{
    return to_string( set, "|" );
}

boolean [element] to_set_of_element( string set, string delimiter )
{
    boolean [element] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_element( str ) ] = true;
    }
    return retval;
}

boolean [element] to_set_of_element( string set )
{
    return to_set_of_element( set, "|" );
}

string to_string( boolean [element] set, string delimiter )
    {
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [element] set )
{
    return to_string( set, "|" );
}

boolean [phylum] to_set_of_phylum( string set, string delimiter )
{
    boolean [phylum] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_phylum( str ) ] = true;
    }
    return retval;
}

boolean [phylum] to_set_of_phylum( string set )
{
    return to_set_of_phylum( set, "|" );
}

string to_string( boolean [phylum] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [phylum] set )
{
    return to_string( set, "|" );
}

boolean [coinmaster] to_set_of_coinmaster( string set, string delimiter )
{
    boolean [coinmaster] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_coinmaster( str ) ] = true;
    }
    return retval;
}

boolean [coinmaster] to_set_of_coinmaster( string set )
{
    return to_set_of_coinmaster( set, "|" );
}

string to_string( boolean [coinmaster] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [coinmaster] set )
{
    return to_string( set, "|" );
}

boolean [thrall] to_set_of_thrall( string set, string delimiter )
{
    boolean [thrall] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_thrall( str ) ] = true;
    }
    return retval;
}

boolean [thrall] to_set_of_thrall( string set )
{
    return to_set_of_thrall( set, "|" );
}

string to_string( boolean [thrall] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [thrall] set )
{
    return to_string( set, "|" );
}

boolean [bounty] to_set_of_bounty( string set, string delimiter )
{
    boolean [bounty] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_bounty( str ) ] = true;
    }
    return retval;
}

boolean [bounty] to_set_of_bounty( string set )
{
    return to_set_of_bounty( set, "|" );
}

string to_string( boolean [bounty] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [bounty] set )
{
    return to_string( set, "|" );
}

boolean [servant] to_set_of_servant( string set, string delimiter )
{
    boolean [servant] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_servant( str ) ] = true;
    }
    return retval;
}

boolean [servant] to_set_of_servant( string set )
{
    return to_set_of_servant( set, "|" );
}

string to_string( boolean [servant] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [servant] set )
{
    return to_string( set, "|" );
}

boolean [vykea] to_set_of_vykea( string set, string delimiter )
{
    boolean [vykea] retval;
    foreach i, str in set.fixed_split_string( delimiter ) {
	retval[ to_vykea( str ) ] = true;
    }
    return retval;
}

boolean [vykea] to_set_of_vykea( string set )
{
    return to_set_of_vykea( set, "|" );
}

string to_string( boolean [vykea] set, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach it in set {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( boolean [vykea] set )
{
    return to_string( set, "|" );
}

// Lists:

boolean [int] to_list_of_boolean( string list, string delimiter )
{
    boolean [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_boolean( str );
    }
    return retval;
}

boolean [int] to_list_of_boolean( string list )
{
    return  to_list_of_boolean( list, "|" );
}

// A list of booleans looks same as a set of ints
// string to_string( boolean [int] list, string delimiter );
// string to_string( boolean [int] list );

int [int] to_list_of_int( string list, string delimiter )
{
    int [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_int( str );
    }
    return retval;
}

int [int] to_list_of_int( string list )
{
    return  to_list_of_int( list, "|" );
}

string to_string( int [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( int [int] list )
{
    return to_string( list, "|" );
}

float [int] to_list_of_float( string list, string delimiter )
{
    float [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_float( str );
    }
    return retval;
}

float [int] to_list_of_float( string list )
{
    return  to_list_of_float( list, "|" );
}

string to_string( float [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( float [int] list )
{
    return to_string( list, "|" );
}

string [int] to_list_of_string( string list, string delimiter )
{
    string [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = str;
    }
    return retval;
}

string [int] to_list_of_string( string list )
{
    return  to_list_of_string( list, "|" );
}

string to_string( string [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( it );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( string [int] list )
{
    return to_string( list, "|" );
}

item [int] to_list_of_item( string list, string delimiter )
{
    item [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_item( str );
    }
    return retval;
}

item [int] to_list_of_item( string list )
{
    return  to_list_of_item( list, "|" );
}

string to_string( item [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( item [int] list )
{
    return to_string( list, "|" );
}

location [int] to_list_of_location( string list, string delimiter )
{
    location [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_location( str );
    }
    return retval;
}

location [int] to_list_of_location( string list )
{
    return  to_list_of_location( list, "|" );
}

string to_string( location [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( location [int] list )
{
    return to_string( list, "|" );
}

class [int] to_list_of_class( string list, string delimiter )
{
    class [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_class( str );
    }
    return retval;
}

class [int] to_list_of_class( string list )
    {
    return  to_list_of_class( list, "|" );
}

string to_string( class [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( class [int] list )
{
    return to_string( list, "|" );
}

stat [int] to_list_of_stat( string list, string delimiter )
{
    stat [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_stat( str );
    }
    return retval;
}

stat [int] to_list_of_stat( string list )
{
    return  to_list_of_stat( list, "|" );
}

string to_string( stat [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( stat [int] list )
{
    return to_string( list, "|" );
}

skill [int] to_list_of_skill( string list, string delimiter )
{
    skill [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_skill( str );
    }
    return retval;
}
    
skill [int] to_list_of_skill( string list )
{
    return  to_list_of_skill( list, "|" );
}

string to_string( skill [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( skill [int] list )
{
    return to_string( list, "|" );
}

effect [int] to_list_of_effect( string list, string delimiter )
{
    effect [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_effect( str );
    }
    return retval;
}

effect [int] to_list_of_effect( string list )
{
    return  to_list_of_effect( list, "|" );
}

string to_string( effect [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( effect [int] list )
{
    return to_string( list, "|" );
}

familiar [int] to_list_of_familiar( string list, string delimiter )
{
    familiar [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_familiar( str );
    }
    return retval;
}

familiar [int] to_list_of_familiar( string list )
{
    return  to_list_of_familiar( list, "|" );
}

string to_string( familiar [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( familiar [int] list )
{
    return to_string( list, "|" );
}

monster [int] to_list_of_monster( string list, string delimiter )
{
    monster [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_monster( str );
    }
    return retval;
}

monster [int] to_list_of_monster( string list )
{
    return  to_list_of_monster( list, "|" );
}

string to_string( monster [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( monster [int] list )
{
    return to_string( list, "|" );
}

element [int] to_list_of_element( string list, string delimiter )
{
    element [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_element( str );
    }
    return retval;
}

element [int] to_list_of_element( string list )
{
    return  to_list_of_element( list, "|" );
}

string to_string( element [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( element [int] list )
{
    return to_string( list, "|" );
}

phylum [int] to_list_of_phylum( string list, string delimiter )
{
    phylum [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_phylum( str );
    }
    return retval;
}

phylum [int] to_list_of_phylum( string list )
{
    return  to_list_of_phylum( list, "|" );
}

string to_string( phylum [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( phylum [int] list )
{
    return to_string( list, "|" );
}

coinmaster [int] to_list_of_coinmaster( string list, string delimiter )
{
    coinmaster [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_coinmaster( str );
    }
    return retval;
}

coinmaster [int] to_list_of_coinmaster( string list )
{
    return  to_list_of_coinmaster( list, "|" );
}

string to_string( coinmaster [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( coinmaster [int] list )
{
    return to_string( list, "|" );
}

thrall [int] to_list_of_thrall( string list, string delimiter )
{
    thrall [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_thrall( str );
    }
    return retval;
}

thrall [int] to_list_of_thrall( string list )
{
    return  to_list_of_thrall( list, "|" );
}

string to_string( thrall [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( thrall [int] list )
{
    return to_string( list, "|" );
}

bounty [int] to_list_of_bounty( string list, string delimiter )
{
    bounty [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_bounty( str );
    }
    return retval;
}

bounty [int] to_list_of_bounty( string list )
{
    return  to_list_of_bounty( list, "|" );
}

string to_string( bounty [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( bounty [int] list )
{
    return to_string( list, "|" );
}

servant [int] to_list_of_servant( string list, string delimiter )
{
    servant [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_servant( str );
    }
    return retval;
}

servant [int] to_list_of_servant( string list )
{
    return  to_list_of_servant( list, "|" );
}

string to_string( servant [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( servant [int] list )
{
    return to_string( list, "|" );
}

vykea [int] to_list_of_vykea( string list, string delimiter )
{
    vykea [int] retval;
    foreach i, str in list.fixed_split_string( delimiter ) {
	retval[ i ] = to_vykea( str );
    }
    return retval;
}

vykea [int] to_list_of_vykea( string list )
{
    return  to_list_of_vykea( list, "|" );
}

string to_string( vykea [int] list, string delimiter )
{
    buffer buf;
    string delim = "";
    foreach i, it in list {
	buf.append( delim );
	buf.append( to_string( it ) );
	delim = delimiter;
    }
    return buf.to_string();
}

string to_string( vykea [int] list )
{
    return to_string( list, "|" );
}

// Values work best if they are "normalized".
//
// "seal tooth" is a normalized "item"
// "seal to" is not normalized.
// "snorkel|seal tooth" is a normalized "list" or "set" of "item"
// "snork|seal to" is not normalized
//
// This package provides functions to normalize string values. Since
// users can set properties to whatever they wish, it uses these
// functions itself, but user programs can also use them if they want to
// ensure that properties that they set are precise.

string normalize_value( string value, string type )
{
    switch ( type ) {
    case "string":
	return value;
    case "boolean":
	return to_string( to_boolean( value ) );
    case "int":
	return to_string( to_int( value ) );
    case "float":
	return to_string( to_float( value ) );
    case "item":
	return to_string( to_item( value ) );
    case "location":
	return to_string( to_location( value ) );
    case "class":
	return to_string( to_class( value ) );
    case "stat":
	return to_string( to_stat( value ) );
    case "skill":
	return to_string( to_skill( value ) );
    case "effect":
	return to_string( to_effect( value ) );
    case "familiar":
	return to_string( to_familiar( value ) );
    case "monster":
	return to_string( to_monster( value ) );
    case "element":
	return to_string( to_element( value ) );
    case "phylum":
	return to_string( to_phylum( value ) );
    case "coinmaster":
	return to_string( to_coinmaster( value ) );
    case "thrall":
	return to_string( to_thrall( value ) );
    case "bounty":
	return to_string( to_bounty( value ) );
    case "servant":
	return to_string( to_servant( value ) );
    case "vykea":
	return to_string( to_vykea( value ) );
    }
    return value;
}

string normalize_list( string value, string type, string delimiter )
{
    string [int] list;
    foreach i, it in value.fixed_split_string( delimiter ) { 
	list[ i ] = normalize_value( it, type );
    }
    return to_string( list, delimiter );
}

string normalize_list( string value, string type )
{
    return normalize_list( value, type, "|" );
}

string normalize_set( string value, string type, string delimiter )
{
    boolean [string] set;
    foreach i, it in value.fixed_split_string( delimiter ) { 
	set[ normalize_value( it, type ) ] = true;
    }
    return to_string( set, delimiter );
}

string normalize_set( string value, string type )
{
    return normalize_set( value, type, "|" );
}

string normalize_value( string value, string type, string collection, string delimiter )
{
    switch ( collection ) {
    case "list":
	return normalize_list( value, type, delimiter );
    case "set":
	return normalize_set( value, type, delimiter );
    }
    return normalize_value( value, type );
}

string normalize_value( string value, string type, string collection )
{
    return normalize_value( value, type, collection, "|" );
}

// define_property specifies that a particular property with NAME is of type TYPE.
// Optionally, you can declare that the value is a COLLECTION (either "list" or "set") with a DELIMITER
// NAME can be either built-in to KoLmafia or a custom user property.
// If it is a custom property, you can specify a DEFAULT value
//
// If the property exists, define_property will fetch the value,
// normalize it, and return it.
//    If the property is custom and the normalized value equals
//    the normalized default value, the property will be removed.
//    If the property is custom and the value is not normalized,
//    the property will be set with the normalized value.
//
// If the property does not exist, define_property will return the
// (normalized) default value and the property will remain unset.

string define_property( string name, string type, string def, string collection, string delimiter )
{
    // All "built-in" properties exist. A "custom" property that doesn't
    // exist uses the (normalized) default.
    if ( !property_exists( name ) ) {
	string normalized_default = normalize_value( def, type, collection, delimiter );
	return normalized_default;
    }

    // The property exists and (potentially) overrides the default
    string raw_value = get_property( name );
    string value = normalize_value( raw_value, type, collection, delimiter );

    // A "custom" property has no default. Normalize it, if needed
    if ( !property_has_default( name ) ) {
	string normalized_default = normalize_value( def, type, collection, delimiter );
	if ( value == normalized_default ) {
	    remove_property( name );
	} else if ( raw_value != value ) {
	    set_property( name, value );
	}
    }

    // Return the normalized property value
    return value;
}

string define_property( string name, string type, string def, string collection )
{
    return define_property( name, type, def, collection, "|" );
}

string define_property( string name, string type, string def )
{
    return define_property( name, type, def, "", "" );
}

// You can use these in conjunction with the appropriate coercion
// function to extract the value of a property into the appropriate data
// type. For example:
//
// int prop1 = define_property( "prop1", "int", "12" ).to_int();
// boolean prop2 = define_property( "prop2", "boolean", "true" ).to_boolean();
// item prop3 = define_property( "prop3", "item", "snorkel" ).to_item();
// boolean [item] prop4 = define_property( "prop4", "item", "snorkel|seal tooth", "set" ).to_set_of_item();
// string [int] prop5 =  define_property( "prop5", "string", "str1,str2,str3", "list", "," ).to_list_of_string( "," );
