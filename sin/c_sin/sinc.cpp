#include <iostream>
#include <iomanip>
#include <cmath>
using namespace std; 
int main()
{    
	int n=0;
	double x, eps=0.00001;
	cout << "x="; cin >> x; 
	double an=x, y=0.0;          
	while(fabs(an)>eps)
	{   
		y+=an;
		n++;
		an*=-x*x/(2*n*(2*n+1));         
	}
	cout << "y=" << y << "\n";
	return 0;
}
