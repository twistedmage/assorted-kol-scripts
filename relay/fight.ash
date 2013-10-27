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
import <zlib.ash>

float turns_till_goals(boolean usespec) {
   float totalgoalitems;
   foreach i,s in get_goals() {
      matcher numthings = create_matcher("(\\d+) (.*)",s);
      if (!numthings.find() || !is_goal(numthings.group(2).to_item())) continue;
      totalgoalitems += numthings.group(1).to_int();
   }
   return totalgoalitems / max(has_goal(my_location(),usespec),0.0001);
}
boolean is_banished(monster m) {
   if (m == $monster[none] || m.boss) return false;
   if (m == to_monster(get_property("_nanorhinoBanishedMonster"))) return true;
   switch (my_class()) {
      case $class[avatar of boris]:
      case $class[zombie master]: foreach i,s in split_string(get_property("banishingShoutMonsters"),"\\|") if (m == to_monster(s)) return true; break;
      case $class[avatar of jarlsberg]: foreach i,s in split_string(get_property("_jiggleCheesedMonsters"),"\\|") if (m == to_monster(s)) return true; break;
   }
   if (get_counters(m+" banished",0,20) != "") return true;
   return false;
}
boolean is_set_to(monster m, string attban) {
   string[int] ms = split_string(vars[(attban == "attract" ? "BatMan_attract" : "BatMan_banish")],", ");
   foreach i,foe in ms if (to_monster(foe) == m) return true;
   return false;
}
buffer results;

record einclove {
   int[item] yield;   // all items yielded, and their average amounts
   boolean andor;     // in case of multiple item types, whether you get all types (true) or only one type (false)
   string note;       // E (X turns), X Substat, other
};
einclove[location] cloves;

string clover_string(location wear) {
   if (!load_current_map("clover_adventures",cloves) || !(cloves contains wear)) return "";
   einclove e = cloves[wear];
   buffer res;
   res.append("<td align=center>");
   boolean popped;
   foreach i,n in e.yield {
      if (popped && !e.andor) res.append(" &or; ");
      res.append("<a href=# class='cliimglink' title='wiki "+entity_encode(i)+"'><img src='/images/itemimages/"+i.image+
         "' title=\""+(n > 1 ? rnum(n)+" "+to_plural(i) : to_string(i))+"\"></a>");
      popped = true;
   }
   res.append((res.length() > 0 && e.note.length() > 0 ? "<br>" : "")+e.note+"<br>");
   if (item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]) == 0) res.append("<img src='/images/itemimages/disclover.gif'> (0)");
    else if (item_amount($item[ten-leaf clover]) > 0) res.append("<a href=# class='cliimglink' title='use * ten-leaf clover'><img src='/images/itemimages/clover.gif' title='Disassemble all clovers'></a> ("+
       rnum(item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]))+")");
     else res.append("<a href=# class='cliimglink' title='use 1 disassembled clover'><img src='/images/itemimages/disclover.gif' title='Assemble a clover'></a> ("+
       rnum(item_amount($item[ten-leaf clover]) + item_amount($item[disassembled clover]))+")");
   res.append("</td>");
   return res.to_string();
}

string[string] post;
void handle_post() {
   post = form_fields();
   if (count(post) == 0) return;
   int wskils(item w) { switch (w) {
      case $item[mer-kin dodgeball]: return to_int(get_property("gladiatorBallMovesKnown"));
      case $item[mer-kin dragnet]: return to_int(get_property("gladiatorNetMovesKnown"));
      case $item[mer-kin switchblade]: return to_int(get_property("gladiatorBladeMovesKnown"));
   } return 0; }
   item next_w() {   // order: balldodger (dragnet), netdragger (switchblade), bladeswitcher (dodgeball)
      if ($location[mer-kin colosseum].combat_queue == "") return $item[mer-kin dragnet];
	  if (($monsters[mer-kin balldodger, mer-kin bladeswitcher, mer-kin netdragger, Georgepaul\, the Balldodger, Ringogeorge\, the Bladeswitcher] 
	     contains to_monster(get_property("lastEncounter"))) && !contains_text(run_combat(),"WINWINWIN")) return equipped_item($slot[weapon]);
      string[int] ms = split_string($location[mer-kin colosseum].combat_queue,"; ");
      switch (to_monster(ms[ms.count()-1])) {
         case $monster[mer-kin balldodger]: case $monster[Georgepaul, the Balldodger]: return $item[mer-kin switchblade];
         case $monster[mer-kin bladeswitcher]: case $monster[Ringogeorge, the Bladeswitcher]: return $item[mer-kin dragnet];
         case $monster[mer-kin netdragger]: case $monster[Johnringo, the Netdragger]: return $item[mer-kin dodgeball];
      } return $item[none];
   }
   float foodDrop() {
      float famBonus() {
         switch (my_path()) {
            case "Avatar of Boris": return minstrel_instrument() == $item[Clancy's lute] ?
               numeric_modifier($familiar[baby gravy fairy], "Item Drop", minstrel_level()*5, $item[none]) : 0;
            case "Avatar of Jarlsberg":	return my_companion() == "Eggman" ? (have_skill($skill[Working Lunch]) ? 75 : 50) : 0;
         }
         int famw = round(familiar_weight(my_familiar()) + weight_adjustment() - numeric_modifier(familiar_equipped_equipment(my_familiar()),"Familiar Weight"));
         return numeric_modifier(my_familiar(), "Item Drop", famw, familiar_equipped_equipment(my_familiar()));
      }
      return round(numeric_modifier("Item Drop") - famBonus() + numeric_modifier("Food Drop"));
   }
   if (post contains "dashi") switch (post["dashi"]) {     // build Adventure Again info box
     case "annae":
      buffer abox;
      abox.append("Adventure again at "+my_location()+".");
      switch (my_location()) {
//         case $location[]: actbox.append(""); break;
         case $location[8-bit realm]: abox.append("<table><tr>"); 
            foreach i in $items[red pixel, green pixel, blue pixel, white pixel] 
               abox.append("<td align=center>"+(creatable_amount(i) > 0 ? "<a href=# class='cliimglink' title='create * "+i+"'>" : "")+
			   "<img src='/images/itemimages/"+i.image+"' title='"+i+"'>"+(creatable_amount(i) > 0 ? "</a>" : "")+"<br>"+rnum(item_amount(i))+"</td>");
            if (item_amount($item[digital key]) == 0 && creatable_amount($item[digital key]) > 0) abox.append("<td><a href=# class='cliimglink' title='create 1 digital key'><img src='/images/itemimages/pixelkey.gif'></a></td>");
            abox.append("</tr></table>"); break;
         case $location[guano junction]: if (item_amount($item[sonar-in-a-biscuit]) > 0 && !($strings[step3, finished] contains get_property("questL04Bat"))) 
            abox.append("<p><a href=# class='cliimglink' title='use sonar-in-a-biscuit'><img src='/images/itemimages/biscuit.gif' class=hand></a>"); break;
         case $location[The Battlefield (Frat Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("hippiesDefeated")))+"</b> hippies left."); break;
         case $location[The Battlefield (Hippy Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("fratboysDefeated")))+"</b> fratboys left."); break;
		 case $location[a-boo peak]: if (item_amount($item[a-boo clue]) > 0) abox.append("<p><a href=# class='cliimglink' title='use a-boo clue'><img src='/images/itemimages/map.gif' class=hand></a> <a href=# class='clilink'>maximize spooky res, cold res, 0.01 hp</a>"); 
            abox.append("<p>Hauntedness remaining: <b>"+get_property("booPeakProgress")+"</b>"); break;
         case $location[twin peak]: int tpprog = to_int(get_property("twinPeakProgress")); if (tpprog < 8) abox.append("<br>");
            if ((tpprog & 1) == 0) abox.append("<br><b>Stench res:</b> "+rnum(numeric_modifier("Stench Resistance"))+"/4 needed"+
               (numeric_modifier("Stench Resistance") < 4 ? " <a href=# class='clilink'>maximize stench res, -tie</a>" : ""));
            if ((tpprog & 2) == 0) abox.append("<br><b>Food drops:</b> "+rnum(foodDrop())+"/50 needed"+
               (foodDrop() < 50 ? " <a href=# class='clilink'>maximize 1.1 food drop, items, -tie</a>" : ""));
            if ((tpprog & 4) == 0) abox.append("<br>You <b>"+(item_amount($item[jar of oil]) == 0 ? "lack" : "have")+"</b> a jar of oil."+
               (item_amount($item[jar of oil]) == 0 ? " <a href='adventure.php?snarfblat=298' class='clilink through' title=''>Oil Peak (1)</a>" : ""));
            if (tpprog == 7) abox.append("<br><b>Initiative:</b> "+rnum(numeric_modifier("Initiative"))+"/40 needed"+
               (numeric_modifier("Initiative") < 40 ? " <a href=# class='clilink'>maximize init, -tie</a>" : ""));
            if (item_amount($item[rusty hedge trimmers]) > 0) abox.append("<p><a href=# class='cliimglink' title='use rusty hedge trimmers'><img src='/images/itemimages/hedgeclippers.gif' class=hand></a>"); break;
         case $location[oil peak]: abox.append("<p>Pressure remaining: <b>"+get_property("oilPeakProgress")+"</b> ("+ceil(to_float(get_property("oilPeakProgress"))/6.34)+" slicks)"); 
            if (item_amount($item[dress pants]) > 0 && !have_equipped($item[dress pants]) && be_good($item[dress pants]) && can_equip($item[dress pants])) 
               abox.append("<p><a href=# class='clilink'>equip dress pants</a>");
            if (item_amount($item[jar of oil]) == 0 && creatable_amount($item[jar of oil]) > 0 && (to_int(get_property("twinPeakProgress")) & 4) == 0)
               abox.append("<p><a href=# class='cliimglink' title='create 1 jar of oil'><img src='/images/itemimages/oiljar.gif' class=hand></a>"); break;
         case $location[the defiled nook]: if (item_amount($item[evil eye]) > 0) abox.append("<p><a href=# class='cliimglink' title='use * evil eye'><img src='/images/itemimages/zomboeye.gif' class=hand></a>");
         case $location[the defiled cranny]:
         case $location[the defiled alcove]:
         case $location[the defiled niche]: abox.append("<p><b>"+get_property("cyrpt"+excise(my_location(),"d ","")+"Evilness")+"</b> evilness left here."); break;
         case $location[the hole in the sky]: abox.append("<p><table style='padding: 0'><tr><th><img src='/images/itemimages/starchart.gif' border=0><br>"+rnum(item_amount($item[star chart]))+
            "</th><th><img src='/images/itemimages/star.gif' border=0><br>"+rnum(item_amount($item[star]))+"</th><th><img src='/images/itemimages/line.gif' border=0><br>"+rnum(item_amount($item[line]))+"</th></tr>");
            foreach i in $items[richard's star key, star hat, star sword, star crossbow] if (have_item(i) == 0) abox.append("<tr><td>"+
              (creatable_amount(i) > 0 ? "<a href=# class='cliimglink' title=\"create 1 "+i+"\"><img src='/images/itemimages/"+i.image+"' class=hand></a>" : "<img src='/images/itemimages/"+i.image+"' title=\""+i+"\" border=0>")+
			  "</td><td align=center>"+get_ingredients(i)[$item[star]]+"</td><td align=center>"+get_ingredients(i)[$item[line]]+"</td></tr>");
            abox.append("</table>"); break;		 
         case $location[the smut orc logging camp]: int planktot; for i from 5782 to 5784 planktot += item_amount(to_item(i));
		    abox.append("<p>You have <b>"+planktot+"</b> of <b>"+rnum(30 - to_int(get_property("chasmBridgeProgress")))+"</b> needed planks."); 
			if (item_amount($item[smut orc keepsake box]) > 0) abox.append("<p><a href=# class='cliimglink' title='use smut orc keepsake box'><img src='/images/itemimages/keepsakebox.gif' class=hand></a>"); break;
		 case $location[barrrney's barrr]: int insultsknown; for n from 1 to 8 if (get_property("lastPirateInsult"+n) == "true") insultsknown += 1;
            if (insultsknown < 8) abox.append("<p>You know <b>"+insultsknown+"</b> insults."); break;
         case $location[the dungeons of doom]: abox.append("<p>"); for i from 819 to 827 abox.append(to_item(i)+(item_amount(to_item(i)) > 0 ? " ("+item_amount(to_item(i))+")" : "")+": "+
            (($strings[blessing, detection, mental acuity, ettin strength, teleportitis] contains get_property("lastBangPotion"+i)) ? "<b>"+get_property("lastBangPotion"+i)+"</b>" : get_property("lastBangPotion"+i))+"<br>"); break;
         case $location[the haunted billiards room]: if (item_amount($item[Spookyraven library key]) == 0 && have_item($item[pool cue]) > 0 &&
                                                item_amount($item[handful of hand chalk]) > 0 && have_effect($effect[chalky hand]) == 0)
            abox.append("<p><a href=# class='clilink' title='use hand chalk'>use hand chalk</a>"); break;
         case $location[the hidden hospital]: int doctot; abox.append("<p>");
            foreach i in $items[half-size scalpel, head mirror, surgical mask, surgical apron, bloodied surgical dungarees] if (have_equipped(i)) doctot += 1;
             else if (can_equip(i) && item_amount(i) > 0 && be_good(i)) abox.append("<a href=# class='cliimglink' title='equip "+(i == $item[surgical mask] ?
                "acc2" : to_slot(i))+" "+i+"'><img src='/images/itemimages/"+i.image+"' class=hand></a> ");
			abox.append("<b>"+rnum(doctot)+" / 5</b> Doctorosity");
            break;
         case $location[The Filthworm Queen's Chamber]:
            if (have_outfit("Frat Warrior")) abox.append("<p><a href='bigisland.php?place=orchard&action=stand&pwd' class='clilink through' title='checkpoint; outfit frat warrior fatigues'>visit stand as frat</a>");
            if (have_outfit("War Hippy")) abox.append("<p><a href='bigisland.php?place=orchard&action=stand&pwd' class='clilink through' title='checkpoint; outfit war hippy fatigues'>visit stand as hippy</a>"); break;
         case $location[Next to that Barrel with Something Burning in it]:
         case $location[Near an Abandoned Refrigerator]:
         case $location[Over Where the Old Tires Are]:
         case $location[Out By that Rusted-Out Car]: if (get_property("currentJunkyardTool") == "") {
               if (have_outfit("Frat Warrior")) abox.append("<p><a href=# class='clilink' title='checkpoint; outfit frat warrior; bigisland.php?action=junkman&pwd=; outfit checkpoint'>visit Yossarian as frat</a>");
               if (have_outfit("War Hippy")) abox.append("<p><a href=# class='clilink' title='checkpoint; outfit war hippy; bigisland.php?action=junkman&pwd=; outfit checkpoint'>visit Yossarian as hippy</a>");
            } break;
         case $location[The Coral Corral]: if (get_property("lassoTraining") != "expertly") abox.append("<p><img src='/images/itemimages/lasso.gif' height=20 width=20 border=0> "+get_property("lassoTraining")); break;
         case $location[mer-kin colosseum]: if (have_item(next_w()) > 0 && !have_equipped(next_w()))
            abox.append("<p><b>Prepare</b> for next monster: <a href=# class='clilink'>equip "+next_w()+"</a>"); break;
         case $location[anger man's level]: abox.append("<b>"+rnum(numeric_modifier("Hot Resistance"))+" Hot Resistance</b> (<span style='color:red'><b>"+
			   rnum(250 - (250*elemental_resistance($element[hot])/100.0))+"</b></span> to pass, 25 for pixel)<br>");
            abox.append("<b>All stats</b> 50+ pass, 500+ for pixel)"); 
            if (!have_equipped($item[regret hose]) && item_amount($item[regret hose]) > 0) abox.append("<p><a href=# class='clilink'>equip regret hose</a>"); break;
         case $location[doubt man's level]: abox.append("<p><b>"+rnum(numeric_modifier("Weapon Damage"))+" Weapon Damage</b> (100+ to pass, 300 for pixel)<br>"); 
            abox.append("<b>"+my_hp()+" HP</b> (>100 to pass, 1000 for pixel)"); 
            if (!have_equipped($item[anger blaster]) && item_amount($item[anger blaster]) > 0) abox.append("<p><a href=# class='clilink'>equip anger blaster</a>"); break;
         case $location[fear man's level]: abox.append("<p><b>"+my_buffedstat($stat[moxie])+" Moxie</b> (50 to pass, 300 for pixel)<br>"); 
            abox.append("<b>"+rnum(numeric_modifier("Spooky Resistance"))+" Spooky Resistance</b> (<span style='color:gray'><b>"+
			   rnum(250 - (250*elemental_resistance($element[spooky])/100.0))+"</b></span> to pass, 25 for pixel)"); 
            if (!have_equipped($item[doubt cannon]) && item_amount($item[doubt cannon]) > 0) abox.append("<p><a href=# class='clilink'>equip doubt cannon</a>"); break;
         case $location[regret man's level]: abox.append("<p><b>"+rnum(my_mp())+" MP</b> (100 to pass, 1000 for pixel)<br>"); int edmgsum;
            abox.append("<b>"); foreach el in $elements[] if (numeric_modifier(el+" Damage") > 0) {
               abox.append(" <span class='"+el+"'>(+"+rnum(numeric_modifier(el+" Damage"))+")</span>"); edmgsum += numeric_modifier(el+" Damage");
            }
            abox.append(" = "+rnum(edmgsum)+" Elemental Damage</b><br>(sum of 50 with some of each to pass, 100+ of each for pixel)");
            if (!have_equipped($item[fear condenser]) && item_amount($item[fear condenser]) > 0) abox.append("<p><a href=# class='clilink'>equip fear condenser</a>"); break;
      }
      if (my_location().zone == "The Sea") {
	     if (get_property("dolphinItem") != "") abox.append("<p><img src='/images/itemimages/"+to_item(get_property("dolphinItem")).image+"' title=\""+
            to_item(get_property("dolphinItem"))+" ("+rnum(sell_val(to_item(get_property("dolphinItem"))))+"&mu;)\" height=23 width=23 border=0> <a href=# class='clilink'>use dolphin whistle</a>");
         boolean popped;
		 foreach w in $items[mer-kin dodgeball, mer-kin dragnet, mer-kin switchblade] if (have_equipped(w) && wskils(w) < 3) {
		    popped = true; abox.append("<p>You have learned <b>"+wskils(w)+"</b> of <b>3</b> "+w+" skills."); break;
		 }
         if (!popped) foreach w in $items[mer-kin dodgeball, mer-kin dragnet, mer-kin switchblade] if (!have_equipped(w) && wskils(w) < 3) {
            if (!popped) { abox.append("<p>"); popped = true; }
            abox.append(" <a href=# class='clilink'>equip "+w+"</a>");
         }
      }
	  float[monster] arq = appearance_rates(my_location(),true);
      if (count(arq) > 0) {
	     abox.append("<p><table><tr>");
		 monster[int] sortm;
         foreach m in arq sortm[count(sortm)] = m;
		 sort sortm by -has_goal(value);
		 monster goalmon = has_goal(sortm[0]) == 0 ? $monster[none] : sortm[0];
		 sort sortm by -arq[value];
         foreach i,m in sortm {
		    if (arq[m] <= 0) continue;
			abox.append("<td align=center class='queuecell"+(m == goalmon && count(get_goals()) > 0 ? " goalmon" : "")+(is_banished(m) ? " dimmed" : "")+
               "'><a href=# class='cliimglink' title='wiki "+(m == $monster[none] ? to_string(my_location()) : m)+
               "'><img src='/images/adventureimages/"+(m == $monster[none] ? "3doors.gif" : m.image == "" ? "question.gif" : m.image)+
               "' title='"+(m == $monster[none] ? "Noncombat" : entity_encode(m)+(is_banished(m) ? " (banished)" : "")+
               (has_goal(m) > 0 ? " (goals: "+rnum(has_goal(m))+")" : ""))+"' height=50 width=50></a>");
            if (m == $monster[none] || m.boss) abox.append("<p>"); 
			else if (count(arq) > 1 && !($locations[mer-kin colosseum, the slime tube, oil peak, the daily dungeon] contains my_location()) && !($strings[Dreadsylvania, Volcano] contains my_location().zone)) {
               abox.append("<br><a href=# class='cliimglink"+(is_set_to(m,"attract") ? "" : " dimmed")+"' title='zlib BatMan_attract = "+
                  (is_set_to(m,"attract") ? list_remove(vars["BatMan_attract"],m) : list_add(vars["BatMan_attract"],m))+
				  "'><img src='/images/itemimages/uparrow.gif' height='16' width='16' title='Click to "+
				  (is_set_to(m,"attract") ? "stop attracting "+m+" (remove from BatMan_attract)." : "attract "+m+" (add to BatMan_attract).")+"'></a>");
               abox.append("<a href=# class='cliimglink"+(is_set_to(m,"banish") ? "" : " dimmed")+"' title='zlib BatMan_banish = "+
                  (is_set_to(m,"banish") ? list_remove(vars["BatMan_banish"],m) : list_add(vars["BatMan_banish"],m))+
				  "'><img src='/images/itemimages/downarrow.gif' height='16' width='16' title='Click to "+
				  (is_set_to(m,"banish") ? "stop banishing "+m+" (remove from BatMan_banish)." : "banish "+m+" (add to BatMan_banish).")+"'></a>");
			}
            abox.append("<br>"+rnum(arq[m],1)+"%</td>");
		 }
		 abox.append(clover_string(my_location()));
	     abox.append("</tr></table>");
      }
      if (have_skill($skill[banishing shout]) && get_property("banishingShoutMonsters") != "") {
          abox.append("<p><b>Banished:</b>\n<ul>");
          foreach i,s in split_string(get_property("banishingShoutMonsters"),"\\|") abox.append("<li>"+normalized(s,"monster")+"</li>");
          abox.append("</ul>");
      }
      if (my_class() == $class[avatar of jarlsberg] && get_property("_jiggleCheesedMonsters") != "") {
          abox.append("<p><b>Banished:</b>\n<ul>");
          foreach i,s in split_string(get_property("_jiggleCheesedMonsters"),"\\|") abox.append("<li>"+normalized(s,"monster")+"</li>");
          abox.append("</ul>");
      }
      if (count(get_goals()) == 0) abox.append("<p>All goals met. <a href='#' class='clilink edit' title='conditions set'>add goals</a>");
       else {
          float gturns = turns_till_goals(false);
          abox.append("<p><b>Goals remaining"+(gturns < 9999 ? " (satisfied in <b>~"+rnum(max(1.0,gturns))+"</b> turns)" : "")+":</b>"+
             " <a href='#' class='clilink edit' title='conditions set'>add goals</a> <a href=# class='clilink' title='conditions clear'>clear</a>\n");
          abox.append("<div style='float: right; margin: 3px'><a href=# class='cliimglink' title='adventure * "+my_location()+
             "'><img src='images/otherimages/sigils/recyctat.gif' height=30 width=30 title='Automate goal acquisition'></a></div>\n<ul>");
          foreach i,g in get_goals() abox.append("<li>"+g+" <a href=# class='clilink' title=\"conditions remove "+g+"\">remove</a> "+
		     (is_goal(to_item(excise(g," ",""))) && creatable_amount(to_item(excise(g," ",""))) > 0 ? "<a href=# class='clilink' title=\"create 1 "+to_item(excise(g," ",""))+"\">create</a>" : "")+"</li>");
          abox.append("</ul>");
          if (goal_exists("item")) {
             item[slot] itgarb;
			 foreach s in $slots[] itgarb[s] = equipped_item(s);
             foreach i in get_inventory() if (can_equip(i) && numeric_modifier(i,"Item Drop") > numeric_modifier(itgarb[to_slot(i)],"Item Drop") && be_good(i))
			    itgarb[to_slot(i)] = i;
             foreach s,i in itgarb {
                if (equipped_item(s) == i || (i.to_int() > 3508 && i.to_int() < 3515)) continue;
                cli_execute("whatif equip "+i+"; quiet");
                float newturns = turns_till_goals(true);
                if (newturns >= gturns) continue;
                abox.append("<br><a href=# class='clilink' title=\"equip "+i+"\">Save "+rnum(gturns-newturns)+" turns by equipping "+i+".</a>");
                if (i.to_slot() == $slot[acc1]) for j from 1 to 3 abox.append(" <a href=# class='clilink' title=\"equip acc"+j+" "+i+"\">"+j+"</a>");
             }
          } else if (goal_exists("choiceadv")) foreach i in get_inventory() if (can_equip(i) && !have_equipped(i) && numeric_modifier(i,"Combat Rate") < 0 && be_good(i)) {
                abox.append("<br><a href=# class='clilink' title=\"equip "+i+"\">Reduce combat rate by equipping "+i+".</a>");
				if (i.to_slot() == $slot[acc1]) for j from 1 to 3 abox.append(" <a href=# class='clilink' title=\"equip acc"+j+" "+i+"\">"+j+"</a>");
		  }
       }
       if (my_class() == $class[avatar of jarlsberg] && item_amount($item[cosmic calorie]) > 19) {
          abox.append("<p><div style='float: left; text-align: center'><a href=# class='cliimglink' title='wiki cosmic calorie'><img src='/images/itemimages/cosmiccalorie.gif' title='Cosmic Calories'></a><br><b>"+
             rnum(item_amount($item[cosmic calorie]))+"</b></div><table style='margin-top: 0px; margin-left: 10px'>");
		  abox.append("<tr><td><a href=# class='clilink' title='use celestial olive oil'>use 20</a></td><td style='font-size: 0.75em'>+1 Elemental Resistance</td></tr>");
		  if (item_amount($item[cosmic calorie]) >= 30) abox.append("<tr><td><a href=# class='clilink' title='use celestial carrot juice'>use 30</a></td><td style='font-size: 0.75em'>+30% Item Drop</td></tr>");
		  if (item_amount($item[cosmic calorie]) >= 50) abox.append("<tr><td><a href=# class='clilink' title='use celestial au jus'>use 50</a></td><td style='font-size: 0.75em'>+5% Combats</td></tr>");
		  if (item_amount($item[cosmic calorie]) >= 60) abox.append("<tr><td><a href=# class='clilink' title='use celestial squid ink'>use 60</a></td><td style='font-size: 0.75em'>-5% Combats</td></tr>");
		  abox.append("</table>");
	   }
      abox.write();
      exit;
     case "wicky":
      buffer wbox;
	  string wickypage = to_upper_case(substring(last_monster(),0,1))+to_lower_case(replace_string(substring(last_monster(),1)," ","_"));  // This Format => This_format
	  wickypage = visit_url("http://kol.coldfront.net/thekolwiki/index.php/"+wickypage);
      vprint("Wiki page length: "+rnum(wickypage.length()),5);
      if (wickypage.length() > 0) { 
	     wbox.append(excise(wickypage,"\</table\>\<div style","\</div\>\<div class=\"printfooter\"\>"));
	     wbox.insert(0,"<div style");
         vprint("Trimmed (length: "+rnum(wbox.length())+").",5);
	     wbox.replace_string("a href=\"/thekolwiki","a target='_new' href=\"http://kol.coldfront.net/thekolwiki");
      } else wbox.append("<div><p>The page could not be loaded.  Try this instead: <a href=# class='clilink'>wiki "+last_monster()+"</a></div>");
      wbox.write();
      exit;
   }
   if (post contains "setml") {
      vars["unknown_ml"] = max(0,to_int(post["setml"]));
      updatevars();
   }
}

void add_features() {
  // add "loading" div
   results.replace_string("</body>", (contains_text(results,"<center><table><a name=\"end\">") && !contains_text(results, "window.fightover = true")) ? 
      "<div id='battab'><ul><li><a href='#bat-enhance'>Actions</a>"+
      "</li><li><a href='#kolformbox' title='Note: non-macro actions are not tracked!'>KoL</a></li><li><a href='#blacklist' class='blacktrigger'>Blacklist</a></li>"+
	  "<li><a href='#wikibox' class='wickytrigger'>Wiki</a></li></ul>"+
	  "<div id='bat-enhance' class='panel'><a href='fight.php' border=0><img id='compimg' src='images/adventureimages/3machines.gif'></a><p>Bat-Computer "+
	  "calculating...</div><div id='kolformbox' class='panel'><center>KoL forms here</center></div><div id='blacklist' class='panel'><p>The "+
	  "blacklist goes here.</div><div id='wikibox' class='panel'><p><img src='images/itemimages/book5.gif'><p>Consulting the Bat-Monstercyclopedia...</div></div>\n</body>" : 
      "<div id='bat-enhance'></div>\n</body>");
  // add scripts/stylesheet
   results.replace_string("</head>", "\n<script src='jquery1.10.1.min.js'></script>\n"+
      "<script src='jquery.dataTables.min.js'></script>\n<script src='clilinks.js'></script>\n<script src='batman.js'></script>\n"+
      "<link rel='stylesheet' type='text/css' href='batman.css'>\n</head>");
  // delete KoL's older version of jQuery
   results.replace_string("<script language=Javascript src=\"/images/scripts/jquery-1.3.1.min.js\"></script>","");
  // add doctype to force IE out of quirks mode
   results.replace_string("<html>", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" "+
      "\"http://www.w3.org/TR/html4/loose.dtd\">\n<html>");
  // fix KoL's CSS
   results.replace_string("right: 1; top: 2;\" id=\"jumptobot","right: 1px; top: 2px;\" id=\"jumptobot");
  // move KoL combat forms 
   results.replace_string("<table><a name=\"end\">","<a name=\"end\"><table id='kolforms'>");
   matcher kolf = create_matcher("\\<table id='kolforms'\\>.+?\\</table\\>",results);
   if (kolf.find()) {
      string alltheforms = kolf.group(0);
      results.replace_string(alltheforms,"");
      results.replace_string("KoL forms here",alltheforms);
   }	  
  // enable enhanced Manuel 
   results.replace_string("<table><tr><td><img id='monpic","<table><tr id='nowfighting'><td><img id='monpic");
   results.replace_string("<td width=30></td><td>","<td width=30></td><td id='manuelcell'>");
}
void main() {
   handle_post();
  // 100% run enforcement
   if (to_familiar(vars["is_100_run"]) != $familiar[none] && my_familiar() != to_familiar(vars["is_100_run"]))
      use_familiar(to_familiar(vars["is_100_run"]));
  // load the KoL page
   if (post contains "runcombat" && post["runcombat"] == "heckyes") results.append(run_combat());
    else results.append(visit_url());
  // enhance it
   add_features();
  // write it
   results.write();
}