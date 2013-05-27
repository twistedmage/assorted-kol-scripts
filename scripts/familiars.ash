// version 1

familiar[int] allfamiliars;
familiar[int] collectedfamiliars;
familiar[int] missingfamiliars;

file_to_map("familiars.txt",allfamiliars);

foreach i in allfamiliars{
	familiar f = allfamiliars[i];
	if(f!=$familiar[none]){
		if(have_familiar(f)){
			collectedfamiliars[i]=f;
		} else {
			missingfamiliars[i]=f;	
		}
	}
}


Print("You have collected " + count(collectedfamiliars) + " of " + count(allfamiliars) + " familiars","green");
print("");

foreach i in collectedfamiliars{
	print(collectedfamiliars[i],"green");
}


print("");
Print("You are missing " + count(missingfamiliars) + " of " + count(allfamiliars) + " familiars","red");
print("");

foreach i in missingfamiliars{
	print(missingfamiliars[i],"red");
}