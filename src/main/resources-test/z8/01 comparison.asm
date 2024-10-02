        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void printString
        ;   rsp+8: arg str
        ;   rsp+0: var chr
@printString:
        ; reserve space for local variables
        sub rsp, 1
@while_1:
        ; copy r0(u8* str), str(0@argument,u8*)
        ; load r1(u8 chr), [r0(u8* str)]
        ; 4:3 if chr == 0
        ; const r2(u8 t.3), 0
        ld r8, 0
        ; equals r2(bool t.2), r1(u8 chr), r2(u8 t.3)
        ; copy chr(1@function,u8), r1(u8 chr)
        ; branch r2(bool t.2), false, @if_2_end
        jz @if_2_end
        ; @if_2_then
        ; jump @printString_ret
        jmp @printString_ret
@if_2_end:
        ; call _, printChar [chr(1@function,u8)]
        ; jump @while_1
        jmp @while_1
@printString_ret:
        ; release space for local variables
        add rsp, 1
        ret

        ; void printStringLength
        ;   rsp+1: arg str
        ;   rsp+8: arg length
@printStringLength:
@while_3:
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
        ; jump @while_3
        jmp @while_3
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
@while_4:
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
        ; cast r3(i16 t.11), r0(u8 pos)
        ; array r3(u8* t.12), buffer(1@function,u8*) + r3(i16 t.11)
        ; store [r3(u8* t.12)], r1(u8 digit)
        ; 30:3 if number == 0
        ; const r1(i16 t.14), 0
        ld r5, 0
        ld r4, 0
        ; equals r1(bool t.13), r2(i16 number), r1(i16 t.14)
        ; copy pos(2@function,u8), r0(u8 pos)
        ; copy number(0@argument,i16), r2(i16 number)
        ; branch r1(bool t.13), false, @while_4
        jz @while_4
        ; 
        ; copy r0(u8 pos), pos(2@function,u8)
        ; cast r1(i16 t.16), r0(u8 pos)
        ; addrof r1(u8* t.15), [buffer(1@function,u8*) + r1(i16 t.16)]
        ; const r2(u8 t.18), 20
        ld r8, 20
        ; sub r0(u8 t.17), r2(u8 t.18), r0(u8 pos)
        ; call _, printStringLength [r1(u8* t.15), r0(u8 t.17)]
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
        ; branch r0(bool t.1), false, @if_6_end
        jz @if_6_end
        ; 
        ; const r0(u8 t.3), 45
        ld r0, 45
        ; call _, printChar [r0(u8 t.3)]
        ; copy r0(i16 number), number(0@argument,i16)
        ; neg r0(i16 number), r0(i16 number)
        ; copy number(0@argument,i16), r0(i16 number)
@if_6_end:
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
        ;   rsp+0: var a
        ;   rsp+2: var b
        ;   rsp+4: var c
        ;   rsp+5: var d
@main:
        ; reserve space for local variables
        sub rsp, 6
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0(u8* t.4), [string-0]
        ; call _, printString [r0(u8* t.4)]
        ; const r0(i16 a), 1
        ld r1, 1
        ld r0, 0
        ; const r1(i16 b), 2
        ld r5, 2
        ld r4, 0
        ; lt r2(bool t.6), r0(i16 a), r1(i16 b)
        ; cast r2(i16 t.5), r2(bool t.6)
        ; copy a(0@function,i16), r0(i16 a)
        ; copy b(1@function,i16), r1(i16 b)
        ; call _, printIntLf [r2(i16 t.5)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; lt r2(bool t.8), r0(i16 b), r1(i16 a)
        ; cast r2(i16 t.7), r2(bool t.8)
        ; call _, printIntLf [r2(i16 t.7)]
        ; const r0(u8* t.9), [string-1]
        ; call _, printString [r0(u8* t.9)]
        ; const r0(u8 c), 0
        ld r0, 0
        ; const r1(u8 d), 128
        ld r4, 128
        ; lt r2(bool t.11), r0(u8 c), r1(u8 d)
        ; cast r2(i16 t.10), r2(bool t.11)
        ; copy c(2@function,u8), r0(u8 c)
        ; copy d(3@function,u8), r1(u8 d)
        ; call _, printIntLf [r2(i16 t.10)]
        ; copy r0(u8 d), d(3@function,u8)
        ; copy r1(u8 c), c(2@function,u8)
        ; lt r2(bool t.13), r0(u8 d), r1(u8 c)
        ; cast r2(i16 t.12), r2(bool t.13)
        ; call _, printIntLf [r2(i16 t.12)]
        ; const r0(u8* t.14), [string-2]
        ; call _, printString [r0(u8* t.14)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 b), b(1@function,i16)
        ; lteq r2(bool t.16), r0(i16 a), r1(i16 b)
        ; cast r2(i16 t.15), r2(bool t.16)
        ; call _, printIntLf [r2(i16 t.15)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; lteq r2(bool t.18), r0(i16 b), r1(i16 a)
        ; cast r2(i16 t.17), r2(bool t.18)
        ; call _, printIntLf [r2(i16 t.17)]
        ; const r0(u8* t.19), [string-3]
        ; call _, printString [r0(u8* t.19)]
        ; copy r0(u8 c), c(2@function,u8)
        ; copy r1(u8 d), d(3@function,u8)
        ; lteq r2(bool t.21), r0(u8 c), r1(u8 d)
        ; cast r2(i16 t.20), r2(bool t.21)
        ; call _, printIntLf [r2(i16 t.20)]
        ; copy r0(u8 d), d(3@function,u8)
        ; copy r1(u8 c), c(2@function,u8)
        ; lteq r2(bool t.23), r0(u8 d), r1(u8 c)
        ; cast r2(i16 t.22), r2(bool t.23)
        ; call _, printIntLf [r2(i16 t.22)]
        ; const r0(u8* t.24), [string-4]
        ; call _, printString [r0(u8* t.24)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 b), b(1@function,i16)
        ; equals r2(bool t.26), r0(i16 a), r1(i16 b)
        ; cast r2(i16 t.25), r2(bool t.26)
        ; call _, printIntLf [r2(i16 t.25)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; equals r2(bool t.28), r0(i16 b), r1(i16 a)
        ; cast r2(i16 t.27), r2(bool t.28)
        ; call _, printIntLf [r2(i16 t.27)]
        ; const r0(u8* t.29), [string-5]
        ; call _, printString [r0(u8* t.29)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 b), b(1@function,i16)
        ; notequals r2(bool t.31), r0(i16 a), r1(i16 b)
        ; cast r2(i16 t.30), r2(bool t.31)
        ; call _, printIntLf [r2(i16 t.30)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; notequals r2(bool t.33), r0(i16 b), r1(i16 a)
        ; cast r2(i16 t.32), r2(bool t.33)
        ; call _, printIntLf [r2(i16 t.32)]
        ; const r0(u8* t.34), [string-6]
        ; call _, printString [r0(u8* t.34)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 b), b(1@function,i16)
        ; gteq r2(bool t.36), r0(i16 a), r1(i16 b)
        ; cast r2(i16 t.35), r2(bool t.36)
        ; call _, printIntLf [r2(i16 t.35)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; gteq r2(bool t.38), r0(i16 b), r1(i16 a)
        ; cast r2(i16 t.37), r2(bool t.38)
        ; call _, printIntLf [r2(i16 t.37)]
        ; const r0(u8* t.39), [string-7]
        ; call _, printString [r0(u8* t.39)]
        ; copy r0(u8 c), c(2@function,u8)
        ; copy r1(u8 d), d(3@function,u8)
        ; gteq r2(bool t.41), r0(u8 c), r1(u8 d)
        ; cast r2(i16 t.40), r2(bool t.41)
        ; call _, printIntLf [r2(i16 t.40)]
        ; copy r0(u8 d), d(3@function,u8)
        ; copy r1(u8 c), c(2@function,u8)
        ; gteq r2(bool t.43), r0(u8 d), r1(u8 c)
        ; cast r2(i16 t.42), r2(bool t.43)
        ; call _, printIntLf [r2(i16 t.42)]
        ; const r0(u8* t.44), [string-8]
        ; call _, printString [r0(u8* t.44)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 b), b(1@function,i16)
        ; gt r2(bool t.46), r0(i16 a), r1(i16 b)
        ; cast r2(i16 t.45), r2(bool t.46)
        ; call _, printIntLf [r2(i16 t.45)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; gt r0(bool t.48), r0(i16 b), r1(i16 a)
        ; cast r0(i16 t.47), r0(bool t.48)
        ; call _, printIntLf [r0(i16 t.47)]
        ; const r0(u8* t.49), [string-9]
        ; call _, printString [r0(u8* t.49)]
        ; copy r0(u8 c), c(2@function,u8)
        ; copy r1(u8 d), d(3@function,u8)
        ; gt r2(bool t.51), r0(u8 c), r1(u8 d)
        ; cast r2(i16 t.50), r2(bool t.51)
        ; call _, printIntLf [r2(i16 t.50)]
        ; copy r0(u8 d), d(3@function,u8)
        ; copy r1(u8 c), c(2@function,u8)
        ; gt r0(bool t.53), r0(u8 d), r1(u8 c)
        ; cast r0(i16 t.52), r0(bool t.53)
        ; call _, printIntLf [r0(i16 t.52)]
        ; release space for local variables
        add rsp, 6
        ret


string_0:
        '< (signed)', 0x0a, 0x00
string_1:
        '< (unsigned)', 0x0a, 0x00
string_2:
        '<= (signed)', 0x0a, 0x00
string_3:
        '<= (unsigned)', 0x0a, 0x00
string_4:
        '==', 0x0a, 0x00
string_5:
        '!=', 0x0a, 0x00
string_6:
        '>= (signed)', 0x0a, 0x00
string_7:
        '>= (unsigned)', 0x0a, 0x00
string_8:
        '> (signed)', 0x0a, 0x00
string_9:
        '> (unsigned)', 0x0a, 0x00

