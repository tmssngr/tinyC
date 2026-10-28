        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; i32 tileValue@u8
        ; arg exponent (u8): r0
tileValue_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; const value.1{r4}, 1
        ld   r4, #%00
        ld   r5, #%00
        ld   r6, #%00
        ld   r7, #%01
        ; const index.1{r8}, 0
        ld   r8, #%00
        ; 40:2 for index < exponent
        jr   for__1

for__1__body:
        ; shiftleft value.3{r4}, 1
        add r7, r7
        adc r6, r6
        adc r5, r5
        adc r4, r4
        ; add index.3{r8}, 1
        inc  r8
for__1:
        ; branch index.2{r8} lt param.exponent{r0}: for_1_body
        cp   r8, r0
        jr   ult, for__1__body
        ; 43:9 return value
        ; move value.2{r0}, value.2{r4}
        ld   r0, r4
        ld   r1, r5
        ld   r2, r6
        ld   r3, r7
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void spawnTile
spawnTile:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const emptyCount.1{r8}, 0
        ld   r8, #%00
        ; const index.1{r9}, 0
        ld   r9, #%00
        ; 48:2 for index < 16
        jr   for__2

for__2__body:
        ; 49:3 if [...] == 0
        ; cast t.7.1{r10}(i16), index.2{r9}(u8)
        ld   r11, r9
        ld   r10, #0
        ; addrof t.6.1{r12}, tiles
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.6.2{r12}, t.7.1{r10}
        add  r13, r11
        adc  r12, r10
        ; load t.5.1{r10}, [t.6.2{r12}]
        lde  r10, @rr12
        ; branch t.5.1{r10} notequals 0: for_2_continue
        cp   r10, #%00
        jr   ne, for__2__continue
        ; add emptyCount.4{r8}, 1
        inc  r8
for__2__continue:
        ; add index.6{r9}, 1
        inc  r9
for__2:
        ; branch index.2{r9} lt 16: for_2_body
        cp   r9, #%10
        jr   ult, for__2__body
        ; branch emptyCount.2{r8} equals 0: spawnTile_ret
        cp   r8, #%00
        jr   eq, spawnTile__ret
        ; call t.9.1{r0} = random16[] -> i16
        call random16
        ; cast t.10.1{r8}(i16), emptyCount.2{r8}(u8)
        ld   r9, r8
        ld   r8, #0
        ; move t.8.1{r10}, t.9.1{r0}
        ld   r11, r1
        ld   r10, r0
        ; mod t.8.1{r10}, t.10.1{r8}
        ld   %12, r10
        ld   %13, r11
        ld   %14, r8
        ld   %15, r9
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r10, %12
        ld   r11, %13
        ; cast chosen.1{r8}(u8), t.8.1{r10}(i16)
        ld   r8, r11
        ; const index.3{r9}, 0
        ld   r9, #%00
        ; 58:2 for index < 16
        jr   for__5

for__5__body:
        ; 59:3 if [...] != 0
        ; cast t.13.1{r10}(i16), index.4{r9}(u8)
        ld   r11, r9
        ld   r10, #0
        ; addrof t.12.1{r12}, tiles
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.12.2{r12}, t.13.1{r10}
        add  r13, r11
        adc  r12, r10
        ; load t.11.1{r10}, [t.12.2{r12}]
        lde  r10, @rr12
        ; branch t.11.1{r10} notequals 0: for_5_continue
        cp   r10, #%00
        jr   ne, for__5__continue
        ; branch chosen.2{r8} equals 0: if_7_then
        cp   r8, #%00
        jr   eq, if__7__then
        ; sub chosen.4{r8}, 1
        dec  r8
for__5__continue:
        ; add index.8{r9}, 1
        inc  r9
for__5:
        ; branch index.4{r9} gteq 16: spawnTile_ret, for_5_body
        cp   r9, #%10
        jr   uge, spawnTile__ret
        jr   for__5__body

if__7__then:
        ; const tile.1{r8}, 1
        ld   r8, #%01
        ; 64:4 if random16([]) % 10 == 0
        ; call t.15.1{r0} = random16[] -> i16
        call random16
        ; mod t.14.1{r0}, 10
        ld   %12, r0
        ld   %13, r1
        ld   %14, #%00
        ld   %15, #%0a
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; branch t.14.1{r0} equals 0: if_8_then
        cp   r1, #%00
        jr   ne, .notEquals1
        cp   r0, #%00
        jr   eq, if__8__then
.notEquals1:
        ; move tile.2{r0}, tile.1{r8}
        ld   r0, r8
        jr   if__8__end

if__8__then:
        ; const tile.3{r0}, 2
        ld   r0, #%02
if__8__end:
        ; cast t.17.1{r1}(i16), index.4{r9}(u8)
        ld   r2, r9
        ld   r1, #0
        ; addrof t.16.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.16.2{r4}, t.17.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.16.2{r4}], tile.2{r0}
        lde  @rr4, r0
        ; 68:4 return
spawnTile__ret:
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; bool slideLine@u8@u8
        ; arg first (u8): r0
        ; arg step (u8): r1
        ; var position.2 (u8): SP+8
        ; var tile.1 (u8): SP+9
        ; var merged.2 (bool): SP+10
        ; var t.19.1 (i32): SP+11
slideLine_Pu8_Pu8:
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
        ; move param.first{r8}, first{r0}
        ld   r8, r0
        ; move param.step{r9}, step{r1}
        ld   r9, r1
        ; move source.1{r10}, param.first{r8}
        ld   r10, r8
        ; move target.1{r11}, param.first{r8}
        ld   r11, r8
        ; const previousMerged.1{r12}, 0
        ld   r12, #%00
        ; const moved.1{r13}, 0
        ld   r13, #%00
        ; const position.1{r1}, 0
        ld   r1, #%00
        ; 79:2 for position < 4
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], position.2{r1}
        lde  @rr14, r1
        ; move position.2{r2}, position.2{r1}
        ld   r2, r1
        jr   for__9

for__9__body:
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], position.2{r2}
        lde  @rr14, r2
        ; cast t.13.1{r1}(i16), source.2{r10}(u8)
        ld   r2, r10
        ld   r1, #0
        ; addrof sourceTile.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add sourceTile.2{r4}, t.13.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load tile.1{r1}, [sourceTile.2{r4}]
        lde  r1, @rr4
        ; 82:3 if tile != 0
        ; branch tile.1{r1} equals 0: if_10_end
        cp   r1, #%00
        jr   eq, if__10__end
        ; const t.14.1{r2}, 0
        ld   r2, #%00
        ; store [sourceTile.2{r4}], t.14.1{r2}
        lde  @rr4, r2
        ; const merged.1{r2}, 0
        ld   r2, #%00
        ; 85:4 if target != first && !previousMerged
        ; branch target.2{r11} notequals param.first{r8}: and_12
        cp   r11, r8
        jr   ne, and__12
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r1}
        lde  @rr14, r1
        ; move merged.2{r1}, merged.2{r2}
        ld   r1, r2
        jr   if__11__end

and__12:
        ; branch previousMerged.2{r12} equals 0: if_11_then
        cp   r12, #%00
        jr   eq, if__11__then
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r1}
        lde  @rr14, r1
        ; move merged.2{r1}, merged.2{r2}
        ld   r1, r2
        jr   if__11__end

if__11__then:
        ; move previous.1{r3}, target.2{r11}
        ld   r3, r11
        ; sub previous.1{r3}, param.step{r9}
        sub  r3, r9
        ; cast t.15.1{r3}(i16), previous.1{r3}(u8)
        ld   r4, r3
        ld   r3, #0
        ; addrof previousTile.1{r6}, tiles
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add previousTile.2{r6}, t.15.1{r3}
        add  r7, r4
        adc  r6, r3
        ; 88:5 if *previousTile == tile
        ; load t.16.1{r3}, [previousTile.2{r6}]
        lde  r3, @rr6
        ; branch t.16.1{r3} equals tile.1{r1}: if_13_then
        cp   r3, r1
        jr   eq, if__13__then
        ; addrof memVarAddr{r14}, merged.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], merged.2{r2}
        lde  @rr14, r2
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, merged.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; move merged.2{r1}, merged.2{r2}
        ld   r1, r2
        jr   if__11__end

if__13__then:
        ; move nextTile.1{r12}, tile.1{r1}
        ld   r12, r1
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r1}
        lde  @rr14, r1
        ; add nextTile.1{r12}, 1
        inc  r12
        ; store [previousTile.2{r6}], nextTile.1{r12}
        lde  @rr6, r12
        ; addrof a.18.1{r2}, score
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; load t.19.1{r4}, [a.18.1{r2}]
        lde  r4, @rr2
        incw r2
        lde  r5, @rr2
        incw r2
        lde  r6, @rr2
        incw r2
        lde  r7, @rr2
        sub  r3, #3
        sbc  r2, #0
        ; addrof memVarAddr{r14}, t.19.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.19.1{r4}
        lde  @rr14, r4
        incw r14
        lde  @rr14, r5
        incw r14
        lde  @rr14, r6
        incw r14
        lde  @rr14, r7
        sub  r15, #3
        sbc  r14, #0
        ; move nextTile.1{r0}, nextTile.1{r12}
        ld   r0, r12
        ; call t.20.1{r0} = tileValue@u8[nextTile.1{r0}] -> i32
        call tileValue_Pu8
        ; load t.19.1{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        incw r14
        lde  r5, @rr14
        incw r14
        lde  r6, @rr14
        incw r14
        lde  r7, @rr14
        sub  r15, #3
        sbc  r14, #0
        ; add t.17.1{r4}, t.20.1{r0}
        add  r7, r3
        adc  r6, r2
        adc  r5, r1
        adc  r4, r0
        ; addrof a.21.1{r2}, score
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; store [a.21.1{r2}], t.17.1{r4}
        lde  @rr2, r4
        incw r2
        lde  @rr2, r5
        incw r2
        lde  @rr2, r6
        incw r2
        lde  @rr2, r7
        sub  r3, #3
        sbc  r2, #0
        ; 92:6 if nextTile == 11
        ; branch nextTile.1{r12} notequals 11: if_14_end
        cp   r12, #%0b
        jr   ne, if__14__end
        ; const t.22.1{r1}, 1
        ld   r1, #%01
        ; addrof a.23.1{r2}, gameState
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.23.1{r2}], t.22.1{r1}
        lde  @rr2, r1
if__14__end:
        ; const merged.3{r1}, 1
        ld   r1, #%01
        ; const previousMerged.6{r2}, 1
        ld   r2, #%01
        ; const moved.7{r3}, 1
        ld   r3, #%01
        ; move previousMerged.4{r12}, previousMerged.6{r2}
        ld   r12, r2
        ; move moved.4{r13}, moved.7{r3}
        ld   r13, r3
if__11__end:
        ; branch merged.2{r1} notequals 0: if_10_end
        cp   r1, #%00
        jr   ne, if__10__end
        ; cast t.25.1{r1}(i16), target.2{r11}(u8)
        ld   r2, r11
        ld   r1, #0
        ; addrof t.24.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.24.2{r4}, t.25.1{r1}
        add  r5, r2
        adc  r4, r1
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load tile.1{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; store [t.24.2{r4}], tile.1{r1}
        lde  @rr4, r1
        ; 102:5 if target != source
        ; branch target.2{r11} notequals source.2{r10}: if_16_then
        cp   r11, r10
        jr   ne, if__16__then
        ; move moved.5{r1}, moved.4{r13}
        ld   r1, r13
        jr   if__16__end

if__16__then:
        ; const moved.6{r1}, 1
        ld   r1, #%01
if__16__end:
        ; move target.7{r2}, target.2{r11}
        ld   r2, r11
        ; add target.7{r2}, param.step{r9}
        add  r2, r9
        ; const previousMerged.5{r3}, 0
        ld   r3, #%00
        ; move target.3{r11}, target.7{r2}
        ld   r11, r2
        ; move previousMerged.3{r12}, previousMerged.5{r3}
        ld   r12, r3
        ; move moved.3{r13}, moved.5{r1}
        ld   r13, r1
if__10__end:
        ; move source.4{r1}, source.2{r10}
        ld   r1, r10
        ; add source.4{r1}, param.step{r9}
        add  r1, r9
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load position.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; add position.5{r2}, 1
        inc  r2
        ; move source.2{r10}, source.4{r1}
        ld   r10, r1
for__9:
        ; branch position.2{r2} lt 4: for_9_body
        cp   r2, #%04
        jr   ult, for__9__body
        ; 111:9 return moved
        ; move moved.2{r0}, moved.2{r13}
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
        ld   %30, SPH
        ld   %31, SPL
        add  %31, #%07
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; bool slide@u8
        ; arg direction (u8): r0
slide_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        ; move param.direction{r8}, direction{r0}
        ld   r8, r0
        ; const moved.1{r9}, 0
        ld   r9, #%00
        ; const line.1{r10}, 0
        ld   r10, #%00
        ; 116:2 for line < 4
        jr   for__17

for__17__body:
        ; move first.1{r11}, line.2{r10}
        ld   r11, r10
        ; shiftleft first.1{r11}, 2
        add r11, r11
        add r11, r11
        ; const step.1{r12}, 1
        ld   r12, #%01
        ; 119:3 if direction == 1
        ; branch param.direction{r8} equals 1: if_18_then
        cp   r8, #%01
        jr   eq, if__18__then
        ; branch param.direction{r8} notequals 2: if_19_else, if_19_then
        cp   r8, #%02
        jr   ne, if__19__else
        jr   if__19__then

if__18__then:
        ; add first.2{r11}, 3
        add  r11, #%03
        ; const step.2{r12}, 255
        ld   r12, #%ff
        ; move first.3{r0}, first.2{r11}
        ld   r0, r11
        ; move step.3{r1}, step.2{r12}
        ld   r1, r12
        jr   if__18__end

if__19__else:
        ; branch param.direction{r8} notequals 3: slide@u8.no_critical_edge_13, if_20_then
        cp   r8, #%03
        jr   ne, slide_Pu8_2eno__critical__edge__13
        jr   if__20__then

if__19__then:
        ; move first.4{r11}, line.2{r10}
        ld   r11, r10
        ; const step.4{r12}, 4
        ld   r12, #%04
        ; move first.3{r0}, first.4{r11}
        ld   r0, r11
        ; move step.3{r1}, step.4{r12}
        ld   r1, r12
        jr   if__18__end

slide_Pu8_2eno__critical__edge__13:
        ; move first.3{r0}, first.1{r11}
        ld   r0, r11
        ; move step.3{r1}, step.1{r12}
        ld   r1, r12
        jr   if__18__end

if__20__then:
        ; move first.5{r11}, line.2{r10}
        ld   r11, r10
        ; add first.5{r11}, 12
        add  r11, #%0c
        ; const step.5{r12}, 252
        ld   r12, #%fc
        ; move first.3{r0}, first.5{r11}
        ld   r0, r11
        ; move step.3{r1}, step.5{r12}
        ld   r1, r12
if__18__end:
        ; 131:3 if slideLine@u8@u8([ExprVarAccess[varName=first, index=3, scope=function, type=u8, varIsArray=false, location=131:17], ExprVarAccess[varName=step, index=4, scope=function, type=u8, varIsArray=false, location=131:24]])
        ; call t.5.1{r0} = slideLine@u8@u8[first.3{r0}, step.3{r1}] -> bool
        call slideLine_Pu8_Pu8
        ; branch t.5.1{r0} notequals 0: if_21_then
        cp   r0, #%00
        jr   ne, if__21__then
        ; move moved.4{r1}, moved.2{r9}
        ld   r1, r9
        jr   for__17__continue

if__21__then:
        ; const moved.5{r1}, 1
        ld   r1, #%01
for__17__continue:
        ; move line.5{r2}, line.2{r10}
        ld   r2, r10
        ; add line.5{r2}, 1
        inc  r2
        ; move moved.2{r9}, moved.4{r1}
        ld   r9, r1
        ; move line.2{r10}, line.5{r2}
        ld   r10, r2
for__17:
        ; branch line.2{r10} lt 4: for_17_body
        cp   r10, #%04
        jr   ult, for__17__body
        ; 135:9 return moved
        ; move moved.2{r0}, moved.2{r9}
        ld   r0, r9
        ; restore clobbered non-volatile registers
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; bool canMove
canMove:
        ; const index.1{r1}, 0
        ld   r1, #%00
        ; 139:2 for index < 16
        jr   for__22

for__22__body:
        ; cast t.3.1{r2}(i16), index.2{r1}(u8)
        ld   r3, r1
        ld   r2, #0
        ; addrof t.2.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.2.2{r4}, t.3.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load tile.1{r2}, [t.2.2{r4}]
        lde  r2, @rr4
        ; 141:3 if tile == 0
        ; branch tile.1{r2} equals 0: if_23_then
        cp   r2, #%00
        jr   eq, if__23__then
        ; 144:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r3}, index.2{r1}
        ld   r3, r1
        ; and t.4.1{r3}, 3
        and  r3, #%03
        ; branch t.4.1{r3} equals 3: if_24_end
        cp   r3, #%03
        jr   eq, if__24__end
        ; move t.8.1{r3}, index.2{r1}
        ld   r3, r1
        ; add t.8.1{r3}, 1
        inc  r3
        ; cast t.7.1{r3}(i16), t.8.1{r3}(u8)
        ld   r4, r3
        ld   r3, #0
        ; addrof t.6.1{r6}, tiles
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.6.2{r6}, t.7.1{r3}
        add  r7, r4
        adc  r6, r3
        ; load t.5.1{r3}, [t.6.2{r6}]
        lde  r3, @rr6
        ; branch t.5.1{r3} equals tile.1{r2}: if_24_then, if_24_end
        cp   r3, r2
        jr   eq, if__24__then
if__24__end:
        ; branch index.2{r1} gteq 12: for_22_continue
        cp   r1, #%0c
        jr   uge, for__22__continue
        ; move t.12.1{r3}, index.2{r1}
        ld   r3, r1
        ; add t.12.1{r3}, 4
        add  r3, #%04
        ; cast t.11.1{r3}(i16), t.12.1{r3}(u8)
        ld   r4, r3
        ld   r3, #0
        ; addrof t.10.1{r6}, tiles
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.10.2{r6}, t.11.1{r3}
        add  r7, r4
        adc  r6, r3
        ; load t.9.1{r3}, [t.10.2{r6}]
        lde  r3, @rr6
        ; branch t.9.1{r3} equals tile.1{r2}: if_26_then, for_22_continue
        cp   r3, r2
        jr   eq, if__26__then
for__22__continue:
        ; add index.5{r1}, 1
        inc  r1
for__22:
        ; branch index.2{r1} lt 16: for_22_body
        cp   r1, #%10
        jr   ult, for__22__body
        ; const {r0}, 0
        ld   r0, #%00
        jr   canMove__ret

if__23__then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove__ret

if__24__then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove__ret

if__26__then:
        ; const {r0}, 1
        ld   r0, #%01
canMove__ret:
        ret

        ; void printTile@u8
        ; arg exponent (u8): r0
printTile_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; move param.exponent{r8}, exponent{r0}
        ld   r8, r0
        ; branch param.exponent{r8} equals 0: if_28_then
        cp   r8, #%00
        jr   eq, if__28__then
        ; branch param.exponent{r8} notequals 1: if_29_else, if_29_then
        cp   r8, #%01
        jr   ne, if__29__else
        jr   if__29__then

if__28__then:
        ; const t.1.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.1.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__29__else:
        ; branch param.exponent{r8} notequals 2: if_30_else, if_30_then
        cp   r8, #%02
        jr   ne, if__30__else
        jr   if__30__then

if__29__then:
        ; const t.2.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.2.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__30__else:
        ; branch param.exponent{r8} notequals 3: if_31_else, if_31_then
        cp   r8, #%03
        jr   ne, if__31__else
        jr   if__31__then

if__30__then:
        ; const t.3.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.3.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__31__else:
        ; branch param.exponent{r8} notequals 4: if_32_else, if_32_then
        cp   r8, #%04
        jr   ne, if__32__else
        jr   if__32__then

if__31__then:
        ; const t.4.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.4.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__32__else:
        ; branch param.exponent{r8} notequals 5: if_33_else, if_33_then
        cp   r8, #%05
        jr   ne, if__33__else
        jr   if__33__then

if__32__then:
        ; const t.5.1{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString@@u8[t.5.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__33__else:
        ; branch param.exponent{r8} notequals 6: if_34_else, if_34_then
        cp   r8, #%06
        jr   ne, if__34__else
        jr   if__34__then

if__33__then:
        ; const t.6.1{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString@@u8[t.6.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__34__else:
        ; branch param.exponent{r8} notequals 7: if_35_else, if_35_then
        cp   r8, #%07
        jr   ne, if__35__else
        jr   if__35__then

if__34__then:
        ; const t.7.1{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString@@u8[t.7.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__35__else:
        ; branch param.exponent{r8} notequals 8: if_36_else, if_36_then
        cp   r8, #%08
        jr   ne, if__36__else
        jr   if__36__then

if__35__then:
        ; const t.8.1{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
        ; call printString@@u8[t.8.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__36__else:
        ; branch param.exponent{r8} notequals 9: if_37_else, if_37_then
        cp   r8, #%09
        jr   ne, if__37__else
        jr   if__37__then

if__36__then:
        ; const t.9.1{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString@@u8[t.9.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__37__else:
        ; branch param.exponent{r8} notequals 10: if_38_else, if_38_then
        cp   r8, #%0a
        jr   ne, if__38__else
        jr   if__38__then

if__37__then:
        ; const t.10.1{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString@@u8[t.10.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__38__else:
        ; branch param.exponent{r8} notequals 11: if_39_else, if_39_then
        cp   r8, #%0b
        jr   ne, if__39__else
        jr   if__39__then

if__38__then:
        ; const t.11.1{r0}, [string-10]
        ld   r0, #hi(string_10)
        ld   r1, #lo(string_10)
        ; call printString@@u8[t.11.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__39__else:
        ; const t.13.1{r0}, [string-12]
        ld   r0, #hi(string_12)
        ld   r1, #lo(string_12)
        ; call printString@@u8[t.13.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__39__then:
        ; const t.12.1{r0}, [string-11]
        ld   r0, #hi(string_11)
        ld   r1, #lo(string_11)
        ; call printString@@u8[t.12.1{r0}]
        call printString_P_Pu8
printTile_Pu8__ret:
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void drawTileAt@i16@i16@u8
        ; arg row (i16): r0
        ; arg column (i16): r2
        ; arg exponent (u8): r4
drawTileAt_Pi16_Pi16_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        ; move param.row{r8}, row{r0}
        ld   r9, r1
        ld   r8, r0
        ; move param.column{r10}, column{r2}
        ld   r11, r3
        ld   r10, r2
        ; move param.exponent{r12}, exponent{r4}
        ld   r12, r4
        ; branch param.exponent{r12} equals 0: drawTileAt@i16@i16@u8_ret
        cp   r12, #%00
        jr   eq, drawTileAt_Pi16_Pi16_Pu8__ret
        ; call setCursor@i16@i16[param.row{r0}, param.column{r2}]
        call setCursor_Pi16_Pi16
        ; const t.3.1{r0}, [string-13]
        ld   r0, #hi(string_13)
        ld   r1, #lo(string_13)
        ; call printString@@u8[t.3.1{r0}]
        call printString_P_Pu8
        ; move t.4.1{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; add t.4.1{r0}, 1
        incw r0
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; call setCursor@i16@i16[t.4.1{r0}, param.column{r2}]
        call setCursor_Pi16_Pi16
        ; const arg.3.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.3.0{r0}]
        call printChar_Pu8
        ; move param.exponent{r0}, param.exponent{r12}
        ld   r0, r12
        ; call printTile@u8[param.exponent{r0}]
        call printTile_Pu8
        ; const arg.5.0{r0}, 124
        ld   r0, #%7c
        ; call printChar@u8[arg.5.0{r0}]
        call printChar_Pu8
        ; move t.5.1{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; add t.5.1{r0}, 2
        add  r1, #%02
        adc  r0, #%00
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; call setCursor@i16@i16[t.5.1{r0}, param.column{r2}]
        call setCursor_Pi16_Pi16
        ; const t.6.1{r0}, [string-13]
        ld   r0, #hi(string_13)
        ld   r1, #lo(string_13)
        ; call printString@@u8[t.6.1{r0}]
        call printString_P_Pu8
drawTileAt_Pi16_Pi16_Pu8__ret:
        ; restore clobbered non-volatile registers
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void drawFrame
drawFrame:
        ; const arg.0.0{r0}, 12
        ld   r0, #%0c
        ; call printChar@u8[arg.0.0{r0}]
        call printChar_Pu8
        ; const arg.1.0{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; const arg.1.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.1.0{r0}, arg.1.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.0.1{r0}, [string-14]
        ld   r0, #hi(string_14)
        ld   r1, #lo(string_14)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ret

        ; void clearBoard
clearBoard:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const row.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ; 219:2 for row < 15
        jr   for__41

for__41__body:
        ; move t.1.1{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add t.1.1{r0}, 3
        add  r1, #%03
        adc  r0, #%00
        ; const arg.0.1{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; call setCursor@i16@i16[t.1.1{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.2.1{r0}, [string-15]
        ld   r0, #hi(string_15)
        ld   r1, #lo(string_15)
        ; call printString@@u8[t.2.1{r0}]
        call printString_P_Pu8
        ; move row.3{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add row.3{r0}, 1
        incw r0
        ; move row.2{r8}, row.3{r0}
        ld   r9, r1
        ld   r8, r0
for__41:
        ; branch row.2{r8} lt 15: for_41_body
        cp   r8, #%00
        jr   lt, for__41__body
        jr   ne, .lt2
        cp   r9, #%0f
        jr   ult, for__41__body
.lt2:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void drawBoard
        ; var boardColumn.2 (u8): SP+8
drawBoard:
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
        ; call clearBoard[]
        call clearBoard
        ; const index.1{r8}, 0
        ld   r8, #%00
        ; const row.1{r9}, 3
        ld   r9, #%00
        ld   r10, #%03
        ; const boardRow.1{r11}, 0
        ld   r11, #%00
        ; 229:2 for boardRow < 4
        jr   for__42

for__42__body:
        ; const column.1{r12}, 1
        ld   r12, #%00
        ld   r13, #%01
        ; const boardColumn.1{r5}, 0
        ld   r5, #%00
        ; 231:3 for boardColumn < 4
        ; addrof memVarAddr{r14}, boardColumn.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], boardColumn.2{r5}
        lde  @rr14, r5
        ; move boardColumn.2{r3}, boardColumn.2{r5}
        ld   r3, r5
        jr   for__43

for__43__body:
        ; addrof memVarAddr{r14}, boardColumn.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], boardColumn.2{r3}
        lde  @rr14, r3
        ; cast t.7.1{r5}(i16), index.3{r8}(u8)
        ld   r6, r8
        ld   r5, #0
        ; addrof t.6.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.6.2{r2}, t.7.1{r5}
        add  r3, r6
        adc  r2, r5
        ; load t.5.1{r4}, [t.6.2{r2}]
        lde  r4, @rr2
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ld   r1, r10
        ; move column.2{r2}, column.2{r12}
        ld   r2, r12
        ld   r3, r13
        ; call drawTileAt@i16@i16@u8[row.2{r0}, column.2{r2}, t.5.1{r4}]
        call drawTileAt_Pi16_Pi16_Pu8
        ; move index.4{r0}, index.3{r8}
        ld   r0, r8
        ; add index.4{r0}, 1
        inc  r0
        ; move column.3{r1}, column.2{r12}
        ld   r1, r12
        ld   r2, r13
        ; add column.3{r1}, 9
        add  r2, #%09
        adc  r1, #%00
        ; load boardColumn.2{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        ; add boardColumn.3{r3}, 1
        inc  r3
        ; move index.3{r8}, index.4{r0}
        ld   r8, r0
        ; move column.2{r12}, column.3{r1}
        ld   r13, r2
        ld   r12, r1
for__43:
        ; branch boardColumn.2{r3} lt 4: for_43_body
        cp   r3, #%04
        jr   ult, for__43__body
        ; move row.4{r0}, row.2{r9}
        ld   r0, r9
        ld   r1, r10
        ; add row.4{r0}, 4
        add  r1, #%04
        adc  r0, #%00
        ; move boardRow.4{r2}, boardRow.2{r11}
        ld   r2, r11
        ; add boardRow.4{r2}, 1
        inc  r2
        ; move row.2{r9}, row.4{r0}
        ld   r10, r1
        ld   r9, r0
        ; move boardRow.2{r11}, boardRow.4{r2}
        ld   r11, r2
for__42:
        ; branch boardRow.2{r11} lt 4: for_42_body
        cp   r11, #%04
        jr   ult, for__42__body
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
        ret

        ; void drawScore
drawScore:
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
        ; const t.0.1{r0}, [string-16]
        ld   r0, #hi(string_16)
        ld   r1, #lo(string_16)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ; addrof a.1.1{r8}, score
        ld   r8, #hi(var_1)
        ld   r9, #lo(var_1)
        ; load t.2.1{r0}, [a.1.1{r8}]
        lde  r0, @rr8
        incw r8
        lde  r1, @rr8
        incw r8
        lde  r2, @rr8
        incw r8
        lde  r3, @rr8
        sub  r9, #3
        sbc  r8, #0
        ; call printUint@i32[t.2.1{r0}]
        call printUint_Pi32
        ; const t.3.1{r0}, [string-17]
        ld   r0, #hi(string_17)
        ld   r1, #lo(string_17)
        ; call printString@@u8[t.3.1{r0}]
        call printString_P_Pu8
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; void drawStatus
drawStatus:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; const arg.0.0{r0}, 19
        ld   r0, #%00
        ld   r1, #%13
        ; const arg.0.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.0.1{r0}, [string-18]
        ld   r0, #hi(string_18)
        ld   r1, #lo(string_18)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ; const arg.2.0{r0}, 19
        ld   r0, #%00
        ld   r1, #%13
        ; const arg.2.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.2.0{r0}, arg.2.1{r2}]
        call setCursor_Pi16_Pi16
        ; 251:2 if gameState == 1
        ; addrof a.1.1{r8}, gameState
        ld   r8, #hi(var_2)
        ld   r9, #lo(var_2)
        ; load t.2.1{r10}, [a.1.1{r8}]
        lde  r10, @rr8
        ; branch t.2.1{r10} equals 1: if_44_then
        cp   r10, #%01
        jr   eq, if__44__then
        ; 254:7 if gameState == 2
        ; branch t.5.1{r10} notequals 2: drawStatus_ret, if_45_then
        cp   r10, #%02
        jr   ne, drawStatus__ret
        jr   if__45__then

if__44__then:
        ; const t.3.1{r0}, [string-19]
        ld   r0, #hi(string_19)
        ld   r1, #lo(string_19)
        ; call printString@@u8[t.3.1{r0}]
        call printString_P_Pu8
        jr   drawStatus__ret

if__45__then:
        ; const t.6.1{r0}, [string-20]
        ld   r0, #hi(string_20)
        ld   r1, #lo(string_20)
        ; call printString@@u8[t.6.1{r0}]
        call printString_P_Pu8
drawStatus__ret:
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void newGame
newGame:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const index.1{r8}, 0
        ld   r8, #%00
        ; 260:2 for index < 16
        jr   for__46

for__46__body:
        ; const t.1.1{r9}, 0
        ld   r9, #%00
        ; cast t.3.1{r10}(i16), index.2{r8}(u8)
        ld   r11, r8
        ld   r10, #0
        ; addrof t.2.1{r12}, tiles
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.2.2{r12}, t.3.1{r10}
        add  r13, r11
        adc  r12, r10
        ; store [t.2.2{r12}], t.1.1{r9}
        lde  @rr12, r9
        ; add index.3{r8}, 1
        inc  r8
for__46:
        ; branch index.2{r8} lt 16: for_46_body
        cp   r8, #%10
        jr   ult, for__46__body
        ; const t.4.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%00
        ; addrof a.5.1{r12}, score
        ld   r12, #hi(var_1)
        ld   r13, #lo(var_1)
        ; store [a.5.1{r12}], t.4.1{r8}
        lde  @rr12, r8
        incw r12
        lde  @rr12, r9
        incw r12
        lde  @rr12, r10
        incw r12
        lde  @rr12, r11
        sub  r13, #3
        sbc  r12, #0
        ; const t.6.1{r8}, 0
        ld   r8, #%00
        ; addrof a.7.1{r10}, gameState
        ld   r10, #hi(var_2)
        ld   r11, #lo(var_2)
        ; store [a.7.1{r10}], t.6.1{r8}
        lde  @rr10, r8
        ; call spawnTile[]
        call spawnTile
        ; call spawnTile[]
        call spawnTile
        ; call drawBoard[]
        call drawBoard
        ; call drawScore[]
        call drawScore
        ; call drawStatus[]
        call drawStatus
        ; const arg.5.0{r0}, 21
        ld   r0, #%00
        ld   r1, #%15
        ; const arg.5.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.5.0{r0}, arg.5.1{r2}]
        call setCursor_Pi16_Pi16
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
        ; begin initialize global variables
        ; const t.2.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%00
        ; addrof a.3.1{r12}, score
        ld   r12, #hi(var_1)
        ld   r13, #lo(var_1)
        ; store [a.3.1{r12}], t.2.1{r8}
        lde  @rr12, r8
        incw r12
        lde  @rr12, r9
        incw r12
        lde  @rr12, r10
        incw r12
        lde  @rr12, r11
        sub  r13, #3
        sbc  r12, #0
        ; const t.4.1{r8}, 0
        ld   r8, #%00
        ; addrof a.5.1{r10}, gameState
        ld   r10, #hi(var_2)
        ld   r11, #lo(var_2)
        ; store [a.5.1{r10}], t.4.1{r8}
        lde  @rr10, r8
        ; end initialize global variables
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom@i32[arg.0.0{r0}]
        call initRandom_Pi32
        ; call drawFrame[]
        call drawFrame
        ; call newGame[]
        call newGame
        ; 277:2 while true
        jr   while__47

if__48__end:
        ; branch key.1{r8} equals 114: if_49_then
        cp   r9, #%72
        jr   ne, .notEquals3
        cp   r8, #%00
        jr   eq, if__49__then
.notEquals3:
        ; branch key.1{r8} equals 82: if_49_then
        cp   r9, #%52
        jr   ne, .notEquals4
        cp   r8, #%00
        jr   eq, if__49__then
.notEquals4:
        ; 286:3 if gameState != 0
        ; addrof a.6.1{r10}, gameState
        ld   r10, #hi(var_2)
        ld   r11, #lo(var_2)
        ; load t.7.1{r12}, [a.6.1{r10}]
        lde  r12, @rr10
        ; branch t.7.1{r12} notequals 0: while_47
        cp   r12, #%00
        jr   ne, while__47
        ; const direction.1{r10}, 255
        ld   r10, #%ff
        ; 291:3 if key == 1 || key == 97 || key == 65
        ; branch key.1{r8} equals 1: if_52_then, or_54
        cp   r9, #%01
        jr   ne, .notEquals5
        cp   r8, #%00
        jr   eq, if__52__then
.notEquals5:
        jr   or__54

if__49__then:
        ; call newGame[]
        call newGame
        jr   while__47

or__54:
        ; branch key.1{r8} equals 97: if_52_then
        cp   r9, #%61
        jr   ne, .notEquals6
        cp   r8, #%00
        jr   eq, if__52__then
.notEquals6:
        ; branch key.1{r8} equals 65: if_52_then
        cp   r9, #%41
        jr   ne, .notEquals7
        cp   r8, #%00
        jr   eq, if__52__then
.notEquals7:
        ; branch key.1{r8} equals 2: if_55_then
        cp   r9, #%02
        jr   ne, .notEquals8
        cp   r8, #%00
        jr   eq, if__55__then
.notEquals8:
        ; branch key.1{r8} equals 100: if_55_then, or_56
        cp   r9, #%64
        jr   ne, .notEquals9
        cp   r8, #%00
        jr   eq, if__55__then
.notEquals9:
        jr   or__56

if__52__then:
        ; const direction.2{r8}, 0
        ld   r8, #%00
        ; move direction.3{r0}, direction.2{r8}
        ld   r0, r8
        jr   if__52__end

or__56:
        ; branch key.1{r8} equals 68: if_55_then
        cp   r9, #%44
        jr   ne, .notEquals10
        cp   r8, #%00
        jr   eq, if__55__then
.notEquals10:
        ; branch key.1{r8} equals 3: if_58_then
        cp   r9, #%03
        jr   ne, .notEquals11
        cp   r8, #%00
        jr   eq, if__58__then
.notEquals11:
        ; branch key.1{r8} equals 119: if_58_then, or_59
        cp   r9, #%77
        jr   ne, .notEquals12
        cp   r8, #%00
        jr   eq, if__58__then
.notEquals12:
        jr   or__59

if__55__then:
        ; const direction.4{r8}, 1
        ld   r8, #%01
        ; move direction.3{r0}, direction.4{r8}
        ld   r0, r8
        jr   if__52__end

or__59:
        ; branch key.1{r8} equals 87: if_58_then
        cp   r9, #%57
        jr   ne, .notEquals13
        cp   r8, #%00
        jr   eq, if__58__then
.notEquals13:
        ; branch key.1{r8} equals 4: if_61_then
        cp   r9, #%04
        jr   ne, .notEquals14
        cp   r8, #%00
        jr   eq, if__61__then
.notEquals14:
        ; branch key.1{r8} equals 115: if_61_then, or_62
        cp   r9, #%73
        jr   ne, .notEquals15
        cp   r8, #%00
        jr   eq, if__61__then
.notEquals15:
        jr   or__62

if__58__then:
        ; const direction.5{r8}, 2
        ld   r8, #%02
        ; move direction.3{r0}, direction.5{r8}
        ld   r0, r8
        jr   if__52__end

or__62:
        ; branch key.1{r8} equals 83: if_61_then
        cp   r9, #%53
        jr   ne, .notEquals16
        cp   r8, #%00
        jr   eq, if__61__then
.notEquals16:
        ; move direction.3{r0}, direction.1{r10}
        ld   r0, r10
        jr   if__52__end

if__61__then:
        ; const direction.6{r8}, 3
        ld   r8, #%03
        ; move direction.3{r0}, direction.6{r8}
        ld   r0, r8
if__52__end:
        ; branch direction.3{r0} equals 255: while_47
        cp   r0, #%ff
        jr   eq, while__47
        ; call t.8.1{r0} = slide@u8[direction.3{r0}] -> bool
        call slide_Pu8
        ; branch t.8.1{r0} equals 0: while_47
        cp   r0, #%00
        jr   eq, while__47
        ; call spawnTile[]
        call spawnTile
        ; 308:3 if gameState == 0 && !canMove([])
        ; addrof a.9.1{r8}, gameState
        ld   r8, #hi(var_2)
        ld   r9, #lo(var_2)
        ; load t.10.1{r10}, [a.9.1{r8}]
        lde  r10, @rr8
        ; branch t.10.1{r10} notequals 0: if_66_end
        cp   r10, #%00
        jr   ne, if__66__end
        ; call t.11.1{r0} = canMove[] -> bool
        call canMove
        ; branch t.11.1{r0} notequals 0: if_66_end
        cp   r0, #%00
        jr   ne, if__66__end
        ; const t.12.1{r8}, 2
        ld   r8, #%02
        ; addrof a.13.1{r10}, gameState
        ld   r10, #hi(var_2)
        ld   r11, #lo(var_2)
        ; store [a.13.1{r10}], t.12.1{r8}
        lde  @rr10, r8
if__66__end:
        ; call drawBoard[]
        call drawBoard
        ; call drawScore[]
        call drawScore
        ; 313:3 if gameState != 0
        ; addrof a.14.1{r8}, gameState
        ld   r8, #hi(var_2)
        ld   r9, #lo(var_2)
        ; load t.15.1{r10}, [a.14.1{r8}]
        lde  r10, @rr8
        ; branch t.15.1{r10} equals 0: if_68_end
        cp   r10, #%00
        jr   eq, if__68__end
        ; call drawStatus[]
        call drawStatus
if__68__end:
        ; const arg.10.0{r0}, 21
        ld   r0, #%00
        ld   r1, #%15
        ; const arg.10.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.10.0{r0}, arg.10.1{r2}]
        call setCursor_Pi16_Pi16
while__47:
        ; call key.1{r0} = getChar[] -> i16
        call getChar
        ; move key.1{r8}, key.1{r0}
        ld   r9, r1
        ld   r8, r0
        ; 279:3 if key == 27
        ; branch key.1{r8} notequals 27: if_48_end
        cp   r9, #%1b
        jr   ne, if__48__end
        cp   r8, #%00
        jr   ne, if__48__end
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

        ; variable 0: tiles[] (u8*/16)
var_0:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 1: score (i32/4)
var_1:
        .data %00 %00 %00 %00
        ; variable 2: gameState (u8/1)
var_2:
        .data %00

string_0:
        .data "      " %00
string_1:
        .data "  2   " %00
string_2:
        .data "  4   " %00
string_3:
        .data "  8   " %00
string_4:
        .data "  16  " %00
string_5:
        .data "  32  " %00
string_6:
        .data "  64  " %00
string_7:
        .data " 128  " %00
string_8:
        .data " 256  " %00
string_9:
        .data " 512  " %00
string_10:
        .data " 1024 " %00
string_11:
        .data " 2048 " %00
string_12:
        .data "  ?   " %00
string_13:
        .data "+------+" %00
string_14:
        .data "Arrows/WASD  R restart  Esc quit" %00
string_15:
        .data "                                   " %00
string_16:
        .data "2048  Score: " %00
string_17:
        .data "          " %00
string_18:
        .data "                                      " %00
string_19:
        .data "2048! Press R to play again." %00
string_20:
        .data "No moves left. Press R to restart." %00

