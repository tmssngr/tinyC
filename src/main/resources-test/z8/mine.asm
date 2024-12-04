        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void printString
        ;   rsp+11: arg str
        ;   rsp+0: var chr
@printString:
        ; reserve space for local variables
        sub rsp, 1
@while_1:
        ; move r0, str
        ; load r1, [r0]
        ; 4:3 if chr == 0
        ; const r2, 0
        ld r8, 0
        ; equals r2, r1, r2
        ; move chr, r1
        ; branch r2, true, @printString_ret
        jnz @printString_ret
        ; @if_2_end
        ; call _, printChar [chr]
        ; jump @while_1
        jmp @while_1
@printString_ret:
        ; release space for local variables
        add rsp, 1
        ret

        ; void printStringLength
        ;   rsp+3: arg str
        ;   rsp+11: arg length
@printStringLength:
@while_3:
        ; const r0, 0
        ld r0, 0
        ; move r1, length
        ; gt r0, r1, r0
        ; branch r0, false, @printStringLength_ret
        jz @printStringLength_ret
        ; 
        ; move r0, str
        ; load r1, [r0]
        ; call _, printChar [r1]
        ; const r0, 1
        ld r0, 1
        ; move r1, length
        ; sub r0, r1, r0
        ; move length, r0
        ; jump @while_3
        jmp @while_3
@printStringLength_ret:
        ret

        ; void printUint
        ;   rsp+25: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
@printUint:
        ; reserve space for local variables
        sub rsp, 21
        ; const r0, 20
        ld r0, 20
        ; 24:2 while true
        ; move pos, r0
@while_4:
        ; const r0, 1
        ld r0, 1
        ; move r1, pos
        ; sub r0, r1, r0
        ; const r1, 10
        ld r5, 10
        ld r4, 0
        ; move r2, number
        ; move r3, r2
        ; mod r1, r3, r1
        ; cast r1(i64), r1(i16)
        ; const r3, 10
        ld r13, 10
        ld r12, 0
        ; div r2, r2, r3
        ; cast r1(u8), r1(i64)
        ; const r3, 48
        ld r12, 48
        ; add r1, r1, r3
        ; cast r3(i16), r0(u8)
        ; cast r3(u8*), r3(i16)
        ; Spill pos
        ; move pos, r0
        ; addrof r0, [buffer]
        ; add r0, r0, r3
        ; store [r0], r1
        ; 30:3 if number == 0
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; equals r0, r2, r0
        ; move number, r2
        ; branch r0, false, @while_4
        jz @while_4
        ; 
        ; move r0, pos
        ; cast r1(i16), r0(u8)
        ; cast r1(u8*), r1(i16)
        ; addrof r2, [buffer]
        ; add r1, r2, r1
        ; const r2, 20
        ld r8, 20
        ; sub r0, r2, r0
        ; call _, printStringLength [r1, r0]
        ; release space for local variables
        add rsp, 21
        ret

        ; u8 getChar
@getChar:
        ; 57:9 return 0
        ; const r0, 0
        ld r0, 0
        ; ret r0
        ret

        ; void setCursor
        ;   rsp+3: arg x
        ;   rsp+4: arg y
@setCursor:
        ret

        ; void initRandom
        ;   rsp+6: arg salt
@initRandom:
        ret

        ; i32 random
@random:
        ; 70:9 return 0
        ; const r0, 0
        ld r3, 0
        ld r2, 0
        ld r1, 0
        ld r0, 0
        ; ret r0
        ret

        ; i16 rowColumnToCell
        ;   rsp+4: arg row
        ;   rsp+6: arg column
@rowColumnToCell:
        ; 15:21 return row * 40 + column
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; move r1, row
        ; mul r0, r1, r0
        ; move r1, column
        ; add r0, r0, r1
        ; ret r0
        ret

        ; u8 getCell
        ;   rsp+4: arg row
        ;   rsp+6: arg column
@getCell:
        ; 19:15 return [...]
        ; call r0, rowColumnToCell, [row, column]
        ; cast r0(u8*), r0(i16)
        ; addrof r1, [field]
        ; add r0, r1, r0
        ; load r0, [r0]
        ; ret r0
        ret

        ; bool isBomb
        ;   rsp+3: arg cell
@isBomb:
        ; 23:27 return cell & 1 != 0
        ; const r0, 1
        ld r0, 1
        ; move r1, cell
        ; and r0, r1, r0
        ; const r1, 0
        ld r4, 0
        ; notequals r0, r0, r1
        ; ret r0
        ret

        ; bool isOpen
        ;   rsp+3: arg cell
@isOpen:
        ; 27:27 return cell & 2 != 0
        ; const r0, 2
        ld r0, 2
        ; move r1, cell
        ; and r0, r1, r0
        ; const r1, 0
        ld r4, 0
        ; notequals r0, r0, r1
        ; ret r0
        ret

        ; bool isFlag
        ;   rsp+3: arg cell
@isFlag:
        ; 31:27 return cell & 4 != 0
        ; const r0, 4
        ld r0, 4
        ; move r1, cell
        ; and r0, r1, r0
        ; const r1, 0
        ld r4, 0
        ; notequals r0, r0, r1
        ; ret r0
        ret

        ; bool checkCellBounds
        ;   rsp+5: arg row
        ;   rsp+7: arg column
        ;   rsp+0: var t.2
@checkCellBounds:
        ; reserve space for local variables
        sub rsp, 1
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, row
        ; gteq r0, r1, r0
        ; move t.2, r0
        ; branch r0, false, @and_next_8
        jz @and_next_8
        ; 
        ; const r0, 20
        ld r1, 20
        ld r0, 0
        ; move r1, row
        ; lt r0, r1, r0
        ; move t.2, r0
@and_next_8:
        ; move r0, t.2
        ; branch r0, false, @and_next_7
        jz @and_next_7
        ; 
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, column
        ; gteq r0, r1, r0
        ; move t.2, r0
@and_next_7:
        ; move r0, t.2
        ; branch r0, false, @and_next_6
        jz @and_next_6
        ; 
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; move r1, column
        ; lt r0, r1, r0
        ; move t.2, r0
@and_next_6:
        ; move r0, t.2
        ; ret r0
        ; release space for local variables
        add rsp, 1
        ret

        ; void setCell
        ;   rsp+3: arg row
        ;   rsp+5: arg column
        ;   rsp+7: arg cell
@setCell:
        ; call r0, rowColumnToCell, [row, column]
        ; cast r0(u8*), r0(i16)
        ; addrof r1, [field]
        ; add r0, r1, r0
        ; move r1, cell
        ; store [r0], r1
        ret

        ; u8 getBombCountAround
        ;   rsp+13: arg row
        ;   rsp+15: arg column
        ;   rsp+0: var count
        ;   rsp+1: var dr
        ;   rsp+3: var r
        ;   rsp+5: var dc
        ;   rsp+7: var c
@getBombCountAround:
        ; reserve space for local variables
        sub rsp, 9
        ; const r0, 0
        ld r0, 0
        ; const r1, -1
        ld r5, 255
        ld r4, 255
        ; 45:2 for dr <= 1
        ; move count, r0
        ; move dr, r1
@for_9:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dr
        ; lteq r0, r1, r0
        ; branch r0, false, @for_9_break
        jz @for_9_break
        ; @for_9_body
        ; move r0, row
        ; move r1, r0
        ; move r2, dr
        ; add r1, r1, r2
        ; const r3, -1
        ld r13, 255
        ld r12, 255
        ; 47:3 for dc <= 1
        ; move r, r1
        ; move dc, r3
@for_10:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dc
        ; lteq r0, r1, r0
        ; branch r0, false, @for_10_break
        jz @for_10_break
        ; @for_10_body
        ; move r0, column
        ; move r1, r0
        ; move r2, dc
        ; add r1, r1, r2
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; move c, r1
        ; call r0, checkCellBounds, [r, r1]
        ; branch r0, false, @for_10_continue
        jz @for_10_continue
        ; 
        ; call r0, getCell, [r, c]
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; call r0, isBomb, [r0]
        ; branch r0, false, @for_10_continue
        jz @for_10_continue
        ; 
        ; const r0, 1
        ld r0, 1
        ; move r1, count
        ; add r0, r1, r0
        ; move count, r0
@for_10_continue:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dc
        ; add r0, r1, r0
        ; move dc, r0
        ; jump @for_10
        jmp @for_10
@for_10_break:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dr
        ; add r0, r1, r0
        ; move dr, r0
        ; jump @for_9
        jmp @for_9
@for_9_break:
        ; 57:9 return count
        ; move r0, count
        ; ret r0
        ; release space for local variables
        add rsp, 9
        ret

        ; u8 getSpacer
        ;   rsp+4: arg row
        ;   rsp+6: arg column
        ;   rsp+8: arg rowCursor
        ;   rsp+10: arg columnCursor
@getSpacer:
        ; 61:2 if rowCursor == row
        ; move r0, rowCursor
        ; move r1, row
        ; equals r0, r0, r1
        ; branch r0, false, @if_13_end
        jz @if_13_end
        ; 
        ; 62:3 if columnCursor == column
        ; move r0, columnCursor
        ; move r1, column
        ; equals r2, r0, r1
        ; branch r2, false, @if_14_end
        jz @if_14_end
        ; @if_14_then
        ; 63:11 return 91
        ; const r0, 91
        ld r0, 91
        ; ret r0
        ; jump @getSpacer_ret
        jmp @getSpacer_ret
@if_14_end:
        ; 65:3 if columnCursor == column - 1
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, column
        ; sub r0, r1, r0
        ; move r1, columnCursor
        ; equals r0, r1, r0
        ; branch r0, false, @if_13_end
        jz @if_13_end
        ; 
        ; 66:11 return 93
        ; const r0, 93
        ld r0, 93
        ; ret r0
        ; jump @getSpacer_ret
        jmp @getSpacer_ret
@if_13_end:
        ; 69:9 return 32
        ; const r0, 32
        ld r0, 32
        ; ret r0
@getSpacer_ret:
        ret

        ; void printCell
        ;   rsp+6: arg cell
        ;   rsp+8: arg row
        ;   rsp+9: arg column
        ;   rsp+0: var chr
        ;   rsp+1: var count
@printCell:
        ; reserve space for local variables
        sub rsp, 2
        ; const r0, 46
        ld r0, 46
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; move chr, r0
        ; call r0, isOpen, [cell]
        ; branch r0, false, @if_16_else
        jz @if_16_else
        ; @if_16_then
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; call r0, isBomb, [cell]
        ; branch r0, false, @if_17_else
        jz @if_17_else
        ; @if_17_then
        ; const r0, 42
        ld r0, 42
        ; move chr, r0
        ; jump @if_16_end
        jmp @if_16_end
@if_17_else:
        ; call r0, getBombCountAround, [row, column]
        ; 80:4 if count > 0
        ; const r1, 0
        ld r4, 0
        ; gt r1, r0, r1
        ; move count, r0
        ; branch r1, false, @if_18_else
        jz @if_18_else
        ; @if_18_then
        ; const r0, 48
        ld r0, 48
        ; move r1, count
        ; add r0, r1, r0
        ; move chr, r0
        ; jump @if_16_end
        jmp @if_16_end
@if_18_else:
        ; const r0, 32
        ld r0, 32
        ; move chr, r0
        ; jump @if_16_end
        jmp @if_16_end
@if_16_else:
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; call r0, isFlag, [cell]
        ; branch r0, false, @if_16_end
        jz @if_16_end
        ; 
        ; const r0, 35
        ld r0, 35
        ; move chr, r0
@if_16_end:
        ; call _, printChar [chr]
        ; release space for local variables
        add rsp, 2
        ret

        ; void printField
        ;   rsp+8: arg rowCursor
        ;   rsp+10: arg columnCursor
        ;   rsp+0: var row
        ;   rsp+2: var column
@printField:
        ; reserve space for local variables
        sub rsp, 4
        ; const r0, 0
        ld r0, 0
        ; const r1, 0
        ld r4, 0
        ; call _, setCursor [r0, r1]
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; 96:2 for row < 20
        ; move row, r0
@for_20:
        ; const r0, 20
        ld r1, 20
        ld r0, 0
        ; move r1, row
        ; lt r0, r1, r0
        ; branch r0, false, @printField_ret
        jz @printField_ret
        ; 
        ; const r0, 124
        ld r0, 124
        ; call _, printChar [r0]
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; 98:3 for column < 40
        ; move column, r0
@for_21:
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; move r1, column
        ; lt r0, r1, r0
        ; branch r0, false, @for_21_break
        jz @for_21_break
        ; @for_21_body
        ; call r0, getSpacer, [row, column, rowCursor, columnCursor]
        ; call _, printChar [r0]
        ; call r0, getCell, [row, column]
        ; call _, printCell [r0, row, column]
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, column
        ; add r0, r1, r0
        ; move column, r0
        ; jump @for_21
        jmp @for_21
@for_21_break:
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; call r0, getSpacer, [row, r0, rowCursor, columnCursor]
        ; call _, printChar [r0]
        ; const r0, [string-0]
        ; call _, printString [r0]
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, row
        ; add r0, r1, r0
        ; move row, r0
        ; jump @for_20
        jmp @for_20
@printField_ret:
        ; release space for local variables
        add rsp, 4
        ret

        ; void printSpaces
        ;   rsp+4: arg i
@printSpaces:
@for_22:
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, i
        ; gt r0, r1, r0
        ; branch r0, false, @printSpaces_ret
        jz @printSpaces_ret
        ; 
        ; const r0, 48
        ld r0, 48
        ; call _, printChar [r0]
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, i
        ; sub r0, r1, r0
        ; move i, r0
        ; jump @for_22
        jmp @for_22
@printSpaces_ret:
        ret

        ; u8 getDigitCount
        ;   rsp+5: arg value
        ;   rsp+0: var count
@getDigitCount:
        ; reserve space for local variables
        sub rsp, 1
        ; const r0, 0
        ld r0, 0
        ; 118:2 if value < 0
        ; const r1, 0
        ld r5, 0
        ld r4, 0
        ; move r2, value
        ; lt r1, r2, r1
        ; move count, r0
        ; branch r1, false, @while_24
        jz @while_24
        ; 
        ; const r0, 1
        ld r0, 1
        ; move r1, value
        ; neg r1, r1
        ; move count, r0
        ; move value, r1
@while_24:
        ; const r0, 1
        ld r0, 1
        ; move r1, count
        ; add r0, r1, r0
        ; const r1, 10
        ld r5, 10
        ld r4, 0
        ; move r2, value
        ; div r1, r2, r1
        ; 126:3 if value == 0
        ; const r2, 0
        ld r9, 0
        ld r8, 0
        ; equals r2, r1, r2
        ; move count, r0
        ; move value, r1
        ; branch r2, false, @while_24
        jz @while_24
        ; 
        ; 131:9 return count
        ; move r0, count
        ; ret r0
        ; release space for local variables
        add rsp, 1
        ret

        ; i16 getHiddenCount
        ;   rsp+0: var count
        ;   rsp+2: var r
        ;   rsp+4: var c
@getHiddenCount:
        ; reserve space for local variables
        sub rsp, 6
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; const r1, 0
        ld r5, 0
        ld r4, 0
        ; 136:2 for r < 20
        ; move count, r0
        ; move r, r1
@for_26:
        ; const r0, 20
        ld r1, 20
        ld r0, 0
        ; move r1, r
        ; lt r0, r1, r0
        ; branch r0, false, @for_26_break
        jz @for_26_break
        ; @for_26_body
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; 137:3 for c < 40
        ; move c, r0
@for_27:
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; move r1, c
        ; lt r0, r1, r0
        ; branch r0, false, @for_27_break
        jz @for_27_break
        ; @for_27_body
        ; call r0, getCell, [r, c]
        ; 139:4 if cell & 6 == 0
        ; const r1, 6
        ld r4, 6
        ; and r0, r0, r1
        ; const r1, 0
        ld r4, 0
        ; equals r0, r0, r1
        ; branch r0, false, @for_27_continue
        jz @for_27_continue
        ; 
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, count
        ; add r0, r1, r0
        ; move count, r0
@for_27_continue:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, c
        ; add r0, r1, r0
        ; move c, r0
        ; jump @for_27
        jmp @for_27
@for_27_break:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, r
        ; add r0, r1, r0
        ; move r, r0
        ; jump @for_26
        jmp @for_26
@for_26_break:
        ; 144:9 return count
        ; move r0, count
        ; ret r0
        ; release space for local variables
        add rsp, 6
        ret

        ; bool printLeft
        ;   rsp+0: var count
        ;   rsp+2: var leftDigits
        ;   rsp+4: var bombDigits
@printLeft:
        ; reserve space for local variables
        sub rsp, 6
        ; call r0, getHiddenCount, []
        ; move count, r0
        ; call r0, getDigitCount, [r0]
        ; cast r0(i16), r0(u8)
        ; const r1, 40
        ld r5, 40
        ld r4, 0
        ; move leftDigits, r0
        ; call r0, getDigitCount, [r1]
        ; cast r0(i16), r0(u8)
        ; const r1, [string-1]
        ; move bombDigits, r0
        ; call _, printString [r1]
        ; move r0, bombDigits
        ; move r1, leftDigits
        ; sub r0, r0, r1
        ; call _, printSpaces [r0]
        ; call _, printUint [count]
        ; 155:15 return count == 0
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, count
        ; equals r0, r1, r0
        ; ret r0
        ; release space for local variables
        add rsp, 6
        ret

        ; i16 abs
        ;   rsp+4: arg a
@abs:
        ; 159:2 if a < 0
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, a
        ; lt r0, r1, r0
        ; branch r0, false, @if_29_end
        jz @if_29_end
        ; @if_29_then
        ; 160:10 return -a
        ; move r0, a
        ; neg r0, r0
        ; ret r0
        ; jump @abs_ret
        jmp @abs_ret
@if_29_end:
        ; 162:9 return a
        ; move r0, a
        ; ret r0
@abs_ret:
        ret

        ; void clearField
        ;   rsp+0: var r
        ;   rsp+2: var c
@clearField:
        ; reserve space for local variables
        sub rsp, 4
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; 166:2 for r < 20
        ; move r, r0
@for_30:
        ; const r0, 20
        ld r1, 20
        ld r0, 0
        ; move r1, r
        ; lt r0, r1, r0
        ; branch r0, false, @clearField_ret
        jz @clearField_ret
        ; 
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; 167:3 for c < 40
        ; move c, r0
@for_31:
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; move r1, c
        ; lt r0, r1, r0
        ; branch r0, false, @for_31_break
        jz @for_31_break
        ; @for_31_body
        ; const r0, 0
        ld r0, 0
        ; call _, setCell [r, c, r0]
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, c
        ; add r0, r1, r0
        ; move c, r0
        ; jump @for_31
        jmp @for_31
@for_31_break:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, r
        ; add r0, r1, r0
        ; move r, r0
        ; jump @for_30
        jmp @for_30
@clearField_ret:
        ; release space for local variables
        add rsp, 4
        ret

        ; void initField
        ;   rsp+11: arg curr_r
        ;   rsp+13: arg curr_c
        ;   rsp+0: var bombs
        ;   rsp+2: var row
        ;   rsp+4: var column
        ;   rsp+6: var t.13
@initField:
        ; reserve space for local variables
        sub rsp, 7
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; 174:2 for bombs > 0
        ; move bombs, r0
@for_32:
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, bombs
        ; gt r0, r1, r0
        ; branch r0, false, @initField_ret
        jz @initField_ret
        ; 
        ; call r0, random, []
        ; const r1, 20
        ld r7, 20
        ld r6, 0
        ld r5, 0
        ld r4, 0
        ; mod r0, r0, r1
        ; cast r0(i16), r0(i32)
        ; move row, r0
        ; call r0, random, []
        ; const r1, 40
        ld r7, 40
        ld r6, 0
        ld r5, 0
        ld r4, 0
        ; mod r0, r0, r1
        ; cast r0(i16), r0(i32)
        ; 177:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move r1, row
        ; move r2, r1
        ; move r3, curr_r
        ; sub r2, r2, r3
        ; move column, r0
        ; call r0, abs, [r2]
        ; const r1, 1
        ld r5, 1
        ld r4, 0
        ; gt r0, r0, r1
        ; move t.13, r0
        ; branch r0, true, @or_next_34
        jnz @or_next_34
        ; 
        ; move r0, column
        ; move r1, r0
        ; move r2, curr_c
        ; sub r1, r1, r2
        ; call r0, abs, [r1]
        ; const r1, 1
        ld r5, 1
        ld r4, 0
        ; gt r0, r0, r1
        ; move t.13, r0
@or_next_34:
        ; move r0, t.13
        ; branch r0, false, @for_32_continue
        jz @for_32_continue
        ; 
        ; const r0, 1
        ld r0, 1
        ; call _, setCell [row, column, r0]
@for_32_continue:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, bombs
        ; sub r0, r1, r0
        ; move bombs, r0
        ; jump @for_32
        jmp @for_32
@initField_ret:
        ; release space for local variables
        add rsp, 7
        ret

        ; void maybeRevealAround
        ;   rsp+14: arg row
        ;   rsp+16: arg column
        ;   rsp+0: var dr
        ;   rsp+2: var r
        ;   rsp+4: var dc
        ;   rsp+6: var c
        ;   rsp+8: var cell
        ;   rsp+9: var t.14
@maybeRevealAround:
        ; reserve space for local variables
        sub rsp, 10
        ; 185:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=185:30]]) != 0
        ; call r0, getBombCountAround, [row, column]
        ; const r1, 0
        ld r4, 0
        ; notequals r0, r0, r1
        ; branch r0, true, @maybeRevealAround_ret
        jnz @maybeRevealAround_ret
        ; @if_35_end
        ; const r0, -1
        ld r1, 255
        ld r0, 255
        ; 189:2 for dr <= 1
        ; move dr, r0
@for_36:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dr
        ; lteq r0, r1, r0
        ; branch r0, false, @maybeRevealAround_ret
        jz @maybeRevealAround_ret
        ; 
        ; move r0, row
        ; move r1, r0
        ; move r2, dr
        ; add r1, r1, r2
        ; const r3, -1
        ld r13, 255
        ld r12, 255
        ; 191:3 for dc <= 1
        ; move r, r1
        ; move dc, r3
@for_37:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dc
        ; lteq r0, r1, r0
        ; branch r0, false, @for_37_break
        jz @for_37_break
        ; @for_37_body
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, dr
        ; equals r0, r1, r0
        ; move t.14, r0
        ; branch r0, false, @and_next_39
        jz @and_next_39
        ; 
        ; const r0, 0
        ld r1, 0
        ld r0, 0
        ; move r1, dc
        ; equals r0, r1, r0
        ; move t.14, r0
@and_next_39:
        ; move r0, t.14
        ; branch r0, true, @for_37_continue
        jnz @for_37_continue
        ; @if_38_end
        ; move r0, column
        ; move r1, r0
        ; move r2, dc
        ; add r1, r1, r2
        ; 197:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; move c, r1
        ; call r0, checkCellBounds, [r, r1]
        ; notlog r0, r0
        ; branch r0, true, @for_37_continue
        jnz @for_37_continue
        ; @if_40_end
        ; call r0, getCell, [r, c]
        ; 202:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move cell, r0
        ; call r0, isOpen, [r0]
        ; branch r0, true, @for_37_continue
        jnz @for_37_continue
        ; @if_41_end
        ; const r0, 2
        ld r0, 2
        ; move r1, cell
        ; or r0, r1, r0
        ; call _, setCell [r, c, r0]
        ; call _, maybeRevealAround [r, c]
@for_37_continue:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dc
        ; add r0, r1, r0
        ; move dc, r0
        ; jump @for_37
        jmp @for_37
@for_37_break:
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, dr
        ; add r0, r1, r0
        ; move dr, r0
        ; jump @for_36
        jmp @for_36
@maybeRevealAround_ret:
        ; release space for local variables
        add rsp, 10
        ret

        ; void main
        ;   rsp+0: var needsInitialize
        ;   rsp+1: var curr_c
        ;   rsp+3: var curr_r
        ;   rsp+5: var chr
        ;   rsp+7: var cell
        ;   rsp+8: var cell
@main:
        ; reserve space for local variables
        sub rsp, 9
        ; begin initialize global variables
        ; end initialize global variables
        ; const r0, 7439742
        ld r3, 126
        ld r2, 133
        ld r1, 113
        ld r0, 0
        ; call _, initRandom [r0]
        ; const r0, 1
        ld r0, 1
        ; move needsInitialize, r0
        ; call _, clearField []
        ; const r0, 20
        ld r0, 20
        ; cast r0(i16), r0(u8)
        ; const r1, 10
        ld r4, 10
        ; cast r1(i16), r1(u8)
        ; 218:2 while true
        ; move curr_c, r0
        ; move curr_r, r1
@while_42:
        ; call _, printField [curr_r, curr_c]
        ; 220:3 if !needsInitialize
        ; move r0, needsInitialize
        ; notlog r1, r0
        ; branch r1, false, @if_43_end
        jz @if_43_end
        ; 
        ; 221:4 if printLeft([])
        ; call r0, printLeft, []
        ; branch r0, false, @if_43_end
        jz @if_43_end
        ; 
        ; const r0, [string-2]
        ; call _, printString [r0]
        ; jump @main_ret
        jmp @main_ret
@if_43_end:
        ; call r0, getChar, []
        ; cast r0(i16), r0(u8)
        ; 228:3 if chr == 27
        ; const r1, 27
        ld r5, 27
        ld r4, 0
        ; equals r1, r0, r1
        ; move chr, r0
        ; branch r1, true, @main_ret
        jnz @main_ret
        ; @if_45_end
        ; 233:3 if chr == 57416
        ; const r0, 57416
        ld r1, 72
        ld r0, 224
        ; move r1, chr
        ; equals r0, r1, r0
        ; branch r0, false, @if_46_else
        jz @if_46_else
        ; @if_46_then
        ; const r0, 20
        ld r1, 20
        ld r0, 0
        ; move r1, curr_r
        ; add r0, r1, r0
        ; const r1, 1
        ld r5, 1
        ld r4, 0
        ; sub r0, r0, r1
        ; const r1, 20
        ld r5, 20
        ld r4, 0
        ; mod r0, r0, r1
        ; move curr_r, r0
        ; jump @while_42
        jmp @while_42
@if_46_else:
        ; 237:8 if chr == 57424
        ; const r0, 57424
        ld r1, 80
        ld r0, 224
        ; move r1, chr
        ; equals r0, r1, r0
        ; branch r0, false, @if_47_else
        jz @if_47_else
        ; @if_47_then
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, curr_r
        ; add r0, r1, r0
        ; const r1, 20
        ld r5, 20
        ld r4, 0
        ; mod r0, r0, r1
        ; move curr_r, r0
        ; jump @while_42
        jmp @while_42
@if_47_else:
        ; 241:8 if chr == 57419
        ; const r0, 57419
        ld r1, 75
        ld r0, 224
        ; move r1, chr
        ; equals r0, r1, r0
        ; branch r0, false, @if_48_else
        jz @if_48_else
        ; @if_48_then
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; move r1, curr_c
        ; add r0, r1, r0
        ; const r1, 1
        ld r5, 1
        ld r4, 0
        ; sub r0, r0, r1
        ; const r1, 40
        ld r5, 40
        ld r4, 0
        ; mod r0, r0, r1
        ; move curr_c, r0
        ; jump @while_42
        jmp @while_42
@if_48_else:
        ; 245:8 if chr == 57419
        ; const r0, 57419
        ld r1, 75
        ld r0, 224
        ; move r1, chr
        ; equals r0, r1, r0
        ; branch r0, false, @if_49_else
        jz @if_49_else
        ; @if_49_then
        ; const r0, 40
        ld r1, 40
        ld r0, 0
        ; move r1, curr_c
        ; add r0, r1, r0
        ; const r1, 1
        ld r5, 1
        ld r4, 0
        ; sub r0, r0, r1
        ; const r1, 40
        ld r5, 40
        ld r4, 0
        ; mod r0, r0, r1
        ; move curr_c, r0
        ; jump @while_42
        jmp @while_42
@if_49_else:
        ; 249:8 if chr == 57421
        ; const r0, 57421
        ld r1, 77
        ld r0, 224
        ; move r1, chr
        ; equals r0, r1, r0
        ; branch r0, false, @if_50_else
        jz @if_50_else
        ; @if_50_then
        ; const r0, 1
        ld r1, 1
        ld r0, 0
        ; move r1, curr_c
        ; add r0, r1, r0
        ; const r1, 40
        ld r5, 40
        ld r4, 0
        ; mod r0, r0, r1
        ; move curr_c, r0
        ; jump @while_42
        jmp @while_42
@if_50_else:
        ; 253:8 if chr == 32
        ; const r0, 32
        ld r1, 32
        ld r0, 0
        ; move r1, chr
        ; equals r0, r1, r0
        ; branch r0, false, @if_51_else
        jz @if_51_else
        ; @if_51_then
        ; 254:4 if !needsInitialize
        ; move r0, needsInitialize
        ; notlog r1, r0
        ; branch r1, false, @while_42
        jz @while_42
        ; 
        ; call r0, getCell, [curr_r, curr_c]
        ; 256:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move cell, r0
        ; call r0, isOpen, [r0]
        ; notlog r0, r0
        ; branch r0, false, @while_42
        jz @while_42
        ; 
        ; const r0, 4
        ld r0, 4
        ; move r1, cell
        ; xor r0, r1, r0
        ; call _, setCell [curr_r, curr_c, r0]
        ; jump @while_42
        jmp @while_42
@if_51_else:
        ; 262:8 if chr == 13
        ; const r0, 13
        ld r1, 13
        ld r0, 0
        ; move r1, chr
        ; equals r0, r1, r0
        ; branch r0, false, @while_42
        jz @while_42
        ; 
        ; move r0, needsInitialize
        ; branch r0, false, @if_55_end
        jz @if_55_end
        ; 
        ; const r0, 0
        ld r0, 0
        ; move needsInitialize, r0
        ; call _, initField [curr_r, curr_c]
@if_55_end:
        ; call r0, getCell, [curr_r, curr_c]
        ; 268:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move cell, r0
        ; call r0, isOpen, [r0]
        ; notlog r0, r0
        ; branch r0, false, @if_56_end
        jz @if_56_end
        ; 
        ; const r0, 2
        ld r0, 2
        ; move r1, cell
        ; move r2, r1
        ; or r0, r2, r0
        ; call _, setCell [curr_r, curr_c, r0]
@if_56_end:
        ; 271:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; call r0, isBomb, [cell]
        ; branch r0, false, @if_57_end
        jz @if_57_end
        ; @if_57_then
        ; call _, printField [curr_r, curr_c]
        ; const r0, [string-3]
        ; call _, printString [r0]
        ; jump @main_ret
        jmp @main_ret
@if_57_end:
        ; call _, maybeRevealAround [curr_r, curr_c]
        ; jump @while_42
        jmp @while_42
@main_ret:
        ; release space for local variables
        add rsp, 9
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

        ; variable 0: field[] (u8*/6400)
var_0:
        .repeat 6400
        .data 0
        .end

string_0:
        '|', 0x0a, 0x00
string_1:
        'Left: ', 0x00
string_2:
        ' You', 0x27, 've cleaned the field!', 0x00
string_3:
        'boom! you', 0x27, 've lost', 0x00

