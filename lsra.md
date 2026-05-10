- todo:
  - if a variable is set early, e.g. a function parameter, but used (read) very late only,
    it makes sense to spill it (AKA, handle it later than other intervals with earlier usages);
    otherwise this interval occupies a (non-volatile) register for a very long time without use
    Example: CompilerTest.testCall, variable/interval e in doPrint()


# Linear Scan Register Allocation

To better explain, we will use following example IR program:

```
mov a, #1
mov b, #2
mov c, #3
call foo(a)
call foo(b)
mov t, a
add t, c
call foo(t)
call foo(c)
```

For simplicity we assume that all operations need their values in registers.

## Precoloring

We begin by adding physical register constraints implied by the processor architecture and calling convention, e.g. the Windows x86_64 calling convention requires the first 4 arguments of a function call in registers RCX, RDX, R8 and R9 which we model here as r1 to r4, and the functional call result in RAX which we model her as r0.
For our example though we only will use registers r0 to r2 for simplicity.
This step is called *precoloring* in the literature.

The instructions are given in a sequence (list).
To determine the live ranges in the next step, we use indices to ease the definition of the live ranges.
For also being able to denote the positions between two instructions we use a two-step counting.
Later we will insert move commands there.
Our precolored example with positions will look so:

```
00:  mov a, #1
02:  mov b, #2
04:  mov c, #3
06:  mov r1, a
08:  call foo(r1)
10:  mov r1, b
12:  call foo(r1)
14:  mov t, a
16:  add t, c
18:  mov r1, t
20:  call foo(r1)
22:  mov r1, c
24:  call foo(r1)
```

## Generating Live-Intervals
Now we are generating the live intervals, naming each interval after the variable and append a zero.
These live intervals contain the live-ranges and also the usage positionsn (`r` means read, `w` write, `x` read and write of the same register):

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
a0: w=====r=======r...........  [ 0, 14); usages: 0w, 6r, 14r
b0: ..w=======r...............  [ 2, 10); usages: 2w, 10r
c0: ....w===========r=====r...  [ 4, 22); usages: 4w, 16r, 22r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
```

The calling convention defines, that during function calls (some) registers will not be preserved (the get "clobbered"), so they can't be used to store values at these positions.
These intervals are called *fixed* intervals in the literature, and form hard boundaries at what positions registers can't be used to store values:
We don't need to remember usages.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
r0: ........=...=.......=...=.  [8, 9), [12, 13), [20, 21), [24, 25)
r1: ......===.===.....===.===.  [6, 9), [10, 13), [18, 21), [22, 25)
r2: ........=...=.......=...=.  [8, 9), [12, 13), [20, 21), [24, 25)
```

## Iterating over Live-Intervals
### Interval `a0`
We start with the first interval `a0`.
Using the fixed intervals we determine until which position each register is free:

```
            r0  r1  r2
free until:  8   6   8
```

The interval `a0` ends at position 14, but no register is longer free than until position 8.
Hence the variable `a` can't be part of one register for its whole live-time and we need to split the interval.
We select the (first) register with the highest free position - `r0` - and assign it to the current interval `a0`.
We truncate that interval before 8, meaning at the odd position 7, and split off the remaining part as a new interval `a1`:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
a1: .......=======r...........  [ 7, 14); usages: 14r
```
This means that from position 0 to position 7 the variable `a` will be stored in register `r0` and at position 7 a `store <memory-address-of-var-a>, r0` has to be inserted.
The split-off interval `a1` has its first usage at position 14, so before we can use it (in a register), we need to load it back from memory into a register.
Hence we split `a1` again at position 13, creating a new interval `a2`:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
a1: .......======.............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r
```

We store the current interval (`a0`) in the *active* list.
The usage-free interval `a1` is moved to the *done* list.
The interval `a2` will be sorted into the *pending* list between the intervals `c0` and `t0` (by sorting for the interval starting positions).

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0

pending:
b0: ..w=======r...............  [ 2, 10); usages: 2w, 10r
c0: ....w===========r=====r...  [ 4, 22); usages: 4w, 16r, 22r
a2: .............=r...........  [13, 14); usages: 14r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r

done:
a1: .......======.............  [ 7, 13); usages: none
```

### Interval `b0`
Now we pick the next pending interval `b0` which starts at position 2.
From the fixed intervals and the *active* intervals we determine our free-until information.
Because register `r0` is already occupied by the active interval `a0` it is not free, indicated by the value -1:

```
            r0  r1  r2
free until: -1   6   8
```

The current interval `b0` ends at position 10 but again the longest free register `r2` is only free until position 8.
Hence the current interval `b0` is assigned the register `r2`, and needs to be split also before position 8, creating interval `b1`.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
b0: ..w====...................  [ 2,  7); usages: 2w         r2
b1: .......===r...............  [ 7, 10); usages: 10r
```

The first usage of `b1` is at position 10, so before being able to use it in a register again, we have to split it at position 9.
This creates interval `b2`:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
b0: ..w====...................  [ 2,  7); usages: 2w         r2
b1: .......==.................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r
```

We move interval `b0` into the active list, too.
Interval `b1` is moved to the done list, and we sort interval `b2` after `a1` into the pending list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
b0: ..w====...................  [ 2,  7); usages: 2w         r2

pending:
c0: ....w===========r=====r...  [ 4, 22); usages: 4w, 16r, 22r
b2: .........=r...............  [ 9, 10); usages: 10r
a2: .............=r...........  [13, 14); usages: 14r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r

done:
a1: .......======.............  [ 7, 13); usages: none
b1: .......==.................  [ 7,  9); usages: none
```

### Interval `c0`
Now we pick interval `c0` which starts at position 4.
From the fixed intervals and the *active* intervals we determine our free-until information.
Because registers `r0` and `r2` are already occupied by intervals `a0` and `b0` they are not free:

```
            r0  r1  r2
free until: -1   6  -1
```

The current interval `c0` ends at position 22 but again the longest free register `r1` is only free until position 6.
Hence the current interval `c0` is assigned the register `r1`, and needs to be split before position 6, creating interval `c1`.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c0: ....w.....................  [ 4,  5); usages: 4w         r1
c1: .....===========r=====r...  [ 5, 22); usages: 16r, 22r
```

The first use of interval `c1` is at position 16, so we split it again at position 15:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c0: ....w.....................  [ 4,  5); usages: 4w         r1
c1: .....==========...........  [ 5, 15); usages: none
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r
```

We move interval `c0` into the active list, interval `c1` to the done list, and sort interval `c2` at the end of the pending list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
b0: ..w====...................  [ 2,  7); usages: 2w         r2
c0: ....w.....................  [ 4,  5); usages: 4w         r1

pending:
b2: .........=r...............  [ 9, 10); usages: 10r
a2: .............=r...........  [13, 14); usages: 14r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a1: .......======.............  [ 7, 13); usages: none
b1: .......==.................  [ 7,  9); usages: none
c1: .....==========...........  [ 5, 15); usages: none
```

### Interval `b2`
We pick interval `b2` which starts at position 9.
This will expire intervals `a0`, `b0` and `c0` which ended before position 9, so we move them from the active to the done list.
From the fixed intervals and the (currently empty list of) active intervals we determine our free-until information.
As we are immediately after the first function call, all registers are free again until position 10 or 12:

```
            r0  r1  r2
free until: 12  10  12
```

Interval `b2` ends at position 10, and one register (`r1`) is free until position 10.
So we assign this register to the current interval and move the latter to the active list.
This is a tiny optimization to reduce the number of moves.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
b2: .........=r...............  [ 9, 10); usages: 10r        r1

pending:
a2: .............=r...........  [13, 14); usages: 14r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
a1: .......======.............  [ 7, 13); usages: none
b0: ..w====...................  [ 2,  7); usages: 2w         r2
b1: .......==.................  [ 7,  9); usages: none
c0: ....w.....................  [ 4,  5); usages: 4w         r1
c1: .....==========...........  [ 5, 15); usages: none
```

### Interval `a2`
We pick interval `a2` which starts at position 13.
This invalidates interval `b2` (ending at position 10) which is moved to the done list.
From the fixed intervals and the (currently empty list of) active intervals we determine our free-until information.
As we are immediately after the second function call, all registers are free again:

```
            r0  r1  r2
free until: 20  18  20
```

Interval `a2` ends at position 14, there is no register which is live only until position 14, so we take the first register with the highest free-until position.
So we set this register `r0` to the current interval and move the latter to the active list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a2: .............=r...........  [13, 14); usages: 14r        r0

pending:
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
a1: .......======.............  [ 7, 13); usages: none
b0: ..w====...................  [ 2,  7); usages: 2w         r2
b1: .......==.................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r        r1
c0: ....w.....................  [ 4,  5); usages: 4w         r1
c1: .....==========...........  [ 5, 15); usages: none
```

### Interval `t0`
We pick interval `t0` which starts at position 14 and ends at position 18.
From the fixed intervals and the active intervals we determine our free-until information.

```
            r0  r1  r2
free until: -1  18  20
```

As the current interval ends at position 18 and there is a register free until that position, we use this register `r1`.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a2: .............=r...........  [13, 14); usages: 14r            r0
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1

pending:
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
a1: .......======.............  [ 7, 13); usages: none
b0: ..w====...................  [ 2,  7); usages: 2w         r2
b1: .......==.................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r        r1
c0: ....w.....................  [ 4,  5); usages: 4w         r1
c1: .....==========...........  [ 5, 15); usages: none
```

### Interval `c2`
We pick interval `c2` which starts at position 15.
This will invalidate the active register `a2`.
From the fixed intervals and the active intervals we determine our free-until information.

```
            r0  r1  r2
free until: 20  -1  20
```

We assign it the first longest free register (`r0`).
As it only is free until position 20, but the current interval ends at 22, we will need to split it at 19.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c2: ...............=r==.......  [15, 19); usages: 16r        r0
c3: ...................===r...  [19, 22); usages: 22r
```

The split-off interval `c3`'s first usage is at position 22, so we need to split it again at position 21, creating interval `c4`:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c2: ...............=r==.......  [15, 19); usages: 16r        r0
c3: ...................==.....  [19, 21); usages: none
c4: .....................=r...  [21, 22); usages: 22r
```

The current interval `c2` has been set register `r0`, so we move it to the active list.
The usage-free interval `c3` can be moved directly to the done list and split-off interval `c4` is moved to the pending list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1
c2: ...............=r===......  [15, 19); usages: 16r            r0

pending:
c4: .....................=r...  [21, 22); usages: 22r

done:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r     r0
a1: .......======.............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r        r0
b0: ..w====...................  [ 2,  7); usages: 2w         r2
b1: .......==.................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r        r1
c0: ....w.....................  [ 4,  5); usages: 4w         r1
c1: .....==========...........  [ 5, 15); usages: none
c3: ...................==.....  [19, 21); usages: none
```

### Interval `c4`
We pick interval `c4` which starts at position 21.
This will invalidate the intervals `t0` and `c2`.
From the fixed intervals and the active intervals we determine our free-until information.

```
            r0  r1  r2
free until: 24  22  24
```

The current interval ends at position 22 and register `r1` is free until position 22, so we pick that.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
c4: .....................=r...  [21, 22); usages: 22r            r1

pending:

done:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r         r0
a1: .......======.............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r            r0
b0: ..w====...................  [ 2,  7); usages: 2w             r2
b1: .......==.................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r            r1
c0: ....w.....................  [ 4,  5); usages: 4w             r1
c1: .....==========...........  [ 5, 15); usages: none
c2: ...............=r==.......  [15, 19); usages: 16r            r2
c3: ...................==.....  [19, 21); usages: none
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1
```

As there is no pending interval any more, we can move all remaining active intervals to the done list.
```
    0 2 4 6 8 0 2 4 6 8 0 2 4
done:
a0: w=====r...................  [ 0,  7); usages: 0w, 6r         r0
a1: .......======.............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r            r0
b0: ..w====...................  [ 2,  7); usages: 2w             r2
b1: .......==.................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r            r1
c0: ....w.....................  [ 4,  5); usages: 4w             r1
c1: .....==========...........  [ 5, 15); usages: none
c2: ...............=r==.......  [15, 19); usages: 16r            r2
c3: ...................==.....  [20, 21); usages: none
c4: .....................=r...  [21, 22); usages: 22r            r1
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1
```

### Generate the final instructions

Now we can iterate the instructions and introduce all the moves if the variables move between register and memory (stack).
```
00:  mov r0, #1
02:  mov r2, #2
04:  mov r1, #3
05:  mov c, r1
06:  mov r1, r0
07:  mov a, r0
08:  call foo(r1)
09:  mov r1, b
10:  mov r1, r1    ; can be skipped
12:  call foo(r1)
13:  mov r0, a
14:  mov r1, r0
15:  mov r2, c
16:  add r1, r2
18:  mov r1, r1    ; can be skipped
20:  call foo(r1)
21;  mov r1, c
22:  mov r1, r1    ; can be skipped
24:  call foo(r1)
```
After removing the useless moves, we get
```
00:  mov r0, #1
02:  mov r2, #2
04:  mov r1, #3
05:  mov c, r1
06:  mov r1, r0
07:  mov a, r0
08:  call foo(r1)
09:  mov r1, b
12:  call foo(r1)
13:  mov r0, a
14:  mov r1, r0
15:  mov r2, c
16:  add r1, r2
20:  call foo(r1)
21;  mov r1, c
24:  call foo(r1)
```
which is not perfect, but quite reasonable.
