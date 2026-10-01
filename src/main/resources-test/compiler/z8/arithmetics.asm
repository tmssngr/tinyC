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
        ; cast t.1.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r0, r0
        rl   r0
        sbc  r0, r0
        sbc  r1, r1
        ; call printUint@i32[t.1.1{r0}]
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
        ; branch param.number{r8} gteq 0: if_1_end
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
        ; neg number.2{r8}, param.number{r8}
        com  r8
        com  r9
        incw r8
if__1__end:
        ; move number.1{r0}, number.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint@i16[number.1{r0}]
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
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const foo.1{r8}, 22
        ld   r8, #%00
        ld   r9, #%16
        ; move bar.1{r10}, foo.1{r8}
        ld   r11, r9
        ld   r10, r8
        ; mul bar.1{r10}, foo.1{r8}
        ld   %12, r10
        ld   %13, r11
        ld   %14, r8
        ld   %15, r9
        srp  #%10
        call %00BA ; mul
        srp  #%20
        ld   r10, %12
        ld   r11, %13
        ; const foo.2{r8}, 1
        ld   r8, #%00
        ld   r9, #%01
        ; move t.5.1{r0}, bar.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; add t.5.1{r0}, foo.2{r8}
        add  r1, r9
        adc  r0, r8
        ; call printIntLf@i16[t.5.1{r0}]
        call printIntLf_Pi16
        ; const foo.3{r0}, 21
        ld   r0, #%00
        ld   r1, #%15
        ; call printIntLf@i16[foo.3{r0}]
        call printIntLf_Pi16
        ; const bazz.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; call printIntLf@i16[bazz.1{r0}]
        call printIntLf_Pi16
        ; const a.1{r8}, 1000
        ld   r8, #%03
        ld   r9, #%e8
        ; const b.1{r10}, 10
        ld   r10, #%00
        ld   r11, #%0a
        ; move t.6.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; div t.6.1{r0}, b.1{r10}
        ld   %12, r0
        ld   %13, r1
        ld   %14, r10
        ld   %15, r11
        srp  #%10
        call %00E0 ; div
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; call printIntLf@i16[t.6.1{r0}]
        call printIntLf_Pi16
        ; move t.7.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.7.1{r0}, 255
        clr  r0
        ; call printIntLf@i16[t.7.1{r0}]
        call printIntLf_Pi16
        ; const a.2{r8}, 10
        ld   r8, #%00
        ld   r9, #%0a
        ; const b.2{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; move t.8.1{r0}, a.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; shiftright t.8.1{r0}, b.2{r10}
        or   r11, r11
        jr   z, .next2
        push r11
.shift2:
        sra  r0
        rrc  r1
        djnz r11, .shift2
        pop  r11
.next2:
        ; call printIntLf@i16[t.8.1{r0}]
        call printIntLf_Pi16
        ; const a.3{r8}, 9
        ld   r8, #%00
        ld   r9, #%09
        ; const b.3{r10}, 2
        ld   r10, #%00
        ld   r11, #%02
        ; move t.9.1{r0}, a.3{r8}
        ld   r0, r8
        ld   r1, r9
        ; shiftright t.9.1{r0}, b.3{r10}
        or   r11, r11
        jr   z, .next3
        push r11
.shift3:
        sra  r0
        rrc  r1
        djnz r11, .shift3
        pop  r11
.next3:
        ; call printIntLf@i16[t.9.1{r0}]
        call printIntLf_Pi16
        ; const a.4{r8}, 1
        ld   r8, #%00
        ld   r9, #%01
        ; move t.10.1{r0}, a.4{r8}
        ld   r0, r8
        ld   r1, r9
        ; shiftleft t.10.1{r0}, b.3{r10}
        or   r11, r11
        jr   z, .next4
        push r11
.shift4:
        rcf
        rlc  r1
        rlc  r0
        djnz r11, .shift4
        pop  r11
.next4:
        ; call printIntLf@i16[t.10.1{r0}]
        call printIntLf_Pi16
        ; restore clobbered non-volatile registers
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
