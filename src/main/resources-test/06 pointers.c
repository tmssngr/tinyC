#include "x86_64.h"

void main() {
	i16 a = 10;  // a=var0
	printIntLf(a);
	i16* b = &a; // b=var1
	i16 c = *b - 1;  // c=var2
	printIntLf(c);
	i16* d = &c; // d=var3
	*d = *d - 1;
	printIntLf(c);
}
