#include "io.h"

/*
 * we use 8 arguments because on Linux/amd64 6 arguments are passed
 * in registers and we want to also check the order of the 7th and
 * 8th argument
 */
i16 printAndSum(i16 a, i16 b, i16 c, i16 d, i16 e, i16 f, i16 g, i16 h) {
	printIntLf(a);
	printIntLf(b);
	printIntLf(c);
	printIntLf(d);
	printIntLf(e);
	printIntLf(f);
	printIntLf(g);
	printIntLf(h);
	return a + b + c + d + e + f + g + h;
}

void main() {
	i16 sum = printAndSum(1, 2, 3, 4, 5, 6, 7, 8);
	printIntLf(sum);
}
