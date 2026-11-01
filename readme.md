# TinyC

This is an experimental, not-ready-to-use compiler implemented in Java that parses a language loosely similar to a simplified version of C with syntax inspirations from Go.
It is not meant to be a serious alternative to any mature compiler, but a hobby project for learning compiler techniques.
The main goal is to have a compiler for a language slightly higher-level than assembly for an old 8-bit machine (using a [Z8 microcontroller](https://en.wikipedia.org/wiki/Zilog_Z8)).

For the Z8 target it produces assembly code to feed into [Z8Asm](https://github.com/tmssngr/z8asm).
For easier testing, it also compiles to **x86_64 binaries for both Windows and Linux** using the [FASM assembler](http://flatassembler.net/).
The Z8 is the intended target; the x86_64 backends prioritize simplicity over performance.

## Assembler

Functions can be implemented in platform-specific assembly by adding `asm` after the parameter list.
Each assembly instruction is provided as a string literal in the function body and is emitted literally in the generated assembly file.
These functions must follow the target's calling convention, preserve its nonvolatile registers and include their own return instruction.
The compiler does not generate a prologue or epilogue for `asm` functions.

### Windows Example

This example uses the `hStdOut` and `WriteFile` symbols provided by the Windows backend.
It reserves shadow space, a fifth argument and storage for the bytes-written result, while keeping the stack aligned for the API call.

```c
void printStringLength(u8* str, i64 length) asm {
	// rsp+0    return address
	// rsp+8h   start of caller-provided 20h-byte shadow space
	// rsp is 8 modulo 10h at function entry
	// rcx      str
	// rdx      length
	// BOOL WriteFile(
	//  [in]                HANDLE       hFile,                    rcx
	//  [in]                LPCVOID      lpBuffer,                 rdx
	//  [in]                DWORD        nNumberOfBytesToWrite,    r8
	//  [out, optional]     LPDWORD      lpNumberOfBytesWritten,   r9
	//  [in, out, optional] LPOVERLAPPED lpOverlapped              stack
	// );
	"sub     rsp, 38h"
	"mov     r8d, edx"
	"mov     rdx, rcx"
	"mov     rcx, [hStdOut]"
	"lea     r9, [rsp+28h]"
	"mov     qword [rsp+20h], 0"
	"call    [WriteFile]"
	"add     rsp, 38h"
	"ret"
}
```

### Linux Example

This function receives arguments using the System V AMD64 calling convention and rearranges them for the Linux `write` syscall.

```c
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
    a = b
}

for u8 i = 0; i < 10; i += 1 {
    a += i
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

TinyC supports the following targets:

| Platform | Architecture | Calling Convention | Output Format    | File Extension  | Predefined Conditional Symbols |
|----------|--------------|--------------------|------------------|-----------------|--------------------------------|
| Z8       | Z8           | TinyC-specific     | Assembly         | `.asm`          | `Z8`, `__Z8`                   |
| Windows  | x86_64       | Microsoft x64      | PE64 console     | `.exe`          | `X86_64`, `__WINDOWS`          |
| Linux    | x86_64       | System V AMD64     | ELF64 executable | `.bin`          | `X86_64`, `__LINUX`            |

The compiler emits assembly into `z8/`, `windows/` and `linux/` directories next to the input file.
It then runs **FASM** (Flat Assembler) for the host x86_64 platform: Windows produces an `.exe`, and Linux produces a `.bin`.
Z8 assembly is left for Z8Asm to assemble separately.
The Windows backend supplies imports from the Windows API and C runtime, including `WriteFile`, `GetStdHandle` and `_getch`.
The Linux backend uses the `exit` syscall, and the Linux assembly example above uses `write` for output.

Rudimentary runtime helpers are provided under [`src/main/resources-test/compiler`](src/main/resources-test/compiler):

- `win_x86_64.h` — Windows API and C runtime calls for console I/O
- `linux_x86_64.h` — Linux `write` wrapper; `getChar` and `setCursor` still contain Windows-specific code
- `z8.h` — Z8 helpers for the intended machine

`io.h` selects the target header using the predefined conditional symbols.

## Compiler internals

See [internals.md](internals.md)
