import bumcheekascend
void main()
{
	if (get_property("sidequestLighthouseCompleted") != "none") return;
	print("BCC: doSideQuest(Beach)", "purple");
	bumUse(4, $item[reodorant]);
	while (i_a("barrel of gunpowder") < 5) {
		print("Getting gunpowder","lime");
		//SIMON ADDED 2 LINES BELOW
//					while(i_a("barrel of gunpowder") < 5 && available_amount($item[Rain-Doh box full of monster])>0 && my_adventures()>0)
//						use(1,$item[Rain-Doh box full of monster]);
		if (i_a("Rain-Doh black box") + i_a("spooky putty mitre") + i_a("spooky putty leotard") + i_a("spooky putty ball") + i_a("spooky putty sheet") + i_a("spooky putty snake") > 0) {
			//SIMON MODIFIED LINES BELOW
//						abort("BCC: You have some putty method, but the script doesn't support puttying at the beach, so we aborted to save you a bunch of turns. Do the beach manually.");
		}
		if(have_effect($effect[silent running])<1)
			cli_execute("uneffect silent running");
		bumAdv($location[Wartime Sonofa Beach], "", "", "5 barrel of gunpowder", "Getting the Barrels of Gunpowder", "+");
//					//SIMON CHANGED
//					if(i_a("barrel of gunpowder") < 5)
//					{
//						setMood("+");

			//place florist friar plants
//						choose_all_plants("", $location[wartime sonofa beach]);
			
//						v(1, $location[Wartime Sonofa Beach]);
//					}
	}
	cli_execute("outfit "+bcasc_warOutfit);
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
	visit_url("bigisland.php?place=lighthouse&action=pyro&pwd=");
	if (get_property("sidequestLighthouseCompleted") != "none")
		return;
	else
		abort("Failed");
}