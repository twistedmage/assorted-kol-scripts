/******************************************************************************
        Wikified Online Script Settings MANager (WOSSMAN) by Zarqon
*******************************************************************************

   - allows you to conveniently and easily edit your ZLib settings
   - displays and allows editing of documentation, loaded from Map Manager

   Have a suggestion to improve this script?  Visit
   http://kolmafia.us/showthread.php?t=2072

   Want to say thanks?  Send me a bat! (Or bat-related item)

******************************************************************************/
script "WOSSMAN.ash"
notify Zarqon;
import <zlib.ash>

int anim_ms = 300;  // how many milliseconds to make animations; set to 0 to prevent jerkiness
string openevent = "click";  // some possible events: mouseover, click, dblclick

// TODO:
// normalization masks for strings
// disable accordion when a form is being edited
// PROBABLY:
  // submission to PHP script for doc/scripts
  // PHP
     // accept type submissions from ZLib
     // accept doc / script submissions from relay_wossman.ash
  // ZLib
     // set data types when new settings are initialized

record{
   string type;    // setting type (for now, only simple types; later can be mask for normalizing settings)
   string doc;     // documentation
   string usage;   // scripts that access the variable
}[string] vardoc;
load_current_map("vars_documentation", vardoc);
buffer build;
string cup(string source) {  // cleanup: escape the quotes since to_json() doesn't
   return replace_string(source,"\"","\\\"");  //"
}

// first, handle posted data
string[string] post = form_fields();
if (count(post) > 0 && post contains "id" && post contains "value") {
   if (!(post contains "pwd") || post["pwd"] != my_hash()) { vprint("Mismatched pwd hash.  Maybe you've logged out since first loading this script.  Rerun the relay script.",-1); write("Error: mismatched hash."); exit; }
   if (post contains "docaction" && vars contains excise(post["id"],"---","")) {   // documentation data was changed for existing setting
      switch (excise(post["id"],"","---")) {
         case "type": if (!($strings[string,int,float,boolean,class,coinmaster,effect,element,familiar,item,location,monster,phylum,skill,slot,stat]
                         contains post["value"])) { write(vardoc[excise(post["id"],"---","")].type); exit; }
                      vardoc[excise(post["id"],"---","")].type = post["value"]; break;
         case "usage": vardoc[excise(post["id"],"---","")].usage = post["value"]; break;
         case "doc": vardoc[excise(post["id"],"---","")].doc = post["value"];
      }
      // add: update remote map
      if (map_to_file(vardoc,"vars_documentation.txt")) vprint("The "+excise(post["id"],"","---")+" for '"+excise(post["id"],"---","")+"' was changed.",5);
      write(entity_encode(post["value"]));
      exit;
   } else if (vars contains post["id"]) {         // form was submitted: edit and output ZLib setting
      string t = "string";
      if (vardoc contains post["id"]) t = vardoc[post["id"]].type;
      t = normalized(post["value"],t);
      if (vars[post["id"]] != t) {
         vars[post["id"]] = t;
         if (updatevars()) vprint("ZLib setting '"+post["id"]+"' changed to '"+t+"'.","purple",2);
      }
      build.append(t);
   } else if (post["id"] == "constants") {        // mafia datatype was clicked; generate and output JSON list
      vprint("Building list of "+post["value"]+"s...",6);
      string[string] bmap;
      if (post["value"] != "type") bmap["none"] = "none";
      switch (post["value"]) {
         case "class": foreach c in $classes[] bmap[cup(c)] = cup(c); break;
         case "coinmaster": foreach c in $coinmasters[] bmap[cup(c)] = cup(c); break;
         case "effect": foreach e in $effects[] bmap[cup(e)] = cup(e); break;
         case "element": foreach e in $elements[] bmap[cup(e)] = cup(e); break;
         case "familiar": foreach f in $familiars[] if (have_familiar(f)) bmap[cup(f)] = cup(f); break;
         case "item": foreach i in $items[] bmap[cup(i)] = cup(i); break;
         case "location": foreach l in $locations[] bmap[cup(l)] = cup(l); break;
         case "monster": foreach m in $monsters[] bmap[cup(m)] = cup(m); break;
         case "phylum": foreach p in $phyla[] bmap[cup(p)] = cup(p); break;
         case "skill": foreach s in $skills[] bmap[cup(s)] = cup(s); break;
         case "slot": foreach s in $slots[] bmap[cup(s)] = cup(s); break;
         case "stat": foreach s in $stats[] bmap[cup(s)] = cup(s); break;
         case "type": foreach tt in $strings[int,float,boolean,class,coinmaster,effect,element,familiar,item,location,monster,phylum,skill,slot,stat,string] bmap[tt] = tt;
      }
      build.append(to_json(bmap));
      vprint("...finished.",6);
   } else if (post["id"] == "delete" && vars contains post["value"] && post["value"] != "verbosity") {
      vprint("Deleting '"+post["value"]+"'...","purple",2);
      remove vars[post["value"]];
      if (updatevars()) vprint("...deleted.",2);
      build.append("success");
   }
   build.write();
   exit;
}

///////////////////// jQuery
// jeditable forms
 build.append("<html><head>\n");
 build.append("<link rel='stylesheet' type='text/css' href='/images/styles.20130904.css'/>\n");
 build.append("<script src=\"jquery1.10.1.min.js\"></script>\n<script src=\"jquery.jeditable.js\"></script>\n");
 build.append("<script type='text/javascript' charset='utf-8'>\n$(document).ready(function() {\n");
 build.append("  $('.edit_area').editable('relay_WOSSMAN.ash', {\n");
 build.append("   indicator : '<img src=\"indicator.gif\">', tooltip : 'Click to edit...', type : 'textarea', rows: '3', submit: 'Save', submitdata : {docaction: \"yes\", pwd: \""+my_hash()+"\"}\n");
 build.append("  });\n");
 build.append("  $('.editable_norm').editable('relay_WOSSMAN.ash', {\n");
 build.append("    indicator : '<img src=\"indicator.gif\">', tooltip : \"Click to edit...\", style : \"display: inline\", submitdata : {pwd: \""+my_hash()+"\"}\n");
 build.append("  });\n");
 build.append("  $('.editable_bool').editable('relay_WOSSMAN.ash', {\n");
 build.append("    indicator : '<img src=\"indicator.gif\">', tooltip : \"Click to edit...\", onblur : \"submit\", data : \"{'true':'true','false':'false'}\", type : \"select\", style : \"display: inline\", submitdata : {pwd: \""+my_hash()+"\"}\n");
 build.append("  });\n");
 foreach s in $strings[class,coinmaster,effect,element,familiar,item,location,monster,phylum,skill,stat,type] {
    build.append("  $('.editable_"+s+"').editable('relay_WOSSMAN.ash', {\n");
    build.append("    indicator : '<img src=\"indicator.gif\">', tooltip : \"Click to edit...\", onblur : \"submit\", loadurl : 'relay_WOSSMAN.ash?pwd="+my_hash()+"&id=constants&value="+s+"', type : \"select\", style : \"display: inline\"\n");
    build.append("   , submitdata : {docaction: \"yes\", pwd: \""+my_hash()+"\"}");
    build.append("  });\n");
 }
// delete
 build.append("  $('a.delete').click(function(e) {\n    e.preventDefault();\n    var parent = $(this).parent();\n    if (!confirm('Really delete setting \"' + $(this).attr('id').replace('delete--','') + '\"?')) return false;");
 build.append("    $.ajax({\n      type: 'post',\n      url: 'relay_WOSSMAN.ash',\n      data: 'pwd="+my_hash()+"&id=delete&value=' + $(this).attr('id').replace('delete--',''), ");
 build.append("      beforeSend: function() {\n        parent.animate({'backgroundColor':'#fb6c6c'},300);\n        parent.next().animate({'backgroundColor':'#fb6c6c'},300);");
 build.append("      },\n      success: function() {\n        parent.next().slideUp(300,function() {\n          parent.next().remove();\n        });");
 build.append("        parent.slideUp(300,function() {\n          parent.remove();\n        });\n      }\n    });\n  });");
// UI functions
 build.append("  function updatecount() { $('#showcount').text($('div.head:visible').length); }\n");
 build.append("  $('#candy').click(function() { $('.zz').hide(); $('span.zz').show(5000); });\n");
 build.append("  $('.unfoldable .head')."+openevent+"(function(event) {\n   $('div:animated').not($(this).next()).stop(true,true); if (!window.expand.checked) $(this).next().siblings('.docu').hide("+anim_ms+"); $(this).next().show("+anim_ms+"); \n      return false;\n   }).next().hide();\n");
 build.append("  $('#filterbox').keyup(function() {\n  $('div:animated').stop(true,true);  if (!window.expand.checked) $('div.docu').hide(); ");
 build.append("     $('div.head').not($('div.head[name*='+$(this).val().toLowerCase()+']')).hide("+anim_ms+",updatecount); if (window.expand.checked) $('div.head').not($('div.head[name*='+$(this).val().toLowerCase()+']')).next().hide("+anim_ms+",updatecount);\n");
 build.append("     $('div.head[name*='+$(this).val().toLowerCase()+']').show("+anim_ms+",updatecount); if (window.expand.checked) $('div.head[name*='+$(this).val().toLowerCase()+']').next().show("+anim_ms+",updatecount); \n      return false;\n   });\n");
 build.append("  $('#showall').change(function() {\n   if (window.expand.checked) $('div.docu').show("+anim_ms+"); else $('div.docu').hide("+anim_ms+"); \n      return false;\n   });\n");
/////////////////////// finish jQuery scripts
 build.append("});\n</script>\n");

// CSS
build.append("<style type=\"text/css\">.setting { float: left; clear: right; font-size: 0.8em; font-weight: bold; } div.docu { clear: both; padding: 6px; border: 1px #e0e0e0 solid; }");
build.append(".highlight:hover { background-color: #ffc; } div.head:hover { background-color: #eaeaea; } span.settingedit { margin-right: 3px; }\n");
build.append("div.head { clear: both; margin-top: 3px; padding: 1px 4px; background-color: #e0e0e0; text-align: right; } span.editable_type { color: #888; font-style: italic; }\n");
build.append("div.usage { float: right; margin: 1px 5px; padding: 5px; border: 1px #e0e0e0 solid; font-size: 0.7em; } #accord { margin-bottom: 50px; } ");
build.append("#opts { float: right; text-align: right; color: #eee; padding: 2px; } #title { font: italic bold 3.2em/0.55; margin-left: -5px; } ");
build.append("#topbar { background-color: #5a5a5a; color: white; font: 0.7em/1.5; padding: 4px; } ");
build.append("#fineprint { text-align: center; color: #aaa; font-size: 0.7em; }</style>");

// write page top
build.append("</head><body><div id='topbar'><div id='opts'><label for='showall'>Expand:</label><input type='checkbox' id='showall' name='expand'> <label for='filterbox'>Filter:</label><input type='text' id='filterbox'><br>Showing <span id='showcount' style='font-weight: bold'>"+count(vars)+"</span> settings.</div>");
build.append("<span id='title'>WOSSMAN</span> by <a href='showplayer.php?who=1406236' style='font: italic 0.9em; color: #66f;'>Zarqon</a><br>");
build.append("<div id='candy' style='letter-spacing: 3px; clear: left;'><b>W</b><span class='zz'>ikified </span><b>O</b><span class='zz'>nline </span><b>S</b><span class='zz'>cript </span><b>S</b><span class='zz'>ettings </span><b>MAN</b><span class='zz'>ager</span></div></div>");

// write the settings accordion
build.append("<div id='accord' class='unfoldable'>\n");

buffer get_input(string setting) {
   buffer res;
   switch (vardoc[setting].type) {
      case "string":
      case "int":
      case "float": res.append("<span class='highlight'><span class='editable_norm' id='"+setting+"'>"+normalized(vars[setting],vardoc[setting].type)+"</span></span>"); break;
      case "boolean": res.append("<span class='highlight'><span class='editable_bool' id='"+setting+"'>"+normalized(vars[setting],vardoc[setting].type)+"</span></span>"); break;
      default: res.append("<span class='highlight'><span class='editable_"+vardoc[setting].type+"' id='"+setting+"'>"+normalized(vars[setting],vardoc[setting].type)+"</span></span>"); break;
   }
   return res;
}

foreach setting in vars {
   if (!(vardoc contains setting)) {
      vardoc[setting].type = "string";
      vardoc[setting].doc = "Click to add documentation.";
      vardoc[setting].usage = "none";
   }
   build.append("<div class='head' name='"+to_lower_case(setting)+"'><div class='setting'><span class='highlight'><span class='editable_type' id='type---"+
      setting+"'>"+vardoc[setting].type+"</span></span> <b>"+setting+"</b></div><span class='settingedit'>"+get_input(setting)+"</span> <a href='#' class='delete' id='delete--"+
      setting+"'><img src='images/itemimages/pixcross.gif' height='15' width='15' title='Delete "+setting+"' border=0></a></div><div class='docu'><div class='usage'>"+
	  "<b>Scripts Using This Setting:</b><div class='highlight'><p class='edit_area' id='usage---"+setting+"'>"+vardoc[setting].usage+"</div></div> "+
	  "<div class='highlight'><span class='edit_area' id='doc---"+setting+"'>"+vardoc[setting].doc+"</span></div></div>\n");
}

// finish up and output page
build.append("</div><p><div id='fineprint'><a href='sendmessage.php?toid=1406236' title='Find this useful? Send me a batbit!' target='_blank'><img src='images/adventureimages/stabbats.gif' border=0 height=60 width=60></a><br>");
build.append("Questions? Ask them <a href='http://kolmafia.us/showthread.php?t=2072' target='_blank'>here</a>. But first, <a href='http://kolmafia.us/showpost.php?p=15167&postcount=20' target='_blank'>read more</a> about script settings.</div></body></html>");
map_to_file(vardoc,"vars_documentation.txt");
write(build);