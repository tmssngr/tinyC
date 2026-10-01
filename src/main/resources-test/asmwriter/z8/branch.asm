        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void branchRegReg
        ; var b1 (u8): SP+0
        ; var b2 (u8): SP+1
        ; var i1 (i16): SP+2
        ; var i2 (i16): SP+4
        ; var w1 (i32): SP+6
        ; var w2 (i32): SP+10
branchRegReg:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%0e
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; branch b1{r0} equals b2{r1}: target, next
        cp   r0, r1
        jr   eq, target
        ; branch i1{r0} equals i2{r2}: target, next
        cp   r1, r3
        jr   ne, .notEquals1
        cp   r0, r2
        jr   eq, target
.notEquals1:
        ; branch w1{r0} equals w2{r4}: target, next
        cp   r3, r7
        jr   ne, .notEquals2
        cp   r2, r6
        jr   ne, .notEquals2
        cp   r1, r5
        jr   ne, .notEquals2
        cp   r0, r4
        jr   eq, target
.notEquals2:
        ; branch b1{r0} notequals b2{r1}: target, next
        cp   r0, r1
        jr   ne, target
        ; branch i1{r0} notequals i2{r2}: target, next
        cp   r1, r3
        jr   ne, target
        cp   r0, r2
        jr   ne, target
        ; branch w1{r0} notequals w2{r4}: target, next
        cp   r3, r7
        jr   ne, target
        cp   r2, r6
        jr   ne, target
        cp   r1, r5
        jr   ne, target
        cp   r0, r4
        jr   ne, target
        ; branch b1{r0} lt b2{r1}: target, next
        cp   r0, r1
        jr   ult, target
        ; branch i1{r0} lt i2{r2}: target, next
        cp   r0, r2
        jr   lt, target
        jr   ne, .lt3
        cp   r1, r3
        jr   ult, target
.lt3:
        ; branch w1{r0} lt w2{r4}: target, next
        cp   r0, r4
        jr   lt, target
        jr   ne, .lt4
        cp   r1, r5
        jr   ult, target
        jr   ne, .lt4
        cp   r2, r6
        jr   ult, target
        jr   ne, .lt4
        cp   r3, r7
        jr   ult, target
.lt4:
        ; branch b1{r0} lteq b2{r1}: target, next
        cp   r0, r1
        jr   ule, target
        ; branch i1{r0} lteq i2{r2}: target, next
        cp   r0, r2
        jr   lt, target
        jr   ne, .lt5
        cp   r1, r3
        jr   ule, target
.lt5:
        ; branch w1{r0} lteq w2{r4}: target, next
        cp   r0, r4
        jr   lt, target
        jr   ne, .lt6
        cp   r1, r5
        jr   ult, target
        jr   ne, .lt6
        cp   r2, r6
        jr   ult, target
        jr   ne, .lt6
        cp   r3, r7
        jr   ule, target
.lt6:
        ; branch b1{r0} gteq b2{r1}: target, next
        cp   r0, r1
        jr   uge, target
        ; branch i1{r0} gteq i2{r2}: target, next
        cp   r0, r2
        jr   gt, target
        jr   ne, .gt7
        cp   r1, r3
        jr   uge, target
.gt7:
        ; branch w1{r0} gteq w2{r4}: target, next
        cp   r0, r4
        jr   gt, target
        jr   ne, .gt8
        cp   r1, r5
        jr   ugt, target
        jr   ne, .gt8
        cp   r2, r6
        jr   ugt, target
        jr   ne, .gt8
        cp   r3, r7
        jr   uge, target
.gt8:
        ; branch b1{r0} gt b2{r1}: target, next
        cp   r0, r1
        jr   ugt, target
        ; branch i1{r0} gt i2{r2}: target, next
        cp   r0, r2
        jr   gt, target
        jr   ne, .gt9
        cp   r1, r3
        jr   ugt, target
.gt9:
        ; branch w1{r0} gt w2{r4}: target, next
        cp   r0, r4
        jr   gt, target
        jr   ne, .gt10
        cp   r1, r5
        jr   ugt, target
        jr   ne, .gt10
        cp   r2, r6
        jr   ugt, target
        jr   ne, .gt10
        cp   r3, r7
        jr   ugt, target
.gt10:
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%0e
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void branchRegLit
        ; var b1 (u8): SP+0
        ; var b2 (u8): SP+1
        ; var i1 (i16): SP+2
        ; var i2 (i16): SP+4
        ; var w1 (i32): SP+6
        ; var w2 (i32): SP+10
branchRegLit:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%0e
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; branch b1{r0} equals 42: target, next
        cp   r0, #%2a
        jr   eq, target
        ; branch i1{r0} equals 42: target, next
        cp   r1, #%2a
        jr   ne, .notEquals11
        cp   r0, #%00
        jr   eq, target
.notEquals11:
        ; branch w1{r0} equals 42: target, next
        cp   r3, #%2a
        jr   ne, .notEquals12
        cp   r2, #%00
        jr   ne, .notEquals12
        cp   r1, #%00
        jr   ne, .notEquals12
        cp   r0, #%00
        jr   eq, target
.notEquals12:
        ; branch b1{r0} notequals 42: target, next
        cp   r0, #%2a
        jr   ne, target
        ; branch i1{r0} notequals 42: target, next
        cp   r1, #%2a
        jr   ne, target
        cp   r0, #%00
        jr   ne, target
        ; branch w1{r0} notequals 42: target, next
        cp   r3, #%2a
        jr   ne, target
        cp   r2, #%00
        jr   ne, target
        cp   r1, #%00
        jr   ne, target
        cp   r0, #%00
        jr   ne, target
        ; branch b1{r0} lt 42: target, next
        cp   r0, #%2a
        jr   ult, target
        ; branch i1{r0} lt 42: target, next
        cp   r0, #%00
        jr   lt, target
        jr   ne, .lt13
        cp   r1, #%2a
        jr   ult, target
.lt13:
        ; branch w1{r0} lt 42: target, next
        cp   r0, #%00
        jr   lt, target
        jr   ne, .lt14
        cp   r1, #%00
        jr   ult, target
        jr   ne, .lt14
        cp   r2, #%00
        jr   ult, target
        jr   ne, .lt14
        cp   r3, #%2a
        jr   ult, target
.lt14:
        ; branch b1{r0} lteq 42: target, next
        cp   r0, #%2a
        jr   ule, target
        ; branch i1{r0} lteq 42: target, next
        cp   r0, #%00
        jr   lt, target
        jr   ne, .lt15
        cp   r1, #%2a
        jr   ule, target
.lt15:
        ; branch w1{r0} lteq 42: target, next
        cp   r0, #%00
        jr   lt, target
        jr   ne, .lt16
        cp   r1, #%00
        jr   ult, target
        jr   ne, .lt16
        cp   r2, #%00
        jr   ult, target
        jr   ne, .lt16
        cp   r3, #%2a
        jr   ule, target
.lt16:
        ; branch b1{r0} gteq 42: target, next
        cp   r0, #%2a
        jr   uge, target
        ; branch i1{r0} gteq 42: target, next
        cp   r0, #%00
        jr   gt, target
        jr   ne, .gt17
        cp   r1, #%2a
        jr   uge, target
.gt17:
        ; branch w1{r0} gteq 42: target, next
        cp   r0, #%00
        jr   gt, target
        jr   ne, .gt18
        cp   r1, #%00
        jr   ugt, target
        jr   ne, .gt18
        cp   r2, #%00
        jr   ugt, target
        jr   ne, .gt18
        cp   r3, #%2a
        jr   uge, target
.gt18:
        ; branch b1{r0} gt 42: target, next
        cp   r0, #%2a
        jr   ugt, target
        ; branch i1{r0} gt 42: target, next
        cp   r0, #%00
        jr   gt, target
        jr   ne, .gt19
        cp   r1, #%2a
        jr   ugt, target
.gt19:
        ; branch w1{r0} gt 42: target, next
        cp   r0, #%00
        jr   gt, target
        jr   ne, .gt20
        cp   r1, #%00
        jr   ugt, target
        jr   ne, .gt20
        cp   r2, #%00
        jr   ugt, target
        jr   ne, .gt20
        cp   r3, #%2a
        jr   ugt, target
.gt20:
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%0e
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret
