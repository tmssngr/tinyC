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

        ; void printNibble
        ;   sp+4: arg x
@printNibble:
        ; save globbered non-volatile registers
        push r8
        push r9
        ; const r8, 15
        ld r8, #%0f
        ; and r0, r0, r8
        and r0, r8
        ; 5:2 if x > 9
        ; gt r8, r0, 9
        not implemented
        ; branch r8, false, @if_3_end
        or r8, r8
        jp z, @if_3_end
        ; add r0, 7
        add r0, #%07
@if_3_end:
        ; add r0, 48
        add r0, #%30
        ; call printChar[r0]
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
        ; move r8, r0
        ld r8, r0
        ; const r9, 4
        ld r9, #%04
        ; move r0, r8
        ld r0, r8
        ; shiftright r0, r0, r9
        not implemented
        ; call printNibble[r0]
        call printNibble
        ; move r0, r8
        ld r0, r8
        ; call printNibble[r0]
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
        ; const r0, [string-0]
        not implemented
        ; call printString[r0]
        call printString
        ; const r8, 0
        ld r8, #%00
        ; 19:2 for i < 16
        jp @for_4
@for_4_body:
        ; 20:3 if i & 7 == 0
        ; const r9, 7
        ld r9, #%07
        ; move r10, r8
        ld r10, r8
        ; and r10, r10, r9
        and r10, r9
        ; equals r9, r10, 0
        not implemented
        ; branch r9, false, @if_5_end
        or r9, r9
        jp z, @if_5_end
        ; const r0, 32
        ld r0, #%20
        ; call printChar[r0]
        call printChar
@if_5_end:
        ; move r0, r8
        ld r0, r8
        ; call printNibble[r0]
        call printNibble
        ; inc r8
        inc r8
@for_4:
        ; lt r9, r8, 16
        not implemented
        ; branch r9, true, @for_4_body
        or r9, r9
        jp nz, @for_4_body
        ; const r0, 10
        ld r0, #%0a
        ; call printChar[r0]
        call printChar
        ; const r8, 32
        ld r8, #%20
        ; 27:2 for i < 128
        jp @for_6
@for_6_body:
        ; 28:3 if i & 15 == 0
        ; const r9, 15
        ld r9, #%0f
        ; move r10, r8
        ld r10, r8
        ; and r10, r10, r9
        and r10, r9
        ; equals r9, r10, 0
        not implemented
        ; branch r9, false, @if_7_end
        or r9, r9
        jp z, @if_7_end
        ; move r0, r8
        ld r0, r8
        ; call printHex2[r0]
        call printHex2
@if_7_end:
        ; 31:3 if i & 7 == 0
        ; const r9, 7
        ld r9, #%07
        ; move r10, r8
        ld r10, r8
        ; and r10, r10, r9
        and r10, r9
        ; equals r9, r10, 0
        not implemented
        ; branch r9, false, @if_8_end
        or r9, r9
        jp z, @if_8_end
        ; const r0, 32
        ld r0, #%20
        ; call printChar[r0]
        call printChar
@if_8_end:
        ; move r0, r8
        ld r0, r8
        ; call printChar[r0]
        call printChar
        ; 35:3 if i & 15 == 15
        ; const r9, 15
        ld r9, #%0f
        ; move r10, r8
        ld r10, r8
        ; and r10, r10, r9
        and r10, r9
        ; equals r9, r10, 15
        not implemented
        ; branch r9, false, @for_6_continue
        or r9, r9
        jp z, @for_6_continue
        ; const r0, 10
        ld r0, #%0a
        ; call printChar[r0]
        call printChar
@for_6_continue:
        ; inc r8
        inc r8
@for_6:
        ; lt r0, r8, 128
        not implemented
        ; branch r0, true, @for_6_body
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

