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
@main:
        ; begin initialize global variables
        ; const r0, [string-0]
        ; end initialize global variables
        ; move text, r0
        ; call _, printString [r0]
        ; call _, printLength []
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; cast r0(u8*), r0(i16)
        ; move r1, text
        ; move r2, r1
        ; add r0, r2, r0
        ; call _, printString [r0]
        ; move r0, text
        ; load r0, [r0]
        ; cast r0(i16), r0(u8)
        ; call _, printIntLf [r0]
        ret

        ; void printLength
        ;   rsp+0: var length
        ;   rsp+2: var ptr
@printLength:
        ; reserve space for local variables
        sub rsp, 10
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, text
        ; 16:2 for *ptr != 0
        ; move length, r0
        ; move ptr, r1
@for_7:
        ; move r0, ptr
        ; load r1, [r0]
        ; const r2, 0
        ld r8, 0
        ; notequals r1, r1, r2
        ; branch r1, false, @for_7_break
        jz @for_7_break
        ; @for_7_body
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, length
        ; add r0, r1, r0
        ; move r1, ptr
        ; cast r1(i16), r1(u8*)
        ; const r2, 1
        ld r9, 1
        ld r8, 0
        ; add r1, r1, r2
        ; cast r1(u8*), r1(i16)
        ; move length, r0
        ; move ptr, r1
        ; jump @for_7
        jmp @for_7
@for_7_break:
        ; call _, printIntLf [length]
        ; release space for local variables
        add rsp, 10
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

        ; variable 0: text (u8*/8)
var_0:
        .repeat 8
        .data 0
        .end

string_0:
        'hello world', 0x0a, 0x00

