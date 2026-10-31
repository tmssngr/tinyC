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

const ESCAPE = 0x1b;
const CURSOR_UP = 0xE048 as i16
const CURSOR_LEFT = 0xE04B as i16
const CURSOR_RIGHT = 0xE04D as i16
const CURSOR_DOWN = 0xE050 as i16

i16 getChar() asm {
	// Assumes stdin is a terminal. termios needs 36 bytes; input goes at 40.
	// Returns one byte (0..255), or -1 on EOF/read error.
	"sub    rsp, 48"
	"xor    edi, edi"       // fd = stdin throughout
	"mov    eax, 16"        // ioctl(0, TCGETS, &termios)
	"mov    esi, 5401h"
	"mov    rdx, rsp"
	"syscall"

	// Save the fields we change: local flags, VTIME and VMIN.
	"mov    r8d, [rsp+12]"
	"mov    r9w, [rsp+22]"
	"and    dword [rsp+12], not 4Ah" // no line buffering or echo
	"mov    word [rsp+22], 100h"    // VTIME = 0, VMIN = 1: wait for a byte
	"mov    eax, 16"        // ioctl(0, TCSETS, &termios)
	"mov    esi, 5402h"
	"syscall"

	"xor    eax, eax"       // read(0, &input, 1)
	"lea    rsi, [rsp+40]"
	"mov    edx, 1"
	"syscall"
	"mov    r10d, -1"
	"cmp    eax, 1"
	"jne    .restore"
	"movzx  r10d, byte [rsp+40]"

	".restore:"
	"mov    [rsp+12], r8d"
	"mov    [rsp+22], r9w"
	"mov    eax, 16"        // restore the original terminal settings
	"mov    esi, 5402h"
	"mov    rdx, rsp"
	"syscall"
	"mov    eax, r10d"
	"add    rsp, 48"
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
