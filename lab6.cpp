#include <iostream>
#include <iomanip>
#include <ctime>
#include <math.h>
#include <stdlib.h>
//8 variant
using namespace std;

int main()
{
	cout << "Input size of array" << endl;
	
	int size;
	
	while (!(cin >> size) || !(size >= 0 && size <= 10))
	{
		cin.clear();
		cin.ignore(numeric_limits<streamsize>::max(), '\n');
	}
	
	double* arr = new double[size];
	double* res = new double[size];

	for (int i = 0; i < size; i++)
	{
		do
		{
			cin.clear();
			cin.ignore(numeric_limits<streamsize>::max(), '\n');
			cout << "arr[" << i << "]" << endl;
		} while (!(cin >> arr[i]));
	}

	_asm
	{
		FINIT
	}
	
	
	for (int i = 0; i < size; i++)
	{
		double val = arr[i];
		double result;
		if (i % 2)
		{
			_asm
			{
				PUSHA

				FLD val

				FSIN

				FSTP result

				FWAIT

				POPA
			}
		}
		else
		{
			_asm
			{
				PUSHA

				FLD val

				FCOS

				FSTP result

				FWAIT

				POPA
			}
		}

		res[i] = result;
	}

	for (int i = 0; i < size; i++)
	{
		cout << "res[" << i << "]" << " = " << res[i] << endl;
	}

	system("pause");
	return 0;
}