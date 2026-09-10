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
fn:
        ; equals b{r0}, u{r1}, v{r2}
        cp   r1, r2
        jr   ne, .ne1
        ld   r0, #1  ; true
        jr   .1
.ne1:
        ld   r0, #0
.1:
        ; equals b{r0}, i{r2}, j{r4}
        cp   r2, r4
        jr   ne, .ne2
        cp   r3, r5
        jr   ne, .ne2
        ld   r0, #1  ; true
        jr   .2
.ne2:
        ld   r0, #0
.2:
        ; notequals b{r0}, u{r1}, v{r2}
        cp   r1, r2
        jr   ne, .ne3
        ld   r0, #0  ; false
        jr   .3
.ne3:
        ld   r0, #1
.3:
        ; notequals b{r0}, i{r2}, j{r4}
        cp   r2, r4
        jr   ne, .ne4
        cp   r3, r5
        jr   ne, .ne4
        ld   r0, #0  ; false
        jr   .4
.ne4:
        ld   r0, #1
.4:
        ; lt b{r0}, u{r1}, v{r2}
        cp   r1, r2
        jr   uge, .false5
.true5:
        ld   r0, #1
        jr   .5
.false5:
        ld   r0, #0
.5:
        ; lt b{r0}, i{r2}, j{r4}
        cp   r2, r4
        jr   lt, .true6
        jr   ne, .false6
        cp   r3, r5
        jr   uge, .false6
.true6:
        ld   r0, #1
        jr   .6
.false6:
        ld   r0, #0
.6:
        ; lteq b{r0}, u{r1}, v{r2}
        cp   r1, r2
        jr   ugt, .false7
.true7:
        ld   r0, #1
        jr   .7
.false7:
        ld   r0, #0
.7:
        ; lteq b{r0}, i{r2}, j{r4}
        cp   r2, r4
        jr   le, .true8
        jr   ne, .false8
        cp   r3, r5
        jr   ugt, .false8
.true8:
        ld   r0, #1
        jr   .8
.false8:
        ld   r0, #0
.8:
        ; gteq b{r0}, u{r1}, v{r2}
        cp   r1, r2
        jr   ult, .false9
.true9:
        ld   r0, #1
        jr   .9
.false9:
        ld   r0, #0
.9:
        ; gteq b{r0}, i{r2}, j{r4}
        cp   r2, r4
        jr   ge, .true10
        jr   ne, .false10
        cp   r3, r5
        jr   ult, .false10
.true10:
        ld   r0, #1
        jr   .10
.false10:
        ld   r0, #0
.10:
        ; gt b{r0}, u{r1}, v{r2}
        cp   r1, r2
        jr   ule, .false11
.true11:
        ld   r0, #1
        jr   .11
.false11:
        ld   r0, #0
.11:
        ; gt b{r0}, i{r2}, j{r4}
        cp   r2, r4
        jr   gt, .true12
        jr   ne, .false12
        cp   r3, r5
        jr   ule, .false12
.true12:
        ld   r0, #1
        jr   .12
.false12:
        ld   r0, #0
.12:
        ret
