/******************************************************************************
                               SmartStasis
         First Things First + Restore + DB Combos + Intelligent Stasis
*******************************************************************************

   This script does way too many things to explain here.  Visit
   http://kolmafia.us/showthread.php?t=1715
   for documentation or to post a suggestion/bug report.

   Want to say thanks?  Send me a bat! (Or bat-related item)

******************************************************************************/
import <BatBrain.ash>

boolean should_summon_ghost() {
   if ($monsters[guy made of bees, cyrus the virus, hulking construct, trophyfish] contains m)
      return vprint("Ghost ain't gonna work against this boss, boss.",-6);
   if (my_adventures() < 2*((10 + (5*to_int(have_item($item[bandolier of the spaghetti elemental]) > 0))) - to_int(get_property("pastamancerGhostSummons"))))
      return vprint("Running out of adventures to use your summons.  Summoning...",4);  // don't waste daily summonses
   int glevel = minmax(floor(square_root(to_float(get_property("pastamancerGhostExperience")))),1,10);
   switch (get_property("pastamancerGhostType")) {
      case "Angel Hair Wisp": return m_dpr(0,0) < glevel + 10;
      case "Boba Fettucini": if (glevel == 10)
          return (!should_olfact && !should_putty &&
            monster_attack($monster[giant sandworm]) < my_defstat() - 6 + to_int(vars["threshold"]));
          return (!intheclear());
      case "Bow Tie Bat": if (glevel == 10)
          return (count(item_drops(m)) > 0);
          return (!intheclear());
      case "Lasagmbie": return (meat_drop() > 100 && monster_element(m) != $element[spooky]);
      case "Penne Dreadful": if (glevel == 10)
          return (count(item_drops(m)) > 0);
          if (glevel > 4)
             foreach thingy,num in item_drops(m) if (item_type(thingy) == "food" && num < 90) return vprint("This monster drops food! Summoning...",4);
          foreach thingy,num in item_drops(m) if (item_type(thingy) == "booze" && num < 90) return vprint("This monster drops booze! Summoning...",4);
          return false;
      case "Spaghetti Elemental": return (glevel < 3 || !intheclear() ||
         (m == $monster[evil spaghetti cultist] && have_item($item[spaghetti cult robe]) == 0));
      case "Spice Ghost": return (!intheclear() || get_property("pastamancerGhostSummons") == "0");
      case "Undead Elbow Macaroni": return (!intheclear() && monster_element(m) != $element[spooky]);
      case "Vampieroghi": if (my_stat("hp") <= round(to_float(get_property("hpAutoRecovery"))*to_float(my_maxhp()))) return true;
          int suckyamount = 4*(glevel + 1);
          if (glevel == 10) suckyamount = 50;
          if (glevel > 4)
             return (my_maxhp() - my_stat("hp") > suckyamount || my_maxmp() - my_stat("mp") > suckyamount);
          return (my_maxhp() - my_stat("hp") > suckyamount);
      case "Vermincelli": if (glevel > 4 && (have_effect($effect[beaten up]) > 0 || have_effect($effect[cunctatitis]) > 0))
            return vprint("You can remove a negative effect! Summoning...",4);
          return (!intheclear());
      default: return false;
   }
}
boolean should_mayfly() {                // TODO: make this return an advevent
   if (!have_equipped($item[mayfly bait necklace]) || to_int(get_property("_mayflySummons")) == 30) return false;
   switch (my_location()) {
      case $location[cobb's knob treasury]:                    // 0-100 meat
      case $location[the slime tube]:                  // free tiny slimy cyst
      case $location[the haunted sorority house]:      // free useful item
      case $location[hobopolis town square]: return true;    // free hobo nickel
      case $location[degrassi knoll]: foreach i in $items[spring, cog, sprocket, empty meat tank] if (has_goal(i) > 0) return true; break;
      case $location[south of the border]: for i from 297 to 300 if (is_goal(to_item(i))) return true; break;   // free gum
      case $location[the penultimate fantasy airship]: if (my_level() < 13) return true; break;             // substats
      case $location[the hole in the sky]: for i from 657 to 665 if (is_goal(to_item(i))) return true; break;   // free star/line, free runaway
      case $location[the haunted pantry]: 
      case $location[the haunted kitchen]: 
      case $location[cobb's knob kitchens]: foreach i in item_drops(m) if (item_type(i) == "food" && has_goal(i) > 0) return true; break;
      case $location[Cobb's Knob Menagerie\, Level 1]: if (has_goal($monster[fruit golem]) > 0 &&
         m != $monster[knob goblin mutant]) return true; break;  // increase fruit drops, free runaway from BASIC elemental
   }
   switch (m) {
      case $monster[zol]: 
      case $monster[tektite]: 
      case $monster[octorok]: 
      case $monster[keese]: if (item_amount($item[digital key]) == 0) return true; break;    // free pixel, free runaway
      case $monster[knob goblin bean counter]: if (my_level() < 10 && item_amount($item[enchanted bean]) == 0) return true; break;  // free enchanted/jumping bean
      case $monster[swarm of killer bees]: if (has_goal(m) == 0 && has_goal($location[the dungeons of doom]) > 0) return true; break;  // free runaway
      case $monster[whiny pirate]: if (has_goal(m) == 0 && has_goal($location[the poop deck]) > 0) return true; break;  // free runaway
   }
   return (my_adventures()/2 - 2 < 30 - to_int(get_property("_mayflySummons")));
}
item to_paste(monster whatsit) {
   switch (whatsit.phylum) {
      case $phylum[constellation]: return $item[cosmic paste];
      case $phylum[construct]: return $item[oily paste];
      case $phylum[dude]: return $item[gooey paste];
      case $phylum[elf]: return $item[crimbo paste];
      case $phylum[horror]: return $item[indescribably horrible paste];
      case $phylum[humanoid]: return $item[greasy paste];
      case $phylum[plant]: return $item[chlorophyll paste];
      case $phylum[slime]: return $item[slimy paste];
      case $phylum[undead]: return $item[ectoplasmic paste];
      case $phylum[weird]: return $item[strange paste];
      case $phylum[none]: return $item[none];
      default: return to_item(whatsit.phylum+" paste");
   }
   return $item[none];
}

item get_spirit() {              // returns the booze you will get from siphoning
   if ($familiar[happy medium].charges == 0) return $item[none];
   int spirit_base() { switch (m.phylum) {
      case $phylum[beast]: return 5593;         case $phylum[bug]: return 5578;
      case $phylum[constellation]: return 5623; case $phylum[elf]: return 5629;
      case $phylum[humanoid]: return 5581;      case $phylum[demon]: return 5596;
      case $phylum[elemental]: return 5599;     case $phylum[fish]: return 5632;
      case $phylum[goblin]: return 5575;        case $phylum[hippy]: return 5608;
      case $phylum[hobo]: return 5617;          case $phylum[dude]: return 5587;
      case $phylum[horror]: return 5590;        case $phylum[mer-kin]: return 5635;
      case $phylum[construct]: return 5605;     case $phylum[orc]: return 5611;
      case $phylum[penguin]: return 5626;       case $phylum[pirate]: return 5584;
      case $phylum[plant]: return 5614;         case $phylum[slime]: return 5602;
      case $phylum[weird]: return 5620;         case $phylum[undead]: return 5572;
      default: return -5;   // to_item(negative number) returns none
    }
   }
   return to_item(spirit_base() + $familiar[happy medium].charges);
}
boolean should_siphon() {
   item spirit = get_spirit();
   if (spirit == $item[none]) return false;
   if (is_goal(spirit)) return true;
   if (can_interact() || my_path() == "BIG!") return $familiar[happy medium].charges == 3;
   string mainstat_gained() { switch (my_primestat()) {
      case $stat[muscle]: return spirit.muscle;
      case $stat[mysticality]: return spirit.mysticality;
      default: return spirit.moxie;
    }
   }
   if (mainstat_gained() == "0") return false;
   if (spirit.levelreq - my_level() > -2 || spirit.levelreq == 8) return true;
   return false;
}

void set_autoputtifaction() {
   if (m == $monster[none] || m.boss || (!have_skill($skill[transcendent olfaction]) &&
       item_amount($item[spooky putty sheet]) + item_amount($item[rain-doh black box]) == 0)) return;
  // first, transparency with mafia settings
   if (to_monster(excise(get_property("autoOlfact"),"monster ","")) == m) should_olfact = true;
   if (to_monster(excise(get_property("autoPutty"),"monster ","")) == m || m == $monster[swarm of fudgewasps]) should_putty = true;
   if (item_drops(m) contains to_item(excise(get_property("autoOlfact"),"item ",""))) should_olfact = true;
   if (item_drops(m) contains to_item(excise(get_property("autoPutty"),"item ",""))) should_putty = true;
   if (m == $monster[lobsterfrogman] && get_property("sidequestLighthouseCompleted") == "none" &&
       item_amount($item[barrel of gunpowder]) < 4) should_putty = true;
//           (my_location() == $location[guards' chamber] && have_effect($effect[fithworm drone stench]) == 1) ||
   if (should_putty && should_olfact) return;
  // second, set puttifaction for bounty monsters
   item ihunt = to_item(to_int(get_property("currentBountyItem")));
   if (ihunt != $item[none]) {
      if (item_drops(m) contains ihunt && (
          !($locations[the fun house,the goatlet,lair of the ninja snowmen,cobb's knob laboratory] contains my_location()) ||
          (contains_text(vars["ftf_olfact"],m.to_string())))) {
         if (ihunt.bounty_count <= to_int(vars["puttybountiesupto"]) && item_amount(ihunt) < ihunt.bounty_count-1) should_putty = true;
         should_olfact = true;
      } else if (contains_text(vars["ftf_olfact"],m.to_string()) && ihunt.bounty != my_location())
         should_olfact = true;
   } else if (contains_text(vars["ftf_olfact"],m.to_string())) should_olfact = true;
  // next, handle effective goal-getting (this only olfacts if you set "goals" for autoOlfact)
   monster bestm;
   float bestr, temp;
   int sources;
   foreach i,mon in get_monsters(my_location()) {
      temp = has_goal(mon);
      if (temp <= 0) continue;
      sources += 1;
      if (temp > bestr || (temp == bestr && mon == m)) { bestm = mon; bestr = temp; }
   }
   if (bestr == 0) return;
   print(sources+"/"+count(get_monsters(my_location()))+" monsters drop goals here.");
   if (bestm == m) {
      vprint("This monster is the best source of goals ("+rnum(bestr)+")!","green",3);
      if (get_property("autoOlfact").contains_text("goals")) should_olfact = true;
      if (get_property("autoPutty").contains_text("goals")) should_putty = true;
   }
}

// TODO: ask the hobo to dance (takes 3 rounds, significant +item and some food/drink)

// Custom Actions
void build_custom() {
   vprint("Building custom actions...",9);
   boolean encustom(advevent which) { if (which.id == "" || (blacklist contains which.id && blacklist[which.id] == 0)) return false; 
      custom[count(custom)] = merge(which,new advevent); return true; }
   void encustom(item which, boolean finisher) { advevent toque = get_action(which); if (encustom(toque) && finisher) custom[count(custom)-1].endscombat = true; }
   void encustom(item which) { encustom(which, false); }
   void encustom(skill which) { advevent toque = get_action(which); encustom(toque); }
  // stealing! add directly to queue[] rather than custom actions
   if (should_pp && (intheclear() || has_goal(m) > 0) && contains_text(page,"value=\"steal"))
      enqueue(to_event("pickpocket","once",1));
  // safe salve
   if (have_skill($skill[saucy salve]) && !happened($skill[saucy salve]) && (my_stat("hp") < m_dpr(0,0) ||
       min(round(to_float(get_property("hpAutoRecoveryTarget"))*to_float(my_maxhp())) - my_stat("hp"),12)*meatperhp > mp_cost($skill[saucy salve])*meatpermp))
      encustom(get_action($skill[saucy salve]));
  // summon pasta guardian                              TODO: rework to modify base event
   if (my_class() == $class[pastamancer] && contains_text(page,"form name=summon") && should_summon_ghost())
      encustom(to_event("summonspirit","",1));
  // siphoning spirits
   if (my_fam() == $familiar[happy medium] && !happened("skill 7117") && should_siphon())
      encustom(to_event("skill 7117","stun 1, item "+get_spirit(),1));
  // flyers
   foreach flyer in $items[jam band flyers, rock band flyers] if (item_amount(flyer) > 0 && get_property("flyeredML").to_int() < 10050 &&
      (to_boolean(vars["flyereverything"]) || m.base_attack.to_int() >= 10000 - get_property("flyeredML").to_int()) && !happened(flyer) &&
      !($locations[the battlefield (hippy uniform), the battlefield (frat uniform)] contains my_location()))
     encustom(to_event("use "+to_int(flyer),to_spread(0),to_spread(to_string(m_dpr(0,0)*(1-m_hit_chance()))),"!! flyeredML +"+monster_attack(m),1));
  // putty
   set_autoputtifaction();
   item copy_item() {
      if (item_amount($item[spooky putty sheet]) > 0 && to_int(get_property("spookyPuttyCopiesMade")) < 5 &&
          to_int(get_property("spookyPuttyCopiesMade")) + to_int(get_property("_raindohCopiesMade")) < 6)
         return $item[spooky putty sheet];
      if (item_amount($item[rain-doh black box]) > 0 && to_int(get_property("_raindohCopiesMade")) < 5 &&
          to_int(get_property("spookyPuttyCopiesMade")) + to_int(get_property("_raindohCopiesMade")) < 6)
         return $item[rain-doh black box];
      if (item_amount($item[4-d camera]) > 0 && !to_boolean(get_property("_cameraUsed")) && to_boolean(vars["cameraPutty"]))
         return $item[4-d camera];
      return $item[none];
   }
   if (should_putty && copy_item() != $item[none]) {
      if (to_item(to_int(get_property("currentBountyItem"))).bounty_count > 0)
         should_olfact = (to_item(to_int(get_property("currentBountyItem"))).bounty_count >= 5 -
            (to_int(get_property("spookyPuttyCopiesMade")) + to_int(get_property("_raindohCopiesMade"))));
      encustom(to_event("use "+to_int(copy_item()),to_spread(0),to_spread(to_string(m_dpr(0,0)*(1-m_hit_chance()))),"",1));
   }
  // olfaction
   if (have_effect($effect[form of...bird!]) == 0 && have_effect($effect[on the trail]) == 0 &&
       should_olfact && !happened($skill[transcendent olfaction])) encustom($skill[transcendent olfaction]);
  // insults
   if (m.phylum == $phylum[pirate] && !($strings[step5, finished] contains get_property("questM12Pirate")) &&
      !($monsters[scary pirate, migratory pirate, ambulatory pirate, peripatetic pirate, black crayon pirate] contains m))
     foreach i in $items[massive manual of marauder mockery, the big book of pirate insults]
       if (item_amount(i) > 0 && !happened(i)) {
          int insultsknown;
          for n from 1 to 8 if (get_property("lastPirateInsult"+n) == "true") insultsknown += 1;
          if (insultsknown < 8) encustom(i); break;
       }
  // identify potions
   float dier,bangcount;
   for i from 819 to 827
      if (get_property("lastBangPotion"+i) == "" && be_good(to_item(i)) && item_amount(to_item(i)) > to_int(get_property("autoPotionID") == "false")) {
         custom[count(custom)] = to_event("use "+i,get_bang(""),1);
         bangcount += 1;
         if (dier == 0) dier = die_rounds();
         if (bangcount >= ceil(dier/10.0)) break;
      }
  // identify spheres		 
   for i from 2174 to 2177
      if (item_amount(to_item(i)) > 0 && get_property("lastStoneSphere"+i) == "" && get_property("autoSphereID") == "true")
         encustom(to_event("use "+i,get_sphere(""),1));
  // release the boots!
   if (my_familiar() == $familiar[pair of stomping boots] && my_location() != $location[none] && get_property("bootsCharged") == "true" && 
       count(get_monsters(my_location())) > 1 && !($items[none,gooey paste] contains to_paste(m)) && !m.boss) {
      boolean[item] pastegoals;
      for i from 5198 to 5219 if (is_goal(to_item(i))) pastegoals[to_item(i)] = true;
     // TODO: if there are other monsters in the zone that have paste goals, wait to stomp them
      if (appearance_rates(my_location())[m] > 0 && (is_goal(to_paste(m)) || has_goal(m) == 0))
         encustom($skill[release the boots]);
   }
  // under the sea
   if (my_location().zone == "The Sea") {
      if (get_property("lassoTraining") != "expertly" && m != $monster[wild seahorse]) encustom($item[sea lasso]);
      if (item_amount($item[Mer-kin dreadscroll]) > 0 && to_int(get_property("merkinVocabularyMastery")) > 89) { 
         if (get_property("dreadScroll5") == "0") encustom($item[Mer-kin killscroll]);
         if (get_property("dreadScroll2") == "0") encustom($item[Mer-kin healscroll]);
      }
   }
  // grin/stinkeye
   if (contains_text(vars["ftf_grin"],m.to_string()))
      foreach sk in $skills[creepy grin, give your opponent the stinkeye] encustom(sk);
  // summon mayflies   (toward the end since it can result in free runaways)
   if (should_mayfly()) encustom(get_action($skill[summon mayfly swarm]));
  // vibrato punchcards
   boolean try_cards(int com, int obj, string note) {
      if (item_amount(to_item(com)) == 0 || item_amount(to_item(obj)) == 0) return false;
      encustom(to_event("use "+com+"; use "+obj,"!! "+note,2));
      return true;
   }
   switch (m) {
      case $monster[hulking construct]:
         if (try_cards(3146,3155,"ATTACK WALL")) break;
         if (try_cards(3146,3153,"ATTACK FLOOR")) break;
         if (try_cards(3146,3152,"ATTACK SELF")) break;
         break;
      case $monster[bizarre construct]:
         if (item_amount($item[repaired El Vibrato drone]) > 0 && !is_goal($item[repaired El Vibrato drone]) && try_cards(3148,3154,"BUFF DRONE")) break;
         if (my_stat("hp") < 0.7*my_maxhp() && try_cards(3147,3151,"REPAIR TARGET")) break;
         if (have_effect($effect[fitter, happier]) < 5 && try_cards(3148,3151,"BUFF TARGET")) break;
         break;
      case $monster[lonely construct]:
         if (item_amount($item[broken El Vibrato drone]) > 0 && !is_goal($item[broken El Vibrato drone]) && try_cards(3147,3154,"REPAIR DRONE")) break;
         if (have_outfit("El Vibrato") && item_amount($item[El Vibrato power sphere]) > 0 && try_cards(3149,3156,"MODIFY SPHERE")) break;
         break;
      case $monster[towering construct]:
         int evdgoals = 1 - to_int(have_familiar($familiar[El Vibrato megadrone]));
         foreach it in $items[broken El Vibrato drone, repaired El Vibrato drone, augmented El Vibrato drone, El Vibrato megadrone]
            evdgoals += to_int(has_goal(it) > 0) - to_int(item_amount(it) > 0);
         if (item_amount($item[El Vibrato drone]) > 0 && evdgoals > 0 && try_cards(3149,3154,"MODIFY DRONE")) break;
         if (item_amount($item[El Vibrato power sphere]) > 0 && !have_outfit("El Vibrato") && try_cards(3149,3156,"MODIFY SPHERE")) break;
         if (try_cards(3150,3154,"BUILD DRONE")) break;
         if (item_amount(to_item(3149)) > 4+evdgoals && item_amount(to_item(3146)) > 0 && item_amount(to_item(3155)) > 0 && try_cards(3149,3152,"MODIFY SELF")) break;
         break;
      case $monster[dirty thieving brigand]: encustom($item[meat vortex]); break;      // meat vortices vs. brigands
      case $monster[tomb rat]: encustom($item[tangle of rat tails]); break;            // tomb rat king! (may require safety checks)
      case $monster[clingy pirate]: if (has_goal(m) == 0) encustom($item[cocktail napkin]); break;  // cocktail napkins
      case $monster[hellseal pup]: encustom($item[seal tooth]); break;                 // seal tooth vs. seal pup
      case $monster[wild seahorse]: if (item_amount($item[sea cowbell]) > 2 && get_property("lassoTraining") == "expertly" && 
                                        item_amount($item[sea lasso]) > 0) foreach it in $items[sea cowbell, sea cowbell, sea cowbell, sea lasso] encustom(it);
         encustom(to_event("runaway","endscombat",1)); break;
     // skate decoys for goals
      case $monster[grouper groupie]: if (is_goal($item[grouper fangirl]) && item_amount($item[ice skate decoy]) > 0 && !happened($item[ice skate decoy]))
         encustom(to_event("use 4231","item grouper fangirl",1)); break;
      case $monster[urchin urchin]: if (is_goal($item[urchin roe]) && item_amount($item[roller skate decoy]) > 0 && !happened($item[roller skate decoy]))
         encustom(to_event("use 4210","item urchin roe",1)); break;
     // boss killers
      case $monster[gargantulihc]: encustom($item[plus-sized phylactery],true); break;
      case $monster[sexy sorority ghost]: encustom($item[ghost trap],true); break;
      case $monster[bugbear scientist]: encustom($item[quantum nanopolymer spider web],true); break;
      case $monster[liquid metal bugbear]: encustom($item[drone self-destruct chip],true); break;
      case $monster[guy made of bees]: encustom($item[antique hand mirror]);
         encustom(to_event("runaway","endscombat",1)); break;
      case $monster[cyrus the virus]: for i from 4011 to 4016
          if (item_amount(to_item(i)) > 0 && !contains_text(get_property("usedAgainstCyrus"),to_item(i))) {
             encustom(to_item(i),true); break;
          }
         encustom(to_event("runaway","endscombat",1)); break;
      case $monster[the big wisniewski]:
      case $monster[the man]: if (get_property("hippiesDefeated") == "999" && get_property("fratboysDefeated") == "999") encustom($item[flaregun],true); break;
      case $monster[thug 1 and thug 2]: if (item_amount($item[jar full of wind]) > 9) for i from 1 to 10 encustom($item[jar full of wind]); break;
      case $monster[the bat in the spats]: if (item_amount($item[clumsiness bark]) > 9) for i from 1 to 10 encustom($item[clumsiness bark]); break;
      case $monster[the large-bellied snitch]: if (item_amount($item[dangerous jerkcicle]) > 7) for i from 1 to 10 encustom($item[dangerous jerkcicle]); break;
      case $monster[mammon the elephant]: if (item_amount($item[dangerous jerkcicle]) > 5) for i from 1 to 6 encustom($item[dangerous jerkcicle]); break;
      case $monster[the landscaper]: if (item_amount($item[grass clippings]) > 2) for i from 1 to 3 encustom($item[grass clippings]); break;
     // tower monsters
      case $monster[beer batter]: encustom($item[baseball],true); break;
      case $monster[best-selling novelist]: encustom($item[plot hole],true); break;
      case $monster[big meat golem]: encustom($item[meat vortex],true); break;
      case $monster[bowling cricket]: encustom($item[sonar-in-a-biscuit],true); break;
      case $monster[bronze chef]: encustom($item[leftovers of indeterminate origin],true); break;
      case $monster[concert pianist]: encustom($item[knob goblin firecracker],true); break;
      case $monster[el diablo]: encustom($item[mariachi g-string],true); break;
      case $monster[electron submarine]: encustom($item[photoprotoneutron torpedo],true); break;
      case $monster[endangered inflatable white tiger]: encustom($item[pygmy blowgun],true); break;
      case $monster[fancy bath slug]: encustom($item[fancy bath salts],true); break;
      case $monster[fickle finger of F8]: encustom($item[razor-sharp can lid],true); break;
      case $monster[flaming samurai]: encustom($item[frigid ninja stars],true); break;
      case $monster[giant desktop globe]: encustom($item[ng],true); break;
      case $monster[giant fried egg]: encustom($item[black pepper],true); break;
      case $monster[ice cube]: encustom($item[hair spray],true); break;
      case $monster[malevolent crop circle]: encustom($item[bronzed locust],true); break;
      case $monster[possessed pipe-organ]: encustom($item[powdered organs],true); break;
      case $monster[pretty fly]: encustom($item[spider web],true); break;
      case $monster[darkness]: encustom($item[inkwell],true); break;
      case $monster[tyrannosaurus tex]: encustom($item[chaos butterfly],true); break;
      case $monster[vicious easel]: encustom($item[disease],true); break;
      case $monster[giant bee]: encustom($item[tropical orchid],true); break;
      case $monster[enraged cow]: encustom($item[barbed-wire fence],true); break;
      case $monster[collapsed mineshaft golem]: encustom($item[stick of dynamite],true); break;
   }
  // learn rave combos
   advevent unknown_rave() {
      if (available_amount($item[seeger's unstoppable banjo]) == 0 && my_location().zone != "Volcano") return new advevent;
      for i from 50 to 52 if (!have_skill(to_skill(i))) return new advevent;
      for i from 50 to 52 for j from 50 to 52 {
         if (j == i) continue;
         for k from 50 to 52 {
            if (k == j || k == i) continue;
            boolean found = false;
            for l from 1 to 6 if (get_property("raveCombo"+l) == to_skill(i)+","+to_skill(j)+","+to_skill(k)) found = true;
            if (!found) return merge(to_event("skill "+i,factors["skill",i],1), to_event("skill "+j,factors["skill",j],1), to_event("skill "+k,factors["skill",k],1));
         }
      }
      return new advevent;
   }
   encustom(unknown_rave());
   vprint("Custom actions built! ("+count(custom)+" actions)",9);
}

void enqueue_custom() {
   sort custom by to_int(value.endscombat);  // move all combat-enders to the end of the queue
   foreach n,ev in custom {
      if (my_stat("mp") < ev.mp) continue;   // can't cast this skill (yet)
      boolean stunfirst = (adj.stun + ev.stun < 1 && !ev.endscombat && to_profit(merge(stun_action(contains_text(ev.id,"use ")),ev)) > to_profit(ev));  // should we stun?
      if (!stunfirst && !ev.endscombat && !($monsters[guy made of bees, cyrus the virus] contains m) && my_stat("hp") - ev.pdmg[$element[none]] < 0) continue;   // you will die
      vprint("Custom action: "+ev.id+((stunfirst) ? " (stun first with "+buytime.id+")" : " (no stun)"),"purple",5);
      if (stunfirst && buytime.id != ev.id) enqueue(buytime);
      if (enqueue(ev)) remove custom[n];
   }
}
string try_custom() {
   enqueue_custom();
   return macro();
}


//                           ---===== DISCO COMBOS =====---

advevent[int] combos;
advevent to_combo(effect which) {
   if (have_effect(which) > 0) return new advevent;
   string ravepref(int i) {
      return (available_amount($item[seeger's unstoppable banjo]) > 0 || my_location().zone == "Volcano") ? get_property("raveCombo"+i) : "";
   }
   string seq(effect c) {
      switch (c) {
         case $effect[disco nirvana]: return "disco dance of doom,disco dance ii: electric boogaloo";
         case $effect[disco concentration]: return "disco eye-poke,disco dance of doom,disco dance ii: electric boogaloo";
         case $effect[none]: return ravepref(5);                // rave steal is $effect[none]
         case $effect[rave nirvana]: return ravepref(2);
         case $effect[rave concentration]: return ravepref(1);
        // combat combos
         case $effect[disco inferno]: return "disco eye-poke,disco dance ii: electric boogaloo";
//         case $effect[disco blindness]: return "disco dance ii: electric boogaloo,disco eye-poke";
//         case $effect[rave stats]: ravepref(6);
      } return "";
   }
   string[int] ord = split_string(seq(which),",");
   if (count(ord) < 2) return new advevent;
   advevent res;
   foreach i,s in ord {
      if (get_action(to_skill(s)).id == "") return new advevent;
      res = (res.id == "" ? get_action(to_skill(s)) : merge(res,get_action(to_skill(s))));
      if (to_int(to_skill(s)) < 53) res.dmg[$element[none]] += 5;    // rave combos are merge(1,2,3) + 15 dmg
   }
   if (-res.mp > my_maxmp()) return new advevent;
   float bonus = 0.3;
   switch (which) {                                                  // add meat/items profit gained
      case $effect[disco concentration]: bonus = 0.2;
      case $effect[none]:
      case $effect[rave concentration]: float dcprofit,prev,icount; boolean skipped;
         foreach num,rec in item_drops_array(m) {
            if (!skipped && stolen contains rec.drop) { skipped = true; continue; }
            if (rec.rate == 0) continue;
            switch (rec.type) {
               case "p": continue;
               case "c": if (item_type(rec.drop) == "shirt" && !have_skill($skill[torso awaregness])) continue;
                         if (!is_displayable(rec.drop)) continue;
                         if (item_type(rec.drop) == "pasta guardian" && my_class() != $class[pastamancer]) break;  // skip pasta guardians for non-PMs
                         if (rec.drop == $item[bunch of square grapes] && my_level() < 11) break;  // grapes drop at 11
            }
            prev = item_val(rec.drop,rec.rate);
            if (which != $effect[none]) {
               if (prev == item_val(rec.drop)) continue;
               dcprofit += item_val(rec.drop,(1.0 + bonus)*rec.rate) - prev;
            } else { icount += 1; dcprofit += prev; }
            if (has_goal(rec.drop) > 0) { dcprofit = 9999999; break; }
         }
         res.meat += which == $effect[none] ? dcprofit/max(1,icount)+to_int($locations[outside the club, the haunted sorority house, lollipop forest] contains my_location())*9999999 : dcprofit; break;
      case $effect[rave nirvana]: bonus = 0.5;
      case $effect[disco nirvana]: if (m == $monster[dirty thieving brigand] && vars["ocw_nunspeed"] == "false") break;
         res.meat += bonus*to_float(meat_drop(m)); break;
      case $effect[disco inferno]: res.att -= 5; break;
//      case $effect[disco blindness]: res.stun = 3; break;
   }
   return res;
}

void build_combos() {
   if (my_class() != $class[disco bandit]) return;
   void encombo(effect c) { advevent thec = to_combo(c); if (thec.id != "") combos[count(combos)] = thec; }
   vprint("Building disco combos...",9);
   if (meat_drop(m) > 0) {
      encombo($effect[disco nirvana]);
      encombo($effect[rave nirvana]);
   }
   if (should_pp || my_location() == $location[outside the club])
      encombo($effect[none]);
   if (count(item_drops(m)) > 1 && !(my_fam() == $familiar[he-boulder] && have_effect($effect[everything looks yellow]) == 0 &&
       contains_text(vars["ftf_yellow"],m.to_string()))) {            // no need for +items if you're going to yellow ray
      encombo($effect[disco concentration]);
      encombo($effect[rave concentration]);
   }
   sort combos by -to_profit(value);
   vprint("Combos built! ("+count(combos)+" combos)",9);
}

void enqueue_combos() {
   foreach n,com in combos if (monster_stat("hp") > dmg_dealt(com.dmg) && to_profit(com) > 0 &&
      die_rounds() - kill_rounds(attack_action()) > com.rounds) {
      if (!enqueue(com)) continue;
      remove combos[n];
   }
}
string try_combos() {
   enqueue_combos();
   return macro();
}

// special cases for stasis              maces            faces                        basis                           hey sis
boolean is_our_huckleberry() {
   if (my_stat("hp") < round(m_dpr(0,0))) return vprint("Your huckleberry will kill you.",-9);
   if (item_amount($item[molybdenum magnet]) > 0 && !happened("lackstool") &&
       $monsters[batwinged gremlin, erudite gremlin, spider gremlin, vegetable gremlin] contains m) {
      if (my_location() == to_location(get_property("currentJunkyardLocation")))
         return (item_drops() contains to_item(get_property("currentJunkyardTool")));
      return (!(item_drops() contains to_item(get_property("currentJunkyardTool"))));
   }
   switch (my_location()) {
      case $location[seaside megalopolis]: if (have_equipped($item[ruby rod])) foreach thingy in item_drops()
         if (contains_text(to_string(thingy),"essence of ") && available_amount(thingy) == 0) 
            return vprint("This "+m+" has a "+thingy+", making it your huckleberry.",9);
         break;
      case $location[outside the club]: if (have_skill($skill[gothy handwave]) && !happened($skill[gothy handwave]))
         switch (m) {
            case $monster[breakdancing raver]: if (!have_skill($skill[break it on down])) return true; break;
            case $monster[pop-and-lock raver]: if (!have_skill($skill[pop and lock it])) return true; break;
            case $monster[running man]: if (!have_skill($skill[run like the wind])) return true;
         } break;
      case $location[the broodling grounds]: if (m == $monster[hellseal pup] && !happened("sealwail")) return true; break;
      case $location[chinatown tenement]: if (m == $monster[the server] && item_amount($item[strange goggles]) > 0 && !happened("use 6118")) return true; break;
      case $location[the clumsiness grove]: if (m == $monster[the thorax] && item_amount($item[clumsiness bark]) > 0) return true; break;
   }
   if (my_fam() == $familiar[he-boulder] && have_effect($effect[everything looks yellow]) == 0 &&
       contains_text(vars["ftf_yellow"],m.to_string())) return vprint("Monsters in ftf_yellow are your huckleberry.",9);
   return vprint("This monster is not your huckleberry.","black",-9);
}

string stasis_repeat() {       // the string of repeat conditions for stasising
   int expskill() { int res; foreach s in $skills[] if (s.combat && have_skill(s)) res = max(res,mp_cost(s)); return res; }
   return "!hpbelow "+my_stat("hp")+                                                        // hp
      (my_stat("hp") < my_maxhp() ? " && hpbelow "+my_maxhp() : "")+
      " && !mpbelow "+my_stat("mp")+                                                        // mp
      (my_stat("mp") < min(expskill(),my_maxmp()) ? " && mpbelow "+min(expskill(),my_maxmp()) : "")+
      " && !pastround "+max(1,floor(maxround - 3 - kill_rounds(smack)))+                    // time to kill
      ((have_equipped($item[crown of thrones])) ? " && !match \"acquire an item\"" : "")+   // CoT
      ((my_fam() == $familiar[hobo monkey]) ? " && !match \"hands you some Meat\"" : "")+   // famspent
      ((my_fam() == $familiar[gluttonous green ghost]) ? " && match ggg.gif" : "")+
      ((my_fam() == $familiar[slimeling]) ? " && match slimeling.gif" : "");
}

string stasis() {
   if ($monsters[naughty sorority nurse, naughty sorceress, naughty sorceress (2),
       pufferfish, bonerdagon] contains m) return page;    // never stasis these monsters
   if (m == $monster[quantum mechanic] && m_hit_chance() > 0.08) return page;  // avoid teleportitis
   stasis_action();
   attack_action();
   while ((to_profit(plink) > to_float(vars["BatMan_profitforstasis"]) || is_our_huckleberry()) &&
         (round < maxround - 3 - kill_rounds(smack) && die_rounds() > kill_rounds(smack))) {
      vprint("Top of the stasis loop.",9);
     // special actions
      enqueue_custom();
      enqueue_combos();
     // stasis action as picked by BatBrain -- macro it until anything changes
      if (plink.id == "" && vprint("You don't have any stasis actions.","olive",4)) break;
      macro(plink, stasis_repeat());
      if (finished()) break;
      stasis_action();       // recalculate stasis/attack actions
      attack_action();
   }
   vprint("Stasis loop complete"+(count(queue) > 0 ? " (queue still contains "+count(queue)+" actions)." : "."),9);
   return page;
}

// NOTE: after running this script, changing these variables here in the script will have no
// effect.  You can view ("zlib vars") or edit ("zlib <settingname> = <value>") values in the CLI.
setvar("flyereverything",true);
setvar("puttybountiesupto",19);
setvar("cameraPutty",false);
setvar("ftf_olfact","blooper, dairy goat, shaky clown, zombie waltzers, goth giant, knott yeti, hellion, violent fungus","list of monster");
setvar("ftf_grin","procrastination giant","list of monster");
setvar("ftf_yellow","knob goblin harem girl","list of monster");
string SSver = check_version("SmartStasis","smartstasis",1715);

void main(int initround, monster foe, string pg) {
   act(pg);
   vprint_html("Profit per round: "+to_html(baseround()),5);
  // custom actions
   build_custom();
   switch (m) {    // add boss monster items here since BatMan is not being consulted
      case $monster[conjoined zmombie]: for i from 1 upto item_amount($item[half-rotten brain])
         custom[count(custom)] = get_action("use 2562"); break;
      case $monster[giant skeelton]: for i from 1 upto item_amount($item[rusty bonesaw])
         custom[count(custom)] = get_action("use 2563"); break;
      case $monster[huge ghuol]: for i from 1 upto item_amount($item[can of Ghuol-B-Gone&trade;])
         custom[count(custom)] = get_action("use 2565"); break;
   }
   if (count(queue) > 0 && queue[0].id == "pickpocket" && my_class() == $class[disco bandit]) try_custom();
    else enqueue_custom();
  // combos
   build_combos();
   if (($familiars[hobo monkey, gluttonous green ghost, slimeling] contains my_fam() && !happened("famspent")) || have_equipped($item[crown of thrones])) try_combos();
    else enqueue_combos();
  // stasis loop
   stasis();
   if (round < maxround && !is_our_huckleberry() && adj.stun < 1 && stun_action(false).stun > to_int(dmg_dealt(buytime.dmg) == 0) &&
       kill_rounds(smack) > 1 && min(buytime.stun-1, kill_rounds(smack)-1)*m_dpr(0,0)*meatperhp > buytime.profit) enqueue(buytime);
   macro();
   vprint("SmartStasis complete.",9);
}
