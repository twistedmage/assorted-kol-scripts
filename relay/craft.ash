import SmashLib.ash
import zlib.ash

record stuff {
    string content; // What to write.
    int tier;       // Useless => Powders => Nuggets => Wads => Sugar => Sea Salt => depl. Grim. => Epic Wad => Ult. Wad => Crovacite
    string alt;     // Alt text, i.e. element percentages
};
string[int]tier;
tier[count(tier)] = "Useless";
tier[count(tier)] = "1P";
tier[count(tier)] = "2P";
tier[count(tier)] = "3P";
tier[count(tier)] = "1N/4P";
tier[count(tier)] = "2N/1N+3P";
tier[count(tier)] = "3N";
tier[count(tier)] = "1W/4N";
tier[count(tier)] = "2W/1W+3N";
tier[count(tier)] = "3W";
tier[count(tier)] = "Sugar shard";
tier[count(tier)] = "Sea salt crystal";
tier[count(tier)] = "Chunk of depleted Grimacite";
tier[count(tier)] = "Epic Wad";
tier[count(tier)] = "Ultimate Wad";
tier[count(tier)] = "Wad of Crovacite";

void craft_relay() {
	print("craft_relay called","blue");
    buffer results;
    boolean smash;
    results.append(visit_url());
    if(results.contains_text("Smash:")) smash = true;
    if(!smash) return;
    results.insert(results.index_of("<head>")+6, 
                      "\n<script language='JavaScript'>\nfunction toggle(it) {document.getElementById(" +
                      "it).style.display=(el.style.display!='none')?'none':'inline';}\nfunction recolo" +
                      "r(filter){var m = document.pulverize.smashitem;for(i=0;i<m.length;i++) {if(filt" +
                      "er!='Show All' && filter!='Elemental' && filter!='#>1') m[i].style.color=(m[i]." +
                      "title.indexOf(filter.toLowerCase())>-1)?'':'silver';if(filter=='Show All') m[i]" +
                      ".style.color='';if(filter=='#>1')m[i].style.color=(m[i].text.indexOf(' (1)')<0)" +
                      "?'':'silver';if(filter=='Elemental')m[i].style.color=(m[i].title.indexOf('cold'" +
                      ")>-1|| m[i].title.indexOf('hot')>-1 || m[i].title.indexOf('hot')>-1 || m[i].tit" +
                      "le.indexOf('sleaze')>-1 || m[i].title.indexOf('spooky')>-1 || m[i].title.indexO" +
                      "f('stench')>-1)?'':'silver';}}\n</script>");
    int headerEnd = results.index_of("<select name=smashitem><option value=0>-select an item-</option>")+64;
    results.substring(0,headerEnd).write();
    results.delete(0,headerEnd);
    buffer footer;
    int footerStart = results.index_of("</select>");
    footer.append(results.substring(footerStart));
    results.delete(footerStart,results.length());
    string[int]row = split_string(results,"<option ");
    stuff[int] type;
    foreach i in row{
        item it = row[i].excise("value="," descid=").to_int().to_item();
        float [string] element_type = get_smash_element(it);
        stuff m;
        switch(get_smash_tier(it)) {
            case "exception":
                if (element_type contains "useless") {
                    m.tier = 0;
                    break;
                }
                m.tier = 10;
                if (element_type contains "sugar")
                    break;
                m.tier += 1;
                if (element_type contains "sea salt")
                    break;
                m.tier += 1;
                if (element_type contains "depleted Grimacite")
                    break;
                m.tier += 1;
                if (element_type contains "epic")
                    break;
                m.tier += 1;
                if (element_type contains "ultimate")
                    break;
                m.tier += 1;
                break;
            case "3W":
                m.tier+=1;
            case "2W":
                m.tier+=1;
            case "1W":
                m.tier+=1;
            case "3N":
                m.tier+=1;
            case "2N":
                m.tier+=1;
            case "1N":
                m.tier+=1;
            case "3P":
                m.tier+=1;
            case "2P":
                m.tier+=1;
            case "1P":
                m.tier+=1;
        }
        m.content = row[i];
        float [item] yield = get_smash_yield(it);
        foreach type in yield
            m.alt+=(type + ": " + yield[type]+"; ");
        m.alt = "title='" + m.alt + "'";
        m.content = m.content.replace_string("descid=", m.alt + " descid=");
        if(m.content=="") continue;
        type[i] = m;
        row[i] = m.content;
    }
    sort type by -value.tier;
    boolean written;
    foreach i in type{
        if(!written) {write("<optgroup label='"+tier[type[i].tier]+"'><option "+type[i].content);written = true;continue;}
        if(type[i].tier!=type[i-1].tier) write("</optgroup><optgroup label='"+tier[type[i].tier]+"'>");
        if(type[i].content.contains_text("<option")) {write(type[i].content);continue;}
        write("<option "+type[i].content);
    }
    footer = footer.replace_string(" onclick='describe(document.pulverize.smashitem);'>", " onclick='describe(document.pulverize.smashitem);'>"
                            + "<span onclick=\"toggle('settingsDiv')\">[settings]</span><br /><div id=\"settingsDiv\" style=\"display: none;"
                            + " padding: 4px;\"><label for=\"filterMenu\">Filter:</label><select name=\"filterMenu\" onchange=\"recolor(this.value)"
                            + "\"><option>Show All</option><option>Elemental</option><option>Cold</option><option>Hot</option><option>"
                            + "Sleaze</option><option>Spooky</option><option>Stench</option><option>Twinkly</option><option>#>1</option></select></div>");
    write("</optgroup></select>"+footer);
}

void main()
{
	craft_relay();
}
