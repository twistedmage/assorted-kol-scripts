// Factroid!: Collect Them All
// by Zarqon, with thanks to turing's missingManuel.ash for a great starting point
import <zlib.ash>

int[string] fs;
file_to_map("factoids_"+replace_string(my_name()," ","_")+".txt",fs);

boolean[string] notmonsters = $strings[Ancient Protector Spirit (crackling), Ancient Protector Spirit (moss-covered), Ancient Protector Spirit (scorched),
      Ancient Protector Spirit (dripping), Clingy Pirate (female), Animated Nightstand (Mahogany) (Noncom), Animated Nightstand (White) (Noncom),
      Batwinged Gremlin (tool), Erudite Gremlin (tool), Spider Gremlin (tool), Vegetable Gremlin (tool), Ninja Snowman (Mask),
      Bizarre Construct (translated), Hulking Construct (translated), Industrious Construct (translated), Lonely Construct (translated),
      Menacing Construct (translated), Towering Construct (translated)];  // KoL monsters that mafia doesn't distinguish

boolean blocked(monster mon) {  // mafia monsters that KoL doesn't distinguish
   if ($monsters[Cyrus the Virus, The Whole Kingdom,
      Don Crimbo, Edwing Abbidriel, Crys-Rock, Trollipop, The Colollilossus, The Fudge Wizard, The Abominable Fudgeman, Uncle Hobo, Underworld Tree,
      Arc-welding Elfborg, Ribbon-cutting Elfborg, Decal-applying Elfborg, Weapons-assembly Elfborg, Crimbomega,
      Gnollish Sorceress, Giant Pair of Tweezers, 7-Foot Dwarf,
      Hammered Yam Golem, Soused Stuffing Golem, Plastered Can of Cranberry Sauce, Inebriated Tofurkey,
      Striking Stocking-Stuffer Elf, Striking Pencil-Pusher Elf, Striking Middle-Management Elf, Striking Gift-Wrapper Elf, Striking Factory-Worker Elf,
      rock homunculus, rock snake,
      Servant Of Lord Flameface, space beast matriarch,
      The Darkness (blind),
      Fudge monkey, Fudge oyster, Fudge vulture,
      Amateur Elf, Auteur Elf, Provocateur Elf, Raconteur Elf, Saboteur Elf, Wire-Crossin' Elf, Mob Penguin Caporegime, Mob Penguin Goon, Mob Penguin Kneecapper,
      Deadwood Tree, Fur Tree, Hangman's Tree, Pumpkin Tree,
      Skeleton Invader, Two Skeleton Invaders, Three Skeleton Invaders, Four Skeleton Invaders,
      CDMoyer's Butt, Hotstuff's Butt, Jick's Butt, Mr. Skullhead's Butt, Multi Czar's Butt, Riff's Butt,
      Slime2, Slime3, Slime4, Slime5,
      Ed the Undying (2), Ed the Undying (3), Ed the Undying (4), Ed the Undying (5), Ed the Undying (6), Ed the Undying (7),
      Count Drunkula (Hard Mode), Falls-From-Sky (Hard Mode), Great Wolf of the Air (Hard Mode), Mayor Ghost (Hard Mode), The Unkillable Skeleton (Hard Mode), Zombie Homeowners' Association (Hard Mode),
      wild seahorse,
      All-Hallow's Steve, The Sagittarian, general seal, Frank &quot;Skipper&quot; Dan\, the Accordion Lord, Chef Boy\, R&amp;D, spirit alarm clock, Caveman Dan] contains mon) return true;
   return false;
}
string fixmon(string name, string first, string img) {  // disambiguate KoL duplicate names.  hey mon!
   switch (name) {
      case "guard turtle": if (contains_text(first, "red shells")) return $monster[French Guard Turtle]; break;
      case "(shadow opponent)": return $monster[your shadow];
      case "Hobelf": if (contains_text(first,"Hobelfs")) return $monster[Elf Hobo]; break;
      case "Slime Tube Monster": return $monster[slime1];
      case "Ed the Undying": return $monster[Ed the Undying (1)];
      case "mimic": if (contains_text(first, "Mimic eggs greatly")) return $monster[Mimic (Bottom 2 Rows)];
         if (contains_text(first, "The least pleasant")) return $monster[Mimic (Middle 2 Rows)];
         if (contains_text(first, "The only thing a mimic")) return $monster[Mimic (Top 2 Rows)]; break;
      case "Orcish Frat Boy": if (contains_text(first, "uniformly terrible grades")) return $monster[Orcish Frat Boy (Music Lover)];
         if (contains_text(first, "garden variety Orcish Frat Boy")) return $monster[Orcish Frat Boy (Paddler)];
         if (contains_text(first, "self esteem of their pledges")) return $monster[Orcish Frat Boy (Pledge)]; break;
      case "[somebody else's butt]": return $monster[Somebody else's butt];
      case "spooky vampire": if (contains_text(first, "as a general rule")) return $monster[spooky vampire (Dreadsylvanian)]; break;
      case "Ancient Protector Spirit": if (contains_text(first, "potted plant")) return "Ancient Protector Spirit (moss-covered)";
         if (contains_text(first, "good explanation")) return "Ancient Protector Spirit (dripping)";
         if (contains_text(first, "corporate ladder")) return "Ancient Protector Spirit (crackling)";
         if (contains_text(first, "eight-year-olds")) return "Ancient Protector Spirit (scorched)"; break;
      case "Clingy Pirate": if (contains_text(first, "kind of a hassle")) return "Clingy Pirate (female)"; break;
      case "batwinged gremlin": if (contains_text(first, "Batwinged gremlins")) return "Batwinged Gremlin (tool)"; break;
      case "erudite gremlin": if (contains_text(first, "erudite gremlin has")) return "Erudite Gremlin (tool)"; break;
      case "spider gremlin": if (contains_text(first, "The spider DNA")) return "Spider Gremlin (tool)"; break;
      case "vegetable gremlin": if (contains_text(first, "look at the abs")) return "Vegetable Gremlin (tool)"; break;
      case "ninja snowman": if (contains_text(first, "modified form of judo")) return "Ninja Snowman (Mask)"; break;
      case "bizarre construct": if (contains_text(first, "this one is being singled out")) return "Bizarre Construct (translated)"; break;
      case "hulking construct": if (contains_text(first, "plain mayonnaise sandwich")) return "Hulking Construct (translated)"; break;
      case "industrious construct": if (contains_text(first, "rudimentary artificial intelligence")) return "Industrious Construct (translated)"; break;
      case "lonely construct": if (contains_text(first, "You shouldn't wonder why a robot would feel lonely")) return "Lonely Construct (translated)"; break;
      case "menacing construct": if (contains_text(first, "constructs play in a band")) return "Menacing Construct (translated)"; break;
      case "towering construct": if (contains_text(first, "clamp is capable of producing")) return "Towering Construct (translated)"; break;
      case "animated nightstand": if (contains_text(first, "made of teak")) return "Animated Nightstand (Mahogany) (Noncom)";
         if (contains_text(first, "disassembled with an allen wrench")) return "Animated Nightstand (White) (Noncom)";
   }
   if (name.to_monster() != $monster[none]) return normalized(name,"monster");
   monster imon = image_to_monster(img);
   if (imon != $monster[none]) name = imon.to_string();
    else vprint("Unknown monster: "+name,-3);   
   return name;
}
void parseman() {
   void onepage(string char) {
      string page = visit_url("questlog.php?which=6&vl="+char);
      matcher onem = create_matcher("(?:adventureimages|otherimages)\\/(.+?.gif).+?<font size=.2>([^<]+?)<\\/font><\\/b><ul><li>(.+?)<\\/ul>", page);
      while (onem.find()) {                                         // group 1: image.gif
         string name = onem.group(2);                               // group 2: monster name
         string[int] facts = split_string(onem.group(3),"<li>");    // group 3: all factoids, including intermediary <li>'s
         name = fixmon(name, facts[0], onem.group(1));
         fs[name] = count(facts);
      }
   }
   fs.clear();
   onepage("-");
   for i from 65 to 90 {
      print(entity_decode("&#"+i+";"));
      onepage(entity_decode("&#"+(i+32)+";"));
   }
   fs["lastchecked"] = now_to_string("yyyyMMdd").to_int();
   map_to_file(fs,"factoids_"+replace_string(my_name()," ","_")+".txt");
}

string[string] post = form_fields();
if (post contains "do") switch (post["do"]) {
   case "refresh": parseman(); break;
   case "foundone": if (post contains "mon" && post contains "img") {  // provide a hook to support quick factoid tracking
      string nom = fixmon(post["mon"],"",post["img"]);
      if (nom != "none" && nom != "") {
         fs[nom] += 1;
         write("Factoid saved: you now have found "+fs[nom]+" factoids for "+nom+".");
         map_to_file(fs,"factoids_"+replace_string(my_name()," ","_")+".txt");
      } else write("Factoid unable to be saved for "+nom+".");
    } exit;
   case "deets": buffer dbox;
      dbox.append("<center>\n<table class=dbox><tr><td>");
      monster graa = to_monster(post["mon"]);
      if (graa != $monster[none]) {
         dbox.append("<img src='images/itemimages/nicesword.gif' title='Attack'>"+rnum(monster_attack(graa)));  // attack
         dbox.append(" </td>\n<td><img src='images/itemimages/"+(graa.phylum == $phylum[none] ? "obnoxious.gif" : graa.phylum.image)+"' title='"+graa.phylum+"'>");  // phylum

         dbox.append("</td></tr>\n<tr><td><img src='images/itemimages/whiteshield.gif' title='Defense'>"+rnum(monster_defense(graa)));  // defense
         dbox.append(" </td>\n<td><img src='images/itemimages/"+monster_element(graa).image+"' title='"+monster_element(graa)+"'>");  // element

         dbox.append("</td></tr>\n<tr><td><img src='images/itemimages/hp.gif' title='HP'>"+rnum(monster_defense(graa)));  // hp
         dbox.append(" </td>\n<td><img src='images/itemimages/");  // initiative
         switch (monster_initiative(graa)) {
            case -1: dbox.append("obnoxious.gif' title='Initiative unknown"); break;
            case -10000: dbox.append("snail.gif' title='Never wins initiative"); break;
            case 10000: dbox.append("lightningbolt.gif' title='Always wins initiative"); break;
            default: dbox.append("watch.gif' title='Initiative +"+monster_initiative(graa)+"%"); break;
         }
         dbox.append("'></td></tr>\n<tr><td colspan=2 align=center>");  // fax
         if (item_amount($item[Clan VIP Lounge key]) > 0 && get_property("_photocopyUsed") == "false" && my_adventures() > 0 &&
           !($strings[Trendy, Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Slow and Steady, Heavy Rains] contains my_path())) {
            if (get_property("photocopyMonster").to_monster() == graa) dbox.append("<a href='inv_use.php?pwd="+my_hash()+
               "&which=3&whichitem=4873' title='Fight your copy of this monster'><img src='images/itemimages/photocopy.gif'></a>");
             else if (can_faxbot(graa)) dbox.append("<a href=relay_Factroid.ash class='cliimglink fax' title='"+
                (item_amount($item[photocopied monster]) > 0 ? "fax put; " : "")+"ash faxbot($monster["+graa+
                "])'><img src='images/itemimages/copier.gif' title='Faxbot this monster'></a>");
         }
         if (my_path() == "Heavy Rains" && my_adventures() > 0 && have_skill($skill[Rain Man]) && my_rain() >= 50 && fs[graa.to_string()] > 0) {
            dbox.append("<a href=skills.php?pwd&action=Skillz&whichskill=16011&quantity=1 class='cliimglink through' title='For now, casts Rain Man and dumps you on the selection menu.'><img src='images/itemimages/rainman.gif' title='Rain Man this monster.'></a>");
         }
      }
      string char = substring(post["mon"],0,1).to_lower_case(); if (!create_matcher("([a-zA-Z])",char).find()) char = "-";
      dbox.append("<a href=questlog.php?which=6&vl="+char+" title='Manuel entries, page "+char.to_upper_case()+  // manuel link
         "'><img src='images/itemimages/monstermanuel.gif'></a>");
      dbox.append("<a href=# class=cliimglink title=\"wiki "+post["mon"]+"\"><img "+     // wiki link
         "src='images/itemimages/necbronomicon.gif'></a>");
      dbox.append("</td></tr></table></center>");
      dbox.write();
      exit;
}

buffer page;
boolean[monster] considered;
if (!(fs contains "lastchecked")) parseman();

void write_monster(monster m, float r) {
   string fixednom(monster nom) { switch (nom) {
      case $monster[Ed the Undying (1)]: return "Ed the Undying";
      case $monster[Slime1]: return "Slime Tube Monster";
      case $monster[Ancient Protector Spirit]: return "Ancient Protector Spirit (dagger)";
      case $monster[Clingy Pirate]: return "Clingy Pirate (male)";
      case $monster[Ninja Snowman (Hilt/Mask)]: return "Ninja Snowman (Hilt)";
    } return nom; 
   }
   page.append("<div class='montile have"+fs[m.to_string()]+"'><img class='hand mon' src='/images/adventureimages/"+
      (m.image == "" ? "question.gif" : m.image)+"' title=\""+fixednom(m)+"\" style='height:40px;width:40px;'><br><div class='deets' data-monster=\""+m+"\"></div>");
   for i from 1 upto fs[m.to_string()] page.append(" &bull; ");
   page.append("<br><small>"+(r == 0 ? "--" : rnum(r)+"%")+"</small></div>");
}
void write_notmonster(string s) {
   matcher noinf = create_matcher("(.*?) \\(",s); monster eq;
   if (noinf.find()) eq = to_monster(noinf.group(1));
   if ($monsters[none, clingy pirate] contains eq) eq = $monster[possibility giant];  // we are only using eq for the image
   page.append("<div class='montile have"+fs[s]+"'><img class='hand mon' src='/images/adventureimages/"+
      eq.image+"' title=\""+s+"\" style='height:40px;width:40px;'><br>");
   for i from 1 upto fs[s] page.append(" &bull; ");
   page.append("</div>");
}
void write_group(string header, boolean[string] mons) {
   if (count(mons) == 0) return;
}
  
void makepage() {
   page.append("<html><head>\n<title>Factroid!: The Game</title>\n");
   page.append("<script src=\"jquery1.10.1.min.js\"></script>\n<script src=\"clilinks.js\"></script>\n");
   page.append("<script src=\"factroid.js\"></script>\n");
   if (svn_exists("omniquest")) page.append("<script>cancan = 'cango.ash';</script>\n");
    else if (svn_exists("therazekolmafia-canadv")) page.append("<script>cancan = 'canadv.ash';</script>\n");  // tell jQuery which script to Ajax to
   page.append("<link href='/images/styles.20130904.css' type='text/css' rel='stylesheet'/>\n");
   page.append("<link href='batman.css' type='text/css' rel='stylesheet'/>\n</head>\n<body>\n");
   page.append("<h3>Factroid! Collect All "+rnum(count($monsters[])+count(notmonsters))+"</h3>");
   boolean pop;
   location[int] sortl;
   foreach l in $locations[] sortl[count(sortl)] = l;
   sort sortl by value.zone;
   foreach i,l in sortl {
      if (count(get_monsters(l)) == 0) continue;
      if ($locations[Grim Grimacite Site, The Cannon Museum, CRIMBCO cubicles, Atomic Crimbo Toy Factory, 
         Old Crimbo Town Toy Factory, Simple Tool-Making Cave, Spooky Fright Factory, Crimborg Collective Factory] contains l) {
         foreach i,m in get_monsters(l) considered[m] = true;
         continue;
      }
      pop = false;
      foreach m,r in appearance_rates(l) {
         considered[m] = true;
         if (m == $monster[none] || r < 0 || blocked(m) || fs[m.to_string()] == 3) continue;
         if (!pop) {
            page.append("<div class='monbox'><div class='monheader'>"+l+" <span class='unloaded' data-location=\""+l+"\" data-url='"+to_url(l)+
               "'><img src='/images/otherimages/spacer.gif' width=17 height=17></span></div>");  // spacer to prevent craziness as locations load
            pop = true;
         }
         write_monster(m,r);
      }
      page.append("</div>\n");
   }
   page.append("\n<div class='monbox'><div class='monheader'>Not Monsters?</div>");
   foreach s in notmonsters if (fs[s] < 3) write_notmonster(s);
   page.append("</div>\n<div class='monbox'><div class='monheader'>Orphans</div>");
   foreach m in $monsters[] if (!(considered contains m) && !blocked(m) && fs[m.to_string()] < 3) write_monster(m,0);
   page.append("</div>\n<center><p style='clear: both; text-align: center'><form action='relay_Factroid.ash' method=post><input type=hidden name=do value=refresh>"+
      "<input class=button type=submit value='Refresh Manuel Data'></form> <small>Last refreshed "+fs["lastchecked"]+"</small></center>\n</body></html>");
   page.write();
}

makepage();
