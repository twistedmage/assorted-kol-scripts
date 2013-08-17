/*
 Pork to the Future! (version 1.01)
 
 Completely completes the Future quest, after completing the Hyboria quest, after completing the Cyrus quest.
 
 To kill extra Wumpii while doing the quest, paste this into the CLI:
 set porkfutureWumpusGenocide = true
 
 To find and kill one Wumpus, visit its lair and run the script; it will stop after killing him (or you).
 Or, use the companion script WumpusFarm.ash to kill numerous wumpii and/or get the Wumpus trophy.
 
 The script may need to adjust your auto-recovery settings, because if the Wumpus doesn't kill you, Cyrus will. Repeatedly.
 Bale's Universal_recovery.ash is, as always, recommended.
 
 Auteur: Guyy
 Gemelli's Wumpinator was used to test the Wumpus-killing script, but "Wumpwn" operates independently of
 Wumpinator and is actually slightly better at finding the Wumpus. *happy dance*
*/

script "PorkFuture.ash";
notify guyy;

boolean wumpus_genocide;
boolean wumpus_hunt;
int wumpus_delay = 0;   // seconds to wait between steps in wumpus-hunting procedure (for debugging)

string advstring;

string tween_text(string searchme, string pre, string post)
{
	int starts, ends;
	starts = index_of(searchme,pre);
	if (starts > 0)
		ends = index_of(searchme,post,starts);
	if (starts > 0 && ends > 0 && (starts + length(pre)) < ends)
		return substring(searchme, (starts + length(pre)), ends);
	else
		return "";
}

void noncombat_mood()
{
	if (my_familiar() == $familiar[hound dog])
		use_familiar($familiar[none]);
	cli_execute("maximize -combat");
	cli_execute("mood porkfuture");
	cli_execute("mood clear");
	if (have_skill($skill[smooth movement]))
		cli_execute("trigger lose_effect, smooth movements, cast 1 smooth movement");
	if (have_skill($skill[sonata of sneakiness]))
		cli_execute("trigger lose_effect, sonata of sneakiness, cast 1 sonata of sneakiness");
	cli_execute("trigger gain_effect, musk of the moose, uneffect musk of the moose");
	cli_execute("trigger gain_effect, cantata of confrontation, uneffect cantata of confrontation");
}

boolean in_combat()
{
	return (contains_text(advstring,"<b>Combat") && !contains_text(advstring,"You win the fight!") &&
	!contains_text(advstring,"You slink away, dejected and defeated."));
}

boolean combat_victory()
{
	return contains_text(advstring,"You win the fight!");
}

void bottle_bouncer()
{
	if (item_amount($item[empty agua de vida bottle]) <= 0)
		abort("You're out of agua de vida bottles!");
}

void bottle_iku(int past_present_fuschia)
{
	bottle_bouncer();
	if (my_adventures() == 0)
		abort("Out of adventures!");
	
	boolean bottle_smash()   // repeat request if bottle breaks. this only works with visit_url, unfortunately
	{
		return contains_text(advstring,"You break the bottle on the ground, and stomp it to powder");
	}
	
	if (my_hp() < (my_maxhp() / 10) || have_effect($effect[beaten up]) > 0)
	{
		cli_execute("recover hp");
		cli_execute("uneffect beaten up");
	}
	cli_execute("mood execute");
	if (past_present_fuschia == 1)
		adventure(1,$location[Primordial Soup]);
	else if (past_present_fuschia == 2)
		adventure(1,$location[Jungles of Ancient Loathing]);
	else if (past_present_fuschia == 3)
		adventure(1,$location[Seaside Megalopolis]);
	else
	{
		advstring = visit_url("adventure.php?snarfblat="+past_present_fuschia);
		if (bottle_smash())
		{
			bottle_bouncer();
			advstring = visit_url("adventure.php?snarfblat="+past_present_fuschia);
		}
	}
}

void set_autoheal()
{
	// need to heal after Cyrus/Wumpus pwns us
	if (get_property("hpAutoRecovery").to_int() < 0.2)
		set_property("hpAutoRecovery","0.2");
	if (get_property("hpAutoRecoveryItems").to_string() == "")
		set_property("hpAutoRecoveryItems","cannelloni cocoon;scroll of drastic healing;tongue of the walrus;lasagna bandages;doc galaktik's ailment ointment");
	if (get_property("hpAutoRecoveryTarget").to_int() < 0.5)
		set_property("hpAutoRecoveryTarget","0.5");
}

string manual_noncom(int choice_number, int valyew)
{
	if (!wumpus_hunt)
		bottle_bouncer();
	advstring = visit_url("choice.php?whichchoice=" + choice_number + "&option=" + valyew + "&pwd=" + my_hash());
	return advstring;
}

boolean in_wumpus_cave()
{
	return (contains_text(advstring,"genericave.gif") || 
	contains_text(advstring,"you notice the mouth of a cave"));
}

// Navigate the Wumpus's lair and kill it; by far the most complex part of the whole quest.
// Note that success in one try is not guaranteed, because sometimes making risky moves is necessary to find the Wumpus.
// If it fails, it will remember the cave and its error(s) for next time.
boolean Wumpwn()
{
	string namae = replace_string(my_name()," ","_");
	string wumpus_rooms = "ABCDEFGHILMNOPQRSUVW";
	string wumpus_room_suffix = " Chamber";
	string[string] wumpus_room_names;
	wumpus_room_names["A"] = "Acrid";
	wumpus_room_names["B"] = "Breezy";
	wumpus_room_names["C"] = "Creepy";
	wumpus_room_names["D"] = "Dripping";
	wumpus_room_names["E"] = "Echoing";
	wumpus_room_names["F"] = "Fetid";
	wumpus_room_names["G"] = "Gloomy";
	wumpus_room_names["H"] = "Howling";
	wumpus_room_names["I"] = "Immense";
	wumpus_room_names["L"] = "Long";
	wumpus_room_names["M"] = "Moaning";
	wumpus_room_names["N"] = "Narrow";
	wumpus_room_names["O"] = "Ordinary";
	wumpus_room_names["P"] = "Pillared";
	wumpus_room_names["Q"] = "Quiet";
	wumpus_room_names["R"] = "Round";
	wumpus_room_names["S"] = "Sparkling";
	wumpus_room_names["U"] = "Underground";
	wumpus_room_names["V"] = "Vaulted";
	wumpus_room_names["W"] = "Windy";
	
	boolean found_wumpus;
	int pits_found;
	int bats_found;
	string wumpus_explored;
	int wumpus_flags;

	string[int] wumpus_etc;
	string[string] wumpus_hazards;
	string[string] wumpus_bats;
	string[string] wumpus_pit;
	string[string] wumpus_wump;
	boolean[string] wumpus_explorable;
	string[int,string] wumpus_adj_rooms;
	int[string] wumpus_exp;   // # of surrounding rooms explored

	int wumpus_path_step;
	int wumpus_path_length;
	string[int] wumpus_path;

	int gonext;
	int w_timeout;
	string curroom;
	string nextroom;
	string[int] adjroom;
	boolean danger_zone;
	boolean murdered_wumpus;
	
	boolean wumpus_safe(string disroom)
	{
		return (wumpus_bats[disroom] == "0" && wumpus_pit[disroom] == "0" && wumpus_wump[disroom] == "0");
	}
	
	string room_name(string r)
	{
		return (wumpus_room_names[r] + wumpus_room_suffix);
	}
	
	string room_name_i(int i)
	{
		return substring(wumpus_rooms,i,i+1);
	}
	
	// Determine a path to a room, following known safe rooms (the last room doesn't have to be safe).
	boolean pathfind(string endroom)
	{
		if (curroom == endroom)
			return false;
		
		string yew_arr_hear;
		string go_thar;
		string passed_rooms;
		string dead_ends;
		
		for h from 1 to 20
		{
			yew_arr_hear = curroom;
			wumpus_path_step = 0;
			passed_rooms = "";
			for i from 1 to 20
			{
				wumpus_path_step += 1;
				go_thar = "";
				for j from 1 to 3
				{
					go_thar = wumpus_adj_rooms[j,yew_arr_hear];
					if (go_thar == endroom || (wumpus_safe(go_thar) && !wumpus_explorable[go_thar] && 
					!contains_text(dead_ends,go_thar) && !contains_text(passed_rooms,go_thar)))
					{
						wumpus_path[wumpus_path_step] = go_thar;
						break;
					}
					else if (j == 3)
						dead_ends += yew_arr_hear;
				}
				if (contains_text(dead_ends,yew_arr_hear))
					break;
				if (go_thar == endroom)
				{
					wumpus_path_length = wumpus_path_step;
					wumpus_path_step = 0;
					return true;
				}
				passed_rooms += yew_arr_hear;
				yew_arr_hear = go_thar;
			}
		}
		return false;
	}
	
	void confirm_bats(string c)
	{
		wumpus_bats[c] = "BB";
		wumpus_pit[c] = "0";
		wumpus_wump[c] = "0";
		print("Bat swarm echolocated in the " + room_name(c) + ".","blue");
	}
	
	void confirm_pit(string c)
	{
		wumpus_bats[c] = "0";
		wumpus_pit[c] = "PP";
		wumpus_wump[c] = "0";
		if (wumpus_hunt)
			print("Pit discovered in the " + room_name(c) + ".","blue");
	}
	
	void found_wumpus(string c)
	{
		if (!found_wumpus)
		{
			found_wumpus = true;
			wumpus_bats[c] = "0";
			wumpus_pit[c] = "0";
			wumpus_wump[c] = "WW";
			if (!wumpus_hunt)
				print("Wumpus detected in the " + room_name(c) + ". Unfortunately, you are dead.","blue");
			else if (adjroom[1] == c || adjroom[2] == c || adjroom[3] == c || pathfind(c))
				print("Wumpus detected in the " + room_name(c) + ". Sneaking up on him...","blue");
			else
				print("Wumpus detected in the " + room_name(c) + ", but can't find a route to him yet. Wandering aimlessly...","blue");
			waitq(wumpus_delay);
		}
	}
	
	void null_wumpus(string s)  // if only 2 wumpus flags are left, and we eliminate one, it has to be the other
	{
		string disroom;
		if (wumpus_wump[s] == "W" && wumpus_flags == 2)
		{
			wumpus_wump[s] = "0";
			wumpus_flags -= 1;
			if (wumpus_flags == 1)
			{
				for i from 0 to (length(wumpus_rooms)-1)
				{
					disroom = room_name_i(i);
					if (wumpus_wump[disroom] == "W")
					{
						found_wumpus(disroom);
						break;
					}
				}
			}
		}
		else
			wumpus_wump[s] = "0";
	}
	
	int fork_test(string roomlabels, string hazard)
	{
		if (roomlabels == hazard + "00")
			return 1;
		else if (roomlabels == "0" + hazard + "0")
			return 2;
		else if (roomlabels == "00" + hazard)
			return 3;
		else
			return 0;
	}
	
	void room_scan(int cycles)
	{
		int sporky;
		string disroom;
		string datroom;
		string blocked_room;
		
		for loopy from 1 to cycles
		{
			pits_found = 0;
			bats_found = 0;
		
			// upgrade rooms from maybes to yesses
			for i from 0 to (length(wumpus_rooms)-1)
			{
				disroom = room_name_i(i);
				
				// visited all adjacent rooms -> we know exactly what's in there (because there's only 2 of each hazard)
				// only one wumpus, so only 2 adjacent room visits are needed
				if (wumpus_exp[disroom] >= 3)
				{
					if (wumpus_bats[disroom] == "B")
						confirm_bats(disroom);
					else if (wumpus_pit[disroom] == "P")
						confirm_pit(disroom);
				}
				if (wumpus_exp[disroom] >= 2 && wumpus_wump[disroom] == "W")
					found_wumpus(disroom);
				
				// if two different rooms are marked for the same hazard by two non-overlapping pairs of rooms, they are both that hazard.
				// (the two mutually exclusive pairs of warnings require that the two hazards be placed between each pair)
				if (wumpus_exp[disroom] >= 2 && (wumpus_bats[disroom] == "B" || wumpus_pit[disroom] == "P"))
				{
					for j from 0 to (length(wumpus_rooms)-1)
					{
						datroom = substring(wumpus_rooms,j,j+1);
						if (datroom != disroom && wumpus_exp[disroom] >= 2 && 
						wumpus_adj_rooms[1,disroom] != wumpus_adj_rooms[1,datroom] && wumpus_adj_rooms[1,disroom] != wumpus_adj_rooms[2,disroom] && 
						wumpus_adj_rooms[1,disroom] != wumpus_adj_rooms[3,datroom] && wumpus_adj_rooms[2,disroom] != wumpus_adj_rooms[2,disroom] && 
						wumpus_adj_rooms[2,disroom] != wumpus_adj_rooms[3,datroom] && wumpus_adj_rooms[3,disroom] != wumpus_adj_rooms[3,disroom])
						{
							if (wumpus_bats[disroom] == "B" && contains_text(wumpus_bats[datroom],"B"))
							{
								confirm_bats(disroom);
								confirm_bats(datroom);
							}
							else if (wumpus_pit[disroom] == "P" && contains_text(wumpus_pit[datroom],"P"))
							{
								confirm_pit(disroom);
								confirm_pit(datroom);
							}
						}
					}
				}
				
				// can also find a hazard if room has one nearby, and 2/3 adjacent rooms are safe
				sporky = fork_test(wumpus_bats[wumpus_adj_rooms[1,disroom]]+wumpus_bats[wumpus_adj_rooms[2,disroom]]+wumpus_bats[wumpus_adj_rooms[3,disroom]],"B");
				if (sporky > 0 && contains_text(wumpus_hazards[disroom],"bats"))
					confirm_bats(wumpus_adj_rooms[sporky,disroom]);
				sporky = fork_test(wumpus_pit[wumpus_adj_rooms[1,disroom]]+wumpus_pit[wumpus_adj_rooms[2,disroom]]+wumpus_pit[wumpus_adj_rooms[3,disroom]],"P");
				if (sporky > 0 && contains_text(wumpus_hazards[disroom],"pit"))
					confirm_pit(wumpus_adj_rooms[sporky,disroom]);
				if (!found_wumpus)
				{
					sporky = fork_test(wumpus_wump[wumpus_adj_rooms[1,disroom]]+wumpus_wump[wumpus_adj_rooms[2,disroom]]+wumpus_wump[wumpus_adj_rooms[3,disroom]],"W");
					if (sporky > 0 && contains_text(wumpus_hazards[disroom],"wumpus"))
						found_wumpus(wumpus_adj_rooms[sporky,disroom]);
				}
				
				if (!contains_text(wumpus_explored,disroom) && 
				(wumpus_pit[wumpus_adj_rooms[1,disroom]] || wumpus_bats[wumpus_adj_rooms[1,disroom]]) && 
				(wumpus_pit[wumpus_adj_rooms[2,disroom]] || wumpus_bats[wumpus_adj_rooms[2,disroom]]) &&
				(wumpus_pit[wumpus_adj_rooms[3,disroom]] || wumpus_bats[wumpus_adj_rooms[3,disroom]]))
					blocked_room = disroom;
					
				if (wumpus_bats[disroom] == "BB")
					bats_found += 1;
				else if (wumpus_pit[disroom] == "PP")
					pits_found += 1;
				else if (wumpus_wump[disroom] == "WW" && !found_wumpus)
					found_wumpus(disroom);
			}
			
			// cleanup
			wumpus_flags = 0;
			for i from 0 to (length(wumpus_rooms)-1)
			{
				disroom = room_name_i(i);
				wumpus_explorable[disroom] = (wumpus_safe(disroom) && !contains_text(wumpus_explored,disroom));
				if (bats_found == 2 && wumpus_bats[disroom] == "B")
					wumpus_bats[disroom] = "0";
				else if (pits_found == 2 && wumpus_pit[disroom] == "P")
					wumpus_pit[disroom] = "0";
				else if (found_wumpus && wumpus_wump[disroom] == "W")
					wumpus_wump[disroom] = "0";
				if (wumpus_wump[disroom] == "W")
					wumpus_flags += 1;
			}
		}
		
		if (bats_found > 2 || pits_found > 2)
			abort("There's an impossible number of hazards in here! Something went wrong.");
		if (blocked_room != "" && !found_wumpus && length(wumpus_explored) >= 15 && wumpus_flags == 0)
			abort("The " + room_name(blocked_room) + " has hazards on all 3 sides, and the Wumpus must be in there, because we've checked everywhere else. Since we can't charge in, killing him is impossible. You'll have to ascend and try again. Stupid wumpus.");
	}
	
	void change_room(int i)
	{
		int superbutton = i;
	
		gonext = i;
		if (gonext > 3)
			gonext -= 3;
		if (i < 3 && wumpus_flags == 2 && wumpus_wump[adjroom[i]] == "W")
			superbutton += 3;
		manual_noncom(360,superbutton);
		if (superbutton > 3 && in_combat())
		{
			wumpus_hunt = false;
			advstring = run_combat();
			if (combat_victory())
				murdered_wumpus = true;
			else
				print("Successfully attacked the Wumpus, but he beat you up!","red");
		}
	}
	
	void wumpus_path_follow()
	{
		if (wumpus_path_length > 0)   // follow preset path to unexplored room or Wumpus
		{
			wumpus_path_step += 1;
			if (wumpus_path_length == wumpus_path_step)
				wumpus_path_length = 0;
			for i from 1 to 3
				if (wumpus_path[wumpus_path_step] == adjroom[i])
					change_room(i);
		}
	}
	
	void kill_wumpus(int i)
	{
		print("Found the Wumpus! Murderfying.","blue");
		waitq(wumpus_delay);
		change_room(3+i);
	}
	
	string extract_room_letter()
	{
		return to_upper_case(substring(tween_text(advstring, 'bgcolor=blue><b>The ',' Chamber'),0,1));
	}
	
	string extract_adj_letter(int d)
	{
		return to_upper_case(substring(tween_text(advstring, 'value='+d+'><input class=button type=submit value="Enter the ', ' chamber'),0,1));
	}
	
	void enter_chamber()
	{
		curroom = extract_room_letter();
		print("Safely entered the " + room_name(curroom),"green");
		adjroom[1] = extract_adj_letter(1);
		adjroom[2] = extract_adj_letter(2);
		adjroom[3] = extract_adj_letter(3);
		
		wumpus_hazards[curroom] = "";
		if (contains_text(advstring,"You hear a low roaring sound nearby"))
			wumpus_hazards[curroom] += " pit ";
		if (contains_text(advstring,"You hear the fluttering of wings"))
			wumpus_hazards[curroom] += " bats ";
		if (contains_text(advstring,"Spatters of blood covering the floor"))
			wumpus_hazards[curroom] += " wumpus ";
		danger_zone = (length(wumpus_hazards[curroom]) > 0);
		if (wumpus_hazards[curroom] == "")
			print("No hazards nearby","green");
		else
			print("Nearby hazards:" + wumpus_hazards[curroom],"red");
		waitq(wumpus_delay);
		
		wumpus_explorable[curroom] = false;
		wumpus_pit[curroom] = "0";
		wumpus_bats[curroom] = "0";
		null_wumpus(curroom);
		
		for i from 1 to 3
			wumpus_adj_rooms[i,curroom] = adjroom[i];
	}
	
	void save_wumpus_data()
	{
		map_to_file(wumpus_hazards,"porkfuture/"+namae+"/wumpus_hazards.txt");
		map_to_file(wumpus_bats,"porkfuture/"+namae+"/wumpus_bats.txt");
		map_to_file(wumpus_pit,"porkfuture/"+namae+"/wumpus_pit.txt");
		map_to_file(wumpus_wump,"porkfuture/"+namae+"/wumpus_wump.txt");
		map_to_file(wumpus_explorable,"porkfuture/"+namae+"/wumpus_explorable.txt");
		map_to_file(wumpus_adj_rooms,"porkfuture/"+namae+"/wumpus_adj_rooms.txt");
		map_to_file(wumpus_exp,"porkfuture/"+namae+"/wumpus_exp.txt");
		wumpus_etc[1] = wumpus_explored;
		wumpus_etc[2] = item_amount($item[wumpus hair]);
		wumpus_etc[3] = my_ascensions();
		wumpus_etc[4] = "four";  // make sure it loaded something
		map_to_file(wumpus_etc,"porkfuture/"+namae+"/wumpus_etc.txt");
	}
	
	// note: does not actually erase the saved data; just marks it as invalid for loading (may need it to kill bugs)
	void erase_wumpus_data()
	{
		wumpus_explored = "";
		for i from 0 to (length(wumpus_rooms)-1)
		{
			wumpus_hazards[room_name_i(i)] = "";
			wumpus_bats[room_name_i(i)] = "";
			wumpus_pit[room_name_i(i)] = "";
			wumpus_wump[room_name_i(i)] = "";
			wumpus_explorable[room_name_i(i)] = false;
				for j from 1 to 3
					wumpus_adj_rooms[j,room_name_i(i)] = "";
			wumpus_exp[room_name_i(i)] = 0;
		}
		wumpus_etc[4] = "ten";
		map_to_file(wumpus_etc,"porkfuture/"+namae+"/wumpus_etc.txt");
	}
	
	void load_wumpus_data()
	{
		file_to_map("porkfuture/"+namae+"/wumpus_etc.txt",wumpus_etc);
		if (wumpus_etc[4] == "four" && wumpus_etc[1] != "" && substring(wumpus_etc[1],0,1) == extract_room_letter() && 
		wumpus_etc[2].to_int() == item_amount($item[wumpus hair]) && wumpus_etc[3].to_int() == my_ascensions())
		{
			print("This looks like the same cave as last time. If it isn't, delete the folder data/porkfuture/"+namae+".","blue");
			wumpus_explored = wumpus_etc[1];
			file_to_map("porkfuture/"+namae+"/wumpus_hazards.txt",wumpus_hazards);
			file_to_map("porkfuture/"+namae+"/wumpus_bats.txt",wumpus_bats);
			file_to_map("porkfuture/"+namae+"/wumpus_pit.txt",wumpus_pit);
			file_to_map("porkfuture/"+namae+"/wumpus_wump.txt",wumpus_wump);
			file_to_map("porkfuture/"+namae+"/wumpus_explorable.txt",wumpus_explorable);
			file_to_map("porkfuture/"+namae+"/wumpus_adj_rooms.txt",wumpus_adj_rooms);
			file_to_map("porkfuture/"+namae+"/wumpus_exp.txt",wumpus_exp);
			enter_chamber();
			room_scan(3);
			print("Hazards identified: " + bats_found + "/2 bats, " + pits_found + "/2 pits.","green");
		}
		else
			erase_wumpus_data();
	}
	
	if (advstring == "")
		advstring = visit_url("mall.php");
	if (contains_text(advstring,"you notice the mouth of a cave"))
		manual_noncom(360,1);
	wumpus_path_length = 0;
	if (!in_wumpus_cave())
		abort("Neither in nor near the Wumpus's lair.");
	print("Off to hunt the Wumpus!","blue");
	wumpus_hunt = true;
	found_wumpus = false;
	load_wumpus_data();
	while (wumpus_hunt)
	{
		if (curroom != extract_room_letter())
			enter_chamber();
				
		if (wumpus_hunt && !contains_text(wumpus_explored,curroom))
		{
			wumpus_explored += curroom;
			for i from 1 to 3
				wumpus_exp[adjroom[i]] += 1;
			if (!danger_zone)
			{
				for i from 1 to 3
				{
					wumpus_pit[adjroom[i]] = "0";
					wumpus_bats[adjroom[i]] = "0";
					null_wumpus(adjroom[i]);
				}
			}
			else
			{
				if (pits_found < 2 && contains_text(wumpus_hazards[curroom],"pit"))
				{
					for i from 1 to 3
						if (wumpus_pit[adjroom[i]] == "")
							wumpus_pit[adjroom[i]] = "P";
				}
				else
					for i from 1 to 3
						if (wumpus_pit[adjroom[i]] != "PP")
							wumpus_pit[adjroom[i]] = "0";
				if (bats_found < 2 && contains_text(wumpus_hazards[curroom],"bats"))
				{
					for i from 1 to 3
						if (wumpus_bats[adjroom[i]] == "")
							wumpus_bats[adjroom[i]] = "B";
				}
				else
					for i from 1 to 3
						if (wumpus_bats[adjroom[i]] != "BB")
							wumpus_bats[adjroom[i]] = "0";
				if (!found_wumpus && contains_text(wumpus_hazards[curroom],"wumpus"))
				{
					for i from 1 to 3
					{
						if (wumpus_wump[adjroom[i]] == "")
						{
							wumpus_flags += 1;
							wumpus_wump[adjroom[i]] = "W";
						}
					}
				}
				else
					for i from 1 to 3
						if (wumpus_wump[adjroom[i]] != "WW")
							null_wumpus(adjroom[i]);
			}
			room_scan(3);
			save_wumpus_data();
		}
		for i from 1 to 3
			if (wumpus_wump[adjroom[i]] == "WW")
				kill_wumpus(i);
		if (wumpus_hunt)
		{
			advstring = "";
			if (wumpus_path_length == 0)
				for i from 0 to (length(wumpus_rooms)-1)
					if (wumpus_wump[room_name_i(i)] == "WW" && pathfind(room_name_i(i)))   // pathfind to wumpus
						break;
			if (wumpus_path_length == 0 && !wumpus_explorable[adjroom[1]] && !wumpus_explorable[adjroom[2]] && !wumpus_explorable[adjroom[3]])   // pathfind to safe unexplored room
				for i from 0 to (length(wumpus_rooms)-1)
					if (wumpus_explorable[room_name_i(i)] && pathfind(room_name_i(i)))
						break;
			wumpus_path_follow();
			if (advstring == "")    // go to a safe, unexplored adjacent room
			{
				gonext = 0;
				for i from 1 to 3
					if (!contains_text(wumpus_explored,adjroom[i]) && wumpus_safe(adjroom[i]))
						gonext = i;
				if (gonext > 0)
					change_room(gonext);
			}
			if (advstring == "")    // no safe rooms, so we'll have to take our chances
			{
				// order of preference: possible bats, possible pit, possible wumpus, definite bats (barely even possible).
				// aborts if there are no available routes, but this shouldn't happen because all rooms have 3 exits and there are only 2 pits.
				string danger_thing = "risk encountering bats.";
				w_timeout = 0;
				for i from 0 to (length(wumpus_rooms)-1)
					if (wumpus_bats[room_name_i(i)] == "B" && wumpus_wump[room_name_i(i)] != "W"
					&& !contains_text(wumpus_pit[room_name_i(i)],"P") && pathfind(room_name_i(i)))
						break;
				if (wumpus_path_length == 0)
				{
					for i from 0 to (length(wumpus_rooms)-1)
						if (wumpus_wump[room_name_i(i)] == "W" && !contains_text(wumpus_pit[room_name_i(i)],"P") 
						&& pathfind(room_name_i(i)))
							break;
					danger_thing = "risk getting pwned by the Wumpus.";
				}
				if (wumpus_path_length == 0)
				{
					for i from 0 to (length(wumpus_rooms)-1)
						if (wumpus_pit[room_name_i(i)] == "P" && pathfind(room_name_i(i)))
							break;
					danger_thing = "risk death by bottomless pit.";
				}
				if (wumpus_path_length == 0)
				{
					for i from 0 to (length(wumpus_rooms)-1)
						if (wumpus_bats[room_name_i(i)] == "BB" && wumpus_pit[room_name_i(i)] != "PP" 
						&& pathfind(room_name_i(i)))
							break;
					danger_thing = "dive into a flock of angry bats.";
				}
				if (wumpus_path_length == 0)
					abort("Can't find an unexplored room that isn't a death-pit!");
				else
				{
					print("No safe unexplored rooms. Will have to "+danger_thing,"red");
					waitq(wumpus_delay);
					wumpus_path_follow();
				}
			}
			/*if (advstring == "")   // go to a safe room, randomly selected
			{
				w_timeout = 0;
				while (w_timeout < 50)
				{
					gonext = 1+random(3);
					w_timeout += 1;
					if (wumpus_safe(adjroom[gonext]))
						break;
				}
				if (w_timeout < 50)
					change_room(gonext);
			}*/
			if (advstring == "")
				abort("Can't find a room to enter! This should never happen. Make sure you're actually in the Wumpus lair. If you are, this is a bug!");
			while (contains_text(advstring,"disturbs a massive flock of bats"))   // bats can drop you onto bats; no telling how many times this might happen in a row
			{
				print("We can't stop in the " + room_name(adjroom[gonext]) + "! This is bat country!","red");
				confirm_bats(adjroom[gonext]);
				wumpus_path_length = 0;   // reset path after batportation
				manual_noncom(360,1);
				adjroom[gonext] = extract_room_letter();
			}
			// the bats can drop you into pits and, theoretically, the Wumpus.
			if (contains_text(advstring,"his foot touched nothing but empty air"))
			{
				wumpus_hunt = false;
				print("Wow, this pit in the " + room_name(adjroom[gonext]) + " looks bottomless! I still can't see the...oh, here it comes!","red");
				confirm_pit(adjroom[gonext]);
				manual_noncom(360,1);
			}
			else if (contains_text(advstring,"the wumpus was nowhere to be seen"))
			{
				wumpus_hunt = false;
				print("Alright, " + room_name(adjroom[gonext]) + ", it's go time! GRAAAAAGGHHrrrruh? No Wumpus? Well, this is awkward.","red");
				null_wumpus(adjroom[gonext]);
			}
			else if (contains_text(advstring,"It blinks in surprise"))
			{
				wumpus_hunt = false;
				print("A wild Wumpus appears in the " + room_name(adjroom[gonext]) + "! And kills you!","red");
				found_wumpus(adjroom[gonext]);
			}
		}
	}
	
	if (!murdered_wumpus)
	{
		save_wumpus_data();
		print("Failed to defeat the Wumpus!","red");
		return false;
	}
	else
	{
		erase_wumpus_data();
		print("Ding, dong, the Wumpus is dead!","blue");
		return true;
	}
}

void futurella()
{
	string assquests = visit_url("questlog.php?which=1");
	string compquests = visit_url("questlog.php?which=2");
	
	if (contains_text(compquests,"You've used the power of all six elements to save the world"))
		print("You remember having been going to have saved the future. Already.","green");
	else
	{
		cli_execute("mood porkfuture");
		cli_execute("mood clear");
	
		if (item_amount($item[empty agua de vida bottle]) <= 0)
			abort("You have no agua de vida bottles!");
		else if (my_adventures() <= 0)
			abort("You're out of adventures!");
		else if (my_inebriety() > inebriety_limit())
			abort("You're too drunk for time-travel!");
		if (item_amount($item[empty agua de vida bottle]) < 10 || my_adventures() < 100)
		{
			print("Warning: This quest is long! At least 10 empty agua de vida bottles (you have "+item_amount($item[empty agua de vida bottle])+") and 100 adventures (you have "+my_adventures()+") are recommended for completing it.","red");
			wait(20);
		}
		print("Initiating quest to ruin the past, save the past, and save the future, in that order.","blue");
		wait(5);
		set_autoheal();
	
		if (!contains_text(compquests,"You remember creating an unstoppable supervirus"))
		{
			string used_pairs;
			string last_pair;
			
			print("Upgrading Cyrus...","blue");
			
			if (!contains_text(visit_url("questlog.php?which=1"),"higher, warmer, oranger"))
			{
				while (!contains_text(advstring,"The Primordial Directive") && !contains_text(advstring,"the soup's bounty failed you"))
				{
					bottle_iku(204);
					if (contains_text(advstring,"waking up in some warm little pond"))
						manual_noncom(346,1);
					else if (contains_text(advstring,"floating in warm darkness for long moments"))
						manual_noncom(347,1);
					else if (contains_text(advstring,"blissfully aware of your environment"))
						manual_noncom(348,1);
					else
						manual_noncom(349,3);
				}
				if (contains_text(advstring,"the soup's bounty failed you") || retrieve_item(1,$item[delicious amino acids]))
				{
					if (item_amount($item[delicious amino acids]) > 0)
						use(1,$item[delicious amino acids]);
					bottle_iku(204);
					manual_noncom(349,1);
				}
				if (!contains_text(visit_url("questlog.php?which=1"),"higher, warmer, oranger"))
					abort("Failed to evolve into a rudimentary organism!");
			}
			
			string make_base_pair()
			{
				string returnzor;
				boolean create_pair(string pair)
				{
					if (!contains_text(used_pairs,pair) && retrieve_item(1,to_item(pair)))
					{
						returnzor = pair;
						return true;
					}
					return false;
				}

				if (create_pair("CA base pair") || create_pair("CG base pair") || create_pair("CT base pair")
				|| create_pair("AG base pair") || create_pair("AT base pair") || create_pair("GT base pair"))
					return returnzor;
				return "";
			}
			
			void psyrus()
			{
				if (contains_text(advstring,"You remember feeling very strong"))
					manual_noncom(350,1);
				else if (contains_text(advstring,"Beginner's Luck"))
					manual_noncom(351,1);
				if (in_combat() && contains_text(advstring,"Cyrus") && last_pair != "")
				{
					advstring = throw_item(last_pair.to_item());
					used_pairs += last_pair;
					last_pair = "";
				}
				if (in_combat())
					advstring = run_combat();
			}
			
			if (contains_text(assquests,"remember inadvertently making him"))
			{
				int startloc = index_of(assquests,"remember inadvertently making him");
				string cyrus_buffs = substring(assquests,startloc,index_of(assquests,".",startloc));
				if (contains_text(cyrus_buffs,"attractive"))
					used_pairs += "CT base pair";
				if (contains_text(cyrus_buffs,"smarter"))
					used_pairs += "CG base pair";
				if (contains_text(cyrus_buffs,"stronger"))
					used_pairs += "CA base pair";
				if (contains_text(cyrus_buffs,"resilient"))
					used_pairs += "GT base pair";
				if (contains_text(cyrus_buffs,"aggressive"))
					used_pairs += "AT base pair";
				if (contains_text(cyrus_buffs,"faster"))
					used_pairs += "AG base pair";
			}
			while (!contains_text(advstring,"I can leave this dump behind") && !contains_text(advstring,"your stomach organelle began to rumble"))
			{
				if (length(used_pairs) < 36)
				{
					if (last_pair == "")
						last_pair = make_base_pair();
					if (item_amount($item[ten-leaf clover]) <= 0 && !retrieve_item(1,$item[ten-leaf clover]))
						print("This would go much faster if we had some clovers!","red");
				}
				if (last_pair != "" || length(used_pairs) >= 36)
				{
					while (item_amount($item[delicious amino acids]) > 0)
					{
						if (!use(1,$item[delicious amino acids]))
						{
							use(item_amount($item[ten-leaf clover]),$item[ten-leaf clover]);
							break;
						}
					}
				}
				bottle_iku(204);
				psyrus();
			}
			
			print("Cyrus upgraded! An unwitting instigator of biological devastation is you!","blue");
		}
		
		if (contains_text(assquests,"Having defeated the High Priest of Ki'rhuss"))
			visit_url("town_wrong.php?action=krakrox");
		else if (!contains_text(compquests,"You discovered and dug up the Pork Elves' reward"))
		{
			// [noncom number, (quest*10 + hybored)] = noncom choice
			// For code cleanliness, order is a bit different from the wiki's procedure
			// (it doesn't get the stone circles until after opening the gate).
			int [int, int] hyboria_city;
			string[int] hyboria_tasks;

			// get grappling hook
			hyboria_tasks[1] = "Grab grappling hook";
			hyboria_city[368, 11] = 3;
			hyboria_city[371, 12] = 3;
			hyboria_city[378, 13] = 2;

			// kill octopus
			hyboria_tasks[2] = "Kill octopus";
			hyboria_city[368, 21] = 5;
			hyboria_city[372, 22] = 2;

			// retrieve hook (repeat)
			hyboria_tasks[3] = "Retrieve grappling hook";
			hyboria_city[368, 31] = 5;
			hyboria_city[372, 32] = 2;

			// iron key
			hyboria_tasks[4] = "Get iron key";
			hyboria_city[368, 41] = 2;
			hyboria_city[370, 42] = 1;
			hyboria_city[375, 43] = 2;

			// kill giant spider
			hyboria_tasks[5] = "Slaughter giant spider";
			hyboria_city[368, 51] = 2;
			hyboria_city[370, 52] = 1;
			hyboria_city[375, 53] = 3;
			hyboria_city[379, 54] = 2;

			// get spider's stone block (repeat)
			hyboria_tasks[6] = "Loot small stone block from giant spider's chest (TREASURE chest, not his abdomen)";
			hyboria_city[368, 61] = 2;
			hyboria_city[370, 62] = 1;
			hyboria_city[375, 63] = 3;
			hyboria_city[379, 64] = 2;

			// kill python
			hyboria_tasks[7] = "Execute giant python";
			hyboria_city[368, 71] = 2;
			hyboria_city[370, 72] = 3;
			hyboria_city[377, 73] = 2;
			hyboria_city[380, 74] = 2;
			hyboria_city[380, 75] = 4;  // if the snake is already dead, cut it open

			// cut open python, get stone block (almost-repeat)
			hyboria_tasks[8] = "Slice up python and pull little stone block out of its guts (ew)";
			hyboria_city[368, 81] = 2;
			hyboria_city[370, 82] = 3;
			hyboria_city[377, 83] = 2;
			hyboria_city[380, 84] = 4;

			// put blocks, pull lever
			hyboria_tasks[9] = "Stick blocks in the gate, pull lever";
			hyboria_city[368, 91] = 1;
			hyboria_city[369, 92] = 1;
			hyboria_city[373, 93] = 2;
			hyboria_city[373, 94] = 2;
			hyboria_city[373, 95] = 2;
			hyboria_city[373, 96] = 1;
			hyboria_city[369, 97] = 3;
			hyboria_city[369, 98] = 11;

			// ponder weights
			hyboria_tasks[10] = "Destabilize gate lock mechanism";
			hyboria_city[368, 101] = 2;
			hyboria_city[370, 102] = 3;
			hyboria_city[377, 103] = 3;
			hyboria_city[381, 104] = 2;
			hyboria_city[382, 105] = 2;
			hyboria_city[383, 106] = 1;
			hyboria_city[385, 107] = 4;
			hyboria_city[386, 108] = 2;

			// kick gate
			hyboria_tasks[11] = "Kick the gate down";
			hyboria_city[368, 111] = 1;
			hyboria_city[369, 112] = 1;
			hyboria_city[373, 113] = 2;

			// get stone circle from chest
			hyboria_tasks[12] = "Smash a chest for stone half-circle";
			hyboria_city[368, 121] = 2;
			hyboria_city[370, 122] = 3;
			hyboria_city[377, 123] = 3;
			hyboria_city[381, 124] = 2;
			hyboria_city[382, 125] = 2;
			hyboria_city[383, 126] = 3;
			hyboria_city[384, 127] = 2;
			hyboria_city[384, 128] = 3;

			// kill giant bird
			hyboria_tasks[13] = "Kill giant bird";
			hyboria_city[368, 131] = 3;
			hyboria_city[371, 132] = 1;
			hyboria_city[374, 133] = 3;

			// get bird's stone circle (repeat)
			hyboria_tasks[14] = "Steal half a stone circle from dead bird";
			hyboria_city[368, 141] = 3;
			hyboria_city[371, 142] = 1;
			hyboria_city[374, 143] = 3;

			// go through gate, unlock temple
			hyboria_tasks[15] = "Unlock temple";
			hyboria_city[368, 151] = 1;
			hyboria_city[369, 152] = 1;
			hyboria_city[373, 153] = 2;
			hyboria_city[376, 154] = 3;
		
			print("Being Krakrox...","blue");
			
			boolean krakrox_complete = false;
			int hybored = 1;
			wumpus_genocide = get_property("porkfutureWumpusGenocide").to_boolean();
			
			boolean yr_cultist = false;
			boolean checked_city = false;
			boolean inserted_small_stone = false;
			boolean inserted_little_stone = false;
			boolean killed_octopus = false;
			boolean unlocked_gate = false;
			boolean kicked_gate = false;
			
			void leave_city(int noncom_number)   // exit city (should only happen if hybored is set to the wrong value)
			{
				int index = index_of(advstring,"Leave the City");
				if (index > 0)
					index = last_index_of(advstring,"option value=", index);
				else
					index = last_index_of(advstring,"option value=");
				if (index > 0)
					index = substring(advstring, (index + 13), (index + 14)).to_int();
				if (index > 0)
					manual_noncom(noncom_number,index);
			}
			
			void explore_city()
			{
				int hystep = 1;
				int last_venture;
				int venture = 366;
				int action;
			
				while (!in_combat() && venture < 386)
				{
					venture += 1;
					action = hyboria_city[venture, ((hybored*10)+hystep)];
					if (action == 11)
					{
						hybored += 1;
						venture = 366;
						hystep = 1;
					}
					else if (action > 0)
					{
						
						if (hystep == 1)
							print("Ancient City, part "+hybored+"/15: "+hyboria_tasks[hybored],"blue");
						manual_noncom(venture, action);
						hystep += 1;
						last_venture = venture;
						venture = 366;
					}
				}
				if (hybored == 15 && !contains_text(advstring,"The temple is now open to you"))
					abort("Failed to unlock the temple!");
				else if (in_combat())
				{
					advstring = run_combat();
					if (!combat_victory())
						print("You were defeated by a monster in the Ancient City! Maybe some leveling up is in order?","red");
					else
						hybored += 1;
				}
				else
				{
					hybored += 1;
					leave_city(last_venture);
				}	
			}
			
			// may need to YR a cultist if we can't get his stupid robe to drop
			boolean zap_cultist()
			{
				if (in_combat() && contains_text(advstring,"cultist") && yr_cultist && 
				item_amount($item[memory of a cultist's robe]) == 0 && equipped_amount($item[memory of a cultist's robe]) == 0 && 
				have_effect($effect[everything looks yellow]) <= 0 && item_amount($item[unbearable light]) > 0)
				{
					print("Yellow-raying to finally get a stupid cultist robe.","blue");
					advstring = throw_item($item[unbearable light]);
					yr_cultist = false;
					return true;
				}
				return false;
			}
			
			// examine the gate/well to see what we've done already
			void check_city()
			{
				manual_noncom(368,1);
				manual_noncom(369,1);
				if (!contains_text(advstring,"The bars of the gate were tempered iron"))
					kicked_gate = true;
				else if (contains_text(advstring,"when the chains holding the counterweights broke"))
					unlocked_gate = true;
				if (kicked_gate || unlocked_gate || contains_text(advstring,"left one has been filled"))
					inserted_small_stone = true;
				if (kicked_gate || unlocked_gate || contains_text(advstring,"one on the right has been filled"))
					inserted_little_stone = true;
				manual_noncom(373, 1);
				manual_noncom(369, 3);
				manual_noncom(368, 5);
				if (contains_text(advstring,"remains of the giant octopus"))
					killed_octopus = true;
				manual_noncom(372,1);
				checked_city = true;
			}
			
			noncombat_mood();
			cli_execute("trigger gain_effect, temporary blindness, uneffect temporary blindness");   // can get this from the octopus
			if (have_effect($effect[on the trail]) > 0 && !contains_text(visit_url("desc_effect.php?whicheffect=91635be2834f8a07c8ff9e3b47d2e43a"),"cultist"))
				cli_execute("uneffect on the trail");
			while (!krakrox_complete)
			{
				if ((!checked_city || hybored == 16) && equipped_amount($item[memory of a cultist's robe]) <= 0)
				{
					if (item_amount($item[memory of a cultist's robe]) > 0)
					{
						for i from 1 to 3
						{
							if (equipped_item(to_slot("acc"+i)) != $item[space trip safety headphones] && 
							equipped_item(to_slot("acc"+i)) != $item[ring of conflict] && 
							equipped_item(to_slot("acc"+i)) != $item[fuzzy slippers of hatred] &&
							equipped_item(to_slot("acc"+i)) != $item[special sauce glove])
							{
								equip(to_slot("acc"+i),$item[memory of a cultist's robe]);
								break;
							}
						}
						if (equipped_amount($item[memory of a cultist's robe]) == 0)
							equip($slot[acc1],$item[memory of a cultist's robe]);
					}
					else if (hybored == 16 && have_effect($effect[everything looks yellow]) <= 0 && retrieve_item(1,$item[unbearable light]))
						yr_cultist = true;
				}
				bottle_iku(205);
				if (contains_text(advstring,"The Story So Far"))  // player has not visited this zone yet this ascension, so that simplifies things
					checked_city = true;
				else if (contains_text(advstring,"Krakrox regarded the ancient temple, overgrown with vines"))
					abort("Supervirus not created!");
				else if (contains_text(advstring,"The wumpus is a fearsome beast"))
				{
					if (item_amount($item[memory of a glowing crystal]) <= 0 || wumpus_genocide)
					{
						if (item_amount($item[memory of a glowing crystal]) <= 0)
							print("Killing a Wumpus to steal his glowing crystal.","blue");
						else
							print("Killing another Wumpus because you hate those furry bastards.","blue");
						Wumpwn();
					}
					else
					{
						print("Already got a glowing crystal; skipping the Wumpus.","green");
						manual_noncom(360,2);
					}
				}
				else if (contains_text(advstring,"This is the entrance to the ancient city"))
				{
					if (hybored < 16)
					{
						// move past pointless intro noncom
						manual_noncom(366, 1);
						// skip ahead and/or backtrack
						if (!checked_city)
							check_city();
						if (item_amount($item[memory of a grappling hook]) <= 0)
						{
							if (!killed_octopus)
								hybored = 1;
							else
								hybored = 3;
						}
						if (hybored <= 2 && killed_octopus)
							hybored = 3;
						if (hybored == 3 && killed_octopus && item_amount($item[memory of a grappling hook]) > 0)
							hybored = 4;
						if (hybored == 4 && (inserted_small_stone || item_amount($item[memory of a small stone block]) > 0 || item_amount($item[memory of an iron key]) > 0))
							hybored = 5;
						if ((hybored == 5 || hybored == 6) && (inserted_small_stone || item_amount($item[memory of a small stone block]) > 0))
							hybored = 7;
						if ((hybored == 7 || hybored == 8) && (inserted_little_stone || item_amount($item[memory of a little stone block]) > 0))
							hybored = 9;
						if (hybored >= 9)
						{
							if (kicked_gate)
								hybored = 12;
							else if (unlocked_gate)
								hybored = 11;
							else if (!killed_octopus)
								hybored = 2;
							else if (!inserted_small_stone && item_amount($item[memory of a small stone block]) <= 0)
							{
								if (item_amount($item[memory of an iron key]) <= 0)
									hybored = 4;
								else
									hybored = 5;
							}
							else if (!inserted_little_stone && item_amount($item[memory of a little stone block]) <= 0)
								hybored = 7;
						}
						if (hybored == 12 && item_amount($item[memory of a stone half-circle]) > 0)
								hybored = 13;
						if ((hybored == 13 || hybored == 14) && item_amount($item[memory of half a stone circle]) > 0)
								hybored = 15;
						if (hybored == 15)
						{
							if (item_amount($item[memory of a stone half-circle]) <= 0)
								hybored = 12;
							else if (item_amount($item[memory of half a stone circle]) <= 0)
								hybored = 13;
						}
						// explore like a boss
						explore_city();
						noncombat_mood();    // unequip the robe if necessary
						if (hybored == 10 || hybored == 11)
						{
							inserted_small_stone = true;
							inserted_little_stone = true;
						}
						else if (hybored == 3 || hybored == 4)
							killed_octopus = true;
					}
					else
						manual_noncom(366, 2);
				}
				else if (contains_text(advstring,"Krakrox regarded the ancient temple with a shudder"))
				{
					hybored = 16;
					if (item_amount($item[memory of a glowing crystal]) > 0)   // can get robe from group of cultists
					{
						if (equipped_amount($item[memory of a cultist's robe]) > 0)
							print("Infiltrating temple and walloping high priest.","blue");
						else
							print("Beating up some cultists because we still don't have a robe.","red");
						manual_noncom(367, 1);
						zap_cultist();
						if (in_combat())
						{
							advstring = run_combat();
							if (contains_text(advstring,"high priest"))
							{
								if (combat_victory())
									krakrox_complete = true;
								else
									print("You need to work on your priest-pummeling!","red");
							}
						}
					}
					else
						manual_noncom(367, 2);
					if (!krakrox_complete && !yr_cultist && item_amount($item[memory of a cultist's robe]) <= 0)
						cli_execute("maximize item");    // need to get that damn robe!
				}
				else if (in_combat())
				{
					if (contains_text(advstring,"evil cultist") && !zap_cultist() && have_skill($skill[Transcendent Olfaction]) && 
					my_mp() >= mp_cost($skill[Transcendent Olfaction]) && have_effect($effect[On the Trail]) <= 0)
						advstring = use_skill($skill[transcendent olfaction]);
					if (in_combat())
						advstring = run_combat();
				}
			}
			cli_execute("mood clear");
			
			if (krakrox_complete)
			{
				visit_url("town_wrong.php?action=krakrox");
				print("Krakrox saved the Distant Past, after you helped Cyrus screw it up! Uh...good job?","blue");
			}
			else
				abort("Failed to finish Distant Past.");
		}
		
		// finally, the last part of the quest in this ludicrously long function
		print("Saving the future...","blue");
		
		void megalopolis_noncoms()
		{
			if (contains_text(advstring,"Time spools out before you"))
				manual_noncom(387, 1);
			else if (contains_text(advstring,"an evil elder god that has been waiting to destroy the earth"))
				manual_noncom(388, 1);
			else if (contains_text(advstring,"HALT! YOU CANNOT PASS!"))
				manual_noncom(365, 2);
			else if (contains_text(advstring,"451 Degrees"))
				manual_noncom(364, 2);
			else if (contains_text(advstring,"You walk into a bar in the Seaside Megalopolis"))
				manual_noncom(389, 1);
			else if (contains_text(advstring,"After wandering the spaceport for a ridiculous length of time"))
				manual_noncom(390, 1);
			else if (contains_text(advstring,"OMG KAWAIII"))
				manual_noncom(391, 1);
			else if (contains_text(advstring,"she leads you into her quarters"))
				manual_noncom(392, 1);
			else if (contains_text(advstring,"I could have sworn you were the savior of humanity"))
				manual_noncom(352, 1);
			else if (contains_text(advstring,"There's a receptionist behind the desk"))
				manual_noncom(353, 1);
			else if (contains_text(advstring,"it's time for the garden party"))
				manual_noncom(354, 1);
			else if (contains_text(advstring,"it's time for the hunt"))
				manual_noncom(355, 1);
			else if (contains_text(advstring,"a makeshift open-air market"))
				manual_noncom(356, 1);
			else if (contains_text(advstring,"back alley referenced on your Mecha Mayhem Club card"))
				manual_noncom(357, 1);
			else if (contains_text(advstring,"find the address on your Blue Milk Club card"))
				manual_noncom(358, 1);
			else if (contains_text(advstring,"finally arrive at the Desert Beach Spaceport"))
				manual_noncom(361, 1);
			else if (contains_text(advstring,"Spacefleet Communicator Badge beeps"))
				manual_noncom(362, 1);
			else if (contains_text(advstring,"finally make your way to Hangar 1138"))
				manual_noncom(363, 1);
		}
		
		boolean future_complete = false;
		
		cli_execute("mood clear");
		noncombat_mood();  // supposedly noncombats here are scheduled, but I haven't observed this, so we might as well
		
		/*for derp from 352 to 363
			if (derp != 360)
				set_property("choiceAdventure"+derp,"1");
				
		for derp from 352 to 363
			if (derp != 360)
				set_property("choiceAdventure"+derp,"0");*/
		
		// get ruby rod
		if (item_amount($item[Ruby Rod]) == 0)
		{
			while(item_amount($item[Ruby Rod]) <= 0)
			{
				bottle_iku(206);
				if (in_combat())
					run_combat();
				else
					megalopolis_noncoms();
			}
		}
		equip($slot[weapon],$item[Ruby Rod]);
		
		item fat_stacking()
		{
			if (retrieve_item(1,$item[fat stacks of cash]))
				return $item[fat stacks of cash];
			else if (retrieve_item(1,$item[3898]))  // Gu-Gone
				return $item[3898];
			else if (retrieve_item(1,$item[facsimile dictionary]))
				return $item[facsimile dictionary];
			else if (retrieve_item(1,$item[dictionary]))
				return $item[dictionary];
			else if (retrieve_item(1,$item[spices]))
				return $item[spices];
			else if (retrieve_item(1,$item[seal tooth]))
				return $item[seal tooth];
			else if (retrieve_item(1,$item[spectre scepter]))
				return $item[spectre scepter];
			
			abort("Need a stasis item!");
			return $item[none];
		}
			
		string findtext;
		item fat_stack = fat_stacking();
		familiar old_fam = my_familiar();
		if (old_fam != $familiar[black cat])
			use_familiar($familiar[none]);   // we're trying to stasis, and familiars cause endless problems with that.
		while(item_amount($item[essence of kink]) <= 0 || item_amount($item[essence of fright]) <= 0 ||
		item_amount($item[essence of stench]) <= 0 || item_amount($item[essence of cold]) <= 0 || 
		item_amount($item[essence of heat]) <= 0 || item_amount($item[essence of cute]) <= 0)
		{
			bottle_iku(206);
			if (in_combat())
			{
				if (contains_text(advstring,"Jay Android") && item_amount($item[essence of kink]) <= 0)
					findtext = "spinning, whirring, vibrating, tubular";
				else if (contains_text(advstring,"Space Marine") && item_amount($item[essence of fright]) <= 0)
					findtext = "freaky alien thing";
				else if (contains_text(advstring,"Dwarf Replicant") && item_amount($item[essence of stench]) <= 0)
					findtext = "vile-smelling, milky-white";
				else if (contains_text(advstring,"liquid metal robot") && item_amount($item[essence of cold]) <= 0)
					findtext = "with liquid nitrogen";
				else if (contains_text(advstring,"Bangyomaman") && item_amount($item[essence of heat]) <= 0)
					findtext = "turns a crank on the side of his gun";
				else
					findtext = "";
				
				// wait for signal to use ruby rod
				if (findtext != "")
				{
					print("Waiting for the right moment to nab an essence...","blue");
					while (!contains_text(advstring,findtext) && in_combat())
						advstring = throw_item(fat_stack);
					if (in_combat())
						advstring = attack();
				}
				if (in_combat())
					advstring = run_combat();
			}
			else
				megalopolis_noncoms();
		}
		use_familiar(old_fam);
		
		while (!future_complete)
		{
			bottle_iku(206);
			if (in_combat())
				advstring = run_combat();
			else if (contains_text(advstring,"she leads you into her quarters"))
			{
				visit_url("choice.php?whichchoice=392&slot1=sleaze&slot2=spooky&slot3=stench&slot4=cold&slot5=hot&option=1&pwd=" + my_hash());
				print("Quest complete! You're a hero of the past, the future, and the...uh...and you got a present! Yaaaay!","blue");
				future_complete = true;
			}
			else
				megalopolis_noncoms();
		}
	}
}

void main()
{
	advstring = visit_url("campground.php");
	
	if (in_wumpus_cave())
		Wumpwn();
	else if (contains_text(advstring,"Your Campsite"))
		futurella();
	else
		abort("You're in the middle of an adventure! Finish that up and run the script again.");
}