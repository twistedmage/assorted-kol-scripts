int count=0;
string send_string;

foreach it in $items[]
{
	if(is_tradeable(it) && item_amount(it) > 0)
	{
		if(item_amount(it) > 0)
		{
			if(count==0)
			{
				send_string = "csend * "+it;
				print(send_string,"blue");
				count=count+1;
			}
			else if(count<10)
			{
				send_string = send_string + ", * "+it;
				print(send_string,"blue");
				count=count+1;
			}
			else
			{
				send_string = send_string + ", * "+it+" to twistedmage";
				print(send_string,"green");
				cli_execute(send_string);
				count=0;
			}
		}
	}
}
if(count!=0)
{
	send_string = send_string + " to twistedmage";
	print(send_string,"green");
	cli_execute(send_string);
}
wait(10);
cli_execute("exit");