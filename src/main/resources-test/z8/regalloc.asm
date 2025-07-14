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

        ; u8 simple
@simple:
        ; const r1, 4
        ld r1, #%04
        ; const r2, 3
        ld r2, #%03
        ; move r0, r1
        ld r0, r1
        ; sub r0, r0, r2
        sub r0, r2
        ; 5:9 return one
        ret

        ; u8 registerHint
        ;   sp+3: arg a
        ;   sp+2: arg b
@registerHint:
        ; 9:11 return a + b
        ; move r0, r1
        ld r0, r1
        ; add r0, r0, r2
        add r0, r2
        ret

        ; u8 max
        ;   sp+3: arg a
        ;   sp+2: arg b
@max:
        ; 13:2 if a < b
        ; lt r3, r1, r2
        not implemented
        ; branch r3, true, @if_1_then
        or r3, r3
        jp nz, @if_1_then
        ; 16:9 return a
        ; move r0, r1
        ld r0, r1
        jp @max_ret
@if_1_then:
        ; 14:10 return b
        ; move r0, r2
        ld r0, r2
@max_ret:
        ret

        ; i16 fibonacci
        ;   sp+2: arg i
@fibonacci:
        ; const r0, 0
        ld r0, #%00
        ld r1, #%00
        ; const r3, 1
        ld r3, #%00
        ld r4, #%01
        ; 22:2 while i > 0
        jp @while_2
@while_2_body:
        ; dec r2
        dec r2
        ; move r5, r0
        ld r5, r0
        ld r6, r1
        ; add r5, r5, r3
        add r6, r4
        adc r5, r3
        ; move r0, r3
        ld r0, r3
        ld r1, r4
        ; move r3, r5
        ld r3, r5
        ld r4, r6
@while_2:
        ; gt r5, r2, 0
        not implemented
        ; branch r5, true, @while_2_body
        or r5, r5
        jp nz, @while_2_body
        ; 28:9 return a
        ret

        ; void main
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        ; call r0 = simple[] -> u8
        call simple
        ; move r8, r0
        ld r8, r0
        ; const r9, 2
        ld r9, #%02
        ; move r1, r8
        ld r1, r8
        ; move r2, r9
        ld r2, r9
        ; call _ = registerHint[r1, r2] -> u8
        call registerHint
        ; move r1, r8
        ld r1, r8
        ; move r2, r9
        ld r2, r9
        ; call r0 = max[r1, r2] -> u8
        call max
        ; const r2, 5
        ld r2, #%05
        ; call r0 = fibonacci[r2] -> i16
        call fibonacci
        ; restore globbered non-volatile registers
        pop r10
        pop r9
        pop r8
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8

