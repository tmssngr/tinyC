#include "x86_64.h"

void main() {
	doPrint(next(), next(), next(), next(), next());
}

u8 i = 0;

u8 next() {
	i = i + 1;
	return i;
}

void doPrint(u8 a, u8 b, u8 c, u8 d, u8 e) {
	printIntLf(a);
	printIntLf(b);
	printIntLf(c);
	printIntLf(d);
	printIntLf(e);
}
