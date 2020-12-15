#include <stdio.h>
float sinus(int x);

int main(void) {
	int x;
	x = 30;
	printf("x = %i\n", x);
        printf("sin(x) = %.*f\n", 9, sinus(x));
        return 0;
}

