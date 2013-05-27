/*Clan Raidlogs(.ash) by Almighty Sapling
visual design & CSS borrowed from Dr. Evi1.
v0.3
TODO:
Loot Manager
Options Manager
*/

string expand(string s){
 switch(s){
  case "TS":return "Town Square";
  case "BB":return "Burnbarrel<br>Blvd.";
  case "EE":return "Exposure<br>Esplanade";
  case "AHBG":case "BG":return "Ancient Hobo<br>Burial Ground";
  case "PLD":return "Purple Light<br>District";
  case "Slime":return "Slime Tube";
  case "Parts":return "Richard";
 }
 return s;
}

string bossName(string s){
 switch(s){
  case "TS":return "Hodgman";
  case "BB":return "Ol' Scratch";
  case "EE":return "Frosty";
  case "Heap":return "Oscus";
  case "AHBG":case "BG":return "Zombo";
  case "PLD":return "Chester";
  case "Slime":return "Mother Slime";
  case "Parts":return "Richard";
 }
 return s;
}

string linkify(string u, string[string] players){
 return "<a href=\"showplayer.php?who="+players[u]+"\">"+u+"</a>";
}

string pullField(int[string,string] fakeField, string fName){
 string rv;
 foreach s,i in fakeField[fName] rv=s;
 return rv;
}

string getName(string l, string[string] players){
 matcher m=create_matcher("(?:<b>)?([\\w\\s_]+) \\(#(\\d+)\\)",l);
 if(!m.find())return ".";
 players[m.group(1)]=m.group(2);
 return m.group(1);
}

int getTurns(string l){
 matcher m=create_matcher("\\((\\d+) turns?\\)",l);
 if(!m.find())return 0;
 return m.group(1).to_int();
}

int parseImageN(string l){
 matcher m=create_matcher("(?<!sewer)(\\d+)\\.gif",l);
 if(!m.find())return -1;
 return m.group(1).to_int();
}

int parseImageS(string l){
 matcher m=create_matcher("(tube_boss|\\d+)\\.gif",l);
 if(!m.find())return -1;
 if(m.group(1)=="tube_boss")return 10;
 return m.group(1).to_int();
}

void getData(int runType, string page,int[string,string,string] data,string[string,string] theMatcher, string[string] players, boolean activeComment){
 string hobo="NONE";
 string st="NONE";
 string hh="NONE";
 string tp;
 string w;
 int t;
 matcher m;
 if(runType==0){
  if(page.contains_text("<b>Slime Tube run,")) runType=2;
  else if(page.contains_text("<b>Hobopolis run,")) runType=1;
  else runType=3;
 }
 switch(runType){
  case 3:
   m=create_matcher("run,(.+?)</table>",page);
   if(m.find())hh=m.group(1);
   else print("GRRR");
   break;
  case 2:
   m=create_matcher("<b>Slime Tube run,(.+?)</table>",page);
   if(m.find())st=m.group(1);
   data[".data","Slime",".image"]=-2;
   break;
  case 1:
   m=create_matcher("<b>Hobopolis run,(.+?)</table>",page);
   if(m.find())hobo=m.group(1);
   data[".data","TS",".image"]=-2;
   data[".data","BB",".image"]=-2;
   data[".data","EE",".image"]=-2;
   data[".data","Heap",".image"]=-2;
   data[".data","AHBG",".image"]=-2;
   data[".data","PLD",".image"]=-2;
   break;
  default:
   m=create_matcher("<div id='Hobopolis'>(.+?)</div>",page);
   if(m.find())hobo=m.group(1);
   else data[".data","Hobo",".hasdata"]=-1;
   m=create_matcher("<div id='SlimeTube'>(.+?)</div>",page);
   if(m.find())st=m.group(1);
   m=create_matcher("<div id='HauntedHouse'>(.+?)</div>",page);
   if(m.find())hh=m.group(1);
   break;
 }
 string[int] lines;
 m=create_matcher("Sewers:</b><blockquote>(.+?)</blockquote>",hobo);
 if(m.find()){
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["Sewer"]{
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l,players);
   t=getTurns(l);
   data[w,"Sewer",pointName]+=t;
   data[w,"Sewer",".total"]+=t;
   data[w,".hobo",".total"]+=t;
   data[".total","Sewer",pointName]+=t;
   data[".total","Sewer",".total"]+=t;
   data[".total",".hobo",".total"]+=t;
   break;
  }
 }else{
  data[".data","Sewer",".hasdata"]=-1;
 }
 m=create_matcher("Town Square:</b><blockquote>(.+?)</blockquote>",hobo);
 if(m.find()){
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["TS"]{
   if(pointName.char_at(0)==".")continue;
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l,players);
   t=getTurns(l);
   data[w,"TS",pointName]+=t;
   data[w,"TS",".total"]+=t;
   data[w,".hobo",".total"]+=t;
   data[".total","TS",pointName]+=t;
   data[".total","TS",".total"]+=t;
   data[".total",".hobo",".total"]+=t;
   break;
  }  
 }else{
  data[".data","TS",".hasdata"]=-1;
 }
 data[".data","BB",".open"]=0;
 data[".data","EE",".open"]=0;
 data[".data","Heap",".open"]=0;
 data[".data","AHBG",".open"]=0;
 data[".data","PLD",".open"]=0;
 if(runType<0){
  tp=visit_url("clan_hobopolis.php?place=2");
  m=create_matcher("Town Square \\(picture #(\\d+)(o?)\\)",tp);
  if(m.find()){
   data[".data","TS",".image"]=m.group(1).to_int();
   if(data[".data","TS",".image"]==125)data[".data","TS",".image"]=13;
   data[".data","TS",".open"]=(m.group(2)=="o"?1:0);
   data[".data","BB",".open"]=-1;
   data[".data","EE",".open"]=-1;
   data[".data","Heap",".open"]=-1;
   data[".data","AHBG",".open"]=-1;
   data[".data","PLD",".open"]=-1;
  }else data[".data","TS",".image"]=-1;
  switch(data[".data","TS",".image"]){
   case 26:case 25:case 24:case 23:case 22:case 21:case 20:case 19:case 18:case 17:case 16:case 15: case 14: case 13:case 12:case 11:case 10:
    data[".data","PLD",".open"]=1;
   case 9:case 8:data[".data","AHBG",".open"]=1;
   case 7:case 6:data[".data","Heap",".open"]=1;
   case 5:case 4:data[".data","EE",".open"]=1;
   case 3:case 2:data[".data","BB",".open"]=1;break;
   case 1:case 0:break;
  }
 }
 data[".data","BB",".hasdata"]=-1;
 data[".data","EE",".hasdata"]=-1;
 data[".data","Heap",".hasdata"]=-1;
 data[".data","AHBG",".hasdata"]=-1;
 data[".data","PLD",".hasdata"]=-1;
 foreach area in $strings[BB,EE,Heap,AHBG,PLD]{
  if(data[".data",area,".open"]>-1){
   m=create_matcher(theMatcher[area,".gmatcher"]+":</b><blockquote>(.+?)</blockquote>",hobo);
   if(m.find()){
    data[".data",area,".open"]=1;
    data[".data",area,".hasdata"]=1;
    lines=split_string(m.group(1),"<br>");
    foreach ln,l in lines foreach pointName,mString in theMatcher[area]{
     if(pointName.char_at(0)==".")continue;
     m=create_matcher(mString,l);
     if(!m.find())continue;
     w=getName(l,players);
     t=getTurns(l);
     data[w,area,pointName]+=t;
     data[w,area,".total"]+=t;
     data[w,".hobo",".total"]+=t;
     data[".total",area,pointName]+=t;
     data[".total",area,".total"]+=t;
     data[".total",".hobo",".total"]+=t;
     break;
    }
   }
   if(runType<0){
    tp=visit_url("clan_hobopolis.php?place="+theMatcher[area,".place"]);
    data[".data",area,".image"]=parseImageN(tp);
   }
   if(data[".total",area,"!"+area.bossName()]>0)data[".data",area,".image"]=11;
  }
 }
 m=create_matcher("Miscellaneous</b><blockquote>(.+?)</blockquote>",hobo);
 if(m.find()){
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["TS"]{
   if(pointName.char_at(0)==".")continue;
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l,players);
   t=getTurns(l);
   data[w,"TS",pointName]+=t;
   data[w,"TS",".total"]+=t;
   data[w,".hobo",".total"]+=t;
   data[".total","TS",pointName]+=t;
   data[".total","TS",".total"]+=t;
   data[".total",".hobo",".total"]+=t;
   break;
  }
 }
 if(data[".total","TS","!Hodgman"]>0)data[".data","TS",".image"]=26;
 foreach pointName,mString in theMatcher["Parts"] data[".data","Richard",pointName]=0;
 if(runType<0){
  tp=visit_url("clan_hobopolis.php?place=3&action=talkrichard&whichtalk=3");
  if(tp.contains_text("a scarehobo")){
   foreach pointName,mString in theMatcher["Parts"]{
    if(pointName.char_at(0)==".")continue;
    m=create_matcher(mString,tp);
    if(!m.find())continue;
    data[".data","Richard",pointName]=m.group(1).to_int();
   }
  }
 }
 m=create_matcher("Miscellaneous</b><blockquote>(.+?)</blockquote>",st);
 if(m.find()){
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["Slime"]{
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l,players);
   t=getTurns(l);
   data[w,"Slime",pointName]+=t;
   data[w,"Slime",".total"]+=t;
   data[".stotal","Slime",pointName]+=t;
   data[".stotal","Slime",".total"]+=t;
   break;
  }
 }else{
  data[".data","Slime",".hasdata"]=-1;
 }
 if(runType<0){
  tp=visit_url("clan_slimetube.php");
  data[".data","Slime",".image"]=parseImageS(tp);
 }
 if(data[".stotal","Slime","!Mother Slime"]>0)data[".data","Slime",".image"]=11;
 m=create_matcher("Miscellaneous</b><blockquote>(.+?)</blockquote>",hh);
 if(m.find()){
  lines=split_string(m.group(1),"<br>");
  foreach ln,l in lines foreach pointName,mString in theMatcher["Haunted"]{
   m=create_matcher(mString,l);
   if(!m.find())continue;
   w=getName(l,players);
   t=getTurns(l);
   data[w,"Haunted",pointName]+=t;
   data[w,"Haunted",".total"]+=t;
   data[".htotal","Haunted",pointName]+=t;
   data[".htotal","Haunted",".total"]+=t;
   break;
  }
 }else{
  data[".data","Haunted",".hasdata"]=-1;
 }
 if(activeComment)map_to_file(data,"raidlog/rawdata.txt");
}

void pageHeader(string page){
 /*
  Tables: use tableD, [element]T
  Header: use rowD, [element]I, font-size:13px;
  Odd rows: use rowD, [element]O
  Even rows: use rowD, rowEven
  Totals: use rowD, [element]I
  
  T-comes from table
  O-comes from shaded
  I-comes from header/totals
 */
 writeln("<html><head><style type=\"text/css\">");
 writeln(".directory td{font-size:11px;border:0px;border-collapse:separate;padding:0px 10px;}");
 writeln(".tableD{font-size:11px;border:1px solid;border-spacing:0px;border-collapse:separate;background-color:#FFFFFF;width:100%;}");
 writeln(".rowD th,.rowD td{font-size:11px;text-align:center;padding:0px 3px;}");
 writeln(".rowEven{background-color:#FFFFFF;}");
 writeln(".bossKiller{font-weight:bold;color:black !important;}");
 writeln(".clear{font-weight:bold;color:darkgreen !important;}");
 writeln(".smalltxt{font-size:10px;color:black;background-color:white;font-weight:normal;padding:1px;height:auto;}");
 writeln(".smallbtn{font-size:9px;font-style:normal;color:black;border-color:gray;background-color:lightgray;font-weight:bold;height:16px;}");

 writeln(".SkinsC{color:black;}");
 writeln(".TST{border-color:black;}");
 writeln(".TSI{font-weight:bold;color:white;background-color:#17037D;}");
 writeln(".TSO{background-color:#E3E2EA;}");

 writeln(".SewerT, .PartsT{border-color:brown;}");
 writeln(".SewerI, .PartsI{font-weight:bold;color:white;background-color:#98790C;}");
 writeln(".SewerO, .PartsO{background-color:#DED3AB;}");

 writeln(".BootsC{color:#D93636;}");
 writeln(".BBT{border-color:red;}");
 writeln(".BBI{font-weight:bold;color:white;background-color:#D93636;}");
 writeln(".BBO{background-color:#FDC5C5;}");

 writeln(".EyesC{color:#3B7FEF;}");
 writeln(".EET{border-color:blue;}");
 writeln(".EEI{font-weight:bold;color:white;background-color:#3B7FEF;}");
 writeln(".EEO{background-color:#B8D3FE;}");

 writeln(".GutsC{color:#438C5B;}");
 writeln(".HeapT{border-color:green;}");
 writeln(".HeapI{font-weight:bold;color:white;background-color:#438C5B;}");
 writeln(".HeapO{background-color:#A8D8B8;}");

 writeln(".SkullsC{color:#919191;}");
 writeln(".AHBGT{border-color:gray;}");
 writeln(".AHBGI{font-weight:bold;color:white;background-color:#919191;}");
 writeln(".AHBGO{background-color:#DEDBDB;}");

 writeln(".CrotchesC{color:#B12DA6;}");
 writeln(".PLDT{border-color:purple;}");
 writeln(".PLDI{font-weight:bold;color:white;background-color:#B12DA6;}");
 writeln(".PLDO{background-color:#FAC1F5;}");

 writeln(".SlimeT{border-color:green;}");
 writeln(".SlimeI{font-weight:bold;color:white;background-color:#146803;}");
 writeln(".SlimeO{background-color:#C0D4BF;}");

 writeln(".HauntedT{border-color:FFA500;}");
 writeln(".HauntedI{font-weight:bold;color:white;background-color:#101010;}");
 writeln(".HauntedO{background-color:#FFA500;}");
 writeln("</style>");
 write("<script language=\"Javascript\" type=\"text/javascript\">function tog(e){ var i=document.getElementById(e);if(i.style.display==\"none\"){i.style.display=\"inline\";}else{i.style.display=\"none\";}}</script>");
 int i=page.index_of("<body>");
 write(page.substring(12,i+6));
}

void formatHBT(string[string,string] theMatcher, int[string,string,string] data){
 write("<table><tr class=\"rowD\">");
 foreach area in $strings[Parts,BB,EE,Heap,AHBG,PLD,TS] write("<td class=\""+area+"I\">"+area.bossName()+"</td>");
 write("</tr><tr>");
 foreach area in $strings[Parts,BB,EE,Heap,AHBG,PLD,TS] write("<td class=\""+area+"O\"><a href=\"clan_hobopolis.php?place="+theMatcher[area,".place"]+"\"><img src=\""+theMatcher[area,".image"]+"\" width=\"80px\" height=\"80px\" /></a></td>");
 write("</tr><tr class=\"rowD\">");
 write("<td><div style=\"border:1px solid brown;\">");
 foreach thing in $strings[Skins,Boots,Eyes,Guts,Skulls,Crotches]{
  write("<span class=\""+thing+"C\">"+data[".data","Richard",thing]+" "+thing+"</span><br>");
 }
 write("</div></td>");
 foreach area in $strings[BB,EE,Heap,AHBG,PLD]{
  write("<td width=\"75px\" class=\""+area+"I\">");
  switch(data[".data",area,".image"]){
   case -2:
    write("<font size=\"0.9em\">Data not available.</font>");
    break;
   case -1:
    write("<font size=\"0.9em\">Area not open yet or unavailable to you.</font>");
    break;
   case 10:
    write("<font size=\"0.9em\">Boss is ready for a fight!</font>");
    break;
   case 11:
    write("<font size=\"0.9em\">Defeated by ");
    foreach user in data{
     if(user.char_at(0)==".")continue;
     if(data[user,area,"!"+area.bossName()]<1)continue;
     write(user+"</font>");
     break;
    }
    break;
   default:
    write(data[".data",area,".image"]+"0% Complete");
  }
  write("</td>");
 }
 write("<td width=\"75px\" class=\"TSI\">");
 switch(data[".data","TS",".image"]){
  case -2:
   write("<font size=\"0.9em\">Data not available.</font>");
   break;
  case -1:
   write("<font size=\"0.9em\">Area not open yet or unavailable to you.</font>");
   break;
  case 25:
   write("<font size=\"0.9em\">Boss is ready for a fight!</font>");
   break;
  case 26:
   write("<font size=\"0.9em\">Defeated by ");
   foreach user in data{
    if(user.char_at(0)==".")continue;
    if(data[user,"TS","!Hodgman"]<1)continue;
    write(user+"</font>");
    break;
   }
   break;
  default:
   write(to_string(data[".data","TS",".image"]*4)+"% Complete");
   write("<br>Tent is "+(data[".data","TS",".open"]==1?"Open":"Closed")+"</td>");
 }
 write("</tr><tr><td colspan=\"7\"><form action=\"clan_hobopolis.php\" method=\"post\">");
 write("<input type=\"hidden\" name=\"preaction\" value=\"simulacrum\"><input type=\"hidden\" name=\"place\" value=\"3\">");
 write("<input class=\"smalltxt\" type=\"text\" name=\"qty\" value=\"0\" size=\"4\"><input class=\"smallbtn\" type=\"submit\" value=\"Make Scarehobos\">");
 writeln("</form></td></tr></table><br>");
}

void formatHB(string[string,string] theMatcher, int[string,string,string] data,int[int,string,string]odata,string[string] options,string clearID,string[string] players){
 boolean odd=false;//Full Area Table
 write("<table class=\"tableD TST\"><tr class=\"rowD\"><td class=\"TSI\" onclick=\"tog('totTable')\">Totals</td></tr><tr><td><center><div id=\"totTable\" style=\"display:inline;\"><table class=\"tableD TST\">");
 write("<tr class=\"rowD\"><th class=\"TSI\">Players</th>");
 foreach s in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{//Headers
  if(data[".data",s,".hasdata"]==-1)continue;
  write("<th class=\""+s+"I\">"+expand(s)+"</th>");
 }
 clear(odata);
 write("<th class=\"TSI\">Totals</th>");
 boolean customTotals=false;
 foreach att in $strings[marketMatter,richardMatter,defeatsMatter,sewersMatter] if(options[att]=="n")customTotals=true;
 if(customTotals)write("<th class=\"TSI\">Adjusted Total</th>");
 write("<tr>");
 int tmp;
 foreach user in data{//Sort data
  if(user.char_at(0)==".")continue;
  if(data[user,".hobo",".total"]<1)continue;
  odata[count(odata)]=data[user];
  odata[count(odata)-1,".name",user]=1;
  tmp=data[user,".hobo",".total"];
  if(options["marketMatter"]=="n")tmp-=data[user,"TS","Market<br>Trips"];
  if(options["richardMatter"]=="n"){
   tmp-=data[user,"TS","Made<br>Bandages"];
   tmp-=data[user,"TS","Made<br>Grenades"];
   tmp-=data[user,"TS","Made<br>Shakes"];
  }
  if(options["defeatsMatter"]=="n"){
   foreach area in $strings[TS,BB,EE,Heap,AHBG,PLD]{
    tmp-=data[user,area,"Defeats"];
    tmp-=data[user,area,"!bossloss"];
   }
   if(options["sewersMatter"]=="y")tmp-=data[user,"Sewer","Defeats"];
  }
  if(options["sewersMatter"]=="n")tmp-=data[user,"Sewer",".total"];  
  odata[count(odata)-1,".hobo",".rtotal"]=tmp;
 }
 sort odata by (value["Sewer",clearID]==0?5000:0)-value[".hobo",".rtotal"];
 foreach index in odata{//Full Area Table Data
  odd=!odd;
  write("<tr class=\"rowD\"><td class=\""+(odd?"TSO":"rowEven")+"\" style=\"text-align:left\">"+linkify(odata[index].pullField(".name"),players)+"</td>");
  foreach s in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{
   if(data[".data",s,".hasdata"]==-1)continue;
   write("<td class=\""+(odd?s+"O":"rowEven")+"\">"+odata[index,s,".total"]+"</td>");
  }
  write("<td class=\""+(odd?"TSO":"rowEven")+"\">"+odata[index,".hobo",".total"]+"</td>");
  if(customTotals)write("<td class=\""+(odd?"TSO":"rowEven")+"\">"+odata[index,".hobo",".rtotal"]+"</td>");
  write("</tr>");
 }
 write("<tr class=\"rowD\"><td class=\"TSI\">Total</td>");
 foreach s in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{//Full Area Table Total
  if(data[".data",s,".hasdata"]==-1)continue;
  write("<td class=\""+s+"I\">"+data[".total",s,".total"]+"</td>");
 }
 write("<td class=\"TSI\">"+data[".total",".hobo",".total"]);
 if(customTotals){
  tmp=data[".total",".hobo",".total"];
  if(options["marketMatter"]=="n")tmp-=data[".total","TS","Market<br>Trips"];
  if(options["richardMatter"]=="n"){
   tmp-=data[".total","TS","Made<br>Bandages"];
   tmp-=data[".total","TS","Made<br>Grenades"];
   tmp-=data[".total","TS","Made<br>Shakes"];
  }
  if(options["defeatsMatter"]=="n"){
   foreach area in $strings[TS,BB,EE,Heap,AHBG,PLD]{
    tmp-=data[".total",area,"Defeats"];
    tmp-=data[".total",area,"!bossloss"];
   }
   if(options["sewersMatter"]=="y")tmp-=data[".total","Sewer","Defeats"];
  }
  if(options["sewersMatter"]=="n")tmp-=data[".total","Sewer",".total"];  
  write("<td class=\"TSI\">"+tmp+"</td>");
 }
 writeln("</tr></table></div></center></td></tr></table><br>");
 foreach area in $strings[Sewer,TS,BB,EE,Heap,AHBG,PLD]{//Per-area tables
  if(data[".data",area,".hasdata"]<0)continue;
  write("<table class=\"tableD "+area+"T\"><tr class=\"rowD\"><td class=\""+area+"I\" onclick=\"tog('"+area+"Table')\">"+expand(area)+"</td></tr><tr><td><center><div id=\""+area+"Table\" style=\"display:inline;\"><table class=\"tableD "+area+"T\">");
  write("<th class=\""+area+"O\">Players</th>");
  foreach s in theMatcher[area]{//per-area headers
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".total",area,s]<1)&&((s!="Defeats")||data[".total",area,"!bossloss"]<1))continue;
   write("<th class=\""+area+"O\">"+s+"</th>");
  }
  write("<th class=\""+area+"O\">Totals</th>");
  clear(odata);
  foreach user in data{//Get and sort data
   if(user.char_at(0)==".")continue;
   if(data[user,area,".total"]<1)continue;
   odata[count(odata)]=data[user];
   odata[count(odata)-1,".name",user]=1;
  }
  sort odata by (area=="Sewer"?(1-value["Sewer",clearID])*5000-value[area,".total"]:-value[area,".total"]);
  odd=true;
  foreach index in odata{//per-area table data
   odd=!odd;
   write("<tr class=\"rowD\"><td class=\""+(odd?area+"O":"rowEven")+"\" style=\"text-align:left\">");
   write(linkify(odata[index].pullField(".name"),players)+((area=="Sewer")&&(odata[index,"Sewer",clearID]>0)?" <span class=\"clear\">(Clear"+(odata[index,"Sewer",clearID]>1?" x"+odata[index,"Sewer",clearID]:"")+")</span>":"")+(odata[index,area,"!"+area.bossName()]>0?" <span class=\"bossKiller\">(Boss)</span>":"")+"</td>");
   foreach s in theMatcher[area]{//per-area table data
    if(".!".contains_text(s.char_at(0)))continue;
    if((data[".total",area,s]<1)&&((s!="Defeats")||data[".total",area,"!bossloss"]<1))continue;
    write("<td class=\""+(odd?area+"O":"rowEven")+"\">"+odata[index,area,s]+((s=="Defeats")&&(odata[index,area,"!bossloss"]>0)?" ("+odata[index,area,"!bossloss"]+")":"")+"</td>");
   }
   write("<td class=\""+(odd?area+"O":"rowEven")+"\">"+odata[index,area,".total"]+"</td></tr>");
  }
  write("<tr class=\"rowD\"><td class=\""+area+"I\">Total</td>");
  foreach s in theMatcher[area]{//per-area totals row
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".total",area,s]<1)&&((s!="Defeats")||data[".total",area,"!bossloss"]<1))continue;
   write("<td class=\""+area+"I\">"+data[".total",area,s]+((s=="Defeats")&&(data[".total",area,"!bossloss"]>0)?" ("+data[".total",area,"!bossloss"]+")":"")+"</td>");
  }
  writeln("<td class=\""+area+"I\">"+data[".total",area,".total"]+"</td></tr></table></div></center></td></tr></table><br>");
 }
}

void formatST(string[string,string] theMatcher, int[string,string,string] data,int[int,string,string] odata,string[string] players){
 write("<table><tr><td width=\"80px\" valign=\"top\"><table>");//all of ST
 write("<tr class=\"rowD\"><td class=\"SlimeI\">Mother Slime</td></tr><tr><td class=\"SlimeO\"><a href=\"/clan_slimetube.php\"><img src=\""+theMatcher["Slime",".image"]+"\" width=\"80px\" height=\"80px\" /></a></td></tr><tr class=\"rowD\"><td class=\"SlimeI\">");
 switch(data[".data","Slime",".image"]){//Write the boss table text
  case -2:
   write("<font size=\"0.9em\">Data not available.</font>");
   break;
  case -1:
   write("<font size=\"0.9em\">Area not available to you.</font>");
   break;
  case 10:write("<font size=\"0.9em\">Boss is ready for a fight!</font>");break;
  case 11:write("<font size=\"0.9em\">Defeated by ");
   foreach user in data{
    if(user.char_at(0)==".") continue;
    if(data[user,"Slime","!Mother Slime"]<1) continue;
    write(user+"</font>");
    break;
   }
   break;
  default:write(data[".data","Slime",".image"]+"0% Complete");  
 }
 write("</td></tr></table></td><td width=\"100%\"><table class=\"tableD SlimeT\"><tr class=\"rowD\"><td class=\"SlimeI\" onclick='tog(SlimeTable);'>Slime Tube</td></tr><tr><td><center><div id=\"SlimeTable\" style=\"display:inline;\">");
 write("<table class=\"tableD SlimeT\"><tr class=\"rowD\"><th class=\"SlimeO\">Players</th>");
 foreach s in theMatcher["Slime"]{//Slime table header row
  if(".!".contains_text(s.char_at(0)))continue;
  if((data[".stotal","Slime",s]<1)&&((s!="Defeats")||data[".stotal","Slime","!bossloss"]<1))continue;
  write("<th class=\"SlimeO\">"+s+"</th>");
 }
 write("<th class=\"SlimeO\">Totals</th></tr>");
 clear(odata);
 foreach user in data{//data collection and sorting
  if(user.char_at(0)==".")continue;
  if(data[user,"Slime",".total"]<1)continue;
  odata[count(odata)]=data[user];
  odata[count(odata)-1,".name",user]=1;
 }
 sort odata by -value["Slime","Slimes"];
 boolean odd=true;
 foreach index in odata{//slime table rows
  odd=!odd;
  write("<tr class=\"rowD\"><td class=\""+(odd?"SlimeO":"rowEven")+"\" style=\"text-align:left\">"+linkify(odata[index].pullField(".name"),players)+"</td>");
  foreach s in theMatcher["Slime"]{
   if(".!".contains_text(s.char_at(0)))continue;
   if((data[".stotal","Slime",s]<1)&&((s!="Defeats")||data[".stotal","Slime","!bossloss"]<1))continue;
   write("<td class=\""+(odd?"SlimeO":"rowEven")+"\">"+odata[index,"Slime",s]+((s=="Defeats")&&(odata[index,"Slime","!bossloss"]>0)?" ("+odata[index,"Slime","!bossloss"]+")":"")+"</td>");
  }
  write("<td class=\""+(odd?"SlimeO":"rowEven")+"\">"+odata[index,"Slime",".total"]+"</td></tr>");
 }
 write("<tr class=\"rowD\"><td class=\"SlimeI\">Total</td>");
 foreach s in theMatcher["Slime"]{
  if(".!".contains_text(s.char_at(0)))continue;
  if((data[".stotal","Slime",s]<1)&&((s!="Defeats")||data[".stotal","Slime","!bossloss"]<1))continue;
  write("<td class=\"SlimeI\">"+data[".stotal","Slime",s]+((s=="Defeats")&&(data[".stotal","Slime","!bossloss"]>0)?" ("+data[".stotal","Slime","!bossloss"]+")":"")+"</td>");
 }
 writeln("<td class=\"SlimeI\">"+data[".stotal","Slime",".total"]+"</td></tr></table></div></center></td></tr></table></td></tr></table><br>");
}

void formatHH(string[string] players, boolean activeComment, string[string,string] theMatcher,int[int,string,string] odata,int[string,string,string] data){
 write("<table><tr><td width=\"80px\" valign=\"top\"><table>");//all of HH
 write("<tr class=\"rowD\"><td class=\"HauntedI\">Necbromancer</td></tr><tr><td width=\"90px\" class=\"HauntedO\"><a href=\"/clan_hh.php\"><img src=\""+theMatcher["Haunted",".image"]+"\" width=\"90px\" height=\"90px\" /></a></td></tr><tr class=\"rowD\"><td class=\"HauntedI\">");
/* switch(data[".htotal","Haunted","!Necbromancer"]){//Write the boss table text
  case 1:write("<font size=\"0.9em\">Defeated by ");
   foreach user in data{
    if(user.char_at(0)==".") continue;
    if(data[user,"Haunted","!Necbromancer"]<1) continue;
    write(user+"</font>");
    break;
   }
   break;
  default:
   write("<font size=\"0.9em\"></font>");
   break;
 }*/
 int tmp=0;
 clear(odata);
 foreach user in data{//data collection and sorting
  if(user.char_at(0)==".")continue;
  if(data[user,"Haunted",".total"]<1)continue;
  odata[count(odata)]=data[user];
  odata[count(odata)-1,".name",user]=1;
  tmp=data[user,"Haunted","!Mirrors"];
  tmp+=data[user,"Haunted","!Bullet"];
  tmp+=data[user,"Haunted","!Chainsaw"];
  tmp+=data[user,"Haunted","!Trap"];
  tmp+=data[user,"Haunted","!Guides"];
  tmp+=data[user,"Haunted","!Costume"];
  odata[count(odata)-1,"Haunted","Collected<br>Item"]=tmp;
  tmp=data[user,"Haunted","!NoiseUp"];
  tmp+=data[user,"Haunted","!NoiseDown"];
  tmp+=data[user,"Haunted","!DarkUp"];
  tmp+=data[user,"Haunted","!DarkDown"];
  tmp+=data[user,"Haunted","!FogUp"];
  tmp+=data[user,"Haunted","!FogDown"];
  odata[count(odata)-1,"Haunted","Mod ML"]=tmp;
 }
 sort odata by -value["Haunted",".total"];
 odata[count(odata),".name",".total"]=1;
 foreach s in theMatcher["Haunted"] if(s.char_at(0)=="&")odata[count(odata)-1,"Haunted",s]=0;
 for n from 0 upto count(odata)-2 foreach c,v in odata[n,"Haunted"] odata[count(odata)-1,"Haunted",c]+=v;
 if(activeComment)map_to_file(odata,"raidlog/HHodata.txt");
 write("</td></tr></table></td><td width=\"100%\"><table class=\"tableD HauntedT\"><tr class=\"rowD\"><td class=\"HauntedI\" onclick='tog(HauntedTable);'>Haunted Sorority House</td></tr><tr><td><center><div id=\"HauntedTable\" style=\"display:inline;\">");
 write("<table class=\"tableD HauntedT\"><tr class=\"rowD\"><th class=\"HauntedO\">Players</th>");
 foreach s in odata[count(odata)-1,"Haunted"]{//haunted table header row
  if(".!".contains_text(s.char_at(0)))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&"))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
  write("<th class=\"HauntedO\">"+s+"</th>");
 }
 write("<th class=\"HauntedO\">Totals</th></tr>");
 boolean odd=true;
 foreach index in odata{//haunted table rows
  if(index==count(odata)-1)break;
  odd=!odd;
  write("<tr class=\"rowD\"><td class=\""+(odd?"HauntedO":"rowEven")+"\" style=\"text-align:left\">"+linkify(odata[index].pullField(".name"),players)+(odata[index,"Haunted","!Necbromancer"]>0?" ("+odata[index,"Haunted","!Necbromancer"]+")":"")+(odata[index,"Haunted","!Guides"]>0?" (G)":"")+"</td>");
  foreach s in odata[count(odata)-1,"Haunted"]{
   if(".!".contains_text(s.char_at(0)))continue;
   if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
   write("<td class=\""+(odd?"HauntedO":"rowEven")+"\">"+odata[index,"Haunted",s]+((s=="Defeats")&&(odata[index,"Haunted","!bossloss"]>0)?" ("+odata[index,"Haunted","!bossloss"]+")":""));
   if("&".contains_text(s.char_at(0)))write(" ["+odata[index,"Haunted","!"+s.substring(6)]+"]");
   write("</td>");
  }
  write("<td class=\""+(odd?"HauntedO":"rowEven")+"\">"+odata[index,"Haunted",".total"]+"</td></tr>");
 }
 write("<tr class=\"rowD\"><td class=\"HauntedI\">Total</td>");
 foreach s in odata[count(odata)-1,"Haunted"]{//Haunted table totals
  if(".!".contains_text(s.char_at(0)))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
  write("<td class=\"HauntedI\">"+odata[count(odata)-1,"Haunted",s]+((s=="Defeats")&&(odata[count(odata)-1,"Haunted","!bossloss"]>0)?" ("+odata[count(odata)-1,"Haunted","!bossloss"]+")":""));
  if("&".contains_text(s.char_at(0)))write(" ["+odata[count(odata)-1,"Haunted","!"+s.substring(6)]+"]");
  write("</td>");
 }
 write("<td class=\"HauntedI\">"+odata[count(odata)-1,"Haunted",".total"]+"</td></tr>");
 write("<tr class=\"rowD\"><td class=\"HauntedI\">Current<br>Remaining:</td>");
 odd=true;
 foreach s in odata[count(odata)-1,"Haunted"]{//haunted table current estimates
  if(".!".contains_text(s.char_at(0)))continue;
  if((odata[count(odata)-1,"Haunted",s]==0)&&(s.char_at(0)!="&")&&((s!="Defeats")||data[".htotal","Haunted","!bossloss"]<1))continue;
  if((s.char_at(0)!="&")&&(s!="Mod ML")){
   write("<td class=\"HauntedI\"></td>");
   continue;
  }
  if(s=="Mod ML"){
   odd=false;
   tmp=odata[count(odata)-1,"Haunted","!DarkUp"]-odata[count(odata)-1,"Haunted","!DarkDown"];
   tmp+=odata[count(odata)-1,"Haunted","!FogUp"]-odata[count(odata)-1,"Haunted","!FogDown"];
   tmp+=odata[count(odata)-1,"Haunted","!NoiseUp"]-odata[count(odata)-1,"Haunted","!NoiseDown"];
   write("<td class=\"HauntedI\" style=\"font-weight:bold;\">ML: "+tmp+"</td>");
   continue;
  }
  tmp=300-odata[count(odata)-1,"Haunted",s];
  tmp-=floor(odata[count(odata)-1,"Haunted","!"+s.substring(6)]*((s=="&nbsp;Wolves")||(s=="&nbsp;Vamps")?17.5:12.5));
  write("<td class=\"HauntedI\">"+tmp+"</td>");
 }
 if(odd)write("<td class=\"HauntedI\">ML: 0</td>");
 else write("<td class=\"HauntedI\"></td>");
 writeln("</tr></table></div></center></td></tr></table></td></tr></table><br>");
}

void formatData(string clearID,string[string] options,int[int,string,string] odata, string[string,string] theMatcher,int runType,int[string,string,string] data,string[string] players,boolean activeComment){
 write("<center>");
 write("<table class=\"directory\"><tr>");
 write("<td><a href=\"clan_basement.php\">Basement</a></td>");
 write("<td><a href=\"clan_hobopolis.php?place=1\">Sewers</a></td>");
 write("<td><a href=\"clan_hobopolis.php?place=2\">Town Square</a></td>");
 write("<td><a href=\""+__FILE__+"?lootman=1\">Loot Manager</a></td>");
 write("<td><a href=\""+__FILE__+"?changeOpts=1\">Options</a></td>");
 write("</tr></table>");
 if(((runType<0)||(runType==1))&&(data[".data","Hobo",".hasdata"]!=-1)) formatHBT(theMatcher, data);
 if(((runType<0)||(runType==3))&&(data[".data","Haunted",".hasdata"]!=-1)) formatHH(players, activeComment, theMatcher, odata,data);
 if(((runType<0)||(runType==2))&&(data[".data","Slime",".hasdata"]!=-1)) formatST(theMatcher, data, odata, players);
 if(((runType<0)||(runType==1))&&(data[".data","Hobo",".hasdata"]!=-1)) formatHB(theMatcher, data, odata, options, clearID, players);
 write("</center>");
}

void pageFooter(string page){
 int i=page.index_of("<body>");
 write(page.substring(i+6));
}

void lootManager(string page){
 pageHeader(page);
 write("WIP<br><a href=\""+__FILE__+"\">BACK</a>");
 write("</body></html>");
}

void logOptions(){
}

void loadOptions(string[string] options,string[string] FF){
 string[string]defs;
 defs["marketMatter"]="n";
 defs["richardMatter"]="n";
 defs["defeatsMatter"]="n";
 defs["sewersMatter"]="n";
 file_to_map("raidlog/options.txt",options);
 if(FF contains "submitOpts"){
  foreach oN,oV in FF if(oN!="submitOpts")options[oN]=oV;
  foreach oN in $strings[marketMatter,richardMatter,defeatsMatter,sewersMatter] if(!(FF contains oN))options[oN]="n";
 }
 foreach oN,oV in defs if(!(options contains oN))options[oN]=oV;
 map_to_file(options,"raidlog/options.txt");
}

void clan_raidlogs_relay(){
	print("clan_raidlogs_relay called","blue");
	
	string[string] FF=form_fields();
	string page;
//	if (FF contains "viewlog") page=visit_url("clan_raidlogs.php?viewlog="+FF["viewlog"]);
//	else page=visit_url("clan_raidlogs.php");
	page=visit_url();
	//total, player, area, section, display name
	int[string,string,string] data;
	string[string] players;
	string[string] options;
	int[int,string,string] odata;

	int runType=-1;
	//Consts
	boolean activeComment=false;//uncomment next line for testing.
	//activeComment=true;
	string clearID="!Made it<br>Through";
	string[string,string] theMatcher;

	theMatcher["Parts",".place"]="3&action=talkrichard&whichtalk=3";
	theMatcher["Parts",".image"]="http://images.kingdomofloathing.com/adventureimages/richardmoll.gif";
	theMatcher["Parts","Skins"]="Richard has <b>(\\d+)</b> hobo skin";
	theMatcher["Parts","Crotches"]="Richard has <b>(\\d+)</b> hobo crotch";
	theMatcher["Parts","Skulls"]="Richard has <b>(\\d+)</b> creepy hobo skull";
	theMatcher["Parts","Guts"]="Richard has <b>(\\d+)</b> pile";
	theMatcher["Parts","Eyes"]="Richard has <b>(\\d+)</b> pairs? of frozen hobo";
	theMatcher["Parts","Boots"]="Richard has <b>(\\d+)</b> pairs? of charred hobo";
	theMatcher["Parts","!Bandages"]="has <b>(\\d+)</b> bandages";
	theMatcher["Parts","!Grenades"]="has <b>(\\d+)</b> grenades";
	theMatcher["Parts","!Protein Shakes"]="has <b>(\\d+)</b> protein";

	theMatcher["Sewer",clearID]="made it through the sewer";
	theMatcher["Sewer","&nbsp;Gators"]="defeated a sewer gator";
	theMatcher["Sewer","&nbsp;C.H.U.M.s"]="defeated a C. H. U. M.";
	theMatcher["Sewer","&nbsp;Goldfish"]="defeated a giant zombie goldfish";
	theMatcher["Sewer","Defeats"]="was defeated by";
	theMatcher["Sewer","Explored<br>Tunnels"]="explored";
	theMatcher["Sewer","Opened<br>Grates"]="sewer grate";
	theMatcher["Sewer","Turned<br>Valves"]="lowered the water level";
	theMatcher["Sewer","Gnawed<br>Through Cage"]="gnawed through";
	theMatcher["Sewer","Found Cage<br>Empty"]="empty cage";
	theMatcher["Sewer","Rescued<br>Caged Player"]="rescued";

	theMatcher["TS",".place"]="2";
	theMatcher["TS",".image"]="http://images.kingdomofloathing.com/adventureimages/hodgman.gif";
	theMatcher["TS","&nbsp;Normal Hobo"]="defeated  Normal hobo";
	theMatcher["TS","Defeats"]="was defeated by  Normal";
	theMatcher["TS","Market<br>Trips"]="went shopping in the Marketplace";
	theMatcher["TS","Performed"]="took the stage";
	theMatcher["TS","Busked"]="passed";
	theMatcher["TS","Moshed"]="mosh";
	theMatcher["TS","Ruined<br>Show"]="ruined";
	theMatcher["TS","Made<br>Bandages"]="bandage";
	theMatcher["TS","Made<br>Grenades"]="grenade";
	theMatcher["TS","Made<br>Shakes"]="protein shake";

	theMatcher["TS","!Hodgman"]="defeated  Hodgman";
	theMatcher["TS","!bossloss"]="was defeated by  H";

	theMatcher["BB",".gmatcher"]="Blvd\\.";
	theMatcher["BB",".place"]="4";
	theMatcher["BB",".image"]="http://images.kingdomofloathing.com/adventureimages/olscratch.gif";
	theMatcher["BB","&nbsp;Hot Hobo"]="defeated  Hot hobo";
	theMatcher["BB","Defeats"]="defeated by  Hot";
	theMatcher["BB","!Ol' Scratch"]="defeated  Ol";
	theMatcher["BB","!bossloss"]="defeated by  Ol";
	theMatcher["BB","Threw Tire"]="on the fire";
	theMatcher["BB","Tirevalanche"]="tirevalanche";
	theMatcher["BB","Diverted<br>Steam"]="diverted some steam away";
	theMatcher["BB","Opened<br>Door"]="clan coffer";
	theMatcher["BB","Burned<br>by Door"]="hot door";

	theMatcher["EE",".gmatcher"]="Esplanade";
	theMatcher["EE",".place"]="5";
	theMatcher["EE",".image"]="http://images.kingdomofloathing.com/adventureimages/frosty.gif";
	theMatcher["EE","&nbsp;Cold Hobo"]="defeated  Cold hobo";
	theMatcher["EE","Defeats"]="defeated by  Cold";
	theMatcher["EE","!Frosty"]="defeated  Frosty";
	theMatcher["EE","!bossloss"]="defeated by  Frosty";
	theMatcher["EE","Freezers"]="freezer";
	theMatcher["EE","Fridges"]="fridge";
	theMatcher["EE","Pipes Busted"]="broke";
	theMatcher["EE","Diverted Water<br>Out"]="diverted some cold water out of";
	theMatcher["EE","Diverted Water<br>to BB"]="diverted some cold water to";
	theMatcher["EE","Yodeled<br>(a little)"]="yodeled a little";
	theMatcher["EE","Yodeled<br>(a lot)"]="yodeled quite a bit";
	theMatcher["EE","Yodeled<br>(like crazy)"]="yodeled like crazy";

	theMatcher["Heap",".gmatcher"]="Heap";
	theMatcher["Heap",".place"]="6";
	theMatcher["Heap",".image"]="http://images.kingdomofloathing.com/adventureimages/oscus.gif";
	theMatcher["Heap","&nbsp;Stench Hobo"]="defeated  Stench hobo";
	theMatcher["Heap","Defeats"]="defeated by  Stench";
	theMatcher["Heap","!Oscus"]="defeated  Oscus";
	theMatcher["Heap","!bossloss"]="deafeted by  Oscus";
	theMatcher["Heap","Trashcanos"]="trashcano eruption";
	theMatcher["Heap","Buried<br>Treasure"]="buried treasure";
	theMatcher["Heap","Sent<br>Compost"]="Burial Ground";

	theMatcher["AHBG",".gmatcher"]="Ground";
	theMatcher["AHBG",".place"]="7";
	theMatcher["AHBG",".image"]="http://images.kingdomofloathing.com/adventureimages/zombo.gif";
	theMatcher["AHBG","&nbsp;Spooky Hobo"]="defeated  Spooky hobo";
	theMatcher["AHBG","Defeats"]="defeated by  Spooky";
	theMatcher["AHBG","!Zombo"]="defeated  Zombo";
	theMatcher["AHBG","!bossloss"]="defeated by  Zombo";
	theMatcher["AHBG","Sent Flowers"]="flower";
	theMatcher["AHBG","Raided Tombs"]="raided";
	theMatcher["AHBG","Watched<br>Dancers"]="zombie hobos dance";
	theMatcher["AHBG","Failed to<br>Impress"]="failed to impress";
	theMatcher["AHBG","Busted<br>Moves"]="busted";

	theMatcher["PLD",".gmatcher"]="District";
	theMatcher["PLD",".place"]="8";
	theMatcher["PLD",".image"]="http://images.kingdomofloathing.com/adventureimages/chester.gif";
	theMatcher["PLD","&nbsp;Sleaze Hobo"]="defeated  Sleaze hobo";
	theMatcher["PLD","Defeats"]="defeated by  Sleaze";
	theMatcher["PLD","!Chester"]="defeated  Chester";
	theMatcher["PLD","!bossloss"]="defeated by  Chester";
	theMatcher["PLD","Raided<br>Dumstpers"]="dumpster";
	theMatcher["PLD","Sent Trash"]="sent some trash";
	theMatcher["PLD","Bamboozled"]="bamboozled";
	theMatcher["PLD","Flimflammed"]="flimflammed";
	theMatcher["PLD","Danced"]="danced like a superstar";
	theMatcher["PLD","Barfights"]="barfight";
	//TODO: add uncle hobo

	//Slimetube
	theMatcher["Slime",".image"]="http://images.kingdomofloathing.com/adventureimages/motherslime.gif";
	theMatcher["Slime","Slimes"]="defeated a";
	theMatcher["Slime","Defeats"]="defeated by a Slime";
	theMatcher["Slime","!Mother Slime"]="defeated  Mother Slime";
	theMatcher["Slime","!bossloss"]="defeated by  Mother";
	theMatcher["Slime","Tickled"]="tickled";
	theMatcher["Slime","Squeezed"]="squeezed";

	//Haunted House
	theMatcher["Haunted",".image"]="http://images.kingdomofloathing.com/adventureimages/necbromancer.gif";
	theMatcher["Haunted","Defeats"]="was defeated by";
	theMatcher["Haunted","&nbsp;Wolves"]="defeated  sexy sorority werewolf";
	theMatcher["Haunted","&nbsp;Zombies"]="defeated  sexy sorority zombie";
	theMatcher["Haunted","&nbsp;Ghosts"]="defeated  sexy sorority ghost";
	theMatcher["Haunted","&nbsp;Vamps"]="defeated  sexy sorority vampire";
	theMatcher["Haunted","&nbsp;Skeletons"]="defeated  sexy sorority skeleton";
	theMatcher["Haunted","!Wolves"]="took care of some werewolves";
	theMatcher["Haunted","!Ghosts"]="trapped some ghosts";
	theMatcher["Haunted","!Zombies"]="took out some zombies";
	theMatcher["Haunted","!Skeletons"]="took out some skeletons";
	theMatcher["Haunted","!Vamps"]="slew some vamp";
	theMatcher["Haunted","!NoiseUp"]="(?:cranked up the spooky noise|noiseon)";
	theMatcher["Haunted","!NoiseDown"]="(?:turned down the spooky noise|noiseoff)";
	theMatcher["Haunted","!DarkUp"]="(?:closed some windows|darkup)";
	theMatcher["Haunted","!DarkDown"]="(?:opened up some windows|darkdown)";
	theMatcher["Haunted","!FogUp"]="(?:turned up the fog|fogup)";
	theMatcher["Haunted","!FogDown"]="(?:turned down the fog|fogdown)";
	theMatcher["Haunted","!Mirrors"]="(?:snagged a funhouse|gotmirror)";
	theMatcher["Haunted","!Bullet"]="(?:made a silver shotgun|madeshell)";
	theMatcher["Haunted","!Chainsaw"]="(?:grabbed a chain|gotchain)";
	theMatcher["Haunted","!Trap"]="(?:snagged a ghost|gottrap)";
	theMatcher["Haunted","!Guides"]="(?:picked up some staff|gotmaps)";
	theMatcher["Haunted","!Costume"]="(?:grabbed a sexy|gotcostume)";
	theMatcher["Haunted","!Necbromancer"]="defeated  The Necbromancer";
	theMatcher["Haunted","!bossloss"]="defeated by  The Necbromancer";


	//End Consts
 loadOptions(options,FF);
 if(__FILE__!="clan_raidlogs.ash"){
  matcher m=create_matcher("a href=\"clan_raidlogs\\.php\\?viewlog=",page);
  page=m.replace_all("a href=\""+__FILE__+"?viewlog=");
  //replace all viewlog links in page
 }
 if(FF contains "viewlog"){
  runType=0;
 }
 if(FF contains "lootman"){
  lootManager(page);
  return;
 }
 if(FF contains "changeOpts"){
  logOptions();
  return;
 }
 getData(runType, page, data,theMatcher, players, activeComment);
 pageHeader(page);
 formatData(clearID, options, odata, theMatcher,runType,data, players, activeComment);
 pageFooter(page);
}

void main()
{
	clan_raidlogs_relay();
}