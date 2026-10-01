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

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf_Pu8:
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
        push r12
        push r13
        ; begin initialize global variables
        ; const t.2.1{r8}, [string-0]
        ld   r8, #hi(string_0)
        ld   r9, #lo(string_0)
        ; addrof a.3.1{r10}, text
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; store [a.3.1{r10}], t.2.1{r8}
        lde  @rr10, r8
        incw r10
        lde  @rr10, r9
        decw r10
        ; end initialize global variables
        ; move a.4.1{r8}, a.4.1{r10}
        ld   r8, r10
        ld   r9, r11
        ; load t.5.1{r0}, [a.4.1{r8}]
        lde  r0, @rr8
        incw r8
        lde  r1, @rr8
        decw r8
        ; call printString@@u8[t.5.1{r0}]
        call printString_P_Pu8
        ; call printLength[]
        call printLength
        ; const t.6.1{r8}, 1
        ld   r8, #%00
        ld   r9, #%01
        ; load second.1{r12}, [a.7.1{r10}]
        lde  r12, @rr10
        incw r10
        lde  r13, @rr10
        decw r10
        ; move second.2{r0}, second.1{r12}
        ld   r0, r12
        ld   r1, r13
        ; add second.2{r0}, t.6.1{r8}
        add  r1, r9
        adc  r0, r8
        ; call printString@@u8[second.2{r0}]
        call printString_P_Pu8
        ; move a.8.1{r8}, a.8.1{r10}
        ld   r8, r10
        ld   r9, r11
        ; move t.9.1{r10}, t.9.1{r12}
        ld   r10, r12
        ld   r11, r13
        ; load chr.1{r0}, [t.9.1{r10}]
        lde  r0, @rr10
        ; call printIntLf@u8[chr.1{r0}]
        call printIntLf_Pu8
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printLength
printLength:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const length.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; addrof a.2.1{r10}, text
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; load ptr.1{r12}, [a.2.1{r10}]
        lde  r12, @rr10
        incw r10
        lde  r13, @rr10
        decw r10
        ; 16:2 for *ptr != 0
        ; move length.2{r0}, length.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; move ptr.2{r8}, ptr.1{r12}
        ld   r8, r12
        ld   r9, r13
        jr   for__2

for__2__body:
        ; move length.3{r10}, length.2{r0}
        ld   r11, r1
        ld   r10, r0
        ; add length.3{r10}, 1
        incw r10
        ; add ptr.3{r8}, 1
        incw r8
        ; move length.2{r0}, length.3{r10}
        ld   r0, r10
        ld   r1, r11
for__2:
        ; load t.3.1{r10}, [ptr.2{r8}]
        lde  r10, @rr8
        ; branch t.3.1{r10} notequals 0: for_2_body
        cp   r10, #%00
        jr   ne, for__2__body
        ; call printIntLf@i16[length.2{r0}]
        call printIntLf_Pi16
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printString@@u8
printString_P_Pu8:
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

        ; variable 0: text (u8*/2)
var_0:
        .data %00 %00

string_0:
        .data "hello world" %0a %00

