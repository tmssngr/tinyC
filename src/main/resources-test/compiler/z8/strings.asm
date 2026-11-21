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

        ; void printIntLf_Pu8
        ; arg number (u8): r0
printIntLf_Pu8:
        ; cast t.1.1{r0}(i16), param.number{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; call printIntLf_Pi16[t.1.1{r0}]
        call printIntLf_Pi16
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
        ; const t.2.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; addrof a.3.1{r2}, text
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; store [a.3.1{r2}], t.2.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; end initialize global variables
        ; move a.4.1{r0}, a.4.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; load t.5.1{r2}, [a.4.1{r0}]
        lde  r2, @rr0
        incw r0
        lde  r3, @rr0
        decw r0
        ; move t.5.1{r0}, t.5.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; call printString_P_pu8[t.5.1{r0}]
        call printString_P_pu8
        ; call printLength[]
        call printLength
        ; const t.6.1{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; addrof a.7.1{r2}, text
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; load second.1{r4}, [a.7.1{r2}]
        lde  r4, @rr2
        incw r2
        lde  r5, @rr2
        decw r2
        ; move second.2{r2}, second.1{r4}
        ld   r2, r4
        ld   r3, r5
        ; add second.2{r2}, t.6.1{r0}
        add  r3, r1
        adc  r2, r0
        ; move second.2{r0}, second.2{r2}
        ld   r0, r2
        ld   r1, r3
        ; call printString_P_pu8[second.2{r0}]
        call printString_P_pu8
        ; addrof a.8.1{r0}, text
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; load t.9.1{r2}, [a.8.1{r0}]
        lde  r2, @rr0
        incw r0
        lde  r3, @rr0
        decw r0
        ; load chr.1{r0}, [t.9.1{r2}]
        lde  r0, @rr2
        ; call printIntLf_Pu8[chr.1{r0}]
        call printIntLf_Pu8
        ret

        ; void printLength
printLength:
        ; const length.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; addrof a.2.1{r2}, text
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; load ptr.1{r4}, [a.2.1{r2}]
        lde  r4, @rr2
        incw r2
        lde  r5, @rr2
        decw r2
        ; 16:2 for *ptr != 0
        ; move ptr.2{r2}, ptr.1{r4}
        ld   r2, r4
        ld   r3, r5
        jr   for_2

for_2_body:
        ; add length.3{r0}, 1
        incw r0
        ; add ptr.3{r2}, 1
        incw r2
for_2:
        ; load t.3.1{r4}, [ptr.2{r2}]
        lde  r4, @rr2
        ; branch t.3.1{r4} notequals 0: for_2_body
        cp   r4, #%00
        jr   ne, for_2_body
        ; call printIntLf_Pi16[length.2{r0}]
        call printIntLf_Pi16
        ret

        ; void printString_P_pu8
printString_P_pu8:
        ld   r2, r0
        ld   r3, r1
        jr   .loop
.print:
        call printChar_Pu8
        incw r2
.loop:
        lde  r0, @rr2
        or   r0, r0
        jr   nz, .print
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

        ; variable 0: text (u8*/2)
var_0:
        .data %00 %00

string_0:
        .data "hello world" %0a %00

