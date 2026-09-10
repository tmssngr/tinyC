        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printBoard
printBoard:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const arg.0.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; const i{r8}, 0
        ld   r8, #%00
        ; 11:2 for i < 30
        jr   for__1

for____1____body:
        ; 12:3 if [...] == 0
        ; cast t.3{r9}(i16), i{r8}(u8)
        ld   r10, r8
        ld   r9, #0
        ; addrof t.2{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.2{r12}, t.2{r12}, t.3{r9}
        add  r13, r10
        adc  r12, r9
        ; load t.1{r9}, [t.2{r12}]
        lde  r9, @rr12
        ; branch t.1{r9} equals 0: if_2_then, if_2_else
        cp   r9, #%00
        jr   eq, if__2__then
.1:
        ; const arg.2.0{r0}, 42
        ld   r0, #%2a
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
        jr   for__1__continue

if____2____then:
        ; const arg.1.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
for____1____continue:
        ; add i{r8}, i{r8}, 1
        inc  r8
for____1:
        ; branch i{r8} lt 30: for_1_body, for_1_break
        cp   r8, #%1e
        jr   ult, for__1__body
.2:
        ; const t.4{r0}, [string-0]
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.4{r0}]
        call printString_P_Pu8
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; const i{r8}, 0
        ld   r8, #%00
        ; 23:2 for i < 30
        jr   for__3

for____3____body:
        ; const t.4{r9}, 0
        ld   r9, #%00
        ; cast t.6{r10}(i16), i{r8}(u8)
        ld   r11, r8
        ld   r10, #0
        ; addrof t.5{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.5{r12}, t.5{r12}, t.6{r10}
        add  r13, r11
        adc  r12, r10
        ; store [t.5{r12}], t.4{r9}
        lde  @rr12, r9
        ; add i{r8}, i{r8}, 1
        inc  r8
for____3:
        ; branch i{r8} lt 30: for_3_body, for_3_break
        cp   r8, #%1e
        jr   ult, for__3__body
.3:
        ; const t.7{r8}, 1
        ld   r8, #%01
        ; const t.9{r9}, 29
        ld   r9, #%00
        ld   r10, #%1d
        ; addrof t.8{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.8{r12}, t.8{r12}, t.9{r9}
        add  r13, r10
        adc  r12, r9
        ; store [t.8{r12}], t.7{r8}
        lde  @rr12, r8
        ; call printBoard[]
        call printBoard
        ; const i{r8}, 0
        ld   r8, #%00
        ; 30:2 for i < 28
        jr   for__4

for____4____body:
        ; const t.13{r9}, 0
        ld   r9, #%00
        ld   r10, #%00
        ; addrof t.12{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.12{r12}, t.12{r12}, t.13{r9}
        add  r13, r10
        adc  r12, r9
        ; load t.11{r9}, [t.12{r12}]
        lde  r9, @rr12
        ; shiftleft t.10{r9}, t.10{r9}, 1
        rcf
        rlc  r9
        ; const t.16{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; addrof t.15{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.15{r12}, t.15{r12}, t.16{r10}
        add  r13, r11
        adc  r12, r10
        ; load t.14{r10}, [t.15{r12}]
        lde  r10, @rr12
        ; or pattern{r9}, pattern{r9}, t.14{r10}
        or   r9, r10
        ; const j{r10}, 1
        ld   r10, #%01
        ; 32:3 for j < 29
        jr   for__5

for____5____body:
        ; shiftleft t.18{r9}, t.18{r9}, 1
        rcf
        rlc  r9
        ; and t.17{r9}, t.17{r9}, 7
        and  r9, #%07
        ; move t.22{r11}, j{r10}
        ld   r11, r10
        ; add t.22{r11}, t.22{r11}, 1
        inc  r11
        ; cast t.21{r11}(i16), t.22{r11}(u8)
        ld   r12, r11
        ld   r11, #0
        ; addrof t.20{r14}, [board]
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; add t.20{r14}, t.20{r14}, t.21{r11}
        add  r15, r12
        adc  r14, r11
        ; load t.19{r11}, [t.20{r14}]
        lde  r11, @rr14
        ; or pattern{r9}, pattern{r9}, t.19{r11}
        or   r9, r11
        ; const t.25{r11}, 110
        ld   r11, #%6e
        ; shiftright t.24{r11}, t.24{r11}, pattern{r9}
        or   r9, r9
        jr   z, .next4
        push r9
.shift4:
        rcf
        rrc  r11
        djnz r9, .shift4
        pop  r9
.next4:
        ; and t.23{r11}, t.23{r11}, 1
        and  r11, #%01
        ; cast t.27{r12}(i16), j{r10}(u8)
        ld   r13, r10
        ld   r12, #0
        ; addrof t.26{r14}, [board]
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; add t.26{r14}, t.26{r14}, t.27{r12}
        add  r15, r13
        adc  r14, r12
        ; store [t.26{r14}], t.23{r11}
        lde  @rr14, r11
        ; add j{r10}, j{r10}, 1
        inc  r10
for____5:
        ; branch j{r10} lt 29: for_5_body, for_5_break
        cp   r10, #%1d
        jr   ult, for__5__body
.5:
        ; call printBoard[]
        call printBoard
        ; add i{r8}, i{r8}, 1
        inc  r8
for____4:
        ; branch i{r8} lt 28: for_4_body, main_ret
        cp   r8, #%1c
        jr   ult, for__4__body
.6:
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
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

        ; variable 0: board[] (u8*/60)
var__0:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00

string__0:
        .data "|" %0a %00

