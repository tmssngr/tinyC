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
        ; and param.x{r0}, param.x{r0}, 15
        and  r0, #%0f
        ; 5:2 if x > 9
        ; gt t.1{r8}, param.x{r0}, 9
        cp   r0, #%09
        jr   ule, .false1
.true1:
        ld   r8, #1
        jr   .1
.false1:
        ld   r8, #0
.1:
        ; branch t.1{r8}, false, @if_1_end, @if_1_then
        or   r8, r8
        jr   z, if__1__end
        ; add param.x{r0}, param.x{r0}, 7
        add  r0, #%07
if__1__end:
        ; add param.x{r0}, param.x{r0}, 48
        add  r0, #%30
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
        ; move param.x{r8}, x{r0}
        ld   r8, r0
        ; move t.1{r0}, param.x{r8}
        ld   r0, r8
        ; shiftright t.1{r0}, t.1{r0}, 4
        swap r0
        and  r0, #%0F
        ; call printNibble@u8[t.1{r0}]
        call printNibble_Pu8
        ; move param.x{r0}, param.x{r8}
        ld   r0, r8
        ; call printNibble@u8[param.x{r0}]
        call printNibble_Pu8
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
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
        ; move t.5{r9}, i{r8}
        ld   r9, r8
        ; and t.5{r9}, t.5{r9}, 7
        and  r9, #%07
        ; equals t.4{r9}, t.5{r9}, 0
        cp   r9, #%00
        jr   ne, .ne2
        ld   r9, #1  ; true
        jr   .2
.ne2:
        ld   r9, #0
.2:
        ; branch t.4{r9}, false, @if_3_end, @if_3_then
        or   r9, r9
        jr   z, if__3__end
        ; const arg.1.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
if__3__end:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printNibble@u8[i{r0}]
        call printNibble_Pu8
        ; add i{r8}, i{r8}, 1
        inc  r8
for__2:
        ; lt t.3{r9}, i{r8}, 16
        cp   r8, #%10
        jr   uge, .false3
.true3:
        ld   r9, #1
        jr   .3
.false3:
        ld   r9, #0
.3:
        ; branch t.3{r9}, true, @for_2_body, @for_2_break
        or   r9, r9
        jr   nz, for__2__body
        ; const arg.3.0{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[arg.3.0{r0}]
        call printChar_Pu8
        ; const i{r8}, 32
        ld   r8, #%20
        ; 27:2 for i < 128
        jr   for__4

for__4__body:
        ; 28:3 if i & 15 == 0
        ; move t.8{r9}, i{r8}
        ld   r9, r8
        ; and t.8{r9}, t.8{r9}, 15
        and  r9, #%0f
        ; equals t.7{r9}, t.8{r9}, 0
        cp   r9, #%00
        jr   ne, .ne4
        ld   r9, #1  ; true
        jr   .4
.ne4:
        ld   r9, #0
.4:
        ; branch t.7{r9}, false, @if_5_end, @if_5_then
        or   r9, r9
        jr   z, if__5__end
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printHex2@u8[i{r0}]
        call printHex2_Pu8
if__5__end:
        ; 31:3 if i & 7 == 0
        ; move t.10{r9}, i{r8}
        ld   r9, r8
        ; and t.10{r9}, t.10{r9}, 7
        and  r9, #%07
        ; equals t.9{r9}, t.10{r9}, 0
        cp   r9, #%00
        jr   ne, .ne5
        ld   r9, #1  ; true
        jr   .5
.ne5:
        ld   r9, #0
.5:
        ; branch t.9{r9}, false, @if_6_end, @if_6_then
        or   r9, r9
        jr   z, if__6__end
        ; const arg.5.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.5.0{r0}]
        call printChar_Pu8
if__6__end:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printChar@u8[i{r0}]
        call printChar_Pu8
        ; 35:3 if i & 15 == 15
        ; move t.12{r9}, i{r8}
        ld   r9, r8
        ; and t.12{r9}, t.12{r9}, 15
        and  r9, #%0f
        ; equals t.11{r9}, t.12{r9}, 15
        cp   r9, #%0f
        jr   ne, .ne6
        ld   r9, #1  ; true
        jr   .6
.ne6:
        ld   r9, #0
.6:
        ; branch t.11{r9}, false, @for_4_continue, @if_7_then
        or   r9, r9
        jr   z, for__4__continue
        ; const arg.7.0{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[arg.7.0{r0}]
        call printChar_Pu8
for__4__continue:
        ; add i{r8}, i{r8}, 1
        inc  r8
for__4:
        ; lt t.6{r0}, i{r8}, 128
        cp   r8, #%80
        jr   uge, .false7
.true7:
        ld   r0, #1
        jr   .7
.false7:
        ld   r0, #0
.7:
        ; branch t.6{r0}, true, @for_4_body, @main_ret
        or   r0, r0
        jr   nz, for__4__body
        ; restore clobbered non-volatile registers
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

