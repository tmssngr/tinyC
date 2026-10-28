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

        ; void printIntLf@bool
        ; arg value (bool): r0
printIntLf_Pbool:
        ; save clobbered non-volatile registers
        push r8
        ; const number.1{r8}, 0
        ld   r8, #%00
        ; 122:2 if value
        ; branch param.value{r0} equals 0: if_1_end
        cp   r0, #%00
        jr   eq, if__1__end
        ; const number.3{r8}, 1
        ld   r8, #%01
if__1__end:
        ; cast t.2.1{r0}(i16), number.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; call printIntLf@i16[t.2.1{r0}]
        call printIntLf_Pi16
        ; restore clobbered non-volatile registers
        pop  r8
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
        ; branch param.number{r8} gteq 0: if_2_end
        cp   r8, #%00
        jr   gt, if__2__end
        jr   ne, .gt1
        cp   r9, #%00
        jr   uge, if__2__end
.gt1:
        ; const arg.0.0{r0}, 45
        ld   r0, #%2d
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; neg number.2{r8}, param.number{r8}
        com  r8
        com  r9
        incw r8
if__2__end:
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
        ; const t.4.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.4.1{r0}]
        call printString_P_Pu8
        ; const a.1{r8}, 1
        ld   r8, #%00
        ld   r9, #%01
        ; const b.1{r10}, 2
        ld   r10, #%00
        ld   r11, #%02
        ; lt t.5.1{r0}, a.1{r8}, b.1{r10}
        cp   r8, r10
        jr   lt, .true2
        jr   ne, .false2
        cp   r9, r11
        jr   ult, .true2
.false2:
        ld   r0, #0
        jr   .2
.true2:
        ld   r0, #1
.2:
        ; call printIntLf@bool[t.5.1{r0}]
        call printIntLf_Pbool
        ; lt t.6.1{r0}, b.1{r10}, a.1{r8}
        cp   r10, r8
        jr   lt, .true3
        jr   ne, .false3
        cp   r11, r9
        jr   ult, .true3
.false3:
        ld   r0, #0
        jr   .3
.true3:
        ld   r0, #1
.3:
        ; call printIntLf@bool[t.6.1{r0}]
        call printIntLf_Pbool
        ; const t.7.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.7.1{r0}]
        call printString_P_Pu8
        ; const c.1{r12}, 0
        ld   r12, #%00
        ; const d.1{r13}, 128
        ld   r13, #%80
        ; lt t.8.1{r0}, c.1{r12}, d.1{r13}
        cp   r12, r13
        jr   ult, .true4
        ld   r0, #0  ; false
        jr   .4
.true4:
        ld   r0, #1
.4:
        ; call printIntLf@bool[t.8.1{r0}]
        call printIntLf_Pbool
        ; lt t.9.1{r0}, d.1{r13}, c.1{r12}
        cp   r13, r12
        jr   ult, .true5
        ld   r0, #0  ; false
        jr   .5
.true5:
        ld   r0, #1
.5:
        ; call printIntLf@bool[t.9.1{r0}]
        call printIntLf_Pbool
        ; const t.10.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.10.1{r0}]
        call printString_P_Pu8
        ; lteq t.11.1{r0}, a.1{r8}, b.1{r10}
        cp   r8, r10
        jr   lt, .true6
        jr   ne, .false6
        cp   r9, r11
        jr   ule, .true6
.false6:
        ld   r0, #0
        jr   .6
.true6:
        ld   r0, #1
.6:
        ; call printIntLf@bool[t.11.1{r0}]
        call printIntLf_Pbool
        ; lteq t.12.1{r0}, b.1{r10}, a.1{r8}
        cp   r10, r8
        jr   lt, .true7
        jr   ne, .false7
        cp   r11, r9
        jr   ule, .true7
.false7:
        ld   r0, #0
        jr   .7
.true7:
        ld   r0, #1
.7:
        ; call printIntLf@bool[t.12.1{r0}]
        call printIntLf_Pbool
        ; const t.13.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.13.1{r0}]
        call printString_P_Pu8
        ; lteq t.14.1{r0}, c.1{r12}, d.1{r13}
        cp   r12, r13
        jr   ule, .true8
        ld   r0, #0  ; false
        jr   .8
.true8:
        ld   r0, #1
.8:
        ; call printIntLf@bool[t.14.1{r0}]
        call printIntLf_Pbool
        ; lteq t.15.1{r0}, d.1{r13}, c.1{r12}
        cp   r13, r12
        jr   ule, .true9
        ld   r0, #0  ; false
        jr   .9
.true9:
        ld   r0, #1
.9:
        ; call printIntLf@bool[t.15.1{r0}]
        call printIntLf_Pbool
        ; const t.16.1{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString@@u8[t.16.1{r0}]
        call printString_P_Pu8
        ; equals t.17.1{r0}, a.1{r8}, b.1{r10}
        cp   r8, r10
        jr   ne, .ne10
        cp   r9, r11
        jr   ne, .ne10
        ld   r0, #1  ; true
        jr   .10
.ne10:
        ld   r0, #0
.10:
        ; call printIntLf@bool[t.17.1{r0}]
        call printIntLf_Pbool
        ; equals t.18.1{r0}, b.1{r10}, a.1{r8}
        cp   r10, r8
        jr   ne, .ne11
        cp   r11, r9
        jr   ne, .ne11
        ld   r0, #1  ; true
        jr   .11
.ne11:
        ld   r0, #0
.11:
        ; call printIntLf@bool[t.18.1{r0}]
        call printIntLf_Pbool
        ; const t.19.1{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString@@u8[t.19.1{r0}]
        call printString_P_Pu8
        ; notequals t.20.1{r0}, a.1{r8}, b.1{r10}
        cp   r8, r10
        jr   ne, .ne12
        cp   r9, r11
        jr   ne, .ne12
        ld   r0, #0  ; false
        jr   .12
.ne12:
        ld   r0, #1
.12:
        ; call printIntLf@bool[t.20.1{r0}]
        call printIntLf_Pbool
        ; notequals t.21.1{r0}, b.1{r10}, a.1{r8}
        cp   r10, r8
        jr   ne, .ne13
        cp   r11, r9
        jr   ne, .ne13
        ld   r0, #0  ; false
        jr   .13
.ne13:
        ld   r0, #1
.13:
        ; call printIntLf@bool[t.21.1{r0}]
        call printIntLf_Pbool
        ; const t.22.1{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString@@u8[t.22.1{r0}]
        call printString_P_Pu8
        ; gteq t.23.1{r0}, a.1{r8}, b.1{r10}
        cp   r8, r10
        jr   gt, .true14
        jr   ne, .false14
        cp   r9, r11
        jr   uge, .true14
.false14:
        ld   r0, #0
        jr   .14
.true14:
        ld   r0, #1
.14:
        ; call printIntLf@bool[t.23.1{r0}]
        call printIntLf_Pbool
        ; gteq t.24.1{r0}, b.1{r10}, a.1{r8}
        cp   r10, r8
        jr   gt, .true15
        jr   ne, .false15
        cp   r11, r9
        jr   uge, .true15
.false15:
        ld   r0, #0
        jr   .15
.true15:
        ld   r0, #1
.15:
        ; call printIntLf@bool[t.24.1{r0}]
        call printIntLf_Pbool
        ; const t.25.1{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
        ; call printString@@u8[t.25.1{r0}]
        call printString_P_Pu8
        ; gteq t.26.1{r0}, c.1{r12}, d.1{r13}
        cp   r12, r13
        jr   uge, .true16
        ld   r0, #0  ; false
        jr   .16
.true16:
        ld   r0, #1
.16:
        ; call printIntLf@bool[t.26.1{r0}]
        call printIntLf_Pbool
        ; gteq t.27.1{r0}, d.1{r13}, c.1{r12}
        cp   r13, r12
        jr   uge, .true17
        ld   r0, #0  ; false
        jr   .17
.true17:
        ld   r0, #1
.17:
        ; call printIntLf@bool[t.27.1{r0}]
        call printIntLf_Pbool
        ; const t.28.1{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString@@u8[t.28.1{r0}]
        call printString_P_Pu8
        ; gt t.29.1{r0}, a.1{r8}, b.1{r10}
        cp   r8, r10
        jr   gt, .true18
        jr   ne, .false18
        cp   r9, r11
        jr   ugt, .true18
.false18:
        ld   r0, #0
        jr   .18
.true18:
        ld   r0, #1
.18:
        ; call printIntLf@bool[t.29.1{r0}]
        call printIntLf_Pbool
        ; gt t.30.1{r0}, b.1{r10}, a.1{r8}
        cp   r10, r8
        jr   gt, .true19
        jr   ne, .false19
        cp   r11, r9
        jr   ugt, .true19
.false19:
        ld   r0, #0
        jr   .19
.true19:
        ld   r0, #1
.19:
        ; call printIntLf@bool[t.30.1{r0}]
        call printIntLf_Pbool
        ; const t.31.1{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString@@u8[t.31.1{r0}]
        call printString_P_Pu8
        ; gt t.32.1{r0}, c.1{r12}, d.1{r13}
        cp   r12, r13
        jr   ugt, .true20
        ld   r0, #0  ; false
        jr   .20
.true20:
        ld   r0, #1
.20:
        ; call printIntLf@bool[t.32.1{r0}]
        call printIntLf_Pbool
        ; gt t.33.1{r0}, d.1{r13}, c.1{r12}
        cp   r13, r12
        jr   ugt, .true21
        ld   r0, #0  ; false
        jr   .21
.true21:
        ld   r0, #1
.21:
        ; call printIntLf@bool[t.33.1{r0}]
        call printIntLf_Pbool
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

string_0:
        .data "< (signed)" %0a %00
string_1:
        .data "< (unsigned)" %0a %00
string_2:
        .data "<= (signed)" %0a %00
string_3:
        .data "<= (unsigned)" %0a %00
string_4:
        .data "==" %0a %00
string_5:
        .data "!=" %0a %00
string_6:
        .data ">= (signed)" %0a %00
string_7:
        .data ">= (unsigned)" %0a %00
string_8:
        .data "> (signed)" %0a %00
string_9:
        .data "> (unsigned)" %0a %00

