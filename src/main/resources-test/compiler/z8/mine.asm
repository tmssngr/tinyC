        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; void setCursor@i16@i16
        ; arg x (i16): r0
        ; arg y (i16): r2
setCursor_Pi16_Pi16:
        ret

        ; i16 rowColumnToCell@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
rowColumnToCell_Pi16_Pi16:
        ; 16:21 return row * 17 + column
        ; move t.3{r4}, param.row{r0}
        ld   r4, r0
        ld   r5, r1
        ; mul t.3{r4}, t.3{r4}, 17
        ld   %12, r4
        ld   %13, r5
        ld   %14, #%00
        ld   %15, #%11
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
        ld   r2, #hi(var__0)
        ld   r3, #lo(var__0)
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
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 17
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; gteq t.2{r4}, param.row{r0}, 0
        cp   r0, #%00
        jr   ge, .true4
        jr   ne, .false4
        cp   r1, #%00
        jr   ult, .false4
.true4:
        ld   r4, #1
        jr   .4
.false4:
        ld   r4, #0
.4:
        ; branch t.2{r4}, false, @and_next_3, @and_2nd_3
        or   r4, r4
        jr   z, and__next__3
        ; lt t.2{r4}, param.row{r0}, 20
        cp   r0, #%00
        jr   lt, .true5
        jr   ne, .false5
        cp   r1, #%14
        jr   uge, .false5
.true5:
        ld   r4, #1
        jr   .5
.false5:
        ld   r4, #0
.5:
and__next__3:
        ; branch t.2{r4}, false, @and_next_2, @and_2nd_2
        or   r4, r4
        jr   z, and__next__2
        ; gteq t.2{r4}, param.column{r2}, 0
        cp   r2, #%00
        jr   ge, .true6
        jr   ne, .false6
        cp   r3, #%00
        jr   ult, .false6
.true6:
        ld   r4, #1
        jr   .6
.false6:
        ld   r4, #0
.6:
and__next__2:
        ; branch t.2{r4}, false, @and_next_1, @and_2nd_1
        or   r4, r4
        jr   z, and__next__1
        ; lt t.2{r4}, param.column{r2}, 17
        cp   r2, #%00
        jr   lt, .true7
        jr   ne, .false7
        cp   r3, #%11
        jr   uge, .false7
.true7:
        ld   r4, #1
        jr   .7
.false7:
        ld   r4, #0
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
        ld   r2, #hi(var__0)
        ld   r3, #lo(var__0)
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
        ; var r (i16): SP+8
        ; var dc (i16): SP+10
        ; var c (i16): SP+12
getBombCountAround_Pi16_Pi16:
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
        ld   r9, r1
        ; move param.column{r10}, column{r2}
        ld   r10, r2
        ld   r11, r3
        ; const count{r12}, 0
        ld   r12, #%00
        ; const dr{r13}, -1
        ld   r13, #%ff
        ld   r14, #%ff
        ; 46:2 for dr <= 1
        jr   for__4

for__4__body:
        ; move r{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; add r{r0}, r{r0}, dr{r13}
        add  r1, r14
        adc  r0, r13
        ; const dc{r4}, -1
        ld   r4, #%ff
        ld   r5, #%ff
        ; 48:3 for dc <= 1
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
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
        ld   r4, r1
        ld   r5, r2
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
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
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], dc{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
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
        ; call t.10{r0} = checkCellBounds@i16@i16[r{r0}, c{r2}] -> bool
        call checkCellBounds_Pi16_Pi16
        ; branch t.10{r0}, false, @for_5_continue, @if_6_then
        or   r0, r0
        jr   z, for__5__continue
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
        ; call cell{r0} = getCell@i16@i16[r{r0}, c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; call t.11{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.11{r0}, false, @for_5_continue, @if_7_then
        or   r0, r0
        jr   z, for__5__continue
        ; add count{r12}, count{r12}, 1
        inc  r12
for__5__continue:
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load dc{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        incw r14
        lde  r2, @rr14
        ; add dc{r1}, dc{r1}, 1
        add  r2, #%01
        adc  r1, #%00
for__5:
        ; lteq t.9{r3}, dc{r1}, 1
        cp   r1, #%00
        jr   le, .true8
        jr   ne, .false8
        cp   r2, #%01
        jr   ugt, .false8
.true8:
        ld   r3, #1
        jr   .8
.false8:
        ld   r3, #0
.8:
        ; branch t.9{r3}, true, @for_5_body, @for_4_continue
        or   r3, r3
        jr   nz, for__5__body
        ; add dr{r13}, dr{r13}, 1
        add  r14, #%01
        adc  r13, #%00
for__4:
        ; lteq t.8{r1}, dr{r13}, 1
        cp   r13, #%00
        jr   le, .true9
        jr   ne, .false9
        cp   r14, #%01
        jr   ugt, .false9
.true9:
        ld   r1, #1
        jr   .9
.false9:
        ld   r1, #0
.9:
        ; branch t.8{r1}, true, @for_4_body, @for_4_break
        or   r1, r1
        jr   nz, for__4__body
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
        ret

        ; u8 getSpacer@i16@i16@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; arg rowCursor (i16): r4
        ; arg columnCursor (i16): r6
getSpacer_Pi16_Pi16_Pi16_Pi16:
        ; 62:2 if rowCursor == row
        ; equals t.4{r1}, param.rowCursor{r4}, param.row{r0}
        cp   r4, r0
        jr   ne, .ne10
        cp   r5, r1
        jr   ne, .ne10
        ld   r1, #1  ; true
        jr   .10
.ne10:
        ld   r1, #0
.10:
        ; branch t.4{r1}, false, @if_8_end, @if_8_then
        or   r1, r1
        jr   z, if__8__end
        ; 63:3 if columnCursor == column
        ; equals t.5{r1}, param.columnCursor{r6}, param.column{r2}
        cp   r6, r2
        jr   ne, .ne11
        cp   r7, r3
        jr   ne, .ne11
        ld   r1, #1  ; true
        jr   .11
.ne11:
        ld   r1, #0
.11:
        ; branch t.5{r1}, true, @if_9_then, @if_9_end
        or   r1, r1
        jr   nz, if__9__then
        ; 66:3 if columnCursor == column - 1
        ; move t.8{r1}, param.column{r2}
        ld   r2, r3
        ld   r1, r2
        ; sub t.8{r1}, t.8{r1}, 1
        sub  r2, #%01
        sbc  r1, #%00
        ; equals t.7{r1}, param.columnCursor{r6}, t.8{r1}
        cp   r6, r1
        jr   ne, .ne12
        cp   r7, r2
        jr   ne, .ne12
        ld   r1, #1  ; true
        jr   .12
.ne12:
        ld   r1, #0
.12:
        ; branch t.7{r1}, false, @if_8_end, @if_10_then
        or   r1, r1
        jr   z, if__8__end
        jr   if__10__then

if__9__then:
        ; 64:11 return 91
        ; const t.6{r0}, 91
        ld   r0, #%5b
        jr   getSpacer_Pi16_Pi16_Pi16_Pi16__ret

if__10__then:
        ; 67:11 return 93
        ; const t.9{r1}, 93
        ld   r1, #%5d
        ; move t.9{r0}, t.9{r1}
        ld   r0, r1
        jr   getSpacer_Pi16_Pi16_Pi16_Pi16__ret

if__8__end:
        ; 70:9 return 32
        ; const t.10{r1}, 32
        ld   r1, #%20
        ; move t.10{r0}, t.10{r1}
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
        ld   r9, r1
        ld   r10, r2
        ; move param.column{r11}, column{r3}
        ld   r11, r3
        ld   r12, r4
        ; const chr{r13}, 46
        ld   r13, #%2e
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.5{r0} = isOpen@u8[param.cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.5{r0}, true, @if_11_then, @if_11_else
        or   r0, r0
        jr   nz, if__11__then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.8{r0} = isFlag@u8[param.cell{r0}] -> bool
        call isFlag_Pu8
        ; branch t.8{r0}, false, @if_11_end, @if_14_then
        or   r0, r0
        jr   z, if__11__end
        jr   if__14__then

if__11__then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.6{r0} = isBomb@u8[param.cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.6{r0}, false, @if_12_else, @if_12_then
        or   r0, r0
        jr   z, if__12__else
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
        ; gt t.7{r8}, count{r0}, 0
        cp   r0, #%00
        jr   ule, .false13
.true13:
        ld   r8, #1
        jr   .13
.false13:
        ld   r8, #0
.13:
        ; branch t.7{r8}, false, @if_13_else, @if_13_then
        or   r8, r8
        jr   z, if__13__else
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
        ld   r8, r0
        ld   r9, r1
        ; move param.columnCursor{r10}, columnCursor{r2}
        ld   r10, r2
        ld   r11, r3
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
        ; 99:3 for column < 17
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
        ; lt t.8{r2}, column{r14}, 17
        cp   r14, #%00
        jr   lt, .true14
        jr   ne, .false14
        cp   r15, #%11
        jr   uge, .false14
.true14:
        ld   r2, #1
        jr   .14
.false14:
        ld   r2, #0
.14:
        ; branch t.8{r2}, true, @for_16_body, @for_16_break
        or   r2, r2
        jr   nz, for__16__body
        ; move row{r0}, row{r12}
        ld   r0, r12
        ld   r1, r13
        ; move param.rowCursor{r4}, param.rowCursor{r8}
        ld   r4, r8
        ld   r5, r9
        ; move param.columnCursor{r6}, param.columnCursor{r10}
        ld   r6, r10
        ld   r7, r11
        ; const arg.6.1{r2}, 17
        ld   r2, #%00
        ld   r3, #%11
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r0}, arg.6.1{r2}, param.rowCursor{r4}, param.columnCursor{r6}] -> u8
        call getSpacer_Pi16_Pi16_Pi16_Pi16
        ; call printChar@u8[spacer{r0}]
        call printChar_Pu8
        ; const t.9{r0}, [string-0]
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.9{r0}]
        call printString_P_Pu8
        ; add row{r12}, row{r12}, 1
        incw r12
for__15:
        ; lt t.7{r0}, row{r12}, 20
        cp   r12, #%00
        jr   lt, .true15
        jr   ne, .false15
        cp   r13, #%14
        jr   uge, .false15
.true15:
        ld   r0, #1
        jr   .15
.false15:
        ld   r0, #0
.15:
        ; branch t.7{r0}, true, @for_15_body, @printField@i16@i16_ret
        or   r0, r0
        jr   nz, for__15__body
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
        jr   for__17

for__17__body:
        ; const c{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; 168:3 for c < 17
        jr   for__18

for__18__body:
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
for__18:
        ; lt t.3{r0}, c{r10}, 17
        cp   r10, #%00
        jr   lt, .true16
        jr   ne, .false16
        cp   r11, #%11
        jr   uge, .false16
.true16:
        ld   r0, #1
        jr   .16
.false16:
        ld   r0, #0
.16:
        ; branch t.3{r0}, true, @for_18_body, @for_17_continue
        or   r0, r0
        jr   nz, for__18__body
        ; add r{r8}, r{r8}, 1
        incw r8
for__17:
        ; lt t.2{r0}, r{r8}, 20
        cp   r8, #%00
        jr   lt, .true17
        jr   ne, .false17
        cp   r9, #%14
        jr   uge, .false17
.true17:
        ld   r0, #1
        jr   .17
.false17:
        ld   r0, #0
.17:
        ; branch t.2{r0}, true, @for_17_body, @clearField_ret
        or   r0, r0
        jr   nz, for__17__body
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void main
main:
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom@i32[arg.0.0{r0}]
        call initRandom_Pi32
        ; call clearField[]
        call clearField
        ; const curr_c{r2}, 8
        ld   r2, #%00
        ld   r3, #%08
        ; const curr_r{r0}, 10
        ld   r0, #%00
        ld   r1, #%0a
        ; 219:2 while true
        ; call printField@i16@i16[curr_r{r0}, curr_c{r2}]
        call printField_Pi16_Pi16
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

        ; void initRandom@i32
initRandom_Pi32:
        ld   %70, r0
        ld   %71, r1
        ld   %72, r2
        ld   %73, r3
        ret

        ; variable 0: field[] (u8*/680)
var__0:
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

string__0:
        .data "|" %0a %00
string__1:
        .data "Left: " %00

