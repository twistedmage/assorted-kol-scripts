// ================================================================
// Harry Crimboween's FightOptimizer.ash v1.1.09
// Modified by Therealtahu
// Many thanks to the KoLwiki which provided most of the formulas
// used in this script, and the data tables as well. And big
// props to everyone who spaded them out!
//
// Bugs, requests, etc via kmail please.
//
// This script looks for some optional properties which you can
// set to help it make better decisions. These are optional and
// the script will perform well even if they're not set.
//
//   galaktikQuestComplete    "true" if Doc gives you a discount
//   numAscensions            number of ascensions
//
// If you have downloaded the two files spading_hp_min.dat and
// spading_hp_max.dat, they should go in the "data" directory next
// to your "scripts" directory. KoLmafia will update these files
// if autospading is enabled.
//
// Version 1.1.09 - 8th Nov 2009
//    - add jiggle staff
//    - fix some spell damage formulae
//    - add tango of terror
//    - add LESS_PESSIMISTIC flag to make some formulae closer to average rather than worst case.
//
// Version 1.1.0B - April 5th.
//    - Updated LTS and Thrust Smack. 
//    - Fixed small bug with lts and thrust smack where the script 
//      attempted to use those skills with ranged weapons
//    - Updated script to work with the modifiers overhaul.
//      But there are still a few issues.
//    - Basic Hobo Spells added. No fully working overkill support yet.
//    - I think I have weapon percentage working correctly. Maybe.
//    - Criticals and fumbles are a little weird right now.
//	  - Long overdue Wormwood monsters added. I think the HP is set right. Maybe.
//	  - Due to one request, and the fact that is was mostly copy and paste
//      and was a cheap workaround, the haiku katana support has returned. 
//	    Hopefully, I didn't break it by readding.
//================================================================

// -- To do list --
// Familiar effects+damage
// Protection effects+damage (Saucespheres, Pointiness, etc)
// Stasis, if NS13 doesn't totally nerf it
// Handle Hotform/Coldform/etc
// Item use (mercenary, flare gun, plot hole, etc)
// Test the DB chaining
// Add hobo spells
// Jiggle staff (no fumble, no MP, guaranteed hit)
// Check every formula
// Change how critical chance work, there are additional as well as replacement ones now.

// -----------------------------------------------------------
// One-line helpers
// -----------------------------------------------------------
int min(int a, int b) { if (a <= b) return a; return b; }
int max(int a, int b) { if (a >= b) return a; return b; }
int pin(int low, int hi, int val) { return min(hi,max(low,val)); }
float min(float a, float b) { if (a <= b) return a; return b; }
float max(float a, float b) { if (a >= b) return a; return b; }
float pin(float low, float hi, float val) { return min(hi,max(low,val)); }
float percentage(float val) { return pin(0.0, 1.0, val); }
int capped(int max, int val) { return min(max,val); }
int cappedMyst(int max) { return capped(max, my_buffedstat($stat[Mysticality])); }
int cappedLevel(int max) { return capped(max, my_level()); }
int uncappedMuscle() { return my_buffedstat($stat[Muscle]); }
int uncappedMyst() { return my_buffedstat($stat[Mysticality]); }
int uncappedMoxie() { return my_buffedstat($stat[Moxie]); }

// -----------------------------------------------------------
// Important globals
// -----------------------------------------------------------

string  OPPONENT;
int     ROUND;
string  PAGE;
int     INITIAL_MP = my_mp();
int     INITIAL_HP = my_hp();
boolean HIDDEN_DAMAGE = false;

boolean[int] NOODLED;
boolean[int] STUNNED;
boolean[int] BLEEDING;

boolean DEBUG                        = false; // show predicted damage for each action
boolean DEBUG_SIMULATOR              = false; // spews a whole lot, showing every step of every simulation
boolean WARNINGS_ARE_ERRORS          = false; // stop if damage is less than we predicted, etc
boolean ADJUST_STRATEGY_DURING_FIGHT = true;  // may slow down fights on slower computers
boolean AUTOSPADE_MONSTERS           = true;  // when an unknown monster is encountered, spade out its HP
boolean AUTOSPADE_AGGRESSIVELY       = false; // focus more on spading than optimization
boolean HOBOPOLIS_ADVENTURING        = true; // Enable FightOptimizer in Hobopolis. 
											  // This is basic support and may not overkill successfully.
											  // Use at your own risk.	
boolean HAIKU_TEST                   = false; // Disables all skills except for haiku katana skills. 
											  // This is so the script prioritizes katana skills. For testing only.
boolean LESS_PESSIMISTIC             = true; // Adjusts some formulae to give more likely figures
                                              // instead of absolute worst case.

if (in_hardcore()) AUTOSPADE_AGGRESSIVELY = false; // normally only softcore characters try hard at spading

// Properties that we check for
boolean GALAKTIK_DISCOUNT = to_boolean(get_property("galaktikQuestComplete"));
string ascensions_string = get_property("numAscensions");
int ASCENSIONS = to_int(ascensions_string);
if (ascensions_string == "") ASCENSIONS = 200; // assume the worst

// Spading maps.
int[string] spading_hp_min;      // Largest amount of damage inflicted without a kill
int[string] spading_hp_max;      // Smallest amount of damage inflicted with a kill
int total_damage_inflicted = 0;  // Keeps track of total damage inflicted

// Elements are enumerated as globals for convenience
element COLD   = $element[cold];
element HOT    = $element[hot];
element SPOOKY = $element[spooky];
element SLEAZE = $element[sleaze];
element STENCH = $element[stench];
element NONE   = $element[none];

// Many skills are enumerated as globals for convenience
skill NOODLES         = $skill[Entangling Noodles];
skill STREAM          = $skill[Stream of Sauce];
skill STORM           = $skill[Saucestorm];
skill WAVE            = $skill[Wave of Sauce];
skill GEYSER          = $skill[Saucegeyser];
skill RAVIOLI         = $skill[Ravioli Shurikens];
skill CANNON          = $skill[Cannelloni Cannon];
skill MORTAR_SHELL    = $skill[Stuffed Mortar Shell];
skill WEAPON          = $skill[Weapon of the Pastalord];
skill FETTUCINI       = $skill[Fearful Fettucini];
skill THRUST_SMACK    = $skill[Thrust-Smack];
skill LUNGE_SMACK     = $skill[Lunge-Smack];		// skill no longer available to new characters
skill LTS             = $skill[Lunging Thrust-Smack];
skill EYE_POKE        = $skill[Disco Eye-Poke];
skill DANCE           = $skill[Disco Dance of Doom];
skill DANCE_II        = $skill[Disco Dance II: Electric Boogaloo];
skill FACE_STAB       = $skill[Disco Face Stab];
skill TANGO           = $skill[Tango of Terror];
skill MANEUVER        = $skill[Moxious Maneuver];
skill HEADBUTT        = $skill[Headbutt];
skill KNEEBUTT        = $skill[Kneebutt];
skill SHIELDBUTT      = $skill[Shieldbutt];
skill HEADKNEE        = $skill[Head + Knee Combo];
skill HEADSHIELD      = $skill[Head + Shield Combo];
skill KNEESHIELD      = $skill[Knee + Shield Combo];
skill HEADKNEESHIELD  = $skill[Head + Knee + Shield Combo];

skill BANDAGES        = $skill[Lasagna Bandages];
skill SALVE           = $skill[Saucy Salve];
skill WALRUS_TONGUE   = $skill[Tongue of the Walrus];
skill OTTER_TONGUE    = $skill[Tongue of the Otter];
skill POWER_NAP       = $skill[Disco Power Nap];
skill NAP             = $skill[Disco Nap];

skill IMMACULATE_SEASONING = $skill[Immaculate Seasoning];
skill INTRINSIC_SPICINESS  = $skill[Intrinsic Spiciness];
skill STOAT                = $skill[Eye of the Stoat];
skill TERRAPIN             = $skill[Tao of the Terrapin];
skill HALF_SHELL           = $skill[Hero of the Half-Shell];

//Hobopolis stuff. Currently incomplete.
skill CAMPFIRE     = $skill[Conjure Relaxing Campfire];
skill CHILL      = $skill[Maximum Chill];
skill MUDBATH 		      = $skill[Mudbath];
skill LULLABY      = $skill[Creepy Lullaby];
skill BACKRUB      = $skill[Inappropriate Backrub];

//Haiku Katana skills
skill SEVENTEEN_CUTS 		= $skill[The 17 Cuts];
skill SPRING                = $skill[Spring Raindrop Attack];
skill SUMMER                = $skill[Summer Siesta];
skill FALL                  = $skill[Falling Leaf Whirlwind];
skill WINTER                = $skill[Winter's Bite Technique];

// Allow overrides for testing purposes.
boolean [skill] skill_simulate;
boolean [skill] skill_ignore;
//skill_ignore[THRUST_SMACK] = true;
boolean override_have_skill(skill s) {
    if (skill_simulate contains s) return true;
	if (skill_ignore contains s) return false;
	return have_skill(s);
}

// Some sauce spells are special.
boolean [skill] is_sauce;
is_sauce[STREAM] = true;
is_sauce[STORM]  = true;
is_sauce[WAVE]   = true;
is_sauce[GEYSER] = true;

// Some pasta skills are special.
boolean [skill] is_elemental_pasta;
is_elemental_pasta[RAVIOLI]   = true;
is_elemental_pasta[CANNON] = true;
is_elemental_pasta[MORTAR_SHELL] = true;

// Some skills confer bonus spell damage - but only for Sauceror spells.
int [element, skill] skill_saucespell_bonus;
int spiciness_level = my_level(); if (spiciness_level > 10) spiciness_level = 10;
skill_saucespell_bonus[NONE,   INTRINSIC_SPICINESS] = spiciness_level;

// Some pieces of equipment affect fumble chance
float [item] equipment_fumble_multiplier;
equipment_fumble_multiplier[$item[balloon sword]] = 0.0;
equipment_fumble_multiplier[$item[Chelonian Morningstar]] = 0.0;
equipment_fumble_multiplier[$item[plexiglass pendant]] = 0.0;
equipment_fumble_multiplier[$item[porquoise bracelet]] = 0.0;
equipment_fumble_multiplier[$item[porquoise eyebrow ring]] = 0.0;
equipment_fumble_multiplier[$item[pulled porquoise earring]] = 0.0;
equipment_fumble_multiplier[$item[spooky glove]] = 0.0;
equipment_fumble_multiplier[$item[tiny plastic Dr. Awkward]] = 0.0;
equipment_fumble_multiplier[$item[&quot;Humorous&quot; T-shirt]] = 2.0;
equipment_fumble_multiplier[$item[ridiculously overelaborate ninja weapon]] = 3.0;
equipment_fumble_multiplier[$item[vibrating cyborg knife]] = 3.0;

// Some passive skills affect fumble chance
float [skill] skill_fumble_multiplier;
skill_fumble_multiplier[STOAT] = 0.5;

// Some effects affect fumble chance
float [effect] effect_fumble_multiplier;
effect_fumble_multiplier[$effect[Chalky Hand]] = 0.0;
effect_fumble_multiplier[$effect[White Knuckles]] = 0.0;
effect_fumble_multiplier[$effect[Sticky Hands]] = 0.03; // I think I did this right. Maybe?

// Some pieces of equipment affect critical hit chance
int [item] equipment_crit_multiplier;
equipment_crit_multiplier[$item[Spirit Precipice]] = 5;
equipment_crit_multiplier[$item[stainless steel shillelagh]] = 4;
equipment_crit_multiplier[$item[clockwork crossbow]] = 3;
equipment_crit_multiplier[$item[clockwork staff]] = 3;
equipment_crit_multiplier[$item[clockwork sword]] = 3;
equipment_crit_multiplier[$item[giant cactus quill]] = 3;
equipment_crit_multiplier[$item[crazy bastard sword]] = 3;
equipment_crit_multiplier[$item[hamethyst earring]] = 3;
equipment_crit_multiplier[$item[hamethyst bracelet]] = 3;
equipment_crit_multiplier[$item[kneecapping stick]] = 3;
equipment_crit_multiplier[$item[repeating crossbow]] = 3;
equipment_crit_multiplier[$item[ridiculously overelaborate ninja weapon]] = 3;
equipment_crit_multiplier[$item[Hammer of Smiting]] = 3;
equipment_crit_multiplier[$item[enchanted brass knuckles]] = 2;
equipment_crit_multiplier[$item[giant discarded plastic fork]] = 2;
equipment_crit_multiplier[$item[prehistoric spear]] = 2;
equipment_crit_multiplier[$item[spooky bicycle chain]] = 2;
equipment_crit_multiplier[$item[Super Magic Power Sword X]] = 2;
equipment_crit_multiplier[$item[toy ray gun]] = 2;
equipment_crit_multiplier[$item[vorpal blade]] = 2;

// Shields are special for several Turtle Tamer skills
int [item] shield_power;
shield_power[$item[sewer turtle]]         = 20;
shield_power[$item[barskin buckler]]      = 27;
shield_power[$item[sebaceous shield]]     = 40;
shield_power[$item[box turtle]]           = 50;
shield_power[$item[balloon shield]]       = 55;
shield_power[$item[coffin lid]]           = 55;
shield_power[$item[pixel shield]]         = 55;
shield_power[$item[clownskin buckler]]    = 60;
shield_power[$item[cardboard box turtle]] = 70;
shield_power[$item[Cloaca-Cola shield]]   = 75;
shield_power[$item[Dyspepsi-Cola shield]] = 75;
shield_power[$item[demon buckler]]        = 77;
shield_power[$item[white satin shield]]   = 80;
shield_power[$item[gnauga hide buckler]]  = 95;
shield_power[$item[hippo skin buckler]]   = 95;
shield_power[$item[penguin skin buckler]] = 95;
shield_power[$item[yakskin buckler]]      = 95;
shield_power[$item[hors d'oeuvre tray]]   = 115;
shield_power[$item[snake shield]]         = 117;
shield_power[$item[snarling wolf shield]] = 117;
shield_power[$item[polyalloy shield]]     = 155; 
shield_power[$item[black shield]]         = 160;
shield_power[$item[star buckler]]         = 167;
shield_power[$item[wicker shield]]        = 175;
shield_power[$item[keg shield]]           = 175;
shield_power[$item[catskin buckler]]      = 177;
shield_power[$item[sawblade shield]]      = 180;
shield_power[$item[wonderwall shield]]    = 190;
shield_power[$item[six-rainbow shield]]   = 195;
shield_power[$item[duct tape buckler]]    = 200;
shield_power[$item[battered hubcap]]      = 220;
shield_power[$item[antique shield]]       = 230;
shield_power[$item[Brimstone Bunker]]     = 240;
shield_power[$item[Ol' Scratch's stove door]]   = 240;
shield_power[$item[pilgrim shield]]       = 240;
shield_power[$item[Zombo's shield]]       = 240;
shield_power[$item[Dallas Dynasty Falcon Crest shield]] = 240; // Unspaded, using lowest power

// Turtle helmets are special for Headbutt.
int [item] bonus_helmet_damage;
bonus_helmet_damage[$item[helmet turtle]]            = 5;
bonus_helmet_damage[$item[knobby helmet turtle]]     = 6;
bonus_helmet_damage[$item[skeletortoise]]            = 6;
bonus_helmet_damage[$item[furry green turtle]]       = 7;
bonus_helmet_damage[$item[Elder Turtle Shell]]       = 10;
bonus_helmet_damage[$item[asbestos helmet turtle]]   = 15;
bonus_helmet_damage[$item[chrome helmet turtle]]     = 15;
bonus_helmet_damage[$item[linoleum helmet turtle]]   = 15;
bonus_helmet_damage[$item[stainless steel skullcap]] = 20;
bonus_helmet_damage[$item[plexiglass pith helmet]]   = 25;

// Jiggle your staff (min damage). Useful as guaranteed hit, no fumble.
int [item] jiggle_damage_amount;
jiggle_damage_amount[$item[Staff of the Short Order Cook]]  = 10;
jiggle_damage_amount[$item[Staff of the Midnight Snack]]    = 10;
jiggle_damage_amount[$item[Staff of Blood and Pudding]]     = 0;	// steals 5-10 HP
jiggle_damage_amount[$item[Staff of the Teapot Tempest]]    = 10;
jiggle_damage_amount[$item[Staff of the Greasefire]]        = 8;	// 8 hot, 8 sleaze
jiggle_damage_amount[$item[Staff of the Black Kettle]]      = 20;
jiggle_damage_amount[$item[Staff of the Soupbone]]          = 20;	// spooky
jiggle_damage_amount[$item[Staff of the Well-Tempered Cauldron]]  = 30;	// spooky
jiggle_damage_amount[$item[Staff of the Walk-In Freezer]]   = 25;	// cold, also delevel 5-10
jiggle_damage_amount[$item[Staff of the Grand Flamb]]      = 35;	// hot
jiggle_damage_amount[$item[Staff of the Kitchen Floor]]     = 35;	// stench
jiggle_damage_amount[$item[Staff of the Grease Trap]]       = 35;	// sleaze
jiggle_damage_amount[$item[Staff of the Deepest Freeze]]    = 40;	// cold

element [item] jiggle_damage_type;
jiggle_damage_type[$item[Staff of the Short Order Cook]]  = NONE;
jiggle_damage_type[$item[Staff of the Midnight Snack]]    = NONE;
jiggle_damage_type[$item[Staff of Blood and Pudding]]     = NONE;
jiggle_damage_type[$item[Staff of the Teapot Tempest]]    = NONE;
jiggle_damage_type[$item[Staff of the Greasefire]]        = HOT;
jiggle_damage_type[$item[Staff of the Black Kettle]]      = NONE;
jiggle_damage_type[$item[Staff of the Soupbone]]          = SPOOKY;
jiggle_damage_type[$item[Staff of the Well-Tempered Cauldron]]  = SPOOKY;
jiggle_damage_type[$item[Staff of the Walk-In Freezer]]   = COLD;
jiggle_damage_type[$item[Staff of the Grand Flamb]]      = HOT;
jiggle_damage_type[$item[Staff of the Kitchen Floor]]     = STENCH;
jiggle_damage_type[$item[Staff of the Grease Trap]]       = SLEAZE;
jiggle_damage_type[$item[Staff of the Deepest Freeze]]    = COLD;

// This map helps us enumerate the player's equipment quickly
int [slot] equipment_slots;
equipment_slots[$slot[hat]]      = 1;
equipment_slots[$slot[weapon]]   = 1;
equipment_slots[$slot[off-hand]] = 1;
equipment_slots[$slot[shirt]]    = 1;
equipment_slots[$slot[pants]]    = 1;
equipment_slots[$slot[acc1]]     = 1;
equipment_slots[$slot[acc2]]     = 1;
equipment_slots[$slot[acc3]]     = 1;

// A few monsters are resistant to physical attacks
boolean [string] resists_physical;
resists_physical["chalkdust wraith"] = true;
resists_physical["ghost miner"] = true;
resists_physical["hulking construct"] = true;
resists_physical["snow queen"] = true;
resists_physical["ancient protector spirit"] = true;
resists_physical["protector spectre"] = true;

// A few monsters have stats that scale to the player's level,
// or simply aren't known by KoLmafia. We need to override
// the base attack/defense/hp values for these monsters.

int [int] scaling_monster_attack;
int [int] scaling_monster_defense;
int [int] scaling_monster_hp;

int SCALING_MONSTER_LOW = 0;
int SCALING_MONSTER_MEDIUM = 1;
int SCALING_MONSTER_HIGH = 2;
int SCALING_MONSTER_RATSWORTH = 3;
int SCALING_MONSTER_WORMWOOD = 4; // Assuming Wormwood monsters scale high.

scaling_monster_attack [SCALING_MONSTER_LOW] = max(1,my_buffedstat($stat[Moxie])) - 5;
scaling_monster_attack [SCALING_MONSTER_MEDIUM] = max(1,my_buffedstat($stat[Moxie]));
scaling_monster_attack [SCALING_MONSTER_HIGH] = max(1,my_buffedstat($stat[Moxie])) + 5;
scaling_monster_attack [SCALING_MONSTER_RATSWORTH] = max(1,my_buffedstat($stat[Moxie])) + 3 + capped(12,ASCENSIONS);
scaling_monster_attack [SCALING_MONSTER_WORMWOOD] = capped(125, max(1,my_buffedstat($stat[Moxie])) + 5);

scaling_monster_defense[SCALING_MONSTER_LOW] = max(1,my_buffedstat($stat[Muscle]) - 5);
scaling_monster_defense[SCALING_MONSTER_MEDIUM] = max(1,my_buffedstat($stat[Muscle]));
scaling_monster_defense[SCALING_MONSTER_HIGH] = max(1,my_buffedstat($stat[Muscle])) + 5;
scaling_monster_defense[SCALING_MONSTER_RATSWORTH] = max(1,my_buffedstat($stat[Muscle]) + 3 + capped(12,ASCENSIONS));
scaling_monster_defense[SCALING_MONSTER_WORMWOOD] = capped(125, max(1,my_buffedstat($stat[Muscle])) + 5);

scaling_monster_hp     [SCALING_MONSTER_LOW] = max(1,my_maxhp() * 0.70);
scaling_monster_hp     [SCALING_MONSTER_MEDIUM] = max(1,my_maxhp() * 0.80);
scaling_monster_hp     [SCALING_MONSTER_HIGH] = max(1,my_maxhp());
scaling_monster_hp     [SCALING_MONSTER_RATSWORTH] = max(1,my_maxhp() * 1.20);
scaling_monster_hp     [SCALING_MONSTER_WORMWOOD] = max(1,my_maxhp());

int [string] monster_attack_override;
int [string] monster_defense_override;
int [string] monster_hp_override;
element [string] monster_element_override;

void scaling_monster(string m, int which) {
 monster_attack_override [m] = scaling_monster_attack [which];
 monster_defense_override[m] = scaling_monster_defense[which];
 monster_hp_override     [m] = scaling_monster_hp     [which];
 monster_element_override[m] = NONE;
}

scaling_monster("candied yam golem",                SCALING_MONSTER_LOW);
scaling_monster("malevolent tofurkey",              SCALING_MONSTER_LOW);
scaling_monster("possessed can of cranberry sauce", SCALING_MONSTER_LOW);
scaling_monster("stuffing golem",                   SCALING_MONSTER_LOW);
scaling_monster("El Novio Cadáver",					SCALING_MONSTER_LOW);
scaling_monster("El Padre Cadáver",					SCALING_MONSTER_LOW);
scaling_monster("La Novia Cadáver",					SCALING_MONSTER_LOW);
scaling_monster("La Persona Inocente Cadáver",		SCALING_MONSTER_LOW);
scaling_monster("mutant gila monster",              SCALING_MONSTER_LOW);
scaling_monster("mutant rattlesnake",               SCALING_MONSTER_LOW);
scaling_monster("mutant saguaro",                   SCALING_MONSTER_LOW);
scaling_monster("swarm of mutant fire ants",        SCALING_MONSTER_LOW);
scaling_monster("mob penguin smith",                SCALING_MONSTER_MEDIUM);
scaling_monster("mob penguin smasher",              SCALING_MONSTER_MEDIUM);
scaling_monster("mob penguin supervisor",           SCALING_MONSTER_MEDIUM);
// New crimbo monsters basic support. Assuming medium case. Somehow, they break the script.
scaling_monster("Mob Penguin racketeer",            SCALING_MONSTER_MEDIUM);
scaling_monster("Mob Penguin goon",                 SCALING_MONSTER_MEDIUM);
scaling_monster("Mob Penguin enforcer",             SCALING_MONSTER_MEDIUM);
//scaling_monster("mutant cookie-baking elf"        SCALING_MONSTER_MEDIUM);
scaling_monster("mutant doll-dressing elf",         SCALING_MONSTER_MEDIUM);
scaling_monster("mutant gift-wrapping elf",         SCALING_MONSTER_MEDIUM);
scaling_monster("baron von ratsworth",              SCALING_MONSTER_RATSWORTH);
//Wormwood Monsters
scaling_monster("bellhop",                          SCALING_MONSTER_WORMWOOD);
scaling_monster("black cat",                        SCALING_MONSTER_WORMWOOD);
scaling_monster("ourang-outang",                    SCALING_MONSTER_WORMWOOD);
scaling_monster("raven",                            SCALING_MONSTER_WORMWOOD);
scaling_monster("usher",                            SCALING_MONSTER_WORMWOOD);
scaling_monster("ancient mariner",                  SCALING_MONSTER_WORMWOOD);
scaling_monster("angry poet",                       SCALING_MONSTER_WORMWOOD);
scaling_monster("kubla khan",                       SCALING_MONSTER_WORMWOOD);
scaling_monster("roller-skating muse",              SCALING_MONSTER_WORMWOOD);
scaling_monster("toothless mastiff bitch",          SCALING_MONSTER_WORMWOOD);
scaling_monster("can-can dancer",                   SCALING_MONSTER_WORMWOOD);
scaling_monster("courtesan",                        SCALING_MONSTER_WORMWOOD);
scaling_monster("master of ceremonies",             SCALING_MONSTER_WORMWOOD);
scaling_monster("sensitive poet-type",              SCALING_MONSTER_WORMWOOD);
scaling_monster("voyeuristic artist",               SCALING_MONSTER_WORMWOOD);
//Mt. Molehill

// NS13 monsters. Now that the script does autospading, I'm only putting monsters
// in here if we have a pinpointed value for them. These values should be accurate
// to within +- 1 HP.

monster_element_override["lord spookyraven"] = SPOOKY;
monster_element_override["possessed wine rack"] = SPOOKY;
monster_element_override["skeletal sommelier"] = SPOOKY;
monster_element_override["rattlin' duck"] = STENCH;
monster_element_override["frat warrior drill sergeant"] = SLEAZE;
monster_element_override["war frat 500th infantrygentleman"] = SLEAZE;
monster_element_override["brutus, the toga-clad lout"] = SLEAZE;
monster_element_override["man"] = SLEAZE; // The Man, to be precise
monster_element_override["big wisniewski"] = STENCH;

string[string] monster_remap;
monster_remap["ninja snowman"] = "ninja snowman (katana)";
monster_remap["knight"] = "knight (snake)";
monster_remap["overdone flame-broiled meat blob"] = "flame-broiled meat blob";

// A few monsters can only be defeated by a certain item.
item [string] item_monsters;
item_monsters["beer batter"]            = $item[baseball];
item_monsters["best-selling novelist"]  = $item[plot hole];
item_monsters["big meat golem"]         = $item[meat vortex];
item_monsters["bowling cricket"]        = $item[sonar-in-a-biscuit];
item_monsters["bronze chef"]            = $item[leftovers of indeterminate origin];
item_monsters["collapsed mineshaft golem"] = $item[stick of dynamite];
item_monsters["concert pianist"]        = $item[knob goblin firecracker];
item_monsters["darkness"]               = $item[inkwell];
item_monsters["el diablo"]              = $item[mariachi g-string];
item_monsters["electron submarine"]     = $item[photoprotoneutron torpedo];
item_monsters["endangered inflatable white tiger"] = $item[pygmy blowgun];
item_monsters["enraged cow"]            = $item[barbed-wire fence];
item_monsters["fancy bath slug"]        = $item[fancy bath salts];
item_monsters["fickle finger of f8"]    = $item[razor-sharp can lid];
item_monsters["flaming samurai"]        = $item[frigid ninja stars];
item_monsters["giant bee"]              = $item[tropical orchid];
item_monsters["giant desktop globe"]    = $item[NG];
item_monsters["giant fried egg"]        = $item[black pepper];
item_monsters["ice cube"]               = $item[hair spray];
item_monsters["malevolent crop circle"] = $item[bronzed locust];
item_monsters["possessed pipe-organ"]   = $item[powdered organs];
item_monsters["pretty fly"]             = $item[spider web];
item_monsters["tyrannosaurus tex"]      = $item[chaos butterfly];
item_monsters["vicious easel"]          = $item[disease];
item_monsters["guy made of bees"]       = $item[antique hand mirror];

// Monsters from the Orc Chasm are special.
boolean [string] dictionary_hurts;
dictionary_hurts["anime smiley"]  = true;
dictionary_hurts["1335 haxx0r"]   = true;
dictionary_hurts["flaming troll"] = true;
dictionary_hurts["lamz0r n00b"]   = true;
dictionary_hurts["me4t begz0r"]   = true;
dictionary_hurts["spam witch"]    = true;
dictionary_hurts["xxx pr0n"]      = true;

// Some skills delevel our opponent.
int [skill] skill_leveladj;
skill_leveladj[EYE_POKE]  = -1;
skill_leveladj[DANCE]     = -3;
skill_leveladj[DANCE_II]  = -5;
skill_leveladj[SHIELDBUTT]  = -5;
skill_leveladj[FACE_STAB] = -7;
skill_leveladj[TANGO] = -7;

// Some skills heal us in combat.
int [skill] skill_combat_heal;
skill_combat_heal[BANDAGES] = 10;
skill_combat_heal[SALVE] = 10;

// Some skills heal us out of combat.
// We use an average rather than our normal pessimistic value here.
int [skill] skill_noncombat_heal;
skill_noncombat_heal[BANDAGES]      = 20;
skill_noncombat_heal[WALRUS_TONGUE] = 35;
skill_noncombat_heal[OTTER_TONGUE]  = 15;
skill_noncombat_heal[POWER_NAP]     = 40;
skill_noncombat_heal[NAP]           = 20;

// Some skills can be chained in combat for extra effects.
string[string] skill_chain;
skill_chain["Disco Dance of Doom, Disco Eye-Poke"] = "Disco Blindness 1";
skill_chain["Disco Dance II: Electric Boogaloo, Disco Eye-Poke"] = "Disco Blindness 2";
skill_chain["Disco Dance II: Electric Boogaloo, Disco Dance of Doom, Disco Eye-Poke"] = "Disco Blindness 2";
skill_chain["Disco Dance of Doom, Disco Face Stab"] = "Disco Bleeding 1";
skill_chain["Disco Dance II: Electric Boogaloo, Disco Face Stab"] = "Disco Bleeding 2";
skill_chain["Disco Dance II: Electric Boogaloo, Disco Dance of Doom, Disco Face Stab"] = "Disco Bleeding 3";

// KoLmafia actually has pretty excellent support for stealing.
// When you are adventuring with items in your conditions list
// and you encounter a monster with the right drop, it will auto-steal
// if your dodge probability is high enough.
//
// However, it plays it safe and I want to encourage it a little more.
// That's what this table does. The higher the value we assign to the
// stolen loot, the more likely we will be to steal even if we'll
// get hit. Stealing will still only be chosen if FightOptimizer is
// sure you'll win the fight.
//
int [string] monster_bonus_loot;
monster_bonus_loot["gnollish gearhead"]= 500;  // empty meat tank - quest item
monster_bonus_loot["dairy goat"]       = 500;  // milk and cheese - quest item
monster_bonus_loot["astronomer"]       = 250;  // stars and lines - quest item
monster_bonus_loot["burrowing bishop"] = 250;
monster_bonus_loot["family jewels"]    = 250;
monster_bonus_loot["hooded warrior"]   = 250;
monster_bonus_loot["junk"]             = 250;
monster_bonus_loot["one-eyed willie"]  = 250;
monster_bonus_loot["pork sword"]       = 250;
monster_bonus_loot["skinflute"]        = 250;
monster_bonus_loot["trouser snake"]    = 250;
monster_bonus_loot["twig and berries"] = 250;
monster_bonus_loot["axe wound"]        = 250;
monster_bonus_loot["beaver"]           = 250;
monster_bonus_loot["box"]              = 250;
monster_bonus_loot["bush"]             = 250;
monster_bonus_loot["camel's toe"]      = 250;
monster_bonus_loot["flange"]           = 250;
monster_bonus_loot["honey pot"]        = 250;
monster_bonus_loot["little man in the canoe"] = 250;
monster_bonus_loot["muff"]             = 250;
if (available_amount($item[334 scroll]) < 2 &&
    available_amount($item[668 scroll]) < 1 &&
	available_amount($item[64735 scroll]) < 1) {
	monster_bonus_loot["1335 haxx0r"]      = 500; // 334 - quest item
	monster_bonus_loot["anime smiley"]     = 500; // 334 - quest item
}
if (available_amount($item[33398 scroll]) < 1 &&
    available_amount($item[64067 scroll]) < 1 &&
	available_amount($item[64735 scroll]) < 1)
	monster_bonus_loot["lamz0r n00b"]      = 500; // 33398 - quest item
if (available_amount($item[30669 scroll]) < 1 &&
    available_amount($item[64067 scroll]) < 1 &&
	available_amount($item[64735 scroll]) < 1)
	monster_bonus_loot["spam witch"]       = 500; // 30669 - quest item

// Some items are just nice to have.
monster_bonus_loot["booze giant"]      = 50;   // bottle of alcohol

// Some items can be used to plink a monster to determine its HP more accurately.
// This helps in spading.
boolean ambidextrous = override_have_skill($skill[Ambidextrous Funkslinging]);
item plink = $item[none];
item plink2 = $item[none];
int[item] plink_damage;
plink_damage[$item[spices]] = 1;
plink_damage[$item[turtle totem]] = 1;
plink_damage[$item[seal tooth]] = 1;
plink_damage[$item[spectre scepter]] = 4;
foreach i in plink_damage {
   if (item_amount(i) > 1) {
      if(plink == $item[none]) {
         plink = i; plink2 = i;
      } else if( plink_damage[i] > plink_damage[plink]) {
         plink = i; plink2 = i;
      }
   } else if (item_amount(i) > 0) {
      if (plink == $item[none])
         plink = i;
      else
         plink2 = i;
   }
}
if (!ambidextrous) plink2 = $item[none];


// ---------------------------------------------------------------
// Helper functions
// ---------------------------------------------------------------

boolean starts_with(string s, string prefix) { return (index_of(s,prefix) == 0); }
boolean ends_with(string s, string suffix) { int li = last_index_of(s,suffix); return ((li >= 0) && ((li + length(suffix)) == length(s))); }

string comma_join(string[int] list, int start) {
	string result = "";
	int end = count(list)-1;
	if (start <= end) result = list[start];
	if (start+1 <= count(list)-1)
		for i from start+1 upto count(list)-1
			result = result + ", " + list[i];
	return result;
}
string comma_join(string[int] list) { return comma_join(list,0); }
string[int] comma_split(string s) {
	if (s == "") { string[int] empty; return empty; }
	if (!contains_text(s,",")) { string[int] singleton; singleton[0] = s; return singleton; }
	return split_string(s," *, *");
}

void read_spade_maps() {
	// Safe to do unconditionally as of rev 4557
	file_to_map("spading_hp_min.dat", spading_hp_min);
	file_to_map("spading_hp_max.dat", spading_hp_max);
}

void write_spade_maps() {
	if (AUTOSPADE_MONSTERS && !HIDDEN_DAMAGE) {
		foreach key in spading_hp_min if (spading_hp_min[key] == 0) remove spading_hp_min[key];
		foreach key in spading_hp_max if (spading_hp_max[key] == 0) remove spading_hp_max[key];
		if (count(spading_hp_min) > 0)
			map_to_file(spading_hp_min, "spading_hp_min.dat");
		if (count(spading_hp_max) > 0)
			map_to_file(spading_hp_max, "spading_hp_max.dat");
	}
}

void error(string s) {
	write_spade_maps();
	abort("ERROR: " + s);
}

boolean[string] warned;
void warn(string s) {
	if (WARNINGS_ARE_ERRORS)
		error(s);
	else {
		if (!warned[s])
			print("WARNING: " + s,"red");
		warned[s] = true;
	}
}

// ---------------------------------------------------------------
// Iterator functions
// ---------------------------------------------------------------

int equipment_max(int [item] slice) {
	int result = 0;
	foreach x in equipment_slots result = max(result,slice[equipped_item(x)]);
	return result;
}

int equipment_sum(int [item] slice) {
	int result = 0;
	foreach x in equipment_slots result = result + slice[equipped_item(x)];
	return result;
}

float equipment_sum(float [item] slice) {
	float result = 0;
	foreach x in equipment_slots result = result + slice[equipped_item(x)];
	return result;
}

int effect_sum(int advs, int [effect] slice) {
	int result = 0;
	foreach eff in slice if (have_effect(eff) > advs) result = result + slice[eff];
	return result;
}

int effect_sum(int [effect] slice) {
	return effect_sum(0,slice);
}

int skill_sum(int [skill] slice) {
	int result = 0;
	foreach s in slice if (override_have_skill(s)) result = result + slice[s];
	return result;
}

float equipment_multiply(float [item] slice) {
	float result = 1.0;
	foreach x in equipment_slots
		if (slice contains equipped_item(x))
			result = result * slice[equipped_item(x)];
	return result;
}

float effect_multiply(float [effect] slice) {
	float result = 1.0;
	foreach eff in slice if (have_effect(eff) > 0) result = result * slice[eff];
	return result;
}

float skill_multiply(float [skill] slice) {
	float result = 1.0;
	foreach s in slice if (override_have_skill(s)) result = result * slice[s];
	return result;
}

// ---------------------------------------------------------------
// MP cost
// ---------------------------------------------------------------

// Some costs returned by kolmafia are currently wrong, so override here
int mp_cost_fixed(skill s) {
	if (s == CANNON) return 6;
	if (s == MORTAR_SHELL) return 13;
	if (s == WEAPON) return 24;
	if (s == FETTUCINI) return 24;
	return mp_cost(s);
}

// Combat MP cost estimates the cost of using a skill in combat.
// If we are fighting a monster that blocks skills, or if we have
// Cunctatitis, we increase our MP estimate.
int combat_mp_cost(skill s) {
	int multiplier = 1;
	if (contains_text(OPPONENT,"bonerdagon")) multiplier = 2;
	else if (have_effect($effect[Cunctatitis]) > 0) multiplier = 3;
	return mp_cost_fixed(s) * multiplier;
}

// Noncombat MP cost estimates the cost of using a skill outside of combat.
int noncombat_mp_cost(skill s) {
	return max(1,mp_cost(s)-mana_cost_modifier());
}

// ---------------------------------------------------------------
// Hat, pants, shield
// ---------------------------------------------------------------

int hat_power(item hat) {
	int p = get_power(hat);
	if (override_have_skill(TERRAPIN)) p = p*2;
	return p;
}
	
int pants_power(item pants) {
	int p = get_power(pants);
	if (override_have_skill(TERRAPIN)) p = p*2;
	return p;
}

boolean shield_equipped = shield_power contains equipped_item($slot[off-hand]);
boolean turtle_tamer = (my_class() == $class[Turtle Tamer]);

boolean hero_of_the_half_shell = override_have_skill(HALF_SHELL) && shield_equipped;

// ---------------------------------------------------------------
// Buffed attack/defense
// ---------------------------------------------------------------

int buffed_defense_stat() { return uncappedMoxie(); }

int buffed_damage_stat() {
	int mox = uncappedMoxie();
	if (hero_of_the_half_shell)
		return max(mox,uncappedMuscle());
	return mox;
}

int buffed_attack_stat() {
	// buffed_hit_stat() is currently wrong when a staff is equipped
	stat chs = current_hit_stat();
	if (chs == $stat[Mysticality]) chs = $stat[Muscle];
	return my_buffedstat(chs);
}

// ---------------------------------------------------------------
// Monster info
// ---------------------------------------------------------------

// We need to be pessimistic about monster level variance. The exact
// formula is unknown, which means this is nothing but a guess so far.
//
// If we guess too low, it's possible that a monster outlier will
//  not get killed on the round we expect and we'll end up beaten up.
// If we guess too high, we're going to consistently (and greatly)
//  underestimate the damage done by melee attacks.
//
int monster_level_variance(int base) {
	if (LESS_PESSIMISTIC)
		return 0;
	return pin(0,5,base/20);
}

int ml = monster_level_adjustment();
boolean monster_level_unknown = false;

int[string] monster_base_hp;
int monster_hp(string m, int leveladj) {
	if (monster_base_hp contains m) { return monster_base_hp[m] + ml + leveladj + monster_level_variance(monster_base_hp[m]); }
	int base = monster_hp(to_monster(m)) - ml;
	if (monster_hp_override contains m) base = monster_hp_override[m];
	if (base == 0 || base+ml == 0) {
		warn(m + " has unknown monster level!");
		monster_level_unknown = true;
		base = 40;
		if (spading_hp_max contains OPPONENT || spading_hp_min contains OPPONENT) {
			int spading_min = min(spading_hp_min[OPPONENT],spading_hp_max[OPPONENT]);
			int spading_max = max(spading_hp_min[OPPONENT],spading_hp_max[OPPONENT]);
			if (spading_min == 0) spading_min = spading_max;
			int spading_min_plus_third = (2*spading_min + spading_max) / 3;
			if (spading_min_plus_third - spading_min > 20) base = spading_min_plus_third;
			else base = spading_min;
			warn("acting as if the monster has " + base + " base HP");
		}
	}
	monster_base_hp[m] = base;
	if (DEBUG) print("monster_hp: " + base + " + " + ml + " + " + leveladj + " + " + monster_level_variance(base));
	return base + ml + leveladj + monster_level_variance(base);
}

int[string] monster_base_attack;
int monster_attack(string m, int leveladj) {
	if (monster_base_attack contains m) { return monster_base_attack[m] + ml + leveladj + monster_level_variance(monster_base_attack[m]); }
	int base = monster_attack(to_monster(m)) - ml;
	if (monster_attack_override contains m) base = monster_attack_override[m];
	if (base == 0 || base+ml == 0) {
		warn(m + " has unknown monster level!");
		monster_level_unknown = true;
		base = 40;
		monster_hp(m,leveladj);
		if (monster_base_hp contains OPPONENT) {
			base = monster_base_hp[OPPONENT]; // assume equal, we'll scale up if necessary
			string loc = to_string(my_location());
			if (contains_text(loc,"Frat Uniform") || contains_text(loc,"Hippy Uniform"))
				base = min(200,max(140,base * 0.72)); // Battlefield monsters seem to have more HP than attack/defense
		}
		warn("acting as if the monster has " + base + " base attack");
	}
	monster_base_attack[m] = base;
	if (DEBUG) print("monster_attack: " + base + " + " + ml + " + " + leveladj + " + " + monster_level_variance(base));
	return base + ml + leveladj + monster_level_variance(base);
}

int[string] monster_base_defense;
int monster_defense(string m, int leveladj) {
	if (monster_base_defense contains m) { return monster_base_defense[m] + ml + leveladj + monster_level_variance(monster_base_defense[m]); }
	int base = monster_defense(to_monster(m)) - ml;
	if (monster_defense_override contains m) base = monster_defense_override[m];
	if (base == 0 || base+ml == 0) {
		warn(m + " has unknown monster level!");
		monster_level_unknown = true;
		base = monster_attack(m, leveladj) - ml - leveladj;	// assume defense same as attack
		monster_hp(m,leveladj);
		if (monster_base_attack contains OPPONENT) {
			base = monster_base_attack[OPPONENT]; // assume equal, we'll scale up if necessary
			// TODO: should spade this
// 			string loc = to_string(my_location());
// 			if (contains_text(loc,"Frat Uniform") || contains_text(loc,"Hippy Uniform"))
// 				base = min(40,max(40,base * 0.72)); // Battlefield monsters seem to have more HP than attack/defense
		}
		warn("acting as if the monster has " + base + " base defense");
	}
	monster_base_defense[m] = base;
	if (DEBUG) print("monster_defense: " + base + " + " + ml + " + " + leveladj + " + " + monster_level_variance(base));
	return base + ml + leveladj + monster_level_variance(base);
}

element[string] monster_element_cache;
element monster_element(string m) {
	if (monster_element_cache contains m) return monster_element_cache[m];
	element e = monster_element(to_monster(m));
	if (monster_element_override contains m) e = monster_element_override[m];
	else if (e == NONE && to_monster(m) == $monster[none]) { // do some basic location guessing for unknown monsters
		string loc = to_string(my_location());
		if (contains_text(loc,"Frat Uniform")) e = STENCH;
		else if (contains_text(loc,"Hippy Camp")) e = STENCH;
		else if (contains_text(loc,"Hippy Uniform")) e = SLEAZE;
		else if (contains_text(loc,"Frat House")) e = SLEAZE;
		else if (contains_text(loc,"Haunted")) e = SPOOKY;
	}
	monster_element_cache[m] = e;
	return e;
}

// Computes the percentage chance that m can hit us, as a value from 0.0-1.0.
// Because critical hits are factored in, this never returns a value less than 0.06.
float [string, int, int] monster_hit_cache;
float monster_hit_percentage(string m, int leveladj)
{
	// Let's be pessimistic and assume the worst.
	// (This is very pessimistic and can result in no possible successful strategy).
	if (!LESS_PESSIMISTIC)
		return 1.0;
	
	int bds = buffed_defense_stat();
	if (monster_hit_cache[m,leveladj] contains bds) return monster_hit_cache[m,leveladj,bds];
	
	// http://kol.coldfront.net/thekolwiki/index.php/Hit_Chance
	float base = percentage((6.5 + (monster_attack(m,leveladj) - bds)) / 12.0);
	float crit = 0.06;
	float fumb = 0.06;
	float hit = base * (1 - (crit+fumb));
	float total = percentage(hit+crit);
	
	//if (DEBUG) print("" + m + " hit: " + to_int(total*100) + "%");
	monster_hit_cache[m,leveladj,bds] = total;
	return total;
}

// Computes the monster's average damage per round against us. This is
// a pessimistic value which accounts for critical hits and even Cunctatitis.
int [string, int, int] monster_damage_cache;
int monster_damage(string m, int leveladj)
{
	int bds = buffed_damage_stat();
	if (monster_damage_cache[m,leveladj] contains bds) return monster_damage_cache[m,leveladj,bds];
	float mhp = monster_hit_percentage(m,leveladj);
	int ma = monster_attack(m,leveladj);
	int diff = max(0,ma - bds);
	int base = max(0,diff + ma/4 - damage_reduction());
	float absorbFrac = (damage_absorption_percent() / 100.0);
	float elementalFrac = (elemental_resistance(to_monster(m)) / 100.0);
	int hitDamage = max(0,to_int(base * (1-absorbFrac) * (1-elementalFrac)));
	int damagePerRound = mhp * hitDamage;
	
	// If we've gotten lazy, we may need to repeat our actions an average of 3 times,
	// giving the monster more opportunities to whack us.
	if (have_effect($effect[Cunctatitis]) > 0) damagePerRound = damagePerRound * 3;
	
	if (DEBUG) print("" + m + ": mhp " + mhp + ", diff " + diff + ", hitDamage " + hitDamage + ", damage per round: " + damagePerRound);
	monster_damage_cache[m,leveladj,bds] = damagePerRound;
	return damagePerRound;
}

// -----------------------------------------------------------------------
//  Player hit percentages
// -----------------------------------------------------------------------

float fumble_percentage = percentage(
	(1.0/22.0) * equipment_multiply(equipment_fumble_multiplier)
	           * skill_multiply(skill_fumble_multiplier)
			   * effect_multiply(effect_fumble_multiplier));

float stoat_crit_modifier = 0.0;
if (override_have_skill(STOAT)) stoat_crit_modifier = 0.5;
float crit_percentage = percentage(
	(1.0/11.0) * (numeric_modifier("Critical") + stoat_crit_modifier));

float [string, int, int] hit_percentage_cache;
float hit_percentage(string m, int leveladj)
{
	int bas = buffed_attack_stat();
	if (hit_percentage_cache[m,leveladj] contains bas) return hit_percentage_cache[m,leveladj,bas];
	
	// http://kol.coldfront.net/thekolwiki/index.php/Hit_Chance
	float base = percentage((6.0 + buffed_attack_stat() - monster_defense(m,leveladj)) / 10.5);
	float normalhit = percentage((1-fumble_percentage)*(base-crit_percentage));
	float criticalhit = percentage(min(base,crit_percentage));
	if (DEBUG) print("Hit Percentage: base "+to_int(base*100)+", normal "+to_int(normalhit*100)+", critical "+to_int(criticalhit*100)+", final = "+to_int((normalhit+criticalhit)*100));
	float result = percentage(normalhit+criticalhit);
	hit_percentage_cache[m,leveladj,bas] = result;
	return result;
}

float smack_hit_percentage(string m, int leveladj,skill s)
{
	// NS13 changed Stoat from 100% hit to something else. We'll guess it's +20 to muscle for hit calculation for Lunge. 
	//It's actually +25% if not seal clubber. +30% for SC. LTS
	// Also, we should only do Stoat calculations if we're using Muscle as our hit stat.
	if (override_have_skill(STOAT) && (current_hit_stat() != $stat[Moxie])){
// 		if (s == LUNGE_SMACK) return hit_percentage(m,leveladj-20);		// don't think this is right
		if (s == THRUST_SMACK) return hit_percentage(m,leveladj-20);
		if (s == LTS) {
			if (my_class() == $class[Seal Clubber]) return hit_percentage(m,leveladj-my_buffedstat($stat[Muscle])*.3);
			else 
				return hit_percentage(m,leveladj-my_buffedstat($stat[Muscle])*.25);}}
	return hit_percentage(m,leveladj);
}

float maneuver_hit_percentage(string m, int leveladj)
{
	// http://kol.coldfront.net/thekolwiki/index.php/Hit_Chance
	float base = percentage((6.0 + uncappedMoxie() - monster_defense(m,leveladj)) / 10.5);
	float normalhit = percentage((1-fumble_percentage)*(base-crit_percentage));
	float criticalhit = percentage(min(base,crit_percentage));
	if (DEBUG) print("Maneuver Hit Percentage: base "+to_int(base*100)+", normal "+to_int(normalhit*100)+", critical "+to_int(criticalhit*100)+", final = "+to_int((normalhit+criticalhit)*100));
	return percentage(normalhit+criticalhit);
}

float knee_hit_percentage(string m, int leveladj)
{
	// Kneebutt is theorized to add 20 to your attack stat for hit calculation. This
	// is equivalent to subtracting 20 from monster level.
	return hit_percentage(m,leveladj-20);
}

// ---------------------------------------------------------------
// Spell damage
// ---------------------------------------------------------------

// Since equipment does not change during the fight, these can be
// safely computed just once.
int[element] spell_bonus;
spell_bonus[NONE]   = numeric_modifier("Spell Damage");
spell_bonus[HOT]    = numeric_modifier("Hot Spell Damage");
spell_bonus[COLD]   = numeric_modifier("Cold Spell Damage");
spell_bonus[SPOOKY] = numeric_modifier("Spooky Spell Damage");
spell_bonus[STENCH] = numeric_modifier("Stench Spell Damage");
spell_bonus[SLEAZE] = numeric_modifier("Sleaze Spell Damage");

float spell_damage_percent(){
return numeric_modifier("Spell Damage Percent")/100;
}
int bonus_spell_damage(element which, skill s)
{
	int bsd = numeric_modifier("Spell Damage");
	//Temp fix for Spell Damage. Elemental spell damage is added twice. 
	//Sloppy, but it works.
	bsd = bsd - spell_bonus[HOT] - spell_bonus[COLD] - spell_bonus[SPOOKY]
	- spell_bonus[STENCH] - spell_bonus[SLEAZE];
	// Get the bonus spell damage from equipment.
	bsd = bsd + spell_bonus[which];
	
	// Sauceror-specific bonus damage.
	boolean sauce = is_sauce[s];
	if (sauce) bsd = bsd + skill_sum(skill_saucespell_bonus[NONE]);
	if (sauce && which != NONE) bsd = bsd + skill_sum(skill_saucespell_bonus[which]);
	
	return bsd;
}

element get_offense_element(skill s)
{
	// Elemental forms override everything else.
	if (have_effect($effect[Hotform]) > 0)    return HOT;
	if (have_effect($effect[Coldform]) > 0)   return COLD;
	if (have_effect($effect[Stenchform]) > 0) return STENCH;
	if (have_effect($effect[Spookyform]) > 0) return SPOOKY;
	if (have_effect($effect[Sleazeform]) > 0) return SLEAZE;
	
	element e = NONE;
	boolean pasta = is_elemental_pasta[s];
	boolean sauce = is_sauce[s];
	
	// Many combat spells are affected by cookbooks.
	if (pasta && have_equipped($item[Necrotelicomnicon]))                         e = SPOOKY;
	if (pasta && have_equipped($item[Cookbook of the Damned]))                    e = STENCH;
	if (pasta && have_equipped($item[Sinful Desires]))                            e = SLEAZE;
	if ((pasta || sauce) && have_equipped($item[Gazpacho's Glacial Grimoire]))    e = COLD;
	if ((pasta || sauce) && have_equipped($item[Codex of Capsaicin Conjuration])) e = HOT;
	
	// A few spells are always a particular element.
	if (s == WEAPON)    e = NONE;
	if (s == FETTUCINI) e = SPOOKY;
	//Hobopolis Spells
	if (s == CAMPFIRE) e = HOT;
	if (s == CHILL) e = COLD;
	if (s == MUDBATH) e = STENCH;
	if (s == LULLABY) e = SPOOKY;
	if (s == BACKRUB) e = SLEAZE;
	
	// Pastamancer spells can be affected by Flavour of Magic.
	if (e == NONE && pasta) {
		if (have_effect($effect[Spirit of Cayenne]) > 0)      e = HOT;
		if (have_effect($effect[Spirit of Peppermint]) > 0)   e = COLD;
		if (have_effect($effect[Spirit of Garlic]) > 0)       e = STENCH;
		if (have_effect($effect[Spirit of Wormwood]) > 0)     e = SPOOKY;
		if (have_effect($effect[Spirit of Bacon Grease]) > 0) e = SLEAZE;
	}
	
	// Sauce spells always pick the right element if you have Immaculate Seasoning.
	if (sauce && e == NONE && override_have_skill(IMMACULATE_SEASONING)) {
		element defense = monster_element(OPPONENT);
		if (defense == COLD || defense == SPOOKY) e = HOT;
		if (defense == SLEAZE || defense == STENCH || defense == HOT) e = COLD;
		
		// The beatles take double damage from hot and sleaze, but aren't otherwise elemental.
		if (OPPONENT == "swarm of scarab beatles") e = HOT;
		
		// If we still didn't pick anything, but we have hot- or cold-enhancing
		// gear or effects, Immaculate Seasoning will pick that.
		if (e == NONE) {
			int hotBonus = numeric_modifier("Hot Spell Damage");
			int coldBonus = numeric_modifier("Cold Spell Damage");
			if (coldBonus > 0 && coldBonus > hotBonus) e = COLD;
			if (hotBonus > 0 && hotBonus >= coldBonus) e = HOT;
		}
	}
	
	return e;
}

int get_elemental_multiplier(element d, element o)
{
	if ((o == HOT    && (d == SPOOKY || d == COLD)) ||
		(o == SPOOKY && (d == COLD   || d == SLEAZE)) ||
		(o == COLD   && (d == SLEAZE || d == STENCH)) ||
		(o == SLEAZE && (d == STENCH || d == HOT)) ||
		(o == STENCH && (d == HOT    || d == SPOOKY)))
		return 2;
	if (o != NONE && o == d)
		return 0;
	return 1;
}

boolean is_random_element(skill s) {
	return (is_sauce[s] || is_elemental_pasta[s]) && (get_offense_element(s) == NONE);
}

int [skill,int] spell_damage_cache;
int [skill,int] spell_backlash;
int spell_damage(skill s)
{
	// If we've already computed the damage once, no need to do it again.
	int myst = uncappedMyst();
	if (spell_damage_cache[s] contains myst) return spell_damage_cache[s,myst];
	
	// Short-circuit for Entangling Noodles.
	if (s == NOODLES) { spell_damage_cache[s,myst] = 0; return 0; }
	
	// Compute the components of the damage
	element defense = monster_element(OPPONENT);
	element offense = get_offense_element(s);
	float multiplier = get_elemental_multiplier(defense, offense);
	int bsd = bonus_spell_damage(offense, s);
	
	// If we're using a normal (randomized) pasta spell and the monster has either
	// elemental defense or physical resistance, adjust the damage downward to reflect
	// the fact that we may get the wrong kind of spell 1/6 of the time.
	// Pasta spells never match monster element:
	// http://kol.coldfront.net/thekolwiki/index.php/Elemental_Spell_Damage
	if (is_elemental_pasta[s] && offense == NONE && resists_physical[OPPONENT])
		multiplier = 0.80; // really 0.833, but we want to penalize it a bit more
	
	// If the monster has elemental defense and we're using a normal (randomized)
	// sauce spell, adjust the damage downward to reflect the fact that we may get the
	// wrong element 50% of the time.
	if (offense == NONE && defense != NONE && is_sauce[s] && !override_have_skill(IMMACULATE_SEASONING)) {
		if (defense == HOT) multiplier = 0.40;  //  hot = 1 damage, cold = normal damage
		if (defense == COLD) multiplier = 0.80; // cold = 1 damage,  hot = double damage
	}
	
	// The beatles are special.
	if (OPPONENT == "swarm of scarab beatles" && (offense == HOT || offense == SLEAZE))
		multiplier = 2;
	
	// Use the KoLwiki's formula and return the minimum guaranteed damage.
	int base = 1;
	int cap = 1000000;
	if (s == STREAM)        { base = (3 +  (10*cappedMyst(100))/100); cap = 10; }
	if (s == STORM)         { base = (14 + (20*cappedMyst(125))/100); cap = 15; }
	if (s == WAVE)          { base = (20 + (30*cappedMyst(100))/100); cap = 25; }
	if (s == GEYSER)        { base = (35 + (35* uncappedMyst())/100); } // no cap seen yet, even with base+bsd=170
	if (s == RAVIOLI)       { base = (3 +  ( 7*cappedMyst(215))/100); cap = 25; }
	if (s == CANNON)        { base = (8 +  (15*cappedMyst(134))/100); cap = 40; }
	if (s == MORTAR_SHELL)  { base = (16 + (25*cappedMyst(120))/100); cap = 60; }
	if (s == WEAPON)        { base = (32 + (35* uncappedMyst())/100); } // no cap seen yet, even with base+bsd=150
	if (s == FETTUCINI)     { base = (32 + (35* uncappedMyst())/100); } // no cap seen yet, even with base+bsd=150
	//Hobopolis
	if (s == CAMPFIRE)      { base = (10 + (10* uncappedMyst())/100); }
	if (s == CHILL)         { base = (10 + (10* uncappedMyst())/100); }
	if (s == MUDBATH)       { base = (10 + (10* uncappedMyst())/100); }
	if (s == LULLABY)       { base = (10 + (10* uncappedMyst())/100); }
	if (s == BACKRUB)       { base = (10 + (10* uncappedMyst())/100); }
	if (base == 1) { warn("Don't know the formula for " +s+ "!\n"); multiplier = 0; }
	
	// NS13 damage cap
	// Here's my early guess as to how it works. There is a (random within a given range?)
	// damage cap which is applied to the base + bonus spell damage value. When you hit the cap,
	// here's what happens:
	//  - non-spellcasters: up to 11(?) damage is dealt to the player instead of the monster
	//  - spellcasters, pasta spell: get a warning message
	//  - spellcasters, sauce spell: get a warning message and an effect.
	// The effect you get doesn't seem to do much that's harmful.

	// TODO: Need to distinguish between generic spell damage bonus and element-specific.
	// See http://kol.coldfront.net/thekolwiki/index.php/Calculating_Spell_Damage
	// TODO: fix splashback
	if (bsd > cap)
	{
		if (my_primestat() != $stat[Mysticality]) {
// 			modified = cap - 11;
			spell_backlash[s,myst] = 11;
		}
		bsd = cap;
	}
	int modified = base + bsd;
	
	// NS13 chefstaff percentage bonuses are applied after the damage cap.
	int afterbonus = modified + (modified * spell_damage_percent());
	
	// Elemental and equipment multipliers
	// TODO: WEAPON can deal half physical, half elemental
	int damage = afterbonus * multiplier;
	if (damage == 0) damage = 1;
	
	// Log the expected damage and return
	if (DEBUG) print("" +s+ ": cap(" +base+ "+" +bsd+ ") = " +modified+ " + " +to_int(spell_damage_percent()*100)+ "% = " +afterbonus+ " * " +multiplier+ " = " +damage+ "\n");
	spell_damage_cache[s,myst] = damage;
	return damage;
}

// Jiggle your stuff - guaranteed hit, no MP
int jiggle_damage() {
	item weapon = equipped_item($slot[weapon]);
	if (!(jiggle_damage_amount contains weapon))
		return 0;

	element defense = monster_element(OPPONENT);
	element offense = jiggle_damage_type[weapon];

	int damage = get_elemental_multiplier(defense, offense) * jiggle_damage_amount[weapon];

	// Greasefire staff does 2 types of damage - nasty hack here
	if (weapon == $item[Staff of the Greasefire])
		damage = damage + get_elemental_multiplier(defense, SLEAZE) * jiggle_damage_amount[weapon];

	return damage;
}

// ---------------------------------------------------------------
// Melee/Ranged damage
// ---------------------------------------------------------------

int bonus_melee_damage() {
	return numeric_modifier("Weapon Damage");
}
boolean ranged_weapon_equipped = weapon_type(equipped_item($slot[weapon]))==$stat[moxie];

int bonus_ranged_damage(){
int bonus_ranged_damage = numeric_modifier("Ranged Damage");
	if (!ranged_weapon_equipped) 
		bonus_ranged_damage = 0;
return bonus_ranged_damage;
}

int bonus_elemental_damage() {
	int h  = numeric_modifier("Hot Damage");
	int c  = numeric_modifier("Cold Damage");
	int sp = numeric_modifier("Spooky Damage");
	int st = numeric_modifier("Stench Damage");
	int sl = numeric_modifier("Sleaze Damage");
	
	element d = monster_element(OPPONENT);
	if (d == HOT)    {  h = min( h,1); sl = sl*2; st = st*2; }
	if (d == SPOOKY) { sp = min(sp,1); st = st*2;  h =  h*2; }
	if (d == COLD)   {  c = min( c,1);  h =  h*2; sp = sp*2; }
	if (d == SLEAZE) { sl = min(sl,1); sp = sp*2;  c =  c*2; }
	if (d == STENCH) { st = min(st,1);  c =  c*2; sl = sl*2; }
	
	// Beatles are apparently special...
	if (OPPONENT == "swarm of scarab beatles") { h=h*2; sl=sl*2; }
	
	return h + c + sp + st + sl;
}

int [int, int, int] attack_damage_cache;
int attack_damage(int thrustSmackFactor, int leveladj)
{
	// If we already calculated this, use the previous value.
	int mus = uncappedMuscle();
	if (attack_damage_cache[thrustSmackFactor, leveladj] contains mus)
		return attack_damage_cache[thrustSmackFactor, leveladj, mus];
	
	item weapon = equipped_item($slot[weapon]);
	item offhand = equipped_item($slot[off-hand]);
	boolean barehanded = (weapon == $item[none]);
	boolean dualwield = (weapon_hands(offhand) == 1);
	
	// NS13 change: thrust-smack with 2 batblades now seems to underpredict
	// (Player Muscle * rangeadj) - Monster Defense, (minimum 0)
	// + 10% to 20% of Weapon Power * (crit) * (tsfactor) or 1 if barehanded
	// + 10% to 20% of Offhand Weapon Power * (crit) if double-wielding
	// + Bonus Melee Damage
	// + Bonus Ranged Damage (only when wielding a ranged weapon)
	// + Elemental Bonus Damage
	
	int adjustedAttack = mus;
	if (ranged_weapon_equipped) adjustedAttack = (adjustedAttack * 3) / 4;
	if (barehanded) adjustedAttack = adjustedAttack / 4;
	if (thrustSmackFactor == 3 && override_have_skill(STOAT) && current_hit_stat() != $stat[Moxie]) {
		if (my_class() == $class[Seal Clubber])
			adjustedAttack = adjustedAttack * 1.3;
		else
			adjustedAttack = adjustedAttack * 1.25;
	}
	
	int weaponPower = get_power(weapon);
	int offhandPower = get_power(offhand);
	if (have_effect($effect[Sharp Weapon]) > 0) {
		if (!barehanded) weaponPower = weaponPower + 30;
		if (dualwield) offhandPower = offhandPower + 30; // does this affect both?
	}
	if (have_effect($effect[Corroded Weapon]) > 0) {
		if (!barehanded) weaponPower = (weaponPower*80)/100;
		if (dualwield) offhandPower = (offhandPower*80)/100; // does this affect both?
	}
	// weaponDamage = (10-20% + 0..1) x (1 + crit%)
	int weaponDamage;
	if (LESS_PESSIMISTIC)
		weaponDamage = max(1,(weaponPower * 0.15) * thrustSmackFactor) * (1 + crit_percentage);
	else
		weaponDamage = max(1,(weaponPower / 10) * thrustSmackFactor);
	if (barehanded) weaponDamage = 1;
	if (dualwield) weaponDamage = weaponDamage + (offhandPower / 10);
	
	int WeaponPercentBonus = (max(adjustedAttack - monster_defense(OPPONENT,leveladj),0)
		+ weaponDamage + bonus_melee_damage()) * (numeric_modifier("Weapon Damage Percent")/100);
	// Break it up into the two main components.
	int physicalComponent = max(adjustedAttack - monster_defense(OPPONENT,leveladj),0)
		+ weaponDamage 
		+ bonus_melee_damage()
		+ WeaponPercentBonus
		+ bonus_ranged_damage();
	int elementalComponent = bonus_elemental_damage();
	
	// Handle physical resistance.
	if (resists_physical[OPPONENT])
		physicalComponent = 1;
	
	// This is our final result.
	int result = physicalComponent + elementalComponent;
	
	// Debug output.
	string what = "Attack";
	if (thrustSmackFactor == 2) what = "Thrust-Smack";
	if (thrustSmackFactor == 3) what = "Lunging Thrust-Smack";
	if (DEBUG) {print("Physical: " + max(adjustedAttack - monster_defense(OPPONENT,leveladj),0) + "+" + weaponDamage + "+" 
	+ bonus_melee_damage() + "+" + WeaponPercentBonus + "+" + bonus_ranged_damage() + " = " + physicalComponent);}
	if (DEBUG) print(what + ": " + physicalComponent + "+" + elementalComponent + " = " + result);
	
	// Stash it into our cache and return.
	attack_damage_cache[thrustSmackFactor, leveladj, mus] = result;
	return result;
}


// ---------------------------------------------------------------
// Workarounds
// ---------------------------------------------------------------

//Little section to play around with how Winter's Bite Technique works.
//Summer Siesta is below. Note: we need to redo how critical hits work

int winter_bonus_elemental_damage() {
	int h  = numeric_modifier("Hot Damage");
	int c  = numeric_modifier("Cold Damage");
	int sp = numeric_modifier("Spooky Damage");
	int st = numeric_modifier("Stench Damage");
	int sl = numeric_modifier("Sleaze Damage");
	
	element d = monster_element(OPPONENT);
	if (d == HOT)    {  h = min( h,1); sl = sl*2; st = st*2; }
	if (d == SPOOKY) { sp = min(sp,1); st = st*2;  h =  h*2; }
	if (d == COLD)   {  c = min( c,1);  h =  h*2; sp = sp*2; }
	if (d == SLEAZE) { sl = min(sl,1); sp = sp*2;  c =  c*2; }
	if (d == STENCH) { st = min(st,1);  c =  c*2; sl = sl*2; }
	
	// Beatles are apparently special...
	if (OPPONENT == "swarm of scarab beatles") { h=h*2; sl=sl*2; }
	
	return h + c + sp + st + sl;
}

int [int, int, int] winter_attack_damage_cache;
int winter_attack_damage(int thrustSmackFactor, int leveladj)
{
	// If we already calculated this, use the previous value.
	int mus = uncappedMuscle();
	if (winter_attack_damage_cache[thrustSmackFactor, leveladj] contains mus)
		return winter_attack_damage_cache[thrustSmackFactor, leveladj, mus];
	
	item weapon = equipped_item($slot[weapon]);
	item offhand = equipped_item($slot[off-hand]);
	boolean dualwield = (weapon_hands(offhand) == 1);
	
	// NS13 change: thrust-smack with 2 batblades now seems to underpredict
	// (Player Muscle * rangeadj) - Monster Defense, (minimum 0)
	// + 10% to 20% of Weapon Power * (crit) * (tsfactor) or 1 if barehanded
	// + 10% to 20% of Offhand Weapon Power * (crit) if double-wielding
	// + Bonus Melee Damage
	// + Bonus Ranged Damage (only when wielding a ranged weapon)
	// + Elemental Bonus Damage
	
	int adjustedAttack = mus;
	
	int weaponPower = get_power(weapon);
	int offhandPower = get_power(offhand);
	if (have_effect($effect[Sharp Weapon]) > 0) {
		if (dualwield) offhandPower = offhandPower + 30; // does this affect both?
	}
	if (have_effect($effect[Corroded Weapon]) > 0) {
		if (dualwield) offhandPower = (offhandPower*80)/100; // does this affect both?
	}
	int weaponDamage = max(1,(weaponPower / 10) * thrustSmackFactor);
	if (dualwield) weaponDamage = weaponDamage + (offhandPower / 10);
	
	int WeaponPercentBonus = (max(adjustedAttack - monster_defense(OPPONENT,leveladj),0)
		+ weaponDamage + bonus_melee_damage()) * (numeric_modifier("Weapon Damage Percent")/100);
	// Break it up into the two main components.
	int physicalComponent = max(adjustedAttack - monster_defense(OPPONENT,leveladj),0)
		+ weaponDamage 
		+ bonus_melee_damage()
		+ WeaponPercentBonus
		+ bonus_ranged_damage();
	int elementalComponent = winter_bonus_elemental_damage();
	
	// Handle physical resistance.
	if (resists_physical[OPPONENT])
		physicalComponent = 1;
	
	// This is our final result.
	int result = physicalComponent + elementalComponent;
	
	// Debug output.
	string what = "Attack";
	if (thrustSmackFactor == 2) what = "Thrust-Smack";
	if (thrustSmackFactor == 3) what = "Lunging Thrust-Smack";
	if (DEBUG) {print("Physical: " + max(adjustedAttack - monster_defense(OPPONENT,leveladj),0) + "+" + weaponDamage + "+" 
	+ bonus_melee_damage() + "+" + WeaponPercentBonus + "+" + bonus_ranged_damage() + " = " + physicalComponent);}
	if (DEBUG) print(what + ": " + physicalComponent + "+" + elementalComponent + " = " + result);
	
	// Stash it into our cache and return.
	winter_attack_damage_cache[thrustSmackFactor, leveladj, mus] = result;
	return result;
}

float summer_crit_percentage = percentage(1);

float [string, int, int] summer_hit_percentage_cache;
float summer_hit_percentage(string m, int leveladj)
{
	int bas = buffed_attack_stat();
	if (hit_percentage_cache[m,leveladj] contains bas) return hit_percentage_cache[m,leveladj,bas];
	
	// http://kol.coldfront.net/thekolwiki/index.php/Hit_Chance
	float base = percentage((6.0 + buffed_attack_stat() - monster_defense(m,leveladj)) / 10.5);
	float normalhit = percentage((1-fumble_percentage)*(base-summer_crit_percentage));
	float criticalhit = percentage(min(base,summer_crit_percentage));
	if (DEBUG) print("Hit Percentage: base "+to_int(base*100)+", normal "+to_int(normalhit*100)+", critical "+to_int(criticalhit*100)+", final = "+to_int((normalhit+criticalhit)*100));
	float result = percentage(normalhit+criticalhit);
	summer_hit_percentage_cache[m,leveladj,bas] = result;
	return result;
}

// -----------------------------------------------------------------------
// Moxious Maneuver
// -----------------------------------------------------------------------

int [int, int] maneuver_damage_cache;
int maneuver_damage(string m, int leveladj)
{
	int bhs = uncappedMoxie();
	if (maneuver_damage_cache[leveladj] contains bhs)
		return maneuver_damage_cache[leveladj,bhs];
	
	item weapon = equipped_item($slot[weapon]);
	item offhand = equipped_item($slot[off-hand]);
	boolean barehanded = (weapon == $item[none]);
	boolean dualwield = (weapon_hands(offhand) == 1);
	
	// (Player Muscle * rangeadj) - Monster Defense, (minimum 0)
	// + 10% to 20% of Weapon Power * (crit) * (tsfactor) or 1 if barehanded
	// + 10% to 20% of Offhand Weapon Power * (crit) if double-wielding
	// + Bonus Melee Damage * (tsfactor)
	// + Bonus Ranged Damage (only when wielding a ranged weapon)
	// + Elemental Bonus Damage
	
	int adjustedAttack = bhs;
	if (ranged_weapon_equipped) adjustedAttack = (adjustedAttack * 3) / 4;
	if (barehanded) adjustedAttack = adjustedAttack / 4;
	
	int weaponPower = get_power(weapon);
	int offhandPower = get_power(offhand);
	if (have_effect($effect[Sharp Weapon]) > 0) {
		if (!barehanded) weaponPower = weaponPower + 30;
		if (dualwield) offhandPower = offhandPower + 30; // does this affect both?
	}
	if (have_effect($effect[Corroded Weapon]) > 0) {
		if (!barehanded) weaponPower = (weaponPower*80)/100;
		if (dualwield) offhandPower = (offhandPower*80)/100; // does this affect both?
	}
	int weaponDamage = (weaponPower / 10);
	if (barehanded) weaponDamage = 1;
	if (dualwield) weaponDamage = weaponDamage + (offhandPower / 10);
	
	int WeaponPercentBonus = (max(adjustedAttack - monster_defense(OPPONENT,leveladj),0)
		+ weaponDamage + bonus_melee_damage()) * (numeric_modifier("Weapon Damage Percent")/100);
	// Break it up into the two main components.
	int physicalComponent = max(adjustedAttack - monster_defense(OPPONENT,leveladj),0)
		+ weaponDamage 
		+ bonus_melee_damage()
		+ WeaponPercentBonus
		+ bonus_ranged_damage();
	int elementalComponent = bonus_elemental_damage();
	
	// Handle physical resistance.
	if (resists_physical[OPPONENT])
		physicalComponent = 1;
	
	// This is our final result.
	int result = physicalComponent + elementalComponent;
	
	// Debug output.
	if (DEBUG) print("Moxious Maneuver: " + physicalComponent + "+" + elementalComponent + " = " + result);
	
	// Stash it into our cache and return.
	maneuver_damage_cache[leveladj, bhs] = result;
	return result;
}

// -----------------------------------------------------------------------
// Turtle Tamer butt skills
// -----------------------------------------------------------------------

int headbutt_damage = max(1,hat_power(equipped_item($slot[hat]))/10) + bonus_helmet_damage[equipped_item($slot[hat])];
int kneebutt_damage = max(1,pants_power(equipped_item($slot[pants]))/10);
int shieldbutt_damage = max(1,shield_power[equipped_item($slot[off-hand])]/10);

int [skill] extra_butt_damage;
extra_butt_damage[HEADBUTT]       = headbutt_damage;
extra_butt_damage[KNEEBUTT]       = kneebutt_damage;
extra_butt_damage[SHIELDBUTT]     = shieldbutt_damage;
extra_butt_damage[HEADKNEE]       = headbutt_damage + kneebutt_damage;
extra_butt_damage[HEADSHIELD]     = headbutt_damage + shieldbutt_damage;
extra_butt_damage[KNEESHIELD]     = kneebutt_damage + shieldbutt_damage;
extra_butt_damage[HEADKNEESHIELD] = headbutt_damage + kneebutt_damage + shieldbutt_damage;

int [skill,string,int] butt_damage_cache;
int butt_damage(skill s,string m,int leveladj)
{
	if (butt_damage_cache[s,m] contains leveladj)
		return butt_damage_cache[s,m,leveladj];
	
	int base = attack_damage(1,leveladj);
	int extra = extra_butt_damage[s];
	int total = base + extra;
	if (DEBUG) print("" + s + ": " + base +"+"+ extra +" = "+ total);
	butt_damage_cache[s,m,leveladj] = total;
	return total;
}

// -----------------------------------------------------------------------
//  Dictionary handling
// -----------------------------------------------------------------------

int dictionary_damage = 30;
if (ambidextrous && plink != $item[none])
	dictionary_damage = dictionary_damage + 1;

string dictionary()
{
	item d = $item[dictionary];
	if (item_amount(d) == 0) d = $item[facsimile dictionary];
	if (item_amount(d) == 0) error("You don't have a dictionary!");
	if (ambidextrous && plink != $item[none])
		return throw_items(d, plink);
	return throw_item(d);
}

// -----------------------------------------------------------------------
//  Plinking
// -----------------------------------------------------------------------

string plink()
{
	if (plink == $item[none]) error("You don't have the right items to plink!");
	if (plink2 != $item[none]) return throw_items(plink, plink2);
	return throw_item(plink);
}

// -----------------------------------------------------------------------
//  Antidotes
// -----------------------------------------------------------------------

string antidote()
{
	item aaa = $item[anti-anti-antidote];
	if (item_amount(aaa) == 0)
		error("You don't have any anti-anti-antidotes!");
	if (ambidextrous && plink != $item[none])
		return throw_items(aaa, plink);
	return throw_item(aaa);
}

// -----------------------------------------------------------------------
//  Band flyers
// -----------------------------------------------------------------------

boolean[item] flyers;
if (item_amount($item[rock band flyers]) > 0)
	flyers[$item[rock band flyers]] = true;
if (item_amount($item[jam band flyers]) > 0)
	flyers[$item[jam band flyers]] = true;

boolean can_flyer() {
	// KoLmafia doesn't notice when we lose our flyers. So we'll manually check
	// to see if they're really offered in the item pop-up.
	foreach i in flyers
		if (!contains_text(PAGE,to_string(flyers[i])))
			remove flyers[i];
	return count(flyers) > 0;
}

string flyer()
{
	if (!can_flyer())
		error("No flyers selected!");
	
	// Throw the flyer(s) at the monster. We'll do both the rock and jam
	// band flyers at once if we can.
	string result;
	if (ambidextrous && count(flyers) > 1) {
		result = throw_items($item[rock band flyers], $item[jam band flyers]);
		foreach f in flyers remove flyers[f];
	}
	else if (ambidextrous && plink != $item[none]) {
		foreach f in flyers {
			result = throw_items(f,plink);
			remove flyers[f];
			break;
		}
	}
	else {
		foreach f in flyers {
			result = throw_item(f);
			remove flyers[f];
			break;
		}
	}
	
	// And we're done.
	return result;
}

// -----------------------------------------------------------------------
//  Rampaging adding machine
// -----------------------------------------------------------------------

item[int] addends;
int addition_index = 2;
int scrolls_thrown = 0;
addends[0] = $item[none];
addends[1] = $item[none];

boolean scrolls_to_add()
{
	if (addition_index != 2)
		return true;
	
	if (item_amount($item[64735 scroll]) == 0 &&
		item_amount($item[64067 scroll]) > 0 && item_amount($item[668 scroll]) > 0)
	{
		addends[0] = $item[668 scroll];
		addends[1] = $item[64067 scroll];
	}
	else if (item_amount($item[64067 scroll]) == 0 &&
		item_amount($item[30669 scroll]) > 0 && item_amount($item[33398 scroll]) > 0)
	{
		addends[0] = $item[30669 scroll];
		addends[1] = $item[33398 scroll];
	}
	else if (item_amount($item[334 scroll]) >= 2)
	{
		addends[0] = $item[334 scroll];
		addends[1] = $item[334 scroll];
	}
	else if (item_amount($item[64735 scroll]) > 0 &&
		item_amount($item[30669 scroll]) > 0 && item_amount($item[668 scroll]) > 0)
	{
		addends[0] = $item[30669 scroll];
		addends[1] = $item[668 scroll];
	}
	else
	{
		addends[0] = $item[none];
		addends[1] = $item[none];
		addition_index = 2;
		return false;
	}
	addition_index = 0;
	return true;
}

string add_scrolls()
{
	if (!scrolls_to_add()) error("You don't have any scrolls to add!");
	
	// We can't auto-spade because the damage is hidden.
	HIDDEN_DAMAGE = true;
	
	// Throw two at once, if we can.
	if (ambidextrous) {
		addition_index = 2;
		scrolls_thrown = scrolls_thrown + 2;
		return throw_items(addends[0], addends[1]);
	}
	
	// Throw one per round.
	addition_index = addition_index + 1;
	scrolls_thrown = scrolls_thrown + 1;
	return throw_item(addends[addition_index - 1]);
}

// -----------------------------------------------------------------------
//  Magnet handling
// -----------------------------------------------------------------------

boolean should_use_magnet()
{
	return item_amount($item[molybdenum magnet]) > 0 && 
		  (contains_text(PAGE,"whips out a hammer") ||
	       contains_text(PAGE,"whips out a crescent wrench") ||
	       contains_text(PAGE,"whips out a pair of pliers") ||
	       contains_text(PAGE,"whips out a screwdriver"));
}

string magnet()
{
	item m = $item[molybdenum magnet];
	if (item_amount(m) == 0) error("You don't have a molybdenum magnet!");
	HIDDEN_DAMAGE = true;
	return throw_item(m);
}

// -----------------------------------------------------------------------
// HP and MP cost in meat
// -----------------------------------------------------------------------
// A battle strategy's cost can ultimately be summarized as meat.
// If I lose X HP and Y HP, how much meat will it cost to recover that?
// To do that we need to know what sort of access the player has to HP/MP restorers.

float mmj_meat_per_mp = 100.0 / ((3 * my_level() / 2) + 5);
float kgs_meat_per_mp = 80.0 / 10.0;
float tonic_meat_per_mp = 17;
if (GALAKTIK_DISCOUNT)
	tonic_meat_per_mp = 10;

float meat_per_mp = tonic_meat_per_mp;
if (have_outfit("Knob Goblin Elite Guard Uniform"))
	meat_per_mp = kgs_meat_per_mp;
if ((my_class() == $class[Sauceror]) || (my_class() == $class[Pastamancer]) || (my_class() == $class[Accordion Thief] && my_level() >= 9))
	meat_per_mp = mmj_meat_per_mp;

float mp_per_hp = 1000.0;
foreach x in skill_noncombat_heal
	if (override_have_skill(x))
		mp_per_hp = min(mp_per_hp,to_float(noncombat_mp_cost(x)) / to_float(skill_noncombat_heal[x]));

// We never get exactly the right amount of HP/MP ... there's often some
// amount of over-restoration. Adjust the costs to reflect that.
float restoration_fudge_factor = 1.1;
meat_per_mp = meat_per_mp * restoration_fudge_factor;
mp_per_hp = mp_per_hp * restoration_fudge_factor;

//take value from universal recovery
meat_per_mp = to_float(get_property("_meatpermp"));
print("universal recovery says meatpermp="+meat_per_mp,"green");

// Note that this function can return a negative value if given a negative hp input.
// This may happen if we decide to cast a HP restoration skill in combat.
int [int] hp_to_meat_cache;
int hp_to_meat(int hp)
{
	if (hp_to_meat_cache contains hp) return hp_to_meat_cache[hp];
	if (hp < 0) return -hp_to_meat(-hp);
	// We're going to ignore herbs here because you can only use 15 per day, and we don't
	// know if you have spleen available or if you want to waste spleen on herbs.
	int nostrum_meat = hp * 10;
	if (GALAKTIK_DISCOUNT) nostrum_meat = hp * 6;
	int mp_meat = (hp * mp_per_hp * meat_per_mp);
	int meat = min(mp_meat, nostrum_meat);
	if (override_have_skill($skill[Cannelloni Cocoon]))
		meat = min(meat, noncombat_mp_cost($skill[Cannelloni Cocoon]) * meat_per_mp);
	hp_to_meat_cache[hp] = meat;
	return meat;
}

// ------------------------------------------------------------------
//  Actions
// ------------------------------------------------------------------

// Make a list of available combat actions. If the script takes too long
// to run, you can try disabling some skills that you have but don't
// want to use in combat. (e.g. Weapon of the Pastalord, etc)
boolean [string] action_map;
if (!HAIKU_TEST){
action_map["attack"]                        = true;
action_map[to_string(LUNGE_SMACK)]          = override_have_skill(LUNGE_SMACK) && !ranged_weapon_equipped;
action_map[to_string(THRUST_SMACK)]         = override_have_skill(THRUST_SMACK) && !ranged_weapon_equipped;
action_map[to_string(LTS)]                  = override_have_skill(LTS) && !ranged_weapon_equipped;
action_map[to_string(STREAM)]               = override_have_skill(STREAM);
action_map[to_string(RAVIOLI)]              = override_have_skill(RAVIOLI);
action_map[to_string(CANNON)]               = override_have_skill(CANNON);
action_map[to_string(STORM)]                = override_have_skill(STORM);
action_map[to_string(MORTAR_SHELL)]         = override_have_skill(MORTAR_SHELL);
action_map[to_string(WAVE)]                 = override_have_skill(WAVE);
action_map[to_string(WEAPON)]               = override_have_skill(WEAPON);
action_map[to_string(FETTUCINI)]            = override_have_skill(FETTUCINI);
action_map[to_string(GEYSER)]               = override_have_skill(GEYSER);
action_map[to_string(EYE_POKE)]             = override_have_skill(EYE_POKE);
action_map[to_string(DANCE)]                = override_have_skill(DANCE);
action_map[to_string(DANCE_II)]             = override_have_skill(DANCE_II);
action_map[to_string(FACE_STAB)]            = override_have_skill(FACE_STAB);
action_map[to_string(TANGO)]                = override_have_skill(TANGO);
action_map[to_string(MANEUVER)]             = override_have_skill(MANEUVER);
action_map[to_string(HEADBUTT)]             = override_have_skill(HEADBUTT) && !ranged_weapon_equipped;
action_map[to_string(KNEEBUTT)]             = override_have_skill(KNEEBUTT) && !ranged_weapon_equipped;
action_map[to_string(SHIELDBUTT)]           = override_have_skill(SHIELDBUTT) && shield_equipped && !ranged_weapon_equipped;
action_map[to_string(HEADKNEE)]             = override_have_skill(HEADBUTT) && override_have_skill(KNEEBUTT) && !ranged_weapon_equipped && turtle_tamer;
action_map[to_string(HEADSHIELD)]           = override_have_skill(HEADBUTT) && override_have_skill(SHIELDBUTT) && shield_equipped && !ranged_weapon_equipped && turtle_tamer;
action_map[to_string(KNEESHIELD)]           = override_have_skill(KNEEBUTT) && override_have_skill(SHIELDBUTT) && shield_equipped && !ranged_weapon_equipped && turtle_tamer;
action_map[to_string(HEADKNEESHIELD)]       = override_have_skill(HEADBUTT) && override_have_skill(KNEEBUTT) && override_have_skill(SHIELDBUTT) && shield_equipped && !ranged_weapon_equipped && turtle_tamer;
//Hobopolis
action_map[to_string(CAMPFIRE)]               = override_have_skill(CAMPFIRE);
action_map[to_string(CHILL)]                  = override_have_skill(CHILL);
action_map[to_string(MUDBATH)]                = override_have_skill(MUDBATH);
action_map[to_string(LULLABY)]                = override_have_skill(LULLABY);
action_map[to_string(BACKRUB)]                = override_have_skill(BACKRUB);
}
//Haiku Katana
action_map[to_string(SEVENTEEN_CUTS)]        = override_have_skill(SEVENTEEN_CUTS) && !(have_effect($effect[Haiku State of Mind]) > 0); 
action_map[to_string(SPRING)]                = override_have_skill(SPRING);
action_map[to_string(SUMMER)]                = override_have_skill(SUMMER);
action_map[to_string(FALL)]                  = override_have_skill(FALL);
action_map[to_string(WINTER)]                = override_have_skill(WINTER);
if (plink != $item[none])
	action_map["plink"] = true;

// Healing skills are an interesting avenue to explore, but in practice they just
// grow the search tree exponentially and never get picked.
//action_map[to_string(BANDAGES)]             = override_have_skill(BANDAGES);
//action_map[to_string(SALVE)]                = override_have_skill(SALVE);

// Trim out unavailable actions.
foreach action in action_map
	if (!action_map[action])
		remove action_map[action];

// There are some special actions that we can (or should) only do
// at the start of the fight.
boolean [string] initial_action;
initial_action[""]                     = true;
initial_action["Entangling Noodles, "] = true;
initial_action["steal, "]              = true;

if (!override_have_skill(NOODLES)) remove initial_action["Entangling Noodles, "];
if (my_class() != $class[Accordion Thief] && my_class() != $class[Disco Bandit]) remove initial_action["steal, "];

// Sort the action map by MP cost.
string[int] sorted_action_map;

void sort_action_map()
{
	boolean amnesiac = have_effect($effect[Temporary Amnesia]) > 0;
	foreach x in sorted_action_map remove sorted_action_map[x];
	foreach action in action_map
	{
		skill sk = to_skill(action);
		if (amnesiac && (sk != $skill[none])) continue;
		int cost = combat_mp_cost(sk);
		if (action == "dictionary") cost = -1; // prefer dictionary over attacking against Orc Chasm monsters
		if (action == "plink") cost = 100; // plink should be considered last, preferably
		if (count(sorted_action_map) >= 0)
			for i from 0 upto count(sorted_action_map)
			{
				if (sorted_action_map[i] == "") {
					sorted_action_map[i] = action;
					break;
				}
				else if (combat_mp_cost(to_skill(sorted_action_map[i])) > cost) {
					for j from count(sorted_action_map) downto i+1
						sorted_action_map[j] = sorted_action_map[j-1];
					sorted_action_map[i] = action;
					break;
				}
			}
	}
}

sort_action_map();
//if (DEBUG)
//	for i from 0 upto count(sorted_action_map)-1
//		print("sorted_action_map[" + i + "] = " + sorted_action_map[i]);


// -----------------------------------------------------------------------
//  Strategy simulation
// -----------------------------------------------------------------------

// Strategy map. Key is a strategy string, value is cost of that strategy in meat.
int [string] strategy_map;

// Best strategy found so far, and its cost in meat.
string best_strategy = "";
int lowest_cost = 1000000;

// Markers used to indicate that a strategy has failed.
int STRATEGY_CONTINUE = -100000;  // strategy failed to win, but might work if you keep searching
int STRATEGY_PRUNE = -100001;     // strategy can't win or is discouraged, prune here

// Returns a pessimistic damage estimate for an action.
int [string, int, int, int, int] predicted_action_damage_cache;
int predicted_action_damage(string action, int leveladj)
{
	int mus = my_buffedstat($stat[Muscle]);
	int mys = my_buffedstat($stat[Mysticality]);
	int mox = my_buffedstat($stat[Moxie]);
	if (predicted_action_damage_cache[action,leveladj,mus,mys] contains mox)
		return predicted_action_damage_cache[action, leveladj,mus,mys,mox];
	int damage = 0;
	int disco_bandit_bonus = 0;
	//if (have_equipped($item[Shagadelic Disco Banjo])) disco_bandit_bonus = 7;
	skill s = to_skill(action);
	if (action == "attack")            damage = attack_damage(1,leveladj) * hit_percentage(OPPONENT,leveladj);
	else if (action == "add")          damage = 0; // not really!
	else if (action == "dictionary")   damage = dictionary_damage;
	else if (action == "steal")        damage = 0;
	else if (action == "flyer")        damage = 0;
	else if (action == "plink")        damage = plink_damage[plink] + plink_damage[plink2];
	else if (action == "antidote")     damage = 0;
	else if (action == "jiggle")       damage = jiggle_damage();
	else if (s == LUNGE_SMACK)         damage = attack_damage(3,leveladj) * hit_percentage(OPPONENT,leveladj);
	else if (s == THRUST_SMACK)        damage = attack_damage(2,leveladj) * smack_hit_percentage(OPPONENT,leveladj,s);
	else if (s == LTS)                 damage = attack_damage(3,leveladj) * smack_hit_percentage(OPPONENT,leveladj,s);
	else if (s == HEADBUTT)            damage = butt_damage(s,1,leveladj) * hit_percentage(OPPONENT,leveladj);
	else if (s == KNEEBUTT)            damage = butt_damage(s,1,leveladj) * knee_hit_percentage(OPPONENT,leveladj);
	else if (s == HEADKNEE)            damage = butt_damage(s,1,leveladj) * knee_hit_percentage(OPPONENT,leveladj);
	else if (s == SHIELDBUTT)          damage = butt_damage(s,1,leveladj);
	else if (s == HEADSHIELD)          damage = butt_damage(s,1,leveladj);
	else if (s == KNEESHIELD)          damage = butt_damage(s,1,leveladj);
	else if (s == HEADKNEESHIELD)      damage = butt_damage(s,1,leveladj);
	else if (s == EYE_POKE)            damage = 1 + disco_bandit_bonus;
	else if (s == DANCE)               damage = 6 + disco_bandit_bonus;
	else if (s == DANCE_II)            damage = 8 + disco_bandit_bonus;
	else if (s == FACE_STAB)           damage = 15 + disco_bandit_bonus;
	else if (s == TANGO)               damage = (get_elemental_multiplier(monster_element(OPPONENT), SPOOKY) * 15) + disco_bandit_bonus;	// Tango does spooky damage
	else if (s == SEVENTEEN_CUTS)      damage = 17;
	else if (s == SUMMER)              damage = attack_damage(1,leveladj) * summer_hit_percentage(OPPONENT,leveladj);
	else if (s == WINTER)              damage = 10 + winter_attack_damage(1,leveladj);
	else if (s == MANEUVER)            damage = maneuver_damage(OPPONENT,leveladj) * maneuver_hit_percentage(OPPONENT,leveladj);
	else if (s == BANDAGES || s == SALVE) damage = 0;
	else                               damage = spell_damage(s);
	predicted_action_damage_cache[action,leveladj,mus,mys,mox] = damage;
	if (damage < 0) warn("negative damage for " + action);
	return damage;
}

int predicted_action_backlash(string action, int leveladj)
{
	// Right now we only handle spell backlash.
	return spell_backlash[to_skill(action),my_buffedstat($stat[Mysticality])];
}

int action_leveladj(string action) {
	return skill_leveladj[to_skill(action)];
}

int action_cost(string action) {
	return combat_mp_cost(to_skill(action));
}

// This is so that we don't waste a lot of time exploring blind alleys with
// attacks that don't hit. We will consider attacking if we hit more than 33% of the time,
// and we'll consider MP-expending skills if they'll hit more than 50% of the time.
// These figures are totally arbitrary but they work for me.
boolean action_is_discouraged(string action, int leveladj, int playerhp) {
	skill s = to_skill(action);
	return (action == "attack" && hit_percentage(OPPONENT, leveladj) < 0.34) ||
	       (action == "flyer" && count(flyers) == 0) ||
	       ((s == LUNGE_SMACK) && hit_percentage(OPPONENT, leveladj) < 0.5) ||
	       ((s == THRUST_SMACK || s == LTS) && smack_hit_percentage(OPPONENT,leveladj,s) < 0.5) ||
		   ((s == MANEUVER) && maneuver_hit_percentage(OPPONENT,leveladj) < 0.5) ||
		   ((s == HEADBUTT) && hit_percentage(OPPONENT, leveladj) < 0.5) ||
		   ((s == KNEEBUTT || s == HEADKNEE) && knee_hit_percentage(OPPONENT,leveladj) < 0.5) ||
		   (action == "add" && !scrolls_to_add()) || // don't try to feed scrolls if we don't have any
		   ((s == BANDAGES || s == SALVE) && (playerhp == my_maxhp())); // don't heal if we're already full
}

int meat_cost_from_simulation(int simulated_player_hp, int simulated_player_mp)
{
	int mp_used = INITIAL_MP - simulated_player_mp;
	int hp_used = INITIAL_HP - simulated_player_hp;
	return (mp_used * meat_per_mp) + hp_to_meat(hp_used);
}

int simulate_strategy(int mhp, int leveladj, string strategy, boolean truncate_short_actions)
{
	boolean SIMDEBUG = DEBUG_SIMULATOR;
	//if (contains_text(strategy, "Entangling Noodles, Saucegeyser")) SIMDEBUG = true;
	//if (contains_text(strategy, "Saucy Salve") || contains_text(strategy, "Lasagna Bandages")) SIMDEBUG = true;
	//if (contains_text(strategy, "butt")) SIMDEBUG = true;
	//if (contains_text(strategy, "flyer")) SIMDEBUG = true;
	
	// Set up our simulation variables
	int simulated_monster_hp = mhp;
	int simulated_player_hp = my_hp();
	int simulated_player_mp = my_mp();
	int simulated_leveladj = leveladj;
	
	// Plink has to be the last action in our list.
	if (contains_text(strategy, "plink, ") && !ends_with(strategy, "plink"))
		return STRATEGY_PRUNE;
	
	// Flyer can't be the last action in our list, and we can't have more flyer actions
	// than we have actual flyers.
	if (ends_with(strategy,"flyer"))
		return STRATEGY_CONTINUE;
	if (contains_text(strategy,"flyer"))
	{
		int num_flyer_actions = count(split_string(strategy,"flyer")) - 1;
		if (ambidextrous && num_flyer_actions > 1) return STRATEGY_PRUNE;
		if (!ambidextrous && num_flyer_actions > count(flyers)) return STRATEGY_PRUNE;
	}

	// Can't jiggle more than once
	if (index_of(strategy, "jiggle") != last_index_of(strategy, "jiggle"))
		return STRATEGY_PRUNE;
	
	// Loop through the actions in the list. Repeat the last one if the monster's not dead yet.
	string chain = "";
	string[int] actions = comma_split(strategy);
	int lastAction = count(actions) - 1;
	boolean[int] predict_stunned;
	boolean[int] predict_noodled;
	boolean[int] predict_bleeding;
	foreach x in STUNNED  predict_stunned[x]  = STUNNED[x];
	foreach x in NOODLED  predict_noodled[x]  = NOODLED[x];
	foreach x in BLEEDING predict_bleeding[x] = BLEEDING[x];
	int i = -1;
	int max = 32;
	int bonus_loot = 0;
	boolean truncate = truncate_short_actions && (count(actions)<3);
	if (actions[0] == "Entangling Noodles" || actions[0] == "steal") truncate = (count(actions)<4);
	if (actions[count(actions)-1] == "plink") truncate = false;
	for r from ROUND upto 30
	{
		// We'll repeat the last action on long actions only.
		if ((i == lastAction) && truncate) {
			if (SIMDEBUG) print(" ... didn't beat the monster in "+(i+1)+" turns");
			return STRATEGY_CONTINUE;
		}
		
		i = min(i+1,lastAction);
		string action = actions[i];
		skill sk = to_skill(action);
		if (SIMDEBUG) print("Simulation round " + r + ": HP " +simulated_player_hp+ ", MP " +simulated_player_mp+
			", ML " +simulated_leveladj+ ", MHP " +simulated_monster_hp + ": '" + action + "'");
		
		// Skip discouraged actions
		if (action_is_discouraged(action, simulated_leveladj, simulated_player_hp)) {
			if (SIMDEBUG) print(" ... this course of action has been discouraged");
			return STRATEGY_PRUNE;
		}
		
		// Stealing is a tricky subject. How much is it worth, in meat? We can't really say
		// without including a ton of huge tables (steal success, monster drops, frequency,
		// autosell value, etc). Let's just say 50 meat for now. This will often be wrong
		// but at least it gives some weight to the stealing.
		if (action == "steal")
			bonus_loot = bonus_loot + monster_bonus_loot[OPPONENT] + 50;
		
		// Flyering works toward quest completion, so give it a bonus.
		if (action == "flyer")
			bonus_loot = bonus_loot + 500;
		
		// If we're fighting the adding machine, we really want to use scrolls
		// whenever possible.
		if (action == "add")
			bonus_loot = bonus_loot + 500;
		
		// Handle skill chaining effects ... we ignore the buff effects since they
		// either don't affect combat (Concentration, Nirvana) or are too darn
		// hard to simulate to bother for a 1-round effect (Inferno).
		if (chain != "") chain = chain + ", ";
		chain = chain + action;
		foreach x in skill_chain
			if (ends_with(chain, x))
			{
				if (skill_chain[x] == "Disco Blindness 1")
					{ predict_stunned[r] = true; }
				else if (skill_chain[x] == "Disco Blindness 2")
					{ predict_stunned[r] = true; predict_stunned[r+1] = true; }
				else if (skill_chain[x] == "Disco Bleeding 1")
					{ predict_bleeding[r] = true; }
				else if (skill_chain[x] == "Disco Bleeding 2")
					{ predict_bleeding[r] = true; predict_bleeding[r+1] = true; }
				else if (skill_chain[x] == "Disco Bleeding 3")
					{ predict_bleeding[r] = true; predict_bleeding[r+1] = true; predict_bleeding[r+2] = true; }
			}
		
		// Noodles stun for at least this round and next round
		if (sk == NOODLES) {
			predict_noodled[r]   = true;
			predict_noodled[r+1] = true;
		}
		
		// Subtract the MP cost of this action
		simulated_player_mp = simulated_player_mp - combat_mp_cost(sk);
		if (simulated_player_mp < 0) { // not enough mp?
			if (SIMDEBUG) print(" ... ran out of MP");
			return STRATEGY_PRUNE;
		}
		
		// Handle any HP restoration effects
		simulated_player_hp = min(my_maxhp(), simulated_player_hp + skill_combat_heal[sk]);
		
		// Damage and delevel the monster
		simulated_monster_hp = simulated_monster_hp - predicted_action_damage(action, simulated_leveladj);
		simulated_leveladj = simulated_leveladj + action_leveladj(action);
		simulated_player_hp = simulated_player_hp - predicted_action_backlash(action, simulated_leveladj);
		if (simulated_player_hp <= 0) { // did we lose?
			if (SIMDEBUG) print("backlash = " + predicted_action_backlash(action, simulated_leveladj));
			if (SIMDEBUG) print(" ... ran out of HP");
			return STRATEGY_PRUNE;
		}
		if (simulated_monster_hp <= 0) // did we win?
			break;
		
		// Monster attacks now
		if (!predict_stunned[r] && !predict_noodled[r]) {
			simulated_player_hp = simulated_player_hp - monster_damage(OPPONENT, simulated_leveladj);
			//simulated_monster_hp = simulated_monster_hp - action_retaliation_damage(action);
		}
		if (simulated_player_hp <= 0) { // did we lose?
			if (SIMDEBUG) print("monster damage = " + monster_damage(OPPONENT, simulated_leveladj));
			if (SIMDEBUG) print(" ... ran out of HP");
			return STRATEGY_PRUNE;
		}
		
		// I think bleeding takes place after the monster's attack. Need to figure
		// this out for sure, though.
		if (predict_bleeding[r]) {
			simulated_monster_hp = simulated_monster_hp - 15;
			if (simulated_monster_hp <= 0) // did we win?
				break;
		}
		
		// If we've gone beyond the best winning strategy so far, don't
		// bother exploring this branch further.
		if (!AUTOSPADE_MONSTERS) {
			if (meat_cost_from_simulation(simulated_player_hp, simulated_player_mp) - bonus_loot > lowest_cost) {
				if (SIMDEBUG) print(" ... getting too expensive");
				return STRATEGY_PRUNE;
			}
		} else {
			if (meat_cost_from_simulation(simulated_player_hp, simulated_player_mp) - bonus_loot > lowest_cost + 3000) {
				if (SIMDEBUG) print(" ... getting too expensive");
				return STRATEGY_PRUNE;
			}
		}
	}
	
	// If we didn't beat the monster, clearly this strategy won't work
	if (simulated_monster_hp > 0) {
		if (SIMDEBUG) print(" ... ran out of turns");
		return STRATEGY_CONTINUE;
	}
	
	// If we're autospading aggressively, give a boost to any strategy
	// which results in a total damage close to our minimum prediction.
	if (AUTOSPADE_MONSTERS && AUTOSPADE_AGGRESSIVELY && spading_hp_max contains OPPONENT) {
		int di = mhp - ml - simulated_monster_hp;
		if (di >= spading_hp_max[OPPONENT]-1)
			bonus_loot = bonus_loot - 1000;		// Penalize overkills
		else
			bonus_loot = bonus_loot + 1000 + (spading_hp_min[OPPONENT] - di) * 10;
			
		// Particularly boost plinking since it narrows down the monster's HP very well.
		if (ends_with(strategy,"plink")) {
			bonus_loot = bonus_loot + 1000;
			// But don't boost strategies that include attack/TS/LTS so much, since they
			// have widely varying damage.
			if (contains_text(strategy,"attack") || contains_text(strategy,to_string(THRUST_SMACK)) || contains_text(strategy,to_string(LTS)))
				bonus_loot = bonus_loot - 750;
		}
	}
	
	// Now we need to figure out the total meat cost.
	int meat_cost = meat_cost_from_simulation(simulated_player_hp, simulated_player_mp) - bonus_loot;
	int mp_used = INITIAL_MP - simulated_player_mp;
	int hp_used = INITIAL_HP - simulated_player_hp;
	if (meat_cost > lowest_cost) {
		if (SIMDEBUG) print(" ... won, but too expensive");
		return STRATEGY_PRUNE;
	}
	if (SIMDEBUG) print("Candidate: " + strategy + " (" + mp_used + "MP, " + hp_used + "HP = " + (meat_cost+bonus_loot) + " meat + "+bonus_loot+" bonus)");
	return meat_cost;
}

int simulate_strategy(int mhp, int leveladj, string strategy) {
	return simulate_strategy(mhp, leveladj, strategy, true);
}

string finalize_strategy(string strategy)
{
	// Remove duplicate actions at the end ... "attack, attack" has some
	// semantic meaning during our search, but after that it's pointless.
	string[int] actions = comma_split(strategy);
	int trim = 0;
	int lastAction = count(actions) - 1;
	if (lastAction >= 1)
		for i from lastAction downto 1
			if (actions[i] == actions[i-1])
				trim = trim + 1;
			else
				break;

	// Becuase of crits, it is better to do more expensive skills first sometimes
	// e.g. if string = attack, LTS then we can't out-moxie opponent, so better to LTS first
	// that way, if we get crit and one-hit kill, no need to lose HP on normal attack.
	for i from count(actions)-1-trim downto 1 {
		if (actions[i] == "Lunging Thrust-Smack" && actions[i-1] == "attack") {
			actions[i-1] = "Lunging Thrust-Smack";
			actions[i] = "attack";
		}
		if (actions[i] == "Thrust-Smack" && actions[i-1] == "attack") {
			actions[i-1] = "Thrust-Smack";
			actions[i] = "attack";
		}
		if (actions[i] == "Lunging Thrust-Smack" && actions[i-1] == "Thrust-Smack") {
			actions[i-1] = "Lunging Thrust-Smack";
			actions[i] = "Thrust-Smack";
		}
		if (actions[i] == "Cannelloni Cannon" && actions[i-1] == "Ravioli Shurikens") {
			actions[i-1] = "Cannelloni Cannon";
			actions[i] = "Ravioli Shurikens";
		}
		// TODO - better way to do this? And is this ordering always better?
	}
	
	// Generate a fresh new string
	string result = actions[0];
	if (count(actions)-trim > 1)
		for i from 1 upto count(actions)-1-trim
			result = result + ", " + actions[i];
	return result;
}

void add_to_strategy_map(string strategy, int meat_cost)
{
	strategy_map[strategy] = meat_cost;
	boolean best = (meat_cost < lowest_cost);
	
	if (meat_cost == lowest_cost)
	{
		if (count(comma_split(strategy)) < count(comma_split(best_strategy)))
			best = true; // prefer shorter strategies
		else if (ends_with(strategy,"plink"))
			best = true; // prefer autospading strategies
	}
	
	if (best) {
		best_strategy = strategy;
		lowest_cost = meat_cost;
	}
}

void clear_strategy_map()
{
	foreach x in strategy_map remove strategy_map[x];
	lowest_cost = 1000000;
	best_strategy = "";
}

int consider_strategy(int mhp, int leveladj, string strategy)
{
	// Simulate the strategy
	boolean strat_ok = false;
	int meat_cost = -1;
    meat_cost = simulate_strategy(max(1,mhp), leveladj, strategy);
	if (meat_cost > STRATEGY_CONTINUE)
		add_to_strategy_map(finalize_strategy(strategy), meat_cost);
	return meat_cost;
}

int consider_strategy(string strategy) {
	int monster_base_hp = monster_hp(OPPONENT,0);
	return consider_strategy(monster_base_hp - total_damage_inflicted, 0, strategy);
}


// -----------------------------------------------------------------------
// Damage parsing
// -----------------------------------------------------------------------

string damage_regex = "";
string damage_separator = "";

void build_damage_regex()
{
	// Regex building code. Some effort has been made to keep this human-readable.
	string whitespace = "[ \\t]+";
	string tag = "<[^<>]+>";
	string named_entity = "&[A-Za-z]+;";
	string numeric_entity = "&#[0-9]+;";
	string entity = "(" + named_entity + "|" + numeric_entity + ")";
	string junk = "[()+]"; // for the purposes of damage calculation
	string separator = "(" + whitespace + "|" + tag + "|" + entity + "|" + junk + ")";
	string optional_separator = separator + "*";
	string component = optional_separator + "[0-9]+" + optional_separator;
	string components = "(" + component + ")+";
	string damageword = "(damage|to your opponent|points|notches)";
	string extrawords = "[^0-9.]*";
	
	// Here's our damage regex. The numeric components will be gathered in match[x,1]
	// and can be separated with damage_separator.
	damage_regex = "(" + components + ")" + extrawords + damageword;
	damage_separator = separator + "+";
	
	// Curious? Uncomment this to see what the result is.
// 	print("damage_regex = \"" + damage_regex + "\"");
// 	print("damage_separator = \"" + damage_separator + "\"");
}
build_damage_regex();

boolean blocked()
{
	return contains_text(PAGE,"FUMBLE!") ||
		   contains_text(PAGE,"failed to hit the monster") ||
		   contains_text(PAGE,"lose track of what you're doing") ||
	       contains_text(PAGE,"knocks it out of your hand") ||
	       contains_text(PAGE,"forget what you were doing") ||
	       contains_text(PAGE,"forget what you were about to do") ||
	       contains_text(PAGE,"forget to complete your action") ||
	       contains_text(PAGE,"grabs the item from you") ||
	       contains_text(PAGE,"you fumble and drop it") ||
	       contains_text(PAGE,"before you can use it") ||
	       contains_text(PAGE,"dirty tricks don't work so well") ||
	       contains_text(PAGE,"but she proves one sneakier") ||
	       contains_text(PAGE,"like a fish, doesn't have any feelings") ||
	       contains_text(PAGE,"decide to use that skill later") ||
	       contains_text(PAGE,"decide to attack him later") ||
	       contains_text(PAGE,"decide to use that item later");
}

// -----------------------------------------------------------------------
//  Strategy execution
// -----------------------------------------------------------------------

int actual_action_damage(string action)
{
	if (action == "steal") return 0;
	if (skill_combat_heal[to_skill(action)] > 0) return 0;
	if (contains_text(PAGE,"You failed to hit the monster.")) return 0;
	if (contains_text(PAGE,"FUMBLE!")) return 0;
	
	// Special-case that damn ice sickle which prints the damage twice.
	if (contains_text(PAGE, "reaping")) {
		string[int,int] sown = group_string(PAGE,"reaping [^.]+ damage.([^.]+ sown [^.]+ damage.)");
		if (count(sown) > 0)
		 for x from count(sown)-1 downto 0
		  PAGE = replace_string(PAGE,sown[x,1],"");
	}
	
	// Convert "hit points" to "HP" and "mana/mojo/muscularity points" to "MP". This helps
	// avoid incorrectly triggering on the "You lose X hit points" message.
	PAGE = replace_string(PAGE,"hit points","HP");
	PAGE = replace_string(PAGE,"mana points","MP");
	PAGE = replace_string(PAGE,"Mana Points","MP");
	PAGE = replace_string(PAGE,"mojo points","MP");
	PAGE = replace_string(PAGE,"Mojo Points","MP");
	PAGE = replace_string(PAGE,"Muscularity Points","MP");
	PAGE = replace_string(PAGE,"muscularity points","MP");
	
	// Extract the damage from the page.
	int damage = 0;

	// Running group_string() on the whole PAGE is *really* slow, as PAGE is big, and regex is complicated.
	// So try to search only a subset of the page if possible.
	string[int, int] match;
	int start = index_of(PAGE, "You're fighting");
	int end = index_of(PAGE, "<form name=attack", start);
	if (start != -1 && end > start)
		match = group_string(substring(PAGE, start, end), damage_regex);
	else
		match = group_string(PAGE,damage_regex);
	foreach hit in match
	{
		string[int] components = split_string(match[hit,1], damage_separator);
		foreach j in components
			damage = damage + to_int(components[j]);
	}
	
	return damage;
}

int damage_inflicted(string action)
{
	int damage = 0;
	if (!blocked()) damage = damage + actual_action_damage(action);
	return damage;
}

string update_strategy(string old_strategy, string m, int leveladj, int mhp)
{
	// The cost of the old strategy might have changed, so recalculate it.
	lowest_cost = 1000000;
	int old_cost = simulate_strategy(mhp, leveladj, old_strategy, false);
	clear_strategy_map();
	if (old_cost != STRATEGY_CONTINUE && old_cost != STRATEGY_PRUNE) {
		best_strategy = old_strategy;
		lowest_cost = old_cost;
	}
	
	for i1 from 0 upto count(sorted_action_map)-1
		if (consider_strategy(mhp,leveladj,sorted_action_map[i1]) == STRATEGY_CONTINUE)
			for i2 from 0 upto count(sorted_action_map)-1
				if (consider_strategy(mhp,leveladj,sorted_action_map[i1] + ", " + sorted_action_map[i2]) == STRATEGY_CONTINUE)
					for i3 from 0 upto count(sorted_action_map)-1
						consider_strategy(mhp,leveladj,sorted_action_map[i1] + ", " + sorted_action_map[i2] + ", " + sorted_action_map[i3]);
	
	if (best_strategy == "") {
		if (ROUND >= 30) {
			attack(); // doesn't matter what we do, since KoL will ignore it
			error("Ran out of turns!");
		}
		error("Couldn't select a new strategy!");
	}
	
	if ((mhp > 0) && (old_strategy != best_strategy))
		print("FightOptimizer adjusted strategy: " + best_strategy + " (" + lowest_cost + " meat)", "green");
	return best_strategy;
}

string remove_first_action(string strategy)
{
	string[int] actions = comma_split(strategy);
	if (count(actions) <= 1)
		return strategy;
	return comma_join(actions,1);
}

void execute_strategy(string strategy)
{
	string[int] actions = comma_split(strategy);
	int lastAction = count(actions) - 1;
	string chain = "";
	int i = -1;
	int leveladj = 0;
	int mhp = monster_hp(OPPONENT,0);
	boolean first_round = true;
	string uneffect = "";
	
	for r from ROUND upto 31
	{
		// Always use antidotes in combat if we've been poisoned
		// and if they are available.
		if ((have_effect($effect[Hardly Poisoned At All]) > 0) ||
		    (have_effect($effect[A Little Bit Poisoned]) > 0) ||
		    (have_effect($effect[Somewhat Poisoned]) > 0) ||
		    (have_effect($effect[Really Quite Poisoned]) > 0) ||
			(have_effect($effect[Majorly Poisoned]) > 0))
		{
			if (item_amount($item[anti-anti-antidote]) > 0)
				uneffect = "antidote";
		}
		
		if (contains_text(PAGE, "win the fight") || contains_text(PAGE, "WINWINWIN")) {
			if (AUTOSPADE_MONSTERS) {
				if (spading_hp_max contains OPPONENT)
					spading_hp_max[OPPONENT] = min(spading_hp_max[OPPONENT], total_damage_inflicted - ml);
				else
					spading_hp_max[OPPONENT] = total_damage_inflicted - ml;
			}
			return;
		}
		if (AUTOSPADE_MONSTERS) {
			if (spading_hp_min contains OPPONENT)
				spading_hp_min[OPPONENT] = max(spading_hp_min[OPPONENT], total_damage_inflicted - ml + 1);
			else
				spading_hp_min[OPPONENT] = total_damage_inflicted - ml + 1;
		}
		write_spade_maps();
		if (contains_text(PAGE, "slink away"))
			error("You lost the fight.");
		
		// The monster obviously has at least 1 HP left.
		mhp = max(1,mhp);
		
		// If the user wants us to, search for a new strategy based on
		// our current HP/MP and the monster's estimated new HP.
		if (!first_round && ADJUST_STRATEGY_DURING_FIGHT && uneffect == "") {
			strategy = update_strategy(strategy,OPPONENT,leveladj,mhp);
			actions = comma_split(strategy);
			lastAction = count(actions) - 1;
			i = -1;
		}
		first_round = false;
		
		string action;
		skill sk;
		// Extract the next action from the list.
		if (uneffect != "") {
			action = uneffect;
			uneffect = "";
		} else {
			i = min(i+1,lastAction);
			action = actions[i];
		}
		sk = to_skill(action);
		if (action == "attack")
			PAGE = attack();
		else if (action == "dictionary")
			PAGE = dictionary();
		else if (action == "add")
			PAGE = add_scrolls();
		else if (action == "steal")
			PAGE = steal();
		else if (action == "jiggle") {
			PAGE = visit_url("fight.php?action=chefstaff");
			// only once per fight (uses PRUNE to remove dups in simulate_strategy)
			remove action_map["jiggle"];
			sort_action_map();
		}
		else if (action == "flyer") {
			PAGE = flyer();
			
			// Now that we've thrown, re-check to see if it makes sense to throw any more flyers.
			if (!can_flyer()) {
				remove action_map["flyer"];
				sort_action_map();
			}
		}
		else if (action == "plink")
			PAGE = plink();
		else if (action == "antidote")
			PAGE = antidote();
		else {
			if (my_mp() < mp_cost_fixed(sk)) error("You don't have enough MP for " + action + "!");
			PAGE = use_skill(sk);
		}
		ROUND = ROUND + 1;
		
		// Determine the total monster damage -- taking into account familiar actions, acid-squirting
		// flowers, saucespheres, pointiness, etc.
		int di = damage_inflicted(action);
		total_damage_inflicted = total_damage_inflicted + di;
		mhp = mhp - di;
		if (DEBUG) print("Monster took " + di + " total damage.");
		
		// If we're fighting a gremlin and we've got the molybdenum magnet, and
		// the monster just used a target item on us ... then we can win the fight and
		// help complete the quest by using the magnet.
		if (contains_text(OPPONENT,"gremlin") && should_use_magnet()) {
			PAGE = magnet();
			return;
		}
		
		// Retry if our action was blocked.
		boolean b = blocked();
		if (b)
		{
			print("Blocked!","red");
			chain = "";
			i = i - 1;
			
			// Sometimes when we're guessing at a monster's level we think an attack will work when
			// in fact it has no hope. To counteract this effect, every time we miss we crank up
			// the level used for hit/miss calculation.
			if (monster_level_unknown) {
				print("Adjusting monster level estimate by +10...");
				leveladj = leveladj + 10;
			}
		}
		else
		{
			// We're done with this action so remove it from our strategy. Note
			// that it'll still be in the actions[int] map.
			strategy = remove_first_action(strategy);
			
			// Adjust level.
			leveladj = leveladj + action_leveladj(action);
			
			// If we just cast noodles, the monster will almost certainly be stunned for
			// at least this round and the next round.
			if (action == to_string(NOODLES)) {
				NOODLED[r] = true; NOODLED[r+1] = true;
			}
			
			// Handle skill chaining.
			if (chain != "") chain = chain + ", ";
			chain = chain + action;
			foreach x in skill_chain
				if (ends_with(chain, x))
				{
					if (skill_chain[x] == "Disco Blindness 1")
						{ STUNNED[r] = true; }
					else if (skill_chain[x] == "Disco Blindness 2")
						{ STUNNED[r] = true; STUNNED[r+1] = true; }
					else if (skill_chain[x] == "Disco Bleeding 1")
						{ BLEEDING[r] = true; }
					else if (skill_chain[x] == "Disco Bleeding 2")
						{ BLEEDING[r] = true; BLEEDING[r+1] = true; }
					else if (skill_chain[x] == "Disco Bleeding 3")
						{ BLEEDING[r] = true; BLEEDING[r+1] = true; BLEEDING[r+2] = true; }
				}
			
			// Print the actual damage that we inflicted with our action.
			int ad = actual_action_damage(action);
			int pd = predicted_action_damage(action,leveladj);
			if (ad > 0 || pd > 0) {
				string color = "black";
				if (!LESS_PESSIMISTIC && ad < pd) color = "red"; // Warn if damage wasn't right
				print("You did " +ad+ " damage with your " + action + ". (p=" + pd + ",t=" + total_damage_inflicted + ")", color);
				boolean unexpected = (monster_element(OPPONENT) == NONE) || !is_random_element(sk);
				if (!LESS_PESSIMISTIC && (ad < pd) && unexpected) {
					if (WARNINGS_ARE_ERRORS) {
						PAGE = replace_string(replace_string(PAGE,"<","&lt;"),">","&gt;");
						print("PAGE = " + PAGE);
					}
					if (!monster_level_unknown)
						warn("Damage prediction seems wrong -- our simulator or parser may be incorrect");
				}
			}
		}
	}
	
	// Too many turns!
	error("Too many turns!");
}


// ------------------------------------------------------------------
//  main
// ------------------------------------------------------------------

void main(string roundString, string encounterString, string pageString)
{

	print("fightoptimizer called","blue");
	// Parse out the values.
	ROUND = to_int(roundString);
	OPPONENT = to_lower_case(encounterString);
	PAGE = pageString;
	if (monster_remap contains OPPONENT)
		OPPONENT = monster_remap[OPPONENT];
	
	// Reset the spading damage for this monster. This parses the page to determine
	// the damage inflicted by auto-attack actions and such.
	total_damage_inflicted = damage_inflicted("");
	
	// If KoLmafia has data for this monster, we don't need to spade it.
	int mafia_hp = monster_hp(to_monster(OPPONENT));
	if (mafia_hp != 0 && mafia_hp != monster_level_adjustment())
		AUTOSPADE_MONSTERS = false;
	
	// If we have a known override for this monster, don't spade it.
	if (monster_hp_override contains OPPONENT)
		AUTOSPADE_MONSTERS = false;
	
	// Load existing spade data
	read_spade_maps();
	
	// Print the current range that we've discovered.
	if (spading_hp_min contains OPPONENT && spading_hp_max contains OPPONENT)
	{
		int low = spading_hp_min[OPPONENT];
		int high = spading_hp_max[OPPONENT];
		low = low - monster_level_variance(low);
		high = high + monster_level_variance(high);
		print("AUTOSPADE: " + OPPONENT + " has base HP in the range " +low+ " to " +high+ ".");
	}
	
	// If we already have this monster spaded out, we don't need to keep doing it.
	if (spading_hp_min contains OPPONENT && spading_hp_max contains OPPONENT)
	{
		int spading_hp_average = (spading_hp_min[OPPONENT] + spading_hp_max[OPPONENT]) / 2;
		int variance = monster_level_variance(spading_hp_average);
		if ((spading_hp_min[OPPONENT] >= spading_hp_average + variance) &&
			(spading_hp_max[OPPONENT] <= spading_hp_average - variance))
		{
			print("FightOptimizer spading result = " + spading_hp_average + " base HP");
			AUTOSPADE_MONSTERS = false;
		}
	}
	
	// If we're not coming in on round 0 or 1, we can't spade.
	if (ROUND != 0 && ROUND != 1)
		AUTOSPADE_MONSTERS = false;
	
	// Remove plink as an action if we're not spading.
	if (!AUTOSPADE_MONSTERS)
		remove action_map["plink"];
	
	// We can only steal if we won initiative and KoL is offering us the chance.
	boolean can_steal = ROUND < 2 && count(group_string(PAGE, "Pick [A-z]+ Pocket")) > 0;
	if (!can_steal)
		remove initial_action["steal, "];
	else if (count(item_drops(to_monster(OPPONENT))) < 1)	// no point stealing if nothing to steal
		remove initial_action["steal, "];

	
	// Add the dictionary to the action list if our opponent is vulnerable to it.
	if (dictionary_hurts[OPPONENT] &&
		(item_amount($item[dictionary]) > 0 || item_amount($item[facsimile dictionary]) > 0))
	{
		action_map["dictionary"] = true;
		sort_action_map();
	}
	
	// If this is a rampaging adding machine, add scrolls to our action list.
	if (contains_text(OPPONENT,"rampaging adding machine") && scrolls_to_add())
	{
		if (ambidextrous)
			action_map["add"] = true;
		else
			action_map["add, add"] = true;
		sort_action_map();
	}
	
	// If we're working on the flyer portion of the island quest, the flyer
	// may be an option.
	if (can_flyer()) {
		string loc = to_string(my_location());
		if (!contains_text(loc,"Battlefield") && !contains_text(loc, "Wartime")) {
			action_map["flyer"] = true;
			sort_action_map();
		}
	}

	// If wielding a chefstave can jiggle (once per combat)
	if (contains_text(pageString, "Jiggle your"))
		action_map["jiggle"] = true;
	
	// If this is the possessed silverware drawer and we don't already have
	// a shiny butcherknife, then run away and we'll get one.
	if ((OPPONENT == "possessed silverware drawer") &&
		available_amount($item[shiny butcherknife]) == 0)
	{
		runaway();
		return;
	}
	
	// If this is a special monster that can only be defeated by an item, use it
	// if we've got it ... otherwise scram.
	if (item_monsters contains OPPONENT) {
		item weakness = item_monsters[OPPONENT];
		if (item_amount(weakness) > 0)
			throw_item(weakness);
		else {
			runaway();
			error(OPPONENT + "'s only weakness is the " + weakness + ", and you don't have one!");
		}
		return;
	}
	
	// If this is the Naughty Sorceress, abort.
	if (contains_text(OPPONENT, "naughty sorceress")) error("Sorry, no Sorceress yet.");
	if (contains_text(OPPONENT, "ed the undying")) error("Sorry, no Ed the Undying yet.");
	if (contains_text(to_string(my_location()),"Molehill")) error("Sorry, no Mt. Molehill."); 
	if (!HOBOPOLIS_ADVENTURING){
		if (contains_text(to_string(my_location()),"Maze of Sewer")) error("No Hobopolis support. If " +
		"you're willing to risk it though, enable hobopolis adventuring in FightOptimizer.ash");
		if (contains_text(to_string(my_location()),"Esplanade")) error("No Hobopolis support. If " +
		"you're willing to risk it though, enable hobopolis adventuring in FightOptimizer.ash");
		if (contains_text(to_string(my_location()),"Purple Light")) error("No Hobopolis support. If " +
		"you're willing to risk it though, enable hobopolis adventuring in FightOptimizer.ash");
		if (contains_text(to_string(my_location()),"Burnbarrel")) error("No Hobopolis support. If " +
		"you're willing to risk it though, enable hobopolis adventuring in FightOptimizer.ash");
		if (contains_text(to_string(my_location()),"Heap")) error("No Hobopolis support. If " +
		"you're willing to risk it though, enable hobopolis adventuring in FightOptimizer.ash");
		if (contains_text(to_string(my_location()),"Burial Ground")) error("No Hobopolis support. If " +
		"you're willing to risk it though, enable hobopolis adventuring in FightOptimizer.ash");
		if (contains_text(to_string(my_location()),"Hobopolis Town")) error("No Hobopolis support. If " +
		"you're willing to risk it though, enable hobopolis adventuring in FightOptimizer.ash");
	}
	print(to_string(my_location()));
	// Remove plink from the list of actions unless we're aggressively
	// autospading an unknown monster.
	monster_hp(OPPONENT,0);
	if (!AUTOSPADE_MONSTERS || !AUTOSPADE_AGGRESSIVELY || !monster_level_unknown) {
		remove action_map["plink"];
		sort_action_map();
	}
	
	// We're going to build a table of strategies. Each strategy
	// can be boiled down to a single "cost" value: how much meat
	// it will take to restore HP/MP after the battle. Strategies
	// that don't result in a win are discarded.
	// 
	// How do we pick the strategies? Brute force, of course. We
	// iterate through all possible lists of 4 actions. To trim
	// the search space a bit we prune the branch and don't go
	// deeper if we win after just a few actions.
	//
	clear_strategy_map();
	
	foreach action0 in initial_action
		for i1 from 0 upto count(sorted_action_map)-1
			if (consider_strategy(action0 + sorted_action_map[i1]) == STRATEGY_CONTINUE)
				for i2 from 0 upto count(sorted_action_map)-1
					if (consider_strategy(action0 + sorted_action_map[i1] + ", " + sorted_action_map[i2]) == STRATEGY_CONTINUE)
						for i3 from 0 upto count(sorted_action_map)-1
							consider_strategy(action0 + sorted_action_map[i1] + ", " + sorted_action_map[i2] + ", " + sorted_action_map[i3]);
	
	// If we didn't find a strategy, there's nothing we can do.
	if (best_strategy == "")
		error("Couldn't find a winning strategy!");
	
	// Show the user what we're going to do, and then do it.
	if (AUTOSPADE_MONSTERS) print("FightOptimizer is auto-spading this monster...");
	print("FightOptimizer strategy: " + best_strategy + " (" + lowest_cost + " meat)", "green");
	execute_strategy(best_strategy);
	
	if (AUTOSPADE_MONSTERS)
	{
		// Print the current range that we've discovered.
		if (spading_hp_min contains OPPONENT && spading_hp_max contains OPPONENT)
		{
			int low = spading_hp_min[OPPONENT];
			int high = spading_hp_max[OPPONENT];
			low = low - monster_level_variance(low);
			high = high + monster_level_variance(high);
			print("AUTOSPADE: " + OPPONENT + " has base HP in the range " +low+ " to " +high+ ".");
		}

		// Save data
		write_spade_maps();
	}
	print("fightoptimzer finished called","blue");
}

