void main()
{
	class[int] cs;
	cs[1]=$class[seal clubber];
	cs[2]=$class[sauceror];
	cs[3]=$class[turtle tamer];
	cs[4]=$class[pastamancer];
	cs[5]=$class[disco bandit];
	cs[6]=$class[accordion thief];

	foreach c in cs
	{
		string route="";
		int avail1 = available_amount($item[ass-stompers of violence]);
		int avail2 = available_amount($item[treads of loathing]);
		int avail3 = available_amount($item[cold stone of hatred]);
		int avail4 = available_amount($item[scepter of loathing]);
		switch (cs[c])
		{
			case $class[seal clubber]:
				avail1 = available_amount($item[ass-stompers of violence]);
				avail2 = available_amount($item[treads of loathing]);
				avail3 = available_amount($item[cold stone of hatred]);
				avail4 = available_amount($item[scepter of loathing]);
				if (avail1 + avail2 < 2) route = "gladiator";
				else 
				if (avail3 + avail4 < 2) route = "scholar";
				break;
			case $class[turtle tamer]:
				avail1 = available_amount($item[brand of violence]);
				avail2 = available_amount($item[scepter of loathing]);
				avail3 = available_amount($item[girdle of hatred]);
				avail4 = available_amount($item[belt of loathing]);
				if (avail1 + avail2 < 2) route = "scholar";
			//	else 
			//	if (avail3 + avail4<3) route = "gladiator";
				break;
			case $class[pastamancer]:
				avail1 = available_amount($item[novelty belt buckle of violence]);
				avail2 = available_amount($item[belt of loathing]);
				avail3 = available_amount($item[staff of simmering hatred]);
				avail4 = available_amount($item[stick-knife of loathing]);
				if (avail1 + avail2 < 2) route = "gladiator";
				else 
				if (avail3 + avail4 < 2) route = "scholar";
				break;
			case $class[sauceror]:
				avail1 = available_amount($item[lens of violence]);
				avail2 = available_amount($item[goggles of loathing]);
				avail3 = available_amount($item[pantaloons of hatred]);
				avail4 = available_amount($item[jeans of loathing]);
			//	if (avail1 + avail2 < 4) route = "gladiator";
			//	else 
				if (avail3 + avail4 < 4) route = "scholar";
				break;
			case $class[disco bandit]:
				avail1 = available_amount($item[pigsticker of violence]);
				avail2 = available_amount($item[stick-knife of loathing]);
				avail3 = available_amount($item[fuzzy slippers of hatred]);
				avail4 = available_amount($item[treads of loathing]);
			//	if (avail1 + avail2 < 6) route = "gladiator";
			//	else 
				if (avail3 + avail4 < 2) route = "scholar";
				break;
			case $class[accordion thief]:
				avail1 = available_amount($item[jodhpurs of violence]);
				avail2 = available_amount($item[jeans of loathing]);
				avail3 = available_amount($item[lens of hatred]);
				avail4 = available_amount($item[goggles of loathing]);
			//	if (avail1 + avail2 < 4) route = "gladiator";
			//	else 
				if (avail3 + avail4 < 4) route = "scholar";
				break;
			default:
				break;
		}
		print(cs[c]+" = "+route);
	}
}