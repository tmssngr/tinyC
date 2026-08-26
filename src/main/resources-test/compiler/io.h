#ifdef X86_64
#include "x86_64.h"

void printString(u8* str) {
	i64 length = strlen(str);
	printStringLength(str, length);
}

void printChar(u8 chr) {
	printStringLength(&chr, 1);
}

void printUint(u8 number) {
	printUint((i64)number);
}

void printUint(i16 number) {
	printUint((i64)number);
}

void printUint(i32 number) {
	printUint((i64)number);
}

void printUint(i64 number) {
	u8 buffer[20];
	u8 pos = 20;
	while (true) {
		pos = pos - 1;
		i64 remainder = number % 10;
		number = number / 10;
		u8 digit = (u8)remainder + '0';
		buffer[pos] = digit;
		if (number == 0) {
			break;
		}
	}
	printStringLength(&buffer[pos], 20 - pos);
}

void printIntLf(bool number) {
	printIntLf((i64)number);
}

void printIntLf(u8 number) {
	printIntLf((i64)number);
}

void printIntLf(i16 number) {
	printIntLf((i64)number);
}

void printIntLf(i64 number) {
	if (number < 0) {
		printChar('-');
		number = -number;
	}
	printUint(number);
	printChar('\n');
}

i64 strlen(u8* str) {
	i64 length = 0;
	for (; *str != 0; str = str + 1) {
		length = length + 1;
	}
	return length;
}

void printStringLength(u8* str, u8 length) {
	printStringLength(str, (i64)length);
}

#end
