#include "io.h"

void testIf(u8 a) {
	u8 b = 1
	u8* b_ref = &b
	if a == 0 {
	  printIntLf(*b_ref)
	}
	printIntLf(b)
}

void main() {
	i16 a = 10;
	printIntLf(a);
	i16* b = &a;
	i16 c = *b - 1;
	printIntLf(c);
	i16* d = &c;
	*d = *d - 1;
	printIntLf(c);

	testIf(1)
}
