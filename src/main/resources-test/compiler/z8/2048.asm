        .const  RP    = %FD
        .const  SPH   = %FE
        .const  SPL   = %FF

        .org %e000

        srp  #%20
        jr   main

        ; i16 tileValue_Pu8
        ; arg exponent (u8): r0
tileValue_Pu8:
        ; const value.1{r1}, 1
        ld   r1, #%00
        ld   r2, #%01
        ; const index.1{r3}, 0
        ld   r3, #%00
        ; 32:2 for index < exponent
        jr   for_1

for_1_body:
        ; shiftleft value.3{r1}, 1
        add r2, r2
        adc r1, r1
        ; add index.3{r3}, 1
        inc  r3
for_1:
        ; branch index.2{r3} lt param.exponent{r0}: for_1_body
        cp   r3, r0
        jr   ult, for_1_body
        ; 35:9 return value
        ; move value.2{r0}, value.2{r1}
        ld   r0, r1
        ld   r1, r2
        ret

        ; void spawnTile
spawnTile:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const emptyCount.1{r0}, 0
        ld   r0, #%00
        ; const index.1{r1}, 0
        ld   r1, #%00
        ; 40:2 for index < 16
        ; move emptyCount.2{r8}, emptyCount.1{r0}
        ld   r8, r0
        jr   for_2

for_2_body:
        ; 41:3 if [...] == 0
        ; cast t.7.1{r1}(i16), index.2{r0}(u8)
        ld   r2, r0
        ld   r1, #0
        ; addrof t.6.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.6.2{r4}, t.7.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load t.5.1{r1}, [t.6.2{r4}]
        lde  r1, @rr4
        ; branch t.5.1{r1} equals 0: if_3_then
        cp   r1, #%00
        jr   eq, if_3_then
        ; move emptyCount.3{r1}, emptyCount.2{r8}
        ld   r1, r8
        jr   for_2_continue

if_3_then:
        ; move emptyCount.4{r1}, emptyCount.2{r8}
        ld   r1, r8
        ; add emptyCount.4{r1}, 1
        inc  r1
for_2_continue:
        ; add index.6{r0}, 1
        inc  r0
        ; move emptyCount.2{r8}, emptyCount.3{r1}
        ld   r8, r1
for_2:
        ; branch index.2{r0} lt 16: for_2_body
        cp   r0, #%10
        jr   ult, for_2_body
        ; branch emptyCount.2{r8} equals 0: spawnTile_ret
        cp   r8, #%00
        jr   eq, spawnTile_ret
        ; call t.9.1{r0} = random16[] -> i16
        call random16
        ; cast t.10.1{r2}(i16), emptyCount.2{r8}(u8)
        ld   r3, r8
        ld   r2, #0
        ; mod t.8.1{r0}, t.10.1{r2}
        ld   %12, r0
        ld   %13, r1
        ld   %14, r2
        ld   %15, r3
        srp  #%10
        call %011F ; mod
        srp  #%20
        ld   r0, %12
        ld   r1, %13
        ; cast chosen.1{r0}(u8), t.8.1{r0}(i16)
        ld   r0, r1
        ; const index.3{r1}, 0
        ld   r1, #%00
        ; 50:2 for index < 16
        ; move index.4{r8}, index.3{r1}
        ld   r8, r1
        jr   for_5

for_5_body:
        ; 51:3 if [...] != 0
        ; cast t.13.1{r1}(i16), index.4{r8}(u8)
        ld   r2, r8
        ld   r1, #0
        ; addrof t.12.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.12.2{r4}, t.13.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load t.11.1{r1}, [t.12.2{r4}]
        lde  r1, @rr4
        ; branch t.11.1{r1} notequals 0: for_5_continue
        cp   r1, #%00
        jr   ne, for_5_continue
        ; branch chosen.2{r0} equals 0: if_7_then
        cp   r0, #%00
        jr   eq, if_7_then
        ; sub chosen.4{r0}, 1
        dec  r0
for_5_continue:
        ; move index.8{r1}, index.4{r8}
        ld   r1, r8
        ; add index.8{r1}, 1
        inc  r1
        ; move index.4{r8}, index.8{r1}
        ld   r8, r1
for_5:
        ; branch index.4{r8} gteq 16: spawnTile_ret, for_5_body
        cp   r8, #%10
        jr   uge, spawnTile_ret
        jr   for_5_body

if_7_then:
        ; const tile.1{r9}, 1
        ld   r9, #%01
        ; 56:4 if random16([]) % 10 == 0
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
        jr   eq, if_8_then
.notEquals1:
        ; move tile.2{r0}, tile.1{r9}
        ld   r0, r9
        jr   if_8_end

if_8_then:
        ; const tile.3{r0}, 2
        ld   r0, #%02
if_8_end:
        ; cast t.17.1{r1}(i16), index.4{r8}(u8)
        ld   r2, r8
        ld   r1, #0
        ; addrof t.16.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.16.2{r4}, t.17.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.16.2{r4}], tile.2{r0}
        lde  @rr4, r0
        ; 60:4 return
spawnTile_ret:
        ; restore clobbered non-volatile registers
        pop  r9
        pop  r8
        ret

        ; bool slideLine_Pu8_Pu8
        ; arg first (u8): r0
        ; arg step (u8): r1
        ; var position.2 (u8): SP+8
        ; var tile.1 (u8): SP+9
        ; var merged.2 (bool): SP+10
        ; var param.first (u8): SP+11
        ; var param.step (u8): SP+12
slideLine_Pu8_Pu8:
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
        ; move param.first{r8}, first{r0}
        ld   r8, r0
        ; move param.step{r9}, step{r1}
        ld   r9, r1
        ; move target.1{r1}, param.first{r8}
        ld   r1, r8
        ; const previousMerged.1{r2}, 0
        ld   r2, #%00
        ; const moved.1{r3}, 0
        ld   r3, #%00
        ; const position.1{r4}, 0
        ld   r4, #%00
        ; 71:2 for position < 4
        ; move source.2{r10}, source.1{r0}
        ld   r10, r0
        ; move target.2{r11}, target.1{r1}
        ld   r11, r1
        ; move previousMerged.2{r12}, previousMerged.1{r2}
        ld   r12, r2
        ; move moved.2{r13}, moved.1{r3}
        ld   r13, r3
        ; move position.2{r0}, position.1{r4}
        ld   r0, r4
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], position.2{r0}
        lde  @rr14, r0
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; move param.step{r2}, param.step{r9}
        ld   r2, r9
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; move position.2{r1}, position.2{r0}
        ld   r1, r0
        jr   for_9

for_9_body:
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], position.2{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; load param.first{r8}, [memVarAddr{r14}]
        lde  r8, @rr14
        ; move param.step{r9}, param.step{r2}
        ld   r9, r2
        ; cast t.14.1{r0}(i16), source.2{r10}(u8)
        ld   r1, r10
        ld   r0, #0
        ; addrof sourceTile.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add sourceTile.2{r2}, t.14.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load tile.1{r0}, [sourceTile.2{r2}]
        lde  r0, @rr2
        ; 74:3 if tile != 0
        ; branch tile.1{r0} notequals 0: if_10_then
        cp   r0, #%00
        jr   ne, if_10_then
        ; move param.step{r2}, param.step{r9}
        ld   r2, r9
        jr   if_10_end

if_10_then:
        ; const t.15.1{r1}, 0
        ld   r1, #%00
        ; store [sourceTile.2{r2}], t.15.1{r1}
        lde  @rr2, r1
        ; const merged.1{r1}, 0
        ld   r1, #%00
        ; 77:4 if target != first && !previousMerged
        ; branch target.2{r11} notequals param.first{r8}: and_12
        cp   r11, r8
        jr   ne, and_12
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r0}
        lde  @rr14, r0
        ; move merged.2{r0}, merged.2{r1}
        ld   r0, r1
        jr   if_11_end

and_12:
        ; branch previousMerged.2{r12} equals 0: if_11_then
        cp   r12, #%00
        jr   eq, if_11_then
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r0}
        lde  @rr14, r0
        ; move merged.2{r0}, merged.2{r1}
        ld   r0, r1
        jr   if_11_end

if_11_then:
        ; move previous.1{r2}, target.2{r11}
        ld   r2, r11
        ; sub previous.1{r2}, param.step{r9}
        sub  r2, r9
        ; cast t.16.1{r2}(i16), previous.1{r2}(u8)
        ld   r3, r2
        ld   r2, #0
        ; addrof previousTile.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add previousTile.2{r4}, t.16.1{r2}
        add  r5, r3
        adc  r4, r2
        ; 80:5 if *previousTile == tile
        ; load t.17.1{r2}, [previousTile.2{r4}]
        lde  r2, @rr4
        ; branch t.17.1{r2} equals tile.1{r0}: if_13_then
        cp   r2, r0
        jr   eq, if_13_then
        ; addrof memVarAddr{r14}, merged.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], merged.2{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r0}
        lde  @rr14, r0
        ; addrof memVarAddr{r14}, merged.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; move merged.2{r0}, merged.2{r1}
        ld   r0, r1
        jr   if_11_end

if_13_then:
        ; move nextTile.1{r12}, tile.1{r0}
        ld   r12, r0
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], tile.1{r0}
        lde  @rr14, r0
        ; add nextTile.1{r12}, 1
        inc  r12
        ; store [previousTile.2{r4}], nextTile.1{r12}
        lde  @rr4, r12
        ; move nextTile.1{r0}, nextTile.1{r12}
        ld   r0, r12
        ; call t.18.1{r0} = tileValue_Pu8[nextTile.1{r0}] -> i16
        call tileValue_Pu8
        ; cast mergedScore.1{r0}(i32), t.18.1{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; addrof a.20.1{r4}, score
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; addrof memVarAddr{r14}, param.first
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.first{r8}
        lde  @rr14, r8
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.step{r9}
        lde  @rr14, r9
        ; load t.21.1{r6}, [a.20.1{r4}]
        lde  r6, @rr4
        incw r4
        lde  r7, @rr4
        incw r4
        lde  r8, @rr4
        incw r4
        lde  r9, @rr4
        sub  r5, #3
        sbc  r4, #0
        ; move t.19.1{r4}, t.21.1{r6}
        ld   r4, r6
        ld   r5, r7
        ld   r6, r8
        ld   r7, r9
        ; add t.19.1{r4}, mergedScore.1{r0}
        add  r7, r3
        adc  r6, r2
        adc  r5, r1
        adc  r4, r0
        ; addrof a.22.1{r0}, score
        ld   r0, #hi(var_1)
        ld   r1, #lo(var_1)
        ; store [a.22.1{r0}], t.19.1{r4}
        lde  @rr0, r4
        incw r0
        lde  @rr0, r5
        incw r0
        lde  @rr0, r6
        incw r0
        lde  @rr0, r7
        sub  r1, #3
        sbc  r0, #0
        ; 85:6 if nextTile == 11
        ; branch nextTile.1{r12} notequals 11: if_14_end
        cp   r12, #%0b
        jr   ne, if_14_end
        ; const t.23.1{r0}, 1
        ld   r0, #%01
        ; addrof a.24.1{r2}, gameState
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.24.1{r2}], t.23.1{r0}
        lde  @rr2, r0
if_14_end:
        ; const merged.3{r0}, 1
        ld   r0, #%01
        ; const previousMerged.6{r1}, 1
        ld   r1, #%01
        ; const moved.7{r2}, 1
        ld   r2, #%01
        ; move previousMerged.4{r12}, previousMerged.6{r1}
        ld   r12, r1
        ; move moved.4{r13}, moved.7{r2}
        ld   r13, r2
if_11_end:
        ; branch merged.2{r0} equals 0: if_15_then
        cp   r0, #%00
        jr   eq, if_15_then
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load param.step{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        jr   if_10_end

if_15_then:
        ; cast t.26.1{r0}(i16), target.2{r11}(u8)
        ld   r1, r11
        ld   r0, #0
        ; addrof t.25.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.25.2{r2}, t.26.1{r0}
        add  r3, r1
        adc  r2, r0
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load tile.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; store [t.25.2{r2}], tile.1{r0}
        lde  @rr2, r0
        ; 95:5 if target != source
        ; branch target.2{r11} notequals source.2{r10}: if_16_then
        cp   r11, r10
        jr   ne, if_16_then
        ; move moved.5{r0}, moved.4{r13}
        ld   r0, r13
        jr   if_16_end

if_16_then:
        ; const moved.6{r0}, 1
        ld   r0, #%01
if_16_end:
        ; move target.7{r1}, target.2{r11}
        ld   r1, r11
        ; addrof memVarAddr{r14}, param.step
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load param.step{r2}, [memVarAddr{r14}]
        lde  r2, @rr14
        ; add target.7{r1}, param.step{r2}
        add  r1, r2
        ; const previousMerged.5{r3}, 0
        ld   r3, #%00
        ; move target.3{r11}, target.7{r1}
        ld   r11, r1
        ; move previousMerged.3{r12}, previousMerged.5{r3}
        ld   r12, r3
        ; move moved.3{r13}, moved.5{r0}
        ld   r13, r0
if_10_end:
        ; move source.4{r0}, source.2{r10}
        ld   r0, r10
        ; add source.4{r0}, param.step{r2}
        add  r0, r2
        ; addrof memVarAddr{r14}, position.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load position.2{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; add position.5{r1}, 1
        inc  r1
        ; move source.2{r10}, source.4{r0}
        ld   r10, r0
for_9:
        ; branch position.2{r1} lt 4: for_9_body
        cp   r1, #%04
        jr   ult, for_9_body
        ; 104:9 return moved
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
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        ret

        ; bool slide_Pu8
        ; arg direction (u8): r0
slide_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; move param.direction{r8}, direction{r0}
        ld   r8, r0
        ; const moved.1{r0}, 0
        ld   r0, #%00
        ; const line.1{r1}, 0
        ld   r1, #%00
        ; 109:2 for line < 4
        ; move moved.2{r9}, moved.1{r0}
        ld   r9, r0
        ; move line.2{r10}, line.1{r1}
        ld   r10, r1
        jr   for_17

for_17_body:
        ; move first.1{r0}, line.2{r10}
        ld   r0, r10
        ; shiftleft first.1{r0}, 2
        add r0, r0
        add r0, r0
        ; const step.1{r1}, 1
        ld   r1, #%01
        ; 112:3 if direction == 1
        ; branch param.direction{r8} equals 1: if_18_then
        cp   r8, #%01
        jr   eq, if_18_then
        ; branch param.direction{r8} notequals 2: if_19_else, if_19_then
        cp   r8, #%02
        jr   ne, if_19_else
        jr   if_19_then

if_18_then:
        ; add first.2{r0}, 3
        add  r0, #%03
        ; const step.2{r1}, 255
        ld   r1, #%ff
        jr   if_18_end

if_19_else:
        ; branch param.direction{r8} notequals 3: if_18_end, if_20_then
        cp   r8, #%03
        jr   ne, if_18_end
        jr   if_20_then

if_19_then:
        ; move first.4{r0}, line.2{r10}
        ld   r0, r10
        ; const step.4{r1}, 4
        ld   r1, #%04
        jr   if_18_end

if_20_then:
        ; move first.5{r0}, line.2{r10}
        ld   r0, r10
        ; add first.5{r0}, 12
        add  r0, #%0c
        ; const step.5{r1}, 252
        ld   r1, #%fc
if_18_end:
        ; 124:3 if slideLine_Pu8_Pu8([ExprVarAccess[varName=first, index=3, scope=function, type=u8, varIsArray=false, location=124:16], ExprVarAccess[varName=step, index=4, scope=function, type=u8, varIsArray=false, location=124:23]])
        ; call t.5.1{r0} = slideLine_Pu8_Pu8[first.3{r0}, step.3{r1}] -> bool
        call slideLine_Pu8_Pu8
        ; branch t.5.1{r0} notequals 0: if_21_then
        cp   r0, #%00
        jr   ne, if_21_then
        ; move moved.4{r0}, moved.2{r9}
        ld   r0, r9
        jr   for_17_continue

if_21_then:
        ; const moved.5{r0}, 1
        ld   r0, #%01
for_17_continue:
        ; move line.5{r1}, line.2{r10}
        ld   r1, r10
        ; add line.5{r1}, 1
        inc  r1
        ; move moved.2{r9}, moved.4{r0}
        ld   r9, r0
        ; move line.2{r10}, line.5{r1}
        ld   r10, r1
for_17:
        ; branch line.2{r10} lt 4: for_17_body
        cp   r10, #%04
        jr   ult, for_17_body
        ; 128:9 return moved
        ; move moved.2{r0}, moved.2{r9}
        ld   r0, r9
        ; restore clobbered non-volatile registers
        pop  r10
        pop  r9
        pop  r8
        ret

        ; bool canMove
canMove:
        ; const index.1{r0}, 0
        ld   r0, #%00
        ; 132:2 for index < 16
        jr   for_22

for_22_body:
        ; cast t.3.1{r1}(i16), index.2{r0}(u8)
        ld   r2, r0
        ld   r1, #0
        ; addrof t.2.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.2.2{r4}, t.3.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load tile.1{r1}, [t.2.2{r4}]
        lde  r1, @rr4
        ; 134:3 if tile == 0
        ; branch tile.1{r1} equals 0: if_23_then
        cp   r1, #%00
        jr   eq, if_23_then
        ; 137:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r2}, index.2{r0}
        ld   r2, r0
        ; and t.4.1{r2}, 3
        and  r2, #%03
        ; branch t.4.1{r2} equals 3: if_24_end
        cp   r2, #%03
        jr   eq, if_24_end
        ; move t.8.1{r2}, index.2{r0}
        ld   r2, r0
        ; add t.8.1{r2}, 1
        inc  r2
        ; cast t.7.1{r2}(i16), t.8.1{r2}(u8)
        ld   r3, r2
        ld   r2, #0
        ; addrof t.6.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.6.2{r4}, t.7.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.5.1{r2}, [t.6.2{r4}]
        lde  r2, @rr4
        ; branch t.5.1{r2} equals tile.1{r1}: if_24_then, if_24_end
        cp   r2, r1
        jr   eq, if_24_then
if_24_end:
        ; branch index.2{r0} gteq 12: for_22_continue
        cp   r0, #%0c
        jr   uge, for_22_continue
        ; move t.12.1{r2}, index.2{r0}
        ld   r2, r0
        ; add t.12.1{r2}, 4
        add  r2, #%04
        ; cast t.11.1{r2}(i16), t.12.1{r2}(u8)
        ld   r3, r2
        ld   r2, #0
        ; addrof t.10.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.10.2{r4}, t.11.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.9.1{r2}, [t.10.2{r4}]
        lde  r2, @rr4
        ; branch t.9.1{r2} equals tile.1{r1}: if_26_then, for_22_continue
        cp   r2, r1
        jr   eq, if_26_then
for_22_continue:
        ; add index.5{r0}, 1
        inc  r0
for_22:
        ; branch index.2{r0} lt 16: for_22_body
        cp   r0, #%10
        jr   ult, for_22_body
        ; const {r0}, 0
        ld   r0, #%00
        jr   canMove_ret

if_23_then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove_ret

if_24_then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove_ret

if_26_then:
        ; const {r0}, 1
        ld   r0, #%01
canMove_ret:
        ret

        ; void printTile_Pu8
        ; arg exponent (u8): r0
printTile_Pu8:
        ; save clobbered non-volatile registers
        push r8
        ; move param.exponent{r8}, exponent{r0}
        ld   r8, r0
        ; branch param.exponent{r8} equals 0: if_28_then
        cp   r8, #%00
        jr   eq, if_28_then
        ; branch param.exponent{r8} notequals 1: if_29_else, if_29_then
        cp   r8, #%01
        jr   ne, if_29_else
        jr   if_29_then

if_28_then:
        ; const t.1.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString_P_pu8[t.1.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_29_else:
        ; branch param.exponent{r8} notequals 2: if_30_else, if_30_then
        cp   r8, #%02
        jr   ne, if_30_else
        jr   if_30_then

if_29_then:
        ; const t.2.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_30_else:
        ; branch param.exponent{r8} notequals 3: if_31_else, if_31_then
        cp   r8, #%03
        jr   ne, if_31_else
        jr   if_31_then

if_30_then:
        ; const t.3.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_31_else:
        ; branch param.exponent{r8} notequals 4: if_32_else, if_32_then
        cp   r8, #%04
        jr   ne, if_32_else
        jr   if_32_then

if_31_then:
        ; const t.4.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString_P_pu8[t.4.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_32_else:
        ; branch param.exponent{r8} notequals 5: if_33_else, if_33_then
        cp   r8, #%05
        jr   ne, if_33_else
        jr   if_33_then

if_32_then:
        ; const t.5.1{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString_P_pu8[t.5.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_33_else:
        ; branch param.exponent{r8} notequals 6: if_34_else, if_34_then
        cp   r8, #%06
        jr   ne, if_34_else
        jr   if_34_then

if_33_then:
        ; const t.6.1{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString_P_pu8[t.6.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_34_else:
        ; branch param.exponent{r8} notequals 7: if_35_else, if_35_then
        cp   r8, #%07
        jr   ne, if_35_else
        jr   if_35_then

if_34_then:
        ; const t.7.1{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString_P_pu8[t.7.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_35_else:
        ; branch param.exponent{r8} notequals 8: if_36_else, if_36_then
        cp   r8, #%08
        jr   ne, if_36_else
        jr   if_36_then

if_35_then:
        ; const t.8.1{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
        ; call printString_P_pu8[t.8.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_36_else:
        ; branch param.exponent{r8} notequals 9: if_37_else, if_37_then
        cp   r8, #%09
        jr   ne, if_37_else
        jr   if_37_then

if_36_then:
        ; const t.9.1{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString_P_pu8[t.9.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_37_else:
        ; branch param.exponent{r8} notequals 10: if_38_else, if_38_then
        cp   r8, #%0a
        jr   ne, if_38_else
        jr   if_38_then

if_37_then:
        ; const t.10.1{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString_P_pu8[t.10.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_38_else:
        ; branch param.exponent{r8} notequals 11: if_39_else, if_39_then
        cp   r8, #%0b
        jr   ne, if_39_else
        jr   if_39_then

if_38_then:
        ; const t.11.1{r0}, [string-10]
        ld   r0, #hi(string_10)
        ld   r1, #lo(string_10)
        ; call printString_P_pu8[t.11.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_39_else:
        ; const t.13.1{r0}, [string-12]
        ld   r0, #hi(string_12)
        ld   r1, #lo(string_12)
        ; call printString_P_pu8[t.13.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_39_then:
        ; const t.12.1{r0}, [string-11]
        ld   r0, #hi(string_11)
        ld   r1, #lo(string_11)
        ; call printString_P_pu8[t.12.1{r0}]
        call printString_P_pu8
printTile_Pu8_ret:
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void drawFrame
drawFrame:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; const arg.0.0{r0}, 12
        ld   r0, #%0c
        ; call printChar_Pu8[arg.0.0{r0}]
        call printChar_Pu8
        ; const arg.1.0{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; const arg.1.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.1.0{r0}, arg.1.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.2.1{r0}, [string-13]
        ld   r0, #hi(string_13)
        ld   r1, #lo(string_13)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        ; const row.1{r0}, 3
        ld   r0, #%00
        ld   r1, #%03
        ; const index.1{r2}, 0
        ld   r2, #%00
        ; 197:2 for index < 4
        ; move row.2{r8}, row.1{r0}
        ld   r9, r1
        ld   r8, r0
        ; move index.2{r10}, index.1{r2}
        ld   r10, r2
        jr   for_40

for_40_body:
        ; move row.2{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; const arg.3.1{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; call setCursor_Pi16_Pi16[row.2{r0}, arg.3.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.3.1{r0}, [string-14]
        ld   r0, #hi(string_14)
        ld   r1, #lo(string_14)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        ; move t.4.1{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add t.4.1{r0}, 1
        incw r0
        ; const arg.5.1{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; call setCursor_Pi16_Pi16[t.4.1{r0}, arg.5.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.5.1{r0}, [string-15]
        ld   r0, #hi(string_15)
        ld   r1, #lo(string_15)
        ; call printString_P_pu8[t.5.1{r0}]
        call printString_P_pu8
        ; move t.6.1{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add t.6.1{r0}, 2
        add  r1, #%02
        adc  r0, #%00
        ; const arg.7.1{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; call setCursor_Pi16_Pi16[t.6.1{r0}, arg.7.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.7.1{r0}, [string-15]
        ld   r0, #hi(string_15)
        ld   r1, #lo(string_15)
        ; call printString_P_pu8[t.7.1{r0}]
        call printString_P_pu8
        ; move row.3{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add row.3{r0}, 3
        add  r1, #%03
        adc  r0, #%00
        ; move index.3{r2}, index.2{r10}
        ld   r2, r10
        ; add index.3{r2}, 1
        inc  r2
        ; move row.2{r8}, row.3{r0}
        ld   r9, r1
        ld   r8, r0
        ; move index.2{r10}, index.3{r2}
        ld   r10, r2
for_40:
        ; branch index.2{r10} lt 4: for_40_body
        cp   r10, #%04
        jr   ult, for_40_body
        ; move row.2{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; const arg.9.1{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; call setCursor_Pi16_Pi16[row.2{r0}, arg.9.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.8.1{r0}, [string-14]
        ld   r0, #hi(string_14)
        ld   r1, #lo(string_14)
        ; call printString_P_pu8[t.8.1{r0}]
        call printString_P_pu8
        ; restore clobbered non-volatile registers
        pop  r10
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
        ; const index.1{r0}, 0
        ld   r0, #%00
        ; const row.1{r1}, 5
        ld   r1, #%00
        ld   r2, #%05
        ; const boardRow.1{r3}, 0
        ld   r3, #%00
        ; 213:2 for boardRow < 4
        ; move index.2{r8}, index.1{r0}
        ld   r8, r0
        ; move row.2{r9}, row.1{r1}
        ld   r10, r2
        ld   r9, r1
        ; move boardRow.2{r11}, boardRow.1{r3}
        ld   r11, r3
        jr   for_41

for_41_body:
        ; const column.1{r0}, 2
        ld   r0, #%00
        ld   r1, #%02
        ; const boardColumn.1{r2}, 0
        ld   r2, #%00
        ; 215:3 for boardColumn < 4
        ; move column.2{r12}, column.1{r0}
        ld   r13, r1
        ld   r12, r0
        ; move boardColumn.2{r0}, boardColumn.1{r2}
        ld   r0, r2
        ; addrof memVarAddr{r14}, boardColumn.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], boardColumn.2{r0}
        lde  @rr14, r0
        ; move boardColumn.2{r3}, boardColumn.2{r0}
        ld   r3, r0
        jr   for_42

for_42_body:
        ; addrof memVarAddr{r14}, boardColumn.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], boardColumn.2{r3}
        lde  @rr14, r3
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ld   r1, r10
        ; move column.2{r2}, column.2{r12}
        ld   r2, r12
        ld   r3, r13
        ; call setCursor_Pi16_Pi16[row.2{r0}, column.2{r2}]
        call setCursor_Pi16_Pi16
        ; cast t.7.1{r0}(i16), index.3{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.6.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.6.2{r2}, t.7.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.5.1{r0}, [t.6.2{r2}]
        lde  r0, @rr2
        ; call printTile_Pu8[t.5.1{r0}]
        call printTile_Pu8
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
for_42:
        ; branch boardColumn.2{r3} lt 4: for_42_body
        cp   r3, #%04
        jr   ult, for_42_body
        ; move row.4{r0}, row.2{r9}
        ld   r0, r9
        ld   r1, r10
        ; add row.4{r0}, 3
        add  r1, #%03
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
for_41:
        ; branch boardRow.2{r11} lt 4: for_41_body
        cp   r11, #%04
        jr   ult, for_41_body
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
        ; const arg.0.0{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; const arg.0.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.0.1{r0}, [string-16]
        ld   r0, #hi(string_16)
        ld   r1, #lo(string_16)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ; addrof a.1.1{r0}, score
        ld   r0, #hi(var_1)
        ld   r1, #lo(var_1)
        ; load t.2.1{r2}, [a.1.1{r0}]
        lde  r2, @rr0
        incw r0
        lde  r3, @rr0
        incw r0
        lde  r4, @rr0
        incw r0
        lde  r5, @rr0
        sub  r1, #3
        sbc  r0, #0
        ; move t.2.1{r0}, t.2.1{r2}
        ld   r0, r2
        ld   r1, r3
        ld   r2, r4
        ld   r3, r5
        ; call printUint_Pi32[t.2.1{r0}]
        call printUint_Pi32
        ; const t.3.1{r0}, [string-17]
        ld   r0, #hi(string_17)
        ld   r1, #lo(string_17)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        ret

        ; void drawStatus
drawStatus:
        ; const arg.0.0{r0}, 18
        ld   r0, #%00
        ld   r1, #%12
        ; const arg.0.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.0.1{r0}, [string-18]
        ld   r0, #hi(string_18)
        ld   r1, #lo(string_18)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ; const arg.2.0{r0}, 18
        ld   r0, #%00
        ld   r1, #%12
        ; const arg.2.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.2.0{r0}, arg.2.1{r2}]
        call setCursor_Pi16_Pi16
        ; 236:2 if gameState == 1
        ; addrof a.1.1{r0}, gameState
        ld   r0, #hi(var_2)
        ld   r1, #lo(var_2)
        ; load t.2.1{r2}, [a.1.1{r0}]
        lde  r2, @rr0
        ; branch t.2.1{r2} equals 1: if_43_then
        cp   r2, #%01
        jr   eq, if_43_then
        ; 239:7 if gameState == 2
        ; branch t.5.1{r2} notequals 2: drawStatus_ret, if_44_then
        cp   r2, #%02
        jr   ne, drawStatus_ret
        jr   if_44_then

if_43_then:
        ; const t.3.1{r0}, [string-19]
        ld   r0, #hi(string_19)
        ld   r1, #lo(string_19)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        jr   drawStatus_ret

if_44_then:
        ; const t.6.1{r0}, [string-20]
        ld   r0, #hi(string_20)
        ld   r1, #lo(string_20)
        ; call printString_P_pu8[t.6.1{r0}]
        call printString_P_pu8
drawStatus_ret:
        ret

        ; void newGame
newGame:
        ; const index.1{r0}, 0
        ld   r0, #%00
        ; 245:2 for index < 16
        jr   for_45

for_45_body:
        ; const t.1.1{r1}, 0
        ld   r1, #%00
        ; cast t.3.1{r2}(i16), index.2{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; addrof t.2.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.2.2{r4}, t.3.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.2.2{r4}], t.1.1{r1}
        lde  @rr4, r1
        ; add index.3{r0}, 1
        inc  r0
for_45:
        ; branch index.2{r0} lt 16: for_45_body
        cp   r0, #%10
        jr   ult, for_45_body
        ; const t.4.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ld   r2, #%00
        ld   r3, #%00
        ; addrof a.5.1{r4}, score
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; store [a.5.1{r4}], t.4.1{r0}
        lde  @rr4, r0
        incw r4
        lde  @rr4, r1
        incw r4
        lde  @rr4, r2
        incw r4
        lde  @rr4, r3
        sub  r5, #3
        sbc  r4, #0
        ; call drawScore[]
        call drawScore
        ; const t.6.1{r0}, 0
        ld   r0, #%00
        ; addrof a.7.1{r2}, gameState
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.7.1{r2}], t.6.1{r0}
        lde  @rr2, r0
        ; call spawnTile[]
        call spawnTile
        ; call spawnTile[]
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
        ; call setCursor_Pi16_Pi16[arg.5.0{r0}, arg.5.1{r2}]
        call setCursor_Pi16_Pi16
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; begin initialize global variables
        ; const t.2.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ld   r2, #%00
        ld   r3, #%00
        ; addrof a.3.1{r4}, score
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; store [a.3.1{r4}], t.2.1{r0}
        lde  @rr4, r0
        incw r4
        lde  @rr4, r1
        incw r4
        lde  @rr4, r2
        incw r4
        lde  @rr4, r3
        sub  r5, #3
        sbc  r4, #0
        ; const t.4.1{r0}, 0
        ld   r0, #%00
        ; addrof a.5.1{r2}, gameState
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.5.1{r2}], t.4.1{r0}
        lde  @rr2, r0
        ; end initialize global variables
        ; const arg.0.0{r0}, 7439742
        ld   r0, #%00
        ld   r1, #%71
        ld   r2, #%85
        ld   r3, #%7e
        ; call initRandom_Pi32[arg.0.0{r0}]
        call initRandom_Pi32
        ; call drawFrame[]
        call drawFrame
        ; call newGame[]
        call newGame
        ; 262:2 while true
        jr   while_46

if_47_end:
        ; branch key.1{r8} equals 114: if_48_then
        cp   r9, #%72
        jr   ne, .notEquals2
        cp   r8, #%00
        jr   eq, if_48_then
.notEquals2:
        ; branch key.1{r8} equals 82: if_48_then
        cp   r9, #%52
        jr   ne, .notEquals3
        cp   r8, #%00
        jr   eq, if_48_then
.notEquals3:
        ; 271:3 if gameState != 0
        ; addrof a.6.1{r0}, gameState
        ld   r0, #hi(var_2)
        ld   r1, #lo(var_2)
        ; load t.7.1{r2}, [a.6.1{r0}]
        lde  r2, @rr0
        ; branch t.7.1{r2} notequals 0: while_46
        cp   r2, #%00
        jr   ne, while_46
        ; branch key.1{r8} equals 1: if_51_then, or_53
        cp   r9, #%01
        jr   ne, .notEquals4
        cp   r8, #%00
        jr   eq, if_51_then
.notEquals4:
        jr   or_53

if_48_then:
        ; call newGame[]
        call newGame
        jr   while_46

or_53:
        ; branch key.1{r8} equals 97: if_51_then
        cp   r9, #%61
        jr   ne, .notEquals5
        cp   r8, #%00
        jr   eq, if_51_then
.notEquals5:
        ; branch key.1{r8} equals 65: if_51_then
        cp   r9, #%41
        jr   ne, .notEquals6
        cp   r8, #%00
        jr   eq, if_51_then
.notEquals6:
        ; branch key.1{r8} equals 2: if_54_then
        cp   r9, #%02
        jr   ne, .notEquals7
        cp   r8, #%00
        jr   eq, if_54_then
.notEquals7:
        ; branch key.1{r8} equals 100: if_54_then, or_55
        cp   r9, #%64
        jr   ne, .notEquals8
        cp   r8, #%00
        jr   eq, if_54_then
.notEquals8:
        jr   or_55

if_51_then:
        ; const direction.2{r0}, 0
        ld   r0, #%00
        jr   if_51_end

or_55:
        ; branch key.1{r8} equals 68: if_54_then
        cp   r9, #%44
        jr   ne, .notEquals9
        cp   r8, #%00
        jr   eq, if_54_then
.notEquals9:
        ; branch key.1{r8} equals 3: if_57_then
        cp   r9, #%03
        jr   ne, .notEquals10
        cp   r8, #%00
        jr   eq, if_57_then
.notEquals10:
        ; branch key.1{r8} equals 119: if_57_then, or_58
        cp   r9, #%77
        jr   ne, .notEquals11
        cp   r8, #%00
        jr   eq, if_57_then
.notEquals11:
        jr   or_58

if_54_then:
        ; const direction.4{r0}, 1
        ld   r0, #%01
        jr   if_51_end

or_58:
        ; branch key.1{r8} equals 87: if_57_then
        cp   r9, #%57
        jr   ne, .notEquals12
        cp   r8, #%00
        jr   eq, if_57_then
.notEquals12:
        ; branch key.1{r8} equals 4: if_60_then
        cp   r9, #%04
        jr   ne, .notEquals13
        cp   r8, #%00
        jr   eq, if_60_then
.notEquals13:
        ; branch key.1{r8} equals 115: if_60_then, or_61
        cp   r9, #%73
        jr   ne, .notEquals14
        cp   r8, #%00
        jr   eq, if_60_then
.notEquals14:
        jr   or_61

if_57_then:
        ; const direction.5{r0}, 2
        ld   r0, #%02
        jr   if_51_end

or_61:
        ; branch key.1{r8} notequals 83: while_46, if_60_then
        cp   r9, #%53
        jr   ne, while_46
        cp   r8, #%00
        jr   ne, while_46
if_60_then:
        ; const direction.6{r0}, 3
        ld   r0, #%03
if_51_end:
        ; 291:3 if !slide_Pu8([ExprVarAccess[varName=direction, index=1, scope=function, type=u8, varIsArray=false, location=291:13]])
        ; call t.8.1{r0} = slide_Pu8[direction.3{r0}] -> bool
        call slide_Pu8
        ; branch t.8.1{r0} equals 0: while_46
        cp   r0, #%00
        jr   eq, while_46
        ; call spawnTile[]
        call spawnTile
        ; 296:3 if gameState == 0 && !canMove([])
        ; addrof a.9.1{r0}, gameState
        ld   r0, #hi(var_2)
        ld   r1, #lo(var_2)
        ; load t.10.1{r2}, [a.9.1{r0}]
        lde  r2, @rr0
        ; branch t.10.1{r2} notequals 0: if_64_end
        cp   r2, #%00
        jr   ne, if_64_end
        ; call t.11.1{r0} = canMove[] -> bool
        call canMove
        ; branch t.11.1{r0} notequals 0: if_64_end
        cp   r0, #%00
        jr   ne, if_64_end
        ; const t.12.1{r0}, 2
        ld   r0, #%02
        ; addrof a.13.1{r2}, gameState
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; store [a.13.1{r2}], t.12.1{r0}
        lde  @rr2, r0
if_64_end:
        ; call drawBoard[]
        call drawBoard
        ; call drawScore[]
        call drawScore
        ; 301:3 if gameState != 0
        ; addrof a.14.1{r0}, gameState
        ld   r0, #hi(var_2)
        ld   r1, #lo(var_2)
        ; load t.15.1{r2}, [a.14.1{r0}]
        lde  r2, @rr0
        ; branch t.15.1{r2} equals 0: if_66_end
        cp   r2, #%00
        jr   eq, if_66_end
        ; call drawStatus[]
        call drawStatus
if_66_end:
        ; const arg.10.0{r0}, 21
        ld   r0, #%00
        ld   r1, #%15
        ; const arg.10.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.10.0{r0}, arg.10.1{r2}]
        call setCursor_Pi16_Pi16
while_46:
        ; call key.1{r0} = getChar[] -> i16
        call getChar
        ; move key.1{r8}, key.1{r0}
        ld   r9, r1
        ld   r8, r0
        ; 264:3 if key == 27
        ; branch key.1{r8} notequals 27: if_47_end
        cp   r9, #%1b
        jr   ne, if_47_end
        cp   r8, #%00
        jr   ne, if_47_end
        ; restore clobbered non-volatile registers
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
        .data "        " %00
string_1:
        .data "   2    " %00
string_2:
        .data "   4    " %00
string_3:
        .data "   8    " %00
string_4:
        .data "   16   " %00
string_5:
        .data "   32   " %00
string_6:
        .data "   64   " %00
string_7:
        .data "  128   " %00
string_8:
        .data "  256   " %00
string_9:
        .data "  512   " %00
string_10:
        .data "  1024  " %00
string_11:
        .data "  2048  " %00
string_12:
        .data "   ?    " %00
string_13:
        .data "Arrows/WASD  R restart  Esc quit" %00
string_14:
        .data "+--------+--------+--------+--------+" %00
string_15:
        .data "|        |        |        |        |" %00
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

