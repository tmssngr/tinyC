        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void printStringLength
        ;   rsp+1: arg str
        ;   rsp+8: arg length
@printStringLength:
@while_1:
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
        ; jump @while_1
        jmp @while_1
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
@while_2:
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
        ; branch r.1(1@register,bool), false, @while_2
        jz @while_2
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
        ; branch r.0(0@register,bool), false, @if_4_end
        jz @if_4_end
        ; 
        ; const r.0(0@register,u8), 45
        ld r0, 45
        ; call _, printChar [r.0(0@register,u8)]
        ; copy r.0(0@register,i16), number(0@argument,i16)
        ; neg r.0(0@register,i16), r.0(0@register,i16)
        ; copy number(0@argument,i16), r.0(0@register,i16)
@if_4_end:
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
        ;   rsp+0: var t.0
        ;   rsp+1: var t.1
        ;   rsp+2: var t.2
        ;   rsp+3: var t.3
@main:
        ; reserve space for local variables
        sub rsp, 4
        ; begin initialize global variables
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; end initialize global variables
        ; copy i(0@global,u8), r.0(0@register,u8)
        ; call r.0(0@register,u8), next, []
        ; copy t.0(0@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,u8), next, []
        ; copy t.1(1@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,u8), next, []
        ; copy t.2(2@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,u8), next, []
        ; copy t.3(3@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,u8), next, []
        ; call _, doPrint [t.0(0@function,u8), t.1(1@function,u8), t.2(2@function,u8), t.3(3@function,u8), r.0(0@register,u8)]
        ; release space for local variables
        add rsp, 4
        ret

        ; u8 next
@next:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), i(0@global,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; 11:9 return i
        ; copy i(0@global,u8), r.0(0@register,u8)
        ; ret r.0(0@register,u8)
        ret

        ; void doPrint
        ;   rsp+1: arg a
        ;   rsp+1: arg b
        ;   rsp+1: arg c
        ;   rsp+1: arg d
        ;   rsp+1: arg e
@doPrint:
        ; copy r.0(0@register,u8), a(0@argument,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,u8), b(1@argument,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,u8), c(2@argument,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,u8), d(3@argument,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,u8), e(4@argument,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printIntLf [r.0(0@register,i16)]
        ret

        ; variable 0: i (1)
var_0:
        .data 0

