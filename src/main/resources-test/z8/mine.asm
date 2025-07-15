        .const RP  = %FD
        .const SPH = %FE
        .const SPL = %FF

        .org %E000

start:
        push RP
        srp  #%20
        call @main
        pop  RP
        ret

        ; void printString
        ;   sp+7: arg str
@printString:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move str{r8}, str{r0}
        ld r8, r0
        ld r9, r1
        ; 2:2 while true
        jp @while_1
@if_2_end:
        ; move chr{r0}, chr{r10}
        ld r0, r10
        ; call printChar[chr{r0}]
        call printChar
@while_1:
        ; load chr{r10}, [str{r8}]
        lde r10, rr8
        ; 4:3 if chr == 0
        ; equals t.2{r0}, chr{r10}, 0
        cp  r10, #%00
        jr  nz, .1
        cp  r11, #%00
        jr  nz, .1
        cp  r12, #%00
        jr  nz, .1
        cp  r13, #%00
        jr  nz, .1
        cp  r14, #%00
        jr  nz, .1
        cp  r15, #%00
        jr  nz, .1
        cp  %30, #%00
        jr  nz, .1
        cp  %31, #%00
        jr  nz, .1
        cp  %32, #%00
        jr  nz, .1
        cp  %33, #%00
        jr  nz, .1
        cp  %34, #%00
        jr  nz, .1
        cp  %35, #%00
        jr  nz, .1
        cp  %36, #%00
        jr  nz, .1
        cp  %37, #%00
        jr  nz, .1
        cp  %38, #%00
        jr  nz, .1
        cp  %39, #%00
        jr  nz, .1
        ld  r0, #%ff
        jr  .2
.1:
        ld  r0, #%00
.2:
        ; branch t.2{r0}, false, @if_2_end
        or r0, r0
        jp z, @if_2_end
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printStringLength
        ;   sp+8: arg str
        ;   sp+6: arg length
@printStringLength:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; move str{r8}, str{r0}
        ld r8, r0
        ld r9, r1
        ; move length{r10}, length{r2}
        ld r10, r2
        ; 13:2 while length > 0
        jp @while_3
@while_3_body:
        ; load chr{r0}, [str{r8}]
        lde r0, rr8
        ; call printChar[chr{r0}]
        call printChar
        ; dec length{r10}
        dec r10
@while_3:
        ; gt t.3{r0}, length{r10}, 0
        cp  r10, #%00
        jr  uge, .3
.3:
        ld  r0, #%ff
        jr  .5
.4:
        ld  r0, #%00
.5:
        ; branch t.3{r0}, true, @while_3_body
        or r0, r0
        jp nz, @while_3_body
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printUint
        ;   sp+19: arg number
        ;   sp+9: var buffer
        ;   sp+7: var remainder
@printUint:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; reserve space for local variables
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; const pos{r8}, 20
        ld r8, #%14
        ; 24:2 while true
@while_4:
        ; dec pos{r8}
        dec r8
        ; const t.6{r9}, 10
        ld r9, #%00
        ld r10, #%0a
        ; move t.5{r11}, number{r0}
        ld r11, r0
        ld r12, r1
        ; mod t.5{r11}, t.5{r11}, t.6{r9}
        not implemented
        ; cast remainder(i64), t.5{r11}(i16)
        not implemented
        ; const t.7{r9}, 10
        ld r9, #%00
        ld r10, #%0a
        ; div number{r0}, number{r0}, t.7{r9}
        not implemented
        ; cast t.8{r9}(u8), remainder(i64)
        not implemented
        ; const t.9{r10}, 48
        ld r10, #%30
        ; add digit{r9}, digit{r9}, t.9{r10}
        add r9, r10
        ; cast t.11{r10}(i16), pos{r8}(u8)
        not implemented
        ; cast t.12{r10}(u8*), t.11{r10}(i16)
        not implemented
        ; addrof t.10{r12}, [buffer]
        not implemented
        ; add t.10{r12}, t.10{r12}, t.12{r10}
        add r13, r11
        adc r12, r10
        ; store [t.10{r12}], digit{r9}
        lde rr12, r9
        ; 30:3 if number == 0
        ; equals t.13{r9}, number{r0}, 0
        cp  r0, #%00
        jr  nz, .6
        cp  r1, #%00
        jr  nz, .6
        cp  r2, #%00
        jr  nz, .6
        cp  r3, #%00
        jr  nz, .6
        cp  r4, #%00
        jr  nz, .6
        cp  r5, #%00
        jr  nz, .6
        cp  r6, #%00
        jr  nz, .6
        cp  r7, #%00
        jr  nz, .6
        cp  r8, #%00
        jr  nz, .6
        cp  r9, #%00
        jr  nz, .6
        cp  r10, #%00
        jr  nz, .6
        cp  r11, #%00
        jr  nz, .6
        cp  r12, #%00
        jr  nz, .6
        cp  r13, #%00
        jr  nz, .6
        cp  r14, #%00
        jr  nz, .6
        cp  r15, #%00
        jr  nz, .6
        ld  r9, #%ff
        jr  .7
.6:
        ld  r9, #%00
.7:
        ; branch t.13{r9}, false, @while_4
        or r9, r9
        jp z, @while_4
        ; cast t.15{r9}(i16), pos{r8}(u8)
        not implemented
        ; cast t.16{r10}(u8*), t.15{r9}(i16)
        not implemented
        ; addrof t.14{r0}, [buffer]
        not implemented
        ; add t.14{r0}, t.14{r0}, t.16{r10}
        add r1, r11
        adc r0, r10
        ; const t.18{r9}, 20
        ld r9, #%14
        ; move t.17{r2}, t.18{r9}
        ld r2, r9
        ; sub t.17{r2}, t.17{r2}, pos{r8}
        sub r2, r8
        ; call printStringLength[t.14{r0}, t.17{r2}]
        call printStringLength
        ; free space for local variables
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; u8 getChar
@getChar:
        ; 57:9 return 0
        ; const t.0{r0}, 0
        ld r0, #%00
        ret

        ; void setCursor
        ;   sp+3: arg x
        ;   sp+2: arg y
@setCursor:
        ret

        ; void initRandom
        ;   sp+5: arg salt
@initRandom:
        ret

        ; i32 random
@random:
        ; 70:9 return 0
        ; const t.0{r0}, 0
        ld r0, #%00
        ld r1, #%00
        ld r2, #%00
        ld r3, #%00
        ret

        ; i16 rowColumnToCell
        ;   sp+5: arg row
        ;   sp+3: arg column
@rowColumnToCell:
        ; 15:21 return row * 40 + column
        ; const t.4{r6}, 40
        ld r6, #%00
        ld r7, #%28
        ; mul t.3{r2}, t.3{r2}, t.4{r6}
        not implemented
        ; move t.2{r0}, t.3{r2}
        ld r0, r2
        ld r1, r3
        ; add t.2{r0}, t.2{r0}, column{r4}
        add r1, r5
        adc r0, r4
        ret

        ; u8 getCell
        ;   sp+5: arg row
        ;   sp+3: arg column
@getCell:
        ; move column{r4}, column{r3}
        ld r4, r3
        ld r5, r4
        ; 19:15 return [...]
        ; move row{r2}, row{r1}
        ld r2, r1
        ld r3, r2
        ; call t.4{r0} = rowColumnToCell[row{r2}, column{r4}] -> i16
        call rowColumnToCell
        ; cast t.5{r2}(u8*), t.4{r0}(i16)
        not implemented
        ; addrof t.3{r4}, [field]
        not implemented
        ; add t.3{r4}, t.3{r4}, t.5{r2}
        add r5, r3
        adc r4, r2
        ; load t.2{r0}, [t.3{r4}]
        lde r0, rr4
        ret

        ; bool isBomb
        ;   sp+2: arg cell
@isBomb:
        ; 23:27 return cell & 1 != 0
        ; const t.3{r2}, 1
        ld r2, #%01
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and r1, r2
        ; notequals t.1{r0}, t.2{r1}, 0
        cp  r1, #%00
        jr  nz, .8
        cp  r2, #%00
        jr  nz, .8
        cp  r3, #%00
        jr  nz, .8
        cp  r4, #%00
        jr  nz, .8
        cp  r5, #%00
        jr  nz, .8
        cp  r6, #%00
        jr  nz, .8
        cp  r7, #%00
        jr  nz, .8
        cp  r8, #%00
        jr  nz, .8
        cp  r9, #%00
        jr  nz, .8
        cp  r10, #%00
        jr  nz, .8
        cp  r11, #%00
        jr  nz, .8
        cp  r12, #%00
        jr  nz, .8
        cp  r13, #%00
        jr  nz, .8
        cp  r14, #%00
        jr  nz, .8
        cp  r15, #%00
        jr  nz, .8
        cp  %30, #%00
        jr  nz, .8
        ld  r0, #%00
        jr  .9
.8:
        ld  r0, #%ff
.9:
        ret

        ; bool isOpen
        ;   sp+2: arg cell
@isOpen:
        ; 27:27 return cell & 2 != 0
        ; const t.3{r2}, 2
        ld r2, #%02
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and r1, r2
        ; notequals t.1{r0}, t.2{r1}, 0
        cp  r1, #%00
        jr  nz, .10
        cp  r2, #%00
        jr  nz, .10
        cp  r3, #%00
        jr  nz, .10
        cp  r4, #%00
        jr  nz, .10
        cp  r5, #%00
        jr  nz, .10
        cp  r6, #%00
        jr  nz, .10
        cp  r7, #%00
        jr  nz, .10
        cp  r8, #%00
        jr  nz, .10
        cp  r9, #%00
        jr  nz, .10
        cp  r10, #%00
        jr  nz, .10
        cp  r11, #%00
        jr  nz, .10
        cp  r12, #%00
        jr  nz, .10
        cp  r13, #%00
        jr  nz, .10
        cp  r14, #%00
        jr  nz, .10
        cp  r15, #%00
        jr  nz, .10
        cp  %30, #%00
        jr  nz, .10
        ld  r0, #%00
        jr  .11
.10:
        ld  r0, #%ff
.11:
        ret

        ; bool isFlag
        ;   sp+2: arg cell
@isFlag:
        ; 31:27 return cell & 4 != 0
        ; const t.3{r2}, 4
        ld r2, #%04
        ; and t.2{r1}, t.2{r1}, t.3{r2}
        and r1, r2
        ; notequals t.1{r0}, t.2{r1}, 0
        cp  r1, #%00
        jr  nz, .12
        cp  r2, #%00
        jr  nz, .12
        cp  r3, #%00
        jr  nz, .12
        cp  r4, #%00
        jr  nz, .12
        cp  r5, #%00
        jr  nz, .12
        cp  r6, #%00
        jr  nz, .12
        cp  r7, #%00
        jr  nz, .12
        cp  r8, #%00
        jr  nz, .12
        cp  r9, #%00
        jr  nz, .12
        cp  r10, #%00
        jr  nz, .12
        cp  r11, #%00
        jr  nz, .12
        cp  r12, #%00
        jr  nz, .12
        cp  r13, #%00
        jr  nz, .12
        cp  r14, #%00
        jr  nz, .12
        cp  r15, #%00
        jr  nz, .12
        cp  %30, #%00
        jr  nz, .12
        ld  r0, #%00
        jr  .13
.12:
        ld  r0, #%ff
.13:
        ret

        ; bool checkCellBounds
        ;   sp+5: arg row
        ;   sp+3: arg column
@checkCellBounds:
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; gteq t.2{r0}, row{r1}, 0
        cp  r1, #%00
        jr  ge, .14
        jr  nz, .15
        cp  r2, #%00
        jr  uge, .14
.14:
        ld  r0, #%ff
        jr  .16
.15:
        ld  r0, #%00
.16:
        ; branch t.2{r0}, false, @and_next_8
        or r0, r0
        jp z, @and_next_8
        ; lt t.2{r0}, row{r1}, 20
        cp  r1, #%00
        jr  lt, .17
        jr  nz, .18
        cp  r2, #%14
        jr  ult, .17
.17:
        ld  r0, #%ff
        jr  .19
.18:
        ld  r0, #%00
.19:
@and_next_8:
        ; branch t.2{r0}, false, @and_next_7
        or r0, r0
        jp z, @and_next_7
        ; gteq t.2{r0}, column{r3}, 0
        cp  r3, #%00
        jr  ge, .20
        jr  nz, .21
        cp  r4, #%00
        jr  uge, .20
.20:
        ld  r0, #%ff
        jr  .22
.21:
        ld  r0, #%00
.22:
@and_next_7:
        ; branch t.2{r0}, false, @checkCellBounds_ret
        or r0, r0
        jp z, @checkCellBounds_ret
        ; lt t.2{r0}, column{r3}, 40
        cp  r3, #%00
        jr  lt, .23
        jr  nz, .24
        cp  r4, #%28
        jr  ult, .23
.23:
        ld  r0, #%ff
        jr  .25
.24:
        ld  r0, #%00
.25:
@checkCellBounds_ret:
        ret

        ; void setCell
        ;   sp+8: arg row
        ;   sp+6: arg column
        ;   sp+4: arg cell
@setCell:
        ; save globbered non-volatile registers
        push r8
        push r9
        ; move column{r5}, column{r2}
        ld r5, r2
        ld r6, r3
        ; move cell{r8}, cell{r4}
        ld r8, r4
        ; move row{r2}, row{r0}
        ld r2, r0
        ld r3, r1
        ; move column{r4}, column{r5}
        ld r4, r5
        ld r5, r6
        ; call t.4{r0} = rowColumnToCell[row{r2}, column{r4}] -> i16
        call rowColumnToCell
        ; cast t.5{r0}(u8*), t.4{r0}(i16)
        not implemented
        ; addrof t.3{r2}, [field]
        not implemented
        ; add t.3{r2}, t.3{r2}, t.5{r0}
        add r3, r1
        adc r2, r0
        ; store [t.3{r2}], cell{r8}
        lde rr2, r8
        ; restore globbered non-volatile registers
        pop r9
        pop r8
        ret

        ; u8 getBombCountAround
        ;   sp+18: arg row
        ;   sp+16: arg column
        ;   sp+5: var r
        ;   sp+3: var dc
        ;   sp+1: var c
@getBombCountAround:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        ; reserve space for local variables
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; move row{r8}, row{r1}
        ld r8, r1
        ld r9, r2
        ; move column{r10}, column{r3}
        ld r10, r3
        ld r11, r4
        ; const count{r12}, 0
        ld r12, #%00
        ; const dr{r13}, -1
        ld r13, #%ff
        ld r14, #%ff
        ; 45:2 for dr <= 1
        jp @for_9
@for_9_body:
        ; move r{r5}, row{r8}
        ld r5, r8
        ld r6, r9
        ; add r{r5}, r{r5}, dr{r13}
        add r6, r14
        adc r5, r13
        ; const dc{r3}, -1
        ld r3, #%ff
        ld r4, #%ff
        ; 47:3 for dc <= 1
        ; move r, r{r5}
        not implemented
        ; move dc{r1}, dc{r3}
        ld r1, r3
        ld r2, r4
        jp @for_10
@for_10_body:
        ; move dc{r3}, dc{r1}
        ld r3, r1
        ld r4, r2
        ; move r{r5}, r
        not implemented
        ; move c{r0}, column{r10}
        ld r0, r10
        ld r1, r11
        ; add c{r0}, c{r0}, dc{r3}
        add r1, r4
        adc r0, r3
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; move r{r1}, r{r5}
        ld r1, r5
        ld r2, r6
        ; move c, c{r0}
        not implemented
        ; move c{r3}, c
        not implemented
        ; move dc, dc{r3}
        not implemented
        ; move r, r{r5}
        not implemented
        ; call t.10{r0} = checkCellBounds[r{r1}, c{r3}] -> bool
        call checkCellBounds
        ; branch t.10{r0}, false, @for_10_continue
        or r0, r0
        jp z, @for_10_continue
        ; move r{r5}, r
        not implemented
        ; move r{r1}, r{r5}
        ld r1, r5
        ld r2, r6
        ; move c{r3}, c
        not implemented
        ; move r, r{r5}
        not implemented
        ; call cell{r0} = getCell[r{r1}, c{r3}] -> u8
        call getCell
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; move cell{r1}, cell{r0}
        ld r1, r0
        ; call t.11{r0} = isBomb[cell{r1}] -> bool
        call isBomb
        ; branch t.11{r0}, false, @for_10_continue
        or r0, r0
        jp z, @for_10_continue
        ; inc count{r12}
        inc r12
@for_10_continue:
        ; move dc{r1}, dc
        not implemented
        ; inc dc{r1}
        add r2, #%01
        adc r1, #%00
@for_10:
        ; lteq t.9{r3}, dc{r1}, 1
        cp  r1, #%00
        jr  le, .26
        jr  nz, .27
        cp  r2, #%01
        jr  ule, .26
.26:
        ld  r3, #%ff
        jr  .28
.27:
        ld  r3, #%00
.28:
        ; branch t.9{r3}, true, @for_10_body
        or r3, r3
        jp nz, @for_10_body
        ; inc dr{r13}
        add r14, #%01
        adc r13, #%00
@for_9:
        ; lteq t.8{r1}, dr{r13}, 1
        cp  r13, #%00
        jr  le, .29
        jr  nz, .30
        cp  r14, #%01
        jr  ule, .29
.29:
        ld  r1, #%ff
        jr  .31
.30:
        ld  r1, #%00
.31:
        ; branch t.8{r1}, true, @for_9_body
        or r1, r1
        jp nz, @for_9_body
        ; 57:9 return count
        ; move count{r0}, count{r12}
        ld r0, r12
        ; free space for local variables
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop r14
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; u8 getSpacer
        ;   sp+10: arg row
        ;   sp+8: arg column
        ;   sp+6: arg rowCursor
        ;   sp+4: arg columnCursor
@getSpacer:
        ; save globbered non-volatile registers
        push r8
        ; 61:2 if rowCursor == row
        ; equals t.4{r1}, rowCursor{r5}, row{r1}
        not implemented
        ; branch t.4{r1}, false, @if_13_end
        or r1, r1
        jp z, @if_13_end
        ; 62:3 if columnCursor == column
        ; equals t.5{r1}, columnCursor{r7}, column{r3}
        not implemented
        ; branch t.5{r1}, true, @if_14_then
        or r1, r1
        jp nz, @if_14_then
        ; 65:3 if columnCursor == column - 1
        ; const t.9{r1}, 1
        ld r1, #%00
        ld r2, #%01
        ; sub t.8{r3}, t.8{r3}, t.9{r1}
        sub r4, r2
        sbc r3, r1
        ; equals t.7{r1}, columnCursor{r7}, t.8{r3}
        not implemented
        ; branch t.7{r1}, false, @if_13_end
        or r1, r1
        jp z, @if_13_end
        jp @if_15_then
@if_14_then:
        ; 63:11 return 91
        ; const t.6{r0}, 91
        ld r0, #%5b
        jp @getSpacer_ret
@if_15_then:
        ; 66:11 return 93
        ; const t.10{r0}, 93
        ld r0, #%5d
        jp @getSpacer_ret
@if_13_end:
        ; 69:9 return 32
        ; const t.11{r0}, 32
        ld r0, #%20
@getSpacer_ret:
        ; restore globbered non-volatile registers
        pop r8
        ret

        ; void printCell
        ;   sp+13: arg cell
        ;   sp+12: arg row
        ;   sp+10: arg column
@printCell:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        ; move cell{r8}, cell{r0}
        ld r8, r0
        ; move row{r9}, row{r1}
        ld r9, r1
        ld r10, r2
        ; move column{r11}, column{r3}
        ld r11, r3
        ld r12, r4
        ; const chr{r13}, 46
        ld r13, #%2e
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; move cell{r1}, cell{r8}
        ld r1, r8
        ; call t.5{r0} = isOpen[cell{r1}] -> bool
        call isOpen
        ; branch t.5{r0}, true, @if_16_then
        or r0, r0
        jp nz, @if_16_then
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; move cell{r1}, cell{r8}
        ld r1, r8
        ; call t.9{r0} = isFlag[cell{r1}] -> bool
        call isFlag
        ; branch t.9{r0}, false, @if_16_end
        or r0, r0
        jp z, @if_16_end
        jp @if_19_then
@if_16_then:
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; move cell{r1}, cell{r8}
        ld r1, r8
        ; call t.6{r0} = isBomb[cell{r1}] -> bool
        call isBomb
        ; branch t.6{r0}, false, @if_17_else
        or r0, r0
        jp z, @if_17_else
        jp @if_17_then
@if_19_then:
        ; const chr{r13}, 35
        ld r13, #%23
        jp @if_16_end
@if_17_else:
        ; move row{r1}, row{r9}
        ld r1, r9
        ld r2, r10
        ; move column{r3}, column{r11}
        ld r3, r11
        ld r4, r12
        ; call count{r0} = getBombCountAround[row{r1}, column{r3}] -> u8
        call getBombCountAround
        ; 80:4 if count > 0
        ; gt t.7{r8}, count{r0}, 0
        cp  r0, #%00
        jr  uge, .32
.32:
        ld  r8, #%ff
        jr  .34
.33:
        ld  r8, #%00
.34:
        ; branch t.7{r8}, false, @if_18_else
        or r8, r8
        jp z, @if_18_else
        jp @if_18_then
@if_17_then:
        ; const chr{r13}, 42
        ld r13, #%2a
        jp @if_16_end
@if_18_else:
        ; const chr{r13}, 32
        ld r13, #%20
        jp @if_16_end
@if_18_then:
        ; const t.8{r8}, 48
        ld r8, #%30
        ; move chr{r13}, count{r0}
        ld r13, r0
        ; add chr{r13}, chr{r13}, t.8{r8}
        add r13, r8
@if_16_end:
        ; move chr{r0}, chr{r13}
        ld r0, r13
        ; call printChar[chr{r0}]
        call printChar
        ; restore globbered non-volatile registers
        pop r14
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printField
        ;   sp+16: arg rowCursor
        ;   sp+14: arg columnCursor
        ;   sp+1: var column
@printField:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        push %30
        ; reserve space for local variables
        decw SPH
        decw SPH
        ; move rowCursor{r9}, rowCursor{r0}
        ld r9, r0
        ld r10, r1
        ; move columnCursor{r11}, columnCursor{r2}
        ld r11, r2
        ld r12, r3
        ; const t.7{r0}, 0
        ld r0, #%00
        ; const t.8{r1}, 0
        ld r1, #%00
        ; call setCursor[t.7{r0}, t.8{r1}]
        call setCursor
        ; const row{r13}, 0
        ld r13, #%00
        ld r14, #%00
        ; 96:2 for row < 20
        jp @for_20
@for_20_body:
        ; const t.10{r0}, 124
        ld r0, #%7c
        ; call printChar[t.10{r0}]
        call printChar
        ; const column{r7}, 0
        ld r7, #%00
        ld r8, #%00
        ; 98:3 for column < 40
        jp @for_21
@for_21_body:
        ; move row{r1}, row{r13}
        ld r1, r13
        ld r2, r14
        ; move column{r3}, column{r7}
        ld r3, r7
        ld r4, r8
        ; move rowCursor{r5}, rowCursor{r9}
        ld r5, r9
        ld r6, r10
        ; move columnCursor{r7}, columnCursor{r11}
        ld r7, r11
        ld r8, r12
        ; move column, column{r7}
        not implemented
        ; call spacer{r0} = getSpacer[row{r1}, column{r3}, rowCursor{r5}, columnCursor{r7}] -> u8
        call getSpacer
        ; call printChar[spacer{r0}]
        call printChar
        ; move row{r1}, row{r13}
        ld r1, r13
        ld r2, r14
        ; move column{r5}, column
        not implemented
        ; move column{r3}, column{r5}
        ld r3, r5
        ld r4, r6
        ; move column, column{r5}
        not implemented
        ; call cell{r0} = getCell[row{r1}, column{r3}] -> u8
        call getCell
        ; move row{r1}, row{r13}
        ld r1, r13
        ld r2, r14
        ; move column{r5}, column
        not implemented
        ; move column{r3}, column{r5}
        ld r3, r5
        ld r4, r6
        ; move column, column{r5}
        not implemented
        ; call printCell[cell{r0}, row{r1}, column{r3}]
        call printCell
        ; move column{r7}, column
        not implemented
        ; inc column{r7}
        add r8, #%01
        adc r7, #%00
@for_21:
        ; lt t.11{r15}, column{r7}, 40
        cp  r7, #%00
        jr  lt, .35
        jr  nz, .36
        cp  r8, #%28
        jr  ult, .35
.35:
        ld  r15, #%ff
        jr  .37
.36:
        ld  r15, #%00
.37:
        ; branch t.11{r15}, true, @for_21_body
        or r15, r15
        jp nz, @for_21_body
        ; const t.12{r3}, 40
        ld r3, #%00
        ld r4, #%28
        ; move row{r1}, row{r13}
        ld r1, r13
        ld r2, r14
        ; move rowCursor{r5}, rowCursor{r9}
        ld r5, r9
        ld r6, r10
        ; move columnCursor{r7}, columnCursor{r11}
        ld r7, r11
        ld r8, r12
        ; call spacer{r0} = getSpacer[row{r1}, t.12{r3}, rowCursor{r5}, columnCursor{r7}] -> u8
        call getSpacer
        ; call printChar[spacer{r0}]
        call printChar
        ; const t.13{r0}, [string-0]
        not implemented
        ; call printString[t.13{r0}]
        call printString
        ; inc row{r13}
        add r14, #%01
        adc r13, #%00
@for_20:
        ; lt t.9{r0}, row{r13}, 20
        cp  r13, #%00
        jr  lt, .38
        jr  nz, .39
        cp  r14, #%14
        jr  ult, .38
.38:
        ld  r0, #%ff
        jr  .40
.39:
        ld  r0, #%00
.40:
        ; branch t.9{r0}, true, @for_20_body
        or r0, r0
        jp nz, @for_20_body
        ; free space for local variables
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop %30
        pop r15
        pop r14
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printSpaces
        ;   sp+5: arg i
@printSpaces:
        ; save globbered non-volatile registers
        push r8
        push r9
        ; move i{r8}, i{r0}
        ld r8, r0
        ld r9, r1
        ; 111:2 for i > 0
        jp @for_22
@for_22_body:
        ; const t.2{r0}, 48
        ld r0, #%30
        ; call printChar[t.2{r0}]
        call printChar
        ; dec i{r8}
        decw r8
@for_22:
        ; gt t.1{r0}, i{r8}, 0
        cp  r8, #%00
        jr  gt, .41
        jr  nz, .42
        cp  r9, #%00
        jr  uge, .41
.41:
        ld  r0, #%ff
        jr  .43
.42:
        ld  r0, #%00
.43:
        ; branch t.1{r0}, true, @for_22_body
        or r0, r0
        jp nz, @for_22_body
        ; restore globbered non-volatile registers
        pop r9
        pop r8
        ret

        ; u8 getDigitCount
        ;   sp+3: arg value
@getDigitCount:
        ; const count{r0}, 0
        ld r0, #%00
        ; 118:2 if value < 0
        ; lt t.2{r3}, value{r1}, 0
        cp  r1, #%00
        jr  lt, .44
        jr  nz, .45
        cp  r2, #%00
        jr  ult, .44
.44:
        ld  r3, #%ff
        jr  .46
.45:
        ld  r3, #%00
.46:
        ; branch t.2{r3}, false, @while_24
        or r3, r3
        jp z, @while_24
        ; const count{r0}, 1
        ld r0, #%01
        ; neg value{r1}, value{r1}
        com r1
        com r2
        add r2, #%01
        adc r1, #%00
@while_24:
        ; inc count{r0}
        inc r0
        ; const t.3{r3}, 10
        ld r3, #%00
        ld r4, #%0a
        ; div value{r1}, value{r1}, t.3{r3}
        not implemented
        ; 126:3 if value == 0
        ; equals t.4{r3}, value{r1}, 0
        cp  r1, #%00
        jr  nz, .47
        cp  r2, #%00
        jr  nz, .47
        cp  r3, #%00
        jr  nz, .47
        cp  r4, #%00
        jr  nz, .47
        cp  r5, #%00
        jr  nz, .47
        cp  r6, #%00
        jr  nz, .47
        cp  r7, #%00
        jr  nz, .47
        cp  r8, #%00
        jr  nz, .47
        cp  r9, #%00
        jr  nz, .47
        cp  r10, #%00
        jr  nz, .47
        cp  r11, #%00
        jr  nz, .47
        cp  r12, #%00
        jr  nz, .47
        cp  r13, #%00
        jr  nz, .47
        cp  r14, #%00
        jr  nz, .47
        cp  r15, #%00
        jr  nz, .47
        cp  %30, #%00
        jr  nz, .47
        ld  r3, #%ff
        jr  .48
.47:
        ld  r3, #%00
.48:
        ; branch t.4{r3}, false, @while_24
        or r3, r3
        jp z, @while_24
        ; 131:9 return count
        ret

        ; i16 getHiddenCount
@getHiddenCount:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; const count{r8}, 0
        ld r8, #%00
        ld r9, #%00
        ; const r{r10}, 0
        ld r10, #%00
        ld r11, #%00
        ; 136:2 for r < 20
        jp @for_26
@for_26_body:
        ; const c{r12}, 0
        ld r12, #%00
        ld r13, #%00
        ; 137:3 for c < 40
        jp @for_27
@for_27_body:
        ; move r{r1}, r{r10}
        ld r1, r10
        ld r2, r11
        ; move c{r3}, c{r12}
        ld r3, r12
        ld r4, r13
        ; call cell{r0} = getCell[r{r1}, c{r3}] -> u8
        call getCell
        ; 139:4 if cell & 6 == 0
        ; const t.8{r2}, 6
        ld r2, #%06
        ; move t.7{r3}, cell{r0}
        ld r3, r0
        ; and t.7{r3}, t.7{r3}, t.8{r2}
        and r3, r2
        ; equals t.6{r2}, t.7{r3}, 0
        cp  r3, #%00
        jr  nz, .49
        cp  r4, #%00
        jr  nz, .49
        cp  r5, #%00
        jr  nz, .49
        cp  r6, #%00
        jr  nz, .49
        cp  r7, #%00
        jr  nz, .49
        cp  r8, #%00
        jr  nz, .49
        cp  r9, #%00
        jr  nz, .49
        cp  r10, #%00
        jr  nz, .49
        cp  r11, #%00
        jr  nz, .49
        cp  r12, #%00
        jr  nz, .49
        cp  r13, #%00
        jr  nz, .49
        cp  r14, #%00
        jr  nz, .49
        cp  r15, #%00
        jr  nz, .49
        cp  %30, #%00
        jr  nz, .49
        cp  %31, #%00
        jr  nz, .49
        cp  %32, #%00
        jr  nz, .49
        ld  r2, #%ff
        jr  .50
.49:
        ld  r2, #%00
.50:
        ; branch t.6{r2}, false, @for_27_continue
        or r2, r2
        jp z, @for_27_continue
        ; inc count{r8}
        incw r8
@for_27_continue:
        ; inc c{r12}
        incw r12
@for_27:
        ; lt t.5{r2}, c{r12}, 40
        cp  r12, #%00
        jr  lt, .51
        jr  nz, .52
        cp  r13, #%28
        jr  ult, .51
.51:
        ld  r2, #%ff
        jr  .53
.52:
        ld  r2, #%00
.53:
        ; branch t.5{r2}, true, @for_27_body
        or r2, r2
        jp nz, @for_27_body
        ; inc r{r10}
        incw r10
@for_26:
        ; lt t.4{r2}, r{r10}, 20
        cp  r10, #%00
        jr  lt, .54
        jr  nz, .55
        cp  r11, #%14
        jr  ult, .54
.54:
        ld  r2, #%ff
        jr  .56
.55:
        ld  r2, #%00
.56:
        ; branch t.4{r2}, true, @for_26_body
        or r2, r2
        jp nz, @for_26_body
        ; 144:9 return count
        ; move count{r0}, count{r8}
        ld r0, r8
        ld r1, r9
        ; restore globbered non-volatile registers
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; bool printLeft
@printLeft:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        ; call count{r0} = getHiddenCount[] -> i16
        call getHiddenCount
        ; move count{r8}, count{r0}
        ld r8, r0
        ld r9, r1
        ; move count{r1}, count{r8}
        ld r1, r8
        ld r2, r9
        ; call t.3{r0} = getDigitCount[count{r1}] -> u8
        call getDigitCount
        ; cast leftDigits{r10}(i16), t.3{r0}(u8)
        not implemented
        ; const t.5{r1}, 40
        ld r1, #%00
        ld r2, #%28
        ; call t.4{r0} = getDigitCount[t.5{r1}] -> u8
        call getDigitCount
        ; cast bombDigits{r12}(i16), t.4{r0}(u8)
        not implemented
        ; const t.6{r0}, [string-1]
        not implemented
        ; call printString[t.6{r0}]
        call printString
        ; move t.7{r0}, bombDigits{r12}
        ld r0, r12
        ld r1, r13
        ; sub t.7{r0}, t.7{r0}, leftDigits{r10}
        sub r1, r11
        sbc r0, r10
        ; call printSpaces[t.7{r0}]
        call printSpaces
        ; move count{r0}, count{r8}
        ld r0, r8
        ld r1, r9
        ; call printUint[count{r0}]
        call printUint
        ; 155:15 return count == 0
        ; equals t.8{r0}, count{r8}, 0
        cp  r8, #%00
        jr  nz, .57
        cp  r9, #%00
        jr  nz, .57
        cp  r10, #%00
        jr  nz, .57
        cp  r11, #%00
        jr  nz, .57
        cp  r12, #%00
        jr  nz, .57
        cp  r13, #%00
        jr  nz, .57
        cp  r14, #%00
        jr  nz, .57
        cp  r15, #%00
        jr  nz, .57
        cp  %30, #%00
        jr  nz, .57
        cp  %31, #%00
        jr  nz, .57
        cp  %32, #%00
        jr  nz, .57
        cp  %33, #%00
        jr  nz, .57
        cp  %34, #%00
        jr  nz, .57
        cp  %35, #%00
        jr  nz, .57
        cp  %36, #%00
        jr  nz, .57
        cp  %37, #%00
        jr  nz, .57
        ld  r0, #%ff
        jr  .58
.57:
        ld  r0, #%00
.58:
        ; restore globbered non-volatile registers
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; i16 abs
        ;   sp+3: arg a
@abs:
        ; 159:2 if a < 0
        ; lt t.1{r4}, a{r2}, 0
        cp  r2, #%00
        jr  lt, .59
        jr  nz, .60
        cp  r3, #%00
        jr  ult, .59
.59:
        ld  r4, #%ff
        jr  .61
.60:
        ld  r4, #%00
.61:
        ; branch t.1{r4}, true, @if_29_then
        or r4, r4
        jp nz, @if_29_then
        ; 162:9 return a
        ; move a{r0}, a{r2}
        ld r0, r2
        ld r1, r3
        jp @abs_ret
@if_29_then:
        ; 160:10 return -a
        ; neg t.2{r0}, a{r2}
        ld r0, #%00
        ld r1, #%00
        sub r1, r3
        sbc r0, r2
@abs_ret:
        ret

        ; void clearField
@clearField:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        ; const r{r8}, 0
        ld r8, #%00
        ld r9, #%00
        ; 166:2 for r < 20
        jp @for_30
@for_30_body:
        ; const c{r10}, 0
        ld r10, #%00
        ld r11, #%00
        ; 167:3 for c < 40
        jp @for_31
@for_31_body:
        ; const t.4{r4}, 0
        ld r4, #%00
        ; move r{r0}, r{r8}
        ld r0, r8
        ld r1, r9
        ; move c{r2}, c{r10}
        ld r2, r10
        ld r3, r11
        ; call setCell[r{r0}, c{r2}, t.4{r4}]
        call setCell
        ; inc c{r10}
        incw r10
@for_31:
        ; lt t.3{r0}, c{r10}, 40
        cp  r10, #%00
        jr  lt, .62
        jr  nz, .63
        cp  r11, #%28
        jr  ult, .62
.62:
        ld  r0, #%ff
        jr  .64
.63:
        ld  r0, #%00
.64:
        ; branch t.3{r0}, true, @for_31_body
        or r0, r0
        jp nz, @for_31_body
        ; inc r{r8}
        incw r8
@for_30:
        ; lt t.2{r0}, r{r8}, 20
        cp  r8, #%00
        jr  lt, .65
        jr  nz, .66
        cp  r9, #%14
        jr  ult, .65
.65:
        ld  r0, #%ff
        jr  .67
.66:
        ld  r0, #%00
.67:
        ; branch t.2{r0}, true, @for_30_body
        or r0, r0
        jp nz, @for_30_body
        ; restore globbered non-volatile registers
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void initField
        ;   sp+15: arg curr_r
        ;   sp+13: arg curr_c
        ;   sp+1: var column
@initField:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; reserve space for local variables
        decw SPH
        decw SPH
        ; move curr_r{r8}, curr_r{r0}
        ld r8, r0
        ld r9, r1
        ; move curr_c{r10}, curr_c{r2}
        ld r10, r2
        ld r11, r3
        ; const bombs{r12}, 40
        ld r12, #%00
        ld r13, #%28
        ; 174:2 for bombs > 0
        jp @for_32
@for_32_body:
        ; call t.7{r0} = random[] -> i32
        call random
        ; const t.8{r4}, 20
        ld r4, #%00
        ld r5, #%00
        ld r6, #%00
        ld r7, #%14
        ; mod t.6{r0}, t.6{r0}, t.8{r4}
        not implemented
        ; cast row{r14}(i16), t.6{r0}(i32)
        not implemented
        ; call t.10{r0} = random[] -> i32
        call random
        ; const t.11{r4}, 40
        ld r4, #%00
        ld r5, #%00
        ld r6, #%00
        ld r7, #%28
        ; mod t.9{r0}, t.9{r0}, t.11{r4}
        not implemented
        ; cast column{r0}(i16), t.9{r0}(i32)
        not implemented
        ; 177:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move t.14{r2}, row{r14}
        ld r2, r14
        ld r3, r15
        ; sub t.14{r2}, t.14{r2}, curr_r{r8}
        sub r3, r9
        sbc r2, r8
        ; move column, column{r0}
        not implemented
        ; call t.13{r0} = abs[t.14{r2}] -> i16
        call abs
        ; gt t.12{r0}, t.13{r0}, 1
        cp  r0, #%00
        jr  gt, .68
        jr  nz, .69
        cp  r1, #%01
        jr  uge, .68
.68:
        ld  r0, #%ff
        jr  .70
.69:
        ld  r0, #%00
.70:
        ; branch t.12{r0}, false, @or_2nd_34
        or r0, r0
        jp z, @or_2nd_34
        ; move t.12{r5}, t.12{r0}
        ld r5, r0
        jp @or_next_34
@or_2nd_34:
        ; move column{r0}, column
        not implemented
        ; move t.16{r2}, column{r0}
        ld r2, r0
        ld r3, r1
        ; sub t.16{r2}, t.16{r2}, curr_c{r10}
        sub r3, r11
        sbc r2, r10
        ; move column, column{r0}
        not implemented
        ; call t.15{r0} = abs[t.16{r2}] -> i16
        call abs
        ; gt t.12{r5}, t.15{r0}, 1
        cp  r0, #%00
        jr  gt, .71
        jr  nz, .72
        cp  r1, #%01
        jr  uge, .71
.71:
        ld  r5, #%ff
        jr  .73
.72:
        ld  r5, #%00
.73:
@or_next_34:
        ; branch t.12{r5}, false, @for_32_continue
        or r5, r5
        jp z, @for_32_continue
        ; const t.17{r4}, 1
        ld r4, #%01
        ; move row{r0}, row{r14}
        ld r0, r14
        ld r1, r15
        ; move column{r2}, column
        not implemented
        ; call setCell[row{r0}, column{r2}, t.17{r4}]
        call setCell
@for_32_continue:
        ; dec bombs{r12}
        decw r12
@for_32:
        ; gt t.5{r0}, bombs{r12}, 0
        cp  r12, #%00
        jr  gt, .74
        jr  nz, .75
        cp  r13, #%00
        jr  uge, .74
.74:
        ld  r0, #%ff
        jr  .76
.75:
        ld  r0, #%00
.76:
        ; branch t.5{r0}, true, @for_32_body
        or r0, r0
        jp nz, @for_32_body
        ; free space for local variables
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop r15
        pop r14
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void maybeRevealAround
        ;   sp+18: arg row
        ;   sp+16: arg column
        ;   sp+4: var dc
        ;   sp+2: var c
        ;   sp+0: var cell
@maybeRevealAround:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        ; reserve space for local variables
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        decw SPH
        ; move row{r8}, row{r0}
        ld r8, r0
        ld r9, r1
        ; move column{r10}, column{r2}
        ld r10, r2
        ld r11, r3
        ; 185:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=185:30]]) != 0
        ; move row{r1}, row{r8}
        ld r1, r8
        ld r2, r9
        ; move column{r3}, column{r10}
        ld r3, r10
        ld r4, r11
        ; call t.8{r0} = getBombCountAround[row{r1}, column{r3}] -> u8
        call getBombCountAround
        ; notequals t.7{r12}, t.8{r0}, 0
        cp  r0, #%00
        jr  nz, .77
        cp  r1, #%00
        jr  nz, .77
        cp  r2, #%00
        jr  nz, .77
        cp  r3, #%00
        jr  nz, .77
        cp  r4, #%00
        jr  nz, .77
        cp  r5, #%00
        jr  nz, .77
        cp  r6, #%00
        jr  nz, .77
        cp  r7, #%00
        jr  nz, .77
        cp  r8, #%00
        jr  nz, .77
        cp  r9, #%00
        jr  nz, .77
        cp  r10, #%00
        jr  nz, .77
        cp  r11, #%00
        jr  nz, .77
        cp  r12, #%00
        jr  nz, .77
        cp  r13, #%00
        jr  nz, .77
        cp  r14, #%00
        jr  nz, .77
        cp  r15, #%00
        jr  nz, .77
        ld  r12, #%00
        jr  .78
.77:
        ld  r12, #%ff
.78:
        ; branch t.7{r12}, true, @maybeRevealAround_ret
        or r12, r12
        jp nz, @maybeRevealAround_ret
        ; const dr{r12}, -1
        ld r12, #%ff
        ld r13, #%ff
        ; 189:2 for dr <= 1
        jp @for_36
@for_36_body:
        ; move r{r14}, row{r8}
        ld r14, r8
        ld r15, r9
        ; add r{r14}, r{r14}, dr{r12}
        add r15, r13
        adc r14, r12
        ; const dc{r5}, -1
        ld r5, #%ff
        ld r6, #%ff
        ; 191:3 for dc <= 1
        ; move dc{r0}, dc{r5}
        ld r0, r5
        ld r1, r6
        jp @for_37
@for_37_body:
        ; move dc{r5}, dc{r0}
        ld r5, r0
        ld r6, r1
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; equals t.11{r0}, dr{r12}, 0
        cp  r12, #%00
        jr  nz, .79
        cp  r13, #%00
        jr  nz, .79
        cp  r14, #%00
        jr  nz, .79
        cp  r15, #%00
        jr  nz, .79
        cp  %30, #%00
        jr  nz, .79
        cp  %31, #%00
        jr  nz, .79
        cp  %32, #%00
        jr  nz, .79
        cp  %33, #%00
        jr  nz, .79
        cp  %34, #%00
        jr  nz, .79
        cp  %35, #%00
        jr  nz, .79
        cp  %36, #%00
        jr  nz, .79
        cp  %37, #%00
        jr  nz, .79
        cp  %38, #%00
        jr  nz, .79
        cp  %39, #%00
        jr  nz, .79
        cp  %3a, #%00
        jr  nz, .79
        cp  %3b, #%00
        jr  nz, .79
        ld  r0, #%ff
        jr  .80
.79:
        ld  r0, #%00
.80:
        ; branch t.11{r0}, false, @and_next_39
        or r0, r0
        jp z, @and_next_39
        ; equals t.11{r0}, dc{r5}, 0
        cp  r5, #%00
        jr  nz, .81
        cp  r6, #%00
        jr  nz, .81
        cp  r7, #%00
        jr  nz, .81
        cp  r8, #%00
        jr  nz, .81
        cp  r9, #%00
        jr  nz, .81
        cp  r10, #%00
        jr  nz, .81
        cp  r11, #%00
        jr  nz, .81
        cp  r12, #%00
        jr  nz, .81
        cp  r13, #%00
        jr  nz, .81
        cp  r14, #%00
        jr  nz, .81
        cp  r15, #%00
        jr  nz, .81
        cp  %30, #%00
        jr  nz, .81
        cp  %31, #%00
        jr  nz, .81
        cp  %32, #%00
        jr  nz, .81
        cp  %33, #%00
        jr  nz, .81
        cp  %34, #%00
        jr  nz, .81
        ld  r0, #%ff
        jr  .82
.81:
        ld  r0, #%00
.82:
@and_next_39:
        ; branch t.11{r0}, true, @if_38_then
        or r0, r0
        jp nz, @if_38_then
        ; move c{r3}, column{r10}
        ld r3, r10
        ld r4, r11
        ; add c{r3}, c{r3}, dc{r5}
        add r4, r6
        adc r3, r5
        ; 197:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; move r{r1}, r{r14}
        ld r1, r14
        ld r2, r15
        ; move c, c{r3}
        not implemented
        ; move dc, dc{r5}
        not implemented
        ; call t.13{r0} = checkCellBounds[r{r1}, c{r3}] -> bool
        call checkCellBounds
        ; notlog t.12{r0}, t.13{r0}
        not implemented
        ; branch t.12{r0}, false, @if_40_end
        or r0, r0
        jp z, @if_40_end
        jp @for_37_continue
@if_38_then:
        ; move dc, dc{r5}
        not implemented
        jp @for_37_continue
@if_40_end:
        ; move r{r1}, r{r14}
        ld r1, r14
        ld r2, r15
        ; move c{r5}, c
        not implemented
        ; move c{r3}, c{r5}
        ld r3, r5
        ld r4, r6
        ; move c, c{r5}
        not implemented
        ; call cell{r0} = getCell[r{r1}, c{r3}] -> u8
        call getCell
        ; 202:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move cell{r1}, cell{r0}
        ld r1, r0
        ; move cell, cell{r0}
        not implemented
        ; call t.14{r0} = isOpen[cell{r1}] -> bool
        call isOpen
        ; branch t.14{r0}, true, @for_37_continue
        or r0, r0
        jp nz, @for_37_continue
        ; const t.16{r5}, 2
        ld r5, #%02
        ; move cell{r6}, cell
        not implemented
        ; move t.15{r4}, cell{r6}
        ld r4, r6
        ; or t.15{r4}, t.15{r4}, t.16{r5}
        or r4, r5
        ; move r{r0}, r{r14}
        ld r0, r14
        ld r1, r15
        ; move c{r5}, c
        not implemented
        ; move c{r2}, c{r5}
        ld r2, r5
        ld r3, r6
        ; move c, c{r5}
        not implemented
        ; call setCell[r{r0}, c{r2}, t.15{r4}]
        call setCell
        ; move r{r0}, r{r14}
        ld r0, r14
        ld r1, r15
        ; move c{r2}, c
        not implemented
        ; call maybeRevealAround[r{r0}, c{r2}]
        call maybeRevealAround
@for_37_continue:
        ; move dc{r0}, dc
        not implemented
        ; inc dc{r0}
        incw r0
@for_37:
        ; lteq t.10{r2}, dc{r0}, 1
        cp  r0, #%00
        jr  le, .83
        jr  nz, .84
        cp  r1, #%01
        jr  ule, .83
.83:
        ld  r2, #%ff
        jr  .85
.84:
        ld  r2, #%00
.85:
        ; branch t.10{r2}, true, @for_37_body
        or r2, r2
        jp nz, @for_37_body
        ; inc dr{r12}
        incw r12
@for_36:
        ; lteq t.9{r0}, dr{r12}, 1
        cp  r12, #%00
        jr  le, .86
        jr  nz, .87
        cp  r13, #%01
        jr  ule, .86
.86:
        ld  r0, #%ff
        jr  .88
.87:
        ld  r0, #%00
.88:
        ; branch t.9{r0}, true, @for_36_body
        or r0, r0
        jp nz, @for_36_body
@maybeRevealAround_ret:
        ; free space for local variables
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        incw SPH
        ; restore globbered non-volatile registers
        pop r15
        pop r14
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void main
@main:
        ; save globbered non-volatile registers
        push r8
        push r9
        push r10
        push r11
        push r12
        push r13
        push r14
        push r15
        push %30
        ; begin initialize global variables
        ; end initialize global variables
        ; const t.6{r0}, 7439742
        ld r0, #%00
        ld r1, #%71
        ld r2, #%85
        ld r3, #%7e
        ; call initRandom[t.6{r0}]
        call initRandom
        ; const needsInitialize{r8}, 1
        ld r8, #%01
        ; call clearField[]
        call clearField
        ; const t.7{r9}, 20
        ld r9, #%14
        ; cast curr_c{r9}(i16), t.7{r9}(u8)
        not implemented
        ; const t.8{r11}, 10
        ld r11, #%0a
        ; cast curr_r{r11}(i16), t.8{r11}(u8)
        not implemented
        ; 218:2 while true
        jp @while_42
@if_43_then:
        ; 221:4 if printLeft([])
        ; call t.10{r0} = printLeft[] -> bool
        call printLeft
        ; branch t.10{r0}, true, @if_44_then
        or r0, r0
        jp nz, @if_44_then
@if_43_end:
        ; call t.12{r0} = getChar[] -> u8
        call getChar
        ; cast chr{r13}(i16), t.12{r0}(u8)
        not implemented
        ; 228:3 if chr == 27
        ; equals t.13{r15}, chr{r13}, 27
        cp  r13, #%00
        jr  nz, .89
        cp  r14, #%00
        jr  nz, .89
        cp  r15, #%00
        jr  nz, .89
        cp  %30, #%00
        jr  nz, .89
        cp  %31, #%00
        jr  nz, .89
        cp  %32, #%00
        jr  nz, .89
        cp  %33, #%00
        jr  nz, .89
        cp  %34, #%00
        jr  nz, .89
        cp  %35, #%00
        jr  nz, .89
        cp  %36, #%00
        jr  nz, .89
        cp  %37, #%00
        jr  nz, .89
        cp  %38, #%00
        jr  nz, .89
        cp  %39, #%00
        jr  nz, .89
        cp  %3a, #%00
        jr  nz, .89
        cp  %3b, #%00
        jr  nz, .89
        cp  %3c, #%1b
        jr  nz, .89
        ld  r15, #%ff
        jr  .90
.89:
        ld  r15, #%00
.90:
        ; branch t.13{r15}, true, @main_ret
        or r15, r15
        jp nz, @main_ret
        ; 233:3 if chr == 57416
        ; equals t.14{r15}, chr{r13}, 57416
        cp  r13, #%00
        jr  nz, .91
        cp  r14, #%00
        jr  nz, .91
        cp  r15, #%00
        jr  nz, .91
        cp  %30, #%00
        jr  nz, .91
        cp  %31, #%00
        jr  nz, .91
        cp  %32, #%00
        jr  nz, .91
        cp  %33, #%00
        jr  nz, .91
        cp  %34, #%00
        jr  nz, .91
        cp  %35, #%00
        jr  nz, .91
        cp  %36, #%00
        jr  nz, .91
        cp  %37, #%00
        jr  nz, .91
        cp  %38, #%00
        jr  nz, .91
        cp  %39, #%00
        jr  nz, .91
        cp  %3a, #%00
        jr  nz, .91
        cp  %3b, #%e0
        jr  nz, .91
        cp  %3c, #%48
        jr  nz, .91
        ld  r15, #%ff
        jr  .92
.91:
        ld  r15, #%00
.92:
        ; branch t.14{r15}, true, @if_46_then
        or r15, r15
        jp nz, @if_46_then
        ; 237:8 if chr == 57424
        ; equals t.20{r15}, chr{r13}, 57424
        cp  r13, #%00
        jr  nz, .93
        cp  r14, #%00
        jr  nz, .93
        cp  r15, #%00
        jr  nz, .93
        cp  %30, #%00
        jr  nz, .93
        cp  %31, #%00
        jr  nz, .93
        cp  %32, #%00
        jr  nz, .93
        cp  %33, #%00
        jr  nz, .93
        cp  %34, #%00
        jr  nz, .93
        cp  %35, #%00
        jr  nz, .93
        cp  %36, #%00
        jr  nz, .93
        cp  %37, #%00
        jr  nz, .93
        cp  %38, #%00
        jr  nz, .93
        cp  %39, #%00
        jr  nz, .93
        cp  %3a, #%00
        jr  nz, .93
        cp  %3b, #%e0
        jr  nz, .93
        cp  %3c, #%50
        jr  nz, .93
        ld  r15, #%ff
        jr  .94
.93:
        ld  r15, #%00
.94:
        ; branch t.20{r15}, false, @if_47_else
        or r15, r15
        jp z, @if_47_else
        jp @if_47_then
@if_46_then:
        ; const t.17{r5}, 20
        ld r5, #%00
        ld r6, #%14
        ; move t.16{r3}, curr_r{r11}
        ld r3, r11
        ld r4, r12
        ; add t.16{r3}, t.16{r3}, t.17{r5}
        add r4, r6
        adc r3, r5
        ; const t.18{r5}, 1
        ld r5, #%00
        ld r6, #%01
        ; sub t.15{r3}, t.15{r3}, t.18{r5}
        sub r4, r6
        sbc r3, r5
        ; const t.19{r5}, 20
        ld r5, #%00
        ld r6, #%14
        ; move curr_r{r11}, t.15{r3}
        ld r11, r3
        ld r12, r4
        ; mod curr_r{r11}, curr_r{r11}, t.19{r5}
        not implemented
        jp @while_42
@if_47_else:
        ; 241:8 if chr == 57419
        ; equals t.24{r15}, chr{r13}, 57419
        cp  r13, #%00
        jr  nz, .95
        cp  r14, #%00
        jr  nz, .95
        cp  r15, #%00
        jr  nz, .95
        cp  %30, #%00
        jr  nz, .95
        cp  %31, #%00
        jr  nz, .95
        cp  %32, #%00
        jr  nz, .95
        cp  %33, #%00
        jr  nz, .95
        cp  %34, #%00
        jr  nz, .95
        cp  %35, #%00
        jr  nz, .95
        cp  %36, #%00
        jr  nz, .95
        cp  %37, #%00
        jr  nz, .95
        cp  %38, #%00
        jr  nz, .95
        cp  %39, #%00
        jr  nz, .95
        cp  %3a, #%00
        jr  nz, .95
        cp  %3b, #%e0
        jr  nz, .95
        cp  %3c, #%4b
        jr  nz, .95
        ld  r15, #%ff
        jr  .96
.95:
        ld  r15, #%00
.96:
        ; branch t.24{r15}, false, @if_48_else
        or r15, r15
        jp z, @if_48_else
        jp @if_48_then
@if_47_then:
        ; const t.22{r5}, 1
        ld r5, #%00
        ld r6, #%01
        ; move t.21{r3}, curr_r{r11}
        ld r3, r11
        ld r4, r12
        ; add t.21{r3}, t.21{r3}, t.22{r5}
        add r4, r6
        adc r3, r5
        ; const t.23{r5}, 20
        ld r5, #%00
        ld r6, #%14
        ; move curr_r{r11}, t.21{r3}
        ld r11, r3
        ld r12, r4
        ; mod curr_r{r11}, curr_r{r11}, t.23{r5}
        not implemented
        jp @while_42
@if_48_else:
        ; 245:8 if chr == 57419
        ; equals t.30{r15}, chr{r13}, 57419
        cp  r13, #%00
        jr  nz, .97
        cp  r14, #%00
        jr  nz, .97
        cp  r15, #%00
        jr  nz, .97
        cp  %30, #%00
        jr  nz, .97
        cp  %31, #%00
        jr  nz, .97
        cp  %32, #%00
        jr  nz, .97
        cp  %33, #%00
        jr  nz, .97
        cp  %34, #%00
        jr  nz, .97
        cp  %35, #%00
        jr  nz, .97
        cp  %36, #%00
        jr  nz, .97
        cp  %37, #%00
        jr  nz, .97
        cp  %38, #%00
        jr  nz, .97
        cp  %39, #%00
        jr  nz, .97
        cp  %3a, #%00
        jr  nz, .97
        cp  %3b, #%e0
        jr  nz, .97
        cp  %3c, #%4b
        jr  nz, .97
        ld  r15, #%ff
        jr  .98
.97:
        ld  r15, #%00
.98:
        ; branch t.30{r15}, false, @if_49_else
        or r15, r15
        jp z, @if_49_else
        jp @if_49_then
@if_48_then:
        ; const t.27{r5}, 40
        ld r5, #%00
        ld r6, #%28
        ; move t.26{r3}, curr_c{r9}
        ld r3, r9
        ld r4, r10
        ; add t.26{r3}, t.26{r3}, t.27{r5}
        add r4, r6
        adc r3, r5
        ; const t.28{r5}, 1
        ld r5, #%00
        ld r6, #%01
        ; sub t.25{r3}, t.25{r3}, t.28{r5}
        sub r4, r6
        sbc r3, r5
        ; const t.29{r5}, 40
        ld r5, #%00
        ld r6, #%28
        ; move curr_c{r9}, t.25{r3}
        ld r9, r3
        ld r10, r4
        ; mod curr_c{r9}, curr_c{r9}, t.29{r5}
        not implemented
        jp @while_42
@if_49_else:
        ; 249:8 if chr == 57421
        ; equals t.36{r15}, chr{r13}, 57421
        cp  r13, #%00
        jr  nz, .99
        cp  r14, #%00
        jr  nz, .99
        cp  r15, #%00
        jr  nz, .99
        cp  %30, #%00
        jr  nz, .99
        cp  %31, #%00
        jr  nz, .99
        cp  %32, #%00
        jr  nz, .99
        cp  %33, #%00
        jr  nz, .99
        cp  %34, #%00
        jr  nz, .99
        cp  %35, #%00
        jr  nz, .99
        cp  %36, #%00
        jr  nz, .99
        cp  %37, #%00
        jr  nz, .99
        cp  %38, #%00
        jr  nz, .99
        cp  %39, #%00
        jr  nz, .99
        cp  %3a, #%00
        jr  nz, .99
        cp  %3b, #%e0
        jr  nz, .99
        cp  %3c, #%4d
        jr  nz, .99
        ld  r15, #%ff
        jr  .100
.99:
        ld  r15, #%00
.100:
        ; branch t.36{r15}, false, @if_50_else
        or r15, r15
        jp z, @if_50_else
        jp @if_50_then
@if_49_then:
        ; const t.33{r5}, 40
        ld r5, #%00
        ld r6, #%28
        ; move t.32{r3}, curr_c{r9}
        ld r3, r9
        ld r4, r10
        ; add t.32{r3}, t.32{r3}, t.33{r5}
        add r4, r6
        adc r3, r5
        ; const t.34{r5}, 1
        ld r5, #%00
        ld r6, #%01
        ; sub t.31{r3}, t.31{r3}, t.34{r5}
        sub r4, r6
        sbc r3, r5
        ; const t.35{r5}, 40
        ld r5, #%00
        ld r6, #%28
        ; move curr_c{r9}, t.31{r3}
        ld r9, r3
        ld r10, r4
        ; mod curr_c{r9}, curr_c{r9}, t.35{r5}
        not implemented
        jp @while_42
@if_50_else:
        ; 253:8 if chr == 32
        ; equals t.40{r15}, chr{r13}, 32
        cp  r13, #%00
        jr  nz, .101
        cp  r14, #%00
        jr  nz, .101
        cp  r15, #%00
        jr  nz, .101
        cp  %30, #%00
        jr  nz, .101
        cp  %31, #%00
        jr  nz, .101
        cp  %32, #%00
        jr  nz, .101
        cp  %33, #%00
        jr  nz, .101
        cp  %34, #%00
        jr  nz, .101
        cp  %35, #%00
        jr  nz, .101
        cp  %36, #%00
        jr  nz, .101
        cp  %37, #%00
        jr  nz, .101
        cp  %38, #%00
        jr  nz, .101
        cp  %39, #%00
        jr  nz, .101
        cp  %3a, #%00
        jr  nz, .101
        cp  %3b, #%00
        jr  nz, .101
        cp  %3c, #%20
        jr  nz, .101
        ld  r15, #%ff
        jr  .102
.101:
        ld  r15, #%00
.102:
        ; branch t.40{r15}, false, @if_51_else
        or r15, r15
        jp z, @if_51_else
        jp @if_51_then
@if_50_then:
        ; const t.38{r5}, 1
        ld r5, #%00
        ld r6, #%01
        ; move t.37{r3}, curr_c{r9}
        ld r3, r9
        ld r4, r10
        ; add t.37{r3}, t.37{r3}, t.38{r5}
        add r4, r6
        adc r3, r5
        ; const t.39{r5}, 40
        ld r5, #%00
        ld r6, #%28
        ; move curr_c{r9}, t.37{r3}
        ld r9, r3
        ld r10, r4
        ; mod curr_c{r9}, curr_c{r9}, t.39{r5}
        not implemented
        jp @while_42
@if_51_else:
        ; 262:8 if chr == 13
        ; equals t.45{r13}, chr{r13}, 13
        cp  r13, #%00
        jr  nz, .103
        cp  r14, #%00
        jr  nz, .103
        cp  r15, #%00
        jr  nz, .103
        cp  %30, #%00
        jr  nz, .103
        cp  %31, #%00
        jr  nz, .103
        cp  %32, #%00
        jr  nz, .103
        cp  %33, #%00
        jr  nz, .103
        cp  %34, #%00
        jr  nz, .103
        cp  %35, #%00
        jr  nz, .103
        cp  %36, #%00
        jr  nz, .103
        cp  %37, #%00
        jr  nz, .103
        cp  %38, #%00
        jr  nz, .103
        cp  %39, #%00
        jr  nz, .103
        cp  %3a, #%00
        jr  nz, .103
        cp  %3b, #%00
        jr  nz, .103
        cp  %3c, #%0d
        jr  nz, .103
        ld  r13, #%ff
        jr  .104
.103:
        ld  r13, #%00
.104:
        ; branch t.45{r13}, false, @while_42
        or r13, r13
        jp z, @while_42
        jp @if_54_then
@if_51_then:
        ; 254:4 if !needsInitialize
        ; notlog t.41{r13}, needsInitialize{r8}
        not implemented
        ; branch t.41{r13}, false, @while_42
        or r13, r13
        jp z, @while_42
        jp @if_52_then
@if_54_then:
        ; branch needsInitialize{r8}, false, @if_55_end
        or r8, r8
        jp z, @if_55_end
        jp @if_55_then
@if_52_then:
        ; move curr_r{r1}, curr_r{r11}
        ld r1, r11
        ld r2, r12
        ; move curr_c{r3}, curr_c{r9}
        ld r3, r9
        ld r4, r10
        ; call cell{r0} = getCell[curr_r{r1}, curr_c{r3}] -> u8
        call getCell
        ; move cell{r13}, cell{r0}
        ld r13, r0
        ; 256:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move cell{r1}, cell{r13}
        ld r1, r13
        ; call t.43{r0} = isOpen[cell{r1}] -> bool
        call isOpen
        ; notlog t.42{r14}, t.43{r0}
        not implemented
        ; branch t.42{r14}, false, @while_42
        or r14, r14
        jp z, @while_42
        jp @if_53_then
@if_55_then:
        ; const needsInitialize{r8}, 0
        ld r8, #%00
        ; move curr_r{r0}, curr_r{r11}
        ld r0, r11
        ld r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld r2, r9
        ld r3, r10
        ; call initField[curr_r{r0}, curr_c{r2}]
        call initField
        jp @if_55_end
@if_53_then:
        ; const t.44{r14}, 4
        ld r14, #%04
        ; xor cell{r13}, cell{r13}, t.44{r14}
        xor r13, r14
        ; move curr_r{r0}, curr_r{r11}
        ld r0, r11
        ld r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld r2, r9
        ld r3, r10
        ; move cell{r4}, cell{r13}
        ld r4, r13
        ; call setCell[curr_r{r0}, curr_c{r2}, cell{r4}]
        call setCell
        jp @while_42
@if_55_end:
        ; move curr_r{r1}, curr_r{r11}
        ld r1, r11
        ld r2, r12
        ; move curr_c{r3}, curr_c{r9}
        ld r3, r9
        ld r4, r10
        ; call cell{r0} = getCell[curr_r{r1}, curr_c{r3}] -> u8
        call getCell
        ; move cell{r13}, cell{r0}
        ld r13, r0
        ; 268:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move cell{r1}, cell{r13}
        ld r1, r13
        ; call t.47{r0} = isOpen[cell{r1}] -> bool
        call isOpen
        ; notlog t.46{r14}, t.47{r0}
        not implemented
        ; branch t.46{r14}, false, @if_56_end
        or r14, r14
        jp z, @if_56_end
        ; const t.49{r14}, 2
        ld r14, #%02
        ; move t.48{r4}, cell{r13}
        ld r4, r13
        ; or t.48{r4}, t.48{r4}, t.49{r14}
        or r4, r14
        ; move curr_r{r0}, curr_r{r11}
        ld r0, r11
        ld r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld r2, r9
        ld r3, r10
        ; call setCell[curr_r{r0}, curr_c{r2}, t.48{r4}]
        call setCell
@if_56_end:
        ; 271:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; move cell{r1}, cell{r13}
        ld r1, r13
        ; call t.50{r0} = isBomb[cell{r1}] -> bool
        call isBomb
        ; branch t.50{r0}, true, @if_57_then
        or r0, r0
        jp nz, @if_57_then
        ; move curr_r{r0}, curr_r{r11}
        ld r0, r11
        ld r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld r2, r9
        ld r3, r10
        ; call maybeRevealAround[curr_r{r0}, curr_c{r2}]
        call maybeRevealAround
@while_42:
        ; move curr_r{r0}, curr_r{r11}
        ld r0, r11
        ld r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld r2, r9
        ld r3, r10
        ; call printField[curr_r{r0}, curr_c{r2}]
        call printField
        ; 220:3 if !needsInitialize
        ; notlog t.9{r13}, needsInitialize{r8}
        not implemented
        ; branch t.9{r13}, false, @if_43_end
        or r13, r13
        jp z, @if_43_end
        jp @if_43_then
@if_44_then:
        ; const t.11{r0}, [string-2]
        not implemented
        ; call printString[t.11{r0}]
        call printString
        jp @main_ret
@if_57_then:
        ; move curr_r{r0}, curr_r{r11}
        ld r0, r11
        ld r1, r12
        ; move curr_c{r2}, curr_c{r9}
        ld r2, r9
        ld r3, r10
        ; call printField[curr_r{r0}, curr_c{r2}]
        call printField
        ; const t.51{r0}, [string-3]
        not implemented
        ; call printString[t.51{r0}]
        call printString
@main_ret:
        ; restore globbered non-volatile registers
        pop %30
        pop r15
        pop r14
        pop r13
        pop r12
        pop r11
        pop r10
        pop r9
        pop r8
        ret

        ; void printChar
@printChar:
        ld   r0, SPH
        ld   r1, SPL
        add  r1, 3
        adc  r0, 0
        ldc  r1, @rr0
        ld   %15, r1
        jp   %0818

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: field[] (u8*/1600)
        var_0 rb 1600

section '.data' data readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

