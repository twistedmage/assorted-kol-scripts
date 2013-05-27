import <QuestLib.ash>;
import <Unlock Temple.ash>;
import <zlib.ash>

/*
string [int] citymap;
string urldata;

int altarcount = 0;
int spheres = 0;

void visit_city()
{
	urldata = visit_url("hiddencity.php");
	// I need to figure out what will be returned if the hiddencity is locked
	// so we can abort safely in that case
	if(contains_text(urldata, "Combat!"))
		abort("You're still in the middle of a combat!");
	if(!contains_text(urldata, "ruin"))
		abort("No ruins found!");
	string search = "http://images.kingdomofloathing.com";
	urldata = replace_string(urldata, search, "IMAGES");
} // visit_city

// used to find either altars, explored ruins, or unexplored ruins
void find_generic(string type, string text1, string text2)
{
	string text;
	if (type == "altar")
		altarcount = 0;
	for i from 0 upto 24 by 1
	{
		text = text1 + i + text2;
		if(contains_text(urldata, text))
		{
			// print(type + " at " + i);
			if(type == "altar")
				altarcount = altarcount + 1;
			citymap[i] = type;
		}
	}
}

void update_map()
{
	visit_city();
	find_generic("altar", "hiddencity.php?which=", "'><img src=\"IMAGES/otherimages/hiddencity/map_altar.gif");
	find_generic("explored ruin", "hiddencity.php?which=", "'><img src=\"IMAGES/otherimages/hiddencity/map_ruins");
	find_generic("unexplored ruin", "hiddencity.php?which=", "'><img src=\"IMAGES/otherimages/hiddencity/map_unruins");
	// '><img src=\"IMAGES/otherimages/hiddencity/map_temple.gif
	find_generic("smallish temple", "hiddencity.php?which=", "'><img src=\"IMAGES/otherimages/hiddencity/map_temple.gif");
}

int get_next_unexplored()
{
	for i from 0 upto 24 by 1
	{
		if(citymap[i] == "unexplored ruin")
			return i;
	}

	return -1;
}

int sphere_count()
{
	// this counts how many spheres we have
	int count = item_amount($item[mossy stone sphere]);
	count = count + item_amount($item[rough stone sphere]);
	count = count + item_amount($item[smooth stone sphere]);
	count = count + item_amount($item[cracked stone sphere]);
	print("spheres : " + count);
	return count;
}

boolean spheres_identified()
{
	string stone1 = get_property("lastStoneSphere2174");
	string stone2 = get_property("lastStoneSphere2175");
	string stone3 = get_property("lastStoneSphere2176");
	string stone4 = get_property("lastStoneSphere2177");
	if(stone1!="" && stone2!="" && stone3!="" && stone4!="")
	{
		return true;
	}
	return false;
}

void id_spheres()
{
	while(!spheres_identified())
	{
		adventure(1,$location[Degrassi knoll]);
	}
}

boolean altar_check()
{
	// this checks if we have found all 4 altars, and the smallish temple
	if((altarcount == 4) && (contains_text(urldata, "map_temple")))
		return true;

	return false;
}

string throw_spheres(string url)
{
	int funk_item = 0;

	for i from 2174 to 2177
	{
		boolean should_throw = true;
		if (item_amount(to_item(i)) > 0)
			if (get_property("lastStoneSphere" + to_string(i)) != "")
				should_throw = false;
		else
			should_throw = false;

		if (should_throw)
		{
			if (!have_skill($skill[Ambidextrous Funkslinging]))
			{
				url = throw_item(to_item(i));
			}
			else
			{
				if (funk_item == 0)
                    funk_item = i;
				else
				{
					url = throw_items(to_item(funk_item), to_item(i));
					funk_item = 0;
				}
			}
		}			
	}

	if (funk_item != 0)
	{
		throw_item(to_item(funk_item));
	}

	return url;
}

void explore(int citysquare)
{
	print("exploring square : " + citysquare);
	request_monsterlevel(0);
	string url = visit_url("hiddencity.php?which=" + citysquare);
	while(!contains_text(url, "WINWINWIN") && !contains_text(url, "slink away dejected"))
	{
		throw_spheres(url);
		url=run_combat();
	}
}

boolean explore_entire_city()
{
	update_map();
	spheres = sphere_count();
	
	// spheres get traded in for stones
	// if we have all 4 stones/spheres already, AND all altars found, we're already done
	if(((available_amount(to_item("triangular stone")) + spheres) == 4) && altar_check())
	{
		id_spheres();
		return true;
	}		
	
	// as long as we dont have all 4 spheres, 4 altars, and the smallish temple
	// keep exploring
	repeat
	{
		int i = get_next_unexplored();
		if (i == -1)
		{
			return true;			
		}

		if (my_adventures() == 0)
		{
			abort("Ran out of adventures");
		}

		
		explore(i);
		update_map();

		spheres = sphere_count();
		if(altar_check())
			print("altars and temple all found!");
		print("altars : " + altarcount);

	} until ((spheres == 4) && altar_check());
	
	print("done!");
	return true;
}

item give_appropriate_stone(string page)
{
	item this_stone(string desc)
	{
		if(get_property("lastStoneSphere2174") == desc)
			return to_item(2174);
		else if(get_property("lastStoneSphere2175") == desc)
			return to_item(2175);
		else if(get_property("lastStoneSphere2176") == desc)
			return to_item(2176);
		else if(get_property("lastStoneSphere2177") == desc)
			return to_item(2177);
		else
			abort("correct stone not found!");
			
		return to_item(1);
	}
	
	// altar1.gif - lightning
	// altar2.gif - water
	// altar3.gif - fire
	// altar4.gif - nature
	if(contains_text(page, "altar1.gif"))
	{
		print("Lightning!");
		return this_stone("lightning");
	}
	else if(contains_text(page, "altar2.gif"))
	{
		print("Water!");
		return this_stone("water");
	}
	else if(contains_text(page, "altar3.gif"))
	{
		print("Fire!");
		return this_stone("fire");
	}
	else if(contains_text(page, "altar4.gif"))
	{
		print("Nature!");
		return this_stone("nature");
	}

	abort("correct stone not found!");
	return to_item(1);
}

boolean get_triangular_stones()
{
	if(item_amount(to_item("triangular stone")) == 4)
		return true;
	if(!altar_check())
		return false;
		
	for i from 0 upto 24 by 1
	{
		if(citymap[i] == "altar")
		{
			// put the stone into this altar
			string url = visit_url("hiddencity.php?which=" + i);
			if (contains_text(url, "the altar doesn't really do anything but look neat"))
				print("already used this altar");
			else
			{
				item stone = give_appropriate_stone(url);
				if (stone != to_item(1))
				{
					print("Using stone : " + to_string(stone));
					
					// interesting... it doesnt use the url to remember which altar
					// you're inserting a round object into..
					// hiddencity.php?action=roundthing&whichitem=2176
					url = visit_url("hiddencity.php?action=roundthing&whichitem=" + to_int(stone));
					if (contains_text(url, "tristone.gif"))
						print("Successfully inserted sphere!");
					else
						abort("something went wrong!");				
				}
			}
		}
	}
	if(available_amount(to_item("triangular stone")) == 4)
		return true;
	
	return false;
}

boolean finish_city()
{
	print("called finish city","green");
	if(!get_triangular_stones())
		return false;
	print("finished get triangular stones","green");
	if(!altar_check())
		return false;
	print("finished altar check","green");
	
	for i from 0 upto 24 by 1
	{
		if(citymap[i] == "smallish temple")
		{
			print("found temple","green");
			request_monsterlevel(0);
			visit_url("hiddencity.php?which=" + i);
			visit_url("hiddencity.php?action=trisocket");
			string url = visit_url("hiddencity.php?which="+i);
			run_combat();
			return true;
		}
	}
	return false;
}
*/


//stolen from zarqon
boolean do_hiddencity() {
/*
  Hidden City Layout
  N - nature        0 - unexplored         T - temple
  L - lightning     E - explored           A - archaeologist
  F - fire          P - protector spectre
  W - water         D - defeated spectre
*/
   if (item_amount($item[ancient amulet]) + item_amount($item[headpiece of the staff of ed]) +
      item_amount($item[staff of ed, almost]) + item_amount($item[staff of ed]) > 0) return vprint("You have already completed the Hidden City.",2);
   if (to_int(get_property("lastHiddenCityAscension")) != my_ascensions()) visit_url("hiddencity.php");
   cli_execute("conditions clear");
   string prop = to_lower_case(get_property("hiddenCityLayout"));
   if (get_property("autoSphereID") == "false") vprint("WARNING: Mafia is not set to automatically ID stone spheres!","olive",-2);

   int get_first(string hunt) {
      for i from 1 to length(prop)
         if (substring(prop,i-1,i) == hunt) return i;
      return 0;
   }
   boolean hc_adventure(string hunt) {
		cli_execute("recover both");
      if (get_first(hunt) == 0) return false;
      set_property("hiddenCitySquare",get_first(hunt));
      if (!adv1($location[hidden city],-1,"")) return vprint("Debug: adv1 returned false.",-7);
      prop = to_lower_case(get_property("hiddenCityLayout"));
      return true;
   }
   boolean reveal_square(string hunt) {
      while (!contains_text(prop,hunt))
         if (!hc_adventure("0")) return false;
      return true;
   }
   item this_stone(string desc) {
      for i from 2174 to 2177
         if (get_property("lastStoneSphere"+i) == desc) return to_item(i);
      print("Couldn't ID '"+desc+"' stone.  Trying to adventure in spooky forest and find it.","red");
	  while(get_property("lastStoneSphere2174") != desc && get_property("lastStoneSphere2175") != desc && get_property("lastStoneSphere2176") != desc && get_property("lastStoneSphere2177") != desc && my_adventures()>0)
	  {
			set_property("choiceAdventure502","3");
			set_property("choiceAdventure506","1");
			set_property("choiceAdventure26","2");
			set_property("choiceAdventure28","2");
			adventure(1,$location[spooky forest]);
	  }
      for i from 2174 to 2177
         if (get_property("lastStoneSphere"+i) == desc) return to_item(i);
      vprint("Still couldn't ID '"+desc+"' stone.  You may have to identify the stones yourself.",0);
      return $item[none];
   }
   boolean do_altar(string god) {
      vprint("Finding the altar of "+god+"...",2);
      if (!reveal_square(substring(god,0,1))) return vprint("Unable to reveal the "+god+" altar.",-2);
      if (item_amount(this_stone(god)) > 0) cli_execute("hiddencity "+get_first(substring(god,0,1))+" altar "+this_stone(god));
      return (item_amount(this_stone(god)) == 0);
   }

   
	if(!get_property("spheres_collected_this_ascension").to_boolean())
	{
	    print("Getting spheres","green");
	   while (item_amount($item[mossy stone sphere]) + item_amount($item[rough stone sphere]) + item_amount($item[triangular stone]) +
			  item_amount($item[smooth stone sphere]) + item_amount($item[cracked stone sphere]) < 4 && my_adventures()>0) {
		  if (get_first("p") > 0) {
			 if (!hc_adventure("p")) return false;
		  } else if (!hc_adventure("0")) return false;
	   }
	   if(item_amount($item[mossy stone sphere]) + item_amount($item[rough stone sphere]) + item_amount($item[triangular stone]) +
			  item_amount($item[smooth stone sphere]) + item_amount($item[cracked stone sphere]) < 4 && my_adventures()>0)
	   {
			set_property("spheres_collected_this_ascension",true);
	   }
   }
   if (my_adventures()>0 && do_altar("nature") && do_altar("lightning") && do_altar("fire") && do_altar("water") && reveal_square("t") && (item_amount($item[ancient amulet]) + item_amount($item[headpiece of the staff of ed]) +
                                                item_amount($item[staff of ed, almost]) + item_amount($item[staff of ed]) < 1))
   {
	 print("Going to temple","green");
	 print("hiddencity "+get_first("t")+" temple","green");
     cli_execute("hiddencity "+get_first("t")+" temple");
	 run_combat();
	 set_property("spheres_collected_this_ascension",false);
   }
   return (item_amount($item[ancient amulet]) > 0 && vprint("Hidden city complete.",2));
}

void HiddenCityQuest()
{
	UnlockTemple();

	if (contains_text(visit_url("questlog.php?which=1"),"Gotta Worship Them All"))
	{
		dress_for_fighting();
		int needed = 15-item_amount($item[scroll of ancient forbidden unspeakable evil]);
		if(needed<0)
		{
			needed=0;
		}
		else
		{
			buy(needed,$item[scroll of ancient forbidden unspeakable evil]);
		}
		while (!contains_text(visit_url("woods.php"),"hiddencity.gif") && my_adventures()>0)
		{
			adventure(request_apathetic(1), $location[Hidden Temple]);
		}

		if (contains_text(visit_url("woods.php"),"hiddencity.gif"))
		{
			print("Calling do_hiddencity","green");
			do_hiddencity();
			/*
			explore_entire_city();
			if (get_triangular_stones())
			{
				finish_city();
			}		
			*/			
		}
	}
	else if (contains_text(visit_url("questlog.php?which=2"),"Gotta Worship Them All"))
	{
		print("You have already completed Gotta Worship Them All.");
	}
	else
	{
		print("Gotta Worship Them All is not currently available.");
	}
}


void main ()
{
	HiddenCityQuest();
}
