## Original script from: http://kolmafia.us/index.php/topic,527.msg2569.html#msg2569 [19 October 2006]
## Updated by Hippymon 13 November 2007
### Updated by Raven434 - 2009-02-13 
### There are 56 outfit based tattoos
##data obtained from http://kol.coldfront.net/thekolwiki/index.php/Outfits_by_number
### New Tat #10 added in
### Modded - there is no #13 listed in the outfits_by_number page

### Batrachomyomachia 2009-11-04
###
### converted to use a map
### fixed typos
### added outfits
### only hit server once
### checkpoint your outfit

string[string] tats; // map outfit name onto tattoo gif name
void init_tats() {
  tats["8-Bit Finery"] = "swordtat.gif";
  tats["Antique Arms And Armor"] = "armortat.gif";
  tats["Arrrbor Day Aparrrrrel"] = "arbortat.gif";
  tats["Arboreal Raiment"] = "wreathtat.gif";
  tats["Black Armaments"] = "blacktat.gif";
  tats["Bounty-Hunting Rig"] = "meattat.gif";
  tats["Bow Tux"] = "bowtat.gif";
  tats["Bugbear Costume"] = "bugbear.gif";
  tats["Cloaca-Cola Uniform"] = "cola1tat.gif";
  tats["Clockwork Apparatus"] = "clocktat.gif";
  tats["Crimbo Duds"] = "pressietat.gif";
  tats["Crimborg Assault Armor"] = "halotat.gif";
  tats["Cursed Zombie Pirate Costume"] = "zompirtat.gif";
  tats["Dire Drifter Duds"] = "spohobotat.gif";
  tats["Dwarvish War Uniform"] = "dwarvish.gif";
  tats["Dyspepsi-Cola Uniform"] = "cola2tat.gif";
  tats["El Vibrato Relics"] = "elvtat.gif";
  tats["Encephalic Ensemble"] = "jfishtat.gif";
  tats["EXtreme Cold-Weather Gear"] = "coldgear.gif";
  tats["Filthy Hippy Disguise"] = "hippy.gif";
  tats["Floaty Fatigues"] = "rock_tat.gif";
  tats["Frat Boy Ensemble"] = "fratboy.gif";
  tats["Frat Warrior Fatigues"] = "warfrattat.gif";
  tats["Furry Suit"] = "losertat.gif";
  tats["Glad Bag Glad Rags"] = "recyctat.gif";
  tats["Gnauga Hides"] = "gnaugatat.gif";
  tats["Grass Guise"] = "eggtat.gif";
  tats["Grimy Reaper's Vestments"] = "reapertat.gif";
  tats["Hodgman's Regal Frippery"] = "hodgmantat.gif";
  tats["Hot and Cold Running Ninja Suit"] = "ninja.gif";
  tats["Hyperborean Hobo Habiliments"] = "colhobotat.gif";
  tats["Knob Goblin Elite Guard Uniform"] = "eliteguard.gif";
  tats["Knob Goblin Harem Girl Disguise"] = "haremgirl.gif";
  tats["Mining Gear"] = "miner.gif";
  tats["Mutant Couture"] = "dnatat.gif";
  tats["OK Lumberjack Outfit"] = "canadiatat.gif";
  tats["Palmist Paraphernalia"] = "palmtat.gif";
  tats["Pork Elf Prizes"] = "pigirontat.gif";
  tats["Primitive Radio Duds"] = "vol_tat.gif";
  tats["Pyretic Panhandler Paraphernalia"] = "hothobotat.gif";
  tats["Radio Free Regalia"] = "radiotat.gif";
  tats["Roy Orbison Disguise"] = "orbisontat.gif";
  tats["Slimesuit"] = "slimetat.gif";
  tats["Star Garb"] = "startat.gif";
  tats["Swashbuckling Getup"] = "pirate.gif";
  tats["Tapered Threads"] = "ducttat.gif";
  tats["Tawdry Tramp Togs"] = "slehobotat.gif";
  tats["Terrifying Clown Suit"] = "clown.gif";
  tats["Terrycloth Tackle"] = "toweltat.gif";
  tats["Time Trappings"] = "hourtat.gif";
  tats["Tropical Crimbo Duds"] = "tropictat.gif";
  tats["Vestments of the Treeslayer"] = "arborween.gif";
  tats["Vile Vagrant Vestments"] = "stehobotat.gif";
  tats["War Hippy Fatigues"] = "warhiptat.gif";
  tats["Wumpus-Hair Wardrobe"] = "wumpustat.gif";
  tats["Yendorian Finery"] = "elbereth.gif";
}

void check_tats() {
  string tats_page = visit_url("account_tattoos.php");
  boolean checkpoint = false;
  foreach outfit, gif in tats {
    if ( !contains_text(tats_page, gif) ) {
      // missing this tat
      if ( have_outfit(outfit) ) {
	print("Getting tattoo for "+outfit);
	if (! checkpoint) {
	  cli_execute("checkpoint");
	  checkpoint = true;
        }
	outfit(outfit);
	visit_url("town_wrong.php?place=artist");
      } else print("Need "+outfit); 
    }
  }
  if (checkpoint) outfit("checkpoint");
}

void main() {
  init_tats();
  check_tats();
}
