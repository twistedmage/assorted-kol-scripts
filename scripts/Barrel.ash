void Barrel( int VarBarrel)
{
 if( my_adventures() <= 0)
 {
  cli_execute( "abort No adventures left.");
 }
 if( my_hp() <= 0)
 {
//Or put what you use for a HP restore thing...
	cli_execute("Universal_recovery.ash");
//  cli_execute( "abort No HP");
 }
 if( VarBarrel > 36 || VarBarrel < 1)
 {
  cli_execute( "abort Not a valid barrel.");
 }
 if( my_adventures() > 0 && my_hp() > 0 && VarBarrel <= 36 && VarBarrel >= 1)
 {
  cli_execute("barrel.php?smash="+int_to_string(VarBarrel)+"&pwd");
  string catch=run_combat();
 }
}

void main()
{
 int Counter;
 Counter = 1;
 while( Counter <= 36)
 {
  Barrel( Counter);
  Counter = Counter + 1;
 }
}

//try top left barrel