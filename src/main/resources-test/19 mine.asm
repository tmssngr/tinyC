format pe64 console
include 'win64ax.inc'

STD_IN_HANDLE = -10
STD_OUT_HANDLE = -11
STD_ERR_HANDLE = -12

entry start

section '.text' code readable executable

start:
        ; alignment
        and rsp, -16
        call init
        call @main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printString
        ;   rsp+16: arg str
@printString:
        ; save globbered non-volatile registers
        push rbx
        ; move r6, r1
        mov rbx, rcx
        ; move r1, r6
        mov rcx, rbx
        ; call r0, strlen, [r1]
        sub rsp, 20h; shadow space
        call @strlen
        add rsp, 20h
        ; move r1, r6
        mov rcx, rbx
        ; move r2, r0
        mov rdx, rax
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; void printChar
        ;   rsp+16: arg chr
@printChar:
        ; save globbered non-volatile registers
        push rbx
        ; addrof r6, chr
        lea rbx, [rsp+16]
        ; const r2, 1
        mov rdx, 1
        ; move chr, r1
        lea r11, [rsp+16]
        mov [r11], cl
        ; move r1, r6
        mov rcx, rbx
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; void printUint
        ;   rsp+48: arg number
        ;   rsp+20: var buffer
@printUint:
        sub rsp, 24
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov rbx, rcx
        ; const r7, 20
        mov r12b, 20
        ; 13:2 while true
@while_1:
        ; const r3, 1
        mov r8b, 1
        ; sub r7, r7, r3
        sub r12b, r8b
        ; const r3, 10
        mov r8, 10
        ; move r4, r6
        mov r9, rbx
        ; move r0, r4
        mov rax, r9
        ; mod r2, r0, r3
        cqo
        idiv r8
        ; move r4, r2
        mov r9, rdx
        ; const r3, 10
        mov r8, 10
        ; move r0, r6
        mov rax, rbx
        ; div r0, r0, r3
        cqo
        idiv r8
        ; move r6, r0
        mov rbx, rax
        ; cast r0(u8), r4(i64)
        mov al, r9b
        ; const r3, 48
        mov r8b, 48
        ; add r0, r0, r3
        add al, r8b
        ; cast r3(i64), r7(u8)
        movzx r8, r12b
        ; cast r3(u8*), r3(i64)
        ; addrof r4, [buffer]
        lea r9, [rsp+20]
        ; add r4, r4, r3
        add r9, r8
        ; store [r4], r0
        mov [r9], al
        ; 19:3 if number == 0
        ; const r0, 0
        mov rax, 0
        ; equals r0, r6, r0
        cmp rbx, rax
        sete al
        ; branch r0, false, @while_1
        or al, al
        jz @while_1
        ; cast r6(i64), r7(u8)
        movzx rbx, r12b
        ; cast r6(u8*), r6(i64)
        ; addrof r1, [buffer]
        lea rcx, [rsp+20]
        ; add r1, r1, r6
        add rcx, rbx
        ; const r6, 20
        mov bl, 20
        ; sub r6, r6, r7
        sub bl, r12b
        ; cast r2(i64), r6(u8)
        movzx rdx, bl
        ; call _, printStringLength [r1, r2]
        sub rsp, 20h; shadow space
        call @printStringLength
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; i64 strlen
        ;   rsp+16: arg str
@strlen:
        sub rsp, 8
        ; const r0, 0
        mov rax, 0
        ; 37:2 for *str != 0
        jmp @for_3
@for_3_body:
        ; const r2, 1
        mov rdx, 1
        ; add r0, r0, r2
        add rax, rdx
        ; cast r2(i64), r1(u8*)
        mov rdx, rcx
        ; const r3, 1
        mov r8, 1
        ; add r2, r2, r3
        add rdx, r8
        ; cast r1(u8*), r2(i64)
        mov rcx, rdx
@for_3:
        ; load r2, [r1]
        mov dl, [rcx]
        ; const r3, 0
        mov r8b, 0
        ; notequals r2, r2, r3
        cmp dl, r8b
        setne dl
        ; branch r2, true, @for_3_body
        or dl, dl
        jnz @for_3_body
        ; 40:9 return length
        add rsp, 8
        ret

        ; void initRandom
        ;   rsp+16: arg salt
@initRandom:
        sub rsp, 8
        ; move r0, r1
        mov eax, ecx
        ; move __random__, r0
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i32 random
@random:
        sub rsp, 8
        ; move r0, __random__
        lea r11, [var_0]
        mov eax, [r11]
        ; move r2, r0
        mov edx, eax
        ; const r3, 524287
        mov r8d, 524287
        ; move r4, r2
        mov r9d, edx
        ; and r4, r4, r3
        and r9d, r8d
        ; const r3, 48271
        mov r8d, 48271
        ; mul r4, r4, r3
        movsxd r9, r9d
        movsxd r8, r8d
        imul  r9, r8
        ; const r1, 15
        mov ecx, 15
        ; shiftright r2, r2, r1
        sar edx, cl
        ; const r3, 48271
        mov r8d, 48271
        ; mul r2, r2, r3
        movsxd rdx, edx
        movsxd r8, r8d
        imul  rdx, r8
        ; const r3, 65535
        mov r8d, 65535
        ; move r5, r2
        mov r10d, edx
        ; and r5, r5, r3
        and r10d, r8d
        ; const r1, 15
        mov ecx, 15
        ; move r3, r5
        mov r8d, r10d
        ; shiftleft r3, r3, r1
        sal r8d, cl
        ; const r1, 16
        mov ecx, 16
        ; shiftright r2, r2, r1
        sar edx, cl
        ; add r2, r2, r4
        add edx, r9d
        ; add r2, r2, r3
        add edx, r8d
        ; const r3, 2147483647
        mov r8d, 2147483647
        ; move r4, r2
        mov r9d, edx
        ; and r4, r4, r3
        and r9d, r8d
        ; const r1, 31
        mov ecx, 31
        ; shiftright r2, r2, r1
        sar edx, cl
        ; move r0, r4
        mov eax, r9d
        ; add r0, r0, r2
        add eax, edx
        ; 123:9 return __random__
        ; move __random__, r0
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i16 rowColumnToCell
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@rowColumnToCell:
        sub rsp, 8
        ; 15:21 return row * 40 + column
        ; const r3, 40
        mov r8w, 40
        ; mul r1, r1, r3
        movsx rcx, cx
        movsx r8, r8w
        imul  rcx, r8
        ; move r0, r1
        mov ax, cx
        ; add r0, r0, r2
        add ax, dx
        add rsp, 8
        ret

        ; u8 getCell
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@getCell:
        sub rsp, 8
        ; 19:15 return [...]
        ; call r0, rowColumnToCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @rowColumnToCell
        add rsp, 20h
        ; cast r1(i64), r0(i16)
        movzx rcx, ax
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [field]
        lea rdx, [var_1]
        ; add r2, r2, r1
        add rdx, rcx
        ; load r0, [r2]
        mov al, [rdx]
        add rsp, 8
        ret

        ; bool isBomb
        ;   rsp+16: arg cell
@isBomb:
        sub rsp, 8
        ; 23:27 return cell & 1 != 0
        ; const r2, 1
        mov dl, 1
        ; and r1, r1, r2
        and cl, dl
        ; const r2, 0
        mov dl, 0
        ; notequals r0, r1, r2
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool isOpen
        ;   rsp+16: arg cell
@isOpen:
        sub rsp, 8
        ; 27:27 return cell & 2 != 0
        ; const r2, 2
        mov dl, 2
        ; and r1, r1, r2
        and cl, dl
        ; const r2, 0
        mov dl, 0
        ; notequals r0, r1, r2
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool isFlag
        ;   rsp+16: arg cell
@isFlag:
        sub rsp, 8
        ; 31:27 return cell & 4 != 0
        ; const r2, 4
        mov dl, 4
        ; and r1, r1, r2
        and cl, dl
        ; const r2, 0
        mov dl, 0
        ; notequals r0, r1, r2
        cmp cl, dl
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds
        ;   rsp+16: arg row
        ;   rsp+24: arg column
@checkCellBounds:
        sub rsp, 8
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const r3, 0
        mov r8w, 0
        ; gteq r0, r1, r3
        cmp cx, r8w
        setge al
        ; branch r0, false, @and_next_6
        or al, al
        jz @and_next_6
        ; const r3, 20
        mov r8w, 20
        ; lt r0, r1, r3
        cmp cx, r8w
        setl al
@and_next_6:
        ; branch r0, false, @and_next_5
        or al, al
        jz @and_next_5
        ; const r1, 0
        mov cx, 0
        ; gteq r0, r2, r1
        cmp dx, cx
        setge al
@and_next_5:
        ; branch r0, false, @checkCellBounds_ret
        or al, al
        jz @checkCellBounds_ret
        ; const r1, 40
        mov cx, 40
        ; lt r0, r2, r1
        cmp dx, cx
        setl al
@checkCellBounds_ret:
        add rsp, 8
        ret

        ; void setCell
        ;   rsp+16: arg row
        ;   rsp+24: arg column
        ;   rsp+32: arg cell
@setCell:
        ; save globbered non-volatile registers
        push rbx
        ; move r6, r3
        mov bl, r8b
        ; call r0, rowColumnToCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @rowColumnToCell
        add rsp, 20h
        ; cast r0(i64), r0(i16)
        movzx rax, ax
        ; cast r0(u8*), r0(i64)
        ; addrof r1, [field]
        lea rcx, [var_1]
        ; add r1, r1, r0
        add rcx, rax
        ; store [r1], r6
        mov [rcx], bl
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; u8 getBombCountAround
        ;   rsp+48: arg row
        ;   rsp+56: arg column
        ;   rsp+16: var count
        ;   rsp+18: var dr
        ;   rsp+20: var r
        ;   rsp+22: var dc
        ;   rsp+24: var c
@getBombCountAround:
        sub rsp, 24
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov bx, cx
        ; move r7, r2
        mov r12w, dx
        ; const r0, 0
        mov al, 0
        ; const r3, -1
        mov r8w, -1
        ; 45:2 for dr <= 1
        ; move r2, r3
        mov dx, r8w
        jmp @for_7
@for_7_body:
        ; move r3, r2
        mov r8w, dx
        ; move r4, r6
        mov r9w, bx
        ; add r4, r4, r3
        add r9w, r8w
        ; const r5, -1
        mov r10w, -1
        ; 47:3 for dc <= 1
        ; move dr, r3
        lea r11, [rsp+18]
        mov [r11], r8w
        ; move r, r4
        lea r11, [rsp+20]
        mov [r11], r9w
        ; move r2, r5
        mov dx, r10w
        jmp @for_8
@no_critical_edge_14:
        ; move r5, r2
        mov r10w, dx
        ; move r3, dr
        lea r11, [rsp+18]
        mov r8w, [r11]
        ; move r4, r
        lea r11, [rsp+20]
        mov r9w, [r11]
        ; move r2, r7
        mov dx, r12w
        ; add r2, r2, r5
        add dx, r10w
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; move r1, r4
        mov cx, r9w
        ; move c, r2
        lea r11, [rsp+24]
        mov [r11], dx
        ; move count, r0
        lea r11, [rsp+16]
        mov [r11], al
        ; move dr, r3
        lea r11, [rsp+18]
        mov [r11], r8w
        ; move r, r4
        lea r11, [rsp+20]
        mov [r11], r9w
        ; move dc, r5
        lea r11, [rsp+22]
        mov [r11], r10w
        ; call r0, checkCellBounds, [r1, r2]
        sub rsp, 20h; shadow space
        call @checkCellBounds
        add rsp, 20h
        ; branch r0, true, @if_9_then
        or al, al
        jnz @if_9_then
        ; move r0, count
        lea r11, [rsp+16]
        mov al, [r11]
        jmp @for_8_continue
@if_9_then:
        ; move r0, r
        lea r11, [rsp+20]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, c
        lea r11, [rsp+24]
        mov dx, [r11]
        ; move r, r0
        lea r11, [rsp+20]
        mov [r11], ax
        ; call r0, getCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @getCell
        add rsp, 20h
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; move r1, r0
        mov cl, al
        ; call r0, isBomb, [r1]
        sub rsp, 20h; shadow space
        call @isBomb
        add rsp, 20h
        ; branch r0, true, @if_10_then
        or al, al
        jnz @if_10_then
        ; move r0, count
        lea r11, [rsp+16]
        mov al, [r11]
        jmp @for_8_continue
@if_10_then:
        ; const r1, 1
        mov cl, 1
        ; move r0, count
        lea r11, [rsp+16]
        mov al, [r11]
        ; add r0, r0, r1
        add al, cl
@for_8_continue:
        ; const r1, 1
        mov cx, 1
        ; move r2, dc
        lea r11, [rsp+22]
        mov dx, [r11]
        ; add r2, r2, r1
        add dx, cx
@for_8:
        ; const r1, 1
        mov cx, 1
        ; lteq r1, r2, r1
        cmp dx, cx
        setle cl
        ; branch r1, true, @no_critical_edge_14
        or cl, cl
        jnz @no_critical_edge_14
        ; const r1, 1
        mov cx, 1
        ; move r2, dr
        lea r11, [rsp+18]
        mov dx, [r11]
        ; add r2, r2, r1
        add dx, cx
@for_7:
        ; const r1, 1
        mov cx, 1
        ; lteq r1, r2, r1
        cmp dx, cx
        setle cl
        ; branch r1, true, @for_7_body
        or cl, cl
        jnz @for_7_body
        ; 57:9 return count
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; u8 getSpacer
        ;   rsp+16: arg row
        ;   rsp+24: arg column
        ;   rsp+32: arg rowCursor
        ;   rsp+40: arg columnCursor
@getSpacer:
        sub rsp, 8
        ; 61:2 if rowCursor == row
        ; equals r1, r3, r1
        cmp r8w, cx
        sete cl
        ; branch r1, false, @if_11_end
        or cl, cl
        jz @if_11_end
        ; 62:3 if columnCursor == column
        ; equals r1, r4, r2
        cmp r9w, dx
        sete cl
        ; branch r1, false, @if_12_end
        or cl, cl
        jz @if_12_end
        ; 63:11 return 91
        ; const r0, 91
        mov al, 91
        jmp @getSpacer_ret
@if_12_end:
        ; 65:3 if columnCursor == column - 1
        ; const r1, 1
        mov cx, 1
        ; sub r2, r2, r1
        sub dx, cx
        ; equals r1, r4, r2
        cmp r9w, dx
        sete cl
        ; branch r1, false, @if_11_end
        or cl, cl
        jz @if_11_end
        ; 66:11 return 93
        ; const r0, 93
        mov al, 93
        jmp @getSpacer_ret
@if_11_end:
        ; 69:9 return 32
        ; const r0, 32
        mov al, 32
@getSpacer_ret:
        add rsp, 8
        ret

        ; void printCell
        ;   rsp+32: arg cell
        ;   rsp+40: arg row
        ;   rsp+48: arg column
        ;   rsp+16: var chr
@printCell:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov bl, cl
        ; move r7, r2
        mov r12w, dx
        ; move r0, r3
        mov ax, r8w
        ; const r2, 46
        mov dl, 46
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; move r1, r6
        mov cl, bl
        ; move column, r0
        lea r11, [rsp+48]
        mov [r11], ax
        ; move chr, r2
        lea r11, [rsp+16]
        mov [r11], dl
        ; call r0, isOpen, [r1]
        sub rsp, 20h; shadow space
        call @isOpen
        add rsp, 20h
        ; branch r0, true, @if_14_then
        or al, al
        jnz @if_14_then
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; move r1, r6
        mov cl, bl
        ; call r0, isFlag, [r1]
        sub rsp, 20h; shadow space
        call @isFlag
        add rsp, 20h
        ; branch r0, false, @no_critical_edge_15
        or al, al
        jz @no_critical_edge_15
        jmp @if_17_then
@if_14_then:
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; move r1, r6
        mov cl, bl
        ; call r0, isBomb, [r1]
        sub rsp, 20h; shadow space
        call @isBomb
        add rsp, 20h
        ; branch r0, false, @if_15_else
        or al, al
        jz @if_15_else
        jmp @if_15_then
@no_critical_edge_15:
        ; move r6, chr
        lea r11, [rsp+16]
        mov bl, [r11]
        jmp @if_14_end
@if_17_then:
        ; const r6, 35
        mov bl, 35
        jmp @if_14_end
@if_15_then:
        ; const r6, 42
        mov bl, 42
        jmp @if_14_end
@if_15_else:
        ; move r1, r7
        mov cx, r12w
        ; move r2, column
        lea r11, [rsp+48]
        mov dx, [r11]
        ; call r0, getBombCountAround, [r1, r2]
        sub rsp, 20h; shadow space
        call @getBombCountAround
        add rsp, 20h
        ; 80:4 if count > 0
        ; const r7, 0
        mov r12b, 0
        ; gt r7, r0, r7
        cmp al, r12b
        seta r12b
        ; branch r7, true, @if_16_then
        or r12b, r12b
        jnz @if_16_then
        ; const r6, 32
        mov bl, 32
        jmp @if_14_end
@if_16_then:
        ; const r7, 48
        mov r12b, 48
        ; move r6, r0
        mov bl, al
        ; add r6, r6, r7
        add bl, r12b
@if_14_end:
        ; move r1, r6
        mov cl, bl
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printField
        ;   rsp+32: arg rowCursor
        ;   rsp+40: arg columnCursor
        ;   rsp+16: var row
        ;   rsp+18: var column
@printField:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov bx, cx
        ; move r7, r2
        mov r12w, dx
        ; const r1, 0
        mov cx, 0
        ; const r2, 0
        mov dx, 0
        ; call _, setCursor [r1, r2]
        sub rsp, 20h; shadow space
        call @setCursor
        add rsp, 20h
        ; const r0, 0
        mov ax, 0
        ; 96:2 for row < 20
        ; move r1, r0
        mov cx, ax
        jmp @for_18
@for_18_body:
        ; move r0, r1
        mov ax, cx
        ; const r1, 124
        mov cl, 124
        ; move row, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; const r0, 0
        mov ax, 0
        ; 98:3 for column < 40
        ; move r5, r0
        mov r10w, ax
        jmp @for_19
@for_19_body:
        ; move r0, r5
        mov ax, r10w
        ; move r5, row
        lea r11, [rsp+16]
        mov r10w, [r11]
        ; move r1, r5
        mov cx, r10w
        ; move r2, r0
        mov dx, ax
        ; move r3, r6
        mov r8w, bx
        ; move r4, r7
        mov r9w, r12w
        ; move row, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        ; move column, r0
        lea r11, [rsp+18]
        mov [r11], ax
        ; call r0, getSpacer, [r1, r2, r3, r4]
        sub rsp, 20h; shadow space
        call @getSpacer
        add rsp, 20h
        ; move r1, r0
        mov cl, al
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; move r0, row
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r3, column
        lea r11, [rsp+18]
        mov r8w, [r11]
        ; move r2, r3
        mov dx, r8w
        ; move row, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; move column, r3
        lea r11, [rsp+18]
        mov [r11], r8w
        ; call r0, getCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @getCell
        add rsp, 20h
        ; move r1, r0
        mov cl, al
        ; move r0, row
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r2, r0
        mov dx, ax
        ; move r4, column
        lea r11, [rsp+18]
        mov r9w, [r11]
        ; move r3, r4
        mov r8w, r9w
        ; move row, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; move column, r4
        lea r11, [rsp+18]
        mov [r11], r9w
        ; call _, printCell [r1, r2, r3]
        sub rsp, 20h; shadow space
        call @printCell
        add rsp, 20h
        ; const r0, 1
        mov ax, 1
        ; move r5, column
        lea r11, [rsp+18]
        mov r10w, [r11]
        ; add r5, r5, r0
        add r10w, ax
@for_19:
        ; const r0, 40
        mov ax, 40
        ; lt r0, r5, r0
        cmp r10w, ax
        setl al
        ; branch r0, true, @for_19_body
        or al, al
        jnz @for_19_body
        ; const r2, 40
        mov dx, 40
        ; move r0, row
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r3, r6
        mov r8w, bx
        ; move r4, r7
        mov r9w, r12w
        ; move row, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call r0, getSpacer, [r1, r2, r3, r4]
        sub rsp, 20h; shadow space
        call @getSpacer
        add rsp, 20h
        ; move r1, r0
        mov cl, al
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; const r1, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; const r0, 1
        mov ax, 1
        ; move r1, row
        lea r11, [rsp+16]
        mov cx, [r11]
        ; add r1, r1, r0
        add cx, ax
@for_18:
        ; const r0, 20
        mov ax, 20
        ; lt r0, r1, r0
        cmp cx, ax
        setl al
        ; branch r0, true, @for_18_body
        or al, al
        jnz @for_18_body
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printSpaces
        ;   rsp+16: arg i
@printSpaces:
        ; save globbered non-volatile registers
        push rbx
        ; move r6, r1
        mov bx, cx
        ; 111:2 for i > 0
        jmp @for_20
@for_20_body:
        ; const r1, 48
        mov cl, 48
        ; call _, printChar [r1]
        sub rsp, 20h; shadow space
        call @printChar
        add rsp, 20h
        ; const r0, 1
        mov ax, 1
        ; sub r6, r6, r0
        sub bx, ax
@for_20:
        ; const r0, 0
        mov ax, 0
        ; gt r0, r6, r0
        cmp bx, ax
        setg al
        ; branch r0, true, @for_20_body
        or al, al
        jnz @for_20_body
        ; restore globbered non-volatile registers
        pop rbx
        ret

        ; u8 getDigitCount
        ;   rsp+16: arg value
@getDigitCount:
        sub rsp, 8
        ; const r3, 0
        mov r8b, 0
        ; 118:2 if value < 0
        ; const r4, 0
        mov r9w, 0
        ; lt r4, r1, r4
        cmp cx, r9w
        setl r9b
        ; branch r4, false, @while_22
        or r9b, r9b
        jz @while_22
        ; const r3, 1
        mov r8b, 1
        ; neg r1, r1
        neg rcx
@while_22:
        ; const r4, 1
        mov r9b, 1
        ; add r3, r3, r4
        add r8b, r9b
        ; const r4, 10
        mov r9w, 10
        ; move r0, r1
        mov ax, cx
        ; div r0, r0, r4
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move r1, r0
        mov cx, ax
        ; 126:3 if value == 0
        ; const r2, 0
        mov dx, 0
        ; equals r2, r1, r2
        cmp cx, dx
        sete dl
        ; branch r2, false, @while_22
        or dl, dl
        jz @while_22
        ; 131:9 return count
        ; move r0, r3
        mov al, r8b
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+16: var c
@getHiddenCount:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; const r6, 0
        mov bx, 0
        ; const r7, 0
        mov r12w, 0
        ; 136:2 for r < 20
        jmp @for_24
@for_24_body:
        ; const r0, 0
        mov ax, 0
        ; 137:3 for c < 40
        ; move r2, r0
        mov dx, ax
        jmp @for_25
@no_critical_edge_12:
        ; move r0, r2
        mov ax, dx
        ; move r1, r7
        mov cx, r12w
        ; move r2, r0
        mov dx, ax
        ; move c, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call r0, getCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @getCell
        add rsp, 20h
        ; 139:4 if cell & 6 == 0
        ; const r1, 6
        mov cl, 6
        ; move r2, r0
        mov dl, al
        ; and r2, r2, r1
        and dl, cl
        ; const r1, 0
        mov cl, 0
        ; equals r1, r2, r1
        cmp dl, cl
        sete cl
        ; branch r1, false, @for_25_continue
        or cl, cl
        jz @for_25_continue
        ; const r1, 1
        mov cx, 1
        ; add r6, r6, r1
        add bx, cx
@for_25_continue:
        ; const r1, 1
        mov cx, 1
        ; move r2, c
        lea r11, [rsp+16]
        mov dx, [r11]
        ; add r2, r2, r1
        add dx, cx
@for_25:
        ; const r1, 40
        mov cx, 40
        ; lt r1, r2, r1
        cmp dx, cx
        setl cl
        ; branch r1, true, @no_critical_edge_12
        or cl, cl
        jnz @no_critical_edge_12
        ; const r1, 1
        mov cx, 1
        ; add r7, r7, r1
        add r12w, cx
@for_24:
        ; const r1, 20
        mov cx, 20
        ; lt r1, r7, r1
        cmp r12w, cx
        setl cl
        ; branch r1, true, @for_24_body
        or cl, cl
        jnz @for_24_body
        ; 144:9 return count
        ; move r0, r6
        mov ax, bx
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+16: var bombDigits
@printLeft:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; call r0, getHiddenCount, []
        sub rsp, 20h; shadow space
        call @getHiddenCount
        add rsp, 20h
        ; move r6, r0
        mov bx, ax
        ; move r1, r6
        mov cx, bx
        ; call r0, getDigitCount, [r1]
        sub rsp, 20h; shadow space
        call @getDigitCount
        add rsp, 20h
        ; cast r7(i16), r0(u8)
        movzx r12w, al
        ; const r1, 40
        mov cx, 40
        ; call r0, getDigitCount, [r1]
        sub rsp, 20h; shadow space
        call @getDigitCount
        add rsp, 20h
        ; cast r0(i16), r0(u8)
        movzx ax, al
        ; const r1, [string-1]
        lea rcx, [string_1]
        ; move bombDigits, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        ; move r0, bombDigits
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; sub r1, r1, r7
        sub cx, r12w
        ; call _, printSpaces [r1]
        sub rsp, 20h; shadow space
        call @printSpaces
        add rsp, 20h
        ; cast r1(i64), r6(i16)
        movzx rcx, bx
        ; call _, printUint [r1]
        sub rsp, 20h; shadow space
        call @printUint
        add rsp, 20h
        ; 155:15 return count == 0
        ; const r1, 0
        mov cx, 0
        ; equals r0, r6, r1
        cmp bx, cx
        sete al
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i16 abs
        ;   rsp+16: arg a
@abs:
        sub rsp, 8
        ; 159:2 if a < 0
        ; const r2, 0
        mov dx, 0
        ; lt r2, r1, r2
        cmp cx, dx
        setl dl
        ; branch r2, true, @if_27_then
        or dl, dl
        jnz @if_27_then
        ; 162:9 return a
        ; move r0, r1
        mov ax, cx
        jmp @abs_ret
@if_27_then:
        ; 160:10 return -a
        ; neg r0, r1
        mov rax, rcx
        neg rax
@abs_ret:
        add rsp, 8
        ret

        ; void clearField
@clearField:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; const r6, 0
        mov bx, 0
        ; 166:2 for r < 20
        jmp @for_28
@for_28_body:
        ; const r7, 0
        mov r12w, 0
        ; 167:3 for c < 40
        jmp @for_29
@for_29_body:
        ; const r3, 0
        mov r8b, 0
        ; move r1, r6
        mov cx, bx
        ; move r2, r7
        mov dx, r12w
        ; call _, setCell [r1, r2, r3]
        sub rsp, 20h; shadow space
        call @setCell
        add rsp, 20h
        ; const r0, 1
        mov ax, 1
        ; add r7, r7, r0
        add r12w, ax
@for_29:
        ; const r0, 40
        mov ax, 40
        ; lt r0, r7, r0
        cmp r12w, ax
        setl al
        ; branch r0, true, @for_29_body
        or al, al
        jnz @for_29_body
        ; const r0, 1
        mov ax, 1
        ; add r6, r6, r0
        add bx, ax
@for_28:
        ; const r0, 20
        mov ax, 20
        ; lt r0, r6, r0
        cmp bx, ax
        setl al
        ; branch r0, true, @for_28_body
        or al, al
        jnz @for_28_body
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void initField
        ;   rsp+32: arg curr_r
        ;   rsp+40: arg curr_c
        ;   rsp+16: var bombs
        ;   rsp+18: var row
        ;   rsp+20: var column
@initField:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov bx, cx
        ; move r7, r2
        mov r12w, dx
        ; const r0, 40
        mov ax, 40
        ; 174:2 for bombs > 0
        ; move r1, r0
        mov cx, ax
        jmp @for_30
@no_critical_edge_10:
        ; move r0, r1
        mov ax, cx
        ; move bombs, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call r0, random, []
        sub rsp, 20h; shadow space
        call @random
        add rsp, 20h
        ; const r1, 20
        mov ecx, 20
        ; move r3, r0
        mov r8d, eax
        ; move r0, r3
        mov eax, r8d
        ; mod r2, r0, r1
        movsxd rax, eax
        movsxd rcx, ecx
        cqo
        idiv rcx
        ; move r3, r2
        mov r8d, edx
        ; cast r0(i16), r3(i32)
        mov ax, r8w
        ; move row, r0
        lea r11, [rsp+18]
        mov [r11], ax
        ; call r0, random, []
        sub rsp, 20h; shadow space
        call @random
        add rsp, 20h
        ; const r3, 40
        mov r8d, 40
        ; move r4, r0
        mov r9d, eax
        ; move r0, r4
        mov eax, r9d
        ; mod r2, r0, r3
        movsxd rax, eax
        movsxd r8, r8d
        cqo
        idiv r8
        ; move r4, r2
        mov r9d, edx
        ; cast r0(i16), r4(i32)
        mov ax, r9w
        ; 177:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move r2, row
        lea r11, [rsp+18]
        mov dx, [r11]
        ; move r1, r2
        mov cx, dx
        ; sub r1, r1, r6
        sub cx, bx
        ; move row, r2
        lea r11, [rsp+18]
        mov [r11], dx
        ; move column, r0
        lea r11, [rsp+20]
        mov [r11], ax
        ; call r0, abs, [r1]
        sub rsp, 20h; shadow space
        call @abs
        add rsp, 20h
        ; const r2, 1
        mov dx, 1
        ; gt r0, r0, r2
        cmp ax, dx
        setg al
        ; branch r0, true, @or_next_32
        or al, al
        jnz @or_next_32
        ; move r0, column
        lea r11, [rsp+20]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; sub r1, r1, r7
        sub cx, r12w
        ; move column, r0
        lea r11, [rsp+20]
        mov [r11], ax
        ; call r0, abs, [r1]
        sub rsp, 20h; shadow space
        call @abs
        add rsp, 20h
        ; const r4, 1
        mov r9w, 1
        ; gt r0, r0, r4
        cmp ax, r9w
        setg al
@or_next_32:
        ; branch r0, false, @for_30_continue
        or al, al
        jz @for_30_continue
        ; const r3, 1
        mov r8b, 1
        ; move r1, row
        lea r11, [rsp+18]
        mov cx, [r11]
        ; move r2, column
        lea r11, [rsp+20]
        mov dx, [r11]
        ; call _, setCell [r1, r2, r3]
        sub rsp, 20h; shadow space
        call @setCell
        add rsp, 20h
@for_30_continue:
        ; const r0, 1
        mov ax, 1
        ; move r1, bombs
        lea r11, [rsp+16]
        mov cx, [r11]
        ; sub r1, r1, r0
        sub cx, ax
@for_30:
        ; const r0, 0
        mov ax, 0
        ; gt r0, r1, r0
        cmp cx, ax
        setg al
        ; branch r0, true, @no_critical_edge_10
        or al, al
        jnz @no_critical_edge_10
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void maybeRevealAround
        ;   rsp+48: arg row
        ;   rsp+56: arg column
        ;   rsp+16: var dr
        ;   rsp+18: var r
        ;   rsp+20: var dc
        ;   rsp+22: var c
        ;   rsp+24: var cell
@maybeRevealAround:
        sub rsp, 24
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; move r6, r1
        mov bx, cx
        ; move r7, r2
        mov r12w, dx
        ; 185:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=185:30]]) != 0
        ; move r1, r6
        mov cx, bx
        ; move r2, r7
        mov dx, r12w
        ; call r0, getBombCountAround, [r1, r2]
        sub rsp, 20h; shadow space
        call @getBombCountAround
        add rsp, 20h
        ; const r3, 0
        mov r8b, 0
        ; notequals r0, r0, r3
        cmp al, r8b
        setne al
        ; branch r0, true, @maybeRevealAround_ret
        or al, al
        jnz @maybeRevealAround_ret
        ; const r0, -1
        mov ax, -1
        ; 189:2 for dr <= 1
        ; move r1, r0
        mov cx, ax
        jmp @for_34
@for_34_body:
        ; move r0, r1
        mov ax, cx
        ; move r3, r6
        mov r8w, bx
        ; add r3, r3, r0
        add r8w, ax
        ; const r4, -1
        mov r9w, -1
        ; 191:3 for dc <= 1
        ; move dr, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; move r, r3
        lea r11, [rsp+18]
        mov [r11], r8w
        ; move r1, r4
        mov cx, r9w
        jmp @for_35
@no_critical_edge_20:
        ; move r4, r1
        mov r9w, cx
        ; move r0, dr
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r3, r
        lea r11, [rsp+18]
        mov r8w, [r11]
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; const r5, 0
        mov r10w, 0
        ; equals r5, r0, r5
        cmp ax, r10w
        sete r10b
        ; branch r5, false, @and_next_37
        or r10b, r10b
        jz @and_next_37
        ; const r2, 0
        mov dx, 0
        ; equals r5, r4, r2
        cmp r9w, dx
        sete r10b
@and_next_37:
        ; branch r5, false, @if_36_end
        or r10b, r10b
        jz @if_36_end
        ; move dc, r4
        lea r11, [rsp+20]
        mov [r11], r9w
        ; move dr, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; move r, r3
        lea r11, [rsp+18]
        mov [r11], r8w
        jmp @for_35_continue
@if_36_end:
        ; move r5, r7
        mov r10w, r12w
        ; add r5, r5, r4
        add r10w, r9w
        ; 197:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; move r1, r3
        mov cx, r8w
        ; move r2, r5
        mov dx, r10w
        ; move dr, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; move r, r3
        lea r11, [rsp+18]
        mov [r11], r8w
        ; move dc, r4
        lea r11, [rsp+20]
        mov [r11], r9w
        ; move c, r5
        lea r11, [rsp+22]
        mov [r11], r10w
        ; call r0, checkCellBounds, [r1, r2]
        sub rsp, 20h; shadow space
        call @checkCellBounds
        add rsp, 20h
        ; notlog r0, r0
        or al, al
        sete al
        ; branch r0, true, @for_35_continue
        or al, al
        jnz @for_35_continue
        ; move r0, r
        lea r11, [rsp+18]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r3, c
        lea r11, [rsp+22]
        mov r8w, [r11]
        ; move r2, r3
        mov dx, r8w
        ; move r, r0
        lea r11, [rsp+18]
        mov [r11], ax
        ; move c, r3
        lea r11, [rsp+22]
        mov [r11], r8w
        ; call r0, getCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @getCell
        add rsp, 20h
        ; 202:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move r1, r0
        mov cl, al
        ; move cell, r0
        lea r11, [rsp+24]
        mov [r11], al
        ; call r0, isOpen, [r1]
        sub rsp, 20h; shadow space
        call @isOpen
        add rsp, 20h
        ; branch r0, true, @for_35_continue
        or al, al
        jnz @for_35_continue
        ; const r0, 2
        mov al, 2
        ; move r4, cell
        lea r11, [rsp+24]
        mov r9b, [r11]
        ; move r3, r4
        mov r8b, r9b
        ; or r3, r3, r0
        or r8b, al
        ; move r0, r
        lea r11, [rsp+18]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r4, c
        lea r11, [rsp+22]
        mov r9w, [r11]
        ; move r2, r4
        mov dx, r9w
        ; move r, r0
        lea r11, [rsp+18]
        mov [r11], ax
        ; move c, r4
        lea r11, [rsp+22]
        mov [r11], r9w
        ; call _, setCell [r1, r2, r3]
        sub rsp, 20h; shadow space
        call @setCell
        add rsp, 20h
        ; move r0, r
        lea r11, [rsp+18]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, c
        lea r11, [rsp+22]
        mov dx, [r11]
        ; move r, r0
        lea r11, [rsp+18]
        mov [r11], ax
        ; call _, maybeRevealAround [r1, r2]
        sub rsp, 20h; shadow space
        call @maybeRevealAround
        add rsp, 20h
@for_35_continue:
        ; const r0, 1
        mov ax, 1
        ; move r1, dc
        lea r11, [rsp+20]
        mov cx, [r11]
        ; add r1, r1, r0
        add cx, ax
@for_35:
        ; const r0, 1
        mov ax, 1
        ; lteq r0, r1, r0
        cmp cx, ax
        setle al
        ; branch r0, true, @no_critical_edge_20
        or al, al
        jnz @no_critical_edge_20
        ; const r0, 1
        mov ax, 1
        ; move r1, dr
        lea r11, [rsp+16]
        mov cx, [r11]
        ; add r1, r1, r0
        add cx, ax
@for_34:
        ; const r0, 1
        mov ax, 1
        ; lteq r0, r1, r0
        cmp cx, ax
        setle al
        ; branch r0, true, @for_34_body
        or al, al
        jnz @for_34_body
@maybeRevealAround_ret:
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void main
        ;   rsp+16: var curr_r
        ;   rsp+18: var cell
        ;   rsp+19: var cell
@main:
        sub rsp, 8
        ; save globbered non-volatile registers
        push rbx
        push r12
        ; begin initialize global variables
        ; const r6, 0
        mov ebx, 0
        ; end initialize global variables
        ; const r1, 7439742
        mov ecx, 7439742
        ; move __random__, r6
        lea r11, [var_0]
        mov [r11], ebx
        ; call _, initRandom [r1]
        sub rsp, 20h; shadow space
        call @initRandom
        add rsp, 20h
        ; const r6, 1
        mov bl, 1
        ; call _, clearField []
        sub rsp, 20h; shadow space
        call @clearField
        add rsp, 20h
        ; const r7, 20
        mov r12b, 20
        ; cast r7(i16), r7(u8)
        movzx r12w, r12b
        ; const r0, 10
        mov al, 10
        ; cast r0(i16), r0(u8)
        movzx ax, al
        ; 218:2 while true
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        jmp @while_40
@no_critical_edge_40:
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        jmp @if_41_end
@no_critical_edge_41:
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; 221:4 if printLeft([])
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call r0, printLeft, []
        sub rsp, 20h; shadow space
        call @printLeft
        add rsp, 20h
        ; branch r0, true, @if_42_then
        or al, al
        jnz @if_42_then
@if_41_end:
        ; call r0, getChar, []
        sub rsp, 20h; shadow space
        call @getChar
        add rsp, 20h
        ; move r3, r0
        mov r8w, ax
        ; 228:3 if chr == 27
        ; const r4, 27
        mov r9w, 27
        ; equals r4, r3, r4
        cmp r8w, r9w
        sete r9b
        ; branch r4, true, @main_ret
        or r9b, r9b
        jnz @main_ret
        ; 233:3 if chr == 57416
        ; const r4, 57416
        mov r9w, 57416
        ; equals r4, r3, r4
        cmp r8w, r9w
        sete r9b
        ; branch r4, false, @if_44_else
        or r9b, r9b
        jz @if_44_else
        ; const r4, 20
        mov r9w, 20
        ; move r5, curr_r
        lea r11, [rsp+16]
        mov r10w, [r11]
        ; move r1, r5
        mov cx, r10w
        ; add r1, r1, r4
        add cx, r9w
        ; const r4, 1
        mov r9w, 1
        ; sub r1, r1, r4
        sub cx, r9w
        ; const r4, 20
        mov r9w, 20
        ; move r5, r1
        mov r10w, cx
        ; move r0, r5
        mov ax, r10w
        ; mod r2, r0, r4
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move r5, r2
        mov r10w, dx
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @while_40
@if_44_else:
        ; move r5, curr_r
        lea r11, [rsp+16]
        mov r10w, [r11]
        ; 237:8 if chr == 57424
        ; const r4, 57424
        mov r9w, 57424
        ; equals r4, r3, r4
        cmp r8w, r9w
        sete r9b
        ; branch r4, false, @if_45_else
        or r9b, r9b
        jz @if_45_else
        ; const r4, 1
        mov r9w, 1
        ; move r1, r5
        mov cx, r10w
        ; add r1, r1, r4
        add cx, r9w
        ; const r4, 20
        mov r9w, 20
        ; move r5, r1
        mov r10w, cx
        ; move r0, r5
        mov ax, r10w
        ; mod r2, r0, r4
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move r5, r2
        mov r10w, dx
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @while_40
@if_45_else:
        ; 241:8 if chr == 57419
        ; const r4, 57419
        mov r9w, 57419
        ; equals r4, r3, r4
        cmp r8w, r9w
        sete r9b
        ; branch r4, false, @if_46_else
        or r9b, r9b
        jz @if_46_else
        ; const r4, 40
        mov r9w, 40
        ; move r1, r7
        mov cx, r12w
        ; add r1, r1, r4
        add cx, r9w
        ; const r4, 1
        mov r9w, 1
        ; sub r1, r1, r4
        sub cx, r9w
        ; const r4, 40
        mov r9w, 40
        ; move r7, r1
        mov r12w, cx
        ; move r0, r7
        mov ax, r12w
        ; mod r2, r0, r4
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move r7, r2
        mov r12w, dx
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @while_40
@if_46_else:
        ; 245:8 if chr == 57419
        ; const r4, 57419
        mov r9w, 57419
        ; equals r4, r3, r4
        cmp r8w, r9w
        sete r9b
        ; branch r4, false, @if_47_else
        or r9b, r9b
        jz @if_47_else
        ; const r4, 40
        mov r9w, 40
        ; move r1, r7
        mov cx, r12w
        ; add r1, r1, r4
        add cx, r9w
        ; const r4, 1
        mov r9w, 1
        ; sub r1, r1, r4
        sub cx, r9w
        ; const r4, 40
        mov r9w, 40
        ; move r7, r1
        mov r12w, cx
        ; move r0, r7
        mov ax, r12w
        ; mod r2, r0, r4
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move r7, r2
        mov r12w, dx
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @while_40
@if_47_else:
        ; 249:8 if chr == 57421
        ; const r4, 57421
        mov r9w, 57421
        ; equals r4, r3, r4
        cmp r8w, r9w
        sete r9b
        ; branch r4, false, @if_48_else
        or r9b, r9b
        jz @if_48_else
        ; const r4, 1
        mov r9w, 1
        ; move r1, r7
        mov cx, r12w
        ; add r1, r1, r4
        add cx, r9w
        ; const r4, 40
        mov r9w, 40
        ; move r7, r1
        mov r12w, cx
        ; move r0, r7
        mov ax, r12w
        ; mod r2, r0, r4
        movsx rax, ax
        movsx r9, r9w
        cqo
        idiv r9
        ; move r7, r2
        mov r12w, dx
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @while_40
@if_48_else:
        ; 253:8 if chr == 32
        ; const r0, 32
        mov ax, 32
        ; equals r0, r3, r0
        cmp r8w, ax
        sete al
        ; branch r0, true, @if_49_then
        or al, al
        jnz @if_49_then
        ; 262:8 if chr == 13
        ; const r0, 13
        mov ax, 13
        ; equals r0, r3, r0
        cmp r8w, ax
        sete al
        ; branch r0, false, @no_critical_edge_50
        or al, al
        jz @no_critical_edge_50
        jmp @if_52_then
@if_49_then:
        ; 254:4 if !needsInitialize
        ; notlog r0, r6
        or bl, bl
        sete al
        ; branch r0, false, @no_critical_edge_61
        or al, al
        jz @no_critical_edge_61
        jmp @if_50_then
@no_critical_edge_50:
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @while_40
@no_critical_edge_61:
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @while_40
@if_52_then:
        ; branch r6, false, @no_critical_edge_59
        or bl, bl
        jz @no_critical_edge_59
        jmp @if_53_then
@if_50_then:
        ; move r1, r5
        mov cx, r10w
        ; move r2, r7
        mov dx, r12w
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        ; call r0, getCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @getCell
        add rsp, 20h
        ; 256:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move r1, r0
        mov cl, al
        ; move cell, r0
        lea r11, [rsp+18]
        mov [r11], al
        ; call r0, isOpen, [r1]
        sub rsp, 20h; shadow space
        call @isOpen
        add rsp, 20h
        ; notlog r0, r0
        or al, al
        sete al
        ; branch r0, false, @while_40
        or al, al
        jz @while_40
        jmp @if_51_then
@no_critical_edge_59:
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        jmp @if_53_end
@if_53_then:
        ; move curr_r, r5
        lea r11, [rsp+16]
        mov [r11], r10w
        ; const r6, 0
        mov bl, 0
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, r7
        mov dx, r12w
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call _, initField [r1, r2]
        sub rsp, 20h; shadow space
        call @initField
        add rsp, 20h
        jmp @if_53_end
@if_51_then:
        ; const r0, 4
        mov al, 4
        ; move r3, cell
        lea r11, [rsp+18]
        mov r8b, [r11]
        ; xor r3, r3, r0
        xor r8b, al
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, r7
        mov dx, r12w
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call _, setCell [r1, r2, r3]
        sub rsp, 20h; shadow space
        call @setCell
        add rsp, 20h
        jmp @while_40
@if_53_end:
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, r7
        mov dx, r12w
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call r0, getCell, [r1, r2]
        sub rsp, 20h; shadow space
        call @getCell
        add rsp, 20h
        ; 268:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move r1, r0
        mov cl, al
        ; move cell, r0
        lea r11, [rsp+19]
        mov [r11], al
        ; call r0, isOpen, [r1]
        sub rsp, 20h; shadow space
        call @isOpen
        add rsp, 20h
        ; notlog r0, r0
        or al, al
        sete al
        ; branch r0, false, @if_54_end
        or al, al
        jz @if_54_end
        ; const r0, 2
        mov al, 2
        ; move r4, cell
        lea r11, [rsp+19]
        mov r9b, [r11]
        ; move r3, r4
        mov r8b, r9b
        ; or r3, r3, r0
        or r8b, al
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, r7
        mov dx, r12w
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; move cell, r4
        lea r11, [rsp+19]
        mov [r11], r9b
        ; call _, setCell [r1, r2, r3]
        sub rsp, 20h; shadow space
        call @setCell
        add rsp, 20h
@if_54_end:
        ; 271:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; move r1, cell
        lea r11, [rsp+19]
        mov cl, [r11]
        ; call r0, isBomb, [r1]
        sub rsp, 20h; shadow space
        call @isBomb
        add rsp, 20h
        ; branch r0, true, @if_55_then
        or al, al
        jnz @if_55_then
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, r7
        mov dx, r12w
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call _, maybeRevealAround [r1, r2]
        sub rsp, 20h; shadow space
        call @maybeRevealAround
        add rsp, 20h
@while_40:
        ; move r0, curr_r
        lea r11, [rsp+16]
        mov ax, [r11]
        ; move r1, r0
        mov cx, ax
        ; move r2, r7
        mov dx, r12w
        ; move curr_r, r0
        lea r11, [rsp+16]
        mov [r11], ax
        ; call _, printField [r1, r2]
        sub rsp, 20h; shadow space
        call @printField
        add rsp, 20h
        ; 220:3 if !needsInitialize
        ; notlog r0, r6
        or bl, bl
        sete al
        ; branch r0, false, @no_critical_edge_40
        or al, al
        jz @no_critical_edge_40
        jmp @no_critical_edge_41
@if_42_then:
        ; const r1, [string-2]
        lea rcx, [string_2]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
        jmp @main_ret
@if_55_then:
        ; move r1, curr_r
        lea r11, [rsp+16]
        mov cx, [r11]
        ; move r2, r7
        mov dx, r12w
        ; call _, printField [r1, r2]
        sub rsp, 20h; shadow space
        call @printField
        add rsp, 20h
        ; const r1, [string-3]
        lea rcx, [string_3]
        ; call _, printString [r1]
        sub rsp, 20h; shadow space
        call @printString
        add rsp, 20h
@main_ret:
        ; restore globbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength
@printStringLength:
        mov     rdi, rsp

        mov     r8, rdx
        mov     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        xor     r9, r9
        push    0
        sub     rsp, 20h
          call    [WriteFile]
        mov     rsp, rdi
        ret

        ; i16 getChar
@getChar:
        sub    rsp, 28h
          call [_getch]
          test al, al
          js   .1
          jnz  .2
          dec  al
.1:
          mov  rbx, rax
          shl  rbx, 8
          call [_getch]
          or   rax, rbx
.2:
        add    rsp, 28h
        ret

        ; void setCursor
@setCursor:
        sub     rsp, 28h
        shl     rcx, 16
        movsxd  rcx, ecx
        movsx   rdx, dx
        add     rdx, rcx
        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        call   [SetConsoleCursorPosition]
        add     rsp, 28h
        ret
init:
        sub rsp, 28h
          mov rcx, STD_IN_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdIn]
          mov qword [rcx], rax

          mov rcx, STD_OUT_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdOut]
          mov qword [rcx], rax

          mov rcx, STD_ERR_HANDLE
          call [GetStdHandle]
          ; handle in rax, 0 if invalid
          lea rcx, [hStdErr]
          mov qword [rcx], rax
        add rsp, 28h
        ret

section '.data' data readable writeable
        hStdIn  rb 8
        hStdOut rb 8
        hStdErr rb 8
        ; variable 0: __random__ (i32/4)
        var_0 rb 4
        ; variable 1: field[] (u8*/6400)
        var_1 rb 6400

section '.data' data readable
        string_0 db '|', 0x0a, 0x00
        string_1 db 'Left: ', 0x00
        string_2 db ' You', 0x27, 've cleaned the field!', 0x00
        string_3 db 'boom! you', 0x27, 've lost', 0x00

section '.idata' import data readable writeable

library kernel32,'KERNEL32.DLL',\
        msvcrt,'MSVCRT.DLL'

import kernel32,\
       ExitProcess,'ExitProcess',\
       GetStdHandle,'GetStdHandle',\
       SetConsoleCursorPosition,'SetConsoleCursorPosition',\
       WriteFile,'WriteFile'

import msvcrt,\
       _getch,'_getch'
