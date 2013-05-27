int counter=1;

void check_drink(string cons_list, string drinkname)
{
	if(!contains_text(cons_list,">"+drinkname+"</a>"))
	{
		print(counter+": "+drinkname);
		counter=counter+1;
	}
}

void main()
{
	//read consumption
	string cons_list = visit_url("showconsumption.php");

	check_drink(cons_list,"Zoodriver");
	check_drink(cons_list,"Sloe Comfortable Zoo");
	check_drink(cons_list,"Sloe Comfortable Zoo on Fire");
	check_drink(cons_list,"Grasshopper");
	check_drink(cons_list,"Locust");
	check_drink(cons_list,"Plague of Locusts");
	check_drink(cons_list,"Dark & Starry");
	check_drink(cons_list,"Black Hole");
	check_drink(cons_list,"Event Horizon");
	check_drink(cons_list,"Lollipop Drop");
	check_drink(cons_list,"Candy Alexander");
	check_drink(cons_list,"Candicaine");
	check_drink(cons_list,"Red Dwarf");
	check_drink(cons_list,"Golden Mean");
	check_drink(cons_list,"Green Giant");
	check_drink(cons_list,"Suffering Sinner");
	check_drink(cons_list,"Suppurating Sinner");
	check_drink(cons_list,"Sizzling Sinner");
	check_drink(cons_list,"Firewater");
	check_drink(cons_list,"Earth and Firewater");
	check_drink(cons_list,"Earth, Wind and Firewater");
	check_drink(cons_list,"Caipiranha");
	check_drink(cons_list,"Flying Caipiranha");
	check_drink(cons_list,"Flaming Caipiranha");
	check_drink(cons_list,"Buttery Knob");
	check_drink(cons_list,"Slippery Knob");
	check_drink(cons_list,"Flaming Knob");
	check_drink(cons_list,"Fauna Libre");
	check_drink(cons_list,"Chakra Libre");
	check_drink(cons_list,"Aura Libre");
	check_drink(cons_list,"Mohobo");
	check_drink(cons_list,"Moonshine Mohobo");
	check_drink(cons_list,"Flaming Mohobo");
	check_drink(cons_list,"Great Old Fashioned");
	check_drink(cons_list,"Fuzzy Tentacle");
	check_drink(cons_list,"Crazymaker");
	check_drink(cons_list,"Humanitini");
	check_drink(cons_list,"More Humanitini than Humanitini");
	check_drink(cons_list,"Oh, the Humanitini");
	check_drink(cons_list,"Punchplanter");
	check_drink(cons_list,"Doublepunchplanter");
	check_drink(cons_list,"Haymaker");
	check_drink(cons_list,"Cement Mixer");
	check_drink(cons_list,"Jackhammer");
	check_drink(cons_list,"Dump Truck");
	check_drink(cons_list,"Sazerorc");
	check_drink(cons_list,"Sazuruk-hai");
	check_drink(cons_list,"Flaming Sazerorc");
	check_drink(cons_list,"Herring Daiquiri");
	check_drink(cons_list,"Herring Wallbanger");
	check_drink(cons_list,"Herringtini");
	check_drink(cons_list,"Aye Aye");
	check_drink(cons_list,"Aye Aye, Captain");
	check_drink(cons_list,"Aye Aye, Tooth Tooth");
	check_drink(cons_list,"Green Velvet");
	check_drink(cons_list,"Green Muslin");
	check_drink(cons_list,"Green Burlap");
	check_drink(cons_list,"Slimosa");
	check_drink(cons_list,"Extra-slimy Slimosa");
	check_drink(cons_list,"Slimebite");
	check_drink(cons_list,"Drunken Philosopher");
	check_drink(cons_list,"Drunken Neurologist");
	check_drink(cons_list,"Drunken Astrophysicist");
	check_drink(cons_list,"Drac & Tan");
	check_drink(cons_list,"Transylvania Sling");
	check_drink(cons_list,"Shot of the Living Dead");

}