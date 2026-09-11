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
        ; 16:21 return row * 17 + column
        ; move t.3{r4}, param.row{r0}
        ld   r5, r1
        ld   r4, r0
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
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 17
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
        ; lt t.2{r4}, param.column{r2}, 17
        cp   r2, #%00
        jr   lt, .true7
        jr   ne, .false7
        cp   r3, #%11
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
        ; move param.cell{r8}, cell{r0}
        ld   r8, r0
        ; move param.row{r9}, row{r1}
        ld   r10, r2
        ld   r9, r1
        ; move param.column{r11}, column{r3}
        ld   r12, r4
        ld   r11, r3
        ; 75:2 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:12]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.5{r0} = isFlag@u8[param.cell{r0}] -> bool
        call isFlag_Pu8
        ; branch t.5{r0} notequals 0: if_8_then, if_8_else
        cp   r0, #%00
        jr   ne, if__8__then
        ; 78:7 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=78:17]])
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.6{r0} = isBomb@u8[param.cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.6{r0} equals 0: if_9_else, if_9_then
        cp   r0, #%00
        jr   eq, if__9__else
        jr   if__9__then

if__8__then:
        ; const chr{r8}, 35
        ld   r8, #%23
        jr   if__8__end

if__9__else:
        ; move param.row{r0}, param.row{r9}
        ld   r0, r9
        ld   r1, r10
        ; move param.column{r2}, param.column{r11}
        ld   r2, r11
        ld   r3, r12
        ; call count{r0} = getBombCountAround@i16@i16[param.row{r0}, param.column{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; move count{r9}, count{r0}
        ld   r9, r0
        ; 83:3 if count == 0 && isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=83:27]])
        ; branch count{r9} notequals 0: if_10_else, and_11
        cp   r9, #%00
        jr   ne, if__10__else
        jr   and__11

if__9__then:
        ; const chr{r8}, 42
        ld   r8, #%2a
        jr   if__8__end

and__11:
        ; move param.cell{r0}, param.cell{r8}
        ld   r0, r8
        ; call t.7{r0} = isOpen@u8[param.cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.7{r0} equals 0: if_10_else, if_10_then
        cp   r0, #%00
        jr   eq, if__10__else
        ; const chr{r8}, 32
        ld   r8, #%20
        jr   if__8__end

if__10__else:
        ; move chr{r8}, count{r9}
        ld   r8, r9
        ; add chr{r8}, chr{r8}, 48
        add  r8, #%30
if__8__end:
        ; move chr{r0}, chr{r8}
        ld   r0, r8
        ; call printChar@u8[chr{r0}]
        call printChar_Pu8
        ; restore clobbered non-volatile registers
        pop  r12
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
        ld   r9, #%00
        ; 95:2 for row < 20
        jr   for__12

for__12__body:
        ; const arg.1.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.1.0{r0}]
        call printChar_Pu8
        ; const column{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; 97:3 for column < 17
        jr   for__13

for__13__body:
        ; const arg.2.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
        ; move row{r0}, row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move column{r2}, column{r10}
        ld   r2, r10
        ld   r3, r11
        ; call cell{r0} = getCell@i16@i16[row{r0}, column{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move row{r1}, row{r8}
        ld   r1, r8
        ld   r2, r9
        ; move column{r3}, column{r10}
        ld   r3, r10
        ld   r4, r11
        ; call printCell@u8@i16@i16[cell{r0}, row{r1}, column{r3}]
        call printCell_Pu8_Pi16_Pi16
        ; add column{r10}, column{r10}, 1
        incw r10
for__13:
        ; branch column{r10} lt 17: for_13_body, for_13_break
        cp   r10, #%00
        jr   lt, for__13__body
        jr   ne, .lt10
        cp   r11, #%11
        jr   ult, for__13__body
.lt10:
        ; const t.3{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.3{r0}]
        call printString_P_Pu8
        ; add row{r8}, row{r8}, 1
        incw r8
for__12:
        ; branch row{r8} lt 20: for_12_body, printField_ret
        cp   r8, #%00
        jr   lt, for__12__body
        jr   ne, .lt11
        cp   r9, #%14
        jr   ult, for__12__body
.lt11:
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; i16 getX@i16
        ; arg column (i16): r0
getX_Pi16:
        ; 107:22 return column + 1 << 1
        ; move t.2{r2}, param.column{r0}
        ld   r3, r1
        ld   r2, r0
        ; add t.2{r2}, t.2{r2}, 1
        incw r2
        ; move t.1{r0}, t.2{r2}
        ld   r0, r2
        ld   r1, r3
        ; shiftleft t.1{r0}, t.1{r0}, 1
        rcf
        rlc  r1
        rlc  r0
        ret

        ; void printCursor@i16@i16@bool
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; arg show (bool): r4
printCursor_Pi16_Pi16_Pbool:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        ; move param.row{r8}, row{r0}
        ld   r9, r1
        ld   r8, r0
        ; move param.show{r10}, show{r4}
        ld   r10, r4
        ; move param.column{r0}, param.column{r2}
        ld   r0, r2
        ld   r1, r3
        ; call x{r0} = getX@i16[param.column{r0}] -> i16
        call getX_Pi16
        ; move x{r11}, x{r0}
        ld   r12, r1
        ld   r11, r0
        ; move t.4{r2}, x{r11}
        ld   r2, r11
        ld   r3, r12
        ; sub t.4{r2}, t.4{r2}, 1
        decw r2
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; call setCursor@i16@i16[param.row{r0}, t.4{r2}]
        call setCursor_Pi16_Pi16
        ; 113:2 if show
        ; branch param.show{r10} notequals 0: if_14_then, if_14_else
        cp   r10, #%00
        jr   ne, if__14__then
        ; const arg.3.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.3.0{r0}]
        call printChar_Pu8
        jr   if__14__end

if__14__then:
        ; const arg.2.0{r0}, 91
        ld   r0, #%5b
        ; call printChar@u8[arg.2.0{r0}]
        call printChar_Pu8
if__14__end:
        ; move t.5{r2}, x{r11}
        ld   r2, r11
        ld   r3, r12
        ; add t.5{r2}, t.5{r2}, 1
        incw r2
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; call setCursor@i16@i16[param.row{r0}, t.5{r2}]
        call setCursor_Pi16_Pi16
        ; 120:2 if show
        ; branch param.show{r10} notequals 0: if_15_then, if_15_else
        cp   r10, #%00
        jr   ne, if__15__then
        ; const arg.6.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.6.0{r0}]
        call printChar_Pu8
        jr   printCursor_Pi16_Pi16_Pbool__ret

if__15__then:
        ; const arg.5.0{r0}, 93
        ld   r0, #%5d
        ; call printChar@u8[arg.5.0{r0}]
        call printChar_Pu8
printCursor_Pi16_Pi16_Pbool__ret:
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
        ; 129:2 for i > 0
        jr   for__16

for__16__body:
        ; const arg.0.0{r0}, 48
        ld   r0, #%30
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; sub param.i{r8}, param.i{r8}, 1
        decw r8
for__16:
        ; branch param.i{r8} gt 0: for_16_body, printSpaces@i16_ret
        cp   r8, #%00
        jr   gt, for__16__body
        jr   ne, .gt12
        cp   r9, #%00
        jr   ugt, for__16__body
.gt12:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; u8 getDigitCount@i16
        ; arg value (i16): r0
getDigitCount_Pi16:
        ; const count{r2}, 0
        ld   r2, #%00
        ; 136:2 if value < 0
        ; branch param.value{r0} gteq 0: while_18, if_17_then
        cp   r0, #%00
        jr   gt, while__18
        jr   ne, .gt13
        cp   r1, #%00
        jr   uge, while__18
.gt13:
        ; const count{r2}, 1
        ld   r2, #%01
        ; neg param.value{r0}, param.value{r0}
        com  r0
        com  r1
        incw r0
while__18:
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
        ; 144:3 if value == 0
        ; branch param.value{r0} notequals 0: while_18, while_18_break
        cp   r1, #%00
        jr   ne, while__18
        cp   r0, #%00
        jr   ne, while__18
        ; 149:9 return count
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
        ; 154:2 for r < 20
        jr   for__20

for__20__body:
        ; const c{r12}, 0
        ld   r12, #%00
        ld   r13, #%00
        ; 155:3 for c < 17
        jr   for__21

for__21__body:
        ; move r{r0}, r{r10}
        ld   r0, r10
        ld   r1, r11
        ; move c{r2}, c{r12}
        ld   r2, r12
        ld   r3, r13
        ; call cell{r0} = getCell@i16@i16[r{r0}, c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; 157:4 if cell & 6 == 0
        ; move t.4{r2}, cell{r0}
        ld   r2, r0
        ; and t.4{r2}, t.4{r2}, 6
        and  r2, #%06
        ; branch t.4{r2} notequals 0: for_21_continue, if_22_then
        cp   r2, #%00
        jr   ne, for__21__continue
        ; add count{r8}, count{r8}, 1
        incw r8
for__21__continue:
        ; add c{r12}, c{r12}, 1
        incw r12
for__21:
        ; branch c{r12} lt 17: for_21_body, for_20_continue
        cp   r12, #%00
        jr   lt, for__21__body
        jr   ne, .lt14
        cp   r13, #%11
        jr   ult, for__21__body
.lt14:
        ; add r{r10}, r{r10}, 1
        incw r10
for__20:
        ; branch r{r10} lt 20: for_20_body, for_20_break
        cp   r10, #%00
        jr   lt, for__20__body
        jr   ne, .lt15
        cp   r11, #%14
        jr   ult, for__20__body
.lt15:
        ; 162:9 return count
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
        ; 173:15 return count == 0
        ; equals t.6{r0}, count{r8}, 0
        cp   r8, #%00
        jr   ne, .ne16
        cp   r9, #%00
        jr   ne, .ne16
        ld   r0, #1  ; true
        jr   .16
.ne16:
        ld   r0, #0
.16:
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
        ; 177:2 if a < 0
        ; branch param.a{r2} lt 0: if_23_then, if_23_end
        cp   r2, #%00
        jr   lt, if__23__then
        jr   ne, .lt17
        cp   r3, #%00
        jr   ult, if__23__then
.lt17:
        ; 180:9 return a
        ; move param.a{r0}, param.a{r2}
        ld   r0, r2
        ld   r1, r3
        jr   abs_Pi16__ret

if__23__then:
        ; 178:10 return -a
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
        ; 184:2 for r < 20
        jr   for__24

for__24__body:
        ; const c{r10}, 0
        ld   r10, #%00
        ld   r11, #%00
        ; 185:3 for c < 17
        jr   for__25

for__25__body:
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
for__25:
        ; branch c{r10} lt 17: for_25_body, for_24_continue
        cp   r10, #%00
        jr   lt, for__25__body
        jr   ne, .lt18
        cp   r11, #%11
        jr   ult, for__25__body
.lt18:
        ; add r{r8}, r{r8}, 1
        incw r8
for__24:
        ; branch r{r8} lt 20: for_24_body, clearField_ret
        cp   r8, #%00
        jr   lt, for__24__body
        jr   ne, .lt19
        cp   r9, #%14
        jr   ult, for__24__body
.lt19:
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
        ; const bombs{r12}, 17
        ld   r12, #%00
        ld   r13, #%11
        ; 192:2 for bombs > 0
        jr   for__26

for__26__body:
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
        ; 195:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=195:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=195:20], location=195:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=196:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=196:20], location=196:18]]) > 1
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
        ; branch t.7{r0} gt 1: if_27_then, or_28
        cp   r0, #%00
        jr   gt, if__27__then
        jr   ne, .gt20
        cp   r1, #%01
        jr   ugt, if__27__then
.gt20:
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
        ; branch t.9{r0} lteq 1: for_26_continue, if_27_then
        cp   r0, #%00
        jr   lt, for__26__continue
        jr   ne, .lt21
        cp   r1, #%01
        jr   ule, for__26__continue
.lt21:
if__27__then:
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
for__26__continue:
        ; sub bombs{r12}, bombs{r12}, 1
        decw r12
for__26:
        ; branch bombs{r12} gt 0: for_26_body, initField@i16@i16_ret
        cp   r12, #%00
        jr   gt, for__26__body
        jr   ne, .gt22
        cp   r13, #%00
        jr   ugt, for__26__body
.gt22:
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

        ; void revealCells@i16@i16@i16
        ; arg row (i16): r0
        ; arg left (i16): r2
        ; arg right (i16): r4
revealCells_Pi16_Pi16_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        ; move param.row{r8}, row{r0}
        ld   r9, r1
        ld   r8, r0
        ; move param.left{r10}, left{r2}
        ld   r11, r3
        ld   r10, r2
        ; move param.right{r12}, right{r4}
        ld   r13, r5
        ld   r12, r4
        ; move param.left{r0}, param.left{r10}
        ld   r0, r10
        ld   r1, r11
        ; call t.5{r0} = getX@i16[param.left{r0}] -> i16
        call getX_Pi16
        ; move t.5{r2}, t.5{r0}
        ld   r3, r1
        ld   r2, r0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; call setCursor@i16@i16[param.row{r0}, t.5{r2}]
        call setCursor_Pi16_Pi16
        ; 204:2 for c <= right
        jr   for__29

for__29__body:
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move c{r2}, c{r10}
        ld   r2, r10
        ld   r3, r11
        ; call cell{r0} = getCell@i16@i16[param.row{r0}, c{r2}] -> u8
        call getCell_Pi16_Pi16
        ; move cell{r14}, cell{r0}
        ld   r14, r0
        ; or cell{r14}, cell{r14}, 2
        or  r14, #%02
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move c{r2}, c{r10}
        ld   r2, r10
        ld   r3, r11
        ; move cell{r4}, cell{r14}
        ld   r4, r14
        ; call setCell@i16@i16@u8[param.row{r0}, c{r2}, cell{r4}]
        call setCell_Pi16_Pi16_Pu8
        ; move cell{r0}, cell{r14}
        ld   r0, r14
        ; move param.row{r1}, param.row{r8}
        ld   r1, r8
        ld   r2, r9
        ; move c{r3}, c{r10}
        ld   r3, r10
        ld   r4, r11
        ; call printCell@u8@i16@i16[cell{r0}, param.row{r1}, c{r3}]
        call printCell_Pu8_Pi16_Pi16
        ; const arg.5.0{r0}, 32
        ld   r0, #%20
        ; call printChar@u8[arg.5.0{r0}]
        call printChar_Pu8
        ; add c{r10}, c{r10}, 1
        incw r10
for__29:
        ; branch c{r10} lteq param.right{r12}: for_29_body, revealCells@i16@i16@i16_ret
        cp   r10, r12
        jr   lt, for__29__body
        jr   ne, .lt23
        cp   r11, r13
        jr   ule, for__29__body
.lt23:
        ; restore clobbered non-volatile registers
        pop  r14
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void maybeRevealAround@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
maybeRevealAround_Pi16_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; move param.row{r8}, row{r0}
        ld   r9, r1
        ld   r8, r0
        ; move param.column{r10}, column{r2}
        ld   r11, r3
        ld   r10, r2
        ; 214:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=214:24], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=214:29]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; call t.4{r0} = getBombCountAround@i16@i16[param.row{r0}, param.column{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; branch t.4{r0} notequals 0: maybeRevealAround@i16@i16_ret, if_30_end
        cp   r0, #%00
        jr   ne, maybeRevealAround_Pi16_Pi16__ret
        ; move left{r12}, param.column{r10}
        ld   r13, r11
        ld   r12, r10
        ; 219:2 while left > 0
        jr   while__31

while__31__body:
        ; sub left{r12}, left{r12}, 1
        decw r12
        ; 221:3 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=221:25], ExprVarAccess[varName=left, index=2, scope=function, type=i16, varIsArray=false, location=221:30]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move left{r2}, left{r12}
        ld   r2, r12
        ld   r3, r13
        ; call t.5{r0} = getBombCountAround@i16@i16[param.row{r0}, left{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; branch t.5{r0} notequals 0: if_32_then, while_31
        cp   r0, #%00
        jr   ne, if__32__then
while__31:
        ; branch left{r12} lteq 0: while_31_break, while_31_body
        cp   r12, #%00
        jr   lt, while__31__break
        jr   ne, .lt24
        cp   r13, #%00
        jr   ule, while__31__break
.lt24:
        jr   while__31__body

if__32__then:
        ; add left{r12}, left{r12}, 1
        incw r12
while__31__break:
        ; 228:2 while true
        jr   while__33

or__35:
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move right{r2}, right{r10}
        ld   r2, r10
        ld   r3, r11
        ; call t.6{r0} = getBombCountAround@i16@i16[param.row{r0}, right{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; branch t.6{r0} notequals 0: if_34_then, while_33
        cp   r0, #%00
        jr   ne, if__34__then
while__33:
        ; add right{r10}, right{r10}, 1
        incw r10
        ; 230:3 if right >= 17 || getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=231:25], ExprVarAccess[varName=right, index=3, scope=function, type=i16, varIsArray=false, location=231:30]]) != 0
        ; branch right{r10} lt 17: or_35, if_34_then
        cp   r10, #%00
        jr   lt, or__35
        jr   ne, .lt25
        cp   r11, #%11
        jr   ult, or__35
.lt25:
if__34__then:
        ; sub right{r10}, right{r10}, 1
        decw r10
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move left{r2}, left{r12}
        ld   r2, r12
        ld   r3, r13
        ; move right{r4}, right{r10}
        ld   r4, r10
        ld   r5, r11
        ; call revealCells@i16@i16@i16[param.row{r0}, left{r2}, right{r4}]
        call revealCells_Pi16_Pi16_Pi16
maybeRevealAround_Pi16_Pi16__ret:
        ; restore clobbered non-volatile registers
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
        push r13
        push r14
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
        ; const curr_c{r9}, 8
        ld   r9, #%00
        ld   r10, #%08
        ; const curr_r{r11}, 10
        ld   r11, #%00
        ld   r12, #%0a
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
        ; 277:2 while true
        jr   while__36

if__37__then:
        ; 279:4 if printLeft([])
        ; call t.7{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.7{r0} notequals 0: if_38_then, if_37_end
        cp   r0, #%00
        jr   ne, if__38__then
if__37__end:
        ; const t.9{r4}, 1
        ld   r4, #%01
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call printCursor@i16@i16@bool[curr_r{r0}, curr_c{r2}, t.9{r4}]
        call printCursor_Pi16_Pi16_Pbool
        ; call chr{r0} = getChar[] -> i16
        call getChar
        ; move chr{r13}, chr{r0}
        ld   r14, r1
        ld   r13, r0
        ; const t.10{r4}, 0
        ld   r4, #%00
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call printCursor@i16@i16@bool[curr_r{r0}, curr_c{r2}, t.10{r4}]
        call printCursor_Pi16_Pi16_Pbool
        ; 288:3 if chr == 27
        ; branch chr{r13} equals 27: main_ret, if_39_end
        cp   r14, #%1b
        jr   ne, .notEquals26
        cp   r13, #%00
        jr   eq, main__ret
.notEquals26:
        ; branch chr{r13} equals 3: if_40_then, if_40_else
        cp   r14, #%03
        jr   ne, .notEquals27
        cp   r13, #%00
        jr   eq, if__40__then
.notEquals27:
        ; branch chr{r13} notequals 4: if_41_else, if_41_then
        cp   r14, #%04
        jr   ne, if__41__else
        cp   r13, #%00
        jr   ne, if__41__else
        jr   if__41__then

if__40__then:
        ; add t.12{r11}, t.12{r11}, 20
        add  r12, #%14
        adc  r11, #%00
        ; sub t.11{r11}, t.11{r11}, 1
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
        jr   while__36

if__41__else:
        ; branch chr{r13} notequals 1: if_42_else, if_42_then
        cp   r14, #%01
        jr   ne, if__42__else
        cp   r13, #%00
        jr   ne, if__42__else
        jr   if__42__then

if__41__then:
        ; add t.13{r11}, t.13{r11}, 1
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
        jr   while__36

if__42__else:
        ; branch chr{r13} notequals 2: if_43_else, if_43_then
        cp   r14, #%02
        jr   ne, if__43__else
        cp   r13, #%00
        jr   ne, if__43__else
        jr   if__43__then

if__42__then:
        ; add t.15{r9}, t.15{r9}, 17
        add  r10, #%11
        adc  r9, #%00
        ; sub t.14{r9}, t.14{r9}, 1
        sub  r10, #%01
        sbc  r9, #%00
        ; mod curr_c{r9}, curr_c{r9}, 17
        ld   %12, r9
        ld   %13, r10
        ld   %14, #%00
        ld   %15, #%11
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r9, %12
        ld   r10, %13
        jr   while__36

if__43__else:
        ; branch chr{r13} notequals 32: if_44_else, if_44_then
        cp   r14, #%20
        jr   ne, if__44__else
        cp   r13, #%00
        jr   ne, if__44__else
        jr   if__44__then

if__43__then:
        ; add t.16{r9}, t.16{r9}, 1
        add  r10, #%01
        adc  r9, #%00
        ; mod curr_c{r9}, curr_c{r9}, 17
        ld   %12, r9
        ld   %13, r10
        ld   %14, #%00
        ld   %15, #%11
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r9, %12
        ld   r10, %13
        jr   while__36

if__44__else:
        ; branch chr{r13} notequals 13: while_36, if_47_then
        cp   r14, #%0d
        jr   ne, while__36
        cp   r13, #%00
        jr   ne, while__36
        jr   if__47__then

if__44__then:
        ; branch needsInitialize{r8} notequals 0: while_36, if_45_then
        cp   r8, #%00
        jr   ne, while__36
        jr   if__45__then

if__47__then:
        ; branch needsInitialize{r8} equals 0: if_48_end, if_48_then
        cp   r8, #%00
        jr   eq, if__48__end
        jr   if__48__then

if__45__then:
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
        ; 312:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=312:17]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.17{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.17{r0} notequals 0: while_36, if_46_then
        cp   r0, #%00
        jr   ne, while__36
        jr   if__46__then

if__48__then:
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
        ; call printField[]
        call printField
        jr   if__48__end

if__46__then:
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
        jr   while__36

if__48__end:
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
        ; 325:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=325:16]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.18{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.18{r0} notequals 0: if_49_end, if_49_then
        cp   r0, #%00
        jr   ne, if__49__end
        ; move t.19{r4}, cell{r13}
        ld   r4, r13
        ; or t.19{r4}, t.19{r4}, 2
        or  r4, #%02
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call setCell@i16@i16@u8[curr_r{r0}, curr_c{r2}, t.19{r4}]
        call setCell_Pi16_Pi16_Pu8
if__49__end:
        ; 328:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=328:15]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.20{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.20{r0} notequals 0: if_50_then, if_50_end
        cp   r0, #%00
        jr   ne, if__50__then
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call maybeRevealAround@i16@i16[curr_r{r0}, curr_c{r2}]
        call maybeRevealAround_Pi16_Pi16
while__36:
        ; branch needsInitialize{r8} notequals 0: if_37_end, if_37_then
        cp   r8, #%00
        jr   ne, if__37__end
        jr   if__37__then

if__38__then:
        ; const t.8{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.8{r0}]
        call printString_P_Pu8
        jr   main__ret

if__50__then:
        ; call printField[]
        call printField
        ; const t.21{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.21{r0}]
        call printString_P_Pu8
main__ret:
        ; restore clobbered non-volatile registers
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

