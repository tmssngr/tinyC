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

i16 getChar() {
	while (true) {
		i16 c = __getChar()
		if c != ESCAPE {
			return c
		}

		c = __getChar()
		if c == ESCAPE {
			return c
		}
		if c != '[' {
			continue
		}

		c = __getChar()
		if c == 'A' {
			return CURSOR_UP
		}
		if c == 'B' {
			return CURSOR_DOWN
		}
		if c == 'C' {
			return CURSOR_RIGHT
		}
		if c == 'D' {
			return CURSOR_LEFT
		}
	}
}

i16 __getChar() asm {
	// Assumes stdin is a terminal. The stack holds a 36-byte kernel termios
	// structure at rsp and an input byte at rsp+40.
	// Returns one byte (0..255), or -1 on EOF/read error.
	//
	// Linux x86-64 syscall ABI (numbers, argument registers, return value):
	// https://man7.org/linux/man-pages/man2/syscall.2.html
	// ioctl requests for reading/writing terminal settings:
	// https://man7.org/linux/man-pages/man2/ioctl_tty.2.html
	// Meaning of terminal flags, VTIME and VMIN:
	// https://man7.org/linux/man-pages/man3/termios.3.html
	// Kernel structure layout and flag values:
	// https://github.com/torvalds/linux/blob/master/include/uapi/asm-generic/termbits.h
	//
	// syscall uses rax for its number and rdi/rsi/rdx for its first 3 arguments.
	// It returns in rax and overwrites rcx/r11; r8/r9/r10 keep their values.
	// Writing eax/edi/esi/edx also clears the upper half of rax/rdi/rsi/rdx.
	"sub    rsp, 48"        // reserve space for termios, padding and input
	"xor    edi, edi"       // rdi = 0: stdin file descriptor, for every syscall below
	"mov    eax, 16"        // rax = 16: sys_ioctl
	"mov    esi, 5401h"     // rsi = TCGETS: read the current terminal settings
	"mov    rdx, rsp"       // rdx = address of the termios buffer
	"syscall"              // ioctl returns 0 on success, or a negative error number

	// Kernel termios offsets: c_lflag at 12, c_cc[VTIME] at 22, c_cc[VMIN] at 23.
	"mov    r8d, [rsp+12]"  // save the original c_lflag in r8d
	"mov    r9w, [rsp+22]"  // save the original VTIME/VMIN bytes in r9w
	// ICANON=02h (wait for Enter), ECHO=08h, ECHONL=40h (echo even a newline).
	"and    dword [rsp+12], not 4Ah" // clear those bits: no line buffering or echo
	// Little endian: word 0100h stores VTIME=0 (no timeout), then VMIN=1 (one byte).
	"mov    word [rsp+22], 100h"
	"mov    eax, 16"        // rax = 16: sys_ioctl
	"mov    esi, 5402h"     // rsi = TCSETS: apply the modified settings immediately
	// rdi is still 0 (stdin); rdx still points to termios at rsp.
	"syscall"

	// read(fd, buffer, count):
	// https://man7.org/linux/man-pages/man2/read.2.html
	"xor    eax, eax"       // rax = 0: sys_read; rdi is still 0 (stdin)
	"lea    rsi, [rsp+40]"  // rsi = address where the input byte will be stored
	"mov    edx, 1"         // rdx = 1: read at most one byte
	"syscall"
	// rax = bytes read, 0 on EOF, or a negative error number.
	"mov    r10d, -1"       // default function result for EOF/read error
	"cmp    eax, 1"         // did we read one byte?
	"jne    .restore"
	"movzx  r10d, byte [rsp+40]" // result = input byte, zero-extended to 0..255

	".restore:"
	"mov    [rsp+12], r8d"  // restore the original c_lflag in the buffer
	"mov    [rsp+22], r9w"  // restore the original VTIME/VMIN in the buffer
	"mov    eax, 16"        // rax = 16: sys_ioctl; rdi is still 0 (stdin)
	"mov    esi, 5402h"     // rsi = TCSETS: apply the original settings immediately
	"mov    rdx, rsp"       // rdx = address of the restored termios buffer
	"syscall"
	"mov    eax, r10d"      // return the saved result in rax (i16 uses its low 16 bits)
	"add    rsp, 48"        // release the stack buffer
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
