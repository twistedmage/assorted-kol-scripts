item RED = $item[vial of red slime];
item YELLOW = $item[vial of yellow slime];
item BLUE = $item[vial of blue slime];
item ORANGE = $item[vial of orange slime];
item GREEN = $item[vial of green slime];
item VIOLET = $item[vial of violet slime];
item VERMILION = $item[vial of vermilion slime];
item AMBER = $item[vial of amber slime];
item CHARTREUSE = $item[vial of chartreuse slime];
item TEAL = $item[vial of teal slime];
item INDIGO = $item[vial of indigo slime];
item PURPLE = $item[vial of purple slime];
item BROWN = $item[vial of brown slime];

int[item] inv;

inv[RED] = item_amount( $item[vial of red slime] );
if ( inv[RED] < 9 )
{
	abort( "You need at least 9 vials of red slime" );
}

inv[BLUE] = item_amount( $item[vial of blue slime] );
if ( inv[BLUE] < 9 )
{
	abort( "You need at least 9 vials of blue slime" );
}

inv[YELLOW] = item_amount( $item[vial of yellow slime] );
if ( inv[YELLOW] < 9 )
{
	abort( "You need at least 9 vials of yellow slime" );
}

int cooks = 0;

void mix(int qty, item res, item a, item b)
{
	inv[a] = inv[a] - qty;
	if (inv[a] < 0) abort(inv[a] + " " + a);
	inv[b] = inv[b] - qty;
	if (inv[b] < 0) abort(inv[b] + " " + b);
	inv[res] = inv[res] + qty;
	print( (cooks + 1) + ") Cook " + qty + " " + a + " with " + qty + " " + b );
	cooks = cooks + qty;
	craft( "cook", qty, a, b );
}

mix(3, ORANGE, RED, YELLOW);
mix(3, GREEN, YELLOW, BLUE);
mix(3, VIOLET, RED, BLUE);

mix(1, VERMILION, RED, ORANGE);
mix(1, AMBER, YELLOW, ORANGE);
mix(1, CHARTREUSE, YELLOW, GREEN);
mix(1, TEAL, BLUE, GREEN);
mix(1, PURPLE, RED, VIOLET);
mix(1, INDIGO, BLUE, VIOLET);

print( "" );
print( "Currently in inventory after " + cooks + " cooks:" );
foreach it, qty in inv
{
	if ( qty > 0 )
	{
		print(qty + " " + it);
	}
}
