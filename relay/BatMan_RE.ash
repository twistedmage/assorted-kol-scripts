/******************************************************************************
                              BatMan Relay

               more clicking, less profit.  no wait...
                       more worry, less information.  no wait...
                                the opposite of all of that.
*******************************************************************************

   Documentation and discussion of this script is here:
   http://kolmafia.us/showthread.php?t=10042

   Feel appreciative?  Send me a bat! (Or bat-related item)

******************************************************************************/
import <SmartStasis.ash>

buffer actbox;
int[string] stundex;
int[string] stasdex;
int[string] rawlist;    // raw blacklist, as compared to BB's supplemented one
if (!file_to_map("BatMan_blacklist_"+replace_string(my_name()," ","_")+".txt",rawlist)) vprint("Error loading blacklist.",-2);
string[string] post = form_fields();
if (post contains "setml") {
   vars["unknown_ml"] = max(0,to_int(post["setml"]));
   updatevars();
} else if (post contains "black") {                         // handle blacklist
   switch (post["black"]) {
      case "add": if (post["id"] == "") break;
         rawlist[post["id"]] = max(0,to_int(post["amt"]));
         map_to_file(rawlist,"BatMan_blacklist_"+replace_string(my_name()," ","_")+".txt");
         build_blacklist();
         break;
      case "remove": if (post["id"] == "" || !(rawlist contains post["id"])) break;
         remove rawlist[post["id"]];
         map_to_file(rawlist,"BatMan_blacklist_"+replace_string(my_name()," ","_")+".txt");
         build_blacklist();
         break;
   }
   buffer bbox;
   m = last_monster();
   bbox.append("<div style='padding: 3px; float: right'><a href=# title='' class='clilink editblack'>add entry</a> "+
      "<a href='#' title='' class='clilink refreshblack'>refresh</a></div><center>"+
      "<img src='/images/itemimages/scroll1.gif' style='vertical-align:middle'> <b>Blacklist</b><br><table id='blacktable'>");
   foreach action,amt in blacklist {
      bbox.append("\n<tr><td>");
      if (rawlist contains action) bbox.append("<a href='#' class='removeblack' title='"+action+"'><img src='images/itemimages/leftarrow.gif' "+
         "height='15' width='15' title='Remove this blacklist entry.' border=0></a>");
      bbox.append("</td><td style='text-align: left'><form name='blacklist_"+action+"' style='display: inline' action=fight.php "+
         "method=post><input type=hidden name=action value='macro'><input type='hidden' name='macrotext' value='"+batround()+action+
         "'><input type=submit title='"+action+"' class='buttlink");
      switch {
         case (contains_text(action,"use ") && !contains_text(action,";")): item blbl = to_item(excise(action,"use ",""));
               bbox.append(" item' value=\""+blbl+" ("+item_amount(blbl)+")\""); break;
         case (contains_text(action,"skill ") && !contains_text(action,";")): bbox.append(" skill' value=\""+to_skill(to_int(excise(action,"skill ","")))+"\""); break;
         case (action == "attack"): bbox.append("' value='Attack with weapon'"); break;
         case (action == "jiggle"): bbox.append("' value='Jiggle your chefstaff'"); break;
         case (action == "pickpocket"): bbox.append("' value='Steal'"); break;
         default: bbox.append("' value='"+action+"'"); break;
      }
      bbox.append(" onclick='return bjilgt(this);'></form></td><td style='text-align: right;'>"+
         "<a class='editblack hand' title='"+action+"'><b>"+amt+"</b></a></td></tr>");
   }
   bbox.append("\n</table><div id='blackformbox'><form id='blackform' method=post action=fight.php><input type=hidden name=black value='add'><span title='Canonical ID of "+
      "action to blacklist.'><b>Action:</b></span> <input id='blackid' name=id size=18> <span title='Enter 0 to completely blacklist.  Otherwise, number "+
      "to keep in reserve (items) or maximum casts allowed per combat (skills).'><b>Amount:</b></span> <input id='blackamt' name=amt size=4> <input type=image "+
      "src='images/itemimages/uparrow.gif' height=20 width=20 title='Add entry'> <img src='images/itemimages/downarrow.gif' height=20 width=20 title='Cancel' "+
      "onClick=\"$('#blackformbox').slideUp();s\"></form></div></center>");
   bbox.write();
   exit;
}

string quote() {
   string[int] bw;
   switch (m) {
//      case $monster[]: bw[count(bw)] = ""; break;
      case $monster[Mutant Cookie-Baking Elf]:
      case $monster[Cookie-baking Thing from Beyond Time]: bw[count(bw)] = "Lisa: \"Would you like to come in for a glass of milk and cookies?\"<br>"+
         "Bruce: \"I'm afraid it's rather late. Why, it's 10:30!\"";
         bw[count(bw)] =  "Bruce: \"Milk and cookies, did you say?\"<br>Lisa: \"I made the cookies myself.\"<br>Bruce: \"Man cannot live by crime-fighting alone.\""; break;
      case $monster[normal hobo]: bw[count(bw)] = "\"A reporter's lot is not easy, making exciting stories out of plain, average, ordinary people like Robin and me.\""; break;
      case $monster[clingy pirate]: bw[count(bw)] = "Marsha: \"You mean you're not in love with me?\"<br>Batman: \"I'm not even mildly interested.\""; break;
      case $monster[rotten dolphin thief]: bw[count(bw)] = "\"There's a method to his misdemeanors.\"";
         bw[count(bw)] = "\"I'm certain this is the first stitch in a large tapestry of crime.\""; break;
      case $monster[suckubus]: bw[count(bw)] = "Olga: \"You find me attractive?\"<br>Batman: \"I'd find you much more attractive if you were on the right side of the law, Olga.\""; break;
      case $monster[beast with x eyes]: bw[count(bw)] = "\"It's staring us right in our masks.\""; break;
      case $monster[mob penguin hitman]: bw[count(bw)] = "\"Judging from the trajectory of the angle, and figuring the wind at six knots per hour north by northeast as per this morning's weather report...X times six squared...over...logarithm of that...yes! You see? It came from that room on that floor!\""; break;
      case $monster[giant bird-creature]: bw[count(bw)] = "Bruce: \"Yes, Dick, your bird calls are close to perfect. If more people practiced them, someday we might have a chance for real communication with our feathered friends.\"<br>Dick: \"In that case I think I'll polish up my ruby-crowned kinglet and my rose-breasted yellow-tailed grouse-beak calls.\""; break;
      case $monster[naughty sorceress]:
      case $monster[naughty sorceress (2)]:
      case $monster[naughty sorceress (3)]: bw[count(bw)] = "Robin: \"I guess you can never trust a woman.\"<br>Batman: \"You've made a hasty generalization, Robin. It's a bad habit to get into.\""; break;
      case $monster[swarm of scarab beatles]: bw[count(bw)] = "Robin: \"But what is it?\"<br>Batman: \"Saribus Sacer. A species of ancient Egyptian beetle, sacred to the Sun God, Hymeopolos. And from which the term scarab is derived. But, you should know that, Robin, if you are up on your studies of Egyptology.\"<br>Robin: \"You're right.\""; break;
      case $monster[fruit golem]: bw[count(bw)] = "Blaze: \"Oh Batman, would you get me a candy bar please?\"<br>Batman: \"Candy? Actually, fresh fruit is much more healthful.\""; break;
   }
   if (contains_text(to_lower_case(to_string(m)),"guard")) bw[count(bw)] = "\"It's obvious. Only a criminal would disguise himself as a licensed, bonded guard yet callously park in front of a fire hydrant!\"";
   if (contains_text(to_string(m),"Tooth")) bw[count(bw)] = "Robin: \"Holy molars! Am I ever glad I take good care of my teeth!\"<br>Batman: \"True. You owe your life to dental hygiene.\"";
   switch (my_location()) {
//      case $location[]: bw[count(bw)] = ""; break;
      case $location[the lower chambers]: bw[count(bw)] = "\"Out of the sarcophagus and back into the saddle.\"";
         bw[count(bw)] = "\"Oda wabba simba. Six o'clock in our nomenclature. In the 14th dynasty, the hour of the hyena. The time when ancient Egyptian supercriminals invariably struck!\""; break;
      case $location[outside the club]: bw[count(bw)] = "\"At the risk of sounding conceited, young lady, we're not just anyone.\"";
         bw[count(bw)] = "Dick: \"Sorry, I'm not interested in dance lessons.\"<br>Bruce: \"Wait a minute, Dick. The junior prom's coming up, isn't it?\"<br>Dick: \"Yes, but...\"<br>Bruce: \"Well, we don't want you to be a wallflower, do we? Dancing is an integral part of every young man's education.\"<br>Dick: \"Gosh Bruce, you're right.\""; break;
      case $location[the f'c'le]:
      case $location[belowdecks]:
      case $location[the poop deck]: bw[count(bw)] = "Barbara: \"I think a ship sailing is one of the most exciting things in the world. Don't you, Bruce?\"<br>Bruce: \"Glamorous, romantic, a sense of mystery and adventure. Hard to beat in this hum-drum world.\""; break;
      case $location[cobb's knob treasury]: bw[count(bw)] = "\"We just dropped in for that Small Batcave Improvement Loan that you mentioned, but in view of the strange criminal activity that seems to be transpiring here...\"";
         bw[count(bw)] = "Dick: \"Gosh, Economics is sure a dull subject.\"<br>Bruce: \"Oh, you must be jesting, Dick. Economics dull? The glamour, the romance of commerce... Hmm. It's the very lifeblood of our country's society.\""; break;
      case $location[the hidden temple]: bw[count(bw)] = "\"It looks like we're getting closer to the heart of this criminal artichoke.\""; break;
      case $location[the temple portico]: bw[count(bw)] = "Robin: \"Batman, look! What skinny macaroni!\"<br>Batman: \"No, it's spaghetti, Robin. A variety of alimentary paste, larger then bernachelli but not as tubular as macaroni.\""; break;
      case $location[the typical tavern cellar]:
      case $location[a barroom brawl]: bw[count(bw)] = "Robin: \"Let's go!\"<br>Batman: \"Not you, Robin. They have strict licensing laws in this country. A boy of your age is not allowed in a drinking tavern.\""; break;
      case $location[The Valley of Rof L'm Fao]: bw[count(bw)] = "Robin: \"You can't get away from Batman that easy!\"<br>Batman: \"Easily.\"<br>Robin: \"Easily.\"<br>Batman: \"Good grammar is essential, Robin.\"<br>Robin: \"Thank you.\"<br>Batman: \"You're welcome.\"";
         bw[count(bw)] = "\"It's full of misspellings, and I'm full of misgivings.\""; break;
      case $location[south of the border]: bw[count(bw)] = "Batman: \"The green button will turn the car <i>a la izquierda o a la derecha</i>.\"<br>Robin: \"To the left or right. Threw in a little Spanish on me, huh, Batman?\"<br>Batman: \"One should always keep abreast of foreign tongues, Robin.\"";
         bw[count(bw)] = "Batman: \"Let's go Robin, we've nary a second to lose! <i>Vamanos!</i>\"<br>Robin: \"Right <i>amigo!</i>\""; break;
      case $location[none]: break;
      default: bw[count(bw)] = "To the Bat-"+my_location()+"!";
   }
   switch (m.phylum) {
//      case $phylum[]: bw[count(bw)] = ""; break;
      case $phylum[horror]:
      case $phylum[undead]:
      case $phylum[demon]: bw[count(bw)] = "\"Good, even though it's sometimes sidetracked, always, repeat: always triumphs over evil.\""; break;
      case $phylum[weird]: bw[count(bw)] = "Lila: \"I have some other very rare lilacs in the rear room, if you'd like to see them.\"<br>Batman: \"I'm always interested in the unusual of any species.\""; break;
      case $phylum[fish]: bw[count(bw)] = "Robin: \"<i>Ghoti</i> is fish?\"<br>Batman: \"See here. English phonetics. GH becomes F, as in tough or laugh. O becomes I as in women. TI becomes SH as in ration or the word nation.\"<br>"+
         "Robin: \"Holy semantics, Batman. You never cease to amaze me!\"<br>Batman: \"No time for compliments, Robin. We must thwart some criminals. To the Batmobile!\""; break;
      case $phylum[plant]: bw[count(bw)] = "\"Man-eating lilacs have no teeth, Robin. It's a process of ingestion through their tentacles.\""; break;
      case $phylum[hippy]: bw[count(bw)] = "\"You're far from mod, Robin. And many hippies are older than you are.\"";
         bw[count(bw)] = "Batman: \"Go back outside and calm the flower children.\"<br>Robin: \"They'll mob me!\"<br>Batman: \"Groovy.\""; break;
      case $phylum[penguin]: bw[count(bw)] = "\"It's beddy-bye for you, Penquin.\""; break;
   }
   if (have_effect($effect[temporary blindness]) > 0) bw[count(bw)] = "Robin: \"If we close our eyes, we can't see anything.\"<br>Batman: \"A sound observation, Robin.\"";
   if (have_effect($effect[form of...bird!]) > 0) bw[count(bw)] = "Bruce: \"Yes, Dick, your bird calls are close to perfect. If more people practiced them, someday we might have a chance for real communication with our feathered friends.\"<br>Dick: \"In that case I think I'll polish up my ruby-crowned kinglet and my rose-breasted yellow-tailed grouse-beak calls.\"";
   if (have_effect($effect[beaten up]) > 0) bw[count(bw)] = "\"The best-laid plans of mice and men oft gong agley.\"";
   if (my_location().zone == "The Sea") bw[count(bw)] = "Robin: \"Where'd you get a live fish, Batman?\"<br>Batman: \"The true crimefighter always carries everything he needs in his utility belt, Robin.\"";
   if (smack.id == "" && !finished()) {
      bw[count(bw)] = "\"I'd rather die than beg for such a small favor as my life.\"";
      bw[count(bw)] = "Robin: \"That's an impossible shot, Batman.\"<br>Batman: \"That's a negative attitude, Robin.\"";
   }
   if (finished()) {
      bw[count(bw)] = "\"In the end, veracity and rectitude always triumph.\"";
      bw[count(bw)] = "Robin: \"You were right, Batman, we might have been killed.\"<br>Batman: \"Or worse.\"";
      bw[count(bw)] = "\"It's all in a day's crimefighting.\"";
   }
   if (count(bw) < 3) {
      bw[count(bw)] = "\"No time to tarry, lest we forget, lives are at stake.\"";
      bw[count(bw)] = "\"Let's go, Robin. The longer we tarry, the more dire the peril.\"";
      bw[count(bw)] = "\"An opportunity well taken is always a weapon of advantage.\"";
      bw[count(bw)] = "\"When fighting crime even the most minute detail must not be ignored.\"";
      bw[count(bw)] = "\"Are you ready to capitulate?\"";
   }
   return count(bw) == 1 ? bw[0] : bw[random(count(bw))];
}

string to_hex(int src) {
   int first = floor(src/16);
   string res;
   if (first > 0) res = to_hex(first);
   src -= first*16;
   switch (src) {
      case 10: return res + "a";
      case 11: return res + "b";
      case 12: return res + "c";
      case 13: return res + "d";
      case 14: return res + "e";
      case 15: return res + "f";
   }
   return res + to_string(src);
}
string to_htmlcolor(float percent) {  // returns a gradient, 100% = green, 0% = red
   int pos = round(minmax(percent,0,1)*255.0);
   string pt1 = to_hex(255-pos);
   if (length(pt1) == 1) pt1 = "0"+pt1;
   string pt2 = to_hex(pos);
   if (length(pt2) == 1) pt2 = "0"+pt2;
   return "#"+pt1+pt2+"00";
}

string to_html(advevent a, int i, boolean shorty) {
   buffer res;
   if (!shorty) res.append("\n  <tr><td><span style='cursor:help; font-size: 2.0em; color: "+to_htmlcolor(hitchance(a.id))+"' title='Hit chance: "+rnum(hitchance(a.id)*100)+"%'>&bull;</span> ");
  // Action
   if (kill_rounds(a) <= min(die_rounds(),maxround-round)) res.append("<form name=spam"+random(999999)+" style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
      "<input type='hidden' name='macrotext' value='"+batround()+"sub main; "+a.id+"; call batround; endsub; call main; repeat'><input type=image src='images/itemimages/sammich.gif'"+
      " width=18 height=18 title='Spam "+a.id+"! (kills monster in "+kill_rounds(a)+" rounds)' onclick='return bjilgt(this);'></form>");
   if (my_fam() == $familiar[black cat]) {
      if (contains_text(a.id,"use ")) res.append("<form name=kitty"+random(999999)+" style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
         "<input type='hidden' name='macrotext' value='"+batround()+"sub main; "+a.id+"; call batround; endsub; call main; repeat match \"bats it out of your hand\"'><input type=image src='images/itemimages/bkitten.gif'"+
         " width=18 height=18 title='Definitely "+a.id+" (at your peril!)' onclick='return bjilgt(this);'></form>");
       else if (contains_text(a.id,"skill ")) res.append("<form name=kitty"+random(999999)+" style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
         "<input type='hidden' name='macrotext' value='"+batround()+"sub main; "+a.id+"; call batround; endsub; call main; repeat match \"jumps onto the keyboard\"'><input type=image src='images/itemimages/bkitten.gif'"+
         " width=18 height=18 title='Definitely "+a.id+" (at your peril!)' onclick='return bjilgt(this);'></form>");
   }
   if (a.profit >= to_float(vars["BatMan_profitforstasis"])) {
      res.append("<form name=stasis"+random(999999)+" style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
      "<input type='hidden' name='macrotext' value='"+batround()+"sub main; "+a.id+"; call batround; endsub; call main; repeat "+stasis_repeat()+"'><input type=image src='images/itemimages/watch.gif'"+
      " width=18 height=18 title='Stasis with "+a.id+"! ("+rnum(to_profit(a))+" profit)' onclick='return bjilgt(this);'></form>");
   }
   res.append(" <form name='"+a.id+"' style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
         "<input type='hidden' name='macrotext' value='"+batround()+a.id+"; call batround'><input type=submit title='"+a.id+"' class='buttlink");
   matcher funkmatch = create_matcher("use (\\d+),(\\d+)",a.id);
   string ufname;
   switch {
      case (contains_text(a.id,";")): res.append("' "); ufname = a.id; break;
      case (contains_text(a.id,"skill ")): res.append(" skill' "); ufname = to_skill(to_int(excise(a.id,"skill ",""))); break;
      case (a.id == "attack"): res.append("' "); ufname = "Attack with weapon"; break;
      case (a.id == "jiggle"): res.append("' "); ufname = "Jiggle your chefstaff"; break;
      case (a.id == "pickpocket"): res.append("' "); ufname = "Steal"; break;
      case (funkmatch.find()): res.append(" item' "); ufname = "Funksling "+to_item(to_int(funkmatch.group(1)))+" / "+to_item(to_int(funkmatch.group(2)))+"\""; break;
      case (contains_text(a.id,"use ")): item blbl = to_item(to_int(excise(a.id,"use ","")));
            if (blbl != $item[none]) { res.append(" item' "); ufname = blbl+" ("+item_amount(blbl)+")"; break; }
      default: res.append("' "); ufname = a.id; break;
   }
   res.append("value=\""+ufname+"\" onclick='return bjilgt(this);'></form>");
   if (a.note != "") res.append(" <img src='images/itemimages/asterisk.gif' width=12 height=12 title='"+a.note+"' style='cursor:help'>");  // note
   res.append(" <span class='littlemeat'>("+rnum(-a.meat)+"&mu;)</span></td>");  // cost appended
   if (shorty) return to_string(res);
  // Damage
   res.append("<td>");
   if (dmg_dealt(a.dmg) != 0) {
      res.append("<span title='Formula: "+
       (contains_text(a.id,"use ") ? factors["item"][to_int(excise(a.id,"use ",""))].dmg :
        contains_text(a.id,"skill ") ? factors["skill"][to_int(excise(a.id,"skill ",""))].dmg : "0") + "'>");
      res.append(to_html(a.dmg));
      if (a.dmg[$element[none]] != dmg_dealt(a.dmg)) res.append(" (Dealt:&nbsp;"+rnum(dmg_dealt(a.dmg))+")");
      res.append(" <span class='littlemeat'>("+rnum(-a.meat/dmg_dealt(a.dmg))+"&nbsp;&mu;PD)</span></span>");
   }
  // Delevel
   res.append("</td><td>");
   if (a.att != 0) {
      int tillsafe;
      if (monster_stat("att") > my_defstat() - 6) tillsafe = max(0,round((my_defstat() - monster_stat("att") - 6)/a.att));
      if (tillsafe > 0) res.append("<form name=macro"+random(999999)+" style='display:inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
      "<input type='hidden' name='macrotext' value='"+batround()+"sub main; "+a.id+"; call batround; endsub; call main; repeat !times "+(tillsafe-1)+"'><input type=image src='images/itemimages/nicesword.gif' border=0"+
      " width=16 height=16 title='Delevel until safe: x"+tillsafe+" ("+rnum(m_dpr(a.att,0)-m_dpr(0,0))+" DPR)' onclick='return bjilgt(this);'></form>"+rnum(a.att)+" ");
       else res.append("<span title='"+rnum(m_dpr(a.att,0)-m_dpr(0,0))+" DPR.'>"+rnum(a.att)+"</span>");
   }
   res.append("</td><td>");
   if (a.def != 0) {
      int tillhit;
      if (monster_stat("def") > buffed_hit_stat() - 6) tillhit = max(0,round((buffed_hit_stat() - monster_stat("def") - 6)/a.def));
      if (tillhit > 0) res.append("<form name=macro"+random(999999)+" style='display:inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
      "<input type='hidden' name='macrotext' value='"+batround()+"sub main; "+a.id+"; call batround; endsub; call main; repeat !times "+(tillhit-1)+"'><input type=image src='images/itemimages/whiteshield.gif' border=0"+
      " width=16 height=16 title='Delevel until you can always hit: x"+tillhit+"' onclick='return bjilgt(this);'></form>"+rnum(a.def)+" ");
       else res.append(rnum(a.def));
   }
  // Stun
   res.append("</td><td>");
   if (a.stun != 0) res.append("<a title='"+rnum(m_dpr(0,a.stun)-m_dpr(0,0))+" DPR'>"+rnum(a.stun*100.0)+"% </a>");
  // HP
   res.append("</td><td>");
   if (dmg_taken(a.pdmg) != 0) {
     res.append(to_html(a.pdmg));
     if (minmax(-dmg_taken(a.pdmg),-my_hp(),my_maxhp()-my_hp()) != -dmg_taken(a.pdmg)) res.append(" <small>("+rnum(minmax(-dmg_taken(a.pdmg),-my_hp(),my_maxhp()-my_hp()))+")</small>");
   }
  // MP
   res.append("</td><td>");
   if (a.mp != 0) {
     res.append(rnum(a.mp));
     if (minmax(a.mp,-my_mp(),my_maxmp()-my_mp()) != a.mp) res.append(" <small>("+rnum(minmax(a.mp,-my_mp(),my_maxmp()-my_mp()))+")</small>");
   }
  // Profit
   res.append("</td><td><span style='color: "+to_htmlcolor(minmax((a.profit+100.0)/200,0,1.0))+"'>"+rnum(a.profit)+"</span></td><td>");
  // Add to Blacklist
   if (!(rawlist contains a.id)) res.append("<a href=# class='addblack' title='"+a.id+"'><img src='images/itemimages/rightarrow.gif' title=\"Send '"+a.id+"' to blacklist.\" height=15 width=15></a>");
  // Hidden Indices
   res.append("</td><td>"+rnum(i)+"</td>");              // attack_action()
   res.append("<td>"+rnum(stasdex[a.id])+"</td>");       // stasis_action()
   res.append("<td>"+rnum(stundex[a.id])+"</td>");       // stun_action()
   res.append("<td>"+a.id+" "+ufname+(a.custom != "" ? " custom "+a.custom : "")+"</td></tr>");  // text for searchability
   return res.to_string();
}
string to_html(advevent a, int i) { return to_html(a,i,false); }

void batman_enhance() {
   if (!(post contains "page")) { write("No page submitted."); print("This script is not intended to be run from the CLI."); }
   act(post["page"]);
   actbox.append("<div id='actbox'>");
   if (!finished()) {
     // custom actions
      build_custom();
      enqueue_custom();
      if (count(queue) > 0) {
         actbox.append("\n   <div class='onemenu'><form name='batcustom' style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
           "<input type='hidden' name='macrotext' value='"+get_macro()+"'><input type=image src='images/itemimages/bulb.gif' "+
           "title='Custom -- click to perform all' height=22 width=22 onclick='return bjilgt(this);'></form></div>\n<div class='popout'>");
         foreach n,a in queue actbox.append((n+1)+". "+to_html(a,n,true)+"<br>\n");
         actbox.append("   </div>");
      }
     // disco combos
      reset_queue();
      build_combos();
      enqueue_combos();
      if (count(queue) > 0) {
         actbox.append("\n   <div class='onemenu'><form name='batcombos' style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
           "<input type='hidden' name='macrotext' value='"+get_macro()+"'><input type=image src='images/itemimages/discoball.gif' "+
           "title='Combos -- click to perform all' height=22 width=22 onclick='return bjilgt(this);'></form></div>\n<div class='popout'>");
         foreach n,a in queue actbox.append((n+1)+". "+to_html(a,n,true)+"<br>\n ");
         actbox.append("</div>");
      }
     // cache stun/stasis/attack
      stun_action(false);
      foreach i,o in opts stundex[o.id] = i;
      stasis_action();
      foreach i,o in opts stasdex[o.id] = i;
      attack_action();
     // stasis!
      if (plink.profit >= to_float(vars["BatMan_profitforstasis"]) || is_our_huckleberry()) {
         actbox.append("\n   <div class='onemenu'><form name='batstasis' style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
           "<input type='hidden' name='macrotext' value='"+batround()+"sub main; "+plink.id+"; call batround; endsub; call main; repeat "+stasis_repeat()+"'><input type=image src='images/itemimages/watch.gif' "+
           "title='Stasis with "+plink.id+"' height=22 width=22 onclick='return bjilgt(this);'></form></div>\n<div class='popout'>");
         actbox.append(to_html(plink,0,true)+"<p><span id='stasissort' class='littlesort'><img src='images/itemimages/bgecalendar.gif'> Sort by stasis_action()</span></div>");
      }
     // stun!
      if (adj.stun < 1 && (buytime.stun > 1 || buytime.profit >= 0) && kill_rounds(smack) > 1 &&
          min(buytime.stun - 1, kill_rounds(smack)-1)*m_dpr(0,0)*meatperhp > buytime.profit) {
         actbox.append("\n   <div class='onemenu'><form name='batstun' style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
           "<input type='hidden' name='macrotext' value='"+batround()+buytime.id+"; call batround"+"'><input type=image src='images/itemimages/bananapeel.gif' "+
           "title='Stun with "+buytime.id+"' height=22 width=22 onclick='return bjilgt(this);'></form></div>\n<div class='popout'>");
         actbox.append(to_html(buytime,0,true)+"<p><span id='stunsort' class='littlesort'><img src='images/itemimages/bgecalendar.gif'> Sort by stun_action()</span></div>");
      }
     // attack
      if (smack.id != "") {
         actbox.append("\n   <div class='onemenu'><form name='batattack' style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
           "<input type='hidden' name='macrotext' value='"+batround()+smack.id+"; call batround"+"'><input type=image src='images/itemimages/"+
           (current_hit_stat() == $stat[moxie] ? "crossbow" : "nicesword")+".gif' title='"+smack.id+"' height=22 width=22 onclick='return bjilgt(this);'></form></div>\n<div class='popout'>");
         actbox.append(to_html(smack,0,true)+"<p><span id='attacksort' class='littlesort'><img src='images/itemimages/bgecalendar.gif'> Sort by attack_action()</span></div>");
      }
     // siphon
      if (my_fam() == $familiar[happy medium] && !happened("skill 7117") && get_spirit() != $item[none]) {
         item whichspirit = get_spirit();
         actbox.append("\n   <div class='onemenu'><form name='siphon' style='display: inline' action=fight.php method=post><input type=hidden name=action value='macro'>"+
           "<input type='hidden' name='macrotext' value='"+batround()+"skill 7117; call batround"+"'><input type=image src='images/itemimages/"+whichspirit.image+
           "' title='skill 7117' height=22 width=22 onclick='return bjilgt(this);'></form></div>\n<div class='popout'>");
         actbox.append("Siphon a <span style='color: "+($familiar[happy medium].charges == 1 ? "blue" : ($familiar[happy medium].charges == 2 ? "orange" : "red"))+
            "'><b>"+whichspirit+"</b></span> ("+whichspirit.quality+")<p><small>Adventures: "+whichspirit.adventures+(whichspirit.levelreq > my_level() ? 
            "<br>Level required: "+whichspirit.levelreq : "")+(whichspirit.muscle == "0" ? "" : "<br>Muscle: "+whichspirit.muscle)+
            (whichspirit.mysticality == "0" ? "" : "<br>Mysticality: "+whichspirit.mysticality)+(whichspirit.moxie == "0" ? "" : "<br>Moxie: "+
            whichspirit.moxie)+"<p>"+whichspirit.notes+"</small><br><a href='#' class='clilink' title='wiki "+whichspirit+"'>more info</a></div>");
      }	  
     // automate
      actbox.append("\n   <div class='onemenu'><form name='automate' style='display: inline' action=fight.php method=post><input type=hidden name=runcombat "+
         "value=\"heckyes\"><input type=image src='images/otherimages/sigils/recyctat.gif' "+
         "title='Automate' height=22 width=22 onclick='return bjilgt(this);'></form></div>\n<div class='popout'>Hand this combat over to mafia.<p>"+
         round+". "+get_ccs_action(round)+"</div>");
     // macros
      matcher mac = create_matcher("option value=\"(\\d+)\" picurl=.+?\\>(.+?)\\<\\/option",excise(page,"macrotext",""));
      boolean ncheese;
      while (mac.find()) {
         if (!ncheese) { actbox.append("\n   <div class='onemenu'><img src='images/itemimages/braces.gif' "+
         "title='Macros' height=22 width=22></div>\n<div class='popout'>Saved combat macros:<ul>"); ncheese = true; }
         actbox.append("<li><form name='macro"+mac.group(1)+"' action=fight.php method=post><input type=hidden name=action value='macro'>"+
            "<input type='hidden' name='whichmacro' value='"+mac.group(1)+"'><input type=submit title='macro "+mac.group(1)+
            "' class='buttlink' value=\""+mac.group(2)+"\" onclick='return bjilgt(this);'></form></li>");
      } if (ncheese) actbox.append("</ul></div>");
   } else if (my_location() != $location[none] && my_adventures() > 0 && contains_text(page,to_url(my_location()))) {
     // adventure again link, includes location info?
      actbox.append("\n   <div class='onemenu'><a href='"+to_url(my_location())+(my_location() == $location[the boss bat's lair] ? "&confirm2=on" : "")+"'>"+
        "<img src='../images/itemimages/hourglass.gif' height=22 width=22 border=0></a></div><div class='popout' id='again'></div>");
     // semirare helper!
      if (get_counters("Semirare window begin",0,10) != "" || get_counters("Fortune Cookie",0,10) != "" ||    // if either window/counter is nigh
          get_counters("Semirare window end",0,my_path() == "Oxygenarian" ? 20 : 40) != "") {                 // or we're IN the window, show
         actbox.append("\n   <div class='onemenu'><img src='images/itemimages/fortune.gif'  height=22 width=22 border=0 title='Semirare helper'></div>"+
            "\n<div class='popout' id='srhelper'></div>");
      }
   }
   string BMRver = check_version("BatMan RE","batman-re",10042);
   string verstuff;
   void addver(string res) { if (res == "") return; verstuff += "<p>"+res; }
   addver(BBver); addver(SSver); addver(BMRver);
   actbox.append("\n   <div class='onemenu'><a href='http://zachbardon.com/mafiatools/bats.php' target='_new'>"+
      "<img src='../images/itemimages/2wingbat.gif' height=22 width=22 border=0></a></div>"+
      "<div class='popout'><a href='http://kolmafia.us/showthread.php?10042' title='Official thread' target='_new'>BatMan RE</a> "+
      "is powered by <a href='http://kolmafia.us/showthread.php?6445' title='Official thread' target='_new'>BatBrain</a>.<p>");
   if (to_boolean(vars["BatMan_RE_enabled"])) actbox.append("<form name=disablebatman action=fight.php method=post><input type=hidden name=enabletoggle value=off>"+
      "<input class=button type=submit value='Disable BatMan RE'></form><p>");
   actbox.append((verstuff == "" ? "<div id='batquote'>"+quote()+"</div>" : verstuff)+"</div></div>");
  // Add unknown_ml editor if any stats are unknown
   if (!havemanuel && (m.raw_attack == -1 || m.raw_defense == -1 || m.raw_hp == -1) && contains_text(page,"monname"))
      actbox.append("<div id='undermon'><form name='changeml' action=fight.php method=post>Unknown monster stats treated as "+
      "<input name=setml type=text size=4 value='"+vars["unknown_ml"]+"'>.</form></div>");
  // Actions table
   if (!finished()) {
      reset_queue();
      actbox.append("<table id='battable' width='100%'>\n"+
        "<thead><tr><th>Action</th><th>Damage</th>"+
        "<th><img src='images/itemimages/nicesword.gif' title='Delevel Attack' height=26 width=26 border=0></th>"+
        "<th><img src='images/itemimages/whiteshield.gif' title='Delevel Defense' height=26 width=26 border=0></th><th>Stun</th>"+
        "<th><img src='images/itemimages/hp.gif' title='1 HP = "+rnum(meatperhp,3)+"&mu;' border=0></th>"+
        "<th><img src='images/itemimages/mp.gif' title='1 MP = "+rnum(meatpermp,3)+"&mu;' border=0></th>"+
        "<th><img src='images/itemimages/meatstack.gif' title='Profit' border=0></th>"+
        "<th><img src='images/itemimages/scroll1.gif' title='Add to Blacklist' height=26 width=26 border=0></th>"+
        "<th>A</th><th>...</th><th>S</th><th>U</th></tr></thead>\n<tbody>");
      foreach i,ev in opts actbox.append(to_html(ev,i));
      actbox.append("\n</tbody></table>\n   ");
  // enhanced Manuel box
      actbox.append("<div id='manuelbox'><table><tr><td width=22><img src=/images/itemimages/nicesword.gif width=22 height=22 "+
         "title='This monster has a "+rnum(m_hit_chance()*100.0,2)+"% chance of hitting you for "+rnum(dmg_taken(m_regular()))+" damage, death in "+rnum(die_rounds())+
         " rounds.'></td><td width=50 valign=center align=left><b><span style='font-size: 1.2em; color: "+to_htmlcolor(1.0-m_hit_chance())+";'>"+
         rnum(monster_stat("att"))+"</span></b></td></tr>");
      actbox.append("<tr><td width=22><img src=/images/itemimages/whiteshield.gif width=22 height=22 "+
         "title='You have a "+rnum(hitchance("attack")*100.0)+"% chance of hitting for "+rnum(dmg_dealt(regular(1)))+" damage.'></td>"+
         "<td width=50 valign=center align=left><b><span style='font-size: 1.2em; color: "+to_htmlcolor(hitchance("attack"))+";'>"+
         rnum(monster_stat("def"))+"</span></b></td></tr>");
      actbox.append("<tr><td width=22><img src=/images/itemimages/hp.gif width=22 height=22 "+
         "title='This monster typically starts with "+monster_hp(m)+" hit points.'></td>"+
         "<td width=50 valign=center align=left><b><span style='font-size: 1.2em; color: "+
         to_htmlcolor(monster_stat("hp")/max(1.0,to_float(monster_hp(m))))+";'>"+rnum(monster_stat("hp"))+"</span></b></td></tr>");
      actbox.append("<tr><td width=22><img src=/images/itemimages/meatstack.gif width=22 height=22 "+
         "title='Monster value: "+
         rnum(to_float(my_path() == "Way of the Surprising Fist" ? max(meat_drop(m),12) : meat_drop(m)) * (max(0,meat_drop_modifier()+100))/100.0)
         +" meat + "+rnum(stat_value(m_stats()))+" in substats + item drops'></td>"+
         "<td width=50 valign=center align=left><b><span style='font-size: 1.2em; color: green;'>"+rnum(monstervalue())+"&mu;</span></b></td></tr>");
      actbox.append("</table></div>\n");
   }
   actbox.write();
}

void main() { batman_enhance(); }