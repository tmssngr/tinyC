        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printUint@i16
        ; arg number (i16): r0
printUint_Pi16:
        ; cast t.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r0, r0
        rl   r0
        sbc  r0, r0
        sbc  r1, r1
        ; call printUint@i32[t.1{r0}]
        call printUint_Pi32
        ret

        ; void printIntLf@i16
        ; arg number (i16): r0
printIntLf_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.number{r8}, number{r0}
        ld   r9, r1
        ld   r8, r0
        ; 127:2 if number < 0
        ; branch param.number{r8} gteq 0: if_1_end, if_1_then
        cp   r8, #%00
        jr   gt, if__1__end
        jr   ne, .gt1
        cp   r9, #%00
        jr   uge, if__1__end
.gt1:
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg param.number{r8}, param.number{r8}
        com  r8
        com  r9
        incw r8
if__1__end:
        ; move param.number{r0}, param.number{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint@i16[param.number{r0}]
        call printUint_Pi16
        ; const arg.2.0{r0}, 13
        ld   r0, #%0d
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void main
        ; var a (i16): SP+4
        ; var c (i16): SP+6
main:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%04
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const t.a{r8}, 10
        ld   r8, #%00
        ld   r9, #%0a
        ; addrof a.a{r10}, a
        ld   r10, SPH
        ld   r11, SPL
        add  r11, #%04
        adc  r10, #%00
        ; store [a.a{r10}], t.a{r8}
        lde  @rr10, r8
        incw r10
        lde  @rr10, r9
        decw r10
        ; addrof a.a1{r8}, a
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%04
        adc  r8, #%00
        ; load t.a1{r0}, [a.a1{r8}]
        lde  r0, @rr8
        incw r8
        lde  r1, @rr8
        decw r8
        ; call printIntLf@i16[t.a1{r0}]
        call printIntLf_Pi16
        ; addrof b{r8}, a
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%04
        adc  r8, #%00
        ; load t.4{r10}, [b{r8}]
        lde  r10, @rr8
        incw r8
        lde  r11, @rr8
        decw r8
        ; move t.c{r8}, t.4{r10}
        ld   r8, r10
        ld   r9, r11
        ; sub t.c{r8}, t.c{r8}, 1
        decw r8
        ; addrof a.c{r10}, c
        ld   r10, SPH
        ld   r11, SPL
        add  r11, #%06
        adc  r10, #%00
        ; store [a.c{r10}], t.c{r8}
        lde  @rr10, r8
        incw r10
        lde  @rr10, r9
        decw r10
        ; addrof a.c1{r8}, c
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%06
        adc  r8, #%00
        ; load t.c1{r0}, [a.c1{r8}]
        lde  r0, @rr8
        incw r8
        lde  r1, @rr8
        decw r8
        ; call printIntLf@i16[t.c1{r0}]
        call printIntLf_Pi16
        ; addrof d{r8}, c
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%06
        adc  r8, #%00
        ; load t.6{r10}, [d{r8}]
        lde  r10, @rr8
        incw r8
        lde  r11, @rr8
        decw r8
        ; sub t.5{r10}, t.5{r10}, 1
        decw r10
        ; store [d{r8}], t.5{r10}
        lde  @rr8, r10
        incw r8
        lde  @rr8, r11
        decw r8
        ; addrof a.c2{r8}, c
        ld   r8, SPH
        ld   r9, SPL
        add  r9, #%06
        adc  r8, #%00
        ; load t.c2{r0}, [a.c2{r8}]
        lde  r0, @rr8
        incw r8
        lde  r1, @rr8
        decw r8
        ; call printIntLf@i16[t.c2{r0}]
        call printIntLf_Pi16
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%04
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void printChar@u8
printChar_Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

        ; void printUint@i32
printUint_Pi32:
        ld   r4, #1
        ld   r5, #%28
        ld   r6, #8
.push:
        push @r5
        inc  r5
        djnz r6, .push
        ; result
        clr     r11
        clr     r12
        clr     r13
        clr     r14
        clr     r15
        ; summand (bcd-shifted power of 2)
        clr     r6
        clr     r7
        clr     r8
        clr     r9
        ld      r10, #1
        ; counter
        ld      r5, #%20
.1:
        sra     r0
        rrc     r1
        rrc     r2
        rrc     r3
        jr      nc, .2
        add     r15, r10
        da      r15
        adc     r14, r9
        da      r14
        adc     r13, r8
        da      r13
        adc     r12, r7
        da      r12
        adc     r11, r6
        da      r11
.2:
        add     r10, r10
        da      r10
        adc     r9, r9
        da      r9
        adc     r8, r8
        da      r8
        adc     r7, r7
        da      r7
        adc     r6, r6
        da      r6
        djnz    r5, .1
        ld      r6, #%2b
        ; counter
        ld      r7, #10
.loop:
        ld      r5, @r6
        tm      r7, #1
        jr      nz, .4
        swap    r5
.4:
        and     r5, #%0f
        or      r4, r4
        jr      z, .5
        cp      r7, #1
        jr      eq, .5
        or      r5, r5
        jr      z, .6
        clr     r4
.5:
        ld      %15, r5
        add     %15, #'0'
        call    %0818
.6:
        tm      r7, #1
        jr      z, .7
        inc     r6
.7:
        djnz    r7, .loop
        ld   r5, #%2f
        ld   r6, #8
.pop:
        pop  @r5
        dec  r5
        djnz r6, .pop
        ret
