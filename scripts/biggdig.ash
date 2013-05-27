/* biggdig.ash - automate farming in Bigg's Dig. */

item biggdig( int section, int subsection, int square )
{
	buffer digg_result = visit_url( "dig.php?action=dig&pwd=" + my_hash() + "&s1=" + section + "&s2=" + subsection + "&s3=" + square );
	if(digg_result.contains_text("crumbles") || digg_result.contains_text("too difficult to dig"))
	{
		return $item[ none ];
	}
	if (digg_result.contains_text("Uh oh, looks like somebody beat you to that spot.")) return $item[ bum cheek ];
	foreach it in extract_items(digg_result) return it;
	return $item[ none ];
}

#Returns a 10x10 map of the given subsection. Excavated spots are marked as true, while unexcavated spots are marked as false.
#Format: [Y_coord, X_coord] => boolean
boolean [10, 10] get_subsection_map( int section, int subsection )
{
	boolean [10, 10] subsection_map;
	buffer view_result = visit_url( "dig.php?viewsection=" + section + "&viewsubsection=" + subsection );
	matcher m = create_matcher( "<td width=30 height=30.*?</td>", view_result );

	for y from 0 upto 9
	{
		for x from 0 upto 9
		{
			if (!m.find()) abort( "Error in get_subsection_map(): cannot find match." );
			subsection_map[y, x] = m.group().contains_text( "/itemimages/db_dug" );
			if(!subsection_map[y, x])
			{
				subsection_map[y, x] = m.group().contains_text( "/itemimages/db_dirt" );
			}
			
		}
	}
	# <td width=30 height=30  class=tiny align=center valign=center><a href=dig.php?action=dig&pwd=d06e4b05d2b6de376e809887a8e5fc1f&s1=56&s2=4&s3=34><img src=/images/itemimages/db_dirt2.gif border=0></a></td>
	# Uses db_lump\d.gif and db_dirt\d.gif
	# <td width=30 height=30  class=tiny align=center valign=center><img src=/images/itemimages/db_dug[1-9].gif></td>

	return subsection_map;
}

#Returns a 10x10 map of the given section with the completion rates of each subsection.
float [10, 10] get_section_map( int section )
{
	float [10, 10] section_map;
	buffer view_result = visit_url("dig.php?viewsection=" + section);
	matcher m = create_matcher("<td width=50 height=50.*?\\((\\d+)%\\).*?</td>", view_result);

	for y from 0 upto 9
	{
		for x from 0 upto 9
		{
			if (!m.find()) abort("Error in get_section_map(): cannot find match.");
			section_map[y, x] = m.group(1).to_int() / 100.0;
		}
	}

	return section_map;
}

#Returns a 10x10 map of Bigg's Dig with the completion rates of each section.
float [10, 10] get_biggdig_map()
{
	float [10, 10] biggdig_map;
	matcher m = create_matcher("<td width=50 height=50.*?\\(([\\d.]+)%\\).*?</td>", visit_url("dig.php"));

	for y from 0 upto 9
	{
		for x from 0 upto 9
		{
			if (!m.find()) abort("Error in get_biggdig_map(): cannot find match.");
			biggdig_map[y, x] = m.group(1).to_float() / 100;
		}
	}

	return biggdig_map;
}

void summarize_result(int turns_used, int[item] result_list)
{
	print("");
	print("The following items were acquired in " + turns_used + " adventures:", "blue");
	foreach it, quantity in result_list
		print( it + ": " + quantity);
	exit;
}

void main(int turns_used)
{
	cli_execute("inventory refresh");
	visit_url("plains.php?action=bigg"); //get shovel
	if(turns_used==0) return;
	if(available_amount($item[archaeologing shovel])!=0)
	{
		
		if (turns_used > 30) turns_used=30;
		
		equip($item[archaeologing shovel]);

		int turn_counter = 0;
		int [item] result_list;

		print("Scanning for digging sites...");

		foreach section_y, section_x, section_completion in get_biggdig_map()
		{
			boolean finished=false;
			if (section_completion == 1) continue;
			int section_num = section_x + section_y * 10 + 1;
			foreach sub_y, sub_x, sub_completion in get_section_map(section_num)
			{
				if (sub_completion == 1) continue;
				int subsection_num = sub_x + sub_y * 10 + 1;
				foreach square_y, square_x, is_used in get_subsection_map(section_num, subsection_num)
				{
					int square_num = square_x + square_y * 10 + 1;
					if (is_used) continue;
					if (turns_used <= turn_counter || finished)
					{
						print("Finished!", "blue");
						summarize_result(turns_used, result_list);
					}
					else
					{
						item result = biggdig(section_num, subsection_num, square_num);
						if (result == $item[none])
						{
							finished=true;
							break;
							continue;
						}
						else if(result != $item[bum cheek])
						{
							result_list[result] += 1;
							turn_counter += 1;
							print("Turn #" + turn_counter + ": acquired " + result + " in " + section_num + ":" + subsection_num + ":" + square_num);
						}
					}
				}
				if(finished)
				{
					break;
				}

			}
		}

		print("Ran out of digging sites. It was fun while it lasted.", "red");
		summarize_result(turns_used, result_list);
		cli_execute("csend * fossilized limb to twistedmage");
		cli_execute("csend * fossilized wing to twistedmage");
		cli_execute("csend * fossilized spike to twistedmage");
		cli_execute("csend * volcanic ash to twistedmage");
		cli_execute("csend * unearthed potsherd to twistedmage");
		cli_execute("csend * fossilized baboon skull to twistedmage");
		cli_execute("csend * fossilized bat skull to twistedmage");
		cli_execute("csend * fossilized serpent skull to twistedmage");
		cli_execute("csend * fossilized spine to twistedmage");
		cli_execute("csend * fossilized torso to twistedmage");
	}
}