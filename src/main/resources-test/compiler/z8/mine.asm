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
        ; cast t.1.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r0, r0
        rl   r0
        sbc  r0, r0
        sbc  r1, r1
        ; call printUint@i32[t.1.1{r0}]
        call printUint_Pi32
        ret

        ; i16 rowColumnToCell@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
rowColumnToCell_Pu8_Pu8:
        ; cast r.1{r2}(i16), param.row{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; cast c.1{r4}(i16), param.column{r1}(u8)
        ld   r5, r1
        ld   r4, #0
        ; 26:19 return r * 38 + c
        ; mul t.5.1{r2}, 38
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%26
        srp  #%10
        call %00BA ; mul
        srp  #%20
        ld   r2, %12
        ld   r3, %13
        ; move t.4.1{r0}, t.5.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.4.1{r0}, c.1{r4}
        add  r1, r5
        adc  r0, r4
        ret

        ; u8 getBombCountAround@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
getBombCountAround_Pu8_Pu8:
        ; call index.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; 31:22 return [...] & 15
        ; addrof t.5.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.5.2{r2}, index.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.4.1{r1}, [t.5.2{r2}]
        lde  r1, @rr2
        ; move t.3.1{r0}, t.4.1{r1}
        ld   r0, r1
        ; and t.3.1{r0}, 15
        and  r0, #%0f
        ret

        ; i16 columnToX@u8
        ; arg column (u8): r0
columnToX_Pu8:
        ; cast c.1{r2}(i16), param.column{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; 36:2 if true
        ; const t.2.1{r4}, 1
        ld   r4, #%01
        ; branch t.2.1{r4} notequals 0: if_1_then
        cp   r4, #%00
        jr   ne, if__1__then
        ; 40:17 return c + 1 << 1
        ; add t.4.1{r2}, 1
        incw r2
        ; move t.3.1{r0}, t.4.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; shiftleft t.3.1{r0}, 1
        rcf
        rlc  r1
        rlc  r0
        jr   columnToX_Pu8__ret

if__1__then:
        ; 37:10 return c
        ; move c.1{r0}, c.1{r2}
        ld   r0, r2
        ld   r1, r3
columnToX_Pu8__ret:
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
        ; call t.4.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.3.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.3.2{r10}, t.4.1{r0}
        add  r11, r1
        adc  r10, r0
        ; load cell.1{r0}, [t.3.2{r10}]
        lde  r0, @rr10
        ; move param.row{r1}, param.row{r8}
        ld   r1, r8
        ; move param.column{r2}, param.column{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell.1{r0}, param.row{r1}, param.column{r2}]
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
        ; call x.1{r0} = columnToX@u8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x.1{r2}, x.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; cast t.4.1{r0}(i16), param.row{r9}(u8)
        ld   r1, r9
        ld   r0, #0
        ; call setCursor@i16@i16[t.4.1{r0}, x.1{r2}]
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
        ; const chr.1{r8}, 46
        ld   r8, #%2e
        ; 56:2 if cell & 32 != 0
        ; move t.5.1{r9}, param.cell{r0}
        ld   r9, r0
        ; and t.5.1{r9}, 32
        and  r9, #%20
        ; branch t.5.1{r9} notequals 0: if_2_then
        cp   r9, #%00
        jr   ne, if__2__then
        ; 70:7 if cell & 64 != 0
        ; move t.7.1{r9}, param.cell{r0}
        ld   r9, r0
        ; and t.7.1{r9}, 64
        and  r9, #%40
        ; branch t.7.1{r9} equals 0: if_2_end, if_5_then
        cp   r9, #%00
        jr   eq, if__2__end
        jr   if__5__then

if__2__then:
        ; 57:3 if cell & 128 != 0
        ; move t.6.1{r8}, param.cell{r0}
        ld   r8, r0
        ; and t.6.1{r8}, 128
        and  r8, #%80
        ; branch t.6.1{r8} equals 0: if_3_else, if_3_then
        cp   r8, #%00
        jr   eq, if__3__else
        jr   if__3__then

if__5__then:
        ; const chr.3{r8}, 35
        ld   r8, #%23
        jr   if__2__end

if__3__else:
        ; move param.row{r0}, param.row{r1}
        ld   r0, r1
        ; move param.column{r1}, param.column{r2}
        ld   r1, r2
        ; call count.1{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; 62:4 if count > 0
        ; branch count.1{r0} lteq 0: if_4_else, if_4_then
        cp   r0, #%00
        jr   ule, if__4__else
        jr   if__4__then

if__3__then:
        ; const chr.4{r8}, 42
        ld   r8, #%2a
        jr   if__2__end

if__4__else:
        ; const chr.5{r8}, 32
        ld   r8, #%20
        jr   if__2__end

if__4__then:
        ; move chr.6{r8}, count.1{r0}
        ld   r8, r0
        ; add chr.6{r8}, 48
        add  r8, #%30
if__2__end:
        ; move chr.2{r0}, chr.2{r8}
        ld   r0, r8
        ; call printChar@u8[chr.2{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void initializeScreen
initializeScreen:
        ; const arg.0.0{r0}, 12
        ld   r0, #%0c
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; call printField[]
        call printField
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
        ; const row.1{r8}, 0
        ld   r8, #%00
        ; 89:2 for row < 20
        jr   for__6

for__6__body:
        ; cast t.3.1{r0}(i16), row.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; const arg.1.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[t.3.1{r0}, arg.1.1{r2}]
        call setCursor_Pi16_Pi16
        ; 91:3 if false
        ; const t.4.1{r9}, 0
        ld   r9, #%00
        ; branch t.4.1{r9} equals 0: if_7_end
        cp   r9, #%00
        jr   eq, if__7__end
        ; const arg.2.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
if__7__end:
        ; const column.1{r9}, 0
        ld   r9, #%00
        ; 94:3 for column < 38
        jr   for__8

for__8__body:
        ; 95:4 if false
        ; const t.5.1{r10}, 0
        ld   r10, #%00
        ; branch t.5.1{r10} equals 0: if_9_end
        cp   r10, #%00
        jr   eq, if__9__end
        ; const arg.3.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.3.0{r0}]
        call printChar_Pu8
if__9__end:
        ; move row.2{r0}, row.2{r8}
        ld   r0, r8
        ; move column.2{r1}, column.2{r9}
        ld   r1, r9
        ; call t.7.1{r0} = rowColumnToCell@u8@u8[row.2{r0}, column.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.6.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.6.2{r10}, t.7.1{r0}
        add  r11, r1
        adc  r10, r0
        ; load cell.1{r0}, [t.6.2{r10}]
        lde  r0, @rr10
        ; move row.2{r1}, row.2{r8}
        ld   r1, r8
        ; move column.2{r2}, column.2{r9}
        ld   r2, r9
        ; call printCell@u8@u8@u8[cell.1{r0}, row.2{r1}, column.2{r2}]
        call printCell_Pu8_Pu8_Pu8
        ; add column.4{r9}, 1
        inc  r9
for__8:
        ; branch column.2{r9} lt 38: for_8_body
        cp   r9, #%26
        jr   ult, for__8__body
        ; 101:3 if false
        ; const t.8.1{r9}, 0
        ld   r9, #%00
        ; branch t.8.1{r9} equals 0: for_6_continue
        cp   r9, #%00
        jr   eq, for__6__continue
        ; const t.9.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.9.1{r0}]
        call printString_P_Pu8
for__6__continue:
        ; move row.7{r0}, row.2{r8}
        ld   r0, r8
        ; add row.7{r0}, 1
        inc  r0
        ; move row.2{r8}, row.7{r0}
        ld   r8, r0
for__6:
        ; branch row.2{r8} lt 20: for_6_body
        cp   r8, #%14
        jr   ult, for__6__body
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
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; move param.show{r10}, show{r2}
        ld   r10, r2
        ; 108:2 if true
        ; const t.6.1{r11}, 1
        ld   r11, #%01
        ; branch t.6.1{r11} notequals 0: if_11_then
        cp   r11, #%00
        jr   ne, if__11__then
        ; move param.column{r0}, param.column{r9}
        ld   r0, r9
        ; call x.1{r0} = columnToX@u8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x.1{r11}, x.1{r0}
        ld   r12, r1
        ld   r11, r0
        ; cast t.8.1{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; move t.9.1{r2}, x.1{r11}
        ld   r2, r11
        ld   r3, r12
        ; sub t.9.1{r2}, 1
        decw r2
        ; call setCursor@i16@i16[t.8.1{r0}, t.9.1{r2}]
        call setCursor_Pi16_Pi16
        ; const chr.1{r9}, 32
        ld   r9, #%20
        ; 119:2 if show
        ; branch param.show{r10} equals 0: if_13_end, if_13_then
        cp   r10, #%00
        jr   eq, if__13__end
        jr   if__13__then

if__11__then:
        ; branch param.show{r10} equals 0: showCursor@u8@u8@bool_ret, if_12_then
        cp   r10, #%00
        jr   eq, showCursor_Pu8_Pu8_Pbool__ret
        jr   if__12__then

if__13__then:
        ; const chr.3{r9}, 91
        ld   r9, #%5b
        jr   if__13__end

if__12__then:
        ; move param.column{r0}, param.column{r9}
        ld   r0, r9
        ; call x.3{r0} = columnToX@u8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x.3{r2}, x.3{r0}
        ld   r3, r1
        ld   r2, r0
        ; cast t.7.1{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; call setCursor@i16@i16[t.7.1{r0}, x.3{r2}]
        call setCursor_Pi16_Pi16
        jr   showCursor_Pu8_Pu8_Pbool__ret

if__13__end:
        ; move chr.2{r0}, chr.2{r9}
        ld   r0, r9
        ; call printChar@u8[chr.2{r0}]
        call printChar_Pu8
        ; cast t.10.1{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; move t.11.1{r2}, x.1{r11}
        ld   r2, r11
        ld   r3, r12
        ; add t.11.1{r2}, 1
        incw r2
        ; call setCursor@i16@i16[t.10.1{r0}, t.11.1{r2}]
        call setCursor_Pi16_Pi16
        ; 125:2 if show
        ; branch param.show{r10} notequals 0: if_14_then
        cp   r10, #%00
        jr   ne, if__14__then
        ; move chr.4{r0}, chr.2{r9}
        ld   r0, r9
        jr   if__14__end

if__14__then:
        ; const chr.5{r8}, 93
        ld   r8, #%5d
        ; move chr.4{r0}, chr.5{r8}
        ld   r0, r8
if__14__end:
        ; call printChar@u8[chr.4{r0}]
        call printChar_Pu8
showCursor_Pu8_Pu8_Pbool__ret:
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
        ; move i.1{r8}, param.i{r0}
        ld   r9, r1
        ld   r8, r0
        jr   for__15

for__15__body:
        ; const arg.0.0{r0}, 48
        ld   r0, #%30
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; move i.2{r0}, i.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; sub i.2{r0}, 1
        decw r0
        ; move i.1{r8}, i.2{r0}
        ld   r9, r1
        ld   r8, r0
for__15:
        ; branch i.1{r8} gt 0: for_15_body
        cp   r8, #%00
        jr   gt, for__15__body
        jr   ne, .gt1
        cp   r9, #%00
        jr   ugt, for__15__body
.gt1:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; u8 getDigitCount@i16
        ; arg value (i16): r0
getDigitCount_Pi16:
        ; const count.1{r2}, 0
        ld   r2, #%00
        ; 139:2 if value < 0
        ; branch param.value{r0} lt 0: if_16_then
        cp   r0, #%00
        jr   lt, if__16__then
        jr   ne, .lt2
        cp   r1, #%00
        jr   ult, if__16__then
.lt2:
        ; move value.1{r3}, param.value{r0}
        ld   r4, r1
        ld   r3, r0
        ; move count.2{r1}, count.1{r2}
        ld   r1, r2
        jr   if__16__end

if__16__then:
        ; const count.3{r2}, 1
        ld   r2, #%01
        ; neg value.2{r3}, param.value{r0}
        ld   r3, #%00
        ld   r4, #%00
        sub  r4, r1
        sbc  r3, r0
        ; move count.2{r1}, count.3{r2}
        ld   r1, r2
if__16__end:
        ; move value.3{r2}, value.1{r3}
        ld   r2, r3
        ld   r3, r4
        jr   while__17

getDigitCount_Pi16_2eno__critical__edge__7:
        ; move value.3{r2}, value.4{r1}
        ld   r3, r2
        ld   r2, r1
        ; move count.4{r1}, count.5{r0}
        ld   r1, r0
while__17:
        ; move count.5{r0}, count.4{r1}
        ld   r0, r1
        ; add count.5{r0}, 1
        inc  r0
        ; move value.4{r1}, value.3{r2}
        ld   r1, r2
        ld   r2, r3
        ; div value.4{r1}, 10
        ld   %12, r1
        ld   %13, r2
        ld   %14, #%00
        ld   %15, #%0a
        srp  #%10
        call %00E0 ; div
        srp  #%20
        ld   r1, %12
        ld   r2, %13
        ; 147:3 if value == 0
        ; branch value.4{r1} notequals 0: getDigitCount@i16.no_critical_edge_7
        cp   r2, #%00
        jr   ne, getDigitCount_Pi16_2eno__critical__edge__7
        cp   r1, #%00
        jr   ne, getDigitCount_Pi16_2eno__critical__edge__7
        ; 152:9 return count
        ret

        ; i16 getHiddenCount
getHiddenCount:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const count.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; const r.1{r10}, 0
        ld   r10, #%00
        ; 157:2 for r < 20
        jr   for__19

for__19__body:
        ; const c.1{r11}, 0
        ld   r11, #%00
        ; 158:3 for c < 38
        jr   for__20

for__20__body:
        ; move r.2{r0}, r.2{r10}
        ld   r0, r10
        ; move c.2{r1}, c.2{r11}
        ld   r1, r11
        ; call t.5.1{r0} = rowColumnToCell@u8@u8[r.2{r0}, c.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.4.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.4.2{r2}, t.5.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load cell.1{r4}, [t.4.2{r2}]
        lde  r4, @rr2
        ; 160:4 if cell & 96 == 0
        ; move t.6.1{r2}, cell.1{r4}
        ld   r2, r4
        ; and t.6.1{r2}, 96
        and  r2, #%60
        ; branch t.6.1{r2} equals 0: if_21_then
        cp   r2, #%00
        jr   eq, if__21__then
        ; move count.4{r2}, count.3{r8}
        ld   r2, r8
        ld   r3, r9
        jr   for__20__continue

if__21__then:
        ; move count.5{r2}, count.3{r8}
        ld   r2, r8
        ld   r3, r9
        ; add count.5{r2}, 1
        incw r2
for__20__continue:
        ; move c.4{r4}, c.2{r11}
        ld   r4, r11
        ; add c.4{r4}, 1
        inc  r4
        ; move count.3{r8}, count.4{r2}
        ld   r9, r3
        ld   r8, r2
        ; move c.2{r11}, c.4{r4}
        ld   r11, r4
for__20:
        ; branch c.2{r11} lt 38: for_20_body
        cp   r11, #%26
        jr   ult, for__20__body
        ; move r.4{r2}, r.2{r10}
        ld   r2, r10
        ; add r.4{r2}, 1
        inc  r2
        ; move r.2{r10}, r.4{r2}
        ld   r10, r2
for__19:
        ; branch r.2{r10} lt 20: for_19_body
        cp   r10, #%14
        jr   ult, for__19__body
        ; 165:9 return count
        ; move count.2{r0}, count.2{r8}
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
        ; call count.1{r0} = getHiddenCount[] -> i16
        call getHiddenCount
        ; move count.1{r8}, count.1{r0}
        ld   r9, r1
        ld   r8, r0
        ; call t.3.1{r0} = getDigitCount@i16[count.1{r0}] -> u8
        call getDigitCount_Pi16
        ; cast leftDigits.1{r10}(i16), t.3.1{r0}(u8)
        ld   r11, r0
        ld   r10, #0
        ; const arg.2.0{r0}, 68
        ld   r0, #%00
        ld   r1, #%44
        ; call t.4.1{r0} = getDigitCount@i16[arg.2.0{r0}] -> u8
        call getDigitCount_Pi16
        ; cast bombDigits.1{r12}(i16), t.4.1{r0}(u8)
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
        ; move t.5.1{r0}, bombDigits.1{r12}
        ld   r0, r12
        ld   r1, r13
        ; sub t.5.1{r0}, leftDigits.1{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call printSpaces@i16[t.5.1{r0}]
        call printSpaces_Pi16
        ; move count.1{r0}, count.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint@i16[count.1{r0}]
        call printUint_Pi16
        ; 176:15 return count == 0
        ; equals t.6.1{r0}, count.1{r8}, 0
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
        ; branch param.a{r2} lt 0: if_22_then
        cp   r2, #%00
        jr   lt, if__22__then
        jr   ne, .lt4
        cp   r3, #%00
        jr   ult, if__22__then
.lt4:
        ; 183:9 return a
        jr   abs_Pi16__ret

if__22__then:
        ; 181:10 return -a
        ; neg t.1.1{r2}, param.a{r2}
        com  r2
        com  r3
        incw r2
        ; move t.1.1{r0}, t.1.1{r2}
        ld   r0, r2
        ld   r1, r3
abs_Pi16__ret:
        ret

        ; void clearField
clearField:
        ; const index.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const i.1{r2}, 760
        ld   r2, #%02
        ld   r3, #%f8
        ; 188:2 for i > 0
        jr   for__23

for__23__body:
        ; const t.2.1{r4}, 0
        ld   r4, #%00
        ; addrof t.3.1{r6}, field
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.3.2{r6}, index.2{r0}
        add  r7, r1
        adc  r6, r0
        ; store [t.3.2{r6}], t.2.1{r4}
        lde  @rr6, r4
        ; sub i.3{r2}, 1
        decw r2
        ; add index.3{r0}, 1
        incw r0
for__23:
        ; branch i.2{r2} gt 0: for_23_body
        cp   r2, #%00
        jr   gt, for__23__body
        jr   ne, .gt5
        cp   r3, #%00
        jr   ugt, for__23__body
.gt5:
        ret

        ; void initField@u8@u8
        ; arg curr_r (u8): r0
        ; arg curr_c (u8): r1
        ; var row.1 (i16): SP+8
        ; var column.1 (i16): SP+10
initField_Pu8_Pu8:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%04
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
        ; cast r.1{r8}(i16), param.curr_r{r0}(u8)
        ld   r9, r0
        ld   r8, #0
        ; cast c.1{r10}(i16), param.curr_c{r1}(u8)
        ld   r11, r1
        ld   r10, #0
        ; const bombs.1{r12}, 68
        ld   r12, #%00
        ld   r13, #%44
        ; 196:2 for bombs > 0
        jr   for__24

for__24__body:
        ; call t.7.1{r0} = random16[] -> i16
        call random16
        ; mod row.1{r0}, 20
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], row.1{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; call t.8.1{r0} = random16[] -> i16
        call random16
        ; move column.1{r2}, t.8.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; mod column.1{r2}, 38
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%26
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r2, %12
        ld   r3, %13
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], column.1{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; 199:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=199:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=199:20], location=199:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=200:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=200:20], location=200:18]]) > 1
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move t.10.1{r0}, row.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; sub t.10.1{r0}, r.1{r8}
        sub  r1, r9
        sbc  r0, r8
        ; call t.9.1{r0} = abs@i16[t.10.1{r0}] -> i16
        call abs_Pi16
        ; branch t.9.1{r0} gt 1: if_25_then
        cp   r0, #%00
        jr   gt, if__25__then
        jr   ne, .gt6
        cp   r1, #%01
        jr   ugt, if__25__then
.gt6:
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move t.12.1{r0}, column.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; sub t.12.1{r0}, c.1{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call t.11.1{r0} = abs@i16[t.12.1{r0}] -> i16
        call abs_Pi16
        ; branch t.11.1{r0} lteq 1: for_24_continue, if_25_then
        cp   r0, #%00
        jr   lt, for__24__continue
        jr   ne, .lt7
        cp   r1, #%01
        jr   ule, for__24__continue
.lt7:
if__25__then:
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; cast t.13.1{r0}(u8), row.1{r2}(i16)
        ld   r0, r3
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; cast t.14.1{r1}(u8), column.1{r2}(i16)
        ld   r1, r3
        ; call setBomb@u8@u8[t.13.1{r0}, t.14.1{r1}]
        call setBomb_Pu8_Pu8
for__24__continue:
        ; move bombs.5{r0}, bombs.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; sub bombs.5{r0}, 1
        decw r0
        ; move bombs.2{r12}, bombs.5{r0}
        ld   r13, r1
        ld   r12, r0
for__24:
        ; branch bombs.2{r12} gt 0: for_24_body
        cp   r12, #%00
        jr   gt, for__24__body
        jr   ne, .gt8
        cp   r13, #%00
        jr   ugt, for__24__body
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
        add  %31, #%04
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void setBomb@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
setBomb_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; call index.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; 208:2 if [...] == 128
        ; addrof t.13.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.13.2{r2}, index.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.12.1{r4}, [t.13.2{r2}]
        lde  r4, @rr2
        ; branch t.12.1{r4} equals 128: setBomb@u8@u8_ret
        cp   r4, #%80
        jr   eq, setBomb_Pu8_Pu8__ret
        ; const t.14.1{r2}, 128
        ld   r2, #%80
        ; addrof t.15.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.15.2{r4}, index.1{r0}
        add  r5, r1
        adc  r4, r0
        ; store [t.15.2{r4}], t.14.1{r2}
        lde  @rr4, r2
        ; move rowFrom.1{r2}, param.row{r8}
        ld   r2, r8
        ; 214:2 if rowFrom > 0
        ; branch rowFrom.1{r2} lteq 0: if_28_end
        cp   r2, #%00
        jr   ule, if__28__end
        ; sub rowFrom.3{r2}, 1
        dec  r2
        ; sub index.3{r0}, 38
        sub  r1, #%26
        sbc  r0, #%00
if__28__end:
        ; move rowTo.1{r3}, param.row{r8}
        ld   r3, r8
        ; add rowTo.1{r3}, 1
        inc  r3
        ; 219:2 if rowTo >= 20
        ; branch rowTo.1{r3} lt 20: if_29_end
        cp   r3, #%14
        jr   ult, if__29__end
        ; sub rowTo.3{r3}, 1
        dec  r3
if__29__end:
        ; move colFrom.1{r4}, param.column{r9}
        ld   r4, r9
        ; 224:2 if colFrom > 0
        ; branch colFrom.1{r4} lteq 0: if_30_end
        cp   r4, #%00
        jr   ule, if__30__end
        ; sub colFrom.3{r4}, 1
        dec  r4
        ; sub index.6{r0}, 1
        decw r0
if__30__end:
        ; move colTo.1{r5}, param.column{r9}
        ld   r5, r9
        ; add colTo.1{r5}, 1
        inc  r5
        ; 229:2 if colTo >= 38
        ; branch colTo.1{r5} lt 38: if_31_end
        cp   r5, #%26
        jr   ult, if__31__end
        ; sub colTo.3{r5}, 1
        dec  r5
if__31__end:
        ; 234:2 for r <= rowTo
        jr   for__32

for__32__body:
        ; move c.1{r6}, colFrom.2{r4}
        ld   r6, r4
        ; 235:3 for c <= colTo
        jr   for__33

for__33__body:
        ; branch r.2{r2} notequals param.row{r8}: if_34_end
        cp   r2, r8
        jr   ne, if__34__end
        ; branch c.2{r6} equals param.column{r9}: for_33_continue, if_34_end
        cp   r6, r9
        jr   eq, for__33__continue
if__34__end:
        ; addrof t.16.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.16.2{r10}, index.9{r0}
        add  r11, r1
        adc  r10, r0
        ; load cell.1{r7}, [t.16.2{r10}]
        lde  r7, @rr10
        ; 241:4 if cell & 128 == 0
        ; move t.17.1{r10}, cell.1{r7}
        ld   r10, r7
        ; and t.17.1{r10}, 128
        and  r10, #%80
        ; branch t.17.1{r10} notequals 0: for_33_continue
        cp   r10, #%00
        jr   ne, for__33__continue
        ; and count.2{r7}, 15
        and  r7, #%0f
        ; add count.3{r7}, 1
        inc  r7
        ; addrof t.18.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.18.2{r10}, index.9{r0}
        add  r11, r1
        adc  r10, r0
        ; store [t.18.2{r10}], count.3{r7}
        lde  @rr10, r7
for__33__continue:
        ; add c.5{r6}, 1
        inc  r6
        ; add index.13{r0}, 1
        incw r0
for__33:
        ; branch c.2{r6} lteq colTo.2{r5}: for_33_body
        cp   r6, r5
        jr   ule, for__33__body
        ; cast t.22.1{r6}(i16), colTo.2{r5}(u8)
        ld   r7, r5
        ld   r6, #0
        ; sub t.21.1{r0}, t.22.1{r6}
        sub  r1, r7
        sbc  r0, r6
        ; cast t.23.1{r6}(i16), colFrom.2{r4}(u8)
        ld   r7, r4
        ld   r6, #0
        ; add t.20.1{r0}, t.23.1{r6}
        add  r1, r7
        adc  r0, r6
        ; add t.19.1{r0}, 38
        add  r1, #%26
        adc  r0, #%00
        ; sub index.10{r0}, 1
        decw r0
        ; add r.4{r2}, 1
        inc  r2
for__32:
        ; branch r.2{r2} lteq rowTo.2{r3}: for_32_body, setBomb@u8@u8_ret
        cp   r2, r3
        jr   ule, for__32__body
setBomb_Pu8_Pu8__ret:
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void maybeRevealAround@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
maybeRevealAround_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; call printCellAt@u8@u8[param.row{r0}, param.column{r1}]
        call printCellAt_Pu8_Pu8
        ; 253:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=253:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=253:30]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call t.10.1{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.10.1{r0} notequals 0: maybeRevealAround@u8@u8_ret
        cp   r0, #%00
        jr   ne, maybeRevealAround_Pu8_Pu8__ret
        ; const changed.1{r8}, 1
        ld   r8, #%01
        ; 258:2 while changed
        jr   while__38

while__38__body:
        ; const changed.3{r8}, 0
        ld   r8, #%00
        ; const index.1{r9}, 0
        ld   r9, #%00
        ld   r10, #%00
        ; const r.1{r11}, 0
        ld   r11, #%00
        ; 262:3 for r < 20
        jr   for__39

for__39__body:
        ; const c.1{r12}, 0
        ld   r12, #%00
        ; 263:4 for c < 38
        jr   for__40

for__40__body:
        ; addrof t.11.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.11.2{r2}, index.3{r9}
        add  r3, r10
        adc  r2, r9
        ; load cell.1{r13}, [t.11.2{r2}]
        lde  r13, @rr2
        ; 265:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.12.1{r2}, cell.1{r13}
        ld   r2, r13
        ; and t.12.1{r2}, 32
        and  r2, #%20
        ; branch t.12.1{r2} equals 0: for_40_continue
        cp   r2, #%00
        jr   eq, for__40__continue
        ; and t.13.1{r13}, 128
        and  r13, #%80
        ; branch t.13.1{r13} notequals 0: for_40_continue
        cp   r13, #%00
        jr   ne, for__40__continue
        ; 268:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=268:28], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=268:31]]) != 0
        ; move r.2{r0}, r.2{r11}
        ld   r0, r11
        ; move c.2{r1}, c.2{r12}
        ld   r1, r12
        ; call t.14.1{r0} = getBombCountAround@u8@u8[r.2{r0}, c.2{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.14.1{r0} notequals 0: for_40_continue
        cp   r0, #%00
        jr   ne, for__40__continue
        ; 272:5 if revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=272:24], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=272:27]])
        ; move r.2{r0}, r.2{r11}
        ld   r0, r11
        ; move c.2{r1}, c.2{r12}
        ld   r1, r12
        ; call t.15.1{r0} = revealNeighbors@u8@u8[r.2{r0}, c.2{r1}] -> bool
        call revealNeighbors_Pu8_Pu8
        ; branch t.15.1{r0} equals 0: for_40_continue
        cp   r0, #%00
        jr   eq, for__40__continue
        ; const changed.9{r8}, 1
        ld   r8, #%01
for__40__continue:
        ; add c.6{r12}, 1
        inc  r12
        ; add index.7{r9}, 1
        add  r10, #%01
        adc  r9, #%00
for__40:
        ; branch c.2{r12} lt 38: for_40_body
        cp   r12, #%26
        jr   ult, for__40__body
        ; add r.6{r11}, 1
        inc  r11
for__39:
        ; branch r.2{r11} lt 20: for_39_body
        cp   r11, #%14
        jr   ult, for__39__body
        ; branch changed.4{r8} equals 0: maybeRevealAround@u8@u8_ret
        cp   r8, #%00
        jr   eq, maybeRevealAround_Pu8_Pu8__ret
        ; const r.4{r11}, 20
        ld   r11, #%14
        ; 283:3 while true
        jr   while__46

if__47__end:
        ; sub r.7{r11}, 1
        dec  r11
        ; const c.3{r12}, 38
        ld   r12, #%26
        ; 290:4 while true
        jr   while__48

if__49__end:
        ; sub c.7{r12}, 1
        dec  r12
        ; sub index.8{r9}, 1
        sub  r10, #%01
        sbc  r9, #%00
        ; addrof t.16.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.16.2{r2}, index.8{r9}
        add  r3, r10
        adc  r2, r9
        ; load cell.2{r13}, [t.16.2{r2}]
        lde  r13, @rr2
        ; 297:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.17.1{r2}, cell.2{r13}
        ld   r2, r13
        ; and t.17.1{r2}, 32
        and  r2, #%20
        ; branch t.17.1{r2} equals 0: while_48
        cp   r2, #%00
        jr   eq, while__48
        ; and t.18.1{r13}, 128
        and  r13, #%80
        ; branch t.18.1{r13} notequals 0: while_48
        cp   r13, #%00
        jr   ne, while__48
        ; 300:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=7, scope=function, type=u8, varIsArray=false, location=300:28], ExprVarAccess[varName=c, index=8, scope=function, type=u8, varIsArray=false, location=300:31]]) != 0
        ; move r.7{r0}, r.7{r11}
        ld   r0, r11
        ; move c.7{r1}, c.7{r12}
        ld   r1, r12
        ; call t.19.1{r0} = getBombCountAround@u8@u8[r.7{r0}, c.7{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.19.1{r0} notequals 0: while_48
        cp   r0, #%00
        jr   ne, while__48
        ; 304:5 if revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=7, scope=function, type=u8, varIsArray=false, location=304:24], ExprVarAccess[varName=c, index=8, scope=function, type=u8, varIsArray=false, location=304:27]])
        ; move r.7{r0}, r.7{r11}
        ld   r0, r11
        ; move c.7{r1}, c.7{r12}
        ld   r1, r12
        ; call t.20.1{r0} = revealNeighbors@u8@u8[r.7{r0}, c.7{r1}] -> bool
        call revealNeighbors_Pu8_Pu8
        ; branch t.20.1{r0} equals 0: while_48
        cp   r0, #%00
        jr   eq, while__48
        ; const changed.10{r0}, 1
        ld   r0, #%01
        ; move changed.7{r8}, changed.10{r0}
        ld   r8, r0
while__48:
        ; branch c.4{r12} notequals 0: if_49_end, while_46
        cp   r12, #%00
        jr   ne, if__49__end
while__46:
        ; branch r.5{r11} notequals 0: if_47_end, while_38
        cp   r11, #%00
        jr   ne, if__47__end
while__38:
        ; branch changed.2{r8} notequals 0: while_38_body, maybeRevealAround@u8@u8_ret
        cp   r8, #%00
        jr   ne, while__38__body
maybeRevealAround_Pu8_Pu8__ret:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; bool revealNeighbors@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; var index.3 (i16): SP+8
revealNeighbors_Pu8_Pu8:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%02
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
        ; move rowFrom.1{r8}, param.row{r0}
        ld   r8, r0
        ; 314:2 if rowFrom > 0
        ; branch rowFrom.1{r8} lteq 0: if_54_end
        cp   r8, #%00
        jr   ule, if__54__end
        ; sub rowFrom.3{r8}, 1
        dec  r8
if__54__end:
        ; move rowTo.1{r9}, param.row{r0}
        ld   r9, r0
        ; add rowTo.1{r9}, 1
        inc  r9
        ; 318:2 if rowTo >= 20
        ; branch rowTo.1{r9} lt 20: if_55_end
        cp   r9, #%14
        jr   ult, if__55__end
        ; sub rowTo.3{r9}, 1
        dec  r9
if__55__end:
        ; move colFrom.1{r10}, param.column{r1}
        ld   r10, r1
        ; 323:2 if colFrom > 0
        ; branch colFrom.1{r10} lteq 0: if_56_end
        cp   r10, #%00
        jr   ule, if__56__end
        ; sub colFrom.3{r10}, 1
        dec  r10
if__56__end:
        ; move colTo.1{r11}, param.column{r1}
        ld   r11, r1
        ; add colTo.1{r11}, 1
        inc  r11
        ; 327:2 if colTo >= 38
        ; branch colTo.1{r11} lt 38: if_57_end
        cp   r11, #%26
        jr   ult, if__57__end
        ; sub colTo.3{r11}, 1
        dec  r11
if__57__end:
        ; move rowFrom.2{r0}, rowFrom.2{r8}
        ld   r0, r8
        ; move colFrom.2{r1}, colFrom.2{r10}
        ld   r1, r10
        ; call index.1{r0} = rowColumnToCell@u8@u8[rowFrom.2{r0}, colFrom.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; const changed.1{r12}, 0
        ld   r12, #%00
        ; 332:2 for r <= rowTo
        ; move index.2{r3}, index.1{r0}
        ld   r4, r1
        ld   r3, r0
        ; move index.2{r1}, index.2{r3}
        ld   r1, r3
        ld   r2, r4
        jr   for__58

for__58__body:
        ; move index.2{r3}, index.2{r1}
        ld   r4, r2
        ld   r3, r1
        ; move c.1{r13}, colFrom.2{r10}
        ld   r13, r10
        ; 333:3 for c <= colTo
        ; move index.3{r2}, index.3{r3}
        ld   r2, r3
        ld   r3, r4
        jr   for__59

for__59__body:
        ; move index.3{r3}, index.3{r2}
        ld   r4, r3
        ld   r3, r2
        ; addrof t.11.1{r6}, field
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.11.2{r6}, index.3{r3}
        add  r7, r4
        adc  r6, r3
        ; load cell.1{r5}, [t.11.2{r6}]
        lde  r5, @rr6
        ; 335:4 if cell & 32 != 0
        ; move t.12.1{r6}, cell.1{r5}
        ld   r6, r5
        ; and t.12.1{r6}, 32
        and  r6, #%20
        ; branch t.12.1{r6} equals 0: if_60_end
        cp   r6, #%00
        jr   eq, if__60__end
        ; addrof memVarAddr{r14}, index.3
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], index.3{r3}
        lde  @rr14, r3
        incw r14
        lde  @rr14, r4
        decw r14
        jr   for__59__continue

if__60__end:
        ; move cell.2{r0}, cell.1{r5}
        ld   r0, r5
        ; or cell.2{r0}, 32
        or  r0, #%20
        ; addrof t.13.1{r6}, field
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.13.2{r6}, index.3{r3}
        add  r7, r4
        adc  r6, r3
        ; addrof memVarAddr{r14}, index.3
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], index.3{r3}
        lde  @rr14, r3
        incw r14
        lde  @rr14, r4
        decw r14
        ; store [t.13.2{r6}], cell.2{r0}
        lde  @rr6, r0
        ; move r.2{r1}, r.2{r8}
        ld   r1, r8
        ; move c.2{r2}, c.2{r13}
        ld   r2, r13
        ; call printCellAt@u8@u8@u8[cell.2{r0}, r.2{r1}, c.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
        ; const changed.5{r1}, 1
        ld   r1, #%01
        ; move changed.4{r12}, changed.5{r1}
        ld   r12, r1
for__59__continue:
        ; move c.4{r1}, c.2{r13}
        ld   r1, r13
        ; add c.4{r1}, 1
        inc  r1
        ; addrof memVarAddr{r14}, index.3
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load index.3{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; add index.6{r2}, 1
        incw r2
        ; move c.2{r13}, c.4{r1}
        ld   r13, r1
for__59:
        ; branch c.2{r13} lteq colTo.2{r11}: for_59_body
        cp   r13, r11
        jr   ule, for__59__body
        ; cast t.17.1{r4}(i16), colTo.2{r11}(u8)
        ld   r5, r11
        ld   r4, #0
        ; move t.16.1{r1}, index.3{r2}
        ld   r1, r2
        ld   r2, r3
        ; sub t.16.1{r1}, t.17.1{r4}
        sub  r2, r5
        sbc  r1, r4
        ; cast t.18.1{r3}(i16), colFrom.2{r10}(u8)
        ld   r4, r10
        ld   r3, #0
        ; add t.15.1{r1}, t.18.1{r3}
        add  r2, r4
        adc  r1, r3
        ; add t.14.1{r1}, 38
        add  r2, #%26
        adc  r1, #%00
        ; sub index.4{r1}, 1
        sub  r2, #%01
        sbc  r1, #%00
        ; move r.4{r3}, r.2{r8}
        ld   r3, r8
        ; add r.4{r3}, 1
        inc  r3
        ; move r.2{r8}, r.4{r3}
        ld   r8, r3
for__58:
        ; branch r.2{r8} lteq rowTo.2{r9}: for_58_body
        cp   r8, r9
        jr   ule, for__58__body
        ; 346:9 return changed
        ; move changed.2{r0}, changed.2{r12}
        ld   r0, r12
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
        add  %31, #%02
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
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom@i32[arg.0.0{r0}]
        call initRandom_Pi32
        ; const needsInitialize.1{r8}, 1
        ld   r8, #%01
        ; call clearField[]
        call clearField
        ; call initializeScreen[]
        call initializeScreen
        ; const arg.3.0{r0}, 20
        ld   r0, #%00
        ld   r1, #%14
        ; const arg.3.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.3.0{r0}, arg.3.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.8.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.8.1{r0}]
        call printString_P_Pu8
        ; const curr_c.1{r9}, 19
        ld   r9, #%13
        ; const curr_r.1{r10}, 10
        ld   r10, #%0a
        ; 358:2 while true
        jr   while__61

if__62__then:
        ; 360:4 if printLeft([])
        ; call t.9.1{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.9.1{r0} notequals 0: if_63_then, if_62_end
        cp   r0, #%00
        jr   ne, if__63__then
if__62__end:
        ; const t.11.1{r2}, 1
        ld   r2, #%01
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r.2{r0}, curr_c.2{r1}, t.11.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; call chr.1{r0} = getChar[] -> i16
        call getChar
        ; move chr.1{r11}, chr.1{r0}
        ld   r12, r1
        ld   r11, r0
        ; const t.12.1{r2}, 0
        ld   r2, #%00
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r.2{r0}, curr_c.2{r1}, t.12.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; 369:3 if chr == 27
        ; branch chr.1{r11} equals 27: main_ret
        cp   r12, #%1b
        jr   ne, .notEquals9
        cp   r11, #%00
        jr   eq, main__ret
.notEquals9:
        ; branch chr.1{r11} equals 13: if_65_then
        cp   r12, #%0d
        jr   ne, .notEquals10
        cp   r11, #%00
        jr   eq, if__65__then
.notEquals10:
        ; branch chr.1{r11} notequals 3: if_69_else, if_69_then
        cp   r12, #%03
        jr   ne, if__69__else
        cp   r11, #%00
        jr   ne, if__69__else
        jr   if__69__then

if__65__then:
        ; branch needsInitialize.2{r8} equals 0: if_66_end, if_66_then
        cp   r8, #%00
        jr   eq, if__66__end
        jr   if__66__then

if__69__else:
        ; branch chr.1{r11} notequals 4: if_71_else, if_71_then
        cp   r12, #%04
        jr   ne, if__71__else
        cp   r11, #%00
        jr   ne, if__71__else
        jr   if__71__then

if__69__then:
        ; branch curr_r.2{r10} lteq 0: while_61, if_70_then
        cp   r10, #%00
        jr   ule, while__61
        jr   if__70__then

if__66__then:
        ; const needsInitialize.5{r8}, 0
        ld   r8, #%00
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call initField@u8@u8[curr_r.2{r0}, curr_c.2{r1}]
        call initField_Pu8_Pu8
        jr   if__66__end

if__71__else:
        ; branch chr.1{r11} notequals 1: if_73_else, if_73_then
        cp   r12, #%01
        jr   ne, if__73__else
        cp   r11, #%00
        jr   ne, if__73__else
        jr   if__73__then

if__71__then:
        ; branch curr_r.2{r10} gteq 19: while_61, if_72_then
        cp   r10, #%13
        jr   uge, while__61
        jr   if__72__then

if__70__then:
        ; sub curr_r.5{r10}, 1
        dec  r10
        jr   while__61

if__66__end:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call index.1{r0} = rowColumnToCell@u8@u8[curr_r.2{r0}, curr_c.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.13.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.13.2{r12}, index.1{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell.1{r11}, [t.13.2{r12}]
        lde  r11, @rr12
        ; 380:4 if cell & 32 == 0
        ; move t.14.1{r12}, cell.1{r11}
        ld   r12, r11
        ; and t.14.1{r12}, 32
        and  r12, #%20
        ; branch t.14.1{r12} notequals 0: if_67_end, if_67_then
        cp   r12, #%00
        jr   ne, if__67__end
        jr   if__67__then

if__73__else:
        ; branch chr.1{r11} notequals 2: if_75_else, if_75_then
        cp   r12, #%02
        jr   ne, if__75__else
        cp   r11, #%00
        jr   ne, if__75__else
        jr   if__75__then

if__73__then:
        ; branch curr_c.2{r9} lteq 0: while_61, if_74_then
        cp   r9, #%00
        jr   ule, while__61
        jr   if__74__then

if__72__then:
        ; add curr_r.6{r10}, 1
        inc  r10
        jr   while__61

if__67__then:
        ; move t.15.1{r12}, cell.1{r11}
        ld   r12, r11
        ; or t.15.1{r12}, 32
        or  r12, #%20
        ; addrof t.16.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.16.2{r2}, index.1{r0}
        add  r3, r1
        adc  r2, r0
        ; store [t.16.2{r2}], t.15.1{r12}
        lde  @rr2, r12
        jr   if__67__end

if__75__else:
        ; branch chr.1{r11} notequals 32: while_61, if_77_then
        cp   r12, #%20
        jr   ne, while__61
        cp   r11, #%00
        jr   ne, while__61
        jr   if__77__then

if__75__then:
        ; branch curr_c.2{r9} gteq 37: while_61, if_76_then
        cp   r9, #%25
        jr   uge, while__61
        jr   if__76__then

if__74__then:
        ; sub curr_c.6{r9}, 1
        dec  r9
        jr   while__61

if__67__end:
        ; 383:4 if cell & 128 != 0
        ; and t.17.1{r11}, 128
        and  r11, #%80
        ; branch t.17.1{r11} equals 0: if_68_end, if_68_then
        cp   r11, #%00
        jr   eq, if__68__end
        jr   if__68__then

if__77__then:
        ; branch needsInitialize.2{r8} notequals 0: while_61, if_78_then
        cp   r8, #%00
        jr   ne, while__61
        jr   if__78__then

if__76__then:
        ; add curr_c.7{r9}, 1
        inc  r9
        jr   while__61

if__68__end:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call maybeRevealAround@u8@u8[curr_r.2{r0}, curr_c.2{r1}]
        call maybeRevealAround_Pu8_Pu8
        jr   while__61

if__78__then:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call index.2{r0} = rowColumnToCell@u8@u8[curr_r.2{r0}, curr_c.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.19.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.19.2{r12}, index.2{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell.3{r11}, [t.19.2{r12}]
        lde  r11, @rr12
        ; 419:5 if cell & 32 == 0
        ; move t.20.1{r12}, cell.3{r11}
        ld   r12, r11
        ; and t.20.1{r12}, 32
        and  r12, #%20
        ; branch t.20.1{r12} notequals 0: while_61
        cp   r12, #%00
        jr   ne, while__61
        ; xor cell.4{r11}, 64
        xor r11, #%40
        ; addrof t.21.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.21.2{r12}, index.2{r0}
        add  r13, r1
        adc  r12, r0
        ; store [t.21.2{r12}], cell.4{r11}
        lde  @rr12, r11
        ; move cell.4{r0}, cell.4{r11}
        ld   r0, r11
        ; move curr_r.2{r1}, curr_r.2{r10}
        ld   r1, r10
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell.4{r0}, curr_r.2{r1}, curr_c.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
while__61:
        ; branch needsInitialize.2{r8} notequals 0: if_62_end, if_62_then
        cp   r8, #%00
        jr   ne, if__62__end
        jr   if__62__then

if__63__then:
        ; const t.10.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.10.1{r0}]
        call printString_P_Pu8
        jr   main__ret

if__68__then:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call printCellAt@u8@u8[curr_r.2{r0}, curr_c.2{r1}]
        call printCellAt_Pu8_Pu8
        ; const t.18.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.18.1{r0}]
        call printString_P_Pu8
main__ret:
        ; restore clobbered non-volatile registers
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
        ld   %74, r0
        ld   %75, r1
        ld   %76, r2
        ld   %77, r3
        ld   r0, #%F7
        ld   r1, #%A8
        ld   r2, #%74
        ld   r3, #4
.1:
        ldei @rr0, @r2
        djnz r3, .1
        ret

        ; i16 random16
random16:
        call %0836
        ld   r0, %74
        ld   r1, %75
        and  r0, #%7f
        ret

        ; variable 0: field[] (u8*/1520)
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
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00

string_0:
        .data " |" %00
string_1:
        .data "Left:" %00
string_2:
        .data " You've cleaned the field!" %00
string_3:
        .data "boom! you've lost" %00

