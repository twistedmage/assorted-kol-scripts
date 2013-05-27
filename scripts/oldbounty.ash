// AutoBHH
// originally by izchak
// revisions by Raorn and Zarqon
import <canadv.ash>
setvar("do_smallest_bounty",false);

// load bounty data
record _bounty {
	int amount;
	location where;
	int safemox;
};
_bounty[item] bounty;
boolean load_current_map(string fname) {
   string curr = visit_url("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getver");
   file_to_map(fname+".txt",bounty);
   if  ((count(bounty) == 0) || (curr != "" && get_property(fname+".txt") != curr)) {
      print("Updating "+fname+".txt from '"+get_property(fname+".txt")+"'...");
      if (!file_to_map("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getmap",bounty) || count(bounty) == 0) return false;
      print("Bounty count: "+count(bounty));
      map_to_file(bounty,fname+".txt");
      set_property(fname+".txt",curr);
      print("..."+fname+".txt updated.");
   }
   return (count(bounty) > 0);
}
if (!load_current_map("bounty")) abort("Error loading bounty data.");
string bhh_page;
item[int] bopts;
void rebountify(string url) {
   if (url != "") bhh_page = visit_url(url);
   clear(bopts);
   item[int] moxsorted;
   foreach i in bounty {
      if (bhh_page.contains_text(bounty[i].amount + " " + i.to_plural()))
      moxsorted[bounty[i].safemox] = i;
   }
   foreach n in moxsorted bopts[count(bopts)] = moxsorted[n];
}

boolean accept_bounty(item itm) {
   if (!bhh_page.contains_text("be a Bounty Hunter, and earn some filthy lucre?"))
      return false;
   print("Accepting the hunt for "+bounty[itm].amount+" "+itm.to_plural()+"...");
   rebountify("bhh.php?pwd&action=takebounty&whichitem="+itm.to_int());
   return (count(bopts) == 1);
}
boolean cancel_bounty() {
   print("Aborting current hunt...");
   rebountify("bhh.php?pwd&action=abandonbounty");
   return bhh_page.contains_text("Can't hack it, eh?");
}
boolean can_has_bounty(item itm, int minMox) {
   if (!(bounty contains itm) || bounty[itm].safemox > minMox + to_int(vars["threshold"])) return false;
   if (itm==$item[greasy dreadlock] && (contains_text(visit_url("questlog.php?which=1"),"Make War, Not") || contains_text(visit_url("questlog.php?which=2"),"Make War, Not")))
   {
		return false;
   }
   return can_adv(bounty[itm].where,!to_boolean(vars["do_smallest_bounty"]));
}

boolean accept_best_bounty(boolean smallest) {
   int flag = 41;
   item chosen;
   for i from 2 downto 0 {
      print("Checking bounty hunt possibility in " + bounty[bopts[i]].where + "...");
      if (can_has_bounty(bopts[i], my_defstat())) {
         if (smallest) {
            if (bounty[bopts[i]].amount < flag) {
               flag = bounty[bopts[i]].amount;
               chosen = bopts[i];
            }
         } else return accept_bounty(bopts[i]);
      } else print("Impossible! Skipping...");
   }
   if (smallest) return (can_adv(bounty[chosen].where,true) && accept_bounty(chosen));
   return false;
}

boolean hunt_bounty(int advs) {
   cli_execute("recover hp");
   if(have_effect($effect[beaten up])!=0)
   {
		print("curing beaten up before bounty","green");
		if(can_interact())
		{
			use(1,$item[tiny house]);
		}
		else
		{
			cli_execute("sleep 3");
		}
   }
   print("Calling hunt_bounty()","green");
   if (count(bopts) == 1) {
      if (!can_has_bounty(bopts[0],my_defstat())) {
         print("Can't finish current bounty.","olive");
         if (item_amount(bopts[0]) > 0)
            abort("Somehow, you already have "+item_amount(bopts[0])+" "+bopts[0].to_plural()+" even though i don't think you can do it now.  I (the script) am aborting in confusion.");
         cancel_bounty();
      }
   } else if (!accept_best_bounty(to_boolean(vars["do_smallest_bounty"]))) return false;
   if (count(bopts) != 1) abort("Error selecting bounty.");
   print("Adventuring in "+bounty[bopts[0]].where.to_string()+" for "+bounty[bopts[0]].amount+" " + bopts[0].to_plural()+".");
   set_property("battleAction", "custom combat script");
   cli_execute("conditions clear; conditions set "+bounty[bopts[0]].amount+" "+bopts[0]);
	print("About to adventure","green");
	print("advs="+advs,"green");
	print("bounty[bopts[0]].where="+bounty[bopts[0]].where,"green");
	adventure(advs, bounty[bopts[0]].where);
	cli_execute("conditions clear");
  // Refresh page and collect lucre if any
	print("About to rebountify","green");
   rebountify("bhh.php");
   print("You have "+available_amount($item[filthy lucre])+" filthy lucre.");
   return (count(bopts) == 0);
}

void usage() {
   print_html("<b>Usage:</b><p><br>bounty.ash {COUNT|*}<br>bounty.ash list<br>bounty.ash accept {best|small|easy|1|normal|2|hard|3}<br>bounty.ash abort");
}

void main(string params) {
	set_property("choiceAdventure151","2");
   rebountify("bhh.php");
   if (bhh_page.contains_text("I can't assign you a new one")) {
      print("Bounty hunt already completed today."); return;
   }
   if (count(bopts) == 1)
      print("Currently hunting: "+bounty[bopts[0]].amount+" "+bopts[0].to_plural()+" (hunted so far: "+item_amount(bopts[0])+")");
   int advs = 0;
   string[int] argv = params.to_lower_case().split_string("\\s+");
   if (count(argv) == 2) {
      if (argv[0] == "accept") {
         if (count(bopts) == 1) abort("Unable to accept another bounty.");
         int w = -1;
         switch (argv[1]) {
            case "best": accept_best_bounty(false); return;
            case "smallest":
            case "small": accept_best_bounty(true); return;
            case "1":
            case "easy": w = 0; break;
            case "2":
            case "normal":
            case "medium": w = 1; break;
            case "3":
            case "hard": w = 2;
         }
         if (w == -1) { usage(); return; }
         if (!can_adv(bounty[bopts[w]].where,true)) print("Warning: bounty "+w+" is not possible!", "olive");
         if (accept_bounty(bopts[w])) print("...now hunting!");
         return;
      } else { usage(); return; }
   } else if (argv.count() == 1) {
      switch (argv[0]) {
         case "abort": if (count(bopts) == 1 && cancel_bounty()) print("Bounty hunt canceled."); return;
         case "list": if (count(bopts) > 1)
            for i from 0 to 2
               print(to_string(i+1) + ": "+bounty[bopts[i]].amount+" "+bopts[i].to_plural()+" from "+
                     bounty[bopts[i]].where+" ("+bounty[bopts[i]].safemox + " Mox)");
            return;
         case "hunt":
         case "*": advs = my_adventures(); break;
         default: if (argv[0].to_int() > 0) advs = argv[0].to_int();
                  else { usage(); return; }
      }
   }
   if(can_interact() && contains_text(visit_url("town_clan.php"),"rumpusroom.gif"))
   {
	   refresh_stash();
	}
   if (advs > 0) {
      if (hunt_bounty(advs)) print("Bounty hunt successful.");
		    else print("Bounty hunt failed.");
   } else usage();
   if(available_amount($item[spooky putty monster])!=0)
	{
		use(1,$item[spooky putty monster]);
	}
}