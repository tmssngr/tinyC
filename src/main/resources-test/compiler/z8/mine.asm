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

        ; void setCursor@i16@i16
        ; arg x (i16): r0
        ; arg y (i16): r2
setCursor_Pi16_Pi16:
        ret

        ; i16 getChar
getChar:
        ; 139:9 return 0
        ; const t.0{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ret

        ; void initRandom@i32
        ; arg salt (i32): r0
initRandom_Pi32:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.__random__{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        incw r14
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
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

        ; i32 random
        ; var b (i32): SP+8
random:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; load tmp.__random__{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        incw r14
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; move r{r4}, tmp.__random__{r0}
        ld   r4, r0
        ld   r5, r1
        ld   r6, r2
        ld   r7, r3
        ; const t.6{r8}, 524287
        ld   r8, #%00
        ld   r9, #%07
        ld   r10, #%ff
        ld   r11, #%ff
        ; move t.5{r0}, r{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.5{r0}, t.5{r0}, t.6{r8}
        and  r0, r8
        and  r1, r9
        and  r2, r10
        and  r3, r11
        ; const t.7{r8}, 48271
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%bc
        ld   r11, #%8f
        ; mul b{r0}, b{r0}, t.7{r8}
        Not supported yet: mul/div/mod for i32
        ; const t.9{r8}, 15
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%0f
        ; shiftright t.8{r4}, t.8{r4}, t.9{r8}
        or   r11, r11
        jr   z, .next1
        push r11
.shift1:
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        djnz r11, .shift1
        pop  r11
.next1:
        ; const t.10{r8}, 48271
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%bc
        ld   r11, #%8f
        ; mul c{r4}, c{r4}, t.10{r8}
        Not supported yet: mul/div/mod for i32
        ; const t.12{r8}, 65535
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%ff
        ld   r11, #%ff
        ; addrof memVarAddr{r14}, b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], b{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        incw r14
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
        ; move t.11{r0}, c{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.11{r0}, t.11{r0}, t.12{r8}
        and  r0, r8
        and  r1, r9
        and  r2, r10
        and  r3, r11
        ; const t.13{r8}, 15
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%0f
        ; shiftleft d{r0}, d{r0}, t.13{r8}
        or   r11, r11
        jr   z, .next2
        push r11
.shift2:
        rcf
        rlc  r3
        rlc  r2
        rlc  r1
        rlc  r0
        djnz r11, .shift2
        pop  r11
.next2:
        ; const t.16{r8}, 16
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%10
        ; shiftright t.15{r4}, t.15{r4}, t.16{r8}
        or   r11, r11
        jr   z, .next3
        push r11
.shift3:
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        djnz r11, .shift3
        pop  r11
.next3:
        ; addrof memVarAddr{r14}, b
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load b{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        incw r14
        lde  r9, @rr14
        incw r14
        lde  r10, @rr14
        incw r14
        lde  r11, @rr14
        ; add t.14{r4}, t.14{r4}, b{r8}
        add  r7, r11
        adc  r6, r10
        adc  r5, r9
        adc  r4, r8
        ; add e{r4}, e{r4}, d{r0}
        add  r7, r3
        adc  r6, r2
        adc  r5, r1
        adc  r4, r0
        ; const t.18{r8}, 2147483647
        ld   r8, #%7f
        ld   r9, #%ff
        ld   r10, #%ff
        ld   r11, #%ff
        ; move t.17{r0}, e{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; and t.17{r0}, t.17{r0}, t.18{r8}
        and  r0, r8
        and  r1, r9
        and  r2, r10
        and  r3, r11
        ; const t.20{r8}, 31
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%1f
        ; shiftright t.19{r4}, t.19{r4}, t.20{r8}
        or   r11, r11
        jr   z, .next4
        push r11
.shift4:
        sra  r4
        rrc  r5
        rrc  r6
        rrc  r7
        djnz r11, .shift4
        pop  r11
.next4:
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.19{r4}
        add  r3, r7
        adc  r2, r6
        adc  r1, r5
        adc  r0, r4
        ; 15:9 return __random__
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.__random__{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        incw r14
        lde  @rr14, r2
        incw r14
        lde  @rr14, r3
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

        ; i16 rowColumnToCell@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
rowColumnToCell_Pi16_Pi16:
        ; 16:21 return row * 40 + column
        ; const t.4{r4}, 40
        ld   r4, #%00
        ld   r5, #%28
        ; move t.3{r6}, param.row{r0}
        ld   r6, r0
        ld   r7, r1
        ; mul t.3{r6}, t.3{r6}, t.4{r4}
        ld   %12, r6
        ld   %13, r7
        ld   %14, r4
        ld   %15, r5
        srp  #%10
        call %00BA ; mul
        srp  #%20
        ld   r6, %12
        ld   r7, %13
        ; move t.2{r0}, t.3{r6}
        ld   r0, r6
        ld   r1, r7
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
        ld   r2, #hi(var__1)
        ld   r3, #lo(var__1)
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
        ; const t.3{r1}, 1
        ld   r1, #%01
        ; move t.2{r2}, param.cell{r0}
        ld   r2, r0
        ; and t.2{r2}, t.2{r2}, t.3{r1}
        and  r2, r1
        ; const t.4{r1}, 0
        ld   r1, #%00
        ; notequals t.1{r0}, t.2{r2}, t.4{r1}
        cp   r2, r1
        jr   ne, .ne5
        ld   r0, #0  ; false
        jr   .5
.ne5:
        ld   r0, #1
.5:
        ret

        ; bool isOpen@u8
        ; arg cell (u8): r0
isOpen_Pu8:
        ; 28:27 return cell & 2 != 0
        ; const t.3{r1}, 2
        ld   r1, #%02
        ; move t.2{r2}, param.cell{r0}
        ld   r2, r0
        ; and t.2{r2}, t.2{r2}, t.3{r1}
        and  r2, r1
        ; const t.4{r1}, 0
        ld   r1, #%00
        ; notequals t.1{r0}, t.2{r2}, t.4{r1}
        cp   r2, r1
        jr   ne, .ne6
        ld   r0, #0  ; false
        jr   .6
.ne6:
        ld   r0, #1
.6:
        ret

        ; bool isFlag@u8
        ; arg cell (u8): r0
isFlag_Pu8:
        ; 32:27 return cell & 4 != 0
        ; const t.3{r1}, 4
        ld   r1, #%04
        ; move t.2{r2}, param.cell{r0}
        ld   r2, r0
        ; and t.2{r2}, t.2{r2}, t.3{r1}
        and  r2, r1
        ; const t.4{r1}, 0
        ld   r1, #%00
        ; notequals t.1{r0}, t.2{r2}, t.4{r1}
        cp   r2, r1
        jr   ne, .ne7
        ld   r0, #0  ; false
        jr   .7
.ne7:
        ld   r0, #1
.7:
        ret

        ; bool checkCellBounds@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
checkCellBounds_Pi16_Pi16:
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; const t.3{r4}, 0
        ld   r4, #%00
        ld   r5, #%00
        ; gteq t.2{r4}, param.row{r0}, t.3{r4}
        cp   r0, r4
        jr   ge, .true8
        jr   ne, .false8
        cp   r1, r5
        jr   ult, .false8
.true8:
        ld   r4, #1
        jr   .8
.false8:
        ld   r4, #0
.8:
        ; branch t.2{r4}, false, @and_next_3, @and_2nd_3
        or   r4, r4
        jr   z, and__next__3
        ; const t.4{r4}, 20
        ld   r4, #%00
        ld   r5, #%14
        ; lt t.2{r4}, param.row{r0}, t.4{r4}
        cp   r0, r4
        jr   lt, .true9
        jr   ne, .false9
        cp   r1, r5
        jr   uge, .false9
.true9:
        ld   r4, #1
        jr   .9
.false9:
        ld   r4, #0
.9:
and__next__3:
        ; branch t.2{r4}, false, @and_next_2, @and_2nd_2
        or   r4, r4
        jr   z, and__next__2
        ; const t.5{r4}, 0
        ld   r4, #%00
        ld   r5, #%00
        ; gteq t.2{r4}, param.column{r2}, t.5{r4}
        cp   r2, r4
        jr   ge, .true10
        jr   ne, .false10
        cp   r3, r5
        jr   ult, .false10
.true10:
        ld   r4, #1
        jr   .10
.false10:
        ld   r4, #0
.10:
and__next__2:
        ; branch t.2{r4}, false, @and_next_1, @and_2nd_1
        or   r4, r4
        jr   z, and__next__1
        ; const t.6{r4}, 40
        ld   r4, #%00
        ld   r5, #%28
        ; lt t.2{r4}, param.column{r2}, t.6{r4}
        cp   r2, r4
        jr   lt, .true11
        jr   ne, .false11
        cp   r3, r5
        jr   uge, .false11
.true11:
        ld   r4, #1
        jr   .11
.false11:
        ld   r4, #0
.11:
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
        ld   r2, #hi(var__1)
        ld   r3, #lo(var__1)
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
        ; move dc{r3}, dc{r4}
        ld   r4, r5
        ld   r3, r4
        jr   for__5

for__5__body:
        ; move dc{r4}, dc{r3}
        ld   r5, r4
        ld   r4, r3
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
        ; call t.12{r0} = checkCellBounds@i16@i16[r{r0}, c{r2}] -> bool
        call checkCellBounds_Pi16_Pi16
        ; branch t.12{r0}, false, @for_5_continue, @if_6_then
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
        ; call t.13{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.13{r0}, false, @for_5_continue, @if_7_then
        or   r0, r0
        jr   z, for__5__continue
        ; const t.14{r1}, 1
        ld   r1, #%01
        ; add count{r12}, count{r12}, t.14{r1}
        add  r12, r1
for__5__continue:
        ; const t.15{r1}, 1
        ld   r1, #%00
        ld   r2, #%01
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load dc{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        incw r14
        lde  r4, @rr14
        ; add dc{r3}, dc{r3}, t.15{r1}
        add  r4, r2
        adc  r3, r1
for__5:
        ; const t.11{r1}, 1
        ld   r1, #%00
        ld   r2, #%01
        ; lteq t.10{r1}, dc{r3}, t.11{r1}
        cp   r3, r1
        jr   le, .true12
        jr   ne, .false12
        cp   r4, r2
        jr   ugt, .false12
.true12:
        ld   r1, #1
        jr   .12
.false12:
        ld   r1, #0
.12:
        ; branch t.10{r1}, true, @for_5_body, @for_4_continue
        or   r1, r1
        jr   nz, for__5__body
        ; const t.16{r1}, 1
        ld   r1, #%00
        ld   r2, #%01
        ; add dr{r13}, dr{r13}, t.16{r1}
        add  r14, r2
        adc  r13, r1
for__4:
        ; const t.9{r1}, 1
        ld   r1, #%00
        ld   r2, #%01
        ; lteq t.8{r1}, dr{r13}, t.9{r1}
        cp   r13, r1
        jr   le, .true13
        jr   ne, .false13
        cp   r14, r2
        jr   ugt, .false13
.true13:
        ld   r1, #1
        jr   .13
.false13:
        ld   r1, #0
.13:
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
        jr   ne, .ne14
        cp   r5, r1
        jr   ne, .ne14
        ld   r1, #1  ; true
        jr   .14
.ne14:
        ld   r1, #0
.14:
        ; branch t.4{r1}, false, @if_8_end, @if_8_then
        or   r1, r1
        jr   z, if__8__end
        ; 63:3 if columnCursor == column
        ; equals t.5{r1}, param.columnCursor{r6}, param.column{r2}
        cp   r6, r2
        jr   ne, .ne15
        cp   r7, r3
        jr   ne, .ne15
        ld   r1, #1  ; true
        jr   .15
.ne15:
        ld   r1, #0
.15:
        ; branch t.5{r1}, true, @if_9_then, @if_9_end
        or   r1, r1
        jr   nz, if__9__then
        ; 66:3 if columnCursor == column - 1
        ; const t.9{r4}, 1
        ld   r4, #%00
        ld   r5, #%01
        ; move t.8{r1}, param.column{r2}
        ld   r2, r3
        ld   r1, r2
        ; sub t.8{r1}, t.8{r1}, t.9{r4}
        sub  r2, r5
        sbc  r1, r4
        ; equals t.7{r1}, param.columnCursor{r6}, t.8{r1}
        cp   r6, r1
        jr   ne, .ne16
        cp   r7, r2
        jr   ne, .ne16
        ld   r1, #1  ; true
        jr   .16
.ne16:
        ld   r1, #0
.16:
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
        ; const t.10{r1}, 93
        ld   r1, #%5d
        ; move t.10{r0}, t.10{r1}
        ld   r0, r1
        jr   getSpacer_Pi16_Pi16_Pi16_Pi16__ret

if__8__end:
        ; 70:9 return 32
        ; const t.11{r1}, 32
        ld   r1, #%20
        ; move t.11{r0}, t.11{r1}
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
        ; call t.10{r0} = isFlag@u8[param.cell{r0}] -> bool
        call isFlag_Pu8
        ; branch t.10{r0}, false, @if_11_end, @if_14_then
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
        ; const t.8{r8}, 0
        ld   r8, #%00
        ; gt t.7{r8}, count{r0}, t.8{r8}
        cp   r0, r8
        jr   ule, .false17
.true17:
        ld   r8, #1
        jr   .17
.false17:
        ld   r8, #0
.17:
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
        ; const t.9{r8}, 48
        ld   r8, #%30
        ; move chr{r13}, count{r0}
        ld   r13, r0
        ; add chr{r13}, chr{r13}, t.9{r8}
        add  r13, r8
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
        ; const t.7{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const t.8{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[t.7{r0}, t.8{r2}]
        call setCursor_Pi16_Pi16
        ; const row{r12}, 0
        ld   r12, #%00
        ld   r13, #%00
        ; 97:2 for row < 20
        jr   for__15

for__15__body:
        ; const t.11{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[t.11{r0}]
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
        ; const t.14{r6}, 1
        ld   r6, #%00
        ld   r7, #%01
        ; add column{r14}, column{r14}, t.14{r6}
        add  r15, r7
        adc  r14, r6
for__16:
        ; const t.13{r6}, 40
        ld   r6, #%00
        ld   r7, #%28
        ; lt t.12{r6}, column{r14}, t.13{r6}
        cp   r14, r6
        jr   lt, .true18
        jr   ne, .false18
        cp   r15, r7
        jr   uge, .false18
.true18:
        ld   r6, #1
        jr   .18
.false18:
        ld   r6, #0
.18:
        ; branch t.12{r6}, true, @for_16_body, @for_16_break
        or   r6, r6
        jr   nz, for__16__body
        ; const t.15{r2}, 40
        ld   r2, #%00
        ld   r3, #%28
        ; move row{r0}, row{r12}
        ld   r0, r12
        ld   r1, r13
        ; move param.rowCursor{r4}, param.rowCursor{r8}
        ld   r4, r8
        ld   r5, r9
        ; move param.columnCursor{r6}, param.columnCursor{r10}
        ld   r6, r10
        ld   r7, r11
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r0}, t.15{r2}, param.rowCursor{r4}, param.columnCursor{r6}] -> u8
        call getSpacer_Pi16_Pi16_Pi16_Pi16
        ; call printChar@u8[spacer{r0}]
        call printChar_Pu8
        ; const t.16{r0}, [string-0]
        ld   r0, #hi(string__0)
        ld   r1, #lo(string__0)
        ; call printString@@u8[t.16{r0}]
        call printString_P_Pu8
        ; const t.17{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; add row{r12}, row{r12}, t.17{r0}
        add  r13, r1
        adc  r12, r0
for__15:
        ; const t.10{r0}, 20
        ld   r0, #%00
        ld   r1, #%14
        ; lt t.9{r0}, row{r12}, t.10{r0}
        cp   r12, r0
        jr   lt, .true19
        jr   ne, .false19
        cp   r13, r1
        jr   uge, .false19
.true19:
        ld   r0, #1
        jr   .19
.false19:
        ld   r0, #0
.19:
        ; branch t.9{r0}, true, @for_15_body, @printField@i16@i16_ret
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

        ; void printSpaces@i16
        ; arg i (i16): r0
printSpaces_Pi16:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; move param.i{r8}, i{r0}
        ld   r8, r0
        ld   r9, r1
        ; 112:2 for i > 0
        jr   for__17

for__17__body:
        ; const t.3{r0}, 48
        ld   r0, #%30
        ; call printChar@u8[t.3{r0}]
        call printChar_Pu8
        ; const t.4{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; sub param.i{r8}, param.i{r8}, t.4{r0}
        sub  r9, r1
        sbc  r8, r0
for__17:
        ; const t.2{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; gt t.1{r0}, param.i{r8}, t.2{r0}
        cp   r8, r0
        jr   gt, .true20
        jr   ne, .false20
        cp   r9, r1
        jr   ule, .false20
.true20:
        ld   r0, #1
        jr   .20
.false20:
        ld   r0, #0
.20:
        ; branch t.1{r0}, true, @for_17_body, @printSpaces@i16_ret
        or   r0, r0
        jr   nz, for__17__body
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
        ; const t.3{r3}, 0
        ld   r3, #%00
        ld   r4, #%00
        ; lt t.2{r3}, param.value{r0}, t.3{r3}
        cp   r0, r3
        jr   lt, .true21
        jr   ne, .false21
        cp   r1, r4
        jr   uge, .false21
.true21:
        ld   r3, #1
        jr   .21
.false21:
        ld   r3, #0
.21:
        ; branch t.2{r3}, false, @while_19, @if_18_then
        or   r3, r3
        jr   z, while__19
        ; const count{r2}, 1
        ld   r2, #%01
        ; neg param.value{r0}, param.value{r0}
        com  r0
        com  r1
        incw r0
while__19:
        ; const t.4{r3}, 1
        ld   r3, #%01
        ; add count{r2}, count{r2}, t.4{r3}
        add  r2, r3
        ; const t.5{r3}, 10
        ld   r3, #%00
        ld   r4, #%0a
        ; div param.value{r0}, param.value{r0}, t.5{r3}
        ld   %12, r0
        ld   %13, r1
        ld   %14, r3
        ld   %15, r4
        srp  #%10
        call %00E0 ; div
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; 127:3 if value == 0
        ; const t.7{r3}, 0
        ld   r3, #%00
        ld   r4, #%00
        ; equals t.6{r3}, param.value{r0}, t.7{r3}
        cp   r0, r3
        jr   ne, .ne22
        cp   r1, r4
        jr   ne, .ne22
        ld   r3, #1  ; true
        jr   .22
.ne22:
        ld   r3, #0
.22:
        ; branch t.6{r3}, false, @while_19, @while_19_break
        or   r3, r3
        jr   z, while__19
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
        ; const t.10{r2}, 6
        ld   r2, #%06
        ; move t.9{r3}, cell{r0}
        ld   r3, r0
        ; and t.9{r3}, t.9{r3}, t.10{r2}
        and  r3, r2
        ; const t.11{r2}, 0
        ld   r2, #%00
        ; equals t.8{r2}, t.9{r3}, t.11{r2}
        cp   r3, r2
        jr   ne, .ne23
        ld   r2, #1  ; true
        jr   .23
.ne23:
        ld   r2, #0
.23:
        ; branch t.8{r2}, false, @for_22_continue, @if_23_then
        or   r2, r2
        jr   z, for__22__continue
        ; const t.12{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; add count{r8}, count{r8}, t.12{r2}
        add  r9, r3
        adc  r8, r2
for__22__continue:
        ; const t.13{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; add c{r12}, c{r12}, t.13{r2}
        add  r13, r3
        adc  r12, r2
for__22:
        ; const t.7{r2}, 40
        ld   r2, #%00
        ld   r3, #%28
        ; lt t.6{r2}, c{r12}, t.7{r2}
        cp   r12, r2
        jr   lt, .true24
        jr   ne, .false24
        cp   r13, r3
        jr   uge, .false24
.true24:
        ld   r2, #1
        jr   .24
.false24:
        ld   r2, #0
.24:
        ; branch t.6{r2}, true, @for_22_body, @for_21_continue
        or   r2, r2
        jr   nz, for__22__body
        ; const t.14{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; add r{r10}, r{r10}, t.14{r2}
        add  r11, r3
        adc  r10, r2
for__21:
        ; const t.5{r2}, 20
        ld   r2, #%00
        ld   r3, #%14
        ; lt t.4{r2}, r{r10}, t.5{r2}
        cp   r10, r2
        jr   lt, .true25
        jr   ne, .false25
        cp   r11, r3
        jr   uge, .false25
.true25:
        ld   r2, #1
        jr   .25
.false25:
        ld   r2, #0
.25:
        ; branch t.4{r2}, true, @for_21_body, @for_21_break
        or   r2, r2
        jr   nz, for__21__body
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
        ld   r8, r0
        ld   r9, r1
        ; move count{r0}, count{r8}
        ld   r0, r8
        ld   r1, r9
        ; call t.3{r0} = getDigitCount@i16[count{r0}] -> u8
        call getDigitCount_Pi16
        ; cast leftDigits{r10}(i16), t.3{r0}(u8)
        ld   r11, r0
        ld   r10, #0
        ; const t.5{r0}, 40
        ld   r0, #%00
        ld   r1, #%28
        ; call t.4{r0} = getDigitCount@i16[t.5{r0}] -> u8
        call getDigitCount_Pi16
        ; cast bombDigits{r12}(i16), t.4{r0}(u8)
        ld   r13, r0
        ld   r12, #0
        ; const t.6{r0}, [string-1]
        ld   r0, #hi(string__1)
        ld   r1, #lo(string__1)
        ; call printString@@u8[t.6{r0}]
        call printString_P_Pu8
        ; move t.7{r0}, bombDigits{r12}
        ld   r0, r12
        ld   r1, r13
        ; sub t.7{r0}, t.7{r0}, leftDigits{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call printSpaces@i16[t.7{r0}]
        call printSpaces_Pi16
        ; move count{r0}, count{r8}
        ld   r0, r8
        ld   r1, r9
        ; call printUint@i16[count{r0}]
        call printUint_Pi16
        ; 156:15 return count == 0
        ; const t.9{r1}, 0
        ld   r1, #%00
        ld   r2, #%00
        ; equals t.8{r0}, count{r8}, t.9{r1}
        cp   r8, r1
        jr   ne, .ne26
        cp   r9, r2
        jr   ne, .ne26
        ld   r0, #1  ; true
        jr   .26
.ne26:
        ld   r0, #0
.26:
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
        ld   r2, r0
        ld   r3, r1
        ; 160:2 if a < 0
        ; const t.2{r4}, 0
        ld   r4, #%00
        ld   r5, #%00
        ; lt t.1{r4}, param.a{r2}, t.2{r4}
        cp   r2, r4
        jr   lt, .true27
        jr   ne, .false27
        cp   r3, r5
        jr   uge, .false27
.true27:
        ld   r4, #1
        jr   .27
.false27:
        ld   r4, #0
.27:
        ; branch t.1{r4}, true, @if_24_then, @if_24_end
        or   r4, r4
        jr   nz, if__24__then
        ; 163:9 return a
        ; move param.a{r0}, param.a{r2}
        ld   r0, r2
        ld   r1, r3
        jr   abs_Pi16__ret

if__24__then:
        ; 161:10 return -a
        ; neg t.3{r2}, param.a{r2}
        com  r2
        com  r3
        incw r2
        ; move t.3{r0}, t.3{r2}
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
        ; const t.6{r4}, 0
        ld   r4, #%00
        ; move r{r0}, r{r8}
        ld   r0, r8
        ld   r1, r9
        ; move c{r2}, c{r10}
        ld   r2, r10
        ld   r3, r11
        ; call setCell@i16@i16@u8[r{r0}, c{r2}, t.6{r4}]
        call setCell_Pi16_Pi16_Pu8
        ; const t.7{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; add c{r10}, c{r10}, t.7{r0}
        add  r11, r1
        adc  r10, r0
for__26:
        ; const t.5{r0}, 40
        ld   r0, #%00
        ld   r1, #%28
        ; lt t.4{r0}, c{r10}, t.5{r0}
        cp   r10, r0
        jr   lt, .true28
        jr   ne, .false28
        cp   r11, r1
        jr   uge, .false28
.true28:
        ld   r0, #1
        jr   .28
.false28:
        ld   r0, #0
.28:
        ; branch t.4{r0}, true, @for_26_body, @for_25_continue
        or   r0, r0
        jr   nz, for__26__body
        ; const t.8{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; add r{r8}, r{r8}, t.8{r0}
        add  r9, r1
        adc  r8, r0
for__25:
        ; const t.3{r0}, 20
        ld   r0, #%00
        ld   r1, #%14
        ; lt t.2{r0}, r{r8}, t.3{r0}
        cp   r8, r0
        jr   lt, .true29
        jr   ne, .false29
        cp   r9, r1
        jr   uge, .false29
.true29:
        ld   r0, #1
        jr   .29
.false29:
        ld   r0, #0
.29:
        ; branch t.2{r0}, true, @for_25_body, @clearField_ret
        or   r0, r0
        jr   nz, for__25__body
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
        ld   r8, r0
        ld   r9, r1
        ; move param.curr_c{r10}, curr_c{r2}
        ld   r10, r2
        ld   r11, r3
        ; const bombs{r12}, 40
        ld   r12, #%00
        ld   r13, #%28
        ; 175:2 for bombs > 0
        jr   for__27

for__27__body:
        ; call t.8{r0} = random[] -> i32
        call random
        ; const t.9{r4}, 20
        ld   r4, #%00
        ld   r5, #%00
        ld   r6, #%00
        ld   r7, #%14
        ; mod t.7{r0}, t.7{r0}, t.9{r4}
        Not supported yet: mul/div/mod for i32
        ; cast row{r0}(i16), t.7{r0}(i32)
        ld   r0, r2
        ld   r1, r3
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], row{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; call t.11{r0} = random[] -> i32
        call random
        ; const t.12{r4}, 40
        ld   r4, #%00
        ld   r5, #%00
        ld   r6, #%00
        ld   r7, #%28
        ; mod t.10{r0}, t.10{r0}, t.12{r4}
        Not supported yet: mul/div/mod for i32
        ; cast column{r2}(i16), t.10{r0}(i32)
        ld   r2, r2
        ld   r3, r3
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
        ; 179:4 logic or
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load row{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; move t.15{r2}, row{r0}
        ld   r2, r0
        ld   r3, r1
        ; addrof memVarAddr{r14}, row
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], row{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        ; sub t.15{r2}, t.15{r2}, param.curr_r{r8}
        sub  r3, r9
        sbc  r2, r8
        ; move t.15{r0}, t.15{r2}
        ld   r0, r2
        ld   r1, r3
        ; call t.14{r0} = abs@i16[t.15{r0}] -> i16
        call abs_Pi16
        ; const t.16{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; gt t.13{r14}, t.14{r0}, t.16{r2}
        cp   r0, r2
        jr   gt, .true30
        jr   ne, .false30
        cp   r1, r3
        jr   ule, .false30
.true30:
        ld   r14, #1
        jr   .30
.false30:
        ld   r14, #0
.30:
        ; branch t.13{r14}, true, @or_next_29, @or_2nd_29
        or   r14, r14
        jr   nz, or__next__29
        ; addrof memVarAddr{r14}, column
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load column{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; move t.18{r0}, column{r2}
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
        ; sub t.18{r0}, t.18{r0}, param.curr_c{r10}
        sub  r1, r11
        sbc  r0, r10
        ; call t.17{r0} = abs@i16[t.18{r0}] -> i16
        call abs_Pi16
        ; const t.19{r5}, 1
        ld   r5, #%00
        ld   r6, #%01
        ; gt t.13{r14}, t.17{r0}, t.19{r5}
        cp   r0, r5
        jr   gt, .true31
        jr   ne, .false31
        cp   r1, r6
        jr   ule, .false31
.true31:
        ld   r14, #1
        jr   .31
.false31:
        ld   r14, #0
.31:
or__next__29:
        ; branch t.13{r14}, false, @for_27_continue, @if_28_then
        or   r14, r14
        jr   z, for__27__continue
        ; const t.20{r4}, 1
        ld   r4, #%01
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
        ; call setCell@i16@i16@u8[row{r0}, column{r2}, t.20{r4}]
        call setCell_Pi16_Pi16_Pu8
for__27__continue:
        ; const t.21{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; sub bombs{r12}, bombs{r12}, t.21{r0}
        sub  r13, r1
        sbc  r12, r0
for__27:
        ; const t.6{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; gt t.5{r0}, bombs{r12}, t.6{r0}
        cp   r12, r0
        jr   gt, .true32
        jr   ne, .false32
        cp   r13, r1
        jr   ule, .false32
.true32:
        ld   r0, #1
        jr   .32
.false32:
        ld   r0, #0
.32:
        ; branch t.5{r0}, true, @for_27_body, @initField@i16@i16_ret
        or   r0, r0
        jr   nz, for__27__body
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

        ; void maybeRevealAround@i16@i16
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; var r (i16): SP+8
        ; var dc (i16): SP+10
        ; var c (i16): SP+12
maybeRevealAround_Pi16_Pi16:
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
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; move param.row{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; call t.8{r0} = getBombCountAround@i16@i16[param.row{r0}, param.column{r2}] -> u8
        call getBombCountAround_Pi16_Pi16
        ; const t.9{r12}, 0
        ld   r12, #%00
        ; notequals t.7{r12}, t.8{r0}, t.9{r12}
        cp   r0, r12
        jr   ne, .ne33
        ld   r12, #0  ; false
        jr   .33
.ne33:
        ld   r12, #1
.33:
        ; branch t.7{r12}, true, @maybeRevealAround@i16@i16_ret, @if_30_end
        or   r12, r12
        jr   nz, maybeRevealAround_Pi16_Pi16__ret
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
        ; move dc{r2}, dc{r4}
        ld   r2, r4
        ld   r3, r5
        jr   for__32

for__32__body:
        ; move dc{r4}, dc{r2}
        ld   r4, r2
        ld   r5, r3
        ; addrof memVarAddr{r14}, r
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load r{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        ; 193:4 if dr == 0 && dc == 0
        ; 193:16 logic and
        ; const t.15{r6}, 0
        ld   r6, #%00
        ld   r7, #%00
        ; equals t.14{r14}, dr{r12}, t.15{r6}
        cp   r12, r6
        jr   ne, .ne34
        cp   r13, r7
        jr   ne, .ne34
        ld   r14, #1  ; true
        jr   .34
.ne34:
        ld   r14, #0
.34:
        ; branch t.14{r14}, false, @and_next_34, @and_2nd_34
        or   r14, r14
        jr   z, and__next__34
        ; const t.16{r6}, 0
        ld   r6, #%00
        ld   r7, #%00
        ; equals t.14{r14}, dc{r4}, t.16{r6}
        cp   r4, r6
        jr   ne, .ne35
        cp   r5, r7
        jr   ne, .ne35
        ld   r14, #1  ; true
        jr   .35
.ne35:
        ld   r14, #0
.35:
and__next__34:
        ; branch t.14{r14}, false, @if_33_end, @no_critical_edge_17
        or   r14, r14
        jr   z, if__33__end
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
        ; call t.18{r0} = checkCellBounds@i16@i16[r{r0}, c{r2}] -> bool
        call checkCellBounds_Pi16_Pi16
        ; notlog t.17{r14}, t.18{r0}
        or   r0, r0
        ld   r14, #0  ; false
        jr   nz, .36
        ld   r14, #1  ; true
.36:
        ; branch t.17{r14}, true, @for_32_continue, @if_35_end
        or   r14, r14
        jr   nz, for__32__continue
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
        ; move cell{r14}, cell{r0}
        ld   r14, r0
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; move cell{r0}, cell{r14}
        ld   r0, r14
        ; call t.19{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; branch t.19{r0}, true, @for_32_continue, @if_36_end
        or   r0, r0
        jr   nz, for__32__continue
        ; const t.21{r5}, 2
        ld   r5, #%02
        ; move t.20{r4}, cell{r14}
        ld   r4, r14
        ; or t.20{r4}, t.20{r4}, t.21{r5}
        or   r4, r5
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
        ; call setCell@i16@i16@u8[r{r0}, c{r2}, t.20{r4}]
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
        ; const t.22{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; addrof memVarAddr{r14}, dc
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load dc{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        incw r14
        lde  r3, @rr14
        ; add dc{r2}, dc{r2}, t.22{r0}
        add  r3, r1
        adc  r2, r0
for__32:
        ; const t.13{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; lteq t.12{r0}, dc{r2}, t.13{r0}
        cp   r2, r0
        jr   le, .true37
        jr   ne, .false37
        cp   r3, r1
        jr   ugt, .false37
.true37:
        ld   r0, #1
        jr   .37
.false37:
        ld   r0, #0
.37:
        ; branch t.12{r0}, true, @for_32_body, @for_31_continue
        or   r0, r0
        jr   nz, for__32__body
        ; const t.23{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; add dr{r12}, dr{r12}, t.23{r0}
        add  r13, r1
        adc  r12, r0
for__31:
        ; const t.11{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; lteq t.10{r0}, dr{r12}, t.11{r0}
        cp   r12, r0
        jr   le, .true38
        jr   ne, .false38
        cp   r13, r1
        jr   ugt, .false38
.true38:
        ld   r0, #1
        jr   .38
.false38:
        ld   r0, #0
.38:
        ; branch t.10{r0}, true, @for_31_body, @maybeRevealAround@i16@i16_ret
        or   r0, r0
        jr   nz, for__31__body
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
        push r15
        ; begin initialize global variables
        ; const tmp.__random__{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%00
        ; end initialize global variables
        ; const t.6{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; addrof memVarAddr{r14}, __random__
        ld   r14, #hi(var__0)
        ld   r15, #lo(var__0)
        ; store [memVarAddr{r14}], tmp.__random__{r8}
        lde  @rr14, r8
        incw r14
        lde  @rr14, r9
        incw r14
        lde  @rr14, r10
        incw r14
        lde  @rr14, r11
        ; call initRandom@i32[t.6{r0}]
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
        ; 219:2 while true
        jr   while__37

if__38__then:
        ; 222:4 if printLeft([])
        ; call t.8{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.8{r0}, true, @if_39_then, @if_38_end
        or   r0, r0
        jr   nz, if__39__then
if__38__end:
        ; call chr{r0} = getChar[] -> i16
        call getChar
        ; 229:3 if chr == 27
        ; const t.11{r13}, 27
        ld   r13, #%00
        ld   r14, #%1b
        ; equals t.10{r13}, chr{r0}, t.11{r13}
        cp   r0, r13
        jr   ne, .ne39
        cp   r1, r14
        jr   ne, .ne39
        ld   r13, #1  ; true
        jr   .39
.ne39:
        ld   r13, #0
.39:
        ; branch t.10{r13}, true, @main_ret, @if_40_end
        or   r13, r13
        jr   nz, main__ret
        ; 234:3 if chr == -8120
        ; const t.13{r13}, -8120
        ld   r13, #%e0
        ld   r14, #%48
        ; equals t.12{r13}, chr{r0}, t.13{r13}
        cp   r0, r13
        jr   ne, .ne40
        cp   r1, r14
        jr   ne, .ne40
        ld   r13, #1  ; true
        jr   .40
.ne40:
        ld   r13, #0
.40:
        ; branch t.12{r13}, true, @if_41_then, @if_41_else
        or   r13, r13
        jr   nz, if__41__then
        ; 238:8 if chr == -8112
        ; const t.20{r13}, -8112
        ld   r13, #%e0
        ld   r14, #%50
        ; equals t.19{r13}, chr{r0}, t.20{r13}
        cp   r0, r13
        jr   ne, .ne41
        cp   r1, r14
        jr   ne, .ne41
        ld   r13, #1  ; true
        jr   .41
.ne41:
        ld   r13, #0
.41:
        ; branch t.19{r13}, false, @if_42_else, @if_42_then
        or   r13, r13
        jr   z, if__42__else
        jr   if__42__then

if__41__then:
        ; const t.16{r13}, 20
        ld   r13, #%00
        ld   r14, #%14
        ; add t.15{r11}, t.15{r11}, t.16{r13}
        add  r12, r14
        adc  r11, r13
        ; const t.17{r13}, 1
        ld   r13, #%00
        ld   r14, #%01
        ; sub t.14{r11}, t.14{r11}, t.17{r13}
        sub  r12, r14
        sbc  r11, r13
        ; const t.18{r13}, 20
        ld   r13, #%00
        ld   r14, #%14
        ; mod curr_r{r11}, curr_r{r11}, t.18{r13}
        ld   %12, r11
        ld   %13, r12
        ld   %14, r13
        ld   %15, r14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r11, %12
        ld   r12, %13
        jr   while__37

if__42__else:
        ; 242:8 if chr == -8117
        ; const t.25{r13}, -8117
        ld   r13, #%e0
        ld   r14, #%4b
        ; equals t.24{r13}, chr{r0}, t.25{r13}
        cp   r0, r13
        jr   ne, .ne42
        cp   r1, r14
        jr   ne, .ne42
        ld   r13, #1  ; true
        jr   .42
.ne42:
        ld   r13, #0
.42:
        ; branch t.24{r13}, false, @if_43_else, @if_43_then
        or   r13, r13
        jr   z, if__43__else
        jr   if__43__then

if__42__then:
        ; const t.22{r13}, 1
        ld   r13, #%00
        ld   r14, #%01
        ; add t.21{r11}, t.21{r11}, t.22{r13}
        add  r12, r14
        adc  r11, r13
        ; const t.23{r13}, 20
        ld   r13, #%00
        ld   r14, #%14
        ; mod curr_r{r11}, curr_r{r11}, t.23{r13}
        ld   %12, r11
        ld   %13, r12
        ld   %14, r13
        ld   %15, r14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r11, %12
        ld   r12, %13
        jr   while__37

if__43__else:
        ; 246:8 if chr == -8117
        ; const t.32{r13}, -8117
        ld   r13, #%e0
        ld   r14, #%4b
        ; equals t.31{r13}, chr{r0}, t.32{r13}
        cp   r0, r13
        jr   ne, .ne43
        cp   r1, r14
        jr   ne, .ne43
        ld   r13, #1  ; true
        jr   .43
.ne43:
        ld   r13, #0
.43:
        ; branch t.31{r13}, false, @if_44_else, @if_44_then
        or   r13, r13
        jr   z, if__44__else
        jr   if__44__then

if__43__then:
        ; const t.28{r13}, 40
        ld   r13, #%00
        ld   r14, #%28
        ; add t.27{r9}, t.27{r9}, t.28{r13}
        add  r10, r14
        adc  r9, r13
        ; const t.29{r13}, 1
        ld   r13, #%00
        ld   r14, #%01
        ; sub t.26{r9}, t.26{r9}, t.29{r13}
        sub  r10, r14
        sbc  r9, r13
        ; const t.30{r13}, 40
        ld   r13, #%00
        ld   r14, #%28
        ; mod curr_c{r9}, curr_c{r9}, t.30{r13}
        ld   %12, r9
        ld   %13, r10
        ld   %14, r13
        ld   %15, r14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r9, %12
        ld   r10, %13
        jr   while__37

if__44__else:
        ; 250:8 if chr == -8115
        ; const t.39{r13}, -8115
        ld   r13, #%e0
        ld   r14, #%4d
        ; equals t.38{r13}, chr{r0}, t.39{r13}
        cp   r0, r13
        jr   ne, .ne44
        cp   r1, r14
        jr   ne, .ne44
        ld   r13, #1  ; true
        jr   .44
.ne44:
        ld   r13, #0
.44:
        ; branch t.38{r13}, false, @if_45_else, @if_45_then
        or   r13, r13
        jr   z, if__45__else
        jr   if__45__then

if__44__then:
        ; const t.35{r13}, 40
        ld   r13, #%00
        ld   r14, #%28
        ; add t.34{r9}, t.34{r9}, t.35{r13}
        add  r10, r14
        adc  r9, r13
        ; const t.36{r13}, 1
        ld   r13, #%00
        ld   r14, #%01
        ; sub t.33{r9}, t.33{r9}, t.36{r13}
        sub  r10, r14
        sbc  r9, r13
        ; const t.37{r13}, 40
        ld   r13, #%00
        ld   r14, #%28
        ; mod curr_c{r9}, curr_c{r9}, t.37{r13}
        ld   %12, r9
        ld   %13, r10
        ld   %14, r13
        ld   %15, r14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r9, %12
        ld   r10, %13
        jr   while__37

if__45__else:
        ; 254:8 if chr == 32
        ; const t.44{r13}, 32
        ld   r13, #%00
        ld   r14, #%20
        ; equals t.43{r13}, chr{r0}, t.44{r13}
        cp   r0, r13
        jr   ne, .ne45
        cp   r1, r14
        jr   ne, .ne45
        ld   r13, #1  ; true
        jr   .45
.ne45:
        ld   r13, #0
.45:
        ; branch t.43{r13}, false, @if_46_else, @if_46_then
        or   r13, r13
        jr   z, if__46__else
        jr   if__46__then

if__45__then:
        ; const t.41{r13}, 1
        ld   r13, #%00
        ld   r14, #%01
        ; add t.40{r9}, t.40{r9}, t.41{r13}
        add  r10, r14
        adc  r9, r13
        ; const t.42{r13}, 40
        ld   r13, #%00
        ld   r14, #%28
        ; mod curr_c{r9}, curr_c{r9}, t.42{r13}
        ld   %12, r9
        ld   %13, r10
        ld   %14, r13
        ld   %15, r14
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r9, %12
        ld   r10, %13
        jr   while__37

if__46__else:
        ; 263:8 if chr == 13
        ; const t.50{r13}, 13
        ld   r13, #%00
        ld   r14, #%0d
        ; equals t.49{r13}, chr{r0}, t.50{r13}
        cp   r0, r13
        jr   ne, .ne46
        cp   r1, r14
        jr   ne, .ne46
        ld   r13, #1  ; true
        jr   .46
.ne46:
        ld   r13, #0
.46:
        ; branch t.49{r13}, false, @while_37, @if_49_then
        or   r13, r13
        jr   z, while__37
        jr   if__49__then

if__46__then:
        ; 255:4 if !needsInitialize
        ; notlog t.45{r13}, needsInitialize{r8}
        or   r8, r8
        ld   r13, #0  ; false
        jr   nz, .47
        ld   r13, #1  ; true
.47:
        ; branch t.45{r13}, false, @while_37, @if_47_then
        or   r13, r13
        jr   z, while__37
        jr   if__47__then

if__49__then:
        ; branch needsInitialize{r8}, false, @if_50_end, @if_50_then
        or   r8, r8
        jr   z, if__50__end
        jr   if__50__then

if__47__then:
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
        ; 257:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=257:17]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.47{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; notlog t.46{r14}, t.47{r0}
        or   r0, r0
        ld   r14, #0  ; false
        jr   nz, .48
        ld   r14, #1  ; true
.48:
        ; branch t.46{r14}, false, @while_37, @if_48_then
        or   r14, r14
        jr   z, while__37
        jr   if__48__then

if__50__then:
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
        jr   if__50__end

if__48__then:
        ; const t.48{r14}, 4
        ld   r14, #%04
        ; xor cell{r13}, cell{r13}, t.48{r14}
        xor  r13, r14
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

if__50__end:
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
        ; 269:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=269:16]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.52{r0} = isOpen@u8[cell{r0}] -> bool
        call isOpen_Pu8
        ; notlog t.51{r14}, t.52{r0}
        or   r0, r0
        ld   r14, #0  ; false
        jr   nz, .49
        ld   r14, #1  ; true
.49:
        ; branch t.51{r14}, false, @if_51_end, @if_51_then
        or   r14, r14
        jr   z, if__51__end
        ; const t.54{r14}, 2
        ld   r14, #%02
        ; move t.53{r4}, cell{r13}
        ld   r4, r13
        ; or t.53{r4}, t.53{r4}, t.54{r14}
        or   r4, r14
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call setCell@i16@i16@u8[curr_r{r0}, curr_c{r2}, t.53{r4}]
        call setCell_Pi16_Pi16_Pu8
if__51__end:
        ; 272:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=272:15]])
        ; move cell{r0}, cell{r13}
        ld   r0, r13
        ; call t.55{r0} = isBomb@u8[cell{r0}] -> bool
        call isBomb_Pu8
        ; branch t.55{r0}, true, @if_52_then, @if_52_end
        or   r0, r0
        jr   nz, if__52__then
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
        ; 221:3 if !needsInitialize
        ; notlog t.7{r13}, needsInitialize{r8}
        or   r8, r8
        ld   r13, #0  ; false
        jr   nz, .50
        ld   r13, #1  ; true
.50:
        ; branch t.7{r13}, false, @if_38_end, @if_38_then
        or   r13, r13
        jr   z, if__38__end
        jr   if__38__then

if__39__then:
        ; const t.9{r0}, [string-2]
        ld   r0, #hi(string__2)
        ld   r1, #lo(string__2)
        ; call printString@@u8[t.9{r0}]
        call printString_P_Pu8
        jr   main__ret

if__52__then:
        ; move curr_r{r0}, curr_r{r11}
        ld   r0, r11
        ld   r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld   r2, r9
        ld   r3, r10
        ; call printField@i16@i16[curr_r{r0}, curr_c{r2}]
        call printField_Pi16_Pi16
        ; const t.56{r0}, [string-3]
        ld   r0, #hi(string__3)
        ld   r1, #lo(string__3)
        ; call printString@@u8[t.56{r0}]
        call printString_P_Pu8
main__ret:
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

        ; variable 0: __random__ (i32/4)
var__0:
        .data %00 %00 %00 %00
        ; variable 1: field[] (u8*/1600)
var__1:
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

string__0:
        .data "|" %0a %00
string__1:
        .data "Left: " %00
string__2:
        .data " You've cleaned the field!" %00
string__3:
        .data "boom! you've lost" %00

