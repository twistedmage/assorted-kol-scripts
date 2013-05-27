import <questlib.ash>;

void citadelquest()
{
	dress_for_fighting();
	print("Doing White citadel quest");
	if(contains_text(visit_url("questlog.php?which=1&pwd"),"bringing back a delicious meal from the legendary White Citadel"))
	{
		print("Adventuring in whiteys grove");
		//if we are at the first stage, go to whiteys grove, it will auto stop when we open next area
		adventure(my_adventures(),$location[Whitey's Grove]);
	}
	if((!contains_text(visit_url("questlog.php?which=1&pwd"),"carryout order")) && (!contains_text(visit_url("questlog.php?which=1&pwd"),"Satisfaction Satchel")))
	{
		print("Adventuring in the road to the white citadel");
		while(available_amount($item[hobo code binder])!=0 && !contains_text(visit_url("questlog.php?which=5"),"The Road to White Citadel")&& my_adventures()>0)
		{
			set_property("battleAction","try to run away");
			cli_execute("maximize moxie, equip hobo code binder");
			adventure(1,$location[White Citadel]);
		}
		set_property("battleAction","custom combat script");
		//now go to the road to the white citadel, it will auto stop when opened
		adventure(my_adventures(),$location[White Citadel]);
	}
	print("Buying meal");
	//assume has the 300 meat
	visit_url("store.php?whichstore=w&pwd");
	//hand in
	print("Handing in");
	visit_url("guild.php?place=paco&pwd");
}

void prep()
{
	//if completed, skip
	if(contains_text(visit_url("questlog.php?which=2&pwd"),"White Citadel"))
	{
		print("White citadel already completed");
	}
	else if(!contains_text(visit_url("questlog.php?which=1&pwd"),"White Citadel"))
	{
		//if not accepted or completed accept then do
		print("Accepting White citadel quest");
		visit_url("guild.php?place=paco&pwd");
		citadelquest();
	}
	else
	{
		//it's already accepted but not done
		citadelquest();
	}
}


void main()
{
	prep();
}