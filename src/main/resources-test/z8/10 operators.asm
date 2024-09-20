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

        ; void printStringLength
        ;   rsp+1: arg str
        ;   rsp+8: arg length
@printStringLength:
@while_3:
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; copy r.1(1@register,u8), length(1@argument,u8)
        ; gt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @while_3_break
        jz @while_3_break
        ; @while_3_body
@while_3_body:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        ; call _, printChar [r.0(0@register,u8)]
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), length(1@argument,u8)
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy length(1@argument,u8), r.0(0@register,u8)
        ; jump @while_3
        jmp @while_3
@while_3_break:
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
        ; copy pos(2@function,u8), r.0(0@register,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; array r.0(0@register,u8*), buffer(1@function,u8*) + r.0(0@register,i16)
        ; store [r.0(0@register,u8*)], r.1(1@register,u8)
        ; 30:3 if number == 0
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy number(0@argument,i16), r.2(2@register,i16)
        ; equals r.0(0@register,bool), r.2(2@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_5_end
        jz @if_5_end
        ; @if_5_then
@if_5_then:
        ; jump @while_4_break
        jmp @while_4_break
@if_5_end:
        ; jump @while_4
        jmp @while_4
@while_4_break:
        ; copy r.0(0@register,u8), pos(2@function,u8)
        ; cast r.1(1@register,i16), r.0(0@register,u8)
        ; addrof r.1(1@register,u8*), [buffer(1@function,u8*) + r.1(1@register,i16)]
        ; const r.2(2@register,u8), 20
        ld r8, 20
        ; sub r.0(0@register,u8), r.2(2@register,u8), r.0(0@register,u8)
        ; call _, printStringLength [r.1(1@register,u8*), r.0(0@register,u8)]
@printUint_ret:
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
        ; @if_6_then
@if_6_then:
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
@printIntLf_ret:
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
        ; const r.0(0@register,u8*), [string-0]
        ; call _, printString [r.0(0@register,u8*)]
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; const r.1(1@register,i16), 1
        ld r5, 1
        ld r4, 0
        ; const r.2(2@register,i16), 2
        ld r9, 2
        ld r8, 0
        ; const r.3(3@register,i16), 3
        ld r13, 3
        ld r12, 0
        ; Spill a
        ; copy a(0@function,i16), r.0(0@register,i16)
        ; const r.0(0@register,bool), 1
        ld r0, 1
        ; Spill t
        ; copy t(4@function,bool), r.0(0@register,bool)
        ; const r.0(0@register,bool), 0
        ld r0, 0
        ; Spill f
        ; copy f(5@function,bool), r.0(0@register,bool)
        ; Spill b
        ; copy b(1@function,i16), r.1(1@register,i16)
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; and r.0(0@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        ; copy c(2@function,i16), r.2(2@register,i16)
        ; copy d(3@function,i16), r.3(3@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), b(1@function,i16)
        ; and r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; and r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; and r.0(0@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,u8*), [string-1]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; or r.0(0@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), b(1@function,i16)
        ; or r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; or r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; or r.0(0@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,u8*), [string-2]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; xor r.0(0@register,i16), r.0(0@register,i16), r.0(0@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), a(0@function,i16)
        ; copy r.1(1@register,i16), c(2@function,i16)
        ; xor r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), a(0@function,i16)
        ; xor r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), c(2@function,i16)
        ; xor r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,u8*), [string-3]
        ; call _, printString [r.0(0@register,u8*)]
        ; 26:15 logic and
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.26(7@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @and_next_7
        jz @and_next_7
        ; @and_2nd_7
@and_2nd_7:
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.26(7@function,bool), r.0(0@register,bool)
@and_next_7:
        ; copy r.0(0@register,bool), t.26(7@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 27:15 logic and
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.28(8@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @and_next_8
        jz @and_next_8
        ; @and_2nd_8
@and_2nd_8:
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.28(8@function,bool), r.0(0@register,bool)
@and_next_8:
        ; copy r.0(0@register,bool), t.28(8@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 28:15 logic and
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.30(9@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @and_next_9
        jz @and_next_9
        ; @and_2nd_9
@and_2nd_9:
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.30(9@function,bool), r.0(0@register,bool)
@and_next_9:
        ; copy r.0(0@register,bool), t.30(9@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 29:15 logic and
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.32(10@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @and_next_10
        jz @and_next_10
        ; @and_2nd_10
@and_2nd_10:
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.32(10@function,bool), r.0(0@register,bool)
@and_next_10:
        ; copy r.0(0@register,bool), t.32(10@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,u8*), [string-4]
        ; call _, printString [r.0(0@register,u8*)]
        ; 31:15 logic or
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.35(11@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), true, @or_next_11
        jnz @or_next_11
        ; @or_2nd_11
@or_2nd_11:
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.35(11@function,bool), r.0(0@register,bool)
@or_next_11:
        ; copy r.0(0@register,bool), t.35(11@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 32:15 logic or
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.37(12@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), true, @or_next_12
        jnz @or_next_12
        ; @or_2nd_12
@or_2nd_12:
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.37(12@function,bool), r.0(0@register,bool)
@or_next_12:
        ; copy r.0(0@register,bool), t.37(12@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 33:15 logic or
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.39(13@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), true, @or_next_13
        jnz @or_next_13
        ; @or_2nd_13
@or_2nd_13:
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; copy t.39(13@function,bool), r.0(0@register,bool)
@or_next_13:
        ; copy r.0(0@register,bool), t.39(13@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 34:15 logic or
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.41(14@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), true, @or_next_14
        jnz @or_next_14
        ; @or_2nd_14
@or_2nd_14:
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; copy t.41(14@function,bool), r.0(0@register,bool)
@or_next_14:
        ; copy r.0(0@register,bool), t.41(14@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,u8*), [string-5]
        ; call _, printString [r.0(0@register,u8*)]
        ; copy r.0(0@register,bool), f(5@function,bool)
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,bool), t(4@function,bool)
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,u8*), [string-6]
        ; call _, printString [r.0(0@register,u8*)]
        ; const r.0(0@register,u8), 10
        ld r0, 10
        ; const r.1(1@register,u8), 6
        ld r4, 6
        ; const r.2(2@register,u8), 1
        ld r8, 1
        ; and r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; copy b1(6@function,u8), r.2(2@register,u8)
        ; or r.0(0@register,u8), r.0(0@register,u8), r.2(2@register,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 43:20 logic or
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), c(2@function,i16)
        ; equals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; copy t.52(15@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), true, @or_next_15
        jnz @or_next_15
        ; @or_2nd_15
@or_2nd_15:
        ; copy r.0(0@register,i16), c(2@function,i16)
        ; copy r.1(1@register,i16), d(3@function,i16)
        ; lt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; copy t.52(15@function,bool), r.0(0@register,bool)
@or_next_15:
        ; copy r.0(0@register,bool), t.52(15@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; 44:20 logic and
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; copy r.1(1@register,i16), c(2@function,i16)
        ; equals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; copy t.54(16@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @and_next_16
        jz @and_next_16
        ; @and_2nd_16
@and_2nd_16:
        ; copy r.0(0@register,i16), c(2@function,i16)
        ; copy r.1(1@register,i16), d(3@function,i16)
        ; lt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; copy t.54(16@function,bool), r.0(0@register,bool)
@and_next_16:
        ; copy r.0(0@register,bool), t.54(16@function,bool)
        ; cast r.0(0@register,i16), r.0(0@register,bool)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; const r.0(0@register,i16), -1
        ld r1, 255
        ld r0, 255
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,i16), b(1@function,i16)
        ; neg r.0(0@register,i16), r.0(0@register,i16)
        ; call _, printIntLf [r.0(0@register,i16)]
        ; copy r.0(0@register,u8), b1(6@function,u8)
        ; not r.0(0@register,u8), r.0(0@register,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printIntLf [r.0(0@register,i16)]
@main_ret:
        ; release space for local variables
        add rsp, 21
        ret


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

