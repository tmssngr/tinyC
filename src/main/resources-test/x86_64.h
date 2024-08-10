void printString(u8* str) {
	i64 length = strlen(str);
	printStringLength(str, length);
}

void printChar(u8 chr) {
	printStringLength(&chr, 1);
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

void printStringLength(u8* str, i64 length) asm {
	// rsp+0    calling address
	// rsp+8    nothing (offset to get rsp % 10 == 0)
	// rsp+10h  length
	// rsp+18h  str
	// BOOL WriteFile(
	//  [in]                HANDLE       hFile,                    rcx
	//  [in]                LPCVOID      lpBuffer,                 rdx
	//  [in]                DWORD        nNumberOfBytesToWrite,    r8
	//  [out, optional]     LPDWORD      lpNumberOfBytesWritten,   r9
	//  [in, out, optional] LPOVERLAPPED lpOverlapped              stack
	//);
	"mov     rdi, rsp"
	""
	"lea     rcx, [hStdOut]"
	"mov     rcx, [rcx]"
	"mov     rdx, [rdi+18h]"
	"mov     r8, [rdi+10h]"
	"xor     r9, r9"
	"push    0"
	"sub     rsp, 20h"
	"  call    [WriteFile]"
	"mov     rsp, rdi"
	"ret"
}