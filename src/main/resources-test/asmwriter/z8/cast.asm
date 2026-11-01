        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; i16 fn
        ; var u (u8): SP+0
        ; var i (i16): SP+1
        ; var k (i32): SP+3
fn:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%07
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; cast u{r0}(u8), i{r1}(i16)
        ld   r0, r2
        ; cast u{r0}(u8), i{r0}(i16)
        ld   r0, r1
        ; cast u{r1}(u8), i{r0}(i16)
        ; cast u{r2}(u8), i{r0}(i16)
        ld   r2, r1
        ; cast u{r0}(u8), k{r1}(i32)
        ld   r0, r4
        ; cast u{r0}(u8), k{r0}(i32)
        ld   r0, r3
        ; cast u{r3}(u8), k{r0}(i32)
        ; cast u{r4}(u8), k{r0}(i32)
        ld   r4, r3
        ; cast i{r0}(i16), u{r2}(u8)
        ld   r1, r2
        ld   r0, #0
        ; cast i{r0}(i16), u{r1}(u8)
        ld   r0, #0
        ; cast i{r0}(i16), u{r1}(u8)
        ld   r0, #0
        ; cast i{r0}(i16), u{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; cast i{r1}(i16), u{r0}(u8)
        ld   r2, r0
        ld   r1, #0
        ; cast i{r0}(i16), k{r2}(i32)
        ld   r0, r4
        ld   r1, r5
        ; cast i{r0}(i16), k{r0}(i32)
        ld   r0, r2
        ld   r1, r3
        ; cast i{r2}(i16), k{r0}(i32)
        ; cast i{r4}(i16), k{r0}(i32)
        ld   r5, r3
        ld   r4, r2
        ; cast k{r0}(i32), u{r4}(u8)
        ld   r3, r4
        ld   r2, #0
        ld   r1, #0
        ld   r0, #0
        ; cast k{r0}(i32), u{r3}(u8)
        ld   r2, #0
        ld   r1, #0
        ld   r0, #0
        ; cast k{r0}(i32), u{r3}(u8)
        ld   r2, #0
        ld   r1, #0
        ld   r0, #0
        ; cast k{r0}(i32), u{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ld   r1, #0
        ld   r0, #0
        ; cast k{r1}(i32), u{r0}(u8)
        ld   r4, r0
        ld   r3, #0
        ld   r2, #0
        ld   r1, #0
        ; cast k{r0}(i32), i{r4}(i16)
        ld   r2, r4
        ld   r3, r5
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; cast k{r0}(i32), i{r3}(i16)
        ld   r2, r3
        ld   r3, r4
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; cast k{r0}(i32), i{r2}(i16)
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; cast k{r0}(i32), i{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; cast k{r2}(i32), i{r0}(i16)
        ld   r5, r1
        ld   r4, r0
        ld   r3, r4
        rl   r3
        sbc  r3, r3
        sbc  r2, r2
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%07
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret
