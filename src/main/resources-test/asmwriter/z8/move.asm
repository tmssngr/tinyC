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
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%02
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
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
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%02
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret
