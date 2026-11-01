        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; u8 fn
        ; arg p0 (u8): r0
        ; arg p1 (u8): r1
        ; arg p2 (u8): r2
        ; arg p3 (u8): r3
        ; arg p4 (u8): r4
        ; arg p5 (u8): r5
        ; arg p6 (u8): r6
        ; arg p7 (u8): r7
        ; arg p8 (u8): SP+4
        ; arg p9 (u8): SP+5
        ; var v10 (u8): SP+1
fn:
        decw SPH
        ; save clobbered non-volatile registers
        push r8
        ; move v10{r8}, p0{r0}
        ld   r8, r0
        ; restore clobbered non-volatile registers
        pop  r8
        incw SPH
        ret
