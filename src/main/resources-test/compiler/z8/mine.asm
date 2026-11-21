        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; void printUint_Pi16
        ; arg number (i16): r0
printUint_Pi16:
        ; cast t.1.1{r0}(i32), param.number{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; call printUint_Pi32[t.1.1{r0}]
        call printUint_Pi32
        ret

        ; i16 rowColumnToCell_Pi16_Pi16
        ; arg row (i16): r0
        ; arg column (i16): r2
rowColumnToCell_Pi16_Pi16:
        ; 16:21 return row * 40 + column
        ; mul t.3.1{r0}, 40
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%28
        srp  #%10
        call %00BA ; mul
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; add t.2.1{r0}, param.column{r2}
        add  r1, r3
        adc  r0, r2
        ret

        ; u8 getCell_Pi16_Pi16
        ; arg row (i16): r0
        ; arg column (i16): r2
getCell_Pi16_Pi16:
        ; 20:15 return [...]
        ; call t.4.1{r0} = rowColumnToCell_Pi16_Pi16[param.row{r0}, param.column{r2}] -> i16
        call rowColumnToCell_Pi16_Pi16
        ; addrof t.3.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.3.2{r2}, t.4.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.2.1{r0}, [t.3.2{r2}]
        lde  r0, @rr2
        ret

        ; bool isBomb_Pu8
        ; arg cell (u8): r0
isBomb_Pu8:
        ; 24:27 return cell & 1 != 0
        ; and t.2.1{r0}, 1
        and  r0, #%01
        ; notequals t.1.1{r0}, t.2.1{r0}, 0
        cp   r0, #%00
        jr   ne, .ne1
        ld   r0, #0  ; false
        jr   .1
.ne1:
        ld   r0, #1
.1:
        ret

        ; bool isOpen_Pu8
        ; arg cell (u8): r0
isOpen_Pu8:
        ; 28:27 return cell & 2 != 0
        ; and t.2.1{r0}, 2
        and  r0, #%02
        ; notequals t.1.1{r0}, t.2.1{r0}, 0
        cp   r0, #%00
        jr   ne, .ne2
        ld   r0, #0  ; false
        jr   .2
.ne2:
        ld   r0, #1
.2:
        ret

        ; bool isFlag_Pu8
        ; arg cell (u8): r0
isFlag_Pu8:
        ; 32:27 return cell & 4 != 0
        ; and t.2.1{r0}, 4
        and  r0, #%04
        ; notequals t.1.1{r0}, t.2.1{r0}, 0
        cp   r0, #%00
        jr   ne, .ne3
        ld   r0, #0  ; false
        jr   .3
.ne3:
        ld   r0, #1
.3:
        ret

        ; bool checkCellBounds_Pi16_Pi16
        ; arg row (i16): r0
        ; arg column (i16): r2
checkCellBounds_Pi16_Pi16:
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 36:40 logic and
        ; 36:21 logic and
        ; gteq t.2.1{r4}, param.row{r0}, 0
        cp   r0, #%00
        jr   gt, .true4
        jr   ne, .false4
        cp   r1, #%00
        jr   uge, .true4
.false4:
        ld   r4, #0
        jr   .4
.true4:
        ld   r4, #1
.4:
        ; branch t.2.1{r4} notequals 0: and_2nd_3
        cp   r4, #%00
        jr   ne, and_2nd_3
        ; move t.2.2{r0}, t.2.1{r4}
        ld   r0, r4
        jr   and_next_3

and_2nd_3:
        ; lt t.2.3{r0}, param.row{r0}, 20
        cp   r0, #%00
        jr   lt, .true5
        jr   ne, .false5
        cp   r1, #%14
        jr   ult, .true5
.false5:
        ld   r0, #0
        jr   .5
.true5:
        ld   r0, #1
.5:
and_next_3:
        ; branch t.2.2{r0} equals 0: and_next_2
        cp   r0, #%00
        jr   eq, and_next_2
        ; gteq t.2.5{r0}, param.column{r2}, 0
        cp   r2, #%00
        jr   gt, .true6
        jr   ne, .false6
        cp   r3, #%00
        jr   uge, .true6
.false6:
        ld   r0, #0
        jr   .6
.true6:
        ld   r0, #1
.6:
and_next_2:
        ; branch t.2.4{r0} equals 0: checkCellBounds_Pi16_Pi16_ret
        cp   r0, #%00
        jr   eq, checkCellBounds_Pi16_Pi16_ret
        ; lt t.2.7{r0}, param.column{r2}, 40
        cp   r2, #%00
        jr   lt, .true7
        jr   ne, .false7
        cp   r3, #%28
        jr   ult, .true7
.false7:
        ld   r0, #0
        jr   .7
.true7:
        ld   r0, #1
.7:
checkCellBounds_Pi16_Pi16_ret:
        ret

        ; void setCell_Pi16_Pi16_Pu8
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; arg cell (u8): r4
setCell_Pi16_Pi16_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; move param.cell{r8}, cell{r4}
        ld   r8, r4
        ; call t.4.1{r0} = rowColumnToCell_Pi16_Pi16[param.row{r0}, param.column{r2}] -> i16
        call rowColumnToCell_Pi16_Pi16
        ; addrof t.3.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.3.2{r2}, t.4.1{r0}
        add  r3, r1
        adc  r2, r0
        ; store [t.3.2{r2}], param.cell{r8}
        lde  @rr2, r8
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; u8 getBombCountAround_Pi16_Pi16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; var dr.2 (i16): SP+8
        ; var r.1 (i16): SP+10
        ; var dc.2 (i16): SP+12
        ; var c.1 (i16): SP+14
getBombCountAround_Pi16_Pi16:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%08
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
        ld   r9, r1
        ld   r8, r0
        ; move param.column{r10}, column{r2}
        ld   r11, r3
        ld   r10, r2
        ; const count.1{r0}, 0
        ld   r0, #%00
        ; const dr.1{r1}, -1
        ld   r1, #%ff
        ld   r2, #%ff
        ; 46:2 for dr <= 1
        ; move count.2{r12}, count.1{r0}
        ld   r12, r0
        ; move dr.2{r0}, dr.1{r1}
        ld   r0, r1
        ld   r1, r2
        jr   for_4

for_4_body:
        ; move r.1{r2}, param.row{r8}
        ld   r2, r8
        ld   r3, r9
        ; add r.1{r2}, dr.2{r0}
        add  r3, r1
        adc  r2, r0
        ; addrof memVarAddr{r14}, dr.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], dr.2{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; const dc.1{r0}, -1
        ld   r0, #%ff
        ld   r1, #%ff
        ; 48:3 for dc <= 1
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], r.1{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        jr   for_5

for_5_body:
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load r.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move c.1{r4}, param.column{r10}
        ld   r4, r10
        ld   r5, r11
        ; add c.1{r4}, dc.2{r0}
        add  r5, r1
        adc  r4, r0
        ; addrof memVarAddr{r14}, dc.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], dc.2{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; 50:4 if checkCellBounds_Pi16_Pi16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; move r.1{r0}, r.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; move c.1{r2}, c.1{r4}
        ld   r2, r4
        ld   r3, r5
        ; addrof memVarAddr{r14}, c.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], c.1{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        decw r14
        ; call t.8.1{r0} = checkCellBounds_Pi16_Pi16[r.1{r0}, c.1{r2}] -> bool
        call checkCellBounds_Pi16_Pi16
        ; branch t.8.1{r0} equals 0: for_5_continue
        cp   r0, #%00
        jr   eq, for_5_continue
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load r.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move r.1{r0}, r.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, c.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load c.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; call cell.1{r0} = getCell_Pi16_Pi16[r.1{r0}, c.1{r2}] -> u8
        call getCell_Pi16_Pi16
        ; 52:5 if isBomb_Pu8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; call t.9.1{r0} = isBomb_Pu8[cell.1{r0}] -> bool
        call isBomb_Pu8
        ; branch t.9.1{r0} equals 0: for_5_continue
        cp   r0, #%00
        jr   eq, for_5_continue
        ; move count.5{r0}, count.3{r12}
        ld   r0, r12
        ; add count.5{r0}, 1
        inc  r0
        ; move count.4{r12}, count.5{r0}
        ld   r12, r0
for_5_continue:
        ; addrof memVarAddr{r14}, dc.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load dc.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; add dc.4{r0}, 1
        incw r0
for_5:
        ; branch dc.2{r0} lteq 1: for_5_body
        cp   r0, #%00
        jr   lt, for_5_body
        jr   ne, .lt8
        cp   r1, #%01
        jr   ule, for_5_body
.lt8:
        ; addrof memVarAddr{r14}, dr.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load dr.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; add dr.4{r0}, 1
        incw r0
for_4:
        ; branch dr.2{r0} lteq 1: for_4_body
        cp   r0, #%00
        jr   lt, for_4_body
        jr   ne, .lt9
        cp   r1, #%01
        jr   ule, for_4_body
.lt9:
        ; 58:9 return count
        ; move count.2{r0}, count.2{r12}
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
        add  %31, #%08
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; u8 getSpacer_Pi16_Pi16_Pi16_Pi16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; arg rowCursor (i16): r4
        ; arg columnCursor (i16): r6
getSpacer_Pi16_Pi16_Pi16_Pi16:
        ; branch param.rowCursor{r4} notequals param.row{r0}: if_8_end
        cp   r5, r1
        jr   ne, if_8_end
        cp   r4, r0
        jr   ne, if_8_end
        ; branch param.columnCursor{r6} equals param.column{r2}: if_9_then
        cp   r7, r3
        jr   ne, .notEquals10
        cp   r6, r2
        jr   eq, if_9_then
.notEquals10:
        ; 66:3 if columnCursor == column - 1
        ; move t.4.1{r0}, param.column{r2}
        ld   r0, r2
        ld   r1, r3
        ; sub t.4.1{r0}, 1
        decw r0
        ; branch param.columnCursor{r6} notequals t.4.1{r0}: if_8_end, if_10_then
        cp   r7, r1
        jr   ne, if_8_end
        cp   r6, r0
        jr   ne, if_8_end
        jr   if_10_then

if_9_then:
        ; const {r0}, 91
        ld   r0, #%5b
        jr   getSpacer_Pi16_Pi16_Pi16_Pi16_ret

if_10_then:
        ; const {r0}, 93
        ld   r0, #%5d
        jr   getSpacer_Pi16_Pi16_Pi16_Pi16_ret

if_8_end:
        ; const {r0}, 32
        ld   r0, #%20
getSpacer_Pi16_Pi16_Pi16_Pi16_ret:
        ret

        ; void printCell_Pu8_Pi16_Pi16
        ; arg cell (u8): r0
        ; arg row (i16): r1
        ; arg column (i16): r3
printCell_Pu8_Pi16_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; move param.cell{r8}, cell{r0}
        ld   r8, r0
        ; move param.row{r9}, row{r1}
        ld   r10, r2
        ld   r9, r1
        ; move param.column{r11}, column{r3}
        ld   r12, r4
        ld   r11, r3
        ; const chr.1{r13}, 46
        ld   r13, #%2e
        ; 75:2 if isOpen_Pu8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; call t.5.1{r0} = isOpen_Pu8[param.cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.5.1{r0} notequals 0: if_11_then
        cp   r0, #%00
        jr   ne, if_11_then
        ; 89:7 if isFlag_Pu8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.7.1{r0} = isFlag_Pu8[param.cell{r0}] -> bool
        call isFlag_Pu8
        ; branch t.7.1{r0} equals 0: printCell_Pu8_Pi16_Pi16.no_critical_edge_10, if_14_then
        cp   r0, #%00
        jr   eq, printCell_Pu8_Pi16_Pi16.no_critical_edge_10
        jr   if_14_then

if_11_then:
        ; 76:3 if isBomb_Pu8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.6.1{r0} = isBomb_Pu8[param.cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.6.1{r0} equals 0: if_12_else, if_12_then
        cp   r0, #%00
        jr   eq, if_12_else
        jr   if_12_then

printCell_Pu8_Pi16_Pi16.no_critical_edge_10:
        ; move chr.2{r8}, chr.1{r13}
        ld   r8, r13
        jr   if_11_end

if_14_then:
        ; const chr.3{r0}, 35
        ld   r0, #%23
        ; move chr.2{r8}, chr.3{r0}
        ld   r8, r0
        jr   if_11_end

if_12_else:
        ; move param.row{r0}, param.row{r9}
        ld   r0, r9
        ld   r1, r10
        ; move param.column{r2}, param.column{r11}
        ld   r2, r11
        ld   r3, r12
        ; call count.1{r0} = getBombCountAround_Pi16_Pi16[param.row{r0}, param.column{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; 81:4 if count > 0
        ; branch count.1{r0} lteq 0: if_13_else, if_13_then
        cp   r0, #%00
        jr   ule, if_13_else
        jr   if_13_then

if_12_then:
        ; const chr.4{r0}, 42
        ld   r0, #%2a
        ; move chr.2{r8}, chr.4{r0}
        ld   r8, r0
        jr   if_11_end

if_13_else:
        ; const chr.5{r0}, 32
        ld   r0, #%20
        ; move chr.2{r8}, chr.5{r0}
        ld   r8, r0
        jr   if_11_end

if_13_then:
        ; add chr.6{r0}, 48
        add  r0, #%30
        ; move chr.2{r8}, chr.6{r0}
        ld   r8, r0
if_11_end:
        ; move chr.2{r0}, chr.2{r8}
        ld   r0, r8
        ; call printChar_Pu8[chr.2{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printField_Pi16_Pi16
        ; arg rowCursor (i16): r0
        ; arg columnCursor (i16): r2
printField_Pi16_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; move param.rowCursor{r8}, rowCursor{r0}
        ld   r9, r1
        ld   r8, r0
        ; move param.columnCursor{r10}, columnCursor{r2}
        ld   r11, r3
        ld   r10, r2
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
        ld   r1, #%00
        ; 97:2 for row < 20
        ; move row.2{r12}, row.1{r0}
        ld   r13, r1
        ld   r12, r0
        jr   for_15

for_15_body:
        ; const arg.1.0{r0}, 124
        ld   r0, #%7c
        ; call printChar_Pu8[arg.1.0{r0}]
        call printChar_Pu8
        ; const column.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; 99:3 for column < 40
        ; move column.2{r14}, column.1{r0}
        ld   r15, r1
        ld   r14, r0
        jr   for_16

for_16_body:
        ; move row.2{r0}, row.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; move column.2{r2}, column.2{r14}
        ld   r2, r14
        ld   r3, r15
        ; move param.rowCursor{r4}, param.rowCursor{r8}
        ld   r4, r8
        ld   r5, r9
        ; move param.columnCursor{r6}, param.columnCursor{r10}
        ld   r6, r10
        ld   r7, r11
        ; call spacer.2{r0} = getSpacer_Pi16_Pi16_Pi16_Pi16[row.2{r0}, column.2{r2}, param.rowCursor{r4}, param.columnCursor{r6}] -> u8
        call getSpacer_Pi16_Pi16_Pi16_Pi16
        ; call printChar_Pu8[spacer.2{r0}]
        call printChar_Pu8
        ; move row.2{r0}, row.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; move column.2{r2}, column.2{r14}
        ld   r2, r14
        ld   r3, r15
        ; call cell.1{r0} = getCell_Pi16_Pi16[row.2{r0}, column.2{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move row.2{r1}, row.2{r12}
        ld   r1, r12
        ld   r2, r13
        ; move column.2{r3}, column.2{r14}
        ld   r3, r14
        ld   r4, r15
        ; call printCell_Pu8_Pi16_Pi16[cell.1{r0}, row.2{r1}, column.2{r3}]
        call printCell_Pu8_Pi16_Pi16
        ; move column.3{r0}, column.2{r14}
        ld   r0, r14
        ld   r1, r15
        ; add column.3{r0}, 1
        incw r0
        ; move column.2{r14}, column.3{r0}
        ld   r15, r1
        ld   r14, r0
for_16:
        ; branch column.2{r14} lt 40: for_16_body
        cp   r14, #%00
        jr   lt, for_16_body
        jr   ne, .lt11
        cp   r15, #%28
        jr   ult, for_16_body
.lt11:
        ; move row.2{r0}, row.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; move param.rowCursor{r4}, param.rowCursor{r8}
        ld   r4, r8
        ld   r5, r9
        ; move param.columnCursor{r6}, param.columnCursor{r10}
        ld   r6, r10
        ld   r7, r11
        ; const arg.6.1{r2}, 40
        ld   r2, #%00
        ld   r3, #%28
        ; call spacer.1{r0} = getSpacer_Pi16_Pi16_Pi16_Pi16[row.2{r0}, arg.6.1{r2}, param.rowCursor{r4}, param.columnCursor{r6}] -> u8
        call getSpacer_Pi16_Pi16_Pi16_Pi16
        ; call printChar_Pu8[spacer.1{r0}]
        call printChar_Pu8
        ; const t.7.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString_P_pu8[t.7.1{r0}]
        call printString_P_pu8
        ; move row.4{r0}, row.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; add row.4{r0}, 1
        incw r0
        ; move row.2{r12}, row.4{r0}
        ld   r13, r1
        ld   r12, r0
for_15:
        ; branch row.2{r12} lt 20: for_15_body
        cp   r12, #%00
        jr   lt, for_15_body
        jr   ne, .lt12
        cp   r13, #%14
        jr   ult, for_15_body
.lt12:
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

        ; void printSpaces_Pi16
        ; arg i (i16): r0
printSpaces_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move i.1{r8}, param.i{r0}
        ld   r9, r1
        ld   r8, r0
        jr   for_17

for_17_body:
        ; const arg.0.0{r0}, 48
        ld   r0, #%30
        ; call printChar_Pu8[arg.0.0{r0}]
        call printChar_Pu8
        ; move i.2{r0}, i.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; sub i.2{r0}, 1
        decw r0
        ; move i.1{r8}, i.2{r0}
        ld   r9, r1
        ld   r8, r0
for_17:
        ; branch i.1{r8} gt 0: for_17_body
        cp   r8, #%00
        jr   gt, for_17_body
        jr   ne, .gt13
        cp   r9, #%00
        jr   ugt, for_17_body
.gt13:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; u8 getDigitCount_Pi16
        ; arg value (i16): r0
getDigitCount_Pi16:
        ; const count.1{r2}, 0
        ld   r2, #%00
        ; 119:2 if value < 0
        ; branch param.value{r0} gteq 0: while_19
        cp   r0, #%00
        jr   gt, while_19
        jr   ne, .gt14
        cp   r1, #%00
        jr   uge, while_19
.gt14:
        ; const count.3{r2}, 1
        ld   r2, #%01
        ; neg value.2{r0}, param.value{r0}
        com  r0
        com  r1
        incw r0
while_19:
        ; add count.5{r2}, 1
        inc  r2
        ; div value.4{r0}, 10
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%0a
        srp  #%10
        call %00E0 ; div
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; 127:3 if value == 0
        ; branch value.4{r0} notequals 0: while_19
        cp   r1, #%00
        jr   ne, while_19
        cp   r0, #%00
        jr   ne, while_19
        ; 132:9 return count
        ; move count.5{r0}, count.5{r2}
        ld   r0, r2
        ret

        ; i16 getHiddenCount
getHiddenCount:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const count.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const r.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; 137:2 for r < 20
        ; move count.2{r8}, count.1{r0}
        ld   r9, r1
        ld   r8, r0
        ; move r.2{r10}, r.1{r2}
        ld   r11, r3
        ld   r10, r2
        jr   for_21

for_21_body:
        ; const c.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; 138:3 for c < 40
        ; move c.2{r12}, c.1{r0}
        ld   r13, r1
        ld   r12, r0
        jr   for_22

for_22_body:
        ; move r.2{r0}, r.2{r10}
        ld   r0, r10
        ld   r1, r11
        ; move c.2{r2}, c.2{r12}
        ld   r2, r12
        ld   r3, r13
        ; call cell.1{r0} = getCell_Pi16_Pi16[r.2{r0}, c.2{r2}] -> u8
        call getCell_Pi16_Pi16
        ; 140:4 if cell & 6 == 0
        ; and t.4.1{r0}, 6
        and  r0, #%06
        ; branch t.4.1{r0} equals 0: if_23_then
        cp   r0, #%00
        jr   eq, if_23_then
        ; move count.4{r0}, count.3{r8}
        ld   r0, r8
        ld   r1, r9
        jr   for_22_continue

if_23_then:
        ; move count.5{r0}, count.3{r8}
        ld   r0, r8
        ld   r1, r9
        ; add count.5{r0}, 1
        incw r0
for_22_continue:
        ; move c.4{r2}, c.2{r12}
        ld   r2, r12
        ld   r3, r13
        ; add c.4{r2}, 1
        incw r2
        ; move count.3{r8}, count.4{r0}
        ld   r9, r1
        ld   r8, r0
        ; move c.2{r12}, c.4{r2}
        ld   r13, r3
        ld   r12, r2
for_22:
        ; branch c.2{r12} lt 40: for_22_body
        cp   r12, #%00
        jr   lt, for_22_body
        jr   ne, .lt15
        cp   r13, #%28
        jr   ult, for_22_body
.lt15:
        ; move r.4{r0}, r.2{r10}
        ld   r0, r10
        ld   r1, r11
        ; add r.4{r0}, 1
        incw r0
        ; move r.2{r10}, r.4{r0}
        ld   r11, r1
        ld   r10, r0
for_21:
        ; branch r.2{r10} lt 20: for_21_body
        cp   r10, #%00
        jr   lt, for_21_body
        jr   ne, .lt16
        cp   r11, #%14
        jr   ult, for_21_body
.lt16:
        ; 145:9 return count
        ; move count.2{r0}, count.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
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
        ; call t.3.1{r0} = getDigitCount_Pi16[count.1{r0}] -> u8
        call getDigitCount_Pi16
        ; cast leftDigits.1{r10}(i16), t.3.1{r0}(u8)
        ld   r11, r0
        ld   r10, #0
        ; const arg.2.0{r0}, 40
        ld   r0, #%00
        ld   r1, #%28
        ; call t.4.1{r0} = getDigitCount_Pi16[arg.2.0{r0}] -> u8
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
        ; call setCursor_Pi16_Pi16[arg.3.0{r0}, arg.3.1{r2}]
        call setCursor_Pi16_Pi16
        ; move t.5.1{r0}, bombDigits.1{r12}
        ld   r0, r12
        ld   r1, r13
        ; sub t.5.1{r0}, leftDigits.1{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call printSpaces_Pi16[t.5.1{r0}]
        call printSpaces_Pi16
        ; move count.1{r0}, count.1{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint_Pi16[count.1{r0}]
        call printUint_Pi16
        ; 156:15 return count == 0
        ; equals t.6.1{r0}, count.1{r8}, 0
        cp   r8, #%00
        jr   ne, .ne17
        cp   r9, #%00
        jr   ne, .ne17
        ld   r0, #1  ; true
        jr   .17
.ne17:
        ld   r0, #0
.17:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; i16 abs_Pi16
        ; arg a (i16): r0
abs_Pi16:
        ; move param.a{r2}, a{r0}
        ld   r3, r1
        ld   r2, r0
        ; branch param.a{r2} lt 0: if_24_then
        cp   r2, #%00
        jr   lt, if_24_then
        jr   ne, .lt18
        cp   r3, #%00
        jr   ult, if_24_then
.lt18:
        ; 163:9 return a
        jr   abs_Pi16_ret

if_24_then:
        ; 161:10 return -a
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
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const r.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; 167:2 for r < 20
        ; move r.2{r8}, r.1{r0}
        ld   r9, r1
        ld   r8, r0
        jr   for_25

for_25_body:
        ; const c.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; 168:3 for c < 40
        ; move c.2{r10}, c.1{r0}
        ld   r11, r1
        ld   r10, r0
        jr   for_26

for_26_body:
        ; move r.2{r0}, r.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; move c.2{r2}, c.2{r10}
        ld   r2, r10
        ld   r3, r11
        ; const arg.0.2{r4}, 0
        ld   r4, #%00
        ; call setCell_Pi16_Pi16_Pu8[r.2{r0}, c.2{r2}, arg.0.2{r4}]
        call setCell_Pi16_Pi16_Pu8
        ; move c.3{r0}, c.2{r10}
        ld   r0, r10
        ld   r1, r11
        ; add c.3{r0}, 1
        incw r0
        ; move c.2{r10}, c.3{r0}
        ld   r11, r1
        ld   r10, r0
for_26:
        ; branch c.2{r10} lt 40: for_26_body
        cp   r10, #%00
        jr   lt, for_26_body
        jr   ne, .lt19
        cp   r11, #%28
        jr   ult, for_26_body
.lt19:
        ; move r.4{r0}, r.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add r.4{r0}, 1
        incw r0
        ; move r.2{r8}, r.4{r0}
        ld   r9, r1
        ld   r8, r0
for_25:
        ; branch r.2{r8} lt 20: for_25_body
        cp   r8, #%00
        jr   lt, for_25_body
        jr   ne, .lt20
        cp   r9, #%14
        jr   ult, for_25_body
.lt20:
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void initField_Pi16_Pi16
        ; arg curr_r (i16): r0
        ; arg curr_c (i16): r2
        ; var row.1 (i16): SP+8
        ; var column.1 (i16): SP+10
initField_Pi16_Pi16:
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
        ; move param.curr_r{r8}, curr_r{r0}
        ld   r9, r1
        ld   r8, r0
        ; move param.curr_c{r10}, curr_c{r2}
        ld   r11, r3
        ld   r10, r2
        ; const bombs.1{r0}, 40
        ld   r0, #%00
        ld   r1, #%28
        ; 175:2 for bombs > 0
        ; move bombs.2{r12}, bombs.1{r0}
        ld   r13, r1
        ld   r12, r0
        jr   for_27

for_27_body:
        ; call t.5.1{r0} = random16[] -> i16
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
        ; call t.6.1{r0} = random16[] -> i16
        call random16
        ; move column.1{r2}, t.6.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; mod column.1{r2}, 40
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%28
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
        ; 178:3 if abs_Pi16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs_Pi16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; move t.8.1{r2}, row.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; sub t.8.1{r2}, param.curr_r{r8}
        sub  r3, r9
        sbc  r2, r8
        ; move t.8.1{r0}, t.8.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; call t.7.1{r0} = abs_Pi16[t.8.1{r0}] -> i16
        call abs_Pi16
        ; branch t.7.1{r0} gt 1: if_28_then
        cp   r0, #%00
        jr   gt, if_28_then
        jr   ne, .gt21
        cp   r1, #%01
        jr   ugt, if_28_then
.gt21:
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
        ; move t.10.1{r0}, column.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; sub t.10.1{r0}, param.curr_c{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call t.9.1{r0} = abs_Pi16[t.10.1{r0}] -> i16
        call abs_Pi16
        ; branch t.9.1{r0} lteq 1: for_27_continue, if_28_then
        cp   r0, #%00
        jr   lt, for_27_continue
        jr   ne, .lt22
        cp   r1, #%01
        jr   ule, for_27_continue
.lt22:
if_28_then:
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
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
        ; const arg.4.2{r4}, 1
        ld   r4, #%01
        ; call setCell_Pi16_Pi16_Pu8[row.1{r0}, column.1{r2}, arg.4.2{r4}]
        call setCell_Pi16_Pi16_Pu8
for_27_continue:
        ; move bombs.5{r0}, bombs.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; sub bombs.5{r0}, 1
        decw r0
        ; move bombs.2{r12}, bombs.5{r0}
        ld   r13, r1
        ld   r12, r0
for_27:
        ; branch bombs.2{r12} gt 0: for_27_body
        cp   r12, #%00
        jr   gt, for_27_body
        jr   ne, .gt23
        cp   r13, #%00
        jr   ugt, for_27_body
.gt23:
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

        ; void maybeRevealAround_Pi16_Pi16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; var r.1 (i16): SP+8
        ; var dc.2 (i16): SP+10
        ; var c.1 (i16): SP+12
        ; var cell.1 (u8): SP+14
maybeRevealAround_Pi16_Pi16:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%07
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
        ld   r9, r1
        ld   r8, r0
        ; move param.column{r10}, column{r2}
        ld   r11, r3
        ld   r10, r2
        ; 186:2 if getBombCountAround_Pi16_Pi16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; call t.7.1{r0} = getBombCountAround_Pi16_Pi16[param.row{r0}, param.column{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; branch t.7.1{r0} notequals 0: maybeRevealAround_Pi16_Pi16_ret
        cp   r0, #%00
        jr   ne, maybeRevealAround_Pi16_Pi16_ret
        ; const dr.1{r0}, -1
        ld   r0, #%ff
        ld   r1, #%ff
        ; 190:2 for dr <= 1
        ; move dr.2{r12}, dr.1{r0}
        ld   r13, r1
        ld   r12, r0
        jr   for_31

for_31_body:
        ; move r.1{r2}, param.row{r8}
        ld   r2, r8
        ld   r3, r9
        ; add r.1{r2}, dr.2{r12}
        add  r3, r13
        adc  r2, r12
        ; const dc.1{r0}, -1
        ld   r0, #%ff
        ld   r1, #%ff
        ; 192:3 for dc <= 1
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r.1{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        jr   for_32

for_32_body:
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; branch dr.2{r12} notequals 0: if_33_end
        cp   r13, #%00
        jr   ne, if_33_end
        cp   r12, #%00
        jr   ne, if_33_end
        ; branch dc.2{r0} notequals 0: if_33_end
        cp   r1, #%00
        jr   ne, if_33_end
        cp   r0, #%00
        jr   ne, if_33_end
        ; addrof memVarAddr{r14}, dc.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], dc.2{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        jr   for_32_continue

if_33_end:
        ; move c.1{r4}, param.column{r10}
        ld   r4, r10
        ld   r5, r11
        ; add c.1{r4}, dc.2{r0}
        add  r5, r1
        adc  r4, r0
        ; addrof memVarAddr{r14}, dc.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], dc.2{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; 198:4 if !checkCellBounds_Pi16_Pi16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; move r.1{r0}, r.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r.1{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        decw r14
        ; move c.1{r2}, c.1{r4}
        ld   r2, r4
        ld   r3, r5
        ; addrof memVarAddr{r14}, c.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], c.1{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        decw r14
        ; call t.8.1{r0} = checkCellBounds_Pi16_Pi16[r.1{r0}, c.1{r2}] -> bool
        call checkCellBounds_Pi16_Pi16
        ; branch t.8.1{r0} equals 0: for_32_continue
        cp   r0, #%00
        jr   eq, for_32_continue
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move r.1{r0}, r.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, c.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load c.1{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        incw r14
        lde  r5, @rr14
        decw r14
        ; move c.1{r2}, c.1{r4}
        ld   r2, r4
        ld   r3, r5
        ; call cell.1{r0} = getCell_Pi16_Pi16[r.1{r0}, c.1{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move cell.1{r1}, cell.1{r0}
        ld   r1, r0
        ; 203:4 if isOpen_Pu8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; addrof memVarAddr{r14}, cell.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], cell.1{r1}
        lde  @rr14, r1
        ; call t.9.1{r0} = isOpen_Pu8[cell.1{r0}] -> bool
        call isOpen_Pu8
        ; branch t.9.1{r0} notequals 0: for_32_continue
        cp   r0, #%00
        jr   ne, for_32_continue
        ; load cell.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; move t.10.1{r4}, cell.1{r0}
        ld   r4, r0
        ; or t.10.1{r4}, 2
        or  r4, #%02
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move r.1{r0}, r.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, c.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load c.1{r5}, [memVarAddr{r14}]
        lde  r5, @rr14
        incw r14
        lde  r6, @rr14
        decw r14
        ; move c.1{r2}, c.1{r5}
        ld   r2, r5
        ld   r3, r6
        ; call setCell_Pi16_Pi16_Pu8[r.1{r0}, c.1{r2}, t.10.1{r4}]
        call setCell_Pi16_Pi16_Pu8
        ; addrof memVarAddr{r14}, r.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; move r.1{r0}, r.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, c.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load c.1{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        decw r14
        ; call maybeRevealAround_Pi16_Pi16[r.1{r0}, c.1{r2}]
        call maybeRevealAround_Pi16_Pi16
for_32_continue:
        ; addrof memVarAddr{r14}, dc.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load dc.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; add dc.5{r0}, 1
        incw r0
for_32:
        ; branch dc.2{r0} lteq 1: for_32_body
        cp   r0, #%00
        jr   lt, for_32_body
        jr   ne, .lt24
        cp   r1, #%01
        jr   ule, for_32_body
.lt24:
        ; move dr.4{r0}, dr.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; add dr.4{r0}, 1
        incw r0
        ; move dr.2{r12}, dr.4{r0}
        ld   r13, r1
        ld   r12, r0
for_31:
        ; branch dr.2{r12} lteq 1: for_31_body, maybeRevealAround_Pi16_Pi16_ret
        cp   r12, #%00
        jr   lt, for_31_body
        jr   ne, .lt25
        cp   r13, #%01
        jr   ule, for_31_body
.lt25:
maybeRevealAround_Pi16_Pi16_ret:
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
        add  %31, #%07
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
        ; call initRandom_Pi32[arg.0.0{r0}]
        call initRandom_Pi32
        ; const needsInitialize.1{r8}, 1
        ld   r8, #%01
        ; call clearField[]
        call clearField
        ; const curr_c.1{r9}, 20
        ld   r9, #%00
        ld   r10, #%14
        ; const curr_r.1{r11}, 10
        ld   r11, #%00
        ld   r12, #%0a
        ; const arg.2.0{r0}, 20
        ld   r0, #%00
        ld   r1, #%14
        ; const arg.2.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.2.0{r0}, arg.2.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.6.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString_P_pu8[t.6.1{r0}]
        call printString_P_pu8
        ; 221:2 while true
        jr   while_37

if_38_then:
        ; 224:4 if printLeft([])
        ; call t.7.1{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.7.1{r0} notequals 0: if_39_then, if_38_end
        cp   r0, #%00
        jr   ne, if_39_then
if_38_end:
        ; call chr.1{r0} = getChar[] -> i16
        call getChar
        ; 231:3 if chr == 27
        ; branch chr.1{r0} equals 27: main_ret
        cp   r1, #%1b
        jr   ne, .notEquals26
        cp   r0, #%00
        jr   eq, main_ret
.notEquals26:
        ; branch chr.1{r0} equals 3: if_41_then
        cp   r1, #%03
        jr   ne, .notEquals27
        cp   r0, #%00
        jr   eq, if_41_then
.notEquals27:
        ; branch chr.1{r0} notequals 4: if_42_else, if_42_then
        cp   r1, #%04
        jr   ne, if_42_else
        cp   r0, #%00
        jr   ne, if_42_else
        jr   if_42_then

if_41_then:
        ; move t.10.1{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; add t.10.1{r0}, 20
        add  r1, #%14
        adc  r0, #%00
        ; sub t.9.1{r0}, 1
        decw r0
        ; mod curr_r.4{r0}, 20
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; move curr_r.2{r11}, curr_r.4{r0}
        ld   r12, r1
        ld   r11, r0
        jr   while_37

if_42_else:
        ; branch chr.1{r0} notequals 1: if_43_else, if_43_then
        cp   r1, #%01
        jr   ne, if_43_else
        cp   r0, #%00
        jr   ne, if_43_else
        jr   if_43_then

if_42_then:
        ; move t.11.1{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; add t.11.1{r0}, 1
        incw r0
        ; mod curr_r.5{r0}, 20
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; move curr_r.2{r11}, curr_r.5{r0}
        ld   r12, r1
        ld   r11, r0
        jr   while_37

if_43_else:
        ; branch chr.1{r0} notequals 2: if_44_else, if_44_then
        cp   r1, #%02
        jr   ne, if_44_else
        cp   r0, #%00
        jr   ne, if_44_else
        jr   if_44_then

if_43_then:
        ; move t.13.1{r0}, curr_c.2{r9}
        ld   r0, r9
        ld   r1, r10
        ; add t.13.1{r0}, 40
        add  r1, #%28
        adc  r0, #%00
        ; sub t.12.1{r0}, 1
        decw r0
        ; mod curr_c.4{r0}, 40
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%28
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; move curr_c.2{r9}, curr_c.4{r0}
        ld   r10, r1
        ld   r9, r0
        jr   while_37

if_44_else:
        ; branch chr.1{r0} notequals 32: if_45_else, if_45_then
        cp   r1, #%20
        jr   ne, if_45_else
        cp   r0, #%00
        jr   ne, if_45_else
        jr   if_45_then

if_44_then:
        ; move t.14.1{r0}, curr_c.2{r9}
        ld   r0, r9
        ld   r1, r10
        ; add t.14.1{r0}, 1
        incw r0
        ; mod curr_c.5{r0}, 40
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%28
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; move curr_c.2{r9}, curr_c.5{r0}
        ld   r10, r1
        ld   r9, r0
        jr   while_37

if_45_else:
        ; branch chr.1{r0} notequals 13: while_37, if_48_then
        cp   r1, #%0d
        jr   ne, while_37
        cp   r0, #%00
        jr   ne, while_37
        jr   if_48_then

if_45_then:
        ; branch needsInitialize.2{r8} notequals 0: while_37, if_46_then
        cp   r8, #%00
        jr   ne, while_37
        jr   if_46_then

if_48_then:
        ; branch needsInitialize.2{r8} equals 0: if_49_end, if_49_then
        cp   r8, #%00
        jr   eq, if_49_end
        jr   if_49_then

if_46_then:
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call cell.1{r0} = getCell_Pi16_Pi16[curr_r.2{r0}, curr_c.2{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move cell.1{r13}, cell.1{r0}
        ld   r13, r0
        ; 255:5 if !isOpen_Pu8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=255:17]])
        ; call t.15.1{r0} = isOpen_Pu8[cell.1{r0}] -> bool
        call isOpen_Pu8
        ; branch t.15.1{r0} notequals 0: while_37, if_47_then
        cp   r0, #%00
        jr   ne, while_37
        jr   if_47_then

if_49_then:
        ; const needsInitialize.5{r8}, 0
        ld   r8, #%00
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call initField_Pi16_Pi16[curr_r.2{r0}, curr_c.2{r2}]
        call initField_Pi16_Pi16
        jr   if_49_end

if_47_then:
        ; move cell.2{r4}, cell.1{r13}
        ld   r4, r13
        ; xor cell.2{r4}, 4
        xor r4, #%04
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call setCell_Pi16_Pi16_Pu8[curr_r.2{r0}, curr_c.2{r2}, cell.2{r4}]
        call setCell_Pi16_Pi16_Pu8
        jr   while_37

if_49_end:
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call cell.3{r0} = getCell_Pi16_Pi16[curr_r.2{r0}, curr_c.2{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move cell.3{r13}, cell.3{r0}
        ld   r13, r0
        ; 267:4 if !isOpen_Pu8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=267:16]])
        ; call t.16.1{r0} = isOpen_Pu8[cell.3{r0}] -> bool
        call isOpen_Pu8
        ; branch t.16.1{r0} notequals 0: if_50_end
        cp   r0, #%00
        jr   ne, if_50_end
        ; move t.17.1{r4}, cell.3{r13}
        ld   r4, r13
        ; or t.17.1{r4}, 2
        or  r4, #%02
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call setCell_Pi16_Pi16_Pu8[curr_r.2{r0}, curr_c.2{r2}, t.17.1{r4}]
        call setCell_Pi16_Pi16_Pu8
if_50_end:
        ; 270:4 if isBomb_Pu8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=270:15]])
        ; move cell.3{r0}, cell.3{r13}
        ld   r0, r13
        ; call t.18.1{r0} = isBomb_Pu8[cell.3{r0}] -> bool
        call isBomb_Pu8
        ; branch t.18.1{r0} notequals 0: if_51_then
        cp   r0, #%00
        jr   ne, if_51_then
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call maybeRevealAround_Pi16_Pi16[curr_r.2{r0}, curr_c.2{r2}]
        call maybeRevealAround_Pi16_Pi16
while_37:
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call printField_Pi16_Pi16[curr_r.2{r0}, curr_c.2{r2}]
        call printField_Pi16_Pi16
        ; 223:3 if !needsInitialize
        ; branch needsInitialize.2{r8} notequals 0: if_38_end, if_38_then
        cp   r8, #%00
        jr   ne, if_38_end
        jr   if_38_then

if_39_then:
        ; const t.8.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString_P_pu8[t.8.1{r0}]
        call printString_P_pu8
        jr   main_ret

if_51_then:
        ; move curr_r.2{r0}, curr_r.2{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ld   r3, r10
        ; call printField_Pi16_Pi16[curr_r.2{r0}, curr_c.2{r2}]
        call printField_Pi16_Pi16
        ; const t.19.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString_P_pu8[t.19.1{r0}]
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

        ; void printUint_Pi32
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

        ; variable 0: field[] (u8*/800)
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

string_0:
        .data "|" %0a %00
string_1:
        .data "Left:" %00
string_2:
        .data " You've cleaned the field!" %00
string_3:
        .data "boom! you've lost" %00

