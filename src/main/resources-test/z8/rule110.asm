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
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; 2:2 while true
        jp @while_1
@if_2_end:
        ; move r0, r10
        ld r0, r10
        ; call printChar[r0]
        call printChar
@while_1:
        ; load r10, [r8]
        lde r10, rr8
        ; 4:3 if chr == 0
        ; equals r0, r10, 0
        not implemented
        ; branch r0, false, @if_2_end
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
        ; const r0, 124
        ld r0, #%7c
        ; call printChar[r0]
        call printChar
        ; const r8, 0
        ld r8, #%00
        ; 11:2 for i < 30
        jp @for_3
@for_3_body:
        ; 12:3 if [...] == 0
        ; cast r9(i16), r8(u8)
        not implemented
        ; cast r10(u8*), r9(i16)
        not implemented
        ; addrof r12, [board]
        not implemented
        ; add r12, r12, r10
        add r13, r11
        adc r12, r10
        ; load r9, [r12]
        lde r9, rr12
        ; equals r9, r9, 0
        not implemented
        ; branch r9, true, @if_4_then
        or r9, r9
        jp nz, @if_4_then
        ; const r0, 42
        ld r0, #%2a
        ; call printChar[r0]
        call printChar
        jp @for_3_continue
@if_4_then:
        ; const r0, 32
        ld r0, #%20
        ; call printChar[r0]
        call printChar
@for_3_continue:
        ; inc r8
        inc r8
@for_3:
        ; lt r9, r8, 30
        not implemented
        ; branch r9, true, @for_3_body
        or r9, r9
        jp nz, @for_3_body
        ; const r0, [string-0]
        not implemented
        ; call printString[r0]
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
        ; const r8, 0
        ld r8, #%00
        ; 23:2 for i < 30
        jp @for_5
@for_5_body:
        ; const r9, 0
        ld r9, #%00
        ; cast r10(i16), r8(u8)
        not implemented
        ; cast r10(u8*), r10(i16)
        not implemented
        ; addrof r12, [board]
        not implemented
        ; add r12, r12, r10
        add r13, r11
        adc r12, r10
        ; store [r12], r9
        not implemented
        ; inc r8
        inc r8
@for_5:
        ; lt r9, r8, 30
        not implemented
        ; branch r9, true, @for_5_body
        or r9, r9
        jp nz, @for_5_body
        ; const r8, 1
        ld r8, #%01
        ; const r9, 29
        ld r9, #%1d
        ; cast r9(i16), r9(u8)
        not implemented
        ; cast r10(u8*), r9(i16)
        not implemented
        ; addrof r12, [board]
        not implemented
        ; add r12, r12, r10
        add r13, r11
        adc r12, r10
        ; store [r12], r8
        not implemented
        ; call printBoard[]
        call printBoard
        ; const r8, 0
        ld r8, #%00
        ; 30:2 for i < 28
        jp @for_6
@for_6_body:
        ; const r9, 0
        ld r9, #%00
        ld r10, #%00
        ; cast r10(u8*), r9(i16)
        not implemented
        ; addrof r12, [board]
        not implemented
        ; add r12, r12, r10
        add r13, r11
        adc r12, r10
        ; load r9, [r12]
        lde r9, rr12
        ; const r10, 1
        ld r10, #%01
        ; shiftleft r9, r9, r10
        not implemented
        ; const r10, 1
        ld r10, #%00
        ld r11, #%01
        ; cast r10(u8*), r10(i16)
        not implemented
        ; addrof r12, [board]
        not implemented
        ; add r12, r12, r10
        add r13, r11
        adc r12, r10
        ; load r10, [r12]
        lde r10, rr12
        ; or r9, r9, r10
        or r9, r10
        ; const r10, 1
        ld r10, #%01
        ; 32:3 for j < 29
        jp @for_7
@for_7_body:
        ; const r11, 1
        ld r11, #%01
        ; move r12, r9
        ld r12, r9
        ; shiftleft r12, r12, r11
        not implemented
        ; const r11, 7
        ld r11, #%07
        ; and r12, r12, r11
        and r12, r11
        ; const r11, 1
        ld r11, #%01
        ; move r13, r10
        ld r13, r10
        ; add r13, r13, r11
        add r13, r11
        ; cast r13(i16), r13(u8)
        not implemented
        ; cast r14(u8*), r13(i16)
        not implemented
        ; addrof r0, [board]
        not implemented
        ; add r0, r0, r14
        add r1, r15
        adc r0, r14
        ; load r11, [r0]
        lde r11, rr0
        ; move r9, r12
        ld r9, r12
        ; or r9, r9, r11
        or r9, r11
        ; const r11, 110
        ld r11, #%6e
        ; shiftright r11, r11, r9
        not implemented
        ; const r12, 1
        ld r12, #%01
        ; and r11, r11, r12
        and r11, r12
        ; cast r12(i16), r10(u8)
        not implemented
        ; cast r12(u8*), r12(i16)
        not implemented
        ; addrof r14, [board]
        not implemented
        ; add r14, r14, r12
        add r15, r13
        adc r14, r12
        ; store [r14], r11
        not implemented
        ; inc r10
        inc r10
@for_7:
        ; lt r11, r10, 29
        not implemented
        ; branch r11, true, @for_7_body
        or r11, r11
        jp nz, @for_7_body
        ; call printBoard[]
        call printBoard
        ; inc r8
        inc r8
@for_6:
        ; lt r0, r8, 28
        not implemented
        ; branch r0, true, @for_6_body
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

