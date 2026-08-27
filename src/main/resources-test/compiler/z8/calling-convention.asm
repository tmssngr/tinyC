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
        push r10
        push r11
        ; move param.number{r8}, number{r0}
        ld   r8, r0
        ld   r9, r1
        ; 127:2 if number < 0
        ; const t.2{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; lt t.1{r10}, param.number{r8}, t.2{r10}
        cp   r8, r10
        jr   lt, .true1
        jr   ne, .false1
        cp   r9, r11
        jr   uge, .false1
.true1:
        ld   r10, #1
        jr   .1
.false1:
        ld   r10, #0
.1:
        ; branch t.1{r10}, false, @if_1_end, @if_1_then
        or   r10, r10
        jr   z, if__1__end
        ; const t.3{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[t.3{r0}]
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
        ; const t.4{r0}, 13
        ld   r0, #%0d
        ; call printChar@u8[t.4{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; i16 printAndSum@i16@i16@i16@i16@i16@i16@i16@i16
        ; arg a (i16): r0
        ; arg b (i16): r2
        ; arg c (i16): r4
        ; arg d (i16): r6
        ; arg e (i16): SP+18
        ; arg f (i16): SP+20
        ; arg g (i16): SP+22
        ; arg h (i16): SP+24
        ; var param.a (i16): SP+8
        ; var param.b (i16): SP+10
        ; var param.c (i16): SP+12
        ; var param.d (i16): SP+14
printAndSum_Pi16_Pi16_Pi16_Pi16_Pi16_Pi16_Pi16_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; addrof memVarAddr{r14}, f
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; load f{r12}, [memVarAddr{r14}]
        lde  r12, @rr14
        incw r14
        lde  r13, @rr14
        ; addrof memVarAddr{r14}, g
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%16
        adc  r14, #%00
        ; load g{r10}, [memVarAddr{r14}]
        lde  r10, @rr14
        incw r14
        lde  r11, @rr14
        ; addrof memVarAddr{r14}, h
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%18
        adc  r14, #%00
        ; load h{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        ; addrof memVarAddr{r14}, param.a
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.a{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, param.b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.b{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; addrof memVarAddr{r14}, param.c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.c{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        ; addrof memVarAddr{r14}, param.d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.d{r6}
        lde  @rr14, r6
        incw r14
        lde  @rr14, r7
        ; addrof memVarAddr{r14}, param.a
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load param.a{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, param.a
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.a{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; call printIntLf@i16[param.a{r0}]
        call printIntLf_Pi16
        ; addrof memVarAddr{r14}, param.b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load param.b{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; move param.b{r0}, param.b{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, param.b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.b{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; call printIntLf@i16[param.b{r0}]
        call printIntLf_Pi16
        ; addrof memVarAddr{r14}, param.c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load param.c{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        incw r14
        lde  r5, @rr14
        ; move param.c{r0}, param.c{r4}
        ld   r0, r4
        ld   r1, r5
        ; addrof memVarAddr{r14}, param.c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.c{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        ; call printIntLf@i16[param.c{r0}]
        call printIntLf_Pi16
        ; addrof memVarAddr{r14}, param.d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load param.d{r6}, [memVarAddr{r14}]
        lde  r6, @rr14
        incw r14
        lde  r7, @rr14
        ; move param.d{r0}, param.d{r6}
        ld   r0, r6
        ld   r1, r7
        ; addrof memVarAddr{r14}, param.d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.d{r6}
        lde  @rr14, r6
        incw r14
        lde  @rr14, r7
        ; call printIntLf@i16[param.d{r0}]
        call printIntLf_Pi16
        ; addrof memVarAddr{r14}, e
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%12
        adc  r14, #%00
        ; load e{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, e
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%12
        adc  r14, #%00
        ; store [memVarAddr{r14}], e{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; call printIntLf@i16[e{r0}]
        call printIntLf_Pi16
        ; move f{r0}, f{r12}
        ld   r0, r12
        ld   r1, r13
        ; call printIntLf@i16[f{r0}]
        call printIntLf_Pi16
        ; move g{r0}, g{r10}
        ld   r0, r10
        ld   r1, r11
        ; call printIntLf@i16[g{r0}]
        call printIntLf_Pi16
        ; move h{r0}, h{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printIntLf@i16[h{r0}]
        call printIntLf_Pi16
        ; 17:35 return a + b + c + d + e + f + g + h
        ; addrof memVarAddr{r14}, param.a
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load param.a{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; move t.14{r2}, param.a{r0}
        ld   r2, r0
        ld   r3, r1
        ; addrof memVarAddr{r14}, param.b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load param.b{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        incw r14
        lde  r5, @rr14
        ; add t.14{r2}, t.14{r2}, param.b{r4}
        add  r3, r5
        adc  r2, r4
        ; addrof memVarAddr{r14}, param.c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load param.c{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        incw r14
        lde  r5, @rr14
        ; add t.13{r2}, t.13{r2}, param.c{r4}
        add  r3, r5
        adc  r2, r4
        ; addrof memVarAddr{r14}, param.d
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load param.d{r6}, [memVarAddr{r14}]
        lde  r6, @rr14
        incw r14
        lde  r7, @rr14
        ; add t.12{r2}, t.12{r2}, param.d{r6}
        add  r3, r7
        adc  r2, r6
        ; addrof memVarAddr{r14}, e
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%12
        adc  r14, #%00
        ; load e{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        incw r14
        lde  r5, @rr14
        ; add t.11{r2}, t.11{r2}, e{r4}
        add  r3, r5
        adc  r2, r4
        ; add t.10{r2}, t.10{r2}, f{r12}
        add  r3, r13
        adc  r2, r12
        ; add t.9{r2}, t.9{r2}, g{r10}
        add  r3, r11
        adc  r2, r10
        ; move t.8{r0}, t.9{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.8{r0}, t.8{r0}, h{r8}
        add  r1, r9
        adc  r0, r8
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void main
        ; var t.4 (i16): SP+16
        ; var arg.0.4 (i16): SP+0
        ; var arg.0.5 (i16): SP+2
        ; var arg.0.6 (i16): SP+4
        ; var arg.0.7 (i16): SP+6
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; const t.1{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; const t.2{r2}, 2
        ld   r2, #%00
        ld   r3, #%02
        ; const t.3{r4}, 3
        ld   r4, #%00
        ld   r5, #%03
        ; const t.4{r6}, 4
        ld   r6, #%00
        ld   r7, #%04
        ; const t.5{r8}, 5
        ld   r8, #%00
        ld   r9, #%05
        ; const t.6{r10}, 6
        ld   r10, #%00
        ld   r11, #%06
        ; const t.7{r12}, 7
        ld   r12, #%00
        ld   r13, #%07
        ; addrof memVarAddr{r14}, t.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.4{r6}
        lde  @rr14, r6
        incw r14
        lde  @rr14, r7
        ; const t.8{r6}, 8
        ld   r6, #%00
        ld   r7, #%08
        ; addrof memVarAddr{r14}, arg.0.4
        ld   r14, SPH
        ld   r15, SPL
        ; store [memVarAddr{r14}], t.5{r8}
        lde  @rr14, r8
        incw r14
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, arg.0.5
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%02
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.6{r10}
        lde  @rr14, r10
        incw r14
        lde  @rr14, r11
        ; addrof memVarAddr{r14}, arg.0.6
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%04
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.7{r12}
        lde  @rr14, r12
        incw r14
        lde  @rr14, r13
        ; addrof memVarAddr{r14}, arg.0.7
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%06
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.8{r6}
        lde  @rr14, r6
        incw r14
        lde  @rr14, r7
        ; addrof memVarAddr{r14}, t.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; load t.4{r6}, [memVarAddr{r14}]
        lde  r6, @rr14
        incw r14
        lde  r7, @rr14
        ; call sum{r0} = printAndSum@i16@i16@i16@i16@i16@i16@i16@i16[t.1{r0}, t.2{r2}, t.3{r4}, t.4{r6}, arg.0.4, arg.0.5, arg.0.6, arg.0.7] -> i16
        call printAndSum_Pi16_Pi16_Pi16_Pi16_Pi16_Pi16_Pi16_Pi16
        ; call printIntLf@i16[sum{r0}]
        call printIntLf_Pi16
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
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
