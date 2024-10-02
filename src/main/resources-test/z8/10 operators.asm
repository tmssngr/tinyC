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
        ; branch r0(bool t.14), false, @while_4
        jz @while_4
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
        ;   rsp+6: var d
        ;   rsp+8: var t
        ;   rsp+9: var f
        ;   rsp+10: var b1
        ;   rsp+11: var t.26
        ;   rsp+12: var t.28
        ;   rsp+13: var t.30
        ;   rsp+14: var t.32
        ;   rsp+15: var t.35
        ;   rsp+16: var t.37
        ;   rsp+17: var t.39
        ;   rsp+18: var t.41
        ;   rsp+19: var t.52
        ;   rsp+20: var t.54
@main:
        ; reserve space for local variables
        sub rsp, 21
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0(u8* t.9), [string-0]
        ; call _, printString [r0(u8* t.9)]
        ; const r0(i16 a), 0
        ld r1, 0
        ld r0, 0
        ; const r1(i16 b), 1
        ld r5, 1
        ld r4, 0
        ; const r2(i16 c), 2
        ld r9, 2
        ld r8, 0
        ; const r3(i16 d), 3
        ld r13, 3
        ld r12, 0
        ; Spill a
        ; copy a(0@function,i16), r0(i16 a)
        ; const r0(bool t), 1
        ld r0, 1
        ; Spill t
        ; copy t(4@function,bool), r0(bool t)
        ; const r0(bool f), 0
        ld r0, 0
        ; Spill f
        ; copy f(5@function,bool), r0(bool f)
        ; Spill b
        ; copy b(1@function,i16), r1(i16 b)
        ; copy r0(i16 a), a(0@function,i16)
        ; and r1(i16 t.10), r0(i16 a), r0(i16 a)
        ; copy c(2@function,i16), r2(i16 c)
        ; copy d(3@function,i16), r3(i16 d)
        ; call _, printIntLf [r1(i16 t.10)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 b), b(1@function,i16)
        ; and r2(i16 t.11), r0(i16 a), r1(i16 b)
        ; call _, printIntLf [r2(i16 t.11)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; and r2(i16 t.12), r0(i16 b), r1(i16 a)
        ; call _, printIntLf [r2(i16 t.12)]
        ; copy r0(i16 b), b(1@function,i16)
        ; and r1(i16 t.13), r0(i16 b), r0(i16 b)
        ; call _, printIntLf [r1(i16 t.13)]
        ; const r0(u8* t.14), [string-1]
        ; call _, printString [r0(u8* t.14)]
        ; copy r0(i16 a), a(0@function,i16)
        ; or r1(i16 t.15), r0(i16 a), r0(i16 a)
        ; call _, printIntLf [r1(i16 t.15)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 b), b(1@function,i16)
        ; or r2(i16 t.16), r0(i16 a), r1(i16 b)
        ; call _, printIntLf [r2(i16 t.16)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; or r2(i16 t.17), r0(i16 b), r1(i16 a)
        ; call _, printIntLf [r2(i16 t.17)]
        ; copy r0(i16 b), b(1@function,i16)
        ; or r1(i16 t.18), r0(i16 b), r0(i16 b)
        ; call _, printIntLf [r1(i16 t.18)]
        ; const r0(u8* t.19), [string-2]
        ; call _, printString [r0(u8* t.19)]
        ; copy r0(i16 a), a(0@function,i16)
        ; xor r1(i16 t.20), r0(i16 a), r0(i16 a)
        ; call _, printIntLf [r1(i16 t.20)]
        ; copy r0(i16 a), a(0@function,i16)
        ; copy r1(i16 c), c(2@function,i16)
        ; xor r2(i16 t.21), r0(i16 a), r1(i16 c)
        ; call _, printIntLf [r2(i16 t.21)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 a), a(0@function,i16)
        ; xor r1(i16 t.22), r0(i16 b), r1(i16 a)
        ; call _, printIntLf [r1(i16 t.22)]
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 c), c(2@function,i16)
        ; xor r2(i16 t.23), r0(i16 b), r1(i16 c)
        ; call _, printIntLf [r2(i16 t.23)]
        ; const r0(u8* t.24), [string-3]
        ; call _, printString [r0(u8* t.24)]
        ; 26:15 logic and
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.26), r0(bool f)
        ; copy t.26(7@function,bool), r1(bool t.26)
        ; branch r1(bool t.26), false, @and_next_7
        jz @and_next_7
        ; 
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.26), r0(bool f)
        ; copy t.26(7@function,bool), r1(bool t.26)
@and_next_7:
        ; copy r0(bool t.26), t.26(7@function,bool)
        ; cast r0(i16 t.25), r0(bool t.26)
        ; call _, printIntLf [r0(i16 t.25)]
        ; 27:15 logic and
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.28), r0(bool f)
        ; copy t.28(8@function,bool), r1(bool t.28)
        ; branch r1(bool t.28), false, @and_next_8
        jz @and_next_8
        ; 
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.28), r0(bool t)
        ; copy t.28(8@function,bool), r1(bool t.28)
@and_next_8:
        ; copy r0(bool t.28), t.28(8@function,bool)
        ; cast r0(i16 t.27), r0(bool t.28)
        ; call _, printIntLf [r0(i16 t.27)]
        ; 28:15 logic and
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.30), r0(bool t)
        ; copy t.30(9@function,bool), r1(bool t.30)
        ; branch r1(bool t.30), false, @and_next_9
        jz @and_next_9
        ; 
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.30), r0(bool f)
        ; copy t.30(9@function,bool), r1(bool t.30)
@and_next_9:
        ; copy r0(bool t.30), t.30(9@function,bool)
        ; cast r0(i16 t.29), r0(bool t.30)
        ; call _, printIntLf [r0(i16 t.29)]
        ; 29:15 logic and
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.32), r0(bool t)
        ; copy t.32(10@function,bool), r1(bool t.32)
        ; branch r1(bool t.32), false, @and_next_10
        jz @and_next_10
        ; 
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.32), r0(bool t)
        ; copy t.32(10@function,bool), r1(bool t.32)
@and_next_10:
        ; copy r0(bool t.32), t.32(10@function,bool)
        ; cast r0(i16 t.31), r0(bool t.32)
        ; call _, printIntLf [r0(i16 t.31)]
        ; const r0(u8* t.33), [string-4]
        ; call _, printString [r0(u8* t.33)]
        ; 31:15 logic or
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.35), r0(bool f)
        ; copy t.35(11@function,bool), r1(bool t.35)
        ; branch r1(bool t.35), true, @or_next_11
        jnz @or_next_11
        ; 
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.35), r0(bool f)
        ; copy t.35(11@function,bool), r1(bool t.35)
@or_next_11:
        ; copy r0(bool t.35), t.35(11@function,bool)
        ; cast r0(i16 t.34), r0(bool t.35)
        ; call _, printIntLf [r0(i16 t.34)]
        ; 32:15 logic or
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.37), r0(bool f)
        ; copy t.37(12@function,bool), r1(bool t.37)
        ; branch r1(bool t.37), true, @or_next_12
        jnz @or_next_12
        ; 
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.37), r0(bool t)
        ; copy t.37(12@function,bool), r1(bool t.37)
@or_next_12:
        ; copy r0(bool t.37), t.37(12@function,bool)
        ; cast r0(i16 t.36), r0(bool t.37)
        ; call _, printIntLf [r0(i16 t.36)]
        ; 33:15 logic or
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.39), r0(bool t)
        ; copy t.39(13@function,bool), r1(bool t.39)
        ; branch r1(bool t.39), true, @or_next_13
        jnz @or_next_13
        ; 
        ; copy r0(bool f), f(5@function,bool)
        ; copy r1(bool t.39), r0(bool f)
        ; copy t.39(13@function,bool), r1(bool t.39)
@or_next_13:
        ; copy r0(bool t.39), t.39(13@function,bool)
        ; cast r0(i16 t.38), r0(bool t.39)
        ; call _, printIntLf [r0(i16 t.38)]
        ; 34:15 logic or
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.41), r0(bool t)
        ; copy t.41(14@function,bool), r1(bool t.41)
        ; branch r1(bool t.41), true, @or_next_14
        jnz @or_next_14
        ; 
        ; copy r0(bool t), t(4@function,bool)
        ; copy r1(bool t.41), r0(bool t)
        ; copy t.41(14@function,bool), r1(bool t.41)
@or_next_14:
        ; copy r0(bool t.41), t.41(14@function,bool)
        ; cast r0(i16 t.40), r0(bool t.41)
        ; call _, printIntLf [r0(i16 t.40)]
        ; const r0(u8* t.42), [string-5]
        ; call _, printString [r0(u8* t.42)]
        ; copy r0(bool f), f(5@function,bool)
        ; notlog r0(bool t.44), r0(bool f)
        ; cast r0(i16 t.43), r0(bool t.44)
        ; call _, printIntLf [r0(i16 t.43)]
        ; copy r0(bool t), t(4@function,bool)
        ; notlog r0(bool t.46), r0(bool t)
        ; cast r0(i16 t.45), r0(bool t.46)
        ; call _, printIntLf [r0(i16 t.45)]
        ; const r0(u8* t.47), [string-6]
        ; call _, printString [r0(u8* t.47)]
        ; const r0(u8 b10), 10
        ld r0, 10
        ; const r1(u8 b6), 6
        ld r4, 6
        ; const r2(u8 b1), 1
        ld r8, 1
        ; and r0(u8 t.50), r0(u8 b10), r1(u8 b6)
        ; or r0(u8 t.49), r0(u8 t.50), r2(u8 b1)
        ; cast r0(i16 t.48), r0(u8 t.49)
        ; copy b1(6@function,u8), r2(u8 b1)
        ; call _, printIntLf [r0(i16 t.48)]
        ; 43:20 logic or
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 c), c(2@function,i16)
        ; equals r2(bool t.52), r0(i16 b), r1(i16 c)
        ; copy t.52(15@function,bool), r2(bool t.52)
        ; branch r2(bool t.52), true, @or_next_15
        jnz @or_next_15
        ; 
        ; copy r0(i16 c), c(2@function,i16)
        ; copy r1(i16 d), d(3@function,i16)
        ; lt r2(bool t.52), r0(i16 c), r1(i16 d)
        ; copy t.52(15@function,bool), r2(bool t.52)
@or_next_15:
        ; copy r0(bool t.52), t.52(15@function,bool)
        ; cast r0(i16 t.51), r0(bool t.52)
        ; call _, printIntLf [r0(i16 t.51)]
        ; 44:20 logic and
        ; copy r0(i16 b), b(1@function,i16)
        ; copy r1(i16 c), c(2@function,i16)
        ; equals r2(bool t.54), r0(i16 b), r1(i16 c)
        ; copy t.54(16@function,bool), r2(bool t.54)
        ; branch r2(bool t.54), false, @and_next_16
        jz @and_next_16
        ; 
        ; copy r0(i16 c), c(2@function,i16)
        ; copy r1(i16 d), d(3@function,i16)
        ; lt r0(bool t.54), r0(i16 c), r1(i16 d)
        ; copy t.54(16@function,bool), r0(bool t.54)
@and_next_16:
        ; copy r0(bool t.54), t.54(16@function,bool)
        ; cast r0(i16 t.53), r0(bool t.54)
        ; call _, printIntLf [r0(i16 t.53)]
        ; const r0(i16 t.55), -1
        ld r1, 255
        ld r0, 255
        ; call _, printIntLf [r0(i16 t.55)]
        ; copy r0(i16 b), b(1@function,i16)
        ; neg r0(i16 t.56), r0(i16 b)
        ; call _, printIntLf [r0(i16 t.56)]
        ; copy r0(u8 b1), b1(6@function,u8)
        ; not r0(u8 t.58), r0(u8 b1)
        ; cast r0(i16 t.57), r0(u8 t.58)
        ; call _, printIntLf [r0(i16 t.57)]
        ; release space for local variables
        add rsp, 21
        ret


string_0:
        'Bit-&:', 0x0a, 0x00
string_1:
        0x0a, 'Bit-|:', 0x0a, 0x00
string_2:
        0x0a, 'Bit-^:', 0x0a, 0x00
string_3:
        0x0a, 'Logic-&&:', 0x0a, 0x00
string_4:
        0x0a, 'Logic-||:', 0x0a, 0x00
string_5:
        0x0a, 'Logic-!:', 0x0a, 0x00
string_6:
        0x0a, 'misc:', 0x0a, 0x00

