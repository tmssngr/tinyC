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

        ; void printStringLength
        ;   rsp+1: arg str
        ;   rsp+8: arg length
@printStringLength:
@while_3:
        ; const r0(u8 t.4), 0
        ld r0, 0
        ; copy r1(u8 length), length(1@argument,u8)
        ; gt r0(bool t.3), r1(u8 length), r0(u8 t.4)
        ; branch r0(bool t.3), false, @printStringLength_ret
        jz @printStringLength_ret
        ; 
        ; copy r0(u8* str), str(0@argument,u8*)
        ; load r1(u8 chr), [r0(u8* str)]
        ; call _, printChar [r1(u8 chr)]
        ; const r0(u8 t.5), 1
        ld r0, 1
        ; copy r1(u8 length), length(1@argument,u8)
        ; sub r0(u8 length), r1(u8 length), r0(u8 t.5)
        ; copy length(1@argument,u8), r0(u8 length)
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
        ; const r0(u8 pos), 20
        ld r0, 20
        ; 24:2 while true
        ; copy pos(2@function,u8), r0(u8 pos)
@while_4:
        ; const r0(u8 t.5), 1
        ld r0, 1
        ; copy r1(u8 pos), pos(2@function,u8)
        ; sub r0(u8 pos), r1(u8 pos), r0(u8 t.5)
        ; const r1(i16 t.7), 10
        ld r5, 10
        ld r4, 0
        ; copy r2(i16 number), number(0@argument,i16)
        ; mod r1(i16 t.6), r2(i16 number), r1(i16 t.7)
        ; cast r1(i64 remainder), r1(i16 t.6)
        ; const r3(i16 t.8), 10
        ld r13, 10
        ld r12, 0
        ; div r2(i16 number), r2(i16 number), r3(i16 t.8)
        ; cast r1(u8 t.9), r1(i64 remainder)
        ; const r3(u8 t.10), 48
        ld r12, 48
        ; add r1(u8 digit), r1(u8 t.9), r3(u8 t.10)
        ; cast r3(i16 t.12), r0(u8 pos)
        ; cast r3(u8* t.13), r3(i16 t.12)
        ; Spill pos
        ; copy pos(2@function,u8), r0(u8 pos)
        ; addrof r0(u8* t.11), [buffer(1@function,u8*)]
        ; add r0(u8* t.11), r0(u8* t.11), r3(u8* t.13)
        ; store [r0(u8* t.11)], r1(u8 digit)
        ; 30:3 if number == 0
        ; const r0(i16 t.15), 0
        ld r1, 0
        ld r0, 0
        ; equals r0(bool t.14), r2(i16 number), r0(i16 t.15)
        ; copy number(0@argument,i16), r2(i16 number)
        ; branch r0(bool t.14), false, @while_4
        jz @while_4
        ; 
        ; copy r0(u8 pos), pos(2@function,u8)
        ; cast r1(i16 t.17), r0(u8 pos)
        ; cast r1(u8* t.18), r1(i16 t.17)
        ; addrof r2(u8* t.16), [buffer(1@function,u8*)]
        ; add r1(u8* t.16), r2(u8* t.16), r1(u8* t.18)
        ; const r2(u8 t.20), 20
        ld r8, 20
        ; sub r0(u8 t.19), r2(u8 t.20), r0(u8 pos)
        ; call _, printStringLength [r1(u8* t.16), r0(u8 t.19)]
        ; release space for local variables
        add rsp, 21
        ret

        ; void printIntLf
        ;   rsp+2: arg number
@printIntLf:
        ; 38:2 if number < 0
        ; const r0(i16 t.2), 0
        ld r1, 0
        ld r0, 0
        ; copy r1(i16 number), number(0@argument,i16)
        ; lt r0(bool t.1), r1(i16 number), r0(i16 t.2)
        ; branch r0(bool t.1), false, @if_6_end
        jz @if_6_end
        ; 
        ; const r0(u8 t.3), 45
        ld r0, 45
        ; call _, printChar [r0(u8 t.3)]
        ; copy r0(i16 number), number(0@argument,i16)
        ; neg r0(i16 number), r0(i16 number)
        ; copy number(0@argument,i16), r0(i16 number)
@if_6_end:
        ; call _, printUint [number(0@argument,i16)]
        ; const r0(u8 t.4), 10
        ld r0, 10
        ; call _, printChar [r0(u8 t.4)]
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
@main:
        ; begin initialize global variables
        ; const r0(u8* text), [string-0]
        ; end initialize global variables
        ; copy text(0@global,u8*), r0(u8* text)
        ; call _, printString [r0(u8* text)]
        ; call _, printLength []
        ; const r0(i16 t.2), 1
        ld r1, 1
        ld r0, 0
        ; cast r0(u8* t.3), r0(i16 t.2)
        ; copy r1(u8* text), text(0@global,u8*)
        ; addrof r2(u8* second), [r1(u8* text)]
        ; add r0(u8* second), r2(u8* second), r0(u8* t.3)
        ; call _, printString [r0(u8* second)]
        ; copy r0(u8* text), text(0@global,u8*)
        ; load r0(u8 chr), [r0(u8* text)]
        ; cast r0(i16 t.4), r0(u8 chr)
        ; call _, printIntLf [r0(i16 t.4)]
        ret

        ; void printLength
        ;   rsp+0: var length
        ;   rsp+2: var ptr
@printLength:
        ; reserve space for local variables
        sub rsp, 10
        ; const r0(i16 length), 0
        ld r1, 0
        ld r0, 0
        ; copy r1(u8* text), text(0@global,u8*)
        ; copy r1(u8* ptr), r1(u8* text)
        ; 16:2 for *ptr != 0
        ; copy length(0@function,i16), r0(i16 length)
        ; copy ptr(1@function,u8*), r1(u8* ptr)
@for_7:
        ; copy r0(u8* ptr), ptr(1@function,u8*)
        ; load r1(u8 t.3), [r0(u8* ptr)]
        ; const r2(u8 t.4), 0
        ld r8, 0
        ; notequals r1(bool t.2), r1(u8 t.3), r2(u8 t.4)
        ; branch r1(bool t.2), false, @for_7_break
        jz @for_7_break
        ; @for_7_body
        ; const r0(i16 t.5), 1
        ld r1, 1
        ld r0, 0
        ; copy r1(i16 length), length(0@function,i16)
        ; add r0(i16 length), r1(i16 length), r0(i16 t.5)
        ; copy length(0@function,i16), r0(i16 length)
        ; copy r0(u8* ptr), ptr(1@function,u8*)
        ; cast r0(i16 t.7), r0(u8* ptr)
        ; const r1(i16 t.8), 1
        ld r5, 1
        ld r4, 0
        ; add r0(i16 t.6), r0(i16 t.7), r1(i16 t.8)
        ; cast r0(u8* ptr), r0(i16 t.6)
        ; copy ptr(1@function,u8*), r0(u8* ptr)
        ; jump @for_7
        jmp @for_7
@for_7_break:
        ; call _, printIntLf [length(0@function,i16)]
        ; release space for local variables
        add rsp, 10
        ret

        ; variable 0: text (8)
var_0:
        .repeat 8
        .data 0
        .end

string_0:
        'hello world', 0x0a, 0x00

