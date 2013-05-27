// betweenBattleMood v1.1

script "betweenBattleMood.ash";
import <zlib.ash>

int manaBurningThreshold() {
	print("mp threshold="+my_maxmp() * to_float(get_property("manaBurningThreshold")),"olive");
	return my_maxmp() * to_float(get_property("manaBurningThreshold"));
}

// Burn off mana with all librams equally.
void librams() {
	print("burning mana on librams","olive");
	skill [int] libram;
	int [int] times;
	// Make sure that the character actually has the skills in question.
//	foreach key in $skills[Summon Candy Heart, Summon Party Favor, Summon Love Song, Summon BRICKOs, summon dice, summon resolutions]
	if(can_interact())
	{
		if(have_skill($skill[summon dice]))
			libram[count(libram)] = $skill[summon dice];
	}
	else
	{
		//stick in a bricko if we don't have 3 bats
		if(have_skill($skill[summon brickos]) && available_amount($item[bricko bat])<3 &&(available_amount($item[bricko eye brick])<3 || available_amount($item[bricko brick])<15))
			libram[count(libram)] = $skill[summon brickos];
		//2 divines per candy heart and resolution
		foreach key in $skills[summon party favor,summon candy heart,summon resolutions,summon party favor]
			if(have_skill(key))
				libram[count(libram)] = key;
	}
	if(count(libram)<1) // No valid librams were found
	{
		print("No librams found");
		return;
	}
	// Burn down to 90% of mana burning threshold
	int min_mp = ceil(manaBurningThreshold() *.9 );
	// start summoning!!
	int mptotal = mp_cost($skill[Summon Candy Heart]);
	if(my_mp() - mptotal > min_mp) {
		int x = square_root(8 * mp_cost($skill[Summon Candy Heart]) -7)/2 + 0.5;
		int y;
		while(my_mp() - mptotal > min_mp) {
			y = x % count(libram);
			times[y] = times[y] + 1;
			x = x +1;
			mptotal = mptotal + x * (x - 1) /2 +1;
		}
		foreach key in libram
			if(times[key] > 0)
			{
				print("casting "+libram[key]+" x"+times[key]);
				use_skill(times[key], libram[key]);
			}
	}
}

// Burn off mana by summoning cocktailcrafting, noodles and reagents. This will only summon up to one of each.
void summon_yummy() {
	print("burning mana on yummies","olive");
	if(my_mp() < manaBurningThreshold() *.9 + mp_cost($skill[Pastamastery]))
		return;
	int left;
	foreach key in $skills[Advanced Cocktailcrafting, Advanced Saucecrafting, Pastamastery, request sandwich, lunch break]
		if(have_skill(key)) {
			switch(key) {
			case $skill[Advanced Cocktailcrafting]:
				left =  have_skill($skill[Superhuman Cocktailcrafting]).to_int() * 2 +3 - get_property("cocktailSummons").to_int();
				break;
			case $skill[Advanced Saucecrafting]:
				left =  have_skill($skill[The Way of Sauce]).to_int() * 2 +3 - get_property("reagentSummons").to_int();
				break;
			case $skill[Pastamastery]:
				left =  have_skill($skill[Transcendental Noodlecraft]).to_int() * 2 +3 - get_property("noodleSummons").to_int();
				break;
			case $skill[request sandwich]:
				left =  1-get_property("_requestSandwichSucceeded").to_int();
				break;
			case $skill[lunch break]:
				left =  1-get_property("_lunchBreak").to_int();
				break;
			}
			while(left > 0) {
				print("Making a yummy: "+key,"olive");
				use_skill(1, key);
				left=left-1;
				if(my_mp() < manaBurningThreshold() *.9 + mp_cost(key))
					return;
			}
		}
}
void summon_yummy2() {
	print("burning mana on yummies","olive");
	if(my_mp() < manaBurningThreshold() *.9 + mp_cost($skill[Pastamastery]))
		return;
	record summoning {
		skill it;
		int today;
		int max;
	};
	summoning [int] yummy;
	int x;
	foreach key in $skills[Advanced Cocktailcrafting, Advanced Saucecrafting, Pastamastery]
		if(have_skill(key)) {
			x = count(yummy);
			yummy[x].it = key;
			switch(key) {
			case $skill[Advanced Cocktailcrafting]:
				yummy[x].today = get_property("cocktailSummons").to_int();
				yummy[x].max =  have_skill($skill[Superhuman Cocktailcrafting]).to_int() * 2 +3;
				break;
			case $skill[Advanced Saucecrafting]:
				yummy[x].today = get_property("reagentSummons").to_int();
				yummy[x].max =  have_skill($skill[The Way of Sauce]).to_int() * 2 +3;
				break;
			case $skill[Pastamastery]:
				yummy[x].today = get_property("noodleSummons").to_int();
				yummy[x].max =  have_skill($skill[Transcendental Noodlecraft]).to_int() * 2 +3;
			}
		}
	if(count(yummy) < 1)
		return;
	while(my_mp() < manaBurningThreshold() *.9 + mp_cost($skill[Pastamastery])) {
		sort yummy by yummy[index].today;
		for i from 0 to count(yummy)-1 {
			if(yummy[i].today < yummy[i].max) {
				use_skill(1, yummy[i].it);
				yummy[i].today = yummy[i].today+1;
				break;
			}
			if(i == count(yummy)-1 && yummy[i].today >= yummy[i].max)
				return;
		}
	}
}



void main() {
	// Burn off mana with librams out of ronin, or summon food goodies if in ronin/hardcore.
	// Burning mana for these things takes preference over regular mana burning and that's good.
	if(can_interact()) {
		librams();
	} else summon_yummy();
	print("Finished betweenBattleMood","olive");
}
