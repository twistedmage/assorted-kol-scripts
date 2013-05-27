//Lava.ash is a solver for the Volcano Maze part of the Nemesis quest ("A Volcanic Cave").
//Credits:
//CptJesus - putting all of the routes into maps and calling them
//RoyalTonberry - producing the layouts and routes for the six maze types
//Veracity - making our visit_url()s actually work

//Many thanks for all who assisted and thanks to anyone willing to test this in different maze types

/////////////////////////////////////////////////////////////////////////////////////////////
//USAGE
//You must be at the beginning of the maze
//We confirm this with you, and the maze checks it for you. We do not take responsibility
//for you trying to use this when not at the beginning of the maze. We do our best.
//The script stops one platform from the end. Take the time to prepare for the Nemesis fight
/////////////////////////////////////////////////////////////////////////////////////////////

script "lava.ash";

string [int] maze1;
maze1[0] = "X";
maze1[1] = "O";
maze1[2] = "O";
maze1[3] = "O";
maze1[4] = "X";
maze1[5] = "O";
maze1[6] = "O";
maze1[7] = "X";
maze1[8] = "O";
maze1[9] = "X";
maze1[10] = "O";
maze1[11] = "O";
maze1[12] = "O";
string [int] maze2;
maze2[0] = "O";
maze2[1] = "O";
maze2[2] = "O";
maze2[3] = "X";
maze2[4] = "O";
maze2[5] = "X";
maze2[6] = "O";
maze2[7] = "O";
maze2[8] = "X";
maze2[9] = "O";
maze2[10] = "O";
maze2[11] = "O";
maze2[12] = "X";
string [int] maze3;
maze3[0] = "X";
maze3[1] = "O";
maze3[2] = "O";
maze3[3] = "X";
maze3[4] = "O";
maze3[5] = "O";
maze3[6] = "O";
maze3[7] = "O";
maze3[8] = "O";
maze3[9] = "O";
maze3[10] = "O";
maze3[11] = "O";
maze3[12] = "O";
string [int] maze4;
maze4[0] = "O";
maze4[1] = "O";
maze4[2] = "O";
maze4[3] = "O";
maze4[4] = "O";
maze4[5] = "O";
maze4[6] = "O";
maze4[7] = "O";
maze4[8] = "O";
maze4[9] = "X";
maze4[10] = "O";
maze4[11] = "O";
maze4[12] = "X";
string [int] maze5;
maze5[0] = "O";
maze5[1] = "O";
maze5[2] = "X";
maze5[3] = "O";
maze5[4] = "X";
maze5[5] = "O";
maze5[6] = "O";
maze5[7] = "X";
maze5[8] = "O";
maze5[9] = "X";
maze5[10] = "O";
maze5[11] = "O";
maze5[12] = "O";
string [int] maze6;
maze6[0] = "O";
maze6[1] = "O";
maze6[2] = "O";
maze6[3] = "X";
maze6[4] = "O";
maze6[5] = "X";
maze6[6] = "O";
maze6[7] = "O";
maze6[8] = "X";
maze6[9] = "O";
maze6[10] = "X";
maze6[11] = "O";
maze6[12] = "O";

record coordinate
{
	int x;
	int y;
};
coordinate [int] m1;
coordinate [int] m2;
coordinate [int] m3;
coordinate [int] m4;
coordinate [int] m5;
coordinate [int] m6;

int put( int m , int index , int xi , int yi )
{
	if( m == 1 )
	{
		m1[index].x = xi;
		m1[index].y = yi;
	}
	if( m == 2 )
	{
		m2[index].x = xi;
		m2[index].y = yi;
	}
	if( m == 3 )
	{
		m3[index].x = xi;
		m3[index].y = yi;
	}
	if( m == 4 )
	{
		m4[index].x = xi;
		m4[index].y = yi;
	}
	if( m == 5 )
	{
		m5[index].x = xi;
		m5[index].y = yi;
	}
	if( m == 6 )
	{
		m6[index].x = xi;
		m6[index].y = yi;
	}
	return index + 1;
}

//m1
int map_int = 1;
map_int = put(1,map_int,6, 12);
map_int = put(1,map_int,7, 12);
map_int = put(1,map_int,8, 12);
map_int = put(1,map_int,9, 11);
map_int = put(1,map_int,8, 11);
map_int = put(1,map_int,9, 10);
map_int = put(1,map_int,10, 9);
map_int = put(1,map_int,10, 8);
map_int = put(1,map_int,9, 7);
map_int = put(1,map_int,10, 6);
map_int = put(1,map_int,10, 5);
map_int = put(1,map_int,10, 4);
map_int = put(1,map_int,11, 3);
map_int = put(1,map_int,10, 2);
map_int = put(1,map_int,9, 1);
map_int = put(1,map_int,8, 0);
map_int = put(1,map_int,9, 0);
map_int = put(1,map_int,10, 1);
map_int = put(1,map_int,11, 0);
map_int = put(1,map_int,12, 1);
map_int = put(1,map_int,12, 2);
map_int = put(1,map_int,12, 3);
map_int = put(1,map_int,12, 4);
map_int = put(1,map_int,12, 5);
map_int = put(1,map_int,11, 6);
map_int = put(1,map_int,12, 7);
map_int = put(1,map_int,12, 8);
map_int = put(1,map_int,12, 9);
map_int = put(1,map_int,12, 10);
map_int = put(1,map_int,12, 11);
map_int = put(1,map_int,11, 12);
map_int = put(1,map_int,10, 12);
map_int = put(1,map_int,11, 11);
map_int = put(1,map_int,10, 10);
map_int = put(1,map_int,9, 9);
map_int = put(1,map_int,8, 9);
map_int = put(1,map_int,7, 10);
map_int = put(1,map_int,6, 10);
map_int = put(1,map_int,5, 9);
map_int = put(1,map_int,4, 10);
map_int = put(1,map_int,3, 9);
map_int = put(1,map_int,3, 8);
map_int = put(1,map_int,3, 7);
map_int = put(1,map_int,2, 6);
map_int = put(1,map_int,1, 6);
map_int = put(1,map_int,0, 5);
map_int = put(1,map_int,1, 4);
map_int = put(1,map_int,2, 3);
map_int = put(1,map_int,2, 4);
map_int = put(1,map_int,1, 3);
map_int = put(1,map_int,0, 3);
map_int = put(1,map_int,1, 2);
map_int = put(1,map_int,1, 1);
map_int = put(1,map_int,2, 0);
map_int = put(1,map_int,3, 1);
map_int = put(1,map_int,4, 1);
map_int = put(1,map_int,5, 2);
map_int = put(1,map_int,6, 2);
map_int = put(1,map_int,7, 2);
map_int = put(1,map_int,8, 3);
map_int = put(1,map_int,7, 3);
map_int = put(1,map_int,6, 3);
map_int = put(1,map_int,7, 4);
map_int = put(1,map_int,6, 5);
map_int = put(1,map_int,6, 6);

//m2
map_int = 1;
map_int = put(2,map_int,6,12);
map_int = put(2,map_int,5, 12);
map_int = put(2,map_int,4, 12);
map_int = put(2,map_int,3, 11);
map_int = put(2,map_int,4, 11);
map_int = put(2,map_int,3, 10);
map_int = put(2,map_int,2, 9);
map_int = put(2,map_int,2, 8);
map_int = put(2,map_int,3, 7);
map_int = put(2,map_int,2, 6);
map_int = put(2,map_int,2, 5);
map_int = put(2,map_int,2, 4);
map_int = put(2,map_int,1, 3);
map_int = put(2,map_int,2, 2);
map_int = put(2,map_int,3, 1);
map_int = put(2,map_int,4, 0);
map_int = put(2,map_int,3, 0);
map_int = put(2,map_int,2, 0);
map_int = put(2,map_int,1, 0);
map_int = put(2,map_int,0, 1);
map_int = put(2,map_int,0, 2);
map_int = put(2,map_int,0, 3);
map_int = put(2,map_int,0, 4);
map_int = put(2,map_int,0, 5);
map_int = put(2,map_int,1, 6);
map_int = put(2,map_int,0, 7);
map_int = put(2,map_int,0, 8);
map_int = put(2,map_int,0, 9);
map_int = put(2,map_int,0, 10);
map_int = put(2,map_int,0, 11);
map_int = put(2,map_int,1, 12);
map_int = put(2,map_int,2, 12);
map_int = put(2,map_int,1, 11);
map_int = put(2,map_int,2, 10);
map_int = put(2,map_int,3, 9);
map_int = put(2,map_int,4, 9);
map_int = put(2,map_int,5, 10);
map_int = put(2,map_int,6, 10);
map_int = put(2,map_int,7, 9);
map_int = put(2,map_int,8, 10);
map_int = put(2,map_int,9, 9);
map_int = put(2,map_int,9, 8);
map_int = put(2,map_int,9, 7);
map_int = put(2,map_int,10, 6);
map_int = put(2,map_int,11, 6);
map_int = put(2,map_int,12, 5);
map_int = put(2,map_int,11, 4);
map_int = put(2,map_int,10, 3);
map_int = put(2,map_int,10, 4);
map_int = put(2,map_int,11, 3);
map_int = put(2,map_int,12, 3);
map_int = put(2,map_int,11, 2);
map_int = put(2,map_int,11, 1);
map_int = put(2,map_int,10, 0);
map_int = put(2,map_int,9, 1);
map_int = put(2,map_int,8, 1);
map_int = put(2,map_int,7, 2);
map_int = put(2,map_int,6, 2);
map_int = put(2,map_int,5, 2);
map_int = put(2,map_int,4, 3);
map_int = put(2,map_int,5, 3);
map_int = put(2,map_int,6, 3);
map_int = put(2,map_int,5, 4);
map_int = put(2,map_int,6, 5);
map_int = put(2,map_int,6, 6);

//m3
map_int = 1;
map_int = put(3,map_int,6, 12);
map_int = put(3,map_int,7, 12);
map_int = put(3,map_int,8, 11);
map_int = put(3,map_int,9, 11);
map_int = put(3,map_int,10, 11);
map_int = put(3,map_int,9, 10);
map_int = put(3,map_int,9, 9);
map_int = put(3,map_int,8, 10);
map_int = put(3,map_int,7, 9);
map_int = put(3,map_int,6, 10);
map_int = put(3,map_int,5, 10);
map_int = put(3,map_int,4, 10);
map_int = put(3,map_int,3, 11);
map_int = put(3,map_int,2, 10);
map_int = put(3,map_int,1, 11);
map_int = put(3,map_int,0, 10);
map_int = put(3,map_int,1, 9);
map_int = put(3,map_int,2, 9);
map_int = put(3,map_int,1, 8);
map_int = put(3,map_int,0, 7);
map_int = put(3,map_int,0, 6);
map_int = put(3,map_int,1, 5);
map_int = put(3,map_int,0, 4);
map_int = put(3,map_int,0, 3);
map_int = put(3,map_int,1, 2);
map_int = put(3,map_int,2, 1);
map_int = put(3,map_int,3, 0);
map_int = put(3,map_int,4, 0);
map_int = put(3,map_int,5, 1);
map_int = put(3,map_int,6, 0);
map_int = put(3,map_int,7, 0);
map_int = put(3,map_int,8, 1);
map_int = put(3,map_int,9, 1);
map_int = put(3,map_int,10, 2);
map_int = put(3,map_int,11, 3);
map_int = put(3,map_int,10, 4);
map_int = put(3,map_int,9, 5);
map_int = put(3,map_int,8, 6);
map_int = put(3,map_int,8, 7);
map_int = put(3,map_int,7, 7);
map_int = put(3,map_int,6, 6);

//m4
map_int = 1;
map_int = put(4,map_int,6, 12);
map_int = put(4,map_int,5, 12);
map_int = put(4,map_int,4, 11);
map_int = put(4,map_int,3, 11);
map_int = put(4,map_int,2, 11);
map_int = put(4,map_int,3, 10);
map_int = put(4,map_int,3, 9);
map_int = put(4,map_int,4, 10);
map_int = put(4,map_int,5, 9);
map_int = put(4,map_int,6, 10);
map_int = put(4,map_int,7, 10);
map_int = put(4,map_int,8, 10);
map_int = put(4,map_int,9, 11);
map_int = put(4,map_int,10, 10);
map_int = put(4,map_int,11, 11);
map_int = put(4,map_int,12, 10);
map_int = put(4,map_int,11, 9);
map_int = put(4,map_int,10, 9);
map_int = put(4,map_int,11, 8);
map_int = put(4,map_int,12, 7);
map_int = put(4,map_int,12, 6);
map_int = put(4,map_int,11, 5);
map_int = put(4,map_int,12, 4);
map_int = put(4,map_int,11, 3);
map_int = put(4,map_int,11, 2);
map_int = put(4,map_int,10, 1);
map_int = put(4,map_int,9, 0);
map_int = put(4,map_int,8, 0);
map_int = put(4,map_int,7, 1);
map_int = put(4,map_int,6, 0);
map_int = put(4,map_int,5, 0);
map_int = put(4,map_int,4, 1);
map_int = put(4,map_int,3, 1);
map_int = put(4,map_int,2, 2);
map_int = put(4,map_int,1, 3);
map_int = put(4,map_int,2, 4);
map_int = put(4,map_int,3, 5);
map_int = put(4,map_int,3, 6);
map_int = put(4,map_int,4, 7);
map_int = put(4,map_int,5, 7);
map_int = put(4,map_int,6, 6);

//m5
map_int = 1;
map_int = put(5,map_int,6, 12);
map_int = put(5,map_int,7, 12);
map_int = put(5,map_int,8, 12);
map_int = put(5,map_int,9, 11);
map_int = put(5,map_int,10, 11);
map_int = put(5,map_int,11, 10);
map_int = put(5,map_int,11, 9);
map_int = put(5,map_int,11, 8);
map_int = put(5,map_int,12, 7);
map_int = put(5,map_int,12, 6);
map_int = put(5,map_int,11, 5);
map_int = put(5,map_int,11, 4);
map_int = put(5,map_int,11, 3);
map_int = put(5,map_int,10, 2);
map_int = put(5,map_int,9, 1);
map_int = put(5,map_int,8, 1);
map_int = put(5,map_int,7, 0);
map_int = put(5,map_int,6, 0);
map_int = put(5,map_int,5, 1);
map_int = put(5,map_int,4, 1);
map_int = put(5,map_int,3, 0);
map_int = put(5,map_int,2, 0);
map_int = put(5,map_int,1, 1);
map_int = put(5,map_int,1, 2);
map_int = put(5,map_int,0, 3);
map_int = put(5,map_int,0, 4);
map_int = put(5,map_int,1, 5);
map_int = put(5,map_int,2, 4);
map_int = put(5,map_int,3, 3);
map_int = put(5,map_int,4, 3);
map_int = put(5,map_int,5, 3);
map_int = put(5,map_int,6, 2);
map_int = put(5,map_int,7, 2);
map_int = put(5,map_int,8, 3);
map_int = put(5,map_int,9, 4);
map_int = put(5,map_int,9, 5);
map_int = put(5,map_int,9, 6);
map_int = put(5,map_int,10, 7);
map_int = put(5,map_int,9, 7);
map_int = put(5,map_int,8, 6);
map_int = put(5,map_int,8, 7);
map_int = put(5,map_int,7, 8);
map_int = put(5,map_int,6, 8);
map_int = put(5,map_int,5, 8);
map_int = put(5,map_int,4, 7);
map_int = put(5,map_int,5, 6);
map_int = put(5,map_int,6, 6);

//m6
map_int = 1;
map_int = put(6,map_int,6, 12);
map_int = put(6,map_int,5, 12);
map_int = put(6,map_int,4, 12);
map_int = put(6,map_int,3, 11);
map_int = put(6,map_int,2, 11);
map_int = put(6,map_int,1, 10);
map_int = put(6,map_int,1, 9);
map_int = put(6,map_int,1, 8);
map_int = put(6,map_int,0, 7);
map_int = put(6,map_int,0, 6);
map_int = put(6,map_int,1, 5);
map_int = put(6,map_int,1, 4);
map_int = put(6,map_int,1, 3);
map_int = put(6,map_int,2, 2);
map_int = put(6,map_int,3, 1);
map_int = put(6,map_int,4, 1);
map_int = put(6,map_int,5, 0);
map_int = put(6,map_int,6, 0);
map_int = put(6,map_int,7, 1);
map_int = put(6,map_int,8, 1);
map_int = put(6,map_int,9, 0);
map_int = put(6,map_int,10, 0);
map_int = put(6,map_int,11, 1);
map_int = put(6,map_int,11, 2);
map_int = put(6,map_int,12, 3);
map_int = put(6,map_int,12, 4);
map_int = put(6,map_int,11, 5);
map_int = put(6,map_int,10, 4);
map_int = put(6,map_int,9, 3);
map_int = put(6,map_int,8, 3);
map_int = put(6,map_int,7, 3);
map_int = put(6,map_int,6, 2);
map_int = put(6,map_int,5, 2);
map_int = put(6,map_int,4, 3);
map_int = put(6,map_int,3, 4);
map_int = put(6,map_int,3, 5);
map_int = put(6,map_int,3, 6);
map_int = put(6,map_int,2, 7);
map_int = put(6,map_int,3, 7);
map_int = put(6,map_int,4, 6);
map_int = put(6,map_int,4, 7);
map_int = put(6,map_int,5, 8);
map_int = put(6,map_int,6, 8);
map_int = put(6,map_int,7, 8);
map_int = put(6,map_int,8, 7);
map_int = put(6,map_int,7, 6);
map_int = put(6,map_int,6, 6);

boolean [int] boo_maze;
boo_maze[1] = true;
boo_maze[2] = true;
boo_maze[3] = true;
boo_maze[4] = true;
boo_maze[5] = true;
boo_maze[6] = true;

void compare( string x , int y )
{
	if( maze1[y] != x )
		boo_maze[1] = false;
	if( maze2[y] != x )
		boo_maze[2] = false;
	if( maze3[y] != x )
		boo_maze[3] = false;
	if( maze4[y] != x )
		boo_maze[4] = false;
	if( maze5[y] != x )
		boo_maze[5] = false;
	if( maze6[y] != x )
		boo_maze[6] = false;
}

void main()
{
	if( !user_confirm( "Select Yes if you can guarantee you are at the START of the maze. Otherwise, click no and swim to shore first." ) )
	{
		print( "Stopping the script before we try anything WEIRD" , "red" );
		exit;
	}
	int counter = 0;
	while( my_hp() == 0 )
		visit_url("galaktik.php?pwd&action=curehp&quantity=1");
	string [int] maze;
	string main = visit_url( "volcanomaze.php" );
	if( contains_text( main , "A Volcanic Cave" ) )
	{
		string [int] split = split_string( main , "</div>" );
		foreach int in split
		{
			if( contains_text( split[int] , "<div id=\"sq" ) )
			{
				counter = counter + 1;
				if( contains_text( split[int] , "class=\"sq yes" ) )
				{
					maze[int] = "X";
				}
				else if( contains_text( split[int] , "class=\"sq no" ) )
				{
					maze[int] = "O";
				}
			}
		}
		
		if( counter < 169 || counter > 169 )
		{
			print( "Counted an unexpected number of squares. Counted: " + counter + ". Expected: 169." );
			exit;
		}
		else
			print( "Counted " + counter + " squares." );
		
		for int from 0 to 12
		{
			print( "Comparing row 1, square " + int );
			compare( maze[int] , int );
		}
		
		int count_boo = 0;
		foreach int in boo_maze
		{
			if( boo_maze[int] == true )
			{
				print( "Maze " + int + " is true" );
				foreach x in boo_maze
				{
					if( boo_maze[int] == boo_maze[x] )
					{
						print( "Maze " + int + " matches maze " + x + ". If the numbers are the same, that's good!" );
						count_boo = count_boo + 1;
					}
				}
			}
		}
		if( count_boo != 1 )
		{
			print( "You have " + count_boo + " mazes matching. Exiting." );
			exit;
		}
		else
			print( "You have " + count_boo + " maze matching. Perfect." );
		
		coordinate [int] map;

		if( boo_maze[1] == true )
		{
			map = m1;
		}
		else if( boo_maze[2] == true )
		{
			map = m2;
		}
		else if( boo_maze[3] == true )
		{
			map = m3;
		}
		else if( boo_maze[4] == true )
		{
			map = m4;
		}
		else if( boo_maze[5] == true )
		{
			map = m5;
		}
		else if( boo_maze[6] == true )
		{
			map = m6;
		}
		else
			print( "Not sure what's going on here. The script should have aborted before now. Please contact Grotfang or CptJesus." );

		int loopindex = 1;
		while( loopindex < count( map ) )
		{
			int x = map[loopindex].x;
			int y = map[loopindex].y;
			visit_url( "volcanomaze.php?move=" + x + "," + y + "&ajax=1", false );
			print( x + "," + y );
			loopindex = loopindex + 1;
		}
		
		print( "Finished." );
	}
	else
		print( "It doesn't look like you've opened the lava cave yet." );
}
