#include "io.h"

void main() {
	initRandom(7439742);
	for (u8 i = 0; i < 50; i = i + 1) {
		u8 r = randomU8();
		printIntLf(r);
	}
}
