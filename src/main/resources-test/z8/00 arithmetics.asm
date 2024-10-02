        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void printStringLength
        ;   rsp+1: arg str
        ;   rsp+8: arg length
@printStringLength:
@while_1:
        ; const r0(u8 t.4), 0
        ld r0, 0
        ; copy r1(u8 length), length(1@argument,u8)
        ; gt r0(bool t.3), r1(u8 length), r0(u8 t.4)
        ; branch r0(bool t.3), false, @printStringLength_ret
        jz @printStringLength_ret
        ; 
        ; copy r0(u8* str), str(0@argument,u8*)
        ; load r1(u8 chr), [r0(u8* str)]
        ; call _, printChar [r1(u8 chr)]
        ; const r0(u8 t.5), 1
        ld r0, 1
        ; copy r1(u8 length), length(1@argument,u8)
        ; sub r0(u8 length), r1(u8 length), r0(u8 t.5)
        ; copy length(1@argument,u8), r0(u8 length)
        ; jump @while_1
        jmp @while_1
@printStringLength_ret:
        ret

        ; void printUint
        ;   rsp+2: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
@printUint:
        ; reserve space for local variables
        sub rsp, 21
        ; const r0(u8 pos), 20
        ld r0, 20
        ; 24:2 while true
        ; copy pos(2@function,u8), r0(u8 pos)
@while_2:
        ; const r0(u8 t.5), 1
        ld r0, 1
        ; copy r1(u8 pos), pos(2@function,u8)
        ; sub r0(u8 pos), r1(u8 pos), r0(u8 t.5)
        ; const r1(i16 t.7), 10
        ld r5, 10
        ld r4, 0
        ; copy r2(i16 number), number(0@argument,i16)
        ; mod r1(i16 t.6), r2(i16 number), r1(i16 t.7)
        ; cast r1(i64 remainder), r1(i16 t.6)
        ; const r3(i16 t.8), 10
        ld r13, 10
        ld r12, 0
        ; div r2(i16 number), r2(i16 number), r3(i16 t.8)
        ; cast r1(u8 t.9), r1(i64 remainder)
        ; const r3(u8 t.10), 48
        ld r12, 48
        ; add r1(u8 digit), r1(u8 t.9), r3(u8 t.10)
        ; cast r3(i16 t.12), r0(u8 pos)
        ; cast r3(u8* t.13), r3(i16 t.12)
        ; Spill pos
        ; copy pos(2@function,u8), r0(u8 pos)
        ; addrof r0(u8* t.11), [buffer(1@function,u8*)]
        ; add r0(u8* t.11), r0(u8* t.11), r3(u8* t.13)
        ; store [r0(u8* t.11)], r1(u8 digit)
        ; 30:3 if number == 0
        ; const r0(i16 t.15), 0
        ld r1, 0
        ld r0, 0
        ; equals r0(bool t.14), r2(i16 number), r0(i16 t.15)
        ; copy number(0@argument,i16), r2(i16 number)
        ; branch r0(bool t.14), false, @while_2
        jz @while_2
        ; 
        ; copy r0(u8 pos), pos(2@function,u8)
        ; cast r1(i16 t.17), r0(u8 pos)
        ; cast r1(u8* t.18), r1(i16 t.17)
        ; addrof r2(u8* t.16), [buffer(1@function,u8*)]
        ; add r1(u8* t.16), r2(u8* t.16), r1(u8* t.18)
        ; const r2(u8 t.20), 20
        ld r8, 20
        ; sub r0(u8 t.19), r2(u8 t.20), r0(u8 pos)
        ; call _, printStringLength [r1(u8* t.16), r0(u8 t.19)]
        ; release space for local variables
        add rsp, 21
        ret

        ; void printIntLf
        ;   rsp+2: arg number
@printIntLf:
        ; 38:2 if number < 0
        ; const r0(i16 t.2), 0
        ld r1, 0
        ld r0, 0
        ; copy r1(i16 number), number(0@argument,i16)
        ; lt r0(bool t.1), r1(i16 number), r0(i16 t.2)
        ; branch r0(bool t.1), false, @if_4_end
        jz @if_4_end
        ; 
        ; const r0(u8 t.3), 45
        ld r0, 45
        ; call _, printChar [r0(u8 t.3)]
        ; copy r0(i16 number), number(0@argument,i16)
        ; neg r0(i16 number), r0(i16 number)
        ; copy number(0@argument,i16), r0(i16 number)
@if_4_end:
        ; call _, printUint [number(0@argument,i16)]
        ; const r0(u8 t.4), 10
        ld r0, 10
        ; call _, printChar [r0(u8 t.4)]
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

        ; void main
        ;   rsp+0: var bazz
        ;   rsp+2: var a
        ;   rsp+4: var b
@main:
        ; reserve space for local variables
        sub rsp, 6
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0(u8 t.5), 22
        ld r0, 22
        ; cast r0(i16 foo), r0(u8 t.5)
        ; mul r0(i16 bar), r0(i16 foo), r0(i16 foo)
        ; const r1(i16 foo), 1
        ld r5, 1
        ld r4, 0
        ; add r0(i16 t.6), r0(i16 bar), r1(i16 foo)
        ; call _, printIntLf [r0(i16 t.6)]
        ; const r0(u8 t.7), 21
        ld r0, 21
        ; cast r0(i16 foo), r0(u8 t.7)
        ; call _, printIntLf [r0(i16 foo)]
        ; call _, printIntLf [bazz(0@function,i16)]
        ; const r0(i16 a), 1000
        ld r1, 232
        ld r0, 3
        ; const r1(i16 b), 10
        ld r5, 10
        ld r4, 0
        ; div r1(i16 t.8), r0(i16 a), r1(i16 b)
        ; copy a(1@function,i16), r0(i16 a)
        ; call _, printIntLf [r1(i16 t.8)]
        ; const r0(i16 t.10), 255
        ld r1, 255
        ld r0, 0
        ; copy r1(i16 a), a(1@function,i16)
        ; and r0(i16 t.9), r1(i16 a), r0(i16 t.10)
        ; call _, printIntLf [r0(i16 t.9)]
        ; const r0(i16 a), 10
        ld r1, 10
        ld r0, 0
        ; const r1(i16 b), 1
        ld r5, 1
        ld r4, 0
        ; shiftright r0(i16 t.11), r0(i16 a), r1(i16 b)
        ; call _, printIntLf [r0(i16 t.11)]
        ; const r0(i16 a), 9
        ld r1, 9
        ld r0, 0
        ; const r1(i16 b), 2
        ld r5, 2
        ld r4, 0
        ; shiftright r0(i16 t.12), r0(i16 a), r1(i16 b)
        ; copy b(2@function,i16), r1(i16 b)
        ; call _, printIntLf [r0(i16 t.12)]
        ; const r0(i16 a), 1
        ld r1, 1
        ld r0, 0
        ; copy r1(i16 b), b(2@function,i16)
        ; shiftleft r0(i16 t.13), r0(i16 a), r1(i16 b)
        ; call _, printIntLf [r0(i16 t.13)]
        ; release space for local variables
        add rsp, 6
        ret


