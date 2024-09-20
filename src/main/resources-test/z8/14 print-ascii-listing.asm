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

        ; void printNibble
        ;   rsp+1: arg x
@printNibble:
        ; const r.0(0@register,u8), 15
        ld r0, 15
        ; copy r.1(1@register,u8), x(0@argument,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; 5:2 if x > 9
        ; const r.1(1@register,u8), 9
        ld r4, 9
        ; copy x(0@argument,u8), r.0(0@register,u8)
        ; gt r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_3_end
        jz @if_3_end
        ; @if_3_then
@if_3_then:
        ; const r.0(0@register,u8), 7
        ld r0, 7
        ; copy r.1(1@register,u8), x(0@argument,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy x(0@argument,u8), r.0(0@register,u8)
@if_3_end:
        ; const r.0(0@register,u8), 48
        ld r0, 48
        ; copy r.1(1@register,u8), x(0@argument,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; call _, printChar [r.0(0@register,u8)]
@printNibble_ret:
        ret

        ; void printHex2
        ;   rsp+1: arg x
@printHex2:
        ; const r.0(0@register,u8), 4
        ld r0, 4
        ; copy r.1(1@register,u8), x(0@argument,u8)
        ; shiftright r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; call _, printNibble [r.0(0@register,u8)]
        ; call _, printNibble [x(0@argument,u8)]
@printHex2_ret:
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
@main:
        ; reserve space for local variables
        sub rsp, 2
        ; begin initialize global variables
        ; end initialize global variables
        ; const r.0(0@register,u8*), [string-0]
        ; call _, printString [r.0(0@register,u8*)]
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; 19:2 for i < 16
        ; copy i(0@function,u8), r.0(0@register,u8)
@for_4:
        ; const r.0(0@register,u8), 16
        ld r0, 16
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @for_4_break
        jz @for_4_break
        ; @for_4_body
@for_4_body:
        ; 20:3 if i & 7 == 0
        ; const r.0(0@register,u8), 7
        ld r0, 7
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_5_end
        jz @if_5_end
        ; @if_5_then
@if_5_then:
        ; const r.0(0@register,u8), 32
        ld r0, 32
        ; call _, printChar [r.0(0@register,u8)]
@if_5_end:
        ; call _, printNibble [i(0@function,u8)]
@for_4_continue:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), i(0@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy i(0@function,u8), r.0(0@register,u8)
        ; jump @for_4
        jmp @for_4
@for_4_break:
        ; const r.0(0@register,u8), 10
        ld r0, 10
        ; call _, printChar [r.0(0@register,u8)]
        ; const r.0(0@register,u8), 32
        ld r0, 32
        ; 27:2 for i < 128
        ; copy i(1@function,u8), r.0(0@register,u8)
@for_6:
        ; const r.0(0@register,u8), 128
        ld r0, 128
        ; copy r.1(1@register,u8), i(1@function,u8)
        ; lt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @for_6_break
        jz @for_6_break
        ; @for_6_body
@for_6_body:
        ; 28:3 if i & 15 == 0
        ; const r.0(0@register,u8), 15
        ld r0, 15
        ; copy r.1(1@register,u8), i(1@function,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_7_end
        jz @if_7_end
        ; @if_7_then
@if_7_then:
        ; call _, printHex2 [i(1@function,u8)]
@if_7_end:
        ; 31:3 if i & 7 == 0
        ; const r.0(0@register,u8), 7
        ld r0, 7
        ; copy r.1(1@register,u8), i(1@function,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_8_end
        jz @if_8_end
        ; @if_8_then
@if_8_then:
        ; const r.0(0@register,u8), 32
        ld r0, 32
        ; call _, printChar [r.0(0@register,u8)]
@if_8_end:
        ; call _, printChar [i(1@function,u8)]
        ; 35:3 if i & 15 == 15
        ; const r.0(0@register,u8), 15
        ld r0, 15
        ; copy r.1(1@register,u8), i(1@function,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 15
        ld r4, 15
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_9_end
        jz @if_9_end
        ; @if_9_then
@if_9_then:
        ; const r.0(0@register,u8), 10
        ld r0, 10
        ; call _, printChar [r.0(0@register,u8)]
@if_9_end:
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
        add rsp, 2
        ret


string_0:
        ' x', 0x00

