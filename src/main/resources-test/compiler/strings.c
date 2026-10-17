#include "io.h"

u8* text = "hello world\n";

void main() {
	printString(text);
	printLength();
	u8* second = &text[1];
	printString(second);
	u8 chr = *text;
	printIntLf(chr);
}

void printLength() {
	i16 length = 0;
	for (u8* ptr = text; *ptr != 0; ptr += 1) {
		length += 1;
	}
	printIntLf(length);
}
