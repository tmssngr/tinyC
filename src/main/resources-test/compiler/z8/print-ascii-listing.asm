        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printNibble@u8
        ; arg x (u8): r0
printNibble__Pu8:
        ; and param.x{r0}, param.x{r0}, 15
        and  r0, #%0f
        ; 5:2 if x > 9
        ; branch param.x{r0} lteq 9: if_1_end, if_1_then
        cp   r0, #%09
        jr   ule, if__1__end
.1:
        ; add param.x{r0}, param.x{r0}, 7
        add  r0, #%07
if____1____end:
        ; add param.x{r0}, param.x{r0}, 48
        add  r0, #%30
        ; call printChar@u8[param.x{r0}]
        call printChar_Pu8
        ret

        ; void printHex2@u8
        ; arg x (u8): r0
printHex2__Pu8:
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

for____2____body:
        ; 20:3 if i & 7 == 0
        ; move t.3{r9}, i{r8}
        ld   r9, r8
        ; and t.3{r9}, t.3{r9}, 7
        and  r9, #%07
        ; branch t.3{r9} notequals 0: if_3_end, if_3_then
        cp   r9, #%00
        jr   ne, if__3__end
.2:
        ; const arg.1.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
if____3____end:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printNibble@u8[i{r0}]
        call printNibble_Pu8
        ; add i{r8}, i{r8}, 1
        inc  r8
for____2:
        ; branch i{r8} lt 16: for_2_body, for_2_break
        cp   r8, #%10
        jr   ult, for__2__body
.3:
        ; const arg.3.0{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[arg.3.0{r0}]
        call printChar_Pu8
        ; const i{r8}, 32
        ld   r8, #%20
        ; 27:2 for i < 128
        jr   for__4

for____4____body:
        ; 28:3 if i & 15 == 0
        ; move t.4{r9}, i{r8}
        ld   r9, r8
        ; and t.4{r9}, t.4{r9}, 15
        and  r9, #%0f
        ; branch t.4{r9} notequals 0: if_5_end, if_5_then
        cp   r9, #%00
        jr   ne, if__5__end
.4:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printHex2@u8[i{r0}]
        call printHex2_Pu8
if____5____end:
        ; 31:3 if i & 7 == 0
        ; move t.5{r9}, i{r8}
        ld   r9, r8
        ; and t.5{r9}, t.5{r9}, 7
        and  r9, #%07
        ; branch t.5{r9} notequals 0: if_6_end, if_6_then
        cp   r9, #%00
        jr   ne, if__6__end
.5:
        ; const arg.5.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.5.0{r0}]
        call printChar_Pu8
if____6____end:
        ; move i{r0}, i{r8}
        ld   r0, r8
        ; call printChar@u8[i{r0}]
        call printChar_Pu8
        ; 35:3 if i & 15 == 15
        ; move t.6{r9}, i{r8}
        ld   r9, r8
        ; and t.6{r9}, t.6{r9}, 15
        and  r9, #%0f
        ; branch t.6{r9} notequals 15: for_4_continue, if_7_then
        cp   r9, #%0f
        jr   ne, for__4__continue
.6:
        ; const arg.7.0{r0}, 10
        ld   r0, #%0a
        ; call printChar@u8[arg.7.0{r0}]
        call printChar_Pu8
for____4____continue:
        ; add i{r8}, i{r8}, 1
        inc  r8
for____4:
        ; branch i{r8} lt 128: for_4_body, main_ret
        cp   r8, #%80
        jr   ult, for__4__body
.7:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void printString@@u8
printString__P__Pu8:
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
printChar__Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

string__0:
        .data " x" %00

