import <fight.ash>
void adventure_relay()
{
	buffer results;
	fight_top_level(results);
	if (contains_text(results,"adventure.php")) {
	   buffer actbox;
	   actbox.append("<div id='actbox'>");
	   if (my_location() != $location[none] && my_adventures() > 1 && contains_text(results,"adventure.php")) {
		 // adventure again link
		  actbox.append("\n   <div class='onemenu'><a href='"+to_url(my_location())+(my_location() == $location[boss bat lair] ?
		  "&confirm2=on" : "")+"'><img src='../images/itemimages/hourglass.gif' height=22 width=22 border=0></a></div>"+
		  "<div class='popout' id='again'></div>");
	   }
	   actbox.append("\n   <div class='onemenu'><a href='http://zachbardon.com/mafiatools/bats.php' target='_new'>"+
		  "<img src='../images/itemimages/2wingbat.gif' title='Zarqon: BAT KING' height=22 width=22 border=0></a></div>"+
		  "<div class='popout'><a href='http://kolmafia.us/showthread.php?10042' title='Official thread' target='_new'>BatMan RE</a> "+
		  "is powered by <a href='http://kolmafia.us/showthread.php?6445' title='Official thread' target='_new'>BatBrain</a>.</div></div>");
	   results.replace_string("</body>", actbox+"\n</body>");
	}
	add_features(results);
	results.write();
}

void main()
{
	adventure_relay();
}