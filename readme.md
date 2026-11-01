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

## Stages

A compiler works in multiple stages.

### Build the AST (abstract syntax tree)

The lexer (class `Lexer`) takes the input files and splits the character streams into tokens, e.g. `if` will become the if-token, `13` an integer literal, `"foo"` a string literal, `foo` an identifier, or `<=` a less-than-or-equal token.
The parser receives the stream of tokens and builds the AST.
The root object of the AST is `Program` which has children for type definitions (`TypeDef`), global variables, functions (`Function`) and string literals.
Each function has a name, return type, zero or more arguments and a list of statements (`Statement`).
Statements can be, e.g., control flow statements like `StmtIf` or `StmtLoop`, expression-statements or others (e.g. for `break`, `continue` or `return a`).
Control flow statements have nested statements, e.g. for the then- or else-branches, and expressions for the conditions.

In the next step a type checker (class `TypeChecker`) assigns types to the nodes of the AST, verifies the types (e.g. rejects multiplying two pointers) and inserts implicit casts where permitted.

#### Variables

Variables are divided into global variables, local variables (defined within a function) and parameters.
Internally, a variable has a scope (`VariableScope`: `global`, `function` or `parameter`) and an integer index, as well as its name and type.
The IR also uses the `register` scope for assigned or constrained registers.

### Build the IR (intermediate representation)

An intermediate representation is used as a flat list of instructions similar to a high-level assembly language.
Control flow statements are converted to labels, conditional branches (`branch`) and unconditional jumps (`jump`).
The following illustrative fragment shows the IR syntax.
Internal function names include parameter-type suffixes, such as `printInt@i64`.
A `branch` instruction lists its comparison, the target when it is true, and the target when it is false.

```text
printInt@i64:                                // function entry
  const t2, 0                                // t2 = 0
  branch number gteq t2: if_3_end, if_3_then // skip the minus sign if number >= 0
if_3_then:
  const t3, 45                               // t3 = '-' (45)
  call printChar@u8[t3]                      // print the minus sign
  neg number, number                         // number = -number
if_3_end:                                    // label
  call printUint@i64[number]                 // print the magnitude
```

### Control Flow Graph

A control flow graph (CFG) supports optimizations such as unreachable-code removal and is used for detecting variable liveness.
It can also support register allocation (mapping variables to the limited number of processor registers).

We look at each function separately and build a directed graph of *basic blocks*.
A basic block is a sequence of instructions with a single entry point and no internal control-flow splits.
In this implementation, each block has a unique name; labels identify block boundaries but are not stored as instructions inside a block.
Blocks with successors end with a `jump` or with a `branch` followed by a `jump` for the other path.
Each basic block can have multiple predecessors (those basic blocks that jump to the current basic block) and successors (the target basic block(s) that are jumped to from the current basic block).

Together, these blocks and their edges form the control flow graph of the function.

#### Implementation

We split the instruction list at labels and after branches or jumps, adding explicit jumps for fall-through paths.
Starting at the entry block, we follow successor edges to identify reachable blocks.
Unreachable blocks can be discarded.

The compiler also splits critical edges: edges from a block with multiple successors to a block with multiple predecessors.
An intermediate block on each such edge makes it possible to insert copies for SSA phi nodes later.

Before critical-edge splitting, the fragment above has the following block structure.
The labels below stand for block names:

```text
// no predecessors
printInt@i64:
  const t2, 0
  branch number gteq t2: if_3_end, if_3_then
  jump if_3_then
// successors: if_3_then, if_3_end

// predecessor: printInt@i64
if_3_then:
  const t3, 45
  call printChar@u8[t3]
  neg number, number
  jump if_3_end
// successor: if_3_end

// predecessor: printInt@i64, if_3_then
if_3_end:
  call printUint@i64[number]
// no successor
```

#### Variable Liveness Analysis

Variable liveness analysis records which variables' current values may be read later, before being overwritten.
It works in reverse order of the instructions (starting with the last instruction).
A block's live-out set is the union of its successors' live-in sets.
For each instruction, we remove the variables it defines and add the variables it reads.
We repeat this analysis until the live sets stop changing, which also handles loops.
Address-taken local variables are conservatively kept live at block boundaries to account for indirect accesses.

For clarity, the liveness walkthrough below uses the three-block graph above, before critical-edge splitting and SSA conversion.

For this example, no variable is needed after the last instruction of the exit block.
Using the above example, we look at the last instruction `call printUint@i64[number]`.
This requires the variable `number` to be live before this instruction.
We add `number` to the live set; this instruction is its last use on this path.
The block label does not change the live set.

```text
                                             // live: number
if_3_end:
                                             // live: number
  call printUint@i64[number]                 // last use: number
                                             // nothing live
```

Now we look at the predecessor blocks.
For this walkthrough, we look first at the `printInt@i64` block and put the block `if_3_then` on a stack, so we don't forget to look at it later.

The block `printInt@i64` has the successors `if_3_then` and `if_3_end`.
We have processed only `if_3_end` so far, so we use its live-in set, containing `number`, for this first pass.
The `jump` instruction does not require any variable.
But the `branch` instruction requires the variables `number` and `t2`.
As `number` is already in the set of live variables, we only add `t2` to it.
The `const` instruction writes the constant `0` to `t2`.
Hence `t2` will be removed from the list of live variables:

```text
                                             // live: number
printInt@i64:
                                             // live: number
  const t2, 0
                                             // live: number, t2
  branch number gteq t2: if_3_end, if_3_then // last use: t2
                                             // live: number
  jump if_3_then
                                             // live: number (from if_3_end)
```

This block has no predecessors, so we can take the block `if_3_then` from the stack.
It has the successor `if_3_end` which requires the variable `number`.
The `neg` instruction writes the variable `number`, but also uses it, so it actually does not change the live set.
The `call` instruction requires the variable `t3` (also as last use).
The `const` instruction writes `t3`, so we can remove it from the list of live variables.

```text
                                             // live: number
if_3_then:
                                             // live: number
  const t3, 45
                                             // live: number, t3
  call printChar@u8[t3]                      // last use: t3
                                             // live: number
  neg number, number
                                             // live: number
  jump if_3_end
                                             // live: number (from if_3_end)
```

The predecessor of the `if_3_then` block is block `printInt@i64`.
Because the live variables from the blocks `if_3_then` and `if_3_end` (the successors of block `printInt@i64`) are the same, the live-in set for `printInt@i64` does not change when we account for both successors.
The implementation scans the blocks in reverse order repeatedly until no live set changes.

### SSA and IR preparation

`SsaFactory` converts eligible variables into static single assignment (SSA) form: each new value gets a distinct variable name.
Phi nodes at joins select the value arriving from each predecessor.
Variables whose addresses are taken remain in memory and are excluded from this renaming.
`IRConverter` prepares binary operations for the backends' two-operand form.
`PhiElimination` then replaces phi nodes with copies in predecessor blocks, and `RemoveNotLiveResults` removes instructions that produce unused values.
Calls are retained for their possible side effects even when their return values are unused.
The resulting IR is passed to register allocation, followed by IR optimization and cleanup of unused local variables.

### Register Allocation

Register allocation assigns live values to processor registers and spills them to memory when necessary.
`LSRegAlloc` uses linear-scan register allocation across a whole function. Values can remain in registers across basic-block boundaries.

#### Linear-scan register allocation

`LSPreprocessor` introduces the register constraints required by the calling convention and, on x86_64, instructions such as division and shifts.
`LSIntervalFactory` builds live intervals from the control flow graph and variable liveness, including fixed intervals for registers required or clobbered by instructions.
`LSAlgorithm` scans intervals in start-position order, assigning registers, splitting intervals and spilling values when registers are unavailable.
On Z8, values can occupy several consecutive byte registers, and pointers require an even-numbered register pair.

`LSRegAlloc` rewrites operands to use the assigned registers and inserts moves, loads and stores for spills and changes of location.
Moves on control-flow edges reconcile the locations assigned in predecessor and successor blocks; `LSParallelMove` resolves conflicting transfers.
Register operands use `VariableScope.register` and print as `r0`, `r1`, etc., or as `name{r0}` when variable names are included.
For example, a register-to-register copy uses the `move` instruction:

```text
  move r0, r1
```

The register indices are mapped to physical registers by the target backend. More detail is available in [lsra.md](lsra.md).

#### Variables addressed with pointers

Variables whose addresses are taken (`&foo`) keep memory locations and are excluded from register allocation.
The IR uses explicit address, load and store instructions for these accesses, so indirect writes cannot leave a cached variable value out of date.

#### Calls

Calling-convention constraints place arguments and results in the required registers or stack locations.
Fixed intervals account for registers clobbered by calls. Values live across a call can remain in nonvolatile registers or be spilled and reloaded as needed.
The assembly backends generate the required saves and restores for nonvolatile registers used by ordinary compiled functions.

### Convert to ASM

The target-specific assembly writer translates the allocated IR into assembly: `Z8AsmWriter`, `X86_64_WindowsAsmWriter` or `X86_64_LinuxAsmWriter`.
FASM assembles the host's x86_64 output into an executable; the Z8 output is assembly source for Z8Asm.
