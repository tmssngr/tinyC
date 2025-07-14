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

        ; void printStringLength
        ;   sp+8: arg str
        ;   sp+6: arg length
@printStringLength:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; move r10, r2
        ld r10, r2
        ; 13:2 while length > 0
        jp @while_3
@while_3_body:
        ; load r0, [r8]
        lde r0, rr8
        ; call printChar[r0]
        call printChar
        ; dec r10
        dec r10
@while_3:
        ; gt r0, r10, 0
        not implemented
        ; branch r0, true, @while_3_body
        or r0, r0
        jp nz, @while_3_body
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printUint
        ;   sp+19: arg number
        ;   sp+9: var buffer
        ;   sp+7: var remainder
@printUint:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; reserve space for local variables
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; const r8, 20
        ld r8, #%14
        ; 24:2 while true
@while_4:
        ; dec r8
        dec r8
        ; const r9, 10
        ld r9, #%00
        ld r10, #%0a
        ; move r11, r0
        ld r11, r0
        ld r12, r1
        ; mod r11, r11, r9
        not implemented
        ; cast remainder(i64), r11(i16)
        not implemented
        ; const r9, 10
        ld r9, #%00
        ld r10, #%0a
        ; div r0, r0, r9
        not implemented
        ; cast r9(u8), remainder(i64)
        not implemented
        ; const r10, 48
        ld r10, #%30
        ; add r9, r9, r10
        add r9, r10
        ; cast r10(i16), r8(u8)
        not implemented
        ; cast r10(u8*), r10(i16)
        not implemented
        ; addrof r12, [buffer]
        not implemented
        ; add r12, r12, r10
        add r13, r11
        adc r12, r10
        ; store [r12], r9
        not implemented
        ; 30:3 if number == 0
        ; equals r9, r0, 0
        not implemented
        ; branch r9, false, @while_4
        or r9, r9
        jp z, @while_4
        ; cast r9(i16), r8(u8)
        not implemented
        ; cast r10(u8*), r9(i16)
        not implemented
        ; addrof r0, [buffer]
        not implemented
        ; add r0, r0, r10
        add r1, r11
        adc r0, r10
        ; const r9, 20
        ld r9, #%14
        ; move r2, r9
        ld r2, r9
        ; sub r2, r2, r8
        sub r2, r8
        ; call printStringLength[r0, r2]
        call printStringLength
        ; free space for local variables
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printIntLf
        ;   sp+7: arg number
@printIntLf:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; 38:2 if number < 0
        ; lt r10, r8, 0
        not implemented
        ; branch r10, false, @if_6_end
        or r10, r10
        jp z, @if_6_end
        ; const r0, 45
        ld r0, #%2d
        ; call printChar[r0]
        call printChar
        ; neg r8, r8
        com r8
        com r9
        incw r8
@if_6_end:
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; call printUint[r0]
        call printUint
        ; const r0, 10
        ld r0, #%0a
        ; call printChar[r0]
        call printChar
        ; restore globbered non-volatile registers
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
        ; const r0, [string-0]
        not implemented
        ; call printString[r0]
        call printString
        ; const r8, 1
        ld r8, #%00
        ld r9, #%01
        ; const r10, 2
        ld r10, #%00
        ld r11, #%02
        ; lt r12, r8, r10
        not implemented
        ; cast r0(i16), r12(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; lt r12, r10, r8
        not implemented
        ; cast r0(i16), r12(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-1]
        not implemented
        ; call printString[r0]
        call printString
        ; const r12, 0
        ld r12, #%00
        ; const r13, 128
        ld r13, #%80
        ; lt r14, r12, r13
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; lt r14, r13, r12
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-2]
        not implemented
        ; call printString[r0]
        call printString
        ; lteq r14, r8, r10
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; lteq r14, r10, r8
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-3]
        not implemented
        ; call printString[r0]
        call printString
        ; lteq r14, r12, r13
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; lteq r14, r13, r12
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-4]
        not implemented
        ; call printString[r0]
        call printString
        ; equals r14, r8, r10
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; equals r14, r10, r8
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-5]
        not implemented
        ; call printString[r0]
        call printString
        ; notequals r14, r8, r10
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; notequals r14, r10, r8
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-6]
        not implemented
        ; call printString[r0]
        call printString
        ; gteq r14, r8, r10
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; gteq r14, r10, r8
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-7]
        not implemented
        ; call printString[r0]
        call printString
        ; gteq r14, r12, r13
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; gteq r14, r13, r12
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-8]
        not implemented
        ; call printString[r0]
        call printString
        ; gt r14, r8, r10
        not implemented
        ; cast r0(i16), r14(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; gt r8, r10, r8
        not implemented
        ; cast r0(i16), r8(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-9]
        not implemented
        ; call printString[r0]
        call printString
        ; gt r8, r12, r13
        not implemented
        ; cast r0(i16), r8(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; gt r8, r13, r12
        not implemented
        ; cast r0(i16), r8(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
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

section '.data' data readable
        string_0 db '< (signed)', 0x0a, 0x00
        string_1 db '< (unsigned)', 0x0a, 0x00
        string_2 db '<= (signed)', 0x0a, 0x00
        string_3 db '<= (unsigned)', 0x0a, 0x00
        string_4 db '==', 0x0a, 0x00
        string_5 db '!=', 0x0a, 0x00
        string_6 db '>= (signed)', 0x0a, 0x00
        string_7 db '>= (unsigned)', 0x0a, 0x00
        string_8 db '> (signed)', 0x0a, 0x00
        string_9 db '> (unsigned)', 0x0a, 0x00

