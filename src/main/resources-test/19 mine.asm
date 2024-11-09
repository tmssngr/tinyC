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
        sub rsp, 8
          call init
        add rsp, 8
          call @main
        mov rcx, 0
        sub rsp, 0x20
          call [ExitProcess]

        ; void printString
        ;   rsp+24: arg str
        ;   rsp+0: var length
@printString:
        ; reserve space for local variables
        sub rsp, 16
        ; call r0, strlen, [str]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
          call @strlen
        add rsp, 8
        mov rcx, rax
        ; call _, printStringLength [str, r0]
        lea rax, [rsp+24]
        mov rax, [rax]
        push rax
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printChar
        ;   rsp+24: arg chr
        ;   rsp+0: var t.1
        ;   rsp+8: var t.2
@printChar:
        ; reserve space for local variables
        sub rsp, 16
        ; addrof r0, chr
        lea rcx, [rsp+24]
        ; const r1, 1
        mov rdx, 1
        ; call _, printStringLength [r0, r1]
        push rcx
        push rdx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 16
        ret

        ; void printUint
        ;   rsp+152: arg number
        ;   rsp+0: var buffer
        ;   rsp+20: var pos
        ;   rsp+24: var remainder
        ;   rsp+32: var digit
        ;   rsp+33: var t.5
        ;   rsp+40: var t.6
        ;   rsp+48: var t.7
        ;   rsp+56: var t.8
        ;   rsp+57: var t.9
        ;   rsp+64: var t.10
        ;   rsp+72: var t.11
        ;   rsp+80: var t.12
        ;   rsp+88: var t.13
        ;   rsp+96: var t.14
        ;   rsp+104: var t.15
        ;   rsp+112: var t.16
        ;   rsp+120: var t.17
        ;   rsp+128: var t.18
        ;   rsp+136: var t.19
        ;   rsp+137: var t.20
@printUint:
        ; reserve space for local variables
        sub rsp, 144
        ; const r0, 20
        mov cl, 20
        ; 13:2 while true
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
@while_1:
        ; const r0, 1
        mov cl, 1
        ; move r1, pos
        lea rax, [rsp+20]
        mov dl, [rax]
        ; sub r0, r1, r0
        mov al, dl
        sub al, cl
        mov cl, al
        ; const r1, 10
        mov rdx, 10
        ; move r2, number
        lea rax, [rsp+152]
        mov r9, [rax]
        ; move r3, r2
        mov r10, r9
        ; mod r1, r3, r1
        mov rax, r10
        mov rbx, rdx
        cqo
        idiv rbx
        ; const r3, 10
        mov r10, 10
        ; div r2, r2, r3
        push rdx
        mov rax, r9
        mov rbx, r10
        cqo
        idiv rbx
        mov r9, rax
        pop rdx
        ; cast r1(u8), r1(i64)
        ; const r3, 48
        mov r10b, 48
        ; add r1, r1, r3
        add dl, r10b
        ; cast r3(i64), r0(u8)
        movzx r10, cl
        ; cast r3(u8*), r3(i64)
        ; Spill pos
        ; move pos, r0
        lea rax, [rsp+20]
        mov [rax], cl
        ; addrof r0, [buffer]
        lea rcx, [rsp+0]
        ; add r0, r0, r3
        add rcx, r10
        ; store [r0], r1
        mov [rcx], dl
        ; 19:3 if number == 0
        ; const r0, 0
        mov rcx, 0
        ; equals r0, r2, r0
        cmp r9, rcx
        sete cl
        ; move number, r2
        lea rax, [rsp+152]
        mov [rax], r9
        ; branch r0, false, @while_1
        or cl, cl
        jz @while_1
        ; move r0, pos
        lea rax, [rsp+20]
        mov cl, [rax]
        ; cast r1(i64), r0(u8)
        movzx rdx, cl
        ; cast r1(u8*), r1(i64)
        ; addrof r2, [buffer]
        lea r9, [rsp+0]
        ; add r1, r2, r1
        mov rax, r9
        add rax, rdx
        mov rdx, rax
        ; const r2, 20
        mov r9b, 20
        ; sub r0, r2, r0
        mov al, r9b
        sub al, cl
        mov cl, al
        ; cast r0(i64), r0(u8)
        movzx rcx, cl
        ; call _, printStringLength [r1, r0]
        push rdx
        push rcx
        sub rsp, 8
          call @printStringLength
        add rsp, 24
        ; release space for local variables
        add rsp, 144
        ret

        ; i64 strlen
        ;   rsp+56: arg str
        ;   rsp+0: var length
        ;   rsp+8: var t.2
        ;   rsp+9: var t.3
        ;   rsp+10: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
        ;   rsp+32: var t.7
        ;   rsp+40: var t.8
@strlen:
        ; reserve space for local variables
        sub rsp, 48
        ; const r0, 0
        mov rcx, 0
        ; 37:2 for *str != 0
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
@for_3:
        ; move r0, str
        lea rax, [rsp+56]
        mov rcx, [rax]
        ; load r1, [r0]
        mov dl, [rcx]
        ; const r2, 0
        mov r9b, 0
        ; notequals r1, r1, r2
        cmp dl, r9b
        setne dl
        ; branch r1, false, @for_3_break
        or dl, dl
        jz @for_3_break
        ; const r0, 1
        mov rcx, 1
        ; move r1, length
        lea rax, [rsp+0]
        mov rdx, [rax]
        ; add r0, r1, r0
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; move r1, str
        lea rax, [rsp+56]
        mov rdx, [rax]
        ; cast r1(i64), r1(u8*)
        ; const r2, 1
        mov r9, 1
        ; add r1, r1, r2
        add rdx, r9
        ; cast r1(u8*), r1(i64)
        ; move length, r0
        lea rax, [rsp+0]
        mov [rax], rcx
        ; move str, r1
        lea rax, [rsp+56]
        mov [rax], rdx
        jmp @for_3
@for_3_break:
        ; 40:9 return length
        ; move r0, length
        lea rax, [rsp+0]
        mov rcx, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 48
        ret

        ; void initRandom
        ;   rsp+8: arg salt
@initRandom:
        ; move r0, salt
        lea rax, [rsp+8]
        mov ecx, [rax]
        ; move __random__, r0
        lea rax, [var_0]
        mov [rax], ecx
        ret

        ; i32 random
        ;   rsp+0: var r
        ;   rsp+4: var b
        ;   rsp+8: var c
        ;   rsp+12: var d
        ;   rsp+16: var e
        ;   rsp+20: var t.5
        ;   rsp+24: var t.6
        ;   rsp+28: var t.7
        ;   rsp+32: var t.8
        ;   rsp+36: var t.9
        ;   rsp+40: var t.10
        ;   rsp+44: var t.11
        ;   rsp+48: var t.12
        ;   rsp+52: var t.13
        ;   rsp+56: var t.14
        ;   rsp+60: var t.15
        ;   rsp+64: var t.16
        ;   rsp+68: var t.17
        ;   rsp+72: var t.18
        ;   rsp+76: var t.19
        ;   rsp+80: var t.20
@random:
        ; reserve space for local variables
        sub rsp, 96
        ; move r0, __random__
        lea rax, [var_0]
        mov ecx, [rax]
        ; const r1, 524287
        mov edx, 524287
        ; move r2, r0
        mov r9d, ecx
        ; and r1, r2, r1
        mov eax, r9d
        and eax, edx
        mov edx, eax
        ; const r2, 48271
        mov r9d, 48271
        ; mul r1, r1, r2
        movsxd rdx, edx
        movsxd r9, r9d
        imul  rdx, r9
        ; const r2, 15
        mov r9d, 15
        ; shiftright r0, r0, r2
        mov eax, ecx
        mov ecx, r9d
        sar eax, cl
        mov ecx, eax
        ; const r2, 48271
        mov r9d, 48271
        ; mul r0, r0, r2
        movsxd rcx, ecx
        movsxd r9, r9d
        imul  rcx, r9
        ; const r2, 65535
        mov r9d, 65535
        ; move r3, r0
        mov r10d, ecx
        ; and r2, r3, r2
        mov eax, r10d
        and eax, r9d
        mov r9d, eax
        ; const r3, 15
        mov r10d, 15
        ; shiftleft r2, r2, r3
        mov rbx, rcx
        mov eax, r9d
        mov cl, r10b
        sal eax, cl
        mov r9d, eax
        mov rcx, rbx
        ; const r3, 16
        mov r10d, 16
        ; shiftright r0, r0, r3
        mov eax, ecx
        mov ecx, r10d
        sar eax, cl
        mov ecx, eax
        ; add r0, r0, r1
        add ecx, edx
        ; add r0, r0, r2
        add ecx, r9d
        ; const r1, 2147483647
        mov edx, 2147483647
        ; move r2, r0
        mov r9d, ecx
        ; and r1, r2, r1
        mov eax, r9d
        and eax, edx
        mov edx, eax
        ; const r2, 31
        mov r9d, 31
        ; shiftright r0, r0, r2
        mov eax, ecx
        mov ecx, r9d
        sar eax, cl
        mov ecx, eax
        ; move __random__, r1
        lea rax, [var_0]
        mov [rax], edx
        ; add r0, r1, r0
        mov eax, edx
        add eax, ecx
        mov ecx, eax
        ; 127:9 return __random__
        ; move __random__, r0
        lea rax, [var_0]
        mov [rax], ecx
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 96
        ret

        ; i16 rowColumnToCell
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
@rowColumnToCell:
        ; reserve space for local variables
        sub rsp, 16
        ; 15:21 return row * 40 + column
        ; const r0, 40
        mov cx, 40
        ; move r1, row
        lea rax, [rsp+40]
        mov dx, [rax]
        ; mul r0, r1, r0
        movsx rdx, dx
        movsx rcx, cx
        mov rax, rdx
        imul rax, rcx
        mov rcx, rax
        ; move r1, column
        lea rax, [rsp+32]
        mov dx, [rax]
        ; add r0, r0, r1
        add cx, dx
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getCell
        ;   rsp+72: arg row
        ;   rsp+64: arg column
        ;   rsp+0: var t.2
        ;   rsp+8: var t.3
        ;   rsp+16: var t.4
        ;   rsp+24: var t.5
        ;   rsp+32: var t.6
@getCell:
        ; reserve space for local variables
        sub rsp, 48
        ; 19:15 return [...]
        ; call r0, rowColumnToCell, [row, column]
        lea rax, [rsp+72]
        mov ax, [rax]
        push rax
        lea rax, [rsp+72]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @rowColumnToCell
        add rsp, 24
        mov cx, ax
        ; cast r0(i64), r0(i16)
        movzx rcx, cx
        ; cast r0(u8*), r0(i64)
        ; addrof r1, [field]
        lea rdx, [var_1]
        ; add r0, r1, r0
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; load r0, [r0]
        mov cl, [rcx]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 48
        ret

        ; bool isBomb
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isBomb:
        ; reserve space for local variables
        sub rsp, 16
        ; 23:27 return cell & 1 != 0
        ; const r0, 1
        mov cl, 1
        ; move r1, cell
        lea rax, [rsp+24]
        mov dl, [rax]
        ; and r0, r1, r0
        mov al, dl
        and al, cl
        mov cl, al
        ; const r1, 0
        mov dl, 0
        ; notequals r0, r0, r1
        cmp cl, dl
        setne cl
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isOpen
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isOpen:
        ; reserve space for local variables
        sub rsp, 16
        ; 27:27 return cell & 2 != 0
        ; const r0, 2
        mov cl, 2
        ; move r1, cell
        lea rax, [rsp+24]
        mov dl, [rax]
        ; and r0, r1, r0
        mov al, dl
        and al, cl
        mov cl, al
        ; const r1, 0
        mov dl, 0
        ; notequals r0, r0, r1
        cmp cl, dl
        setne cl
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool isFlag
        ;   rsp+24: arg cell
        ;   rsp+0: var t.1
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+3: var t.4
@isFlag:
        ; reserve space for local variables
        sub rsp, 16
        ; 31:27 return cell & 4 != 0
        ; const r0, 4
        mov cl, 4
        ; move r1, cell
        lea rax, [rsp+24]
        mov dl, [rax]
        ; and r0, r1, r0
        mov al, dl
        and al, cl
        mov cl, al
        ; const r1, 0
        mov dl, 0
        ; notequals r0, r0, r1
        cmp cl, dl
        setne cl
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; bool checkCellBounds
        ;   rsp+40: arg row
        ;   rsp+32: arg column
        ;   rsp+0: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
@checkCellBounds:
        ; reserve space for local variables
        sub rsp, 16
        ; 36:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 36:21 logic and
        ; 36:6 logic and
        ; 35:21 logic and
        ; const r0, 0
        mov cx, 0
        ; move r1, row
        lea rax, [rsp+40]
        mov dx, [rax]
        ; gteq r0, r1, r0
        cmp dx, cx
        setge cl
        ; move t.2, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; branch r0, false, @and_next_6
        or cl, cl
        jz @and_next_6
        ; const r0, 20
        mov cx, 20
        ; move r1, row
        lea rax, [rsp+40]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; move t.2, r0
        lea rax, [rsp+0]
        mov [rax], cl
@and_next_6:
        ; move r0, t.2
        lea rax, [rsp+0]
        mov cl, [rax]
        ; branch r0, false, @and_next_5
        or cl, cl
        jz @and_next_5
        ; const r0, 0
        mov cx, 0
        ; move r1, column
        lea rax, [rsp+32]
        mov dx, [rax]
        ; gteq r0, r1, r0
        cmp dx, cx
        setge cl
        ; move t.2, r0
        lea rax, [rsp+0]
        mov [rax], cl
@and_next_5:
        ; move r0, t.2
        lea rax, [rsp+0]
        mov cl, [rax]
        ; branch r0, false, @and_next_4
        or cl, cl
        jz @and_next_4
        ; const r0, 40
        mov cx, 40
        ; move r1, column
        lea rax, [rsp+32]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; move t.2, r0
        lea rax, [rsp+0]
        mov [rax], cl
@and_next_4:
        ; move r0, t.2
        lea rax, [rsp+0]
        mov cl, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; void setCell
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+40: arg cell
        ;   rsp+0: var t.3
        ;   rsp+8: var t.4
        ;   rsp+16: var t.5
        ;   rsp+24: var t.6
@setCell:
        ; reserve space for local variables
        sub rsp, 32
        ; call r0, rowColumnToCell, [row, column]
        lea rax, [rsp+56]
        mov ax, [rax]
        push rax
        lea rax, [rsp+56]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @rowColumnToCell
        add rsp, 24
        mov cx, ax
        ; cast r0(i64), r0(i16)
        movzx rcx, cx
        ; cast r0(u8*), r0(i64)
        ; addrof r1, [field]
        lea rdx, [var_1]
        ; add r0, r1, r0
        mov rax, rdx
        add rax, rcx
        mov rcx, rax
        ; move r1, cell
        lea rax, [rsp+40]
        mov dl, [rax]
        ; store [r0], r1
        mov [rcx], dl
        ; release space for local variables
        add rsp, 32
        ret

        ; u8 getBombCountAround
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+0: var count
        ;   rsp+2: var dr
        ;   rsp+4: var r
        ;   rsp+6: var dc
        ;   rsp+8: var c
        ;   rsp+10: var cell
        ;   rsp+11: var t.8
        ;   rsp+12: var t.9
        ;   rsp+14: var t.10
        ;   rsp+16: var t.11
        ;   rsp+18: var t.12
        ;   rsp+19: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
@getBombCountAround:
        ; reserve space for local variables
        sub rsp, 32
        ; const r0, 0
        mov cl, 0
        ; const r1, -1
        mov dx, -1
        ; 45:2 for dr <= 1
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; move dr, r1
        lea rax, [rsp+2]
        mov [rax], dx
@for_7:
        ; const r0, 1
        mov cx, 1
        ; move r1, dr
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lteq r0, r1, r0
        cmp dx, cx
        setle cl
        ; branch r0, false, @for_7_break
        or cl, cl
        jz @for_7_break
        ; move r0, row
        lea rax, [rsp+56]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, dr
        lea rax, [rsp+2]
        mov r9w, [rax]
        ; add r1, r1, r2
        add dx, r9w
        ; const r3, -1
        mov r10w, -1
        ; 47:3 for dc <= 1
        ; move r, r1
        lea rax, [rsp+4]
        mov [rax], dx
        ; move dc, r3
        lea rax, [rsp+6]
        mov [rax], r10w
@for_8:
        ; const r0, 1
        mov cx, 1
        ; move r1, dc
        lea rax, [rsp+6]
        mov dx, [rax]
        ; lteq r0, r1, r0
        cmp dx, cx
        setle cl
        ; branch r0, false, @for_8_break
        or cl, cl
        jz @for_8_break
        ; move r0, column
        lea rax, [rsp+48]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, dc
        lea rax, [rsp+6]
        mov r9w, [rax]
        ; add r1, r1, r2
        add dx, r9w
        ; 49:4 if checkCellBounds([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=49:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=49:27]])
        ; move c, r1
        lea rax, [rsp+8]
        mov [rax], dx
        ; call r0, checkCellBounds, [r, r1]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        push rdx
        sub rsp, 8
          call @checkCellBounds
        add rsp, 24
        mov cl, al
        ; branch r0, false, @for_8_continue
        or cl, cl
        jz @for_8_continue
        ; call r0, getCell, [r, c]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+16]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 51:5 if isBomb([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=51:16]])
        ; call r0, isBomb, [r0]
        push rcx
          call @isBomb
        add rsp, 8
        mov cl, al
        ; branch r0, false, @for_8_continue
        or cl, cl
        jz @for_8_continue
        ; const r0, 1
        mov cl, 1
        ; move r1, count
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cl
@for_8_continue:
        ; const r0, 1
        mov cx, 1
        ; move r1, dc
        lea rax, [rsp+6]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move dc, r0
        lea rax, [rsp+6]
        mov [rax], cx
        jmp @for_8
@for_8_break:
        ; const r0, 1
        mov cx, 1
        ; move r1, dr
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move dr, r0
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_7
@for_7_break:
        ; 57:9 return count
        ; move r0, count
        lea rax, [rsp+0]
        mov cl, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 32
        ret

        ; u8 getSpacer
        ;   rsp+56: arg row
        ;   rsp+48: arg column
        ;   rsp+40: arg rowCursor
        ;   rsp+32: arg columnCursor
        ;   rsp+0: var t.4
        ;   rsp+1: var t.5
        ;   rsp+2: var t.6
        ;   rsp+3: var t.7
        ;   rsp+4: var t.8
        ;   rsp+6: var t.9
        ;   rsp+8: var t.10
        ;   rsp+9: var t.11
@getSpacer:
        ; reserve space for local variables
        sub rsp, 16
        ; 61:2 if rowCursor == row
        ; move r0, rowCursor
        lea rax, [rsp+40]
        mov cx, [rax]
        ; move r1, row
        lea rax, [rsp+56]
        mov dx, [rax]
        ; equals r0, r0, r1
        cmp cx, dx
        sete cl
        ; branch r0, false, @if_11_end
        or cl, cl
        jz @if_11_end
        ; 62:3 if columnCursor == column
        ; move r0, columnCursor
        lea rax, [rsp+32]
        mov cx, [rax]
        ; move r1, column
        lea rax, [rsp+48]
        mov dx, [rax]
        ; equals r2, r0, r1
        cmp cx, dx
        sete r9b
        ; branch r2, false, @if_12_end
        or r9b, r9b
        jz @if_12_end
        ; 63:11 return 91
        ; const r0, 91
        mov cl, 91
        ; ret r0
        mov rax, rcx
        jmp @getSpacer_ret
@if_12_end:
        ; 65:3 if columnCursor == column - 1
        ; const r0, 1
        mov cx, 1
        ; move r1, column
        lea rax, [rsp+48]
        mov dx, [rax]
        ; sub r0, r1, r0
        mov ax, dx
        sub ax, cx
        mov cx, ax
        ; move r1, columnCursor
        lea rax, [rsp+32]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, false, @if_11_end
        or cl, cl
        jz @if_11_end
        ; 66:11 return 93
        ; const r0, 93
        mov cl, 93
        ; ret r0
        mov rax, rcx
        jmp @getSpacer_ret
@if_11_end:
        ; 69:9 return 32
        ; const r0, 32
        mov cl, 32
        ; ret r0
        mov rax, rcx
@getSpacer_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void printCell
        ;   rsp+40: arg cell
        ;   rsp+32: arg row
        ;   rsp+24: arg column
        ;   rsp+0: var chr
        ;   rsp+1: var count
        ;   rsp+2: var t.5
        ;   rsp+3: var t.6
        ;   rsp+4: var t.7
        ;   rsp+5: var t.8
        ;   rsp+6: var t.9
        ;   rsp+7: var t.10
@printCell:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0, 46
        mov cl, 46
        ; 74:2 if isOpen([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=74:13]])
        ; move chr, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; call r0, isOpen, [cell]
        lea rax, [rsp+40]
        mov al, [rax]
        push rax
          call @isOpen
        add rsp, 8
        mov cl, al
        ; branch r0, true, @if_14_then
        or cl, cl
        jnz @if_14_then
        ; 88:7 if isFlag([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=88:18]])
        ; call r0, isFlag, [cell]
        lea rax, [rsp+40]
        mov al, [rax]
        push rax
          call @isFlag
        add rsp, 8
        mov cl, al
        ; branch r0, false, @if_14_end
        or cl, cl
        jz @if_14_end
        jmp @if_17_then
@if_14_then:
        ; 75:3 if isBomb([ExprVarAccess[varName=cell, index=0, scope=argument, type=u8, varIsArray=false, location=75:14]])
        ; call r0, isBomb, [cell]
        lea rax, [rsp+40]
        mov al, [rax]
        push rax
          call @isBomb
        add rsp, 8
        mov cl, al
        ; branch r0, false, @if_15_else
        or cl, cl
        jz @if_15_else
        jmp @if_15_then
@if_17_then:
        ; const r0, 35
        mov cl, 35
        ; move chr, r0
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @if_14_end
@if_15_then:
        ; const r0, 42
        mov cl, 42
        ; move chr, r0
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @if_14_end
@if_15_else:
        ; call r0, getBombCountAround, [row, column]
        lea rax, [rsp+32]
        mov ax, [rax]
        push rax
        lea rax, [rsp+32]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getBombCountAround
        add rsp, 24
        mov cl, al
        ; 80:4 if count > 0
        ; const r1, 0
        mov dl, 0
        ; gt r1, r0, r1
        cmp cl, dl
        seta dl
        ; move count, r0
        lea rax, [rsp+1]
        mov [rax], cl
        ; branch r1, true, @if_16_then
        or dl, dl
        jnz @if_16_then
        ; const r0, 32
        mov cl, 32
        ; move chr, r0
        lea rax, [rsp+0]
        mov [rax], cl
        jmp @if_14_end
@if_16_then:
        ; const r0, 48
        mov cl, 48
        ; move r1, count
        lea rax, [rsp+1]
        mov dl, [rax]
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; move chr, r0
        lea rax, [rsp+0]
        mov [rax], cl
@if_14_end:
        ; call _, printChar [chr]
        lea rax, [rsp+0]
        mov al, [rax]
        push rax
          call @printChar
        add rsp, 8
        ; release space for local variables
        add rsp, 16
        ret

        ; void printField
        ;   rsp+72: arg rowCursor
        ;   rsp+64: arg columnCursor
        ;   rsp+0: var row
        ;   rsp+2: var column
        ;   rsp+4: var spacer
        ;   rsp+5: var cell
        ;   rsp+6: var spacer
        ;   rsp+8: var t.7
        ;   rsp+10: var t.8
        ;   rsp+12: var t.9
        ;   rsp+14: var t.10
        ;   rsp+16: var t.11
        ;   rsp+17: var t.12
        ;   rsp+18: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
        ;   rsp+32: var t.17
@printField:
        ; reserve space for local variables
        sub rsp, 48
        ; const r0, 0
        mov cx, 0
        ; const r1, 0
        mov dx, 0
        ; call _, setCursor [r0, r1]
        push rcx
        push rdx
        sub rsp, 8
          call @setCursor
        add rsp, 24
        ; const r0, 0
        mov cx, 0
        ; 96:2 for row < 20
        ; move row, r0
        lea rax, [rsp+0]
        mov [rax], cx
@for_18:
        ; const r0, 20
        mov cx, 20
        ; move r1, row
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; branch r0, false, @printField_ret
        or cl, cl
        jz @printField_ret
        ; const r0, 124
        mov cl, 124
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; const r0, 0
        mov cx, 0
        ; 98:3 for column < 40
        ; move column, r0
        lea rax, [rsp+2]
        mov [rax], cx
@for_19:
        ; const r0, 40
        mov cx, 40
        ; move r1, column
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; branch r0, false, @for_19_break
        or cl, cl
        jz @for_19_break
        ; call r0, getSpacer, [row, column, rowCursor, columnCursor]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getSpacer
        add rsp, 40
        mov cl, al
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; call r0, getCell, [row, column]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; call _, printCell [r0, row, column]
        push rcx
        lea rax, [rsp+8]
        mov ax, [rax]
        push rax
        lea rax, [rsp+18]
        mov ax, [rax]
        push rax
          call @printCell
        add rsp, 24
        ; const r0, 1
        mov cx, 1
        ; move r1, column
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move column, r0
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_19
@for_19_break:
        ; const r0, 40
        mov cx, 40
        ; call r0, getSpacer, [row, r0, rowCursor, columnCursor]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        push rcx
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        lea rax, [rsp+88]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getSpacer
        add rsp, 40
        mov cl, al
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; const r0, [string-0]
        lea rcx, [string_0]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        ; const r0, 1
        mov cx, 1
        ; move r1, row
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move row, r0
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_18
@printField_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void printSpaces
        ;   rsp+24: arg i
        ;   rsp+0: var t.1
        ;   rsp+2: var t.2
        ;   rsp+4: var t.3
        ;   rsp+6: var t.4
@printSpaces:
        ; reserve space for local variables
        sub rsp, 16
@for_20:
        ; const r0, 0
        mov cx, 0
        ; move r1, i
        lea rax, [rsp+24]
        mov dx, [rax]
        ; gt r0, r1, r0
        cmp dx, cx
        setg cl
        ; branch r0, false, @printSpaces_ret
        or cl, cl
        jz @printSpaces_ret
        ; const r0, 48
        mov cl, 48
        ; call _, printChar [r0]
        push rcx
          call @printChar
        add rsp, 8
        ; const r0, 1
        mov cx, 1
        ; move r1, i
        lea rax, [rsp+24]
        mov dx, [rax]
        ; sub r0, r1, r0
        mov ax, dx
        sub ax, cx
        mov cx, ax
        ; move i, r0
        lea rax, [rsp+24]
        mov [rax], cx
        jmp @for_20
@printSpaces_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; u8 getDigitCount
        ;   rsp+24: arg value
        ;   rsp+0: var count
        ;   rsp+1: var t.2
        ;   rsp+2: var t.3
        ;   rsp+4: var t.4
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
        ;   rsp+10: var t.7
@getDigitCount:
        ; reserve space for local variables
        sub rsp, 16
        ; const r0, 0
        mov cl, 0
        ; 118:2 if value < 0
        ; const r1, 0
        mov dx, 0
        ; move r2, value
        lea rax, [rsp+24]
        mov r9w, [rax]
        ; lt r1, r2, r1
        cmp r9w, dx
        setl dl
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; branch r1, false, @while_22
        or dl, dl
        jz @while_22
        ; const r0, 1
        mov cl, 1
        ; move r1, value
        lea rax, [rsp+24]
        mov dx, [rax]
        ; neg r1, r1
        neg rdx
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; move value, r1
        lea rax, [rsp+24]
        mov [rax], dx
@while_22:
        ; const r0, 1
        mov cl, 1
        ; move r1, count
        lea rax, [rsp+0]
        mov dl, [rax]
        ; add r0, r1, r0
        mov al, dl
        add al, cl
        mov cl, al
        ; const r1, 10
        mov dx, 10
        ; move r2, value
        lea rax, [rsp+24]
        mov r9w, [rax]
        ; div r1, r2, r1
        movsx rax, r9w
        movsx rbx, dx
        cqo
        idiv rbx
        mov rdx, rax
        ; 126:3 if value == 0
        ; const r2, 0
        mov r9w, 0
        ; equals r2, r1, r2
        cmp dx, r9w
        sete r9b
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; move value, r1
        lea rax, [rsp+24]
        mov [rax], dx
        ; branch r2, false, @while_22
        or r9b, r9b
        jz @while_22
        ; 131:9 return count
        ; move r0, count
        lea rax, [rsp+0]
        mov cl, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 16
        ret

        ; i16 getHiddenCount
        ;   rsp+0: var count
        ;   rsp+2: var r
        ;   rsp+4: var c
        ;   rsp+6: var cell
        ;   rsp+7: var t.4
        ;   rsp+8: var t.5
        ;   rsp+10: var t.6
        ;   rsp+12: var t.7
        ;   rsp+14: var t.8
        ;   rsp+15: var t.9
        ;   rsp+16: var t.10
        ;   rsp+17: var t.11
        ;   rsp+18: var t.12
        ;   rsp+20: var t.13
        ;   rsp+22: var t.14
@getHiddenCount:
        ; reserve space for local variables
        sub rsp, 32
        ; const r0, 0
        mov cx, 0
        ; const r1, 0
        mov dx, 0
        ; 136:2 for r < 20
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cx
        ; move r, r1
        lea rax, [rsp+2]
        mov [rax], dx
@for_24:
        ; const r0, 20
        mov cx, 20
        ; move r1, r
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; branch r0, false, @for_24_break
        or cl, cl
        jz @for_24_break
        ; const r0, 0
        mov cx, 0
        ; 137:3 for c < 40
        ; move c, r0
        lea rax, [rsp+4]
        mov [rax], cx
@for_25:
        ; const r0, 40
        mov cx, 40
        ; move r1, c
        lea rax, [rsp+4]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; branch r0, false, @for_25_break
        or cl, cl
        jz @for_25_break
        ; call r0, getCell, [r, c]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+12]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 139:4 if cell & 6 == 0
        ; const r1, 6
        mov dl, 6
        ; and r0, r0, r1
        and cl, dl
        ; const r1, 0
        mov dl, 0
        ; equals r0, r0, r1
        cmp cl, dl
        sete cl
        ; branch r0, false, @for_25_continue
        or cl, cl
        jz @for_25_continue
        ; const r0, 1
        mov cx, 1
        ; move r1, count
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cx
@for_25_continue:
        ; const r0, 1
        mov cx, 1
        ; move r1, c
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move c, r0
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @for_25
@for_25_break:
        ; const r0, 1
        mov cx, 1
        ; move r1, r
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move r, r0
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_24
@for_24_break:
        ; 144:9 return count
        ; move r0, count
        lea rax, [rsp+0]
        mov cx, [rax]
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 32
        ret

        ; bool printLeft
        ;   rsp+0: var count
        ;   rsp+2: var leftDigits
        ;   rsp+4: var bombDigits
        ;   rsp+6: var t.3
        ;   rsp+7: var t.4
        ;   rsp+8: var t.5
        ;   rsp+16: var t.6
        ;   rsp+24: var t.7
        ;   rsp+32: var t.8
        ;   rsp+40: var t.9
        ;   rsp+42: var t.10
@printLeft:
        ; reserve space for local variables
        sub rsp, 48
        ; call r0, getHiddenCount, []
        sub rsp, 8
          call @getHiddenCount
        add rsp, 8
        mov cx, ax
        ; move count, r0
        lea rax, [rsp+0]
        mov [rax], cx
        ; call r0, getDigitCount, [r0]
        push rcx
          call @getDigitCount
        add rsp, 8
        mov cl, al
        ; cast r0(i16), r0(u8)
        movzx cx, cl
        ; const r1, 40
        mov dx, 40
        ; move leftDigits, r0
        lea rax, [rsp+2]
        mov [rax], cx
        ; call r0, getDigitCount, [r1]
        push rdx
          call @getDigitCount
        add rsp, 8
        mov cl, al
        ; cast r0(i16), r0(u8)
        movzx cx, cl
        ; const r1, [string-1]
        lea rdx, [string_1]
        ; move bombDigits, r0
        lea rax, [rsp+4]
        mov [rax], cx
        ; call _, printString [r1]
        push rdx
          call @printString
        add rsp, 8
        ; move r0, bombDigits
        lea rax, [rsp+4]
        mov cx, [rax]
        ; move r1, leftDigits
        lea rax, [rsp+2]
        mov dx, [rax]
        ; sub r0, r0, r1
        sub cx, dx
        ; call _, printSpaces [r0]
        push rcx
          call @printSpaces
        add rsp, 8
        ; move r0, count
        lea rax, [rsp+0]
        mov cx, [rax]
        ; cast r1(i64), r0(i16)
        movzx rdx, cx
        ; call _, printUint [r1]
        push rdx
          call @printUint
        add rsp, 8
        ; 155:15 return count == 0
        ; const r0, 0
        mov cx, 0
        ; move r1, count
        lea rax, [rsp+0]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; ret r0
        mov rax, rcx
        ; release space for local variables
        add rsp, 48
        ret

        ; i16 abs
        ;   rsp+24: arg a
        ;   rsp+0: var t.1
        ;   rsp+2: var t.2
        ;   rsp+4: var t.3
@abs:
        ; reserve space for local variables
        sub rsp, 16
        ; 159:2 if a < 0
        ; const r0, 0
        mov cx, 0
        ; move r1, a
        lea rax, [rsp+24]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; branch r0, true, @if_27_then
        or cl, cl
        jnz @if_27_then
        ; 162:9 return a
        ; move r0, a
        lea rax, [rsp+24]
        mov cx, [rax]
        ; ret r0
        mov rax, rcx
        jmp @abs_ret
@if_27_then:
        ; 160:10 return -a
        ; move r0, a
        lea rax, [rsp+24]
        mov cx, [rax]
        ; neg r0, r0
        neg rcx
        ; ret r0
        mov rax, rcx
@abs_ret:
        ; release space for local variables
        add rsp, 16
        ret

        ; void clearField
        ;   rsp+0: var r
        ;   rsp+2: var c
        ;   rsp+4: var t.2
        ;   rsp+6: var t.3
        ;   rsp+8: var t.4
        ;   rsp+10: var t.5
        ;   rsp+12: var t.6
        ;   rsp+14: var t.7
        ;   rsp+16: var t.8
@clearField:
        ; reserve space for local variables
        sub rsp, 32
        ; const r0, 0
        mov cx, 0
        ; 166:2 for r < 20
        ; move r, r0
        lea rax, [rsp+0]
        mov [rax], cx
@for_28:
        ; const r0, 20
        mov cx, 20
        ; move r1, r
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; branch r0, false, @clearField_ret
        or cl, cl
        jz @clearField_ret
        ; const r0, 0
        mov cx, 0
        ; 167:3 for c < 40
        ; move c, r0
        lea rax, [rsp+2]
        mov [rax], cx
@for_29:
        ; const r0, 40
        mov cx, 40
        ; move r1, c
        lea rax, [rsp+2]
        mov dx, [rax]
        ; lt r0, r1, r0
        cmp dx, cx
        setl cl
        ; branch r0, false, @for_29_break
        or cl, cl
        jz @for_29_break
        ; const r0, 0
        mov cl, 0
        ; call _, setCell [r, c, r0]
        lea rax, [rsp+0]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
        ; const r0, 1
        mov cx, 1
        ; move r1, c
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move c, r0
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @for_29
@for_29_break:
        ; const r0, 1
        mov cx, 1
        ; move r1, r
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move r, r0
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_28
@clearField_ret:
        ; release space for local variables
        add rsp, 32
        ret

        ; void initField
        ;   rsp+88: arg curr_r
        ;   rsp+80: arg curr_c
        ;   rsp+0: var bombs
        ;   rsp+2: var row
        ;   rsp+4: var column
        ;   rsp+6: var t.5
        ;   rsp+8: var t.6
        ;   rsp+12: var t.7
        ;   rsp+16: var t.8
        ;   rsp+20: var t.9
        ;   rsp+24: var t.10
        ;   rsp+28: var t.11
        ;   rsp+32: var t.12
        ;   rsp+36: var t.13
        ;   rsp+38: var t.14
        ;   rsp+40: var t.15
        ;   rsp+42: var t.16
        ;   rsp+44: var t.17
        ;   rsp+46: var t.18
        ;   rsp+48: var t.19
        ;   rsp+50: var t.20
        ;   rsp+52: var t.21
@initField:
        ; reserve space for local variables
        sub rsp, 64
        ; const r0, 40
        mov cx, 40
        ; 174:2 for bombs > 0
        ; move bombs, r0
        lea rax, [rsp+0]
        mov [rax], cx
@for_30:
        ; const r0, 0
        mov cx, 0
        ; move r1, bombs
        lea rax, [rsp+0]
        mov dx, [rax]
        ; gt r0, r1, r0
        cmp dx, cx
        setg cl
        ; branch r0, false, @initField_ret
        or cl, cl
        jz @initField_ret
        ; call r0, random, []
        sub rsp, 8
          call @random
        add rsp, 8
        mov ecx, eax
        ; const r1, 20
        mov edx, 20
        ; mod r0, r0, r1
        push rdx
        movsxd rax, ecx
        movsxd rbx, edx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; cast r0(i16), r0(i32)
        ; move row, r0
        lea rax, [rsp+2]
        mov [rax], cx
        ; call r0, random, []
        sub rsp, 8
          call @random
        add rsp, 8
        mov ecx, eax
        ; const r1, 40
        mov edx, 40
        ; mod r0, r0, r1
        push rdx
        movsxd rax, ecx
        movsxd rbx, edx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; cast r0(i16), r0(i32)
        ; 177:3 if abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=177:11], right=ExprVarAccess[varName=curr_r, index=0, scope=argument, type=i16, varIsArray=false, location=177:20], location=177:18]]) > 1 || abs([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_c, index=1, scope=argument, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1
        ; 178:4 logic or
        ; move r1, row
        lea rax, [rsp+2]
        mov dx, [rax]
        ; move r2, r1
        mov r9w, dx
        ; move r3, curr_r
        lea rax, [rsp+88]
        mov r10w, [rax]
        ; sub r2, r2, r3
        sub r9w, r10w
        ; move column, r0
        lea rax, [rsp+4]
        mov [rax], cx
        ; call r0, abs, [r2]
        push r9
          call @abs
        add rsp, 8
        mov cx, ax
        ; const r1, 1
        mov dx, 1
        ; gt r0, r0, r1
        cmp cx, dx
        setg cl
        ; move t.13, r0
        lea rax, [rsp+36]
        mov [rax], cl
        ; branch r0, true, @or_next_32
        or cl, cl
        jnz @or_next_32
        ; move r0, column
        lea rax, [rsp+4]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, curr_c
        lea rax, [rsp+80]
        mov r9w, [rax]
        ; sub r1, r1, r2
        sub dx, r9w
        ; call r0, abs, [r1]
        push rdx
          call @abs
        add rsp, 8
        mov cx, ax
        ; const r1, 1
        mov dx, 1
        ; gt r0, r0, r1
        cmp cx, dx
        setg cl
        ; move t.13, r0
        lea rax, [rsp+36]
        mov [rax], cl
@or_next_32:
        ; move r0, t.13
        lea rax, [rsp+36]
        mov cl, [rax]
        ; branch r0, false, @for_30_continue
        or cl, cl
        jz @for_30_continue
        ; const r0, 1
        mov cl, 1
        ; call _, setCell [row, column, r0]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+12]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
@for_30_continue:
        ; const r0, 1
        mov cx, 1
        ; move r1, bombs
        lea rax, [rsp+0]
        mov dx, [rax]
        ; sub r0, r1, r0
        mov ax, dx
        sub ax, cx
        mov cx, ax
        ; move bombs, r0
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_30
@initField_ret:
        ; release space for local variables
        add rsp, 64
        ret

        ; void maybeRevealAround
        ;   rsp+72: arg row
        ;   rsp+64: arg column
        ;   rsp+0: var dr
        ;   rsp+2: var r
        ;   rsp+4: var dc
        ;   rsp+6: var c
        ;   rsp+8: var cell
        ;   rsp+9: var t.7
        ;   rsp+10: var t.8
        ;   rsp+11: var t.9
        ;   rsp+12: var t.10
        ;   rsp+14: var t.11
        ;   rsp+16: var t.12
        ;   rsp+18: var t.13
        ;   rsp+20: var t.14
        ;   rsp+22: var t.15
        ;   rsp+24: var t.16
        ;   rsp+26: var t.17
        ;   rsp+27: var t.18
        ;   rsp+28: var t.19
        ;   rsp+29: var t.20
        ;   rsp+30: var t.21
        ;   rsp+32: var t.22
        ;   rsp+34: var t.23
@maybeRevealAround:
        ; reserve space for local variables
        sub rsp, 48
        ; 185:2 if getBombCountAround([ExprVarAccess[varName=row, index=0, scope=argument, type=i16, varIsArray=false, location=185:25], ExprVarAccess[varName=column, index=1, scope=argument, type=i16, varIsArray=false, location=185:30]]) != 0
        ; call r0, getBombCountAround, [row, column]
        lea rax, [rsp+72]
        mov ax, [rax]
        push rax
        lea rax, [rsp+72]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getBombCountAround
        add rsp, 24
        mov cl, al
        ; const r1, 0
        mov dl, 0
        ; notequals r0, r0, r1
        cmp cl, dl
        setne cl
        ; branch r0, true, @maybeRevealAround_ret
        or cl, cl
        jnz @maybeRevealAround_ret
        ; const r0, -1
        mov cx, -1
        ; 189:2 for dr <= 1
        ; move dr, r0
        lea rax, [rsp+0]
        mov [rax], cx
@for_34:
        ; const r0, 1
        mov cx, 1
        ; move r1, dr
        lea rax, [rsp+0]
        mov dx, [rax]
        ; lteq r0, r1, r0
        cmp dx, cx
        setle cl
        ; branch r0, false, @maybeRevealAround_ret
        or cl, cl
        jz @maybeRevealAround_ret
        ; move r0, row
        lea rax, [rsp+72]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, dr
        lea rax, [rsp+0]
        mov r9w, [rax]
        ; add r1, r1, r2
        add dx, r9w
        ; const r3, -1
        mov r10w, -1
        ; 191:3 for dc <= 1
        ; move r, r1
        lea rax, [rsp+2]
        mov [rax], dx
        ; move dc, r3
        lea rax, [rsp+4]
        mov [rax], r10w
@for_35:
        ; const r0, 1
        mov cx, 1
        ; move r1, dc
        lea rax, [rsp+4]
        mov dx, [rax]
        ; lteq r0, r1, r0
        cmp dx, cx
        setle cl
        ; branch r0, false, @for_35_break
        or cl, cl
        jz @for_35_break
        ; 192:4 if dr == 0 && dc == 0
        ; 192:16 logic and
        ; const r0, 0
        mov cx, 0
        ; move r1, dr
        lea rax, [rsp+0]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; move t.14, r0
        lea rax, [rsp+20]
        mov [rax], cl
        ; branch r0, false, @and_next_37
        or cl, cl
        jz @and_next_37
        ; const r0, 0
        mov cx, 0
        ; move r1, dc
        lea rax, [rsp+4]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; move t.14, r0
        lea rax, [rsp+20]
        mov [rax], cl
@and_next_37:
        ; move r0, t.14
        lea rax, [rsp+20]
        mov cl, [rax]
        ; branch r0, true, @for_35_continue
        or cl, cl
        jnz @for_35_continue
        ; move r0, column
        lea rax, [rsp+64]
        mov cx, [rax]
        ; move r1, r0
        mov dx, cx
        ; move r2, dc
        lea rax, [rsp+4]
        mov r9w, [rax]
        ; add r1, r1, r2
        add dx, r9w
        ; 197:4 if !checkCellBounds([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=197:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=197:28]])
        ; move c, r1
        lea rax, [rsp+6]
        mov [rax], dx
        ; call r0, checkCellBounds, [r, r1]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        push rdx
        sub rsp, 8
          call @checkCellBounds
        add rsp, 24
        mov cl, al
        ; notlog r0, r0
        or cl, cl
        sete cl
        ; branch r0, true, @for_35_continue
        or cl, cl
        jnz @for_35_continue
        ; call r0, getCell, [r, c]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+14]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 202:4 if isOpen([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=202:15]])
        ; move cell, r0
        lea rax, [rsp+8]
        mov [rax], cl
        ; call r0, isOpen, [r0]
        push rcx
          call @isOpen
        add rsp, 8
        mov cl, al
        ; branch r0, true, @for_35_continue
        or cl, cl
        jnz @for_35_continue
        ; const r0, 2
        mov cl, 2
        ; move r1, cell
        lea rax, [rsp+8]
        mov dl, [rax]
        ; or r0, r1, r0
        mov al, dl
        or al, cl
        mov cl, al
        ; call _, setCell [r, c, r0]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+14]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
        ; call _, maybeRevealAround [r, c]
        lea rax, [rsp+2]
        mov ax, [rax]
        push rax
        lea rax, [rsp+14]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @maybeRevealAround
        add rsp, 24
@for_35_continue:
        ; const r0, 1
        mov cx, 1
        ; move r1, dc
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move dc, r0
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @for_35
@for_35_break:
        ; const r0, 1
        mov cx, 1
        ; move r1, dr
        lea rax, [rsp+0]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; move dr, r0
        lea rax, [rsp+0]
        mov [rax], cx
        jmp @for_34
@maybeRevealAround_ret:
        ; release space for local variables
        add rsp, 48
        ret

        ; void main
        ;   rsp+0: var needsInitialize
        ;   rsp+2: var curr_c
        ;   rsp+4: var curr_r
        ;   rsp+6: var chr
        ;   rsp+8: var cell
        ;   rsp+9: var cell
        ;   rsp+12: var t.6
        ;   rsp+16: var t.7
        ;   rsp+17: var t.8
        ;   rsp+18: var t.9
        ;   rsp+19: var t.10
        ;   rsp+24: var t.11
        ;   rsp+32: var t.12
        ;   rsp+34: var t.13
        ;   rsp+36: var t.14
        ;   rsp+38: var t.15
        ;   rsp+40: var t.16
        ;   rsp+42: var t.17
        ;   rsp+44: var t.18
        ;   rsp+46: var t.19
        ;   rsp+48: var t.20
        ;   rsp+50: var t.21
        ;   rsp+52: var t.22
        ;   rsp+54: var t.23
        ;   rsp+56: var t.24
        ;   rsp+58: var t.25
        ;   rsp+60: var t.26
        ;   rsp+62: var t.27
        ;   rsp+64: var t.28
        ;   rsp+66: var t.29
        ;   rsp+68: var t.30
        ;   rsp+70: var t.31
        ;   rsp+72: var t.32
        ;   rsp+74: var t.33
        ;   rsp+76: var t.34
        ;   rsp+78: var t.35
        ;   rsp+80: var t.36
        ;   rsp+82: var t.37
        ;   rsp+84: var t.38
        ;   rsp+86: var t.39
        ;   rsp+88: var t.40
        ;   rsp+90: var t.41
        ;   rsp+92: var t.42
        ;   rsp+94: var t.43
        ;   rsp+96: var t.44
        ;   rsp+98: var t.45
        ;   rsp+100: var t.46
        ;   rsp+102: var t.47
        ;   rsp+103: var t.48
        ;   rsp+104: var t.49
        ;   rsp+105: var t.50
        ;   rsp+106: var t.51
        ;   rsp+108: var t.52
        ;   rsp+110: var t.53
        ;   rsp+111: var t.54
        ;   rsp+112: var t.55
        ;   rsp+113: var t.56
        ;   rsp+114: var t.57
        ;   rsp+120: var t.58
@main:
        ; reserve space for local variables
        sub rsp, 128
        ; begin initialize global variables
        ; const r0, 0
        mov ecx, 0
        ; end initialize global variables
        ; const r1, 7439742
        mov edx, 7439742
        ; move __random__, r0
        lea rax, [var_0]
        mov [rax], ecx
        ; call _, initRandom [r1]
        push rdx
          call @initRandom
        add rsp, 8
        ; const r0, 1
        mov cl, 1
        ; move needsInitialize, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; call _, clearField []
        sub rsp, 8
          call @clearField
        add rsp, 8
        ; const r0, 20
        mov cl, 20
        ; cast r0(i16), r0(u8)
        movzx cx, cl
        ; const r1, 10
        mov dl, 10
        ; cast r1(i16), r1(u8)
        movzx dx, dl
        ; 218:2 while true
        ; move curr_c, r0
        lea rax, [rsp+2]
        mov [rax], cx
        ; move curr_r, r1
        lea rax, [rsp+4]
        mov [rax], dx
@while_40:
        ; call _, printField [curr_r, curr_c]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @printField
        add rsp, 24
        ; 220:3 if !needsInitialize
        ; move r0, needsInitialize
        lea rax, [rsp+0]
        mov cl, [rax]
        ; notlog r1, r0
        or cl, cl
        sete dl
        ; branch r1, false, @if_41_end
        or dl, dl
        jz @if_41_end
        ; 221:4 if printLeft([])
        ; call r0, printLeft, []
        sub rsp, 8
          call @printLeft
        add rsp, 8
        mov cl, al
        ; branch r0, true, @if_42_then
        or cl, cl
        jnz @if_42_then
@if_41_end:
        ; call r0, getChar, []
        sub rsp, 8
          call @getChar
        add rsp, 8
        mov cx, ax
        ; 228:3 if chr == 27
        ; const r1, 27
        mov dx, 27
        ; equals r1, r0, r1
        cmp cx, dx
        sete dl
        ; move chr, r0
        lea rax, [rsp+6]
        mov [rax], cx
        ; branch r1, true, @main_ret
        or dl, dl
        jnz @main_ret
        ; 233:3 if chr == 57416
        ; const r0, 57416
        mov cx, 57416
        ; move r1, chr
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, false, @if_44_else
        or cl, cl
        jz @if_44_else
        ; const r0, 20
        mov cx, 20
        ; move r1, curr_r
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r1, 1
        mov dx, 1
        ; sub r0, r0, r1
        sub cx, dx
        ; const r1, 20
        mov dx, 20
        ; mod r0, r0, r1
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; move curr_r, r0
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @while_40
@if_44_else:
        ; 237:8 if chr == 57424
        ; const r0, 57424
        mov cx, 57424
        ; move r1, chr
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, false, @if_45_else
        or cl, cl
        jz @if_45_else
        ; const r0, 1
        mov cx, 1
        ; move r1, curr_r
        lea rax, [rsp+4]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r1, 20
        mov dx, 20
        ; mod r0, r0, r1
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; move curr_r, r0
        lea rax, [rsp+4]
        mov [rax], cx
        jmp @while_40
@if_45_else:
        ; 241:8 if chr == 57419
        ; const r0, 57419
        mov cx, 57419
        ; move r1, chr
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, false, @if_46_else
        or cl, cl
        jz @if_46_else
        ; const r0, 40
        mov cx, 40
        ; move r1, curr_c
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r1, 1
        mov dx, 1
        ; sub r0, r0, r1
        sub cx, dx
        ; const r1, 40
        mov dx, 40
        ; mod r0, r0, r1
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; move curr_c, r0
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @while_40
@if_46_else:
        ; 245:8 if chr == 57419
        ; const r0, 57419
        mov cx, 57419
        ; move r1, chr
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, false, @if_47_else
        or cl, cl
        jz @if_47_else
        ; const r0, 40
        mov cx, 40
        ; move r1, curr_c
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r1, 1
        mov dx, 1
        ; sub r0, r0, r1
        sub cx, dx
        ; const r1, 40
        mov dx, 40
        ; mod r0, r0, r1
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; move curr_c, r0
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @while_40
@if_47_else:
        ; 249:8 if chr == 57421
        ; const r0, 57421
        mov cx, 57421
        ; move r1, chr
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, false, @if_48_else
        or cl, cl
        jz @if_48_else
        ; const r0, 1
        mov cx, 1
        ; move r1, curr_c
        lea rax, [rsp+2]
        mov dx, [rax]
        ; add r0, r1, r0
        mov ax, dx
        add ax, cx
        mov cx, ax
        ; const r1, 40
        mov dx, 40
        ; mod r0, r0, r1
        push rdx
        movsx rax, cx
        movsx rbx, dx
        cqo
        idiv rbx
        mov rcx, rdx
        pop rdx
        ; move curr_c, r0
        lea rax, [rsp+2]
        mov [rax], cx
        jmp @while_40
@if_48_else:
        ; 253:8 if chr == 32
        ; const r0, 32
        mov cx, 32
        ; move r1, chr
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, true, @if_49_then
        or cl, cl
        jnz @if_49_then
        ; 262:8 if chr == 13
        ; const r0, 13
        mov cx, 13
        ; move r1, chr
        lea rax, [rsp+6]
        mov dx, [rax]
        ; equals r0, r1, r0
        cmp dx, cx
        sete cl
        ; branch r0, false, @while_40
        or cl, cl
        jz @while_40
        jmp @if_52_then
@if_49_then:
        ; 254:4 if !needsInitialize
        ; move r0, needsInitialize
        lea rax, [rsp+0]
        mov cl, [rax]
        ; notlog r1, r0
        or cl, cl
        sete dl
        ; branch r1, false, @while_40
        or dl, dl
        jz @while_40
        jmp @if_50_then
@if_52_then:
        ; move r0, needsInitialize
        lea rax, [rsp+0]
        mov cl, [rax]
        ; branch r0, false, @if_53_end
        or cl, cl
        jz @if_53_end
        jmp @if_53_then
@if_50_then:
        ; call r0, getCell, [curr_r, curr_c]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 256:5 if !isOpen([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=256:17]])
        ; move cell, r0
        lea rax, [rsp+8]
        mov [rax], cl
        ; call r0, isOpen, [r0]
        push rcx
          call @isOpen
        add rsp, 8
        mov cl, al
        ; notlog r0, r0
        or cl, cl
        sete cl
        ; branch r0, false, @while_40
        or cl, cl
        jz @while_40
        jmp @if_51_then
@if_53_then:
        ; const r0, 0
        mov cl, 0
        ; move needsInitialize, r0
        lea rax, [rsp+0]
        mov [rax], cl
        ; call _, initField [curr_r, curr_c]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @initField
        add rsp, 24
        jmp @if_53_end
@if_51_then:
        ; const r0, 4
        mov cl, 4
        ; move r1, cell
        lea rax, [rsp+8]
        mov dl, [rax]
        ; xor r0, r1, r0
        mov al, dl
        xor al, cl
        mov cl, al
        ; call _, setCell [curr_r, curr_c, r0]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
        jmp @while_40
@if_53_end:
        ; call r0, getCell, [curr_r, curr_c]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @getCell
        add rsp, 24
        mov cl, al
        ; 268:4 if !isOpen([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:16]])
        ; move cell, r0
        lea rax, [rsp+9]
        mov [rax], cl
        ; call r0, isOpen, [r0]
        push rcx
          call @isOpen
        add rsp, 8
        mov cl, al
        ; notlog r0, r0
        or cl, cl
        sete cl
        ; branch r0, false, @if_54_end
        or cl, cl
        jz @if_54_end
        ; const r0, 2
        mov cl, 2
        ; move r1, cell
        lea rax, [rsp+9]
        mov dl, [rax]
        ; move r2, r1
        mov r9b, dl
        ; or r0, r2, r0
        mov al, r9b
        or al, cl
        mov cl, al
        ; call _, setCell [curr_r, curr_c, r0]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        push rcx
          call @setCell
        add rsp, 24
@if_54_end:
        ; 271:4 if isBomb([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=271:15]])
        ; call r0, isBomb, [cell]
        lea rax, [rsp+9]
        mov al, [rax]
        push rax
          call @isBomb
        add rsp, 8
        mov cl, al
        ; branch r0, true, @if_55_then
        or cl, cl
        jnz @if_55_then
        ; call _, maybeRevealAround [curr_r, curr_c]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @maybeRevealAround
        add rsp, 24
        jmp @while_40
@if_42_then:
        ; const r0, [string-2]
        lea rcx, [string_2]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
        jmp @main_ret
@if_55_then:
        ; call _, printField [curr_r, curr_c]
        lea rax, [rsp+4]
        mov ax, [rax]
        push rax
        lea rax, [rsp+10]
        mov ax, [rax]
        push rax
        sub rsp, 8
          call @printField
        add rsp, 24
        ; const r0, [string-3]
        lea rcx, [string_3]
        ; call _, printString [r0]
        push rcx
          call @printString
        add rsp, 8
@main_ret:
        ; release space for local variables
        add rsp, 128
        ret

        ; void printStringLength
@printStringLength:
        mov     rdi, rsp

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     rdx, [rdi+18h]
        mov     r8, [rdi+10h]
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
        mov     rdi, rsp
        and     spl, 0xf0

        lea     rcx, [hStdOut]
        mov     rcx, [rcx]
        mov     dx, [rdi+10h]
        shl     rdx, 16
        mov     dx, [rdi+18h]
        sub     rsp, 20h
          call   [SetConsoleCursorPosition]
        mov     rsp, rdi
        ret
init:
        sub rsp, 20h
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
        add rsp, 20h
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
