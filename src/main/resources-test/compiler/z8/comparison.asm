        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printIntLf@bool
        ; arg number (bool): r0
printIntLf_Pbool:
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
        ; const t.4{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.4{r0}]
        call printString_P_Pu8
        ; const a{r8}, 1
        ld   r8, #%00
        ld   r9, #%01
        ; const b{r10}, 2
        ld   r10, #%00
        ld   r11, #%02
        ; lt t.5{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   lt, .true1
        jr   ne, .false1
        cp   r9, r11
        jr   ult, .true1
.false1:
        ld   r0, #0
        jr   .1
.true1:
        ld   r0, #1
.1:
        ; call printIntLf@bool[t.5{r0}]
        call printIntLf_Pbool
        ; lt t.6{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   lt, .true2
        jr   ne, .false2
        cp   r11, r9
        jr   ult, .true2
.false2:
        ld   r0, #0
        jr   .2
.true2:
        ld   r0, #1
.2:
        ; call printIntLf@bool[t.6{r0}]
        call printIntLf_Pbool
        ; const t.7{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.7{r0}]
        call printString_P_Pu8
        ; const c{r12}, 0
        ld   r12, #%00
        ; const d{r13}, 128
        ld   r13, #%80
        ; lt t.8{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   ult, .true3
        ld   r0, #0  ; false
        jr   .3
.true3:
        ld   r0, #1
.3:
        ; call printIntLf@bool[t.8{r0}]
        call printIntLf_Pbool
        ; lt t.9{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   ult, .true4
        ld   r0, #0  ; false
        jr   .4
.true4:
        ld   r0, #1
.4:
        ; call printIntLf@bool[t.9{r0}]
        call printIntLf_Pbool
        ; const t.10{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.10{r0}]
        call printString_P_Pu8
        ; lteq t.11{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   lt, .true5
        jr   ne, .false5
        cp   r9, r11
        jr   ule, .true5
.false5:
        ld   r0, #0
        jr   .5
.true5:
        ld   r0, #1
.5:
        ; call printIntLf@bool[t.11{r0}]
        call printIntLf_Pbool
        ; lteq t.12{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   lt, .true6
        jr   ne, .false6
        cp   r11, r9
        jr   ule, .true6
.false6:
        ld   r0, #0
        jr   .6
.true6:
        ld   r0, #1
.6:
        ; call printIntLf@bool[t.12{r0}]
        call printIntLf_Pbool
        ; const t.13{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.13{r0}]
        call printString_P_Pu8
        ; lteq t.14{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   ule, .true7
        ld   r0, #0  ; false
        jr   .7
.true7:
        ld   r0, #1
.7:
        ; call printIntLf@bool[t.14{r0}]
        call printIntLf_Pbool
        ; lteq t.15{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   ule, .true8
        ld   r0, #0  ; false
        jr   .8
.true8:
        ld   r0, #1
.8:
        ; call printIntLf@bool[t.15{r0}]
        call printIntLf_Pbool
        ; const t.16{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString@@u8[t.16{r0}]
        call printString_P_Pu8
        ; equals t.17{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   ne, .ne9
        cp   r9, r11
        jr   ne, .ne9
        ld   r0, #1  ; true
        jr   .9
.ne9:
        ld   r0, #0
.9:
        ; call printIntLf@bool[t.17{r0}]
        call printIntLf_Pbool
        ; equals t.18{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   ne, .ne10
        cp   r11, r9
        jr   ne, .ne10
        ld   r0, #1  ; true
        jr   .10
.ne10:
        ld   r0, #0
.10:
        ; call printIntLf@bool[t.18{r0}]
        call printIntLf_Pbool
        ; const t.19{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString@@u8[t.19{r0}]
        call printString_P_Pu8
        ; notequals t.20{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   ne, .ne11
        cp   r9, r11
        jr   ne, .ne11
        ld   r0, #0  ; false
        jr   .11
.ne11:
        ld   r0, #1
.11:
        ; call printIntLf@bool[t.20{r0}]
        call printIntLf_Pbool
        ; notequals t.21{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   ne, .ne12
        cp   r11, r9
        jr   ne, .ne12
        ld   r0, #0  ; false
        jr   .12
.ne12:
        ld   r0, #1
.12:
        ; call printIntLf@bool[t.21{r0}]
        call printIntLf_Pbool
        ; const t.22{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString@@u8[t.22{r0}]
        call printString_P_Pu8
        ; gteq t.23{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   gt, .true13
        jr   ne, .false13
        cp   r9, r11
        jr   uge, .true13
.false13:
        ld   r0, #0
        jr   .13
.true13:
        ld   r0, #1
.13:
        ; call printIntLf@bool[t.23{r0}]
        call printIntLf_Pbool
        ; gteq t.24{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   gt, .true14
        jr   ne, .false14
        cp   r11, r9
        jr   uge, .true14
.false14:
        ld   r0, #0
        jr   .14
.true14:
        ld   r0, #1
.14:
        ; call printIntLf@bool[t.24{r0}]
        call printIntLf_Pbool
        ; const t.25{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
        ; call printString@@u8[t.25{r0}]
        call printString_P_Pu8
        ; gteq t.26{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   uge, .true15
        ld   r0, #0  ; false
        jr   .15
.true15:
        ld   r0, #1
.15:
        ; call printIntLf@bool[t.26{r0}]
        call printIntLf_Pbool
        ; gteq t.27{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   uge, .true16
        ld   r0, #0  ; false
        jr   .16
.true16:
        ld   r0, #1
.16:
        ; call printIntLf@bool[t.27{r0}]
        call printIntLf_Pbool
        ; const t.28{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString@@u8[t.28{r0}]
        call printString_P_Pu8
        ; gt t.29{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   gt, .true17
        jr   ne, .false17
        cp   r9, r11
        jr   ugt, .true17
.false17:
        ld   r0, #0
        jr   .17
.true17:
        ld   r0, #1
.17:
        ; call printIntLf@bool[t.29{r0}]
        call printIntLf_Pbool
        ; gt t.30{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   gt, .true18
        jr   ne, .false18
        cp   r11, r9
        jr   ugt, .true18
.false18:
        ld   r0, #0
        jr   .18
.true18:
        ld   r0, #1
.18:
        ; call printIntLf@bool[t.30{r0}]
        call printIntLf_Pbool
        ; const t.31{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString@@u8[t.31{r0}]
        call printString_P_Pu8
        ; gt t.32{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   ugt, .true19
        ld   r0, #0  ; false
        jr   .19
.true19:
        ld   r0, #1
.19:
        ; call printIntLf@bool[t.32{r0}]
        call printIntLf_Pbool
        ; gt t.33{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   ugt, .true20
        ld   r0, #0  ; false
        jr   .20
.true20:
        ld   r0, #1
.20:
        ; call printIntLf@bool[t.33{r0}]
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

