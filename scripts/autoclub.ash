#/******************************************************************************
#                        AutoClub 1.3 by Zarqon
#*******************************************************************************
#
#   this is not an organization for people who like cars
#   this is an AUTOMATIC SEAL-CLUBBING utility
#
#   Have a suggestion to improve this script?  Visit
#   http://kolmafia.us/showthread.php?t=2918
#
#   Want to say thanks?  Send me a bat! (Or bat-related item)
#
#******************************************************************************/
script "autoclub.ash";
import "zlib.ash"
import <canadv.ash>

record seal_item {
   item figurine;     // which figurine you need
   location wheir;    // location to obtain the figurine ("none" for Smacketeria/hermit)
   int safemox;       // safemox for fighting summoned seal
};
seal_item[item] seals;
file_to_map("seals.txt",seals);
if (count(seals) == 0) vprint("Problem loading seals.txt -- probably it doesn't exist.",0);
int summons = 5 + to_int(have_item($item[claw of the infernal seal]) > 0)*5;

boolean hunt_seal(item to_hunt) {
   int sflag = item_amount(to_hunt);
   if (my_defstat() + to_int(vars["threshold"]) < seals[to_hunt].safemox)
      return vprint("You need "+(seals[to_hunt].safemox - my_defstat() - to_int(vars["threshold"]))+" more defense stat to attempt clubbing this seal.  (He's a mean sucker.)",-2);
   if (get_property("_sealsSummoned").to_int() >= summons) return vprint("Sadly, you have reached your seal-summoning limit for today.",-2);
   boolean get_figurine(seal_item s) {
      print("Getting a "+s.figurine+"...");
      if (retrieve_item(1,s.figurine)) return vprint("You have a "+s.figurine+" now.",4);
      if (s.figurine == $item[depleted uranium seal figurine]) return vprint("Get a depleted uranium figurine before trying to use it.",-2);
      if (s.figurine == $item[figurine of an ancient seal]) {
         hermit(1,$item[figurine of an ancient seal]);
         return (item_amount($item[figurine of an ancient seal]) > 0);
      }
      if (s.wheir != $location[none] && can_adv(s.wheir,true)) return obtain(1,s.figurine,s.wheir);
      return false;
   }
   boolean get_candles(seal_item s) {
      vprint("Getting necessary candles...",2);
      if (s.figurine == $item[figurine of an armored seal]) return retrieve_item(10,$item[seal-blubber candle]);
      if (s.wheir == $location[none] && s.figurine != $item[depleted uranium seal figurine]) return retrieve_item(5,$item[seal-blubber candle]);
      if (item_amount($item[imbued seal-blubber candle]) > 0) return true;
      vprint("Getting an imbued candle...",2);
      if (item_amount($item[powdered sealbone]) == 0) hunt_seal($item[powdered sealbone]);
      if (retrieve_item(1,$item[seal-blubber candle]) && create(1,$item[imbued seal-blubber candle])) {}
      return (item_amount($item[imbued seal-blubber candle]) > 0);
   }
   if (get_figurine(seals[to_hunt]) && get_candles(seals[to_hunt])) {
      auto_mcd(seals[to_hunt].safemox);
      if (to_familiar(vars["is_100_run"]) != $familiar[none] && my_familiar() != to_familiar(vars["is_100_run"]))
         use_familiar(to_familiar(vars["is_100_run"]));
      use(1,seals[to_hunt].figurine);
   }
   return (item_amount(to_hunt) > sflag);
}

check_version("AutoClub","autoclub","1.3",2918);
void main(item desired) {      // just specify the item you want to club for
   if (my_class() != $class[seal clubber]) vprint("Silly "+my_class()+", clubbing seals is for Seal Clubbers.",0);
   cli_execute("maximize muscle, type club, -ml");
   if (item_type(equipped_item($slot[weapon])) != "club") vprint("That's not a club. I've seen a club and that isn't it.",0);
   vprint("Seal-summons remaining today: "+(summons - to_int(get_property("_sealsSummoned"))),3);
   if (!(seals contains desired)) {
      if (desired != $item[none]) vprint("You cannot acquire a "+desired+" by clubbing seals, much as we wish it were possible.",-2);
      vprint("Valid items to go clubbing for (with safemox):",1);
      foreach doodad,rec in seals if (my_defstat() + to_int(vars["threshold"]) >= rec.safemox) vprint("* "+doodad+" ("+rec.safemox+") - "+item_amount(doodad),1);
      return;
   }
   if (hunt_seal(desired)) vprint("Seal successfully clubbed!","blue",2);
    else vprint("Seal insufficiently clubbed.",2);
}
