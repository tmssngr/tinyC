#include "x86_64.h"

void main() {
	i16 a = 10;
	printIntLf(a);
	i16* b = &a;
	i16 c = *b - 1;
	printIntLf(c);
	i16* d = &c;
	*d = *d - 1;
	printIntLf(c);
}
