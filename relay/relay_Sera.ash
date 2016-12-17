// SeRa by Zarqon
// Semirare helper table
import <zlib.ash>

buffer page;
record quesera {
   string yield;      // stringlist of all items yielded
   string note;       // extra infos
   string category;   // edibles, elements, quest, fight, buff, combat items
   boolean ascend;    // is important for ascending
};
quesera[location] seras;
quesera[string, location] sorted;
if (!file_to_map("semirares.txt",seras)) vprint("Unable to load semirare info.",0);   // load and sort
foreach l,rec in seras sorted[(rec.category == "" ? "uncategorized" : rec.category),l] = rec;

boolean avail(location l) {
   switch (l) {
      case $location[twin peak]: if (get_property("twinPeakProgress") == "15") return false; break;
      case to_location(get_property("semirareLocation")): if (get_property("lastSemirareReset").to_int() == my_ascensions()) return false; break;
   } return true;
}
boolean relevant(location l) {
   if (get_property("questL13Final") == "finished") return false;  // you've completed your run
   switch (l) {
      case $location[A Mob of Zeppelin Protesters]: if (get_property("zeppelinProtestors").to_int() >= 80) return false; break;
      case $location[Cobb's Knob Harem]: if (my_class() == $class[ed] || item_amount($item[scented massage oil]) > 0) return false; break;
      case $location[Cobb's Knob Menagerie, Level 2]: if ($strings[Avatar of Boris, Avatar of Jarlsberg, Avatar of Sneaky Pete] contains my_path()) return false; break;
      case $location[The Castle in the Clouds in the Sky (Top Floor)]: if (item_amount($item[Mick's IcyVapoHotness Inhaler]) > 1 || 
         get_property("sidequestNunsCompleted") != "none") return false; break;
      case $location[The Copperhead Club]: if (item_amount($item[Flamin' Whatshisname]) > 0 || get_property("zeppelinProtestors").to_int() >= 80) return false; break;
      case $location[The Haunted Billiards Room]: if (get_property("poolSharkCount").to_int() > 24) return false; break;
      case $location[The Haunted Pantry]: return can_eat() && be_good($item[tasty tart]);
      case $location[The Hidden Temple]: if (item_amount($item[stone wool]) > 0 || !($strings[unstarted,started,step1,step2] contains get_property("questL11Worship"))) return false; break;
      case $location[The Limerick Dungeon]: if (item_amount($item[cyclops eyedrops]) > 1) return false; break;
      case $location[The Outskirts of Cobb's Knob]: return can_eat() && can_drink() && my_path() != "Bees Hate You";
      case $location[The Sleazy Back Alley]: return can_drink() && be_good($item[distilled fortified wine]);
      default: print("No logic exists for "+l);
   }
   return true;  // defaults to true
}
page.append("<html><head>\n<title>SeRa</title>\n");
page.append("<script src=\"jquery1.10.1.min.js\"></script>\n<script src=\"clilinks.js\"></script>\n");
page.append("<script>jQuery(function($){ var cancan; ");
if (svn_exists("omniquest")) page.append("cancan = 'cango.ash'; ");
 else if (svn_exists("therazekolmafia-canadv")) page.append("cancan = 'canadv.ash'; ");
page.append("if (cancan) $(window).on('DOMContentLoaded load resize scroll', function(e) {"+
"$('.unloaded').each(function(id) { var r = this.getBoundingClientRect(); if (r.top >= 0 && r.top <= (window.innerHeight || "+
"document.documentElement.clientHeight)) { var caller = $(this); caller.removeClass('unloaded'); $.post(cancan, { where: caller.text(), verb: '9' },"+
" function(data) { if (data == 'available') return false; caller.html(caller.data('location')); "+
"caller.closest('tr').addClass('dimmed').slideUp(400).addClass('unavail'); }); } }); $('#showall').change(function() { "+
"if ($('#showall').is(':checked')) $('.unavail').show(400); else $('.unavail').hide(400); return false; }); }); $('#jaemok').hover(function() { "+
"$('.gimm').show(400); }, function() { $('.gimm').hide(400); }); });</script>");
page.append("<link href='/images/styles.20120512.css' type='text/css' rel='stylesheet'/>\n");
page.append("<link href='batman.css' type='text/css' rel='stylesheet'/>\n");
page.append("</head>\n<body><center><table>\n<tr><td><span id=jaemok style='font-size: 2.5em; line-height: 0.5'>");
page.append("Se<span class=gimm>mi-</span>ra<span class=gimm>re Helper</span></span></td>");
page.append("<td td style='text-align: right; vertical-align:middle; font-size: 0.8em' colspan=2> ");
page.append("<input type='checkbox' id='showall' name='expand'> <small><label for='showall'>Show Unavailable</label></small><br>");
if (get_counters("Semirare",0,200) != "") {
   page.append(can_eat() && my_fullness() < fullness_limit() && be_good($item[fortune cookie]) ? 
      "<a href=relay_Sera.ash class='clilink through'>eatsilent fortune cookie</a>" : "unable to eat ");
} else if (get_counters("Fortune Cookie",0,0) != "") page.append("<b>It's time!</b>");
 else for i from 1 to 200 if (get_counters("Fortune Cookie",i,i) == "") {
    if (i <= 11) page.append(i+" . ");
 } else { page.append((i > 11 ? " ... " : "")+"<big><b>"+i+"</b></big>"); break; }
page.append("<img style='vertical-align: middle' src='images/itemimages/fortune.gif' title='Nom Nom Nom'></td></tr>");

string cref; item i;
matcher ym = create_matcher("(.+?) ?(?:\\((\\d+)\\))?(?:$|, )","");
int[location] maddprofitz;
int[int] fs;
file_to_map("factoids_"+replace_string(my_name()," ","_")+".txt",fs);  // factoids info
foreach c,l,rec in sorted {
   if (c != cref) { cref = c; page.append("\n<tr><th colspan=3 style='padding: 3px; color: white; background-color: #444'>"+c+"</td></tr>\n"); }
   page.append("<tr"+(avail(l) ? "" : " class='dimmed unavail'")+"><td style='padding-left: 30px'><span data-location=\""+l+"\" class=unloaded"+
      (rec.ascend && relevant(l) ? " style='font-weight: bold'>" : ">")+"<a href='"+to_url(l)+"&confirm0=on'>"+
      l+"</a></span></td><td style='text-align: center'>");
   ym.reset(rec.yield);
   while (ym.find()) {
      i = to_item(ym.group(1));
      if (i == $item[none]) { page.append(ym.group(1)); continue; }
      page.append("<a href=# class='cliimglink' title=\"wiki "+i+"\"><img src='/images/itemimages/"+i.smallimage+
         "' title=\""+i+" (have: "+rnum(have_item(i))+")\"></a> ");
      if (is_integer(ym.group(2))) page.append(" ("+ym.group(2)+") ");
      if (c != "unavailable") maddprofitz[l] += sell_val(i,3)*max(1,to_int(ym.group(2)));
   }

   if (rec.note != "") {
      element boron; if (c == "element") foreach e in $elements[] if (contains_text(rec.note,to_string(e))) boron = e;
      if (c == "fight" && rec.note.to_monster().id > 0) {
         page.append("<br>");
         for i from 1 to 3 page.append(i > fs[to_monster(rec.note).id] ? " <span class='dimmed'>&bull;</span> " : " <big>&bull;</big> ");
      }
      page.append("<br><span style='font-size: 0.7em'"+(boron == $element[none] ? "" : " class='"+boron+"'")+">"+rec.note+"</span>");
   }
   page.append("</td><td style='text-align: right; font-size: 0.8em; color: green'>"+(c == "unavailable" ? "--" : rnum(maddprofitz[l])+"&mu;")+"</td></tr>");
}

page.append("</table>\n<p align=center><a href='sendmessage.php?toid=1406236' title='Find this useful? Send me a batbit!'><img src='images/adventureimages/stabbats.gif'");
page.append(" border=0 height=60 width=60></a><br><small>Question? Ask <a href='http://kolmafia.us/showthread.php?10042' target='_blank'>here</a>.</small>");
page.write();
