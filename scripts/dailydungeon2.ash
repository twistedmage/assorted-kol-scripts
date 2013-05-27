#/******************************************************************************
#                    Daily Dungeon Diver 1.8 by Zarqon
#*******************************************************************************
#
#   Intelligently automates the daily dungeon, checking the Noblesse Oblige
#   calendar before adventuring to decide whether you can pass or not.
#
#   Have a suggestion to improve this script?  Visit
#   http://kolmafia.us/showthread.php?t=1866
#
#   Mad props to Ragnok of NO for pointing me to where the Daily Dungeon data
#   is kept, and for creating the NO calendar in the first place!
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#******************************************************************************/
script "dailydungeon.ash";
import <zlib.ash>
string this_version = "1.8";

setvar("ddd_goal3",$item[potato sprout]); // specify an item from the first chest, and the script will
                                       // open the chest only if you don't have that item already
                                       // (checks terrarium in case the item is potato sprout)

setvar("ddd_goal6",$item[none]);       // specify an item from the second chest, and the script will
                                       // open the chest only if you don't have that item already
                                     
setvar("ddd_takeitintheface",true);    // if true, will pass elemental test rooms even without resistance

setvar("ddd_dungeonblind",false);      // if true, will attempt to complete the dungeon even
                                       // if foreknowledge of the rooms is unavailable

setvar("ddd_statchance",2);            // how risky to be when passing stat tests:
                                       // 1: attempt when your stat is at least the lowest possible pass value
                                       // 2: only attempt when your stat is at least average of pass/fail range
                                       // 3: only attempt when your stat is guaranteed to pass
string src;
int roomnum;
record statrange {
   stat type;
   int min;
   int max;
};
statrange[string] dchecks;
if (!file_to_map("dungeonstatchecks.txt",dchecks) || count(dchecks) == 0)
   vprint("Unable to load daily dungeon stat check info.",0);
dchecks["Locked Door"].type = my_primestat();

int stat_check(string title) {             // returns 0-3 certainty of passing
   foreach a in dchecks                    // 0: impossible, 1: first half of range, 2: second half, 3: certain
      if (contains_text(title,a)) {        //
         if (my_buffedstat(dchecks[a].type) < dchecks[a].min)
            return to_int(vprint("Passing with "+dchecks[a].type+" of "+my_buffedstat(dchecks[a].type)+": IMPOSSIBLE!",-2));
         if (my_buffedstat(dchecks[a].type) < (dchecks[a].min + dchecks[a].max) / 2)
            return to_int(vprint("Passing with "+dchecks[a].type+" of "+my_buffedstat(dchecks[a].type)+": UNLIKELY!","olive",2));
         if (my_buffedstat(dchecks[a].type) <= dchecks[a].max) {
            vprint("Passing with "+dchecks[a].type+" of "+my_buffedstat(dchecks[a].type)+": PROBABLE!","olive",2);
            return 2;
         }
         vprint("Passing with "+dchecks[a].type+" of "+my_buffedstat(dchecks[a].type)+": CERTAIN!","green",2);
         return 3;
      }
   return to_int(vprint("No registered adventure name found.",-2));
}

boolean trytrytry(string advtitle, string query) {      // if the stat CAN pass, tries until it does
   if (stat_check(advtitle) < to_int(vars["ddd_statchance"]))
      return vprint("Sorry, but that stat is lower than a snake in a wagon rut. Not attempting to pass.",-2);
   repeat {
      src = visit_url("dungeon.php?pwd&"+query);
      refresh_status();
      restore_hp(0);
   } until (src.contains_text("You move deeper") || have_effect($effect[beaten up]) > 0 || my_adventures() == 0);
   return (src.contains_text("You move deeper"));
}

boolean chestcontainsgoods(int roomie) {
   switch (roomie) {
      case 10: return vprint("The 10th room always has goods.",4);
      case 6: return (to_item(vars["ddd_goal6"]) != $item[none] && item_amount(to_item(vars["ddd_goal6"])) + equipped_amount(to_item(vars["ddd_goal6"])) == 0);
      case 3: if (to_item(vars["ddd_goal3"]) == $item[potato sprout])
               return (!have_familiar($familiar[levitating potato]) && item_amount(to_item(vars["ddd_goal3"])) == 0);
              return (to_item(vars["ddd_goal3"]) != $item[none] && item_amount(to_item(vars["ddd_goal3"])) + equipped_amount(to_item(vars["ddd_goal3"])) == 0);
   }
   return vprint("There's no chest in room "+roomie+".",-4);
}

boolean do_room() {
   restore_hp(0);
   restore_mp(0);
   int previousroom = roomnum;
   roomnum = to_int(excise(src,"<center><b>Room ",":"));
   if (roomnum == previousroom) return vprint("There was a problem passing room "+previousroom+"!",-2);
  // mini-functions for doing different types of room
   boolean do_chest() {
      vprint("Treasure!",2);
      if (chestcontainsgoods(roomnum))
      src = visit_url("dungeon.php?pwd&action=Yep&option=1");
       else {
         src = visit_url("dungeon.php?pwd&action=Yep.&option=2");
         vprint("Treasure chest skipped.",2);
       }
      if (roomnum == 3 && item_amount($item[potato sprout]) > 0 && !have_familiar($familiar[levitating potato]) && use(1,$item[potato sprout])) {}
      return vprint("Treasure room cleared.",5);
   }
   boolean do_door() {
      vprint("Door!",2);
      if (item_amount($item[platinum yendorian express card]) > 0) {   // use plantnorium yendari... whatever
         src = visit_url("dungeon.php?pwd&action=Yep&option=4");
         return (src.contains_text("You move deeper"));
      }
      if (item_amount($item[pick-o-matic lockpicks]) > 0)              // lockpicks are good too
         if (trytrytry("Smooth Criminal","action=Yep&option=3")) return vprint("Door cleared.",5);
      if (item_amount($item[skeleton key]) + creatable_amount($item[skeleton key]) > 2) {
         retrieve_item(1,$item[skeleton key]);                         // ok, try a skeletor key... but keep one for later
         src = visit_url("dungeon.php?pwd&action=Yep.&option=2");
         return (src.contains_text("You move deeper"));
      }
      return trytrytry("Locked Door","action=Yep&option=1");           // nothing left but the ol' "forcing the door" technique
   }
   boolean do_monster() {
      vprint("Monster!",2);
      src = visit_url("dungeon.php?pwd&action=Yep&option=1");
      boolean result = contains_text(run_combat(),"You win the fight!");
      src = visit_url("dungeon.php");
      return result;
   }
   boolean do_resistance(element req) {
      vprint("Elemental Test!",2);
      if (!resist(req,true) && !to_boolean(vars["ddd_takeitintheface"])) return vprint("Not taking it in the face.",-4);
      src = visit_url("dungeon.php?pwd&action=Yep&option=1");
      cli_execute("outfit checkpoint");
      if (to_familiar(vars["is_100_run"]) != $familiar[none] && my_familiar() != to_familiar(vars["is_100_run"]))
         use_familiar(to_familiar(vars["is_100_run"]));
      return (src.contains_text("You move deeper"));
   }
   vprint("Room "+roomnum+"...","blue",2);
   switch {
      case (src.contains_text(": Treasure!")): return do_chest();
      case (src.contains_text(": Locked Door")): return do_door();
      case (src.contains_text(": Monster")): return do_monster();
      case (src.contains_text("most powerful refrigerator")):
      case (src.contains_text("metal pole")): return do_resistance($element[cold]);
      case (src.contains_text("gigantic magnifying glass")):
      case (src.contains_text("enormous electric stove burner")): return do_resistance($element[hot]);
      case (src.contains_text("Eternal Stench")):
      case (src.contains_text("Sewage Moat")): return do_resistance($element[stench]);
      case (src.contains_text("used car salesmen")):
      case (src.contains_text("pornographic magazines")): return do_resistance($element[sleaze]);
      case (src.contains_text("enormous spooky skull")):
      case (src.contains_text("huge-eyed crying orphans")): return do_resistance($element[spooky]);
      default: print("Stat Test!"); return trytrytry(src,"action=Yep&option=1");
   }
}

// begin pre-checking functions (loads room data from Noblesse Oblige site once daily)

string[int] p;

int dd_precheck() {             // returns the number of adventures your dive is likely to take, 0 if you can't pass
   int advs, keys;
   boolean result = true;
  // little function that mafia can't do
   stat piece_to_stat(string s) {
      switch (s) {
         case "Mys": return $stat[mysticality];
         case "Mus": return $stat[muscle];
         case "Mox": return $stat[moxie];
      }
      return $stat[none];
   }
   for i from 1 to 9 {
      print("Checking room "+i+": "+p[i]+"...");
      if (i == 3 || i == 6) {
         if (chestcontainsgoods(i)) {
            vprint("Opening chest: +1 adv","maroon",2);
            advs = advs + 1;
         } else vprint("Not opening chest.","gray",2);
         continue;
      }
      if (p[i].contains_text("Locked Door")) {
         if (item_amount($item[platinum yendorian express card]) > 0) {
            vprint("Using Plendorian Yatnor... whatever.","gray",2); continue;
         }
         if (item_amount($item[pick-o-matic lockpicks]) > 0 && stat_check("Smooth Criminal") >= to_int(vars["ddd_statchance"])) {
            vprint("Using lockpicks.","gray",2); continue;
         }
         if (item_amount($item[skeleton key]) + creatable_amount($item[skeleton key]) > 2) {
            vprint("Using skeleton key: +1 key","gray",2); keys = keys + 1; continue;
         }
         int stator = stat_check(p[i]);
         if (stator < to_int(vars["ddd_statchance"])) {
            result = vprint("This likelihood is below your specified stat chance.",-2);
            continue;
         }
         int forplus = 1;
         if (stator == 1) forplus = 2;
         vprint("Forcing open the door: +"+forplus+" adv","maroon",2);
         advs = advs + forplus; continue;
      } else if (p[i].contains_text("resistance")) {
         if (!resist(to_element(substring(p[i],index_of(p[i],"(")+1,index_of(p[i]," resistance"))),false)) {
            if (to_boolean(vars["ddd_takeitintheface"])) print("Taking it in the face... Ouch!","olive");
            else { result = vprint("Resistance is futile!",-2); continue; }
         }
         cli_execute("outfit checkpoint");
         vprint("Passing through: +1 adv","maroon",2);
         advs = advs + 1; continue;
      } else if (p[i].contains_text("Monster")) {
         vprint("Fighting monster: +1 adv","maroon",2);
         advs = advs + 1; continue;
      } else if (p[i].contains_text("check)")) {
         stat whichstat = piece_to_stat(substring(p[i],index_of(p[i],"(")+1,index_of(p[i]," check)")));
         int stator = stat_check(p[i]);
         if (stator < to_int(vars["ddd_statchance"])) {
            result = vprint("This likelihood is below your specified stat chance.",-2);
            continue;
         }
         int forplus = 1;
         if (stator == 1) forplus = 2;
         vprint("Passing through: +"+forplus+" adv","maroon",2);
         advs = advs + forplus; continue;
      }
      vprint("Some other unknown thing! (text: '"+p[i]+"') +1 adv","maroon",2);
      advs = advs + 1;
   }
   if (my_adventures() < advs) return to_int(vprint("You don't have enough adventures ("+advs+") to clear the daily dungeon today!",-2));
   if (!result) return 0;
   vprint("Room 10 Chest: +1 adv","maroon",2);
   vprint("You can safely dive the daily dungeon!  You will use "+(advs+1)+" adventures and "+keys+" skeleton keys.","blue",2);
   return advs;
}

boolean fetch_roomdata() {
   string url = visit_url("http://www.noblesse-oblige.org/calendar/daily_"+today_to_string()+".html");
   if (!contains_text(url,"<h3>Daily Dungeon</h3>"))
      return vprint("Noblesse Oblige's daily dungeon info is not yet available today.","black",-2);
   url = substring(url,index_of(url,"Room ")+5,index_of(url,"Room 10"));
   string[int] chunks = split_string(url,"Room ");
   if (count(chunks) != 9) return false;
   foreach i in chunks
      p[to_int(substring(chunks[i],0,3))] = substring(chunks[i],index_of(chunks[i],": ")+2,index_of(chunks[i],"<"));
   return (count(p) == 9);
}

boolean load_dailydungeon(string filename) {
   if (!file_to_map(filename,p) || count(p) == 0 || get_property(filename) != today_to_string()) {
      if (!fetch_roomdata()) return vprint("Unable to load room data.",-3);
      vprint("Caching page...",2);
      if (!map_to_file(p,filename)) return vprint("Unable to cache page.","olive",-3);
      set_property(filename,today_to_string());
      return vprint("Room data written to '"+filename+"' for "+today_to_string()+".",3);
   }
   return vprint("Using cached dungeon info...",2);
}

// end prechecking functions, begin main and "wrapper main"

boolean dailydungeon() {
   vprint("Loading daily dungeon information for "+today_to_string()+"...",2);
   if ((!load_dailydungeon("dailydungeondata.txt") && !to_boolean(vars["ddd_dungeonblind"])) || (count(p) == 9 && dd_precheck() == 0)) return false;
   vprint("Completing daily dungeon...",3);
   src = visit_url("dungeon.php");
   cli_execute("checkpoint");
   while (!src.contains_text("reached the bottom")) {
      if (have_effect($effect[beaten up]) > 0)
		{
			print("You can't dive the daily dungeon while beaten up.","blue");
			if(can_interact())
			{
				use(1,$item[tiny house]);
			}
			else if(have_skill($skill[Tongue of the Walrus]) && my_maxmp()>=mp_cost($skill[Tongue of the Walrus]))
			{
				use_skill($skill[Tongue of the Walrus]);
			}
			else if(have_skill($skill[Tongue of the Otter]) && my_maxmp()>=mp_cost($skill[Tongue of the Otter]))
			{
				use_skill($skill[Tongue of the Otter]);
			}
			else if(my_adventures()>3)
			{
				cli_execute("sleep 3");
			}
			else
			{
				abort("You can't do the daily dungeon while beaten up and can't remove beaten up");
			}
		}	
      if (my_buffedstat(my_primestat()) < 15) return vprint("You need at least 15 "+my_primestat()+" to do the daily dungeon.",-2);
      if (!do_room()) return vprint("Unable to complete room "+roomnum+".",-2); else vprint("Room "+roomnum+" cleared.",2);
   }
   set_property("dailyDungeonDone","true");
   return true;
}

check_version("Daily Dungeon Diver","DDD",this_version,1866);
void main() {
   if (get_property("dailyDungeonDone") == "true") vprint("You have already completed the Daily Dungeon today.",0);
   if (my_adventures() == 0) vprint("Chance of completing the Daily Dungeon in 0 adventures: ZERO!",0);
   if (have_effect($effect[beaten up]) > 0)
		{
			print("You can't dive the daily dungeon while beaten up.","blue");
			if(can_interact())
			{
				use(1,$item[tiny house]);
			}
			else if(have_skill($skill[Tongue of the Walrus]) && my_maxmp()>=mp_cost($skill[Tongue of the Walrus]))
			{
				use_skill($skill[Tongue of the Walrus]);
			}
			else if(have_skill($skill[Tongue of the Otter]) && my_maxmp()>=mp_cost($skill[Tongue of the Otter]))
			{
				use_skill($skill[Tongue of the Otter]);
			}
			else if(my_adventures()>3)
			{
				cli_execute("sleep 3");
			}
			else
			{
				abort("You can't do the daily dungeon while beaten up and can't remove beaten up");
			}
		}	
   if (my_buffedstat(my_primestat()) < 15) vprint("You need at least 15 "+my_primestat()+" to do the daily dungeon.",0);
   if (dailydungeon()) vprint("Daily dungeon complete!","blue",2);
    else
	{	
		print("Unable to complete daily dungeon.","blue");
	}	
}
