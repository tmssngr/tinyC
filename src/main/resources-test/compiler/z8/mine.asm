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

        ; i16 rowColumnToCell@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
rowColumnToCell_Pi16_Pi16:
        ; 16:21 return row * 40 + column
        ; move t.3{r4}, param.row{r0}
        ld   r5, r1
        ld   r4, r0
        ; mul t.3{r4}, t.3{r4}, 40
        ld   %12, r4
        ld   %13, r5
        ld   %14, #%00
        ld   %15, #%28
        srp  #%10
        call %00BA ; mul
        srp  #%20
        ld   r4, %12
        ld   r5, %13
        ; move t.2{r0}, t.3{r4}
        ld   r0, r4
        ld   r1, r5
        ; add t.2{r0}, t.2{r0}, param.column{r2}
        add  r1, r3
        adc  r0, r2
        ret

        ; u8 getCell@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
getCell_Pi16_Pi16:
        ; 20:15 return [...]
        ; call t.4{r0} = rowColumnToCell@i16@i16[param.row{r0}, param.column{r2}] -> i16
        call rowColumnToCell_Pi16_Pi16
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
        ; 24:27 return cell & 1 != 0
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
        ; 28:27 return cell & 2 != 0
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
        ; 32:27 return cell & 4 != 0
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

        ; bool checkCellBounds@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
checkCellBounds_Pi16_Pi16:
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 36:40 logic and
        ; 36:21 logic and
        ; gteq t.2{r4}, param.row{r0}, 0
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
        ; branch t.2{r4} equals 0: and_next_3, and_2nd_3
        cp   r4, #%00
        jr   eq, and__next__3
        ; lt t.2{r4}, param.row{r0}, 20
        cp   r0, #%00
        jr   lt, .true5
        jr   ne, .false5
        cp   r1, #%14
        jr   ult, .true5
.false5:
        ld   r4, #0
        jr   .5
.true5:
        ld   r4, #1
.5:
and__next__3:
        ; branch t.2{r4} equals 0: and_next_2, and_2nd_2
        cp   r4, #%00
        jr   eq, and__next__2
        ; gteq t.2{r4}, param.column{r2}, 0
        cp   r2, #%00
        jr   gt, .true6
        jr   ne, .false6
        cp   r3, #%00
        jr   uge, .true6
.false6:
        ld   r4, #0
        jr   .6
.true6:
        ld   r4, #1
.6:
and__next__2:
        ; branch t.2{r4} equals 0: and_next_1, and_2nd_1
        cp   r4, #%00
        jr   eq, and__next__1
        ; lt t.2{r4}, param.column{r2}, 40
        cp   r2, #%00
        jr   lt, .true7
        jr   ne, .false7
        cp   r3, #%28
        jr   ult, .true7
.false7:
        ld   r4, #0
        jr   .7
.true7:
        ld   r4, #1
.7:
and__next__1:
        ; move t.2{r0}, t.2{r4}
        ld   r0, r4
        ret

        ; void setCell@i16@i16@u8
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; arg cell (u8): r4
setCell_Pi16_Pi16_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; move param.cell{r8}, cell{r4}
        ld   r8, r4
        ; call t.4{r0} = rowColumnToCell@i16@i16[param.row{r0}, param.column{r2}] -> i16
        call rowColumnToCell_Pi16_Pi16
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

        ; u8 getBombCountAround@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; var dr (i16): SP+8
        ; var r (i16): SP+10
        ; var dc (i16): SP+12
        ; var c (i16): SP+14
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
        ; const count{r12}, 0
        ld   r12, #%00
        ; const dr{r4}, -1
        ld   r4, #%ff
        ld   r5, #%ff
        ; 46:2 for dr <= 1
        ; move dr{r1}, dr{r4}
        ld   r1, r4
        ld   r2, r5
        jr   for__4

for__4__body:
        ; move dr{r4}, dr{r1}
        ld   r5, r2
        ld   r4, r1
        ; move r{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; add r{r0}, r{r0}, dr{r4}
        add  r1, r5
        adc  r0, r4
        ; addrof memVarAddr{r14}, dr
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], dr{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        ; const dc{r4}, -1
        ld   r4, #%ff
        ld   r5, #%ff
        ; 48:3 for dc <= 1
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; move dc{r1}, dc{r4}
        ld   r1, r4
        ld   r2, r5
        jr   for__5

for__5__body:
        ; move dc{r4}, dc{r1}
        ld   r5, r2
        ld   r4, r1
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load r{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; move c{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; add c{r2}, c{r2}, dc{r4}
        add  r3, r5
        adc  r2, r4
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], dc{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], c{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; call t.8{r0} = checkCellBounds@i16@i16[r{r0}, c{r2}] -> bool
        call checkCellBounds_Pi16_Pi16
        ; branch t.8{r0} equals 0: for_5_continue, if_6_then
        cp   r0, #%00
        jr   eq, for__5__continue
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load r{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load c{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; call cell{r0} = getCell@i16@i16[r{r0}, c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; call t.9{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.9{r0} equals 0: for_5_continue, if_7_then
        cp   r0, #%00
        jr   eq, for__5__continue
        ; add count{r12}, count{r12}, 1
        inc  r12
for__5__continue:
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load dc{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        incw r14
        lde  r2, @rr14
        ; add dc{r1}, dc{r1}, 1
        add  r2, #%01
        adc  r1, #%00
for__5:
        ; branch dc{r1} lteq 1: for_5_body, for_4_continue
        cp   r1, #%00
        jr   lt, for__5__body
        jr   ne, .lt8
        cp   r2, #%01
        jr   ule, for__5__body
.lt8:
        ; addrof memVarAddr{r14}, dr
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load dr{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        incw r14
        lde  r2, @rr14
        ; add dr{r1}, dr{r1}, 1
        add  r2, #%01
        adc  r1, #%00
for__4:
        ; branch dr{r1} lteq 1: for_4_body, for_4_break
        cp   r1, #%00
        jr   lt, for__4__body
        jr   ne, .lt9
        cp   r2, #%01
        jr   ule, for__4__body
.lt9:
        ; 58:9 return count
        ; move count{r0}, count{r12}
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

        ; u8 getSpacer@i16@i16@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; arg rowCursor (i16): r4
        ; arg columnCursor (i16): r6
getSpacer_Pi16_Pi16_Pi16_Pi16:
        ; 62:2 if rowCursor == row
        ; branch param.rowCursor{r4} notequals param.row{r0}: if_8_end, if_8_then
        cp   r5, r1
        jr   ne, if__8__end
        cp   r4, r0
        jr   ne, if__8__end
        ; branch param.columnCursor{r6} equals param.column{r2}: if_9_then, if_9_end
        cp   r7, r3
        jr   ne, .notEquals10
        cp   r6, r2
        jr   eq, if__9__then
.notEquals10:
        ; 66:3 if columnCursor == column - 1
        ; move t.5{r1}, param.column{r2}
        ld   r1, r2
        ld   r2, r3
        ; sub t.5{r1}, t.5{r1}, 1
        sub  r2, #%01
        sbc  r1, #%00
        ; branch param.columnCursor{r6} notequals t.5{r1}: if_8_end, if_10_then
        cp   r7, r2
        jr   ne, if__8__end
        cp   r6, r1
        jr   ne, if__8__end
        jr   if__10__then

if__9__then:
        ; 64:11 return 91
        ; const t.4{r0}, 91
        ld   r0, #%5b
        jr   getSpacer_Pi16_Pi16_Pi16_Pi16__ret

if__10__then:
        ; 67:11 return 93
        ; const t.6{r1}, 93
        ld   r1, #%5d
        ; move t.6{r0}, t.6{r1}
        ld   r0, r1
        jr   getSpacer_Pi16_Pi16_Pi16_Pi16__ret

if__8__end:
        ; 70:9 return 32
        ; const t.7{r1}, 32
        ld   r1, #%20
        ; move t.7{r0}, t.7{r1}
        ld   r0, r1
getSpacer_Pi16_Pi16_Pi16_Pi16__ret:
        ret

        ; void printCell@u8@i16@i16
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
        ; const chr{r13}, 46
        ld   r13, #%2e
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.5{r0} = isOpen@u8[param.cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.5{r0} notequals 0: if_11_then, if_11_else
        cp   r0, #%00
        jr   ne, if__11__then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.7{r0} = isFlag@u8[param.cell{r0}] -> bool
        call isFlag_Pu8
        ; branch t.7{r0} equals 0: if_11_end, if_14_then
        cp   r0, #%00
        jr   eq, if__11__end
        jr   if__14__then

if__11__then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.6{r0} = isBomb@u8[param.cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.6{r0} equals 0: if_12_else, if_12_then
        cp   r0, #%00
        jr   eq, if__12__else
        jr   if__12__then

if__14__then:
        ; const chr{r13}, 35
        ld   r13, #%23
        jr   if__11__end

if__12__else:
        ; move param.row{r0}, param.row{r9}
        ld   r0, r9
        ld   r1, r10
        ; move param.column{r2}, param.column{r11}
        ld   r2, r11
        ld   r3, r12
        ; call count{r0} = getBombCountAround@i16@i16[param.row{r0}, param.column{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; 81:4 if count > 0
        ; branch count{r0} lteq 0: if_13_else, if_13_then
        cp   r0, #%00
        jr   ule, if__13__else
        jr   if__13__then

if__12__then:
        ; const chr{r13}, 42
        ld   r13, #%2a
        jr   if__11__end

if__13__else:
        ; const chr{r13}, 32
        ld   r13, #%20
        jr   if__11__end

if__13__then:
        ; move chr{r13}, count{r0}
        ld   r13, r0
        ; add chr{r13}, chr{r13}, 48
        add  r13, #%30
if__11__end:
        ; move chr{r0}, chr{r13}
        ld   r0, r13
        ; call printChar@u8[chr{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void printField@i16@i16
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
        ; call setCursor@i16@i16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const row{r12}, 0
        ld   r12, #%00
        ld   r13, #%00
        ; 97:2 for row < 20
        jr   for__15

for__15__body:
        ; const arg.1.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
        ; const column{r14}, 0
        ld   r14, #%00
        ld   r15, #%00
        ; 99:3 for column < 40
        jr   for__16

for__16__body:
        ; move row{r0}, row{r12}
        ld   r0, r12
        ld   r1, r13
        ; move column{r2}, column{r14}
        ld   r2, r14
        ld   r3, r15
        ; move param.rowCursor{r4}, param.rowCursor{r8}
        ld   r4, r8
        ld   r5, r9
        ; move param.columnCursor{r6}, param.columnCursor{r10}
        ld   r6, r10
        ld   r7, r11
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r0}, column{r2}, param.rowCursor{r4}, param.columnCursor{r6}] -> u8
        call getSpacer_Pi16_Pi16_Pi16_Pi16
        ; call printChar@u8[spacer{r0}]
        call printChar_Pu8
        ; move row{r0}, row{r12}
        ld   r0, r12
        ld   r1, r13
        ; move column{r2}, column{r14}
        ld   r2, r14
        ld   r3, r15
        ; call cell{r0} = getCell@i16@i16[row{r0}, column{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move row{r1}, row{r12}
        ld   r1, r12
        ld   r2, r13
        ; move column{r3}, column{r14}
        ld   r3, r14
        ld   r4, r15
        ; call printCell@u8@i16@i16[cell{r0}, row{r1}, column{r3}]
        call printCell_Pu8_Pi16_Pi16
        ; add column{r14}, column{r14}, 1
        incw r14
for__16:
        ; branch column{r14} lt 40: for_16_body, for_16_break
        cp   r14, #%00
        jr   lt, for__16__body
        jr   ne, .lt11
        cp   r15, #%28
        jr   ult, for__16__body
.lt11:
        ; move row{r0}, row{r12}
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
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r0}, arg.6.1{r2}, param.rowCursor{r4}, param.columnCursor{r6}] -> u8
        call getSpacer_Pi16_Pi16_Pi16_Pi16
        ; call printChar@u8[spacer{r0}]
        call printChar_Pu8
        ; const t.7{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.7{r0}]
        call printString_P_Pu8
        ; add row{r12}, row{r12}, 1
        incw r12
for__15:
        ; branch row{r12} lt 20: for_15_body, printField@i16@i16_ret
        cp   r12, #%00
        jr   lt, for__15__body
        jr   ne, .lt12
        cp   r13, #%14
        jr   ult, for__15__body
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

        ; void printSpaces@i16
        ; arg i (i16): r0
printSpaces_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.i{r8}, i{r0}
        ld   r9, r1
        ld   r8, r0
        ; 112:2 for i > 0
        jr   for__17

for__17__body:
        ; const arg.0.0{r0}, 48
        ld   r0, #%30
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; sub param.i{r8}, param.i{r8}, 1
        decw r8
for__17:
        ; branch param.i{r8} gt 0: for_17_body, printSpaces@i16_ret
        cp   r8, #%00
        jr   gt, for__17__body
        jr   ne, .gt13
        cp   r9, #%00
        jr   ugt, for__17__body
.gt13:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; u8 getDigitCount@i16
        ; arg value (i16): r0
getDigitCount_Pi16:
        ; const count{r2}, 0
        ld   r2, #%00
        ; 119:2 if value < 0
        ; branch param.value{r0} gteq 0: while_19, if_18_then
        cp   r0, #%00
        jr   gt, while__19
        jr   ne, .gt14
        cp   r1, #%00
        jr   uge, while__19
.gt14:
        ; const count{r2}, 1
        ld   r2, #%01
        ; neg param.value{r0}, param.value{r0}
        com  r0
        com  r1
        incw r0
while__19:
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
        ; 127:3 if value == 0
        ; branch param.value{r0} notequals 0: while_19, while_19_break
        cp   r1, #%00
        jr   ne, while__19
        cp   r0, #%00
        jr   ne, while__19
        ; 132:9 return count
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
        push r12
        push r13
        ; const count{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; const r{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; 137:2 for r < 20
        jr   for__21

for__21__body:
        ; const c{r12}, 0
        ld   r12, #%00
        ld   r13, #%00
        ; 138:3 for c < 40
        jr   for__22

for__22__body:
        ; move r{r0}, r{r10}
        ld   r0, r10
        ld   r1, r11
        ; move c{r2}, c{r12}
        ld   r2, r12
        ld   r3, r13
        ; call cell{r0} = getCell@i16@i16[r{r0}, c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; 140:4 if cell & 6 == 0
        ; move t.4{r2}, cell{r0}
        ld   r2, r0
        ; and t.4{r2}, t.4{r2}, 6
        and  r2, #%06
        ; branch t.4{r2} notequals 0: for_22_continue, if_23_then
        cp   r2, #%00
        jr   ne, for__22__continue
        ; add count{r8}, count{r8}, 1
        incw r8
for__22__continue:
        ; add c{r12}, c{r12}, 1
        incw r12
for__22:
        ; branch c{r12} lt 40: for_22_body, for_21_continue
        cp   r12, #%00
        jr   lt, for__22__body
        jr   ne, .lt15
        cp   r13, #%28
        jr   ult, for__22__body
.lt15:
        ; add r{r10}, r{r10}, 1
        incw r10
for__21:
        ; branch r{r10} lt 20: for_21_body, for_21_break
        cp   r10, #%00
        jr   lt, for__21__body
        jr   ne, .lt16
        cp   r11, #%14
        jr   ult, for__21__body
.lt16:
        ; 145:9 return count
        ; move count{r0}, count{r8}
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
        ; const arg.2.0{r0}, 40
        ld   r0, #%00
        ld   r1, #%28
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
        ; 156:15 return count == 0
        ; equals t.6{r0}, count{r8}, 0
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

        ; i16 abs@i16
        ; arg a (i16): r0
abs_Pi16:
        ; move param.a{r2}, a{r0}
        ld   r3, r1
        ld   r2, r0
        ; 160:2 if a < 0
        ; branch param.a{r2} lt 0: if_24_then, if_24_end
        cp   r2, #%00
        jr   lt, if__24__then
        jr   ne, .lt18
        cp   r3, #%00
        jr   ult, if__24__then
.lt18:
        ; 163:9 return a
        ; move param.a{r0}, param.a{r2}
        ld   r0, r2
        ld   r1, r3
        jr   abs_Pi16__ret

if__24__then:
        ; 161:10 return -a
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
        push r10
        push r11
        ; const r{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; 167:2 for r < 20
        jr   for__25

for__25__body:
        ; const c{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; 168:3 for c < 40
        jr   for__26

for__26__body:
        ; move r{r0}, r{r8}
        ld   r0, r8
        ld   r1, r9
        ; move c{r2}, c{r10}
        ld   r2, r10
        ld   r3, r11
        ; const arg.0.2{r4}, 0
        ld   r4, #%00
        ; call setCell@i16@i16@u8[r{r0}, c{r2}, arg.0.2{r4}]
        call setCell_Pi16_Pi16_Pu8
        ; add c{r10}, c{r10}, 1
        incw r10
for__26:
        ; branch c{r10} lt 40: for_26_body, for_25_continue
        cp   r10, #%00
        jr   lt, for__26__body
        jr   ne, .lt19
        cp   r11, #%28
        jr   ult, for__26__body
.lt19:
        ; add r{r8}, r{r8}, 1
        incw r8
for__25:
        ; branch r{r8} lt 20: for_25_body, clearField_ret
        cp   r8, #%00
        jr   lt, for__25__body
        jr   ne, .lt20
        cp   r9, #%14
        jr   ult, for__25__body
.lt20:
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void initField@i16@i16
        ; arg curr_r (i16): r0
        ; arg curr_c (i16): r2
        ; var row (i16): SP+8
        ; var column (i16): SP+10
initField_Pi16_Pi16:
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
        ; move param.curr_r{r8}, curr_r{r0}
        ld   r9, r1
        ld   r8, r0
        ; move param.curr_c{r10}, curr_c{r2}
        ld   r11, r3
        ld   r10, r2
        ; const bombs{r12}, 40
        ld   r12, #%00
        ld   r13, #%28
        ; 175:2 for bombs > 0
        jr   for__27

for__27__body:
        ; call t.5{r0} = random16[] -> i16
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
        ; call t.6{r0} = random16[] -> i16
        call random16
        ; move column{r2}, t.6{r0}
        ld   r3, r1
        ld   r2, r0
        ; mod column{r2}, column{r2}, 40
        ld   %12, r2
        ld   %13, r3
        ld   %14, #%00
        ld   %15, #%28
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
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; move t.8{r2}, row{r0}
        ld   r3, r1
        ld   r2, r0
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], row{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; sub t.8{r2}, t.8{r2}, param.curr_r{r8}
        sub  r3, r9
        sbc  r2, r8
        ; move t.8{r0}, t.8{r2}
        ld   r0, r2
        ld   r1, r3
        ; call t.7{r0} = abs@i16[t.8{r0}] -> i16
        call abs_Pi16
        ; branch t.7{r0} gt 1: if_28_then, or_29
        cp   r0, #%00
        jr   gt, if__28__then
        jr   ne, .gt21
        cp   r1, #%01
        jr   ugt, if__28__then
.gt21:
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; move t.10{r0}, column{r2}
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
        ; sub t.10{r0}, t.10{r0}, param.curr_c{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call t.9{r0} = abs@i16[t.10{r0}] -> i16
        call abs_Pi16
        ; branch t.9{r0} lteq 1: for_27_continue, if_28_then
        cp   r0, #%00
        jr   lt, for__27__continue
        jr   ne, .lt22
        cp   r1, #%01
        jr   ule, for__27__continue
.lt22:
if__28__then:
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; const arg.4.2{r4}, 1
        ld   r4, #%01
        ; call setCell@i16@i16@u8[row{r0}, column{r2}, arg.4.2{r4}]
        call setCell_Pi16_Pi16_Pu8
for__27__continue:
        ; sub bombs{r12}, bombs{r12}, 1
        decw r12
for__27:
        ; branch bombs{r12} gt 0: for_27_body, initField@i16@i16_ret
        cp   r12, #%00
        jr   gt, for__27__body
        jr   ne, .gt23
        cp   r13, #%00
        jr   ugt, for__27__body
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
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%04
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void maybeRevealAround@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; var r (i16): SP+8
        ; var dc (i16): SP+10
        ; var c (i16): SP+12
        ; var cell (u8): SP+14
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
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; call t.7{r0} = getBombCountAround@i16@i16[param.row{r0}, param.column{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; branch t.7{r0} notequals 0: maybeRevealAround@i16@i16_ret, if_30_end
        cp   r0, #%00
        jr   ne, maybeRevealAround_Pi16_Pi16__ret
        ; const dr{r12}, -1
        ld   r12, #%ff
        ld   r13, #%ff
        ; 190:2 for dr <= 1
        jr   for__31

for__31__body:
        ; move r{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; add r{r0}, r{r0}, dr{r12}
        add  r1, r13
        adc  r0, r12
        ; const dc{r4}, -1
        ld   r4, #%ff
        ld   r5, #%ff
        ; 192:3 for dc <= 1
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; move dc{r0}, dc{r4}
        ld   r0, r4
        ld   r1, r5
        jr   for__32

for__32__body:
        ; move dc{r4}, dc{r0}
        ld   r5, r1
        ld   r4, r0
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; branch dr{r12} notequals 0: if_33_end, and_34
        cp   r13, #%00
        jr   ne, if__33__end
        cp   r12, #%00
        jr   ne, if__33__end
        ; branch dc{r4} notequals 0: if_33_end, maybeRevealAround@i16@i16.no_critical_edge_18
        cp   r5, #%00
        jr   ne, if__33__end
        cp   r4, #%00
        jr   ne, if__33__end
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], dc{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        jr   for__32__continue

if__33__end:
        ; move c{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; add c{r2}, c{r2}, dc{r4}
        add  r3, r5
        adc  r2, r4
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], dc{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], c{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; call t.8{r0} = checkCellBounds@i16@i16[r{r0}, c{r2}] -> bool
        call checkCellBounds_Pi16_Pi16
        ; branch t.8{r0} equals 0: for_32_continue, if_35_end
        cp   r0, #%00
        jr   eq, for__32__continue
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load c{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], c{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; call cell{r0} = getCell@i16@i16[r{r0}, c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; addrof memVarAddr{r14}, cell
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], cell{r0}
        lde  @rr14, r0
        ; call t.9{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.9{r0} notequals 0: for_32_continue, if_36_end
        cp   r0, #%00
        jr   ne, for__32__continue
        ; addrof memVarAddr{r14}, cell
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load cell{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; move t.10{r4}, cell{r0}
        ld   r4, r0
        ; or t.10{r4}, t.10{r4}, 2
        or  r4, #%02
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load c{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], c{r2}
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; call setCell@i16@i16@u8[r{r0}, c{r2}, t.10{r4}]
        call setCell_Pi16_Pi16_Pu8
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], r{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, c
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load c{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; call maybeRevealAround@i16@i16[r{r0}, c{r2}]
        call maybeRevealAround_Pi16_Pi16
for__32__continue:
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load dc{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; add dc{r0}, dc{r0}, 1
        incw r0
for__32:
        ; branch dc{r0} lteq 1: for_32_body, for_31_continue
        cp   r0, #%00
        jr   lt, for__32__body
        jr   ne, .lt24
        cp   r1, #%01
        jr   ule, for__32__body
.lt24:
        ; add dr{r12}, dr{r12}, 1
        incw r12
for__31:
        ; branch dr{r12} lteq 1: for_31_body, maybeRevealAround@i16@i16_ret
        cp   r12, #%00
        jr   lt, for__31__body
        jr   ne, .lt25
        cp   r13, #%01
        jr   ule, for__31__body
.lt25:
maybeRevealAround_Pi16_Pi16__ret:
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
        ; call initRandom@i32[arg.0.0{r0}]
        call initRandom_Pi32
        ; const needsInitialize{r8}, 1
        ld   r8, #%01
        ; call clearField[]
        call clearField
        ; const curr_c{r9}, 20
        ld   r9, #%00
        ld   r10, #%14
        ; const curr_r{r11}, 10
        ld   r11, #%00
        ld   r12, #%0a
        ; const arg.2.0{r0}, 20
        ld   r0, #%00
        ld   r1, #%14
        ; const arg.2.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.2.0{r0}, arg.2.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.6{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.6{r0}]
        call printString_P_Pu8
        ; 221:2 while true
        jr   while__37

if__38__then:
        ; 224:4 if printLeft([])
        ; call t.7{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.7{r0} notequals 0: if_39_then, if_38_end
        cp   r0, #%00
        jr   ne, if__39__then
if__38__end:
        ; call chr{r0} = getChar[] -> i16
        call getChar
        ; 231:3 if chr == 27
        ; branch chr{r0} equals 27: main_ret, if_40_end
        cp   r1, #%1b
        jr   ne, .notEquals26
        cp   r0, #%00
        jr   eq, main__ret
.notEquals26:
        ; branch chr{r0} equals 3: if_41_then, if_41_else
        cp   r1, #%03
        jr   ne, .notEquals27
        cp   r0, #%00
        jr   eq, if__41__then
.notEquals27:
        ; branch chr{r0} notequals 4: if_42_else, if_42_then
        cp   r1, #%04
        jr   ne, if__42__else
        cp   r0, #%00
        jr   ne, if__42__else
        jr   if__42__then

if__41__then:
        ; add t.10{r11}, t.10{r11}, 20
        add  r12, #%14
        adc  r11, #%00
        ; sub t.9{r11}, t.9{r11}, 1
        sub  r12, #%01
        sbc  r11, #%00
        ; mod curr_r{r11}, curr_r{r11}, 20
        ld   %12, r11
        ld   %13, r12
        ld   %14, #%00
        ld   %15, #%14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r11, %12
        ld   r12, %13
        jr   while__37

if__42__else:
        ; branch chr{r0} notequals 1: if_43_else, if_43_then
        cp   r1, #%01
        jr   ne, if__43__else
        cp   r0, #%00
        jr   ne, if__43__else
        jr   if__43__then

if__42__then:
        ; add t.11{r11}, t.11{r11}, 1
        add  r12, #%01
        adc  r11, #%00
        ; mod curr_r{r11}, curr_r{r11}, 20
        ld   %12, r11
        ld   %13, r12
        ld   %14, #%00
        ld   %15, #%14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r11, %12
        ld   r12, %13
        jr   while__37

if__43__else:
        ; branch chr{r0} notequals 2: if_44_else, if_44_then
        cp   r1, #%02
        jr   ne, if__44__else
        cp   r0, #%00
        jr   ne, if__44__else
        jr   if__44__then

if__43__then:
        ; add t.13{r9}, t.13{r9}, 40
        add  r10, #%28
        adc  r9, #%00
        ; sub t.12{r9}, t.12{r9}, 1
        sub  r10, #%01
        sbc  r9, #%00
        ; mod curr_c{r9}, curr_c{r9}, 40
        ld   %12, r9
        ld   %13, r10
        ld   %14, #%00
        ld   %15, #%28
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r9, %12
        ld   r10, %13
        jr   while__37

if__44__else:
        ; branch chr{r0} notequals 32: if_45_else, if_45_then
        cp   r1, #%20
        jr   ne, if__45__else
        cp   r0, #%00
        jr   ne, if__45__else
        jr   if__45__then

if__44__then:
        ; add t.14{r9}, t.14{r9}, 1
        add  r10, #%01
        adc  r9, #%00
        ; mod curr_c{r9}, curr_c{r9}, 40
        ld   %12, r9
        ld   %13, r10
        ld   %14, #%00
        ld   %15, #%28
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r9, %12
        ld   r10, %13
        jr   while__37

if__45__else:
        ; branch chr{r0} notequals 13: while_37, if_48_then
        cp   r1, #%0d
        jr   ne, while__37
        cp   r0, #%00
        jr   ne, while__37
        jr   if__48__then

if__45__then:
        ; branch needsInitialize{r8} notequals 0: while_37, if_46_then
        cp   r8, #%00
        jr   ne, while__37
        jr   if__46__then

if__48__then:
        ; branch needsInitialize{r8} equals 0: if_49_end, if_49_then
        cp   r8, #%00
        jr   eq, if__49__end
        jr   if__49__then

if__46__then:
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call cell{r0} = getCell@i16@i16[curr_r{r0}, curr_c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move cell{r13}, cell{r0}
        ld   r13, r0
        ; 255:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=255:17]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.15{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.15{r0} notequals 0: while_37, if_47_then
        cp   r0, #%00
        jr   ne, while__37
        jr   if__47__then

if__49__then:
        ; const needsInitialize{r8}, 0
        ld   r8, #%00
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call initField@i16@i16[curr_r{r0}, curr_c{r2}]
        call initField_Pi16_Pi16
        jr   if__49__end

if__47__then:
        ; xor cell{r13}, cell{r13}, 4
        xor r13, #%04
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; move cell{r4}, cell{r13}
        ld   r4, r13
        ; call setCell@i16@i16@u8[curr_r{r0}, curr_c{r2}, cell{r4}]
        call setCell_Pi16_Pi16_Pu8
        jr   while__37

if__49__end:
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call cell{r0} = getCell@i16@i16[curr_r{r0}, curr_c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move cell{r13}, cell{r0}
        ld   r13, r0
        ; 267:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=267:16]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.16{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.16{r0} notequals 0: if_50_end, if_50_then
        cp   r0, #%00
        jr   ne, if__50__end
        ; move t.17{r4}, cell{r13}
        ld   r4, r13
        ; or t.17{r4}, t.17{r4}, 2
        or  r4, #%02
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call setCell@i16@i16@u8[curr_r{r0}, curr_c{r2}, t.17{r4}]
        call setCell_Pi16_Pi16_Pu8
if__50__end:
        ; 270:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=270:15]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.18{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.18{r0} notequals 0: if_51_then, if_51_end
        cp   r0, #%00
        jr   ne, if__51__then
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call maybeRevealAround@i16@i16[curr_r{r0}, curr_c{r2}]
        call maybeRevealAround_Pi16_Pi16
while__37:
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call printField@i16@i16[curr_r{r0}, curr_c{r2}]
        call printField_Pi16_Pi16
        ; 223:3 if !needsInitialize
        ; branch needsInitialize{r8} notequals 0: if_38_end, if_38_then
        cp   r8, #%00
        jr   ne, if__38__end
        jr   if__38__then

if__39__then:
        ; const t.8{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.8{r0}]
        call printString_P_Pu8
        jr   main__ret

if__51__then:
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call printField@i16@i16[curr_r{r0}, curr_c{r2}]
        call printField_Pi16_Pi16
        ; const t.19{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.19{r0}]
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

        ; variable 0: field[] (u8*/1600)
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

