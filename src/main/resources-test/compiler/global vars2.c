#include "io.h"

u8 global = 0;

u8 next() {
	u8 copy = global;
	global = global + 1;
	return copy;
}

void main() {
	while (true) {
		printString("loop\n");
		u8 n = next();
		if (n == 3) {
			break;
		}

		if (n < 2) {
			printString("<2\n");
		}
	}
}
