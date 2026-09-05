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
        call _main
        mov rcx, 0
        sub rsp, 0x20
        call [ExitProcess]

        ; void printString@@u8
        ;   rsp+48: arg str
_printString@@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move str{r6}, str{r1}
        mov rbx, rcx
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; call length{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length{r2}, length{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; void printChar@u8
        ;   rsp+48: arg chr
_printChar@u8:
        sub rsp, 8
        sub rsp, 32
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; addrof t.1{r1}, chr
        lea rcx, [rsp+48]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+48: arg number
_printUint@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1{r1}(i64), number{r1}(i16)
        movsx rcx, cx
        ; call printUint@i64[t.1{r1}]
        call _printUint@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i64
        ;   rsp+96: arg number
        ;   rsp+60: var buffer
_printUint@i64:
        sub rsp, 40
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move number{r6}, number{r1}
        mov rbx, rcx
        ; const pos{r7}, 20
        mov r12b, 20
        ; 28:2 while true
_while_1:
        ; sub pos{r7}, pos{r7}, 1
        sub r12b, 1
        ; move remainder{r3}, number{r6}
        mov r8, rbx
        ; move remainder{r0}, remainder{r3}
        mov rax, r8
        ; mod remainder{r2}, remainder{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move remainder{r3}, remainder{r2}
        mov r8, rdx
        ; move number{r0}, number{r6}
        mov rax, rbx
        ; div number{r0}, number{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move number{r6}, number{r0}
        mov rbx, rax
        ; cast t.5{r0}(u8), remainder{r3}(i64)
        mov al, r8b
        ; add digit{r0}, digit{r0}, 48
        add al, 48
        ; cast t.7{r3}(i64), pos{r7}(u8)
        movzx r8, r12b
        ; addrof t.6{r4}, [buffer]
        lea r9, [rsp+60]
        ; add t.6{r4}, t.6{r4}, t.7{r3}
        add r9, r8
        ; store [t.6{r4}], digit{r0}
        mov [r9], al
        ; 34:3 if number == 0
        ; branch number{r6} notequals 0: while_1, while_1_break
        cmp rbx, 0
        jne _while_1
        ; cast t.9{r6}(i64), pos{r7}(u8)
        movzx rbx, r12b
        ; addrof t.8{r1}, [buffer]
        lea rcx, [rsp+60]
        ; add t.8{r1}, t.8{r1}, t.9{r6}
        add rcx, rbx
        ; const t.11{r6}, 20
        mov bl, 20
        ; move t.10{r2}, t.11{r6}
        mov dl, bl
        ; sub t.10{r2}, t.10{r2}, pos{r7}
        sub dl, r12b
        ; call printStringLength@@u8@u8[t.8{r1}, t.10{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 40
        ret

        ; i64 strlen@@u8
        ;   rsp+16: arg str
_strlen@@u8:
        sub rsp, 8
        ; const length{r0}, 0
        mov rax, 0
        ; 64:2 for *str != 0
        jmp _for_3
_for_3_body:
        ; add length{r0}, length{r0}, 1
        add rax, 1
        ; add str{r1}, str{r1}, 1
        add rcx, 1
_for_3:
        ; load t.2{r2}, [str{r1}]
        mov dl, [rcx]
        ; branch t.2{r2} notequals 0: for_3_body, for_3_break
        cmp dl, 0
        jne _for_3_body
        ; 67:9 return length
        add rsp, 8
        ret

        ; void printStringLength@@u8@u8
        ;   rsp+48: arg str
        ;   rsp+56: arg length
_printStringLength@@u8@u8:
        sub rsp, 8
        sub rsp, 32
        ; cast t.2{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+16: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move tmp.__random__{r0}, salt{r1}
        mov eax, ecx
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; move tmp.__random__{r0}, __random__
        lea r11, [var_0]
        mov eax, [r11]
        ; move r{r1}, tmp.__random__{r0}
        mov ecx, eax
        ; move t.5{r2}, r{r1}
        mov edx, ecx
        ; and t.5{r2}, t.5{r2}, 524287
        and edx, 524287
        ; mul b{r2}, b{r2}, 48271
        movsxd rdx, edx
        imul  rdx, 48271
        ; shiftright t.6{r1}, t.6{r1}, 15
        sar ecx, 15
        ; mul c{r1}, c{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; move t.7{r3}, c{r1}
        mov r8d, ecx
        ; and t.7{r3}, t.7{r3}, 65535
        and r8d, 65535
        ; shiftleft d{r3}, d{r3}, 15
        sal r8d, 15
        ; shiftright t.9{r1}, t.9{r1}, 16
        sar ecx, 16
        ; add t.8{r1}, t.8{r1}, b{r2}
        add ecx, edx
        ; add e{r1}, e{r1}, d{r3}
        add ecx, r8d
        ; move t.10{r2}, e{r1}
        mov edx, ecx
        ; and t.10{r2}, t.10{r2}, 2147483647
        and edx, 2147483647
        ; shiftright t.11{r1}, t.11{r1}, 31
        sar ecx, 31
        ; move tmp.__random__{r0}, t.10{r2}
        mov eax, edx
        ; add tmp.__random__{r0}, tmp.__random__{r0}, t.11{r1}
        add eax, ecx
        ; 15:9 return __random__
        ; move __random__, tmp.__random__{r0}
        lea r11, [var_0]
        mov [r11], eax
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
_rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 16:21 return row * 40 + column
        ; mul t.3{r1}, t.3{r1}, 40
        movsx rcx, cx
        imul  rcx, 40
        ; move t.2{r0}, t.3{r1}
        mov ax, cx
        ; add t.2{r0}, t.2{r0}, column{r2}
        add ax, dx
        add rsp, 8
        ret

        ; u8 getCell@i16@i16
        ;   rsp+48: arg row
        ;   rsp+56: arg column
_getCell@i16@i16:
        sub rsp, 8
        sub rsp, 32
        ; 20:15 return [...]
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4{r1}(i64), t.5{r0}(i16)
        movsx rcx, ax
        ; addrof t.3{r2}, [field]
        lea rdx, [var_1]
        ; add t.3{r2}, t.3{r2}, t.4{r1}
        add rdx, rcx
        ; load t.2{r0}, [t.3{r2}]
        mov al, [rdx]
        add rsp, 32
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+16: arg cell
_isBomb@u8:
        sub rsp, 8
        ; 24:27 return cell & 1 != 0
        ; and t.2{r1}, t.2{r1}, 1
        and cl, 1
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+16: arg cell
_isOpen@u8:
        sub rsp, 8
        ; 28:27 return cell & 2 != 0
        ; and t.2{r1}, t.2{r1}, 2
        and cl, 2
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+16: arg cell
_isFlag@u8:
        sub rsp, 8
        ; 32:27 return cell & 4 != 0
        ; and t.2{r1}, t.2{r1}, 4
        and cl, 4
        ; notequals t.1{r0}, t.2{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool checkCellBounds@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
_checkCellBounds@i16@i16:
        sub rsp, 8
        ; 37:21 return row >= 0 && row < 20 && column >= 0 && column < 40
        ; 37:21 logic and
        ; 37:6 logic and
        ; 36:21 logic and
        ; gteq t.2{r0}, row{r1}, 0
        cmp cx, 0
        setge al
        ; branch t.2{r0} equals 0: and_next_6, and_2nd_6
        cmp al, 0
        je _and_next_6
        ; lt t.2{r0}, row{r1}, 20
        cmp cx, 20
        setl al
_and_next_6:
        ; branch t.2{r0} equals 0: and_next_5, and_2nd_5
        cmp al, 0
        je _and_next_5
        ; gteq t.2{r0}, column{r2}, 0
        cmp dx, 0
        setge al
_and_next_5:
        ; branch t.2{r0} equals 0: checkCellBounds@i16@i16_ret, and_2nd_4
        cmp al, 0
        je _checkCellBounds@i16@i16_ret
        ; lt t.2{r0}, column{r2}, 40
        cmp dx, 40
        setl al
_checkCellBounds@i16@i16_ret:
        add rsp, 8
        ret

        ; void setCell@i16@i16@u8
        ;   rsp+48: arg row
        ;   rsp+56: arg column
        ;   rsp+64: arg cell
_setCell@i16@i16@u8:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move cell{r6}, cell{r3}
        mov bl, r8b
        ; call t.5{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4{r0}(i64), t.5{r0}(i16)
        movsx rax, ax
        ; addrof t.3{r1}, [field]
        lea rcx, [var_1]
        ; add t.3{r1}, t.3{r1}, t.4{r0}
        add rcx, rax
        ; store [t.3{r1}], cell{r6}
        mov [rcx], bl
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getBombCountAround@i16@i16
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+48: var count
        ;   rsp+50: var dr
        ;   rsp+52: var r
        ;   rsp+54: var dc
        ;   rsp+56: var c
_getBombCountAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bx, cx
        ; move column{r7}, column{r2}
        mov r12w, dx
        ; const count{r0}, 0
        mov al, 0
        ; move count, count{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; const dr{r0}, -1
        mov ax, -1
        ; 46:2 for dr <= 1
        ; move dr{r1}, dr{r0}
        mov cx, ax
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp _for_7
_for_7_body:
        ; move count, count{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move dr{r0}, dr{r1}
        mov ax, cx
        ; move r{r1}, row{r6}
        mov cx, bx
        ; add r{r1}, r{r1}, dr{r0}
        add cx, ax
        ; move dr, dr{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; const dc{r0}, -1
        mov ax, -1
        ; 48:3 for dc <= 1
        ; move r, r{r1}
        lea r11, [rsp+52]
        mov [r11], cx
        ; move dc{r1}, dc{r0}
        mov cx, ax
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp _for_8
_for_8_body:
        ; move count, count{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; move dc{r0}, dc{r1}
        mov ax, cx
        ; move r{r1}, r
        lea r11, [rsp+52]
        mov cx, [r11]
        ; move c{r2}, column{r7}
        mov dx, r12w
        ; add c{r2}, c{r2}, dc{r0}
        add dx, ax
        ; move dc, dc{r0}
        lea r11, [rsp+54]
        mov [r11], ax
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; move r, r{r1}
        lea r11, [rsp+52]
        mov [r11], cx
        ; move c, c{r2}
        lea r11, [rsp+56]
        mov [r11], dx
        ; call t.8{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.8{r0} notequals 0: if_9_then, getBombCountAround@i16@i16.no_critical_edge_11
        cmp al, 0
        jne _if_9_then
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp _for_8_continue
_if_9_then:
        ; move r{r1}, r
        lea r11, [rsp+52]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+52]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+56]
        mov dx, [r11]
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call _getCell@i16@i16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; call t.9{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.9{r0} notequals 0: if_10_then, getBombCountAround@i16@i16.no_critical_edge_12
        cmp al, 0
        jne _if_10_then
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        jmp _for_8_continue
_if_10_then:
        ; move count{r0}, count
        lea r11, [rsp+48]
        mov al, [r11]
        ; add count{r0}, count{r0}, 1
        add al, 1
_for_8_continue:
        ; move dc{r1}, dc
        lea r11, [rsp+54]
        mov cx, [r11]
        ; add dc{r1}, dc{r1}, 1
        add cx, 1
_for_8:
        ; branch dc{r1} lteq 1: for_8_body, for_7_continue
        cmp cx, 1
        jle _for_8_body
        ; move dr{r1}, dr
        lea r11, [rsp+50]
        mov cx, [r11]
        ; add dr{r1}, dr{r1}, 1
        add cx, 1
_for_7:
        ; branch dr{r1} lteq 1: for_7_body, for_7_break
        cmp cx, 1
        jle _for_7_body
        ; 58:9 return count
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; u8 getSpacer@i16@i16@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
        ;   rsp+32: arg rowCursor
        ;   rsp+40: arg columnCursor
_getSpacer@i16@i16@i16@i16:
        sub rsp, 8
        ; 62:2 if rowCursor == row
        ; branch rowCursor{r3} notequals row{r1}: if_11_end, if_11_then
        cmp r8w, cx
        jne _if_11_end
        ; branch columnCursor{r4} equals column{r2}: if_12_then, if_12_end
        cmp r9w, dx
        je _if_12_then
        ; 66:3 if columnCursor == column - 1
        ; move t.5{r1}, column{r2}
        mov cx, dx
        ; sub t.5{r1}, t.5{r1}, 1
        sub cx, 1
        ; branch columnCursor{r4} notequals t.5{r1}: if_11_end, if_13_then
        cmp r9w, cx
        jne _if_11_end
        jmp _if_13_then
_if_12_then:
        ; 64:11 return 91
        ; const t.4{r0}, 91
        mov al, 91
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_13_then:
        ; 67:11 return 93
        ; const t.6{r1}, 93
        mov cl, 93
        ; move t.6{r0}, t.6{r1}
        mov al, cl
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_11_end:
        ; 70:9 return 32
        ; const t.7{r1}, 32
        mov cl, 32
        ; move t.7{r0}, t.7{r1}
        mov al, cl
_getSpacer@i16@i16@i16@i16_ret:
        add rsp, 8
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+64: arg cell
        ;   rsp+72: arg row
        ;   rsp+80: arg column
        ;   rsp+48: var chr
_printCell@u8@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move cell{r6}, cell{r1}
        mov bl, cl
        ; move row{r7}, row{r2}
        mov r12w, dx
        ; move column, column{r3}
        lea r11, [rsp+80]
        mov [r11], r8w
        ; const chr{r1}, 46
        mov cl, 46
        ; move chr, chr{r1}
        lea r11, [rsp+48]
        mov [r11], cl
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.5{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.5{r0} notequals 0: if_14_then, if_14_else
        cmp al, 0
        jne _if_14_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.7{r0} = isFlag@u8[cell{r1}] -> bool
        call _isFlag@u8
        ; branch t.7{r0} equals 0: printCell@u8@i16@i16.no_critical_edge_10, if_17_then
        cmp al, 0
        je _printCell@u8@i16@i16.no_critical_edge_10
        jmp _if_17_then
_if_14_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.6{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.6{r0} equals 0: if_15_else, if_15_then
        cmp al, 0
        je _if_15_else
        jmp _if_15_then
_printCell@u8@i16@i16.no_critical_edge_10:
        ; move chr{r6}, chr
        lea r11, [rsp+48]
        mov bl, [r11]
        jmp _if_14_end
_if_17_then:
        ; const chr{r6}, 35
        mov bl, 35
        jmp _if_14_end
_if_15_else:
        ; move row{r1}, row{r7}
        mov cx, r12w
        ; move column{r2}, column
        lea r11, [rsp+80]
        mov dx, [r11]
        ; call count{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; 81:4 if count > 0
        ; branch count{r0} lteq 0: if_16_else, if_16_then
        cmp al, 0
        jbe _if_16_else
        jmp _if_16_then
_if_15_then:
        ; const chr{r6}, 42
        mov bl, 42
        jmp _if_14_end
_if_16_else:
        ; const chr{r6}, 32
        mov bl, 32
        jmp _if_14_end
_if_16_then:
        ; move chr{r6}, count{r0}
        mov bl, al
        ; add chr{r6}, chr{r6}, 48
        add bl, 48
_if_14_end:
        ; move chr{r1}, chr{r6}
        mov cl, bl
        ; call printChar@u8[chr{r1}]
        call _printChar@u8
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printField@i16@i16
        ;   rsp+64: arg rowCursor
        ;   rsp+72: arg columnCursor
        ;   rsp+48: var row
        ;   rsp+50: var column
_printField@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move rowCursor{r6}, rowCursor{r1}
        mov bx, cx
        ; move columnCursor{r7}, columnCursor{r2}
        mov r12w, dx
        ; const arg.0.0{r1}, 0
        mov cx, 0
        ; const arg.0.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.0.0{r1}, arg.0.1{r2}]
        call _setCursor@i16@i16
        ; const row{r1}, 0
        mov cx, 0
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; 97:2 for row < 20
        ; move row{r0}, row
        lea r11, [rsp+48]
        mov ax, [r11]
        jmp _for_18
_for_18_body:
        ; move row, row{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const arg.1.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column{r2}, 0
        mov dx, 0
        ; 99:3 for column < 40
        ; move column{r0}, column{r2}
        mov ax, dx
        jmp _for_19
_for_19_body:
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move column{r2}, column{r0}
        mov dx, ax
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move column, column{r2}
        lea r11, [rsp+50]
        mov [r11], dx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; move columnCursor{r4}, columnCursor{r7}
        mov r9w, r12w
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, column{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov cl, al
        ; call printChar@u8[spacer{r1}]
        call _printChar@u8
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move column{r2}, column
        lea r11, [rsp+50]
        mov dx, [r11]
        ; move column, column{r2}
        lea r11, [rsp+50]
        mov [r11], dx
        ; call cell{r0} = getCell@i16@i16[row{r1}, column{r2}] -> u8
        call _getCell@i16@i16
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move row{r2}, row
        lea r11, [rsp+48]
        mov dx, [r11]
        ; move row, row{r2}
        lea r11, [rsp+48]
        mov [r11], dx
        ; move column{r3}, column
        lea r11, [rsp+50]
        mov r8w, [r11]
        ; move column, column{r3}
        lea r11, [rsp+50]
        mov [r11], r8w
        ; call printCell@u8@i16@i16[cell{r1}, row{r2}, column{r3}]
        call _printCell@u8@i16@i16
        ; move column{r0}, column
        lea r11, [rsp+50]
        mov ax, [r11]
        ; add column{r0}, column{r0}, 1
        add ax, 1
_for_19:
        ; branch column{r0} lt 40: for_19_body, for_19_break
        cmp ax, 40
        jl _for_19_body
        ; move row{r1}, row
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move row, row{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; move columnCursor{r4}, columnCursor{r7}
        mov r9w, r12w
        ; const arg.6.1{r2}, 40
        mov dx, 40
        ; call spacer{r0} = getSpacer@i16@i16@i16@i16[row{r1}, arg.6.1{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer{r1}, spacer{r0}
        mov cl, al
        ; call printChar@u8[spacer{r1}]
        call _printChar@u8
        ; const t.7{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.7{r1}]
        call _printString@@u8
        ; move row{r0}, row
        lea r11, [rsp+48]
        mov ax, [r11]
        ; add row{r0}, row{r0}, 1
        add ax, 1
_for_18:
        ; branch row{r0} lt 20: for_18_body, printField@i16@i16_ret
        cmp ax, 20
        jl _for_18_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printSpaces@i16
        ;   rsp+48: arg i
_printSpaces@i16:
        ; save clobbered non-volatile registers
        push rbx
        sub rsp, 32
        ; move i{r6}, i{r1}
        mov bx, cx
        ; 112:2 for i > 0
        jmp _for_20
_for_20_body:
        ; const arg.0.0{r1}, 48
        mov cl, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; sub i{r6}, i{r6}, 1
        sub bx, 1
_for_20:
        ; branch i{r6} gt 0: for_20_body, printSpaces@i16_ret
        cmp bx, 0
        jg _for_20_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getDigitCount@i16
        ;   rsp+16: arg value
_getDigitCount@i16:
        sub rsp, 8
        ; move value{r3}, value{r1}
        mov r8w, cx
        ; const count{r4}, 0
        mov r9b, 0
        ; 119:2 if value < 0
        ; branch value{r3} gteq 0: while_22, if_21_then
        cmp r8w, 0
        jge _while_22
        ; const count{r4}, 1
        mov r9b, 1
        ; neg value{r3}, value{r3}
        neg r8
_while_22:
        ; add count{r4}, count{r4}, 1
        add r9b, 1
        ; move value{r0}, value{r3}
        mov ax, r8w
        ; div value{r0}, value{r0}, 10
        movsx rax, ax
        mov cx, 10
        cqo
        idiv cx
        ; move value{r3}, value{r0}
        mov r8w, ax
        ; 127:3 if value == 0
        ; branch value{r3} notequals 0: while_22, while_22_break
        cmp r8w, 0
        jne _while_22
        ; 132:9 return count
        ; move count{r0}, count{r4}
        mov al, r9b
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+48: var c
_getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const count{r6}, 0
        mov bx, 0
        ; const r{r7}, 0
        mov r12w, 0
        ; 137:2 for r < 20
        jmp _for_24
_for_24_body:
        ; const c{r2}, 0
        mov dx, 0
        ; 138:3 for c < 40
        ; move c{r1}, c{r2}
        mov cx, dx
        jmp _for_25
_for_25_body:
        ; move c{r2}, c{r1}
        mov dx, cx
        ; move r{r1}, r{r7}
        mov cx, r12w
        ; move c, c{r2}
        lea r11, [rsp+48]
        mov [r11], dx
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call _getCell@i16@i16
        ; 140:4 if cell & 6 == 0
        ; move t.4{r1}, cell{r0}
        mov cl, al
        ; and t.4{r1}, t.4{r1}, 6
        and cl, 6
        ; branch t.4{r1} notequals 0: for_25_continue, if_26_then
        cmp cl, 0
        jne _for_25_continue
        ; add count{r6}, count{r6}, 1
        add bx, 1
_for_25_continue:
        ; move c{r1}, c
        lea r11, [rsp+48]
        mov cx, [r11]
        ; add c{r1}, c{r1}, 1
        add cx, 1
_for_25:
        ; branch c{r1} lt 40: for_25_body, for_24_continue
        cmp cx, 40
        jl _for_25_body
        ; add r{r7}, r{r7}, 1
        add r12w, 1
_for_24:
        ; branch r{r7} lt 20: for_24_body, for_24_break
        cmp r12w, 20
        jl _for_24_body
        ; 145:9 return count
        ; move count{r0}, count{r6}
        mov ax, bx
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+48: var bombDigits
_printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call count{r0} = getHiddenCount[] -> i16
        call _getHiddenCount
        ; move count{r6}, count{r0}
        mov bx, ax
        ; move count{r1}, count{r6}
        mov cx, bx
        ; call t.3{r0} = getDigitCount@i16[count{r1}] -> u8
        call _getDigitCount@i16
        ; cast leftDigits{r7}(i16), t.3{r0}(u8)
        movzx r12w, al
        ; const arg.2.0{r1}, 40
        mov cx, 40
        ; call t.4{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call _getDigitCount@i16
        ; cast bombDigits{r0}(i16), t.4{r0}(u8)
        movzx ax, al
        ; move bombDigits, bombDigits{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const t.5{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.5{r1}]
        call _printString@@u8
        ; move bombDigits{r0}, bombDigits
        lea r11, [rsp+48]
        mov ax, [r11]
        ; move t.6{r1}, bombDigits{r0}
        mov cx, ax
        ; sub t.6{r1}, t.6{r1}, leftDigits{r7}
        sub cx, r12w
        ; call printSpaces@i16[t.6{r1}]
        call _printSpaces@i16
        ; move count{r1}, count{r6}
        mov cx, bx
        ; call printUint@i16[count{r1}]
        call _printUint@i16
        ; 156:15 return count == 0
        ; equals t.7{r0}, count{r6}, 0
        cmp bx, 0
        sete al
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; i16 abs@i16
        ;   rsp+16: arg a
_abs@i16:
        sub rsp, 8
        ; 160:2 if a < 0
        ; branch a{r1} lt 0: if_27_then, if_27_end
        cmp cx, 0
        jl _if_27_then
        ; 163:9 return a
        ; move a{r0}, a{r1}
        mov ax, cx
        jmp _abs@i16_ret
_if_27_then:
        ; 161:10 return -a
        ; neg t.1{r1}, a{r1}
        neg rcx
        ; move t.1{r0}, t.1{r1}
        mov ax, cx
_abs@i16_ret:
        add rsp, 8
        ret

        ; void clearField
_clearField:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const r{r6}, 0
        mov bx, 0
        ; 167:2 for r < 20
        jmp _for_28
_for_28_body:
        ; const c{r7}, 0
        mov r12w, 0
        ; 168:3 for c < 40
        jmp _for_29
_for_29_body:
        ; move r{r1}, r{r6}
        mov cx, bx
        ; move c{r2}, c{r7}
        mov dx, r12w
        ; const arg.0.2{r3}, 0
        mov r8b, 0
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, arg.0.2{r3}]
        call _setCell@i16@i16@u8
        ; add c{r7}, c{r7}, 1
        add r12w, 1
_for_29:
        ; branch c{r7} lt 40: for_29_body, for_28_continue
        cmp r12w, 40
        jl _for_29_body
        ; add r{r6}, r{r6}, 1
        add bx, 1
_for_28:
        ; branch r{r6} lt 20: for_28_body, clearField_ret
        cmp bx, 20
        jl _for_28_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void initField@i16@i16
        ;   rsp+64: arg curr_r
        ;   rsp+72: arg curr_c
        ;   rsp+48: var bombs
        ;   rsp+50: var row
        ;   rsp+52: var column
_initField@i16@i16:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move curr_r{r6}, curr_r{r1}
        mov bx, cx
        ; move curr_c{r7}, curr_c{r2}
        mov r12w, dx
        ; const bombs{r0}, 40
        mov ax, 40
        ; move bombs, bombs{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; 175:2 for bombs > 0
        ; move bombs{r0}, bombs
        lea r11, [rsp+48]
        mov ax, [r11]
        jmp _for_30
_for_30_body:
        ; move bombs, bombs{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; call t.6{r0} = random[] -> i32
        call _random
        ; move t.5{r3}, t.6{r0}
        mov r8d, eax
        ; move t.5{r0}, t.5{r3}
        mov eax, r8d
        ; mod t.5{r2}, t.5{r0}, 20
        movsxd rax, eax
        mov cx, 20
        cqo
        idiv cx
        ; move t.5{r3}, t.5{r2}
        mov r8d, edx
        ; cast row{r1}(i16), t.5{r3}(i32)
        mov cx, r8w
        ; move row, row{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; call t.8{r0} = random[] -> i32
        call _random
        ; move t.7{r3}, t.8{r0}
        mov r8d, eax
        ; move t.7{r0}, t.7{r3}
        mov eax, r8d
        ; mod t.7{r2}, t.7{r0}, 40
        movsxd rax, eax
        mov cx, 40
        cqo
        idiv cx
        ; move t.7{r3}, t.7{r2}
        mov r8d, edx
        ; cast column{r2}(i16), t.7{r3}(i32)
        mov dx, r8w
        ; move column, column{r2}
        lea r11, [rsp+52]
        mov [r11], dx
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; move row{r0}, row
        lea r11, [rsp+50]
        mov ax, [r11]
        ; move t.10{r1}, row{r0}
        mov cx, ax
        ; move row, row{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; sub t.10{r1}, t.10{r1}, curr_r{r6}
        sub cx, bx
        ; call t.9{r0} = abs@i16[t.10{r1}] -> i16
        call _abs@i16
        ; branch t.9{r0} gt 1: if_31_then, or_32
        cmp ax, 1
        jg _if_31_then
        ; move column{r0}, column
        lea r11, [rsp+52]
        mov ax, [r11]
        ; move t.12{r1}, column{r0}
        mov cx, ax
        ; move column, column{r0}
        lea r11, [rsp+52]
        mov [r11], ax
        ; sub t.12{r1}, t.12{r1}, curr_c{r7}
        sub cx, r12w
        ; call t.11{r0} = abs@i16[t.12{r1}] -> i16
        call _abs@i16
        ; branch t.11{r0} lteq 1: for_30_continue, if_31_then
        cmp ax, 1
        jle _for_30_continue
_if_31_then:
        ; move row{r1}, row
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move column{r2}, column
        lea r11, [rsp+52]
        mov dx, [r11]
        ; const arg.4.2{r3}, 1
        mov r8b, 1
        ; call setCell@i16@i16@u8[row{r1}, column{r2}, arg.4.2{r3}]
        call _setCell@i16@i16@u8
_for_30_continue:
        ; move bombs{r0}, bombs
        lea r11, [rsp+48]
        mov ax, [r11]
        ; sub bombs{r0}, bombs{r0}, 1
        sub ax, 1
_for_30:
        ; branch bombs{r0} gt 0: for_30_body, initField@i16@i16_ret
        cmp ax, 0
        jg _for_30_body
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void maybeRevealAround@i16@i16
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+48: var dr
        ;   rsp+50: var r
        ;   rsp+52: var dc
        ;   rsp+54: var c
        ;   rsp+56: var cell
_maybeRevealAround@i16@i16:
        sub rsp, 24
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; move row{r6}, row{r1}
        mov bx, cx
        ; move column{r7}, column{r2}
        mov r12w, dx
        ; 186:2 if getBombCountAround@i16@i16([ExprVarAccess[varName=row, index=0, scope=parameter, type=i16, varIsArray=false, location=186:25], ExprVarAccess[varName=column, index=1, scope=parameter, type=i16, varIsArray=false, location=186:30]]) != 0
        ; move row{r1}, row{r6}
        mov cx, bx
        ; move column{r2}, column{r7}
        mov dx, r12w
        ; call t.7{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; branch t.7{r0} notequals 0: maybeRevealAround@i16@i16_ret, if_33_end
        cmp al, 0
        jne _maybeRevealAround@i16@i16_ret
        ; const dr{r0}, -1
        mov ax, -1
        ; 190:2 for dr <= 1
        jmp _for_34
_for_34_body:
        ; move r{r1}, row{r6}
        mov cx, bx
        ; add r{r1}, r{r1}, dr{r0}
        add cx, ax
        ; const dc{r3}, -1
        mov r8w, -1
        ; 192:3 for dc <= 1
        ; move dr, dr{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move dc{r0}, dc{r3}
        mov ax, r8w
        jmp _for_35
_for_35_body:
        ; move dc{r3}, dc{r0}
        mov r8w, ax
        ; move dr{r0}, dr
        lea r11, [rsp+48]
        mov ax, [r11]
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; branch dr{r0} notequals 0: maybeRevealAround@i16@i16.no_critical_edge_15, and_37
        cmp ax, 0
        jne _maybeRevealAround@i16@i16.no_critical_edge_15
        ; move dr, dr{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        jmp _and_37
_maybeRevealAround@i16@i16.no_critical_edge_15:
        ; move dr, dr{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        jmp _if_36_end
_and_37:
        ; move dr, dr{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; branch dc{r3} notequals 0: if_36_end, maybeRevealAround@i16@i16.no_critical_edge_18
        cmp r8w, 0
        jne _if_36_end
        ; move dc, dc{r3}
        lea r11, [rsp+52]
        mov [r11], r8w
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        jmp _for_35_continue
_if_36_end:
        ; move c{r2}, column{r7}
        mov dx, r12w
        ; add c{r2}, c{r2}, dc{r3}
        add dx, r8w
        ; move dc, dc{r3}
        lea r11, [rsp+52]
        mov [r11], r8w
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c, c{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call t.8{r0} = checkCellBounds@i16@i16[r{r1}, c{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.8{r0} equals 0: for_35_continue, if_38_end
        cmp al, 0
        je _for_35_continue
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+54]
        mov dx, [r11]
        ; move c, c{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call cell{r0} = getCell@i16@i16[r{r1}, c{r2}] -> u8
        call _getCell@i16@i16
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move cell, cell{r0}
        lea r11, [rsp+56]
        mov [r11], al
        ; call t.9{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.9{r0} notequals 0: for_35_continue, if_39_end
        cmp al, 0
        jne _for_35_continue
        ; move cell{r0}, cell
        lea r11, [rsp+56]
        mov al, [r11]
        ; move t.10{r3}, cell{r0}
        mov r8b, al
        ; or t.10{r3}, t.10{r3}, 2
        or r8b, 2
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+54]
        mov dx, [r11]
        ; move c, c{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call setCell@i16@i16@u8[r{r1}, c{r2}, t.10{r3}]
        call _setCell@i16@i16@u8
        ; move r{r1}, r
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r, r{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c{r2}, c
        lea r11, [rsp+54]
        mov dx, [r11]
        ; call maybeRevealAround@i16@i16[r{r1}, c{r2}]
        call _maybeRevealAround@i16@i16
_for_35_continue:
        ; move dc{r0}, dc
        lea r11, [rsp+52]
        mov ax, [r11]
        ; add dc{r0}, dc{r0}, 1
        add ax, 1
_for_35:
        ; branch dc{r0} lteq 1: for_35_body, for_34_continue
        cmp ax, 1
        jle _for_35_body
        ; move dr{r0}, dr
        lea r11, [rsp+48]
        mov ax, [r11]
        ; add dr{r0}, dr{r0}, 1
        add ax, 1
_for_34:
        ; branch dr{r0} lteq 1: for_34_body, maybeRevealAround@i16@i16_ret
        cmp ax, 1
        jle _for_34_body
_maybeRevealAround@i16@i16_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 24
        ret

        ; void main
        ;   rsp+48: var curr_r
        ;   rsp+50: var cell
        ;   rsp+51: var cell
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const tmp.__random__{r6}, 0
        mov ebx, 0
        ; end initialize global variables
        ; move __random__, tmp.__random__{r6}
        lea r11, [var_0]
        mov [r11], ebx
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const needsInitialize{r6}, 1
        mov bl, 1
        ; call clearField[]
        call _clearField
        ; const curr_c{r7}, 20
        mov r12w, 20
        ; const curr_r{r0}, 10
        mov ax, 10
        ; move curr_r, curr_r{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; 219:2 while true
        jmp _while_40
_if_41_then:
        ; 222:4 if printLeft([])
        ; call t.6{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.6{r0} notequals 0: if_42_then, if_41_end
        cmp al, 0
        jne _if_42_then
_if_41_end:
        ; call chr{r0} = getChar[] -> i16
        call _getChar
        ; move chr{r3}, chr{r0}
        mov r8w, ax
        ; 229:3 if chr == 27
        ; branch chr{r3} equals 27: main_ret, if_43_end
        cmp r8w, 27
        je _main_ret
        ; branch chr{r3} equals -8120: if_44_then, if_44_else
        cmp r8w, -8120
        je _if_44_then
        ; branch chr{r3} notequals -8112: if_45_else, if_45_then
        cmp r8w, -8112
        jne _if_45_else
        jmp _if_45_then
_if_44_then:
        ; move curr_r{r4}, curr_r
        lea r11, [rsp+48]
        mov r9w, [r11]
        ; move t.9{r3}, curr_r{r4}
        mov r8w, r9w
        ; add t.9{r3}, t.9{r3}, 20
        add r8w, 20
        ; sub t.8{r3}, t.8{r3}, 1
        sub r8w, 1
        ; move curr_r{r4}, t.8{r3}
        mov r9w, r8w
        ; move curr_r{r0}, curr_r{r4}
        mov ax, r9w
        ; mod curr_r{r2}, curr_r{r0}, 20
        movsx rax, ax
        mov cx, 20
        cqo
        idiv cx
        ; move curr_r{r4}, curr_r{r2}
        mov r9w, dx
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        jmp _while_40
_if_45_else:
        ; move curr_r{r4}, curr_r
        lea r11, [rsp+48]
        mov r9w, [r11]
        ; branch chr{r3} notequals -8117: if_46_else, if_46_then
        cmp r8w, -8117
        jne _if_46_else
        jmp _if_46_then
_if_45_then:
        ; move curr_r{r4}, curr_r
        lea r11, [rsp+48]
        mov r9w, [r11]
        ; move t.10{r3}, curr_r{r4}
        mov r8w, r9w
        ; add t.10{r3}, t.10{r3}, 1
        add r8w, 1
        ; move curr_r{r4}, t.10{r3}
        mov r9w, r8w
        ; move curr_r{r0}, curr_r{r4}
        mov ax, r9w
        ; mod curr_r{r2}, curr_r{r0}, 20
        movsx rax, ax
        mov cx, 20
        cqo
        idiv cx
        ; move curr_r{r4}, curr_r{r2}
        mov r9w, dx
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        jmp _while_40
_if_46_else:
        ; branch chr{r3} notequals -8115: if_47_else, if_47_then
        cmp r8w, -8115
        jne _if_47_else
        jmp _if_47_then
_if_46_then:
        ; add t.12{r7}, t.12{r7}, 40
        add r12w, 40
        ; sub t.11{r7}, t.11{r7}, 1
        sub r12w, 1
        ; move curr_c{r0}, curr_c{r7}
        mov ax, r12w
        ; mod curr_c{r2}, curr_c{r0}, 40
        movsx rax, ax
        mov cx, 40
        cqo
        idiv cx
        ; move curr_c{r7}, curr_c{r2}
        mov r12w, dx
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        jmp _while_40
_if_47_else:
        ; branch chr{r3} notequals 32: if_48_else, if_48_then
        cmp r8w, 32
        jne _if_48_else
        jmp _if_48_then
_if_47_then:
        ; add t.13{r7}, t.13{r7}, 1
        add r12w, 1
        ; move curr_c{r0}, curr_c{r7}
        mov ax, r12w
        ; mod curr_c{r2}, curr_c{r0}, 40
        movsx rax, ax
        mov cx, 40
        cqo
        idiv cx
        ; move curr_c{r7}, curr_c{r2}
        mov r12w, dx
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        jmp _while_40
_if_48_else:
        ; branch chr{r3} notequals 13: main.no_critical_edge_28, if_51_then
        cmp r8w, 13
        jne _main.no_critical_edge_28
        jmp _if_51_then
_if_48_then:
        ; branch needsInitialize{r6} notequals 0: main.no_critical_edge_31, if_49_then
        cmp bl, 0
        jne _main.no_critical_edge_31
        jmp _if_49_then
_main.no_critical_edge_28:
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        jmp _while_40
_if_51_then:
        ; branch needsInitialize{r6} equals 0: main.no_critical_edge_29, if_52_then
        cmp bl, 0
        je _main.no_critical_edge_29
        jmp _if_52_then
_main.no_critical_edge_31:
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        jmp _while_40
_if_49_then:
        ; move curr_r{r1}, curr_r{r4}
        mov cx, r9w
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call _getCell@i16@i16
        ; 253:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=253:17]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move cell, cell{r0}
        lea r11, [rsp+50]
        mov [r11], al
        ; call t.14{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.14{r0} notequals 0: while_40, if_50_then
        cmp al, 0
        jne _while_40
        jmp _if_50_then
_main.no_critical_edge_29:
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        jmp _if_52_end
_if_52_then:
        ; move curr_r, curr_r{r4}
        lea r11, [rsp+48]
        mov [r11], r9w
        ; const needsInitialize{r6}, 0
        mov bl, 0
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call initField@i16@i16[curr_r{r1}, curr_c{r2}]
        call _initField@i16@i16
        jmp _if_52_end
_if_50_then:
        ; move cell{r3}, cell
        lea r11, [rsp+50]
        mov r8b, [r11]
        ; xor cell{r3}, cell{r3}, 4
        xor r8b, 4
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, cell{r3}]
        call _setCell@i16@i16@u8
        jmp _while_40
_if_52_end:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call cell{r0} = getCell@i16@i16[curr_r{r1}, curr_c{r2}] -> u8
        call _getCell@i16@i16
        ; 265:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=265:16]])
        ; move cell{r1}, cell{r0}
        mov cl, al
        ; move cell, cell{r0}
        lea r11, [rsp+51]
        mov [r11], al
        ; call t.15{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.15{r0} notequals 0: if_53_end, if_53_then
        cmp al, 0
        jne _if_53_end
        ; move cell{r0}, cell
        lea r11, [rsp+51]
        mov al, [r11]
        ; move t.16{r3}, cell{r0}
        mov r8b, al
        ; move cell, cell{r0}
        lea r11, [rsp+51]
        mov [r11], al
        ; or t.16{r3}, t.16{r3}, 2
        or r8b, 2
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call setCell@i16@i16@u8[curr_r{r1}, curr_c{r2}, t.16{r3}]
        call _setCell@i16@i16@u8
_if_53_end:
        ; 268:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=268:15]])
        ; move cell{r1}, cell
        lea r11, [rsp+51]
        mov cl, [r11]
        ; call t.17{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.17{r0} notequals 0: if_54_then, if_54_end
        cmp al, 0
        jne _if_54_then
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call maybeRevealAround@i16@i16[curr_r{r1}, curr_c{r2}]
        call _maybeRevealAround@i16@i16
_while_40:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_r, curr_r{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call _printField@i16@i16
        ; 221:3 if !needsInitialize
        ; branch needsInitialize{r6} notequals 0: if_41_end, if_41_then
        cmp bl, 0
        jne _if_41_end
        jmp _if_41_then
_if_42_then:
        ; const t.7{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.7{r1}]
        call _printString@@u8
        jmp _main_ret
_if_54_then:
        ; move curr_r{r1}, curr_r
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move curr_c{r2}, curr_c{r7}
        mov dx, r12w
        ; call printField@i16@i16[curr_r{r1}, curr_c{r2}]
        call _printField@i16@i16
        ; const t.18{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.18{r1}]
        call _printString@@u8
_main_ret:
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; void printStringLength@@u8@i64
_printStringLength@@u8@i64:
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
_getChar:
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

        ; void setCursor@i16@i16
_setCursor@i16@i16:
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
