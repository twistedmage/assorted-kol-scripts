/******************************************************************************
                               SmartStasis
            First Things First + Restore + Intelligent Stasis
*******************************************************************************

   This script does way too many things to explain here.  Visit
   http://kolmafia.us/showthread.php?t=1715
   for documentation or to post a suggestion/bug report.

   Want to say thanks?  Send me a bat! (Or bat-related item)

******************************************************************************/
since r18076;   // villain lair daily properties
import <BatBrain.ash>

boolean should_mayfly() {                // TODO: make this return an advevent
   if (!have_equipped($item[mayfly bait necklace]) || to_int(get_property("_mayflySummons")) == 30) return false;
   switch (where.zone) {
      case "Dreadsylvania":                                 // Freddies!
      case "Twitch":                                        // Chroner!
      case "Spring Break Beach":                            // Beach Bucks!
      case "Conspiracy Island":                             // Coinspiracy!
      case "That 70s Volcano":                              // Volcoinos!
      case "The Glaciest":                                  // Wal-bucks!
      case "Dinseylandfill": return true;                   // Fun Funds!
   }
   switch (where) {
      case $location[cobb's knob treasury]:                 // 0-100 meat
      case $location[the slime tube]:                       // free tiny slimy cyst
      case $location[the haunted sorority house]:           // free useful item
      case $location[hobopolis town square]: return true;   // free hobo nickel
      case $location[Battlefield (Cloaca Uniform)]: if (is_goal($item[cloaca-cola])) return true; break;
      case $location[Battlefield (Dyspepsi Uniform)]: if (is_goal($item[dyspepsi-cola])) return true; break;
      case $location[the degrassi knoll garage]: foreach i in $items[spring, cog, sprocket, empty meat tank] if (has_goal(i) > 0) return true; break;
      case $location[south of the border]: for i from 297 to 300 if (is_goal(to_item(i))) return true; break;   // free gum
      case $location[the penultimate fantasy airship]: if (my_level() < 13) return true; break;                 // substats
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
      case $monster[keese]: if (item_amount($item[digital key]) == 0) return true; break;      // free pixel, free runaway
      case $monster[bugged bugbear]: if (where != $location[none]) return true; break; // free runaway when normally adventuring
      case $monster[knob goblin bean counter]: if (my_level() < 10 && item_amount($item[enchanted bean]) == 0) return true; break;  // free enchanted/jumping bean
      case $monster[swarm of killer bees]: if (has_goal(m) == 0) return true; break;           // free runaway
      case $monster[whiny pirate]: if (has_goal(m) == 0 && has_goal($location[the poop deck]) > 0) return true; break;  // free runaway
   }
   return (my_adventures()/2 - 2 < 30 - to_int(get_property("_mayflySummons")));
}
item to_paste(monster whatsit) {
   if (whatsit.boss) return $item[none];
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
   if (m == $monster[none] || m.boss) return;
  // first, transparency with mafia settings
   if (to_monster(excise(get_property("autoOlfact"),"monster ","")) == m) should_olfact = true;
   if (to_monster(excise(get_property("autoPutty"),"monster ","")) == m || m == $monster[swarm of fudgewasps]) should_putty = true;
   if (item_drops(m) contains to_item(excise(get_property("autoOlfact"),"item ",""))) should_olfact = true;
   if (item_drops(m) contains to_item(excise(get_property("autoPutty"),"item ",""))) should_putty = true;
   if (m == $monster[lobsterfrogman] && get_property("sidequestLighthouseCompleted") == "none" && !qprop("questL12War") &&
       item_amount($item[barrel of gunpowder]) < 4) should_putty = true;
   if (should_putty && should_olfact) return;
  // second, set puttifaction for bounty monsters
   foreach s in $strings[currentEasyBountyItem, currentHardBountyItem, currentSpecialBountyItem]
      if (to_bounty(get_property(s)).monster == m) should_olfact = true;
   /*
   boolean[location] blocs;
   foreach s in $strings[currentEasyBountyItem, currentHardBountyItem, currentSpecialBountyItem] {
      bounty thisb = to_bounty(get_property(s));
      if (thisb.number == 0) continue;
      if (m == thisb.monster && (!($locations[the "fun" house, the goatlet, lair of the ninja snowmen, cobb's knob laboratory] contains where) ||
          (list_contains(getvar("BatMan_attract"),m)))) {
         if (thisb.number <= to_int(getvar("BatMan_puttybountiesupto")) && item_amount(ihunt) < ihunt.bounty_count-1) should_putty = true;
         should_olfact = true;
      } else if (list_contains(getvar("BatMan_attract"),m) && ihunt.bounty != where)
         should_olfact = true;
  } else
  */
  
  // next, handle effective goal-getting (this only olfacts if you set "goals" for autoOlfact)
   monster[int] sortm = get_monsters(where);
   boolean belongs;
   sort sortm by -has_goal(value);
   int sources;
   foreach i,mon in sortm {
      if (mon == m) belongs = true;
      if (has_goal(mon) == 0) continue;
      sources += 1;
   }
   if (list_contains(getvar("BatMan_attract"),m) && (belongs || where == $location[none])) should_olfact = true;
   if (sources == 0) return;
   print(sources+"/"+count(get_monsters(where))+" monsters drop goals here.");
   if (sortm[0] == m) {
      vprint("This monster is the best source of goals ("+rnum(has_goal(m))+")!","green",3);
      if (get_property("autoOlfact").contains_text("goals")) should_olfact = true;
      if (get_property("autoPutty").contains_text("goals")) should_putty = true;
   }
}

// TODO: ask the hobo to dance (takes 3 rounds, significant +item and some food/drink)

// Custom Actions
void build_custom() {
   vprint("Building custom actions...",9);
   boolean encustom(advevent which) { if (which.id == "" || (blacklist contains which.id && blacklist[which.id] == 0)) return false; 
      custom[count(custom)] = copy(which); return true; }
   boolean encustom(item which, boolean finisher) {
      advevent toque = get_action(which);
      if (!encustom(toque)) return false;
      if (finisher) custom[count(custom)-1].endscombat = true;
      return true;
   }
   boolean encustom(item which) { return encustom(which, false); }
   boolean encustom(skill which) { advevent toque = get_action(which); return encustom(toque); }
  // stealing! add directly to queue[] rather than custom actions
   boolean needlove = have_skill($skill[catchphrase]) && my_audience() < 30 + (have_equipped($item[sneaky pete's leather jacket]) ||
      have_equipped($item[sneaky pete's leather jacket (collar popped)]) ? 20 : 0);
   if (have_skill($skill[incite riot]) && get_property("_petePartyThrown").to_boolean() && !get_property("_peteRiotIncited").to_boolean()) {
      needlove = false; should_pp = true;
      if (get_property("_peteJumpedShark").to_int() < 3) encustom(get_action($skill[jump shark]));
   }
   if (has_goal(m) == 0 && needlove) should_pp = false;   // don't pp if the monster drops no goals and you can get more Love
   if (should_pp && (intheclear() || has_goal(m) > 0)) {
      if (contains_text(page,"value=\"steal")) enqueue(to_event("pickpocket","once",1));
       else if (my_path() == "Zombie Slayer") encustom($skill[smash & graaagh]);
   } else if (round < 2 && intheclear() && needlove) enqueue(get_action($skill[mug for the audience]));    // for now, always mug unless you can pickpocket goals
  // more stealing!
   if (my_class() == $class[accordion thief]) encustom(get_action($skill[steal accordion]));
  // safe salve
   if (have_skill($skill[saucy salve]) && !happened($skill[saucy salve]) && (my_stat("hp") < m_dpr(0,0) ||
       min(round(to_float(get_property("hpAutoRecoveryTarget"))*to_float(my_maxhp())) - my_stat("hp"),12)*meatperhp > mp_cost($skill[saucy salve])*meatpermp))
      encustom(get_action($skill[saucy salve]));
  // weaksauce
//   if ((m_hit_chance() > 0.4 && kill_rounds(attack_action()) > 1) || $strings[Dreadsylvania, Junkyard] contains my_location().zone) 
//      encustom($skill[curse of weaksauce]);  // needs better logic before being added to public version
   switch (where) {
      case $location[mt. molehill]: if (is_goal($item[climate colada])) encustom(get_action($skill[tunnel upwards]));  // a few tunnelling aids
         else if (is_goal($item[digital underground potion])) encustom(get_action($skill[tunnel downwards])); break;
      case $location[a mob of zeppelin protesters]: if (get_property("zeppelinProtestors").to_int() < 79 && !encustom($item[bomb of unknown origin]))  // speed up protester removal
         encustom($item[cigarette lighter]); break;
   }
  // ghost hunting
   if (have_equipped($item[protonic accelerator pack]) && m.sub_types contains "ghost")
      for i from 1 to 3 encustom($skill[shoot ghost]);  // this fails if the skill is unavailable; also Trap Ghost is a BatBrain autoreaction whenever available
  // flyers
   foreach flyer in $items[jam band flyers, rock band flyers] if (item_amount(flyer) > 0 && !qprop("questL12War") && be_good(flyer) && get_property("flyeredML").to_int() < 10050 &&
      (to_boolean(getvar("BatMan_flyereverything")) || m.base_attack.to_int() >= 10000 - get_property("flyeredML").to_int()) && !happened(flyer) &&
      !($locations[the battlefield (hippy uniform), the battlefield (frat uniform)] contains where))
     encustom(to_event("use "+to_int(flyer),to_spread(0),to_spread(to_string(m_dpr(0,0)*(1-m_hit_chance()))),"!! flyeredML +"+monster_attack(m),1));
  // putty
   set_autoputtifaction();
   if (should_putty) encustom(custom_action("copy"));
/*
      if (to_item(to_int(get_property("currentBountyItem"))).bounty_count > 0)
         should_olfact = (to_item(to_int(get_property("currentBountyItem"))).bounty_count >= 5 -
            (to_int(get_property("spookyPuttyCopiesMade")) + to_int(get_property("_raindohCopiesMade"))));
   }
*/
  // attraction
   if (should_olfact) encustom(custom_action("attract"));
  // insults
   if (m.phylum == $phylum[pirate] && qprop("questM12Pirate < 5") &&
       !($monsters[scary pirate, migratory pirate, ambulatory pirate, peripatetic pirate, black crayon pirate] contains m)) {
      int insultsknown;
      for n from 1 to 8 if (get_property("lastPirateInsult"+n) == "true") insultsknown += 1;
      if (insultsknown < 8) encustom(custom_action("insult"));
   }
  // extract (source skill)
   if (qprop("questL13Final") || item_amount($item[source essence]) < 100 || mp_cost($skill[extract])/to_float(my_maxmp()) < 0.33)
      encustom(get_action($skill[extract]));
  // identify potions
   float dier,bangcount;
   if (get_property("autoPotionID") == "true") for i from 819 to 827
      if (get_property("lastBangPotion"+i) == "" && be_good(to_item(i)) && item_amount(to_item(i)) > to_int(get_property("autoPotionID") == "false")) {
         custom[count(custom)] = to_event("use "+i,get_bang(""),1);
         bangcount += 1;
         if (dier == 0) dier = die_rounds();
         if (bangcount >= ceil(dier/10.0)) break;
      }
  // zone stuff
   switch (where.zone) {
      case "The Sea": if (get_property("lassoTraining") != "expertly" && m != $monster[wild seahorse]) encustom($item[sea lasso]);
         if (item_amount($item[Mer-kin dreadscroll]) > 0 && to_int(get_property("merkinVocabularyMastery")) > 89) { 
            if (get_property("dreadScroll5") == "0") encustom($item[Mer-kin killscroll]);
            if (get_property("dreadScroll2") == "0") encustom($item[Mer-kin healscroll]);
         } break;
      case "The Glaciest": if (get_property("walfordBucketItem") == "blood" && have_equipped($item[walford's bucket]) && qprop("questECoBucket < 2") &&
            where.environment != "underwater" && !happened($item[tin snips]) && get_property("walfordBucketProgress").to_int() < 100)
         encustom(get_action($item[tin snips]));
         break;
   }
   switch (my_fam()) {
     // siphoning spirits
      case $familiar[happy medium]: if (!happened("skill 7117") && should_siphon())
         encustom(to_event("skill 7117","stun 1, item "+get_spirit(),1)); break;
     // release the boots!
      case $familiar[pair of stomping boots]: if (where != $location[none] && get_property("bootsCharged") == "true" && 
       count(get_monsters(where)) > 1 && !($items[none,gooey paste] contains to_paste(m))) {
         boolean[item] pastegoals;
         for i from 5198 to 5219 if (is_goal(to_item(i))) pastegoals[to_item(i)] = true;
        // TODO: if there are other monsters in the zone that have paste goals, wait to stomp them
         if (appearance_rates(where)[m] > 0 && (is_goal(to_paste(m)) || has_goal(m) == 0))
            encustom($skill[release the boots]);
       } break;
     // extract jelly
      case $familiar[space jellyfish]: if (!m.boss && m.attack_element != $element[none])
        encustom($skill[extract jelly]); break;
   }
  // yellow ray actions
   if (have_effect($effect[everything looks yellow]) == 0 && list_contains(getvar("BatMan_yellow"),m) && 
       my_fam() != $familiar[he-boulder]) encustom(custom_action("yellow"));
  // banishing actions
   if (list_contains(getvar("BatMan_banish"),m)) encustom(custom_action("banish"));
  // summon mayflies (toward the end since it can result in free runaways)
   if (should_mayfly()) encustom(get_action($skill[summon mayfly swarm]));
  // vibrato punchcards
   boolean try_cards(int com, int obj, string note) {
      if (item_amount(to_item(com)) == 0 || item_amount(to_item(obj)) == 0) return false;
      encustom(to_event("use "+com+"; use "+obj,"!! "+note,2));
      return true;
   }
   switch (m) {
      case $monster[hulking construct]:
      case $monster[hulking construct (translated)]:
         if (try_cards(3146,3155,"ATTACK WALL")) break;
         if (try_cards(3146,3153,"ATTACK FLOOR")) break;
         if (try_cards(3146,3152,"ATTACK SELF")) break;
         break;
      case $monster[bizarre construct]:
      case $monster[bizarre construct (translated)]:
         if (item_amount($item[repaired El Vibrato drone]) > 0 && !is_goal($item[repaired El Vibrato drone]) && try_cards(3148,3154,"BUFF DRONE")) break;
         if (my_stat("hp") < 0.7*my_maxhp() && try_cards(3147,3151,"REPAIR TARGET")) break;
         if (have_effect($effect[fitter, happier]) < 5 && try_cards(3148,3151,"BUFF TARGET")) break;
         break;
      case $monster[lonely construct]:
      case $monster[lonely construct (translated)]:
         if (item_amount($item[broken El Vibrato drone]) > 0 && !is_goal($item[broken El Vibrato drone]) && try_cards(3147,3154,"REPAIR DRONE")) break;
         if (have_outfit("El Vibrato") && item_amount($item[El Vibrato power sphere]) > 0 && try_cards(3149,3156,"MODIFY SPHERE")) break;
         break;
      case $monster[towering construct]:
      case $monster[towering construct (translated)]:
         int evdgoals = 1 - to_int(have_familiar($familiar[El Vibrato megadrone]));
         foreach it in $items[broken El Vibrato drone, repaired El Vibrato drone, augmented El Vibrato drone, El Vibrato megadrone]
            evdgoals += to_int(has_goal(it) > 0) - to_int(item_amount(it) > 0);
         if (item_amount($item[El Vibrato drone]) > 0 && evdgoals > 0 && try_cards(3149,3154,"MODIFY DRONE")) break;
         if (item_amount($item[El Vibrato power sphere]) > 0 && !have_outfit("El Vibrato") && try_cards(3149,3156,"MODIFY SPHERE")) break;
         if (try_cards(3150,3154,"BUILD DRONE")) break;
         if (item_amount(to_item(3149)) > 4+evdgoals && item_amount(to_item(3146)) > 0 && item_amount(to_item(3155)) > 0 && try_cards(3149,3152,"MODIFY SELF")) break;
         break;
     // random custom actions
      case $monster[dirty thieving brigand]: encustom($item[meat vortex]); break;      // meat vortices vs. brigands
      case $monster[tomb rat]: encustom($item[tangle of rat tails]); break;            // tomb rat king! (may require safety checks)
      case $monster[clingy pirate (male)]: 
      case $monster[clingy pirate (female)]: if (has_goal(m) == 0) encustom($item[cocktail napkin]); break;  // cocktail napkins
      case $monster[hellseal pup]: if (!happened("sealwail")) encustom($item[seal tooth]); break;   // seal tooth vs. seal pup
      case $monster[wild seahorse]: if (item_amount($item[sea cowbell]) > 2 && get_property("lassoTraining") == "expertly" && 
                                        item_amount($item[sea lasso]) > 0) foreach it in $items[sea cowbell, sea cowbell, sea cowbell, sea lasso] encustom(it);
         encustom(to_event("runaway","endscombat",1)); break;
      case $monster[racecar bob]: case $monster[bob racecar]: if (get_property("questL11Palindome") == "started" && item_amount($item[photograph of a dog]) == 0)
         encustom($item[disposable instant camera]); break;
      case $monster[villainous minion]: if (my_path() != "License to Adventure" || get_property("_villainLairProgress").to_int() > 900) break;
         if (!get_property("_villainLairCanLidUsed").to_boolean()) encustom($item[razor-sharp can lid]);
         if (!get_property("_villainLairFirecrackerUsed").to_boolean()) encustom($item[knob goblin firecracker]);
         if (!get_property("_villainLairWebUsed").to_boolean()) encustom($item[spider web]); break;
     // upgrading abstractions                           TODO: are these triggered by goals?  if not, add is_goal() check
      case $monster[thinker of thoughts]: if (have_familiar($familiar[machine elf])) encustom($item[abstraction: action]); break;
      case $monster[perceiver of sensations]: if (have_familiar($familiar[machine elf])) encustom($item[abstraction: thought]); break;
      case $monster[performer of actions]: if (have_familiar($familiar[machine elf])) encustom($item[abstraction: sensation]); break;
     // pretentious artist's psychoses depend on target effect specified in BatMan_pretentioustarget
      case $monster[bag of Potatoes of Security]: switch (to_effect(getvar("BatMan_pretentioustarget"))) {
         case $effect[my breakfast with andrea]: encustom($item[artist's butterknife of regret],true); break;
         case $effect[the champion's breakfast]: encustom($item[artist's cr&egrave;me brul&eacute;e torch of fury],true); break;
         case $effect[tiffany's breakfast]: encustom($item[artist's whisk of misery],true); break;
         case $effect[breakfast clubbed]: encustom($item[artist's cookie cutter of loneliness],true); encustom($item[artist's spatula of despair],true); break;
      } break;
      case $monster[box of Batter Mix of Hope]: switch (to_effect(getvar("BatMan_pretentioustarget"))) {
         case $effect[my breakfast with andrea]: encustom($item[artist's spatula of despair],true); break;
         case $effect[the champion's breakfast]: encustom($item[artist's whisk of misery],true); break;
         case $effect[tiffany's breakfast]: encustom($item[artist's cookie cutter of loneliness],true); break;
         case $effect[breakfast clubbed]: encustom($item[artist's butterknife of regret],true); encustom($item[artist's cr&egrave;me brul&eacute;e torch of fury],true); break;
      } break;
      case $monster[bundle of Meat of Happiness]: switch (to_effect(getvar("BatMan_pretentioustarget"))) {
         case $effect[my breakfast with andrea]: encustom($item[artist's butterknife of regret],true); break;
         case $effect[the champion's breakfast]: encustom($item[artist's cookie cutter of loneliness],true); break;
         case $effect[tiffany's breakfast]: encustom($item[artist's spatula of despair],true); break;
         case $effect[breakfast clubbed]: encustom($item[artist's cr&egrave;me brul&eacute;e torch of fury],true); encustom($item[artist's whisk of misery],true); break;
      } break;
      case $monster[carton of Eggs of Confidence]: switch (to_effect(getvar("BatMan_pretentioustarget"))) {
         case $effect[my breakfast with andrea]: encustom($item[artist's whisk of misery],true); break;
         case $effect[the champion's breakfast]: encustom($item[artist's cr&egrave;me brul&eacute;e torch of fury],true); break;
         case $effect[tiffany's breakfast]: encustom($item[artist's spatula of despair],true); break;
         case $effect[breakfast clubbed]: encustom($item[artist's cookie cutter of loneliness],true); encustom($item[artist's butterknife of regret],true); break;
      } break;
      case $monster[loaf of Bread of Wonder]: switch (to_effect(getvar("BatMan_pretentioustarget"))) {
         case $effect[my breakfast with andrea]: encustom($item[artist's butterknife of regret],true); break;
         case $effect[the champion's breakfast]: encustom($item[artist's cr&egrave;me brul&eacute;e torch of fury],true); break;
         case $effect[tiffany's breakfast]: encustom($item[artist's cookie cutter of loneliness],true); break;
         case $effect[breakfast clubbed]: encustom($item[artist's spatula of despair],true); encustom($item[artist's whisk of misery],true); break;
      } break;
     // skate decoys for goals
      case $monster[grouper groupie]: if (is_goal($item[grouper fangirl]) && item_amount($item[ice skate decoy]) > 0 && !happened($item[ice skate decoy]))
         encustom(to_event("use 4231","item grouper fangirl",1)); break;
      case $monster[urchin urchin]: if (is_goal($item[urchin roe]) && item_amount($item[roller skate decoy]) > 0 && !happened($item[roller skate decoy]))
         encustom(to_event("use 4210","item urchin roe",1)); break;
     // special insta-killers
      case $monster[gargantulihc]: encustom($item[plus-sized phylactery],true); break;
      case $monster[bugbear scientist]: if (get_property("statusScienceLab") == "open") encustom($item[quantum nanopolymer spider web],true); break;
      case $monster[liquid metal bugbear]: if (get_property("statusEngineering") == "open") encustom($item[drone self-destruct chip],true); break;
      case $monster[guy made of bees]: encustom($item[antique hand mirror]);
         encustom(to_event("runaway","endscombat",1)); break;
      case $monster[cyrus the virus]: for i from 4011 to 4016
          if (item_amount(to_item(i)) > 0 && !contains_text(get_property("usedAgainstCyrus"),to_item(i))) {
             encustom(to_item(i),true); break;
          }
         encustom(to_event("runaway","endscombat",1)); break;
      case $monster[the big wisniewski]:
      case $monster[the man]: if (get_property("hippiesDefeated") == "999" && get_property("fratboysDefeated") == "999") encustom($item[flaregun],true); break;
      case $monster[guard turtle]: if (!contains_text(page,"frenchturtle.gif")) break;       
      case $monster[french guard turtle]: if (have_equipped($item[fouet de tortue-dressage])) for i from 1 to 5 encustom($skill[apprivoisez la tortue]); break;
      case $monster[thug 1 and thug 2]: if (item_amount($item[jar full of wind]) > 9) for i from 1 to 10 encustom($item[jar full of wind]); break;
      case $monster[the bat in the spats]: if (item_amount($item[clumsiness bark]) > 9) for i from 1 to 10 encustom($item[clumsiness bark]); break;
      case $monster[the large-bellied snitch]: if (item_amount($item[dangerous jerkcicle]) > 7) for i from 1 to 10 encustom($item[dangerous jerkcicle]); break;
      case $monster[mammon the elephant]: if (item_amount($item[dangerous jerkcicle]) > 5) for i from 1 to 6 encustom($item[dangerous jerkcicle]); break;
      case $monster[the landscaper]: if (item_amount($item[grass clippings]) > 2) for i from 1 to 3 encustom($item[grass clippings]); break;
      case $monster[pair of burnouts]: encustom($item[opium grenade],true); break;
      case $monster[angry tourist]: case $monster[garbage tourist]: if (get_property("dinseyTouristsFed").to_int() < 30)
         encustom($item[complimentary Dinsey refreshments],true); break;
      case $monster[one of Doctor Weirdeaux's creations]: if (get_property("questESpClipper") == "started" && !happened($item[military-grade fingernail clippers]))
         for i from max(get_property("fingernailsClipped").to_int(),21) upto 23 encustom($item[military-grade fingernail clippers]); break;
     // highway trucks
      case $monster[fire truck]: custom.clear(); for i from 1 to 3 encustom($skill[awesome balls of fire]); break;
      case $monster[ice cream truck]: custom.clear(); for i from 1 to 3 encustom($skill[snowclone]); break;
      case $monster[monster hearse]: custom.clear(); for i from 1 to 3 encustom($skill[raise backup dancer]); break;
      case $monster[sewer tanker]: custom.clear(); for i from 1 to 3 encustom($skill[eggsplosion]); break;
      case $monster[sketchy van]: custom.clear(); for i from 1 to 3 encustom($skill[grease lightning]); break;
     // witch house defenses
      case $monster[school of gummi piranhas]: encustom($skill[snowclone]); break;
      case $monster[tricksy pixie]: encustom($skill[awesome balls of fire]); break;
      case $monster[candied pecan tree]: encustom($skill[raise backup dancer]); break;
      case $monster[licorice snake]: encustom($skill[eggsplosion]); break;
      case $monster[rock pop weasel]: encustom($skill[grease lightning]); break;
     // tower monsters
      case $monster[wall of skin]: encustom($item[beehive],true); break;
      case $monster[wall of bones]: encustom($item[electric boning knife],true); break;
   }
  // learn rave combos
   advevent unknown_rave() {
      if (available_amount($item[seeger's unstoppable banjo]) == 0 && where.zone != "Volcano") return new advevent;
      for i from 50 to 52 if (!have_skill(to_skill(i))) return new advevent;
      for i from 50 to 52 for j from 50 to 52 {
         if (j == i) continue;
         for k from 50 to 52 {
            if (k == j || k == i) continue;
            boolean found = false;
            for l from 1 to 6 if (get_property("raveCombo"+l) == to_skill(i)+","+to_skill(j)+","+to_skill(k)) found = true;
            if (!found) return merge(merge(to_event("skill "+i,factors["skill",i],1), to_event("skill "+j,factors["skill",j],1)), to_event("skill "+k,factors["skill",k],1));
         }
      }
      return new advevent;
   }
   encustom(unknown_rave());
   if (to_boolean(getvar("BatMan_onlycustomitems"))) foreach i,v in opts 
      if (index_of(v.id,"use ") == 0 && v.custom == "") remove opts[i];
   vprint("Custom actions built! ("+count(custom)+" actions)",9);
}

// special cases for stasis              maces            faces                        basis                           hey sis
boolean is_our_huckleberry() {
   if (my_stat("hp") < round(m_dpr(0,0)*2)) return vprint("Your huckleberry will kill you.",-9);
   if (item_amount($item[molybdenum magnet]) > 0 && !happened("lackstool") &&
       $monsters[batwinged gremlin, erudite gremlin, spider gremlin, vegetable gremlin] contains m) {
      if (where == to_location(get_property("currentJunkyardLocation")))
         return (item_drops() contains to_item(get_property("currentJunkyardTool")));
      return (!(item_drops() contains to_item(get_property("currentJunkyardTool"))));
   }
   switch (where) {
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
         contains_text(getvar("BatMan_yellow"),m.to_string())) return vprint("Monsters in BatMan_yellow are your huckleberry.",9);
   return vprint("This monster is not your huckleberry.","black",-9);
}

void enqueue_custom() {
   sort custom by to_int(value.endscombat);  // move all combat-enders to the end of the queue
   foreach n,ev in custom {
      if (my_stat("mp") < ev.mp) continue;   // can't cast this skill (yet)
      boolean stunfirst = !is_our_huckleberry() && (adj.stun + ev.stun < 1 && !ev.endscombat && to_profit(stun_action(contains_text(ev.id,"use "))) >= 0 && buytime.id != "");  // should we stun?
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
      return (available_amount($item[seeger's unstoppable banjo]) > 0 || where.zone == "Volcano") ? get_property("raveCombo"+i) : "";
   }
   string seq(effect c) {
      switch (c) {
         case $effect[none]: return ravepref(5);                // rave steal is $effect[none]
         case $effect[rave nirvana]: return ravepref(2);
         case $effect[rave concentration]: return ravepref(1);
      } return "";
   }
   string[int] ord = split_string(seq(which),",");
   if (count(ord) < 2) return new advevent;
   advevent res;
   foreach i,s in ord {
      if (get_action(to_skill(s)).id == "") return new advevent;
      merge(res,get_action(to_skill(s)));
      if (to_int(to_skill(s)) < 53) res.dmg[$element[none]] += 5;    // rave combos are merge(1,2,3) + 15 dmg
   }
   if (-res.mp > my_maxmp()) return new advevent;
   float bonus = 0.3;
   switch (which) {                                                  // add meat/items profit gained
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
         res.meat += which == $effect[none] ? dcprofit/max(1,icount)+to_int($locations[outside the club, the haunted sorority house, lollipop forest] contains where)*9999999 : dcprofit; break;
      case $effect[rave nirvana]: bonus = 0.5;
   }
   return res;
}

void build_combos() {
   if (my_class() != $class[disco bandit]) return;
   void encombo(effect c) { advevent thec = to_combo(c); if (thec.id != "") combos[count(combos)] = thec; }
   vprint("Building disco combos...",9);
   if (meat_drop(m) > 0) encombo($effect[rave nirvana]);
   if ((should_pp && get_property("_raveStealCount").to_int() < 30) || where == $location[outside the club]) encombo($effect[none]);
   if (count(item_drops(m)) > 1 && !(my_fam() == $familiar[he-boulder] && have_effect($effect[everything looks yellow]) == 0 &&
       contains_text(getvar("BatMan_yellow"),m.to_string())))             // no need for +items if you're going to yellow ray
      encombo($effect[rave concentration]);
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

string stasis_repeat() {       // the string of repeat conditions for stasising
   int expskill() { int res; foreach s in $skills[] if (s.combat && have_skill(s)) res = max(res,mp_cost(s)); return res; }
   return "!hpbelow "+round(my_stat("hp"))+                                                 // hp
      (my_stat("hp") < my_maxhp() ? " && hpbelow "+my_maxhp() : "")+
      " && !mpbelow "+round(my_stat("mp"))+                                                 // mp
      (my_stat("mp") < min(expskill(),my_maxmp()) ? " && mpbelow "+min(expskill(),my_maxmp()) : "")+
      " && !pastround "+max(1,floor(mdata.maxround - 3 - kill_rounds(smack)))+                    // time to kill
      ((have_equipped($item[crown of thrones]) || have_equipped($item[buddy bjorn])) ? " && !match \"acquire an item\"" : "")+   // CoT/BB
      ((m == $monster[hellseal pup]) ? " && !match \"high-pitched screeching wail\"" : "")+ // hellseal pup
      ((my_fam() == $familiar[hobo monkey]) ? " && !match \"hands you some Meat\"" : "")+   // famspent
      ((my_fam() == $familiar[gluttonous green ghost]) ? " && match ggg.gif" : "")+
      ((my_fam() == $familiar[slimeling]) ? " && match slimeling.gif" : "");
}

boolean is_once(string id) {  // hackish but a big improvement over false repeats for once items
   if (!contains_text(id," ")) return false;
   string cat = excise(id,""," "); if (cat == "use") cat = "item";
   if (!(factors contains cat)) return vprint("Factors does not contain '"+cat+"'.",-3);
   if (!(factors[cat] contains to_int(excise(id," ","")))) return vprint("Factors["+cat+"] does not contain '"+excise(id," ","")+"'.",-3);
   return list_contains(factors[cat,to_int(excise(id," ",""))].special, "once");
}

string stasis() {
   if ($monsters[naughty sorority nurse, naughty sorceress, naughty sorceress (2),
       pufferfish, bonerdagon, toxic beastie, Daisy the Unclean] contains m) return page;    // never stasis these monsters
   if (m == $monster[quantum mechanic] && m_hit_chance() > 0.08) return page;  // avoid teleportitis
   stasis_action(is_our_huckleberry());
   attack_action();
   while ((to_profit(plink) > to_float(getvar("BatMan_profitforstasis")) || is_our_huckleberry()) &&
         (round < mdata.maxround - 3 - kill_rounds(smack) && die_rounds() > kill_rounds(smack))) {
      vprint("Top of the stasis loop.",9);
     // special actions
      enqueue_custom();
      enqueue_combos();
     // stasis action as picked by BatBrain -- macro it until anything changes
      if (plink.id == "" && vprint("You don't have any stasis actions.","olive",4)) break;
      if (is_once(plink.id)) enqueue(plink, false);
       else macro(plink, stasis_repeat());
      if (finished()) break;
      stasis_action();       // recalculate stasis/attack actions
      attack_action();
   }
   vprint("Stasis loop complete"+(count(queue) > 0 ? " (queue still contains "+count(queue)+" actions)." : "."),9);
   return page;
}

// NOTE: after running this script, changing these variables here in the script will have no
// effect.  You can view ("zlib vars") or edit ("zlib <settingname> = <value>") values in the CLI.
setvar("BatMan_flyereverything",true);
setvar("BatMan_puttybountiesupto",19);
setvar("BatMan_pretentioustarget",$effect[my breakfast with andrea]);
setvar("BatMan_onlycustomitems",false);
setvar("BatMan_attract","blooper, dairy goat, zombie waltzers, dirty old lihc, violent fungus","list of monster");
setvar("BatMan_banish","senile lihc, slick lihc, A.M.C. gremlin, pygmy orderlies","list of monster");
setvar("BatMan_yellow","knob goblin harem girl, 7-foot dwarf foreman, orcish frat boy spy, war hippy spy","list of monster");
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
   if (round < mdata.maxround && !is_our_huckleberry() && adj.stun < 1 && stun_action(false).stun > to_int(dmg_dealt(buytime.dmg) == 0) &&
       kill_rounds(smack) > 1 && min(buytime.stun-1, kill_rounds(smack)-1)*m_dpr(0,0)*meatperhp > buytime.profit) enqueue(buytime);
   macro();
   vprint("SmartStasis complete.",9);
}
