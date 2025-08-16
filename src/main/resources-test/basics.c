#include "io.h"

u8 zero = '0';
u8 one = '1';
u8 two = '2';
u8 threeFour = 34;

i64 unusedArgs(i16 a, bool b, i64 c, i64 d) {
	return c;
}

void main() {
	i64 c = unusedArgs(1, true, 2, 3);

	printChar(zero);

	u8* onePtr = &one;
	printChar(*onePtr);

	u8* twoPtr = &two;
	printChar(twoPtr[0]);

	printUint(threeFour);

	printChar('\n');
}
