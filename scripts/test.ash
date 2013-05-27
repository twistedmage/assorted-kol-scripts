
void main()
{
print("a");
	string tmp =visit_url("account.php?tab=combat");
print("a");
	matcher mtch = create_matcher("option selected=\"selected\" value=\"(\\d*)\">([\\w \(\)]*)",tmp);
print("a");
	if(mtch.find())
	{
		print("found "+mtch.group(1));
		print("and found "+mtch.group(2));
	}
	else
		print("failure");
}