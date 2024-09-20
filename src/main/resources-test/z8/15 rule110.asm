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
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        ; 4:3 if chr == 0
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; copy chr(1@function,u8), r.0(0@register,u8)
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_2_end
        jz @if_2_end
        ; @if_2_then
@if_2_then:
        ; jump @while_1_break
        jmp @while_1_break
@if_2_end:
        ; call _, printChar [chr(1@function,u8)]
        ; jump @while_1
        jmp @while_1
@while_1_break:
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
        ; const r.0(0@register,u8), 124
        ld r0, 124
        ; call _, printChar [r.0(0@register,u8)]
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; 11:2 for i < 30
        ; copy i(0@function,u8), r.0(0@register,u8)
@for_3:
        ; const r.0(0@register,u8), 30
        ld r0, 30
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @for_3_break
        jz @for_3_break
        ; @for_3_body
@for_3_body:
        ; 12:3 if [...] == 0
        ; copy r.0(0@register,u8), i(0@function,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; array r.0(0@register,u8*), board(0@global,u8*) + r.0(0@register,i16)
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_4_else
        jz @if_4_else
        ; @if_4_then
@if_4_then:
        ; const r.0(0@register,u8), 32
        ld r0, 32
        ; call _, printChar [r.0(0@register,u8)]
        ; jump @if_4_end
        jmp @if_4_end
@if_4_else:
        ; const r.0(0@register,u8), 42
        ld r0, 42
        ; call _, printChar [r.0(0@register,u8)]
@if_4_end:
@for_3_continue:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy i(0@function,u8), r.0(0@register,u8)
        ; jump @for_3
        jmp @for_3
@for_3_break:
        ; const r.0(0@register,u8*), [string-0]
        ; call _, printString [r.0(0@register,u8*)]
@printBoard_ret:
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
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; 23:2 for i < 30
        ; copy i(0@function,u8), r.0(0@register,u8)
@for_5:
        ; const r.0(0@register,u8), 30
        ld r0, 30
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @for_5_break
        jz @for_5_break
        ; @for_5_body
@for_5_body:
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; cast r.1(1@register,i16), r.1(1@register,u8)
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i16)
        ; store [r.1(1@register,u8*)], r.0(0@register,u8)
@for_5_continue:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy i(0@function,u8), r.0(0@register,u8)
        ; jump @for_5
        jmp @for_5
@for_5_break:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; const r.1(1@register,u8), 29
        ld r4, 29
        ; cast r.1(1@register,i16), r.1(1@register,u8)
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i16)
        ; store [r.1(1@register,u8*)], r.0(0@register,u8)
        ; call _, printBoard []
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; 30:2 for i < 28
        ; copy i(1@function,u8), r.0(0@register,u8)
@for_6:
        ; const r.0(0@register,u8), 28
        ld r0, 28
        ; copy r.1(1@register,u8), i(1@function,u8)
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @for_6_break
        jz @for_6_break
        ; @for_6_body
@for_6_body:
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; array r.0(0@register,u8*), board(0@global,u8*) + r.0(0@register,i16)
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        ; const r.1(1@register,u8), 1
        ld r4, 1
        ; shiftleft r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; const r.1(1@register,i16), 1
        ld r5, 1
        ld r4, 0
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i16)
        ; load r.1(1@register,u8), [r.1(1@register,u8*)]
        ; or r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; const r.1(1@register,u8), 1
        ld r4, 1
        ; 32:3 for j < 29
        ; copy pattern(2@function,u8), r.0(0@register,u8)
        ; copy j(3@function,u8), r.1(1@register,u8)
@for_7:
        ; const r.0(0@register,u8), 29
        ld r0, 29
        ; copy r.1(1@register,u8), j(3@function,u8)
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @for_7_break
        jz @for_7_break
        ; @for_7_body
@for_7_body:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), pattern(2@function,u8)
        ; shiftleft r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 7
        ld r4, 7
        ; and r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; const r.1(1@register,u8), 1
        ld r4, 1
        ; copy r.2(2@register,u8), j(3@function,u8)
        ; add r.1(1@register,u8), r.2(2@register,u8), r.1(1@register,u8)
        ; cast r.1(1@register,i16), r.1(1@register,u8)
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i16)
        ; load r.1(1@register,u8), [r.1(1@register,u8*)]
        ; or r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; const r.1(1@register,u8), 110
        ld r4, 110
        ; copy pattern(2@function,u8), r.0(0@register,u8)
        ; shiftright r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 1
        ld r4, 1
        ; and r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.1(1@register,i16), r.2(2@register,u8)
        ; array r.1(1@register,u8*), board(0@global,u8*) + r.1(1@register,i16)
        ; store [r.1(1@register,u8*)], r.0(0@register,u8)
@for_7_continue:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), j(3@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy j(3@function,u8), r.0(0@register,u8)
        ; jump @for_7
        jmp @for_7
@for_7_break:
        ; call _, printBoard []
@for_6_continue:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), i(1@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy i(1@function,u8), r.0(0@register,u8)
        ; jump @for_6
        jmp @for_6
@for_6_break:
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

