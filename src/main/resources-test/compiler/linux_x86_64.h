void printStringLength(u8* str, i64 length) asm {
	// rsp+0    calling address
	// rsp+8    nothing (offset to get rsp % 10 == 0)
	// rdi      str
	// rsi      length
    //
    // https://www.chromium.org/chromium-os/developer-library/reference/linux-constants/syscalls/#x86_64-64-bit
	// syscall write(
    //    rax=1
    //    arg0(rdi)=file descriptor
    //    arg1(rsi)=const char *buf
    //    arg2(rdx)=count
	//);
    "mov rdx, rsi"
    "mov rsi, rdi"
    "mov rdi, 1"    // stdout
    "mov rax, 1"    // sys_write
    "syscall"
	"ret"
}

i16 getChar() asm {
	"sub    rsp, 28h" // 8h to compensate for return address, 20h for calling _getch
	"  call [_getch]"
	"  test al, al"
	"  js   .1"
	"  jnz  .2"
	"  dec  al"
	".1:"
	"  mov  rbx, rax"
	"  shl  rbx, 8"
	"  call [_getch]"
	"  or   rax, rbx"
	".2:"
	"add    rsp, 28h"
	"ret"
}

void setCursor(i16 x, i16 y) asm {
	// rcx      y
	// rdx      x
	// BOOL WINAPI SetConsoleCursorPosition(
	//  _In_ HANDLE hConsoleOutput,            rcx
	//  _In_ COORD  dwCursorPosition           rdx
	// );
	// typedef struct _COORD {
	//   SHORT X;
	//   SHORT Y;
	// } COORD, *PCOORD;
	"sub     rsp, 28h"
	"shl     rcx, 16"
	"movsxd  rcx, ecx"
	"movsx   rdx, dx"
	"add     rdx, rcx"
	"lea     rcx, [hStdOut]"
	"mov     rcx, [rcx]"
	"call   [SetConsoleCursorPosition]"
	"add     rsp, 28h"
	"ret"
}
