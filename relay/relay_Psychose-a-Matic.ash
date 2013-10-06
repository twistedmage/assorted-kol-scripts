/******************************************************************************
                               Psychose-a-Matic
                  A helpful counselor for all your psychoses
*******************************************************************************

   Inquiries?  Insights?  Ingebretzens?  Visit
   http://kolmafia.us/showthread.php?t=13293
   for documentation or to post a suggestion/bug report.

   Want to say thanks?  Send me a bat! (Or bat-related item)

******************************************************************************/
script "Psychose-a-Matic.ash";
notify Zarqon;
import <zlib.ash>
string[string] post = form_fields();
foreach k,v in post switch (k) {
   case "used": if (get_property("_psychoJarUsed") == "false") set_property("_psychoJarUsed","true"); break;
   case "getjar": if (to_int(v) < 5898 || to_int(v) > 5905) continue; item wj = to_item(to_int(v));
      switch (wj) {
         case $item[jar of psychoses (The Suspicious-Looking Guy)]: visit_url("tavern.php?action=jung&whichperson=susguy"); break;
         case $item[jar of psychoses (The Captain of the Gourd)]: visit_url("town_right.php?action=jung&whichperson=gourdcaptain"); break;
         case $item[jar of psychoses (The Crackpot Mystic)]: visit_url("shop.php?whichshop=mystic&action=jung&whichperson=mystic"); break;
         case $item[jar of psychoses (The Old Man)]: visit_url("oldman.php?action=jung&whichperson=oldman"); break;
         case $item[jar of psychoses (The Pretentious Artist)]: visit_url("town_wrong.php?action=jung&whichperson=artist"); break;
         case $item[jar of psychoses (The Meatsmith)]: visit_url("store.php?whichstore=s&action=jung&whichperson=meatsmith"); break;
         case $item[jar of psychoses (Jick)]: visit_url("showplayer.php?who=1&action=jung&whichperson=jick"); break;
      }
}
if (get_property("_jickJarAvailable") == "unknown") visit_url("showplayer.php?who=1");
boolean havejar = item_amount($item[psychoanalytic jar]) > 0;
boolean fetchable(item j) {
   if (!havejar) return false;
   switch (j) {
      case $item[jar of psychoses (The Suspicious-Looking Guy)]: return (my_level() > 2);
      case $item[jar of psychoses (The Crackpot Mystic)]: return (available_amount($item[continuum transfunctioner]) > 0);
      case $item[jar of psychoses (The Old Man)]: return (my_level() > 10);
      case $item[jar of psychoses (Jick)]: return (get_property("_jickJarAvailable") == "true" && get_property("_psychoJarFilled") == "false"); 
   } return true;
}
boolean[item] rewards(item j) { switch (j) {
   case $item[jar of psychoses (The Suspicious-Looking Guy)]: return $items[white dragon fang, suspicious-looking fedora];
   case $item[jar of psychoses (The Captain of the Gourd)]: return $items[truthsayer, fancy gourd potion];
   case $item[jar of psychoses (The Crackpot Mystic)]: return $items[byte, anger blaster, doubt cannon, fear condenser, regret hose];
   case $item[jar of psychoses (The Old Man)]: return $items[bloodbath, ornamental sextant, foam commodore's hat, foam naval trousers, miniature deck cannon];
   case $item[jar of psychoses (The Pretentious Artist)]: return $items[ginsu&trade;];
   case $item[jar of psychoses (The Meatsmith)]: return $items[meatcleaver];
   case $item[jar of psychoses (Jick)]: return $items[sword of procedural generation];
  } boolean[item] blank; return blank;
}
string randquote() {
   switch (random(34)) {
      case 0: return "Roses are red, violets are blue, I'm schizophrenic, and so am I. -Oscar Levant";
      case 1: return "Let's talk about your mother, and how fat she is.";
      case 2: return "Anyone who goes to a psychiatrist should have his head examined. -Samuel Goldwyn";
      case 3: return "Psychiatry enables us to correct our faults by confessing our parents shortcomings. -Laurence Peter";
      case 4: return "A psychotic is a guy who's just found out what's going on. -William S. Burroughs";
      case 5: return "How does this script make you feel?";
      case 6: return "One should only see a psychiatrist out of boredom. -Muriel Spark";
      case 7: return "I'm not psycho... I just like psychotic things. -Gerard Way";
      case 8: return "The road to creativity passes so close to the madhouse and often detours or ends there. -Ernest Becker";
      case 9: return "We are all born mad. Some remain so. -Samuel Beckett";
      case 10: return "When we remember that we are all mad, the mysteries disappear and life stands explained. -Mark Twain";
      case 11: return "It is sometimes an appropriate response to reality to go insane. -Philip K. Dick";
      case 12: return "Perhaps a lunatic was simply a minority of one. -George Orwell";
      case 13: return "We're all a little wacko sometimes, and if we think we're not, maybe we are more than we know. -Mariah Carey";
      case 14: return "The sanity of society is a balance of a thousand insanities. -Emerson";
      case 15: return "Insanity is relative. It depends on who has who locked in what cage. -Ray Bradbury";
      case 16: return "If you think you've gone insane ... you're nuts. -Stephen King";
      case 17: return "Being crazy isn't enough. -Dr. Suess";
      case 18: return "Sane is boring. -R.A. Salvatore";
	  case 19: return "You're just batshit insane sometimes. In a good way. -Bale, to Zarqon";
      case 20: return "Crazy isn't being broken or swallowing a dark secret. It's you or me amplified. -Susanna Kaysen";
      case 21: return "When you are crazy you learn to keep quiet. -Philip K. Dick";
      case 22: return "I would imagine that if you could understand Morse code, a tap dancer would drive you crazy. -Mitch Hedberg";
      case 23: return "Those who are crazy enough to think they can change the world usually do. -Steve Jobs";
	  case 24: return "Slowly going insane is the best kind of insane! -slyz";
	  case 25: return "Never mind me, I'm crazy. -heeheehee";
	  case 26: return "A drink a day keeps the shrink away. -Edward Abbey";
      case 27: return "So many people drive me crazy. Little do they know I enjoy the trip. -Fluxxdog";
	  case 28: return "I have been certified as sane. This brings up the question of the tester's sanity. -Fluxxdog";
	  case 29: return "I don't get lost in my thoughts. I just don't use a map. -Fluxxdog";
	  case 30: return "People worry when I talk to myself. I tell them they should worry when I'm quiet. -Fluxxdog";
	  case 31: return "I don't know what it is that CHEESEBURGER LLAMA FUTON makes people think there's a problem with me. -Fluxxdog";
   } return "Bats.  Bats bats, bats.  BAAAATTTTTTSSSS";
}
buffer page;
page.append("<html><head>\n<title>Psychose-a-Matic</title>\n");
page.append("<script src=\"jquery1.10.1.min.js\"></script>\n<script src=\"clilinks.js\"></script>\n");
page.append("<link href='/images/styles.20120512.css' type='text/css' rel='stylesheet'/>\n");
page.append("<style type=\"text/css\">img { vertical-align: middle } .dim { opacity: 0.4; filter: alpha(opacity=40); }</style></head>\n<body>");
page.append("<div style='float:left'><h2>Psychose-a-Matic</h2> <small><i>"+randquote()+"</i></small><p>"+
   "<a href=# class='cliimglink' title='wiki psychoanalytic jar'><img src='/images/itemimages/analjar_empty.gif' title='psychoanalytic jar'></a>: <b>"+item_amount($item[psychoanalytic jar])+"</b></div>");
// display current jar, if jar there be
if (get_property("_psychoJarUsed") == "true") {
   matcher gatenum = create_matcher("junggate_(\\d)",visit_url("campground.php"));
   if (gatenum.find()) {
      matcher jarbit = create_matcher("<center><div(.+)</div>",visit_url("place.php?whichplace=junggate_"+gatenum.group(1)));
	  if (jarbit.find()) page.append("<p align=center><table><tr><td>"+jarbit.group(0)+"</center></td></tr></table>");
   }
}
// table of handiness
page.append("<p align=center style='clear:both'><table cellpadding=2><tr><th>Jar</th><th>Amount</th><th>Acquire</th><th>Rewards</th></tr>");
item jar;
for i from 5898 upto 5905 {
   jar = to_item(i);
   if (jar == $item[none]) continue;
   page.append("\n  <tr><td><a href=# class='cliimglink' title='wiki "+jar+"'><img src='/images/itemimages/"+jar.image+"' title='"+jar+"'></a> <b>"+
      to_string(jar).replace_string("Jick","<a href=showplayer.php?who=1 title='view Jick with your own eyes, you Doubting Thomas you'>Jick</a>")+"</b>"+
      (item_amount(jar) > 0 && get_property("_psychoJarUsed") == "false" ? " <a href=relay_Psychose-a-Matic.ash?used=yes class='clilink through' title='use 1 "+jar+"'>use</a>" : ""));
   page.append("</td><td align=center><b>"+item_amount(jar)+"</b></td><td align=center>");
   page.append(fetchable(jar) ? "<form name='getjar"+i+"' action='relay_Psychose-a-Matic.ash'><input type=hidden name=getjar value="+i+"><input class=button type=submit value='Fill a jar'></form>" : 
      "<span style='color: "+(my_meat() >= mall_val(jar,3) ? "green" : "red")+"'>"+rnum(mall_val(jar,3))+"&mu;</span> "+(can_interact() ? "<a href=relay_Psychose-a-Matic.ash class='clilink through' title='buy 1 "+jar+"'>buy</a>" : "N/A"));
   page.append("</td><td>");
   foreach i in rewards(jar) page.append("<a href=# class='cliimglink' title=\"wiki "+i+"\"><img src='/images/itemimages/"+i.image+"' title=\""+i+
      (available_amount(i) + storage_amount(i) + display_amount(i) + closet_amount(i) == 0 ? "\" class=\"dim" : "")+"\"></a> ");
   page.append("</td></tr>");
}
page.append("</table>\n<p align=center><a href='sendmessage.php?toid=1406236' title='Find this useful? Send me a batbit!'><img src='images/adventureimages/stabbats.gif'"+
   " border=0 height=60 width=60></a><br><small>Question? Ask <a href='http://kolmafia.us/showthread.php?t=13293' target='_blank'>here</a>.</small>");
page.write();
check_version("Psychose-a-Matic","psychoseamatic",13293);