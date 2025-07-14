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
        not implemented
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
        not implemented
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
        not implemented
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

        ; void initRandom
        ;   sp+5: arg salt
@initRandom:
        ret

        ; i32 random
@random:
        ; 70:9 return 0
        ; const r0, 0
        ld r0, #%00
        ld r1, #%00
        ld r2, #%00
        ld r3, #%00
        ret

        ; u8 randomU8
@randomU8:
        ; 74:10 return (u8)
        ; call r0 = random[] -> i32
        call random
        ; cast r0(u8), r0(i32)
        not implemented
        ret

        ; void main
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, 7439742
        ld r0, #%00
        ld r1, #%71
        ld r2, #%85
        ld r3, #%7e
        ; call initRandom[r0]
        call initRandom
        ; const r8, 0
        ld r8, #%00
        ; 5:2 for i < 50
        jp @for_5
@for_5_body:
        ; call r0 = randomU8[] -> u8
        call randomU8
        ; cast r0(i16), r0(u8)
        not implemented
        ; call printIntLf[r0]
        call printIntLf
        ; inc r8
        inc r8
@for_5:
        ; lt r0, r8, 50
        not implemented
        ; branch r0, true, @for_5_body
        or r0, r0
        jp nz, @for_5_body
        ; restore globbered non-volatile registers
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

