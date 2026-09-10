        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; i16 fn
        ; var i16 (i16): SP+0
fn:
        ; move i16{r0}, i16{r2}
        ld   r0, r2
        ld   r1, r3
        ; move i16{r2}, i16{r0}
        ld   r3, r1
        ld   r2, r0
        ; move i16{r1}, i16{r2}
        ld   r1, r2
        ld   r2, r3
        ; move i16{r2}, i16{r1}
        ld   r3, r2
        ld   r2, r1
        ret
