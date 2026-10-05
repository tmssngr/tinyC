        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

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

        ; i16 abs@i16
        ; arg a (i16): r0
abs_Pi16:
        ; move param.a{r2}, a{r0}
        ld   r3, r1
        ld   r2, r0
        ; branch param.a{r2} lt 0: if_15_then
        cp   r2, #%00
        jr   lt, if__15__then
        jr   ne, .lt1
        cp   r3, #%00
        jr   ult, if__15__then
.lt1:
        ; 183:9 return a
        jr   abs_Pi16__ret

if__15__then:
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
        jr   for__16

for__16__body:
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
for__16:
        ; branch i.2{r2} gt 0: for_16_body
        cp   r2, #%00
        jr   gt, for__16__body
        jr   ne, .gt2
        cp   r3, #%00
        jr   ugt, for__16__body
.gt2:
        ret

        ; i16 initField@u8@u8
        ; arg curr_r (u8): r0
        ; arg curr_c (u8): r1
        ; var bombs.2 (i16): SP+8
        ; var row.1 (i16): SP+10
        ; var column.1 (i16): SP+12
initField_Pu8_Pu8:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%06
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
        ; const bombCount.1{r12}, 0
        ld   r12, #%00
        ld   r13, #%00
        ; const bombs.1{r0}, 68
        ld   r0, #%00
        ld   r1, #%44
        ; 197:2 for bombs > 0
        ; addrof memVarAddr{r14}, bombs.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], bombs.2{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; move bombs.2{r2}, bombs.2{r0}
        ld   r3, r1
        ld   r2, r0
        jr   for__17

for__17__body:
        ; addrof memVarAddr{r14}, bombs.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], bombs.2{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; call t.8.1{r0} = random16[] -> i16
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
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], row.1{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; call t.9.1{r0} = random16[] -> i16
        call random16
        ; move column.1{r2}, t.9.1{r0}
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
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], column.1{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; 200:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=200:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=200:20], location=200:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=201:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=201:20], location=201:18]]) > 1
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load row.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move t.11.1{r0}, row.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; sub t.11.1{r0}, r.1{r8}
        sub  r1, r9
        sbc  r0, r8
        ; call t.10.1{r0} = abs@i16[t.11.1{r0}] -> i16
        call abs_Pi16
        ; branch t.10.1{r0} gt 1: if_18_then
        cp   r0, #%00
        jr   gt, if__18__then
        jr   ne, .gt3
        cp   r1, #%01
        jr   ugt, if__18__then
.gt3:
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load column.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move t.13.1{r0}, column.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; sub t.13.1{r0}, c.1{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call t.12.1{r0} = abs@i16[t.13.1{r0}] -> i16
        call abs_Pi16
        ; branch t.12.1{r0} lteq 1: for_17_continue, if_18_then
        cp   r0, #%00
        jr   lt, for__17__continue
        jr   ne, .lt4
        cp   r1, #%01
        jr   ule, for__17__continue
.lt4:
if__18__then:
        ; 202:4 if setBomb@u8@u8([ExprCast[typeString=u8, expression=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=202:19], type=u8, location=202:16], ExprCast[typeString=u8, expression=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=202:28], type=u8, location=202:25]])
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load row.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; cast t.15.1{r0}(u8), row.1{r2}(i16)
        ld   r0, r3
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load column.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; cast t.16.1{r1}(u8), column.1{r2}(i16)
        ld   r1, r3
        ; call t.14.1{r0} = setBomb@u8@u8[t.15.1{r0}, t.16.1{r1}] -> bool
        call setBomb_Pu8_Pu8
        ; branch t.14.1{r0} equals 0: for_17_continue
        cp   r0, #%00
        jr   eq, for__17__continue
        ; move bombCount.5{r2}, bombCount.2{r12}
        ld   r2, r12
        ld   r3, r13
        ; add bombCount.5{r2}, 1
        incw r2
        ; move bombCount.4{r12}, bombCount.5{r2}
        ld   r13, r3
        ld   r12, r2
for__17__continue:
        ; addrof memVarAddr{r14}, bombs.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load bombs.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; sub bombs.5{r2}, 1
        decw r2
for__17:
        ; branch bombs.2{r2} gt 0: for_17_body
        cp   r2, #%00
        jr   gt, for__17__body
        jr   ne, .gt5
        cp   r3, #%00
        jr   ugt, for__17__body
.gt5:
        ; 207:9 return bombCount
        ; move bombCount.2{r0}, bombCount.2{r12}
        ld   r0, r12
        ld   r1, r13
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
        add  %31, #%06
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; bool setBomb@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
setBomb_Pu8_Pu8:
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
        ; call index.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; move index.1{r1}, index.1{r0}
        ld   r2, r1
        ld   r1, r0
        ; 212:2 if [...] == 128
        ; addrof t.13.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.13.2{r4}, index.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load t.12.1{r3}, [t.13.2{r4}]
        lde  r3, @rr4
        ; branch t.12.1{r3} equals 128: if_21_then
        cp   r3, #%80
        jr   eq, if__21__then
        ; const t.14.1{r3}, 128
        ld   r3, #%80
        ; addrof t.15.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.15.2{r4}, index.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.15.2{r4}], t.14.1{r3}
        lde  @rr4, r3
        ; move rowFrom.1{r3}, param.row{r8}
        ld   r3, r8
        ; 218:2 if rowFrom > 0
        ; branch rowFrom.1{r3} lteq 0: if_22_end, if_22_then
        cp   r3, #%00
        jr   ule, if__22__end
        jr   if__22__then

if__21__then:
        ; 213:10 return false
        ; const {r0}, 0
        ld   r0, #%00
        jr   setBomb_Pu8_Pu8__ret

if__22__then:
        ; move rowFrom.3{r3}, param.row{r8}
        ld   r3, r8
        ; sub rowFrom.3{r3}, 1
        dec  r3
        ; sub index.3{r1}, 38
        sub  r2, #%26
        sbc  r1, #%00
if__22__end:
        ; move rowTo.1{r4}, param.row{r8}
        ld   r4, r8
        ; add rowTo.1{r4}, 1
        inc  r4
        ; 223:2 if rowTo >= 20
        ; branch rowTo.1{r4} lt 20: if_23_end
        cp   r4, #%14
        jr   ult, if__23__end
        ; sub rowTo.3{r4}, 1
        dec  r4
if__23__end:
        ; move colFrom.1{r5}, param.column{r9}
        ld   r5, r9
        ; 228:2 if colFrom > 0
        ; branch colFrom.1{r5} lteq 0: if_24_end
        cp   r5, #%00
        jr   ule, if__24__end
        ; sub colFrom.3{r5}, 1
        dec  r5
        ; sub index.6{r1}, 1
        sub  r2, #%01
        sbc  r1, #%00
if__24__end:
        ; move colTo.1{r6}, param.column{r9}
        ld   r6, r9
        ; add colTo.1{r6}, 1
        inc  r6
        ; 233:2 if colTo >= 38
        ; branch colTo.1{r6} lt 38: if_25_end
        cp   r6, #%26
        jr   ult, if__25__end
        ; sub colTo.3{r6}, 1
        dec  r6
if__25__end:
        ; 238:2 for r <= rowTo
        jr   for__26

for__26__body:
        ; move c.1{r7}, colFrom.2{r5}
        ld   r7, r5
        ; 239:3 for c <= colTo
        jr   for__27

for__27__body:
        ; branch r.2{r3} notequals param.row{r8}: if_28_end
        cp   r3, r8
        jr   ne, if__28__end
        ; branch c.2{r7} equals param.column{r9}: for_27_continue, if_28_end
        cp   r7, r9
        jr   eq, for__27__continue
if__28__end:
        ; addrof t.16.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.16.2{r10}, index.9{r1}
        add  r11, r2
        adc  r10, r1
        ; load cell.1{r12}, [t.16.2{r10}]
        lde  r12, @rr10
        ; 245:4 if cell & 128 == 0
        ; move t.17.1{r10}, cell.1{r12}
        ld   r10, r12
        ; and t.17.1{r10}, 128
        and  r10, #%80
        ; branch t.17.1{r10} notequals 0: for_27_continue
        cp   r10, #%00
        jr   ne, for__27__continue
        ; move count.2{r10}, cell.1{r12}
        ld   r10, r12
        ; and count.2{r10}, 15
        and  r10, #%0f
        ; add count.3{r10}, 1
        inc  r10
        ; addrof t.18.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.18.2{r12}, index.9{r1}
        add  r13, r2
        adc  r12, r1
        ; store [t.18.2{r12}], count.3{r10}
        lde  @rr12, r10
for__27__continue:
        ; add c.5{r7}, 1
        inc  r7
        ; add index.13{r1}, 1
        add  r2, #%01
        adc  r1, #%00
for__27:
        ; branch c.2{r7} lteq colTo.2{r6}: for_27_body
        cp   r7, r6
        jr   ule, for__27__body
        ; cast t.22.1{r10}(i16), colTo.2{r6}(u8)
        ld   r11, r6
        ld   r10, #0
        ; sub t.21.1{r1}, t.22.1{r10}
        sub  r2, r11
        sbc  r1, r10
        ; cast t.23.1{r10}(i16), colFrom.2{r5}(u8)
        ld   r11, r5
        ld   r10, #0
        ; add t.20.1{r1}, t.23.1{r10}
        add  r2, r11
        adc  r1, r10
        ; add t.19.1{r1}, 38
        add  r2, #%26
        adc  r1, #%00
        ; sub index.10{r1}, 1
        sub  r2, #%01
        sbc  r1, #%00
        ; add r.4{r3}, 1
        inc  r3
for__26:
        ; branch r.2{r3} lteq rowTo.2{r4}: for_26_body
        cp   r3, r4
        jr   ule, for__26__body
        ; 253:9 return true
        ; const {r0}, 1
        ld   r0, #%01
setBomb_Pu8_Pu8__ret:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
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
        ; 258:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=258:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=258:30]]) != 0
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
        ; 263:2 while changed
        jr   while__32

while__32__body:
        ; const changed.3{r8}, 0
        ld   r8, #%00
        ; const index.1{r9}, 0
        ld   r9, #%00
        ld   r10, #%00
        ; const r.1{r11}, 0
        ld   r11, #%00
        ; 267:3 for r < 20
        jr   for__33

for__33__body:
        ; const c.1{r12}, 0
        ld   r12, #%00
        ; 268:4 for c < 38
        jr   for__34

for__34__body:
        ; addrof t.11.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.11.2{r2}, index.3{r9}
        add  r3, r10
        adc  r2, r9
        ; load cell.1{r13}, [t.11.2{r2}]
        lde  r13, @rr2
        ; 270:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.12.1{r2}, cell.1{r13}
        ld   r2, r13
        ; and t.12.1{r2}, 32
        and  r2, #%20
        ; branch t.12.1{r2} equals 0: for_34_continue
        cp   r2, #%00
        jr   eq, for__34__continue
        ; and t.13.1{r13}, 128
        and  r13, #%80
        ; branch t.13.1{r13} notequals 0: for_34_continue
        cp   r13, #%00
        jr   ne, for__34__continue
        ; 273:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=273:28], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=273:31]]) != 0
        ; move r.2{r0}, r.2{r11}
        ld   r0, r11
        ; move c.2{r1}, c.2{r12}
        ld   r1, r12
        ; call t.14.1{r0} = getBombCountAround@u8@u8[r.2{r0}, c.2{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.14.1{r0} notequals 0: for_34_continue
        cp   r0, #%00
        jr   ne, for__34__continue
        ; 277:5 if revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=4, scope=function, type=u8, varIsArray=false, location=277:24], ExprVarAccess[varName=c, index=5, scope=function, type=u8, varIsArray=false, location=277:27]])
        ; move r.2{r0}, r.2{r11}
        ld   r0, r11
        ; move c.2{r1}, c.2{r12}
        ld   r1, r12
        ; call t.15.1{r0} = revealNeighbors@u8@u8[r.2{r0}, c.2{r1}] -> bool
        call revealNeighbors_Pu8_Pu8
        ; branch t.15.1{r0} equals 0: for_34_continue
        cp   r0, #%00
        jr   eq, for__34__continue
        ; const changed.9{r8}, 1
        ld   r8, #%01
for__34__continue:
        ; add c.6{r12}, 1
        inc  r12
        ; add index.7{r9}, 1
        add  r10, #%01
        adc  r9, #%00
for__34:
        ; branch c.2{r12} lt 38: for_34_body
        cp   r12, #%26
        jr   ult, for__34__body
        ; add r.6{r11}, 1
        inc  r11
for__33:
        ; branch r.2{r11} lt 20: for_33_body
        cp   r11, #%14
        jr   ult, for__33__body
        ; branch changed.4{r8} equals 0: maybeRevealAround@u8@u8_ret
        cp   r8, #%00
        jr   eq, maybeRevealAround_Pu8_Pu8__ret
        ; const r.4{r11}, 20
        ld   r11, #%14
        ; 288:3 while true
        jr   while__40

if__41__end:
        ; sub r.7{r11}, 1
        dec  r11
        ; const c.3{r12}, 38
        ld   r12, #%26
        ; 295:4 while true
        jr   while__42

if__43__end:
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
        ; 302:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.17.1{r2}, cell.2{r13}
        ld   r2, r13
        ; and t.17.1{r2}, 32
        and  r2, #%20
        ; branch t.17.1{r2} equals 0: while_42
        cp   r2, #%00
        jr   eq, while__42
        ; and t.18.1{r13}, 128
        and  r13, #%80
        ; branch t.18.1{r13} notequals 0: while_42
        cp   r13, #%00
        jr   ne, while__42
        ; 305:5 if getBombCountAround@u8@u8([ExprVarAccess[varName=r, index=7, scope=function, type=u8, varIsArray=false, location=305:28], ExprVarAccess[varName=c, index=8, scope=function, type=u8, varIsArray=false, location=305:31]]) != 0
        ; move r.7{r0}, r.7{r11}
        ld   r0, r11
        ; move c.7{r1}, c.7{r12}
        ld   r1, r12
        ; call t.19.1{r0} = getBombCountAround@u8@u8[r.7{r0}, c.7{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.19.1{r0} notequals 0: while_42
        cp   r0, #%00
        jr   ne, while__42
        ; 309:5 if revealNeighbors@u8@u8([ExprVarAccess[varName=r, index=7, scope=function, type=u8, varIsArray=false, location=309:24], ExprVarAccess[varName=c, index=8, scope=function, type=u8, varIsArray=false, location=309:27]])
        ; move r.7{r0}, r.7{r11}
        ld   r0, r11
        ; move c.7{r1}, c.7{r12}
        ld   r1, r12
        ; call t.20.1{r0} = revealNeighbors@u8@u8[r.7{r0}, c.7{r1}] -> bool
        call revealNeighbors_Pu8_Pu8
        ; branch t.20.1{r0} equals 0: while_42
        cp   r0, #%00
        jr   eq, while__42
        ; const changed.10{r0}, 1
        ld   r0, #%01
        ; move changed.7{r8}, changed.10{r0}
        ld   r8, r0
while__42:
        ; branch c.4{r12} notequals 0: if_43_end, while_40
        cp   r12, #%00
        jr   ne, if__43__end
while__40:
        ; branch r.5{r11} notequals 0: if_41_end, while_32
        cp   r11, #%00
        jr   ne, if__41__end
while__32:
        ; branch changed.2{r8} notequals 0: while_32_body, maybeRevealAround@u8@u8_ret
        cp   r8, #%00
        jr   ne, while__32__body
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
        ; 319:2 if rowFrom > 0
        ; branch rowFrom.1{r8} lteq 0: if_48_end
        cp   r8, #%00
        jr   ule, if__48__end
        ; sub rowFrom.3{r8}, 1
        dec  r8
if__48__end:
        ; move rowTo.1{r9}, param.row{r0}
        ld   r9, r0
        ; add rowTo.1{r9}, 1
        inc  r9
        ; 323:2 if rowTo >= 20
        ; branch rowTo.1{r9} lt 20: if_49_end
        cp   r9, #%14
        jr   ult, if__49__end
        ; sub rowTo.3{r9}, 1
        dec  r9
if__49__end:
        ; move colFrom.1{r10}, param.column{r1}
        ld   r10, r1
        ; 328:2 if colFrom > 0
        ; branch colFrom.1{r10} lteq 0: if_50_end
        cp   r10, #%00
        jr   ule, if__50__end
        ; sub colFrom.3{r10}, 1
        dec  r10
if__50__end:
        ; move colTo.1{r11}, param.column{r1}
        ld   r11, r1
        ; add colTo.1{r11}, 1
        inc  r11
        ; 332:2 if colTo >= 38
        ; branch colTo.1{r11} lt 38: if_51_end
        cp   r11, #%26
        jr   ult, if__51__end
        ; sub colTo.3{r11}, 1
        dec  r11
if__51__end:
        ; move rowFrom.2{r0}, rowFrom.2{r8}
        ld   r0, r8
        ; move colFrom.2{r1}, colFrom.2{r10}
        ld   r1, r10
        ; call index.1{r0} = rowColumnToCell@u8@u8[rowFrom.2{r0}, colFrom.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; const changed.1{r12}, 0
        ld   r12, #%00
        ; 337:2 for r <= rowTo
        ; move index.2{r3}, index.1{r0}
        ld   r4, r1
        ld   r3, r0
        ; move index.2{r1}, index.2{r3}
        ld   r1, r3
        ld   r2, r4
        jr   for__52

for__52__body:
        ; move index.2{r3}, index.2{r1}
        ld   r4, r2
        ld   r3, r1
        ; move c.1{r13}, colFrom.2{r10}
        ld   r13, r10
        ; 338:3 for c <= colTo
        ; move index.3{r2}, index.3{r3}
        ld   r2, r3
        ld   r3, r4
        jr   for__53

for__53__body:
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
        ; 340:4 if cell & 32 != 0
        ; move t.12.1{r6}, cell.1{r5}
        ld   r6, r5
        ; and t.12.1{r6}, 32
        and  r6, #%20
        ; branch t.12.1{r6} equals 0: if_54_end
        cp   r6, #%00
        jr   eq, if__54__end
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
        jr   for__53__continue

if__54__end:
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
for__53__continue:
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
for__53:
        ; branch c.2{r13} lteq colTo.2{r11}: for_53_body
        cp   r13, r11
        jr   ule, for__53__body
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
for__52:
        ; branch r.2{r8} lteq rowTo.2{r9}: for_52_body
        cp   r8, r9
        jr   ule, for__52__body
        ; 351:9 return changed
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
        ; const col.1{r8}, 19
        ld   r8, #%13
        ; const row.1{r9}, 10
        ld   r9, #%0a
        ; const bombsLeft.1{r10}, -1
        ld   r10, #%ff
        ld   r11, #%ff
        ; 363:2 while true
        jr   while__55

if__56__end:
        ; const t.9.1{r2}, 1
        ld   r2, #%01
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call showCursor@u8@u8@bool[row.2{r0}, col.2{r1}, t.9.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; call chr.1{r0} = getChar[] -> i16
        call getChar
        ; move chr.1{r12}, chr.1{r0}
        ld   r13, r1
        ld   r12, r0
        ; const t.10.1{r2}, 0
        ld   r2, #%00
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call showCursor@u8@u8@bool[row.2{r0}, col.2{r1}, t.10.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; 372:3 if chr == 27
        ; branch chr.1{r12} equals 27: main_ret
        cp   r13, #%1b
        jr   ne, .notEquals6
        cp   r12, #%00
        jr   eq, main__ret
.notEquals6:
        ; branch chr.1{r12} equals 13: if_58_then
        cp   r13, #%0d
        jr   ne, .notEquals7
        cp   r12, #%00
        jr   eq, if__58__then
.notEquals7:
        ; branch chr.1{r12} notequals 3: if_62_else, if_62_then
        cp   r13, #%03
        jr   ne, if__62__else
        cp   r12, #%00
        jr   ne, if__62__else
        jr   if__62__then

if__58__then:
        ; branch bombsLeft.2{r10} gteq 0: if_59_end, if_59_then
        cp   r10, #%00
        jr   gt, if__59__end
        jr   ne, .gt8
        cp   r11, #%00
        jr   uge, if__59__end
.gt8:
        jr   if__59__then

if__62__else:
        ; branch chr.1{r12} notequals 4: if_64_else, if_64_then
        cp   r13, #%04
        jr   ne, if__64__else
        cp   r12, #%00
        jr   ne, if__64__else
        jr   if__64__then

if__62__then:
        ; branch row.2{r9} lteq 0: while_55, if_63_then
        cp   r9, #%00
        jr   ule, while__55
        jr   if__63__then

if__59__then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call bombsLeft.4{r0} = initField@u8@u8[row.2{r0}, col.2{r1}] -> i16
        call initField_Pu8_Pu8
        ; move bombsLeft.3{r10}, bombsLeft.4{r0}
        ld   r11, r1
        ld   r10, r0
        jr   if__59__end

if__64__else:
        ; branch chr.1{r12} notequals 1: if_66_else, if_66_then
        cp   r13, #%01
        jr   ne, if__66__else
        cp   r12, #%00
        jr   ne, if__66__else
        jr   if__66__then

if__64__then:
        ; branch row.2{r9} gteq 19: while_55, if_65_then
        cp   r9, #%13
        jr   uge, while__55
        jr   if__65__then

if__63__then:
        ; sub row.4{r9}, 1
        dec  r9
        jr   while__55

if__59__end:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call index.1{r0} = rowColumnToCell@u8@u8[row.2{r0}, col.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.11.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.11.2{r12}, index.1{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell.1{r2}, [t.11.2{r12}]
        lde  r2, @rr12
        ; 382:4 if cell & 32 == 0
        ; move t.12.1{r12}, cell.1{r2}
        ld   r12, r2
        ; and t.12.1{r12}, 32
        and  r12, #%20
        ; branch t.12.1{r12} notequals 0: if_60_end, if_60_then
        cp   r12, #%00
        jr   ne, if__60__end
        jr   if__60__then

if__66__else:
        ; branch chr.1{r12} notequals 2: if_68_else, if_68_then
        cp   r13, #%02
        jr   ne, if__68__else
        cp   r12, #%00
        jr   ne, if__68__else
        jr   if__68__then

if__66__then:
        ; branch col.2{r8} lteq 0: while_55, if_67_then
        cp   r8, #%00
        jr   ule, while__55
        jr   if__67__then

if__65__then:
        ; add row.5{r9}, 1
        inc  r9
        jr   while__55

if__60__then:
        ; move t.13.1{r12}, cell.1{r2}
        ld   r12, r2
        ; or t.13.1{r12}, 32
        or  r12, #%20
        ; addrof t.14.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.14.2{r4}, index.1{r0}
        add  r5, r1
        adc  r4, r0
        ; store [t.14.2{r4}], t.13.1{r12}
        lde  @rr4, r12
        jr   if__60__end

if__68__else:
        ; branch chr.1{r12} notequals 32: while_55, if_70_then
        cp   r13, #%20
        jr   ne, while__55
        cp   r12, #%00
        jr   ne, while__55
        jr   if__70__then

if__68__then:
        ; branch col.2{r8} gteq 37: while_55, if_69_then
        cp   r8, #%25
        jr   uge, while__55
        jr   if__69__then

if__67__then:
        ; sub col.5{r8}, 1
        dec  r8
        jr   while__55

if__60__end:
        ; 385:4 if cell & 128 != 0
        ; move t.15.1{r12}, cell.1{r2}
        ld   r12, r2
        ; and t.15.1{r12}, 128
        and  r12, #%80
        ; branch t.15.1{r12} equals 0: if_61_end, if_61_then
        cp   r12, #%00
        jr   eq, if__61__end
        jr   if__61__then

if__70__then:
        ; branch bombsLeft.2{r10} lt 0: while_55, if_71_then
        cp   r10, #%00
        jr   lt, while__55
        jr   ne, .lt9
        cp   r11, #%00
        jr   ult, while__55
.lt9:
        jr   if__71__then

if__69__then:
        ; add col.6{r8}, 1
        inc  r8
        jr   while__55

if__61__end:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call maybeRevealAround@u8@u8[row.2{r0}, col.2{r1}]
        call maybeRevealAround_Pu8_Pu8
        jr   while__55

if__71__then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call index.2{r0} = rowColumnToCell@u8@u8[row.2{r0}, col.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.17.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.17.2{r12}, index.2{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell.3{r3}, [t.17.2{r12}]
        lde  r3, @rr12
        ; 421:5 if cell & 32 == 0
        ; move t.18.1{r12}, cell.3{r3}
        ld   r12, r3
        ; and t.18.1{r12}, 32
        and  r12, #%20
        ; branch t.18.1{r12} notequals 0: while_55
        cp   r12, #%00
        jr   ne, while__55
        ; move cell.4{r12}, cell.3{r3}
        ld   r12, r3
        ; xor cell.4{r12}, 64
        xor r12, #%40
        ; 423:6 if cell & 128 != 0
        ; move t.19.1{r13}, cell.4{r12}
        ld   r13, r12
        ; and t.19.1{r13}, 128
        and  r13, #%80
        ; branch t.19.1{r13} equals 0: if_73_end
        cp   r13, #%00
        jr   eq, if__73__end
        ; 424:7 if cell & 64 != 0
        ; move t.20.1{r13}, cell.4{r12}
        ld   r13, r12
        ; and t.20.1{r13}, 64
        and  r13, #%40
        ; branch t.20.1{r13} notequals 0: if_74_then
        cp   r13, #%00
        jr   ne, if__74__then
        ; add bombsLeft.7{r10}, 1
        incw r10
        jr   if__73__end

if__74__then:
        ; sub bombsLeft.8{r10}, 1
        decw r10
if__73__end:
        ; addrof t.21.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.21.2{r4}, index.2{r0}
        add  r5, r1
        adc  r4, r0
        ; store [t.21.2{r4}], cell.4{r12}
        lde  @rr4, r12
        ; move cell.4{r0}, cell.4{r12}
        ld   r0, r12
        ; move row.2{r1}, row.2{r9}
        ld   r1, r9
        ; move col.2{r2}, col.2{r8}
        ld   r2, r8
        ; call printCellAt@u8@u8@u8[cell.4{r0}, row.2{r1}, col.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
while__55:
        ; branch bombsLeft.2{r10} notequals 0: if_56_end
        cp   r11, #%00
        jr   ne, if__56__end
        cp   r10, #%00
        jr   ne, if__56__end
        ; const t.8.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.8.1{r0}]
        call printString_P_Pu8
        jr   main__ret

if__61__then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call printCellAt@u8@u8[row.2{r0}, col.2{r1}]
        call printCellAt_Pu8_Pu8
        ; const t.16.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.16.1{r0}]
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
        .data " You've cleaned the field!" %00
string_2:
        .data "boom! you've lost" %00

