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

        ; void printBoard
        ;   rsp+0: var i
@printBoard:
        ; reserve space for local variables
        sub rsp, 1
        ; const r0, 124
        ld r0, 124
        ; call _, printChar [r0]
        ; const r0, 0
        ld r0, 0
        ; 11:2 for i < 30
        ; move i, r0
@for_3:
        ; const r0, 30
        ld r0, 30
        ; move r1, i
        ; lt r0, r1, r0
        ; branch r0, false, @for_3_break
        jz @for_3_break
        ; @for_3_body
        ; 12:3 if [...] == 0
        ; move r0, i
        ; cast r1(i16), r0(u8)
        ; cast r1(u8*), r1(i16)
        ; addrof r2, [board]
        ; add r1, r2, r1
        ; load r1, [r1]
        ; const r2, 0
        ld r8, 0
        ; equals r1, r1, r2
        ; branch r1, false, @if_4_else
        jz @if_4_else
        ; @if_4_then
        ; const r0, 32
        ld r0, 32
        ; call _, printChar [r0]
        ; jump @for_3_continue
        jmp @for_3_continue
@if_4_else:
        ; const r0, 42
        ld r0, 42
        ; call _, printChar [r0]
@for_3_continue:
        ; const r0, 1
        ld r0, 1
        ; move r1, i
        ; add r0, r1, r0
        ; move i, r0
        ; jump @for_3
        jmp @for_3
@for_3_break:
        ; const r0, [string-0]
        ; call _, printString [r0]
        ; release space for local variables
        add rsp, 1
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
        ;   rsp+2: var pattern
        ;   rsp+3: var j
@main:
        ; reserve space for local variables
        sub rsp, 4
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, 0
        ld r0, 0
        ; 23:2 for i < 30
        ; move i, r0
@for_5:
        ; const r0, 30
        ld r0, 30
        ; move r1, i
        ; lt r0, r1, r0
        ; branch r0, false, @for_5_break
        jz @for_5_break
        ; @for_5_body
        ; const r0, 0
        ld r0, 0
        ; move r1, i
        ; cast r2(i16), r1(u8)
        ; cast r2(u8*), r2(i16)
        ; addrof r3, [board]
        ; add r2, r3, r2
        ; store [r2], r0
        ; const r0, 1
        ld r0, 1
        ; add r0, r1, r0
        ; move i, r0
        ; jump @for_5
        jmp @for_5
@for_5_break:
        ; const r0, 1
        ld r0, 1
        ; const r1, 29
        ld r4, 29
        ; cast r1(i16), r1(u8)
        ; cast r1(u8*), r1(i16)
        ; addrof r2, [board]
        ; add r1, r2, r1
        ; store [r1], r0
        ; call _, printBoard []
        ; const r0, 0
        ld r0, 0
        ; 30:2 for i < 28
        ; move i, r0
@for_6:
        ; const r0, 28
        ld r0, 28
        ; move r1, i
        ; lt r0, r1, r0
        ; branch r0, false, @main_ret
        jz @main_ret
        ; 
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; cast r0(u8*), r0(i16)
        ; addrof r1, [board]
        ; add r0, r1, r0
        ; load r0, [r0]
        ; const r1, 1
        ld r4, 1
        ; shiftleft r0, r0, r1
        ; const r1, 1
        ld r5, 1
        ld r4, 0
        ; cast r1(u8*), r1(i16)
        ; addrof r2, [board]
        ; add r1, r2, r1
        ; load r1, [r1]
        ; or r0, r0, r1
        ; const r1, 1
        ld r4, 1
        ; 32:3 for j < 29
        ; move pattern, r0
        ; move j, r1
@for_7:
        ; const r0, 29
        ld r0, 29
        ; move r1, j
        ; lt r0, r1, r0
        ; branch r0, false, @for_7_break
        jz @for_7_break
        ; @for_7_body
        ; const r0, 1
        ld r0, 1
        ; move r1, pattern
        ; shiftleft r0, r1, r0
        ; const r1, 7
        ld r4, 7
        ; and r0, r0, r1
        ; const r1, 1
        ld r4, 1
        ; move r2, j
        ; move r3, r2
        ; add r1, r3, r1
        ; cast r1(i16), r1(u8)
        ; cast r1(u8*), r1(i16)
        ; addrof r3, [board]
        ; add r1, r3, r1
        ; load r1, [r1]
        ; or r0, r0, r1
        ; const r1, 110
        ld r4, 110
        ; shiftright r1, r1, r0
        ; const r3, 1
        ld r12, 1
        ; and r1, r1, r3
        ; cast r3(i16), r2(u8)
        ; cast r3(u8*), r3(i16)
        ; addrof r2, [board]
        ; add r2, r2, r3
        ; store [r2], r1
        ; const r1, 1
        ld r4, 1
        ; move r2, j
        ; add r1, r2, r1
        ; move pattern, r0
        ; move j, r1
        ; jump @for_7
        jmp @for_7
@for_7_break:
        ; call _, printBoard []
        ; const r0, 1
        ld r0, 1
        ; move r1, i
        ; add r0, r1, r0
        ; move i, r0
        ; jump @for_6
        jmp @for_6
@main_ret:
        ; release space for local variables
        add rsp, 4
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

        ; variable 0: board[] (u8*/240)
var_0:
        .repeat 240
        .data 0
        .end

string_0:
        '|', 0x0a, 0x00

