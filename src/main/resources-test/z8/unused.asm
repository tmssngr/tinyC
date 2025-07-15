        .const RP  = %FD
        .const SPH = %FE
        .const SPL = %FF

        .org %E000

start:
        push RP
        srp  #%20
        call @main
        pop  RP
        ret

        ; void unusedArg
        ;   sp+9: arg a
@unusedArg:
        ret

        ; void main
@main:
        ; const t.0{r0}, 0
        ld r0, #%00
        ld r1, #%00
        ld r2, #%00
        ld r3, #%00
        ld r4, #%00
        ld r5, #%00
        ld r6, #%00
        ld r7, #%00
        ; call unusedArg[t.0{r0}]
        call unusedArg
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8

