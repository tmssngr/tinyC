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
        ; begin initialize global variables
        ; const t.0.1{r0}, 32
        ld   r0, #%00
        ld   r1, #%20
        ; addrof a.1.1{r2}, space
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; store [a.1.1{r2}], t.0.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; const t.2.1{r0}, 63
        ld   r0, #%00
        ld   r1, #%3f
        ; addrof a.3.1{r2}, next
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; store [a.3.1{r2}], t.2.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; addrof t.4.1{r0}, space
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; addrof a.5.1{r2}, ptrToSpace
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.5.1{r2}], t.4.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; end initialize global variables
        ; addrof a.6.1{r0}, next
        ld   r0, #hi(var_1)
        ld   r1, #lo(var_1)
        ; load t.7.1{r2}, [a.6.1{r0}]
        lde  r2, @rr0
        incw r0
        lde  r3, @rr0
        decw r0
        ; move t.7.1{r0}, t.7.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; call printIntLf_Pi16[t.7.1{r0}]
        call printIntLf_Pi16
        ; addrof a.9.1{r0}, ptrToSpace
        ld   r0, #hi(var_2)
        ld   r1, #lo(var_2)
        ; load t.10.1{r2}, [a.9.1{r0}]
        lde  r2, @rr0
        incw r0
        lde  r3, @rr0
        decw r0
        ; move t.8.1{r0}, t.10.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.8.1{r0}, 2
        add  r1, #%02
        adc  r0, #%00
        ; addrof a.11.1{r2}, ptrToSpace
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.11.1{r2}], t.8.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; move a.13.1{r0}, a.13.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; load t.14.1{r2}, [a.13.1{r0}]
        lde  r2, @rr0
        incw r0
        lde  r3, @rr0
        decw r0
        ; load t.12.1{r0}, [t.14.1{r2}]
        lde  r0, @rr2
        incw r2
        lde  r1, @rr2
        decw r2
        ; call printIntLf_Pi16[t.12.1{r0}]
        call printIntLf_Pi16
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

        ; variable 0: space (i16/2)
var_0:
        .data %00 %00
        ; variable 1: next (i16/2)
var_1:
        .data %00 %00
        ; variable 2: ptrToSpace (i16*/2)
var_2:
        .data %00 %00
