        .const RP  = %FD
        .const SPH = %FE
        .const SPL = %FF

        .org %E000

start:
        push RP
        srp  #%20
        call @main
        pop  RP
        ret

        ; void printString
        ;   sp+7: arg str
@printString:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move str{r8}, str{r0}
        ld r8, r0
        ld r9, r1
        ; 2:2 while true
        jp @while_1
@if_2_end:
        ; move chr{r0}, chr{r10}
        ld r0, r10
        ; call printChar[chr{r0}]
        call printChar
@while_1:
        ; load chr{r10}, [str{r8}]
        lde r10, rr8
        ; 4:3 if chr == 0
        ; equals t.2{r0}, chr{r10}, 0
        cp  r10, #%00
        jr  nz, .1
        cp  r11, #%00
        jr  nz, .1
        cp  r12, #%00
        jr  nz, .1
        cp  r13, #%00
        jr  nz, .1
        cp  r14, #%00
        jr  nz, .1
        cp  r15, #%00
        jr  nz, .1
        cp  %30, #%00
        jr  nz, .1
        cp  %31, #%00
        jr  nz, .1
        cp  %32, #%00
        jr  nz, .1
        cp  %33, #%00
        jr  nz, .1
        cp  %34, #%00
        jr  nz, .1
        cp  %35, #%00
        jr  nz, .1
        cp  %36, #%00
        jr  nz, .1
        cp  %37, #%00
        jr  nz, .1
        cp  %38, #%00
        jr  nz, .1
        cp  %39, #%00
        jr  nz, .1
        ld  r0, #%ff
        jr  .2
.1:
        ld  r0, #%00
.2:
        ; branch t.2{r0}, false, @if_2_end
        or r0, r0
        jp z, @if_2_end
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printNibble
        ;   sp+4: arg x
@printNibble:
        ; save globbered non-volatile registers
        push r8
        push r9
        ; const t.1{r8}, 15
        ld r8, #%0f
        ; and x{r0}, x{r0}, t.1{r8}
        and r0, r8
        ; 5:2 if x > 9
        ; gt t.2{r8}, x{r0}, 9
        cp  r0, #%09
        jr  uge, .3
.3:
        ld  r8, #%ff
        jr  .5
.4:
        ld  r8, #%00
.5:
        ; branch t.2{r8}, false, @if_3_end
        or r8, r8
        jp z, @if_3_end
        ; add x{r0}, 7
        add r0, #%07
@if_3_end:
        ; add x{r0}, 48
        add r0, #%30
        ; call printChar[x{r0}]
        call printChar
        ; restore globbered non-volatile registers
        pop r9
        pop r8
        ret

        ; void printHex2
        ;   sp+5: arg x
@printHex2:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        ; move x{r8}, x{r0}
        ld r8, r0
        ; const t.2{r9}, 4
        ld r9, #%04
        ; move t.1{r0}, x{r8}
        ld r0, r8
        ; shiftright t.1{r0}, t.1{r0}, t.2{r9}
        not implemented
        ; call printNibble[t.1{r0}]
        call printNibble
        ; move x{r0}, x{r8}
        ld r0, r8
        ; call printNibble[x{r0}]
        call printNibble
        ; restore globbered non-volatile registers
        pop r10
        pop r9
        pop r8
        ret

        ; void main
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.2{r0}, [string-0]
        not implemented
        ; call printString[t.2{r0}]
        call printString
        ; const i{r8}, 0
        ld r8, #%00
        ; 19:2 for i < 16
        jp @for_4
@for_4_body:
        ; 20:3 if i & 7 == 0
        ; const t.6{r9}, 7
        ld r9, #%07
        ; move t.5{r10}, i{r8}
        ld r10, r8
        ; and t.5{r10}, t.5{r10}, t.6{r9}
        and r10, r9
        ; equals t.4{r9}, t.5{r10}, 0
        cp  r10, #%00
        jr  nz, .6
        cp  r11, #%00
        jr  nz, .6
        cp  r12, #%00
        jr  nz, .6
        cp  r13, #%00
        jr  nz, .6
        cp  r14, #%00
        jr  nz, .6
        cp  r15, #%00
        jr  nz, .6
        cp  %30, #%00
        jr  nz, .6
        cp  %31, #%00
        jr  nz, .6
        cp  %32, #%00
        jr  nz, .6
        cp  %33, #%00
        jr  nz, .6
        cp  %34, #%00
        jr  nz, .6
        cp  %35, #%00
        jr  nz, .6
        cp  %36, #%00
        jr  nz, .6
        cp  %37, #%00
        jr  nz, .6
        cp  %38, #%00
        jr  nz, .6
        cp  %39, #%00
        jr  nz, .6
        ld  r9, #%ff
        jr  .7
.6:
        ld  r9, #%00
.7:
        ; branch t.4{r9}, false, @if_5_end
        or r9, r9
        jp z, @if_5_end
        ; const t.7{r0}, 32
        ld r0, #%20
        ; call printChar[t.7{r0}]
        call printChar
@if_5_end:
        ; move i{r0}, i{r8}
        ld r0, r8
        ; call printNibble[i{r0}]
        call printNibble
        ; inc i{r8}
        inc r8
@for_4:
        ; lt t.3{r9}, i{r8}, 16
        cp  r8, #%10
        jr  ult, .8
.8:
        ld  r9, #%ff
        jr  .10
.9:
        ld  r9, #%00
.10:
        ; branch t.3{r9}, true, @for_4_body
        or r9, r9
        jp nz, @for_4_body
        ; const t.8{r0}, 10
        ld r0, #%0a
        ; call printChar[t.8{r0}]
        call printChar
        ; const i{r8}, 32
        ld r8, #%20
        ; 27:2 for i < 128
        jp @for_6
@for_6_body:
        ; 28:3 if i & 15 == 0
        ; const t.12{r9}, 15
        ld r9, #%0f
        ; move t.11{r10}, i{r8}
        ld r10, r8
        ; and t.11{r10}, t.11{r10}, t.12{r9}
        and r10, r9
        ; equals t.10{r9}, t.11{r10}, 0
        cp  r10, #%00
        jr  nz, .11
        cp  r11, #%00
        jr  nz, .11
        cp  r12, #%00
        jr  nz, .11
        cp  r13, #%00
        jr  nz, .11
        cp  r14, #%00
        jr  nz, .11
        cp  r15, #%00
        jr  nz, .11
        cp  %30, #%00
        jr  nz, .11
        cp  %31, #%00
        jr  nz, .11
        cp  %32, #%00
        jr  nz, .11
        cp  %33, #%00
        jr  nz, .11
        cp  %34, #%00
        jr  nz, .11
        cp  %35, #%00
        jr  nz, .11
        cp  %36, #%00
        jr  nz, .11
        cp  %37, #%00
        jr  nz, .11
        cp  %38, #%00
        jr  nz, .11
        cp  %39, #%00
        jr  nz, .11
        ld  r9, #%ff
        jr  .12
.11:
        ld  r9, #%00
.12:
        ; branch t.10{r9}, false, @if_7_end
        or r9, r9
        jp z, @if_7_end
        ; move i{r0}, i{r8}
        ld r0, r8
        ; call printHex2[i{r0}]
        call printHex2
@if_7_end:
        ; 31:3 if i & 7 == 0
        ; const t.15{r9}, 7
        ld r9, #%07
        ; move t.14{r10}, i{r8}
        ld r10, r8
        ; and t.14{r10}, t.14{r10}, t.15{r9}
        and r10, r9
        ; equals t.13{r9}, t.14{r10}, 0
        cp  r10, #%00
        jr  nz, .13
        cp  r11, #%00
        jr  nz, .13
        cp  r12, #%00
        jr  nz, .13
        cp  r13, #%00
        jr  nz, .13
        cp  r14, #%00
        jr  nz, .13
        cp  r15, #%00
        jr  nz, .13
        cp  %30, #%00
        jr  nz, .13
        cp  %31, #%00
        jr  nz, .13
        cp  %32, #%00
        jr  nz, .13
        cp  %33, #%00
        jr  nz, .13
        cp  %34, #%00
        jr  nz, .13
        cp  %35, #%00
        jr  nz, .13
        cp  %36, #%00
        jr  nz, .13
        cp  %37, #%00
        jr  nz, .13
        cp  %38, #%00
        jr  nz, .13
        cp  %39, #%00
        jr  nz, .13
        ld  r9, #%ff
        jr  .14
.13:
        ld  r9, #%00
.14:
        ; branch t.13{r9}, false, @if_8_end
        or r9, r9
        jp z, @if_8_end
        ; const t.16{r0}, 32
        ld r0, #%20
        ; call printChar[t.16{r0}]
        call printChar
@if_8_end:
        ; move i{r0}, i{r8}
        ld r0, r8
        ; call printChar[i{r0}]
        call printChar
        ; 35:3 if i & 15 == 15
        ; const t.19{r9}, 15
        ld r9, #%0f
        ; move t.18{r10}, i{r8}
        ld r10, r8
        ; and t.18{r10}, t.18{r10}, t.19{r9}
        and r10, r9
        ; equals t.17{r9}, t.18{r10}, 15
        cp  r10, #%00
        jr  nz, .15
        cp  r11, #%00
        jr  nz, .15
        cp  r12, #%00
        jr  nz, .15
        cp  r13, #%00
        jr  nz, .15
        cp  r14, #%00
        jr  nz, .15
        cp  r15, #%00
        jr  nz, .15
        cp  %30, #%00
        jr  nz, .15
        cp  %31, #%00
        jr  nz, .15
        cp  %32, #%00
        jr  nz, .15
        cp  %33, #%00
        jr  nz, .15
        cp  %34, #%00
        jr  nz, .15
        cp  %35, #%00
        jr  nz, .15
        cp  %36, #%00
        jr  nz, .15
        cp  %37, #%00
        jr  nz, .15
        cp  %38, #%00
        jr  nz, .15
        cp  %39, #%0f
        jr  nz, .15
        ld  r9, #%ff
        jr  .16
.15:
        ld  r9, #%00
.16:
        ; branch t.17{r9}, false, @for_6_continue
        or r9, r9
        jp z, @for_6_continue
        ; const t.20{r0}, 10
        ld r0, #%0a
        ; call printChar[t.20{r0}]
        call printChar
@for_6_continue:
        ; inc i{r8}
        inc r8
@for_6:
        ; lt t.9{r0}, i{r8}, 128
        cp  r8, #%80
        jr  ult, .17
.17:
        ld  r0, #%ff
        jr  .19
.18:
        ld  r0, #%00
.19:
        ; branch t.9{r0}, true, @for_6_body
        or r0, r0
        jp nz, @for_6_body
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printChar
@printChar:
        ld   r0, SPH
        ld   r1, SPL
        add  r1, 3
        adc  r0, 0
        ldc  r1, @rr0
        ld   %15, r1
        jp   %0818

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8

section '.data' data readable
        string_0 db ' x', 0x00

