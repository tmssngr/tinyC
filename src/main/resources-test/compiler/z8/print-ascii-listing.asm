        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printNibble@u8
        ; arg x (u8): r0
printNibble_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; const t.1{r8}, 15
        ld   r8, #%0f
        ; and param.x{r0}, param.x{r0}, t.1{r8}
        and  r0, r8
        ; 5:2 if x > 9
        ; const t.3{r8}, 9
        ld   r8, #%09
        ; gt t.2{r8}, param.x{r0}, t.3{r8}
        cp   r0, r8
        jr   ule, .false1
.true1:
        ld   r8, #1
        jr   .1
.false1:
        ld   r8, #0
.1:
        ; branch t.2{r8}, false, @if_1_end, @if_1_then
        or   r8, r8
        jr   z, if__1__end
        ; const t.4{r8}, 7
        ld   r8, #%07
        ; add param.x{r0}, param.x{r0}, t.4{r8}
        add  r0, r8
if__1__end:
        ; const t.5{r8}, 48
        ld   r8, #%30
        ; add param.x{r0}, param.x{r0}, t.5{r8}
        add  r0, r8
        ; call printChar@u8[param.x{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void printHex2@u8
        ; arg x (u8): r0
printHex2_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.x{r8}, x{r0}
        ld   r8, r0
        ; const t.2{r9}, 4
        ld   r9, #%04
        ; move t.1{r0}, param.x{r8}
        ld   r0, r8
        ; shiftright t.1{r0}, t.1{r0}, t.2{r9}
        or   r9, r9
        jr   z, .next2
        push r9
.shift2:
        rcf
        rrc  r0
        djnz r9, .shift2
        pop  r9
.next2:
        ; call printNibble@u8[t.1{r0}]
        call printNibble_Pu8
        ; move param.x{r0}, param.x{r8}
        ld   r0, r8
        ; call printNibble@u8[param.x{r0}]
        call printNibble_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; const t.2{r0}, [string-0]
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.2{r0}]
        call printString_P_Pu8
        ; const i{r8}, 0
        ld   r8, #%00
        ; 19:2 for i < 16
        jr   for__2

for__2__body:
        ; 20:3 if i & 7 == 0
        ; const t.7{r9}, 7
        ld   r9, #%07
        ; move t.6{r10}, i{r8}
        ld   r10, r8
        ; and t.6{r10}, t.6{r10}, t.7{r9}
        and  r10, r9
        ; const t.8{r9}, 0
        ld   r9, #%00
        ; equals t.5{r9}, t.6{r10}, t.8{r9}
        cp   r10, r9
        jr   ne, .ne3
        ld   r9, #1  ; true
        jr   .3
.ne3:
        ld   r9, #0
.3:
        ; branch t.5{r9}, false, @if_3_end, @if_3_then
        or   r9, r9
        jr   z, if__3__end
        ; const t.9{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[t.9{r0}]
        call printChar_Pu8
if__3__end:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printNibble@u8[i{r0}]
        call printNibble_Pu8
        ; const t.10{r9}, 1
        ld   r9, #%01
        ; add i{r8}, i{r8}, t.10{r9}
        add  r8, r9
for__2:
        ; const t.4{r9}, 16
        ld   r9, #%10
        ; lt t.3{r9}, i{r8}, t.4{r9}
        cp   r8, r9
        jr   uge, .false4
.true4:
        ld   r9, #1
        jr   .4
.false4:
        ld   r9, #0
.4:
        ; branch t.3{r9}, true, @for_2_body, @for_2_break
        or   r9, r9
        jr   nz, for__2__body
        ; const t.11{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[t.11{r0}]
        call printChar_Pu8
        ; const i{r8}, 32
        ld   r8, #%20
        ; 27:2 for i < 128
        jr   for__4

for__4__body:
        ; 28:3 if i & 15 == 0
        ; const t.16{r9}, 15
        ld   r9, #%0f
        ; move t.15{r10}, i{r8}
        ld   r10, r8
        ; and t.15{r10}, t.15{r10}, t.16{r9}
        and  r10, r9
        ; const t.17{r9}, 0
        ld   r9, #%00
        ; equals t.14{r9}, t.15{r10}, t.17{r9}
        cp   r10, r9
        jr   ne, .ne5
        ld   r9, #1  ; true
        jr   .5
.ne5:
        ld   r9, #0
.5:
        ; branch t.14{r9}, false, @if_5_end, @if_5_then
        or   r9, r9
        jr   z, if__5__end
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printHex2@u8[i{r0}]
        call printHex2_Pu8
if__5__end:
        ; 31:3 if i & 7 == 0
        ; const t.20{r9}, 7
        ld   r9, #%07
        ; move t.19{r10}, i{r8}
        ld   r10, r8
        ; and t.19{r10}, t.19{r10}, t.20{r9}
        and  r10, r9
        ; const t.21{r9}, 0
        ld   r9, #%00
        ; equals t.18{r9}, t.19{r10}, t.21{r9}
        cp   r10, r9
        jr   ne, .ne6
        ld   r9, #1  ; true
        jr   .6
.ne6:
        ld   r9, #0
.6:
        ; branch t.18{r9}, false, @if_6_end, @if_6_then
        or   r9, r9
        jr   z, if__6__end
        ; const t.22{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[t.22{r0}]
        call printChar_Pu8
if__6__end:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printChar@u8[i{r0}]
        call printChar_Pu8
        ; 35:3 if i & 15 == 15
        ; const t.25{r9}, 15
        ld   r9, #%0f
        ; move t.24{r10}, i{r8}
        ld   r10, r8
        ; and t.24{r10}, t.24{r10}, t.25{r9}
        and  r10, r9
        ; const t.26{r9}, 15
        ld   r9, #%0f
        ; equals t.23{r9}, t.24{r10}, t.26{r9}
        cp   r10, r9
        jr   ne, .ne7
        ld   r9, #1  ; true
        jr   .7
.ne7:
        ld   r9, #0
.7:
        ; branch t.23{r9}, false, @for_4_continue, @if_7_then
        or   r9, r9
        jr   z, for__4__continue
        ; const t.27{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[t.27{r0}]
        call printChar_Pu8
for__4__continue:
        ; const t.28{r0}, 1
        ld   r0, #%01
        ; add i{r8}, i{r8}, t.28{r0}
        add  r8, r0
for__4:
        ; const t.13{r0}, 128
        ld   r0, #%80
        ; lt t.12{r0}, i{r8}, t.13{r0}
        cp   r8, r0
        jr   uge, .false8
.true8:
        ld   r0, #1
        jr   .8
.false8:
        ld   r0, #0
.8:
        ; branch t.12{r0}, true, @for_4_body, @main_ret
        or   r0, r0
        jr   nz, for__4__body
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printString@@u8
printString_P_Pu8:
        ld   r2, r0
        ld   r3, r1
        jr   .loop
.print:
        call printChar_Pu8
        incw r2
.loop:
        lde  r0, @rr2
        or   r0, r0
        jr   nz, .print
        ret

        ; void printChar@u8
printChar_Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

string__0:
        .data " x" %00

