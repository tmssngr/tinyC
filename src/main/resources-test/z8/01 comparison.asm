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
        ; load r.1(1@register,u8), [r.0(0@register,u8*)]
        ; 4:3 if chr == 0
        ; const r.2(2@register,u8), 0
        ld r8, 0
        ; equals r.2(2@register,bool), r.1(1@register,u8), r.2(2@register,u8)
        ; copy chr(1@function,u8), r.1(1@register,u8)
        ; branch r.2(2@register,bool), false, @if_2_end
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
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; copy r.1(1@register,u8), length(1@argument,u8)
        ; gt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @printStringLength_ret
        jz @printStringLength_ret
        ; 
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        ; load r.1(1@register,u8), [r.0(0@register,u8*)]
        ; call _, printChar [r.1(1@register,u8)]
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), length(1@argument,u8)
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy length(1@argument,u8), r.0(0@register,u8)
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
        ; const r.0(0@register,u8), 20
        ld r0, 20
        ; 24:2 while true
        ; copy pos(2@function,u8), r.0(0@register,u8)
@while_4:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), pos(2@function,u8)
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,i16), 10
        ld r5, 10
        ld r4, 0
        ; copy r.2(2@register,i16), number(0@argument,i16)
        ; mod r.1(1@register,i16), r.2(2@register,i16), r.1(1@register,i16)
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        ; const r.3(3@register,i16), 10
        ld r13, 10
        ld r12, 0
        ; div r.2(2@register,i16), r.2(2@register,i16), r.3(3@register,i16)
        ; cast r.1(1@register,u8), r.1(1@register,i64)
        ; const r.3(3@register,u8), 48
        ld r12, 48
        ; add r.1(1@register,u8), r.1(1@register,u8), r.3(3@register,u8)
        ; cast r.3(3@register,i16), r.0(0@register,u8)
        ; array r.3(3@register,u8*), buffer(1@function,u8*) + r.3(3@register,i16)
        ; store [r.3(3@register,u8*)], r.1(1@register,u8)
        ; 30:3 if number == 0
        ; const r.1(1@register,i16), 0
        ld r5, 0
        ld r4, 0
        ; equals r.1(1@register,bool), r.2(2@register,i16), r.1(1@register,i16)
        ; copy pos(2@function,u8), r.0(0@register,u8)
        ; copy number(0@argument,i16), r.2(2@register,i16)
        ; branch r.1(1@register,bool), false, @while_4
        jz @while_4
        ; 
        ; copy r.0(0@register,u8), pos(2@function,u8)
        ; cast r.1(1@register,i16), r.0(0@register,u8)
        ; addrof r.1(1@register,u8*), [buffer(1@function,u8*) + r.1(1@register,i16)]
        ; const r.2(2@register,u8), 20
        ld r8, 20
        ; sub r.0(0@register,u8), r.2(2@register,u8), r.0(0@register,u8)
        ; call _, printStringLength [r.1(1@register,u8*), r.0(0@register,u8)]
        ; release space for local variables
        add rsp, 21
        ret

        ; void printIntLf
        ;   rsp+2: arg number
@printIntLf:
        ; 38:2 if number < 0
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), number(0@argument,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_6_end
        jz @if_6_end
        ; 
        ; const r.0(0@register,u8), 45
        ld r0, 45
        ; call _, printChar [r.0(0@register,u8)]
        ; copy r.0(0@register,i16), number(0@argument,i16)
        ; neg r.0(0@register,i16), r.0(0@register,i16)
        ; copy number(0@argument,i16), r.0(0@register,i16)
@if_6_end:
        ; call _, printUint [number(0@argument,i16)]
        ; const r.0(0@register,u8), 10
        ld r0, 10
        ; call _, printChar [r.0(0@register,u8)]
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
        ; const r.0(0@register,u8*), [string-0]
        ; call _, printString [r.0(0@register,u8*)]
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; const r.1(1@register,i16), 2
        ld r5, 2
        ld r4, 0
        ; lt r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; copy a(0@function,i16), r.0(0@register,i16)
        ; copy b(1@function,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; lt r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-1]
        ; call _, printString [r.0(0@register,u8*)]
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; const r.1(1@register,u8), 128
        ld r4, 128
        ; lt r.2(2@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; copy c(2@function,u8), r.0(0@register,u8)
        ; copy d(3@function,u8), r.1(1@register,u8)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,u8), d(3@function,u8)
        ; copy r.1(1@register,u8), c(2@function,u8)
        ; lt r.2(2@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-2]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), b(1@function,i16)
        ; lteq r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; lteq r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-3]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,u8), c(2@function,u8)
        ; copy r.1(1@register,u8), d(3@function,u8)
        ; lteq r.2(2@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,u8), d(3@function,u8)
        ; copy r.1(1@register,u8), c(2@function,u8)
        ; lteq r.2(2@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-4]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), b(1@function,i16)
        ; equals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; equals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-5]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), b(1@function,i16)
        ; notequals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; notequals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-6]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), b(1@function,i16)
        ; gteq r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; gteq r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-7]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,u8), c(2@function,u8)
        ; copy r.1(1@register,u8), d(3@function,u8)
        ; gteq r.2(2@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,u8), d(3@function,u8)
        ; copy r.1(1@register,u8), c(2@function,u8)
        ; gteq r.2(2@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; const r.0(0@register,u8*), [string-8]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), b(1@function,i16)
        ; gt r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; gt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,u8*), [string-9]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,u8), c(2@function,u8)
        ; copy r.1(1@register,u8), d(3@function,u8)
        ; gt r.2(2@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.2(2@register,i16), r.2(2@register,bool)
        ; call _, printIntLf [r.2(2@register,i16)]
        ; copy r.0(0@register,u8), d(3@function,u8)
        ; copy r.1(1@register,u8), c(2@function,u8)
        ; gt r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
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

