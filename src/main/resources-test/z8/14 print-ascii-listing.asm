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

        ; void printNibble
        ;   rsp+3: arg x
@printNibble:
        ; const r0, 15
        ld r0, 15
        ; move r1, x
        ; and r0, r1, r0
        ; 5:2 if x > 9
        ; const r1, 9
        ld r4, 9
        ; gt r1, r0, r1
        ; move x, r0
        ; branch r1, false, @if_3_end
        jz @if_3_end
        ; 
        ; const r0, 7
        ld r0, 7
        ; move r1, x
        ; add r0, r1, r0
        ; move x, r0
@if_3_end:
        ; const r0, 48
        ld r0, 48
        ; move r1, x
        ; add r0, r1, r0
        ; call _, printChar [r0]
        ret

        ; void printHex2
        ;   rsp+3: arg x
@printHex2:
        ; const r0, 4
        ld r0, 4
        ; move r1, x
        ; move r2, r1
        ; shiftright r0, r2, r0
        ; call _, printNibble [r0]
        ; call _, printNibble [x]
        ret

        ; void main
        ;   rsp+0: var i
        ;   rsp+1: var i
@main:
        ; reserve space for local variables
        sub rsp, 2
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, [string-0]
        ; call _, printString [r0]
        ; const r0, 0
        ld r0, 0
        ; 19:2 for i < 16
        ; move i, r0
@for_4:
        ; const r0, 16
        ld r0, 16
        ; move r1, i
        ; lt r0, r1, r0
        ; branch r0, false, @for_4_break
        jz @for_4_break
        ; @for_4_body
        ; 20:3 if i & 7 == 0
        ; const r0, 7
        ld r0, 7
        ; move r1, i
        ; move r2, r1
        ; and r0, r2, r0
        ; const r2, 0
        ld r8, 0
        ; equals r0, r0, r2
        ; branch r0, false, @if_5_end
        jz @if_5_end
        ; 
        ; const r0, 32
        ld r0, 32
        ; call _, printChar [r0]
@if_5_end:
        ; call _, printNibble [i]
        ; const r0, 1
        ld r0, 1
        ; move r1, i
        ; add r0, r1, r0
        ; move i, r0
        ; jump @for_4
        jmp @for_4
@for_4_break:
        ; const r0, 10
        ld r0, 10
        ; call _, printChar [r0]
        ; const r0, 32
        ld r0, 32
        ; 27:2 for i < 128
        ; move i, r0
@for_6:
        ; const r0, 128
        ld r0, 128
        ; move r1, i
        ; lt r0, r1, r0
        ; branch r0, false, @main_ret
        jz @main_ret
        ; 
        ; 28:3 if i & 15 == 0
        ; const r0, 15
        ld r0, 15
        ; move r1, i
        ; move r2, r1
        ; and r0, r2, r0
        ; const r2, 0
        ld r8, 0
        ; equals r0, r0, r2
        ; branch r0, false, @if_7_end
        jz @if_7_end
        ; 
        ; call _, printHex2 [i]
@if_7_end:
        ; 31:3 if i & 7 == 0
        ; const r0, 7
        ld r0, 7
        ; move r1, i
        ; move r2, r1
        ; and r0, r2, r0
        ; const r2, 0
        ld r8, 0
        ; equals r0, r0, r2
        ; branch r0, false, @if_8_end
        jz @if_8_end
        ; 
        ; const r0, 32
        ld r0, 32
        ; call _, printChar [r0]
@if_8_end:
        ; call _, printChar [i]
        ; 35:3 if i & 15 == 15
        ; const r0, 15
        ld r0, 15
        ; move r1, i
        ; move r2, r1
        ; and r0, r2, r0
        ; const r2, 15
        ld r8, 15
        ; equals r0, r0, r2
        ; branch r0, false, @for_6_continue
        jz @for_6_continue
        ; 
        ; const r0, 10
        ld r0, 10
        ; call _, printChar [r0]
@for_6_continue:
        ; const r0, 1
        ld r0, 1
        ; move r1, i
        ; add r0, r1, r0
        ; move i, r0
        ; jump @for_6
        jmp @for_6
@main_ret:
        ; release space for local variables
        add rsp, 2
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


string_0:
        ' x', 0x00

