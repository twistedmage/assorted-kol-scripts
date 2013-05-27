#/******************************************************************************
#                                ZLib : 19
#                    supporting functions for scripts
#*******************************************************************************
#
#   Want to say thanks?  Send me (Zarqon) a bat! (Or bat-related item)
#
#   For a list of included functions, check out
#   http://kolmafia.us/showthread.php?t=2072
#
#******************************************************************************/

// stuff that has to be at the top
int abs(int n) { if (n < 0) return -n; return n; }
string[string] vars;

//                             STRING ROUTINES

// returns the string between start and end in source
// passing an empty string for start or end means the end of the string
string excise(string source, string start, string end) {
   if (start != "") {
      if (!source.contains_text(start)) return "";
      source = substring(source,index_of(source,start)+length(start));
   }
   if (end == "") return source;
   if (!source.contains_text(end)) return "";
   return substring(source,0,index_of(source,end));
}

// improved print(), prints message depending on vars["verbosity"] setting
// has boolean return value -- replaces { print(message); return t/f; }
// level == 0: abort error
// level > 0: prints message if verbosity >= level, returns true
// level < 0: prints message if verbosity >= abs(level), returns false
// ===== Recommended level scale: ====
// 0: abort error
// (-)1: essential (and non-cluttering) information -- use very sparingly, since a verbosity of 1 is basically "silent mode"
// (-)2: important and useful info -- this should generally be your base level for your most important messages
// (-)4: interesting but non-essential information
// (-)6: info which an overly curious person might like to see on their CLI
// (-)10: details which are only helpful for debugging, such as "begin/end functionname()" or "current value of variable: value"
boolean vprint(string message, string color, int level) {
   if (level == 0) abort(message);
   if (to_int(vars["verbosity"]) >= abs(level)) print(message,color);
   return (level > 0);
}
boolean vprint(string message, int level) { if (level > 0) return vprint(message,"black",level); return vprint(message,"red",level); }
boolean vprint_html(string message, int level) {
   if (level == 0) { print_html(message); abort(); }
   if (to_int(vars["verbosity"]) >= abs(level)) print_html(message);
   return (level > 0);
}

// mafia lacks this ... ?
element to_element(string s) {
   switch (s) {
      case "hot":
      case "heat": return $element[hot];
      case "cold": return $element[cold];
      case "spooky": return $element[spooky];
      case "sleaze": return $element[sleaze];
      case "stench": return $element[stench];
      case "slime": return $element[slime];
   }
   return $element[none];
}

// human-readable number (adds commas for large numbers, truncates floats at specified place)
string rnum(int n) {
   buffer cr;
   boolean neg;
   if (n < 0) { neg = true; n = -n; }
   cr.append(to_string(n));
   if (cr.length() > 4) for i from 1 to floor((cr.length()-1) / 3.0)
      cr.insert(cr.length()-(i*3)-(i-1),",");
   if (neg) return "-"+to_string(cr);
   return to_string(cr);
}
string rnum(float n, int place) {
   if (to_float(round(n)) == n || place < 1) return rnum(round(n));
   buffer res;
   res.append(rnum(truncate(n))+".");
   if (n < 0 && n > -1) res.insert(0,"-");
   res.append(excise(to_string(round(n*10.0^place)/10.0^place),".",""));
   return to_string(res);
}
string rnum(float n) { return rnum(n,2); }


//                             NUMBER ROUTINES

float minmax(float a, float min, float max) { return max(min(a,max),min); }
float abs(float n) { if (n < 0) return -n; return n; }
void set_avg(float toadd, string whichprop) {
   string initv = get_property(whichprop);
   if (initv == "") { set_property(whichprop,toadd+":1"); return; }
   float a = to_float(excise(initv,"",":"));
   float b = to_float(excise(initv,":",""));
   a = ((a * b)+toadd) / (b+1);
   b = b + 1;
   set_property(whichprop,a+":"+b);
}
float get_avg(string whichprop) {
   string initv = get_property(whichprop);
   if (initv == "") return 0;
   return to_float(substring(initv,0,index_of(initv,":")));
}

// Evaluates expressions in the format used by variable modifiers:
//
// No spaces allowed, except as part of a zone/location name.
// + - * / ( ) have their usual mathematical meaning and precedence.
// ^ is exponentiation, with the highest precedence.
// Math functions: ceil(x) floor(x) sqrt(x) min(x,y) max(x,y)
// Text functions (can use a maximum of ONE!):
//   loc(text), zone(text) - 1 if the current adventure location or zone contains the specified text, 0 elsewise.
//   fam(text) - 1 if the player's familiar type contains the text, else 0.
//   pref(text) - must be used on preferences with a float value ONLY - merely retrieving an integer pref will corrupt it!
// Internally-used variables (upper-case letters)
//	D - drunkenness
//	F - fullness
//	G - Grimace darkness (0..5)
//	L - player level
//	M - total moonlight (0..9)
//	S - spleenness
//	X - gender (-1=male, 1=female)
// User-defined variables (provided in "values") must begin with lowercase letters/underscores
float eval(string expr, float[string] values) {
   buffer b;
   matcher m = create_matcher("\\b[a-z_][a-zA-Z0-9_]*\\b", expr);
   while (m.find()) {
      string var = m.group(0);
      if (values contains var) m.append_replacement(b, values[var].to_string());
   }
   m.append_tail(b);
   vprint("Evaluating '"+b.to_string()+"'...",8);
   return modifier_eval(b.to_string());
}


//                             SCRIPT ROUTINES

// checks script version once daily
void check_version(string soft, string prop, string thisver, int thread) { int w;
   switch (get_property("_version_"+prop)) {
      case thisver: return;
      case "": vprint("Checking for updates (running "+soft+" ver. "+thisver+")...",1);
         matcher find_ver = create_matcher("<b>"+soft+" (.+?)</b>",visit_url("http://kolmafia.us/showthread.php?t="+thread)); w=19;
         if (!find_ver.find()) { vprint("Unable to load current version info.",-1); return; }
         set_property("_version_"+prop,find_ver.group(1));
         if (find_ver.group(1) == thisver) { vprint("You have a current version of "+soft+".",1); return; }
      default:
         vprint_html("<big><font color=red><b>New Version of "+soft+" Available: "+get_property("_version_"+prop)+"</b></font></big>",1);
         vprint("Upgrade "+soft+" from "+thisver+" to "+get_property("_version_"+prop)+" here: http://kolmafia.us/showthread.php?t="+thread,"blue",1);wait(1+w);
   }
}

// loads specified map file either from disk or from Map Manager if an updated map is available (checks once daily)
boolean load_current_map(string fname, aggregate dest) {
   file_to_map(fname+".txt",dest);
   string curr = get_property("map_"+fname+".txt");
   if (contains_text(curr,today_to_string())) return (count(dest) > 0);
   string rem = visit_url("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getver");
   if (contains_text(curr,rem) && count(dest) > 0) {
      set_property("map_"+fname+".txt",rem+", checked "+today_to_string());
      return vprint("You have the latest "+fname+".txt.  Will not check again today.",3);
   }
   vprint("Updating "+fname+".txt from '"+curr+"'...",1);
   if (!file_to_map("http://zachbardon.com/mafiatools/autoupdate.php?f="+fname+"&act=getmap",dest) || count(dest) == 0)
      return vprint("Error loading "+fname+".txt from the Map Manager.","red",-1);
   map_to_file(dest,fname+".txt");
   set_property("map_"+fname+".txt",rem+", checked "+today_to_string());
   return vprint("..."+fname+".txt updated.",1);
}


//                                 WOSSMAN

file_to_map("vars_"+replace_string(my_name()," ","_")+".txt",vars);

// writes local vars map
boolean updatevars() {
   return map_to_file(vars,"vars_"+replace_string(my_name()," ","_")+".txt");
}
void setvar(string varname,string dfault,string type) {
   if (vars contains varname) return;
   vprint("New ZLib setting: "+varname+" => "+dfault,"purple",4);
  // submit var/type to remote map
   vars[varname] = dfault;
   updatevars();
}
void setvar(string varname,string dfault) {  setvar(varname,dfault,"string");  }
void setvar(string varname,boolean dfault) {  setvar(varname,to_string(dfault),"boolean");  }
void setvar(string varname,int dfault) {  setvar(varname,to_string(dfault),"int");  }
void setvar(string varname,float dfault) {  setvar(varname,to_string(dfault),"float");  }
void setvar(string varname,item dfault) {  setvar(varname,to_string(dfault),"item");  }
void setvar(string varname,location dfault) {  setvar(varname,to_string(dfault),"location");  }
void setvar(string varname,element dfault) {  setvar(varname,to_string(dfault),"element");  }
void setvar(string varname,familiar dfault) {  setvar(varname,to_string(dfault),"familiar");  }
void setvar(string varname,skill dfault) {  setvar(varname,to_string(dfault),"skill");  }
void setvar(string varname,effect dfault) {  setvar(varname,to_string(dfault),"effect");  }
void setvar(string varname,stat dfault) {  setvar(varname,to_string(dfault),"stat");  }
void setvar(string varname,class dfault) {  setvar(varname,to_string(dfault),"class");  }


//                           ADVENTURING ROUTINES

// returns how many of an item you have
int have_item(string tolookup) {
   return item_amount(to_item(tolookup)) + equipped_amount(to_item(tolookup));
}

float [item][item] useforitems;
float has_goal(item whatsit) {                   // chance of getting a goal from an item
   float has_goal(item whatsit,int level) {
     if (whatsit == $item[none]) return 0;
     if (is_goal(whatsit) || whatsit == to_item(to_int(get_property("currentBountyItem")))) return 1.0;
     if (count(useforitems) == 0 && !load_current_map("use_for_items", useforitems)) {
        vprint("Unable to load file \"use_for_items.txt\".",-3); return 0;
     }
     if (level > 5) return 0;  // avoid infinite recursion
     float res;
     if (useforitems contains whatsit) foreach key,perc in useforitems[whatsit]
        if (has_goal(key,level+1) > 0) res = max(res,perc);
     return res;
   }
   return has_goal(whatsit,0);
}
float has_goal(monster m) {                      // chance of getting a goal from a monster
   float res, temp;
   foreach num,rec in item_drops_array(m) {
      temp = has_goal(rec.drop);
      if (temp == 0) continue;
      switch (rec.type) {
         case "p": if (my_primestat() == $stat[moxie] || have_effect($effect[Form of...Bird!]) > 0)
            res = res + temp*minmax(rec.rate*(numeric_modifier("Pickpocket Chance")+100)/100.0,0,100)/100.0; continue;
		 case "b": return 1;
         case "c": if (!is_displayable(rec.drop) || (item_type(rec.drop) == "shirt" && !have_skill($skill[torso awaregness]))) continue;
         case "":
         case "n": res = res + temp*minmax(rec.rate*(item_drop_modifier()+100)/100.0,0,100)/100.0;
      }
   }
   return res;
}
float has_goal(location l) {                     // chance of getting a goal from a location (-noncombats)
   float res;
   foreach m,r in appearance_rates(l) {
      if (r <= 0 || m == $monster[none]) continue;
      res = res + has_goal(m)*r/100.0;
   }
   return res;
}

// gets n (-existing) of cond, either by purchasing, pulling from Hangk's, or
// adventuring at the given location.  also works with choiceadvs
boolean obtain(int n, string cond, location locale) {
   if (cond == "choiceadv") cli_execute("conditions clear; conditions add "+n+" choiceadv");
   else {
      if (retrieve_item(n, to_item(cond))) return vprint("You have "+n+" "+cond+", no adventuring necessary.",5);
      if (!in_hardcore() && storage_amount(to_item(cond)) > 0) take_storage(n-have_item(cond),to_item(cond));
       if (have_item(cond) >= n) return vprint("You have taken your needed items from storage.",5);
      cli_execute("conditions clear");
      add_item_condition(n - have_item(cond), to_item(cond));
   }
   set_location(locale);
   if (adventure(my_adventures(), locale)) return vprint("Out of adventures.",-1);
   if (cond == "choiceadv") return (my_adventures() > 0);
   return (have_item(cond) >= n);
}

// gets (if purchase) and uses n doodads if possible
// otherwise, uses as many as you have up to n
boolean use_upto(int n, item doodad, boolean purchase) {
   if (doodad == $item[deodorant] && item_amount($item[chunk of rock salt]) > item_amount(doodad)) doodad = $item[chunk of rock salt];
   if (item_amount(doodad) >= n || (purchase && retrieve_item(n, doodad))) return use(n, doodad);
   if (item_amount(doodad) == 0) return false;
   return use(item_amount(doodad), doodad);
}

// attempts to resist the given element
boolean resist(element req, boolean reallydoit) {
   vprint("Checking resistance to "+req+"...",2);
   if (req == $element[none]) return true;
   if (elemental_resistance(req) >= 10) return vprint("You can already resist "+req+".",5);
  // first, try catchall buffs (more expensive but least likely to screw someone up)
   if (have_skill($skill[astral shell]) && (
       (!reallydoit && my_mp() >= mp_cost($skill[astral shell])) ||
       (reallydoit && use_skill(1,$skill[astral shell])))) return vprint("Resistance achieved via Astral Shell.",5);
   if (have_skill($skill[elemental saucesphere]) && (
       (!reallydoit && my_mp() >= mp_cost($skill[elemental saucesphere])) ||
       (reallydoit && use_skill(1,$skill[elemental saucesphere])))) return vprint("Resistance achieved via saucesphere.",5);
  // next, try resistance from gear
   int[item] mgear = get_inventory();
   string rtype = to_string(req) + " resistance";
   vprint("Searching items for "+rtype+"...",3);
   foreach doodad in mgear {
      if (to_slot(doodad) != $slot[none] && numeric_modifier(doodad,rtype) >= 1.0 && can_equip(doodad)) {
         vprint("Resistance-granting item found: "+doodad,3);
         if (reallydoit) {
            if (to_slot(doodad) == $slot[acc1]) equip($slot[acc3],doodad);
              else equip(doodad);
            if (elemental_resistance(req) < 10) return vprint("Unable to equip your "+doodad+".",-5);
         }
         return vprint("Resistance achieved via gear.",5);
      }
   }
  // last, try resistance from the parrot
   if (have_familiar($familiar[exotic parrot])) {
       int necessary_parrot_weight(element which) {
          switch (which) {
             case $element[hot]: return 1;
             case $element[cold]: return 5;
             case $element[spooky]: return 9;
             case $element[stench]: return 13;
             case $element[sleaze]: return 17;
          }
          return 0;
       }
       int possible_parrot_weight() {
          int result = familiar_weight($familiar[exotic parrot]);
          if (familiar_equipped_equipment($familiar[exotic parrot]) == $item[cracker] || item_amount($item[cracker]) > 0)
             result = result + 15;
          return result + numeric_modifier("Familiar Weight") - numeric_modifier(equipped_item($slot[familiar]),"Familiar Weight");
       }
       if (possible_parrot_weight() >= necessary_parrot_weight(req)) {
          vprint("Your parrot is able to resist "+req+".",3);
          if (reallydoit) {
             use_familiar($familiar[exotic parrot]);
             if (familiar_equipped_equipment($familiar[exotic parrot]) != $item[cracker] && item_amount($item[cracker]) > 0)
                equip($item[cracker]);
          }
          return vprint("Resistance achieved via parrot.",5);
       }
   }
   return vprint("Unable to resist "+req+"!",-2);
}

// returns the value of your buffed defense stat, factoring in Hero of the Half-Shell
int my_defstat() {
   if (have_skill($skill[hero of the half-shell]) && item_type(equipped_item($slot[offhand])) == "shield")
      return max(my_buffedstat($stat[muscle]),my_buffedstat($stat[moxie]));
   return my_buffedstat($stat[moxie]);
}

// returns safe moxie for a given location (includes +ML and MCD, skips bosses)
int get_safemox(location wear) {
   int high;
   foreach i,m in get_monsters(wear) {
      switch(m) {
         case $monster[dr. awkward]:
         case $monster[ancient protector spirit]:
         case $monster[ol scratch]:
         case $monster[frosty]:
         case $monster[oscus]:
         case $monster[zombo]:
         case $monster[chester]:
         case $monster[hodgman, the hoboverlord]: continue;
         case $monster[clownlord beelzebozo]: if (get_property("choiceAdventure151") != "1") continue; break;
         case $monster[conjoined zmombie]: if (get_property("choiceAdventure154") != "1") continue; break;
         case $monster[giant skeelton]: if (get_property("choiceAdventure156") != "1") continue; break;
         case $monster[gargantulihc]: if (get_property("choiceAdventure158") != "1") continue; break;
         case $monster[huge ghuol]: if (get_property("choiceAdventure160") != "1") continue;
      }
      high = max(monster_attack(m),high);
   }
   if (high == 0 || high == monster_level_adjustment()) return 0;
   return high + 7 - current_mcd();
}

// if 'automcd' is true, adjusts your MCD for the specified safemox based on your threshold
boolean auto_mcd(int safemox) {
   if (!to_boolean(vars["automcd"]) || (my_ascensions() < 1)) return true;
   if ((in_muscle_sign() && !retrieve_item(1,$item[detuned radio])) ||
     (in_moxie_sign() && available_amount($item[bitchin meatcar]) == 0) &&
      !contains_text(get_property("unlockedLocations"),"South of the Border") &&
      !contains_text(get_property("unlockedLocations"),"Thugnderdome"))
      return vprint("MCD: unavailable","olive",5);
   if (safemox == 0) {
      vprint("MCD: Using your 'unknown_ml' value ("+vars["unknown_ml"]+").","olive",2);
      safemox = to_int(vars["unknown_ml"]) + 7;
   }
   int adj = minmax(my_defstat() + to_int(vars["threshold"]) - safemox, 0, 10+in_mysticality_sign().to_int());
   if (current_mcd() == adj) return true;
   else return (vprint("MCD: adjusting to "+adj+"...","olive",2) && change_mcd(adj));
}
boolean auto_mcd(monster mob) {                               // automcd for a single monster
   if (monster_attack(mob) == monster_level_adjustment()) return auto_mcd(0);
   return auto_mcd(monster_attack(mob) + 7 - current_mcd());
}
boolean auto_mcd(location place) {                            // automcd for locations
   if (my_location() == $location[boss bat's lair] || my_location() == $location[king's chamber] ||
       my_location() == $location[haert of the cyrpt] || my_location() == $location[slime tube])
      return vprint("MCD: Sensitive location, not adjusting.","olive",4);
   if (count(get_monsters(place)) == 0) return vprint("MCD: "+place+" has no known combats.","olive",4);
   return auto_mcd(get_safemox(place));
}

// returns your heaviest familiar of a given type (currently possible: items, meat, produce, stat, delevel)
familiar best_fam(string ftype) {
   if (to_familiar(vars["is_100_run"]) != $familiar[none]) return to_familiar(vars["is_100_run"]);
   familiar result = $familiar[none];
   string[familiar] fams;
   if (!load_current_map("bestfamiliars",fams)) return result;
   vprint("Finding best familiar of type \""+ftype+"\"...",3);
   int bestweight = 0;
   int beststrength = 0;
   int famstrength(string alltypes, string targettype) {
     matcher m = create_matcher("(\\w+)\\s+(\\d+)", alltypes);          // thanks for the regex Jason
     while (m.find()) if (m.group(1) == targettype) return to_int(m.group(2));
     return 0;
   }
   foreach i in fams {
     if (!have_familiar(i) || !contains_text(fams[i],ftype)) continue;
     if (familiar_weight(i) > bestweight || (familiar_weight(i) == bestweight && famstrength(fams[i],ftype) > beststrength)) {
        if (result == $familiar[none]) vprint("First match for type \""+ftype+"\": "+i,3);
         else vprint(i+" is better than "+result+"...",3);
        result = i;
        bestweight = familiar_weight(i);
        beststrength = famstrength(fams[i],ftype);
     }
   }
   if (result == $familiar[none]) {
      vprint("No familiar found matching type \""+ftype+"\"",-3);
      return my_familiar();
   }
   return result;
}

boolean send_gift(string to, string message, int meat, int[item] goodies, string insidenote) {
 // parse items into query string
   string itemstring = "";
   int j = 0;
   int[item] extra;
   foreach i in goodies {
      if (is_tradeable(i) || is_giftable(i)) {
         j = j+1;
         if (j < 4)
           itemstring = itemstring + "&howmany"+j+"="+goodies[i]+"&whichitem"+j+"="+to_int(i);
         else extra[i] = goodies[i];
      }
   }
   int shipping = 200;
   int pnum = 3;
   if (count(goodies) < 3) {
      shipping = 50*max(1,count(goodies));
      pnum = max(1,count(goodies));
   }
   if (my_meat() < meat+shipping) return vprint("Not enough meat to send the package.",-2);
  // send gift
   string url = visit_url("town_sendgift.php?pwd=&towho="+to+"&note="+message+"&insidenote="+insidenote+"&whichpackage="+pnum+"&fromwhere=0&sendmeat="+meat+"&action=Yep."+itemstring);
   if (!contains_text(url,"Package sent.")) return vprint("The message didn't send for some reason.",-2);
   if (count(extra) > 0) return send_gift(to,message,0,extra,insidenote);
   return true;
}
boolean send_gift(string to, string message, int meat, int[item] goodies) { return send_gift(to,message,meat,goodies,""); }

boolean kmail(string to, string message, int meat, int[item] goodies, string insidenote) {
   if (meat > my_meat()) return vprint("You don't have "+meat+" meat.",-2);
  // parse items into query strings
   string itemstring = "";
   int j = 0;
   string[int] itemstrings;
   foreach i in goodies {
      if (is_tradeable(i) || is_giftable(i)) {
         j = j+1;
         itemstring = itemstring + "&howmany"+j+"="+goodies[i]+"&whichitem"+j+"="+to_int(i);
         if (j > 10) {
            itemstrings[count(itemstrings)] = itemstring;
            itemstring = '';
            j = 0;
         }
      }
   }
   if (itemstring != "") itemstrings[count(itemstrings)] = itemstring;
   if (count(itemstrings) == 0) itemstrings[0] = "";
    else vprint(count(goodies)+" item types split into "+count(itemstrings)+" separate kmails.",5);
  // send message(s)
   foreach q in itemstrings {
      string url = visit_url("sendmessage.php?pwd=&action=send&towho="+to+"&message="+message+"&savecopy=on&sendmeat="+meat+itemstrings[q]);
      if (contains_text(url,"That player cannot receive Meat or items"))
        return (vprint("That player cannot receive stuff, sending gift instead...",4) && send_gift(to, message, meat, goodies, insidenote));
      if (!contains_text(url,"Message sent.")) return vprint("The message didn't send for some reason.",-2);
   }
   return true;
}
boolean kmail(string to, string message, int meat, int[item] goodies) { return kmail(to,message,meat,goodies,""); }
boolean kmail(string to, string message, int meat) { int[item] nothing; return kmail(to,message,meat,nothing,""); }

// NOTE: after running this script, changing these variables here in the script will have no
// effect.  You should instead edit the values in vars_myname.txt, in mafia's data directory.
setvar("automcd",true);
setvar("threshold",4);
setvar("verbosity",3);
setvar("unknown_ml",170);
setvar("is_100_run",$familiar[none]);
setvar("defaultoutfit","current");

check_version("ZLib","zlib",": 19",2072);
void main(string setval) {
   if (setval == "vars") {
      vprint_html("<b>Copy/paste any of the following lines into the CLI to edit settings:</b><br>",1);
      foreach key,val in vars vprint("zlib "+key+" = "+val,1); return;
   }
   if (!setval.contains_text(" = ")) vprint("Proper syntax is settingname = value",0);
   string n = substring(setval,0,index_of(setval," = "));
   if (!(vars contains n)) { vprint("No setting named '"+n+"' exists.","olive",-2); return; }
   string v = substring(setval,index_of(setval," = ")+3);
   print("Previous value of "+n+": "+vars[n]);
   if (vars[n] == v) return;
   if (n == "threshold") {
      if (v == "up") v = to_string(to_int(vars["threshold"])+1);
      if (v == "down") v = to_string(to_int(vars["threshold"])-1);
   }
   vars[n] = v;
   if (updatevars()) print("Changed to "+v+".");
}
