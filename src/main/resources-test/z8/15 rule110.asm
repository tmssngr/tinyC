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

        ; void printChar
@printChar:
        ld   r0, SPH
        ld   r1, SPL
        add  r1, 3
        adc  r0, 0
        ldc  r1, @rr0
        ld   %15, r1
        jp   %0818

        ; void printBoard
        ;   rsp+0: var i
@printBoard:
        ; reserve space for local variables
        sub rsp, 1
        ; const r0(u8 t.1), 124
        ld r0, 124
        ; call _, printChar [r0(u8 t.1)]
        ; const r0(u8 i), 0
        ld r0, 0
        ; 11:2 for i < 30
        ; copy i(0@function,u8), r0(u8 i)
@for_3:
        ; const r0(u8 t.3), 30
        ld r0, 30
        ; copy r1(u8 i), i(0@function,u8)
        ; lt r0(bool t.2), r1(u8 i), r0(u8 t.3)
        ; branch r0(bool t.2), false, @for_3_break
        jz @for_3_break
        ; @for_3_body
        ; 12:3 if [...] == 0
        ; copy r0(u8 i), i(0@function,u8)
        ; cast r1(i16 t.6), r0(u8 i)
        ; array r1(u8* t.7), board(0@global,u8*) + r1(i16 t.6)
        ; load r1(u8 t.5), [r1(u8* t.7)]
        ; const r2(u8 t.8), 0
        ld r8, 0
        ; equals r1(bool t.4), r1(u8 t.5), r2(u8 t.8)
        ; branch r1(bool t.4), false, @if_4_else
        jz @if_4_else
        ; @if_4_then
        ; const r0(u8 t.9), 32
        ld r0, 32
        ; call _, printChar [r0(u8 t.9)]
        ; jump @for_3_continue
        jmp @for_3_continue
@if_4_else:
        ; const r0(u8 t.10), 42
        ld r0, 42
        ; call _, printChar [r0(u8 t.10)]
@for_3_continue:
        ; const r0(u8 t.11), 1
        ld r0, 1
        ; copy r1(u8 i), i(0@function,u8)
        ; add r0(u8 i), r1(u8 i), r0(u8 t.11)
        ; copy i(0@function,u8), r0(u8 i)
        ; jump @for_3
        jmp @for_3
@for_3_break:
        ; const r0(u8* t.12), [string-0]
        ; call _, printString [r0(u8* t.12)]
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
        ; const r0(u8 i), 0
        ld r0, 0
        ; 23:2 for i < 30
        ; copy i(0@function,u8), r0(u8 i)
@for_5:
        ; const r0(u8 t.5), 30
        ld r0, 30
        ; copy r1(u8 i), i(0@function,u8)
        ; lt r0(bool t.4), r1(u8 i), r0(u8 t.5)
        ; branch r0(bool t.4), false, @for_5_break
        jz @for_5_break
        ; @for_5_body
        ; const r0(u8 t.6), 0
        ld r0, 0
        ; copy r1(u8 i), i(0@function,u8)
        ; cast r2(i16 t.7), r1(u8 i)
        ; array r2(u8* t.8), board(0@global,u8*) + r2(i16 t.7)
        ; store [r2(u8* t.8)], r0(u8 t.6)
        ; const r0(u8 t.9), 1
        ld r0, 1
        ; copy r1(u8 i), i(0@function,u8)
        ; add r0(u8 i), r1(u8 i), r0(u8 t.9)
        ; copy i(0@function,u8), r0(u8 i)
        ; jump @for_5
        jmp @for_5
@for_5_break:
        ; const r0(u8 t.10), 1
        ld r0, 1
        ; const r1(u8 t.12), 29
        ld r4, 29
        ; cast r1(i16 t.11), r1(u8 t.12)
        ; array r1(u8* t.13), board(0@global,u8*) + r1(i16 t.11)
        ; store [r1(u8* t.13)], r0(u8 t.10)
        ; call _, printBoard []
        ; const r0(u8 i), 0
        ld r0, 0
        ; 30:2 for i < 28
        ; copy i(1@function,u8), r0(u8 i)
@for_6:
        ; const r0(u8 t.15), 28
        ld r0, 28
        ; copy r1(u8 i), i(1@function,u8)
        ; lt r0(bool t.14), r1(u8 i), r0(u8 t.15)
        ; branch r0(bool t.14), false, @main_ret
        jz @main_ret
        ; 
        ; const r0(i16 t.18), 0
        ld r1, 0
        ld r0, 0
        ; array r0(u8* t.19), board(0@global,u8*) + r0(i16 t.18)
        ; load r0(u8 t.17), [r0(u8* t.19)]
        ; const r1(u8 t.20), 1
        ld r4, 1
        ; shiftleft r0(u8 t.16), r0(u8 t.17), r1(u8 t.20)
        ; const r1(i16 t.22), 1
        ld r5, 1
        ld r4, 0
        ; array r1(u8* t.23), board(0@global,u8*) + r1(i16 t.22)
        ; load r1(u8 t.21), [r1(u8* t.23)]
        ; or r0(u8 pattern), r0(u8 t.16), r1(u8 t.21)
        ; const r1(u8 j), 1
        ld r4, 1
        ; 32:3 for j < 29
        ; copy pattern(2@function,u8), r0(u8 pattern)
        ; copy j(3@function,u8), r1(u8 j)
@for_7:
        ; const r0(u8 t.25), 29
        ld r0, 29
        ; copy r1(u8 j), j(3@function,u8)
        ; lt r0(bool t.24), r1(u8 j), r0(u8 t.25)
        ; branch r0(bool t.24), false, @for_7_break
        jz @for_7_break
        ; @for_7_body
        ; const r0(u8 t.28), 1
        ld r0, 1
        ; copy r1(u8 pattern), pattern(2@function,u8)
        ; shiftleft r0(u8 t.27), r1(u8 pattern), r0(u8 t.28)
        ; const r1(u8 t.29), 7
        ld r4, 7
        ; and r0(u8 t.26), r0(u8 t.27), r1(u8 t.29)
        ; const r1(u8 t.33), 1
        ld r4, 1
        ; copy r2(u8 j), j(3@function,u8)
        ; add r1(u8 t.32), r2(u8 j), r1(u8 t.33)
        ; cast r1(i16 t.31), r1(u8 t.32)
        ; array r1(u8* t.34), board(0@global,u8*) + r1(i16 t.31)
        ; load r1(u8 t.30), [r1(u8* t.34)]
        ; or r0(u8 pattern), r0(u8 t.26), r1(u8 t.30)
        ; const r1(u8 t.37), 110
        ld r4, 110
        ; shiftright r1(u8 t.36), r1(u8 t.37), r0(u8 pattern)
        ; const r3(u8 t.38), 1
        ld r12, 1
        ; and r1(u8 t.35), r1(u8 t.36), r3(u8 t.38)
        ; cast r3(i16 t.39), r2(u8 j)
        ; array r3(u8* t.40), board(0@global,u8*) + r3(i16 t.39)
        ; store [r3(u8* t.40)], r1(u8 t.35)
        ; copy pattern(2@function,u8), r0(u8 pattern)
        ; const r0(u8 t.41), 1
        ld r0, 1
        ; copy r1(u8 j), j(3@function,u8)
        ; add r0(u8 j), r1(u8 j), r0(u8 t.41)
        ; copy j(3@function,u8), r0(u8 j)
        ; jump @for_7
        jmp @for_7
@for_7_break:
        ; call _, printBoard []
        ; const r0(u8 t.42), 1
        ld r0, 1
        ; copy r1(u8 i), i(1@function,u8)
        ; add r0(u8 i), r1(u8 i), r0(u8 t.42)
        ; copy i(1@function,u8), r0(u8 i)
        ; jump @for_6
        jmp @for_6
@main_ret:
        ; release space for local variables
        add rsp, 4
        ret

        ; variable 0: board (240)
var_0:
        .repeat 240
        .data 0
        .end

string_0:
        '|', 0x0a, 0x00

