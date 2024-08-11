#include "x86_64.h"

void printNibble(u8 x) {
	x = x & 0xf;
	if (x > 9) {
		x = x + ('A' - '9' - 1);
	}
	x = x + '0';
	printChar(x);
}

void printHex2(u8 x) {
	printNibble(x / 16);
	printNibble(x);
}

void main() {
	printString(" x");
	for (u8 i = 0; i < 0x10; i = i + 1) {
		if ((i & 7) == 0) {
			printChar(' ');
		}
		printNibble(i);
	}
	printChar('\n');

	for (u8 i = 0x20; i < 0x80; i = i + 1) {
		if ((i & 0xF) == 0) {
			printHex2(i);
		}
		if ((i & 7) == 0) {
			printChar(' ');
		}
		printChar(i);
		if ((i & 0xF) == 0xF) {
			printChar('\n');
		}
	}
}
