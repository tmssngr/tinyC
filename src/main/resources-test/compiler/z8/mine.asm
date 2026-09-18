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
        ; 23:19 return r * 17 + c
        ; mul t.5.1{r2}, 17
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%11
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

        ; u8 getCell@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
getCell_Pu8_Pu8:
        ; 27:15 return [...]
        ; call t.4.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.3.1{r2}, field
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.3.2{r2}, t.4.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.2.1{r0}, [t.3.2{r2}]
        lde  r0, @rr2
        ret

        ; bool isBomb@u8
        ; arg cell (u8): r0
isBomb_Pu8:
        ; 31:27 return cell & 1 != 0
        ; move t.2.1{r1}, param.cell{r0}
        ld   r1, r0
        ; and t.2.1{r1}, 1
        and  r1, #%01
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cp   r1, #%00
        jr   ne, .ne1
        ld   r0, #0  ; false
        jr   .1
.ne1:
        ld   r0, #1
.1:
        ret

        ; bool isOpen@u8
        ; arg cell (u8): r0
isOpen_Pu8:
        ; 35:27 return cell & 2 != 0
        ; move t.2.1{r1}, param.cell{r0}
        ld   r1, r0
        ; and t.2.1{r1}, 2
        and  r1, #%02
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cp   r1, #%00
        jr   ne, .ne2
        ld   r0, #0  ; false
        jr   .2
.ne2:
        ld   r0, #1
.2:
        ret

        ; bool isFlag@u8
        ; arg cell (u8): r0
isFlag_Pu8:
        ; 39:27 return cell & 4 != 0
        ; move t.2.1{r1}, param.cell{r0}
        ld   r1, r0
        ; and t.2.1{r1}, 4
        and  r1, #%04
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cp   r1, #%00
        jr   ne, .ne3
        ld   r0, #0  ; false
        jr   .3
.ne3:
        ld   r0, #1
.3:
        ret

        ; void setCell@u8@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; arg cell (u8): r2
setCell_Pu8_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; move param.cell{r8}, cell{r2}
        ld   r8, r2
        ; call t.4.1{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
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
        push r15
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; move rowFrom.1{r10}, param.row{r8}
        ld   r10, r8
        ; 48:2 if rowFrom > 0
        ; branch rowFrom.1{r10} lteq 0: if_1_end
        cp   r10, #%00
        jr   ule, if__1__end
        ; sub rowFrom.3{r10}, 1
        dec  r10
if__1__end:
        ; move rowTo.1{r11}, param.row{r8}
        ld   r11, r8
        ; add rowTo.1{r11}, 1
        inc  r11
        ; 52:2 if rowTo >= 20
        ; branch rowTo.1{r11} lt 20: if_2_end
        cp   r11, #%14
        jr   ult, if__2__end
        ; sub rowTo.3{r11}, 1
        dec  r11
if__2__end:
        ; move colFrom.1{r12}, param.column{r9}
        ld   r12, r9
        ; 57:2 if colFrom > 0
        ; branch colFrom.1{r12} lteq 0: if_3_end
        cp   r12, #%00
        jr   ule, if__3__end
        ; sub colFrom.3{r12}, 1
        dec  r12
if__3__end:
        ; move colTo.1{r13}, param.column{r9}
        ld   r13, r9
        ; add colTo.1{r13}, 1
        inc  r13
        ; 61:2 if colTo >= 17
        ; branch colTo.1{r13} lt 17: if_4_end
        cp   r13, #%11
        jr   ult, if__4__end
        ; sub colTo.3{r13}, 1
        dec  r13
if__4__end:
        ; const count.1{r14}, 0
        ld   r14, #%00
        ; 66:2 for r <= rowTo
        jr   for__5

for__5__body:
        ; move c.1{r15}, colFrom.2{r12}
        ld   r15, r12
        ; 67:3 for c <= colTo
        jr   for__6

for__6__body:
        ; branch r.2{r10} notequals param.row{r8}: if_7_end
        cp   r10, r8
        jr   ne, if__7__end
        ; branch c.2{r15} equals param.column{r9}: for_6_continue, if_7_end
        cp   r15, r9
        jr   eq, for__6__continue
if__7__end:
        ; move r.2{r0}, r.2{r10}
        ld   r0, r10
        ; move c.2{r1}, c.2{r15}
        ld   r1, r15
        ; call cell.1{r0} = getCell@u8@u8[r.2{r0}, c.2{r1}] -> u8
        call getCell_Pu8_Pu8
        ; 72:4 if isBomb@u8([ExprVarAccess[varName=cell, index=9, scope=function, type=u8, varIsArray=false, location=72:14]])
        ; call t.10.1{r0} = isBomb@u8[cell.1{r0}] -> bool
        call isBomb_Pu8
        ; branch t.10.1{r0} equals 0: for_6_continue
        cp   r0, #%00
        jr   eq, for__6__continue
        ; move count.6{r1}, count.3{r14}
        ld   r1, r14
        ; add count.6{r1}, 1
        inc  r1
        ; move count.5{r14}, count.6{r1}
        ld   r14, r1
for__6__continue:
        ; move c.5{r1}, c.2{r15}
        ld   r1, r15
        ; add c.5{r1}, 1
        inc  r1
        ; move c.2{r15}, c.5{r1}
        ld   r15, r1
for__6:
        ; branch c.2{r15} lteq colTo.2{r13}: for_6_body
        cp   r15, r13
        jr   ule, for__6__body
        ; move r.4{r1}, r.2{r10}
        ld   r1, r10
        ; add r.4{r1}, 1
        inc  r1
        ; move r.2{r10}, r.4{r1}
        ld   r10, r1
for__5:
        ; branch r.2{r10} lteq rowTo.2{r11}: for_5_body
        cp   r10, r11
        jr   ule, for__5__body
        ; 77:9 return count
        ; move count.2{r0}, count.2{r14}
        ld   r0, r14
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

        ; i16 columnToX@u8
        ; arg column (u8): r0
columnToX_Pu8:
        ; cast c.1{r2}(i16), param.column{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; 82:17 return c + 1 << 1
        ; add t.3.1{r2}, 1
        incw r2
        ; move t.2.1{r0}, t.3.1{r2}
        ld   r0, r2
        ld   r1, r3
        ; shiftleft t.2.1{r0}, 1
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
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; call cell.1{r0} = getCell@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move param.row{r1}, param.row{r8}
        ld   r1, r8
        ; move param.column{r2}, param.column{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell.1{r0}, param.row{r1}, param.column{r2}]
        call printCellAt_Pu8_Pu8_Pu8
        ; restore clobbered non-volatile registers
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
        push r11
        ; move param.cell{r8}, cell{r0}
        ld   r8, r0
        ; move param.row{r9}, row{r1}
        ld   r9, r1
        ; move param.column{r10}, column{r2}
        ld   r10, r2
        ; const chr.1{r11}, 46
        ld   r11, #%2e
        ; 98:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=98:13]])
        ; call t.5.1{r0} = isOpen@u8[param.cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.5.1{r0} notequals 0: if_10_then
        cp   r0, #%00
        jr   ne, if__10__then
        ; 112:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=112:18]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.7.1{r0} = isFlag@u8[param.cell{r0}] -> bool
        call isFlag_Pu8
        ; branch t.7.1{r0} equals 0: printCell@u8@u8@u8.no_critical_edge_10, if_13_then
        cp   r0, #%00
        jr   eq, printCell_Pu8_Pu8_Pu8_2eno__critical__edge__10
        jr   if__13__then

if__10__then:
        ; 99:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=99:14]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.6.1{r0} = isBomb@u8[param.cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.6.1{r0} equals 0: if_11_else, if_11_then
        cp   r0, #%00
        jr   eq, if__11__else
        jr   if__11__then

printCell_Pu8_Pu8_Pu8_2eno__critical__edge__10:
        ; move chr.2{r8}, chr.1{r11}
        ld   r8, r11
        jr   if__10__end

if__13__then:
        ; const chr.3{r8}, 35
        ld   r8, #%23
        jr   if__10__end

if__11__else:
        ; move param.row{r0}, param.row{r9}
        ld   r0, r9
        ; move param.column{r1}, param.column{r10}
        ld   r1, r10
        ; call count.1{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; 104:4 if count > 0
        ; branch count.1{r0} lteq 0: if_12_else, if_12_then
        cp   r0, #%00
        jr   ule, if__12__else
        jr   if__12__then

if__11__then:
        ; const chr.4{r8}, 42
        ld   r8, #%2a
        jr   if__10__end

if__12__else:
        ; const chr.5{r8}, 32
        ld   r8, #%20
        jr   if__10__end

if__12__then:
        ; move chr.6{r8}, count.1{r0}
        ld   r8, r0
        ; add chr.6{r8}, 48
        add  r8, #%30
if__10__end:
        ; move chr.2{r0}, chr.2{r8}
        ld   r0, r8
        ; call printChar@u8[chr.2{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
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
        ; call setCursor@i16@i16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const row.1{r8}, 0
        ld   r8, #%00
        ; 120:2 for row < 20
        jr   for__14

for__14__body:
        ; const arg.1.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
        ; const column.1{r9}, 0
        ld   r9, #%00
        ; 122:3 for column < 17
        jr   for__15

for__15__body:
        ; const arg.2.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
        ; move row.2{r0}, row.2{r8}
        ld   r0, r8
        ; move column.2{r1}, column.2{r9}
        ld   r1, r9
        ; call cell.1{r0} = getCell@u8@u8[row.2{r0}, column.2{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move row.2{r1}, row.2{r8}
        ld   r1, r8
        ; move column.2{r2}, column.2{r9}
        ld   r2, r9
        ; call printCell@u8@u8@u8[cell.1{r0}, row.2{r1}, column.2{r2}]
        call printCell_Pu8_Pu8_Pu8
        ; add column.3{r9}, 1
        inc  r9
for__15:
        ; branch column.2{r9} lt 17: for_15_body
        cp   r9, #%11
        jr   ult, for__15__body
        ; const t.3.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.3.1{r0}]
        call printString_P_Pu8
        ; move row.4{r0}, row.2{r8}
        ld   r0, r8
        ; add row.4{r0}, 1
        inc  r0
        ; move row.2{r8}, row.4{r0}
        ld   r8, r0
for__14:
        ; branch row.2{r8} lt 20: for_14_body
        cp   r8, #%14
        jr   ult, for__14__body
        ; restore clobbered non-volatile registers
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
        ; call x.1{r0} = columnToX@u8[param.column{r0}] -> i16
        call columnToX_Pu8
        ; move x.1{r10}, x.1{r0}
        ld   r11, r1
        ld   r10, r0
        ; cast t.5.1{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; move t.6.1{r2}, x.1{r10}
        ld   r2, r10
        ld   r3, r11
        ; sub t.6.1{r2}, 1
        decw r2
        ; call setCursor@i16@i16[t.5.1{r0}, t.6.1{r2}]
        call setCursor_Pi16_Pi16
        ; const chr.1{r12}, 32
        ld   r12, #%20
        ; 135:2 if show
        ; branch param.show{r9} equals 0: if_16_end
        cp   r9, #%00
        jr   eq, if__16__end
        ; const chr.3{r12}, 91
        ld   r12, #%5b
if__16__end:
        ; move chr.2{r0}, chr.2{r12}
        ld   r0, r12
        ; call printChar@u8[chr.2{r0}]
        call printChar_Pu8
        ; cast t.7.1{r0}(i16), param.row{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; move t.8.1{r2}, x.1{r10}
        ld   r2, r10
        ld   r3, r11
        ; add t.8.1{r2}, 1
        incw r2
        ; call setCursor@i16@i16[t.7.1{r0}, t.8.1{r2}]
        call setCursor_Pi16_Pi16
        ; 141:2 if show
        ; branch param.show{r9} notequals 0: if_17_then
        cp   r9, #%00
        jr   ne, if__17__then
        ; move chr.4{r0}, chr.2{r12}
        ld   r0, r12
        jr   if__17__end

if__17__then:
        ; const chr.5{r8}, 93
        ld   r8, #%5d
        ; move chr.4{r0}, chr.5{r8}
        ld   r0, r8
if__17__end:
        ; call printChar@u8[chr.4{r0}]
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
        ; move i.1{r8}, param.i{r0}
        ld   r9, r1
        ld   r8, r0
        jr   for__18

for__18__body:
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
for__18:
        ; branch i.1{r8} gt 0: for_18_body
        cp   r8, #%00
        jr   gt, for__18__body
        jr   ne, .gt4
        cp   r9, #%00
        jr   ugt, for__18__body
.gt4:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; u8 getDigitCount@i16
        ; arg value (i16): r0
getDigitCount_Pi16:
        ; const count.1{r2}, 0
        ld   r2, #%00
        ; 155:2 if value < 0
        ; branch param.value{r0} lt 0: if_19_then
        cp   r0, #%00
        jr   lt, if__19__then
        jr   ne, .lt5
        cp   r1, #%00
        jr   ult, if__19__then
.lt5:
        ; move value.1{r3}, param.value{r0}
        ld   r4, r1
        ld   r3, r0
        ; move count.2{r1}, count.1{r2}
        ld   r1, r2
        jr   if__19__end

if__19__then:
        ; const count.3{r2}, 1
        ld   r2, #%01
        ; neg value.2{r3}, param.value{r0}
        ld   r3, #%00
        ld   r4, #%00
        sub  r4, r1
        sbc  r3, r0
        ; move count.2{r1}, count.3{r2}
        ld   r1, r2
if__19__end:
        ; move value.3{r2}, value.1{r3}
        ld   r2, r3
        ld   r3, r4
        jr   while__20

getDigitCount_Pi16_2eno__critical__edge__7:
        ; move value.3{r2}, value.4{r1}
        ld   r3, r2
        ld   r2, r1
        ; move count.4{r1}, count.5{r0}
        ld   r1, r0
while__20:
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
        ; 163:3 if value == 0
        ; branch value.4{r1} notequals 0: getDigitCount@i16.no_critical_edge_7
        cp   r2, #%00
        jr   ne, getDigitCount_Pi16_2eno__critical__edge__7
        cp   r1, #%00
        jr   ne, getDigitCount_Pi16_2eno__critical__edge__7
        ; 168:9 return count
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
        ; 173:2 for r < 20
        jr   for__22

for__22__body:
        ; const c.1{r11}, 0
        ld   r11, #%00
        ; 174:3 for c < 17
        jr   for__23

for__23__body:
        ; move r.2{r0}, r.2{r10}
        ld   r0, r10
        ; move c.2{r1}, c.2{r11}
        ld   r1, r11
        ; call cell.1{r0} = getCell@u8@u8[r.2{r0}, c.2{r1}] -> u8
        call getCell_Pu8_Pu8
        ; 176:4 if cell & 6 == 0
        ; move t.4.1{r2}, cell.1{r0}
        ld   r2, r0
        ; and t.4.1{r2}, 6
        and  r2, #%06
        ; branch t.4.1{r2} equals 0: if_24_then
        cp   r2, #%00
        jr   eq, if__24__then
        ; move count.4{r2}, count.3{r8}
        ld   r2, r8
        ld   r3, r9
        jr   for__23__continue

if__24__then:
        ; move count.5{r2}, count.3{r8}
        ld   r2, r8
        ld   r3, r9
        ; add count.5{r2}, 1
        incw r2
for__23__continue:
        ; move c.4{r4}, c.2{r11}
        ld   r4, r11
        ; add c.4{r4}, 1
        inc  r4
        ; move count.3{r8}, count.4{r2}
        ld   r9, r3
        ld   r8, r2
        ; move c.2{r11}, c.4{r4}
        ld   r11, r4
for__23:
        ; branch c.2{r11} lt 17: for_23_body
        cp   r11, #%11
        jr   ult, for__23__body
        ; move r.4{r2}, r.2{r10}
        ld   r2, r10
        ; add r.4{r2}, 1
        inc  r2
        ; move r.2{r10}, r.4{r2}
        ld   r10, r2
for__22:
        ; branch r.2{r10} lt 20: for_22_body
        cp   r10, #%14
        jr   ult, for__22__body
        ; 181:9 return count
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
        ; const arg.2.0{r0}, 17
        ld   r0, #%00
        ld   r1, #%11
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
        ; 192:15 return count == 0
        ; equals t.6.1{r0}, count.1{r8}, 0
        cp   r8, #%00
        jr   ne, .ne6
        cp   r9, #%00
        jr   ne, .ne6
        ld   r0, #1  ; true
        jr   .6
.ne6:
        ld   r0, #0
.6:
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
        ; branch param.a{r2} lt 0: if_25_then
        cp   r2, #%00
        jr   lt, if__25__then
        jr   ne, .lt7
        cp   r3, #%00
        jr   ult, if__25__then
.lt7:
        ; 199:9 return a
        jr   abs_Pi16__ret

if__25__then:
        ; 197:10 return -a
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
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const r.1{r8}, 0
        ld   r8, #%00
        ; 203:2 for r < 20
        jr   for__26

for__26__body:
        ; const c.1{r9}, 0
        ld   r9, #%00
        ; 204:3 for c < 17
        jr   for__27

for__27__body:
        ; move r.2{r0}, r.2{r8}
        ld   r0, r8
        ; move c.2{r1}, c.2{r9}
        ld   r1, r9
        ; const arg.0.2{r2}, 0
        ld   r2, #%00
        ; call setCell@u8@u8@u8[r.2{r0}, c.2{r1}, arg.0.2{r2}]
        call setCell_Pu8_Pu8_Pu8
        ; move c.3{r0}, c.2{r9}
        ld   r0, r9
        ; add c.3{r0}, 1
        inc  r0
        ; move c.2{r9}, c.3{r0}
        ld   r9, r0
for__27:
        ; branch c.2{r9} lt 17: for_27_body
        cp   r9, #%11
        jr   ult, for__27__body
        ; move r.4{r0}, r.2{r8}
        ld   r0, r8
        ; add r.4{r0}, 1
        inc  r0
        ; move r.2{r8}, r.4{r0}
        ld   r8, r0
for__26:
        ; branch r.2{r8} lt 20: for_26_body
        cp   r8, #%14
        jr   ult, for__26__body
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
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
        ; const bombs.1{r12}, 17
        ld   r12, #%00
        ld   r13, #%11
        ; 213:2 for bombs > 0
        jr   for__28

for__28__body:
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
        ; mod column.1{r2}, 17
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%11
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
        ; 216:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=216:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=216:20], location=216:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=217:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=217:20], location=217:18]]) > 1
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
        ; branch t.9.1{r0} gt 1: if_29_then
        cp   r0, #%00
        jr   gt, if__29__then
        jr   ne, .gt8
        cp   r1, #%01
        jr   ugt, if__29__then
.gt8:
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
        ; branch t.11.1{r0} lteq 1: for_28_continue, if_29_then
        cp   r0, #%00
        jr   lt, for__28__continue
        jr   ne, .lt9
        cp   r1, #%01
        jr   ule, for__28__continue
.lt9:
if__29__then:
        ; addrof memVarAddr{r14}, row.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row.1{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        incw r14
        lde  r4, @rr14
        decw r14
        ; cast t.13.1{r0}(u8), row.1{r3}(i16)
        ld   r0, r4
        ; addrof memVarAddr{r14}, column.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column.1{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        incw r14
        lde  r4, @rr14
        decw r14
        ; cast t.14.1{r1}(u8), column.1{r3}(i16)
        ld   r1, r4
        ; const arg.4.2{r2}, 1
        ld   r2, #%01
        ; call setCell@u8@u8@u8[t.13.1{r0}, t.14.1{r1}, arg.4.2{r2}]
        call setCell_Pu8_Pu8_Pu8
for__28__continue:
        ; move bombs.5{r0}, bombs.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; sub bombs.5{r0}, 1
        decw r0
        ; move bombs.2{r12}, bombs.5{r0}
        ld   r13, r1
        ld   r12, r0
for__28:
        ; branch bombs.2{r12} gt 0: for_28_body
        cp   r12, #%00
        jr   gt, for__28__body
        jr   ne, .gt10
        cp   r13, #%00
        jr   ugt, for__28__body
.gt10:
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
        push r14
        push r15
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; call printCellAt@u8@u8[param.row{r0}, param.column{r1}]
        call printCellAt_Pu8_Pu8
        ; 225:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=225:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=225:30]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call t.9.1{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.9.1{r0} notequals 0: maybeRevealAround@u8@u8_ret
        cp   r0, #%00
        jr   ne, maybeRevealAround_Pu8_Pu8__ret
        ; move rowFrom.1{r10}, param.row{r8}
        ld   r10, r8
        ; 230:2 if rowFrom > 0
        ; branch rowFrom.1{r10} lteq 0: if_32_end
        cp   r10, #%00
        jr   ule, if__32__end
        ; sub rowFrom.3{r10}, 1
        dec  r10
if__32__end:
        ; move rowTo.1{r11}, param.row{r8}
        ld   r11, r8
        ; add rowTo.1{r11}, 1
        inc  r11
        ; 234:2 if rowTo >= 20
        ; branch rowTo.1{r11} lt 20: if_33_end
        cp   r11, #%14
        jr   ult, if__33__end
        ; sub rowTo.3{r11}, 1
        dec  r11
if__33__end:
        ; move colFrom.1{r12}, param.column{r9}
        ld   r12, r9
        ; 239:2 if colFrom > 0
        ; branch colFrom.1{r12} lteq 0: if_34_end
        cp   r12, #%00
        jr   ule, if__34__end
        ; sub colFrom.3{r12}, 1
        dec  r12
if__34__end:
        ; move colTo.1{r13}, param.column{r9}
        ld   r13, r9
        ; add colTo.1{r13}, 1
        inc  r13
        ; 243:2 if colTo >= 17
        ; branch colTo.1{r13} lt 17: if_35_end
        cp   r13, #%11
        jr   ult, if__35__end
        ; sub colTo.3{r13}, 1
        dec  r13
if__35__end:
        ; 246:2 for r <= rowTo
        jr   for__36

for__36__body:
        ; move c.1{r14}, colFrom.2{r12}
        ld   r14, r12
        ; 247:3 for c <= colTo
        jr   for__37

for__37__body:
        ; branch r.2{r10} notequals param.row{r8}: if_38_end
        cp   r10, r8
        jr   ne, if__38__end
        ; branch c.2{r14} equals param.column{r9}: for_37_continue, if_38_end
        cp   r14, r9
        jr   eq, for__37__continue
if__38__end:
        ; move r.2{r0}, r.2{r10}
        ld   r0, r10
        ; move c.2{r1}, c.2{r14}
        ld   r1, r14
        ; call cell.1{r0} = getCell@u8@u8[r.2{r0}, c.2{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move cell.1{r15}, cell.1{r0}
        ld   r15, r0
        ; 253:4 if isOpen@u8([ExprVarAccess[varName=cell, index=8, scope=function, type=u8, varIsArray=false, location=253:15]])
        ; call t.10.1{r0} = isOpen@u8[cell.1{r0}] -> bool
        call isOpen_Pu8
        ; branch t.10.1{r0} notequals 0: for_37_continue
        cp   r0, #%00
        jr   ne, for__37__continue
        ; move t.11.1{r2}, cell.1{r15}
        ld   r2, r15
        ; or t.11.1{r2}, 2
        or  r2, #%02
        ; move r.2{r0}, r.2{r10}
        ld   r0, r10
        ; move c.2{r1}, c.2{r14}
        ld   r1, r14
        ; call setCell@u8@u8@u8[r.2{r0}, c.2{r1}, t.11.1{r2}]
        call setCell_Pu8_Pu8_Pu8
        ; move r.2{r0}, r.2{r10}
        ld   r0, r10
        ; move c.2{r1}, c.2{r14}
        ld   r1, r14
        ; call maybeRevealAround@u8@u8[r.2{r0}, c.2{r1}]
        call maybeRevealAround_Pu8_Pu8
for__37__continue:
        ; move c.5{r0}, c.2{r14}
        ld   r0, r14
        ; add c.5{r0}, 1
        inc  r0
        ; move c.2{r14}, c.5{r0}
        ld   r14, r0
for__37:
        ; branch c.2{r14} lteq colTo.2{r13}: for_37_body
        cp   r14, r13
        jr   ule, for__37__body
        ; move r.4{r0}, r.2{r10}
        ld   r0, r10
        ; add r.4{r0}, 1
        inc  r0
        ; move r.2{r10}, r.4{r0}
        ld   r10, r0
for__36:
        ; branch r.2{r10} lteq rowTo.2{r11}: for_36_body, maybeRevealAround@u8@u8_ret
        cp   r10, r11
        jr   ule, for__36__body
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
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
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
        ; const t.6.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.6.1{r0}]
        call printString_P_Pu8
        ; const curr_c.1{r9}, 8
        ld   r9, #%08
        ; const curr_r.1{r10}, 10
        ld   r10, #%0a
        ; 272:2 while true
        jr   while__41

if__42__then:
        ; 274:4 if printLeft([])
        ; call t.7.1{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.7.1{r0} notequals 0: if_43_then, if_42_end
        cp   r0, #%00
        jr   ne, if__43__then
if__42__end:
        ; const t.9.1{r2}, 1
        ld   r2, #%01
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r.2{r0}, curr_c.2{r1}, t.9.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; call chr.1{r0} = getChar[] -> i16
        call getChar
        ; move chr.1{r11}, chr.1{r0}
        ld   r12, r1
        ld   r11, r0
        ; const t.10.1{r2}, 0
        ld   r2, #%00
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r.2{r0}, curr_c.2{r1}, t.10.1{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; 283:3 if chr == 27
        ; branch chr.1{r11} equals 27: main_ret
        cp   r12, #%1b
        jr   ne, .notEquals11
        cp   r11, #%00
        jr   eq, main__ret
.notEquals11:
        ; branch chr.1{r11} equals 13: if_45_then
        cp   r12, #%0d
        jr   ne, .notEquals12
        cp   r11, #%00
        jr   eq, if__45__then
.notEquals12:
        ; branch chr.1{r11} notequals 3: if_49_else, if_49_then
        cp   r12, #%03
        jr   ne, if__49__else
        cp   r11, #%00
        jr   ne, if__49__else
        jr   if__49__then

if__45__then:
        ; branch needsInitialize.2{r8} equals 0: if_46_end, if_46_then
        cp   r8, #%00
        jr   eq, if__46__end
        jr   if__46__then

if__49__else:
        ; branch chr.1{r11} notequals 4: if_51_else, if_51_then
        cp   r12, #%04
        jr   ne, if__51__else
        cp   r11, #%00
        jr   ne, if__51__else
        jr   if__51__then

if__49__then:
        ; branch curr_r.2{r10} lteq 0: while_41, if_50_then
        cp   r10, #%00
        jr   ule, while__41
        jr   if__50__then

if__46__then:
        ; const needsInitialize.5{r8}, 0
        ld   r8, #%00
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call initField@u8@u8[curr_r.2{r0}, curr_c.2{r1}]
        call initField_Pu8_Pu8
        jr   if__46__end

if__51__else:
        ; branch chr.1{r11} notequals 1: if_53_else, if_53_then
        cp   r12, #%01
        jr   ne, if__53__else
        cp   r11, #%00
        jr   ne, if__53__else
        jr   if__53__then

if__51__then:
        ; branch curr_r.2{r10} gteq 19: while_41, if_52_then
        cp   r10, #%13
        jr   uge, while__41
        jr   if__52__then

if__50__then:
        ; sub curr_r.5{r10}, 1
        dec  r10
        jr   while__41

if__46__end:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call cell.1{r0} = getCell@u8@u8[curr_r.2{r0}, curr_c.2{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move cell.1{r11}, cell.1{r0}
        ld   r11, r0
        ; 293:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=293:16]])
        ; call t.11.1{r0} = isOpen@u8[cell.1{r0}] -> bool
        call isOpen_Pu8
        ; branch t.11.1{r0} notequals 0: if_47_end, if_47_then
        cp   r0, #%00
        jr   ne, if__47__end
        jr   if__47__then

if__53__else:
        ; branch chr.1{r11} notequals 2: if_55_else, if_55_then
        cp   r12, #%02
        jr   ne, if__55__else
        cp   r11, #%00
        jr   ne, if__55__else
        jr   if__55__then

if__53__then:
        ; branch curr_c.2{r9} lteq 0: while_41, if_54_then
        cp   r9, #%00
        jr   ule, while__41
        jr   if__54__then

if__52__then:
        ; add curr_r.6{r10}, 1
        inc  r10
        jr   while__41

if__47__then:
        ; move t.12.1{r2}, cell.1{r11}
        ld   r2, r11
        ; or t.12.1{r2}, 2
        or  r2, #%02
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call setCell@u8@u8@u8[curr_r.2{r0}, curr_c.2{r1}, t.12.1{r2}]
        call setCell_Pu8_Pu8_Pu8
        jr   if__47__end

if__55__else:
        ; branch chr.1{r11} notequals 32: while_41, if_57_then
        cp   r12, #%20
        jr   ne, while__41
        cp   r11, #%00
        jr   ne, while__41
        jr   if__57__then

if__55__then:
        ; branch curr_c.2{r9} gteq 16: while_41, if_56_then
        cp   r9, #%10
        jr   uge, while__41
        jr   if__56__then

if__54__then:
        ; sub curr_c.6{r9}, 1
        dec  r9
        jr   while__41

if__47__end:
        ; 296:4 if isBomb@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=296:15]])
        ; move cell.1{r0}, cell.1{r11}
        ld   r0, r11
        ; call t.13.1{r0} = isBomb@u8[cell.1{r0}] -> bool
        call isBomb_Pu8
        ; branch t.13.1{r0} equals 0: if_48_end, if_48_then
        cp   r0, #%00
        jr   eq, if__48__end
        jr   if__48__then

if__57__then:
        ; branch needsInitialize.2{r8} notequals 0: while_41, if_58_then
        cp   r8, #%00
        jr   ne, while__41
        jr   if__58__then

if__56__then:
        ; add curr_c.7{r9}, 1
        inc  r9
        jr   while__41

if__48__end:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call maybeRevealAround@u8@u8[curr_r.2{r0}, curr_c.2{r1}]
        call maybeRevealAround_Pu8_Pu8
        jr   while__41

if__58__then:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call cell.3{r0} = getCell@u8@u8[curr_r.2{r0}, curr_c.2{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move cell.3{r11}, cell.3{r0}
        ld   r11, r0
        ; 331:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=331:17]])
        ; call t.15.1{r0} = isOpen@u8[cell.3{r0}] -> bool
        call isOpen_Pu8
        ; branch t.15.1{r0} notequals 0: while_41
        cp   r0, #%00
        jr   ne, while__41
        ; xor cell.4{r11}, 4
        xor r11, #%04
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; move cell.4{r2}, cell.4{r11}
        ld   r2, r11
        ; call setCell@u8@u8@u8[curr_r.2{r0}, curr_c.2{r1}, cell.4{r2}]
        call setCell_Pu8_Pu8_Pu8
        ; move cell.4{r0}, cell.4{r11}
        ld   r0, r11
        ; move curr_r.2{r1}, curr_r.2{r10}
        ld   r1, r10
        ; move curr_c.2{r2}, curr_c.2{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell.4{r0}, curr_r.2{r1}, curr_c.2{r2}]
        call printCellAt_Pu8_Pu8_Pu8
while__41:
        ; branch needsInitialize.2{r8} notequals 0: if_42_end, if_42_then
        cp   r8, #%00
        jr   ne, if__42__end
        jr   if__42__then

if__43__then:
        ; const t.8.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.8.1{r0}]
        call printString_P_Pu8
        jr   main__ret

if__48__then:
        ; move curr_r.2{r0}, curr_r.2{r10}
        ld   r0, r10
        ; move curr_c.2{r1}, curr_c.2{r9}
        ld   r1, r9
        ; call printCellAt@u8@u8[curr_r.2{r0}, curr_c.2{r1}]
        call printCellAt_Pu8_Pu8
        ; const t.14.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.14.1{r0}]
        call printString_P_Pu8
main__ret:
        ; restore clobbered non-volatile registers
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

