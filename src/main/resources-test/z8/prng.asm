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

        ; void printIntLf
        ;   rsp+4: arg number
@printIntLf:
        ; 38:2 if number < 0
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, number
        ; lt r0, r1, r0
        ; branch r0, false, @if_4_end
        jz @if_4_end
        ; 
        ; const r0, 45
        ld r0, 45
        ; call _, printChar [r0]
        ; move r0, number
        ; neg r0, r0
        ; move number, r0
@if_4_end:
        ; call _, printUint [number]
        ; const r0, 10
        ld r0, 10
        ; call _, printChar [r0]
        ret

        ; void initRandom
        ;   rsp+6: arg salt
@initRandom:
        ret

        ; i32 random
@random:
        ; 70:9 return 0
        ; const r0, 0
        ld r3, 0
        ld r2, 0
        ld r1, 0
        ld r0, 0
        ; ret r0
        ret

        ; u8 randomU8
@randomU8:
        ; 74:10 return (u8)
        ; call r0, random, []
        ; cast r0(u8), r0(i32)
        ; ret r0
        ret

        ; void main
        ;   rsp+0: var i
@main:
        ; reserve space for local variables
        sub rsp, 1
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, 7439742
        ld r3, 126
        ld r2, 133
        ld r1, 113
        ld r0, 0
        ; call _, initRandom [r0]
        ; const r0, 0
        ld r0, 0
        ; 5:2 for i < 50
        ; move i, r0
@for_5:
        ; const r0, 50
        ld r0, 50
        ; move r1, i
        ; lt r0, r1, r0
        ; branch r0, false, @main_ret
        jz @main_ret
        ; 
        ; call r0, randomU8, []
        ; cast r0(i16), r0(u8)
        ; call _, printIntLf [r0]
        ; const r0, 1
        ld r0, 1
        ; move r1, i
        ; add r0, r1, r0
        ; move i, r0
        ; jump @for_5
        jmp @for_5
@main_ret:
        ; release space for local variables
        add rsp, 1
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


