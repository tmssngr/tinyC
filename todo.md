# Already implemented
- char literals, including escape sequences
- structs
- implement some API already in language (printString, printUint, printChar)
- ability to define API as ASM which is tunneled through to the ASM output literally

# Pending features
- labeled (nested) loops (break/continue with label)
- composites
	- unions
- array initialization (size derived from count of expressions), e.g. `u8 s[] = { 1, 2, 3 };`
- switch statement
- `++var` and `var++`
- `+=` and derivates
- null pointer
- sizeof
- static local variables (global variable only visible inside specific method)
- ternary operator
- pointer to functions
- spill registers
- x86_64 calling convention
- optimizations
	- pre-calculate constants, e.g. `foo = 4 * 5 + 1;`
- nice-to-have features
	- enums, e.g. `enum foo { int_lit, identifier, plus };`
	- `final` variables
	- defer statement
	- Gleam-like module support (naming scope): https://tour.gleam.run/basics/modules/

# Calling a function

## IR

One goal for me is that the IR remains independent of the used platform or the used calling convention.
Hence, all details needs to be handled in the backend.
The IR only should provide enough information so the backend can access the passed values.
The simplest way would be to always use a (local) variable that contains the call parameter value.
In the future we could support constants or global variables, too.

The backend also needs to know into which register the IR expects a possible return value.
If the method does not return a value, `resultReg` and `resultSize` could be zero.
```
  IRCall(List<IRCallArg> arguments, int resultReg, int resultSize)

  IRCallArg(int value, int size)
```

## Backend

There are 2 tasks: storing the arguments in the calling code in the registers or on the stack, and accessing these arguments in the called function.

The Windows x86_64 C ABI calling convention defines to pass the first four arguments in registers `RCX`, `RDX`, `R8` and `R9` while the remaining (fifth, sixth, ...) arguments are passed on the stack, pushed in right-to-left order.
The result will be passed in `RAX`.

If the called function receives the arguments in registers, it might be necessary to store them in additional local variables.
Hence, it might be a good idea to start very simple, e.g., by pushing **all** arguments to the stack in left-to-right order.
We could also simplify even more by pushing always 8 bytes, so we do not have to think about alignment.
