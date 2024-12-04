        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void printString
        ;   rsp+11: arg str
        ;   rsp+0: var chr
@printString:
        ; reserve space for local variables
        sub rsp, 1
@while_1:
        ; move r0, str
        ; load r1, [r0]
        ; 4:3 if chr == 0
        ; const r2, 0
        ld r8, 0
        ; equals r2, r1, r2
        ; move chr, r1
        ; branch r2, true, @printString_ret
        jnz @printString_ret
        ; @if_2_end
        ; call _, printChar [chr]
        ; jump @while_1
        jmp @while_1
@printString_ret:
        ; release space for local variables
        add rsp, 1
        ret

        ; void printStringLength
        ;   rsp+3: arg str
        ;   rsp+11: arg length
@printStringLength:
@while_3:
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
        ; jump @while_3
        jmp @while_3
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
@while_4:
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
        ; branch r0, false, @while_4
        jz @while_4
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
        ; branch r0, false, @if_6_end
        jz @if_6_end
        ; 
        ; const r0, 45
        ld r0, 45
        ; call _, printChar [r0]
        ; move r0, number
        ; neg r0, r0
        ; move number, r0
@if_6_end:
        ; call _, printUint [number]
        ; const r0, 10
        ld r0, 10
        ; call _, printChar [r0]
        ret

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
        ; const r0, [string-0]
        ; call _, printString [r0]
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; const r1, 2
        ld r5, 2
        ld r4, 0
        ; lt r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; move a, r0
        ; move b, r1
        ; call _, printIntLf [r2]
        ; move r0, b
        ; move r1, a
        ; lt r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-1]
        ; call _, printString [r0]
        ; const r0, 0
        ld r0, 0
        ; const r1, 128
        ld r4, 128
        ; lt r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; move c, r0
        ; move d, r1
        ; call _, printIntLf [r2]
        ; move r0, d
        ; move r1, c
        ; lt r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-2]
        ; call _, printString [r0]
        ; move r0, a
        ; move r1, b
        ; lteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, b
        ; move r1, a
        ; lteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-3]
        ; call _, printString [r0]
        ; move r0, c
        ; move r1, d
        ; lteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, d
        ; move r1, c
        ; lteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-4]
        ; call _, printString [r0]
        ; move r0, a
        ; move r1, b
        ; equals r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, b
        ; move r1, a
        ; equals r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-5]
        ; call _, printString [r0]
        ; move r0, a
        ; move r1, b
        ; notequals r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, b
        ; move r1, a
        ; notequals r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-6]
        ; call _, printString [r0]
        ; move r0, a
        ; move r1, b
        ; gteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, b
        ; move r1, a
        ; gteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-7]
        ; call _, printString [r0]
        ; move r0, c
        ; move r1, d
        ; gteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, d
        ; move r1, c
        ; gteq r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; const r0, [string-8]
        ; call _, printString [r0]
        ; move r0, a
        ; move r1, b
        ; gt r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, b
        ; move r1, a
        ; gt r0, r0, r1
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; const r0, [string-9]
        ; call _, printString [r0]
        ; move r0, c
        ; move r1, d
        ; gt r2, r0, r1
        ; cast r2(i16), r2(bool)
        ; call _, printIntLf [r2]
        ; move r0, d
        ; move r1, c
        ; gt r0, r0, r1
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; release space for local variables
        add rsp, 6
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

