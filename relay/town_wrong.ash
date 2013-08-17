buffer results;
	results.append(visit_url());
	
	results.replace_string("title=\"The Tracks\"></a></td>", "title=\"The Tracks\"></a></td><td rowspan=3><a href='storage.php'>Hagnk</a><br /><a href='town_right.php?place=gourd'>Gourd Tower</a><br /><a href='guild.php?place=f'>Muscle Guild</a><br /><a href='guild.php?place=m'>Myst Guild</a><br /><a href='manor.php'>Manor</a></td>");
	
	results.write();
