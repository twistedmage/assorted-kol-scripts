//Wiki Links v1.0
//By IceColdFever

void desc_familiar_relay()
{
	buffer results;
	results.append(visit_url());
	int start = index_of(results, "<b>");
	int end = index_of(results, "</b>");
	string name_of_item = substring(results, start+3,end);
	
	name_of_item = replace_string(name_of_item, " ", "_");
	
	insert(results, start, "<a target=_blank href=http://kol.coldfront.net/thekolwiki/index.php/"+name_of_item+">");
	int new_end = index_of(results, "</b>");
	insert(results, new_end + 4, "</a>");
	
	results.write();
}

void main()
{
	desc_familiar_relay();
}