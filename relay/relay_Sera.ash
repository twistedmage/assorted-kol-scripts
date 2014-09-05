// SeRa by Zarqon
// Semirare helper table
import <cango.ash>

buffer page;
record quesera {
   string yield;      // stringlist of all items yielded
   string note;       // extra infos
   string category;   // edibles, elements, ascension, fight, buff, combat items
   boolean ascend;    // is important for ascending
};
quesera[location] seras;
quesera[string, location] sorted;
if (!file_to_map("semirares.txt",seras)) vprint("Unable to load semirare info.",0);   // load and sort
foreach l,rec in seras {
   if (!can_adv(l,false) || (get_property("lastSemirareReset").to_int() == my_ascensions() && l == to_location(get_property("semirareLocation"))) || 
       (l == $location[twin peak] && get_property("twinPeakProgress") == "15")) rec.category = "unavailable";
   sorted[(rec.category == "" ? "uncategorized" : rec.category),l] = rec;
}
boolean relevant(location l) {
   if (get_property("questL13Final") == "finished") return false;  // you've completed your run
   switch (l) {
      case $location[Cobb's Knob Harem]: if (item_amount($item[scented massage oil]) > 0) return false; break;
      case $location[The Castle in the Clouds in the Sky (Top Floor)]: if (item_amount($item[Mick's IcyVapoHotness Inhaler]) > 1 || 
         get_property("sidequestNunsCompleted") != "none") return false; break;
      case $location[The Haunted Billiards Room]: if (get_property("poolSharkCount").to_int() > 24) return false; break;
      case $location[The Haunted Pantry]: return can_eat();
      case $location[The Hidden Temple]: if (item_amount($item[stone wool]) > 0 || can_adv($location[the hidden park],false)) return false; break;
      case $location[The Limerick Dungeon]: if (item_amount($item[cyclops eyedrops]) > 1) return false; break;
      case $location[The Outskirts of Cobb's Knob]: return can_eat() && can_drink();
      case $location[The Sleazy Back Alley]: return can_drink();
      default: print("No logic exists for "+l);
   }
   return true;  // defaults to true
}
page.append("<html><head>\n<title>SeRa</title>\n");
page.append("<script src=\"jquery1.10.1.min.js\"></script>\n<script src=\"clilinks.js\"></script>\n");
page.append("<link href='/images/styles.20120512.css' type='text/css' rel='stylesheet'/>\n");
page.append("<link href='batman.css' type='text/css' rel='stylesheet'/>\n");
page.append("</head>\n<body><center><table>\n<tr><td><span style='font-size: 2.5em; line-height: 0.5'>Sera</span></td>");
page.append("<td td style='text-align: right; vertical-align:middle; font-size: 0.8em' colspan=2> ");
if (get_counters("Semirare",0,200) != "") page.append(" <a href=# class='clilink'>eat fortune cookie</a>");
 else if (get_counters("Fortune Cookie",0,0) != "") page.append("<b>It's time!</b>");
 else for i from 1 to 200 if (get_counters("Fortune Cookie",i,i) == "") {
    if (i < 11) page.append(i+" . ");
 } else { page.append((i > 11 ? " ... " : "")+"<big><b>"+i+"</b></big>"); break; }
page.append("<img style='vertical-align: middle' src='images/itemimages/fortune.gif' title='Nom Nom Nom'></td></tr>");

string cref; item i;
matcher ym = create_matcher("(.+?) ?(?:\\((\\d+)\\))?(?:$|, )","");
int[location] maddprofitz;
foreach c,l,rec in sorted {
   if (c != cref) { cref = c; page.append("<tr><th colspan=3 style='padding: 3px; color: white; background-color: #444'>"+c+"</td></tr>\n"); }
   page.append("<tr"+(c == "unavailable" ? " class=dimmed" : "")+"><td style='padding-left: 30px'><a href='"+to_url(l)+"&confirm0=on'>"+
      (rec.ascend && relevant(l) ? "<span style='color: blue; font-weight: bold'>"+l+"</span>" : l)+"</a></td><td style='text-align: center'>");
   ym.reset(rec.yield);
   while (ym.find()) {
      i = to_item(ym.group(1));
      if (i == $item[none]) { page.append(ym.group(1)); continue; }
      page.append("<a href=# class='cliimglink' title=\"wiki "+i+"\"><img src='/images/itemimages/"+i.image+
         "' title=\""+i+" (have: "+rnum(have_item(i))+")\"></a> ");
      if (is_integer(ym.group(2))) page.append(" ("+ym.group(2)+") ");
      if (c != "unavailable") maddprofitz[l] += sell_val(i,3)*max(1,to_int(ym.group(2)));
   }
   if (rec.note != "") {
      element boron; if (c == "element") foreach e in $elements[] if (contains_text(rec.note,to_string(e))) boron = e;
      page.append("<br><span style='font-size: 0.7em'"+(boron == $element[none] ? "" : " class='"+boron+"'")+">"+rec.note+"</span>");
   }
   page.append("</td><td style='text-align: right; font-size: 0.8em; color: green'>"+(c == "unavailable" ? "--" : rnum(maddprofitz[l]))+"</td></tr>");
}

page.append("</table>\n<p align=center><a href='sendmessage.php?toid=1406236' title='Find this useful? Send me a batbit!'><img src='images/adventureimages/stabbats.gif'");
page.append(" border=0 height=60 width=60></a><br><small>Question? Ask <a href='http://kolmafia.us/showthread.php?t=13293' target='_blank'>here</a>.</small>");
page.write();
