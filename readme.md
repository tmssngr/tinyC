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

## Constants

Constants can be defined globally using this syntax:

```
const NAME = 10 * 2;
```

The expression at the right must be fully interpretable at this point.
You can use other constants, a lot of unary or binary operations (but not all).

# Stages

A compiler works in multiple stages.

## Build the AST (abstract syntax tree).
The lexer (class `Lexer`) takes the input files and splits the character streams into tokens, e.g. `if` will become the if-token, `13` an integer literal, `"foo"` a string literal, `foo` an identifier, or `<=` an less-or-equal-token.
The parser will receive the stream of tokens and builds the AST.
The root object of the AST is `Program` which has children for type definitions (`TypeDef`), global variables, functions (`Function`) and string literals.
Each function has a name, return type, zero or more arguments and a list of statements (`Statement`).
Statements can be, e.g., control flow statements like `StmtIf` or `StmtLoop`, expression-statements or others (e.g. for `break`, `continue` or `return a`).
Control flow statements have nested statements, e.g. for the then- or else-branches, and expressions for the conditions.

In the next step a type checker (class `TypeChecker`) assigns types to the nodes of the AST, verifies the types (e.g. rejects multiplying two pointers) and adds autocasts where necessary.

### Variables
Variables are distinguished by global ones, local ones (defined within a function) and parameters.
We decided to refer to variables internally with a scope enum (`VariableScope`: `global`, `function` and `argument`) and an (integer) index.

## Build the IR (intermediate representation)
An intermediate representation is used as a flat list of instructions similar to a high-level assembly language.
Control flow statements are converted to label, conditional (`branch`) and unconditional (`jump`) jump instructions.
```
@printInt:                    // label
  const t2, 0                 // assign zero to variable "t2"
  lt t1, number, t2           // set the variable "t1" to true if the variable "number" has the same value as the variable "t2"
  branch t1, false, @if_3_end // if the variable "t1" is false, jump to the label "if_3_end"
  const t3, 45                // assign 45 to variable "t3"
  call _, printChar, t3       // call method "printChar", pass the content of variable "t3" as (first) argument, "_" means it has no return value
  neg number, number          // store the negated value of the variable "number" in the variable "number"
@if_3_end:                    // label
  call _, printUint, number   // call method "printUint", pass the content of variable "number" as (first) argument, expect no return value
```

## Control Flow Graph
For the simplest compiler a control flow graph (CFG) is not necessary, but it helps for performing optimizations like dead code removal, or for register allocation (mapping from the variables to the limited number of processor registers).

We look at each function separately and build a directed graph of *basic block*.
A basic block is a series of consecutive instructions that usually start with a label and end with a jump or branch.
Because each basic block starts with a unique label, we can use it to identify basic blocks.
Each basic block can have multiple predecessors (those basic blocks that jump to the current basic block) and successors (the target basic block(s) that are jumped to from the current basic block).

The summary of all these basic blocks of a function form the control flow graph of that function.

### Implementation
We are iterating over all instructions and create basic blocks after a branch or jump, or before a label.
Then we iterate the blocks in execution order starting with the first and proceeding with the next ones until all next blocks were already processed.
Those blocks which were not iterated now can be removed because they are dead code.

For the above instructions this will create following:
```
// no predecessors
@printInt:
  const t2, 0
  lt t1, number, t2
  branch t1, false, @if_3_end
  jump @if_3_then
// successors: @if_3_then, @if_3_end

// predecessor: @printInt
@if_3_then:
  const t3, 45
  call _, printChar, t3
  neg number, number
  jump @if_3_end
// successor: @if_3_end

// predecessor: @printInt, @if_3_then
@if_3_end:
  call _, printUint, number
// no successor
```

### Variable Liveness Analysis
For each basic block we are also performing the variable liveness analysis.
In other words, we remember for each instruction which variables are still *live* (will be required later).

This best is done in reverse order.
We start with the last block and assume, that no variable is needed after the last instruction.
Using the above example, we look at the last instruction `call _, printUint, number`.
This require the variable `number` to be live before this instruction.
As there is no live variable `number` already, we add it - and also remember it as last use.
The label instruction does not change anything on the live variables.
```
                            // live: number
@if_3_end:
                            // live: number
  call _, printUint, number // last use: number
                            // nothing live
```
No we need to look at the predecessor blocks.
Let's assume, we look first at the `@printInt` block and put the block `@if_3_then` on a stack, so we don't forget to look at it later.

The block `@printInt` has the successors `@if_3_then` and `@if_3_end`.
As we only have processed block `@if_3_end` yet, we know that it requires the variable `number`.
The `jump` instruction does not require any variable.
But the `branch` instruction requires the variable `t1` and it is the last use for it.
The `lt` instruction writes the variable `t1`, so it is not required before any more.
But it requires the variables `number` and `t2`.
As `number` is already in the list of live variables, we only add `t2` to it.
The `const` instruction writes the constant `0` to `t2`.
Hence it will be removed from the list of live variables:
```
                               // live: number
@printInt:
                               // live: number
  const t2, 0
                               // live: number, t2
  lt t1, number, t2            // last use: t2
                               // live: number, t1
  branch t1, false, @if_3_end  // last use: t1
                               // live: number
  jump @if_3_then
                               // live: number (from @if_3_end)
```
This block has no predecessors any more, so we can take the block `@if_3_then` from the stack.
It has the successor `@if_3_end` which requires the variable `number`.
The `neg` instruction writes the variable `number`, but also uses it, so it actually does not change anything on the live variables.
The `call` instruction requires the variable `t3` (also as last use).
The `const` instruction writes `t3`, so we can remove it from the list of live variable.
```
                               // live: number
@if_3_then:
                               // live: number
  const t3, 45
                               // live: number, t3
  call _, printChar, t3        // last use: t3
                               // live: number
  neg number, number
                               // live: number
  jump @if_3_end
                               // live: number (from @if_3_end)
```
The predecessor of the `@if_3_then` block is block `@printInt`.
Because the live variables from the blocks `@if_3_then` and `@if_3_end` (the successors of block `@printInt`) are the same, we don't need to process the block `@printInt` again.

## Register Allocation
Register allocation means which variable to store in what processor register or whether/when to keep in memory.
A extremely simple register allocation would be to store all variables in memory and only load them when needed by a IR instruction.
Of course, this would be very inefficient, e.g. `const t2, 0` from the above example would store the value `0` in the variable `t2` (in memory)
  while the next instruction `lt t1, number, t2` would already need it again, hence loading from memory.

### Linear Register Allocation
The Linear Register Allocation is easy to understand, fast (linear) and though produces good results.
The idea of the Linear Register Allocation is to "cache" values in registers when they are needed.

For implementing it, we need to extend the *variable* represenation by a new `register` scope.

If a variable `number` is needed in a register `r.0`, it is loaded into a register (`number` means the stack location for the variable of this name):
```
  mov r.0, number
```

#### Example

That best could be explained with an example:
```
mov x, 0            ; 1
mov y, 1            ; 2
a = foo(x, y)       ; 3
b = bar(y, x)       ; 4
bazz(a, b)          ; 5
```

For our example we assume following calling convention:
- the first four call arguments are passed in registers `r.1`, `r.2`, `r.3` and `r.4`
- more arguments are passed on the stack
- a function return value is stored in register `r.0`
- the registers `r.0` to `r.4` are considered volatile; a called function might clobber them
- but we have three additional non-volatile registers `r.5`, `r.6` and `r.7` (which we refer to in the below examples as `rnv.1`, `rnv.2` and `rnv.3`) that a function needs to save before using them (and restore later), so from the callee's perspective they remain unmodified

We start with the last line 5.
It needs (*uses*) variables `a` and `b` in registers `r.1` and `r.2` because they are the first and second call argument:
```
...
b = bar(y, x)       ; 4
...
; a = r.1, b = r.2
bazz(a, b)          ; 5
```
Now we are looking at line 4 and compare it with the expected registers for line 5.
Line 4 writes variable `b` which according to the calling convention is returned in register `r.0`;
Hence we need to move it from register `r.0` to register `r.2` where it is expected for line 5.
```
...
b = bar(y, x)       ; 4
...
; a = r.1, b = r.0
mov r.2, r.0
; a = r.1, b = r.2
bazz(a, b)          ; 5
```
The variable `a` is expected in register `r.1`, but because this is a volatile register this might be clobbered by the call in line 4.
Hence we need to store it in a non-volatile register, let's use the first one `rnv.1`.
```
...
b = bar(y, x)       ; 4
; a = rnv.1, b = r.0
mov r.1, rnv.1
; a = r.1, b = r.0
mov r.2, r.0
; a = r.1, b = r.2
bazz(a, b)          ; 5
```
Now we can look at where we expect the used variables for line 4.
Variable `a` is written in line 3, so it is stored in `r.0`, but it is expected in the non-volatile register `rnv.1`, so a move is required, freeing `rnv.1`.
```
...
a = foo(x, y)       ; 3
...
; a = r.0, y = r.1, x = r.2
mov rnv.1, r.0
; a = rnv.1, y = r.1, x = r.2
b = bar(y, x)       ; 4
...
```
As the call to `foo` might clobber the registers `r.1` and `r.2` where the variables `y` and `x` are stored, we have to store them in non-volatile registers instead.
```
...
a = foo(x, y)       ; 3
; a = r.0, y = rnv.1, x = rnv.2
mov r.2, rnv.2
; a = r.0, y = rnv.1, x = r.2
mov r.1, rnv.1
; a = r.0, y = r.1, x = r.2
mov rnv.1, r.0
; a = rnv.1, y = r.1, x = r.2
b = bar(y, x)       ; 4
...
```
Now let's look at the arguments for the call to `foo` in line 3.
The first argument (`x`) is expected in register `r.1`, but the next instruction expects it in register `rnv.2`.
This requires to store variable `x` in the two registers `r.1` and `rnv.2` which is easily done with a move from one to another.
We have the choice for where the variable `x` being stored *before* line 3 - either in `r.1` or in `rnv.2`.
We prefer the volatile register `r.1`:
```
...
; y = r.2/rnv.1, x = r.1
mov rnv.2, r.1
; y = r.2/rnv.1, x = r.1/rnv.2
a = foo(x, y)       ; 3
; a = r.0, y = rnv.1, x = rnv.2
...
```
Similar we proceed with variable `y`:
```
...
; y = r.2, x = r.1
mov rnv.1, r.2
; y = r.2/rnv.1, x = r.1
mov rnv.2, r.1
; y = r.2/rnv.1, x = r.1/rnv.2
a = foo(x, y)       ; 3
; a = r.0, y = rnv.1, x = rnv.2
...
```
Now the lines 2 and 1 are very easy, so here is the full list of instructions:
```
mov r.1, 0          ; 1
; x = r.1
mov r.2, 1          ; 2
; y = r.2, x = r.1
mov rnv.1, r.2
mov rnv.2, r.1
a = foo(x, y)       ; 3
; a = r.0, y = rnv.1, x = rnv.2
mov r.2, rnv.2
; a = r.0, y = rnv.1, x = r.2
mov r.1, rnv.1
; a = r.0, y = r.1, x = r.2
mov rnv.1, r.0
; a = rnv.1, y = r.1, x = r.2
b = bar(y, x)       ; 4
; a = rnv.1, b = r.0
mov r.1, rnv.1
; a = r.1, b = r.0
mov r.2, r.0
; a = r.1, b = r.2
bazz(a, b)          ; 5
```
If this would be the full code of a function `qux` (not just one basic block), we would have to push the used non-volatile registers and pop them before the return:
```
qux:
	push rnv.1
	push rnv.2
	mov r.1, 0
	mov r.2, 1
	mov rnv.1, r.2
	mov rnv.2, r.1
	call foo
	mov r.2, rnv.2
	mov r.1, rnv.1
	mov rnv.1, r.0
	call bar
	mov r.1, rnv.1
	mov r.2, r.0
	call bazz
	pop rnv.2
	pop rnv.1
	ret
```


#### Variables addressed with pointers

In a previous step we have remembered all variables for which the address is requested (`&foo`).
Those might be read or written indirectly through their address.
To prevent their cached register values from their memory values, we only keep them in registers until a memory address is read or written.


## Convert to ASM
The IR can be converted to different assembler outputs.
