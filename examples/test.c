#include "../src/main/resources-test/x86_64.h"

void main() {
	i16 chr = getChar();
	setCursor(0, 0);
	printIntLf(chr);
}
