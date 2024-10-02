void printString(u8* str) {
	while (true) {
		u8 chr = *str;
		if (chr == 0) {
			break;
		}

		printChar(chr);
	}
}

void printStringLength(u8* str, u8 length) {
	while (length > 0) {
		u8 chr = *str;
		printChar(chr);
		length = length - 1;
	}
}

const PRINT_UINT_BUFFER_SIZE = 20;
void printUint(i16 number) {
	u8 buffer[PRINT_UINT_BUFFER_SIZE];
	u8 pos = PRINT_UINT_BUFFER_SIZE;
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
	printStringLength(&buffer[pos], PRINT_UINT_BUFFER_SIZE - pos);
}

void printIntLf(i16 number) {
	if (number < 0) {
		printChar('-');
		number = -number;
	}
	printUint(number);
	printChar('\n');
}

void printChar(u8 chr) asm {
	"ld   r0, SPH"
	"ld   r1, SPL"
	"add  r1, 3"
	"adc  r0, 0"
	"ldc  r1, @rr0"
	"ld   %15, r1"
	"jp   %0818"
}

u8 getChar() {
	return 0;
}

void setCursor(u8 x, u8 y) {
}

i32 __random__ = 0;
const __random__a = 48271;
void initRandom(i32 salt) {
	__random__ = salt;
}

i32 random() {
	return 0;
}

u8 randomU8() {
	return (u8)random();
}
