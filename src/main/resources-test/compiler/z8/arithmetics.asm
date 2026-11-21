        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; void printUint_Pi16
        ; arg number (i16): r0
printUint_Pi16:
        ; cast t.1.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; call printUint_Pi32[t.1.1{r0}]
        call printUint_Pi32
        ret

        ; void printIntLf_Pi16
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
        jr   gt, if_1_end
        jr   ne, .gt1
        cp   r9, #%00
        jr   uge, if_1_end
.gt1:
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar_Pu8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg number.2{r0}, param.number{r8}
        ld   r0, #%00
        ld   r1, #%00
        sub  r1, r9
        sbc  r0, r8
        ; move number.1{r8}, number.2{r0}
        ld   r9, r1
        ld   r8, r0
if_1_end:
        ; move number.1{r0}, number.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint_Pi16[number.1{r0}]
        call printUint_Pi16
        ; const arg.2.0{r0}, 13
        ld   r0, #%0d
        ; call printChar_Pu8[arg.2.0{r0}]
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
        ; const foo.1{r0}, 22
        ld   r0, #%00
        ld   r1, #%16
        ; move bar.1{r2}, foo.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; mul bar.1{r2}, foo.1{r0}
        ld   %12, r2
        ld   %13, r3
        ld   %14, r0
        ld   %15, r1
        srp  #%10
        call %00BA ; mul
        srp  #%20
        ld   r2, %12
        ld   r3, %13
        ; const foo.2{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; add t.5.1{r2}, foo.2{r0}
        add  r3, r1
        adc  r2, r0
        ; move t.5.1{r0}, t.5.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; call printIntLf_Pi16[t.5.1{r0}]
        call printIntLf_Pi16
        ; const foo.3{r0}, 21
        ld   r0, #%00
        ld   r1, #%15
        ; call printIntLf_Pi16[foo.3{r0}]
        call printIntLf_Pi16
        ; const bazz.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; call printIntLf_Pi16[bazz.1{r0}]
        call printIntLf_Pi16
        ; const a.1{r8}, 1000
        ld   r8, #%03
        ld   r9, #%e8
        ; const b.1{r0}, 10
        ld   r0, #%00
        ld   r1, #%0a
        ; move t.6.1{r2}, a.1{r8}
        ld   r2, r8
        ld   r3, r9
        ; div t.6.1{r2}, b.1{r0}
        ld   %12, r2
        ld   %13, r3
        ld   %14, r0
        ld   %15, r1
        srp  #%10
        call %00E0 ; div
        srp  #%20
        ld   r2, %12
        ld   r3, %13
        ; move t.6.1{r0}, t.6.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; call printIntLf_Pi16[t.6.1{r0}]
        call printIntLf_Pi16
        ; move t.7.1{r0}, a.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; and t.7.1{r0}, 255
        clr  r0
        ; call printIntLf_Pi16[t.7.1{r0}]
        call printIntLf_Pi16
        ; const a.2{r0}, 10
        ld   r0, #%00
        ld   r1, #%0a
        ; const b.2{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; shiftright t.8.1{r0}, b.2{r2}
        or   r3, r3
        jr   z, .next2
        push r3
.shift2:
        sra  r0
        rrc  r1
        djnz r3, .shift2
        pop  r3
.next2:
        ; call printIntLf_Pi16[t.8.1{r0}]
        call printIntLf_Pi16
        ; const a.3{r0}, 9
        ld   r0, #%00
        ld   r1, #%09
        ; const b.3{r8}, 2
        ld   r8, #%00
        ld   r9, #%02
        ; shiftright t.9.1{r0}, b.3{r8}
        or   r9, r9
        jr   z, .next3
        push r9
.shift3:
        sra  r0
        rrc  r1
        djnz r9, .shift3
        pop  r9
.next3:
        ; call printIntLf_Pi16[t.9.1{r0}]
        call printIntLf_Pi16
        ; const a.4{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; shiftleft t.10.1{r0}, b.3{r8}
        or   r9, r9
        jr   z, .next4
        push r9
.shift4:
        rcf
        rlc  r1
        rlc  r0
        djnz r9, .shift4
        pop  r9
.next4:
        ; call printIntLf_Pi16[t.10.1{r0}]
        call printIntLf_Pi16
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void printChar_Pu8
printChar_Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

        ; void printUint_Pi32
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
