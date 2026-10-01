        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void regReg
        ; var b1 (u8): SP+2
        ; var b2 (u8): SP+3
        ; var i1 (i16): SP+4
        ; var i2 (i16): SP+6
regReg:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%06
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; equals b{r0}, b1{r1}, b2{r2}
        cp   r1, r2
        jr   eq, .true1
        ld   r0, #0  ; false
        jr   .1
.true1:
        ld   r0, #1
.1:
        ; equals b{r0}, i1{r2}, i2{r4}
        cp   r2, r4
        jr   ne, .ne2
        cp   r3, r5
        jr   ne, .ne2
        ld   r0, #1  ; true
        jr   .2
.ne2:
        ld   r0, #0
.2:
        ; equals b{r0}, w1{r2}, w2{r6}
        cp   r2, r6
        jr   ne, .ne3
        cp   r3, r7
        jr   ne, .ne3
        cp   r4, r8
        jr   ne, .ne3
        cp   r5, r9
        jr   ne, .ne3
        ld   r0, #1  ; true
        jr   .3
.ne3:
        ld   r0, #0
.3:
        ; notequals b{r0}, b1{r1}, b2{r2}
        cp   r1, r2
        jr   ne, .true4
        ld   r0, #0  ; false
        jr   .4
.true4:
        ld   r0, #1
.4:
        ; notequals b{r0}, i1{r2}, i2{r4}
        cp   r2, r4
        jr   ne, .ne5
        cp   r3, r5
        jr   ne, .ne5
        ld   r0, #0  ; false
        jr   .5
.ne5:
        ld   r0, #1
.5:
        ; notequals b{r0}, w1{r2}, w2{r6}
        cp   r2, r6
        jr   ne, .ne6
        cp   r3, r7
        jr   ne, .ne6
        cp   r4, r8
        jr   ne, .ne6
        cp   r5, r9
        jr   ne, .ne6
        ld   r0, #0  ; false
        jr   .6
.ne6:
        ld   r0, #1
.6:
        ; lt b{r0}, b1{r1}, b2{r2}
        cp   r1, r2
        jr   ult, .true7
        ld   r0, #0  ; false
        jr   .7
.true7:
        ld   r0, #1
.7:
        ; lt b{r0}, i1{r2}, i2{r4}
        cp   r2, r4
        jr   lt, .true8
        jr   ne, .false8
        cp   r3, r5
        jr   ult, .true8
.false8:
        ld   r0, #0
        jr   .8
.true8:
        ld   r0, #1
.8:
        ; lt b{r0}, w1{r2}, w2{r6}
        cp   r2, r6
        jr   lt, .true9
        jr   ne, .false9
        cp   r3, r7
        jr   ult, .true9
        jr   ne, .false9
        cp   r4, r8
        jr   ult, .true9
        jr   ne, .false9
        cp   r5, r9
        jr   ult, .true9
.false9:
        ld   r0, #0
        jr   .9
.true9:
        ld   r0, #1
.9:
        ; lteq b{r0}, b1{r1}, b2{r2}
        cp   r1, r2
        jr   ule, .true10
        ld   r0, #0  ; false
        jr   .10
.true10:
        ld   r0, #1
.10:
        ; lteq b{r0}, i1{r2}, i2{r4}
        cp   r2, r4
        jr   lt, .true11
        jr   ne, .false11
        cp   r3, r5
        jr   ule, .true11
.false11:
        ld   r0, #0
        jr   .11
.true11:
        ld   r0, #1
.11:
        ; lteq b{r0}, w1{r2}, w2{r6}
        cp   r2, r6
        jr   lt, .true12
        jr   ne, .false12
        cp   r3, r7
        jr   ult, .true12
        jr   ne, .false12
        cp   r4, r8
        jr   ult, .true12
        jr   ne, .false12
        cp   r5, r9
        jr   ule, .true12
.false12:
        ld   r0, #0
        jr   .12
.true12:
        ld   r0, #1
.12:
        ; gteq b{r0}, b1{r1}, b2{r2}
        cp   r1, r2
        jr   uge, .true13
        ld   r0, #0  ; false
        jr   .13
.true13:
        ld   r0, #1
.13:
        ; gteq b{r0}, i1{r2}, i2{r4}
        cp   r2, r4
        jr   gt, .true14
        jr   ne, .false14
        cp   r3, r5
        jr   uge, .true14
.false14:
        ld   r0, #0
        jr   .14
.true14:
        ld   r0, #1
.14:
        ; gteq b{r0}, w1{r2}, w2{r6}
        cp   r2, r6
        jr   gt, .true15
        jr   ne, .false15
        cp   r3, r7
        jr   ugt, .true15
        jr   ne, .false15
        cp   r4, r8
        jr   ugt, .true15
        jr   ne, .false15
        cp   r5, r9
        jr   uge, .true15
.false15:
        ld   r0, #0
        jr   .15
.true15:
        ld   r0, #1
.15:
        ; gt b{r0}, b1{r1}, b2{r2}
        cp   r1, r2
        jr   ugt, .true16
        ld   r0, #0  ; false
        jr   .16
.true16:
        ld   r0, #1
.16:
        ; gt b{r0}, i1{r2}, i2{r4}
        cp   r2, r4
        jr   gt, .true17
        jr   ne, .false17
        cp   r3, r5
        jr   ugt, .true17
.false17:
        ld   r0, #0
        jr   .17
.true17:
        ld   r0, #1
.17:
        ; gt b{r0}, w1{r2}, w2{r6}
        cp   r2, r6
        jr   gt, .true18
        jr   ne, .false18
        cp   r3, r7
        jr   ugt, .true18
        jr   ne, .false18
        cp   r4, r8
        jr   ugt, .true18
        jr   ne, .false18
        cp   r5, r9
        jr   ugt, .true18
.false18:
        ld   r0, #0
        jr   .18
.true18:
        ld   r0, #1
.18:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%06
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void regLit
        ; var b1 (u8): SP+0
        ; var b2 (u8): SP+1
        ; var i1 (i16): SP+2
        ; var i2 (i16): SP+4
regLit:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%06
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; equals b{r0}, b1{r1}, 42
        cp   r1, #%2a
        jr   eq, .eq19
        ld   r0, #0  ; false
        jr   .19
.eq19:
        ld   r0, #1
.19:
        ; equals b{r0}, i1{r2}, 42
        cp   r2, #%00
        jr   ne, .ne20
        cp   r3, #%2a
        jr   ne, .ne20
        ld   r0, #1  ; true
        jr   .20
.ne20:
        ld   r0, #0
.20:
        ; equals b{r0}, w1{r2}, 42
        cp   r2, #%00
        jr   ne, .ne21
        cp   r3, #%00
        jr   ne, .ne21
        cp   r4, #%00
        jr   ne, .ne21
        cp   r5, #%2a
        jr   ne, .ne21
        ld   r0, #1  ; true
        jr   .21
.ne21:
        ld   r0, #0
.21:
        ; notequals b{r0}, b1{r1}, 42
        cp   r1, #%2a
        jr   ne, .ne22
        ld   r0, #0  ; false
        jr   .22
.ne22:
        ld   r0, #1
.22:
        ; notequals b{r0}, i1{r2}, 42
        cp   r2, #%00
        jr   ne, .ne23
        cp   r3, #%2a
        jr   ne, .ne23
        ld   r0, #0  ; false
        jr   .23
.ne23:
        ld   r0, #1
.23:
        ; notequals b{r0}, w1{r2}, 42
        cp   r2, #%00
        jr   ne, .ne24
        cp   r3, #%00
        jr   ne, .ne24
        cp   r4, #%00
        jr   ne, .ne24
        cp   r5, #%2a
        jr   ne, .ne24
        ld   r0, #0  ; false
        jr   .24
.ne24:
        ld   r0, #1
.24:
        ; lt b{r0}, b1{r1}, 42
        cp   r1, #%2a
        jr   ult, .ult25
        ld   r0, #0  ; false
        jr   .25
.ult25:
        ld   r0, #1
.25:
        ; lt b{r0}, i1{r2}, 42
        cp   r2, #%00
        jr   lt, .true26
        jr   ne, .false26
        cp   r3, #%2a
        jr   ult, .true26
.false26:
        ld   r0, #0
        jr   .26
.true26:
        ld   r0, #1
.26:
        ; lt b{r0}, w1{r2}, 42
        cp   r2, #%00
        jr   lt, .true27
        jr   ne, .false27
        cp   r3, #%00
        jr   ult, .true27
        jr   ne, .false27
        cp   r4, #%00
        jr   ult, .true27
        jr   ne, .false27
        cp   r5, #%2a
        jr   ult, .true27
.false27:
        ld   r0, #0
        jr   .27
.true27:
        ld   r0, #1
.27:
        ; lteq b{r0}, b1{r1}, 42
        cp   r1, #%2a
        jr   ule, .ule28
        ld   r0, #0  ; false
        jr   .28
.ule28:
        ld   r0, #1
.28:
        ; lteq b{r0}, i1{r2}, 42
        cp   r2, #%00
        jr   lt, .true29
        jr   ne, .false29
        cp   r3, #%2a
        jr   ule, .true29
.false29:
        ld   r0, #0
        jr   .29
.true29:
        ld   r0, #1
.29:
        ; lteq b{r0}, w1{r2}, 42
        cp   r2, #%00
        jr   lt, .true30
        jr   ne, .false30
        cp   r3, #%00
        jr   ult, .true30
        jr   ne, .false30
        cp   r4, #%00
        jr   ult, .true30
        jr   ne, .false30
        cp   r5, #%2a
        jr   ule, .true30
.false30:
        ld   r0, #0
        jr   .30
.true30:
        ld   r0, #1
.30:
        ; gteq b{r0}, b1{r1}, 42
        cp   r1, #%2a
        jr   uge, .uge31
        ld   r0, #0  ; false
        jr   .31
.uge31:
        ld   r0, #1
.31:
        ; gteq b{r0}, i1{r2}, 42
        cp   r2, #%00
        jr   gt, .true32
        jr   ne, .false32
        cp   r3, #%2a
        jr   uge, .true32
.false32:
        ld   r0, #0
        jr   .32
.true32:
        ld   r0, #1
.32:
        ; gteq b{r0}, w1{r2}, 42
        cp   r2, #%00
        jr   gt, .true33
        jr   ne, .false33
        cp   r3, #%00
        jr   ugt, .true33
        jr   ne, .false33
        cp   r4, #%00
        jr   ugt, .true33
        jr   ne, .false33
        cp   r5, #%2a
        jr   uge, .true33
.false33:
        ld   r0, #0
        jr   .33
.true33:
        ld   r0, #1
.33:
        ; gt b{r0}, b1{r1}, 42
        cp   r1, #%2a
        jr   ugt, .ugt34
        ld   r0, #0  ; false
        jr   .34
.ugt34:
        ld   r0, #1
.34:
        ; gt b{r0}, i1{r2}, 42
        cp   r2, #%00
        jr   gt, .true35
        jr   ne, .false35
        cp   r3, #%2a
        jr   ugt, .true35
.false35:
        ld   r0, #0
        jr   .35
.true35:
        ld   r0, #1
.35:
        ; gt b{r0}, w1{r2}, 42
        cp   r2, #%00
        jr   gt, .true36
        jr   ne, .false36
        cp   r3, #%00
        jr   ugt, .true36
        jr   ne, .false36
        cp   r4, #%00
        jr   ugt, .true36
        jr   ne, .false36
        cp   r5, #%2a
        jr   ugt, .true36
.false36:
        ld   r0, #0
        jr   .36
.true36:
        ld   r0, #1
.36:
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%06
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret
