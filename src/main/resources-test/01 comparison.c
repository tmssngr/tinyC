#include "x86_64.h"

void main() {
	printString("< (signed)\n");
	printIntLf(1 < 2);
	printIntLf(2 < 1);

	printString("< (unsigned)\n");
	printIntLf(0 < 0x80);
	printIntLf(0x80 < 0);

	printString("<= (signed)\n");
	printIntLf(1 <= 2);
	printIntLf(2 <= 1);

	printString("<= (unsigned)\n");
	printIntLf(0 <= 0x80);
	printIntLf(0x80 <= 0);

	printString("==\n");
	printIntLf(1 == 2);

	printString("!=\n");
	printIntLf(1 != 2);

	printString(">= (signed)\n");
	printIntLf(1 >= 2);
	printIntLf(2 >= 1);

	printString(">= (unsigned)\n");
	printIntLf(0 >= 0x80);
	printIntLf(0x80 >= 0);

	printString("> (signed)\n");
	printIntLf(1 > 2);
	printIntLf(2 > 1);

	printString("> (unsigned)\n");
	printIntLf(0 > 0x80);
	printIntLf(0x80 > 0);
}
