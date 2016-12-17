// Factroid!: Collect Them All
// by Zarqon, with thanks to turing's missingManuel.ash for a great starting point
import <zlib.ash>

int[int] fs; // indexed by monster id
file_to_map("factoids_"+replace_string(my_name()," ","_")+".txt",fs);

// monsters with unattainable or no factoids (most now handled in m.attributes)
boolean[monster] blockedmonsters = $monsters[blazing bat, The Frattlesnake];
boolean blocked(monster mon) { return (mon.id < 0 || mon.attributes.index_of("NOMANUEL") != -1 || blockedmonsters contains mon); }

// phyla-cheating stats
int[phylum] phytot;
int[phylum] phygot;
boolean cancard = item_amount($item[deck of every card]) > 0 && my_adventures() > 0 && get_property("_deckCardsDrawn").to_int() < 11;
foreach m in all_monsters_with_id() if (!blocked(m)) {
   phytot[m.phylum] += 1;
   if (fs[m.id] >= 3) phygot[m.phylum] += 1;
}
static {
   boolean havemanuel;
   string whohasmanuel;
}
void detectmanuel() {
   havemanuel = visit_url("questlog.php").contains_text("questlog.php?which=6");
   whohasmanuel = my_name();
}
if (whohasmanuel != my_name()) detectmanuel();

void parseman() {
   if (!havemanuel) return;
   void onepage(string char) {
      string page = visit_url("questlog.php?which=6&vl="+char);
// old matcher including name and image: mon(\\d+).+?(?:adventureimages|otherimages)\\/(.+?.gif).+?rowspan.+?<font size=.2>(.+?)<\\/font><\\/b><ul><li>(.+?)<\\/ul>      
      matcher onem = create_matcher("mon(\\d+).+?<\\/font><\\/b><ul><li>(.+?)<\\/ul>", page);
      while (onem.find()) {
         int thisid = to_int(onem.group(1));                        // group 1: monster id
         string[int] facts = split_string(onem.group(2),"<li>");    // group 2: all factoids, including intermediary <li>'s
         vprint(to_monster(thisid)+" has "+count(facts)+" factoids.",10);
         fs[thisid] = count(facts);
      }
   }
   fs.clear();
   onepage("-");
   for i from 65 to 90 {
      print(entity_decode("&#"+i+";"));
      onepage(entity_decode("&#"+(i+32)+";"));
   }
   fs[-1] = now_to_string("yyyyMMdd").to_int();
   map_to_file(fs,"factoids_"+replace_string(my_name()," ","_")+".txt");
}

string[string] post = form_fields();
if (post contains "do") switch (post["do"]) {
   case "refresh": parseman(); break;
   case "foundone": if (post contains "mid") {  // provide a hook to support quick factoid tracking
      int nom = to_int(post["mid"]);
      if (nom > 0) {
         fs[nom] += 1;
         write("Factoid saved: you now have found "+fs[nom]+" factoids for "+to_monster(nom)+".");
         map_to_file(fs,"factoids_"+replace_string(my_name()," ","_")+".txt");
      } else write("Factoid unable to be saved for monster ID "+nom+".");
    } exit;
   case "deets": buffer dbox;
      monster graa = to_monster(to_int(post["mon"]));
      dbox.append("<center>\n<table class=dbox><tr><td>");
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
         dbox.append("'></td></tr>\n<tr><td colspan=2 align=center>");  // copying
         if (item_amount($item[Clan VIP Lounge key]) > 0 && get_property("_photocopyUsed") == "false" && my_adventures() > 0 &&
           !($strings[Trendy, Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete, Slow and Steady, Heavy Rains] contains my_path())) {
            if (get_property("photocopyMonster").to_monster() == graa) dbox.append("<a href='inv_use.php?pwd="+my_hash()+
               "&which=3&whichitem=4873' title='Fight your copy of this monster'><img src='images/itemimages/photocopy.gif'></a>");
             else if (can_faxbot(graa)) dbox.append("<a href=relay_Factroid.ash class='cliimglink fax' title=\""+
                (item_amount($item[photocopied monster]) > 0 ? "fax put; " : "")+"ash faxbot($monster["+graa+
                "])\"><img src='images/itemimages/copier.gif' title='Faxbot this monster'></a>");
         }
         if (my_path() == "Heavy Rains" && my_adventures() > 0 && have_skill($skill[Rain Man]) && my_rain() >= 50 && fs[graa.id] > 0) {
            dbox.append("<a href='skills.php?pwd="+my_hash()+"&action=Skillz&whichskill=16011&quantity=1' class='cliimglink through' title='For now, casts Rain Man and dumps you on the selection menu.'><img src='images/itemimages/rainman.gif' title='Rain Man this monster.'></a>");
         }
         if (cancard) {
            dbox.append("<a href=# class='cliimglink' title='cheat phylum "+graa.phylum+"'><img src='images/itemimages/deckdeck.gif' title='Cheat "+
               graa.phylum+" ("+rnum(phygot[graa.phylum])+"/"+rnum(phytot[graa.phylum])+" monsters complete in this phylum)'></a>");
         }
      }
      string char = substring(graa,0,1).to_lower_case(); if (!create_matcher("([a-zA-Z])",char).find()) char = "-";
      if (havemanuel) dbox.append("<a href=questlog.php?which=6&vl="+char+(fs[graa.id] > 0 ? "#mon"+post["mon"] : "")+" title='Manuel entries, page "+char.to_upper_case()+  // manuel link
         "'><img src='images/itemimages/monstermanuel.gif'></a>");
      dbox.append("<a href=# class='cliimglink' title=\"wiki "+graa+"\"><img "+     // wiki link
         "src='images/itemimages/necbronomicon.gif'></a>");
//      dbox.append("<br><small>"+random(100)+"</small>");
      dbox.append("</td></tr></table></center>");
      dbox.write();
      exit;
}

buffer page;
boolean[monster] considered;
if (!(fs contains -1)) parseman();

void write_monster(monster m, float r) {
   page.append("<div class='montile have"+fs[m.id]+"'><img class='hand mon' data-phylum='"+m.phylum+"' src='/images/adventureimages/"+
      (m.image == "" ? "question.gif" : m.image)+"' title=\""+m.id+": "+m+"\" style='height:40px;width:40px;'><br><div class='deets' data-monster=\""+m.id+"\"></div>");
   for i from 1 upto fs[m.id] page.append(" &bull; ");
   page.append("<br><small>"+(r == 0 ? "--" : rnum(r)+"%")+"</small></div>");
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
   page.append("<h3>Factroid! Collect All ~"+rnum(count(all_monsters_with_id())-count(blockedmonsters))+"</h3>");
   boolean pop;
  // phyla helper
   phylum[int] sortp;
   foreach p in $phyla[] sortp[count(sortp)] = p;
   sort sortp by to_float(phygot[value])/phytot[value];
   foreach n,p in sortp {
      if (phygot[p] == phytot[p]) continue;
      if (!pop) { page.append("<div class='monbox'><div class='monheader'>Phyla Helper</div>"); pop = true; }
      page.append("<div class='montile'>");
      if (cancard) page.append("<a href=# class='cliimglink' title='cheat phylum "+p+"'>");
      page.append("<img data-phylum='"+p+"' src='/images/itemimages/"+p.image+"' title='"+(cancard ? "Click to cheat "+p : p)+
         "' style='height:30px;width:30px;'>"+(cancard ? "</a>" : "")+"<br><small>"+rnum(phygot[p])+" / "+rnum(phytot[p])+"<br><small>"+
         rnum(100.0*to_float(phygot[p])/to_float(phytot[p]))+"%</small></small></div>\n");
   }
   page.append("</div>\n");
  // location boxes
   location[int] sortl;
   foreach l in $locations[] sortl[count(sortl)] = l;
   sort sortl by value.zone;
   foreach i,l in sortl {
      if (count(get_monsters(l)) == 0) continue;
      pop = false;
      foreach m,r in appearance_rates(l) {
         considered[m] = true;
         if (m == $monster[slime]) m = $monster[Slime Tube monster];
         if (m.id == 0 || r < 0 || blocked(m) || fs[m.id] == 3) continue;
         if (!pop) {
            page.append("<div class='monbox'><div class='monheader'><a href=# class=clilinknostyle title=\"wiki "+l+"\">"+l+"</a> <span class='unloaded' data-location=\""+l+"\" data-url='"+to_url(l)+
               "'><img src='/images/otherimages/spacer.gif' width=15 height=15></span></div>");  // spacer to reduce craziness as locations load
            pop = true;
         }
         write_monster(m,r);
      }
      if (pop) page.append("</div>\n");
   }
   page.append("\n<div class='monbox'><div class='monheader'>Orphans</div>");
   foreach m in all_monsters_with_id() if (!(considered contains m) && !blocked(m) && fs[m.id] < 3) write_monster(m,0);
   page.append("</div>\n<center><p style='clear: both; text-align: center'><form action='relay_Factroid.ash' method=post><input type=hidden name=do value=refresh>"+
      "<input class=button type=submit value='Refresh Manuel Data'></form> <small>Last refreshed "+fs[-1]+"</small></center>\n</body></html>");
   page.write();
}
void main() { makepage(); }