        .org %e000

start:  jp main
        ; i16 fn
@fn:
        ; const a{r0}, 10
        ld r1, #%0a
        ld r0, #%00
        ; const b{r2}, 20
        ld r2, #%14
        ; addrof d{r4}, c
        ; load c{r3}, [d{r4}]
        lde r3, rr4
        ret
