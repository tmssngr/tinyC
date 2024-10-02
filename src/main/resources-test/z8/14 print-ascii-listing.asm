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

        ; void printNibble
        ;   rsp+1: arg x
@printNibble:
        ; const r0(u8 t.1), 15
        ld r0, 15
        ; copy r1(u8 x), x(0@argument,u8)
        ; and r0(u8 x), r1(u8 x), r0(u8 t.1)
        ; 5:2 if x > 9
        ; const r1(u8 t.3), 9
        ld r4, 9
        ; gt r1(bool t.2), r0(u8 x), r1(u8 t.3)
        ; copy x(0@argument,u8), r0(u8 x)
        ; branch r1(bool t.2), false, @if_3_end
        jz @if_3_end
        ; 
        ; const r0(u8 t.4), 7
        ld r0, 7
        ; copy r1(u8 x), x(0@argument,u8)
        ; add r0(u8 x), r1(u8 x), r0(u8 t.4)
        ; copy x(0@argument,u8), r0(u8 x)
@if_3_end:
        ; const r0(u8 t.5), 48
        ld r0, 48
        ; copy r1(u8 x), x(0@argument,u8)
        ; add r0(u8 x), r1(u8 x), r0(u8 t.5)
        ; call _, printChar [r0(u8 x)]
        ret

        ; void printHex2
        ;   rsp+1: arg x
@printHex2:
        ; const r0(u8 t.2), 4
        ld r0, 4
        ; copy r1(u8 x), x(0@argument,u8)
        ; shiftright r0(u8 t.1), r1(u8 x), r0(u8 t.2)
        ; call _, printNibble [r0(u8 t.1)]
        ; call _, printNibble [x(0@argument,u8)]
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
@main:
        ; reserve space for local variables
        sub rsp, 2
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0(u8* t.2), [string-0]
        ; call _, printString [r0(u8* t.2)]
        ; const r0(u8 i), 0
        ld r0, 0
        ; 19:2 for i < 16
        ; copy i(0@function,u8), r0(u8 i)
@for_4:
        ; const r0(u8 t.4), 16
        ld r0, 16
        ; copy r1(u8 i), i(0@function,u8)
        ; lt r0(bool t.3), r1(u8 i), r0(u8 t.4)
        ; branch r0(bool t.3), false, @for_4_break
        jz @for_4_break
        ; @for_4_body
        ; 20:3 if i & 7 == 0
        ; const r0(u8 t.7), 7
        ld r0, 7
        ; copy r1(u8 i), i(0@function,u8)
        ; and r0(u8 t.6), r1(u8 i), r0(u8 t.7)
        ; const r2(u8 t.8), 0
        ld r8, 0
        ; equals r0(bool t.5), r0(u8 t.6), r2(u8 t.8)
        ; branch r0(bool t.5), false, @if_5_end
        jz @if_5_end
        ; 
        ; const r0(u8 t.9), 32
        ld r0, 32
        ; call _, printChar [r0(u8 t.9)]
@if_5_end:
        ; call _, printNibble [i(0@function,u8)]
        ; const r0(u8 t.10), 1
        ld r0, 1
        ; copy r1(u8 i), i(0@function,u8)
        ; add r0(u8 i), r1(u8 i), r0(u8 t.10)
        ; copy i(0@function,u8), r0(u8 i)
        ; jump @for_4
        jmp @for_4
@for_4_break:
        ; const r0(u8 t.11), 10
        ld r0, 10
        ; call _, printChar [r0(u8 t.11)]
        ; const r0(u8 i), 32
        ld r0, 32
        ; 27:2 for i < 128
        ; copy i(1@function,u8), r0(u8 i)
@for_6:
        ; const r0(u8 t.13), 128
        ld r0, 128
        ; copy r1(u8 i), i(1@function,u8)
        ; lt r0(bool t.12), r1(u8 i), r0(u8 t.13)
        ; branch r0(bool t.12), false, @main_ret
        jz @main_ret
        ; 
        ; 28:3 if i & 15 == 0
        ; const r0(u8 t.16), 15
        ld r0, 15
        ; copy r1(u8 i), i(1@function,u8)
        ; and r0(u8 t.15), r1(u8 i), r0(u8 t.16)
        ; const r2(u8 t.17), 0
        ld r8, 0
        ; equals r0(bool t.14), r0(u8 t.15), r2(u8 t.17)
        ; branch r0(bool t.14), false, @if_7_end
        jz @if_7_end
        ; 
        ; call _, printHex2 [i(1@function,u8)]
@if_7_end:
        ; 31:3 if i & 7 == 0
        ; const r0(u8 t.20), 7
        ld r0, 7
        ; copy r1(u8 i), i(1@function,u8)
        ; and r0(u8 t.19), r1(u8 i), r0(u8 t.20)
        ; const r2(u8 t.21), 0
        ld r8, 0
        ; equals r0(bool t.18), r0(u8 t.19), r2(u8 t.21)
        ; branch r0(bool t.18), false, @if_8_end
        jz @if_8_end
        ; 
        ; const r0(u8 t.22), 32
        ld r0, 32
        ; call _, printChar [r0(u8 t.22)]
@if_8_end:
        ; call _, printChar [i(1@function,u8)]
        ; 35:3 if i & 15 == 15
        ; const r0(u8 t.25), 15
        ld r0, 15
        ; copy r1(u8 i), i(1@function,u8)
        ; and r0(u8 t.24), r1(u8 i), r0(u8 t.25)
        ; const r2(u8 t.26), 15
        ld r8, 15
        ; equals r0(bool t.23), r0(u8 t.24), r2(u8 t.26)
        ; branch r0(bool t.23), false, @for_6_continue
        jz @for_6_continue
        ; 
        ; const r0(u8 t.27), 10
        ld r0, 10
        ; call _, printChar [r0(u8 t.27)]
@for_6_continue:
        ; const r0(u8 t.28), 1
        ld r0, 1
        ; copy r1(u8 i), i(1@function,u8)
        ; add r0(u8 i), r1(u8 i), r0(u8 t.28)
        ; copy i(1@function,u8), r0(u8 i)
        ; jump @for_6
        jmp @for_6
@main_ret:
        ; release space for local variables
        add rsp, 2
        ret


string_0:
        ' x', 0x00

