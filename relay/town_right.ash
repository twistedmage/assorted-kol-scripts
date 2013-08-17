buffer results;
	results.append(visit_url());
	
	results.replace_string("<table><tr><td rowspan=3", "<table><tr><td rowspan=3>TEST</td><td rowspan=3");
	
	results.write();
