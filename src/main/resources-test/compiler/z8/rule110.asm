        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; void printBoard
printBoard:
        ; save clobbered non-volatile registers
        push r8
        ; const arg.0.0{r0}, 124
        ld   r0, #%7c
        ; call printChar_Pu8[arg.0.0{r0}]
        call printChar_Pu8
        ; const i.1{r0}, 0
        ld   r0, #%00
        ; 11:2 for i < 30
        ; move i.2{r8}, i.1{r0}
        ld   r8, r0
        jr   for_1

for_1_body:
        ; 12:3 if [...] == 0
        ; cast t.3.1{r0}(i16), i.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.2.1{r2}, board
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.2.2{r2}, t.3.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.1.1{r0}, [t.2.2{r2}]
        lde  r0, @rr2
        ; branch t.1.1{r0} equals 0: if_2_then
        cp   r0, #%00
        jr   eq, if_2_then
        ; const arg.1.0{r0}, 42
        ld   r0, #%2a
        ; call printChar_Pu8[arg.1.0{r0}]
        call printChar_Pu8
        jr   for_1_continue

if_2_then:
        ; const arg.2.0{r0}, 32
        ld   r0, #%20
        ; call printChar_Pu8[arg.2.0{r0}]
        call printChar_Pu8
for_1_continue:
        ; move i.4{r0}, i.2{r8}
        ld   r0, r8
        ; add i.4{r0}, 1
        inc  r0
        ; move i.2{r8}, i.4{r0}
        ld   r8, r0
for_1:
        ; branch i.2{r8} lt 30: for_1_body
        cp   r8, #%1e
        jr   ult, for_1_body
        ; const t.4.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString_P_pu8[t.4.1{r0}]
        call printString_P_pu8
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        ; const i.1{r0}, 0
        ld   r0, #%00
        ; 23:2 for i < 30
        jr   for_3

for_3_body:
        ; const t.4.1{r1}, 0
        ld   r1, #%00
        ; cast t.6.1{r2}(i16), i.2{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; addrof t.5.1{r4}, board
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.5.2{r4}, t.6.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.5.2{r4}], t.4.1{r1}
        lde  @rr4, r1
        ; add i.5{r0}, 1
        inc  r0
for_3:
        ; branch i.2{r0} lt 30: for_3_body
        cp   r0, #%1e
        jr   ult, for_3_body
        ; const t.7.1{r0}, 1
        ld   r0, #%01
        ; const t.9.1{r1}, 29
        ld   r1, #%00
        ld   r2, #%1d
        ; addrof t.8.1{r4}, board
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.8.2{r4}, t.9.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.8.2{r4}], t.7.1{r0}
        lde  @rr4, r0
        ; call printBoard[]
        call printBoard
        ; const i.3{r0}, 0
        ld   r0, #%00
        ; 30:2 for i < 28
        ; move i.4{r8}, i.3{r0}
        ld   r8, r0
        jr   for_4

for_4_body:
        ; const t.13.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; addrof t.12.1{r2}, board
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.12.2{r2}, t.13.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.11.1{r0}, [t.12.2{r2}]
        lde  r0, @rr2
        ; shiftleft t.10.1{r0}, 1
        add r0, r0
        ; const t.16.1{r1}, 1
        ld   r1, #%00
        ld   r2, #%01
        ; addrof t.15.1{r4}, board
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.15.2{r4}, t.16.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load t.14.1{r1}, [t.15.2{r4}]
        lde  r1, @rr4
        ; or pattern.1{r0}, t.14.1{r1}
        or   r0, r1
        ; const j.1{r1}, 1
        ld   r1, #%01
        ; 32:3 for j < 29
        jr   for_5

for_5_body:
        ; shiftleft t.18.1{r0}, 1
        add r0, r0
        ; and t.17.1{r0}, 7
        and  r0, #%07
        ; move t.22.1{r2}, j.2{r1}
        ld   r2, r1
        ; add t.22.1{r2}, 1
        inc  r2
        ; cast t.21.1{r2}(i16), t.22.1{r2}(u8)
        ld   r3, r2
        ld   r2, #0
        ; addrof t.20.1{r4}, board
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.20.2{r4}, t.21.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.19.1{r2}, [t.20.2{r4}]
        lde  r2, @rr4
        ; or pattern.3{r0}, t.19.1{r2}
        or   r0, r2
        ; const t.25.1{r2}, 110
        ld   r2, #%6e
        ; shiftright t.24.1{r2}, pattern.3{r0}
        or   r0, r0
        jr   z, .next1
        push r0
.shift1:
        rcf
        rrc  r2
        djnz r0, .shift1
        pop  r0
.next1:
        ; and t.23.1{r2}, 1
        and  r2, #%01
        ; cast t.27.1{r3}(i16), j.2{r1}(u8)
        ld   r4, r1
        ld   r3, #0
        ; addrof t.26.1{r6}, board
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.26.2{r6}, t.27.1{r3}
        add  r7, r4
        adc  r6, r3
        ; store [t.26.2{r6}], t.23.1{r2}
        lde  @rr6, r2
        ; add j.3{r1}, 1
        inc  r1
for_5:
        ; branch j.2{r1} lt 29: for_5_body
        cp   r1, #%1d
        jr   ult, for_5_body
        ; call printBoard[]
        call printBoard
        ; move i.7{r0}, i.4{r8}
        ld   r0, r8
        ; add i.7{r0}, 1
        inc  r0
        ; move i.4{r8}, i.7{r0}
        ld   r8, r0
for_4:
        ; branch i.4{r8} lt 28: for_4_body
        cp   r8, #%1c
        jr   ult, for_4_body
        ; restore clobbered non-volatile registers
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

        ; variable 0: board[] (u8*/30)
var_0:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00

string_0:
        .data "|" %0a %00

