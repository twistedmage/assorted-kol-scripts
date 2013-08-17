buffer results;
	results.append(visit_url());
	
	string beach = "<a href='guild.php?place=paco'>Go see paco...</a>";
	results.replace_string("Desert Beach is.</td></tr>", "Desert Beach is.</td></tr><tr><td>" + beach + "</td></tr>");
	
	results.write();
