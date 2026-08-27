        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; i16 fn
        ; arg a (i16): r0
        ; arg b (u8): r2
        ; var c (u8): SP+0
        ; var d (void*): SP+1
fn:
        ; const a{r0}, 10
        ld   r0, #%00
        ld   r1, #%0a
        ; const b{r2}, 20
        ld   r2, #%14
        ; addrof d{r4}, c
        ld   r4, SPH
        ld   r5, SPL
        ; load c{r3}, [d{r4}]
        lde  r3, @rr4
        ret
