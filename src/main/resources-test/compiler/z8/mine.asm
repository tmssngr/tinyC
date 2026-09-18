        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void printUint@i16
        ; arg number (i16): r0
printUint_Pi16:
        ; cast t.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r0, r0
        rl   r0
        sbc  r0, r0
        sbc  r1, r1
        ; call printUint@i32[t.1{r0}]
        call printUint_Pi32
        ret

        ; i16 rowColumnToCell@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
rowColumnToCell_Pu8_Pu8:
        ; cast r{r2}(i16), param.row{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; cast c{r4}(i16), param.column{r1}(u8)
        ld   r5, r1
        ld   r4, #0
        ; 18:19 return r * 17 + c
        ; mul t.5{r2}, t.5{r2}, 17
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%11
        srp  #%10
        call %00BA ; mul
        srp  #%20
        ld   r2, %12
        ld   r3, %13
        ; move t.4{r0}, t.5{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.4{r0}, t.4{r0}, c{r4}
        add  r1, r5
        adc  r0, r4
        ret

        ; u8 getBombCountAround@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
getBombCountAround_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; move rowFrom{r10}, param.row{r8}
        ld   r10, r8
        ; 23:2 if rowFrom > 0
        ; branch rowFrom{r10} lteq 0: if_1_end, if_1_then
        cp   r10, #%00
        jr   ule, if__1__end
        ; move rowFrom{r10}, param.row{r8}
        ld   r10, r8
        ; sub rowFrom{r10}, rowFrom{r10}, 1
        dec  r10
if__1__end:
        ; move rowTo{r11}, param.row{r8}
        ld   r11, r8
        ; add rowTo{r11}, rowTo{r11}, 1
        inc  r11
        ; 27:2 if rowTo >= 20
        ; branch rowTo{r11} lt 20: if_2_end, if_2_then
        cp   r11, #%14
        jr   ult, if__2__end
        ; sub rowTo{r11}, rowTo{r11}, 1
        dec  r11
if__2__end:
        ; move colFrom{r12}, param.column{r9}
        ld   r12, r9
        ; 32:2 if colFrom > 0
        ; branch colFrom{r12} lteq 0: if_3_end, if_3_then
        cp   r12, #%00
        jr   ule, if__3__end
        ; sub colFrom{r12}, colFrom{r12}, 1
        dec  r12
if__3__end:
        ; move colTo{r13}, param.column{r9}
        ld   r13, r9
        ; add colTo{r13}, colTo{r13}, 1
        inc  r13
        ; 36:2 if colTo >= 17
        ; branch colTo{r13} lt 17: if_4_end, if_4_then
        cp   r13, #%11
        jr   ult, if__4__end
        ; sub colTo{r13}, colTo{r13}, 1
        dec  r13
if__4__end:
        ; const count{r14}, 0
        ld   r14, #%00
        ; move rowFrom{r0}, rowFrom{r10}
        ld   r0, r10
        ; move colFrom{r1}, colFrom{r12}
        ld   r1, r12
        ; call index{r0} = rowColumnToCell@u8@u8[rowFrom{r0}, colFrom{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; move r{r2}, rowFrom{r10}
        ld   r2, r10
        ; 42:2 for r <= rowTo
        jr   for__5

for__5__body:
        ; move c{r3}, colFrom{r12}
        ld   r3, r12
        ; 43:3 for c <= colTo
        jr   for__6

for__6__body:
        ; branch r{r2} notequals param.row{r8}: if_7_end, and_8
        cp   r2, r8
        jr   ne, if__7__end
        ; branch c{r3} equals param.column{r9}: for_6_continue, if_7_end
        cp   r3, r9
        jr   eq, for__6__continue
if__7__end:
        ; addrof t.11{r4}, [field]
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.11{r4}, t.11{r4}, index{r0}
        add  r5, r1
        adc  r4, r0
        ; load cell{r6}, [t.11{r4}]
        lde  r6, @rr4
        ; 49:4 if cell & 1 != 0
        ; move t.12{r4}, cell{r6}
        ld   r4, r6
        ; and t.12{r4}, t.12{r4}, 1
        and  r4, #%01
        ; branch t.12{r4} equals 0: for_6_continue, if_9_then
        cp   r4, #%00
        jr   eq, for__6__continue
        ; add count{r14}, count{r14}, 1
        inc  r14
for__6__continue:
        ; add c{r3}, c{r3}, 1
        inc  r3
        ; add index{r0}, index{r0}, 1
        incw r0
for__6:
        ; branch c{r3} lteq colTo{r13}: for_6_body, for_6_break
        cp   r3, r13
        jr   ule, for__6__body
        ; cast t.16{r3}(i16), colTo{r13}(u8)
        ld   r4, r13
        ld   r3, #0
        ; move t.15{r5}, index{r0}
        ld   r6, r1
        ld   r5, r0
        ; sub t.15{r5}, t.15{r5}, t.16{r3}
        sub  r6, r4
        sbc  r5, r3
        ; cast t.17{r3}(i16), colFrom{r12}(u8)
        ld   r4, r12
        ld   r3, #0
        ; add t.14{r5}, t.14{r5}, t.17{r3}
        add  r6, r4
        adc  r5, r3
        ; move t.13{r3}, t.14{r5}
        ld   r3, r5
        ld   r4, r6
        ; add t.13{r3}, t.13{r3}, 17
        add  r4, #%11
        adc  r3, #%00
        ; move index{r0}, t.13{r3}
        ld   r0, r3
        ld   r1, r4
        ; sub index{r0}, index{r0}, 1
        decw r0
        ; add r{r2}, r{r2}, 1
        inc  r2
for__5:
        ; branch r{r2} lteq rowTo{r11}: for_5_body, for_5_break
        cp   r2, r11
        jr   ule, for__5__body
        ; 55:9 return count
        ; move count{r0}, count{r14}
        ld   r0, r14
        ; restore clobbered non-volatile registers
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; i16 columnToX@u8
        ; arg column (u8): r0
columnToX_Pu8:
        ; cast c{r2}(i16), param.column{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; 60:17 return c + 1 << 1
        ; add t.3{r2}, t.3{r2}, 1
        incw r2
        ; move t.2{r0}, t.3{r2}
        ld   r0, r2
        ld   r1, r3
        ; shiftleft t.2{r0}, t.2{r0}, 1
        rcf
        rlc  r1
        rlc  r0
        ret

        ; void printCellAt@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
printCellAt_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call t.4{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.3{r10}, [field]
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.3{r10}, t.3{r10}, t.4{r0}
        add  r11, r1
        adc  r10, r0
        ; load cell{r0}, [t.3{r10}]
        lde  r0, @rr10
        ; move param.row{r1}, param.row{r8}
        ld   r1, r8
        ; move param.column{r2}, param.column{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell{r0}, param.row{r1}, param.column{r2}]
        call printCellAt_Pu8_Pu8_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printCellAt@u8@u8@u8
        ; arg cell (u8): r0
        ; arg row (u8): r1
        ; arg column (u8): r2
printCellAt_Pu8_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; move param.cell{r8}, cell{r0}
        ld   r8, r0
        ; move param.row{r9}, row{r1}
        ld   r9, r1
        ; move param.column{r10}, column{r2}
        ld   r10, r2
        ; move param.column{r0}, param.column{r10}
        ld   r0, r10
        ; call x{r0} = columnToX@u8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x{r2}, x{r0}
        ld   r3, r1
        ld   r2, r0
        ; cast t.4{r0}(i16), param.row{r9}(u8)
        ld   r1, r9
        ld   r0, #0
        ; call setCursor@i16@i16[t.4{r0}, x{r2}]
        call setCursor_Pi16_Pi16
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; move param.row{r1}, param.row{r9}
        ld   r1, r9
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ; call printCell@u8@u8@u8[param.cell{r0}, param.row{r1}, param.column{r2}]
        call printCell_Pu8_Pu8_Pu8
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printCell@u8@u8@u8
        ; arg cell (u8): r0
        ; arg row (u8): r1
        ; arg column (u8): r2
printCell_Pu8_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const chr{r8}, 46
        ld   r8, #%2e
        ; 76:2 if cell & 2 != 0
        ; move t.5{r9}, param.cell{r0}
        ld   r9, r0
        ; and t.5{r9}, t.5{r9}, 2
        and  r9, #%02
        ; branch t.5{r9} notequals 0: if_10_then, if_10_else
        cp   r9, #%00
        jr   ne, if__10__then
        ; 90:7 if cell & 4 != 0
        ; move t.7{r9}, param.cell{r0}
        ld   r9, r0
        ; and t.7{r9}, t.7{r9}, 4
        and  r9, #%04
        ; branch t.7{r9} equals 0: if_10_end, if_13_then
        cp   r9, #%00
        jr   eq, if__10__end
        jr   if__13__then

if__10__then:
        ; 77:3 if cell & 1 != 0
        ; move t.6{r8}, param.cell{r0}
        ld   r8, r0
        ; and t.6{r8}, t.6{r8}, 1
        and  r8, #%01
        ; branch t.6{r8} equals 0: if_11_else, if_11_then
        cp   r8, #%00
        jr   eq, if__11__else
        jr   if__11__then

if__13__then:
        ; const chr{r8}, 35
        ld   r8, #%23
        jr   if__10__end

if__11__else:
        ; move param.row{r0}, param.row{r1}
        ld   r0, r1
        ; move param.column{r1}, param.column{r2}
        ld   r1, r2
        ; call count{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; 82:4 if count > 0
        ; branch count{r0} lteq 0: if_12_else, if_12_then
        cp   r0, #%00
        jr   ule, if__12__else
        jr   if__12__then

if__11__then:
        ; const chr{r8}, 42
        ld   r8, #%2a
        jr   if__10__end

if__12__else:
        ; const chr{r8}, 32
        ld   r8, #%20
        jr   if__10__end

if__12__then:
        ; move chr{r8}, count{r0}
        ld   r8, r0
        ; add chr{r8}, chr{r8}, 48
        add  r8, #%30
if__10__end:
        ; move chr{r0}, chr{r8}
        ld   r0, r8
        ; call printChar@u8[chr{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void printField
printField:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const arg.0.0{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const arg.0.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const row{r8}, 0
        ld   r8, #%00
        ; 98:2 for row < 20
        jr   for__14

for__14__body:
        ; const arg.1.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
        ; const column{r9}, 0
        ld   r9, #%00
        ; 100:3 for column < 17
        jr   for__15

for__15__body:
        ; const arg.2.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
        ; move row{r0}, row{r8}
        ld   r0, r8
        ; move column{r1}, column{r9}
        ld   r1, r9
        ; call t.4{r0} = rowColumnToCell@u8@u8[row{r0}, column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.3{r10}, [field]
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.3{r10}, t.3{r10}, t.4{r0}
        add  r11, r1
        adc  r10, r0
        ; load cell{r0}, [t.3{r10}]
        lde  r0, @rr10
        ; move row{r1}, row{r8}
        ld   r1, r8
        ; move column{r2}, column{r9}
        ld   r2, r9
        ; call printCell@u8@u8@u8[cell{r0}, row{r1}, column{r2}]
        call printCell_Pu8_Pu8_Pu8
        ; add column{r9}, column{r9}, 1
        inc  r9
for__15:
        ; branch column{r9} lt 17: for_15_body, for_15_break
        cp   r9, #%11
        jr   ult, for__15__body
        ; const t.5{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.5{r0}]
        call printString_P_Pu8
        ; add row{r8}, row{r8}, 1
        inc  r8
for__14:
        ; branch row{r8} lt 20: for_14_body, printField_ret
        cp   r8, #%14
        jr   ult, for__14__body
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void showCursor@u8@u8@bool
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; arg show (bool): r2
showCursor_Pu8_Pu8_Pbool:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.show{r9}, show{r2}
        ld   r9, r2
        ; move param.column{r0}, param.column{r1}
        ld   r0, r1
        ; call x{r0} = columnToX@u8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x{r10}, x{r0}
        ld   r11, r1
        ld   r10, r0
        ; cast t.5{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; move t.6{r2}, x{r10}
        ld   r2, r10
        ld   r3, r11
        ; sub t.6{r2}, t.6{r2}, 1
        decw r2
        ; call setCursor@i16@i16[t.5{r0}, t.6{r2}]
        call setCursor_Pi16_Pi16
        ; const chr{r12}, 32
        ld   r12, #%20
        ; 113:2 if show
        ; branch param.show{r9} equals 0: if_16_end, if_16_then
        cp   r9, #%00
        jr   eq, if__16__end
        ; const chr{r12}, 91
        ld   r12, #%5b
if__16__end:
        ; move chr{r0}, chr{r12}
        ld   r0, r12
        ; call printChar@u8[chr{r0}]
        call printChar_Pu8
        ; cast t.7{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; move t.8{r2}, x{r10}
        ld   r2, r10
        ld   r3, r11
        ; add t.8{r2}, t.8{r2}, 1
        incw r2
        ; call setCursor@i16@i16[t.7{r0}, t.8{r2}]
        call setCursor_Pi16_Pi16
        ; 119:2 if show
        ; branch param.show{r9} equals 0: if_17_end, if_17_then
        cp   r9, #%00
        jr   eq, if__17__end
        ; const chr{r12}, 93
        ld   r12, #%5d
if__17__end:
        ; move chr{r0}, chr{r12}
        ld   r0, r12
        ; call printChar@u8[chr{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printSpaces@i16
        ; arg i (i16): r0
printSpaces_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.i{r8}, i{r0}
        ld   r9, r1
        ld   r8, r0
        ; 126:2 for i > 0
        jr   for__18

for__18__body:
        ; const arg.0.0{r0}, 48
        ld   r0, #%30
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; sub param.i{r8}, param.i{r8}, 1
        decw r8
for__18:
        ; branch param.i{r8} gt 0: for_18_body, printSpaces@i16_ret
        cp   r8, #%00
        jr   gt, for__18__body
        jr   ne, .gt1
        cp   r9, #%00
        jr   ugt, for__18__body
.gt1:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; u8 getDigitCount@i16
        ; arg value (i16): r0
getDigitCount_Pi16:
        ; const count{r2}, 0
        ld   r2, #%00
        ; 133:2 if value < 0
        ; branch param.value{r0} gteq 0: while_20, if_19_then
        cp   r0, #%00
        jr   gt, while__20
        jr   ne, .gt2
        cp   r1, #%00
        jr   uge, while__20
.gt2:
        ; const count{r2}, 1
        ld   r2, #%01
        ; neg param.value{r0}, param.value{r0}
        com  r0
        com  r1
        incw r0
while__20:
        ; add count{r2}, count{r2}, 1
        inc  r2
        ; div param.value{r0}, param.value{r0}, 10
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%0a
        srp  #%10
        call %00E0 ; div
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; 141:3 if value == 0
        ; branch param.value{r0} notequals 0: while_20, while_20_break
        cp   r1, #%00
        jr   ne, while__20
        cp   r0, #%00
        jr   ne, while__20
        ; 146:9 return count
        ; move count{r0}, count{r2}
        ld   r0, r2
        ret

        ; i16 getHiddenCount
getHiddenCount:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const count{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; const r{r10}, 0
        ld   r10, #%00
        ; 151:2 for r < 20
        jr   for__22

for__22__body:
        ; const c{r11}, 0
        ld   r11, #%00
        ; 152:3 for c < 17
        jr   for__23

for__23__body:
        ; move r{r0}, r{r10}
        ld   r0, r10
        ; move c{r1}, c{r11}
        ld   r1, r11
        ; call t.5{r0} = rowColumnToCell@u8@u8[r{r0}, c{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.4{r2}, [field]
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.4{r2}, t.4{r2}, t.5{r0}
        add  r3, r1
        adc  r2, r0
        ; load cell{r4}, [t.4{r2}]
        lde  r4, @rr2
        ; 154:4 if cell & 6 == 0
        ; move t.6{r2}, cell{r4}
        ld   r2, r4
        ; and t.6{r2}, t.6{r2}, 6
        and  r2, #%06
        ; branch t.6{r2} notequals 0: for_23_continue, if_24_then
        cp   r2, #%00
        jr   ne, for__23__continue
        ; add count{r8}, count{r8}, 1
        incw r8
for__23__continue:
        ; add c{r11}, c{r11}, 1
        inc  r11
for__23:
        ; branch c{r11} lt 17: for_23_body, for_22_continue
        cp   r11, #%11
        jr   ult, for__23__body
        ; add r{r10}, r{r10}, 1
        inc  r10
for__22:
        ; branch r{r10} lt 20: for_22_body, for_22_break
        cp   r10, #%14
        jr   ult, for__22__body
        ; 159:9 return count
        ; move count{r0}, count{r8}
        ld   r0, r8
        ld   r1, r9
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; bool printLeft
printLeft:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; call count{r0} = getHiddenCount[] -> i16
        call getHiddenCount
        ; move count{r8}, count{r0}
        ld   r9, r1
        ld   r8, r0
        ; move count{r0}, count{r8}
        ld   r0, r8
        ld   r1, r9
        ; call t.3{r0} = getDigitCount@i16[count{r0}] -> u8
        call getDigitCount_Pi16
        ; cast leftDigits{r10}(i16), t.3{r0}(u8)
        ld   r11, r0
        ld   r10, #0
        ; const arg.2.0{r0}, 23
        ld   r0, #%00
        ld   r1, #%17
        ; call t.4{r0} = getDigitCount@i16[arg.2.0{r0}] -> u8
        call getDigitCount_Pi16
        ; cast bombDigits{r12}(i16), t.4{r0}(u8)
        ld   r13, r0
        ld   r12, #0
        ; const arg.3.0{r0}, 20
        ld   r0, #%00
        ld   r1, #%14
        ; const arg.3.1{r2}, 6
        ld   r2, #%00
        ld   r3, #%06
        ; call setCursor@i16@i16[arg.3.0{r0}, arg.3.1{r2}]
        call setCursor_Pi16_Pi16
        ; move t.5{r0}, bombDigits{r12}
        ld   r0, r12
        ld   r1, r13
        ; sub t.5{r0}, t.5{r0}, leftDigits{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call printSpaces@i16[t.5{r0}]
        call printSpaces_Pi16
        ; move count{r0}, count{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint@i16[count{r0}]
        call printUint_Pi16
        ; 170:15 return count == 0
        ; equals t.6{r0}, count{r8}, 0
        cp   r8, #%00
        jr   ne, .ne3
        cp   r9, #%00
        jr   ne, .ne3
        ld   r0, #1  ; true
        jr   .3
.ne3:
        ld   r0, #0
.3:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; i16 abs@i16
        ; arg a (i16): r0
abs_Pi16:
        ; move param.a{r2}, a{r0}
        ld   r3, r1
        ld   r2, r0
        ; 174:2 if a < 0
        ; branch param.a{r2} lt 0: if_25_then, if_25_end
        cp   r2, #%00
        jr   lt, if__25__then
        jr   ne, .lt4
        cp   r3, #%00
        jr   ult, if__25__then
.lt4:
        ; 177:9 return a
        ; move param.a{r0}, param.a{r2}
        ld   r0, r2
        ld   r1, r3
        jr   abs_Pi16__ret

if__25__then:
        ; 175:10 return -a
        ; neg t.1{r2}, param.a{r2}
        com  r2
        com  r3
        incw r2
        ; move t.1{r0}, t.1{r2}
        ld   r0, r2
        ld   r1, r3
abs_Pi16__ret:
        ret

        ; void clearField
clearField:
        ; const index{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const i{r2}, 340
        ld   r2, #%01
        ld   r3, #%54
        ; 182:2 for i > 0
        jr   for__26

for__26__body:
        ; const t.2{r4}, 0
        ld   r4, #%00
        ; addrof t.3{r6}, [field]
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.3{r6}, t.3{r6}, index{r0}
        add  r7, r1
        adc  r6, r0
        ; store [t.3{r6}], t.2{r4}
        lde  @rr6, r4
        ; sub i{r2}, i{r2}, 1
        decw r2
for__26:
        ; branch i{r2} gt 0: for_26_body, clearField_ret
        cp   r2, #%00
        jr   gt, for__26__body
        jr   ne, .gt5
        cp   r3, #%00
        jr   ugt, for__26__body
.gt5:
        ret

        ; void initField@u8@u8
        ; arg curr_r (u8): r0
        ; arg curr_c (u8): r1
        ; var row (i16): SP+8
        ; var column (i16): SP+10
        ; var t.13 (u8): SP+12
initField_Pu8_Pu8:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%05
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; cast r{r8}(i16), param.curr_r{r0}(u8)
        ld   r9, r0
        ld   r8, #0
        ; cast c{r10}(i16), param.curr_c{r1}(u8)
        ld   r11, r1
        ld   r10, #0
        ; const bombs{r12}, 23
        ld   r12, #%00
        ld   r13, #%17
        ; 190:2 for bombs > 0
        jr   for__27

for__27__body:
        ; call t.7{r0} = random16[] -> i16
        call random16
        ; mod row{r0}, row{r0}, 20
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], row{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; call t.8{r0} = random16[] -> i16
        call random16
        ; move column{r2}, t.8{r0}
        ld   r3, r1
        ld   r2, r0
        ; mod column{r2}, column{r2}, 17
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%11
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r2, %12
        ld   r3, %13
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], column{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; 193:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=193:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=193:20], location=193:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=194:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=194:20], location=194:18]]) > 1
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move t.10{r0}, row{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], row{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; sub t.10{r0}, t.10{r0}, r{r8}
        sub  r1, r9
        sbc  r0, r8
        ; call t.9{r0} = abs@i16[t.10{r0}] -> i16
        call abs_Pi16
        ; branch t.9{r0} gt 1: if_28_then, or_29
        cp   r0, #%00
        jr   gt, if__28__then
        jr   ne, .gt6
        cp   r1, #%01
        jr   ugt, if__28__then
.gt6:
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move t.12{r0}, column{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], column{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; sub t.12{r0}, t.12{r0}, c{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call t.11{r0} = abs@i16[t.12{r0}] -> i16
        call abs_Pi16
        ; branch t.11{r0} lteq 1: for_27_continue, if_28_then
        cp   r0, #%00
        jr   lt, for__27__continue
        jr   ne, .lt7
        cp   r1, #%01
        jr   ule, for__27__continue
.lt7:
if__28__then:
        ; const t.13{r2}, 1
        ld   r2, #%01
        ; addrof memVarAddr{r14}, t.13
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.13{r2}
        lde  @rr14, r2
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; cast t.16{r0}(u8), row{r2}(i16)
        ld   r0, r3
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; cast t.17{r1}(u8), column{r2}(i16)
        ld   r1, r3
        ; call t.15{r0} = rowColumnToCell@u8@u8[t.16{r0}, t.17{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.14{r2}, [field]
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.14{r2}, t.14{r2}, t.15{r0}
        add  r3, r1
        adc  r2, r0
        ; addrof memVarAddr{r14}, t.13
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load t.13{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; store [t.14{r2}], t.13{r0}
        lde  @rr2, r0
for__27__continue:
        ; sub bombs{r12}, bombs{r12}, 1
        decw r12
for__27:
        ; branch bombs{r12} gt 0: for_27_body, initField@u8@u8_ret
        cp   r12, #%00
        jr   gt, for__27__body
        jr   ne, .gt8
        cp   r13, #%00
        jr   ugt, for__27__body
.gt8:
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%05
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void maybeRevealAround@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; var index (i16): SP+8
        ; var c (u8): SP+10
maybeRevealAround_Pu8_Pu8:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%03
        sbc  %30, #%00
        ld   SPH, %30
        ld   SPL, %31
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call printCellAt@u8@u8[param.row{r0}, param.column{r1}]
        call printCellAt_Pu8_Pu8
        ; 202:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=202:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=202:30]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call t.10{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.10{r0} notequals 0: maybeRevealAround@u8@u8_ret, if_30_end
        cp   r0, #%00
        jr   ne, maybeRevealAround_Pu8_Pu8__ret
        ; move rowFrom{r10}, param.row{r8}
        ld   r10, r8
        ; 207:2 if rowFrom > 0
        ; branch rowFrom{r10} lteq 0: if_31_end, if_31_then
        cp   r10, #%00
        jr   ule, if__31__end
        ; move rowFrom{r10}, param.row{r8}
        ld   r10, r8
        ; sub rowFrom{r10}, rowFrom{r10}, 1
        dec  r10
if__31__end:
        ; move rowTo{r11}, param.row{r8}
        ld   r11, r8
        ; add rowTo{r11}, rowTo{r11}, 1
        inc  r11
        ; 211:2 if rowTo >= 20
        ; branch rowTo{r11} lt 20: if_32_end, if_32_then
        cp   r11, #%14
        jr   ult, if__32__end
        ; sub rowTo{r11}, rowTo{r11}, 1
        dec  r11
if__32__end:
        ; move colFrom{r12}, param.column{r9}
        ld   r12, r9
        ; 216:2 if colFrom > 0
        ; branch colFrom{r12} lteq 0: if_33_end, if_33_then
        cp   r12, #%00
        jr   ule, if__33__end
        ; sub colFrom{r12}, colFrom{r12}, 1
        dec  r12
if__33__end:
        ; move colTo{r13}, param.column{r9}
        ld   r13, r9
        ; add colTo{r13}, colTo{r13}, 1
        inc  r13
        ; 220:2 if colTo >= 17
        ; branch colTo{r13} lt 17: if_34_end, if_34_then
        cp   r13, #%11
        jr   ult, if__34__end
        ; sub colTo{r13}, colTo{r13}, 1
        dec  r13
if__34__end:
        ; move rowFrom{r0}, rowFrom{r10}
        ld   r0, r10
        ; move colFrom{r1}, colFrom{r12}
        ld   r1, r12
        ; call index{r0} = rowColumnToCell@u8@u8[rowFrom{r0}, colFrom{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; 224:2 for r <= rowTo
        ; move index{r2}, index{r0}
        ld   r3, r1
        ld   r2, r0
        jr   for__35

for__35__body:
        ; move index{r0}, index{r2}
        ld   r0, r2
        ld   r1, r3
        ; move c{r2}, colFrom{r12}
        ld   r2, r12
        ; 225:3 for c <= colTo
        ; move c{r1}, c{r2}
        ld   r1, r2
        ; move index{r2}, index{r0}
        ld   r3, r1
        ld   r2, r0
        jr   for__36

for__36__body:
        ; move index{r0}, index{r2}
        ld   r0, r2
        ld   r1, r3
        ; move c{r2}, c{r1}
        ld   r2, r1
        ; branch r{r10} notequals param.row{r8}: if_37_end, and_38
        cp   r10, r8
        jr   ne, if__37__end
        ; branch c{r2} notequals param.column{r9}: if_37_end, maybeRevealAround@u8@u8.no_critical_edge_29
        cp   r2, r9
        jr   ne, if__37__end
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], c{r2}
        lde  @rr14, r2
        ; addrof memVarAddr{r14}, index
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], index{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        jr   for__36__continue

if__37__end:
        ; addrof t.11{r4}, [field]
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.11{r4}, t.11{r4}, index{r0}
        add  r5, r1
        adc  r4, r0
        ; load cell{r3}, [t.11{r4}]
        lde  r3, @rr4
        ; 231:4 if cell & 2 != 0
        ; move t.12{r4}, cell{r3}
        ld   r4, r3
        ; and t.12{r4}, t.12{r4}, 2
        and  r4, #%02
        ; branch t.12{r4} equals 0: if_39_end, maybeRevealAround@u8@u8.no_critical_edge_28
        cp   r4, #%00
        jr   eq, if__39__end
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], c{r2}
        lde  @rr14, r2
        ; addrof memVarAddr{r14}, index
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], index{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        jr   for__36__continue

if__39__end:
        ; or t.13{r3}, t.13{r3}, 2
        or  r3, #%02
        ; addrof t.14{r4}, [field]
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.14{r4}, t.14{r4}, index{r0}
        add  r5, r1
        adc  r4, r0
        ; addrof memVarAddr{r14}, index
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], index{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; store [t.14{r4}], t.13{r3}
        lde  @rr4, r3
        ; move r{r0}, r{r10}
        ld   r0, r10
        ; move c{r1}, c{r2}
        ld   r1, r2
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], c{r2}
        lde  @rr14, r2
        ; call maybeRevealAround@u8@u8[r{r0}, c{r1}]
        call maybeRevealAround_Pu8_Pu8
for__36__continue:
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load c{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; add c{r1}, c{r1}, 1
        inc  r1
        ; addrof memVarAddr{r14}, index
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load index{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; add index{r2}, index{r2}, 1
        incw r2
for__36:
        ; branch c{r1} lteq colTo{r13}: for_36_body, for_36_break
        cp   r1, r13
        jr   ule, for__36__body
        ; cast t.18{r0}(i16), colTo{r13}(u8)
        ld   r1, r13
        ld   r0, #0
        ; sub t.17{r2}, t.17{r2}, t.18{r0}
        sub  r3, r1
        sbc  r2, r0
        ; cast t.19{r0}(i16), colFrom{r12}(u8)
        ld   r1, r12
        ld   r0, #0
        ; add t.16{r2}, t.16{r2}, t.19{r0}
        add  r3, r1
        adc  r2, r0
        ; move t.15{r0}, t.16{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.15{r0}, t.15{r0}, 17
        add  r1, #%11
        adc  r0, #%00
        ; move index{r2}, t.15{r0}
        ld   r3, r1
        ld   r2, r0
        ; sub index{r2}, index{r2}, 1
        decw r2
        ; add r{r10}, r{r10}, 1
        inc  r10
for__35:
        ; branch r{r10} lteq rowTo{r11}: for_35_body, maybeRevealAround@u8@u8_ret
        cp   r10, r11
        jr   ule, for__35__body
maybeRevealAround_Pu8_Pu8__ret:
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%03
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
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
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom@i32[arg.0.0{r0}]
        call initRandom_Pi32
        ; const needsInitialize{r8}, 1
        ld   r8, #%01
        ; call clearField[]
        call clearField
        ; call printField[]
        call printField
        ; const arg.3.0{r0}, 20
        ld   r0, #%00
        ld   r1, #%14
        ; const arg.3.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.3.0{r0}, arg.3.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.8{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.8{r0}]
        call printString_P_Pu8
        ; const curr_c{r9}, 8
        ld   r9, #%08
        ; const curr_r{r10}, 10
        ld   r10, #%0a
        ; 251:2 while true
        jr   while__40

if__41__then:
        ; 253:4 if printLeft([])
        ; call t.9{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.9{r0} notequals 0: if_42_then, if_41_end
        cp   r0, #%00
        jr   ne, if__42__then
if__41__end:
        ; const t.11{r2}, 1
        ld   r2, #%01
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r{r0}, curr_c{r1}, t.11{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; call chr{r0} = getChar[] -> i16
        call getChar
        ; move chr{r11}, chr{r0}
        ld   r12, r1
        ld   r11, r0
        ; const t.12{r2}, 0
        ld   r2, #%00
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r{r0}, curr_c{r1}, t.12{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; 262:3 if chr == 27
        ; branch chr{r11} equals 27: main_ret, if_43_end
        cp   r12, #%1b
        jr   ne, .notEquals9
        cp   r11, #%00
        jr   eq, main__ret
.notEquals9:
        ; branch chr{r11} equals 13: if_44_then, if_44_else
        cp   r12, #%0d
        jr   ne, .notEquals10
        cp   r11, #%00
        jr   eq, if__44__then
.notEquals10:
        ; branch chr{r11} notequals 3: if_48_else, if_48_then
        cp   r12, #%03
        jr   ne, if__48__else
        cp   r11, #%00
        jr   ne, if__48__else
        jr   if__48__then

if__44__then:
        ; branch needsInitialize{r8} equals 0: if_45_end, if_45_then
        cp   r8, #%00
        jr   eq, if__45__end
        jr   if__45__then

if__48__else:
        ; branch chr{r11} notequals 4: if_50_else, if_50_then
        cp   r12, #%04
        jr   ne, if__50__else
        cp   r11, #%00
        jr   ne, if__50__else
        jr   if__50__then

if__48__then:
        ; branch curr_r{r10} lteq 0: while_40, if_49_then
        cp   r10, #%00
        jr   ule, while__40
        jr   if__49__then

if__45__then:
        ; const needsInitialize{r8}, 0
        ld   r8, #%00
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call initField@u8@u8[curr_r{r0}, curr_c{r1}]
        call initField_Pu8_Pu8
        jr   if__45__end

if__50__else:
        ; branch chr{r11} notequals 1: if_52_else, if_52_then
        cp   r12, #%01
        jr   ne, if__52__else
        cp   r11, #%00
        jr   ne, if__52__else
        jr   if__52__then

if__50__then:
        ; branch curr_r{r10} gteq 19: while_40, if_51_then
        cp   r10, #%13
        jr   uge, while__40
        jr   if__51__then

if__49__then:
        ; sub curr_r{r10}, curr_r{r10}, 1
        dec  r10
        jr   while__40

if__45__end:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call index{r0} = rowColumnToCell@u8@u8[curr_r{r0}, curr_c{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.13{r12}, [field]
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.13{r12}, t.13{r12}, index{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell{r11}, [t.13{r12}]
        lde  r11, @rr12
        ; 273:4 if cell & 2 == 0
        ; move t.14{r12}, cell{r11}
        ld   r12, r11
        ; and t.14{r12}, t.14{r12}, 2
        and  r12, #%02
        ; branch t.14{r12} notequals 0: if_46_end, if_46_then
        cp   r12, #%00
        jr   ne, if__46__end
        jr   if__46__then

if__52__else:
        ; branch chr{r11} notequals 2: if_54_else, if_54_then
        cp   r12, #%02
        jr   ne, if__54__else
        cp   r11, #%00
        jr   ne, if__54__else
        jr   if__54__then

if__52__then:
        ; branch curr_c{r9} lteq 0: while_40, if_53_then
        cp   r9, #%00
        jr   ule, while__40
        jr   if__53__then

if__51__then:
        ; add curr_r{r10}, curr_r{r10}, 1
        inc  r10
        jr   while__40

if__46__then:
        ; move t.15{r12}, cell{r11}
        ld   r12, r11
        ; or t.15{r12}, t.15{r12}, 2
        or  r12, #%02
        ; addrof t.16{r14}, [field]
        ld   r14, #hi(var_0)
        ld   r15, #lo(var_0)
        ; add t.16{r14}, t.16{r14}, index{r0}
        add  r15, r1
        adc  r14, r0
        ; store [t.16{r14}], t.15{r12}
        lde  @rr14, r12
        jr   if__46__end

if__54__else:
        ; branch chr{r11} notequals 32: while_40, if_56_then
        cp   r12, #%20
        jr   ne, while__40
        cp   r11, #%00
        jr   ne, while__40
        jr   if__56__then

if__54__then:
        ; branch curr_c{r9} gteq 16: while_40, if_55_then
        cp   r9, #%10
        jr   uge, while__40
        jr   if__55__then

if__53__then:
        ; sub curr_c{r9}, curr_c{r9}, 1
        dec  r9
        jr   while__40

if__46__end:
        ; 276:4 if cell & 1 != 0
        ; and t.17{r11}, t.17{r11}, 1
        and  r11, #%01
        ; branch t.17{r11} equals 0: if_47_end, if_47_then
        cp   r11, #%00
        jr   eq, if__47__end
        jr   if__47__then

if__56__then:
        ; branch needsInitialize{r8} notequals 0: while_40, if_57_then
        cp   r8, #%00
        jr   ne, while__40
        jr   if__57__then

if__55__then:
        ; add curr_c{r9}, curr_c{r9}, 1
        inc  r9
        jr   while__40

if__47__end:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call maybeRevealAround@u8@u8[curr_r{r0}, curr_c{r1}]
        call maybeRevealAround_Pu8_Pu8
        jr   while__40

if__57__then:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call index{r0} = rowColumnToCell@u8@u8[curr_r{r0}, curr_c{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.19{r12}, [field]
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.19{r12}, t.19{r12}, index{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell{r11}, [t.19{r12}]
        lde  r11, @rr12
        ; 312:5 if cell & 2 == 0
        ; move t.20{r12}, cell{r11}
        ld   r12, r11
        ; and t.20{r12}, t.20{r12}, 2
        and  r12, #%02
        ; branch t.20{r12} notequals 0: while_40, if_58_then
        cp   r12, #%00
        jr   ne, while__40
        ; xor cell{r11}, cell{r11}, 4
        xor r11, #%04
        ; addrof t.21{r12}, [field]
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.21{r12}, t.21{r12}, index{r0}
        add  r13, r1
        adc  r12, r0
        ; store [t.21{r12}], cell{r11}
        lde  @rr12, r11
        ; move cell{r0}, cell{r11}
        ld   r0, r11
        ; move curr_r{r1}, curr_r{r10}
        ld   r1, r10
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell{r0}, curr_r{r1}, curr_c{r2}]
        call printCellAt_Pu8_Pu8_Pu8
while__40:
        ; branch needsInitialize{r8} notequals 0: if_41_end, if_41_then
        cp   r8, #%00
        jr   ne, if__41__end
        jr   if__41__then

if__42__then:
        ; const t.10{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.10{r0}]
        call printString_P_Pu8
        jr   main__ret

if__47__then:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call printCellAt@u8@u8[curr_r{r0}, curr_c{r1}]
        call printCellAt_Pu8_Pu8
        ; const t.18{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.18{r0}]
        call printString_P_Pu8
main__ret:
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

        ; void printUint@i32
printUint_Pi32:
        ld   r4, #1
        ld   r5, #%28
        ld   r6, #8
.push:
        push @r5
        inc  r5
        djnz r6, .push
        ; result
        clr     r11
        clr     r12
        clr     r13
        clr     r14
        clr     r15
        ; summand (bcd-shifted power of 2)
        clr     r6
        clr     r7
        clr     r8
        clr     r9
        ld      r10, #1
        ; counter
        ld      r5, #%20
.1:
        sra     r0
        rrc     r1
        rrc     r2
        rrc     r3
        jr      nc, .2
        add     r15, r10
        da      r15
        adc     r14, r9
        da      r14
        adc     r13, r8
        da      r13
        adc     r12, r7
        da      r12
        adc     r11, r6
        da      r11
.2:
        add     r10, r10
        da      r10
        adc     r9, r9
        da      r9
        adc     r8, r8
        da      r8
        adc     r7, r7
        da      r7
        adc     r6, r6
        da      r6
        djnz    r5, .1
        ld      r6, #%2b
        ; counter
        ld      r7, #10
.loop:
        ld      r5, @r6
        tm      r7, #1
        jr      nz, .4
        swap    r5
.4:
        and     r5, #%0f
        or      r4, r4
        jr      z, .5
        cp      r7, #1
        jr      eq, .5
        or      r5, r5
        jr      z, .6
        clr     r4
.5:
        ld      %15, r5
        add     %15, #'0'
        call    %0818
.6:
        tm      r7, #1
        jr      z, .7
        inc     r6
.7:
        djnz    r7, .loop
        ld   r5, #%2f
        ld   r6, #8
.pop:
        pop  @r5
        dec  r5
        djnz r6, .pop
        ret

        ; void setCursor@i16@i16
setCursor_Pi16_Pi16:
        ld   %5b, r3
        ld   %5c, r1
        ret

        ; i16 getChar
getChar:
        call %081e
        ld   r0, #0
        ld   r1, %13
        ret

        ; void initRandom@i32
initRandom_Pi32:
        ld   %70, r0
        ld   %71, r1
        ld   %72, r2
        ld   %73, r3
        ret

        ; i16 random16
random16:
        call %0836
        ld   r0, %74
        ld   r1, %75
        and  r0, #%7f
        ret

        ; variable 0: field[] (u8*/680)
var_0:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00

string_0:
        .data " |" %0a %00
string_1:
        .data "Left:" %00
string_2:
        .data " You've cleaned the field!" %00
string_3:
        .data "boom! you've lost" %00

