        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

start:
        srp  #%20
        jr   main

        ; i16 tileValue@u8
        ; arg exponent (u8): r0
tileValue_Pu8:
        ; const value.1{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; const index.1{r4}, 0
        ld   r4, #%00
        ; 45:2 for index < exponent
        jr   for__1

for__1__body:
        ; shiftleft value.3{r2}, 1
        add r3, r3
        adc r2, r2
        ; add index.3{r4}, 1
        inc  r4
for__1:
        ; branch index.2{r4} lt param.exponent{r0}: for_1_body
        cp   r4, r0
        jr   ult, for__1__body
        ; 48:9 return value
        ; move value.2{r0}, value.2{r2}
        ld   r0, r2
        ld   r1, r3
        ret

        ; u8 spawnTile
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
        ; 53:2 for index < 16
        jr   for__2

for__2__body:
        ; 54:3 if [...] == 0
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
        ; branch emptyCount.2{r8} equals 0: if_4_then
        cp   r8, #%00
        jr   eq, if__4__then
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
        ; 63:2 for index < 16
        jr   for__5

for__5__body:
        ; 64:3 if [...] != 0
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
        jr   for__5

if__4__then:
        ; const {r0}, 255
        ld   r0, #%ff
        jr   spawnTile__ret

for__5:
        ; branch index.4{r9} lt 16: for_5_body
        cp   r9, #%10
        jr   ult, for__5__body
        ; const {r0}, 255
        ld   r0, #%ff
        jr   spawnTile__ret

if__7__then:
        ; const tile.1{r8}, 1
        ld   r8, #%01
        ; 69:4 if random16([]) % 10 == 0
        ; call t.15.1{r0} = random16[] -> i16
        call random16
        ; move t.14.1{r1}, t.15.1{r0}
        ld   r2, r1
        ld   r1, r0
        ; mod t.14.1{r1}, 10
        ld   %12, r1
        ld   %13, r2
        ld   %14, #%00
        ld   %15, #%0a
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r1, %12
        ld   r2, %13
        ; branch t.14.1{r1} equals 0: if_8_then
        cp   r2, #%00
        jr   ne, .notEquals1
        cp   r1, #%00
        jr   eq, if__8__then
.notEquals1:
        ; move tile.2{r1}, tile.1{r8}
        ld   r1, r8
        jr   if__8__end

if__8__then:
        ; const tile.3{r1}, 2
        ld   r1, #%02
if__8__end:
        ; cast t.17.1{r2}(i16), index.4{r9}(u8)
        ld   r3, r9
        ld   r2, #0
        ; addrof t.16.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.16.2{r4}, t.17.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.16.2{r4}], tile.2{r1}
        lde  @rr4, r1
        ; 73:11 return index
        ; move index.4{r0}, index.4{r9}
        ld   r0, r9
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
        ; var source.2 (u8): SP+8
        ; var target.2 (u8): SP+9
        ; var position.2 (u8): SP+10
        ; var tile.1 (u8): SP+11
        ; var merged.2 (bool): SP+12
        ; var param.first (u8): SP+13
        ; var param.step (u8): SP+14
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
        ; 85:2 for position < 4
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], position.2{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; move param.step{r4}, param.step{r9}
        ld   r4, r9
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; move position.2{r3}, position.2{r1}
        ld   r3, r1
        ; move source.2{r2}, source.2{r10}
        ld   r2, r10
        ; move target.2{r1}, target.2{r11}
        ld   r1, r11
        jr   for__9

for__9__body:
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], position.2{r3}
        lde  @rr14, r3
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; load param.first{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move param.step{r9}, param.step{r4}
        ld   r9, r4
        ; move source.2{r10}, source.2{r2}
        ld   r10, r2
        ; move target.2{r11}, target.2{r1}
        ld   r11, r1
        ; cast t.14.1{r1}(i16), source.2{r10}(u8)
        ld   r2, r10
        ld   r1, #0
        ; addrof sourceTile.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add sourceTile.2{r4}, t.14.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load tile.1{r1}, [sourceTile.2{r4}]
        lde  r1, @rr4
        ; 88:3 if tile != 0
        ; branch tile.1{r1} notequals 0: if_10_then
        cp   r1, #%00
        jr   ne, if__10__then
        ; move param.step{r4}, param.step{r9}
        ld   r4, r9
        ; move source.2{r2}, source.2{r10}
        ld   r2, r10
        jr   if__10__end

if__10__then:
        ; const t.15.1{r2}, 0
        ld   r2, #%00
        ; store [sourceTile.2{r4}], t.15.1{r2}
        lde  @rr4, r2
        ; const merged.1{r2}, 0
        ld   r2, #%00
        ; 91:4 if target != first && !previousMerged
        ; branch target.2{r11} notequals param.first{r8}: and_12
        cp   r11, r8
        jr   ne, and__12
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, source.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], source.2{r10}
        lde  @rr14, r10
        ; addrof memVarAddr{r14}, target.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.2{r11}
        lde  @rr14, r11
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
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
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, source.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], source.2{r10}
        lde  @rr14, r10
        ; addrof memVarAddr{r14}, target.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.2{r11}
        lde  @rr14, r11
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
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
        ; cast t.16.1{r4}(i16), previous.1{r3}(u8)
        ld   r5, r3
        ld   r4, #0
        ; addrof previousTile.1{r6}, tiles
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add previousTile.2{r6}, t.16.1{r4}
        add  r7, r5
        adc  r6, r4
        ; 94:5 if *previousTile == tile
        ; load t.17.1{r4}, [previousTile.2{r6}]
        lde  r4, @rr6
        ; branch t.17.1{r4} equals tile.1{r1}: if_13_then
        cp   r4, r1
        jr   eq, if__13__then
        ; addrof memVarAddr{r14}, merged.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], merged.2{r2}
        lde  @rr14, r2
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, source.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], source.2{r10}
        lde  @rr14, r10
        ; addrof memVarAddr{r14}, target.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.2{r11}
        lde  @rr14, r11
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, merged.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; move merged.2{r1}, merged.2{r2}
        ld   r1, r2
        jr   if__11__end

if__13__then:
        ; move t.18.1{r12}, previous.1{r3}
        ld   r12, r3
        ; or t.18.1{r12}, 128
        or  r12, #%80
        ; cast t.20.1{r2}(i16), source.2{r10}(u8)
        ld   r3, r10
        ld   r2, #0
        ; addrof t.19.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.19.2{r4}, t.20.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.19.2{r4}], t.18.1{r12}
        lde  @rr4, r12
        ; move nextTile.1{r12}, tile.1{r1}
        ld   r12, r1
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r1}
        lde  @rr14, r1
        ; add nextTile.1{r12}, 1
        inc  r12
        ; store [previousTile.2{r6}], nextTile.1{r12}
        lde  @rr6, r12
        ; move nextTile.1{r0}, nextTile.1{r12}
        ld   r0, r12
        ; call t.21.1{r0} = tileValue@u8[nextTile.1{r0}] -> i16
        call tileValue_Pu8
        ; cast mergedScore.1{r1}(i32), t.21.1{r0}(i16)
        ld   r4, r1
        ld   r3, r0
        ld   r2, r3
        rl   r2
        sbc  r2, r2
        sbc  r1, r1
        ; addrof a.23.1{r6}, score
        ld   r6, #hi(var_3)
        ld   r7, #lo(var_3)
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, source.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], source.2{r10}
        lde  @rr14, r10
        ; addrof memVarAddr{r14}, target.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.2{r11}
        lde  @rr14, r11
        ; load t.24.1{r8}, [a.23.1{r6}]
        lde  r8, @rr6
        incw r6
        lde  r9, @rr6
        incw r6
        lde  r10, @rr6
        incw r6
        lde  r11, @rr6
        sub  r7, #3
        sbc  r6, #0
        ; move t.22.1{r5}, t.24.1{r8}
        ld   r5, r8
        ld   r6, r9
        ld   r7, r10
        ld   r8, r11
        ; add t.22.1{r5}, mergedScore.1{r1}
        add  r8, r4
        adc  r7, r3
        adc  r6, r2
        adc  r5, r1
        ; addrof a.25.1{r2}, score
        ld   r2, #hi(var_3)
        ld   r3, #lo(var_3)
        ; store [a.25.1{r2}], t.22.1{r5}
        lde  @rr2, r5
        incw r2
        lde  @rr2, r6
        incw r2
        lde  @rr2, r7
        incw r2
        lde  @rr2, r8
        sub  r3, #3
        sbc  r2, #0
        ; 101:6 if nextTile == 11
        ; branch nextTile.1{r12} notequals 11: if_14_end
        cp   r12, #%0b
        jr   ne, if__14__end
        ; const t.26.1{r1}, 1
        ld   r1, #%01
        ; addrof a.27.1{r2}, gameState
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.27.1{r2}], t.26.1{r1}
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
        ; branch merged.2{r1} equals 0: if_15_then
        cp   r1, #%00
        jr   eq, if__15__then
        ; addrof memVarAddr{r14}, target.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load target.2{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; move target.3{r11}, target.2{r1}
        ld   r11, r1
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load param.step{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        ; addrof memVarAddr{r14}, source.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load source.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        jr   if__10__end

if__15__then:
        ; addrof memVarAddr{r14}, target.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load target.2{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, source.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load source.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; cast t.29.1{r3}(i16), source.2{r2}(u8)
        ld   r4, r2
        ld   r3, #0
        ; addrof t.28.1{r6}, moveTargets
        ld   r6, #hi(var_2)
        ld   r7, #lo(var_2)
        ; add t.28.2{r6}, t.29.1{r3}
        add  r7, r4
        adc  r6, r3
        ; store [t.28.2{r6}], target.2{r1}
        lde  @rr6, r1
        ; cast t.31.1{r3}(i16), target.2{r1}(u8)
        ld   r4, r1
        ld   r3, #0
        ; addrof t.30.1{r6}, tiles
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.30.2{r6}, t.31.1{r3}
        add  r7, r4
        adc  r6, r3
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; load tile.1{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        ; store [t.30.2{r6}], tile.1{r3}
        lde  @rr6, r3
        ; 112:5 if target != source
        ; branch target.2{r1} notequals source.2{r2}: if_16_then
        cp   r1, r2
        jr   ne, if__16__then
        ; move moved.5{r3}, moved.4{r13}
        ld   r3, r13
        jr   if__16__end

if__16__then:
        ; const moved.6{r3}, 1
        ld   r3, #%01
if__16__end:
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load param.step{r4}, [memVarAddr{r14}]
        lde  r4, @rr14
        ; add target.7{r1}, param.step{r4}
        add  r1, r4
        ; const previousMerged.5{r5}, 0
        ld   r5, #%00
        ; move target.3{r11}, target.7{r1}
        ld   r11, r1
        ; move previousMerged.3{r12}, previousMerged.5{r5}
        ld   r12, r5
        ; move moved.3{r13}, moved.5{r3}
        ld   r13, r3
if__10__end:
        ; move source.4{r1}, source.2{r2}
        ld   r1, r2
        ; add source.4{r1}, param.step{r4}
        add  r1, r4
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load position.2{r3}, [memVarAddr{r14}]
        lde  r3, @rr14
        ; add position.5{r3}, 1
        inc  r3
        ; move source.2{r2}, source.4{r1}
        ld   r2, r1
        ; move target.2{r1}, target.3{r11}
        ld   r1, r11
for__9:
        ; branch position.2{r3} lt 4: for_9_body
        cp   r3, #%04
        jr   ult, for__9__body
        ; 121:9 return moved
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
        push r13
        ; move param.direction{r8}, direction{r0}
        ld   r8, r0
        ; const index.1{r9}, 0
        ld   r9, #%00
        ; 125:2 for index < 16
        jr   for__17

for__17__body:
        ; cast t.8.1{r10}(i16), index.2{r9}(u8)
        ld   r11, r9
        ld   r10, #0
        ; addrof t.7.1{r12}, tiles
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.7.2{r12}, t.8.1{r10}
        add  r13, r11
        adc  r12, r10
        ; load t.6.1{r10}, [t.7.2{r12}]
        lde  r10, @rr12
        ; cast t.10.1{r11}(i16), index.2{r9}(u8)
        ld   r12, r9
        ld   r11, #0
        ; addrof t.9.1{r2}, moveTiles
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; add t.9.2{r2}, t.10.1{r11}
        add  r3, r12
        adc  r2, r11
        ; store [t.9.2{r2}], t.6.1{r10}
        lde  @rr2, r10
        ; move t.12.1{r10}, t.12.1{r11}
        ld   r10, r11
        ld   r11, r12
        ; addrof t.11.1{r12}, moveTargets
        ld   r12, #hi(var_2)
        ld   r13, #lo(var_2)
        ; add t.11.2{r12}, t.12.1{r10}
        add  r13, r11
        adc  r12, r10
        ; store [t.11.2{r12}], index.2{r9}
        lde  @rr12, r9
        ; add index.3{r9}, 1
        inc  r9
for__17:
        ; branch index.2{r9} lt 16: for_17_body
        cp   r9, #%10
        jr   ult, for__17__body
        ; const moved.1{r9}, 0
        ld   r9, #%00
        ; const line.1{r10}, 0
        ld   r10, #%00
        ; 130:2 for line < 4
        jr   for__18

for__18__body:
        ; move first.1{r11}, line.2{r10}
        ld   r11, r10
        ; shiftleft first.1{r11}, 2
        add r11, r11
        add r11, r11
        ; const step.1{r12}, 1
        ld   r12, #%01
        ; 133:3 if direction == 1
        ; branch param.direction{r8} equals 1: if_19_then
        cp   r8, #%01
        jr   eq, if__19__then
        ; branch param.direction{r8} notequals 2: if_20_else, if_20_then
        cp   r8, #%02
        jr   ne, if__20__else
        jr   if__20__then

if__19__then:
        ; add first.2{r11}, 3
        add  r11, #%03
        ; const step.2{r12}, 255
        ld   r12, #%ff
        ; move first.3{r0}, first.2{r11}
        ld   r0, r11
        ; move step.3{r1}, step.2{r12}
        ld   r1, r12
        jr   if__19__end

if__20__else:
        ; branch param.direction{r8} notequals 3: slide@u8.no_critical_edge_17, if_21_then
        cp   r8, #%03
        jr   ne, slide_Pu8_2eno__critical__edge__17
        jr   if__21__then

if__20__then:
        ; move first.4{r11}, line.2{r10}
        ld   r11, r10
        ; const step.4{r12}, 4
        ld   r12, #%04
        ; move first.3{r0}, first.4{r11}
        ld   r0, r11
        ; move step.3{r1}, step.4{r12}
        ld   r1, r12
        jr   if__19__end

slide_Pu8_2eno__critical__edge__17:
        ; move first.3{r0}, first.1{r11}
        ld   r0, r11
        ; move step.3{r1}, step.1{r12}
        ld   r1, r12
        jr   if__19__end

if__21__then:
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
if__19__end:
        ; 145:3 if slideLine@u8@u8([ExprVarAccess[varName=first, index=4, scope=function, type=u8, varIsArray=false, location=145:16], ExprVarAccess[varName=step, index=5, scope=function, type=u8, varIsArray=false, location=145:23]])
        ; call t.13.1{r0} = slideLine@u8@u8[first.3{r0}, step.3{r1}] -> bool
        call slideLine_Pu8_Pu8
        ; branch t.13.1{r0} notequals 0: if_22_then
        cp   r0, #%00
        jr   ne, if__22__then
        ; move moved.4{r1}, moved.2{r9}
        ld   r1, r9
        jr   for__18__continue

if__22__then:
        ; const moved.5{r1}, 1
        ld   r1, #%01
for__18__continue:
        ; move line.5{r2}, line.2{r10}
        ld   r2, r10
        ; add line.5{r2}, 1
        inc  r2
        ; move moved.2{r9}, moved.4{r1}
        ld   r9, r1
        ; move line.2{r10}, line.5{r2}
        ld   r10, r2
for__18:
        ; branch line.2{r10} lt 4: for_18_body
        cp   r10, #%04
        jr   ult, for__18__body
        ; 149:9 return moved
        ; move moved.2{r0}, moved.2{r9}
        ld   r0, r9
        ; restore clobbered non-volatile registers
        pop  r13
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
        ; 153:2 for index < 16
        jr   for__23

for__23__body:
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
        ; 155:3 if tile == 0
        ; branch tile.1{r2} equals 0: if_24_then
        cp   r2, #%00
        jr   eq, if__24__then
        ; 158:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r3}, index.2{r1}
        ld   r3, r1
        ; and t.4.1{r3}, 3
        and  r3, #%03
        ; branch t.4.1{r3} equals 3: if_25_end
        cp   r3, #%03
        jr   eq, if__25__end
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
        ; branch t.5.1{r3} equals tile.1{r2}: if_25_then, if_25_end
        cp   r3, r2
        jr   eq, if__25__then
if__25__end:
        ; branch index.2{r1} gteq 12: for_23_continue
        cp   r1, #%0c
        jr   uge, for__23__continue
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
        ; branch t.9.1{r3} equals tile.1{r2}: if_27_then, for_23_continue
        cp   r3, r2
        jr   eq, if__27__then
for__23__continue:
        ; add index.5{r1}, 1
        inc  r1
for__23:
        ; branch index.2{r1} lt 16: for_23_body
        cp   r1, #%10
        jr   ult, for__23__body
        ; const {r0}, 0
        ld   r0, #%00
        jr   canMove__ret

if__24__then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove__ret

if__25__then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove__ret

if__27__then:
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
        ; branch param.exponent{r8} equals 0: if_29_then
        cp   r8, #%00
        jr   eq, if__29__then
        ; branch param.exponent{r8} notequals 1: if_30_else, if_30_then
        cp   r8, #%01
        jr   ne, if__30__else
        jr   if__30__then

if__29__then:
        ; const t.1.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString@@u8[t.1.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__30__else:
        ; branch param.exponent{r8} notequals 2: if_31_else, if_31_then
        cp   r8, #%02
        jr   ne, if__31__else
        jr   if__31__then

if__30__then:
        ; const t.2.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString@@u8[t.2.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__31__else:
        ; branch param.exponent{r8} notequals 3: if_32_else, if_32_then
        cp   r8, #%03
        jr   ne, if__32__else
        jr   if__32__then

if__31__then:
        ; const t.3.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString@@u8[t.3.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__32__else:
        ; branch param.exponent{r8} notequals 4: if_33_else, if_33_then
        cp   r8, #%04
        jr   ne, if__33__else
        jr   if__33__then

if__32__then:
        ; const t.4.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString@@u8[t.4.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__33__else:
        ; branch param.exponent{r8} notequals 5: if_34_else, if_34_then
        cp   r8, #%05
        jr   ne, if__34__else
        jr   if__34__then

if__33__then:
        ; const t.5.1{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString@@u8[t.5.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__34__else:
        ; branch param.exponent{r8} notequals 6: if_35_else, if_35_then
        cp   r8, #%06
        jr   ne, if__35__else
        jr   if__35__then

if__34__then:
        ; const t.6.1{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString@@u8[t.6.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__35__else:
        ; branch param.exponent{r8} notequals 7: if_36_else, if_36_then
        cp   r8, #%07
        jr   ne, if__36__else
        jr   if__36__then

if__35__then:
        ; const t.7.1{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString@@u8[t.7.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__36__else:
        ; branch param.exponent{r8} notequals 8: if_37_else, if_37_then
        cp   r8, #%08
        jr   ne, if__37__else
        jr   if__37__then

if__36__then:
        ; const t.8.1{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
        ; call printString@@u8[t.8.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__37__else:
        ; branch param.exponent{r8} notequals 9: if_38_else, if_38_then
        cp   r8, #%09
        jr   ne, if__38__else
        jr   if__38__then

if__37__then:
        ; const t.9.1{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString@@u8[t.9.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__38__else:
        ; branch param.exponent{r8} notequals 10: if_39_else, if_39_then
        cp   r8, #%0a
        jr   ne, if__39__else
        jr   if__39__then

if__38__then:
        ; const t.10.1{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString@@u8[t.10.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__39__else:
        ; branch param.exponent{r8} notequals 11: if_40_else, if_40_then
        cp   r8, #%0b
        jr   ne, if__40__else
        jr   if__40__then

if__39__then:
        ; const t.11.1{r0}, [string-10]
        ld   r0, #hi(string_10)
        ld   r1, #lo(string_10)
        ; call printString@@u8[t.11.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__40__else:
        ; const t.13.1{r0}, [string-12]
        ld   r0, #hi(string_12)
        ld   r1, #lo(string_12)
        ; call printString@@u8[t.13.1{r0}]
        call printString_P_Pu8
        jr   printTile_Pu8__ret

if__40__then:
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

        ; u8 tileRow@u8
        ; arg index (u8): r0
tileRow_Pu8:
        ; 226:19 return index & 12 + 3
        ; move t.2.1{r1}, param.index{r0}
        ld   r1, r0
        ; and t.2.1{r1}, 12
        and  r1, #%0c
        ; move t.1.1{r0}, t.2.1{r1}
        ld   r0, r1
        ; add t.1.1{r0}, 3
        add  r0, #%03
        ret

        ; u8 tileColumn@u8
        ; arg index (u8): r0
tileColumn_Pu8:
        ; move column.1{r1}, param.index{r0}
        ld   r1, r0
        ; and column.1{r1}, 3
        and  r1, #%03
        ; 231:36 return column << 3 + 1 + column
        ; move t.4.1{r2}, column.1{r1}
        ld   r2, r1
        ; shiftleft t.4.1{r2}, 3
        add r2, r2
        add r2, r2
        add r2, r2
        ; add t.3.1{r2}, 1
        inc  r2
        ; move t.2.1{r0}, t.3.1{r2}
        ld   r0, r2
        ; add t.2.1{r0}, column.1{r1}
        add  r0, r1
        ret

        ; void clearTileTrail@u8@u8@u8@u8
        ; arg row (u8): r0
        ; arg column (u8): r1
        ; arg direction (u8): r2
        ; arg distance (u8): r3
clearTileTrail_Pu8_Pu8_Pu8_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; const width.1{r8}, 8
        ld   r8, #%08
        ; const height.1{r9}, 3
        ld   r9, #%03
        ; 237:2 if direction < 2
        ; branch param.direction{r2} lt 2: if_42_then
        cp   r2, #%02
        jr   ult, if__42__then
        ; branch param.distance{r3} gteq height.1{r9}: if_45_end, if_45_then
        cp   r3, r9
        jr   uge, if__45__end
        jr   if__45__then

if__42__then:
        ; branch param.distance{r3} gteq width.1{r8}: if_43_end, if_43_then
        cp   r3, r8
        jr   uge, if__43__end
        jr   if__43__then

if__45__then:
        ; move height.3{r9}, param.distance{r3}
        ld   r9, r3
        jr   if__45__end

if__43__then:
        ; move width.4{r8}, param.distance{r3}
        ld   r8, r3
        jr   if__43__end

if__45__end:
        ; branch param.direction{r2} notequals 2: clearTileTrail@u8@u8@u8@u8.no_critical_edge_15, if_46_then
        cp   r2, #%02
        jr   ne, clearTileTrail_Pu8_Pu8_Pu8_Pu8_2eno__critical__edge__15
        jr   if__46__then

if__43__end:
        ; branch param.direction{r2} notequals 0: clearTileTrail@u8@u8@u8@u8.no_critical_edge_17, if_44_then
        cp   r2, #%00
        jr   ne, clearTileTrail_Pu8_Pu8_Pu8_Pu8_2eno__critical__edge__17
        jr   if__44__then

clearTileTrail_Pu8_Pu8_Pu8_Pu8_2eno__critical__edge__15:
        ; move row.3{r10}, param.row{r0}
        ld   r10, r0
        ; move column.3{r11}, param.column{r1}
        ld   r11, r1
        jr   if__42__end

if__46__then:
        ; const t.11.1{r10}, 3
        ld   r10, #%03
        ; sub t.10.1{r10}, height.2{r9}
        sub  r10, r9
        ; move row.4{r11}, param.row{r0}
        ld   r11, r0
        ; add row.4{r11}, t.10.1{r10}
        add  r11, r10
        ; move row.3{r10}, row.4{r11}
        ld   r10, r11
        ; move column.3{r11}, param.column{r1}
        ld   r11, r1
        jr   if__42__end

clearTileTrail_Pu8_Pu8_Pu8_Pu8_2eno__critical__edge__17:
        ; move row.3{r10}, param.row{r0}
        ld   r10, r0
        ; move column.3{r11}, param.column{r1}
        ld   r11, r1
        jr   if__42__end

if__44__then:
        ; const t.9.1{r10}, 8
        ld   r10, #%08
        ; sub t.8.1{r10}, width.3{r8}
        sub  r10, r8
        ; move column.4{r11}, param.column{r1}
        ld   r11, r1
        ; add column.4{r11}, t.8.1{r10}
        add  r11, r10
        ; move row.3{r10}, param.row{r0}
        ld   r10, r0
if__42__end:
        ; const spaces.1{r12}, [string-14]
        ld   r12, #hi(string_14)
        ld   r13, #lo(string_14)
        ; const t.14.1{r14}, 8
        ld   r14, #%08
        ; sub t.13.1{r14}, width.5{r8}
        sub  r14, r8
        ; cast t.12.1{r14}(i16), t.13.1{r14}(u8)
        ld   r15, r14
        ld   r14, #0
        ; add spaces.2{r12}, t.12.1{r14}
        add  r13, r15
        adc  r12, r14
        ; const line.1{r8}, 0
        ld   r8, #%00
        ; 255:2 for line < height
        jr   for__47

for__47__body:
        ; cast t.15.1{r0}(i16), row.5{r10}(u8)
        ld   r1, r10
        ld   r0, #0
        ; cast t.16.1{r2}(i16), column.3{r11}(u8)
        ld   r3, r11
        ld   r2, #0
        ; call setCursor@i16@i16[t.15.1{r0}, t.16.1{r2}]
        call setCursor_Pi16_Pi16
        ; move spaces.2{r0}, spaces.2{r12}
        ld   r0, r12
        ld   r1, r13
        ; call printString@@u8[spaces.2{r0}]
        call printString_P_Pu8
        ; move row.6{r0}, row.5{r10}
        ld   r0, r10
        ; add row.6{r0}, 1
        inc  r0
        ; move line.3{r1}, line.2{r8}
        ld   r1, r8
        ; add line.3{r1}, 1
        inc  r1
        ; move row.5{r10}, row.6{r0}
        ld   r10, r0
        ; move line.2{r8}, line.3{r1}
        ld   r8, r1
for__47:
        ; branch line.2{r8} lt height.5{r9}: for_47_body
        cp   r8, r9
        jr   ult, for__47__body
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

        ; bool drawMoveFrame@u8@u8@u8@bool
        ; arg direction (u8): r0
        ; arg previous (u8): r1
        ; arg travel (u8): r2
        ; arg erase (bool): r3
        ; var count.2 (u8): SP+8
        ; var index.2 (u8): SP+9
        ; var exponent.1 (u8): SP+10
        ; var pending.4 (bool): SP+11
        ; var target.1 (u8): SP+12
        ; var distance.4 (u8): SP+13
        ; var oldOffset.2 (u8): SP+14
        ; var pending.9 (bool): SP+15
        ; var offset.2 (u8): SP+16
        ; var column.3 (u8): SP+17
        ; var t.52.1 (i16): SP+18
        ; var param.direction (u8): SP+20
        ; var param.previous (u8): SP+21
drawMoveFrame_Pu8_Pu8_Pu8_Pbool:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%0e
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
        ; move param.direction{r8}, direction{r0}
        ld   r8, r0
        ; move param.previous{r9}, previous{r1}
        ld   r9, r1
        ; move param.travel{r10}, travel{r2}
        ld   r10, r2
        ; move param.erase{r11}, erase{r3}
        ld   r11, r3
        ; lt horizontal.1{r12}, param.direction{r8}, 2
        cp   r8, #%02
        jr   ult, .ult2
        ld   r12, #0  ; false
        jr   .2
.ult2:
        ld   r12, #1
.2:
        ; move t.17.1{r13}, param.direction{r8}
        ld   r13, r8
        ; and t.17.1{r13}, 1
        and  r13, #%01
        ; notequals forward.1{r13}, t.17.1{r13}, 0
        cp   r13, #%00
        jr   ne, .ne3
        ld   r13, #0  ; false
        jr   .3
.ne3:
        ld   r13, #1
.3:
        ; const pending.1{r5}, 0
        ld   r5, #%00
        ; const count.1{r6}, 0
        ld   r6, #%00
        ; 267:2 for count < 16
        ; move pending.2{r0}, pending.1{r5}
        ld   r0, r5
        ; move count.2{r5}, count.1{r6}
        ld   r5, r6
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%15
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; move count.2{r1}, count.2{r5}
        ld   r1, r5
        jr   for__48

for__48__body:
        ; move count.2{r5}, count.2{r1}
        ld   r5, r1
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%15
        adc  r14, #%00
        ; load param.previous{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        ; move index.1{r6}, count.2{r5}
        ld   r6, r5
        ; 269:3 if !forward
        ; branch forward.1{r13} equals 0: if_49_then
        cp   r13, #%00
        jr   eq, if__49__then
        ; addrof memVarAddr{r14}, count.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], count.2{r5}
        lde  @rr14, r5
        jr   if__49__end

if__49__then:
        ; const t.18.1{r6}, 15
        ld   r6, #%0f
        ; sub index.3{r6}, count.2{r5}
        sub  r6, r5
        ; addrof memVarAddr{r14}, count.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], count.2{r5}
        lde  @rr14, r5
if__49__end:
        ; cast t.20.1{r4}(i16), index.2{r6}(u8)
        ld   r5, r6
        ld   r4, #0
        ; addrof t.19.1{r2}, moveTiles
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; add t.19.2{r2}, t.20.1{r4}
        add  r3, r5
        adc  r2, r4
        ; load exponent.1{r4}, [t.19.2{r2}]
        lde  r4, @rr2
        ; 274:3 if exponent == 0
        ; branch exponent.1{r4} notequals 0: if_50_end
        cp   r4, #%00
        jr   ne, if__50__end
        ; move pending.4{r5}, pending.2{r0}
        ld   r5, r0
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%15
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; move pending.4{r9}, pending.4{r5}
        ld   r9, r5
        jr   for__48__continue

if__50__end:
        ; cast t.23.1{r2}(i16), index.2{r6}(u8)
        ld   r3, r6
        ld   r2, #0
        ; addrof memVarAddr{r14}, exponent.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], exponent.1{r4}
        lde  @rr14, r4
        ; addrof t.22.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.22.2{r4}, t.23.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.21.1{r7}, [t.22.2{r4}]
        lde  r7, @rr4
        ; move target.1{r5}, t.21.1{r7}
        ld   r5, r7
        ; and target.1{r5}, 15
        and  r5, #%0f
        ; move distance.1{r7}, index.2{r6}
        ld   r7, r6
        ; sub distance.1{r7}, target.1{r5}
        sub  r7, r5
        ; 280:3 if forward
        ; branch forward.1{r13} equals 0: if_51_end
        cp   r13, #%00
        jr   eq, if__51__end
        ; move distance.3{r7}, target.1{r5}
        ld   r7, r5
        ; sub distance.3{r7}, index.2{r6}
        sub  r7, r6
if__51__end:
        ; branch horizontal.1{r12} equals 0: if_52_end
        cp   r12, #%00
        jr   eq, if__52__end
        ; move t.24.1{r4}, distance.2{r7}
        ld   r4, r7
        ; shiftleft t.24.1{r4}, 3
        add r4, r4
        add r4, r4
        add r4, r4
        ; add distance.5{r7}, t.24.1{r4}
        add  r7, r4
if__52__end:
        ; move oldOffset.1{r4}, param.previous{r9}
        ld   r4, r9
        ; 289:3 if oldOffset > distance
        ; branch oldOffset.1{r4} lteq distance.4{r7}: if_53_end
        cp   r4, r7
        jr   ule, if__53__end
        ; move oldOffset.3{r4}, distance.4{r7}
        ld   r4, r7
if__53__end:
        ; move offset.1{r2}, param.travel{r10}
        ld   r2, r10
        ; 295:3 if offset >= distance
        ; branch offset.1{r2} gteq distance.4{r7}: if_54_then
        cp   r2, r7
        jr   uge, if__54__then
        ; const pending.8{r3}, 1
        ld   r3, #%01
        ; addrof memVarAddr{r14}, distance.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], distance.4{r7}
        lde  @rr14, r7
        jr   if__54__end

if__54__then:
        ; move offset.3{r2}, distance.4{r7}
        ld   r2, r7
        ; addrof memVarAddr{r14}, distance.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], distance.4{r7}
        lde  @rr14, r7
        ; move pending.9{r3}, pending.2{r0}
        ld   r3, r0
if__54__end:
        ; branch oldOffset.2{r4} equals offset.2{r2}: and_56
        cp   r4, r2
        jr   eq, and__56
        ; addrof memVarAddr{r14}, param.direction
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.direction{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%15
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; store [memVarAddr{r14}], pending.9{r3}
        lde  @rr14, r3
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.1{r5}
        lde  @rr14, r5
        ; addrof memVarAddr{r14}, exponent.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load exponent.1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        jr   if__55__end

and__56:
        ; branch param.erase{r11} equals 0: or_57
        cp   r11, #%00
        jr   eq, or__57
        ; move pending.4{r5}, pending.9{r3}
        ld   r5, r3
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%15
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; move pending.4{r9}, pending.4{r5}
        ld   r9, r5
        jr   for__48__continue

or__57:
        ; cast t.27.1{r0}(i16), target.1{r5}(u8)
        ld   r1, r5
        ld   r0, #0
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.1{r5}
        lde  @rr14, r5
        ; addrof memVarAddr{r14}, param.direction
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.direction{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%15
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; addrof t.26.1{r8}, tiles
        ld   r8, #hi(var_0)
        ld   r9, #lo(var_0)
        ; add t.26.2{r8}, t.27.1{r0}
        add  r9, r1
        adc  r8, r0
        ; load t.25.1{r5}, [t.26.2{r8}]
        lde  r5, @rr8
        ; addrof memVarAddr{r14}, exponent.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load exponent.1{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; branch exponent.1{r8} notequals t.25.1{r5}: drawMoveFrame@u8@u8@u8@bool.no_critical_edge_46
        cp   r8, r5
        jr   ne, drawMoveFrame_Pu8_Pu8_Pu8_Pbool_2eno__critical__edge__46
        ; move pending.4{r5}, pending.9{r3}
        ld   r5, r3
        ; addrof memVarAddr{r14}, pending.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], pending.4{r5}
        lde  @rr14, r5
        ; addrof memVarAddr{r14}, param.direction
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; load param.direction{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; addrof memVarAddr{r14}, pending.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; move pending.4{r9}, pending.4{r5}
        ld   r9, r5
        jr   for__48__continue

drawMoveFrame_Pu8_Pu8_Pu8_Pbool_2eno__critical__edge__46:
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; store [memVarAddr{r14}], pending.9{r3}
        lde  @rr14, r3
if__55__end:
        ; move displacement.1{r9}, offset.2{r2}
        ld   r9, r2
        ; addrof memVarAddr{r14}, offset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; store [memVarAddr{r14}], offset.2{r2}
        lde  @rr14, r2
        ; 307:3 if erase
        ; branch param.erase{r11} notequals 0: if_58_then
        cp   r11, #%00
        jr   ne, if__58__then
        ; addrof memVarAddr{r14}, oldOffset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], oldOffset.2{r4}
        lde  @rr14, r4
        jr   if__58__end

if__58__then:
        ; move displacement.3{r9}, oldOffset.2{r4}
        ld   r9, r4
        ; addrof memVarAddr{r14}, oldOffset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], oldOffset.2{r4}
        lde  @rr14, r4
if__58__end:
        ; branch forward.1{r13} notequals 0: if_59_end
        cp   r13, #%00
        jr   ne, if__59__end
        ; const t.28.1{r5}, 0
        ld   r5, #%00
        ; sub displacement.5{r5}, displacement.2{r9}
        sub  r5, r9
        ; move displacement.4{r9}, displacement.5{r5}
        ld   r9, r5
if__59__end:
        ; move t.29.1{r5}, index.2{r6}
        ld   r5, r6
        ; and t.29.1{r5}, 12
        and  r5, #%0c
        ; add row.1{r5}, 3
        add  r5, #%03
        ; move column.1{r7}, index.2{r6}
        ld   r7, r6
        ; addrof memVarAddr{r14}, index.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], index.2{r6}
        lde  @rr14, r6
        ; and column.1{r7}, 3
        and  r7, #%03
        ; move t.31.1{r6}, column.1{r7}
        ld   r6, r7
        ; shiftleft t.31.1{r6}, 3
        add r6, r6
        add r6, r6
        add r6, r6
        ; add t.30.1{r6}, 1
        inc  r6
        ; add column.2{r7}, t.30.1{r6}
        add  r7, r6
        ; 319:3 if horizontal
        ; branch horizontal.1{r12} notequals 0: if_60_then
        cp   r12, #%00
        jr   ne, if__60__then
        ; add row.2{r5}, displacement.4{r9}
        add  r5, r9
        ; move row.3{r9}, row.2{r5}
        ld   r9, r5
        ; move column.3{r1}, column.2{r7}
        ld   r1, r7
        jr   if__60__end

if__60__then:
        ; move column.4{r6}, column.2{r7}
        ld   r6, r7
        ; add column.4{r6}, displacement.4{r9}
        add  r6, r9
        ; move row.3{r9}, row.1{r5}
        ld   r9, r5
        ; move column.3{r1}, column.4{r6}
        ld   r1, r6
if__60__end:
        ; branch param.erase{r11} notequals 0: if_61_then
        cp   r11, #%00
        jr   ne, if__61__then
        ; cast t.33.1{r5}(i16), row.3{r9}(u8)
        ld   r6, r9
        ld   r5, #0
        ; cast t.34.1{r2}(i16), column.3{r1}(u8)
        ld   r3, r1
        ld   r2, #0
        ; move t.33.1{r0}, t.33.1{r5}
        ld   r0, r5
        ld   r1, r6
        ; move exponent.1{r4}, exponent.1{r8}
        ld   r4, r8
        ; call drawTileAt@i16@i16@u8[t.33.1{r0}, t.34.1{r2}, exponent.1{r4}]
        call drawTileAt_Pi16_Pi16_Pu8
        ; 331:4 if offset == distance
        ; addrof memVarAddr{r14}, distance.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; load distance.4{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        ; addrof memVarAddr{r14}, offset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; load offset.2{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; branch offset.2{r8} notequals distance.4{r9}: drawMoveFrame@u8@u8@u8@bool.no_critical_edge_42, if_62_then
        cp   r8, r9
        jr   ne, drawMoveFrame_Pu8_Pu8_Pu8_Pbool_2eno__critical__edge__42
        jr   if__62__then

if__61__then:
        ; addrof memVarAddr{r14}, column.3
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%11
        adc  r14, #%00
        ; store [memVarAddr{r14}], column.3{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, offset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; load offset.2{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move t.32.1{r3}, offset.2{r8}
        ld   r3, r8
        ; addrof memVarAddr{r14}, oldOffset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load oldOffset.2{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; sub t.32.1{r3}, oldOffset.2{r8}
        sub  r3, r8
        ; move row.3{r0}, row.3{r9}
        ld   r0, r9
        ; addrof memVarAddr{r14}, param.direction
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; load param.direction{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move param.direction{r2}, param.direction{r8}
        ld   r2, r8
        ; call clearTileTrail@u8@u8@u8@u8[row.3{r0}, column.3{r1}, param.direction{r2}, t.32.1{r3}]
        call clearTileTrail_Pu8_Pu8_Pu8_Pu8
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; load pending.9{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        jr   for__48__continue

drawMoveFrame_Pu8_Pu8_Pu8_Pbool_2eno__critical__edge__42:
        ; addrof memVarAddr{r14}, param.direction
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; load param.direction{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; load pending.9{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        jr   for__48__continue

if__62__then:
        ; addrof memVarAddr{r14}, param.direction
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; load param.direction{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; load pending.9{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        ; 332:5 if [...] & 128 != 0
        ; addrof memVarAddr{r14}, index.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load index.2{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; cast t.38.1{r2}(i16), index.2{r1}(u8)
        ld   r3, r1
        ld   r2, #0
        ; addrof t.37.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.37.2{r4}, t.38.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.36.1{r2}, [t.37.2{r4}]
        lde  r2, @rr4
        ; and t.35.1{r2}, 128
        and  r2, #%80
        ; branch t.35.1{r2} notequals 0: if_63_then
        cp   r2, #%00
        jr   ne, if__63__then
        ; 336:10 if [...] & 64 != 0
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load target.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; cast t.51.1{r2}(i16), target.1{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; addrof t.50.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.50.2{r4}, t.51.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.49.1{r2}, [t.50.2{r4}]
        lde  r2, @rr4
        ; and t.48.1{r2}, 64
        and  r2, #%40
        ; branch t.48.1{r2} equals 0: for_48_continue, if_64_then
        cp   r2, #%00
        jr   eq, for__48__continue
        jr   if__64__then

if__63__then:
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load target.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; cast t.42.1{r2}(i16), target.1{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; addrof t.41.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.41.2{r4}, t.42.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.40.1{r2}, [t.41.2{r4}]
        lde  r2, @rr4
        ; or t.39.1{r2}, 64
        or  r2, #%40
        ; cast t.44.1{r3}(i16), target.1{r0}(u8)
        ld   r4, r0
        ld   r3, #0
        ; addrof t.43.1{r6}, moveTargets
        ld   r6, #hi(var_2)
        ld   r7, #lo(var_2)
        ; add t.43.2{r6}, t.44.1{r3}
        add  r7, r4
        adc  r6, r3
        ; store [t.43.2{r6}], t.39.1{r2}
        lde  @rr6, r2
        ; const t.45.1{r2}, 0
        ld   r2, #%00
        ; cast t.47.1{r3}(i16), index.2{r1}(u8)
        ld   r4, r1
        ld   r3, #0
        ; addrof t.46.1{r6}, moveTiles
        ld   r6, #hi(var_1)
        ld   r7, #lo(var_1)
        ; add t.46.2{r6}, t.47.1{r3}
        add  r7, r4
        adc  r6, r3
        ; store [t.46.2{r6}], t.45.1{r2}
        lde  @rr6, r2
        jr   for__48__continue

if__64__then:
        ; addrof memVarAddr{r14}, index.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], index.2{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.1{r0}
        lde  @rr14, r0
        ; call t.53.1{r0} = tileRow@u8[target.1{r0}] -> u8
        call tileRow_Pu8
        ; cast t.52.1{r0}(i16), t.53.1{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; addrof memVarAddr{r14}, t.52.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%12
        adc  r14, #%00
        ; store [memVarAddr{r14}], t.52.1{r0}
        lde  @rr14, r0
        incw r14
        lde  @rr14, r1
        decw r14
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load target.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; call t.55.1{r0} = tileColumn@u8[target.1{r0}] -> u8
        call tileColumn_Pu8
        ; cast t.54.1{r2}(i16), t.55.1{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; load target.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; cast t.58.1{r5}(i16), target.1{r0}(u8)
        ld   r6, r0
        ld   r5, #0
        ; addrof t.57.1{r0}, tiles
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.57.2{r0}, t.58.1{r5}
        add  r1, r6
        adc  r0, r5
        ; load t.56.1{r4}, [t.57.2{r0}]
        lde  r4, @rr0
        ; addrof memVarAddr{r14}, t.52.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%12
        adc  r14, #%00
        ; load t.52.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; call drawTileAt@i16@i16@u8[t.52.1{r0}, t.54.1{r2}, t.56.1{r4}]
        call drawTileAt_Pi16_Pi16_Pu8
        ; const t.59.1{r1}, 0
        ld   r1, #%00
        ; addrof memVarAddr{r14}, index.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load index.2{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; cast t.61.1{r2}(i16), index.2{r2}(u8)
        ld   r3, r2
        ld   r2, #0
        ; addrof t.60.1{r4}, moveTiles
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; add t.60.2{r4}, t.61.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.60.2{r4}], t.59.1{r1}
        lde  @rr4, r1
for__48__continue:
        ; addrof memVarAddr{r14}, count.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load count.2{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; add count.5{r1}, 1
        inc  r1
        ; move pending.2{r0}, pending.4{r9}
        ld   r0, r9
for__48:
        ; branch count.2{r1} lt 16: for_48_body
        cp   r1, #%10
        jr   ult, for__48__body
        ; 343:9 return pending
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
        add  %31, #%0e
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void animateMove@u8
        ; arg direction (u8): r0
animateMove_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; move param.direction{r8}, direction{r0}
        ld   r8, r0
        ; const travel.1{r9}, 0
        ld   r9, #%00
        ; const speed.1{r10}, 1
        ld   r10, #%01
        ; const pending.1{r11}, 1
        ld   r11, #%01
        ; 352:2 while pending
        jr   while__65

while__65__body:
        ; move previous.1{r11}, travel.2{r9}
        ld   r11, r9
        ; add travel.3{r9}, speed.2{r10}
        add  r9, r10
        ; add speed.3{r10}, 1
        inc  r10
        ; const t.7.1{r3}, 1
        ld   r3, #%01
        ; move param.direction{r0}, param.direction{r8}
        ld   r0, r8
        ; move previous.1{r1}, previous.1{r11}
        ld   r1, r11
        ; move travel.3{r2}, travel.3{r9}
        ld   r2, r9
        ; call _ = drawMoveFrame@u8@u8@u8@bool[param.direction{r0}, previous.1{r1}, travel.3{r2}, t.7.1{r3}] -> bool
        call drawMoveFrame_Pu8_Pu8_Pu8_Pbool
        ; const t.8.1{r3}, 0
        ld   r3, #%00
        ; move param.direction{r0}, param.direction{r8}
        ld   r0, r8
        ; move previous.1{r1}, previous.1{r11}
        ld   r1, r11
        ; move travel.3{r2}, travel.3{r9}
        ld   r2, r9
        ; call pending.3{r0} = drawMoveFrame@u8@u8@u8@bool[param.direction{r0}, previous.1{r1}, travel.3{r2}, t.8.1{r3}] -> bool
        call drawMoveFrame_Pu8_Pu8_Pu8_Pbool
        ; move pending.3{r11}, pending.3{r0}
        ld   r11, r0
        ; call waitFrame[]
        call waitFrame
while__65:
        ; branch pending.2{r11} notequals 0: while_65_body
        cp   r11, #%00
        jr   ne, while__65__body
        ; const index.1{r8}, 0
        ld   r8, #%00
        ; 362:2 for index < 16
        jr   for__66

for__66__body:
        ; cast t.11.1{r9}(i16), index.2{r8}(u8)
        ld   r10, r8
        ld   r9, #0
        ; addrof t.10.1{r12}, moveTargets
        ld   r12, #hi(var_2)
        ld   r13, #lo(var_2)
        ; add t.10.2{r12}, t.11.1{r9}
        add  r13, r10
        adc  r12, r9
        ; load t.9.1{r9}, [t.10.2{r12}]
        lde  r9, @rr12
        ; and target.1{r9}, 15
        and  r9, #%0f
        ; 364:3 if [...] != 0 && [...] != [...]
        ; cast t.14.1{r10}(i16), index.2{r8}(u8)
        ld   r11, r8
        ld   r10, #0
        ; addrof t.13.1{r12}, moveTiles
        ld   r12, #hi(var_1)
        ld   r13, #lo(var_1)
        ; add t.13.2{r12}, t.14.1{r10}
        add  r13, r11
        adc  r12, r10
        ; load t.12.1{r10}, [t.13.2{r12}]
        lde  r10, @rr12
        ; branch t.12.1{r10} equals 0: for_66_continue
        cp   r10, #%00
        jr   eq, for__66__continue
        ; cast t.17.1{r10}(i16), index.2{r8}(u8)
        ld   r11, r8
        ld   r10, #0
        ; addrof t.16.1{r12}, moveTiles
        ld   r12, #hi(var_1)
        ld   r13, #lo(var_1)
        ; add t.16.2{r12}, t.17.1{r10}
        add  r13, r11
        adc  r12, r10
        ; load t.15.1{r10}, [t.16.2{r12}]
        lde  r10, @rr12
        ; cast t.20.1{r11}(i16), target.1{r9}(u8)
        ld   r12, r9
        ld   r11, #0
        ; addrof t.19.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.19.2{r2}, t.20.1{r11}
        add  r3, r12
        adc  r2, r11
        ; load t.18.1{r11}, [t.19.2{r2}]
        lde  r11, @rr2
        ; branch t.15.1{r10} equals t.18.1{r11}: for_66_continue
        cp   r10, r11
        jr   eq, for__66__continue
        ; move target.1{r0}, target.1{r9}
        ld   r0, r9
        ; call t.23.1{r0} = tileRow@u8[target.1{r0}] -> u8
        call tileRow_Pu8
        ; cast t.22.1{r10}(i16), t.23.1{r0}(u8)
        ld   r11, r0
        ld   r10, #0
        ; add t.21.1{r10}, 1
        incw r10
        ; move target.1{r0}, target.1{r9}
        ld   r0, r9
        ; call t.26.1{r0} = tileColumn@u8[target.1{r0}] -> u8
        call tileColumn_Pu8
        ; cast t.25.1{r12}(i16), t.26.1{r0}(u8)
        ld   r13, r0
        ld   r12, #0
        ; move t.24.1{r2}, t.25.1{r12}
        ld   r2, r12
        ld   r3, r13
        ; add t.24.1{r2}, 1
        incw r2
        ; move t.21.1{r0}, t.21.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; call setCursor@i16@i16[t.21.1{r0}, t.24.1{r2}]
        call setCursor_Pi16_Pi16
        ; cast t.29.1{r9}(i16), target.1{r9}(u8)
        ld   r10, r9
        ld   r9, #0
        ; addrof t.28.1{r12}, tiles
        ld   r12, #hi(var_0)
        ld   r13, #lo(var_0)
        ; add t.28.2{r12}, t.29.1{r9}
        add  r13, r10
        adc  r12, r9
        ; load t.27.1{r0}, [t.28.2{r12}]
        lde  r0, @rr12
        ; call printTile@u8[t.27.1{r0}]
        call printTile_Pu8
for__66__continue:
        ; move index.4{r0}, index.2{r8}
        ld   r0, r8
        ; add index.4{r0}, 1
        inc  r0
        ; move index.2{r8}, index.4{r0}
        ld   r8, r0
for__66:
        ; branch index.2{r8} lt 16: for_66_body
        cp   r8, #%10
        jr   ult, for__66__body
        ; restore clobbered non-volatile registers
        pop  r13
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
        ; const t.0.1{r0}, [string-15]
        ld   r0, #hi(string_15)
        ld   r1, #lo(string_15)
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
        ; 404:2 for row < 15
        jr   for__69

for__69__body:
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
        ; const t.2.1{r0}, [string-16]
        ld   r0, #hi(string_16)
        ld   r1, #lo(string_16)
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
for__69:
        ; branch row.2{r8} lt 15: for_69_body
        cp   r8, #%00
        jr   lt, for__69__body
        jr   ne, .lt4
        cp   r9, #%0f
        jr   ult, for__69__body
.lt4:
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
        ; 414:2 for boardRow < 4
        jr   for__70

for__70__body:
        ; const column.1{r12}, 1
        ld   r12, #%00
        ld   r13, #%01
        ; const boardColumn.1{r5}, 0
        ld   r5, #%00
        ; 416:3 for boardColumn < 4
        ; addrof memVarAddr{r14}, boardColumn.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], boardColumn.2{r5}
        lde  @rr14, r5
        ; move boardColumn.2{r3}, boardColumn.2{r5}
        ld   r3, r5
        jr   for__71

for__71__body:
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
for__71:
        ; branch boardColumn.2{r3} lt 4: for_71_body
        cp   r3, #%04
        jr   ult, for__71__body
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
for__70:
        ; branch boardRow.2{r11} lt 4: for_70_body
        cp   r11, #%04
        jr   ult, for__70__body
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
        ; const t.0.1{r0}, [string-17]
        ld   r0, #hi(string_17)
        ld   r1, #lo(string_17)
        ; call printString@@u8[t.0.1{r0}]
        call printString_P_Pu8
        ; addrof a.1.1{r8}, score
        ld   r8, #hi(var_3)
        ld   r9, #lo(var_3)
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
        ; const t.3.1{r0}, [string-18]
        ld   r0, #hi(string_18)
        ld   r1, #lo(string_18)
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
        ; const t.0.1{r0}, [string-19]
        ld   r0, #hi(string_19)
        ld   r1, #lo(string_19)
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
        ; 436:2 if gameState == 1
        ; addrof a.1.1{r8}, gameState
        ld   r8, #hi(var_4)
        ld   r9, #lo(var_4)
        ; load t.2.1{r10}, [a.1.1{r8}]
        lde  r10, @rr8
        ; branch t.2.1{r10} equals 1: if_72_then
        cp   r10, #%01
        jr   eq, if__72__then
        ; 439:7 if gameState == 2
        ; branch t.5.1{r10} notequals 2: drawStatus_ret, if_73_then
        cp   r10, #%02
        jr   ne, drawStatus__ret
        jr   if__73__then

if__72__then:
        ; const t.3.1{r0}, [string-20]
        ld   r0, #hi(string_20)
        ld   r1, #lo(string_20)
        ; call printString@@u8[t.3.1{r0}]
        call printString_P_Pu8
        jr   drawStatus__ret

if__73__then:
        ; const t.6.1{r0}, [string-21]
        ld   r0, #hi(string_21)
        ld   r1, #lo(string_21)
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
        ; 445:2 for index < 16
        jr   for__74

for__74__body:
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
for__74:
        ; branch index.2{r8} lt 16: for_74_body
        cp   r8, #%10
        jr   ult, for__74__body
        ; const t.4.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%00
        ; addrof a.5.1{r12}, score
        ld   r12, #hi(var_3)
        ld   r13, #lo(var_3)
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
        ; call drawScore[]
        call drawScore
        ; const t.6.1{r8}, 0
        ld   r8, #%00
        ; addrof a.7.1{r10}, gameState
        ld   r10, #hi(var_4)
        ld   r11, #lo(var_4)
        ; store [a.7.1{r10}], t.6.1{r8}
        lde  @rr10, r8
        ; call _ = spawnTile[] -> u8
        call spawnTile
        ; call _ = spawnTile[] -> u8
        call spawnTile
        ; call drawBoard[]
        call drawBoard
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
        ; const t.3.1{r8}, 0
        ld   r8, #%00
        ld   r9, #%00
        ld   r10, #%00
        ld   r11, #%00
        ; addrof a.4.1{r12}, score
        ld   r12, #hi(var_3)
        ld   r13, #lo(var_3)
        ; store [a.4.1{r12}], t.3.1{r8}
        lde  @rr12, r8
        incw r12
        lde  @rr12, r9
        incw r12
        lde  @rr12, r10
        incw r12
        lde  @rr12, r11
        sub  r13, #3
        sbc  r12, #0
        ; const t.5.1{r8}, 0
        ld   r8, #%00
        ; addrof a.6.1{r10}, gameState
        ld   r10, #hi(var_4)
        ld   r11, #lo(var_4)
        ; store [a.6.1{r10}], t.5.1{r8}
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
        ; 462:2 while true
        jr   while__75

if__76__end:
        ; branch key.1{r8} equals 114: if_77_then
        cp   r9, #%72
        jr   ne, .notEquals5
        cp   r8, #%00
        jr   eq, if__77__then
.notEquals5:
        ; branch key.1{r8} equals 82: if_77_then
        cp   r9, #%52
        jr   ne, .notEquals6
        cp   r8, #%00
        jr   eq, if__77__then
.notEquals6:
        ; 471:3 if gameState != 0
        ; addrof a.7.1{r10}, gameState
        ld   r10, #hi(var_4)
        ld   r11, #lo(var_4)
        ; load t.8.1{r12}, [a.7.1{r10}]
        lde  r12, @rr10
        ; branch t.8.1{r12} notequals 0: while_75
        cp   r12, #%00
        jr   ne, while__75
        ; branch key.1{r8} equals 1: if_80_then, or_82
        cp   r9, #%01
        jr   ne, .notEquals7
        cp   r8, #%00
        jr   eq, if__80__then
.notEquals7:
        jr   or__82

if__77__then:
        ; call newGame[]
        call newGame
        jr   while__75

or__82:
        ; branch key.1{r8} equals 97: if_80_then
        cp   r9, #%61
        jr   ne, .notEquals8
        cp   r8, #%00
        jr   eq, if__80__then
.notEquals8:
        ; branch key.1{r8} equals 65: if_80_then
        cp   r9, #%41
        jr   ne, .notEquals9
        cp   r8, #%00
        jr   eq, if__80__then
.notEquals9:
        ; branch key.1{r8} equals 2: if_83_then
        cp   r9, #%02
        jr   ne, .notEquals10
        cp   r8, #%00
        jr   eq, if__83__then
.notEquals10:
        ; branch key.1{r8} equals 100: if_83_then, or_84
        cp   r9, #%64
        jr   ne, .notEquals11
        cp   r8, #%00
        jr   eq, if__83__then
.notEquals11:
        jr   or__84

if__80__then:
        ; const direction.2{r8}, 0
        ld   r8, #%00
        jr   if__80__end

or__84:
        ; branch key.1{r8} equals 68: if_83_then
        cp   r9, #%44
        jr   ne, .notEquals12
        cp   r8, #%00
        jr   eq, if__83__then
.notEquals12:
        ; branch key.1{r8} equals 3: if_86_then
        cp   r9, #%03
        jr   ne, .notEquals13
        cp   r8, #%00
        jr   eq, if__86__then
.notEquals13:
        ; branch key.1{r8} equals 119: if_86_then, or_87
        cp   r9, #%77
        jr   ne, .notEquals14
        cp   r8, #%00
        jr   eq, if__86__then
.notEquals14:
        jr   or__87

if__83__then:
        ; const direction.4{r8}, 1
        ld   r8, #%01
        jr   if__80__end

or__87:
        ; branch key.1{r8} equals 87: if_86_then
        cp   r9, #%57
        jr   ne, .notEquals15
        cp   r8, #%00
        jr   eq, if__86__then
.notEquals15:
        ; branch key.1{r8} equals 4: if_89_then
        cp   r9, #%04
        jr   ne, .notEquals16
        cp   r8, #%00
        jr   eq, if__89__then
.notEquals16:
        ; branch key.1{r8} equals 115: if_89_then, or_90
        cp   r9, #%73
        jr   ne, .notEquals17
        cp   r8, #%00
        jr   eq, if__89__then
.notEquals17:
        jr   or__90

if__86__then:
        ; const direction.5{r8}, 2
        ld   r8, #%02
        jr   if__80__end

or__90:
        ; branch key.1{r8} notequals 83: while_75, if_89_then
        cp   r9, #%53
        jr   ne, while__75
        cp   r8, #%00
        jr   ne, while__75
if__89__then:
        ; const direction.6{r8}, 3
        ld   r8, #%03
if__80__end:
        ; 491:3 if !slide@u8([ExprVarAccess[varName=direction, index=1, scope=function, type=u8, varIsArray=false, location=491:13]])
        ; move direction.3{r0}, direction.3{r8}
        ld   r0, r8
        ; call t.9.1{r0} = slide@u8[direction.3{r0}] -> bool
        call slide_Pu8
        ; branch t.9.1{r0} equals 0: while_75
        cp   r0, #%00
        jr   eq, while__75
        ; move direction.3{r0}, direction.3{r8}
        ld   r0, r8
        ; call animateMove@u8[direction.3{r0}]
        call animateMove_Pu8
        ; call spawned.1{r0} = spawnTile[] -> u8
        call spawnTile
        ; move spawned.1{r8}, spawned.1{r0}
        ld   r8, r0
        ; 497:3 if spawned != 255
        ; branch spawned.1{r8} equals 255: if_93_end
        cp   r8, #%ff
        jr   eq, if__93__end
        ; call t.11.1{r0} = tileRow@u8[spawned.1{r0}] -> u8
        call tileRow_Pu8
        ; cast t.10.1{r9}(i16), t.11.1{r0}(u8)
        ld   r10, r0
        ld   r9, #0
        ; move spawned.1{r0}, spawned.1{r8}
        ld   r0, r8
        ; call t.13.1{r0} = tileColumn@u8[spawned.1{r0}] -> u8
        call tileColumn_Pu8
        ; cast t.12.1{r2}(i16), t.13.1{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; cast t.16.1{r11}(i16), spawned.1{r8}(u8)
        ld   r12, r8
        ld   r11, #0
        ; addrof t.15.1{r6}, tiles
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add t.15.2{r6}, t.16.1{r11}
        add  r7, r12
        adc  r6, r11
        ; load t.14.1{r4}, [t.15.2{r6}]
        lde  r4, @rr6
        ; move t.10.1{r0}, t.10.1{r9}
        ld   r0, r9
        ld   r1, r10
        ; call drawTileAt@i16@i16@u8[t.10.1{r0}, t.12.1{r2}, t.14.1{r4}]
        call drawTileAt_Pi16_Pi16_Pu8
if__93__end:
        ; 500:3 if gameState == 0 && !canMove([])
        ; addrof a.17.1{r8}, gameState
        ld   r8, #hi(var_4)
        ld   r9, #lo(var_4)
        ; load t.18.1{r10}, [a.17.1{r8}]
        lde  r10, @rr8
        ; branch t.18.1{r10} notequals 0: if_94_end
        cp   r10, #%00
        jr   ne, if__94__end
        ; call t.19.1{r0} = canMove[] -> bool
        call canMove
        ; branch t.19.1{r0} notequals 0: if_94_end
        cp   r0, #%00
        jr   ne, if__94__end
        ; const t.20.1{r8}, 2
        ld   r8, #%02
        ; addrof a.21.1{r10}, gameState
        ld   r10, #hi(var_4)
        ld   r11, #lo(var_4)
        ; store [a.21.1{r10}], t.20.1{r8}
        lde  @rr10, r8
if__94__end:
        ; call drawScore[]
        call drawScore
        ; 504:3 if gameState != 0
        ; addrof a.22.1{r8}, gameState
        ld   r8, #hi(var_4)
        ld   r9, #lo(var_4)
        ; load t.23.1{r10}, [a.22.1{r8}]
        lde  r10, @rr8
        ; branch t.23.1{r10} equals 0: if_96_end
        cp   r10, #%00
        jr   eq, if__96__end
        ; call drawStatus[]
        call drawStatus
if__96__end:
        ; const arg.13.0{r0}, 21
        ld   r0, #%00
        ld   r1, #%15
        ; const arg.13.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor@i16@i16[arg.13.0{r0}, arg.13.1{r2}]
        call setCursor_Pi16_Pi16
while__75:
        ; call key.1{r0} = getChar[] -> i16
        call getChar
        ; move key.1{r8}, key.1{r0}
        ld   r9, r1
        ld   r8, r0
        ; 464:3 if key == 27
        ; branch key.1{r8} notequals 27: if_76_end
        cp   r9, #%1b
        jr   ne, if__76__end
        cp   r8, #%00
        jr   ne, if__76__end
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

        ; void waitFrame
waitFrame:
        ret

        ; variable 0: tiles[] (u8*/16)
var_0:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 1: moveTiles[] (u8*/16)
var_1:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 2: moveTargets[] (u8*/16)
var_2:
        .data %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00 %00
        ; variable 3: score (i32/4)
var_3:
        .data %00 %00 %00 %00
        ; variable 4: gameState (u8/1)
var_4:
        .data %00

string_0:
        .data "      " %00
string_1:
        .data "   2  " %00
string_2:
        .data "   4  " %00
string_3:
        .data "   8  " %00
string_4:
        .data "  16  " %00
string_5:
        .data "  32  " %00
string_6:
        .data "  64  " %00
string_7:
        .data "  128 " %00
string_8:
        .data "  256 " %00
string_9:
        .data "  512 " %00
string_10:
        .data " 1024 " %00
string_11:
        .data " 2048 " %00
string_12:
        .data "  ?   " %00
string_13:
        .data "+------+" %00
string_14:
        .data "        " %00
string_15:
        .data "Arrows/WASD  R restart  Esc quit" %00
string_16:
        .data "                                   " %00
string_17:
        .data "2048  Score: " %00
string_18:
        .data "          " %00
string_19:
        .data "                                      " %00
string_20:
        .data "2048! Press R to play again." %00
string_21:
        .data "No moves left. Press R to restart." %00

