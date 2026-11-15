        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; void printNibble_Pu8
        ; arg x (u8): r0
printNibble_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; move x.1{r8}, param.x{r0}
        ld   r8, r0
        ; and x.1{r8}, 15
        and  r8, #%0f
        ; 5:2 if x > 9
        ; branch x.1{r8} lteq 9: if_1_end
        cp   r8, #%09
        jr   ule, if_1_end
        ; add x.3{r8}, 7
        add  r8, #%07
if_1_end:
        ; move x.4{r0}, x.2{r8}
        ld   r0, r8
        ; add x.4{r0}, 48
        add  r0, #%30
        ; call printChar_Pu8[x.4{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void printHex2_Pu8
        ; arg x (u8): r0
printHex2_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; move param.x{r8}, x{r0}
        ld   r8, r0
        ; shiftright t.1.1{r0}, 4
        swap r0
        and  r0, #%0F
        ; call printNibble_Pu8[t.1.1{r0}]
        call printNibble_Pu8
        ; move param.x{r0}, param.x{r8}
        ld   r0, r8
        ; call printNibble_Pu8[param.x{r0}]
        call printNibble_Pu8
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const t.2.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        ; const i.1{r8}, 0
        ld   r8, #%00
        ; 19:2 for i < 16
        jr   for_2

for_2_body:
        ; 20:3 if i & 7 == 0
        ; move t.3.1{r9}, i.2{r8}
        ld   r9, r8
        ; and t.3.1{r9}, 7
        and  r9, #%07
        ; branch t.3.1{r9} notequals 0: if_3_end
        cp   r9, #%00
        jr   ne, if_3_end
        ; const arg.1.0{r0}, 32
        ld   r0, #%20
        ; call printChar_Pu8[arg.1.0{r0}]
        call printChar_Pu8
if_3_end:
        ; move i.2{r0}, i.2{r8}
        ld   r0, r8
        ; call printNibble_Pu8[i.2{r0}]
        call printNibble_Pu8
        ; add i.7{r8}, 1
        inc  r8
for_2:
        ; branch i.2{r8} lt 16: for_2_body
        cp   r8, #%10
        jr   ult, for_2_body
        ; const arg.3.0{r0}, 10
        ld   r0, #%0a
        ; call printChar_Pu8[arg.3.0{r0}]
        call printChar_Pu8
        ; const i.3{r8}, 32
        ld   r8, #%20
        ; 27:2 for i < 128
        jr   for_4

for_4_body:
        ; 28:3 if i & 15 == 0
        ; move t.4.1{r9}, i.4{r8}
        ld   r9, r8
        ; and t.4.1{r9}, 15
        and  r9, #%0f
        ; branch t.4.1{r9} notequals 0: if_5_end
        cp   r9, #%00
        jr   ne, if_5_end
        ; move i.4{r0}, i.4{r8}
        ld   r0, r8
        ; call printHex2_Pu8[i.4{r0}]
        call printHex2_Pu8
if_5_end:
        ; 31:3 if i & 7 == 0
        ; move t.5.1{r9}, i.4{r8}
        ld   r9, r8
        ; and t.5.1{r9}, 7
        and  r9, #%07
        ; branch t.5.1{r9} notequals 0: if_6_end
        cp   r9, #%00
        jr   ne, if_6_end
        ; const arg.5.0{r0}, 32
        ld   r0, #%20
        ; call printChar_Pu8[arg.5.0{r0}]
        call printChar_Pu8
if_6_end:
        ; move i.4{r0}, i.4{r8}
        ld   r0, r8
        ; call printChar_Pu8[i.4{r0}]
        call printChar_Pu8
        ; 35:3 if i & 15 == 15
        ; move t.6.1{r9}, i.4{r8}
        ld   r9, r8
        ; and t.6.1{r9}, 15
        and  r9, #%0f
        ; branch t.6.1{r9} notequals 15: for_4_continue
        cp   r9, #%0f
        jr   ne, for_4_continue
        ; const arg.7.0{r0}, 10
        ld   r0, #%0a
        ; call printChar_Pu8[arg.7.0{r0}]
        call printChar_Pu8
for_4_continue:
        ; move i.10{r0}, i.4{r8}
        ld   r0, r8
        ; add i.10{r0}, 1
        inc  r0
        ; move i.4{r8}, i.10{r0}
        ld   r8, r0
for_4:
        ; branch i.4{r8} lt 128: for_4_body
        cp   r8, #%80
        jr   ult, for_4_body
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void printString_P_pu8
printString_P_pu8:
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

        ; void printChar_Pu8
printChar_Pu8:
        cp    r0, #%0a
        jr    ne, .1
        ld    r0, #%0d
.1:
        ld    %15, r0
        jp    %0818

string_0:
        .data " x" %00

