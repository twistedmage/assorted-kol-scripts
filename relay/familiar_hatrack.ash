
record _hat {
	int cap;
	string effects;
};

_hat [item] hats;
file_to_map("hatrack.txt", hats);

boolean hatrack_check()
{
	return false;
}

buffer hatrack_preaction()
{
	// Should not be called
	return visit_url();
}

buffer hatrack_main(buffer page)
{
	print("familiar_hatrack_relay called","blue");
	if (page.index_of("<optgroup label=\"Hats\" id=\"optgroup_hat\">") == -1)
		return page;

	foreach itm in hats {
		string src = ">" + itm.to_string();
		string dst = src + " (";
		if (hats[itm].cap != 0)
			dst = dst + hats[itm].cap + " lbs., ";
		if (hats[itm].effects != "")
			dst = dst + hats[itm].effects;
		dst = dst + ")";
		page.replace_string(src, dst);
	}

	return page;
}

// vim: set ft=javascript ts=4:
