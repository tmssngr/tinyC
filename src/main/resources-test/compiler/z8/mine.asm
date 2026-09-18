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

        ; u8 getCell@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
getCell_Pu8_Pu8:
        ; 22:15 return [...]
        ; call t.4{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.3{r2}, [field]
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.3{r2}, t.3{r2}, t.4{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.2{r0}, [t.3{r2}]
        lde  r0, @rr2
        ret

        ; bool isBomb@u8
        ; arg cell (u8): r0
isBomb_Pu8:
        ; 26:27 return cell & 1 != 0
        ; move t.2{r1}, param.cell{r0}
        ld   r1, r0
        ; and t.2{r1}, t.2{r1}, 1
        and  r1, #%01
        ; notequals t.1{r0}, t.2{r1}, 0
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
        ; 30:27 return cell & 2 != 0
        ; move t.2{r1}, param.cell{r0}
        ld   r1, r0
        ; and t.2{r1}, t.2{r1}, 2
        and  r1, #%02
        ; notequals t.1{r0}, t.2{r1}, 0
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
        ; 34:27 return cell & 4 != 0
        ; move t.2{r1}, param.cell{r0}
        ld   r1, r0
        ; and t.2{r1}, t.2{r1}, 4
        and  r1, #%04
        ; notequals t.1{r0}, t.2{r1}, 0
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
        ; call t.4{r0} = rowColumnToCell@u8@u8[param.row{r0}, param.column{r1}] -> i16
        call rowColumnToCell_Pu8_Pu8
        ; addrof t.3{r2}, [field]
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.3{r2}, t.3{r2}, t.4{r0}
        add  r3, r1
        adc  r2, r0
        ; store [t.3{r2}], param.cell{r8}
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
        ; move rowFrom{r10}, param.row{r8}
        ld   r10, r8
        ; 43:2 if rowFrom > 0
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
        ; 47:2 if rowTo >= 20
        ; branch rowTo{r11} lt 20: if_2_end, if_2_then
        cp   r11, #%14
        jr   ult, if__2__end
        ; sub rowTo{r11}, rowTo{r11}, 1
        dec  r11
if__2__end:
        ; move colFrom{r12}, param.column{r9}
        ld   r12, r9
        ; 52:2 if colFrom > 0
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
        ; 56:2 if colTo >= 17
        ; branch colTo{r13} lt 17: if_4_end, if_4_then
        cp   r13, #%11
        jr   ult, if__4__end
        ; sub colTo{r13}, colTo{r13}, 1
        dec  r13
if__4__end:
        ; const count{r14}, 0
        ld   r14, #%00
        ; 61:2 for r <= rowTo
        jr   for__5

for__5__body:
        ; move c{r15}, colFrom{r12}
        ld   r15, r12
        ; 62:3 for c <= colTo
        jr   for__6

for__6__body:
        ; branch r{r10} notequals param.row{r8}: if_7_end, and_8
        cp   r10, r8
        jr   ne, if__7__end
        ; branch c{r15} equals param.column{r9}: for_6_continue, if_7_end
        cp   r15, r9
        jr   eq, for__6__continue
if__7__end:
        ; move r{r0}, r{r10}
        ld   r0, r10
        ; move c{r1}, c{r15}
        ld   r1, r15
        ; call cell{r0} = getCell@u8@u8[r{r0}, c{r1}] -> u8
        call getCell_Pu8_Pu8
        ; 67:4 if isBomb@u8([ExprVarAccess[varName=cell, index=9, scope=function, type=u8, varIsArray=false, location=67:14]])
        ; call t.10{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.10{r0} equals 0: for_6_continue, if_9_then
        cp   r0, #%00
        jr   eq, for__6__continue
        ; add count{r14}, count{r14}, 1
        inc  r14
for__6__continue:
        ; add c{r15}, c{r15}, 1
        inc  r15
for__6:
        ; branch c{r15} lteq colTo{r13}: for_6_body, for_5_continue
        cp   r15, r13
        jr   ule, for__6__body
        ; add r{r10}, r{r10}, 1
        inc  r10
for__5:
        ; branch r{r10} lteq rowTo{r11}: for_5_body, for_5_break
        cp   r10, r11
        jr   ule, for__5__body
        ; 72:9 return count
        ; move count{r0}, count{r14}
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
        ; cast c{r2}(i16), param.column{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; 77:17 return c + 1 << 1
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
        ; move param.row{r8}, row{r0}
        ld   r8, r0
        ; move param.column{r9}, column{r1}
        ld   r9, r1
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call cell{r0} = getCell@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move param.row{r1}, param.row{r8}
        ld   r1, r8
        ; move param.column{r2}, param.column{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell{r0}, param.row{r1}, param.column{r2}]
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
        push r10
        push r11
        ; move param.cell{r8}, cell{r0}
        ld   r8, r0
        ; move param.row{r9}, row{r1}
        ld   r9, r1
        ; move param.column{r10}, column{r2}
        ld   r10, r2
        ; const chr{r11}, 46
        ld   r11, #%2e
        ; 93:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=93:13]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.5{r0} = isOpen@u8[param.cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.5{r0} notequals 0: if_10_then, if_10_else
        cp   r0, #%00
        jr   ne, if__10__then
        ; 107:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=107:18]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.7{r0} = isFlag@u8[param.cell{r0}] -> bool
        call isFlag_Pu8
        ; branch t.7{r0} equals 0: if_10_end, if_13_then
        cp   r0, #%00
        jr   eq, if__10__end
        jr   if__13__then

if__10__then:
        ; 94:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=94:14]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.6{r0} = isBomb@u8[param.cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.6{r0} equals 0: if_11_else, if_11_then
        cp   r0, #%00
        jr   eq, if__11__else
        jr   if__11__then

if__13__then:
        ; const chr{r11}, 35
        ld   r11, #%23
        jr   if__10__end

if__11__else:
        ; move param.row{r0}, param.row{r9}
        ld   r0, r9
        ; move param.column{r1}, param.column{r10}
        ld   r1, r10
        ; call count{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; 99:4 if count > 0
        ; branch count{r0} lteq 0: if_12_else, if_12_then
        cp   r0, #%00
        jr   ule, if__12__else
        jr   if__12__then

if__11__then:
        ; const chr{r11}, 42
        ld   r11, #%2a
        jr   if__10__end

if__12__else:
        ; const chr{r11}, 32
        ld   r11, #%20
        jr   if__10__end

if__12__then:
        ; move chr{r11}, count{r0}
        ld   r11, r0
        ; add chr{r11}, chr{r11}, 48
        add  r11, #%30
if__10__end:
        ; move chr{r0}, chr{r11}
        ld   r0, r11
        ; call printChar@u8[chr{r0}]
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
        ; const row{r8}, 0
        ld   r8, #%00
        ; 115:2 for row < 20
        jr   for__14

for__14__body:
        ; const arg.1.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
        ; const column{r9}, 0
        ld   r9, #%00
        ; 117:3 for column < 17
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
        ; call cell{r0} = getCell@u8@u8[row{r0}, column{r1}] -> u8
        call getCell_Pu8_Pu8
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
        ; const t.3{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.3{r0}]
        call printString_P_Pu8
        ; add row{r8}, row{r8}, 1
        inc  r8
for__14:
        ; branch row{r8} lt 20: for_14_body, printField_ret
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
        ; 130:2 if show
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
        ; 136:2 if show
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
        ; 143:2 for i > 0
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
        ; const count{r2}, 0
        ld   r2, #%00
        ; 150:2 if value < 0
        ; branch param.value{r0} gteq 0: while_20, if_19_then
        cp   r0, #%00
        jr   gt, while__20
        jr   ne, .gt5
        cp   r1, #%00
        jr   uge, while__20
.gt5:
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
        ; 158:3 if value == 0
        ; branch param.value{r0} notequals 0: while_20, while_20_break
        cp   r1, #%00
        jr   ne, while__20
        cp   r0, #%00
        jr   ne, while__20
        ; 163:9 return count
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
        ; 168:2 for r < 20
        jr   for__22

for__22__body:
        ; const c{r11}, 0
        ld   r11, #%00
        ; 169:3 for c < 17
        jr   for__23

for__23__body:
        ; move r{r0}, r{r10}
        ld   r0, r10
        ; move c{r1}, c{r11}
        ld   r1, r11
        ; call cell{r0} = getCell@u8@u8[r{r0}, c{r1}] -> u8
        call getCell_Pu8_Pu8
        ; 171:4 if cell & 6 == 0
        ; move t.4{r2}, cell{r0}
        ld   r2, r0
        ; and t.4{r2}, t.4{r2}, 6
        and  r2, #%06
        ; branch t.4{r2} notequals 0: for_23_continue, if_24_then
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
        ; 176:9 return count
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
        ; const arg.2.0{r0}, 17
        ld   r0, #%00
        ld   r1, #%11
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
        ; 187:15 return count == 0
        ; equals t.6{r0}, count{r8}, 0
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
        ; 191:2 if a < 0
        ; branch param.a{r2} lt 0: if_25_then, if_25_end
        cp   r2, #%00
        jr   lt, if__25__then
        jr   ne, .lt7
        cp   r3, #%00
        jr   ult, if__25__then
.lt7:
        ; 194:9 return a
        ; move param.a{r0}, param.a{r2}
        ld   r0, r2
        ld   r1, r3
        jr   abs_Pi16__ret

if__25__then:
        ; 192:10 return -a
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
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const r{r8}, 0
        ld   r8, #%00
        ; 198:2 for r < 20
        jr   for__26

for__26__body:
        ; const c{r9}, 0
        ld   r9, #%00
        ; 199:3 for c < 17
        jr   for__27

for__27__body:
        ; move r{r0}, r{r8}
        ld   r0, r8
        ; move c{r1}, c{r9}
        ld   r1, r9
        ; const arg.0.2{r2}, 0
        ld   r2, #%00
        ; call setCell@u8@u8@u8[r{r0}, c{r1}, arg.0.2{r2}]
        call setCell_Pu8_Pu8_Pu8
        ; add c{r9}, c{r9}, 1
        inc  r9
for__27:
        ; branch c{r9} lt 17: for_27_body, for_26_continue
        cp   r9, #%11
        jr   ult, for__27__body
        ; add r{r8}, r{r8}, 1
        inc  r8
for__26:
        ; branch r{r8} lt 20: for_26_body, clearField_ret
        cp   r8, #%14
        jr   ult, for__26__body
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void initField@u8@u8
        ; arg curr_r (u8): r0
        ; arg curr_c (u8): r1
        ; var row (i16): SP+8
        ; var column (i16): SP+10
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
        ; cast r{r8}(i16), param.curr_r{r0}(u8)
        ld   r9, r0
        ld   r8, #0
        ; cast c{r10}(i16), param.curr_c{r1}(u8)
        ld   r11, r1
        ld   r10, #0
        ; const bombs{r12}, 17
        ld   r12, #%00
        ld   r13, #%11
        ; 208:2 for bombs > 0
        jr   for__28

for__28__body:
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
        ; 211:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=5, scope=function, type=i16, varIsArray=false, location=211:11], right=ExprVarAccess[varName=r, index=2, scope=function, type=i16, varIsArray=false, location=211:20], location=211:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=6, scope=function, type=i16, varIsArray=false, location=212:11], right=ExprVarAccess[varName=c, index=3, scope=function, type=i16, varIsArray=false, location=212:20], location=212:18]]) > 1
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
        ; branch t.9{r0} gt 1: if_29_then, or_30
        cp   r0, #%00
        jr   gt, if__29__then
        jr   ne, .gt8
        cp   r1, #%01
        jr   ugt, if__29__then
.gt8:
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
        ; branch t.11{r0} lteq 1: for_28_continue, if_29_then
        cp   r0, #%00
        jr   lt, for__28__continue
        jr   ne, .lt9
        cp   r1, #%01
        jr   ule, for__28__continue
.lt9:
if__29__then:
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        incw r14
        lde  r4, @rr14
        decw r14
        ; cast t.13{r0}(u8), row{r3}(i16)
        ld   r0, r4
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        incw r14
        lde  r4, @rr14
        decw r14
        ; cast t.14{r1}(u8), column{r3}(i16)
        ld   r1, r4
        ; const arg.4.2{r2}, 1
        ld   r2, #%01
        ; call setCell@u8@u8@u8[t.13{r0}, t.14{r1}, arg.4.2{r2}]
        call setCell_Pu8_Pu8_Pu8
for__28__continue:
        ; sub bombs{r12}, bombs{r12}, 1
        decw r12
for__28:
        ; branch bombs{r12} gt 0: for_28_body, initField@u8@u8_ret
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
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call printCellAt@u8@u8[param.row{r0}, param.column{r1}]
        call printCellAt_Pu8_Pu8
        ; 220:2 if getBombCountAround@u8@u8([ExprVarAccess[varName=row, index=0, scope=parameter, type=u8, varIsArray=false, location=220:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=u8, varIsArray=false, location=220:30]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ; move param.column{r1}, param.column{r9}
        ld   r1, r9
        ; call t.9{r0} = getBombCountAround@u8@u8[param.row{r0}, param.column{r1}] -> u8
        call getBombCountAround_Pu8_Pu8
        ; branch t.9{r0} notequals 0: maybeRevealAround@u8@u8_ret, if_31_end
        cp   r0, #%00
        jr   ne, maybeRevealAround_Pu8_Pu8__ret
        ; move rowFrom{r10}, param.row{r8}
        ld   r10, r8
        ; 225:2 if rowFrom > 0
        ; branch rowFrom{r10} lteq 0: if_32_end, if_32_then
        cp   r10, #%00
        jr   ule, if__32__end
        ; move rowFrom{r10}, param.row{r8}
        ld   r10, r8
        ; sub rowFrom{r10}, rowFrom{r10}, 1
        dec  r10
if__32__end:
        ; move rowTo{r11}, param.row{r8}
        ld   r11, r8
        ; add rowTo{r11}, rowTo{r11}, 1
        inc  r11
        ; 229:2 if rowTo >= 20
        ; branch rowTo{r11} lt 20: if_33_end, if_33_then
        cp   r11, #%14
        jr   ult, if__33__end
        ; sub rowTo{r11}, rowTo{r11}, 1
        dec  r11
if__33__end:
        ; move colFrom{r12}, param.column{r9}
        ld   r12, r9
        ; 234:2 if colFrom > 0
        ; branch colFrom{r12} lteq 0: if_34_end, if_34_then
        cp   r12, #%00
        jr   ule, if__34__end
        ; sub colFrom{r12}, colFrom{r12}, 1
        dec  r12
if__34__end:
        ; move colTo{r13}, param.column{r9}
        ld   r13, r9
        ; add colTo{r13}, colTo{r13}, 1
        inc  r13
        ; 238:2 if colTo >= 17
        ; branch colTo{r13} lt 17: if_35_end, if_35_then
        cp   r13, #%11
        jr   ult, if__35__end
        ; sub colTo{r13}, colTo{r13}, 1
        dec  r13
if__35__end:
        ; 241:2 for r <= rowTo
        jr   for__36

for__36__body:
        ; move c{r14}, colFrom{r12}
        ld   r14, r12
        ; 242:3 for c <= colTo
        jr   for__37

for__37__body:
        ; branch r{r10} notequals param.row{r8}: if_38_end, and_39
        cp   r10, r8
        jr   ne, if__38__end
        ; branch c{r14} equals param.column{r9}: for_37_continue, if_38_end
        cp   r14, r9
        jr   eq, for__37__continue
if__38__end:
        ; move r{r0}, r{r10}
        ld   r0, r10
        ; move c{r1}, c{r14}
        ld   r1, r14
        ; call cell{r0} = getCell@u8@u8[r{r0}, c{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move cell{r15}, cell{r0}
        ld   r15, r0
        ; 248:4 if isOpen@u8([ExprVarAccess[varName=cell, index=8, scope=function, type=u8, varIsArray=false, location=248:15]])
        ; move cell{r0}, cell{r15}
        ld   r0, r15
        ; call t.10{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.10{r0} notequals 0: for_37_continue, if_40_end
        cp   r0, #%00
        jr   ne, for__37__continue
        ; move t.11{r2}, cell{r15}
        ld   r2, r15
        ; or t.11{r2}, t.11{r2}, 2
        or  r2, #%02
        ; move r{r0}, r{r10}
        ld   r0, r10
        ; move c{r1}, c{r14}
        ld   r1, r14
        ; call setCell@u8@u8@u8[r{r0}, c{r1}, t.11{r2}]
        call setCell_Pu8_Pu8_Pu8
        ; move r{r0}, r{r10}
        ld   r0, r10
        ; move c{r1}, c{r14}
        ld   r1, r14
        ; call maybeRevealAround@u8@u8[r{r0}, c{r1}]
        call maybeRevealAround_Pu8_Pu8
for__37__continue:
        ; add c{r14}, c{r14}, 1
        inc  r14
for__37:
        ; branch c{r14} lteq colTo{r13}: for_37_body, for_36_continue
        cp   r14, r13
        jr   ule, for__37__body
        ; add r{r10}, r{r10}, 1
        inc  r10
for__36:
        ; branch r{r10} lteq rowTo{r11}: for_36_body, maybeRevealAround@u8@u8_ret
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
        ; const t.6{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.6{r0}]
        call printString_P_Pu8
        ; const curr_c{r9}, 8
        ld   r9, #%08
        ; const curr_r{r10}, 10
        ld   r10, #%0a
        ; 267:2 while true
        jr   while__41

if__42__then:
        ; 269:4 if printLeft([])
        ; call t.7{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.7{r0} notequals 0: if_43_then, if_42_end
        cp   r0, #%00
        jr   ne, if__43__then
if__42__end:
        ; const t.9{r2}, 1
        ld   r2, #%01
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r{r0}, curr_c{r1}, t.9{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; call chr{r0} = getChar[] -> i16
        call getChar
        ; move chr{r11}, chr{r0}
        ld   r12, r1
        ld   r11, r0
        ; const t.10{r2}, 0
        ld   r2, #%00
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call showCursor@u8@u8@bool[curr_r{r0}, curr_c{r1}, t.10{r2}]
        call showCursor_Pu8_Pu8_Pbool
        ; 278:3 if chr == 27
        ; branch chr{r11} equals 27: main_ret, if_44_end
        cp   r12, #%1b
        jr   ne, .notEquals11
        cp   r11, #%00
        jr   eq, main__ret
.notEquals11:
        ; branch chr{r11} equals 13: if_45_then, if_45_else
        cp   r12, #%0d
        jr   ne, .notEquals12
        cp   r11, #%00
        jr   eq, if__45__then
.notEquals12:
        ; branch chr{r11} notequals 3: if_49_else, if_49_then
        cp   r12, #%03
        jr   ne, if__49__else
        cp   r11, #%00
        jr   ne, if__49__else
        jr   if__49__then

if__45__then:
        ; branch needsInitialize{r8} equals 0: if_46_end, if_46_then
        cp   r8, #%00
        jr   eq, if__46__end
        jr   if__46__then

if__49__else:
        ; branch chr{r11} notequals 4: if_51_else, if_51_then
        cp   r12, #%04
        jr   ne, if__51__else
        cp   r11, #%00
        jr   ne, if__51__else
        jr   if__51__then

if__49__then:
        ; branch curr_r{r10} lteq 0: while_41, if_50_then
        cp   r10, #%00
        jr   ule, while__41
        jr   if__50__then

if__46__then:
        ; const needsInitialize{r8}, 0
        ld   r8, #%00
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call initField@u8@u8[curr_r{r0}, curr_c{r1}]
        call initField_Pu8_Pu8
        jr   if__46__end

if__51__else:
        ; branch chr{r11} notequals 1: if_53_else, if_53_then
        cp   r12, #%01
        jr   ne, if__53__else
        cp   r11, #%00
        jr   ne, if__53__else
        jr   if__53__then

if__51__then:
        ; branch curr_r{r10} gteq 19: while_41, if_52_then
        cp   r10, #%13
        jr   uge, while__41
        jr   if__52__then

if__50__then:
        ; sub curr_r{r10}, curr_r{r10}, 1
        dec  r10
        jr   while__41

if__46__end:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call cell{r0} = getCell@u8@u8[curr_r{r0}, curr_c{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move cell{r11}, cell{r0}
        ld   r11, r0
        ; 288:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=288:16]])
        ; move cell{r0}, cell{r11}
        ld   r0, r11
        ; call t.11{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.11{r0} notequals 0: if_47_end, if_47_then
        cp   r0, #%00
        jr   ne, if__47__end
        jr   if__47__then

if__53__else:
        ; branch chr{r11} notequals 2: if_55_else, if_55_then
        cp   r12, #%02
        jr   ne, if__55__else
        cp   r11, #%00
        jr   ne, if__55__else
        jr   if__55__then

if__53__then:
        ; branch curr_c{r9} lteq 0: while_41, if_54_then
        cp   r9, #%00
        jr   ule, while__41
        jr   if__54__then

if__52__then:
        ; add curr_r{r10}, curr_r{r10}, 1
        inc  r10
        jr   while__41

if__47__then:
        ; move t.12{r2}, cell{r11}
        ld   r2, r11
        ; or t.12{r2}, t.12{r2}, 2
        or  r2, #%02
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call setCell@u8@u8@u8[curr_r{r0}, curr_c{r1}, t.12{r2}]
        call setCell_Pu8_Pu8_Pu8
        jr   if__47__end

if__55__else:
        ; branch chr{r11} notequals 32: while_41, if_57_then
        cp   r12, #%20
        jr   ne, while__41
        cp   r11, #%00
        jr   ne, while__41
        jr   if__57__then

if__55__then:
        ; branch curr_c{r9} gteq 16: while_41, if_56_then
        cp   r9, #%10
        jr   uge, while__41
        jr   if__56__then

if__54__then:
        ; sub curr_c{r9}, curr_c{r9}, 1
        dec  r9
        jr   while__41

if__47__end:
        ; 291:4 if isBomb@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=291:15]])
        ; move cell{r0}, cell{r11}
        ld   r0, r11
        ; call t.13{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.13{r0} equals 0: if_48_end, if_48_then
        cp   r0, #%00
        jr   eq, if__48__end
        jr   if__48__then

if__57__then:
        ; branch needsInitialize{r8} notequals 0: while_41, if_58_then
        cp   r8, #%00
        jr   ne, while__41
        jr   if__58__then

if__56__then:
        ; add curr_c{r9}, curr_c{r9}, 1
        inc  r9
        jr   while__41

if__48__end:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call maybeRevealAround@u8@u8[curr_r{r0}, curr_c{r1}]
        call maybeRevealAround_Pu8_Pu8
        jr   while__41

if__58__then:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call cell{r0} = getCell@u8@u8[curr_r{r0}, curr_c{r1}] -> u8
        call getCell_Pu8_Pu8
        ; move cell{r11}, cell{r0}
        ld   r11, r0
        ; 326:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=326:17]])
        ; move cell{r0}, cell{r11}
        ld   r0, r11
        ; call t.15{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.15{r0} notequals 0: while_41, if_59_then
        cp   r0, #%00
        jr   ne, while__41
        ; xor cell{r11}, cell{r11}, 4
        xor r11, #%04
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; move cell{r2}, cell{r11}
        ld   r2, r11
        ; call setCell@u8@u8@u8[curr_r{r0}, curr_c{r1}, cell{r2}]
        call setCell_Pu8_Pu8_Pu8
        ; move cell{r0}, cell{r11}
        ld   r0, r11
        ; move curr_r{r1}, curr_r{r10}
        ld   r1, r10
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ; call printCellAt@u8@u8@u8[cell{r0}, curr_r{r1}, curr_c{r2}]
        call printCellAt_Pu8_Pu8_Pu8
while__41:
        ; branch needsInitialize{r8} notequals 0: if_42_end, if_42_then
        cp   r8, #%00
        jr   ne, if__42__end
        jr   if__42__then

if__43__then:
        ; const t.8{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.8{r0}]
        call printString_P_Pu8
        jr   main__ret

if__48__then:
        ; move curr_r{r0}, curr_r{r10}
        ld   r0, r10
        ; move curr_c{r1}, curr_c{r9}
        ld   r1, r9
        ; call printCellAt@u8@u8[curr_r{r0}, curr_c{r1}]
        call printCellAt_Pu8_Pu8
        ; const t.14{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.14{r0}]
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

