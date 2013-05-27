void Leafquest()
{
	council();
	cli_execute("leaflet stats");

	if (available_amount($item[Frobozz Real-Estate Company Instant House (TM)]) > 0)
	{
		use(1, $item[Frobozz Real-Estate Company Instant House (TM)]);
	}
}

void main()
{
	Leafquest();
}
