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

        ; void printBoard
@printBoard:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const t.1{r0}, 124
        ld r0, #%7c
        ; call printChar[t.1{r0}]
        call printChar
        ; const i{r8}, 0
        ld r8, #%00
        ; 11:2 for i < 30
        jp @for_3
@for_3_body:
        ; 12:3 if [...] == 0
        ; cast t.6{r9}(i16), i{r8}(u8)
        not implemented
        ; cast t.7{r10}(u8*), t.6{r9}(i16)
        not implemented
        ; addrof t.5{r12}, [board]
        not implemented
        ; add t.5{r12}, t.5{r12}, t.7{r10}
        add r13, r11
        adc r12, r10
        ; load t.4{r9}, [t.5{r12}]
        lde r9, rr12
        ; equals t.3{r9}, t.4{r9}, 0
        cp  r9, #%00
        jr  nz, .3
        cp  r10, #%00
        jr  nz, .3
        cp  r11, #%00
        jr  nz, .3
        cp  r12, #%00
        jr  nz, .3
        cp  r13, #%00
        jr  nz, .3
        cp  r14, #%00
        jr  nz, .3
        cp  r15, #%00
        jr  nz, .3
        cp  %30, #%00
        jr  nz, .3
        cp  %31, #%00
        jr  nz, .3
        cp  %32, #%00
        jr  nz, .3
        cp  %33, #%00
        jr  nz, .3
        cp  %34, #%00
        jr  nz, .3
        cp  %35, #%00
        jr  nz, .3
        cp  %36, #%00
        jr  nz, .3
        cp  %37, #%00
        jr  nz, .3
        cp  %38, #%00
        jr  nz, .3
        ld  r9, #%ff
        jr  .4
.3:
        ld  r9, #%00
.4:
        ; branch t.3{r9}, true, @if_4_then
        or r9, r9
        jp nz, @if_4_then
        ; const t.9{r0}, 42
        ld r0, #%2a
        ; call printChar[t.9{r0}]
        call printChar
        jp @for_3_continue
@if_4_then:
        ; const t.8{r0}, 32
        ld r0, #%20
        ; call printChar[t.8{r0}]
        call printChar
@for_3_continue:
        ; inc i{r8}
        inc r8
@for_3:
        ; lt t.2{r9}, i{r8}, 30
        cp  r8, #%1e
        jr  ult, .5
.5:
        ld  r9, #%ff
        jr  .7
.6:
        ld  r9, #%00
.7:
        ; branch t.2{r9}, true, @for_3_body
        or r9, r9
        jp nz, @for_3_body
        ; const t.10{r0}, [string-0]
        not implemented
        ; call printString[t.10{r0}]
        call printString
        ; restore globbered non-volatile registers
        pop r13
        pop r12
        pop r11
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
        push r12
        push r13
        push r14
        push r15
        ; begin initialize global variables
        ; end initialize global variables
        ; const i{r8}, 0
        ld r8, #%00
        ; 23:2 for i < 30
        jp @for_5
@for_5_body:
        ; const t.5{r9}, 0
        ld r9, #%00
        ; cast t.7{r10}(i16), i{r8}(u8)
        not implemented
        ; cast t.8{r10}(u8*), t.7{r10}(i16)
        not implemented
        ; addrof t.6{r12}, [board]
        not implemented
        ; add t.6{r12}, t.6{r12}, t.8{r10}
        add r13, r11
        adc r12, r10
        ; store [t.6{r12}], t.5{r9}
        lde rr12, r9
        ; inc i{r8}
        inc r8
@for_5:
        ; lt t.4{r9}, i{r8}, 30
        cp  r8, #%1e
        jr  ult, .8
.8:
        ld  r9, #%ff
        jr  .10
.9:
        ld  r9, #%00
.10:
        ; branch t.4{r9}, true, @for_5_body
        or r9, r9
        jp nz, @for_5_body
        ; const t.9{r8}, 1
        ld r8, #%01
        ; const t.12{r9}, 29
        ld r9, #%1d
        ; cast t.11{r9}(i16), t.12{r9}(u8)
        not implemented
        ; cast t.13{r10}(u8*), t.11{r9}(i16)
        not implemented
        ; addrof t.10{r12}, [board]
        not implemented
        ; add t.10{r12}, t.10{r12}, t.13{r10}
        add r13, r11
        adc r12, r10
        ; store [t.10{r12}], t.9{r8}
        lde rr12, r8
        ; call printBoard[]
        call printBoard
        ; const i{r8}, 0
        ld r8, #%00
        ; 30:2 for i < 28
        jp @for_6
@for_6_body:
        ; const t.18{r9}, 0
        ld r9, #%00
        ld r10, #%00
        ; cast t.19{r10}(u8*), t.18{r9}(i16)
        not implemented
        ; addrof t.17{r12}, [board]
        not implemented
        ; add t.17{r12}, t.17{r12}, t.19{r10}
        add r13, r11
        adc r12, r10
        ; load t.16{r9}, [t.17{r12}]
        lde r9, rr12
        ; const t.20{r10}, 1
        ld r10, #%01
        ; shiftleft t.15{r9}, t.15{r9}, t.20{r10}
        not implemented
        ; const t.23{r10}, 1
        ld r10, #%00
        ld r11, #%01
        ; cast t.24{r10}(u8*), t.23{r10}(i16)
        not implemented
        ; addrof t.22{r12}, [board]
        not implemented
        ; add t.22{r12}, t.22{r12}, t.24{r10}
        add r13, r11
        adc r12, r10
        ; load t.21{r10}, [t.22{r12}]
        lde r10, rr12
        ; or pattern{r9}, pattern{r9}, t.21{r10}
        or r9, r10
        ; const j{r10}, 1
        ld r10, #%01
        ; 32:3 for j < 29
        jp @for_7
@for_7_body:
        ; const t.28{r11}, 1
        ld r11, #%01
        ; move t.27{r12}, pattern{r9}
        ld r12, r9
        ; shiftleft t.27{r12}, t.27{r12}, t.28{r11}
        not implemented
        ; const t.29{r11}, 7
        ld r11, #%07
        ; and t.26{r12}, t.26{r12}, t.29{r11}
        and r12, r11
        ; const t.34{r11}, 1
        ld r11, #%01
        ; move t.33{r13}, j{r10}
        ld r13, r10
        ; add t.33{r13}, t.33{r13}, t.34{r11}
        add r13, r11
        ; cast t.32{r13}(i16), t.33{r13}(u8)
        not implemented
        ; cast t.35{r14}(u8*), t.32{r13}(i16)
        not implemented
        ; addrof t.31{r0}, [board]
        not implemented
        ; add t.31{r0}, t.31{r0}, t.35{r14}
        add r1, r15
        adc r0, r14
        ; load t.30{r11}, [t.31{r0}]
        lde r11, rr0
        ; move pattern{r9}, t.26{r12}
        ld r9, r12
        ; or pattern{r9}, pattern{r9}, t.30{r11}
        or r9, r11
        ; const t.38{r11}, 110
        ld r11, #%6e
        ; shiftright t.37{r11}, t.37{r11}, pattern{r9}
        not implemented
        ; const t.39{r12}, 1
        ld r12, #%01
        ; and t.36{r11}, t.36{r11}, t.39{r12}
        and r11, r12
        ; cast t.41{r12}(i16), j{r10}(u8)
        not implemented
        ; cast t.42{r12}(u8*), t.41{r12}(i16)
        not implemented
        ; addrof t.40{r14}, [board]
        not implemented
        ; add t.40{r14}, t.40{r14}, t.42{r12}
        add r15, r13
        adc r14, r12
        ; store [t.40{r14}], t.36{r11}
        lde rr14, r11
        ; inc j{r10}
        inc r10
@for_7:
        ; lt t.25{r11}, j{r10}, 29
        cp  r10, #%1d
        jr  ult, .11
.11:
        ld  r11, #%ff
        jr  .13
.12:
        ld  r11, #%00
.13:
        ; branch t.25{r11}, true, @for_7_body
        or r11, r11
        jp nz, @for_7_body
        ; call printBoard[]
        call printBoard
        ; inc i{r8}
        inc r8
@for_6:
        ; lt t.14{r0}, i{r8}, 28
        cp  r8, #%1c
        jr  ult, .14
.14:
        ld  r0, #%ff
        jr  .16
.15:
        ld  r0, #%00
.16:
        ; branch t.14{r0}, true, @for_6_body
        or r0, r0
        jp nz, @for_6_body
        ; restore globbered non-volatile registers
        pop r15
        pop r14
        pop r13
        pop r12
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
        ; variable 0: board[] (u8*/60)
        var_0 rb 60

section '.data' data readable
        string_0 db '|', 0x0a, 0x00

