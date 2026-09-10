        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printUint@i16
        ; arg number (i16): r0
printUint__Pi16:
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

        ; void printIntLf@u8
        ; arg number (u8): r0
printIntLf__Pu8:
        ret

        ; void printIntLf@i16
        ; arg number (i16): r0
printIntLf__Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.number{r8}, number{r0}
        ld   r9, r1
        ld   r8, r0
        ; 127:2 if number < 0
        ; branch param.number{r8} gteq 0: if_1_end, if_1_then
        cp   r8, #%00
        jr   ge, .1
        jr   ne, if__1__end
        cp   r9, #%00
        jr   uge, if__1__end
.1:
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg param.number{r8}, param.number{r8}
        com  r8
        com  r9
        incw r8
if____1____end:
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
        ; begin initialize global variables
        ; const tmp.text{r8}, [string-0]
        ld   r8, #hi(string__0)
        ld   r9, #lo(string__0)
        ; end initialize global variables
        ; addrof memVarAddr{r14}, text
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.text{r8}
        lde  @rr14, r8
        incw r14
        lde  @rr14, r9
        ; move tmp.text{r0}, tmp.text{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printString@@u8[tmp.text{r0}]
        call printString_P_Pu8
        ; call printLength[]
        call printLength
        ; const t.2{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; addrof memVarAddr{r14}, text
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.text{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        ; move second{r0}, tmp.text{r8}
        ld   r0, r8
        ld   r1, r9
        ; add second{r0}, second{r0}, t.2{r10}
        add  r1, r11
        adc  r0, r10
        ; call printString@@u8[second{r0}]
        call printString_P_Pu8
        ; addrof memVarAddr{r14}, text
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.text{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        ; load chr{r0}, [tmp.text{r8}]
        lde  r0, @rr8
        ; call printIntLf@u8[chr{r0}]
        call printIntLf_Pu8
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

        ; void printLength
printLength:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; const length{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; addrof memVarAddr{r14}, text
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.text{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        ; 16:2 for *ptr != 0
        jr   for__2

for____2____body:
        ; add length{r0}, length{r0}, 1
        incw r0
        ; add ptr{r8}, ptr{r8}, 1
        incw r8
for____2:
        ; load t.2{r10}, [ptr{r8}]
        lde  r10, @rr8
        ; branch t.2{r10} notequals 0: for_2_body, for_2_break
        cp   r10, #%00
        jr   ne, for__2__body
.2:
        ; call printIntLf@i16[length{r0}]
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

        ; void printString@@u8
printString__P__Pu8:
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
printChar__Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

        ; void printUint@i32
printUint__Pi32:
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
var__0:
        .data %00 %00

string__0:
        .data "hello world" %0a %00

