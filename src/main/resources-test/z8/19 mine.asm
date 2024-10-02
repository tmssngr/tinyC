        .const SPH = %FE
        .const SPL = %FF

        .org %C000

        srp %20
        jp @main

        ; void printString
        ;   rsp+8: arg str
        ;   rsp+0: var chr
@printString:
        ; reserve space for local variables
        sub rsp, 1
@while_1:
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        ; load r.1(1@register,u8), [r.0(0@register,u8*)]
        ; 4:3 if chr == 0
        ; const r.2(2@register,u8), 0
        ld r8, 0
        ; equals r.2(2@register,bool), r.1(1@register,u8), r.2(2@register,u8)
        ; copy chr(1@function,u8), r.1(1@register,u8)
        ; branch r.2(2@register,bool), false, @if_2_end
        jz @if_2_end
        ; @if_2_then
        ; jump @printString_ret
        jmp @printString_ret
@if_2_end:
        ; call _, printChar [chr(1@function,u8)]
        ; jump @while_1
        jmp @while_1
@printString_ret:
        ; release space for local variables
        add rsp, 1
        ret

        ; void printStringLength
        ;   rsp+1: arg str
        ;   rsp+8: arg length
@printStringLength:
@while_3:
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; copy r.1(1@register,u8), length(1@argument,u8)
        ; gt r.0(0@register,bool), r.1(1@register,u8), r.0(0@register,u8)
        ; branch r.0(0@register,bool), false, @printStringLength_ret
        jz @printStringLength_ret
        ; 
        ; copy r.0(0@register,u8*), str(0@argument,u8*)
        ; load r.1(1@register,u8), [r.0(0@register,u8*)]
        ; call _, printChar [r.1(1@register,u8)]
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), length(1@argument,u8)
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy length(1@argument,u8), r.0(0@register,u8)
        ; jump @while_3
        jmp @while_3
@printStringLength_ret:
        ret

        ; void printUint
        ;   rsp+2: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
@printUint:
        ; reserve space for local variables
        sub rsp, 21
        ; const r.0(0@register,u8), 20
        ld r0, 20
        ; 24:2 while true
        ; copy pos(2@function,u8), r.0(0@register,u8)
@while_4:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), pos(2@function,u8)
        ; sub r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,i16), 10
        ld r5, 10
        ld r4, 0
        ; copy r.2(2@register,i16), number(0@argument,i16)
        ; mod r.1(1@register,i16), r.2(2@register,i16), r.1(1@register,i16)
        ; cast r.1(1@register,i64), r.1(1@register,i16)
        ; const r.3(3@register,i16), 10
        ld r13, 10
        ld r12, 0
        ; div r.2(2@register,i16), r.2(2@register,i16), r.3(3@register,i16)
        ; cast r.1(1@register,u8), r.1(1@register,i64)
        ; const r.3(3@register,u8), 48
        ld r12, 48
        ; add r.1(1@register,u8), r.1(1@register,u8), r.3(3@register,u8)
        ; cast r.3(3@register,i16), r.0(0@register,u8)
        ; array r.3(3@register,u8*), buffer(1@function,u8*) + r.3(3@register,i16)
        ; store [r.3(3@register,u8*)], r.1(1@register,u8)
        ; 30:3 if number == 0
        ; const r.1(1@register,i16), 0
        ld r5, 0
        ld r4, 0
        ; equals r.1(1@register,bool), r.2(2@register,i16), r.1(1@register,i16)
        ; copy pos(2@function,u8), r.0(0@register,u8)
        ; copy number(0@argument,i16), r.2(2@register,i16)
        ; branch r.1(1@register,bool), false, @while_4
        jz @while_4
        ; 
        ; copy r.0(0@register,u8), pos(2@function,u8)
        ; cast r.1(1@register,i16), r.0(0@register,u8)
        ; addrof r.1(1@register,u8*), [buffer(1@function,u8*) + r.1(1@register,i16)]
        ; const r.2(2@register,u8), 20
        ld r8, 20
        ; sub r.0(0@register,u8), r.2(2@register,u8), r.0(0@register,u8)
        ; call _, printStringLength [r.1(1@register,u8*), r.0(0@register,u8)]
        ; release space for local variables
        add rsp, 21
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

        ; u8 getChar
@getChar:
        ; 57:9 return 0
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; ret r.0(0@register,u8)
        ret

        ; void setCursor
        ;   rsp+1: arg x
        ;   rsp+1: arg y
@setCursor:
        ret

        ; void initRandom
        ;   rsp+4: arg salt
@initRandom:
        ret

        ; i32 random
@random:
        ; 70:9 return 0
        ; const r.0(0@register,i32), 0
        ld r3, 0
        ld r2, 0
        ld r1, 0
        ld r0, 0
        ; ret r.0(0@register,i32)
        ret

        ; i16 rowColumnToCell
        ;   rsp+2: arg row
        ;   rsp+2: arg column
@rowColumnToCell:
        ; 15:21 return row * 40 + column
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; copy r.1(1@register,i16), row(0@argument,i16)
        ; mul r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy r.1(1@register,i16), column(1@argument,i16)
        ; add r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; ret r.0(0@register,i16)
        ret

        ; u8 getCell
        ;   rsp+2: arg row
        ;   rsp+2: arg column
@getCell:
        ; 19:15 return [...]
        ; call r.0(0@register,i16), rowColumnToCell, [row(0@argument,i16), column(1@argument,i16)]
        ; array r.0(0@register,u8*), field(0@global,u8*) + r.0(0@register,i16)
        ; load r.0(0@register,u8), [r.0(0@register,u8*)]
        ; ret r.0(0@register,u8)
        ret

        ; bool isBomb
        ;   rsp+1: arg cell
@isBomb:
        ; 23:27 return cell & 1 != 0
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), cell(0@argument,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; ret r.0(0@register,bool)
        ret

        ; bool isOpen
        ;   rsp+1: arg cell
@isOpen:
        ; 27:27 return cell & 2 != 0
        ; const r.0(0@register,u8), 2
        ld r0, 2
        ; copy r.1(1@register,u8), cell(0@argument,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; ret r.0(0@register,bool)
        ret

        ; bool isFlag
        ;   rsp+1: arg cell
@isFlag:
        ; 31:27 return cell & 4 != 0
        ; const r.0(0@register,u8), 4
        ld r0, 4
        ; copy r.1(1@register,u8), cell(0@argument,u8)
        ; and r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; ret r.0(0@register,bool)
        ret

        ; bool checkCellBounds
        ;   rsp+2: arg row
        ;   rsp+2: arg column
        ;   rsp+0: var t.2
@checkCellBounds:
        ; reserve space for local variables
        sub rsp, 1
        ; 36:21 return row > 0 && row < 20 && column > 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), row(0@argument,i16)
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; copy t.2(2@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @and_next_8
        jz @and_next_8
        ; 
        ; const r.0(0@register,i16), 20
        ld r1, 20
        ld r0, 0
        ; copy r.1(1@register,i16), row(0@argument,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; copy t.2(2@function,bool), r.0(0@register,bool)
@and_next_8:
        ; copy r.0(0@register,bool), t.2(2@function,bool)
        ; branch r.0(0@register,bool), false, @and_next_7
        jz @and_next_7
        ; 
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), column(1@argument,i16)
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; copy t.2(2@function,bool), r.0(0@register,bool)
@and_next_7:
        ; copy r.0(0@register,bool), t.2(2@function,bool)
        ; branch r.0(0@register,bool), false, @and_next_6
        jz @and_next_6
        ; 
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; copy r.1(1@register,i16), column(1@argument,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; copy t.2(2@function,bool), r.0(0@register,bool)
@and_next_6:
        ; copy r.0(0@register,bool), t.2(2@function,bool)
        ; ret r.0(0@register,bool)
        ; release space for local variables
        add rsp, 1
        ret

        ; void setCell
        ;   rsp+1: arg row
        ;   rsp+2: arg column
        ;   rsp+2: arg cell
@setCell:
        ; call r.0(0@register,i16), rowColumnToCell, [row(0@argument,i16), column(1@argument,i16)]
        ; array r.0(0@register,u8*), field(0@global,u8*) + r.0(0@register,i16)
        ; copy r.1(1@register,u8), cell(2@argument,u8)
        ; store [r.0(0@register,u8*)], r.1(1@register,u8)
        ret

        ; u8 getBombCountAround
        ;   rsp+2: arg row
        ;   rsp+2: arg column
        ;   rsp+0: var count
        ;   rsp+1: var dr
        ;   rsp+3: var r
        ;   rsp+5: var dc
        ;   rsp+7: var c
@getBombCountAround:
        ; reserve space for local variables
        sub rsp, 9
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; const r.1(1@register,i16), -1
        ld r5, 255
        ld r4, 255
        ; 45:2 for dr <= 1
        ; copy count(2@function,u8), r.0(0@register,u8)
        ; copy dr(3@function,i16), r.1(1@register,i16)
@for_9:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dr(3@function,i16)
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @for_9_break
        jz @for_9_break
        ; @for_9_body
        ; copy r.0(0@register,i16), row(0@argument,i16)
        ; copy r.1(1@register,i16), dr(3@function,i16)
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; const r.3(3@register,i16), -1
        ld r13, 255
        ld r12, 255
        ; 47:3 for dc <= 1
        ; copy r(4@function,i16), r.2(2@register,i16)
        ; copy dc(5@function,i16), r.3(3@register,i16)
@for_10:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dc(5@function,i16)
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @for_9_continue
        jz @for_9_continue
        ; 
        ; copy r.0(0@register,i16), column(1@argument,i16)
        ; copy r.1(1@register,i16), dc(5@function,i16)
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; copy c(6@function,i16), r.2(2@register,i16)
        ; call r.0(0@register,bool), checkCellBounds, [r(4@function,i16), r.2(2@register,i16)]
        ; branch r.0(0@register,bool), false, @for_10_continue
        jz @for_10_continue
        ; 
        ; call r.0(0@register,u8), getCell, [r(4@function,i16), c(6@function,i16)]
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; call r.0(0@register,bool), isBomb, [r.0(0@register,u8)]
        ; branch r.0(0@register,bool), false, @for_10_continue
        jz @for_10_continue
        ; 
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), count(2@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy count(2@function,u8), r.0(0@register,u8)
@for_10_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dc(5@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy dc(5@function,i16), r.0(0@register,i16)
        ; jump @for_10
        jmp @for_10
@for_9_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dr(3@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy dr(3@function,i16), r.0(0@register,i16)
        ; jump @for_9
        jmp @for_9
@for_9_break:
        ; 57:9 return count
        ; copy r.0(0@register,u8), count(2@function,u8)
        ; ret r.0(0@register,u8)
        ; release space for local variables
        add rsp, 9
        ret

        ; u8 getSpacer
        ;   rsp+2: arg row
        ;   rsp+2: arg column
        ;   rsp+2: arg rowCursor
        ;   rsp+2: arg columnCursor
@getSpacer:
        ; 61:2 if rowCursor == row
        ; copy r.0(0@register,i16), rowCursor(2@argument,i16)
        ; copy r.1(1@register,i16), row(0@argument,i16)
        ; equals r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; branch r.0(0@register,bool), false, @if_13_end
        jz @if_13_end
        ; 
        ; 62:3 if columnCursor == column
        ; copy r.0(0@register,i16), columnCursor(3@argument,i16)
        ; copy r.1(1@register,i16), column(1@argument,i16)
        ; equals r.2(2@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; branch r.2(2@register,bool), false, @if_14_end
        jz @if_14_end
        ; 
        ; 63:11 return 91
        ; const r.0(0@register,u8), 91
        ld r0, 91
        ; ret r.0(0@register,u8)
        ; jump @getSpacer_ret
        jmp @getSpacer_ret
@if_14_end:
        ; 65:3 if columnCursor == column - 1
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), column(1@argument,i16)
        ; sub r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy r.1(1@register,i16), columnCursor(3@argument,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_13_end
        jz @if_13_end
        ; 
        ; 66:11 return 93
        ; const r.0(0@register,u8), 93
        ld r0, 93
        ; ret r.0(0@register,u8)
        ; jump @getSpacer_ret
        jmp @getSpacer_ret
@if_13_end:
        ; 69:9 return 32
        ; const r.0(0@register,u8), 32
        ld r0, 32
        ; ret r.0(0@register,u8)
@getSpacer_ret:
        ret

        ; void printCell
        ;   rsp+2: arg cell
        ;   rsp+2: arg row
        ;   rsp+1: arg column
        ;   rsp+0: var chr
        ;   rsp+1: var count
@printCell:
        ; reserve space for local variables
        sub rsp, 2
        ; const r.0(0@register,u8), 46
        ld r0, 46
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; copy chr(3@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,bool), isOpen, [cell(0@argument,u8)]
        ; branch r.0(0@register,bool), false, @if_16_else
        jz @if_16_else
        ; 
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; call r.0(0@register,bool), isBomb, [cell(0@argument,u8)]
        ; branch r.0(0@register,bool), false, @if_17_else
        jz @if_17_else
        ; 
        ; const r.0(0@register,u8), 42
        ld r0, 42
        ; copy chr(3@function,u8), r.0(0@register,u8)
        ; jump @if_16_end
        jmp @if_16_end
@if_17_else:
        ; call r.0(0@register,u8), getBombCountAround, [row(1@argument,i16), column(2@argument,i16)]
        ; 80:4 if count > 0
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; gt r.1(1@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; copy count(4@function,u8), r.0(0@register,u8)
        ; branch r.1(1@register,bool), false, @if_18_else
        jz @if_18_else
        ; @if_18_then
        ; const r.0(0@register,u8), 48
        ld r0, 48
        ; copy r.1(1@register,u8), count(4@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; copy chr(3@function,u8), r.0(0@register,u8)
        ; jump @if_16_end
        jmp @if_16_end
@if_18_else:
        ; const r.0(0@register,u8), 32
        ld r0, 32
        ; copy chr(3@function,u8), r.0(0@register,u8)
        ; jump @if_16_end
        jmp @if_16_end
@if_16_else:
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; call r.0(0@register,bool), isFlag, [cell(0@argument,u8)]
        ; branch r.0(0@register,bool), false, @if_16_end
        jz @if_16_end
        ; 
        ; const r.0(0@register,u8), 35
        ld r0, 35
        ; copy chr(3@function,u8), r.0(0@register,u8)
@if_16_end:
        ; call _, printChar [chr(3@function,u8)]
        ; release space for local variables
        add rsp, 2
        ret

        ; void printField
        ;   rsp+2: arg rowCursor
        ;   rsp+2: arg columnCursor
        ;   rsp+0: var row
        ;   rsp+2: var column
@printField:
        ; reserve space for local variables
        sub rsp, 4
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; call _, setCursor [r.0(0@register,u8), r.1(1@register,u8)]
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; 96:2 for row < 20
        ; copy row(2@function,i16), r.0(0@register,i16)
@for_20:
        ; const r.0(0@register,i16), 20
        ld r1, 20
        ld r0, 0
        ; copy r.1(1@register,i16), row(2@function,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @printField_ret
        jz @printField_ret
        ; 
        ; const r.0(0@register,u8), 124
        ld r0, 124
        ; call _, printChar [r.0(0@register,u8)]
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; 98:3 for column < 40
        ; copy column(3@function,i16), r.0(0@register,i16)
@for_21:
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; copy r.1(1@register,i16), column(3@function,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @for_21_break
        jz @for_21_break
        ; @for_21_body
        ; call r.0(0@register,u8), getSpacer, [row(2@function,i16), column(3@function,i16), rowCursor(0@argument,i16), columnCursor(1@argument,i16)]
        ; call _, printChar [r.0(0@register,u8)]
        ; call r.0(0@register,u8), getCell, [row(2@function,i16), column(3@function,i16)]
        ; call _, printCell [r.0(0@register,u8), row(2@function,i16), column(3@function,i16)]
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), column(3@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy column(3@function,i16), r.0(0@register,i16)
        ; jump @for_21
        jmp @for_21
@for_21_break:
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; call r.0(0@register,u8), getSpacer, [row(2@function,i16), r.0(0@register,i16), rowCursor(0@argument,i16), columnCursor(1@argument,i16)]
        ; call _, printChar [r.0(0@register,u8)]
        ; const r.0(0@register,u8*), [string-0]
        ; call _, printString [r.0(0@register,u8*)]
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), row(2@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy row(2@function,i16), r.0(0@register,i16)
        ; jump @for_20
        jmp @for_20
@printField_ret:
        ; release space for local variables
        add rsp, 4
        ret

        ; void printSpaces
        ;   rsp+2: arg i
@printSpaces:
@for_22:
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), i(0@argument,i16)
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @printSpaces_ret
        jz @printSpaces_ret
        ; 
        ; const r.0(0@register,u8), 48
        ld r0, 48
        ; call _, printChar [r.0(0@register,u8)]
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), i(0@argument,i16)
        ; sub r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy i(0@argument,i16), r.0(0@register,i16)
        ; jump @for_22
        jmp @for_22
@printSpaces_ret:
        ret

        ; u8 getDigitCount
        ;   rsp+2: arg value
        ;   rsp+0: var count
@getDigitCount:
        ; reserve space for local variables
        sub rsp, 1
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; 118:2 if value < 0
        ; const r.1(1@register,i16), 0
        ld r5, 0
        ld r4, 0
        ; copy r.2(2@register,i16), value(0@argument,i16)
        ; lt r.1(1@register,bool), r.2(2@register,i16), r.1(1@register,i16)
        ; copy count(1@function,u8), r.0(0@register,u8)
        ; branch r.1(1@register,bool), false, @while_24
        jz @while_24
        ; 
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,i16), value(0@argument,i16)
        ; neg r.1(1@register,i16), r.1(1@register,i16)
        ; copy count(1@function,u8), r.0(0@register,u8)
        ; copy value(0@argument,i16), r.1(1@register,i16)
@while_24:
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; copy r.1(1@register,u8), count(1@function,u8)
        ; add r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; const r.1(1@register,i16), 10
        ld r5, 10
        ld r4, 0
        ; copy r.2(2@register,i16), value(0@argument,i16)
        ; div r.1(1@register,i16), r.2(2@register,i16), r.1(1@register,i16)
        ; 126:3 if value == 0
        ; const r.2(2@register,i16), 0
        ld r9, 0
        ld r8, 0
        ; equals r.2(2@register,bool), r.1(1@register,i16), r.2(2@register,i16)
        ; copy count(1@function,u8), r.0(0@register,u8)
        ; copy value(0@argument,i16), r.1(1@register,i16)
        ; branch r.2(2@register,bool), false, @while_24
        jz @while_24
        ; 
        ; 131:9 return count
        ; copy r.0(0@register,u8), count(1@function,u8)
        ; ret r.0(0@register,u8)
        ; release space for local variables
        add rsp, 1
        ret

        ; bool printLeft
        ;   rsp+0: var count
        ;   rsp+2: var r
        ;   rsp+4: var c
        ;   rsp+6: var leftDigits
        ;   rsp+7: var bombDigits
@printLeft:
        ; reserve space for local variables
        sub rsp, 8
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; const r.1(1@register,i16), 0
        ld r5, 0
        ld r4, 0
        ; 136:2 for r < 20
        ; copy count(0@function,i16), r.0(0@register,i16)
        ; copy r(1@function,i16), r.1(1@register,i16)
@for_26:
        ; const r.0(0@register,i16), 20
        ld r1, 20
        ld r0, 0
        ; copy r.1(1@register,i16), r(1@function,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @for_26_break
        jz @for_26_break
        ; @for_26_body
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; 137:3 for c < 40
        ; copy c(2@function,i16), r.0(0@register,i16)
@for_27:
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; copy r.1(1@register,i16), c(2@function,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @for_26_continue
        jz @for_26_continue
        ; 
        ; call r.0(0@register,u8), getCell, [r(1@function,i16), c(2@function,i16)]
        ; 139:4 if cell & 6 == 0
        ; const r.1(1@register,u8), 6
        ld r4, 6
        ; and r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; equals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @for_27_continue
        jz @for_27_continue
        ; 
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), count(0@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy count(0@function,i16), r.0(0@register,i16)
@for_27_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), c(2@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy c(2@function,i16), r.0(0@register,i16)
        ; jump @for_27
        jmp @for_27
@for_26_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), r(1@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy r(1@function,i16), r.0(0@register,i16)
        ; jump @for_26
        jmp @for_26
@for_26_break:
        ; call r.0(0@register,u8), getDigitCount, [count(0@function,i16)]
        ; const r.1(1@register,i16), 40
        ld r5, 40
        ld r4, 0
        ; copy leftDigits(3@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,u8), getDigitCount, [r.1(1@register,i16)]
        ; const r.1(1@register,u8*), [string-1]
        ; copy bombDigits(4@function,u8), r.0(0@register,u8)
        ; call _, printString [r.1(1@register,u8*)]
        ; copy r.0(0@register,u8), bombDigits(4@function,u8)
        ; copy r.1(1@register,u8), leftDigits(3@function,u8)
        ; sub r.0(0@register,u8), r.0(0@register,u8), r.1(1@register,u8)
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; call _, printSpaces [r.0(0@register,i16)]
        ; call _, printUint [count(0@function,i16)]
        ; 150:15 return count == 0
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), count(0@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; ret r.0(0@register,bool)
        ; release space for local variables
        add rsp, 8
        ret

        ; i16 abs
        ;   rsp+2: arg a
@abs:
        ; 154:2 if a < 0
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), a(0@argument,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_29_end
        jz @if_29_end
        ; @if_29_then
        ; 155:10 return -a
        ; copy r.0(0@register,i16), a(0@argument,i16)
        ; neg r.0(0@register,i16), r.0(0@register,i16)
        ; ret r.0(0@register,i16)
        ; jump @abs_ret
        jmp @abs_ret
@if_29_end:
        ; 157:9 return a
        ; copy r.0(0@register,i16), a(0@argument,i16)
        ; ret r.0(0@register,i16)
@abs_ret:
        ret

        ; void clearField
        ;   rsp+0: var r
        ;   rsp+2: var c
@clearField:
        ; reserve space for local variables
        sub rsp, 4
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; 161:2 for r < 20
        ; copy r(0@function,i16), r.0(0@register,i16)
@for_30:
        ; const r.0(0@register,i16), 20
        ld r1, 20
        ld r0, 0
        ; copy r.1(1@register,i16), r(0@function,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @clearField_ret
        jz @clearField_ret
        ; 
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; 162:3 for c < 40
        ; copy c(1@function,i16), r.0(0@register,i16)
@for_31:
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; copy r.1(1@register,i16), c(1@function,i16)
        ; lt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @for_30_continue
        jz @for_30_continue
        ; 
        ; const r.0(0@register,u8), 0
        ld r0, 0
        ; call _, setCell [r(0@function,i16), c(1@function,i16), r.0(0@register,u8)]
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), c(1@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy c(1@function,i16), r.0(0@register,i16)
        ; jump @for_31
        jmp @for_31
@for_30_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), r(0@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy r(0@function,i16), r.0(0@register,i16)
        ; jump @for_30
        jmp @for_30
@clearField_ret:
        ; release space for local variables
        add rsp, 4
        ret

        ; void initField
        ;   rsp+2: arg curr_r
        ;   rsp+2: arg curr_c
        ;   rsp+0: var bombs
        ;   rsp+2: var row
        ;   rsp+4: var column
        ;   rsp+6: var t.13
@initField:
        ; reserve space for local variables
        sub rsp, 7
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; 169:2 for bombs > 0
        ; copy bombs(2@function,i16), r.0(0@register,i16)
@for_32:
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), bombs(2@function,i16)
        ; gt r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @initField_ret
        jz @initField_ret
        ; 
        ; call r.0(0@register,i32), random, []
        ; const r.1(1@register,i32), 20
        ld r7, 20
        ld r6, 0
        ld r5, 0
        ld r4, 0
        ; mod r.0(0@register,i32), r.0(0@register,i32), r.1(1@register,i32)
        ; cast r.0(0@register,i16), r.0(0@register,i32)
        ; copy row(3@function,i16), r.0(0@register,i16)
        ; call r.0(0@register,i32), random, []
        ; const r.1(1@register,i32), 40
        ld r7, 40
        ld r6, 0
        ld r5, 0
        ld r4, 0
        ; mod r.0(0@register,i32), r.0(0@register,i32), r.1(1@register,i32)
        ; cast r.0(0@register,i16), r.0(0@register,i32)
        ; 172:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=172:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=172:20], location=172:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=173:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=173:20], location=173:18]]) > 1
        ; 173:4 logic or
        ; copy r.1(1@register,i16), row(3@function,i16)
        ; copy r.2(2@register,i16), curr_r(0@argument,i16)
        ; sub r.3(3@register,i16), r.1(1@register,i16), r.2(2@register,i16)
        ; copy column(4@function,i16), r.0(0@register,i16)
        ; call r.0(0@register,i16), abs, [r.3(3@register,i16)]
        ; const r.1(1@register,i16), 1
        ld r5, 1
        ld r4, 0
        ; gt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; copy t.13(5@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), true, @or_next_34
        jnz @or_next_34
        ; 
        ; copy r.0(0@register,i16), column(4@function,i16)
        ; copy r.1(1@register,i16), curr_c(1@argument,i16)
        ; sub r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; call r.0(0@register,i16), abs, [r.2(2@register,i16)]
        ; const r.1(1@register,i16), 1
        ld r5, 1
        ld r4, 0
        ; gt r.0(0@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; copy t.13(5@function,bool), r.0(0@register,bool)
@or_next_34:
        ; copy r.0(0@register,bool), t.13(5@function,bool)
        ; branch r.0(0@register,bool), false, @for_32_continue
        jz @for_32_continue
        ; 
        ; const r.0(0@register,u8), 1
        ld r0, 1
        ; call _, setCell [row(3@function,i16), column(4@function,i16), r.0(0@register,u8)]
@for_32_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), bombs(2@function,i16)
        ; sub r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy bombs(2@function,i16), r.0(0@register,i16)
        ; jump @for_32
        jmp @for_32
@initField_ret:
        ; release space for local variables
        add rsp, 7
        ret

        ; void maybeRevealAround
        ;   rsp+2: arg row
        ;   rsp+2: arg column
        ;   rsp+0: var dr
        ;   rsp+2: var r
        ;   rsp+4: var dc
        ;   rsp+6: var c
        ;   rsp+8: var cell
        ;   rsp+9: var t.14
@maybeRevealAround:
        ; reserve space for local variables
        sub rsp, 10
        ; 180:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=180:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=180:30]]) != 0
        ; call r.0(0@register,u8), getBombCountAround, [row(0@argument,i16), column(1@argument,i16)]
        ; const r.1(1@register,u8), 0
        ld r4, 0
        ; notequals r.0(0@register,bool), r.0(0@register,u8), r.1(1@register,u8)
        ; branch r.0(0@register,bool), false, @if_35_end
        jz @if_35_end
        ; @if_35_then
        ; jump @maybeRevealAround_ret
        jmp @maybeRevealAround_ret
@if_35_end:
        ; const r.0(0@register,i16), -1
        ld r1, 255
        ld r0, 255
        ; 184:2 for dr <= 1
        ; copy dr(2@function,i16), r.0(0@register,i16)
@for_36:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dr(2@function,i16)
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @maybeRevealAround_ret
        jz @maybeRevealAround_ret
        ; 
        ; copy r.0(0@register,i16), row(0@argument,i16)
        ; copy r.1(1@register,i16), dr(2@function,i16)
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; const r.3(3@register,i16), -1
        ld r13, 255
        ld r12, 255
        ; 186:3 for dc <= 1
        ; copy r(3@function,i16), r.2(2@register,i16)
        ; copy dc(4@function,i16), r.3(3@register,i16)
@for_37:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dc(4@function,i16)
        ; lteq r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @for_36_continue
        jz @for_36_continue
        ; 
        ; 187:4 if dr == 0 && dc == 0
        ; 187:16 logic and
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), dr(2@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; copy t.14(7@function,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @and_next_39
        jz @and_next_39
        ; 
        ; const r.0(0@register,i16), 0
        ld r1, 0
        ld r0, 0
        ; copy r.1(1@register,i16), dc(4@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; copy t.14(7@function,bool), r.0(0@register,bool)
@and_next_39:
        ; copy r.0(0@register,bool), t.14(7@function,bool)
        ; branch r.0(0@register,bool), false, @if_38_end
        jz @if_38_end
        ; 
        ; jump @for_37_continue
        jmp @for_37_continue
@if_38_end:
        ; copy r.0(0@register,i16), column(1@argument,i16)
        ; copy r.1(1@register,i16), dc(4@function,i16)
        ; add r.2(2@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; 192:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=192:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=192:28]])
        ; copy c(5@function,i16), r.2(2@register,i16)
        ; call r.0(0@register,bool), checkCellBounds, [r(3@function,i16), r.2(2@register,i16)]
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @if_40_end
        jz @if_40_end
        ; 
        ; jump @for_37_continue
        jmp @for_37_continue
@if_40_end:
        ; call r.0(0@register,u8), getCell, [r(3@function,i16), c(5@function,i16)]
        ; 197:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=197:15]])
        ; copy cell(6@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,bool), isOpen, [r.0(0@register,u8)]
        ; branch r.0(0@register,bool), false, @if_41_end
        jz @if_41_end
        ; @if_41_then
        ; jump @for_37_continue
        jmp @for_37_continue
@if_41_end:
        ; const r.0(0@register,u8), 2
        ld r0, 2
        ; copy r.1(1@register,u8), cell(6@function,u8)
        ; or r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; call _, setCell [r(3@function,i16), c(5@function,i16), r.0(0@register,u8)]
        ; call _, maybeRevealAround [r(3@function,i16), c(5@function,i16)]
@for_37_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dc(4@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy dc(4@function,i16), r.0(0@register,i16)
        ; jump @for_37
        jmp @for_37
@for_36_continue:
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), dr(2@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; copy dr(2@function,i16), r.0(0@register,i16)
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
        ; const r.0(0@register,i32), 7439742
        ld r3, 126
        ld r2, 133
        ld r1, 113
        ld r0, 0
        ; call _, initRandom [r.0(0@register,i32)]
        ; const r.0(0@register,bool), 1
        ld r0, 1
        ; copy needsInitialize(0@function,bool), r.0(0@register,bool)
        ; call _, clearField []
        ; const r.0(0@register,u8), 20
        ld r0, 20
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; const r.1(1@register,u8), 10
        ld r4, 10
        ; cast r.1(1@register,i16), r.1(1@register,u8)
        ; 213:2 while true
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        ; copy curr_r(2@function,i16), r.1(1@register,i16)
@while_42:
        ; call _, printField [curr_r(2@function,i16), curr_c(1@function,i16)]
        ; 215:3 if !needsInitialize
        ; copy r.0(0@register,bool), needsInitialize(0@function,bool)
        ; notlog r.1(1@register,bool), r.0(0@register,bool)
        ; branch r.1(1@register,bool), false, @if_43_end
        jz @if_43_end
        ; 
        ; 216:4 if printLeft([])
        ; call r.0(0@register,bool), printLeft, []
        ; branch r.0(0@register,bool), false, @if_43_end
        jz @if_43_end
        ; 
        ; const r.0(0@register,u8*), [string-2]
        ; call _, printString [r.0(0@register,u8*)]
        ; jump @main_ret
        jmp @main_ret
@if_43_end:
        ; call r.0(0@register,u8), getChar, []
        ; cast r.0(0@register,i16), r.0(0@register,u8)
        ; 223:3 if chr == 27
        ; const r.1(1@register,i16), 27
        ld r5, 27
        ld r4, 0
        ; equals r.1(1@register,bool), r.0(0@register,i16), r.1(1@register,i16)
        ; copy chr(3@function,i16), r.0(0@register,i16)
        ; branch r.1(1@register,bool), false, @if_45_end
        jz @if_45_end
        ; 
        ; jump @main_ret
        jmp @main_ret
@if_45_end:
        ; 228:3 if chr == 57416
        ; const r.0(0@register,i16), 57416
        ld r1, 72
        ld r0, 224
        ; copy r.1(1@register,i16), chr(3@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_46_else
        jz @if_46_else
        ; 
        ; const r.0(0@register,i16), 20
        ld r1, 20
        ld r0, 0
        ; copy r.1(1@register,i16), curr_r(2@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; const r.1(1@register,i16), 1
        ld r5, 1
        ld r4, 0
        ; sub r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; const r.1(1@register,i16), 20
        ld r5, 20
        ld r4, 0
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; copy curr_r(2@function,i16), r.0(0@register,i16)
        ; jump @while_42
        jmp @while_42
@if_46_else:
        ; 232:8 if chr == 57424
        ; const r.0(0@register,i16), 57424
        ld r1, 80
        ld r0, 224
        ; copy r.1(1@register,i16), chr(3@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_47_else
        jz @if_47_else
        ; 
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), curr_r(2@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; const r.1(1@register,i16), 20
        ld r5, 20
        ld r4, 0
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; copy curr_r(2@function,i16), r.0(0@register,i16)
        ; jump @while_42
        jmp @while_42
@if_47_else:
        ; 236:8 if chr == 57419
        ; const r.0(0@register,i16), 57419
        ld r1, 75
        ld r0, 224
        ; copy r.1(1@register,i16), chr(3@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_48_else
        jz @if_48_else
        ; 
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; copy r.1(1@register,i16), curr_c(1@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; const r.1(1@register,i16), 1
        ld r5, 1
        ld r4, 0
        ; sub r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; const r.1(1@register,i16), 40
        ld r5, 40
        ld r4, 0
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        ; jump @while_42
        jmp @while_42
@if_48_else:
        ; 240:8 if chr == 57419
        ; const r.0(0@register,i16), 57419
        ld r1, 75
        ld r0, 224
        ; copy r.1(1@register,i16), chr(3@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_49_else
        jz @if_49_else
        ; 
        ; const r.0(0@register,i16), 40
        ld r1, 40
        ld r0, 0
        ; copy r.1(1@register,i16), curr_c(1@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; const r.1(1@register,i16), 1
        ld r5, 1
        ld r4, 0
        ; sub r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; const r.1(1@register,i16), 40
        ld r5, 40
        ld r4, 0
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        ; jump @while_42
        jmp @while_42
@if_49_else:
        ; 244:8 if chr == 57421
        ; const r.0(0@register,i16), 57421
        ld r1, 77
        ld r0, 224
        ; copy r.1(1@register,i16), chr(3@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_50_else
        jz @if_50_else
        ; 
        ; const r.0(0@register,i16), 1
        ld r1, 1
        ld r0, 0
        ; copy r.1(1@register,i16), curr_c(1@function,i16)
        ; add r.0(0@register,i16), r.1(1@register,i16), r.0(0@register,i16)
        ; const r.1(1@register,i16), 40
        ld r5, 40
        ld r4, 0
        ; mod r.0(0@register,i16), r.0(0@register,i16), r.1(1@register,i16)
        ; copy curr_c(1@function,i16), r.0(0@register,i16)
        ; jump @while_42
        jmp @while_42
@if_50_else:
        ; 248:8 if chr == 32
        ; const r.0(0@register,i16), 32
        ld r1, 32
        ld r0, 0
        ; copy r.1(1@register,i16), chr(3@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @if_51_else
        jz @if_51_else
        ; 
        ; 249:4 if !needsInitialize
        ; copy r.0(0@register,bool), needsInitialize(0@function,bool)
        ; notlog r.1(1@register,bool), r.0(0@register,bool)
        ; branch r.1(1@register,bool), false, @while_42
        jz @while_42
        ; 
        ; call r.0(0@register,u8), getCell, [curr_r(2@function,i16), curr_c(1@function,i16)]
        ; 251:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=251:17]])
        ; copy cell(4@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,bool), isOpen, [r.0(0@register,u8)]
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @while_42
        jz @while_42
        ; 
        ; const r.0(0@register,u8), 4
        ld r0, 4
        ; copy r.1(1@register,u8), cell(4@function,u8)
        ; xor r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; call _, setCell [curr_r(2@function,i16), curr_c(1@function,i16), r.0(0@register,u8)]
        ; jump @while_42
        jmp @while_42
@if_51_else:
        ; 257:8 if chr == 13
        ; const r.0(0@register,i16), 13
        ld r1, 13
        ld r0, 0
        ; copy r.1(1@register,i16), chr(3@function,i16)
        ; equals r.0(0@register,bool), r.1(1@register,i16), r.0(0@register,i16)
        ; branch r.0(0@register,bool), false, @while_42
        jz @while_42
        ; 
        ; copy r.0(0@register,bool), needsInitialize(0@function,bool)
        ; branch r.0(0@register,bool), false, @if_55_end
        jz @if_55_end
        ; 
        ; const r.0(0@register,bool), 0
        ld r0, 0
        ; copy needsInitialize(0@function,bool), r.0(0@register,bool)
        ; call _, initField [curr_r(2@function,i16), curr_c(1@function,i16)]
@if_55_end:
        ; call r.0(0@register,u8), getCell, [curr_r(2@function,i16), curr_c(1@function,i16)]
        ; 263:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=263:16]])
        ; copy cell(5@function,u8), r.0(0@register,u8)
        ; call r.0(0@register,bool), isOpen, [r.0(0@register,u8)]
        ; notlog r.0(0@register,bool), r.0(0@register,bool)
        ; branch r.0(0@register,bool), false, @if_56_end
        jz @if_56_end
        ; 
        ; const r.0(0@register,u8), 2
        ld r0, 2
        ; copy r.1(1@register,u8), cell(5@function,u8)
        ; or r.0(0@register,u8), r.1(1@register,u8), r.0(0@register,u8)
        ; call _, setCell [curr_r(2@function,i16), curr_c(1@function,i16), r.0(0@register,u8)]
@if_56_end:
        ; 266:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=266:15]])
        ; call r.0(0@register,bool), isBomb, [cell(5@function,u8)]
        ; branch r.0(0@register,bool), false, @if_57_end
        jz @if_57_end
        ; @if_57_then
        ; call _, printField [curr_r(2@function,i16), curr_c(1@function,i16)]
        ; const r.0(0@register,u8*), [string-3]
        ; call _, printString [r.0(0@register,u8*)]
        ; jump @main_ret
        jmp @main_ret
@if_57_end:
        ; call _, maybeRevealAround [curr_r(2@function,i16), curr_c(1@function,i16)]
        ; jump @while_42
        jmp @while_42
@main_ret:
        ; release space for local variables
        add rsp, 9
        ret

        ; variable 0: field (6400)
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

