#include "io.h"
#include "random.h"

void main() {
	initRandom(7439742);
	for (i16 i = 0; i < 300; i = i + 1) {
		i32 r = random();
		printIntLf((i64)r);
	}
}
