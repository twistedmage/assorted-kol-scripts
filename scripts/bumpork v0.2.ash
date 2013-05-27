/*
	bumpork.ash v0.2
	The master relay override script. 
	
	0.1 - Initial. Starts games and automatically plays them if you have opened the game already. 
	0.2 - Changes from Veracity (thanks!) countering some weirdness in the script hitting the choice.php page too many times.
*/

script "bumpork.ash";

string playPorko()
{
	string [int] exp = split_string(get_property("lastPorkoExpected"), ":");
	
	float highest = 0;
	int highestnum = 0;
	foreach i in exp {
		if (highest < to_float(exp[i])) {
			highest = to_float(exp[i]);
			highestnum = i;
		}
	}
	highestnum = highestnum + 1;
	
	print(highest+" isotopes expected with choice number "+highestnum, "blue");
	return visit_url("choice.php?whichchoice=537&pwd=&option="+highestnum);
}

void main( int iterations )
{
	if (index_of(visit_url("http://kolmafia.us/showthread.php?t=6861"), "0.2</b>") == -1) {
		print("There is a new version available - go download the next version of bumpork.ash at the sourceforge page, linked from http://kolmafia.us/showthread.php?t=6861!", "red");
	}

	int porkocount = 1;
	cli_execute("maximize mp regen min, mp regen max, switch disembodied hand");
	
	while ( iterations > 0 && my_adventures() > 0 && have_effect( $effect[ Transpondent] ) > 0 ) {
		cli_execute("burn * mp");
		print("We need to start our Porko game number "+porkocount+"!", "green");
		porkocount += 1;

		string text = visit_url("spaaace.php?pwd=&place=porko&action=playporko");
		// Redirects to choice.php. Visit it to get the board
		text = visit_url("choice.php");

		// Iterate until we can go "Back to Elvish Paradise"
		while ( !contains_text(text, "Elvish Paradise")) {
			text = playPorko();
		}

		iterations -= 1;
	}

	if ( iterations > 0 ) {
		if ( my_adventures() == 0 ) {
			print( "Ran out of adventures", "red" );
		}
		if ( have_effect( $effect[ Transpondent] ) == 0 ) {
			print( "Ran out of Transpondent", "red" );
		}
	}

	print("Completed. Enjoy your isotopes.", "green");
}
