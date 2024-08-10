# TinyC

This is a compiler implemented in Java to parse a language similar to a subset of C.
Currently, it produced X86_64 binaries for Windows using the excellent [FASM assembler](http://flatassembler.net/).

## Assembler

To be able to implement more functions, it is possible to implement functions completely in ASM.

```
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
```
