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
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; call printUint@i32[t.1.1{r0}]
        call printUint_Pi32
        ret

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf_Pu8:
        ; cast t.1.1{r0}(i16), param.number{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; call printIntLf@i16[t.1.1{r0}]
        call printIntLf_Pi16
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
        ; begin initialize global variables
        ; const t.0.1{r8}, 0
        ld   r8, #%00
        ; addrof a.1.1{r10}, i
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; store [a.1.1{r10}], t.0.1{r8}
        lde  @rr10, r8
        ; end initialize global variables
        ; call t.2.1{r0} = next[] -> u8
        call next
        ; move t.2.1{r8}, t.2.1{r0}
        ld   r8, r0
        ; call t.3.1{r0} = next[] -> u8
        call next
        ; move t.3.1{r9}, t.3.1{r0}
        ld   r9, r0
        ; call t.4.1{r0} = next[] -> u8
        call next
        ; move t.4.1{r10}, t.4.1{r0}
        ld   r10, r0
        ; call t.5.1{r0} = next[] -> u8
        call next
        ; move t.5.1{r11}, t.5.1{r0}
        ld   r11, r0
        ; call t.6.1{r0} = next[] -> u8
        call next
        ; move t.6.1{r4}, t.6.1{r0}
        ld   r4, r0
        ; move t.2.1{r0}, t.2.1{r8}
        ld   r0, r8
        ; move t.3.1{r1}, t.3.1{r9}
        ld   r1, r9
        ; move t.4.1{r2}, t.4.1{r10}
        ld   r2, r10
        ; move t.5.1{r3}, t.5.1{r11}
        ld   r3, r11
        ; call doPrint@u8@u8@u8@u8@u8[t.2.1{r0}, t.3.1{r1}, t.4.1{r2}, t.5.1{r3}, t.6.1{r4}]
        call doPrint_Pu8_Pu8_Pu8_Pu8_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; u8 next
next:
        ; addrof a.1.1{r2}, i
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; load t.2.1{r1}, [a.1.1{r2}]
        lde  r1, @rr2
        ; add t.0.1{r1}, 1
        inc  r1
        ; store [a.3.1{r2}], t.0.1{r1}
        lde  @rr2, r1
        ; 11:9 return i
        ; move t.5.1{r0}, t.5.1{r1}
        ld   r0, r1
        ret

        ; void doPrint@u8@u8@u8@u8@u8
        ; arg a (u8): r0
        ; arg b (u8): r1
        ; arg c (u8): r2
        ; arg d (u8): r3
        ; arg e (u8): r4
doPrint_Pu8_Pu8_Pu8_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move param.b{r8}, b{r1}
        ld   r8, r1
        ; move param.c{r9}, c{r2}
        ld   r9, r2
        ; move param.d{r10}, d{r3}
        ld   r10, r3
        ; move param.e{r11}, e{r4}
        ld   r11, r4
        ; call printIntLf@u8[param.a{r0}]
        call printIntLf_Pu8
        ; move param.b{r0}, param.b{r8}
        ld   r0, r8
        ; call printIntLf@u8[param.b{r0}]
        call printIntLf_Pu8
        ; move param.c{r0}, param.c{r9}
        ld   r0, r9
        ; call printIntLf@u8[param.c{r0}]
        call printIntLf_Pu8
        ; move param.d{r0}, param.d{r10}
        ld   r0, r10
        ; call printIntLf@u8[param.d{r0}]
        call printIntLf_Pu8
        ; move param.e{r0}, param.e{r11}
        ld   r0, r11
        ; call printIntLf@u8[param.e{r0}]
        call printIntLf_Pu8
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

        ; variable 0: i (u8/1)
var_0:
        .data %00
