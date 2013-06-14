void item_turnin(item i)
{
	sell(i.buyer, item_amount(i), i);
}

void main()
{
	item_turnin($item[red class ring]);
	item_turnin($item[blue class ring]);
	item_turnin($item[white class ring]);
	item_turnin($item[beer helmet]);
	item_turnin($item[distressed denim pants]);
	item_turnin($item[bejeweled pledge pin]);
	item_turnin($item[PADL Phone]);
	item_turnin($item[kick-ass kicks]);
	item_turnin($item[perforated battle paddle]);
	item_turnin($item[bottle opener belt buckle]);
	item_turnin($item[keg shield]);
	item_turnin($item[giant foam finger]);
	item_turnin($item[war tongs]);
	item_turnin($item[energy drink IV]);
	item_turnin($item[Elmley shades]);
	item_turnin($item[beer bong]);
	//buy($coinmaster[Dimemaster], $coinmaster[dimemaster].available_tokens/2, $item[filthy poultice]);
	buy($coinmaster[Dimemaster], $coinmaster[dimemaster].available_tokens/5, $item[seashell necklace]);
	autosell(item_amount($item[seashell necklace]),$item[seashell necklace]);
}