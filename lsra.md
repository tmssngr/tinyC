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
For easier inserting of additional instructions later between instructions we use a two-step counting.
Our precolored example with leading positions will look so:

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
These contain the live-ranges and also the usage positionsn (`r` means read, `w` write, `x` read and write of the same register):

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
a0: w=====r=======r...........  [ 0, 14); usages: 0w, 6r, 14r
b0: ..w=======r...............  [ 2, 10); usages: 2w, 10r
c0: ....w===========r=====r...  [ 4, 22); usages: 4w, 16r, 22r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
```

The calling convention defines, that during function calls (some) registers will not be preserved, so they can't be used to store values at these positions.
These intervals are called *fixed* intervals in the literature, don't need usages being remembered and form hard boundaries for at what positions registers can be used to store values:

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
We select the (first) register with the highest free position - `r0` - and set it to the current interval `a0`.
We truncate that interval before 8, e.g. at the odd position 7, and split off the remaining part as a new interval `a1`:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
a1: .......=======r...........  [ 7, 14); usages: 14r
```
This means that from position 0 to position 7 the variable `a` will be stored in register `r0` and at position 7 a `store <memory-address-of-var-a>, r0` has to be inserted.

We store the current interval in the *active* list.
The interval `a1` will be sorted into the *pending* list between the intervals `c0` and `t0` (by sorting for the interval starting positions).

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0

pending:
b0: ..w=======r...............  [ 2, 10); usages: 2w, 10r
c0: ....w===========r=====r...  [ 4, 22); usages: 4w, 16r, 22r
a1: .......=======r...........  [ 7, 14); usages: 14r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
```

### Interval `b0`
Now we pick interval `b0` which starts at position 2.
From the fixed intervals and the *active* intervals we determine our free-until information.
Because register `r0` is already occupied by the active interval `a0` it is not free, indicated by the value -1:

```
            r0  r1  r2
free until: -1   6   8
```

The current interval `b0` ends at position 10 but again the longest free register `r2` is only free until position 8.
Hence the current interval `b0` is set the register `r2`, and needs to be split also before position 8, creating interval `b1`.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
b0: ..w=====..................  [ 2,  7); usages: 2w         r2
b1: .......===r...............  [ 7, 10); usages: 10r
```

We move interval `b0` into the active list, too, and sort interval `b1` after `a1` into the pending list (though both intervals start at the same position, we can define a heuristic which one to sort before the other, e.g. the one where the first use position is higher).

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
b0: ..w=====..................  [ 2,  7); usages: 2w         r2

pending:
c0: ....w===========r=====r...  [ 4, 22); usages: 4w, 16r, 22r
a1: .......=======r...........  [ 7, 14); usages: 14r
b1: .......===r...............  [ 7, 10); usages: 10r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
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
Hence the current interval `c0` is set the register `r1`, needs to be split before position 6, creating interval `c1`.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c0: ....w=....................  [ 4,  5); usages: 4w         r1
c1: .....===========r=====r...  [ 5, 22); usages: 16r, 22r
```

We move interval `c0` into the active list, and sort interval `c1` before `a1` into the pending list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
b0: ..w=====..................  [ 2,  7); usages: 2w         r2
c0: ....w=....................  [ 4,  5); usages: 4w         r1

pending:
c1: .....===========r=====r...  [ 5, 22); usages: 16r, 22r
a1: .......=======r...........  [ 7, 14); usages: 14r
b1: .......===r...............  [ 7, 10); usages: 10r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
```

### Interval `c1`
We pick interval `c1` which starts at position 5.
From the fixed intervals and the *active* intervals we determine our free-until information.
Because all registers are already occupied by the active intervals, neither can't be used:

```
            r0  r1  r2
free until: -1  -1  -1
```

So we look at which position the registers are blocked next by fixed intervals.
Note, registers which would be not blocked by fixed intervals, their blocked next position would be set to `Integer.MAX_VALUE`.
But for our example all registers are blocked:

```
              r0  r1  r2
blocked next:  8   6   8
```
The current interval's next use is at position 16.
Because this position is higher than the highest blocked-next position, it couldn't be kept in a register past position 8.
So we have to spill it.
As in our example all instructions require their arguments to be in registers, we need to reload it back into a register at position 15, immediately before its next use at position 16.
We achieve that by splitting the current interval at position 15.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c1: .....===========..........  [ 5, 15); usages: none
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r
```

Because we couldn't set a register for the first part of `c1` (truncated at 15), it can't influence any further register choices, and we move it to the done list.
The split-off interval `c2` is moved to the end of the pending list:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
b0: ..w=====..................  [ 2,  7); usages: 2w         r2
c0: ....w=....................  [ 4,  5); usages: 4w         r1

pending:
a1: .......=======r...........  [ 7, 14); usages: 14r
b1: .......===r...............  [ 7, 10); usages: 10r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
c1: .....===========..........  [ 5, 15); usages: none
```

### Interval `a1`
We pick interval `a1` which starts at position 7.
This will expire interval `c0` which ended at position 5, so we move `c0` from the active to the *done* list.
The registers r0 and r2 are blocked by active intervals while register r1 is blocked by its fixed interval:

```
            r0  r1  r2
free until: -1  -1  -1
```

Hence we can't set interval `a1` any free register.
We look at the blocked-next positions (now register 1 is already blocked):

```
              r0  r1  r2
blocked next:  8  -1   8
```
The current interval's next use is at position 14.
This is higher than the highest blocked-next position, so we split the current interval at position 13.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
a1: .......=======............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r
```

The truncated part of `a1` is moved to the done list without having set it a register.
The split-off interval `a2` is moved before `c2` of the pending list:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
b0: ..w=====..................  [ 2,  7); usages: 2w         r2

pending:
b1: .......===r...............  [ 7, 10); usages: 10r
a2: .............=r...........  [13, 14); usages: 14r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a1: .......=======............  [ 7, 13); usages: none
c0: ....w=....................  [ 4,  5); usages: 4w         r1
c1: .....===========..........  [ 5, 15); usages: none
```

### Interval `b1`
We pick interval `b1` which also starts at position 7.
Our free-until information indicates that all registers are blocked:

```
            r0  r1  r2
free until: -1  -1  -1
```

Hence we can't set interval `b1` any free register.
Instead, we look at the next use.
```
              r0  r1  r2
blocked next:  8  -1   8
```

The current interval's next use is at position 10, which is behind the highest blocked-next postion, so we split it at position 9.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
b1: .......===................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r
```

The truncated part of `b1` is moved to the done list without having set it a register.
The split-off interval `b2` is moved before `c2` of the pending list:

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
b0: ..w=====..................  [ 2,  7); usages: 2w         r2

pending:
b2: .........=r...............  [ 9, 10); usages: 10r
a2: .............=r...........  [13, 14); usages: 14r
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a1: .......=======............  [ 7, 13); usages: none
b1: .......===................  [ 7,  9); usages: none
c0: ....w=....................  [ 4,  5); usages: 4w         r1
c1: .....===========..........  [ 5, 15); usages: none
```

### Interval `b2`
We pick interval `b2` which starts at position 9.
This will expire interval `a0` and `b0` which ended at position 7, so we move them from the active to the done list.
From the fixed intervals and the (currently empty list of) active intervals we determine our free-until information.
As we are immediately after the first function call, all registers are free again until position 10 or 12:

```
            r0  r1  r2
free until: 12  10  12
```

Interval `b2` ends at position 10, and one register (`r1`) is free until position 10.
So we set this register to the current interval and move the latter to the active list.
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
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
a1: .......=======............  [ 7, 13); usages: none
b0: ..w=====..................  [ 2,  7); usages: 2w         r2
b1: .......===................  [ 7,  9); usages: none
c0: ....w=....................  [ 4,  5); usages: 4w         r1
c1: .....===========..........  [ 5, 15); usages: none
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
So we set this register r0 to the current interval and move the latter to the active list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a2: .............=r...........  [13, 14); usages: 14r        r0

pending:
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
a1: .......=======............  [ 7, 13); usages: none
b0: ..w=====..................  [ 2,  7); usages: 2w         r2
b1: .......===................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r        r1
c0: ....w=....................  [ 4,  5); usages: 4w         r1
c1: .....===========..........  [ 5, 15); usages: none
```

### Interval `t0`
We pick interval `t0` which starts at position 14 and ends at position 18.
From the fixed intervals and the active intervals we determine our free-until information.

```
            r0  r1  r2
free until: -1  18  20
```

As the current interval ends at position 18 and there is a register free until that position, we use this register r1.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
a2: .............=r...........  [13, 14); usages: 14r            r0
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1

pending:
c2: ...............=r=====r...  [15, 22); usages: 16r, 22r

done:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
a1: .......=======............  [ 7, 13); usages: none
b0: ..w=====..................  [ 2,  7); usages: 2w         r2
b1: .......===................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r        r1
c0: ....w=....................  [ 4,  5); usages: 4w         r1
c1: .....===========..........  [ 5, 15); usages: none
```

### Interval `c2`
We pick interval `c2` which starts at position 15.
This will invalidate the active register `a2`.
From the fixed intervals and the active intervals we determine our free-until information.

```
            r0  r1  r2
free until: 20  -1  20
```

We assign it the first longest free register (`r0`)
As it only is free until position 20, but the current interval ends at 22, we will need to split it at 19.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c2: ...............=r===......  [15, 19); usages: 16r        r0
c3: ...................===r...  [19, 22); usages: 22r
```
The current interval has been set register r2, so we move it to the active list.
The split-off interval `c3` is moved to the pending list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1
c2: ...............=r===......  [15, 19); usages: 16r            r0

pending:
c3: ...................===r...  [19, 22); usages: 22r

done:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r     r0
a1: .......=======............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r        r0
b0: ..w=====..................  [ 2,  7); usages: 2w         r2
b1: .......===................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r        r1
c0: ....w=....................  [ 4,  5); usages: 4w         r1
c1: .....===========..........  [ 5, 15); usages: none
```

### Interval `c3`
We pick interval `c3` which starts at position 19.
This will invalidate the active interval `t0`.
From the fixed intervals and the active intervals we determine our free-until information.

```
            r0  r1  r2
free until: -1  -1  20
```

The highest free position is 20 and the first use of the current interval is at position 22. But since the interval starts at position 19, we can't use that too-short-free register.
```
              r0  r1  r2
blocked next: 20  -1  20
```
As the next-use position is behind the highest blocked-next position, we need to split before the next-use position, at position 21.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
c3: ...................===....  [19, 21); usages: none
c4: .....................=r...  [21, 22); usages: 22r
```
The truncated current interval has been set no register, so we move it to the done list.
The split-off interval `c4` is moved to the pending list.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
c2: ...............=r===......  [15, 19); usages: 16r            r2

pending:
c4: .....................=r...  [21, 22); usages: 22r

done:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r         r0
a1: .......=======............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r            r0
b0: ..w=====..................  [ 2,  7); usages: 2w             r2
b1: .......===................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r            r1
c0: ....w=....................  [ 4,  5); usages: 4w             r1
c1: .....===========..........  [ 5, 15); usages: none
c3: ...................===....  [19, 21); usages: none
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1
```

### Interval `c4`
We pick interval `c4` which starts at position 21.
This will invalidate the intervals `c2`.
From the fixed intervals and the active intervals we determine our free-until information.

```
            r0  r1  r2
free until: 24  22  24
```

The current interval ends at position 22 and register r1 is free until position 22, we pick that.

```
    0 2 4 6 8 0 2 4 6 8 0 2 4
active:
c4: .....................=r...  [21, 22); usages: 22r            r1

pending:

done:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r         r0
a1: .......=======............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r            r0
b0: ..w=====..................  [ 2,  7); usages: 2w             r2
b1: .......===................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r            r1
c0: ....w=....................  [ 4,  5); usages: 4w             r1
c1: .....===========..........  [ 5, 15); usages: none
c2: ...............=r===......  [15, 19); usages: 16r            r2
c3: ...................===....  [19, 21); usages: none
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1
```

As there is no pending interval any more, we can remove all remaining active intervals to the done list.
```
    0 2 4 6 8 0 2 4 6 8 0 2 4
done:
a0: w=====r=..................  [ 0,  7); usages: 0w, 6r         r0
a1: .......=======............  [ 7, 13); usages: none
a2: .............=r...........  [13, 14); usages: 14r            r0
b0: ..w=====..................  [ 2,  7); usages: 2w             r2
b1: .......===................  [ 7,  9); usages: none
b2: .........=r...............  [ 9, 10); usages: 10r            r1
c0: ....w=....................  [ 4,  5); usages: 4w             r1
c1: .....===========..........  [ 5, 15); usages: none
c2: ...............=r===......  [15, 19); usages: 16r            r2
c3: ....................==....  [20, 21); usages: none
c4: .....................=r...  [21, 22); usages: 22r            r1
t0: ..............w=x=r.......  [14, 18); usages: 14w, 16x, 18r  r1
```

### Generate the final instructions

Now we can iterate the instructions and introduce all the moves if the variables move between register and stack.
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
