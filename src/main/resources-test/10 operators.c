#include "x86_64.h"

void main() {
	printString("Bit-&:\n");
	print(0 & 0);
	print(0 & 1);
	print(1 & 0);
	print(1 & 1);
	printString("\nBit-|:\n");
	print(0 | 0);
	print(0 | 1);
	print(1 | 0);
	print(1 | 1);
	printString("\nBit-^:\n");
	print(0 ^ 0);
	print(0 ^ 2);
	print(1 ^ 0);
	print(1 ^ 2);
	printString("\nLogic-&&:\n");
	print(false && false);
	print(false && true);
	print(true && false);
	print(true && true);
	printString("\nLogic-||:\n");
	print(false || false);
	print(false || true);
	print(true || false);
	print(true || true);
	printString("\nLogic-!:\n");
	print(!false);
	print(!true);
	printString("\nmisc:\n");
	print(0b1010 & 0b0110 | 0b0001);
	print(1 == 2 || 2 < 3);
	print(1 == 2 && 2 < 3);
	print(-1);
	print(~1);
}
