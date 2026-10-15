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
        ; 33:19 return r * 38 + c
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

        ; i16 columnToX@u8
        ; arg column (u8): r0
columnToX_Pu8:
        ; cast c.1{r0}(i16), param.column{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; 39:10 return c
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
        push r10
        ; const chr.1{r8}, 46
        ld   r8, #%2e
        ; 58:2 if cell & 32 != 0
        ; move t.6.1{r9}, param.cell{r0}
        ld   r9, r0
        ; and t.6.1{r9}, 32
        and  r9, #%20
        ; branch t.6.1{r9} notequals 0: if_1_then
        cp   r9, #%00
        jr   ne, if__1__then
        ; 73:7 if cell & 64 != 0
        ; move t.10.1{r9}, param.cell{r0}
        ld   r9, r0
        ; and t.10.1{r9}, 64
        and  r9, #%40
        ; branch t.10.1{r9} equals 0: if_1_end, if_4_then
        cp   r9, #%00
        jr   eq, if__1__end
        jr   if__4__then

if__1__then:
        ; 59:3 if cell & 128 != 0
        ; move t.7.1{r8}, param.cell{r0}
        ld   r8, r0
        ; and t.7.1{r8}, 128
        and  r8, #%80
        ; branch t.7.1{r8} equals 0: if_2_else, if_2_then
        cp   r8, #%00
        jr   eq, if__2__else
        jr   if__2__then

if__4__then:
        ; const chr.3{r8}, 35
        ld   r8, #%23
        jr   if__1__end

if__2__else:
        ; move param.row{r0}, param.row{r1}
        ld   r0, r1
        ; move param.column{r1}, param.column{r2}
        ld   r1, r2
        ; call index.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.9.1{r8}, field
        ld   r8, #hi(var_0)
        ld   r9, #lo(var_0)
        ; add t.9.2{r8}, index.1{r0}
        add  r9, r1
        adc  r8, r0
        ; load t.8.1{r10}, [t.9.2{r8}]
        lde  r10, @rr8
        ; move count.1{r8}, t.8.1{r10}
        ld   r8, r10
        ; and count.1{r8}, 15
        and  r8, #%0f
        ; 65:4 if count > 0
        ; branch count.1{r8} lteq 0: if_3_else, if_3_then
        cp   r8, #%00
        jr   ule, if__3__else
        jr   if__3__then

if__2__then:
        ; const chr.4{r8}, 42
        ld   r8, #%2a
        jr   if__1__end

if__3__else:
        ; const chr.5{r8}, 32
        ld   r8, #%20
        jr   if__1__end

if__3__then:
        ; add chr.6{r8}, 48
        add  r8, #%30
if__1__end:
        ; move chr.2{r0}, chr.2{r8}
        ld   r0, r8
        ; call printChar@u8[chr.2{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r10
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
        ; 92:2 for row < 20
        jr   for__5

for__5__body:
        ; cast t.3.1{r0}(i16), row.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; const arg.1.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[t.3.1{r0}, arg.1.1{r2}]
        call setCursor_Pi16_Pi16
        ; const column.1{r9}, 0
        ld   r9, #%00
        ; 97:3 for column < 38
        jr   for__6

for__6__body:
        ; move row.2{r0}, row.2{r8}
        ld   r0, r8
        ; move column.2{r1}, column.2{r9}
        ld   r1, r9
        ; call t.5.1{r0} = rowColumnToCell@u8@u8[row.2{r0}, column.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.4.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.4.2{r10}, t.5.1{r0}
        add  r11, r1
        adc  r10, r0
        ; load cell.1{r0}, [t.4.2{r10}]
        lde  r0, @rr10
        ; move row.2{r1}, row.2{r8}
        ld   r1, r8
        ; move column.2{r2}, column.2{r9}
        ld   r2, r9
        ; call printCell@u8@u8@u8[cell.1{r0}, row.2{r1}, column.2{r2}]
        call printCell_Pu8_Pu8_Pu8
        ; move column.3{r0}, column.2{r9}
        ld   r0, r9
        ; add column.3{r0}, 1
        inc  r0
        ; move column.2{r9}, column.3{r0}
        ld   r9, r0
for__6:
        ; branch column.2{r9} lt 38: for_6_body
        cp   r9, #%26
        jr   ult, for__6__body
        ; move row.4{r0}, row.2{r8}
        ld   r0, r8
        ; add row.4{r0}, 1
        inc  r0
        ; move row.2{r8}, row.4{r0}
        ld   r8, r0
for__5:
        ; branch row.2{r8} lt 20: for_5_body
        cp   r8, #%14
        jr   ult, for__5__body
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
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; branch param.show{r2} equals 0: showCursor@u8@u8@bool_ret
        cp   r2, #%00
        jr   eq, showCursor_Pu8_Pu8_Pbool__ret
        ; move param.column{r0}, param.column{r1}
        ld   r0, r1
        ; call x.1{r0} = columnToX@u8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x.1{r2}, x.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; cast t.6.1{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; call setCursor@i16@i16[t.6.1{r0}, x.1{r2}]
        call setCursor_Pi16_Pi16
showCursor_Pu8_Pu8_Pbool__ret:
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; i16 abs@i16
        ; arg a (i16): r0
abs_Pi16:
        ; move param.a{r2}, a{r0}
        ld   r3, r1
        ld   r2, r0
        ; branch param.a{r2} lt 0: if_10_then
        cp   r2, #%00
        jr   lt, if__10__then
        jr   ne, .lt1
        cp   r3, #%00
        jr   ult, if__10__then
.lt1:
        ; 186:9 return a
        jr   abs_Pi16__ret

if__10__then:
        ; 184:10 return -a
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
        ; 191:2 for i > 0
        jr   for__11

for__11__body:
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
for__11:
        ; branch i.2{r2} gt 0: for_11_body
        cp   r2, #%00
        jr   gt, for__11__body
        jr   ne, .gt2
        cp   r3, #%00
        jr   ugt, for__11__body
.gt2:
        ret

        ; i16 initField@u8@u8
        ; arg curr_r (u8): r0
        ; arg curr_c (u8): r1
        ; var bombs.2 (i16): SP+8
        ; var row.1 (i16): SP+10
        ; var column.1 (i16): SP+12
initField_Pu8_Pu8:
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
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
        ; 200:2 for bombs > 0
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
        jr   for__12

for__12__body:
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
        ; 203:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=203:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=203:20], location=203:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=204:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=204:20], location=204:18]]) > 1
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
        ; branch t.10.1{r0} gt 1: if_13_then
        cp   r0, #%00
        jr   gt, if__13__then
        jr   ne, .gt3
        cp   r1, #%01
        jr   ugt, if__13__then
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
        ; branch t.12.1{r0} lteq 1: for_12_continue, if_13_then
        cp   r0, #%00
        jr   lt, for__12__continue
        jr   ne, .lt4
        cp   r1, #%01
        jr   ule, for__12__continue
.lt4:
if__13__then:
        ; 205:4 if setBomb@u8@u8([ExprCast[typeString=u8, expression=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=205:15], type=u8, location=205:22], ExprCast[typeString=u8, expression=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=205:26], type=u8, location=205:36]])
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
        ; branch t.14.1{r0} equals 0: for_12_continue
        cp   r0, #%00
        jr   eq, for__12__continue
        ; move bombCount.5{r2}, bombCount.2{r12}
        ld   r2, r12
        ld   r3, r13
        ; add bombCount.5{r2}, 1
        incw r2
        ; move bombCount.4{r12}, bombCount.5{r2}
        ld   r13, r3
        ld   r12, r2
for__12__continue:
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
for__12:
        ; branch bombs.2{r2} gt 0: for_12_body
        cp   r2, #%00
        jr   gt, for__12__body
        jr   ne, .gt5
        cp   r3, #%00
        jr   ugt, for__12__body
.gt5:
        ; 210:9 return bombCount
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
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
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
        ; 215:2 if [...] == 128
        ; addrof t.13.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.13.2{r4}, index.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load t.12.1{r3}, [t.13.2{r4}]
        lde  r3, @rr4
        ; branch t.12.1{r3} equals 128: if_16_then
        cp   r3, #%80
        jr   eq, if__16__then
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
        ; 221:2 if rowFrom > 0
        ; branch rowFrom.1{r3} lteq 0: if_17_end, if_17_then
        cp   r3, #%00
        jr   ule, if__17__end
        jr   if__17__then

if__16__then:
        ; const {r0}, 0
        ld   r0, #%00
        jr   setBomb_Pu8_Pu8__ret

if__17__then:
        ; sub rowFrom.3{r3}, 1
        dec  r3
        ; sub index.3{r1}, 38
        sub  r2, #%26
        sbc  r1, #%00
if__17__end:
        ; move rowTo.1{r4}, param.row{r8}
        ld   r4, r8
        ; add rowTo.1{r4}, 1
        inc  r4
        ; 226:2 if rowTo >= 20
        ; branch rowTo.1{r4} lt 20: if_18_end
        cp   r4, #%14
        jr   ult, if__18__end
        ; sub rowTo.3{r4}, 1
        dec  r4
if__18__end:
        ; move colFrom.1{r5}, param.column{r9}
        ld   r5, r9
        ; 231:2 if colFrom > 0
        ; branch colFrom.1{r5} lteq 0: if_19_end
        cp   r5, #%00
        jr   ule, if__19__end
        ; sub colFrom.3{r5}, 1
        dec  r5
        ; sub index.6{r1}, 1
        sub  r2, #%01
        sbc  r1, #%00
if__19__end:
        ; move colTo.1{r6}, param.column{r9}
        ld   r6, r9
        ; add colTo.1{r6}, 1
        inc  r6
        ; 236:2 if colTo >= 38
        ; branch colTo.1{r6} lt 38: if_20_end
        cp   r6, #%26
        jr   ult, if__20__end
        ; sub colTo.3{r6}, 1
        dec  r6
if__20__end:
        ; 241:2 for r <= rowTo
        jr   for__21

for__21__body:
        ; move c.1{r7}, colFrom.2{r5}
        ld   r7, r5
        ; 242:3 for c <= colTo
        jr   for__22

for__22__body:
        ; branch r.2{r3} notequals param.row{r8}: if_23_end
        cp   r3, r8
        jr   ne, if__23__end
        ; branch c.2{r7} equals param.column{r9}: for_22_continue, if_23_end
        cp   r7, r9
        jr   eq, for__22__continue
if__23__end:
        ; addrof t.16.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.16.2{r10}, index.9{r1}
        add  r11, r2
        adc  r10, r1
        ; load cell.1{r12}, [t.16.2{r10}]
        lde  r12, @rr10
        ; 248:4 if cell & 128 == 0
        ; move t.17.1{r10}, cell.1{r12}
        ld   r10, r12
        ; and t.17.1{r10}, 128
        and  r10, #%80
        ; branch t.17.1{r10} notequals 0: for_22_continue
        cp   r10, #%00
        jr   ne, for__22__continue
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
for__22__continue:
        ; add c.5{r7}, 1
        inc  r7
        ; add index.13{r1}, 1
        add  r2, #%01
        adc  r1, #%00
for__22:
        ; branch c.2{r7} lteq colTo.2{r6}: for_22_body
        cp   r7, r6
        jr   ule, for__22__body
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
for__21:
        ; branch r.2{r3} lteq rowTo.2{r4}: for_21_body
        cp   r3, r4
        jr   ule, for__21__body
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
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call index.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; 262:2 if [...] & 15 != 0
        ; addrof t.14.1{r10}, field
        ld   r10, #hi(var_0)
        ld   r11, #lo(var_0)
        ; add t.14.2{r10}, index.1{r0}
        add  r11, r1
        adc  r10, r0
        ; load t.13.1{r12}, [t.14.2{r10}]
        lde  r12, @rr10
        ; move t.12.1{r10}, t.13.1{r12}
        ld   r10, r12
        ; and t.12.1{r10}, 15
        and  r10, #%0f
        ; branch t.12.1{r10} notequals 0: maybeRevealAround@u8@u8_ret
        cp   r10, #%00
        jr   ne, maybeRevealAround_Pu8_Pu8__ret
        ; const t.16.1{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; addrof t.15.1{r12}, revealStackRows
        ld   r12, #hi(var_1)
        ld   r13, #lo(var_1)
        ; add t.15.2{r12}, t.16.1{r10}
        add  r13, r11
        adc  r12, r10
        ; store [t.15.2{r12}], param.row{r8}
        lde  @rr12, r8
        ; addrof t.17.1{r12}, revealStackColumns
        ld   r12, #hi(var_2)
        ld   r13, #lo(var_2)
        ; add t.17.2{r12}, t.18.1{r10}
        add  r13, r11
        adc  r12, r10
        ; store [t.17.2{r12}], param.column{r9}
        lde  @rr12, r9
        ; addrof a.19.1{r8}, revealStackIndices
        ld   r8, #hi(var_3)
        ld   r9, #lo(var_3)
        ; store [a.19.1{r8}], index.1{r0}
        lde  @rr8, r0
        incw r8
        lde  @rr8, r1
        decw r8
        ; add t.20.1{r8}, 2
        add  r9, #%02
        adc  r8, #%00
        ; addrof a.22.1{r10}, revealStackIndexTop
        ld   r10, #hi(var_4)
        ld   r11, #lo(var_4)
        ; store [a.22.1{r10}], t.20.1{r8}
        lde  @rr10, r8
        incw r10
        lde  @rr10, r9
        decw r10
        ; const t.23.1{r8}, 1
        ld   r8, #%01
        ; addrof a.24.1{r10}, revealStackSize
        ld   r10, #hi(var_5)
        ld   r11, #lo(var_5)
        ; store [a.24.1{r10}], t.23.1{r8}
        lde  @rr10, r8
        ; 271:2 while revealStackSize > 0
        jr   while__27

while__27__body:
        ; addrof a.27.1{r8}, revealStackSize
        ld   r8, #hi(var_5)
        ld   r9, #lo(var_5)
        ; load t.28.1{r10}, [a.27.1{r8}]
        lde  r10, @rr8
        ; move stackSize.1{r8}, t.28.1{r10}
        ld   r8, r10
        ; sub stackSize.1{r8}, 1
        dec  r8
        ; move t.29.1{r9}, stackSize.1{r8}
        ld   r9, r8
        ; addrof a.30.1{r10}, revealStackSize
        ld   r10, #hi(var_5)
        ld   r11, #lo(var_5)
        ; store [a.30.1{r10}], t.29.1{r9}
        lde  @rr10, r9
        ; cast t.32.1{r9}(i16), stackSize.1{r8}(u8)
        ld   r10, r8
        ld   r9, #0
        ; addrof t.31.1{r12}, revealStackRows
        ld   r12, #hi(var_1)
        ld   r13, #lo(var_1)
        ; add t.31.2{r12}, t.32.1{r9}
        add  r13, r10
        adc  r12, r9
        ; load row.1{r0}, [t.31.2{r12}]
        lde  r0, @rr12
        ; move t.34.1{r8}, t.34.1{r9}
        ld   r8, r9
        ld   r9, r10
        ; addrof t.33.1{r10}, revealStackColumns
        ld   r10, #hi(var_2)
        ld   r11, #lo(var_2)
        ; add t.33.2{r10}, t.34.1{r8}
        add  r11, r9
        adc  r10, r8
        ; load column.1{r1}, [t.33.2{r10}]
        lde  r1, @rr10
        ; addrof a.35.1{r8}, revealStackIndexTop
        ld   r8, #hi(var_4)
        ld   r9, #lo(var_4)
        ; load t.36.1{r10}, [a.35.1{r8}]
        lde  r10, @rr8
        incw r8
        lde  r11, @rr8
        decw r8
        ; move stackIndex.1{r8}, t.36.1{r10}
        ld   r8, r10
        ld   r9, r11
        ; add stackIndex.1{r8}, -2
        add  r9, #%fe
        adc  r8, #%ff
        ; move t.37.1{r10}, stackIndex.1{r8}
        ld   r11, r9
        ld   r10, r8
        ; addrof a.38.1{r12}, revealStackIndexTop
        ld   r12, #hi(var_4)
        ld   r13, #lo(var_4)
        ; store [a.38.1{r12}], t.37.1{r10}
        lde  @rr12, r10
        incw r12
        lde  @rr12, r11
        decw r12
        ; load index.2{r2}, [stackIndex.1{r8}]
        lde  r2, @rr8
        incw r8
        lde  r3, @rr8
        decw r8
        ; call _ = revealNeighbors@u8@u8@i16[row.1{r0}, column.1{r1}, index.2{r2}] -> bool
        call revealNeighbors_Pu8_Pu8_Pi16
        ; 280:3 if revealStackSize == 255
        ; addrof a.39.1{r8}, revealStackSize
        ld   r8, #hi(var_5)
        ld   r9, #lo(var_5)
        ; load t.40.1{r10}, [a.39.1{r8}]
        lde  r10, @rr8
        ; branch t.40.1{r10} equals 255: while_27_break, while_27
        cp   r10, #%ff
        jr   eq, while__27__break
while__27:
        ; addrof a.25.1{r8}, revealStackSize
        ld   r8, #hi(var_5)
        ld   r9, #lo(var_5)
        ; load t.26.1{r10}, [a.25.1{r8}]
        lde  r10, @rr8
        ; branch t.26.1{r10} gt 0: while_27_body, while_27_break
        cp   r10, #%00
        jr   ugt, while__27__body
while__27__break:
        ; 284:2 if revealStackSize != 255
        ; addrof a.41.1{r8}, revealStackSize
        ld   r8, #hi(var_5)
        ld   r9, #lo(var_5)
        ; load t.42.1{r10}, [a.41.1{r8}]
        lde  r10, @rr8
        ; branch t.42.1{r10} notequals 255: maybeRevealAround@u8@u8_ret
        cp   r10, #%ff
        jr   ne, maybeRevealAround_Pu8_Pu8__ret
        ; const changed.1{r8}, 1
        ld   r8, #%01
        ; 289:2 while changed
        jr   while__30

while__30__body:
        ; const changed.3{r8}, 0
        ld   r8, #%00
        ; const index.3{r9}, 0
        ld   r9, #%00
        ld   r10, #%00
        ; const r.1{r11}, 0
        ld   r11, #%00
        ; 293:3 for r < 20
        jr   for__31

for__31__body:
        ; const c.1{r12}, 0
        ld   r12, #%00
        ; 294:4 for c < 38
        jr   for__32

for__32__body:
        ; addrof t.43.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.43.2{r4}, index.5{r9}
        add  r5, r10
        adc  r4, r9
        ; load cell.1{r13}, [t.43.2{r4}]
        lde  r13, @rr4
        ; 296:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.44.1{r4}, cell.1{r13}
        ld   r4, r13
        ; and t.44.1{r4}, 32
        and  r4, #%20
        ; branch t.44.1{r4} equals 0: for_32_continue
        cp   r4, #%00
        jr   eq, for__32__continue
        ; and t.45.1{r13}, 128
        and  r13, #%80
        ; branch t.45.1{r13} notequals 0: for_32_continue
        cp   r13, #%00
        jr   ne, for__32__continue
        ; 299:5 if [...] & 15 != 0
        ; addrof t.48.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.48.2{r4}, index.5{r9}
        add  r5, r10
        adc  r4, r9
        ; load t.47.1{r13}, [t.48.2{r4}]
        lde  r13, @rr4
        ; and t.46.1{r13}, 15
        and  r13, #%0f
        ; branch t.46.1{r13} notequals 0: for_32_continue
        cp   r13, #%00
        jr   ne, for__32__continue
        ; 303:5 if revealNeighbors@u8@u8@i16([ExprVarAccess[varName=r, index=6, scope=function, type=u8, varIsArray=false, location=303:24], ExprVarAccess[varName=c, index=7, scope=function, type=u8, varIsArray=false, location=303:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=303:30]])
        ; move r.2{r0}, r.2{r11}
        ld   r0, r11
        ; move c.2{r1}, c.2{r12}
        ld   r1, r12
        ; move index.5{r2}, index.5{r9}
        ld   r2, r9
        ld   r3, r10
        ; call t.49.1{r0} = revealNeighbors@u8@u8@i16[r.2{r0}, c.2{r1}, index.5{r2}] -> bool
        call revealNeighbors_Pu8_Pu8_Pi16
        ; branch t.49.1{r0} equals 0: for_32_continue
        cp   r0, #%00
        jr   eq, for__32__continue
        ; const changed.9{r8}, 1
        ld   r8, #%01
for__32__continue:
        ; add c.6{r12}, 1
        inc  r12
        ; add index.9{r9}, 1
        add  r10, #%01
        adc  r9, #%00
for__32:
        ; branch c.2{r12} lt 38: for_32_body
        cp   r12, #%26
        jr   ult, for__32__body
        ; add r.6{r11}, 1
        inc  r11
for__31:
        ; branch r.2{r11} lt 20: for_31_body
        cp   r11, #%14
        jr   ult, for__31__body
        ; branch changed.4{r8} equals 0: maybeRevealAround@u8@u8_ret
        cp   r8, #%00
        jr   eq, maybeRevealAround_Pu8_Pu8__ret
        ; const r.4{r11}, 20
        ld   r11, #%14
        ; 314:3 while true
        jr   while__38

if__39__end:
        ; sub r.7{r11}, 1
        dec  r11
        ; const c.3{r12}, 38
        ld   r12, #%26
        ; 321:4 while true
        jr   while__40

if__41__end:
        ; sub c.7{r12}, 1
        dec  r12
        ; sub index.10{r9}, 1
        sub  r10, #%01
        sbc  r9, #%00
        ; addrof t.50.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.50.2{r4}, index.10{r9}
        add  r5, r10
        adc  r4, r9
        ; load cell.2{r13}, [t.50.2{r4}]
        lde  r13, @rr4
        ; 328:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.51.1{r4}, cell.2{r13}
        ld   r4, r13
        ; and t.51.1{r4}, 32
        and  r4, #%20
        ; branch t.51.1{r4} equals 0: while_40
        cp   r4, #%00
        jr   eq, while__40
        ; and t.52.1{r13}, 128
        and  r13, #%80
        ; branch t.52.1{r13} notequals 0: while_40
        cp   r13, #%00
        jr   ne, while__40
        ; 331:5 if [...] & 15 != 0
        ; addrof t.55.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.55.2{r4}, index.10{r9}
        add  r5, r10
        adc  r4, r9
        ; load t.54.1{r13}, [t.55.2{r4}]
        lde  r13, @rr4
        ; and t.53.1{r13}, 15
        and  r13, #%0f
        ; branch t.53.1{r13} notequals 0: while_40
        cp   r13, #%00
        jr   ne, while__40
        ; 335:5 if revealNeighbors@u8@u8@i16([ExprVarAccess[varName=r, index=9, scope=function, type=u8, varIsArray=false, location=335:24], ExprVarAccess[varName=c, index=10, scope=function, type=u8, varIsArray=false, location=335:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=335:30]])
        ; move r.7{r0}, r.7{r11}
        ld   r0, r11
        ; move c.7{r1}, c.7{r12}
        ld   r1, r12
        ; move index.10{r2}, index.10{r9}
        ld   r2, r9
        ld   r3, r10
        ; call t.56.1{r0} = revealNeighbors@u8@u8@i16[r.7{r0}, c.7{r1}, index.10{r2}] -> bool
        call revealNeighbors_Pu8_Pu8_Pi16
        ; branch t.56.1{r0} equals 0: while_40
        cp   r0, #%00
        jr   eq, while__40
        ; const changed.10{r0}, 1
        ld   r0, #%01
        ; move changed.7{r8}, changed.10{r0}
        ld   r8, r0
while__40:
        ; branch c.4{r12} notequals 0: if_41_end, while_38
        cp   r12, #%00
        jr   ne, if__41__end
while__38:
        ; branch r.5{r11} notequals 0: if_39_end, while_30
        cp   r11, #%00
        jr   ne, if__39__end
while__30:
        ; branch changed.2{r8} notequals 0: while_30_body, maybeRevealAround@u8@u8_ret
        cp   r8, #%00
        jr   ne, while__30__body
maybeRevealAround_Pu8_Pu8__ret:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void pushReveal@u8@u8@i16
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; arg index (i16): r2
pushReveal_Pu8_Pu8_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; addrof a.4.1{r4}, revealStackSize
        ld   r4, #hi(var_5)
        ld   r5, #lo(var_5)
        ; load stackSize.1{r6}, [a.4.1{r4}]
        lde  r6, @rr4
        ; 345:2 if stackSize >= 16
        ; branch stackSize.1{r6} gteq 16: if_46_then
        cp   r6, #%10
        jr   uge, if__46__then
        ; cast t.8.1{r4}(i16), stackSize.1{r6}(u8)
        ld   r5, r6
        ld   r4, #0
        ; addrof t.7.1{r8}, revealStackRows
        ld   r8, #hi(var_1)
        ld   r9, #lo(var_1)
        ; add t.7.2{r8}, t.8.1{r4}
        add  r9, r5
        adc  r8, r4
        ; store [t.7.2{r8}], param.row{r0}
        lde  @rr8, r0
        ; addrof t.9.1{r8}, revealStackColumns
        ld   r8, #hi(var_2)
        ld   r9, #lo(var_2)
        ; add t.9.2{r8}, t.10.1{r4}
        add  r9, r5
        adc  r8, r4
        ; store [t.9.2{r8}], param.column{r1}
        lde  @rr8, r1
        ; addrof a.11.1{r0}, revealStackIndexTop
        ld   r0, #hi(var_4)
        ld   r1, #lo(var_4)
        ; load t.12.1{r4}, [a.11.1{r0}]
        lde  r4, @rr0
        incw r0
        lde  r5, @rr0
        decw r0
        ; store [t.12.1{r4}], param.index{r2}
        lde  @rr4, r2
        incw r4
        lde  @rr4, r3
        decw r4
        ; move t.15.1{r2}, t.15.1{r4}
        ld   r2, r4
        ld   r3, r5
        ; move t.13.1{r0}, t.15.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.13.1{r0}, 2
        add  r1, #%02
        adc  r0, #%00
        ; addrof a.16.1{r2}, revealStackIndexTop
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.16.1{r2}], t.13.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; move t.17.1{r0}, stackSize.1{r6}
        ld   r0, r6
        ; add t.17.1{r0}, 1
        inc  r0
        ; addrof a.18.1{r2}, revealStackSize
        ld   r2, #hi(var_5)
        ld   r3, #lo(var_5)
        ; store [a.18.1{r2}], t.17.1{r0}
        lde  @rr2, r0
        jr   pushReveal_Pu8_Pu8_Pi16__ret

if__46__then:
        ; const t.5.1{r0}, 255
        ld   r0, #%ff
        ; addrof a.6.1{r2}, revealStackSize
        ld   r2, #hi(var_5)
        ld   r3, #lo(var_5)
        ; store [a.6.1{r2}], t.5.1{r0}
        lde  @rr2, r0
        ; 347:3 return
pushReveal_Pu8_Pu8_Pi16__ret:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; bool revealNeighbors@u8@u8@i16
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; arg index (i16): r2
        ; var c.2 (u8): SP+8
        ; var changed.4 (bool): SP+9
        ; var cell.2 (u8): SP+10
        ; var changed.5 (bool): SP+11
revealNeighbors_Pu8_Pu8_Pi16:
        decw SPH
        decw SPH
        decw SPH
        decw SPH
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
        ; 359:2 if rowFrom > 0
        ; branch rowFrom.1{r8} gt 0: if_47_then
        cp   r8, #%00
        jr   ugt, if__47__then
        ; move index.1{r9}, param.index{r2}
        ld   r10, r3
        ld   r9, r2
        jr   if__47__end

if__47__then:
        ; sub rowFrom.3{r8}, 1
        dec  r8
        ; move index.2{r9}, param.index{r2}
        ld   r10, r3
        ld   r9, r2
        ; sub index.2{r9}, 38
        sub  r10, #%26
        sbc  r9, #%00
if__47__end:
        ; move rowTo.1{r11}, param.row{r0}
        ld   r11, r0
        ; add rowTo.1{r11}, 1
        inc  r11
        ; 364:2 if rowTo >= 20
        ; branch rowTo.1{r11} lt 20: if_48_end
        cp   r11, #%14
        jr   ult, if__48__end
        ; sub rowTo.3{r11}, 1
        dec  r11
if__48__end:
        ; move colFrom.1{r12}, param.column{r1}
        ld   r12, r1
        ; 369:2 if colFrom > 0
        ; branch colFrom.1{r12} lteq 0: if_49_end
        cp   r12, #%00
        jr   ule, if__49__end
        ; sub colFrom.3{r12}, 1
        dec  r12
        ; sub index.5{r9}, 1
        sub  r10, #%01
        sbc  r9, #%00
if__49__end:
        ; move colTo.1{r13}, param.column{r1}
        ld   r13, r1
        ; add colTo.1{r13}, 1
        inc  r13
        ; 374:2 if colTo >= 38
        ; branch colTo.1{r13} lt 38: if_50_end
        cp   r13, #%26
        jr   ult, if__50__end
        ; sub colTo.3{r13}, 1
        dec  r13
if__50__end:
        ; const changed.1{r3}, 0
        ld   r3, #%00
        ; 378:2 for r <= rowTo
        ; move changed.2{r0}, changed.1{r3}
        ld   r0, r3
        jr   for__51

for__51__body:
        ; move c.1{r3}, colFrom.2{r12}
        ld   r3, r12
        ; 379:3 for c <= colTo
        ; move changed.3{r4}, changed.2{r0}
        ld   r4, r0
        ; move c.2{r2}, c.1{r3}
        ld   r2, r3
        ; move changed.3{r1}, changed.3{r4}
        ld   r1, r4
        jr   for__52

for__52__body:
        ; move changed.3{r4}, changed.3{r1}
        ld   r4, r1
        ; addrof t.11.1{r6}, field
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.11.2{r6}, index.8{r9}
        add  r7, r10
        adc  r6, r9
        ; load cell.1{r3}, [t.11.2{r6}]
        lde  r3, @rr6
        ; 381:4 if cell & 32 != 0
        ; move t.12.1{r5}, cell.1{r3}
        ld   r5, r3
        ; and t.12.1{r5}, 32
        and  r5, #%20
        ; branch t.12.1{r5} equals 0: if_53_end
        cp   r5, #%00
        jr   eq, if__53__end
        ; move changed.4{r3}, changed.3{r4}
        ld   r3, r4
        ; addrof memVarAddr{r14}, changed.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], changed.4{r3}
        lde  @rr14, r3
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], c.2{r2}
        lde  @rr14, r2
        ; addrof memVarAddr{r14}, changed.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        jr   for__52__continue

if__53__end:
        ; move cell.2{r0}, cell.1{r3}
        ld   r0, r3
        ; or cell.2{r0}, 32
        or  r0, #%20
        ; addrof t.13.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.13.2{r4}, index.8{r9}
        add  r5, r10
        adc  r4, r9
        ; store [t.13.2{r4}], cell.2{r0}
        lde  @rr4, r0
        ; addrof memVarAddr{r14}, cell.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], cell.2{r0}
        lde  @rr14, r0
        ; move r.2{r1}, r.2{r8}
        ld   r1, r8
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], c.2{r2}
        lde  @rr14, r2
        ; call printCellAt@u8@u8@u8[cell.2{r0}, r.2{r1}, c.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
        ; const changed.5{r4}, 1
        ld   r4, #%01
        ; 389:4 if cell & 143 == 0 && revealStackSize != 255
        ; addrof memVarAddr{r14}, cell.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load cell.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; move t.14.1{r5}, cell.2{r0}
        ld   r5, r0
        ; and t.14.1{r5}, 143
        and  r5, #%8f
        ; branch t.14.1{r5} equals 0: and_55
        cp   r5, #%00
        jr   eq, and__55
        ; move changed.4{r1}, changed.4{r4}
        ld   r1, r4
        jr   for__52__continue

and__55:
        ; addrof a.15.1{r6}, revealStackSize
        ld   r6, #hi(var_5)
        ld   r7, #lo(var_5)
        ; load t.16.1{r5}, [a.15.1{r6}]
        lde  r5, @rr6
        ; branch t.16.1{r5} notequals 255: if_54_then
        cp   r5, #%ff
        jr   ne, if__54__then
        ; addrof memVarAddr{r14}, changed.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], changed.4{r4}
        lde  @rr14, r4
        ; move changed.4{r1}, changed.4{r4}
        ld   r1, r4
        jr   for__52__continue

if__54__then:
        ; addrof memVarAddr{r14}, changed.5
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], changed.5{r4}
        lde  @rr14, r4
        ; move r.2{r0}, r.2{r8}
        ld   r0, r8
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load c.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; move c.2{r1}, c.2{r2}
        ld   r1, r2
        ; move index.8{r2}, index.8{r9}
        ld   r2, r9
        ld   r3, r10
        ; call pushReveal@u8@u8@i16[r.2{r0}, c.2{r1}, index.8{r2}]
        call pushReveal_Pu8_Pu8_Pi16
        ; addrof memVarAddr{r14}, changed.5
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; load changed.5{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
for__52__continue:
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load c.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; add c.4{r2}, 1
        inc  r2
        ; move index.11{r3}, index.8{r9}
        ld   r3, r9
        ld   r4, r10
        ; add index.11{r3}, 1
        add  r4, #%01
        adc  r3, #%00
        ; move index.8{r9}, index.11{r3}
        ld   r10, r4
        ld   r9, r3
for__52:
        ; branch c.2{r2} lteq colTo.2{r13}: for_52_body
        cp   r2, r13
        jr   ule, for__52__body
        ; cast t.20.1{r2}(i16), colTo.2{r13}(u8)
        ld   r3, r13
        ld   r2, #0
        ; move t.19.1{r4}, index.8{r9}
        ld   r4, r9
        ld   r5, r10
        ; sub t.19.1{r4}, t.20.1{r2}
        sub  r5, r3
        sbc  r4, r2
        ; cast t.21.1{r2}(i16), colFrom.2{r12}(u8)
        ld   r3, r12
        ld   r2, #0
        ; add t.18.1{r4}, t.21.1{r2}
        add  r5, r3
        adc  r4, r2
        ; move t.17.1{r2}, t.18.1{r4}
        ld   r2, r4
        ld   r3, r5
        ; add t.17.1{r2}, 38
        add  r3, #%26
        adc  r2, #%00
        ; sub index.9{r2}, 1
        decw r2
        ; move r.4{r4}, r.2{r8}
        ld   r4, r8
        ; add r.4{r4}, 1
        inc  r4
        ; move index.7{r9}, index.9{r2}
        ld   r10, r3
        ld   r9, r2
        ; move changed.2{r0}, changed.3{r1}
        ld   r0, r1
        ; move r.2{r8}, r.4{r4}
        ld   r8, r4
for__51:
        ; branch r.2{r8} lteq rowTo.2{r11}: for_51_body
        cp   r8, r11
        jr   ule, for__51__body
        ; 395:9 return changed
        ; restore clobbered non-volatile registers
        pop  r15
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        incw SPH
        incw SPH
        incw SPH
        incw SPH
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
        ; begin initialize global variables
        ; const t.8.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; addrof a.9.1{r10}, revealStackIndexTop
        ld   r10, #hi(var_4)
        ld   r11, #lo(var_4)
        ; store [a.9.1{r10}], t.8.1{r8}
        lde  @rr10, r8
        incw r10
        lde  @rr10, r9
        decw r10
        ; const t.10.1{r8}, 0
        ld   r8, #%00
        ; addrof a.11.1{r10}, revealStackSize
        ld   r10, #hi(var_5)
        ld   r11, #lo(var_5)
        ; store [a.11.1{r10}], t.10.1{r8}
        lde  @rr10, r8
        ; end initialize global variables
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
        ; 407:2 while true
        jr   while__56

if__57__end:
        ; const t.13.1{r2}, 1
        ld   r2, #%01
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call showCursor@u8@u8@bool[row.2{r0}, col.2{r1}, t.13.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; call chr.1{r0} = getChar[] -> i16
        call getChar
        ; move chr.1{r12}, chr.1{r0}
        ld   r13, r1
        ld   r12, r0
        ; const t.14.1{r2}, 0
        ld   r2, #%00
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call showCursor@u8@u8@bool[row.2{r0}, col.2{r1}, t.14.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; 416:3 if chr == 27
        ; branch chr.1{r12} equals 27: main_ret
        cp   r13, #%1b
        jr   ne, .notEquals6
        cp   r12, #%00
        jr   eq, main__ret
.notEquals6:
        ; branch chr.1{r12} equals 13: if_59_then
        cp   r13, #%0d
        jr   ne, .notEquals7
        cp   r12, #%00
        jr   eq, if__59__then
.notEquals7:
        ; branch chr.1{r12} notequals 3: if_63_else, if_63_then
        cp   r13, #%03
        jr   ne, if__63__else
        cp   r12, #%00
        jr   ne, if__63__else
        jr   if__63__then

if__59__then:
        ; branch bombsLeft.2{r10} gteq 0: if_60_end, if_60_then
        cp   r10, #%00
        jr   gt, if__60__end
        jr   ne, .gt8
        cp   r11, #%00
        jr   uge, if__60__end
.gt8:
        jr   if__60__then

if__63__else:
        ; branch chr.1{r12} notequals 4: if_65_else, if_65_then
        cp   r13, #%04
        jr   ne, if__65__else
        cp   r12, #%00
        jr   ne, if__65__else
        jr   if__65__then

if__63__then:
        ; branch row.2{r9} lteq 0: while_56, if_64_then
        cp   r9, #%00
        jr   ule, while__56
        jr   if__64__then

if__60__then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call bombsLeft.4{r0} = initField@u8@u8[row.2{r0}, col.2{r1}] -> i16
        call initField_Pu8_Pu8
        ; move bombsLeft.3{r10}, bombsLeft.4{r0}
        ld   r11, r1
        ld   r10, r0
        jr   if__60__end

if__65__else:
        ; branch chr.1{r12} notequals 1: if_67_else, if_67_then
        cp   r13, #%01
        jr   ne, if__67__else
        cp   r12, #%00
        jr   ne, if__67__else
        jr   if__67__then

if__65__then:
        ; branch row.2{r9} gteq 19: while_56, if_66_then
        cp   r9, #%13
        jr   uge, while__56
        jr   if__66__then

if__64__then:
        ; sub row.4{r9}, 1
        dec  r9
        jr   while__56

if__60__end:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call index.1{r0} = rowColumnToCell@u8@u8[row.2{r0}, col.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.15.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.15.2{r12}, index.1{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell.1{r2}, [t.15.2{r12}]
        lde  r2, @rr12
        ; 426:4 if cell & 32 == 0
        ; move t.16.1{r12}, cell.1{r2}
        ld   r12, r2
        ; and t.16.1{r12}, 32
        and  r12, #%20
        ; branch t.16.1{r12} notequals 0: if_61_end, if_61_then
        cp   r12, #%00
        jr   ne, if__61__end
        jr   if__61__then

if__67__else:
        ; branch chr.1{r12} notequals 2: if_69_else, if_69_then
        cp   r13, #%02
        jr   ne, if__69__else
        cp   r12, #%00
        jr   ne, if__69__else
        jr   if__69__then

if__67__then:
        ; branch col.2{r8} lteq 0: while_56, if_68_then
        cp   r8, #%00
        jr   ule, while__56
        jr   if__68__then

if__66__then:
        ; add row.5{r9}, 1
        inc  r9
        jr   while__56

if__61__then:
        ; move t.17.1{r12}, cell.1{r2}
        ld   r12, r2
        ; or t.17.1{r12}, 32
        or  r12, #%20
        ; addrof t.18.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.18.2{r4}, index.1{r0}
        add  r5, r1
        adc  r4, r0
        ; store [t.18.2{r4}], t.17.1{r12}
        lde  @rr4, r12
        jr   if__61__end

if__69__else:
        ; branch chr.1{r12} notequals 32: while_56, if_71_then
        cp   r13, #%20
        jr   ne, while__56
        cp   r12, #%00
        jr   ne, while__56
        jr   if__71__then

if__69__then:
        ; branch col.2{r8} gteq 37: while_56, if_70_then
        cp   r8, #%25
        jr   uge, while__56
        jr   if__70__then

if__68__then:
        ; sub col.5{r8}, 1
        dec  r8
        jr   while__56

if__61__end:
        ; 429:4 if cell & 128 != 0
        ; move t.19.1{r12}, cell.1{r2}
        ld   r12, r2
        ; and t.19.1{r12}, 128
        and  r12, #%80
        ; branch t.19.1{r12} equals 0: if_62_end, if_62_then
        cp   r12, #%00
        jr   eq, if__62__end
        jr   if__62__then

if__71__then:
        ; branch bombsLeft.2{r10} lt 0: while_56, if_72_then
        cp   r10, #%00
        jr   lt, while__56
        jr   ne, .lt9
        cp   r11, #%00
        jr   ult, while__56
.lt9:
        jr   if__72__then

if__70__then:
        ; add col.6{r8}, 1
        inc  r8
        jr   while__56

if__62__end:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call maybeRevealAround@u8@u8[row.2{r0}, col.2{r1}]
        call maybeRevealAround_Pu8_Pu8
        jr   while__56

if__72__then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call index.2{r0} = rowColumnToCell@u8@u8[row.2{r0}, col.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.21.1{r12}, field
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.21.2{r12}, index.2{r0}
        add  r13, r1
        adc  r12, r0
        ; load cell.3{r3}, [t.21.2{r12}]
        lde  r3, @rr12
        ; 465:5 if cell & 32 == 0
        ; move t.22.1{r12}, cell.3{r3}
        ld   r12, r3
        ; and t.22.1{r12}, 32
        and  r12, #%20
        ; branch t.22.1{r12} notequals 0: while_56
        cp   r12, #%00
        jr   ne, while__56
        ; move cell.4{r12}, cell.3{r3}
        ld   r12, r3
        ; xor cell.4{r12}, 64
        xor r12, #%40
        ; 467:6 if cell & 128 != 0
        ; move t.23.1{r13}, cell.4{r12}
        ld   r13, r12
        ; and t.23.1{r13}, 128
        and  r13, #%80
        ; branch t.23.1{r13} equals 0: if_74_end
        cp   r13, #%00
        jr   eq, if__74__end
        ; 468:7 if cell & 64 != 0
        ; move t.24.1{r13}, cell.4{r12}
        ld   r13, r12
        ; and t.24.1{r13}, 64
        and  r13, #%40
        ; branch t.24.1{r13} notequals 0: if_75_then
        cp   r13, #%00
        jr   ne, if__75__then
        ; add bombsLeft.7{r10}, 1
        incw r10
        jr   if__74__end

if__75__then:
        ; sub bombsLeft.8{r10}, 1
        decw r10
if__74__end:
        ; addrof t.25.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.25.2{r4}, index.2{r0}
        add  r5, r1
        adc  r4, r0
        ; store [t.25.2{r4}], cell.4{r12}
        lde  @rr4, r12
        ; move cell.4{r0}, cell.4{r12}
        ld   r0, r12
        ; move row.2{r1}, row.2{r9}
        ld   r1, r9
        ; move col.2{r2}, col.2{r8}
        ld   r2, r8
        ; call printCellAt@u8@u8@u8[cell.4{r0}, row.2{r1}, col.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
while__56:
        ; branch bombsLeft.2{r10} notequals 0: if_57_end
        cp   r11, #%00
        jr   ne, if__57__end
        cp   r10, #%00
        jr   ne, if__57__end
        ; const t.12.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.12.1{r0}]
        call printString_P_Pu8
        jr   main__ret

if__62__then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call printCellAt@u8@u8[row.2{r0}, col.2{r1}]
        call printCellAt_Pu8_Pu8
        ; const t.20.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.20.1{r0}]
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

        ; variable 0: field[] (u8*/760)
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
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 1: revealStackRows[] (u8*/16)
var_1:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 2: revealStackColumns[] (u8*/16)
var_2:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 3: revealStackIndices[] (i16*/32)
var_3:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 4: revealStackIndexTop (i16*/2)
var_4:
        .data %00 %00
        ; variable 5: revealStackSize (u8/1)
var_5:
        .data %00

string_0:
        .data " |" %00
string_1:
        .data " You've cleaned the field!" %00
string_2:
        .data "boom! you've lost" %00

