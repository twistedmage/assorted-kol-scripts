#/******************************************************************************
#                     Hardcore Checklist 1.2 by Zarqon
#                required item getter / ascension aid script
#*******************************************************************************
#
#   Purpose: to aid players (primarily HC) in procuring all required items for
#   ascension in a timely manner.
#
#   based on the Hardcore Checklist at
#   http://kol.coldfront.net/thekolwiki/index.php/Hardcore_Checklist
#
#   Have a suggestion to improve this script?  Visit
#   http://kolmafia.us/showthread.php?t=1045
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#******************************************************************************/
script "Checklist.ash";
import <dailydungeon.ash>
import <canadv.ash>
import <sims_lib.ash>
string this_ver = "1.2.7 (really)";

int show_steps = 10;        // how many steps to show in info_only mode

record required_item {
   int safemox;             // moxie for safe adventuring
   int quant;               // how many to get
   string where;            // where to adventure
   string req;              // what to get; if none, adventures until check_url contains check_text
   string check_url;        // optional; first checks check_url for check_text
                            // SPECIAL VALUES: maid, chef, bartender, completed, ns, haveitem, havefam
   string check_text;       // if found, it skips getting the item(s)
};

required_item [int] c;
string s;
boolean maid_check() {
   int [item] camp = get_campground();        // in a function in case it helps memory usage
   return (camp[$item[meat maid]] + camp[$item[clockwork maid]]> 0);
}
boolean have_maid = maid_check();


// load checklist
boolean load_list(string fname) {
   print("Loading checklist...");
   if (!load_current_map(fname,c)) abort("Error loading checklist.");
   if (count(c) == 0) abort("Checklist is empty.  I guess that means... you're done?");
   print("Checklist loaded ("+count(c)+" steps).");
}

// For determining whether the script will adventure at a location.
// "diff" is your defstat - the location's listed safe moxie value and ML.
boolean unsafe(int diff) {
   if (to_boolean(vars["auto_mcd"])) {
      int adj = minmax(diff + current_mcd(),0,10+to_int(in_mysticality_sign()));
      if (current_mcd() != adj && change_mcd(adj)) return false;
   }
   return (diff < 0);
}

// returns true if step which is already completed/unnecessary
boolean check_it(int which) {
   if (in_muscle_sign() && c[which].where == "degrassi gnoll") return retrieve_item(1,to_item(c[which].req));
   if (c[which].req == "grave robbing shovel") { if (have_item("rusty grave robbing shovel") > 0)
                                                 return true; else return !to_boolean(vars["get_servants"]);}
   if (contains_text(c[which].req,"potion")) switch (get_property("lastBangPotion"+to_int(to_item(c[which].req)))) {
      case "healing": case "confusion": case "inebriety": case "sleepiness": return true;
   }
   switch (c[which].check_url) {
      case "haveitem": return (have_item(c[which].check_text) > 0);
      case "havefam": return (have_familiar(to_familiar(c[which].check_text)));
      case "none": return (c[which].req == "none");
      case "ns": return !to_boolean(vars["checklist_get_ns_items"]);
      case "maid": if (to_boolean(vars["checklist_get_servants"])) return have_maid;
      case "chef": if (to_boolean(vars["checklist_get_servants"])) return simons_have_chef();
      case "bartender": if (to_boolean(vars["checklist_get_servants"])) return simons_have_bartender();
      case "completed": return contains_text(s, c[which].check_text);
   }
   return contains_text(visit_url(c[which].check_url), c[which].check_text);
}

int stepcount = 0;
// returns true if it's OK to adventure
boolean check_adv(required_item i) {
   if (to_boolean(vars["checklist_info_only"])) {
      stepcount = stepcount + 1;
      if (stepcount < show_steps) return false;
      abort("Not adventuring.  Set 'checklist_info_only' to false (in your vars_myname.txt file) if you want to adventure.");
   }
   if (i.where == "pirate cove" && item_amount($item[dingy dinghy]) == 0) {
      while (item_amount($item[dinghy plans]) == 0 && my_adventures() > 3 && my_meat() > 500)
         adventure(1,$location[moxie vacation]);
      if (item_amount($item[dinghy plans]) == 0) abort("Not enough meat/adv to procure dinghy plans.");
      if (item_amount($item[dingy planks]) == 0) hermit(1,$item[dingy planks]);
      use(1,$item[dinghy plans]);
   }
   if (!can_adv(to_location(i.where),true)) abort();
   if (unsafe(my_defstat() + to_int(vars["threshold"]) - i.safemox - monster_level_adjustment()))
      abort("You need +"+(i.safemox+monster_level_adjustment()-my_defstat()-to_int(vars["threshold"])-current_mcd())+" moxie to adventure here safely ("+i.where+").");
   return true;
}

// handles daily dungeon diving
void dungeon_check() {
   if (my_buffedstat($stat[muscle]) < 42 || my_buffedstat($stat[mysticality]) < 42 ||
     my_buffedstat($stat[moxie]) < 42 || get_property("dailyDungeonDone") == "true") return;
   int keys = to_int(item_amount($item[boris's key])>0) + to_int(item_amount($item[sneaky pete's key])>0) + to_int(item_amount($item[jarlsberg's key])>0);
   switch (keys) {
      case 3: print("You already have all three daily dungeon keys.","green"); return;
      case 2: if (to_boolean(vars["checklist_dive_for_third"])) print("You have 2/3 keys, and 'checklist_dive_for_third' set to true.  Diving...");
              else { print("You have 2/3 keys and you have 'checklist_dive_for_third' set to false.  Not diving."); return; }
      default: if (!dailydungeon()) print("You were unable to complete the Daily Dungeon today.  Try again later.","olive");
   }
}

// takes care of dolphin map if you have it
void dolphin_check() {
	if(!contains_text(visit_url("questlog.php?which=3&pwd"),"Dolphin King's treasure"))
	{
		dress_for_fighting();
		while(item_amount($item[Dolphin King's map])==0 && my_adventures() > 0)
		{
			adventure(1,$location[Haunted Pantry]);
		}
		if(item_amount($item[Dolphin King's map])!=0)
		{
			if (my_meat() < 30) return;
			buy(1,$item[snorkel]);
			item currenthead = equipped_item($slot[hat]);
			equip($item[snorkel]);
			use(1,$item[dolphin king's map]);
			equip(currenthead);
		}
	}
}

// takes care of slug lord's map if you have it
void slug_check() {
	if(!contains_text(visit_url("questlog.php?which=3&pwd"),"Slug Lord's treasure") && my_adventures()>0)
	{
		dress_for_fighting();
		while(item_amount($item[The Slug Lord's map])==0 && my_adventures() > 0)
		{
			adventure(1,$location[Sleazy Back Alley]);
		}
   		cli_execute("checkpoint");
		cli_execute("maximize stench resistance");
		if(!resist($element[stench],true)) return;
		if(item_amount($item[The Slug Lord's map])>0)
		{
			use(1,$item[slug lord's map]);
		}
   		cli_execute("outfit checkpoint");
	}
}

setvar("checklist_get_ns_items",false);
setvar("checklist_get_servants",true);
setvar("checklist_info_only",true);
setvar("checklist_dive_for_third",false);
setvar("automcd",true);

void main() {
   check_version("Hardcore Checklist","checklist",this_ver,1045);
   cli_execute("checkpoint");
   dungeon_check();
   dolphin_check();
   slug_check();
   load_list("checklist");

  // cache some things to reduce server hits
   print("Checking for items...");
   s = visit_url("questlog.php?which=2");
   if (my_level() != to_int(get_property("lastCouncilVisit"))) visit_url("council.php");
   if ((!contains_text(s,"retrieve the Pretentious Artist's stuff")) &&
       ((item_amount($item[pretentious paintbrush]) == 0 && item_amount($item[pretentious palette]) == 0 && item_amount($item[pail of pretentious paint]) == 0) ||
        (item_amount($item[pretentious paintbrush]) > 0 && item_amount($item[pretentious palette]) > 0 && item_amount($item[pail of pretentious paint]) > 0)))
     visit_url("town_wrong.php?place=artist");
   if (!can_interact() && item_amount($item[goofballs]) == 0 && contains_text(visit_url("town_wrong.php?place=goofballs"),"First bottle's free"))
     visit_url("town_wrong.php?action=buygoofballs");

  // main loop
   int i = 0;
   while (i < count(c)) { if (!check_it(i)) {
     // if it's just a condition that needs to be met
      if (c[i].req == "none") {
         print("Step "+i+": adventure at "+c[i].where+" until '"+c[i].check_text+"' in "+c[i].check_url,"blue");
         if (!check_adv(c[i])) { i = i + 1; continue; }
         cli_execute("conditions clear");
         repeat {
            if (check_adv(c[i])) adventure(1, to_location(c[i].where));
         } until ((check_it(i)) || (my_adventures() == 0));
     // or, if we have an item requirement,
      } else if (have_item(c[i].req) < c[i].quant) {
         if (creatable_amount(to_item(c[i].req)) > 0 && create(min(creatable_amount(to_item(c[i].req)),c[i].quant),to_item(c[i].req)) &&
             have_item(c[i].req) >= c[i].quant) continue;
         print("Step "+i+": procure "+c[i].quant+" "+c[i].req+" from "+c[i].where+" (safemox: "+c[i].safemox+")","blue");
         if (!check_adv(c[i])) { i = i + 1; continue; }
         cli_execute("conditions clear");
         repeat {
            if (check_adv(c[i])) adventure(1, to_location(c[i].where));
            if (c[i].req == "64735 scroll") {
              add_item_condition(1,$item[64735 scroll]);
              boolean catch=adventure(my_adventures(),$location[orc chasm]);
              cli_execute("conditions clear");
            }
            if (c[i].where == "degrassi knoll") cli_execute("use * gnollish toolbox");
            if (c[i].where == "dungeons of doom") cli_execute("use * small box; use * large box");
            if (c[i].where == "fantasy airship") cli_execute("use * penultimate fantasy chest");
            if (c[i].where == "black forest") cli_execute("use * black picnic basket");
            if (creatable_amount(to_item(c[i].req)) > 0 && create(min(creatable_amount(to_item(c[i].req)),c[i].quant),to_item(c[i].req))) {}
         } until (have_item(c[i].req) >= c[i].quant);
         cli_execute("outfit checkpoint");
        // turn in mosquito
         if (c[i].req == "mosquito larva") visit_url("council.php");
        // use some items
         if (c[i].req == "64735 scroll") use(1, $item[64735 scroll]);
         if (c[i].req == "31337 scroll") { use(1, $item[31337 scroll]); cli_execute("use * hermit script"); }
        // use plus sign
         if (c[i].req == "plus sign") {
            if (my_meat() < 1000) {
               print("You need meat for the Oracle."); change_mcd(0);
               while (my_meat() < 1000 && my_adventures() > 0) adventure(1,$location[treasury]);
               check_adv(c[i]);
            }
            cli_execute("conditions add 1 choiceadv; adventure * greater-than sign");
            use(1,$item[plus sign]);
         }
        // if item was sonar and batland is not unlocked, use it
         if (c[i].req == "sonar-in-a-biscuit") while (!contains_text(visit_url(c[i].check_url), c[i].check_text))
            use(1,$item[sonar-in-a-biscuit]);
        // if item was disembodied brain, build something
         if (c[i].req == "disembodied brain") {
             if (!have_maid) {
                if (retrieve_item(1,$item[meat maid])) {
                   use(1,$item[meat maid]);
                   have_maid = true; i = 37;
                }
             } else if (!simons_have_chef()) {
                if (retrieve_item(1,$item[chef-in-the-box])) {
                   use(1,$item[chef-in-the-box]);
                   i = 37;
                }
             } else if (!simons_have_bartender()) {
                if (retrieve_item(1,$item[bartender-in-the-box]))
                   use(1,$item[bartender-in-the-box]);
             }
         }
        // if item was anticheese, make the goat
         if (c[i].req == "anticheese") if (retrieve_item(1, $item[goat])) use(1, $item[goat]);
        // if item was sabre teeth, make the sabre-toothed lime
         if (c[i].req == "sabre teeth") if (retrieve_item(1, $item[sabre-toothed lime cub])) use(1, $item[sabre-toothed lime cub]);
         print("Step "+i+" cleared.","blue");
      }}
      if (c[i].req == "Spooky Temple map" && item_amount($item[Spooky Temple map]) > 0) use(1, $item[Spooky Temple map]);
     // meatcar
      if (c[i].req == "tires" && item_amount($item[tires]) > 0 && item_amount($item[bitchin' meatcar]) == 0 && !contains_text(s,"built a new meat car")) {
         if (item_amount($item[sweet rims]) + item_amount($item[dope wheels]) == 0)
            hermit(1,$item[sweet rims]);
         retrieve_item(1,$item[bitchin' meatcar]);
      }
      if (item_amount($item[bitchin' meatcar]) > 0 && item_amount($item[degrassi knoll shopping list]) > 0)
         use(1,$item[degrassi knoll shopping list]);
      i = i + 1;
   }
   if (to_boolean(vars["checklist_get_ns_items"])) retrieve_item(1, $item[hair spray]);
   print("All steps clear!","blue");
}