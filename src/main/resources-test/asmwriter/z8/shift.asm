        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; i32 fn
        ; var u8 (u8): SP+4
        ; var i32 (i32): SP+5
fn:
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; shiftleft u8{r0}, 1
        add r0, r0
        ; shiftright u8{r0}, 1
        rcf
        rrc  r0
        ; shiftleft u8{r1}, 2
        add r1, r1
        add r1, r1
        ; shiftright u8{r1}, 2
        rcf
        rrc  r1
        rcf
        rrc  r1
        ; shiftleft u8{r2}, 4
        and  r2, #%0F
        swap r2
        ; shiftright u8{r2}, 4
        swap r2
        and  r2, #%0F
        ; shiftleft u8{r3}, 8
        clr  r3
        ; shiftright u8{r3}, 8
        clr  r3
        ; shiftleft i32{r0}, 1
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        ; shiftright i32{r0}, 1
        sra  r0
        rrc  r1
        rrc  r2
        rrc  r3
        ; shiftleft i32{r4}, 2
        add r7, r7
        adc r6, r6
        adc r5, r5
        adc r4, r4
        add r7, r7
        adc r6, r6
        adc r5, r5
        adc r4, r4
        ; shiftright i32{r4}, 2
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        ; shiftleft i32{r8}, 4
        add r11, r11
        adc r10, r10
        adc r9, r9
        adc r8, r8
        add r11, r11
        adc r10, r10
        adc r9, r9
        adc r8, r8
        add r11, r11
        adc r10, r10
        adc r9, r9
        adc r8, r8
        add r11, r11
        adc r10, r10
        adc r9, r9
        adc r8, r8
        ; shiftright i32{r8}, 4
        sra  r8
        rrc  r9
        rrc  r10
        rrc  r11
        sra  r8
        rrc  r9
        rrc  r10
        rrc  r11
        sra  r8
        rrc  r9
        rrc  r10
        rrc  r11
        sra  r8
        rrc  r9
        rrc  r10
        rrc  r11
        ; shiftleft i32{r0}, 8
        ld   r0, r1
        ld   r1, r2
        ld   r2, r3
        clr  r3
        ; shiftright i32{r0}, 8
        ld   r3, r2
        ld   r2, r1
        ld   r1, r0
        rl   r0
        sbc  r0, r0
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        ret
