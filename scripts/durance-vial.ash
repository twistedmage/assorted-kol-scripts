boolean[item] allVials = $items[
	red slime, yellow slime, blue slime,
	orange slime, v green slime, violet slime,
	vermilion slime, amber slime, chartreuse slime,
	teal slime, purple slime, indigo slime,
	brown slime
];
boolean[item] primary = $items[
	red slime, yellow slime, blue slime,
];
boolean[item] secondary = $items[
	orange slime, v green slime, violet slime,
];
boolean[item] tertiary = $items[
	vermilion slime, amber slime, chartreuse slime,
	teal slime, purple slime, indigo slime,
];
boolean[item] creatable = $items[
	vermilion slime, amber slime, chartreuse slime,
	teal slime, purple slime, indigo slime,
	orange slime, v green slime, violet slime,
];

print("Finding out what you've already discovered...");
string page = visit_url("craft.php?mode=discoveries&what=cook");
item[item, item] known;
int knownCount = 0;
matcher m = create_matcher("<td [^>]*valign=top[^>]*><b>(?:<a [^>]*>)?(.*?)(?:</a>)?</b>.*?<br/>(.+?) \\(\\d+\\) \\+ (.+?) \\(\\d+\\)</font>", page);
while (m.find())
{
	item res = m.group(1).to_item();
	if (!(allVials contains res)) continue;
	item a = m.group(2).to_item();
	if (!(allVials contains a)) continue;
	item b = m.group(3).to_item();
	if (!(allVials contains b)) continue;
	knownCount = knownCount + 1;
	known[a, b] = res;
	known[b, a] = res;
}
print("You already know " + knownCount + " of the slime vial recipes.");

int[item] need;
boolean reallyMix = false;
void mix(item res, item a, item b)
{
	if (known[a, b] == res) return;	// already discovered
	if (reallyMix) {
		craft("cook", 1, a, b);
	}
	else
	{
		need[a] = need[a] + 1;
		need[b] = need[b] + 1;
		need[res] = need[res] - 1;
	}
}

void mixAll()
{
	mix($item[red slime], $item[red slime], $item[red slime]);
	mix($item[yellow slime], $item[yellow slime], $item[yellow slime]);
	mix($item[blue slime], $item[blue slime], $item[blue slime]);
	
	mix($item[orange slime], $item[orange slime], $item[orange slime]);
	mix($item[v green slime], $item[v green slime], $item[v green slime]);
	mix($item[violet slime], $item[violet slime], $item[violet slime]);
	
	mix($item[vermilion slime], $item[vermilion slime], $item[vermilion slime]);
	mix($item[amber slime], $item[amber slime], $item[amber slime]);
	mix($item[chartreuse slime], $item[chartreuse slime], $item[chartreuse slime]);
	mix($item[teal slime], $item[teal slime], $item[teal slime]);
	mix($item[purple slime], $item[purple slime], $item[purple slime]);
	mix($item[indigo slime], $item[indigo slime], $item[indigo slime]);
	
	mix($item[orange slime], $item[red slime], $item[amber slime]);
	mix($item[orange slime], $item[yellow slime], $item[vermilion slime]);
	mix($item[orange slime], $item[vermilion slime], $item[amber slime]);
	
	mix($item[v green slime], $item[blue slime], $item[chartreuse slime]);
	mix($item[v green slime], $item[yellow slime], $item[teal slime]);
	mix($item[v green slime], $item[chartreuse slime], $item[teal slime]);
	
	mix($item[violet slime], $item[blue slime], $item[purple slime]);
	mix($item[violet slime], $item[red slime], $item[indigo slime]);
	mix($item[violet slime], $item[indigo slime], $item[purple slime]);
	
	mix($item[vermilion slime], $item[orange slime], $item[vermilion slime]);
	mix($item[vermilion slime], $item[red slime], $item[vermilion slime]);
	
	mix($item[amber slime], $item[orange slime], $item[amber slime]);
	mix($item[amber slime], $item[yellow slime], $item[amber slime]);
	
	mix($item[chartreuse slime], $item[v green slime], $item[chartreuse slime]);
	mix($item[chartreuse slime], $item[yellow slime], $item[chartreuse slime]);
	
	mix($item[teal slime], $item[blue slime], $item[teal slime]);
	mix($item[teal slime], $item[v green slime], $item[teal slime]);
	
	mix($item[purple slime], $item[red slime], $item[purple slime]);
	mix($item[purple slime], $item[violet slime], $item[purple slime]);
	
	mix($item[indigo slime], $item[blue slime], $item[indigo slime]);
	mix($item[indigo slime], $item[violet slime], $item[indigo slime]);
	
	mix($item[brown slime], $item[amber slime], $item[chartreuse slime]);
	mix($item[brown slime], $item[amber slime], $item[indigo slime]);
	mix($item[brown slime], $item[amber slime], $item[purple slime]);
	mix($item[brown slime], $item[amber slime], $item[teal slime]);
	mix($item[brown slime], $item[blue slime], $item[amber slime]);
	mix($item[brown slime], $item[blue slime], $item[orange slime]);
	mix($item[brown slime], $item[blue slime], $item[vermilion slime]);
	mix($item[brown slime], $item[chartreuse slime], $item[indigo slime]);
	mix($item[brown slime], $item[chartreuse slime], $item[purple slime]);
	mix($item[brown slime], $item[v green slime], $item[amber slime]);
	mix($item[brown slime], $item[v green slime], $item[indigo slime]);
	mix($item[brown slime], $item[v green slime], $item[purple slime]);
	mix($item[brown slime], $item[v green slime], $item[vermilion slime]);
	mix($item[brown slime], $item[v green slime], $item[violet slime]);
	mix($item[brown slime], $item[orange slime], $item[chartreuse slime]);
	mix($item[brown slime], $item[orange slime], $item[v green slime]);
	mix($item[brown slime], $item[orange slime], $item[indigo slime]);
	mix($item[brown slime], $item[orange slime], $item[purple slime]);
	mix($item[brown slime], $item[orange slime], $item[teal slime]);
	mix($item[brown slime], $item[orange slime], $item[violet slime]);
	mix($item[brown slime], $item[red slime], $item[chartreuse slime]);
	mix($item[brown slime], $item[red slime], $item[v green slime]);
	mix($item[brown slime], $item[red slime], $item[teal slime]);
	mix($item[brown slime], $item[teal slime], $item[indigo slime]);
	mix($item[brown slime], $item[teal slime], $item[purple slime]);
	mix($item[brown slime], $item[vermilion slime], $item[chartreuse slime]);
	mix($item[brown slime], $item[vermilion slime], $item[indigo slime]);
	mix($item[brown slime], $item[vermilion slime], $item[purple slime]);
	mix($item[brown slime], $item[vermilion slime], $item[teal slime]);
	mix($item[brown slime], $item[violet slime], $item[amber slime]);
	mix($item[brown slime], $item[violet slime], $item[chartreuse slime]);
	mix($item[brown slime], $item[violet slime], $item[teal slime]);
	mix($item[brown slime], $item[violet slime], $item[vermilion slime]);
	mix($item[brown slime], $item[yellow slime], $item[indigo slime]);
	mix($item[brown slime], $item[yellow slime], $item[purple slime]);
	mix($item[brown slime], $item[yellow slime], $item[violet slime]);

	mix($item[brown slime], $item[yellow slime], $item[brown slime]);
	mix($item[brown slime], $item[violet slime], $item[brown slime]);
	mix($item[brown slime], $item[vermilion slime], $item[brown slime]);
	mix($item[brown slime], $item[teal slime], $item[brown slime]);
	mix($item[brown slime], $item[purple slime], $item[brown slime]);
	mix($item[brown slime], $item[red slime], $item[brown slime]);
	mix($item[brown slime], $item[orange slime], $item[brown slime]);
	mix($item[brown slime], $item[indigo slime], $item[brown slime]);
	mix($item[brown slime], $item[v green slime], $item[brown slime]);
	mix($item[brown slime], $item[chartreuse slime], $item[brown slime]);
	mix($item[brown slime], $item[blue slime], $item[brown slime]);
	mix($item[brown slime], $item[amber slime], $item[brown slime]);
	mix($item[brown slime], $item[brown slime], $item[brown slime]);
}

mixAll();
foreach cr in creatable {
	int qty = need[cr] - item_amount(cr);
	if (qty <= 0) continue;
	foreach ingr in get_ingredients(cr) {
		need[ingr] = need[ingr] + qty;
	}
}

boolean fail = false;
foreach pri in primary {
	int n = need[pri];
	int h = item_amount(pri);
	if (h >= n) {
		print(pri + ": you have all " + n + " that you need.");
	} else {
		print(pri + ": you need " + (n - h) + " more, for a total of " + n);
		fail = true;
	}
}

if (!fail && user_confirm("Cook 'em, Danno!")) {
	foreach sec in secondary {
		retrieve_item(need[sec], sec);
	}
	foreach ter in tertiary {
		retrieve_item(need[ter], ter);
	}
	reallyMix = true;
	mixAll();
	print("Don't forget to buy the trophy!");
}

