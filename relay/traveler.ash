void traveler_relay() {
	print("traveler_relay called","blue");
	string input = visit_url();

	string gen_from = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
	string gen_to = "NOPQRSTUVWXYZABCDEFGHIJKLMnopqrstuvwxyzabcdefghijklm";
	
	string char_rot13(string c) {
		int at = index_of(gen_from, c);
		if (at == -1)
			return c;
		return substring(gen_to, at, at+ 1);
	}
	
	matcher m = create_matcher("and says \&quot\;([^\;]*)\&quot\;", input);
	if (find(m)) {
		string msg_i = group(m, 1);
		string msg_o = "";
		int i = 0;
		while(i < length(msg_i)) {
			msg_o = msg_o + char_rot13(substring(msg_i, i, i + 1));
			i = i + 1;
		}
		write(replace_string(input, "understand the following:", "understand he said: " + msg_o));
	} else {
		write(input);
	}
}

void main()
{
	traveler_relay();
}