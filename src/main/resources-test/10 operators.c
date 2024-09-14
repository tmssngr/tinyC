#include "x86_64.h"

void main() {
	printString("Bit-&:\n");
	i16 a = 0;
	i16 b = 1;
	i16 c = 2;
	i16 d = 3;
	bool t = true;
	bool f = false;
	printIntLf(a & a);
	printIntLf(a & b);
	printIntLf(b & a);
	printIntLf(b & b);
	printString("\nBit-|:\n");
	printIntLf(a | a);
	printIntLf(a | b);
	printIntLf(b | a);
	printIntLf(b | b);
	printString("\nBit-^:\n");
	printIntLf(a ^ a);
	printIntLf(a ^ c);
	printIntLf(b ^ a);
	printIntLf(b ^ c);
	printString("\nLogic-&&:\n");
	printIntLf(f && f);
	printIntLf(f && t);
	printIntLf(t && f);
	printIntLf(t && t);
	printString("\nLogic-||:\n");
	printIntLf(f || f);
	printIntLf(f || t);
	printIntLf(t || f);
	printIntLf(t || t);
	printString("\nLogic-!:\n");
	printIntLf(!f);
	printIntLf(!t);
	printString("\nmisc:\n");
	u8 b10 = 0b1010;
	u8 b6 = 0b0110;
	u8 b1 = 0b0001;
	printIntLf(b10 & b6 | b1);
	printIntLf(b == c || c < d);
	printIntLf(b == c && c < d);
	printIntLf(-1);
	printIntLf(-b);
	printIntLf(~b1);
}
