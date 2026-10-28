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

        ; void initRandom@i32
        ; arg salt (i32): r0
initRandom_Pi32:
        ; addrof a.2.1{r4}, __random__
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; store [a.2.1{r4}], t.1.1{r0}
        lde  @rr4, r0
        incw r4
        lde  @rr4, r1
        incw r4
        lde  @rr4, r2
        incw r4
        lde  @rr4, r3
        sub  r5, #3
        sbc  r4, #0
        ret

        ; i32 random
random:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; addrof a.5.1{r4}, __random__
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; load r.1{r6}, [a.5.1{r4}]
        lde  r6, @rr4
        incw r4
        lde  r7, @rr4
        incw r4
        lde  r8, @rr4
        incw r4
        lde  r9, @rr4
        sub  r5, #3
        sbc  r4, #0
        ; move t.6.1{r10}, r.1{r6}
        ld   r13, r9
        ld   r12, r8
        ld   r11, r7
        ld   r10, r6
        ; and t.6.1{r10}, 524287
        and  r11, #%07
        clr  r10
        ; mul b.1{r10}, 48271
        Not supported yet: mul/div/mod for i32
        ; move t.7.1{r4}, r.1{r6}
        ld   r4, r6
        ld   r5, r7
        ld   r6, r8
        ld   r7, r9
        ; shiftright t.7.1{r4}, 15
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        ; mul c.1{r4}, 48271
        Not supported yet: mul/div/mod for i32
        ; move t.8.1{r0}, c.1{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.8.1{r0}, 65535
        clr  r1
        clr  r0
        ; shiftleft d.1{r0}, 15
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        add r3, r3
        adc r2, r2
        adc r1, r1
        adc r0, r0
        ; shiftright t.10.1{r4}, 16
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        ; add t.9.1{r4}, b.1{r10}
        add  r7, r13
        adc  r6, r12
        adc  r5, r11
        adc  r4, r10
        ; add e.1{r4}, d.1{r0}
        add  r7, r3
        adc  r6, r2
        adc  r5, r1
        adc  r4, r0
        ; move t.12.1{r8}, e.1{r4}
        ld   r11, r7
        ld   r10, r6
        ld   r9, r5
        ld   r8, r4
        ; and t.12.1{r8}, 2147483647
        and  r8, #%7f
        ; shiftright t.13.1{r4}, 31
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        ; add t.11.1{r8}, t.13.1{r4}
        add  r11, r7
        adc  r10, r6
        adc  r9, r5
        adc  r8, r4
        ; addrof a.14.1{r4}, __random__
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; store [a.14.1{r4}], t.11.1{r8}
        lde  @rr4, r8
        incw r4
        lde  @rr4, r9
        incw r4
        lde  @rr4, r10
        incw r4
        lde  @rr4, r11
        sub  r5, #3
        sbc  r4, #0
        ; 15:9 return __random__
        ; move t.16.1{r0}, t.16.1{r8}
        ld   r0, r8
        ld   r1, r9
        ld   r2, r10
        ld   r3, r11
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; u8 randomU8
randomU8:
        ; 19:21 return (u8)
        ; call t.1.1{r0} = random[] -> i32
        call random
        ; cast t.0.1{r0}(u8), t.1.1{r0}(i32)
        ld   r0, r3
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; begin initialize global variables
        ; const t.2.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%00
        ; addrof a.3.1{r12}, __random__
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; store [a.3.1{r12}], t.2.1{r8}
        lde  @rr12, r8
        incw r12
        lde  @rr12, r9
        incw r12
        lde  @rr12, r10
        incw r12
        lde  @rr12, r11
        sub  r13, #3
        sbc  r12, #0
        ; end initialize global variables
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom@i32[arg.0.0{r0}]
        call initRandom_Pi32
        ; const i.1{r8}, 0
        ld   r8, #%00
        ; 6:2 for i < 50
        jr   for__2

for__2__body:
        ; call r.1{r0} = randomU8[] -> u8
        call randomU8
        ; call printIntLf@u8[r.1{r0}]
        call printIntLf_Pu8
        ; move i.3{r0}, i.2{r8}
        ld   r0, r8
        ; add i.3{r0}, 1
        inc  r0
        ; move i.2{r8}, i.3{r0}
        ld   r8, r0
for__2:
        ; branch i.2{r8} lt 50: for_2_body
        cp   r8, #%32
        jr   ult, for__2__body
        ; restore clobbered non-volatile registers
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

        ; variable 0: __random__ (i32/4)
var_0:
        .data %00 %00 %00 %00
