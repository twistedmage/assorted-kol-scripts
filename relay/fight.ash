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
boolean been_banished(monster m) {
//   if (m == $monster[none] || m.boss) return false;
   if (is_banished(m) || get_counters(m+" banished",0,30) != "") return true;
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
   if (my_path() == "Bees Hate You") return "";  // can't use disassemBled clovers
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

record quesera {
   string yield;      // stringlist of all items yielded
   string note;       // extra infos
   string category;   // edibles, elements, ascension, fight, buff, combat items
};
quesera[location] seras;

string seratable() {
   if (!file_to_map("semirares.txt",seras)) return "";
   buffer res;
   res.append("<h3>Unfiltered, Unsorted Semirare List</h3> "+
      "(<a href='relay_Sera.ash'>filtered, sorted list</a>)\n<div style='height: 300px; overflow: auto'><table>");
   matcher ym = create_matcher("(.+?) ?(?:\\((\\d+)\\))?(?:$|, )","");
   item i;
   foreach l,rec in seras {
      res.append("<tr"+(get_property("lastSemirareReset").to_int() == my_ascensions() && l == to_location(get_property("semirareLocation")) ? 
         " class=dimmed" : "")+"><td><a href='"+to_url(l)+"'>"+l+"</a></td><td>");
   ym.reset(rec.yield);
   while (ym.find()) {
      i = to_item(ym.group(1));
      if (i == $item[none]) { res.append(ym.group(1)); continue; }
      res.append("<a href=# class='cliimglink' title=\"wiki "+i+"\"><img src='/images/itemimages/"+i.image+
         "' title=\""+i+" (have: "+rnum(have_item(i))+")\"></a> ");
      if (is_integer(ym.group(2))) res.append(" ("+ym.group(2)+") ");
   }
   if (rec.note != "") {
      element boron; if (rec.category == "element") foreach e in $elements[] if (contains_text(rec.note,to_string(e))) boron = e;
      res.append("<br><span style='font-size: 0.7em'"+(boron == $element[none] ? "" : " class='"+boron+"'")+">"+rec.note+"</span>");
   }
   res.append("</td></tr>");
  }
  res.append("</table></div>");
  return res;
}
string cliimg(item i, string cmd) {
   return "<a href=# class='cliimglink' title=\""+cmd+"\"><img src='/images/itemimages/"+i.image+"' class=hand></a>";
}
string delaybit(location loc, int delayturns, string untilwhat) {
   if (loc.turns_spent >= delayturns) return "";
   buffer res;
   res.append("<p><b>"+(delayturns - loc.turns_spent)+"</b> turns of delay until "+untilwhat+".");
   if (my_level() >= 4 && item_amount($item[turkey blaster]) + creatable_amount($item[turkey blaster]) > 0 && my_spleen_use() + 2 < spleen_limit())
      res.append(" "+cliimg($item[turkey blaster], "acquire 1 turkey blaster; chew 1 turkey blaster"));
   return res.to_string();
}

string[string] post;
void handle_post() {
   post = form_fields();
   if (count(post) == 0) return;
  // mini-functions used by various post handlers 
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
         case $monster[mer-kin netdragger]: case $monster[Johnringo, the Netdragger]: return $item[mer-kin dodgeball];
         case $monster[mer-kin bladeswitcher]: case $monster[Ringogeorge, the Bladeswitcher]: return $item[mer-kin dragnet];
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
   int narrowdown(string ctr, int offset) {
      for i from 0 to 10 if (get_counters(ctr,i,i) != "") return i+offset;
      return 0;
   }
   boolean equipgood(item i) { return item_amount(i) + creatable_amount(i) > 0 && !have_equipped(i) && be_good(i) && can_equip(i); }
  // now for the actual post handlers
   if (post contains "dashi") switch (post["dashi"]) {     // fetch a refreshed component
     case "annae":   // Adventure Again box
      buffer abox;
      location myl = (post contains "loc") ? to_location(post["loc"]) : my_location();
      if (get_property("ghostLocation") != "" && have_item($item[protonic accelerator pack]) > 0 && my_adventures() > 0 && my_inebriety() <= inebriety_limit())
         abox.append("<div style='float: right; margin: 3px'><a href="+to_url(to_location(get_property("ghostLocation")))+" class='cliimglink through' title=\"equip protonic accelerator pack\">"+
            "<img src='images/itemimages/walkietalkie.gif' height=30 width=30 title='Hunt a ghost at "+get_property("ghostLocation")+"'></a></div>\n");
      abox.append("Adventure <span style='cursor:help' title='You have spent "+rnum(myl.turns_spent)+" turns here this run.'>again</span> at <a href=# class=cliimglink title=\"wiki "+myl+"\">"+myl+"</a>.");
      if (my_path() == "Heavy Rains") {  abox.append(" <img style='vertical-align: text-top' height=22 width=22 src='/images/itemimages/");
         switch (myl.environment) {
            case "underground": abox.append("echo.gif' title='Underground: Thunder"); break;
            case "indoor": abox.append("blooddrops.gif' title='Indoors: Rain"); break;
            case "outdoor": abox.append("lightningrod.gif' title='Outdoors: Lightning"); break;
         }
         abox.append(" ("+rnum(min(6,myl.water_level+numeric_modifier("Water Level")))+")'> ");
      }
      switch (myl) {
        // Level 1/2: Larva
         case $location[8-bit realm]: abox.append("<table><tr>"); 
            foreach i in $items[red pixel, green pixel, blue pixel, white pixel] 
               abox.append("<td align=center>"+(creatable_amount(i) > 0 ? "<a href=# class='cliimglink' title='create * "+i+"'>" : "")+
               "<img src='/images/itemimages/"+i.image+"' title='"+i+"'>"+(creatable_amount(i) > 0 ? "</a>" : "")+"<br>"+rnum(item_amount(i))+"</td>");
            if (item_amount($item[digital key]) == 0 && creatable_amount($item[digital key]) > 0) abox.append("<td>"+cliimg($item[digital key], "create 1 digital key")+"</td>");
            abox.append("</tr></table>"); break;
         case $location[the outskirts of cobb's knob]: abox.append(delaybit(myl,10,"you get your encryption key")); break;
         case $location[the spooky forest]: abox.append(delaybit(myl,5,"your first Arboreal Respite")); break;
         case $location[the hidden temple]: if (item_amount($item[stone wool]) > 0 && have_effect($effect[stone-faced]) == 0)
            abox.append("<p>"+cliimg($item[stone wool],"use stone wool")); break;
        // Level 3: Rat
        // Level 4: Bat
         case $location[guano junction]: if (item_amount($item[sonar-in-a-biscuit]) > 0 && qprop("questL04Bat < 3")) 
            abox.append("<p>"+cliimg($item[sonar-in-a-biscuit],"use sonar-in-a-biscuit")); break;
         case $location[the boss bat's lair]: abox.append("<p><a href=# class='cliimglink' title='mcd 4'><img src='/images/itemimages/batpants.gif' class="+(current_mcd() == 4 ? "hand" : "dimmed")+"></a>"); 
            abox.append("<a href=# class='cliimglink' title='mcd 8'><img src='/images/itemimages/batbling.gif' class="+(current_mcd() == 8 ? "hand" : "dimmed")+"></a>"); 
            if (contains_text(my_location().combat_queue,"Boss Bat")) abox.append(" <a href=# class=clilink>mcd 10</a>"); break;
        // Level 5: Goblin
         case $location[cobb's knob harem]: abox.append(delaybit(myl,10,"you find the harem girl outfit in the Locker")); break;
        // Level 6: Friar
        // Level 7: Cyrptic
         case $location[the defiled nook]: if (item_amount($item[evil eye]) > 0) abox.append("<p>"+cliimg($item[evil eye],"use * evil eye"));
         case $location[the defiled cranny]:
         case $location[the defiled alcove]:
         case $location[the defiled niche]: abox.append("<p><b>"+get_property("cyrpt"+excise(myl,"d ","")+"Evilness")+"</b> evilness left here."); 
            if (equipgood($item[gravy boat])) abox.append("<p>"+cliimg($item[gravy boat],"equip gravy boat")); 
             else if (!have_equipped($item[gravy boat]) && item_amount($item[gravy boat]) == 0 && creatable_amount($item[gravy boat]) > 0)
                abox.append("<p>"+cliimg($item[gravy boat],"create gravy boat")); break;
        // Level 8: Trapper
        // Level 9: Topping
         case $location[the smut orc logging camp]: if (to_int(get_property("chasmBridgeProgress")) >= 30) {
               if (get_property("questL09Topping") == "step1")
                  abox.append("<p><a href='place.php?whichplace=highlands&action=highlands_dude'>Talk to the Highland Lord</a>");
               break;
            }
            int planktot; for i from 5782 to 5784 planktot += item_amount(to_item(i));
            abox.append("<p>You have <b>"+planktot+"</b> of <b>"+rnum(30 - to_int(get_property("chasmBridgeProgress")))+"</b> needed planks. "+
               "<a href=# class='clilink' title='place.php?whichplace=orc_chasm&action=bridge"+get_property("chasmBridgeProgress")+"'>chasm</a>");
            planktot = 0; for i from 5785 to 5787 planktot += item_amount(to_item(i));
            abox.append("<br>You have <b>"+planktot+"</b> of <b>"+rnum(30 - to_int(get_property("chasmBridgeProgress")))+"</b> needed fasteners.");
            foreach i in $items[loadstone, logging hatchet] if (equipgood(i)) abox.append("<p>"+cliimg(i,"equip "+i));
            if (item_amount($item[smut orc keepsake box]) > 0) abox.append("<p>"+cliimg($item[smut orc keepsake box],"use smut orc keepsake box")); break;
         case $location[a-boo peak]: if (item_amount($item[a-boo clue]) > 0) abox.append("<p><a href=adventure.php?snarfblat=296 class='cliimglink through' title='restore hp; use a-boo clue'><img src='/images/itemimages/map.gif' class=hand></a> "+
           "("+rnum(item_amount($item[a-boo clue]))+") <a href=# class='clilink'>maximize spooky res, cold res, 0.01 hp -tie</a>"); 
            abox.append("<p>Hauntedness remaining: <b>"+get_property("booPeakProgress")+"</b>"); break;
         case $location[twin peak]: int tpprog = to_int(get_property("twinPeakProgress")); if (tpprog < 8) abox.append("<br>");
            if ((tpprog & 1) == 0) abox.append("<br><b>Stench res:</b> "+rnum(numeric_modifier("Stench Resistance"))+"/4 needed"+
               (numeric_modifier("Stench Resistance") < 4 ? " <a href=# class='clilink'>maximize stench res, -tie</a>" : ""));
            if ((tpprog & 2) == 0) abox.append("<br><b>Food drops:</b> "+rnum(foodDrop())+"/50 needed"+
               (foodDrop() < 50 ? " <a href=# class='clilink'>maximize 1.1 food drop, items, -tie</a>"+
                (get_property("friarsBlessingReceived") == "false" ? " <a href=# class='clilink'>friars food</a>" : "") : ""));
            if ((tpprog & 4) == 0) abox.append("<br>You <b>"+(item_amount($item[jar of oil]) == 0 ? "lack" : "have")+"</b> a jar of oil."+
               (item_amount($item[jar of oil]) == 0 ? 
               (creatable_amount($item[jar of oil]) > 0 ? " <a href=# title='create jar of oil' class='clilink'>create</a>" : 
               " <a href='adventure.php?snarfblat=298' class='clilink through' title='conditions clear; conditions add 1 jar of oil'>Oil Peak (1)</a>") : ""));
            if (tpprog == 7) abox.append("<br><b>Initiative:</b> "+rnum(numeric_modifier("Initiative"))+"/40 needed"+
               (numeric_modifier("Initiative") < 40 ? " <a href=# class='clilink'>maximize init, -tie</a>" : ""));
            if (item_amount($item[rusty hedge trimmers]) > 0) abox.append("<p>"+cliimg($item[rusty hedge trimmers],"use rusty hedge trimmers")); break;
         case $location[oil peak]: abox.append("<p>Pressure remaining: <b>"+get_property("oilPeakProgress")+"</b> ("+ceil(to_float(get_property("oilPeakProgress"))/6.34)+" slicks)");
            if (equipgood($item[dress pants])) abox.append("<p>"+cliimg($item[dress pants],"equip dress pants"));
            if (item_amount($item[jar of oil]) == 0 && (to_int(get_property("twinPeakProgress")) & 4) == 0) {
               if (creatable_amount($item[jar of oil]) > 0) abox.append("<p>"+cliimg($item[jar of oil],"create 1 jar of oil"));
                else abox.append("<p>You have <b>"+item_amount($item[bubblin' crude])+" / 12</b> bubblin' crude towards your jar of oil.");
            } break;
        // Level 10: Garbage
         case $location[the penultimate fantasy airship]: abox.append(delaybit(myl,20,"you can find all the Immateria (5 per Immaterium)")); break;
         case $location[the castle in the clouds in the sky (basement)]: if (get_property("lastCastleGroundUnlock").to_int() == my_ascensions()) break;
            foreach i in $items[amulet of extreme plot significance, titanium assault umbrella] if (equipgood(i))
               abox.append("<p>"+cliimg(i,"equip "+to_slot(i)+" "+i)); break;
         case $location[the castle in the clouds in the sky (ground floor)]: abox.append(delaybit(myl,10,"you unlock the top floor")); break;
         case $location[the hole in the sky]: abox.append("<p><table style='padding: 0'><tr><th align='center'><img src='/images/itemimages/starchart.gif' border=0><br>"+rnum(item_amount($item[star chart]))+
            "</th><th align='center'><img src='/images/itemimages/star.gif' border=0><br>"+rnum(item_amount($item[star]))+"</th><th align='center'><img src='/images/itemimages/line.gif' border=0><br>"+rnum(item_amount($item[line]))+"</th></tr>");
            foreach i in $items[richard's star key, star hat, star sword, star crossbow] if (have_item(i) == 0) abox.append("<tr><td>"+
              (creatable_amount(i) > 0 ? "<a href=# class='cliimglink' title=\"create 1 "+i+"\"><img src='/images/itemimages/"+i.image+"' class=hand></a>" : "<img src='/images/itemimages/"+i.image+"' title=\""+i+"\" border=0 class=dimmed>")+
               "</td><td align=center>"+get_ingredients(i)[$item[star]]+"</td><td align=center>"+get_ingredients(i)[$item[line]]+"</td></tr>");
            abox.append("</table>"); break;
        // Level 11: MacGuffin
         case $location[the black forest]: abox.append("<p>Black locations discovered: <b>"+get_property("blackForestProgress")+" / 5</b>");
            if (equipgood($item[blackberry galoshes])) abox.append(cliimg($item[blackberry galoshes],"equip acc3 blackberry galoshes"));
            break;
         case $location[the hidden bowling alley]: if (get_property("hiddenTavernUnlock").to_int() == my_ascensions() && 
               item_amount($item[bowl of scorpions]) == 0 && my_meat() >= 500) 
            abox.append("<p>"+cliimg($item[bowl of scorpions],"buy bowl of scorpions")); break;
         case $location[the hidden hospital]: int doctot; abox.append("<p>");
            foreach i in $items[half-size scalpel, head mirror, surgical mask, surgical apron, bloodied surgical dungarees] if (have_equipped(i)) doctot += 1;
             else if (equipgood(i)) abox.append(cliimg(i,"equip "+(i == $item[surgical mask] ? "acc2" : to_slot(i))+" "+i)+" ");
            abox.append("<b>"+rnum(doctot)+" / 5</b> Doctorosity");
            break;
         case $location[inside the palindome]: if (!qprop("questL11Palindome")) abox.append("<p><b>"+get_property("palindomeDudesDefeated")+" / 5</b> dudes defeated.");
            break;
         case $location[a mob of zeppelin protesters]: int zeptot = (have_effect($effect[musky]) == 0) ? 0 : 3;
            abox.append("<p>You have scared away <b>"+get_property("zeppelinProtestors")+"</b> of <b>80</b> protesters.<p>");
            foreach i in $items[lynyrdskin cap, lynyrdskin tunic, lynyrdskin breeches] if (have_equipped(i)) zeptot += 5;
             else if (equipgood(i)) abox.append(cliimg(i,"equip "+to_slot(i)+" "+i)+"");
            if (item_amount($item[lynyrd musk]) > 0 && have_effect($effect[musky]) == 0) abox.append(cliimg($item[lynyrd musk],"use lynyrd musk"));
            if (item_amount($item[bomb of unknown origin]) == 0 && creatable_amount($item[bomb of unknown origin]) > 0) abox.append(cliimg($item[bomb of unknown origin],"create bomb of unknown origin"));
            abox.append("<p>Lynyrd: <b>"+zeptot+"</b> (scare "+rnum(3+zeptot)+" away)");
            zeptot = numeric_modifier("Sleaze Damage") + numeric_modifier("Sleaze Spell Damage");
            abox.append("<br>Sleaze: <b>"+rnum(zeptot)+"</b> (scare "+max(3,ceil(zeptot**0.5))+" away) <a href=# class=clilink>maximize sleaze damage, sleaze spell damage, -tie</a>");
            abox.append("<br>Flaming Whatshisnames: <b>"+item_amount($item[Flamin' Whatshisname])+"</b>");
            break;
         case $location[the arid, extra-dry desert]: abox.append("<p>The desert is <b>"+get_property("desertExploration")+"%</b> explored.");
            if (have_effect($effect[ultrahydrated]) == 0)
               abox.append("<p>"+cliimg($item[personal raindrop],"adv 1 oasis")+" WARNING: NOT ULTRAHYDRATED");
            if (equipgood($item[uv-resistant compass])) abox.append("<p>"+cliimg($item[uv-resistant compass],"equip uv-resistant compass")); break;
        // Level 12: IsleWar
         case $location[The Battlefield (Frat Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("hippiesDefeated")))+"</b> hippies left."); 
            if (item_amount($item[stuffing fluffer]) > 0) abox.append(cliimg($item[stuffing fluffer],"use stuffing fluffer")); break;
         case $location[The Battlefield (Hippy Uniform)]: abox.append("<p>Just <b>"+(1000-to_int(get_property("fratboysDefeated")))+"</b> fratboys left."); 
            if (item_amount($item[stuffing fluffer]) > 0) abox.append(cliimg($item[stuffing fluffer],"use stuffing fluffer")); break;
         case $location[The Filthworm Queen's Chamber]:
            if (have_outfit("Frat Warrior")) abox.append("<p><a href='bigisland.php?place=orchard&action=stand&pwd="+my_hash()+"' class='clilink through' title='checkpoint; outfit frat warrior fatigues'>visit stand as frat</a>");
            if (have_outfit("War Hippy")) abox.append("<p><a href='bigisland.php?place=orchard&action=stand&pwd="+my_hash()+"' class='clilink through' title='checkpoint; outfit war hippy fatigues'>visit stand as hippy</a>"); break;
         case $location[Next to that Barrel with Something Burning in it]:
         case $location[Near an Abandoned Refrigerator]:
         case $location[Over Where the Old Tires Are]:
         case $location[Out By that Rusted-Out Car]: if (get_property("currentJunkyardTool") == "") {
               if (have_outfit("Frat Warrior")) abox.append("<p><a href='bigisland.php?place=junkyard' class='clilink through' title='checkpoint; outfit frat warrior; bigisland.php?action=junkman&pwd=; outfit checkpoint'>visit Yossarian as frat</a>");
               if (have_outfit("War Hippy")) abox.append("<p><a href='bigisland.php?place=junkyard' class='clilink through' title='checkpoint; outfit war hippy; bigisland.php?action=junkman&pwd=; outfit checkpoint'>visit Yossarian as hippy</a>");
            } break;
        // Level 13: Lair
         case $location[fastest adventurer contest]: abox.append("<p><b>"+get_property("nsContestants1")+"</b> contestants remaining."); break;
         case $location[strongest adventurer contest]: 
         case $location[smartest adventurer contest]: 
         case $location[smoothest adventurer contest]: abox.append("<p><b>"+get_property("nsContestants2")+"</b> contestants remaining."); break;
         case $location[hottest adventurer contest]: 
         case $location[coldest adventurer contest]: 
         case $location[spookiest adventurer contest]: 
         case $location[stinkiest adventurer contest]: 
         case $location[sleaziest adventurer contest]: abox.append("<p><b>"+get_property("nsContestants3")+"</b> contestants remaining."); break;
        // Spookyraven
         case $location[the haunted ballroom]: if (item_amount($item[dance card]) > 0 && get_counters("Dance Card",0,5) == "") 
            abox.append("<p>"+cliimg($item[dance card],"use dance card")); break;
         case $location[the haunted billiards room]: if (item_amount($item[7302]) > 0) break;   // library key
            int poolishness = min(10,floor(2*square_root(to_float(get_property("poolSharkCount"))))) + (min(my_inebriety(),10) - 
               max(0,my_inebriety() - 10)*2) + to_int(numeric_modifier("Pool Skill")) + to_int(get_property("poolSkill"));
            abox.append("<p>You have <b>"+rnum(poolishness)+"</b> pool skill.<ul><li>Pool sharkiness: <b>"+min(10,floor(2*square_root(to_float(get_property("poolSharkCount")))))+
               "</b></li><li>Drunkenness: <b>"+rnum(min(my_inebriety(),10) - max(0,my_inebriety() - 10)*2)+"</b></li><li>Practicing: <b>"+get_property("poolSkill")+
               "</b></li><li>Equipment/buffs: <b>"+rnum(to_float(numeric_modifier("Pool Skill")))+"</b>");
            if (item_amount($item[handful of hand chalk]) > 0 && have_effect($effect[chalky hand]) == 0)
               abox.append("<p><a href=# class='clilink' title='use hand chalk'>use hand chalk</a>");
            if (true) abox.append(" <a href=# class='clilink'>maximize pool skill, -tie</a>");  // TODO: should be spec check
            abox.append("</li></ul>"); break;
         case $location[the haunted kitchen]: if (item_amount($item[Spookyraven billiards room key]) > 0) break;
            abox.append("<p>You have opened <b>"+get_property("manorDrawerCount")+" / 21</b> drawers.");
            abox.append("<p>You will open <b>"+rnum(minmax(max(numeric_modifier("Hot Resistance"), numeric_modifier("Stench Resistance"))/3,1,4))+"</b> drawers per fight.<p>");
            foreach tores in $elements[hot, stench] abox.append("<b>"+tores+" res:</b> "+rnum(numeric_modifier(tores+" Resistance"))+
               " <a href=# class='clilink'>maximize "+tores+" res, -tie</a><br>"); break;
         case $location[the haunted library]: if (get_property("writingDesksDefeated").to_int() < 5)
            abox.append("<p>You have defeated <b>"+get_property("writingDesksDefeated")+" / 5</b> writing desks.");
         case $location[the haunted gallery]: abox.append(delaybit(myl,5,"you can enter the Louvre")); break;
         case $location[the haunted bathroom]: abox.append(delaybit(myl,5,"you can find the cosmetics wraith")); break;
         case $location[the haunted bedroom]: abox.append(delaybit(myl,5,"you can fight elegant nightstands")); break;
         
         case $location[barrrney's barrr]: int insultsknown; for n from 1 to 8 if (get_property("lastPirateInsult"+n) == "true") insultsknown += 1;
            if (insultsknown < 8) abox.append("<p>You know <b>"+insultsknown+"</b> insults."); break;
         case $location[the dungeons of doom]: if (item_amount($item[large box]) + item_amount($item[small box]) > 0) {
              abox.append("<p><div style='margin: 3px; float:right'>");
              foreach bx in $items[large box, small box] if (item_amount(bx) > 0) abox.append(" "+cliimg(bx,"use 1 "+bx));
              abox.append("</div>");
            }
            abox.append("<p>"); for i from 819 to 827 abox.append(to_item(i)+(item_amount(to_item(i)) > 0 ? " ("+item_amount(to_item(i))+")" : "")+": "+
            (($strings[blessing, detection, mental acuity, ettin strength, teleportitis] contains get_property("lastBangPotion"+i)) ? "<b>"+get_property("lastBangPotion"+i)+"</b>" : get_property("lastBangPotion"+i))+"<br>"); break;
         case $location[The Valley of Rof L'm Fao]: abox.append(delaybit(myl,5,"you can fight RAMs")); break;
        // Path-specific
         case $location[The Secret Council Warehouse]: abox.append("<p><b>"+get_property("warehouseProgress")+" / 40</b> explorations complete."); break;
         case $location[Super Villain's Lair]: abox.append("<p><b>"+get_property("_villainLairProgress")+" / 60</b> minions defeated.");
            if (item_amount($item[can of Minions-Be-Gone]) > 0) abox.append("<p>"+cliimg($item[can of Minions-Be-Gone],"use can of Minions-Be-Gone")+" ("+rnum(item_amount($item[can of Minions-Be-Gone]))+")");
            if (!get_property("_villainLairColorChoiceUsed").to_boolean() && get_property("_villainLairColor") != "") 
               abox.append("<p>You should press the <b>"+get_property("_villainLairColor")+"</b> button."); break;
        // Airport
         case $location[The Fun-Guy Mansion]: if (qprop("questESlAudit < 0") || qprop("questESlAudit")) break;
            abox.append("<p>You have retrieved <b>"+item_amount($item[Taco Dan's Taco Stand's Taco Receipt])+" / 10</b> taco receipts.");
            if (item_amount($item[sleight-of-hand mushroom]) > 0 && have_effect($effect[sleight of mind]) == 0)
               abox.append("<p>"+cliimg($item[sleight-of-hand mushroom],"use sleight-of-hand mushroom"));
            break;
         case $location[The Sunken Party Yacht]: if (qprop("questESlFish < 0") || qprop("questESlFish")) break;
            abox.append("<p>You have retrieved <b>"+get_property("tacoDanFishMeat")+" / 300</b> pounds of fish meat.");
            break;
         case $location[the bubblin' caldera]: abox.append("<p>You have <b>"+rnum(item_amount($item[superheated metal]))+"</b> superheated metal."); break;
        // Guild/Nemesis
         case $location[the "fun" house]: // first, links to make the LEW so that you don't have to keep looking up the friggin' name
            if (item_amount($item[distilled seal blood]) > 0) abox.append("<p>"+cliimg($item[hammer of smiting],"unequip Bjorn Hammer; create 1 Hammer of Smiting"));
            if (item_amount($item[turtle chain]) > 0) abox.append("<p>"+cliimg($item[chelonian morningstar],"unequip Mace of the Tortoise; create 1 Chelonian Morningstar"));
            if (item_amount($item[high-octane olive oil]) > 0) abox.append("<p>"+cliimg($item[greek pasta spoon of peril],"unequip Pasta Spoon of Peril; create 1 Greek Pasta Spoon of Peril"));
            if (item_amount($item[peppercorns of power]) > 0) abox.append("<p>"+cliimg($item[17-alarm saucepan],"unequip 5-alarm saucepan; create 1 17-alarm Saucepan"));
            if (item_amount($item[vial of mojo]) > 0) abox.append("<p>"+cliimg($item[shagadelic disco banjo],"unequip disco banjo; create 1 Shagadelic Disco Banjo"));
            if (item_amount($item[golden reeds]) > 0) abox.append("<p>"+cliimg($item[squeezebox of the ages],"unequip Rock and Roll Legend; create 1 Squeezebox of the Ages"));
            if (qprop("questG04Nemesis > 5")) break; 
            abox.append(delaybit(myl,10,"you can fight the Clownlord"));
            abox.append("<p>");    // next, help with amassing clownosity
            if (numeric_modifier("Clownosity") < 4) foreach i in $items[431,432,434,435,448,449,2233,2475,2476,2477,2478,2485] if (equipgood(i))
               abox.append(cliimg(i,"equip "+(i == $item[big red clown nose] ? "acc2" : to_slot(i))+" "+i)+" ");
               abox.append("<p>Clownosity: <b>"+rnum(numeric_modifier("Clownosity"))+" / 4</b>"); break;
         case $location[the road to the white citadel]: abox.append("<p>Burnouts defeated: <b>"+get_property("burnoutsDefeated")+"</b>");
            if (item_amount($item[opium grenade]) == 0 && creatable_amount($item[opium grenade]) > 0)
               abox.append("<p>"+cliimg($item[opium grenade],"create opium grenade")); break;
         case $location[Outside the Club]: if (!have_skill($skill[break it on down])) abox.append("<p>You need <b>Break It On Down</b> from the breakdancing raver.");
            if (!have_skill($skill[pop and lock it])) abox.append("<p>You need <b>Pop and Lock It</b> from the pop-and-lock raver.");
            if (!have_skill($skill[run like the wind])) abox.append("<p>You need <b>Run Like the Wind</b> from the running man."); abox.append("<p>");
            if (numeric_modifier("Raveosity") < 7) foreach i in $items[2073,2287,2443,2838,2952,3218,3873,4193,4194,4195,4428,4429,4430] if (equipgood(i) && available_amount(i) + creatable_amount(i) > 0)
               abox.append(cliimg(i,"equip "+(i == $item[big red clown nose] ? "acc2" : to_slot(i))+" "+i)+" ");
            abox.append("<p>Raveosity: <b>"+rnum(numeric_modifier("Raveosity"))+" / 7</b>"); break;
         case $location[the outer compound]: abox.append("<p><b>"+get_property("guardTurtlesFreed")+" / 6</b> guard turtles freen."); break;
        // Miscellaneous
         case $location[the electric lemonade acid parade]: abox.append("<p>You have <b>"+have_effect($effect[in your cups])+
            "</b> turns of In Your Cups. <a href=# class='clilink' title='ashq visit_url(\"inv_use.php?pwd="+my_hash()+"&whichitem=4613&teacups=1&ajax=1\");'>increase</a>"); break;
         case $location[The X-32-F Combat Training Snowman]: abox.append("<p>Free fights remaining: <b>"+rnum(10 - get_property("_snojoFreeFights").to_int())+"</b>"); break;
         case $location[neckback crick]: if (equipgood($item[blackberry galoshes])) abox.append("<p>"+cliimg($item[blackberry galoshes],"equip acc3 blackberry galoshes")); break;
        // Under the Sea
         case $location[Anemone Mine]: if (equipgood($item[Mer-kin digpick])) abox.append("<p>"+cliimg($item[mer-kin digpick],"equip mer-kin digpick")); break;
         case $location[An Octopus's Garden]: if (item_amount($item[glob of green slime]) > 0 && item_amount($item[soggy seed packet]) > 0 &&
               equipgood($item[straw hat])) abox.append("<p>"+cliimg($item[straw hat],"equip straw hat"));
            if (equipgood($item[octopus's spade])) abox.append("<p>"+cliimg($item[octopus's spade],"equip octopus's spade")); break;
         case $location[The Coral Corral]: if (get_property("lassoTraining") != "expertly") abox.append("<p><img src='/images/itemimages/lasso.gif' height=20 width=20 border=0> "+get_property("lassoTraining"));
            abox.append("<p>"+cliimg($item[sea cowbell],"buy sea cowbell")+" <b>"+item_amount($item[sea cowbell])+"</b> of <b>3</b><br>");
            abox.append(cliimg($item[sea lasso],"buy sea lasso")+" <b>"+item_amount($item[sea lasso])+"</b> of <b>1</b>"); break;
         case $location[Mer-kin Library]: abox.append("<p><b>Dreadscroll clues:</b> <a href=inv_use.php?pwd="+my_hash()+"&which=3&whichitem=6353 class='clilink through' title='print Making a guess...'>guess</a><small><ul>"); int cluenum;
            foreach s in $strings[Card catalog, Use healscroll, Deep Dark Visions, Use knucklebone, Use killscroll, Card catalog, Sushi with worktea, Card catalog] {
               cluenum += 1;
               abox.append("<li>"+(get_property("dreadScroll"+cluenum) == "0" ? s : "<span class=dimmed>"+s+": "+get_property("dreadScroll"+cluenum)+"</span>")+"</li>");
            }
            abox.append("</ul></small>");
         case $location[Mer-kin Elementary School]: abox.append("<p>Vocabulary skill: <b>"+get_property("merkinVocabularyMastery")+"</b>"); 
            if (get_property("merkinVocabularyMastery").to_int() < 100 && item_amount($item[mer-kin wordquiz]) > 0 && item_amount($item[mer-kin cheatsheet]) > 0) 
               abox.append(" "+cliimg($item[mer-kin wordquiz],"use 1 mer-kin wordquiz")); break;
         case $location[mer-kin colosseum]: if (equipgood(next_w()))
            abox.append("<p><b>Prepare</b> for next monster: "+cliimg(next_w(),"equip "+next_w())); break;
        // batfellow
         case $location[gotpork conservatory of flowers]: abox.append("<p>Gain <b>Bat-Health regeneration</b> from the vicious plant creature.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[glob of bat-glue],"wiki glob of bat-glue")+" ("+item_amount($item[glob of bat-glue])+")"); 
            abox.append("<br>Gain 50% exploration with: 3 x "+cliimg($item[fingerprint dusting kit],"wiki fingerprint dusting kit")+" ("+item_amount($item[fingerprint dusting kit])+")"); break;
         case $location[gotpork municipal reservoir]: abox.append("<p>Gain <b>increased Bat-Health</b> from the giant mosquito.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[Bat-Aid&trade; bandage],"wiki bat-aid bandage")+" ("+item_amount($item[Bat-Aid&trade; bandage])+")"); 
            abox.append("<br>Gain 50% exploration with: 3 x "+cliimg($item[ultracoagulator],"wiki ultracoagulator")+" ("+item_amount($item[ultracoagulator])+")"); break;
         case $location[gotpork gardens cemetery]: abox.append("<p>Gain <b>Bat-Armor</b> from the walking skeleton.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[bat-bearing],"wiki bat-bearing")+" ("+item_amount($item[bat-bearing])+")"); 
            abox.append("<br>Gain 50% exploration with: 3 x "+cliimg($item[exploding kickball],"wiki exploding kickball")+" ("+item_amount($item[exploding kickball])+")"); break;
         case $location[porkham asylum]: abox.append("<p>Gain <b>Bat-Bulletproofing</b> from the former guard.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[bat-o-mite],"wiki bat-o-mite")+" ("+item_amount($item[bat-o-mite])+")"); break;
         case $location[gotpork city sewers]: abox.append("<p>Gain <b>Bat-Stench Resistance</b> from the plumber's helper.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[bat-oomerang],"wiki bat-oomerang")+" ("+item_amount($item[bat-oomerang])+")"); break;
         case $location[the old gotpork library]: abox.append("<p>Gain <b>Bat-Spooky Resistance</b> from the very [adj] henchman.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[bat-jute],"wiki bat-jute")+" ("+item_amount($item[bat-jute])+")"); break;
         case $location[gotpork clock, inc.]: abox.append("<p>Gain <b>Bat-Minutes</b> from the time bandit.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[exploding kickball],"wiki exploding kickball")+" ("+item_amount($item[exploding kickball])+")"); break;
         case $location[gotpork foundry]: abox.append("<p>Gain <b>Bat-Hot Resistance</b> from the burner.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[ultracoagulator],"wiki ultracoagulator")+" ("+item_amount($item[ultracoagulator])+")"); break;
         case $location[trivial pursuits, LLC]: abox.append("<p>Gain <b>Investigation Progress</b> from the first inquisitee.");
            abox.append("<br>Gain 25% exploration with: "+cliimg($item[fingerprint dusting kit],"wiki fingerprint dusting kit")+" ("+item_amount($item[fingerprint dusting kit])+")"); break;
        // Psychoses
         case $location[anger man's level]: abox.append("<p><b>"+rnum(numeric_modifier("Hot Resistance"))+" Hot Resistance</b> (<span style='color:red'><b>"+
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
        // grimstone: witch
         case $location[sweet-ade lake]: abox.append("<p>Deal <b>cold</b> damage to <b>piranhas</b> to gain more <b>Moat</b>."); break;
         case $location[eager rice burrows]: abox.append("<p>Deal <b>sleaze</b> damage to <b>weasels</b> to gain more <b>Mine</b>."); break;
         case $location[gumdrop forest]: abox.append("<p>Deal <b>hot</b> damage to <b>pixies</b> to gain more <b>Turret</b>.");
            abox.append("<br>Deal <b>stench</b> damage to <b>snakes</b> to gain more <b>Poison</b>.");
            abox.append("<br>Deal <b>spooky</b> damage to <b>trees</b> to gain more <b>Wall</b>."); break;
      }
      if (my_location().environment == "underwater" && get_property("dolphinItem") != "") abox.append("<p><img src='/images/itemimages/"+to_item(get_property("dolphinItem")).image+"' title=\""+
         to_item(get_property("dolphinItem"))+" ("+rnum(sell_val(to_item(get_property("dolphinItem"))))+"&mu;)\" height=23 width=23 border=0> <a href=# class='clilink'>use dolphin whistle</a>");
      switch (myl.zone) {
         case "The Sea": boolean popped;
            foreach w in $items[mer-kin dodgeball, mer-kin dragnet, mer-kin switchblade] if (have_equipped(w) && wskils(w) < 3) {
               popped = true; abox.append("<p>You have learned <b>"+wskils(w)+"</b> of <b>3</b> "+w+" skills."); break;
            }
            if (!popped) foreach w in $items[mer-kin dodgeball, mer-kin dragnet, mer-kin switchblade] if (!have_equipped(w) && wskils(w) < 3) {
               if (!popped) { abox.append("<p>"); popped = true; }
               abox.append(" <a href=# class='clilink'>equip "+w+"</a>");
            } break;
         case "KOL High School": abox.append("<p>School's out in <b>"+rnum(40 - to_int(get_property("_kolhsAdventures")))+"</b> turns."); break;
      }
      foreach i in $ints[4178,4179,4180,4181,4182,4183,4191] if (have_equipped(to_item(i)) && get_property("sugarCounter"+i).to_int() > 0)
         abox.append("<p>"+cliimg(to_item(i),"unequip "+to_item(i))+" <b>"+rnum(30 - to_int(get_property("sugarCounter"+i)))+"</b> turns till breakage.");
      float[monster] arq = appearance_rates(myl,true);
      if (count(arq) > 0) {
         int[int] fs; file_to_map("factoids_"+replace_string(my_name()," ","_")+".txt",fs);    // load factoids
         abox.append("<p><table><tr>");
         monster[int] sortm;
         foreach m in arq sortm[count(sortm)] = m;
         sort sortm by -has_goal(value);
         monster goalmon = has_goal(sortm[0]) == 0 ? $monster[none] : sortm[0];
         sort sortm by -arq[value];
         foreach i,m in sortm {
            if (arq[m] <= 0 && !is_banished(m)) continue;
            abox.append("<td align=center valign=top class='queuecell"+(m == goalmon && count(get_goals()) > 0 ? " goalmon" : "")+(been_banished(m) ? " dimmed" : "")+
               "'><a href=# class='cliimglink' title=\"wiki "+(m == $monster[none] ? to_string(myl) : m)+
               "\"><img src='/images/adventureimages/"+(m == $monster[none] ? "3doors.gif" : m.image == "" ? "question.gif" : m.image)+
               "' title=\""+(m == $monster[none] ? "Noncombat" : entity_encode(m)+(been_banished(m) ? " (banished)" : "")+
               (has_goal(m) > 0 ? " (goals: "+rnum(has_goal(m))+")" : ""))+"\" height=50 width=50></a>");
            if (m == $monster[none] || m.boss) abox.append("<p>"); 
            else if (count(arq) > 1 && !($locations[mer-kin colosseum, the slime tube, oil peak, the daily dungeon, The Mansion of Dr. Weirdeaux] contains myl) && !($strings[Dreadsylvania, Volcano] contains myl.zone)) {
               abox.append("<br><a href=# class='cliimglink"+(is_set_to(m,"attract") ? "" : " dimmed")+"' title=\"zlib BatMan_attract = "+
                  (is_set_to(m,"attract") ? list_remove(getvar("BatMan_attract"),m) : list_add(getvar("BatMan_attract"),m))+
                  "\"><img src='/images/itemimages/uparrow.gif' height='16' width='16' title=\"Click to "+
                  (is_set_to(m,"attract") ? "stop attracting "+m+" (remove from BatMan_attract)." : "attract "+m+" (add to BatMan_attract).")+"\"></a>");
               abox.append("<a href=# class='cliimglink"+(is_set_to(m,"banish") ? "" : " dimmed")+"' title=\"zlib BatMan_banish = "+
                  (is_set_to(m,"banish") ? list_remove(getvar("BatMan_banish"),m) : list_add(getvar("BatMan_banish"),m))+
                  "\"><img src='/images/itemimages/downarrow.gif' height='16' width='16' title=\"Click to "+
                  (is_set_to(m,"banish") ? "stop banishing "+m+" (remove from BatMan_banish)." : "banish "+m+" (add to BatMan_banish).")+"\"></a>");
            }
            abox.append("<br>"+rnum(max(0,arq[m]),1)+"%");
            if (count(fs) > 0 && fs[m.id] > 0) {     // display factoids known
               abox.append("<br><a href='relay_Factroid.ash' title='Factroid!' style='text-decoration: none'>");
               for i from 1 upto fs[m.id] abox.append(" &bull; "); 
               abox.append("</a>");
            }
            if (kadrop(m) > 0) abox.append("<br><b>"+rnum(kadrop(m))+"</b> <img src='/images/itemimages/kacoin.gif' height='14' width='14' title='Ka coin'>");
            abox.append("</td>");
         }
         abox.append(clover_string(myl));
         abox.append("</tr></table>");
      }
      switch (my_class()) {
         case $class[avatar of boris]: if (!have_skill($skill[banishing shout]) || get_property("banishingShoutMonsters") == "") break;
            abox.append("<p><b>Banished:</b>\n<ul>");
            foreach i,s in split_string(get_property("banishingShoutMonsters"),"\\|") abox.append("<li>"+normalized(s,"monster")+"</li>");
            abox.append("</ul>"); break;
         case $class[avatar of jarlsberg]: if (get_property("_jiggleCheesedMonsters") == "") break;
            abox.append("<p><b>Banished:</b>\n<ul>");
            foreach i,s in split_string(get_property("_jiggleCheesedMonsters"),"\\|") abox.append("<li>"+normalized(s,"monster")+"</li>");
            abox.append("</ul>"); break;
         case $class[avatar of sneaky pete]: if (have_skill($skill[make friends]) && get_property("makeFriendsMonster") != "")
               abox.append("<p>Make Friends monster: "+get_property("makeFriendsMonster"));
            if (!have_skill($skill[peel out])) break;
            abox.append("<p>Peel Outs remaining: <b>");
            abox.append(rnum(10 + (get_property("peteMotorbikeTires") == "Racing Slicks" ? 20 : 0) - to_int(get_property("_petePeeledOut")))+"</b>");
            break;
         case $class[ed]: boolean[servant] svs; foreach s in $servants[] if (have_servant(s)) svs[s] = (my_servant() == s);
            if (count(svs) < 2) break;
            abox.append("<p><b>Servant selection:</b><p>");
            foreach s,mine in svs abox.append("<a href=# class='cliimglink' title='servant "+s+"'><img src='/images/itemimages/"+s.image+"' class="+
               (mine ? "hand" : "dimmed")+" title='"+(mine ? "Your "+s+" is hard at" : "Put your "+s+" to")+" work.'></a>");
      }
      if (count(get_goals()) == 0) abox.append("<p>All goals met. <a href='#' class='clilink edit' title='conditions set'>add goals</a>");
       else {
          float gturns = turns_till_goals(false);
          abox.append("<p><b>Goals remaining"+(gturns < 9999 ? " (satisfied in <b>~"+rnum(max(1.0,gturns))+"</b> turns)" : "")+":</b>"+
             " <a href='#' class='clilink edit' title='conditions set'>add goals</a> <a href=# class='clilink' title='conditions clear'>clear</a>\n");
          abox.append("<div style='float: right; margin: 3px'><a href=# class='cliimglink' title=\"adventure * "+myl.replace_string("\"","")+
             "\"><img src='images/otherimages/sigils/recyctat.gif' height=30 width=30 title='Automate goal acquisition (approx. "+rnum(gturns)+" turns)'></a></div>\n<ul>");
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
       if (my_location().environment != "none" && florist_available()) {
          string[string] plantimgs;
          plantimgs[""] = "noplant";
          foreach p in $strings[Rabid Dogwood, Rutabeggar, Rad-ish Radish, Artichoker, Smoke-ra, Skunk Cabbage, Deadly Cinnamon, Celery Stalker,
             Lettuce Spray, Seltzer Watercress, War Lily, Stealing Magnolia, Canned Spinach, Impatiens, Spider Plant, Red Fern, BamBOO!, Arctic Moss,
             Aloe Guv'nor, Pitcher Plant, Blustery Puffball, Horn of Plenty, Wizard's Wig, Shuffle Truffle, Dis Lichen, Loose Morels, Foul Toadstool, 
             Chillterelle, Portlybella, Max Headshroom, Spankton, Kelptomaniac, Crookweed, Electric Eelgrass, Duckweed, Orca Orchid, Sargassum, 
             Sub-Sea Rose, Snori, Up Sea Daisy]
           plantimgs[p] = "plant"+count(plantimgs);
          abox.append("\n<p>");
          foreach i,s in get_florist_plants()[my_location()] abox.append(" <a href='place.php?whichplace=forestvillage&action=fv_friar'><img src='/images/otherimages/friarplants/"+
             plantimgs[s]+".gif' height=55 width=29 title=\""+(s == "" ? "Plant something in "+my_location() : s)+"\"></a>");
       }
       if (myl.zone == "Psychoses" && svn_exists("psychoseamatic")) abox.append("<p><a href='relay_Psychose-a-Matic.ash'>Back to Psychose-a-Matic</a>");
       if (svn_exists("omniquest")) abox.append("<p><a href='relay_OmniQuest.ash'>Back to OmniQuest</a>");
      abox.write();
      exit;
     case "sera":  // semirare helper
      buffer sbox;
      int offset = -to_int(to_int(post["turnflag"]) == total_turns_played());
      if (offset != 0) print("Adjusting counters by an offset of "+offset);
      if (get_counters("Semirare window begin",0+offset,6+offset) != "") sbox.append("<p><span style='font-weight: bold; font-size: 3.0em'>"+narrowdown("Semirare window begin",offset)+" </span> turns until your semirare window.");
       else if (get_counters("Fortune Cookie",1+offset,6+offset) != "") sbox.append("<p><span style='font-weight: bold; font-size: 3.0em'>"+narrowdown("Fortune Cookie",offset)+" </span> turns until your semirare!");
       else if (get_counters("Fortune Cookie",0+offset,0+offset) != "") sbox.append("<p>Time to get your semirare!");
      if (get_counters("Fortune Cookie",0+offset,220+offset) == "" && my_fullness() < fullness_limit() && can_eat())
         sbox.append("<p><a href=# class='cliimglink' title='eatsilent fortune cookie'><img src='/images/itemimages/fortune.gif' class=hand></a>");
      sbox.append(seratable());
      sbox.write();
      exit;
     case "wicky":  // wiki tab
      buffer wbox;
      string wickypage = to_upper_case(substring(last_monster(),0,1))+to_lower_case(replace_string(substring(last_monster(),1)," ","_"));  // This Format => This_format
      wickypage = visit_url("http://kol.coldfront.net/thekolwiki/index.php?search="+url_encode(wickypage)+"&title=Special:Search&go=Go");
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
   if (post contains "enabletoggle") {
      vars["BatMan_RE_enabled"] = post["enabletoggle"] == "on";
      updatevars();
   }
}
string witchesshelper() {
   buffer res;
   res.append("<div style='margin: 0 auto; text-align: center'>");
   monster wm;
   for i from 1935 to 1942 {
      wm = to_monster(i);
      res.append("<div style='float: left'><a href='choice.php?option=1&pwd="+my_hash()+"&whichchoice=1182&piece="+i);
      res.append("' class='cliimglink through' title='ashq visit_url(\"campground.php?action=witchess\"); "+
         "visit_url(\"choice.php?pwd="+my_hash()+"&whichchoice=1181&option=1\");'><img src='/images/adventureimages/"+wm.image+
         "' width=70 height=70 title='Fight a "+wm+"'></a><br>");
      foreach it in item_drops(wm) res.append(cliimg(it,"wiki "+it));
      res.append("</div>");
   }
   res.append("</div>");
   return res.to_string();
}

void add_features() {
   if (!to_boolean(getvar("BatMan_RE_enabled"))) {
      vprint("BatMan RE disabled for this character, skipping enhancements.",4);
        results.replace_string("Run Away\"></td></tr></form>","Run Away\"></form><p><form name=enablebatman action=fight.php method=post>"+
        "<input type=hidden name=enabletoggle value=on><input class=button type=submit value='Enable BatMan RE'></td></tr></form>");
      return;
   }
  // add "loading" div
   results.replace_string("</body>", (contains_text(results,"<center><table><a name=\"end\">") && !contains_text(results, "window.fightover = true")) ? 
      "<div id='battab'><ul><li><a href='#bat-enhance'>Actions</a>"+
      "</li><li><a href='#kolformbox' title='Note: non-macro actions are not tracked!'>KoL</a></li><li><a href='#blacklist' class='blacktrigger'>Blacklist</a></li>"+
      "<li><a href='#wikibox' class='wickytrigger'>Wiki</a></li></ul>"+
      "<div id='bat-enhance' class='panel'><a href='fight.php' border=0><img id='compimg' src='images/otherimages/eldritchgrobulator.gif'></a><p>Bat-Computer "+
      "calculating...</div><div id='kolformbox' class='panel'><center>KoL forms here</center></div><div id='blacklist' class='panel'><p>The "+
      "blacklist goes here.</div><div id='wikibox' class='panel'><p><img src='images/itemimages/book5.gif'><p>Consulting the Bat-Monstercyclopedia...</div></div>\n</body>" : 
      "<div id='bat-enhance'></div>\n</body>");   // old Bat-Computer: images/adventureimages/3machines.gif
  // add elements helper
   results.replace_string("</body>","<div id='elementhelper'><img src='/images/kol_elements.gif'></div>\n</body>");      
  // add scripts/stylesheet and set turncount flag
   results.replace_string("</head>", "\n<script src='jquery1.10.1.min.js'></script><script>turncount = "+total_turns_played()+";</script>\n"+
      "<script src='datatables.min.js'></script>\n<script src='clilinks.js'></script>\n<script src='batman.js'></script>\n"+
      "<link rel='stylesheet' type='text/css' href='batman.css'>\n</head>");
  // delete KoL's older version of jQuery
   results.replace_string("<script language=Javascript src=\"/images/scripts/jquery-1.3.1.min.js\"></script>","");
  // add doctype to force IE out of quirks mode
   results.replace_string("<html>", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" "+
      "\"http://www.w3.org/TR/html4/loose.dtd\">\n<html>");
  // fix KoL's CSS
   results.replace_string("right: 1; top: 2;\" id=\"jumptobot","right: 1px; top: 2px;\" id=\"jumptobot");
  // witchess helper
   if (get_property("lastEncounter").contains_text("Witchess") && get_property("_witchessFights").to_int() < 5)
      results.replace_string("Back to Your Witchess Set</a>","Back to Your Witchess Set</a><p>"+witchesshelper());
  // time spinner helper -- add adventure again link
   if (item_drops(last_monster()) contains $item[compounded experience] && get_property("_timeSpinnerMinutesUsed").to_int() < 10)
      results.replace_string("Back to your Inventory</a>","Back to your Inventory</a><p><a href='choice.php?pwd="+my_hash()+
         "&whichchoice=1195&option=3' class='clilinknostyle through' title=\"ashq visit_url('inv_use.php?pwd="+my_hash()+"&whichitem=9104')\">Fight here again ("+
         (10 - get_property("_timeSpinnerMinutesUsed").to_int())+" minutes left)");
  // move KoL combat forms 
   results.replace_string("<table><a name=\"end\">","<a name=\"end\"><table id='kolforms'>");
   matcher kolf = create_matcher("\\<table id='kolforms'\\>.+?\\</table\\>",results);
   if (kolf.find()) {
      string alltheforms = kolf.group(0);
      results.replace_string(alltheforms,"");
      results.replace_string("KoL forms here",alltheforms);
   }
  // enable enhanced Manuel 
  //   results.replace_string("<table><tr><td><div id=monsterpic","<table><tr id='nowfighting'><td><div id=monsterpic");
  //   results.replace_string("<tr><td width=30 valign=top></td><td><div id=monsterpic","<tr id='nowfighting'><td width=30 valign=top></td><td><div id=monsterpic");
   results.replace_string("<td width=30></td><td>","<td width=30></td><td id='manuelcell'>");
}
setvar("BatMan_RE_enabled",true);       // this setting is used to enable/disable the script per character
void main() {
   handle_post();
  // 100% run enforcement
   if (to_familiar(getvar("is_100_run")) != $familiar[none] && my_familiar() != to_familiar(getvar("is_100_run")))
      use_familiar(to_familiar(getvar("is_100_run")));
  // load the KoL page
   if (post contains "runcombat" && post["runcombat"] == "heckyes") results.append(run_combat());
    else results.append(visit_url());
  // enhance it
   add_features();
  // write it
   results.write();
}