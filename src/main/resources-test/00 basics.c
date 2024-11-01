#include "io.h"

u8 zero = '0';
u8 one = '1';
u8 two = '2';
u8 threeFour = 34;

void main() {
	printChar(zero);

	u8* onePtr = &one;
	printChar(*onePtr);

	u8* twoPtr = &two;
	printChar(twoPtr[0]);

	printUint(threeFour);

	printChar('\n');
}
