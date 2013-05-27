#/*****************************************************************************#
#                          SafeGuide 1.3 by Zarqon                             #
#       Lists the most level-appropriate locations for you to adventure,       #
#                      to the best of mafia's knowledge                        #
#*****************************************************************************/#
import <zlib.ash>
string this_version = "1.3"; string[int] d;

int scope = 5;               // How many locations to list on each side

void add_loc(location wear) {
   int nsm = get_safemox(wear);
   if (nsm == 0) return;
   if (d contains nsm) d[nsm] = d[nsm]+", "+wear;
   else d[nsm] = to_string(wear);
}

buffer report(int index, int range) {
   int counter = 0;
   int i = index;
   buffer out;
   out.append("<p align=left><table cellpadding=7 width=500><tr>"+
              "<td align=left valign=top><p><b>--== Nearest Risks ==--</b><p><span style=\"color:#999900\">");
   while (counter < range && i < 400) {
      if (d contains i) {
         out.append(i+" :: "+d[i]+"<br>");
         counter = counter + 1;
      }
      i = i + 1;
   }
   if (counter == 0) out.append("<span style=\"color:#909090\">(All safe.)</span>");
   counter = 0;
   i = index;
   out.append("</span></td><td valign=middle bgcolor=#eeeeee><p align=center><small>SAFE<br>LIMIT<br>"+index+
              "</small></td><td align=left valign=top><p><b>--== Nearest Havens ==--</b><p><span style=\"color:#00aa00\">");
   while (counter < range && i > 0) {
      if (d contains i) {
         out.append(i+" :: "+d[i]+"<br>");
         counter = counter + 1;
      }
      i = i - 1;
   }
   if (counter == 0) out.append("<span style=\"color:#909090\">(All unsafe.)</span>");
   out.append("</td></tr></table><p align=left>");
   return out;
}

void main() {
   check_version("SafeGuide","safe",this_version,1533);
   print("Checking locations...");
   location place;
   for i from 1 to 400 {
      place = to_location(i);
      if (place != $location[none]) add_loc(place);
   }
   print_html(report(my_buffedstat($stat[moxie])+to_int(vars["threshold"]), scope));
}