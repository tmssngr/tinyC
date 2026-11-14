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
        ; 49:2 for index < exponent
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
        ; 52:9 return value
        ; move value.2{r0}, value.2{r1}
        ld   r0, r1
        ld   r1, r2
        ret

        ; u8 spawnTile
spawnTile:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const emptyCount.1{r0}, 0
        ld   r0, #%00
        ; const index.1{r1}, 0
        ld   r1, #%00
        ; 57:2 for index < 16
        ; move emptyCount.2{r8}, emptyCount.1{r0}
        ld   r8, r0
        jr   for_2

for_2_body:
        ; 58:3 if [...] == 0
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
        ; branch emptyCount.2{r8} equals 0: if_4_then
        cp   r8, #%00
        jr   eq, if_4_then
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
        ; 67:2 for index < 16
        ; move chosen.2{r2}, chosen.1{r0}
        ld   r2, r0
        ; move index.4{r8}, index.3{r1}
        ld   r8, r1
        jr   for_5

for_5_body:
        ; 68:3 if [...] != 0
        ; cast t.13.1{r0}(i16), index.4{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.12.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.12.2{r4}, t.13.1{r0}
        add  r5, r1
        adc  r4, r0
        ; load t.11.1{r0}, [t.12.2{r4}]
        lde  r0, @rr4
        ; branch t.11.1{r0} equals 0: if_6_end
        cp   r0, #%00
        jr   eq, if_6_end
        ; move chosen.3{r0}, chosen.2{r2}
        ld   r0, r2
        jr   for_5_continue

if_6_end:
        ; branch chosen.2{r2} equals 0: if_7_then
        cp   r2, #%00
        jr   eq, if_7_then
        ; move chosen.4{r0}, chosen.2{r2}
        ld   r0, r2
        ; sub chosen.4{r0}, 1
        dec  r0
for_5_continue:
        ; move index.8{r1}, index.4{r8}
        ld   r1, r8
        ; add index.8{r1}, 1
        inc  r1
        ; move chosen.2{r2}, chosen.3{r0}
        ld   r2, r0
        ; move index.4{r8}, index.8{r1}
        ld   r8, r1
        jr   for_5

if_4_then:
        ; const {r0}, 255
        ld   r0, #%ff
        jr   spawnTile_ret

for_5:
        ; branch index.4{r8} lt 16: for_5_body
        cp   r8, #%10
        jr   ult, for_5_body
        ; const {r0}, 255
        ld   r0, #%ff
        jr   spawnTile_ret

if_7_then:
        ; const tile.1{r9}, 1
        ld   r9, #%01
        ; 73:4 if random16([]) % 10 == 0
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
        ; 77:11 return index
        ; move index.4{r0}, index.4{r8}
        ld   r0, r8
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
        ; 91:2 for position < 4
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
        ; 94:3 if tile != 0
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
        ; 97:4 if target != first && !previousMerged
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
        ; cast t.16.1{r3}(i16), previous.1{r2}(u8)
        ld   r4, r2
        ld   r3, #0
        ; addrof previousTile.1{r6}, tiles
        ld   r6, #hi(var_0)
        ld   r7, #lo(var_0)
        ; add previousTile.2{r6}, t.16.1{r3}
        add  r7, r4
        adc  r6, r3
        ; 100:5 if *previousTile == tile
        ; load t.17.1{r3}, [previousTile.2{r6}]
        lde  r3, @rr6
        ; branch t.17.1{r3} equals tile.1{r0}: if_13_then
        cp   r3, r0
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
        ; move t.18.1{r1}, previous.1{r2}
        ld   r1, r2
        ; or t.18.1{r1}, 128
        or  r1, #%80
        ; cast t.20.1{r2}(i16), source.2{r10}(u8)
        ld   r3, r10
        ld   r2, #0
        ; addrof t.19.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.19.2{r4}, t.20.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.19.2{r4}], t.18.1{r1}
        lde  @rr4, r1
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
        ; store [previousTile.2{r6}], nextTile.1{r12}
        lde  @rr6, r12
        ; move nextTile.1{r0}, nextTile.1{r12}
        ld   r0, r12
        ; call t.21.1{r0} = tileValue_Pu8[nextTile.1{r0}] -> i16
        call tileValue_Pu8
        ; cast mergedScore.1{r0}(i32), t.21.1{r0}(i16)
        ld   r3, r1
        ld   r2, r0
        ld   r1, r2
        rl   r1
        sbc  r1, r1
        sbc  r0, r0
        ; addrof a.23.1{r4}, score
        ld   r4, #hi(var_3)
        ld   r5, #lo(var_3)
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
        ; load t.24.1{r6}, [a.23.1{r4}]
        lde  r6, @rr4
        incw r4
        lde  r7, @rr4
        incw r4
        lde  r8, @rr4
        incw r4
        lde  r9, @rr4
        sub  r5, #3
        sbc  r4, #0
        ; move t.22.1{r4}, t.24.1{r6}
        ld   r4, r6
        ld   r5, r7
        ld   r6, r8
        ld   r7, r9
        ; add t.22.1{r4}, mergedScore.1{r0}
        add  r7, r3
        adc  r6, r2
        adc  r5, r1
        adc  r4, r0
        ; addrof a.25.1{r0}, score
        ld   r0, #hi(var_3)
        ld   r1, #lo(var_3)
        ; store [a.25.1{r0}], t.22.1{r4}
        lde  @rr0, r4
        incw r0
        lde  @rr0, r5
        incw r0
        lde  @rr0, r6
        incw r0
        lde  @rr0, r7
        sub  r1, #3
        sbc  r0, #0
        ; 107:6 if nextTile == 11
        ; branch nextTile.1{r12} notequals 11: if_14_end
        cp   r12, #%0b
        jr   ne, if_14_end
        ; const t.26.1{r0}, 1
        ld   r0, #%01
        ; addrof a.27.1{r2}, gameState
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.27.1{r2}], t.26.1{r0}
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
        ; cast t.29.1{r0}(i16), source.2{r10}(u8)
        ld   r1, r10
        ld   r0, #0
        ; addrof t.28.1{r2}, moveTargets
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; add t.28.2{r2}, t.29.1{r0}
        add  r3, r1
        adc  r2, r0
        ; store [t.28.2{r2}], target.2{r11}
        lde  @rr2, r11
        ; cast t.31.1{r0}(i16), target.2{r11}(u8)
        ld   r1, r11
        ld   r0, #0
        ; addrof t.30.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.30.2{r2}, t.31.1{r0}
        add  r3, r1
        adc  r2, r0
        ; addrof memVarAddr{r14}, tile.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load tile.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; store [t.30.2{r2}], tile.1{r0}
        lde  @rr2, r0
        ; 118:5 if target != source
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
        ; 127:9 return moved
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
        ; const index.1{r0}, 0
        ld   r0, #%00
        ; 131:2 for index < 16
        jr   for_17

for_17_body:
        ; cast t.8.1{r1}(i16), index.2{r0}(u8)
        ld   r2, r0
        ld   r1, #0
        ; addrof t.7.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.7.2{r4}, t.8.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load t.6.1{r1}, [t.7.2{r4}]
        lde  r1, @rr4
        ; cast t.10.1{r2}(i16), index.2{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; addrof t.9.1{r4}, moveTiles
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; add t.9.2{r4}, t.10.1{r2}
        add  r5, r3
        adc  r4, r2
        ; store [t.9.2{r4}], t.6.1{r1}
        lde  @rr4, r1
        ; move t.12.1{r1}, t.12.1{r2}
        ld   r1, r2
        ld   r2, r3
        ; addrof t.11.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.11.2{r4}, t.12.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.11.2{r4}], index.2{r0}
        lde  @rr4, r0
        ; add index.3{r0}, 1
        inc  r0
for_17:
        ; branch index.2{r0} lt 16: for_17_body
        cp   r0, #%10
        jr   ult, for_17_body
        ; const moved.1{r0}, 0
        ld   r0, #%00
        ; const line.1{r1}, 0
        ld   r1, #%00
        ; 136:2 for line < 4
        ; move moved.2{r9}, moved.1{r0}
        ld   r9, r0
        ; move line.2{r10}, line.1{r1}
        ld   r10, r1
        jr   for_18

for_18_body:
        ; move first.1{r0}, line.2{r10}
        ld   r0, r10
        ; shiftleft first.1{r0}, 2
        add r0, r0
        add r0, r0
        ; const step.1{r1}, 1
        ld   r1, #%01
        ; 139:3 if direction == 1
        ; branch param.direction{r8} equals 1: if_19_then
        cp   r8, #%01
        jr   eq, if_19_then
        ; branch param.direction{r8} notequals 2: if_20_else, if_20_then
        cp   r8, #%02
        jr   ne, if_20_else
        jr   if_20_then

if_19_then:
        ; add first.2{r0}, 3
        add  r0, #%03
        ; const step.2{r1}, 255
        ld   r1, #%ff
        jr   if_19_end

if_20_else:
        ; branch param.direction{r8} notequals 3: if_19_end, if_21_then
        cp   r8, #%03
        jr   ne, if_19_end
        jr   if_21_then

if_20_then:
        ; move first.4{r0}, line.2{r10}
        ld   r0, r10
        ; const step.4{r1}, 4
        ld   r1, #%04
        jr   if_19_end

if_21_then:
        ; move first.5{r0}, line.2{r10}
        ld   r0, r10
        ; add first.5{r0}, 12
        add  r0, #%0c
        ; const step.5{r1}, 252
        ld   r1, #%fc
if_19_end:
        ; 151:3 if slideLine_Pu8_Pu8([ExprVarAccess[varName=first, index=4, scope=function, type=u8, varIsArray=false, location=151:16], ExprVarAccess[varName=step, index=5, scope=function, type=u8, varIsArray=false, location=151:23]])
        ; call t.13.1{r0} = slideLine_Pu8_Pu8[first.3{r0}, step.3{r1}] -> bool
        call slideLine_Pu8_Pu8
        ; branch t.13.1{r0} notequals 0: if_22_then
        cp   r0, #%00
        jr   ne, if_22_then
        ; move moved.4{r0}, moved.2{r9}
        ld   r0, r9
        jr   for_18_continue

if_22_then:
        ; const moved.5{r0}, 1
        ld   r0, #%01
for_18_continue:
        ; move line.5{r1}, line.2{r10}
        ld   r1, r10
        ; add line.5{r1}, 1
        inc  r1
        ; move moved.2{r9}, moved.4{r0}
        ld   r9, r0
        ; move line.2{r10}, line.5{r1}
        ld   r10, r1
for_18:
        ; branch line.2{r10} lt 4: for_18_body
        cp   r10, #%04
        jr   ult, for_18_body
        ; 155:9 return moved
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
        ; 159:2 for index < 16
        jr   for_23

for_23_body:
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
        ; 161:3 if tile == 0
        ; branch tile.1{r1} equals 0: if_24_then
        cp   r1, #%00
        jr   eq, if_24_then
        ; 164:3 if index & 3 != 3 && [...] == tile
        ; move t.4.1{r2}, index.2{r0}
        ld   r2, r0
        ; and t.4.1{r2}, 3
        and  r2, #%03
        ; branch t.4.1{r2} equals 3: if_25_end
        cp   r2, #%03
        jr   eq, if_25_end
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
        ; branch t.5.1{r2} equals tile.1{r1}: if_25_then, if_25_end
        cp   r2, r1
        jr   eq, if_25_then
if_25_end:
        ; branch index.2{r0} gteq 12: for_23_continue
        cp   r0, #%0c
        jr   uge, for_23_continue
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
        ; branch t.9.1{r2} equals tile.1{r1}: if_27_then, for_23_continue
        cp   r2, r1
        jr   eq, if_27_then
for_23_continue:
        ; add index.5{r0}, 1
        inc  r0
for_23:
        ; branch index.2{r0} lt 16: for_23_body
        cp   r0, #%10
        jr   ult, for_23_body
        ; const {r0}, 0
        ld   r0, #%00
        jr   canMove_ret

if_24_then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove_ret

if_25_then:
        ; const {r0}, 1
        ld   r0, #%01
        jr   canMove_ret

if_27_then:
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
        ; branch param.exponent{r8} equals 0: if_29_then
        cp   r8, #%00
        jr   eq, if_29_then
        ; branch param.exponent{r8} notequals 1: if_30_else, if_30_then
        cp   r8, #%01
        jr   ne, if_30_else
        jr   if_30_then

if_29_then:
        ; const t.1.1{r0}, [string-0]
        ld   r0, #hi(string_0)
        ld   r1, #lo(string_0)
        ; call printString_P_pu8[t.1.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_30_else:
        ; branch param.exponent{r8} notequals 2: if_31_else, if_31_then
        cp   r8, #%02
        jr   ne, if_31_else
        jr   if_31_then

if_30_then:
        ; const t.2.1{r0}, [string-1]
        ld   r0, #hi(string_1)
        ld   r1, #lo(string_1)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_31_else:
        ; branch param.exponent{r8} notequals 3: if_32_else, if_32_then
        cp   r8, #%03
        jr   ne, if_32_else
        jr   if_32_then

if_31_then:
        ; const t.3.1{r0}, [string-2]
        ld   r0, #hi(string_2)
        ld   r1, #lo(string_2)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_32_else:
        ; branch param.exponent{r8} notequals 4: if_33_else, if_33_then
        cp   r8, #%04
        jr   ne, if_33_else
        jr   if_33_then

if_32_then:
        ; const t.4.1{r0}, [string-3]
        ld   r0, #hi(string_3)
        ld   r1, #lo(string_3)
        ; call printString_P_pu8[t.4.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_33_else:
        ; branch param.exponent{r8} notequals 5: if_34_else, if_34_then
        cp   r8, #%05
        jr   ne, if_34_else
        jr   if_34_then

if_33_then:
        ; const t.5.1{r0}, [string-4]
        ld   r0, #hi(string_4)
        ld   r1, #lo(string_4)
        ; call printString_P_pu8[t.5.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_34_else:
        ; branch param.exponent{r8} notequals 6: if_35_else, if_35_then
        cp   r8, #%06
        jr   ne, if_35_else
        jr   if_35_then

if_34_then:
        ; const t.6.1{r0}, [string-5]
        ld   r0, #hi(string_5)
        ld   r1, #lo(string_5)
        ; call printString_P_pu8[t.6.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_35_else:
        ; branch param.exponent{r8} notequals 7: if_36_else, if_36_then
        cp   r8, #%07
        jr   ne, if_36_else
        jr   if_36_then

if_35_then:
        ; const t.7.1{r0}, [string-6]
        ld   r0, #hi(string_6)
        ld   r1, #lo(string_6)
        ; call printString_P_pu8[t.7.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_36_else:
        ; branch param.exponent{r8} notequals 8: if_37_else, if_37_then
        cp   r8, #%08
        jr   ne, if_37_else
        jr   if_37_then

if_36_then:
        ; const t.8.1{r0}, [string-7]
        ld   r0, #hi(string_7)
        ld   r1, #lo(string_7)
        ; call printString_P_pu8[t.8.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_37_else:
        ; branch param.exponent{r8} notequals 9: if_38_else, if_38_then
        cp   r8, #%09
        jr   ne, if_38_else
        jr   if_38_then

if_37_then:
        ; const t.9.1{r0}, [string-8]
        ld   r0, #hi(string_8)
        ld   r1, #lo(string_8)
        ; call printString_P_pu8[t.9.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_38_else:
        ; branch param.exponent{r8} notequals 10: if_39_else, if_39_then
        cp   r8, #%0a
        jr   ne, if_39_else
        jr   if_39_then

if_38_then:
        ; const t.10.1{r0}, [string-9]
        ld   r0, #hi(string_9)
        ld   r1, #lo(string_9)
        ; call printString_P_pu8[t.10.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_39_else:
        ; branch param.exponent{r8} notequals 11: if_40_else, if_40_then
        cp   r8, #%0b
        jr   ne, if_40_else
        jr   if_40_then

if_39_then:
        ; const t.11.1{r0}, [string-10]
        ld   r0, #hi(string_10)
        ld   r1, #lo(string_10)
        ; call printString_P_pu8[t.11.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_40_else:
        ; const t.13.1{r0}, [string-12]
        ld   r0, #hi(string_12)
        ld   r1, #lo(string_12)
        ; call printString_P_pu8[t.13.1{r0}]
        call printString_P_pu8
        jr   printTile_Pu8_ret

if_40_then:
        ; const t.12.1{r0}, [string-11]
        ld   r0, #hi(string_11)
        ld   r1, #lo(string_11)
        ; call printString_P_pu8[t.12.1{r0}]
        call printString_P_pu8
printTile_Pu8_ret:
        ; restore clobbered non-volatile registers
        pop  r8
        ret

        ; void drawTileAt_Pi16_Pi16_Pu8
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
        ; branch param.exponent{r12} equals 0: drawTileAt_Pi16_Pi16_Pu8_ret
        cp   r12, #%00
        jr   eq, drawTileAt_Pi16_Pi16_Pu8_ret
        ; call setCursor_Pi16_Pi16[param.row{r0}, param.column{r2}]
        call setCursor_Pi16_Pi16
        ; const t.3.1{r0}, [string-13]
        ld   r0, #hi(string_13)
        ld   r1, #lo(string_13)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        ; move t.4.1{r0}, param.row{r8}
        ld   r0, r8
        ld   r1, r9
        ; add t.4.1{r0}, 1
        incw r0
        ; move param.column{r2}, param.column{r10}
        ld   r2, r10
        ld   r3, r11
        ; call setCursor_Pi16_Pi16[t.4.1{r0}, param.column{r2}]
        call setCursor_Pi16_Pi16
        ; const arg.3.0{r0}, 124
        ld   r0, #%7c
        ; call printChar_Pu8[arg.3.0{r0}]
        call printChar_Pu8
        ; move param.exponent{r0}, param.exponent{r12}
        ld   r0, r12
        ; call printTile_Pu8[param.exponent{r0}]
        call printTile_Pu8
        ; const arg.5.0{r0}, 124
        ld   r0, #%7c
        ; call printChar_Pu8[arg.5.0{r0}]
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
        ; call setCursor_Pi16_Pi16[t.5.1{r0}, param.column{r2}]
        call setCursor_Pi16_Pi16
        ; const t.6.1{r0}, [string-13]
        ld   r0, #hi(string_13)
        ld   r1, #lo(string_13)
        ; call printString_P_pu8[t.6.1{r0}]
        call printString_P_pu8
drawTileAt_Pi16_Pi16_Pu8_ret:
        ; restore clobbered non-volatile registers
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; u8 tileRow_Pu8
        ; arg index (u8): r0
tileRow_Pu8:
        ; 232:19 return index & 12 + 3
        ; and t.2.1{r0}, 12
        and  r0, #%0c
        ; add t.1.1{r0}, 3
        add  r0, #%03
        ret

        ; u8 tileColumn_Pu8
        ; arg index (u8): r0
tileColumn_Pu8:
        ; and column.1{r0}, 3
        and  r0, #%03
        ; 237:36 return column << 3 + 1 + column
        ; move t.4.1{r1}, column.1{r0}
        ld   r1, r0
        ; shiftleft t.4.1{r1}, 3
        add r1, r1
        add r1, r1
        add r1, r1
        ; add t.3.1{r1}, 1
        inc  r1
        ; add t.2.1{r1}, column.1{r0}
        add  r1, r0
        ; move t.2.1{r0}, t.2.1{r1}
        ld   r0, r1
        ret

        ; void clearTileTrail_Pu8_Pu8_Pu8_Pu8
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
        ; const width.1{r4}, 8
        ld   r4, #%08
        ; const height.1{r5}, 3
        ld   r5, #%03
        ; 244:2 if direction < 2
        ; branch param.direction{r2} lt 2: if_42_then
        cp   r2, #%02
        jr   ult, if_42_then
        ; branch param.distance{r3} gteq height.1{r5}: clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_14, if_45_end
        cp   r3, r5
        jr   uge, clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_14
        jr   if_45_end

if_42_then:
        ; branch param.distance{r3} gteq width.1{r4}: clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_16, if_43_end
        cp   r3, r4
        jr   uge, clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_16
        jr   if_43_end

clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_14:
        ; move height.2{r3}, height.1{r5}
        ld   r3, r5
        jr   if_45_end

clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_16:
        ; move width.3{r3}, width.1{r4}
        ld   r3, r4
        jr   if_43_end

if_45_end:
        ; branch param.direction{r2} notequals 2: clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_15, if_46_then
        cp   r2, #%02
        jr   ne, clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_15
        jr   if_46_then

if_43_end:
        ; branch param.direction{r2} notequals 0: clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_17, if_44_then
        cp   r2, #%00
        jr   ne, clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_17
        jr   if_44_then

clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_15:
        ; move column.3{r8}, param.column{r1}
        ld   r8, r1
        ; move width.5{r1}, width.1{r4}
        ld   r1, r4
        ; move height.5{r9}, height.2{r3}
        ld   r9, r3
        jr   if_42_end

if_46_then:
        ; const t.11.1{r2}, 3
        ld   r2, #%03
        ; sub t.10.1{r2}, height.2{r3}
        sub  r2, r3
        ; add row.4{r0}, t.10.1{r2}
        add  r0, r2
        ; move column.3{r8}, param.column{r1}
        ld   r8, r1
        ; move width.5{r1}, width.1{r4}
        ld   r1, r4
        ; move height.5{r9}, height.2{r3}
        ld   r9, r3
        jr   if_42_end

clearTileTrail_Pu8_Pu8_Pu8_Pu8.no_critical_edge_17:
        ; move column.3{r8}, param.column{r1}
        ld   r8, r1
        ; move width.5{r1}, width.3{r3}
        ld   r1, r3
        ; move height.5{r9}, height.1{r5}
        ld   r9, r5
        jr   if_42_end

if_44_then:
        ; const t.9.1{r2}, 8
        ld   r2, #%08
        ; sub t.8.1{r2}, width.3{r3}
        sub  r2, r3
        ; add column.4{r1}, t.8.1{r2}
        add  r1, r2
        ; move column.3{r8}, column.4{r1}
        ld   r8, r1
        ; move width.5{r1}, width.3{r3}
        ld   r1, r3
        ; move height.5{r9}, height.1{r5}
        ld   r9, r5
if_42_end:
        ; const spaces.1{r2}, [string-14]
        ld   r2, #hi(string_14)
        ld   r3, #lo(string_14)
        ; const t.14.1{r4}, 8
        ld   r4, #%08
        ; sub t.13.1{r4}, width.5{r1}
        sub  r4, r1
        ; cast t.12.1{r4}(i16), t.13.1{r4}(u8)
        ld   r5, r4
        ld   r4, #0
        ; move spaces.2{r10}, spaces.1{r2}
        ld   r11, r3
        ld   r10, r2
        ; add spaces.2{r10}, t.12.1{r4}
        add  r11, r5
        adc  r10, r4
        ; const line.1{r1}, 0
        ld   r1, #%00
        ; 262:2 for line < height
        ; move row.5{r12}, row.3{r0}
        ld   r12, r0
        ; move line.2{r13}, line.1{r1}
        ld   r13, r1
        jr   for_47

for_47_body:
        ; cast t.15.1{r0}(i16), row.5{r12}(u8)
        ld   r1, r12
        ld   r0, #0
        ; cast t.16.1{r2}(i16), column.3{r8}(u8)
        ld   r3, r8
        ld   r2, #0
        ; call setCursor_Pi16_Pi16[t.15.1{r0}, t.16.1{r2}]
        call setCursor_Pi16_Pi16
        ; move spaces.2{r0}, spaces.2{r10}
        ld   r0, r10
        ld   r1, r11
        ; call printString_P_pu8[spaces.2{r0}]
        call printString_P_pu8
        ; move row.6{r0}, row.5{r12}
        ld   r0, r12
        ; add row.6{r0}, 1
        inc  r0
        ; move line.3{r1}, line.2{r13}
        ld   r1, r13
        ; add line.3{r1}, 1
        inc  r1
        ; move row.5{r12}, row.6{r0}
        ld   r12, r0
        ; move line.2{r13}, line.3{r1}
        ld   r13, r1
for_47:
        ; branch line.2{r13} lt height.5{r9}: for_47_body
        cp   r13, r9
        jr   ult, for_47_body
        ; restore clobbered non-volatile registers
        pop  r13
        pop  r12
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; bool drawMoveFrame_Pu8_Pu8_Pu8_Pbool
        ; arg direction (u8): r0
        ; arg previous (u8): r1
        ; arg travel (u8): r2
        ; arg erase (bool): r3
        ; var pending.2 (bool): SP+8
        ; var count.2 (u8): SP+9
        ; var index.2 (u8): SP+10
        ; var pending.4 (bool): SP+11
        ; var target.1 (u8): SP+12
        ; var distance.4 (u8): SP+13
        ; var oldOffset.2 (u8): SP+14
        ; var pending.9 (bool): SP+15
        ; var offset.2 (u8): SP+16
        ; var t.52.1 (i16): SP+17
        ; var param.previous (u8): SP+19
        ; var param.travel (u8): SP+20
drawMoveFrame_Pu8_Pu8_Pu8_Pbool:
        ld   %30, SPH
        ld   %31, SPL
        sub  %31, #%0d
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
        ; and t.17.1{r0}, 1
        and  r0, #%01
        ; notequals forward.1{r13}, t.17.1{r0}, 0
        cp   r0, #%00
        jr   ne, .ne3
        ld   r13, #0  ; false
        jr   .3
.ne3:
        ld   r13, #1
.3:
        ; const pending.1{r0}, 0
        ld   r0, #%00
        ; const count.1{r1}, 0
        ld   r1, #%00
        ; 276:2 for count < 16
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%13
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, param.travel
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.travel{r10}
        lde  @rr14, r10
        ; move count.2{r2}, count.2{r1}
        ld   r2, r1
        ; move pending.2{r1}, pending.2{r0}
        ld   r1, r0
        ; move count.2{r0}, count.2{r2}
        ld   r0, r2
        jr   for_48

for_48_body:
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%13
        adc  r14, #%00
        ; load param.previous{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        ; addrof memVarAddr{r14}, param.travel
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; load param.travel{r10}, [memVarAddr{r14}]
        lde  r10, @rr14
        ; move count.2{r2}, count.2{r0}
        ld   r2, r0
        ; move pending.2{r0}, pending.2{r1}
        ld   r0, r1
        ; move count.2{r1}, count.2{r2}
        ld   r1, r2
        ; 278:3 if !forward
        ; branch forward.1{r13} equals 0: if_49_then
        cp   r13, #%00
        jr   eq, if_49_then
        ; addrof memVarAddr{r14}, count.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], count.2{r1}
        lde  @rr14, r1
        jr   if_49_end

if_49_then:
        ; const t.18.1{r2}, 15
        ld   r2, #%0f
        ; sub index.3{r2}, count.2{r1}
        sub  r2, r1
        ; addrof memVarAddr{r14}, count.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; store [memVarAddr{r14}], count.2{r1}
        lde  @rr14, r1
if_49_end:
        ; cast t.20.1{r3}(i16), index.2{r2}(u8)
        ld   r4, r2
        ld   r3, #0
        ; addrof t.19.1{r6}, moveTiles
        ld   r6, #hi(var_1)
        ld   r7, #lo(var_1)
        ; add t.19.2{r6}, t.20.1{r3}
        add  r7, r4
        adc  r6, r3
        ; load exponent.1{r4}, [t.19.2{r6}]
        lde  r4, @rr6
        ; 283:3 if exponent == 0
        ; branch exponent.1{r4} notequals 0: if_50_end
        cp   r4, #%00
        jr   ne, if_50_end
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%13
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, param.travel
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.travel{r10}
        lde  @rr14, r10
        ; move pending.4{r9}, pending.4{r0}
        ld   r9, r0
        jr   for_48_continue

if_50_end:
        ; cast t.23.1{r5}(i16), index.2{r2}(u8)
        ld   r6, r2
        ld   r5, #0
        ; addrof memVarAddr{r14}, pending.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], pending.2{r0}
        lde  @rr14, r0
        ; addrof t.22.1{r0}, moveTargets
        ld   r0, #hi(var_2)
        ld   r1, #lo(var_2)
        ; add t.22.2{r0}, t.23.1{r5}
        add  r1, r6
        adc  r0, r5
        ; load t.21.1{r3}, [t.22.2{r0}]
        lde  r3, @rr0
        ; move target.1{r0}, t.21.1{r3}
        ld   r0, r3
        ; and target.1{r0}, 15
        and  r0, #%0f
        ; move distance.1{r1}, index.2{r2}
        ld   r1, r2
        ; sub distance.1{r1}, target.1{r0}
        sub  r1, r0
        ; 289:3 if forward
        ; branch forward.1{r13} equals 0: if_51_end
        cp   r13, #%00
        jr   eq, if_51_end
        ; move distance.3{r1}, target.1{r0}
        ld   r1, r0
        ; sub distance.3{r1}, index.2{r2}
        sub  r1, r2
if_51_end:
        ; branch horizontal.1{r12} equals 0: if_52_end
        cp   r12, #%00
        jr   eq, if_52_end
        ; move t.24.1{r3}, distance.2{r1}
        ld   r3, r1
        ; shiftleft t.24.1{r3}, 3
        add r3, r3
        add r3, r3
        add r3, r3
        ; add distance.5{r1}, t.24.1{r3}
        add  r1, r3
if_52_end:
        ; move oldOffset.1{r3}, param.previous{r9}
        ld   r3, r9
        ; 298:3 if oldOffset > distance
        ; branch oldOffset.1{r3} lteq distance.4{r1}: if_53_end
        cp   r3, r1
        jr   ule, if_53_end
        ; move oldOffset.3{r3}, distance.4{r1}
        ld   r3, r1
if_53_end:
        ; move offset.1{r5}, param.travel{r10}
        ld   r5, r10
        ; 304:3 if offset >= distance
        ; branch offset.1{r5} gteq distance.4{r1}: if_54_then
        cp   r5, r1
        jr   uge, if_54_then
        ; const pending.8{r6}, 1
        ld   r6, #%01
        ; addrof memVarAddr{r14}, distance.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], distance.4{r1}
        lde  @rr14, r1
        jr   if_54_end

if_54_then:
        ; move offset.3{r5}, distance.4{r1}
        ld   r5, r1
        ; addrof memVarAddr{r14}, distance.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; store [memVarAddr{r14}], distance.4{r1}
        lde  @rr14, r1
        ; addrof memVarAddr{r14}, pending.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; load pending.2{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; move pending.9{r6}, pending.2{r1}
        ld   r6, r1
if_54_end:
        ; branch oldOffset.2{r3} equals offset.2{r5}: and_56
        cp   r3, r5
        jr   eq, and_56
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%13
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, param.travel
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.travel{r10}
        lde  @rr14, r10
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; store [memVarAddr{r14}], pending.9{r6}
        lde  @rr14, r6
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.1{r0}
        lde  @rr14, r0
        jr   if_55_end

and_56:
        ; branch param.erase{r11} equals 0: or_57
        cp   r11, #%00
        jr   eq, or_57
        ; move pending.4{r0}, pending.9{r6}
        ld   r0, r6
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%13
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, param.travel
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.travel{r10}
        lde  @rr14, r10
        ; move pending.4{r9}, pending.4{r0}
        ld   r9, r0
        jr   for_48_continue

or_57:
        ; addrof memVarAddr{r14}, param.previous
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%13
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.previous{r9}
        lde  @rr14, r9
        ; addrof memVarAddr{r14}, param.travel
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%14
        adc  r14, #%00
        ; store [memVarAddr{r14}], param.travel{r10}
        lde  @rr14, r10
        ; cast t.27.1{r9}(i16), target.1{r0}(u8)
        ld   r10, r0
        ld   r9, #0
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.1{r0}
        lde  @rr14, r0
        ; addrof t.26.1{r0}, tiles
        ld   r0, #hi(var_0)
        ld   r1, #lo(var_0)
        ; add t.26.2{r0}, t.27.1{r9}
        add  r1, r10
        adc  r0, r9
        ; load t.25.1{r7}, [t.26.2{r0}]
        lde  r7, @rr0
        ; branch exponent.1{r4} notequals t.25.1{r7}: drawMoveFrame_Pu8_Pu8_Pu8_Pbool.no_critical_edge_46
        cp   r4, r7
        jr   ne, drawMoveFrame_Pu8_Pu8_Pu8_Pbool.no_critical_edge_46
        ; move pending.4{r0}, pending.9{r6}
        ld   r0, r6
        ; addrof memVarAddr{r14}, pending.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0b
        adc  r14, #%00
        ; store [memVarAddr{r14}], pending.4{r0}
        lde  @rr14, r0
        ; move pending.4{r9}, pending.4{r0}
        ld   r9, r0
        jr   for_48_continue

drawMoveFrame_Pu8_Pu8_Pu8_Pbool.no_critical_edge_46:
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; store [memVarAddr{r14}], pending.9{r6}
        lde  @rr14, r6
if_55_end:
        ; move displacement.1{r0}, offset.2{r5}
        ld   r0, r5
        ; addrof memVarAddr{r14}, offset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; store [memVarAddr{r14}], offset.2{r5}
        lde  @rr14, r5
        ; 316:3 if erase
        ; branch param.erase{r11} notequals 0: if_58_then
        cp   r11, #%00
        jr   ne, if_58_then
        ; addrof memVarAddr{r14}, oldOffset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], oldOffset.2{r3}
        lde  @rr14, r3
        jr   if_58_end

if_58_then:
        ; move displacement.3{r0}, oldOffset.2{r3}
        ld   r0, r3
        ; addrof memVarAddr{r14}, oldOffset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; store [memVarAddr{r14}], oldOffset.2{r3}
        lde  @rr14, r3
if_58_end:
        ; branch forward.1{r13} notequals 0: if_59_end
        cp   r13, #%00
        jr   ne, if_59_end
        ; const t.28.1{r1}, 0
        ld   r1, #%00
        ; sub displacement.5{r1}, displacement.2{r0}
        sub  r1, r0
        ; move displacement.4{r0}, displacement.5{r1}
        ld   r0, r1
if_59_end:
        ; move t.29.1{r1}, index.2{r2}
        ld   r1, r2
        ; and t.29.1{r1}, 12
        and  r1, #%0c
        ; add row.1{r1}, 3
        add  r1, #%03
        ; move column.1{r3}, index.2{r2}
        ld   r3, r2
        ; addrof memVarAddr{r14}, index.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; store [memVarAddr{r14}], index.2{r2}
        lde  @rr14, r2
        ; and column.1{r3}, 3
        and  r3, #%03
        ; move t.31.1{r2}, column.1{r3}
        ld   r2, r3
        ; shiftleft t.31.1{r2}, 3
        add r2, r2
        add r2, r2
        add r2, r2
        ; add t.30.1{r2}, 1
        inc  r2
        ; add column.2{r3}, t.30.1{r2}
        add  r3, r2
        ; 328:3 if horizontal
        ; branch horizontal.1{r12} notequals 0: if_60_then
        cp   r12, #%00
        jr   ne, if_60_then
        ; add row.2{r1}, displacement.4{r0}
        add  r1, r0
        ; move row.3{r9}, row.2{r1}
        ld   r9, r1
        ; move column.3{r10}, column.2{r3}
        ld   r10, r3
        jr   if_60_end

if_60_then:
        ; move column.4{r2}, column.2{r3}
        ld   r2, r3
        ; add column.4{r2}, displacement.4{r0}
        add  r2, r0
        ; move row.3{r9}, row.1{r1}
        ld   r9, r1
        ; move column.3{r10}, column.4{r2}
        ld   r10, r2
if_60_end:
        ; branch param.erase{r11} notequals 0: if_61_then
        cp   r11, #%00
        jr   ne, if_61_then
        ; cast t.33.1{r0}(i16), row.3{r9}(u8)
        ld   r1, r9
        ld   r0, #0
        ; cast t.34.1{r2}(i16), column.3{r10}(u8)
        ld   r3, r10
        ld   r2, #0
        ; call drawTileAt_Pi16_Pi16_Pu8[t.33.1{r0}, t.34.1{r2}, exponent.1{r4}]
        call drawTileAt_Pi16_Pi16_Pu8
        ; 340:4 if offset == distance
        ; addrof memVarAddr{r14}, distance.4
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0d
        adc  r14, #%00
        ; load distance.4{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; addrof memVarAddr{r14}, offset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; load offset.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; branch offset.2{r0} notequals distance.4{r1}: drawMoveFrame_Pu8_Pu8_Pu8_Pbool.no_critical_edge_42, if_62_then
        cp   r0, r1
        jr   ne, drawMoveFrame_Pu8_Pu8_Pu8_Pbool.no_critical_edge_42
        jr   if_62_then

if_61_then:
        ; addrof memVarAddr{r14}, offset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%10
        adc  r14, #%00
        ; load offset.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; move t.32.1{r3}, offset.2{r0}
        ld   r3, r0
        ; addrof memVarAddr{r14}, oldOffset.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0e
        adc  r14, #%00
        ; load oldOffset.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; sub t.32.1{r3}, oldOffset.2{r0}
        sub  r3, r0
        ; move row.3{r0}, row.3{r9}
        ld   r0, r9
        ; move column.3{r1}, column.3{r10}
        ld   r1, r10
        ; move param.direction{r2}, param.direction{r8}
        ld   r2, r8
        ; call clearTileTrail_Pu8_Pu8_Pu8_Pu8[row.3{r0}, column.3{r1}, param.direction{r2}, t.32.1{r3}]
        call clearTileTrail_Pu8_Pu8_Pu8_Pu8
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; load pending.9{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        jr   for_48_continue

drawMoveFrame_Pu8_Pu8_Pu8_Pbool.no_critical_edge_42:
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; load pending.9{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        jr   for_48_continue

if_62_then:
        ; addrof memVarAddr{r14}, pending.9
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0f
        adc  r14, #%00
        ; load pending.9{r9}, [memVarAddr{r14}]
        lde  r9, @rr14
        ; 341:5 if [...] & 128 != 0
        ; addrof memVarAddr{r14}, index.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0a
        adc  r14, #%00
        ; load index.2{r10}, [memVarAddr{r14}]
        lde  r10, @rr14
        ; cast t.38.1{r0}(i16), index.2{r10}(u8)
        ld   r1, r10
        ld   r0, #0
        ; addrof t.37.1{r2}, moveTargets
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; add t.37.2{r2}, t.38.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.36.1{r0}, [t.37.2{r2}]
        lde  r0, @rr2
        ; and t.35.1{r0}, 128
        and  r0, #%80
        ; branch t.35.1{r0} notequals 0: if_63_then
        cp   r0, #%00
        jr   ne, if_63_then
        ; 345:10 if [...] & 64 != 0
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load target.1{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; cast t.51.1{r2}(i16), target.1{r1}(u8)
        ld   r3, r1
        ld   r2, #0
        ; addrof t.50.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.50.2{r4}, t.51.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.49.1{r0}, [t.50.2{r4}]
        lde  r0, @rr4
        ; and t.48.1{r0}, 64
        and  r0, #%40
        ; branch t.48.1{r0} equals 0: for_48_continue, if_64_then
        cp   r0, #%00
        jr   eq, for_48_continue
        jr   if_64_then

if_63_then:
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; load target.1{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; cast t.42.1{r2}(i16), target.1{r1}(u8)
        ld   r3, r1
        ld   r2, #0
        ; addrof t.41.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.41.2{r4}, t.42.1{r2}
        add  r5, r3
        adc  r4, r2
        ; load t.40.1{r0}, [t.41.2{r4}]
        lde  r0, @rr4
        ; or t.39.1{r0}, 64
        or  r0, #%40
        ; move t.44.1{r1}, t.44.1{r2}
        ld   r1, r2
        ld   r2, r3
        ; addrof t.43.1{r4}, moveTargets
        ld   r4, #hi(var_2)
        ld   r5, #lo(var_2)
        ; add t.43.2{r4}, t.44.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.43.2{r4}], t.39.1{r0}
        lde  @rr4, r0
        ; const t.45.1{r0}, 0
        ld   r0, #%00
        ; cast t.47.1{r1}(i16), index.2{r10}(u8)
        ld   r2, r10
        ld   r1, #0
        ; addrof t.46.1{r4}, moveTiles
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; add t.46.2{r4}, t.47.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.46.2{r4}], t.45.1{r0}
        lde  @rr4, r0
        jr   for_48_continue

if_64_then:
        ; move target.1{r0}, target.1{r1}
        ld   r0, r1
        ; addrof memVarAddr{r14}, target.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%0c
        adc  r14, #%00
        ; store [memVarAddr{r14}], target.1{r1}
        lde  @rr14, r1
        ; call t.53.1{r0} = tileRow_Pu8[target.1{r0}] -> u8
        call tileRow_Pu8
        ; cast t.52.1{r0}(i16), t.53.1{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; addrof memVarAddr{r14}, t.52.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%11
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
        ; load target.1{r1}, [memVarAddr{r14}]
        lde  r1, @rr14
        ; move target.1{r0}, target.1{r1}
        ld   r0, r1
        ; call t.55.1{r0} = tileColumn_Pu8[target.1{r0}] -> u8
        call tileColumn_Pu8
        ; cast t.54.1{r2}(i16), t.55.1{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; load target.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; cast t.58.1{r0}(i16), target.1{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; addrof t.57.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.57.2{r4}, t.58.1{r0}
        add  r5, r1
        adc  r4, r0
        ; load t.56.1{r6}, [t.57.2{r4}]
        lde  r6, @rr4
        ; addrof memVarAddr{r14}, t.52.1
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%11
        adc  r14, #%00
        ; load t.52.1{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        incw r14
        lde  r1, @rr14
        decw r14
        ; move t.56.1{r4}, t.56.1{r6}
        ld   r4, r6
        ; call drawTileAt_Pi16_Pi16_Pu8[t.52.1{r0}, t.54.1{r2}, t.56.1{r4}]
        call drawTileAt_Pi16_Pi16_Pu8
        ; const t.59.1{r0}, 0
        ld   r0, #%00
        ; cast t.61.1{r1}(i16), index.2{r10}(u8)
        ld   r2, r10
        ld   r1, #0
        ; addrof t.60.1{r4}, moveTiles
        ld   r4, #hi(var_1)
        ld   r5, #lo(var_1)
        ; add t.60.2{r4}, t.61.1{r1}
        add  r5, r2
        adc  r4, r1
        ; store [t.60.2{r4}], t.59.1{r0}
        lde  @rr4, r0
for_48_continue:
        ; addrof memVarAddr{r14}, count.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%09
        adc  r14, #%00
        ; load count.2{r0}, [memVarAddr{r14}]
        lde  r0, @rr14
        ; add count.5{r0}, 1
        inc  r0
        ; move pending.2{r1}, pending.4{r9}
        ld   r1, r9
for_48:
        ; branch count.2{r0} lt 16: for_48_body
        cp   r0, #%10
        jr   ult, for_48_body
        ; 352:9 return pending
        ; move pending.2{r0}, pending.2{r1}
        ld   r0, r1
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
        add  %31, #%0d
        adc  %30, #%00
        ld   SPL, %31
        ld   SPH, %30
        ret

        ; void animateMove_Pu8
        ; arg direction (u8): r0
animateMove_Pu8:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move param.direction{r8}, direction{r0}
        ld   r8, r0
        ; const travel.1{r0}, 0
        ld   r0, #%00
        ; const speed.1{r1}, 1
        ld   r1, #%01
        ; const pending.1{r2}, 1
        ld   r2, #%01
        ; 361:2 while pending
        ; move travel.2{r9}, travel.1{r0}
        ld   r9, r0
        ; move speed.2{r10}, speed.1{r1}
        ld   r10, r1
        ; move pending.2{r11}, pending.1{r2}
        ld   r11, r2
        jr   while_65

while_65_body:
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
        ; call _ = drawMoveFrame_Pu8_Pu8_Pu8_Pbool[param.direction{r0}, previous.1{r1}, travel.3{r2}, t.7.1{r3}] -> bool
        call drawMoveFrame_Pu8_Pu8_Pu8_Pbool
        ; const t.8.1{r3}, 0
        ld   r3, #%00
        ; move param.direction{r0}, param.direction{r8}
        ld   r0, r8
        ; move previous.1{r1}, previous.1{r11}
        ld   r1, r11
        ; move travel.3{r2}, travel.3{r9}
        ld   r2, r9
        ; call pending.3{r0} = drawMoveFrame_Pu8_Pu8_Pu8_Pbool[param.direction{r0}, previous.1{r1}, travel.3{r2}, t.8.1{r3}] -> bool
        call drawMoveFrame_Pu8_Pu8_Pu8_Pbool
        ; move pending.3{r11}, pending.3{r0}
        ld   r11, r0
        ; call waitFrame[]
        call waitFrame
while_65:
        ; branch pending.2{r11} notequals 0: while_65_body
        cp   r11, #%00
        jr   ne, while_65_body
        ; const index.1{r0}, 0
        ld   r0, #%00
        ; 371:2 for index < 16
        ; move index.2{r8}, index.1{r0}
        ld   r8, r0
        jr   for_66

for_66_body:
        ; cast t.11.1{r0}(i16), index.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.10.1{r2}, moveTargets
        ld   r2, #hi(var_2)
        ld   r3, #lo(var_2)
        ; add t.10.2{r2}, t.11.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.9.1{r0}, [t.10.2{r2}]
        lde  r0, @rr2
        ; move target.1{r9}, t.9.1{r0}
        ld   r9, r0
        ; and target.1{r9}, 15
        and  r9, #%0f
        ; 373:3 if [...] != 0 && [...] != [...]
        ; cast t.14.1{r0}(i16), index.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.13.1{r2}, moveTiles
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; add t.13.2{r2}, t.14.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.12.1{r0}, [t.13.2{r2}]
        lde  r0, @rr2
        ; branch t.12.1{r0} equals 0: for_66_continue
        cp   r0, #%00
        jr   eq, for_66_continue
        ; cast t.17.1{r0}(i16), index.2{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.16.1{r2}, moveTiles
        ld   r2, #hi(var_1)
        ld   r3, #lo(var_1)
        ; add t.16.2{r2}, t.17.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.15.1{r0}, [t.16.2{r2}]
        lde  r0, @rr2
        ; cast t.20.1{r1}(i16), target.1{r9}(u8)
        ld   r2, r9
        ld   r1, #0
        ; addrof t.19.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.19.2{r4}, t.20.1{r1}
        add  r5, r2
        adc  r4, r1
        ; load t.18.1{r1}, [t.19.2{r4}]
        lde  r1, @rr4
        ; branch t.15.1{r0} equals t.18.1{r1}: for_66_continue
        cp   r0, r1
        jr   eq, for_66_continue
        ; move target.1{r0}, target.1{r9}
        ld   r0, r9
        ; call t.23.1{r0} = tileRow_Pu8[target.1{r0}] -> u8
        call tileRow_Pu8
        ; cast t.22.1{r0}(i16), t.23.1{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; move t.21.1{r10}, t.22.1{r0}
        ld   r11, r1
        ld   r10, r0
        ; add t.21.1{r10}, 1
        incw r10
        ; move target.1{r0}, target.1{r9}
        ld   r0, r9
        ; call t.26.1{r0} = tileColumn_Pu8[target.1{r0}] -> u8
        call tileColumn_Pu8
        ; cast t.25.1{r0}(i16), t.26.1{r0}(u8)
        ld   r1, r0
        ld   r0, #0
        ; move t.24.1{r2}, t.25.1{r0}
        ld   r3, r1
        ld   r2, r0
        ; add t.24.1{r2}, 1
        incw r2
        ; move t.21.1{r0}, t.21.1{r10}
        ld   r0, r10
        ld   r1, r11
        ; call setCursor_Pi16_Pi16[t.21.1{r0}, t.24.1{r2}]
        call setCursor_Pi16_Pi16
        ; cast t.29.1{r0}(i16), target.1{r9}(u8)
        ld   r1, r9
        ld   r0, #0
        ; addrof t.28.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.28.2{r2}, t.29.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.27.1{r0}, [t.28.2{r2}]
        lde  r0, @rr2
        ; call printTile_Pu8[t.27.1{r0}]
        call printTile_Pu8
for_66_continue:
        ; move index.4{r0}, index.2{r8}
        ld   r0, r8
        ; add index.4{r0}, 1
        inc  r0
        ; move index.2{r8}, index.4{r0}
        ld   r8, r0
for_66:
        ; branch index.2{r8} lt 16: for_66_body
        cp   r8, #%10
        jr   ult, for_66_body
        ; restore clobbered non-volatile registers
        pop  r11
        pop  r10
        pop  r9
        pop  r8
        ret

        ; void drawFrame
drawFrame:
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
        ; const t.0.1{r0}, [string-15]
        ld   r0, #hi(string_15)
        ld   r1, #lo(string_15)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ret

        ; void clearBoard
clearBoard:
        ; save clobbered non-volatile registers
        push r8
        push r9
        ; const row.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ; 413:2 for row < 15
        ; move row.2{r8}, row.1{r0}
        ld   r9, r1
        ld   r8, r0
        jr   for_69

for_69_body:
        ; move t.1.1{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add t.1.1{r0}, 3
        add  r1, #%03
        adc  r0, #%00
        ; const arg.0.1{r2}, 1
        ld   r2, #%00
        ld   r3, #%01
        ; call setCursor_Pi16_Pi16[t.1.1{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.2.1{r0}, [string-16]
        ld   r0, #hi(string_16)
        ld   r1, #lo(string_16)
        ; call printString_P_pu8[t.2.1{r0}]
        call printString_P_pu8
        ; move row.3{r0}, row.2{r8}
        ld   r0, r8
        ld   r1, r9
        ; add row.3{r0}, 1
        incw r0
        ; move row.2{r8}, row.3{r0}
        ld   r9, r1
        ld   r8, r0
for_69:
        ; branch row.2{r8} lt 15: for_69_body
        cp   r8, #%00
        jr   lt, for_69_body
        jr   ne, .lt4
        cp   r9, #%0f
        jr   ult, for_69_body
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
        ; const index.1{r0}, 0
        ld   r0, #%00
        ; const row.1{r1}, 3
        ld   r1, #%00
        ld   r2, #%03
        ; const boardRow.1{r3}, 0
        ld   r3, #%00
        ; 423:2 for boardRow < 4
        ; move index.2{r8}, index.1{r0}
        ld   r8, r0
        ; move row.2{r9}, row.1{r1}
        ld   r10, r2
        ld   r9, r1
        ; move boardRow.2{r11}, boardRow.1{r3}
        ld   r11, r3
        jr   for_70

for_70_body:
        ; const column.1{r0}, 1
        ld   r0, #%00
        ld   r1, #%01
        ; const boardColumn.1{r2}, 0
        ld   r2, #%00
        ; 425:3 for boardColumn < 4
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
        jr   for_71

for_71_body:
        ; addrof memVarAddr{r14}, boardColumn.2
        ld   r14, SPH
        ld   r15, SPL
        add  r15, #%08
        adc  r14, #%00
        ; store [memVarAddr{r14}], boardColumn.2{r3}
        lde  @rr14, r3
        ; cast t.7.1{r0}(i16), index.3{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.6.1{r2}, tiles
        ld   r2, #hi(var_0)
        ld   r3, #lo(var_0)
        ; add t.6.2{r2}, t.7.1{r0}
        add  r3, r1
        adc  r2, r0
        ; load t.5.1{r4}, [t.6.2{r2}]
        lde  r4, @rr2
        ; move row.2{r0}, row.2{r9}
        ld   r0, r9
        ld   r1, r10
        ; move column.2{r2}, column.2{r12}
        ld   r2, r12
        ld   r3, r13
        ; call drawTileAt_Pi16_Pi16_Pu8[row.2{r0}, column.2{r2}, t.5.1{r4}]
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
for_71:
        ; branch boardColumn.2{r3} lt 4: for_71_body
        cp   r3, #%04
        jr   ult, for_71_body
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
for_70:
        ; branch boardRow.2{r11} lt 4: for_70_body
        cp   r11, #%04
        jr   ult, for_70_body
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
        ; const t.0.1{r0}, [string-17]
        ld   r0, #hi(string_17)
        ld   r1, #lo(string_17)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ; addrof a.1.1{r0}, score
        ld   r0, #hi(var_3)
        ld   r1, #lo(var_3)
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
        ; const t.3.1{r0}, [string-18]
        ld   r0, #hi(string_18)
        ld   r1, #lo(string_18)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        ret

        ; void drawStatus
drawStatus:
        ; const arg.0.0{r0}, 19
        ld   r0, #%00
        ld   r1, #%13
        ; const arg.0.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.0.0{r0}, arg.0.1{r2}]
        call setCursor_Pi16_Pi16
        ; const t.0.1{r0}, [string-19]
        ld   r0, #hi(string_19)
        ld   r1, #lo(string_19)
        ; call printString_P_pu8[t.0.1{r0}]
        call printString_P_pu8
        ; const arg.2.0{r0}, 19
        ld   r0, #%00
        ld   r1, #%13
        ; const arg.2.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.2.0{r0}, arg.2.1{r2}]
        call setCursor_Pi16_Pi16
        ; 445:2 if gameState == 1
        ; addrof a.1.1{r0}, gameState
        ld   r0, #hi(var_4)
        ld   r1, #lo(var_4)
        ; load t.2.1{r2}, [a.1.1{r0}]
        lde  r2, @rr0
        ; branch t.2.1{r2} equals 1: if_72_then
        cp   r2, #%01
        jr   eq, if_72_then
        ; 448:7 if gameState == 2
        ; branch t.5.1{r2} notequals 2: drawStatus_ret, if_73_then
        cp   r2, #%02
        jr   ne, drawStatus_ret
        jr   if_73_then

if_72_then:
        ; const t.3.1{r0}, [string-20]
        ld   r0, #hi(string_20)
        ld   r1, #lo(string_20)
        ; call printString_P_pu8[t.3.1{r0}]
        call printString_P_pu8
        jr   drawStatus_ret

if_73_then:
        ; const t.6.1{r0}, [string-21]
        ld   r0, #hi(string_21)
        ld   r1, #lo(string_21)
        ; call printString_P_pu8[t.6.1{r0}]
        call printString_P_pu8
drawStatus_ret:
        ret

        ; void newGame
newGame:
        ; const index.1{r0}, 0
        ld   r0, #%00
        ; 454:2 for index < 16
        jr   for_74

for_74_body:
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
for_74:
        ; branch index.2{r0} lt 16: for_74_body
        cp   r0, #%10
        jr   ult, for_74_body
        ; const t.4.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ld   r2, #%00
        ld   r3, #%00
        ; addrof a.5.1{r4}, score
        ld   r4, #hi(var_3)
        ld   r5, #lo(var_3)
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
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.7.1{r2}], t.6.1{r0}
        lde  @rr2, r0
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
        ; call setCursor_Pi16_Pi16[arg.5.0{r0}, arg.5.1{r2}]
        call setCursor_Pi16_Pi16
        ret

        ; void main
main:
        ; save clobbered non-volatile registers
        push r8
        push r9
        push r10
        ; begin initialize global variables
        ; const t.3.1{r0}, 0
        ld   r0, #%00
        ld   r1, #%00
        ld   r2, #%00
        ld   r3, #%00
        ; addrof a.4.1{r4}, score
        ld   r4, #hi(var_3)
        ld   r5, #lo(var_3)
        ; store [a.4.1{r4}], t.3.1{r0}
        lde  @rr4, r0
        incw r4
        lde  @rr4, r1
        incw r4
        lde  @rr4, r2
        incw r4
        lde  @rr4, r3
        sub  r5, #3
        sbc  r4, #0
        ; const t.5.1{r0}, 0
        ld   r0, #%00
        ; addrof a.6.1{r2}, gameState
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.6.1{r2}], t.5.1{r0}
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
        ; 471:2 while true
        jr   while_75

if_76_end:
        ; branch key.1{r8} equals 114: if_77_then
        cp   r9, #%72
        jr   ne, .notEquals5
        cp   r8, #%00
        jr   eq, if_77_then
.notEquals5:
        ; branch key.1{r8} equals 82: if_77_then
        cp   r9, #%52
        jr   ne, .notEquals6
        cp   r8, #%00
        jr   eq, if_77_then
.notEquals6:
        ; 480:3 if gameState != 0
        ; addrof a.7.1{r0}, gameState
        ld   r0, #hi(var_4)
        ld   r1, #lo(var_4)
        ; load t.8.1{r2}, [a.7.1{r0}]
        lde  r2, @rr0
        ; branch t.8.1{r2} notequals 0: while_75
        cp   r2, #%00
        jr   ne, while_75
        ; branch key.1{r8} equals 1: if_80_then, or_82
        cp   r9, #%01
        jr   ne, .notEquals7
        cp   r8, #%00
        jr   eq, if_80_then
.notEquals7:
        jr   or_82

if_77_then:
        ; call newGame[]
        call newGame
        jr   while_75

or_82:
        ; branch key.1{r8} equals 97: if_80_then
        cp   r9, #%61
        jr   ne, .notEquals8
        cp   r8, #%00
        jr   eq, if_80_then
.notEquals8:
        ; branch key.1{r8} equals 65: if_80_then
        cp   r9, #%41
        jr   ne, .notEquals9
        cp   r8, #%00
        jr   eq, if_80_then
.notEquals9:
        ; branch key.1{r8} equals 2: if_83_then
        cp   r9, #%02
        jr   ne, .notEquals10
        cp   r8, #%00
        jr   eq, if_83_then
.notEquals10:
        ; branch key.1{r8} equals 100: if_83_then, or_84
        cp   r9, #%64
        jr   ne, .notEquals11
        cp   r8, #%00
        jr   eq, if_83_then
.notEquals11:
        jr   or_84

if_80_then:
        ; const direction.2{r0}, 0
        ld   r0, #%00
        ; move direction.3{r8}, direction.2{r0}
        ld   r8, r0
        jr   if_80_end

or_84:
        ; branch key.1{r8} equals 68: if_83_then
        cp   r9, #%44
        jr   ne, .notEquals12
        cp   r8, #%00
        jr   eq, if_83_then
.notEquals12:
        ; branch key.1{r8} equals 3: if_86_then
        cp   r9, #%03
        jr   ne, .notEquals13
        cp   r8, #%00
        jr   eq, if_86_then
.notEquals13:
        ; branch key.1{r8} equals 119: if_86_then, or_87
        cp   r9, #%77
        jr   ne, .notEquals14
        cp   r8, #%00
        jr   eq, if_86_then
.notEquals14:
        jr   or_87

if_83_then:
        ; const direction.4{r0}, 1
        ld   r0, #%01
        ; move direction.3{r8}, direction.4{r0}
        ld   r8, r0
        jr   if_80_end

or_87:
        ; branch key.1{r8} equals 87: if_86_then
        cp   r9, #%57
        jr   ne, .notEquals15
        cp   r8, #%00
        jr   eq, if_86_then
.notEquals15:
        ; branch key.1{r8} equals 4: if_89_then
        cp   r9, #%04
        jr   ne, .notEquals16
        cp   r8, #%00
        jr   eq, if_89_then
.notEquals16:
        ; branch key.1{r8} equals 115: if_89_then, or_90
        cp   r9, #%73
        jr   ne, .notEquals17
        cp   r8, #%00
        jr   eq, if_89_then
.notEquals17:
        jr   or_90

if_86_then:
        ; const direction.5{r0}, 2
        ld   r0, #%02
        ; move direction.3{r8}, direction.5{r0}
        ld   r8, r0
        jr   if_80_end

or_90:
        ; branch key.1{r8} notequals 83: while_75, if_89_then
        cp   r9, #%53
        jr   ne, while_75
        cp   r8, #%00
        jr   ne, while_75
if_89_then:
        ; const direction.6{r0}, 3
        ld   r0, #%03
        ; move direction.3{r8}, direction.6{r0}
        ld   r8, r0
if_80_end:
        ; 500:3 if !slide_Pu8([ExprVarAccess[varName=direction, index=1, scope=function, type=u8, varIsArray=false, location=500:13]])
        ; move direction.3{r0}, direction.3{r8}
        ld   r0, r8
        ; call t.9.1{r0} = slide_Pu8[direction.3{r0}] -> bool
        call slide_Pu8
        ; branch t.9.1{r0} equals 0: while_75
        cp   r0, #%00
        jr   eq, while_75
        ; move direction.3{r0}, direction.3{r8}
        ld   r0, r8
        ; call animateMove_Pu8[direction.3{r0}]
        call animateMove_Pu8
        ; call spawned.1{r0} = spawnTile[] -> u8
        call spawnTile
        ; move spawned.1{r8}, spawned.1{r0}
        ld   r8, r0
        ; 506:3 if spawned != 255
        ; branch spawned.1{r8} equals 255: if_93_end
        cp   r8, #%ff
        jr   eq, if_93_end
        ; call t.11.1{r0} = tileRow_Pu8[spawned.1{r0}] -> u8
        call tileRow_Pu8
        ; cast t.10.1{r9}(i16), t.11.1{r0}(u8)
        ld   r10, r0
        ld   r9, #0
        ; move spawned.1{r0}, spawned.1{r8}
        ld   r0, r8
        ; call t.13.1{r0} = tileColumn_Pu8[spawned.1{r0}] -> u8
        call tileColumn_Pu8
        ; cast t.12.1{r2}(i16), t.13.1{r0}(u8)
        ld   r3, r0
        ld   r2, #0
        ; cast t.16.1{r0}(i16), spawned.1{r8}(u8)
        ld   r1, r8
        ld   r0, #0
        ; addrof t.15.1{r4}, tiles
        ld   r4, #hi(var_0)
        ld   r5, #lo(var_0)
        ; add t.15.2{r4}, t.16.1{r0}
        add  r5, r1
        adc  r4, r0
        ; load t.14.1{r6}, [t.15.2{r4}]
        lde  r6, @rr4
        ; move t.10.1{r0}, t.10.1{r9}
        ld   r0, r9
        ld   r1, r10
        ; move t.14.1{r4}, t.14.1{r6}
        ld   r4, r6
        ; call drawTileAt_Pi16_Pi16_Pu8[t.10.1{r0}, t.12.1{r2}, t.14.1{r4}]
        call drawTileAt_Pi16_Pi16_Pu8
if_93_end:
        ; 509:3 if gameState == 0 && !canMove([])
        ; addrof a.17.1{r0}, gameState
        ld   r0, #hi(var_4)
        ld   r1, #lo(var_4)
        ; load t.18.1{r2}, [a.17.1{r0}]
        lde  r2, @rr0
        ; branch t.18.1{r2} notequals 0: if_94_end
        cp   r2, #%00
        jr   ne, if_94_end
        ; call t.19.1{r0} = canMove[] -> bool
        call canMove
        ; branch t.19.1{r0} notequals 0: if_94_end
        cp   r0, #%00
        jr   ne, if_94_end
        ; const t.20.1{r0}, 2
        ld   r0, #%02
        ; addrof a.21.1{r2}, gameState
        ld   r2, #hi(var_4)
        ld   r3, #lo(var_4)
        ; store [a.21.1{r2}], t.20.1{r0}
        lde  @rr2, r0
if_94_end:
        ; call drawScore[]
        call drawScore
        ; 513:3 if gameState != 0
        ; addrof a.22.1{r0}, gameState
        ld   r0, #hi(var_4)
        ld   r1, #lo(var_4)
        ; load t.23.1{r2}, [a.22.1{r0}]
        lde  r2, @rr0
        ; branch t.23.1{r2} equals 0: if_96_end
        cp   r2, #%00
        jr   eq, if_96_end
        ; call drawStatus[]
        call drawStatus
if_96_end:
        ; const arg.13.0{r0}, 21
        ld   r0, #%00
        ld   r1, #%15
        ; const arg.13.1{r2}, 0
        ld   r2, #%00
        ld   r3, #%00
        ; call setCursor_Pi16_Pi16[arg.13.0{r0}, arg.13.1{r2}]
        call setCursor_Pi16_Pi16
while_75:
        ; call key.1{r0} = getChar[] -> i16
        call getChar
        ; move key.1{r8}, key.1{r0}
        ld   r9, r1
        ld   r8, r0
        ; 473:3 if key == 27
        ; branch key.1{r8} notequals 27: if_76_end
        cp   r9, #%1b
        jr   ne, if_76_end
        cp   r8, #%00
        jr   ne, if_76_end
        ; restore clobbered non-volatile registers
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

