// ashq set_property("dailyDeedsOptions", get_property("dailyDeedsOptions") + ",$CUSTOM|Simple|Chat with ChibiBuddy™|ashq import ChibiParent; haveChat();|1")
script "ChibiParent.ash";
notify eegee;

import <zlib.ash>;

record ChibiStat {
  string name;
  int level;
};

record AlterStat {
  string choice1;
  string choice2;
  string choice2AfterDailyAdv;
};

ChibiStat[4] currentStats;
AlterStat[string, string] alterStats;
int chibiAge;

string useChibiBuddy() {
  return visit_url("inv_use.php?pwd&whichitem=5908");
}

void putChibiBuddyAway() {
  visit_url("choice.php?pwd&option=7&whichchoice=627");
}

string findWhichChoice(string page) {
  matcher statMatcher = create_matcher("whichchoice value=(\\d+)", page);
  find(statMatcher);
  return group(statMatcher, 1);
}

string doSomethingElseWithChibiBuddy(string page) {
  return visit_url("choice.php?pwd&option=6&whichchoice=" + findWhichChoice(page));
}

string getInitialPage() {
  string result = useChibiBuddy();
  
  if (!contains_text(result, "ChibiBuddy")) {
    vprint("ChibiBuddy is not turned on.", 0);
  }
  if (contains_text(result, "Do something else with your ChibiBuddy")) {
    vprint("ChibiBuddy was turned already on; returning to initial page.", "gray", 3);
    result = doSomethingElseWithChibiBuddy(result);
  }
  
  return result;
}

void haveChat(string page) {
  if (contains_text(page, "choiceform5")) {
    vprint("Obtaining ChibiChanged™..", 2);
    visit_url("choice.php?pwd&option=5&whichchoice=627");
  }
  else {
    vprint("Already got ChibiChanged™ today.", "gray", 2);
  }
}

void haveChat() {
  haveChat(getInitialPage());
  putChibiBuddyAway();
}

int parseAge(string page) {
  matcher statMatcher = create_matcher("is (\\d+) days old", page);
  if (!find(statMatcher)) {
    return 1;
  }
  return to_int(group(statMatcher, 1));
}

void init() {
  check_version("ChibiParent", "chibiParent", "0.77", 11634);
  
  setvar("chibiParent_allowBalancing", true);
  setvar("chibiParent_allowAdventuring", true);
  setvar("chibiParent_allowDynamicBounds", true);
  setvar("chibiParent_distanceTillAdventure", 2);
  
  setvar("chibiParent_haveChat", true);
  setvar("chibiParent_pause", 5);
  
  setvar("chibiParent_irresponsible", false);
  
  currentStats[0] = new ChibiStat("Fitness");
  currentStats[1] = new ChibiStat("Intelligence");
  currentStats[2] = new ChibiStat("Socialization");
  currentStats[3] = new ChibiStat("Alignment");
  
  load_current_map("ChibiBuddy", alterStats);
  
  if (available_amount($item[ChibiBuddy (on)]) == 0) {
    vprint("ChibiBuddy™ (on) is not available. If you have one, please turn it on.", 0);
  }
  if (!to_boolean(vars["chibiParent_allowBalancing"]) && !to_boolean(vars["chibiParent_allowAdventuring"])) {
    vprint("You must allow balancing and/or adventuring!", 0);
  }
  
  string page = getInitialPage();
  
  chibiAge = parseAge(page);
  if (to_boolean(vars["chibiParent_irresponsible"]) && to_boolean(vars["chibiParent_haveChat"])) {
    haveChat(page);
  }
}

int parseLevel(string page, string statName) {
  matcher statMatcher = create_matcher(statName + ".*?alt=\"(\\d+)", page);
  if (!find(statMatcher)) {
    vprint("ChibiBuddy™ might have died recently. If you have one, please turn it on.", 0);
  }
  return to_int(group(statMatcher, 1));
}

void refreshStats() {
  string page = visit_url("choice.php");
  foreach i, cStat in currentStats {
    cStat.level = parseLevel(page, cStat.name);
  }
  sort currentStats by value.level;
}

void printStats() {
  vprint("--- Current Stats ---", 1);
  foreach i, chibiStat in currentStats {
    string colour = "green";
    if (chibiStat.level < 4) {
      colour = "blue";
    }
    else if (chibiStat.level > 6) {
      colour = "red";
    }
    else if (chibiStat.level  == 5) {
      colour = "black";
    }
    vprint_html("<b>" + chibiStat.name + ":</b> " + "<font color='" + colour + "'>" + chibiStat.level + "</font>", 2);
  }
  vprint("--- [" + currentStats[0].level + ", " + currentStats[1].level + ", " + currentStats[2].level + ", " + currentStats[3].level + "]  ---", 1);
}

int remapChoice(string choiceName) {
  switch (choiceName) {
    case "Feed":
      return 1;
    case "Entertain":
      return 2;
    case "Interact":
      return 3;
    case "Explore":
      return 4;
    default:
      vprint("Could not remap choice name '" + choiceName + "'. Did data/ChibiBuddy.txt download properly?", 0);
      return -1;
  }
}

void printResults(string page) {
  matcher statMatcher = create_matcher("Results.*?<center><table><tr><td>(.*?)</td>", page);
  if (!find(statMatcher)) {
    set_property("_chibibuddyAdventuresUsed", 0);
    vprint("There were no results. ChibiBuddy™ probably died, please turn it back on.", 0);
  }
  string results = replace_string(group(statMatcher, 1), "<p>", "<br>");
  vprint_html("<hr><b>Results:</b>&nbsp;" + results + "<hr>", 2);
}

void followPath(AlterStat path) {
  vprint("following path => " + path.choice1 + ", " + path.choice2, 4);
  wait(to_int(vars["chibiParent_pause"]));
  
  string pageChoice1 = visit_url("choice.php?pwd&whichchoice=627&option=" + remapChoice(path.choice1));
    
  if ((to_int(get_property("_chibibuddyAdventuresUsed")) < 5) && !contains_text(pageChoice1, "choiceform1")) {
    vprint("Nothing happened because you ran out of daily adventures.(this happens when adventures were used outsite ChibiParent)", "gray", 1);
    set_property("_chibibuddyAdventuresUsed", 5);
    doSomethingElseWithChibiBuddy(pageChoice1);
    return;
  }
  
  string pageChoice2 = visit_url("choice.php?pwd&whichchoice=" + findWhichChoice(pageChoice1) + "&option=" + path.choice2);
  printResults(pageChoice2);
}

void useBalancing(int increaseIndex, int decreaseIndex) {
  printStats();
  vprint("BALANCING by increasing [" + increaseIndex + "]'" + currentStats[increaseIndex].name + "' and decreasing [" + decreaseIndex + "]'" + currentStats[decreaseIndex].name + "'.", "orange", 1);
  followPath(alterStats[currentStats[increaseIndex].name, currentStats[decreaseIndex].name]);
}

int optimalStatLevel(int index) {
  if (to_boolean(vars["chibiParent_allowBalancing"])) {
    return ((index <= 1) ? 4 : 6);
  }
  
  return 5;
}

void useBalancing() {
  if ((currentStats[0].level != optimalStatLevel(0)) || (currentStats[3].level != optimalStatLevel(3))) {
    useBalancing(0, 3);
  }
  else {
    useBalancing(1, 2);
  }
}

void useAdventuring(int statIndex) {
  printStats();
  if (currentStats[statIndex].level < optimalStatLevel(statIndex)) {
    vprint("ADVENTURING to increase [" + statIndex + "]'" + currentStats[statIndex].name + "'.", "orange", 1);
    followPath(alterStats[currentStats[statIndex].name, "None"]);
  }
  else {
    vprint("ADVENTURING to decrease [" + statIndex + "]'" + currentStats[statIndex].name + "'.", "orange", 1);
    followPath(alterStats["None", currentStats[statIndex].name]);
  }
  
  set_property("_chibibuddyAdventuresUsed", to_int(get_property("_chibibuddyAdventuresUsed")) + 1);
}

int priorityForBalancing(ChibiStat chibiStat, boolean bottom) {
  int result;
  
  switch {
    case (chibiStat.level == (bottom ? 1 : 9)):
      result += 1;
    case (chibiStat.level == (bottom ? 2 : 8)):
      result += 1;
    case (bottom ? (chibiStat.level >= 5) : (chibiStat.level <= 5)):
      result += 1;
    case (chibiStat.level == (bottom ? 3 : 7)):
      result += 1;
  }
  
  return result;
}

int distanceForAdventuring(ChibiStat chibiStat) {
  return abs(chibiStat.level - 5);
}

void useAdventuring() {
  int index;
  int counter;
  
  foreach i, chibiStat in currentStats {
    int currentCounter;
    if (to_boolean(vars["chibiParent_allowBalancing"])) {
      currentCounter = priorityForBalancing(chibiStat, i <= 1);
    }
    else if (to_boolean(vars["chibiParent_allowAdventuring"])) {
      currentCounter = distanceForAdventuring(chibiStat);
    }
    
    if (currentCounter > counter) {
      index = i;
      counter = currentCounter;
    }
  }
  
  useAdventuring(index);
}

boolean areStatsOptimized() {
  return ((currentStats[0].level == optimalStatLevel(0))
       && (currentStats[1].level == optimalStatLevel(1))
       && (currentStats[2].level == optimalStatLevel(2))
       && (currentStats[3].level == optimalStatLevel(3)));
}

boolean isBalacingViable() {
  if (to_int(get_property("_chibibuddyAdventuresUsed")) >= 5) {
    return false;
  }
  
  int highestPriority;
  int countBelow;
  int countAbove;
  int totalDistanceFromOptimum;
  foreach i, chibiStat in currentStats {
    boolean bottom = i <= 1;
    if (to_boolean(vars["chibiParent_allowBalancing"])) {
      int priority = priorityForBalancing(chibiStat, i <= 1);
      highestPriority = max(highestPriority, priority);
    }
    
    if (chibiStat.level <= 5) {
      countBelow += 1;
    }
    else if (chibiStat.level >= 5) {
      countAbove += 1;
    }
    
    totalDistanceFromOptimum += abs(chibiStat.level - (bottom ? 4 : 6));
  }
  
  int maxPriority = 4;
  int maxDistance = to_int(vars["chibiParent_distanceTillAdventure"]);
  if (to_boolean(vars["chibiParent_allowDynamicBounds"])) {
    if (to_int(get_property("_chibibuddyAdventuresUsed")) >= 2) {
      maxPriority = 3;
      # maxDistance += 1;
    }
  }
  
  boolean priorityFine = highestPriority < maxPriority;
  boolean spreadFine = min(countBelow, countAbove) >= 2;
  boolean tooFarForAdventuring = totalDistanceFromOptimum > maxDistance;
  
  return priorityFine && spreadFine && tooFarForAdventuring;
}

boolean couldModifyStats() {
  refreshStats();
  if (areStatsOptimized()) {
    return false;
  }
  
  if (to_boolean(vars["chibiParent_allowBalancing"]) && isBalacingViable()) {
    useBalancing();
  }
  else if (to_boolean(vars["chibiParent_allowAdventuring"]) && (to_int(get_property("_chibibuddyAdventuresUsed")) < 5)) {
    useAdventuring();
  }
  else if (to_boolean(vars["chibiParent_allowBalancing"]) && to_boolean(vars["chibiParent_irresponsible"])) {
    useBalancing();
  }
  else {
    return false;
  }
  
  return true;
}

void displaySummary(int actionsUsed, int advsUsed) {
  vprint_html("<h3>Finished running ChibiParent</h3>", 1);
  vprint("", 1);
  printStats();
  vprint("", 1);
  vprint("Adventured: " + advsUsed, "orange", 1);
  vprint("Balanced: " + (actionsUsed - advsUsed), "orange", 1);
  vprint_html("<b style='color: orange; font-size: larger;'>Total actions: " + actionsUsed + "</b>", 1);
  vprint("ChibiBuddy™ is " + chibiAge + ((chibiAge == 1) ? " day" : " days") + " old.", "teal", 1);
  vprint("", 1);
  if (areStatsOptimized()) {
    vprint("Stats optimized!", "#9400D3", 1);
  }
  if ((chibiAge >= 11) && !contains_text(visit_url("trophies.php"), "Great Responsibility")) {
    vprint_html("<b style='color: #9400D3; font-size: large;'>You qualify for the \"Great Responsibility\" trophy!</b> Go buy it <a href=\"trophy.php\">here</a>.", 1);
  }
}

void main() {
  init();
  
  int actionsUsed;
  int advsUsed = to_int(get_property("_chibibuddyAdventuresUsed"));
  
  while (couldModifyStats()) {
    actionsUsed += 1;
  }
  
  if (!to_boolean(vars["chibiParent_irresponsible"]) && to_boolean(vars["chibiParent_haveChat"])) {
    haveChat(visit_url("choice.php"));
  }
  putChibiBuddyAway();
  displaySummary(actionsUsed, to_int(get_property("_chibibuddyAdventuresUsed")) - advsUsed);
}