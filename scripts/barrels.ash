// Use the inebriety table as a cheap way to find out
// whether or not something is booze.
import<Universal_recovery.ash>

int [item] lookup;
file_to_map( "inebriety.txt", lookup );


// Utility method which extracts the first item which
// is located in the response text.

item first_item( string text )
{
     int [item] results = text.extract_items();
     foreach key in results
     {
         if ( results[key] >= 1 )
             return key;
     }

     return $item[none];
}


// Utility method which beats up the mimic for whatever
// he drops.  Should be modified to represent how you
// would handle the mimic.

item handle_mimic( string text )
{
     while ( text.index_of( "fight.php" ) != -1 )
         text = attack();
    return text.first_item();
}


// Attempt to break the barrel located at the given location
// and return what was found there.

item break_barrel( int square )
{
	if( my_hp() <= 0)
 	{	
		cli_execute("recover hp");
 	}
	print( "Trying barrel #" + square + "..." );

    string text = visit_url( "barrel.php?pwd&smash=" + square );
    if ( text.index_of( "fight.php" ) != -1 )
        return handle_mimic( text );
     if( text.index_of( "KOMPRESSOR" ) != -1 )
         return $item[cog];

    return text.first_item();
}

// Utility method which checks whether the given item is booze.
// Uses the map declared and read in earlier.

boolean is_possible_booze( item result )
{
	if ( result == $item[none] )
		return true;

	if ( result == $item[ten-leaf clover] )
		return true;

	if ( lookup[result] > 0 )
		return true;

	return false;
}


// Attempts to find booze in the given meta_row and meta_block.  Returns
// whether or not the attempt to find booze was successful.

boolean find_booze( int meta_row, int meta_block )
{
	int s1 = ((meta_row - 1) * 12) + (2 * (meta_block - 1)) + 1;
	int s2 = s1 + 1;
	int s3 = s1 + 6;
	int s4 = s2 + 6;

	// This is a little counter-intuitive, but the idea is
	// basically, you break each barrel.  If it's definitely
	// not booze, you kick out.  Otherwise, keep scanning
	// the meta block -- you may find something.

	item result = break_barrel( s1 );
	if ( result== $item[cog] )
		return true;			//if barrel already smashed pretend we are done
	if ( !result.is_possible_booze() )
		return false;

	result = break_barrel( s2 );
	if ( !result.is_possible_booze() )
		return false;

	result = break_barrel( s3 );
	if ( !result.is_possible_booze() )
		return false;

	result = break_barrel( s4 );
	if ( !result.is_possible_booze() )
		return false;

	return true;
}


// Utility method which clears out the given meta row of all of
// its booze.  Just goes from left to right.  If you want, you
// could randomize it.

void find_booze( int meta_row )
{
	if ( find_booze( meta_row, 1 ) )
		return;

	if ( find_booze( meta_row, 3 ) )
		return;

	find_booze( meta_row, 2 );
}


// Main method.  Here, you simply attempt to clear the second
// meta row.  This could be extended to clear both the first and
// second meta rows with one extra function call.

void main()
{
	find_booze( 1 );
	find_booze( 2 );
	find_booze( 3 );
}