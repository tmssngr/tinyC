/*
// rcx = pointer to text
// rdx = length
// BOOL WriteFile(
//  [in]                HANDLE       hFile,                    rcx
//  [in]                LPCVOID      lpBuffer,                 rdx
//  [in]                DWORD        nNumberOfBytesToWrite,    r8
//  [out, optional]     LPDWORD      lpNumberOfBytesWritten,   r9
//  [in, out, optional] LPOVERLAPPED lpOverlapped              stack
//);
void printString(u8* buffer, u16 count) asm {
        "mov     rdi, rsp"
        "and     spl, 0xF0"

        "mov     r8, rdx"
        "mov     rdx, rcx"
        "lea     rcx, [hStdOut]"
        "mov     rcx, [rcx]"
        "xor     r9, r9"
        "push    0"
        "sub     rsp, 20h"
        "call    [WriteFile]"
        "add     rsp, 20h"
        "; add     rsp, 8"
        "mov     rsp, rdi"
        "ret"
}
*/

void printString(u8* str) {
	i64 length = strlen(str);
	printStringLength(str, length);
}

i64 strlen(u8* str) {
	i64 length = 0;
	for (; *str != 0; str = str + 1) {
		length = length + 1;
	}
	return length;
}
