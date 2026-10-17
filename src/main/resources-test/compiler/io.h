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
	printUint(number as i64);
}

void printUint(i16 number) {
	printUint(number as i64);
}

void printUint(i32 number) {
	printUint(number as i64);
}

void printUint(i64 number) {
	u8 buffer[20];
	u8 pos = 20;
	while (true) {
		pos -= 1;
		i64 remainder = number % 10;
		number /= 10;
		u8 digit = remainder as u8 + '0';
		buffer[pos] = digit;
		if (number == 0) {
			break;
		}
	}
	printStringLength(&buffer[pos], 20 - pos);
}

void printIntLf(bool number) {
	printIntLf(number as i64);
}

void printIntLf(u8 number) {
	printIntLf(number as i64);
}

void printIntLf(i16 number) {
	printIntLf(number as i64);
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
	for (; *str != 0; str += 1) {
		length += 1;
	}
	return length;
}

void printStringLength(u8* str, u8 length) {
	printStringLength(str, length as i64);
}

#endif
