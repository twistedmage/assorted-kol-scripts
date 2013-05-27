//Sandwormfarmer v 1.1 by Halfvoid:
//This script will use all drum machines in your inventory to farm sandworms.

int start = my_meat();
int startspice = item_amount($item[ spices ]);
int startmel = item_amount($item[ spice melange ]);

while ( item_amount( $item[ drum machine ]) > 0 && my_adventures() > 0 )
   {
use (1, $item[ drum machine ]);
run_combat();
   }

int changemeat = my_meat() - start;
int changespice = item_amount($item[ spices ]) - startspice;
int changemel = item_amount($item[ spice melange ]) - startmel;

print("Meat change: " + changemeat + " | Spice gained: " + changespice + " | Melange gained: " + changemel);

