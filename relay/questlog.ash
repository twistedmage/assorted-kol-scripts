script "Monster Manuel Improvement";
// Version 1.3

int offset;  // Number of characters inserted

void add(buffer page, string add, int x) {
	if(add == "") return;
	x += offset;
	page.insert(x, ")</span>");
	page.insert(x, add);
	page.insert(x, " <span style='font-weight:normal;color:#808080'>(");
	offset += length(add) + 57; // 57 is length of CSS and border characters
}

// Look up monsters by first 23 characters of first factoid
string factoids(string fact) {
	switch(fact) {
	// Gremlins
	case "Batwinged gremlins are sometimes": return "molybenium hammer";
	case "The erudite gremlin has an I.Q. ": return "molybenium crescent wrench";
	case "The spider DNA in the gremlin is": return "molybenium pliers";
	case "Man, look at the abs on that gre": return "molybenium screwdriver";
	// El Vibrato
	case "Honestly, all of the El Vibrato ": // bizarre
	case "The hulking construct enjoys a p": // hulking
	case "Industrious constructs have a ru": // industrious
	case "All it really wants is a hug. Go": // lonely
	case "The El Vibrato constructs play i": // menacing
	case "The towering construct's clamp i": // towering
		return "translated";
/*	case "El Vibrato punchcards make terri": // bizarre
	case "The hulking construct enjoys a h": // hulking
	case "The floors of El Vibrato settlem": // industrious
	case "This_is_currently_not_on_the_wik": // lonely
	case "The menacing construct is actual": // menacing
	case '"CHAPAZEVE NOFUBECHO FULA" is "V': // towering
		break; */
	// Nightstands
	case "The nightstand can be disassembl":
	case "The animated nightstand is made ": return '"One Nightstand" noncombat';
	case "This nightstand was assembled wi":
	case "Mahogany is not actually a type ": return "combat adventure";
	// Mimics
	case "A mimic in its natural form kind": return "Dungeon of Doom";
	case "Mimic eggs greatly resemble gold": return "bottom barrels";
	case "The least pleasant part of being": return "middle barrels";
	case "The only thing a mimic can't mim": return "top barrels";
	// clingy pirate
	case "Although they're kind of a hassl": return "female";
	case "Clingy pirates have so much love": return "male";
	}
	return "";
}

string spirit(string atk, string def) {
	switch(atk) {
	case "156": return "rough stone sphere";
	case "158": return "mossy stone sphere";
	case "162": return "smooth stone sphere";
	case "160": return def  == "140"? "cracked stone sphere"
		: "obsidian dagger";
	}
	return "";
}

string nemesis(string atk) {
	switch(atk) {
	case "27" : return "Inner Sanctum";
	case "170": return "Nemesis' Lair";
	case "185": return "Volcanic Cave";
	}
	return "";
}

void manuel_relay() {
	buffer log;
	log.append(visit_url());
	
	// Let big images be big
	log.replace_string(" width=100></td>", "></td>");
	
	matcher mob = create_matcher("95%>.+?(adventureimages/[^>]+).+?size=\\+2>([^<]+).+?size=\\+2>([^<]+).+?<li>(.{32}).+?size=\\+2>([^<]+)", log);
	// Groups: 1 = image name, 2 = attack, 3 = monster name, 4 = first factoid, 5 = defense.
	// To keep matching simple, only the first 32 characters of the factoid are captured.
	
	while(mob.find())
		switch(mob.group(3)) {
		// Fix Your Shadow
		case "(shadow opponent)":
			buffer shadow;
			shadow.append("otherimages/shadows/");
			shadow.append(my_class().to_int().to_string());
			shadow.append(modifier_eval("X") > 0? "1": "0");
			shadow.append(".gif");
			log.replace_string("adventureimages/.gif", shadow);
			offset += (length(shadow) - 20); // This many extra characters are added
			break;
		// Gremlins
		case "batwinged gremlin":
		case "erudite gremlin":
		case "spider gremlin":
		case "vegetable gremlin":
		// El Vibrato
		case "bizarre construct":
		case "hulking construct":
		case "industrious construct":
		case "lonely construct":
		case "menacing construct":
		case "towering construct":
		// Others
		case "animated nightstand":
		case "mimic":
		case "clingy pirate":
			log.add(factoids(mob.group(4)), mob.end(3));
			break;
		// Annotate ancient protector spirits
		case "ancient protector spirit":
			log.add(spirit(mob.group(2), mob.group(5)), mob.end(3));
			break;
		// Annotate Nemesi
		case "Gorgolok, the Infernal Seal":
		case "Stella, the Turtle Poacher":
		case "Spaghetti Elemental":
		case "Lumpy, the Sinister Sauceblob":
		case "Spirit of New Wave":
		case "Somerset Lopez, Dread Mariachi":
			log.add(nemesis(mob.group(2)), mob.end(3));
			break;
		}
	
	log.write();
}

void main()
{
	manuel_relay();
}