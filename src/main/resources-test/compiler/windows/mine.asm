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
        ; call length.1{r0} = strlen@@u8[str{r1}] -> i64
        call _strlen@@u8
        ; move str{r1}, str{r6}
        mov rcx, rbx
        ; move length.1{r2}, length.1{r0}
        mov rdx, rax
        ; call printStringLength@@u8@i64[str{r1}, length.1{r2}]
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
        ; addrof t.1.1{r1}, chr
        lea rcx, [rsp+48]
        ; const arg.0.1{r2}, 1
        mov dl, 1
        ; call printStringLength@@u8@u8[t.1.1{r1}, arg.0.1{r2}]
        call _printStringLength@@u8@u8
        add rsp, 32
        add rsp, 8
        ret

        ; void printUint@i16
        ;   rsp+48: arg number
_printUint@i16:
        sub rsp, 8
        sub rsp, 32
        ; cast t.1.1{r1}(i64), number{r1}(i16)
        movsx rcx, cx
        ; call printUint@i64[t.1.1{r1}]
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
        ; const pos.1{r6}, 20
        mov bl, 20
        ; 28:2 while true
        ; move number.1{r7}, number{r1}
        mov r12, rcx
_while_1:
        ; sub pos.3{r6}, pos.3{r6}, 1
        sub bl, 1
        ; move remainder.1{r3}, number.1{r7}
        mov r8, r12
        ; move remainder.1{r0}, remainder.1{r3}
        mov rax, r8
        ; mod remainder.1{r2}, remainder.1{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move remainder.1{r3}, remainder.1{r2}
        mov r8, rdx
        ; move number.2{r0}, number.2{r7}
        mov rax, r12
        ; div number.2{r0}, number.2{r0}, 10
        mov cx, 10
        cqo
        idiv cx
        ; move number.2{r7}, number.2{r0}
        mov r12, rax
        ; cast t.5.1{r0}(u8), remainder.1{r3}(i64)
        mov al, r8b
        ; add digit.1{r0}, digit.1{r0}, 48
        add al, 48
        ; cast t.7.1{r3}(i64), pos.3{r6}(u8)
        movzx r8, bl
        ; addrof t.6.1{r4}, [buffer]
        lea r9, [rsp+60]
        ; add t.6.2{r4}, t.6.2{r4}, t.7.1{r3}
        add r9, r8
        ; store [t.6.2{r4}], digit.1{r0}
        mov [r9], al
        ; 34:3 if number == 0
        ; branch number.2{r7} notequals 0: while_1, while_1_break
        cmp r12, 0
        jne _while_1
        ; cast t.9.1{r7}(i64), pos.3{r6}(u8)
        movzx r12, bl
        ; addrof t.8.1{r0}, [buffer]
        lea rax, [rsp+60]
        ; move t.8.2{r1}, t.8.1{r0}
        mov rcx, rax
        ; add t.8.2{r1}, t.8.2{r1}, t.9.1{r7}
        add rcx, r12
        ; const t.11.1{r7}, 20
        mov r12b, 20
        ; move t.10.1{r2}, t.11.1{r7}
        mov dl, r12b
        ; sub t.10.1{r2}, t.10.1{r2}, pos.3{r6}
        sub dl, bl
        ; call printStringLength@@u8@u8[t.8.2{r1}, t.10.1{r2}]
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
        ; const length.1{r2}, 0
        mov rdx, 0
        ; 64:2 for *str != 0
        ; move length.2{r0}, length.1{r2}
        mov rax, rdx
        jmp _for_3
_for_3_body:
        ; move length.3{r2}, length.2{r0}
        mov rdx, rax
        ; add length.3{r2}, length.3{r2}, 1
        add rdx, 1
        ; add str.2{r1}, str.2{r1}, 1
        add rcx, 1
        ; move length.2{r0}, length.3{r2}
        mov rax, rdx
_for_3:
        ; load t.2.1{r2}, [str.1{r1}]
        mov dl, [rcx]
        ; branch t.2.1{r2} notequals 0: for_3_body, for_3_break
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
        ; cast t.2.1{r2}(i64), length{r2}(u8)
        movzx rdx, dl
        ; call printStringLength@@u8@i64[str{r1}, t.2.1{r2}]
        call _printStringLength@@u8@i64
        add rsp, 32
        add rsp, 8
        ret

        ; void initRandom@i32
        ;   rsp+16: arg salt
_initRandom@i32:
        sub rsp, 8
        ; move t.__random__{r0}, salt{r1}
        mov eax, ecx
        ; addrof a.__random__{r1}, __random__
        lea rcx, [var_0]
        ; store [a.__random__{r1}], t.__random__{r0}
        mov [rcx], eax
        add rsp, 8
        ret

        ; i32 random
_random:
        sub rsp, 8
        ; addrof a.__random__{r1}, __random__
        lea rcx, [var_0]
        ; load t.__random__{r1}, [a.__random__{r1}]
        mov ecx, [rcx]
        ; move t.5.1{r2}, r.1{r1}
        mov edx, ecx
        ; and t.5.1{r2}, t.5.1{r2}, 524287
        and edx, 524287
        ; mul b.1{r2}, b.1{r2}, 48271
        movsxd rdx, edx
        imul  rdx, 48271
        ; shiftright t.6.1{r1}, t.6.1{r1}, 15
        sar ecx, 15
        ; mul c.1{r1}, c.1{r1}, 48271
        movsxd rcx, ecx
        imul  rcx, 48271
        ; move t.7.1{r3}, c.1{r1}
        mov r8d, ecx
        ; and t.7.1{r3}, t.7.1{r3}, 65535
        and r8d, 65535
        ; shiftleft d.1{r3}, d.1{r3}, 15
        sal r8d, 15
        ; shiftright t.9.1{r1}, t.9.1{r1}, 16
        sar ecx, 16
        ; add t.8.1{r1}, t.8.1{r1}, b.1{r2}
        add ecx, edx
        ; add e.1{r1}, e.1{r1}, d.1{r3}
        add ecx, r8d
        ; move t.10.1{r2}, e.1{r1}
        mov edx, ecx
        ; and t.10.1{r2}, t.10.1{r2}, 2147483647
        and edx, 2147483647
        ; shiftright t.11.1{r1}, t.11.1{r1}, 31
        sar ecx, 31
        ; add t.__random__1{r2}, t.__random__1{r2}, t.11.1{r1}
        add edx, ecx
        ; addrof a.__random__1{r1}, __random__
        lea rcx, [var_0]
        ; store [a.__random__1{r1}], t.__random__1{r2}
        mov [rcx], edx
        ; 15:9 return __random__
        ; addrof a.__random__2{r1}, __random__
        lea rcx, [var_0]
        ; load t.__random__2{r0}, [a.__random__2{r1}]
        mov eax, [rcx]
        add rsp, 8
        ret

        ; i16 rowColumnToCell@i16@i16
        ;   rsp+16: arg row
        ;   rsp+24: arg column
_rowColumnToCell@i16@i16:
        sub rsp, 8
        ; 16:21 return row * 40 + column
        ; mul t.3.1{r1}, t.3.1{r1}, 40
        movsx rcx, cx
        imul  rcx, 40
        ; move t.2.1{r0}, t.3.1{r1}
        mov ax, cx
        ; add t.2.1{r0}, t.2.1{r0}, column{r2}
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
        ; call t.5.1{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4.1{r1}(i64), t.5.1{r0}(i16)
        movsx rcx, ax
        ; addrof t.3.1{r2}, [field]
        lea rdx, [var_1]
        ; add t.3.2{r2}, t.3.2{r2}, t.4.1{r1}
        add rdx, rcx
        ; load t.2.1{r0}, [t.3.2{r2}]
        mov al, [rdx]
        add rsp, 32
        add rsp, 8
        ret

        ; bool isBomb@u8
        ;   rsp+16: arg cell
_isBomb@u8:
        sub rsp, 8
        ; 24:27 return cell & 1 != 0
        ; and t.2.1{r1}, t.2.1{r1}, 1
        and cl, 1
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool isOpen@u8
        ;   rsp+16: arg cell
_isOpen@u8:
        sub rsp, 8
        ; 28:27 return cell & 2 != 0
        ; and t.2.1{r1}, t.2.1{r1}, 2
        and cl, 2
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
        cmp cl, 0
        setne al
        add rsp, 8
        ret

        ; bool isFlag@u8
        ;   rsp+16: arg cell
_isFlag@u8:
        sub rsp, 8
        ; 32:27 return cell & 4 != 0
        ; and t.2.1{r1}, t.2.1{r1}, 4
        and cl, 4
        ; notequals t.1.1{r0}, t.2.1{r1}, 0
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
        ; 36:40 logic and
        ; 36:21 logic and
        ; gteq t.2.1{r3}, row{r1}, 0
        cmp cx, 0
        setge r8b
        ; branch t.2.1{r3} notequals 0: and_2nd_6, checkCellBounds@i16@i16.no_critical_edge_8
        cmp r8b, 0
        jne _and_2nd_6
        ; move t.2.2{r1}, t.2.1{r3}
        mov cl, r8b
        jmp _and_next_6
_and_2nd_6:
        ; lt t.2.3{r1}, row{r1}, 20
        cmp cx, 20
        setl cl
_and_next_6:
        ; branch t.2.2{r1} equals 0: and_next_5, and_2nd_5
        cmp cl, 0
        je _and_next_5
        ; gteq t.2.5{r1}, column{r2}, 0
        cmp dx, 0
        setge cl
_and_next_5:
        ; branch t.2.4{r1} notequals 0: and_2nd_4, checkCellBounds@i16@i16.no_critical_edge_10
        cmp cl, 0
        jne _and_2nd_4
        ; move t.2.6{r0}, t.2.4{r1}
        mov al, cl
        jmp _checkCellBounds@i16@i16_ret
_and_2nd_4:
        ; lt t.2.7{r1}, column{r2}, 40
        cmp dx, 40
        setl cl
        ; move t.2.6{r0}, t.2.7{r1}
        mov al, cl
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
        ; call t.5.1{r0} = rowColumnToCell@i16@i16[row{r1}, column{r2}] -> i16
        call _rowColumnToCell@i16@i16
        ; cast t.4.1{r0}(i64), t.5.1{r0}(i16)
        movsx rax, ax
        ; addrof t.3.1{r1}, [field]
        lea rcx, [var_1]
        ; add t.3.2{r1}, t.3.2{r1}, t.4.1{r0}
        add rcx, rax
        ; store [t.3.2{r1}], cell{r6}
        mov [rcx], bl
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop rbx
        ret

        ; u8 getBombCountAround@i16@i16
        ;   rsp+80: arg row
        ;   rsp+88: arg column
        ;   rsp+48: var dr.2
        ;   rsp+50: var r.1
        ;   rsp+52: var count.3
        ;   rsp+54: var dc.2
        ;   rsp+56: var c.1
        ;   rsp+58: var count.4
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
        ; const count.1{r0}, 0
        mov al, 0
        ; const dr.1{r3}, -1
        mov r8w, -1
        ; 46:2 for dr <= 1
        ; move dr.2{r2}, dr.2{r3}
        mov dx, r8w
        jmp _for_7
_for_7_body:
        ; move dr.2{r3}, dr.2{r2}
        mov r8w, dx
        ; move r.1{r1}, row{r6}
        mov cx, bx
        ; add r.1{r1}, r.1{r1}, dr.2{r3}
        add cx, r8w
        ; move dr.2, dr.2{r3}
        lea r11, [rsp+48]
        mov [r11], r8w
        ; const dc.1{r3}, -1
        mov r8w, -1
        ; 48:3 for dc <= 1
        ; move count.3, count.3{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; move dc.2{r0}, dc.1{r3}
        mov ax, r8w
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move dc.2{r2}, dc.2{r0}
        mov dx, ax
        ; move count.3{r1}, count.3
        lea r11, [rsp+52]
        mov cl, [r11]
        jmp _for_8
_for_8_body:
        ; move count.3, count.3{r1}
        lea r11, [rsp+52]
        mov [r11], cl
        ; move dc.2{r0}, dc.2{r2}
        mov ax, dx
        ; move r.1{r1}, r.1
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move c.1{r2}, column{r7}
        mov dx, r12w
        ; add c.1{r2}, c.1{r2}, dc.2{r0}
        add dx, ax
        ; move dc.2, dc.2{r0}
        lea r11, [rsp+54]
        mov [r11], ax
        ; 50:4 if checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=4, scope=function, type=i16, varIsArray=false, location=50:24], ExprVarAccess[varName=c, index=6, scope=function, type=i16, varIsArray=false, location=50:27]])
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c.1, c.1{r2}
        lea r11, [rsp+56]
        mov [r11], dx
        ; call t.8.1{r0} = checkCellBounds@i16@i16[r.1{r1}, c.1{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.8.1{r0} notequals 0: if_9_then, getBombCountAround@i16@i16.no_critical_edge_11
        cmp al, 0
        jne _if_9_then
        ; move count.3{r0}, count.3
        lea r11, [rsp+52]
        mov al, [r11]
        ; move count.4, count.4{r0}
        lea r11, [rsp+58]
        mov [r11], al
        ; move count.4{r1}, count.4
        lea r11, [rsp+58]
        mov cl, [r11]
        jmp _for_8_continue
_if_9_then:
        ; move r.1{r1}, r.1
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c.1{r2}, c.1
        lea r11, [rsp+56]
        mov dx, [r11]
        ; call cell.1{r0} = getCell@i16@i16[r.1{r1}, c.1{r2}] -> u8
        call _getCell@i16@i16
        ; 52:5 if isBomb@u8([ExprVarAccess[varName=cell, index=7, scope=function, type=u8, varIsArray=false, location=52:16]])
        ; move cell.1{r1}, cell.1{r0}
        mov cl, al
        ; call t.9.1{r0} = isBomb@u8[cell.1{r1}] -> bool
        call _isBomb@u8
        ; branch t.9.1{r0} notequals 0: if_10_then, getBombCountAround@i16@i16.no_critical_edge_12
        cmp al, 0
        jne _if_10_then
        ; move count.3{r1}, count.3
        lea r11, [rsp+52]
        mov cl, [r11]
        jmp _for_8_continue
_if_10_then:
        ; move count.3{r1}, count.3
        lea r11, [rsp+52]
        mov cl, [r11]
        ; add count.5{r1}, count.5{r1}, 1
        add cl, 1
_for_8_continue:
        ; move dc.2{r2}, dc.2
        lea r11, [rsp+54]
        mov dx, [r11]
        ; add dc.4{r2}, dc.4{r2}, 1
        add dx, 1
_for_8:
        ; branch dc.2{r2} lteq 1: for_8_body, for_7_continue
        cmp dx, 1
        jle _for_8_body
        ; move dr.2{r2}, dr.2
        lea r11, [rsp+48]
        mov dx, [r11]
        ; add dr.4{r2}, dr.4{r2}, 1
        add dx, 1
        ; move count.2{r0}, count.3{r1}
        mov al, cl
_for_7:
        ; branch dr.2{r2} lteq 1: for_7_body, for_7_break
        cmp dx, 1
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
        ; branch rowCursor{r3} notequals row{r1}: if_11_end, if_11_then
        cmp r8w, cx
        jne _if_11_end
        ; branch columnCursor{r4} equals column{r2}: if_12_then, if_12_end
        cmp r9w, dx
        je _if_12_then
        ; 66:3 if columnCursor == column - 1
        ; move t.4.1{r1}, column{r2}
        mov cx, dx
        ; sub t.4.1{r1}, t.4.1{r1}, 1
        sub cx, 1
        ; branch columnCursor{r4} notequals t.4.1{r1}: if_11_end, if_13_then
        cmp r9w, cx
        jne _if_11_end
        jmp _if_13_then
_if_12_then:
        ; 64:11 return 91
        ; const {r0}, 91
        mov al, 91
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_13_then:
        ; 67:11 return 93
        ; const {r0}, 93
        mov al, 93
        jmp _getSpacer@i16@i16@i16@i16_ret
_if_11_end:
        ; 70:9 return 32
        ; const {r0}, 32
        mov al, 32
_getSpacer@i16@i16@i16@i16_ret:
        add rsp, 8
        ret

        ; void printCell@u8@i16@i16
        ;   rsp+64: arg cell
        ;   rsp+72: arg row
        ;   rsp+80: arg column
        ;   rsp+48: var chr.1
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
        ; const chr.1{r0}, 46
        mov al, 46
        ; move chr.1, chr.1{r0}
        lea r11, [rsp+48]
        mov [r11], al
        ; 75:2 if isOpen@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=75:13]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.5.1{r0} = isOpen@u8[cell{r1}] -> bool
        call _isOpen@u8
        ; branch t.5.1{r0} notequals 0: if_14_then, if_14_else
        cmp al, 0
        jne _if_14_then
        ; 89:7 if isFlag@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=89:18]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.7.1{r0} = isFlag@u8[cell{r1}] -> bool
        call _isFlag@u8
        ; branch t.7.1{r0} equals 0: printCell@u8@i16@i16.no_critical_edge_10, if_17_then
        cmp al, 0
        je _printCell@u8@i16@i16.no_critical_edge_10
        jmp _if_17_then
_if_14_then:
        ; 76:3 if isBomb@u8([ExprVarAccess[varName=cell, index=0, scope=parameter, type=u8, varIsArray=false, location=76:14]])
        ; move cell{r1}, cell{r6}
        mov cl, bl
        ; call t.6.1{r0} = isBomb@u8[cell{r1}] -> bool
        call _isBomb@u8
        ; branch t.6.1{r0} equals 0: if_15_else, if_15_then
        cmp al, 0
        je _if_15_else
        jmp _if_15_then
_printCell@u8@i16@i16.no_critical_edge_10:
        ; move chr.1{r6}, chr.1
        lea r11, [rsp+48]
        mov bl, [r11]
        jmp _if_14_end
_if_17_then:
        ; const chr.3{r6}, 35
        mov bl, 35
        jmp _if_14_end
_if_15_else:
        ; move row{r1}, row{r7}
        mov cx, r12w
        ; move column{r2}, column
        lea r11, [rsp+80]
        mov dx, [r11]
        ; call count.1{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; 81:4 if count > 0
        ; branch count.1{r0} lteq 0: if_16_else, if_16_then
        cmp al, 0
        jbe _if_16_else
        jmp _if_16_then
_if_15_then:
        ; const chr.4{r6}, 42
        mov bl, 42
        jmp _if_14_end
_if_16_else:
        ; const chr.5{r6}, 32
        mov bl, 32
        jmp _if_14_end
_if_16_then:
        ; move chr.6{r6}, count.1{r0}
        mov bl, al
        ; add chr.6{r6}, chr.6{r6}, 48
        add bl, 48
_if_14_end:
        ; move chr.2{r1}, chr.2{r6}
        mov cl, bl
        ; call printChar@u8[chr.2{r1}]
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
        ;   rsp+48: var row.2
        ;   rsp+50: var column.2
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
        ; const row.1{r0}, 0
        mov ax, 0
        ; 97:2 for row < 20
        ; move row.2{r1}, row.1{r0}
        mov cx, ax
        ; move row.2, row.2{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move row.2{r0}, row.2
        lea r11, [rsp+48]
        mov ax, [r11]
        jmp _for_18
_for_18_body:
        ; move row.2, row.2{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const arg.1.0{r1}, 124
        mov cl, 124
        ; call printChar@u8[arg.1.0{r1}]
        call _printChar@u8
        ; const column.1{r0}, 0
        mov ax, 0
        ; 99:3 for column < 40
        ; move column.2{r2}, column.1{r0}
        mov dx, ax
        ; move column.2{r0}, column.2{r2}
        mov ax, dx
        jmp _for_19
_for_19_body:
        ; move row.2{r1}, row.2
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move column.2{r2}, column.2{r0}
        mov dx, ax
        ; move row.2, row.2{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move column.2, column.2{r2}
        lea r11, [rsp+50]
        mov [r11], dx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; move columnCursor{r4}, columnCursor{r7}
        mov r9w, r12w
        ; call spacer.2{r0} = getSpacer@i16@i16@i16@i16[row.2{r1}, column.2{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer.2{r1}, spacer.2{r0}
        mov cl, al
        ; call printChar@u8[spacer.2{r1}]
        call _printChar@u8
        ; move row.2{r1}, row.2
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move row.2, row.2{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move column.2{r2}, column.2
        lea r11, [rsp+50]
        mov dx, [r11]
        ; move column.2, column.2{r2}
        lea r11, [rsp+50]
        mov [r11], dx
        ; call cell.1{r0} = getCell@i16@i16[row.2{r1}, column.2{r2}] -> u8
        call _getCell@i16@i16
        ; move cell.1{r1}, cell.1{r0}
        mov cl, al
        ; move row.2{r2}, row.2
        lea r11, [rsp+48]
        mov dx, [r11]
        ; move row.2, row.2{r2}
        lea r11, [rsp+48]
        mov [r11], dx
        ; move column.2{r3}, column.2
        lea r11, [rsp+50]
        mov r8w, [r11]
        ; move column.2, column.2{r3}
        lea r11, [rsp+50]
        mov [r11], r8w
        ; call printCell@u8@i16@i16[cell.1{r1}, row.2{r2}, column.2{r3}]
        call _printCell@u8@i16@i16
        ; move column.2{r0}, column.2
        lea r11, [rsp+50]
        mov ax, [r11]
        ; add column.3{r0}, column.3{r0}, 1
        add ax, 1
_for_19:
        ; branch column.2{r0} lt 40: for_19_body, for_19_break
        cmp ax, 40
        jl _for_19_body
        ; move row.2{r1}, row.2
        lea r11, [rsp+48]
        mov cx, [r11]
        ; move row.2, row.2{r1}
        lea r11, [rsp+48]
        mov [r11], cx
        ; move rowCursor{r3}, rowCursor{r6}
        mov r8w, bx
        ; move columnCursor{r4}, columnCursor{r7}
        mov r9w, r12w
        ; const arg.6.1{r2}, 40
        mov dx, 40
        ; call spacer.1{r0} = getSpacer@i16@i16@i16@i16[row.2{r1}, arg.6.1{r2}, rowCursor{r3}, columnCursor{r4}] -> u8
        call _getSpacer@i16@i16@i16@i16
        ; move spacer.1{r1}, spacer.1{r0}
        mov cl, al
        ; call printChar@u8[spacer.1{r1}]
        call _printChar@u8
        ; const t.7.1{r1}, [string-0]
        lea rcx, [string_0]
        ; call printString@@u8[t.7.1{r1}]
        call _printString@@u8
        ; move row.2{r0}, row.2
        lea r11, [rsp+48]
        mov ax, [r11]
        ; add row.4{r0}, row.4{r0}, 1
        add ax, 1
_for_18:
        ; branch row.2{r0} lt 20: for_18_body, printField@i16@i16_ret
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
        ; move i.1{r6}, i{r1}
        mov bx, cx
        jmp _for_20
_for_20_body:
        ; const arg.0.0{r1}, 48
        mov cl, 48
        ; call printChar@u8[arg.0.0{r1}]
        call _printChar@u8
        ; move i.2{r0}, i.1{r6}
        mov ax, bx
        ; sub i.2{r0}, i.2{r0}, 1
        sub ax, 1
        ; move i.1{r6}, i.2{r0}
        mov bx, ax
_for_20:
        ; branch i.1{r6} gt 0: for_20_body, printSpaces@i16_ret
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
        ; const count.1{r3}, 0
        mov r8b, 0
        ; 119:2 if value < 0
        ; branch value{r1} lt 0: if_21_then, getDigitCount@i16.no_critical_edge_6
        cmp cx, 0
        jl _if_21_then
        ; move value.1{r4}, value{r1}
        mov r9w, cx
        jmp _while_22
_if_21_then:
        ; const count.3{r3}, 1
        mov r8b, 1
        ; neg value.2{r4}, value{r1}
        mov r9, rcx
        neg r9
_while_22:
        ; add count.5{r3}, count.5{r3}, 1
        add r8b, 1
        ; move value.4{r0}, value.4{r4}
        mov ax, r9w
        ; div value.4{r0}, value.4{r0}, 10
        movsx rax, ax
        mov cx, 10
        cqo
        idiv cx
        ; move value.4{r4}, value.4{r0}
        mov r9w, ax
        ; 127:3 if value == 0
        ; branch value.4{r4} notequals 0: while_22, while_22_break
        cmp r9w, 0
        jne _while_22
        ; 132:9 return count
        ; move count.5{r0}, count.5{r3}
        mov al, r8b
        add rsp, 8
        ret

        ; i16 getHiddenCount
        ;   rsp+48: var c.2
_getHiddenCount:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; const count.1{r6}, 0
        mov bx, 0
        ; const r.1{r7}, 0
        mov r12w, 0
        ; 137:2 for r < 20
        jmp _for_24
_for_24_body:
        ; const c.1{r0}, 0
        mov ax, 0
        ; 138:3 for c < 40
        ; move c.2{r2}, c.1{r0}
        mov dx, ax
        jmp _for_25
_for_25_body:
        ; move r.2{r1}, r.2{r7}
        mov cx, r12w
        ; move c.2, c.2{r2}
        lea r11, [rsp+48]
        mov [r11], dx
        ; call cell.1{r0} = getCell@i16@i16[r.2{r1}, c.2{r2}] -> u8
        call _getCell@i16@i16
        ; 140:4 if cell & 6 == 0
        ; move t.4.1{r1}, cell.1{r0}
        mov cl, al
        ; and t.4.1{r1}, t.4.1{r1}, 6
        and cl, 6
        ; branch t.4.1{r1} equals 0: if_26_then, getHiddenCount.no_critical_edge_10
        cmp cl, 0
        je _if_26_then
        ; move count.4{r1}, count.3{r6}
        mov cx, bx
        jmp _for_25_continue
_if_26_then:
        ; move count.5{r1}, count.3{r6}
        mov cx, bx
        ; add count.5{r1}, count.5{r1}, 1
        add cx, 1
_for_25_continue:
        ; move c.2{r2}, c.2
        lea r11, [rsp+48]
        mov dx, [r11]
        ; add c.4{r2}, c.4{r2}, 1
        add dx, 1
        ; move count.3{r6}, count.4{r1}
        mov bx, cx
_for_25:
        ; branch c.2{r2} lt 40: for_25_body, for_24_continue
        cmp dx, 40
        jl _for_25_body
        ; move r.4{r1}, r.2{r7}
        mov cx, r12w
        ; add r.4{r1}, r.4{r1}, 1
        add cx, 1
        ; move r.2{r7}, r.4{r1}
        mov r12w, cx
_for_24:
        ; branch r.2{r7} lt 20: for_24_body, for_24_break
        cmp r12w, 20
        jl _for_24_body
        ; 145:9 return count
        ; move count.2{r0}, count.2{r6}
        mov ax, bx
        add rsp, 32
        ; restore clobbered non-volatile registers
        pop r12
        pop rbx
        add rsp, 8
        ret

        ; bool printLeft
        ;   rsp+48: var bombDigits.1
_printLeft:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; call count.1{r0} = getHiddenCount[] -> i16
        call _getHiddenCount
        ; move count.1{r6}, count.1{r0}
        mov bx, ax
        ; move count.1{r1}, count.1{r6}
        mov cx, bx
        ; call t.3.1{r0} = getDigitCount@i16[count.1{r1}] -> u8
        call _getDigitCount@i16
        ; cast leftDigits.1{r7}(i16), t.3.1{r0}(u8)
        movzx r12w, al
        ; const arg.2.0{r1}, 40
        mov cx, 40
        ; call t.4.1{r0} = getDigitCount@i16[arg.2.0{r1}] -> u8
        call _getDigitCount@i16
        ; cast bombDigits.1{r0}(i16), t.4.1{r0}(u8)
        movzx ax, al
        ; move bombDigits.1, bombDigits.1{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const arg.3.0{r1}, 20
        mov cx, 20
        ; const arg.3.1{r2}, 6
        mov dx, 6
        ; call setCursor@i16@i16[arg.3.0{r1}, arg.3.1{r2}]
        call _setCursor@i16@i16
        ; move bombDigits.1{r0}, bombDigits.1
        lea r11, [rsp+48]
        mov ax, [r11]
        ; move t.5.1{r1}, bombDigits.1{r0}
        mov cx, ax
        ; sub t.5.1{r1}, t.5.1{r1}, leftDigits.1{r7}
        sub cx, r12w
        ; call printSpaces@i16[t.5.1{r1}]
        call _printSpaces@i16
        ; move count.1{r1}, count.1{r6}
        mov cx, bx
        ; call printUint@i16[count.1{r1}]
        call _printUint@i16
        ; 156:15 return count == 0
        ; equals t.6.1{r0}, count.1{r6}, 0
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
        ; branch a{r1} lt 0: if_27_then, if_27_end
        cmp cx, 0
        jl _if_27_then
        ; 163:9 return a
        ; move a{r0}, a{r1}
        mov ax, cx
        jmp _abs@i16_ret
_if_27_then:
        ; 161:10 return -a
        ; neg t.1.1{r1}, a{r1}
        neg rcx
        ; move t.1.1{r0}, t.1.1{r1}
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
        ; const r.1{r6}, 0
        mov bx, 0
        ; 167:2 for r < 20
        jmp _for_28
_for_28_body:
        ; const c.1{r7}, 0
        mov r12w, 0
        ; 168:3 for c < 40
        jmp _for_29
_for_29_body:
        ; move r.2{r1}, r.2{r6}
        mov cx, bx
        ; move c.2{r2}, c.2{r7}
        mov dx, r12w
        ; const arg.0.2{r3}, 0
        mov r8b, 0
        ; call setCell@i16@i16@u8[r.2{r1}, c.2{r2}, arg.0.2{r3}]
        call _setCell@i16@i16@u8
        ; move c.3{r0}, c.2{r7}
        mov ax, r12w
        ; add c.3{r0}, c.3{r0}, 1
        add ax, 1
        ; move c.2{r7}, c.3{r0}
        mov r12w, ax
_for_29:
        ; branch c.2{r7} lt 40: for_29_body, for_28_continue
        cmp r12w, 40
        jl _for_29_body
        ; move r.4{r0}, r.2{r6}
        mov ax, bx
        ; add r.4{r0}, r.4{r0}, 1
        add ax, 1
        ; move r.2{r6}, r.4{r0}
        mov bx, ax
_for_28:
        ; branch r.2{r6} lt 20: for_28_body, clearField_ret
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
        ;   rsp+48: var bombs.2
        ;   rsp+50: var row.1
        ;   rsp+52: var column.1
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
        ; const bombs.1{r0}, 40
        mov ax, 40
        ; 175:2 for bombs > 0
        ; move bombs.2, bombs.2{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; move bombs.2{r0}, bombs.2
        lea r11, [rsp+48]
        mov ax, [r11]
        jmp _for_30
_for_30_body:
        ; move bombs.2, bombs.2{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; call t.6.1{r0} = random[] -> i32
        call _random
        ; move t.5.1{r3}, t.6.1{r0}
        mov r8d, eax
        ; move t.5.1{r0}, t.5.1{r3}
        mov eax, r8d
        ; mod t.5.1{r2}, t.5.1{r0}, 20
        movsxd rax, eax
        mov cx, 20
        cqo
        idiv cx
        ; move t.5.1{r3}, t.5.1{r2}
        mov r8d, edx
        ; cast row.1{r1}(i16), t.5.1{r3}(i32)
        mov cx, r8w
        ; move row.1, row.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; call t.8.1{r0} = random[] -> i32
        call _random
        ; move t.7.1{r3}, t.8.1{r0}
        mov r8d, eax
        ; move t.7.1{r0}, t.7.1{r3}
        mov eax, r8d
        ; mod t.7.1{r2}, t.7.1{r0}, 40
        movsxd rax, eax
        mov cx, 40
        cqo
        idiv cx
        ; move t.7.1{r3}, t.7.1{r2}
        mov r8d, edx
        ; cast column.1{r2}(i16), t.7.1{r3}(i32)
        mov dx, r8w
        ; move column.1, column.1{r2}
        lea r11, [rsp+52]
        mov [r11], dx
        ; 178:3 if abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=row, index=3, scope=function, type=i16, varIsArray=false, location=178:11], right=ExprVarAccess[varName=curr_r, index=0, scope=parameter, type=i16, varIsArray=false, location=178:20], location=178:18]]) > 1 || abs@i16([ExprBinary[op=-, type=i16, left=ExprVarAccess[varName=column, index=4, scope=function, type=i16, varIsArray=false, location=179:11], right=ExprVarAccess[varName=curr_c, index=1, scope=parameter, type=i16, varIsArray=false, location=179:20], location=179:18]]) > 1
        ; move row.1{r0}, row.1
        lea r11, [rsp+50]
        mov ax, [r11]
        ; move t.10.1{r1}, row.1{r0}
        mov cx, ax
        ; move row.1, row.1{r0}
        lea r11, [rsp+50]
        mov [r11], ax
        ; sub t.10.1{r1}, t.10.1{r1}, curr_r{r6}
        sub cx, bx
        ; call t.9.1{r0} = abs@i16[t.10.1{r1}] -> i16
        call _abs@i16
        ; branch t.9.1{r0} gt 1: if_31_then, or_32
        cmp ax, 1
        jg _if_31_then
        ; move column.1{r0}, column.1
        lea r11, [rsp+52]
        mov ax, [r11]
        ; move t.12.1{r1}, column.1{r0}
        mov cx, ax
        ; move column.1, column.1{r0}
        lea r11, [rsp+52]
        mov [r11], ax
        ; sub t.12.1{r1}, t.12.1{r1}, curr_c{r7}
        sub cx, r12w
        ; call t.11.1{r0} = abs@i16[t.12.1{r1}] -> i16
        call _abs@i16
        ; branch t.11.1{r0} lteq 1: for_30_continue, if_31_then
        cmp ax, 1
        jle _for_30_continue
_if_31_then:
        ; move row.1{r1}, row.1
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move column.1{r2}, column.1
        lea r11, [rsp+52]
        mov dx, [r11]
        ; const arg.4.2{r3}, 1
        mov r8b, 1
        ; call setCell@i16@i16@u8[row.1{r1}, column.1{r2}, arg.4.2{r3}]
        call _setCell@i16@i16@u8
_for_30_continue:
        ; move bombs.2{r0}, bombs.2
        lea r11, [rsp+48]
        mov ax, [r11]
        ; sub bombs.5{r0}, bombs.5{r0}, 1
        sub ax, 1
_for_30:
        ; branch bombs.2{r0} gt 0: for_30_body, initField@i16@i16_ret
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
        ;   rsp+48: var dr.2
        ;   rsp+50: var r.1
        ;   rsp+52: var dc.2
        ;   rsp+54: var c.1
        ;   rsp+56: var cell.1
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
        ; call t.7.1{r0} = getBombCountAround@i16@i16[row{r1}, column{r2}] -> u8
        call _getBombCountAround@i16@i16
        ; branch t.7.1{r0} notequals 0: maybeRevealAround@i16@i16_ret, if_33_end
        cmp al, 0
        jne _maybeRevealAround@i16@i16_ret
        ; const dr.1{r0}, -1
        mov ax, -1
        ; 190:2 for dr <= 1
        jmp _for_34
_for_34_body:
        ; move r.1{r1}, row{r6}
        mov cx, bx
        ; add r.1{r1}, r.1{r1}, dr.2{r0}
        add cx, ax
        ; const dc.1{r3}, -1
        mov r8w, -1
        ; 192:3 for dc <= 1
        ; move dr.2, dr.2{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move dc.2{r0}, dc.2{r3}
        mov ax, r8w
        jmp _for_35
_for_35_body:
        ; move dc.2{r3}, dc.2{r0}
        mov r8w, ax
        ; move dr.2{r0}, dr.2
        lea r11, [rsp+48]
        mov ax, [r11]
        ; move r.1{r1}, r.1
        lea r11, [rsp+50]
        mov cx, [r11]
        ; branch dr.2{r0} notequals 0: maybeRevealAround@i16@i16.no_critical_edge_15, and_37
        cmp ax, 0
        jne _maybeRevealAround@i16@i16.no_critical_edge_15
        ; move dr.2, dr.2{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        jmp _and_37
_maybeRevealAround@i16@i16.no_critical_edge_15:
        ; move dr.2, dr.2{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        jmp _if_36_end
_and_37:
        ; move dr.2, dr.2{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; branch dc.2{r3} notequals 0: if_36_end, maybeRevealAround@i16@i16.no_critical_edge_18
        cmp r8w, 0
        jne _if_36_end
        ; move dc.2, dc.2{r3}
        lea r11, [rsp+52]
        mov [r11], r8w
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        jmp _for_35_continue
_if_36_end:
        ; move c.1{r2}, column{r7}
        mov dx, r12w
        ; add c.1{r2}, c.1{r2}, dc.2{r3}
        add dx, r8w
        ; move dc.2, dc.2{r3}
        lea r11, [rsp+52]
        mov [r11], r8w
        ; 198:4 if !checkCellBounds@i16@i16([ExprVarAccess[varName=r, index=3, scope=function, type=i16, varIsArray=false, location=198:25], ExprVarAccess[varName=c, index=5, scope=function, type=i16, varIsArray=false, location=198:28]])
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c.1, c.1{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call t.8.1{r0} = checkCellBounds@i16@i16[r.1{r1}, c.1{r2}] -> bool
        call _checkCellBounds@i16@i16
        ; branch t.8.1{r0} equals 0: for_35_continue, if_38_end
        cmp al, 0
        je _for_35_continue
        ; move r.1{r1}, r.1
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c.1{r2}, c.1
        lea r11, [rsp+54]
        mov dx, [r11]
        ; move c.1, c.1{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call cell.1{r0} = getCell@i16@i16[r.1{r1}, c.1{r2}] -> u8
        call _getCell@i16@i16
        ; 203:4 if isOpen@u8([ExprVarAccess[varName=cell, index=6, scope=function, type=u8, varIsArray=false, location=203:15]])
        ; move cell.1{r1}, cell.1{r0}
        mov cl, al
        ; move cell.1, cell.1{r0}
        lea r11, [rsp+56]
        mov [r11], al
        ; call t.9.1{r0} = isOpen@u8[cell.1{r1}] -> bool
        call _isOpen@u8
        ; branch t.9.1{r0} notequals 0: for_35_continue, if_39_end
        cmp al, 0
        jne _for_35_continue
        ; move cell.1{r0}, cell.1
        lea r11, [rsp+56]
        mov al, [r11]
        ; move t.10.1{r3}, cell.1{r0}
        mov r8b, al
        ; or t.10.1{r3}, t.10.1{r3}, 2
        or r8b, 2
        ; move r.1{r1}, r.1
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c.1{r2}, c.1
        lea r11, [rsp+54]
        mov dx, [r11]
        ; move c.1, c.1{r2}
        lea r11, [rsp+54]
        mov [r11], dx
        ; call setCell@i16@i16@u8[r.1{r1}, c.1{r2}, t.10.1{r3}]
        call _setCell@i16@i16@u8
        ; move r.1{r1}, r.1
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move r.1, r.1{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move c.1{r2}, c.1
        lea r11, [rsp+54]
        mov dx, [r11]
        ; call maybeRevealAround@i16@i16[r.1{r1}, c.1{r2}]
        call _maybeRevealAround@i16@i16
_for_35_continue:
        ; move dc.2{r0}, dc.2
        lea r11, [rsp+52]
        mov ax, [r11]
        ; add dc.5{r0}, dc.5{r0}, 1
        add ax, 1
_for_35:
        ; branch dc.2{r0} lteq 1: for_35_body, for_34_continue
        cmp ax, 1
        jle _for_35_body
        ; move dr.2{r0}, dr.2
        lea r11, [rsp+48]
        mov ax, [r11]
        ; add dr.4{r0}, dr.4{r0}, 1
        add ax, 1
_for_34:
        ; branch dr.2{r0} lteq 1: for_34_body, maybeRevealAround@i16@i16_ret
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
        ;   rsp+48: var curr_r.1
        ;   rsp+50: var curr_r.2
        ;   rsp+52: var cell.1
        ;   rsp+53: var cell.3
_main:
        sub rsp, 8
        ; save clobbered non-volatile registers
        push rbx
        push r12
        sub rsp, 32
        ; begin initialize global variables
        ; const t.__random__{r6}, 0
        mov ebx, 0
        ; addrof a.__random__{r7}, __random__
        lea r12, [var_0]
        ; store [a.__random__{r7}], t.__random__{r6}
        mov [r12], ebx
        ; end initialize global variables
        ; const arg.0.0{r1}, 7439742
        mov ecx, 7439742
        ; call initRandom@i32[arg.0.0{r1}]
        call _initRandom@i32
        ; const needsInitialize.1{r6}, 1
        mov bl, 1
        ; call clearField[]
        call _clearField
        ; const curr_c.1{r7}, 20
        mov r12w, 20
        ; const curr_r.1{r0}, 10
        mov ax, 10
        ; move curr_r.1, curr_r.1{r0}
        lea r11, [rsp+48]
        mov [r11], ax
        ; const arg.2.0{r1}, 20
        mov cx, 20
        ; const arg.2.1{r2}, 0
        mov dx, 0
        ; call setCursor@i16@i16[arg.2.0{r1}, arg.2.1{r2}]
        call _setCursor@i16@i16
        ; const t.6.1{r1}, [string-1]
        lea rcx, [string_1]
        ; call printString@@u8[t.6.1{r1}]
        call _printString@@u8
        ; 221:2 while true
        ; move curr_r.1{r0}, curr_r.1
        lea r11, [rsp+48]
        mov ax, [r11]
        ; move curr_r.2{r1}, curr_r.1{r0}
        mov cx, ax
        ; move curr_r.2, curr_r.2{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        jmp _while_40
_if_41_then:
        ; 224:4 if printLeft([])
        ; call t.7.1{r0} = printLeft[] -> bool
        call _printLeft
        ; branch t.7.1{r0} notequals 0: if_42_then, if_41_end
        cmp al, 0
        jne _if_42_then
_if_41_end:
        ; call chr.1{r0} = getChar[] -> i16
        call _getChar
        ; move chr.1{r3}, chr.1{r0}
        mov r8w, ax
        ; 231:3 if chr == 27
        ; branch chr.1{r3} equals 27: main_ret, if_43_end
        cmp r8w, 27
        je _main_ret
        ; branch chr.1{r3} equals -8120: if_44_then, if_44_else
        cmp r8w, -8120
        je _if_44_then
        ; branch chr.1{r3} notequals -8112: if_45_else, if_45_then
        cmp r8w, -8112
        jne _if_45_else
        jmp _if_45_then
_if_44_then:
        ; move curr_r.2{r4}, curr_r.2
        lea r11, [rsp+50]
        mov r9w, [r11]
        ; move t.10.1{r3}, curr_r.2{r4}
        mov r8w, r9w
        ; add t.10.1{r3}, t.10.1{r3}, 20
        add r8w, 20
        ; sub t.9.1{r3}, t.9.1{r3}, 1
        sub r8w, 1
        ; move curr_r.4{r0}, curr_r.4{r3}
        mov ax, r8w
        ; mod curr_r.4{r2}, curr_r.4{r0}, 20
        movsx rax, ax
        mov cx, 20
        cqo
        idiv cx
        ; move curr_r.4{r3}, curr_r.4{r2}
        mov r8w, dx
        ; move curr_r.2{r4}, curr_r.4{r3}
        mov r9w, r8w
        ; move curr_r.2{r1}, curr_r.2{r4}
        mov cx, r9w
        jmp _while_40
_if_45_else:
        ; move curr_r.2{r4}, curr_r.2
        lea r11, [rsp+50]
        mov r9w, [r11]
        ; branch chr.1{r3} notequals -8117: if_46_else, if_46_then
        cmp r8w, -8117
        jne _if_46_else
        jmp _if_46_then
_if_45_then:
        ; move curr_r.2{r4}, curr_r.2
        lea r11, [rsp+50]
        mov r9w, [r11]
        ; move t.11.1{r3}, curr_r.2{r4}
        mov r8w, r9w
        ; add t.11.1{r3}, t.11.1{r3}, 1
        add r8w, 1
        ; move curr_r.5{r0}, curr_r.5{r3}
        mov ax, r8w
        ; mod curr_r.5{r2}, curr_r.5{r0}, 20
        movsx rax, ax
        mov cx, 20
        cqo
        idiv cx
        ; move curr_r.5{r3}, curr_r.5{r2}
        mov r8w, dx
        ; move curr_r.2{r4}, curr_r.5{r3}
        mov r9w, r8w
        ; move curr_r.2{r1}, curr_r.2{r4}
        mov cx, r9w
        jmp _while_40
_if_46_else:
        ; branch chr.1{r3} notequals -8115: if_47_else, if_47_then
        cmp r8w, -8115
        jne _if_47_else
        jmp _if_47_then
_if_46_then:
        ; add t.13.1{r7}, t.13.1{r7}, 40
        add r12w, 40
        ; sub t.12.1{r7}, t.12.1{r7}, 1
        sub r12w, 1
        ; move curr_c.4{r0}, curr_c.4{r7}
        mov ax, r12w
        ; mod curr_c.4{r2}, curr_c.4{r0}, 40
        movsx rax, ax
        mov cx, 40
        cqo
        idiv cx
        ; move curr_c.4{r7}, curr_c.4{r2}
        mov r12w, dx
        ; move curr_r.2{r1}, curr_r.2{r4}
        mov cx, r9w
        jmp _while_40
_if_47_else:
        ; branch chr.1{r3} notequals 32: if_48_else, if_48_then
        cmp r8w, 32
        jne _if_48_else
        jmp _if_48_then
_if_47_then:
        ; add t.14.1{r7}, t.14.1{r7}, 1
        add r12w, 1
        ; move curr_c.5{r0}, curr_c.5{r7}
        mov ax, r12w
        ; mod curr_c.5{r2}, curr_c.5{r0}, 40
        movsx rax, ax
        mov cx, 40
        cqo
        idiv cx
        ; move curr_c.5{r7}, curr_c.5{r2}
        mov r12w, dx
        ; move curr_r.2{r1}, curr_r.2{r4}
        mov cx, r9w
        jmp _while_40
_if_48_else:
        ; branch chr.1{r3} notequals 13: main.no_critical_edge_28, if_51_then
        cmp r8w, 13
        jne _main.no_critical_edge_28
        jmp _if_51_then
_if_48_then:
        ; branch needsInitialize.2{r6} notequals 0: main.no_critical_edge_31, if_49_then
        cmp bl, 0
        jne _main.no_critical_edge_31
        jmp _if_49_then
_main.no_critical_edge_28:
        ; move curr_r.2{r1}, curr_r.2{r4}
        mov cx, r9w
        jmp _while_40
_if_51_then:
        ; branch needsInitialize.2{r6} equals 0: main.no_critical_edge_29, if_52_then
        cmp bl, 0
        je _main.no_critical_edge_29
        jmp _if_52_then
_main.no_critical_edge_31:
        ; move curr_r.2{r1}, curr_r.2{r4}
        mov cx, r9w
        jmp _while_40
_if_49_then:
        ; move curr_r.2{r1}, curr_r.2{r4}
        mov cx, r9w
        ; move curr_r.2, curr_r.2{r4}
        lea r11, [rsp+50]
        mov [r11], r9w
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call cell.1{r0} = getCell@i16@i16[curr_r.2{r1}, curr_c.2{r2}] -> u8
        call _getCell@i16@i16
        ; 255:5 if !isOpen@u8([ExprVarAccess[varName=cell, index=4, scope=function, type=u8, varIsArray=false, location=255:17]])
        ; move cell.1{r1}, cell.1{r0}
        mov cl, al
        ; move cell.1, cell.1{r0}
        lea r11, [rsp+52]
        mov [r11], al
        ; call t.15.1{r0} = isOpen@u8[cell.1{r1}] -> bool
        call _isOpen@u8
        ; branch t.15.1{r0} notequals 0: main.no_critical_edge_32, if_50_then
        cmp al, 0
        jne _main.no_critical_edge_32
        jmp _if_50_then
_main.no_critical_edge_29:
        ; move curr_r.2, curr_r.2{r4}
        lea r11, [rsp+50]
        mov [r11], r9w
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        jmp _if_52_end
_if_52_then:
        ; move curr_r.2, curr_r.2{r4}
        lea r11, [rsp+50]
        mov [r11], r9w
        ; const needsInitialize.5{r6}, 0
        mov bl, 0
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move curr_r.2, curr_r.2{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call initField@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _initField@i16@i16
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        jmp _if_52_end
_main.no_critical_edge_32:
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        jmp _while_40
_if_50_then:
        ; move cell.1{r0}, cell.1
        lea r11, [rsp+52]
        mov al, [r11]
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move cell.2{r3}, cell.1{r0}
        mov r8b, al
        ; xor cell.2{r3}, cell.2{r3}, 4
        xor r8b, 4
        ; move curr_r.2, curr_r.2{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call setCell@i16@i16@u8[curr_r.2{r1}, curr_c.2{r2}, cell.2{r3}]
        call _setCell@i16@i16@u8
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        jmp _while_40
_if_52_end:
        ; move curr_r.2, curr_r.2{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call cell.3{r0} = getCell@i16@i16[curr_r.2{r1}, curr_c.2{r2}] -> u8
        call _getCell@i16@i16
        ; 267:4 if !isOpen@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=267:16]])
        ; move cell.3{r1}, cell.3{r0}
        mov cl, al
        ; move cell.3, cell.3{r0}
        lea r11, [rsp+53]
        mov [r11], al
        ; call t.16.1{r0} = isOpen@u8[cell.3{r1}] -> bool
        call _isOpen@u8
        ; branch t.16.1{r0} notequals 0: if_53_end, if_53_then
        cmp al, 0
        jne _if_53_end
        ; move cell.3{r0}, cell.3
        lea r11, [rsp+53]
        mov al, [r11]
        ; move t.17.1{r3}, cell.3{r0}
        mov r8b, al
        ; move cell.3, cell.3{r0}
        lea r11, [rsp+53]
        mov [r11], al
        ; or t.17.1{r3}, t.17.1{r3}, 2
        or r8b, 2
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move curr_r.2, curr_r.2{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call setCell@i16@i16@u8[curr_r.2{r1}, curr_c.2{r2}, t.17.1{r3}]
        call _setCell@i16@i16@u8
_if_53_end:
        ; 270:4 if isBomb@u8([ExprVarAccess[varName=cell, index=5, scope=function, type=u8, varIsArray=false, location=270:15]])
        ; move cell.3{r1}, cell.3
        lea r11, [rsp+53]
        mov cl, [r11]
        ; call t.18.1{r0} = isBomb@u8[cell.3{r1}] -> bool
        call _isBomb@u8
        ; branch t.18.1{r0} notequals 0: if_54_then, if_54_end
        cmp al, 0
        jne _if_54_then
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move curr_r.2, curr_r.2{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call maybeRevealAround@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _maybeRevealAround@i16@i16
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
_while_40:
        ; move curr_r.2, curr_r.2{r1}
        lea r11, [rsp+50]
        mov [r11], cx
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call printField@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _printField@i16@i16
        ; 223:3 if !needsInitialize
        ; branch needsInitialize.2{r6} notequals 0: if_41_end, if_41_then
        cmp bl, 0
        jne _if_41_end
        jmp _if_41_then
_if_42_then:
        ; const t.8.1{r1}, [string-2]
        lea rcx, [string_2]
        ; call printString@@u8[t.8.1{r1}]
        call _printString@@u8
        jmp _main_ret
_if_54_then:
        ; move curr_r.2{r1}, curr_r.2
        lea r11, [rsp+50]
        mov cx, [r11]
        ; move curr_c.2{r2}, curr_c.2{r7}
        mov dx, r12w
        ; call printField@i16@i16[curr_r.2{r1}, curr_c.2{r2}]
        call _printField@i16@i16
        ; const t.19.1{r1}, [string-3]
        lea rcx, [string_3]
        ; call printString@@u8[t.19.1{r1}]
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
        string_1 db 'Left:', 0x00
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
