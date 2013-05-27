import <sims_lib.ash>

void main()
{
//	while(true)
//	{
		string result=visit_url_non_abort("multiuse.php?action=useitem&pwd&from=inv&quantity=63&whichitem=5289");
		matcher dist_match = create_matcher("It goes \\d\\d\\d feet",result);
		dist_match.find();
		string dist_str=group(dist_match,0);
		print(dist_str);
//		int dist=
		if(!contains_text(result,"does not hit anything interesting"))
			abort("DONE!");
//	}
}