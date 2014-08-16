// SeRa by Zarqon
// Semirare helper table
import <cango.ash>

buffer page;
record quesera {
   string yield;      // stringlist of all items yielded
   string note;       // extra infos
   string category;   // edibles, elements, ascension, fight, buff, combat items
};
quesera[location] seras;
quesera[string, location] sorted;

if (!file_to_map("semirares.txt",seras)) vprint("Unable to load semirare info.",0);   // load and sort
foreach l,rec in seras {
   if (!can_adv(l,false) || (get_property("lastSemirareReset").to_int() == my_ascensions() && 
      l == to_location(get_property("semirareLocation")))) rec.category = "unavailable";
   sorted[(rec.category == "" ? "uncategorized" : rec.category),l] = rec;
}

page.append("<html><head>\n<title>SeRa</title>\n");
page.append("<script src=\"jquery1.10.1.min.js\"></script>\n<script src=\"clilinks.js\"></script>\n");
page.append("<link href='/images/styles.20120512.css' type='text/css' rel='stylesheet'/>\n");
page.append("<link href='batman.css' type='text/css' rel='stylesheet'/>\n");
page.append("</head>\n<body><h2>Sera</h2><table>\n");

string cref; item i;
matcher ym = create_matcher("(.+?) ?(?:\\((\\d+)\\))?(?:$|, )","");
foreach c,l,rec in sorted {
   if (c != cref) { cref = c; page.append("<tr><td colspan=2 style='padding: 3px; color: white; background-color: #444'>"+c+"</td></tr>\n"); }
   page.append("<tr"+(c == "unavailable" ? " class=dimmed" : "")+
      "><td style='padding-left: 30px'><a href='"+to_url(l)+"&confirm0=on'>"+l+"</a></td><td style='text-align: center'>");
   ym.reset(rec.yield);
   while (ym.find()) {
      i = to_item(ym.group(1));
      if (i == $item[none]) { vprint("'"+ym.group(1)+"' is not an item.",-2); page.append(ym.group(1)); continue; }
      page.append("<a href=# class='cliimglink' title=\"wiki "+i+"\"><img src='/images/itemimages/"+i.image+
         "' title=\""+i+" (have: "+rnum(have_item(i))+")\"></a> ");
      if (is_integer(ym.group(2))) page.append(" ("+ym.group(2)+") ");
   }
   if (rec.note != "") {
      element boron; if (c == "element") foreach e in $elements[] if (contains_text(rec.note,to_string(e))) boron = e;
      page.append("<br><span style='font-size: 0.7em'"+(boron == $element[none] ? "" : " class='"+boron+"'")+">"+rec.note+"</span>");
   }
   page.append("</td></tr>");
}

page.append("</table>\n<p align=center><a href='sendmessage.php?toid=1406236' title='Find this useful? Send me a batbit!'><img src='images/adventureimages/stabbats.gif'");
page.append(" border=0 height=60 width=60></a><br><small>Question? Ask <a href='http://kolmafia.us/showthread.php?t=13293' target='_blank'>here</a>.</small>");
page.write();
