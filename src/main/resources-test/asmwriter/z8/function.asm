        .org %e000

start:  jp main
        ; i64 fn
@fn:
        ; const a{r0}, 10
        ; const b{r1}, 20
        ; addrof c{r2}, c
        ; load d{r3}, [c{r2}]
        ret
