import <QuestLib.ash>;
import <Spookyraven.ash>;

void UnlockGallery()
{
	UnlockSpookyraven();

	if (available_amount($item[Spookyraven gallery key]) > 0 )
	{
		print("You have already unlocked the Haunted Gallery.");
		return;
	}
	dress_for_fighting();

	set_library_choices();

	while (get_property("lastGalleryUnlock").to_int() != g_knownAscensions && my_adventures()>0)
	{

		cli_execute("conditions clear");
		adventure(request_noncombat(1), $location[Haunted Library]); 
	}

	while (available_amount($item[Spookyraven gallery key]) == 0 && my_adventures()>0)
	{
		cli_execute("conditions clear");
		adventure(request_noncombat(1), $location[Haunted Conservatory]);
	}
}

void main()
{
	UnlockGallery();
}
