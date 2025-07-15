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
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; 2:2 while true
        jp @while_1
@if_2_end:
        ; move r0, r10
        ld r0, r10
        ; call printChar[r0]
        call printChar
@while_1:
        ; load r10, [r8]
        lde r10, rr8
        ; 4:3 if chr == 0
        ; equals r0, r10, 0
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
        ; branch r0, false, @if_2_end
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
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; move r10, r2
        ld r10, r2
        ; 13:2 while length > 0
        jp @while_3
@while_3_body:
        ; load r0, [r8]
        lde r0, rr8
        ; call printChar[r0]
        call printChar
        ; dec r10
        dec r10
@while_3:
        ; gt r0, r10, 0
        cp  r10, #%00
        jr  uge, .3
.3:
        ld  r0, #%ff
        jr  .5
.4:
        ld  r0, #%00
.5:
        ; branch r0, true, @while_3_body
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
        ; const r8, 20
        ld r8, #%14
        ; 24:2 while true
@while_4:
        ; dec r8
        dec r8
        ; const r9, 10
        ld r9, #%00
        ld r10, #%0a
        ; move r11, r0
        ld r11, r0
        ld r12, r1
        ; mod r11, r11, r9
        not implemented
        ; cast remainder(i64), r11(i16)
        not implemented
        ; const r9, 10
        ld r9, #%00
        ld r10, #%0a
        ; div r0, r0, r9
        not implemented
        ; cast r9(u8), remainder(i64)
        not implemented
        ; const r10, 48
        ld r10, #%30
        ; add r9, r9, r10
        add r9, r10
        ; cast r10(i16), r8(u8)
        not implemented
        ; cast r10(u8*), r10(i16)
        not implemented
        ; addrof r12, [buffer]
        not implemented
        ; add r12, r12, r10
        add r13, r11
        adc r12, r10
        ; store [r12], r9
        lde rr12, r9
        ; 30:3 if number == 0
        ; equals r9, r0, 0
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
        ; branch r9, false, @while_4
        or r9, r9
        jp z, @while_4
        ; cast r9(i16), r8(u8)
        not implemented
        ; cast r10(u8*), r9(i16)
        not implemented
        ; addrof r0, [buffer]
        not implemented
        ; add r0, r0, r10
        add r1, r11
        adc r0, r10
        ; const r9, 20
        ld r9, #%14
        ; move r2, r9
        ld r2, r9
        ; sub r2, r2, r8
        sub r2, r8
        ; call printStringLength[r0, r2]
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
        ; const r0, 0
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
        ; const r0, 0
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
        ; const r6, 40
        ld r6, #%00
        ld r7, #%28
        ; mul r2, r2, r6
        not implemented
        ; move r0, r2
        ld r0, r2
        ld r1, r3
        ; add r0, r0, r4
        add r1, r5
        adc r0, r4
        ret

        ; u8 getCell
        ;   sp+5: arg row
        ;   sp+3: arg column
@getCell:
        ; move r4, r3
        ld r4, r3
        ld r5, r4
        ; 19:15 return [...]
        ; move r2, r1
        ld r2, r1
        ld r3, r2
        ; call r0 = rowColumnToCell[r2, r4] -> i16
        call rowColumnToCell
        ; cast r2(u8*), r0(i16)
        not implemented
        ; addrof r4, [field]
        not implemented
        ; add r4, r4, r2
        add r5, r3
        adc r4, r2
        ; load r0, [r4]
        lde r0, rr4
        ret

        ; bool isBomb
        ;   sp+2: arg cell
@isBomb:
        ; 23:27 return cell & 1 != 0
        ; const r2, 1
        ld r2, #%01
        ; and r1, r1, r2
        and r1, r2
        ; notequals r0, r1, 0
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
        ; const r2, 2
        ld r2, #%02
        ; and r1, r1, r2
        and r1, r2
        ; notequals r0, r1, 0
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
        ; const r2, 4
        ld r2, #%04
        ; and r1, r1, r2
        and r1, r2
        ; notequals r0, r1, 0
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
        ; gteq r0, r1, 0
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
        ; branch r0, false, @and_next_8
        or r0, r0
        jp z, @and_next_8
        ; lt r0, r1, 20
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
        ; branch r0, false, @and_next_7
        or r0, r0
        jp z, @and_next_7
        ; gteq r0, r3, 0
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
        ; branch r0, false, @checkCellBounds_ret
        or r0, r0
        jp z, @checkCellBounds_ret
        ; lt r0, r3, 40
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
        ; move r5, r2
        ld r5, r2
        ld r6, r3
        ; move r8, r4
        ld r8, r4
        ; move r2, r0
        ld r2, r0
        ld r3, r1
        ; move r4, r5
        ld r4, r5
        ld r5, r6
        ; call r0 = rowColumnToCell[r2, r4] -> i16
        call rowColumnToCell
        ; cast r0(u8*), r0(i16)
        not implemented
        ; addrof r2, [field]
        not implemented
        ; add r2, r2, r0
        add r3, r1
        adc r2, r0
        ; store [r2], r8
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
        ; move r8, r1
        ld r8, r1
        ld r9, r2
        ; move r10, r3
        ld r10, r3
        ld r11, r4
        ; const r12, 0
        ld r12, #%00
        ; const r13, -1
        ld r13, #%ff
        ld r14, #%ff
        ; 45:2 for dr <= 1
        jp @for_9
@for_9_body:
        ; move r5, r8
        ld r5, r8
        ld r6, r9
        ; add r5, r5, r13
        add r6, r14
        adc r5, r13
        ; const r3, -1
        ld r3, #%ff
        ld r4, #%ff
        ; 47:3 for dc <= 1
        ; move r, r5
        not implemented
        ; move r1, r3
        ld r1, r3
        ld r2, r4
        jp @for_10
@for_10_body:
        ; move r3, r1
        ld r3, r1
        ld r4, r2
        ; move r5, r
        not implemented
        ; move r0, r10
        ld r0, r10
        ld r1, r11
        ; add r0, r0, r3
        add r1, r4
        adc r0, r3
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; move r1, r5
        ld r1, r5
        ld r2, r6
        ; move c, r0
        not implemented
        ; move r3, c
        not implemented
        ; move dc, r3
        not implemented
        ; move r, r5
        not implemented
        ; call r0 = checkCellBounds[r1, r3] -> bool
        call checkCellBounds
        ; branch r0, false, @for_10_continue
        or r0, r0
        jp z, @for_10_continue
        ; move r5, r
        not implemented
        ; move r1, r5
        ld r1, r5
        ld r2, r6
        ; move r3, c
        not implemented
        ; move r, r5
        not implemented
        ; call r0 = getCell[r1, r3] -> u8
        call getCell
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; move r1, r0
        ld r1, r0
        ; call r0 = isBomb[r1] -> bool
        call isBomb
        ; branch r0, false, @for_10_continue
        or r0, r0
        jp z, @for_10_continue
        ; inc r12
        inc r12
@for_10_continue:
        ; move r1, dc
        not implemented
        ; inc r1
        add r2, #%01
        adc r1, #%00
@for_10:
        ; lteq r3, r1, 1
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
        ; branch r3, true, @for_10_body
        or r3, r3
        jp nz, @for_10_body
        ; inc r13
        add r14, #%01
        adc r13, #%00
@for_9:
        ; lteq r1, r13, 1
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
        ; branch r1, true, @for_9_body
        or r1, r1
        jp nz, @for_9_body
        ; 57:9 return count
        ; move r0, r12
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
        ; equals r1, r5, r1
        not implemented
        ; branch r1, false, @if_13_end
        or r1, r1
        jp z, @if_13_end
        ; 62:3 if columnCursor == column
        ; equals r1, r7, r3
        not implemented
        ; branch r1, true, @if_14_then
        or r1, r1
        jp nz, @if_14_then
        ; 65:3 if columnCursor == column - 1
        ; const r1, 1
        ld r1, #%00
        ld r2, #%01
        ; sub r3, r3, r1
        sub r4, r2
        sbc r3, r1
        ; equals r1, r7, r3
        not implemented
        ; branch r1, false, @if_13_end
        or r1, r1
        jp z, @if_13_end
        jp @if_15_then
@if_14_then:
        ; 63:11 return 91
        ; const r0, 91
        ld r0, #%5b
        jp @getSpacer_ret
@if_15_then:
        ; 66:11 return 93
        ; const r0, 93
        ld r0, #%5d
        jp @getSpacer_ret
@if_13_end:
        ; 69:9 return 32
        ; const r0, 32
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
        ; move r8, r0
        ld r8, r0
        ; move r9, r1
        ld r9, r1
        ld r10, r2
        ; move r11, r3
        ld r11, r3
        ld r12, r4
        ; const r13, 46
        ld r13, #%2e
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; move r1, r8
        ld r1, r8
        ; call r0 = isOpen[r1] -> bool
        call isOpen
        ; branch r0, true, @if_16_then
        or r0, r0
        jp nz, @if_16_then
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; move r1, r8
        ld r1, r8
        ; call r0 = isFlag[r1] -> bool
        call isFlag
        ; branch r0, false, @if_16_end
        or r0, r0
        jp z, @if_16_end
        jp @if_19_then
@if_16_then:
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; move r1, r8
        ld r1, r8
        ; call r0 = isBomb[r1] -> bool
        call isBomb
        ; branch r0, false, @if_17_else
        or r0, r0
        jp z, @if_17_else
        jp @if_17_then
@if_19_then:
        ; const r13, 35
        ld r13, #%23
        jp @if_16_end
@if_17_else:
        ; move r1, r9
        ld r1, r9
        ld r2, r10
        ; move r3, r11
        ld r3, r11
        ld r4, r12
        ; call r0 = getBombCountAround[r1, r3] -> u8
        call getBombCountAround
        ; 80:4 if count > 0
        ; gt r8, r0, 0
        cp  r0, #%00
        jr  uge, .32
.32:
        ld  r8, #%ff
        jr  .34
.33:
        ld  r8, #%00
.34:
        ; branch r8, false, @if_18_else
        or r8, r8
        jp z, @if_18_else
        jp @if_18_then
@if_17_then:
        ; const r13, 42
        ld r13, #%2a
        jp @if_16_end
@if_18_else:
        ; const r13, 32
        ld r13, #%20
        jp @if_16_end
@if_18_then:
        ; const r8, 48
        ld r8, #%30
        ; move r13, r0
        ld r13, r0
        ; add r13, r13, r8
        add r13, r8
@if_16_end:
        ; move r0, r13
        ld r0, r13
        ; call printChar[r0]
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
        ; move r9, r0
        ld r9, r0
        ld r10, r1
        ; move r11, r2
        ld r11, r2
        ld r12, r3
        ; const r0, 0
        ld r0, #%00
        ; const r1, 0
        ld r1, #%00
        ; call setCursor[r0, r1]
        call setCursor
        ; const r13, 0
        ld r13, #%00
        ld r14, #%00
        ; 96:2 for row < 20
        jp @for_20
@for_20_body:
        ; const r0, 124
        ld r0, #%7c
        ; call printChar[r0]
        call printChar
        ; const r7, 0
        ld r7, #%00
        ld r8, #%00
        ; 98:3 for column < 40
        jp @for_21
@for_21_body:
        ; move r1, r13
        ld r1, r13
        ld r2, r14
        ; move r3, r7
        ld r3, r7
        ld r4, r8
        ; move r5, r9
        ld r5, r9
        ld r6, r10
        ; move r7, r11
        ld r7, r11
        ld r8, r12
        ; move column, r7
        not implemented
        ; call r0 = getSpacer[r1, r3, r5, r7] -> u8
        call getSpacer
        ; call printChar[r0]
        call printChar
        ; move r1, r13
        ld r1, r13
        ld r2, r14
        ; move r5, column
        not implemented
        ; move r3, r5
        ld r3, r5
        ld r4, r6
        ; move column, r5
        not implemented
        ; call r0 = getCell[r1, r3] -> u8
        call getCell
        ; move r1, r13
        ld r1, r13
        ld r2, r14
        ; move r5, column
        not implemented
        ; move r3, r5
        ld r3, r5
        ld r4, r6
        ; move column, r5
        not implemented
        ; call printCell[r0, r1, r3]
        call printCell
        ; move r7, column
        not implemented
        ; inc r7
        add r8, #%01
        adc r7, #%00
@for_21:
        ; lt r15, r7, 40
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
        ; branch r15, true, @for_21_body
        or r15, r15
        jp nz, @for_21_body
        ; const r3, 40
        ld r3, #%00
        ld r4, #%28
        ; move r1, r13
        ld r1, r13
        ld r2, r14
        ; move r5, r9
        ld r5, r9
        ld r6, r10
        ; move r7, r11
        ld r7, r11
        ld r8, r12
        ; call r0 = getSpacer[r1, r3, r5, r7] -> u8
        call getSpacer
        ; call printChar[r0]
        call printChar
        ; const r0, [string-0]
        not implemented
        ; call printString[r0]
        call printString
        ; inc r13
        add r14, #%01
        adc r13, #%00
@for_20:
        ; lt r0, r13, 20
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
        ; branch r0, true, @for_20_body
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
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; 111:2 for i > 0
        jp @for_22
@for_22_body:
        ; const r0, 48
        ld r0, #%30
        ; call printChar[r0]
        call printChar
        ; dec r8
        decw r8
@for_22:
        ; gt r0, r8, 0
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
        ; branch r0, true, @for_22_body
        or r0, r0
        jp nz, @for_22_body
        ; restore globbered non-volatile registers
        pop r9
        pop r8
        ret

        ; u8 getDigitCount
        ;   sp+3: arg value
@getDigitCount:
        ; const r0, 0
        ld r0, #%00
        ; 118:2 if value < 0
        ; lt r3, r1, 0
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
        ; branch r3, false, @while_24
        or r3, r3
        jp z, @while_24
        ; const r0, 1
        ld r0, #%01
        ; neg r1, r1
        com r1
        com r2
        add r2, #%01
        adc r1, #%00
@while_24:
        ; inc r0
        inc r0
        ; const r3, 10
        ld r3, #%00
        ld r4, #%0a
        ; div r1, r1, r3
        not implemented
        ; 126:3 if value == 0
        ; equals r3, r1, 0
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
        ; branch r3, false, @while_24
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
        ; const r8, 0
        ld r8, #%00
        ld r9, #%00
        ; const r10, 0
        ld r10, #%00
        ld r11, #%00
        ; 136:2 for r < 20
        jp @for_26
@for_26_body:
        ; const r12, 0
        ld r12, #%00
        ld r13, #%00
        ; 137:3 for c < 40
        jp @for_27
@for_27_body:
        ; move r1, r10
        ld r1, r10
        ld r2, r11
        ; move r3, r12
        ld r3, r12
        ld r4, r13
        ; call r0 = getCell[r1, r3] -> u8
        call getCell
        ; 139:4 if cell & 6 == 0
        ; const r2, 6
        ld r2, #%06
        ; move r3, r0
        ld r3, r0
        ; and r3, r3, r2
        and r3, r2
        ; equals r2, r3, 0
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
        ; branch r2, false, @for_27_continue
        or r2, r2
        jp z, @for_27_continue
        ; inc r8
        incw r8
@for_27_continue:
        ; inc r12
        incw r12
@for_27:
        ; lt r2, r12, 40
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
        ; branch r2, true, @for_27_body
        or r2, r2
        jp nz, @for_27_body
        ; inc r10
        incw r10
@for_26:
        ; lt r2, r10, 20
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
        ; branch r2, true, @for_26_body
        or r2, r2
        jp nz, @for_26_body
        ; 144:9 return count
        ; move r0, r8
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
        ; call r0 = getHiddenCount[] -> i16
        call getHiddenCount
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; move r1, r8
        ld r1, r8
        ld r2, r9
        ; call r0 = getDigitCount[r1] -> u8
        call getDigitCount
        ; cast r10(i16), r0(u8)
        not implemented
        ; const r1, 40
        ld r1, #%00
        ld r2, #%28
        ; call r0 = getDigitCount[r1] -> u8
        call getDigitCount
        ; cast r12(i16), r0(u8)
        not implemented
        ; const r0, [string-1]
        not implemented
        ; call printString[r0]
        call printString
        ; move r0, r12
        ld r0, r12
        ld r1, r13
        ; sub r0, r0, r10
        sub r1, r11
        sbc r0, r10
        ; call printSpaces[r0]
        call printSpaces
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; call printUint[r0]
        call printUint
        ; 155:15 return count == 0
        ; equals r0, r8, 0
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
        ; lt r4, r2, 0
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
        ; branch r4, true, @if_29_then
        or r4, r4
        jp nz, @if_29_then
        ; 162:9 return a
        ; move r0, r2
        ld r0, r2
        ld r1, r3
        jp @abs_ret
@if_29_then:
        ; 160:10 return -a
        ; neg r0, r2
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
        ; const r8, 0
        ld r8, #%00
        ld r9, #%00
        ; 166:2 for r < 20
        jp @for_30
@for_30_body:
        ; const r10, 0
        ld r10, #%00
        ld r11, #%00
        ; 167:3 for c < 40
        jp @for_31
@for_31_body:
        ; const r4, 0
        ld r4, #%00
        ; move r0, r8
        ld r0, r8
        ld r1, r9
        ; move r2, r10
        ld r2, r10
        ld r3, r11
        ; call setCell[r0, r2, r4]
        call setCell
        ; inc r10
        incw r10
@for_31:
        ; lt r0, r10, 40
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
        ; branch r0, true, @for_31_body
        or r0, r0
        jp nz, @for_31_body
        ; inc r8
        incw r8
@for_30:
        ; lt r0, r8, 20
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
        ; branch r0, true, @for_30_body
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
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; move r10, r2
        ld r10, r2
        ld r11, r3
        ; const r12, 40
        ld r12, #%00
        ld r13, #%28
        ; 174:2 for bombs > 0
        jp @for_32
@for_32_body:
        ; call r0 = random[] -> i32
        call random
        ; const r4, 20
        ld r4, #%00
        ld r5, #%00
        ld r6, #%00
        ld r7, #%14
        ; mod r0, r0, r4
        not implemented
        ; cast r14(i16), r0(i32)
        not implemented
        ; call r0 = random[] -> i32
        call random
        ; const r4, 40
        ld r4, #%00
        ld r5, #%00
        ld r6, #%00
        ld r7, #%28
        ; mod r0, r0, r4
        not implemented
        ; cast r0(i16), r0(i32)
        not implemented
        ; 177:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move r2, r14
        ld r2, r14
        ld r3, r15
        ; sub r2, r2, r8
        sub r3, r9
        sbc r2, r8
        ; move column, r0
        not implemented
        ; call r0 = abs[r2] -> i16
        call abs
        ; gt r0, r0, 1
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
        ; branch r0, false, @or_2nd_34
        or r0, r0
        jp z, @or_2nd_34
        ; move r5, r0
        ld r5, r0
        jp @or_next_34
@or_2nd_34:
        ; move r0, column
        not implemented
        ; move r2, r0
        ld r2, r0
        ld r3, r1
        ; sub r2, r2, r10
        sub r3, r11
        sbc r2, r10
        ; move column, r0
        not implemented
        ; call r0 = abs[r2] -> i16
        call abs
        ; gt r5, r0, 1
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
        ; branch r5, false, @for_32_continue
        or r5, r5
        jp z, @for_32_continue
        ; const r4, 1
        ld r4, #%01
        ; move r0, r14
        ld r0, r14
        ld r1, r15
        ; move r2, column
        not implemented
        ; call setCell[r0, r2, r4]
        call setCell
@for_32_continue:
        ; dec r12
        decw r12
@for_32:
        ; gt r0, r12, 0
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
        ; branch r0, true, @for_32_body
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
        ; move r8, r0
        ld r8, r0
        ld r9, r1
        ; move r10, r2
        ld r10, r2
        ld r11, r3
        ; 185:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=185:30]]) != 0
        ; move r1, r8
        ld r1, r8
        ld r2, r9
        ; move r3, r10
        ld r3, r10
        ld r4, r11
        ; call r0 = getBombCountAround[r1, r3] -> u8
        call getBombCountAround
        ; notequals r12, r0, 0
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
        ; branch r12, true, @maybeRevealAround_ret
        or r12, r12
        jp nz, @maybeRevealAround_ret
        ; const r12, -1
        ld r12, #%ff
        ld r13, #%ff
        ; 189:2 for dr <= 1
        jp @for_36
@for_36_body:
        ; move r14, r8
        ld r14, r8
        ld r15, r9
        ; add r14, r14, r12
        add r15, r13
        adc r14, r12
        ; const r5, -1
        ld r5, #%ff
        ld r6, #%ff
        ; 191:3 for dc <= 1
        ; move r0, r5
        ld r0, r5
        ld r1, r6
        jp @for_37
@for_37_body:
        ; move r5, r0
        ld r5, r0
        ld r6, r1
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; equals r0, r12, 0
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
        ; branch r0, false, @and_next_39
        or r0, r0
        jp z, @and_next_39
        ; equals r0, r5, 0
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
        ; branch r0, true, @if_38_then
        or r0, r0
        jp nz, @if_38_then
        ; move r3, r10
        ld r3, r10
        ld r4, r11
        ; add r3, r3, r5
        add r4, r6
        adc r3, r5
        ; 197:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; move r1, r14
        ld r1, r14
        ld r2, r15
        ; move c, r3
        not implemented
        ; move dc, r5
        not implemented
        ; call r0 = checkCellBounds[r1, r3] -> bool
        call checkCellBounds
        ; notlog r0, r0
        not implemented
        ; branch r0, false, @if_40_end
        or r0, r0
        jp z, @if_40_end
        jp @for_37_continue
@if_38_then:
        ; move dc, r5
        not implemented
        jp @for_37_continue
@if_40_end:
        ; move r1, r14
        ld r1, r14
        ld r2, r15
        ; move r5, c
        not implemented
        ; move r3, r5
        ld r3, r5
        ld r4, r6
        ; move c, r5
        not implemented
        ; call r0 = getCell[r1, r3] -> u8
        call getCell
        ; 202:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move r1, r0
        ld r1, r0
        ; move cell, r0
        not implemented
        ; call r0 = isOpen[r1] -> bool
        call isOpen
        ; branch r0, true, @for_37_continue
        or r0, r0
        jp nz, @for_37_continue
        ; const r5, 2
        ld r5, #%02
        ; move r6, cell
        not implemented
        ; move r4, r6
        ld r4, r6
        ; or r4, r4, r5
        or r4, r5
        ; move r0, r14
        ld r0, r14
        ld r1, r15
        ; move r5, c
        not implemented
        ; move r2, r5
        ld r2, r5
        ld r3, r6
        ; move c, r5
        not implemented
        ; call setCell[r0, r2, r4]
        call setCell
        ; move r0, r14
        ld r0, r14
        ld r1, r15
        ; move r2, c
        not implemented
        ; call maybeRevealAround[r0, r2]
        call maybeRevealAround
@for_37_continue:
        ; move r0, dc
        not implemented
        ; inc r0
        incw r0
@for_37:
        ; lteq r2, r0, 1
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
        ; branch r2, true, @for_37_body
        or r2, r2
        jp nz, @for_37_body
        ; inc r12
        incw r12
@for_36:
        ; lteq r0, r12, 1
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
        ; branch r0, true, @for_36_body
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
        ; const r0, 7439742
        ld r0, #%00
        ld r1, #%71
        ld r2, #%85
        ld r3, #%7e
        ; call initRandom[r0]
        call initRandom
        ; const r8, 1
        ld r8, #%01
        ; call clearField[]
        call clearField
        ; const r9, 20
        ld r9, #%14
        ; cast r9(i16), r9(u8)
        not implemented
        ; const r11, 10
        ld r11, #%0a
        ; cast r11(i16), r11(u8)
        not implemented
        ; 218:2 while true
        jp @while_42
@if_43_then:
        ; 221:4 if printLeft([])
        ; call r0 = printLeft[] -> bool
        call printLeft
        ; branch r0, true, @if_44_then
        or r0, r0
        jp nz, @if_44_then
@if_43_end:
        ; call r0 = getChar[] -> u8
        call getChar
        ; cast r13(i16), r0(u8)
        not implemented
        ; 228:3 if chr == 27
        ; equals r15, r13, 27
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
        ; branch r15, true, @main_ret
        or r15, r15
        jp nz, @main_ret
        ; 233:3 if chr == 57416
        ; equals r15, r13, 57416
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
        ; branch r15, true, @if_46_then
        or r15, r15
        jp nz, @if_46_then
        ; 237:8 if chr == 57424
        ; equals r15, r13, 57424
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
        ; branch r15, false, @if_47_else
        or r15, r15
        jp z, @if_47_else
        jp @if_47_then
@if_46_then:
        ; const r5, 20
        ld r5, #%00
        ld r6, #%14
        ; move r3, r11
        ld r3, r11
        ld r4, r12
        ; add r3, r3, r5
        add r4, r6
        adc r3, r5
        ; const r5, 1
        ld r5, #%00
        ld r6, #%01
        ; sub r3, r3, r5
        sub r4, r6
        sbc r3, r5
        ; const r5, 20
        ld r5, #%00
        ld r6, #%14
        ; move r11, r3
        ld r11, r3
        ld r12, r4
        ; mod r11, r11, r5
        not implemented
        jp @while_42
@if_47_else:
        ; 241:8 if chr == 57419
        ; equals r15, r13, 57419
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
        ; branch r15, false, @if_48_else
        or r15, r15
        jp z, @if_48_else
        jp @if_48_then
@if_47_then:
        ; const r5, 1
        ld r5, #%00
        ld r6, #%01
        ; move r3, r11
        ld r3, r11
        ld r4, r12
        ; add r3, r3, r5
        add r4, r6
        adc r3, r5
        ; const r5, 20
        ld r5, #%00
        ld r6, #%14
        ; move r11, r3
        ld r11, r3
        ld r12, r4
        ; mod r11, r11, r5
        not implemented
        jp @while_42
@if_48_else:
        ; 245:8 if chr == 57419
        ; equals r15, r13, 57419
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
        ; branch r15, false, @if_49_else
        or r15, r15
        jp z, @if_49_else
        jp @if_49_then
@if_48_then:
        ; const r5, 40
        ld r5, #%00
        ld r6, #%28
        ; move r3, r9
        ld r3, r9
        ld r4, r10
        ; add r3, r3, r5
        add r4, r6
        adc r3, r5
        ; const r5, 1
        ld r5, #%00
        ld r6, #%01
        ; sub r3, r3, r5
        sub r4, r6
        sbc r3, r5
        ; const r5, 40
        ld r5, #%00
        ld r6, #%28
        ; move r9, r3
        ld r9, r3
        ld r10, r4
        ; mod r9, r9, r5
        not implemented
        jp @while_42
@if_49_else:
        ; 249:8 if chr == 57421
        ; equals r15, r13, 57421
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
        ; branch r15, false, @if_50_else
        or r15, r15
        jp z, @if_50_else
        jp @if_50_then
@if_49_then:
        ; const r5, 40
        ld r5, #%00
        ld r6, #%28
        ; move r3, r9
        ld r3, r9
        ld r4, r10
        ; add r3, r3, r5
        add r4, r6
        adc r3, r5
        ; const r5, 1
        ld r5, #%00
        ld r6, #%01
        ; sub r3, r3, r5
        sub r4, r6
        sbc r3, r5
        ; const r5, 40
        ld r5, #%00
        ld r6, #%28
        ; move r9, r3
        ld r9, r3
        ld r10, r4
        ; mod r9, r9, r5
        not implemented
        jp @while_42
@if_50_else:
        ; 253:8 if chr == 32
        ; equals r15, r13, 32
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
        ; branch r15, false, @if_51_else
        or r15, r15
        jp z, @if_51_else
        jp @if_51_then
@if_50_then:
        ; const r5, 1
        ld r5, #%00
        ld r6, #%01
        ; move r3, r9
        ld r3, r9
        ld r4, r10
        ; add r3, r3, r5
        add r4, r6
        adc r3, r5
        ; const r5, 40
        ld r5, #%00
        ld r6, #%28
        ; move r9, r3
        ld r9, r3
        ld r10, r4
        ; mod r9, r9, r5
        not implemented
        jp @while_42
@if_51_else:
        ; 262:8 if chr == 13
        ; equals r13, r13, 13
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
        ; branch r13, false, @while_42
        or r13, r13
        jp z, @while_42
        jp @if_54_then
@if_51_then:
        ; 254:4 if !needsInitialize
        ; notlog r13, r8
        not implemented
        ; branch r13, false, @while_42
        or r13, r13
        jp z, @while_42
        jp @if_52_then
@if_54_then:
        ; branch r8, false, @if_55_end
        or r8, r8
        jp z, @if_55_end
        jp @if_55_then
@if_52_then:
        ; move r1, r11
        ld r1, r11
        ld r2, r12
        ; move r3, r9
        ld r3, r9
        ld r4, r10
        ; call r0 = getCell[r1, r3] -> u8
        call getCell
        ; move r13, r0
        ld r13, r0
        ; 256:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move r1, r13
        ld r1, r13
        ; call r0 = isOpen[r1] -> bool
        call isOpen
        ; notlog r14, r0
        not implemented
        ; branch r14, false, @while_42
        or r14, r14
        jp z, @while_42
        jp @if_53_then
@if_55_then:
        ; const r8, 0
        ld r8, #%00
        ; move r0, r11
        ld r0, r11
        ld r1, r12
        ; move r2, r9
        ld r2, r9
        ld r3, r10
        ; call initField[r0, r2]
        call initField
        jp @if_55_end
@if_53_then:
        ; const r14, 4
        ld r14, #%04
        ; xor r13, r13, r14
        xor r13, r14
        ; move r0, r11
        ld r0, r11
        ld r1, r12
        ; move r2, r9
        ld r2, r9
        ld r3, r10
        ; move r4, r13
        ld r4, r13
        ; call setCell[r0, r2, r4]
        call setCell
        jp @while_42
@if_55_end:
        ; move r1, r11
        ld r1, r11
        ld r2, r12
        ; move r3, r9
        ld r3, r9
        ld r4, r10
        ; call r0 = getCell[r1, r3] -> u8
        call getCell
        ; move r13, r0
        ld r13, r0
        ; 268:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move r1, r13
        ld r1, r13
        ; call r0 = isOpen[r1] -> bool
        call isOpen
        ; notlog r14, r0
        not implemented
        ; branch r14, false, @if_56_end
        or r14, r14
        jp z, @if_56_end
        ; const r14, 2
        ld r14, #%02
        ; move r4, r13
        ld r4, r13
        ; or r4, r4, r14
        or r4, r14
        ; move r0, r11
        ld r0, r11
        ld r1, r12
        ; move r2, r9
        ld r2, r9
        ld r3, r10
        ; call setCell[r0, r2, r4]
        call setCell
@if_56_end:
        ; 271:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; move r1, r13
        ld r1, r13
        ; call r0 = isBomb[r1] -> bool
        call isBomb
        ; branch r0, true, @if_57_then
        or r0, r0
        jp nz, @if_57_then
        ; move r0, r11
        ld r0, r11
        ld r1, r12
        ; move r2, r9
        ld r2, r9
        ld r3, r10
        ; call maybeRevealAround[r0, r2]
        call maybeRevealAround
@while_42:
        ; move r0, r11
        ld r0, r11
        ld r1, r12
        ; move r2, r9
        ld r2, r9
        ld r3, r10
        ; call printField[r0, r2]
        call printField
        ; 220:3 if !needsInitialize
        ; notlog r13, r8
        not implemented
        ; branch r13, false, @if_43_end
        or r13, r13
        jp z, @if_43_end
        jp @if_43_then
@if_44_then:
        ; const r0, [string-2]
        not implemented
        ; call printString[r0]
        call printString
        jp @main_ret
@if_57_then:
        ; move r0, r11
        ld r0, r11
        ld r1, r12
        ; move r2, r9
        ld r2, r9
        ld r3, r10
        ; call printField[r0, r2]
        call printField
        ; const r0, [string-3]
        not implemented
        ; call printString[r0]
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

