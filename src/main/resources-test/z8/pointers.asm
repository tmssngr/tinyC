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
        jp @while_1
@while_1_body:
        ; load r0, [r8]
        lde r0, rr8
        ; call printChar[r0]
        call printChar
        ; dec r10
        dec r10
@while_1:
        ; gt r0, r10, 0
        cp  r10, #%00
        jr  uge, .1
.1:
        ld  r0, #%ff
        jr  .3
.2:
        ld  r0, #%00
.3:
        ; branch r0, true, @while_1_body
        or r0, r0
        jp nz, @while_1_body
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
@while_2:
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
        cp  r0, #%00
        jr  nz, .4
        cp  r1, #%00
        jr  nz, .4
        cp  r2, #%00
        jr  nz, .4
        cp  r3, #%00
        jr  nz, .4
        cp  r4, #%00
        jr  nz, .4
        cp  r5, #%00
        jr  nz, .4
        cp  r6, #%00
        jr  nz, .4
        cp  r7, #%00
        jr  nz, .4
        cp  r8, #%00
        jr  nz, .4
        cp  r9, #%00
        jr  nz, .4
        cp  r10, #%00
        jr  nz, .4
        cp  r11, #%00
        jr  nz, .4
        cp  r12, #%00
        jr  nz, .4
        cp  r13, #%00
        jr  nz, .4
        cp  r14, #%00
        jr  nz, .4
        cp  r15, #%00
        jr  nz, .4
        ld  r9, #%ff
        jr  .5
.4:
        ld  r9, #%00
.5:
        ; branch r9, false, @while_2
        or r9, r9
        jp z, @while_2
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
        jr  lt, .6
        jr  nz, .7
        cp  r9, #%00
        jr  ult, .6
.6:
        ld  r10, #%ff
        jr  .8
.7:
        ld  r10, #%00
.8:
        ; branch r10, false, @if_4_end
        or r10, r10
        jp z, @if_4_end
        ; const r0, 45
        ld r0, #%2d
        ; call printChar[r0]
        call printChar
        ; neg r8, r8
        com r8
        com r9
        incw r8
@if_4_end:
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
        ;   sp+3: var a
        ;   sp+1: var c
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
        decw SPH
        decw SPH
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, 10
        ld r0, #%00
        ld r1, #%0a
        ; move a, r0
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; addrof r8, a
        not implemented
        ; load r8, [r8]
        lde r8, rr8
        incw r8
        lde r9, rr8
        decw r8
        ; const r10, 1
        ld r10, #%00
        ld r11, #%01
        ; sub r8, r8, r10
        sub r9, r11
        sbc r8, r10
        ; move c, r8
        not implemented
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; call printIntLf[r0]
        call printIntLf
        ; addrof r10, c
        not implemented
        ; load r12, [r10]
        lde r12, rr10
        incw r10
        lde r13, rr10
        decw r10
        ; const r14, 1
        ld r14, #%00
        ld r15, #%01
        ; sub r12, r12, r14
        sub r13, r15
        sbc r12, r14
        ; store [r10], r12
        not implemented
        ; move r8, c
        not implemented
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; call printIntLf[r0]
        call printIntLf
        ; free space for local variables
        incw SPH
        incw SPH
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

