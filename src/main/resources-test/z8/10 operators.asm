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
        ; const r0, [string-0]
        ; call _, printString [r0]
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; const r1, 1
        ld r5, 1
        ld r4, 0
        ; const r2, 2
        ld r9, 2
        ld r8, 0
        ; const r3, 3
        ld r13, 3
        ld r12, 0
        ; Spill a
        ; move a, r0
        ; const r0, 1
        ld r0, 1
        ; Spill t
        ; move t, r0
        ; const r0, 0
        ld r0, 0
        ; Spill f
        ; move f, r0
        ; Spill b
        ; move b, r1
        ; move r0, a
        ; move r1, r0
        ; and r1, r1, r0
        ; move c, r2
        ; move d, r3
        ; call _, printIntLf [r1]
        ; move r0, a
        ; move r1, r0
        ; move r2, b
        ; and r1, r1, r2
        ; call _, printIntLf [r1]
        ; move r0, b
        ; move r1, r0
        ; move r2, a
        ; and r1, r1, r2
        ; call _, printIntLf [r1]
        ; move r0, b
        ; move r1, r0
        ; and r1, r1, r0
        ; call _, printIntLf [r1]
        ; const r0, [string-1]
        ; call _, printString [r0]
        ; move r0, a
        ; move r1, r0
        ; or r1, r1, r0
        ; call _, printIntLf [r1]
        ; move r0, a
        ; move r1, r0
        ; move r2, b
        ; or r1, r1, r2
        ; call _, printIntLf [r1]
        ; move r0, b
        ; move r1, r0
        ; move r2, a
        ; or r1, r1, r2
        ; call _, printIntLf [r1]
        ; move r0, b
        ; move r1, r0
        ; or r1, r1, r0
        ; call _, printIntLf [r1]
        ; const r0, [string-2]
        ; call _, printString [r0]
        ; move r0, a
        ; move r1, r0
        ; xor r1, r1, r0
        ; call _, printIntLf [r1]
        ; move r0, a
        ; move r1, r0
        ; move r2, c
        ; xor r1, r1, r2
        ; call _, printIntLf [r1]
        ; move r0, b
        ; move r1, r0
        ; move r2, a
        ; xor r1, r1, r2
        ; call _, printIntLf [r1]
        ; move r0, b
        ; move r1, r0
        ; move r2, c
        ; xor r1, r1, r2
        ; call _, printIntLf [r1]
        ; const r0, [string-3]
        ; call _, printString [r0]
        ; 26:15 logic and
        ; move r0, f
        ; move r1, r0
        ; move t.26, r1
        ; branch r1, false, @and_next_7
        jz @and_next_7
        ; 
        ; move r0, f
        ; move r1, r0
        ; move t.26, r1
@and_next_7:
        ; move r0, t.26
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; 27:15 logic and
        ; move r0, f
        ; move r1, r0
        ; move t.28, r1
        ; branch r1, false, @and_next_8
        jz @and_next_8
        ; 
        ; move r0, t
        ; move r1, r0
        ; move t.28, r1
@and_next_8:
        ; move r0, t.28
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; 28:15 logic and
        ; move r0, t
        ; move r1, r0
        ; move t.30, r1
        ; branch r1, false, @and_next_9
        jz @and_next_9
        ; 
        ; move r0, f
        ; move r1, r0
        ; move t.30, r1
@and_next_9:
        ; move r0, t.30
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; 29:15 logic and
        ; move r0, t
        ; move r1, r0
        ; move t.32, r1
        ; branch r1, false, @and_next_10
        jz @and_next_10
        ; 
        ; move r0, t
        ; move r1, r0
        ; move t.32, r1
@and_next_10:
        ; move r0, t.32
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; const r0, [string-4]
        ; call _, printString [r0]
        ; 31:15 logic or
        ; move r0, f
        ; move r1, r0
        ; move t.35, r1
        ; branch r1, true, @or_next_11
        jnz @or_next_11
        ; 
        ; move r0, f
        ; move r1, r0
        ; move t.35, r1
@or_next_11:
        ; move r0, t.35
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; 32:15 logic or
        ; move r0, f
        ; move r1, r0
        ; move t.37, r1
        ; branch r1, true, @or_next_12
        jnz @or_next_12
        ; 
        ; move r0, t
        ; move r1, r0
        ; move t.37, r1
@or_next_12:
        ; move r0, t.37
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; 33:15 logic or
        ; move r0, t
        ; move r1, r0
        ; move t.39, r1
        ; branch r1, true, @or_next_13
        jnz @or_next_13
        ; 
        ; move r0, f
        ; move r1, r0
        ; move t.39, r1
@or_next_13:
        ; move r0, t.39
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; 34:15 logic or
        ; move r0, t
        ; move r1, r0
        ; move t.41, r1
        ; branch r1, true, @or_next_14
        jnz @or_next_14
        ; 
        ; move r0, t
        ; move r1, r0
        ; move t.41, r1
@or_next_14:
        ; move r0, t.41
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; const r0, [string-5]
        ; call _, printString [r0]
        ; move r0, f
        ; notlog r0, r0
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; move r0, t
        ; notlog r0, r0
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; const r0, [string-6]
        ; call _, printString [r0]
        ; const r0, 10
        ld r0, 10
        ; const r1, 6
        ld r4, 6
        ; const r2, 1
        ld r8, 1
        ; and r0, r0, r1
        ; or r0, r0, r2
        ; cast r0(i16), r0(u8)
        ; move b1, r2
        ; call _, printIntLf [r0]
        ; 43:20 logic or
        ; move r0, b
        ; move r1, c
        ; equals r2, r0, r1
        ; move t.52, r2
        ; branch r2, true, @or_next_15
        jnz @or_next_15
        ; 
        ; move r0, c
        ; move r1, d
        ; lt r2, r0, r1
        ; move t.52, r2
@or_next_15:
        ; move r0, t.52
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; 44:20 logic and
        ; move r0, b
        ; move r1, c
        ; equals r2, r0, r1
        ; move t.54, r2
        ; branch r2, false, @and_next_16
        jz @and_next_16
        ; 
        ; move r0, c
        ; move r1, d
        ; lt r0, r0, r1
        ; move t.54, r0
@and_next_16:
        ; move r0, t.54
        ; cast r0(i16), r0(bool)
        ; call _, printIntLf [r0]
        ; const r0, -1
        ld r1, 255
        ld r0, 255
        ; call _, printIntLf [r0]
        ; move r0, b
        ; neg r0, r0
        ; call _, printIntLf [r0]
        ; move r0, b1
        ; not r0, r0
        ; cast r0(i16), r0(u8)
        ; call _, printIntLf [r0]
        ; release space for local variables
        add rsp, 21
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

