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
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
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
        jr   uge, .false1
.true1:
        ld   r0, #1
        jr   .1
.false1:
        ld   r0, #0
.1:
        ; call printIntLf@bool[t.5{r0}]
        call printIntLf_Pbool
        ; lt t.6{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   lt, .true2
        jr   ne, .false2
        cp   r11, r9
        jr   uge, .false2
.true2:
        ld   r0, #1
        jr   .2
.false2:
        ld   r0, #0
.2:
        ; call printIntLf@bool[t.6{r0}]
        call printIntLf_Pbool
        ; const t.7{r0}, [string-1]
        ld   r0, #hi(string__1)
        ld   r1, #lo(string__1)
        ; call printString@@u8[t.7{r0}]
        call printString_P_Pu8
        ; const c{r12}, 0
        ld   r12, #%00
        ; const d{r13}, 128
        ld   r13, #%80
        ; lt t.8{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   uge, .false3
.true3:
        ld   r0, #1
        jr   .3
.false3:
        ld   r0, #0
.3:
        ; call printIntLf@bool[t.8{r0}]
        call printIntLf_Pbool
        ; lt t.9{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   uge, .false4
.true4:
        ld   r0, #1
        jr   .4
.false4:
        ld   r0, #0
.4:
        ; call printIntLf@bool[t.9{r0}]
        call printIntLf_Pbool
        ; const t.10{r0}, [string-2]
        ld   r0, #hi(string__2)
        ld   r1, #lo(string__2)
        ; call printString@@u8[t.10{r0}]
        call printString_P_Pu8
        ; lteq t.11{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   le, .true5
        jr   ne, .false5
        cp   r9, r11
        jr   ugt, .false5
.true5:
        ld   r0, #1
        jr   .5
.false5:
        ld   r0, #0
.5:
        ; call printIntLf@bool[t.11{r0}]
        call printIntLf_Pbool
        ; lteq t.12{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   le, .true6
        jr   ne, .false6
        cp   r11, r9
        jr   ugt, .false6
.true6:
        ld   r0, #1
        jr   .6
.false6:
        ld   r0, #0
.6:
        ; call printIntLf@bool[t.12{r0}]
        call printIntLf_Pbool
        ; const t.13{r0}, [string-3]
        ld   r0, #hi(string__3)
        ld   r1, #lo(string__3)
        ; call printString@@u8[t.13{r0}]
        call printString_P_Pu8
        ; lteq t.14{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   ugt, .false7
.true7:
        ld   r0, #1
        jr   .7
.false7:
        ld   r0, #0
.7:
        ; call printIntLf@bool[t.14{r0}]
        call printIntLf_Pbool
        ; lteq t.15{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   ugt, .false8
.true8:
        ld   r0, #1
        jr   .8
.false8:
        ld   r0, #0
.8:
        ; call printIntLf@bool[t.15{r0}]
        call printIntLf_Pbool
        ; const t.16{r0}, [string-4]
        ld   r0, #hi(string__4)
        ld   r1, #lo(string__4)
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
        ld   r0, #hi(string__5)
        ld   r1, #lo(string__5)
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
        ld   r0, #hi(string__6)
        ld   r1, #lo(string__6)
        ; call printString@@u8[t.22{r0}]
        call printString_P_Pu8
        ; gteq t.23{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   ge, .true13
        jr   ne, .false13
        cp   r9, r11
        jr   ult, .false13
.true13:
        ld   r0, #1
        jr   .13
.false13:
        ld   r0, #0
.13:
        ; call printIntLf@bool[t.23{r0}]
        call printIntLf_Pbool
        ; gteq t.24{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   ge, .true14
        jr   ne, .false14
        cp   r11, r9
        jr   ult, .false14
.true14:
        ld   r0, #1
        jr   .14
.false14:
        ld   r0, #0
.14:
        ; call printIntLf@bool[t.24{r0}]
        call printIntLf_Pbool
        ; const t.25{r0}, [string-7]
        ld   r0, #hi(string__7)
        ld   r1, #lo(string__7)
        ; call printString@@u8[t.25{r0}]
        call printString_P_Pu8
        ; gteq t.26{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   ult, .false15
.true15:
        ld   r0, #1
        jr   .15
.false15:
        ld   r0, #0
.15:
        ; call printIntLf@bool[t.26{r0}]
        call printIntLf_Pbool
        ; gteq t.27{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   ult, .false16
.true16:
        ld   r0, #1
        jr   .16
.false16:
        ld   r0, #0
.16:
        ; call printIntLf@bool[t.27{r0}]
        call printIntLf_Pbool
        ; const t.28{r0}, [string-8]
        ld   r0, #hi(string__8)
        ld   r1, #lo(string__8)
        ; call printString@@u8[t.28{r0}]
        call printString_P_Pu8
        ; gt t.29{r0}, a{r8}, b{r10}
        cp   r8, r10
        jr   gt, .true17
        jr   ne, .false17
        cp   r9, r11
        jr   ule, .false17
.true17:
        ld   r0, #1
        jr   .17
.false17:
        ld   r0, #0
.17:
        ; call printIntLf@bool[t.29{r0}]
        call printIntLf_Pbool
        ; gt t.30{r0}, b{r10}, a{r8}
        cp   r10, r8
        jr   gt, .true18
        jr   ne, .false18
        cp   r11, r9
        jr   ule, .false18
.true18:
        ld   r0, #1
        jr   .18
.false18:
        ld   r0, #0
.18:
        ; call printIntLf@bool[t.30{r0}]
        call printIntLf_Pbool
        ; const t.31{r0}, [string-9]
        ld   r0, #hi(string__9)
        ld   r1, #lo(string__9)
        ; call printString@@u8[t.31{r0}]
        call printString_P_Pu8
        ; gt t.32{r0}, c{r12}, d{r13}
        cp   r12, r13
        jr   ule, .false19
.true19:
        ld   r0, #1
        jr   .19
.false19:
        ld   r0, #0
.19:
        ; call printIntLf@bool[t.32{r0}]
        call printIntLf_Pbool
        ; gt t.33{r0}, d{r13}, c{r12}
        cp   r13, r12
        jr   ule, .false20
.true20:
        ld   r0, #1
        jr   .20
.false20:
        ld   r0, #0
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

string__0:
        .data "< (signed)" %0a %00
string__1:
        .data "< (unsigned)" %0a %00
string__2:
        .data "<= (signed)" %0a %00
string__3:
        .data "<= (unsigned)" %0a %00
string__4:
        .data "==" %0a %00
string__5:
        .data "!=" %0a %00
string__6:
        .data ">= (signed)" %0a %00
string__7:
        .data ">= (unsigned)" %0a %00
string__8:
        .data "> (signed)" %0a %00
string__9:
        .data "> (unsigned)" %0a %00

