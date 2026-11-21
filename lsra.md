# Linear Scan Register Allocation

The example uses a function `foo` that takes one argument and returns no value.

```text
const a, 1
const b, 2
const c, 3
call foo[a]
call foo[b]
move t, a
add t, c
call foo[t]
call foo[c]
```

## Set up the calls

The calling convention says where to pass each argument, in a register or on the stack, and which registers a call may clobber.
In this example, `r1` holds the first argument, and a call can overwrite any of the four registers `r0` through `r3`.
On x86-64, the first argument in `r1` maps to RCX on Windows and RDI on Linux.

The preprocessor inserts a move into `r1` before each call.
This is called *precoloring*.
Instructions get even positions, leaving odd positions for extra moves.

```text
00  const a, 1
02  const b, 2
04  const c, 3
06  move a{r1}, a
08  call foo[a{r1}]
10  move b{r1}, b
12  call foo[b{r1}]
14  move t, a
16  add t, c
18  move t{r1}, t
20  call foo[t{r1}]
22  move c{r1}, c
24  call foo[c{r1}]
```

## Find the live ranges

The allocator reads the instructions backward to find where each value is live.
For example, `a` is written at 0, copied to the first call's argument register at 6, and read for the last time at 14.
In `[start, end)`, the last read can happen at `end`.
The two rows above each timeline show the tens and ones digits of the positions.
A `=` marks a live position, and a `.` marks a position outside the range.
`w` means write, `r` means read, and `x` means both.

```text
    0         1         2
    01234567890123456789012345
a:  w=====r=======r...........  [ 0, 14)  0w, 6r, 14r
b:  ..w=======r...............  [ 2, 10)  2w, 10r
c:  ....w===========r=====r...  [ 4, 22)  4w, 16r, 22r
t:  ..............w=x=r.......  [14, 18)  14w, 16x, 18r
```

The allocator also records *fixed ranges* for registers already claimed by instructions.
A `#` marks a position in a fixed range.
For the first call, `r1` is reserved from the argument move at 6 through the call at 8, and the other registers are clobbered at 8.

```text
    0         1         2
    01234567890123456789012345
r0: ........#...#.......#...#.  [8, 9)    [12, 13)    [20, 21)    [24, 25)
r1: ......###.###.....###.###.  [6, 9)    [10, 13)    [18, 21)    [22, 25)
r2: ........#...#.......#...#.  [8, 9)    [12, 13)    [20, 21)    [24, 25)
r3: ........#...#.......#...#.  [8, 9)    [12, 13)    [20, 21)    [24, 25)
```

## Assign registers and split ranges

The first pass tries all four registers.
The original intervals are `a0`, `b0`, `c0`, and `t0`, and each split gives the new piece the next number for its variable.
The allocator takes the pending piece with the earliest start and checks which registers are free there.
An active piece holds a register at the current position, and a `-1` means the register is already busy.
A piece is done once it ends or the allocator decides it will stay on the stack.

A register hint points to a register already named in a copy.
The allocator tries it first because putting the value there can remove that copy.
For example, reloading `b` straight into `r1` saves the copy into `r1` before the call.
The hint only works if the register is free for the whole piece.

With no usable hint, the allocator looks for an *exact fit*.
Suppose `r0` is free until 20 and `r2` is free until 10.
For a piece that ends at 10, `r2` fits exactly, leaving `r0` for a value that needs to stay in a register longer.
If the instruction at 10 copies the value into `r2`, that copy can disappear too.

With no exact fit, the allocator takes the lowest-numbered register that covers the whole piece.
Registers that calls may overwrite come first in the allocator's numbering.
Using one can avoid having to save and restore a register for the caller.

If no register fits, the one that stays free the longest gives the allocator the most room to choose a split.
The allocator uses the same selection order for the shorter piece.

```text
Active   empty
Pending  a0 b0 c0 t0
Done     empty
```

### `a0` at position 0

```text
Free until  r0=8  r1=6  r2=8  r3=8
```

The call at 8 can overwrite all four registers, and `a0` lasts until 14.
The last use before 8 is the argument copy at 6, so the allocator splits at 7.
The shorter piece needs a register free until 7.
`r1` is reserved starting at 6, so the allocator gives `a0` the next fitting choice, `r0`.
The remaining range `[7, 14)` can stay on the stack until just before the read at 14, so it splits again at 13.
Putting a value on the stack is called *spilling*.

```text
    0         1         2
    01234567890123456789012345
a0: w=====r...................  [ 0,  7)  r0       0w, 6r
a1: .......======.............  [ 7, 13)  stack
a2: .............=r...........  [13, 14)  pending  14r

Active   a0
Pending  b0 c0 a2 t0
Done     a1
```

### `b0` at position 2

```text
Free until  r0=-1  r1=6  r2=8  r3=8
```

Its only use before the call is the write at 2, so the allocator splits at 3.
`a0` holds `r0`, and the `r1` hint covers the shorter piece `[2, 3)`.
It splits the remaining range `[3, 10)` at 9 so `b` can stay on the stack until just before its argument copy at 10.

```text
    0         1         2
    01234567890123456789012345
b0: ..w.......................  [ 2,  3)  r1       2w
b1: ...======.................  [ 3,  9)  stack
b2: .........=r...............  [ 9, 10)  pending  10r

Active   a0 b0
Pending  c0 b2 a2 t0
Done     a1 b1
```

### `c0` at position 4

```text
Free until  r0=-1  r1=6  r2=8  r3=8
```

`b0` ended at 3, freeing `r1` while `a0` still holds `r0`.
The only use before the call at 8 is the write at 4, so the allocator splits at 5.
The `r1` hint fits `[4, 5)`.
It splits the remaining range `[5, 22)` at 15 to leave `c` on the stack until just before the add.

```text
    0         1         2
    01234567890123456789012345
c0: ....w.....................  [ 4,  5)  r1       4w
c1: .....==========...........  [ 5, 15)  stack
c2: ...............=r=====r...  [15, 22)  pending  16r, 22r

Active   a0 c0
Pending  b2 a2 t0 c2
Done     a1 b1 b0 c1
```

### `b2` at position 9

```text
Free until  r0=12  r1=10  r2=12  r3=12
```

The scan moves `a0` and `c0` to done because both ended before 9.
`b2` ends at 10, so its `r1` hint fits the whole range.
Reloading `b` directly into `r1` at 9 makes the argument copy at 10 unnecessary.

```text
    0         1         2
    01234567890123456789012345
b2: .........=r...............  [ 9, 10)  r1       10r

Active   b2
Pending  a2 t0 c2
Done     a1 b1 b0 c1 a0 c0
```

### `a2` at position 13

```text
Free until  r0=20  r1=18  r2=20  r3=20
```

`b2` ended at 10, and the second call has finished clobbering registers.
`a2` keeps the `r1` hint from `a0`, and `r1` is free long enough for the read at 14.
The allocator reloads `a` into `r1` at 13.

```text
    0         1         2
    01234567890123456789012345
a2: .............=r...........  [13, 14)  r1       14r

Active   a2
Pending  t0 c2
Done     a1 b1 b0 c1 a0 c0 b2
```

### `t0` at position 14

```text
Free until  r0=20  r1=18  r2=20  r3=20
```

`a2` ends at 14, so `t0` can take over `r1` as `a` is read for the last time.
`t0` has a hint for `r1` and lasts until 18, when the third call's argument needs that register.
Both `move t, a` at 14 and the argument copy at 18 become copies within `r1`, so both disappear.

```text
    0         1         2
    01234567890123456789012345
t0: ..............w=x=r.......  [14, 18)  r1       14w, 16x, 18r

Active   t0
Pending  c2
Done     a1 b1 b0 c1 a0 c0 b2 a2
```

### `c2` at position 15

```text
Free until  r0=20  r1=-1  r2=20  r3=20
```

`t0` holds `r1`, and the call at 20 can overwrite the other registers that `c2` could use.
Since `c` is needed again at 22, the allocator splits at 17, just after the add.
`r0` is the lowest-numbered register that covers `[15, 17)`, so the allocator reloads `c` into it at 15.
It splits the remaining range `[17, 22)` at 21 so `c` can stay on the stack until just before the final argument copy.

```text
    0         1         2
    01234567890123456789012345
c2: ...............=r.........  [15, 17)  r0       16r
c3: .................====.....  [17, 21)  stack
c4: .....................=r...  [21, 22)  pending  22r

Active   t0 c2
Pending  c4
Done     a1 b1 b0 c1 a0 c0 b2 a2 c3
```

### `c4` at position 21

```text
Free until  r0=24  r1=22  r2=24  r3=24
```

`t0` and `c2` have both ended, so the scan moves them to done.
The `r1` hint fits `c4` exactly, so the allocator reloads `c` into `r1` at 21 and drops the argument copy at 22.

```text
    0         1         2
    01234567890123456789012345
c4: .....................=r...  [21, 22)  r1       22r

Active   c4
Pending  empty
Done     a1 b1 b0 c1 a0 c0 b2 a2 c3 t0 c2
```

With the pending list empty, the scan moves `c4` to done.

### Scan again with a spill address register

The first pass found stack pieces for `a`, `b`, and `c`, so the allocator starts over from `a0`, `b0`, `c0`, and `t0`.
It sets `r3` aside for stack addresses, so the second pass uses the first three columns of each free-until line.
`r3` always tied with `r2` in the first pass, so both passes make the same choices.

```text
    0         1         2
    01234567890123456789012345
a0: w=====r...................  [ 0,  7)  r0       0w, 6r
a1: .......======.............  [ 7, 13)  stack
a2: .............=r...........  [13, 14)  r1       14r
b0: ..w.......................  [ 2,  3)  r1       2w
b1: ...======.................  [ 3,  9)  stack
b2: .........=r...............  [ 9, 10)  r1       10r
c0: ....w.....................  [ 4,  5)  r1       4w
c1: .....==========...........  [ 5, 15)  stack
c2: ...............=r.........  [15, 17)  r0       16r
c3: .................====.....  [17, 21)  stack
c4: .....................=r...  [21, 22)  r1       22r
t0: ..............w=x=r.......  [14, 18)  r1       14w, 16x, 18r
```

## Write the final instructions

The allocator inserts stores and loads at the split points where a value moves between a register and the stack.
For example, `a0` becomes `a1` at 7, so the allocator stores `a` there and loads it back when `a2` starts at 13.
Each spill or reload starts with `addrof`, which puts the stack address in `r3`.
The argument move for `a` at 6 copies it from `r0` to `r1`.
The other three argument moves disappear because those values already reach the calls in `r1`.

```text
00  const a{r0}, 1
02  const b{r1}, 2
03  addrof memVarAddr{r3}, b
03  store [memVarAddr{r3}], b{r1}
04  const c{r1}, 3
05  addrof memVarAddr{r3}, c
05  store [memVarAddr{r3}], c{r1}
06  move a{r1}, a{r0}
07  addrof memVarAddr{r3}, a
07  store [memVarAddr{r3}], a{r0}
08  call foo[a{r1}]
09  addrof memVarAddr{r3}, b
09  load b{r1}, [memVarAddr{r3}]
12  call foo[b{r1}]
13  addrof memVarAddr{r3}, a
13  load a{r1}, [memVarAddr{r3}]
15  addrof memVarAddr{r3}, c
15  load c{r0}, [memVarAddr{r3}]
16  add t{r1}, c{r0}
17  addrof memVarAddr{r3}, c
17  store [memVarAddr{r3}], c{r0}
20  call foo[t{r1}]
21  addrof memVarAddr{r3}, c
21  load c{r1}, [memVarAddr{r3}]
24  call foo[c{r1}]
```

## When all registers are busy

Suppose `x` needs a register from 4 to 6 and the two registers hold values that will next be read at 8 and 10.
The allocator can make room for `x` by spilling the value needed at 10, since that frees a register for longer.

## Across branches

If `x` is live over `[0, 4)` and `[10, 14)`, another value that lives over `[6, 8)` can share its register.
For example, one arm of an `if` can read `x` while the other returns without using it.

When two paths join, each may arrive with values in different registers.
Suppose one path leaves `a` in `r0` and `b` in `r1`, but the next block expects them swapped.
With `r2` free, the allocator inserts these moves on that path to save `a` before overwriting `r0`.

```text
move r2, r0
move r0, r1
move r1, r2
```

## Register pairs on Z8

On Z8, each register holds one byte, and a pointer needs two registers starting at an even index.
If a byte already occupies `r0`, the allocator can put the pointer in `r2` and `r3`.
Both registers must be free for the whole piece.
For an exact fit, the next conflict for each register must start at the piece's exclusive end.
The scan considers pairs through the last register.
