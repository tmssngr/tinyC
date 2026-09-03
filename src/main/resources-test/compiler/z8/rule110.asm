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

for__1__body:
        ; 12:3 if [...] == 0
        ; cast t.5{r9}(i16), i{r8}(u8)
        ld   r10, r8
        ld   r9, #0
        ; addrof t.4{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.4{r12}, t.4{r12}, t.5{r9}
        add  r13, r10
        adc  r12, r9
        ; load t.3{r9}, [t.4{r12}]
        lde  r9, @rr12
        ; equals t.2{r9}, t.3{r9}, 0
        cp   r9, #%00
        jr   ne, .ne1
        ld   r9, #1  ; true
        jr   .1
.ne1:
        ld   r9, #0
.1:
        ; branch t.2{r9}, true, @if_2_then, @if_2_else
        or   r9, r9
        jr   nz, if__2__then
        ; const arg.2.0{r0}, 42
        ld   r0, #%2a
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
        jr   for__1__continue

if__2__then:
        ; const arg.1.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
for__1__continue:
        ; add i{r8}, i{r8}, 1
        inc  r8
for__1:
        ; lt t.1{r9}, i{r8}, 30
        cp   r8, #%1e
        jr   uge, .false2
.true2:
        ld   r9, #1
        jr   .2
.false2:
        ld   r9, #0
.2:
        ; branch t.1{r9}, true, @for_1_body, @for_1_break
        or   r9, r9
        jr   nz, for__1__body
        ; const t.6{r0}, [string-0]
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.6{r0}]
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

for__3__body:
        ; const t.5{r9}, 0
        ld   r9, #%00
        ; cast t.7{r10}(i16), i{r8}(u8)
        ld   r11, r8
        ld   r10, #0
        ; addrof t.6{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.6{r12}, t.6{r12}, t.7{r10}
        add  r13, r11
        adc  r12, r10
        ; store [t.6{r12}], t.5{r9}
        lde  @rr12, r9
        ; add i{r8}, i{r8}, 1
        inc  r8
for__3:
        ; lt t.4{r9}, i{r8}, 30
        cp   r8, #%1e
        jr   uge, .false3
.true3:
        ld   r9, #1
        jr   .3
.false3:
        ld   r9, #0
.3:
        ; branch t.4{r9}, true, @for_3_body, @for_3_break
        or   r9, r9
        jr   nz, for__3__body
        ; const t.8{r8}, 1
        ld   r8, #%01
        ; const t.10{r9}, 29
        ld   r9, #%00
        ld   r10, #%1d
        ; addrof t.9{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.9{r12}, t.9{r12}, t.10{r9}
        add  r13, r10
        adc  r12, r9
        ; store [t.9{r12}], t.8{r8}
        lde  @rr12, r8
        ; call printBoard[]
        call printBoard
        ; const i{r8}, 0
        ld   r8, #%00
        ; 30:2 for i < 28
        jr   for__4

for__4__body:
        ; const t.15{r9}, 0
        ld   r9, #%00
        ld   r10, #%00
        ; addrof t.14{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.14{r12}, t.14{r12}, t.15{r9}
        add  r13, r10
        adc  r12, r9
        ; load t.13{r9}, [t.14{r12}]
        lde  r9, @rr12
        ; shiftleft t.12{r9}, t.12{r9}, 1
        rcf
        rlc  r9
        ; const t.18{r10}, 1
        ld   r10, #%00
        ld   r11, #%01
        ; addrof t.17{r12}, [board]
        ld   r12, #hi(var__0)
        ld   r13, #lo(var__0)
        ; add t.17{r12}, t.17{r12}, t.18{r10}
        add  r13, r11
        adc  r12, r10
        ; load t.16{r10}, [t.17{r12}]
        lde  r10, @rr12
        ; or pattern{r9}, pattern{r9}, t.16{r10}
        or   r9, r10
        ; const j{r10}, 1
        ld   r10, #%01
        ; 32:3 for j < 29
        jr   for__5

for__5__body:
        ; shiftleft t.21{r9}, t.21{r9}, 1
        rcf
        rlc  r9
        ; and t.20{r9}, t.20{r9}, 7
        and  r9, #%07
        ; move t.25{r11}, j{r10}
        ld   r11, r10
        ; add t.25{r11}, t.25{r11}, 1
        inc  r11
        ; cast t.24{r11}(i16), t.25{r11}(u8)
        ld   r12, r11
        ld   r11, #0
        ; addrof t.23{r14}, [board]
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; add t.23{r14}, t.23{r14}, t.24{r11}
        add  r15, r12
        adc  r14, r11
        ; load t.22{r11}, [t.23{r14}]
        lde  r11, @rr14
        ; or pattern{r9}, pattern{r9}, t.22{r11}
        or   r9, r11
        ; const t.28{r11}, 110
        ld   r11, #%6e
        ; shiftright t.27{r11}, t.27{r11}, pattern{r9}
        or   r9, r9
        jr   z, .next4
        push r9
.shift4:
        rcf
        rrc  r11
        djnz r9, .shift4
        pop  r9
.next4:
        ; and t.26{r11}, t.26{r11}, 1
        and  r11, #%01
        ; cast t.30{r12}(i16), j{r10}(u8)
        ld   r13, r10
        ld   r12, #0
        ; addrof t.29{r14}, [board]
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; add t.29{r14}, t.29{r14}, t.30{r12}
        add  r15, r13
        adc  r14, r12
        ; store [t.29{r14}], t.26{r11}
        lde  @rr14, r11
        ; add j{r10}, j{r10}, 1
        inc  r10
for__5:
        ; lt t.19{r11}, j{r10}, 29
        cp   r10, #%1d
        jr   uge, .false5
.true5:
        ld   r11, #1
        jr   .5
.false5:
        ld   r11, #0
.5:
        ; branch t.19{r11}, true, @for_5_body, @for_5_break
        or   r11, r11
        jr   nz, for__5__body
        ; call printBoard[]
        call printBoard
        ; add i{r8}, i{r8}, 1
        inc  r8
for__4:
        ; lt t.11{r0}, i{r8}, 28
        cp   r8, #%1c
        jr   uge, .false6
.true6:
        ld   r0, #1
        jr   .6
.false6:
        ld   r0, #0
.6:
        ; branch t.11{r0}, true, @for_4_body, @main_ret
        or   r0, r0
        jr   nz, for__4__body
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

        ; variable 0: board[] (u8*/60)
var__0:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00

string__0:
        .data "|" %0a %00

