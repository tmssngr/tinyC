        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void printStringLength
        ;   rsp+3: arg str
        ;   rsp+11: arg length
@printStringLength:
@while_1:
        ; const r0, 0
        ld r0, 0
        ; move r1, length
        ; gt r0, r1, r0
        ; branch r0, false, @printStringLength_ret
        jz @printStringLength_ret
        ; 
        ; move r0, str
        ; load r1, [r0]
        ; call _, printChar [r1]
        ; const r0, 1
        ld r0, 1
        ; move r1, length
        ; sub r0, r1, r0
        ; move length, r0
        ; jump @while_1
        jmp @while_1
@printStringLength_ret:
        ret

        ; void printUint
        ;   rsp+25: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
@printUint:
        ; reserve space for local variables
        sub rsp, 21
        ; const r0, 20
        ld r0, 20
        ; 24:2 while true
        ; move pos, r0
@while_2:
        ; const r0, 1
        ld r0, 1
        ; move r1, pos
        ; sub r0, r1, r0
        ; const r1, 10
        ld r5, 10
        ld r4, 0
        ; move r2, number
        ; move r3, r2
        ; mod r1, r3, r1
        ; cast r1(i64), r1(i16)
        ; const r3, 10
        ld r13, 10
        ld r12, 0
        ; div r2, r2, r3
        ; cast r1(u8), r1(i64)
        ; const r3, 48
        ld r12, 48
        ; add r1, r1, r3
        ; cast r3(i16), r0(u8)
        ; cast r3(u8*), r3(i16)
        ; Spill pos
        ; move pos, r0
        ; addrof r0, [buffer]
        ; add r0, r0, r3
        ; store [r0], r1
        ; 30:3 if number == 0
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; equals r0, r2, r0
        ; move number, r2
        ; branch r0, false, @while_2
        jz @while_2
        ; 
        ; move r0, pos
        ; cast r1(i16), r0(u8)
        ; cast r1(u8*), r1(i16)
        ; addrof r2, [buffer]
        ; add r1, r2, r1
        ; const r2, 20
        ld r8, 20
        ; sub r0, r2, r0
        ; call _, printStringLength [r1, r0]
        ; release space for local variables
        add rsp, 21
        ret

        ; void main
@main:
        ; begin initialize global variables
        ; const r0, 48
        ld r0, 48
        ; const r1, 49
        ld r4, 49
        ; const r2, 50
        ld r8, 50
        ; const r3, 34
        ld r12, 34
        ; end initialize global variables
        ; move zero, r0
        ; move one, r1
        ; move two, r2
        ; move threeFour, r3
        ; call _, printChar [r0]
        ; addrof r0, one
        ; load r0, [r0]
        ; call _, printChar [r0]
        ; addrof r0, two
        ; const r1, 0
        ld r5, 0
        ld r4, 0
        ; cast r1(u8*), r1(i16)
        ; add r0, r0, r1
        ; load r0, [r0]
        ; call _, printChar [r0]
        ; move r0, threeFour
        ; cast r0(i16), r0(u8)
        ; call _, printUint [r0]
        ; const r0, 10
        ld r0, 10
        ; call _, printChar [r0]
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

        ; variable 0: zero (u8/1)
var_0:
        .data 0
        ; variable 1: one (u8/1)
var_1:
        .data 0
        ; variable 2: two (u8/1)
var_2:
        .data 0
        ; variable 3: threeFour (u8/1)
var_3:
        .data 0

