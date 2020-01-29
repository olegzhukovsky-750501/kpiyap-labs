#define _CRT_SECURE_NO_WARNINGS
#include <windows.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

int main()
{
	int flag = 1;
	do
	{
		double upper, lower, d;
		double result_c;

		do
		{
			system("cls");
			printf("lower limit:");
			rewind(stdin);
			scanf("%lf", &lower);
		} while (lower <= 0);
		do
		{
			system("cls");
			printf("upper limit:");
			rewind(stdin);
			scanf("%lf", &upper);
		} while (upper <= 0);
		printf("Enter step:");
		rewind(stdin);
		scanf("%lf", &d);


		clock_t begin = clock();
		for (double i = lower; i < upper; i += d)
		{
			result_c = (i * sqrt(i) / log2(i));
		}
		clock_t end = clock();

		printf("math.h time : %.8lf seconds\nresult:%lf\n\n", (double)(end - begin) / CLOCKS_PER_SEC, result_c);

		double result_asm;
		begin = clock();
		_asm finit;
		for (double i = lower; i < upper; i += d)
		{
			_asm
			{
				fld i
				fsqrt
				fmul i
				fld1
				fld i
				fyl2x
				
				fdiv

				fstp result_asm
			}
		}
		_asm fwait;
		end = clock();

		printf("coprocessor time : %.8lf seconds\nresult:%lf", (double)(end - begin) / CLOCKS_PER_SEC, result_asm);
		printf("\n0 - EXIT\nOTHER KEYS - CONTINUE\n");
		rewind(stdin);
		scanf("%d", &flag);
		system("cls");
	} while (flag);

	system("pause");
	return 0;
}