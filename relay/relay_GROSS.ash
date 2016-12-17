// Club GROSS (Get Rid of Slimy sealS)
// by Zarqon
// Seal Clubber seal slubbing assistance
import <zlib.ash>

int[item] ingred(item fig) {  // extra items required to use a given figurine
   int[item] res;
   switch (fig) {
      case $item[figurine of an armored seal]: res[$item[seal-blubber candle]] = 5;
      case $item[figurine of a cute baby seal]: res[$item[seal-blubber candle]] += 2;
      case $item[figurine of an ancient seal]: res[$item[seal-blubber candle]] += 2;
      case $item[figurine of a wretched-looking seal]: res[$item[seal-blubber candle]] += 1; break;
      default: res[$item[imbued seal-blubber candle]] = 1; break;
   } return res;
}
boolean have_ingred(item fig) { foreach ing,num in ingred(fig) if (item_amount(ing) < num) return false; return true; }
boolean get_ingred(item fig) { foreach ing,num in ingred(fig) if (!retrieve_item(num,ing)) return false; return true; }
boolean clubbin = item_type(equipped_item($slot[weapon])) == "club";
int summons;
string success() {
  if (item_type(equipped_item($slot[off-hand])) == "club") return "Club sandwich!  Haha!";
  switch (random(21)) {
     case 0: return "You clubbed a baby seal to make a better deal!  You're crazy!";
     case 1: return "You clubbed the carp out of that seal!";
     case 2: return "The seal's face has joined the club!";
     case 3: return "Fore!";
     case 4: return "You return the club to your caddy as he congratulates you.";
     case 5: return "You wish you had a club foot so you could have clubbed him even harder.";
     case 6: return "You return home alone from your time out clubbing.  Success!";
     case 7: return "Clubbing success!";
     case 8: return "You sealed the deal!";
     case 9: return "Club. Club club club.  It looks weird now.  Club.";
     case 10: return "Success!  Afterwards, you place the seal between crackers and jab a toothpick through him.  More success!";
     case 11: return "Promotion unlocked: Club Secretary General!";
     case 12: return "Promotion unlocked: First Tiger!";
     case 13: return "Promotion unlocked: Top Scout!";
     case 14: return "Promotion unlocked: Court Stenographer!";
     case 15: return "Promotion unlocked: Dictator-for-Life!";
     case 17: return "Tigers are mean! Tigers are fierce! Tigers have teeth and claws that pierce!";
     case 18: return "Tigers are great! They can't be beat! If I was a tiger, that would be neat!";
     case 19: return "Tigers are nimble and light on their toes. My REspect for tigers continually grows.";
     case 20: return "Tigers are great! They're the toast of the town. Life's always better when a tiger's around!";
  } return "";
}
string message; boolean redgreen;
string[string] post = form_fields();
if (!clubbin) message = "You can't join the club without a club.";
 else if (post contains "clubseal") {
    item figgy = to_item(to_int(post["clubseal"]));
    if (!retrieve_item(1,figgy)) message = "Unable to acquire figurine.";
     else if (!get_ingred(figgy)) message = "Unable to acquire material component.";
     else if (!use(1,figgy)) message = "Seal unsuccessfully clubbed.";
     else {
        redgreen = true;
        message = success();
        if (item_amount($item[powdered sealbone]) > 0 && item_amount($item[imbued seal-blubber candle]) == 0) 
           retrieve_item(1,$item[imbued seal-blubber candle]);
     }
 }
if (my_class() == $class[seal clubber]) summons = 5 + to_int(have_item($item[claw of the infernal seal]) > 0)*5 - to_int(get_property("_sealsSummoned"));

buffer page;
page.append("<html><head>\n<title>GROSS</title>\n");
page.append("<script src=\"jquery1.10.1.min.js\"></script>\n<script src=\"clilinks.js\"></script>\n");
page.append("<script>jQuery(function($){ $('#jaemok').hover(function() { "+
"$('.gimm').show(400); }, function() { $('.gimm').hide(400); }); });</script>");
page.append("<link href='/images/styles.20120512.css' type='text/css' rel='stylesheet'/>\n");
page.append("<link href='batman.css' type='text/css' rel='stylesheet'/>\n");
page.append("</head>\n<body><center><table cellpadding=6px>\n<tr><td style='text-align: center' colspan="+(5 + to_int(clubbin && summons > 0))+">");
if (my_class() == $class[seal clubber]) page.append("<img src='/images/clubgross.jpg' style='height:153px;width:150px;' title='Welcome to top secret Club G.R.O.S.S.'><br>");
page.append("<span id=jaemok style='font-size: 2.5em; line-height: 0.5'>");
page.append("G<span class=gimm>et </span>R<span class=gimm>id </span>O<span class=gimm>f </span>S<span class=gimm>limy seal</span>S</span>");
page.append("<p>Summons Remaining: <b>"+rnum(summons)+"</b></td></tr>");
if (my_class() != $class[seal clubber]) {
   page.append("<tr><td colspan=5 style='font-size: 1.1em; color: red; border: 2px solid red;'>KEEP OUT<p>No sissy non-Seal-Clubbers allowed!</td></tr><table>");
   page.append("<p><img src='/images/greatclub.jpg'></td></tr>");
   page.write();
   exit;
}
if (message != "") page.append("<tr><td colspan="+(5 + to_int(clubbin))+" style='font-size: 1.1em; color: "+(redgreen ? "green" : "red")+"; border: 2px solid "+
   (redgreen ? "green" : "red")+";'>"+message+"</td></tr>");

page.append("<tr><th><span title='Material Component'>M</span></th><th>Figurine</th><th>Location</th><th>Seal</th><th>Drops</th>"+
   (clubbin && summons > 0 ? "<th>Club</th>" : "")+"</tr>");

int[int] fs;
file_to_map("factoids_"+replace_string(my_name()," ","_")+".txt",fs);  // factoids info
record seal_item {
   location odi;       // location to obtain the figurine (if obtained through adventuring)
   monster whichseal;  // the seal summoned by using the figurine
};
seal_item[item] seals;
file_to_map("seals.txt",seals);
if (count(seals) == 0) vprint("Problem loading seals.txt -- probably it doesn't exist.",0);

foreach fig,rec in seals {
   page.append("<tr><td style='text-align: center'>");
   foreach it,n in ingred(fig) {
      page.append("<a href='relay_GROSS.ash' class='cliimglink through' title='"+(item_amount(it) < n ? "acquire "+n : "wiki")+" "+it+"'>");
      page.append("<img "+(item_amount(it) < n ? "class='dimmed' " : "")+"src='/images/itemimages/"+it.image+"'></a>");
      page.append("<br><small><b>"+rnum(item_amount(it))+" / "+n+"</b></small>");
   }
   page.append("</td><td style='text-align: center'><a href='relay_GROSS.ash' class='cliimglink through"+
      (item_amount(fig) == 0 ? " dimmed' title='acquire 1 " : "' title='wiki ")+fig+"'><img src='/images/itemimages/"+
      fig.image+"' class=hand></a><br><small><b>"+rnum(item_amount(fig)));
   page.append("</b></small></td><td style='text-align: center'>");
   if (rec.odi != $location[none]) page.append("<a href='"+to_url(rec.odi)+"' class='clilink through' title='conditions clear; conditions add 1 "+fig+"'>"+rec.odi+"</a>");
   page.append("</td><td style='text-align: center'>");
   if (rec.whichseal == $monster[none]) page.append("<img src='/images/adventureimages/question.gif' style='height:40px;width:40px;' title='Club a random Greater Seal'>");
    else { page.append("<a href=# class='cliimglink' title='wiki "+rec.whichseal+
       "'><img src='/images/adventureimages/"+rec.whichseal.image+"' style='height:40px;width:40px;' title='"+rec.whichseal+"' class=hand></a><br><small>A: "+
       monster_attack(rec.whichseal)+", D: "+monster_defense(rec.whichseal)+"</small><br>");
     for i from 1 to 3 page.append(i > fs[rec.whichseal.id] ? " <span class='dimmed'>&bull;</span> " : " <big>&bull;</big> ");
    }
   page.append("</td><td>");
   foreach lootz in item_drops(rec.whichseal) page.append("<div style='text-align: center; float: left'><a href=# class='cliimglink"+(item_amount(lootz) == 0 ? " dimmed" : "")+
      "' title=\"wiki "+lootz+"\"><img src='/images/itemimages/"+lootz.image+"' class=hand></a><br><small><b>"+rnum(item_amount(lootz))+"</b></small></div>");
   page.append("</td>");
   if (clubbin && summons > 0) {
      page.append("<td><small>");
      if (!have_ingred(fig) && ingred(fig) contains $item[imbued seal-blubber candle]) page.append("No material component.");
       else if (item_amount(fig) == 0 && ingred(fig) contains $item[imbued seal-blubber candle]) page.append("No figurine.");
       else page.append("<form action='relay_GROSS.ash'><input type=hidden name=clubseal value="+
          to_int(fig)+"><input class=button type=submit value='Club it!' title='"+(fig == $item[figurine of an ancient seal] ? "Note: will auto-craft imbued candle." : "Club it, cracka.")+"'></form>");
      page.append("</small></td>");
   }
   page.append("</td><td>");   
   
   page.append("</tr>");
}

page.append("</table>\n<p align=center><a href='sendmessage.php?toid=1406236' title='Find this useful? Send me a batbit!'><img src='images/adventureimages/stabbats.gif'");
page.append(" border=0 height=60 width=60></a><br><small>Question? Ask <a href='http://kolmafia.us/showthread.php?10042' target='_blank'>here</a>.</small>");
page.append("\n</body></html>");
page.write();