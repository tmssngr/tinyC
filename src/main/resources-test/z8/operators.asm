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
        ;   sp+1: var t
        ;   sp+0: var f
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
        ; reserve space for local variables
        decw SPH
        decw SPH
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, [string-0]
        not implemented
        ; call printString[r0]
        call printString
        ; const r8, 0
        ld r8, #%00
        ld r9, #%00
        ; const r10, 1
        ld r10, #%00
        ld r11, #%01
        ; const r12, 2
        ld r12, #%00
        ld r13, #%02
        ; const r14, 3
        ld r14, #%00
        ld r15, #%03
        ; const r2, 1
        ld r2, #%01
        ; const r3, 0
        ld r3, #%00
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; and r0, r0, r8
        and r1, r9
        and r0, r8
        ; move t, r2
        not implemented
        ; move f, r3
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; and r0, r0, r10
        and r1, r11
        and r0, r10
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r10
        ld r0, r10
        ld r1, r11
        ; and r0, r0, r8
        and r1, r9
        and r0, r8
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r10
        ld r0, r10
        ld r1, r11
        ; and r0, r0, r10
        and r1, r11
        and r0, r10
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-1]
        not implemented
        ; call printString[r0]
        call printString
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; or r0, r0, r8
        or r1, r9
        or r0, r8
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; or r0, r0, r10
        or r1, r11
        or r0, r10
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r10
        ld r0, r10
        ld r1, r11
        ; or r0, r0, r8
        or r1, r9
        or r0, r8
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r10
        ld r0, r10
        ld r1, r11
        ; or r0, r0, r10
        or r1, r11
        or r0, r10
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-2]
        not implemented
        ; call printString[r0]
        call printString
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; xor r0, r0, r8
        xor r1, r9
        xor r0, r8
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; xor r0, r0, r12
        xor r1, r13
        xor r0, r12
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r10
        ld r0, r10
        ld r1, r11
        ; xor r0, r0, r8
        xor r1, r9
        xor r0, r8
        ; call printIntLf[r0]
        call printIntLf
        ; move r0, r10
        ld r0, r10
        ld r1, r11
        ; xor r0, r0, r12
        xor r1, r13
        xor r0, r12
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-3]
        not implemented
        ; call printString[r0]
        call printString
        ; 26:15 logic and
        ; move r8, f
        not implemented
        ; move r9, r8
        ld r9, r8
        ; branch r9, false, @and_next_7
        or r9, r9
        jp z, @and_next_7
        ; move r9, r8
        ld r9, r8
@and_next_7:
        ; cast r0(i16), r9(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; 27:15 logic and
        ; move r9, r8
        ld r9, r8
        ; branch r9, true, @and_2nd_8
        or r9, r9
        jp nz, @and_2nd_8
        ; move r2, t
        not implemented
        jp @and_next_8
@and_2nd_8:
        ; move r2, t
        not implemented
        ; move r9, r2
        ld r9, r2
@and_next_8:
        ; cast r0(i16), r9(bool)
        not implemented
        ; move r9, r2
        ld r9, r2
        ; call printIntLf[r0]
        call printIntLf
        ; 28:15 logic and
        ; move r2, r9
        ld r2, r9
        ; branch r2, false, @and_next_9
        or r2, r2
        jp z, @and_next_9
        ; move r2, r8
        ld r2, r8
@and_next_9:
        ; cast r0(i16), r2(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; 29:15 logic and
        ; move r2, r9
        ld r2, r9
        ; branch r2, false, @and_next_10
        or r2, r2
        jp z, @and_next_10
        ; move r2, r9
        ld r2, r9
@and_next_10:
        ; cast r0(i16), r2(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-4]
        not implemented
        ; call printString[r0]
        call printString
        ; 31:15 logic or
        ; move r2, r8
        ld r2, r8
        ; branch r2, true, @or_next_11
        or r2, r2
        jp nz, @or_next_11
        ; move r2, r8
        ld r2, r8
@or_next_11:
        ; cast r0(i16), r2(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; 32:15 logic or
        ; move r2, r8
        ld r2, r8
        ; branch r2, true, @or_next_12
        or r2, r2
        jp nz, @or_next_12
        ; move r2, r9
        ld r2, r9
@or_next_12:
        ; cast r0(i16), r2(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; 33:15 logic or
        ; move r2, r9
        ld r2, r9
        ; branch r2, true, @or_next_13
        or r2, r2
        jp nz, @or_next_13
        ; move r2, r8
        ld r2, r8
@or_next_13:
        ; cast r0(i16), r2(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; 34:15 logic or
        ; move r2, r9
        ld r2, r9
        ; branch r2, true, @or_next_14
        or r2, r2
        jp nz, @or_next_14
        ; move r2, r9
        ld r2, r9
@or_next_14:
        ; cast r0(i16), r2(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-5]
        not implemented
        ; call printString[r0]
        call printString
        ; notlog r8, r8
        not implemented
        ; cast r0(i16), r8(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; notlog r8, r9
        not implemented
        ; cast r0(i16), r8(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, [string-6]
        not implemented
        ; call printString[r0]
        call printString
        ; const r8, 10
        ld r8, #%0a
        ; const r9, 6
        ld r9, #%06
        ; const r2, 1
        ld r2, #%01
        ; and r8, r8, r9
        and r8, r9
        ; or r8, r8, r2
        or r8, r2
        ; cast r0(i16), r8(u8)
        not implemented
        ; move r8, r2
        ld r8, r2
        ; call printIntLf[r0]
        call printIntLf
        ; 43:20 logic or
        ; equals r9, r10, r12
        not implemented
        ; branch r9, true, @or_next_15
        or r9, r9
        jp nz, @or_next_15
        ; lt r9, r12, r14
        not implemented
@or_next_15:
        ; cast r0(i16), r9(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; 44:20 logic and
        ; equals r9, r10, r12
        not implemented
        ; branch r9, false, @and_next_16
        or r9, r9
        jp z, @and_next_16
        ; lt r9, r12, r14
        not implemented
@and_next_16:
        ; cast r0(i16), r9(bool)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; const r0, -1
        ld r0, #%ff
        ld r1, #%ff
        ; call printIntLf[r0]
        call printIntLf
        ; neg r0, r10
        ld r0, #%00
        ld r1, #%00
        sub r1, r11
        sbc r0, r10
        ; call printIntLf[r0]
        call printIntLf
        ; not r8, r8
        com r8
        ; cast r0(i16), r8(u8)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; free space for local variables
        incw SPH
        incw SPH
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
        string_0 db 'Bit-&:', 0x0a, 0x00
        string_1 db 0x0a, 'Bit-|:', 0x0a, 0x00
        string_2 db 0x0a, 'Bit-^:', 0x0a, 0x00
        string_3 db 0x0a, 'Logic-&&:', 0x0a, 0x00
        string_4 db 0x0a, 'Logic-||:', 0x0a, 0x00
        string_5 db 0x0a, 'Logic-!:', 0x0a, 0x00
        string_6 db 0x0a, 'misc:', 0x0a, 0x00

