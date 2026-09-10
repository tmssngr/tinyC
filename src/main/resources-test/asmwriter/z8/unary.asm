        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; i16 fn
        ; arg u (u8): r0
        ; arg v (u8): r1
        ; arg i (i16): r2
        ; arg j (i16): r4
        ; var i (i32): SP+0
        ; var j (i32): SP+4
        ; var b (bool): SP+8
        ; var c (bool): SP+9
fn:
        ; neg u{r0}, v{r0}
        com  r0
        inc  r0
        ; neg u{r0}, v{r1}
        ld   r0, #%00
        sub  r0, r1
        ; neg i{r0}, j{r0}
        com  r0
        com  r1
        incw r0
        ; neg i{r0}, j{r2}
        ld   r0, #%00
        ld   r1, #%00
        sub  r1, r3
        sbc  r0, r2
        ; neg i{r0}, j{r0}
        com  r0
        com  r1
        com  r2
        com  r3
        sub  r3, #1
        sbc  r2, #0
        sbc  r1, #0
        sbc  r0, #0
        ; neg i{r0}, j{r4}
        ld   r0, #%00
        ld   r1, #%00
        ld   r2, #%00
        ld   r3, #%00
        sub  r3, r7
        sbc  r2, r6
        sbc  r1, r5
        sbc  r0, r4
        ; not u{r0}, v{r0}
        com  r0
        ; not u{r0}, v{r1}
        ld   r0, r1
        com  r0
        ; not i{r0}, j{r0}
        com  r0
        com  r1
        ; not i{r0}, j{r2}
        ld   r0, r2
        ld   r1, r3
        com  r0
        com  r1
        ; notlog b{r0}, c{r0}
        or   r0, r0
        ld   r0, #0  ; false
        jr   nz, .1
        ld   r0, #1  ; true
.1:
        ; notlog b{r0}, c{r1}
        or   r1, r1
        ld   r0, #0  ; false
        jr   nz, .2
        ld   r0, #1  ; true
.2:
        ret
