buffer results;
	results.append(visit_url());
	
	string form = "<center><span style='color:red;font-weight:bold;'>Wouldn't life be easier if everything had 'win' buttons?</span><br><form name='bumliteracy' action='' method='post'><input type='hidden' name='action' value='Yep.' />";
	form += "<input type='hidden' name='oath' value='I have read the Policies of Loathing, and I promise to abide by them.' />";
	form += "<input type='hidden' name='t1' value='3' />";
	form += "<input type='hidden' name='t2' value='1' />";
	form += "<input type='hidden' name='t3' value='3' />";
	form += "<input type='hidden' name='y1' value='1' />";
	form += "<input type='hidden' name='y2' value='1' />";
	form += "<input type='hidden' name='pwd' value='"+my_hash()+"' />";
	form += "<input type='hidden' name='horsecolor' value='Black' />";
	form += "<input type='submit' value='Prove Yourself Literate!' /></form>";
	results.replace_string("ghostaltar.gif\">", "ghostaltar.gif\">"+form);
	
	results.write();
