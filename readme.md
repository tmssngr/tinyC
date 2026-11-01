# TinyC

This is an experimental, not-ready-to-use compiler implemented in Java that parses a language loosely similar to a simplified version of C with syntax inspirations from Go.
It is not meant to be a serious alternative to any mature compiler, but a hobby project for learning compiler techniques.
The main goal is to have a compiler for a language slightly higher-level than assembly for an old 8-bit machine (using a [Z8 microcontroller](https://en.wikipedia.org/wiki/Zilog_Z8)).

For easier testing, it currently compiles to **x86_64 binaries for both Windows and Linux** using the [FASM assembler](http://flatassembler.net/).
The Z8 is the intended target; the currently implemented x86_64 backend prioritizes simplicity over performance.

## Assembler

Functions can be implemented in platform-specific assembly by adding `asm` after the parameter list.
Each assembly instruction is provided as a string literal in the function body and is emitted literally in the generated assembly file.
These functions must follow the target's calling convention, preserve its nonvolatile registers and include their own return instruction.
The compiler does not generate a prologue or epilogue for `asm` functions.

### Windows Example

This example uses the `hStdOut` and `WriteFile` symbols provided by the Windows backend.

```
void printStringLength(u8* str, i64 length) asm {
	// rsp+0    return address
	// rsp+8    padding (rsp is 8 modulo 10h at function entry)
	// rcx      str
	// rdx      length
	// BOOL WriteFile(
	//  [in]                HANDLE       hFile,                    rcx
	//  [in]                LPCVOID      lpBuffer,                 rdx
	//  [in]                DWORD        nNumberOfBytesToWrite,    r8
	//  [out, optional]     LPDWORD      lpNumberOfBytesWritten,   r9
	//  [in, out, optional] LPOVERLAPPED lpOverlapped              stack
	// );
	"mov     rdi, rsp"
	""
	"mov     r8, rdx"
	"mov     rdx, rcx"
	"lea     rcx, [hStdOut]"
	"mov     rcx, [rcx]"
	"xor     r9, r9"
	"push    0"
	"sub     rsp, 20h"
	"  call    [WriteFile]"
	"mov     rsp, rdi"
	"ret"
}
```

### Linux Example
```
void printStringLength(u8* str, i64 length) asm {
	// rdi      str
	// rsi      length
	// sys_write(1, str, length)
	"mov rdx, rsi"
	"mov rsi, rdi"
	"mov rdi, 1"    // stdout
	"mov rax, 1"    // sys_write
	"syscall"
	"ret"
}
```

## Syntax

TinyC uses the file extension `.tc`.
The syntax combines elements of C and Go.

Variables and function parameters are declared as in C.
A line break can replace a statement's trailing semicolon:

```c
u8 twoTimes(u8 a) {
    u8 c = a * 2
    return c
}
```

Parentheses around the clauses of a `for` loop and the conditions of `if` and `while` statements are optional, but braces around their bodies are required.
The two semicolons separating the clauses of a `for` loop are required:

```c
if a < b {
    // ...
}

for u8 i = 0; i < 10; i += 1 {
    // ...
}
```

The built-in value types are:

- `bool` — Boolean values (`true` and `false`)
- `u8` — unsigned 8-bit integer
- `i16`, `i32` and `i64` — signed 16-, 32- and 64-bit integers

Functions can also return `void`.
Pointers, arrays and user-defined struct types are supported.

Pre/post-increment/decrement expressions (e.g. `++i` or `i++`) are not supported, but compound assignment operators (e.g. `+=`) can be used instead.

`a = b` is an assignment statement, not an expression.

Casts are done using the `as` keyword: `u8 a = i16Number as u8` and bind more tightly than binary arithmetic operators.
If the type is a pointer, you need to add surrounding parentheses: `ptr = anotherPtr as (u8*)`.

Constants can be defined globally using this syntax (the semicolon is optional):

```c
const NAME = 10 * 2;
```

The expression on the right must be evaluable at compile time.
Constants are resolved while parsing.
Supported expressions include integer and Boolean literals, previously defined constants, unary and binary operators.

Functions can be overloaded.
The argument types for invocation of overloaded functions must match exactly.
For a function with a single signature, integer literals are implicitly converted to the parameter types if their values fit.
Other integer conversions require an explicit cast:

```c
void nonOverloaded(i16 a) {
}

void overloaded(u8 a, u8 b) {
}

void overloaded(i16 a, u8 b) {
}

void foo() {
    // ...
    nonOverloaded(10)
    // ...
    overloaded(10 as i16, 'x')
    // ...
}
```

## Platform Support

TinyC supports following architectures:

| Platform | Architecture | Calling Convention | Output Format    | File Extension  | Predefined Conditional Symbols |
|----------|--------------|--------------------|------------------|-----------------|--------------------------------|
| Windows  | x86_64       | Microsoft x64      | PE64 console     | `.exe`          | `X86_64`, `__WINDOWS`          |
| Linux    | x86_64       | System V AMD64     | ELF64 executable | `.bin`          | `X86_64`, `__LINUX`            |

The compiler uses **FASM** (Flat Assembler) for both platforms.
On Windows, it generates code that calls Win32 API functions (e.g., `WriteFile`, `GetStdHandle`, `_getch`).
On Linux, it uses direct system calls (e.g., `sys_write`, `sys_read`, `sys_ioctl`) for terminal I/O.

Extremely rudimentary platform-specific runtime functions are provided in header files:
- `win_x86_64.h` — Windows system calls and console I/O
- `linux_x86_64.h` — Linux system calls


## Compiler internals

See [internals.md](internals.md)
