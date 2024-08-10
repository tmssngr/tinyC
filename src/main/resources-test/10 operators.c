#include "x86_64.h"

void main() {
	printString("Bit-&:\n");
	printIntLf(0 & 0);
	printIntLf(0 & 1);
	printIntLf(1 & 0);
	printIntLf(1 & 1);
	printString("\nBit-|:\n");
	printIntLf(0 | 0);
	printIntLf(0 | 1);
	printIntLf(1 | 0);
	printIntLf(1 | 1);
	printString("\nBit-^:\n");
	printIntLf(0 ^ 0);
	printIntLf(0 ^ 2);
	printIntLf(1 ^ 0);
	printIntLf(1 ^ 2);
	printString("\nLogic-&&:\n");
	printIntLf(false && false);
	printIntLf(false && true);
	printIntLf(true && false);
	printIntLf(true && true);
	printString("\nLogic-||:\n");
	printIntLf(false || false);
	printIntLf(false || true);
	printIntLf(true || false);
	printIntLf(true || true);
	printString("\nLogic-!:\n");
	printIntLf(!false);
	printIntLf(!true);
	printString("\nmisc:\n");
	printIntLf(0b1010 & 0b0110 | 0b0001);
	printIntLf(1 == 2 || 2 < 3);
	printIntLf(1 == 2 && 2 < 3);
	printIntLf(-1);
	printIntLf(~1);
}
