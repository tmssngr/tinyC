        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; i16 rowColumnToCell_Pu8_Pu8
        ; arg row (u8): r0
        ; arg column (u8): r1
rowColumnToCell_Pu8_Pu8:
        ; cast r.1{r2}(i16), param.row{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; cast c.1{r0}(i16), param.column{r1}(u8)
        ld   r0, #0
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
        ; add t.4.1{r2}, c.1{r0}
        add  r3, r1
        adc  r2, r0
        ; move t.4.1{r0}, t.4.1{r2}
        ld   r0, r2
        ld   r1, r3
        ret

        ; i16 columnToX_Pu8
        ; arg column (u8): r0
columnToX_Pu8:
        ; cast c.1{r0}(i16), param.column{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; 39:10 return c
        ret

        ; void printCellAt_Pu8_Pu8
        ; arg row (u8): r0
        ; arg column (u8): r1
printCellAt_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; call t.4.1{r0} = rowColumnToCell_Pu8_Pu8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.3.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.3.2{r2}, t.4.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load cell.1{r0}, [t.3.2{r2}]
        lde  r0, @rr2
        ; move param.row{r1}, param.row{r8}
        ld   r1, r8
        ; move param.column{r2}, param.column{r9}
        ld   r2, r9
        ; call printCellAt_Pu8_Pu8_Pu8[cell.1{r0}, param.row{r1}, param.column{r2}]
        call printCellAt_Pu8_Pu8_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void printCellAt_Pu8_Pu8_Pu8
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
        ; call x.1{r0} = columnToX_Pu8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x.1{r2}, x.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; cast t.4.1{r0}(i16), param.row{r9}(u8)
        ld   r1, r9
        ld   r0, #0
        ; call setCursor_Pi16_Pi16[t.4.1{r0}, x.1{r2}]
        call setCursor_Pi16_Pi16
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; move param.row{r1}, param.row{r9}
        ld   r1, r9
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ; call printCell_Pu8_Pu8_Pu8[param.cell{r0}, param.row{r1}, param.column{r2}]
        call printCell_Pu8_Pu8_Pu8
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printCell_Pu8_Pu8_Pu8
        ; arg cell (u8): r0
        ; arg row (u8): r1
        ; arg column (u8): r2
printCell_Pu8_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; const chr.1{r3}, 46
        ld   r3, #%2e
        ; 58:2 if cell & 32 != 0
        ; move t.6.1{r4}, param.cell{r0}
        ld   r4, r0
        ; and t.6.1{r4}, 32
        and  r4, #%20
        ; branch t.6.1{r4} notequals 0: if_1_then
        cp   r4, #%00
        jr   ne, if_1_then
        ; 73:7 if cell & 64 != 0
        ; and t.10.1{r0}, 64
        and  r0, #%40
        ; branch t.10.1{r0} equals 0: printCell_Pu8_Pu8_Pu8.no_critical_edge_10, if_4_then
        cp   r0, #%00
        jr   eq, printCell_Pu8_Pu8_Pu8.no_critical_edge_10
        jr   if_4_then

if_1_then:
        ; 59:3 if cell & 128 != 0
        ; and t.7.1{r0}, 128
        and  r0, #%80
        ; branch t.7.1{r0} equals 0: if_2_else, if_2_then
        cp   r0, #%00
        jr   eq, if_2_else
        jr   if_2_then

printCell_Pu8_Pu8_Pu8.no_critical_edge_10:
        ; move chr.2{r8}, chr.1{r3}
        ld   r8, r3
        jr   if_1_end

if_4_then:
        ; const chr.3{r0}, 35
        ld   r0, #%23
        ; move chr.2{r8}, chr.3{r0}
        ld   r8, r0
        jr   if_1_end

if_2_else:
        ; move param.row{r0}, param.row{r1}
        ld   r0, r1
        ; move param.column{r1}, param.column{r2}
        ld   r1, r2
        ; call index.1{r0} = rowColumnToCell_Pu8_Pu8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.9.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.9.2{r2}, index.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.8.1{r0}, [t.9.2{r2}]
        lde  r0, @rr2
        ; and count.1{r0}, 15
        and  r0, #%0f
        ; 65:4 if count > 0
        ; branch count.1{r0} lteq 0: if_3_else, if_3_then
        cp   r0, #%00
        jr   ule, if_3_else
        jr   if_3_then

if_2_then:
        ; const chr.4{r0}, 42
        ld   r0, #%2a
        ; move chr.2{r8}, chr.4{r0}
        ld   r8, r0
        jr   if_1_end

if_3_else:
        ; const chr.5{r0}, 32
        ld   r0, #%20
        ; move chr.2{r8}, chr.5{r0}
        ld   r8, r0
        jr   if_1_end

if_3_then:
        ; add chr.6{r0}, 48
        add  r0, #%30
        ; move chr.2{r8}, chr.6{r0}
        ld   r8, r0
if_1_end:
        ; move chr.2{r0}, chr.2{r8}
        ld   r0, r8
        ; call printChar_Pu8[chr.2{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void initializeScreen
initializeScreen:
        ; const arg.0.0{r0}, 12
        ld   r0, #%0c
        ; call printChar_Pu8[arg.0.0{r0}]
        call printChar_Pu8
        ; call printField[]
        call printField
        ret

        ; void printField
printField:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const arg.0.0{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const arg.0.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const row.1{r0}, 0
        ld   r0, #%00
        ; 92:2 for row < 20
        ; move row.2{r8}, row.1{r0}
        ld   r8, r0
        jr   for_5

for_5_body:
        ; cast t.3.1{r0}(i16), row.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; const arg.1.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[t.3.1{r0}, arg.1.1{r2}]
        call setCursor_Pi16_Pi16
        ; const column.1{r0}, 0
        ld   r0, #%00
        ; 97:3 for column < 38
        ; move column.2{r9}, column.1{r0}
        ld   r9, r0
        jr   for_6

for_6_body:
        ; move row.2{r0}, row.2{r8}
        ld   r0, r8
        ; move column.2{r1}, column.2{r9}
        ld   r1, r9
        ; call t.5.1{r0} = rowColumnToCell_Pu8_Pu8[row.2{r0}, column.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.4.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.4.2{r2}, t.5.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load cell.1{r0}, [t.4.2{r2}]
        lde  r0, @rr2
        ; move row.2{r1}, row.2{r8}
        ld   r1, r8
        ; move column.2{r2}, column.2{r9}
        ld   r2, r9
        ; call printCell_Pu8_Pu8_Pu8[cell.1{r0}, row.2{r1}, column.2{r2}]
        call printCell_Pu8_Pu8_Pu8
        ; move column.3{r0}, column.2{r9}
        ld   r0, r9
        ; add column.3{r0}, 1
        inc  r0
        ; move column.2{r9}, column.3{r0}
        ld   r9, r0
for_6:
        ; branch column.2{r9} lt 38: for_6_body
        cp   r9, #%26
        jr   ult, for_6_body
        ; move row.4{r0}, row.2{r8}
        ld   r0, r8
        ; add row.4{r0}, 1
        inc  r0
        ; move row.2{r8}, row.4{r0}
        ld   r8, r0
for_5:
        ; branch row.2{r8} lt 20: for_5_body
        cp   r8, #%14
        jr   ult, for_5_body
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void showCursor_Pu8_Pu8_Pbool
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; arg show (bool): r2
showCursor_Pu8_Pu8_Pbool:
        ; save clobbered non-volatile registers
        push r8
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; branch param.show{r2} equals 0: showCursor_Pu8_Pu8_Pbool_ret
        cp   r2, #%00
        jr   eq, showCursor_Pu8_Pu8_Pbool_ret
        ; move param.column{r0}, param.column{r1}
        ld   r0, r1
        ; call x.1{r0} = columnToX_Pu8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x.1{r2}, x.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; cast t.6.1{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; call setCursor_Pi16_Pi16[t.6.1{r0}, x.1{r2}]
        call setCursor_Pi16_Pi16
showCursor_Pu8_Pu8_Pbool_ret:
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; i16 abs_Pi16
        ; arg a (i16): r0
abs_Pi16:
        ; move param.a{r2}, a{r0}
        ld   r3, r1
        ld   r2, r0
        ; branch param.a{r2} lt 0: if_10_then
        cp   r2, #%00
        jr   lt, if_10_then
        jr   ne, .lt1
        cp   r3, #%00
        jr   ult, if_10_then
.lt1:
        ; 186:9 return a
        jr   abs_Pi16_ret

if_10_then:
        ; 184:10 return -a
        ; neg t.1.1{r2}, param.a{r2}
        com  r2
        com  r3
        incw r2
        ; move t.1.1{r0}, t.1.1{r2}
        ld   r0, r2
        ld   r1, r3
abs_Pi16_ret:
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
        jr   for_11

for_11_body:
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
for_11:
        ; branch i.2{r2} gt 0: for_11_body
        cp   r2, #%00
        jr   gt, for_11_body
        jr   ne, .gt2
        cp   r3, #%00
        jr   ugt, for_11_body
.gt2:
        ret

        ; i16 initField_Pu8_Pu8
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
        ; const bombCount.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const bombs.1{r2}, 68
        ld   r2, #%00
        ld   r3, #%44
        ; 200:2 for bombs > 0
        ; move bombCount.2{r12}, bombCount.1{r0}
        ld   r13, r1
        ld   r12, r0
        ; move bombs.2{r0}, bombs.1{r2}
        ld   r0, r2
        ld   r1, r3
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
        jr   for_12

for_12_body:
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
        ; mod column.1{r0}, 38
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%26
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], column.1{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; 203:3 if abs_Pi16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=203:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=203:20], location=203:18]]) > 1 || abs_Pi16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=204:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=204:20], location=204:18]]) > 1
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load row.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; move t.11.1{r2}, row.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; sub t.11.1{r2}, r.1{r8}
        sub  r3, r9
        sbc  r2, r8
        ; move t.11.1{r0}, t.11.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; call t.10.1{r0} = abs_Pi16[t.11.1{r0}] -> i16
        call abs_Pi16
        ; branch t.10.1{r0} gt 1: if_13_then
        cp   r0, #%00
        jr   gt, if_13_then
        jr   ne, .gt3
        cp   r1, #%01
        jr   ugt, if_13_then
.gt3:
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load column.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; move t.13.1{r2}, column.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; sub t.13.1{r2}, c.1{r10}
        sub  r3, r11
        sbc  r2, r10
        ; move t.13.1{r0}, t.13.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; call t.12.1{r0} = abs_Pi16[t.13.1{r0}] -> i16
        call abs_Pi16
        ; branch t.12.1{r0} lteq 1: for_12_continue, if_13_then
        cp   r0, #%00
        jr   lt, for_12_continue
        jr   ne, .lt4
        cp   r1, #%01
        jr   ule, for_12_continue
.lt4:
if_13_then:
        ; 205:4 if setBomb_Pu8_Pu8([ExprCast[typeString=u8, expression=ExprVarAccess[varName=row, index=6, scope=function, type=i16, varIsArray=false, location=205:15], type=u8, location=205:22], ExprCast[typeString=u8, expression=ExprVarAccess[varName=column, index=7, scope=function, type=i16, varIsArray=false, location=205:26], type=u8, location=205:36]])
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load row.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; cast t.15.1{r0}(u8), row.1{r0}(i16)
        ld   r0, r1
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load column.1{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        incw r14
        lde  r2, @rr14
        decw r14
        ; cast t.16.1{r1}(u8), column.1{r1}(i16)
        ld   r1, r2
        ; call t.14.1{r0} = setBomb_Pu8_Pu8[t.15.1{r0}, t.16.1{r1}] -> bool
        call setBomb_Pu8_Pu8
        ; branch t.14.1{r0} equals 0: for_12_continue
        cp   r0, #%00
        jr   eq, for_12_continue
        ; move bombCount.5{r0}, bombCount.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; add bombCount.5{r0}, 1
        incw r0
        ; move bombCount.4{r12}, bombCount.5{r0}
        ld   r13, r1
        ld   r12, r0
for_12_continue:
        ; addrof memVarAddr{r14}, bombs.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load bombs.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; sub bombs.5{r0}, 1
        decw r0
for_12:
        ; branch bombs.2{r0} gt 0: for_12_body
        cp   r0, #%00
        jr   gt, for_12_body
        jr   ne, .gt5
        cp   r1, #%00
        jr   ugt, for_12_body
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

        ; bool setBomb_Pu8_Pu8
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
        ; call index.1{r0} = rowColumnToCell_Pu8_Pu8[param.row{r0}, param.column{r1}] -> i16
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
        ; load t.12.1{r0}, [t.13.2{r4}]
        lde  r0, @rr4
        ; branch t.12.1{r0} equals 128: if_16_then
        cp   r0, #%80
        jr   eq, if_16_then
        ; const t.14.1{r0}, 128
        ld   r0, #%80
        ; addrof t.15.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.15.2{r4}, index.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.15.2{r4}], t.14.1{r0}
        lde  @rr4, r0
        ; move rowFrom.1{r3}, param.row{r8}
        ld   r3, r8
        ; 221:2 if rowFrom > 0
        ; branch rowFrom.1{r3} lteq 0: if_17_end, if_17_then
        cp   r3, #%00
        jr   ule, if_17_end
        jr   if_17_then

if_16_then:
        ; const {r0}, 0
        ld   r0, #%00
        jr   setBomb_Pu8_Pu8_ret

if_17_then:
        ; sub rowFrom.3{r3}, 1
        dec  r3
        ; sub index.3{r1}, 38
        sub  r2, #%26
        sbc  r1, #%00
if_17_end:
        ; move rowTo.1{r4}, param.row{r8}
        ld   r4, r8
        ; add rowTo.1{r4}, 1
        inc  r4
        ; 226:2 if rowTo >= 20
        ; branch rowTo.1{r4} lt 20: if_18_end
        cp   r4, #%14
        jr   ult, if_18_end
        ; sub rowTo.3{r4}, 1
        dec  r4
if_18_end:
        ; move colFrom.1{r5}, param.column{r9}
        ld   r5, r9
        ; 231:2 if colFrom > 0
        ; branch colFrom.1{r5} lteq 0: if_19_end
        cp   r5, #%00
        jr   ule, if_19_end
        ; sub colFrom.3{r5}, 1
        dec  r5
        ; sub index.6{r1}, 1
        sub  r2, #%01
        sbc  r1, #%00
if_19_end:
        ; move colTo.1{r6}, param.column{r9}
        ld   r6, r9
        ; add colTo.1{r6}, 1
        inc  r6
        ; 236:2 if colTo >= 38
        ; branch colTo.1{r6} lt 38: if_20_end
        cp   r6, #%26
        jr   ult, if_20_end
        ; sub colTo.3{r6}, 1
        dec  r6
if_20_end:
        ; 241:2 for r <= rowTo
        jr   for_21

for_21_body:
        ; move c.1{r7}, colFrom.2{r5}
        ld   r7, r5
        ; 242:3 for c <= colTo
        jr   for_22

for_22_body:
        ; branch r.2{r3} notequals param.row{r8}: if_23_end
        cp   r3, r8
        jr   ne, if_23_end
        ; branch c.2{r7} equals param.column{r9}: for_22_continue, if_23_end
        cp   r7, r9
        jr   eq, for_22_continue
if_23_end:
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
        jr   ne, for_22_continue
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
for_22_continue:
        ; add c.5{r7}, 1
        inc  r7
        ; add index.13{r1}, 1
        add  r2, #%01
        adc  r1, #%00
for_22:
        ; branch c.2{r7} lteq colTo.2{r6}: for_22_body
        cp   r7, r6
        jr   ule, for_22_body
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
for_21:
        ; branch r.2{r3} lteq rowTo.2{r4}: for_21_body
        cp   r3, r4
        jr   ule, for_21_body
        ; const {r0}, 1
        ld   r0, #%01
setBomb_Pu8_Pu8_ret:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void maybeRevealAround_Pu8_Pu8
        ; arg row (u8): r0
        ; arg column (u8): r1
maybeRevealAround_Pu8_Pu8:
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
        ; call printCellAt_Pu8_Pu8[param.row{r0}, param.column{r1}]
        call printCellAt_Pu8_Pu8
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call index.1{r0} = rowColumnToCell_Pu8_Pu8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; 262:2 if [...] & 15 != 0
        ; addrof t.14.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.14.2{r2}, index.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.13.1{r4}, [t.14.2{r2}]
        lde  r4, @rr2
        ; move t.12.1{r2}, t.13.1{r4}
        ld   r2, r4
        ; and t.12.1{r2}, 15
        and  r2, #%0f
        ; branch t.12.1{r2} notequals 0: maybeRevealAround_Pu8_Pu8_ret
        cp   r2, #%00
        jr   ne, maybeRevealAround_Pu8_Pu8_ret
        ; const t.16.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; addrof t.15.1{r4}, revealStackRows
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; add t.15.2{r4}, t.16.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.15.2{r4}], param.row{r8}
        lde  @rr4, r8
        ; addrof t.17.1{r4}, revealStackColumns
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.17.2{r4}, t.18.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.17.2{r4}], param.column{r9}
        lde  @rr4, r9
        ; addrof a.19.1{r2}, revealStackIndices
        ld   r2, #hi(var_3)
        ld   r3, #lo(var_3)
        ; store [a.19.1{r2}], index.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; move a.21.1{r0}, a.21.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.20.1{r0}, 2
        add  r1, #%02
        adc  r0, #%00
        ; addrof a.22.1{r2}, revealStackIndexTop
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.22.1{r2}], t.20.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; const t.23.1{r0}, 1
        ld   r0, #%01
        ; addrof a.24.1{r2}, revealStackSize
        ld   r2, #hi(var_5)
        ld   r3, #lo(var_5)
        ; store [a.24.1{r2}], t.23.1{r0}
        lde  @rr2, r0
        ; 271:2 while revealStackSize > 0
        jr   while_27

while_27_body:
        ; addrof a.27.1{r0}, revealStackSize
        ld   r0, #hi(var_5)
        ld   r1, #lo(var_5)
        ; load t.28.1{r2}, [a.27.1{r0}]
        lde  r2, @rr0
        ; move stackSize.1{r0}, t.28.1{r2}
        ld   r0, r2
        ; sub stackSize.1{r0}, 1
        dec  r0
        ; move t.29.1{r1}, stackSize.1{r0}
        ld   r1, r0
        ; addrof a.30.1{r2}, revealStackSize
        ld   r2, #hi(var_5)
        ld   r3, #lo(var_5)
        ; store [a.30.1{r2}], t.29.1{r1}
        lde  @rr2, r1
        ; cast t.32.1{r1}(i16), stackSize.1{r0}(u8)
        ld   r2, r0
        ld   r1, #0
        ; addrof t.31.1{r4}, revealStackRows
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; add t.31.2{r4}, t.32.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load row.1{r1}, [t.31.2{r4}]
        lde  r1, @rr4
        ; cast t.34.1{r2}(i16), stackSize.1{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; addrof t.33.1{r4}, revealStackColumns
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.33.2{r4}, t.34.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load column.1{r2}, [t.33.2{r4}]
        lde  r2, @rr4
        ; addrof a.35.1{r4}, revealStackIndexTop
        ld   r4, #hi(var_4)
        ld   r5, #lo(var_4)
        ; load t.36.1{r6}, [a.35.1{r4}]
        lde  r6, @rr4
        incw r4
        lde  r7, @rr4
        decw r4
        ; move stackIndex.1{r4}, t.36.1{r6}
        ld   r4, r6
        ld   r5, r7
        ; add stackIndex.1{r4}, -2
        add  r5, #%fe
        adc  r4, #%ff
        ; move t.37.1{r6}, stackIndex.1{r4}
        ld   r7, r5
        ld   r6, r4
        ; addrof a.38.1{r8}, revealStackIndexTop
        ld   r8, #hi(var_4)
        ld   r9, #lo(var_4)
        ; store [a.38.1{r8}], t.37.1{r6}
        lde  @rr8, r6
        incw r8
        lde  @rr8, r7
        decw r8
        ; load index.2{r6}, [stackIndex.1{r4}]
        lde  r6, @rr4
        incw r4
        lde  r7, @rr4
        decw r4
        ; move row.1{r0}, row.1{r1}
        ld   r0, r1
        ; move column.1{r1}, column.1{r2}
        ld   r1, r2
        ; move index.2{r2}, index.2{r6}
        ld   r2, r6
        ld   r3, r7
        ; call _ = revealNeighbors_Pu8_Pu8_Pi16[row.1{r0}, column.1{r1}, index.2{r2}] -> bool
        call revealNeighbors_Pu8_Pu8_Pi16
        ; 280:3 if revealStackSize == 255
        ; addrof a.39.1{r0}, revealStackSize
        ld   r0, #hi(var_5)
        ld   r1, #lo(var_5)
        ; load t.40.1{r2}, [a.39.1{r0}]
        lde  r2, @rr0
        ; branch t.40.1{r2} equals 255: while_27_break, while_27
        cp   r2, #%ff
        jr   eq, while_27_break
while_27:
        ; addrof a.25.1{r0}, revealStackSize
        ld   r0, #hi(var_5)
        ld   r1, #lo(var_5)
        ; load t.26.1{r2}, [a.25.1{r0}]
        lde  r2, @rr0
        ; branch t.26.1{r2} gt 0: while_27_body, while_27_break
        cp   r2, #%00
        jr   ugt, while_27_body
while_27_break:
        ; 284:2 if revealStackSize != 255
        ; addrof a.41.1{r0}, revealStackSize
        ld   r0, #hi(var_5)
        ld   r1, #lo(var_5)
        ; load t.42.1{r2}, [a.41.1{r0}]
        lde  r2, @rr0
        ; branch t.42.1{r2} notequals 255: maybeRevealAround_Pu8_Pu8_ret
        cp   r2, #%ff
        jr   ne, maybeRevealAround_Pu8_Pu8_ret
        ; const changed.1{r0}, 1
        ld   r0, #%01
        ; 289:2 while changed
        ; move changed.2{r8}, changed.1{r0}
        ld   r8, r0
        jr   while_30

while_30_body:
        ; const changed.3{r0}, 0
        ld   r0, #%00
        ; const index.3{r1}, 0
        ld   r1, #%00
        ld   r2, #%00
        ; const r.1{r3}, 0
        ld   r3, #%00
        ; 293:3 for r < 20
        ; move index.4{r8}, index.3{r1}
        ld   r9, r2
        ld   r8, r1
        ; move changed.4{r10}, changed.3{r0}
        ld   r10, r0
        ; move r.2{r11}, r.1{r3}
        ld   r11, r3
        jr   for_31

for_31_body:
        ; const c.1{r0}, 0
        ld   r0, #%00
        ; 294:4 for c < 38
        ; move c.2{r12}, c.1{r0}
        ld   r12, r0
        jr   for_32

for_32_body:
        ; addrof t.43.1{r0}, field
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.43.2{r0}, index.5{r8}
        add  r1, r9
        adc  r0, r8
        ; load cell.1{r2}, [t.43.2{r0}]
        lde  r2, @rr0
        ; 296:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.44.1{r0}, cell.1{r2}
        ld   r0, r2
        ; and t.44.1{r0}, 32
        and  r0, #%20
        ; branch t.44.1{r0} equals 0: for_32_continue
        cp   r0, #%00
        jr   eq, for_32_continue
        ; move t.45.1{r0}, cell.1{r2}
        ld   r0, r2
        ; and t.45.1{r0}, 128
        and  r0, #%80
        ; branch t.45.1{r0} notequals 0: for_32_continue
        cp   r0, #%00
        jr   ne, for_32_continue
        ; 299:5 if [...] & 15 != 0
        ; addrof t.48.1{r0}, field
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.48.2{r0}, index.5{r8}
        add  r1, r9
        adc  r0, r8
        ; load t.47.1{r2}, [t.48.2{r0}]
        lde  r2, @rr0
        ; move t.46.1{r0}, t.47.1{r2}
        ld   r0, r2
        ; and t.46.1{r0}, 15
        and  r0, #%0f
        ; branch t.46.1{r0} notequals 0: for_32_continue
        cp   r0, #%00
        jr   ne, for_32_continue
        ; 303:5 if revealNeighbors_Pu8_Pu8_Pi16([ExprVarAccess[varName=r, index=6, scope=function, type=u8, varIsArray=false, location=303:24], ExprVarAccess[varName=c, index=7, scope=function, type=u8, varIsArray=false, location=303:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=303:30]])
        ; move r.2{r0}, r.2{r11}
        ld   r0, r11
        ; move c.2{r1}, c.2{r12}
        ld   r1, r12
        ; move index.5{r2}, index.5{r8}
        ld   r2, r8
        ld   r3, r9
        ; call t.49.1{r0} = revealNeighbors_Pu8_Pu8_Pi16[r.2{r0}, c.2{r1}, index.5{r2}] -> bool
        call revealNeighbors_Pu8_Pu8_Pi16
        ; branch t.49.1{r0} equals 0: for_32_continue
        cp   r0, #%00
        jr   eq, for_32_continue
        ; const changed.9{r0}, 1
        ld   r0, #%01
        ; move changed.8{r10}, changed.9{r0}
        ld   r10, r0
for_32_continue:
        ; move c.6{r0}, c.2{r12}
        ld   r0, r12
        ; add c.6{r0}, 1
        inc  r0
        ; move index.9{r1}, index.5{r8}
        ld   r1, r8
        ld   r2, r9
        ; add index.9{r1}, 1
        add  r2, #%01
        adc  r1, #%00
        ; move index.5{r8}, index.9{r1}
        ld   r9, r2
        ld   r8, r1
        ; move c.2{r12}, c.6{r0}
        ld   r12, r0
for_32:
        ; branch c.2{r12} lt 38: for_32_body
        cp   r12, #%26
        jr   ult, for_32_body
        ; move r.6{r0}, r.2{r11}
        ld   r0, r11
        ; add r.6{r0}, 1
        inc  r0
        ; move r.2{r11}, r.6{r0}
        ld   r11, r0
for_31:
        ; branch r.2{r11} lt 20: for_31_body
        cp   r11, #%14
        jr   ult, for_31_body
        ; branch changed.4{r10} equals 0: maybeRevealAround_Pu8_Pu8_ret
        cp   r10, #%00
        jr   eq, maybeRevealAround_Pu8_Pu8_ret
        ; const r.4{r0}, 20
        ld   r0, #%14
        ; 314:3 while true
        ; move r.5{r11}, r.4{r0}
        ld   r11, r0
        jr   while_38

if_39_end:
        ; sub r.7{r11}, 1
        dec  r11
        ; const c.3{r0}, 38
        ld   r0, #%26
        ; 321:4 while true
        ; move c.4{r12}, c.3{r0}
        ld   r12, r0
        jr   while_40

if_41_end:
        ; sub c.7{r12}, 1
        dec  r12
        ; sub index.10{r8}, 1
        decw r8
        ; addrof t.50.1{r0}, field
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.50.2{r0}, index.10{r8}
        add  r1, r9
        adc  r0, r8
        ; load cell.2{r2}, [t.50.2{r0}]
        lde  r2, @rr0
        ; 328:5 if cell & 32 == 0 || cell & 128 != 0
        ; move t.51.1{r0}, cell.2{r2}
        ld   r0, r2
        ; and t.51.1{r0}, 32
        and  r0, #%20
        ; branch t.51.1{r0} equals 0: while_40
        cp   r0, #%00
        jr   eq, while_40
        ; move t.52.1{r0}, cell.2{r2}
        ld   r0, r2
        ; and t.52.1{r0}, 128
        and  r0, #%80
        ; branch t.52.1{r0} notequals 0: while_40
        cp   r0, #%00
        jr   ne, while_40
        ; 331:5 if [...] & 15 != 0
        ; addrof t.55.1{r0}, field
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.55.2{r0}, index.10{r8}
        add  r1, r9
        adc  r0, r8
        ; load t.54.1{r2}, [t.55.2{r0}]
        lde  r2, @rr0
        ; move t.53.1{r0}, t.54.1{r2}
        ld   r0, r2
        ; and t.53.1{r0}, 15
        and  r0, #%0f
        ; branch t.53.1{r0} notequals 0: while_40
        cp   r0, #%00
        jr   ne, while_40
        ; 335:5 if revealNeighbors_Pu8_Pu8_Pi16([ExprVarAccess[varName=r, index=9, scope=function, type=u8, varIsArray=false, location=335:24], ExprVarAccess[varName=c, index=10, scope=function, type=u8, varIsArray=false, location=335:27], ExprVarAccess[varName=index, index=2, scope=function, type=i16, varIsArray=false, location=335:30]])
        ; move r.7{r0}, r.7{r11}
        ld   r0, r11
        ; move c.7{r1}, c.7{r12}
        ld   r1, r12
        ; move index.10{r2}, index.10{r8}
        ld   r2, r8
        ld   r3, r9
        ; call t.56.1{r0} = revealNeighbors_Pu8_Pu8_Pi16[r.7{r0}, c.7{r1}, index.10{r2}] -> bool
        call revealNeighbors_Pu8_Pu8_Pi16
        ; branch t.56.1{r0} equals 0: while_40
        cp   r0, #%00
        jr   eq, while_40
        ; const changed.10{r0}, 1
        ld   r0, #%01
        ; move changed.7{r10}, changed.10{r0}
        ld   r10, r0
while_40:
        ; branch c.4{r12} notequals 0: if_41_end, while_38
        cp   r12, #%00
        jr   ne, if_41_end
while_38:
        ; branch r.5{r11} notequals 0: if_39_end
        cp   r11, #%00
        jr   ne, if_39_end
        ; move changed.2{r8}, changed.6{r10}
        ld   r8, r10
while_30:
        ; branch changed.2{r8} notequals 0: while_30_body, maybeRevealAround_Pu8_Pu8_ret
        cp   r8, #%00
        jr   ne, while_30_body
maybeRevealAround_Pu8_Pu8_ret:
        ; restore clobbered non-volatile registers
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void pushReveal_Pu8_Pu8_Pi16
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
        jr   uge, if_46_then
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
        jr   pushReveal_Pu8_Pu8_Pi16_ret

if_46_then:
        ; const t.5.1{r0}, 255
        ld   r0, #%ff
        ; addrof a.6.1{r2}, revealStackSize
        ld   r2, #hi(var_5)
        ld   r3, #lo(var_5)
        ; store [a.6.1{r2}], t.5.1{r0}
        lde  @rr2, r0
        ; 347:3 return
pushReveal_Pu8_Pu8_Pi16_ret:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; bool revealNeighbors_Pu8_Pu8_Pi16
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; arg index (i16): r2
        ; var r.2 (u8): SP+8
        ; var c.2 (u8): SP+9
        ; var changed.5 (bool): SP+10
revealNeighbors_Pu8_Pu8_Pi16:
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
        ; move rowFrom.1{r4}, param.row{r0}
        ld   r4, r0
        ; 359:2 if rowFrom > 0
        ; branch rowFrom.1{r4} lteq 0: if_47_end
        cp   r4, #%00
        jr   ule, if_47_end
        ; sub rowFrom.3{r4}, 1
        dec  r4
        ; sub index.2{r2}, 38
        sub  r3, #%26
        sbc  r2, #%00
if_47_end:
        ; add rowTo.1{r0}, 1
        inc  r0
        ; 364:2 if rowTo >= 20
        ; branch rowTo.1{r0} gteq 20: if_48_then
        cp   r0, #%14
        jr   uge, if_48_then
        ; move rowTo.2{r8}, rowTo.1{r0}
        ld   r8, r0
        jr   if_48_end

if_48_then:
        ; sub rowTo.3{r0}, 1
        dec  r0
        ; move rowTo.2{r8}, rowTo.3{r0}
        ld   r8, r0
if_48_end:
        ; move colFrom.1{r0}, param.column{r1}
        ld   r0, r1
        ; 369:2 if colFrom > 0
        ; branch colFrom.1{r0} gt 0: if_49_then
        cp   r0, #%00
        jr   ugt, if_49_then
        ; move colFrom.2{r9}, colFrom.1{r0}
        ld   r9, r0
        jr   if_49_end

if_49_then:
        ; sub colFrom.3{r0}, 1
        dec  r0
        ; sub index.5{r2}, 1
        decw r2
        ; move colFrom.2{r9}, colFrom.3{r0}
        ld   r9, r0
if_49_end:
        ; move colTo.1{r0}, param.column{r1}
        ld   r0, r1
        ; add colTo.1{r0}, 1
        inc  r0
        ; 374:2 if colTo >= 38
        ; branch colTo.1{r0} gteq 38: if_50_then
        cp   r0, #%26
        jr   uge, if_50_then
        ; move colTo.2{r10}, colTo.1{r0}
        ld   r10, r0
        jr   if_50_end

if_50_then:
        ; sub colTo.3{r0}, 1
        dec  r0
        ; move colTo.2{r10}, colTo.3{r0}
        ld   r10, r0
if_50_end:
        ; const changed.1{r0}, 0
        ld   r0, #%00
        ; move r.1{r1}, rowFrom.2{r4}
        ld   r1, r4
        ; 378:2 for r <= rowTo
        ; move index.7{r11}, index.4{r2}
        ld   r12, r3
        ld   r11, r2
        ; move changed.2{r13}, changed.1{r0}
        ld   r13, r0
        ; move r.2{r2}, r.1{r1}
        ld   r2, r1
        jr   for_51

for_51_body:
        ; move c.1{r0}, colFrom.2{r9}
        ld   r0, r9
        ; 379:3 for c <= colTo
        ; move c.2{r3}, c.1{r0}
        ld   r3, r0
        ; addrof memVarAddr{r14}, r.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r.2{r2}
        lde  @rr14, r2
        ; move c.2{r2}, c.2{r3}
        ld   r2, r3
        jr   for_52

for_52_body:
        ; move c.2{r3}, c.2{r2}
        ld   r3, r2
        ; addrof memVarAddr{r14}, r.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; addrof t.11.1{r0}, field
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.11.2{r0}, index.8{r11}
        add  r1, r12
        adc  r0, r11
        ; load cell.1{r4}, [t.11.2{r0}]
        lde  r4, @rr0
        ; 381:4 if cell & 32 != 0
        ; move t.12.1{r0}, cell.1{r4}
        ld   r0, r4
        ; and t.12.1{r0}, 32
        and  r0, #%20
        ; branch t.12.1{r0} equals 0: if_53_end
        cp   r0, #%00
        jr   eq, if_53_end
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], c.2{r3}
        lde  @rr14, r3
        ; addrof memVarAddr{r14}, r.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        jr   for_52_continue

if_53_end:
        ; move cell.2{r13}, cell.1{r4}
        ld   r13, r4
        ; or cell.2{r13}, 32
        or  r13, #%20
        ; addrof t.13.1{r0}, field
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.13.2{r0}, index.8{r11}
        add  r1, r12
        adc  r0, r11
        ; store [t.13.2{r0}], cell.2{r13}
        lde  @rr0, r13
        ; move cell.2{r0}, cell.2{r13}
        ld   r0, r13
        ; move r.2{r1}, r.2{r2}
        ld   r1, r2
        ; addrof memVarAddr{r14}, r.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r.2{r2}
        lde  @rr14, r2
        ; move c.2{r2}, c.2{r3}
        ld   r2, r3
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], c.2{r3}
        lde  @rr14, r3
        ; call printCellAt_Pu8_Pu8_Pu8[cell.2{r0}, r.2{r1}, c.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
        ; const changed.5{r0}, 1
        ld   r0, #%01
        ; 389:4 if cell & 143 == 0 && revealStackSize != 255
        ; move t.14.1{r1}, cell.2{r13}
        ld   r1, r13
        ; and t.14.1{r1}, 143
        and  r1, #%8f
        ; branch t.14.1{r1} equals 0: and_55
        cp   r1, #%00
        jr   eq, and_55
        ; move changed.4{r13}, changed.5{r0}
        ld   r13, r0
        jr   for_52_continue

and_55:
        ; addrof a.15.1{r2}, revealStackSize
        ld   r2, #hi(var_5)
        ld   r3, #lo(var_5)
        ; load t.16.1{r1}, [a.15.1{r2}]
        lde  r1, @rr2
        ; branch t.16.1{r1} notequals 255: if_54_then
        cp   r1, #%ff
        jr   ne, if_54_then
        ; move changed.4{r13}, changed.5{r0}
        ld   r13, r0
        jr   for_52_continue

if_54_then:
        ; addrof memVarAddr{r14}, changed.5
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], changed.5{r0}
        lde  @rr14, r0
        ; addrof memVarAddr{r14}, r.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r.2{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; move r.2{r0}, r.2{r1}
        ld   r0, r1
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load c.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; move c.2{r1}, c.2{r2}
        ld   r1, r2
        ; move index.8{r2}, index.8{r11}
        ld   r2, r11
        ld   r3, r12
        ; call pushReveal_Pu8_Pu8_Pi16[r.2{r0}, c.2{r1}, index.8{r2}]
        call pushReveal_Pu8_Pu8_Pi16
        ; addrof memVarAddr{r14}, changed.5
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load changed.5{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; move changed.4{r13}, changed.5{r0}
        ld   r13, r0
for_52_continue:
        ; addrof memVarAddr{r14}, c.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load c.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; move c.4{r0}, c.2{r2}
        ld   r0, r2
        ; add c.4{r0}, 1
        inc  r0
        ; move index.11{r1}, index.8{r11}
        ld   r1, r11
        ld   r2, r12
        ; add index.11{r1}, 1
        add  r2, #%01
        adc  r1, #%00
        ; move index.8{r11}, index.11{r1}
        ld   r12, r2
        ld   r11, r1
        ; move c.2{r2}, c.4{r0}
        ld   r2, r0
for_52:
        ; branch c.2{r2} lteq colTo.2{r10}: for_52_body
        cp   r2, r10
        jr   ule, for_52_body
        ; cast t.20.1{r0}(i16), colTo.2{r10}(u8)
        ld   r1, r10
        ld   r0, #0
        ; move t.19.1{r2}, index.8{r11}
        ld   r2, r11
        ld   r3, r12
        ; sub t.19.1{r2}, t.20.1{r0}
        sub  r3, r1
        sbc  r2, r0
        ; cast t.21.1{r0}(i16), colFrom.2{r9}(u8)
        ld   r1, r9
        ld   r0, #0
        ; add t.18.1{r2}, t.21.1{r0}
        add  r3, r1
        adc  r2, r0
        ; move t.17.1{r0}, t.18.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; add t.17.1{r0}, 38
        add  r1, #%26
        adc  r0, #%00
        ; sub index.9{r0}, 1
        decw r0
        ; addrof memVarAddr{r14}, r.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; add r.4{r2}, 1
        inc  r2
        ; move index.7{r11}, index.9{r0}
        ld   r12, r1
        ld   r11, r0
for_51:
        ; branch r.2{r2} lteq rowTo.2{r8}: for_51_body
        cp   r2, r8
        jr   ule, for_51_body
        ; 395:9 return changed
        ; move changed.2{r0}, changed.2{r13}
        ld   r0, r13
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
        ; const t.8.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; addrof a.9.1{r2}, revealStackIndexTop
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.9.1{r2}], t.8.1{r0}
        lde  @rr2, r0
        incw r2
        lde  @rr2, r1
        decw r2
        ; const t.10.1{r0}, 0
        ld   r0, #%00
        ; addrof a.11.1{r2}, revealStackSize
        ld   r2, #hi(var_5)
        ld   r3, #lo(var_5)
        ; store [a.11.1{r2}], t.10.1{r0}
        lde  @rr2, r0
        ; end initialize global variables
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom_Pi32[arg.0.0{r0}]
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
        ; call setCursor_Pi16_Pi16[arg.3.0{r0}, arg.3.1{r2}]
        call setCursor_Pi16_Pi16
        ; const col.1{r0}, 19
        ld   r0, #%13
        ; const row.1{r1}, 10
        ld   r1, #%0a
        ; const bombsLeft.1{r2}, -1
        ld   r2, #%ff
        ld   r3, #%ff
        ; 407:2 while true
        ; move col.2{r8}, col.1{r0}
        ld   r8, r0
        ; move row.2{r9}, row.1{r1}
        ld   r9, r1
        ; move bombsLeft.2{r10}, bombsLeft.1{r2}
        ld   r11, r3
        ld   r10, r2
        jr   while_56

if_57_end:
        ; const t.13.1{r2}, 1
        ld   r2, #%01
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call showCursor_Pu8_Pu8_Pbool[row.2{r0}, col.2{r1}, t.13.1{r2}]
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
        ; call showCursor_Pu8_Pu8_Pbool[row.2{r0}, col.2{r1}, t.14.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; 416:3 if chr == 27
        ; branch chr.1{r12} equals 27: main_ret
        cp   r13, #%1b
        jr   ne, .notEquals6
        cp   r12, #%00
        jr   eq, main_ret
.notEquals6:
        ; branch chr.1{r12} equals 13: if_59_then
        cp   r13, #%0d
        jr   ne, .notEquals7
        cp   r12, #%00
        jr   eq, if_59_then
.notEquals7:
        ; branch chr.1{r12} notequals 3: if_63_else, if_63_then
        cp   r13, #%03
        jr   ne, if_63_else
        cp   r12, #%00
        jr   ne, if_63_else
        jr   if_63_then

if_59_then:
        ; branch bombsLeft.2{r10} gteq 0: if_60_end, if_60_then
        cp   r10, #%00
        jr   gt, if_60_end
        jr   ne, .gt8
        cp   r11, #%00
        jr   uge, if_60_end
.gt8:
        jr   if_60_then

if_63_else:
        ; branch chr.1{r12} notequals 4: if_65_else, if_65_then
        cp   r13, #%04
        jr   ne, if_65_else
        cp   r12, #%00
        jr   ne, if_65_else
        jr   if_65_then

if_63_then:
        ; branch row.2{r9} lteq 0: while_56, if_64_then
        cp   r9, #%00
        jr   ule, while_56
        jr   if_64_then

if_60_then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call bombsLeft.4{r0} = initField_Pu8_Pu8[row.2{r0}, col.2{r1}] -> i16
        call initField_Pu8_Pu8
        ; move bombsLeft.3{r10}, bombsLeft.4{r0}
        ld   r11, r1
        ld   r10, r0
        jr   if_60_end

if_65_else:
        ; branch chr.1{r12} notequals 1: if_67_else, if_67_then
        cp   r13, #%01
        jr   ne, if_67_else
        cp   r12, #%00
        jr   ne, if_67_else
        jr   if_67_then

if_65_then:
        ; branch row.2{r9} gteq 19: while_56, if_66_then
        cp   r9, #%13
        jr   uge, while_56
        jr   if_66_then

if_64_then:
        ; move row.4{r0}, row.2{r9}
        ld   r0, r9
        ; sub row.4{r0}, 1
        dec  r0
        ; move row.2{r9}, row.4{r0}
        ld   r9, r0
        jr   while_56

if_60_end:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call index.1{r0} = rowColumnToCell_Pu8_Pu8[row.2{r0}, col.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.15.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.15.2{r2}, index.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load cell.1{r4}, [t.15.2{r2}]
        lde  r4, @rr2
        ; 426:4 if cell & 32 == 0
        ; move t.16.1{r2}, cell.1{r4}
        ld   r2, r4
        ; and t.16.1{r2}, 32
        and  r2, #%20
        ; branch t.16.1{r2} notequals 0: if_61_end, if_61_then
        cp   r2, #%00
        jr   ne, if_61_end
        jr   if_61_then

if_67_else:
        ; branch chr.1{r12} notequals 2: if_69_else, if_69_then
        cp   r13, #%02
        jr   ne, if_69_else
        cp   r12, #%00
        jr   ne, if_69_else
        jr   if_69_then

if_67_then:
        ; branch col.2{r8} lteq 0: while_56, if_68_then
        cp   r8, #%00
        jr   ule, while_56
        jr   if_68_then

if_66_then:
        ; move row.5{r0}, row.2{r9}
        ld   r0, r9
        ; add row.5{r0}, 1
        inc  r0
        ; move row.2{r9}, row.5{r0}
        ld   r9, r0
        jr   while_56

if_61_then:
        ; move t.17.1{r2}, cell.1{r4}
        ld   r2, r4
        ; or t.17.1{r2}, 32
        or  r2, #%20
        ; addrof t.18.1{r6}, field
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.18.2{r6}, index.1{r0}
        add  r7, r1
        adc  r6, r0
        ; store [t.18.2{r6}], t.17.1{r2}
        lde  @rr6, r2
        jr   if_61_end

if_69_else:
        ; branch chr.1{r12} notequals 32: while_56, if_71_then
        cp   r13, #%20
        jr   ne, while_56
        cp   r12, #%00
        jr   ne, while_56
        jr   if_71_then

if_69_then:
        ; branch col.2{r8} gteq 37: while_56, if_70_then
        cp   r8, #%25
        jr   uge, while_56
        jr   if_70_then

if_68_then:
        ; move col.5{r0}, col.2{r8}
        ld   r0, r8
        ; sub col.5{r0}, 1
        dec  r0
        ; move col.2{r8}, col.5{r0}
        ld   r8, r0
        jr   while_56

if_61_end:
        ; 429:4 if cell & 128 != 0
        ; move t.19.1{r0}, cell.1{r4}
        ld   r0, r4
        ; and t.19.1{r0}, 128
        and  r0, #%80
        ; branch t.19.1{r0} equals 0: if_62_end, if_62_then
        cp   r0, #%00
        jr   eq, if_62_end
        jr   if_62_then

if_71_then:
        ; branch bombsLeft.2{r10} lt 0: while_56, if_72_then
        cp   r10, #%00
        jr   lt, while_56
        jr   ne, .lt9
        cp   r11, #%00
        jr   ult, while_56
.lt9:
        jr   if_72_then

if_70_then:
        ; move col.6{r0}, col.2{r8}
        ld   r0, r8
        ; add col.6{r0}, 1
        inc  r0
        ; move col.2{r8}, col.6{r0}
        ld   r8, r0
        jr   while_56

if_62_end:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call maybeRevealAround_Pu8_Pu8[row.2{r0}, col.2{r1}]
        call maybeRevealAround_Pu8_Pu8
        jr   while_56

if_72_then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call index.2{r0} = rowColumnToCell_Pu8_Pu8[row.2{r0}, col.2{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.21.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.21.2{r2}, index.2{r0}
        add  r3, r1
        adc  r2, r0
        ; load cell.3{r4}, [t.21.2{r2}]
        lde  r4, @rr2
        ; 465:5 if cell & 32 == 0
        ; move t.22.1{r2}, cell.3{r4}
        ld   r2, r4
        ; and t.22.1{r2}, 32
        and  r2, #%20
        ; branch t.22.1{r2} notequals 0: while_56
        cp   r2, #%00
        jr   ne, while_56
        ; move cell.4{r2}, cell.3{r4}
        ld   r2, r4
        ; xor cell.4{r2}, 64
        xor r2, #%40
        ; 467:6 if cell & 128 != 0
        ; move t.23.1{r3}, cell.4{r2}
        ld   r3, r2
        ; and t.23.1{r3}, 128
        and  r3, #%80
        ; branch t.23.1{r3} equals 0: if_74_end
        cp   r3, #%00
        jr   eq, if_74_end
        ; 468:7 if cell & 64 != 0
        ; move t.24.1{r3}, cell.4{r2}
        ld   r3, r2
        ; and t.24.1{r3}, 64
        and  r3, #%40
        ; branch t.24.1{r3} notequals 0: if_75_then
        cp   r3, #%00
        jr   ne, if_75_then
        ; move bombsLeft.7{r3}, bombsLeft.2{r10}
        ld   r3, r10
        ld   r4, r11
        ; add bombsLeft.7{r3}, 1
        add  r4, #%01
        adc  r3, #%00
        ; move bombsLeft.6{r10}, bombsLeft.7{r3}
        ld   r11, r4
        ld   r10, r3
        jr   if_74_end

if_75_then:
        ; move bombsLeft.8{r3}, bombsLeft.2{r10}
        ld   r3, r10
        ld   r4, r11
        ; sub bombsLeft.8{r3}, 1
        sub  r4, #%01
        sbc  r3, #%00
        ; move bombsLeft.6{r10}, bombsLeft.8{r3}
        ld   r11, r4
        ld   r10, r3
if_74_end:
        ; addrof t.25.1{r4}, field
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.25.2{r4}, index.2{r0}
        add  r5, r1
        adc  r4, r0
        ; store [t.25.2{r4}], cell.4{r2}
        lde  @rr4, r2
        ; move cell.4{r0}, cell.4{r2}
        ld   r0, r2
        ; move row.2{r1}, row.2{r9}
        ld   r1, r9
        ; move col.2{r2}, col.2{r8}
        ld   r2, r8
        ; call printCellAt_Pu8_Pu8_Pu8[cell.4{r0}, row.2{r1}, col.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
while_56:
        ; branch bombsLeft.2{r10} notequals 0: if_57_end
        cp   r11, #%00
        jr   ne, if_57_end
        cp   r10, #%00
        jr   ne, if_57_end
        ; const t.12.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString_P_pu8[t.12.1{r0}]
        call printString_P_pu8
        jr   main_ret

if_62_then:
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ; move col.2{r1}, col.2{r8}
        ld   r1, r8
        ; call printCellAt_Pu8_Pu8[row.2{r0}, col.2{r1}]
        call printCellAt_Pu8_Pu8
        ; const t.20.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString_P_pu8[t.20.1{r0}]
        call printString_P_pu8
main_ret:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
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

        ; void setCursor_Pi16_Pi16
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

        ; void initRandom_Pi32
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

string_1:
        .data " You've cleaned the field!" %00
string_2:
        .data "boom! you've lost" %00

