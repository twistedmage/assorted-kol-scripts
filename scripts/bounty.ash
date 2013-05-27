// AutoBHH
// originally by izchak
// revisions by Raorn and Zarqon
import <canadv.ash>
setvar("do_smallest_bounty",false);

// load bounty data
record {
   item what;
	int amount;
	location where;
   boolean avail;
}[int] bounty;

location bounty_loc(item bountyitem) {
   foreach l in $locations[]
      foreach num,m in get_monsters(l)
         foreach i in item_drops(m) 
            if (i == bountyitem) return l;
   return $location[none];
}
item to_singular(string plur) {
   foreach i in $items[] if (equals(plur,to_plural(i))) return i;
   return $item[none];
}
string bstring(int n) {
   return (bounty contains n) ? bounty[n].amount+" "+bounty[n].what.to_plural()+" from "+bounty[n].where : "";
}
boolean can_has_bounty(int n) {
   if (get_safemox(bounty[n].where) > my_defstat() + to_int(vars["threshold"])) return false;
   return can_adv(bounty[n].where,!to_boolean(vars["do_smallest_bounty"]));
}
string visit_bhh(string query) {
   string page = visit_url("bhh.php?pwd"+query);
   if (page.contains_text("I can't assign you a new one")) { bounty.clear(); return page; }
   matcher biggles = create_matcher("(?:bring me |<b>)(\\d+) (.+?)(?:,|</b>)",page);
   while (biggles.find()) {
      int b = count(bounty);
      bounty[b].what = to_singular(biggles.group(2));
      bounty[b].amount = biggles.group(1).to_int();
      bounty[b].where = bounty_loc(bounty[b].what);
      bounty[b].avail = can_has_bounty(b);
      vprint(bstring(b), bounty[b].avail ? "green" : "red",3);
   }
   if (count(bounty) == 1) foreach i,r in bounty
      print("Now hunting: "+bstring(i)+" (hunted so far: "+item_amount(r.what)+")","blue");
   return page;
}
visit_bhh("");

boolean accept_bounty(int n) {
   if (count(bounty) < 2) return false;
   print("Accepting the hunt for "+bstring(n)+"...");
   visit_bhh("&action=takebounty&whichitem="+bounty[n].what.to_int());
   return (count(bounty) == 1);
}
boolean cancel_bounty() {
   print("Aborting current hunt...");
   visit_bhh("&action=abandonbounty");
   return (count(bounty) > 1);
}
boolean accept_best_bounty(boolean small) {
   if (count(bounty) == 1) return true;
   if (small) sort bounty by value.amount;
    else sort bounty by -get_safemox(value.where);
   foreach i,r in bounty if (bounty[i].avail) return accept_bounty(i);
       else print("Impossible! Skipping...");
   return false;
}

boolean hunt_bounty() {
   if (count(bounty) > 1 && !accept_best_bounty(to_boolean(vars["do_smallest_bounty"]))) return false;
   foreach i,r in bounty {
     print("Adventuring for "+bstring(i)+"...");
     if (!obtain(r.amount,r.what,r.where)) return false;
    // Refresh page and collect lucre if any
     visit_bhh("");
     print("You have "+available_amount($item[filthy lucre])+" filthy lucre.");
   }
   return (count(bounty) == 0);
}

void main(string param) {
   if (count(bounty) == 0) vprint("Bounty hunt already completed today.",-3);
    else switch (param) {
      case "cancel":
      case "abort": if (count(bounty) == 1 && cancel_bounty()) print("Bounty hunt canceled."); return;
      case "hard":
      case "best": accept_best_bounty(false); return;
      case "smallest":
      case "small": accept_best_bounty(true); return;
      case "list": return;
      case "go":
      case "*": if (hunt_bounty()) print("Bounty hunt successful.");
         else print("Bounty hunt failed."); return;
      default: print_html("<b>Usage:</b><p>bounty.ash {go|*}<br>bounty.ash list<br>bounty.ash {best|small|hard}<br>bounty.ash {abort|cancel}");
   }
}
