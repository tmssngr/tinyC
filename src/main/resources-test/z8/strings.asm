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
        cp  r10, #%00
        jr  uge, .3
.3:
        ld  r0, #%ff
        jr  .5
.4:
        ld  r0, #%00
.5:
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
        lde rr12, r9
        ; 30:3 if number == 0
        ; equals r9, r0, 0
        cp  r0, #%00
        jr  nz, .6
        cp  r1, #%00
        jr  nz, .6
        cp  r2, #%00
        jr  nz, .6
        cp  r3, #%00
        jr  nz, .6
        cp  r4, #%00
        jr  nz, .6
        cp  r5, #%00
        jr  nz, .6
        cp  r6, #%00
        jr  nz, .6
        cp  r7, #%00
        jr  nz, .6
        cp  r8, #%00
        jr  nz, .6
        cp  r9, #%00
        jr  nz, .6
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
        ld  r9, #%ff
        jr  .7
.6:
        ld  r9, #%00
.7:
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
        cp  r8, #%00
        jr  lt, .8
        jr  nz, .9
        cp  r9, #%00
        jr  ult, .8
.8:
        ld  r10, #%ff
        jr  .10
.9:
        ld  r10, #%00
.10:
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
        ; begin initialize global variables
        ; const r8, [string-0]
        not implemented
        ; end initialize global variables
        ; move text, r8
        not implemented
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; call printString[r0]
        call printString
        ; call printLength[]
        call printLength
        ; const r10, 1
        ld r10, #%00
        ld r11, #%01
        ; cast r10(u8*), r10(i16)
        not implemented
        ; move r8, text
        not implemented
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; add r0, r0, r10
        add r1, r11
        adc r0, r10
        ; call printString[r0]
        call printString
        ; move r8, text
        not implemented
        ; load r10, [r8]
        lde r10, rr8
        ; cast r0(i16), r10(u8)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printLength
@printLength:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const r0, 0
        ld r0, #%00
        ld r1, #%00
        ; move r8, text
        not implemented
        ; 16:2 for *ptr != 0
        jp @for_7
@for_7_body:
        ; inc r0
        incw r0
        ; cast r10(i16), r8(u8*)
        not implemented
        ; const r12, 1
        ld r12, #%00
        ld r13, #%01
        ; add r10, r10, r12
        add r11, r13
        adc r10, r12
        ; cast r8(u8*), r10(i16)
        not implemented
@for_7:
        ; load r10, [r8]
        lde r10, rr8
        ; notequals r10, r10, 0
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
        ld  r10, #%00
        jr  .12
.11:
        ld  r10, #%ff
.12:
        ; branch r10, true, @for_7_body
        or r10, r10
        jp nz, @for_7_body
        ; call printIntLf[r0]
        call printIntLf
        ; restore globbered non-volatile registers
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
        ; variable 0: text (u8*/2)
        var_0 rb 2

section '.data' data readable
        string_0 db 'hello world', 0x0a, 0x00

